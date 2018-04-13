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

import java.time.Duration
import java.util.Objects
import java.util.concurrent.CompletableFuture
import java.util.concurrent.Delayed
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.ScheduledThreadPoolExecutor
import java.util.concurrent.TimeUnit

import static extension de.fhg.fokus.xtensions.concurrent.internal.DurationToTimeConversion.*
import static extension java.util.Objects.*

/**
 * This class provides static functions that can be used to schedule tasks that
 * are either repeated or delayed by a given amount of time. The provided functions
 * are wrappers around {@link ScheduledExecutorService}, but provides more readable 
 * method names and work with {@link CompletableFuture}s for better composability 
 * of actions.
 */
final class SchedulingUtil {

	private new() {
		throw new IllegalStateException("SchedulingExtensions not intended to be instantiated")
	}

	/**
	 * This class implements both {@link CompletableFuture} and {@link ScheduledFuture},
	 * so it can be used in a non-blocking fashion, but still be asked for the delay for
	 * the next execution of a scheduled task.<br>
	 * This class is not intended to be sub-classed outside of the SchedulingUtil.
	 * 
	 * @param <T> The type of the result value the future is wrapping
	 */
	public abstract static class ScheduledCompletableFuture<T> extends CompletableFuture<T> implements ScheduledFuture<T> {

		package new() {
		}

	}
	
	/**
	 * This ScheduledCompletableFuture is wrapping around a {@code ScheduledFuture<?>}, forwarding the {@code getDelay}
	 * and {@code compareTo} calls to the ones from the wrapped. The wrapped {@code ScheduledFuture<?>} is provided
	 * by subclasses via the the abstract {@link #getScheduled()} method. Note that the wrapped future will be tried
	 * to be cancelled, as soon as the wrapped future completes. 
	 */
	private abstract static class WrappingScheduledCompletableFuture<T> extends ScheduledCompletableFuture<T> {
		
		protected abstract def ScheduledFuture<?> getScheduled()
		
		new() {
			this.whenComplete[
				scheduled.cancel(false)
			]
		}

		override long getDelay(TimeUnit unit) {
			scheduled.getDelay(unit)
		}

		override int compareTo(Delayed o) {
			scheduled.compareTo(o)
		}
	}

	/**
	 * Adds delay information to an action to be scheduled. Instances of this class are created via one of the 
	 * following methods:
	 * <ul>
	 * 	<li>{@link SchedulingUtil#repeatEvery(long, TimeUnit)}</li>
	 * 	<li>{@link SchedulingUtil#repeatEvery(ScheduledExecutorService, long, TimeUnit)}</li>
	 * </ul>
	 * When the {@link DelaySpecifier#withInitialDelay(long, org.eclipse.xtext.xbase.lib.Procedures.Procedure1) withInitialDelay(long initialDelay, (CompletableFuture&lt;?&gt;)=&gt;void action)}
	 * method is called the scheduling will be started, by scheduling the given action according to the scheduling 
	 * information given to the function producing the DelaySpecifier and the given delay passed to withInitialDelay.<br>
	 * This class is not intended to be sub-classed outside of the SchdulingExtensions.
	 */
	public abstract static class DelaySpecifier {

		private new() {
		}

		/**
		 * Schedules the given {@code action} according to the time interval specified in the {@code repeatEvery}
		 * method used to construct this {@code DelaySpecifier}. The given {@code initalDelay} specifies
		 * the initial time (in the time unit specified in the {@code repeatEvery} method) before the 
		 * {@code action} is invoked the first time.
		 * @param initialDelay time (in the unit defined in {@code repeatEvery} method) after which the 
		 *   first repeated execution of the given action will start
		 * @param action the action to be called repeatedly with the returned future (which can be used to check for cancellation). 
		 * @return the future which can be used to track repeated computation of {@code action}.
		 * @throws IllegalArgumentException if {@code initialDelay <= 0}
		 * @throws NullPointerException if {@code action === null}
		 */
		abstract def ScheduledCompletableFuture<?> withInitialDelay(long initialDelay,
			(ScheduledCompletableFuture<?>)=>void action);
	}

