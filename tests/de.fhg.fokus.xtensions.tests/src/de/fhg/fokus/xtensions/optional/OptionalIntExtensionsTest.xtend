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
package de.fhg.fokus.xtensions.optional

import de.fhg.fokus.xtensions.Util
import java.util.NoSuchElementException
import java.util.OptionalInt
import java.util.PrimitiveIterator.OfInt
import java.util.Set
import java.util.Spliterators
import java.util.concurrent.atomic.AtomicBoolean
import java.util.function.IntSupplier
import java.util.stream.StreamSupport
import org.junit.Test

import static de.fhg.fokus.xtensions.Util.*
import static org.junit.Assert.*

import static extension de.fhg.fokus.xtensions.optional.OptionalIntExtensions.*

class OptionalIntExtensionsTest {
	
	//////////
	// some //
	//////////
	
	@Test def void testSomeValue() {
		val expected = 4
		val OptionalInt o =  some(expected)
		assertTrue(o.present)
		assertEquals(expected, o.asInt)
	}
	
	////////////
	// someOf //
	////////////
	
	@Test def void testSomeOfVeryLowValue() {
		val expected = Integer.MIN_VALUE + 1
		testSomeOf(expected)
	}
	
	@Test def void testSomeOfLowestCached() {
		val expected = -128
		testSomeOf(expected)
	}
	
	@Test def void testSomeOfHighestCached() {
		val expected = 127
		testSomeOf(expected)
	}
	
	
	@Test def void testSomeOfZero() {
		val expected = 0
		testSomeOf(expected)
	}
	
	
	@Test def void testSomeOfVeryHighValue() {
		val expected = Integer.MAX_VALUE + 1
		testSomeOf(expected)
	}
	
	///////////
	// noInt //
	///////////
	
	@Test def void testNoInt() {
		val OptionalInt o =  noInt
		assertFalse(o.present)
		Util.expectException(NoSuchElementException) [
			o.asInt
		]
	}
	
	///////////
	// maybe //
	///////////
	
	@Test def void testMaybeWithValue() {
		val Integer expected = -30
		val OptionalInt o =  expected.maybe
		assertTrue(o.present)
		assertEquals(expected, o.asInt)
	}
	
	
	@Test def void testMaybeWithNullValue() {
		val expected = null
		val OptionalInt o =  maybe(expected)
		assertFalse(o.present)
		Util.expectException(NoSuchElementException) [
			o.asInt
		]
	}
	
	//////////////
	// iterator //
	//////////////
	
	@Test def void testIteratorEmpty() {
		val OptionalInt o = OptionalInt.empty
		val i = o.iterator
		testEmptyIterator(i)
	}
	
	@Test def void testIteratorElement() {
		val expected = 42
		val OptionalInt o = OptionalInt.of(expected)
		val i = o.iterator
		testOneElementIterator(i, expected)
	}
	
	
	//////////////
	// Iterable //
	//////////////
	
