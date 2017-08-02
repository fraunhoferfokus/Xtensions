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
	
	private new(){}

	/**
	 * An instance of this class has to be provided by the function passed to
	 * any of the {@code async} methods. Since this 
	 * Create instance using one of the following functions:
	 * <ul>
	 * 	<li>{@link AsyncCompute#completeAsync() completeAsync()}</li>
	 * 	<li>{@link AsyncCompute#completedAlready() completedAllready()}</li>
	 * 	<li>{@link AsyncCompute#completeNow(Object) completeNow(T)}</li>
	 * 	<li>{@link AsyncCompute#completeWith(CompletableFuture) completeWith(CompletableFuture<? extends T>)}</li>
	 * </ul>
	 */
	public static class FutureCompletion<T> {
		package new() {
		}
	}

	/**
	 * Factory method to create a FutureCompletion instance that can be used
	 * as a return value in a function passed to an async function. <br>
	 * The created FutureCompletion indicates, that the result future is completed asynchronously.
	 * This means that the CompletedFuture passed into the function must be called 
	 * "manually". This can also be done asynchronously on a different thread. Note that 
	 * the caller method cannot ensure completion of the future holding the result value.
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
	 * as a return value in a function passed to an async function.<br>
	 * The value returned by this value indicates that the future provided to 
	 * the {@code async} method was already completed. Note that if this value 
	 * is provided without actually having completed the future, the future will
	 * be completed exceptionally by the {@code async} method.
	 * 
	 * @return utureCompletion to return by functions passed to {@code async} method.
	 * @see #async(Function1)
	 * @see #async(Executor, Function1)
	 * @see #async(long, TimeUnit, Function1)
	 * @see #async(long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
	 */
	public static def <T> FutureCompletion<T> completedAlready() {
		// completion is the same for every type T
		ALREADY_COMPLETED_COMPLETION as FutureCompletion<?> as FutureCompletion<T>
	}

	/** 
	 * Factory method to create a FutureCompletion instance that can be used
	 * as a return value in a function passed to an async function.<br>
	 * The value returned by this method indicates that the given {@code value}
	 * should be used to complete the result future.
	 * 
	 * @param value used to complete result future with
	 * @return FutureCompletion to return by functions passed to {@code async} method.
	 * @see #async(Function1)
	 * @see #async(Executor, Function1)
	 * @see #async(long, TimeUnit, Function1)
	 * @see #async(long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
	 */
	public static def <T> FutureCompletion<T> completeNow(T value) {
		return new NowFutureCompletion(value)
	}

	/** 
	 * Factory method to create a FutureCompletion instance that can be used
	 * as a return value in a function passed to an async function.<br>
	 * The value returned by this method indicates that the resulting completable
	 * future should be completed with the value provided by the 
	 * 
	 * TODO FURTHER DESCRIPTION, cancellation forward
	 * 
	 * @param futureResult
	 * @return FutureCompletion to return by functions passed to {@code async} method.
	 * @see #async(Function1)
	 * @see #async(Executor, Function1)
	 * @see #async(long, TimeUnit, Function1)
	 * @see #async(long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
	 * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
	 */
	public static def <T> FutureCompletion<T> completeWith(CompletableFuture<? extends T> futureResult) {
		return new FutureFutureCompletion(futureResult)
	}

	private static val NO_OP_COMPLETION = new FutureCompletion
	private static val ALREADY_COMPLETED_COMPLETION = new FutureCompletion

	/**
	 * Subclass of {@link FutureCompletion} holding a result value of type {@code T}
	 */
	private static final class NowFutureCompletion<T> extends FutureCompletion<T> {
		val T value

		package new(T t) {
			value = t
		}
	}

	/**
	 * Subclass of {@link FutureCompletion} holding a future of {@code T} holding the 
	 * value to be returned.
	 */
	private static final class FutureFutureCompletion<T> extends FutureCompletion<T> {
		val CompletableFuture<? extends T> value

		package new(CompletableFuture<? extends T> f) {
			value = f
		}
	}

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
					case result === ALREADY_COMPLETED_COMPLETION: {
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
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPoo}.
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

	// TODO documentation
	// TODO allow Duration here
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

}
