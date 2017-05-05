package de.fhg.fokus.xtensions.itarator

import org.junit.Test
import static extension de.fhg.fokus.xtensions.iterator.PrimitiveArrayExtensions.*
import static org.junit.Assert.*
import java.util.concurrent.atomic.AtomicInteger
import de.fhg.fokus.xtensions.Util
import java.util.PrimitiveIterator.OfInt
import java.util.NoSuchElementException
import java.util.PrimitiveIterator.OfLong
import java.util.PrimitiveIterator.OfDouble

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
	
	@Test def void testIntArrayStream() {
		val int[] arr = #[9, -123, 0, Integer.MAX_VALUE]
		assertArrayEquals(arr, arr.stream.toArray)
	}
	
	//////////////////
	// long[]#stream //
	//////////////////
	
	@Test def void testEmptyLongArrayStream() {
		val long[] empty = #[]
		assertEquals(0,empty.stream.count)
	}
	
	@Test def void testLongArrayStream() {
		val long[] arr = #[100_000_000L, -8L, 0L, Long.MAX_VALUE]
		assertArrayEquals(arr, arr.stream.toArray)
	}
	
	//////////////////
	// double[]#stream //
	//////////////////
	
	@Test def void testEmptyDoubleArrayStream() {
		val double[] empty = #[]
		assertEquals(0,empty.stream.count)
	}
	
	@Test def void testDoubleArrayStream() {
		val double[] arr = #[Double.NaN,5.0d,Double.POSITIVE_INFINITY,1e-5]
		assertArrayEquals(arr, arr.stream.toArray, 1e-6)
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
		
		assertIteratorEqualsArray(arr, iterable.iterator)
		
		val res = iterable.stream.toArray
		assertArrayEquals(arr, res)
	}
	
	def assertIteratorEqualsArray(int[] arr, OfInt iterator) {
		for(var i = 0; i<arr.length; i++) {
			assertTrue(iterator.hasNext)
			assertEquals(arr.get(i), iterator.nextInt)
		}
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextInt
		]
	}
	
	///////////////////
	// asIntIterable //
	///////////////////
	
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
		
		assertLongIteratorEqualsArray(arr, iterable.iterator)
		
		val res = iterable.stream.toArray
		assertArrayEquals(arr, res)
	}
	
	def assertLongIteratorEqualsArray(long[] arr, OfLong iterator) {
		for(var i = 0; i<arr.length; i++) {
			assertTrue(iterator.hasNext)
			assertEquals(arr.get(i), iterator.nextLong)
		}
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextLong
		]
	}
	
	///////////////////
	// asDoubleIterable //
	///////////////////
	
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
		
		assertDoubleIteratorEqualsArray(arr, iterable.iterator, 1e-6)
		
		val res = iterable.stream.toArray
		assertArrayEquals(arr, res, 1e-6)
	}
	
	def assertDoubleIteratorEqualsArray(double[] arr, OfDouble iterator, double eps) {
		for(var i = 0; i<arr.length; i++) {
			assertTrue(iterator.hasNext)
			assertEquals(arr.get(i), iterator.nextDouble, eps)
		}
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextDouble
		]
	}
	
	// TODO test asIterable with slices
}