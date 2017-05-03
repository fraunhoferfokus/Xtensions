package de.fhg.fokus.xtensions.concurrent.circuitbreaker.impl

import org.junit.Test
import static org.junit.Assert.*

/**
 * Tests for {@link ErrorSequnceChecker}
 */
class ErrorSequnceCheckerTest {
	
	@Test(expected = IllegalArgumentException) def void testIllegalArgumentMaxBelowZero() {
		new ErrorSequnceChecker(-2)
	}
	
	@Test def void testZeroErrorCheck() {
		val checker = new ErrorSequnceChecker(1)
		val result = checker.addErrorAndCheck
		assertFalse("No error allowed, checker schould trip on error", result)
	}
	
	@Test def void testZeroErrorCheckWithPriorSuccess() {
		val checker = new ErrorSequnceChecker(1)
		checker.addSuccess
		checker.addSuccess
		checker.addSuccess
		val result = checker.addErrorAndCheck
		assertFalse("No error allowed, checker schould trip on error", result)
	}
	
	@Test def void testTwoErrorsAlowedThreErrorsOccurring() {
		val checker = new ErrorSequnceChecker(3)
		val one = checker.addErrorAndCheck
		assertTrue("Two errors allowed, one error should be allowed", one)
		val two = checker.addErrorAndCheck
		assertTrue("Two errors allowed, two errors should be allowed", two)
		val three = checker.addErrorAndCheck
		assertFalse("Two errors allowed, three errors should not be allowed", three)
	}
	
	@Test def void testTwoErrorsAlowdThreErrorsButNotConsecutive() {
		val checker = new ErrorSequnceChecker(3)
		val one = checker.addErrorAndCheck
		assertTrue("Two errors allowed, one error should be allowed", one)
		val two = checker.addErrorAndCheck
		assertTrue("Two errors allowed, two errors should be allowed", two)
		checker.addSuccess
		val three = checker.addErrorAndCheck
		assertTrue("Two errors allowed, three errors should not be allowed", three)
	}
}