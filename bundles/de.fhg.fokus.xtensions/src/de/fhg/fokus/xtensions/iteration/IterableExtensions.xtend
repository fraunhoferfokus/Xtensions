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
import java.util.List
import java.util.Objects
import java.util.function.BiPredicate
import java.util.function.DoubleConsumer
import java.util.function.IntConsumer
import java.util.function.LongConsumer
import java.util.function.Predicate
import java.util.function.ToDoubleFunction
import java.util.function.ToIntFunction
import java.util.function.ToLongFunction
import java.util.stream.Collector
import java.util.stream.Stream
import java.util.stream.StreamSupport

import static extension de.fhg.fokus.xtensions.iteration.IteratorExtensions.*
import static extension java.util.Objects.*

/**
 * Additional extension functions for the {@link Iterable} class.
 */
final class IterableExtensions {

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
	
	/**
	 * Groups the elements in {@code iterable} into sets by the classes given via parameters {@code firstGroup}, {@code firstGroup}, and {@code additionalGroups}.
	 * The elements will be checked to be instance of the given classes in the 
	 * order they appear in the parameter list. So if e.g. classes {@code Object} and {@code String}
	 * are passed into the function in this order, an instance of {@code String} will land
	 * in the group of {@code Object}. Also note that objects that are not matching any given class
	 * are simply omitted from the resulting grouping. If you need a group for all objects that 
	 * were not matched, just pass in the class of {@code Object} as the last parameter.
	 * @param iterable the iterable, that provides the elements to be be grouped into sets by the given classes
	 * @param firstGroup first class elements of {@code iterable} are be grouped by
	 * @param secondGroup first class elements of {@code iterable} are be grouped by
	 * @param additionalGroups further classes to group elements by. This parameter is allowed to be {@code null}.
	 * @return a grouping of elements by the classes, provided via the parameters {@code firstGroup}, {@code firstGroup}, and {@code additionalGroups}
	 * @see IterableExtensions#partitionBy(Iterable, Class)
	 * @see IterableExtensions#partitionBy(Iterable, Class, Collector, Collector)
	 * @since 1.1.0.
	 */
	static def ClassGroupingSet groupIntoSetBy(Iterable<?> iterable, Class<?> firstGroup, Class<?> secondGroup, Class<?>... additionalGroups) {
		val iterator = iterable.iterator
		iterator.groupIntoSetBy(firstGroup, secondGroup, additionalGroups)
	}
	
	/**
	 * Groups the elements in {@code iterable} into lists by the classes given via parameters {@code firstGroup}, {@code firstGroup}, and {@code additionalGroups}.
	 * The elements will be checked to be instance of the given classes in the 
	 * order they appear in the parameter list. So if e.g. classes {@code Object} and {@code String}
	 * are passed into the function in this order, an instance of {@code String} will land
	 * in the group of {@code Object}. Also note that objects that are not matching any given class
	 * are simply omitted from the resulting grouping. If you need a group for all objects that 
	 * were not matched, just pass in the class of {@code Object} as the last parameter.
	 * @param iterable the iterable, that provides the elements to be be grouped into sets by the given classes
	 * @param firstGroup first class elements of {@code iterable} are be grouped by
	 * @param secondGroup first class elements of {@code iterable} are be grouped by
	 * @param additionalGroups further classes to group elements by. This parameter is allowed to be {@code null}.
	 * @return a grouping of elements by the classes, provided via the parameters {@code firstGroup}, {@code firstGroup}, and {@code additionalGroups}.
	 * @see IterableExtensions#partitionBy(Iterable, Class)
	 * @see IterableExtensions#partitionBy(Iterable, Class, Collector, Collector)
	 * @since 1.1.0
	 */
	static def ClassGroupingList groupIntoListBy(Iterable<?> iterable, Class<?> firstGroup, Class<?> secondGroup, Class<?>... additionalGroups) {
		val iterator = iterable.iterator
		iterator.groupIntoListBy(firstGroup, secondGroup, additionalGroups)
	}
	
