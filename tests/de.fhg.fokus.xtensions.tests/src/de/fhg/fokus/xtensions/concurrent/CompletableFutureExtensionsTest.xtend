package de.fhg.fokus.xtensions.concurrent

import org.junit.Test
import java.util.concurrent.CompletableFuture
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*
import static org.junit.Assert.*
import org.junit.Rule
import org.junit.rules.ExpectedException
import static org.hamcrest.core.IsInstanceOf.instanceOf
import java.util.concurrent.CompletionException
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.CancellationException
import java.util.concurrent.TimeUnit
import java.util.concurrent.ScheduledThreadPoolExecutor
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicReference
import org.junit.rules.Timeout
import java.util.ConcurrentModificationException

class CompletableFutureExtensionsTest {
	
	@Rule public var thrown = ExpectedException.none;
	@Rule public var timeout = Timeout.seconds(1);
	
	///////////////////////
	// then -> thenApply //
	///////////////////////
	
	@Test(expected = NullPointerException) def void testThenApplyFutNull() {
		val CompletableFuture<String> cf = null
		cf.then [toUpperCase]
	}
	
	@Test(expected = NullPointerException) def void testThenApplyHandlerNull() {
		val cf = new CompletableFuture<String>
		val (String)=>String handler = null
		cf.then(handler)
	}
	
	@Test def void testThenApplyHandlerThrowing() {
		val cf = new CompletableFuture<String>
		val (String)=>String handler = [
			throw new NullPointerException
		]
		val result = cf.then(handler)
		cf.complete("foo")
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		result.join
	}
	
	@Test def void testThenApplyHandlerThrowingAfterCompletion() {
		val cf = new CompletableFuture<String>
		val (String)=>String handler = [
			throw new NullPointerException
		]
		cf.complete("foo")
		val result = cf.then(handler)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		result.join
	}
	
	@Test def void testThenApplySuccess() {
		val cf = new CompletableFuture<String>
		val after = cf.then [toUpperCase]
		assertFalse("Then should not create a completed future", after.done)
		
		cf.complete("foo")
		val result = after.get
		assertEquals("FOO", result)
	}
	
	@Test def void testThenApplySuccessThrowing() {
		val cf = new CompletableFuture<String>
		val (String)=>String handler = [
			throw new NullPointerException
		]
		val after = cf.then(handler)
		assertFalse("Then should not create a completed future", after.done)
		
		cf.complete("foo")
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testThenApplySuccessAfterCompletion() {
		val cf = new CompletableFuture<String>
		cf.complete("foo")
		val after = cf.then [toUpperCase]
		
		val result = after.get
		assertEquals("FOO", result)
	}
	
	@Test def void testThenApplyError() {
		val expected = new NumberFormatException
		val cf = new CompletableFuture<String>
		val after = cf.then [toUpperCase]
		assertFalse("Then should not create a completed future", after.done)
		
		cf.completeExceptionally(expected)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(expected.class))
		after.join
	}
	
