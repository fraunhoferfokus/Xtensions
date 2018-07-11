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

import de.fhg.fokus.xtensions.Util
import java.util.concurrent.CompletableFuture
import java.util.concurrent.CompletionException
import java.util.concurrent.Executors
import java.util.concurrent.Semaphore
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeoutException
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicReference
import org.junit.Rule
import org.junit.Test
import org.junit.rules.ExpectedException
import org.junit.rules.Timeout

import static org.hamcrest.core.IsInstanceOf.instanceOf
import static org.junit.Assert.*

import static extension de.fhg.fokus.xtensions.concurrent.AsyncCompute.*

class AsyncComputeTest {
	
	@Rule public var thrown = ExpectedException.none;
	@Rule public var timeout = Timeout.seconds(1);

	//////////////
	// asyncRun //
	//////////////
	
	@Test(expected = NullPointerException) def void testAsyncRunNullAction() {
		asyncRun(null)
	}
	
	@Test def void testAsyncRun() {
		val success = new AtomicBoolean(false)
		val fut = asyncRun [
			success.set(true)
		]
		fut.join
		
		assertTrue("When future completes, the async block must have executed.", success.get)
	}
	
	@Test def void testAsyncRunExceptionally() {
		val fut = asyncRun [
			throw new NullPointerException
		]
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		fut.join
	}
	
