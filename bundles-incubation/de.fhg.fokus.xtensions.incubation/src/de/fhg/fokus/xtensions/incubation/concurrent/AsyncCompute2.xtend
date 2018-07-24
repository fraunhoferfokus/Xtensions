package de.fhg.fokus.xtensions.incubation.concurrent

import java.util.concurrent.CompletableFuture
import java.util.concurrent.ForkJoinPool
import java.util.concurrent.Executor
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit
import de.fhg.fokus.xtensions.incubation.concurrent.FutureCompletion.NowFutureCompletion
import de.fhg.fokus.xtensions.incubation.concurrent.FutureCompletion.FutureFutureCompletion
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*

/**
 * The static methods of this class start asynchronous computation, such as the {@code async}
 */
class AsyncCompute2 {
	
	private new(){}
	
		/**
	 * 
	 */
	static def <R> CompletableFuture<R> async((CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
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
	static def <R> CompletableFuture<R> async(Executor executor, (CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
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
	static def <R> CompletableFuture<R> async(long timeout, TimeUnit unit,
		(CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	// TODO allow Duration here
	static def <R> CompletableFuture<R> async(Executor executor, long timeout, TimeUnit unit,
		(CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(executor, runAsync)
		fut.cancelOnTimeout(timeout, unit)
	}

	// TODO documentation
	// TODO allow Duration here
	static def <R> CompletableFuture<R> async(ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		(CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}

	// TODO documentation
	// TODO allow Duration here
	static def <R> CompletableFuture<R> async(ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		Executor executor, (CompletableFuture<R>)=>FutureCompletion<R> runAsync) {
		val fut = async(executor, runAsync)
		fut.cancelOnTimeout(scheduler, timeout, unit)
	}
}