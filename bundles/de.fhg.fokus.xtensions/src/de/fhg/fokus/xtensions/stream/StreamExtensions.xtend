package de.fhg.fokus.xtensions.stream

import java.util.Collection
import java.util.List
import java.util.Objects
import java.util.Set
import java.util.function.Supplier
import java.util.stream.Stream
import java.util.stream.StreamSupport

import static java.util.stream.Collectors.*

class StreamExtensions {

	// //
	// Stream constructors
	// /
	
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
		if (it instanceof Collection) {
			it.stream
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
		if (it instanceof Collection) {
			it.parallelStream
		} else {
			StreamSupport.stream(it.spliterator, true)
		}
	}
	
	// ////////////////
	// More filters //
	// ////////////////
	
	static def <T, U> Stream<U> filter(Stream<T> input, Class<? extends U> clazz) {
		Objects.requireNonNull(input)
		Objects.requireNonNull(clazz)
		input.filter[clazz.isInstance(it)] as Stream<U>
	}

	static def <T> Stream<T> filterNull(Stream<T> stream) {
		Objects.requireNonNull(stream)
		stream.filter[it !== null]
	}

	// ///////////////////////////////////
	// Shortcuts for common collectors //
	// ///////////////////////////////////
	
	static def <T> List<T> toList(Stream<T> stream) {
		stream.collect(toList)
	}

	static def <T> Set<T> toSet(Stream<T> stream) {
		stream.collect(toSet)
	}

	static def <T, C extends Collection<T>> C toCollection(Stream<T> stream, Supplier<C> collectionFactory) {
		stream.collect(toCollection(collectionFactory))
	}

	// //////////
	// Others //
	// //////////

	/**
	 * This function returns a stream of the Cartesian product of {@code stream} and the iterable {@code combineWith}.
	 */ 
	static def <T, Z> Stream<Pair<T, Z>> combinations(Stream<T> stream, Iterable<Z> combineWith) {
		Objects.requireNonNull(combineWith);
		stream.flatMap[t|combineWith.stream.map[t -> it]]
	}

	static def <T, Z> Stream<Pair<T, Z>> combinations(Stream<T> stream, Collection<Z> combineWith) {
		Objects.requireNonNull(combineWith);
		stream.flatMap[t|combineWith.stream.map[t -> it]]
	}

	/**
	 * On every call the given {@code streamSupplier) has to return a stream of the same elements.
	 */
	static def <T, Z> Stream<Pair<T, Z>> combinations(Stream<T> stream, ()=>Stream<Z> streamSupplier) {
		Objects.requireNonNull(streamSupplier);
		stream.flatMap[t|streamSupplier.apply.map[t -> it]]
	}

	/**
	 * This function returns a stream of the Cartesian product of {@code stream} and the iterable {@code combineWith}.
	 */ 
	static def <T, Z, R> Stream<R> combinations(Stream<T> stream, Iterable<Z> combineWith, (T,Z)=>R combiner) {
		Objects.requireNonNull(combineWith);
		stream.flatMap[t|combineWith.stream.map[combiner.apply(t,it)]]
	}

	static def <T, Z, R> Stream<R> combinations(Stream<T> stream, Collection<Z> combineWith, (T,Z)=>R combiner) {
		Objects.requireNonNull(combineWith);
		stream.flatMap[t|combineWith.stream.map[combiner.apply(t,it)]]
	}

	/**
	 * On every call the given {@code streamSupplier) has to return a stream of the same elements.
	 */
	static def <T, Z, R> Stream<R> combinations(Stream<T> stream, ()=>Stream<Z> streamSupplier, (T,Z)=>R combiner) {
		Objects.requireNonNull(streamSupplier);
		stream.flatMap[t|streamSupplier.apply.map[combiner.apply(t,it)]]
	}
	
	static def <T> Stream<T> + (Stream<? extends T> first, Stream<? extends T> second) {
		Stream.concat(first, second)
	}

	static def <T, V> Stream<V> flatMap(Stream<T> stream, (T)=>Collection<? extends V> mappingFunc) {
		Objects.requireNonNull(mappingFunc);
		stream.flatMap[mappingFunc.apply(it).stream]
	}

	static def <T, V> Stream<V> flatMapIter(Stream<T> stream, (T)=>Iterable<? extends V> mappingFunc) {
		Objects.requireNonNull(mappingFunc);
		stream.flatMap[mappingFunc.apply(it).stream]
	}

// TODO
// Collector IsEmpty => Stream#isEmpty
// Collector GetOnlyElement => Stream#getOnlyElement() -> Optional<T>
// Stream<Iterable>#flatten //?? needed?
// Stream<T>#forEach with index (check parallel! Use AtomicLong with getAndIncrement )
// Stream<T>#forEachOrdered indexed (check parallel!)
// Stream<T>#indexed():Stream<Pair<int,T>> (check parallel!)
// Stream<T>#zip(Iterable<? extends V>):Stream<Pair<T,V>> : call zip(iterable.spliterator())
// Stream<T>#zip(Stream<V>) : Stream<Pair<T,V>>: call zip(stream.spliterator())
// Stream<T>#zip(Spliterator<V>) :  Stream<Pair<T,V>> create new based spliterator on both and stream from spliterator, maybe thorw if one source not ordered
// zip variants with BiFunction<T,V,R> returning Stream<V>
// Stream<Pair<X,Y>>#squash((X,Y)=>Z), auch f�r andere?
}