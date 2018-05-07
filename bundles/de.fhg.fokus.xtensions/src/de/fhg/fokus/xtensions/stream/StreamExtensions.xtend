/*******************************************************************************
 * Copyright (c) 2017 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.stream

import java.util.Collection
import java.util.List
import java.util.Objects
import java.util.Set
import java.util.function.Supplier
import java.util.stream.Stream

import static extension de.fhg.fokus.xtensions.iteration.IterableExtensions.*
import static java.util.stream.Collectors.*
import java.util.function.Predicate
import java.util.function.UnaryOperator
import java.util.Iterator
import java.util.NoSuchElementException
import java.util.stream.StreamSupport
import java.util.Optional
import java.util.Spliterators
import java.util.Spliterator
import java.util.Comparator

/**
 * This class provides static extension methods for the {@link Stream} class.
 */
final class StreamExtensions {
	
// TODO
// static def <T, Z> Stream<Pair<T, Z>> combinations(Stream<T> stream, Iterable<Z> combineWith, BiPredicate<T,Z> where)
// static def <T, Z> Stream<Pair<T, Z>> combinations(Stream<T> stream, ()=>Stream<Z> streamSupplier, BiPredicate<T,Z> where) 
// static def <T, Z, R> Stream<R> combinations(Stream<T> stream, Iterable<Z> combineWith, (T, Z)=>R combiner, BiPredicate<T,Z> where)
// static def <T, Z, R> Stream<R> combinations(Stream<T> stream, ()=>Stream<Z> streamSupplier, (T, Z)=>R combiner, BiPredicate<T,Z> where)	
// static def <T> IntStream flatMap(Stream<T> stream, (T)=>IntIterable mapper) // etc. for long, double, boolean
// static def <T> Stream<T> without(Stream<T>, Collection<?> other) // Note most performant using Set as other
// JDK9 support: static def <T> Stream<T> ofNullable​(Class<Stream> clazz, T t)
// "Unification" with Xtend APIs:
// static def <T> boolean exists(Stream<T> stream, Predicate<? super T> test) // alias for anyMatch
// static def <T> Stream<T> take(Stream<T> stream, long limit) // alias for limit
// static def <T> Stream<T> drop(Stream<T> stream, long limit) // alias for skip
// static def <T> Optional<T> head(Stream<T> stream) // alias for findFirst
// static def <T> Stream<T> tail(Stream<T> stream) // alias for skip(1)
// static def <T, K> Map<K,List<T>> groupBy(Stream<T> stream, Function<? super T, ? extends K> grouping) // shortcut for stream.collect(Collectors.groupingBy(grouping))
	
	private new() {
		throw new IllegalStateException
	}
	
	/**
	 * This method provides a convenient way to {@link Stream#flatMap(Function) flatMap} on a {@code Stream} by providing an 
	 * {@code Iterable} instead of a {@code Stream}. If a given {@code Iterable} is instance of 
	 * {@link Collection}, the {@code stream()} method of the interface will be called.
	 * 
	 * @param stream the input stream; each element will be passed to {@code flatMapper}. The resulting
	 *  elements will be concatenated to a flat {@code Stream} containing all elements of the returned
	 *  {@code Iterable}s.
	 * @param flatMapper function returning an {@code Iterable} for each element in {@code stream}.
	 * @param <T> Type of elements provided by {@code stream}.
	 * @param <U> Type of elements {@code flatMapper} maps to from {@code T}.
	 * @return Stream concatenating all elements returned by {@code flatMapper} for each elements
	 *  provided by {@code stream}.
	 * @throws NullPointerException if {@code stream} or {@code flatMapper} is {@code null}, or if 
	 *   {@code flatMapper} returns a {@code null} object.
	 */
	static def <T,U> Stream<U> flatMap(Stream<T> stream, (T)=>Iterable<? extends U> flatMapper) {
		Objects.requireNonNull(flatMapper)
		stream.flatMap[flatMapper.apply(it).stream]
	}

	// ////////////////
	// More filters //
	// ////////////////
	/**
	 * Filters the given Stream {@code input} to only contain elements instance
	 * of the given class {@code clazz}. Note that the returned stream is of type
	 * {@code Stream<U>}, so a stream of the the class it is filtered by.
	 * @param input to be filtered to only contain instances of {@code clazz}
	 * @param clazz object of the class the {@code input} should be filtered for.
	 * @param <T> Type of elements provided by {@code stream}.
	 * @param <U> Type, elements in {@code input} are checked to be. The resulting stream only 
	 *   contains elements of that type.
	 * @return {@code input} Stream filtered to only contain instances of {@code clazz}.
	 */
	static def <T, U> Stream<U> filter(Stream<T> input, Class<? extends U> clazz) {
		Objects.requireNonNull(input)
		Objects.requireNonNull(clazz)
		input.filter[clazz.isInstance(it)] as Stream<U>
	}
	