	@Test def void testAsyncRunCancellation() {
		val success = new AtomicBoolean(true) // if block is not started at all, cancellation kicked in early
		val blockStart = new Semaphore(0)
		val fut = asyncRun [
			blockStart.acquire
			success.set(cancelled)
		]
		fut.cancel(false)
		blockStart.release
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncRunCancellationCheckInBlock() {
		val success = new AtomicBoolean(false) // we explicitly go to block before cancellation
		val reachBlock = new Semaphore(0)
		val cancelFut = new Semaphore(0)
		val fut = asyncRun [
			reachBlock.release
			cancelFut.acquire
			success.set(cancelled)
			reachBlock.release
		]
		reachBlock.acquire
		fut.cancel(false)
		cancelFut.release
		reachBlock.acquire
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncRunSuccessCancellationNoModify() {
		val sema = new Semaphore(0)
		val fut = asyncRun [
			sema.acquire
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by successful asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncRunExceptionallyCancellationNoModify() {
		val sema = new Semaphore(0)
		val fut = asyncRun [
			sema.acquire
			throw new IllegalStateException
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by exceptional asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncRunOnDiffernetThread() {
		val thread = new AtomicReference<Thread>()
		val factory = [
			val t = new Thread(it)
			thread.set(t)
			t
		]
		val executor = Executors.newSingleThreadExecutor(factory)
		val result = new AtomicBoolean(false)
		val fut = executor.asyncRun [
			result.set(thread.get === Thread.currentThread)
		]
		fut.get
		assertTrue(result.get)
	}
	
	
	///////////////////////
	// asyncRun Executor //
	///////////////////////
	
	@Test(expected = NullPointerException) def void testAsyncRunExecutorNullAction() {
		val executor = Executors.newSingleThreadExecutor
		executor.asyncRun(null)
	}
	
	@Test(expected = NullPointerException) def void testAsyncRunExecutorNullExecutor() {
		val executor = null
		executor.asyncRun[fail()]
	}
	
	@Test def void testAsyncRunExecutor() {
		val executor = Executors.newSingleThreadExecutor
		val success = new AtomicBoolean(false)
		val fut = executor.asyncRun [
			success.set(true)
		]
		fut.join
		
		assertTrue("When future completes, the async block must have executed.", success.get)
	}
	
	@Test def void testAsyncRunExecutorExceptionally() {
		val executor = Executors.newSingleThreadExecutor
		val fut = executor.asyncRun [
			throw new NullPointerException
		]
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		fut.join
	}
	
	@Test def void testAsyncRunExecutorCancellation() {
		val executor = Executors.newSingleThreadExecutor
		val success = new AtomicBoolean(true) // if block is not started at all, cancellation kicked in early
		val blockStart = new Semaphore(0)
		val fut = executor.asyncRun [
			blockStart.acquire
			success.set(cancelled)
		]
		fut.cancel(false)
		blockStart.release
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncRunExecutorCancellationCheckInBlock() {
		val executor = Executors.newSingleThreadExecutor
		val success = new AtomicBoolean(false) // we explicitly go to block before cancellation
		val reachBlock = new Semaphore(0)
		val cancelFut = new Semaphore(0)
		val fut = executor.asyncRun [
			reachBlock.release
			cancelFut.acquire
			success.set(cancelled)
			reachBlock.release
		]
		reachBlock.acquire
		fut.cancel(false)
		cancelFut.release
		reachBlock.acquire
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncRunExecutorSuccessCancellationNoModify() {
		val executor = Executors.newSingleThreadExecutor
		val sema = new Semaphore(0)
		val fut = executor.asyncRun [
			sema.acquire
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by successful asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncRunExecutorExceptionallyCancellationNoModify() {
		val executor = Executors.newSingleThreadExecutor
		val sema = new Semaphore(0)
		val fut = executor.asyncRun [
			sema.acquire
			throw new IllegalStateException
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by exceptional asyncRun block",fut.cancelled)
	}
	
	//////////////////////
	// asyncRun Timeout //
	//////////////////////
	
	@Test(expected = NullPointerException) def void testAsyncTimeoutRunNullAction() {
		asyncRun(0L,TimeUnit.SECONDS,null)
	}
	
	@Test(expected = NullPointerException) def void testAsyncTimeoutRunNullTimeUnit() {
		asyncRun(0L,null)[]
	}
	
	@Test def void testAsyncRunNoTimeout() {
		val success = new AtomicBoolean(false)
		val fut = asyncRun(5,TimeUnit.SECONDS) [
			success.set(!cancelled)
		]
		fut.join
		
		assertTrue("When future completes before timeout, the async block must have executed and future must not be cancelled.", success.get)
	}
	
	@Test def void testAsyncRunWithTimeout() {
		val sema = new Semaphore(0)
		val fut = asyncRun(1,TimeUnit.NANOSECONDS) [
			Thread.sleep(50)
			sema.release
		]
		fut.assertTimedOut
		// must succeed and not time out
		sema.acquire
	}
	
	@Test def void testAsyncRunExceptionallyNoTimeout() {
		val fut = asyncRun(1, TimeUnit.SECONDS) [
			throw new NullPointerException
		]
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		fut.join
	}
	
	@Test def void testAsyncRunExceptionallyOnTimeout() {
		val fut = asyncRun(1, TimeUnit.MILLISECONDS) [
			Thread.sleep(50)
			throw new NullPointerException
		]
		
		fut.assertTimedOut
		Thread.sleep(100)
		// Must still be timed out after NPE thrown
		fut.assertTimedOutNow
	}
	
	@Test def void testAsyncRunCancellationNoTimeout() {
		val success = new AtomicBoolean(true) // if block is not started at all, cancellation kicked in early
		val blockStart = new Semaphore(0)
		val fut = asyncRun(10, TimeUnit.SECONDS) [
			blockStart.acquire
			success.set(cancelled)
		]
		fut.cancel(false)
		blockStart.release
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncRunCancellationCheckInBlockNoTimeout() {
		val success = new AtomicBoolean(false) // we explicitly go to block before cancellation
		val reachBlock = new Semaphore(0)
		val cancelFut = new Semaphore(0)
		val fut = asyncRun(10, TimeUnit.SECONDS) [
			reachBlock.release
			cancelFut.acquire
			success.set(cancelled)
			reachBlock.release
		]
		reachBlock.acquire
		fut.cancel(false)
		cancelFut.release
		reachBlock.acquire
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncRunSuccessCancellationNoModifyNoTimeout() {
		val sema = new Semaphore(0)
		val fut = asyncRun(10, TimeUnit.SECONDS) [
			sema.acquire
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by successful asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncRunExceptionallyCancellationNoModifyNoTimeout() {
		val sema = new Semaphore(0)
		val fut = asyncRun(2,TimeUnit.SECONDS) [
			sema.acquire
			throw new IllegalStateException
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by exceptional asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncRunExceptionallyTimeout() {
		val fut = asyncRun(1,TimeUnit.NANOSECONDS) [
			Thread.sleep(50)
			throw new IllegalStateException
		]
		Thread.sleep(100)
		// Timeout should not be overwritten by exceptional asyncRun block
		fut.assertTimedOutNow
	}
	
	@Test def void testAsyncRunOnDiffernetThreadNoTimeout() {
		val thread = new AtomicReference<Thread>()
		val factory = [
			val t = new Thread(it)
			thread.set(t)
			t
		]
		val executor = Executors.newSingleThreadExecutor(factory)
		val result = new AtomicBoolean(false)
		val fut = executor.asyncRun(1, TimeUnit.SECONDS) [
			result.set(thread.get === Thread.currentThread)
		]
		fut.get
		assertTrue(result.get)
	}
	
	//////////////////////////////////
	// asyncRun Timeout & Scheduler //
	//////////////////////////////////
	
	@Test(expected = NullPointerException) def void testAsyncTimeoutSchedulerRunNullAction() {
		val scheduler = Executors.newScheduledThreadPool(1)
		scheduler.asyncRun(0L,TimeUnit.SECONDS,null)
	}
	
	@Test(expected = NullPointerException) def void testAsyncTimeoutSchedulerRunNullScheduler() {
		val scheduler = null
		scheduler.asyncRun(0L,TimeUnit.SECONDS)[fail()]
	}
	
	@Test(expected = NullPointerException) def void testAsyncTimeoutSchedulerRunNullTimeUnit() {
		val scheduler = Executors.newScheduledThreadPool(1)
		scheduler.asyncRun(0L,null)[]
	}
	
	@Test def void testAsyncRunNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val success = new AtomicBoolean(false)
		val fut = scheduler.asyncRun(5,TimeUnit.SECONDS) [
			success.set(!cancelled)
		]
		fut.join
		
		assertTrue("When future completes before timeout, the async block must have executed and future must not be cancelled.", success.get)
	}
	
	@Test def void testAsyncRunWithTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val sema = new Semaphore(0)
		val fut = scheduler.asyncRun(1,TimeUnit.NANOSECONDS) [
			Thread.sleep(50)
			sema.release
		]
		fut.assertTimedOut
		// must succeed and not time out
		sema.acquire
	}
	
	@Test def void testAsyncRunExceptionallyNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val fut = scheduler.asyncRun(1, TimeUnit.SECONDS) [
			throw new NullPointerException
		]
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		fut.join
	}
	
	@Test def void testAsyncRunExceptionallyOnTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val fut = scheduler.asyncRun(1, TimeUnit.MILLISECONDS) [
			Thread.sleep(50)
			throw new NullPointerException
		]
		fut.assertTimedOut
		Thread.sleep(100)
		//After cancellation, exceptional completion of action should not overwrite future result"
		fut.assertTimedOutNow
	}
	
	@Test def void testAsyncRunCancellationNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val success = new AtomicBoolean(true) // if block is not started at all, cancellation kicked in early
		val blockStart = new Semaphore(0)
		val fut = scheduler.asyncRun(10, TimeUnit.SECONDS) [
			blockStart.acquire
			success.set(cancelled)
		]
		fut.cancel(false)
		blockStart.release
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncRunCancellationCheckInBlockNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val success = new AtomicBoolean(false) // we explicitly go to block before cancellation
		val reachBlock = new Semaphore(0)
		val cancelFut = new Semaphore(0)
		val fut = scheduler.asyncRun(10, TimeUnit.SECONDS) [
			reachBlock.release
			cancelFut.acquire
			success.set(cancelled)
			reachBlock.release
		]
		reachBlock.acquire
		fut.cancel(false)
		cancelFut.release
		reachBlock.acquire
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncRunSuccessCancellationNoModifyNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val sema = new Semaphore(0)
		val fut = scheduler.asyncRun(10, TimeUnit.SECONDS) [
			sema.acquire
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(20)
		assertTrue("Cancellation should not be overwritten by successful asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncRunExceptionallyCancellationNoModifyNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val sema = new Semaphore(0)
		val fut = scheduler.asyncRun(2,TimeUnit.SECONDS) [
			sema.acquire
			throw new IllegalStateException
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by exceptional asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncRunExceptionallyTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val fut = scheduler.asyncRun(1,TimeUnit.NANOSECONDS) [
			Thread.sleep(10)
			throw new IllegalStateException
		]
		Thread.sleep(50)
		fut.assertTimedOutNow
	}
	
	@Test def void testAsyncRunOnDiffernetThreadNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val thread = new AtomicReference<Thread>()
		val factory = [
			val t = new Thread(it)
			thread.set(t)
			t
		]
		val executor = Executors.newSingleThreadExecutor(factory)
		val result = new AtomicBoolean(false)
		val fut = executor.asyncRun(scheduler,1, TimeUnit.SECONDS) [
			result.set(thread.get === Thread.currentThread)
		]
		fut.get
		assertTrue(result.get)
	}
	
	
	/////////////////
	// asyncSupply //
	/////////////////
	
	@Test(expected = NullPointerException) def void testAsyncSupplyNullAction() {
		asyncSupply(null)
	}
	
	@Test def void testAsyncSupply() {
		val expected = "correct result"
		val fut = asyncSupply [
			expected
		]
		val result = fut.join
		
		assertSame("When future completes, the async result must be the one provided by supplier.", expected, result)
	}
	
	@Test def void testAsyncSupplyExceptionally() {
		val fut = asyncSupply [
			throw new NullPointerException
		]
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		fut.join
	}
	
	@Test def void testAsyncSupplyCancellation() {
		val success = new AtomicBoolean(true) // if block is not started at all, cancellation kicked in early
		val blockStart = new Semaphore(0)
		val fut = asyncSupply [
			blockStart.acquire
			success.set(cancelled)
			""
		]
		fut.cancel(false)
		blockStart.release
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncSupplyCancellationCheckInBlock() {
		val success = new AtomicBoolean(false) // we explicitly go to block before cancellation
		val reachBlock = new Semaphore(0)
		val cancelFut = new Semaphore(0)
		val fut = asyncSupply [
			reachBlock.release
			cancelFut.acquire
			success.set(cancelled)
			reachBlock.release
			""
		]
		reachBlock.acquire
		fut.cancel(false)
		cancelFut.release
		reachBlock.acquire
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncSupplySuccessCancellationNoModify() {
		val sema = new Semaphore(0)
		val fut = asyncSupply [
			sema.acquire
			""
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by successful asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncSupplyExceptionallyCancellationNoModify() {
		val sema = new Semaphore(0)
		val fut = asyncSupply [
			sema.acquire
			throw new IllegalStateException
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by exceptional asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncSupplyRunOnDiffernetThread() {
		val thread = new AtomicReference<Thread>()
		val factory = [
			val t = new Thread(it)
			thread.set(t)
			t
		]
		val executor = Executors.newSingleThreadExecutor(factory)
		val result = new AtomicBoolean(false)
		val fut = executor.asyncSupply [
			result.set(thread.get === Thread.currentThread)
			""
		]
		fut.get
		assertTrue(result.get)
	}
	
	
	
	/////////////////////////
	// asyncSupply Timeout //
	/////////////////////////
	
	@Test(expected = NullPointerException) def void testAsyncSupplyTimeoutNullAction() {
		asyncSupply(0L,TimeUnit.SECONDS,null)
	}
	
	@Test(expected = NullPointerException) def void testAsyncSupplyTimeoutNullTimeUnit() {
		asyncRun(0L,null)[]
	}
	
	@Test def void testAsyncSupplyNoTimeout() {
		val success = new AtomicBoolean(false)
		val expected = "foo"
		val fut = asyncSupply(5,TimeUnit.SECONDS) [
			success.set(!cancelled)
			expected
		]
		val result = fut.join
		assertSame("Provided result should be value asynchronously provided", expected, result)
		assertTrue("When future completes before timeout, the async block must have executed and future must not be cancelled.", success.get)
	}
	
	@Test def void testAsyncSupplyWithTimeout() {
		val sema = new Semaphore(0)
		val fut = asyncSupply(1,TimeUnit.NANOSECONDS) [
			Thread.sleep(50)
			sema.release
			""
		]
		fut.assertTimedOut
		// must succeed and not time out
		sema.acquire
		Thread.sleep(50)
		fut.assertTimedOutNow
	}
	
	@Test def void testAsynSupplyExceptionallyNoTimeout() {
		val fut = asyncSupply(1, TimeUnit.SECONDS) [
			throw new NullPointerException
		]
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		fut.join
	}
	
	@Test def void testAsyncSupplyExceptionallyOnTimeout() {
		val fut = asyncSupply(1, TimeUnit.MILLISECONDS) [
			Thread.sleep(50)
			throw new NullPointerException
		]
		
		fut.assertTimedOut
		Thread.sleep(100)
		val msg = "After exceptional completion, result of action should not overwrite future result"
		val ex2 = Util.expectException(CompletionException) [
			fut.join
		]
		assertThat(msg, ex2.cause, instanceOf(TimeoutException))
	}
	
	def assertTimedOut(CompletableFuture<?> fut) {
		val ex = Util.expectException(CompletionException) [
			fut.join
		]
		assertThat(ex.cause, instanceOf(TimeoutException))
	}
	
	def assertTimedOutNow(CompletableFuture<?> fut) {
		val ex = Util.expectException(CompletionException) [
			fut.getNow(null)
		]
		assertThat(ex.cause, instanceOf(TimeoutException))
	}
	
	@Test def void testAsyncSupplyCancellationNoTimeout() {
		val success = new AtomicBoolean(true) // if block is not started at all, cancellation kicked in early
		val blockStart = new Semaphore(0)
		val fut = asyncSupply(10, TimeUnit.SECONDS) [
			blockStart.acquire
			success.set(cancelled)
			""
		]
		fut.cancel(false)
		blockStart.release
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncSupplyCancellationCheckInBlockNoTimeout() {
		val success = new AtomicBoolean(false) // we explicitly go to block before cancellation
		val reachBlock = new Semaphore(0)
		val cancelFut = new Semaphore(0)
		val fut = asyncSupply(10, TimeUnit.SECONDS) [
			reachBlock.release
			cancelFut.acquire
			success.set(cancelled)
			reachBlock.release
			""
		]
		reachBlock.acquire
		fut.cancel(false)
		cancelFut.release
		reachBlock.acquire
		assertTrue("Cancellation should be visible in asyncRun block",success.get)
	}
	
	@Test def void testAsyncSupplySuccessCancellationNoModifyNoTimeout() {
		val sema = new Semaphore(0)
		val fut = asyncSupply(10, TimeUnit.SECONDS) [
			sema.acquire
			""
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by successful asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncSupplyExceptionallyCancellationNoModifyNoTimeout() {
		val sema = new Semaphore(0)
		val fut = asyncSupply(2,TimeUnit.SECONDS) [
			sema.acquire
			throw new IllegalStateException
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by exceptional asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncSupplyExceptionallyTimeout() {
		val fut = asyncRun(1,TimeUnit.NANOSECONDS) [
			Thread.sleep(50)
			throw new IllegalStateException
		]
		fut.assertTimedOut
		Thread.sleep(100)
		//Timeout should not be overwritten by exceptional asyncRun block
		fut.assertTimedOutNow
	}
	
	@Test def void testAsyncSupplyOnDiffernetThreadNoTimeout() {
		val thread = new AtomicReference<Thread>()
		val factory = [
			val t = new Thread(it)
			thread.set(t)
			t
		]
		val executor = Executors.newSingleThreadExecutor(factory)
		val result = new AtomicBoolean(false)
		val fut = executor.asyncSupply(1, TimeUnit.SECONDS) [
			result.set(thread.get === Thread.currentThread)
			""
		]
		fut.get
		assertTrue(result.get)
	}
	
	
	/////////////////////////////////////
	// asyncSupply Timeout & Scheduler //
	/////////////////////////////////////
	
	@Test(expected = NullPointerException) def void testAsyncsupplyTimeoutSchedulerNullAction() {
		val scheduler = Executors.newScheduledThreadPool(1)
		scheduler.asyncSupply(0L,TimeUnit.SECONDS,null)
	}
	
	@Test(expected = NullPointerException) def void testAsyncSupplyTimeoutSchedulerNullScheduler() {
		val scheduler = null
		scheduler.asyncSupply(0L,TimeUnit.SECONDS)[fail() ""]
	}
	
	@Test(expected = NullPointerException) def void testAsyncSupplyTimeoutSchedulerNullTimeUnit() {
		val scheduler = Executors.newScheduledThreadPool(1)
		scheduler.asyncSupply(0L,null)[fail() null]
	}
	
	@Test def void testAsyncSupplyNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val expected = "the expected result"
		val fut = scheduler.asyncSupply(5,TimeUnit.SECONDS) [
			expected
		]
		val result = fut.join
		
		assertSame("Future must be completed with result provided by action.", expected, result)
	}
	
	@Test def void testAsyncSupplyWithTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val sema = new Semaphore(0)
		val fut = scheduler.asyncSupply(1,TimeUnit.NANOSECONDS) [
			Thread.sleep(50)
			sema.release
			""
		]
		fut.assertTimedOut
		// must succeed and not time out
		sema.acquire
		Thread.sleep(60)
		// after return of string must still be timed out
		fut.assertTimedOutNow
	}
	
	@Test def void testAsyncSupplyExceptionallyNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val fut = scheduler.asyncSupply(1, TimeUnit.SECONDS) [
			throw new NullPointerException
		]
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		fut.join
	}
	
	@Test def void testAsyncSupplyExceptionallyOnTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val fut = scheduler.asyncSupply(1, TimeUnit.MILLISECONDS) [
			Thread.sleep(50)
			throw new NullPointerException
		]
		fut.assertTimedOut
		Thread.sleep(100)
		fut.assertTimedOutNow
	}
	
	@Test def void testAsyncSupplyCancellationNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val success = new AtomicBoolean(true) // if block is not started at all, cancellation kicked in early
		val blockStart = new Semaphore(0)
		val fut = scheduler.asyncSupply(10, TimeUnit.SECONDS) [
			blockStart.acquire
			success.set(cancelled)
			""
		]
		fut.cancel(false)
		blockStart.release
		assertTrue("Cancellation should be visible in asyncSupply block",success.get)
	}
	
	@Test def void testAsyncSupplyCancellationCheckInBlockNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val success = new AtomicBoolean(false) // we explicitly go to block before cancellation
		val reachBlock = new Semaphore(0)
		val cancelFut = new Semaphore(0)
		val fut = scheduler.asyncSupply(10, TimeUnit.SECONDS) [
			reachBlock.release
			cancelFut.acquire
			success.set(cancelled)
			reachBlock.release
			""
		]
		reachBlock.acquire
		fut.cancel(false)
		cancelFut.release
		reachBlock.acquire
		assertTrue("Cancellation should be visible in asyncSupply block",success.get)
	}
	
	@Test def void testAsyncSupplySuccessCancellationNoModifyNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val sema = new Semaphore(0)
		val fut = scheduler.asyncSupply(10, TimeUnit.SECONDS) [
			sema.acquire
			""
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by successful asyncSupply block",fut.cancelled)
	}
	
	@Test def void testAsyncSupplyExceptionallyCancellationNoModifyNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val sema = new Semaphore(0)
		val fut = scheduler.asyncSupply(2,TimeUnit.SECONDS) [
			sema.acquire
			throw new IllegalStateException
		]
		fut.cancel(false)
		sema.release
		Thread.sleep(50)
		assertTrue("Cancellation should not be overwritten by exceptional asyncSupply block",fut.cancelled)
	}
	
	@Test def void testAsyncSupplyExceptionallyTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val fut = scheduler.asyncSupply(1,TimeUnit.NANOSECONDS) [
			Thread.sleep(100)
			throw new IllegalStateException
		]
		Thread.sleep(50)
		fut.assertTimedOut
	}
	
	@Test def void testAsyncSupplyOnDiffernetThreadNoTimeoutScheduler() {
		val scheduler = Executors.newScheduledThreadPool(1)
		val thread = new AtomicReference<Thread>()
		val factory = [
			val t = new Thread(it)
			thread.set(t)
			t
		]
		val executor = Executors.newSingleThreadExecutor(factory)
		val result = new AtomicBoolean(false)
		val fut = executor.asyncSupply(scheduler,1, TimeUnit.SECONDS) [
			result.set(thread.get === Thread.currentThread)
			""
		]
		fut.get
		assertTrue(result.get)
	}
}