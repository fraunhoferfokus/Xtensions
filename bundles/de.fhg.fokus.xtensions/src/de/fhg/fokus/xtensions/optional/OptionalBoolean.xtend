/*******************************************************************************
 * Copyright (c) 2017 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.optional

import java.util.function.BooleanSupplier
import java.util.function.Supplier
import de.fhg.fokus.xtensions.util.BooleanConsumer
import java.util.Optional
import static extension java.util.Objects.*

/**
 * This is a class representing a boolean value that may or may not be present.<br>
 * References to instances of this class are <em>always</em> supposed to hold a value.
 * Instances of this class can only created via the static factory methods
 * {@link OptionalBoolean#empty() empty()}, {@link OptionalBoolean#ofTrue() ofTrue()}, 
 * {@link OptionalBoolean#ofFalse() ofFalse()}, {@link OptionalBoolean#of(boolean) of(boolean)}, or
 * {@link OptionalBoolean#ofNullable(Boolean) ofNullable(Boolean)} / {@link OptionalBoolean#asOptional(Boolean) asOptional(Boolean)}<br>
 * Note that this optional does not have a {@code get} method which throws a runtime exception 
 * if no value is present. Instead, use {@link OptionalBoolean#orElseThrow(Supplier) orElseThrow} instead,
 * explicitly stating which exception to throw if no value is present. Alternatively, the methods with 
 * prefix {@code is} can be used if the empty case can be mapped to either {@code true} or {@code false}.
 * @since 1.3.0
 * @author Max Bureck
 */
abstract class OptionalBoolean {

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
	@Inline("de.fhg.fokus.xtensions.optional.OptionalBoolean.ofNullable($1)")
	static def OptionalBoolean asOptional(Boolean value) {
		ofNullable(value)
	}

	/**
	 * Returns an {@code OptionalBoolean} wrapping the given {@code value}.
	 * Note that this function takes a primitive {@code boolean} value, do
	 * <em>not</em> call this method with a boxed {@code Boolean} (this may
	 * cause a {@code NullPointerException}), use {@link #ofNullable(Boolean) ofNullable} / 
	 * {@link #asOptional(Boolean) asOptional} instead.
	 * @param value the {@code boolean} to be held by the returned {@code OptionalBoolean}
	 * @return an instance of {@code OptionalBoolean} holding the given {@code value}.
	 * @see OptionalBoolean#ofNullable(Boolean)
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
	 * Provides an instance of {@code OptionalBoolean} holding the {@code boolean}
	 * value {@code false}.
	 * @return an instance of {@code OptionalBoolean} holding the {@code boolean}
	 *   value {@code false}.
	 * @since 1.3.0
	 */
	static def OptionalBoolean ofFalse() {
		FALSE
	}

	/**
	 * Provides an instance of {@code OptionalBoolean} which is empty.
	 * @return an instance of {@code OptionalBoolean} which holds no value (empty)
	 * @since 1.3.0
	 */
	static def OptionalBoolean empty() {
		EMPTY
	}

	/**
	 * Determines if this optional is empty (holds no {@code boolean} value). Returns the negation 
	 * of {@link #isPresent()}.
	 * @return {@code true} if this optional is empty, {@code false} if it wraps a {@code boolean} value.
	 * @see OptionalBoolean#isPresent()
	 * @since 1.3.0
	 */
	def boolean isEmpty();

	/**
	 * Determines if this optional is not empty and holds no {@code boolean} value. Returns the negation 
	 * of {@link #isEmpty()}.
	 * @return {@code true} the optional it wraps a {@code boolean} value and is not empty.
	 * @see OptionalBoolean#isEmpty()
	 * @since 1.3.0
	 */
	def boolean isPresent();

	/**
	 * Tests if the optional is not empty and wraps the {@code boolean} value {@code true}.
	 * @return {@code true} if the optional is not empty and holds the {@code boolean} value {@code true}, 
	 *  otherwise returns {@code false}.
	 * @since 1.3.0
	 */
	def boolean isTrue();

	/**
	 * Tests if the optional is either empty or wraps the {@code boolean} value {@code true}.
	 * @return {@code true} if the optional is either empty or holds the {@code boolean} value {@code true}, 
	 *  otherwise returns {@code false}.
	 * @since 1.3.0
	 */
	def boolean isTrueOrEmpty();

	/**
	 * Tests if the optional is not empty and wraps the {@code boolean} value {@code true}.
	 * @return {@code true} if the optional is not empty and holds the {@code boolean} value {@code true}, 
	 *  otherwise returns {@code false}.
	 * @since 1.3.0
	 */
	def boolean isFalse();