	/**
	 * Filters the given {@code iterable} by filtering all elements out that are also included
	 * in the given {@code Iterable toExclude}. If an element from {@code iterable} is {@code null} it is removed 
	 * if {@code toExclude} also contains a {@code null} value. Otherwise elements {@code e} from 
	 * {@code iterable} are only removed, if {@code toExclude} contains an element {@code o}, where {@code e.equals(o)}.
	 * @param iterable the iterable to be filtered. Must not be {@code null}.
	 * @param toExclude the elements not to be included in the resulting iterable. Must not be {@code null}.
	 * @param <T> Type of elements in {@code iterable}
	 * @return filtered {@code iterable} not containing elements from {@code toExclude}.
	 * @throws NullPointerException will be thrown if {@code iterable} or {@code toExclude} is {@code null}.
	 * @since 1.1.0
	 */
	static def <T> Iterable<T> withoutAll(Iterable<T> iterable, Iterable<?> toExclude) {
		iterable.requireNonNull
		toExclude.requireNonNull;
		[iterable.iterator.withoutAll(toExclude)]
	}
	
	
	/**
	 * This function returns a new Iterable providing the elements of the Cartesian Product of the elements provided 
	 * by {@code iterable} and the elements of the {@code other}. The 
	 * combination of elements of the {@code iterable} and the {@code other} are represented 
	 * as {@link Pair}s of the values from both sources.
	 * 
	 * @param iterable the iterable that's elements are combined with every elements from {@code other}. Must not be {@code null}.
	 * @param other the elements to be combined with each element from {@code iterable}. Must not be {@code null}.
	 * @param <X> Type of elements in {@code iterable}.
	 * @param <Y> Type of elements provided by {@code other}
	 * @return iterable of combinations of all elements from {@code iterable} with every element of the elements provided by {@code other}.
	 * @throws NullPointerException is thrown if {@code iterable} or {@code other} is {@code null}
	 * @since 1.1.0
	 */
	static def <X, Y> Iterable<Pair<X, Y>> combinations(Iterable<X> iterable, Iterable<Y> other) {
		iterable.requireNonNull("iterable")
		other.requireNonNull("other");
		[iterable.iterator.combinations(other)]
	}
	
	/**
	 * This function returns a new Iterable providing the elements of the Cartesian Product of the elements provided 
	 * by {@code iterable} and the elements of the {@code other}. The 
	 * combination of elements of the {@code iterable} and the {@code other} are computed using the {@code merger}
	 * function.
	 * 
	 * @param iterable the iterable that's elements are combined with every elements from {@code other}. Must not be {@code null}.
	 * @param other the elements to be combined with each element from {@code iterable}. Must not be {@code null}.
	 * @param merger the function combining the elements from {@code iterable} and {@code other}.
	 * @param <X> Type of elements in {@code iterable}.
	 * @param <Y> Type of elements provided by {@code other}
	 * @param <Z> Type of the merged elements
	 * @return Iterable of combinations of all elements from {@code iterable} with every element of the elements provided by {@code other}.
	 * @throws NullPointerException is thrown if {@code iterable}, or {@code other}, or {@code merger} is {@code null}
	 * @since 1.1.0
	 */
	static def <X,Y,Z> Iterable<Z> combinations(Iterable<X> iterable, Iterable<Y> other, (X,Y)=>Z merger) {
		other.requireNonNull("other")
		merger.requireNonNull("merger")
		iterable.requireNonNull("iterable");
		[iterable.iterator.combinations(other,merger)]
	}
	
