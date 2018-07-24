package de.fhg.fokus.xtensions.incubation.optional;

import org.eclipse.jdt.annotation.NonNull;
import java.util.function.Predicate;
import java.util.stream.Collector;
import java.util.Optional;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Pure;

public class OptionalExtensions {
	
	// TODO is any of the following functionality actually useful???

	/**
	 * This function is basically a factory function for {@link Optional}, that
	 * returns an optional containing the given value {@code t}, if the predicate
	 * {@code test} evaluates to {@code true}. If the predicate is evaluated to
	 * {@code false}, an empty optional will be returned. Semantically this method
	 * is equal to {@code some(t).filter(test)}, but may produce one object instance
	 * less.
	 *
	 * @param t    value that will be wrapped into an optional if {@code test}
	 *             evaluates to {@code true}
	 * @param test check that decides if value {@code t} will be wrapped into an
	 *             Optional or not.
	 * @return optional that contains value {@code t}, if {@code test} evaluates to
	 *         {@code true}.
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

	@Pure
	public static <T, U> @NonNull Optional<@NonNull Pair<@NonNull T, @NonNull U>> zip(@NonNull Optional<T> self,
			@NonNull Optional<U> other) {
		if (self.isPresent() && other.isPresent()) {
			return Optional.of(Pair.of(self.get(), other.get()));
		} else {
			return Optional.empty();
		}
	}

	/**
	 * Returns the wrapped optional if present, or returns an empty optional
	 * instead.<br>
	 * This method is inlined to the followin code.
	 * 
	 * <pre>
	 * {@code self.orElse(Optional.empty())}
	 * </pre>
	 * 
	 * @param self the optional to be flattened.
	 * @return the wrapped optional if present, or returns an empty optional instead
	 */
	@Inline(value = "$1.orElse(Optional.empty())", imported = Optional.class)
	@Pure
	public static <T> @NonNull Optional<T> flatten(@NonNull Optional<Optional<T>> self) {
		// TODO check if self.isPresent() ? self.get() : Optional.empty() is
		// faster
		return self.orElse(Optional.empty());
	}

	@Inline(value = "$1.isPresent() ? $1.get() : null; if(!$1.isPresent())return Optional.empty();", imported = Optional.class)
	public static <T> T getOrReturn(Optional<T> opt) {
		throw new IllegalStateException("Method can only be used inlined");
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
}