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
import de.fhg.fokus.xtensions.Util
import java.util.concurrent.ExecutionException
import java.util.NoSuchElementException
import java.util.concurrent.TimeoutException
import java.util.function.Function
import java.util.function.Consumer
import java.util.concurrent.ForkJoinPool
import java.time.Duration

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
		val Function<String,String> handler = null
		cf.then(handler)
	}
	
	@Test def void testThenApplyHandlerThrowing() {
		val cf = new CompletableFuture<String>
		val Function<String,String> handler = [
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
		val Function<String,String> handler = [
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
		val Function<String,String> handler = [
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
		val Consumer<String> handler = [] 
		cf.then(handler)
	}
	
	@Test(expected = NullPointerException) def void testThenAcceptHandlerNull() {
		val cf = new CompletableFuture<String>
		val Consumer<String> handler = null
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
		val Runnable handler = [] 
		cf.then(handler)
	}
	
	@Test(expected = NullPointerException) def void testThenRunHandlerNull() {
		val cf = new CompletableFuture<String>
		val Runnable handler = null
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
	
	@Test def void testThenRunSuccessThrowing() {
		val cf = new CompletableFuture<String>
		val Runnable handler = [
			throw new NullPointerException
		]
		val after = cf.then(handler)
		assertFalse("Then should not create a completed future", after.done)
		
		cf.complete("foo")
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testThenRunSuccessThrowingAfterCompletion() {
		val cf = new CompletableFuture<String>
		val Runnable handler = [
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
		val Runnable handler = [] 
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
	
	////////////////////////
	// whenCancelledAsync //
	////////////////////////
	
	@Test(expected = NullPointerException) def void testWhenCancelledAsyncNull() {
		val CompletableFuture<String> cf = null
		val Runnable handler = [] 
		cf.whenCancelledAsync(handler)
	}
	
	@Test def void testWhenCancelledAsyncOnSuccess() {
		var expected = "foo"
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		
		val after = cf.whenCancelledAsync [
			success.set(false)
		]
		assertFalse("whenCancelled should not create a completed future", after.done)
		cf.complete(expected)
		
		after.join // must not throw exception
		assertTrue("Then handler only be called on cancellation", success.get)
		assertSame("Result of whenCancelled should contain input result", expected, after.get)
	}
	
	@Test def void testWhenCancelledAsnycOnSomeException() {
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		val after = cf.whenCancelledAsync[success.set(false)]
		assertFalse("whenCancelled should not create a completed future", after.done)
		cf.completeExceptionally(new NullPointerException)
		
		assertTrue("Then handler should be called on cancellation", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testWhenCancelledAsyncOnCancellation() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val outerThread = Thread.currentThread
		val pool = new ForkJoinPool
		val after = cf.whenCancelledAsync(pool) [|
			assertNotSame(outerThread, Thread.currentThread)
			success.set(true)
		]
		assertFalse("whenCancelled should not create a completed future", after.done)
		
		cf.cancel(false)
		val ex = Util.expectException(CompletionException) [
			after.join
		]
		assertThat(ex.cause, instanceOf(CancellationException))
		assertTrue("Then handler must be called.", success.get)
	}
	
	@Test def void testWhenCancelledAsyncOnSuccessAfterCompletion() {
		var expected = "foo"
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		
		cf.complete(expected)
		val after = cf.whenCancelledAsync[success.set(false)]
		
		after.join // must not throw exception
		assertTrue("Then handler only be called on cancellation", success.get)
		assertSame("Result of whenCancelled should contain input result", expected, after.get)
	}
	
	@Test def void testWhenCancelledAsyncOnSomeExceptionAfterCompletion() {
		val success = new AtomicBoolean(true)
		
		val cf = new CompletableFuture<String>
		cf.completeExceptionally(new NullPointerException)
		val after = cf.whenCancelledAsync[success.set(false)]
		
		assertFalse("Future result of whenCancelled should not be cancelled", after.isCancelled)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		after.join
	}
	
	@Test def void testWhenCancelledAsyncOnCancellationAfterCompletion() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val outerThread = Thread.currentThread
		val pool = new ForkJoinPool
		
		cf.cancel(false)
		val after = cf.whenCancelledAsync(pool) [|
			assertNotSame(outerThread,Thread.currentThread)
			success.set(true)
		]
		val ex = Util.expectException(ExecutionException) [
			after.get
		]
		assertThat(ex.cause, instanceOf(CancellationException))
		assertTrue("Then handler must be called.", success.get)
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
	// whenExceptionAsync //
	////////////////////////
	
	@Test(expected = NullPointerException) def void testWhenExceptionAsyncNullFuture() {
		val CompletableFuture<String> cf = null
		val (Throwable)=>void handler = [] 
		cf.whenExceptionAsync(handler)
	}
	
	@Test(expected = NullPointerException) def void testWhenExceptionAsyncWithExecutorNullFuture() {
		val CompletableFuture<String> cf = null
		val pool = ForkJoinPool.commonPool
		val (Throwable)=>void handler = [] 
		cf.whenExceptionAsync(pool,handler)
	}
	
	@Test(expected = NullPointerException) def void testWhenExceptionAsyncNullHandler() {
		val cf = new CompletableFuture<String>
		cf.whenExceptionAsync(null)
	}
	
	@Test(expected = NullPointerException) def void testWhenExceptionAsyncWithExecutorNullHandler() {
		val cf = new CompletableFuture<String>
		val pool = ForkJoinPool.commonPool
		cf.whenExceptionAsync(pool,null)
	}
	
	@Test(expected = NullPointerException) def void testWhenExceptionAsyncWithExecutorNullExecutor() {
		val cf = new CompletableFuture<String>
		val pool = null
		cf.whenExceptionAsync(pool,[])
	}
	
	@Test def void testWhenExceptionAsyncOnSuccess() {
		var expected = "foo"
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		val pool = Executors.newCachedThreadPool
		val outerThread = Thread.currentThread
		val after = cf.whenExceptionAsync(pool)[
			assertNotSame(outerThread, Thread.currentThread)
			success.set(false)
		]
		assertFalse("whenException should not create a completed future", after.done)
		cf.complete(expected)
		
		after.join // must not throw exception
		assertTrue("Then handler only be called on exception", success.get)
		assertSame("Result of whenException should contain input result", expected, after.get)
	}
	
	@Test def void testWhenExceptionAsyncOnException() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val pool = Executors.newCachedThreadPool
		val outerThread = Thread.currentThread
		val after = cf.whenExceptionAsync(pool)[
			assertNotSame(outerThread, Thread.currentThread)
			success.set(true)
		]
		assertFalse("whenException should not create a completed future", after.done)
		cf.completeExceptionally(new NullPointerException)
		
		val ex = Util.expectException(CompletionException) [
			after.join
		]
		assertTrue(ex.cause instanceof NullPointerException)
		assertTrue("Then handler should be called on exception", success.get)
	}
	
	@Test def void testWhenExceptionOnExceptionAsyncThrowing() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val outerThread = Thread.currentThread
		val pool = Executors.newCachedThreadPool
		val after = cf.whenExceptionAsync(pool)[
			assertNotSame(outerThread, Thread.currentThread)
			success.set(true)
			throw new IllegalStateException
		]
		assertFalse("whenException should not create a completed future", after.done)
		cf.completeExceptionally(new NullPointerException)
		
		val ex = Util.expectException(CompletionException) [
			after.join
		]
		assertTrue("Expected cause to be NullPointerException",ex.cause instanceof NullPointerException)
		assertTrue("Then handler should be called on exception", success.get)
	}
	
	@Test def void testWhenExceptionAsyncOnCancellation() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val outerThread = Thread.currentThread
		val pool = Executors.newCachedThreadPool
		val after = cf.whenExceptionAsync(pool) [
			assertNotSame(outerThread, Thread.currentThread)
			success.set(true)
		]
		
		assertFalse("whenException should not create a completed future", after.done)
		cf.cancel(false)
		val ex = Util.expectException(CompletionException) [
			after.join
		]
		assertTrue("Expected cause to be CancellationException", ex.cause instanceof CancellationException)
		assertTrue("Then handler must be called.", success.get)
	}
	
	@Test def void testWhenExceptionAsyncOnSuccessAfterCompletion() {
		var expected = "foo"
		val success = new AtomicBoolean(true)
		val cf = new CompletableFuture<String>
		
		cf.complete(expected)
		val after = cf.whenExceptionAsync[success.set(false)]
		
		after.join // must not throw exception
		assertTrue("Then handler only be called on exception", success.get)
		assertSame("Result of whenException should contain input result", expected, after.get)
	}
	
	@Test def void testWhenExceptionOnExceptionAsyncAfterCompletion() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		cf.completeExceptionally(new NullPointerException)
		val pool = Executors.newCachedThreadPool
		val outerThread = Thread.currentThread
		val after = cf.whenExceptionAsync(pool)[
			assertNotSame(outerThread, Thread.currentThread)
			success.set(true)
		]
		
		val ex = Util.expectException(CompletionException) [
			after.join
		]
		assertTrue("Expected cause to be NullPointerException", ex.cause instanceof NullPointerException)
		assertTrue("Then handler should be called on exception", success.get)
	}
	
	@Test def void testWhenExceptionAsyncOnCancellationAfterCompletion() {
		val success = new AtomicBoolean(false)
		val cf = new CompletableFuture<String>
		val pool = Executors.newCachedThreadPool
		val outerThread = Thread.currentThread
		
		cf.cancel(false)
		val after = cf.whenExceptionAsync(pool) [
			assertNotSame(outerThread, Thread.currentThread)
			success.set(true)
		]
		
		val ex = Util.expectException(CompletionException) [
			after.join
		]
		assertTrue("Expected cause to be CancellationException", ex.cause instanceof CancellationException)
		assertTrue("Then handler must be called.", success.get)
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
		val expectedException = new ArithmeticException
		val outerThread = Thread.currentThread
		val pool = new ForkJoinPool
		val result = cf.exceptionallyAsync(pool) [
			assertSame(it, expectedException)
			assertNotSame(outerThread, Thread.currentThread)
			expected
		]
		assertFalse("whenException should not create a completed future", result.done)
		cf.completeExceptionally(expectedException)
		
		val resultVal = result.get // must not fail
		assertSame("Result of exceptionallyAsync should have ", expected, resultVal)
	}
	
	@Test def void testExceptionallyAsyncOnExceptionAfterCompletion() {
		val cf = new CompletableFuture<String>
		val expected = "baz"
		val expectedException = new ArithmeticException
		val outerThread = Thread.currentThread
		cf.completeExceptionally(expectedException)
		val pool = new ForkJoinPool
		
		val result = cf.exceptionallyAsync(pool) [
			assertSame(it, expectedException)
			assertNotSame(outerThread, Thread.currentThread)
			expected
		]
		
		val resultVal = result.get // must not fail
		assertSame("Result of exceptionallyAsync should have ", expected, resultVal)
	}
	
	@Test def void testExceptionallyAsyncOnCancellation() {
		val success = new AtomicBoolean(true)
		val expected = "baz"
		val outerThread = Thread.currentThread
		val cf = new CompletableFuture<String>
		val pool = new ForkJoinPool
		
		val result = cf.exceptionallyAsync(pool) [
			assertNotSame(outerThread, Thread.currentThread)
			expected
		]
		assertFalse("whenException should not create a completed future", result.done)
		cf.cancel(true)
		
		val resultVal = result.get // must not fail
		assertTrue("Handler should not be called on success.", success.get)
		assertSame("Result of exceptionallyAsync should have ", expected, resultVal)
	}
	
	@Test def void testExceptionallyAsyncOnCancellationAfterCompletion() {
		val success = new AtomicBoolean(true)
		val expected = "baz"
		val outerThread = Thread.currentThread
		val cf = new CompletableFuture<String>
		cf.cancel(true)
		val pool = new ForkJoinPool
		
		val result = cf.exceptionallyAsync(pool) [
			assertNotSame(outerThread, Thread.currentThread)
			expected
		]
		
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
		cf.get(50, TimeUnit.MILLISECONDS)
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
	
	/////////////////////////////
	// cancelOnTimeoutDuration //
	/////////////////////////////
	
	@Test(expected = NullPointerException) def void testCancelOnTimeoutDurationNullFuture() {
		cancelOnTimeout(null, Duration.ofSeconds(10))
	}
	
	@Test def void testCancelOnTimeoutDurationOnCompletedSuccess() {
		val cf = new CompletableFuture<String>
		val expected = "foo"
		cf.complete(expected)
		cf.cancelOnTimeout(Duration.ofMillis(1))
		Thread.sleep(2)
		val result = cf.get
		assertSame("When calling cancelOnTimeout on completed future, should have no effect", expected, result)
	}
	
	@Test def void testCancelOnTimeoutDurationOnCompletedExceptionally() {
		val cf = new CompletableFuture<String>
		val expected = new IllegalStateException
		cf.completeExceptionally(expected)
		cf.cancelOnTimeout(Duration.ofMillis(2))
		Thread.sleep(2)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(IllegalStateException))
		cf.join
	}
	
	@Test def void testCancelOnTimeoutDurationReturnSelf() {
		val cf = new CompletableFuture<String>
		val result = cf.cancelOnTimeout(Duration.ofMillis(2))
		assertSame("cancelOnTimeout must return self future", cf, result)
	}
	
	@Test def void testCancelOnTimeoutDurationOnTimeOut() {
		val cf = new CompletableFuture<String>
		cf.cancelOnTimeout(Duration.ofMillis(10))
		thrown.expect(CancellationException)
		cf.get(50, TimeUnit.MILLISECONDS)
	}
	
	@Test def void testCancelOnTimeoutDurationResultBeforeTimeout() {
		val cf = new CompletableFuture<String>
		cf.cancelOnTimeout(Duration.ofMillis(10))
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
	
	@Test def void testCancelOnTimeoutOnCompleted() {
		val pool = Executors.newScheduledThreadPool(0)
		val cf = CompletableFuture.completedFuture("foo")
		cf.cancelOnTimeout(pool, 2, TimeUnit.MILLISECONDS)
		Thread.sleep(10)
		assertFalse(cf.isCancelled)
		assertFalse(cf.isCompletedExceptionally)
		assertTrue(cf.done)
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
		
		assertTrue(to.cancelled)
		thrown.expect(CancellationException)
		to.join
	}
	
	@Test def void testForwardToCancellationAfterCompletion() {
		val cf = new CompletableFuture<String>
		val to = new CompletableFuture<String>
		
		cf.cancel(false)
		cf.forwardTo(to)
		
		assertTrue(to.cancelled)
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
	
	@Test(timeout=1000) def void testRecoverWithNothingToRecover() {
		val cf = new CompletableFuture<String>
		val expected = "bar"
		val result = cf.recoverWith[fail()null]
		cf.complete(expected)
		val actual = result.join
		assertSame("CompletableFuture should complete with provided result", expected, actual)
	}
	
	//////////////////////
	// recoverWithAsync //
	//////////////////////
	
	@Test(expected = NullPointerException) def void testRecoverWithAsyncNullFuture() {
		val cf = new CompletableFuture<String>
		recoverWithAsync(null)[cf]
	}
	
	@Test(expected = NullPointerException) def void testRecoverWithAsyncNullRecovery() {
		val cf = new CompletableFuture<String>
		cf.recoverWithAsync(null)
	}
	
	@Test def void testRecoverWithAsyncRecoveryReturningNull() {
		val cf = new CompletableFuture<String>
		val outerThread = Thread.currentThread
		val pool = new ForkJoinPool
		
		val result = cf.recoverWithAsync(pool)[
			assertNotSame(outerThread, Thread.currentThread)
			null
		]
		
		cf.completeExceptionally(new IllegalStateException)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		result.join
	}
	
	@Test def void testRecoverWithAsnyRecoveryReturningNullAfterCompletion() {
		val cf = new CompletableFuture<String>
		cf.completeExceptionally(new IllegalStateException)
		val outerThread = Thread.currentThread
		val pool = new ForkJoinPool
		
		val result = cf.recoverWithAsync(pool) [
			assertNotSame(outerThread, Thread.currentThread)
			null
		]
		
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(NullPointerException))
		result.join
	}
	
	@Test def void testRecoverWithAsnycRecoveryThrowingException() {
		val cf = new CompletableFuture<String>
		val outerThread = Thread.currentThread
		val pool = new ForkJoinPool
		
		val result = cf.recoverWithAsync(pool)[
			assertNotSame(outerThread, Thread.currentThread)
			throw new ArrayStoreException
		]
		
		cf.completeExceptionally(new IllegalStateException)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(ArrayStoreException))
		result.join
	}
	
	@Test def void testRecoverWithAsyncRecoveryRecoverWithCompleted() {
		val cf = new CompletableFuture<String>
		val expected = "bar"
		val outerThread = Thread.currentThread
		val pool = new ForkJoinPool
		
		val result = cf.recoverWithAsync(pool)[
			assertNotSame(outerThread, Thread.currentThread)
			CompletableFuture.completedFuture(expected)
		]
		cf.completeExceptionally(new IllegalStateException)
		val actual = result.join
		assertSame("CompletableFuture should complete with provided result", expected, actual)
	}
	
	@Test def void testRecoverWithAsyncRecoveryRecoverWithCompletedAfterCompletion() {
		val cf = new CompletableFuture<String>
		val expected = "bar"
		val outerThread = Thread.currentThread
		val pool = new ForkJoinPool
		
		cf.completeExceptionally(new IllegalStateException)
		val result = cf.recoverWithAsync(pool) [
			assertNotSame(outerThread, Thread.currentThread)
			CompletableFuture.completedFuture(expected)
		]
		
		val actual = result.join
		assertSame("CompletableFuture should complete with provided result", expected, actual)
	}
	
	@Test def void testRecoverWithAsyncRecoveryRecoverWithDelay() {
		val cf = new CompletableFuture<String>
		val expected = "bar"
		val recovery = new CompletableFuture<String>
		val outerThread = Thread.currentThread
		val pool = new ForkJoinPool
		
		val result = cf.recoverWithAsync(pool)[
			assertNotSame(outerThread, Thread.currentThread)
			recovery
		]
		cf.completeExceptionally(new IllegalStateException)
		assertFalse("When recovery is not available, result cannot be present." ,result.isDone)
		recovery.complete(expected)
		val actual = result.join
		assertSame("CompletableFuture should complete with provided result", expected, actual)
	}
	
	@Test def void testRecoverWithAsyncRecoveryRecoverWithDelayAfterCompletion() {
		val cf = new CompletableFuture<String>
		val expected = "bar"
		val recovery = new CompletableFuture<String>
		cf.completeExceptionally(new IllegalStateException)
		val outerThread = Thread.currentThread
		val pool = new ForkJoinPool
		
		val result = cf.recoverWithAsync(pool)[
			assertNotSame(outerThread, Thread.currentThread)
			recovery
		]
		
		assertFalse("When recovery is not available, result cannot be present." ,result.isDone)
		recovery.complete(expected)
		val actual = result.join
		assertSame("CompletableFuture should complete with provided result", expected, actual)
	}
	
	@Test(timeout=1000) def void testRecoverWithAsnycNothingToRecover() {
		val cf = new CompletableFuture<String>
		val expected = "bar"
		val result = cf.recoverWithAsync[fail()null]
		cf.complete(expected)
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
	
	/////////////////////////////
	// handleCancellationAsync //
	/////////////////////////////
	
	@Test(expected = NullPointerException) def void testHandleCancellationAsyncNullFut() {
		handleCancellationAsync(null,[])
	}
	
	@Test(expected = NullPointerException) def void testHandleCancellationAsyncNullHandler() {
		val cf = new CompletableFuture<String>
		cf.handleCancellationAsync(null)
	}
	
	@Test def void testHandleCancellationAsyncOnSuccess() {
		val expected = "zoo"
		val cf = new CompletableFuture<String>
		val success = new AtomicBoolean(true)
		val result = cf.handleCancellationAsync[
			success.set(false)
			throw new IllegalStateException
		]
		cf.complete(expected)
		val actual = result.get // must not fail
		
		assertTrue("Handler must not be called on successful call.", success.get)
		assertSame("The result is expected the forwarded successful result.", expected, actual)
	}
	
	@Test def void testHandleCancellationAsyncOnError() {
		val cf = new CompletableFuture<String>
		val success = new AtomicBoolean(true)
		val pool = new ForkJoinPool
		
		val result = cf.handleCancellationAsync(pool) [
			success.set(false)
			throw new IllegalStateException
		]
		cf.completeExceptionally(new ArrayStoreException)
		
		assertTrue("Handler must not be called on successful call.", success.get)
		thrown.expect(CompletionException)
		thrown.expectCause(instanceOf(ArrayStoreException))
		result.join // must not fail
	}
	
	@Test def void testHandleCancellationAsyncOnCancellation() {
		val cf = new CompletableFuture<String>
		val expected = "hui-buh"
		val pool = new ForkJoinPool
		val result = cf.handleCancellationAsync(pool) [
			expected
		]
		cf.cancel(false)
		
		val actual = result.get // must not fail
		
		assertSame("The result is expected holding the handler provided value.", expected, actual)
	}
	
	//////////
	// copy //
	//////////
	
	@Test def void testCopyFutureNonCompleted() {
		val fut = new CompletableFuture<Integer>
		val fut2 = fut.copy
		
		assertFalse(fut2.done)
		fut.complete(2)
		
		assertEquals(2, fut2.get)
	}
	
	@Test def void testCopyFutureNonCompletedExceptionally() {
		val fut = new CompletableFuture<Integer>
		val fut2 = fut.copy
		val ex = new IllegalStateException
		
		assertFalse(fut2.done)
		fut.completeExceptionally(ex)
		
		assertEquals(true, fut2.isCompletedExceptionally)
		val correctException = new AtomicBoolean(false)
		fut2.whenComplete [i,t|
			correctException.set(t.cause === ex)
		]
		assertTrue(correctException.get)
	}
	
	@Test def void testCopyFutureCompleted() {
		val fut = new CompletableFuture<Integer>
		fut.complete(2)
		
		val fut2 = fut.copy
		
		assertEquals(2, fut.get)
		assertEquals(2, fut2.get)
	}
	
	@Test def void testCopyFutureCompletedExceptionally() {
		val fut = new CompletableFuture<Integer>
		val ex = new ArrayIndexOutOfBoundsException
		fut.completeExceptionally(ex)
		
		val fut2 = fut.copy
		
		assertEquals(true, fut2.isCompletedExceptionally)
		val correctException = new AtomicBoolean(false)
		fut2.whenComplete [i,t|
			correctException.set(t.cause === ex)
		]
		assertTrue(correctException.get)
	}
	
	/////////////////////////
	// forwardCancellation //
	/////////////////////////
	
	@Test def void testForwardCancellationCancelOriginal() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		fut.forwardCancellation(fut2)
		fut.cancel
		
		assertTrue(fut2.cancelled)
	}
	
	@Test def void testForwardCancellationCancelOriginalBeforeForward() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		fut.cancel
		fut.forwardCancellation(fut2)
		
		assertTrue(fut2.cancelled)
	}
	
	@Test def void testForwardCancellationCancelOriginalForwardeeAlreadyComplete() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		fut.forwardCancellation(fut2)
		fut2.complete(42)
		fut.cancel
		assertFalse(fut2.cancelled)
		assertFalse(fut2.completedExceptionally)
	}
	
	@Test def void testForwardCancellationCancelOriginalForwardeeAlreadyCompletedExceptionally() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val expected = new NoSuchElementException
		fut.forwardCancellation(fut2)
		fut2.completeExceptionally(expected)
		fut.cancel
		assertFalse(fut2.cancelled)
		assertTrue(fut2.completedExceptionally)
		val e = Util.expectException(ExecutionException) [
			fut2.get
		]
		assertSame(expected, e.cause)
	}
	
	@Test def void testForwardCancellationOriginalCompletesSuccessfully() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		fut.forwardCancellation(fut2)
		fut.complete(42)
		
		assertFalse(fut2.isDone)
	}
	
	@Test def void testForwardCancellationOriginalCompletesSuccessfullyBeforeForward() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		fut.complete(42)
		fut.forwardCancellation(fut2)
		
		assertFalse(fut2.isDone)
	}
	
	
	@Test def void testForwardCancellationOriginalCompletesExceptionally() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		fut.forwardCancellation(fut2)
		fut.completeExceptionally(new IllegalStateException)
		
		assertFalse(fut2.isDone)
	}
	
	@Test def void testForwardCancellationOriginalCompletesExceptionallyBeforeForward() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		fut.completeExceptionally(new ArrayIndexOutOfBoundsException)
		fut.forwardCancellation(fut2)
		
		assertFalse(fut2.isDone)
	}
	
	/////////////////////////////////////
	// forwardCancellation to multiple //
	/////////////////////////////////////
	
	@Test def void testForwardCancellationToMultiCancelOriginal() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		val fut3 = new CompletableFuture<Integer>
		val fut4 = new CompletableFuture<Integer>
		
		fut.forwardCancellation(fut2, fut3, fut4)
		fut.cancel
		
		assertTrue(fut2.cancelled)
		assertTrue(fut3.cancelled)
		assertTrue(fut4.cancelled)
	}
	
	@Test def void testForwardCancellationToMultCancelOriginalBeforeForward() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		val fut3 = new CompletableFuture<Integer>
		val fut4 = new CompletableFuture<Integer>
		
		fut.cancel
		fut.forwardCancellation(fut2, fut3, fut4)
		
		assertTrue(fut2.cancelled)
		assertTrue(fut3.cancelled)
		assertTrue(fut4.cancelled)
	}
	
	@Test def void testForwardCancellationCancelToMultiOriginalForwardeeAlreadyComplete() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		val fut3 = new CompletableFuture<Integer>
		val fut4 = new CompletableFuture<Integer>
		
		fut.forwardCancellation(fut2,fut3,fut4)
		fut2.complete(42)
		fut3.complete(37)
		fut4.complete(55)
		fut.cancel
		assertFalse(fut2.cancelled)
		assertFalse(fut2.completedExceptionally)
		assertFalse(fut3.cancelled)
		assertFalse(fut3.completedExceptionally)
		assertFalse(fut4.cancelled)
		assertFalse(fut4.completedExceptionally)
	}
	
	@Test def void testForwardCancellationCancelToMultiOriginalForwardeesPartiallyComplete() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		val fut3 = new CompletableFuture<Integer>
		val fut4 = new CompletableFuture<Integer>
		
		fut.forwardCancellation(fut2,fut3,fut4)
		fut2.complete(42)
		fut4.complete(55)
		fut.cancel
		assertFalse(fut2.cancelled)
		assertFalse(fut2.completedExceptionally)
		assertTrue(fut3.cancelled)
		assertFalse(fut4.cancelled)
		assertFalse(fut4.completedExceptionally)
	}
	
	@Test def void testForwardCancellationToMultiCancelOriginalForwardeeAlreadyCompletedExceptionally() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		val fut3 = new CompletableFuture<Integer>
		val fut4 = new CompletableFuture<Integer>
		
		val expected = new NoSuchElementException
		fut.forwardCancellation(fut2,fut3,fut4)
		fut2.completeExceptionally(expected)
		fut3.completeExceptionally(expected)
		fut4.completeExceptionally(expected)
		fut.cancel
		assertFalse(fut2.cancelled)
		assertTrue(fut2.completedExceptionally)
		assertFalse(fut3.cancelled)
		assertTrue(fut3.completedExceptionally)
		assertFalse(fut4.cancelled)
		assertTrue(fut4.completedExceptionally)
		val e = Util.expectException(ExecutionException) [
			fut2.get
		]
		assertSame(expected, e.cause)
		val e2 = Util.expectException(ExecutionException) [
			fut3.get
		]
		assertSame(expected, e2.cause)
		val e3 = Util.expectException(ExecutionException) [
			fut4.get
		]
		assertSame(expected, e3.cause)
	}
	
	@Test def void testForwardCancellationToMultiCancelOriginalForwardeesPartiallyAlreadyCompletedExceptionally() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		val fut3 = new CompletableFuture<Integer>
		val fut4 = new CompletableFuture<Integer>
		
		val expected = new NoSuchElementException
		fut.forwardCancellation(fut2,fut3,fut4)
		fut3.completeExceptionally(expected)
		fut4.completeExceptionally(expected)
		fut.cancel
		assertTrue(fut2.cancelled)
		assertFalse(fut3.cancelled)
		assertTrue(fut3.completedExceptionally)
		assertFalse(fut4.cancelled)
		assertTrue(fut4.completedExceptionally)
		val e2 = Util.expectException(ExecutionException) [
			fut3.get
		]
		assertSame(expected, e2.cause)
		val e3 = Util.expectException(ExecutionException) [
			fut4.get
		]
		assertSame(expected, e3.cause)
	}
	
	@Test def void testForwardCancellationToMultiOriginalCompletesSuccessfully() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		val fut3 = new CompletableFuture<Integer>
		val fut4 = new CompletableFuture<Integer>
		
		fut.forwardCancellation(fut2,fut3,fut4)
		fut.complete(42)
		
		assertFalse(fut2.isDone)
		assertFalse(fut3.isDone)
		assertFalse(fut4.isDone)
	}
	
	@Test def void testForwardCancellationToMultiOriginalCompletesSuccessfullyBeforeForward() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		val fut3 = new CompletableFuture<Integer>
		val fut4 = new CompletableFuture<Integer>
		
		fut.complete(42)
		fut.forwardCancellation(fut2,fut3,fut4)
		
		assertFalse(fut2.isDone)
		assertFalse(fut3.isDone)
		assertFalse(fut4.isDone)
	}
	
	
	@Test def void testForwardCancellationToMultiOriginalCompletesExceptionally() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		val fut3 = new CompletableFuture<Integer>
		val fut4 = new CompletableFuture<Integer>
		
		fut.forwardCancellation(fut2,fut3,fut4)
		fut.completeExceptionally(new IllegalStateException)
		
		assertFalse(fut2.isDone)
		assertFalse(fut3.isDone)
		assertFalse(fut4.isDone)
	}
	
	@Test def void testForwardCancellationToMultiOriginalCompletesExceptionallyBeforeForward() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		val fut3 = new CompletableFuture<Integer>
		val fut4 = new CompletableFuture<Integer>
		
		fut.completeExceptionally(new ArrayIndexOutOfBoundsException)
		fut.forwardCancellation(fut2,fut3,fut4)
		
		assertFalse(fut2.isDone)
		assertFalse(fut3.isDone)
		assertFalse(fut4.isDone)
	}
	
	//////////////////
	// completeWith //
	//////////////////
	
	@Test(timeout=1000) def void testCompleteWithForwardingSuccess() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val Integer expected = 42
		
		fut.completeWith(fut2)
		assertFalse(fut.done)
		fut2.complete(expected)
		assertTrue(fut.done)		
		assertSame(expected, fut.get)
	}
	
	@Test(timeout=1000) def void testCompleteWithForwardingException() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val Exception expected = new IllegalStateException
		
		fut.completeWith(fut2)
		assertFalse(fut.done)
		fut2.completeExceptionally(expected)
		assertTrue(fut.done)		
		assertTrue(fut.completedExceptionally)
		val e = Util.expectException(ExecutionException) [
			fut.get
		]
		assertSame(expected, e.cause)
	}
	
	@Test(timeout=1000) def void testCompleteForwardingAfterTargetCompleted() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val Integer expected = 42
		fut.completeWith(fut2)
		assertFalse(fut.done)
		fut.complete(expected)
		fut2.complete(55)
		assertTrue(fut.done)		
		assertSame(expected, fut.get)
	}
	
	@Test(timeout=1000) def void testCompleteForwardingErrorAfterTargetCompleted() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val Integer expected = 42
		fut.completeWith(fut2)
		assertFalse(fut.done)
		fut.complete(expected)
		fut2.completeExceptionally(new NullPointerException)
		assertTrue(fut.done)
		assertFalse(fut.completedExceptionally)		
		assertSame(expected, fut.get)
	}
	
	@Test(timeout=1000) def void testCompleteForwardingOnCompleted() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val Integer expected = 42
		fut.complete(expected)
		fut.completeWith(fut2)
		fut2.complete(55)
		assertTrue(fut.done)		
		assertSame(expected, fut.get)
	}
	
	@Test(timeout=1000) def void testCompleteForwardingErrorOnCompleted() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val Integer expected = 42
		fut.complete(expected)
		fut.completeWith(fut2)
		fut2.completeExceptionally(new NullPointerException)
		assertTrue(fut.done)
		assertFalse(fut.completedExceptionally)		
		assertSame(expected, fut.get)
	}
	
	// exceptionally 
	
	@Test(timeout=1000) def void testCompleteForwardingAfterTargetCompletedExceptionally() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val expected = new NoSuchElementException
		fut.completeWith(fut2)
		assertFalse(fut.done)
		fut.completeExceptionally(expected)
		fut2.complete(55)
		assertTrue(fut.done)		
		val e = Util.expectException(ExecutionException) [
			fut.get
		]
		assertSame(expected, e.cause)
	}
	
	@Test(timeout=1000) def void testCompleteForwardingErrorAfterTargetCompletedExceptionally() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val expected = new IllegalArgumentException
		fut.completeWith(fut2)
		assertFalse(fut.done)
		fut.completeExceptionally(expected)
		fut2.completeExceptionally(new NullPointerException)
		assertTrue(fut.done)
		val e = Util.expectException(ExecutionException) [
			fut.get
		]
		assertSame(expected, e.cause)
	}
	
	@Test(timeout=1000) def void testCompleteForwardingOnCompletedExeptionally() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val expected = new NullPointerException
		fut.completeExceptionally(expected)
		fut.completeWith(fut2)
		fut2.complete(55)
		assertTrue(fut.done)		
		val e = Util.expectException(ExecutionException) [
			fut.get
		]
		assertSame(expected, e.cause)
	}
	
	@Test(timeout=1000) def void testCompleteForwardingErrorOnCompletedExceptionally() {
		val fut = new CompletableFuture<Integer>
		val fut2 = new CompletableFuture<Integer>
		
		val expected = new UnsupportedOperationException
		fut.completeExceptionally(expected)
		fut.completeWith(fut2)
		fut2.completeExceptionally(new NullPointerException)
		assertTrue(fut.done)
		val e = Util.expectException(ExecutionException) [
			fut.get
		]
		assertSame(expected, e.cause)
	}
	
	//////////////////////////////////////////////////
	// orTimeout(CompletableFuture, long, TimeUnit) //
	//////////////////////////////////////////////////
	
	@Test(timeout = 1000) def void testOrTimeoutOnTimeout() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 10L
		val unit = TimeUnit.MILLISECONDS
		val withTimeout = fut.orTimeout(timeoutTime, unit)
		Thread.sleep(100)
		assertFalse(fut.done)
		assertTrue(withTimeout.done)
		assertTrue(withTimeout.completedExceptionally)
		val e = Util.expectException(ExecutionException) [
			withTimeout.get
		]
		assertTrue(e.cause instanceof TimeoutException)
	}
	
	@Test(timeout = 1000) def void testOrTimeoutCompleteBeforeTimeout() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 100L
		val unit = TimeUnit.MILLISECONDS
		val withTimeout = fut.orTimeout(timeoutTime, unit)
		val expected = "foobar"
		fut.complete(expected)
		Thread.sleep(200)
		assertTrue(withTimeout.done)
		assertFalse(withTimeout.completedExceptionally)
		assertSame(expected, withTimeout.join)
	}
	
	@Test(timeout = 1000) def void testOrTimeoutCompleteExceptionallyBeforeTimeout() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 50L
		val unit = TimeUnit.MILLISECONDS
		val withTimeout = fut.orTimeout(timeoutTime, unit)
		val expected = new NullPointerException
		fut.completeExceptionally(expected)
		Thread.sleep(200)
		assertTrue(withTimeout.done)
		assertTrue(withTimeout.completedExceptionally)
		val e = Util.expectException(ExecutionException) [
			withTimeout.get
		]
		assertSame(expected, e.cause)
	}
	
	@Test(timeout = 1000) def void testOrTimeoutCancelBeforeTimeout() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 50L
		val unit = TimeUnit.MILLISECONDS
		val withTimeout = fut.orTimeout(timeoutTime, unit)
		fut.cancel
		Thread.sleep(200)
		assertTrue(withTimeout.done)
		assertTrue(withTimeout.cancelled)
	}
	
	///////////////////////////////////////////////////////////////////////
	// orTimeout(CompletableFuture<R>, (TimeoutConfig)=>void) //
	///////////////////////////////////////////////////////////////////////
	
	@Test(timeout = 1000) def void testOrTimeoutConfigCancelBeforeTimeout() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 50L
		val unit = TimeUnit.MILLISECONDS
		val withTimeout = fut.orTimeout[
			timeout = (timeoutTime -> unit)
		]
		fut.cancel
		Thread.sleep(200)
		assertTrue(withTimeout.done)
		assertTrue(withTimeout.cancelled)
	}
	
	@Test(timeout = 1000) def void testOrTimeoutOnConfigDefaultTimeoutException() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 10L
		val unit = TimeUnit.MILLISECONDS
		val withTimeout = fut.orTimeout[
			timeout = (timeoutTime -> unit)
		]
		Thread.sleep(100)
		assertFalse(fut.done)
		assertTrue(withTimeout.done)
		assertTrue(withTimeout.completedExceptionally)
		val e = Util.expectException(ExecutionException) [
			withTimeout.get
		]
		assertTrue(e.cause instanceof TimeoutException)
	}
	
	@Test(timeout = 1000) def void testOrTimeoutConfigOnTimeoutException() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 10L
		val unit = TimeUnit.MILLISECONDS
		val ex = new NoSuchElementException
		val withTimeout = fut.orTimeout [
			timeout = (timeoutTime -> unit)
			exceptionProvider = [ex]
		]
		Thread.sleep(100)
		assertFalse(fut.done) // by default no cancellation of original
		assertTrue(withTimeout.done)
		assertTrue(withTimeout.completedExceptionally)
		val e = Util.expectException(ExecutionException) [
			withTimeout.get
		]
		assertTrue(e.cause === ex)
	}
	
	@Test def void testOrTimeoutConfigCancelBackpropagation() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 10L
		val unit = TimeUnit.SECONDS
		val ex = new NoSuchElementException
		val withTimeout = fut.orTimeout [
			timeout = (timeoutTime -> unit)
			exceptionProvider = [ex]
			backwardPropagateCancel = true
		]
		assertFalse(fut.done)
		assertFalse(withTimeout.done)
		
		withTimeout.cancel(true)
		assertTrue(fut.cancelled)
	}
	
	@Test def void testOrTimeoutConfigCancelNoBackpropagation() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 100L
		val unit = TimeUnit.MILLISECONDS
		val ex = new NoSuchElementException
		val withTimeout = fut.orTimeout [
			timeout = (timeoutTime -> unit)
			exceptionProvider = [ex]
			backwardPropagateCancel = false
		]
		assertFalse(fut.done)
		assertFalse(withTimeout.done)
		
		withTimeout.cancel(true)
		assertFalse(fut.cancelled)
	}
	
	@Test def void testOrTimeoutConfigCancelOriginalOnTimeout() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 10L
		val unit = TimeUnit.MILLISECONDS
		val ex = new NoSuchElementException
		val withTimeout = fut.orTimeout [
			timeout = (timeoutTime -> unit)
			exceptionProvider = [ex]
			cancelOriginalOnTimeout = true
		]
		Thread.sleep(100)
		assertTrue(withTimeout.completedExceptionally)
		assertTrue(fut.cancelled)
	}
	
	@Test def void testOrTimeoutConfigShutdownSchedulerAfterTimeout() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 10L
		val unit = TimeUnit.MILLISECONDS
		val ex = new NoSuchElementException
		val pool = new ScheduledThreadPoolExecutor(1)
		val withTimeout = fut.orTimeout [
			timeout = (timeoutTime -> unit)
			exceptionProvider = [ex]
			scheduler = pool
			tryShutdownScheduler = true
		]
		Thread.sleep(100)
		assertTrue(pool.isShutdown)
	}
	
	@Test(timeout = 1000) def void testOrTimeoutConfigShutdownSchedulerOnCompletion() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 10L
		val unit = TimeUnit.SECONDS
		val ex = new NoSuchElementException
		val pool = new ScheduledThreadPoolExecutor(1)
		val withTimeout = fut.orTimeout [
			timeout = (timeoutTime -> unit)
			exceptionProvider = [ex]
			scheduler = pool
			tryShutdownScheduler = true
		]
		fut.complete("foobar")
		pool.awaitTermination(100, TimeUnit.MILLISECONDS)
		assertTrue(pool.isShutdown)
	}
	
	@Test(timeout = 1000) def void testOrTimeoutConfigAlreadyCompletedShutdownScheduler() {
		val fut = new CompletableFuture<String>
		val timeoutTime = 10L
		val unit = TimeUnit.SECONDS
		val ex = new NoSuchElementException
		val pool = new ScheduledThreadPoolExecutor(1)
		fut.complete("foobar")
		val withTimeout = fut.orTimeout [
			timeout = (timeoutTime -> unit)
			exceptionProvider = [ex]
			scheduler = pool
			tryShutdownScheduler = true
		]
		pool.awaitTermination(100, TimeUnit.MILLISECONDS)
		assertTrue(pool.isShutdown)
	}
	
	// TODO test Async variants
}