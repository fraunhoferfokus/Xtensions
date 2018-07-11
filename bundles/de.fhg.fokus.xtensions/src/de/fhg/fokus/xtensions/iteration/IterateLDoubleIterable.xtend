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
import java.util.function.DoubleUnaryOperator
import java.util.function.DoubleConsumer
import java.util.function.DoublePredicate
import java.util.NoSuchElementException
import java.util.stream.DoubleStream

/**
 * Instances of this class should be provided using {@link DoubleIterable#iterate(double,DoubleUnaryOperator)}.<br>
 * DoubleIterable based on an long seed value and an DoubleUnaryOperator producing 
 * the next value from the previous one. 
 */
package class IterateDoubleIterable implements DoubleIterable {
	
	val double seed
	val DoubleUnaryOperator operator
	
	new(double seed, DoubleUnaryOperator operator) {
		this.seed = seed
		this.operator = operator
	}
	
	override OfDouble iterator() {
		new IterateOfDouble(seed, operator)
	}
	
	override forEachDouble(DoubleConsumer consumer) {
		val op = operator
		var next = seed
		while(true) {
			consumer.accept(next)
			next = op.applyAsDouble(next)
		}
	}
	
	override stream() {
		DoubleStream.iterate(seed, operator)
	}
	
}

/**
 * {@code OfDouble} implementation of an infinite iterator based on a seed value
 * and a function mapping the current value to the next one.
 */
package class IterateOfDouble implements OfDouble {
	
	var double next
	val DoubleUnaryOperator operator
	
	/**
	 * @param d initial value to be returned by iterator
	 * @param operator operation mapping the current iterator value to the next
	 */
	new(double d, DoubleUnaryOperator operator) {
		this.next = d
		this.operator = operator
	}
	
	override nextDouble() {
		val curr = next
		next = operator.applyAsDouble(curr)
		curr
	}
	
	override hasNext() {
		true
	}
	
	override forEachRemaining(DoubleConsumer action) {
		val op = operator
		while(true) {
			val curr = next
			next = op.applyAsDouble(curr)
			action.accept(curr)
		}
	}
	
}

package class IterateDoubleIterableLimited implements DoubleIterable {
	
	val double seed
	val DoublePredicate hasNext
	val DoubleUnaryOperator next
	
	new(double seed, DoublePredicate hasNext, DoubleUnaryOperator next) {
		this.seed = seed
		this.hasNext = hasNext
		this.next = next
	}
	
	override OfDouble iterator() {
		new IterateOfDoubleLimited(seed, hasNext, next)
	}
	
	override forEachDouble(DoubleConsumer consumer) {
		val hasNextOp = hasNext
		val nextOp = next
		var next = seed
		while(hasNextOp.test(next)) {
			consumer.accept(next)
			next = nextOp.applyAsDouble(next)
		}
	}
	
	// When setting minimum to Java 9, overwrite stream() method calling DoubleStream.iterate(seed, hasNext, next)
	
}

/**
 * {@code OfDouble} implementation of an infinite iterator based on a seed value
 * and a function mapping the current value to the next one.
 */
package class IterateOfDoubleLimited implements OfDouble {
	
	var double next
	val DoubleUnaryOperator operator
	val DoublePredicate hasNext
	
	/**
	 * @param seed initial value to be returned by iterator
	 * @param hasNext predicate checking if a next value should be computed.
	 * @param next operation mapping the current iterator value to the next
	 */
	new(double seed, DoublePredicate hasNext, DoubleUnaryOperator next) {
		this.next = seed
		this.operator = next
		this.hasNext = hasNext
	}
	
	override nextDouble() {
		if(!hasNext.test(next)) {
			throw new NoSuchElementException
		}
		val curr = next
		next = operator.applyAsDouble(curr)
		curr
	}
	
	override hasNext() {
		hasNext.test(next)
	}
	
	override forEachRemaining(DoubleConsumer action) {
		val op = operator
		val hasNext = this.hasNext
		var curr = next
		while(hasNext.test(curr)) {
			val localNext = op.applyAsDouble(curr)
			next = localNext
			action.accept(curr)
			curr = localNext
		}
	}
	
}