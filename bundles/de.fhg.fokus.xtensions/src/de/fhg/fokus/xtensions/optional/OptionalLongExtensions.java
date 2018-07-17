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
import java.util.PrimitiveIterator.OfLong;
import java.util.Set;
import java.util.function.LongConsumer;
import java.util.function.LongFunction;
import java.util.function.LongPredicate;
import java.util.function.LongSupplier;
import java.util.function.LongToDoubleFunction;
import java.util.function.LongToIntFunction;
import java.util.function.LongUnaryOperator;
import java.util.function.Supplier;
import java.util.stream.LongStream;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Pure;

import de.fhg.fokus.xtensions.iteration.LongIterable;
import de.fhg.fokus.xtensions.iteration.internal.LongStreamable;
import de.fhg.fokus.xtensions.iteration.internal.PrimitiveIterableUtil;

/**
 * This class contains static functions that ease the work with Java 8
 * {@link OptionalLong}. <br>
 * To make easy use of this functions import this extensions like this in your
 * Xtend source:
 * <pre>
 * {@code import static extension de.fhg.fokus.xtenders.optional.OptionalLongExtensions.*}
 * </pre>
 * 
 * @see OptionalExtensions
 * @see OptionalIntExtensions
 * @see OptionalDoubleExtensions
 * @author Max Bureck
 */
public final class OptionalLongExtensions {

	private static final int CACHE_LOW_BOUND = -128;
	private static final int CACHE_UPPER_BOUND = 127;
	
	private static final class OptionalLongCacheHoder {
		private static final OptionalLong[] CACHE = new OptionalLong[CACHE_UPPER_BOUND - CACHE_LOW_BOUND + 1];
	}
	
	private OptionalLongExtensions() {
	}
	
	/**
	 * This method is an alias for {@link OptionalLong#of(long)}.
	 * @param l long to wrap in an {@code OptionalLong}
	 * @return {@code OptionalLong}, having present value {@code l}.
	 */
	@Inline(value = "OptionalLong.of($1)", imported = OptionalLong.class)
	public static @NonNull OptionalLong some(long l) {
		return OptionalLong.of(l);
	}
	
	/**
	 * This method returns an OptionalLong instance wrapping the given long {@code l}.
	 * The returned value might be cached to achieve object re-use and therefore 
	 * less garbage collection.<br>
	 * This method might be deprecated in future if {@link OptionalLong#of(long)} or a
	 * new factory method adds caching of instances itself.
	 * @param l long to be wrapped in OptionalLong
	 * @return instance of OptionalLong, wrapping the given long {@code l}.
	 */
	public static OptionalLong someOf(long l) {
		if(l < CACHE_LOW_BOUND || l > CACHE_UPPER_BOUND) {
			return OptionalLong.of(l);
		} else {
			OptionalLong[] cache = OptionalLongCacheHoder.CACHE;
			// we do not care for multi-threaded access to the cache.
			// in the worst case we create a cached element multiple times,
			// overwriting the value of a different thread.
			// We can safely cast to int, since we checked above we are in int value range
			final int cacheIndex = ((int)l) - CACHE_LOW_BOUND;
			final OptionalLong result = cache[cacheIndex];
			if(result != null) {
				return result;
			} else {
				final OptionalLong cachedResult = OptionalLong.of(l);
				cache[cacheIndex] = cachedResult;
				return cachedResult;
			}
		}
	}
	
	/**
	 * This method is a shortcut for the following expression:
	 * <pre>
	 * {@code l == null ? OptionalLong.empty() : OptionalLong.of(i)}
	 * </pre>
	 * @param l a {@code Long} that is checked for {@code null}. If {@code l == null}, then
	 *  returns an empty {@code OptionalLong}. If {@code l != null} returns an {@code OptionalLong}
	 *  holding the long value.
	 * @return an {@code OptionalLong} holding {@code i}, if {@code l != null}, an empty {@code OptionalLong} otherwise.
	 */
	@Pure 
	@Inline(value = "$1 == null ? OptionalLong.empty() : OptionalLong.of($1)", imported = OptionalLong.class)
	public static @NonNull OptionalLong maybe(@Nullable Long l) {
		return l == null ? OptionalLong.empty() : OptionalLong.of(l);
	}

