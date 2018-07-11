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

import java.util.concurrent.CompletableFuture
import java.util.concurrent.ForkJoinPool
import java.util.concurrent.TimeUnit
import java.util.concurrent.Executor
import java.util.concurrent.ScheduledExecutorService
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*
import java.util.Objects
import java.util.concurrent.TimeoutException

/**
 * The static methods of this class start asynchronous computation, such as the {@code asyncSupply},
 * and {@code asyncRun} methods.
 */
final class AsyncCompute {

	private new() {
	}

	// TODO public static def <R> CompletableFuture<R> execute(Executor executor, (CompletableFuture<T>)=>void toExecute)
	// TODO async(ExecutorService, ... ,RetryStrategy) <- when ExecutorService rejects task, retry instead 
	// RetryStrategy{ scheduleNextRetry(Runnable) }
	// RetryStrategy.fixed(int,TimeUnit)
	// RetryStrategy.fixed(ScheduledThreadPoolExecutor,int,TimeUnit)
	// TODO asyncRun variants taking AtomicBoolean for checking cancellation?
	// TODO allow java.time.Duration for specifying timeouts
	// TODO CompletableFuture<R> asyncSupply(long, TimeUnit, =>Throwable, (CompletableFuture<?>)=>R)
	// TODO CompletableFuture<R> asyncSupply(ScheduledExecutorService, long, TimeUnit, =>Throwable, (CompletableFuture<?>)=>R)
	// TODO CompletableFuture<?> asyncRun(long, TimeUnit, =>Throwable, (CompletableFuture<?>)=>void)
	// TODO CompletableFuture<?> asyncRun(Executor, long, TimeUnit, =>Throwable, (CompletableFuture<?>)=>void)
	// TODO CompletableFuture<?> asyncRun(Executor, ScheduledExecutorService, long, TimeUnit, =>Throwable, (CompletableFuture<?>)=>void)
	/**
	 * This method will call the given {@code runAsync} function using the {@link ForkJoinPool#commonPool() common ForkJoinPool} passing 
	 * in a new {@code CompletableFuture} which is also being returned from this method. This future is supposed to be used to checked by 
	 * the {@code runAsync} function for completion from the outside. The value returned by the {@code runAsync} function will be used 
	 * to try to complete the returned future with. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object. The result or exception from the {@code runAsync} method will not be obtruded to
	 * the future; if the future is completed from the outside before completion of {@code runAsync}, its result will be ignored.
	 * 
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPool}. The 
	 *  result of this function will be used to complete the CompletableFuture returned by this method.
	 * @param <R> Type of the object supplied by {@code runAsync}, and that is promised to be made available in the 
	 *  returned future.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for completion.
	 * @throws NullPointerException if {@code runAsync} is {@code null}
	 */
	static def <R> CompletableFuture<R> asyncSupply((CompletableFuture<?>)=>R runAsync) {
		asyncSupply(ForkJoinPool.commonPool, runAsync)
	}

