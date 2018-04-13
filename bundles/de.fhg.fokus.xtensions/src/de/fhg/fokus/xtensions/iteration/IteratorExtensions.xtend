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

}
