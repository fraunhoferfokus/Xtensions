package de.fhg.fokus.xtensions.incubation

import static extension de.fhg.fokus.xtensions.incubation.Primitives.*
import static org.junit.Assert.*
import org.junit.Test
import java.util.OptionalInt
import java.util.OptionalLong
import java.util.OptionalDouble

class PrimitivesTest {
	
	/////////////////////////////
	// isTrue(T, (T)=>boolean) //
	/////////////////////////////

	@Test
	def void testIsTrueContextNull() {
		val Object context = null
		assertFalse( context.isTrue[true] )
	}

	@Test
	def void testIsTrueContextPassedToLambda() {
		val context = new Object
		extension val _ = new Object {
			Object actual
		}
		context.isTrue[actual = it; true]
		assertSame(context, actual)
	}

	@Test
	def void testIsTrueLambdaReturnsNull() {
		val context = new Object
		assertFalse( context.isTrue[null] )
	}

	@Test
	def void testIsTrueLambdaReturnsTrue() {
		val context = new Object
		assertTrue( context.isTrue[true] )
	}

	@Test
	def void testIsTrueLambdaReturnsFalse() {
		val context = new Object
		assertFalse( context.isTrue[false] )
	}
	
	@Test(expected = IndexOutOfBoundsException)
	def void testIsTrueLambdaThrows() {
		val context = new Object
		context.isTrue[throw new IndexOutOfBoundsException]
	}
	
	@Test(expected = NullPointerException)
	def void testIstrueLambdaIsNull() {
		val context = new Object
		context.isTrue(null)
	}
	
	///////////////////////////////////
	// isNullOrTrue(T, (T)=>boolean) //
	///////////////////////////////////

	@Test
	def void testIsNullOrTrueContextNull() {
		val Object context = null
		assertTrue( context.isNullOrTrue[true] )
	}

	@Test
	def void testIsNullOrTrueContextPassedToLambda() {
		val context = new Object
		extension val _ = new Object {
			Object actual
		}
		context.isNullOrTrue[actual = it; true]
		assertSame(context, actual)
	}

	@Test
	def void testIsNullOrTrueLambdaReturnsNull() {
		val context = new Object
		assertTrue( context.isNullOrTrue[null] )
	}

	@Test
	def void testIsNullOrTrueLambdaReturnsTrue() {
		val context = new Object
		assertTrue( context.isNullOrTrue[true] )
	}

	@Test
	def void testIsNullOrTrueLambdaReturnsFalse() {
		val context = new Object
		assertFalse( context.isNullOrTrue[false] )
	}
	
	@Test(expected = IndexOutOfBoundsException)
	def void testIsNullOrTrueLambdaThrows() {
		val context = new Object
		context.isNullOrTrue[throw new IndexOutOfBoundsException]
	}

	@Test(expected = NullPointerException)
	def void testIsNullOrTrueLambdaIsNull() {
		val context = new Object
		context.isNullOrTrue(null)
	}
	
	//////////////////////////////
	// isFalse(T, (T)=>boolean) //
	//////////////////////////////
	
	
		@Test
	def void testIsFalseContextNull() {
		val Object context = null
		assertFalse( context.isFalse[true] )
	}

	@Test
	def void testIsFalseContextPassedToLambda() {
		val context = new Object
		extension val _ = new Object {
			Object actual
		}
		context.isFalse[actual = it; true]
		assertSame(context, actual)
	}

	@Test
	def void testIsFalseLambdaReturnsNull() {
		val context = new Object
		assertFalse( context.isFalse[null] )
	}

	@Test
	def void testIsFalseLambdaReturnsTrue() {
		val context = new Object
		assertFalse( context.isFalse[true] )
	}

	@Test
	def void testIsFalseLambdaReturnsFalse() {
		val context = new Object
		assertTrue( context.isFalse[false] )
	}
	
	@Test(expected = IndexOutOfBoundsException)
	def void testIsFalseLambdaThrows() {
		val context = new Object
		context.isFalse[throw new IndexOutOfBoundsException]
	}
	
	@Test(expected = NullPointerException)
	def void testIsFalseLambdaIsNull() {
		val context = new Object
		context.isFalse(null)
	}
	
	////////////////////////////////////
	// isNullOrFalse(T, (T)=>boolean) //
	////////////////////////////////////

	@Test
	def void testIsNullOrFalseContextNull() {
		val Object context = null
		assertTrue( context.isNullOrFalse[true] )
	}

