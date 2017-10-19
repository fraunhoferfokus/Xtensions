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

import java.util.PrimitiveIterator.OfInt
import java.util.function.IntConsumer
import java.util.function.IntPredicate
import java.util.function.IntSupplier
import java.util.function.IntUnaryOperator
import java.util.stream.IntStream
import de.fhg.fokus.xtensions.iteration.IterateIntIterable
import de.fhg.fokus.xtensions.iteration.PrimitiveArrayExtensions
import de.fhg.fokus.xtensions.iteration.PrimitiveIteratorExtensions
import de.fhg.fokus.xtensions.iteration.SupplierIntIterable

/** 
 * This interface is a specialized version of an {@code Iterable<Integer>}providing a {@link PrimitiveIterator::OfInt} which allows iteration over a
 * (possibly infinite) amount of unboxed primitive values.<br>
 * <br>
 * This abstraction can be used in situations where an {@link IntStream} would
 * be appropriate, but the user has to be able to create the stream multiple
 * times. It can also be used as an immutable view on an {@code int[]}array.<br>
 * <br>
 * This interface is also useful to abstract over different datatypes providing
 * int values such as {@code int[]} array,{@link org.eclipse.xtext.xbase.lib.IntegerRange IntegerRange}, or one of the
 * generator functions {@link IntIterable#generate(Supplier) generate} and{@link IntIterable#iterate(int, IntUnaryOperator) iterate}.
 * @see PrimitiveArrayExtensions#asIntIterable(int[])
 * @see de.fhg.fokus.xtensions.range.RangeExtensions#asIntIterable(org.eclipse.xtext.xbase.lib.IntegerRange)
 */
interface IntIterable extends Iterable<Integer> {
	
	/** 
	 * Returns a primitive iterator over elements of type {@code int}. This
	 * method specializes the super-interface method.
	 * @return a PrimitiveIterator.OfInt
	 */
	override OfInt iterator()

	/** 
	 * Iterates over all elements of the iterable and calls {@code consumer} for
	 * each element. The default implementation uses {@link #iterator()} to get
	 * the elements of the iterable. Implementations are encouraged to overwrite
	 * this method with a more efficient implementation.<br>
	 * Be aware that on inifinite iterables this method only returns when the{@code consumer} throws an exception or terminates the runtime.
	 * @param consumerthe action to be called for each element in the iterable.
	 */
	def void forEachInt(IntConsumer consumer) {
		val OfInt iterator = iterator()
		while (iterator.hasNext()) {
			val int next = iterator.nextInt()
			consumer.accept(next)
		}
	}

	// TODO: useful? or is forEachInt(IntPredicate consumer) better??? Or not needed?
	// default void forEachInt(IntPredicate whileCondition, IntConsumer consumer) {
	// final OfInt iterator = iterator();
	// while (iterator.hasNext()) {
	// final int next = iterator.nextInt();
	// if(!consumer.test(next)) {
	// break;
	// }
	// whileBody.accept(next);
	// }
	// }
	/** 
	 * Returns an {@link IntStream} based on the elements in the iterable. <br>
	 * The default implementation returns a stream uses{@link PrimitiveIteratorExtensions#streamRemaining(OfInt)} with the iterator from{@link #iterator()} to construct the resulting stream. It is highly
	 * recommended for the implementations of this interface to provide an own
	 * implementation of this method.
	 * @return an IntStream to iterate over the elements of this iterable.
	 */
	def IntStream stream() {
		val OfInt iterator = iterator()
		PrimitiveIteratorExtensions::streamRemaining(iterator)
	}

	/** 
	 * Creates a new IntIterable that will produce an infinite{@link PrimitiveIterator::OfInt} or {@link IntStream} based on the{@link IntSupplier} provided by supplier {@code s}.
	 * @param ssupplier, that provides an {@link IntSupplier} for each
	 * iterator or stream created.
	 * @return IntIterable based on the supplier {@code s}.
	 */
	def static IntIterable generate(()=>IntSupplier s) {
		new SupplierIntIterable(s)
	}

	/** 
	 * Creates {@link IntIterable} an infinite providing an infinite source of
	 * numbers, starting with the given {@code seed} value and in every
	 * subsequent step the result of the given {@code operator} applied on the
	 * last step's value. So in the second step this would be{@code op.applyAsInt(seed)} and so on.
	 * @param seedfirst value to be provided and used as seed fed to {@code op}in second step.
	 * @param opthis operator must be side-effect free.
	 * @return and {@link IntIterable} providing infinite source of numbers
	 * based on {@code seed} and {@code op}.
	 */
	def static IntIterable iterate(int seed, IntUnaryOperator op) {
		new IterateIntIterable(seed, op)
	}

	/** 
	 * Creates {@link IntIterable} an which works similar to a traditional for-loop.
	 * The first value provided by an iterator provided by the created iterable will be {@code seed} value. The iterator's {@code OfInt#next()} method will return the
	 * boolean value provided by {@code IntPredicate} on the potentially next value.
	 * This also means that if {@code IntPredicate} does not hold for the first value 
	 * the iterator will not provide any value. The next value provided after the initial
	 * one is {@code next} applied to the initial value. All following values provided by
	 * the iterator will be computed from the last value by applying {@code next}.
	 * @param seed initial value to be provided by iterators
	 * @param hasNext method to check if iterator should provide a next value
	 * @param next value mapping previous value provided by iterator to next value provided
	 * @return iterable, providing an iterator based on {@code seed}, {@code hasNext}, and {@code next}.
	 */
	def static IntIterable iterate(int seed, IntPredicate hasNext, IntUnaryOperator next) {
		new IterateIntIterableLimited(seed, hasNext, next)
	}
}
