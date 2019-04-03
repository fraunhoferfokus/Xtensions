package de.fhg.fokus.xtensions.incubation

import static extension de.fhg.fokus.xtensions.incubation.Primitives.*
import static org.junit.Assert.*
import org.junit.Test

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
	
	
	// TODO onNull(Integer)
	// TODO onNull(Long)
	// TODO onNull(Double)
	// TODO onNull(Boolean)
}