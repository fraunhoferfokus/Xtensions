/*******************************************************************************
 * Copyright (c) 2017-2018 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.iteration

import java.util.Iterator
import java.util.function.ToIntFunction
import java.util.PrimitiveIterator.OfInt
import java.util.PrimitiveIterator.OfLong
import java.util.function.ToLongFunction
import java.util.PrimitiveIterator.OfDouble
import java.util.function.ToDoubleFunction
import static extension java.util.Objects.*
import com.google.common.collect.ImmutableMultimap
import com.google.common.collect.ImmutableListMultimap
import static extension de.fhg.fokus.xtensions.iteration.ArrayExtensions.*
import de.fhg.fokus.xtensions.iteration.internal.ClassGroupingListImpl
import de.fhg.fokus.xtensions.iteration.internal.ClassGroupingSetImpl
import com.google.common.collect.ImmutableSetMultimap
import java.util.Collection
import java.util.Objects
import java.util.function.BiPredicate
import java.util.stream.Collector
import java.util.function.BiConsumer
import java.util.function.Function
import de.fhg.fokus.xtensions.iteration.internal.PartitionImpl
import java.util.List
import java.util.function.Predicate
import static extension java.util.Objects.*
import de.fhg.fokus.xtensions.iteration.internal.IntStreamable
import java.util.stream.Stream
import java.util.Spliterators
import java.util.stream.StreamSupport
import de.fhg.fokus.xtensions.iteration.internal.DoubleStreamable
import de.fhg.fokus.xtensions.iteration.internal.LongStreamable

/**
 * Extension methods for the {@link Iterator} class. 
 */
class IteratorExtensions {

	private new() {
		throw new IllegalStateException("IteratorExtensions not intended to be instantiated")
	}

	/**
	 * This function maps an {@link Iterator} to a {@link OfInt PrimitiveIterator.OfInt}, using the 
	 * {@code mapper} function for each element of the original {@code iterator}. 
	 * The returned {@code PrimitiveIterator.OfInt} is lazy, only calling
	 * the {@code mapper} function when a next element is pulled from it.
	 * @param iterator the {@code Iterator} of which each element should be mapped to {@code int} values.
	 * @param mapper the mapping function, mapping each element of {@code iterator} to an {@code int} value.
	 * @param <T> type of elements in {@code iterator}, that are mapped to {@code int}s via {@code mapper}.
	 * @return a {@code PrimitiveIterator.OfInt} mapped from the elements of the input {@code iterator}.
	 * @throws NullPointerException if {@code iterator} or {@code mapper} is {@code null}
	 */
	static def <T> OfInt mapInt(Iterator<T> iterator, ToIntFunction<T> mapper) {
		iterator.requireNonNull
		mapper.requireNonNull
		new MappedOfInt(iterator, mapper)
	}
	
	/**
	 * Implementation of a {@code PrimitiveIterator.OfInt} mapping the elements
	 * of an {@code Iterator} to primitive {@code int} values based on a given {@code ToIntFunction}.
	 */
	private static final class MappedOfInt<T> implements OfInt, IntStreamable {
		
		val Iterator<T> iterator
		val ToIntFunction<T> mapper
		
		new (Iterator<T> iterator, ToIntFunction<T> mapper) {
			this.iterator = iterator
			this.mapper = mapper
		}

		override nextInt() {
			val current = iterator.next
			mapper.applyAsInt(current)
		}

		override hasNext() {
			iterator.hasNext
		}
		
		override streamInts() {
			iterator.streamRemaining.mapToInt(mapper)
		}
		
	}
	
	/**
	 * Creates a Java 8 stream of all remaining elements provided by the {@code iterator}.
	 * @param iterator source of elements provided by returned stream
	 * @return stream of elements taken from {@code iterator}
	 */
	private static def <T> Stream<T> streamRemaining(Iterator<T> iterator) {
		// when made public, test iterator for being null
		val spliterator = Spliterators.spliteratorUnknownSize(iterator, 0)
		StreamSupport.stream(spliterator, false);
	}

