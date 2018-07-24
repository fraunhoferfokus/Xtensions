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
import java.util.function.DoubleConsumer
import de.fhg.fokus.xtensions.Util
import java.util.concurrent.atomic.AtomicLong

class DoubleIterableTest {
	
	/////////////
	// generate //
	/////////////
	
	private static class MyException extends Exception{}
	
	@Test(timeout = 1000) def void generateIterator() {
		val DoubleIterable doubles = DoubleIterable.generate [
			val double[] d = #[0.0d]
			[
				val result = d.get(0)
				d.set(0,result + 1.0d)
				result
			]
		]
		// iterator is infinite, so we limit to 100 elements
		val iter = doubles.iterator
		for(var i = 0; i< 100; i++) {
			assertTrue(iter.hasNext)
			assertEquals(i, iter.nextDouble, 0.0d)
		}
		
		// try starting over with new iterator
		val iter2 = doubles.iterator
		for(var i = 0; i< 100; i++) {
			assertTrue(iter2.hasNext)
			assertEquals(i, iter2.nextDouble, 0.0d)
		}
		
		val iter3 = doubles.iterator
		val ai = new AtomicLong(0)
		val DoubleConsumer action = [double it|
			val d = ai.getAndIncrement
			if(d == 100) throw new MyException
			assertEquals(d, it, 0.0d)
		]
		expectException(MyException) [
			iter3.forEachRemaining(action)
		]
	}
	
	@Test(expected = MyException, timeout = 1000) def void generateIteratorForEach() {
		val DoubleIterable longs = DoubleIterable.generate [
			val double[] d = #[0]
			[
				val result = d.get(0)
				d.set(0,result+1)
				result
			]
		]
		val AtomicLong al = new AtomicLong(-1)
		longs.forEachDouble [
			val expected = al.incrementAndGet
			assertEquals(expected, it, 0.0d)
			if(it > 100) {
				throw new MyException()
			}
		]
		fail()
	}
	
	@Test (timeout = 1000) def void generatForEach() {
		val DoubleIterable doubles = DoubleIterable.generate [
			val double[] d = #[0]
			[
				val result = d.get(0)
				d.set(0,result+1)
				result
			]
		]
		val AtomicLong ai = new AtomicLong(-1)
		expectException(MyException) [
			doubles.forEachDouble [
				val expected = ai.incrementAndGet
				assertEquals(expected, it, 0.0d)
				if(it > 100) {
					throw new MyException()
				}
			]
		]
		// try again, iterable should start over
		val AtomicLong ai2 = new AtomicLong(-1)
		expectException(MyException) [
			doubles.forEachDouble [
				val expected = ai2.incrementAndGet
				assertEquals(expected, it, 0.0d)
				if(it > 100) {
					throw new MyException()
				}
			]
		]
	}
	
	@Test def void generateStream() {
		val DoubleIterable longs = DoubleIterable.generate [
			val double[] d = #[0]
			[
				val result = d.get(0)
				d.set(0,result+1)
				2 * result
			]
		]
		// stream is infinite, so we limit to 100 elements
		val longsArr = longs.stream.limit(100).toArray
		assertEquals(100, longsArr.length)
		for(var i = 0; i< 100; i++) {
			assertEquals(2 * i, longsArr.get(i), 0.0d)
		}
		
		// try starting over with new iterator
		val longsArr2 = longs.stream.limit(100).toArray
		assertEquals(100, longsArr2.length)
		for(var i = 0; i< 100; i++) {
			assertEquals(2 * i, longsArr2.get(i), 0.0d)
		}
	}
	
		
	/////////////
	// iterate //
	/////////////
	
	@Test def void testIterateIterator() {
		val DoubleIterable longs = DoubleIterable.iterate(0L) [
			it + 1
		]
		
		// iterator is infinite, so we limit to 100 elements
		val iter = longs.iterator
		for(var i = 0L; i< 100L; i++) {
			assertTrue(iter.hasNext)
			assertEquals(i, iter.nextDouble, 0.0d)
		}
		
		// try starting over with new iterator
		val iter2 = longs.iterator
		for(var i = 0L; i< 100L; i++) {
			assertTrue(iter2.hasNext)
			assertEquals(i, iter2.nextDouble, 0.0d)
		}
		
		val iter3 = longs.iterator
		val ai = new AtomicLong(0)
		val DoubleConsumer action = [double it|
			val i = ai.getAndIncrement
			if(i == 100) throw new MyException
			assertEquals(i, it, 0.0d)
		]
		expectException(MyException) [
			iter3.forEachRemaining(action)
		]
	}
	
