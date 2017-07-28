package de.fhg.fokus.xtensions.iteration

import java.util.PrimitiveIterator
import java.util.function.IntConsumer
import java.util.NoSuchElementException
import java.util.stream.IntStream
import java.util.Objects
import java.util.stream.DoubleStream
import java.util.stream.LongStream
import java.util.function.LongConsumer
import java.util.function.DoubleConsumer
import java.util.Arrays
import de.fhg.fokus.xtensions.iteration.internal.PrimitiveIterableUtil

/**
 * This class provides extension methods on arrays of the primitive types {@code int}, {@code long}, {@code float}, and {@code double}.
 */
final class PrimitiveArrayExtensions {

	private new() {
		throw new IllegalStateException("PrimitiveArrayExtensions not intended to be instantiated")
	}

	/**
	 * This method creates an {@link IntIterable} for the given array {@code arr},
	 * allowing iteration over all elements in the array via a primitive iterator or a stream.
	 * @parameter arr array to create an iterable for.
	 * @return primitive iterable
	 */
	static def IntIterable asIntIterable(int[] arr) {
		asIntIterable(arr, 0, arr.length)
	}

	/**
	 * This method provides an unmodifiable view as a {@link IntIterable} on a slice of the 
	 * array {@code arr}. The slice will start at the array index of {@code startIncluding} and 
	 * and at the array index of {@code endExcluding - 1}. If {@code startIncluding == endExcluding} an empty iterable is returned. 
	 * Note that at the current point negative values for the index parameters are not supported and will cause this 
	 * method to throw an exception. This may change in later releases.
	 * @param arr the array to create a {@code IntIterable} view for.
	 * @param startIncluding the index of the array where the iterable will start. Must be {@code >=0} and 
	 *  {@code < arr.length}.
	 * @param endExcluding the index of the last element to be iterated over in the array +1. E.g. if the
	 *  last element of the array should be the last element to be iterated over, this parameter must be 
	 *  {@code arr.length}. The value must be {@code >= 0} and {@code <= arr.length}. If value is {@code 0}
	 *  then {@code startIncluding} must be {@code 0} as well; in this case an empty {@code IntIterable} is returned
	 * @throws IllegalArgumentException if {@code startIncluding > endExcluding}.
	 * @throws IndexOutOfBoundsException if either {@code startIncluding} or {@code endExcluding}
	 *  refer to an index out of the range of array {@code arr}.
	 */
	static def IntIterable asIntIterable(int[] arr, int startIncluding, int endExcluding) throws IllegalArgumentException, IndexOutOfBoundsException {
		// TODO negative parameter = array.length - value
		if (startIncluding == endExcluding) {
			PrimitiveIterableUtil.EMPTY_INTITERABLE
		} else {
			new IntArrayIterable(arr, startIncluding, endExcluding)
		}
	}

	/**
	 * This method creates an {@link IntIterable} for the given array {@code arr},
	 * allowing iteration over the complete array via a primitive iterator or a stream.
	 * @parameter arr array to create an iterable for.
	 */
	static def LongIterable asLongIterable(long[] arr) {
		asLongIterable(arr, 0, arr.length)
	}

