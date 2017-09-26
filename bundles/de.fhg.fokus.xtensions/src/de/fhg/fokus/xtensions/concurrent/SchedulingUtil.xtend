package de.fhg.fokus.xtensions.concurrent

import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit
import java.util.concurrent.ScheduledExecutorService
import java.util.Objects
import java.util.concurrent.ScheduledThreadPoolExecutor
import java.time.Duration
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.Delayed
import static extension de.fhg.fokus.xtensions.concurrent.internal.DurationToTimeConversion.*

/**
 * This class provides static functions that can be used to schedule tasks that
 * are either repeated or delayed by a given amount of time.
 */
final class SchedulingUtil {

	private new() {
		throw new IllegalStateException("SchedulingExtensions not intended to be instantiated")
	}

	/**
	 * This class implements both {@link CompletableFuture} and {@link ScheduledFuture},
	 * so it can be used in a non-blocking fashion, but still be asked for the delay for
	 * the next execution of a scheduled task.<br>
	 * This class is not intended to be sub-classed outside of the SchdulingExtensions.
	 */
	public abstract static class ScheduledCompletableFuture<T> extends CompletableFuture<T> implements ScheduledFuture<T> {

		package new() {
		}

	}

	/**
	 * Adds delay information to an action to be scheduled. When the {@link DelaySpecifier#withInitialDelay(long, Procedure0)}
	 * method is called the scheduling will be started, by scheduling the given action according to the scheduling 
	 * information given to the function producing the DelaySpecifier and the given delay passed to withInitialDelay.<br>
	 * This class is not intended to be sub-classed outside of the SchdulingExtensions.
	 */
	public abstract static class DelaySpecifier {

		private new() {
		}

		abstract def ScheduledCompletableFuture<?> withInitialDelay(long initialDelay, (CompletableFuture<?>)=>void action);
	}

	/**
	 * This method will schedule the given {@code action} to run in a fixed interval specified via {@code duration}
	 * starting from the time this method is called. If {@code action} throws, the action will un-scheduled and not
	 * called anymore. The returned {@code ScheduledCompletableFuture} will also be passed to the action on every 
	 * scheduled call. The future will only completed via an exception
	 * thrown from {@code action}, from the outside by the caller or by the {@code action}. When the future is be completed
	 * (no matter how), the {@code action} will be un-scheduled and not be called again.<br><br>
	 * Be aware that the execution of {@code action} will be performed on a single Thread, so if the execution of {@code action}
	 * takes longer than the specified {@code period}, following executions are delayed. Consider using 
	 * {@link SchedulingUtil#repeatEvery(ScheduledExecutorService, Duration, Procedure1) repeatEvery(ScheduledExecutorService, Duration, (CompletableFuture<?>)=>void)}
	 * to specify an own {@code ScheduledExecutorService} which may provide more threads for execution.<br><br>
	 * Note: The use of {@code Duration} may cause a loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped. Alternatively you can call 
	 * {@link SchedulingUtil#repeatEvery(long, TimeUnit, Procedure1) repeatEvery(long, TimeUnit, (CompletableFuture<?>)=>void)} or 
	 * {@link SchedulingUtil#repeatEvery(ScheduledExecutorService, long, TimeUnit, Procedure1) repeatEvery(ScheduledExecutorService, long, TimeUnit, (CompletableFuture<?>)=>void)}
	 * to specify the time without loss of precision.
	 * @param period at which the given {@code action} should be called.
	 * @param action 
	 * @see SchedulingUtil#repeatEvery(long, TimeUnit, Procedure1)
	 */
	public static def ScheduledCompletableFuture<?> repeatEvery(Duration period, (ScheduledCompletableFuture<?>)=>void action) {
		// TODO check parameters
		val time = period.toTime
		repeatEvery(time.amount, time.unit, action)
	}
	
	/**
	 * May cause loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped.
	 */
	public static def ScheduledCompletableFuture<?> repeatEvery(ScheduledExecutorService scheduler, Duration duration, (CompletableFuture<?>)=>void action) {
		// TODO check parameters
		val time = duration.toTime
		scheduler.repeatEvery(time.amount, time.unit, action)
	}

	public static def ScheduledCompletableFuture<?> repeatEvery(long period, TimeUnit unit, (ScheduledCompletableFuture<?>)=>void action) {
		// TODO sanity check on params
		scheduleAtFixedRate(0, period, unit, action)
	}
	
	public static def ScheduledCompletableFuture<?> repeatEvery(ScheduledExecutorService scheduler, long time, TimeUnit unit, (CompletableFuture<?>)=>void action) {
		// TODO sanity check on params
		Objects.requireNonNull(unit)
		scheduler.scheduleAtFixedRate(0, time, unit, action)
	}

