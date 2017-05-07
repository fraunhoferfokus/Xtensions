package de.fhg.fokus.xtensions.iterator

import java.util.Collection
import java.util.Objects
import java.util.stream.Stream
import java.util.stream.StreamSupport

class IterableExtensions {

	/**
	 * Creates a {@link Stream} instance for processing the elements 
	 * of the Iterable {@code it}.<br/>
	 * If the given {@link Iterable} is instance of {@link Collection}, the 
	 * {@link Collection#stream() stream} method of the Collection interface will
	 * be called. Otherwise uses {@link StreamSupport} to create a Stream with the
	 * Spliterator created using {@link Iterable#spliterator()}.
	 * @param Iterable from which the returned Stream is created
	 * @return Stream to process all elements of the given Iterator {@code it}.
	 */
	static def <T> Stream<T> stream(Iterable<T> it) {
		Objects.requireNonNull(it)
		// if there is a native stream function, take this!
		if (it instanceof Collection<?>) {
			it.stream as Stream<T>
		} else {
			StreamSupport.stream(it.spliterator, false)
		}
	}

	/**
	 * Creates a parallel {@link Stream} instance for processing the elements 
	 * of the Iterable {@code it}.<br/>
	 * If the given {@link Iterable} is instance of {@link Collection}, the 
	 * {@link Collection#parallelStream() parallelStream} method of the Collection interface will
	 * be called. Otherwise uses {@link StreamSupport} to create the parallel Stream with the
	 * Spliterator created using {@link Iterable#spliterator()}.
	 * @param Iterable from which the returned Stream is created
	 * @return parallel Stream to process all elements of the given Iterator {@code it}.
	 */
	static def <T> Stream<T> parallelStream(Iterable<T> it) {
		Objects.requireNonNull(it)
		// if there is a native stream function, take this!
		if (it instanceof Collection<?>) {
			it.parallelStream as Stream<T>
		} else {
			StreamSupport.stream(it.spliterator, true)
		}
	}
}
