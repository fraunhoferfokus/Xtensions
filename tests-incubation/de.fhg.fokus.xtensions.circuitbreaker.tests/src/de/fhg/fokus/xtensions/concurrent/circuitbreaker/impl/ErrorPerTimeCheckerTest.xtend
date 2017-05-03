package de.fhg.fokus.xtensions.concurrent.circuitbreaker.impl

import org.junit.Test
import static org.junit.Assert.*

/**
 * Tests for {@link ErrorPerTimeChecker}
 */
class ErrorPerTimeCheckerTest {
	
	@Test(expected = IllegalArgumentException) def void testIllegalMaxErrorCount() {
		new ErrorPerTimeChecker(-1, 10, [10])
	}
	
	@Test(expected = IllegalArgumentException) def void testIllegalNegativeTimeIntervalCount() {
		new ErrorPerTimeChecker(1, -10, [10])
	}
	
	@Test(expected = IllegalArgumentException) def void testIllegalZeroTimeIntervalCount() {
		new ErrorPerTimeChecker(1, 0, [10])
	}
	
	@Test(expected = IllegalArgumentException) def void testIllegaNullTimeProvider() {
		new ErrorPerTimeChecker(1, 10, null)
	}
	
	@Test def void testZeroErrorsOnStart() {
		val checker = new ErrorPerTimeChecker(0, 10, [10])
		val result = checker.addErrorAndCheck
		assertFalse("If no error is allowed, error should cause checker to trip",result)
	}
	
	@Test def void testTwoErrorsAllowedThreeErrorsOccuringInFirstInterval() {
		val int[] time = #[0]
		val checker = new ErrorPerTimeChecker(2, 10, [time.get(0)])
		time.set(0,3)
		val first = checker.addErrorAndCheck
		assertTrue("Two errors allowed, one error should not cause checker to trip", first)
		time.set(0,5)
		val second = checker.addErrorAndCheck
		assertTrue("Two errors allowed, second error should not cause checker to trip", second)
		time.set(0,8)
		val third = checker.addErrorAndCheck
		assertFalse("Two errors allowed, third error in interval should cause checker to trip", third)
	}
	
	@Test def void testTwoErrorsAllowedThreeErrorsOccuringInFirstIntervalWithAFewSuccesses() {
		val int[] time = #[0]
		val checker = new ErrorPerTimeChecker(2, 10, [time.get(0)])
		time.set(0,1)
		checker.addSuccess
		time.set(0,3)
		val first = checker.addErrorAndCheck
		assertTrue("Two errors allowed, one error should not cause checker to trip", first)
		time.set(0,4)
		checker.addSuccess
		time.set(0,5)
		val second = checker.addErrorAndCheck
		assertTrue("Two errors allowed, second error should not cause checker to trip", second)
		time.set(0,7)
		checker.addSuccess
		time.set(0,8)
		val third = checker.addErrorAndCheck
		assertFalse("Two errors allowed, third error in interval should cause checker to trip", third)
	}
	
	@Test def void testTwoErrorsAllowedThreeErrorsOccuringInFirstIntervalEnd() {
		val int[] time = #[0]
		val checker = new ErrorPerTimeChecker(2, 10, [time.get(0)])
		time.set(0,3)
		val first = checker.addErrorAndCheck
		assertTrue("Two errors allowed, one error should not cause checker to trip", first)
		time.set(0,5)
		val second = checker.addErrorAndCheck
		assertTrue("Two errors allowed, second error should not cause checker to trip", second)
		time.set(0,10)
		val third = checker.addErrorAndCheck
		assertFalse("Two errors allowed, third error in interval should cause checker to trip", third)
	}
	
	@Test def void testTwoErrorsAllowedTwoErrorsOccuringThenIntervalChange() {
		val int[] time = #[0]
		val checker = new ErrorPerTimeChecker(2, 10, [time.get(0)])
		time.set(0,3)
		val first = checker.addErrorAndCheck
		assertTrue("Two errors allowed, one error should not cause checker to trip", first)
		time.set(0,5)
		val second = checker.addErrorAndCheck
		assertTrue("Two errors allowed, second error should not cause checker to trip", second)
		time.set(0,11)
		val third = checker.addErrorAndCheck
		assertTrue("Two errors allowed, third error is in new interval and should not cause checker to trip", third)
	}
}