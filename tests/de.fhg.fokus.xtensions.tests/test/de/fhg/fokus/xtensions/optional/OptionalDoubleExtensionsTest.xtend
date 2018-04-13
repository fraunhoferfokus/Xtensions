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
package de.fhg.fokus.xtensions.optional

import java.util.OptionalDouble
import static extension de.fhg.fokus.xtensions.optional.OptionalDoubleExtensions.*
import org.junit.Test
import static org.junit.Assert.*
import de.fhg.fokus.xtensions.Util
import java.util.NoSuchElementException
import java.util.concurrent.atomic.AtomicBoolean
import java.util.function.DoubleSupplier
import java.util.Set
import java.util.PrimitiveIterator.OfDouble
import java.util.Spliterators
import java.util.stream.StreamSupport

class OptionalDoubleExtensionsTest {
	
	
	//////////
	// some //
	//////////
	
	@Test def void testSomeValue() {
		val expected = 4
		val OptionalDouble o =  some(expected)
		assertTrue(o.present)
		assertEquals(expected, o.asDouble, 0.0d)
	}
	
	
	////////////
	// noDouble //
	////////////
	
	@Test def void testNoDouble() {
		val OptionalDouble o =  noDouble
		assertFalse(o.present)
		Util.expectException(NoSuchElementException) [
			o.asDouble
		]
	}
	
	///////////
	// maybe //
	///////////
	
	@Test def void testMaybeWithValue() {
		val Double expected = -30000000.0d
		val OptionalDouble o =  expected.maybe
		assertTrue(o.present)
		assertEquals(expected, o.asDouble, 0.0d)
	}
	
	
	@Test def void testMaybeWithNullValue() {
		val expected = null
		val OptionalDouble o =  maybe(expected)
		assertFalse(o.present)
		Util.expectException(NoSuchElementException) [
			o.asDouble
		]
	}
	
	/////////////////////////
	// whenPresent or else //
	/////////////////////////
	
