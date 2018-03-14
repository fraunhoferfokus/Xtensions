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
import java.util.function.LongSupplier
import java.util.function.LongUnaryOperator
import java.util.function.LongPredicate

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
	
	/** 
	 * Creates a new LongIterable that will produce an infinite {@link OfLong} or {@link LongStream} based on the {@link LongSupplier} provided by supplier {@code s}.
	 * @param s supplier, that provides an {@link LongSupplier} for each
	 * iterator or stream created.
	 * @return LongIterable based on the supplier {@code s}.
	 */
	public static def LongIterable generate(()=>LongSupplier s) {
		new SupplierLongIterable(s)
	}
	
	/** 
	 * Creates {@link LongIterable} an infinite providing an infinite source of
	 * numbers, starting with the given {@code seed} value and in every
	 * subsequent step the result of the given {@code operator} applied on the
	 * last step's value. So in the second step this would be{@code op.applyAsLong(seed)} and so on.
	 * @param seed first value to be provided and used as seed fed to {@code op} in second step.
	 * @param op this operator must be side-effect free.
	 * @return and {@link LongIterable} providing infinite source of numbers
	 * based on {@code seed} and {@code op}.
	 */
	public static def LongIterable iterate(long seed, LongUnaryOperator op) {
		new IterateLongIterable(seed, op)
	}
	
	/** 
	 * Creates {@link LongPredicate} an which works similar to a traditional for-loop.
	 * The first value provided by an iterator provided by the created iterable will be {@code seed} value. 
	 * The iterator's {@code OfLong#next()} method will return the
	 * boolean value provided by {@code LongPredicate} on the potentially next value.
	 * This also means that if {@code LongPredicate} does not hold for the first value 
	 * the iterator will not provide any value. The next value provided after the initial
	 * one is {@code next} applied to the initial value. All following values provided by
	 * the iterator will be computed from the last value by applying {@code next}.
	 * @param seed initial value to be provided by iterators
	 * @param hasNext method to check if iterator should provide a next value
	 * @param next value mapping previous value provided by iterator to next value provided
	 * @return iterable, providing an iterator based on {@code seed}, {@code hasNext}, and {@code next}.
	 */
	def static LongIterable iterate(long seed, LongPredicate hasNext, LongUnaryOperator next) {
		new IterateLongIterableLimited(seed, hasNext, next)
	}
}
