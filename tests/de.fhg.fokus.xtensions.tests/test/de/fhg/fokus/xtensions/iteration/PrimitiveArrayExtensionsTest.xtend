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

import de.fhg.fokus.xtensions.Util
import de.fhg.fokus.xtensions.iteration.DoubleIterable
import de.fhg.fokus.xtensions.iteration.IntIterable
import de.fhg.fokus.xtensions.iteration.LongIterable
import java.util.NoSuchElementException
import java.util.concurrent.atomic.AtomicInteger
import java.util.function.DoubleConsumer
import java.util.function.IntConsumer
import java.util.function.LongConsumer
import org.junit.Test

import static org.junit.Assert.*

import static extension de.fhg.fokus.xtensions.iteration.PrimitiveArrayExtensions.*

class PrimitiveArrayExtensionsTest {
	
	////////////////
	// forEachInt //
	////////////////
	
	@Test def testForEachIntEmpty() {
		val int[] empty = #[]
		empty.forEachInt [
			fail()
		]
	}
	
	@Test def testForEachIntElements() {
		val int[] arr = #[1,8,-2,100,Integer.MAX_VALUE]
		val AtomicInteger index = new AtomicInteger(0)
		arr.forEachInt [
			val i = index.getAndIncrement
			assertEquals(arr.get(i), it)
		]
		assertEquals(arr.length, index.get)
	}
	
	/////////////////
	// forEachLong //
	/////////////////
	
	@Test def testForEachLongEmpty() {
		val long[] empty = #[]
		empty.forEachLong [
			fail()
		]
	}
	
	@Test def testForEachLongElements() {
		val long[] arr = #[Long.MIN_VALUE,8L,-2L,100L,9L]
		val AtomicInteger index = new AtomicInteger(0)
		arr.forEachLong [
			val i = index.getAndIncrement
			assertEquals(arr.get(i), it)
		]
		assertEquals(arr.length, index.get)
	}
	
	///////////////////
	// forEachDouble //
	///////////////////
	
	@Test def testForEachDoubleEmpty() {
		val double[] empty = #[]
		empty.forEachDouble [
			fail()
		]
	}
	
	@Test def testForEachDoubleElements() {
		val double[] arr = #[Double.NaN,5.0d,Double.POSITIVE_INFINITY,1e-5]
		val AtomicInteger index = new AtomicInteger(0)
		arr.forEachDouble [
			val i = index.getAndIncrement
			assertEquals(arr.get(i), it, 1e-6)
		]
		assertEquals(arr.length, index.get)
	}
	
	//////////////////
	// int[]#stream //
	//////////////////
	
	@Test def void testEmptyIntArrayStream() {
		val int[] empty = #[]
		assertEquals(0,empty.stream.count)
	}
	
	//////////////////
	// long[]#stream //
	//////////////////
	
	@Test def void testEmptyLongArrayStream() {
		val long[] empty = #[]
		assertEquals(0,empty.stream.count)
	}
	
	//////////////////
	// double[]#stream //
	//////////////////
	
	@Test def void testEmptyDoubleArrayStream() {
		val double[] empty = #[]
		assertEquals(0,empty.stream.count)
	}
	
	///////////////////
	// asIntIterable //
	///////////////////
	
	@Test def void testAsIntIterableEmpty() {
		val int[] empty = #[]
		val iterable = empty.asIntIterable
		iterable.forEachInt [
			fail()
		]
		
		Util.assertEmptyIntIterator(iterable.iterator)
		
		val res = iterable.stream.toArray
		assertArrayEquals(empty, res)
	}
	
	@Test def void testAsIntIterableElements() {
		val int[] arr = #[9, -100, Integer.MAX_VALUE, 0]
		val iterable = arr.asIntIterable
		val ai = new AtomicInteger(0)
		iterable.forEachInt [
			val i = ai.getAndIncrement
			assertEquals(arr.get(i), it)
		]
		assertEquals(arr.length, ai.get)
		
		assertIteratorEqualsArray(arr, iterable)
		
		val res = iterable.stream.toArray
		assertArrayEquals(arr, res)
	}
	
