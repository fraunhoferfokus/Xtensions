package de.fhg.fokus.xtensions.optional;

import java.util.Iterator;
import java.util.Map;
import java.util.Optional;
import java.util.Queue;
import java.util.function.Consumer;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.Inline;

import static de.fhg.fokus.xtensions.optional.OptionalExtensions.*;
import static org.eclipse.xtext.xbase.lib.IterableExtensions.*;

public class CollectionOptionalExtensions {

	private CollectionOptionalExtensions() {
		throw new IllegalStateException("CollectionOptionalExtensions is not allowed to be instantiated");
	}

	/**
	 * This method will look up the given {@code key} in the map {@code self}
	 * and if the value returned from the get operation is not {@code null}, the
	 * given {@code consumer} is called with the retrieved value. Be aware that
	 * this method cannot distinguish between a {@code null} value registered
	 * for the given key (given that the map supports null values) and the fact
	 * that no value was set for the given key.
	 * 
	 * @param self
	 *            map the value is read for the given {@code key}.
	 * @param key
	 *            will be used to look up value in map {@code self}.
	 * @param consumer
	 *            will be called with value registered under {@code key}, if
	 *            exists and is non-null.
	 * @throws NullPointerException
	 *             if the specified {@code key} is {@code null} and {@code self}
	 *             map does not permit {@code null} keys
	 */
	public static <K, V> void ifGet(@NonNull Map<K, V> self, @Nullable K key,
			@NonNull Consumer<@NonNull ? super V> consumer) throws NullPointerException {
		V val = self.get(key);
		if (val != null) {
			consumer.accept(val);
		}
	}
	
	/**
	 * This operation has to perform two lookup operations, which may lead to
	 * undesired effects when the Map {@code self} is updated concurrently while
	 * calling this method. This may cause the {@code consumer} to receive an empty
	 * Optional, even if there is no entry for the given {@code key} in the map anymore.
	 * The user has to make sure to synchronize access to the map if concurrent access
	 * is needed.
	 * 
	 * @param self
	 * @param key
	 * @param consumer
	 * @throws NullPointerException
	 */
	public static <K, V> void ifGetExists(@NonNull Map<K, V> self, @Nullable K key,
			@NonNull Consumer<@NonNull ? super Optional<@NonNull V>> consumer) throws NullPointerException {
		// Alternatively Map#computeIfPresent could be re-purposed,
		// which can have better performance if default method is overridden.
		// But that solution could lead to update loss in concurrent access.
		// A read operation must not cause a lost update.
		if(self.containsKey(key)) {
			V val = self.get(key);
			consumer.accept(maybe(val));
		}
	}
	
	// TODO Map<T>#putOpt(Optional<T>)???

	@Inline(value = "Optional.ofNullable($1.get($2))", imported = Optional.class)
	public static <K, V> Optional<V> getOpt(@NonNull Map<K, V> self, @Nullable K key) {
		return maybe(self.get(key));
	}

	public static <V> void ifPoll(@NonNull Queue<V> self, @NonNull Consumer<@NonNull V> consumer) {
		final V val = self.poll();
		if (val != null) {
			consumer.accept(val);
		}
	}

// TODO: really needed???
//
//	// TODO primitive versions
//	public static <T, R> R foldPresent(@NonNull Iterable<Optional<T>> self, R seed,
//			@NonNull Function2<? super R, ? super T, ? extends R> function) {
//		return fold(self, seed, (r, o) -> o.isPresent() ? function.apply(r, o.get()) : r);
//	}
//
//	// TODO primitive versions
//	public static <T> Optional<T> reducePresent(@NonNull Iterable<? extends Optional<? extends T>> iterable,
//			@NonNull Function2<? super T, ? super T, ? extends T> function) {
//		final Iterator<? extends Optional<? extends T>> iterator = iterable.iterator();
//		// we can only fold if we have at least one value
//		if (!iterator.hasNext()) {
//			return none();
//		}
//		Optional<? extends T> next = iterator.next();
//		// find first non-empty optional
//		while (!next.isPresent() && iterator.hasNext()) {
//			next = iterator.next();
//		}
//		// if we did not find a non-empty element, we have no result
//		if (!next.isPresent()) {
//			return none();
//		}
//		T result = next.get();
//		// now start actual folding
//		while (iterator.hasNext()) {
//			next = iterator.next();
//			// only fold existing values
//			if (next.isPresent()) {
//				result = function.apply(result, next.get());
//			}
//		}
//		return maybe(result);
//	}

	/*
	 * public static <V> void ifPeek public static <V> peekOpt() public static
	 * <V> pollOpt()
	 * 
	 * public static <V> ifPeekLast public static <V> ifPollLast public static
	 * <V> peekLastOpt public static <V> pollLastOpt public static <V>
	 * ifPeekFirst public static <V> ifPollFirst public static <V> peekFirstOpt
	 * public static <V> pollFirstOpt
	 * 
	 * Iterable extensions: public static <V> ifHead public static <V> ifLast
	 * public static <V> headOpt public static <V> lastOpt findFirstOpt
	 * findLastOpt ifFindFirst ifFindLast minOpt ifMin maxOpt ifMax ifReduce
	 * reduceOpt
	 * 
	 * List remove, get
	 */
}
