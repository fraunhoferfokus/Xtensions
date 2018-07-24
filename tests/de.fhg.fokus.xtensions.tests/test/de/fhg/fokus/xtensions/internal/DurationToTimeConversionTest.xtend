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
package de.fhg.fokus.xtensions.internal

import static extension de.fhg.fokus.xtensions.concurrent.internal.DurationToTimeConversion.*
import org.junit.Test
import static org.junit.Assert.*
import java.time.Duration
import java.util.concurrent.TimeUnit

class DurationToTimeConversionTest {
	
	@Test def void convertOneNanosecond() {
		val expectedNanos = 1
		val duration = Duration.ofNanos(expectedNanos)
		val time = duration.toTime
		val timeInNanos = time.unit.toNanos(time.amount)
		assertEquals("Conversion of nanoseconds", expectedNanos, timeInNanos)
	}
	
	@Test def void convertMaximumNanosecond() {
		val expectedNanos = Long.MAX_VALUE
		val duration = Duration.ofNanos(expectedNanos)
		val time = duration.toTime
		val timeInNanos = time.unit.toNanos(time.amount)
		assertEquals("Conversion of nanoseconds", expectedNanos, timeInNanos)
	}
	
	@Test def void convertMaxDuration() {
		val duration = Duration.ofSeconds(Long.MAX_VALUE).withNanos(999_999_999)
		// since maximum allowed nanos are under one second,
		// the conversion should just keep the seconds
		val time = duration.toTime
		val timeInSeconds = time.unit.toSeconds(time.amount)
		assertEquals("Time must have the maximum of seconds", Long.MAX_VALUE, timeInSeconds)
	}
	
	@Test def void convertOneDay() {
		val duration = Duration.ofDays(1)
		val time = duration.toTime
		val timeInDays = time.unit.toDays(time.amount)
		assertEquals("Conversion of day", 1, timeInDays)
	}
	
	@Test def void convertOneDayAndSomeNanos() {
		val expectedNanos = (24L /*h*/ * 60L /*min*/ * 60L /*sec*/ * 1_000_000_000L /*nanos*/) + 10L
		val duration = Duration.ofDays(1).withNanos(10)
		val time = duration.toTime
		val timeInNanos = time.unit.toNanos(time.amount)
		assertEquals("Conversion of day", expectedNanos, timeInNanos)
	}
	
	@Test def void convertManyDaysAndSomeNanos() {
		// force overflow of nanoseconds, so result 
		// cannot be returned as nanoseconds
		val days = 293L * 365L
		val duration = Duration.ofDays(days).withNanos(10)
		val time = duration.toTime
		val timeInDays = time.unit.toDays(time.amount)
		assertEquals("Conversion of days", days, timeInDays)
	}
	
	@Test def void convertOutOfRangeOfNanoShouldSwitchToMilli() {
		val duration = Duration.ofNanos(Long.MAX_VALUE).plus(Duration.ofNanos(1))
		val time = duration.toTime
		val unit = time.unit
		val msg = "Time unit should switch from nanos to millis, since nanos don't fit anymore."
		assertEquals(msg, TimeUnit.MILLISECONDS, unit)
	}
	
	@Test def void convertMaximumMillisLossless() {
		val duration = Duration.ofMillis(Long.MAX_VALUE)
		val time = duration.toTime
		val timeInMillis = time.unit.toMillis(time.amount)
		assertEquals("Conversion of maximum millis should be lossless.", Long.MAX_VALUE, timeInMillis)
	}
	
	@Test def void convertMaximumMillisPlusOneMili() {
		val seconds = TimeUnit.MILLISECONDS.toSeconds(Long.MAX_VALUE)
		val milliRest = Long.MAX_VALUE - TimeUnit.SECONDS.toMillis(seconds) + 1
		val nanoRest = TimeUnit.MILLISECONDS.toNanos(milliRest) as int
		val duration = Duration.ofSeconds(seconds).withNanos(nanoRest)
		val time = duration.toTime
		val timeInMillis = time.unit.toMillis(time.amount)
		assertEquals("Conversion should only lose nanos.", Long.MAX_VALUE, timeInMillis)
	}
}