/*******************************************************************************
 * Copyright (c) 2017-2018 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 * 
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
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
import java.util.ArrayList
import java.util.Collections
import java.util.Arrays
import java.util.Set
import java.util.stream.Collectors
import java.util.function.Predicate
import java.util.Collection

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
	
	////////////////
	// withoutAll //
	////////////////
	
	@Test(expected = NullPointerException) def void testWithoutAllIteratorNull() {
		val Iterator<?> i = null
		i.withoutAll(#[])
	}
	
	@Test(expected = NullPointerException) def void testWithoutAllToExcludeNull() {
		val Iterator<?> i = #[].iterator
		i.withoutAll(null)
	}
	
	@Test def void testWithoutAllEmtpyIterator() {
		val Iterator<?> i = #[].iterator
		val result = i.withoutAll(#["Foo", 1L])
		Util.assertEmptyIterator(result)
	}
	
	@Test def void testWithoutAllFilterNoElements() {
		val source = #["foo", "bar", 42L]
		val i = source.iterator
		val result = i.withoutAll(#[Pattern.compile(".*"), "boo"]).toList
		assertEquals(source, result)
	}
	
	@Test def void testWithoutAllFilterNoElementsIterable() {
		val source = #["foo", "bar", 42L]
		val i = source.iterator
		val List<Object> excludeList = #[Pattern.compile(".*"), "boo"]
		val Iterable<?> toExclude = [|excludeList.iterator]
		val result = i.withoutAll(toExclude).toList
		assertEquals(source, result)
	}
	
	@Test def void testWithoutAllFilterAllElements() {
		val source = #["foo", "bar", 42L]
		val List<Object> toExclude = new ArrayList(source)
		toExclude.add(300)
		val i = source.iterator
		val result = i.withoutAll(toExclude)
		Util.assertEmptyIterator(result)
	}
	
	@Test def void testWithoutAllFilterAllElementsIterable() {
		val source = #["foo", "bar", 42L]
		val toExclude = source + #[300]
		val i = source.iterator
		val result = i.withoutAll(toExclude)
		Util.assertEmptyIterator(result)
	}
	
	@Test def void testWithoutAllFilterSomeElements() {
		val List<Object> toExclude = newArrayList("foo", 42L)
		val source = new ArrayList(toExclude)
		val expectedRemaining = "bar"
		source.add(expectedRemaining)
		val i = source.iterator
		val result = i.withoutAll(toExclude)
		val actual = result.next
		assertSame(expectedRemaining, actual)
		Util.assertEmptyIterator(result)
	}
	
	@Test def void testWithoutAllFilterSomeElementsIterable() {
		val List<Object> toExcludeList = newArrayList("foo", 42L)
		val Iterable<?> toExclude = [|toExcludeList.iterator]
		val source = new ArrayList(toExcludeList)
		val expectedRemaining = "bar"
		source.add(expectedRemaining)
		val i = source.iterator
		val result = i.withoutAll(toExclude)
		val actual = result.next
		assertSame(expectedRemaining, actual)
		Util.assertEmptyIterator(result)
	}
	
	//////////////////
	// combinations //
	//////////////////
	
	@Test(expected = NullPointerException) def void testCombinationsIteratorNull() {
		val Iterator<String> iterator = null
		iterator.combinations(#["foo"])
	}
	
	@Test(expected = NullPointerException) def void testCombinationsOtherNull() {
		val Iterator<String> iterator = #["foo"].iterator
		iterator.combinations(null)
	}
	
	@Test def void testCombinationsIteratorEmptyIterable() {
		val list = Collections.emptyIterator.combinations(#["foo", "bar"]).toList
		assertTrue(list.empty)
	}
	
	@Test def void testCombinationsOtherEmpty() {
		val list = Arrays.asList("foo", "bar").iterator.combinations(#[]).toList
		assertTrue(list.empty)
	}
	
	@Test def void testCombinationsIteratorAndOtherWithElements() {
		val result = Arrays.asList("foo", "bar")
			.iterator
			.combinations(#[1,2])
			.toSet
		val Set<Pair<String,Integer>> expected = #{"foo"->1, "bar"->1, "foo"->2, "bar"->2}
		assertEquals(expected, result)
	}
	
	///////////////////////////
	// combinations (merger) //
	///////////////////////////
	
	@Test(expected = NullPointerException) def void testCombinationsMergeIteratorNull() {
		val Iterator<String> iterator = null
		iterator.combinations(#["foo"])[a,b| a+b]
	}
	
	@Test(expected = NullPointerException) def void testCombinationsMergeOtherNull() {
		val Iterator<String> iterator = #["foo"].iterator
		iterator.combinations(null)[a,b| a+b]
	}
	
	@Test(expected = NullPointerException) def void testCombinationsMergeMergerNull() {
		val result = Arrays.asList("foo", "bar")
			.iterator
			.combinations(#[1,2], null)
	}
	
	@Test def void testCombinationsMergeIteratorEmptyIterable() {
		val list = Collections
			.emptyIterator
			.combinations(#["foo", "bar"])[a,b| a+b]
			.toList
		assertTrue(list.empty)
	}
	
	@Test def void testCombinationsMergeOtherEmpty() {
		val list = Arrays.asList("foo", "bar").iterator.combinations(#[]).toList
		assertTrue(list.empty)
	}
	
	@Test def void testCombinationsMergeIteratorAndOtherWithElements() {
		val Set<String> result = Arrays.asList("foo", "bar")
			.iterator
			.combinations(#[1,2])[a,b| a+b]
			.toSet
		val Set<String> expected = #{"foo1", "bar1", "foo2","bar2"}
		assertEquals(expected, result)
	}
	
	///////////////////////
	// combinationsWhere //
	///////////////////////
	
	@Test(expected = NullPointerException) def void testCombinationsWhereIteratorNull() {
		val Iterator<String> iterator = null
		iterator.combinationsWhere(#["foo"])[true]
	}
	
	@Test(expected = NullPointerException) def void testCombinationsWhereOtherNull() {
		val Iterator<String> iterator = #["foo"].iterator
		iterator.combinationsWhere(null)[true]
	}
	
	@Test(expected = NullPointerException) def void testCombinationsWhereWhereNull() {
		val result = Arrays.asList("foo", "bar")
			.iterator
			.combinationsWhere(#[1,2], null)
	}
	
	@Test def void testCombinationsWhereIteratorEmptyIterable() {
		val list = Collections
			.emptyIterator
			.combinationsWhere(#["foo", "bar"])[true]
			.toList
		assertTrue(list.empty)
	}
	
	@Test def void testCombinationsWhereOtherEmpty() {
		val list = Arrays.asList("foo", "bar").iterator.combinationsWhere(#[])[true].toList
		assertTrue(list.empty)
	}
	
	@Test def void testCombinationsWhereIteratorAndOtherWithElements() {
		val Set<Pair<String,Integer>> result = Arrays.asList("foo", "bar", "baz")
			.iterator
			.combinationsWhere(#[1,2,3,4])[a,b| a.startsWith("b") && (b % 2 == 0)]
			.toSet
		val Set<Pair<String,Integer>> expected = #{"bar" -> 2, "bar" -> 4, "baz" -> 2, "baz" -> 4}
		assertEquals(expected, result)
	}
	
	
	///////////////////////////////
	// combinationsWhere (merge) //
	///////////////////////////////
	
	@Test(expected = NullPointerException) def void testCombinationsWhereMergeIteratorNull() {
		val Iterator<String> iterator = null
		iterator.combinationsWhere(#["foo"],[true])[a,b| a+b]
	}
	
	@Test(expected = NullPointerException) def void testCombinationsWhereMergeOtherNull() {
		val Iterator<String> iterator = #["foo"].iterator
		iterator.combinationsWhere(null,[true])[a,b| a+b]
	}
	
	@Test(expected = NullPointerException) def void testCombinationsWhereMergeWhereNull() {
		val result = Arrays.asList("foo", "bar")
			.iterator
			.combinationsWhere(#[1,2], null)[a,b| a+b]
	}
	
	@Test(expected = NullPointerException) def void testCombinationsWhereMergeMergerNull() {
		val result = Arrays.asList("foo", "bar")
			.iterator
			.combinationsWhere(#[1,2], [true], null)
	}
	
	@Test def void testCombinationsWhereMergeIteratorEmptyIterable() {
		val list = Collections
			.emptyIterator
			.combinationsWhere(#["foo", "bar"],[true])[a,b| a+b]
			.toList
		assertTrue(list.empty)
	}
	
	@Test def void testCombinationsWhereMergeOtherEmpty() {
		val list = Arrays.asList("foo", "bar").iterator.combinationsWhere(#[],[true])[a,b| a+b].toList
		assertTrue(list.empty)
	}
	
	@Test def void testCombinationsWhereMergeIteratorAndOtherWithElements() {
		val Set<String> result = Arrays.asList("foo", "bar", "baz")
			.iterator
			.combinationsWhere(#[1,2,3,4],[a,b| a.startsWith("b") && (b % 2 == 0)])[a,b| a+b]
			.toSet
		val Set<String> expected = #{"bar2", "bar4", "baz2", "baz4"}
		assertEquals(expected, result)
	}
	
	//////////////////////////////////
	// partitionBy (selectionClass) //
	//////////////////////////////////
	
	@Test(expected = NullPointerException) def void testPartitionBySelectionClassIteratorNull() {
		val Iterator<String> i = null
		i.partitionBy(Integer)
	}
	
	@Test(expected = NullPointerException) def void testPartitionBySelectionClassSelectionClassNull() {
		val Iterator<String> i = #[].iterator
		i.partitionBy(null as Class<String>)
	}
	
	@Test def void testPartitionBySelectionClassEmptyIterable() {
		val Iterator<Number> i = #[].iterator
		val result = i.partitionBy(Integer)
		assertNotNull(result)
		val selected = result.selected
		assertNotNull(selected)
		assertTrue(selected.empty)
		val rejected = result.rejected
		assertNotNull(rejected)
		assertTrue(rejected.empty)
	}
	
	@Test def void testPartitionBySelectionClassOnlySelected() {
		val List<Number> l = #[32, 64, 4711]
		val Iterator<Number> i = l.iterator
		val result = i.partitionBy(Integer)
		assertNotNull(result)
		val selected = result.selected
		assertNotNull(selected)
		assertEquals(selected, l)
		val rejected = result.rejected
		assertNotNull(rejected)
		assertTrue(rejected.empty)
	}
	
	@Test def void testPartitionBySelectionClassOnlyRejected() {
		val List<Number> l = #[11, 4533, 91]
		val Iterator<Number> i = l.iterator
		val result = i.partitionBy(Double)
		assertNotNull(result)
		val rejected = result.rejected
		assertNotNull(rejected)
		assertEquals(rejected, l)
		val selected = result.selected
		assertNotNull(selected)
		assertTrue(selected.empty)
	}
	
	@Test def void testPartitionBySelectionClass() {
		val List<Number> l = #[64d, 33, 51f, 4711]
		val Iterator<Number> i = l.iterator
		val result = i.partitionBy(Integer)
		assertNotNull(result)
		val rejected = result.rejected
		assertNotNull(rejected)
		assertEquals(#[64d, 51f], rejected)
		val selected = result.selected
		assertNotNull(selected)
		assertEquals(#[33, 4711], selected)
	}
	
	////////////////////////////////////////////////////////////////////////
	// partitionBy (selectionClass, selectedCollector, rejectedCollector) //
	////////////////////////////////////////////////////////////////////////
	
	
	@Test(expected = NullPointerException) def void testPartitionBySelectionClassCollectorsIteratorNull() {
		val Iterator<String> i = null
		val selectedCollector = Collectors::toSet
		val rejectedCollector = Collectors::toSet
		i.partitionBy(Integer,selectedCollector,rejectedCollector)
	}
	
	@Test(expected = NullPointerException) def void testPartitionBySelectionClassCollectorSelectionClassNull() {
		val Iterator<String> i = #[].iterator
		val selectedCollector = Collectors::toSet
		val rejectedCollector = Collectors::toSet
		i.partitionBy(null as Class<Integer>, selectedCollector, rejectedCollector)
	}
	
	@Test(expected = NullPointerException) def void testPartitionBySelectionClassCollectorSelectedCollectorNull() {
		val Iterator<String> i = #[].iterator
		val collector = Collectors::toSet
		i.partitionBy(String, null, collector)
	}
	
	@Test(expected = NullPointerException) def void testPartitionBySelectionClassCollectorRejectedCollectorNull() {
		val Iterator<String> i = #[].iterator
		val collector = Collectors::toSet
		i.partitionBy(String, collector, null)
	}
	
	@Test def void testPartitionBySelectionClassCollectorsEmptyIterable() {
		val Iterator<Number> i = #[].iterator
		val selectedCollector = Collectors::toSet
		val rejectedCollector = Collectors::toSet
		val result = i.partitionBy(Integer, selectedCollector, rejectedCollector)
		assertNotNull(result)
		val Set<Integer> selected = result.selected
		assertNotNull(selected)
		assertTrue(selected.empty)
		val Set<Number> rejected = result.rejected
		assertNotNull(rejected)
		assertTrue(rejected.empty)
	}
	
	@Test def void testPartitionBySelectionClassCollecotrsOnlySelected() {
		val List<Number> l = #[32, 64, 4711]
		val Iterator<Number> i = l.iterator
		val selectedCollector = Collectors::toSet
		val rejectedCollector = Collectors::toSet
		val result = i.partitionBy(Integer, selectedCollector, rejectedCollector)
		assertNotNull(result)
		val Set<Integer> selected = result.selected
		assertNotNull(selected)
		assertEquals(selected, l.toSet)
		val Set<Number> rejected = result.rejected
		assertNotNull(rejected)
		assertTrue(rejected.empty)
	}
	
	@Test def void testPartitionBySelectionClassCollectorsOnlyRejected() {
		val List<Number> l = #[11, 4533, 91]
		val Iterator<Number> i = l.iterator
		val selectedCollector = Collectors::toSet
		val rejectedCollector = Collectors::toSet
		val result = i.partitionBy(Double, selectedCollector, rejectedCollector)
		assertNotNull(result)
		val Set<Number> rejected = result.rejected
		assertNotNull(rejected)
		assertEquals(l.toSet, rejected)
		val Set<Double> selected = result.selected
		assertNotNull(selected)
		assertTrue(selected.empty)
	}
	
	@Test def void testPartitionBySelectionClassCollectors() {
		val List<Number> l = #[64d, 33, 51f, 4711]
		val Iterator<Number> i = l.iterator
		val selectedCollector = Collectors::toSet
		val rejectedCollector = Collectors::toSet
		val result = i.partitionBy(Integer, selectedCollector, rejectedCollector)
		assertNotNull(result)
		val Set<Number> rejected = result.rejected
		assertNotNull(rejected)
		assertEquals(#{64d, 51f}, rejected)
		val Set<Integer> selected = result.selected
		assertNotNull(selected)
		assertEquals(#{33, 4711}, selected)
	}
	
	//////////////////////////////////////
	// partitionBy (partitionPredicate) //
	//////////////////////////////////////
	
	@Test(expected = NullPointerException) def void testPartitionByPredicateIteratorNull() {
		val Iterator<String> i = null
		i.partitionBy[true]
	}
	
	@Test(expected = NullPointerException) def void testPartitionByPredicatePredicateNull() {
		val Iterator<String> i = #[].iterator
		i.partitionBy(null as Predicate<String>)
	}
	
	@Test def void testPartitionByPredicateEmptyIterable() {
		val Iterator<Number> i = #[].iterator
		val result = i.partitionBy[true]
		assertNotNull(result)
		val selected = result.selected
		assertNotNull(selected)
		assertTrue(selected.empty)
		val rejected = result.rejected
		assertNotNull(rejected)
		assertTrue(rejected.empty)
	}
	
	@Test def void testPartitionByPredicateOnlySelected() {
		val List<Number> l = #[32, 64, 4711]
		val Iterator<Number> i = l.iterator
		val result = i.partitionBy[true]
		assertNotNull(result)
		val selected = result.selected
		assertNotNull(selected)
		assertEquals(selected, l)
		val rejected = result.rejected
		assertNotNull(rejected)
		assertTrue(rejected.empty)
	}
	
	@Test def void testPartitionByPredicateOnlyRejected() {
		val List<Number> l = #[11, 4533, 91]
		val Iterator<Number> i = l.iterator
		val result = i.partitionBy[false]
		assertNotNull(result)
		val selected = result.selected
		assertNotNull(selected)
		assertTrue(selected.empty)
		val rejected = result.rejected
		assertNotNull(rejected)
		assertEquals(rejected, l)
	}
	
	@Test def void testPartitionByPredicate() {
		val List<Number> l = #[64d, 33, 51f, 4711]
		val Iterator<Number> i = l.iterator
		val result = i.partitionBy[it.doubleValue > 60]
		assertNotNull(result)
		val selected = result.selected
		assertNotNull(selected)
		assertEquals(#[64d, 4711], selected)
		val rejected = result.rejected
		assertNotNull(rejected)
		assertEquals(#[33, 51f], rejected)
	}
	
	
	/////////////////////////////////////////////////
	// partitionBy (partitionPredicate, collector) //
	/////////////////////////////////////////////////
	
	@Test(expected = NullPointerException) def void testPartitionByPredicateCollectorIteratorNull() {
		val Iterator<String> i = null
		i.partitionBy([true], Collectors.toList)
	}
	
	@Test(expected = NullPointerException) def void testPartitionByPredicateCollectorPredicateNull() {
		val Iterator<String> i = #[].iterator
		i.partitionBy(null as Predicate<String>, Collectors.toList)
	}
	
	@Test(expected = NullPointerException) def void testPartitionByPredicateCollectorCollectorNull() {
		val Iterator<String> i = #[].iterator
		i.partitionBy([true], null)
	}
	
	@Test def void testPartitionByPredicateCollectorEmptyIterable() {
		val Iterator<Number> i = #[].iterator
		val result = i.partitionBy([true], Collectors::toSet)
		assertNotNull(result)
		val Set<Number> selected = result.selected
		assertNotNull(selected)
		assertTrue(selected.empty)
		val Set<Number> rejected = result.rejected
		assertNotNull(rejected)
		assertTrue(rejected.empty)
	}
	
	@Test def void testPartitionByPredicateCollectorOnlySelected() {
		val List<Integer> l = #[32, 64, 4711]
		val Iterator<Integer> i = l.iterator
		val result = i.partitionBy([true], Collectors::toSet)
		assertNotNull(result)
		val Set<Integer> selected = result.selected
		assertNotNull(selected)
		assertEquals(selected, l.toSet)
		val Set<Integer> rejected = result.rejected
		assertNotNull(rejected)
		assertTrue(rejected.empty)
	}
	
	@Test def void testPartitionByPredicateCollectorOnlyRejected() {
		val List<Integer> l = #[11, 4533, 91]
		val Iterator<Integer> i = l.iterator
		val result = i.partitionBy([false], Collectors::toSet)
		assertNotNull(result)
		val Set<Integer> rejected = result.rejected
		assertNotNull(rejected)
		assertEquals(l.toSet, rejected)
		val Set<Integer> selected = result.selected
		assertNotNull(selected)
		assertTrue(selected.empty)
	}
	
	@Test def void testPartitionByPredicateCollector() {
		val List<Number> l = #[64d, 33, 51f, 4711]
		val Iterator<Number> i = l.iterator
		val result = i.partitionBy([it.doubleValue > 60], Collectors::toSet)
		assertNotNull(result)
		val Set<Number> selected = result.selected
		assertNotNull(selected)
		assertEquals(#{64d, 4711}, selected)
		val Set<Number> rejected = result.rejected
		assertNotNull(rejected)
		assertEquals(#{33, 51f}, rejected)
	}
	
	
	////////////////////////////////////////////////////////////////////////////
	// partitionBy (partitionPredicate, selectedCollector, rejectedCollector) //
	////////////////////////////////////////////////////////////////////////////
	
	@Test(expected = NullPointerException) def void testPartitionByPredicateCollectorsIteratorNull() {
		val Iterator<String> i = null
		i.partitionBy([true], Collectors.toList, Collectors.toSet)
	}
	
	@Test(expected = NullPointerException) def void testPartitionByPredicateCollectorsPredicateNull() {
		val Iterator<String> i = #[].iterator
		i.partitionBy(null as Predicate<String>, Collectors.toList, Collectors.toSet)
	}
	
	@Test(expected = NullPointerException) def void testPartitionByPredicateCollectorSelectedCollectorNull() {
		val Iterator<String> i = #[].iterator
		i.partitionBy([true], null, Collectors.toSet)
	}
	
	@Test(expected = NullPointerException) def void testPartitionByPredicateCollectorrejectedCollectorNull() {
		val Iterator<String> i = #[].iterator
		i.partitionBy([true], Collectors.toSet, null)
	}
	
	@Test def void testPartitionByPredicateCollectorsEmptyIterable() {
		val Iterator<Number> i = #[].iterator
		val selectedCollector = Collectors::toList
		val rejectedCollector = Collectors::toSet
		val result = i.partitionBy([true], selectedCollector, rejectedCollector)
		assertNotNull(result)
		val List<Number> selected = result.selected
		assertNotNull(selected)
		assertTrue(selected.empty)
		val Set<Number> rejected = result.rejected
		assertNotNull(rejected)
		assertTrue(rejected.empty)
	}
	
	@Test def void testPartitionByPredicateCollecotrsOnlySelected() {
		val List<Integer> l = #[32, 64, 4711]
		val Iterator<Integer> i = l.iterator
		val selectedCollector = Collectors::toSet
		val rejectedCollector = Collectors::toSet
		val result = i.partitionBy([true], selectedCollector, rejectedCollector)
		assertNotNull(result)
		val Set<Integer> selected = result.selected
		assertNotNull(selected)
		assertEquals(selected, l.toSet)
		val Set<Integer> rejected = result.rejected
		assertNotNull(rejected)
		assertTrue(rejected.empty)
	}
	
	@Test def void testPartitionByPredicateCollectorsOnlyRejected() {
		val List<Integer> l = #[11, 4533, 91]
		val Iterator<Integer> i = l.iterator
		val selectedCollector = Collectors::toSet
		val rejectedCollector = Collectors::toSet
		val result = i.partitionBy([false], selectedCollector, rejectedCollector)
		assertNotNull(result)
		val Set<Integer> rejected = result.rejected
		assertNotNull(rejected)
		assertEquals(l.toSet, rejected)
		val Set<Integer> selected = result.selected
		assertNotNull(selected)
		assertTrue(selected.empty)
	}
	
	@Test def void testPartitionByPredicateCollectors() {
		val List<Number> l = #[64d, 33, 51f, 4711]
		val Iterator<Number> i = l.iterator
		val selectedCollector = Collectors::toSet
		val rejectedCollector = Collectors::toSet
		val result = i.partitionBy([it.doubleValue > 60], selectedCollector, rejectedCollector)
		assertNotNull(result)
		val Set<Number> selected = result.selected
		assertNotNull(selected)
		assertEquals(#{64d, 4711}, selected)
		val Set<Number> rejected = result.rejected
		assertNotNull(rejected)
		assertEquals(#{33, 51f}, rejected)
	}
	
	//////////////
	// into one //
	//////////////
	
	@Test(expected = NullPointerException) 
	def void testIntoCollectionIteratorNull() {
		val Iterator<String> i = null
		i.into(newArrayList)
	}
	
	@Test(expected = NullPointerException) 
	def void testIntoCollectionTargetNull() {
		#["foo"].iterator.into(null as Collection<String>)
	}
	
	@Test
	def void testIntoCollectionTestInEqualsOut() {
		val expected = newArrayList
		val result = #["foo", "bar"].iterator.into(expected)
		assertSame(expected, result)
	}
	
	@Test
	def void testIntoCollectionIteratorEmpty() {
		val expected = #["foo", "bar"]
		val target = new ArrayList(expected)
		val result = #[].iterator.into(target)
		assertEquals(expected, result)
	}
	
	@Test
	def void testIntoCollectionTargetEmpty() {
		val expected = #["foo", "bar"]
		val target = newArrayList
		val result = expected.iterator.into(target)
		assertEquals(expected, result)
	}
	
	@Test
	def void testIntoCollection() {
		val expected = #["foo", "bar", "one", "two"]
		val target = newArrayList("foo", "bar")
		val result = #["one", "two"].iterator.into(target)
		assertEquals(expected, result)
	}
	
	//////////////////
	// into varargs //
	//////////////////
	
	@Test(expected = NullPointerException) 
	def void testIntoCollectionsIteratorNull() {
		val Iterator<String> i = null
		i.into(newArrayList,newArrayList)
	}
	
	@Test(expected = NullPointerException) 
	def void testIntoCollectionsTargetNull() {
		#["foo"].iterator.into(null as Collection<String>[])
	}
	
	@Test(expected = NullPointerException) 
	def void testIntoCollectionsIteratorOneTargetNull() {
		val Iterator<String> i = #[].iterator
		i.into(newArrayList,null)
	}
	
	@Test 
	def void testIntoCollectionsIteratorNoTarget() {
		val result = #["foo", "bar"].iterator.into
		assertEquals(0, result.length)
	}
	
	@Test
	def void testIntoCollectionsIteratorEmpty() {
		val a = #["foo", "bar"]
		val b = #["hui", "buh"]
		val Collection<String>[] expected = #[a, b].toArray(newArrayOfSize(2))
		val Collection<String>[] result = #[].iterator.into(a,b)
		assertArrayEquals(expected, result)
	}
	
	@Test
	def void testIntoCollectionsOneCollection() {
		val Collection<String>[] expected = #[#["foo", "bar", "one", "two"]].toArray(newArrayOfSize(1))
		val target = newArrayList("foo", "bar")
		val result = #["one", "two"].iterator.into(#[target])
		assertArrayEquals(expected, result)
	}
	
	@Test
	def void testIntoCollectionsTwoCollections() {
		val Collection<String>[] expected = #[#["foo", "bar", "one", "two"], #["alpha", "beta", "one", "two"]]
			.toArray(newArrayOfSize(2))
		val target1 = newArrayList("foo", "bar")
		val target2 = newArrayList("alpha", "beta")
		val result = #["one", "two"].iterator.into(#[target1,target2])
		assertArrayEquals(expected, result)
		assertSame(target1, result.get(0))
		assertSame(target2, result.get(1))
	}
	
}