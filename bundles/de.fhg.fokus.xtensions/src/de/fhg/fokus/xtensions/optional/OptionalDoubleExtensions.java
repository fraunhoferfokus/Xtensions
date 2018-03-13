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
package de.fhg.fokus.xtensions.optional;

import java.util.Collections;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.OptionalDouble;
import java.util.OptionalInt;
import java.util.OptionalLong;
import java.util.PrimitiveIterator.OfDouble;
import java.util.Set;
import java.util.function.DoubleConsumer;
import java.util.function.DoubleFunction;
import java.util.function.DoublePredicate;
import java.util.function.DoubleSupplier;
import java.util.function.DoubleToIntFunction;
import java.util.function.DoubleToLongFunction;
import java.util.function.DoubleUnaryOperator;
import java.util.function.Supplier;
import java.util.stream.DoubleStream;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Pure;

import de.fhg.fokus.xtensions.iteration.DoubleIterable;
import de.fhg.fokus.xtensions.iteration.LongIterable;
import de.fhg.fokus.xtensions.iteration.internal.PrimitiveIterableUtil;

/**
 * This class contains static functions that ease the work with Java 8
 * {@link OptionalDouble}. <br>
 * To make easy use of this functions import this extensions like this in your
 * Xtend source:
 * <pre>
 * {@code import static extension de.fhg.fokus.xtenders.optional.OptionalDoubleExtensions.*}
 * </pre>
 * 
 * @see OptionalExtensions
 * @see OptionalIntExtensions
 * @see OptionalLongExtensions
 * @author Max Bureck
 */
public final class OptionalDoubleExtensions {

	private OptionalDoubleExtensions() {
	}

// TODO needed? whenPresent seems way clearer
//	@FunctionalInterface
//	public interface DoublePresenceCheck extends DoubleConsumer, Procedure1<@NonNull OptionalDouble> {
//
//		/**
//		 * User method, will be called if Optional contains a value.
//		 */
//		@Override
//		void accept(double value);
//
//		@Override
//		default void apply(@NonNull OptionalDouble p) {
//			p.ifPresent(this);
//		}
//
//		@Pure
//		default Procedure1<@NonNull OptionalDouble> elseDo(@NonNull Procedure0 or) {
//			return o -> {
//				if (o.isPresent()) {
//					accept(o.getAsDouble());
//				} else {
//					or.apply();
//				}
//			};
//		}
//
//	}
//
//	@Pure
//	public static <T> @NonNull DoublePresenceCheck ifPresent(@NonNull DoubleConsumer either) {
//		return either::accept;
//	}
	
	/**
	 * This extension method will check if a value is present in {@code self} and if so will call {@code onPresent}
	 * with that value. The returned {@code Else} will allows to perform a block of code if the optional does
	 * not hold a value. Example usage:
	 * <pre>{@code 
	 * val OptionalDouble o = OptionalDouble.of(42.0d)
	 * o.whenPresent [
	 * 	println(it)
	 * ].elseDo [
	 * 	println("no val")
	 * ]
	 * }</pre>
	 * @param self if holds value, {@code onPresent} will be executed with the value held by {@code self}.
	 * @param onPresent will be executed with value of {@code self}, if present.
	 * @return instance of {@code Else} that either execute an else block if {@code self} has no value present,
	 *  or ignore the else block if the value is present.
	 */
	public static Else whenPresent(@NonNull OptionalDouble self, @NonNull DoubleConsumer onPresent) {
		if(self.isPresent()) {
			double value = self.getAsDouble();
			onPresent.accept(value);
			return Else.PRESENT;
		} else {
			return Else.NOT_PRESENT;
		}
	}

