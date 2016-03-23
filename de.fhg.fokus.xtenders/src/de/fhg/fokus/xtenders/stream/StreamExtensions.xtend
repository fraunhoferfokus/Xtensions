package de.fhg.fokus.xtenders.stream

import java.util.Collection
import java.util.List
import java.util.Objects
import java.util.Set
import java.util.Spliterator
import java.util.Spliterators
import java.util.function.Supplier
import java.util.regex.Pattern
import java.util.stream.IntStream
import java.util.stream.Stream
import java.util.stream.StreamSupport

import static java.util.stream.Collectors.*

import static extension de.fhg.fokus.xtenders.string.StringSplitExtensions.*
import static extension de.fhg.fokus.xtenders.string.StringMatchExtensions.*

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

	/**
	 * Creates an {@link IntStream} for processing of all integers of the
	 * given {@code range}.
	 * @param range The source providing the elements to the returned IntStream
	 * @return stream of all integers defined by the range
	 */
	static def IntStream intStream(IntegerRange range) {
		StreamSupport.intStream(new IntRangeSpliterator(range), false)
	}

	/**
	 * Creates a parallel {@link IntStream} for processing of all integers of the
	 * given {@code range}.
	 * @param range The source providing the elements to the returned IntStream
	 * @return parallel IntStream of all integers defined by the range
	 */
	static def IntStream parallelIntStream(IntegerRange range) {
		StreamSupport.intStream(new IntRangeSpliterator(range), true)
	}

	// TODO IntSreams for ExclusiveRange
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
		stream.filter[it != null]
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

	// /////////////////////////////
	// Stream<Strings> helpers //
	// /////////////////////////////
	static def String join(Stream<? extends CharSequence> stream) {
		stream.collect(joining)
	}

	static def String join(Stream<? extends CharSequence> stream, CharSequence delimiter) {
		Objects.requireNonNull(delimiter, "separator string must not be null")
		stream.collect(joining(delimiter))
	}

	static def String join(Stream<? extends CharSequence> stream, CharSequence delimiter, CharSequence prefix,
		CharSequence suffix) {
		Objects.requireNonNull(delimiter, "separator string must not be null")
		stream.collect(joining(delimiter, prefix, suffix))
	}

	static def <S extends CharSequence> Stream<S> matching(Stream<S> stream, String pattern) {
		Objects.requireNonNull(pattern, "Pattern must not be null")
		Objects.requireNonNull(stream, "Stream must not be null")
		val p = Pattern.compile(pattern)
		stream.matching(p)
	}

	static def <S extends CharSequence> Stream<S> matching(Stream<S> stream, Pattern pattern) {
		stream.filter[pattern.matcher(it).matches]
	}

	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, String pattern) {
		val p = Pattern.compile(pattern)
		stream.flatSplit(p)
	}

	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, Pattern pattern) {
		stream.flatMap[pattern.splitAsStream(it)]
	}

	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, String pattern, int limit) {
		val p = Pattern.compile(pattern)
		stream.flatSplit(p, limit)
	}

	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, Pattern pattern, int limit) {
		stream.flatMap[splitStream(pattern, limit)]
	}

	private static def Stream<String> splitStream(CharSequence input, Pattern pattern, int limit) {
		if (limit == 0) {
			// take platform native implementation for default behavior
			pattern.splitAsStream(input)
		} else {
			val Supplier<Spliterator<String>> s = [|
				val characteristics = Spliterator.ORDERED.bitwiseOr(Spliterator.NONNULL)
				Spliterators.spliteratorUnknownSize(input.splitIt(pattern, limit), characteristics)
			]
			StreamSupport.stream(s, 0, false)
		}
	}

	static def Stream<String> flatMatches(Stream<String> stream, Pattern pattern) {
		stream.flatMap[matchStream(pattern)]
	}

	static def Stream<String> flatMatches(Stream<String> stream, String pattern) {
		stream.flatMatches(Pattern.compile(pattern))
	}

	private static def Stream<String> matchStream(String input, Pattern pattern) {
		// TODO characteristics!!
		val Supplier<Spliterator<String>> s = [|
			Spliterators.spliteratorUnknownSize(input.matchIt(pattern), 0)
		]
		StreamSupport.stream(s, 0, false)
	}

// //////////
// Others //
// //////////
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

	static def <T> Stream<T> +(Stream<? extends T> first, Stream<? extends T> second) {
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
// 
// Collector GetOnlyElement => Stream#getOnlyElement() -> Optional<T>
// Stream<Iterable>#flatten //?? needed?
// Stream<String>#matches, groups to stream (reading lazy)?
// Stream<String>#matching(String) and #matching(Pattern)
// Stream<T>#forEach with index (check parallel!)
// Stream<T>#forEachOrdered indexed (check parallel!)
// Stream<T>#indexed():Stream<Pair<int,T>> (check parallel!)
// Stream<T>#zip(Iterable<? extends V>):Stream<Pair<T,V>> document that parallel is not efficient
// Stream<Pair<X,Y>>#map((X,Y)=>Z), auch für andere?
}