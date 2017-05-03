package de.fhg.fokus.xtensions.concurrent.circuitbreaker.impl

import org.junit.Test
import static org.junit.Assert.*
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicLong
import de.fhg.fokus.xtensions.concurrent.circuitbreaker.TimeoutStrategy
import java.util.concurrent.CancellationException

class DefaultCircuitBreakerStateTest {
	
	@Test def void createCircuitBreakerStateSettingNoOptions() {
		val state = CircuitBreakerStateBuilder.create
		.build
		assertNotNull(state)
	}
	
	private def createStateAllowingOneError(AtomicLong time, TimeoutStrategy timeoutStrategy) {
		CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(2)
		.toHalfOpenPeriod[|timeoutStrategy]
		.nanoTimeProvider[time.get]
		.build
	}
	
	private def createStateAllowingOneErrorAndGoGlosedState(AtomicLong time, TimeoutStrategy timeout, String cbName) {
		val state = createStateAllowingOneError(time, timeout)
		
		state.exceptionalCall(new NullPointerException, cbName)
		val first = state.isCallPossible(cbName)
		assertTrue("No open after one error expected", first) 
		
		state.exceptionalCall(new ArrayIndexOutOfBoundsException, cbName)
		val second = state.isCallPossible(cbName)
		assertFalse("Open after second error expected", second) 
		
		state
	}
	
	@Test(expected = IllegalArgumentException) def void openOnFailureCountInTimeInvalidFailureCount() {
		CircuitBreakerStateBuilder.create
		.openOnFailureCountInTime(-1, 10, TimeUnit.SECONDS)
	}
	
	@Test(expected = IllegalArgumentException) def void openOnFailureCountInTimeInvalidTime() {
		CircuitBreakerStateBuilder.create
		.openOnFailureCountInTime(1, -5, TimeUnit.SECONDS)
	}
	
	@Test(expected = IllegalArgumentException) def void openOnFailureRateInvalidFailureCount() {
		CircuitBreakerStateBuilder.create
		.openOnFailureRate(-2, 0)
	}
	
	@Test(expected = IllegalArgumentException) def void openOnFailureRateInvalidFailureCountZero() {
		CircuitBreakerStateBuilder.create
		.openOnFailureRate(0, 10)
	}
	
	@Test(expected = IllegalArgumentException) def void openOnFailureRateInvalidTotalCount() {
		CircuitBreakerStateBuilder.create
		.openOnFailureRate(1, -10)
	}
	
	@Test(expected = IllegalArgumentException) def void openOnSubsequentFailureCountInvalidErrorCount() {
		CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(-1)
	}
	
