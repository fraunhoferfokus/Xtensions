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
import java.util.PrimitiveIterator.OfInt;
import java.util.Set;
import java.util.function.IntConsumer;
import java.util.function.IntFunction;
import java.util.function.IntPredicate;
import java.util.function.IntSupplier;
import java.util.function.IntToDoubleFunction;
import java.util.function.IntToLongFunction;
import java.util.function.IntUnaryOperator;
import java.util.function.Supplier;
import java.util.stream.IntStream;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Pure;

import de.fhg.fokus.xtensions.iteration.IntIterable;
import de.fhg.fokus.xtensions.iteration.LongIterable;
import de.fhg.fokus.xtensions.iteration.internal.PrimitiveIterableUtil;

/**
 * This class contains static functions that ease the work with Java 8
 * {@link OptionalInt}. <br>
 * To make easy use of this functions import this extensions like this in your
 * Xtend source:
 * <pre>
 * {@code import static extension de.fhg.fokus.xtenders.optional.OptionalIntExtensions.*}
 * </pre>
 * 
 * @see OptionalExtensions
 * @see OptionalLongExtensions
 * @see OptionalDoubleExtensions
 * @author Max Bureck
 */
public final class OptionalIntExtensions {
	
	private static int cacheLowBound = -127;
	private static int cacheUpperBound = 128;
	
	private static final class OptionalIntCacheHoder {
		private static OptionalInt[] cache = new OptionalInt[cacheUpperBound - cacheLowBound + 1];
	}
	
	private OptionalIntExtensions() {
	}
	
	/**
	 * This extension method will check if a value is present in {@code self} and if so will call {@code onPresent}
	 * with that value. The returned {@code Else} will allows to perform a block of code if the optional does
	 * not hold a value. Example usage:
	 * <pre>{@code 
	 * val OptionalInt o = OptionalInt.of(42)
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
	public static Else whenPresent(@NonNull OptionalInt self, @NonNull IntConsumer onPresent) {
		if(self.isPresent()) {
			int value = self.getAsInt();
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
	public static void ifNotPresent(@NonNull OptionalInt self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	/**
	 * This method is an alias for {@link OptionalInt#of(int)}.
	 * @param i integer to wrap in an {@code OptionalInt}
	 * @return {@code OptionalInt}, having present value {@code i}.
	 */
	@Pure
	@Inline(value = "OptionalInt.of($1)", imported = OptionalInt.class)
	public static @NonNull OptionalInt some(int i) {
		return OptionalInt.of(i);
	}
	
	/**
	 * This method returns an OptionalInt instance wrapping the given int {@code i}.
	 * The returned value might be cached to achieve object re-use and therefore 
	 * less garbage collection.<br>
	 * This method might be deprecated in future if {@link OptionalInt#of(int)} or a
	 * new factory method adds caching of instances itself.
	 * @param i integer to be wrapped in OptionalInt
	 * @return instance of OptionalInt, wrapping the given integer {@code i}.
	 */
	public static OptionalInt someOf(int i) {
		if(i < cacheLowBound || i > cacheUpperBound) {
			return OptionalInt.of(i);
		} else {
			OptionalInt[] cache = OptionalIntCacheHoder.cache;
			// we do not care for multi-threaded access to the cache.
			// in the worst case we create a cached element multiple times,
			// overwriting the value of a different thread.
			final int cacheIndex = i - cacheLowBound;
			final OptionalInt result = cache[cacheIndex];
			if(result != null) {
				return result;
			} else {
				final OptionalInt cachedResult = OptionalInt.of(i);
				cache[cacheIndex] = cachedResult;
				return cachedResult;
			}
		}
	}

	/**
	 * Alias for {@link OptionalInt#empty()}.
	 * @return an {@code OptionalInt} with no value present.
	 */
	@Pure
	@Inline(value = "OptionalInt.empty()", imported = OptionalInt.class)
	public static @NonNull OptionalInt noInt() {
		return OptionalInt.empty();
	}
	
