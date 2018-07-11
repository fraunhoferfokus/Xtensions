package de.fhg.fokus.xtensions.concurrent.circuitbreaker.impl

import de.fhg.fokus.xtensions.concurrent.circuitbreaker.CancellationByTimeoutException
import de.fhg.fokus.xtensions.concurrent.circuitbreaker.CircuitBreakerState
import de.fhg.fokus.xtensions.concurrent.circuitbreaker.CircuitOpenException
import de.fhg.fokus.xtensions.concurrent.circuitbreaker.RetryStrategy
import java.util.concurrent.CompletableFuture
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.xtend.lib.annotations.Data
import org.junit.Assert
import org.junit.Test
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*

class DefaultCircuitBreakerTest {

	@Test def void createCircuitBreaker() {
		val breaker = CircuitBreakerBuilder.create.build
		val msg = "Default configuration on CircuitBreakerBuilder should build a circuit breaker."
		Assert.assertNotNull(msg, breaker)
	}

	@Data
	private static class AlwaysOpenCircuitBreakerState implements CircuitBreakerState {

		val AtomicBoolean success;
		val AtomicReference<String> msg;

		override isCallPossible(String name) {
			false
		}

		override successfulCall(String name) {
			success.set(false)
			msg.set("CircuitBreakerState#successfulCall() was called although circuit is always open")
		}

		override exceptionalCall(Throwable ex, String name) {
			success.set(false)
			msg.set("CircuitBreakerState#exceptionalCall() was called although circuit is always open")
		}

	}

	@Data
	private static class NeverReachRetry implements RetryStrategy {

		val AtomicBoolean success;

		override <T> withRetryTimeout(CompletableFuture<T> fut) {
			fut
		}

		override checkRetry(Throwable lastFailure, ()=>void noRetry, ()=>void doRetry) {
			// should not ask for retry!
			success.set(false)
			noRetry.apply
		}

	}

	@Test def void openCircuitShouldLeadToNoActionCall() {
		val success = new AtomicBoolean(true)
		val errorMsg = new AtomicReference("")
		
		val strategy = new NeverReachRetry(success)
		val state = new AlwaysOpenCircuitBreakerState(success,errorMsg)

		val extension breaker = CircuitBreakerBuilder.create.stateProvider[|state].
			retryStrategyProvider[|strategy].build
			
		val action = [|
			// action should not be called when circuit is open
			success.set(false)
			errorMsg.set("Action is executed, although circuit is open")
			CompletableFuture.completedFuture("foo")
		]
		action.withBreaker.handle [ t, ex |
			val result = ex instanceof CircuitOpenException
			success.compareAndSet(true, result)
			if (!result) {
				errorMsg.set("Result of breaking action is not CircuitOpenException")
			}
			"recovery"
		].get(100, TimeUnit.MILLISECONDS)

		Assert.assertTrue(errorMsg.get, success.get)
	}

	 static class AlwaysClosedCircuitBreakerState implements CircuitBreakerState {

		val successCount = new AtomicInteger(0)
		val failCount = new AtomicInteger(0)

		override isCallPossible(String name) {
			true
		}

		override successfulCall(String name) {
			successCount.incrementAndGet
		}

		override exceptionalCall(Throwable ex, String name) {
			failCount.incrementAndGet
		}

	}

	@Data static class ReachRetryTimes implements RetryStrategy {
		val int max
		package val retryCount = new AtomicInteger(0)

		override <T> withRetryTimeout(CompletableFuture<T> fut) {
			fut
		}

		override checkRetry(Throwable lastFailure, ()=>void noRetry, ()=>void doRetry) {
			if (retryCount.incrementAndGet > max) {
				// only count actual retries
				retryCount.decrementAndGet
				noRetry.apply
			} else {
				doRetry.apply
			}
		}

	}

