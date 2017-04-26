package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl

import java.util.concurrent.Executor
import java.util.concurrent.CompletableFuture
import java.util.concurrent.ForkJoinPool
import static extension de.fhg.fokus.xtenders.concurrent.CompletableFutureExtensions.*
import java.util.concurrent.CancellationException
import java.util.Objects
import java.util.UUID
import java.util.concurrent.RejectedExecutionException
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitBreakerState
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.RetryStrategy
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitBreaker
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitOpenException

/**
 * Builder for a default implementation of {@link CircuitBreaker}.<br>
 * Every method call of this class creates a new object, so that every step can be 
 * used as a snapshot and used for different configurations based on the
 * previous one. This makes the class effectively immutable.
 * However, this does imply that the class is thread safe.
 */
final class CircuitBreakerBuilder<T> implements Cloneable {

	private new() {
	}

	package String name = null
	package =>CircuitBreakerState stateProvider = null
	package =>T valueProvider = null
	package =>RetryStrategy strategy = [SimpleRetryStrategies.NO_RETRY_NO_TIMEOUT_STRATEGY]
	package Executor breakerExecutor = null
	package =>Throwable exceptionProvider = null

	public static def <T> CircuitBreakerBuilder<T> create() {
		new CircuitBreakerBuilder<T>
	}

	/**
	 * Sets the name of the circuit breaker that is passed on to 
	 * the circuit breaker state.
	 * By default and if {@code null} is chosen as name,
	 * a random UUID will be assigned to the name when building
	 * the CircuitBreaker.
	 */
	def CircuitBreakerBuilder<T> name(String name) {
		val result = this.clone
		result.name = name
		result
	}

	/**
	 * If this value is not set, the a default provider will be chosen based on the 
	 * default configuration of {@link SimpleCircuitBreakerStateBuilder}.
	 * @see CircuitBreakerStateBuilder
	 */
	def CircuitBreakerBuilder<T> stateProvider(=>CircuitBreakerState stateProvider) {
		Objects.requireNonNull(stateProvider)
		val result = this.clone
		result.stateProvider = stateProvider
		result
	}

	/**
	 * The provider should return a new strategy instance on each call. Attention:
	 * if no retry strategy is provided by the user a default one is selected. This
	 * will be {@link SimpleRetryStrategies#NO_RETRY_NO_TIMEOUT_STRATEGY}.
	 * @see RetryStrategyBuilder
	 * @see SimpleRetryStrategies
	 * @throws 
	 */
	def CircuitBreakerBuilder<T> retryStrategyProvider(=>RetryStrategy strategyProvider) throws NullPointerException {
		Objects.requireNonNull(strategyProvider)
		val result = this.clone
		result.strategy = strategyProvider
		result
	}

	/**
	 * All logic of the created circuit breaker will run on the given executor.
	 * By default this option is set to the common ForkJoinPool.
	 * @see java.util.concurrent.Executors
	 */
	def CircuitBreakerBuilder<T> breakerExecutor(Executor breakerExecutor) {
		val result = this.clone
		result.breakerExecutor = breakerExecutor
		result
	}

	/**
	 * If this option is set, if an option fails, despite retries, the given
	 * {@code valueProvider} will be used to return a default result.<br>
	 * By default no value provider will be set. If this is set, it will shadow any
	 * previously set {@link #noValueExceptionProvider(Function0) noValueExceptionProvider}.
	 * 
	 * @see #noValueExceptionProvider(Function0)
	 */
	def CircuitBreakerBuilder<T> defaultValueProvider(=>T valueProvider) {
		Objects.requireNonNull(valueProvider)
		val result = this.clone
		result.valueProvider = valueProvider
		result
	}

	/**
	 * if {@link #defaultValueProvider(Function0) defaultValue} is set, the {@link exceptionProvider} 
	 * will never be used. This option can be un-set by calling this method with {@code null}.
	 * 
	 * @see #defaultValueProvider(Function0)
	 */
	def CircuitBreakerBuilder<T> defaultExceptionProvider(=>Throwable exceptionProvider) {
		Objects.requireNonNull(exceptionProvider)
		val result = this.clone
		result.exceptionProvider = exceptionProvider
		result
	}

