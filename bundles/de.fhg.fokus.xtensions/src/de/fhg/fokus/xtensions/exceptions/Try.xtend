/*******************************************************************************
 * Copyright (c) 2017-2019 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.exceptions

import java.util.Optional
import java.util.NoSuchElementException
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*
import java.util.function.Predicate
import static extension java.util.Objects.*
import java.util.stream.Stream
import com.google.common.collect.Iterators
import java.util.Collections
import java.util.Iterator
import static extension de.fhg.fokus.xtensions.iteration.ArrayExtensions.*
import de.fhg.fokus.xtensions.exceptions.Try.Success

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
 * 	<li>{@link #tryCall(Functions.Function0) tryCall(=&gt;R)}</li>
 * 	<li>{@link #tryCall(Object, Functions.Function1) tryCall(I, (I)=&gt;R)}</li>
 * 	<li>{@link #tryWith(Functions.Function0, Functions.Function1) tryWith(=&gt;I, (I)=&gt;R)}</li>
 * 	<li>{@link #tryFlat(Functions.Function0) flatTry(=&gt;Try&lt;R&gt;)}</li>
 * 	<li>{@link #completed(Object) completed(R)}</li>
 * 	<li>{@link #completedSuccessfully(Object) completedSuccessfully(R)}</li>
 * 	<li>{@link #completedFailed(Throwable)}</li>
 * 	<li>{@link #completedEmpty()}</li>
 * </ul>
 * All methods starting with {@code if} react on the result and simply return 
 * the Try on which they were invoked again. If the handlers passed to these methods
 * throw an exception, they well be thrown from the {@code if*} method that was called.<br>
 * <br>
 * The methods starting with {@code then} execute the given handler when the Try represents
 * a successful computation.<br><br>
 * Note that equality of {@code Try} instances is defined via the equality of the wrapped result.
 * This means two {@code Try.Success} instances wrapping elements that are equal are equals as well.
 * Two {@code Try.Failure} instances wrapping exceptions that are equals are equal as well. But different
 * subclasses of {@code Try} even if they wrap the exact same object (e.g. an Exception) are never
 * equal.
 */
abstract class Try<R> implements Iterable<R> {

	private new() {
	}

	/**
	 * Returns an instance of {@link Empty} if {@code result === null},
	 * or an instance of {@link Success} holding the {@code result} value if not.
	 * @param result the result value to be wrapped. May be {@code null}.
	 * @param <R> type of successful value to be wrapped
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
	 * @param <R> type of successful value to be wrapped
	 * @return a {@code Success} wrapping the given {@code result} parameter.
	 * @throws NullPointerException if {@code result === null}.
	 */
	static def <R> Success<R> completedSuccessfully(R result) throws NullPointerException {
		new Success(result.requireNonNull)
	}

	/**
	 * Returns an instance of {@link Try.Empty}, representing a successful, but empty result.
	 * @param <R> type of expected successful value
	 * @return an instance of {@link Try.Empty}
	 */
	def static <R> Empty<R> completedEmpty() {
		Empty.INSTANCE as Empty<?> as Empty<R>
	}

	/**
	 * Returns an instance of {@link Failure} wrapping around the {@code Throwable t} 
	 * which is the cause of failure.
	 * @param t error that is wrapped into the returned {@link Failure}. Must not be {@code null}.
	 * @param <R> type of expected successful value
	 * @return instance of {@link Failure} wrapping around parameter {@code t} 
	 * @throws NullPointerException if {@code t} is {@code null}
	 */
	def static <R> Failure<R> completedFailed(Throwable t) throws NullPointerException {
		new Failure(t.requireNonNull("Throwable t must not be null"))
	}

	/**
	 * Executes the given {@code provider}, if it throws an exception it will be wrapped
	 * into a {@code Try.Failure}. If it computes normally and returns {@code null} a {@code Try.Empty}
	 * will be returned, otherwise a {@code Try.Success} will be returned wrapping the result value.
	 * If {@code provider} is {@code null} this method will return a {@code Try.Failure} holding a
	 * {@code NullPointerException}.
	 * 
	 * @param provider function to be called, and that's return value or thrown exception will be wrapped
	 *  and returned. Must not be {@code null}.
	 * @param <R> type of successful result returned by {@code provider} and wrapped into the returned {@code Try}.
	 * @return {@code Try.Failure} if {@code provider} throws an exception which will be wrapped into the failure; {@code Try.Empty} if {@code provider}
	 * 	returns {@code null}; {@code Try.Success} if provider returns {@code provider} returns a value {@code !== null} which will
	 * 	be wrapped into the success. If {@code provider} is {@code null} returns a {@code Try.Failure} wrapping a {@code NullPointerException}.
	 */
	def static <R> Try<R> tryCall(=>R provider) {
		if(provider === null) {
			return completedFailed(new NullPointerException("provider must not be null"))
		}
		try {
			val result = provider.apply
			completed(result)
		} catch (Throwable e) {
			completedFailed(e)
		}
	}

	/**
	 * This method is a version of {@link Try#tryCall(Functions.Function0) tryCall(=&gt;R)} allowing to
	 * pass a context object into the {@code provider}, which can be used to get more
	 * performance, avoiding capturing lambdas. But it can also be used similar to the 
	 * {@code =&gt;} operator to group calls to a single context object.
	 * If {@code provider} is {@code null} this method will return a {@code Try.Failure} holding a
	 * {@code NullPointerException}.<br><br>
	 * Note that this method does <em>not</em> have the semantics of
	 * {@link #tryWith(Functions.Function0,Functions.Function1) tryWith(=>I,(I)=>R)}.
	 * It will <em>not</em> close an {@code AutoCloseable} resource passed as {@code input}. 
	 * 
	 * @param input element that will be passed to {@code provider}
	 * @param provider function to be called with {@code input}, the result
	 *  of this function will be wrapped in a {@code Try} and returned.
	 * @param <I> type of the input object passed through to {@code provider}.
	 * @param <R> type of successful result returned by {@code provider} and wrapped into the returned {@code Try}.
	 * @return {@code Try.Failure} if {@code provider} throws an exception which will be wrapped into the failure; {@code Try.Empty} if {@code provider}
	 * 	returns {@code null}; {@code Try.Success} if provider returns {@code provider} returns a value {@code !== null} which will
	 * 	be wrapped into the success. If {@code provider} is {@code null} returns a {@code Try.Failure} holding a
	 * {@code NullPointerException}.
	 * @see Try#tryCall(Functions.Function0)
	 */
	def static <I, R> Try<R> tryCall(I input, (I)=>R provider) {
		if(provider === null) {
			return completedFailed(new NullPointerException("provider must not be null"))
		}
		try {
			val result = provider.apply(input)
			completed(result)
		} catch (Throwable e) {
			completedFailed(e)
		}
	}

	/**
	 * Executes the given {@code provider}, if it throws an exception it will be wrapped
	 * into a {@code Try.Failure}. If it computes normally and the returned {@code Optional} has
	 * a value present, this value will be wrapped into a {@code Try.Success} and returned, if the
	 * returned value is an empty {@code Optional} an empty {@code Try} will be returned. if {@code provider}
	 * returns {@code null} the returned {@code Try} will be failed with a {@code NullPointerException}. 
	 * 
	 * @param provider function to be invoked, and that's result will be wrapped into a {@code Try}. Must not be {@code null}.
	 * @param <R> Type of successful result provided by {@code provider} and wrapped in returned {@code Try}.
	 * @return {@code Try.Failure} if {@code provider} throws an exception which will be wrapped into the failure; {@code Try.Success} 
	 * if {@code provider} returns an {@code Optional} with a value present, the returned value will wrap around the value held by the 
	 * {@code Optional}; {@code Try.Empty} otherwise. If {@code provider} is {@code null} or returns {@code null} the resulting 
	 * {@code Try} will be failed with a {@code NullPointerException}. 
	 */
	def static <R> Try<R> tryOptional(=>Optional<R> provider) {
		provider.requireNonNull("provider must not be null")
		try {
			val result = provider.apply
			if (result !== null) {
				if(result.present) {
					completed(result.get)
				} else {
					completedEmpty
				}
			} else {
				completedFailed(new NullPointerException("returned Optional must not be null"))
			}
		} catch (Throwable e) {
			completedFailed(e)
		}
	}

