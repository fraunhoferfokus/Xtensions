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
import java.util.Iterator
import java.beans.XMLEncoder
import java.io.File
import java.util.regex.Pattern

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
	
		// ///////////////////
	// groupIntoListBy //
	// ///////////////////
	@Test(expected=NullPointerException) def void testGroupIntoListByNull() {
		val Iterator<String> it = null
		it.groupIntoListBy(Object, String)
	}

	@Test(expected=NullPointerException) def void testGroupIntoListByOneVarArgNull() {
		val Iterator<String> it = null
		it.groupIntoListBy(Object, String, Number)
	}

	@Test def void testGroupIntoListByEmpty() {
		val Iterator<String> it = #[].iterator
		val result = it.groupIntoListBy(Object, String)
		assertNotNull(result)
		val resultGroups = result.groupingClasses
		assertEquals(#[Object, String], resultGroups)

		val emptyPartition1 = result.get(Object)
		assertNotNull(emptyPartition1)
		assertEquals(0, emptyPartition1.size)

		val emptyPartition2 = result.get(Object)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)

		val emptyPartition3 = result.get(Number)
		assertNotNull(emptyPartition3)
		assertEquals(0, emptyPartition3.size)
	}

	@Test def void testGroupIntoListByEmptyNullVarArg() {
		val Iterator<String> it = #[].iterator
		val result = it.groupIntoListBy(Object, String, null)
		assertNotNull(result)
		val resultGroups = result.groupingClasses
		assertEquals(#[Object, String], resultGroups)

		val emptyPartition1 = result.get(Object)
		assertNotNull(emptyPartition1)
		assertEquals(0, emptyPartition1.size)

		val emptyPartition2 = result.get(Object)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)

		val emptyPartition3 = result.get(Number)
		assertNotNull(emptyPartition3)
		assertEquals(0, emptyPartition3.size)
	}

	@Test def void testGroupIntoListByOneVarArgEmpty() {
		val Iterator<String> it = #[].iterator
		val result = it.groupIntoListBy(Object, String, Number)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[Object, String, Number], resultGroups)

		val emptyPartition1 = result.get(Object)
		assertNotNull(emptyPartition1)
		assertEquals(0, emptyPartition1.size)

		val emptyPartition2 = result.get(Object)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)

		val emptyPartition3 = result.get(Number)
		assertNotNull(emptyPartition3)
		assertEquals(0, emptyPartition3.size)

		val emptyPartition4 = result.get(Boolean)
		assertNotNull(emptyPartition4)
		assertEquals(0, emptyPartition4.size)
	}

	@Test def void testGroupIntoListByOneVarArgLastClassMatch() {
		val expected = "foo"
		val Iterator<String> it = #[expected].iterator
		val result = it.groupIntoListBy(Number, XMLEncoder, String)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[Number, XMLEncoder, String], resultGroups)

		val emptyPartition1 = result.get(Number)
		assertNotNull(emptyPartition1)
		assertEquals(0, emptyPartition1.size)

		val emptyPartition2 = result.get(XMLEncoder)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)

		val emptyPartition3 = result.get(String)
		assertNotNull(emptyPartition3)
		assertEquals(1, emptyPartition3.size)
		val actual = emptyPartition3.head
		assertSame(expected, actual)

		val emptyPartition4 = result.get(Boolean)
		assertNotNull(emptyPartition4)
		assertEquals(0, emptyPartition4.size)
	}

	@Test def void testGroupIntoListByOneVarArgLastClassMatchNullVarArgs() {
		val expected = "foo"
		val Iterator<String> it = #[expected].iterator
		val result = it.groupIntoListBy(Number, String, null)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[Number, String], resultGroups)

		val emptyPartition1 = result.get(Number)
		assertNotNull(emptyPartition1)
		assertEquals(0, emptyPartition1.size)

		val emptyPartition3 = result.get(String)
		assertNotNull(emptyPartition3)
		assertEquals(1, emptyPartition3.size)
		val actual = emptyPartition3.head
		assertSame(expected, actual)

		val emptyPartition4 = result.get(Boolean)
		assertNotNull(emptyPartition4)
		assertEquals(0, emptyPartition4.size)
	}

	@Test def void testGroupIntoListByOneElementOneMatch() {
		val expected = "foo"
		val Iterator<String> it = #[expected].iterator
		val result = it.groupIntoListBy(String, Number)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[String, Number], resultGroups)

		val partitionWithExpected = result.get(String)
		assertNotNull(partitionWithExpected)
		assertEquals(1, partitionWithExpected.size)
		val actual = partitionWithExpected.head
		assertSame(expected, actual)

		val emptyPartition = result.get(Number)
		assertNotNull(emptyPartition)
		assertEquals(0, emptyPartition.size)

		val notGivenPartition = result.get(Integer)
		assertNotNull(notGivenPartition)
		assertEquals(0, notGivenPartition.size)
	}

	@Test def void testGroupIntoListByTwoElementsInOneGroup() {
		val expected1 = "foo"
		val expected2 = "bar"
		val Iterator<String> it = #[expected1, expected2].iterator
		val result = it.groupIntoListBy(Number, File, String)
		assertNotNull(result)

		val partitionWithExpected = result.get(String)
		assertNotNull(partitionWithExpected)
		assertEquals(2, partitionWithExpected.size)
		val msg = "Expected element in partition group"
		assertTrue(msg, partitionWithExpected.contains(expected1))
		assertTrue(msg, partitionWithExpected.contains(expected2))

		val emptyPartition = result.get(Number)
		assertNotNull(emptyPartition)
		assertEquals(0, emptyPartition.size)

		val emptyPartition2 = result.get(File)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)
	}

	@Test def void testGroupIntoListByTwoElementsTwoGroups() {
		val expected1 = "foo"
		val expected2 = 25L
		val it = #[expected1, expected2].iterator
		val result = it.groupIntoListBy(Long, File, String)
		assertNotNull(result)

		val stringPartition = result.get(String)
		assertNotNull(stringPartition)
		assertEquals(1, stringPartition.size)
		val msg = "Expected element in partition group"
		assertEquals(msg, expected1, stringPartition.head)

		val longPartition = result.get(Long)
		assertNotNull(longPartition)
		assertEquals(1, longPartition.size)
		assertEquals(expected2, longPartition.head)

		val emptyPartition2 = result.get(File)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)
	}

	@Test def void testGroupIntoListByMachSubclass() {
		val expected = 42L
		val it = #[expected].iterator
		val result = it.groupIntoListBy(Number, File)
		assertNotNull(result)

		val numberPartition = result.get(Number)
		assertNotNull(numberPartition)
		assertEquals(1, numberPartition.size)
		assertEquals(expected, numberPartition.head)
	}

	@Test def void testGroupIntoListByOneElementNoMatch() {
		val expected = "foo"
		val it = #[expected].iterator
		val result = it.groupIntoListBy(StringBuilder, Number)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[StringBuilder, Number], resultGroups)

		val partitionWithExpected = result.get(StringBuilder)
		assertNotNull(partitionWithExpected)
		assertEquals(0, partitionWithExpected.size)

		val emptyPartition = result.get(Number)
		assertNotNull(emptyPartition)
		assertEquals(0, emptyPartition.size)

		val notGivenPartition = result.get(Integer)
		assertNotNull(notGivenPartition)
		assertEquals(0, notGivenPartition.size)
	}

	@Test def void testGroupIntoListByOneElementSuperClassMatchesFirst() {
		val expected = "foo"
		val it = #[expected].iterator
		val result = it.groupIntoListBy(Object, String)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[Object, String], resultGroups)

		val partitionWithExpected = result.get(Object)
		assertNotNull(partitionWithExpected)
		assertEquals(1, partitionWithExpected.size)
		val actual = partitionWithExpected.head
		assertSame(expected, actual)

		val emptyPartition = result.get(String)
		assertNotNull(emptyPartition)
		assertEquals(0, emptyPartition.size)
	}

	@Test def void testGroupIntoListByGroupingClassesTwice() {
		val expected = "foo"
		val it = #[expected].iterator
		val result = it.groupIntoListBy(Object, String)

		val resultGroups = result.groupingClasses
		assertEquals(#[Object, String], resultGroups)
		val resultGroups2 = result.groupingClasses
		assertEquals(#[Object, String], resultGroups2)
	}

	@Test def void testGroupIntoListByAsMap() {
		val expected = "foo"
		val it = #[expected].iterator
		val result = it.groupIntoListBy(Number, String, Boolean)

		val resultMap = result.asMap

		resultMap.get(String) => [
			assertNotNull(it)
			assertEquals(#[expected], it)
		]

		resultMap.get(Number) => [
			assertNull(it)
		]

		resultMap.get(Boolean) => [
			assertNull(it)
		]

		resultMap.get(Pattern) => [
			assertNull(it)
		]
	}

	// ///////////////////
	// groupIntoSetBy //
	// ///////////////////
	@Test(expected=NullPointerException) def void testGroupIntoSetByNull() {
		val Iterator<String> it = null
		it.groupIntoSetBy(Object, String)
	}

	@Test(expected=NullPointerException) def void testGroupIntoSetByOneVarArgNull() {
		val Iterator<String> it = null
		it.groupIntoSetBy(Object, String, Number)
	}

	@Test def void testGroupIntoSetByEmpty() {
		val Iterator<String> it = #[].iterator
		val result = it.groupIntoSetBy(Object, String)
		assertNotNull(result)
		val resultGroups = result.groupingClasses
		assertEquals(#[Object, String], resultGroups)

		val emptyPartition1 = result.get(Object)
		assertNotNull(emptyPartition1)
		assertEquals(0, emptyPartition1.size)

		val emptyPartition2 = result.get(Object)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)

		val emptyPartition3 = result.get(Number)
		assertNotNull(emptyPartition3)
		assertEquals(0, emptyPartition3.size)
	}

	@Test def void testGroupIntoSetByEmptyNullVarArg() {
		val it = #[].iterator
		val result = it.groupIntoSetBy(Object, String, null)
		assertNotNull(result)
		val resultGroups = result.groupingClasses
		assertEquals(#[Object, String], resultGroups)

		val emptyPartition1 = result.get(Object)
		assertNotNull(emptyPartition1)
		assertEquals(0, emptyPartition1.size)

		val emptyPartition2 = result.get(Object)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)

		val emptyPartition3 = result.get(Number)
		assertNotNull(emptyPartition3)
		assertEquals(0, emptyPartition3.size)
	}

	@Test def void testGroupIntoSetByOneVarArgEmpty() {
		val Iterator<String> it = #[].iterator
		val result = it.groupIntoSetBy(Object, String, Number)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[Object, String, Number], resultGroups)

		val emptyPartition1 = result.get(Object)
		assertNotNull(emptyPartition1)
		assertEquals(0, emptyPartition1.size)

		val emptyPartition2 = result.get(Object)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)

		val emptyPartition3 = result.get(Number)
		assertNotNull(emptyPartition3)
		assertEquals(0, emptyPartition3.size)

		val emptyPartition4 = result.get(Boolean)
		assertNotNull(emptyPartition4)
		assertEquals(0, emptyPartition4.size)
	}

	@Test def void testGroupIntoSetByOneVarArgLastClassMatch() {
		val expected = "foo"
		val Iterator<String> it = #[expected].iterator
		val result = it.groupIntoSetBy(Number, XMLEncoder, String)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[Number, XMLEncoder, String], resultGroups)

		val emptyPartition1 = result.get(Number)
		assertNotNull(emptyPartition1)
		assertEquals(0, emptyPartition1.size)

		val emptyPartition2 = result.get(XMLEncoder)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)

		val emptyPartition3 = result.get(String)
		assertNotNull(emptyPartition3)
		assertEquals(1, emptyPartition3.size)
		val actual = emptyPartition3.head
		assertSame(expected, actual)

		val emptyPartition4 = result.get(Boolean)
		assertNotNull(emptyPartition4)
		assertEquals(0, emptyPartition4.size)
	}

	@Test def void testGroupIntoSetByOneVarArgLastClassMatchNullVarArgs() {
		val expected = "foo"
		val Iterator<String> it = #[expected].iterator
		val result = it.groupIntoSetBy(Number, String, null)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[Number, String], resultGroups)

		val emptyPartition1 = result.get(Number)
		assertNotNull(emptyPartition1)
		assertEquals(0, emptyPartition1.size)

		val emptyPartition3 = result.get(String)
		assertNotNull(emptyPartition3)
		assertEquals(1, emptyPartition3.size)
		val actual = emptyPartition3.head
		assertSame(expected, actual)

		val emptyPartition4 = result.get(Boolean)
		assertNotNull(emptyPartition4)
		assertEquals(0, emptyPartition4.size)
	}

	@Test def void testGroupIntoSetByOneElementOneMatch() {
		val expected = "foo"
		val Iterator<String> it = #[expected].iterator
		val result = it.groupIntoListBy(String, Number)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[String, Number], resultGroups)

		val partitionWithExpected = result.get(String)
		assertNotNull(partitionWithExpected)
		assertEquals(1, partitionWithExpected.size)
		val actual = partitionWithExpected.head
		assertSame(expected, actual)

		val emptyPartition = result.get(Number)
		assertNotNull(emptyPartition)
		assertEquals(0, emptyPartition.size)

		val notGivenPartition = result.get(Integer)
		assertNotNull(notGivenPartition)
		assertEquals(0, notGivenPartition.size)
	}

	@Test def void testGroupIntoSetByTwoElementsInOneGroup() {
		val expected1 = "foo"
		val expected2 = "bar"
		val it = #[expected1, expected2].iterator
		val result = it.groupIntoSetBy(Number, File, String)
		assertNotNull(result)

		val partitionWithExpected = result.get(String)
		assertNotNull(partitionWithExpected)
		assertEquals(2, partitionWithExpected.size)
		val msg = "Expected element in partition group"
		assertTrue(msg, partitionWithExpected.contains(expected1))
		assertTrue(msg, partitionWithExpected.contains(expected2))

		val emptyPartition = result.get(Number)
		assertNotNull(emptyPartition)
		assertEquals(0, emptyPartition.size)

		val emptyPartition2 = result.get(File)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)
	}

	@Test def void testGroupIntoSetByTwoElementsTwoGroups() {
		val expected1 = "foo"
		val expected2 = 25L
		val it = #[expected1, expected2].iterator
		val result = it.groupIntoSetBy(Long, File, String)
		assertNotNull(result)

		val stringPartition = result.get(String)
		assertNotNull(stringPartition)
		assertEquals(1, stringPartition.size)
		val msg = "Expected element in partition group"
		assertEquals(msg, expected1, stringPartition.head)

		val longPartition = result.get(Long)
		assertNotNull(longPartition)
		assertEquals(1, longPartition.size)
		assertEquals(expected2, longPartition.head)

		val emptyPartition2 = result.get(File)
		assertNotNull(emptyPartition2)
		assertEquals(0, emptyPartition2.size)
	}

	@Test def void testGroupIntoSetByMachSubclass() {
		val expected = 42L
		val it = #[expected].iterator
		val result = it.groupIntoSetBy(Number, File)
		assertNotNull(result)

		val numberPartition = result.get(Number)
		assertNotNull(numberPartition)
		assertEquals(1, numberPartition.size)
		assertEquals(expected, numberPartition.head)
	}

	@Test def void testGroupIntoSetByOneElementNoMatch() {
		val expected = "foo"
		val it = #[expected].iterator
		val result = it.groupIntoSetBy(StringBuilder, Number)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[StringBuilder, Number], resultGroups)

		val partitionWithExpected = result.get(StringBuilder)
		assertNotNull(partitionWithExpected)
		assertEquals(0, partitionWithExpected.size)

		val emptyPartition = result.get(Number)
		assertNotNull(emptyPartition)
		assertEquals(0, emptyPartition.size)

		val notGivenPartition = result.get(Integer)
		assertNotNull(notGivenPartition)
		assertEquals(0, notGivenPartition.size)
	}

	@Test def void testGroupIntoSetByOneElementSuperClassMatchesFirst() {
		val expected = "foo"
		val it = #[expected].iterator
		val result = it.groupIntoSetBy(Object, String)
		assertNotNull(result)

		val resultGroups = result.groupingClasses
		assertEquals(#[Object, String], resultGroups)

		val partitionWithExpected = result.get(Object)
		assertNotNull(partitionWithExpected)
		assertEquals(1, partitionWithExpected.size)
		val actual = partitionWithExpected.head
		assertSame(expected, actual)

		val emptyPartition = result.get(String)
		assertNotNull(emptyPartition)
		assertEquals(0, emptyPartition.size)
	}

	@Test def void testGroupIntoSetByGroupingClassesTwice() {
		val expected = "foo"
		val it = #[expected].iterator
		val result = it.groupIntoSetBy(Object, String)

		val resultGroups = result.groupingClasses
		assertEquals(#[Object, String], resultGroups)
		val resultGroups2 = result.groupingClasses
		assertEquals(#[Object, String], resultGroups2)
	}

	@Test def void testGroupIntoSetByAsMap() {
		val expected = "foo"
		val it = #[expected].iterator
		val result = it.groupIntoSetBy(Number, String, Boolean)

		val resultMap = result.asMap

		resultMap.get(String) => [
			assertNotNull(it)
			assertEquals(#{expected}, it)
		]

		resultMap.get(Number) => [
			assertNull(it)
		]

		resultMap.get(Boolean) => [
			assertNull(it)
		]

		resultMap.get(Pattern) => [
			assertNull(it)
		]
	}
}