	public static def DelaySpecifier repeatEvery(long time, TimeUnit unit) {
		// TODO check parameters
		new DelaySpecifier {

			override withInitialDelay(long initialDelay, (CompletableFuture<?>)=>void action) {
				scheduleAtFixedRate(initialDelay, time, unit, action)
			}

		}
	}
	
	public static def DelaySpecifier repeatEvery(ScheduledExecutorService scheduler, long time, TimeUnit unit) {
		// TODO check parameters
		new DelaySpecifier {

			override withInitialDelay(long initialDelay, (CompletableFuture<?>)=>void action) {
				scheduler.scheduleAtFixedRate(initialDelay, time, unit, action)
			}

		}
	}

	// TODO version with duration
	public static def ScheduledCompletableFuture<?> repeatWithFixedDelay(long time, TimeUnit unit,
		(CompletableFuture<?>)=>void action) {
		// TODO sanity check on params
		scheduleWithFixedDelay(0, time, unit, action)
	}

	public static def DelaySpecifier repeatWithFixedDelay(long delay, TimeUnit unit) {
		// TODO sanity check on params
		new DelaySpecifier {

			override withInitialDelay(long initialDelay, (CompletableFuture<?>)=>void action) {
				scheduleWithFixedDelay(initialDelay, delay, unit, action)
			}

		}
	}

	private static def ScheduledCompletableFuture<?> scheduleAtFixedRate(long initialDelay, long period, TimeUnit unit,
		(ScheduledCompletableFuture<?>)=>void action) {
		val scheduler = Executors.newScheduledThreadPool(1)
		val result = scheduler.scheduleAtFixedRate(initialDelay, period, unit, action)
		result.whenComplete [
			scheduler.shutdown()
		]
		result
	}
	
	private static def ScheduledCompletableFuture<?> scheduleAtFixedRate(ScheduledExecutorService scheduler, long initialDelay, long rate, TimeUnit unit,
		(ScheduledCompletableFuture<?>)=>void action) {
		val result = new ScheduledCompletableFuture<Void>() {
			val Runnable task = [
				try {
					action.apply(this)
				} catch (Throwable t) {
					this.completeExceptionally(t)
				}
			]
			val scheduled = scheduler.scheduleAtFixedRate(task, initialDelay, rate, unit);

			@SuppressWarnings("unused") // we need to call whenCancelled in anonymous class
			val afterCancel = this.whenComplete[scheduled.cancel(false)]

			override getDelay(TimeUnit unit) {
				scheduled.getDelay(unit)
			}

			override compareTo(Delayed o) {
				scheduled.compareTo(o)
			}
			
		}
		result
	}

	private static def ScheduledCompletableFuture<?> scheduleWithFixedDelay(long initialDelay, long rate, TimeUnit unit,
		(CompletableFuture<?>)=>void action) {
		val scheduler = Executors.newScheduledThreadPool(1)
		val result = scheduler.scheduleWithFixedDelay(initialDelay, rate, unit, action)
		result.whenComplete [
			scheduler.shutdown()
		]

		result
	}
	
	private static def ScheduledCompletableFuture<?> scheduleWithFixedDelay(ScheduledExecutorService scheduler, long initialDelay, long rate, TimeUnit unit,
		(CompletableFuture<?>)=>void action) {
		val result = new ScheduledCompletableFuture<Void>() {
			val Runnable task = [
				try {
					action.apply(this)
				} catch (Throwable t) {
					this.completeExceptionally(t)
				}
			]
			val scheduled = scheduler.scheduleWithFixedDelay(task, initialDelay, rate, unit);

			@SuppressWarnings("unused") // we need to call whenCancelled in anonymous class
			val afterCancel = this.whenComplete[scheduled.cancel(false)]

			override getDelay(TimeUnit unit) {
				scheduled.getDelay(unit)
			}

			override compareTo(Delayed o) {
				scheduled.compareTo(o)
			}

		}
		result
			
	}

