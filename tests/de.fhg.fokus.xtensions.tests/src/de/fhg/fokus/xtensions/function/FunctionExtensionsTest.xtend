package de.fhg.fokus.xtensions.function

import org.junit.Test

import static org.junit.Assert.*

import static extension com.google.common.base.Strings.*
import static extension de.fhg.fokus.xtensions.function.FunctionExtensions.*

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
	
	
	@Test def void testAndThen() {
		val result = [|2].andThen[it*2].apply
		assertEquals(4,result)
	}
	
	// TODO test >> operator
	// TODO test << operator
	// TODO test and, or, negate
	
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