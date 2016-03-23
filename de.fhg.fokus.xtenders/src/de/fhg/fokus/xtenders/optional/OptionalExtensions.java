package de.fhg.fokus.xtenders.optional;

import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.OptionalDouble;
import java.util.OptionalInt;
import java.util.OptionalLong;
import java.util.PrimitiveIterator;
import java.util.PrimitiveIterator.OfDouble;
import java.util.PrimitiveIterator.OfInt;
import java.util.PrimitiveIterator.OfLong;
import java.util.Set;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.function.DoubleConsumer;
import java.util.function.DoubleFunction;
import java.util.function.DoublePredicate;
import java.util.function.DoubleSupplier;
import java.util.function.DoubleToIntFunction;
import java.util.function.DoubleToLongFunction;
import java.util.function.DoubleUnaryOperator;
import java.util.function.Function;
import java.util.function.IntConsumer;
import java.util.function.IntFunction;
import java.util.function.IntPredicate;
import java.util.function.IntSupplier;
import java.util.function.IntToDoubleFunction;
import java.util.function.IntToLongFunction;
import java.util.function.IntUnaryOperator;
import java.util.function.LongConsumer;
import java.util.function.LongFunction;
import java.util.function.LongPredicate;
import java.util.function.LongSupplier;
import java.util.function.LongToDoubleFunction;
import java.util.function.LongToIntFunction;
import java.util.function.LongUnaryOperator;
import java.util.function.Predicate;
import java.util.function.Supplier;
import java.util.function.ToDoubleFunction;
import java.util.function.ToIntFunction;
import java.util.function.ToLongFunction;
import java.util.stream.Collector;
import java.util.stream.Collectors;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;

