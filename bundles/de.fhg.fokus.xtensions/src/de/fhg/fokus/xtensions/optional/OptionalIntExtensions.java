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
import java.util.stream.IntStream;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

import de.fhg.fokus.xtensions.iterator.IntIterable;
import de.fhg.fokus.xtensions.iterator.LongIterable;
import de.fhg.fokus.xtensions.iterator.internal.PrimitiveIterableUtil;

import org.eclipse.xtext.xbase.lib.Pure;


public class OptionalIntExtensions {
	
	private OptionalIntExtensions() {
	}

	@FunctionalInterface
	public interface IntPresenceCheck extends IntConsumer, Procedure1<@NonNull OptionalInt> {

		/**
		 * User method, will be called if Optional contains a value.
		 */
		@Override
		void accept(int value);

		/**
		 * Checks if {@code p} holds a value and if so, calls {@link #accept(int)}
		 * with value from the given optional {@code p}.
		 */
		@Override
		default void apply(@NonNull OptionalInt p) {
			p.ifPresent(this);
		}

		@Pure
		default Procedure1<@NonNull OptionalInt> elseDo(@NonNull Procedure0 or) {
			return o -> {
				if (o.isPresent()) {
					accept(o.getAsInt());
				} else {
					or.apply();
				}
			};
		}

	}

	@Pure
	public static <T> @NonNull IntPresenceCheck intPresent(@NonNull IntConsumer either) {
		return either::accept;
	}

	public static <T> void ifNotPresent(@NonNull OptionalInt self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	public static <T> @NonNull Procedure1<@NonNull OptionalInt> intNotPresent(@NonNull Procedure0 then) {
		return o -> ifNotPresent(o, then);
	}

	@Pure
	@Inline(value = "OptionalInt.of($1)", imported = OptionalInt.class)
	public static <T> @NonNull OptionalInt some(int i) {
		return OptionalInt.of(i);
	}

	@Pure
	@Inline(value = "OptionalInt.empty()", imported = OptionalInt.class)
	public static <T> @NonNull OptionalInt noInt() {
		return OptionalInt.empty();
	}

	@Pure
	@Inline(value = "$1.orElse($2)", imported = OptionalInt.class)
	public static <T> int operator_elvis(@NonNull OptionalInt o, int alternative) {
		return o.orElse(alternative);
	}

	@Pure
	@Inline(value = "$1.orElseGet($2)", imported = OptionalInt.class)
	public static <T> int operator_elvis(@NonNull OptionalInt o, IntSupplier getter) {
		return o.orElseGet(getter);
	}

	@Pure
	public static @NonNull Optional<Integer> boxed(@NonNull OptionalInt self) {
		return map(self, Integer::valueOf);
	}

	public static @NonNull OptionalInt filter(@NonNull OptionalInt self, @NonNull IntPredicate predicate) {
		return self.isPresent() && predicate.test(self.getAsInt()) ? self : OptionalInt.empty();
	}

	@Pure
	public static @NonNull OptionalLong asLong(@NonNull OptionalInt self) {
		return self.isPresent() ? OptionalLong.of(self.getAsInt()) : OptionalLong.empty();
	}

	@Pure
	public static @NonNull OptionalDouble asDouble(@NonNull OptionalInt self) {
		return self.isPresent() ? OptionalDouble.of(self.getAsInt()) : OptionalDouble.empty();
	}

	public static <V> @NonNull Optional<V> map(@NonNull OptionalInt self, @NonNull IntFunction<V> op) {
		return self.isPresent() ? Optional.ofNullable(op.apply(self.getAsInt())) : Optional.empty();
	}
	
	public static <T> @NonNull OptionalInt mapInt(@NonNull OptionalInt self, @NonNull IntUnaryOperator op) {
		return self.isPresent() ? OptionalInt.of(op.applyAsInt(self.getAsInt())) : self;
	}

	public static <T> @NonNull OptionalInt flatMapInt(@NonNull OptionalInt self, @NonNull IntFunction<OptionalInt> mapper) {
		return self.isPresent() ? mapper.apply(self.getAsInt()) : self;
	}

	public static <T> @NonNull OptionalLong mapLong(@NonNull OptionalInt self, @NonNull IntToLongFunction mapFunc) {
		return self.isPresent() ? OptionalLong.of(mapFunc.applyAsLong(self.getAsInt())) : OptionalLong.empty();
	}

	public static <T> @NonNull OptionalDouble mapDouble(@NonNull OptionalInt self,
			@NonNull IntToDoubleFunction mapFunc) {
		return self.isPresent() ? OptionalDouble.of(mapFunc.applyAsDouble(self.getAsInt())) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull IntIterable asIterable(@NonNull OptionalInt self) {
		if(self.isPresent()) {
			int value = self.getAsInt();
			return new ValueIterable(value);
		} else {
			return PrimitiveIterableUtil.EMPTY_INTITERABLE;
		}
	}

	public static <T> @NonNull OfInt iterator(@NonNull OptionalInt self) {
		if(self.isPresent()) {
			int value = self.getAsInt();
			return new ValueIterator(value);
		} else {
			return PrimitiveIterableUtil.EMPTY_INTITERATOR;
		}
	}
	
	// TODO DoubleIterable asIterable(@NonNull OptionalDouble self){}
	// TODO LongIterable asIterable(@NonNull OptionalLong self){}
	
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

}
