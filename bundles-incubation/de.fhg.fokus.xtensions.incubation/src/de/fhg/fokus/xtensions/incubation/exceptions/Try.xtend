package de.fhg.fokus.xtensions.incubation.exceptions

import java.util.Optional
import java.util.NoSuchElementException
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*
import java.util.function.Predicate
import static extension java.util.Objects.*
import java.util.stream.Stream
import com.google.common.collect.Iterators
import java.util.Collections
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Iterator

/**
 * Try is a result type of a computation that may either hold a result value (from a successful computation),
 * an empty result (e.g. from a {@code null} result value) or an error (the computation threw).
 * The three possible states are represented by the three subclasses {@link Try.Success}, {@link Try.Empty} and
 * {@link Try.Failure}.<br>
 * Since Xtend does not have checked exceptions, this type can e.g. be used to force a caller of a method
 * to directly handle error cases. However, this API cannot enforce the user to handle a specific set
 * of exception types.<br>
 * To construct a Try value, use one of the factory methods:
 * <ul>
 * 	<li>{@link #tryCall(Function0) tryCall(=&gt;R)</li>
 * 	<li>{@link #tryCall(Object, Function1) tryCall(I, (I)=&gt;R)}</li>
 * 	<li>{@link #tryWith(Function0, Function1) tryWith(=&gt;I, (I)=&gt;R)}</li>
 * 	<li>{@link #tryFlat(Function0) flatTry(=&gtTry&lt;R&gt;)}</li>
 * 	<li>{@link #completed(Object) completed(R)}</li>
 * 	<li>{@link #completedSuccessfully(Object) completedSuccessfully(R)}</li>
 * 	<li>{@link #completedExceptionally(Throwable)}</li>
 * 	<li>{@link #completedEmpty()}</li>
 * </ul>
 * All methods starting with {@code if} react on the result and simply return 
 * the Try on which they were invoked again. If the handlers passed to these methods
 * throw an exception, they well be thrown from the {@code if*} method that was called.<br>
 * <br>
 * The methods starting with {@code then} execute the given handler when the Try represents
 * a successful computation.
 */
abstract class Try<R> implements Iterable<R> {

	private new() {
	}

	/**
	 * Returns an instance of {@link Empty} if {@code result === null},
	 * or an instance of {@link Success} holding the {@code result} value if not.
	 * @param result the result value to be wrapped. May be {@code null}.
	 * @return if parameter {@code result} is {@code null} a {@code Try.Empty}, else a 
	 * 	{@link Try.Success} wrapping {@code result}.
	 */
	static def <R> Try<R> completed(R result) {
		if (result === null) {
			completedEmpty
		} else {
			new Success(result)
		}
	}

	/**
	 * Returns a new instance of {@link Success} wrapping around the given
	 * result. The given {@code result} must not be {@code null}. If the result
	 * may be {@code null}, consider using factory method {@link Try#completed(Object) completed}
	 * instead.
	 * @param result The result value to wrap into a {@code Success} instance. Must not be {@code null}.
	 * @return a {@code Success} wrapping the given {@code result} parameter.
	 * @throws NullPointerException if {@code result === null}.
	 */
	static def <R> Success<R> completedSuccessfully(R result) throws NullPointerException {
		new Success(result.requireNonNull)
	}

	/**
	 * Returns an instance of {@link Try.Empty}, representing a successful, but empty result.
	 * @return an instance of {@link Try.Empty}
	 */
	def static <R> Empty<R> completedEmpty() {
		Empty.INSTANCE as Empty<?> as Empty<R>
	}

	/**
	 * Returns an instance of {@link Failure} wrapping around the {@code Throwable t} 
	 * which is the cause of failure.
	 * @param t error that is wrapped into the returned {@link Failure}. Must not be {@code null}.
	 * @return instance of {@link Failure} wrapping around parameter {@code t} 
	 * @throws NullPointerException if {@code t} is {@code null}
	 */
	def static <R> Failure<R> completedExceptionally(Throwable t) throws NullPointerException {
		new Failure(t.requireNonNull("Throwable t must not be null"))
	}

	/**
	 * Executes the given {@code provider}, if it throws an exception it will be wrapped
	 * into a {@code Try.Failure}. If it computes normally and returns {@code null} a {@code Try.Empty}
	 * will be returned, otherwise a {@code Try.Success} will be returned wrapping the result value.
	 * 
	 * @param provider function to be called, and that's return value or thrown exception will be wrapped
	 *  and returned. Must not be {@code null}.
	 * @return {@code Try.Failure} if {@code provider} throws an exception which will be wrapped into the failure; {@code Try.Empty} if {@code provider}
	 * 	returns {@code null}; {@code Try.Success} if provider returns {@code provider} returns a value {@code !== null} which will
	 * 	be wrapped into the success.
	 * @throws NullPointerException if {@code provider} is {@code null}
	 */
	def static <R> Try<R> tryCall(=>R provider) throws NullPointerException {
		provider.requireNonNull("provider must not be null")
		try {
			val result = provider.apply
			completed(result)
		} catch (Throwable e) {
			completedExceptionally(e)
		}
	}

