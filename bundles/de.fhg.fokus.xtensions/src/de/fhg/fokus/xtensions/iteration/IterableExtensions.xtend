package de.fhg.fokus.xtensions.iteration

import java.util.Collection
import java.util.Objects
import java.util.stream.Stream
import java.util.stream.StreamSupport
import java.util.stream.Collector
import java.util.function.ToIntFunction
import java.util.function.IntConsumer
import java.util.PrimitiveIterator.OfInt
import static extension java.util.Objects.*
import java.util.function.ToLongFunction
import java.util.PrimitiveIterator.OfLong
import java.util.function.LongConsumer
import java.util.function.ToDoubleFunction
import java.util.PrimitiveIterator.OfDouble
import java.util.function.DoubleConsumer

/**
 * Additional extension functions for the {@link Iterable} class.
 */
final class IterableExtensions {

// static def <X,Y> Iterable<Pair<X,Y>> combinations(Iterable<X>,Iterable<Y>)
// static def <X,Y> Iterable<Pair<X,Y>> combinations(Iterable<X>,Iterable<Y>, BiPredicate<X,Y>)
// static def <T> List<T> toImmutableList(Iterable<T>)
	
	private new() {
		throw new IllegalStateException
	}
	
	/**
	 * This function maps an {@link Iterable} to an {@link IntIterable}, using the 
	 * {@code mapper} function for each element of the original {@code iterable}. 
	 * The returned {@code IntIterable} is lazy, only performing
	 * the {@code mapper} function when iterating over the original {@code iterable}
	 * object. If the returned iterable will be traversed multiple times 
	 */
	static def <T> IntIterable mapInt(Iterable<T> iterable, ToIntFunction<T> mapper){
		iterable.requireNonNull
		mapper.requireNonNull
		new IntIterable {
			override iterator() {
				// TODO move into IteratorExtensions to allow Iterator#mapInt
				new OfInt {
					val iterator = iterable.iterator
					
					override nextInt() {
						val current = iterator.next
						mapper.applyAsInt(current)
					}
					
					override hasNext() {
						iterator.hasNext
					}
					
				}
			}
			
			override forEachInt(IntConsumer consumer) {
				val iterator = iterable.iterator
				while(iterator.hasNext) {
					val currentBefore = iterator.next
					val current = mapper.applyAsInt(currentBefore)
					consumer.accept(current)
				}
			}
			
			override stream() {
				iterable.stream().mapToInt(mapper)
			}
		}
	}
	
	/**
	 * This function maps an {@link Iterable} to a {@link LongIterable}, using the 
	 * {@code mapper} function for each element of the original {@code iterable}. 
	 * The returned {@code LongIterable} is lazy, only performing
	 * the {@code mapper} function when iterating over the original {@code iterable}
	 * object. If the returned iterable will be traversed multiple times 
	 */
	static def <T> LongIterable mapLong(Iterable<T> iterable, ToLongFunction<T> mapper){
		iterable.requireNonNull
		mapper.requireNonNull
		new LongIterable {
			override iterator() {
				// TODO move into IteratorExtensions to allow Iterator#mapLong
				new OfLong {
					val iterator = iterable.iterator
					
					override nextLong() {
						val current = iterator.next
						mapper.applyAsLong(current)
					}
					
					override hasNext() {
						iterator.hasNext
					}
					
				}
			}
			
			override forEachLong(LongConsumer consumer) {
				val iterator = iterable.iterator
				while(iterator.hasNext) {
					val currentBefore = iterator.next
					val current = mapper.applyAsLong(currentBefore)
					consumer.accept(current)
				}
			}
			
			override stream() {
				iterable.stream().mapToLong(mapper)
			}
		}
	}
	
	/**
	 * This function maps an {@link Iterable} to a {@link DoubleIterable}, using the 
	 * {@code mapper} function for each element of the original {@code iterable}. 
	 * The returned {@code DoubleIterable} is lazy, only performing
	 * the {@code mapper} function when iterating over the original {@code iterable}
	 * object. If the returned iterable will be traversed multiple times 
	 */
	static def <T> DoubleIterable mapDouble(Iterable<T> iterable, ToDoubleFunction<T> mapper){
		iterable.requireNonNull
		mapper.requireNonNull
		new DoubleIterable {
			override iterator() {
				// TODO move into IteratorExtensions to allow Iterator#mapLong
				new OfDouble {
					val iterator = iterable.iterator
					
					override nextDouble() {
						val current = iterator.next
						mapper.applyAsDouble(current)
					}
					
					override hasNext() {
						iterator.hasNext
					}
					
				}
			}
			
			override forEachDouble(DoubleConsumer consumer) {
				val iterator = iterable.iterator
				while(iterator.hasNext) {
					val currentBefore = iterator.next
					val current = mapper.applyAsDouble(currentBefore)
					consumer.accept(current)
				}
			}
			
			override stream() {
				iterable.stream().mapToDouble(mapper)
			}
		}
	}

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

	/** 
	 * Simple implementation reducing the elements of an iterable to a return value
	 * using a {@link Collector}.
	 * @param data the iterable elements should be collected.
	 * @param collector the collector reducing multiple values into a single result value
	 */
	static def <T, A, R> R collect(Iterable<T> data, Collector<? super T, A, R> collector) {
		val supplier = Objects.requireNonNull(collector.supplier)
		val accumulator = Objects.requireNonNull(collector.accumulator)
		val finisher = Objects.requireNonNull(collector.finisher)
		
		val A container = supplier.get()
		for (T t : data) {
			accumulator.accept(container, t)
		}
		return finisher.apply(container)
	}
}
