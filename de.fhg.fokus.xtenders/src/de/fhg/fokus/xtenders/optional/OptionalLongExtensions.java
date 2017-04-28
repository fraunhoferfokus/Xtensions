package de.fhg.fokus.xtenders.optional;

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
import java.util.stream.LongStream;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;

import de.fhg.fokus.xtenders.iterator.LongIterable;

public class OptionalLongExtensions {

	private OptionalLongExtensions() {
	}

	@FunctionalInterface
	public interface LongPresenceCheck extends LongConsumer, Procedure1<@NonNull OptionalLong> {

		/**
		 * User method, will be called if Optional contains a value.
		 */
		@Override
		void accept(long value);

		@Override
		default void apply(@NonNull OptionalLong p) {
			p.ifPresent(this);
		}

		@Pure
		default Procedure1<@NonNull OptionalLong> elseDo(@NonNull Procedure0 or) {
			return o -> {
				if (o.isPresent()) {
					accept(o.getAsLong());
				} else {
					or.apply();
				}
			};
		}

	}

	@Pure
	public static <T> @NonNull LongPresenceCheck longPresent(@NonNull LongConsumer either) {
		return either::accept;
	}

	public static <T> void ifNotPresent(@NonNull OptionalLong self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	public static <T> @NonNull Procedure1<@NonNull OptionalLong> ifNotPresent(@NonNull Procedure0 then) {
		return o -> ifNotPresent(o, then);
	}

	@Inline(value = "$1.orElse($2)", imported = OptionalLong.class)
	public static <T> long operator_elvis(@NonNull OptionalLong o, long alternative) {
		return o.orElse(alternative);
	}

	@Inline(value = "$1.orElseGet($2)", imported = OptionalLong.class)
	public static <T> long operator_elvis(@NonNull OptionalLong o, LongSupplier getter) {
		return o.orElseGet(getter);
	}

	@Inline(value = "OptionalLong.of($1)", imported = OptionalLong.class)
	public static <T> @NonNull OptionalLong some(long l) {
		return OptionalLong.of(l);
	}

	@Inline(value = "OptionalLong.empty()", imported = OptionalLong.class)
	public static <T> @NonNull OptionalLong noLong() {
		return OptionalLong.empty();
	}

	@Pure
	public static @NonNull Optional<Long> boxed(@NonNull OptionalLong self) {
		return map(self, Long::valueOf);
	}

	public static @NonNull OptionalLong filter(@NonNull OptionalLong self, @NonNull LongPredicate predicate) {
		return self.isPresent() && predicate.test(self.getAsLong()) ? self : OptionalLong.empty();
	}

	public static @NonNull OptionalDouble asDouble(@NonNull OptionalLong self) {
		return self.isPresent() ? OptionalDouble.of(self.getAsLong()) : OptionalDouble.empty();
	}

	public static <V> @NonNull Optional<V> map(@NonNull OptionalLong self, @NonNull LongFunction<V> mapFunc) {
		return self.isPresent() ? Optional.ofNullable(mapFunc.apply(self.getAsLong())) : Optional.empty();
	}

	public static <T> @NonNull OptionalInt mapInt(@NonNull OptionalLong self, @NonNull LongToIntFunction mapFunc) {
		return self.isPresent() ? OptionalInt.of(mapFunc.applyAsInt(self.getAsLong())) : OptionalInt.empty();
	}

	public static <T> @NonNull OptionalLong mapLong(@NonNull OptionalLong self, @NonNull LongUnaryOperator op) {
		return self.isPresent() ? OptionalLong.of(op.applyAsLong(self.getAsLong())) : OptionalLong.empty();
	}

	public static <T> @NonNull OptionalDouble mapDouble(@NonNull OptionalLong self,
			@NonNull LongToDoubleFunction mapFunc) {
		return self.isPresent() ? OptionalDouble.of(mapFunc.applyAsDouble(self.getAsLong())) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull LongIterable asIterable(@NonNull OptionalLong self) {
		if (self.isPresent()) {
			long value = self.getAsLong();
			return new ValueIterable(value);
		} else {
			return EMPTY_ITERABLE;
		}
	}

	private static class ValueIterator implements OfLong {
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

	private static OfLong EMPTY_ITERATOR = new OfLong() {

		@Override
		public boolean hasNext() {
			return false;
		}

		@Override
		public long nextLong() {
			throw new NoSuchElementException();
		}
		
		public void forEachRemaining(LongConsumer action) {};
	};

	private static LongIterable EMPTY_ITERABLE = new LongIterable() {

		@Override
		public OfLong iterator() {
			return EMPTY_ITERATOR;
		}

		@Override
		public void forEachLong(LongConsumer consumer) {
		};

		@Override
		public void forEach(java.util.function.Consumer<? super Long> action) {
		};

		@Override
		public LongStream stream() {
			return LongStream.empty();
		};
	};

	public static <T> @NonNull OfLong iterator(@NonNull OptionalLong self) {
		if (self.isPresent()) {
			long value = self.getAsLong();
			return new ValueIterator(value);
		} else {
			return EMPTY_ITERATOR;
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
}