	/**
	 * This method provides an unmodifiable view as a {@link LongIterable} on a slice of the 
	 * array {@code arr}. The slice will start at the array index of {@code startIncluding} and 
	 * and at the array index of {@code endExcluding - 1}. If {@code startIncluding == endExcluding} an empty iterable is returned. 
	 * Note that at the current point negative values for the index parameters are not supported and will cause this method 
	 * to throw an exception. This may change in later releases.
	 * @param arr the array to create a {@code LongIterable} view for.
	 * @param startIncluding the index of the array where the iterable will start. Must be {@code >=0} and 
	 *  {@code < arr.length}.
	 * @param endExcluding the index of the last element to be iterated over in the array +1. E.g. if the
	 *  last element of the array should be the last element to be iterated over, this parameter must be 
	 *  {@code arr.length}. The value must be {@code >= 0} and {@code <= arr.length}. If value is {@code 0}
	 *  then {@code startIncluding} must be {@code 0} as well; in this case an empty {@code LongIterable} is returned.
	 * @throws IllegalArgumentException if {@code startIncluding > endExcluding}.
	 * @throws IndexOutOfBoundsException if either {@code startIncluding} or {@code endExcluding}
	 *  refer to an index out of the range of array {@code arr}.
	 */
	static def LongIterable asLongIterable(long[] arr, int startIncluding, int endExcluding) throws IllegalArgumentException, IndexOutOfBoundsException  {
		// TODO negative parameter = array.length - value
		if (startIncluding == endExcluding) {
			PrimitiveIterableUtil.EMPTY_LONGITERABLE
		} else {
			new LongArrayIterable(arr, startIncluding, endExcluding)
		}
	}

	/**
	 * This method creates an {@link IntIterable} for the given array {@code arr},
	 * allowing iteration over the complete array via a primitive iterator or a stream.
	 * @parameter arr array to create an iterable for.
	 */
	static def DoubleIterable asDoubleIterable(double[] arr) {
		asDoubleIterable(arr, 0, arr.length)
	}

	/**
	 * This method provides an unmodifiable view as a {@link DoubleIterable} on a slice of the 
	 * array {@code arr}. The slice will start at the array index of {@code startIncluding} and 
	 * and at the array index of {@code endExcluding - 1}. If {@code startIncluding == endExcluding} an empty iterable is returned. 
	 * Note that at the current point negative values for the index parameters are not supported and will cause this method 
	 * to throw an exception. This may change in later releases.
	 * @param arr the array to create a {@code DoubleIterable} view for.
	 * @param startIncluding the index of the array where the iterable will start. Must be {@code >=0} and 
	 *  {@code < arr.length}.
	 * @param endExcluding the index of the last element to be iterated over in the array +1. E.g. if the
	 *  last element of the array should be the last element to be iterated over, this parameter must be 
	 *  {@code arr.length}. The value must be {@code >= 0} and {@code <= arr.length}. If value is {@code 0}
	 *  then {@code startIncluding} must be {@code 0} as well; in this case an empty {@code DoubleIterable} is returned.
	 * @throws IllegalArgumentException if {@code startIncluding > endExcluding}.
	 * @throws IndexOutOfBoundsException if either {@code startIncluding} or {@code endExcluding}
	 *  refer to an index out of the range of array {@code arr}.
	 */
	static def DoubleIterable asDoubleIterable(double[] arr, int startIncluding, int endExcluding) throws IllegalArgumentException, IndexOutOfBoundsException {
		// TODO negative parameter = array.length - value
		if (startIncluding == endExcluding) {
			PrimitiveIterableUtil.EMPTY_DOUBLEITERABLE
		} else {
			new DoubleArrayIterable(arr, startIncluding, endExcluding)
		}
	}

	/**
	 * This method allows iterating over the primitive values in the given array {@code arr} without boxing the values into objects. 
	 * For each elements in the array (from index {@code 0} to {@code arr.length - 1}) the given {@code consumer}
	 * is called with every element. 
	 * @param arr array to iterate over
	 * @param consumer the action called with each element in {@code arr}.
	 */
	static def void forEachInt(int[] arr, IntConsumer consumer) {
		for (var i = 0; i < arr.length; i++) {
			consumer.accept(arr.get(i))
		}
	}

	/**
	 * This method allows iterating over the primitive values in the given array {@code arr} without boxing the values into objects. 
	 * For each elements in the array (from index {@code 0} to {@code arr.length - 1}) the given {@code consumer}
	 * is called with every element. 
	 * @param arr array to iterate over
	 * @param consumer the action called with each element in {@code arr}.
	 */
	static def void forEachLong(long[] arr, LongConsumer consumer) {
		for (var i = 0; i < arr.length; i++) {
			consumer.accept(arr.get(i))
		}
	}

