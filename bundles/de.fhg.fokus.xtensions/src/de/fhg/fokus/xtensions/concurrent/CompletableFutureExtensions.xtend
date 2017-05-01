package de.fhg.fokus.xtensions.concurrent

import java.time.Duration
import java.util.Objects
import java.util.concurrent.CancellationException
import java.util.concurrent.CompletableFuture
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.ScheduledThreadPoolExecutor
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

import java.util.concurrent.CompletionStage
import java.util.concurrent.Executor
import java.util.concurrent.ForkJoinPool
import java.util.concurrent.TimeoutException
import java.util.concurrent.RejectedExecutionException
import java.util.concurrent.Executors
import java.util.concurrent.ThreadFactory
import static extension de.fhg.fokus.xtensions.concurrent.internal.DurationToTimeConversion.*
import java.util.function.BiConsumer
import org.eclipse.jdt.annotation.NonNull

/**
 * This class provides static methods (many of them to be used as extension methods)
 * that enrich the {@code CompletableFuture} class.
 * <p>
 * The extension methods for CompletableFuture make some common use cases easier. Some of these methods are:
 * <ul>
 * 	 <li>{@link #then(CompletableFuture, Function1)}</li>
 * 	 <li>{@link #then(CompletableFuture, Procedure1)}</li>
 * 	 <li>{@link #then(CompletableFuture, Procedure0)}</li>
 * 	 <li>{@link #whenSuccessfull(CompletableFuture, Procedure1)}</li>
 * 	 <li>{@link #whenCancelled(CompletableFuture, Procedure0)}</li>
 * 	 <li>{@link #whenException(CompletableFuture, Procedure1)}</li>
 * 	 <li>{@link #handleCancellation(CompletableFuture, Function0)}</li>
 * 	 <li>{@link #cancelOnTimeout(CompletableFuture, long, TimeUnit)}</li>
 * 	 <li>{@link #cancelOnTimeout(CompletableFuture, ScheduledExecutorService, long, TimeUnit)}</li>
 * 	 <li>{@link #forwardTo(CompletableFuture, CompletableFuture)}</li>
 * 	 <li>{@link #forwardCancellation(CompletableFuture, CompletableFuture)}</li>
 * </ul>
 * <p>
 */
class CompletableFutureExtensions {

	/**
	 * Calls {@link CompletableFuture#cancel(boolean)} on the given {@code future}.
	 * Since the boolean parameter {@code mayInterruptIfRunning} has no influence 
	 * on CompletableFuture instances anyway,  this method provides a cancel method 
	 * without the parameter.
	 * @see CompletableFuture#cancel(boolean)
	 */
	static def <R> boolean cancel(CompletableFuture<R> future) {
		Objects.requireNonNull(future)
		future.cancel(false)
	}

