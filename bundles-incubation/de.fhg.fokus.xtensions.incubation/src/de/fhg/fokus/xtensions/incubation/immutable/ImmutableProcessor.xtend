package de.fhg.fokus.xtensions.incubation.immutable

import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructorProcessor
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableMemberDeclaration
import java.util.List
import org.eclipse.xtend.lib.macro.RegisterGlobalsParticipant
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.annotations.AccessorsProcessor
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.eclipse.xtend.lib.macro.declaration.MutableTypeParameterDeclarator
import org.eclipse.xtend.lib.macro.declaration.MutableTypeParameterDeclaration

class ImmutableProcessor implements TransformationParticipant<MutableMemberDeclaration>, RegisterGlobalsParticipant<MutableMemberDeclaration> {

	override doTransform(List<? extends MutableMemberDeclaration> elements, extension TransformationContext context) {
		elements.forEach[transform(context)]
	}

	def dispatch void transform(MutableFieldDeclaration it, extension TransformationContext context) {
		extension val util = new ImmutableProcessor.Util(context)
		handleField(context, util)
	}

	def dispatch void transform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		extension val util = new ImmutableProcessor.Util(context)
		annotatedClass.declaredFields.forEach[it.handleField(context,util)]
		if (annotatedClass.declaredFields.size > 0) {
			val ffc = new FinalFieldsConstructorProcessor.Util(context)
			if (!ffc.hasFinalFieldsConstructor(annotatedClass)) {
				ffc.addFinalFieldsConstructor(annotatedClass)
			}
		}
		