	/**
	 * This method is a shortcut for {@code stream.filter(test).findFirst()}.
	 * Meaning this operation will try to find the fist element in the stream
	 * matching the given {@code test}. If such an element is found, the returned
	 * Optional will have the found element present. Otherwise an empty Optional
	 * will be returned.
	 * @param stream the stream that will be searched for an element matching 
	 *  the {@code test}
	 * @param test the predicate checking for an matching element. An element
	 *  is considered a match when the test returns {@code true} for a given
	 *  element. If {@code test} throws an exception this exception will be 
	 *  thrown from this method.
	 * @param <T> Type of elements in {@code stream}.
	 * @return an optional either holding the element found in {@code stream}
	 *  or an empty optional if no element matched {@code test}.
	 * @throws NullPointerException if {@code stream} or {@code test} is {@code null}
	 */
	static def <T> Optional<T> findFirst(Stream<T> stream, Predicate<T> test) {
		Objects.requireNonNull(stream)
		Objects.requireNonNull(test)
		stream.filter(test).findFirst
	}
	
	/**
	 * This method is a shortcut for {@code stream.filter(test).findAny()}.
	 * Meaning this operation will try to find the an element in the stream
	 * matching the given {@code test}. If such an element is found, the returned
	 * Optional will have the found element present. Otherwise an empty Optional
	 * will be returned.
	 * @param stream the stream that will be searched for an element matching 
	 *  the {@code test}
	 * @param test the predicate checking for an matching element. An element
	 *  is considered a match when the test returns {@code true} for a given
	 *  element. If {@code test} throws an exception this exception will be 
	 *  thrown from this method.
	 * @param <T> Type of elements in {@code stream}.
	 * @return an optional either holding the element found in {@code stream}
	 *  or an empty optional if no element matched {@code test}.
	 * @throws NullPointerException if {@code stream} or {@code test} is {@code null}
	 */
	static def <T> Optional<T> findAny(Stream<T> stream, Predicate<T> test) {
		Objects.requireNonNull(stream)
		Objects.requireNonNull(test)
		stream.filter(test).findAny
	}
	
	/**
	 * This is a shortcut for {@code stream.min(Comparator.naturalOrder())}. 
	 * This extension method conveniently seaches the minimum element according
	 * to the order implemented via the {@code Comparable} interface the elements
	 * of the stream implement.
	 * @param stream the stream to be reduced to the minimum element.
	 * @param <T> Type of elements in {@code stream}.
	 * @return an Optional holding the minimum element of the stream, 
	 *   or an empty optional if the stream is empty.
	 */
//	 @Inline(value="$1.min(Comparator.naturalOrder())", imported=Comparator)
	static def <T extends Comparable<? super T>> Optional<T> min(Stream<T> stream) {
		stream.min(Comparator.naturalOrder)
	}
	
	/**
	 * This is a shortcut for {@code stream.max(Comparator.naturalOrder())}. 
	 * This extension method conveniently seaches the maximum element according
	 * to the order implemented via the {@code Comparable} interface the elements
	 * of the stream implement.
	 * @param stream the stream to be reduced to the maximum element.
	 * @param <T> Type of elements in {@code stream}.
	 * @return an Optional holding the maximum element of the stream, 
	 *   or an empty optional if the stream is empty.
	 */
//	 @Inline(value="$1.max(Comparator.naturalOrder())", imported=Comparator)
	static def <T extends Comparable<? super T>> Optional<T> max(Stream<T> stream) {
		stream.max(Comparator.naturalOrder)
	}

	/**
	 * Filters a {@code stream} to not include {@code null} values.
	 * @param stream the stream to be filtered to exclude {@code null} values.
	 * @param <T> Type of elements in {@code stream}.
	 * @return filtered stream
	 */
	static def <T> Stream<T> filterNull(Stream<T> stream) {
		Objects.requireNonNull(stream)
		// When method references supported use Objects#nonNull
		stream.filter[it !== null]
	}

	// ///////////////////////////////////
	// Shortcuts for common collectors //
	// ///////////////////////////////////
	/**
	 * This function is a simple shortcut for {@code stream.collect(Collectors.toList())}.
	 * @param stream the stream to be collected into a new {@code List}.
	 * @param <T> Type of elements in {@code stream}.
	 * @return List containing all values from {@code stream}
	 */
//	@Inline(value="$1.collect(Collectors.toList())", imported=Collectors)
	static def <T> List<T> toList(Stream<T> stream) {
		stream.collect(toList)
	}

