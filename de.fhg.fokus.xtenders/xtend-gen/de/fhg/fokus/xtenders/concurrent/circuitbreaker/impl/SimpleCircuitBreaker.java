package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import com.google.common.base.Objects;
import de.fhg.fokus.xtenders.concurrent.CompletableFutureExtensions;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitBreaker;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitBreakerState;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitOpenException;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.RetryStrategy;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.CancelledFromOutsideException;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.CircuitBreakerBuilder;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.concurrent.RejectedExecutionException;
import java.util.function.BiConsumer;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure2;

/**
 * Default implementation of CircuitBreaker that is created using the
 * {@link CircuitBreakerBuilder}
 */
@SuppressWarnings("all")
final class SimpleCircuitBreaker<T extends Object> implements CircuitBreaker<T> {
  private final static String NULL_FROM_ACTION_MSG = "Action returned null instead of CompletableFuture";
  
  private final static String DEFAULT_EXCEPTION_NULL_MSG = "Default exception was null";
  
  @Extension
  private final CircuitBreakerBuilder<T> config;
  
  /**
   * Internal state, checking if calls are allowed or not,
   * based on success and error statistics.
   */
  private final CircuitBreakerState breakerState;
  
  private final Procedure2<? super Throwable, ? super CompletableFuture<T>> lastResortResultCompletion;
  
  private final Procedure2<? super Function0<? extends Throwable>, ? super CompletableFuture<T>> lazyLastResortResultCompletion;
  
  SimpleCircuitBreaker(final CircuitBreakerBuilder<T> builder) {
    this.config = builder;
    CircuitBreakerState _apply = this.config.stateProvider.apply();
    this.breakerState = _apply;
    Procedure2<? super Throwable, ? super CompletableFuture<T>> _determineLastResort = this.determineLastResort();
    this.lastResortResultCompletion = _determineLastResort;
    Procedure2<? super Function0<? extends Throwable>, ? super CompletableFuture<T>> _determineLazyLastResort = this.determineLazyLastResort();
    this.lazyLastResortResultCompletion = _determineLazyLastResort;
  }
  
