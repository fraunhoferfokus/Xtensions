package de.fhg.fokus.xtenders.optional;

import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.OptionalDouble;
import java.util.OptionalInt;
import java.util.OptionalLong;
import java.util.Set;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.function.IntConsumer;
import java.util.function.Predicate;
import java.util.function.Supplier;
import java.util.function.ToDoubleFunction;
import java.util.function.ToIntFunction;
import java.util.function.ToLongFunction;
import java.util.stream.Stream;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;

import de.fhg.fokus.xtenders.range.IntIntConsumer;
import de.fhg.fokus.xtenders.range.RangeExtensions;

/**
 * This class contains static functions that ease the work with Java 8
 * {@link Optional}, as well as the primitive versions {@link OptionalInt},
 * {@link OptionalLong}, and {@link OptionalDouble}. <br>
 * To make easy use of this functions import this extensions like this in your
 * Xtend source:
 * {@code import static extension de.fhg.fokus.xtenders.optional.OptionalExtensions.*}
 * 
 * @author Max Bureck
 */
public final class OptionalExtensions {
	
	private OptionalExtensions() {
		throw new IllegalStateException("OptionalExtensions is not allowed to be instantiated");
	}

// TODO onlyIf / onlyIfNullable really needed???

//	/**
//	 * This function is basically a factory function for {@link Optional}, that
//	 * returns an optional containing the given value {@code t}, if the
//	 * predicate {@code test} evaluates to {@code true}. If the predicate is
//	 * evaluated to {@code false}, an empty optional will be returned.
//	 * Semantically this method is equal to {@code some(t).filter(test)}, but
//	 * may produce one object instance less.
//	 * 
//	 * @param t
//	 *            value that will be wrapped into an optional if {@code test}
//	 *            evaluates to {@code true}
//	 * @param test
//	 *            check that decides if value {@code t} will be wrapped into an
//	 *            Optional or not.
//	 * @return optional that contains value {@code t}, if {@code test} evaluates
//	 *         to {@code true}.
//	 */
//	@Pure
//	public static <T> @NonNull Optional<T> onlyIf(@NonNull T t, @NonNull Predicate<T> test) {
//		return test.test(t) ? Optional.of(t) : Optional.empty();
//	}
//
//	@Pure
//	public static <T> @NonNull Optional<T> onlyIfNullable(@Nullable T t, @NonNull Predicate<T> test) {
//		if (t == null) {
//			return Optional.empty();
//		} else {
//			return test.test(t) ? Optional.of(t) : Optional.empty();
//		}
//	}
	

// TODO is zip usefull???
		
//		@Pure
//		public static <T, U> @NonNull Optional<@NonNull Pair<@NonNull T, @NonNull U>> zip(@NonNull Optional<T> self,
//				@NonNull Optional<U> other) {
//			if (self.isPresent() && other.isPresent()) {
//				return Optional.of(Pair.of(self.get(), other.get()));
//			} else {
//				return Optional.empty();
//			}
//		}

	
//	@Inline(value = "$1.isPresent() ? $1.get() : null; if(!$1.isPresent()) return Optional.empty();", imported = Optional.class)
//	public static <T> T getOrReturn(Optional<T> opt) {
//		throw new IllegalStateException("Method can only be used inlined");
//	}

	////////////////////////////
	// Optional<IntegerRange> //
	////////////////////////////

	/**
	 * When parameter {@code self} contains a range, starts an iteration over
	 * all {@code int} values in that range. Every value will be passed to
	 * {@code consumer} one after the other. If the Optional is empty, the
	 * {@code consumer} will not be called.
	 * 
	 * @param self
	 *            Optional that may or may not contain an IntegerRange. If
	 *            Optional is not empty, {@code consumer} will be called with
	 *            each element in range.
	 * @param consumer
	 *            will be called with each element in given range
	 */
	public static void forEachInt(@NonNull Optional<? extends IntegerRange> self, @NonNull IntConsumer consumer) {
		if (self.isPresent()) {
			RangeExtensions.forEachInt(self.get(), consumer);
		}
	}

