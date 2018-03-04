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
package de.fhg.fokus.xtensions.function

import org.junit.Test

import static org.junit.Assert.*

import static extension com.google.common.base.Strings.*
import static extension de.fhg.fokus.xtensions.function.FunctionExtensions.*
import java.util.concurrent.atomic.AtomicBoolean

class FunctionExtensionsTest {
	
	@Test def testPipe() {
		val chained = " foo " >>> [if(nullOrEmpty) "" else toUpperCase] >>> [trim]
		assertEquals("FOO", chained)
	}
	
	
	@Test(expected = NullPointerException) def void testPipeNull() {
		null >>> [String it|trim]
	}
	
	
	@Test(expected = NullPointerException) def void testPipeToNull() {
		val (String)=>String fun = null
		"foo" >>> fun
	}
	
	@Test def testTuplePipe() {
		val result = ("foo" -> "bar") >>> [a, b|a + b]
		assertEquals("foobar", result)
	}
	
	@Test(expected = NullPointerException) def void testTuplePipeToNull() {
		val (String,String)=>String op = null
		("foo" -> "bar") >>> op
	}
	
	@Test(expected = NullPointerException) def void testTuplePipeNull() {
		val Pair<String,String> p = null
		p >>> [a, b|a + b]
	}
	
	//////////////////////////
	// andThen(=>R, (R)=>V) //
	//////////////////////////
	
	@Test def void testAndThen() {
		val result = [|2].andThen[it*2].apply
		assertEquals(4,result)
	}
	
	@Test(expected = NullPointerException) def void testAndThenFirstNull() {
		val =>Integer first = null
		first.andThen[it*2].apply
	}
	
	@Test(expected = NullPointerException) def void testAndThenSecondNull() {
		val (Integer)=>Integer second = null
		[|2].andThen(second).apply
	}
	
	/////////////////
	// >> operator //
	/////////////////
	
	@Test def void testConcat() {
		val (int)=>int func = [int it|it*2] >> [it + 1]
		val result = func.apply(2)
		assertEquals(5, result)
	}
	
	@Test(expected = NullPointerException) def void testConcatFirstNull() {
		val (Integer)=>Integer first = null
		val foo = first >> [it + 1]
	}
	
	@Test(expected = NullPointerException) def void testConcatSecondNull() {
		val (Integer)=>Integer second = null
		val foo = [int i|i + 1] >> second
	}
	
	/////////////////
	// << operator //
	/////////////////
	
	@Test def void testCompose() {
		val (int)=>int func = [int it|it*2] << [it + 1]
		assertEquals(6, func.apply(2))
	}
	
	@Test(expected = NullPointerException) def void testFirstNull() {
		val (int)=>int func = null << [it + 1]
	}
	
	@Test(expected = NullPointerException) def void testSecondNull() {
		val (int)=>int func = [int it|it*2] << null
	}
	
	
	/////////
	// and //
	/////////
	
	@Test def void testAndFirstFalse() {
		val ai = new AtomicBoolean(false)
		val (String)=>Boolean test = [String s|
			ai.set(true)
			false
		].and[fail() false]
		val result = test.apply("fo")
		assertFalse(result)
		assertTrue(ai.get)
	}
	
	
	@Test def void testAndSecondFalse() {
		val a1 = new AtomicBoolean(false)
		val a2 = new AtomicBoolean(false)
		val (String)=>Boolean test = [String s|
			a1.set(true)
			true
		].and[
			a2.set(true)
			false
		]
		val result = test.apply("fo")
		assertFalse(result)
		assertTrue(a1.get)
		assertTrue(a2.get)
	}
	
	
	@Test def void testAndBothTrue() {
		val a1 = new AtomicBoolean(false)
		val a2 = new AtomicBoolean(false)
		val (String)=>Boolean test = [String s|
			a1.set(true)
			true
		].and[
			a2.set(true)
			true
		]
		val result = test.apply("fo")
		assertTrue(result)
		assertTrue(a1.get)
		assertTrue(a2.get)
	}
	
	////////
	// or //
	////////
	
	@Test def void testOrFirstTrue() {
		val ab = new AtomicBoolean(false)
		val (String)=>Boolean test = [String s|
			ab.set(true)
			true
		].or[
			fail()
			false
		]
		val result = test.apply("shoo")
		assertTrue(result)
		assertTrue(ab.get)
	}
	
	@Test def void testOrFirstFalseSecondTrue() {
		val a1 = new AtomicBoolean(false)
		val a2 = new AtomicBoolean(false)
		val (String)=>Boolean test = [String s|
			a1.set(true)
			false
		].or[
			a2.set(true)
			true
		]
		val result = test.apply("shoo")
		assertTrue(result)
		assertTrue(a1.get)
		assertTrue(a2.get)
	}
	
	@Test def void testOrBothFalse() {
		val a1 = new AtomicBoolean(false)
		val a2 = new AtomicBoolean(false)
		val (String)=>Boolean test = [String s|
			a1.set(true)
			false
		].or[
			a2.set(true)
			false
		]
		val result = test.apply("shoo")
		assertFalse(result)
		assertTrue(a1.get)
		assertTrue(a2.get)
	}
	
	////////////
	// negate //
	////////////
	
	@Test def void testNegateOnFalse() {
		val ab = new AtomicBoolean(false)
		val toTrue = [ab.set(true);false].negate
		val result = toTrue.apply("")
		assertTrue(result)
		assertTrue(ab.get)
	}
	
	@Test def void testNegateOnTrue() {
		val ab = new AtomicBoolean(false)
		val toTrue = [ab.set(true);true].negate
		val result = toTrue.apply("")
		assertFalse(result)
		assertTrue(ab.get)
	}
	
//	def void sample() {
//		
//		MemorizationExtensions.mem(ATOMIC) [
//			
//		]
//		
//		var bar = getName() >>> safe [
//			if(length < 3)
//				padStart(3,' ')
//			else 
//				toLowerCase.trim.substring(0,3)
//		]
//		
//		val nums = #[1,10,3,100,7] 
//		
//		val sum = nums >>> safe [ 
//			if(size == 0) 
//				OptionalInt.empty 
//			else 
//				fold(0)[p1, p2| p1 + p2] >>> [OptionalInt.of(it)]
//		] ?: OptionalInt.empty
//		println(sum)
//		//...
//	}
//	
//	def abbr(String name) {
//		var String result = name
//		if(name !== null) {
//			
//		}
//		result
//	}
//	
//	def String getName() {
//		" fernando"
//	}
}