	/**
	 * This method allows iterating over the primitive values in the given array {@code arr} without boxing the values into objects. 
	 * For each elements in the array (from index {@code 0} to {@code arr.length - 1}) the given {@code consumer}
	 * is called with every element. 
	 * @param arr array to iterate over
	 * @param consumer the action called with each element in {@code arr}.
	 */
	static def void forEachDouble(double[] arr, DoubleConsumer consumer) {
		for (var i = 0; i < arr.length; i++) {
			consumer.accept(arr.get(i))
		}
	}

	/**
	 * This is a convenience extension method for {@link Arrays#stream(int[])}.
	 */
//	@Inline(value="Arrays.stream($1)", imported=Arrays)
	static def IntStream stream(int[] arr) {
		Arrays.stream(arr)
	}

	/**
	 * This is a convenience extension method for {@link Arrays#stream(double[])}.
	 */
//	@Inline(value="Arrays.stream($1)", imported=Arrays)
	static def DoubleStream stream(double[] arr) {
		Arrays.stream(arr)
	}

	/**
	 * This is a convenience extension method for {@link Arrays#stream(long[])}.
	 */
//	@Inline(value="Arrays.stream($1)", imported=Arrays)
	static def LongStream stream(long[] arr) {
		Arrays.stream(arr)
	}
}

/**
 * Implementation of {@link IntIterable} for {@code int[]}. 
 */
package class IntArrayIterable implements IntIterable {

	new(int[] arr, int startIncluding, int endExcluding) {
		if (startIncluding < 0) {
			throw new IndexOutOfBoundsException('''Start index «startIncluding» is below zero''')
		}
		if (arr.length <= startIncluding) {
			throw new IndexOutOfBoundsException('''Start index «startIncluding» is beyond last element''')
		}
		if (arr.length < endExcluding) {
			throw new IndexOutOfBoundsException('''End index «endExcluding» is beyond last element''')
		}
		if (startIncluding >= endExcluding) {
			throw new IllegalArgumentException("Forbidden combination startIncluding >= endExcluding")
		}
		this.arr = arr
		this.startIncluding = startIncluding
		this.endExcluding = endExcluding
	}

	val int[] arr
	val int startIncluding
	val int endExcluding

	override iterator() {
		new IntegerArrayIterator(arr, startIncluding, endExcluding)
	}

	override forEachInt(IntConsumer consumer) {
		val array = arr
		val end = endExcluding
		for (var i = startIncluding; i < end; i++) {
			consumer.accept(array.get(i))
		}
	}

	override stream() {
		Arrays.stream(arr, startIncluding, endExcluding)
	}

}

/**
 * This class is an implementation of {@link PrimitiveIterator.OfInt} for {@code int[]}.
 */
package class IntegerArrayIterator implements PrimitiveIterator.OfInt {
	val int[] arr
	var int next
	val int endExcluding

	new(int[] arr, int startIncluding, int endExcluding) {
		this.arr = arr
		this.next = startIncluding
		this.endExcluding = endExcluding
	}

	override nextInt() {
		if (next >= endExcluding) {
			throw new NoSuchElementException
		}
		val result = arr.get(next)
		next++
		return result
	}

	override hasNext() {
		next < endExcluding
	}

	override forEachRemaining(IntConsumer action) {
		Objects.requireNonNull(action);
		val end = endExcluding
		for (var i = next; i < end; next = (i=i+1)) {
			action.accept(arr.get(i))
		}
	}

}

/**
 * Implementation of {@link LongIterable} for {@code long[]}. 
 */
