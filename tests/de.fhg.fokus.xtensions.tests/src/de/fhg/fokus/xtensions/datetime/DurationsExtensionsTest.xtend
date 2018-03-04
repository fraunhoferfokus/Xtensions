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
package de.fhg.fokus.xtensions.datetime
import static extension de.fhg.fokus.xtensions.datetime.DurationExtensions.*
import org.junit.Test
import static org.junit.Assert.*
import java.time.temporal.ChronoUnit

class DurationsExtensionsTest {
	
	//////////////////
	// Constructors //
	//////////////////
	
	@Test def testNanoSeconds() {
		assertEquals(java.time.Duration.ofNanos(100), 100.nanoseconds)
		assertEquals(java.time.Duration.of(100, ChronoUnit.NANOS), 100.nanoseconds)
	}
	
	@Test def testMilliSeconds() {
		assertEquals(java.time.Duration.ofMillis(13), 13.milliseconds)
		assertEquals(java.time.Duration.of(13, ChronoUnit.MILLIS), 13.milliseconds)
	}
	
	@Test def testMicroSeconds() {
		assertEquals(java.time.Duration.of(64, ChronoUnit.MICROS), 64.microseconds)
	}
	
	@Test def testSeconds() {
		assertEquals(java.time.Duration.ofSeconds(42), 42.seconds)
		assertEquals(java.time.Duration.of(42,ChronoUnit.SECONDS), 42.seconds)
	}
	
	@Test def testMinutes() {
		assertEquals(java.time.Duration.ofMinutes(99), 99.minutes)
		assertEquals(java.time.Duration.of(99,ChronoUnit.MINUTES), 99.minutes)
	}
	
	@Test def testHours() {
		assertEquals(java.time.Duration.ofHours(32), 32.hours)
		assertEquals(java.time.Duration.of(32, ChronoUnit.HOURS), 32.hours)
	}
	
	@Test def testDays() {
		assertEquals(java.time.Duration.ofDays(7), 7.days)
		assertEquals(java.time.Duration.of(7, ChronoUnit.DAYS), 7.days)
	}
	
	////////////////
	// + operator //
	////////////////
	
	@Test def testPlus() {
		val result = java.time.Duration.ofSeconds(30) + java.time.Duration.ofMinutes(1)
		assertEquals(java.time.Duration.ofSeconds(90), result)
	}
	
	////////////////
	// - operator //
	////////////////
	
	@Test def testMinus() {
		val result = java.time.Duration.ofSeconds(120) - java.time.Duration.ofMinutes(1)
		assertEquals(java.time.Duration.ofMinutes(1), result)
	}
	
	////////////////
	// < operator //
	////////////////
	
	@Test def testSmallerThanActuallySmaller() {
		assertTrue(java.time.Duration.ofSeconds(30) < java.time.Duration.ofMinutes(1))
	}
	
	@Test def testSmallerThanEqual() {
		assertFalse(java.time.Duration.ofSeconds(60) < java.time.Duration.ofMinutes(1))
	}
	
	@Test def testSmallerThanGreater() {
		assertFalse(java.time.Duration.ofSeconds(500) < java.time.Duration.ofMinutes(1))
	}
	
	
	
	////////////////
	// <= operator //
	////////////////
	
	@Test def testSmallerThanEqualSmaller() {
		assertTrue(java.time.Duration.ofSeconds(30) <= java.time.Duration.ofMinutes(1))
	}
	
	@Test def testSmallerThanEqualEqual() {
		assertTrue(java.time.Duration.ofSeconds(60) <= java.time.Duration.ofMinutes(1))
	}
	
	@Test def testSmallerThanEqualGreater() {
		assertFalse(java.time.Duration.ofSeconds(500) <= java.time.Duration.ofMinutes(1))
	}
	
	/////////////////
	// >= operator //
	/////////////////
	
	@Test def testGreaterThanActuallyGreater() {
		assertTrue(java.time.Duration.ofDays(1) > java.time.Duration.ofMinutes(1))
	}
	
	@Test def testGreaterThanEqual() {
		assertFalse(java.time.Duration.ofSeconds(120) > java.time.Duration.ofMinutes(2))
	}
	
	@Test def testGreaterThanSmaller() {
		assertFalse(java.time.Duration.ofMinutes(2) > java.time.Duration.ofDays(3))
	}
	
	/////////////////
	// >= operator //
	/////////////////
	
	@Test def testGreaterThanEqualGreater() {
		assertTrue(java.time.Duration.ofDays(1) >= java.time.Duration.ofMinutes(1))
	}
	
	@Test def testGreaterThanEqualEqual() {
		assertTrue(java.time.Duration.ofSeconds(120) >= java.time.Duration.ofMinutes(2))
	}
	
	@Test def testGreaterThanEqualSmaller() {
		assertFalse(java.time.Duration.ofMinutes(2) >= java.time.Duration.ofDays(3))
	}
	
	//////////////////
	// <=> operator //
	//////////////////
	
	@Test def testSpaceshipGreater() {
		val result = java.time.Duration.ofDays(1) <=> java.time.Duration.ofMinutes(1)
		assertTrue(result > 0)
	}
	
	@Test def testSpaceshipEqual() {
		val result = java.time.Duration.ofSeconds(120) <=> java.time.Duration.ofMinutes(2)
		assertEquals(0, result)
	}
	
	@Test def testSpaceshipSmaller() {
		val result = java.time.Duration.ofMinutes(2) <=> java.time.Duration.ofDays(3)
		assertTrue(result < 0)
	}
	
	////////////////
	// * oeprator //
	////////////////
	
	@Test def testMultiplicationValue() {
		val result = java.time.Duration.ofMinutes(60) * 3
		val expected = java.time.Duration.ofHours(3)
		assertEquals(expected, result)
	}
	
	@Test def testMultiplicationZero() {
		val result = java.time.Duration.ofHours(5) * 0
		assertTrue(result.zero)
	}
	
	@Test(expected = ArithmeticException) def void testMultiplyToOverflow() {
		java.time.Duration.ofMinutes(1) * Long.MAX_VALUE
	}
	
	/////////////////////	
	// divide operator //
	/////////////////////
	
	@Test def testDivideOperator() {
		val result = java.time.Duration.ofMinutes(1) / 60
		val expected = java.time.Duration.ofSeconds(1)
		assertEquals(expected, result)
	}
	
	@Test(expected = ArithmeticException) def void testDivideByZero() {
		java.time.Duration.ofMinutes(1) / 0
	}
}