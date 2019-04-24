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

import static extension org.junit.Assert.*
import org.junit.Test
import de.fhg.fokus.xtensions.optional.OptionalBoolean
import de.fhg.fokus.xtensions.optional.TrueOptional
import de.fhg.fokus.xtensions.optional.FalseOptional
import de.fhg.fokus.xtensions.optional.EmptyOptional
import static extension de.fhg.fokus.xtensions.optional.OptionalBoolean.asOptional

class OptionalBooleanTest {

	////////////////
	// asOptional //
	////////////////

	@Test
	def void testAsOptionalEmpty() {
		val o = null.asOptional
		o.assertNotNull()
		o.assertInstanceOf(EmptyOptional)
	}

	@Test
	def void testAsOptionalTrue() {
		val o = true.asOptional
		o.assertNotNull()
		o.assertInstanceOf(TrueOptional)
	}

	@Test
	def void testAsOptionalFalse() {
		val o = false.asOptional
		o.assertNotNull()
		o.assertInstanceOf(FalseOptional)
	}

	////////////////
	// ofNullable //
	////////////////

	@Test
	def void testOfNullableEmpty() {
		val o = OptionalBoolean.ofNullable(null)
		o.assertNotNull()
		o.assertInstanceOf(EmptyOptional)
	}

	@Test
	def void testOfNullableTrue() {
		val o = OptionalBoolean.ofNullable(true)
		o.assertNotNull()
		o.assertInstanceOf(TrueOptional)
	}

	@Test
	def void testOfNullableFalse() {
		val o = OptionalBoolean.ofNullable(false)
		o.assertNotNull()
		o.assertInstanceOf(FalseOptional)
	}

	///////////
	// empty //
	///////////

	@Test
	def void testEmpty() {
		val o = OptionalBoolean.empty
		o.assertInstanceOf(EmptyOptional)
	}

	////////////
	// ofTrue //
	////////////

	@Test
	def void testOfTrue() {
		val o = OptionalBoolean.ofTrue
		o.assertInstanceOf(TrueOptional)
	}

	////////////
	// ofFalse //
	////////////

	@Test
	def void testOfFalse() {
		val o = OptionalBoolean.ofFalse
		o.assertInstanceOf(FalseOptional)
	}

	////////
	// of //
	////////

	@Test
	def void testOfWithTrue() {
		val o = OptionalBoolean.of(true)
		o.assertInstanceOf(TrueOptional)
	}

	@Test
	def void testOfWithFalse() {
		val o = OptionalBoolean.of(false)
		o.assertInstanceOf(FalseOptional)
	}

	///////////////
	// isPresent //
	///////////////

	@Test
	def void testEmptyIsPresent() {
		val o = OptionalBoolean.empty
		o.isPresent.assertFalse()
	}

	@Test
	def void testTrueIsPresent() {
		val o = OptionalBoolean.ofTrue
		o.isPresent.assertTrue()
	}

	@Test
	def void testFalseIsPresent() {
		val o = OptionalBoolean.ofFalse
		o.isPresent.assertTrue()
	}

	/////////////
	// isEmpty //
	/////////////

	@Test
	def void testEmptyIsEmpty() {
		val o = OptionalBoolean.empty
		o.isEmpty.assertTrue()
	}

	@Test
	def void testTrueIsEmpty() {
		val o = OptionalBoolean.ofTrue
		o.isEmpty.assertFalse()
	}

	@Test
	def void testFalseIsEmpty() {
		val o = OptionalBoolean.ofFalse
		o.isEmpty.assertFalse()
	}

	////////////
	// isTrue //
	////////////

	@Test
	def void testEmptyIsTrue() {
		val o = OptionalBoolean.empty
		o.isTrue.assertFalse()
	}

	@Test
	def void testTrueIsTrue() {
		val o = OptionalBoolean.ofTrue
		o.isTrue.assertTrue()
	}

