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
package de.fhg.fokus.xtensions.concurrent

import org.junit.Test
import static org.junit.Assert.*
import java.util.concurrent.TimeUnit
import static extension de.fhg.fokus.xtensions.concurrent.SchedulingUtil.*
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicBoolean
import de.fhg.fokus.xtensions.Util
import java.util.concurrent.CancellationException
import java.time.Duration
import java.util.concurrent.ScheduledThreadPoolExecutor
import java.util.concurrent.ThreadFactory
import java.util.concurrent.atomic.AtomicReference
import java.time.temporal.TemporalUnit
import java.time.temporal.ChronoUnit

class SchedulingUtilTest {
	
	/////////////////
	// repeatEvery //
	/////////////////
	
	@Test(expected = NullPointerException) 
	def void testRepeatEveryLambdaNull() {
		repeatEvery(100, TimeUnit.MILLISECONDS, null)
	}
	
	@Test(expected = NullPointerException) 
	def void testRepeatEveryTimeUnitNull() {
		repeatEvery(100, null)[fail()]
	}
	
	@Test(expected = IllegalArgumentException) 
	def void testRepeatEveryNegativePeriod() {
		repeatEvery(-1, TimeUnit.DAYS)[fail()]
	}
	
	@Test(timeout = 1000)
	def void testRepeatEvery() {
		val count = new AtomicInteger(0)
		val fut = repeatEvery(20, TimeUnit.MILLISECONDS) [
			count.incrementAndGet
		]
		Thread.sleep(100)
		fut.cancel(false)
		val resultCount = count.get
		assertTrue(resultCount >= 5 && resultCount <= 6)
		// now let's test if cancellation worked
		Thread.sleep(20) 
		assertEquals(resultCount, count.get)
	}
	
	
	@Test(timeout = 100)
	def void testRepeatEverySelfCancellation() {
		val res = new AtomicBoolean(false)
		val fut = repeatEvery(20, TimeUnit.MILLISECONDS) [
			assertFalse(res.get)
			res.set(true)
			cancel(false)
		]
		Util.expectException(CancellationException) [
			fut.get(10, TimeUnit.MILLISECONDS)
		]
		assertTrue(res.get)
	}
	
	////////////////////////////////
	// repeatEvery with Scheduler //
	////////////////////////////////
	
