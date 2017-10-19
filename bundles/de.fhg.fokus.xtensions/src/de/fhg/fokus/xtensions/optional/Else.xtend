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
package de.fhg.fokus.xtensions.optional

import java.util.function.BiConsumer
import java.util.function.Consumer

/** 
 * Class with method {@link Else#elseDo(Runnable) elseDo(Runnable)}, which either
 * executes the given runnable or not, depending on the sub-class.
 * @see OptionalExtensions#whenPresent(java.util.Optional, Consumer)
 * @see OptionalIntExtensions#whenPresent(java.util.OptionalInt, java.util.function.IntConsumer)
 * @see OptionalLongExtensions#whenPresent(java.util.OptionalLong, java.util.function.LongConsumer)
 * @see OptionalDoubleExtensions#whenPresent(java.util.OptionalDouble, java.util.function.DoubleConsumer)
 */
abstract class Else {
	/*package*/ static final package Else PRESENT = new Else() {
		override void elseDo(Runnable elseBlock) {
		}

		override <T> void elseDo(T value, Consumer<T> elseBlock) {
		}

		override <T, U> void elseDo(T t, U u, BiConsumer<T, U> elseBlock) {
		}
	}
	/*package*/ static final package Else NOT_PRESENT = new Else() {
		override void elseDo(Runnable elseBlock) {
			elseBlock.run()
		}

		override <T> void elseDo(T value, Consumer<T> elseBlock) {
			elseBlock.accept(value)
		}

		override <T, U> void elseDo(T t, U u, BiConsumer<T, U> elseBlock) {
			elseBlock.accept(t, u)
		}
	}

	private new() {
	}

	/** 
	 * This method either executes the given {@code elseBlock} or not,
	 * based on the sub-class of {@code Else}.
	 * @param elseBlock code to be executed or not.
	 */
	def abstract void elseDo(Runnable elseBlock)

	/** 
	 * This method either executes the given {@code elseBlock} or not,
	 * based on the sub-class of {@code Else}. The given {@code val} will
	 * be forwarded to the elseBlock on execution. This allows the usage of non-capturing
	 * lambdas, allowing better execution performance.
	 * @param value value to be forwarded to {@code elseBlock}, if it is executed.
	 * @param elseBlock code to be executed or not.
	 */
	def abstract <T> void elseDo(T value, Consumer<T> elseBlock)

	/** 
	 * This method either executes the given {@code elseBlock} or not,
	 * based on the sub-class of {@code Else}. The given {@code t} and {@code u} will
	 * be forwarded to the elseBlock on execution. This allows the usage of non-capturing
	 * lambdas, allowing better execution performance.
	 * @param t value to be forwarded to {@code elseBlock}, if it is executed.
	 * @param u value to be forwarded to {@code elseBlock}, if it is executed.
	 * @param elseBlock code to be executed or not.
	 */
	def abstract <T, U> void elseDo(T t, U u, BiConsumer<T, U> elseBlock)

}
