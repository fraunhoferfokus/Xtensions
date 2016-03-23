package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

/**
 * Superclass of classes representing the internal state.
 * The state determines if calls can be performed or not.
 */
@SuppressWarnings("all")
interface State {
  /**
   * Checks if call can be performed in the current state.
   */
  public abstract boolean isCallPossible();
}
