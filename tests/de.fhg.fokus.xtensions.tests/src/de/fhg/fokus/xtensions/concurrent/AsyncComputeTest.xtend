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

class AsyncComputeTest {
	
	@Rule public var thrown = ExpectedException.none;
	@Rule public var timeout = Timeout.seconds(1);
	
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
}
