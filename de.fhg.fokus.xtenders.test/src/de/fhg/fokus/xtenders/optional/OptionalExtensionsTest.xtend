package de.fhg.fokus.xtenders.optional

import org.junit.Test
import java.util.Optional
import static extension de.fhg.fokus.xtenders.optional.OptionalExtensions.*
import static org.junit.Assert.*
import java.util.concurrent.atomic.AtomicBoolean

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