	/**
	 * This method is a shortcut for the following expression:
	 * <pre>
	 * {@code i == null ? OptionalInt.empty() : OptionalInt.of(i)}
	 * </pre>
	 * @param i an Integer that is checked for {@code null}. If {@code i == null}, then
	 *  returns an empty {@code OptionalInt}. If {@code i != null} returns an {@code OptionalInt}
	 *  holding the integer value.
	 * @return an {@code OptionalInt} holding {@code i}, if {@code i != null}, an empty {@code OptionalInt} otherwise.
	 */
	@Pure 
	@Inline(value = "$1 == null ? OptionalInt.empty() : OptionalInt.of($1)", imported = OptionalInt.class)
	public static @NonNull OptionalInt maybe(@Nullable Integer i) {
		return i == null ? OptionalInt.empty() : OptionalInt.of(i);
	}

	/**
	 * This operator is an alias for:
	 * <pre>
	 * <code>o.{@link OptionalInt#orElse(int) orElse}(alternative)</code>
	 * </pre>
	 * @param o checked for a present value 
	 * @param alternative value to be returned by this extension function, oif {@code o} is empty.
	 * @return either the value present in {@code o}, or {@code alternative} if there is no 
	 *  value present in {@code o}.
	 */
	@Pure
	@Inline(value = "$1.orElse($2)", imported = OptionalInt.class)
	public static int operator_elvis(@NonNull OptionalInt o, int alternative) {
		return o.orElse(alternative);
	}

	/**
	 * Alias for {@link OptionalInt#orElseGet(IntSupplier)}.
	 * 
	 * @param o
	 *            optional to be queried for value
	 * @param getter
	 *            will be called to get return value if parameter {@code o} is empty.
	 * @return if {@code o} has a value present, will return this value.
	 *         Otherwise returns {@code getter} will be called to get return value.
	 */
	@Pure
	@Inline(value = "$1.orElseGet($2)", imported = OptionalInt.class)
	public static int operator_elvis(@NonNull OptionalInt o, IntSupplier getter) {
		return o.orElseGet(getter);
	}

	/**
	 * Returns an {@code Optional<Integer>} holding the value of {@code self}, or returns 
	 * an empty optional, if the given {@code OptionalInt} is empty.
	 * @param self value will be extracted from this {@code OptionalInt}, if value is present
	 *   and wrapped into an {@code Integer} which will be returned in an {@code Optional} from
	 *   this method.
	 * @return {@code Optional<Integer>} holding the value of {@code self} if present, empty 
	 *  {@code Optional} otherwise
	 */
	@Pure
	public static @NonNull Optional<Integer> boxed(@NonNull OptionalInt self) {
		return map(self, Integer::valueOf);
	}

	/**
	 * If the given {@code OptionalInt self} holds a value and the value tests positive with the given
	 * {@code IntPredicate predicate}, returns {@code self}, otherwise returns an empty {@code OptionalInt}.
	 * @param self the optional value that will be filtered using {@code predicate} 
	 * @param predicate the test that will be used to filter {@code self}.
	 * @return filtered {@code OptionalInt}, empty optional if {@code self} is empty or it's content
	 *  tests negative with {@code predicate}. Otherwise returns {@code self}.
	 */
	public static @NonNull OptionalInt filter(@NonNull OptionalInt self, @NonNull IntPredicate predicate) {
		return self.isPresent() && predicate.test(self.getAsInt()) ? self : OptionalInt.empty();
	}

	/**
	 * Returns {@code OptionalLong} that holds the up-casted int value from {@code self}, or
	 * an empty {@code OptionalLong} if {@code self} is empty.
	 * @param self the value to be converted to an {@code OptionalLong}.
	 * @return int value from {@code self} wrapped in {@code OptionalLong} if present,
	 *  an empty {@code OptionalLong} otherwise.
	 */
	@Pure
	public static @NonNull OptionalLong asLong(@NonNull OptionalInt self) {
		return self.isPresent() ? OptionalLong.of(self.getAsInt()) : OptionalLong.empty();
	}

	/**
	 * Returns {@code OptionalDouble} that holds the value from {@code self} casted to {@code double}, or
	 * an empty {@code OptionalDouble} if {@code self} is empty.
	 * @param self the value to be converted to an {@code OptionalDouble}.
	 * @return int value from {@code self} wrapped in {@code OptionalDouble} if present,
	 *  an empty {@code OptionalDouble} otherwise.
	 */
	@Pure
	public static @NonNull OptionalDouble asDouble(@NonNull OptionalInt self) {
		return self.isPresent() ? OptionalDouble.of(self.getAsInt()) : OptionalDouble.empty();
	}

