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
package de.fhg.fokus.xtensions.iteration

import java.util.PrimitiveIterator.OfLong
import java.util.function.LongConsumer
import java.util.stream.LongStream
import de.fhg.fokus.xtensions.iteration.PrimitiveIteratorExtensions

/** 
 * This interface is a specialized version of an {@code Iterable<Long>} providing a {@link OfLong PrimitiveIterator.OfLong} 
 * which allows iteration over a (possibly infinite) amount of unboxed primitive values.<br>
 * <br>
 * This abstraction can be used in situations where an {@link LongStream} would
 * be appropriate, but the user has to be able to create the stream multiple
 * times. It can also be used as an immutable view on an {@code long[]} array.
 */
interface LongIterable extends Iterable<Long> {
	/** 
	 * Returns a primitive iterator over elements of type {@code long}. This
	 * method specializes the super-interface method.
	 * @return a PrimitiveIterator.OfLong
	 */
	override OfLong iterator()

	/** 
	 * Iterates over all elements of the iterable and calls {@code consumer} for
	 * each element. The default implementation uses {@link #iterator()} to get
	 * the elements of the iterable. Implementations are encouraged to overwrite
	 * this method with a more efficient implementation.<br>
	 * Be aware that on inifinite iterables this method only returns when the {@code consumer} throws an exception or terminates the runtime.
	 * @param consumer the action to be called for each element in the iterable.
	 */
	def void forEachLong(LongConsumer consumer) {
		val OfLong iterator = iterator()
		while (iterator.hasNext()) {
			var long next = iterator.nextLong()
			consumer.accept(next)
		}
	}

	/** 
	 * Returns an {@link LongStream} based on the elements in the iterable. <br>
	 * The default implementation returns a stream uses {@link PrimitiveIteratorExtensions#streamRemaining(PrimitiveIterator.OfLong)} 
	 * with the iterator from {@link #iterator()} to construct the resulting stream. It is highly
	 * recommended for the implementations of this interface to provide an own
	 * implementation of this method.
	 * @return a LongStream to iterate over the elements of this iterable.
	 */
	def LongStream stream() {
		val OfLong iterator = iterator()
		PrimitiveIteratorExtensions.streamRemaining(iterator)
	} 
	
	// TODO public static LongIterable generate(final LongSupplier s)
	// TODO public static LongIterable iterate(final long seed, final LongUnaryOperator f)
	// TODO public static LongIterable iterate(final long seed, LongPredicate hasNext, final LongUnaryOperator next)
}