	/**
	 * This function returns a new Iterable providing the elements of the Cartesian Product of the elements provided 
	 * by {@code iterable} and the elements of the {@code other}. A combination of values from {@code iterable} and 
	 * {@code other} will only be included in the resulting iterable, if the {@code where} predicate holds true for
	 * the combination. The combination of elements are represented as {@link Pair}s of the values from both sources.
	 * 
	 * @param iterable the iterable that's elements are combined with every elements from {@code other}. Must not be {@code null}.
	 * @param other the elements to be combined with each element from {@code iterable}. Must not be {@code null}.
	 * @param where a filtering predicate to only produce combinations for which this predicate holds true. Must not be {@code null}.
	 * @param <X> Type of elements in {@code iterable}.
	 * @param <Y> Type of elements provided by {@code other}
	 * @return iterable of combinations of all elements from {@code iterable} with every element of the elements provided by {@code other} 
	 *  for which the {@code where} predicate holds true.
	 * @throws NullPointerException is thrown if {@code iterable}, or {@code other} or {@code where} is {@code null}
	 * @since 1.1.0
	 */
	static def <X,Y> Iterable<Pair<X,Y>> combinationsWhere(Iterable<X> iterable, Iterable<Y> other, BiPredicate<X,Y> where) {
		other.requireNonNull("other")
		where.requireNonNull("where")
		iterable.requireNonNull("iterable");
		[iterable.iterator.combinationsWhere(other,where)]
	}
	

	/**
	 * This function returns a new Iterable providing the elements of the Cartesian Product of the elements provided 
	 * by {@code iterable} and the elements of the {@code other}. A combination of values from {@code iterable} and 
	 * {@code other} will only be included in the resulting iterable, if the {@code where} predicate holds true for
	 * the combination. The combination of elements of the {@code iterable} and the {@code other} are computed using 
	 * the {@code merger} function.
	 * 
	 * @param iterable the iterable that's elements are combined with every elements from {@code other}. Must not be {@code null}.
	 * @param other the elements to be combined with each element from {@code iterable}. Must not be {@code null}.
	 * @param where a filtering predicate to only produce combinations for which this predicate holds true. Must not be {@code null}.
	 * @param merger the function combining the elements from {@code iterable} and {@code other}.
	 * @param <X> Type of elements in {@code iterable}.
	 * @param <Y> Type of elements provided by {@code other}
	 * @param <Z> Type of the merged elements
	 * @return iterable of combinations of all elements from {@code iterable} with every element of the elements provided by {@code other} 
	 *  for which the {@code where} predicate holds true. The elements are a result of the {@code merger} call for each combination
	 * @throws NullPointerException is thrown if {@code iterable}, or {@code other}, or {@code where}, or {@code merger} is {@code null}
	 * @since 1.1.0
	 */
	static def <X,Y,Z> Iterable<Z> combinationsWhere(Iterable<X> iterable, Iterable<Y> other, BiPredicate<X,Y> where, (X,Y)=>Z merger) {
		iterable.requireNonNull("iterable")
		other.requireNonNull("other")
		where.requireNonNull("where")
		merger.requireNonNull("merger");
		[iterable.iterator.combinationsWhere(other,where,merger)]
	}
	
	/**
	 * This method partitions the elements in {@code iterable} into elements instance of {@code selectionClass}
	 * and elements that are not. The returned partition holds the elements instance of {@code selectionClass} 
	 * in the selected partition and the other elements in the rejected partition. Partitions are Lists of the 
	 * elements. The relative order of the elements in {@code iterable} is preserved in the respective partitions. 
	 * There is no guarantee about mutability or thread safety of the list partitions. If there is no element
	 * selected or rejected, the respective parts will hold an empty List; the parts are guaranteed to be not {@code null}.
	 * @param iterable source iterable, that's elements are partitioned based on {@code selectionClass}
	 * @param selectionClass the class elements in {@code iterable} are checked to be instance of. Elements 
	 *   that are instance of {@code selectionClass} will be added to the selected partition of the result.
	 *   Elements that are not, will end up in the rejected partition.
	 * @param <X> Type of elements in {@code iterable}
	 * @param <Y> Type of elements that are part of {@code iterable} and will be put into the resulting selected partition.
	 * @return partition of elements in {@code iterable}, providing the selected elements, that are instance of {@code selectionClass}, and rejected elements
	 *  not instance of {@code selectionClass}.
	 * @throws NullPointerException if {@code iterable} or {@code selectionClass} is {@code null}
	 * @see IterableExtensions#groupIntoListBy(Iterable, Class, Class,Class[])
	 * @see IterableExtensions#groupIntoSetBy(Iterable, Class, Class,Class[])
	 * @since 1.1.0
	 */
	static def <X,Y> Partition<List<Y>,List<X>> partitionBy(Iterable<X> iterable, Class<Y> selectionClass) {
		iterable.iterator.partitionBy(selectionClass)
	}
	