	/**
	 * This method will schedule the given {@code action} to run in a fixed interval specified via {@code period}
	 * starting from the time this method is called. If {@code action} throws, the action will un-scheduled and not
	 * called anymore. The returned {@code ScheduledCompletableFuture} will also be passed to the action on every 
	 * scheduled call. The future will only completed via an exception
	 * thrown from {@code action}, from the outside by the caller or by the {@code action}. When the future is be completed
	 * (no matter how), the {@code action} will be un-scheduled and not be called again.<br><br>
	 * Be aware that the execution of {@code action} will be performed on a single Thread, so if the execution of {@code action}
	 * takes longer than the specified {@code period}, following executions are delayed. Consider using 
	 * {@link SchedulingUtil#repeatEvery(ScheduledExecutorService, Duration, org.eclipse.xtext.xbase.lib.Procedures.Procedure1) repeatEvery(ScheduledExecutorService, Duration, (CompletableFuture&lt;?&gt;)=&gt;void)}
	 * to specify an own {@code ScheduledExecutorService} which may provide more threads for execution.<br><br>
	 * Note: The use of {@code Duration} may cause a loss in time precision, if the overall period exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped. Alternatively you can call 
	 * {@link SchedulingUtil#repeatEvery(long, TimeUnit, org.eclipse.xtext.xbase.lib.Procedures.Procedure1) repeatEvery(long, TimeUnit, (CompletableFuture&lt;?&gt;)=&gt;void)} or 
	 * {@link SchedulingUtil#repeatEvery(ScheduledExecutorService, long, TimeUnit, org.eclipse.xtext.xbase.lib.Procedures.Procedure1) 
	 * repeatEvery(ScheduledExecutorService, long, TimeUnit, (CompletableFuture&lt;?&gt;)=&gt;void)}
	 * to specify the time without loss of precision.
	 * 
	 * @param period at which the given {@code action} should be called.
	 * @param action action to be scheduled to be repeatedly called at the given {@code period}. The action will be called with the 
	 *  returned {@code ScheduledCompletableFuture} which can be used to check for cancellation or complete to stop further executions
	 *  of the action. If the action throws and exception the future will be completed exceptionally with the thrown exception and the 
	 *  action will not be un-scheduled and not called again.
	 * @return a future that can be checked for the delay until next execution of {@code action} and completed to stop further executions
	 *  of {@code action}. 
	 * @see SchedulingUtil#repeatEvery(long, TimeUnit, org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 * @throws java.lang.NullPointerException if {@code period} or {@code action} is {@code null}
	 * @throws java.lang.IllegalArgumentException if {@code period} is a negative duration
	 */
	public static def ScheduledCompletableFuture<?> repeatEvery(Duration period,
		(ScheduledCompletableFuture<?>)=>void action) {
		action.requireNonNull
		period.requireNonNull
		period.requirePositive
		val time = period.toTime
		repeatEvery(time.amount, time.unit, action)
	}

	/**
	 * This method will schedule the given {@code action} to run in a fixed interval specified via {@code period}
	 * starting from the time this method is called. If {@code action} throws, the action will un-scheduled and not
	 * called anymore. The returned {@code ScheduledCompletableFuture} will also be passed to the action on every 
	 * scheduled call. The future will only completed via an exception
	 * thrown from {@code action}, from the outside by the caller or by the {@code action}. When the future is be completed
	 * (no matter how), the {@code action} will be un-scheduled and not be called again.<br><br>
	 * The {@code action} will be scheduled and then executed on the given {@code scheduler}.<br><br>
	 * Note: The use of {@code Duration} may cause a loss in time precision, if the overall period exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped. Alternatively you can call 
	 * {@link SchedulingUtil#repeatEvery(long, TimeUnit, org.eclipse.xtext.xbase.lib.Procedures.Procedure1) repeatEvery(long, TimeUnit, (CompletableFuture&lt;?&gt;)=&gt;void)} or 
	 * {@link SchedulingUtil#repeatEvery(ScheduledExecutorService, long, TimeUnit, org.eclipse.xtext.xbase.lib.Procedures.Procedure1) repeatEvery(ScheduledExecutorService, long, TimeUnit, (CompletableFuture&lt;?&gt;)=&gt;void)}
	 * to specify the time without loss of precision.<br>
	 * 
	 * @param scheduler the executor service used for scheduling the given {@code action}.
	 * @param period at which the given {@code action} should be called.
	 * @param action action to be scheduled to be repeatedly called at the given {@code period}. The action will be called with the 
	 *  returned {@code ScheduledCompletableFuture} which can be used to check for cancellation or complete to stop further executions
	 *  of the action. If the action throws and exception the future will be completed exceptionally with the thrown exception and the 
	 *  action will not be un-scheduled and not called again.
	 * @return a future that can be checked for the delay until next execution of {@code action} and completed to stop further executions
	 *  of {@code action}. 
	 * @throws java.lang.NullPointerException if {@code period}, {@code scheduler}, or {@code action} is {@code null}
	 * @throws java.lang.IllegalArgumentException if {@code period} is a negative duration
	 */
	public static def ScheduledCompletableFuture<?> repeatEvery(ScheduledExecutorService scheduler, Duration period,
		(CompletableFuture<?>)=>void action) {
		scheduler.requireNonNull
		action.requireNonNull
		period.requireNonNull
		period.requirePositive
		val time = period.toTime
		scheduler.repeatEvery(time.amount, time.unit, action)
	}

