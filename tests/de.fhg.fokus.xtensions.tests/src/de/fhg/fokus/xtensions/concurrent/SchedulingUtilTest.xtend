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
import java.util.concurrent.ScheduledExecutorService

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
		val fut = repeatEvery(50, TimeUnit.MILLISECONDS) [
			count.incrementAndGet
		]
		Thread.sleep(250)
		fut.cancel(false)
		val resultCount = count.get
		resultCount.assertRange(4,6)
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
			fut.get(50, TimeUnit.MILLISECONDS)
		]
		assertTrue(res.get)
	}
	
	
	/////////////////////////////////
	// repeatEvery with init delay //
	/////////////////////////////////
	
	@Test(expected = NullPointerException) 
	def void testRepeatEveryInitialDelayLambdaNull() {
		repeatEvery(100, TimeUnit.MILLISECONDS).withInitialDelay(50, null)
	}
	
	@Test(expected = NullPointerException) 
	def void testRepeatEveryWithInitialDelayTimeUnitNull() {
		repeatEvery(100, null)//.withInitialDelay(50)[fail()]
	}
	
	@Test(expected = IllegalArgumentException) 
	def void testRepeatEveryWithInitialDelayNegativePeriod() {
		repeatEvery(-1, TimeUnit.DAYS)//.withInitialDelay(50)[fail()]
	}
	
	@Test(expected = IllegalArgumentException) 
	def void testRepeatEveryWithInitialDelayNegativeDelay() {
		repeatEvery(1, TimeUnit.NANOSECONDS).withInitialDelay(-1)[fail()]
	}
	
	@Test(timeout = 1000)
	def void testRepeatEveryWithInitialDelay() {
		val count = new AtomicInteger(0)
		val fut = repeatEvery(50, TimeUnit.MILLISECONDS).withInitialDelay(10) [
			count.incrementAndGet
		]
		Thread.sleep(250)
		fut.cancel(false)
		val resultCount = count.get
		resultCount.assertRange(4,6)
		// now let's test if cancellation worked
		Thread.sleep(20) 
		assertEquals(resultCount, count.get)
	}
	
	
	@Test(timeout = 100)
	def void testRepeatEveryWithInitialDelaySelfCancellation() {
		val res = new AtomicBoolean(false)
		val fut = repeatEvery(20, TimeUnit.MILLISECONDS).withInitialDelay(10) [
			assertFalse(res.get)
			res.set(true)
			cancel(false)
		]
		Util.expectException(CancellationException) [
			fut.get(50, TimeUnit.MILLISECONDS)
		]
		assertTrue(res.get)
	}
	
	
	/////////////////////////////////////////////
	// repeatEvery with Scheduler & init delay //
	/////////////////////////////////////////////
	
	@Test(expected = NullPointerException) 
	def void testRepeatEveryInitialDelaySchedulerLambdaNull() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.repeatEvery(100, TimeUnit.MILLISECONDS).withInitialDelay(50, null)
	}
	
	@Test(expected = NullPointerException) 
	def void testRepeatEveryInitialDelaySchedulerSchedulerNull() {
		val scheduler = null
		scheduler.repeatEvery(100, TimeUnit.MILLISECONDS)//.withInitialDelay(50, [])
	}
	
	@Test(expected = NullPointerException) 
	def void testRepeatEveryWithInitialDelaySchedulerTimeUnitNull() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.repeatEvery(100, null)//.withInitialDelay(50)[fail()]
	}
	
	@Test(expected = IllegalArgumentException) 
	def void testRepeatEveryWithInitialDelaySchedulerNegativePeriod() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.repeatEvery(-1, TimeUnit.DAYS)//.withInitialDelay(50)[fail()]
	}
	
	@Test(expected = IllegalArgumentException) 
	def void testRepeatEveryWithInitialDelaySchedulerNegativeDelay() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.repeatEvery(1, TimeUnit.NANOSECONDS).withInitialDelay(-1)[fail()]
	}
	
	@Test(timeout = 1000)
	def void testRepeatEveryWithInitialDelayScheduler() {
		val count = new AtomicInteger(0)
		val scheduler = new ScheduledThreadPoolExecutor(1)
		Thread.sleep(50) // make scheduler thread start first
		val fut = scheduler.repeatEvery(40, TimeUnit.MILLISECONDS).withInitialDelay(10) [
			count.incrementAndGet
		]
		Thread.sleep(200)
		fut.cancel(false)
		val resultCount = count.get
		assertTrue("Expected count between 4 and 6, but was: "+resultCount, resultCount >= 4 && resultCount <= 6)
		// now let's test if cancellation worked
		Thread.sleep(20) 
		assertEquals("Expected count not to change after cancellation", resultCount, count.get)
	}
	
	
	@Test(timeout = 100)
	def void testRepeatEveryWithInitialDelaySchedulerSelfCancellation() {
		val res = new AtomicBoolean(false)
		val scheduler = new ScheduledThreadPoolExecutor(1)
		val fut = scheduler.repeatEvery(20, TimeUnit.MILLISECONDS).withInitialDelay(10) [
			assertFalse(res.get)
			res.set(true)
			cancel(false)
		]
		Util.expectException(CancellationException) [
			fut.get(30, TimeUnit.MILLISECONDS)
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
		assertTrue(("Expected count between 5 and 6, but was: " + resultCount), resultCount >= 5 && resultCount <= 6)
		// now let's test if cancellation worked
		Thread.sleep(20) 
		assertEquals("Expected result count not to change anymore", resultCount, count.get)
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
			fut.get(50, TimeUnit.MILLISECONDS)
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
		val fut = repeatEvery(Duration.ofMillis(50)) [
			count.incrementAndGet
		]
		Thread.sleep(250)
		fut.cancel(false)
		val resultCount = count.get
		resultCount.assertRange(4,6)
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
			fut.get(50, TimeUnit.MILLISECONDS)
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
		val fut = scheduler.repeatEvery(Duration.ofMillis(50)) [
			count.incrementAndGet
		]
		Thread.sleep(250)
		fut.cancel(false)
		val resultCount = count.get
		resultCount.assertRange(4,6)
		// now let's test if cancellation worked
		Thread.sleep(20) 
		assertEquals(resultCount, count.get)
	}
	
	def assertRange(int actual, int lower, int upper) {
		assertTrue('''Expected value between «lower» and «upper», but was «actual»''',  actual >= lower && actual <= upper)
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
			fut.get(50, TimeUnit.MILLISECONDS)
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
		Thread.sleep(100)
		assertTrue(fut.done)
		assertNull(fut.get)
	}
	
	//////////////////////
	// waitFor Duration //
	//////////////////////
	
	@Test(expected = NullPointerException)
	def void testWaitForDurationNull() {
		waitFor(null)
	}
	
	@Test(expected = IllegalArgumentException)
	def void testWaitForDurationNegativeTime() {
		waitFor(Duration.ofSeconds(1).negated)
	}
	
	@Test
	def void testWaitForDuration() {
		val fut = waitFor(Duration.ofMillis(10))
		assertFalse(fut.done)
		Thread.sleep(100)
		assertTrue(fut.done)
		assertNull(fut.get)
	}
	
	//////////////////////
	// waitFor callback //
	//////////////////////
	
	// TODO: all waitFor with callback should test self cancellation
	
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
		val fut = waitFor(100, TimeUnit.MILLISECONDS) [
			result.set(true)
		]
		assertFalse("Expected future to complete after 100 ms, not immediately", fut.done)
		Thread.sleep(200)
		assertTrue("Expected future to complete after 100 ms", fut.done)
		assertNull("Expected future to complete with null value", fut.get)
		assertTrue("Expected callback to be executed",result.get)
	}
	
	/////////////////////////////////
	// waitFor duration & callback //
	/////////////////////////////////
	
	
	
	
	@Test
	def void testWaitForCallbackDurationNull() {
		val result = new AtomicBoolean(true)
		Util.expectException(NullPointerException) [
			waitFor(null) [
				result.set(false)
				fail()
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testWaitForCallbackDurationNegativeTime() {
		val result = new AtomicBoolean(true)
		Util.expectException(IllegalArgumentException) [
			waitFor(Duration.ofSeconds(1).negated) [
				result.set(false)
				fail()
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testWaitForCallbackDuration() {
		val result = new AtomicBoolean(false)
		val fut = waitFor(Duration.ofMillis(100)) [
			result.set(true)
		]
		assertFalse("Expected future to complete after 100 ms, not immediately", fut.done)
		Thread.sleep(200)
		assertTrue("Expected future to complete after 100 ms", fut.done)
		assertNull("Expected future to complete with null value", fut.get)
		assertTrue("Expected callback to be executed",result.get)
	}
	
	
	
	//////////////////////////////////
	// waitFor scheduler & callback //
	//////////////////////////////////
	
	@Test
	def void testWaitForCallbackSchedulerTimeUnitNull() {
		val result = new AtomicBoolean(true)
		val scheduler = new ScheduledThreadPoolExecutor(1)
		Util.expectException(NullPointerException) [
			scheduler.waitFor(10, null) [
				result.set(false)
				fail()
			]
		]
		assertTrue(result.get)
	}
	
	
	@Test
	def void testWaitForCallbackSchedulerSchedulerNull() {
		val result = new AtomicBoolean(true)
		val ScheduledExecutorService scheduler = null
		Util.expectException(NullPointerException) [
			scheduler.waitFor(10, TimeUnit.MILLISECONDS) [
				result.set(false)
				fail()
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testWaitForCallbackSchedulerNegativeTime() {
		val result = new AtomicBoolean(true)
		val scheduler = new ScheduledThreadPoolExecutor(1)
		Util.expectException(IllegalArgumentException) [
			scheduler.waitFor(-1, TimeUnit.SECONDS) [
				result.set(false)
				fail()
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testWaitForCallbackScheduler() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		val result = new AtomicBoolean(false)
		val fut = scheduler.waitFor(100, TimeUnit.MILLISECONDS) [
			result.set(true)
		]
		assertFalse("Expected future to complete after 100 ms, not immediately", fut.done)
		Thread.sleep(200)
		assertTrue("Expected future to complete after 100 ms", fut.done)
		assertNull("Expected future to complete with null value", fut.get)
		assertTrue("Expected callback to be executed",result.get)
	}
	
	
	@Test(timeout = 1000)
	def void testWaitForCallbackSchedulerOnThread() {
		val res = new AtomicBoolean(false)
		val threadRef = new AtomicReference(null)
		val ThreadFactory threadFactory = [
			val result = new Thread(it)
			threadRef.set(result)
			result
		]
		val scheduler = new ScheduledThreadPoolExecutor(1, threadFactory)
		val fut = scheduler.waitFor(20, TimeUnit.MILLISECONDS) [
			res.set(threadRef.get === Thread.currentThread)
		]
		try {
			fut.join
		} catch(Exception e){
		}
		assertTrue(res.get)
	}
	
	///////////
	// delay //
	///////////
	
	@Test
	def void testDelayTimeUnitNull() {
		val result = new AtomicBoolean(true)
		Util.expectException(NullPointerException) [
			delay(10, null) [
				result.set(false)
				fail()
				""
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testDelayNegativeTime() {
		val result = new AtomicBoolean(true)
		Util.expectException(IllegalArgumentException) [
			delay(-1, TimeUnit.SECONDS) [
				result.set(false)
				fail()
				""
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testDelayCallback() {
		val expected = "Result string"
		val fut = delay(100, TimeUnit.MILLISECONDS) [
			expected
		]
		assertFalse("Expected future to complete after 100 ms, not immediately", fut.done)
		Thread.sleep(200)
		assertTrue("Expected future to complete after 100 ms", fut.done)
		assertSame("Expected future to complete with null value", expected, fut.get)
	}
	
	
	@Test
	def void testDelayCallbackSelfCancellation() {
		val expected = "Result string"
		val fut = delay(100, TimeUnit.MILLISECONDS) [
			cancel(false)
			expected
		]
		assertFalse("Expected future to complete after 100 ms, not immediately", fut.done)
		Thread.sleep(200)
		assertTrue("Expected future to complete after 100 ms", fut.done)
		Util.expectException(CancellationException) [
			fut.get
		]
	}
	

	/////////////////////////
	// delay with duration //
	/////////////////////////
	
	@Test
	def void testDelayDurationNull() {
		val result = new AtomicBoolean(true)
		Util.expectException(NullPointerException) [
			delay(null) [
				result.set(false)
				fail()
				""
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testDelayDurationNegativeTime() {
		val result = new AtomicBoolean(true)
		Util.expectException(IllegalArgumentException) [
			delay(Duration.ofSeconds(1).negated) [
				result.set(false)
				fail()
				""
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testDelayDurationCallback() {
		val expected = "Result string"
		val fut = delay(Duration.ofMillis(100)) [
			expected
		]
		assertFalse("Expected future to complete after 100 ms, not immediately", fut.done)
		Thread.sleep(200)
		assertTrue("Expected future to complete after 100 ms", fut.done)
		assertSame("Expected future to complete with null value", expected, fut.get)
	}
	
	
	@Test
	def void testDelayDurationCallbackSelfCancellation() {
		val expected = "Result string"
		val fut = delay(Duration.ofMillis(100)) [
			cancel(false)
			expected
		]
		assertFalse("Expected future to complete after 100 ms, not immediately", fut.done)
		Thread.sleep(200)
		assertTrue("Expected future to complete after 100 ms", fut.done)
		Util.expectException(CancellationException) [
			fut.get
		]
	}
	
	
	
	//////////////////////////
	// delay with scheduler //
	//////////////////////////
	
	@Test
	def void testDelaySchedulerTimeUnitNull() {
		val result = new AtomicBoolean(true)
		val scheduler = new ScheduledThreadPoolExecutor(1)
		Util.expectException(NullPointerException) [
			scheduler.delay(10, null) [
				result.set(false)
				fail()
				""
			]
		]
		assertTrue(result.get)
	}
	
	
	@Test
	def void testDelaySchedulerNull() {
		val result = new AtomicBoolean(true)
		val ScheduledExecutorService scheduler = null
		Util.expectException(NullPointerException) [
			scheduler.delay(10, TimeUnit.MILLISECONDS) [
				result.set(false)
				fail()
				""
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testDelaySchedulerNegativeTime() {
		val result = new AtomicBoolean(true)
		val scheduler = new ScheduledThreadPoolExecutor(1)
		Util.expectException(IllegalArgumentException) [
			scheduler.delay(-1, TimeUnit.SECONDS) [
				result.set(false)
				fail()
				""
			]
		]
		assertTrue(result.get)
	}
	
	@Test
	def void testDelayScheduler() {
		val expected = "Result string"
		val scheduler = new ScheduledThreadPoolExecutor(1)
		val fut = scheduler.delay(50, TimeUnit.MILLISECONDS) [
			expected
		]
		assertFalse("Expected future to complete after 50 ms, not immediately", fut.done)
		Thread.sleep(200)
		assertTrue("Expected future to complete after 50 ms", fut.done)
		assertSame("Expected future to complete with null value", expected, fut.get)
	}
	
	
	@Test
	def void testDelaySchedulerSelfCancellation() {
		val expected = "Result string"
		val scheduler = new ScheduledThreadPoolExecutor(1)
		val fut = scheduler.delay(10, TimeUnit.MILLISECONDS) [
			cancel(false)
			expected
		]
		assertFalse("Expected future to complete after 10 ms, not immediately", fut.done)
		Thread.sleep(100)
		assertTrue("Expected future to complete after 10 ms", fut.done)
		Util.expectException(CancellationException) [
			fut.get
		]
	}
	
	@Test
	def void testDelaySchedulerOnSchedulerThread() {
		val res = new AtomicBoolean(false)
		val threadRef = new AtomicReference(null)
		val ThreadFactory threadFactory = [
			val result = new Thread(it)
			threadRef.set(result)
			result
		]
		val scheduler = new ScheduledThreadPoolExecutor(1, threadFactory)
		scheduler.delay(10, TimeUnit.MILLISECONDS) [
			res.set(threadRef.get === Thread.currentThread)
			""
		]
		Thread.sleep(100)
		assertTrue(res.get)
	}
	
}