	/**
	 * Executes the given {@code provider}, if it throws an exception it will be wrapped
	 * into a {@code Try.Failure}. If it computes normally, the result of the call to 
	 * {@code provider} will be returned.
	 * 
	 * @param provider function to be invoked, and that's result will be returned. If it throws an exception,
	 *  it will be caught, wrapped into a {@code Try.Failure} and returned. {@code provider} must not be {@code null}.
	 * @param <R> Type of successful result provided by {@code provider} and wrapped in returned {@code Try}.
	 * @return result of call to {@code provider}. If {@code provider} is {@code null} or returns {@code null} a {@code Try}
	 *  will be returned wrapping a {@code NullPointerException}.
	 *  If {@code provider} throws, a {@code Try.Failure} wrapping the caught {@code Throwable}.
	 */
	def static <R> Try<R> tryFlat(=>Try<R> provider) {
		if(provider === null) {
			return completedFailed(new NullPointerException("provider must not be null"))
		}
		try {
			val result = provider.apply
			if(result === null) {
				completedFailed(new NullPointerException("return value of provider must not be null"))
			} else {
				result
			}
		} catch (Throwable e) {
			completedFailed(e)
		}
	}

	/**
	 * This method calls the provided {@code provider} with the {@code AutoCloseable} resource 
	 * provided by {@code resourceProvider}. The method will always close the resource (if it is not {@code null})
	 * after calling {@code provider}, no matter if {@code provider} executes successfully or throws an exception.<br> 
	 * If the {@code resourceProvider} throws an exception,
	 * the returned {@code Try} will be a failure wrapping the exception. In case it provides a non-{@code null}
	 * reference, the resource will be closed before this method ends. If the {@code provider}
	 * returns a non-{@code null} reference, this method will return a {@code Try.Success} wrapping
	 * the result. If the {@code provider} returns a {@code null}, this method returns a {@code Try.Empty}.
	 * If the {@code provider} throws an exception, this method will return a {@code Try.Failure} wrapping
	 * the thrown exception.<br>
	 * If {@code resourceProvider} or {@code provider} is {@code null} returns a {@code Try.Failure}  
	 *  wrapping a {@code NullPointerException}.
	 * 
	 * @param resourceProvider provides a resource to be passed to {@code provider}. The provided resource
	 *  will be closed after calling {@code provider}, if {@code resourceProvider} does not throw an 
	 *  exception and returns a non-{@code null} reference. Must not be {@code null}.
	 * @param <I> Type of closeable resource provided by {@code resourceProvider} and passed on to {@code provider}.
	 * @param <R> Type of successful result provided by {@code provider} and wrapped in returned {@code Try}.
	 * @param provider will be called by this method with the resource provided by {@code resourceProvider}.
	 *  The outcome of the call to {@code provider} will be wrapped into a {@code Try} and returned by this method.
	 *  Must not be {@code null}.
	 * @return {@code Try.Failure} if {@code resourceProvider} or {@code provider} throws an exception;
	 *  {@code Try.Empty} if {@code provider} returns a {@code null} reference; otherwise a {@code Try.Success}
	 *  is returned wrapping the result of {@code provider}.
	 *  If {@code resourceProvider} or {@code provider} is {@code null} a {@code Try.Failure} will be returned 
	 *  wrapping a {@code NullPointerException}.
	 */
	def static <I extends AutoCloseable, R> Try<R> tryWith(=>I resourceProvider,
		(I)=>R provider) throws NullPointerException {
		if(resourceProvider === null) {
			return completedFailed(new NullPointerException("resourceProvider must not be null"))
		}
		if(provider === null) {
			return completedFailed(new NullPointerException("provider must not be null"))
		}
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
			completedFailed(e)
		}
	}

	/**
	 * This method tries to recover the {@code Try}, if it is failed. Note that it will not recover
	 * an empty {@code Try} (see {@link #tryRecover(Functions.Function0) tryRecover(=>R)}). If the 
	 * given {@code recovery} function is {@code null} this method will return a failed {@code Try}
	 * that contains a {@code NullPointerException}. When this method is called on successful or
	 * empty {@code Try} instances, the {@code this} reference will be returned. If this method
	 * is called on a {@code Try.Failure}, the {@code recovery} method is called. If {@code recovery}
	 * returns a {@code null} value, an {@code Try.Empty} method is returned, if it returns a 
	 * non-{@code null} value a {@code Try.Success} value is returned wrapping the result value.
	 * If {@code recovery} throws an exception, a {@code Try.Failure} will be returned wrapping 
	 * the thrown exception.
	 * <br><br>
	 * If this {@code Try} is a {@code Try.Failure} and this method returns a 
	 * {@code Try.Failure} (do to some reason stated above), the exception wrapped in the 
	 * original {@code Try.Failure} will be added as a {@link Throwable#getSuppressed() suppressed}
	 * exception to the exception wrapped in the {@code Try.Failure} returned from this method. 
	 * @param recovery function to recover from an exception. The function maps from the wrapped
	 *  exception to a success value.
	 * @return If recovery is {@code null} this method returns a {@code Try.Failure} completed with
	 *  a {@link NullPointerException}. If the {@code this} reference if {@code this} is a success or empty. 
	 *  If {@code this} is failed, the failure is tried to be recovered using the {@code recovery} function. 
	 *  The result will be wrapped in a {@code Try.Success}, or {@code Try.Empty} if the returned recovery
	 *  value is {@code null}. If the {@code recovery} throws an exception a {@code Try.Failure} wrapping
	 *  the thrown exception.
	 */
	abstract def Try<R> tryRecoverFailure((Throwable)=>R recovery)

	/**
	 * This method tries to recover the {@code Try}, if it is failed with an exception instance of type {@code E}. 
	 * Note that it will not recover an empty {@code Try} or a {@code Try} of a different exception type than {@code E}. 
	 * If the given {@code recovery} function is {@code null} or {@code exceptionType} is {@code null} 
	 * this method will return a failed {@code Try} that contains a {@code NullPointerException}. 
	 * When this method is called on successful or empty {@code Try} instances or called on a failed 
	 * {@code Try} that is <em>not</em> instance of {@code E}, the {@code this} reference will be returned. 
	 * If this method is called on a {@code Try.Failure} and 
	 * the wrapped exception is instance of {@code E}, the {@code recovery} method is called. If {@code recovery}
	 * returns a {@code null} value, an {@code Try.Empty} method is returned, if it returns a 
	 * non-{@code null} value a {@code Try.Success} value is returned wrapping the result value.
	 * If {@code recovery} throws an exception, a {@code Try.Failure} will be returned wrapping 
	 * the thrown exception.
	 * <br><br>
	 * If this {@code Try} is a {@code Try.Failure} and this method returns a 
	 * {@code Try.Failure} (do to some reason stated above), the exception wrapped in the 
	 * original {@code Try.Failure} will be added as a {@link Throwable#getSuppressed() suppressed}
	 * exception to the exception wrapped in the {@code Try.Failure} returned from this method.
	 * @param exceptionType type of exception to recover by the given {@code recovery}.
	 * @param recovery function to recover from an exception of type {@code E}. The function maps from the wrapped
	 *  exception to a success value.
	 * @param <E> Type of exception to recover from.
	 * @return If recovery is {@code null} this method returns a {@code Try.Failure} completed with
	 *  a {@link NullPointerException}. If {@code this} is a success or empty,
	 *  or a failure wrapping an exception not instance of type {@code E}, {@code this} will be returned. 
	 *  If {@code this} is failed and the exception is instance of {@code E}, the failure is tried to be 
	 *  recovered using the {@code recovery} function. The result will be wrapped in a {@code Try.Success}, 
	 *  or {@code Try.Empty} if the returned recovery value is {@code null}. If the {@code recovery} throws 
	 *  an exception a {@code Try.Failure} wrapping the thrown exception.
	 */
	abstract def <E extends Throwable> Try<R> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery)

	/**
	 * This method tries to recover the {@code Try}, if it is failed with an exception instance of type 
	 * {@code exceptionType} or {@code exceptionType2}. 
	 * Note that it will not recover an empty {@code Try} or a {@code Try} of a different exception type than 
	 * {@code exceptionType} or {@code exceptionType2}. 
	 * If the given {@code recovery} function is {@code null}, {@code exceptionType} is {@code null} or 
	 * {@code exceptionType2} is {@code null} this method will return a failed {@code Try}
	 * that contains a {@code NullPointerException}. When this method is called on successful or
	 * empty {@code Try} instances or called on a failed {@code Try} that is <em>not</em> instance of 
	 * {@code exceptionType} or {@code exceptionType2}, the {@code this} reference will be returned. 
	 * If this method is called on a {@code Try.Failure} and 
	 * the wrapped exception is instance of {@code exceptionType} or {@code exceptionType2}, the {@code recovery} 
	 * method is called. If {@code recovery} returns a {@code null} value, an {@code Try.Empty} method 
	 * is returned, if it returns a non-{@code null} value a {@code Try.Success} value is returned 
	 * wrapping the result value.
	 * If {@code recovery} throws an exception, a {@code Try.Failure} will be returned wrapping 
	 * the thrown exception.
	 * <br><br>
	 * If this {@code Try} is a {@code Try.Failure} and this method returns a 
	 * {@code Try.Failure} (do to some reason stated above), the exception wrapped in the 
	 * original {@code Try.Failure} will be added as a {@link Throwable#getSuppressed() suppressed}
	 * exception to the exception wrapped in the {@code Try.Failure} returned from this method.
	 * @param exceptionType type of exception to recover by the given {@code recovery}.
	 * @param exceptionType2 type of exception to recover by the given {@code recovery}.
	 * @param recovery function to recover from an exception of type {@code exceptionType} or {@code exceptionType2}. 
	 * The function maps from the wrapped exception to a success value.
	 * @param <E> Type of exception to recover from.
	 * @return If recovery is {@code null} this method returns a {@code Try.Failure} completed with
	 *  a {@link NullPointerException}. If the {@code this} reference if {@code this} is a success or empty,
	 *  or a failure wrapping an exception not instance of type {@code exceptionType} or {@code exceptionType2}. 
	 *  If {@code this} is failed and the exception is instance of {@code exceptionType} or {@code exceptionType2},
	 *  the failure is tried to be recovered using the {@code recovery} function. The result will be wrapped 
	 *  in a {@code Try.Success}, or {@code Try.Empty} if the returned recovery value is {@code null}. 
	 *  If the {@code recovery} throws an exception a {@code Try.Failure} wrapping the thrown exception.
	 */
	abstract def <E extends Throwable> Try<R> tryRecoverFailure(Class<? extends E> exceptionType,
		Class<? extends E> exceptionType2, (E)=>R recovery)

	/**
	 * This method tries to recover the {@code Try}, if it is failed with an exception instance of any type 
	 * included in {@code exceptionTypes}. 
	 * Note that it will not recover an empty {@code Try} or a {@code Try} of a different exception type than 
	 * any of {@code exceptionTypes}. 
	 * If the given {@code recovery} function is {@code null} this method will return a failed {@code Try}
	 * that contains a {@code NullPointerException}. If {@code exceptionTypes} is {@code null} or any of the 
	 * class references in it is {@code null} than the returned {@code Try} will also be failed and contain
	 * a {@code NullPointerException}.
	 * When this method is called on successful or
	 * empty {@code Try} instances or called on a failed {@code Try} that is <em>not</em> instance of 
	 * any class in {@code exceptionTypes}, the {@code this} reference will be returned. 
	 * If this method is called on a {@code Try.Failure} and 
	 * the wrapped exception is instance of any type in {@code exceptionTypes}, the {@code recovery} 
	 * method is called. If {@code recovery} returns a {@code null} value, an {@code Try.Empty} method 
	 * is returned, if it returns a non-{@code null} value a {@code Try.Success} value is returned 
	 * wrapping the result value.
	 * If {@code recovery} throws an exception, a {@code Try.Failure} will be returned wrapping 
	 * the thrown exception.
	 * <br><br>
	 * If this {@code Try} is a {@code Try.Failure} and this method returns a 
	 * {@code Try.Failure} (do to some reason stated above), the exception wrapped in the 
	 * original {@code Try.Failure} will be added as a {@link Throwable#getSuppressed() suppressed}
	 * exception to the exception wrapped in the {@code Try.Failure} returned from this method. 
	 * @param exceptionTypes classes of exceptions to be recovered (via the returned {@code RecoveryStarter}).
	 * @param <E> Type of exception to recover from.
	 * @return call {@link RecoveryStarter#with(Functions.Function1) with} on the returned object to start recovery.
	 */
	abstract def <E extends Throwable> RecoveryStarter<E, R> tryRecoverFailure(
		Class<? extends E>... exceptionTypes)

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
	 * If this method is called on a successful {@code Try}, this method returns the 
	 * {@code this} reference. Otherwise the {@code recovery} is called and the resulting
	 * value will be wrapped in a new {@code Try}. If {@code recovery} is {@code null} 
	 * always returns a {@code Try} failed with a {@code NullPointerException}.<br>
	 * If recovery fails with an exception a failed {@code Try} is returned. 
	 * If the value returned by {@code recovery} is {@code null}, an empty {@code Try} will
	 * be returned from this method. If {@code recovery} throws an exception, and this try is 
	 * empty the thrown exception will be wrapped in a {@code Try.Failure} and returned from
	 * this method. <br>
	 * If this {@code Try} is a {@code Try.Failure} and this method returns a 
	 * {@code Try.Failure} (do to some reason stated above), the exception wrapped in the 
	 * original {@code Try.Failure} will be added as a {@link Throwable#getSuppressed() suppressed}
	 * exception to the exception wrapped in the {@code Try.Failure} returned from this method. 
	 * 
	 * @param recovery function providing a recovery value wrapped in the resulting {@code Try}.
	 * @return If recovery succeeds a {@code Try.Success} with the recovered value. If the recovered 
	 * value is {@code null} returns an {@code Try.Empty}. If recovery fails for some reason
	 * a {@code Try.Failure} will be returned.
	 */
	abstract def Try<R> tryRecover(=>R recovery)

	/**
	 * Recovers exceptions or {@code null} result values with value {@code recovery}.
	 * @param recovery value to be returned if this {@code Try} is failed or empty.
	 * @return if this is a {@code Try.Success} returns the wrapped value, otherwise
	 *  returns the given {@code recovery}
	 */
	abstract def R recover(R recovery)

	/**
	 * Provides exception to {@code handler} if this {@code Try} failed with
	 * an exception. Returns this {@code Try} unchanged. This can e.g. be handy for
	 * logging an exception.<br>
	 * If {@code handler} throws an exception it will be propagated to the caller of
	 * this method.
	 * @param handler the callback to be invoked with the wrapped exception if this {@code Try}
	 *  is a {@link Try.Failure}.
	 * @return same instance as {@code this}.
	 * @throws NullPointerException if {@code handler} is {@code null}
	 */
	abstract def Try<R> ifFailure((Throwable)=>void handler)

	/**
	 * Provides exception of type {@code E} to {@code handler} if this {@code Try} failed with
	 * an exception of type {@code E} and the exception is instance of {@code exceptionType}. 
	 * Returns this {@code Try} unchanged. This can e.g. be handy for logging an exception.<br>
	 * If {@code handler} throws an exception it will be propagated to the caller of
	 * this method.
	 * @param exceptionType type the wrapped exception is tested to be instance of
	 * @param handler the callback to be invoked with the wrapped exception if this {@code Try}
	 *  is a {@link Try.Failure} and the exception is instance of {@code exceptionType}
	 * @param <E> Type of exception to be checked for.
	 * @return same instance as {@code this}.
	 * @throws NullPointerException if {@code exceptionType} or {@code handler} is {@code null}
	 */
	abstract def <E extends Throwable> Try<R> ifFailure(Class<E> exceptionType, (E)=>void handler)

	/**
	 * Provides exception of type {@code E} to {@code handler} if this {@code Try} failed with
	 * an exception of type {@code E} and the exception is instance of {@code exceptionType} or {@code exceptionType2}.
	 * Returns this {@code Try} unchanged. This can e.g. be handy for logging an exception.<br>
	 * If {@code handler} throws an exception it will be propagated to the caller of
	 * this method.<br>
	 * If {@code handler} throws an exception it will be propagated to the caller of
	 * this method.
	 * @param exceptionType type the wrapped exception is tested to be instance of
	 * @param exceptionType2 type the wrapped exception is tested to be instance of
	 * @param handler the callback to be invoked with the wrapped exception if this {@code Try}
	 *  is a {@link Try.Failure} and the exception is instance of {@code exceptionType} or instance
	 *  of {@code exceptionType2}
	 * @param <E> Type of exception to be checked for.
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
	 * @param <E> Type of exception to be checked for.
	 * @return object to start check via the {@link FailureHandlerStarter#then(Procedures.Procedure1) then((E)=&gt;void)} method.
	 * @throws NullPointerException if {@code exceptionTypes}, any value in {@code exceptionTypes}, or {@code handler} is {@code null}
	 */
	abstract def <E extends Throwable> FailureHandlerStarter<E, R> ifFailure(Class<? extends E>... exceptionTypes)

	/**
	 * Calls the given {@code handler} with the result value if the Try 
	 * completed with a non {@code null} result value.<br>
	 * If {@code handler} throws an exception it will be propagated to the caller of
	 * this method.
	 * @param handler the callback to be called if this is an instance of {@code Try.Success}
	 *  with the wrapped successful value as the parameter
	 * @return same instance as {@code this}
	 * @throws NullPointerException if {@code handler} is {@code null}
	 */
	abstract def Try<R> ifSuccess((R)=>void handler)

	/**
	 * If operation was successful but returned {@code null} value, the given 
	 * {@code handler} will be called, otherwise the {@code handler} will not be called.<br>
	 * If {@code handler} throws an exception it will be propagated to the caller of
	 * this method.
	 * @param handler the callback to be called if this is an instance of {@code Try.Empty}
	 * @return same instance as {@code this}
	 * @throws NullPointerException if {@code handler} is {@code null}
	 */
	abstract def Try<R> ifEmpty(=>void handler)

	/**
	 * Calls {@code action} with the result of this try, if the Try
	 * holds a successful result and is not {@code null}. If {@code action}
	 * returns a value it will be wrapped in a {@code Try.Success}, or {@code Try.Empty}
	 * if the result is {@code null}, and returned. If {@code action} throws an exception,
	 * the exception will be wrapped in a {@code Try.Failure} and returned.
	 * If {@code action} is {@code null} a failed {@code Try} will be returned 
	 * wrapping around a {@code NullPointerException} (when called on failed {@code Try}
	 * instances the wrapped failure exception will be added as a suppressed exception to the 
	 * {@code NullPointerException}).
	 * If this {@code Try} is empty or failed, the {@code this} reference is returned.
	 * @param action operation to be performed if this Try holds a result that
	 *  is not {@code null}.
	 * @param <U> Type of successful result computed by {@code action} and returned wrapped in the returned {@code Try}.
	 * @return If {@code this} is a success, a {@code Try} wrapping the result of the {@code action} if it completes successful,
	 *   or holding an exception if the operation throws. If {@code this} is empty or a failure, returns the {@code this} reference.
	 */
	abstract def <U> Try<U> thenTry((R)=>U action)

	/**
	 * Calls {@code action} with the result of this try, if the Try
	 * holds a successful result and is not {@code null}. If {@code action}
	 * returns a {@code Optional} holding a value, this value will be wrapped in a 
	 * {@code Try.Success}. If the {@code Optional} is empty a {@code Try.Empty} will
	 * be returned. If the {@code action} returns {@code null} this method will return
	 * a failed {@code Try} wrapping a {@code NullPointerException}. 
	 * If {@code action} throws an exception, the exception will be wrapped in a 
	 * {@code Try.Failure} and returned.
	 * If {@code action} is {@code null} a failed {@code Try} will be returned 
	 * wrapping around a {@code NullPointerException} (when called on failed {@code Try}
	 * instances the wrapped failure exception will be added as a suppressed exception to the 
	 * {@code NullPointerException}).
	 * If this {@code Try} is empty or failed, the {@code this} reference is returned.
	 * @param action operation to be performed if this Try holds a result that
	 *  is not {@code null}.
	 * @param <U> Type of successful result computed by {@code action} and returned wrapped in the returned {@code Try}.
	 * @return If {@code this} is a success, a {@code Try} wrapping the result of the {@code action} if {@code action}
	 * completes successfully. This means it will hold a value, if {@code action} provides an Optional holding the result 
	 * value, or an empty try when an empty {@code Optional} is returned. The returned try will be  holding an exception 
	 * if the operation throws. If {@code this} is empty or a failure, returns the {@code this} reference. If {@code action}
	 * is {@code null} or returns {@code null} a {@code Try} failed with a {@code NullPointerException} will be returned.
	 */
	abstract def <U> Try<U> thenTryOptional((R)=>Optional<U> action)

	/**
	 * Calls {@code action} with the result of this try, if the Try
	 * holds a successful result and is not {@code null} and with a resource provided
	 * by {@code resourceProducer}. If {@code action} returns a value it will be wrapped 
	 * in a {@code Try.Success}, or {@code Try.Empty} if the result is {@code null}, and returned. 
	 * If {@code resourceProducer} or {@code action} throws an exception, the exception will be 
	 * wrapped in a {@code Try.Failure} and returned.<br>
	 * If {@code action} or {@code resourceProducer} is {@code null} a failed {@code Try} will be returned 
	 * wrapping around a {@code NullPointerException} (when called on failed {@code Try}
	 * instances the wrapped failure exception will be added as a suppressed exception to the 
	 * {@code NullPointerException}). Note that the resource provided by {@code resourceProducer}
	 * may be {@code null} and passed on to {@code action}. After this method's call to {@code action},
	 * the resource provided by {@code resourceProducer} will be closed if it is not {@code null}. It will
	 * even be closed when {@code action} throws an exception.<br>
	 * If this {@code Try} is empty or failed, the {@code this} reference is returned.
	 * @param resourceProducer creates a resource to be passed to {@code action} and closed 
	 *  after {@code action} is called. Most not be {@code null}.
	 * @param action operation to be performed if this Try holds a result that
	 *  is not {@code null}.
	 * @param <U> Type of successful result computed by {@code action} and returned wrapped in the returned {@code Try}.
	 * @param <I> Type of closeable resource provided by {@code resourceProvider} and passed on to {@code action}.
	 * @return If {@code this} is a success, a {@code Try} wrapping the result of the {@code action} if it completes successful,
	 *   or holding an exception if the operation throws. If {@code this} is empty or a failure, returns the {@code this} reference.
	 *   If {@code action} or {@code resourceProducer} is {@code null} a failed {@code Try} will be returned 
	 *   wrapping around a {@code NullPointerException}. If {@code action} or {@code resourceProducer} is throwing an
	 *   exception a {@code Try.Failure} will be returned holding the thrown exception.
	 */
	abstract def <U, I extends AutoCloseable> Try<U> thenTryWith(=>I resourceProducer, (I, R)=>U action)

	/**
	 * Calls {@code action} with the result of this {@code Try}, if the {@code Try}
	 * holds a successful result and is not {@code null}. The returned result of {@code action}
	 * will be returned. If {@code action} throws an exception,
	 * the exception will be wrapped in a {@code Try.Failure} and returned.
	 * If {@code action} is {@code null} a failed {@code Try} will be returned 
	 * wrapping around a {@code NullPointerException} (when called on failed {@code Try}
	 * instances the wrapped failure exception will be added as a suppressed exception to the 
	 * {@code NullPointerException}). If the result returned by {@code action} is {@code null}
	 * a {@code Try.Failure} will be returned wrapping around a {@code NullPointerException}.
	 * If this {@code Try} is empty or failed, the {@code this} reference is returned.
	 * @param action operation to be performed if this Try holds a result that
	 *  is not {@code null}.
	 * @param <U> type of successful result returned by {@code action}
	 * @return If {@code this} is a success, a {@code Try} wrapping the result of the {@code action} if it completes successful,
	 *   or holding an exception if the operation throws. If {@code this} is empty or a failure, returns the {@code this} reference.
	 */
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
	 * If this {@code Try} is a {@code Try.Failure} the given {@code mapper} will
	 * be called with a wrapped exception; the returned exception will be wrapped 
	 * in a new {@code Try.Failure} and be returned. If this method is not called
	 * on a {@code Try.Failure} the {@code mapper} will not be called and this {@code Try}
	 * will be returned from this method.<br><br>
	 * Should mapper throw an exception, the returned {@code Try} will be a failure
	 * wrapping the thrown exception. If {@code mapper} is {@code null} or returns {@code null} the returned {@code Try.failure}
	 * will a {@code NullPointerException}.
	 * <br>
	 * If this {@code Try} is a {@code Try.Failure} and this method returns a 
	 * {@code Try.Failure} (do to some reason stated above), the exception wrapped in the 
	 * original {@code Try.Failure} will be added as a {@link Throwable#getSuppressed() suppressed}
	 * exception to the exception wrapped in the {@code Try.Failure} returned from this method.
	 * 
	 * @param mapper method mapping an exception to a new exception. May throw an exception
	 * will be wrapped in a {@code Try.Failure}).
	 *  If {@code mapper} is {@code null} or returns {@code null} returns a failed try completed with a 
	 *  {@code NullPointerException}.
	 * @return If this {@code Try} is not failed returns the reference to this.
	 *  If {@code mapper} is {@code null} or returns {@code null} returns a 
	 * {@code Try.Failure} completed with a {@link NullPointerException}. If {@code mapper} 
	 * throws an exception, will return a {@code Try.Failure} completed completed with
	 * the thrown exception.
	 * If {@code mapper} returns properly, the returned exception will be wrapped
	 * in a {@code Try.Failure}.
	 */
	abstract def Try<R> tryMapException((Throwable)=>Throwable mapper)

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
	 * @param <U> Type of successful value that will nt be filtered out.
	 * @return the filtered version of this {@code Try} if it is a {@link Try.Success}
	 *  otherwise returns this {@code Try}.
	 * @throws NullPointerException if {@code test} is {@code null}.
	 */
	abstract def <U> Try<U> filterSuccess(Class<U> clazz)

	/**
	 * This method turns a {@code Try&lt;R&gt;} into a {@code Try&lt;R&gt;}. The three parameters
	 * handle the three cases successful, failed and empty. If the executed transformer method 
	 * returns a non-{@code null} value, this method returns a {@code Try.Success} wrapping the 
	 * value returned by the transformer. If the transformer returns a {@code null} value, this method
	 * will return a {@code Try.Empty}. If the transformer throws an exception, this method will 
	 * return a {@code Try.Failure} wrapping the thrown exception.<br>
	 * If {@code resultTransformer} or {@code exceptionTranformer} or {@code emptyTransformer}
	 * is {@code null}, this method will return a {@code Try.Failure} wrapping a {@code NullPointerException}.
	 * If the executed transformer function throws an exception a {@code Try.Failure} is returned
	 * wrapping the thrown exception.<br>
	 * If this method returns a {@code Try.Failure} and this {@code Try} is failed, the exception
	 * wrapped in the returned {@code Try} will have the exception wrapped by this {@code Try}
	 * added to the list of {@code suppressed} exceptions.
	 * 
	 * @param resultTransformer function to turn a successful result to a value of type {@code U}.
	 *  must not be {@code null}.
	 * @param exceptionTranformer function to turn a failed result to a value of type {@code U}.
	 *  must not be {@code null}.
	 * @param emptyTransformer function to turn an empty result to a value of type {@code U}.
	 *  must not be {@code null}.
	 * @param <U> type of successful result wrapped by the returned {@code Try}.
	 * @return {@code Try.Success} if the executed transformer returns a non-{@code null} value;
	 *  {@code Try.Empty} if the transformer returns a {@code null} value; a {@code Try.Failure}
	 *  if the transformer throws an exception; a {@code Try.Failure} wrapping a {@code NullPointerException}
	 *  if any of the {@code transformer} methods is {@code null}.
	 */
	abstract def <U> Try<U> tryTransform((R)=>U resultTransformer, (Throwable)=>U exceptionTranformer,
		=>U emptyTransformer)

	/**
	 * Returns empty optional if Try completed failed or with a
	 * {@code null} value. Otherwise returns an optional with the computed
	 * result value present.
	 * @return an {@code Optional} holding the captured success value, if this 
	 *  {@code Try} is a {@link Try.Success}, or an empty {@code Optional}
	 *  if this {@code Try} is no {@code Try.Success}.
	 */
	abstract def Optional<R> getResult()

	/**
	 * Returns an empty stream if Try completed failed or with 
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
	 * @param exceptionProvider provides the exception to be thrown if this element is a {@link Try.Empty}.
	 * @param <E> Type of exception to be thrown if this is a {@link Try.Empty}
	 * @return the value wrapped in the {@link Try.Success}.
	 * @throws E if this Try is empty
	 */
	abstract def <E extends Exception> R getOrThrow(=>E exceptionProvider) throws E

	/**
	 * Returns empty optional if Try completed successfully (holding a result) or with a
	 * {@code null} value. Otherwise returns an optional with the exception captured
	 * in this failed {@code Try}.
	 * @return an {@code Optional} holding the captured exception, if this 
	 *  {@code Try} is a {@link Try.Failure}, or an empty {@code Optional}
	 *  if this {@code Try} is no {@code Try.Failure}.
	 */
	abstract def Optional<Throwable> getException()

	/**
	 * Returns given {@code Try<T>} as {@code Try<U>} where {@code U} is supertype of {@code T}.
	 * This is a safe operation, since the user cannot place own values of {@code R} in a {@code Try}.
	 * @param t is the {@code Try} to be casted to a {@code Try} of a super-type of {@code R}.
	 * @param <U> Super-type of {@code R}
	 * @param <R> Type of successful value of {@code t}
	 * @return the same {@code Try} as {@code t} but casted to a {@code Try&lt;U&gt;}
	 * @see Try#upcast(Success)
	 * @see Try#upcast(Empty)
	 * @see Try#upcast(Failure)
	 */
	static def <U, R extends U> Try<U> upcast(Try<R> t) {
		t as Try<?> as Try<U>
	}

	/**
	 * Returns given {@code Success<T>} as {@code Success<U>} where {@code U} is supertype of {@code T}.
	 * This is a safe operation, since the user cannot place own values of {@code R} in a {@code Success}.
	 * @param t {@code Success} to be upcasted to {@code Success&lt;U&gt;}
	 * @param <U> Super-type of {@code R}
	 * @param <R> Type of successful value of {@code t}
	 * @return the same {@code Success} as {@code t} but casted to a {@code Success&lt;U&gt;}
	 * @see Try#upcast(Try)
	 * @see Try#upcast(Empty)
	 * @see Try#upcast(Failure)
	 */
	static def <U, R extends U> Success<U> upcast(Success<R> t) {
		t as Success<?> as Success<U>
	}

	/**
	 * Returns given {@code Empty<T>} as {@code Empty<U>} where {@code U} is supertype of {@code T}.
	 * This is a safe operation, since the user cannot place own values of {@code R} in a {@code Empty}.
	 * @param t {@code Empty} to be upcasted to {@code Empty&lt;U&gt;}
	 * @param <U> Super-type of {@code R}
	 * @param <R> Type of successful value of {@code t}
	 * @return the same {@code Empty} as {@code t} but casted to a {@code Empty&lt;U&gt;}
	 * @see Try#upcast(Success)
	 * @see Try#upcast(Try)
	 * @see Try#upcast(Failure)
	 */
	static def <U, R extends U> Empty<U> upcast(Empty<R> t) {
		t as Empty<?> as Empty<U>
	}

	/**
	 * Returns given {@code Failure<T>} as {@code Failure<U>} where {@code U} is supertype of {@code T}.
	 * This is a safe operation, since the user cannot place own values of {@code R} in a {@code Failure}.
	 * @param t {@code Failure} to be upcasted to {@code Failure&lt;U&gt;}
	 * @param <U> Super-type of {@code R}
	 * @param <R> Type of successful value of {@code t}
	 * @return the same {@code Failure} as {@code t} but casted to a {@code Failure&lt;U&gt;}
	 * @see Try#upcast(Success)
	 * @see Try#upcast(Empty)
	 * @see Try#upcast(Try)
	 */
	static def <U, R extends U> Failure<U> upcast(Failure<R> t) {
		t as Failure<?> as Failure<U>
	}

	static def <T> void requireNonNullElements(T[] array, String msg) {
		array.requireNonNull(msg)
		for (var i = 0; i < array.length; i++) {
			array.get(i).requireNonNull("array element must not be null")
		}
	}

	final static class Success<R> extends Try<R> {

		val R result

		private new(R result) {
			this.result = result
		}

		override int hashCode() {
			val int prime = 31
			var int result = 13
			// note that result must not be null
			result = prime * result + this.result.hashCode()
			result
		}

		override boolean equals(Object obj) {
			if (this === obj)
				return true
			if (obj === null || this.getClass() !== obj.getClass())
				return false
	
			val other = obj as Success<?>
			// no null-check needed, result must not be null
			result.equals(other.result)
		}

		/**
		 * Tests if the wrapped value is instance of the given class {@code clazz}.
		 * @param clazz the class used to test if the value is instance of.
		 * @return {@code true} if the wrapped value is instance of {@code clazz}. Must not be {@code null}.
		 * @throws NullPointerException if {@code clazz} is {@code null}.
		 */
		def boolean is(Class<?> clazz) {
			clazz.requireNonNull("clazz must not be null")
			clazz.isInstance(result)
		}

		/**
		 * Calls the given {@code consumer} if the wrapped value is instance of 
		 * the given Class {@code clazz}.
		 * @param clazz Class the wrapped value will be checked to be instance of. Must not be {@code null}.
		 * @param consumer will be called with the wrapped value if it is instance of {@code clazz}. 
		 *  Must not be {@code null}.
		 * @param <U> type the wrapped value will be tested to be instance of
		 * @return the {@code this} reference.
		 * @throws NullPointerException if {@code clazz} or {@code consumer} is {@code null}
		 */
		def <U> Success<R> ifInstanceOf(Class<U> clazz, (U)=>void consumer) {
			clazz.requireNonNull("clazz must not be null")
			consumer.requireNonNull("clazz must not be null")
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
			switch recovery {
				case (recovery === null):
					completedFailed(new NullPointerException("recovery must not be null"))
				case exceptionType === null:
					completedFailed(new NullPointerException("exceptionType must not be null"))
				default:
					this
			}
		}

		override <E extends Throwable> Try<R> tryRecoverFailure(Class<? extends E> exceptionType,
			Class<? extends E> exceptionType2, (E)=>R recovery) {
			if (exceptionType === null) {
				return completedFailed(new NullPointerException("exceptionType must not be null"))
			}
			if (exceptionType2 === null) {
				return completedFailed(new NullPointerException("exceptionType2 must not be null"))
			}
			if (recovery === null) {
				return completedFailed(new NullPointerException("recovery must bot be null"))
			}
			this
		}

		override <E extends Throwable> tryRecoverFailure(Class<? extends E>... exceptionTypes) {
			if (exceptionTypes === null) {
				return [
					val npe = new NullPointerException("exceptionTypes must not be null")
					completedFailed(npe)
				]
			}
			try {
				exceptionTypes.forEach [ e, i |
					e.requireNonNull['''Element in exceptionTypes at index «i» must not be null''']
				]
			} catch (NullPointerException npe) {
				return [
					completedFailed(npe)
				]
			}
			val result = this;
			[
				if (it === null) {
					completedFailed(new NullPointerException("recovery must not be null"))
				} else {
					result
				}
			]
		}

		override tryRecoverFailure((Throwable)=>R recovery) {
			if (recovery === null) {
				completedFailed(new NullPointerException("recovery must not be null"))
			} else {
				this
			}
		}

		override Try<R> tryRecoverEmpty(=>R recovery) {
			if (recovery === null) {
				completedFailed(new NullPointerException("recovery must not be null"))
			} else {
				this
			}
		}

		override Try<R> recoverEmpty(R recovery) {
			this
		}

		override tryRecover(=>R recovery) {
			if (recovery === null) {
				completedFailed(new NullPointerException("recovery must not be null"))
			} else {
				this
			}
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
			exceptionTypes.requireNonNullElements("exceptionTypes must not be null");
			[
				it.requireNonNull("handler must not be null")
				this
			]
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

		override ifEmpty(=>void handler) {
			handler.requireNonNull("handler must not be null")
			// not empty
			this
		}

		override <U> thenTry((R)=>U action) {
			tryCall [
				action.requireNonNull("action must not be null").apply(result)
			]
		}

		override <U, I extends AutoCloseable> thenTryWith(=>I resourceProducer, (I, R)=>U action) {
			if(action === null) {
				return completedFailed(new NullPointerException("action must not be null"))
			}
			tryWith(resourceProducer) [ res |
				action.apply(res, result)
			]
		}

		override <U> thenTryFlat((R)=>Try<U> action) {
			if(action === null) {
				return completedFailed(new NullPointerException("action must not be null"))
			}
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

		override Try<R> tryMapException((Throwable)=>Throwable mapper) {
			if (mapper === null) {
				completedFailed(new NullPointerException("mapper must not be null"))
			} else {
				// nothing to map
				this
			}
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

		override <U> Try<U> tryTransform((R)=>U resultTransformer, (Throwable)=>U exceptionTranformer,
			=>U emtpyTransformer) {
			tryCall [
				exceptionTranformer.requireNonNull("exceptionTranformer must not be null")
				emtpyTransformer.requireNonNull("emtpyTransformer must not be null")
				resultTransformer.requireNonNull("resultTransformer must not be null").apply(result)
			]
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
			if(action === null) {
				completedFailed(new NullPointerException("action must not be null"))
			} else {
				tryOptional[|action.apply(result)]
			}
		}

		override iterator() {
			Iterators.forArray(result)
		}

		override toString() {
			'''Try.Success{ result=«this.result»  }'''
		}

	}

	final static class Empty<R> extends Try<R> {
		static val Empty<?> INSTANCE = new Empty

		private def <U> Empty<U> cast() {
			this as Empty<?> as Empty<U>
		}

		override <E extends Throwable> Try<R> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			switch (recovery) {
				case recovery === null:
					completedFailed(new NullPointerException("recovery must not be null"))
				case exceptionType === null:
					completedFailed(new NullPointerException("exceptionType must not be null"))
				default:
					// No exception to recover from
					this
			}
		}

		override <E extends Throwable> Try<R> tryRecoverFailure(Class<? extends E> exceptionType,
			Class<? extends E> exceptionType2, (E)=>R recovery) {
			if (exceptionType === null) {
				return completedFailed(new NullPointerException("exceptionType must not be null"))
			}
			if (exceptionType2 === null) {
				return completedFailed(new NullPointerException("exceptionType2 must not be null"))
			}
			if (recovery === null) {
				return completedFailed(new NullPointerException("recovery must not be null"))
			}
			this
		}

		override <E extends Throwable> tryRecoverFailure(Class<? extends E>... exceptionTypes) {
			if (exceptionTypes === null) {
				return [
					val npe = new NullPointerException("exceptionTypes must not be null")
					completedFailed(npe)
				]
			}
			try {
				exceptionTypes.forEach [ e, i |
					e.requireNonNull['''Element in exceptionTypes at index «i» must not be null''']
				]
			} catch (NullPointerException npe) {
				return [
					completedFailed(npe)
				]
			}
			val result = this;
			[ recovery |
				if (recovery === null) {
					completedFailed(new NullPointerException("recovery must not be null"))
				} else {
					result
				}
			]
		}

		override Try<R> tryRecoverFailure((Throwable)=>R recovery) {
			if (recovery === null) {
				completedFailed(new NullPointerException("recovery must not be null"))
			} else {
				// No exception to recover from
				this
			}
		}

		override Try<R> tryRecoverEmpty(=>R recovery) {
			if (recovery === null) {
				completedFailed(new NullPointerException("recovery must not be null"))
			} else {
				tryCall(recovery)
			}
		}

		override Try<R> recoverEmpty(R recovery) {
			completed(recovery)
		}

		override Try<R> tryRecover(=>R recovery) {
			if (recovery === null) {
				completedFailed(new NullPointerException("recovery must not be null"))
			} else {
				tryCall(recovery)
			}
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
			exceptionTypes.requireNonNullElements("exceptionTypes must not be null");
			[
				it.requireNonNull("handler must not be null")
				this
			]
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

		override Empty<R> ifEmpty(=>void handler) {
			handler.requireNonNull("handler must not be null")
			handler.apply
			this
		}

		override <U> Try<U> thenTry((R)=>U action) {
			if (action === null) {
				completedFailed(new NullPointerException("action must not be null"))
			} else {
				cast
			}
		}

		override <U, I extends AutoCloseable> Try<U> thenTryWith(=>I resourceProducer, (I, R)=>U action) {
			if(action === null) {
				return completedFailed(new NullPointerException("action must not be null"))
			}
			if(resourceProducer === null) {
				return completedFailed(new NullPointerException("resourceProvider must not be null"))
			}
			cast
		}

		override <U> Try<U> thenTryFlat((R)=>Try<U> action) {
			if(action === null) {
				return completedFailed(new NullPointerException("action must not be null"))
			}
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

		override Try<R> tryMapException((Throwable)=>Throwable mapper) {
			if (mapper === null) {
				completedFailed(new NullPointerException("mapper must not be null"))
			} else {
				this
			}
		}

		override Empty<R> filterSuccess(Predicate<R> test) {
			test.requireNonNull("predicate must not be null")
			this
		}

		override <U> Empty<U> filterSuccess(Class<U> clazz) {
			clazz.requireNonNull("clazz must not be null")
			cast
		}

		override <U> Try<U> tryTransform((R)=>U resultTransformer, (Throwable)=>U exceptionTranformer,
			=>U emptyTransformer) {
			tryCall [
				resultTransformer.requireNonNull("resultTransformer must not be null")
				exceptionTranformer.requireNonNull("exceptionTranformer must not be null")
				emptyTransformer.requireNonNull("emptyTransformer must not be null").apply
			]
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

		override <E extends Exception> getOrThrow(=>E exceptionProvider) throws E {
			throw exceptionProvider.apply
		}

		override getException() {
			none
		}

		override <U> Try<U> thenTryOptional((R)=>Optional<U> action) {
			if(action === null) {
				completedFailed(new NullPointerException("action must not be null"))
			} else {
				cast
			}
		}

		override iterator() {
			Collections.emptyIterator
		}

		override toString() {
			'''Try.Empty{}'''
		}

	}

	final static class Failure<R> extends Try<R> {
		val Throwable e
		
		override int hashCode() {
			val int prime = 31
			var int result = 19
			// note that e must not be null
			result = prime * result + this.e.hashCode()
			result
		}

		override boolean equals(Object obj) {
			if (this === obj)
				return true
			if (obj === null || this.getClass() !== obj.getClass())
				return false
	
			val other = obj as Failure<?>
			// no null-check needed, e must not be null
			e.equals(other.e)
		}

		private new(Throwable e) {
			this.e = e
		}

		private def <U> cast() {
			this as Failure<?> as Failure<U>
		}

		def Throwable get() {
			e
		}

		/**
		 * Tests if the wrapped exception is instance of the given {@code exceptionType}.
		 * @param exceptionType used to check if the wrapped exception is instance of this {@code Class}. Must not be {@code null}.
		 * @return {@code true} if the wrapped exception is instance of {@code exceptionType}, {@code false} otherwise.
		 * @throws NullPointerException if {@code exceptionType} is {@code null}.
		 */
		def boolean is(Class<?> exceptionType) {
			exceptionType.requireNonNull("exceptionType must not be null")
			exceptionType.isInstance(e)
		}

		override <E extends Throwable> tryRecoverFailure(Class<E> exceptionType, (E)=>R recovery) {
			switch (recovery) {
				case recovery === null: {
					var nep = new NullPointerException("recovery must not be null")
					nep.addSuppressed(this.e)
					completedFailed(nep)
				}
				case exceptionType === null: {
					val nep = new NullPointerException("exceptionType must not be null")
					nep.addSuppressed(this.e)
					completedFailed(nep)
				}
				case exceptionType.isInstance(e):
					try {
						val result = recovery.apply(e as E)
						completed(result)
					} catch (Throwable t) {
						t.addSuppressed(this.e)
						completedFailed(t)
					}
				default:
					this
			}
		}

		override <E extends Throwable> tryRecoverFailure(Class<? extends E> exceptionType,
			Class<? extends E> exceptionType2, (E)=>R recovery) {
			if (exceptionType === null) {
				val npe = new NullPointerException("exceptionType must not be null")
				npe.addSuppressed(this.e)
				return completedFailed(npe)
			}
			if (exceptionType2 === null) {
				val npe = new NullPointerException("exceptionType2 must not be null")
				npe.addSuppressed(this.e)
				return completedFailed(npe)
			}
			if (recovery === null) {
				val npe = new NullPointerException("recovery must bot be null")
				npe.addSuppressed(this.e)
				return completedFailed(npe)
			}
			if (exceptionType.isInstance(e) || exceptionType2.isInstance(e)) {
				try {
					val result = recovery.apply(e as E)
					completed(result)
				} catch (Throwable t) {
					t.addSuppressed(this.e)
					completedFailed(t)
				}
			} else {
				this
			}
		}

		override tryRecoverFailure((Throwable)=>R recovery) {
			if (recovery === null) {
				completedFailed(new NullPointerException("recovery must not be null"))
			} else {
				try {
					val recovered = recovery.apply(e)
					completed(recovered)
				} catch (Throwable t) {
					t.addSuppressed(e)
					completedFailed(t)
				}
			}
		}

		override <E extends Throwable> tryRecoverFailure(Class<? extends E>... exceptionTypes) {
			if (exceptionTypes === null) {
				return [
					val npe = new NullPointerException("exceptionTypes must not be null")
					npe.addSuppressed(this.e)
					completedFailed(npe)
				]
			}
			try {
				exceptionTypes.forEach [ e, i |
					e.requireNonNull['''Element in exceptionTypes at index «i» must not be null''']
				]
			} catch (NullPointerException npe) {
				npe.addSuppressed(this.e)
				return [
					completedFailed(npe)
				]
			}
			val _this = this;
			[ recovery |
				if (recovery === null) {
					val npe = new NullPointerException("recovery must not be null")
					npe.addSuppressed(this.e)
					return Try.completedFailed(npe)
				}
				if (exceptionTypes.exists[isInstance(e)]) {
					try {
						val recovered = recovery.apply(e as E)
						completed(recovered)
					} catch (Throwable t) {
						t.addSuppressed(this.e)
						completedFailed(t)
					}
				} else {
					_this
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
			exceptionTypes.requireNonNullElements("exceptionTypes must not be null");
			[
				it.requireNonNull("handler must not be null")
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

		override Failure<R> ifEmpty(=>void handler) {
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
			if (action === null) {
				val npe = new NullPointerException("action must not be null")
				npe.addSuppressed(this.e)
				completedFailed(npe)
			} else {
				// no result
				cast
			}
		}

		override <U, I extends AutoCloseable> Failure<U> thenTryWith(=>I resourceProducer, (I, R)=>U action) {
			if(action === null) {
				val npe = new NullPointerException("action must not be null")
				npe.addSuppressed(this.e)
				return completedFailed(npe)
			}
			if(resourceProducer === null) {
				val npe = new NullPointerException("resourceProvider must not be null")
				npe.addSuppressed(this.e)
				return completedFailed(npe)
			}
			cast
		}

		override <U> Failure<U> thenTryFlat((R)=>Try<U> action) {
			if(action === null) {
				val npe = new NullPointerException("action must not be null")
				npe.addSuppressed(this.e)
				return completedFailed(npe)
			}
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

		override Failure<R> tryMapException((Throwable)=>Throwable mapper) {
			try {
				if (mapper === null) {
					val nep = new NullPointerException("mapper must not be null")
					nep.addSuppressed(this.e)
					completedFailed(nep)
				} else {
					val newException = mapper.apply(e)
					if (newException === null) {
						val npe = new NullPointerException("mapped exception must not be null")
						npe.addSuppressed(e)
						completedFailed(npe)
					} else {
						completedFailed(newException)
					}
				}
			} catch (Exception mappingException) {
				mappingException.addSuppressed(e)
				completedFailed(mappingException)
			}
		}

		override Failure<R> filterSuccess(Predicate<R> test) {
			test.requireNonNull("test must not be null")
			this
		}

		override <U> Failure<U> filterSuccess(Class<U> clazz) {
			clazz.requireNonNull("clazz must not be null")
			cast
		}

		override <U> Try<U> tryTransform((R)=>U resultTransformer, (Throwable)=>U exceptionTranformer,
			=>U emptyTransformer) {
			try {
				resultTransformer.requireNonNull("resultTransformer must not be null")
				emptyTransformer.requireNonNull("emptyTransformer must not be null")
				val result = exceptionTranformer.requireNonNull("exceptionTranformer must not be null").apply(e)
				completed(result)
			} catch(Throwable t) {
				t.addSuppressed(this.e)
				completedFailed(t)
			}
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

		override Failure<R> tryRecoverEmpty(=>R recovery) {
			if (recovery === null) {
				val nep = new NullPointerException("recovery must not be null")
				nep.addSuppressed(this.e)
				completedFailed(nep)
			} else {
				this
			}
		}

		override Failure<R> recoverEmpty(R recovery) {
			this
		}

		override tryRecover(=>R recovery) {
			if (recovery === null) {
				val nep = new NullPointerException("recovery must not be null")
				nep.addSuppressed(this.e)
				completedFailed(nep)
			} else {
				try {
					completed(recovery.apply)
				} catch (Throwable t) {
					t.addSuppressed(e)
					completedFailed(t)
				}
			}
		}

		override recover(R recovery) {
			recovery
		}

		override <U> thenTryOptional((R)=>Optional<U> action) {
			if(action === null) {
				val npe = new NullPointerException("action must not be null")
				npe.addSuppressed(this.e)
				completedFailed(npe)
			} else {
				cast
			}
		}

		override iterator() {
			Collections.emptyIterator
		}

		override toString() {
			'''Try.Failure{ error=«this.e» }'''
		}
	}
}

/**
 * This interface is used as the return type of {@code Try#ifFailure(Class[])}.
 * It is used to trigger a handler via the {@link FailureHandlerStarter#then(Procedures.Procedure1) then((E)=&gt;void handler)}
 * method, if the captured exception matches one of the classes given to the {@code ifFailure} method
 * @see Try#ifFailure(Class[])
 */
@FunctionalInterface
interface FailureHandlerStarter<E extends Throwable, T> {

	/**
	 * Triggers a handler via this method if the {@code FailureHandlerStarter} was 
	 * returned from a {@code Try.Failure} and the wrapped exception is of type {@code E}.
	 * Will return the {@code Try} that was used to produce this {@code FailureHandlerStarter}.<br>
	 * If {@code handler} throws an exception it will be propagated to the caller of
	 * this method.
	 * @param handler callback to be invoked if wrapped exception is of type {@code E}
	 * @return the {@code Try} object that was used to create this {@code FailureHandlerStarter}
	 */
	def Try<T> then((E)=>void handler)
}

/**
 * Instances of this interface can be used to recover a failed {@link Try}
 * instance via the {@link RecoveryStarter#with(Functions.Function1) with} method.
 * @see Try#tryRecoverFailure(Class[])
 */
@FunctionalInterface
interface RecoveryStarter<E extends Throwable, R> {

	/**
	 * Starts the recovery of a failed {link Try}, if the exception class is matching 
	 * one of the classes passed to {@link Try#tryRecoverFailure(Class[]) tryRecoverFailure(Class<? extends E>...)}. 
	 * The wrapped exception will be passed to 
	 * @param recovery method providing the recovery value based on the exception
	 *  that let the originating {@code Try} fail.
	 * @return If recovery is {@code null} this method returns a {@code Try.Failure} completed with
	 *  a {@link NullPointerException}. If the originating {@code Try} is a success or empty,
	 *  or a failure wrapping an exception not instance of the filtering exception types 
	 * (see {@link Try#tryRecoverFailure(Class[])}) returns the originating {@code Try}. 
	 * If  the originating {@code Try} is failed and the exception is instance of the filtering exceptions,
	 * the failure is tried to be recovered using the {@code recovery} function. The result will be wrapped 
	 * in a {@code Try.Success}, or {@code Try.Empty} if the returned recovery value is {@code null}. 
	 * If the {@code recovery} throws an exception a {@code Try.Failure} wrapping the thrown exception.
	 * @see Try#tryRecoverFailure(Class[])
	 */
	def Try<R> with((E)=>R recovery)
}