	private static def ScheduledCompletableFuture<Void> waitForInternal(long time, TimeUnit unit,
		ScheduledExecutorService scheduler) {
		val result = new ScheduledCompletableFuture<Void>() {
			val Runnable task = [
				this.complete(null)
			]
			val scheduled = scheduler.schedule(task, time, unit);

			@SuppressWarnings("unused") // we need to call whenCancelled in anonymous class
			val afterCancel = this.whenComplete[scheduled.cancel(false)]

			override getDelay(TimeUnit unit) {
				scheduled.getDelay(unit)
			}

			override compareTo(Delayed o) {
				scheduled.compareTo(o)
			}

		}
		result
	}

	
	// TODO return ScheduledCompletableFuture<?> ??? 
	private static def ScheduledCompletableFuture<?> waitForInternal(long time, TimeUnit unit,
		ScheduledExecutorService scheduler, (CompletableFuture<?>)=>void then) {
		
		val result = new ScheduledCompletableFuture<Void>() {
			val Runnable task = [
				try {
					then.apply(this)
					this.complete(null)
				} catch (Throwable t) {
					this.completeExceptionally(t)
				}
			]
			val scheduled = scheduler.schedule(task, time, unit);

			@SuppressWarnings("unused") // we need to call whenCancelled in anonymous class
			val afterCancel = this.whenComplete[scheduled.cancel(false)]

			override getDelay(TimeUnit unit) {
				scheduled.getDelay(unit)
			}

			override compareTo(Delayed o) {
				scheduled.compareTo(o)
			}

		}
		
		result
	}

	/**
	 * The thread calling this method will not block, but immediately return
	 * a CompletableFuture that will be completed after the delay specified 
	 * by the parameters.
	 * The returned CompletableFuture will be completed on a new thread.
	 * So all non-asynchronous callbacks will be executed on that thread.
	 */
	// TODO version with scheduler
	public static def ScheduledCompletableFuture<?> waitFor(long time, TimeUnit unit) {
		// TODO sanity check on time
		Objects.requireNonNull(unit)
		val scheduler = Executors.newScheduledThreadPool(1)
		val result = waitForInternal(time, unit, scheduler)
		result.whenComplete[scheduler.shutdown()]
		result
	}

	/**
	 * May cause loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped.
	 */
	// TODO version with scheduler
	public static def ScheduledCompletableFuture<?> waitFor(Duration duration) {
		// TODO sanity check on param
		var time = duration.toTime
		waitFor(time.amount, time.unit)
	}

	/**
	 * May cause loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped.
	 */
	// TODO version with scheduler
	public static def ScheduledCompletableFuture<?> waitFor(Duration duration, (CompletableFuture<?>)=>void then) {
		// TODO sanity check on params
		val time = duration.toTime
		waitFor(time.amount, time.unit, then)
	}

	public static def ScheduledCompletableFuture<?> waitFor(long time, TimeUnit unit, (CompletableFuture<?>)=>void then) {
		// TODO sanity check on params
		Objects.requireNonNull(unit)
		val scheduler = new ScheduledThreadPoolExecutor(1)
		val result = waitForInternal(time, unit, scheduler, then)
		result.whenComplete[scheduler.shutdown()]
		result
	}

	// TODO version with Duration
	public static def ScheduledCompletableFuture<?> waitFor(ScheduledExecutorService scheduler, long time, TimeUnit unit,
		(CompletableFuture<?>)=>void action) {
		Objects.requireNonNull(scheduler)
		Objects.requireNonNull(action)
		// TODO sanity check on time
		waitForInternal(time, unit, scheduler, action)
	}

	public static def <T> ScheduledCompletableFuture<T> delay(long delayTime, TimeUnit delayUnit,
		(CompletableFuture<?>)=>T delayed) {
		// TODO sanity check on params
		val scheduler = new ScheduledThreadPoolExecutor(1)
		val result = scheduler.delayInternal(delayTime, delayUnit, delayed)
		result.whenComplete[scheduler.shutdown()]
		result
	}

	/**
	 * May cause loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds, 
	 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
	 * second) may be stripped.
	 */
	 // TODO version with scheduler
	public static def <T> ScheduledCompletableFuture<T> delay(Duration delayBy, (CompletableFuture<?>)=>T delayed) {
		// TODO sanity check on params
		var time = delayBy.toTime
		delay(time.amount, time.unit, delayed)
	}
	
	// be aware: completing the future outside of this function will not stop the computation of action.
	// the future can be cancelled though, which will prevent execution, if the computation of action did not start yet
	public static def <T> ScheduledCompletableFuture<T> delay(ScheduledExecutorService scheduler, long time,
		TimeUnit unit, (CompletableFuture<?>)=>T action) {
		// TODO sanity check on time
		Objects.requireNonNull(scheduler)
		Objects.requireNonNull(action)
		delayInternal(scheduler, time, unit, action)
	}
	
	private static def <T> delayInternal(ScheduledExecutorService scheduler, long time,
		TimeUnit unit, (CompletableFuture<?>)=>T action) {
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

			override getDelay(TimeUnit unit) {
				scheduled.getDelay(unit)
			}

			override compareTo(Delayed o) {
				scheduled.compareTo(o)
			}

		}
		result
	}
}
