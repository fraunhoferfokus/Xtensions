package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import java.util.concurrent.CancellationException;

/**
 * Used to signal that the user of the CircuitBreaker API cancelled an
 * operation.
 */
@SuppressWarnings("all")
class CancelledFromOutsideException extends CancellationException {
}
