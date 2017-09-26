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
	
	// TODO public static def <R> CompletableFuture<R> execute(Executor executor, (CompletableFuture<T>)=>void toExecute)
	// TODO async(ExecutorService, ... ,RetryStrategy) <- when ExecutorService rejects task, retry instead 
	// RetryStrategy{ scheduleNextRetry(Runnable) }
	// RetryStrategy.fixed(int,TimeUnit)
	// RetryStrategy.fixed(ScheduledThreadPoolExecutor,int,TimeUnit)
	// TODO asyncRun variants taking AtomicBoolean for checking cancellation
	// TODO allow java.time.Duration for specifying timeouts


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

	/**
	 * This method will call the given {@code runAsync} function using the {@link ForkJoinPool#commonPool() common ForkJoinPool} with the {@code CompletableFuture}
	 * being returned. This parameter is supposed to be used to checked by the {@code runAsync} function
	 * for cancellation from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object. If the {@code runAsync} function does not provide a result value 
	 * after the timeout specified via the parameters {@code timeout} and {@code unit}, the returned future will be 
	 * canceled. For the scheduling of the timeout the given {@code scheduler} will be used. The scheduler will <b>not</b> be 
	 * shut down after timeout. The {@code runAsync} function is advised to check for cancellation of the future provided
	 * to it as parameter. If {@code runAsync} returns a value after the CompletableFuture was cancelled or completed from
	 * the outside, the result will not appear in the CompletableFuture; the result will not be obtruted to the future.
	 * 
	 * @param scheduler is the executor service used to schedule the cancellation after timeout specified via 
	 *  {@code timeout} and {@code unit}.
	 * @param timeout Amount of time after which the returned {@code CompletableFuture} is cancelled, if it was not 
	 *  completed until then. The unit of the amount of time is specified via parameter {@code unit}.
	 * @param unit the time unit of the {@code timeout} parameter.
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPoo}. The 
	 *  result of this function will be used to complete the CompletableFuture returned by this method.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for cancellation.
	 */
	public static def <R> CompletableFuture<R> asyncSupply(ScheduledExecutorService scheduler, long timeout,
		TimeUnit unit, (CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	/**
	 * This method will call the given {@code runAsync} function using the given {@code executor}.
	 * being returned. This parameter is supposed to be used to checked by the {@code runAsync} function
	 * for cancellation from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object. If the {@code runAsync} function does not provide a result value 
	 * after the timeout specified via the parameters {@code timeout} and {@code unit}, the returned future will be 
	 * canceled. For the scheduling of the timeout the given {@code scheduler} will be used. The scheduler will <b>not</b> be 
	 * shut down after timeout. The {@code runAsync} function is advised to check for cancellation of the future provided
	 * to it as parameter. If {@code runAsync} returns a value after the CompletableFuture was cancelled or completed from
	 * the outside, the result will not appear in the CompletableFuture; the result will not be obtruted to the future.
	 * 
	 * @param executor is the executor used to run {@code runAsync} asynchronously.
	 * @param timeout Amount of time after which the returned {@code CompletableFuture} is cancelled, if it was not 
	 *  completed until then. The unit of the amount of time is specified via parameter {@code unit}.
	 * @param unit the time unit of the {@code timeout} parameter.
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPoo}. The 
	 *  result of this function will be used to complete the CompletableFuture returned by this method.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for cancellation.
	 */
	public static def <R> CompletableFuture<R> asyncSupply(Executor executor, long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(executor, runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	/**
	 * This method will call the given {@code runAsync} function using the given {@code executor}.
	 * being returned. This parameter is supposed to be used to checked by the {@code runAsync} function
	 * for cancellation from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object. If the {@code runAsync} function does not provide a result value 
	 * after the timeout specified via the parameters {@code timeout} and {@code unit}, the returned future will be 
	 * canceled. Therefore the {@code runAsync} function is advised to check for cancellation of the future provided
	 * to it as parameter. If {@code runAsync} returns a value after the CompletableFuture was cancelled, the result
	 * will not appear in the CompletableFuture.
	 * 
	 * @param executor is the executor used to run {@code runAsync} asynchronously.
	 * @param scheduler is the executor service used to schedule the cancellation after timeout specified via 
	 *  {@code timeout} and {@code unit}.
	 * @param timeout Amount of time after which the returned {@code CompletableFuture} is cancelled, if it was not 
	 *  completed until then. The unit of the amount of time is specified via parameter {@code unit}.
	 * @param unit the time unit of the {@code timeout} parameter.
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPoo}. The 
	 *  result of this function will be used to complete the CompletableFuture returned by this method.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for cancellation.
	 */
	public static def <R> CompletableFuture<R> asyncSupply(Executor executor, ScheduledExecutorService scheduler, long timeout,
		TimeUnit unit, (CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(executor, runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	/**
	 * Calls {@link #asyncRun(Executor,Function1) asyncRun(Executor,(CompletableFuture<?>)=>void)} with
	 * the common {@code ForkJoinPool} as the executor.
	 * @see AsyncCompute#asyncRun(Executor,Function1)
	 */
	public static def <R> CompletableFuture<?> asyncRun((CompletableFuture<?>)=>void runAsync) {
		asyncRun(ForkJoinPool.commonPool, runAsync)
	}

	/**
	 * This method will create a {@link CompletableFuture} and will run the given {@code runAsync} procedure
	 * asynchronously, by calling it on the given {@code executor}, passing the created future to it.
	 * The created future will then be returned from this function.<br>
	 * When the {@code runAsync} procedure completes, the future will be completed with a {@code null} value.
	 * If {@code runAsync} throws an exception, the future will be completed exceptionally with the thrown 
	 * exception. Neither the successful, nor the exceptional execution of {@code runAsync} will obtrude the
	 * result value into the future. If the future was completed in {@code runAsync} this result will stay
	 * in the future. However, it is advised to use the future in {@code runAsync} only to check for cancellation
	 * from the outside.
	 * @param executor will be used to execute {@code runAsync}
	 * @param runAsync procedure to execute using {@code executor}. The future returned from this method
	 *  will be passed to this procedure to allow checking for cancellation from the outside.
	 * @return future that will be created in this method and passed to {@code runAsync}.
	 */
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

	/**
	 * Calls {@link #asyncRun(Executor,long,TimeUnit,Function1) asyncRun(Executor,long,TimeUnit,(CompletableFuture<?>)=>void)} with
	 * the common {@code ForkJoinPool} as the executor.
	 * @see AsyncCompute#asyncRun(Executor,long,TimeUnit,Function1)
	 */
	public static def <R> CompletableFuture<?> asyncRun(long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>void runAsync) {
		asyncRun(ForkJoinPool.commonPool, timeout, unit, runAsync)
	}

	/**
	 * This method will create a {@link CompletableFuture} and will run the given {@code runAsync} procedure
	 * asynchronously, by calling it on the given {@code executor}, passing the created future to it.
	 * The created future will then be returned from this function.<br>
	 * When the {@code runAsync} procedure completes, the future will be completed with a {@code null} value.
	 * If {@code runAsync} throws an exception, the future will be completed exceptionally with the thrown 
	 * exception. If the {@code runAsync} procedure does not finish executing after a timeout defined via
	 * {@code timeout} and {@code unit}, the future will be cancelled.<br>
	 * Neither the successful, nor the exceptional execution of {@code runAsync} will obtrude the
	 * result value into the future. This includes completion via cancellation by timeout. 
	 * If the future was completed in {@code runAsync} this result will stay in the future. 
	 * However, it is advised to use the future in {@code runAsync} only to check for cancellation from the outside.
	 * @param executor will be used to execute {@code runAsync}
	 * @param runAsync procedure to execute using {@code executor}. The future returned from this method
	 *  will be passed to this procedure to allow checking for cancellation from the outside.
	 * @return future that will be created in this method and passed to {@code runAsync}.
	 */
	public static def <R> CompletableFuture<?> asyncRun(Executor executor, long timeout, TimeUnit unit, 
		(CompletableFuture<?>)=>void runAsync) {
		val fut = asyncRun(executor, runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	/**
	 * This method will create a {@link CompletableFuture} and will run the given {@code runAsync} procedure
	 * asynchronously, by calling it on the given {@code executor}, passing the created future to it.
	 * The created future will then be returned from this function.<br>
	 * When the {@code runAsync} procedure completes, the future will be completed with a {@code null} value.
	 * If {@code runAsync} throws an exception, the future will be completed exceptionally with the thrown 
	 * exception. If the {@code runAsync} procedure does not finish executing after a timeout defined via
	 * {@code timeout} and {@code unit}, the future will be cancelled. The timeout will be scheduled using 
	 * the given {@code scheduler}.<br>
	 * Neither the successful, nor the exceptional execution of {@code runAsync} will obtrude the
	 * result value into the future. This includes completion via cancellation by timeout. 
	 * If the future was completed in {@code runAsync} this result will stay in the future. 
	 * However, it is advised to use the future in {@code runAsync} only to check for cancellation from the outside.
	 * @param executor will be used to execute {@code runAsync}.
	 * @param scheduler is the executor service used to schedule the cancellation after timeout specified via 
	 *  {@code timeout} and {@code unit}.
	 * @param runAsync procedure to execute using {@code executor}. The future returned from this method
	 *  will be passed to this procedure to allow checking for cancellation from the outside.
	 * @return future that will be created in this method and passed to {@code runAsync}.
	 */
	public static def <R> CompletableFuture<?> asyncRun(Executor executor, ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>void runAsync) {
		val fut = asyncRun(executor, runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}
}