		if(annotatedClass.hasAnnotation(ImmutableFeature.WITH_METHOD)) {
			annotatedClass.addWithMethod(context)
		}
		if(annotatedClass.hasAnnotation(ImmutableFeature.CREATE_METHOD)) {
			annotatedClass.addCreateMethod(context)
		}
	}
	
	override doRegisterGlobals(List<? extends MutableMemberDeclaration> annotatedSourceElements, extension RegisterGlobalsContext context) {
		annotatedSourceElements.filter(ClassDeclaration).forEach[ clazz |
			val annotation = clazz.annotations.findFirst[annotationTypeDeclaration.qualifiedName == Immutable.name]
			if (annotation !== null) {
				val types = annotation.getEnumArrayValue("value").map[ImmutableFeature.valueOf(simpleName)]
				if(types.contains(ImmutableFeature.WITH_METHOD) || types.contains(ImmutableFeature.CREATE_METHOD)) {
					val builderClassName = clazz.qualifiedName + ".Builder"
					val builderClazz = context.findSourceClass(builderClassName)
					if(builderClazz === null) {
						context.registerClass(builderClassName)
					}
				}
			}
		]
	}

	def void handleField(MutableFieldDeclaration it, extension TransformationContext context, extension ImmutableProcessor.Util util) {
		// all fields in immutable classes will be final!
		it.final = true
		if (it.shouldAddUpdateMethod) {
			it.addUpdateMethod()
		}
		if (it.shouldAddFocusMethod) {
			it.addFocusMethod()
		}
	}

	 static class Util {
		extension TransformationContext context

		new(TransformationContext context) {
			this.context = context
		}

		def boolean shouldAddFocusMethod(FieldDeclaration it) {
			if (hasFocusMethod) {
				false
			} else {
				it.shouldAddFeature(ImmutableFeature.FOCUS_METHODS)
			}
		}

		def boolean shouldAddUpdateMethod(FieldDeclaration it) {
			if (hasUpdateMethod) {
				false
			} else {
				shouldAddFeature(ImmutableFeature.UPDATE_METHODS)
			}
		}

		def void addUpdateMethod(MutableFieldDeclaration field) {
			val clazz = field.declaringType
			clazz.addMethod(field.simpleName) [
				val param = addParameter("updater", field.updateMethodType)
				returnType = clazz.newSelfTypeReference
				val typeName = field.type.name
				body = '''
					final «typeName» newValue = «param.simpleName».apply(this.«field.simpleName»);
					return «clazz.constructorCall(field,"newValue")»;
				'''
			]
		}

		def void addFocusMethod(MutableFieldDeclaration field) {
			val clazz = field.declaringType
			clazz.addMethod(field.simpleName + "Focus") [
				val fieldTypeRef = field.type.orObject.wrapperIfPrimitive
				returnType = Focus.findTypeGlobally.newTypeReference(clazz.newSelfTypeReference,fieldTypeRef)
				body = '''
					return «Focus.name».create(this.«field.simpleName», (it)->«clazz.constructorCall(field,"it")»);
				'''
			]
		}
		
		def void addWithMethod(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
			val builder = addBuilderClass(annotatedClass, context)
			annotatedClass.addMethod("with") [
				val clazzRef = annotatedClass.newSelfTypeReference
				val typeParams = annotatedClass.typeParameters.map[it.newSelfTypeReference]
				returnType = clazzRef
				val lambdaType = findTypeGlobally(Procedure1).newTypeReference(builder.newTypeReference(typeParams))
				addParameter("block", lambdaType)
				body = '''
					// For simplicity we use raw types here. Compiler warnings are ignored anyway.
					final «annotatedClass.simpleName».Builder builder = new «annotatedClass.simpleName».Builder(this);
					block.apply(builder);
					return builder.build();
				'''
			]
		}
	
		def addBuilderClass(MutableClassDeclaration annotatedClass, TransformationContext context) {
			val builder = findClass(annotatedClass.qualifiedName + ".Builder")
			builder.final = true
			// Add generics if original type has generics
			annotatedClass.typeParameters.forEach[ typeParam |
				builder.genericTypeReference(typeParam)
			]
			val apu = new AccessorsProcessor.Util(context)
			// create fields of builder
			annotatedClass.declaredFields.forEach [ f |
				val fieldExists = builder.declaredFields.exists[it.simpleName == f.simpleName]
				if(!fieldExists) {
					builder.addField(f.simpleName) [
						// If type of source field is generic, we have to use a respective generic type from builder
						val genericType = annotatedClass.typeParameters.filter[it.newSelfTypeReference == f.type].head
						if(genericType !== null) {
							val targetFieldTypeRef = builder.genericTypeReference(genericType)
							type = targetFieldTypeRef.newTypeReference()
						} else {
							// otherwise we just use the type from original field
							type = f.type.orObject
						}
						visibility = Visibility.PRIVATE
						apu.addGetter(it, Visibility.PUBLIC)
						apu.addSetter(it, Visibility.PUBLIC)
					]
				}
			]
			// does constructor already exist? If not create
			val constructorExists = builder.declaredConstructors.exists[
				val param = it.parameters.head
				param?.type?.type?.qualifiedName == annotatedClass.qualifiedName
			]
			if(!constructorExists) {
				builder.addConstructor [
					val typeParams  = builder.typeParameters.map[it.newSelfTypeReference]
					addParameter("source", annotatedClass.newTypeReference(typeParams))
					visibility = Visibility.PRIVATE
					body = '''
						«FOR f : annotatedClass.declaredFields»
							this.«f.simpleName» = source.«f.simpleName»;
						«ENDFOR»
					'''
				]
			}
			// does empty constructor exist?
			val defaultConstructorExists = builder.declaredConstructors.exists[
				it.parameters.length == 0
			]
			if(!defaultConstructorExists) {
				builder.addConstructor [
					visibility = Visibility.PRIVATE
					body = ''''''
				]
			}
			// If build method does not exist, create it
			val builderMethodExists = builder.declaredMethods.exists[it.simpleName == "build" && parameters.size == 0]
			if(!builderMethodExists) {
				builder.addMethod("build") [
					val typeParams  = builder.typeParameters.map[it.newSelfTypeReference]
					returnType = annotatedClass.newTypeReference(typeParams)
					body = '''
						return new «annotatedClass.simpleName»(
							«FOR f: annotatedClass.declaredFields SEPARATOR ','»
								this.«f.simpleName»
							«ENDFOR»
						);
					'''
				]
			}
			return builder
		}
		
		def void addCreateMethod(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
			val builder = addBuilderClass(annotatedClass, context)
			val createMethodExists = annotatedClass.declaredMethods.exists[
				it.simpleName == "create" &&
				it.parameters.size == 1 &&
				it.parameters.head?.type?.type?.qualifiedName == annotatedClass.qualifiedName + ".Builder"
			]
			if(!createMethodExists) {
				annotatedClass.addMethod("create") [
					static = true
					returnType = annotatedClass.newSelfTypeReference
					
					val typeParams = annotatedClass.typeParameters.map[it.newSelfTypeReference]
					val lambdaType = findTypeGlobally(Procedure1).newTypeReference(builder.newTypeReference(typeParams))
					addParameter("block", lambdaType)
					body = '''
						// For simplicity we use raw types here. Compiler warnings are ignored anyway.
						final «annotatedClass.simpleName».Builder builder = new «annotatedClass.simpleName».Builder();
						block.apply(builder);
						return builder.build();
					'''
				]
			}
		}
		
		def create target: builder.addTypeParameter(genericTypeRef.simpleName, genericTypeRef.upperBounds) 
			genericTypeReference(MutableClassDeclaration builder, MutableTypeParameterDeclaration genericTypeRef) {
				// TODO handle type parameters of type parameters
		}

		def constructorCall(MutableTypeDeclaration clazz, MutableFieldDeclaration field, String value) {
			clazz.declaredFields.map[if(it === field) value else "this." + it.simpleName].
				join('''new «clazz.parameterizedTypeName» (''', ',', ')', [it])
		}
		
		def String parameterizedTypeName(MutableTypeDeclaration clazz) {
			switch(clazz) {
				MutableTypeParameterDeclarator case clazz.typeParameters.size > 0:
					clazz.simpleName + clazz.typeParameters.join('<',',','>')[it.simpleName]
				default: {
					clazz.addWarning(clazz.class.name)
					clazz.simpleName
				}
			}
		}

		def boolean shouldAddFeature(FieldDeclaration it, ImmutableFeature feature) {
			it.hasAnnotation(feature) /*or*/ [
				it.declaringType.hasAnnotation(feature)
			]
		}

		def boolean hasAnnotation(AnnotationTarget it, ImmutableFeature feature, ()=>boolean or) {
			val annotation = it.immutableAnnotation
			if (annotation !== null) {
				val types = annotation.getEnumArrayValue("value").map[ImmutableFeature.valueOf(simpleName)]
				types.contains(feature)
			} else {
				or.apply
			}
		}

		def boolean hasAnnotation(AnnotationTarget it, ImmutableFeature feature) {
			hasAnnotation(it, feature, [false])
		}

		def boolean getHasNoneAnnotation(AnnotationTarget it) {
			val annotation = it.immutableAnnotation
			if (annotation !== null) {
				val types = annotation.getEnumArrayValue("value").map[ImmutableFeature.valueOf(simpleName)]
				types.contains(ImmutableFeature.NONE)
			} else {
				false
			}
		}

		def boolean hasUpdateMethod(FieldDeclaration field) {
			field.declaringType.declaredMethods.exists [
				val paramTypeRef = it.parameters?.head?.type
				val paramTypeName = paramTypeRef?.type?.qualifiedName

				simpleName == field.simpleName && paramTypeName == "org.eclipse.xtext.xbase.lib.Functions.Function1"
			]
		}
		
		def boolean hasFocusMethod(FieldDeclaration field) {
			field.declaringType.declaredMethods.exists [
				simpleName == (field.simpleName + "Focus") && 
				it.parameters.length == 0
			]
		}

		def updateMethodType(FieldDeclaration it) {
			val fieldType = it.type.orObject.wrapperIfPrimitive // TODO handle primitive types
			context.findTypeGlobally(Function1).newTypeReference(fieldType, fieldType)
		}

		def getImmutableAnnotation(AnnotationTarget it) {
			findAnnotation(Immutable.findTypeGlobally)
		}

		private def orObject(TypeReference ref) {
			if(ref === null) object else ref
		}
	}
}