	@Test(expected = NullPointerException) 
	def void testRepeatEverySchedulerLambdaNull() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.repeatEvery(100, TimeUnit.MILLISECONDS, null)
	}
	
	@Test(expected = NullPointerException) 
	def void testRepeatEverySchedulerTimeUnitNull() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.repeatEvery(100, null)[fail()]
	}
	
	@Test(expected = IllegalArgumentException) 
	def void testRepeatEverySchedulerNegativePeriod() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.repeatEvery(-1, TimeUnit.DAYS)[fail()]
	}
	
	@Test(timeout = 1000)
	def void testRepeatEveryScheduler() {
		val count = new AtomicInteger(0)
		val scheduler = new ScheduledThreadPoolExecutor(1)
		val fut = scheduler.repeatEvery(20, TimeUnit.MILLISECONDS) [
			count.incrementAndGet
		]
		Thread.sleep(100)
		fut.cancel(false)
		val resultCount = count.get
		assertTrue(resultCount >= 5 && resultCount <= 6)
		// now let's test if cancellation worked
		Thread.sleep(20) 
		assertEquals(resultCount, count.get)
	}
	
	
	@Test(timeout = 100)
	def void testRepeatEverySchedulerSelfCancellation() {
		val res = new AtomicBoolean(false)
		val scheduler = new ScheduledThreadPoolExecutor(1)
		val fut = scheduler.repeatEvery(20, TimeUnit.MILLISECONDS) [
			assertFalse(res.get)
			res.set(true)
			cancel(false)
		]
		Util.expectException(CancellationException) [
			fut.get(10, TimeUnit.MILLISECONDS)
		]
		assertTrue(res.get)
	}
	
	@Test(timeout = 1000)
	def void testRepeatEverySchedulerTestRunningOnScheduler() {
		val res = new AtomicBoolean(false)
		val threadRef = new AtomicReference(null)
		val ThreadFactory threadFactory = [
			val result = new Thread(it)
			threadRef.set(result)
			result
		]
		val scheduler = new ScheduledThreadPoolExecutor(1, threadFactory)
		val fut = scheduler.repeatEvery(20, TimeUnit.MILLISECONDS) [
			res.set(threadRef.get === Thread.currentThread)
			cancel(false)
		]
		try {
			fut.join
		} catch(Exception e){
		}
		assertTrue(res.get)
	}
	
	
	///////////////////////////////
	// repeatEvery with duration //
	///////////////////////////////
	
	@Test(expected = NullPointerException) 
	def void testRepeatEveryDurationLambdaNull() {
		repeatEvery(Duration.ofMillis(100), null)
	}
	
	@Test(expected = NullPointerException) 
	def void testRepeatEveryDurationWithDurationNull() {
		repeatEvery(null)[fail()]
	}
	
	@Test(expected = IllegalArgumentException) 
	def void testRepeatEveryNegativeDuration() {
		repeatEvery(Duration.ofDays(-1))[fail()]
	}
	
	@Test(timeout = 1000)
	def void testRepeatEveryDuration() {
		val count = new AtomicInteger(0)
		val fut = repeatEvery(Duration.ofMillis(20)) [
			count.incrementAndGet
		]
		Thread.sleep(100)
		fut.cancel(false)
		val resultCount = count.get
		assertTrue(resultCount >= 5 && resultCount <= 6)
		// now let's test if cancellation worked
		Thread.sleep(20) 
		assertEquals(resultCount, count.get)
	}
	
	
	@Test(timeout = 100)
	def void testRepeatDurationEverySelfCancellation() {
		val res = new AtomicBoolean(false)
		val fut = repeatEvery(Duration.ofMillis(20)) [
			assertFalse(res.get)
			res.set(true)
			cancel(false)
		]
		Util.expectException(CancellationException) [
			fut.get(10, TimeUnit.MILLISECONDS)
		]
		assertTrue(res.get)
	}
	
	
	///////////////////////////////////////////
	// repeatEvery with scheduler & duration //
	///////////////////////////////////////////
	
	@Test(expected = NullPointerException) 
	def void testRepeatEverySchedulerDurationLambdaNull() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.repeatEvery(Duration.ofMillis(100), null)
	}
	
	@Test(expected = NullPointerException) 
	def void testRepeatEveryDurationWithSchedulerDurationNull() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.repeatEvery(null)[fail()]
	}
	
	@Test(expected = IllegalArgumentException) 
	def void testRepeatEveryNegativeSchedulerDuration() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.repeatEvery(Duration.ofDays(-1))[fail()]
	}
	
	@Test(timeout = 1000)
	def void testRepeatEverySchedulerDuration() {
		val count = new AtomicInteger(0)
		val scheduler = new ScheduledThreadPoolExecutor(1)
		val fut = scheduler.repeatEvery(Duration.ofMillis(20)) [
			count.incrementAndGet
		]
		Thread.sleep(100)
		fut.cancel(false)
		val resultCount = count.get
		assertTrue(resultCount >= 5 && resultCount <= 6)
		// now let's test if cancellation worked
		Thread.sleep(20) 
		assertEquals(resultCount, count.get)
	}
	
	
	@Test(timeout = 100)
	def void testRepeatEveryDurationSchedulerSelfCancellation() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		val res = new AtomicBoolean(false)
		val fut = scheduler.repeatEvery(Duration.ofMillis(20)) [
			assertFalse(res.get)
			res.set(true)
			cancel(false)
		]
		Util.expectException(CancellationException) [
			fut.get(10, TimeUnit.MILLISECONDS)
		]
		assertTrue(res.get)
	}
	
	@Test(timeout = 1000)
	def void testRepeatEveryDurationSchedulerTestRunningOnScheduler() {
		val res = new AtomicBoolean(false)
		val threadRef = new AtomicReference(null)
		val ThreadFactory threadFactory = [
			val result = new Thread(it)
			threadRef.set(result)
			result
		]
		val scheduler = new ScheduledThreadPoolExecutor(1, threadFactory)
		val fut = scheduler.repeatEvery(Duration.ofMillis(20)) [
			res.set(threadRef.get === Thread.currentThread)
			cancel(false)
		]
		try {
			fut.join
		} catch(Exception e){
		}
		assertTrue(res.get)
	}
	
	/////////////
	// waitFor //
	/////////////
	
	@Test(expected = NullPointerException)
	def void testWaitForTimeUnitNull() {
		waitFor(10, null)
	}
	
	@Test(expected = IllegalArgumentException)
	def void testWaitForNegativeTime() {
		waitFor(-1, TimeUnit.SECONDS)
	}
	
	@Test
	def void testWaitFor() {
		val fut = waitFor(10, TimeUnit.MILLISECONDS)
		assertFalse(fut.done)
		Thread.sleep(15)
		assertTrue(fut.done)
		assertNull(fut.get)
	}
	
	//////////////////////
	// waitFor callback //
	//////////////////////
	
	@Test
	def void testWaitForCallbackTimeUnitNull() {
		val result = new AtomicBoolean(true)
		Util.expectException(NullPointerException) [
			waitFor(10, null) [
				result.set(false)
				fail()
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testWaitForCallbackNegativeTime() {
		val result = new AtomicBoolean(true)
		Util.expectException(IllegalArgumentException) [
			waitFor(-1, TimeUnit.SECONDS) [
				result.set(false)
				fail()
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testWaitForCallback() {
		val result = new AtomicBoolean(false)
		val fut = waitFor(10, TimeUnit.MILLISECONDS) [
			result.set(true)
		]
		assertFalse("Expected future to complete after 10 ms, not immediately", fut.done)
		Thread.sleep(15)
		assertTrue("Expected future to complete after 10 ms", fut.done)
		assertNull("Expected future to complete with null value", fut.get)
		assertTrue("Expected callback to be executed",result.get)
	}
	
}