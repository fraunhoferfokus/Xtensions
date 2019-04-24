/*******************************************************************************
 * Copyright (c) 2017 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.objects

import java.util.function.Supplier
import static extension java.util.Objects.*

/**
 * Provides methods (meant to be used as extension methods) on objects in general. 
 * @since 1.3
 */
final class Objects {

	/**
	 * Java 9 forward compatible alias for 
	 * {@link Objects#recoverNull(Object,org.eclipse.xtext.xbase.lib.Functions.Function0) recoverNull(T, =>T)}.
	 * See documentation of <a href="https://docs.oracle.com/javase/9/docs/api/java/util/Objects.html#requireNonNullElseGet-T-java.util.function.Supplier-">java.utils.Objects#requireNonNullElseGet​</a>.
	 * @param obj is being tested on {@code null} and will be returned from this 
	 *  method if not so.
	 * @param supplier will be called from this method if {@code obj} is 
	 *  {@code null} if the result is not {@code null} it will be returned.
	 * @return {@code obj} if it is null, otherwise {@code supplier.get()} is called
	 * and the result will be returned if it is not {@code null}.
	 * @param <T> type of {@code obj} and element returned by {@code supplier} is instance of
	 * @throws NullPointerException if 
	 * 	<ul>
	 * 		<li>{@code supplier} is {@code null}</li>
	 * 		<li>{@code obj} and {@code supplier.get()} is {@code null}</li>
	 * 	</ul>
	 * @since 1.3
	 */
	static def <T> T requireNonNullElseGet​(T obj, Supplier<? extends T> supplier) {
		supplier.requireNonNull("supplier must not be null")
		val =>T recovery = supplier
		obj.recoverNull(recovery)
	}

	/**
	 * Returns the parameter {@code toTest} if it is <em>not</em> {@code null}
	 * otherwise calls the {@code recoveryProvider} function; if the result of the call 
	 * is not {@code null} it will be returned. If both {@code toTest} and the
	 * provided fallback from {@code recoveryProvider} are {@code null} a {@code NullPointerException}
	 * will be thrown.
	 * @param toTest is being tested on {@code null} and will be returned from this 
	 *  method if not so.
	 * @param recoveryProvider will be called from this method if {@code toTest} is 
	 *  {@code null} if the result is not {@code null} it will be returned.
	 * @param <T> type of {@code toTest} and element returned by {@code recoveryProvider} is instance of
	 * @return {@code toTest} if it is null, otherwise {@code recoveryProvider} is called
	 * and the result will be returned if it is not {@code null}.
	 * @throws NullPointerException if 
	 * 	<ul>
	 * 		<li>{@code recoveryProvider} is {@code null}</li>
	 * 		<li>{@code toTest} and result of {@code recoveryProvider} call is {@code null}</li>
	 * 	</ul>
	 * @since 1.3
	 */
	static def <T> T recoverNull(T toTest, =>T recoveryProvider) {
		recoveryProvider.requireNonNull("recovery supplier must not be null")
		if (toTest !== null) {
			toTest
		} else {
			recoveryProvider.apply.requireNonNull
		}
	}

	/**
	 * Java 9 forward compatible alias for 
	 * {@link Objects#recoverNull(Object,Object) recoverNull(T,T)}.
	 * See documentation of <a href="https://docs.oracle.com/javase/9/docs/api/java/util/Objects.html#requireNonNullElse-T-T-">java.utils.Objects#requireNonNullElse​</a>
	 * @param obj object to be tested for {@code null}
	 * @param defaultObj object returned as fallback if {@code obj} is {@code null}
	 * @param <T> Type of {@code obj} and {@code defaultObj}
	 * @return {@code obj} if it is not {@code null}, otherwise {@code defaultObj} if it is not {@code null}
	 * @throws NullPointerException if both parameters are {@code null}
	 */
	@Inline("de.fhg.fokus.xtensions.objects.Objects.recoverNull($1, $2)")
	static def <T> T requireNonNullElse​(T obj, T defaultObj) {
		obj.recoverNull(defaultObj)
	}

	/**
	 * Returns the parameter {@code toTest} if it is <em>not</em> {@code null}
	 * otherwise {@code recovery} if it is not {@code null}. If both parameters
	 * are {@code null} a {@code NullPointerException} will be thrown.
	 * @param toTest is being tested on {@code null} and will be returned from this 
	 *  method if not so.
	 * @param recovery will be returned from this method if {@code toTest} is 
	 *  {@code null} and {@code recovery} is not {@code null}.
	 * @param <T> Type of {@code toTest} and {@code recovery}
	 * @return {@code toTest} if it is null, otherwise {@code recovery} if it is not {@code null}.
	 * @throws NullPointerException if both parameters are {@code null}
	 * @since 1.3
	 */
	static def <T> T recoverNull(T toTest, T recovery) {
		if (toTest !== null) {
			toTest
		} else {
			recovery.requireNonNull
		}
	}

	/**
	 * This method calls the given {@code consumer} with {@code t}, if 
	 * {@code t !== null}.<br>
	 * This method is useful when using a value in a long
	 * {@code ?.} navigation chain. Instead of buffering the
	 * value into a variable and checking the variable for {@code null}
	 * or navigating the chain again.
	 * @param t object tested for being {@code null}
	 * @param consumer will be called with {@code t} if it is not {@code null}. 
	 *  This parameter must not be {@code null}.
	 * @param <T> Type of parameter {@code t}
	 * @throws NullPointerException if {@code consumer} is {@code null}
	 * @since 1.3
	 */
	static def <T> void ifNotNull(T t, (T)=>void consumer) {
		consumer.requireNonNull("consumer must not be null")
		if (t !== null) {
			consumer.apply(t)
		}
	}

	/**
	 * This method will test if parameter {@code o} is instance
	 * of the given {@code type}. If so, the object will be casted
	 * to this type and returned, otherwise this method will return 
	 * {@code null}. This is the same behavior as the Xtend keyword
	 * {@code as}, but can be handy when used as an extension method
	 * in a (null-safe) navigation chain.
	 * @param o the object to be tested to be instance of {@code type}
	 * @param type the class {@code o} is checked to be instance of.
	 * @param <T> Type parameter {@code o} is tested to be instance of
	 * @return either {@code o} casted as {@code type} if {@code o instanceof type} 
	 *   and {@code null} otherwise
	 * @throws NullPointerException if {@code type} is {@code null}
	 */
	static def <T> T asType(Object o, Class<T> type) {
		val nullMsg = "type must not be null"
		if (type.requireNonNull(nullMsg).isInstance(o)) {
			type.cast(o)
		} else {
			null
		}
	}
}