	@Test(expected = MyException, timeout = 1000) def void testIterateIteratorForEach() {
		val IntIterable doubles = IntIterable.iterate(0) [
			it + 1
		]
		val AtomicLong al = new AtomicLong(-1L)
		doubles.forEachInt [
			val expected = al.incrementAndGet
			assertEquals(expected, it)
			if(it > 100L) {
				throw new MyException()
			}
		]
		fail()
	}
	
	@Test (timeout = 1000) def void testIterateForEach() {
		val IntIterable doubles = IntIterable.iterate(0) [
			it + 1
		]
		val AtomicLong ai = new AtomicLong(-1L)
		expectException(MyException) [
			doubles.forEachInt [
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
			doubles.forEachInt [
				val expected = al2.incrementAndGet
				assertEquals(expected, it)
				if(it > 100L) {
					throw new MyException()
				}
			]
		]
	}
	
	@Test def void testIterateStream() {
		val DoubleIterable longs = DoubleIterable.iterate(0L) [
			it + 2L
		]
		// stream is infinite, so we limit to 100 elements
		val doublesArr = longs.stream.limit(100).toArray
		assertEquals(100, doublesArr.length)
		for(var i = 0; i< 100; i+=2) {
			assertEquals(2 * i as double, doublesArr.get(i), 0.0d)
		}
		
		// try starting over with new iterator
		val doublesArr2 = longs.stream.limit(100).toArray
		assertEquals(100, doublesArr2.length)
		for(var i = 0; i< 100; i+=2) {
			assertEquals(2 * i as double , doublesArr2.get(i), 0.0d)
		}
	}
	
	///////////////////////////
	// iterate end condition //
	///////////////////////////
	
	@Test def void testIterateEndIterator() {
		val DoubleIterable doubles = DoubleIterable.iterate(0L, [it<10L], [it + 1L])
		
		// iterator is infinite, so we limit to 100 elements
		val iter = doubles.iterator
		for(var i = 0; i< 10; i++) {
			assertTrue(iter.hasNext)
			assertEquals(i, iter.nextDouble, 0.0d)
		}
		Util.assertEmptyDoubleIterator(iter)
		
		// try starting over with new iterator
		val iter2 = doubles.iterator
		for(var i = 0; i< 10; i++) {
			assertTrue(iter2.hasNext)
			assertEquals(i as double, iter2.nextDouble, 0.0d)
		}
		Util.assertEmptyDoubleIterator(iter)
		
		val iter3 = doubles.iterator
		// since we incrementAndGet we start with -1a
		val ai = new AtomicLong(-1L)
		val DoubleConsumer action = [double it|
			val i = ai.incrementAndGet
			assertEquals(i as double , it, 0.0d)
		]
		iter3.forEachRemaining(action)
		assertEquals(9, ai.get)
		Util.assertEmptyDoubleIterator(iter3)
	}
	
	@Test def void testIterateEndEmptyIterator() {
		val DoubleIterable longs = DoubleIterable.iterate(0, [false], [throw new Exception])
		Util.assertEmptyDoubleIterator(longs.iterator)
	}
	
	@Test(timeout = 1000) def void generateIteratorEndForEach() {
		val DoubleIterable longs = DoubleIterable.iterate(1L, [it < 17L], [it * 2])
		val AtomicLong al = new AtomicLong(1L)
		longs.forEachDouble [
			val expected = al.get
			assertEquals(expected as double, it, 0.0d)
			// set next expected value
			al.set(expected * 2)
		]
		assertEquals(32L, al.get)
	}
	
	@Test(timeout = 1000) def void generateIteratorEndForEachEmpty() {
		val DoubleIterable longs = DoubleIterable.iterate(0L, [false], [throw new Exception])
		longs.forEachDouble [
			fail()
		]
	}
}