	/**
	 * This method is a version of {@link #tryCall(Function0) tryCall(=>R)} allowing to
	 * pass a context object into the {@code provider}, which can be used to get more
	 * performance, avoiding capturing lambdas. But it can also be used similar to the 
	 * {@code =>} operator to group calls to a single context object.
	 * 
	 * @param input element that will be passed to {@code provider}
	 * @param provider function to be called with {@code input}, the result
	 *  of this function will be wrapped in a {@code Try} and returned.
	 * @return {@code Try.Failure} if {@code provider} throws an exception which will be wrapped into the failure; {@code Try.Empty} if {@code provider}
	 * 	returns {@code null}; {@code Try.Success} if provider returns {@code provider} returns a value {@code !== null} which will
	 * 	be wrapped into the success.
	 * @see #tryCall(Function0)
	 * @throws NullPointerException if {@code provider} is {@code null}
	 */
	def static <I, R> Try<R> tryCall(I input, (I)=>R provider) {
		provider.requireNonNull("provider must not be null")
		try {
			val result = provider.apply(input)
			completed(result)
		} catch (Throwable e) {
			completedExceptionally(e)
		}
	}

	/**
	 * Executes the given {@code provider}, if it throws an exception it will be wrapped
	 * into a {@code Try.Failure}. If it computes normally and the returned {@code Optional} has
	 * a value present, this value will be wrapped into a {@code Try.Success} and returned, otherwise
	 * returns a {@code Try.Empty}.
	 * 
	 * @param provider function to be invoked, and that's result will be wrapped into a {@code Try}. Must not be {@code null}.
	 * @return {@code Try.Failure} if {@code provider} throws an exception which will be wrapped into the failure; {@code Try.Success} 
	 * if {@code provider} returns an {@code Optional} with a value present, the returned value will wrap around the value held by the 
	 * {@code Optional}; {@code Try.Empty} otherwise.
	 * @throws NullPointerException if {@code provider} is {@code null}
	 */
	def static <R> Try<R> tryOptional(=>Optional<R> provider) {
		provider.requireNonNull("provider must not be null")
		try {
			val result = provider.apply
			if (result !== null && result.present) {
				completed(result.get)
			} else {
				completedEmpty
			}
		} catch (Throwable e) {
			completedExceptionally(e)
		}
	}

	/**
	 * Executes the given {@code provider}, if it throws an exception it will be wrapped
	 * into a {@code Try.Failure}. If it computes normally, the result of the call to 
	 * {@code provider} will be returned.
	 * 
	 * @param provider function to be invoked, and that's result will be returned. If it throws an exception,
	 *  it will be caught, wrapped into a {@code Try.Failure} and returned. {@code provider} must not be {@code null}.
	 * @return result of call to {@code provider}. If {@code provider} throws, a {@code Try.Failure} wrapping the 
	 *  caught {@code Throwable}.
	 * @throws NullPointerException if {@code provider} is {@code null}
	 */
	def static <R> Try<R> tryFlat(=>Try<R> provider) {
		provider.requireNonNull("provider must not be null")
		try {
			provider.apply
		} catch (Throwable e) {
			completedExceptionally(e)
		}
	}

	/**
	 * This method calls the provided {@code provider} with the {@code AutoCloseable} resource 
	 * provided by {@code resourceProvider}.<br> 
	 * If the {@code resourceProvider} throws an exception,
	 * the returned {@code Try} will be a failure wrapping the exception. In case it provides a non-{@code null}
	 * reference, the resource will be closed before this method ends. If the {@code provider}
	 * returns a non-{@code null} reference, this method will return a {@code Try.Success} wrapping
	 * the result. If the {@code provider} returns a {@code null}, this method returns a {@code Try.Empty}.
	 * If the {@code provider} throws an exception, this method will return a {@code Try.Failure} wrapping
	 * the thrown exception.
	 * 
	 * @param resourceProvider provides a resource to be passed to {@code provider}. The provided resource
	 *  will be closed after calling {@code provider}, if {@code resourceProvider} does not throw an 
	 *  exception and returns a non-{@code null} reference. Must not be {@code null}.
	 * @param provider will be called by this method with the resource provided by {@code resourceProvider}.
	 *  The outcome of the call to {@code provider} will be wrapped into a {@code Try} and returned by this method.
	 *  Must not be {@code null}.
	 * @return {@code Try.Failure} if {@code resourceProvider} or {@code provider} throws an exception;
	 *  {@code Try.Empty} if {@code provider} returns a [@code null} reference; otherwise a {@code Try.Success}
	 *  is returned wrapping the result of {@code provider}
	 * @throws NullPointerException if {@code resourceProvider} or {@code provider} is {@code null}
	 */
	def static <I extends AutoCloseable, R> Try<R> tryWith(=>I resourceProvider,
		(I)=>R provider) throws NullPointerException {
		resourceProvider.requireNonNull("resourceProvider must not be null")
		provider.requireNonNull("provider must not be null")
		try {
			val resource = resourceProvider.apply
			try {
				val result = provider.apply(resource);
				completed(result)
			} finally {
				if (resource !== null) {
					resource.close
				}
			}
		} catch (Throwable e) {
			completedExceptionally(e);
		}
	}