	@Test
	def void testFalseIsTrue() {
		val o = OptionalBoolean.ofFalse
		o.isTrue.assertFalse()
	}

	///////////////////
	// isTrueOrEmpty //
	///////////////////

	@Test
	def void testEmptyIsTrueOrEmpty() {
		val o = OptionalBoolean.empty
		o.isTrueOrEmpty.assertTrue()
	}

	@Test
	def void testTrueIsTrueOrEmpty() {
		val o = OptionalBoolean.ofTrue
		o.isTrueOrEmpty.assertTrue()
	}

	@Test
	def void testFalseIsTrueOrEmpty() {
		val o = OptionalBoolean.ofFalse
		o.isTrueOrEmpty.assertFalse()
	}

	/////////////
	// isFalse //
	/////////////

	@Test
	def void testEmptyIsFalse() {
		val o = OptionalBoolean.empty
		o.isFalse.assertFalse()
	}

	@Test
	def void testTrueIsFalse() {
		val o = OptionalBoolean.ofTrue
		o.isFalse.assertFalse()
	}

	@Test
	def void testFalseIsFalse() {
		val o = OptionalBoolean.ofFalse
		o.isFalse.assertTrue()
	}

	///////////////////
	// isFalseOrEmpty //
	///////////////////

	@Test
	def void testEmptyIsFalseOrEmpty() {
		val o = OptionalBoolean.empty
		o.isFalseOrEmpty.assertTrue()
	}

	@Test
	def void testTrueIsFalseOrEmpty() {
		val o = OptionalBoolean.ofTrue
		o.isFalseOrEmpty.assertFalse()
	}

	@Test
	def void testFalseIsFalseOrEmpty() {
		val o = OptionalBoolean.ofFalse
		o.isFalseOrEmpty.assertTrue()
	}

	////////////
	// ifTrue //
	////////////