	/**
	 * Tests if the optional is either empty or wraps the {@code boolean} value {@code true}.
	 * @return {@code true} if the optional is either empty or holds the {@code boolean} value {@code true}, 
	 *  otherwise returns {@code false}.
	 * @since 1.3.0
	 */
	def boolean isFalseOrEmpty();

	/**
	 * Calls the given {@code then} if the {@code OptionalBoolean} wraps the 
	 * {@code true}. 
	 * @param then is called if this {@code OptionalBoolean} wraps {@code true}
	 * @throws NullPointerException if {@code then} is {@code null}
	 * @since 1.3.0
	 */
	def void ifTrue(()=>void then);

	/**
	 * Calls the given {@code then} if the {@code OptionalBoolean} wraps the 
	 * {@code true} or is empty. 
	 * @param then is called if this {@code OptionalBoolean} wraps {@code true} or is empty
	 * @throws NullPointerException if {@code then} is {@code null}
	 * @since 1.3.0
	 */
	def void ifTrueOrEmpty(()=>void then);

	/**
	 * Calls the given {@code then} if the {@code OptionalBoolean} wraps the 
	 * {@code false}. 
	 * @param then is called if this {@code OptionalBoolean} wraps {@code false}
	 * @throws NullPointerException if {@code then} is {@code null}
	 * @since 1.3.0
	 */
	def void ifFalse(()=>void then);

	/**
	 * Calls the given {@code then} if the {@code OptionalBoolean} wraps the 
	 * {@code false} or is empty. 
	 * @param then is called if this {@code OptionalBoolean} wraps {@code false} or is empty
	 * @throws NullPointerException if {@code then} is {@code null}
	 * @since 1.3.0
	 */
	def void ifFalseOrEmpty(()=>void then);

	/**
	 * Will call the given {@code consumer} if the optional is not empty 
	 * with the {@code boolean} value it holds.
	 * @param consumer will be called with the {@code boolean} value held by the 
	 *  optional, if it is not empty.
	 * @throws NullPointerException if {@code consumer} is {@code null}
	 * @since 1.3.0
	 */
	def void ifPresent(BooleanConsumer consumer);

	/**
	 * Will call the given {@code action} if the optional is not empty 
	 * with the {@code boolean} value it holds, or emptyAction, if the 
	 * optional is empty.
	 * @param action will be called if the option is not empty with the 
	 *  {@code boolean} value held by the optional
	 * @param emptyAction will be called if the optional is empty
	 * @throws NullPointerException if {@code action} or {@code emptyAction} is {@code null}
	 * @since 1.3.0
	 */
	def void ifPresentOrElse(BooleanConsumer action, Runnable emptyAction);

	/**
	 * If the optional is not empty, it will return the {@code boolean}
	 * value held by the optional, otherwise it will return the given 
	 * {@code fallback} value.
	 * @param fallback will be returned from this method if this optional is empty
	 * @return the value held by the optional if it is not empty, otherwise the 
	 *  given {@code fallback} value. 
	 * @since 1.3.0
	 */
	def boolean orElse(boolean fallback);

	/**
	 * If the optional is not empty, the {@code boolean} value held by the optional
	 * will be returned. Otherwise the method returns the value provided by 
	 * {@code fallback.getAsBoolean()}.
	 * @param fallback callback that will be called to compute the return value
	 *  if the optional is empty
	 * @return either the {@code boolean} value held by the optional, or the 
	 *  value provided by {@code fallback} if the optional is empty
	 * @throws NullPointerException if {@code fallback} is {@code null}
	 * @since 1.3.0
	 */
	def boolean orElseGet(BooleanSupplier fallback);

	/**
	 * This method returns the {@code boolean} value held by the optional, or 
	 * throws the exception provided by {@code exceptionSupplier} if the 
	 * optional is empty.
	 * @param exceptionSupplier supplies the exception to be thrown when the 
	 *  optional is empty.
	 * @param <X> type of exception to be thrown if optional is empty
	 * @return {@code boolean} value held by the optional if it is not empty
	 * @throws X if the optional is empty; exception will be provided by {@code exceptionSupplier}
	 * @throws NullPointerException if {@code exceptionSupplier} is {@code null}
	 * @since 1.3.0
	 */
	def <X extends Throwable> boolean orElseThrow(Supplier<? extends X> exceptionSupplier) throws X;

	/**
	 * Returns either the value of the optional boxed into a {@code Boolean}, if the optional
	 * holds a value, or {@code null} if the optional is empty.
	 * @return an empty optional if this optional is empty, otherwise the 
	 * @since 1.3.0
	 */
	def Optional<Boolean> boxed();

