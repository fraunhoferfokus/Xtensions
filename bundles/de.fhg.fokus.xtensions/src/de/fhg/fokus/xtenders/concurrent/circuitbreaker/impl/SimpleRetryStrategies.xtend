package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.RetryStrategy
import java.util.concurrent.CompletableFuture

/**
 * This class containts fields, holding very simple {@link RetryStrategy}
 * implementations. This class is not intended to be instantiated.
 * @see RetryStrategyBuilder 
 */
class SimpleRetryStrategies {
	
	private new(){}
	
	/**
	 * Holds an instance of RetryStrategy that will never retry
	 * and adds no timeout. The strategy may be shared,
	 * since it holds no internal state.
	 */
	public static val RetryStrategy NO_RETRY_NO_TIMEOUT_STRATEGY = new NoRetryNoTimeoutStrategy()
	
	/**
	 * The held strategy always retries immediately and does not 
	 * configure any timeouts. The returned strategy may be shared,
	 * since it holds no internal state.
	 */
	public static val RetryStrategy ALWAYS_RETRY_NO_TIMEOUT_STRATEGY = new AlwaysRetryNoTimeoutStrategy()
	
}

/**
 * Never retrying strategy that configures no timeout
 */
package class NoRetryNoTimeoutStrategy implements RetryStrategy {
	
	override <T> withRetryTimeout(CompletableFuture<T> fut) {
		// Nothing to do, no retry
		fut
	}
	
	override checkRetry(Throwable lastFailure, ()=>void noRetry, ()=>void doRetry) {
		// never retry
		noRetry.apply
	}
	
}

/**
 * Always immediately retrying strategy that configures no timeout
 */
package class AlwaysRetryNoTimeoutStrategy implements RetryStrategy {
	
	override <T> withRetryTimeout(CompletableFuture<T> fut) {
		// Nothing to do, no retry
		fut
	}
	
	override checkRetry(Throwable lastFailure, ()=>void noRetry, ()=>void doRetry) {
		// always retry
		doRetry.apply
	}
	
}