	/**
	 * Creates a new instance of {@link CircuitBreaker} based on the configuration
	 * of this builder.
	 */
	def CircuitBreaker<T> build() throws IllegalStateException {
		val builder = selfWithDefaults()
		new SimpleCircuitBreaker(builder)
	}

	private def CircuitBreakerBuilder<T> selfWithDefaults() {
		val result = this.clone
		if (result.name === null) {
			result.name = UUID.randomUUID.toString
		}
		if (result.breakerExecutor === null) {
			result.breakerExecutor = ForkJoinPool.commonPool
		}
		if (result.stateProvider === null) {
			val stateBuilder = CircuitBreakerStateBuilder.create
			result.stateProvider = [stateBuilder.build]
		}
		if (result.strategy === null) {
			val strategyBuilder = RetryStrategyBuilder.create
			result.strategy = [strategyBuilder.build]
		}
		result
	}

	protected override def CircuitBreakerBuilder<T> clone() {
		super.clone as CircuitBreakerBuilder<T>
	}
}

/**
 * Used to signal that the user of the CircuitBreaker API cancelled an
 * operation.
 */
package class CancelledFromOutsideException extends CancellationException {
}

/**
 * Default implementation of CircuitBreaker that is created using the
 * {@link CircuitBreakerBuilder}
 */
