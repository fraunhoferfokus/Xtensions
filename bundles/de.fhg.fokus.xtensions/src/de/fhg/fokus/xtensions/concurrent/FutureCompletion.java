package de.fhg.fokus.xtensions.concurrent;

import java.util.concurrent.CompletableFuture;

import org.eclipse.xtext.xbase.lib.Functions.Function1;

public class FutureCompletion<T> {
	
	/*package*/ static final FutureCompletion<?> NO_OP_COMPLETION = new FutureCompletion<>();
	/*package*/ static final FutureCompletion<?> ALREADY_COMPLETED_COMPLETION = new FutureCompletion<>();
	
	/** 
	 * Factory method to create a FutureCompletion instance that can be used
	 * as a return value in a function passed to an async function.<br>
	 * The value returned by this method indicates that the given {@code value}
	 * should be used to complete the result future.
	 * 
	 * @param value used to complete result future with
	 * @return FutureCompletion to return by functions passed to {@code async} method.
	 * @see AsyncCompute#async(Function1)
	 * @see AsyncCompute#async(Executor, Function1)
	 * @see AsyncCompute#async(long, TimeUnit, Function1)
	 * @see AsyncCompute#async(long, TimeUnit, Executor, Function1)
	 * @see AsyncCompute#async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
	 * @see AsyncCompute#async(ScheduledExecutorService, long, TimeUnit, Function1)
	 */
	public static <T> FutureCompletion<T> completeNow(T value) {
		return new NowFutureCompletion<>(value);
	}
	
	/** 
	 * Factory method to create a FutureCompletion instance that can be used
	 * as a return value in a function passed to an async function.<br>
	 * The value returned by this method indicates that the resulting completable
	 * future should be completed with the value provided by the 
	 * 
	 * TODO FURTHER DESCRIPTION, cancellation forward
	 * 
	 * @param futureResult
	 * @return FutureCompletion to return by functions passed to {@code async} method.
	 * @see AsyncCompute#async(Function1)
	 * @see AsyncCompute#async(Executor, Function1)
	 * @see AsyncCompute#async(long, TimeUnit, Function1)
	 * @see AsyncCompute#async(long, TimeUnit, Executor, Function1)
	 * @see AsyncCompute#async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
	 * @see AsyncCompute#async(ScheduledExecutorService, long, TimeUnit, Function1)
	 */
	public static <T> FutureCompletion<T> completeWith(CompletableFuture<? extends T> futureResult) {
		return new FutureFutureCompletion<>(futureResult);
	}
	
	/**
	 * Factory method to create a FutureCompletion instance that can be used
	 * as a return value in a function passed to an async function. <br>
	 * The created FutureCompletion indicates, that the result future is completed asynchronously.
	 * This means that the CompletedFuture passed into the function must be called 
	 * "manually". This can also be done asynchronously on a different thread. Note that 
	 * the caller method cannot ensure completion of the future holding the result value.
	 * @see AsyncCompute#async(Function1)
	 * @see AsyncCompute#async(Executor, Function1)
	 * @see AsyncCompute#async(long, TimeUnit, Function1)
	 * @see AsyncCompute#async(long, TimeUnit, Executor, Function1)
	 * @see AsyncCompute#async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
	 * @see AsyncCompute#async(ScheduledExecutorService, long, TimeUnit, Function1)
	 */
	@SuppressWarnings("unchecked")
	public static <T> FutureCompletion<T> completeAsync() {
		// NoOp completion is the same for every type T
		return (FutureCompletion<T>) NO_OP_COMPLETION;
	}

	private FutureCompletion() {}

	/**
	 * Subclass of {@link FutureCompletion} holding a result value of type {@code T}
	 */
	/*package*/ static final class NowFutureCompletion<T> extends FutureCompletion<T> {
		final T value;

		private NowFutureCompletion(T t) {
			value = t;
		}
	}

	/**
	 * Subclass of {@link FutureCompletion} holding a future of {@code T} holding the 
	 * value to be returned.
	 */
	/*package*/ static final class FutureFutureCompletion<T> extends FutureCompletion<T> {
		final CompletableFuture<? extends T> value;

		private FutureFutureCompletion(CompletableFuture<? extends T> f) {
			value = f;
		}
	}
	
}