	/**
	 * This method will schedule the given {@code action} to run in a fixed time interval specified via {@code period} and {@code unit}
	 * starting from the time this method is called. If {@code action} throws, the action will un-scheduled and not
	 * called anymore. The returned {@code ScheduledCompletableFuture} will also be passed to the action on every 
	 * scheduled call. The future will only completed via an exception
	 * thrown from {@code action}, from the outside by the caller or by the {@code action}. When the future is be completed
	 * (no matter how), the {@code action} will be un-scheduled and not be called again.<br><br>
	 * Be aware that the execution of {@code action} will be performed on a single Thread, so if the execution of {@code action}
	 * takes longer than the specified {@code period}, following executions are delayed. Consider using 
	 * {@link SchedulingUtil#repeatEvery(ScheduledExecutorService, Duration, org.eclipse.xtext.xbase.lib.Procedures.Procedure1) repeatEvery(ScheduledExecutorService, Duration, (CompletableFuture&lt;?&gt;)=&gt;void)}
	 * to specify an own {@code ScheduledExecutorService} which may provide more threads for execution.
	 * 
	 * @param period duration in {@code unit} at which the given {@code action} should be called.
	 * @param unit time unit of {@code period} for scheduling {@code action}.
	 * @param action action to be scheduled to be repeatedly called at the given {@code period}. The action will be called with the 
	 *  returned {@code ScheduledCompletableFuture} which can be used to check for cancellation or complete to stop further executions
	 *  of the action. If the action throws and exception the future will be completed exceptionally with the thrown exception and the 
	 *  action will not be un-scheduled and not called again.
	 * @return the future that can be used to check for delay till next periodic execution of {@code action} or cancellation
	 *  of further executions of {@code action}.
	 * @throws NullPointerException if {@code action} or {@code unit} is {@code null}.
	 * @throws IllegalArgumentException if {@code period} is {@code <= 0}
	 */
	public static def ScheduledCompletableFuture<?> repeatEvery(long period, TimeUnit unit,
		(ScheduledCompletableFuture<?>)=>void action) {
		unit.requireNonNull
		action.requireNonNull
		if (period <= 0) {
			throw new IllegalArgumentException("period must be > 0, but was " + period);
		}
		scheduleAtFixedRate(0, period, unit, action)
	}

	/**
	 * This method will schedule the given {@code action} to run in a fixed time interval specified via {@code period} and {@code unit}
	 * starting from the time this method is called. If {@code action} throws, the action will un-scheduled and not
	 * called anymore. The returned {@code ScheduledCompletableFuture} will also be passed to the action on every 
	 * scheduled call. The future will only completed via an exception
	 * thrown from {@code action}, from the outside by the caller or by the {@code action}. When the future is be completed
	 * (no matter how), the {@code action} will be un-scheduled and not be called again.<br><br>
	 * The {@code action} will be scheduled and executed on the given {@code scheduler}.
	 * 
	 * @param scheduler will be used to schedule repeated execution of {@code action}
	 * @param period duration in {@code unit} at which the given {@code action} should be called.
	 * @param unit time unit of {@code period} for scheduling {@code action}.
	 * @param action action to be scheduled to be repeatedly called at the given {@code period}. The action will be called with the 
	 *  returned {@code ScheduledCompletableFuture} which can be used to check for cancellation or complete to stop further executions
	 *  of the action. If the action throws and exception the future will be completed exceptionally with the thrown exception and the 
	 *  action will not be un-scheduled and not called again.
	 * @return the future that can be used to check for delay till next periodic execution of {@code action} or cancellation
	 * @throws NullPointerException if {@code action} or {@code unit} is {@code null}.
	 * @throws IllegalArgumentException if {@code period} is {@code <= 0}
	 */
	public static def ScheduledCompletableFuture<?> repeatEvery(ScheduledExecutorService scheduler, long period,
		TimeUnit unit, (ScheduledCompletableFuture<?>)=>void action) {
		scheduler.requireNonNull
		unit.requireNonNull
		action.requireNonNull
		if (period <= 0) {
			throw new IllegalArgumentException("period must be > 0, but was " + period);
		}

		scheduler.scheduleAtFixedRate(0, period, unit, action)
	}