	/**
	 * Maps the value held by {@code self} to an object wrapped in {@code Optional} if present,
	 * returns an empty {@code Optional} otherwise.
	 * @param self the optional, that's value should be mapped if present
	 * @param op mapping function mapping the value held by {@code self} to an object
	 * @param <V> Type the given {@code op} mapping function will map to from {@code int} values.
	 *   The returned optional might hold a value of this type if {@code self} actually holds a value.
	 * @return an empty {@code Optional}, if {@code self} is empty, otherwise an {@code Optional}
	 *  holding the result of {@code op} applied to the value held by {@code self}.
	 */
	public static <V> @NonNull Optional<V> map(@NonNull OptionalInt self, @NonNull IntFunction<V> op) {
		return self.isPresent() ? Optional.ofNullable(op.apply(self.getAsInt())) : Optional.empty();
	}
	
	/**
	 * Maps the value of {@code self} to an {@code int} value wrapped into an {@code OptionalInt}, if {@code self} holds a value.
	 * Returns an empty {@code OptionalInt} otherwise.
	 * @param self optional, that's held value will be mapped with {@code mapFunc}, if present
	 * @param mapFunc mapping function, to be applied to value of {@code self}, if present
	 * @return optional holding the value of {@code self}, mapped to int using {@code mapFunc} if value present. Empty 
	 *  optional otherwise.
	 */
	public static @NonNull OptionalInt mapInt(@NonNull OptionalInt self, @NonNull IntUnaryOperator mapFunc) {
		return self.isPresent() ? OptionalInt.of(mapFunc.applyAsInt(self.getAsInt())) : self;
	}

	/**
	 * Maps the value of {@code self} to an {@code OptionalInt} using {@code mapFunc}, if {@code self} has a present
	 * value. If {@code self} is empty, this method returns an empty {@code OptionalInt}
	 * 
	 * @param self possibly holding value to be mapped with {@code mapFunc}
	 * @param mapFunc mapping function, used on value of {@code self} if a value is present.
	 * @return optional either holding result of {@code mapFunc} applied to value of {@code self} if 
	 *  value is present, otherwise returning empty optional.
	 */
	public static @NonNull OptionalInt flatMapInt(@NonNull OptionalInt self, @NonNull IntFunction<OptionalInt> mapFunc) {
		return self.isPresent() ? mapFunc.apply(self.getAsInt()) : self;
	}

	/**
	 * Maps the value of {@code self} to a {@code long} value wrapped into an {@code OptionalLong}, if {@code self} holds a value.
	 * Returns an empty {@code OptionalInt} otherwise.
	 * @param self optional, that's held value will be mapped with {@code mapFunc}, if present
	 * @param mapFunc mapping function, to be applied to value of {@code self}, if present
	 * @return optional holding the value of {@code self}, mapped to {@code long} using {@code mapFunc} if value present. Empty 
	 *  optional otherwise.
	 */
	public static @NonNull OptionalLong mapLong(@NonNull OptionalInt self, @NonNull IntToLongFunction mapFunc) {
		return self.isPresent() ? OptionalLong.of(mapFunc.applyAsLong(self.getAsInt())) : OptionalLong.empty();
	}

	/**
	 * Maps the value of {@code self} to a {@code double} value wrapped into an {@code OptionalDouble}, if {@code self} holds a value.
	 * Returns an empty {@code OptionalDouble} otherwise.
	 * @param self optional, that's held value will be mapped with {@code mapFunc}, if present
	 * @param mapFunc mapping function, to be applied to value of {@code self}, if present
	 * @return optional holding the value of {@code self}, mapped to {@code long} using {@code mapFunc} if value present. Empty 
	 *  optional otherwise.
	 */
	public static @NonNull OptionalDouble mapDouble(@NonNull OptionalInt self,
			@NonNull IntToDoubleFunction mapFunc) {
		return self.isPresent() ? OptionalDouble.of(mapFunc.applyAsDouble(self.getAsInt())) : OptionalDouble.empty();
	}

