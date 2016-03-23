package de.fhg.fokus.xtenders.concurrent.circuitbreaker

/**
 * Implementations of this interface hold the state of a {@link CircuitBreaker},
 * which may be closed, open, or half open.<br>
 * Be aware that because of the asynchronous nature of the CircuitBreaker
 * delayed failures or success of operations started in open mode may cause
 * the circuit breaker state in half open to switch to open or closed.<br>
 * This state manifests in the query method {@link #isCallPossible()} that checks
 * if an operation can be executed (e.g. based on a closed or half open circuit).
 * The state is influenced by the two methods {@link #successfulCall()} and 
 * {@link #exceptionalCall(Throwable)} that are used to report if a call was
 * successful or not.<br>
 * The circuit breaker state may be shared between circuit breakers, so all
 * methods may be called asynchronously and in parallel. Implementations of 
 * CircuitBreakerState have to be thread safe and shall not block on any method
 * call.
 */
interface CircuitBreakerState {
	
	/**
	 * Based on the internal state Checks if an operation can be performed.
	 */
	def boolean isCallPossible(String circuitBreakerName)
	
	/**
	 * Reports that a stated call was successful. Based on this feedback,
	 * the {@link #isCallPossible()} may decide to allow future calls or not.
	 */
	def void successfulCall(String circuitBreakerName)
	
	/**
	 * Reports that a stated call was not successful. Based on this feedback,
	 * the {@link #isCallPossible()} may decide to allow future calls or not.
	 */
	def void exceptionalCall(Throwable ex, String circuitBreakerName)
	
}