	/**
	 * This method calls {@link #cancelOnTimeout(CompletableFuture, long , TimeUnit)} with a
	 * best effort converting the given {@code Duration timeout} to a {@code long} of {@code 
	 * TimeUnit}.
	 * May cause loss in time precision, if the overall timeout duration exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped.
	 * @param fut the future to be cancelled after {@code timeout}, provided the future
	 *   is not completed before cancellation.
	 * @param timeout specifies time to wait, before canceling {@code fut}. Must not be {@code null}.
	 * @return result of call to {@link #cancelOnTimeout(CompletableFuture, long, TimeUnit)}
	 * @see #cancelOnTimeout(CompletableFuture, long, TimeUnit)
	 * @throws NullPointerException throws if {@code fut} or {@code timeout} is {@code null}
	 */
	static def <R> CompletableFuture<R> cancelOnTimeout(CompletableFuture<R> fut, Duration timeout) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(timeout)
		val time = timeout.toTime
		cancelOnTimeout(fut, time.amount, time.unit);
	}

	/**
	 * Defines a time out for the given future {@code fut}. When the time out is reached 
	 * {@code fut} will be cancelled, if the future was not completed already. To determine the time
	 * to wait until performing the cancellation the time is specified by parameter {@code timeout} and 
	 * the unit of time is specified by parameter {@code unit}. This method
	 * will create and use a scheduler internally to schedule the cancellation. To use an own
	 * scheduler, use method {@link #cancelOnTimeout(CompletableFuture, ScheduledExecutorService, long, TimeUnit)}.
	 * @param fut the future to be cancelled after {@code timeout} of time unit {@code unit}, provided the future
	 *   is not completed before cancellation.
	 * @param timeout specifies time to wait, before canceling {@code fut}. Must be &gt;=0
	 * @param unit specifies the time unit of {@code timeout}
	 * @return returns parameter {@code fut}
	 * @see #cancelOnTimeout(CompletableFuture, ScheduledExecutorService, long, TimeUnit)
	 * @throws NullPointerException throws if {@code fut} or {@code unit} is {@code null}
	 */
	static def <R> CompletableFuture<R> cancelOnTimeout(CompletableFuture<R> fut, long timeout, TimeUnit unit) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(unit)

		// if the future is already completed, there is no point in even 
		// starting a timer
		if (fut.done) {
			return fut
		}

		val scheduler = defaultScheduler
		val task = scheduler.schedule([|
			try {
				fut.cancel
			} finally {
				scheduler.shutdown()
			}
			return
		], timeout, unit)
		// if the future is completed earlier
		// than cancellation, we can cancel the 
		// scheduled task (but on the scheduler threads)
		// and shut down the scheduler, since it is only
		// used here
		fut.whenCompleteAsync( [
			if (task.cancel(true)) {
				scheduler.shutdown()
			}
		], scheduler)
		fut
	}

	/**
	 * ScheduledThreadPoolExecutor using daemon threads and allow task
	 * removal on cancellation of task.
	 */
	private def static getDefaultScheduler() {
		val scheduler = new ScheduledThreadPoolExecutor(0, daemonThreadFactory)
		scheduler.removeOnCancelPolicy = true
		scheduler
	}

	/**
	 * Defines a time out for the given future {@code fut}. When the time out is reached 
	 * {@code fut} will be cancelled, if the future was not completed already. To determine the time
	 * to wait until performing the cancellation the time is specified by parameter {@code timeout} and 
	 * the unit of time is specified by parameter {@code unit}. This method
	 * will the given {@code scheduler} to schedule the cancellation. If the scheduler should be provided for
	 * the caller, use method {@link #cancelOnTimeout(CompletableFuture, long, TimeUnit)}.
	 * This method is not responsible for shutting down the given {@code scheduler}
	 * @param fut future to be cancelled after timeout of {@code time} of time unit {@code unit}. 
	 * @param scheduler the timeout will be scheduled and the cancellation executed on this 
	 *   scheduling pool.
	 * @param time timeout time in time unit {@code unit} after which {@code fut} will be cancelled.
	 * @param unit time unit of timeout {@code time}.
	 * @return same reference as parameter {@code fut}.
	 * @see #cancelOnTimeout(CompletableFuture, long, TimeUnit)
	 */
	static def <R> CompletableFuture<R> cancelOnTimeout(CompletableFuture<R> fut, ScheduledExecutorService scheduler,
		long time, TimeUnit unit) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(scheduler)
		Objects.requireNonNull(unit)
		// if the future is already completed, there is no point in even 
		// starting a timer
		if (fut.done) {
			return fut
		}

		val task = scheduler.schedule([fut.cancel], time, unit)
		// if the future is completed earlier
		// than cancellation, we can cancel the 
		// scheduled task
		fut.whenCompleteAsync( [
			task.cancel(true)
		], scheduler)
		fut
	}

	private static def ThreadFactory getDaemonThreadFactory() {
		[
			val t = Executors.defaultThreadFactory.newThread(it)
			t.daemon = true
			t
		]
	}

	// Do Not cancel given stage, forward to returned future. after timeout just cancel returned future
	// TODO static def CompletableFuture<R> orTimeout(CompletionStage<? extends R> fut, long timeout, TimeUnit unit, =>Throwable exceptionProvider)
	/**
	 * This function will forward the result of future {@code from} to future {@code to}. This is independent 
	 * of the result, this could be a regular or exceptional result (which includes cancellation). If future
	 * {@code to} was completed before {@code from} got completed the attempt to forward will fail without 
	 * further feedback to the caller of this method. Returns a CompletableFuture that completes after 
	 * {@code to} was completed with the same result as the original, which includes cancellation
	 * @param from the result of this future will be forwarded to future {@code to}
	 * @param to the result of {@code from} will be forwarded to this future.
	 * @return a CompletableFuture that will complete after the forwarding is complete.
	 * @throws NullPointerException if {@code from} or {@code to} is {@code null}
	 */
	static def <R> CompletionStage<R> forwardTo(CompletionStage<R> from,
		CompletableFuture<? super R> to) throws NullPointerException {
		Objects.requireNonNull(from)
		Objects.requireNonNull(to)

		from.whenComplete [ o, t |
			if (t !== null) {
				to.completeExceptionally(t)
			} else {
				to.complete(o)
			}
		]
	}

	/**
	 * This is the inverse operation of {@link CompletableFutureExtensions#forwardTo(CompletableFuture,
	 * CompletableFuture) forwardTo}. This method will simply call forwardTo parameters in switched order.
	 * @param toComplete the future that will be completed with the result of {@code with}.
	 * @param with the future that provides the result that will be forwarded to {@code toComplete}.
	 * @see CompletableFutureExtensions#forwardTo(CompletableFuture,
	 * CompletableFuture)
	 * @return a CompletableFuture that will complete after the forwarding is complete.
	 */
	static def <R> CompletionStage<R> completeWith(CompletableFuture<? super R> toComplete, CompletionStage<R> with) {
		Objects.requireNonNull(toComplete)
		Objects.requireNonNull(with)
		with.forwardTo(toComplete)
	}

	// TODO static def <R,T> T supplyCancelOnInterrupt(CompletableFuture<R> fut, ()=>T interruptableBlock) 
	/**
	 * This function helps integration of CompletableFuture and blocking APIs. Blocking APIs may allow 
	 * cancellation via interrupting the thread the blocking call is performed on. When a blocking call
	 * is performed on a thread pool it is crucial that the interruption is visible to other tasks that
	 * may be run on the thread. This function is a bridge between cancellation of CompletableFuture and
	 * thread interruption for blocking APIs. The {@interruptableBlock} is called by this method and only
	 * while the block is executed cancellation of the future passed as parameter {@code fut} will lead
	 * to interruption of the current thread executing this method and the {@code interruptableBlock}.
	 * Thrown exceptions will be thrown to the caller of this method.<br>
	 * After this method the interrupted flag of this thread is unset, even when the block throws an exception. 
	 * This way the thread calling this can safely be a pooled thread and may not interrupt some other task 
	 * submitted to the thread pool managing the thread. <br>
	 * This is an example of how this message could be used:
	 * <code><pre>
	 * val blockOpPool = Executors.newCachedThreadPool
	 * // ...
	 * val sleepy = blockOpPool.asyncRun [ 
	 *   whenCancelledInterrupt [|
	 *     try {
	 *       Thread.sleep(100)
	 *     } catch (InterruptedException e) {
	 *       println("Hey, I was cancelled")
	 *     }
	 *   ]
	 * ]
	 * </pre></code>
	 * To make cancellation not interrupt the current thread outside of the context of the 
	 * {@code interruptableBlock}, blocking synchronization is needed at the end of execution 
	 * of {@code interruptableBlock} and in the handler registered on {@code fut} being executed
	 * on cancellation.
	 * 
	 * @param fut future that if cancelled will interrupt the thread calling {@code interruptableBlock}.
	 * @param interruptableBlock the block of code that is executed on the thread calling this method.
	 *   If {@code fut} is cancelled during execution of the block, the calling thread will be interrupted.
	 *   After execution of this block the thread's interrupted flag will be reset.
	 *   This is also guaranteed if the block of code throws an exception.
	 * @throws NullPointerException will be thrown if {@code fut} or {@code interruptableBlock} is {@code null}.
	 */
	static def <R> void whenCancelledInterrupt(CompletableFuture<R> fut, ()=>void interruptableBlock) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(interruptableBlock)
		val interruptAllowed = new AtomicBoolean(true)
		val interruptableThread = Thread.currentThread
		// if future is cancelled and we are still in interruptableBlock
		// then interrupt thread executing interruptableBlock
		fut.whenCancelled [
			// first try without lock, if interruptableBlock
			// already complete. If so, we don't even have to
			// try to set interrupted.
			if (!interruptAllowed.get) {
				return;
			}
			// now double check, if thread is still in interruptableBlock,
			// interrupt the thread executing interruptableBlock
			synchronized (interruptAllowed) {
				if (interruptAllowed.get) {
					interruptableThread.interrupt
				}
			}
		]

		// execute interruptableBlock
		try {
			interruptableBlock.apply
		} finally {
			synchronized (interruptAllowed) {
				interruptAllowed.set(false)
				// reset interrupted flag if set by cancelled future,
				// this way the thread can safely be reused by a thread pool
				Thread.interrupted()
			}
		}
	}

	// TODO document
	/**
	 * The effect of calling this method is like using 
	 * {@link CompletableFuture#exceptionally(java.util.function.Function) CompletableFuture#exceptionally}
	 * where the provided function is only called when {@code fut} is completed with a {@link CancellationException}.
	 * If {@code fut} completes exceptionally, but not with a {@code CancellationException}, the exception is 
	 * re-thrown from the handler, so the returned future will be completed exceptionally with the same exception.
	 * 
	 * @param fut future {@code handler} is registered on. Must not be {@code null}.
	 * @param handler the callback to be invoked when {@code fut} is completed with cancellation.
	 *   Must not be {@code null}.
	 * @return new CompletableFuture that either is completed with the result of {@code fut}, if 
	 *   {@code fut} completes successful. Otherwise the result provided from {@code handler} is 
	 *   used to complete the returned future.
	 * @throws NullPointerException is thrown when {@code fut} or {@code handler} is {@code null}.
	 */
	static def <R> CompletableFuture<R> handleCancellation(CompletableFuture<R> fut, ()=>R handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(handler)
		fut.exceptionally[ex|if(ex instanceof CancellationException) handler.apply else throw ex]
	}

	// TODO document
	static def <R> CompletableFuture<R> handleCancellationAsync(CompletableFuture<R> fut, ()=>R handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(handler)
		fut.handleCancellationAsync(ForkJoinPool.commonPool, handler)
	}

	// TODO document
	static def <R> CompletableFuture<R> handleCancellationAsync(CompletableFuture<R> fut, Executor e, ()=>R handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(e)
		Objects.requireNonNull(handler)
		fut.handleAsync([ o, t |
			if (t !== null) {
				if (t instanceof CancellationException)
					handler.apply
				else
					throw t
			} else
				o
		], e)
	}

	/**
	 * This is a version of {@link CompletableFuture#exceptionally(Function) exceptionally} where the 
	 * handler is executed on the common ForkJoinPool.<br>
	 * The future returned by this method either completes successfully, if parameter {@code fut} completes
	 * successfully, or with the result of {@code handler}, if {@code fut} completes exceptionally. If 
	 * {@code handler} throws an exception, the returned future will complete exceptionally with the thrown
	 * exception.
	 * @param fut Future that's successful result will be forwarded to the returned future. If this future completes
	 *   exceptionally {@code handler} will be called to determine the completion result of the returned future.
	 * @param handler If {@code fut} completes exceptionally, this handler will be called to determine the result
	 *   that will be set on the future returned by this method. If handler throws an exception, the returned 
	 *   future completes exceptionally with the exception thrown by {@code handler}. The handler not be {@code null}.
	 * @return new future that will either complete with the result of {@code fut}, if it completes successfully,
	 *  or with the result provided by {@code handler} if {@code fut} completes exceptionally.
	 * @throws NullPointerException if {@code fut} or {@code handle} is {@code null}.
	 * @see #exceptionallyAsync(CompletableFuture, Executor, Function1)
	 */
	static def <R> CompletableFuture<R> exceptionallyAsync(CompletableFuture<? extends R> fut, (Throwable)=>R handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(handler)
		fut.exceptionallyAsync(ForkJoinPool.commonPool, handler)
	}

	/**
	 * This is a version of {@link CompletableFuture#exceptionally(Function) exceptionally} where the 
	 * handler is executed on the given {@code executor}.<br>
	 * The future returned by this method either completes successfully, if parameter {@code fut} completes
	 * successfully, or with the result of {@code handler}, if {@code fut} completes exceptionally. If 
	 * {@code handler} throws an exception, the returned future will complete exceptionally with the thrown
	 * exception.
	 * @param fut Future that's successful result will be forwarded to the returned future. If this future completes
	 *   exceptionally {@code handler} will be called to determine the completion result of the returned future.
	 * @param executor the executor used to check on the result of {@code fut} and execution of {@code handler}.
	 * @param handler If {@code fut} completes exceptionally, this handler will be called to determine the result
	 *   that will be set on the future returned by this method. If handler throws an exception, the returned 
	 *   future completes exceptionally with the exception thrown by {@code handler}. The handler not be {@code null}.
	 * @return new future that will either complete with the result of {@code fut}, if it completes successfully,
	 *  or with the result provided by {@code handler} if {@code fut} completes exceptionally.
	 * @throws NullPointerException if {@code fut}, {@code executor}, or {@code handle} is {@code null}.
	 * @see #exceptionallyAsync(CompletableFuture, Executor, Function1)
	 */
	static def <R> CompletableFuture<R> exceptionallyAsync(CompletableFuture<? extends R> fut, Executor executor,
		(Throwable)=>R handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(executor)
		fut.handleAsync([o, t|if(t !== null) handler.apply(t) else o], executor)
	}

	private static def <T> BiConsumer<T, Throwable> whenCancelledHandler(()=>void handler) {
		[o, t|if(t !== null && t instanceof CancellationException) handler.apply]
	}

	/**
	 * Registers {@code handler} on the given future {@fut} to be called when the future is cancelled
	 * (meaning completed with an instance of {@link CancellationException}).
	 * @param fut the future {@code handler} is registered on for notification about cancellation. 
	 *   Must not be {@code null}.
	 * @param handler callback to be registered on {@code fut}, being called when the future gets cancelled.
	 *   Must not be {@code null}.
	 * @return a CompletableFuture that will complete after the handler completes or if {@code fut} completes
	 *  without being cancelled. If {@code fut} is cancelled the returned future will be completed exceptionally
	 *  with a {@link java.util.concurrent.CancellationException CancellationException}, but will not itself count 
	 *  as cancelled ({@link CompletableFuture#isCancelled() isCancelled} will return {@code false}). 
	 *  When the original future completes exceptionally, callback methods on the returned future will provide a {@link java.util.concurrent.CompletionException CompletionException}
	 *  wrapping the original exception. This includes {@code CancellationException}s.
	 * @throws NullPointerException if {@code fut} or {@code handler} is {@code null}.
	 */
	static def <R> CompletableFuture<R> whenCancelled(CompletableFuture<R> fut, ()=>void handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(handler)
		fut.whenComplete(whenCancelledHandler(handler))
	}

	// TODO document
	static def <R> CompletableFuture<R> whenCancelledAsync(CompletableFuture<R> fut, ()=>void handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(handler)
		fut.whenCancelledAsync(ForkJoinPool.commonPool, handler)
	}

	// TODO document
	static def <R> CompletableFuture<R> whenCancelledAsync(CompletableFuture<R> fut, Executor e, ()=>void handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(e)
		Objects.requireNonNull(handler)
		fut.whenCompleteAsync(whenCancelledHandler(handler), e)
	}

	private static def <R> BiConsumer<R, Throwable> whenExcpetionHandler((Throwable)=>void handler) {
		[o, t|if(t !== null) handler.apply(t)]
	}

	/**
	 * Registers {@code handler} on the given future {@fut} to be called when the future completes 
	 * exceptionally. This also includes cancellation.
	 * @param fut the future {@code handler} is registered on for notification about exceptional completion. 
	 *   Must not be {@code null}.
	 * @param handler callback to be registered on {@code fut}, being called when the future completes with an exception.
	 *   If the handler throws an exception, the returned future will be completed with the original exception.
	 *   The handler must not be {@code null}.
	 * @return a CompletableFuture that will complete after the handler completes or if {@code fut} completes
	 *  successfully. If {@code fut} completes exceptionally the returned future will be completed exceptionally
	 *  with the same exception.
	 * @throws NullPointerException if {@code fut} or {@code handler} is {@code null}.
	 */
	static def <R> CompletableFuture<R> whenException(CompletableFuture<R> fut, (Throwable)=>void handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(handler)
		fut.whenComplete(whenExcpetionHandler(handler))
	}

	// TODO document
	static def <R> CompletableFuture<R> whenExceptionAsync(CompletableFuture<R> fut, (Throwable)=>void handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(handler)
		fut.whenExceptionAsync(ForkJoinPool.commonPool, handler)
	}

	// TODO document
	static def <R> CompletableFuture<R> whenExceptionAsync(CompletableFuture<R> fut, Executor e,
		(Throwable)=>void handler) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(e)
		Objects.requireNonNull(handler)
		fut.whenCompleteAsync(whenExcpetionHandler(handler), e)
	}

	/**
	 * Registers a callback on future {@code from} so when the future is cancelled, the 
	 * future {@code to} will be attempted to be cancelled as well. If by the time {@code to} is already 
	 * completed, the cancellation of {@code from} will have no affect.
	 * @param from if this future is cancelled, {@code to} will be tried to be cancelled as well..
	 *    Must not be {@code null}.
	 * @param to future to be cancelled when {@code from} is cancelled.
	 * @throws NullPointerException thrown if {@code from} or {@code to} is {@code null}
	 */
	static def void forwardCancellation(CompletableFuture<?> from, CompletableFuture<?> to) {
		Objects.requireNonNull(from)
		Objects.requireNonNull(to)
		from.whenCancelled[to.cancel]
	}

	/**
	 * Registers a callback on future {@code from} so when the future is cancelled, the 
	 * future {@code to} and all futures in {@code toRest} will be attempted to be cancelled as well. 
	 * If by the time {@code to} or futures in {@code toRest} is already completed, 
	 * the cancellation of {@code from} will have no affect on the respective future.
	 * @param from if this future is cancelled, {@code to} will be tried to be cancelled as well..
	 *    Must not be {@code null}.
	 * @param to first future to be cancelled when {@code from} is cancelled. Must not be {@code null}
	 *   and must not contain any {@code null} references.
	 * @param toRest additional futures to be cancelled when {@code from} is cancelled.
	 * @throws NullPointerException thrown if {@code from}, {@code to}, {@code toRest}, or any 
	 *  of the fields of {@code toRest} is {@code null}.
	 */
	static def void forwardCancellation(CompletableFuture<?> from, CompletableFuture<?> to,
		CompletableFuture<?>... toRest) {
		Objects.requireNonNull(from)
		Objects.requireNonNull(to)
		Objects.requireNonNull(toRest)
		for (cf : toRest) {
			Objects.requireNonNull(cf)
		}
		from.whenCancelled [
			to.cancel
			toRest.forEach[cancel]
		]
	}

	/**
	 * This function is calling {@link CompletableFuture#thenAccept(Consumer)} on {@code fut}, adapting
	 * {@code handler} as the parameter.
	 * @param fut the future on which {@link CompletableFuture#thenAccept(Consumer) thenAccept} will be called.
	 *   Must not be {@code null}.
	 * @param handler the function that will be called as the consumer to {@code thenAccept}
	 *   Must not be {@code null}.
	 * @return resulting CompletableFuture of {@code thenAccept} call
	 * @see #then(CompletableFuture, Function1)
	 * @see #then(CompletableFuture, Procedure0)
	 * @throws NullPointerException if either {@code fut} or {@code handler} is {@code null}
	 */
	static def <R> CompletableFuture<Void> then(CompletableFuture<R> fut, (R)=>void handler) {
		// TODO inline if annotation works in Xtend
		Objects.requireNonNull(handler)
		fut.thenAccept(handler)
	}

	/**
	 * This function is calling {@link CompletableFuture#thenApply(Function)} on {@code fut}, adapting
	 * {@code handler} as the parameter.
	 * @param fut the future on which {@link CompletableFuture#thenApply(Function) thenApply} will be called
	 *   Must not be {@code null}.
	 * @param handler the function that will be called as the consumer to {@code thenApply}
	 *   Must not be {@code null}.
	 * @return resulting CompletableFuture of {@code thenApply} call
	 * @throws NullPointerException if either {@code fut} or {@code handler} is {@code null}
	 * @see #then(CompletableFuture, Procedure0)
	 * @see #then(CompletableFuture, Procedure1)
	 */
	static def <R, U> CompletableFuture<U> then(CompletableFuture<R> fut, (R)=>U handler) {
		// TODO inline if annotation works in Xtend
		Objects.requireNonNull(handler)
		fut.thenApply(handler)
	}

	/**
	 * This function is calling {@link CompletableFuture#thenRun(Runnable)} on {@code fut}, adapting
	 * {@code handler} as the parameter.
	 * @param fut the future on which {@link CompletableFuture#thenRun(Runnable) thenRun} will be called
	 * @param handler the function that will be called as the consumer to {@code thenRun}
	 * @return resulting CompletableFuture of {@code thenRun} call
	 * @throws NullPointerException if either {@code fut} or {@code handler} is {@code null}
	 * @see #then(CompletableFuture, Function1)
	 * @see #then(CompletableFuture, Procedure1)
	 */
	static def <R> CompletableFuture<Void> then(CompletableFuture<R> fut, ()=>void handler) {
		// TODO inline if annotation works in Xtend
		Objects.requireNonNull(handler)
		fut.thenRun(handler)
	}

	private static def <R> recover(R r, Throwable ex, CompletableFuture<R> result,
		(Throwable)=>CompletionStage<? extends R> recovery) {
		// did the original
		if (ex !== null) {
			// error occurred, we need to recover
			var CompletionStage<? extends R> recoverFut
			try {
				recoverFut = recovery.apply(ex)
			} catch (Throwable t) {
				result.completeExceptionally(t)
				return
			}
			// did we actually get a future to recover with?
			if (recoverFut === null) {
				// nope, NPE
				result.completeExceptionally(new NullPointerException)
			} else {
				// yes, complete result with the recovery future value 
				// (may be exceptionally too)
				recoverFut.forwardTo(result)
			}
		} else {
			// fut was successful, so we pass along the result
			result.complete(r)
		}
	}

	/**
	 * If the given future {@code fut} completes successfully, the future returned from this method will be
	 * completed with the result value. Otherwise the provider {@code recovery} will be called to provide
	 * a future and the result of this future will be used to complete the returned future. This also means 
	 * that if the provided recovery future was completed exceptionally, the failure will be forwarded to the
	 * returned future.
	 * @param fut the future that may fail (complete exceptionally). If it completes successfully, the result
	 *  value will be used to complete the returned future
	 * @param recovery provides a CompletionStage in case {@code fut} completes exceptionally. In this case the result
	 *  (either value or exception) will be used to complete the future returned from the function. If this 
	 *  supplier provides a {@code null} reference, the returned future will be completed with a {@link NullPointerException}.
	 *  If the supplier throws an exception, the returned future will be completed with this exception.
	 * @return future that will either complete successfully, if {@code fut} completes successfully. If {@code fut}
	 *   completes exceptionally, otherwise {@code recovery} will be called and the result of the provided CompletionStage
	 *   will be forwarded to the returned future.
	 */
	static def <R> CompletableFuture<R> recoverWith(
		CompletableFuture<R> fut,
		(Throwable)=>CompletionStage<? extends R> recovery
	) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(recovery)
		val result = new CompletableFuture<R>
		fut.whenComplete [ r, ex |
			recover(r, ex, result, recovery)
		]
		result
	}

	// TODO document
	static def <R> CompletableFuture<R> recoverWithAsync(
		CompletableFuture<R> fut,
		(Throwable)=>CompletionStage<? extends R> recovery
	) {
		recoverWithAsync(fut, ForkJoinPool.commonPool, recovery)
	}

	// TODO document
	static def <R> CompletableFuture<R> recoverWithAsync(
		CompletableFuture<R> fut,
		Executor e,
		(Throwable)=>CompletionStage<? extends R> recovery
	) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(recovery)
		val result = new CompletableFuture<R>
		fut.whenCompleteAsync([ r, ex |
			recover(r, ex, result, recovery)
		], e)
		result
	}

	public static final class OnTimeoutBuilder {
		private new() {
		}

		private var long timeout = 1
		private var TimeUnit timeUnit = null
		private var ScheduledExecutorService executor = null
		private var tryShutdown = true
		private var =>Throwable exceptionProvider = null
		private var boolean cancelBackPropagation = false
		private var boolean cancelOriginalOnTimeout = false

		def void setTimeout(Pair<Long, TimeUnit> timeout) {
			Objects.requireNonNull(timeout)
			this.timeout = timeout.key
			this.timeUnit = timeout.value
		}

		def void setScheduler(ScheduledExecutorService scheduler) {
			this.executor = scheduler
		}

		def void setTryShutdownScheduler(boolean doShutdown) {
			this.tryShutdown = doShutdown
		}

		def void setExceptionProvider(=>Throwable exceptionProvider) {
			this.exceptionProvider = exceptionProvider;
		}

		def void setBackwardPropagateCancel(boolean cancelPropagation) {
			this.cancelBackPropagation = cancelPropagation
		}

		def void setCancelOriginalOnTimeout(boolean cancelOriginalOnTimeout) {
			this.cancelOriginalOnTimeout = cancelOriginalOnTimeout
		}
	}

	static def <R> CompletableFuture<R> orTimeout(CompletableFuture<R> fut, (OnTimeoutBuilder)=>void config) {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(config)
		val configData = new OnTimeoutBuilder
		config.apply(configData)

		val time = configData.timeout
		val timeUnit = configData.timeUnit ?: TimeUnit.SECONDS
		var isDefaultScheduler = false
		val scheduler = if (configData.executor !== null) {
				configData.executor
			} else {
				isDefaultScheduler = true
				defaultScheduler
			}
		val ()=>Throwable exceptionProvider = configData.exceptionProvider ?: [new TimeoutException]
		val cancelBackPropagation = configData.cancelBackPropagation
		val cancelOriginalOnTimeout = configData.cancelOriginalOnTimeout
		val shutdownScheduler = if (isDefaultScheduler) {
				true
			} else {
				configData.tryShutdown
			}
		orTimeout(fut, scheduler, shutdownScheduler, time, timeUnit, exceptionProvider, cancelBackPropagation,
			cancelOriginalOnTimeout)
	}

	// TODO flag if cancel backward propagation allowed
	// TODO document
	static private def <R> CompletableFuture<R> orTimeout(CompletableFuture<R> fut, ScheduledExecutorService scheduler,
		boolean shutdownScheduler, long time, TimeUnit unit, =>Throwable exceptionProvider,
		boolean cancelBackPropagation, boolean cancelOriginalOnTimeout) {
		// if the future is already completed, there is no point in even 
		// starting a timer
		if (fut.done) {
			return fut
		}

		val result = new CompletableFuture<R>

		val task = scheduler.schedule([|
			try {
				// since exception creation is expensive, we only create exception
				// if we really need to
				if (!result.done) {
					result.completeExceptionally(exceptionProvider.apply)
				}
			} catch (Throwable t) {
				// if problem providing exception, simply
				// complete result with the exception
				result.completeExceptionally(t)
			} finally {
				if (cancelOriginalOnTimeout) {
					fut.cancel
				}
				if (shutdownScheduler) {
					scheduler.shutdown()
				}
			}
			return // make Runnable not Callable
		], time, unit)

		fut.whenComplete [ r, ex |

			// try forwarding outcome of fut
			// to result. But result may already be
			// completed with timeout exception or cancelled
			if (ex !== null) {
				result.completeExceptionally(ex)
			} else {
				result.complete(r)
			}

			if (scheduler.isShutdown) {
				return
			}
			// try canceling the task, but on the scheduler threads
			// not on the thread completing the future
			try {
				scheduler.execute [
					// if the future is completed earlier
					// than cancellation, we can cancel the 
					// scheduled task
					val cancelled = task.cancel(true)
					// if the completion did not happen yet,
					// we need to 
					if (cancelled && shutdownScheduler) {
						scheduler.shutdown()
					}
				]
			} catch (RejectedExecutionException ree) {
				// so the scheduler is already shut down
				// or has to many tasks in task list.
				// In this case we can't cancel our operation
			}
		]

		if (cancelBackPropagation) {
			result.forwardCancellation(fut)
		}
		result
	}

	// ////////////////////////////////
	// Java 9 forward compatibility //
	// ////////////////////////////////
	// TODO variant with flag if cancel backward propagation allowed
	// TODO document
	static def <R> CompletableFuture<R> orTimeout(CompletableFuture<R> fut, long timeoutTime, TimeUnit unit) {
		val ()=>Throwable exceptionProvider = [new TimeoutException]
		val cancelBackPropagation = false
		val shutdownScheduler = true
		val cancelOriginalOnTimeout = false
		val scheduler = defaultScheduler
		fut.orTimeout(scheduler, shutdownScheduler, timeoutTime, unit, exceptionProvider, cancelBackPropagation,
			cancelOriginalOnTimeout)
	}

	// TODO documentation
	static def <R> CompletableFuture<R> copy(CompletableFuture<R> it) {
		thenApply[it]
	}

// TODO static def <T> CompletableFuture<T> completeOnTimeout​(CompletableFuture<T> it, T value, long timeout, TimeUnit unit)
// TODO static def <T> CompletableFuture<T> completeAsync​(CompletableFuture<R> it, Supplier<? extends T> supplier, Executor executor)
// TODO static def <T> CompletableFuture<T> completeAsync​(CompletableFuture<R> it, Supplier<? extends T> supplier)
// ///////////////
// Other Ideas //
// ///////////////
// TODO handleComposeAsync variants
// TODO thenAsync? all variants
// TODO static def <T> CompletableFuture<T> void filter(Predicate<T>) // returns future holding NoSuchElementException if not present (may be cached). Not filtering to null, there are too many methods on CF that can fail on null
// TODO static def <T> CompletableFuture<U> void filter(Class<U>) // returns future holding NoSuchElementException if not present (may be cached). Not filtering to null, there are too many methods on CF that can fail on null
// TODO static def <T> CompletableFuture<T> void filter(Predicate<T>, ()=>Throwable) // returns future holding provided Throwable if not present. Not filtering to null, there are too many methods on CF that can fail on null
}
