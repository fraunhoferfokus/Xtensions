package de.fhg.fokus.xtensions.concurrent

import java.util.concurrent.CompletableFuture
import java.util.concurrent.ForkJoinPool
import java.util.concurrent.TimeUnit
import java.util.concurrent.Executor
import java.util.concurrent.ScheduledExecutorService
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*
import java.util.Objects

/**
 * The static methods of this class start asynchronous computation, such as the {@code asyncSupply},
 * and {@code asyncRun} methods.
 */
class AsyncCompute {
	
	private new(){}



	/**
	 * This method will call the given {@code runAsync} function using the {@link ForkJoinPool#commonPool() common ForkJoinPool} passing 
	 * in a new {@code CompletableFuture} which is also being returned from this method. This future is supposed to be used to checked by 
	 * the {@code runAsync} function for cancellation from the outside. The value returned by the {@code runAsync} function will be used 
	 * to try to complete the returned future with. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object. The result or exception from the {@code runAsync} method will not be obtruded to
	 * the future; if the future is completed from the outside before completion of {@code runAsync}, its result will be ignored.
	 * 
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPoo}. The 
	 *  result of this function will be used to complete the CompletableFuture returned by this method.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for cancellation.
	 */
	public static def <R> CompletableFuture<R> asyncSupply((CompletableFuture<?>)=>R runAsync) {
		asyncSupply(ForkJoinPool.commonPool, runAsync)
	}

	/**
	 * This method will call the given {@code runAsync} function using the provided {@code executor}. A new {@code CompletableFuture}
	 * will be passed to {@code runAsync} and returned by this method. This parameter is supposed to be used by the {@code runAsync} function
	 * to check for cancellation from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future with. If {@code runAsync} throws a {@code Throwable}, it will be used to try to complete the 
	 * future exceptionally with the thrown object. The result or exception from the {@code runAsync} method will not be obtruded to
	 * the future; if the future is completed from the outside before completion of {@code runAsync}, its result will be ignored.
	 * 
	 * @param executor the executor used to execute {@code runAsync} concurrently.
	 * @param runAsync function to be executed using the provided {@code executor}.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for cancellation.
	 */
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

	/**
	 * This method will call the given {@code runAsync} function using the {@link ForkJoinPool#commonPool() common ForkJoinPool} with the {@code CompletableFuture}
	 * being returned. This parameter is supposed to be used to checked by the {@code runAsync} function
	 * for cancellation from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object. If the {@code runAsync} function does not provide a result value 
	 * after the timeout specified via the parameters {@code timeout} and {@code unit}, the returned future will be 
	 * canceled. Therefore the {@code runAsync} function is advised to check for cancellation of the future provided
	 * to it as parameter. If {@code runAsync} returns a value after the CompletableFuture was cancelled, the result
	 * will not appear in the CompletableFuture.
	 * 
	 * @param timeout Amount of time after which the returned {@code CompletableFuture} is cancelled, if it was not 
	 *  completed until then. The unit of the amount of time is specified via parameter {@code unit}.
	 * @param unit the time unit of the {@code timeout} parameter.
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPoo}. The 
	 *  result of this function will be used to complete the CompletableFuture returned by this method.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for cancellation.
	 */
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
	// TODO allow Duration here
	public static def <R> CompletableFuture<R> asyncSupply(Executor executor, long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(executor, runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	// TODO allow Duration here
	public static def <R> CompletableFuture<R> asyncSupply(Executor executor, ScheduledExecutorService scheduler, long timeout,
		TimeUnit unit, (CompletableFuture<?>)=>R runAsync) {
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
				if (fut.cancelled) {
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
	// TODO allow Duration here
	public static def <R> CompletableFuture<?> asyncRun(long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>void runAsync) {
		asyncRun(ForkJoinPool.commonPool, timeout, unit, runAsync)
	}

	// TODO documentation
	// TODO allow Duration here
	public static def <R> CompletableFuture<?> asyncRun(Executor executor, long timeout, TimeUnit unit, 
		(CompletableFuture<?>)=>void runAsync) {
		val fut = asyncRun(executor, runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	// TODO allow Duration here
	public static def <R> CompletableFuture<?> asyncRun(Executor executor, ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>void runAsync) {
		val fut = asyncRun(executor, runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	// TODO async(ExecutorService, ... ,RetryStrategy) <- when ExecutorService rejects task, retry instead 
	// RetryStrategy{ scheduleNextRetry(Runnable) }
	// RetryStrategy.fixed(int,TimeUnit)
	// RetryStrategy.fixed(ScheduledThreadPoolExecutor,int,TimeUnit)
}