	/**
	 * Returns an {@code IntIterable} that either provides the one value present in {@code self},
	 * or an {@code IntIterable} providing no value if {@code self} is empty.
	 * @param self optional that's value (if present) will be provided via the returned iterable.
	 * @return {@code IntIterable} providing one value taken from {@code self} or no value, if {@code self}
	 *   is empty.
	 */
	@Pure
	public static @NonNull IntIterable asIterable(@NonNull OptionalInt self) {
		if(self.isPresent()) {
			int value = self.getAsInt();
			return new ValueIterable(value);
		} else {
			return PrimitiveIterableUtil.EMPTY_INTITERABLE;
		}
	}

	/**
	 * Returns an {@code PrimitiveIterable.OfInt} that either provides the one value present in {@code self},
	 * or an {@code PrimitiveIterable.OfInt} providing no value if {@code self} is empty.
	 * @param self optional that's value (if present) will be provided via the returned iterator.
	 * @return {@code PrimitiveIterable.OfInt} providing one value taken from {@code self} or no value, if {@code self}
	 *   is empty.
	 */
	public static @NonNull OfInt iterator(@NonNull OptionalInt self) {
		if(self.isPresent()) {
			int value = self.getAsInt();
			return new ValueIterator(value);
		} else {
			return PrimitiveIterableUtil.EMPTY_INTITERATOR;
		}
	}
	
	/**
	 * Single value iterator
	 */
	private static class ValueIterator implements java.util.PrimitiveIterator.OfInt {
		final int value;
		boolean done = false;

		public ValueIterator(int value) {
			this.value = value;
		}

		@Override
		public boolean hasNext() {
			return !done;
		}

		@Override
		public int nextInt() {
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
	private static class ValueIterable implements IntIterable {

		final int value;

		public ValueIterable(int value) {
			super();
			this.value = value;
		}

		@Override
		public OfInt iterator() {
			return new ValueIterator(value);
		}

		@Override
		public void forEachInt(IntConsumer consumer) {
			consumer.accept(value);
		}

		@Override
		public IntStream stream() {
			return IntStream.of(value);
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
	public static @NonNull Set<Integer> toSet(@NonNull OptionalInt self) {
		if (self.isPresent()) {
			return Collections.singleton(self.getAsInt());
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
	public static @NonNull IntStream stream(@NonNull OptionalInt self) {
		return self.isPresent() ? IntStream.of(self.getAsInt()) : IntStream.empty();
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
	public static void ifPresentOrElse​(OptionalInt self, IntConsumer action,
            Runnable emptyAction) {
		if (self.isPresent()) {
			final int val = self.getAsInt();
			action.accept(val);
		} else {
			emptyAction.run();
		}
	}
	
	/**
	 * Operator that will be de-sugared to call to
	 * {@code OptionalIntExtensions.or(self,alternativeSupplier)}.
	 * 
	 * @param self
	 *            optional to be checked if empty. If not, this value will be
	 *            returned from operator.
	 * @param alternativeSupplier
	 *            will be called to get return value if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns value
	 *         supplied by {@code alternativeSupplier}.
	 */
	@Inline(value = "OptionalIntExtensions.or($1,$2)", imported = OptionalIntExtensions.class)
	public static @NonNull OptionalInt operator_or(@NonNull OptionalInt self,
			@NonNull Supplier<@NonNull ? extends OptionalInt> alternativeSupplier) {
		return or(self, alternativeSupplier);
	}
	
	/**
	 * This method will either return {@code self} if it is not empty, or
	 * otherwise the value supplied by {@code alternativeSupplier}.
	 * 
	 * @param self
	 *            optional to be checked if empty. If not, this value will be
	 *            returned from operator.
	 * @param alternativeSupplier
	 *            will be called to get return value if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns value
	 *         supplied by {@code alternativeSupplier}.
	 */
	public static @NonNull OptionalInt or(@NonNull OptionalInt self,
	@NonNull Supplier<@NonNull ? extends OptionalInt> alternativeSupplier) {
		return self.isPresent() ? self : alternativeSupplier.get();
	}
	
}
