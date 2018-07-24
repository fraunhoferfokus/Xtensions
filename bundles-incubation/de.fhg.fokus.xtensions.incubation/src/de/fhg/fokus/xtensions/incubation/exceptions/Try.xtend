package de.fhg.fokus.xtensions.incubation.exceptions

import java.util.Optional
import java.util.NoSuchElementException
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*
import java.util.function.Predicate
import static extension java.util.Objects.*
import java.util.stream.Stream

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
 * 	<li>{@link #doTry(Function0) doTry(()=>R)</li>
 * 	<li>{@link #doTry(Object, Function1) doTry(I, (I)=>R)}</li>
 * 	<li>{@link #tryWith(Function0, Function1) tryWith(()=>I, (I)=>R)}</li>
 * 	<li>flatTry</li>
 * 	<li>completedSuccessfully</li>
 * 	<li>completedExceptionally</li>
 * </ul>
 * All methods starting with {@code if} react on the result and simply return 
 * the Try on which they were invoked again. If the handlers passed to these methods
 * throw an exception, they well be thrown from the {@code if*} method that was called.<br>
 * <br>
 * The methods starting with {@code then} execute the given handler when the Try represents
 * a successful computation.
 */
abstract class Try<R> {

	private new() {
	}
	
	
	// TODO: maybe def static <C, I extends AutoCloseable, R> tryWith(C context, ()=>I resourceProvider, (C,I)=>R provider)
	// TODO: test if the following only returning Empty or Failure make sense: 
	//     * static def Try<Void> doTry(()=>void action)
	//     * static def <I> Try<Void> doTry(I input, (I)=>void provider)
	//     * static def <I extends AutoCloseable> Try<Void> tryWith(()=>I resourceProvider, (I)=>void provider)
	// TODO  static <I extends AutoCloseable, R> Try<R> flatTryWith(()=>I resourceProvider, (I)=>Try<R> provider) 

	/**
	 * Returns an instance of {@link Empty} if {@code result === null},
	 * or an instance of {@link Success} holding the {@code result} value if not.
	 * @param result the result value to be wrapped. May be {@code null}.
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
	 * @throws NullPointerException if {@code result === null}.
	 */
	static def <R> Success<R> completedSuccessfully(R result) throws NullPointerException {
		new Success(result.requireNonNull)
	}

	/**
	 * Returns an instance of {@link Empty}, representing a successful, but empty result.
	 */
	def static <R> Empty<R> completedEmpty() {
		Empty.INSTANCE as Empty<?> as Empty<R>
	}

	/**
	 * Returns an instance of {@link Failure} wrapping around the {@code Throwable t} 
	 * which is the cause of failure.
	 */
	def static <R> Failure<R> completedExceptionally(Throwable t) throws NullPointerException {
		new Failure(t.requireNonNull)
	}

	def static <I extends AutoCloseable, R> Try<R> tryWith(()=>I resourceProvider, (I)=>R provider) {
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

	def static <R> Try<R> doTry(()=>R provider) {
		try {
			val result = provider.apply
			completed(result)
		} catch (Throwable e) {
			completedExceptionally(e)
		}
	}

	def static <R> Try<R> tryOptional(()=>Optional<R> provider) {
		try {
			val result = provider.apply
			if (result.present) {
				completed(result.get)
			} else {
				completedEmpty
			}
		} catch (Throwable e) {
			completedExceptionally(e)
		}
	}

	def static <I, R> Try<R> doTry(I input, (I)=>R provider) {
		try {
			val result = provider.apply(input)
			completed(result)
		} catch (Throwable e) {
			completedExceptionally(e)
		}
	}

	def static <R> Try<R> flatTry(()=>Try<R> provider) {
		try {
			provider.apply
		} catch (Throwable e) {
			completedExceptionally(e)
		}
	}
	
	

//	abstract def <U super R> Try<U> upcast();
	/**
	 * Recovers exceptions of class {@code E}. If recovery fails with exception
	 * it will be thrown by this method.
	 */
	abstract def <E extends Throwable> Try<R> recoverFailure(Class<E> exceptionType, (E)=>R recovery)

	// TODO: Same for three and for Exceptions
	abstract def <E extends Throwable> Try<R> recoverFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2,
		(E)=>R recovery)

	/**
	 * Recovers exceptions of class {@code E}. If recovery fails with
	 * exception the returned Try will hold the exception
	 */
	abstract def <E extends Throwable> Try<R> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery)

	// TODO same for 3 and 4 exception classes
	abstract def <E extends Throwable> Try<R> tryRecoverFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2,
		(E)=>R recovery)

	/**
	 * Recovers exceptions. If recovery fails with an exception, the exception 
	 * will be thrown by this method.
	 */
	abstract def Try<R> recoverFailure((Throwable)=>R recovery)

	/**
	 * Recovers exceptions
	 */
	abstract def Try<R> tryRecoverFailure((Throwable)=>R recovery)

	abstract def Try<R> recoverEmpty(()=>R recovery)

	abstract def Try<R> tryRecoverEmpty(()=>R recovery)

	abstract def Try<R> recoverEmpty(R recovery)

	/**
	 * Recovers exceptions or {@code null} result values with value provided by {@code recovery}.
	 * If {@code recovery} fails with an exception it will be thrown by this method. If the result
	 * of {@code recovery} is {@code null}, then this method will return {@code null}.
	 */
	abstract def R recover(()=>R recovery)

	/**
	 * Recovers exceptions or {@code null} result values with value {@code recovery}.
	 * If recovery fails with an exception a failed {@code Try} is returned.
	 */
	abstract def Try<R> tryRecover(()=>R recovery)

	/**
	 * Recovers exceptions or {@code null} result values with value {@code recovery}.
	 */
	abstract def R recover(R recovery)

	// TODO flatRecover functions providing Try<R>
	/**
	 * Provides exception of type {@code E} to {@code handler} if this {@code Try} failed with
	 * an exception of type {@code E}. Returns this {@code Try} unchanged. This can e.g. be handy for
	 * logging an exception.
	 * @return same instance as {@code this}.
	 */
	abstract def <E extends Throwable> Try<R> ifFailure(Class<E> exceptionType, (E)=>void handler)
	
	// TODO same for 3 and 4 exception types
	abstract def <E extends Throwable> Try<R> ifFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2, (E)=>void handler)

	// TODO try versions of if-methods?
	/**
	 * Provides exception to {@code handler} if this {@code Try} failed with
	 * an exception. Returns this {@code Try} unchanged. This can e.g. be handy for
	 * logging an exception.
	 * @return same instance as {@code this}.
	 */
	abstract def Try<R> ifFailure((Throwable)=>void handler)

	/**
	 * Calls the given {@code handler} with the result value if the Try 
	 * completed with a non {@code null} result value.
	 */
	abstract def Try<R> ifSuccess((R)=>void handler)

	/**
	 * If operation was successful but returned {@code null} value.
	 */
	abstract def Try<R> ifEmpty(()=>void handler)

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
	
	// TODO: abstract def <U, I extends AutoCloseable> Try<U> thenFlatTryWith(()=>I resourceProducer, (I,R)=>Try<U> action) ??
	
	abstract def <U> Try<U> thenFlatTry((R)=>Try<U> action)

	abstract def boolean isEmpty()

	abstract def boolean isFailure()

	abstract def boolean isSuccessful()

	abstract def Try<R> mapException((Throwable)=>Throwable mapper)
	
	abstract def Try<R> filter(Predicate<R> test)

	abstract def <U> Try<U> filter(Class<U> clazz)

	// TODO tryTransform
	abstract def <U> U transform((R)=>U resultTransformer, (Throwable)=>U exceptionTranformer, =>U emptyTransformer)

	/**
	 * Returns empty optional if Try completed exceptionally or with a
	 * {@code null} value. Otherwise returns an optional with the computed
	 * result value present.
	 */
	abstract def Optional<R> getResult()

	/**
	 * Returns an empty stream if Try completed exceptionally or with 
	 * a {@code null} value. Otherwise returns a stream with the completed
	 * result value.
	 */
	abstract def Stream<R> stream();

	/**
	 * Returns result value on successful computation (even when the result
	 * value was {@code null}) or {@code null} if an exception was thrown.
	 */
	abstract def R getOrNull()

	/**
	 * Returns result value on successful computation with a result value was 
	 * not {@code null}. If the the operation failed with an exception, this exception
	 * will be re-thrown. If the result was {@code null} a {@link NoSuchElementException}
	 * will be thrown.
	 */
	abstract def R getOrThrow() throws NoSuchElementException

	/**
	 * Returns result value on successful computation with a result value was 
	 * not {@code null}. If the the operation failed with an exception, this exception
	 * will be re-thrown. If the result was {@code null} a the exception provided
	 * by {@code exceptionProvider} will be thrown.
	 */
	abstract def <E extends Exception> R getOrThrow(()=>E exceptionProvider) throws E

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
		
		def <U> boolean is(Class<U> clazz) {
			clazz.isInstance(result)
		}
		
		def <U> Success<R> ifInstanceOf(Class<U> clazz, (U)=>void consumer) {
			if(clazz.isInstance(result)) {
				consumer.apply(clazz.cast(result))
			}
			this
		}

		def R get() {
			result
		}

		override <E extends Throwable> recoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			this
		}

		override <E extends Throwable> recoverFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2,
			(E)=>R recovery) {
			this
		}

		override <E extends Throwable> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			this
		}

		override <E extends Throwable> tryRecoverFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2,
			(E)=>R recovery) {
			this
		}

		override recoverFailure((Throwable)=>R recovery) {
			this
		}

		override tryRecoverFailure((Throwable)=>R recovery) {
			this
		}

		override Try<R> recoverEmpty(()=>R recovery) {
			this
		}

		override Try<R> tryRecoverEmpty(()=>R recovery) {
			this
		}

		override Try<R> recoverEmpty(R recovery) {
			this
		}

		override recover(()=>R recovery) {
			result
		}

		override tryRecover(()=>R recovery) {
			this
		}

		override recover(R recovery) {
			result
		}

		override <E extends Throwable> ifFailure(Class<E> exceptionType, (E)=>void handler) {
			// no exception to handle
			this
		}
		
		override <E extends Throwable> ifFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2, (E)=>void handler) {
			// no exception to handle
			this
		}

		override ifFailure((Throwable)=>void handler) {
			// no exception to handle
			this
		}

		override ifSuccess((R)=>void handler) {
			handler.apply(result)
			this
		}

		override ifEmpty(()=>void handler) {
			// not empty
			this
		}

		override <U> thenTry((R)=>U action) {
			doTry [
				action.apply(result)
			]
		}

		override <U, I extends AutoCloseable> thenTryWith(()=>I resourceProducer, (I, R)=>U action) {
			tryWith(resourceProducer) [ res |
				action.apply(res, result)
			]
		}

		override <U> thenFlatTry((R)=>Try<U> action) {
			flatTry [
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

		override filter(Predicate<R> test) {
			if (test.test(result)) {
				this
			} else {
				completedEmpty
			}
		}

		override <U> filter(Class<U> clazz) {
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

		override <E extends Exception> getOrThrow(()=>E exceptionProvider) throws E {
			result	
		}

		override getException() {
			none
		}

		override <U> thenTryOptional((R)=>Optional<U> action) {
			tryOptional[|action.apply(result)]
		}

	}

	 final static class Empty<R> extends Try<R> {
		static val Empty<?> INSTANCE = new Empty

		private def <U> cast() {
			this as Empty as Empty<U>
		}

		override <E extends Throwable> Empty<R> recoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			// No exception to recover from
			this
		}

		override <E extends Throwable> Empty<R> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			// No exception to recover from
			this
		}

		override <E extends Throwable> Empty<R> tryRecoverFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2,
			(E)=>R recovery) {
			this
		}

		override Empty<R> recoverFailure((Throwable)=>R recovery) {
			// No exception to recover from
			this
		}

		override <E extends Throwable> Empty<R> recoverFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2,
			(E)=>R recovery) {
			// No exception to recover from
			this
		}

		override Empty<R> tryRecoverFailure((Throwable)=>R recovery) {
			// No exception to recover from
			this
		}

		override Try<R> recoverEmpty(()=>R recovery) {
			completed(recovery.apply)
		}

		override Try<R> tryRecoverEmpty(()=>R recovery) {
			doTry(recovery)
		}

		override Try<R> recoverEmpty(R recovery) {
			completed(recovery)
		}

		override R recover(()=>R recovery) {
			recovery.apply
		}

		override Try<R> tryRecover(()=>R recovery) {
			doTry(recovery)
		}

		override R recover(R recovery) {
			recovery
		}

		override <E extends Throwable> Empty<R> ifFailure(Class<E> exceptionType, (E)=>void handler) {
			// no exception
			this
		}
		
		
		override <E extends Throwable> Empty<R> ifFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2, (E)=>void handler) {
			this
		}

		override Empty<R> ifFailure((Throwable)=>void handler) {
			// no exception
			this
		}

		override Empty<R> ifSuccess((R)=>void handler) {
			// no result
			this
		}

		override Empty<R> ifEmpty(()=>void handler) {
			handler.apply
			this
		}

		override <U> Empty<U> thenTry((R)=>U action) {
			cast
		}

		override <U, I extends AutoCloseable> Empty<U> thenTryWith(()=>I resourceProducer, (I, R)=>U action) {
			cast
		}

		override <U> Empty<U> thenFlatTry((R)=>Try<U> action) {
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

		override Empty<R> filter(Predicate<R> test) {
			this
		}

		override <U> Empty<U> filter(Class<U> clazz) {
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

		override <E extends Throwable> recoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			if (exceptionType.isInstance(e)) {
				recovery.apply(e as E).completed
			} else {
				this
			}
		}

		override <E extends Throwable> recoverFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2,
			(E)=>R recovery) {
			if (exceptionType.isInstance(e) || exceptionType2.isInstance(e)) {
				recovery.apply(e as E).completed
			} else {
				this
			}
		}

		override <E extends Throwable> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			if (exceptionType.isInstance(e)) {
				doTry [
					recovery.apply(e as E)
				]
			} else {
				this
			}
		}

		override <E extends Throwable> tryRecoverFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2,
			(E)=>R recovery) {
			if (exceptionType.isInstance(e) || exceptionType2.isInstance(e)) {
				doTry [
					recovery.apply(e as E)
				]
			} else {
				this
			}
		}

		override recoverFailure((Throwable)=>R recovery) {
			recovery.apply(e).completed
		}

		override tryRecoverFailure((Throwable)=>R recovery) {
			doTry [
				recovery.apply(e)
			]
		}

		override <E extends Throwable> Failure<R> ifFailure(Class<E> exceptionType, (E)=>void handler) {
			if (exceptionType.isInstance(e)) {
				handler.apply(e as E)
			}
			this
		}
		
		override <E extends Throwable> Failure<R> ifFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2, (E)=>void handler) {
			if (exceptionType.isInstance(e) || exceptionType2.isInstance(e)) {
				handler.apply(e as E)
			}
			this
		}

		override Failure<R> ifFailure((Throwable)=>void handler) {
			handler.apply(e)
			this
		}

		override Failure<R> ifEmpty(()=>void handler) {
			// not empty result
			this
		}

		override Failure<R> ifSuccess((R)=>void handler) {
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

		override <U> Failure<U> thenFlatTry((R)=>Try<U> action) {
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

		override Failure<R> filter(Predicate<R> test) {
			this
		}

		override <U> Failure<U> filter(Class<U> clazz) {
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

		override <E extends Exception> getOrThrow(()=>E exceptionProvider) throws E {
			throw e
		}

		override getException() {
			some(e)
		}

		override Failure<R> recoverEmpty(()=>R recovery) {
			this
		}

		override Failure<R> tryRecoverEmpty(()=>R recovery) {
			this
		}

		override Failure<R> recoverEmpty(R recovery) {
			this
		}

		override recover(()=>R recovery) {
			recovery.apply
		}

		override tryRecover(()=>R recovery) {
			doTry(recovery)
		}

		override recover(R recovery) {
			recovery
		}

		override <U> thenTryOptional((R)=>Optional<U> action) {
			cast
		}

	}

// TODO makes sense? 
//	def Either<R,Exception> asEither() //mapps empty to NoSuchElementException
}
