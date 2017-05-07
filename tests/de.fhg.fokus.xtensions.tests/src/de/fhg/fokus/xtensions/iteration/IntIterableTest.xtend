package de.fhg.fokus.xtensions.iteration

import org.junit.Test
import de.fhg.fokus.xtensions.iteration.IntIterable
import static org.junit.Assert.*
import java.util.concurrent.atomic.AtomicInteger
import static de.fhg.fokus.xtensions.Util.*
import java.util.function.IntConsumer

class IntIterableTest {
	
	/////////////
	// generate //
	/////////////
	
	private static class MyException extends Exception{}
	
	@Test(timeout = 100) def void generateIterator() {
		val IntIterable ints = IntIterable.generate [
			val int[] i = #[0]
			[
				val result = i.get(0)
				i.set(0,result+1)
				result
			]
		]
		// iterator is infinite, so we limit to 100 elements
		val iter = ints.iterator
		for(var i = 0; i< 100; i++) {
			assertTrue(iter.hasNext)
			assertEquals(i, iter.nextInt)
		}
		
		// try starting over with new iterator
		val iter2 = ints.iterator
		for(var i = 0; i< 100; i++) {
			assertTrue(iter2.hasNext)
			assertEquals(i, iter2.nextInt)
		}
		
		val iter3 = ints.iterator
		val ai = new AtomicInteger(0)
		val IntConsumer action = [int it|
			val i = ai.getAndIncrement
			if(i == 100) throw new MyException
			assertEquals(i, it)
		]
		expectException(MyException) [
			iter3.forEachRemaining(action)
		]
	}
	
	@Test(expected = MyException, timeout = 1000) def void generateIteratorForEach() {
		val IntIterable ints = IntIterable.generate [
			val int[] i = #[0]
			[
				val result = i.get(0)
				i.set(0,result+1)
				result
			]
		]
		val AtomicInteger ai = new AtomicInteger(-1)
		ints.forEachInt [
			val expected = ai.incrementAndGet
			assertEquals(expected, it)
			if(it > 100) {
				throw new MyException()
			}
		]
		fail()
	}
	
	@Test (timeout = 1000) def void generatForEach() {
		val IntIterable ints = IntIterable.generate [
			val int[] i = #[0]
			[
				val result = i.get(0)
				i.set(0,result+1)
				result
			]
		]
		val AtomicInteger ai = new AtomicInteger(-1)
		expectException(MyException) [
			ints.forEachInt [
				val expected = ai.incrementAndGet
				assertEquals(expected, it)
				if(it > 100) {
					throw new MyException()
				}
			]
		]
		// try again, iterable should start over
		val AtomicInteger ai2 = new AtomicInteger(-1)
		expectException(MyException) [
			ints.forEachInt [
				val expected = ai2.incrementAndGet
				assertEquals(expected, it)
				if(it > 100) {
					throw new MyException()
				}
			]
		]
	}
	
	@Test def void generateStream() {
		val IntIterable ints = IntIterable.generate [
			val int[] i = #[0]
			[
				val result = i.get(0)
				i.set(0,result+1)
				2 * result
			]
		]
		// stream is infinite, so we limit to 100 elements
		val intsArr = ints.stream.limit(100).toArray
		assertEquals(100, intsArr.length)
		for(var i = 0; i< 100; i++) {
			assertEquals(2 * i, intsArr.get(i))
		}
		
		// try starting over with new iterator
		val intsArr2 = ints.stream.limit(100).toArray
		assertEquals(100, intsArr2.length)
		for(var i = 0; i< 100; i++) {
			assertEquals(2 * i, intsArr2.get(i))
		}
	}
	
	/////////////
	// iterate //
	/////////////
	
	@Test def void testIterateIterator() {
		val IntIterable ints = IntIterable.iterate(0) [
			it + 1
		]
		
		// iterator is infinite, so we limit to 100 elements
		val iter = ints.iterator
		for(var i = 0; i< 100; i++) {
			assertTrue(iter.hasNext)
			assertEquals(i, iter.nextInt)
		}
		
		// try starting over with new iterator
		val iter2 = ints.iterator
		for(var i = 0; i< 100; i++) {
			assertTrue(iter2.hasNext)
			assertEquals(i, iter2.nextInt)
		}
		
		val iter3 = ints.iterator
		val ai = new AtomicInteger(0)
		val IntConsumer action = [int it|
			val i = ai.getAndIncrement
			if(i == 100) throw new MyException
			assertEquals(i, it)
		]
		expectException(MyException) [
			iter3.forEachRemaining(action)
		]
	}
	
	@Test(expected = MyException, timeout = 1000) def void testIterateIteratorForEach() {
		val IntIterable ints = IntIterable.iterate(0) [
			it + 1
		]
		val AtomicInteger ai = new AtomicInteger(-1)
		ints.forEachInt [
			val expected = ai.incrementAndGet
			assertEquals(expected, it)
			if(it > 100) {
				throw new MyException()
			}
		]
		fail()
	}
	
	@Test (timeout = 1000) def void testIterateForEach() {
		val IntIterable ints = IntIterable.iterate(0) [
			it + 1
		]
		val AtomicInteger ai = new AtomicInteger(-1)
		expectException(MyException) [
			ints.forEachInt [
				val expected = ai.incrementAndGet
				assertEquals(expected, it)
				if(it > 100) {
					throw new MyException()
				}
			]
		]
		// try again, iterable should start over
		val AtomicInteger ai2 = new AtomicInteger(-1)
		expectException(MyException) [
			ints.forEachInt [
				val expected = ai2.incrementAndGet
				assertEquals(expected, it)
				if(it > 100) {
					throw new MyException()
				}
			]
		]
	}
	
	@Test def void testIterateStream() {
		val IntIterable ints = IntIterable.iterate(0) [
			it + 2
		]
		// stream is infinite, so we limit to 100 elements
		val intsArr = ints.stream.limit(100).toArray
		assertEquals(100, intsArr.length)
		for(var i = 0; i< 100; i+=2) {
			assertEquals(2 * i, intsArr.get(i))
		}
		
		// try starting over with new iterator
		val intsArr2 = ints.stream.limit(100).toArray
		assertEquals(100, intsArr2.length)
		for(var i = 0; i< 100; i+=2) {
			assertEquals(2 * i, intsArr2.get(i))
		}
	}
}