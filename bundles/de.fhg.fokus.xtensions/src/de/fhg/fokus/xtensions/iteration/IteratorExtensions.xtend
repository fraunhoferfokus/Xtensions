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
	public static def <T> OfInt mapInt(Iterator<T> iterator, ToIntFunction<T> mapper) {
		iterator.requireNonNull
		mapper.requireNonNull
		new OfInt {

			override nextInt() {
				val current = iterator.next
				mapper.applyAsInt(current)
			}

			override hasNext() {
				iterator.hasNext
			}

		}
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
	public static def <T> OfLong mapLong(Iterator<T> iterator, ToLongFunction<T> mapper) {
		iterator.requireNonNull
		mapper.requireNonNull
		new OfLong {

			override nextLong() {
				val current = iterator.next
				mapper.applyAsLong(current)
			}

			override hasNext() {
				iterator.hasNext
			}

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
	public static def <T> OfDouble mapDouble(Iterator<T> iterator, ToDoubleFunction<T> mapper) {
		iterator.requireNonNull
		mapper.requireNonNull
		new OfDouble {
			override nextDouble() {
				val current = iterator.next
				mapper.applyAsDouble(current)
			}

			override hasNext() {
				iterator.hasNext
			}

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
	 * @since 1.1.0
	 */
	static def ClassGroupingSet groupIntoSetBy(Iterator<?> iterator, Class<?> firstGroup, Class<?> secondGroup, Class<?>... additionalGroups) {
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
	 * @since 1.1.0
	 */
	static def ClassGroupingList groupIntoListBy(Iterator<?> iterator, Class<?> firstGroup, Class<?> secondGroup, Class<?>... additionalGroups) {
		val Class<?>[] partitionKeys = copyIntoNewArray(Class, firstGroup, secondGroup, additionalGroups)
		val builder = ImmutableListMultimap.builder
		iterator.addElementsToGroups(builder, partitionKeys)
		val map = builder.build
		new ClassGroupingListImpl(map, partitionKeys)
	}
	
	private static def <T> addElementsToGroups(Iterator<T> iterator, ImmutableMultimap.Builder<Class<?>, Object> builder, Class<?>[] partitionKeys) {
		iterator.forEach [
			// Find first class it is instance of
			for(var i = 0; i < partitionKeys.length; i++) {
				val clazz = partitionKeys.get(i)
				if(clazz.isInstance(it)) {
					// Add it under Class group
					builder.put(clazz, it)
					// continue with next element in iterable
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
	 * @return filtered {@code iterator} not containing elements from {@code toExclude}.
	 * @throws NullPointerException will be thrown if {@code iterator} or {@code toExclude} is {@code null}.
	 * @since 1.1.0
	 */
	public static def <T> Iterator<T> withoutAll(Iterator<T> iterator, Iterable<?> toExclude) {
		Objects.requireNonNull(toExclude,"toExclude")
		Objects.requireNonNull(iterator,"iterator")
		val filterFunc = if(toExclude instanceof Collection<?>) {
			[!toExclude.contains(it)]
		} else {
			[Object element| !toExclude.exists[it == element]]
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
	public static def <X,Y> Iterator<Pair<X,Y>> combinations(Iterator<X> iterator, Iterable<Y> other) {
		other.requireNonNull("other")
		iterator.requireNonNull("iterator").flatMap[i| other.iterator.map[i -> it]]
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
	static def <X,Y,Z> Iterator<Z> combinations(Iterator<X> iterator, Iterable<Y> other, (X,Y)=>Z merger) {
		other.requireNonNull("other")
		merger.requireNonNull("merger")
		iterator.requireNonNull("iterator")
			.flatMap[X x| other.iterator.map[Y y| merger.apply(x,y)]]
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
	static def <X,Y> Iterator<Pair<X,Y>> combinationsWhere(Iterator<X> iterator, Iterable<Y> other, BiPredicate<X,Y> where) {
		other.requireNonNull("other")
		where.requireNonNull("where")
		iterator.requireNonNull("iterator")
			.flatMap[x| 
				other.iterator
					.filter[y| where.test(x,y)]
					.map[x -> it]
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
	static def <X,Y,Z> Iterator<Z> combinationsWhere(Iterator<X> iterator, Iterable<Y> other, BiPredicate<X,Y> where, (X,Y)=>Z merger) {
		other.requireNonNull("other")
		where.requireNonNull("where")
		merger.requireNonNull("merger")
		iterator.requireNonNull("iterator")
			.flatMap[x| 
				other.iterator
					.filter[y| where.test(x,y)]
					.map[y| merger.apply(x,y)]
			]
	}

}