	@Test
	def void testIsNullOrFalseContextPassedToLambda() {
		val context = new Object
		extension val _ = new Object {
			Object actual
		}
		context.isNullOrFalse[actual = it; true]
		assertSame(context, actual)
	}

	@Test
	def void testIsNullOrFalseLambdaReturnsNull() {
		val context = new Object
		assertTrue( context.isNullOrFalse[null] )
	}

	@Test
	def void testIsNullOrFalseLambdaReturnsTrue() {
		val context = new Object
		assertFalse( context.isNullOrFalse[true] )
	}

	@Test
	def void testIsNullOrFalseLambdaReturnsFalse() {
		val context = new Object
		assertTrue( context.isNullOrFalse[false] )
	}
	
	@Test(expected = IndexOutOfBoundsException)
	def void testIsNullOrFalseLambdaThrows() {
		val context = new Object
		context.isNullOrFalse[throw new IndexOutOfBoundsException]
	}
	
	@Test(expected = NullPointerException)
	def void testIsNullOrFalseLambdaIsNull() {
		val context = new Object
		context.isNullOrFalse(null)
	}



	/////////////////////
	// isTrue(Boolean) //
	/////////////////////

	@Test
	def void testIsTrueValueNull() {
		val Boolean b = null
		assertFalse( b.isTrue() )
	}

	@Test
	def void testIsTrueValueFalse() {
		assertFalse( false.isTrue() )
	}

	@Test
	def void testIsTrueValueTrue() {
		assertTrue( true.isTrue() )
	}

	/////////////////////
	// isTrue(Boolean) //
	/////////////////////

	@Test
	def void testIsFalseValueNull() {
		val Boolean b = null
		assertFalse( b.isFalse() )
	}

	@Test
	def void testIsFalseValueFalse() {
		assertTrue( false.isFalse() )
	}

	@Test
	def void testIsFalseValueTrue() {
		assertFalse( true.isFalse() )
	}

	///////////////////////////
	// isNullOrTrue(Boolean) //
	///////////////////////////

	@Test
	def void testIsNullOrTrueValueNull() {
		val Boolean context = null
		assertTrue( context.isNullOrTrue() )
	}

	@Test
	def void testIsNullOrTrueValueTrue() {
		assertTrue( true.isNullOrTrue() )
	}

	@Test
	def void testIsNullOrTrueValueFalse() {
		assertFalse( false.isNullOrTrue() )
	}

	///////////////////////////
	// isNullOrFalse(Boolean) //
	///////////////////////////

	@Test
	def void testIsNullOrFalseValueNull() {
		val Boolean context = null
		assertTrue( context.isNullOrFalse() )
	}

	@Test
	def void testIsNullOrFalseValueTrue() {
		assertFalse( true.isNullOrFalse() )
	}

	@Test
	def void testIsNullOrFalseValueFalse() {
		assertTrue( false.isNullOrFalse() )
	}



	/////////
	// box //
	/////////

	@Test
	def void testBoxContextNull() {
		assertNull(null.box[throw new IllegalStateException])
	}

	@Test
	def void testBoxLambdaReturnsNull() {
		val context = new Object
		assertNull(context.box[null])
	}

	@Test
	def void testBoxAssertContextPassedOn() {
		val expected = new Object
		extension val validation = new Object {
			var isSame = false
		}
		expected.box[isSame = (it === expected); false]
		assertTrue(isSame)
	}

	@Test
	def void testBoxToTrue() {
		val context = new Object
		assertEquals(Boolean.TRUE, context.box[true])
	}

	@Test
	def void testBoxToFalse() {
		val context = new Object
		assertEquals(Boolean.FALSE, context.box[false])
	}


	////////////
	// boxNum //
	////////////

	@Test
	def void testBoxNumContextNull() {
		assertNull(null.boxNum[throw new IllegalStateException])
	}

	@Test
	def void testBoxNumLambdaReturnsNull() {
		val context = new Object
		assertNull(context.box[null])
	}

	@Test
	def void testBoxNumAssertContextPassedOn() {
		val expected = new Object
		extension val validation = new Object {
			var isSame = false
		}
		expected.boxNum[isSame = (it === expected); 0]
		assertTrue(isSame)
	}

	@Test
	def void testBoxNumIntegerValue() {
		val context = new Object
		val expected = 42
		assertEquals(expected, context.boxNum[expected])
	}

	@Test
	def void testBoxNumDoubleValue() {
		val context = new Object
		val expected = 4711.0d
		assertEquals(Double.valueOf(expected), context.boxNum[expected])
	}

	/////////////////////
	// onNull(Integer) //
	/////////////////////