	@Test def void retryTwoTimesThenFail() {
		val expectedRetries = 2
		val actionCount = new AtomicInteger()
		val expectedException = new IllegalStateException
		val state = new AlwaysClosedCircuitBreakerState
		val retryStrategy = new ReachRetryTimes(expectedRetries)

		// we do expected - 1 retries, so there are expected calls
		val extension breaker = CircuitBreakerBuilder.create.stateProvider[|state].
			retryStrategyProvider[|retryStrategy].build

		val action = [|
			// action should not be called when circuit is open
			actionCount.incrementAndGet
			val result = new CompletableFuture<String>
			result.completeExceptionally(expectedException)
			result
		]
		// we expect an exception, so we map it to be the result of the future
		val actualException = action.withBreaker.handle[t, ex|ex].get(100, TimeUnit.MILLISECONDS)
		
		val actionMsg = '''Expected «expectedRetries + 1» calls to action, but actually performed «actionCount.get» calls.'''
		Assert.assertEquals(actionMsg, actionCount.get, expectedRetries + 1)
		
		val resultMsg = '''Expected the exception thrown by action, but actually found «actualException».'''
		Assert.assertSame(resultMsg, expectedException, actualException)
		
		val expectedFailCount = expectedRetries + 1
		val actualFailCount = state.failCount.get
		val failCountMsg = '''Expected «expectedFailCount» failures to be recorded, but actually was «actualFailCount».'''
		Assert.assertEquals(failCountMsg, expectedFailCount, actualFailCount)
		
		val actualSuccessCount = state.successCount.get
		val successMsg = '''Expected no successfull call, but found «actualSuccessCount».'''
		Assert.assertEquals(successMsg, 0, actualSuccessCount)
	}

	@Test def void retryThreeTimesThenReturnSuccess() {
		val expectedRetries = 3
		val countDown = new AtomicInteger(expectedRetries)
		val exception = new IllegalStateException
		val expectedResult = "this is the result"
		// allow two retries
		val retryStrategy = new ReachRetryTimes(expectedRetries)
		val state = new AlwaysClosedCircuitBreakerState

		val extension breaker = CircuitBreakerBuilder.create.stateProvider[|state].
			retryStrategyProvider[retryStrategy].build

		val action = [|
			// action should not be called when circuit is open
			val currentCount = countDown.getAndDecrement
			val result = new CompletableFuture<String>
			if (currentCount == 0) {
				result.complete(expectedResult)
			} else {
				result.completeExceptionally(exception)
			}
			result
		]
		val actualResult = action.withBreaker.get(100, TimeUnit.MILLISECONDS)
		
		Assert.assertSame(actualResult, expectedResult)
		
		// two failures, second retry leads to result
		val actualRetries = retryStrategy.retryCount.get;
		val msg = '''Expected «expectedRetries» retries, but actually «actualRetries» retries were performed'''
		Assert.assertSame(msg, expectedRetries, actualRetries)
		
		val expectedFailCount = expectedRetries
		val actualFailCount = state.failCount.get
		val failCountMsg = '''Expected «expectedFailCount» failures to be recorded, but actually was «actualFailCount».'''
		Assert.assertEquals(failCountMsg, expectedFailCount, actualFailCount)
		
		val actualSuccessCount = state.successCount.get
		val successMsg = '''Expected one successfull call, but found «actualSuccessCount».'''
		Assert.assertEquals(successMsg, 1, actualSuccessCount)
	}

	@Test def void retryFourTimesThenReturnDefaultValue() {
		val expectedRetries = 4
		val exception = new IllegalStateException
		val expectedResult = "this is the result"
		// allow two retries
		val retryStrategy = new ReachRetryTimes(expectedRetries)
		val state = new AlwaysClosedCircuitBreakerState

		val extension breaker = CircuitBreakerBuilder.create.stateProvider[|state].
			defaultValueProvider[|expectedResult].retryStrategyProvider[retryStrategy].build

		val action = [|
			val result = new CompletableFuture<String>
			result.completeExceptionally(exception)
			result
		]
		val actualResult = action.withBreaker.get(100, TimeUnit.MILLISECONDS)
		
		Assert.assertSame(actualResult, expectedResult)
		
		// two failures, second retry leads to result
		val actualRetries = retryStrategy.retryCount.get;
		val msg = '''Expected «expectedRetries» retries, but actually «actualRetries» retries were performed'''
		Assert.assertSame(msg, expectedRetries, actualRetries)
		
		val expectedFailCount = expectedRetries + 1
		val actualFailCount = state.failCount.get
		val failCountMsg = '''Expected «expectedFailCount» failures to be recorded, but actually was «actualFailCount».'''
		Assert.assertEquals(failCountMsg, expectedFailCount, actualFailCount)
		
		val actualSuccessCount = state.successCount.get
		val successMsg = '''Expected no successfull call, but found «actualSuccessCount».'''
		Assert.assertEquals(successMsg, 0, actualSuccessCount)
	}

