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
package de.fhg.fokus.xtensions.pair

import org.junit.Test
import static org.junit.Assert.*
import static extension de.fhg.fokus.xtensions.pair.PairExtensions.*
import java.util.concurrent.atomic.AtomicBoolean

class PairExtensionTests {
	
	/////////////
	// consume //
	/////////////
	
	@Test def void testConsume() {
		val expectedKey = "foo"
		val expectedVal = 3
		val tst = expectedKey -> expectedVal
		val called = new AtomicBoolean(false)
		tst => [k, v|
			assertEquals(expectedKey, k)
			assertEquals(expectedVal, v)
			called.set(true)
		]
		assertTrue(called.get)
	}
	
	@Test def void testConsumeKeyNull() {
		val String expectedKey = null
		val expectedVal = 3
		val tst = expectedKey -> expectedVal
		val called = new AtomicBoolean(false)
		tst => [k, v|
			assertEquals(expectedKey, k)
			assertEquals(expectedVal, v)
			called.set(true)
		]
		assertTrue(called.get)
	}
	
	@Test def void testConsumeValueNull() {
		val expectedKey = "foo"
		val Integer expectedVal = null
		val tst = expectedKey -> expectedVal
		val called = new AtomicBoolean(false)
		tst => [k, v|
			assertEquals(expectedKey, k)
			assertEquals(expectedVal, v)
			called.set(true)
		]
		assertTrue(called.get)
	}
	
//	//////////
//	// test //
//	//////////
//	
//	@Test def void testTestTrue() {
//		val result = ("foo" -> "bar").test[$0.length == $1.length]
//		assertTrue(result)
//	}
//	
//	@Test def void testTestFalse() {
//		val result = ("foo" -> "baar").test[$0.length == $1.length]
//		assertFalse(result)
//	}
	
	/////////////
	// combine //
	/////////////
	
	@Test def void testCombine() {
		val result = ("fizz" -> "buzz").combine[$0 + $1]
		assertEquals("fizzbuzz", result)
	}
	
	/////////////////
	// safeCombine //
	/////////////////
	
	@Test def void testSafeCombinePairNull() {
		val Pair<Integer,Integer> pair = null
		val result = pair.safeCombine[fail()0]
		assertFalse(result.present)
	}
	
	@Test def void testSafeCombineFirstNull() {
		val result = (null -> "buzz").safeCombine[fail() $0 + $1]
		assertFalse(result.present)
	}
	
	@Test def void testSafeCombineSecondNull() {
		val result = ("bar" -> null).safeCombine[fail() $0 + $1]
		assertFalse(result.present)
	}
	
	@Test def void testSafeCombineReturnNull() {
		val result = ("fizz" -> "buzz").safeCombine[null]
		assertFalse(result.present)
	}
	
	@Test def void testSafeCombine() {
		val result = ("fizz" -> "buzz").safeCombine[$0 + $1]
		assertEquals("fizzbuzz", result.get)
	}
	
	///////////////////
	// with operator //
	///////////////////
	
	@Test def void testWithOpBothPresent() {
		val a = "foo"
		val b = Integer.valueOf(42)
		val entered = new AtomicBoolean(false)
		
		(a -> b) => [x,y|
			assertSame(a,x)
			assertSame(b,y)
			entered.set(true)
		]
		assertTrue(entered.get)
	}
	
	@Test def void testWithOpFirstPresent() {
		val a = "foo"
		val b = null
		val entered = new AtomicBoolean(false)
		
		(a -> b) => [x,y|
			assertSame(a,x)
			assertNull(y)
			entered.set(true)
		]
		assertTrue(entered.get)
	}
	
	@Test def void testWithOpSecondPresent() {
		val a = null
		val b = Integer.valueOf(99)
		val entered = new AtomicBoolean(false)
		
		(a -> b) => [x,y|
			assertNull(x)
			assertSame(b,y)
			entered.set(true)
		]
		assertTrue(entered.get)
	}
	
	@Test def void testWithOpNonePresent() {
		val a = null
		val b = null
		val entered = new AtomicBoolean(false)
		
		(a -> b) => [x,y|
			assertNull(x)
			assertNull(y)
			entered.set(true)
		]
		assertTrue(entered.get)
	}
	
	@Test def void testWithReturningSelf() {
		val Pair<String,Integer> expected = "Foo" -> 3
		val result = expected => [k,v|]
		assertSame(expected,result)
	}
}