package de.fhg.fokus.xtensions.incubation.concurrent

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.declaration.MutableMemberDeclaration
import org.eclipse.xtend.lib.macro.TransformationParticipant
import java.util.List
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.annotations.AccessorType
import static org.eclipse.xtend.lib.annotations.AccessorType.*
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater
import static de.fhg.fokus.xtensions.incubation.concurrent.AtomicUpdateOperations.*

/**
 * This active annotation generates a static {@link AtomicReferenceFieldUpdater} for the annotated 
 * filed and a couple of methods for atomically getting and updating
 * the annotated field (e.g {@code compareAndSet<FieldName>(current,updated)}) using the 
 * generated updater. This leads to a lower memory footprint than using 
 * {@link java.util.concurrent.atomic.AtomicReference AtomicReference}<br>
 * NOT IMPLEMENTED YET!
 */
@Target(ElementType.FIELD)
@Active(AtomicProcessor)
annotation AtomicAccessors {
	AccessorType[] visibility = #[PRIVATE_GETTER, PRIVATE_SETTER]
	AtomicUpdateOperations[] operations = #[GET_AND_SET, GET_AND_UPDATE, UPDATE_AND_GET, WEAK_COMPARE_AND_SET, COMPARE_AND_SET, LAZY_SET]
}

enum AtomicUpdateOperations {
	GET_AND_SET,
	GET_AND_UPDATE,
	UPDATE_AND_GET,
	WEAK_COMPARE_AND_SET,
	COMPARE_AND_SET,
	LAZY_SET
}

class AtomicProcessor  implements TransformationParticipant<MutableMemberDeclaration> {
	
	override doTransform(List<? extends MutableMemberDeclaration> annotatedTargetElements, extension TransformationContext context) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}