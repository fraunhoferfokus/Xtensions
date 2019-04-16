package de.fhg.fokus.xtensions.incubation.optional

import java.util.function.BooleanSupplier
import java.util.function.Supplier
import de.fhg.fokus.xtensions.incubation.util.BooleanConsumer

/**
 * This is a class representing a boolean value that may or may not be present.<br>
 * References to instances of this class are <em>always</em> supposed to hold a value.
 * The implementation details of this class may change. Do not rely on details,
 * e.g. if this class is final or abstract or not. There may be instances of subclasses of 
 * this class returned from the static factory methods in the future.
 * @since 1.3.0
 */
abstract class OptionalBoolean {

	package static final class FalseOptional extends OptionalBoolean {

		override isEmpty() {
			false
		}

		override isPresent() {
			true
		}

		override isTrue() {
			false
		}

		override isTrueOrEmpty() {
			false
		}

		override isFalse() {
			true
		}

		override isFalseOrEmpty() {
			true
		}

		override ifTrue(()=>void then) {
			// nothing to do
		}

		override ifTrueOrEmpty(()=>void then) {
			// nothing to do
		}

		override ifFalse(()=>void then) {
			then.apply
		}

		override ifFalseOrEmpty(()=>void then) {
			then.apply
		}

		override ifPresent(BooleanConsumer consumer) {
			consumer.accept(false)
		}

		override ifPresentOrElse(BooleanConsumer action, Runnable emptyAction) {
			action.accept(false)
		}

		override orElse(boolean fallback) {
			false
		}

		override orElseGet(BooleanSupplier fallback) {
			false
		}

		override <X extends Throwable> orElseThrow(Supplier<? extends X> exceptionSupplier) {
			false
		}

	}

	package static final class TrueOptional extends OptionalBoolean {

		override isEmpty() {
			false
		}

		override isPresent() {
			true
		}

		override isTrue() {
			true
		}

		override isTrueOrEmpty() {
			true
		}

		override isFalse() {
			false
		}

		override isFalseOrEmpty() {
			false
		}

		override ifTrue(()=>void then) {
			then.apply
		}

		override ifTrueOrEmpty(()=>void then) {
			then.apply
		}

		override ifFalse(()=>void then) {
			// nothing to do
		}

		override ifFalseOrEmpty(()=>void then) {
			// nothing to do
		}

		override ifPresent(BooleanConsumer consumer) {
			consumer.accept(true)
		}

		override ifPresentOrElse(BooleanConsumer action, Runnable emptyAction) {
			action.accept(true)
		}

		override orElse(boolean fallback) {
			true
		}

		override orElseGet(BooleanSupplier fallback) {
			true
		}

		override <X extends Throwable> orElseThrow(Supplier<? extends X> exceptionSupplier) {
			true
		}

	}

	package static final class EmptyOptional extends OptionalBoolean {

		override isEmpty() {
			true
		}

		override isPresent() {
			false
		}

		override isTrue() {
			false
		}

		override isTrueOrEmpty() {
			false
		}

		override isFalse() {
			false
		}

		override isFalseOrEmpty() {
			true
		}

		override ifTrue(()=>void then) {
			// nothing to do
		}

		override ifTrueOrEmpty(()=>void then) {
			then.apply
		}

		override ifFalse(()=>void then) {
			// nothing to do
		}

		override ifFalseOrEmpty(()=>void then) {
			then.apply
		}

		override ifPresent(BooleanConsumer consumer) {
			// nothing to do
		}

		override ifPresentOrElse(BooleanConsumer action, Runnable emptyAction) {
			emptyAction.run
		}

		override orElse(boolean fallback) {
			fallback
		}

		override orElseGet(BooleanSupplier fallback) {
			fallback.asBoolean
		}

		override <X extends Throwable> orElseThrow(Supplier<? extends X> exceptionSupplier) {
			throw exceptionSupplier.get
		}

	}

	static val EMPTY = new EmptyOptional
	static val TRUE = new TrueOptional
	static val FALSE = new FalseOptional