	/**
	 * Calls the procedure {@code then} if the optional {@code self} holds no
	 * value. This method is equivalent to the following code:
	 * 
	 * <pre>
	 * <code> if (!self.isPresent()) {
	 * 	then.apply();
	 * }</code>
	 * </pre>
	 * 
	 * @param self
	 *            if optional is empty, {@code then} will be called.
	 * @param then
	 *            procedure to be called if {@code self} does not hold a value.
	 */
	public static void ifNotPresent(@NonNull OptionalDouble self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	/**
	 * This operator is an alias for:
	 * <pre>
	 * <code>o.{@link OptionalDouble#orElse(double) orElse}(alternative)</code>
	 * </pre>
	 * @param o {@code OptionalDouble} checked for a present value 
	 * @param alternative value to be returned by this extension function, oif {@code o} is empty.
	 * @return either the value present in {@code o}, or {@code alternative} if there is no 
	 *  value present in {@code o}.
	 */
	@Pure
	@Inline(value = "$1.orElse($2)", imported = OptionalDouble.class)
	public static double operator_elvis(@NonNull OptionalDouble o, double alternative) {
		return o.orElse(alternative);
	}

	/**
	 * Alias for {@link OptionalDouble#orElseGet(DoubleSupplier)}.
	 * 
	 * @param o
	 *            optional to be queried for value
	 * @param getter
	 *            will be called to get return value if parameter {@code o} is empty.
	 * @return if {@code o} has a value present, will return this value.
	 *         Otherwise returns {@code getter} will be called to get return value.
	 */
	@Pure
	@Inline(value = "$1.orElseGet($2)", imported = OptionalDouble.class)
	public static double operator_elvis(@NonNull OptionalDouble o, DoubleSupplier getter) {
		return o.orElseGet(getter);
	}

	/**
	 * This method is an alias for {@link OptionalDouble#of(double)}.
	 * @param d double to wrap in an {@code OptionalDouble}
	 * @return {@code OptionalDouble}, having present value {@code d}.
	 */
	@Pure
	@Inline(value = "OptionalDouble.of($1)", imported = OptionalDouble.class)
	public static @NonNull OptionalDouble some(double d) {
		return OptionalDouble.of(d);
	}

	/**
	 * Alias for {@link OptionalDouble#empty()}.
	 * @return an {@code OptionalDouble} with no value present.
	 */
	@Pure
	@Inline(value = "OptionalDouble.empty()", imported = OptionalDouble.class)
	public static @NonNull OptionalDouble noDouble() {
		return OptionalDouble.empty();
	}
	
	/**
	 * This method is a shortcut for the following expression:
	 * <pre>
	 * {@code i == null ? OptionalDouble.empty() : OptionalDouble.of(i)}
	 * </pre>
	 * @param i an Integer that is checked for {@code null}. If {@code i == null}, then
	 *  returns an empty {@code OptionalInt}. If {@code i != null} returns an {@code OptionalInt}
	 *  holding the integer value.
	 * @return an {@code OptionalInt} holding {@code i}, if {@code i != null}, an empty {@code OptionalInt} otherwise.
	 */
	@Pure 
	@Inline(value = "$1 == null ? OptionalDouble.empty() : OptionalDouble.of($1)", imported = OptionalDouble.class)
	public static @NonNull OptionalDouble maybe(@Nullable Double i) {
		return i == null ? OptionalDouble.empty() : OptionalDouble.of(i);
	}

	/**
	 * Returns an {@code Optional<Double>} holding the value of {@code self}, or returns 
	 * an empty optional, if the given {@code OptionalDouble} is empty.
	 * @param self value will be extracted from this {@code OptionalDouble}, if value is present
	 *   and wrapped into an {@code Double} which will be returned in an {@code Optional} from
	 *   this method.
	 * @return {@code Optional<Double>} holding the value of {@code self} if present, empty 
	 *  {@code Optional} otherwise
	 */
	@Pure
	public static @NonNull Optional<Double> boxed(@NonNull OptionalDouble self) {
		return map(self, Double::valueOf);
	}

	/**
	 * If the given {@code OptionalDouble self} holds a value and the value tests positive with the given
	 * {@code DoublePredicate predicate}, returns {@code self}, otherwise returns an empty {@code OptionalDouble}.
	 * @param self the optional value that will be filtered using {@code predicate} 
	 * @param predicate the test that will be used to filter {@code self}.
	 * @return filtered {@code OptionalDouble}, empty optional if {@code self} is empty or it's content
	 *  tests negative with {@code predicate}. Otherwise returns {@code self}.
	 */
	public static @NonNull OptionalDouble filter(@NonNull OptionalDouble self, @NonNull DoublePredicate predicate) {
		return self.isPresent() && predicate.test(self.getAsDouble()) ? self : OptionalDouble.empty();
	}

	/**
	 * Maps the value held by {@code self} to an object wrapped in {@code Optional} if present,
	 * returns an empty {@code Optional} otherwise.
	 * @param self the optional, that's value should be mapped if present
	 * @param mapFunc mapping function mapping the value held by {@code self} to an object
	 * @return an empty {@code Optional}, if {@code self} is empty, otherwise an {@code Optional}
	 *  holding the result of {@code op} applied to the value held by {@code self}.
	 * @param <V> type of value the {@code mapFunc} mapps to and is then held in the returned optional
	 */
	public static <V> @NonNull Optional<V> map(@NonNull OptionalDouble self, @NonNull DoubleFunction<V> mapFunc) {
		return self.isPresent() ? Optional.ofNullable(mapFunc.apply(self.getAsDouble())) : Optional.empty();
	}

	/**
	 * Maps the value of {@code self} to an {@code int} value wrapped into an {@code OptionalInt}, if {@code self} holds a value.
	 * Returns an empty {@code OptionalInt} otherwise.
	 * @param self optional, that's held value will be mapped with {@code mapFunc}, if present
	 * @param mapFunc mapping function, to be applied to value of {@code self}, if present
	 * @return optional holding the value of {@code self}, mapped to int using {@code mapFunc} if value present. Empty 
	 *  optional otherwise.
	 */
	public static @NonNull OptionalInt mapInt(@NonNull OptionalDouble self, @NonNull DoubleToIntFunction mapFunc) {
		return self.isPresent() ? OptionalInt.of(mapFunc.applyAsInt(self.getAsDouble())) : OptionalInt.empty();
	}

	/**
	 * Maps the value of {@code self} to a {@code long} value wrapped into an {@code OptionalLong}, if {@code self} holds a value.
	 * Returns an empty {@code OptionalInt} otherwise.
	 * @param self optional, that's held value will be mapped with {@code mapFunc}, if present
	 * @param mapFunc mapping function, to be applied to value of {@code self}, if present
	 * @return optional holding the value of {@code self}, mapped to {@code long} using {@code mapFunc} if value present. Empty 
	 *  optional otherwise.
	 */
	public static @NonNull OptionalLong mapLong(@NonNull OptionalDouble self,
			@NonNull DoubleToLongFunction mapFunc) {
		return self.isPresent() ? OptionalLong.of(mapFunc.applyAsLong(self.getAsDouble())) : OptionalLong.empty();
	}

	/**
	 * Maps the value of {@code self} to a {@code double} value wrapped into an {@code OptionalDouble}, if {@code self} holds a value.
	 * Returns an empty {@code OptionalDouble} otherwise.
	 * @param self optional, that's held value will be mapped with {@code mapFunc}, if present
	 * @param mapFunc mapping function, to be applied to value of {@code self}, if present
	 * @return optional holding the value of {@code self}, mapped to {@code long} using {@code mapFunc} if value present. Empty 
	 *  optional otherwise.
	 */
	public static @NonNull OptionalDouble mapDouble(@NonNull OptionalDouble self, @NonNull DoubleUnaryOperator mapFunc) {
		return self.isPresent() ? OptionalDouble.of(mapFunc.applyAsDouble(self.getAsDouble())) : OptionalDouble.empty();
	}
	
	/**
	 * Maps the value of {@code self} to an {@code OptionalDouble} using {@code mapFunc}, if {@code self} has a present
	 * value. If {@code self} is empty, this method returns an empty {@code OptionalDouble}
	 * 
	 * @param self possibly holding value to be mapped with {@code mapFunc}
	 * @param mapFunc mapping function, used on value of {@code self} if a value is present.
	 * @return optional either holding result of {@code mapFunc} applied to value of {@code self} if 
	 *  value is present, otherwise returning empty optional.
	 */
	public static @NonNull OptionalDouble flatMapDouble(@NonNull OptionalDouble self, @NonNull DoubleFunction<OptionalDouble> mapFunc) {
		return self.isPresent() ? mapFunc.apply(self.getAsDouble()) : self;
	}

	/**
	 * Returns a {@code DoubleIterable} that either provides the one value present in {@code self},
	 * or an {@code DoubleIterable} providing no value if {@code self} is empty.
	 * @param self optional that's value (if present) will be provided via the returned iterable.
	 * @return {@code DoubleIterable} providing one value taken from {@code self} or no value, if {@code self}
	 *   is empty.
	 */
	public static @NonNull DoubleIterable asIterable(@NonNull OptionalDouble self) {
		if (self.isPresent()) {
			double value = self.getAsDouble();
			return new ValueIterable(value);
		} else {
			return PrimitiveIterableUtil.EMPTY_DOUBLEITERABLE;
		}
	}

	private static class ValueIterator implements OfDouble {
		final double value;
		boolean done = false;

		public ValueIterator(double value) {
			this.value = value;
		}

		@Override
		public boolean hasNext() {
			return !done;
		}

		@Override
		public double nextDouble() {
			if (done) {
				throw new NoSuchElementException();
			} else {
				done = true;
				return value;
			}
		}
	}

	/**
	 * Implementation of {@link LongIterable} for iterating over a single long
	 * value.
	 */
	private static class ValueIterable implements DoubleIterable {

		final double value;

		public ValueIterable(double value) {
			super();
			this.value = value;
		}

		@Override
		public OfDouble iterator() {
			return new ValueIterator(value);
		}

		@Override
		public void forEachDouble(DoubleConsumer consumer) {
			consumer.accept(value);
		}

		@Override
		public DoubleStream stream() {
			return DoubleStream.of(value);
		}
	}

	/**
	 * Returns an {@code PrimitiveIterable.OfDouble} that either provides the one value present in {@code self},
	 * or an {@code PrimitiveIterable.OfDouble} providing no value if {@code self} is empty.
	 * @param self optional that's value (if present) will be provided via the returned iterator.
	 * @return {@code PrimitiveIterable.OfDouble} providing one value taken from {@code self} or no value, if {@code self}
	 *   is empty.
	 */
	public static @NonNull OfDouble iterator(@NonNull OptionalDouble self) {
		if (self.isPresent()) {
			double value = self.getAsDouble();
			return new ValueIterator(value);
		} else {
			return PrimitiveIterableUtil.EMPTY_DOUBLEITERATOR;
		}
	}

	/**
	 * Returns an immutable set that either contains the value, held by the
	 * optional, or an empty set, if the optional is empty.
	 * 
	 * @param self
	 *            Optional value is read from
	 * @return Set containing the value held by the input optional, or an empty
	 *         set if the input optional is empty.
	 */
	@Pure
	public static @NonNull Set<Double> toSet(@NonNull OptionalDouble self) {
		if (self.isPresent()) {
			return Collections.singleton(self.getAsDouble());
		} else {
			return Collections.emptySet();
		}
	}
	
	/**
	 * This extension function returns a stream of a single element if the given
	 * optional {@code self} contains a value, or no element if the optional is
	 * empty.
	 * 
	 * @param self
	 *            the optional providing the value for the Stream provided
	 * @return Stream providing either zero or one value, depending on parameter
	 *         {@code self}
	 */
	public static @NonNull DoubleStream stream(@NonNull OptionalDouble self) {
		return self.isPresent() ? DoubleStream.of(self.getAsDouble()) : DoubleStream.empty();
	}
	
	/**
	 * Will call {@code action} with the value held by {@code self} if it is not
	 * empty. Otherwise will call {@code emptyAction}.
	 * 
	 * @param self
	 *            optional to be checked for value.
	 * @param action
	 *            to be called with value of {@code opt} if it is not empty.
	 * @param emptyAction
	 *            to be called if {@code opt} is empty.
	 */
	public static void ifPresentOrElse​(OptionalDouble self, DoubleConsumer action,
            Runnable emptyAction) {
		if (self.isPresent()) {
			final double val = self.getAsDouble();
			action.accept(val);
		} else {
			emptyAction.run();
		}
	}
	
	/**
	 * Operator that will be de-sugared to call to
	 * {@code OptionalIntExtensions.or(self,alternative)}.
	 * 
	 * @param self
	 *            optional to be checked if empty. If not, this value will be
	 *            returned from operator.
	 * @param alternativeSupplier
	 *            will be called to get return value if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns value
	 *         supplied by {@code alternativeSupplier}.
	 */
	@Inline(value = "OptionalDoubleExtensions.or($1,$2)", imported = OptionalDoubleExtensions.class)
	public static @NonNull OptionalDouble operator_or(@NonNull OptionalDouble self,
			@NonNull Supplier<@NonNull ? extends OptionalDouble> alternativeSupplier) {
		return or(self, alternativeSupplier);
	}
	
	/**
	 * This method will either return {@code self} if it is not empty, or
	 * otherwise the value supplied by {@code alternative}.
	 * 
	 * @param self
	 *            optional to be checked if empty. If not, this value will be
	 *            returned from operator.
	 * @param alternativeSupplier
	 *            will be called to get return value if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns value
	 *         supplied by {@code alternativeSupplier}.
	 */
	public static @NonNull OptionalDouble or(@NonNull OptionalDouble self,
	@NonNull Supplier<@NonNull ? extends OptionalDouble> alternativeSupplier) {
		return self.isPresent() ? self : alternativeSupplier.get();
	}

}
