package de.fhg.fokus.xtenders.function;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.DoubleUnaryOperator;
import java.util.function.Function;
import java.util.function.IntUnaryOperator;
import java.util.function.LongUnaryOperator;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.xbase.lib.FunctionExtensions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.Functions.Function3;
import org.eclipse.xtext.xbase.lib.Functions.Function4;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Pair;
import org.eclipse.xtext.xbase.lib.Pure;

/**
 * This class provides static extension methods for Xtend and Java 8 functional
 * interfaces.
 * 
 * @author Max Bureck
 */
public final class AdditionalFunctionExtensions {

	private static final class ConcurrentLazyFunction0<@NonNull R> implements Function0<R> {

		public ConcurrentLazyFunction0(@NonNull Function0<@NonNull R> eagerFunc) {
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

	private static final class ConcurrentLazyFunction1<T, @NonNull R> implements Function1<T, R> {

		private final ConcurrentHashMap<T, Optional<R>> cache = new ConcurrentHashMap<>();

		ConcurrentLazyFunction1(Function1<? super T, @NonNull ? extends R> eagerFunc) {
			super();
			this.eagerFunc = t -> Optional.ofNullable(eagerFunc.apply(t));
		}

		private final Function<? super T, Optional<R>> eagerFunc;

		public R apply(T t) {
			return cache.computeIfAbsent(t, eagerFunc).orElse(null);
		}
	}

	private static final class ConcurrentLazyFunction2<T, U, @NonNull R> implements Function2<T, U, R> {

		private final ConcurrentHashMap<List<Object>, Optional<R>> cache = new ConcurrentHashMap<>();

		ConcurrentLazyFunction2(Function2<? super T, ? super U, @NonNull ? extends R> eagerFunc) {
			super();
			this.eagerFunc = eagerFunc;
		}

		private Optional<R> spreadCallEager(List<Object> parameters) {
			@SuppressWarnings("unchecked") // apply ensures correct types
			final R result = eagerFunc.apply((T) parameters.get(0), (U) parameters.get(1));
			return Optional.ofNullable(result);
		}

		private final Function2<? super T, ? super U, ? extends R> eagerFunc;

		public R apply(T t, U u) {
			return cache.computeIfAbsent(Arrays.asList(t, u), this::spreadCallEager).orElse(null);
		}
	}

	private AdditionalFunctionExtensions() {
		throw new IllegalStateException("FunctionExtensions is not allowed to be instantiated");
	}

	/**
	 * This extension operator is the "pipe forward" operator. The effect is
	 * that {@code function} will be called with the given {@code value}. The
	 * advantage is that chained nested calls are represented as chains which
	 * can be easier to read. E.g. the nested call {@code c(b(a(val)))} can be
	 * represented like this: {@code val >>> a >>> b >>> c}.
	 * 
	 * @param value
	 *            a value that will piped into the {@code function}. Meaning
	 *            that {@code function} will be called with {@code value} as its
	 *            parameter.
	 * @param function
	 *            Will be called with {@code value} Must not be {@code null}.
	 * @return the result of calling {@code function} with {@code value}
	 * @throws NullPointerException
	 *             if {@code function} is null
	 */
	public static <T, R> R operator_tripleGreaterThan(T value, @NonNull Function1<? super T, ? extends R> function)
			throws NullPointerException {
		Objects.requireNonNull(function);
		return function.apply(value);
	}

	/**
	 * This extension operator is the "pipe forward" operator. The effect is
	 * that {@code function} will be called with the given {@code value}. The
	 * advantage is that chained nested calls are represented as chains which
	 * can be easier to read. E.g. the nested call {@code c(b(a(val)))} can be
	 * represented like this: {@code val >>> a >>> b >>> c}.
	 * 
	 * @param value
	 *            a value that will piped into the {@code function}. Meaning
	 *            that {@code function} will be called with {@code value} as its
	 *            parameter.
	 * @param function
	 *            Will be called with {@code value}. Must not be {@code null}.
	 * @return the result of calling {@code function} with {@code value}
	 * @throws NullPointerException
	 *             if {@code function} is null
	 */
	public static <T> int operator_tripleGreaterThan(int value, @NonNull IntUnaryOperator function)
			throws NullPointerException {
		Objects.requireNonNull(function);
		return function.applyAsInt(value);
	}

	/**
	 * This extension operator is the "pipe forward" operator. The effect is
	 * that {@code function} will be called with the given {@code value}. The
	 * advantage is that chained nested calls are represented as chains which
	 * can be easier to read. E.g. the nested call {@code c(b(a(val)))} can be
	 * represented like this: {@code val >>> a >>> b >>> c}.
	 * 
	 * @param value
	 *            a value that will piped into the {@code function}. Meaning
	 *            that {@code function} will be called with {@code value} as its
	 *            parameter.
	 * @param function
	 *            Will be called with {@code value}. Must not be {@code null}.
	 * @return the result of calling {@code function} with {@code value}
	 * @throws NullPointerException
	 *             if {@code function} is null
	 */
	public static <T> long operator_tripleGreaterThan(long value, @NonNull LongUnaryOperator function)
			throws NullPointerException {
		Objects.requireNonNull(function);
		return function.applyAsLong(value);
	}

	/**
	 * This extension operator is the "pipe forward" operator. The effect is
	 * that {@code function} will be called with the given {@code value}. The
	 * advantage is that chained nested calls are represented as chains which
	 * can be easier to read. E.g. the nested call {@code c(b(a(val)))} can be
	 * represented like this: {@code val >>> a >>> b >>> c}.
	 * 
	 * @param value
	 *            a value that will piped into the {@code function}. Meaning
	 *            that {@code function} will be called with {@code value} as its
	 *            parameter.
	 * @param function
	 *            Will be called with {@code value}. Must not be {@code null}.
	 * @return the result of calling {@code function} with {@code value}
	 * @throws NullPointerException
	 *             if {@code function} is null
	 */
	public static <T> double operator_tripleGreaterThan(double value, @NonNull DoubleUnaryOperator function)
			throws NullPointerException {
		Objects.requireNonNull(function);
		return function.applyAsDouble(value);
	}
	
	/**
	 * This extension operator is the "pipe forward" operator for value-pairs.
	 * This will call {@code function} with the the two values of the pair as
	 * parameters and return the result
	 * 
	 * @param value
	 *            This parameter must not be {@code null}.
	 * @param function
	 * @return
	 * @throws NullPointerException
	 *             if either {@code value} or {@code function} is null
	 */
	public static <T, V, R> R operator_tripleGreaterThan(Pair<T, V> value,
			Function2<? super T, ? super V, ? extends R> function) throws NullPointerException {
		Objects.requireNonNull(function);
		Objects.requireNonNull(value);
		return function.apply(value.getKey(), value.getValue());
	}

	// TODO and, or, negate on Function1<T, Boolean>

	/**
	 * Shortcut operator for {@link FunctionExtensions#compose(Function1, Function)}
	 * @param self
	 * @param before
	 * @return
	 */
	@Pure
	@Inline(value = "org.eclipse.xtext.xbase.lib.FunctionExtensions.compose($1,$2)", imported = FunctionExtensions.class)
	public static <T, V, R> @NonNull Function1<V, R> operator_doubleLessThan (@NonNull Function1<? super T, ? extends R> self,
			@NonNull Function1<? super V, ? extends T> before) {
		return FunctionExtensions.compose(self, before);
	}
	
	/**
	 * Shortcut operator for {@link FunctionExtensions#andThen(Function1, Function1)}.
	 * @param self the function to apply before the {@code after} function is applied
	 * @param after  the function to apply after the {@code before} function is applied
	 * @return  a composed function that first applies the {@code before} function and 
	 * then applies the {@code self} function with the result of {@code before}
	 */
	@Pure
	@Inline(value = "org.eclipse.xtext.xbase.lib.FunctionExtensions.andThen($1,$2)", imported = FunctionExtensions.class)
	public static <T, V, R> Function1<T, V> operator_doubleGreaterThan (@NonNull Function1<? super T, ? extends R> self,
			@NonNull Function1<? super R, ? extends V> after) {
		return FunctionExtensions.andThen(self, after);
	}

	/**
	 * Returns a composed function that first calls {@code self} function to
	 * and then applies the {@code after} function to the result. If
	 * evaluation of either function throws an exception, it is relayed to the
	 * caller of the composed function.
	 *
	 * @param <V>
	 *            the type of output of the {@code after} function, and of the
	 *            composed function.
	 * @param <R>
	 *            the return type of function {@code self} and input to function
	 *            {@code after}.
	 * @param self
	 *            the function to apply before {@code after} function is applied
	 *            in the returned composed function. The input to the composed
	 *            function will be passed to this function and the output will
	 *            be forwarded to function {@code after}.
	 * @param after
	 *            the function to be called after function {@code self} taking
	 *            that functions output as an input in the returned composed
	 *            function. The output of this function will be the return value
	 *            of the composed function.
	 * @return a composed function that first applies this function and then
	 *         applies the {@code after} function
	 * @throws NullPointerException
	 *             if {@code self} or {@code after} is {@code null}
	 *
	 * @see #compose(Function1,Function1)
	 */
	@Pure
	public static <V, R> Function0<V> andThen(@NonNull Function0<? extends R> self,
			@NonNull Function1<? super R, ? extends V> after) {
		Objects.requireNonNull(self);
		Objects.requireNonNull(after);
		return () -> after.apply(self.apply());
	}
	
	/**
	 * Wraps the given function {@code lambda} in another function that 
	 * delegates the first call to the wrapped function and caches the output.
	 * Subsequent calls to the wrapper function will return the cached value
	 * without calling {@code lambda} again.
	 * This version of lazy is <em>not</em> thread safe.
	 * 
	 * @param lambda the lambda, thats output will be cached by 
	 *  the returned function.
	 * @return function, delegating to {@code lambda}, caching 
	 *  its output for further calls.
	 * @see #lazyAtomic(Function0)
	 */
	public static <R> Function0<R> lazy(@NonNull Function0<R> lambda) {
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
	public static <T, R> Function1<T, R> lazy(@NonNull Function1<T, R> lambda) {
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
	 * This function is working thread safe and may block concurrent threads.
	 * The lambda is guaranteed to be evaluated at most once.
	 * 
	 * @param lambda
	 * @return
	 */
	public static <R> Function0<R> lazyAtomic(@NonNull Function0<R> lambda) {
		return new ConcurrentLazyFunction0<R>(Objects.requireNonNull(lambda));
	}

	/**
	 * This function is working thread safe and may block concurrent threads.
	 * The lambda is guaranteed to be evaluated at most once if it evaluates
	 * without an exception. If the lambda throws an exception, the lambda will
	 * be evaluated again, if called a second time.
	 * 
	 * @param lambda
	 * @return
	 */
	public static <T, R> Function1<T, R> lazyAtomic(@NonNull Function1<T, @NonNull R> lambda) {
		return new ConcurrentLazyFunction1<T, R>(Objects.requireNonNull(lambda));
	}
	
	/**
	 * This function is working thread safe and may block concurrent threads.
	 * The lambda is guaranteed to be evaluated at most once if it evaluates
	 * without an exception. If the lambda throws an exception, the lambda will
	 * be evaluated again, if called a second time.
	 * 
	 * @param lambda
	 * @return
	 */
	public static <T, U, R> Function2<T, U, R> lazyAtomic(@NonNull Function2<? super T, ? super U, @NonNull ? extends R> lambda) {
		return new ConcurrentLazyFunction2<T, U, R>(Objects.requireNonNull(lambda));
	}
	
	public static <R> Function0<R> recursive ( Function1<Function0<R>, R> recFunc) {
		class RecFunc implements Function0<R> {
			@Override
			public R apply() {
				return recFunc.apply(this);
			}
		}
		return new RecFunc();
	}
	
	public static <T,R> Function1<T,R> recursive ( Function2<Function1<T,R>, T, R> recFunc) {
		class RecFunc implements Function1<T,R> {
			@Override
			public R apply(T t) {
				return recFunc.apply(this, t);
			}
		}
		return new RecFunc();
	}
	
	public static <T,U,R> Function2<T,U,R> recursive ( Function3<Function2<T,U,R>, T, U, R> recFunc) {
		class RecFunc implements Function2<T,U,R> {
			@Override
			public R apply(T t, U u) {
				return recFunc.apply(this, t, u);
			}
		}
		return new RecFunc();
	}
	
	public static <T,U,V,R> Function3<T,U,V,R> recursive ( Function4<Function3<T,U,V,R>, T, U, V, R> recFunc) {
		class RecFunc implements Function3<T,U,V,R> {
			@Override
			public R apply(T t, U u, V v) {
				return recFunc.apply(this, t, u, v);
			}
		}
		return new RecFunc();
	}
	
	// TODO Function1<T>#withCached(T) => Pair<Function1<T>,ResultType>
	//     Function1<T>#withCached(T, (Function1<T>,ResultType)=>void)
	//          if result already cached, do nothing return self, else cache etc.
	//          warn in documentation that caching a lot of values causes lots of memory copying and overhead
	//          internally maybe ImmutableMap from Guava and on new function use builder().addAll(oldMap).add(newEntry).build()
	// TODO andThenDo Function -> Procedure returns procedure
	// TODO functions with more parameters
	// TODO LazyWeakAtomic: without synchronized but possibly multiple calls of wrapped lambda
	// TODO Function1<T,R>#andThen(Procedure1<R>): (T)=>void // if no amiguity
	// TODO Function1<T,Pair<X,Y>>#andThen(Function2<X,Y,V>) -> Function1<T,V>  // if no ambiguity introduced
	// TODO Function0<Pair<X,Y>>#andThen(Function2<X,Y,V>) -> Function0<V> // if no ambiguity introduced
	// TODO Function2<T,T> till Function6<T,...,T>#spread (Iterable<T>/T[]), throw if too little params. Non type save variant?
}