	/**
	 * Recovers exceptions of class {@code E}. If recovery fails with
	 * exception the returned Try will hold the exception
	 */
	abstract def <E extends Throwable> Try<R> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery)

	abstract def <E extends Throwable> Try<R> tryRecoverFailure(Class<? extends E> exceptionType,
		Class<? extends E> exceptionType2, (E)=>R recovery)

	abstract def <E extends Throwable, Exception> RecoveryStarter<E, R> tryRecoverFailure(
		Class<? extends E>... exceptionType)

	/**
	 * Recovers exceptions
	 */
	abstract def Try<R> tryRecoverFailure((Throwable)=>R recovery)

	abstract def Try<R> tryRecoverEmpty(=>R recovery)

	/**
	 * If invoked on a {@link Try.Empty} will return a {@code Try} wrapping
	 * the given {@code recovery}. Note that if {@code recovery} is {@code null}
	 * returns an {@code Try.Empty}, if not a {@code Try.Success} wrapping the
	 * given {@code recovery}. If invoked on a failure or success, this method 
	 * returns the instance the method was invoked on.
	 * @param recovery the element to be wrapped in the returned {@code Try}
	 *  if this {@code Try} is empty.
	 * @return this {@code Try} if it is success or failure. If this {@code Try}
	 *  is empty it will return a {@code Try} wrapping the given {@code recovery}
	 *  value. Note that if {@code recovery} is {@code null} a {@code Try.Empty} 
	 *  will be returned, otherwise a {@code Try.Succes} will be returned wrapping
	 *  {@code recovery}
	 */
	abstract def Try<R> recoverEmpty(R recovery)

	/**
	 * Recovers exceptions or {@code null} result values with value {@code recovery}.
	 * If recovery fails with an exception a failed {@code Try} is returned.
	 * @param recovery
	 */
	abstract def Try<R> tryRecover(=>R recovery)

	/**
	 * Recovers exceptions or {@code null} result values with value {@code recovery}.
	 * @return if this is a {@code Try.Success} returns the wrapped value, otherwise
	 *  returns the given {@code recovery}
	 */
	abstract def R recover(R recovery)

	/**
	 * Provides exception to {@code handler} if this {@code Try} failed with
	 * an exception. Returns this {@code Try} unchanged. This can e.g. be handy for
	 * logging an exception.
	 * @param handler the callback to be invoked with the wrapped exception if this {@code Try}
	 *  is a {@link Try.Failure}.
	 * @return same instance as {@code this}.
	 * @throws NullPointerException if {@code handler} is {@code null}
	 */
	abstract def Try<R> ifFailure((Throwable)=>void handler)

	/**
	 * Provides exception of type {@code E} to {@code handler} if this {@code Try} failed with
	 * an exception of type {@code E} and the exception is instance of {@code exceptionType}. 
	 * Returns this {@code Try} unchanged. This can e.g. be handy for logging an exception.
	 * @param exceptionType type the wrapped exception is tested to be instance of
	 * @param handler the callback to be invoked with the wrapped exception if this {@code Try}
	 *  is a {@link Try.Failure} and the exception is instance of {@code exceptionType}
	 * @return same instance as {@code this}.
	 * @throws NullPointerException if {@code exceptionType} or {@code handler} is {@code null}
	 */
	abstract def <E extends Throwable> Try<R> ifFailure(Class<E> exceptionType, (E)=>void handler)

	/**
	 * Provides exception of type {@code E} to {@code handler} if this {@code Try} failed with
	 * an exception of type {@code E} and the exception is instance of {@code exceptionType} or {@code exceptionType2}.
	 * Returns this {@code Try} unchanged. This can e.g. be handy for logging an exception.
	 * @param exceptionType type the wrapped exception is tested to be instance of
	 * @param exceptionType2 type the wrapped exception is tested to be instance of
	 * @param handler the callback to be invoked with the wrapped exception if this {@code Try}
	 *  is a {@link Try.Failure} and the exception is instance of {@code exceptionType} or instance
	 *  of {@code exceptionType2}
	 * @return same instance as {@code this}.
	 * @throws NullPointerException if {@code exceptionType}, {@code exceptionType2} or {@code handler} is {@code null}
	 */
	abstract def <E extends Throwable> Try<R> ifFailure(Class<? extends E> exceptionType,
		Class<? extends E> exceptionType2, (E)=>void handler)

	/**
	 * Provides exception of type {@code E} to {@code handler} if this {@code Try} failed with
	 * an exception of type {@code E} and the exception is instance of any exception in {@code exceptionTypes}.
	 * Returns this {@code Try} unchanged. This can e.g. be handy for logging an exception.
	 * @param exceptionTypes types the wrapped exception is tested to be instance of
	 * @param handler the callback to be invoked with the wrapped exception if this {@code Try}
	 *  is a {@link Try.Failure} and the exception is instance of any type in {@code exceptionTypes}
	 * @return same instance as {@code this}.
	 * @throws NullPointerException if {@code exceptionTypes}, any value in {@code exceptionTypes}, or {@code handler} is {@code null}
	 */
	abstract def <E extends Throwable> FailureHandlerStarter<E, R> ifFailure(Class<? extends E>... exceptionTypes)

	/**
	 * Calls the given {@code handler} with the result value if the Try 
	 * completed with a non {@code null} result value.
	 * @param handler the callback to be called if this is an instance of {@code Try.Success}
	 *  with the wrapped successful value as the parameter
	 * @return same instance as {@code this}
	 * @throws NullPointerException if {@code handler} is {@code null}
	 */
	abstract def Try<R> ifSuccess((R)=>void handler)

	/**
	 * If operation was successful but returned {@code null} value, the given 
	 * {@code handler} will be called, otherwise the {@code handler} will not be called.
	 * @param handler the callback to be called if this is an instance of {@code Try.Empty}
	 * @return same instance as {@code this}
	 * @throws NullPointerException if {@code handler} is {@code null}
	 */
	abstract def Try<R> ifEmpty(=>void handler)

	/**
	 * Calls {@code action} with the result of this try, if the Try
	 * holds a successful result and is not {@code null}.
	 * @param action operation to be performed if this Try holds a result that
	 *  is not {@code null}.
	 * @return Try wrapping the result of the {@code action} if it completes successful,
	 *   or holding an exception if the operation throws 
	 */
	abstract def <U> Try<U> thenTry((R)=>U action)

	abstract def <U> Try<U> thenTryOptional((R)=>Optional<U> action)

	abstract def <U, I extends AutoCloseable> Try<U> thenTryWith(()=>I resourceProducer, (I, R)=>U action)

	abstract def <U> Try<U> thenTryFlat((R)=>Try<U> action)

	/**
	 * Returns {@code true} if the {@code Try} is empty (instance of {@link Empty}) and {@code false} otherwise.
	 * @return {@code true} if the {@code Try} is empty and {@code false} otherwise.
	 */
	abstract def boolean isEmpty()

	/**
	 * Returns {@code true} if the {@code Try} is a failure (instance of {@link Failure}) and {@code false} otherwise.
	 * @return {@code true} if the {@code Try} is empty and {@code false} otherwise.
	 */
	abstract def boolean isFailure()

	/**
	 * Returns {@code true} if the {@code Try} is a success (instance of {@link Success}) and {@code false} otherwise.
	 * @return {@code true} if the {@code Try} is a success and {@code false} otherwise.
	 */
	abstract def boolean isSuccessful()

	/**
	 * Should mapper throw an exception, the returned {@code Try} will be a failure
	 * wrapping a {@link MapExceptionFailure}, which holds the thrown exception as 
	 * the cause and provides a reference to the exception to be mapped by {@code mapper}.
	 */
	abstract def Try<R> mapException((Throwable)=>Throwable mapper)

	/**
	 * If this {@code Try} is a {@link Try.Success} the contained value
	 * will be passed to {@code test}. If the predicate returns {@code true}
	 * this {@code Try} will be returned unchanged. If the predicate returns
	 * {@code false}, an instance of {@code Try.Empty} will be returned.
	 * If this {@code Try} is not a {@link Try.Success}, it will be returned
	 * unchanged.
	 * 
	 * @param test the predicate used to filter this {@code Try} if this is a {@link Try.Success}.
	 *  Must not be {@code null}.
	 * @return the filtered version of this {@code Try} if it is a {@link Try.Success}
	 *  otherwise returns this {@code Try}.
	 * @throws NullPointerException if {@code test} is {@code null}.
	 */
	abstract def Try<R> filterSuccess(Predicate<R> test)

	/**
	 * If this {@code Try} is a {@link Try.Success} the contained value
	 * will be checked to be instance of {@code clazz}. If the value is instance of {@code clazz}
	 * this {@code Try} will be returned as a {@code Try<U>}. If not, 
	 * an instance of {@code Try.Empty} will be returned.
	 * If this {@code Try} is not a {@link Try.Success}, it will be returned
	 * unchanged.
	 * 
	 * @param clazz The wrapped value of {@code Try.Success} instances will be filtered 
	 *  by checking if it is instance of {@code clazz}. Must not be {@code null}.
	 * @return the filtered version of this {@code Try} if it is a {@link Try.Success}
	 *  otherwise returns this {@code Try}.
	 * @throws NullPointerException if {@code test} is {@code null}.
	 */
	abstract def <U> Try<U> filterSuccess(Class<U> clazz)

	abstract def <U> U transform((R)=>U resultTransformer, (Throwable)=>U exceptionTranformer, =>U emptyTransformer)

	/**
	 * Returns empty optional if Try completed exceptionally or with a
	 * {@code null} value. Otherwise returns an optional with the computed
	 * result value present.
	 * @return an {@code Optional} holding the captured success value, if this 
	 *  {@code Try} is a {@link Try.Success}, or an empty {@code Optional}
	 *  if this {@code Try} is no {@code Try.Success}.
	 */
	abstract def Optional<R> getResult()

	/**
	 * Returns an empty stream if Try completed exceptionally or with 
	 * a {@code null} value. Otherwise returns a stream with the completed
	 * result value.
	 * @return an empty stream if this is empty or a failure, if this {@code Try}
	 * is a success, the returned stream provides the wrapped success element.
	 */
	abstract def Stream<R> stream();

	/**
	 * Returns an iterator that holds an element, if this {@code Try} was completed
	 * successfully, otherwise returns an empty iterator.
	 * @return iterator that holds an element, if this is a {@code Try.Success}, 
	 *  otherwise an empty iterator.
	 */
	override Iterator<R> iterator();

	/**
	 * Returns result value on successful computation (even when the result
	 * value was {@code null}) or {@code null} if an exception was thrown.
	 * @return {@code null} if the result is no success, otherwise the value
	 *  wrapped in the {@link Try.Success}.
	 */
	abstract def R getOrNull()

	/**
	 * Returns result value on successful computation with a result value was 
	 * not {@code null}. If the the operation failed with an exception, this exception
	 * will be re-thrown. If the result was {@code null} a {@link NoSuchElementException}
	 * will be thrown.
	 * @return the value wrapped in the {@link Try.Success}.
	 * @throws NoSuchElementException if this object is instance of {@link Try.Empty} 
	 */
	abstract def R getOrThrow() throws NoSuchElementException

	/**
	 * Returns result value on successful computation with a result value was 
	 * not {@code null}. If the the operation failed with an exception, this exception
	 * will be re-thrown. If the result was {@code null} a the exception provided
	 * by {@code exceptionProvider} will be thrown.
	 * @param exceptionProvider provides the exception to be thrown if this element is no {@link Try.Success}.
	 * @param <E> Type of exception to be thrown if this is a {@link Try.Empty}
	 * @return the value wrapped in the {@link Try.Success}.
	 * @throws E if this Try is empty
	 */
	abstract def <E extends Exception> R getOrThrow(=>E exceptionProvider) throws E

	/**
	 * Returns empty optional if Try completed successfully (holding a result) or with a
	 * {@code null} value. Otherwise returns an optional with the exception captured
	 * in this exceptionally completed {@code Try}.
	 * @return an {@code Optional} holding the captured exception, if this 
	 *  {@code Try} is a {@link Try.Failure}, or an empty {@code Optional}
	 *  if this {@code Try} is no {@code Try.Failure}.
	 */
	abstract def Optional<Throwable> getException()

	/**
	 * Returns given {@code Try<T>} as {@code Try<U>} where {@code U} is supertype of {@code T}.
	 * @see Try#upcast(Success)
	 * @see Try#upcast(Empty)
	 * @see Try#upcast(Failure)
	 */
	static def <U, R extends U> Try<U> upcast(Try<R> t) {
		t as Try<?> as Try<U>
	}

	/**
	 * Returns given {@code Success<T>} as {@code Success<U>} where {@code U} is supertype of {@code T}.
	 * @see Try#upcast(Try)
	 * @see Try#upcast(Empty)
	 * @see Try#upcast(Failure)
	 */
	static def <U, R extends U> Success<U> upcast(Success<R> t) {
		t as Success<?> as Success<U>
	}

	/**
	 * Returns given {@code Empty<T>} as {@code Empty<U>} where {@code U} is supertype of {@code T}.
	 * @see Try#upcast(Success)
	 * @see Try#upcast(Try)
	 * @see Try#upcast(Failure)
	 */
	static def <U, R extends U> Empty<U> upcast(Empty<R> t) {
		t as Empty<?> as Empty<U>
	}

	/**
	 * Returns given {@code Failure<T>} as {@code Failure<U>} where {@code U} is supertype of {@code T}.
	 * @see Try#upcast(Success)
	 * @see Try#upcast(Empty)
	 * @see Try#upcast(Try)
	 */
	static def <U, R extends U> Failure<U> upcast(Failure<R> t) {
		t as Failure<?> as Failure<U>
	}

	final static class Success<R> extends Try<R> {

		val R result

		private new(R result) {
			this.result = result
		}

		/**
		 * Tests if the wrapped value is instance of the given class {@code clazz}.
		 * @param clazz the class used to test if the value is instance of.
		 * @param <U> type the wrapped value is tested to be instance of
		 * @return {@code true} if the wrapped value is instance of {@code clazz}
		 */
		def <U> boolean is(Class<U> clazz) {
			clazz.isInstance(result)
		}

		/**
		 * Calls the given {@code consumer} if the wrapped value is instance of 
		 * the given Class {@code clazz}.
		 * @param clazz 
		 * @param consumer 
		 * @param <U> 
		 * @return 
		 * 
		 */
		def <U> Success<R> ifInstanceOf(Class<U> clazz, (U)=>void consumer) {
			if (clazz.isInstance(result)) {
				consumer.apply(clazz.cast(result))
			}
			this
		}

		/**
		 * Returns the success value wrapped into this {@code Try.Success} instance.
		 * @return returns the wrapped success value
		 */
		def R get() {
			result
		}

		override <E extends Throwable> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			this
		}

		override <E extends Throwable> tryRecoverFailure(Class<? extends E> exceptionType,
			Class<? extends E> exceptionType2, (E)=>R recovery) {
			this
		}

		override <E extends Throwable, Exception> tryRecoverFailure(Class<? extends E>... exceptionType) {
			val result = this;
			[result]
		}

		override tryRecoverFailure((Throwable)=>R recovery) {
			this
		}

		override Try<R> tryRecoverEmpty(()=>R recovery) {
			this
		}

		override Try<R> recoverEmpty(R recovery) {
			this
		}

		override tryRecover(()=>R recovery) {
			this
		}

		override recover(R recovery) {
			result
		}

		override <E extends Throwable> ifFailure(Class<E> exceptionType, (E)=>void handler) {
			exceptionType.requireNonNull("exceptionType must not be null")
			handler.requireNonNull("handler must not be null")
			// no exception to handle
			this
		}

		override <E extends Throwable> ifFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2,
			(E)=>void handler) {
			exceptionType.requireNonNull("exceptionType must not be null")
			exceptionType2.requireNonNull("exceptionType2 must not be null")
			handler.requireNonNull("handler must not be null")
			// no exception to handle
			this
		}

		override <E extends Throwable> ifFailure(Class<? extends E>... exceptionTypes) {
			[this]
		}

		override ifFailure((Throwable)=>void handler) {
			handler.requireNonNull("handler must not be null")
			// no exception to handle
			this
		}

		override ifSuccess((R)=>void handler) {
			handler.requireNonNull("handler must not be null")
			handler.apply(result)
			this
		}

		override ifEmpty(()=>void handler) {
			handler.requireNonNull("handler must not be null")
			// not empty
			this
		}

		override <U> thenTry((R)=>U action) {
			tryCall [
				action.apply(result)
			]
		}

		override <U, I extends AutoCloseable> thenTryWith(()=>I resourceProducer, (I, R)=>U action) {
			tryWith(resourceProducer) [ res |
				action.apply(res, result)
			]
		}

		override <U> thenTryFlat((R)=>Try<U> action) {
			tryFlat [
				action.apply(result)
			]
		}

		override isEmpty() {
			false
		}

		override isFailure() {
			false
		}

		override isSuccessful() {
			true
		}

		override mapException((Throwable)=>Throwable mapper) {
			// nothing to map
			this
		}

		override filterSuccess(Predicate<R> test) {
			test.requireNonNull("test must not be null")
			if (test.test(result)) {
				this
			} else {
				completedEmpty
			}
		}

		override <U> filterSuccess(Class<U> clazz) {
			if (clazz.isInstance(result)) {
				this as Try<?> as Try<U>
			} else {
				completedEmpty
			}
		}

		override <U> transform((R)=>U resultTransformer, (Throwable)=>U exceptionTranformer, ()=>U emtpyTransformer) {
			resultTransformer.apply(result)
		}

		override getResult() {
			some(result)
		}

		override stream() {
			Stream.of(result)
		}

		override getOrNull() {
			result
		}

		override getOrThrow() throws NoSuchElementException {
			result
		}

		override <E extends Exception> getOrThrow(=>E exceptionProvider) throws E {
			exceptionProvider.requireNonNull
			result
		}

		override getException() {
			none
		}

		override <U> thenTryOptional((R)=>Optional<U> action) {
			tryOptional[|action.apply(result)]
		}

		override iterator() {
			Iterators.forArray(result)
		}

	}

	final static class Empty<R> extends Try<R> {
		static val Empty<?> INSTANCE = new Empty

		private def <U> Empty<U> cast() {
			this as Empty as Empty<U>
		}

		override <E extends Throwable> Empty<R> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			// No exception to recover from
			this
		}

		override <E extends Throwable> Empty<R> tryRecoverFailure(Class<? extends E> exceptionType,
			Class<? extends E> exceptionType2, (E)=>R recovery) {
			this
		}

		override <E extends Throwable, Exception> tryRecoverFailure(Class<? extends E>... exceptionType) {
			val result = this;
			[result]
		}

		override Empty<R> tryRecoverFailure((Throwable)=>R recovery) {
			// No exception to recover from
			this
		}

		override Try<R> tryRecoverEmpty(()=>R recovery) {
			tryCall(recovery)
		}

		override Try<R> recoverEmpty(R recovery) {
			completed(recovery)
		}

		override Try<R> tryRecover(()=>R recovery) {
			tryCall(recovery)
		}

		override R recover(R recovery) {
			recovery
		}

		override <E extends Throwable> Empty<R> ifFailure(Class<E> exceptionType, (E)=>void handler) {
			exceptionType.requireNonNull("exceptionType must not be null")
			handler.requireNonNull("handler must not be null")
			// no exception
			this
		}

		override <E extends Throwable> Empty<R> ifFailure(Class<? extends E> exceptionType,
			Class<? extends E> exceptionType2, (E)=>void handler) {
			exceptionType.requireNonNull("exceptionType must not be null")
			exceptionType2.requireNonNull("exceptionType2 must not be null")
			handler.requireNonNull("handler must not be null")
			this
		}

		override <E extends Throwable> ifFailure(Class<? extends E>... exceptionTypes) {
			[this]
		}

		override Empty<R> ifFailure((Throwable)=>void handler) {
			handler.requireNonNull("handler must not be null")
			// no exception
			this
		}

		override Empty<R> ifSuccess((R)=>void handler) {
			handler.requireNonNull("handler must not be null")
			// no result
			this
		}

		override Empty<R> ifEmpty(()=>void handler) {
			handler.requireNonNull("handler must not be null")
			handler.apply
			this
		}

		override <U> Empty<U> thenTry((R)=>U action) {
			cast
		}

		override <U, I extends AutoCloseable> Empty<U> thenTryWith(()=>I resourceProducer, (I, R)=>U action) {
			cast
		}

		override <U> Empty<U> thenTryFlat((R)=>Try<U> action) {
			cast
		}

		override isEmpty() {
			true
		}

		override isFailure() {
			false
		}

		override isSuccessful() {
			false
		}

		override Empty<R> mapException((Throwable)=>Throwable mapper) {
			this
		}

		override Empty<R> filterSuccess(Predicate<R> test) {
			test.requireNonNull("predicate must not be null")
			this
		}

		override <U> Empty<U> filterSuccess(Class<U> clazz) {
			clazz.requireNonNull("clazz must not be null")
			cast
		}

		override <U> U transform((R)=>U resultTransformer, (Throwable)=>U exceptionTranformer, ()=>U emptyTransformer) {
			emptyTransformer.apply
		}

		override getResult() {
			none
		}

		override stream() {
			Stream.empty
		}

		override R getOrNull() {
			null
		}

		override getOrThrow() throws NoSuchElementException {
			throw new NoSuchElementException("Empty result has no result value.")
		}

		override <E extends Exception> getOrThrow(()=>E exceptionProvider) throws E {
			throw exceptionProvider.apply
		}

		override getException() {
			none
		}

		override <U> Empty<U> thenTryOptional((R)=>Optional<U> action) {
			cast
		}

		override iterator() {
			Collections.emptyIterator
		}

	}

	final static class Failure<R> extends Try<R> {
		val Throwable e

		private new(Throwable e) {
			this.e = e
		}

		private def <U> cast() {
			this as Failure<?> as Failure<U>
		}

		def Throwable get() {
			e
		}

		def boolean is(Class<? extends Throwable> exceptionType) {
			exceptionType.isInstance(e)
		}

		override <E extends Throwable> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			if (exceptionType.isInstance(e)) {
				tryCall [
					recovery.apply(e as E)
				]
			} else {
				this
			}
		}

		override <E extends Throwable> tryRecoverFailure(Class<? extends E> exceptionType,
			Class<? extends E> exceptionType2, (E)=>R recovery) {
			if (exceptionType.isInstance(e) || exceptionType2.isInstance(e)) {
				tryCall [
					recovery.apply(e as E)
				]
			} else {
				this
			}
		}

		override tryRecoverFailure((Throwable)=>R recovery) {
			tryCall [
				recovery.apply(e)
			]
		}

		override <E extends Throwable, Exception> tryRecoverFailure(Class<? extends E>... exceptionType) {
			[ recoveryFunc |
				if (exceptionType.exists[isInstance(e)]) {
					Try.tryCall [
						recoveryFunc.apply(e as E)
					]
				}
			]
		}

		override <E extends Throwable> Failure<R> ifFailure(Class<E> exceptionType, (E)=>void handler) {
			exceptionType.requireNonNull("exceptionType must not be null")
			handler.requireNonNull("handler must not be null")
			if (exceptionType.isInstance(e)) {
				handler.apply(e as E)
			}
			this
		}

		override <E extends Throwable> Failure<R> ifFailure(Class<? extends E> exceptionType,
			Class<? extends E> exceptionType2, (E)=>void handler) {
			exceptionType.requireNonNull("exceptionType must not be null")
			exceptionType2.requireNonNull("exceptionType2 must not be null")
			handler.requireNonNull("handler must not be null")
			if (exceptionType.isInstance(e) || exceptionType2.isInstance(e)) {
				handler.apply(e as E)
			}
			this
		}

		override <E extends Throwable> ifFailure(Class<? extends E>... exceptionTypes) {
			exceptionTypes.requireNonNull("exceptionTypes must not be null");
			[
				for (clazz : exceptionTypes) {
					if (clazz.isInstance(e)) {
						it.apply(e as E)
						// Xtend does not feature a "break" keyword
						return this
					}
				}
				this
			]
		}

		override Failure<R> ifFailure((Throwable)=>void handler) {
			handler.requireNonNull("handler must not be null")
			handler.apply(e)
			this
		}

		override Failure<R> ifEmpty(()=>void handler) {
			handler.requireNonNull("handler must not be null")
			// not empty result
			this
		}

		override Failure<R> ifSuccess((R)=>void handler) {
			handler.requireNonNull("handler must not be null")
			// no result
			this
		}

		override <U> Failure<U> thenTry((R)=>U action) {
			// no result
			cast
		}

		override <U, I extends AutoCloseable> Failure<U> thenTryWith(()=>I resourceProducer, (I, R)=>U action) {
			// no result
			cast
		}

		override <U> Failure<U> thenTryFlat((R)=>Try<U> action) {
			// no result
			cast
		}

		override isEmpty() {
			false
		}

		override isFailure() {
			true
		}

		override isSuccessful() {
			false
		}

		override mapException((Throwable)=>Throwable mapper) {
			completedExceptionally(mapper.apply(e))
		}

		override Failure<R> filterSuccess(Predicate<R> test) {
			test.requireNonNull("test must not be null")
			this
		}

		override <U> Failure<U> filterSuccess(Class<U> clazz) {
			clazz.requireNonNull("clazz must not be null")
			cast
		}

		override <U> transform((R)=>U resultTransformer, (Throwable)=>U exceptionTranformer, ()=>U emptyTransformer) {
			exceptionTranformer.apply(e)
		}

		override getResult() {
			none
		}

		override stream() {
			Stream.empty
		}

		override getOrNull() {
			null
		}

		override getOrThrow() throws NoSuchElementException {
			throw e
		}

		override <E extends Exception> getOrThrow(=>E exceptionProvider) throws E {
			exceptionProvider.requireNonNull("exceptionProvider must not be null")
			throw e
		}

		override getException() {
			some(e)
		}

		override Failure<R> tryRecoverEmpty(()=>R recovery) {
			this
		}

		override Failure<R> recoverEmpty(R recovery) {
			this
		}

		override tryRecover(()=>R recovery) {
			tryCall(recovery)
		}

		override recover(R recovery) {
			recovery
		}

		override <U> thenTryOptional((R)=>Optional<U> action) {
			cast
		}

		override iterator() {
			Collections.emptyIterator
		}

	}
}

/**
 * For performance reasons this Exception does not have a stack trace.
 * The stack trace of the of the {@link MapExceptionFailure#getCause() cause}
 * should be more meaningful anyway. 
 */
@Accessors(PUBLIC_GETTER)
class MapExceptionFailure extends Exception {
	val Throwable toBeMapped

	/**
	 * @param rootCause
	 * @param toBeMapped
	 */
	new(Throwable rootCause, Throwable toBeMapped) {
		super(
			"Failure during mapping exceptions in Try",
			rootCause,
			true, // enableSuppression
			false // writableStackTrace
		)
		this.toBeMapped = toBeMapped
	}
}

@FunctionalInterface
interface FailureHandlerStarter<E extends Throwable, T> {
	def Try<T> then((E)=>void handler)
}

@FunctionalInterface
interface RecoveryStarter<E extends Throwable, R> {
	def Try<R> with((E)=>R recovery)
}
