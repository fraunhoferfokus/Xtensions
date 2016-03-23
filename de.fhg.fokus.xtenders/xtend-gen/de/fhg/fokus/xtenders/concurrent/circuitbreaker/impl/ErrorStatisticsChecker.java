package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

/**
 * Records success and error and checks if an error causes the statistics
 * to meet a tripping threshold. This can be used by CircuitBreakerState implementations,
 * to check weather to switch to an open state or not.
 * Implementations of this interface must be thread safe.
 */
@SuppressWarnings("all")
interface ErrorStatisticsChecker {
  /**
   * Returns {@code true} if the error threshold is not reached
   * and further operations are allowed. If {@code false} is returned
   * the maximum allowed error count is reached and the current instance
   * should not be used anymore.
   * @returns {@code true} if the allowed threshold of errors is not reached yet,
   *   {@code false} otherwise
   */
  public abstract boolean addErrorAndCheck();
  
  /**
   * Records a successful operation
   */
  public abstract void addSuccess();
}