	/**
	 * This function is a simple shortcut for {@code stream.collect(Collectors.toSet())}.
	 * @param stream the stream to be collected into a new {@code Set}.
	 * @param <T> Type of elements in {@code stream}.
	 * @return Set containing all values from {@code stream}
	 */
//	@Inline(value="$1.collect(Collectors.toSet())", imported=Collectors)
	static def <T> Set<T> toSet(Stream<T> stream) {
		stream.collect(toSet)
	}

	/**
	 * This function is a simple shortcut for {@code stream.collect(Collectors.toCollection(collectionFactory))}.
	 * Means that all elements of {@code stream} are added to the collection supplied by {@code collectionFactory}.
	 * @param stream the stream to be collected into a new {@code Set}.
	 * @param collectionFactory a {@code Supplier} which returns a new, empty
     * {@code Collection} (of an arbitrary sub-type) supporting mutation.
	 * @param <T> Type of elements in {@code stream}.
	 * @param <C> Type of (mutable) collection all elements of {@code stream} are added to.
	 * @return Set containing all values from {@code stream}
	 */
//	@Inline(value="$1.collect(Collectors.toCollection($2))", imported=Collectors)
	static def <T, C extends Collection<T>> C toCollection(Stream<T> stream, Supplier<C> collectionFactory) {
		stream.collect(toCollection(collectionFactory))
	}

	// ///////////////
	// Combinations //
	// ///////////////
	/**
	 * This function returns a stream of the Cartesian product of {@code stream} and the iterable {@code combineWith}.
	 * Note that this function will multiple times try to create a stream from the Iterable {@code combineWith}. The 
	 * combination of elements of the {@code stream} and {@code combineWith} are represented as {@link Pair}s of the 
	 * values from both sources.
	 * @param stream the stream that's elements are combined with every elements from {@code combineWith}
	 * @param combineWith the elements to be combined with each element from {@code stream}
	 * @param <T> Type of elements in {@code stream}.
	 * @param <Z> Type of elements in {@code combineWith}.
	 * @return stream of combinations of all elements from {@code stream} with every element of {@code combineWith}.
	 */
	static def <T, Z> Stream<Pair<T, Z>> combinations(Stream<T> stream, Iterable<Z> combineWith) {
		Objects.requireNonNull(combineWith);
		stream.flatMap[t|combineWith.stream.map[t -> it]]
	}

	/**
	 * This function returns a stream of the Cartesian Product of {@code stream} and the elements of the stream
	 * provided by {@code streamSupplier}.
	 * Note that this function will call {@code streamSupplier} for each element in {@code stream}, so it is expected
	 * that on every call the given {@code streamSupplier} returns a stream of the same elements. The 
	 * combination of elements of the {@code stream} and the stream provided by {@code streamSupplier} are represented 
	 * as {@link Pair}s of the values from both sources.
	 * @param stream the stream that's elements are combined with every elements from {@code combineWith}
	 * @param streamSupplier the elements to be combined with each element from {@code stream}
	 * @param <T> Type of elements in {@code stream}.
	 * @param <Z> Type of elements provided by stream, provided by {@code streamSupplier}
	 * @return stream of combinations of all elements from {@code stream} with every element of the stream provided by {@code streamSupplier}.
	 */
	static def <T, Z> Stream<Pair<T, Z>> combinations(Stream<T> stream, ()=>Stream<Z> streamSupplier) {
		Objects.requireNonNull(streamSupplier);
		stream.flatMap[t|streamSupplier.apply.map[t -> it]]
	}

	/**
	 * This function returns a stream of the Cartesian product of {@code stream} and the iterable {@code combineWith}.
	 * Note that this function will multiple times try to create a stream from the Iterable {@code combineWith}. Every 
	 * combination of elements of the {@code stream} and {@code combineWith} will be passed to the {@code combiner} to
	 * create a resulting combined element.
	 * @param stream the stream that's elements are combined with every elements from {@code combineWith}
	 * @param combineWith the elements to be combined with each element from {@code stream}
	 * @param combiner will be used to combine elements from {@code stream} and {@code combineWith} to result values.
	 * @param <T> Type of elements in {@code stream}.
	 * @param <Z> Type of elements in {@code combineWith}.
	 * @param <R> Result type of {@code combiner} function, which fuses a {@code T} and a {@code Z} object to one instance of {@code R}.
	 * @return stream of combinations of all elements from {@code stream} with every element of {@code combineWith} 
	 *   combined by using the {@code combiner} function.
	 */
	static def <T, Z, R> Stream<R> combinations(Stream<T> stream, Iterable<Z> combineWith, (T, Z)=>R combiner) {
		Objects.requireNonNull(combineWith);
		stream.flatMap[t|combineWith.stream.map[combiner.apply(t, it)]]
	}


