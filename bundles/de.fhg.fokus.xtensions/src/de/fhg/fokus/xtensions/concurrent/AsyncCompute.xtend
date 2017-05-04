package de.fhg.fokus.xtensions.concurrent

import java.util.concurrent.CompletableFuture
import java.util.concurrent.ForkJoinPool
import java.util.concurrent.TimeUnit
import java.util.concurrent.Executor
import java.util.concurrent.ScheduledExecutorService
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*
import java.util.Objects

/**
 * The static methods of this class start asynchronous computation, such as the {@code async}, {@code asyncSupply},
 * and {@code asyncRun} methods.
 */
class AsyncCompute {

	/**
	 * An instance of this class has to be provided by the function passed to
	 * any of the {@code async} methods. Since this 
	 * Create instance using one of the following functions:
	 * <ul>
	 * 	<em>{@link #completeAsync()}</em>
	 * 	<em>{@link #completedAllready()}</em>
	 * 	<em>{@link #completeNow(Object)}</em>
	 * 	<em>{@link #completeWith(CompletableFuture)}</em>
	 * </ul>
	 */
	public static class FutureCompletion<T> {
		package new() {
		}
	}

	/**
	 * Factory method to create a FutureCompletion instance that can be used
	 * as a return value in a function passed to an async function. The created
	 * FutureCompletion indicates, that the result future is completed asynchronously.
	 * This means that the CompletedFuture passed into the function must be called 
	 * "manually". This can also be done asynchronously on a different thread.
	 * @see #async(Function1)
	 * @see #async(Executor, Function1)
	 * @see #async(long, TimeUnit, Function1)
	 * @see #async(long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
	 */
	public static def <T> FutureCompletion<T> completeAsync() {
		// NoOp completion is the same for every type T
		NO_OP_COMPLETION as FutureCompletion<?> as FutureCompletion<T>
	}

	/** 
	 * Factory method to create a FutureCompletion instance that can be used
	 * as a return value in a function passed to an async function.
	 * TODO FURTHER DESCRIPTION
	 * 
	 * @see #async(Function1)
	 * @see #async(Executor, Function1)
	 * @see #async(long, TimeUnit, Function1)
	 * @see #async(long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
	 */
	public static def <T> FutureCompletion<T> completedAlready() {
		// NoOp completion is the same for every type T
		NO_OP_COMPLETION as FutureCompletion<?> as FutureCompletion<T>
	}

	/** 
	 * Factory method to create a FutureCompletion instance that can be used
	 * as a return value in a function passed to an async function.
	 * TODO FURTHER DESCRIPTION
	 * 
	 * @see #async(Function1)
	 * @see #async(Executor, Function1)
	 * @see #async(long, TimeUnit, Function1)
	 * @see #async(long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
	 */
	public static def <T> FutureCompletion<T> completeNow(T t) {
		return new NowFutureCompletion(t)
	}

	/** 
	 * Factory method to create a FutureCompletion instance that can be used
	 * as a return value in a function passed to an async function.
	 * TODO FURTHER DESCRIPTION, cancellation forward
	 * 
	 * @see #async(Function1)
	 * @see #async(Executor, Function1)
	 * @see #async(long, TimeUnit, Function1)
	 * @see #async(long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
	 */
	public static def <T> FutureCompletion<T> completeWith(CompletableFuture<? extends T> t) {
		return new FutureFutureCompletion(t)
	}

	private static val NO_OP_COMPLETION = new FutureCompletion

	private static class NowFutureCompletion<T> extends FutureCompletion<T> {
		val T value

		package new(T t) {
			value = t
		}
	}

	private static class FutureFutureCompletion<T> extends FutureCompletion<T> {
		val CompletableFuture<? extends T> value

		package new(CompletableFuture<? extends T> f) {
			value = f
		}
	}

