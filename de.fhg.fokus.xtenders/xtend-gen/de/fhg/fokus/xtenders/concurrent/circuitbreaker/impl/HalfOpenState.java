package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.TimeoutStrategy;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.State;
import java.util.concurrent.TimeUnit;

@SuppressWarnings("all")
final class HalfOpenState implements State {
  public final TimeoutStrategy toHalfOpenTimeoutStrategy;
  
  public final long lastTimeout;
  
  public final TimeUnit lastTimeoutUnit;
  
  public HalfOpenState(final TimeoutStrategy strategy, final long lastTimeout, final TimeUnit lastTimeoutUnit) {
    this.toHalfOpenTimeoutStrategy = strategy;
    this.lastTimeout = lastTimeout;
    this.lastTimeoutUnit = lastTimeoutUnit;
  }
  
  @Override
  public boolean isCallPossible() {
    return true;
  }
}
