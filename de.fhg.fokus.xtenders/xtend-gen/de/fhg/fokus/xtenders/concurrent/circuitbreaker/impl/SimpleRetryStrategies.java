package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.RetryStrategy;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.AlwaysRetryNoTimeoutStrategy;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.NoRetryNoTimeoutStrategy;

/**
 * This class containts fields, holding very simple {@link RetryStrategy}
 * implementations. This class is not intended to be instantiated.
 * @see RetryStrategyBuilder
 */
@SuppressWarnings("all")
public class SimpleRetryStrategies {
  private SimpleRetryStrategies() {
  }
  
  /**
   * Holds an instance of RetryStrategy that will never retry
   * and adds no timeout. The strategy may be shared,
   * since it holds no internal state.
   */
  public final static RetryStrategy NO_RETRY_NO_TIMEOUT_STRATEGY = new NoRetryNoTimeoutStrategy();
  
  /**
   * The held strategy always retries immediately and does not
   * configure any timeouts. The returned strategy may be shared,
   * since it holds no internal state.
   */
  public final static RetryStrategy ALWAYS_RETRY_NO_TIMEOUT_STRATEGY = new AlwaysRetryNoTimeoutStrategy();
}