	/**
	 * This method specifies the fixed time interval in which an action will be repeatedly invoked.
	 * The returned {@link DelaySpecifier} allows to specify an initial delay and the actual action
	 * to be scheduled.<br>
	 * Be aware that the execution of the scheduled action will be performed on a single Thread, so if the execution of
	 * the action takes longer than the specified {@code period}, following executions are delayed. 
	 * Consider using {@link SchedulingUtil#repeatEvery(ScheduledExecutorService, long, TimeUnit) repeatEvery(ScheduledExecutorService, long, TimeUnit)}
	 * if you want to provide a custom {@code ScheduledExecutorService}.
	 * 
	 * @param period duration in {@code unit} at which action, specified on the returned {@code DelaySpecifier}, should be called.
	 * @param unit time unit of {@code period} for scheduling action specified on the returned {@code DelaySpecifier}.
	 * @return object to specify initial delay (of time unit {@code unit}) and the action to be scheduled.
	 * @throws NullPointerException if {@code unit} is {@code null}.
	 * @throws IllegalArgumentException if {@code period} is {@code <= 0}
	 */
	public static def DelaySpecifier repeatEvery(long period, TimeUnit unit) {
		if (period <= 0) {
			throw new IllegalArgumentException("period must be > 0")
		}
		if (unit === null) {
			throw new NullPointerException
		}
		new DelaySpecifier {

			override withInitialDelay(long initialDelay, (ScheduledCompletableFuture<?>)=>void action) {
				if (initialDelay <= 0) {
					throw new IllegalArgumentException("period must be > 0")
				}
				if (action === null) {
					throw new NullPointerException("action must not be null")
				}
				scheduleAtFixedRate(initialDelay, period, unit, action)
			}

		}
	}

	/**
	 * This method specifies the fixed time interval in which an action will be repeatedly invoked.
	 * The returned {@link DelaySpecifier} allows to specify an initial delay and the actual action
	 * to be scheduled.<br>
	 * The action is scheduled using the given {@code scheduler}.
	 * 
	 * @param scheduler the executor service used for scheduling the {@code action} provided to the returned {@code DelaySpecifier}.
	 * @param period duration in {@code unit} at which action, specified on the returned {@code DelaySpecifier}, should be called.
	 * @param unit time unit of {@code period} for scheduling action specified on the returned {@code DelaySpecifier}.
	 * @return object to specify initial delay (of time unit {@code unit}) and the action to be scheduled.
	 * @throws NullPointerException if {@code unit} or {@code scheduler} is {@code null}.
	 * @throws IllegalArgumentException if {@code period} is {@code <= 0}
	 */
	public static def DelaySpecifier repeatEvery(ScheduledExecutorService scheduler, long period, TimeUnit unit) {
		if (period <= 0) {
			throw new IllegalArgumentException("period must be > 0")
		}
		if (unit === null) {
			throw new NullPointerException("Time unit must not be null")
		}
		if (scheduler === null) {
			throw new NullPointerException("Scheduler must not be null")
		}
		new DelaySpecifier {

			override withInitialDelay(long initialDelay, (ScheduledCompletableFuture<?>)=>void action) {
				if (initialDelay <= 0) {
					throw new IllegalArgumentException("period must be > 0")
				}
				if (action === null) {
					throw new NullPointerException("action must not be null")
				}
				scheduler.scheduleAtFixedRate(initialDelay, period, unit, action)
			}

		}
	}

	private static def ScheduledCompletableFuture<?> scheduleAtFixedRate(long initialDelay, long period, TimeUnit unit,
		(ScheduledCompletableFuture<?>)=>void action) {
		val scheduler = createDefaultScheduledExecutorService
		val result = scheduler.scheduleAtFixedRate(initialDelay, period, unit, action)
		result.whenComplete [
			scheduler.shutdown()
		]
		result
	}

	private static def ScheduledCompletableFuture<?> scheduleAtFixedRate(ScheduledExecutorService scheduler,
		long initialDelay, long rate, TimeUnit unit, (ScheduledCompletableFuture<?>)=>void action) {
		action.requireNonNull
		val result = new WrappingScheduledCompletableFuture<Void>() {
			val Runnable task = [
				try {
					action.apply(this)
				} catch (Throwable t) {
					this.completeExceptionally(t)
				}
			]
			val scheduled = scheduler.scheduleAtFixedRate(task, initialDelay, rate, unit);
			
			override protected getScheduled() {
				scheduled
			}

		}
		result
	}

