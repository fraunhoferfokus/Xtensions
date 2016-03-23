package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import com.google.common.base.Objects;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitBreakerState;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.TimeoutStrategy;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.CircuitBreakerStateBuilder;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.ClosedState;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.ErrorPerTimeChecker;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.ErrorRateChecker;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.ErrorSequnceChecker;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.ErrorStatisticsChecker;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.HalfOpenState;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.OpenState;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.State;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

/**
 * Implementation of CircuitBreakerState created by {@link CircuitBreakerStateBuilder}.
 */
@SuppressWarnings("all")
final class SimpleCircuitBreakerState implements CircuitBreakerState {
  @Extension
  private final CircuitBreakerStateBuilder config;
  
  private final AtomicReference<State> state;
  
  public SimpleCircuitBreakerState(final CircuitBreakerStateBuilder config) {
    this.config = config;
    final ClosedState initialState = this.newClosedState();
    AtomicReference<State> _atomicReference = new AtomicReference<State>(initialState);
    this.state = _atomicReference;
  }
  
  private ClosedState newClosedState() {
    ClosedState _xblockexpression = null;
    {
      final ErrorRateChecker rateChecker = this.createErrorRateChecker();
      final ErrorPerTimeChecker perTimeChecker = this.createPerTimeChecker();
      final ErrorSequnceChecker subsequentChecker = this.createSubsequentChecker();
      final ErrorStatisticsChecker[] checkers = SimpleCircuitBreakerState.filterNull(rateChecker, perTimeChecker, subsequentChecker);
      _xblockexpression = new ClosedState(checkers);
    }
    return _xblockexpression;
  }
  
