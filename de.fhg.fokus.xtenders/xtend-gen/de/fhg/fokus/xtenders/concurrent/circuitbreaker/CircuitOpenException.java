package de.fhg.fokus.xtenders.concurrent.circuitbreaker;

import de.fhg.fokus.xtenders.concurrent.CompletableFutureExtensions;
import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.concurrent.ForkJoinPool;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

/**
 * Will be used to complete a result of a {@link CircuitBreaker#withBreaker(Function0) CircuitBreaker#withBreaker}
 * with an instance of this class. If this exception is instantiated with a wrapped "cause" exception, this should
 * be the last error returned by the action to be performed in the circuit breaker.
 */
@SuppressWarnings("all")
public final class CircuitOpenException extends Exception {
  /**
   * Default constructor
   */
  public CircuitOpenException() {
  }
  
  /**
   * Calls {@code super(cause)}. Throwable should be the
   * the one returned by action of last failed call
   * @see Exception#Exception(Throwable)
   */
  public CircuitOpenException(final Throwable cause) {
    super(cause);
  }
  
  /**
   * Calls {@code super(message)}
   * @see Exception#Exception(String)
   */
  public CircuitOpenException(final String message) {
    super(message);
  }
  
  /**
   * Calls {@code super(message, cause)}. Throwable should be the
   * the one returned by action of last failed call
   * @see Exception#Exception(String,Throwable)
   */
  public CircuitOpenException(final String message, final Throwable cause) {
    super(message, cause);
  }
  
  private static void callOnCircuitOpenException(final Throwable it, final Procedure1<? super CircuitOpenException> action) {
    if ((it instanceof CircuitOpenException)) {
      action.apply(((CircuitOpenException)it));
    }
  }
  
  /**
   * May be used as extension function, calls the action when the future completes with a CircuitOpenException
   */
  public static <R extends Object> CompletableFuture<R> whenCircuitOpen(final CompletableFuture<R> fut, final Procedure1<? super CircuitOpenException> action) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Procedure1<? super CircuitOpenException>>requireNonNull(action);
      final Procedure1<Throwable> _function = (Throwable it) -> {
        CircuitOpenException.callOnCircuitOpenException(it, action);
      };
      _xblockexpression = CompletableFutureExtensions.<R>whenException(fut, _function);
    }
    return _xblockexpression;
  }
  
  /**
   * May be used as extension function, calls the action on the given executor when the future completes with a CircuitOpenException
   */
  public static <R extends Object> CompletableFuture<R> whenCircuitOpenAsync(final CompletableFuture<R> fut, final Executor e, final Procedure1<? super CircuitOpenException> action) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Procedure1<? super CircuitOpenException>>requireNonNull(action);
      final Procedure1<Throwable> _function = (Throwable it) -> {
        CircuitOpenException.callOnCircuitOpenException(it, action);
      };
      _xblockexpression = CompletableFutureExtensions.<R>whenExceptionAsync(fut, e, _function);
    }
    return _xblockexpression;
  }
  
  /**
   * May be used as extension function, calls the action on the common ForkJoinPool when the future completes with a CircuitOpenException
   */
  public static <R extends Object> CompletableFuture<R> whenCircuitOpenAsync(final CompletableFuture<R> fut, final Procedure1<? super CircuitOpenException> action) {
    ForkJoinPool _commonPool = ForkJoinPool.commonPool();
    return CircuitOpenException.<R>whenCircuitOpenAsync(fut, _commonPool, action);
  }
}