	private static def ScheduledCompletableFuture<Void> waitForInternal(long time, TimeUnit unit,
		ScheduledExecutorService scheduler) {
		val result = new WrappingScheduledCompletableFuture<Void>() {
			val Runnable task = [
				this.complete(null)
			]
			val scheduled = scheduler.schedule(task, time, unit);
			
			override protected getScheduled() {
				scheduled
			}

		}
		result
	}

	private static def ScheduledCompletableFuture<?> waitForInternal(long time, TimeUnit unit,
		ScheduledExecutorService scheduler, (ScheduledCompletableFuture<?>)=>void then) {

		val result = new WrappingScheduledCompletableFuture<Void>() {
			val Runnable task = [
				try {
					then.apply(this)
					this.complete(null)
				} catch (Throwable t) {
					this.completeExceptionally(t)
				}
			]
			val scheduled = scheduler.schedule(task, time, unit);
			
			override protected getScheduled() {
				scheduled
			}

		}

		result
	}

	/**
	 * This method returns a CompletableFuture which will be completed 
	 * with a {@code null} value on a new thread after after the delay time 
	 * specified by the parameters.<br>
	 * The thread calling this method will not block.
	 * @param time in {@code unit} after which the returned future will be completed with {@code null} value.
	 *        The value of this parameter must be {@code > 0}.
	 * @param unit is the time unit of {@code time}
	 * @return the future that can be used to check for delay till completion of the future or to cancel the completion
	 * @throws NullPointerException if {@code unit} is {@code null}
	 * @throws IllegalArgumentException if {@code time <= 0}
	 */
	// TODO version with scheduler
	public static def ScheduledCompletableFuture<?> waitFor(long time, TimeUnit unit) {
		Objects.requireNonNull(unit)
		if (time <= 0) {
			throw new IllegalArgumentException("time must be > 0, but was " + time);
		}
		val scheduler = createDefaultScheduledExecutorService
		val result = waitForInternal(time, unit, scheduler)
		result.whenComplete[scheduler.shutdown()]
		result
	}

	/**
	 * This method returns a CompletableFuture which will be completed 
	 * with a {@code null} value on a new thread after after the delay time 
	 * specified by the {@code duration} parameter.<br>
	 * The thread calling this method will not block.<br>
	 * <br>
	 * Note: The use of {@code Duration} may cause a loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped.
	 * @param duration is the time after which the returned future will be completed with {@code null} value.
	 *        The value of this parameter must be {@code > 0}.
	 * @return the future that can be used to check for delay till completion of the future or to cancel the completion
	 * @throws NullPointerException if {@code duration} is {@code null}
	 * @throws IllegalArgumentException if {@code duration} value is {@code <= 0}
	 */
	// TODO version with scheduler
	public static def ScheduledCompletableFuture<?> waitFor(Duration duration) {
		Objects.requireNonNull(duration)
		duration.requirePositive
		var time = duration.toTime
		waitFor(time.amount, time.unit)
	}

	private static def void requirePositive(Duration duration) {
		if (duration.negative) {
			throw new IllegalArgumentException("duration must be positive")
		}
	}

	/**
	 * This method will run the given {@code then} callback after the delay 
	 * provided via the parameter {@code duration}. The {@code then} callback
	 * will be executed on a new thread and the future which will be returned will
	 * be passed to it. . This allows the callback to check for cancellation during execution.
	 * The returned future will complete with a {@code null} value 
	 * after the {@code then} procedure returns without throwing an exception. 
	 * If {@code then} throws an exception  the returned future will be completed exceptionally 
	 * with the thrown exception. If the returned future is cancelled before {@code then} 
	 * is executed, the callback will not be called at all.<br>
	 * The thread calling this method will not block.<br>
	 * <br>
	 * Note: The use of {@code Duration} may cause a loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped.
	 * @param duration the time that will at least pass between the method call and the execution of the
	 *   {@code then} procedure. Must be a positive value.
	 * @param then the action to be executed when the delay specified via {@code duration} expires.
	 *   This procedure will be called on a new tread. If the action throws an exception, the returned
	 *   future will be completed exceptionally with the thrown exception. Otherwise the future will
	 *   be completed with a {@code null} value after the successful execution of this action.
	 * @return future that will be completed exceptionally if {@code then} throws an exception. 
	 *   Otherwise the future will be completed with a {@code null} value after the successful execution of {@code then}.
	 *   If this future is completed by the caller of this method before {@code then} is started executing,
	 *   the action will not be called. 
	 * @throws NullPointerException if {@code duration} or {@code then} is {@code null}
	 * @throws IllegalArgumentException if {@code duration} value is {@code <= 0}
	 * @see #waitFor(ScheduledExecutorService, long, TimeUnit, org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 * @see #waitFor(long, TimeUnit, org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 */
	// TODO version with scheduler
	public static def ScheduledCompletableFuture<?> waitFor(Duration duration, (CompletableFuture<?>)=>void then) {
		duration.requirePositive
		then.requireNonNull
		val time = duration.toTime
		waitFor(time.amount, time.unit, then)
	}