	@Test
	def void testOnNullIntegerContextNull() {
		val Integer i = null
		val expected = 1
		val int result = i.onNull[expected]
		assertEquals(expected, result)
	}

	@Test
	def void testOnNullIntegerContextValue() {
		val expected = 42
		val int result = expected.onNull[throw new IllegalStateException]
		assertEquals(expected, result)
	}

	@Test(expected = NullPointerException)
	def void testOnNullIntegerFallbackNull() {
		50.onNull(null)
	}

	//////////////////
	// onNull(Long) //
	//////////////////

	@Test
	def void testOnNullLongContextNull() {
		val Long l = null
		val expected = 1
		val long result = l.onNull[expected]
		assertEquals(expected, result)
	}

	@Test
	def void testOnNullLongContextValue() {
		val expected = 42L
		val long result = expected.onNull[throw new IllegalStateException]
		assertEquals(expected, result)
	}

	@Test(expected = NullPointerException)
	def void testOnNullLongFallbackNull() {
		50L.onNull(null)
	}

	////////////////////
	// onNull(Double) //
	////////////////////

	@Test
	def void testOnNullDoubleContextNull() {
		val Double d = null
		val expected = 1
		val double result = d.onNull[expected]
		assertEquals(expected, result, 0.0d)
	}

	@Test
	def void testOnNullDoubleContextValue() {
		val expected = 42.0d
		val double result = expected.onNull[throw new IllegalStateException]
		assertEquals(expected, result, 0.0d)
	}

	@Test(expected = NullPointerException)
	def void testOnNullDoubleFallbackNull() {
		50.0d.onNull(null)
	}

	/////////////////////
	// onNull(Boolean) //
	/////////////////////

	@Test
	def void testOnNullBoolContextNull() {
		val Boolean b = null
		val expected = true
		val boolean result = b.onNull[expected]
		assertEquals(expected, result)
	}

	@Test
	def void testOnNullBoolContextValue() {
		val expected = true
		val boolean result = expected.onNull[throw new IllegalStateException]
		assertEquals(expected, result)
	}

	@Test(expected = NullPointerException)
	def void testOnNullBoolFallbackNull() {
		true.onNull(null)
	}
	
	/////////////////
	// optionalInt //
	/////////////////

	@Test(expected = NullPointerException)
	def void testOptionalIntNullMapper() {
		null.optionalInt(null)
	}

	@Test
	def void testOptionalIntContextNull() {
		val result = null.optionalInt[throw new IllegalStateException]
		assertFalse(result.present)
	}

	@Test
	def void testOptionalIntContextPassedToMapper() {
		extension val sameCheck = new Object {
			boolean result = false
		}
		val context = new Object
		context.optionalInt[
			result = (it === context)
			0
		]
		assertTrue(result)
	}

	@Test
	def void testOptionalIntContextValue() {
		val expected = 42
		val actual = expected.optionalInt[expected]
		assertEquals(OptionalInt.of(expected), actual)
	}

	//////////////////
	// optionalLong //
	//////////////////

	@Test(expected = NullPointerException)
	def void testOptionalLongNullMapper() {
		null.optionalLong(null)
	}

	@Test
	def void testOptionalLongContextNull() {
		val result = null.optionalLong[throw new IllegalStateException]
		assertFalse(result.present)
	}

	@Test
	def void testOptionalLongContextPassedToMapper() {
		extension val sameCheck = new Object {
			boolean result = false
		}
		val context = new Object
		context.optionalLong[
			result = (it === context)
			0L
		]
		assertTrue(result)
	}

	@Test
	def void testOptionalLongContextValue() {
		val expected = 42L
		val actual = expected.optionalLong[expected]
		assertEquals(OptionalLong.of(expected), actual)
	}

	////////////////////
	// optionalDouble //
	////////////////////

	@Test(expected = NullPointerException)
	def void testOptionalDoubleNullMapper() {
		null.optionalDouble(null)
	}

	@Test
	def void testOptionalDoubleContextNull() {
		val result = null.optionalDouble[throw new IllegalStateException]
		assertFalse(result.present)
	}

	@Test
	def void testOptionalDoubleContextPassedToMapper() {
		extension val sameCheck = new Object {
			boolean result = false
		}
		val context = new Object
		context.optionalDouble[
			result = (it === context)
			0.0d
		]
		assertTrue(result)
	}

	@Test
	def void testOptionalDoubleContextValue() {
		val expected = 42.0d
		val actual = expected.optionalDouble[expected]
		assertEquals(OptionalDouble.of(expected), actual)
	}
}