/*******************************************************************************
 * Copyright (c) 2017-2018 Max Bureck (Fraunhofer FOKUS) and others.
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
import static org.junit.Assert.*
import static de.fhg.fokus.xtensions.Util.*
import java.util.concurrent.atomic.AtomicLong
import java.util.function.LongConsumer
import de.fhg.fokus.xtensions.Util

class LongIterableTest {
	
	/////////////
	// generate //
	/////////////
	
	private static class MyException extends Exception{}
	
	@Test(timeout = 100) def void generateIterator() {
		val LongIterable ints = LongIterable.generate [
			val long[] i = #[0L]
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
			assertEquals(i, iter.nextLong)
		}
		
		// try starting over with new iterator
		val iter2 = ints.iterator
		for(var i = 0; i< 100; i++) {
			assertTrue(iter2.hasNext)
			assertEquals(i, iter2.nextLong)
		}
		
		val iter3 = ints.iterator
		val ai = new AtomicLong(0)
		val LongConsumer action = [long it|
			val l = ai.getAndIncrement
			if(l == 100) throw new MyException
			assertEquals(l, it)
		]
		expectException(MyException) [
			iter3.forEachRemaining(action)
		]
	}
	
	@Test(expected = MyException, timeout = 1000) def void generateIteratorForEach() {
		val LongIterable longs = LongIterable.generate [
			val int[] i = #[0]
			[
				val result = i.get(0)
				i.set(0,result+1)
				result
			]
		]
		val AtomicLong al = new AtomicLong(-1)
		longs.forEachLong [
			val expected = al.incrementAndGet
			assertEquals(expected, it)
			if(it > 100) {
				throw new MyException()
			}
		]
		fail()
	}
	
	@Test (timeout = 1000) def void generatForEach() {
		val LongIterable ints = LongIterable.generate [
			val int[] i = #[0]
			[
				val result = i.get(0)
				i.set(0,result+1)
				result
			]
		]
		val AtomicLong ai = new AtomicLong(-1)
		expectException(MyException) [
			ints.forEachLong [
				val expected = ai.incrementAndGet
				assertEquals(expected, it)
				if(it > 100) {
					throw new MyException()
				}
			]
		]
		// try again, iterable should start over
		val AtomicLong ai2 = new AtomicLong(-1)
		expectException(MyException) [
			ints.forEachLong [
				val expected = ai2.incrementAndGet
				assertEquals(expected, it)
				if(it > 100) {
					throw new MyException()
				}
			]
		]
	}
	
	@Test def void generateStream() {
		val LongIterable longs = LongIterable.generate [
			val int[] i = #[0]
			[
				val result = i.get(0)
				i.set(0,result+1)
				2 * result
			]
		]
		// stream is infinite, so we limit to 100 elements
		val longsArr = longs.stream.limit(100).toArray
		assertEquals(100, longsArr.length)
		for(var i = 0; i< 100; i++) {
			assertEquals(2 * i, longsArr.get(i))
		}
		
		// try starting over with new iterator
		val longsArr2 = longs.stream.limit(100).toArray
		assertEquals(100, longsArr2.length)
		for(var i = 0; i< 100; i++) {
			assertEquals(2 * i, longsArr2.get(i))
		}
	}
	
		
	/////////////
	// iterate //
	/////////////
	
	@Test def void testIterateIterator() {
		val LongIterable longs = LongIterable.iterate(0L) [
			it + 1
		]
		
		// iterator is infinite, so we limit to 100 elements
		val iter = longs.iterator
		for(var i = 0L; i< 100L; i++) {
			assertTrue(iter.hasNext)
			assertEquals(i, iter.nextLong)
		}
		
		// try starting over with new iterator
		val iter2 = longs.iterator
		for(var i = 0L; i< 100L; i++) {
			assertTrue(iter2.hasNext)
			assertEquals(i, iter2.nextLong)
		}
		
		val iter3 = longs.iterator
		val ai = new AtomicLong(0)
		val LongConsumer action = [long it|
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
		val AtomicLong al = new AtomicLong(-1L)
		ints.forEachInt [
			val expected = al.incrementAndGet
			assertEquals(expected, it)
			if(it > 100L) {
				throw new MyException()
			}
		]
		fail()
	}
	
	@Test (timeout = 1000) def void testIterateForEach() {
		val IntIterable ints = IntIterable.iterate(0) [
			it + 1
		]
		val AtomicLong ai = new AtomicLong(-1L)
		expectException(MyException) [
			ints.forEachInt [
				val expected = ai.incrementAndGet
				assertEquals(expected, it)
				if(it > 100L) {
					throw new MyException()
				}
			]
		]
		// try again, iterable should start over
		val AtomicLong al2 = new AtomicLong(-1L)
		expectException(MyException) [
			ints.forEachInt [
				val expected = al2.incrementAndGet
				assertEquals(expected, it)
				if(it > 100L) {
					throw new MyException()
				}
			]
		]
	}
	
	@Test def void testIterateStream() {
		val LongIterable longs = LongIterable.iterate(0L) [
			it + 2L
		]
		// stream is infinite, so we limit to 100 elements
		val intsArr = longs.stream.limit(100).toArray
		assertEquals(100, intsArr.length)
		for(var i = 0; i< 100; i+=2) {
			assertEquals(2 * i as long, intsArr.get(i))
		}
		
		// try starting over with new iterator
		val intsArr2 = longs.stream.limit(100).toArray
		assertEquals(100, intsArr2.length)
		for(var i = 0; i< 100; i+=2) {
			assertEquals(2 * i as long , intsArr2.get(i))
		}
	}
	
	///////////////////////////
	// iterate end condition //
	///////////////////////////
	
	@Test def void testIterateEndIterator() {
		val LongIterable ints = LongIterable.iterate(0L, [it<10L], [it + 1L])
		
		// iterator is infinite, so we limit to 100 elements
		val iter = ints.iterator
		for(var i = 0; i< 10; i++) {
			assertTrue(iter.hasNext)
			assertEquals(i, iter.nextLong)
		}
		Util.assertEmptyLongIterator(iter)
		
		// try starting over with new iterator
		val iter2 = ints.iterator
		for(var i = 0; i< 10; i++) {
			assertTrue(iter2.hasNext)
			assertEquals(i as long, iter2.nextLong)
		}
		Util.assertEmptyLongIterator(iter)
		
		val iter3 = ints.iterator
		// since we incrementAndGet we start with -1a
		val ai = new AtomicLong(-1L)
		val LongConsumer action = [long it|
			val i = ai.incrementAndGet
			assertEquals(i, it)
		]
		iter3.forEachRemaining(action)
		assertEquals(9, ai.get)
		Util.assertEmptyLongIterator(iter3)
	}
	
	@Test def void testIterateEndEmptyIterator() {
		val LongIterable longs = LongIterable.iterate(0, [false], [throw new Exception])
		Util.assertEmptyLongIterator(longs.iterator)
	}
	
	@Test(timeout = 1000) def void generateIteratorEndForEach() {
		val LongIterable longs = LongIterable.iterate(1L, [it < 17L], [it * 2])
		val AtomicLong al = new AtomicLong(1L)
		longs.forEachLong [
			val expected = al.get
			assertEquals(expected, it)
			// set next expected value
			al.set(expected * 2)
		]
		assertEquals(32L, al.get)
	}
	
	@Test(timeout = 1000) def void generateIteratorEndForEachEmpty() {
		val LongIterable longs = LongIterable.iterate(0L, [false], [throw new Exception])
		longs.forEachLong [
			fail()
		]
	}
}
