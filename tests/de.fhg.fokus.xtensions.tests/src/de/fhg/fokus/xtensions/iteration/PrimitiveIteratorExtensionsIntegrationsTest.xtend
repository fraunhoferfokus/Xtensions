package de.fhg.fokus.xtensions.iteration

import static extension de.fhg.fokus.xtensions.iteration.PrimitiveIteratorExtensions.*
import static extension de.fhg.fokus.xtensions.iteration.PrimitiveArrayExtensions.*
import org.junit.Test
import static extension org.junit.Assert.*
import de.fhg.fokus.xtensions.Util
import static extension de.fhg.fokus.xtensions.range.RangeExtensions.*
import static extension de.fhg.fokus.xtensions.iteration.IterableExtensions.*
import static extension de.fhg.fokus.xtensions.optional.OptionalIntExtensions.*
import static extension de.fhg.fokus.xtensions.optional.OptionalLongExtensions.*
import static extension de.fhg.fokus.xtensions.optional.OptionalDoubleExtensions.*
import java.util.PrimitiveIterator.OfInt
import java.util.PrimitiveIterator.OfLong
import java.util.PrimitiveIterator.OfDouble
import java.util.OptionalInt
import java.util.OptionalLong
import java.util.OptionalDouble

/**
 * This class tests the combinations of {@code PrimitiveIteratorExtensions#streamRemaining(...)}
 * and {@code PrimitiveIteratorExtensions#streamRemainingExhaustive(...)} methods in combination
 * with Iterators created in various ways in this framework
 */
class PrimitiveIteratorExtensionsIntegrationsTest {
	
	//////////////
	// generate //
	//////////////
	
	@Test
	def void testStreamRemainingIntSupply() {
		extension val obj = new Object {
			var curr = 0
		}
		val iterable = IntIterable.generate[|[curr++]]
		val iterator = iterable.iterator
		val first = iterator.nextInt
		assertEquals(0, first)
		val streamed = iterator.streamRemaining.limit(3).toArray
		val int[] expected = #[1,2,3]
		assertArrayEquals(expected, streamed)
	}
	
	@Test
	def void testStreamRemainingLongSupply() {
		extension val obj = new Object {
			var curr = 0L
		}
		val iterable = LongIterable.generate[|[curr++]]
		val iterator = iterable.iterator
		val first = iterator.nextLong
		assertEquals(0, first)
		val streamed = iterator.streamRemaining.limit(3).toArray
		val long[] expected = #[1,2,3]
		assertArrayEquals(expected, streamed)
	}
	
	@Test
	def void testStreamRemainingDoubleSupply() {
		extension val obj = new Object {
			var curr = 0.0d
		}
		val iterable = DoubleIterable.generate[|[ val old = curr; curr+=1.0d; old]]
		val iterator = iterable.iterator
		val first = iterator.nextDouble
		assertEquals(0.0d, first, 0.0d)
		val streamed = iterator.streamRemaining.limit(3).toArray
		val double[] expected = #[1.0d,2.0d,3.0d]
		assertArrayEquals(expected, streamed, 0.0d)
	}
	
	@Test
	def void testStreamRemainingExhaustiveIntSupply() {
		extension val obj = new Object {
			var curr = 0
		}
		val iterable = IntIterable.generate[|[curr++]]
		val iterator = iterable.iterator
		val first = iterator.nextInt
		assertEquals(0, first)
		val streamed = iterator.streamRemainingExhaustive.limit(3).toArray
		val int[] expected = #[1,2,3]
		assertArrayEquals(expected, streamed)
		
		val fourth = iterator.nextInt
		assertEquals(4, fourth)
	}
	
	@Test
	def void testStreamRemainingExhaustiveLongSupply() {
		extension val obj = new Object {
			var curr = 0L
		}
		val iterable = LongIterable.generate[|[curr++]]
		val iterator = iterable.iterator
		val first = iterator.nextLong
		assertEquals(0, first)
		val streamed = iterator.streamRemainingExhaustive.limit(3).toArray
		val long[] expected = #[1,2,3]
		assertArrayEquals(expected, streamed)
		
		val fourth = iterator.nextLong
		assertEquals(4L, fourth)
	}
	
