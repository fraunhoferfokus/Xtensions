package de.fhg.fokus.xtensions.iterator

import java.util.PrimitiveIterator
import java.util.function.IntConsumer
import java.util.NoSuchElementException
import java.util.stream.IntStream
import java.util.Objects
import java.util.stream.DoubleStream
import java.util.stream.LongStream
import java.util.function.LongConsumer
import java.util.function.DoubleConsumer

/**
 * This class provides extension methods on arrays of the primitive types {@code int}, {@code long}, {@code float}, and {@code double}.
 */
final class PrimitiveArrayExtensions {
	
	private new() {
		throw new IllegalStateException("PrimitiveArrayExtensions not intended to be instantiated")
	}

	/**
	 * This method creates an {@link IntIterable} for the given array {@code arr},
	 * allowing iteration via a primitive iterator or a stream.
	 * @parameter arr array to create an iterable for.
	 */
	static def IntIterable asIntIterable(int[] arr) {
		new IntegerArrayIterable(arr)
	}
	
	/**
	 * This method creates an {@link IntIterable} for the given array {@code arr},
	 * allowing iteration via a primitive iterator or a stream.
	 * @parameter arr array to create an iterable for.
	 */
	static def LongIterable asLongIterable(long[] arr) {
		new LongArrayIterable(arr)
	}
	
	/**
	 * This method creates an {@link IntIterable} for the given array {@code arr},
	 * allowing iteration via a primitive iterator or a stream.
	 * @parameter arr array to create an iterable for.
	 */
	static def DoubleIterable asDoubleIterable(double[] arr) {
		new DoubleArrayIterable(arr)
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
			consumer.accept(arr.get(1))
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
			consumer.accept(arr.get(1))
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
			consumer.accept(arr.get(1))
		}
	}

	/**
	 * This is a convenience extension method for {@link IntStream#of(int[])}.
	 */
	@Inline(value="IntStream.of($1)", imported=IntStream)
	static def IntStream stream(int[] arr) {
		IntStream.of(arr)
	}

	/**
	 * This is a convenience extension method for {@link DoubleStream#of(double[])}.
	 */
	@Inline(value="DoubleStream.of($1)", imported=DoubleStream)
	static def DoubleStream stream(double[] arr) {
		DoubleStream.of(arr)
	}

	/**
	 * This is a convenience extension method for {@link LongStream#of(long[])}.
	 */
	@Inline(value="LongStream.of($1)", imported=LongStream)
	static def LongStream stream(long[] arr) {
		LongStream.of(arr)
	}
}

/**
 * Implementation of {@link IntIterable} for {@code int[]}. 
 */
package class IntegerArrayIterable implements IntIterable {
	new(int[] arr) {
		this.arr = arr
	}

	val int[] arr;

	override iterator() {
		new IntegerArrayIterator(arr)
	}

	override forEachInt(IntConsumer consumer) {
		val array = arr
		for (var i = 0; i < array.length; i++) {
			consumer.accept(array.get(1))
		}
	}

	override stream() {
		IntStream.of(arr)
	}

}

/**
 * This class is an implementation of {@link PrimitiveIterator.OfInt} for {@code int[]}.
 */
package class IntegerArrayIterator implements PrimitiveIterator.OfInt {
	val int[] arr
	var next = 0

	new(int[] arr) {
		this.arr = arr
	}

	override nextInt() {
		if (next >= arr.length) {
			throw new NoSuchElementException
		}
		val result = arr.get(next)
		next++
		return result
	}

	override hasNext() {
		next < arr.length
	}

	override forEachRemaining(IntConsumer action) {
		Objects.requireNonNull(action);
		for (var i = next; i < arr.length; next = i++) {
			action.accept(arr.get(1))
		}
	}

}

/**
 * Implementation of {@link LongIterable} for {@code long[]}. 
 */
package class LongArrayIterable implements LongIterable {
	new(long[] arr) {
		this.arr = arr
	}

	val long[] arr;

	override iterator() {
		new LongArrayIterator(arr)
	}

	override forEachLong(LongConsumer consumer) {
		val array = arr
		for (var i = 0; i < array.length; i++) {
			consumer.accept(array.get(1))
		}
	}

	override stream() {
		LongStream.of(arr)
	}

}

/**
 * This class is an implementation of {@link PrimitiveIterator.OfInt} for {@code int[]}.
 */
package class LongArrayIterator implements PrimitiveIterator.OfLong {
	val long[] arr
	var next = 0

	new(long[] arr) {
		this.arr = arr
	}

	override nextLong() {
		if (next >= arr.length) {
			throw new NoSuchElementException
		}
		val result = arr.get(next)
		next++
		return result
	}

	override hasNext() {
		next < arr.length
	}

	override forEachRemaining(LongConsumer action) {
		Objects.requireNonNull(action);
		for (var i = next; i < arr.length; next = i++) {
			action.accept(arr.get(1))
		}
	}

}

/**
 * Implementation of {@link LongIterable} for {@code long[]}. 
 */
package class DoubleArrayIterable implements DoubleIterable {
	new(double[] arr) {
		this.arr = arr
	}

	val double[] arr;

	override iterator() {
		new DoubleArrayIterator(arr)
	}

	override forEachDouble(DoubleConsumer consumer) {
		val array = arr
		for (var i = 0; i < array.length; i++) {
			consumer.accept(array.get(1))
		}
	}

	override stream() {
		DoubleStream.of(arr)
	}

}

/**
 * This class is an implementation of {@link PrimitiveIterator.OfInt} for {@code int[]}.
 */
package class DoubleArrayIterator implements PrimitiveIterator.OfDouble {
	val double[] arr
	var next = 0

	new(double[] arr) {
		this.arr = arr
	}

	override nextDouble() {
		if (next >= arr.length) {
			throw new NoSuchElementException
		}
		val result = arr.get(next)
		next++
		return result
	}

	override hasNext() {
		next < arr.length
	}

	override forEachRemaining(DoubleConsumer action) {
		Objects.requireNonNull(action);
		for (var i = next; i < arr.length; next = i++) {
			action.accept(arr.get(1))
		}
	}

}