	/**
	 * This function maps an {@link Iterator} to a {@link OfLong PrimitiveIterator.OfLong}, using the 
	 * {@code mapper} function for each element of the original {@code iterator}. 
	 * The returned {@code PrimitiveIterator.OfLong} is lazy, only calling
	 * the {@code mapper} function when a next element is pulled from it.
	 * @param iterator the {@code Iterator} of which each element should be mapped to {@code long} values.
	 * @param mapper the mapping function, mapping each element of {@code iterator} to an {@code long} value.
	 * @param <T> type of elements in {@code iterator}, that are mapped to {@code long}s via {@code mapper}.
	 * @return a {@code PrimitiveIterator.OfLong} mapped from the elements of the input {@code iterator}.
	 * @throws NullPointerException if {@code iterator} or {@code mapper} is {@code null}
	 */
	static def <T> OfLong mapLong(Iterator<T> iterator, ToLongFunction<T> mapper) {
		iterator.requireNonNull
		mapper.requireNonNull
		new MappedOfLong(iterator, mapper)
	}
	
	/**
	 * Implementation of a {@code PrimitiveIterator.OfLong} mapping the elements
	 * of an {@code Iterator} to primitive {@code long} values based on a given {@code ToLongFunction}.
	 */
	private static final class MappedOfLong<T> implements OfLong, LongStreamable {
		val Iterator<T> iterator
		val ToLongFunction<T> mapper
		
		new(Iterator<T> iterator, ToLongFunction<T> mapper) {
			this.iterator = iterator
			this.mapper = mapper
		}
		
		override nextLong() {
			val current = iterator.next
			mapper.applyAsLong(current)
		}

		override hasNext() {
			iterator.hasNext
		}
		
		override streamLongs() {
			iterator.streamRemaining.mapToLong(mapper)
		}
	}

	/**
	 * This function maps an {@link Iterator} to a {@link OfLong PrimitiveIterator.OfDouble}, using the 
	 * {@code mapper} function for each element of the original {@code iterator}. 
	 * The returned {@code PrimitiveIterator.OfDouble} is lazy, only calling
	 * the {@code mapper} function when a next element is pulled from it.
	 * @param iterator the {@code Iterator} of which each element should be mapped to {@code double} values.
	 * @param mapper the mapping function, mapping each element of {@code iterator} to an {@code double} value.
	 * @param <T> type of elements in {@code iterator}, that are mapped to {@code double}s via {@code mapper}.
	 * @return a {@code PrimitiveIterator.OfDouble} mapped from the elements of the input {@code iterator}.
	 * @throws NullPointerException if {@code iterator} or {@code mapper} is {@code null}
	 */
	static def <T> OfDouble mapDouble(Iterator<T> iterator, ToDoubleFunction<T> mapper) {
		iterator.requireNonNull
		mapper.requireNonNull
		new MappedOfDouble(iterator, mapper)
	}
	
	/**
	 * Implementation of a {@code PrimitiveIterator.OfDouble} mapping the elements
	 * of an {@code Iterator} to primitive {@code double} values based on a given {@code ToDoubleFunction}.
	 */
	private static final class MappedOfDouble<T> implements OfDouble, DoubleStreamable {
		val Iterator<T> iterator
		val ToDoubleFunction<T> mapper
		
		new(Iterator<T> iterator, ToDoubleFunction<T> mapper) {
			this.iterator = iterator
			this.mapper = mapper
		}
		
		override nextDouble() {
			val current = iterator.next
			mapper.applyAsDouble(current)
		}

		override hasNext() {
			iterator.hasNext
		}
		
		override streamDoubles() {
			iterator.streamRemaining().mapToDouble(mapper)
		}
		
	}

	/**
	 * Groups the elements in {@code iterator} into sets by the classes given via parameters {@code firstGroup}, {@code firstGroup}, and {@code additionalGroups}.
	 * The elements will be checked to be instance of the given classes in the 
	 * order they appear in the parameter list. So if e.g. classes {@code Object} and {@code String}
	 * are passed into the function in this order, an instance of {@code String} will land
	 * in the group of {@code Object}. Also note that objects that are not matching any given class
	 * are simply omitted from the resulting grouping. If you need a group for all objects that 
	 * were not matched, just pass in the class of {@code Object} as the last parameter.
	 * @param iterator the iterator, that provides the elements to be be grouped into sets by the given classes
	 * @param firstGroup first class elements of {@code iterator} are be grouped by
	 * @param secondGroup first class elements of {@code iterator} are be grouped by
	 * @param additionalGroups further classes to group elements by. This parameter is allowed to be {@code null}.
	 * @return a grouping of elements by the classes, provided via the parameters {@code firstGroup}, {@code firstGroup}, and {@code additionalGroups}.
	 * @see IteratorExtensions#partitionBy(Iterator, Class)
	 * @see IteratorExtensions#partitionBy(Iterator, Class, Collector, Collector)
	 * @since 1.1.0
	 */
	static def ClassGroupingSet groupIntoSetBy(Iterator<?> iterator, Class<?> firstGroup, Class<?> secondGroup,
		Class<?>... additionalGroups) {
		val Class<?>[] partitionKeys = copyIntoNewArray(Class, firstGroup, secondGroup, additionalGroups)
		val builder = ImmutableSetMultimap.builder
		iterator.addElementsToGroups(builder, partitionKeys)
		val map = builder.build
		new ClassGroupingSetImpl(map, partitionKeys)
	}