	/**
	 * This function returns a stream of the Cartesian product of {@code stream} and the elements of the stream
	 * provided by {@code streamSupplier}.
	 * Note that this function will call {@code streamSupplier} for each element in {@code stream}, so it is expected
	 * that on every call the given {@code streamSupplier} returns a stream of the same elements. Every 
	 * combination of elements of the {@code stream} and elements of stream provided by {@code streamSupplier} will be 
	 * passed to the {@code combiner} to create a resulting combined element.
	 * @param stream the stream that's elements are combined with every elements from {@code combineWith}
	 * @param streamSupplier the elements to be combined with each element from {@code stream}
	 * @param combiner will be used to combine elements from {@code stream} and stream provided by {@code streamSupplier} to result values.
	 * @param <T> Type of elements in {@code stream}.
	 * @param <Z> Type of elements in stream, provided by {@code streamSupplier}.
	 * @param <R> Result type of {@code combiner} function, which fuses a {@code T} and a {@code Z} object to one instance of {@code R}.
	 * @return stream of combinations of all elements from {@code stream} with every element of the stream provided by {@code streamSupplier}
	 *   combined by using the {@code combiner} function.
	 */
	static def <T, Z, R> Stream<R> combinations(Stream<T> stream, ()=>Stream<Z> streamSupplier, (T, Z)=>R combiner) {
		Objects.requireNonNull(streamSupplier);
		stream.flatMap[t|streamSupplier.apply.map[combiner.apply(t, it)]]
	}

	// /////////////////
	// Concatenation //
	// /////////////////
	
	/**
	 * Operator shortcut for {@link Stream#concat(Stream,Stream) Stream.concat(first,second)}.
	 * @param first containing the elements first provided by the resulting Stream
	 * @param second elements provided by the resulting stream after the elements of {@code first}.
	 * @param <T> Type of resulting concatinated stream. Both input streams must provide {@code T} objects, or objects of sub-types of {@code T}.
	 * @return lazily concatenated stream of {@code first} and {@code second}
	 */
//	@Inline(value = "Stream.concat($1,$2)", imported=Stream)
	static def <T> Stream<T> +(Stream<? extends T> first, Stream<? extends T> second) {
		Stream.concat(first, second)
	}
	
	//////////////////
	// Construction //
	//////////////////
	
	/**
	 * This method provides functionality that is directly available on the Java 9 Stream class.<br>
	 * This method will construct a Stream that provides {@code seed} as an initial element. Elements will
	 * only be provided if {@code hasNext} returns {@code true} when applied to the element. If {@code hasNext}
	 * returns {@code false} for the initial element the returned Stream will be empty. 
	 * The next value(s) provided by the stream will be computed by the previous element using the {@code next}
	 * function. The stream will terminate and not provide this element if {@code hasNext} does not hold for
	 * this element.
	 * @param seed first element returned by the stream and seed for following elements by using {@code next}.
	 * @param hasNext before each element is provided (except for the first one)
	 * @param next operation providing the next element
	 * @param <T> Type of elements of produced stream
	 * @return Stream providing elements computing by {@code seed}, {@code hasNext}, and {@code next}.
	 */
	static def <T> Stream<T> iterate​(T seed, Predicate<? super T> hasNext, UnaryOperator<T> next) {
		val nextOp = next
		val hasNextPred = hasNext
		val iter = new Iterator<T>() {
			var nextVal = seed
			
			override hasNext() {
				hasNextPred.test(nextVal)
			}
			
			override next() {
				val result = nextVal
				if(!hasNextPred.test(result)) {
					throw new NoSuchElementException()
				}
				nextVal = nextOp.apply(result)
				result
			}
		}
		val characteristics = Spliterator.ORDERED.bitwiseOr(Spliterator.IMMUTABLE)
		val split = Spliterators.spliteratorUnknownSize(iter, characteristics);
		StreamSupport.stream(split, false)
	}
	
	/**
	 * This method redirects to {@link #iterate​(Object, Predicate, UnaryOperator) &lt;T&gt;iterate​(T, Predicate&lt;? super T&gt;, UnaryOperator&lt;T&gt;)}.<br>
	 * This allows e.g. writing {@code Stream.iterate(0,[it<100],[it+1])} in Xtend, which does not require code changes when
	 * switching to Java 9 to take advantage of the native implementation of this method.
	 * @param clazz will be ignored
	 * @param seed first element returned by the stream and seed for following elements by using {@code next}.
	 * @param hasNext before each element is provided (except for the first one)
	 * @param next operation providing the next element
	 * @param <T> Type of elements of produced stream
	 * @return Stream providing elements computing by {@code seed}, {@code hasNext}, and {@code next}.
	 * @see #iterate​(Object, Predicate, UnaryOperator)
	 */
	static def <T> Stream<T> iterate​(Class<Stream> clazz, T seed, Predicate<? super T> hasNext, UnaryOperator<T> next) {
		iterate​(seed,hasNext, next)
	}

}