	/**
	 * When parameter {@code self} contains a range, starts an iteration over
	 * all {@code int} values in that range. Every value, and the number of the
	 * iteration (starting with index {@code 0}) will be passed to
	 * {@code consumer} one after the other. If the Optional is empty, the
	 * {@code consumer} will not be called.
	 * 
	 * @param self
	 *            Optional that may or may not contain an IntegerRange. If
	 *            Optional is not empty, {@code consumer} will be called with
	 *            each element in range.
	 * @param consumer
	 *            will be called with each element and the number of iteration
	 *            (starting with {@code 0}) in given range
	 */
	public static void forEachInt(@NonNull Optional<? extends IntegerRange> self, @NonNull IntIntConsumer consumer) {
		if (self.isPresent()) {

			RangeExtensions.forEachInt(self.get(), consumer);
		}
	}

	////////////////////////
	// Optional<Iterable> //
	////////////////////////

	/**
	 * If the given optional contains an element, the element will be returned,
	 * otherwise an empty iterable is returned.
	 * 
	 * @param optIter
	 *            optional that may hold an Iterable.
	 * @return either the iterable held in the optional, or an empty iterable
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" }) // we know the default
													// provider is safe
	@Inline(value = "$1.orElseGet((Supplier)Collections::emptyList)", imported = { Supplier.class, Collections.class })
	public static <T> Iterable<T> orElseEmpty(@NonNull Optional<? extends Iterable<T>> optIter) {
		return optIter.orElseGet((Supplier) Collections::emptyList);
	}

	//////////////
	// Optional //
	//////////////

	// TODO exists(Predicate<T>) as shortcut for
	// filter(Predicate<T>).isPresent() ?

	@Inline(value = "$1.orElse(Optional.empty())", imported = Optional.class)
	@Pure
	public static <T> @NonNull Optional<T> flatten(@NonNull Optional<Optional<T>> self) {
		// TODO check if self.isPresent() ? self.get() : Optional.empty() is
		// faster
		return self.orElse(Optional.empty());
	}

	@Pure
	@SuppressWarnings("unchecked")
	public static <T> @NonNull Optional<T> or(@NonNull Optional<T> self,
			@NonNull Optional<? extends T> alternative) {
		return self.isPresent() ? self : (Optional<T>) alternative;
	}

	@Pure
	@Inline(value = "OptionalExtensions.or($1,$2)", imported = OptionalExtensions.class)
	public static <T> @NonNull Optional<T> operator_or(@NonNull Optional<T> self,
			@NonNull Optional<? extends T> alternative) {
		return or(self, alternative);
	}

	@Inline(value = "OptionalExtensions.or($1,$2)", imported = OptionalExtensions.class)
	public static <T> @NonNull Optional<T> operator_or(@NonNull Optional<T> self,
			@NonNull Supplier<@NonNull ? extends Optional<? extends T>> alternativeSupplier) {
		return or(self, alternativeSupplier);
	}

	@Pure
	@SuppressWarnings("unchecked") // we know cast is safe, because value
									// can
									// only be taken from Optional
	public static <T extends U, U> @NonNull Optional<U> orSuper(@NonNull Optional<T> self,
			@NonNull Optional<U> alternative) {
		return self.isPresent() ? (Optional<U>) self : alternative;
	}

	@SuppressWarnings("unchecked") // we know cast is safe, because value
									// can
									// only be taken from Optional
	public static <T extends U, U> @NonNull Optional<U> orSuper(@NonNull Optional<T> self,
			@NonNull Supplier<@NonNull Optional<U>> alternativeSupplier) {
		return self.isPresent() ? (Optional<U>) self : alternativeSupplier.get();
	}

	@Pure
	@SuppressWarnings("unchecked") // we checked instance, so cast is safe.
	public static <T, U> @NonNull Optional<U> filter(@NonNull Optional<T> self, @NonNull Class<U> clazz) {
		return (@NonNull Optional<U>) self.filter(t -> clazz.isInstance(t));
	}


	@FunctionalInterface
	public interface PresenceCheck<T> extends Procedure1<@NonNull Optional<T>>, Consumer<@NonNull T> {

		/**
		 * User method, will be called if Optional contains a value.
		 */
		@Override
		void accept(T t);