	/**
	 * Groups the elements in {@code iterator} into lists by the classes given via parameters {@code firstGroup}, {@code firstGroup}, and {@code additionalGroups}.
	 * The elements will be checked to be instance of the given classes in the 
	 * order they appear in the parameter list. So if e.g. classes {@code Object} and {@code String}
	 * are passed into the function in this order, an instance of {@code String} will land
	 * in the group of {@code Object}. Also note that objects that are not matching any given class
	 * are simply omitted from the resulting grouping. If you need a group for all objects that 
	 * were not matched, just pass in the class of {@code Object} as the last parameter.
	 * @param iterator the iterator, that provides the elements to be be grouped into sets by the given classes
	 * @param firstGroup first class elements of {@code iterator} are be grouped by
	 * @param secondGroup first class elements of {@code iterator} are be grouped by
	 * @param additionalGroups further classes to group elements by. This parameter is allowed to be {@code null}.
	 * @return a grouping of elements by the classes, provided via the parameters {@code firstGroup}, {@code firstGroup}, and {@code additionalGroups}.
	 * @see IteratorExtensions#partitionBy(Iterator, Class)
	 * @see IteratorExtensions#partitionBy(Iterator, Class, Collector, Collector)
	 * @since 1.1.0
	 */
	static def ClassGroupingList groupIntoListBy(Iterator<?> iterator, Class<?> firstGroup, Class<?> secondGroup,
		Class<?>... additionalGroups) {
		val Class<?>[] partitionKeys = copyIntoNewArray(Class, firstGroup, secondGroup, additionalGroups)
		val builder = ImmutableListMultimap.builder
		iterator.addElementsToGroups(builder, partitionKeys)
		val map = builder.build
		new ClassGroupingListImpl(map, partitionKeys)
	}

	private static def <T> addElementsToGroups(Iterator<T> iterator,
		ImmutableMultimap.Builder<Class<?>, Object> builder, Class<?>[] partitionKeys) {
		iterator.forEachRemaining [
			// Find first class it is instance of
			for (var i = 0; i < partitionKeys.length; i++) {
				val clazz = partitionKeys.get(i)
				if (clazz.isInstance(it)) {
					// Add it under Class group
					builder.put(clazz, it)
					// continue with next element in iterator
					return
				}
			}
		]
	}

	/**
	 * Filters the given {@code iterator} by filtering all elements out that are also included
	 * in the given {@code Iterable toExclude}. If an element from {@code iterator} is {@code null} it is removed 
	 * if {@code toExclude} also contains a {@code null} value. Otherwise elements {@code e} from 
	 * {@code iterator} are only removed, if {@code toExclude} contains an element {@code o}, where {@code e.equals(o)}.
	 * @param iterator the iterator to be filtered. Must not be {@code null}.
	 * @param toExclude the elements not to be included in the resulting iterator. Must not be {@code null}.
	 * @param <T> Type of elements provided by {@code iterator}
	 * @return filtered {@code iterator} not containing elements from {@code toExclude}.
	 * @throws NullPointerException will be thrown if {@code iterator} or {@code toExclude} is {@code null}.
	 * @since 1.1.0
	 */
	static def <T> Iterator<T> withoutAll(Iterator<T> iterator, Iterable<?> toExclude) {
		Objects.requireNonNull(toExclude, "toExclude")
		Objects.requireNonNull(iterator, "iterator")
		val filterFunc = if (toExclude instanceof Collection<?>) {
				[!toExclude.contains(it)]
			} else {
				[Object element|!toExclude.exists[it == element]]
			}
		iterator.filter(filterFunc)
	}

