package de.fhg.fokus.xtensions.function;

import com.google.common.annotations.Beta;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Function;

import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;

@Beta
public final class MemorizationExtensions {
	
	private MemorizationExtensions() {
		throw new IllegalStateException("MemorizationExtensions not intended to be instantiated");
	}
	
	/**
	 * Thread safety properties for memorized functions.
	 */
	public static enum MemThreadSafety {
		
		/**
		 * No thread safety is performed on memorization. The memorized function is 
		 * only allowed to be used by one thread.
		 */
		NONE, 
		
		/**
		 * Performs an atomic write to the memorized data. This means multiple threads 
		 * may compute the value in parallel if it was not memorized before, but only the 
		 * first to write the value will produce the result always returned from the memorized
		 * function.
		 */
		ATOMIC, 
		
		/**
		 * Performs double-checked locking to create the result value. Only one thread will 
		 * ever compute the memorized result value. During the computation other threads will block until the result
		 * value is computed.
		 */
		SYNC
	}

	private static final class SyncingMemFunction0<@NonNull R> implements Function0<R> {

		public SyncingMemFunction0(@NonNull Function0<@NonNull R> eagerFunc) {
			super();
			this.eagerFunc = eagerFunc;
		}

		private final Function0<R> eagerFunc;

		private volatile Optional<R> val = null;

		public R apply() {
			if (val != null) {
				return val.orElse(null);
			}
			// else we may have to compute and set value
			synchronized (eagerFunc) {
				// double check if no one already set value
				if (val != null) {
					return val.orElse(null);
				} else {
					// we actually do have to compute on our own
					R newVal = eagerFunc.apply();
					val = Optional.ofNullable(newVal);
					return newVal;
				}
			}
		}
	}

	private static final class SyncingMemFunction2<T, U, R> implements Function2<T, U, R> {

		private final ConcurrentHashMap<List<Object>, R> cache = new ConcurrentHashMap<>();

		SyncingMemFunction2(Function2<? super T, ? super U, ? extends R> eagerFunc) {
			super();
			this.eagerFunc = eagerFunc;
		}

		@SuppressWarnings("unchecked")
		private R spreadCallEager(List<Object> parameters) {
			return eagerFunc.apply((T) parameters.get(0), (U) parameters.get(1));
		}

		private final Function2<? super T, ? super U, ? extends R> eagerFunc;

		public R apply(T t, U u) {
			return cache.computeIfAbsent(Arrays.asList(t, u), this::spreadCallEager);
		}
	}

	private static final class SyncingMemFunction1<T, R> implements Function1<T, R> {

		// using array as box, so keys are always non-null
		private final ConcurrentHashMap<T[], R> cache = new ConcurrentHashMap<>();

		SyncingMemFunction1(@NonNull Function1<? super T, ? extends R> eagerFunc) {
			super();
			this.eagerFunc = (ts) -> eagerFunc.apply(ts[0]);
		}

		private final Function<? super T[], ? extends R> eagerFunc;

		public R apply(T t) {
			return compute(t);
		}

		@SafeVarargs
		private final R compute(T... t) {
			return cache.computeIfAbsent(t, eagerFunc);
		}
	}

	/**
	 * Wraps the given function {@code lambda} in another function that
	 * delegates the first call to the wrapped function and caches the output.
	 * Subsequent calls to the wrapper function will return the cached value
	 * without calling {@code lambda} again. This version of lazy is
	 * <em>not</em> thread safe.
	 * 
	 * @param lambda
	 *            the lambda, thats output will be cached by the returned
	 *            function.
	 * @return function, delegating to {@code lambda}, caching its output for
	 *         further calls.
	 * @see #memAtomic(Function0)
	 */
	public static <R> @NonNull Function0<R> mem(@NonNull Function0<R> lambda) {
		Objects.requireNonNull(lambda);
		return new Function0<R>() {
			private boolean memorized = false;
			private R val = null;

			@Override
			public R apply() {
				if (!memorized) {
					val = lambda.apply();
					memorized = true;
				}
				return val;
			}
		};
	}

	/**
	 * This version of lazy is <em>not</em> thread safe.
	 * 
	 * @param lambda
	 * @return
	 */
	public static <T, R> @NonNull Function1<T, R> mem(@NonNull Function1<T, R> lambda) {
		Objects.requireNonNull(lambda);
		final HashMap<T, Optional<R>> values = new HashMap<>();
		return (T t) -> {
			Optional<R> val = values.get(t);
			// if Value is not yet in
			if (val == null) {
				@NonNull
				R newVal = lambda.apply(t);
				values.put(t, Optional.ofNullable(newVal));
				return newVal;
			}
			return val.orElse(null);
		};
	}

	/**
	 * TODO documentation
	 * This function is working thread safe and may block concurrent threads.
	 * The lambda is guaranteed to be evaluated at most once if it evaluates
	 * without an exception. If the lambda throws an exception, the lambda will
	 * be evaluated again, if called a second time.
	 * 
	 * @param lambda
	 * @return
	 */
	public static <T, U, R> @NonNull Function2<T, U, R> mem(@NonNull MemThreadSafety safetyProperties, 
			@NonNull Function2<? super T, ? super U, ? extends R> lambda) {
		switch(safetyProperties) {
		case NONE: throw new UnsupportedOperationException("not implemented yet");
		case SYNC: return new SyncingMemFunction2<T, U, R>(lambda);
		case ATOMIC: throw new UnsupportedOperationException("not implemented yet");
		default: throw new IllegalStateException();
		}
	}

	/**
	 * TODO: documentations
	 * 
	 * @param lambda
	 * @return
	 */
	public static <R> @NonNull Function0<R> mem(@NonNull MemThreadSafety safetyProperties, @NonNull Function0<R> lambda) {
		switch(safetyProperties) {
		case NONE: return mem(lambda);
		case SYNC: return new SyncingMemFunction0<R>(lambda);
		case ATOMIC: throw new UnsupportedOperationException("not implemented yet");
		default: throw new IllegalStateException();
		}
	}

	/**
	 * TODO: documentations
	 * 
	 * Be aware: uses Map, so leaks memory if held on to
	 * 
	 * @param lambda
	 * @return
	 */
	public static <T, R> Function1<T, R> mem(@NonNull MemThreadSafety safetyProperties, @NonNull Function1<T, R> lambda) {
		switch(safetyProperties) {
		case NONE: return mem(lambda);
		case SYNC: return new SyncingMemFunction1<T, R>(lambda);
		case ATOMIC: throw new UnsupportedOperationException("not implemented yet");
		default: throw new IllegalStateException();
		}
	}
}