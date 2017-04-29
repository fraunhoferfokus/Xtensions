package de.fhg.fokus.xtenders.optional;

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
import java.util.function.LongFunction;
import java.util.stream.DoubleStream;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;

import de.fhg.fokus.xtenders.iterator.DoubleIterable;
import de.fhg.fokus.xtenders.iterator.LongIterable;

public class OptionalDoubleExtensions {

	private OptionalDoubleExtensions() {
	}

	@FunctionalInterface
	public interface DoublePresenceCheck extends DoubleConsumer, Procedure1<@NonNull OptionalDouble> {

		/**
		 * User method, will be called if Optional contains a value.
		 */
		@Override
		void accept(double value);

		@Override
		default void apply(@NonNull OptionalDouble p) {
			p.ifPresent(this);
		}

		@Pure
		default Procedure1<@NonNull OptionalDouble> elseDo(@NonNull Procedure0 or) {
			return o -> {
				if (o.isPresent()) {
					accept(o.getAsDouble());
				} else {
					or.apply();
				}
			};
		}

	}

	@Pure
	public static <T> @NonNull DoublePresenceCheck ifPresent(@NonNull DoubleConsumer either) {
		return either::accept;
	}

	public static <T> void ifNotPresent(@NonNull OptionalDouble self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	@Pure
	public static <T> @NonNull Procedure1<@NonNull OptionalDouble> ifNotPresent(@NonNull Procedure0 then) {
		return o -> ifNotPresent(o, then);
	}

	@Pure
	@Inline(value = "$1.orElse($2)", imported = OptionalDouble.class)
	public static <T> double operator_elvis(@NonNull OptionalDouble o, double alternative) {
		return o.orElse(alternative);
	}

	@Pure
	@Inline(value = "$1.orElseGet($2)", imported = OptionalDouble.class)
	public static <T> double operator_elvis(@NonNull OptionalDouble o, DoubleSupplier getter) {
		return o.orElseGet(getter);
	}

	@Pure
	@Inline(value = "OptionalDouble.of($1)", imported = OptionalDouble.class)
	public static <T> @NonNull OptionalDouble some(double d) {
		return OptionalDouble.of(d);
	}

	@Pure
	@Inline(value = "OptionalDouble.empty()", imported = OptionalDouble.class)
	public static <T> @NonNull OptionalDouble noDouble() {
		return OptionalDouble.empty();
	}

	@Pure
	public static @NonNull Optional<Double> boxed(@NonNull OptionalDouble self) {
		return map(self, Double::valueOf);
	}

	public static @NonNull OptionalDouble filter(@NonNull OptionalDouble self, @NonNull DoublePredicate predicate) {
		return self.isPresent() && predicate.test(self.getAsDouble()) ? self : OptionalDouble.empty();
	}

	public static <V> @NonNull Optional<V> map(@NonNull OptionalDouble self, @NonNull DoubleFunction<V> mapFunc) {
		return self.isPresent() ? Optional.ofNullable(mapFunc.apply(self.getAsDouble())) : Optional.empty();
	}

	public static <T> @NonNull OptionalInt mapInt(@NonNull OptionalDouble self, @NonNull DoubleToIntFunction mapFunc) {
		return self.isPresent() ? OptionalInt.of(mapFunc.applyAsInt(self.getAsDouble())) : OptionalInt.empty();
	}

	public static <T> @NonNull OptionalLong mapLong(@NonNull OptionalDouble self,
			@NonNull DoubleToLongFunction mapFunc) {
		return self.isPresent() ? OptionalLong.of(mapFunc.applyAsLong(self.getAsDouble())) : OptionalLong.empty();
	}

	public static <T> @NonNull OptionalDouble mapDouble(@NonNull OptionalDouble self, @NonNull DoubleUnaryOperator op) {
		return self.isPresent() ? OptionalDouble.of(op.applyAsDouble(self.getAsDouble())) : OptionalDouble.empty();
	}
	
	public static <T> @NonNull OptionalDouble flatMapDouble(@NonNull OptionalDouble self, @NonNull DoubleFunction<OptionalDouble> mapper) {
		return self.isPresent() ? mapper.apply(self.getAsDouble()) : self;
	}

	public static <T> @NonNull DoubleIterable asIterable(@NonNull OptionalDouble self) {
		if (self.isPresent()) {
			double value = self.getAsDouble();
			return new ValueIterable(value);
		} else {
			return EMPTY_ITERABLE;
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

	private static OfDouble EMPTY_ITERATOR = new OfDouble() {

		@Override
		public boolean hasNext() {
			return false;
		}

		@Override
		public double nextDouble() {
			throw new NoSuchElementException();
		}
		
		@Override
		public void forEachRemaining(DoubleConsumer action) {};
	};

	private static DoubleIterable EMPTY_ITERABLE = new DoubleIterable() {

		@Override
		public OfDouble iterator() {
			return EMPTY_ITERATOR;
		}

		@Override
		public void forEachDouble(DoubleConsumer consumer) {
		};

		@Override
		public void forEach(java.util.function.Consumer<? super Double> action) {
		};

		@Override
		public DoubleStream stream() {
			return DoubleStream.empty();
		};
	};

	public static <T> @NonNull OfDouble iterator(@NonNull OptionalDouble self) {
		if (self.isPresent()) {
			double value = self.getAsDouble();
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
	public static @NonNull Set<Double> toSet(@NonNull OptionalDouble self) {
		if (self.isPresent()) {
			return Collections.singleton(self.getAsDouble());
		} else {
			return Collections.emptySet();
		}
	}

}
