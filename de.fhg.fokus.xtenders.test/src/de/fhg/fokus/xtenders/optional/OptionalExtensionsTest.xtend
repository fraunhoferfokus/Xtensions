package de.fhg.fokus.xtenders.optional

import org.junit.Test
import java.util.Optional
import static extension de.fhg.fokus.xtenders.optional.OptionalExtensions.*
import static org.junit.Assert.*
import java.util.concurrent.atomic.AtomicBoolean
import java.util.function.Supplier
import java.util.Iterator
import java.util.NoSuchElementException
import java.util.Set
import java.util.List
import java.util.stream.StreamSupport

class OptionalExtensionsTest {
	
	//////////////
	// Unboxing //
	//////////////
	
	@Test def void testUnboxInt() {
		val boxed = Optional.of(1)
		val unboxed = boxed.unboxInt
		assertEquals(boxed.get, unboxed.asInt)
		
		val Optional<Integer> boxedEmpty = Optional.empty
		val unpoxedEmpty = boxedEmpty.unboxInt
		assertFalse(unpoxedEmpty.isPresent)
	}
	
	@Test def void testUnboxLong() {
		val boxed = Optional.of(1L)
		val unboxed = boxed.unboxLong
		assertEquals(boxed.get, unboxed.asLong)
		
		val Optional<Long> boxedEmpty = Optional.empty
		val unpoxedEmpty = boxedEmpty.unboxLong
		assertFalse(unpoxedEmpty.isPresent)
	}
	
	@Test def void testUnboxDouble() {
		val boxed = Optional.of(1.0d)
		val unboxed = boxed.unboxDouble
		assertEquals(boxed.get, unboxed.asDouble, 0.001d)
		
		val Optional<Double> boxedEmpty = Optional.empty
		val unpoxedEmpty = boxedEmpty.unboxDouble
		assertFalse(unpoxedEmpty.isPresent)
	}
	
	/////////////////////
	// ifPresentOrElse //
	/////////////////////
	
