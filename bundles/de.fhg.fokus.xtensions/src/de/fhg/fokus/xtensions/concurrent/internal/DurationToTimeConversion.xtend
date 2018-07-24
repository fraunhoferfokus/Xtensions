/*******************************************************************************
 * Copyright (c) 2017-2018 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.concurrent.internal

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
	@Data static class Time {
		public final long amount;
		public final TimeUnit unit;
	}

	/**
	 * Shortcut for constructor of {@link Time}.
	 */
	private static def Time -> (long time, TimeUnit unit) {
		new Time(time, unit)
	}

	/**
	 * Possibly lossy conversion
	 * @param duration the duration to be represented as {@link Time}.
	 * @return Time representation of given {@code duration}
	 */
	static def Time toTime(Duration duration) {
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
		try {
			val secondsInNanos = Math.multiplyExact(seconds, 1_000_000_000)
			val overallNanos = Math.addExact(secondsInNanos, nanos)
			return overallNanos -> TimeUnit.NANOSECONDS
		} catch (ArithmeticException e) {
			// overflow occurred, we need to find different strategy
		}

		// Duration does not fit into nanoseconds,
		// do seconds fit into long of millis?
		var secondsInMillis = 0L
		try {
			secondsInMillis = Math.multiplyExact(seconds, 1_000)
		} catch (ArithmeticException e) {
			// overflow occurred, we simply stick to seconds
			return seconds -> TimeUnit.SECONDS
		}
		// otherwise we go for milliseconds, even if there is a loss
		// does duration fit in milliseconds?
		val nanosInMillis = nanos / 1_000_000
		return try {
			val milliSum = Math.addExact(secondsInMillis, nanosInMillis)
			milliSum -> TimeUnit.MILLISECONDS
		} catch (ArithmeticException e) {
			// On overflow we keep milliseconds. 
			// We lose less than a second by choosing Long.MAX_VALUE millis.
			// Switching to seconds could lose more precision than staying with millis.
			Long.MAX_VALUE -> TimeUnit.MILLISECONDS
		}
	}
}