	/**
	 * This method will run the given {@code then} callback after the delay 
	 * provided via the parameters {@code time} and {@code unit}. The {@code then} callback
	 * will be executed on a new thread and the future which will be returned will
	 * be passed to it. This allows the callback to check for cancellation during execution. 
	 * The returned future will complete with a {@code null} value 
	 * after the {@code then} procedure returns without throwing an exception. 
	 * If {@code then} throws an exception  the returned future will be completed exceptionally 
	 * with the thrown exception. If the returned future is cancelled before {@code then} 
	 * is executed, the callback will not be called at all.<br>
	 * The thread calling this method will not block.<br>
	 * @param time minimum amount of time specified in {@code unit} that has to elapse before the 
	 *   {@code then} action is executed. This parameter must be a value {@code > 0}.
	 * @param unit the unit of time defined for {@code time}.
	 * @param then the action to be executed when the delay specified via {@code time} and {@code unit} expires.
	 *   This procedure will be called on a new tread. If the action throws an exception, the returned
	 *   future will be completed exceptionally with the thrown exception. Otherwise the future will
	 *   be completed with a {@code null} value after the successful execution of this action.
	 * @return future that will be completed exceptionally if {@code then} throws an exception. 
	 *   Otherwise the future will be completed with a {@code null} value after the successful execution of {@code then}.
	 *   If this future is completed by the caller of this method before {@code then} is started executing,
	 *   the action will not be called. 
	 * @throws NullPointerException if {@code then} or {@code unit} is {@code null}
	 * @throws IllegalArgumentException if {@code time} value is {@code <= 0}
	 * @see #waitFor(ScheduledExecutorService, long, TimeUnit, org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 * @see #waitFor(Duration, org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 */
	public static def ScheduledCompletableFuture<?> waitFor(long time, TimeUnit unit,
		(CompletableFuture<?>)=>void then) {
		Objects.requireNonNull(unit)
		Objects.requireNonNull(then)
		if (time <= 0) {
			throw new IllegalArgumentException("time must be > 0, but was " + time);
		}
		val scheduler = createDefaultScheduledExecutorService
		val result = waitForInternal(time, unit, scheduler, then)
		result.whenComplete[scheduler.shutdown()]
		result
	}

	/**
	 * This method will run the given {@code then} callback after the delay 
	 * provided via the parameters {@code time} and {@code unit}. The {@code then} callback
	 * will be scheduled and executed on the given {@code scheduler} and the future which will be returned will
	 * be passed to it. This allows the callback to check for cancellation during execution.
	 * The returned future will complete with a {@code null} value 
	 * after the {@code then} procedure returns without throwing an exception. 
	 * If {@code then} throws an exception  the returned future will be completed exceptionally 
	 * with the thrown exception. If the returned future is cancelled before {@code then} 
	 * is executed, the callback will not be called at all.<br>
	 * The thread calling this method will not block.<br>
	 * @param scheduler is the executor used for scheduling the execution of the {@code action} action.
	 * @param time minimum amount of time specified in {@code unit} that has to elapse before the 
	 *   {@code then} action is executed. This parameter must be a value {@code > 0}.
	 * @param unit the unit of time defined for {@code time}.
	 * @param then the action to be executed when the delay specified via {@code time} and {@code unit} expires.
	 *   This procedure will be scheduled and called on the {@code scheduler}. If the action throws an exception, the returned
	 *   future will be completed exceptionally with the thrown exception. Otherwise the future will
	 *   be completed with a {@code null} value after the successful execution of this action.
	 * @return future that will be completed exceptionally if {@code then} throws an exception. 
	 *   Otherwise the future will be completed with a {@code null} value after the successful execution of {@code then}.
	 *   If this future is completed by the caller of this method before {@code then} is started executing,
	 *   the action will not be called. 
	 * @throws NullPointerException if {@code scheduler}, {@code then} or {@code unit} is {@code null}
	 * @throws IllegalArgumentException if {@code time} value is {@code <= 0}
	 * @see #waitFor(long, TimeUnit, org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 * @see #waitFor(Duration, org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 */
	public static def ScheduledCompletableFuture<?> waitFor(ScheduledExecutorService scheduler, long time,
		TimeUnit unit, (CompletableFuture<?>)=>void then) {
		Objects.requireNonNull(scheduler)
		Objects.requireNonNull(unit)
		Objects.requireNonNull(then)
		if (time <= 0) {
			throw new IllegalArgumentException("time must be > 0, but was " + time);
		}
		waitForInternal(time, unit, scheduler, then)
	}

