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

/**
 * This class provides static extension methods for the {@link Stream} class.
 */
final class StreamExtensions {
	
	private new() {
		throw new IllegalStateException
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
	 * @return {@code input} Stream filtered to only contain instances of {@code clazz}.
	 */
	static def <T, U> Stream<U> filter(Stream<T> input, Class<? extends U> clazz) {
		Objects.requireNonNull(input)
		Objects.requireNonNull(clazz)
		input.filter[clazz.isInstance(it)] as Stream<U>
	}

	/**
	 * Filters a {@code stream} to not include {@code null} values.
	 * @param stream the stream to be filtered to exclude {@code null} values.
	 * @return filtered stream
	 */
	static def <T> Stream<T> filterNull(Stream<T> stream) {
		Objects.requireNonNull(stream)
		stream.filter[it !== null]
	}

	// ///////////////////////////////////
	// Shortcuts for common collectors //
	// ///////////////////////////////////
	/**
	 * This function is a simple shortcut for {@code stream.collect(Collectors.toList())}.
	 * @param stram the stream to be collected into a new {@code List}.
	 * @return List containing all values from {@code stream}
	 */
//	@Inline(value="$1.collect(Collectors.toList())", imported=Collectors)
	static def <T> List<T> toList(Stream<T> stream) {
		stream.collect(toList)
	}

	/**
	 * This function is a simple shortcut for {@code stream.collect(Collectors.toSet())}.
	 * @param stram the stream to be collected into a new {@code Set}.
	 * @return Set containing all values from {@code stream}
	 */
//	@Inline(value="$1.collect(Collectors.toSet())", imported=Collectors)
	static def <T> Set<T> toSet(Stream<T> stream) {
		stream.collect(toSet)
	}

	/**
	 * This function is a simple shortcut for {@code stream.collect(Collectors.toCollection(collectionFactory))}.
	 * Means that all elements of {@code stream} are added to the collection supplied by {@code collectionFactory}.
	 * @param stram the stream to be collected into a new {@code Set}.
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
	 * @return stream of combinations of all elements from {@code stream} with every element of {@code combineWith}.
	 */
	static def <T, Z> Stream<Pair<T, Z>> combinations(Stream<T> stream, Iterable<Z> combineWith) {
		Objects.requireNonNull(combineWith);
		stream.flatMap[t|combineWith.stream.map[t -> it]]
	}

	/**
	 * This function returns a stream of the Cartesian product of {@code stream} and the elements of the stream
	 * provided by {@code streamSupplier}.
	 * Note that this function will call {@code streamSupplier} for each element in {@code stream}, so it is expected
	 * that on every call the given {@code streamSupplier) returns a stream of the same elements. The 
	 * combination of elements of the {@code stream} and the stream provided by {@code streamSupplier} are represented 
	 * as {@link Pair}s of the values from both sources.
	 * @param stream the stream that's elements are combined with every elements from {@code combineWith}
	 * @param streamSupplier the elements to be combined with each element from {@code stream}
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
	 * that on every call the given {@code streamSupplier) returns a stream of the same elements. Every 
	 * combination of elements of the {@code stream} and elements of stream provided by {@code streamSupplier} will be 
	 * passed to the {@code combiner} to create a resulting combined element.
	 * @param stream the stream that's elements are combined with every elements from {@code combineWith}
	 * @param streamSupplier the elements to be combined with each element from {@code stream}
	 * @param combiner will be used to combine elements from {@code stream} and stream provided by {@code streamSupplier} to result values.
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
	 * @return Stream providing elements computing by {@code seed}, {@code hasNext}, and {@code next}.
	 */
	static def <T> Stream<T> iterate​(T seed, Predicate<? super T> hasNext, UnaryOperator<T> next) {
		val nextOp = next
		val hasNextPred = hasNext
		val Iterable<T> iterable = [new Iterator<T>() {
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
		]
		StreamSupport.stream(iterable.spliterator, false)
	}
	
	/**
	 * This method redirects to {@link StreamExtensions#iterate​(Object, Predicate, UnaryOperator) iterate​(Object, Predicate, UnaryOperator)}.<br>
	 * This allows e.g. writing {@code Stream.iterate(0,[it<100],[it+1])} in Xtend, which does not require code changes when
	 * switching to Java 9 to take advantage of the native implementation of this method.
	 * @see StreamExtensions#iterate​(Object, Predicate, UnaryOperator)
	 */
	static def <T> Stream<T> iterate​(Class<Stream> clazz, T seed, Predicate<? super T> hasNext, UnaryOperator<T> next) {
		iterate​(seed,hasNext, next)
	}

// TODO
// Collector GetOnlyElement => Stream#getOnlyElement() -> Optional<T>
// Stream<Iterable>#flatten //?? needed?
// Stream<T>#forEach with index (check parallel! Use AtomicLong with getAndIncrement )
// Stream<T>#forEachOrdered indexed (check parallel!)
// Stream<T>#indexed():Stream<Pair<int,T>> (check parallel!)
// Stream<T>#zip(Iterable<? extends V>):Stream<Pair<T,V>> : call zip(iterable.spliterator())
// Stream<T>#zip(Stream<V>) : Stream<Pair<T,V>>: call zip(stream.spliterator())
// Stream<T>#zip(Spliterator<V>) :  Stream<Pair<T,V>> create new based spliterator on both and stream from spliterator, maybe thorw if one source not ordered
// zip variants with BiFunction<T,V,R> returning Stream<V>
// static def <T, Z> Stream<Pair<T, Z>> combinations(Stream<T> stream, Iterable<Z> combineWith, BiPredicate<T,Z> where)
// static def <T, Z> Stream<Pair<T, Z>> combinations(Stream<T> stream, ()=>Stream<Z> streamSupplier, BiPredicate<T,Z> where) 
// static def <T, Z, R> Stream<R> combinations(Stream<T> stream, Iterable<Z> combineWith, (T, Z)=>R combiner, BiPredicate<T,Z> where)
// static def <T, Z, R> Stream<R> combinations(Stream<T> stream, ()=>Stream<Z> streamSupplier, (T, Z)=>R combiner, BiPredicate<T,Z> where)
}