	public static def <R> CompletableFuture<R> async((CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		async(ForkJoinPool.commonPool, runAsync)
	}

	public static def <R> CompletableFuture<R> async(Executor executor,
		(CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val CompletableFuture<R> fut = new CompletableFuture<R>
		executor.execute [|
			try {
				switch result : runAsync.apply(fut) {
					NowFutureCompletion<R>:
						fut.complete(result.value)
					// If completed with Future forward result to returned
					// future, and forward cancellation from outside to 
					// result future
					FutureFutureCompletion<R>: {
						val resultFut = result.value
						if (resultFut === null) {
							fut.complete(null as R)
						} else {
							resultFut.forwardTo(fut)
							fut.forwardCancellation(resultFut)
						}
					}
				// if NO_OP_COMPLETION: do nothing :)
				}
			} catch (Throwable t) {
				fut.completeExceptionally(t);
			}
		]
		fut
	}

	// TODO documentation
	public static def <R> CompletableFuture<R> async(long timeout, TimeUnit unit,
		(CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	public static def <R> CompletableFuture<R> async(long timeout, TimeUnit unit, Executor executor,
		(CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(executor, runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	public static def <R> CompletableFuture<R> async(ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		(CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	// TODO documentation
	public static def <R> CompletableFuture<R> async(ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		Executor executor, (CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(executor, runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	// TODO documentation
	public static def <R> CompletableFuture<R> asyncSupply((CompletableFuture<?>)=>R runAsync) {
		asyncSupply(ForkJoinPool.commonPool, runAsync)
	}

	// TODO documentation
	public static def <R> CompletableFuture<R> asyncSupply(Executor executor, (CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = new CompletableFuture
		executor.execute [|
			try {
				val result = runAsync.apply(fut);
				fut.complete(result);
			} catch (Throwable t) {
				fut.completeExceptionally(t);
			}
		];
		fut
	}

	// TODO documentation
	public static def <R> CompletableFuture<R> asyncSupply(long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	public static def <R> CompletableFuture<R> asyncSupply(ScheduledExecutorService scheduler, long timeout,
		TimeUnit unit, (CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	// TODO documentation
	public static def <R> CompletableFuture<R> asyncSupply(long timeout, TimeUnit unit, Executor executor,
		(CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(executor, runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	public static def <R> CompletableFuture<R> asyncSupply(ScheduledExecutorService scheduler, long timeout,
		TimeUnit unit, Executor executor, (CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(executor, runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	// TODO documentation
	/**
	 * Calls {@link #asyncRun(Executor,Function1) asyncRun(Executor,(CompletableFuture<?>)=>void)} with
	 * the common {@code ForkJoinPool} as the executor.
	 */
	public static def <R> CompletableFuture<?> asyncRun((CompletableFuture<?>)=>void runAsync) {
		asyncRun(ForkJoinPool.commonPool, runAsync)
	}

	// TODO documentation
	public static def <R> CompletableFuture<?> asyncRun(Executor executor, (CompletableFuture<?>)=>void runAsync) {
		Objects.requireNonNull(executor)
		Objects.requireNonNull(runAsync)
		val CompletableFuture<Object> fut = new CompletableFuture
		executor.execute [|
			try {
				if(fut.cancelled) {
					return
				}
				runAsync.apply(fut);
				fut.complete(null);
			} catch (Throwable t) {
				fut.completeExceptionally(t);
			}
		];
		fut
	}

	// TODO documentation
	public static def <R> CompletableFuture<?> asyncRun(long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>void runAsync) {
		asyncRun(timeout, unit, ForkJoinPool.commonPool, runAsync)
	}

	// TODO documentation
	public static def <R> CompletableFuture<?> asyncRun(long timeout, TimeUnit unit, Executor executor,
		(CompletableFuture<?>)=>void runAsync) {
		val fut = asyncRun(executor, runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	public static def <R> CompletableFuture<?> asyncRun(ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		Executor executor, (CompletableFuture<?>)=>void runAsync) {
		val fut = asyncRun(executor, runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

}
