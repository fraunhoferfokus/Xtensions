package de.fhg.fokus.xtensions.concurrent

import java.util.concurrent.CompletableFuture
import java.util.Objects
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*

class CompletableFutureAggregations {

	public static def void cancelAll(CompletableFuture<?>... toCancel) {
		Objects::requireNonNull(toCancel)
		toCancel.forEach[it?.cancel]
	}

	public static def <U, V, R> CompletableFuture<R> allCompleted(CompletableFuture<U> a, CompletableFuture<V> b,
		(U, V)=>R onSuccess) {
		Objects.requireNonNull(onSuccess)
		CompletableFuture.allOf(a, b).thenApply [
			onSuccess.apply(a.get, b.get)
		]
	}

	public static def <U, V, W, R> CompletableFuture<R> allCompleted(CompletableFuture<U> a, CompletableFuture<V> b,
		CompletableFuture<W> c, (U, V, W)=>R onSuccess) {
		Objects::requireNonNull(onSuccess)
		CompletableFuture.allOf(a, b, c).thenApply [
			onSuccess.apply(a.get, b.get, c.get)
		]
	}

	public static def <U, V, W, X, R> CompletableFuture<R> allCompleted(CompletableFuture<U> a, CompletableFuture<V> b,
		CompletableFuture<W> c, CompletableFuture<X> d, (U, V, W, X)=>R onSuccess) {
		Objects::requireNonNull(onSuccess)
		CompletableFuture.allOf(a, b, c, d).thenApply [
			onSuccess.apply(a.get, b.get, c.get, d.get)
		]
	}

	public static def <U, V, W, X, Y, R> CompletableFuture<R> allCompleted(CompletableFuture<U> a,
		CompletableFuture<V> b, CompletableFuture<W> c, CompletableFuture<X> d, CompletableFuture<Y> e,
		(U, V, W, X, Y)=>R onSuccess) {
		Objects.requireNonNull(onSuccess)
		CompletableFuture.allOf(a, b, c, d, e).thenApply [
			onSuccess.apply(a.get, b.get, c.get, d.get, e.get)
		]
	}

	public static def <U, V, W, X, Y, Z, R> CompletableFuture<R> allCompleted(CompletableFuture<U> a,
		CompletableFuture<V> b, CompletableFuture<W> c, CompletableFuture<X> d, CompletableFuture<Y> e,
		CompletableFuture<Z> f, (U, V, W, X, Y, Z)=>R onSuccess) {
		Objects.requireNonNull(onSuccess)
		CompletableFuture.allOf(a, b, c, d, e, f).thenApply [
			onSuccess.apply(a.get, b.get, c.get, d.get, e.get, f.get)
		]
	}

	public static def <U, V, R> CompletableFuture<R> allCompletedCancelOnError(CompletableFuture<U> a,
		CompletableFuture<V> b, (U, V)=>R onSuccess) {
		Objects.requireNonNull(onSuccess)
		val result = CompletableFuture.allOf(a, b).thenApply [
			onSuccess.apply(a.get, b.get)
		]
		result.whenException [
			cancelAll(a, b)
		]
	}

	public static def <U, V, W, R> CompletableFuture<R> allCompletedCancelOnError(CompletableFuture<U> a,
		CompletableFuture<V> b, CompletableFuture<W> c, (U, V, W)=>R onSuccess) {
		Objects.requireNonNull(onSuccess)
		val result = CompletableFuture.allOf(a, b, c).thenApply [
			onSuccess.apply(a.get, b.get, c.get)
		]
		result.whenException [
			cancelAll(a, b, c)
		]
	}

	public static def <U, V, W, X, R> CompletableFuture<R> allCompletedCancelOnError(CompletableFuture<U> a,
		CompletableFuture<V> b, CompletableFuture<W> c, CompletableFuture<X> d, (U, V, W, X)=>R onSuccess) {
		Objects.requireNonNull(onSuccess)
		val result = CompletableFuture.allOf(a, b, c, d).thenApply [
			onSuccess.apply(a.get, b.get, c.get, d.get)
		]
		result.whenException [
			cancelAll(a, b, c, d)
		]
	}

	public static def <U, V, W, X, Y, R> CompletableFuture<R> allCompletedCancelOnError(CompletableFuture<U> a,
		CompletableFuture<V> b, CompletableFuture<W> c, CompletableFuture<X> d, CompletableFuture<Y> e,
		(U, V, W, X, Y)=>R onSuccess) {
		Objects.requireNonNull(onSuccess)
		val result = CompletableFuture.allOf(a, b, c, d, e).thenApply [
			onSuccess.apply(a.get, b.get, c.get, d.get, e.get)
		]
		result.whenException [
			cancelAll(a, b, c, d, e)
		]
	}

	public static def <U, V, W, X, Y, Z, R> CompletableFuture<R> allCompletedCancelOnError(CompletableFuture<U> a,
		CompletableFuture<V> b, CompletableFuture<W> c, CompletableFuture<X> d, CompletableFuture<Y> e,
		CompletableFuture<Z> f, (U, V, W, X, Y, Z)=>R onSuccess) {
		Objects.requireNonNull(onSuccess)
		val result = CompletableFuture.allOf(a, b, c, d, e, f).thenApply [
			onSuccess.apply(a.get, b.get, c.get, d.get, e.get, f.get)
		]
		result.whenException [
			cancelAll(a, b, c, d, e)
		]
	}

	/**
	 * The returned future will hold the result of the first future found to be complete.
	 * Be aware that the first completed may be completed exceptionally, or was cancelled.
	 * If the returned future is cancelled, all given futures are cancelled with it.
	 * When the result is available, all futures are being canceled, because their result
	 * is not needed.<br>
	 * Due to the sequential traversal of the {@code futures} the result may not be from
	 * the actual fastest result, but it is the one found the fastest.
	 * 
	 * @param futures are checked for a result. The first future found to be completed completes 
	 *  the returned future. Must not be {@code null}. If any field of the array is {@code null}
	 *  the field is skipped.
	 * @return Future holding the result of the first of the given {@code futures}
	 * @throws NullPointerException if {@code futures} array is {@code null}
	 */
	public static def <V> CompletableFuture<V> firstAndCancelOthers(CompletableFuture<? extends V>... futures) {
		Objects.requireNonNull(futures)
		val result = first(futures)
		result.then [
			// the futures already completed will no be affected
			futures.forEach[it?.cancel]
		]
		result
	}

	/**
	 * The returned future will hold the value of the first future found to be complete.
	 * Be aware that the first completed may be completed exceptionally, or was cancelled.
	 * If the returned future is cancelled, all given futures are cancelled with it.
	 * 
	 * @param futures are checked for a result. The first future found to be completed completes 
	 *  the returned future. Must not be {@code null}. If any field of the array is {@code null}
	 *  this field is skipped.
	 * @return Future holding the result of the first of the given {@code futures}
	 * @throws NullPointerException if {@code futures} array is {@code null}
	 */
	public static def <V> CompletableFuture<V> first(CompletableFuture<? extends V>... futures) {
		Objects.requireNonNull(futures)
		val result = new CompletableFuture<V>()
		futures.forEach [
			if (it !== null) {
				it.forwardTo(result)
				result.forwardCancellation(it)
			}
		]
		result
	}

// TODO public static def CompletableFuture<Pair<U,V>> zip(CompletableFuture<U> self, CompletableFuture<V> other)
}
