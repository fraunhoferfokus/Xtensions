package de.fhg.fokus.xtensions.optional

import static extension de.fhg.fokus.xtensions.optional.OptionalIntExtensions.*
import org.junit.Test
import static org.junit.Assert.*
import java.util.OptionalInt
import de.fhg.fokus.xtensions.Util
import java.util.NoSuchElementException
import static de.fhg.fokus.xtensions.Util.*
import java.util.PrimitiveIterator.OfInt
import java.util.stream.StreamSupport
import java.util.Spliterators
import java.util.concurrent.atomic.AtomicBoolean
import java.util.Set

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
	
	///////////////////////
	// whenPresent or else //
	///////////////////////
	
	@Test def tesWhenPresentOrElseOnEmpty() {
		val OptionalInt o = OptionalInt.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		
		o.whenPresent [
			fail()
		].elseDo [
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def tesWhenPresentOrElseOnEmptyOneVal() {
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
	
	@Test def tesWhenPresentOrElseOnEmptyTwoVals() {
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
	
	def testOneElementIterator(OfInt i, int expected) {
		assertNotNull(i)
		assertTrue(i.hasNext)
		assertSame(expected, i.nextInt)
		testEmptyIterator(i)
	} 
}