	def assertIteratorEqualsArray(int[] arr, IntIterable iterable) {
		val iterator = iterable.iterator
		for(var i = 0; i<arr.length; i++) {
			assertTrue(iterator.hasNext)
			assertEquals(arr.get(i), iterator.nextInt)
		}
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextInt
		]
		
		val iterator2 = iterable.iterator
		val ai = new AtomicInteger(0)
		val IntConsumer action = [int it|
			val i = ai.getAndIncrement
			assertEquals(arr.get(i), it)
		]
		iterator2.forEachRemaining(action)
		Util.expectException(NoSuchElementException) [
			iterator2.nextInt
		]
		assertEquals(arr.length, ai.get)
	}
	
	/////////////////////////
	// asIntIterable slice //
	/////////////////////////
	
	@Test def void testAsIntIterableSliceEmpty() {
		val int[] empty = #[1,3,0,4]
		val iterable = empty.asIntIterable(3,3)
		iterable.forEachInt [
			fail()
		]
		
		Util.assertEmptyIntIterator(iterable.iterator)
		
		val res = iterable.stream.toArray
		assertArrayEquals(#[], res)
	}
	
	@Test def void testAsIntIterableSliceElements() {
		val int[] arr = #[9, -100, Integer.MAX_VALUE, 8, 99999, 0]
		val int[] expected = #[-100, Integer.MAX_VALUE, 8]
		val iterable = arr.asIntIterable(1,4)
		assertIterableEqualsIntArray(expected, iterable)
	}
	
	@Test def void testAsIntIterableSliceFromBegin() {
		val int[] arr = #[9, -100, Integer.MAX_VALUE, 8, 99999, 0]
		val int[] expected = #[9, -100, Integer.MAX_VALUE, 8, 99999]
		val iterable = arr.asIntIterable(0,arr.length - 1)
		assertIterableEqualsIntArray(expected, iterable)
	}
	
	@Test def void testAsIntIterableSliceTillEnd() {
		val int[] arr = #[9, -100, Integer.MAX_VALUE, 8, 99999, 0]
		val int[] expected = #[Integer.MAX_VALUE, 8, 99999, 0]
		val iterable = arr.asIntIterable(2, arr.length)
		assertIterableEqualsIntArray(expected, iterable)
	}
	
	@Test def void testAsIntIterableSliceSingleElement() {
		val int[] arr = #[9, -100, Integer.MAX_VALUE, 8, 99999, 0]
		val int[] expected = #[Integer.MAX_VALUE]
		val iterable = arr.asIntIterable(2, 3)
		assertIterableEqualsIntArray(expected, iterable)
	}
	
	@Test(expected = IndexOutOfBoundsException) def void testAsIntIterableSliceInvalidStart() {
		val int[] arr = #[9, -100, Integer.MAX_VALUE, 8, 99999, 0]
		arr.asIntIterable(6, 1)
	}
	
	@Test(expected = IndexOutOfBoundsException) def void testAsIntIterableSliceNegativeStart() {
		val int[] arr = #[9, -100, Integer.MAX_VALUE, 8, 99999, 0]
		arr.asIntIterable(-2, 1)
	}
	
	@Test(expected = IndexOutOfBoundsException) def void testAsIntIterableSliceInvalidEnd() {
		val int[] arr = #[9, -100, Integer.MAX_VALUE, 8, 99999, 0]
		arr.asIntIterable(2, arr.length + 1)
	}
	
	@Test(expected = IllegalArgumentException) def void testAsIntIterableSliceInvalidArgs() {
		val int[] arr = #[9, -100, Integer.MAX_VALUE, 8, 99999, 0]
		arr.asIntIterable(4, 3)
	}
	
	def void assertIterableEqualsIntArray(int[] expected, IntIterable iterable) {
		val ai = new AtomicInteger(0)
		iterable.forEachInt [
			val i = ai.getAndIncrement
			assertEquals(expected.get(i), it)
		]
		assertEquals(expected.length, ai.get)
		
		assertIteratorEqualsArray(expected, iterable)
		
		val res = iterable.stream.toArray
		assertArrayEquals(expected, res)
	}
	
	////////////////////
	// asLongIterable //
	////////////////////
	
	@Test def void testAsLongIterableEmpty() {
		val long[] empty = #[]
		val iterable = empty.asLongIterable
		iterable.forEachLong [
			fail()
		]
		
		Util.assertEmptyLongIterator(iterable.iterator)
		
		val res = iterable.stream.toArray
		assertArrayEquals(empty, res)
	}
	
	@Test def void testAsLongIterableElements() {
		val long[] arr = #[9_000_000_000L, -100L, Long.MIN_VALUE, 0L]
		val iterable = arr.asLongIterable
		val ai = new AtomicInteger(0)
		iterable.forEachLong [
			val i = ai.getAndIncrement
			assertEquals(arr.get(i), it)
		]
		assertEquals(arr.length, ai.get)
		
		assertLongIteratorEqualsArray(arr, iterable)
		
		val res = iterable.stream.toArray
		assertArrayEquals(arr, res)
	}
	
	def assertLongIteratorEqualsArray(long[] arr, LongIterable iterable) {
		val iterator = iterable.iterator
		for(var i = 0; i<arr.length; i++) {
			assertTrue(iterator.hasNext)
			assertEquals(arr.get(i), iterator.nextLong)
		}
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextLong
		]
		
		val iterator2 = iterable.iterator
		val ai = new AtomicInteger(0)
		val LongConsumer action = [long it|
			val i = ai.getAndIncrement
			assertEquals(arr.get(i), it)
		]
		iterator2.forEachRemaining(action)
		Util.expectException(NoSuchElementException) [
			iterator2.nextLong
		]
		assertEquals(arr.length, ai.get)
	}
	
	//////////////////////////
	// asLongIterable slice //
	//////////////////////////
	
	@Test def void testAsLongIterableSliceEmpty() {
		val long[] arr = #[Long.MIN_VALUE, 0, -8, 666]
		val iterable = arr.asLongIterable(2,2)
		iterable.forEachLong [
			fail()
		]
		
		Util.assertEmptyLongIterator(iterable.iterator)
		
		val res = iterable.stream.toArray
		assertArrayEquals(#[], res)
	}
	
	@Test def void testAsLongIterableSliceElements() {
		val long[] arr = #[9_000_000_000L, -100L, Long.MIN_VALUE, 0L]
		val long[] expected = #[-100L, Long.MIN_VALUE]
		val iterable = arr.asLongIterable(1,3)
		assertIterableEqualsLongArray(expected,iterable)
	}
	
	@Test def void testAsLongIterableSliceFromBegin() {
		val long[] arr = #[9_000_000_000L, -100L, Long.MIN_VALUE, 0L]
		val long[] expected = #[9_000_000_000L, -100L, Long.MIN_VALUE]
		val iterable = arr.asLongIterable(0,arr.length - 1)
		assertIterableEqualsLongArray(expected,iterable)
	}
	
	@Test def void testAsLongIterableSliceTillEnd() {
		val long[] arr = #[9_000_000_000L, -100L, Long.MIN_VALUE, 0L]
		val long[] expected = #[-100L, Long.MIN_VALUE, 0L]
		val iterable = arr.asLongIterable(1, arr.length)
		assertIterableEqualsLongArray(expected,iterable)
	}
	
	@Test def void testAsLongIterableSliceSingleElement() {
		val long[] arr = #[9_000_000_000L, -100L, Long.MIN_VALUE, 0L]
		val long[] expected = #[Long.MIN_VALUE]
		val iterable = arr.asLongIterable(2, 3)
		assertIterableEqualsLongArray(expected,iterable)
	}
	
	@Test(expected = IndexOutOfBoundsException) def void testAsLongIterableSliceInvalidStart() {
		val long[] arr = #[9_000_000_000L, -100L, Long.MIN_VALUE, 0L]
		arr.asLongIterable(4, 3)
	}
	
	@Test(expected = IndexOutOfBoundsException) def void testAsLongIterableSliceNegativeStart() {
		val long[] arr = #[9_000_000_000L, -100L, Long.MIN_VALUE, 0L]
		arr.asLongIterable(-1, 3)
	}
	
	@Test(expected = IndexOutOfBoundsException) def void testAsLongIterableSliceInvalidEnd() {
		val long[] arr = #[9_000_000_000L, -100L, Long.MIN_VALUE, 0L]
		arr.asLongIterable(0, arr.length + 1)
	}
	
	@Test(expected = IllegalArgumentException) def void testAsLongIterableSliceInvalidArgs() {
		val long[] arr = #[9_000_000_000L, -100L, Long.MIN_VALUE, 0L]
		arr.asLongIterable(3, 1)
	}
	
	def void assertIterableEqualsLongArray(long[] expected, LongIterable iterable) {
		val ai = new AtomicInteger(0)
		iterable.forEachLong [
			val i = ai.getAndIncrement
			assertEquals(expected.get(i), it)
		]
		assertEquals(expected.length, ai.get)
		
		assertLongIteratorEqualsArray(expected, iterable)
		
		val res = iterable.stream.toArray
		assertArrayEquals(expected, res)
	}
	
	//////////////////////
	// asDoubleIterable //
	//////////////////////
	
	@Test def void testAsDoubleIterableEmpty() {
		val double[] empty = #[]
		val iterable = empty.asDoubleIterable
		iterable.forEachDouble [
			fail()
		]
		
		Util.assertEmptyDoubleIterator(iterable.iterator)
		
		val res = iterable.stream.toArray
		assertArrayEquals(empty, res, 1e-6)
	}
	
	@Test def void testAsDoubleIterableElements() {
		val double[] arr = #[100.45d, Double.NaN, 0.0d, Double.NEGATIVE_INFINITY, 1e-5d]
		val iterable = arr.asDoubleIterable
		val ai = new AtomicInteger(0)
		iterable.forEachDouble [
			val i = ai.getAndIncrement
			assertEquals(arr.get(i), it, 1e-6)
		]
		assertEquals(arr.length, ai.get)
		
		assertDoubleIteratorEqualsArray(arr, iterable, 1e-6)
		
		val res = iterable.stream.toArray
		assertArrayEquals(arr, res, 1e-6)
	}
	
	def assertDoubleIteratorEqualsArray(double[] arr, DoubleIterable iterable, double eps) {
		val iterator = iterable.iterator
		for(var i = 0; i<arr.length; i++) {
			assertTrue(iterator.hasNext)
			assertEquals(arr.get(i), iterator.nextDouble, eps)
		}
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextDouble
		]
		
		val iterator2 = iterable.iterator
		val ai = new AtomicInteger(0)
		val DoubleConsumer action = [double it|
			val i = ai.getAndIncrement
			assertEquals(arr.get(i), it, eps)
		]
		iterator2.forEachRemaining(action)
		Util.expectException(NoSuchElementException) [
			iterator2.nextDouble
		]
		assertEquals(arr.length, ai.get)
	}
	
	////////////////////////////
	// asDoubleIterable slice //
	////////////////////////////
	
	@Test def void testAsDoubleIterableSliceEmpty() {
		val double[] arr = #[98.0d, Double.POSITIVE_INFINITY, 0.0d, 1e-5d, 0.111d]
		val iterable = arr.asDoubleIterable(2,2)
		iterable.forEachDouble [
			fail()
		]
		
		Util.assertEmptyDoubleIterator(iterable.iterator)
		
		val res = iterable.stream.toArray
		assertArrayEquals(#[], res, 1e-6)
	}
	
	@Test def void testAsDoubleIterableSliceElements() {
		val double[] arr = #[98.0d, Double.POSITIVE_INFINITY, 0.0d, Double.NaN, 1e-5d, 0.111d]
		val double[] expected = #[0.0d, Double.NaN]
		val iterable = arr.asDoubleIterable(2,4)
		assertIterableEqualsDoubleArray(expected, iterable, 1e-6d)
	}
	
	@Test def void testAsDoubleIterableSliceFromBegin() {
		val double[] arr = #[98.0d, Double.POSITIVE_INFINITY, 0.0d, Double.NaN, 1e-5d, 0.111d]
		val double[] expected = #[98.0d, Double.POSITIVE_INFINITY, 0.0d, Double.NaN, 1e-5d]
		val iterable = arr.asDoubleIterable(0,arr.length - 1)
		assertIterableEqualsDoubleArray(expected, iterable, 1e-6d)
	}
	
	@Test def void testAsDoubleIterableSliceTillEnd() {
		val double[] arr = #[98.0d, Double.POSITIVE_INFINITY, 0.0d, Double.NaN, 1e-5d, 0.111d]
		val double[] expected = #[Double.NaN, 1e-5d, 0.111d]
		val iterable = arr.asDoubleIterable(3, arr.length)
		assertIterableEqualsDoubleArray(expected, iterable, 1e-6d)
	}
	
	@Test def void testAsDoubleIterableSliceSingleElement() {
		val double[] arr = #[98.0d, Double.POSITIVE_INFINITY, 0.0d, Double.NaN, 1e-5d, 0.111d]
		val double[] expected = #[Double.POSITIVE_INFINITY]
		val iterable = arr.asDoubleIterable(1,2)
		assertIterableEqualsDoubleArray(expected, iterable, 1e-6d)
	}
	
	@Test(expected = IndexOutOfBoundsException) def void testAsDoubleIterableSliceInvalidStart() {
		val double[] arr = #[98.0d, Double.POSITIVE_INFINITY, 0.0d, Double.NaN, 1e-5d, 0.111d]
		arr.asDoubleIterable(7,2)
	}
	
	@Test(expected = IndexOutOfBoundsException) def void testAsDoubleIterableSliceNegativeStart() {
		val double[] arr = #[98.0d, Double.POSITIVE_INFINITY, 0.0d, Double.NaN, 1e-5d, 0.111d]
		arr.asDoubleIterable(-3,2)
	}
	
	@Test(expected = IndexOutOfBoundsException) def void testAsDoubleIterableSliceInvalidEnd() {
		val double[] arr = #[98.0d, Double.POSITIVE_INFINITY, 0.0d, Double.NaN, 1e-5d, 0.111d]
		arr.asDoubleIterable(0,arr.length + 1)
	}
	
	@Test(expected = IllegalArgumentException) def void testAsDoubleIterableSliceInvalidArgs() {
		val double[] arr = #[98.0d, Double.POSITIVE_INFINITY, 0.0d, Double.NaN, 1e-5d, 0.111d]
		arr.asDoubleIterable(4,2)
	}
	
	def void assertIterableEqualsDoubleArray(double[] expected, DoubleIterable iterable, double eps) {
		val ai = new AtomicInteger(0)
		iterable.forEachDouble [
			val i = ai.getAndIncrement
			assertEquals(expected.get(i), it, eps)
		]
		assertEquals(expected.length, ai.get)
		
		assertDoubleIteratorEqualsArray(expected, iterable, eps)
		
		val res = iterable.stream.toArray
		assertArrayEquals(expected, res, eps)
		
	}
	// TODO Also make slice fail with negative indices and wrong indices.
}