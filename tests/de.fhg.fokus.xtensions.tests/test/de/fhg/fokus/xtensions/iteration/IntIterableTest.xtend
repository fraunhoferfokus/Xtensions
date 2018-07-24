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
package de.fhg.fokus.xtensions.iteration

import org.junit.Test
import de.fhg.fokus.xtensions.iteration.IntIterable
import static org.junit.Assert.*
import java.util.concurrent.atomic.AtomicInteger
import static de.fhg.fokus.xtensions.Util.*
import java.util.function.IntConsumer
import de.fhg.fokus.xtensions.Util

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
	
	///////////////////////////
	// iterate end condition //
	///////////////////////////
	
	@Test def void testIterateEndIterator() {
		val IntIterable ints = IntIterable.iterate(0, [it<10], [it + 1])
		
		// iterator is infinite, so we limit to 100 elements
		val iter = ints.iterator
		for(var i = 0; i< 10; i++) {
			assertTrue(iter.hasNext)
			assertEquals(i, iter.nextInt)
		}
		Util.assertEmptyIntIterator(iter)
		
		// try starting over with new iterator
		val iter2 = ints.iterator
		for(var i = 0; i< 10; i++) {
			assertTrue(iter2.hasNext)
			assertEquals(i, iter2.nextInt)
		}
		Util.assertEmptyIntIterator(iter)
		
		val iter3 = ints.iterator
		// since we incrementAndGet we start with -1a
		val ai = new AtomicInteger(-1)
		val IntConsumer action = [int it|
			val i = ai.incrementAndGet
			assertEquals(i, it)
		]
		iter3.forEachRemaining(action)
		assertEquals(9, ai.get)
		Util.assertEmptyIntIterator(iter3)
	}
	
	@Test def void testIterateEndEmptyIterator() {
		val IntIterable ints = IntIterable.iterate(0, [false], [throw new Exception])
		Util.assertEmptyIntIterator(ints.iterator)
	}
	
	@Test(timeout = 1000) def void generateIteratorEndForEach() {
		val IntIterable ints = IntIterable.iterate(1, [it < 17], [it * 2])
		val AtomicInteger ai = new AtomicInteger(1)
		ints.forEachInt [
			val expected = ai.get
			assertEquals(expected, it)
			// set next expected value
			ai.set(expected * 2)
		]
		assertEquals(32, ai.get)
	}
	
	@Test(timeout = 1000) def void generateIteratorEndForEachEmpty() {
		val IntIterable ints = IntIterable.iterate(0, [false], [throw new Exception])
		ints.forEachInt [
			fail()
		]
	}
}