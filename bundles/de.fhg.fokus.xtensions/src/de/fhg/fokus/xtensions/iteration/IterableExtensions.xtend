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
package de.fhg.fokus.xtensions.iteration

import java.util.Collection
import java.util.Objects
import java.util.stream.Stream
import java.util.stream.StreamSupport
import java.util.stream.Collector
import java.util.function.ToIntFunction
import java.util.function.IntConsumer
import static extension java.util.Objects.*
import java.util.function.ToLongFunction
import java.util.function.LongConsumer
import java.util.function.ToDoubleFunction
import java.util.function.DoubleConsumer
import static extension de.fhg.fokus.xtensions.iteration.IteratorExtensions.*

/**
 * Additional extension functions for the {@link Iterable} class.
 */
final class IterableExtensions {

// static def <T,V> Iterable<Pair<T,V>> zip(Iterable<? extends T>, Iterable<? extends V>)
// static def <T,V,Y> Iterable<Y> zip(Iterable<? extends T>, Iterable<? extends V>, (T,V)=>Y merger)
// static def <X,Y> Iterable<Pair<X,Y>> combinations(Iterable<X>,Iterable<Y>)
// static def <X,Y> Iterable<Pair<X,Y>> combinations(Iterable<X>,Iterable<Y>, BiPredicate<X,Y>)
// static def <T> List<T> toImmutableList(Iterable<T>)
// static def <T> Iterable<T> peek(Iterable<T>,(T)=>void action)
// static def <T> Map<Boolean,List<T>> partitionBy(Iterable<T>, Predicate<T>) // Own impl of Map extending AbstractMap
// static def <T, A, C> Map<Boolean,C> partitionBy(Iterable<T>, Collector<? super T,A,C>, Predicate<T>) // Own impl of Map extending AbstractMap, maybe provide as Collector
// Maybe interface Partitions<T,C> extends Map<Boolean,C> { def C getTrue(); def C getFalse(); } // avoids boxing integers

// static def <T> ClassGrouping groupBy(Iterable<T>, Class<?>... classes) // extend HashMap, maybe provide as Collector
// interface ClassGrouping { 
//  List<Class<?>> getGroupingClasses();
// 	<T> List<T> get(Class<T> clazz) throws NoSuchElementException;
//	Map<Class<?>,List<?>> asMap(); // will be immutable view
// }

// static def <T,Y> Pair<List<Y>,List<T>> partitionBy(Iterable<T>, Class<Y>)
// static def <T,Y,AT,AY,DT,DY> Pair<DY,DT> partitionBy(Iterable<T>, Class<Y>, Collector<? super T, AT, DT>, Collector<? super Y, AY, DY>)
// static def <T> Iterable<T> without(Iterable<T>, Collection<?> other) // Note most performant using Set as other
	
	private new() {
		throw new IllegalStateException
	}
	
	/**
	 * This function maps an {@link Iterable} to an {@link IntIterable}, using the 
	 * {@code mapper} function for each element of the original {@code iterable}. 
	 * The returned {@code IntIterable} is lazy, only performing
	 * the {@code mapper} function when iterating over the original {@code iterable}
	 * object. If the returned iterable will be traversed multiple times the {@code mapper}
	 * function will be applied multiple times for each element.
	 * @param iterable the {@code Iterable} of which each element should be mapped to {@code int} values.
	 * @param mapper the mapping function, mapping each element of {@code iterable} to an {@code int} value.
	 * @param <T> type of elements in {@code iterable}, that are mapped to {@code int}s via {@code mapper}.
	 * @return an iterable over primitive {@code int} values mapped from the elements of the input {@code iterable}.
	 */
	static def <T> IntIterable mapInt(Iterable<T> iterable, ToIntFunction<T> mapper){
		iterable.requireNonNull
		mapper.requireNonNull
		new IntIterable {
			override iterator() {
				iterable.iterator.mapInt(mapper)
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
	 * object. If the returned iterable will be traversed multiple times the {@code mapper}
	 * function will be applied multiple times for each element.
	 * @param iterable the {@code Iterable} of which each element should be mapped to {@code long} values.
	 * @param mapper the mapping function, mapping each element of {@code iterable} to an {@code long} value.
	 * @param <T> type of elements in {@code iterable}, that are mapped to {@code long}s via {@code mapper}.
	 * @return an iterable over primitive {@code long} values mapped from the elements of the input {@code iterable}.
	 */
	static def <T> LongIterable mapLong(Iterable<T> iterable, ToLongFunction<T> mapper){
		iterable.requireNonNull
		mapper.requireNonNull
		new LongIterable {
			override iterator() {
				iterable.iterator.mapLong(mapper)
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
	 * @param iterable the {@code Iterable} of which each element should be mapped to {@code double} values.
	 * @param mapper the mapping function, mapping each element of {@code iterable} to an {@code double} value.
	 * @param <T> type of elements in {@code iterable}, that are mapped to {@code double}s via {@code mapper}.
	 * @return an iterable over primitive {@code double} values mapped from the elements of the input {@code iterable}.
	 */
	static def <T> DoubleIterable mapDouble(Iterable<T> iterable, ToDoubleFunction<T> mapper){
		iterable.requireNonNull
		mapper.requireNonNull
		new DoubleIterable {
			override iterator() {
				iterable.iterator.mapDouble(mapper)				
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
	 * of the Iterable {@code it}.<br>
	 * If the given {@link Iterable} is instance of {@link Collection}, the 
	 * {@link Collection#stream() stream} method of the Collection interface will
	 * be called. Otherwise uses {@link StreamSupport} to create a Stream with the
	 * Spliterator created using {@link Iterable#spliterator()}.
	 * @param it from which the returned Stream is created
	 * @param <T> type of elements in {@code iterable}, that are being provided by the returning stream.
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
	 * of the Iterable {@code it}.<br>
	 * If the given {@link Iterable} is instance of {@link Collection}, the 
	 * {@link Collection#parallelStream() parallelStream} method of the Collection interface will
	 * be called. Otherwise uses {@link StreamSupport} to create the parallel Stream with the
	 * Spliterator created using {@link Iterable#spliterator()}.
	 * @param it from which the returned Stream is created
	 * @param <T> type of elements in {@code iterable}, that are being provided by the returning stream.
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
	 * @param <T> type of elements in {@code iterable}
	 * @param <A> type of mutable aggregator element used by {@code collector}
	 * @param <R> type of the final element produced by {@code collector} that is being returned.
	 * @return the result value computed via the given {@code collector} over each element 
	 *  in the given {@code data} input.
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
