package de.fhg.fokus.xtenders.concurrent.circuitbreaker;

import java.util.concurrent.CancellationException;
import java.util.concurrent.TimeUnit;

/**
 * If an Action used with a {@link CircuitBreaker} fails because of a configured timeout,
 * the action should be canceled using this exception class.
 */
@SuppressWarnings("all")
public final class CancellationByTimeoutException extends CancellationException {
  private final long timeout;
  
  private final TimeUnit timeoutTimeUnit;
  
  /**
   * Passes the timeout time and time unit that passed, so that an action was
   * timed out and cancelled using the created CancellationByTimeoutException.
   */
  public CancellationByTimeoutException(final long timeout, final TimeUnit timeUnit) {
    this.timeout = timeout;
    this.timeoutTimeUnit = timeUnit;
  }
  
  /**
   * Time passed until action timed out. This is the scalar value
   * of time, the time unit can be obtained using {@link #getTimeoutTimeUnit()}
   */
  public long getTimeout() {
    return this.timeout;
  }
  
  /**
   * The TimeUnit of the {@link #getTimeout() timeout}.
   */
  public TimeUnit getTimeoutTimeUnit() {
    return this.timeoutTimeUnit;
  }
}