	/**
	 * This method will run the given {@code delayed} function after the delay 
	 * provided via the parameters {@code delayTime} and {@code delayUnit}. The {@code delayed} function
	 * will be executed on a new thread and the future which will be returned will
	 * be passed to it. This allows the function to check for cancellation during execution. 
	 * The returned future will complete with a the result value of the {@code delayed} function
	 * after executing it, without it throwing an exception. 
	 * If {@code delayed} throws an exception  the returned future will be completed exceptionally 
	 * with the thrown exception. If the returned future is cancelled before {@code delayed} 
	 * is executed, the function will not be called at all.<br>
	 * The thread calling this method will not block.<br>
	 * @param delayTime minimum amount of time specified in {@code delayUnit} that has to elapse before the 
	 *   {@code delayed} action is executed. This parameter must be a value {@code > 0}.
	 * @param delayUnit the unit of time defined for {@code delayTime}.
	 * @param delayed the action to be executed when the delay specified via {@code delayTime} and {@code delayUnit} expires.
	 *   This function will be called on a new tread. If the function throws an exception, the returned
	 *   future will be completed exceptionally with the thrown exception. Otherwise the future will
	 *   be completed with the result value returned from successful execution of this function.
	 * @return future that will be completed exceptionally if {@code delayed} throws an exception. 
	 *   Otherwise the future will be completed with the result value of the successful execution of {@code delayed}.
	 *   If this future is completed by the caller of this method before {@code delayed} is started executing,
	 *   the action will not be called.
	 * @param <T> type of the object returned by the function {@code delayed} that will be provided by the returned future.
	 * @throws NullPointerException if {@code delayed} or {@code delayUnit} is {@code null}
	 * @throws IllegalArgumentException if {@code delayTime} value is {@code <= 0}
	 * @see #delay(Duration, org.eclipse.xtext.xbase.lib.Functions.Function1)
	 * @see #delay(ScheduledExecutorService, long, TimeUnit, org.eclipse.xtext.xbase.lib.Functions.Function1)
	 */
	public static def <T> ScheduledCompletableFuture<T> delay(long delayTime, TimeUnit delayUnit,
		(ScheduledCompletableFuture<?>)=>T delayed) {
		delayed.requireNonNull
		delayUnit.requireNonNull
		if (delayTime <= 0) {
			throw new IllegalArgumentException("delayTime must be > 0, but was " + delayTime);
		}
		val scheduler = createDefaultScheduledExecutorService
		val result = scheduler.delayInternal(delayTime, delayUnit, delayed)
		result.whenComplete[scheduler.shutdown()]
		result
	}

	private static def ScheduledExecutorService createDefaultScheduledExecutorService() {
		val scheduler = new ScheduledThreadPoolExecutor(1)
		scheduler.removeOnCancelPolicy = true
		scheduler.executeExistingDelayedTasksAfterShutdownPolicy = false
		scheduler
	}

	/**
	 * This method will run the given {@code delayed} function after the delay 
	 * provided via the {@code delayBy} parameter. The {@code delayed} function
	 * will be executed on a new thread and the future which will be returned will
	 * be passed to it. This allows the function to check for cancellation during execution. 
	 * The returned future will complete with a the result value of the {@code delayed} function
	 * after executing it, without it throwing an exception. 
	 * If {@code delayed} throws an exception  the returned future will be completed exceptionally 
	 * with the thrown exception. If the returned future is cancelled before {@code delayed} 
	 * is executed, the function will not be called at all.<br>
	 * The thread calling this method will not block.<br>
	 * <br>
	 * Note: The use of {@code Duration} may cause a loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped.
	 * @param delayBy minimum duration specified that has to elapse before the 
	 *   {@code delayed} action is executed. This parameter must be a positive duration.
	 * @param delayed the action to be executed when the delay specified via {@code delayBy} expires.
	 *   This function will be called on a new tread. If the function throws an exception, the returned
	 *   future will be completed exceptionally with the thrown exception. Otherwise the future will
	 *   be completed with the result value returned from successful execution of this function.
	 * @return future that will be completed exceptionally if {@code delayed} throws an exception. 
	 *   Otherwise the future will be completed with the result value of the successful execution of {@code delayed}.
	 *   If this future is completed by the caller of this method before {@code delayed} is started executing,
	 *   the action will not be called.
	 * @param <T> type of the object returned by the function {@code delayed} that will be provided by the returned future.
	 * @throws NullPointerException if {@code delayed} or {@code delayUnit} is {@code null}
	 * @throws IllegalArgumentException if {@code delayBy} time is {@code <= 0}
	 * @see #delay(long, TimeUnit, org.eclipse.xtext.xbase.lib.Functions.Function1)
	 * @see #delay(ScheduledExecutorService, long, TimeUnit, org.eclipse.xtext.xbase.lib.Functions.Function1)
	 */
	// TODO version with scheduler
	public static def <T> ScheduledCompletableFuture<T> delay(Duration delayBy,
		(ScheduledCompletableFuture<?>)=>T delayed) {
		delayBy.requireNonNull
		delayBy.requirePositive
		delayed.requireNonNull
		var time = delayBy.toTime
		delay(time.amount, time.unit, delayed)
	}

