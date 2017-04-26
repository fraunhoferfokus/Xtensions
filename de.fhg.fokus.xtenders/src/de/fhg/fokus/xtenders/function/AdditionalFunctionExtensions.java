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
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.xtext.xbase.lib.FunctionExtensions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.Functions.Function3;
import org.eclipse.xtext.xbase.lib.Functions.Function4;
import org.eclipse.xtext.xbase.lib.Functions.Function5;
import org.eclipse.xtext.xbase.lib.Functions.Function6;
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

	
	private AdditionalFunctionExtensions() {
		throw new IllegalStateException("FunctionExtensions is not allowed to be instantiated");
	}

	/**
	 * This extension operator is the "pipe forward" operator. The effect is
	 * that {@code function} will be called with the given {@code value}. The
	 * advantage is that chained nested calls are represented as chains which
	 * can be easier to read. E.g. the nested call {@code c.apply(b.apply(a.apply(val)))} can be
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
		return function.apply(value);
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
	@Inline(value = "$2.apply($1.getKey(), $1.getValue())", imported = FunctionExtensions.class)
	public static <T, V, R> R operator_tripleGreaterThan(@NonNull Pair<T, V> value,
			@NonNull Function2<? super T, ? super V, ? extends R> function) throws NullPointerException {
		return function.apply(value.getKey(), value.getValue());
	}

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
	public static <T, V, R> @NonNull Function1<T, V> operator_doubleGreaterThan (@NonNull Function1<? super T, ? extends R> self,
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
	public static <V, R> @NonNull Function0<V> andThen(@NonNull Function0<? extends R> self,
			@NonNull Function1<? super R, ? extends V> after) {
		return () -> after.apply(self.apply());
	}
	
	////////////////////////////////////////////////////
	// Feature parity to Java 8 functional interfaces //
	////////////////////////////////////////////////////
	
	public static <T> Function1<T, Boolean> and (Function1<T, Boolean> test, Function1<? super T, Boolean> test2) {
		return (t) -> test.apply(t) && test2.apply(t);
	}

	public static <T> Function1<T, Boolean> or (Function1<T, Boolean> test, Function1<? super T, Boolean> test2) {
		return (t) -> test.apply(t) || test2.apply(t);
	}
	
	public static <T> Function1<T, Boolean> negate (Function1<T, Boolean> test, Function1<? super T, Boolean> test2) {
		return (t) -> !test.apply(t);
	}

	
	// TODO andThenDo Function -> Procedure returns procedure
	// TODO Function1<T,R>#andThen(Procedure1<R>): (T)=>void // if no amiguity
	// TODO Function1<T,Pair<X,Y>>#andThen(Function2<X,Y,V>) -> Function1<T,V>  // if no ambiguity introduced
	// TODO Function0<Pair<X,Y>>#andThen(Function2<X,Y,V>) -> Function0<V> // if no ambiguity introduced
	// TODO Function2<T,T> till Function6<T,...,T>#spread (Iterable<T>/T[]), throw if too little params. Non type save variant?
	// TODO Predicate#on -> .then((U)=>U) : Function1<U,U> ???
}