	/**
	 * This function returns a new Iterator providing the elements of the Cartesian Product of the elements provided 
	 * by {@code iterator} and the elements of the {@code other}. The 
	 * combination of elements of the {@code iterator} and the {@code other} are represented 
	 * as {@link Pair}s of the values from both sources.
	 * 
	 * @param iterator the iterator that's elements are combined with every elements from {@code other}. Must not be {@code null}.
	 * @param other the elements to be combined with each element from {@code iterator}. Must not be {@code null}.
	 * @param <X> Type of elements in {@code iterator}.
	 * @param <Y> Type of elements provided by {@code other}
	 * @return iterator of combinations of all elements from {@code iterator} with every element of the elements provided by {@code other}.
	 * @throws NullPointerException is thrown if {@code iterator} or {@code other} is {@code null}
	 * @since 1.1.0
	 */
	static def <X, Y> Iterator<Pair<X, Y>> combinations(Iterator<X> iterator, Iterable<Y> other) {
		other.requireNonNull("other")
		iterator.requireNonNull("iterator").flatMap[i|other.iterator.map[i -> it]]
	}

	/**
	 * This function returns a new Iterator providing the elements of the Cartesian Product of the elements provided 
	 * by {@code iterator} and the elements of the {@code other}. The 
	 * combination of elements of the {@code iterator} and the {@code other} are computed using the {@code merger}
	 * function.
	 * 
	 * @param iterator the iterator that's elements are combined with every elements from {@code other}. Must not be {@code null}.
	 * @param other the elements to be combined with each element from {@code iterator}. Must not be {@code null}.
	 * @param merger the function combining the elements from {@code iterator} and {@code other}.
	 * @param <X> Type of elements in {@code iterator}.
	 * @param <Y> Type of elements provided by {@code other}
	 * @param <Z> Type of the merged elements
	 * @return iterator of combinations of all elements from {@code iterator} with every element of the elements provided by {@code other}.
	 * @throws NullPointerException is thrown if {@code iterator}, or {@code other}, or {@code merger} is {@code null}
	 * @since 1.1.0
	 */
	static def <X, Y, Z> Iterator<Z> combinations(Iterator<X> iterator, Iterable<Y> other, (X, Y)=>Z merger) {
		other.requireNonNull("other")
		merger.requireNonNull("merger")
		iterator.requireNonNull("iterator").flatMap[X x|other.iterator.map[Y y|merger.apply(x, y)]]
	}

	/**
	 * This function returns a new Iterator providing the elements of the Cartesian Product of the elements provided 
	 * by {@code iterator} and the elements of the {@code other}. A combination of values from {@code iterator} and 
	 * {@code other} will only be included in the resulting iterator, if the {@code where} predicate holds true for
	 * the combination. The combination of elements are represented as {@link Pair}s of the values from both sources.
	 * 
	 * @param iterator the iterator that's elements are combined with every elements from {@code other}. Must not be {@code null}.
	 * @param other the elements to be combined with each element from {@code iterator}. Must not be {@code null}.
	 * @param where a filtering predicate to only produce combinations for which this predicate holds true. Must not be {@code null}.
	 * @param <X> Type of elements in {@code iterator}.
	 * @param <Y> Type of elements provided by {@code other}
	 * @return iterator of combinations of all elements from {@code iterator} with every element of the elements provided by {@code other} 
	 *  for which the {@code where} predicate holds true.
	 * @throws NullPointerException is thrown if {@code iterator}, or {@code other} or {@code where} is {@code null}
	 * @since 1.1.0
	 */
	static def <X, Y> Iterator<Pair<X, Y>> combinationsWhere(Iterator<X> iterator, Iterable<Y> other,
		BiPredicate<X, Y> where) {
		other.requireNonNull("other")
		where.requireNonNull("where")
		iterator.requireNonNull("iterator").flatMap [ x |
			other.iterator.filter[y|where.test(x, y)].map[x -> it]
		]
	}

	/**
	 * This function returns a new Iterator providing the elements of the Cartesian Product of the elements provided 
	 * by {@code iterator} and the elements of the {@code other}. A combination of values from {@code iterator} and 
	 * {@code other} will only be included in the resulting iterator, if the {@code where} predicate holds true for
	 * the combination. The combination of elements of the {@code iterator} and the {@code other} are computed using 
	 * the {@code merger} function.
	 * 
	 * @param iterator the iterator that's elements are combined with every elements from {@code other}. Must not be {@code null}.
	 * @param other the elements to be combined with each element from {@code iterator}. Must not be {@code null}.
	 * @param where a filtering predicate to only produce combinations for which this predicate holds true. Must not be {@code null}.
	 * @param merger the function combining the elements from {@code iterator} and {@code other}.
	 * @param <X> Type of elements in {@code iterator}.
	 * @param <Y> Type of elements provided by {@code other}
	 * @param <Z> Type of the merged elements
	 * @return iterator of combinations of all elements from {@code iterator} with every element of the elements provided by {@code other} 
	 *  for which the {@code where} predicate holds true. The elements are a result of the {@code merger} call for each combination
	 * @throws NullPointerException is thrown if {@code iterator}, or {@code other}, or {@code where}, or {@code merger} is {@code null}
	 * @since 1.1.0
	 */
	static def <X, Y, Z> Iterator<Z> combinationsWhere(Iterator<X> iterator, Iterable<Y> other, BiPredicate<X, Y> where,
		(X, Y)=>Z merger) {
		other.requireNonNull("other")
		where.requireNonNull("where")
		merger.requireNonNull("merger")
		iterator.requireNonNull("iterator").flatMap [ x |
			other.iterator.filter[y|where.test(x, y)].map[y|merger.apply(x, y)]
		]
	}