	/**
	 * This method will call the given {@code runAsync} function using the provided {@code executor}. A new {@code CompletableFuture}
	 * will be passed to {@code runAsync} and returned by this method. This parameter is supposed to be used by the {@code runAsync} function
	 * to check for completion from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future with. If {@code runAsync} throws a {@code Throwable}, it will be used to try to complete the 
	 * future exceptionally with the thrown object. The result or exception from the {@code runAsync} method will not be obtruded to
	 * the future; if the future is completed from the outside before completion of {@code runAsync}, its result will be ignored.
	 * 
	 * @param executor the executor used to execute {@code runAsync} concurrently.
	 * @param runAsync function to be executed using the provided {@code executor}.
	 * @param <R> Type of the object supplied by {@code runAsync}, and that is promised to be made available in the 
	 *  returned future.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for completion.
	 * @throws NullPointerException if {@code runAsync} is {@code null}
	 */
	static def <R> CompletableFuture<R> asyncSupply(Executor executor, (CompletableFuture<?>)=>R runAsync) {
		Objects.requireNonNull(runAsync)
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
	 * for cancellation/completion from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object. If the {@code runAsync} function does not provide a result value 
	 * after the timeout specified via the parameters {@code timeout} and {@code unit}, the returned future will be 
	 * completed exceptionally with a {@code TimoutException}. Therefore the {@code runAsync} function is advised to check for completion of the future provided
	 * to it as parameter. If {@code runAsync} returns a value after the CompletableFuture was completed, the result
	 * will not appear in the CompletableFuture.
	 * 
	 * @param timeout Amount of time after which the returned {@code CompletableFuture} is completed exceptionally, if it was not 
	 *  completed until then. The unit of the amount of time is specified via parameter {@code unit}.
	 * @param unit the time unit of the {@code timeout} parameter.
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPool}. The 
	 *  result of this function will be used to complete the CompletableFuture returned by this method.
	 * @param <R> Type of the object supplied by {@code runAsync}, and that is promised to be made available in the 
	 *  returned future.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for completion.
	 * @throws NullPointerException if {@code runAsync} is {@code null}
	 */
	static def <R> CompletableFuture<R> asyncSupply(long timeout, TimeUnit unit, (CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(runAsync)
		fut.failOnTimeout(timeout, unit)
	}

	/**
	 * This method will call the given {@code runAsync} function using the {@link ForkJoinPool#commonPool() common ForkJoinPool} with the {@code CompletableFuture}
	 * being returned. This parameter is supposed to be used to checked by the {@code runAsync} function
	 * for completion/cancellation from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object. If the {@code runAsync} function does not provide a result value 
	 * after the timeout specified via the parameters {@code timeout} and {@code unit}, the returned future will be 
	 * completed exceptionally with a new TimeoutException. For the scheduling of the timeout the given {@code scheduler} will be used. The scheduler will <b>not</b> be 
	 * shut down after timeout. The {@code runAsync} function is advised to check for completion of the future provided
	 * to it as parameter. If {@code runAsync} returns a value after the CompletableFuture was cancelled or completed from
	 * the outside, the result will not appear in the CompletableFuture; the result will not be obtruted to the future.
	 * 
	 * @param scheduler is the executor service used to schedule the exceptional completion after timeout specified via 
	 *  {@code timeout} and {@code unit}.
	 * @param timeout Amount of time after which the returned {@code CompletableFuture} is completed exceptionally, if it was not 
	 *  completed until then. The unit of the amount of time is specified via parameter {@code unit}.
	 * @param unit the time unit of the {@code timeout} parameter.
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPool}. The 
	 *  result of this function will be used to complete the CompletableFuture returned by this method.
	 * @param <R> Type of the object supplied by {@code runAsync}, and that is promised to be made available in the 
	 *  returned future.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for cancellation/completion.
	 */
	static def <R> CompletableFuture<R> asyncSupply(ScheduledExecutorService scheduler, long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(runAsync)
		fut.failOnTimeout(scheduler, timeout, unit)[new TimeoutException]
	}

	/**
	 * This method will call the given {@code runAsync} function using the given {@code executor}.
	 * being returned. This parameter is supposed to be used to checked by the {@code runAsync} function
	 * for completion from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object. If the {@code runAsync} function does not provide a result value 
	 * after the timeout specified via the parameters {@code timeout} and {@code unit}, the returned future will be 
	 * completed exceptionally with a new {@code TimeoutException}. For the scheduling of the timeout the given 
	 * {@code scheduler} will be used. The scheduler will <b>not</b> be shut down after timeout. 
	 * The {@code runAsync} function is advised to check for completion of the future provided
	 * to it as parameter. If {@code runAsync} returns a value after the CompletableFuture was cancelled or completed from
	 * the outside, the result will not appear in the CompletableFuture; the result will not be obtruted to the future.
	 * 
	 * @param executor is the executor used to run {@code runAsync} asynchronously.
	 * @param timeout Amount of time after which the returned {@code CompletableFuture} is completed exceptionally, if it was not 
	 *  completed until then. The unit of the amount of time is specified via parameter {@code unit}.
	 * @param unit the time unit of the {@code timeout} parameter.
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPool}. The 
	 *  result of this function will be used to complete the CompletableFuture returned by this method.
	 * @param <R> Type of the object supplied by {@code runAsync}, and that is promised to be made available in the 
	 *  returned future.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for completion.
	 */
	static def <R> CompletableFuture<R> asyncSupply(Executor executor, long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(executor, runAsync)
		fut.failOnTimeout(timeout, unit)
	}

	/**
	 * This method will call the given {@code runAsync} function using the given {@code executor}.
	 * being returned. This parameter is supposed to be used to checked by the {@code runAsync} function
	 * for completion from the outside. The value returned by the {@code runAsync} function will be used to try to 
	 * complete the returned future. If {@code runAsync} throws a {@code Throwable}, it will be used to complete the 
	 * future exceptionally with the thrown object. If the {@code runAsync} function does not provide a result value 
	 * after the timeout specified via the parameters {@code timeout} and {@code unit}, the returned future will be 
	 * completed exceptionally with a {@code TimeoutException}. Therefore the {@code runAsync} function is advised 
	 * to check for completion of the future provided to it as parameter. 
	 * If {@code runAsync} returns a value after the CompletableFuture was completed, the result
	 * will not appear in the CompletableFuture.
	 * 
	 * @param executor is the executor used to run {@code runAsync} asynchronously.
	 * @param scheduler is the executor service used to schedule the exceptional completion after timeout specified via 
	 *  {@code timeout} and {@code unit}.
	 * @param timeout Amount of time after which the returned {@code CompletableFuture} is completed exceptionally, if it was not 
	 *  completed until then. The unit of the amount of time is specified via parameter {@code unit}.
	 * @param unit the time unit of the {@code timeout} parameter.
	 * @param runAsync function to be executed on the {@link ForkJoinPool#commonPool() common ForkJoinPool}. The 
	 *  result of this function will be used to complete the CompletableFuture returned by this method.
	 * @param <R> Type of the object supplied by {@code runAsync}, and that is promised to be made available in the 
	 *  returned future.
	 * @return future that will used to provide result from concurrently executed {@code runAsync}. This future
	 *  may be cancelled by the user, the {@code runAsync} function is advised to check the future for completion.
	 */
	static def <R> CompletableFuture<R> asyncSupply(Executor executor, ScheduledExecutorService scheduler, long timeout,
		TimeUnit unit, (CompletableFuture<?>)=>R runAsync) {
		val CompletableFuture<R> fut = asyncSupply(executor, runAsync)
		fut.failOnTimeout(scheduler, timeout, unit)[new TimeoutException]
	}

	/**
	 * Calls {@link #asyncRun(Executor,org.eclipse.xtext.xbase.lib.Procedures.Procedure1) asyncRun(Executor,(CompletableFuture&lt;?&gt;)=>void)} with
	 * the common {@code ForkJoinPool} as the executor.
	 * @param runAsync the action to execute on the common {@code ForkJoinPool}, to which the returned future is passed.
	 * @return a {@code CompletableFuture} which will be completed, after successful execution of {@code runAsync}, or completed
	 *   exceptionally if {@code runAsync} throws an exception.
	 * @see AsyncCompute#asyncRun(Executor,org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 */
	static def CompletableFuture<?> asyncRun((CompletableFuture<?>)=>void runAsync) {
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
	 * in the future. However, it is advised to use the future in {@code runAsync} only to check for completion
	 * from the outside.
	 * @param executor will be used to execute {@code runAsync}
	 * @param runAsync procedure to execute using {@code executor}. The future returned from this method
	 *  will be passed to this procedure to allow checking for completion from the outside.
	 * @return future that will be created in this method and passed to {@code runAsync}.
	 */
	static def CompletableFuture<?> asyncRun(Executor executor, (CompletableFuture<?>)=>void runAsync) {
		Objects.requireNonNull(executor)
		Objects.requireNonNull(runAsync)
		val CompletableFuture<Object> fut = new CompletableFuture
		executor.execute [|
			try {
// TODO introduce flag for this behavior
//				if (fut.cancelled) {
//					return
//				}
				runAsync.apply(fut);
				fut.complete(null);
			} catch (Throwable t) {
				fut.completeExceptionally(t);
			}
		];
		fut
	}

	/**
	 * Calls {@link #asyncRun(Executor,long,TimeUnit,org.eclipse.xtext.xbase.lib.Procedures.Procedure1) asyncRun(Executor,long,TimeUnit,(CompletableFuture&lt;?&gt;)=>void)} with
	 * the common {@code ForkJoinPool} as the executor.
	 * @param timeout the time in {@code unit} after which the returned future will be completed exceptionally.
	 * @param unit the time unit for {@code timeout}.
	 * @param runAsync the action to be called on the common {@code ForkJoinPool}. The returned future will be passed to this function on invocation.
	 * @return the future which will be completed with a {@code null} value after successful execution of {@code runAsync} or exceptionally if {@code runAsync} throws an exception.
	 * @see AsyncCompute#asyncRun(Executor,long,TimeUnit,org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 */
	static def CompletableFuture<?> asyncRun(long timeout, TimeUnit unit, (CompletableFuture<?>)=>void runAsync) {
		asyncRun(ForkJoinPool.commonPool, timeout, unit, runAsync)
	}

	/**
	 * This method will create a {@link CompletableFuture} and will run the given {@code runAsync} procedure
	 * asynchronously, by calling it on the given {@code executor}, passing the created future to it.
	 * The created future will then be returned from this function.<br>
	 * When the {@code runAsync} procedure completes, the future will be completed with a {@code null} value.
	 * If {@code runAsync} throws an exception, the future will be completed exceptionally with the thrown 
	 * exception. If the {@code runAsync} procedure does not finish executing after a timeout defined via
	 * {@code timeout} and {@code unit}, the future will be completed exceptionally with a new {@link TimeoutException}.<br>
	 * Neither the successful, nor the exceptional execution of {@code runAsync} will obtrude the
	 * result value into the future. This includes completion via timeout. 
	 * If the future was completed in {@code runAsync} this result will stay in the future. 
	 * However, it is advised to use the future in {@code runAsync} only to check for completion from the outside.
	 * @param executor will be used to execute {@code runAsync}
	 * @param timeout the time in {@code unit} after which the returned future will be completed exceptionally.
	 * @param unit the time unit for {@code timeout}.
	 * @param runAsync procedure to execute using {@code executor}. The future returned from this method
	 *  will be passed to this procedure to allow checking for completion from the outside.
	 * @return future that will be created in this method and passed to {@code runAsync}.
	 */
	static def CompletableFuture<?> asyncRun(Executor executor, long timeout, TimeUnit unit,
		(CompletableFuture<?>)=>void runAsync) {
		val fut = asyncRun(executor, runAsync)
		fut.failOnTimeout(timeout, unit)
	}

	/**
	 * This method will create a {@link CompletableFuture} and will run the given {@code runAsync} procedure
	 * asynchronously, by calling it on the given {@code executor}, passing the created future to it.
	 * The created future will then be returned from this function.<br>
	 * When the {@code runAsync} procedure completes, the future will be completed with a {@code null} value.
	 * If {@code runAsync} throws an exception, the future will be completed exceptionally with the thrown 
	 * exception. If the {@code runAsync} procedure does not finish executing after a timeout defined via
	 * {@code timeout} and {@code unit}, the future will be completed exceptionally with a new {@code TimeoutException}. 
	 * The timeout will be scheduled using the given {@code scheduler}.<br>
	 * Neither the successful, nor the exceptional execution of {@code runAsync} will obtrude the
	 * result value into the future. This includes completion via by timeout. 
	 * If the future was completed in {@code runAsync} this result will stay in the future. 
	 * However, it is advised to use the future in {@code runAsync} only to check for completion from the outside.
	 * @param executor will be used to execute {@code runAsync}.
	 * @param scheduler is the executor service used to schedule the exceptional completion after timeout specified via 
	 *  {@code timeout} and {@code unit}.
	 * @param timeout the time in {@code unit} after which the returned future will be completed exceptionally.
	 * @param unit the time unit for {@code timeout}.
	 * @param runAsync the action to be called on the common {@code ForkJoinPool}. The returned future will be passed to this function on invocation.
	 * @param runAsync procedure to execute using {@code executor}. The future returned from this method
	 *  will be passed to this procedure to allow checking for completion from the outside.
	 * @return future that will be created in this method and passed to {@code runAsync}.
	 */
	static def CompletableFuture<?> asyncRun(Executor executor, ScheduledExecutorService scheduler, long timeout,
		TimeUnit unit, (CompletableFuture<?>)=>void runAsync) {
		val fut = asyncRun(executor, runAsync)
		fut.failOnTimeout(scheduler, timeout, unit)[new TimeoutException]
	}
}