	@Test def void testIterableEmpty() {
		val OptionalInt o = OptionalInt.empty
		val iterable = o.asIterable
		assertNotNull(iterable)
		var i = iterable.iterator
		testEmptyIterator(i)
		i = iterable.iterator
		testEmptyIterator(i)
		
		iterable.forEach[fail()]
		
		val a1 = iterable.stream().toArray
		assertArrayEquals(#[], a1)
		
		iterable.forEachInt [
			fail()
		]
		
		val sp = Spliterators.spliteratorUnknownSize(iterable.iterator,0)
		val arr = StreamSupport.intStream(sp,false).toArray
		assertTrue(arr.empty)
	}
	
	@Test def void testIterableElement() {
		val expected = 42
		val OptionalInt o = OptionalInt.of(expected)
		val iterable = o.asIterable
		
		val i1 = iterable.iterator
		testOneElementIterator(i1, expected)
		val i2 = iterable.iterator
		testOneElementIterator(i2, expected)
		
		val list = newArrayList
		iterable.forEach[list.add(it)]
		assertEquals(#[expected], list)
		
		val a1 = iterable.stream().toArray
		assertArrayEquals(#[expected], a1)
		
		val list2 = newArrayList
		iterable.forEachInt [
			list2.add(it)
		]
		assertEquals(#[expected], list2)
		
		val sp = Spliterators.spliteratorUnknownSize(iterable.iterator,0)
		val arr = StreamSupport.intStream(sp,false).toArray
		assertArrayEquals(#[expected], arr)
	}
	
	//////////////////
	// ifNotPresent //
	//////////////////
	
	@Test def testIfNotPresentNotPresent() {
		val OptionalInt o = OptionalInt.empty
		
		val AtomicBoolean result = new AtomicBoolean(false)
		o.ifNotPresent[|
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def testIfNotPresentPresent() {
		val OptionalInt o = OptionalInt.of(4711)
		
		o.ifNotPresent[|
			fail()
		]
	}
	
	/////////////////////////
	// whenPresent or else //
	/////////////////////////
	
	@Test def testWhenPresentOrElseOnEmpty() {
		val OptionalInt o = OptionalInt.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		
		o.whenPresent [
			fail()
		].elseDo [
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def testWhenPresentOrElseOnEmptyOneVal() {
		val OptionalInt o = OptionalInt.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		val expected = "foo"
		
		o.whenPresent [
			fail()
		].elseDo(expected) [
			assertSame(expected, it)
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def testWhenPresentOrElseOnEmptyTwoVals() {
		val OptionalInt o = OptionalInt.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		val expected = "foo"
		val Integer expected2 = 42
		
		o.whenPresent [
			fail()
		].elseDo(expected, expected2) [
			assertSame(expected, $0)
			assertSame(expected2, $1)
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def void testWhenPresentOnValue() {
		val expected = 4711
		val OptionalInt o = OptionalInt.of(expected)
		val AtomicBoolean result = new AtomicBoolean(false)
		
		o.whenPresent [
			assertEquals(expected, it)
			result.set(true)
		]
		assertTrue(result.get)
	}
	
	@Test def void testWhenPresentOrElseOnValue() {
		val expected = 4711
		val OptionalInt o = OptionalInt.of(expected)
		val AtomicBoolean result = new AtomicBoolean(false)
		
		val _else = o.whenPresent [
			assertEquals(expected, it)
			result.set(true)
		]
		_else.elseDo [
			fail()
		]
		_else.elseDo("foo") [
			fail()
		]
		_else.elseDo("foo", 42) [
			fail()
		]
		
		assertTrue(result.get)
	}
	
	///////////
	// toSet //
	///////////
	
	@Test def void testToSetOnEmpty() {
		val o = OptionalInt.empty
		
		val Set<Integer> result = o.toSet
		assertTrue(result.empty)
		assertEquals(0, result.size)
		assertFalse(result.iterator.hasNext)
		expectException(UnsupportedOperationException) [
			result.add(4711)
		]
	}
	
	@Test def void testToSetOnValue() {
		val expected = 911
		val o = OptionalInt.of(expected)
		
		val Set<Integer> result = o.toSet
		assertFalse(result.empty)
		assertEquals(1, result.size)
		
		var Integer[] tmp = <Integer>newArrayOfSize(1)
		val int actual = result.toArray(tmp).get(0)
		assertEquals(expected, actual)
		
		assertTrue(result.contains(expected))
		expectException(UnsupportedOperationException) [
			result.add(42)
		]
	}
	
	
	////////////
	// stream //
	////////////
	
	@Test def void streamOnValue() {
		val expected = -100
		val o = OptionalInt.of(expected)
		val result = o.stream().toArray
		assertArrayEquals(#[expected], result)
	}
	
	@Test def void streamOnEmpty() {
		val OptionalInt o = OptionalInt.empty
		val result = o.stream().count
		assertEquals(0, result)
	}
	
	/////////////////////
	// ifPresentOrElse //
	/////////////////////
	
	@Test def void ifPresentOrElseOnVlaue() {
		val opt = OptionalInt.of(3)
		val result = newArrayList
		opt.ifPresentOrElse​([result.add(it)] , [fail()])
		assertEquals(#[3], result)
	}
	
	@Test def void ifPresentOrElseOnEmpty() {
		val OptionalInt opt = OptionalInt.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		opt.ifPresentOrElse​([fail()] , [result.set(true)])
		assertTrue(result.get)
	}
	
	/////////////////
	// or Supplier //
	/////////////////
	
	@Test def void orEmptyEmpty() {
		val OptionalInt o = OptionalInt.empty
		val OptionalInt o2 = OptionalInt.empty
		val result = o.or[o2]
		assertFalse(result.isPresent)
	}
	
	@Test def void orEmptyValue() {
		val expected = -400
		val OptionalInt o = OptionalInt.empty
		val OptionalInt o2 = OptionalInt.of(expected)
		val result = o.or[o2]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asInt)
	}
	
	@Test def void orValueX() {
		val expected = -4711
		val OptionalInt o = OptionalInt.of(expected)
		val result = o.or[fail();return null]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asInt)
	}
	
	
	@Test def void orOpEmptyEmpty() {
		val OptionalInt o = OptionalInt.empty
		val OptionalInt o2 = OptionalInt.empty
		val result = o || [o2]
		assertFalse(result.isPresent)
	}
	
	@Test def void orOpEmptyValue() {
		val expected = 815
		val OptionalInt o = OptionalInt.empty
		val OptionalInt o2 = OptionalInt.of(expected)
		val result = o || [o2]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asInt)
	}
	
	@Test def void orOpValueX() {
		val expected = -9000
		val OptionalInt o = OptionalInt.of(expected)
		val result = o || [fail();return null]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asInt)
	}
	
	///////////
	// elvis //
	///////////
	
	@Test def void testElvisWithValue() {
		val expected = 42
		val o = OptionalInt.of(expected)
		val int result = o ?: 70
		
		assertEquals(expected, result)
	}
	
	@Test def void testElvisWithoutValue() {
		val o = OptionalInt.empty
		val expected = 9020010
		val int result = o ?: expected
		
		assertEquals(expected, result)
	}
	
	////////////////////
	// elvis supplier //
	////////////////////
	
	@Test def void testElvisSupplierWithValue() {
		val expected = 77
		val o = OptionalInt.of(expected)
		val int result = o ?: [fail();0]
		
		assertSame(expected, result)
	}
	
	@Test def void testElvisSupplierWithoutValue() {
		val o = OptionalInt.empty
		val expected = 42
		val int result = o ?: [expected]
		
		assertSame(expected, result)
	}
	
	@Test def void testElvisSupplierWithValueNullSupplier() {
		val expected = 815
		val OptionalInt o = OptionalInt.of(expected)
		val IntSupplier sup = null
		val result = o ?: sup
		
		assertEquals(expected, result)
	}
	
	@Test(expected = NullPointerException) def void testElvisSupplierWithoutValueNullSupplier() {
		val OptionalInt o = OptionalInt.empty
		val IntSupplier sup = null
		val result = o ?: sup
		println(result)
		fail()
	}
	
	
	////////////
	// mapInt //
	////////////
	
	@Test def void testMapIntEmpty() {
		val OptionalInt o = OptionalInt.empty
		val oi = o.mapInt[fail();0]
		assertFalse(oi.present)
	}
	
	@Test def void testMapIntValue() {
		val expected = 42
		val o = OptionalInt.of(21)
		val oi = o.mapInt[it*2]
		assertTrue(oi.present)
		assertEquals(expected, oi.asInt)
	}
	
	////////////
	// mapLong //
	////////////
	
	@Test def void testMapLongEmpty() {
		val OptionalInt o = OptionalInt.empty
		val ol = o.mapLong[fail();Long.MAX_VALUE]
		assertFalse(ol.present)
	}
	
	@Test def void testMapLongValue() {
		val o = OptionalInt.of(99)
		val ol = o.mapLong[
			assertEquals(99, it)
			Long.MAX_VALUE
		]
		assertTrue(ol.present)
		assertEquals(Long.MAX_VALUE, ol.asLong)
	}
	
	///////////////
	// mapDouble //
	///////////////
	
	@Test def void testMapDoubleEmpty() {
		val OptionalInt o = OptionalInt.empty
		val od = o.mapDouble[fail();Double.MAX_VALUE]
		assertFalse(od.present)
	}
	
	@Test def void testMapDoubleValue() {
		val start = 42
		val o = OptionalInt.of(start)
		val od = o.mapDouble[
			assertEquals(start, it)
			Long.MAX_VALUE
		]
		assertTrue(od.present)
		assertEquals(Long.MAX_VALUE, od.asDouble, 0.00001d)
	}
	
	///////////
	// boxed //
	///////////
	
	@Test def void testBoxedEmpty() {
		val o = OptionalInt.empty.boxed
		assertFalse(o.present)
	}
	
	@Test def void testBoxedValue() {
		val expected = Integer.MIN_VALUE
		val o = OptionalInt.of(expected).boxed
		assertTrue(o.present)
		assertEquals(expected, o.get as int)
	}
	
	////////////
	// filter //
	////////////
	
	@Test def void testFilterEmpty() {
		val o = OptionalInt.empty
		val result = o.filter[fail();true]
		assertFalse(result.present)
	}
	
	@Test def void testFilterLetThrough() {
		val expected = 32
		val o = OptionalInt.of(expected)
		val result = o.filter[
			assertEquals(expected, it)
			true
		]
		assertTrue(result.present)
		assertEquals(expected, result.asInt)
	}
	
	@Test def void testFilterOut() {
		val expected = 64
		val o = OptionalInt.of(expected)
		val result = o.filter[
			assertEquals(expected, it)
			false
		]
		assertFalse(result.present)
	}
	
	// TODO 
	// flatMapInt
	
	////////////
	// asLong //
	////////////
	
	@Test def void testAsLongEmpty() {
		val o = OptionalInt.empty.asLong
		assertFalse(o.present)
	}
	
	@Test def void testAsLongElement() {
		val o = OptionalInt.of(Integer.MAX_VALUE).asLong
		assertTrue(o.present)
		val result = o.asLong
		assertEquals(Integer.MAX_VALUE, result)
	}
	
	//////////////
	// asDouble //
	//////////////
	
	@Test def void testAsDoubleEmpty() {
		val o = OptionalInt.empty.asDouble
		assertFalse(o.present)
	}
	
	@Test def void testAsDoubleElement() {
		val o = OptionalInt.of(87).asDouble
		assertTrue(o.present)
		val result = o.asDouble
		assertEquals(87.0d, result, 0.001d)
	}
	
	////////////////
	// flatMapInt //
	////////////////
	
	@Test def void testFlatMapIntEmpty() {
		val OptionalInt o = OptionalInt.empty.flatMapInt[fail()null]
		assertFalse(o.present)
	}
	
	@Test def void testFlatMapIntReturnFilled() {
		val start = 4711
		val OptionalInt o = OptionalInt.of(start)
		val OptionalInt expected = OptionalInt.of(42)
		val result = o.flatMapInt [
			assertEquals(start, it)
			expected
		]
		assertSame(expected, result)
	}
	
	@Test def void testFlatMapIntReturnEmpty() {
		val start = 9000
		val OptionalInt o = OptionalInt.of(start)
		val OptionalInt expected = OptionalInt.empty
		val result = o.flatMapInt [
			assertEquals(start, it)
			expected
		]
		assertSame(expected, result)
	}
	
	///////////////////
	// asIntIterable //
	///////////////////
	
	// empty optional
	
	@Test def void testAsIntIterableEmptyIterator() {
		val o = OptionalInt.empty
		val iterable = o.asIterable
		
		val iter = iterable.iterator
		Util.assertEmptyIntIterator(iter)
	}

	@Test def void testAsIntIterableEmptyStream() {
		val o = OptionalInt.empty
		val iterable = o.asIterable
		
		val s = iterable.stream
		val result = s.toArray
		assertEquals(0, result.length)
	}

	@Test def void testAsIntIterableEmptyForEach() {
		val o = OptionalInt.empty
		val iterable = o.asIterable
		iterable.forEach[throw new Exception]
	}
	
	// optional with value
	
	
	@Test def void testPresentAsIntIterableIterator() {
		val expected = 42
		val o = OptionalInt.of(expected)
		val iterable = o.asIterable
		
		val iter = iterable.iterator
		assertTrue(iter.hasNext)
		val actual = iter.next
		assertEquals(expected, actual)
		
		Util.assertEmptyIntIterator(iter)
	}

	@Test def void testPresentAsIntIterableStream() {
		val expected = 64
		val o = OptionalInt.of(expected)
		val iterable = o.asIterable
		
		val s = iterable.stream
		val result = s.toArray
		assertArrayEquals(#[expected], result)
	}

	@Test def void testPresentAsIntIterableForEach() {
		val expected = 99
		val o = OptionalInt.of(expected)
		val iterable = o.asIterable
		val visited = new AtomicBoolean(false)
		iterable.forEach [
			assertFalse(visited.get)
			assertEquals(expected, it)
			visited.set(true)
		]
		assertTrue(visited.get)
	}
	
	/////////////////////
	// Utility methods //
	/////////////////////
	
	private def testEmptyIterator(OfInt iterator) {
		assertNotNull(iterator)
		assertFalse(iterator.hasNext)
		expectException(NoSuchElementException) [
			iterator.nextInt
		]
	}
	
	private def testOneElementIterator(OfInt i, int expected) {
		assertNotNull(i)
		assertTrue(i.hasNext)
		assertEquals(expected, i.nextInt)
		testEmptyIterator(i)
	} 
	
	private def void testSomeOf(int expected) {
		val OptionalInt o =  someOf(expected)
		assertTrue(o.present)
		assertEquals(expected, o.asInt)
		
		val OptionalInt o2 =  someOf(expected)
		assertTrue(o2.present)
		assertEquals(expected, o2.asInt)
	}
}