	@Test def tesWhenPresentOrElseOnEmpty() {
		val OptionalDouble o = OptionalDouble.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		
		o.whenPresent [
			fail()
		].elseDo [
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def tesWhenPresentOrElseOnEmptyOneVal() {
		val OptionalDouble o = OptionalDouble.empty
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
	
	@Test def tesWhenPresentOrElseOnEmptyTwoVals() {
		val OptionalDouble o = OptionalDouble.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		val expected = "foo"
		val Double expected2 = 42.0d
		
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
		val expected = 4711.0d
		val OptionalDouble o = OptionalDouble.of(expected)
		val AtomicBoolean result = new AtomicBoolean(false)
		
		o.whenPresent [
			assertEquals(expected, it, 0.001d)
			result.set(true)
		]
		assertTrue(result.get)
	}
	
	@Test def void testWhenPresentOrElseOnValue() {
		val expected = 4711.0d
		val OptionalDouble o = OptionalDouble.of(expected)
		val AtomicBoolean result = new AtomicBoolean(false)
		
		val _else = o.whenPresent [
			assertEquals(expected, it, 0.001d)
			result.set(true)
		]
		_else.elseDo [
			fail()
		]
		_else.elseDo("foo") [
			fail()
		]
		_else.elseDo("foo", 42.0d) [
			fail()
		]
		
		assertTrue(result.get)
	}
	
	//////////////////
	// ifNotPresent //
	//////////////////
	
	@Test def testIfNotPresentNotPresent() {
		val OptionalDouble o = OptionalDouble.empty
		
		val AtomicBoolean result = new AtomicBoolean(false)
		o.ifNotPresent[|
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def testIfNotPresentPresent() {
		val OptionalDouble o = OptionalDouble.of(4711.0d)
		
		o.ifNotPresent[|
			fail()
		]
	}
	
	///////////
	// boxed //
	///////////
	
	@Test def void testBoxedEmpty() {
		val o = OptionalDouble.empty.boxed
		assertFalse(o.present)
	}
	
	@Test def void testBoxedValue() {
		val expected = Double.MIN_VALUE
		val o = OptionalDouble.of(expected).boxed
		assertTrue(o.present)
		assertEquals(expected, o.get as double, 0.0d)
	}
	
	////////////
	// filter //
	////////////
	
	@Test def void testFilterEmpty() {
		val o = OptionalDouble.empty
		val result = o.filter[fail();true]
		assertFalse(result.present)
	}
	
	@Test def void testFilterLetThrough() {
		val expected = 32.0d
		val o = OptionalDouble.of(expected)
		val result = o.filter[
			assertEquals(expected, it,0.0d)
			true
		]
		assertTrue(result.present)
		assertEquals(expected, result.asDouble, 0.0d)
	}
	
	@Test def void testFilterOut() {
		val expected = 64.0d
		val o = OptionalDouble.of(expected)
		val result = o.filter[
			assertEquals(expected, it, 0.0d)
			false
		]
		assertFalse(result.present)
	}
	
	///////////
	// elvis //
	///////////
	
	@Test def void testElvisWithValue() {
		val expected = Double.MAX_VALUE
		val o = OptionalDouble.of(expected)
		val double result = o ?: 70.0d
		
		assertEquals(expected, result, 0.0d)
	}
	
	@Test def void testElvisWithoutValue() {
		val o = OptionalDouble.empty
		val expected = 9020010.0d
		val double result = o ?: expected
		
		assertEquals(expected, result, 0.0d)
	}
	
	////////////////////
	// elvis supplier //
	////////////////////
	
	@Test def void testElvisSupplierWithValue() {
		val expected = 77.0d
		val o = OptionalDouble.of(expected)
		val double result = o ?: [fail();0.0d]
		
		assertEquals(expected, result, 0.0d)
	}
	
	@Test def void testElvisSupplierWithoutValue() {
		val o = OptionalDouble.empty
		val expected = 42.0d
		val double result = o ?: [expected]
		
		assertEquals(expected, result, 0.0d)
	}
	
	@Test def void testElvisSupplierWithValueNullSupplier() {
		val expected = 815.0d
		val OptionalDouble o = OptionalDouble.of(expected)
		val DoubleSupplier sup = null
		val result = o ?: sup
		
		assertEquals(expected, result, 0.0d)
	}
	
	@Test(expected = NullPointerException) def void testElvisSupplierWithoutValueNullSupplier() {
		val OptionalDouble o = OptionalDouble.empty
		val DoubleSupplier sup = null
		val result = o ?: sup
		println(result)
		fail()
	}
	
	////////////
	// mapInt //
	////////////
	
	@Test def void testMapIntEmpty() {
		val OptionalDouble o = OptionalDouble.empty
		val oi = o.mapInt[fail();0]
		assertFalse(oi.present)
	}
	
	@Test def void testMapIntValue() {
		val expected = 42
		val start = 21.0d
		val o = OptionalDouble.of(start)
		val oi = o.mapInt[
			assertEquals(start, it ,0.0d)
			expected
		]
		assertTrue(oi.present)
		assertEquals(expected, oi.asInt)
	}
	
	////////////
	// mapLong //
	////////////
	
	@Test def void testMapLongEmpty() {
		val OptionalDouble o = OptionalDouble.empty
		val ol = o.mapLong[fail();Long.MAX_VALUE]
		assertFalse(ol.present)
	}
	
	@Test def void testMapLongValue() {
		val expected = 99.0d
		val o = OptionalDouble.of(expected)
		val ol = o.mapLong[
			assertEquals(expected, it, 0.0d)
			Long.MAX_VALUE
		]
		assertTrue(ol.present)
		assertEquals(Long.MAX_VALUE, ol.asLong)
	}
	
	///////////////
	// mapDouble //
	///////////////
	
	@Test def void testMapDoubleEmpty() {
		val OptionalDouble o = OptionalDouble.empty
		val od = o.mapDouble[fail();Double.MAX_VALUE]
		assertFalse(od.present)
	}
	
	@Test def void testMapDoubleValue() {
		val start = 42.0d
		val o = OptionalDouble.of(start)
		val od = o.mapDouble[
			assertEquals(start, it, 0.0d)
			Double.MAX_VALUE
		]
		assertTrue(od.present)
		assertEquals(Double.MAX_VALUE, od.asDouble, 0.0d)
	}
	
	///////////////////
	// flatMapDouble //
	///////////////////
	
	@Test def void testFlatMapLongEmpty() {
		val OptionalDouble o = OptionalDouble.empty.flatMapDouble[fail()null]
		assertFalse(o.present)
	}
	
	@Test def void testFlatMapLongReturnFilled() {
		val start = 4711.0d
		val OptionalDouble o = OptionalDouble.of(start)
		val OptionalDouble expected = OptionalDouble.of(42.0)
		val result = o.flatMapDouble [
			assertEquals(start, it, 0.0d)
			expected
		]
		assertSame(expected, result)
	}
	
	@Test def void testFlatMapLongReturnEmpty() {
		val start = 9000.0d
		val OptionalDouble o = OptionalDouble.of(start)
		val OptionalDouble expected = OptionalDouble.empty
		val result = o.flatMapDouble [
			assertEquals(start, it, 0.0d)
			expected
		]
		assertSame(expected, result)
	}
	
	/////////////////
	// or Supplier //
	/////////////////
	
	@Test def void orEmptyEmpty() {
		val OptionalDouble o = OptionalDouble.empty
		val OptionalDouble o2 = OptionalDouble.empty
		val result = o.or[o2]
		assertFalse(result.isPresent)
	}
	
	@Test def void orEmptyValue() {
		val expected = -400.0d
		val OptionalDouble o = OptionalDouble.empty
		val OptionalDouble o2 = OptionalDouble.of(expected)
		val result = o.or[o2]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asDouble, 0.0d)
	}
	
	@Test def void orValueX() {
		val expected = -4711L
		val OptionalDouble o = OptionalDouble.of(expected)
		val result = o.or[fail();return null]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asDouble, 0.0d)
	}
	
	
	@Test def void orOpEmptyEmpty() {
		val OptionalDouble o = OptionalDouble.empty
		val OptionalDouble o2 = OptionalDouble.empty
		val result = o || [o2]
		assertFalse(result.isPresent)
	}
	
	@Test def void orOpEmptyValue() {
		val expected = 815.0d
		val OptionalDouble o = OptionalDouble.empty
		val OptionalDouble o2 = OptionalDouble.of(expected)
		val result = o || [o2]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asDouble, 0.0d)
	}
	
	@Test def void orOpValueX() {
		val expected = -9000L
		val OptionalDouble o = OptionalDouble.of(expected)
		val result = o || [fail();return null]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asDouble, 0.0d)
	}
	
	////////////
	// stream //
	////////////
	
	@Test def void streamOnValue() {
		val expected = -100.0d
		val o = OptionalDouble.of(expected)
		val result = o.stream().toArray
		assertArrayEquals(#[expected], result, 0.0d)
	}
	
	@Test def void streamOnEmpty() {
		val o = OptionalDouble.empty
		val result = o.stream().count
		assertEquals(0, result)
	}
	
	/////////////////////
	// ifPresentOrElse //
	/////////////////////
	
	@Test def void ifPresentOrElseOnVlaue() {
		val expected = 3.0d
		val opt = OptionalDouble.of(expected)
		val result = newArrayList
		opt.ifPresentOrElse​([result.add(it)] , [fail()])
		assertArrayEquals(#[expected], result, 0.0d)
	}
	
	@Test def void ifPresentOrElseOnEmpty() {
		val opt = OptionalDouble.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		opt.ifPresentOrElse​([fail()] , [result.set(true)])
		assertTrue(result.get)
	}
	
	///////////
	// toSet //
	///////////
	
	@Test def void testToSetOnEmpty() {
		val o = OptionalDouble.empty
		
		val Set<Double> result = o.toSet
		assertTrue(result.empty)
		assertEquals(0, result.size)
		assertFalse(result.iterator.hasNext)
		Util.expectException(UnsupportedOperationException) [
			result.add(4711.0d)
		]
	}
	
	@Test def void testToSetOnValue() {
		val expected = 911.0d
		val o = OptionalDouble.of(expected)
		
		val Set<Double> result = o.toSet
		assertFalse(result.empty)
		assertEquals(1, result.size)
		
		var Double[] tmp = <Double>newArrayOfSize(1)
		val double actual = result.toArray(tmp).get(0)
		assertEquals(expected, actual, 0.0d)
		
		assertTrue(result.contains(expected))
		Util.expectException(UnsupportedOperationException) [
			result.add(42.0d)
		]
	}
	
	//////////////
	// iterator //
	//////////////
	
	@Test def void testIteratorEmpty() {
		val o = OptionalDouble.empty
		val i = o.iterator
		testEmptyIterator(i)
	}
	
	@Test def void testIteratorElement() {
		val expected = 42.0d
		val o = OptionalDouble.of(expected)
		val i = o.iterator
		testOneElementIterator(i, expected, 0.0d)
	}
	
	
	//////////////
	// Iterable //
	//////////////
	
	@Test def void testIterableEmpty() {
		val o = OptionalDouble.empty
		val iterable = o.asIterable
		assertNotNull(iterable)
		var i = iterable.iterator
		testEmptyIterator(i)
		i = iterable.iterator
		testEmptyIterator(i)
		
		iterable.forEach[fail()]
		
		val a1 = iterable.stream().toArray
		assertArrayEquals(#[], a1, 0.0d)
		
		iterable.forEachDouble [
			fail()
		]
		
		val sp = Spliterators.spliteratorUnknownSize(iterable.iterator,0)
		val arr = StreamSupport.doubleStream(sp,false).toArray
		assertTrue(arr.empty)
	}
	
	@Test def void testIterableElement() {
		val expected = 42.0d
		val o = OptionalDouble.of(expected)
		val iterable = o.asIterable
		
		val i1 = iterable.iterator
		testOneElementIterator(i1, expected, 0.0d)
		val i2 = iterable.iterator
		testOneElementIterator(i2, expected, 0.0d)
		
		val list = newArrayList
		iterable.forEach[list.add(it)]
		assertEquals(#[expected], list)
		
		val a1 = iterable.stream().toArray
		assertArrayEquals(#[expected], a1, 0.0d)
		
		val list2 = newArrayList
		iterable.forEachDouble [
			list2.add(it)
		]
		assertEquals(#[expected], list2)
		
		val sp = Spliterators.spliteratorUnknownSize(iterable.iterator,0)
		val arr = StreamSupport.doubleStream(sp,false).toArray
		assertArrayEquals(#[expected], arr, 0.0d)
	}
	
	
	/////////////////////
	// Utility methods //
	/////////////////////
	
	private def testEmptyIterator(OfDouble iterator) {
		assertNotNull(iterator)
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextDouble
		]
	}
	
	private def testOneElementIterator(OfDouble i, double expected, double delta) {
		assertNotNull(i)
		assertTrue(i.hasNext)
		assertEquals(expected, i.nextDouble, delta)
		testEmptyIterator(i)
	} 
}