  private Procedure2<? super Function0<? extends Throwable>, ? super CompletableFuture<T>> determineLazyLastResort() {
    Procedure2<Function0<? extends Throwable>, CompletableFuture<T>> _xifexpression = null;
    boolean _notEquals = (!Objects.equal(this.config.valueProvider, null));
    if (_notEquals) {
      final Procedure2<Function0<? extends Throwable>, CompletableFuture<T>> _function = (Function0<? extends Throwable> tp, CompletableFuture<T> result) -> {
        T _apply = this.config.valueProvider.apply();
        result.complete(_apply);
      };
      _xifexpression = _function;
    } else {
      Procedure2<Function0<? extends Throwable>, CompletableFuture<T>> _xifexpression_1 = null;
      boolean _notEquals_1 = (!Objects.equal(this.config.exceptionProvider, null));
      if (_notEquals_1) {
        final Procedure2<Function0<? extends Throwable>, CompletableFuture<T>> _function_1 = (Function0<? extends Throwable> tp, CompletableFuture<T> result) -> {
          Throwable _defaultException = this.getDefaultException();
          result.completeExceptionally(_defaultException);
        };
        _xifexpression_1 = _function_1;
      } else {
        final Procedure2<Function0<? extends Throwable>, CompletableFuture<T>> _function_2 = (Function0<? extends Throwable> tp, CompletableFuture<T> result) -> {
          Throwable _apply = tp.apply();
          result.completeExceptionally(_apply);
        };
        _xifexpression_1 = _function_2;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  private Procedure2<? super Throwable, ? super CompletableFuture<T>> determineLastResort() {
    Procedure2<Throwable, CompletableFuture<T>> _xifexpression = null;
    boolean _notEquals = (!Objects.equal(this.config.valueProvider, null));
    if (_notEquals) {
      final Procedure2<Throwable, CompletableFuture<T>> _function = (Throwable t, CompletableFuture<T> result) -> {
        T _apply = this.config.valueProvider.apply();
        result.complete(_apply);
      };
      _xifexpression = _function;
    } else {
      Procedure2<Throwable, CompletableFuture<T>> _xifexpression_1 = null;
      boolean _notEquals_1 = (!Objects.equal(this.config.exceptionProvider, null));
      if (_notEquals_1) {
        final Procedure2<Throwable, CompletableFuture<T>> _function_1 = (Throwable t, CompletableFuture<T> result) -> {
          Throwable _defaultException = this.getDefaultException();
          result.completeExceptionally(_defaultException);
        };
        _xifexpression_1 = _function_1;
      } else {
        final Procedure2<Throwable, CompletableFuture<T>> _function_2 = (Throwable t, CompletableFuture<T> result) -> {
          result.completeExceptionally(t);
        };
        _xifexpression_1 = _function_2;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  @Override
  public CompletableFuture<T> withBreaker(final Function0<? extends CompletableFuture<? extends T>> action) {
    return this.withBreaker(this.config.breakerExecutor, action);
  }
  
  @Override
  public CompletableFuture<T> withBreaker(final Executor executor, final Function0<? extends CompletableFuture<? extends T>> action) {
    CompletableFuture<T> _xblockexpression = null;
    {
      java.util.Objects.<Executor>requireNonNull(executor);
      java.util.Objects.<Function0<? extends CompletableFuture<? extends T>>>requireNonNull(action);
      _xblockexpression = this.applyWithBreaker(executor, action);
    }
    return _xblockexpression;
  }
  
  private CompletableFuture<T> applyWithBreaker(final Executor executor, final Function0<? extends CompletableFuture<? extends T>> action) {
    CompletableFuture<T> _xblockexpression = null;
    {
      final CompletableFuture<T> result = new CompletableFuture<T>();
      try {
        final Runnable _function = () -> {
          this.callActionInit(executor, action, result);
        };
        executor.execute(_function);
      } catch (final Throwable _t) {
        if (_t instanceof RejectedExecutionException) {
          final RejectedExecutionException ree = (RejectedExecutionException)_t;
          this.lastResortResultCompletion.apply(ree, result);
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * Creates the retry strategy for this call and then invokes
   * {@link #callAction(Executor,Function0,CompletableFuture,RetryStrategy) callAction}.
   */
  private void callActionInit(final Executor executor, final Function0<? extends CompletableFuture<? extends T>> action, final CompletableFuture<T> result) {
    final RetryStrategy retryStrategy = this.config.strategy.apply();
    boolean _isCallPossible = this.breakerState.isCallPossible(this.config.name);
    boolean _not = (!_isCallPossible);
    if (_not) {
      final Function0<Throwable> _function = () -> {
        return new CircuitOpenException();
      };
      this.lazyLastResortResultCompletion.apply(_function, result);
      return;
    }
    this.callAction(executor, action, result, retryStrategy);
  }
  
  /**
   * Calls the given action if permitted by {@link #breakerState} and {@code result} was not cancelled.
   * The future returned by the action will be attached with a retry timeout and callbacks will be
   * registered on the future to handle retries and forwarding to {@code result}.
   * This method has to be called on one of the threads managed by the executor.
   */
  private void callAction(final Executor executor, final Function0<? extends CompletableFuture<? extends T>> action, final CompletableFuture<T> result, @Extension final RetryStrategy retryStrategy) {
    boolean _isCancelled = result.isCancelled();
    if (_isCancelled) {
      return;
    }
    CompletableFuture<? extends T> _xtrycatchfinallyexpression = null;
    try {
      CompletableFuture<? extends T> _xblockexpression = null;
      {
        final CompletableFuture<? extends T> actFut = action.apply();
        boolean _equals = Objects.equal(actFut, null);
        if (_equals) {
          final Function0<Throwable> _function = () -> {
            return new NullPointerException(SimpleCircuitBreaker.NULL_FROM_ACTION_MSG);
          };
          this.lazyLastResortResultCompletion.apply(_function, result);
          return;
        }
        _xblockexpression = actFut;
      }
      _xtrycatchfinallyexpression = _xblockexpression;
    } catch (final Throwable _t) {
      if (_t instanceof Throwable) {
        final Throwable t = (Throwable)_t;
        CompletableFuture<T> _xblockexpression_1 = null;
        {
          final CompletableFuture<T> error = new CompletableFuture<T>();
          error.completeExceptionally(t);
          _xblockexpression_1 = error;
        }
        _xtrycatchfinallyexpression = _xblockexpression_1;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    final CompletableFuture<? extends T> fut = _xtrycatchfinallyexpression;
    final CompletableFuture<? extends T> futWithTimeout = retryStrategy.withRetryTimeout(fut);
    boolean _isDone = futWithTimeout.isDone();
    boolean _not = (!_isDone);
    if (_not) {
      final Procedure0 _function = () -> {
        boolean _isDone_1 = futWithTimeout.isDone();
        boolean _not_1 = (!_isDone_1);
        if (_not_1) {
          CancelledFromOutsideException _cancelledFromOutsideException = new CancelledFromOutsideException();
          futWithTimeout.completeExceptionally(_cancelledFromOutsideException);
        }
      };
      CompletableFutureExtensions.<T>whenCancelledAsync(result, executor, _function);
    }
    final BiConsumer<T, Throwable> _function_1 = (T value, Throwable ex) -> {
      boolean _notEquals = (!Objects.equal(ex, null));
      if (_notEquals) {
        this.tryRetryOnError(ex, executor, action, result, retryStrategy);
      } else {
        result.complete(value);
        this.breakerState.successfulCall(this.config.name);
      }
    };
    futWithTimeout.whenCompleteAsync(_function_1, executor);
  }
  
  private void tryRetryOnError(final Throwable failure, final Executor executor, final Function0<? extends CompletableFuture<? extends T>> action, final CompletableFuture<T> result, final RetryStrategy retryStrategy) {
    if ((failure instanceof CancelledFromOutsideException)) {
      return;
    }
    this.breakerState.exceptionalCall(failure, this.config.name);
    final Procedure0 _function = () -> {
      this.lastResortResultCompletion.apply(failure, result);
    };
    final Procedure0 noRetry = _function;
    final Procedure0 _function_1 = () -> {
      try {
        final Runnable _function_2 = () -> {
          boolean _isCallPossible = this.breakerState.isCallPossible(this.config.name);
          boolean _not = (!_isCallPossible);
          if (_not) {
            final Function0<Throwable> _function_3 = () -> {
              return new CircuitOpenException(failure);
            };
            this.lazyLastResortResultCompletion.apply(_function_3, result);
            return;
          }
          this.callAction(executor, action, result, retryStrategy);
        };
        executor.execute(_function_2);
      } catch (final Throwable _t) {
        if (_t instanceof RejectedExecutionException) {
          final RejectedExecutionException ree = (RejectedExecutionException)_t;
          this.lastResortResultCompletion.apply(ree, result);
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
    };
    final Procedure0 doRetry = _function_1;
    retryStrategy.checkRetry(failure, noRetry, doRetry);
  }
  
  private Throwable getDefaultException() {
    Throwable _elvis = null;
    Throwable _apply = this.config.exceptionProvider.apply();
    if (_apply != null) {
      _elvis = _apply;
    } else {
      NullPointerException _nullPointerException = new NullPointerException(SimpleCircuitBreaker.DEFAULT_EXCEPTION_NULL_MSG);
      _elvis = _nullPointerException;
    }
    return _elvis;
  }
}
