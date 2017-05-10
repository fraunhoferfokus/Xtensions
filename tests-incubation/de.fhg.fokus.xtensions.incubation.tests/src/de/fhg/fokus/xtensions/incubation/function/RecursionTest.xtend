package de.fhg.fokus.xtensions.incubation.function

import org.junit.Test

import static de.fhg.fokus.xtensions.incubation.function.Recursion.*
import static extension de.fhg.fokus.xtensions.function.FunctionExtensions.*
import static org.junit.Assert.*
import java.util.OptionalInt
import java.util.List

class RecursionTest {
	
	
	@Test def void testSimpleRecursive2() {
		val harmonic = [int i | 
			recursive [it, double acc, int curr|
				if(curr < i) {
					val next = curr + 1
					it.apply(acc + (1.0d/next), next)
				} else {
					acc
				}
			].apply(1.0d, 1)
		]
		val result = harmonic.apply(4)
		assertEquals(2.0833d, result, 0.0001d)
	}
	
	@Test def void testSimpleRecursive3() {
		val harmonic = [int i | 
			recursive [it, double acc, int curr, int target|
				if(curr < target) {
					val next = curr + 1
					it.apply(acc + (1.0d/next), next, target)
				} else {
					acc
				}
			].apply(1.0d, 1, i)
		]
		val result = harmonic.apply(4)
		assertEquals(2.0833d, result, 0.0001d)
	}
	
	@Test def testRecursive1() {
		val r = recursive [it, int n|
			if(n == 0)
				1
			else
				n * apply(n-1)
		].apply(7)
		
		assertEquals(5040, r)
	}
	
	@Test def void testTailRecursive2() {
		val harmonic = [int i | 
			tailrec [it, double acc, int curr|
				if(curr < i) {
					val next = curr + 1
					apply(acc + (1.0d/next), next)
				} else {
					result(acc)
				}
			].apply(1.0d, 1)
		]
		val result = harmonic.apply(4)
		assertEquals(2.0833d, result, 0.0001d)
	}
	
	
	def sample() {
		val nums = #[1,10,3,100,7] 
		val max = nums >>> [
			if(it.size == 0) {
				return OptionalInt.empty
			}
			val maxFunc = tailrec [it,List<Integer> list, int index, int curMax|
				if(list.size == index) 
					result(curMax)
				else {
					val newMax = Math.max(curMax,list.get(index))
					apply(list, index+1, newMax)
				}
			]
			maxFunc.apply(it, 0 , Integer.MIN_VALUE) >>> [OptionalInt.of(it)]
		]
		print(max)
	}
}
