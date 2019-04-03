package de.fhg.fokus.xtensions.incubation.optional

import java.util.Objects

/**
 * This is a class representing a boolean value that may or may not be present.
 */
final class OptionalBoolean {
	
	static val EMPTY = new OptionalBoolean(false,false)
	
	final boolean isSet
	final boolean value
	
	static def <T> OptionalBoolean asOptional(T context, (T)=>boolean mapper) {
		Objects.requireNonNull(mapper, "mapper function is not allowed to be null")
		if(context === null) {
			EMPTY
		} else {
			val toWrap = mapper.apply(context)
			toWrap.asOptional
		}
	}

	static def OptionalBoolean asOptional(Boolean value) {
		if(value === null) {
			EMPTY
		} else {
			of(value)
		}
	}
	
	static def OptionalBoolean of(boolean value) {
		new OptionalBoolean(true, value)
	}
	
	static def OptionalBoolean empty() {
		EMPTY
	}
	
	private new(boolean isSet, boolean value) {
		this.isSet = isSet
		this.value = value
	}
	
	def boolean isEmpty() {
		!isSet
	}
	
	def boolean isPresent() {
		isSet
	}
	
	def boolean isTrue() {
		isSet && value
	}
	
	def boolean isTrueOrEmpty() {
		!isSet || value
	}
	
	def boolean isFalse() {
		isSet && !value
	}
	
	def boolean isFalseOrEmpty() {
		!isSet || !value
	}
	
	
	
	def void ifTrue(()=>void then) {
		if(isTrue) {
			then.apply
		}
	}
	
	def void ifTrueOrEmpty(()=>void then) {
		if(isTrueOrEmpty) {
			then.apply
		}
	}
	
	def void ifFalse(()=>void then) {
		if(isFalse) {
			then.apply
		}
	}
	
	def void ifFalseOrEmpty(()=>void then) {
		if(isFalseOrEmpty) {
			then.apply
		}
	}
}