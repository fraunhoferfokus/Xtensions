package de.fhg.fokus.xtensions.incubation.exceptions

import java.util.Optional
import java.util.NoSuchElementException
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*
import java.util.function.Predicate
import static extension java.util.Objects.*
import java.util.stream.Stream

/**
 * Result of computation of non-null result value .
 * Constructing try:
 * <ul>
 * 	<li>tryWith</li>
 * 	<li>doTry</li>
 * 	<li>flatTry</li>
 * 	<li>completedSuccessfully</li>
 * 	<li>completedExceptionally</li>
 * </ul>
 * All methods starting with {@code if} react on the result and simply return 
 * the Try on which they were invoked again. If the handlers passed to these methods
 * throw an exception, they well be thrown from the {@code if*} method that was called.<br>
 * <br>
 * The methods starting with {@code then} execute the given handler when the 
 */
abstract class Try<R> {

	private new(){}
	
	
	/**
	 * Returns an instance of {@link Empty} if {@code result === null},
	 * or an instance of {@link Success} holding the {@code result} value if not.
	 * @param result the result value to be wrapped. May be {@code null}.
	 */
	static def <R> Try<R> completed(R result) {
		if(result === null) {
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
	 * Returns an instance of {@link Failure} wrapping around the {@code Exception e} 
	 * which is the cause of failure.
	 */
	def static <R> Failure<R> completedExceptionally(Exception e) throws NullPointerException {
		new Failure(e.requireNonNull)
	}
	
	// maybe 
	def static <I extends AutoCloseable,R> tryWith(()=>I resourceProvider, (I)=>R provider) {
		try {
			val resource = resourceProvider.apply
			try {
				val result = provider.apply(resource);
				completed(result)
			} finally {
				resource.close
			}
		} catch(Exception e) {
			completedExceptionally(e);
		}
	}
	
	def static <R> Try<R> doTry(()=>R provider) {
		try {
			val result = provider.apply
			completed(result)
		} catch(Exception e) {
			completedExceptionally(e)
		}
	}
	
	def static <I,R> Try<R> doTry(I input, (I)=>R provider) {
		try {
			val result = provider.apply(input)
			completed(result)
		} catch(Exception e) {
			completedExceptionally(e)
		}
	}
	
	def static <R> Try<R> flatTry(()=>Try<R> provider) {
		try {
			provider.apply
		} catch(Exception e) {
			completedExceptionally(e)
		}
	}
	
//	abstract def <U super R> Try<U> upcast();
	
	/**
	 * Recovers exceptions of class {@code E}. If recovery fails with exception
	 * it will be thrown by this method.
	 */
	abstract def <E> Try<R> recoverException(Class<E> exceptionType, (E)=>R recovery)
	
	/**
	 * Recovers exceptions of class {@code E}. If recovery fails with
	 * exception the returned Try will hold the exception
	 */
	abstract def <E> Try<R> tryRecoverException(Class<E> exceptionType, (E)=>R recovery)
	
	/**
	 * Recovers exceptions. If recovery fails with an exception, the exception 
	 * will be thrown by this method.
	 */
	abstract def Try<R> recoverException((Exception)=>R recovery)
	
	/**
	 * Recovers exceptions
	 */
	abstract def Try<R> tryRecoverException((Exception)=>R recovery)
	
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
	 * an exception of type {@code E}. Returns this {@code Try} unchanged.
	 * @return same instance as {@code this}.
	 */
	abstract def <E> Try<R> ifException(Class<E> exceptionType, (E)=>void handler)
	
	// TODO try versions of if-methods?
	
	/**
	 * Provides exception to {@code handler} if this {@code Try} failed with
	 * an exception. Returns this {@code Try} unchanged.
	 * @return same instance as {@code this}.
	 */
	abstract def <E> Try<R> ifException((Exception)=>void handler)
	
	/**
	 * Calls the given {@code handler} with the result value if the Try 
	 * completed with a non {@code null} result value.
	 */
	abstract def Try<R> ifResult((R)=>void handler)
	
	/**
	 * If operation was successful but returned {@code null} value.
	 */
	abstract def Try<R> ifEmptyResult(()=>void handler)
	
	/**
	 * Calls {@code action} with the result of this try, if the Try
	 * holds a successful result and is not {@code null}.
	 * @param action operation to be performed if this Try holds a result that
	 *  is not {@code null}.
	 * @return Try wrapping the result of the {@code action} if it completes successful,
	 *   or holding an exception if the operation throws 
	 */
	abstract def <U> Try<U> thenTry((R)=>U action)
	
	abstract def <U, I extends AutoCloseable> Try<U> thenTryWith(()=>I resourceProducer,(I,R)=>U action)
	
	abstract def <U> Try<U> thenFlatTry((R)=>Try<U> action)
	
	abstract def boolean isEmpty()
	
	abstract def boolean isFailure()
	
	abstract def boolean isSuccessful()
	
	abstract def Try<R> mapException((Exception)=>Exception mapper)
	
	abstract def Try<R> filter(Predicate<R> test)
	
	abstract def <U> Try<U> filter(Class<U> clazz)
	
	// TODO tryTransform
	abstract def <U> U transform((R)=>U resultTransformer, (Exception)=>U exceptionTranformer, =>U emptyTransformer)
	
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
		
	abstract def Optional<Exception> getException()
	
	/**
	 * Returns given {@code Try<T>} as {@code Try<U>} where {@code U} is supertype of {@code T}.
	 * @see Try#upcast(Success)
	 * @see Try#upcast(Empty)
	 * @see Try#upcast(Failure)
	 */
	public static def <U,R extends U> Try<U> upcast(Try<R> t) {
		t as Try<?> as Try<U>
	}
	
	/**
	 * Returns given {@code Success<T>} as {@code Success<U>} where {@code U} is supertype of {@code T}.
	 * @see Try#upcast(Try)
	 * @see Try#upcast(Empty)
	 * @see Try#upcast(Failure)
	 */
	public static def <U,R extends U> Success<U> upcast(Success<R> t) {
		t as Success<?> as Success<U>
	}
	
	/**
	 * Returns given {@code Empty<T>} as {@code Empty<U>} where {@code U} is supertype of {@code T}.
	 * @see Try#upcast(Success)
	 * @see Try#upcast(Try)
	 * @see Try#upcast(Failure)
	 */
	public static def <U,R extends U> Empty<U> upcast(Empty<R> t) {
		t as Empty<?> as Empty<U>
	}
	
	/**
	 * Returns given {@code Failure<T>} as {@code Failure<U>} where {@code U} is supertype of {@code T}.
	 * @see Try#upcast(Success)
	 * @see Try#upcast(Empty)
	 * @see Try#upcast(Try)
	 */
	public static def <U,R extends U> Failure<U> upcast(Failure<R> t) {
		t as Failure<?> as Failure<U>
	}
	
	public final static class Success<R> extends Try<R> {
		
		private val R result
		
		private new (R result) {
			this.result = result
		}
		
		def R get() {
			result
		}
		
		override <E> recoverException(Class<E> exceptionType, (E)=>R recovery) {
			this
		}
		
		override <E> tryRecoverException(Class<E> exceptionType, (E)=>R recovery) {
			this
		}
		
		override recoverException((Exception)=>R recovery) {
			this
		}
		
		override tryRecoverException((Exception)=>R recovery) {
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
		
		override <E> ifException(Class<E> exceptionType, (E)=>void handler) {
			// no exception to handle
			this
		}
		
		override <E> ifException((Exception)=>void handler) {
			// no exception to handle
			this
		}
		
		override ifResult((R)=>void handler) {
			handler.apply(result)
			this
		}
		
		override ifEmptyResult(()=>void handler) {
			// not empty
			this
		}
		
		override <U> thenTry((R)=>U action) {
			doTry [
				action.apply(result)
			]
		}
		
		override <U,I extends AutoCloseable> thenTryWith(()=>I resourceProducer, (I, R)=>U action) {
			tryWith(resourceProducer)[ res |
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
		
		override mapException((Exception)=>Exception mapper) {
			// nothing to map
			this
		}
		
		override filter(Predicate<R> test) {
			if(test.test(result)) {
				this
			} else {
				completedEmpty
			}
		}
		
		override <U> filter(Class<U> clazz) {
			if(clazz.isInstance(result)) {
				this as Try<?> as Try<U>
			} else {
				completedEmpty
			}
		}
		
		override <U> transform((R)=>U resultTransformer, (Exception)=>U exceptionTranformer, ()=>U emtpyTransformer) {
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
		
	}
	
	public final static class Empty<R> extends Try<R> {	
		private static val Empty<?> INSTANCE = new Empty
		
		override <E> Empty<R> recoverException(Class<E> exceptionType, (E)=>R recovery) {
			// No exception to recover from
			this
		}
		
		override <E> Empty<R> tryRecoverException(Class<E> exceptionType, (E)=>R recovery) {
			// No exception to recover from
			this
		}
		
		override Empty<R> recoverException((Exception)=>R recovery) {
			// No exception to recover from
			this
		}
		
		override Empty<R> tryRecoverException((Exception)=>R recovery) {
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
		
		override <E> ifException(Class<E> exceptionType, (E)=>void handler) {
			// no exception
			this
		}
		
		override <E> Empty<R> ifException((Exception)=>void handler) {
			// no exception
			this
		}
		
		override Empty<R> ifResult((R)=>void handler) {
			// no result
			this
		}
		
		override Empty<R> ifEmptyResult(()=>void handler) {
			handler.apply
			this
		}
		
		override <U> Empty<U> thenTry((R)=>U action) {
			this as Empty<?> as Empty<U>
		}
		
		override <U,I extends AutoCloseable> Empty<U> thenTryWith(()=>I resourceProducer, (I, R)=>U action) {
			this as Empty<?> as Empty<U>
		}
		
		override <U> Empty<U> thenFlatTry((R)=>Try<U> action) {
			this as Empty<?> as Empty<U>
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
		
		override Empty<R> mapException((Exception)=>Exception mapper) {
			this
		}
		
		override Empty<R> filter(Predicate<R> test) {
			this
		}
		
		override <U> Empty<U> filter(Class<U> clazz) {
			this as Empty<?> as Empty<U>
		}
		
		override <U> U transform((R)=>U resultTransformer, (Exception)=>U exceptionTranformer, ()=>U emptyTransformer) {
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
		
	}
	
	public final static class Failure<R> extends Try<R> {
		private val Exception e
		
		private new (Exception e) {
			this.e = e
		}
		
		public def Exception get() {
			e
		}
		
		override <E> recoverException(Class<E> exceptionType, (E)=>R recovery) {
			if(exceptionType.isInstance(e)) {
				recovery.apply(e as E).completed
			} else {
				this
			}
		}
		
		override <E> tryRecoverException(Class<E> exceptionType, (E)=>R recovery) {
			if(exceptionType.isInstance(e)) {
				doTry [
					recovery.apply(e as E)
				]
			} else {
				this
			}
		}
		
		override recoverException((Exception)=>R recovery) {
			recovery.apply(e).completed
		}
		
		override tryRecoverException((Exception)=>R recovery) {
			doTry [
				recovery.apply(e)
			]
		}
		
		override <E> ifException(Class<E> exceptionType, (E)=>void handler) {
			if(exceptionType.isInstance(e)) {
				handler.apply(e as E)
			}
			this
		}
		
		override <E> ifException((Exception)=>void handler) {
			handler.apply(e)
			this
		}
		
		
		override ifEmptyResult(()=>void handler) {
			// not empty result
			this
		}
		
		override ifResult((R)=>void handler) {
			// no result
			this
		}
		
		override <U> thenTry((R)=>U action) {
			// no result
			this as Try<?> as Try<U>
		}
		
		override <U,I extends AutoCloseable> thenTryWith(()=>I resourceProducer, (I, R)=>U action) {
			// no result
			this as Try<?> as Try<U>
		}
		
		override <U> thenFlatTry((R)=>Try<U> action) {
			// no result
			this as Try<?> as Try<U>
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
		
		override mapException((Exception)=>Exception mapper) {
			completedExceptionally(mapper.apply(e))
		}
		
		override Failure<R> filter(Predicate<R> test) {
			this
		}
		
		override <U> Failure<U> filter(Class<U> clazz) {
			this as Failure<?> as Failure<U>
		}
		
		override <U> transform((R)=>U resultTransformer, (Exception)=>U exceptionTranformer, ()=>U emptyTransformer) {
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
			recovery.apply
		}
		
		override tryRecover(()=>R recovery) {
			doTry(recovery)
		}
		
		override recover(R recovery) {
			recovery
		}
		
	}
	
	// TODO makes sense? 
//	def Either<R,Exception> asEither() //mapps empty to NoSuchElementException
}