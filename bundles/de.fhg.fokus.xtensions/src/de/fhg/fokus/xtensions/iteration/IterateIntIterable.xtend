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
import java.util.function.IntUnaryOperator
import java.util.function.IntConsumer
import java.util.function.IntPredicate
import java.util.NoSuchElementException
import java.util.stream.IntStream

/**
 * Instances of this class should be provided using {@link IntIterable#iterate(int,IntUnaryOperator)}.<br>
 * IntIterable based on an int seed value and an IntUnaryOperator producing 
 * the next value from the previous one. 
 */
package class IterateIntIterable implements IntIterable {
	
	val int seed
	val IntUnaryOperator operator
	
	new(int seed, IntUnaryOperator operator) {
		this.seed = seed
		this.operator = operator
	}
	
	override OfInt iterator() {
		new IterateOfInt(seed, operator)
	}
	
	override forEachInt(IntConsumer consumer) {
		val op = operator
		var next = seed
		while(true) {
			consumer.accept(next)
			next = op.applyAsInt(next)
		}
	}
	
	override stream() {
		IntStream.iterate(seed, operator)
	}
	
}

/**
 * {@code OfInt} implementation of an infinite iterator based on a seed value
 * and a function mapping the current value to the next one.
 */
package class IterateOfInt implements OfInt {
	
	var int next
	val IntUnaryOperator operator
	
	/**
	 * @param i initial value to be returned by iterator
	 * @param operator operation mapping the current iterator value to the next
	 */
	new(int i, IntUnaryOperator operator) {
		this.next = i
		this.operator = operator
	}
	
	override nextInt() {
		val curr = next
		next = operator.applyAsInt(curr)
		curr
	}
	
	override hasNext() {
		true
	}
	
	override forEachRemaining(IntConsumer action) {
		val op = operator
		while(true) {
			val curr = next
			next = op.applyAsInt(curr)
			action.accept(curr)
		}
	}
	
}

package class IterateIntIterableLimited implements IntIterable {
	
	val int seed
	val IntPredicate hasNext
	val IntUnaryOperator next
	
	new(int seed, IntPredicate hasNext, IntUnaryOperator next) {
		this.seed = seed
		this.hasNext = hasNext
		this.next = next
	}
	
	override OfInt iterator() {
		new IterateOfIntLimited(seed, hasNext, next)
	}
	
	override forEachInt(IntConsumer consumer) {
		val hasNextOp = hasNext
		val nextOp = next
		var next = seed
		while(hasNextOp.test(next)) {
			consumer.accept(next)
			next = nextOp.applyAsInt(next)
		}
	}
	
}

/**
 * {@code OfInt} implementation of an infinite iterator based on a seed value
 * and a function mapping the current value to the next one.
 */
package class IterateOfIntLimited implements OfInt {
	
	var int next
	val IntUnaryOperator operator
	val IntPredicate hasNext
	
	/**
	 * @param i initial value to be returned by iterator
	 * @param operator operation mapping the current iterator value to the next
	 */
	new(int seed, IntPredicate hasNext, IntUnaryOperator next) {
		this.next = seed
		this.operator = next
		this.hasNext = hasNext
	}
	
	override nextInt() {
		if(!hasNext.test(next)) {
			throw new NoSuchElementException
		}
		val curr = next
		next = operator.applyAsInt(curr)
		curr
	}
	
	override hasNext() {
		hasNext.test(next)
	}
	
	override forEachRemaining(IntConsumer action) {
		val op = operator
		val hasNext = this.hasNext
		var curr = next
		while(hasNext.test(curr)) {
			val localNext = op.applyAsInt(curr)
			next = localNext
			action.accept(curr)
			curr = localNext
		}
	}
	
}