	/**
	 * This method partitions the elements in the given {@code iterator} into elements instance of {@code selectionClass}
	 * and elements that are not. The returned partition holds the elements instance of {@code selectionClass} 
	 * in the selected partition and the other elements in the rejected partition. Partitions are Lists of the 
	 * elements. The relative order of the elements in {@code iterator} is preserved in the respective partitions. 
	 * There is no guarantee about mutability or thread safety of the list partitions. If there is no element
	 * selected or rejected, the respective parts will hold an empty List; the parts are guaranteed to be not {@code null}.
	 * 
	 * @param iterator source iterator, that's elements are partitioned based on {@code selectionClass}
	 * @param selectionClass the class elements in {@code iterator} are checked to be instance of. Elements 
	 *   that are instance of {@code selectionClass} will be added to the selected partition of the result.
	 *   Elements that are not, will end up in the rejected partition.
	 * @return partition of elements in {@code iterator}, providing the selected elements, that are instance of {@code selectionClass}, and rejected elements
	 *  not instance of {@code selectionClass}.
	 * @param <X> Type of elements in {@code iterator}
	 * @param <Y> Type of elements that are part of {@code iterator} and will be put into the resulting selected partition.
	 * @throws NullPointerException if {@code iterator} or {@code selectionClass} is {@code null}
	 * @see IteratorExtensions#groupIntoListBy(Iterator, Class, Class, Class[])
	 * @see IteratorExtensions#groupIntoSetBy(Iterator, Class, Class, Class[])
	 * @since 1.1.0
	 */
	static def <X, Y> Partition<List<Y>, List<X>> partitionBy(Iterator<X> iterator, Class<Y> selectionClass) {
		selectionClass.requireNonNull("selectionClass")
		val selected = newArrayList
		val rejected = newArrayList
		iterator.forEachRemaining [
			if (selectionClass.isInstance(it)) {
				selected.add(selectionClass.cast(it))
			} else {
				rejected.add(it)
			}
		]
		new PartitionImpl(selected, rejected)
	}

