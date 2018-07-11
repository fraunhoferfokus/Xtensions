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

import java.util.PrimitiveIterator.OfDouble
import java.util.function.DoubleConsumer
import java.util.stream.DoubleStream
import de.fhg.fokus.xtensions.iteration.PrimitiveIteratorExtensions
import java.util.function.DoubleSupplier
import java.util.function.DoubleUnaryOperator
import java.util.function.DoublePredicate

/** 
 * This interface is a specialized version of an {@code Iterable<Double>} providing a {@link OfDouble PrimitiveIterator.OfDouble} 
 * which allows iteration over a (possibly infinite) amount of unboxed primitive values.<br>
 * <br>
 * This abstraction can be used in situations where an {@link DoubleStream} would
 * be appropriate, but the user has to be able to create the stream multiple
 * times. It can also be used as an immutable view on an {@code double[]} array.
 */
interface DoubleIterable extends Iterable<Double> {
	
	/** 
	 * Returns a primitive iterator over elements of type {@code double}. This
	 * method specializes the super-interface method.
	 * @return a PrimitiveIterator.OfDouble
	 */
	override OfDouble iterator()

	/** 
	 * Iterates over all elements of the iterable and calls {@code consumer} for
	 * each element. The default implementation uses {@link #iterator()} to get
	 * the elements of the iterable. Implementations are encouraged to overwrite
	 * this method with a more efficient implementation.<br>
	 * Be aware that on inifinite iterables this method only returns when the {@code consumer} throws an exception or terminates the runtime.
	 * @param consumer the action to be called for each element in the iterable.
	 */
	def void forEachDouble(DoubleConsumer consumer) {
		val OfDouble iterator = iterator()
		while (iterator.hasNext()) {
			var double next = iterator.nextDouble()
			consumer.accept(next)
		}
	}

	/** 
	 * Returns an {@link DoubleStream} based on the elements in the iterable. <br>
	 * The default implementation returns a stream uses {@link PrimitiveIteratorExtensions#streamRemaining(PrimitiveIterator.OfDouble)} with the iterator from{@link #iterator()} to construct the resulting stream. It is highly
	 * recommended for the implementations of this interface to provide an own
	 * implementation of this method.
	 * @return a DoubleStream to iterate over the elements of this iterable.
	 */
	def DoubleStream stream() {
		val OfDouble iterator = iterator()
		PrimitiveIteratorExtensions.streamRemaining(iterator)
	} 
	
	/**
	 * Creates a new LongIterable that will produce an infinite {@link OfDouble} or {@link DoubleStream} based on the {@link DoubleSupplier} provided by supplier {@code s}.
	 * @param s supplier, that provides an {@link DoubleSupplier} for each
	 * iterator or stream created.
	 * @return DoubleIterable based on the supplier {@code s}.
	 */
	static def DoubleIterable generate(()=>DoubleSupplier s) {
		new SupplierDoubleIterable(s)
	}
	
	/** 
	 * Creates {@link DoubleIterable} an infinite providing an infinite source of
	 * numbers, starting with the given {@code seed} value and in every
	 * subsequent step the result of the given {@code operator} applied on the
	 * last step's value. So in the second step this would be{@code op.applyAsDouble(seed)} and so on.
	 * @param seed first value to be provided and used as seed fed to {@code op} in second step.
	 * @param op this operator must be side-effect free.
	 * @return and {@link DoubleIterable} providing infinite source of numbers
	 * based on {@code seed} and {@code op}.
	 */
	static def DoubleIterable iterate(double seed, DoubleUnaryOperator op) {
		new IterateDoubleIterable(seed, op)
	}
	
	/** 
	 * Creates {@link DoubleIterable} an which works similar to a traditional for-loop.
	 * The first value provided by an iterator provided by the created iterable will be {@code seed} value. 
	 * The iterator's {@code OfDouble#next()} method will return the
	 * boolean value provided by {@code DoublePredicate} on the potentially next value.
	 * This also means that if {@code DoublePredicate} does not hold for the first value 
	 * the iterator will not provide any value. The next value provided after the initial
	 * one is {@code next} applied to the initial value. All following values provided by
	 * the iterator will be computed from the last value by applying {@code next}.
	 * @param seed initial value to be provided by iterators
	 * @param hasNext method to check if iterator should provide a next value
	 * @param next value mapping previous value provided by iterator to next value provided
	 * @return iterable, providing an iterator based on {@code seed}, {@code hasNext}, and {@code next}.
	 */
	static def DoubleIterable iterate(double seed, DoublePredicate hasNext, DoubleUnaryOperator next) {
		new IterateDoubleIterableLimited(seed, hasNext, next)
	}
}
