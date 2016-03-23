package de.fhg.fokus.xtenders.concurrent.circuitbreaker;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

/**
 * The CircuitBreaker wraps around operations that return CompletableFutures
 * and based on the configuration may retry the operations if they fail or complete
 * with default values or default exceptions. The internal state may cause failing
 * results, without even calling a given action, if the circuit is opened.<br>
 * A recommended way of usage within Xtend is to declare an extension field or value,
 * so the function can be used in the following way:
 * <pre><code>val extension breaker = SimpleCircuitBreakerBuilder.create.build // or other implementation
 * def callSomeAction() {
 * 	[someAction()].withBreaker
 * }
 * </code></pre>
 */
@SuppressWarnings("all")
public interface CircuitBreaker<T extends Object> {
  /**
   * This method performs the given action, possibly multiple times, until
   * it returns a result regarded successful, or some criterion decided to not to
   * call or retry the action.
   * One of this criterion may be an opened circuit.
   * 
   * All CircuitBreaker logic will be performed on a configured Executor.
   * The returned future may complete with {@link CircuitOpenException} if the action cannot be completed,
   * because of an open circuit.
   * 
   * @param action is the operation that may be called, possibly multiple times, to get
   *  the result that is forwarded to the future returned by this method.
   * @return future that will either be completed with the result of the given {@code action}
   *    or with a default value (if configured) or with a default exception (if configured),
   *    or a CircuitOpenException, if the circuit was opened. Canceling the future from outside
   *    should be recognized by the CircuitBreaker implementation and should lead to no further
   *    retries and canceling of the latest action future. However, there is no guarantee that
   *    a successfully cancelled result will cause actions and retries to stop.
   */
  public abstract CompletableFuture<T> withBreaker(final Function0<? extends CompletableFuture<? extends T>> action);
  
  /**
   * This method performs the given action, possibly multiple times, until
   * it returns a result regarded successful, or some criterion decided to not to
   * call or retry the action.
   * One of this criterion may be an opened circuit.
   * 
   * All CircuitBreaker logic will be performed using the given executor.
   * 
   * @param executor The executor which will be used to perform all the CircuitBreaker logic on.
   * @param action is the operation that may be called, possibly multiple times, to get
   *  the result that is forwarded to the future returned by this method.
   * @return future that will either be completed with the result of the given {@code action}
   *    or with a default value (if configured) or with a default exception (if configured),
   *    or a CircuitOpenException, if the circuit was opened. Canceling the future from outside
   *    should be recognized by the CircuitBreaker implementation and should lead to no further
   *    retries and canceling of the latest action future. However, there is no guarantee that
   *    a successfully cancelled result will cause actions and retries to stop.
   */
  public abstract CompletableFuture<T> withBreaker(final Executor executor, final Function0<? extends CompletableFuture<? extends T>> action);
}
