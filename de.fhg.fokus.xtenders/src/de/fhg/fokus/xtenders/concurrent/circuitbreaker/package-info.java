/**
 * This package and the impl sub-package includes a reactive implementation of
 * the "circuit breaker" pattern completely based on the
 * {@link java.util.concurrent.CompletableFuture CompletableFuture} class. The
 * API follows the following principles:
 * <ul>
 * <li><em>Simple:</em> The APIs between components and to the user are supposed
 * to be simple to understand. Getting started with using the library should be
 * as easy as possible without making advanced usage scenarios impossible.</li>
 * <li><em>Minimal:</em> APIs should only contain a minimum set of methods to
 * allow simple integrations and alternative implementations. The provided basic
 * API implementations should not be overly complex. Functionality that can
 * easily be achieved with CompletableFutures or added via composition will not
 * be added to the core of the library.</li>
 * <li><em>Pluggable:</em> Since the provided API implementations are basic,
 * more versatile and more configurable implementations should be able to be
 * used as drop-in replacements for the provided basic implementations.
 * <li><em>Composable:</em> The API is supposed to have functional elements, so
 * that functional composition may be used to add missing functionality instead
 * of baking the functionality in the library APIs where ever possible.</li>
 * </ul>
 * The basic interface to work with is
 * {@link de.fhg.fokus.xtenders.concurrent.circuitbreaker.CircuitBreaker
 * CircuitBreaker}, a default implementation can be created using the builder
 * class
 * {@link de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.CircuitBreakerBuilder
 * SimpleCircuitBreakerBuilder}.
 */
package de.fhg.fokus.xtenders.concurrent.circuitbreaker;