	/**
	 * Alias for {@link OptionalLong#empty()}.
	 * @return an {@code OptionalLong} with no value present.
	 */
	@Inline(value = "OptionalLong.empty()", imported = OptionalLong.class)
	public static @NonNull OptionalLong noLong() {
		return OptionalLong.empty();
	}

	/**
	 * Returns an {@code Optional<Long>} holding the value of {@code self}, or returns 
	 * an empty optional, if the given {@code OptionalLong} is empty.
	 * @param self value will be extracted from this {@code OptionalLong}, if value is present
	 *   and wrapped into an {@code Long} which will be returned in an {@code Optional} from
	 *   this method.
	 * @return {@code Optional<Long>} holding the value of {@code self} if present, empty 
	 *  {@code Optional} otherwise
	 */
	@Pure
	public static @NonNull Optional<Long> boxed(@NonNull OptionalLong self) {
		return map(self, Long::valueOf);
	}
	
	/**
	 * This extension method will check if a value is present in {@code self} and if so will call {@code onPresent}
	 * with that value. The returned {@code Else} will allows to perform a block of code if the optional does
	 * not hold a value. Example usage:
	 * <pre>{@code 
	 * val OptionalLong o = OptionalLong.of(42L)
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
	public static Else whenPresent(@NonNull OptionalLong self, @NonNull LongConsumer onPresent) {
		if(self.isPresent()) {
			long value = self.getAsLong();
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
	public static void ifNotPresent(@NonNull OptionalLong self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	/**
	 * This operator is an alias for:
	 * <pre>
	 * <code>o.{@link OptionalLong#orElse(long) orElse}(alternative)</code>
	 * </pre>
	 * @param o {@code OptionalLong} checked for a present value 
	 * @param alternative value to be returned by this extension function, oif {@code o} is empty.
	 * @return either the value present in {@code o}, or {@code alternative} if there is no 
	 *  value present in {@code o}.
	 */
	@Inline(value = "$1.orElse($2)", imported = OptionalLong.class)
	public static long operator_elvis(@NonNull OptionalLong o, long alternative) {
		return o.orElse(alternative);
	}

	/**
	 * Alias for {@link OptionalLong#orElseGet(LongSupplier)}.
	 * 
	 * @param o
	 *            optional to be queried for value
	 * @param getter
	 *            will be called to get return value if parameter {@code o} is empty.
	 * @return if {@code o} has a value present, will return this value.
	 *         Otherwise returns {@code getter} will be called to get return value.
	 */
	@Inline(value = "$1.orElseGet($2)", imported = OptionalLong.class)
	public static long operator_elvis(@NonNull OptionalLong o, LongSupplier getter) {
		return o.orElseGet(getter);
	}


	/**
	 * If the given {@code OptionalLong self} holds a value and the value tests positive with the given
	 * {@code LongPredicate predicate}, returns {@code self}, otherwise returns an empty {@code OptionalLong}.
	 * @param self the optional value that will be filtered using {@code predicate} 
	 * @param predicate the test that will be used to filter {@code self}.
	 * @return filtered {@code OptionalLong}, empty optional if {@code self} is empty or it's content
	 *  tests negative with {@code predicate}. Otherwise returns {@code self}.
	 */
	public static @NonNull OptionalLong filter(@NonNull OptionalLong self, @NonNull LongPredicate predicate) {
		return self.isPresent() && predicate.test(self.getAsLong()) ? self : OptionalLong.empty();
	}