package class LongArrayIterable implements LongIterable {

	new(long[] arr, int startIncluding, int endExcluding) {
		if (startIncluding < 0) {
			throw new IndexOutOfBoundsException('''Start index «startIncluding» is below zero''')
		}
		if (arr.length <= startIncluding && startIncluding != 0) {
			throw new IndexOutOfBoundsException('''Start index «startIncluding» is beyond last element''')
		}
		if (arr.length < endExcluding) {
			throw new IndexOutOfBoundsException('''End index «endExcluding» is beyond last element''')
		}
		if (startIncluding >= endExcluding && endExcluding != 0) {
			throw new IllegalArgumentException("Forbidden combination startIncluding >= endExcluding")
		}
		this.arr = arr
		this.startIncluding = startIncluding
		this.endExcluding = endExcluding
	}

	val long[] arr
	val int startIncluding
	val int endExcluding

	override iterator() {
		new LongArrayIterator(arr, startIncluding, endExcluding)
	}

	override forEachLong(LongConsumer consumer) {
		val array = arr
		for (var i = startIncluding; i < endExcluding; i++) {
			consumer.accept(array.get(i))
		}
	}

	override stream() {
		Arrays.stream(arr, startIncluding, endExcluding)
	}

}

/**
 * This class is an implementation of {@link PrimitiveIterator.OfInt} for {@code int[]}.
 */
package class LongArrayIterator implements PrimitiveIterator.OfLong {
	val long[] arr
	var int next
	val int endExcluding

	new(long[] arr, int startIncluding, int endExcluding) {
		this.arr = arr
		this.next = startIncluding
		this.endExcluding = endExcluding
	}

	override nextLong() {
		if (next >= endExcluding) {
			throw new NoSuchElementException
		}
		val result = arr.get(next)
		next++
		return result
	}

	override hasNext() {
		next < endExcluding
	}

	override forEachRemaining(LongConsumer action) {
		Objects.requireNonNull(action);
		val end = endExcluding
		for (var i = next; i < end; next = (i=i+1)) {
			action.accept(arr.get(i))
		}
	}

}

/**
 * Implementation of {@link LongIterable} for {@code long[]}. 
 */
package class DoubleArrayIterable implements DoubleIterable {

	new(double[] arr, int startIncluding, int endExcluding) {
		if (startIncluding < 0) {
			throw new IndexOutOfBoundsException('''Start index «startIncluding» is below zero''')
		}
		if (arr.length <= startIncluding) {
			throw new IndexOutOfBoundsException('''Start index «startIncluding» is beyond last element''')
		}
		if (arr.length < endExcluding) {
			throw new IndexOutOfBoundsException('''End index «endExcluding» is beyond last element''')
		}
		if (startIncluding >= endExcluding) {
			throw new IllegalArgumentException("Forbidden combination startIncluding >= endExcluding")
		}
		this.arr = arr
		this.startIncluding = startIncluding
		this.endExcluding = endExcluding
	}

	val double[] arr
	val int startIncluding
	val int endExcluding

	override iterator() {
		new DoubleArrayIterator(arr, startIncluding, endExcluding)
	}

	override forEachDouble(DoubleConsumer consumer) {
		val array = arr
		val end = endExcluding
		for (var i = startIncluding; i < end; i++) {
			consumer.accept(array.get(i))
		}
	}

	override stream() {
		Arrays.stream(arr, startIncluding, endExcluding)
	}

}

/**
 * This class is an implementation of {@link PrimitiveIterator.OfInt} for {@code int[]}.
 */
package class DoubleArrayIterator implements PrimitiveIterator.OfDouble {
	val double[] arr
	var int next
	val int endExcluding

	new(double[] arr, int startIncluding, int endExcluding) {
		this.arr = arr
		this.next = startIncluding
		this.endExcluding = endExcluding
	}

	override nextDouble() {
		if (next >= endExcluding) {
			throw new NoSuchElementException
		}
		val result = arr.get(next)
		next++
		return result
	}

	override hasNext() {
		next < endExcluding
	}

	override forEachRemaining(DoubleConsumer action) {
		Objects.requireNonNull(action);
		val end = endExcluding
		for (var i = next; i < end; next = (i=i+1)) {
			action.accept(arr.get(i))
		}
	}

}
