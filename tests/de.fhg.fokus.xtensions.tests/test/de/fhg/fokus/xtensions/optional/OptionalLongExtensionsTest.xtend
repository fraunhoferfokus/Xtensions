package de.fhg.fokus.xtensions.optional

import org.junit.Test
import static extension de.fhg.fokus.xtensions.optional.OptionalLongExtensions.*
import java.util.OptionalLong
import static org.junit.Assert.*
import java.util.NoSuchElementException
import de.fhg.fokus.xtensions.Util
import java.util.concurrent.atomic.AtomicBoolean
import java.util.function.LongSupplier
import java.util.Set
import java.util.PrimitiveIterator.OfLong
import java.util.Spliterators
import java.util.stream.StreamSupport

class OptionalLongExtensionsTest {
	
	
	//////////
	// some //
	//////////
	
	@Test def void testSomeValue() {
		val expected = 4
		val OptionalLong o =  some(expected)
		assertTrue(o.present)
		assertEquals(expected, o.asLong)
	}
	
	////////////
	// someOf //
	////////////
	
	@Test def void testSomeOfVeryLowValue() {
		val expected = Long.MIN_VALUE + 1
		testSomeOf(expected)
	}
	
	@Test def void testSomeOfLowestCached() {
		val expected = -128L
		testSomeOf(expected)
	}
	
	@Test def void testSomeOfHighestCached() {
		val expected = 127L
		testSomeOf(expected)
	}
	
	
	@Test def void testSomeOfZero() {
		val expected = 0L
		testSomeOf(expected)
	}
	
	
	@Test def void testSomeOfVeryHighValue() {
		val expected = Long.MAX_VALUE + 1
		testSomeOf(expected)
	}
	
	
	////////////
	// noLong //
	////////////
	
	@Test def void testNoLong() {
		val OptionalLong o =  noLong
		assertFalse(o.present)
		Util.expectException(NoSuchElementException) [
			o.asLong
		]
	}
	
	///////////
	// maybe //
	///////////
	
	@Test def void testMaybeWithValue() {
		val Long expected = -30000000L
		val OptionalLong o =  expected.maybe
		assertTrue(o.present)
		assertEquals(expected, o.asLong)
	}
	
	
	@Test def void testMaybeWithNullValue() {
		val expected = null
		val OptionalLong o =  maybe(expected)
		assertFalse(o.present)
		Util.expectException(NoSuchElementException) [
			o.asLong
		]
	}
	
	/////////////////////////
	// whenPresent or else //
	/////////////////////////
	
