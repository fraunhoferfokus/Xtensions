package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import com.google.common.base.Objects;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitBreakerState;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.TimeoutStrategy;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.CircuitBreakerStateSwitchListener;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.SimpleCircuitBreakerState;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.TimeoutStrategies;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Executor;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.function.Consumer;
import java.util.function.LongSupplier;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

/**
 * This builder class can be used to create a basic implementation of a
 * {@link CircuitBreakerState} based on the configuration of this builder.
 * The implemented state is completely non-blocking at the expense of creating
 * some garbage during operation.
 */
@SuppressWarnings("all")
public final class CircuitBreakerStateBuilder implements Cloneable {
  final static Function0<? extends TimeoutStrategy> DEFAULT_HALF_OPEN_TIME = ((Function0<TimeoutStrategy>) () -> {
    return TimeoutStrategies.fixedTimeout(30, TimeUnit.SECONDS);
  });
  
  final static LongSupplier DEFAULT_TIME_SUPPLIER = ((LongSupplier) () -> {
    return System.nanoTime();
  });
  
  LongSupplier timeSupplier = CircuitBreakerStateBuilder.DEFAULT_TIME_SUPPLIER;
  
  int subsequentFailureCount = 5;
  
  int rateFailureCount = 0;
  
  int rateTotalCount = 0;
  
  int perTimeFailureCount = (-1);
  
  long perTimeInTime = 0;
  
  TimeUnit perTimeTimeUnit = null;
  
  Class<? extends Throwable>[] neverRecord = null;
  
  Class<? extends Throwable>[] onlyRecord = null;
  
  Function0<? extends TimeoutStrategy> toHalfOpenStrategyProvider = CircuitBreakerStateBuilder.DEFAULT_HALF_OPEN_TIME;
  
  CircuitBreakerStateSwitchListener listener = null;
  
  Executor listenerExecutor = ForkJoinPool.commonPool();
  
  String name = null;
  
  private CircuitBreakerStateBuilder() {
  }
  
  /**
   * Creates new new instance of CircuitBreakerStateBuilder.
   */
  public static CircuitBreakerStateBuilder create() {
    return new CircuitBreakerStateBuilder();
  }
  
