package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.RetryStrategy;
import java.util.concurrent.CompletableFuture;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;

/**
 * Never retrying strategy that configures no timeout
 */
@SuppressWarnings("all")
class NoRetryNoTimeoutStrategy implements RetryStrategy {
  @Override
  public <T extends Object> CompletableFuture<T> withRetryTimeout(final CompletableFuture<T> fut) {
    return fut;
  }
  
  @Override
  public void checkRetry(final Throwable lastFailure, final Procedure0 noRetry, final Procedure0 doRetry) {
    noRetry.apply();
  }
}