	/**
	 * This method partitions the elements provided by the {@code iterator} into elements instance of {@code selectionClass}
	 * and elements that are not. Elements instance of {@code selectionClass} are aggregated using the {@code selectedCollector}
	 * and the result will be available via the selected part of the returned partition. Elements not instance of {@code selectionClass}
	 * are aggregated using the {@code rejectedCollector} and provided via the selected part of the returned partition.
	 * 
	 * @param iterator source iterator, that's elements are partitioned based on {@code selectionClass}
	 * @param selectionClass the class elements provided by {@code iterator} are checked to be instance of. Elements 
	 *   that are instance of {@code selectionClass} will be aggregated into the selected partition of the result.
	 *   Elements that are not, will end up in the aggregated rejected partition.
	 * @param selectedCollector aggregates all elements provided by {@code iterator} that are instance of {@code selectionClass}. The 
	 *  aggregation result will be provided by the selected part of the returned partition.
	 * @param rejectedCollector aggregates all elements provided by {@code iterator} that are <em>not</em> instance of {@code selectionClass}. The 
	 *  aggregation result will be provided by the rejected part of the returned partition.
	 * @param <X> Type of elements provided by {@code iterator}
	 * @param <Y> Type of elements that are part of the {@code iterator} and will be put into the resulting aggregation of the selected 
	 *  part of the returned partition.
	 * @param <S> Aggregation result type of the selected part of the returned partition, created by {@code selectedCollector}.
	 * @param <R> Aggregation result type of the rejected part of the returned partition, created by {@code rejectedCollector}.
	 * @return partition of elements provided by {@code iterator}, providing the aggregation of selected elements, that are instance of {@code selectionClass}, 
	 *  and the aggregation of rejected elements not instance of {@code selectionClass}.
	 * @throws NullPointerException if {@code iterator}, {@code selectionClass}, {@code selectedCollector} or {@code rejectedCollector} is {@code null}
	 * @see IteratorExtensions#groupIntoListBy(Iterator, Class, Class,Class[])
	 * @see IteratorExtensions#groupIntoSetBy(Iterator, Class, Class,Class[])
	 * @since 1.1.0
	 */
	static def <X, Y, S, R> Partition<S, R> partitionBy(Iterator<X> iterator, Class<Y> selectionClass,
		Collector<Y, ?, S> selectedCollector, Collector<X, ?, R> rejectedCollector) {
		selectionClass.requireNonNull("selectionClass")

		val selectedAcc = selectedCollector.supplier.get
		val rejectedAcc = rejectedCollector.supplier.get

		val selctedAccumulator = selectedCollector.accumulator.requireNonNull as BiConsumer<Object, Y>
		val rejectedAccumulator = rejectedCollector.accumulator.requireNonNull as BiConsumer<Object, X>

		val selectedFinisher = selectedCollector.finisher.requireNonNull as Function<Object, S>
		val rejectedFinisher = rejectedCollector.finisher.requireNonNull as Function<Object, R>

		// Partition into selected and rejected by either calling selctedAccumulator or rejectedAccumulator
		iterator.forEachRemaining [
			if (selectionClass.isInstance(it)) {
				val curr = selectionClass.cast(it)
				selctedAccumulator.accept(selectedAcc, curr)
			} else {
				rejectedAccumulator.accept(rejectedAcc, it)
			}
		]
		val selected = selectedFinisher.apply(selectedAcc)
		val rejected = rejectedFinisher.apply(rejectedAcc)

		new PartitionImpl(selected, rejected)
	}

	/**
	 * This method partitions the elements provided by the {@code iterator} into elements for which {@code partitionPredicate}
	 * evaluates to {@code true} and elements for which {@code partitionPredicate} evaluates to {@code false}. 
	 * The selected part of the returned partition holds the elements for which {@code partitionPredicate}
	 * evaluates to {@code true}, the rejected part contains the other elements from the {@code iterator}. 
	 * Partition parts are Lists of the elements. The relative order of the elements provided by the {@code iterator} is preserved 
	 * in the respective partitions. There is no guarantee about mutability or thread safety of the lists. If there is no element
	 * selected or rejected, the respective parts will hold an empty List; the parts are guaranteed to be not {@code null}.
	 * 
	 * @param iterator source iterator, that's elements are partitioned based on {@code selectionClass}
	 * @param partitionPredicate predicate deciding if an element provided by {@code iterator} will end up in the 
	 *  selected or rejected part of the returned partition. Elements for which the test returns {@code true} 
	 *  end up in the selected part, others land in the rejected part.
	 * @param <X> Type of elements provided by {@code iterator}
	 * @return partition of elements provided by {@code iterator}, providing the selected elements, for which {@code partitionPredicate}
	 *  evaluates to {@code true} and rejected elements for which {@code partitionPredicate} evaluates to {@code false}.
	 * @throws NullPointerException if {@code iterator} or {@code partitionPredicate} is {@code null}
	 * @since 1.1.0
	 */
	static def <X> Partition<List<X>, List<X>> partitionBy(Iterator<X> iterator, Predicate<X> partitionPredicate) {
		partitionPredicate.requireNonNull("partitionPredicate")
		val selected = newArrayList
		val rejected = newArrayList
		iterator.forEachRemaining [
			if (partitionPredicate.test(it)) {
				selected.add(it)
			} else {
				rejected.add(it)
			}
		]
		new PartitionImpl(selected, rejected)
	}