	/**
	 * Returns {@code OptionalDouble} that holds the value from {@code self} casted to {@code double}, or
	 * an empty {@code OptionalDouble} if {@code self} is empty.
	 * @param self the value to be converted to an {@code OptionalDouble}.
	 * @return int value from {@code self} wrapped in {@code OptionalDouble} if present,
	 *  an empty {@code OptionalDouble} otherwise.
	 */
	public static @NonNull OptionalDouble asDouble(@NonNull OptionalLong self) {
		return self.isPresent() ? OptionalDouble.of(self.getAsLong()) : OptionalDouble.empty();
	}

	/**
	 * Maps the value held by {@code self} to an object wrapped in {@code Optional} if present,
	 * returns an empty {@code Optional} otherwise.
	 * @param self the optional, that's value should be mapped if present
	 * @param mapFunc mapping function mapping the value held by {@code self} to an object
	 * @param <V> Type the given {@code op} mapping function will map to from {@code long} values.
	 *   The returned optional might hold a value of this type if {@code self} actually holds a value.
	 * @return an empty {@code Optional}, if {@code self} is empty, otherwise an {@code Optional}
	 *  holding the result of {@code mapFunc} applied to the value held by {@code self}.
	 */
	public static <V> @NonNull Optional<V> map(@NonNull OptionalLong self, @NonNull LongFunction<V> mapFunc) {
		return self.isPresent() ? Optional.ofNullable(mapFunc.apply(self.getAsLong())) : Optional.empty();
	}

	/**
	 * Maps the value of {@code self} to an {@code int} value wrapped into an {@code OptionalInt}, if {@code self} holds a value.
	 * Returns an empty {@code OptionalInt} otherwise.
	 * @param self optional, that's held value will be mapped with {@code mapFunc}, if present
	 * @param mapFunc mapping function, to be applied to value of {@code self}, if present
	 * @return optional holding the value of {@code self}, mapped to int using {@code mapFunc} if value present. Empty 
	 *  optional otherwise.
	 */
	public static @NonNull OptionalInt mapInt(@NonNull OptionalLong self, @NonNull LongToIntFunction mapFunc) {
		return self.isPresent() ? OptionalInt.of(mapFunc.applyAsInt(self.getAsLong())) : OptionalInt.empty();
	}

	/**
	 * Maps the value of {@code self} to a {@code long} value wrapped into an {@code OptionalLong}, if {@code self} holds a value.
	 * Returns an empty {@code OptionalLong} otherwise.
	 * @param self optional, that's held value will be mapped with {@code mapFunc}, if present
	 * @param mapFunc mapping function, to be applied to value of {@code self}, if present
	 * @return optional holding the value of {@code self}, mapped to {@code long} using {@code mapFunc} if value present. Empty 
	 *  optional otherwise.
	 */
	public static @NonNull OptionalLong mapLong(@NonNull OptionalLong self, @NonNull LongUnaryOperator mapFunc) {
		return self.isPresent() ? OptionalLong.of(mapFunc.applyAsLong(self.getAsLong())) : OptionalLong.empty();
	}
	
	/**
	 * Maps the value of {@code self} to an {@code OptionalLong} using {@code mapFunc}, if {@code self} has a present
	 * value. If {@code self} is empty, this method returns an empty {@code OptionalLong}
	 * 
	 * @param self possibly holding value to be mapped with {@code mapFunc}
	 * @param mapFunc mapping function, used on value of {@code self} if a value is present.
	 * @return optional either holding result of {@code mapFunc} applied to value of {@code self} if 
	 *  value is present, otherwise returning empty optional.
	 */
	public static @NonNull OptionalLong flatMapLong(@NonNull OptionalLong self, @NonNull LongFunction<OptionalLong> mapFunc) {
		return self.isPresent() ? mapFunc.apply(self.getAsLong()) : self;
	}

