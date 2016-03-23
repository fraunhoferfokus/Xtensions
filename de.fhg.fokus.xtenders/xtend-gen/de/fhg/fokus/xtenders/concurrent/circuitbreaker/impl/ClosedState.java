package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.ErrorStatisticsChecker;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.State;

@SuppressWarnings("all")
final class ClosedState implements State {
  public final ErrorStatisticsChecker[] checkers;
  
  public ClosedState(final ErrorStatisticsChecker[] checkers) {
    this.checkers = checkers;
  }
  
  @Override
  public boolean isCallPossible() {
    return true;
  }
}