	/**
	 * This method partitions the elements in {@code iterable} into elements instance of {@code selectionClass}
	 * and elements that are not. Elements instance of {@code selectionClass} are aggregated using the {@code selectedCollector}
	 * and the result will be available via the selected part of the returned partition. Elements not instance of {@code selectionClass}
	 * are aggregated using the {@code rejectedCollector} and provided via the selected part of the returned partition.
	 * 
	 * @param iterable source iterable, that's elements are partitioned based on {@code selectionClass}
	 * @param selectionClass the class elements in {@code iterable} are checked to be instance of. Elements 
	 *   that are instance of {@code selectionClass} will be aggregated into the selected partition of the result.
	 *   Elements that are not, will end up in the aggregated rejected partition.
	 * @param selectedCollector aggregates all elements in {@code iterable} that are instance of {@code selectionClass}. The 
	 *  aggregation result will be provided by the selected part of the returned partition.
	 * @param rejectedCollector aggregates all elements in {@code iterable} that are <em>not</em> instance of {@code selectionClass}. The 
	 *  aggregation result will be provided by the rejected part of the returned partition.
	 * @param <X> Type of elements in {@code iterable}
	 * @param <Y> Type of elements that are part of {@code iterable} and will be put into the resulting aggregation of the selected 
	 *  part of the returned partition.
	 * @param <S> Aggregation result type of the selected part of the returned partition, created by {@code selectedCollector}.
	 * @param <R> Aggregation result type of the rejected part of the returned partition, created by {@code rejectedCollector}.
	 * @return partition of elements in {@code iterable}, providing the aggregation of selected elements, that are instance of {@code selectionClass}, 
	 *  and the aggregation of rejected elements not instance of {@code selectionClass}.
	 * @throws NullPointerException if {@code iterable}, {@code selectionClass}, {@code selectedCollector} or {@code rejectedCollector} is {@code null}
	 * @see IterableExtensions#groupIntoListBy(Iterable, Class, Class,Class[])
	 * @see IterableExtensions#groupIntoSetBy(Iterable, Class, Class,Class[])
	 * @since 1.1.0
	 */
	static def <X,Y,S,R> Partition<S,R> partitionBy(Iterable<X> iterable, Class<Y> selectionClass, Collector<Y, ?, S> selectedCollector, Collector<X, ?, R> rejectedCollector) {
		iterable.requireNonNull("iterable").iterator.partitionBy(selectionClass,selectedCollector,rejectedCollector)
	}
	
	/**
	 * This method partitions the elements in {@code iterable} into elements for which {@code partitionPredicate}
	 * evaluates to {@code true} and elements for which {@code partitionPredicate} evaluates to {@code false}. 
	 * The selected part of the returned partition holds the elements for which {@code partitionPredicate}
	 * evaluates to {@code true}, the rejected part contains the other elements from {@code iterable}. 
	 * Partition parts are Lists of the elements. The relative order of the elements in {@code iterable} is preserved 
	 * in the respective partitions. There is no guarantee about mutability or thread safety of the lists. 
	 * If there is no element selected or rejected, the respective parts will hold an empty List; the parts are 
	 * guaranteed to be not {@code null}.
	 * 
	 * @param iterable source iterable, that's elements are partitioned based on {@code selectionClass}
	 * @param partitionPredicate predicate deciding if an element in {@code iterable} will end up in the 
	 *  selected or rejected part of the returned partition. Elements for which the test returns {@code true} 
	 *  end up in the selected part, others land in the rejected part.
	 * @param <X> Type of elements in {@code iterable}
	 * @return partition of elements in {@code iterable}, providing the selected elements, for which {@code partitionPredicate}
	 *  evaluates to {@code true} and rejected elements for which {@code partitionPredicate} evaluates to {@code false}.
	 * @throws NullPointerException if {@code iterable} or {@code partitionPredicate} is {@code null}
	 * @since 1.1.0
	 */
	static def <X> Partition<List<X>,List<X>> partitionBy(Iterable<X> iterable, Predicate<X> partitionPredicate) {
		iterable.requireNonNull("iterable").iterator.partitionBy(partitionPredicate)
	}
	
