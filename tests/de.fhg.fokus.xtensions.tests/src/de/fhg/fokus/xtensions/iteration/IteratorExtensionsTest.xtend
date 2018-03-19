package de.fhg.fokus.xtensions.iteration

import static extension de.fhg.fokus.xtensions.iteration.IteratorExtensions.*
import org.junit.Test
import static org.junit.Assert.*
import java.util.List
import de.fhg.fokus.xtensions.Util
import java.util.NoSuchElementException
import java.util.PrimitiveIterator.OfInt
import java.util.PrimitiveIterator.OfLong
import java.util.PrimitiveIterator.OfDouble

class IteratorExtensionsTest {
	////////////
	// mapInt //
	////////////

	@Test(expected = NullPointerException) def void mapIntIterableNull() {
		mapInt(null)[fail();0]
	}
	
	@Test(expected = NullPointerException) def void mapIntMapperNull() {
		#[].iterator.mapInt(null)
	}
	
	@Test def void mapIntEmpty() {
		val ints = #[].iterator.mapInt[fail();0]
		assertFalse(ints.hasNext)
		Util.expectException(NoSuchElementException) [
			ints.nextInt
		]
	}
	
	@Test def void mapIntOneElement() {
		val source = "foo"
		val expected = 3
		val ints = #[source].iterator.mapInt[length]
		
		assertTrue(ints.hasNext)
		val actual = ints.nextInt
		assertEquals(expected, actual)
		assertFalse(ints.hasNext)
		Util.expectException(NoSuchElementException) [
			ints.nextInt
		]
	}
	
	@Test def void mapIntMultipleElements() {
		val source = #["a", "foo", "geeee"]
		val ints = source.iterator.mapInt[length]
		
		val expected = source.map[length]
		ints.assertProvides(expected)
	}
	
	private def void assertProvides(OfInt ints, Iterable<Integer> expected) {
		expected.forEach [
			assertTrue(ints.hasNext)
			assertEquals(it, ints.nextInt)
		]
		assertFalse(ints.hasNext)
		Util.expectException(NoSuchElementException) [
			ints.nextInt
		]
	}
	
	/////////////
	// mapLong //
	/////////////

	@Test(expected = NullPointerException) def void mapLongIterableNull() {
		mapLong(null)[fail();0]
	}
	
	@Test(expected = NullPointerException) def void mapLongMapperNull() {
		#[].iterator.mapLong(null)
	}
	
	@Test def void mapLongEmpty() {
		val longs = #[].iterator.mapLong[fail();0]
		
		assertFalse(longs.hasNext)
		Util.expectException(NoSuchElementException) [
			longs.nextLong
		]
	}
	
	@Test def void mapLongOneElement() {
		val source = "foo"
		val expected = Long.MAX_VALUE
		val ints = #[source].iterator.mapLong[expected]
		
		assertTrue(ints.hasNext)
		val actual = ints.nextLong
		assertEquals(expected, actual)
		assertFalse(ints.hasNext)
		
		Util.expectException(NoSuchElementException) [
			ints.nextLong
		]
	}
	
	@Test def void mapLongMultipleElements() {
		val expected = #["a", "foo", "geeee"]
		val longs = expected.iterator.mapLong[length]
		
		val long[] expectedOut = #[
			expected.get(0).length,
			expected.get(1).length,
			expected.get(2).length
		]
		
		longs.assertProvides(expectedOut)
	}
	
	private def void assertProvides(OfLong longs, Iterable<Long> expected) {
		expected.forEach [
			assertTrue(longs.hasNext)
			assertEquals(it, longs.nextLong)
		]
		assertFalse(longs.hasNext)
		Util.expectException(NoSuchElementException) [
			longs.nextLong
		]
	}
	
	///////////////
	// mapDouble //
	///////////////
	
	@Test(expected = NullPointerException) def void mapDoubleIterableNull() {
		mapDouble(null)[fail();0]
	}
	
	@Test(expected = NullPointerException) def void mapDoubleMapperNull() {
		#[].iterator.mapDouble(null)
	}
	
	@Test def void mapDoubleEmpty() {
		val doubles = #[].iterator.mapDouble[fail();0]
		
		assertFalse(doubles.hasNext)
		Util.expectException(NoSuchElementException) [
			doubles.nextDouble
		]
	}
	
	@Test def void mapDoubleOneElement() {
		val source = "foo"
		val expected = Double.MAX_VALUE
		val doubles = #[source].iterator.mapDouble[expected]
		
		assertTrue(doubles.hasNext)
		val actual = doubles.next
		assertEquals(expected, actual, 0.0d)
		assertFalse(doubles.hasNext)
		Util.expectException(NoSuchElementException) [
			doubles.nextDouble
		]
	}
	
	@Test def void mapDoubleMultipleElements() {
		val List<Double> expected = #[4.0d, Double.NaN, Double.NEGATIVE_INFINITY]
		val doubles = expected.iterator.mapDouble[it]
		
		val double[] expectedOut = #[
			expected.get(0),
			expected.get(1),
			expected.get(2)
		]
		
		doubles.assertProvides(expectedOut)
	}
	
	private def void assertProvides(OfDouble doubles, Iterable<Double> expected) {
		expected.forEach [
			assertTrue(doubles.hasNext)
			assertEquals(it, doubles.nextDouble, 0.0d)
		]
		assertFalse(doubles.hasNext)
		Util.expectException(NoSuchElementException) [
			doubles.nextDouble
		]
	}
}