	@Test def void ifPresentOrElseOnVlaue() {
		val opt = Optional.of(3)
		val result = newArrayList
		opt.ifPresentOrElse([result.add(it)] , [fail()])
		assertEquals(#[3], result)
	}
	
	@Test def void ifPresentOrElseOnEmpty() {
		val Optional<Integer> opt = Optional.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		opt.ifPresentOrElse([fail()] , [result.set(true)])
		assertTrue(result.get)
	}
	
	////////////
	// stream //
	////////////
	
	@Test def void streamOnValue() {
		val expected = "foo"
		val o = Optional.of(expected)
		val result = o.stream​().toArray
		assertArrayEquals(#[expected], result)
	}
	
	@Test def void streamOnEmpty() {
		val Optional<String> o = Optional.empty
		val result = o.stream​().count
		assertEquals(0, result)
	}
	
	/////////////////
	// or Supplier //
	/////////////////
	
	@Test def void orEmptyEmpty() {
		val Optional<CharSequence> o = Optional.empty
		val Optional<String> o2 = Optional.empty
		val result = o.or[o2]
		assertFalse(result.isPresent)
	}
	
	@Test def void orEmptyValue() {
		val expected = "bar"
		val Optional<CharSequence> o = Optional.empty
		val Optional<String> o2 = Optional.of(expected)
		val result = o.or[o2]
		assertTrue(result.isPresent)
		assertSame(expected, result.get)
	}
	
	@Test def void orValueX() {
		val expected = "bar"
		val Optional<CharSequence> o = Optional.of(expected)
		val result = o.or[fail();return null]
		assertTrue(result.isPresent)
		assertSame(expected, result.get)
	}
	
	
	@Test def void orOpEmptyEmpty() {
		val Optional<CharSequence> o = Optional.empty
		val Optional<String> o2 = Optional.empty
		val result = o || [o2]
		assertFalse(result.isPresent)
	}
	
	@Test def void orOpEmptyValue() {
		val expected = "bar"
		val Optional<CharSequence> o = Optional.empty
		val Optional<String> o2 = Optional.of(expected)
		val result = o || [o2]
		assertTrue(result.isPresent)
		assertSame(expected, result.get)
	}
	
	@Test def void orOpValueX() {
		val expected = "bar"
		val Optional<CharSequence> o = Optional.of(expected)
		val result = o || [fail();return null]
		assertTrue(result.isPresent)
		assertSame(expected, result.get)
	}
	
	/////////////////
	// or Optional //
	/////////////////
	
	@Test def void orOptionalEmptyEmpty() {
		val Optional<CharSequence> o = Optional.empty
		val Optional<String> o2 = Optional.empty
		val result = o.or(o2)
		assertFalse(result.isPresent)
	}
	
	@Test def void orOptionalEmptyValue() {
		val expected = "bar"
		val Optional<CharSequence> o = Optional.empty
		val Optional<String> o2 = Optional.of(expected)
		val result = o.or(o2)
		assertTrue(result.isPresent)
		assertSame(expected, result.get)
	}
	
	@Test def void orOptionalValueEmpty() {
		val expected = "bar"
		val Optional<CharSequence> o = Optional.of(expected)
		val result = o.or(Optional.empty)
		assertTrue(result.isPresent)
		assertSame(expected, result.get)
	}
	
	@Test def void orOptionalValueValue() {
		val expected = "bar"
		val other = "foo"
		val Optional<CharSequence> o = Optional.of(expected)
		val result = o.or(Optional.of(other))
		assertTrue(result.isPresent)
		assertSame(expected, result.get)
	}
	
	
	@Test def void orOptionalOpEmptyEmpty() {
		val Optional<CharSequence> o = Optional.empty
		val Optional<String> o2 = Optional.empty
		val result = o || o2
		assertFalse(result.isPresent)
	}
	
	@Test def void orOptionalOpEmptyValue() {
		val expected = "bar"
		val Optional<CharSequence> o = Optional.empty
		val Optional<String> o2 = Optional.of(expected)
		val result = o || o2
		assertTrue(result.isPresent)
		assertSame(expected, result.get)
	}
	
	@Test def void orOptionalOpValueEmpty() {
		val expected = "bar"
		val Optional<CharSequence> o = Optional.of(expected)
		val result = o || Optional.empty
		assertTrue(result.isPresent)
		assertSame(expected, result.get)
	}
	
	@Test def void orOptionalOpValueValue() {
		val expected = "bar"
		val other = "foo"
		val Optional<CharSequence> o = Optional.of(expected)
		val result = o || Optional.of(other)
		assertTrue(result.isPresent)
		assertSame(expected, result.get)
		
	}
	
	/////////////////////
	// filter by class //
	/////////////////////
	
	@Test def void testFilterNotInstance() {
		val Optional<Object> o = Optional.of("")
		val Optional<Integer> o2 = o.filter(Integer)
		
		assertFalse(o2.present)
	}
	
	@Test def void testFilterIsInstance() {
		val expected = "foo"
		val Optional<Object> o = Optional.of(expected)
		val Optional<String> o2 = o.filter(String)
		
		assertSame(expected, o2.get)
	}
	
	@Test def void testFilterEmpty() {
		val Optional<Object> o = Optional.empty
		val Optional<String> o2 = o.filter(String)
		
		assertFalse(o2.present)
	}
	
	///////////
	// maybe //
	///////////
	
	@Test def void testMaybeWithVal() {
		val expected = "foo"
		val o = maybe(expected)
		
		assertTrue(o.present)
		assertSame(expected, o.get)
	}
	
	@Test def void testMaybeWithNull() {
		val o = maybe(null)
		
		assertFalse(o.present)
	}
	
	//////////
	// some //
	//////////
	
	@Test def void testSomeWithVal() {
		val expected = "foo"
		val o = maybe(expected)
		
		assertTrue(o.present)
		assertSame(expected, o.get)
	}
	
	@Test(expected = NullPointerException) def void testSomeWithNull() {
		val o = some(null)
		fail()
	}
	
	//////////
	// none //
	//////////
	
	@Test def void testNone() {
		val Optional<String> o = none
		assertFalse(o.present)
	}
	
	///////////
	// elvis //
	///////////
	
	@Test def void testElvisWithValue() {
		val expected = "foo"
		val o = Optional.of(expected)
		val result = o ?: "bar"
		
		assertSame(expected, result)
	}
	
	@Test def void testElvisWithoutValue() {
		val o = Optional.empty
		val expected = "bar"
		val result = o ?: expected
		
		assertSame(expected, result)
	}
	
	@Test def void testElvisWithoutValueNullAlternative() {
		val Optional<String> o = Optional.empty
		val String alt = null
		val result = o ?: alt
		
		assertNull(result)
	}
	
	////////////////////
	// elvis supplier //
	////////////////////
	
	@Test def void testElvisSupplierWithValue() {
		val expected = "foo"
		val o = Optional.of(expected)
		val result = o ?: [fail();"bar"]
		
		assertSame(expected, result)
	}
	
	@Test def void testElvisSupplierWithoutValue() {
		val o = Optional.empty
		val expected = "bar"
		val result = o ?: [expected]
		
		assertSame(expected, result)
	}
	
	@Test def void testElvisSupplierWithoutValueNullAlternative() {
		val Optional<String> o = Optional.empty
		val Supplier<String> alt = [null]
		val result = o ?: alt
		
		assertNull(result)
	}
	
	@Test def void testElvisSupplierWithValueNullSupplier() {
		val expected = "foo"
		val Optional<String> o = Optional.of(expected)
		val Supplier<String> sup = null
		val result = o ?: sup
		
		assertSame(expected, result)
	}
	
	@Test(expected = NullPointerException) def void testElvisSupplierWithoutValueNullSupplier() {
		val Optional<String> o = Optional.empty
		val Supplier<String> sup = null
		val result = o ?: sup
		println(result)
		fail()
	}
	
	////////////
	// mapInt //
	////////////
	
	@Test def void testMapIntEmpty() {
		val Optional<String> o = Optional.empty
		val oi = o.mapInt[fail();length]
		assertFalse(oi.present)
	}
	
	@Test def void testMapIntValue() {
		val o = Optional.of("foo")
		val oi = o.mapInt[length]
		assertTrue(oi.present)
		assertEquals(3, oi.asInt)
	}
	
	////////////
	// mapLong //
	////////////
	
	@Test def void testMapLongEmpty() {
		val Optional<String> o = Optional.empty
		val ol = o.mapLong[fail();Long.MAX_VALUE]
		assertFalse(ol.present)
	}
	
	@Test def void testMapLongValue() {
		val o = Optional.of("foo")
		val ol = o.mapLong[Long.MAX_VALUE]
		assertTrue(ol.present)
		assertEquals(Long.MAX_VALUE, ol.asLong)
	}
	
	///////////////
	// mapDouble //
	///////////////
	
	@Test def void testMapDoubleEmpty() {
		val Optional<String> o = Optional.empty
		val od = o.mapDouble[fail();Double.MAX_VALUE]
		assertFalse(od.present)
	}
	
	@Test def void testMapDoubleValue() {
		val o = Optional.of("foo")
		val od = o.mapDouble[Long.MAX_VALUE]
		assertTrue(od.present)
		assertEquals(Long.MAX_VALUE, od.asDouble, 0.00001d)
	}
	
	//////////////
	// iterator //
	//////////////
	
	@Test def void testIteratorEmpty() {
		val Optional<String> o = Optional.empty
		val i = o.iterator
		testEmptyIterator(i)
	}
	
	private def testEmptyIterator(Iterator<?> iterator) {
		assertNotNull(iterator)
		assertFalse(iterator.hasNext)
		expectException(NoSuchElementException) [
			iterator.next
		]
	}
	
	@Test def void testIteratorElement() {
		val expected = "foo"
		val Optional<String> o = Optional.of(expected)
		val i = o.iterator
		testOneElementIterator(i, expected)
	}
	
	def <T> testOneElementIterator(Iterator<T> i, T expected) {
		assertNotNull(i)
		assertTrue(i.hasNext)
		assertSame(expected, i.next)
		testEmptyIterator(i)
	}
	
	
	//////////////
	// Iterable //
	//////////////
	
	@Test def void testIterableEmpty() {
		val Optional<String> o = Optional.empty
		val iterable = o.asIterable
		assertNotNull(iterable)
		var i = iterable.iterator
		testEmptyIterator(i)
		i = iterable.iterator
		testEmptyIterator(i)
		
		iterable.forEach[fail()]
		
		val sp = iterable.spliterator
		val arr = StreamSupport.stream(sp,false).toArray
		assertTrue(arr.empty)
	}
	
	@Test def void testIterableElement() {
		val expected = "baz"
		val Optional<String> o = Optional.of(expected)
		val iterable = o.asIterable
		
		val i1 = iterable.iterator
		testOneElementIterator(i1, expected)
		val i2 = iterable.iterator
		testOneElementIterator(i2, expected)
		
		val list = newArrayList
		iterable.forEach[list.add(it)]
		assertEquals(#[expected], list)
		
		val sp = iterable.spliterator
		val arr = StreamSupport.stream(sp,false).toArray
		assertArrayEquals(#[expected], arr)
	}
	
	private def <X extends Exception> X expectException(Class<X> exClass, ()=>void action) {
		try {
			action.apply
		} catch(Exception e) {
			if(exClass.isInstance(e)) {
				return exClass.cast(e)
			}
			fail("Exception not instance of " + exClass.name)
		}
		throw new AssertionError("Expected exception of type " + exClass.name)
	}
	
	//////////////////
	// ifNotPresent //
	//////////////////
	
	@Test def testIfNotPresentNotPresent() {
		val Optional<String> o = Optional.empty
		
		val AtomicBoolean result = new AtomicBoolean(false)
		o.ifNotPresent[|
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def testIfNotPresentPresent() {
		val Optional<String> o = Optional.of("foo")
		
		o.ifNotPresent[|
			fail()
		]
	}
	
	///////////////////////////
	// ifNotPresentProcedure //
	///////////////////////////
	
	@Test def testIfNotPresentProcNotPresent() {
		val Optional<String> o = Optional.empty
		
		val AtomicBoolean result = new AtomicBoolean(false)
		val action = ifNotPresent[|
			result.set(true)
		]
		action.apply(o)
		
		assertTrue(result.get)
	}
	
	@Test def testIfNotPresentProcPresent() {
		val Optional<String> o = Optional.of("foo")
		
		val action = ifNotPresent[|
			fail()
		]
		action.apply(o)
	}
	
	///////////////////////
	// ifPresent or else //
	///////////////////////
	
	@Test def tesIfPresentOrElseOnEmpty() {
		val Optional<String> o = Optional.empty
		val AtomicBoolean result = new AtomicBoolean(false)
		
		val action = ifPresent [
			fail()
		].elseDo [
			result.set(true)
		]
		action.apply(o)
		
		assertTrue(result.get)
	}
	
	@Test def tesIfPresentOnEmpty() {
		val Optional<String> o = Optional.empty
		
		val action = ifPresent [
			fail()
		]
		action.apply(o)
	}
	
	@Test def tesIfPresentOnValue() {
		val expected = "woo"
		val Optional<String> o = Optional.of(expected)
		val AtomicBoolean result = new AtomicBoolean(false)
		
		val action = ifPresent [String it|
			assertSame(expected, it)
			result.set(true)
		]
		action.apply(o)
		assertTrue(result.get)
	}
	
	@Test def tesIfPresentOrElseOnValue() {
		val expected = "gaga"
		val Optional<String> o = Optional.of(expected)
		val AtomicBoolean result = new AtomicBoolean(false)
		
		val action = ifPresent [String it|
			assertSame(expected, it)
			result.set(true)
		].elseDo [
			fail()
		]
		action.apply(o)
		
		assertTrue(result.get)
	}
	
	///////////
	// toSet //
	///////////
	
	@Test def void testToSetOnEmpty() {
		val o = Optional.<String>empty
		
		val Set<String> result = o.toSet
		assertTrue(result.empty)
		assertEquals(0, result.size)
		testEmptyIterator(result.iterator)
		expectException(UnsupportedOperationException) [
			result.add("foo")
		]
	}
	
	@Test def void testToSetOnValue() {
		val expected = "baba"
		val o = Optional.of(expected)
		
		val Set<String> result = o.toSet
		assertFalse(result.empty)
		assertEquals(1, result.size)
		testOneElementIterator(result.iterator, expected)
		assertTrue(result.contains(expected))
		expectException(UnsupportedOperationException) [
			result.add("foo")
		]
	}
	
	////////////
	// toList //
	////////////
	
	@Test def void testToSListOnEmpty() {
		val o = Optional.<String>empty
		
		val List<String> result = o.toList
		assertTrue(result.empty)
		assertEquals(0, result.size)
		testEmptyIterator(result.iterator)
		expectException(UnsupportedOperationException) [
			result.add("foo")
		]
	}
	
	@Test def void testToListOnValue() {
		val expected = "baba"
		val o = Optional.of(expected)
		
		val List<String> result = o.toList
		assertFalse(result.empty)
		assertEquals(1, result.size)
		testOneElementIterator(result.iterator, expected)
		assertTrue(result.contains(expected))
		assertSame(expected, result.get(0))
		expectException(UnsupportedOperationException) [
			result.set(0,"bar")
		]
		expectException(UnsupportedOperationException) [
			result.add("foo")
		]
	}
	
	///////////////////
	// ifBothPresent //
	///////////////////
	
	@Test def testIfBothPresentBothEmpty() {
		val a = Optional.<String>empty
		val b = Optional.<List<String>>empty
		
		a.ifBothPresent(b) [av,bv|
			fail()
		]
	}
	
	@Test def testIfBothPresentSecondEmpty() {
		val a = Optional.of("foo")
		val b = Optional.<List<String>>empty
		
		a.ifBothPresent(b) [av,bv|
			fail()
		]
	}
	
	
	@Test def testIfBothPresentFirstEmpty() {
		val a = Optional.<String>empty
		val b = Optional.of(#["foo"])
		
		a.ifBothPresent(b) [av,bv|
			fail()
		]
	}
	
	@Test def testIfBothPresentBothPresent() {
		val expectedA = "foo"
		val expectedB = #["bar"]
		val a = Optional.of(expectedA)
		val b = Optional.of(expectedB)
		val AtomicBoolean result = new AtomicBoolean(false)
		
		a.ifBothPresent(b) [String av, List<String> bv|
			assertSame(expectedA, av)
			assertSame(expectedB, bv)
			result.set(true)
		]
		assertTrue(result.get)
	}
	
	//////////////////
	// ifAllPresent //
	////////////////// 
	
	@Test def ifAllPresentEmptyList() {
		
		val AtomicBoolean result = new AtomicBoolean(false)
		#[].ifAllPresent [l|
			assertTrue(l.empty)
			result.set(true)
		]
		assertTrue(result.get)
	}
	
	
	@Test def ifAllPresentEmptyOptional() {
		#[Optional.empty].ifAllPresent [l|
			fail()
		]
	}
	
	@Test def ifAllPresentEmptyOptionals() {
		#[Optional.empty,Optional.empty,Optional.empty].ifAllPresent [l|
			fail()
		]
	}
	
	@Test def ifAllPresentNotAllValue() {
		#[Optional.empty,Optional.of("foo"),Optional.empty].ifAllPresent [l|
			fail()
		]
	}
	
	@Test def ifAllPresentWithOnePresent() {
		val expected = "foo"
		val AtomicBoolean result = new AtomicBoolean(false)

		#[Optional.of(expected)].ifAllPresent [l|
			assertEquals(1, l.length)
			assertSame(expected, l.get(0))
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
	@Test def ifAllPresentWithMultiplePresent() {
		val a = "foo"
		val b = "bar"
		val c = "woo"
		val AtomicBoolean result = new AtomicBoolean(false)

		#[Optional.of(a),Optional.of(b),Optional.of(c)].ifAllPresent [l|
			assertEquals(#[a,b,c], l)
			result.set(true)
		]
		
		assertTrue(result.get)
	}
	
//	@Test def void getOrReturn() {
//		val test = callGetOrReturnNoReturn("foo")
//		assertEquals("Some foo", test.get())
//		
//		val test2 = callGetOrReturnNoReturn(null)
//		assertFalse(test2.isPresent)
//	}
//	
//	def Optional<String> callGetOrReturnNoReturn(String s) {
//		val Optional<CharSequence> o = Optional.ofNullable(s)
//		val r = o.getOrReturn
//		
//		return some("Some " + r)
//	}
}