	/**
	 * This method partitions the elements in {@code iterable} into aggregated elements for which {@code partitionPredicate}
	 * evaluates to {@code true} and aggregated elements for which {@code partitionPredicate} evaluates to {@code false}. 
	 * The selected part of the returned partition holds the elements aggregated using the given {@code collector} for which 
	 * {@code partitionPredicate} evaluates to {@code true}. The rejected part contains the other elements aggregated using the 
	 * given {@code collector} from {@code iterable}.
	 * 
	 * @param iterable source iterable, that's elements are partitioned based on {@code selectionClass}
	 * @param partitionPredicate predicate deciding if an element in {@code iterable} will end up in the 
	 *  selected or rejected part of the returned partition. Elements for which the test returns {@code true} 
	 *  end up in the selected part, others land in the rejected part.
	 * @param collector used for aggregating the selected and rejected elements in the returned partition.
	 * @param <X> Type of elements in {@code iterable}
	 * @param <AX> Type aggregated elements of returned partition
	 * @return partition of elements in {@code iterable}, providing the selected elements, for which {@code partitionPredicate}
	 *  evaluates to {@code true} aggregated using the given {@code collector} and rejected elements for which {@code partitionPredicate} 
	 * evaluates to {@code false} aggregated using the given {@code collector}.
	 * @throws NullPointerException if {@code iterable}, {@code collector} or {@code partitionPredicate} is {@code null}
	 * @since 1.1.0
	 */
	static def <X,AX> Partition<AX,AX> partitionBy(Iterable<X> iterable, Predicate<X> partitionPredicate, Collector<X, ?, AX> collector) {
		iterable.requireNonNull("iterable").iterator.partitionBy(partitionPredicate, collector)
	}
	
	/**
	 * This method partitions the elements in {@code iterable} into aggregated elements for which {@code partitionPredicate}
	 * evaluates to {@code true} and aggregated elements for which {@code partitionPredicate} evaluates to {@code false}. 
	 * The selected part of the returned partition holds the elements aggregated using the given {@code selectedCollector} for which 
	 * {@code partitionPredicate} evaluates to {@code true}. The rejected part contains the other elements aggregated using the 
	 * given {@code rejectedCollector} from {@code iterable}.
	 * 
	 * @param iterable source iterable, that's elements are partitioned based on {@code selectionClass}
	 * @param partitionPredicate predicate deciding if an element in {@code iterable} will end up aggregated in the 
	 *  selected or aggregated in the rejected part of the returned partition. Elements for which the test returns {@code true} 
	 *  end up in the aggregated selected part, others land in the aggregated rejected part.
	 * @param selectedCollector used for aggregating the selected elements in the returned partition.
	 * @param rejectedCollector used for aggregating the rejected elements in the returned partition.
	 * @param <X> Type of elements in {@code iterable}
	 * @param <AS> Type of aggregated elements of selected part of returned partition
	 * @param <AR>Type of aggregated elements of rejected part of returned partition
	 * @return partition of elements in {@code iterable}, providing the selected elements, for which {@code partitionPredicate}
	 *  evaluates to {@code true} aggregated using the given {@code collector} and rejected elements for which {@code partitionPredicate} 
	 * evaluates to {@code false} aggregated using the given {@code collector}.
	 * @throws NullPointerException if {@code iterable}, {@code selectedCollector}, {@code rejectedCollector} or {@code partitionPredicate} is {@code null}
	 * @since 1.1.0
	 */
	static def <X,AS,AR> Partition<AS,AR> partitionBy(Iterable<X> iterable, Predicate<X> partitionPredicate, Collector<X, ?, AS> selectedCollector, Collector<X, ?, AR> rejectedCollector) {
		iterable.requireNonNull("iterable").iterator.partitionBy(partitionPredicate, selectedCollector, rejectedCollector)
	}
}




