package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.TimeoutStrategy;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.State;
import java.util.concurrent.TimeUnit;

@SuppressWarnings("all")
final class OpenState implements State {
  public final TimeoutStrategy toHalfOpenTimeoutStrategy;
  
  public final long targetTime;
  
  public final long lastTimeout;
  
  public final TimeUnit lastTimeoutUnit;
  
  public OpenState(final TimeoutStrategy strategy, final long targetTime, final long lastTimout, final TimeUnit lastTimeoutUnit) {
    this.toHalfOpenTimeoutStrategy = strategy;
    this.targetTime = targetTime;
    this.lastTimeout = lastTimout;
    this.lastTimeoutUnit = lastTimeoutUnit;
  }
  
  @Override
  public boolean isCallPossible() {
    return false;
  }
}
