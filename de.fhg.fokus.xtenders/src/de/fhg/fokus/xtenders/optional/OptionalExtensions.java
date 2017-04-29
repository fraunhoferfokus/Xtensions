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
import java.util.Spliterator;
import java.util.Spliterators;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.function.IntConsumer;
import java.util.function.Supplier;
import java.util.function.ToDoubleFunction;
import java.util.function.ToIntFunction;
import java.util.function.ToLongFunction;
import java.util.stream.Stream;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;

import de.fhg.fokus.xtenders.function.AdditionalFunctionExtensions;
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

	// TODO is any of the following functionality actually usefull???

	// /**
	// * This function is basically a factory function for {@link Optional},
	// that
	// * returns an optional containing the given value {@code t}, if the
	// * predicate {@code test} evaluates to {@code true}. If the predicate is
	// * evaluated to {@code false}, an empty optional will be returned.
	// * Semantically this method is equal to {@code some(t).filter(test)}, but
	// * may produce one object instance less.
	// *
	// * @param t
	// * value that will be wrapped into an optional if {@code test}
	// * evaluates to {@code true}
	// * @param test
	// * check that decides if value {@code t} will be wrapped into an
	// * Optional or not.
	// * @return optional that contains value {@code t}, if {@code test}
	// evaluates
	// * to {@code true}.
	// */
	// @Pure
	// public static <T> @NonNull Optional<T> onlyIf(@NonNull T t, @NonNull
	// Predicate<T> test) {
	// return test.test(t) ? Optional.of(t) : Optional.empty();
	// }
	//
	// @Pure
	// public static <T> @NonNull Optional<T> onlyIfNullable(@Nullable T t,
	// @NonNull Predicate<T> test) {
	// if (t == null) {
	// return Optional.empty();
	// } else {
	// return test.test(t) ? Optional.of(t) : Optional.empty();
	// }
	// }
	//
	// @Pure
	// public static <T, U> @NonNull Optional<@NonNull Pair<@NonNull T, @NonNull
	// U>> zip(@NonNull Optional<T> self,
	// @NonNull Optional<U> other) {
	// if (self.isPresent() && other.isPresent()) {
	// return Optional.of(Pair.of(self.get(), other.get()));
	// } else {
	// return Optional.empty();
	// }
	// }
	//
	// /**
	// * Returns the wrapped optional if present, or returns an empty optional
	// instead.<br>
	// * This method is inlined to the followin code.
	// * <pre>{@code self.orElse(Optional.empty())}</pre>
	// * @param self the optional to be flattened.
	// * @return the wrapped optional if present, or returns an empty optional
	// instead
	// */
	// @Inline(value = "$1.orElse(Optional.empty())", imported = Optional.class)
	// @Pure
	// public static <T> @NonNull Optional<T> flatten(@NonNull
	// Optional<Optional<T>> self) {
	// // TODO check if self.isPresent() ? self.get() : Optional.empty() is
	// // faster
	// return self.orElse(Optional.empty());
	// }
	//
	// @Inline(value = "$1.isPresent() ? $1.get() : null; if(!$1.isPresent())
	// return Optional.empty();", imported = Optional.class)
	// public static <T> T getOrReturn(Optional<T> opt) {
	// throw new IllegalStateException("Method can only be used inlined");
	// }
	//
	// public static <T, A, R> R collect(@NonNull Optional<T> self, @NonNull
	// Collector<? super T, A, R> collector) {
	// A a = collector.supplier().get();
	// if (self.isPresent()) {
	// collector.accumulator().accept(a, self.get());
	// }
	// // if
	// // collector.characteristics().contains(Characteristics.IDENTITY_FINISH))
	// // == true finisher does not
	// // have to be called. But this will probably take the same time as
	// // calling the finisher every time.
	// return collector.finisher().apply(a);
	// }

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

	/**
	 * This method will either return {@code self} if it is not empty, or
	 * otherwise {@code alternative}. If {@code self} is returned, it is casted
	 * to {@code Optional<U>}, which is safe, since the value can only be read
	 * from {@code self}.
	 * 
	 * @param self
	 *            optional to be checked if empty. If not, this value will be
	 *            returned from this method.
	 * @param alternative
	 *            will be returned if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns
	 *         {@code alternative}.
	 */
	@Pure
	@SuppressWarnings("unchecked") // we know cast is safe, because value
									// can
									// only be taken from Optional
	public static <T extends U, U> @NonNull Optional<U> orSuper(@NonNull Optional<T> self,
			@NonNull Optional<U> alternative) {
		return self.isPresent() ? (Optional<U>) self : alternative;
	}

	/**
	 * This method will either return {@code self} if it is not empty, or
	 * otherwise the value supplied by {@code alternative}. If {@code self} is
	 * returned, it is casted to {@code Optional<U>}, which is safe, since the
	 * value can only be read from {@code self}.
	 * 
	 * @param self
	 *            optional to be checked if empty. If not, this value will be
	 *            returned from this method.
	 * @param alternative
	 *            will be called to get return value if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns value
	 *         supplied by {@code alternative}.
	 */
	@SuppressWarnings("unchecked") // we know cast is safe, because value
									// can
									// only be taken from Optional
	public static <T extends U, U> @NonNull Optional<U> orSuper(@NonNull Optional<T> self,
			@NonNull Supplier<@NonNull Optional<U>> alternativeSupplier) {
		return self.isPresent() ? (Optional<U>) self : alternativeSupplier.get();
	}

	/**
	 * If a value is present in {@code self}, and the value is instance of the
	 * class {@code clazz}, this method returns {@code self} casted to
	 * {@code Optional<T>}, otherwise returns an empty {@code Optional}.
	 * 
	 * @param self
	 *            optional that's value is checked to be instance of
	 *            {@code clazz}
	 * @param clazz
	 *            the type by which the value in {@code self} is filtered
	 * @return if {@code self} is empty, or the value held by {@code self} is
	 *         not instance of {@code clazz} an empty optional, else
	 *         {@code self} casted to {@code Optional<T>}.
	 */
	@Pure
	@SuppressWarnings("unchecked") // we checked instance, so cast is safe.
	public static <T, U> @NonNull Optional<U> filter(@NonNull Optional<T> self, @NonNull Class<U> clazz) {
		return (@NonNull Optional<U>) self.filter(clazz::isInstance);
	}

	/**
	 * @see OptionalExtensions#ifPresent(Consumer)
	 * @param <T>
	 */
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
	/**
	 * This method is a good fit to be used with the
	 * {@link AdditionalFunctionExtensions#operator_tripleGreaterThan(Object, org.eclipse.xtext.xbase.lib.Functions.Function1)
	 * >>>} operator defined in class {@code AdditionalFunctionExtensions}.<br>
	 * Example:
	 * 
	 * <pre>
	 * {@code Optional.of("Hello") >>> ifPresent [
	 * 	println(it)
	 * ].elseDo [
	 * 	println("No value!")
	 * ]}
	 * </pre>
	 * 
	 * @param either
	 * @return
	 */
	@Pure
	public static <T> @NonNull PresenceCheck<T> ifPresent(@NonNull Consumer<@NonNull T> either) {
		return either::accept;
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
	public static <T> void ifNotPresent(@NonNull Optional<T> self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	/**
	 * Returns a procedure that invoked with a an empty optional will call
	 * procedure {@code then}.
	 * 
	 * @param then
	 *            procedure to be called if optional passed to returned
	 *            procedure is empty.
	 */
	@Pure
	public static <T> @NonNull Procedure1<@NonNull Optional<T>> ifNotPresent(@NonNull Procedure0 then) {
		return o -> ifNotPresent(o, then);
	}

	/**
	 * 
	 * Will call the given consumer If {@code opts} is empty, the
	 * {@code consumer} will be called with an empty list.
	 * 
	 * @param opts
	 *            list of optionals. If all optionals hold a value, they get
	 *            unpacked and passed to {@code consumer}.
	 * @param consumer
	 */
	public static <T> void ifAllPresent(@NonNull List<@NonNull Optional<T>> opts,
			@NonNull Consumer<@NonNull List<@NonNull T>> consumer) {
		if (opts.stream().allMatch(Optional::isPresent)) {
			final List<T> result = Lists.transform(opts, o -> o.get());
			consumer.accept(result);
		}
	}

	public static <T, U> void ifBothPresent(@NonNull Optional<T> a, @NonNull Optional<U> b, BiConsumer<T, U> consumer) {
		if (a.isPresent() && b.isPresent()) {
			consumer.accept(a.get(), b.get());
		}
	}

	/**
	 * Alias for {@link Optional#ofNullable(Object)}.
	 * 
	 * @param t
	 *            value the possibly-null value to be represented as
	 *            {@code Optional}
	 * @return an {@code Optional} with value {@code t} present if the specified
	 *         parameter {@code t} is not null, otherwise an empty
	 *         {@code Optional}
	 */
	@Pure
	@Inline(value = "Optional.ofNullable($1)", imported = Optional.class)
	public static <T> @NonNull Optional<T> maybe(@Nullable T t) {
		return Optional.ofNullable((T) t);
	}

	/**
	 * Alias for {@link Optional#of(Object)}.
	 * 
	 * @param t
	 *            non-null value to be represented as {@code Optional} wrapping
	 *            the value.
	 * @return An Optional with {@code t} as present value.
	 * @throws NullPointerException
	 *             if {@code t} is {@code null}.
	 */
	@Pure
	@Inline(value = "Optional.of($1)", imported = Optional.class)
	public static <T> @NonNull Optional<T> some(@NonNull T t) throws NullPointerException {
		return Optional.of(t);
	}

	/**
	 * Alias for {@link Optional#empty()}.
	 * 
	 * @return an empty Optional.
	 */
	@Pure
	@Inline(value = "Optional.empty()", imported = Optional.class)
	public static <T> @NonNull Optional<T> none() {
		return Optional.empty();
	}

	/**
	 * Alias for {@link Optional#orElse(Object)}.
	 * 
	 * @param o
	 *            optional to be queried for value
	 * @param alternative
	 *            will be returned if parameter {@code o} is empty.
	 * @return if {@code o} has a value present, will return this value.
	 *         Otherwise returns {@code alternative}.
	 */
	@Pure
	@Inline(value = "$1.orElse($2)", imported = Optional.class)
	public static <T> T operator_elvis(@NonNull Optional<T> o, T alternative) {
		return o.orElse(alternative);
	}

	/**
	 * Alias for {@link Optional#orElseGet(Supplier)}.
	 * 
	 * @param o
	 *            optional to be queried for value
	 * @param alternative
	 *            will be returned if parameter {@code o} is empty.
	 * @return if {@code o} has a value present, will return this value.
	 *         Otherwise returns {@code alternative}.
	 */
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

	@Pure
	public static <T> @NonNull Iterable<T> asIterable(@NonNull Optional<T> self) {
		if (self.isPresent()) {
			@NonNull
			T value = self.get();
			return new ValueIterable<>(value);
		} else {
			return Collections.emptySet();
		}
	}

	private static class ValueIterable<T> implements Iterable<T> {
		final T value;

		public ValueIterable(T value) {
			super();
			this.value = value;
		}

		@Override
		public Iterator<T> iterator() {
			return new ValueIterator<>(value);
		}

		@Override
		public void forEach(Consumer<? super T> action) {
			action.accept(value);
		}

		@Override
		public Spliterator<T> spliterator() {
			return Spliterators.spliterator(new Object[] { value }, Spliterator.IMMUTABLE);
		}
	}

	/**
	 * Iterator just iterating over a single value.
	 * 
	 * @param <T>
	 *            type of value to be provided by iterator
	 */
	private static class ValueIterator<T> implements Iterator<T> {

		final T value;
		boolean done = false;

		public ValueIterator(T value) {
			super();
			this.value = value;
		}

		@Override
		public boolean hasNext() {
			return !done;
		}

		@Override
		public T next() {
			if (done) {
				throw new NoSuchElementException();
			} else {
				done = true;
				return value;
			}
		}

	}

	/**
	 * Returns an {@link Iterator} that does not return a value if {@code self}
	 * is empty and an {@code Iterator} providing just the value of {@code self}
	 * if present
	 * 
	 * @param self
	 *            optional, iterator is returned for
	 * @return an Iterator providing zero or one element, depending if
	 *         {@code self} has a value present or not.
	 */
	public static <T> @NonNull Iterator<T> iterator(@NonNull Optional<T> self) {
		if (self.isPresent()) {
			return new ValueIterator<>(self.get());
		} else {
			return Collections.emptyIterator();
		}
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
			@NonNull
			T element = self.get();
			return ImmutableList.of(element);
		} else {
			return Collections.emptyList();
		}
	}

	/**
	 * If {@code self} is empty returns an empty {@code OptionalLong}, otherwise
	 * reads the long value from {@code self} and returns an
	 * {@code OptionalLong} holding the value.
	 * 
	 * @param self
	 *            Optional to be converted to an {@code OptionalLong}
	 * @return empty {@code OptionalLong} if {@code self} is empty, else an
	 *         {@code OptionalLong} holding the long value wrapped in
	 *         {@code self}.
	 */
	@Pure
	public static @NonNull OptionalLong unboxLong(@NonNull Optional<Long> self) {
		return mapLong(self, Long::longValue);
	}

	/**
	 * If {@code self} is empty returns an empty {@code OptionalInt}, otherwise
	 * reads the int value from {@code self} and returns an {@code OptionalInt}
	 * holding the value.
	 * 
	 * @param self
	 *            Optional to be converted to an {@code OptionalInt}.
	 * @return empty {@code OptionalInt} if {@code self} is empty, else an
	 *         {@code OptionalInt} holding the int value wrapped in
	 *         {@code self}.
	 */
	@Pure
	public static @NonNull OptionalInt unboxInt(@NonNull Optional<Integer> self) {
		return OptionalExtensions.mapInt(self, Integer::intValue);
	}

	/**
	 * If {@code self} is empty returns an empty {@code OptionalDouble},
	 * otherwise reads the double value from {@code self} and returns an
	 * {@code OptionalDouble} holding the value.
	 * 
	 * @param self
	 *            Optional to be converted to an {@code OptionalDouble}
	 * @return empty {@code OptionalDouble} if {@code self} is empty, else an
	 *         {@code OptionalDouble} holding the double value wrapped in
	 *         {@code self}.
	 */
	@Pure
	public static @NonNull OptionalDouble unboxDouble(@NonNull Optional<Double> self) {
		return mapDouble(self, Double::doubleValue);
	}

	/**
	 * This method will either return {@code self} if it is not empty, or
	 * otherwise {@code alternative}.
	 * 
	 * @param self
	 *            optional to be checked if empty. If not, this value will be
	 *            returned from this method.
	 * @param alternative
	 *            will be returned if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns
	 *         {@code alternative}.
	 */
	@Pure
	@SuppressWarnings("unchecked")
	public static <T> @NonNull Optional<T> or(@NonNull Optional<T> self, @NonNull Optional<? extends T> alternative) {
		return self.isPresent() ? self : (Optional<T>) alternative;
	}

	/**
	 * Operator that will be de-sugared to call to
	 * {@code OptionalExtensions.or(self,alternative)}.
	 * 
	 * @param self
	 *            optional to be checked if empty. If not, this value will be
	 *            returned from this method.
	 * @param alternative
	 *            will be returned if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns
	 *         {@code alternative}.
	 */
	@Pure
	@Inline(value = "OptionalExtensions.or($1,$2)", imported = OptionalExtensions.class)
	public static <T> @NonNull Optional<T> operator_or(@NonNull Optional<T> self,
			@NonNull Optional<? extends T> alternative) {
		return or(self, alternative);
	}

	/**
	 * Operator that will be de-sugared to call to
	 * {@code OptionalExtensions.or(self,alternative)}.
	 * 
	 * @param self
	 *            optional to be checked if empty. If not, this value will be
	 *            returned from operator.
	 * @param alternative
	 *            will be called to get return value if {@code self} is empty.
	 * @return {@code self}, if it is not empty, otherwise returns value
	 *         supplied by {@code alternative}.
	 */
	@Inline(value = "OptionalExtensions.or($1,$2)", imported = OptionalExtensions.class)
	public static <T> @NonNull Optional<T> operator_or(@NonNull Optional<T> self,
			@NonNull Supplier<@NonNull ? extends Optional<? extends T>> alternativeSupplier) {
		return or(self, alternativeSupplier);
	}

	// TODO java 9 forward compatibility

	//////////////////////////////////
	// Java 9 forward compatibility //
	//////////////////////////////////

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
	@SuppressWarnings("unchecked")
	public static <T> @NonNull Optional<T> or(@NonNull Optional<T> self,
			@NonNull Supplier<@NonNull ? extends Optional<? extends T>> alternativeSupplier) {
		return self.isPresent() ? self : (Optional<T>) alternativeSupplier.get();
	}

	/**
	 * Will call {@code action} with the value held by {@code opt} if it is not
	 * empty. Otherwise will call {@code emptyAction}.
	 * 
	 * @param opt
	 *            optional to be checked for value.
	 * @param action
	 *            to be called with value of {@code opt} if it is not empty.
	 * @param emptyAction
	 *            to be called if {@code opt} is empty.
	 */
	public static <T> void ifPresentOrElse(@NonNull Optional<T> opt, Consumer<? super T> action, Runnable emptyAction) {
		if (opt.isPresent()) {
			@NonNull
			T val = opt.get();
			action.accept(val);
		} else {
			emptyAction.run();
		}
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