	/**
	 * Returns an instance of {@code OptionalBoolean} that is 
	 * empty if the given {@code Boolean b} is {@code null};
	 * otherwise the returned optional holds the value the 
	 * given {@code b} wraps.
	 * @param b a boolean value that will be wrapped in the returned 
	 *  {@code OptionalBoolean} if not {@code null}.
	 * @return {@code OptionalBoolean} that is 
	 * empty if the given parameter {@code b} is {@code null};
	 * otherwise an {@code OptionalBoolean} holding the {@code boolean}
	 * value wrapped by {@code b}.
	 * @since 1.3.0
	 */
	static def OptionalBoolean ofNullable(Boolean b) {
		if (b === null) {
			EMPTY
		} else {
			of(b)
		}
	}

	/**
	 * This method is an alias for the static factory method {@link OptionalBoolean#ofNullable(Boolean) ofNullable},
	 * which has a name that is better suited to be used as an extension method.
	 * @param value a boolean value that will be wrapped in the returned 
	 *  {@code OptionalBoolean} if not {@code null}.
	 * @return {@code OptionalBoolean} that is 
	 * empty if the given parameter {@code value} is {@code null};
	 * otherwise an {@code OptionalBoolean} holding the {@code boolean}
	 * value wrapped by {@code b}.
	 * @see OptionalBoolean#ofNullable(Boolean)
	 * @since 1.3.0
	 */
	@Inline("de.fhg.fokus.xtensions.incubation.optional.OptionalBoolean.ofNullable($1)")
	static def OptionalBoolean asOptional(Boolean value) {
		ofNullable(value)
	}

	/**
	 * Returns an {@code OptionalBoolean} wrapping the given {@code value}.
	 * @param value 
	 * @since 1.3.0
	 */
	static def OptionalBoolean of(boolean value) {
		if (value) {
			TRUE
		} else {
			FALSE
		}
	}

	/**
	 * Provides an instance of {@code OptionalBoolean} holding the {@code boolean}
	 * value {@code true}.
	 * @return an instance of {@code OptionalBoolean} holding the {@code boolean}
	 *   value {@code true}.
	 * @since 1.3.0
	 */
	static def OptionalBoolean ofTrue() {
		TRUE
	}

	/**
	 * 
	 * @since 1.3.0
	 */
	static def OptionalBoolean ofFalse() {
		FALSE
	}

	/**
	 * 
	 * @since 1.3.0
	 */
	static def OptionalBoolean empty() {
		EMPTY
	}

	/**
	 * 
	 * @since 1.3.0
	 */
	def boolean isEmpty();

	/**
	 * 
	 * @since 1.3.0
	 */
	def boolean isPresent();

	/**
	 * 
	 * @since 1.3.0
	 */
	def boolean isTrue();

	/**
	 * 
	 * @since 1.3.0
	 */
	def boolean isTrueOrEmpty();

	/**
	 * 
	 * @since 1.3.0
	 */
	def boolean isFalse();

	/**
	 * 
	 * @since 1.3.0
	 */
	def boolean isFalseOrEmpty();

	/**
	 * 
	 * @since 1.3.0
	 */
	def void ifTrue(()=>void then);

	/**
	 * 
	 * @since 1.3.0
	 */
	def void ifTrueOrEmpty(()=>void then);

	/**
	 * 
	 * @since 1.3.0
	 */
	def void ifFalse(()=>void then);

	/**
	 * 
	 * @since 1.3.0
	 */
	def void ifFalseOrEmpty(()=>void then);

	/**
	 * 
	 * @since 1.3.0
	 */
	def void ifPresent(BooleanConsumer consumer);

	/**
	 * 
	 * @since 1.3.0
	 */
	def void ifPresentOrElse(BooleanConsumer action, Runnable emptyAction);

	/**
	 * 
	 * @since 1.3.0
	 */
	def boolean orElse(boolean fallback);

	/**
	 * 
	 * @since 1.3.0
	 */
	def boolean orElseGet(BooleanSupplier fallback);

	/**
	 * 
	 * @since 1.3.0
	 */
	def <X extends Throwable> boolean orElseThrow(Supplier<? extends X> exceptionSupplier);
}