import com.google.common.collect.Lists;

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

	// TODO implement flatMap / flatMapInt / flatMapLong / flatMapDouble for all
	// optionals

	/**
	 * This function is basically a factory function for {@link Optional}, that
	 * returns an optional containing the given value {@code t}, if the
	 * predicate {@code test} evaluates to {@code true}. If the predicate is
	 * evaluated to {@code false}, an empty optional will be returned.
	 * Semantically this method is equal to {@code some(t).filter(test)}, but
	 * may produce one object instance less.
	 * 
	 * @param t
	 *            value that will be wrapped into an optional if {@code test}
	 *            evaluates to {@code true}
	 * @param test
	 *            check that decides if value {@code t} will be wrapped into an
	 *            Optional or not.
	 * @return optional that contains value {@code t}, if {@code test} evaluates
	 *         to {@code true}.
	 */
	@Pure
	public static <T> @NonNull Optional<T> onlyIf(@NonNull T t, @NonNull Predicate<T> test) {
		return test.test(t) ? Optional.of(t) : Optional.empty();
	}

	@Pure
	public static <T> @NonNull Optional<T> onlyIfNullable(@Nullable T t, @NonNull Predicate<T> test) {
		if (t == null) {
			return Optional.empty();
		} else {
			return test.test(t) ? Optional.of(t) : Optional.empty();
		}
	}

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
	 * @param optIter optional that may hold an Iterable.
	 * @return either the iterable held in the optional, or an empty iterable
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" }) // we know the default provider is safe
	@Inline(value = "$1.orElseGet((Supplier)Collections::emptyList)", imported = {Supplier.class,Collections.class})
	public static <T> Iterable<T> orElseEmpty(@NonNull Optional<? extends Iterable<T>> optIter) {
		return optIter.orElseGet((Supplier)Collections::emptyList);
	}

	//////////////
	// Optional //
	//////////////

	// TODO exists(Predicate<T>) as shortcut for filter(Predicate<T>).isPresent() ?

	@SuppressWarnings("null") // we provide non-null else value, so result
								// must
								// be non-null
	@Inline(value = "$1.orElse(Optional.empty())", imported = Optional.class)
	@Pure
	public static <T> @NonNull Optional<T> flatten(@NonNull Optional<Optional<T>> self) {
		// TODO check if self.isPresent() ? self.get() : Optional.empty() is
		// faster
		return self.orElse(Optional.empty());
	}

	@Pure
	@SuppressWarnings("unchecked")
	public static <T> @NonNull Optional<T> orAlt(@NonNull Optional<T> self,
			@NonNull Optional<? extends T> alternative) {
		return self.isPresent() ? self : (Optional<T>) alternative;
	}

	@SuppressWarnings("unchecked")
	public static <T> @NonNull Optional<T> orAltGet(@NonNull Optional<T> self,
			@NonNull Supplier<@NonNull ? extends Optional<? extends T>> alternativeSupplier) {
		return self.isPresent() ? self : (Optional<T>) alternativeSupplier.get();
	}

	@Pure
	@Inline(value = "OptionalExtensions.orAlt($1,$2)", imported = OptionalExtensions.class)
	public static <T> @NonNull Optional<T> operator_or(@NonNull Optional<T> self,
			@NonNull Optional<? extends T> alternative) {
		return orAlt(self, alternative);
	}

	@Inline(value = "OptionalExtensions.orAltGet($1,$2)", imported = OptionalExtensions.class)
	public static <T> @NonNull Optional<T> operator_or(@NonNull Optional<T> self,
			@NonNull Supplier<@NonNull ? extends Optional<? extends T>> alternativeSupplier) {
		return orAltGet(self, alternativeSupplier);
	}

	@Pure
	@SuppressWarnings("unchecked") // we know cast is safe, because value
									// can
									// only be taken from Optional
	public static <T extends U, U> @NonNull Optional<U> orAltSuper(@NonNull Optional<T> self,
			@NonNull Optional<U> alternative) {
		return self.isPresent() ? (Optional<U>) self : alternative;
	}

	@SuppressWarnings("unchecked") // we know cast is safe, because value
									// can
									// only be taken from Optional
	public static <T extends U, U> @NonNull Optional<U> orAltSuperGet(@NonNull Optional<T> self,
			@NonNull Supplier<@NonNull Optional<U>> alternativeSupplier) {
		return self.isPresent() ? (Optional<U>) self : alternativeSupplier.get();
	}

	@Pure
	@SuppressWarnings("unchecked") // we checked instance, so cast is safe.
	public static <T, U> @NonNull Optional<U> filter(@NonNull Optional<T> self, @NonNull Class<U> clazz) {
		return (@NonNull Optional<U>) self.filter(t -> clazz.isInstance(t));
	}

	@Pure
	public static <T, U> @NonNull Optional<@NonNull Pair<@NonNull T, @NonNull U>> zip(@NonNull Optional<T> self,
			@NonNull Optional<U> other) {
		if (self.isPresent() && other.isPresent()) {
			return Optional.of(Pair.of(self.get(), other.get()));
		} else {
			return Optional.empty();
		}
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

	// due to problems with the Xtend compiler we cannot use PresenceCheck as parameter
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

	@SuppressWarnings("null") // we know that the resulting list and its
								// content
								// is not null
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

	public static <T, U> void operator_doubleGreaterThan(@NonNull Pair<@NonNull Optional<T>, @NonNull Optional<U>> opts,
			@NonNull BiConsumer<T, U> consumer) {
		ifBothPresent(opts.getKey(), opts.getValue(), consumer);
	}
	
	public static <T, U> void operator_doubleGreaterThan(@NonNull Optional<Pair<@NonNull T, @NonNull U>> opts,
			@NonNull BiConsumer<T, U> consumer) {
		if(opts.isPresent()) {
			final Pair<@NonNull T, @NonNull U> pair = opts.get();
			consumer.accept(pair.getKey(), pair.getValue());
		}
	}

	@Pure
	@SuppressWarnings("null") // t is allowed to be null
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

	@Inline(value = "$1.map($2)", imported = Optional.class)
	public static <T, V> @NonNull Optional<V> operator_mappedTo(@NonNull Optional<T> o, @NonNull Function<T, V> f) {
		return o.map(f);
	}

	@Inline(value = "$1.ifPresent($2)", imported = Optional.class)
	public static <T> void operator_doubleGreaterThan(@NonNull Optional<T> self,
			@NonNull Consumer<@NonNull ? super T> consumer) {
		self.ifPresent(consumer);
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

	public static <T, A, R> R collect(@NonNull Optional<T> self, @NonNull Collector<? super T, A, R> collector) {
		A a = collector.supplier().get();
		if (self.isPresent()) {
			collector.accumulator().accept(a, self.get());
		}
		// if
		// collector.characteristics().contains(Characteristics.IDENTITY_FINISH))
		// == true finisher does not
		// have to be called. But this will probably take the same time as
		// calling the finisher every time.
		return collector.finisher().apply(a);
	}

	@Inline(value = "OptionalExtensions.collect($1, $2)", imported = OptionalExtensions.class)
	public static <T, A, R> R operator_tripleGreaterThan(@NonNull Optional<T> self,
			@NonNull Collector<? super T, A, R> collector) {
		return collect(self, collector);
	}

	@Pure
	public static <T> @NonNull Iterable<T> toIterable(@NonNull Optional<T> self) {
		return () -> iterator(self);
	}

	public static <T> @NonNull Iterator<T> iterator(@NonNull Optional<T> self) {
		class OptionalIterator implements Iterator<T> {
			boolean done = false;

			@Override
			public boolean hasNext() {
				return !done && self.isPresent();
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
	 * optional, or an empty set, if the optional is empty. If a mutable set is
	 * needed, use {@link OptionalExtensions#collect(Optional, Collector)
	 * collect} or the equivalent operator
	 * {@link OptionalExtensions#operator_tripleGreaterThan(Optional, Collector)
	 * >>>} with the collector {@link Collectors#toSet() Collectors::toSet}
	 * instead.
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

	/////////////////
	// OptionalInt //
	/////////////////

	@FunctionalInterface
	public interface IntPresenceCheck extends IntConsumer, Procedure1<@NonNull OptionalInt> {

		/**
		 * User method, will be called if Optional contains a value.
		 */
		@Override
		void accept(int value);

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

	public static <T> void intNotPresent(@NonNull OptionalInt self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	public static <T> @NonNull Procedure1<@NonNull OptionalInt> intNotPresent(@NonNull Procedure0 then) {
		return o -> intNotPresent(o, then);
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
	@Inline(value = "$1.ifPresent($2)", imported = OptionalInt.class)
	public static <T> void operator_doubleGreaterThan(@NonNull OptionalInt self, @NonNull IntConsumer consumer) {
		self.ifPresent(consumer);
	}

	@Pure
	public static @NonNull Optional<Integer> boxed(@NonNull OptionalInt self) {
		return map(self, Integer::valueOf);
	}

	@Pure
	public static @NonNull OptionalInt unboxInt(@NonNull Optional<Integer> self) {
		return mapInt(self, Integer::intValue);
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
		return self.isPresent() ? OptionalInt.of(op.applyAsInt(self.getAsInt())) : OptionalInt.empty();
	}

	public static <T> @NonNull OptionalLong mapLong(@NonNull OptionalInt self, @NonNull IntToLongFunction mapFunc) {
		return self.isPresent() ? OptionalLong.of(mapFunc.applyAsLong(self.getAsInt())) : OptionalLong.empty();
	}

	public static <T> @NonNull OptionalDouble mapDouble(@NonNull OptionalInt self,
			@NonNull IntToDoubleFunction mapFunc) {
		return self.isPresent() ? OptionalDouble.of(mapFunc.applyAsDouble(self.getAsInt())) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull Iterable<Integer> toIterable(@NonNull OptionalInt self) {
		return () -> iterator(boxed(self));
	}

	public static <T> @NonNull OfInt iterator(@NonNull OptionalInt self) {
		class OptionalIntIterator implements PrimitiveIterator.OfInt {
			boolean done = false;

			@Override
			public boolean hasNext() {
				return !done && self.isPresent();
			}

			@Override
			public int nextInt() {
				if (done) {
					throw new NoSuchElementException("Last value already read");
				}
				done = true;
				return self.getAsInt();
			}

		}
		return new OptionalIntIterator();
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

	public static <T, A, R> R collect(@NonNull OptionalInt self, @NonNull Collector<? super Integer, A, R> collector) {
		A a = collector.supplier().get();
		if (self.isPresent()) {
			collector.accumulator().accept(a, self.getAsInt());
		}
		// if
		// collector.characteristics().contains(Characteristics.IDENTITY_FINISH))
		// == true finisher does not
		// have to be called. But this will probably take the same time as
		// calling the finisher every time.
		return collector.finisher().apply(a);
	}

	public static <T, A, R> R operator_tripleGreaterThan(@NonNull OptionalInt self,
			@NonNull Collector<? super Integer, A, R> collector) {
		return collect(self, collector);
	}

	//////////////////
	// OptionalLong //
	//////////////////

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

	@Inline(value = "$1.ifPresent($2)", imported = OptionalLong.class)
	public static <T> void operator_doubleGreaterThan(@NonNull OptionalLong self, @NonNull LongConsumer consumer) {
		self.ifPresent(consumer);
	}

	@Pure
	public static @NonNull Optional<Long> boxed(@NonNull OptionalLong self) {
		return map(self, Long::valueOf);
	}

	@Pure
	public static @NonNull OptionalLong unboxLong(@NonNull Optional<Long> self) {
		return mapLong(self, Long::longValue);
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
	public static <T> @NonNull Iterable<Long> toIterable(@NonNull OptionalLong self) {
		return () -> iterator(boxed(self));
	}

	public static <T> @NonNull OfLong iterator(@NonNull OptionalLong self) {
		class OptionalLongIterator implements PrimitiveIterator.OfLong {
			boolean done = false;

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

	public static <T, A, R> R operator_tripleGreaterThan(@NonNull OptionalLong self,
			@NonNull Collector<? super Long, A, R> collector) {
		return collect(self, collector);
	}

	////////////////////
	// OptionalDouble //
	////////////////////

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
	public static <T> @NonNull DoublePresenceCheck doublePresent(@NonNull DoubleConsumer either) {
		return either::accept;
	}

	public static <T> void doubleNotPresent(@NonNull OptionalDouble self, @NonNull Procedure0 then) {
		if (!self.isPresent()) {
			then.apply();
		}
	}

	@Pure
	public static <T> @NonNull Procedure1<@NonNull OptionalDouble> doubleNotPresent(@NonNull Procedure0 then) {
		return o -> doubleNotPresent(o, then);
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

	@Inline(value = "$1.ifPresent($2)", imported = OptionalDouble.class)
	public static <T> void operator_doubleGreaterThan(@NonNull OptionalDouble self, @NonNull DoubleConsumer consumer) {
		self.ifPresent(consumer);
	}

	@Pure
	public static @NonNull Optional<Double> boxed(@NonNull OptionalDouble self) {
		return map(self, Double::valueOf);
	}

	@Pure
	public static @NonNull OptionalDouble unboxDouble(@NonNull Optional<Double> self) {
		return mapDouble(self, Double::doubleValue);
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

	public static <T> @NonNull Iterable<Double> toIterable(@NonNull OptionalDouble self) {
		return () -> iterator(boxed(self));
	}

	public static <T> @NonNull OfDouble iterator(@NonNull OptionalDouble self) {
		class OptionalLongIterator implements PrimitiveIterator.OfDouble {
			boolean done = false;

			@Override
			public boolean hasNext() {
				return !done && self.isPresent();
			}

			@Override
			public double nextDouble() {
				if (done) {
					throw new NoSuchElementException("Last value already read");
				}
				done = true;
				return self.getAsDouble();
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
	public static @NonNull Set<Double> toSet(@NonNull OptionalDouble self) {
		if (self.isPresent()) {
			return Collections.singleton(self.getAsDouble());
		} else {
			return Collections.emptySet();
		}
	}

	public static <T, A, R> R collect(@NonNull OptionalDouble self,
			@NonNull Collector<? super Double, A, R> collector) {
		A a = collector.supplier().get();
		if (self.isPresent()) {
			collector.accumulator().accept(a, self.getAsDouble());
		}
		// if
		// collector.characteristics().contains(Characteristics.IDENTITY_FINISH))
		// == true finisher does not
		// have to be called. But this will probably take the same time as
		// calling the finisher every time.
		return collector.finisher().apply(a);
	}

	public static <T, A, R> R operator_tripleGreaterThan(@NonNull OptionalDouble self,
			@NonNull Collector<? super Double, A, R> collector) {
		return collect(self, collector);
	}

}