	/**
	 * This method partitions the elements provided by {@code iterator} into aggregated elements for which {@code partitionPredicate}
	 * evaluates to {@code true} and aggregated elements for which {@code partitionPredicate} evaluates to {@code false}. 
	 * The selected part of the returned partition holds the elements aggregated using the given {@code collector} for which 
	 * {@code partitionPredicate} evaluates to {@code true}. The rejected part contains the other elements aggregated using the 
	 * given {@code collector} from the {@code iterator}.
	 * 
	 * @param iterator source iterator, that's provided elements are partitioned based on {@code selectionClass}
	 * @param partitionPredicate predicate deciding if an element in {@code iterator} will end up in the 
	 *  selected or rejected part of the returned partition. Elements for which the test returns {@code true} 
	 *  end up in the selected part, others land in the rejected part.
	 * @param collector used for aggregating the selected and rejected elements in the returned partition.
	 * @param <X> Type of elements provided by {@code iterator}
	 * @param <AX> Type of aggregated elements provided by the returned partition
	 * @return partition of elements provided by {@code iterator}, providing the selected elements, for which {@code partitionPredicate}
	 *  evaluates to {@code true} aggregated using the given {@code collector} and rejected elements for which {@code partitionPredicate} 
	 * evaluates to {@code false} aggregated using the given {@code collector}.
	 * @throws NullPointerException if {@code iterator}, {@code collector} or {@code partitionPredicate} is {@code null}
	 * @since 1.1.0
	 */
	static def <X, AX> Partition<AX, AX> partitionBy(Iterator<X> iterator, Predicate<X> partitionPredicate,
		Collector<X, ?, AX> collector) {
		partitionPredicate.requireNonNull("partitionPredicate")
		val accSupplier = collector.supplier
		val selectedAcc = accSupplier.get
		val rejectedAcc = accSupplier.get

		val selctedAccumulator = collector.accumulator.requireNonNull as BiConsumer<Object, X>
		val rejectedAccumulator = collector.accumulator.requireNonNull as BiConsumer<Object, X>

		val finisher = collector.finisher.requireNonNull as Function<Object, AX>

		// Partition into selected and rejected by either calling selctedAccumulator or rejectedAccumulator
		iterator.forEachRemaining [
			if (partitionPredicate.test(it)) {
				selctedAccumulator.accept(selectedAcc, it)
			} else {
				rejectedAccumulator.accept(rejectedAcc, it)
			}
		]
		val selected = finisher.apply(selectedAcc)
		val rejected = finisher.apply(rejectedAcc)

		new PartitionImpl(selected, rejected)
	}

	/**
	 * This method partitions the elements provided by {@code iterator} into aggregated elements for which {@code partitionPredicate}
	 * evaluates to {@code true} and aggregated elements for which {@code partitionPredicate} evaluates to {@code false}. 
	 * The selected part of the returned partition holds the elements aggregated using the given {@code selectedCollector} for which 
	 * {@code partitionPredicate} evaluates to {@code true}. The rejected part contains the other elements aggregated using the 
	 * given {@code rejectedCollector} from {@code iterator}.
	 * 
	 * @param iterator source iterator, that's provided elements are partitioned based on {@code selectionClass}
	 * @param partitionPredicate predicate deciding if an element provided by {@code iterator} will end up aggregated in the 
	 *  selected or aggregated in the rejected part of the returned partition. Elements for which the test returns {@code true} 
	 *  end up in the aggregated selected part, others land in the aggregated rejected part.
	 * @param selectedCollector used for aggregating the selected elements in the returned partition.
	 * @param rejectedCollector used for aggregating the rejected elements in the returned partition.
	 * @param <X> Type of elements provided by {@code iterator}
	 * @param <AS> Type of aggregated elements provided by the selected part of the returned partition.
	 * @param <AR> Type of aggregated elements provided by the rejected part of the returned partition.
	 * @return partition of elements provided by {@code iterator}, providing the selected elements, for which {@code partitionPredicate}
	 *  evaluates to {@code true} aggregated using the given {@code collector} and rejected elements for which {@code partitionPredicate} 
	 * evaluates to {@code false} aggregated using the given {@code collector}.
	 * @throws NullPointerException if {@code iterator}, {@code selectedCollector}, {@code rejectedCollector} or {@code partitionPredicate} is {@code null}
	 * @since 1.1.0
	 */
	static def <X, AS, AR> Partition<AS, AR> partitionBy(Iterator<X> iterator, Predicate<X> partitionPredicate,
		Collector<X, ?, AS> selectedCollector, Collector<X, ?, AR> rejectedCollector) {
		iterator.requireNonNull("iterator")
		partitionPredicate.requireNonNull("partitionPredicate")
		val selectedAcc = selectedCollector.supplier.get
		val rejectedAcc = rejectedCollector.supplier.get

		val selctedAccumulator = selectedCollector.accumulator.requireNonNull as BiConsumer<Object, X>
		val rejectedAccumulator = rejectedCollector.accumulator.requireNonNull as BiConsumer<Object, X>

		val selectedFinisher = selectedCollector.finisher.requireNonNull as Function<Object, AS>
		val rejectedFinisher = rejectedCollector.finisher.requireNonNull as Function<Object, AR>

		// Partition into selected and rejected by either calling selctedAccumulator or rejectedAccumulator
		iterator.forEachRemaining [
			if (partitionPredicate.test(it)) {
				selctedAccumulator.accept(selectedAcc, it)
			} else {
				rejectedAccumulator.accept(rejectedAcc, it)
			}
		]
		val selected = selectedFinisher.apply(selectedAcc)
		val rejected = rejectedFinisher.apply(rejectedAcc)

		new PartitionImpl(selected, rejected)
	}
	
