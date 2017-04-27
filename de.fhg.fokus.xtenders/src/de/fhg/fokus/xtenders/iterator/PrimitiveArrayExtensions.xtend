package de.fhg.fokus.xtenders.iterator

import java.util.PrimitiveIterator
import java.util.function.IntConsumer
import java.util.NoSuchElementException
import java.util.stream.IntStream
import java.util.Objects
import java.util.stream.DoubleStream
import java.util.stream.LongStream

/**
 * This class provides extension methods on arrays of the primitive types {@code int}, {@code long}, {@code float}, and {@code double}.
 */
class PrimitiveArrayExtensions {

	static def IntIterable asIntIterable(int[] arr) {
		new IntegerArrayIterable(arr)
	}

	static def void forEachInt(int[] arr, IntConsumer consumer) {
		for (var i = 0; i < arr.length; i++) {
			consumer.accept(arr.get(1))
		}
	}

	// TODO forEachX and asXIterable for other primitive types 

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