	/**
	 * This method will run the given {@code delayed} function after the delay 
	 * provided via the parameters {@code delayTime} and {@code delayUnit}. The {@code delayed} function
	 * will be scheduled and executed using the given {@code scheduler} and the future which will be returned will
	 * be passed to it. This allows the function to check for cancellation during execution. 
	 * The returned future will complete with a the result value of the {@code delayed} function
	 * after executing it, without it throwing an exception. 
	 * If {@code delayed} throws an exception  the returned future will be completed exceptionally 
	 * with the thrown exception. If the returned future is cancelled before {@code delayed} 
	 * is executed, the function will not be called at all.<br>
	 * The thread calling this method will not block.<br>
	 * @param scheduler is the executor used for scheduling and executing of the {@code delayed} function.
	 * @param delayTime minimum amount of time specified in {@code delayUnit} that has to elapse before the 
	 *   {@code delayed} function is executed. This parameter must be a value {@code > 0}.
	 * @param delayUnit the unit of time defined for {@code delayTime}.
	 * @param delayed the action to be executed when the delay specified via {@code delayTime} and {@code delayUnit} expires.
	 *   This function will be called on a new tread. If the function throws an exception, the returned
	 *   future will be completed exceptionally with the thrown exception. Otherwise the future will
	 *   be completed with the result value returned from successful execution of this function.
	 * @param <T> type of the object returned by the function {@code delayed} that will be provided by the returned future.
	 * @return future that will be completed exceptionally if {@code delayed} throws an exception. 
	 *   Otherwise the future will be completed with the result value of the successful execution of {@code delayed}.
	 *   If this future is completed by the caller of this method before {@code delayed} is started executing,
	 *   the action will not be called.
	 * @throws NullPointerException if {@code delayed} or {@code delayUnit} is {@code null}
	 * @throws IllegalArgumentException if {@code delayTime} value is {@code <= 0}
	 * @see #delay(Duration, org.eclipse.xtext.xbase.lib.Functions.Function1)
	 * @see #delay(long, TimeUnit, org.eclipse.xtext.xbase.lib.Functions.Function1)
	 */
	public static def <T> ScheduledCompletableFuture<T> delay(ScheduledExecutorService scheduler, long delayTime,
		TimeUnit delayUnit, (ScheduledCompletableFuture<?>)=>T delayed) {
		scheduler.requireNonNull
		delayed.requireNonNull
		delayUnit.requireNonNull
		if (delayTime <= 0) {
			throw new IllegalArgumentException("delayTime must be > 0, but was " + delayTime);
		}
		delayInternal(scheduler, delayTime, delayUnit, delayed)
	}

	private static def <T> ScheduledCompletableFuture<T> delayInternal(ScheduledExecutorService scheduler, long time,
		TimeUnit unit, (ScheduledCompletableFuture<?>)=>T action) {
		val result = new ScheduledCompletableFuture<T>() {
			val Runnable task = [
				try {
					val computationResult = action.apply(this)
					this.complete(computationResult)
				} catch (Throwable t) {
					this.completeExceptionally(t)
				}
			]
			val scheduled = scheduler.schedule(task, time, unit);

			@SuppressWarnings("unused") // we need to call whenCancelled in anonymous class
			val afterCancel = this.whenComplete[scheduled.cancel(false)]

			override long getDelay(TimeUnit unit) {
				scheduled.getDelay(unit)
			}

			override int compareTo(Delayed o) {
				scheduled.compareTo(o)
			}

		}
		result
	}
}