	@Test def testWhenPresentOrElseOnEmpty() {
		val OptionalLong o = OptionalLong.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		
		o.whenPresent [
			fail()
		].elseDo [
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def testWhenPresentOrElseOnEmptyOneVal() {
		val OptionalLong o = OptionalLong.empty
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
		val OptionalLong o = OptionalLong.empty
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
		val OptionalLong o = OptionalLong.of(expected)
		val AtomicBoolean result = new AtomicBoolean(false)
		
		o.whenPresent [
			assertEquals(expected, it)
			result.set(true)
		]
		assertTrue(result.get)
	}
	
	@Test def void testWhenPresentOrElseOnValue() {
		val expected = 4711
		val OptionalLong o = OptionalLong.of(expected)
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
	
	
	//////////////////
	// ifNotPresent //
	//////////////////
	
	@Test def testIfNotPresentNotPresent() {
		val OptionalLong o = OptionalLong.empty
		
		val AtomicBoolean result = new AtomicBoolean(false)
		o.ifNotPresent[|
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def testIfNotPresentPresent() {
		val OptionalLong o = OptionalLong.of(4711)
		
		o.ifNotPresent[|
			fail()
		]
	}
	
	///////////
	// boxed //
	///////////
	
	@Test def void testBoxedEmpty() {
		val o = OptionalLong.empty.boxed
		assertFalse(o.present)
	}
	
	@Test def void testBoxedValue() {
		val expected = Integer.MIN_VALUE
		val o = OptionalLong.of(expected).boxed
		assertTrue(o.present)
		assertEquals(expected, o.get as long)
	}
	
	////////////
	// filter //
	////////////
	
	@Test def void testFilterEmpty() {
		val o = OptionalLong.empty
		val result = o.filter[fail();true]
		assertFalse(result.present)
	}
	
	@Test def void testFilterLetThrough() {
		val expected = 32L
		val o = OptionalLong.of(expected)
		val result = o.filter[
			assertEquals(expected, it)
			true
		]
		assertTrue(result.present)
		assertEquals(expected, result.asLong)
	}
	
	@Test def void testFilterOut() {
		val expected = 64L
		val o = OptionalLong.of(expected)
		val result = o.filter[
			assertEquals(expected, it)
			false
		]
		assertFalse(result.present)
	}
	
	///////////
	// elvis //
	///////////
	
	@Test def void testElvisWithValue() {
		val expected = Long.MAX_VALUE
		val o = OptionalLong.of(expected)
		val long result = o ?: 70L
		
		assertEquals(expected, result)
	}
	
	@Test def void testElvisWithoutValue() {
		val o = OptionalLong.empty
		val expected = 9020010L
		val long result = o ?: expected
		
		assertEquals(expected, result)
	}
	
	////////////////////
	// elvis supplier //
	////////////////////
	
	@Test def void testElvisSupplierWithValue() {
		val expected = 77L
		val o = OptionalLong.of(expected)
		val long result = o ?: [fail();0L]
		
		assertEquals(expected, result)
	}
	
	@Test def void testElvisSupplierWithoutValue() {
		val o = OptionalLong.empty
		val expected = 42L
		val long result = o ?: [expected]
		
		assertEquals(expected, result)
	}
	
	@Test def void testElvisSupplierWithValueNullSupplier() {
		val expected = 815
		val OptionalLong o = OptionalLong.of(expected)
		val LongSupplier sup = null
		val result = o ?: sup
		
		assertEquals(expected, result)
	}
	
	@Test(expected = NullPointerException) def void testElvisSupplierWithoutValueNullSupplier() {
		val OptionalLong o = OptionalLong.empty
		val LongSupplier sup = null
		val result = o ?: sup
		println(result)
		fail()
	}
	
	////////////
	// mapInt //
	////////////
	
	@Test def void testMapIntEmpty() {
		val OptionalLong o = OptionalLong.empty
		val oi = o.mapInt[fail();0]
		assertFalse(oi.present)
	}
	
	@Test def void testMapIntValue() {
		val expected = 42
		val start = 21L
		val o = OptionalLong.of(start)
		val oi = o.mapInt[
			assertEquals(start, it)
			expected
		]
		assertTrue(oi.present)
		assertEquals(expected, oi.asInt)
	}
	
	////////////
	// mapLong //
	////////////
	
	@Test def void testMapLongEmpty() {
		val OptionalLong o = OptionalLong.empty
		val ol = o.mapLong[fail();Long.MAX_VALUE]
		assertFalse(ol.present)
	}
	
	@Test def void testMapLongValue() {
		val o = OptionalLong.of(99)
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
		val OptionalLong o = OptionalLong.empty
		val od = o.mapDouble[fail();Double.MAX_VALUE]
		assertFalse(od.present)
	}
	
	@Test def void testMapDoubleValue() {
		val start = 42
		val o = OptionalLong.of(start)
		val od = o.mapDouble[
			assertEquals(start, it)
			Long.MAX_VALUE
		]
		assertTrue(od.present)
		assertEquals(Long.MAX_VALUE, od.asDouble, 0.00001d)
	}
	
	/////////////////
	// flatMapLong //
	/////////////////
	
	@Test def void testFlatMapLongEmpty() {
		val OptionalLong o = OptionalLong.empty.flatMapLong[fail()null]
		assertFalse(o.present)
	}
	
	@Test def void testFlatMapLongReturnFilled() {
		val start = 4711L
		val OptionalLong o = OptionalLong.of(start)
		val OptionalLong expected = OptionalLong.of(42)
		val result = o.flatMapLong [
			assertEquals(start, it)
			expected
		]
		assertSame(expected, result)
	}
	
	@Test def void testFlatMapLongReturnEmpty() {
		val start = 9000L
		val OptionalLong o = OptionalLong.of(start)
		val OptionalLong expected = OptionalLong.empty
		val result = o.flatMapLong [
			assertEquals(start, it)
			expected
		]
		assertSame(expected, result)
	}
	
	/////////////////
	// or Supplier //
	/////////////////
	
	@Test def void orEmptyEmpty() {
		val OptionalLong o = OptionalLong.empty
		val OptionalLong o2 = OptionalLong.empty
		val result = o.or[o2]
		assertFalse(result.isPresent)
	}
	
	@Test def void orEmptyValue() {
		val expected = -400L
		val OptionalLong o = OptionalLong.empty
		val OptionalLong o2 = OptionalLong.of(expected)
		val result = o.or[o2]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asLong)
	}
	
	@Test def void orValueX() {
		val expected = -4711L
		val OptionalLong o = OptionalLong.of(expected)
		val result = o.or[fail();return null]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asLong)
	}
	
	
	@Test def void orOpEmptyEmpty() {
		val OptionalLong o = OptionalLong.empty
		val OptionalLong o2 = OptionalLong.empty
		val result = o || [o2]
		assertFalse(result.isPresent)
	}
	
	@Test def void orOpEmptyValue() {
		val expected = 815L
		val OptionalLong o = OptionalLong.empty
		val OptionalLong o2 = OptionalLong.of(expected)
		val result = o || [o2]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asLong)
	}
	
	@Test def void orOpValueX() {
		val expected = -9000L
		val OptionalLong o = OptionalLong.of(expected)
		val result = o || [fail();return null]
		assertTrue(result.isPresent)
		assertEquals(expected, result.asLong)
	}
	
	//////////////
	// asDouble //
	//////////////
	
	@Test def void testAsDoubleEmpty() {
		val o = OptionalLong.empty.asDouble
		assertFalse(o.present)
	}
	
	@Test def void testAsDoubleElement() {
		val o = OptionalLong.of(87L).asDouble
		assertTrue(o.present)
		val result = o.asDouble
		assertEquals(87.0d, result, 0.001d)
	}
	
	
	////////////
	// stream //
	////////////
	
	@Test def void streamOnValue() {
		val expected = -100L
		val o = OptionalLong.of(expected)
		val result = o.stream().toArray
		assertArrayEquals(#[expected], result)
	}
	
	@Test def void streamOnEmpty() {
		val OptionalLong o = OptionalLong.empty
		val result = o.stream().count
		assertEquals(0, result)
	}
	
		
	/////////////////////
	// ifPresentOrElse //
	/////////////////////
	
	@Test def void ifPresentOrElseOnVlaue() {
		val opt = OptionalLong.of(3L)
		val result = newArrayList
		opt.ifPresentOrElse​([result.add(it)] , [fail()])
		assertEquals(#[3L], result)
	}
	
	@Test def void ifPresentOrElseOnEmpty() {
		val OptionalLong opt = OptionalLong.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		opt.ifPresentOrElse​([fail()] , [result.set(true)])
		assertTrue(result.get)
	}
	
	///////////
	// toSet //
	///////////
	
	@Test def void testToSetOnEmpty() {
		val o = OptionalLong.empty
		
		val Set<Long> result = o.toSet
		assertTrue(result.empty)
		assertEquals(0, result.size)
		assertFalse(result.iterator.hasNext)
		Util.expectException(UnsupportedOperationException) [
			result.add(4711L)
		]
	}
	
	@Test def void testToSetOnValue() {
		val expected = 911L
		val o = OptionalLong.of(expected)
		
		val Set<Long> result = o.toSet
		assertFalse(result.empty)
		assertEquals(1, result.size)
		
		var Long[] tmp = <Long>newArrayOfSize(1)
		val long actual = result.toArray(tmp).get(0)
		assertEquals(expected, actual)
		
		assertTrue(result.contains(expected))
		Util.expectException(UnsupportedOperationException) [
			result.add(42L)
		]
	}
	
	
	//////////////
	// iterator //
	//////////////
	
	@Test def void testIteratorEmpty() {
		val OptionalLong o = OptionalLong.empty
		val i = o.iterator
		testEmptyIterator(i)
	}
	
	@Test def void testIteratorElement() {
		val expected = 42
		val OptionalLong o = OptionalLong.of(expected)
		val i = o.iterator
		testOneElementIterator(i, expected)
	}
	
	
	//////////////
	// Iterable //
	//////////////
	
	@Test def void testIterableEmpty() {
		val OptionalLong o = OptionalLong.empty
		val iterable = o.asIterable
		assertNotNull(iterable)
		var i = iterable.iterator
		testEmptyIterator(i)
		i = iterable.iterator
		testEmptyIterator(i)
		
		iterable.forEach[fail()]
		
		val a1 = iterable.stream().toArray
		assertArrayEquals(#[], a1)
		
		iterable.forEachLong [
			fail()
		]
		
		val sp = Spliterators.spliteratorUnknownSize(iterable.iterator,0)
		val arr = StreamSupport.longStream(sp,false).toArray
		assertTrue(arr.empty)
	}
	
	@Test def void testIterableElement() {
		val expected = 42L
		val OptionalLong o = OptionalLong.of(expected)
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
		iterable.forEachLong [
			list2.add(it)
		]
		assertEquals(#[expected], list2)
		
		val sp = Spliterators.spliteratorUnknownSize(iterable.iterator,0)
		val arr = StreamSupport.longStream(sp,false).toArray
		assertArrayEquals(#[expected], arr)
	}
	
	/////////////////////
	// Utility methods //
	/////////////////////
	
	private def testEmptyIterator(OfLong iterator) {
		assertNotNull(iterator)
		assertFalse(iterator.hasNext)
		Util.expectException(NoSuchElementException) [
			iterator.nextLong
		]
	}
	
	private def testOneElementIterator(OfLong i, long expected) {
		assertNotNull(i)
		assertTrue(i.hasNext)
		assertEquals(expected, i.nextLong)
		testEmptyIterator(i)
	} 
	
	private def void testSomeOf(long expected) {
		val OptionalLong o =  someOf(expected)
		assertTrue(o.present)
		assertEquals(expected, o.asLong)
		
		val OptionalLong o2 =  someOf(expected)
		assertTrue(o2.present)
		assertEquals(expected, o2.asLong)
	}
}