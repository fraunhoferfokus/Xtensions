package de.fhg.fokus.xtensions.concurrent.circuitbreaker.impl

import org.eclipse.xtend.lib.annotations.Data
import java.util.function.LongSupplier
import java.util.concurrent.atomic.AtomicReference
import java.util.concurrent.atomic.AtomicInteger
import static extension java.util.Arrays.fill;

/**
 * Records success and error and checks if an error causes the statistics
 * to meet a tripping threshold. This can be used by CircuitBreakerState implementations,
 * to check weather to switch to an open state or not.
 * Implementations of this interface must be thread safe.
 */
package interface ErrorStatisticsChecker {

	/**
	 * Returns {@code true} if the error threshold is not reached 
	 * and further operations are allowed. If {@code false} is returned
	 * the maximum allowed error count is reached and the current instance
	 * should not be used anymore.
	 * @returns {@code true} if the allowed threshold of errors is not reached yet,
	 *   {@code false} otherwise
	 */
	def boolean addErrorAndCheck()

	/**
	 * Records a successful operation
	 */
	def void addSuccess()
}

/**
 * Statistics checking if the last N operation do not exceed a given
 * threshold of error count. 
 */
package class ErrorRateChecker implements ErrorStatisticsChecker {

	val AtomicReference<ErrorRateStatistics> statistics // only on success
	val int maxErrorCount

	/**
	 * Creates an ErrorRateChecker that checks if there is a maximum of {@code maxErrorCount}
	 * in the last {@code size} results.
	 * @param size sample size used to check error count. must be &gt; 0.
	 * @param maxErrorCount maximum amount of errors that can occur in the amount of {@code size}
	 *          results. must be &gt;=0
	 * @throws IllegalArgumentException if any precondition on the arguments is not respected.
	 */
	new(int size, int maxErrorCount) {
		if (size <= 0) {
			throw new IllegalArgumentException("Size must be greater than 0.")
		}
		if (maxErrorCount < 0) {
			throw new IllegalArgumentException("Maximum error count must be equal to or greater than 0.")
		}
		this.statistics = new AtomicReference(new ErrorRateStatistics(size))
		this.maxErrorCount = maxErrorCount
	}

	/**
	 * Returns {@code false} if the maximum amount of errors is reached within 
	 * the last N elements. Otherwise returns {@code true}
	 */
	override boolean addErrorAndCheck() {
		while (true) {
			val stat = statistics.get
			val newStat = stat.addError
			if (statistics.compareAndSet(stat, newStat)) {
				// size does not matter, if error count reached
				// we trip, even if we did not reach the full count yet
				return newStat.errors <= maxErrorCount
			}
		}
	}

	override void addSuccess() {
		while (true) {
			val currStat = statistics.get
			val newStat = currStat.addSuccess
			if (statistics.compareAndSet(currStat, newStat)) {
				return
			}
		}
	}
}

/**
 * Statistics holding records of the last N operations (success or error). The amount
 * of errors can be reached via method {@link ErrorStatistics#errors() errors()}.<br>
 * Internally an array is used to track successful and erroneous operations in the manner 
 * of a cyclic-buffer. This class is immutable, so the array is copied if the array actually changes.
 */
package class ErrorRateStatistics {

	// true = error, false = success
	val boolean[] data
	private val int errors
	private val int index

	/**
	 * @param size amount of sampled results (success/error)
	 */
	new(int size) {
		this.data = newBooleanArrayOfSize(size)
		// fill array with true, since we expect no failures as standard.
		// Nice side effect: Logic of updateFiledAtCurrentIndexTo can stay
		// the same for first and following iterations through data
		this.data.fill(true);
		this.errors = 0
		this.index = 0
	}

	private new(int errors, int index, boolean[] data) {
		this.errors = errors
		this.index = index
		this.data = data
	}

	def ErrorRateStatistics addError() {
		updateFiledAtCurrentIndexTo(false)
	}

	def ErrorRateStatistics addSuccess() {
		updateFiledAtCurrentIndexTo(true)
	}

	def updateFiledAtCurrentIndexTo(boolean newValue) {
		val size = data.size
		val currIndex = index
		val newIndex = (currIndex + 1) % size
		// did we wrap around?
		// replace element, update error statistics
		val oldValue = data.get(currIndex)
		if (oldValue == newValue) {
			// since data array stays the same and this object
			// is immutable, we can safely re-use it.
			new ErrorRateStatistics(errors, newIndex, data)
		} else {
			val newData = data.clone
			// set new value at index
			newData.set(currIndex, newValue)
			// either increase or decrease error count
			val newErrors = if(newValue) errors - 1 else errors + 1
			new ErrorRateStatistics(newErrors, newIndex, newData)
		}
	}

	/**
	 * Count of errors in the last N operations.
	 */
	def errors() {
		errors
	}
}