	/**
	 * Maps the value of {@code self} to a {@code double} value wrapped into an {@code OptionalDouble}, if {@code self} holds a value.
	 * Returns an empty {@code OptionalDouble} otherwise.
	 * @param self optional, that's held value will be mapped with {@code mapFunc}, if present
	 * @param mapFunc mapping function, to be applied to value of {@code self}, if present
	 * @return optional holding the value of {@code self}, mapped to {@code long} using {@code mapFunc} if value present. Empty 
	 *  optional otherwise.
	 */
	public static @NonNull OptionalDouble mapDouble(@NonNull OptionalLong self,
			@NonNull LongToDoubleFunction mapFunc) {
		return self.isPresent() ? OptionalDouble.of(mapFunc.applyAsDouble(self.getAsLong())) : OptionalDouble.empty();
	}

	/**
	 * Returns a {@code LongIterable} that either provides the one value present in {@code self},
	 * or an {@code IntIterable} providing no value if {@code self} is empty.
	 * @param self optional that's value (if present) will be provided via the returned iterable.
	 * @return {@code IntIterable} providing one value taken from {@code self} or no value, if {@code self}
	 *   is empty.
	 */
	@Pure
	public static @NonNull LongIterable asIterable(@NonNull OptionalLong self) {
		if (self.isPresent()) {
			long value = self.getAsLong();
			return new ValueIterable(value);
		} else {
			return PrimitiveIterableUtil.EMPTY_LONGITERABLE;
		}
	}

	private static class ValueIterator implements OfLong, LongStreamable {
		final long value;
		boolean done = false;

		public ValueIterator(long value) {
			this.value = value;
		}

		@Override
		public boolean hasNext() {
			return !done;
		}

		@Override
		public long nextLong() {
			if (done) {
				throw new NoSuchElementException();
			} else {
				done = true;
				return value;
			}
		}

		@Override
		public LongStream streamLongs() {
			if(done) {
				return LongStream.empty();
			} else {
				return LongStream.of(value);
			}
		}
	}

	/**
	 * Implementation of {@link LongIterable} for iterating over a single long
	 * value.
	 */
	private static class ValueIterable implements LongIterable {

		final long value;

		public ValueIterable(long value) {
			super();
			this.value = value;
		}

		@Override
		public OfLong iterator() {
			return new ValueIterator(value);
		}

		@Override
		public void forEachLong(LongConsumer consumer) {
			consumer.accept(value);
		}

		@Override
		public LongStream stream() {
			return LongStream.of(value);
		}
	}

	/**
	 * Returns an {@code PrimitiveIterable.OfLong} that either provides the one value present in {@code self},
	 * or an {@code PrimitiveIterable.OfLong} providing no value if {@code self} is empty.
	 * @param self optional that's value (if present) will be provided via the returned iterator.
	 * @return {@code PrimitiveIterable.OfLong} providing one value taken from {@code self} or no value, if {@code self}
	 *   is empty.
	 */
	public static @NonNull OfLong iterator(@NonNull OptionalLong self) {
		if (self.isPresent()) {
			long value = self.getAsLong();
			return new ValueIterator(value);
		} else {
			return PrimitiveIterableUtil.EMPTY_LONGITERATOR;
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
	public static @NonNull Set<Long> toSet(@NonNull OptionalLong self) {
		if (self.isPresent()) {
			return Collections.singleton(self.getAsLong());
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
	public static @NonNull LongStream stream(@NonNull OptionalLong self) {
		return self.isPresent() ? LongStream.of(self.getAsLong()) : LongStream.empty();
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
	public static void ifPresentOrElse​(OptionalLong self, LongConsumer action,
            Runnable emptyAction) {
		if (self.isPresent()) {
			final long val = self.getAsLong();
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
	@Inline(value = "OptionalLongExtensions.or($1,$2)", imported = OptionalLongExtensions.class)
	public static @NonNull OptionalLong operator_or(@NonNull OptionalLong self,
			@NonNull Supplier<@NonNull ? extends OptionalLong> alternativeSupplier) {
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
	public static @NonNull OptionalLong or(@NonNull OptionalLong self,
	@NonNull Supplier<@NonNull ? extends OptionalLong> alternativeSupplier) {
		return self.isPresent() ? self : alternativeSupplier.get();
	}
}