		@Override
		default void apply(Optional<T> p) {
			p.ifPresent(this);
		}

		@Pure
		default @NonNull Procedure1<@NonNull Optional<T>> elseDo(@NonNull Procedure0 or) {
			return o -> {
				if (o.isPresent()) {
					accept(o.get());
				} else {
					or.apply();
				}
			};
		}

	}

	// due to problems with the Xtend compiler we cannot use PresenceCheck as
	// parameter
	// type and have to accept Consumer instead
	@Pure
	public static <T> @NonNull PresenceCheck<T> ifPresent(@NonNull Consumer<@NonNull T> either) {
		return either::accept;
	}

	public static <T> void notPresent(@NonNull Optional<T> self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	@Pure
	public static <T> @NonNull Procedure1<@NonNull Optional<T>> notPresent(@NonNull Procedure0 then) {
		return o -> notPresent(o, then);
	}

	public static <T> void allPresent(@NonNull List<@NonNull Optional<T>> opts,
			@NonNull Consumer<@NonNull List<@NonNull T>> consumer) {
		if (opts.stream().allMatch(Optional::isPresent)) {
			consumer.accept(Lists.transform(opts, o -> o.get()));
		}
	}

	public static <T, U> void ifBothPresent(@NonNull Optional<T> a, @NonNull Optional<U> b, BiConsumer<T, U> consumer) {
		if (a.isPresent() && b.isPresent()) {
			consumer.accept(a.get(), b.get());
		}
	}

	@Pure
	@Inline(value = "Optional.ofNullable($1)", imported = Optional.class)
	public static <T> @NonNull Optional<T> maybe(@Nullable T t) {
		return Optional.ofNullable((T) t);
	}

	@Pure
	@Inline(value = "Optional.of($1)", imported = Optional.class)
	public static <T> @NonNull Optional<T> some(@NonNull T t) throws NullPointerException {
		return Optional.of(t);
	}

	@Pure
	@Inline(value = "Optional.empty()", imported = Optional.class)
	public static <T> @NonNull Optional<T> none() {
		return Optional.empty();
	}

	@Pure
	@Inline(value = "$1.orElse($2)", imported = Optional.class)
	public static <T> T operator_elvis(@NonNull Optional<T> o, T alternative) {
		return o.orElse(alternative);
	}

	@Pure
	@Inline(value = "$1.orElseGet($2)", imported = Optional.class)
	public static <T> T operator_elvis(@NonNull Optional<T> o, Supplier<T> getter) {
		return o.orElseGet(getter);
	}

	public static <T> @NonNull OptionalInt mapInt(@NonNull Optional<T> self, @NonNull ToIntFunction<T> mapFunc) {
		return self.isPresent() ? OptionalInt.of(mapFunc.applyAsInt(self.get())) : OptionalInt.empty();
	}

	public static <T> @NonNull OptionalLong mapLong(@NonNull Optional<T> self, @NonNull ToLongFunction<T> mapFunc) {
		return self.isPresent() ? OptionalLong.of(mapFunc.applyAsLong(self.get())) : OptionalLong.empty();
	}

	public static <T> @NonNull OptionalDouble mapDouble(@NonNull Optional<T> self,
			@NonNull ToDoubleFunction<T> mapFunc) {
		return self.isPresent() ? OptionalDouble.of(mapFunc.applyAsDouble(self.get())) : OptionalDouble.empty();
	}

// TODO does this make sense?
//	public static <T, A, R> R collect(@NonNull Optional<T> self, @NonNull Collector<? super T, A, R> collector) {
//		A a = collector.supplier().get();
//		if (self.isPresent()) {
//			collector.accumulator().accept(a, self.get());
//		}
//		// if
//		// collector.characteristics().contains(Characteristics.IDENTITY_FINISH))
//		// == true finisher does not
//		// have to be called. But this will probably take the same time as
//		// calling the finisher every time.
//		return collector.finisher().apply(a);
//	}

	@Pure
	public static <T> @NonNull Iterable<T> asIterable(@NonNull Optional<T> self) {
		return () -> iterator(self);
	}

	public static <T> @NonNull Iterator<T> iterator(@NonNull Optional<T> self) {
		class OptionalIterator implements Iterator<T> {
			boolean done = !self.isPresent();

			@Override
			public boolean hasNext() {
				return !done;
			}

			@Override
			public T next() {
				if (done) {
					throw new NoSuchElementException("Last value already read");
				}
				done = true;
				return self.get();
			}

		}
		return new OptionalIterator();
	}

	/**
	 * Returns an immutable set that either contains the value, held by the
	 * optional, or an empty immutable set, if the optional is empty.
	 * 
	 * @param self
	 *            Optional value is read from
	 * @return Set containing the value held by the input optional, or an empty
	 *         set if the input optional is empty.
	 */
	@Pure
	public static <T> @NonNull Set<T> toSet(@NonNull Optional<T> self) {
		if (self.isPresent()) {
			return Collections.singleton(self.get());
		} else {
			return Collections.emptySet();
		}
	}
	
	/**
	 * Returns an immutable list that either contains the value, held by the
	 * optional, or an empty immutable list, if the optional is empty.
	 * 
	 * @param self
	 *            Optional value is read from
	 * @return Set containing the value held by the input optional, or an empty
	 *         set if the input optional is empty.
	 */
	@Pure
	public static <T> @NonNull List<T> toList(@NonNull Optional<T> self) {
		if (self.isPresent()) {
			@NonNull T element = self.get();
			return ImmutableList.of(element);
		} else {
			return Collections.emptyList();
		}
	}
	
	@Pure
	public static @NonNull OptionalLong unboxLong(@NonNull Optional<Long> self) {
		return mapLong(self, Long::longValue);
	}
	
	@Pure
	public static @NonNull OptionalInt unboxInt(@NonNull Optional<Integer> self) {
		return OptionalExtensions.mapInt(self, Integer::intValue);
	}

	@Pure
	public static @NonNull OptionalDouble unboxDouble(@NonNull Optional<Double> self) {
		return mapDouble(self, Double::doubleValue);
	}

	// TODO java 9 forward compatibility
	
	//////////////////////////////////
	// Java 9 forward compatibility //
	//////////////////////////////////
	
	public static <T> void ifPresentOrElse(@NonNull Optional<T> opt, Consumer<? super T> action, Runnable emptyAction) {
		if(opt.isPresent()) {
			@NonNull T val = opt.get();
			action.accept(val);
		} else {
			emptyAction.run();
		}
	}

	@SuppressWarnings("unchecked")
	public static <T> @NonNull Optional<T> or(@NonNull Optional<T> self,
			@NonNull Supplier<@NonNull ? extends Optional<? extends T>> alternativeSupplier) {
		return self.isPresent() ? self : (Optional<T>) alternativeSupplier.get();
	}

	/**
	 * This extension function returns a Stream of a single element if the given
	 * Optional {@code self} contains a value, or no element if the Optional is
	 * empty.<br>
	 * This is a forward compatibility extension method for the Java 9 feature
	 * on Optional.
	 * 
	 * @param self
	 *            the Optional providing the value for the Stream provided
	 * @return Stream providing either zero or one value, depending on parameter
	 *         {@code self}
	 */
	@Pure
	public static <T> Stream<T> stream​(@NonNull Optional<T> self) {
		return self.map(Stream::of).orElseGet(Stream::empty);
	}

}
