package de.fhg.fokus.xtenders.concurrent.internal

import java.util.concurrent.TimeUnit
import java.time.Duration
import org.eclipse.xtend.lib.annotations.Data

/**
 * Conversion cause loss in time precision, if the converted duration exceeds Long.MAX_VALUE nanoseconds, 
 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one 
 * second) may be stripped.
 */
class DurationToTimeConversion {

	/**
	 * Holder class for an {@code amount} of time and its
	 * time {@code unit}.
	 */
	@Data
	public static class Time {
		public final long amount;
		public final TimeUnit unit;
	}

	/**
	 * Shortcut for constructor of {@link Time}.
	 */
	private static def Time operator_mappedTo(long time, TimeUnit unit) {
		new Time(time, unit)
	}

	/**
	 * Possibly lossy conversion
	 */
	public static def Time toTime(Duration duration) {
		// should we go for seconds or for nanos?
		val seconds = duration.seconds
		val nanos = duration.nano

		// if there are no seconds, we can go nanos
		if (seconds == 0) {
			return (nanos as long) -> TimeUnit.NANOSECONDS
		}
		// if there are no nanos, we can go seconds
		if (nanos == 0) {
			return seconds -> TimeUnit.SECONDS
		}

		// does everything fit into nanoseconds?
		// this would cause no loss in precision
		val secondsInNanos = seconds * 1_000_000_000
		// only go further if we have no overflow
		if (secondsInNanos > seconds) {
			val overallNanos = secondsInNanos + nanos
			// if we have no overflow, we can return result in nanos
			if (overallNanos > secondsInNanos && overallNanos > nanos) {
				return overallNanos -> TimeUnit.NANOSECONDS
			}
		}

		// Duration does not fit into nanoseconds,
		// do seconds fit into long of millis?
		val secondsInMillis = (seconds * 1_000)
		// check for overflow when convert to millis
		// if so, we simply stick with seconds and drop nanos
		if (secondsInMillis < seconds) {
			return seconds -> TimeUnit.SECONDS
		}
		// otherwise we go for milliseconds, even if there is a loss
		// does duration fit in milliseconds?
		val nanosInMillis = nanos / 1_000_000
		val milliSum = (secondsInMillis + nanosInMillis)
		// check for overflow.
		return if (milliSum < secondsInMillis) {
			// On overflow we keep milliseconds. 
			// We lose less than a second by choosing Long.MAX_VALUE millis.
			// Switching to seconds could lose more precision than staying with millis.
			Long.MAX_VALUE -> TimeUnit.MILLISECONDS
		} else {
			milliSum -> TimeUnit.MILLISECONDS
		}
	}

}
