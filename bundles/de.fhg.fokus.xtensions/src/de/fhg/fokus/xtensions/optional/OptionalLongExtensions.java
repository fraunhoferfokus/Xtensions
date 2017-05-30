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
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;

import de.fhg.fokus.xtensions.iteration.LongIterable;
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
public class OptionalLongExtensions {

	private OptionalLongExtensions() {
	}

//	@FunctionalInterface
//	public interface LongPresenceCheck extends LongConsumer, Procedure1<@NonNull OptionalLong> {
//
//		/**
//		 * User method, will be called if Optional contains a value.
//		 */
//		@Override
//		void accept(long value);
//
//		@Override
//		default void apply(@NonNull OptionalLong p) {
//			p.ifPresent(this);
//		}
//
//		@Pure
//		default Procedure1<@NonNull OptionalLong> elseDo(@NonNull Procedure0 or) {
//			return o -> {
//				if (o.isPresent()) {
//					accept(o.getAsLong());
//				} else {
//					or.apply();
//				}
//			};
//		}
//
//	}
//
//	@Pure
//	public static <T> @NonNull LongPresenceCheck longPresent(@NonNull LongConsumer either) {
//		return either::accept;
//	}
	
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
	public static <T> Else whenPresent(@NonNull OptionalLong self, @NonNull LongConsumer onPresent) {
		if(self.isPresent()) {
			long value = self.getAsLong();
			onPresent.accept(value);
			return Else.PRESENT;
		} else {
			return Else.NOT_PRESENT;
		}
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
	
	public static <T> @NonNull OptionalLong flatMapLong(@NonNull OptionalLong self, @NonNull LongFunction<OptionalLong> mapper) {
		return self.isPresent() ? mapper.apply(self.getAsLong()) : self;
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
			return PrimitiveIterableUtil.EMPTY_LONGITERABLE;
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

	


	public static <T> @NonNull OfLong iterator(@NonNull OptionalLong self) {
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
	 * @param opt
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
	 * @param alternative
	 *            will be called to get return value if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns value
	 *         supplied by {@code alternative}.
	 */
	@Inline(value = "OptionalLongExtensions.or($1,$2)", imported = OptionalLongExtensions.class)
	public static @NonNull OptionalLong operator_or(@NonNull OptionalLong self,
			@NonNull Supplier<@NonNull ? extends OptionalLong> alternativeSupplier) {
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
	public static @NonNull OptionalLong or(@NonNull OptionalLong self,
	@NonNull Supplier<@NonNull ? extends OptionalLong> alternativeSupplier) {
		return self.isPresent() ? self : alternativeSupplier.get();
	}
}
