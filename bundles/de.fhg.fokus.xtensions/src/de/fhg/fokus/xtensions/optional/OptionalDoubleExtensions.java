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
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
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
public class OptionalDoubleExtensions {

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
	public static <T> Else whenPresent(@NonNull OptionalDouble self, @NonNull DoubleConsumer onPresent) {
		if(self.isPresent()) {
			double value = self.getAsDouble();
			onPresent.accept(value);
			return Else.PRESENT;
		} else {
			return Else.NOT_PRESENT;
		}
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

	public static <T> @NonNull OfDouble iterator(@NonNull OptionalDouble self) {
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
	 * @param opt
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
	 * @param alternative
	 *            will be called to get return value if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns value
	 *         supplied by {@code alternative}.
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
	 * @param alternative
	 *            will be called to get return value if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns value
	 *         supplied by {@code alternative}.
	 */
	public static @NonNull OptionalDouble or(@NonNull OptionalDouble self,
	@NonNull Supplier<@NonNull ? extends OptionalDouble> alternativeSupplier) {
		return self.isPresent() ? self : alternativeSupplier.get();
	}

}
