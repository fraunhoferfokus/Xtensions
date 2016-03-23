package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

/**
 * Can be registered on {@link SimpleCircuitBreakerStateBuilder} and possibly other
 * implementations of CircuitBreaker. An implementation of this interface can be
 * registered to be notified about internal changes of a CircuitBreaker instance.
 * This can e.g. be used for logging purposes.
 */
@SuppressWarnings("all")
public interface CircuitBreakerStateSwitchListener {
  /**
   * Will be called on switch to open state, if registered on CircuitBreakerState (by setting on
   * {@link CircuitBreakerBuilder} and building an instance).
   * @param circuitBreakerState name of circuit breaker state calling this listener
   * @param successfulCircuitBreaker name of circuit breaker reporting the error causing the state to
   *   switch to open mode
   */
  public abstract void onOpen(final String circuitBreakerState, final String successfulCircuitBreaker);
  
  /**
   * Will be called on switch to closed state, if registered on CircuitBreakerState (by setting on
   * {@link CircuitBreakerBuilder} and building an instance).
   * @param circuitBreakerState name of circuit breaker state calling this listener
   * @param successfulCircuitBreaker name of circuit breaker reporting success that
   *   causes switch to closed mode
   */
  public abstract void onClose(final String circuitBreakerState, final String unsuccessfulCircuitBreaker);
  
  /**
   * Will be called on switch to half closed state, if registered on CircuitBreakerState (by setting on
   * {@link CircuitBreakerBuilder} and building an instance).
   * @param circuitBreakerState name of circuit breaker state calling this listener
   * @param successfulCircuitBreaker name of circuit breaker causing switch to half-open mode
   *   by asking if a call is possible.
   */
  public abstract void onHalfOpen(final String circuitBreakerState, final String successfulCircuitBreaker);
}