	@Test
	def void testStreamRemainingExhaustiveDoubleSupply() {
		extension val obj = new Object {
			var curr = 0.0d
		}
		val iterable = DoubleIterable.generate[|[ val old = curr; curr+=1.0d; old]]
		val iterator = iterable.iterator
		val first = iterator.nextDouble
		assertEquals(0.0d, first, 0.0d)
		val streamed = iterator.streamRemainingExhaustive.limit(3).toArray
		val double[] expected = #[1.0d,2.0d,3.0d]
		assertArrayEquals(expected, streamed, 0.0d)
		
		val fourth = iterator.nextDouble
		assertEquals(4.0d, fourth, 0.0d)
	}
	
	
	/////////////
	// iterate //
	/////////////
	
	@Test
	def void testStreamRemainingIntIterate() {
		val iterable = IntIterable.iterate(0)[it+1]
		val iterator = iterable.iterator
		val first = iterator.nextInt
		assertEquals(0, first)
		val streamed = iterator.streamRemaining.limit(3).toArray
		val int[] expected = #[1,2,3]
		assertArrayEquals(expected, streamed)
	}
	
	@Test
	def void testStreamRemainingLongIterate() {
		val iterable = LongIterable.iterate(0, [it+1L])
		val iterator = iterable.iterator
		val first = iterator.nextLong
		assertEquals(0L, first)
		val streamed = iterator.streamRemaining.limit(3).toArray
		val long[] expected = #[1L,2L,3L]
		assertArrayEquals(expected, streamed)
	}
	
	@Test
	def void testStreamRemainingDoubleIterate() {
		val iterable = DoubleIterable.iterate(0)[it+1.0d]
		val iterator = iterable.iterator
		val first = iterator.nextDouble
		assertEquals(0.0d, first, 0.0d)
		val streamed = iterator.streamRemaining.limit(3).toArray
		val double[] expected = #[1.0d,2.0d,3.0d]
		assertArrayEquals(expected, streamed, 0.0d)
	}
	
	
	@Test
	def void testStreamRemainingExhaustiveIntIterate() {
		val iterable = IntIterable.iterate(0)[it+1]
		val iterator = iterable.iterator
		val first = iterator.nextInt
		assertEquals(0, first)
		val streamed = iterator.streamRemainingExhaustive.limit(3).toArray
		val int[] expected = #[1,2,3]
		assertArrayEquals(expected, streamed)
		
		val fourth = iterator.nextInt
		assertEquals(4, fourth)
	}
	
	@Test
	def void testStreamRemainingExhaustiveLongIterate() {
		val iterable = LongIterable.iterate(0L)[it+1L]
		val iterator = iterable.iterator
		val first = iterator.nextLong
		assertEquals(0, first)
		val streamed = iterator.streamRemainingExhaustive.limit(3).toArray
		val long[] expected = #[1,2,3]
		assertArrayEquals(expected, streamed)
		
		val fourth = iterator.nextLong
		assertEquals(4L, fourth)
	}
	
	@Test
	def void testStreamRemainingExhaustiveDoubleIterate() {
		val iterable = DoubleIterable.iterate(0.0d)[it + 1.0d]
		val iterator = iterable.iterator
		val first = iterator.nextDouble
		assertEquals(0.0d, first, 0.0d)
		val streamed = iterator.streamRemainingExhaustive.limit(3).toArray
		val double[] expected = #[1.0d,2.0d,3.0d]
		assertArrayEquals(expected, streamed, 0.0d)
		
		val fourth = iterator.nextDouble
		assertEquals(4.0d, fourth, 0.0d)
	}
	
	/////////////////////
	// iterate Limited //
	/////////////////////
	
	@Test
	def void testStreamRemainingIntIterateLimited() {
		val iterable = IntIterable.iterate(0,[it<5],[it+1])
		val iterator = iterable.iterator
		val first = iterator.nextInt
		assertEquals(0, first)
		val streamed = iterator.streamRemaining.toArray
		val int[] expected = #[1,2,3,4]
		assertArrayEquals(expected, streamed)
	}
	
