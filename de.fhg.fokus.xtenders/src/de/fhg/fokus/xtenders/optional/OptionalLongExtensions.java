package de.fhg.fokus.xtenders.optional;

import java.util.Collections;
import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.OptionalDouble;
import java.util.OptionalInt;
import java.util.OptionalLong;
import java.util.PrimitiveIterator;
import java.util.Set;
import java.util.PrimitiveIterator.OfLong;
import java.util.function.LongConsumer;
import java.util.function.LongFunction;
import java.util.function.LongPredicate;
import java.util.function.LongSupplier;
import java.util.function.LongToDoubleFunction;
import java.util.function.LongToIntFunction;
import java.util.function.LongUnaryOperator;
import java.util.stream.Collector;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Pure;

import de.fhg.fokus.xtenders.iterator.LongIterable;

import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

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

	public static <T> void longNotPresent(@NonNull OptionalLong self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	public static <T> @NonNull Procedure1<@NonNull OptionalLong> longNotPresent(@NonNull Procedure0 then) {
		return o -> longNotPresent(o, then);
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
	public static <T> @NonNull LongIterable toIterable(@NonNull OptionalLong self) {
		return () -> iterator(self);
	}

	public static <T> @NonNull OfLong iterator(@NonNull OptionalLong self) {
		class OptionalLongIterator implements PrimitiveIterator.OfLong {
			boolean done = !self.isPresent();

			@Override
			public boolean hasNext() {
				return !done && self.isPresent();
			}

			@Override
			public long nextLong() {
				if (done) {
					throw new NoSuchElementException("Last value already read");
				}
				done = true;
				return self.getAsLong();
			}

		}
		return new OptionalLongIterator();
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

	public static <T, A, R> R collect(@NonNull OptionalLong self, @NonNull Collector<? super Long, A, R> collector) {
		A a = collector.supplier().get();
		if (self.isPresent()) {
			collector.accumulator().accept(a, self.getAsLong());
		}
		// if
		// collector.characteristics().contains(Characteristics.IDENTITY_FINISH))
		// == true finisher does not
		// have to be called. But this will probably take the same time as
		// calling the finisher every time.
		return collector.finisher().apply(a);
	}
}