	/**
	 * Returns a boxed {@code Boolean} based on the content of the optional. If the optional
	 * is empty, a {@code null} is returned. If the optional holds a value, the boxed value
	 * will be returned.
	 * @return {@code null} if the optional is empty, or a boxed {@code Boolean} wrapping the value
	 *  held by the optional.
	 * @since 1.3.0
	 */
	def Boolean getNullable();
}

/**
 * Variant of {@link OptionalBoolean} that represents the variant where 
 * the optional holds a {@code false} value.
 */
package final class FalseOptional extends OptionalBoolean {

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
		then.requireNonNull("then must not be null")
		// nothing to do
	}

	override ifTrueOrEmpty(()=>void then) {
		then.requireNonNull("then must not be null")
		// nothing to do
	}

	override ifFalse(()=>void then) {
		then.requireNonNull("then must not be null").apply
	}

	override ifFalseOrEmpty(()=>void then) {
		then.requireNonNull("then must not be null").apply
	}

	override ifPresent(BooleanConsumer consumer) {
		consumer.requireNonNull("consumer must not be null").accept(false)
	}

	override ifPresentOrElse(BooleanConsumer action, Runnable emptyAction) {
		emptyAction.requireNonNull("emptyAction must not be null")
		action.requireNonNull("action must not be null").accept(false)
	}

	override orElse(boolean fallback) {
		false
	}

	override orElseGet(BooleanSupplier fallback) {
		fallback.requireNonNull("fallback must not be null")
		false
	}

	override <X extends Throwable> orElseThrow(Supplier<? extends X> exceptionSupplier) {
		exceptionSupplier.requireNonNull("exceptionSupplier must not be null")
		false
	}

	override getNullable() {
		Boolean.FALSE
	}

	override boxed() {
		Optional.of(Boolean.FALSE)
	}

}

/**
 * Variant of {@link OptionalBoolean} that represents the variant where 
 * the optional holds a {@code true} value.
 */
package final class TrueOptional extends OptionalBoolean {

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
		then.requireNonNull("then must not be null").apply
	}

	override ifTrueOrEmpty(()=>void then) {
		then.requireNonNull("then must not be null").apply
	}

	override ifFalse(()=>void then) {
		then.requireNonNull("then must not be null")
		// nothing to do
	}

	override ifFalseOrEmpty(()=>void then) {
		then.requireNonNull("then must not be null")
		// nothing to do
	}

	override ifPresent(BooleanConsumer consumer) {
		consumer.requireNonNull("consumer must not be null").accept(true)
	}

	override ifPresentOrElse(BooleanConsumer action, Runnable emptyAction) {
		emptyAction.requireNonNull("emptyAction must not be null")
		action.requireNonNull("action must not be null").accept(true)
	}

	override orElse(boolean fallback) {
		true
	}

	override orElseGet(BooleanSupplier fallback) {
		fallback.requireNonNull("fallback must not be null")
		true
	}

	override <X extends Throwable> orElseThrow(Supplier<? extends X> exceptionSupplier) {
		exceptionSupplier.requireNonNull("exceptionSupplier must not be null")
		true
	}

	override getNullable() {
		Boolean.TRUE
	}

	override boxed() {
		Optional.of(Boolean.TRUE)
	}

}

/**
 * Variant of {@link OptionalBoolean} that represents the variant of
 * an empty Optional.
 */
package final class EmptyOptional extends OptionalBoolean {

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
		true
	}

	override isFalse() {
		false
	}

	override isFalseOrEmpty() {
		true
	}

	override ifTrue(()=>void then) {
		then.requireNonNull("then must not be null")
		// nothing to do
	}

	override ifTrueOrEmpty(()=>void then) {
		then.requireNonNull("then must not be null").apply
	}

	override ifFalse(()=>void then) {
		then.requireNonNull("then must not be null")
		// nothing to do
	}

	override ifFalseOrEmpty(()=>void then) {
		then.requireNonNull("then must not be null").apply
	}

	override ifPresent(BooleanConsumer consumer) {
		consumer.requireNonNull("consumer must not be null")
		// nothing to do
	}

	override ifPresentOrElse(BooleanConsumer action, Runnable emptyAction) {
		action.requireNonNull("action must not be null")
		emptyAction.requireNonNull("emptyAction must not be null").run
	}

	override orElse(boolean fallback) {
		fallback
	}

	override orElseGet(BooleanSupplier fallback) {
		fallback.requireNonNull("fallback must not be null").asBoolean
	}

	override <X extends Throwable> orElseThrow(Supplier<? extends X> exceptionSupplier) {
		throw exceptionSupplier.requireNonNull("exceptionSupplier must not be null").get
	}

	override getNullable() {
		null
	}

	override boxed() {
		Optional.empty
	}

}
