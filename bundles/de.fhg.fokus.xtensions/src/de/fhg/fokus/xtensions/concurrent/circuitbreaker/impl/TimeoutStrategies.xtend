package de.fhg.fokus.xtensions.concurrent.circuitbreaker.impl

import java.util.concurrent.TimeUnit
import de.fhg.fokus.xtensions.concurrent.circuitbreaker.TimeoutStrategy
import java.util.Objects
import de.fhg.fokus.xtensions.concurrent.circuitbreaker.TimeoutStrategy.TimeFactory

/**
 * Default builder for instances of {@link BackoffStrategy}.
 */
final class TimeoutStrategies {

	private new() {
	}
	
	// TODO version with Duration

	/**
	 * Creates new TimeoutStrategy that always returns the same timeout of the 
	 * given time and the given time unit.
	 * 
	 * @param time amount of time of time unit {@code unit} that is always provided
	 *   by the returned TimeoutStrategy. Must be {@code >=0}
	 * @param unit time unit of the given {@code time} that will always be provided
	 *   by the returned TimeoutStrategy. Must not be {@code null}
	 * @return TimeoutStrategy always returning the same timeout of the given
	 *   {@code time} and {@code unit}
	 * @throws IllegalArgumentException if any of the parameter constraints are not regarded.
	 */
	static def TimeoutStrategy fixedTimeout(long time, TimeUnit unit) {
		if(time < 0) {
			throw new IllegalArgumentException("Timeout time must be greater or equal to 0.")
		}
		Objects.requireNonNull(unit, "Timeout TimeUnit must not be null.");
		[oldTime, oldUnit, mapper|mapper.apply(time, unit)]
	}

	/**
	 * Returns a TimeoutStrategy that when called returns the last time amount multiplied
	 * with the given {@code factor}. If the result of the multiplication exceeds the given 
	 * {@code maxTimeoutTime} of {@code unit}, then the timeout will be limited to {@code maxTimeoutTime}.
	 * When the strategy is called initially (with {@code previousTimeout} 0), then the given 
	 * {@code startTimoutTime} and {@code unit} 
	 * will be returned as timeout time.
	 * @param startTimoutTime initial timeout returned by the TimeoutStrategy when called with
	 *    {@code previousTimeout = 0}. Must be {@code > 0}
	 * @param unit time unit of {@code startTimoutTime} and {@code maxTimoutTime}. Must not be {@code null}.
	 * @param maxTimoutTime maximum timeout provided by the returned TimeoutStrategy. Must be {@code >= startTimoutTime}.
	 * @param factor used to multiply must be {@code >= 1}.
	 * @return TimeoutStrategy that backs off exponentially according to {@code factor}, 
	 *    starting with {@code startTimoutTime}.
	 * @throws IllegalArgumentException if any of the parameter constraints are not regarded.
	 */
	static def TimeoutStrategy exponentialBackoff(long startTimoutTime, TimeUnit unit, long maxTimoutTime,
		double factor) {
		if (factor < 1.0d) {
			throw new IllegalArgumentException("Factor must be greater than, or equal to 1.0.")
		}
		if(startTimoutTime <= 0) {
			throw new IllegalArgumentException("Starting timeout time must be greater than 0.")
		}
		if(maxTimoutTime < startTimoutTime) {
			throw new IllegalArgumentException("Maximum timeout time must be greater than or equal to the starting timeout time.")
		}
		Objects.requireNonNull(unit, "Timeout TimeUnit must not be null.");
		
		[ long oldTime, TimeUnit oldUnit, mapper |
			val newTimeout = if (oldTime == 0) {
					// on first try, use start timeout
					startTimoutTime
				} else {
					val increased = (oldTime * factor) as long
					// check for overflow
					if(increased > oldTime) {
						increased
					} else {
						// on overflow, simply use maximum timeout
						maxTimoutTime
					}
				}
			val limitedTimeout = Math.min(maxTimoutTime, newTimeout)
			mapper.apply(limitedTimeout, unit)
		]
	}
}
