package de.fhg.fokus.xtensions.concurrent.circuitbreaker.impl

import org.junit.Test
import static org.junit.Assert.*;

/**
 * Tests for {@link ErrorRateChecker}
 */
class ErrorRateStatisticsTest {

	@Test(expected=IllegalArgumentException) def void testZeroSize() {
		new ErrorRateChecker(0, 0)
	}

	@Test def void testZeroErrors() {
		val rateChecker = new ErrorRateChecker(10, 0)
		val result = rateChecker.addErrorAndCheck
		assertFalse("If no error is allowed every error should cause rate to trip", result)
	}

	@Test def void testZeroErrorsWhenFull() {
		val rateChecker = new ErrorRateChecker(10, 0)
		(1 .. 11).forEach [
			rateChecker.addSuccess
		]
		val result = rateChecker.addErrorAndCheck
		assertFalse("If no error is allowed every error, also after success, should cause rate to trip", result)
	}

	@Test def void testErrorsAtBegining() {
		val rateChecker = new ErrorRateChecker(10, 2)
		val first = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the first error should not cause rate to trip", first)
		val second = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the second error should not cause rate to trip", second)
		val result = rateChecker.addErrorAndCheck
		assertFalse("If two errors are allowed the third error should cause rate to trip", result)
	}

	@Test def void testErrorsAtBoundary() {
		val rateChecker = new ErrorRateChecker(10, 2)
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		val first = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the first error should not cause rate to trip", first)
		val second = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the second error should not cause rate to trip", second)
		val result = rateChecker.addErrorAndCheck
		assertFalse("If two errors are allowed the third error should cause rate to trip", result)
	}

	@Test def void testErrorsOverBoundary() {
		val rateChecker = new ErrorRateChecker(10, 2)
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		val first = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the first error should not cause rate to trip", first)
		val second = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the second error should not cause rate to trip", second)
		val result = rateChecker.addErrorAndCheck
		assertFalse("If two errors are allowed the third error should cause rate to trip", result)
	}

	@Test def void testThreeNonConsecutiveErrors() {
		val rateChecker = new ErrorRateChecker(10, 2)
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		val first = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the first error should not cause rate to trip", first)
		rateChecker.addSuccess
		rateChecker.addSuccess
		val second = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the second error should not cause rate to trip", second)
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		val result = rateChecker.addErrorAndCheck
		assertFalse("If two errors are allowed the third error should cause rate to trip", result)
	}

	@Test def void testThreeNonConsecutiveErrorsFurthestApart() {
		val rateChecker = new ErrorRateChecker(10, 2)
		rateChecker.addSuccess
		rateChecker.addSuccess
		val first = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the first error should not cause rate to trip", first)
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		val second = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the second error should not cause rate to trip", second)
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		val result = rateChecker.addErrorAndCheck
		assertFalse("If two errors are allowed the third error should cause rate to trip", result)
	}

	@Test def void testThreeNonConsecutiveErrorsTooFarApart() {
		val rateChecker = new ErrorRateChecker(10, 2)
		rateChecker.addSuccess
		val first = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the first error should not cause rate to trip", first)
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		val second = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed, the second error should not cause rate to trip", second)
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		rateChecker.addSuccess
		val result = rateChecker.addErrorAndCheck
		assertTrue("If two errors are allowed in the last 10 and and the third error is too far apart, the rate should not trip", result)
	}

}