	@Test(expected = NullPointerException) def void toHalfOpenPeriodInvalidNullParam() {
		CircuitBreakerStateBuilder.create
		.toHalfOpenPeriod(null)
	}
	
	
	@Test(expected = IllegalArgumentException) def void neverRecordIllegalClass() {
		CircuitBreakerStateBuilder.create
		.neverRecord(#[NullPointerException, null, IllegalStateException])
	}
	
	@Test(expected = IllegalArgumentException) def void onlyRecordIllegalClass() {
		CircuitBreakerStateBuilder.create
		.neverRecord(#[IllegalStateException, ArrayIndexOutOfBoundsException,null])
	}
	
	@Test def void testCloseToOpen() {
		
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy timeout = [prevTimout,prevTimeout,f|f.apply(100, TimeUnit.NANOSECONDS)]
		
		val state = createStateAllowingOneErrorAndGoGlosedState(time, timeout, cbName)
		
		// check after some time, should still be closed
		time.set(50)
		val openAfterShortTime = state.isCallPossible(cbName)
		assertFalse("State should not be half-open yet", openAfterShortTime)
		
		// go to half open state
		time.set(101)
		
		// check half open state
		val afterHalfOpenTime = state.isCallPossible(cbName)
		assertTrue("Expected half open after timeout", afterHalfOpenTime)
		
		// now success, state should be open
		state.successfulCall(cbName)
		
		// one error should now be allowed
		state.exceptionalCall(new NullPointerException, cbName)
		val afterOpenOneError = state.isCallPossible(cbName)
		assertTrue("One error should be allowed after open again", afterOpenOneError)
		
		state.exceptionalCall(new NullPointerException, cbName)
		val afterTwoErrors = state.isCallPossible(cbName)
		assertFalse("Second error should trip circuit breaker", afterTwoErrors)
	}
	
	
	@Test def void testToHalfOpenTwiceAfterFailureWithCorrectTimeout() {
		// check if open -> halfOpen -> open -> halfOpen uses timeout according to strategy
		val cbName = "foo"
		val time = new AtomicLong(0)
		val timeOut = new AtomicLong(100)
		val TimeoutStrategy timeout = [prevTimout,prevTimeout,f|f.apply(timeOut.get, TimeUnit.NANOSECONDS)]
		
		val state = createStateAllowingOneErrorAndGoGlosedState(time, timeout, cbName)
		// go to half open state
		time.set(101)
		
		// check half open state
		val afterHalfOpenTime = state.isCallPossible(cbName)
		assertTrue("Expected half open after timeout", afterHalfOpenTime)
		
		timeOut.set(200)
		
		state.exceptionalCall(new ArrayIndexOutOfBoundsException,cbName)
		val backToOpen = state.isCallPossible(cbName)
		assertFalse("Error on half-open should cause circuit to open again", backToOpen)
		
		time.set(200)
		val notHalfOpenSecondTime = state.isCallPossible(cbName)
		assertFalse("Circuit should not yet be half-open", notHalfOpenSecondTime)
		
		time.set(302)
		val halfOpenThirdTime = state.isCallPossible(cbName)
		assertTrue("Circuit should be half-open after second timeout.", halfOpenThirdTime)
	}
	
	@Test def void testCloseAndFailOnHalfOpen() {
		
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy timeout = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = createStateAllowingOneErrorAndGoGlosedState(time, timeout, cbName)
		
		// check after some time, should still be closed
		time.set(120)
		val openAfterShortTime = state.isCallPossible(cbName)
		assertFalse("State should not be half-open yet", openAfterShortTime)
		
		// go to half open state
		time.set(201)
		
		// check half open state
		val afterHalfOpenTime = state.isCallPossible(cbName)
		assertTrue("Expected half open after timeout", afterHalfOpenTime)
		
		// now success, state should snap back to open
		state.exceptionalCall(new NullPointerException, cbName)
		
		// call should not be allowed in open mode
		val afterSnapBack = state.isCallPossible(cbName)
		assertFalse("Call should not be allowed after switching from half open to open", afterSnapBack)
	}
	
	// TODO test combinations of open criteria.
	//  * openOnSubsequentFailureCount &  openOnFailureCountInTime (either first)
	//  * openOnSubsequentFailureCount & openOnFailureRate (sequence first)
	//  * openOnFailureRate & openOnFailureCountInTime (either first)
	//  Do not test half open transition
	
	/**
	 * Test if openOnSubsequentFailureCount 
	 */
	@Test def void testTreeConsecutiveOrTwoInFiveTripOnThreeInFour() {
		
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy halfOpenStrategy = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(3)
		.openOnFailureRate(3,5)
		.toHalfOpenPeriod[|halfOpenStrategy]
		.nanoTimeProvider[time.get]
		.build
		
		state.exceptionalCall(new IllegalStateException, cbName)
		val afterFirst = state.isCallPossible(cbName)
		assertTrue("After first failure, calls must still be possible", afterFirst)

		state.exceptionalCall(new NullPointerException, cbName)
		val afterSecond = state.isCallPossible(cbName)
		assertTrue("After second failure, calls must still be possible", afterSecond)
		
		state.successfulCall(cbName)
		
		state.exceptionalCall(new IllegalArgumentException, cbName)
		val afterThird = state.isCallPossible(cbName)
		assertTrue("Third failure in four calls, circuit should be open", afterThird)
		
	}
	
	private static class MyCancellationException extends CancellationException {
	}
	
	@Test def void testNeverOpenMatching() {
		
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy halfOpenStrategy = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(1)
		.toHalfOpenPeriod[|halfOpenStrategy]
		.nanoTimeProvider[time.get]
		.neverRecord(NullPointerException, CancellationException)
		.build
		
		state.exceptionalCall(new NullPointerException, cbName)
		val onNuPoEx = state.isCallPossible(cbName)
		assertTrue("NullPointerException should be ignored.", onNuPoEx)
		
		state.exceptionalCall(new CancellationException, cbName)
		val onCancellationEx = state.isCallPossible(cbName)
		assertTrue("CancellationException should be ignored.", onCancellationEx)
		
		state.exceptionalCall(new MyCancellationException, cbName)
		val onMyCancellationEx = state.isCallPossible(cbName)
		assertTrue("MyCancellationException (subclass of CancellationException) should be ignored.", onMyCancellationEx)
	}
	
	@Test def void testNeverOpenNotMatching() {
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy halfOpenStrategy = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(1)
		.toHalfOpenPeriod[|halfOpenStrategy] 
		.nanoTimeProvider[time.get]
		.neverRecord(NullPointerException, CancellationException)
		.build
		
		state.exceptionalCall(new ArrayIndexOutOfBoundsException, cbName)
		val onArrayIndexEx = state.isCallPossible(cbName)
		assertFalse("ArrayIndexOutOfBoundsException should NOT be ignored.", onArrayIndexEx)
	}
	
	@Test def void testNeverOpenNotMatchingSuperClass() {
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy halfOpenStrategy = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(1)
		.toHalfOpenPeriod[|halfOpenStrategy]
		.nanoTimeProvider[time.get]
		.neverRecord(NullPointerException, CancellationException)
		.build
		
		state.exceptionalCall(new Exception, cbName)
		val onArrayIndexEx = state.isCallPossible(cbName)
		assertFalse("Exception should NOT be ignored.", onArrayIndexEx)
	}
	
	@Test def void testNeverOpenDisable() {
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy halfOpenStrategy = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(1)
		.neverRecord(NullPointerException)
		.toHalfOpenPeriod[|halfOpenStrategy]
		.nanoTimeProvider[time.get]
		.neverRecord(null)
		.build
		
		state.exceptionalCall(new NullPointerException, cbName)
		val onNuPoEx = state.isCallPossible(cbName)
		assertFalse("NullPointerException should not be ignored, because neverRecord was disabled.", onNuPoEx)
	}
	
	@Test def void testOnlyOpenOnMatching() {
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy halfOpenStrategy = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(1)
		.onlyRecord(CancellationException, NullPointerException)
		.toHalfOpenPeriod[|halfOpenStrategy]
		.nanoTimeProvider[time.get]
		.build
		
		state.exceptionalCall(new CancellationException, cbName)
		val onCancel = state.isCallPossible(cbName)
		assertFalse("CancellationException should not be ignored, because onlyRecord was set to this class.", onCancel)
	}
	
	@Test def void testOnlyOpenOnMatchingSubclass() {
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy halfOpenStrategy = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(1)
		.onlyRecord(CancellationException)
		.toHalfOpenPeriod[|halfOpenStrategy]
		.nanoTimeProvider[time.get]
		.build
		
		state.exceptionalCall(new MyCancellationException, cbName)
		val onCancel = state.isCallPossible(cbName)
		assertFalse("MyCancellationException should not be ignored, because onlyRecord was set to super class CancellationException.", onCancel)
	}
	
	@Test def void testOnlyOpenNotMatching() {
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy halfOpenStrategy = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(1)
		.onlyRecord(CancellationException)
		.toHalfOpenPeriod[|halfOpenStrategy]
		.nanoTimeProvider[time.get]
		.build
		
		state.exceptionalCall(new NullPointerException, cbName)
		val onNullPointer = state.isCallPossible(cbName)
		assertTrue("NullPointerException should be ignored, because onlyRecord was set to CancellationException.", onNullPointer)
	}
	
	@Test def void testOnlyOpenNotMatching2() {
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy halfOpenStrategy = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(1)
		.onlyRecord(CancellationException)
		.toHalfOpenPeriod[|halfOpenStrategy]
		.nanoTimeProvider[time.get]
		.build
		
		state.exceptionalCall(new ArrayIndexOutOfBoundsException, cbName)
		val onNullPointer = state.isCallPossible(cbName)
		assertTrue("ArrayIndexOutOfBoundsException should be ignored, because onlyRecord was set to CancellationException.", onNullPointer)
	}
	
	@Test def void testOnlyOpenNotMatchingSuperClass() {
		val cbName = "foo"
		
		val time = new AtomicLong(0)
		val TimeoutStrategy halfOpenStrategy = [prevTimout,prevTimeout,f|f.apply(200, TimeUnit.NANOSECONDS)]
		
		val state = CircuitBreakerStateBuilder.create
		.openOnSubsequentFailureCount(1)
		.onlyRecord(CancellationException)
		.toHalfOpenPeriod[|halfOpenStrategy]
		.nanoTimeProvider[time.get]
		.build
		
		state.exceptionalCall(new Exception, cbName)
		val onNullPointer = state.isCallPossible(cbName)
		assertTrue("Exception should be ignored, because onlyRecord was set to CancellationException.", onNullPointer)
	}
	
	// TODO check filtering by exception: 
	//   * never & onlyOpenOn with Ex in only and never, not in only, some other (neither in only nor never)
	
	// TODO test listener going through all states
	// TODO test listener is called using executor
	
	// TODO some concurrent tests in other class
}