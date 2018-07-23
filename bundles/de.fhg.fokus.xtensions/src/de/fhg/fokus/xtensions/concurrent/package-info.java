/**
 * This package contains classes providing extension methods for JDK classes
 * related to concurrent programming and some new functionality for scheduling
 * concurrently executed pieces of code.<br>
 * <br>
 * The {@link de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions
 * CompletableFutureExtensions} class provides extension methods for the JDK
 * class {@link java.util.concurrent.CompletableFuture CompletableFuture}.<br>
 * <br>
 * The class {@link de.fhg.fokus.xtensions.concurrent.AsyncCompute AsyncCompute}
 * provides extension methods on the JDK classes
 * {@link java.util.concurrent.Executor Executor} and
 * {@link java.util.concurrent.ScheduledExecutorService
 * ScheduledExecutorService} that basically dispatch work on the executors and
 * return {@code CompletableFuture}s being completed with the result of the
 * computation. Note that there are similar methods provided in the
 * {@code CompletableFuture} class, but the methods provided in
 * {@code AsyncCompute} are more natural to use with Xtend.<br>
 * <br>
 * The class {@link de.fhg.fokus.xtensions.concurrent.SchedulingUtil
 * SchedulingUtil} provides methods to schedule tasks for later or re-occurring
 * execution. Some of these methods can be used as extension methods on
 * {@link java.util.concurrent.ScheduledExecutorService
 * ScheduledExecutorService}.
 */
package de.fhg.fokus.xtensions.concurrent;