	@Test def void retryThreeTimesThenReturnDefaultException() {
		val expectedRetries = 3
		val exception = new IllegalStateException
		val expectedException = new ArrayIndexOutOfBoundsException
		// allow two retries
		val retryStrategy = new ReachRetryTimes(expectedRetries)
		val state = new AlwaysClosedCircuitBreakerState

		val extension breaker = CircuitBreakerBuilder.create.stateProvider[|state].
			defaultExceptionProvider[|expectedException].retryStrategyProvider[retryStrategy].build

		val action = [|
			val result = new CompletableFuture<String>
			result.completeExceptionally(exception)
			result
		]
		val actualException = action.withBreaker.handle[s, ex|ex].get(100, TimeUnit.MILLISECONDS)
		
		Assert.assertSame(expectedException, actualException)
		
		// two failures, second retry leads to result
		val actualRetries = retryStrategy.retryCount.get;
		val msg = '''Expected «expectedRetries» retries, but actually «actualRetries» retries were performed'''
		Assert.assertSame(msg, expectedRetries, actualRetries)
		
		val expectedFailCount = expectedRetries + 1
		val actualFailCount = state.failCount.get
		val failCountMsg = '''Expected «expectedFailCount» failures to be recorded, but actually was «actualFailCount».'''
		Assert.assertEquals(failCountMsg, expectedFailCount, actualFailCount)
		
		val actualSuccessCount = state.successCount.get
		val successMsg = '''Expected no successfull call, but found «actualSuccessCount».'''
		Assert.assertEquals(successMsg, 0, actualSuccessCount)
	}
	
	

	@Data static class AlwaysRetryNoTimeout implements RetryStrategy {
		
		package val retryCount = new AtomicInteger(0)

		override <T> withRetryTimeout(CompletableFuture<T> fut) {
			fut
		}

		override checkRetry(Throwable lastFailure, ()=>void noRetry, ()=>void doRetry) {
				doRetry.apply
		}

	}
	
	@Data static class OpenAfterNFailuresCircuitBreakerState implements CircuitBreakerState {

		val successCount = new AtomicInteger(0)
		val failCount = new AtomicInteger(0)
		val int max

		override isCallPossible(String name) {
			failCount.get < max
		}

		override successfulCall(String name) {
			successCount.incrementAndGet
		}

		override exceptionalCall(Throwable ex, String name) {
			failCount.incrementAndGet
		}

	}
	
	@Test def void retryFourTimesThenCircuitClose() {
		val expectedRetries = 4
		val actionCount = new AtomicInteger()
		val exception = new NullPointerException
		val state = new OpenAfterNFailuresCircuitBreakerState(expectedRetries+1)
		val retryStrategy = new AlwaysRetryNoTimeout

		// we do expected - 1 retries, so there are expected calls
		val extension breaker = CircuitBreakerBuilder.create.stateProvider[|state].
			retryStrategyProvider[|retryStrategy].build

		val action = [|
			// action should not be called when circuit is open
			actionCount.incrementAndGet
			val result = new CompletableFuture<String>
			result.completeExceptionally(exception)
			result
		]
		// we expect an exception, so we map it to be the result of the future
		val actualException = action.withBreaker.handle[t, ex|ex].get(100, TimeUnit.MILLISECONDS)
		
		val actionMsg = '''Expected «expectedRetries + 1» calls to action, but actually performed «actionCount.get» calls.'''
		Assert.assertEquals(actionMsg, actionCount.get, expectedRetries + 1)
		
		val resultMsg = '''Expected the exception to be instance of CircuitOpenException, but actually found «actualException.class».'''
		Assert.assertTrue(resultMsg, actualException instanceof CircuitOpenException)
		
		val expectedFailCount = expectedRetries + 1
		val actualFailCount = state.failCount.get
		val failCountMsg = '''Expected «expectedFailCount» failures to be recorded, but actually was «actualFailCount».'''
		Assert.assertEquals(failCountMsg, expectedFailCount, actualFailCount)
		
		val actualSuccessCount = state.successCount.get
		val successMsg = '''Expected no successfull call, but found «actualSuccessCount».'''
		Assert.assertEquals(successMsg, 0, actualSuccessCount)
	}

	@Data static class ReachRetryTimesWithTimeout implements RetryStrategy {
		val int max
		package val count = new AtomicInteger(0)
		val long time
		val TimeUnit timeUnit

		override <T> withRetryTimeout(CompletableFuture<T> fut) {
			fut.orTimeout [
				timeout = (time -> timeUnit)
				exceptionProvider = [new CancellationByTimeoutException(time, timeUnit)]
			]
		}