	@Test
	def void testStreamRemainingIntIterateLimitedTakeAll() {
		val iterable = IntIterable.iterate(0,[it<5],[it+1])
		val iterator = iterable.iterator;
		(0..4).forEach [
			iterator.nextInt
		]
		val count = iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	@Test
	def void testStreamRemainingLongIterateLimited() {
		val iterable = LongIterable.iterate(0L,[it<5L],[it+1L])
		val iterator = iterable.iterator
		val first = iterator.nextLong
		assertEquals(0L, first)
		val streamed = iterator.streamRemaining.toArray
		val long[] expected = #[1L,2L,3L,4L]
		assertArrayEquals(expected, streamed)
	}
	
	@Test
	def void testStreamRemainingLongIterateLimitedTakeAll() {
		val iterable = LongIterable.iterate(0L,[it<5L],[it+1L])
		val iterator = iterable.iterator;
		(0..4).forEach [
			iterator.nextLong
		]
		val count = iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	@Test
	def void testStreamRemainingDoubleIterateLimited() {
		val iterable = DoubleIterable.iterate(0.0d,[it<5.0d],[it+1.0d])
		val iterator = iterable.iterator
		val first = iterator.nextDouble
		assertEquals(0.0d, first, 0.0d)
		val streamed = iterator.streamRemaining.toArray
		val double[] expected = #[1.0d,2.0d,3.0d,4.0d]
		assertArrayEquals(expected, streamed, 0.0d)
	}
	
	@Test
	def void testStreamRemainingDoubleIterateLimitedTakeAll() {
		val iterable = DoubleIterable.iterate(0.0d,[it<5.0d],[it+1.0d])
		val iterator = iterable.iterator;
		(0..4).forEach [
			iterator.nextDouble
		]
		val count = iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	// empty iterator
	
	@Test
	def void testStreamRemainingIntIterateLimitedEmpty() {
		val iterable = IntIterable.iterate(0,[false],[it+1])
		val iterator = iterable.iterator
		val count = iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	@Test
	def void testStreamRemainingLongIterateLimitedEmpty() {
		val iterable = LongIterable.iterate(0L,[false],[it+1L])
		val iterator = iterable.iterator
		val count = iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	@Test
	def void testStreamRemainingDoubleIterateLimitedEmpty() {
		val iterable = DoubleIterable.iterate(0.0d,[false],[it+1.0d])
		val iterator = iterable.iterator
		val count = iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	
	@Test
	def void testStreamRemainingExhaustiveIntIterateLimitedExhaustive() {
		val iterable = IntIterable.iterate(0,[it<5],[it+1])
		val iterator = iterable.iterator
		val first = iterator.nextInt
		assertEquals(0, first)
		val streamed = iterator.streamRemainingExhaustive.toArray
		val int[] expected = #[1,2,3,4]
		assertArrayEquals(expected, streamed)
		
		Util.assertEmptyIntIterator(iterator)
	}
	
	@Test
	def void testStreamRemainingExhaustiveLongIterateLimited() {
		val iterable = LongIterable.iterate(0L,[it<5L],[it+1L])
		val iterator = iterable.iterator
		val first = iterator.nextLong
		assertEquals(0, first)
		val streamed = iterator.streamRemainingExhaustive.toArray
		val long[] expected = #[1,2,3,4]
		assertArrayEquals(expected, streamed)
		
		Util.assertEmptyLongIterator(iterator)
	}
	
	@Test
	def void testStreamRemainingExhaustiveDoubleIterateLimited() {
		val iterable = DoubleIterable.iterate(0.0d,[it < 5.0d],[it + 1.0d])
		val iterator = iterable.iterator
		val first = iterator.nextDouble
		assertEquals(0.0d, first, 0.0d)
		val streamed = iterator.streamRemainingExhaustive.toArray
		val double[] expected = #[1.0d,2.0d,3.0d,4.0d]
		assertArrayEquals(expected, streamed, 0.0d)
		
		Util.assertEmptyDoubleIterator(iterator)
	}
	
	/////////////////////////////////////////
	// Primitive Array asIterable iterator //
	/////////////////////////////////////////
	
	@Test
	def void testIntArrayAsIterableIterator() {
		val int[] arr = #[0,2,4,6]
		val i = arr.asIntIterable.iterator
		val int[] result = i.streamRemaining.toArray
		assertArrayEquals(arr, result)
	}
	
	@Test
	def void testIntArrayAsIterableIteratorTakeAll() {
		val int[] arr = #[0,2,4,6]
		val i = arr.asIntIterable.iterator;
		(1..4).forEach[
			i.nextInt
		]
		val count = i.streamRemaining.count
		assertEquals(0, count)
	}
	
	@Test
	def void testIntArrayAsIterableIteratorEmpty() {
		val int[] arr = #[]
		val i = arr.asIntIterable.iterator
		val int[] result = i.streamRemaining.toArray
		assertArrayEquals(arr, result)
	}
	
	@Test
	def void testLongArrayAsIterableIterator() {
		val long[] arr = #[0L,2L,4L,6L]
		val i = arr.asLongIterable.iterator
		val long[] result = i.streamRemaining.toArray
		assertArrayEquals(arr, result)
	}
	
	@Test
	def void testLongArrayAsIterableIteratorTakeAll() {
		val long[] arr = #[0L,2L,4L,6L]
		val i = arr.asLongIterable.iterator;
		(1..4).forEach[
			i.nextLong
		]
		val count = i.streamRemaining.count
		assertEquals(0, count)
	}
	
	@Test
	def void testLongArrayAsIterableIteratorEmpty() {
		val long[] arr = #[]
		val i = arr.asLongIterable.iterator
		val long[] result = i.streamRemaining.toArray
		assertArrayEquals(arr, result)
	}
	
	@Test
	def void testDoubleArrayAsIterableIterator() {
		val double[] arr = #[0.0d,2.0d,4.0d,6.0d]
		val i = arr.asDoubleIterable.iterator
		val double[] result = i.streamRemaining.toArray
		assertArrayEquals(arr, result, 0.0d)
	}
	
	@Test
	def void testDoubleArrayAsIterableIteratorTakeAll() {
		val double[] arr = #[0.0d,2.0d,4.0d,6.0d]
		val i = arr.asDoubleIterable.iterator;
		(1..4).forEach[
			i.nextDouble
		]
		val count = i.streamRemaining.count
		assertEquals(0, count)
	}
	
	
	@Test
	def void testDoubleArrayAsIterableIteratorEmpty() {
		val double[] arr = #[]
		val i = arr.asDoubleIterable.iterator
		val double[] result = i.streamRemaining.toArray
		assertArrayEquals(arr, result, 0.0d)
	}
	
	
	@Test
	def void testIntArrayAsIterableIteratorExhaustive() {
		val int[] arr = #[0,2,4,6]
		val i = arr.asIntIterable.iterator
		val int[] result = i.streamRemainingExhaustive.toArray
		assertArrayEquals(arr, result)
		Util.assertEmptyIntIterator(i)
	}
	
	@Test
	def void testIntArrayAsIterableIteratorEmptyExhaustive() {
		val int[] arr = #[]
		val i = arr.asIntIterable.iterator
		val int[] result = i.streamRemainingExhaustive.toArray
		assertArrayEquals(arr, result)
		Util.assertEmptyIntIterator(i)
	}
	
	@Test
	def void testLongArrayAsIterableIteratorExhaustive() {
		val long[] arr = #[0L,2L,4L,6L]
		val i = arr.asLongIterable.iterator
		val long[] result = i.streamRemainingExhaustive.toArray
		assertArrayEquals(arr, result)
		Util.assertEmptyLongIterator(i)
	}
	
	@Test
	def void testLongArrayAsIterableIteratorEmptyExhaustive() {
		val long[] arr = #[]
		val i = arr.asLongIterable.iterator
		val long[] result = i.streamRemainingExhaustive.toArray
		assertArrayEquals(arr, result)
		Util.assertEmptyLongIterator(i)
	}
	
	@Test
	def void testDoubleArrayAsIterableIteratorExhaustive() {
		val double[] arr = #[0.0d,2.0d,4.0d,6.0d]
		val i = arr.asDoubleIterable.iterator
		val double[] result = i.streamRemainingExhaustive.toArray
		assertArrayEquals(arr, result, 0.0d)
		Util.assertEmptyDoubleIterator(i)
	}
	
	@Test
	def void testDoubleArrayAsIterableIteratorEmptyExhaustive() {
		val double[] arr = #[]
		val i = arr.asDoubleIterable.iterator
		val double[] result = i.streamRemainingExhaustive.toArray
		assertArrayEquals(arr, result, 0.0d)
		Util.assertEmptyDoubleIterator(i)
	}
	
	///////////////////////////////
	// Range.toIterable.iterator //
	///////////////////////////////
	
	@Test
	def void testRangeToITerableIterator() {
		val i = (0..3).asIntIterable.iterator
		val actual = i.streamRemaining.toArray
		val expected = #[0,1,2,3]
		assertArrayEquals(expected, actual)
	}
	
	@Test
	def void testRangeToITerableIteratorTakeOne() {
		val i = (0..3).asIntIterable.iterator
		assertEquals(0, i.nextInt)
		val actual = i.streamRemaining.toArray
		val expected = #[1,2,3]
		assertArrayEquals(expected, actual)
	}
	
	@Test
	def void testRangeToITerableIteratorTakeAll() {
		val i = (0..3).asIntIterable.iterator;
		(0..3).forEach[
			i.nextInt
		]
		val count = i.streamRemaining.count
		assertEquals(0, count)
	}
	
	@Test
	def void testRangeWithStepToITerableIterator() {
		val i = (0..4).withStep(2).asIntIterable.iterator
		val actual = i.streamRemaining.toArray
		val expected = #[0,2,4]
		assertArrayEquals(expected, actual)
	}
	
	
	@Test
	def void testRangeWithStepNotMatchingToITerableIterator() {
		val i = (0..5).withStep(2).asIntIterable.iterator
		val actual = i.streamRemaining.toArray
		val expected = #[0,2,4]
		assertArrayEquals(expected, actual)
	}
	
	/////////////////////////////////////
	// Iterable.mapInt.iterator.stream //
	/////////////////////////////////////
	
	@Test
	def void testIterableMapIntIteratorEmpty() {
		val stream = #[].mapInt[0].iterator.streamRemaining
		assertEquals(0, stream.count)
	}
	
	@Test
	def void testIterableMapIntIteratorElements() {
		val OfInt iterator = #["foo", "xtensions", "bar"]
			.mapInt[it.length]
			.iterator
		assertTrue(iterator.hasNext)
		assertEquals(3, iterator.nextInt)
		val stream = iterator.streamRemaining
		val int[] expected = #[9, 3]
		val actual = stream.toArray
		assertArrayEquals(expected, actual)
	}
	
	@Test
	def void testIterableMapIntIteratorAllTaken() {
		val OfInt iterator = #["foo", "xtensions", "bar"]
			.mapInt[it.length]
			.iterator;
		(1..3).forEach[iterator.nextInt]
		Util.assertEmptyIntIterator(iterator)
		val stream = iterator.streamRemaining
		assertEquals(0, stream.count)
	}
	
	
	//////////////////////////////////////
	// Iterable.mapLong.iterator.stream //
	//////////////////////////////////////
	
	@Test
	def void testIterableMapLongIteratorEmpty() {
		val stream = #[].mapLong[0L].iterator.streamRemaining
		assertEquals(0, stream.count)
	}
	
	@Test
	def void testIterableMapLongIteratorElements() {
		val OfLong iterator = #["foo", "xtensions", "bar"]
			.mapLong[it.length]
			.iterator
		assertTrue(iterator.hasNext)
		assertEquals(3L, iterator.nextLong)
		val stream = iterator.streamRemaining
		val long[] expected = #[9L, 3L]
		val actual = stream.toArray
		assertArrayEquals(expected, actual)
	}
	
	@Test
	def void testIterableMapLongIteratorAllTaken() {
		val OfLong iterator = #["foo", "xtensions", "bar"]
			.mapLong[it.length]
			.iterator;
		(1..3).forEach[iterator.nextLong]
		val stream = iterator.streamRemaining
		assertEquals(0, stream.count)
	}
	
	//////////////////////////////////////
	// Iterable.mapDouble.iterator.stream //
	//////////////////////////////////////
	
	@Test
	def void testIterableMapDoubleIteratorEmpty() {
		val stream = #[].mapDouble[0.0d].iterator.streamRemaining
		assertEquals(0, stream.count)
	}
	
	@Test
	def void testIterableMapDoubleIteratorElements() {
		val OfDouble iterator = #["1.0", "3.5", "42.0"]
			.mapDouble[Double.parseDouble(it)]
			.iterator
		assertTrue(iterator.hasNext)
		assertEquals(1.0d, iterator.nextDouble, 0.0d)
		val stream = iterator.streamRemaining
		val double[] expected = #[3.5d, 42.0d]
		val actual = stream.toArray
		assertArrayEquals(expected, actual, 0.0d)
	}
	
	@Test
	def void testIterableMapDoubleIteratorAllTaken() {
		val OfLong iterator = #["foo", "xtensions", "bar"]
			.mapLong[it.length]
			.iterator;
		(1..3).forEach[iterator.nextLong]
		val stream = iterator.streamRemaining
		assertEquals(0, stream.count)
	}
	
	
	////////////////////////////////////////////////////////
	// Iterable.mapInt.iterator.streamRemainingExhaustive //
	////////////////////////////////////////////////////////
	
	@Test
	def void testIterableMapIntIteratorExhaustiveEmpty() {
		val stream = #[].mapInt[0].iterator.streamRemainingExhaustive
		assertEquals(0, stream.count)
	}
	
	@Test
	def void testIterableMapIntIteratorExhaustiveElements() {
		val OfInt iterator = #["foo", "xtensions", "bar"]
			.mapInt[it.length]
			.iterator
		assertTrue(iterator.hasNext)
		assertEquals(3, iterator.nextInt)
		val stream = iterator.streamRemainingExhaustive
		val int[] expected = #[9, 3]
		val actual = stream.toArray
		assertArrayEquals(expected, actual)
		Util.assertEmptyIntIterator(iterator)
	}
	
	@Test
	def void testIterableMapIntIteratorExhaustiveElementsRemaining() {
		val OfInt iterator = #["foo", "xtensions", "bar"]
			.mapInt[it.length]
			.iterator
		assertTrue(iterator.hasNext)
		assertEquals(3, iterator.nextInt)
		
		// pull element via stream
		val stream = iterator.streamRemainingExhaustive.limit(1)
		val int[] expected = #[9]
		val actual = stream.toArray
		assertArrayEquals(expected, actual)
		
		// check remaining element in iterator
		val last = iterator.next
		assertEquals(3, last)
		Util.assertEmptyIntIterator(iterator)
	}
	
	@Test
	def void testIterableMapIntIteratorExhaustiveAllTaken() {
		val OfInt iterator = #["foo", "xtensions", "bar"]
			.mapInt[it.length]
			.iterator;
		(1..3).forEach[iterator.nextInt]
		val stream = iterator.streamRemainingExhaustive
		assertEquals(0, stream.count)
	}
	
	//////////////////////////////////////
	// Iterable.mapLong.iterator.stream //
	//////////////////////////////////////
	
	@Test
	def void testIterableMapLongIteratorExhaustiveEmpty() {
		val stream = #[].mapLong[0L].iterator.streamRemainingExhaustive
		assertEquals(0, stream.count)
	}
	
	@Test
	def void testIterableMapLongIteratorExhaustiveElements() {
		val OfLong iterator = #["foo", "xtensions", "bar"]
			.mapLong[it.length]
			.iterator
		assertTrue(iterator.hasNext)
		assertEquals(3L, iterator.nextLong)
		val stream = iterator.streamRemainingExhaustive
		val long[] expected = #[9L, 3L]
		val actual = stream.toArray
		assertArrayEquals(expected, actual)
	}
	
	
	def void testIterableMapLongIteratorExhaustiveElementsRemaining() {
		val OfLong iterator = #["foo", "xtensions", "bar"]
			.mapLong[it.length]
			.iterator
		assertTrue(iterator.hasNext)
		assertEquals(3L, iterator.nextLong)
		
		val stream = iterator.streamRemainingExhaustive.limit(1)
		val long[] expected = #[9L]
		val actual = stream.toArray
		assertArrayEquals(expected, actual)
		
		val last = iterator.nextLong
		assertEquals(3L, last)
		Util.assertEmptyLongIterator(iterator)
	}
	
	@Test
	def void testIterableMapLongIteratorExhaustiveAllTaken() {
		val OfLong iterator = #["foo", "xtensions", "bar"]
			.mapLong[it.length]
			.iterator;
		(1..3).forEach[iterator.nextLong]
		val stream = iterator.streamRemainingExhaustive
		assertEquals(0, stream.count)
	}
	
	////////////////////////////////////////
	// Iterable.mapDouble.iterator.stream //
	////////////////////////////////////////
	
	@Test
	def void testIterableMapDoubleIteratorExhaustiveEmpty() {
		val stream = #[].mapDouble[0.0d].iterator.streamRemainingExhaustive
		assertEquals(0, stream.count)
	}
	
	@Test
	def void testIterableMapDoubleIteratorExhaustiveElements() {
		val OfDouble iterator = #["1.0", "3.5", "42.0"]
			.mapDouble[Double.parseDouble(it)]
			.iterator
		assertTrue(iterator.hasNext)
		assertEquals(1.0d, iterator.nextDouble, 0.0d)
		val stream = iterator.streamRemainingExhaustive
		val double[] expected = #[3.5d, 42.0d]
		val actual = stream.toArray
		assertArrayEquals(expected, actual, 0.0d)
	}
	
	@Test
	def void testIterableMapDoubleIteratorExhaustiveElementsRemaining() {
		val OfDouble iterator = #["1.0", "3.5", "42.0"]
			.mapDouble[Double.parseDouble(it)]
			.iterator
		assertTrue(iterator.hasNext)
		assertEquals(1.0d, iterator.nextDouble, 0.0d)
		
		val stream = iterator.streamRemainingExhaustive.limit(1)
		val double[] expected = #[3.5d]
		val actual = stream.toArray
		assertArrayEquals(expected, actual, 0.0d)
		
		val last = iterator.nextDouble
		assertEquals(42.0d, last, 0.0d)
		Util.assertEmptyDoubleIterator(iterator)
	}
	
	@Test
	def void testIterableMapDoubleIteratorExhaustiveAllTaken() {
		val OfLong iterator = #["foo", "xtensions", "bar"]
			.mapLong[it.length]
			.iterator;
		(1..3).forEach[iterator.nextLong]
		val stream = iterator.streamRemainingExhaustive
		assertEquals(0, stream.count)
	}
	
	/////////////////////////////////
	// OptionalInt.iterator.stream //
	/////////////////////////////////
	
	@Test
	def void testOptionalIntIteratorStreamEmpty() {
		val count = OptionalInt.empty.iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	@Test
	def void testOptionalIntIteratorStreamValue() {
		val result = OptionalInt.of(42).iterator.streamRemaining.toArray
		assertArrayEquals(#[42], result)
	}
	
	@Test
	def void testOptionalIntIteratorStreamTakeAll() {
		val iterator = OptionalInt.of(42).iterator
		val first = iterator.nextInt
		assertEquals(42, first)
		
		val count = iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	// exhaustive
	
	@Test
	def void testOptionalIntIteratorExhaustiveStreamEmpty() {
		val count = OptionalInt.empty.iterator.streamRemainingExhaustive.count
		assertEquals(0, count)
	}
	
	@Test
	def void testOptionalIntIteratorExhaustiveStreamValue() {
		val iterator = OptionalInt.of(42).iterator
		val result = iterator.streamRemainingExhaustive.toArray
		assertArrayEquals(#[42], result)
		Util.assertEmptyIntIterator(iterator)
	}
	
	@Test
	def void testOptionalIntIteratorExhaustiveStreamTakeAll() {
		val iterator = OptionalInt.of(42).iterator
		val first = iterator.nextInt
		assertEquals(42, first)
		
		val count = iterator.streamRemainingExhaustive.count
		assertEquals(0, count)
	}
	
	/////////////////////////////////
	// OptionalLong.iterator.stream //
	/////////////////////////////////
	
	@Test
	def void testOptionalLongIteratorStreamEmpty() {
		val count = OptionalLong.empty.iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	@Test
	def void testOptionalLongIteratorStreamValue() {
		val result = OptionalLong.of(Long.MAX_VALUE).iterator.streamRemaining.toArray
		assertArrayEquals(#[Long.MAX_VALUE], result)
	}
	
	@Test
	def void testOptionalLongIteratorStreamTakeAll() {
		val expected = 423234534532434534L
		val iterator = OptionalLong.of(expected).iterator
		val first = iterator.nextLong
		assertEquals(expected, first)
		
		val count = iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	// exhaustive
	
	@Test
	def void testOptionalLongIteratorExhaustiveStreamEmpty() {
		val count = OptionalLong.empty.iterator.streamRemainingExhaustive.count
		assertEquals(0, count)
	}
	
	@Test
	def void testOptionalLongIteratorExhaustiveStreamValue() {
		val iterator = OptionalLong.of(Long.MAX_VALUE).iterator
		val result = iterator.streamRemainingExhaustive.toArray
		assertArrayEquals(#[Long.MAX_VALUE], result)
		Util.assertEmptyLongIterator(iterator)
	}
	
	@Test
	def void testOptionalLongIteratorExhaustiveStreamTakeAll() {
		val expected = 2345234523452345L
		val iterator = OptionalLong.of(expected).iterator
		val first = iterator.nextLong
		assertEquals(expected, first)
		
		val count = iterator.streamRemainingExhaustive.count
		assertEquals(0, count)
	}
	
	/////////////////////////////////
	// OptionalLong.iterator.stream //
	/////////////////////////////////
	
	@Test
	def void testOptionalDoubleIteratorStreamEmpty() {
		val count = OptionalDouble.empty.iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	@Test
	def void testOptionalDoubleIteratorStreamValue() {
		val result = OptionalDouble.of(Double.NaN).iterator.streamRemaining.toArray
		assertArrayEquals(#[Double.NaN], result, 0.0d)
	}
	
	@Test
	def void testOptionalDobuleIteratorStreamTakeAll() {
		val expected = 4234.3245d
		val iterator = OptionalDouble.of(expected).iterator
		val first = iterator.nextDouble
		assertEquals(expected, first, 0.0d)
		
		val count = iterator.streamRemaining.count
		assertEquals(0, count)
	}
	
	// exhaustive
	
	@Test
	def void testOptionalDoubleIteratorExhaustiveStreamEmpty() {
		val count = OptionalDouble.empty.iterator.streamRemainingExhaustive.count
		assertEquals(0, count)
	}
	
	@Test
	def void testOptionalDoubleIteratorExhaustiveStreamValue() {
		val iterator = OptionalDouble.of(Double.MAX_VALUE).iterator
		val result = iterator.streamRemainingExhaustive.toArray
		assertArrayEquals(#[Double.MAX_VALUE], result, 0.0d)
		Util.assertEmptyDoubleIterator(iterator)
	}
	
	@Test
	def void testOptionalDoubleIteratorExhaustiveStreamTakeAll() {
		val expected = 234523452.3452345d
		val iterator = OptionalDouble.of(expected).iterator
		val first = iterator.nextDouble
		assertEquals(expected, first, 0.0d)
		
		val count = iterator.streamRemainingExhaustive.count
		assertEquals(0, count)
	}
	
}