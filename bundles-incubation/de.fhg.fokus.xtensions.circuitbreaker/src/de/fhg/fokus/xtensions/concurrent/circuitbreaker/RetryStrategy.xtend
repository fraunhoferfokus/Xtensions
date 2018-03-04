package de.fhg.fokus.xtensions.concurrent.circuitbreaker

import java.util.concurrent.CompletableFuture

/**
 * RetryStrategy can be used by {@link CircuitBreaker} implementations to handle timeouts
 * of operations and checking if failed operations may be retried or not.<br>
 * Retry strategies are usually created per action to execute and are therefore 
 * called sequentially. Implementations are not expected to be thread safe, so the
 * caller has to make sure the memory is consistent. But calls to the functions 
 * of RetryStrategy may come from different threads.
 */
interface RetryStrategy {
	
	/**
	 * Configures a timeout after which an operation is regarded as timed out.
	 * If no timeout occurs, the result is forwarded from {@code fut} to the returned future.
	 * After the timeout, the returned CompletableFuture should be completed with
	 * a {@link TimeoutCancellationException} and the given completable future should be be cancelled. 
	 * The implementation may check if the future is already completed and not start a 
	 * retry timeout at all.
	 * This operation may return the original future if the RetryStrategy does not configure
	 * a retry timeout at all.
	 */
	def <T> CompletableFuture<T> withRetryTimeout(CompletableFuture<T> fut)
	
	/**
	 * This method checks if a retry is possible, this can e.g. be based on times or
	 * number of retries.<br>
	 * The doRetry callback may be called asynchronously after a delay. This can e.g.
	 * be used if there should be a minimum time between retries.
	 * The callbacks should not perform long operations.
	 */
	def void checkRetry(Throwable lastFailure, ()=>void noRetry, ()=>void doRetry)
}