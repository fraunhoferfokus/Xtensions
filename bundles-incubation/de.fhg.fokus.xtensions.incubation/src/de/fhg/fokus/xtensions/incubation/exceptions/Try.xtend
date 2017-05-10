package de.fhg.fokus.xtensions.incubation.exceptions

import java.util.Optional
import java.util.NoSuchElementException

final class Try<R> {
	private val Exception e
	private val R result
	
	private new (R result, Exception e) {
		this.e = e
		this.result = result
	}
	
	def static <R> Try<R> completed(R result) {
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	def static <R> Try<R> doTry(()=>R provider) {
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	def static <R> Try<R> flatTry(()=>Try<R> provider) {
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	/**
	 * Recovers exceptions of class {@code E}.
	 */
	def <E> Try<R> recover(Class<E> exceptionType, (E)=>R recovery) {
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	/**
	 * Recovers exceptions
	 */
	def Try<R> recover((Exception)=>R recovery) {
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	/**
	 * Recovers exceptions or {@code null} result values with value provided by {@code recovery}.
	 * If {@code recovery} fails with an exception it will be thrown by this method. If the result
	 * of {@code recovery} is {@code null}, then this method will return {@code null}.
	 */
	def R recoverEmpty(()=>R recovery) {
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	/**
	 * Recovers exceptions or {@code null} result values with value {@code recovery}.
	 */
	def R recoverEmpty(R recovery) {
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	/**
	 * Recovers exceptions or {@code null} result values with value {@code recovery}.
	 * If recovery fails with an exception a failed {@code Try} is returned.
	 */
	def Try<R> tryRecoverEmpty(()=>R recovery) {
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	/**
	 * Provides exception of type {@code E} to {@code handler} if this {@code Try} failed with
	 * an exception of type {@code E}. Returns this {@code Try} unchanged.
	 * @return same instance as {@code this}.
	 */
	def <E> Try<R> ifException(Class<E> exceptionType, (E)=>void handler){
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	/**
	 * Provides exception to {@code handler} if this {@code Try} failed with
	 * an exception. Returns this {@code Try} unchanged.
	 * @return same instance as {@code this}.
	 */
	def <E> Try<R> ifException((Exception)=>void handler){
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	def Try<R> ifResult((R)=>void handler){
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	/**
	 * If operation was successful but returned {@code null} value.
	 */
	def Try<R> ifEmptyResult(()=>void handler){
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	/**
	 * Calls {@code action} with the result of this try, if the Try
	 * holds a successful result and is not {@code null}.
	 * @param action operation to be performed if this Try holds a result that
	 *  is not {@code null}.
	 * @return Try wrapping the result of the {@code action} if it completes successful,
	 *   or holding an exception if the operation throws 
	 */
	def <U> Try<U> thenTry((R)=>U action) {
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	def <U> Try<U> thenFlatTry((R)=>Try<U> action) {
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	def Optional<R> get() {
		if(e !== null) {
			Optional.empty
		} else {
			Optional.ofNullable(result)
		}
	}
	
	/**
	 * Returns result value on successful computation or {@code null}
	 * an exception was thrown.
	 */
	def R getOrNull() {
		recoverEmpty(null as R)
	}
	
	/**
	 * Returns result value on successful computation with a result value was 
	 * not {@code null}. If the the operation failed with an exception, this exception
	 * will be re-thrown. If the result was {@code null} a {@link NoSuchElementException}
	 * will be thrown
	 */
	def R getOrThrow() throws NoSuchElementException {
		throw new UnsupportedOperationException("Not implemented yet")
	}
}