		override checkRetry(Throwable lastFailure, ()=>void noRetry, ()=>void doRetry) {
			if (count.incrementAndGet > max) {
				// only count actual retries
				count.decrementAndGet
				noRetry.apply
			} else {
				doRetry.apply
			}
		}

	}
	
	@Test def void retryTwoTimesBasedOnTimeoutThenFail() {
		val expectedRetries = 2
		// allow two retries
		val retryStrategy = new ReachRetryTimesWithTimeout(expectedRetries, 10, TimeUnit.MILLISECONDS)
		val state = new AlwaysClosedCircuitBreakerState

		val extension breaker = CircuitBreakerBuilder.create.stateProvider[|state]
			.retryStrategyProvider[retryStrategy].build

		// action with no completion
		val action = [|
			new CompletableFuture<String>
		]
		val actualException = action.withBreaker.handle[s, ex|ex].get(500, TimeUnit.MILLISECONDS)
		
		val errMsg = "Error expected to be instance of TimeoutException, but was " + actualException.class
		Assert.assertTrue(errMsg, actualException instanceof CancellationByTimeoutException)
		
		// two failures, second retry leads to result
		val actualRetries = retryStrategy.count.get;
		val msg = '''Expected «expectedRetries» retries, but actually «actualRetries» retries were performed'''
		Assert.assertSame(msg, expectedRetries, actualRetries)

		val expectedFailCount = expectedRetries + 1
		val actualFailCount = state.failCount.get
		val failCountMsg = '''Expected «expectedFailCount» failures to be recorded, but actually was «actualFailCount».'''
		Assert.assertEquals(failCountMsg, expectedFailCount, actualFailCount)
		
		val actualSuccessCount = state.successCount.get
		val successMsg = '''Expected no successfull call, but found «actualSuccessCount».'''
		Assert.assertEquals(successMsg, 0, actualSuccessCount)
	}
	
	@Test def void retryTwoTimesBasedOnTimeoutThenReceiveResult() {
		val expectedRetries = 2
		val retryStrategy = new ReachRetryTimesWithTimeout(expectedRetries, 10, TimeUnit.MILLISECONDS)
		val state = new AlwaysClosedCircuitBreakerState
		val expectedResult = "FooBar"

		val extension breaker = CircuitBreakerBuilder.create.stateProvider[|state]
			.retryStrategyProvider[retryStrategy].build

		val actionCount = new AtomicInteger(0)
		// action with no completion
		val action = [|
			val count = actionCount.getAndIncrement
			val result = new CompletableFuture<String>
			if(count == expectedRetries) {
				result.complete(expectedResult)
			}
			result
		]
		val actualResult = action.withBreaker.get(100, TimeUnit.MILLISECONDS)
		
		val actionMsg = '''Expected «expectedRetries + 1» calls to action, but actually performed «actionCount.get» calls.'''
		Assert.assertEquals(actionMsg, actionCount.get, expectedRetries + 1)
		
		val errMsg = '''Difference between expected and actual action result'''
		Assert.assertEquals(errMsg, expectedResult, actualResult)
		
		// two failures, second retry leads to result
		val actualRetries = retryStrategy.count.get;
		val msg = '''Expected «expectedRetries» retries, but actually «actualRetries» retries were performed'''
		Assert.assertSame(msg, expectedRetries, actualRetries)

		val expectedFailCount = expectedRetries
		val actualFailCount = state.failCount.get
		val failCountMsg = '''Expected «expectedFailCount» failures to be recorded, but actually was «actualFailCount».'''
		Assert.assertEquals(failCountMsg, expectedFailCount, actualFailCount)
		
		val actualSuccessCount = state.successCount.get
		val successMsg = '''Expected one successfull call, but found «actualSuccessCount».'''
		Assert.assertEquals(successMsg, 1, actualSuccessCount)
	}
	