  /**
   * Sets the name of the circuit breaker state. If not set a random
   * UUID will be generated as name. If set to {@code null}, also a
   * UUID will be used.<br>
   * The name will be passed to listener on state change (see {@link #listener(CircuitBreakerStateSwitchListener)})
   * @param name of the circuit breaker. If called with {@code null} a default name
   *  will be selected
   * @return new CircuitBreakerStateBuilder with changed option
   */
  public CircuitBreakerStateBuilder name(final String name) {
    try {
      CircuitBreakerStateBuilder _xblockexpression = null;
      {
        final CircuitBreakerStateBuilder result = this.clone();
        result.name = name;
        _xblockexpression = result;
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  /**
   * This method sets the time provider that is used to check for timeouts. This
   * is especially useful when testing timing issues.<br>
   * The default provider uses {@link System#nanoTime()}. To reset to the default
   * provider, call with {@code nanoTimeProvider = null}.
   * @param nanoTimeProvider function providing the current system time. If {@code null}
   *   the default time provider will be used.
   * @return new CircuitBreakerStateBuilder with changed option
   */
  public CircuitBreakerStateBuilder nanoTimeProvider(final LongSupplier nanoTimeProvider) {
    try {
      CircuitBreakerStateBuilder _xblockexpression = null;
      {
        final CircuitBreakerStateBuilder result = this.clone();
        LongSupplier _xifexpression = null;
        boolean _equals = Objects.equal(nanoTimeProvider, null);
        if (_equals) {
          _xifexpression = CircuitBreakerStateBuilder.DEFAULT_TIME_SUPPLIER;
        } else {
          _xifexpression = nanoTimeProvider;
        }
        result.timeSupplier = _xifexpression;
        _xblockexpression = result;
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  /**
   * Sets the count of consecutive errors that will cause the state to switch to open state.<br>
   * If this option is enabled with other  opening criteria, the state will switch to open
   * if <em>any</em> of the criteria matches.<br>
   * If {@code count = 0} the option will be disabled.<br>
   * Default value: 5
   * @param count maximum allowed number or consecutive errors to occur. Must be {@code >=0}.
   *  If set to {@code = 0} the option will be disabled.
   * @return new CircuitBreakerStateBuilder with changed option
   * 
   * @see #openOnFailureRate(int, int)
   * @see #openOnFailureCountInTime(int, long, TimeUnit)
   */
  public CircuitBreakerStateBuilder openOnSubsequentFailureCount(final int count) {
    try {
      CircuitBreakerStateBuilder _xblockexpression = null;
      {
        if ((count < 0)) {
          throw new IllegalArgumentException("Subsequent error count must be >= 0");
        }
        final CircuitBreakerStateBuilder result = this.clone();
        result.subsequentFailureCount = count;
        _xblockexpression = result;
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  /**
   * When the given rate of failures ({@code failureCount} errors in the last
   * {@code totalCount} operations) is reached in the built CircuitBreakerState,
   * the state will switch to open, not permitting further operations to be carried out.<br>
   * If this option is enabled with other opening criteria, the state will switch
   * to open if <em>any</em> of the criteria matches.<br>
   * To disable this option, call with {@code totalCount = 0}<br>
   * By default no failure rate configured.
   * @param failureCount amount of failures in {@code totalCount} of last reported
   *   ended operations (success and failure) that will cause the circuit to open.
   *   Must be {@code > 0}.
   * @param totalCount amount of last operation outcomes that will be recorded to
   *   check for {@code failureCount} errors. Must be {@code >= 0}. If is 0, the
   *   option will be disabled.
   * @throws IllegalArgumentException if the precondition of any parameter is violated.
   * 
   * @see #openOnSubsequentFailureCount(int)
   * @see #openOnFailureCountInTime(int, long, TimeUnit)
   */
  public CircuitBreakerStateBuilder openOnFailureRate(final int failureCount, final int totalCount) {
    try {
      CircuitBreakerStateBuilder _xblockexpression = null;
      {
        if ((failureCount <= 0)) {
          throw new IllegalArgumentException("failureCount must be greater than 0.");
        }
        if ((totalCount < 0)) {
          throw new IllegalArgumentException("failureCount must be greater than or equal to 0.");
        }
        final CircuitBreakerStateBuilder result = this.clone();
        result.rateFailureCount = failureCount;
        result.rateTotalCount = totalCount;
        _xblockexpression = result;
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  /**
   * Configures that closed state switches to open, when in time interval {@code time} of
   * {@code unit} more than {@code failureCount} errors occur.
   * Internally the state will calculate in nanoseconds, so any configured time exceeding
   * {@link Long#MAX_VALUE} nanoseconds (around 292.5 years) will be limited to {@code MAX_VALUE} nanoseconds.<br>
   * If this option is enabled with other opening criteria,
   * the state will switch to open if <em>any</em> of the criteria matches.<br><br>
   * By default, no failure count in time is configured. To disable the option, call with
   * {@code failureCount = 0} or {@code time = 0} or {@code unit = null}.
   * @param failureCount the maximum allowed count of errors to occur in a time-slice
   *   of length of {@code time} in {@code unit}. Must be {@code >= 0}. If {@code = 0}
   *   the option will be disabled.
   * @param time length of time slice in {@code unit} in which errors are counted.
   *   Must be {@code >= 0}. If {@code = 0} the option will be disabled.
   * @param unit time unit of time slice of size {@code time}. If {@code = null} the
   *   option will be disabled.
   * @throws IllegalArgumentException if any of the preconditions are not met.
   * 
   * @see #openOnFailureRate(int, int)
   * @see #openOnSubsequentFailureCount(int)
   */
  public CircuitBreakerStateBuilder openOnFailureCountInTime(final int failureCount, final long time, final TimeUnit unit) {
    try {
      CircuitBreakerStateBuilder _xblockexpression = null;
      {
        if ((time < 0)) {
          throw new IllegalArgumentException("time must be greater than or equal to 0.");
        }
        if ((failureCount < 0)) {
          throw new IllegalArgumentException("failureCount must be greater than or equal to 0.");
        }
        final CircuitBreakerStateBuilder result = this.clone();
        result.perTimeFailureCount = failureCount;
        result.perTimeInTime = time;
        result.perTimeTimeUnit = unit;
        _xblockexpression = result;
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  /**
   * If this option is set exceptions instance of the given classes are never regarded for
   * calculation if the circuit state should switch to open state. This option can be disabled
   * by calling this method with either an empty array or {@code null}.<br>
   * This option will always regarded, no matter if {@link #onlyRecord(Class[]) onlyRecord(Class...)}
   * is set or not (neverRecord has precedence over onlyRecord).
   * <br><br>
   * No default values set.
   * @param classes if not {@code null} then declares the classes of {@code Throwable}s that are never
   *   regarded as errors and never lead to the state to switch to open mode. No class on the array
   *   is allowed to be {@code null}. If the array reference itself is {@code null} the option will
   *   be disabled.
   * @return new CircuitBreakerStateBuilder with changed option
   * @throws IllegalArgumentException if any of the given classes is {@code null}
   */
  public CircuitBreakerStateBuilder neverRecord(final Class<? extends Throwable>... classes) throws IllegalArgumentException {
    try {
      CircuitBreakerStateBuilder _xblockexpression = null;
      {
        boolean _notEquals = (!Objects.equal(classes, null));
        if (_notEquals) {
          final Consumer<Class<? extends Throwable>> _function = (Class<? extends Throwable> it) -> {
            boolean _equals = Objects.equal(it, null);
            if (_equals) {
              throw new IllegalArgumentException("Null is not allowed as class");
            }
          };
          ((List<Class<? extends Throwable>>)Conversions.doWrapArray(classes)).forEach(_function);
        }
        final CircuitBreakerStateBuilder result = this.clone();
        result.neverRecord = classes;
        _xblockexpression = result;
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  /**
   * When this option is set, the default behavior where all exceptions are used to
   * calculate if the. This option can be disabled by calling this method with either
   * an empty array or {@code null}.<br>
   * If an exception is instance of a class set via {@link #neverRecord(Class[]) neverRecord(Class...)}, the
   * exception will not recorded though (neverRecord has precedence over onlyRecord).
   * <br><br>
   * No default values set.
   * @param classes if not {@code null} then declares the classes of {@code Throwable}s that are the only ones
   *   regarded as errors allow the mode to switch to open mode. No other classes will be regarded as errors.
   *   No class in the array is allowed to be {@code null}. If the array reference itself is {@code null}
   *   the option will be disabled.
   * @return new CircuitBreakerStateBuilder with changed option
   * @throws IllegalArgumentException if any of the given classes is {@code null}
   */
  public CircuitBreakerStateBuilder onlyRecord(final Class<? extends Throwable>... classes) {
    try {
      CircuitBreakerStateBuilder _xblockexpression = null;
      {
        boolean _notEquals = (!Objects.equal(classes, null));
        if (_notEquals) {
          final Consumer<Class<? extends Throwable>> _function = (Class<? extends Throwable> it) -> {
            boolean _equals = Objects.equal(it, null);
            if (_equals) {
              throw new IllegalArgumentException("Null is not allowed as class");
            }
          };
          ((List<Class<? extends Throwable>>)Conversions.doWrapArray(classes)).forEach(_function);
        }
        final CircuitBreakerStateBuilder result = this.clone();
        Class<? extends Throwable>[] _xifexpression = null;
        int _length = classes.length;
        boolean _equals = (_length == 0);
        if (_equals) {
          _xifexpression = null;
        } else {
          _xifexpression = classes;
        }
        result.onlyRecord = _xifexpression;
        _xblockexpression = result;
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  /**
   * Defines the strategy to .Must not be called with {@code null}.
   * The strategy will be called again to provide
   * new timeout, if the state switches back from half open to open state. This way the
   * time from open to half open can increase when it flips back from half open to open
   * multiple times. Be aware that timeouts in the CircuitBreakerState implementation
   * is tracked internally in nanoseconds, so all defined timeouts are limited to
   * {@link Long#MAX_VALUE} nanoseconds, no matter if the TimeoutStrategy defines a longer
   * timeout in a different time unit.
   * <br><br>
   * By default uses a fixed timeout of 30 seconds. Be aware that the default may change
   * and it is advised to always set this option.
   * @param toHalfOpenStrategyProvider provider of strategy of timeout, when open circuit
   *  should switch to half open state. The same strategy is used until the circuit switches
   *  back to closed state. Must <em>not</em> be {@code null}.
   * @return new CircuitBreakerStateBuilder with changed option
   * @throws NullPointerException if {@code toHalfOpenStrategyProvider} is {@code null}
   * @see TimeoutStrategies
   */
  public CircuitBreakerStateBuilder toHalfOpenPeriod(final Function0<? extends TimeoutStrategy> toHalfOpenStrategyProvider) {
    try {
      CircuitBreakerStateBuilder _xblockexpression = null;
      {
        java.util.Objects.<Function0<? extends TimeoutStrategy>>requireNonNull(toHalfOpenStrategyProvider);
        final CircuitBreakerStateBuilder result = this.clone();
        result.toHalfOpenStrategyProvider = toHalfOpenStrategyProvider;
        _xblockexpression = result;
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  /**
   * Sets the executor that will be used to run the calls to the listener ({@link #listener(CircuitBreakerStateSwitchListener)}
   * by the created CircuitBreaker builder.
   * If called with {@code listenerExecutor = null} option will be
   * reset to its default value. If the executor rejects the action to call the listener with a
   * {@link RejectedExecutionException} the notification to the listener will be lost.<br>
   * By default the listeners will be run on the {@link ForkJoinPool#commonPool() common ForkJoinPool}.
   * @param listenerExecutor executor used to invoke the calls to listener. Can be {@code null}, in this
   *  case the default executor will be selected.
   * @return new CircuitBreakerStateBuilder with changed option
   * @see #listener(CircuitBreakerStateSwitchListener)
   */
  public CircuitBreakerStateBuilder listenerExecutor(final Executor listenerExecutor) {
    try {
      CircuitBreakerStateBuilder _xblockexpression = null;
      {
        final CircuitBreakerStateBuilder result = this.clone();
        Executor _xifexpression = null;
        boolean _equals = Objects.equal(listenerExecutor, null);
        if (_equals) {
          _xifexpression = ForkJoinPool.commonPool();
        } else {
          _xifexpression = listenerExecutor;
        }
        result.listenerExecutor = _xifexpression;
        _xblockexpression = result;
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  /**
   * Only a single listener is supported, so calling this method again will
   * overwrite the previously set listener. If multiple listeners are desired,
   * the user has to implement a compound listener himself/herself.<br><br>
   * By default no listener is configured. To reset this option, call with {@code listener = null}.
   * @param listener Will be called whenever the internal state of the circuit breaker changes.
   *    Can be {@code null}, in this case the listener will be disabled.
   * @return new CircuitBreakerStateBuilder with changed option
   * @see #listener(CircuitBreakerStateSwitchListener)
   */
  public CircuitBreakerStateBuilder listener(final CircuitBreakerStateSwitchListener listener) {
    try {
      CircuitBreakerStateBuilder _xblockexpression = null;
      {
        final CircuitBreakerStateBuilder result = this.clone();
        result.listener = listener;
        _xblockexpression = result;
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  /**
   * Creates an instance of {@link CircuitBreakerState} based on the
   * configuration of this builder.
   * @return new instance of {@link CircuitBreakerState} according to the
   *   configuration of this builder.
   */
  public CircuitBreakerState build() {
    try {
      SimpleCircuitBreakerState _xblockexpression = null;
      {
        final CircuitBreakerStateBuilder conf = this.clone();
        boolean _equals = Objects.equal(conf.name, null);
        if (_equals) {
          UUID _randomUUID = UUID.randomUUID();
          String _string = _randomUUID.toString();
          conf.name = _string;
        }
        _xblockexpression = new SimpleCircuitBreakerState(conf);
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  @Override
  protected CircuitBreakerStateBuilder clone() throws CloneNotSupportedException {
    Object _clone = super.clone();
    return ((CircuitBreakerStateBuilder) _clone);
  }
}