/**
 * This checker tests if the error count in certain time intervals stays
 * under a certain threshold. The checker uses fixed time intervals, and is
 * not starting a new interval whenever a new message is coming in (which 
 * would need management of multiple time-slices).
 */
package class ErrorPerTimeChecker implements ErrorStatisticsChecker {

	val LongSupplier timeSupplier
	val long maxCount
	val long nanoResetInterval
	val AtomicReference<ErrorPerTimeChecker.ErrorState> state

	/**
	 * Creates a new ErrorPerTimeChecker that checks if a maximum number
	 * of {@code maxCount} errors occur in intervals of {@code nanoResetInterval}
	 * starting from the current time provided by {@code timeSuplier}. The 
	 * {@code timeSuplier} is also used to check the time on arrival of error messages, 
	 * reported via {@link #addErrorAndCheck()}.
	 * @param maxCount maximum amount of errors allowed in one time slice of size {@code nanoResetInterval}.
	 *   Must be {@code <= 0}.
	 * @param nanoResetInterval size of time slice in which errors are counted. Must be {@code < 0}.
	 * @param timeSupplier provides the current system time in nanoseconds. Must not be {@code null}.
	 * @throws IllegalArgumentException if any of the parameter preconditions are not respected.
	 */
	package new(long maxCount, long nanoResetInterval, LongSupplier timeSupplier) throws IllegalArgumentException {
		if (maxCount < 0) {
			throw new IllegalArgumentException("Maximum number of errors per time must at least be 0.")
		}
		if (nanoResetInterval <= 0) {
			throw new IllegalArgumentException(
				"Time interval in which errors are counted must be greater than 0 nanoseconds.")
		}
		if (timeSupplier === null) {
			throw new IllegalArgumentException("System time supplier must not be null.")
		}
		this.maxCount = maxCount
		this.nanoResetInterval = nanoResetInterval
		this.timeSupplier = timeSupplier
		this.state = new AtomicReference(new ErrorState(timeSupplier.asLong, 0))
	}

	/**
	 * Holds the state when the last time-slot boundary was crossed
	 * and how many errors occurred in the current time-slot.
	 */
	@Data
	static class ErrorState {
		val long lastReset
		val long errorCount;
	}

	/**
	 * Adds error and checks if the maximum number of errors is reached
	 * in the current time-slice.
	 */
	override boolean addErrorAndCheck() {
		var finished = false
		while (!finished) {
			val currTime = timeSupplier.asLong
			val currState = state.get
			val lastReset = currState.lastReset
			val diff = currTime - lastReset
			if (diff > nanoResetInterval) {
				// we are the first after time-slice boundary crossing
				// so set last boundary up to last full nanoResetInterval
				val newResetTime = lastReset + diff - (diff % nanoResetInterval)
				// we already crossed boundary to a new interval
				// so we can reset the count
				val newErrorCount = 1
				val newState = new ErrorState(newResetTime, newErrorCount)
				finished = state.compareAndSet(currState, newState)
			} else {
				// if we didn't cross time boundary we have to
				// increase the count if we already have maximum count
				// we return false
				val currErrorCount = currState.errorCount
				if (currErrorCount == maxCount) {
					return false
				}
				// else simply increase taken count
				val newErrorCount = currErrorCount + 1
				val newState = new ErrorState(currState.lastReset, newErrorCount)
				finished = state.compareAndSet(currState, newState)
			}
		}
		// if we didn't return false so far the state was 
		// successfully updated and we can return true
		true
	}

	override addSuccess() {
		// no action
	}

}

/**
 * This checker allows only a maximum number of consecutive errors
 * to occur.
 */
package class ErrorSequnceChecker implements ErrorStatisticsChecker {

	val AtomicInteger subsequentErrorCount = new AtomicInteger(0)
	val int failCount

	/**
	 * 
	 * @param failCount number of subsequent errors that is not allowed to occur. Must be {@code >0}
	 * @throws IllegalArgumentException if {@code failCount <= 0}
	 */
	new(int failCount) throws IllegalArgumentException {
		if (failCount <= 0) {
			throw new IllegalArgumentException("Maximum number of consecutive errors must be greater 0.")
		}
		this.failCount = failCount
	}

	override addErrorAndCheck() {
		subsequentErrorCount.incrementAndGet < failCount
	}

	override addSuccess() {
		subsequentErrorCount.set(0)
	}

}