	/**
	 * This method will add the elements provided by {@code iterator} to the {@code target} collection
	 * and then return the {@code target} collection. The elements will be added to {@code target}
	 * in the order that is provided by the {@code forEachRemaining} method defined on {@code iterator}.<br>
	 * <em><b>Attention:</b></em> Even though this method looks functional it produces a side effect.
	 * When the method is returning the {@code target} collection will include the elements provided by 
	 * {@code iterator}. This is intentional and is beneficial if the the elements need to be used
	 * in subsequent statement after calling this method.
	 * <br><br>
	 * This method is introduced for the common case of a single target collection.
	 * The {@link IteratorExtensions#into(Iterator, Collection[]) vararg overload} will 
	 * create may implicitly create an array instance. This is avoided with this 
	 * overload.
	 * 
	 * @param iterator the source of elements to be added to {@code target}. Must not be {@code null}.
	 * @param target the collection to which the elements of {@code iterator} are added to. This reference
	 *  will also be returned by this method. Must not be {@code null}.
	 * @return the {@code target} reference. The elements taken from {@code iterator} will have been added to it when
	 *  being returned.
	 * @param <X> Type of elements of {@code target}. Must be either {@code T} or a super class of {@code T}.
	 * @param <T> Type of elements provided by {@code iterator}.
	 * @throws NullPointerException if {@code iterator}, {@code selectedCollector}, or {@code target} is {@code null}
	 * @see IteratorExtensions#into(Iterator, Collection[])
	 * @since 1.1.0
	 */
	static def <X, T extends X> Collection<X> into(Iterator<T> iterator, Collection<X> target) {
		target.requireNonNull("target")
		iterator.requireNonNull("iterator").forEachRemaining [
			// We do not use forEach here to avoid creating a capturing lambda instance
			target.add(it)
		]
		target
	}
	
	/**
	 * This method will add the elements provided by {@code iterator} to the all of the collection in {@code targets}
	 * and then return all those collections in an array. The elements will be added to the {@code targets} collections
	 * in the order that is provided by the {@code forEach} method defined on {@code iterator}.<br>
	 * <em><b>Attention:</b></em> Even though this method looks functional it produces a side effect.
	 * When the method is returning the {@code targets} collections will include the elements provided by 
	 * {@code iterator}. This is intentional and is beneficial if the the elements need to be used
	 * in subsequent statement after calling this method.
	 * 
	 * @param iterator the source of elements to be added to the collections in {@code targets}. Must not be {@code null}.
	 * @param targets the collections to which the elements of {@code iterator} are added to. An array of the same collections
	 *  will also be returned by this method. Must not be {@code null} and no contained collection reference must be {@code null}.
	 * @return the collections from {@code targets}. The elements from {@code iterator} will have been added to each of the contained 
	 *  collections when being returned.
	 * @param <X> Type of elements of collections in {@code targets}. Must be either {@code T} or a super class of {@code T}.
	 * @param <T> Type of elements provided by {@code iterator}.
	 * @throws NullPointerException if {@code iterator}, {@code selectedCollector}, or {@code targets}, or a 
	 *  collection in {@code targets} is {@code null}.
	 * @see IteratorExtensions#into(Iterator, Collection)
	 * @since 1.1.0
	 */
	static def <X, T extends X> Collection<X>[] into(Iterator<T> iterator, Collection<X>... targets) {
		iterator.requireNonNull("iterator")
		targets.requireNonNull("target").forEach [
			it.requireNonNull("element in target")
		]
		// Defensive copy of array
		val internalTarget = targets.clone
		val length = internalTarget.length
		
		if(length == 0) {
			return internalTarget
		}
		iterator.forEachRemaining [
			// We do not use forEach here to avoid creating a capturing lambda instance
			for(var i = 0; i < length; i++) {
				internalTarget.get(i).add(it)
			}
		]
		internalTarget
	}
}