  private static ErrorStatisticsChecker[] filterNull(final ErrorStatisticsChecker... checkers) {
    ErrorStatisticsChecker[] _xblockexpression = null;
    {
      int count = SimpleCircuitBreakerState.moveNullToEnd(checkers);
      ErrorStatisticsChecker[] result = new ErrorStatisticsChecker[count];
      System.arraycopy(checkers, 0, result, 0, count);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  private static int moveNullToEnd(final ErrorStatisticsChecker[] from) {
    int _xblockexpression = (int) 0;
    {
      int curr = 0;
      for (int i = 0; (i < from.length); i++) {
        {
          final ErrorStatisticsChecker el = from[i];
          boolean _notEquals = (!Objects.equal(el, null));
          if (_notEquals) {
            from[curr] = el;
            curr++;
          }
        }
      }
      _xblockexpression = curr;
    }
    return _xblockexpression;
  }
  
  private ErrorPerTimeChecker createPerTimeChecker() {
    ErrorPerTimeChecker _xifexpression = null;
    boolean _or = false;
    if ((this.config.perTimeInTime == 0)) {
      _or = true;
    } else {
      boolean _equals = Objects.equal(this.config.perTimeTimeUnit, null);
      _or = _equals;
    }
    if (_or) {
      _xifexpression = null;
    } else {
      ErrorPerTimeChecker _xblockexpression = null;
      {
        final long nanoTime = this.config.perTimeTimeUnit.toNanos(this.config.perTimeInTime);
        _xblockexpression = new ErrorPerTimeChecker(this.config.perTimeFailureCount, nanoTime, this.config.timeSupplier);
      }
      _xifexpression = _xblockexpression;
    }
    return _xifexpression;
  }
  
  private ErrorRateChecker createErrorRateChecker() {
    ErrorRateChecker _xifexpression = null;
    if (((this.config.rateFailureCount < 0) || (this.config.rateTotalCount <= 0))) {
      _xifexpression = null;
    } else {
      _xifexpression = new ErrorRateChecker(this.config.rateTotalCount, this.config.rateFailureCount);
    }
    return _xifexpression;
  }
  
  private ErrorSequnceChecker createSubsequentChecker() {
    ErrorSequnceChecker _xifexpression = null;
    if ((this.config.subsequentFailureCount <= 0)) {
      _xifexpression = null;
    } else {
      _xifexpression = new ErrorSequnceChecker(this.config.subsequentFailureCount);
    }
    return _xifexpression;
  }
  
  @Override
  public boolean isCallPossible(final String cbName) {
    boolean _xblockexpression = false;
    {
      final State state = this.checkStateChangeAndGetState(cbName);
      _xblockexpression = state.isCallPossible();
    }
    return _xblockexpression;
  }
  
  private State checkStateChangeAndGetState(final String cbName) {
    State _xblockexpression = null;
    {
      State state = this.state.get();
      State _xifexpression = null;
      if ((state instanceof OpenState)) {
        _xifexpression = this.switchToHalfOpenIfTimeoutReached(((OpenState)state), cbName);
      } else {
        _xifexpression = state;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  private State switchToHalfOpenIfTimeoutReached(final OpenState openState, final String cbName) {
    OpenState oldState = openState;
    long _xtrycatchfinallyexpression = (long) 0;
    try {
      _xtrycatchfinallyexpression = this.config.timeSupplier.getAsLong();
    } catch (final Throwable _t) {
      if (_t instanceof Throwable) {
        final Throwable t = (Throwable)_t;
        _xtrycatchfinallyexpression = System.nanoTime();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    final long currTime = _xtrycatchfinallyexpression;
    while (true) {
      {
        if ((currTime < oldState.targetTime)) {
          return oldState;
        }
        final HalfOpenState newState = new HalfOpenState(oldState.toHalfOpenTimeoutStrategy, oldState.lastTimeout, 
          oldState.lastTimeoutUnit);
        boolean _compareAndSet = this.state.compareAndSet(oldState, newState);
        if (_compareAndSet) {
          this.notifyOnHalfOpen(cbName);
          return newState;
        } else {
          State updatedState = this.state.get();
          if ((updatedState instanceof OpenState)) {
            oldState = ((OpenState)updatedState);
          } else {
            return updatedState;
          }
        }
      }
    }
  }
  
  @Override
  public void successfulCall(final String cbName) {
    State state = this.state.get();
    boolean _matched = false;
    if (!_matched) {
      if (state instanceof ClosedState) {
        _matched=true;
        this.onClosedNotifySuccessfulCall(((ClosedState)state));
      }
    }
    if (!_matched) {
      if (state instanceof HalfOpenState) {
        _matched=true;
        this.onHalfOpenNotifySuccessfulCall(((HalfOpenState)state), cbName);
      }
    }
    if (!_matched) {
      if (state instanceof OpenState) {
        _matched=true;
      }
    }
  }
  
  private void onHalfOpenNotifySuccessfulCall(final HalfOpenState oldState, final String cbName) {
    final ClosedState newState = this.newClosedState();
    boolean _compareAndSet = this.state.compareAndSet(oldState, newState);
    if (_compareAndSet) {
      this.notifyOnClose(cbName);
    }
  }
  
  private void onClosedNotifySuccessfulCall(final ClosedState info) {
    final ErrorStatisticsChecker[] checkers = info.checkers;
    for (int i = 0; (i < checkers.length); i++) {
      ErrorStatisticsChecker _get = checkers[i];
      _get.addSuccess();
    }
  }
  
  @Override
  public void exceptionalCall(final Throwable ex, final String cbName) {
    State state = this.state.get();
    boolean _matched = false;
    if (!_matched) {
      if (state instanceof ClosedState) {
        _matched=true;
        this.onClosedStateNotifyError(((ClosedState)state), ex, cbName);
      }
    }
    if (!_matched) {
      if (state instanceof HalfOpenState) {
        _matched=true;
        this.onHalfOpenNotifyError(((HalfOpenState)state), ex, cbName);
      }
    }
    if (!_matched) {
      if (state instanceof OpenState) {
        _matched=true;
      }
    }
  }
  
  private void onClosedStateNotifyError(final ClosedState state, final Throwable throwable, final String cbName) {
    boolean _isRecordable = this.isRecordable(throwable);
    boolean _not = (!_isRecordable);
    if (_not) {
      return;
    }
    final ErrorStatisticsChecker[] checkers = state.checkers;
    boolean trip = false;
    for (int i = 0; ((i < checkers.length) && (!trip)); i++) {
      boolean _or = false;
      if (trip) {
        _or = true;
      } else {
        ErrorStatisticsChecker _get = checkers[i];
        boolean _addErrorAndCheck = _get.addErrorAndCheck();
        boolean _not_1 = (!_addErrorAndCheck);
        _or = _not_1;
      }
      trip = _or;
    }
    if (trip) {
      this.switchToOpenState(cbName);
    }
  }
  
  private <U extends Object> U recoverWith(final Function0<? extends U> action, final Function0<? extends U> recovery) {
    U _xtrycatchfinallyexpression = null;
    try {
      U _xblockexpression = null;
      {
        final U result = action.apply();
        U _xifexpression = null;
        boolean _notEquals = (!Objects.equal(result, null));
        if (_notEquals) {
          _xifexpression = result;
        } else {
          _xifexpression = recovery.apply();
        }
        _xblockexpression = _xifexpression;
      }
      _xtrycatchfinallyexpression = _xblockexpression;
    } catch (final Throwable _t) {
      if (_t instanceof Throwable) {
        final Throwable t = (Throwable)_t;
        _xtrycatchfinallyexpression = recovery.apply();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return _xtrycatchfinallyexpression;
  }
  
  /**
   * Always switches to open state (no matter the previous state)
   */
  private void switchToOpenState(final String cbName) {
    final TimeoutStrategy toHalfOpenStrategy = this.<TimeoutStrategy>recoverWith(this.config.toHalfOpenStrategyProvider, 
      CircuitBreakerStateBuilder.DEFAULT_HALF_OPEN_TIME);
    this.switchToOpenState(cbName, toHalfOpenStrategy, 0, TimeUnit.NANOSECONDS);
  }
  
  /**
   * Always switches to open state (no matter the previous state)
   */
  private void switchToOpenState(final String cbName, final TimeoutStrategy toHalfOpenStrategy, final long lastTimeout, final TimeUnit lastTimeoutUnit) {
    try {
      this.switchToOpenState(toHalfOpenStrategy, cbName, lastTimeout, lastTimeoutUnit);
    } catch (final Throwable _t) {
      if (_t instanceof Throwable) {
        final Throwable t = (Throwable)_t;
        final TimeoutStrategy defaultTimeout = CircuitBreakerStateBuilder.DEFAULT_HALF_OPEN_TIME.apply();
        this.switchToOpenState(defaultTimeout, cbName, lastTimeout, lastTimeoutUnit);
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
  
  /**
   * Always switches to open state (no matter the previous state)
   */
  private void switchToOpenState(final TimeoutStrategy toHalfOpenStrategy, final String cbName, final long lastTimeout, final TimeUnit lastTimeoutUnit) {
    final TimeoutStrategy.TimeConsumer _function = (long time, TimeUnit unit) -> {
      long _xtrycatchfinallyexpression = (long) 0;
      try {
        _xtrycatchfinallyexpression = this.config.timeSupplier.getAsLong();
      } catch (final Throwable _t) {
        if (_t instanceof Throwable) {
          final Throwable t = (Throwable)_t;
          _xtrycatchfinallyexpression = System.nanoTime();
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
      final long currTime = _xtrycatchfinallyexpression;
      long _nanos = unit.toNanos(time);
      final long targetTime = (currTime + _nanos);
      final OpenState newState = new OpenState(toHalfOpenStrategy, targetTime, time, unit);
      this.state.set(newState);
      this.notifyOnOpen(cbName);
    };
    toHalfOpenStrategy.next(lastTimeout, lastTimeoutUnit, _function);
  }
  
  private void onHalfOpenNotifyError(final HalfOpenState state, final Throwable throwable, final String cbName) {
    boolean _isRecordable = this.isRecordable(throwable);
    boolean _not = (!_isRecordable);
    if (_not) {
      return;
    }
    this.switchToOpenState(cbName, state.toHalfOpenTimeoutStrategy, state.lastTimeout, state.lastTimeoutUnit);
  }
  
  private boolean isRecordable(final Throwable t) {
    boolean _xblockexpression = false;
    {
      boolean _notEquals = (!Objects.equal(this.config.neverRecord, null));
      if (_notEquals) {
        for (int i = 0; (i < this.config.neverRecord.length); i++) {
          Class<? extends Throwable> _get = this.config.neverRecord[i];
          boolean _isInstance = _get.isInstance(t);
          if (_isInstance) {
            return false;
          }
        }
      }
      boolean _notEquals_1 = (!Objects.equal(this.config.onlyRecord, null));
      if (_notEquals_1) {
        for (int i = 0; (i < this.config.onlyRecord.length); i++) {
          Class<? extends Throwable> _get = this.config.onlyRecord[i];
          boolean _isInstance = _get.isInstance(t);
          if (_isInstance) {
            return true;
          }
        }
        return false;
      }
      _xblockexpression = true;
    }
    return _xblockexpression;
  }
  
  private void notifyOnOpen(final String cbName) {
    boolean _notEquals = (!Objects.equal(this.config.listener, null));
    if (_notEquals) {
      try {
        final Runnable _function = () -> {
          this.config.listener.onOpen(this.config.name, cbName);
        };
        this.config.listenerExecutor.execute(_function);
      } catch (final Throwable _t) {
        if (_t instanceof RejectedExecutionException) {
          final RejectedExecutionException t = (RejectedExecutionException)_t;
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
    }
  }
  
  private void notifyOnClose(final String cbName) {
    boolean _notEquals = (!Objects.equal(this.config.listener, null));
    if (_notEquals) {
      try {
        final Runnable _function = () -> {
          this.config.listener.onClose(this.config.name, cbName);
        };
        this.config.listenerExecutor.execute(_function);
      } catch (final Throwable _t) {
        if (_t instanceof RejectedExecutionException) {
          final RejectedExecutionException t = (RejectedExecutionException)_t;
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
    }
  }
  
  private void notifyOnHalfOpen(final String cbName) {
    boolean _notEquals = (!Objects.equal(this.config.listener, null));
    if (_notEquals) {
      try {
        final Runnable _function = () -> {
          this.config.listener.onHalfOpen(this.config.name, cbName);
        };
        this.config.listenerExecutor.execute(_function);
      } catch (final Throwable _t) {
        if (_t instanceof RejectedExecutionException) {
          final RejectedExecutionException t = (RejectedExecutionException)_t;
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
    }
  }
}
