package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitBreaker;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitBreakerState;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.RetryStrategy;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.CircuitBreakerStateBuilder;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.RetryStrategyBuilder;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.SimpleCircuitBreaker;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.SimpleRetryStrategies;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.Executor;
import java.util.concurrent.ForkJoinPool;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

/**
 * Builder for a default implementation of {@link CircuitBreaker}.<br>
 * Every method call of this class creates a new object, so that every step can be
 * used as a snapshot and used for different configurations based on the
 * previous one. This makes the class effectively immutable.
 * However, this does imply that the class is thread safe.
 */
@SuppressWarnings("all")
public final class CircuitBreakerBuilder<T extends Object> implements Cloneable {
  private CircuitBreakerBuilder() {
  }
  
  String name = null;
  
  Function0<? extends CircuitBreakerState> stateProvider = null;
  
  Function0<? extends T> valueProvider = null;
  
  Function0<? extends RetryStrategy> strategy = ((Function0<RetryStrategy>) () -> {
    return SimpleRetryStrategies.NO_RETRY_NO_TIMEOUT_STRATEGY;
  });
  
  Executor breakerExecutor = null;
  
  Function0<? extends Throwable> exceptionProvider = null;
  
  public static <T extends Object> CircuitBreakerBuilder<T> create() {
    return new CircuitBreakerBuilder<T>();
  }
  
  /**
   * Sets the name of the circuit breaker that is passed on to
   * the circuit breaker state.
   * By default and if {@code null} is chosen as name,
   * a random UUID will be assigned to the name when building
   * the CircuitBreaker.
   */
  public CircuitBreakerBuilder<T> name(final String name) {
    CircuitBreakerBuilder<T> _xblockexpression = null;
    {
      final CircuitBreakerBuilder<T> result = this.clone();
      result.name = name;
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * If this value is not set, the a default provider will be chosen based on the
   * default configuration of {@link SimpleCircuitBreakerStateBuilder}.
   * @see CircuitBreakerStateBuilder
   */
  public CircuitBreakerBuilder<T> stateProvider(final Function0<? extends CircuitBreakerState> stateProvider) {
    CircuitBreakerBuilder<T> _xblockexpression = null;
    {
      Objects.<Function0<? extends CircuitBreakerState>>requireNonNull(stateProvider);
      final CircuitBreakerBuilder<T> result = this.clone();
      result.stateProvider = stateProvider;
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * The provider should return a new strategy instance on each call. Attention:
   * if no retry strategy is provided by the user a default one is selected. This
   * will be {@link SimpleRetryStrategies#NO_RETRY_NO_TIMEOUT_STRATEGY}.
   * @see RetryStrategyBuilder
   * @see SimpleRetryStrategies
   * @throws
   */
  public CircuitBreakerBuilder<T> retryStrategyProvider(final Function0<? extends RetryStrategy> strategyProvider) throws NullPointerException {
    CircuitBreakerBuilder<T> _xblockexpression = null;
    {
      Objects.<Function0<? extends RetryStrategy>>requireNonNull(strategyProvider);
      final CircuitBreakerBuilder<T> result = this.clone();
      result.strategy = strategyProvider;
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * All logic of the created circuit breaker will run on the given executor.
   * By default this option is set to the common ForkJoinPool.
   * @see java.util.concurrent.Executors
   */
  public CircuitBreakerBuilder<T> breakerExecutor(final Executor breakerExecutor) {
    CircuitBreakerBuilder<T> _xblockexpression = null;
    {
      final CircuitBreakerBuilder<T> result = this.clone();
      result.breakerExecutor = breakerExecutor;
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * If this option is set, if an option fails, despite retries, the given
   * {@code valueProvider} will be used to return a default result.<br>
   * By default no value provider will be set. If this is set, it will shadow any
   * previously set {@link #noValueExceptionProvider(Function0) noValueExceptionProvider}.
   * 
   * @see #noValueExceptionProvider(Function0)
   */
  public CircuitBreakerBuilder<T> defaultValueProvider(final Function0<? extends T> valueProvider) {
    CircuitBreakerBuilder<T> _xblockexpression = null;
    {
      Objects.<Function0<? extends T>>requireNonNull(valueProvider);
      final CircuitBreakerBuilder<T> result = this.clone();
      result.valueProvider = valueProvider;
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * if {@link #defaultValueProvider(Function0) defaultValue} is set, the {@link exceptionProvider}
   * will never be used. This option can be un-set by calling this method with {@code null}.
   * 
   * @see #defaultValueProvider(Function0)
   */
  public CircuitBreakerBuilder<T> defaultExceptionProvider(final Function0<? extends Throwable> exceptionProvider) {
    CircuitBreakerBuilder<T> _xblockexpression = null;
    {
      Objects.<Function0<? extends Throwable>>requireNonNull(exceptionProvider);
      final CircuitBreakerBuilder<T> result = this.clone();
      result.exceptionProvider = exceptionProvider;
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * Creates a new instance of {@link CircuitBreaker} based on the configuration
   * of this builder.
   */
  public CircuitBreaker<T> build() throws IllegalStateException {
    SimpleCircuitBreaker<T> _xblockexpression = null;
    {
      final CircuitBreakerBuilder<T> builder = this.selfWithDefaults();
      _xblockexpression = new SimpleCircuitBreaker<T>(builder);
    }
    return _xblockexpression;
  }
  
  private CircuitBreakerBuilder<T> selfWithDefaults() {
    CircuitBreakerBuilder<T> _xblockexpression = null;
    {
      final CircuitBreakerBuilder<T> result = this.clone();
      boolean _equals = com.google.common.base.Objects.equal(result.name, null);
      if (_equals) {
        UUID _randomUUID = UUID.randomUUID();
        String _string = _randomUUID.toString();
        result.name = _string;
      }
      boolean _equals_1 = com.google.common.base.Objects.equal(result.breakerExecutor, null);
      if (_equals_1) {
        ForkJoinPool _commonPool = ForkJoinPool.commonPool();
        result.breakerExecutor = _commonPool;
      }
      boolean _equals_2 = com.google.common.base.Objects.equal(result.stateProvider, null);
      if (_equals_2) {
        final CircuitBreakerStateBuilder stateBuilder = CircuitBreakerStateBuilder.create();
        final Function0<CircuitBreakerState> _function = () -> {
          return stateBuilder.build();
        };
        result.stateProvider = _function;
      }
      boolean _equals_3 = com.google.common.base.Objects.equal(result.strategy, null);
      if (_equals_3) {
        final RetryStrategyBuilder strategyBuilder = RetryStrategyBuilder.create();
        final Function0<RetryStrategy> _function_1 = () -> {
          return strategyBuilder.build();
        };
        result.strategy = _function_1;
      }
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  @Override
  protected CircuitBreakerBuilder<T> clone() {
    try {
      Object _clone = super.clone();
      return ((CircuitBreakerBuilder<T>) _clone);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