	@Test def void testThenApplyErrorAfterCompletion() {
		val expected = new NumberFormatException
		val cf = new CompletableFuture<String>
		cf.completeExceptionally(expected)
		val after = cf.then [toUpperCase]
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(expected.class))
		after.join
	}
	
	////////////////////////
	// then -> thenAccept //
	////////////////////////
	
	@Test(expected = NullPointerException) def void testThenAcceptFutNull() {
		val CompletableFuture<String> cf = null
		val (String)=>void handler = [] 
		cf.then(handler)
	}
	
	@Test(expected = NullPointerException) def void testThenAcceptHandlerNull() {
		val cf = new CompletableFuture<String>
		val (String)=>void handler = null
		cf.then(handler)
	}
	
	@Test def void testThenAcceptSuccess() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val after = cf.then [success.set(true)]
		assertFalse("Then should not create a completed future", after.done)
		
		cf.complete("foo")
		after.get  // must not throw exception
		assertTrue("Then handler must be called.", success.get)		
	}
	
	@Test def void testThenAcceptSuccessAfterCompletion() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		cf.complete("foo")
		val after = cf.then [success.set(true)]
		
		after.get // must not throw exception
		assertTrue("Then handler must be called.", success.get)	
	}
	
	@Test def void testThenAcceptError() {
		val success = new AtomicBoolean(true)
		val expected = new NumberFormatException
		val cf = new CompletableFuture<String>
		val after = cf.then [success.set(false)]
		assertFalse("Then should not create a completed future", after.done)
		
		cf.completeExceptionally(expected)
		assertTrue("Then handler should not be called on failure", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(expected.class))
		after.join
	}
	
	@Test def void testThenAcceptErrorAfterCompletion() {
		val success = new AtomicBoolean(true)
		val expected = new NumberFormatException
		val cf = new CompletableFuture<String>
		cf.completeExceptionally(expected)
		val after = cf.then [success.set(false)]
		
		assertTrue("Then handler should not be called on failure", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(expected.class))
		after.join
	}
	
	/////////////////////
	// then -> thenRun //
	/////////////////////
	
	
	@Test(expected = NullPointerException) def void testThenRunFutNull() {
		val CompletableFuture<String> cf = null
		val ()=>void handler = [] 
		cf.then(handler)
	}
	
	@Test(expected = NullPointerException) def void testThenRunHandlerNull() {
		val cf = new CompletableFuture<String>
		val ()=>void handler = null
		cf.then(handler)
	}
	
	@Test def void testThenRunSuccess() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val after = cf.then [|success.set(true)]
		assertFalse("Then should not create a completed future", after.done)
		
		cf.complete("foo")
		after.get  // must not throw exception
		assertTrue("Then handler must be called.", success.get)		
	}
	
	@Test def void testThenRunySuccessThrowing() {
		val cf = new CompletableFuture<String>
		val ()=>void handler = [
			throw new NullPointerException
		]
		val after = cf.then(handler)
		assertFalse("Then should not create a completed future", after.done)
		
		cf.complete("foo")
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testThenRunySuccessThrowingAfterCompletion() {
		val cf = new CompletableFuture<String>
		val ()=>void handler = [
			throw new NullPointerException
		]
		cf.complete("foo")
		val after = cf.then(handler)
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testThenRunSuccessAfterCompletion() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		cf.complete("foo")
		val after = cf.then [|success.set(true)]
		
		after.get // must not throw exception
		assertTrue("Then handler must be called.", success.get)	
	}
	
	@Test def void testThenRunError() {
		val success = new AtomicBoolean(true)
		val expected = new NumberFormatException
		val cf = new CompletableFuture<String>
		val after = cf.then [|success.set(false)]
		assertFalse("Then should not create a completed future", after.done)
		
		cf.completeExceptionally(expected)
		assertTrue("Then handler should not be called on failure", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(expected.class))
		after.join
	}
	
	@Test def void testThenRunErrorAfterCompletion() {
		val success = new AtomicBoolean(true)
		val expected = new NumberFormatException
		val cf = new CompletableFuture<String>
		cf.completeExceptionally(expected)
		val after = cf.then [|success.set(false)]
		
		assertTrue("Then handler should not be called on failure", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(expected.class))
		after.join
	}
	
	///////////////////
	// whenCancelled //
	///////////////////
	
	@Test(expected = NullPointerException) def void testWhenCancelledNull() {
		val CompletableFuture<String> cf = null
		val ()=>void handler = [] 
		cf.whenCancelled(handler)
	}
	
	@Test def void testWhenCancelledOnSuccess() {
		var expected = "foo"
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		val after = cf.whenCancelled[success.set(false)]
		assertFalse("whenCancelled should not create a completed future", after.done)
		cf.complete(expected)
		
		after.join // must not throw exception
		assertTrue("Then handler only be called on cancellation", success.get)
		assertSame("Result of whenCancelled should contain input result", expected, after.get)
	}
	
	@Test def void testWhenCancelledOnSomeException() {
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		val after = cf.whenCancelled[success.set(false)]
		assertFalse("whenCancelled should not create a completed future", after.done)
		cf.completeExceptionally(new NullPointerException)
		
		assertTrue("Then handler should be called on cancellation", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testWhenCancelledOnCancellation() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val after = cf.whenCancelled [|success.set(true)]
		assertFalse("whenCancelled should not create a completed future", after.done)
		
		cf.cancel(false)
		assertTrue("Then handler must be called.", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(CancellationException))
		after.join
	}
	
	@Test def void testWhenCancelledOnSuccessAfterCompletion() {
		var expected = "foo"
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		
		cf.complete(expected)
		val after = cf.whenCancelled[success.set(false)]
		
		after.join // must not throw exception
		assertTrue("Then handler only be called on cancellation", success.get)
		assertSame("Result of whenCancelled should contain input result", expected, after.get)
	}
	
	@Test def void testWhenCancelledOnSomeExceptionAfterCompletion() {
		val success = new AtomicBoolean(true)
		
		val cf = new CompletableFuture<String>
		cf.completeExceptionally(new NullPointerException)
		val after = cf.whenCancelled[success.set(false)]
		
		assertFalse("Future result of whenCancelled should not be cancelled", after.isCancelled)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testWhenCancelledOnCancellationAfterCompletion() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		
		cf.cancel(false)
		val after = cf.whenCancelled [|success.set(true)]
		
		assertTrue("Then handler must be called.", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(CancellationException))
		after.join
	}
	
	///////////////////
	// whenException //
	///////////////////
	
	@Test(expected = NullPointerException) def void testWhenExceptionNullFuture() {
		val CompletableFuture<String> cf = null
		val (Throwable)=>void handler = [] 
		cf.whenException(handler)
	}
	
	@Test(expected = NullPointerException) def void testWhenExceptionNullHandler() {
		val cf = new CompletableFuture<String>
		cf.whenException(null)
	}
	
	@Test def void testWhenExceptionOnSuccess() {
		var expected = "foo"
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		val after = cf.whenException[success.set(false)]
		assertFalse("whenException should not create a completed future", after.done)
		cf.complete(expected)
		
		after.join // must not throw exception
		assertTrue("Then handler only be called on exception", success.get)
		assertSame("Result of whenException should contain input result", expected, after.get)
	}
	
	@Test def void testWhenExceptionOnException() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val after = cf.whenException[success.set(true)]
		assertFalse("whenException should not create a completed future", after.done)
		cf.completeExceptionally(new NullPointerException)
		
		assertTrue("Then handler should be called on exception", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testWhenExceptionOnExceptionThrowing() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val after = cf.whenException[
			success.set(true)
			throw new IllegalStateException
		]
		assertFalse("whenException should not create a completed future", after.done)
		cf.completeExceptionally(new NullPointerException)
		
		assertTrue("Then handler should be called on exception", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testWhenExceptionOnCancellation() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val after = cf.whenException [success.set(true)]
		assertFalse("whenException should not create a completed future", after.done)
		
		cf.cancel(false)
		assertTrue("Then handler must be called.", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(CancellationException))
		after.join
	}
	
	@Test def void testWhenExceptionOnSuccessAfterCompletion() {
		var expected = "foo"
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		
		cf.complete(expected)
		val after = cf.whenException[success.set(false)]
		
		after.join // must not throw exception
		assertTrue("Then handler only be called on exception", success.get)
		assertSame("Result of whenException should contain input result", expected, after.get)
	}
	
	@Test def void testWhenExceptionOnExceptionAfterCompletion() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		cf.completeExceptionally(new NullPointerException)
		val after = cf.whenException[success.set(true)]
		
		assertTrue("Then handler should be called on exception", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testWhenExceptionOnCancellationAfterCompletion() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		
		cf.cancel(false)
		val after = cf.whenException [success.set(true)]
		
		assertTrue("Then handler must be called.", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(CancellationException))
		after.join
	}
	
	////////////////////////
	// exceptionallyAsync //
	////////////////////////
	
	@Test(expected = NullPointerException) def void testExceptionallyAsyncNullFuture() {
		exceptionallyAsync(null,[])
	}
	
	@Test(expected = NullPointerException) def void testExceptionallyAsyncNullHandler() {
		val cf = new CompletableFuture<String>
		cf.exceptionallyAsync(null)
	}
	
	@Test def void testExceptionallyAsyncOnSuccess() {
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		val result = cf.exceptionallyAsync[
			success.set(false)
			""
		]
		assertFalse("whenException should not create a completed future", result.done)
		val expected = "baz"
		cf.complete(expected)
		
		val resultVal = result.get // must not fail
		assertTrue("Handler should not be called on success.", success.get)
		assertSame("Result of exceptionallyAsync should have ", expected, resultVal)
	}
	
	@Test def void testExceptionallyAsyncOnSuccessAfterCompletion() {
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		val expected = "baz"
		cf.complete(expected)
		val result = cf.exceptionallyAsync[
			success.set(false)
			""
		]
		
		val resultVal = result.get // must not fail
		assertTrue("Handler should not be called on success.", success.get)
		assertSame("Result of exceptionallyAsync should have ", expected, resultVal)
	}
	
	@Test def void testExceptionallyAsyncOnException() {
		val cf = new CompletableFuture<String>
		val expected = "baz"
		val result = cf.exceptionallyAsync[expected]
		assertFalse("whenException should not create a completed future", result.done)
		cf.completeExceptionally(new ArithmeticException)
		
		val resultVal = result.get // must not fail
		assertSame("Result of exceptionallyAsync should have ", expected, resultVal)
	}
	
	@Test def void testExceptionallyAsyncOnExceptionAfterCompletion() {
		val cf = new CompletableFuture<String>
		val expected = "baz"
		cf.completeExceptionally(new ArithmeticException)
		val result = cf.exceptionallyAsync[expected]
		
		val resultVal = result.get // must not fail
		assertSame("Result of exceptionallyAsync should have ", expected, resultVal)
	}
	
	@Test def void testExceptionallyAsyncOnCancellation() {
		val success = new AtomicBoolean(true)
		val expected = "baz"
		val cf = new CompletableFuture<String>
		val result = cf.exceptionallyAsync[expected]
		assertFalse("whenException should not create a completed future", result.done)
		cf.cancel(true)
		
		val resultVal = result.get // must not fail
		assertTrue("Handler should not be called on success.", success.get)
		assertSame("Result of exceptionallyAsync should have ", expected, resultVal)
	}
	
	@Test def void testExceptionallyAsyncOnCancellationAfterCompletion() {
		val success = new AtomicBoolean(true)
		val expected = "baz"
		val cf = new CompletableFuture<String>
		cf.cancel(true)
		val result = cf.exceptionallyAsync[expected]
		
		val resultVal = result.get // must not fail
		assertTrue("Handler should not be called on success.", success.get)
		assertSame("Result of exceptionallyAsync should have ", expected, resultVal)
	}
	
	
	/////////////////////
	// cancelOnTimeout //
	/////////////////////
	
	@Test(expected = NullPointerException) def void testCancelOnTimeoutNullFuture() {
		cancelOnTimeout(null, 10, TimeUnit.MILLISECONDS)
	}
	
	@Test(expected = NullPointerException) def void testCancelOnTimeoutNullTimeUnit() {
		val cf = new CompletableFuture<String>
		cf.cancelOnTimeout(10, null)
	}
	
	@Test def void testCancelOnTimeoutOnCompletedSuccess() {
		val cf = new CompletableFuture<String>
		val expected = "foo"
		cf.complete(expected)
		cf.cancelOnTimeout(1, TimeUnit.MILLISECONDS)
		Thread.sleep(2)
		val result = cf.get
		assertSame("When calling cancelOnTimeout on completed future, should have no effect", expected, result)
	}
	
	@Test def void testCancelOnTimeoutOnCompletedExceptionally() {
		val cf = new CompletableFuture<String>
		val expected = new IllegalStateException
		cf.completeExceptionally(expected)
		cf.cancelOnTimeout(1, TimeUnit.MILLISECONDS)
		Thread.sleep(2)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(IllegalStateException))
		cf.join
	}
	
	@Test def void testCancelOnTimeoutReturnSelf() {
		val cf = new CompletableFuture<String>
		val result = cf.cancelOnTimeout(2, TimeUnit.MILLISECONDS)
		assertSame("cancelOnTimeout must return self future", cf, result)
	}
	
	@Test def void testCancelOnTimeoutOnTimeOut() {
		val cf = new CompletableFuture<String>
		cf.cancelOnTimeout(10, TimeUnit.MILLISECONDS)
		thrown.expect(CancellationException)
		cf.get(15, TimeUnit.MILLISECONDS)
	}
	
	@Test def void testCancelOnTimeoutResultBeforeTimeout() {
		val cf = new CompletableFuture<String>
		cf.cancelOnTimeout(10, TimeUnit.MILLISECONDS)
		val expected = "foo"
		cf.complete(expected)
		Thread.sleep(15)
		val actual = cf.get
		assertSame("Expecting set result, no timeout.", expected, actual)
	}
	
	//////////////////////////
	// cancelOnTimeoutAsync //
	//////////////////////////
	
	@Test(expected = NullPointerException) def void testCancelOnTimeoutSchedulerNullFuture() {
		val pool = Executors.newScheduledThreadPool(0)
		cancelOnTimeout(null, pool, 10, TimeUnit.MILLISECONDS)
	}
	
	@Test(expected = NullPointerException) def void testCancelOnTimeoutSchedulerNullTimeUnit() {
		val pool = Executors.newScheduledThreadPool(0)
		val cf = new CompletableFuture<String>
		cf.cancelOnTimeout(pool, 10, null)
	}
	
	@Test(expected = NullPointerException) def void testCancelOnTimeoutSchedulerNullScheduler() {
		val cf = new CompletableFuture<String>
		cf.cancelOnTimeout(null, 10, TimeUnit.MILLISECONDS)
	}
	
	@Test def void testCancelOnTimeout() {
		val success = new AtomicBoolean(false)
		val thread = new AtomicReference<Thread>
		val cf = new CompletableFuture<String>
		val pool = new ScheduledThreadPoolExecutor(0)[r| 
			success.set(true)
			val t = new Thread(r)
			thread.set(t)
			t
		]
		// unfortunately we cannot check if cancellation is actually performed on pooled thread.
		cf.cancelOnTimeout(pool, 1, TimeUnit.MILLISECONDS)
		Thread.sleep(2)
		assertTrue("cancelOnTimeout must use the provided Thread", success.get)
	}
	
	@Test def void testCancelOnTimeoutScheduledReturnSelf() {
		val pool = Executors.newScheduledThreadPool(0)
		val cf = new CompletableFuture<String>
		val result = cf.cancelOnTimeout(pool, 2, TimeUnit.MILLISECONDS)
		assertSame("cancelOnTimeout must return self future", cf, result)
	}
	
	@Test def void testCancelOnTimeoutScheduledOnTimeOut() {
		val pool = Executors.newScheduledThreadPool(0)
		val cf = new CompletableFuture<String>
		cf.cancelOnTimeout(pool, 10, TimeUnit.MILLISECONDS)
		thrown.expect(CancellationException)
		cf.get(15, TimeUnit.MILLISECONDS)
	}
	
	@Test def void testCancelOnTimeoutResultScheduledBeforeTimeout() {
		val pool = Executors.newScheduledThreadPool(0)
		val cf = new CompletableFuture<String>
		cf.cancelOnTimeout(pool, 100, TimeUnit.MILLISECONDS)
		val expected = "foo"
		cf.complete(expected)
		Thread.sleep(200)
		val actual = cf.get
		assertSame("Expecting set result, no timeout.", expected, actual)
	}
	
	///////////////
	// forwardTo //
	///////////////
	
	@Test(expected=NullPointerException) def void testForwardToFutNull() {
		val cf = new CompletableFuture<String>
		forwardTo(null, cf)
	}
	
	@Test(expected=NullPointerException) def void testForwardToNullTo() {
		val cf = new CompletableFuture<String>
		forwardTo(null, cf)
	}
	
	@Test def void testForwardToSuccess() {
		val cf = new CompletableFuture<String>
		val to = new CompletableFuture<String>
		cf.forwardTo(to)
		assertFalse("whenException should not complete to future when source not completed", to.done)
		
		val expected = "zoo"
		cf.complete(expected)
		val actual = to.get
		assertSame("Forwarding should spit out same ouput as was input", expected, actual)
	}
	
	@Test def void testForwardToSuccessAfterCompletion() {
		val cf = new CompletableFuture<String>
		val to = new CompletableFuture<String>
		
		val expected = "zoo"
		cf.complete(expected)
		cf.forwardTo(to)

		val actual = to.get
		assertSame("Forwarding should spit out same ouput as was input", expected, actual)
	}
	
	@Test def void testForwardToException() {
		val cf = new CompletableFuture<String>
		val to = new CompletableFuture<String>
		cf.forwardTo(to)
		assertFalse("whenException should not complete to future when source not completed", to.done)
		
		val expected = new ConcurrentModificationException
		cf.completeExceptionally(expected)
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(expected.class))
		to.join
	}
	
	@Test def void testForwardToExceptionAfterCompletion() {
		val cf = new CompletableFuture<String>
		val to = new CompletableFuture<String>
		
		val expected = new ConcurrentModificationException
		cf.completeExceptionally(expected)
		cf.forwardTo(to)
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(expected.class))
		to.join
	}
	
	@Test def void testForwardToCancellation() {
		val cf = new CompletableFuture<String>
		val to = new CompletableFuture<String>
		cf.forwardTo(to)
		assertFalse("forwardTo should not complete to future when source not completed", to.done)
		
		cf.cancel(false)
		
		thrown.expect(CancellationException)
		to.join
	}
	
	@Test def void testForwardToCancellationAfterCompletion() {
		val cf = new CompletableFuture<String>
		val to = new CompletableFuture<String>
		
		cf.cancel(false)
		cf.forwardTo(to)
		
		thrown.expect(CancellationException)
		to.join
	}
	
	@Test def void testForwardToDoNotForwardToCompleted() {
		val cf = new CompletableFuture<String>
		val to = new CompletableFuture<String>
		val expected = "roo"
		to.complete(expected)
		cf.forwardTo(to)
		
		cf.complete("Not what we expect")
		
		val actual = to.join
		assertSame("", expected, actual)
	}
	
	/////////////////////////
	// forwardCancellation //
	/////////////////////////
	
	@Test(expected = NullPointerException) def void testForwardCancellationNullFrom() {
		val cf = new CompletableFuture<String>
		forwardCancellation(null, cf)
	}
	
	@Test(expected = NullPointerException) def void testForwardCancellationNullTo() {
		val cf = new CompletableFuture<String>
		cf.forwardCancellation(null)
	}
	
	@Test def void testForwardCancellationOnCancellation() {
		val cf = new CompletableFuture<String>
		val receiver = new CompletableFuture<String>
		cf.forwardCancellation(receiver)
		cf.cancel(false)
		assertTrue("Cancellation should be forwarded", receiver.isCancelled)
	}
	
	@Test def void testForwardCancellationOnCancellationAfterCompletion() {
		val cf = new CompletableFuture<String>
		val receiver = new CompletableFuture<String>
		cf.cancel(false)
		cf.forwardCancellation(receiver)
		assertTrue("Cancellation should be forwarded", receiver.isCancelled)
	}
	
	@Test def void testForwardCancellationOnSuccess() {
		val cf = new CompletableFuture<String>
		val receiver = new CompletableFuture<String>
		cf.forwardCancellation(receiver)
		cf.complete("foo")
		assertFalse("Receiver should not be completed", receiver.done)
	}
	
	@Test def void testForwardCancellationOnSuccessAfterCompletion() {
		val cf = new CompletableFuture<String>
		val receiver = new CompletableFuture<String>
		cf.complete("foo")
		cf.forwardCancellation(receiver)
		assertFalse("Receiver should not be completed", receiver.done)
	}
	
	/////////////////
	// recoverWith //
	/////////////////
	
	@Test(expected = NullPointerException) def void testRecoverWithNullFuture() {
		val cf = new CompletableFuture<String>
		recoverWith(null)[cf]
	}
	
	@Test(expected = NullPointerException) def void testRecoverWithNullRecovery() {
		val cf = new CompletableFuture<String>
		cf.recoverWith(null)
	}
	
	@Test def void testRecoverWithRecoveryReturningNull() {
		val cf = new CompletableFuture<String>
		val result = cf.recoverWith[null]
		cf.completeExceptionally(new IllegalStateException)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		result.join
	}
	
	@Test def void testRecoverWithRecoveryReturningNullAfterCompletion() {
		val cf = new CompletableFuture<String>
		cf.completeExceptionally(new IllegalStateException)
		val result = cf.recoverWith[null]
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		result.join
	}
	
	@Test def void testRecoverWithRecoveryThrowingException() {
		val cf = new CompletableFuture<String>
		val result = cf.recoverWith[throw new ArrayStoreException]
		cf.completeExceptionally(new IllegalStateException)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(ArrayStoreException))
		result.join
	}
	
	@Test def void testRecoverWithRecoveryThrowingExceptionAfterCompletion() {
		val cf = new CompletableFuture<String>
		cf.completeExceptionally(new IllegalStateException)
		val result = cf.recoverWith[throw new ArrayStoreException]
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(ArrayStoreException))
		result.join
	}
	
	@Test def void testRecoverWithRecoveryRecoverWithCompleted() {
		val cf = new CompletableFuture<String>
		val expected = "bar"
		val result = cf.recoverWith[CompletableFuture.completedFuture(expected)]
		cf.completeExceptionally(new IllegalStateException)
		val actual = result.join
		assertSame("CompletableFuture should complete with provided result", expected, actual)
	}
	
	@Test def void testRecoverWithRecoveryRecoverWithCompletedAfterCompletion() {
		val cf = new CompletableFuture<String>
		val expected = "bar"
		cf.completeExceptionally(new IllegalStateException)
		val result = cf.recoverWith[CompletableFuture.completedFuture(expected)]
		val actual = result.join
		assertSame("CompletableFuture should complete with provided result", expected, actual)
	}
	
	@Test def void testRecoverWithRecoveryRecoverWithDelay() {
		val cf = new CompletableFuture<String>
		val expected = "bar"
		val recovery = new CompletableFuture<String>
		val result = cf.recoverWith[recovery]
		cf.completeExceptionally(new IllegalStateException)
		assertFalse("When recovery is not available, result cannot be present." ,result.isDone)
		recovery.complete(expected)
		val actual = result.join
		assertSame("CompletableFuture should complete with provided result", expected, actual)
	}
	
	@Test def void testRecoverWithRecoveryRecoverWithDelayAfterCompletion() {
		val cf = new CompletableFuture<String>
		val expected = "bar"
		val recovery = new CompletableFuture<String>
		cf.completeExceptionally(new IllegalStateException)
		val result = cf.recoverWith[recovery]
		assertFalse("When recovery is not available, result cannot be present." ,result.isDone)
		recovery.complete(expected)
		val actual = result.join
		assertSame("CompletableFuture should complete with provided result", expected, actual)
	}
	
	////////////////////////////
	// whenCancelledInterrupt //
	////////////////////////////
	
	@Test(expected = NullPointerException) def void testWhenCancelledInterruptFutNull() {
		whenCancelledInterrupt(null, [])
	}
	
	@Test(expected = NullPointerException) def void testWhenCancelledInterruptHandlerNull() {
		val cf = new CompletableFuture<String>
		cf.whenCancelledInterrupt(null)
	}
	
	@Test def void testWhenCancelledInterruptDoCancel() {
		val cf = new CompletableFuture<String>
		val success = new AtomicBoolean(false)
		cf.cancel(false)
		cf.whenCancelledInterrupt [
			success.set(Thread::interrupted)
		]
		assertFalse("Thread should not be interrupted after block", Thread::interrupted)
		assertTrue("Cancellation should interrupt the current Thread", success.get)
	}
	
	@Test def void testWhenCancelledInterruptNoCancel() {
		val cf = new CompletableFuture<String>
		val success = new AtomicBoolean(true)
		cf.whenCancelledInterrupt [
			success.set(!Thread::interrupted)
		]
		assertFalse("Thread should not be interrupted after block", Thread::interrupted)
		assertTrue("No cancellation should not cause interrupt the current Thread in block", success.get)
	}
	
	@Test def void testWhenCancelledInterruptCancelAfterBlock() {
		val cf = new CompletableFuture<String>
		val success = new AtomicBoolean(true)
		cf.whenCancelledInterrupt [
			success.set(!Thread::interrupted)
		]
		cf.cancel(false)
		assertFalse("Thread should not be interrupted on cancellation after block", Thread::interrupted)
		assertTrue("Cancellation should interrupt the current Thread in block", success.get)
	}
	
	////////////////////////
	// handleCancellation //
	////////////////////////
	
	@Test(expected = NullPointerException) def void testHandleCancellationNullFut() {
		handleCancellation(null,[])
	}
	
	@Test(expected = NullPointerException) def void testHandleCancellationNullHandler() {
		val cf = new CompletableFuture<String>
		cf.handleCancellation(null)
	}
	
	@Test def void testHandleCancellationOnSuccess() {
		val expected = "zoo"
		val cf = new CompletableFuture<String>
		val success = new AtomicBoolean(true)
		val result = cf.handleCancellation[
			success.set(false)
			throw new IllegalStateException
		]
		cf.complete(expected)
		val actual = result.get // must not fail
		
		assertTrue("Handler must not be called on successful call.", success.get)
		assertSame("The result is expected the forwarded successful result.", expected, actual)
	}
	
	@Test def void testHandleCancellationOnError() {
		val cf = new CompletableFuture<String>
		val success = new AtomicBoolean(true)
		val result = cf.handleCancellation[
			success.set(false)
			throw new IllegalStateException
		]
		cf.completeExceptionally(new ArrayStoreException)
		
		assertTrue("Handler must not be called on successful call.", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(ArrayStoreException))
		result.join // must not fail
	}
	
	@Test def void testHandleCancellationOnCancellation() {
		val cf = new CompletableFuture<String>
		val expected = "hui-buh"
		val result = cf.handleCancellation[expected]
		cf.cancel(false)
		
		val actual = result.get // must not fail
		
		assertSame("The result is expected holding the handler provided value.", expected, actual)
	}
	
	@Test def void testCopyFutureNonCompleted() {
		val fut = new CompletableFuture<Integer>
		val fut2 = fut.copy
		
		assertFalse(fut2.done)
		fut.complete(2)
		
		assertEquals(2, fut2.get)
	}
	
	@Test def void testCopyFutureCompleted() {
		val fut = new CompletableFuture<Integer>
		fut.complete(2)
		
		val fut2 = fut.copy
		
		assertEquals(2, fut.get)
		assertEquals(2, fut2.get)
	}
	
	// TODO test withTimeout
	// TODO test Async variants
}