	@Test def void noRetryAllowedFirstTimeSuccess() {
		val expectedRetries = 0
		val expectedResult = "foo"
		// allow two retries
		val retryStrategy = new ReachRetryTimes(expectedRetries)
		val state = new AlwaysClosedCircuitBreakerState

		val extension breaker = CircuitBreakerBuilder.create.stateProvider[|state]
		.retryStrategyProvider[retryStrategy].build

		val action = [|
			val result = new CompletableFuture<String>
			result.complete(expectedResult)
			result
		]
		val actualResult = action.withBreaker.get(100, TimeUnit.MILLISECONDS)
		
		Assert.assertSame(expectedResult, actualResult)
		
		// two failures, second retry leads to result
		val actualRetries = retryStrategy.retryCount.get;
		val msg = '''Expected no retries, but actually «actualRetries» retries were performed'''
		Assert.assertSame(msg, expectedRetries, actualRetries)
		
		val actualFailCount = state.failCount.get
		val failCountMsg = '''Expected no failures to be recorded, but actually was «actualFailCount».'''
		Assert.assertEquals(failCountMsg, 0, actualFailCount)
		
		val actualSuccessCount = state.successCount.get
		val successMsg = '''Expected one successfull call, but found «actualSuccessCount».'''
		Assert.assertEquals(successMsg, 1, actualSuccessCount)
	}

	@Data
	static class AlwaysRetryThreadNameCheckStrategy implements RetryStrategy {
		val String threadName
		val AtomicBoolean success
		val AtomicReference<String> message

		override <T> withRetryTimeout(CompletableFuture<T> fut) {
			val currentThread = Thread.currentThread.name
			val correctThread = currentThread.equals(threadName)
			success.compareAndSet(true, correctThread)
			if(!correctThread) {
				message.set("RetryStrategy#withRetryTimeout was not called on executor thread, but on thread "+ currentThread)
			}
			fut
		}

		override checkRetry(Throwable lastFailure, ()=>void noRetry, ()=>void doRetry) {
			val currentThread = Thread.currentThread.name
			val correctThread = currentThread.equals(threadName)
			success.compareAndSet(true, correctThread)
			if(!correctThread) {
				message.set("RetryStrategy#checkRetry was not called on executor thread, but on thread "+ currentThread)
			}
			doRetry.apply
		}

	}

	@Data
	static class AlwaysClosedThreadNameCheckState implements CircuitBreakerState {

		val String threadName
		val AtomicBoolean success
		val AtomicReference<String> message

		override isCallPossible(String name) {
			val currentThread = Thread.currentThread.name
			val correctThread = currentThread.equals(threadName)
			success.compareAndSet(true, correctThread)
			if(!correctThread) {
				message.set("CircuitBreakerState#isCallPossible was not called on executor thread, but on thread "+ currentThread)
			}
			true
		}

		override successfulCall(String name) {
			val currentThread = Thread.currentThread.name
			val correctThread = currentThread.equals(threadName)
			success.compareAndSet(true, correctThread)
			if(!correctThread) {
				message.set("CircuitBreakerState#successfulCall was not called on executor thread, but on thread "+ currentThread)
			}
		}

		override exceptionalCall(Throwable ex, String name) {
			val currentThread = Thread.currentThread.name
			val correctThread = currentThread.equals(threadName)
			success.compareAndSet(true, correctThread)
			if(!correctThread) {
				message.set("CircuitBreakerState#exceptionalCall was not called on executor thread, but on thread "+ currentThread)
			}
		}

	}

	@Test def void allOperationsOnExecutorThread() {
		val exception = new IllegalStateException
		val threadName = "Test Thread"
		val success = new AtomicBoolean(true)
		val message = new AtomicReference<String>("")
		val executor = Executors.newSingleThreadExecutor[new Thread(it,threadName)]
		val retryStrategy = new AlwaysRetryThreadNameCheckStrategy(threadName, success, message)
		val state = new AlwaysClosedThreadNameCheckState(threadName, success, message)

		val extension breaker = CircuitBreakerBuilder.create.breakerExecutor(executor).stateProvider[|state]
		.retryStrategyProvider[retryStrategy].build

		val failCount = 3

		val actionProvider = [|
			val counter = new AtomicInteger(failCount) 
			return [|
				val result = new CompletableFuture<String>
				val count = counter.getAndDecrement
				if (count == 0) {
					result.complete("foo")
				} else {
					result.completeExceptionally(exception)
				}
				result
			]
		]
		// lets call action a couple of times
		actionProvider.apply.withBreaker.get(100, TimeUnit.MILLISECONDS)
		actionProvider.apply.withBreaker.get(100, TimeUnit.MILLISECONDS)
		actionProvider.apply.withBreaker.get(100, TimeUnit.MILLISECONDS)

	// now check if all operations were executed on correct threads
		Assert.assertTrue(message.get, success.get)
		executor.shutdown()
	}
	
	// TODO how to test cancellation ??
}
