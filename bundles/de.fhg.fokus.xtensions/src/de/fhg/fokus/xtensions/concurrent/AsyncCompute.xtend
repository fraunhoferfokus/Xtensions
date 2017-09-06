package de.fhg.fokus.xtensions.concurrent

import java.util.concurrent.CompletableFuture
import java.util.concurrent.ForkJoinPool
import java.util.concurrent.TimeUnit
import java.util.concurrent.Executor
import java.util.concurrent.ScheduledExecutorService
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*
import java.util.Objects
import de.fhg.fokus.xtensions.concurrent.FutureCompletion.NowFutureCompletion
import de.fhg.fokus.xtensions.concurrent.FutureCompletion.FutureFutureCompletion

/**
 * The static methods of this class start asynchronous computation, such as the {@code async}, {@code asyncSupply},
 * and {@code asyncRun} methods.
 */
class AsyncCompute {
	
	private new(){}

	/**
	 * 
	 */
	public static def <R> CompletableFuture<R> async((CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		async(ForkJoinPool.commonPool, runAsync)
	}

	/**
	 * This method will call the given {@code runAsync} function using the provided {@code executor} with the {@code CompletableFuture}
	 * being returned. This parameter is supposed to be used to checked by the {@code runAsync} function
	 * for cancellation from the outside. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object.<br>
	 * <br>
	 * Based on the value returned by the {@code runAsync} function the future may be completed with a value. 
	 * The {@code FutureCompletion} return value of {@code runAsync} can be constructed using one 
	 * of the following factory functions:
	 * <ul>
	 * 	<li>{@link AsyncCompute#completeAsync() completeAsync()}</li>
	 * 	<li>{@link AsyncCompute#completedAlready() completedAlready()}</li>
	 * 	<li>{@link AsyncCompute#completeNow(Object) completeNow(T)}</li>
	 * 	<li>{@link AsyncCompute#completeWith(CompletableFuture) completeWith(CompletableFuture<? extends T>)}</li>
	 * </ul>
	 * This allows flexible handling of results allowing both direct return values, as well as returning values
	 * from other asynchronous operations via {@code CompletableFuture}. Note that cancellation of the returned
	 * {@code CompletableFuture} will be forwarded to futures provided as return values using 
	 * {@link AsyncCompute#completeWith(CompletableFuture) completeWith(CompletableFuture<? extends T>)}.
	 * 
	 * @param executor
	 * @param runAsync
	 * @return
	 */
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
					case result === FutureCompletion.ALREADY_COMPLETED_COMPLETION: {
						if (!fut.done) {
							val ex = new IllegalStateException(
								"Function claimed alreadyCompleted, while future was not completed.")
							fut.completeExceptionally(ex);
						}
					}
				// if NO_OP_COMPLETION or null: do nothing :)
				}
			} catch (Throwable t) {
				fut.completeExceptionally(t);
			}
		]
		fut
	}

	// TODO documentation
	// TODO allow Duration here
	public static def <R> CompletableFuture<R> async(long timeout, TimeUnit unit,
		(CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	// TODO allow Duration here
	public static def <R> CompletableFuture<R> async(Executor executor, long timeout, TimeUnit unit, 
		(CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(executor, runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	// TODO allow Duration here
	public static def <R> CompletableFuture<R> async(ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		(CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	// TODO documentation
	// TODO allow Duration here
	public static def <R> CompletableFuture<R> async(ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		Executor executor, (CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(executor, runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	/**
	 * This method will call the given {@code runAsync} function using the {@link ForkJoinPool#commonPool() common ForkJoinPoo} with the {@code CompletableFuture}
	 * being returned. This parameter is supposed to be used to checked by the {@code runAsync} function
	 * for cancellation from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object.
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
	 * This method will call the given {@code runAsync} function using the provided {@code executor} with the {@code CompletableFuture}
	 * being returned. This parameter is supposed to be used to checked by the {@code runAsync} function
	 * for cancellation from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object.
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
	 * This method will call the given {@code runAsync} function using the {@link ForkJoinPool#commonPool() common ForkJoinPoo} with the {@code CompletableFuture}
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
	public static def <R> CompletableFuture<?> asyncRun(ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		Executor executor, (CompletableFuture<?>)=>void runAsync) {
		val fut = asyncRun(executor, runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	// TODO async(ExecutorService, ... ,RetryStrategy) <- when ExecutorService rejects task, retry instead 
	// RetryStrategy{ scheduleNextRetry(Runnable) }
	// RetryStrategy.fixed(int,TimeUnit)
	// RetryStrategy.fixed(ScheduledThreadPoolExecutor,int,TimeUnit)
}
