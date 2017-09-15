package de.fhg.fokus.xtensions.iteration

import org.junit.Test
import static extension de.fhg.fokus.xtensions.iteration.IterableExtensions.*
import static org.junit.Assert.*
import static java.util.stream.Collectors.*
import java.util.Arrays
import de.fhg.fokus.xtensions.Util
import java.util.NoSuchElementException
import java.util.List

class IterableExtensionsTest {

	/////////////
	// collect //
	/////////////

	@Test def testCollect() {
		val joined = #["foo", "bar", "baz"].collect(joining(",", "'", "'"))
		assertEquals("'foo,bar,baz'", joined)
		
		val joinedEmpty = #[].collect(joining(",", "'", "'"))
		assertEquals("''", joinedEmpty)
	}

	////////////
	// stream //
	////////////
	
	@Test def iterableEmptyCollectionStream() {
		val Iterable<String> iterable = #[]
		val result = iterable.stream.toArray
		assertEquals(0, result.length)
	}

	@Test def iterableCollectionStream() {
		val String[] expected = #["foo", null, "bar", ""]
		val Iterable<String> iterable = Arrays.asList(expected)
		val result = iterable.stream.toArray
		assertArrayEquals(expected, result)
	}
	
	@Test def iterableEmptyIterableStream() {
		val Iterable<String> iterable = [#[].iterator]
		val result = iterable.stream.toArray
		assertEquals(0, result.length)
	}

	@Test def iterableIterableStream() {
		val String[] expected = #["foo", null, "bar", ""]
		val Iterable<String> iterable = [expected.iterator]
		val result = iterable.stream.toArray
		assertArrayEquals(expected, result)
	}

	////////////////////
	// parallelStream //
	////////////////////

	
	@Test def iterableEmptyCollectionParallelStream() {
		val Iterable<String> iterable = #[]
		val result = iterable.parallelStream.toArray
		assertEquals(0, result.length)
	}

	@Test def iterableCollectionParallelStream() {
		val String[] expected = #["foo", null, "bar", ""]
		val Iterable<String> iterable = Arrays.asList(expected)
		val result = iterable.parallelStream.toArray
		assertArrayEquals(expected, result)
	}
	
	@Test def iterableEmptyIterableParallelStream() {
		val Iterable<String> iterable = [#[].iterator]
		val result = iterable.parallelStream.toArray
		assertEquals(0, result.length)
	}

	@Test def iterableIterableParallelStream() {
		val String[] expected = #["foo", null, "bar", ""]
		val Iterable<String> iterable = [expected.iterator]
		val result = iterable.parallelStream.toArray
		assertArrayEquals(expected, result)
	}
	
	////////////
	// mapInt //
	////////////

	@Test(expected = NullPointerException) def void mapIntIterableNull() {
		mapInt(null)[fail();0]
	}
	
	@Test(expected = NullPointerException) def void mapIntMapperNull() {
		#[].mapInt(null)
	}
	
	@Test def void mapIntEmpty() {
		val ints = #[].mapInt[fail();0]
		
		val streamCount = ints.stream.count
		assertEquals(0, streamCount)
		
		ints.forEachInt[
			fail()
		]
		
		val iterator = ints.iterator
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextInt
		]
	}
	
	@Test def void mapIntOneElement() {
		val expected = "foo"
		val ints = #[expected].mapInt[length]
		
		val streamCount = ints.stream.count
		assertEquals(1, streamCount)
		
		val iterator = ints.iterator
		assertTrue(iterator.hasNext)
		val next = iterator.nextInt
		assertEquals(expected.length, next)
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextInt
		]
	}
	
	@Test def void mapIntMultipleElements() {
		val expected = #["a", "foo", "geeee"]
		val ints = expected.mapInt[length]
		
		val streamOut = newArrayList
		ints.stream.forEach[streamOut.add(it)]
		assertEquals(expected.map[length].toList, streamOut)
		
		val iterator = ints.iterator
		assertTrue(iterator.hasNext)
		for(str : expected) {
			val next = iterator.nextInt
			assertEquals(str.length, next)
		}
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextInt
		]
		
	}
	
	/////////////
	// mapLong //
	/////////////

	@Test(expected = NullPointerException) def void mapLongIterableNull() {
		mapLong(null)[fail();0]
	}
	
	@Test(expected = NullPointerException) def void mapLongMapperNull() {
		#[].mapLong(null)
	}
	
	@Test def void mapLongEmpty() {
		val longs = #[].mapLong[fail();0]
		
		val streamCount = longs.stream.count
		assertEquals(0, streamCount)
		
		longs.forEachLong[
			fail()
		]
		
		val iterator = longs.iterator
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextLong
		]
	}
	
	@Test def void mapLongOneElement() {
		val source = "foo"
		val expected = Long.MAX_VALUE
		val ints = #[source].mapLong[expected]
		
		val longArr = ints.stream.toArray
		assertArrayEquals(#[expected], longArr)
		
		val iterator = ints.iterator
		assertTrue(iterator.hasNext)
		val next = iterator.nextLong
		assertEquals(expected, next)
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextLong
		]
	}
	
	@Test def void mapLongMultipleElements() {
		val expected = #["a", "foo", "geeee"]
		val longs = expected.mapLong[length]
		
		val long[] expectedOut = #[
			expected.get(0).length,
			expected.get(1).length,
			expected.get(2).length
		]
		val streamOut = longs.stream.toArray
		assertArrayEquals(expectedOut, streamOut)
		
		val iterator = longs.iterator
		assertTrue(iterator.hasNext)
		for(l : expectedOut) {
			val next = iterator.nextLong
			assertEquals(l, next)
		}
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextLong
		]
		
	}
	
	///////////////
	// mapDouble //
	///////////////
	
	@Test(expected = NullPointerException) def void mapDoubleIterableNull() {
		mapDouble(null)[fail();0]
	}
	
	@Test(expected = NullPointerException) def void mapDoubleMapperNull() {
		#[].mapDouble(null)
	}
	
	@Test def void mapDoubleEmpty() {
		val longs = #[].mapDouble[fail();0]
		
		val streamCount = longs.stream.count
		assertEquals(0, streamCount)
		
		longs.forEachDouble[
			fail()
		]
		
		val iterator = longs.iterator
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextDouble
		]
	}
	
	@Test def void mapDoubleOneElement() {
		val source = "foo"
		val expected = Double.MAX_VALUE
		val doubles = #[source].mapDouble[expected]
		
		val doubleArr = doubles.stream.toArray
		assertArrayEquals(#[expected], doubleArr, 0.0d)
		
		val iterator = doubles.iterator
		assertTrue(iterator.hasNext)
		val next = iterator.nextDouble
		assertEquals(expected, next, 0.0d)
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextDouble
		]
	}
	
	@Test def void mapDoubleMultipleElements() {
		val List<Double> expected = #[4.0d, Double.NaN, Double.NEGATIVE_INFINITY]
		val longs = expected.mapDouble[it]
		
		val double[] expectedOut = #[
			expected.get(0),
			expected.get(1),
			expected.get(2)
		]
		val streamOut = longs.stream.toArray
		assertArrayEquals(expectedOut, streamOut, 0.0d)
		
		val iterator = longs.iterator
		assertTrue(iterator.hasNext)
		for(l : expectedOut) {
			val next = iterator.nextDouble
			assertEquals(l, next, 0.0d)
		}
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextDouble
		]
		
	}
}