package final class SimpleCircuitBreaker<T> implements CircuitBreaker<T> {

	private static val String NULL_FROM_ACTION_MSG = "Action returned null instead of CompletableFuture"
	private static val String DEFAULT_EXCEPTION_NULL_MSG = "Default exception was null"

	private extension val CircuitBreakerBuilder<T> config
	
	/**
	 * Internal state, checking if calls are allowed or not,
	 * based on success and error statistics.
	 */
	private val CircuitBreakerState breakerState
	
	// chooses between: providing a default value, providing default exception, choosing original exception
	private val (Throwable, CompletableFuture<T>)=>void lastResortResultCompletion
	private val (=>Throwable, CompletableFuture<T>)=>void lazyLastResortResultCompletion

	package new(CircuitBreakerBuilder<T> builder) {
		this.config = builder
		this.breakerState = stateProvider.apply
		this.lastResortResultCompletion = determineLastResort
		this.lazyLastResortResultCompletion = determineLazyLastResort
	}

	private def (=>Throwable, CompletableFuture<T>)=>void determineLazyLastResort() {
		if (valueProvider !== null)
			[tp, result|result.complete(valueProvider.apply)]
		else if (exceptionProvider !== null)
			[tp, result|result.completeExceptionally(defaultException)]
		else
			[tp, result|result.completeExceptionally(tp.apply)]
	}

	private def (Throwable, CompletableFuture<T>)=>void determineLastResort() {
		if (valueProvider !== null)
			[t, result|result.complete(valueProvider.apply)]
		else if (exceptionProvider !== null)
			[t, result|result.completeExceptionally(defaultException)]
		else
			[t, result|result.completeExceptionally(t)]
	}

	override withBreaker(()=>CompletableFuture<? extends T> action) {
		withBreaker(breakerExecutor, action)
	}

	override withBreaker(Executor executor, ()=>CompletableFuture<? extends T> action) {
		Objects.requireNonNull(executor)
		Objects.requireNonNull(action);
		applyWithBreaker(executor, action)
	}

	private def applyWithBreaker(Executor executor, ()=>CompletableFuture<? extends T> action) {
		val result = new CompletableFuture<T>
		try {
			executor.execute [
				callActionInit(executor, action, result)
			]
		} catch (RejectedExecutionException ree) {
			// if we cannot event get started because of rejection,
			// we have to complete result immediately based on the error
			lastResortResultCompletion.apply(ree, result)
		}
		result
	}

	/**
	 * Creates the retry strategy for this call and then invokes 
	 * {@link #callAction(Executor,Function0,CompletableFuture,RetryStrategy) callAction}.
	 */
	private def callActionInit(Executor executor, ()=>CompletableFuture<? extends T> action,
		CompletableFuture<T> result) {
		val retryStrategy = strategy.apply;
		// do not even start if circuit is open
		if (!breakerState.isCallPossible(name)) {
			lazyLastResortResultCompletion.apply([new CircuitOpenException], result)
			return
		}
		callAction(executor, action, result, retryStrategy)
	}

	/**
	 * Calls the given action if permitted by {@link #breakerState} and {@code result} was not cancelled.
	 * The future returned by the action will be attached with a retry timeout and callbacks will be 
	 * registered on the future to handle retries and forwarding to {@code result}.
	 * This method has to be called on one of the threads managed by the executor.
	 */
	private def void callAction(Executor executor, ()=>CompletableFuture<? extends T> action,
		CompletableFuture<T> result, extension RetryStrategy retryStrategy) {
		// check if user cancelled from the outside
		if (result.cancelled) {
			// we don't have to do anything if cancelled,
			// since the result already is completed and we
			// cannot really report success or failure to this.breakerState
			return
		}
		// call action
		val fut = try {
			val actFut = action.apply
			// if action result is null we complete with NullPointerException
			// this is somewhat not a regular exception, therefore we don't report
			// an error to this.beakerState
			if (actFut === null) {
				lazyLastResortResultCompletion.apply([new NullPointerException(NULL_FROM_ACTION_MSG)], result)
				return
			}
			actFut
		} catch (Throwable t) {
			// if calling action returns with exception,
			// we treat this as a future that is exceptionally completed
			val error = new CompletableFuture<T>
			error.completeExceptionally(t)
			error
		}
		val futWithTimeout = fut.withRetryTimeout
		// if operation is not already finished and result was cancelled from
		// outside, we forward cancellation from result to operation
		if (!futWithTimeout.done) {
			result.whenCancelledAsync(executor) [|
				// we check agin if fut is not already done, since exception creation is
				// a pretty expensive operation
				if (!futWithTimeout.done) {
					futWithTimeout.completeExceptionally(new CancelledFromOutsideException)
				}
			]
		}
		// react on completion of future returned by action
		futWithTimeout.whenCompleteAsync([ value, ex |
			if (ex !== null) {
				// we have an exception, can we retry?
				tryRetryOnError(ex, executor, action, result, retryStrategy)
			} else {
				// success! we can complete
				result.complete(value)
				// notify breaker state about successful call,
				// e.g. to switch back to closed state
				breakerState.successfulCall(name)
			}
		], executor)
	}

	private def tryRetryOnError(Throwable failure, Executor executor, ()=>CompletableFuture<? extends T> action,
		CompletableFuture<T> result, RetryStrategy retryStrategy) {
		if (failure instanceof CancelledFromOutsideException) {
			// cancelled from outside: no retry and do not report error
			// to this.breakerState
			return
		}

		// let breakerState know that we got a failure
		breakerState.exceptionalCall(failure, name)

		// if no retry compete result based on configuration (e.g. default value)
		// else do retry
		val noRetry = [|
			lastResortResultCompletion.apply(failure, result)
		]

		val doRetry = [|
			// execute retry on executor, since the checkRetry method may
			// invoke callback on other executor.
			try {
				executor.execute [
					// check if circuit is open. In this case do not retry
					if (!breakerState.isCallPossible(name)) {
						lazyLastResortResultCompletion.apply([new CircuitOpenException(failure)], result)
						return
					}
					// do retry
					callAction(executor, action, result, retryStrategy)
				]
			} catch (RejectedExecutionException ree) {
				// if retry was rejected by executor, we abort the retry
				lastResortResultCompletion.apply(ree, result)
			}
		]

		retryStrategy.checkRetry(failure, noRetry, doRetry)
	}

	private def getDefaultException() {
		exceptionProvider.apply ?: new NullPointerException(DEFAULT_EXCEPTION_NULL_MSG)
	}

}
