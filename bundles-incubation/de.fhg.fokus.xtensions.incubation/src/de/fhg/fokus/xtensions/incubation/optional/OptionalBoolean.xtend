package de.fhg.fokus.xtensions.incubation.optional

import java.util.function.BooleanSupplier
import java.util.function.Supplier
import de.fhg.fokus.xtensions.incubation.util.BooleanConsumer

/**
 * This is a class representing a boolean value that may or may not be present.
 */
final class OptionalBoolean {

	static val EMPTY = new OptionalBoolean(false,false)
	static val TRUE = new OptionalBoolean(true, true)
	static val FALSE = new OptionalBoolean(true, false)

	final boolean isSet
	final boolean value

	static def <T> OptionalBoolean ofNullable(Boolean b) {
		b.asOptional
	}

	static def OptionalBoolean asOptional(Boolean value) {
		if(value === null) {
			EMPTY
		} else {
			of(value)
		}
	}

	static def OptionalBoolean of(boolean value) {
		if(value) {
			TRUE
		} else {
			FALSE
		}
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

	def void ifPresent(BooleanConsumer consumer) {
		if(isSet) {
			consumer.accept(value)
		}
	}

	def void ifPresentOrElse(BooleanConsumer action, Runnable emptyAction) {
		if(isSet) {
			action.accept(value)
		} else {
			emptyAction.run
		}
	}

	def boolean orElse(boolean fallback) {
		if(isSet) {
			value
		} else {
			fallback
		}
	}

	def boolean orElseGet(BooleanSupplier fallback) {
		if(isSet) {
			value
		} else {
			fallback.asBoolean
		}
	}

	def <X extends Throwable> boolean orElseThrow(Supplier<? extends X> exceptionSupplier) {
		if(isSet) {
			value
		} else {
			throw exceptionSupplier.get
		}
	}
}