package de.fhg.fokus.xtensions.datetime
import static extension de.fhg.fokus.xtensions.datetime.DurationExtensions.*
import org.junit.Test
import java.time.Duration
import static org.junit.Assert.*
import java.time.temporal.ChronoUnit

class DurationsExtensionsTest {
	
	//////////////////
	// Constructors //
	//////////////////
	
	@Test def testNanoSeconds() {
		assertEquals(Duration.ofNanos(100), 100.nanoseconds)
		assertEquals(Duration.of(100, ChronoUnit.NANOS), 100.nanoseconds)
	}
	
	@Test def testMilliSeconds() {
		assertEquals(Duration.ofMillis(13), 13.milliseconds)
		assertEquals(Duration.of(13, ChronoUnit.MILLIS), 13.milliseconds)
	}
	
	@Test def testMicroSeconds() {
		assertEquals(Duration.of(64, ChronoUnit.MICROS), 64.microseconds)
	}
	
	@Test def testSeconds() {
		assertEquals(Duration.ofSeconds(42), 42.seconds)
		assertEquals(Duration.of(42,ChronoUnit.SECONDS), 42.seconds)
	}
	
	@Test def testMinutes() {
		assertEquals(Duration.ofMinutes(99), 99.minutes)
		assertEquals(Duration.of(99,ChronoUnit.MINUTES), 99.minutes)
	}
	
	@Test def testHours() {
		assertEquals(Duration.ofHours(32), 32.hours)
		assertEquals(Duration.of(32, ChronoUnit.HOURS), 32.hours)
	}
	
	@Test def testDays() {
		assertEquals(Duration.ofDays(7), 7.days)
		assertEquals(Duration.of(7, ChronoUnit.DAYS), 7.days)
	}
	
	////////////////
	// + operator //
	////////////////
	
	@Test def testPlus() {
		val result = Duration.ofSeconds(30) + Duration.ofMinutes(1)
		assertEquals(Duration.ofSeconds(90), result)
	}
	
	////////////////
	// - operator //
	////////////////
	
	@Test def testMinus() {
		val result = Duration.ofSeconds(120) - Duration.ofMinutes(1)
		assertEquals(Duration.ofMinutes(1), result)
	}
	
	////////////////
	// < operator //
	////////////////
	
	@Test def testSmallerThanActuallySmaller() {
		assertTrue(Duration.ofSeconds(30) < Duration.ofMinutes(1))
	}
	
	@Test def testSmallerThanEqual() {
		assertFalse(Duration.ofSeconds(60) < Duration.ofMinutes(1))
	}
	
	@Test def testSmallerThanGreater() {
		assertFalse(Duration.ofSeconds(500) < Duration.ofMinutes(1))
	}
	
	
	
	////////////////
	// <= operator //
	////////////////
	
	@Test def testSmallerThanEqualSmaller() {
		assertTrue(Duration.ofSeconds(30) <= Duration.ofMinutes(1))
	}
	
	@Test def testSmallerThanEqualEqual() {
		assertTrue(Duration.ofSeconds(60) <= Duration.ofMinutes(1))
	}
	
	@Test def testSmallerThanEqualGreater() {
		assertFalse(Duration.ofSeconds(500) <= Duration.ofMinutes(1))
	}
	
	/////////////////
	// >= operator //
	/////////////////
	
	@Test def testGreaterThanActuallyGreater() {
		assertTrue(Duration.ofDays(1) > Duration.ofMinutes(1))
	}
	
	@Test def testGreaterThanEqual() {
		assertFalse(Duration.ofSeconds(120) > Duration.ofMinutes(2))
	}
	
	@Test def testGreaterThanSmaller() {
		assertFalse(Duration.ofMinutes(2) > Duration.ofDays(3))
	}
	
	/////////////////
	// >= operator //
	/////////////////
	
	@Test def testGreaterThanEqualGreater() {
		assertTrue(Duration.ofDays(1) >= Duration.ofMinutes(1))
	}
	
	@Test def testGreaterThanEqualEqual() {
		assertTrue(Duration.ofSeconds(120) >= Duration.ofMinutes(2))
	}
	
	@Test def testGreaterThanEqualSmaller() {
		assertFalse(Duration.ofMinutes(2) >= Duration.ofDays(3))
	}
	
	//////////////////
	// <=> operator //
	//////////////////
	
	@Test def testSpaceshipGreater() {
		val result = Duration.ofDays(1) <=> Duration.ofMinutes(1)
		assertTrue(result > 0)
	}
	
	@Test def testSpaceshipEqual() {
		val result = Duration.ofSeconds(120) <=> Duration.ofMinutes(2)
		assertEquals(0, result)
	}
	
	@Test def testSpaceshipSmaller() {
		val result = Duration.ofMinutes(2) <=> Duration.ofDays(3)
		assertTrue(result < 0)
	}
	
	////////////////
	// * oeprator //
	////////////////
	
	@Test def testMultiplicationValue() {
		val result = Duration.ofMinutes(60) * 3
		val expected = Duration.ofHours(3)
		assertEquals(expected, result)
	}
	
	@Test def testMultiplicationZero() {
		val result = Duration.ofHours(5) * 0
		assertTrue(result.zero)
	}
	
	@Test(expected = ArithmeticException) def void testMultiplyToOverflow() {
		Duration.ofMinutes(1) * Long.MAX_VALUE
	}
	
	/////////////////////	
	// divide operator //
	/////////////////////
	
	@Test def testDivideOperator() {
		val result = Duration.ofMinutes(1) / 60
		val expected = Duration.ofSeconds(1)
		assertEquals(expected, result)
	}
	
	@Test(expected = ArithmeticException) def void testDivideByZero() {
		Duration.ofMinutes(1) / 0
	}
}