package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.RetryStrategy;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.TimeoutStrategy;
import java.util.concurrent.ScheduledExecutorService;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

/**
 * This is the default builder for {@link RetryStrategy}. To create an instance of the
 * builder, call method {@link RetryStrategyBuilder#create() create()}. Then options can be set in a fluent manner.
 * In the end, to actually build the RetryStrategy instance based on the builder configuration
 * call method {@link RetryStrategyBuilder#build() build()}. Defaults are chosen, so that no option
 * actually has to be set before calling the {@code build()} method.<br>
 * Every call to a method changing an option will return a new object containing the current options,
 * but with the option changed. This allows a base configuration be reused in many contexts.
 * <br><br>
 * The current default configuration will never repeat and has no configured timeout.<br>
 * There is no guarantee the default configuration of any option will stay the same in future versions.
 * Therefore all needed configuration should be present in the user configuration code. It is highly
 * advised to configure a backoff strategy for timeouts, if the API used with the circuit breaker does
 * not support timeouts on its own.
 */
@SuppressWarnings("all")
public final class RetryStrategyBuilder implements Cloneable {
  private RetryStrategyBuilder() {
  }
  
  /**
   * Creates a new instance of RetryStrategyBuilder
   * @return new instance of RetryStrategyBuilder
   */
  public static RetryStrategyBuilder create() {
    return new RetryStrategyBuilder();
  }
  
  /**
   * If set, the provider will be used to calculate timeout times. If the property is not set,
   * no timeout will be calculated. It is highly advised to set this option, if API used with
   * the circuit breaker does not support timeouts out of the box.
   */
  public RetryStrategyBuilder timeoutStrategyProvider(final Function0<? extends TimeoutStrategy> backoffStrategyProvider) {
    return this;
  }
  
  /**
   * If this option is set to a positive value, only a maximum number of retries will
   * be performed.<br>
   * The option can be set to {@code maxRetries <= 0} to disable maximum number of retries.<br><br>
   * By default this option is disabled. There is no guarantee the default configuration
   * will stay the same in future versions.
   */
  public RetryStrategyBuilder maxRetries(final int maxRetries) {
    return this;
  }
  
  /**
   * This option sets the ScheduledExecutorService used for scheduling timeouts.
   */
  public RetryStrategyBuilder retryScheduler(final ScheduledExecutorService breakerExecutor) {
    return this;
  }
  
  /**
   * By default the strategy will repeat, no matter which exception caused an action to fail
   * (including timeouts). This can be changed by setting this option to given exception types.
   * If the option is set an action will fail and not repeat by default and only repeat if
   * an exception is instance of one of the given exception classes. However, an action will
   * never be repeated, if an exception is instance of a class configured via
   * {@link #neverRetryOn(Class[]) neverRetryOn(Class...)} (neverRetryOn has precedence over onlyRetryOn).<br>
   * This option can be un-set by calling this method with either an empty array or {@code null}.
   */
  public RetryStrategyBuilder onlyRetryOn(final Class<? extends Throwable>... exceptionTypes) {
    return this;
  }
  
  /**
   * This option configures that action failures of the given exception classes will cause an action
   * to never be repeated.
   * <br>
   * This option will always regarded, no matter if {@link #onlyRetryOn(Class[]) onlyRetryOn(Class...)}
   * is set or not (neverRetryOn has precedence over onlyRetryOn)..<br>
   * This option can be un-set by calling this method with either an empty array or {@code null}.
   */
  public RetryStrategyBuilder neverRetryOn(final Class<? extends Throwable>... exceptionTypes) {
    return this;
  }
  
  /**
   * If set to {@code true}, the complete timeout time will be waited between retries,
   * even if the action fails faster than the given configured timeout.<br>
   * There is no guarantee the default configuration
   * will stay the same in future versions.
   */
  public RetryStrategyBuilder enforceTimeoutAsDelay(final boolean toggle) {
    return this;
  }
  
  /**
   * Creates new instance of {@link RetryStrategy} based on the configuration
   * of this builder.
   */
  public RetryStrategy build() {
    throw new UnsupportedOperationException("Not implemented yet");
  }
  
  @Override
  protected RetryStrategyBuilder clone() throws CloneNotSupportedException {
    Object _clone = super.clone();
    return ((RetryStrategyBuilder) _clone);
  }
}
