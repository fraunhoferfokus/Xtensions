package de.fhg.fokus.xtensions.concurrent.circuitbreaker

import java.util.concurrent.CompletableFuture
import java.util.concurrent.Executor
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*
import java.util.concurrent.ForkJoinPool
import java.util.Objects
import java.util.concurrent.CancellationException
import java.util.concurrent.TimeUnit

/**
 * The CircuitBreaker wraps around operations that return CompletableFutures
 * and based on the configuration may retry the operations if they fail or complete
 * with default values or default exceptions. The internal state may cause failing 
 * results, without even calling a given action, if the circuit is opened.<br>
 * A recommended way of usage within Xtend is to declare an extension field or value,
 * so the function can be used in the following way:
 * <pre><code>val extension breaker = SimpleCircuitBreakerBuilder.create.build // or other implementation
 * def callSomeAction() {
 * 	[someAction()].withBreaker
 * }
 * </code></pre>
 */
interface CircuitBreaker<T> {

	/**
	 * This method performs the given action, possibly multiple times, until 
	 * it returns a result regarded successful, or some criterion decided to not to
	 * call or retry the action.
	 * One of this criterion may be an opened circuit. 
	 * 
	 * All CircuitBreaker logic will be performed on a configured Executor.
	 * The returned future may complete with {@link CircuitOpenException} if the action cannot be completed,
	 * because of an open circuit.
	 * 
	 * @param action is the operation that may be called, possibly multiple times, to get 
	 *  the result that is forwarded to the future returned by this method.
	 * @return future that will either be completed with the result of the given {@code action}
	 *    or with a default value (if configured) or with a default exception (if configured),
	 *    or a CircuitOpenException, if the circuit was opened. Canceling the future from outside
	 *    should be recognized by the CircuitBreaker implementation and should lead to no further
	 *    retries and canceling of the latest action future. However, there is no guarantee that 
	 *    a successfully cancelled result will cause actions and retries to stop.
	 */
	def CompletableFuture<T> withBreaker(=>CompletableFuture<? extends T> action)

	/**
	 * This method performs the given action, possibly multiple times, until 
	 * it returns a result regarded successful, or some criterion decided to not to 
	 * call or retry the action.
	 * One of this criterion may be an opened circuit.
	 * 
	 * All CircuitBreaker logic will be performed using the given executor.
	 * 
	 * @param executor The executor which will be used to perform all the CircuitBreaker logic on.
	 * @param action is the operation that may be called, possibly multiple times, to get 
	 *  the result that is forwarded to the future returned by this method.
	 * @return future that will either be completed with the result of the given {@code action}
	 *    or with a default value (if configured) or with a default exception (if configured),
	 *    or a CircuitOpenException, if the circuit was opened. Canceling the future from outside
	 *    should be recognized by the CircuitBreaker implementation and should lead to no further
	 *    retries and canceling of the latest action future. However, there is no guarantee that 
	 *    a successfully cancelled result will cause actions and retries to stop.
	 */
	def CompletableFuture<T> withBreaker(Executor executor, =>CompletableFuture<? extends T> action)
}

/**
 * Will be used to complete a result of a {@link CircuitBreaker#withBreaker(Function0) CircuitBreaker#withBreaker}
 * with an instance of this class. If this exception is instantiated with a wrapped "cause" exception, this should
 * be the last error returned by the action to be performed in the circuit breaker.
 */
final class CircuitOpenException extends Exception {
	
	/**
	 * Default constructor
	 */
	new() {
	}
	
	/**
	 * Calls {@code super(cause)}. Throwable should be the 
	 * the one returned by action of last failed call
	 * @see Exception#Exception(Throwable)
	 */
	new(Throwable cause) {
		super(cause)
	}
	
	/**
	 * Calls {@code super(message)}
	 * @see Exception#Exception(String)
	 */
	new(String message) {
		super(message)
	}

	/**
	 * Calls {@code super(message, cause)}. Throwable should be the 
	 * the one returned by action of last failed call
	 * @see Exception#Exception(String,Throwable)
	 */
	new(String message, Throwable cause) {
		super(message, cause)
	}
	
	private static def void callOnCircuitOpenException(Throwable it, (CircuitOpenException)=>void action) {
		if (it instanceof CircuitOpenException) {
			action.apply(it)
		}
	}

	/**
	 * May be used as extension function, calls the action when the future completes with a CircuitOpenException
	 */
	static def <R> CompletableFuture<R> whenCircuitOpen(CompletableFuture<R> fut, (CircuitOpenException)=>void action) {
		Objects.requireNonNull(action)
		fut.whenException[callOnCircuitOpenException(it, action)]
	}

	/**
	 * May be used as extension function, calls the action on the given executor when the future completes with a CircuitOpenException
	 */
	static def <R> CompletableFuture<R> whenCircuitOpenAsync(CompletableFuture<R> fut, Executor e,
		(CircuitOpenException)=>void action) {
		Objects.requireNonNull(action)
		fut.whenExceptionAsync(e)[callOnCircuitOpenException(it, action)]
	}

	/**
	 * May be used as extension function, calls the action on the common ForkJoinPool when the future completes with a CircuitOpenException
	 */
	static def <R> CompletableFuture<R> whenCircuitOpenAsync(CompletableFuture<R> fut,
		(CircuitOpenException)=>void action) {
		fut.whenCircuitOpenAsync(ForkJoinPool.commonPool, action)
	}
}

/**
 * If an Action used with a {@link CircuitBreaker} fails because of a configured timeout,
 * the action should be canceled using this exception class.
 */
final class CancellationByTimeoutException extends CancellationException {
	private val long timeout;
	private val TimeUnit timeoutTimeUnit;
	
	/**
	 * Passes the timeout time and time unit that passed, so that an action was 
	 * timed out and cancelled using the created CancellationByTimeoutException.
	 */
	new(long timeout, TimeUnit timeUnit) {
		this.timeout = timeout
		this.timeoutTimeUnit = timeUnit
	}
	
	/**
	 * Time passed until action timed out. This is the scalar value 
	 * of time, the time unit can be obtained using {@link #getTimeoutTimeUnit()}
	 */
	def getTimeout() {
		timeout
	}
	
	/**
	 * The TimeUnit of the {@link #getTimeout() timeout}.
	 */
	def getTimeoutTimeUnit() {
		timeoutTimeUnit
	}
}