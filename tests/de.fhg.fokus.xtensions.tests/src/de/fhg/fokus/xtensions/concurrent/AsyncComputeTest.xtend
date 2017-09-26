package de.fhg.fokus.xtensions.concurrent

import org.junit.Test
import static org.junit.Assert.*
import static extension de.fhg.fokus.xtensions.concurrent.AsyncCompute.*
import java.util.concurrent.atomic.AtomicBoolean
import org.junit.Rule
import org.junit.rules.Timeout
import org.junit.rules.ExpectedException
import java.util.concurrent.CompletionException
import static  org.hamcrest.core.IsInstanceOf.instanceOf
import java.util.concurrent.Semaphore
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicReference
import java.util.concurrent.TimeUnit
import de.fhg.fokus.xtensions.Util
import java.util.concurrent.CancellationException

class AsyncComputeTest {
	
	@Rule public var thrown = ExpectedException.none;
	@Rule public var timeout = Timeout.seconds(1);

	///////////////
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
		Thread.sleep(10)
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
		Thread.sleep(10)
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
			Thread.sleep(10)
			sema.release
		]
		Util.expectException(CancellationException) [
			fut.join
		]
		assertTrue("When future completes after timeout, the future must be cancelled", fut.cancelled)
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
			Thread.sleep(10)
			throw new NullPointerException
		]
		
		Util.expectException(CancellationException) [
			fut.join
		]
		Thread.sleep(20)
		val msg = "After cancellation, exceptional completion of action should not overwrite future result"
		assertTrue(msg, fut.cancelled)
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
		Thread.sleep(10)
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
		Thread.sleep(10)
		assertTrue("Cancellation should not be overwritten by exceptional asyncRun block",fut.cancelled)
	}
	
	@Test def void testAsyncRunExceptionallyTimeout() {
		val fut = asyncRun(1,TimeUnit.NANOSECONDS) [
			Thread.sleep(10)
			throw new IllegalStateException
		]
		Thread.sleep(20)
		assertTrue("Timeout should not be overwritten by exceptional asyncRun block",fut.cancelled)
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
}