	@Test
	def void testEmptyIfTrue() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.empty
		o.ifTrue[ result = false; throw new IllegalStateException ]
		result.assertTrue()
	}

	@Test
	def void testTrueIfTrue() {
		extension val test = new Object() {
			var result = false
		}
		val o = OptionalBoolean.ofTrue
		o.ifTrue [
			result = true
		]
		result.assertTrue()
	}

	@Test
	def void testFalseIfTrue() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.ofFalse
		o.ifTrue[ result = false; throw new IllegalStateException ]
		result.assertTrue()
	}

	@Test(expected = NullPointerException)
	def void testFalseIfTrueActionNull() {
		val o = OptionalBoolean.ofFalse
		o.ifTrue(null)
	}

	/////////////
	// ifFalse //
	/////////////

	@Test
	def void testEmptyIfFalse() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.empty
		o.ifFalse[ result = false; throw new IllegalStateException ]
		result.assertTrue()
	}

	@Test
	def void testTrueIfFalse() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.ofTrue
		o.ifFalse [
			result = false
			throw new IllegalStateException 
		]
		result.assertTrue()
	}

	@Test
	def void testFalseIfFalse() {
		extension val test = new Object() {
			var result = false
		}
		val o = OptionalBoolean.ofFalse
		o.ifFalse[ result = true ]
		result.assertTrue()
	}

	@Test(expected = NullPointerException)
	def void testTrueIfFalseActionNull() {
		val o = OptionalBoolean.ofTrue
		o.ifFalse(null)
	}

	///////////////////
	// ifTrueOrEmpty //
	///////////////////

	@Test
	def void testEmptyIfTrueOrEmpty() {
		extension val test = new Object() {
			var result = false
		}
		val o = OptionalBoolean.empty
		o.ifTrueOrEmpty[ 
			result = true
		]
		result.assertTrue()
	}

	@Test
	def void testTrueIfTrueOrEmpty() {
		extension val test = new Object() {
			var result = false
		}
		val o = OptionalBoolean.ofTrue
		o.ifTrueOrEmpty [
			result = true
		]
		result.assertTrue()
	}

	@Test
	def void testFalseIfTrueOrEmpty() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.ofFalse
		o.ifTrueOrEmpty [
			result = false
			throw new IllegalStateException
		]
		result.assertTrue()
	}

	@Test(expected = NullPointerException)
	def void testFalseIfTrueOrEmptyActionNull() {
		val o = OptionalBoolean.ofFalse
		o.ifTrueOrEmpty(null)
	}

	////////////////////
	// ifFalseOrEmpty //
	////////////////////

	@Test
	def void testEmptyIfFalseOrEmpty() {
		extension val test = new Object() {
			var result = false
		}
		val o = OptionalBoolean.empty
		o.ifFalseOrEmpty[ 
			result = true
		]
		result.assertTrue()
	}

	@Test
	def void testTrueIfFalseOrEmpty() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.ofTrue
		o.ifFalseOrEmpty [
			result = false
			throw new IllegalStateException 
		]
		result.assertTrue()
	}

	@Test
	def void testFalseIfFalseOrEmpty() {
		extension val test = new Object() {
			var result = false
		}
		val o = OptionalBoolean.ofFalse
		o.ifFalseOrEmpty[ result = true ]
		result.assertTrue()
	}

	@Test(expected = NullPointerException)
	def void testTrueIfFalsOrEmptyeActionNull() {
		val o = OptionalBoolean.ofTrue
		o.ifFalseOrEmpty(null)
	}

	///////////////
	// ifPresent //
	///////////////

	@Test
	def void testEmptyIfPresent() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.empty
		o.ifPresent[
			result = false
			throw new IllegalStateException 
		]
		result.assertTrue()
	}

	@Test
	def void testTrueIfPresent() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.ofTrue
		o.ifPresent [
			result = it
		]
		result.assertTrue()
	}

	@Test
	def void testFalseIfPresent() {
		extension val test = new Object() {
			var result = false
		}
		val o = OptionalBoolean.ofFalse
		o.ifPresent [ 
			result = !it
		]
		result.assertTrue()
	}

	@Test(expected = NullPointerException)
	def void testEmptyIfPresentConsumerNull() {
		val o = OptionalBoolean.empty
		o.ifPresent(null)
	}

	/////////////////////
	// ifPresentOrElse //
	/////////////////////

	@Test
	def void testEmptyIfPresentOrElse() {
		extension val test = new Object() {
			var presentResult = true
		}
		extension val test2 = new Object() {
			var elseResult = false
		}
		val o = OptionalBoolean.empty
		o.ifPresentOrElse([
			presentResult = false
			throw new IllegalStateException 
		],[
			elseResult = true
		])
		presentResult.assertTrue()
		elseResult.assertTrue()
	}

	@Test
	def void testTrueIfPresentOrElse() {
		extension val test = new Object() {
			var presentResult = true
		}
		extension val test2 = new Object() {
			var elseResult = true
		}
		val o = OptionalBoolean.ofTrue
		o.ifPresentOrElse([
			presentResult = it
		], [
			elseResult = false
		])
		presentResult.assertTrue()
		elseResult.assertTrue()
	}

	@Test
	def void testFalseIfPresentOrElse() {
		extension val test = new Object() {
			var presentResult = true
		}
		extension val test2 = new Object() {
			var elseResult = true
		}
		val o = OptionalBoolean.ofFalse
		o.ifPresentOrElse([ 
			presentResult = !it
		],[
			elseResult = false
		])
		presentResult.assertTrue()
		elseResult.assertTrue()
	}

	@Test(expected = NullPointerException)
	def void testEmptyIfPresentOrElsePresentConsumerNull() {
		val o = OptionalBoolean.empty
		o.ifPresentOrElse(null,[
			throw new IllegalStateException
		])
	}

	@Test(expected = NullPointerException)
	def void testEmptyIfPresentOrElseElseConsumerNull() {
		val o = OptionalBoolean.ofTrue
		o.ifPresentOrElse([
			throw new IllegalStateException
		],null)
	}

	////////////
	// orElse //
	////////////

	@Test
	def void testEmptyOrElse() {
		val o = OptionalBoolean.empty
		val expected = true
		val actual = o.orElse(expected)
		expected.assertEquals(actual)
	}

	@Test
	def void testTrueOrElse() {
		val o = OptionalBoolean.ofTrue
		val other = false
		val actual = o.orElse(other)
		true.assertEquals(actual)
	}

	@Test
	def void testFalseOrElse() {
		val o = OptionalBoolean.ofFalse
		val other = true
		val actual = o.orElse(other)
		false.assertEquals(actual)
	}

	///////////////
	// orElseGet //
	///////////////

	@Test
	def void testEmptyOrElseGet() {
		extension val test = new Object() {
			var result = false
		}
		val o = OptionalBoolean.empty
		val expected = true
		val actual = o.orElseGet [
			result = true
			expected
		]
		result.assertTrue
		expected.assertEquals(actual)
	}

	@Test
	def void testTrueOrElseGet() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.ofTrue
		val actual = o.orElseGet [
			result = false 
			throw new IllegalStateException
		]
		true.assertEquals(actual)
		result.assertTrue
	}

	@Test
	def void testFalseOrElseGet() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.ofFalse
		val actual = o.orElseGet [
			result = false
			throw new IllegalStateException
		]
		false.assertEquals(actual)
		result.assertTrue
	}

	@Test(expected = NullPointerException)
	def void testFalseOrElseGetNullLambda() {
		val o = OptionalBoolean.ofFalse
		o.orElseGet(null)
	}

	/////////////////
	// orElseThorw //
	/////////////////

	private static class MyException extends Exception {}
	
	@Test(expected = MyException)
	def void testEmptyOrElseThrow() {
		val o = OptionalBoolean.empty
		o.orElseThrow [
			new MyException
		]
	}

	@Test
	def void testTrueOrElseThrow() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.ofTrue
		val actual = o.orElseThrow [
			result = false 
			throw new MyException
		]
		true.assertEquals(actual)
		result.assertTrue
	}

	@Test
	def void testFalseOrElseThrow() {
		extension val test = new Object() {
			var result = true
		}
		val o = OptionalBoolean.ofFalse
		val actual = o.orElseThrow [
			result = false
			throw new MyException
		]
		false.assertEquals(actual)
		result.assertTrue
	}

	@Test(expected = NullPointerException)
	def void testFalseOrElseThrowNullLambda() {
		val o = OptionalBoolean.ofFalse
		o.orElseThrow(null)
	}

	/////////////////
	// getNullable //
	/////////////////
	
	@Test
	def void testGetNullableEmpty() {
		val o = OptionalBoolean.empty
		o.nullable.assertNull
	}
	
	@Test
	def void testGetNullableTrue() {
		val o = OptionalBoolean.ofTrue
		o.nullable.assertEquals(Boolean.TRUE)
	}
	
	@Test
	def void testGetNullableFalse() {
		val o = OptionalBoolean.ofFalse
		o.nullable.assertEquals(Boolean.FALSE)
	}

	///////////
	// boxed //
	///////////
	
	@Test
	def void testBoxedEmpty() {
		val o = OptionalBoolean.empty
		o.boxed.isPresent.assertFalse
	}
	
	@Test
	def void testBoxedTrue() {
		val o = OptionalBoolean.ofTrue
		o.boxed.get.assertEquals(Boolean.TRUE)
	}
	
	@Test
	def void testBoxedFalse() {
		val o = OptionalBoolean.ofFalse
		o.boxed.get.assertEquals(Boolean.FALSE)
	}

	//////////
	// util //
	//////////	
	
	private def assertInstanceOf(Object o, Class<?> clazz) {
		if(!clazz.isInstance(o)) {
			fail('''Object expected to be instance of «clazz.name» but is of type «o.class.name»''')
		}
	}

}