package de.fhg.fokus.xtensions.incubation.exceptions

import java.util.Optional
import java.util.NoSuchElementException
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*
import java.util.function.Predicate
import static extension java.util.Objects.*

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
	
	static def <R> Try<R> completed(R result) {
		if(result === null) {
			completedEmpty
		} else {
			new Success(result)
		}
	}
	
	static def <R> Try<R> completedSuccessfully(R result) {
		new Success(result.requireNonNull)
	}
	
	def static <R> Empty<R> completedEmpty() {
		Empty.INSTANCE as Empty as Empty<R>
	}
	
	def static <R> Failure<R> completedExceptionally(Exception e) {
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
	
	// TODO tryTransform
	abstract def <U> U transform((R)=>U resultTransformer, (Exception)=>U exceptionTranformer, =>U emptyTransformer)
	
	/**
	 * Returns empty optional if Try completed exceptionally or with a
	 * {@code null} value. Otherwise returns an optional with the computed
	 * result value present.
	 */
	abstract def Optional<R> getResult()
	
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
				
			}
		}
		
		override <U> transform((R)=>U resultTransformer, (Exception)=>U exceptionTranformer, ()=>U emtpyTransformer) {
			resultTransformer.apply(result)
		}
		
		override getResult() {
			some(result)
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
	
	public static class Empty<R> extends Try<R> {	
		private static val Empty<?> INSTANCE = new Empty
		
		override <E> recoverException(Class<E> exceptionType, (E)=>R recovery) {
			// No exception to recover from
			this
		}
		
		override <E> tryRecoverException(Class<E> exceptionType, (E)=>R recovery) {
			// No exception to recover from
			this
		}
		
		override recoverException((Exception)=>R recovery) {
			// No exception to recover from
			this
		}
		
		override tryRecoverException((Exception)=>R recovery) {
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
		
		override recover(()=>R recovery) {
			recovery.apply
		}
		
		override tryRecover(()=>R recovery) {
			doTry(recovery)
		}
		
		override recover(R recovery) {
			recovery
		}
		
		override <E> ifException(Class<E> exceptionType, (E)=>void handler) {
			// no exception
			this
		}
		
		override <E> ifException((Exception)=>void handler) {
			// no exception
			this
		}
		
		override ifResult((R)=>void handler) {
			// no result
			this
		}
		
		override ifEmptyResult(()=>void handler) {
			handler.apply
			this
		}
		
		override <U> thenTry((R)=>U action) {
			this as Try as Try<U>
		}
		
		override <U,I extends AutoCloseable> thenTryWith(()=>I resourceProducer, (I, R)=>U action) {
			this as Try as Try<U>
		}
		
		override <U> thenFlatTry((R)=>Try<U> action) {
			this as Try as Try<U>
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
		
		override mapException((Exception)=>Exception mapper) {
			this
		}
		
		override filter(Predicate<R> test) {
			this
		}
		
		override <U> transform((R)=>U resultTransformer, (Exception)=>U exceptionTranformer, ()=>U emptyTransformer) {
			emptyTransformer.apply
		}
		
		override getResult() {
			none
		}
		
		override getOrNull() {
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
	
	public static final class Failure<R> extends Try<R> {
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
			this as Try as Try<U>
		}
		
		override <U,I extends AutoCloseable> thenTryWith(()=>I resourceProducer, (I, R)=>U action) {
			// no result
			this as Try as Try<U>
		}
		
		override <U> thenFlatTry((R)=>Try<U> action) {
			// no result
			this as Try as Try<U>
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
		
		override filter(Predicate<R> test) {
			this
		}
		
		override <U> transform((R)=>U resultTransformer, (Exception)=>U exceptionTranformer, ()=>U emptyTransformer) {
			exceptionTranformer.apply(e)
		}
		
		override getResult() {
			none
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