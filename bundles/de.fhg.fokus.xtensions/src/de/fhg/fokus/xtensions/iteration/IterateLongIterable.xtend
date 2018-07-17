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
import java.util.function.LongUnaryOperator
import java.util.function.LongConsumer
import java.util.function.LongPredicate
import java.util.NoSuchElementException
import java.util.stream.LongStream
import de.fhg.fokus.xtensions.iteration.internal.LongStreamable

/**
 * Instances of this class should be provided using {@link LongIterable#iterate(long,LongUnaryOperator)}.<br>
 * LongIterable based on an long seed value and an LongUnaryOperator producing 
 * the next value from the previous one. 
 */
package class IterateLongIterable implements LongIterable {
	
	val long seed
	val LongUnaryOperator operator
	
	new(long seed, LongUnaryOperator operator) {
		this.seed = seed
		this.operator = operator
	}
	
	override OfLong iterator() {
		new IterateOfLong(seed, operator)
	}
	
	override forEachLong(LongConsumer consumer) {
		val op = operator
		var next = seed
		while(true) {
			consumer.accept(next)
			next = op.applyAsLong(next)
		}
	}
	
	override stream() {
		LongStream.iterate(seed, operator)
	}
	
}

/**
 * {@code OfLong} implementation of an infinite iterator based on a seed value
 * and a function mapping the current value to the next one.
 */
package class IterateOfLong implements OfLong, LongStreamable {
	
	var long next
	val LongUnaryOperator operator
	
	/**
	 * @param l initial value to be returned by iterator
	 * @param operator operation mapping the current iterator value to the next
	 */
	new(long l, LongUnaryOperator operator) {
		this.next = l
		this.operator = operator
	}
	
	override nextLong() {
		val curr = next
		next = operator.applyAsLong(curr)
		curr
	}
	
	override hasNext() {
		true
	}
	
	override forEachRemaining(LongConsumer action) {
		val op = operator
		while(true) {
			val curr = next
			next = op.applyAsLong(curr)
			action.accept(curr)
		}
	}
	
	override streamLongs() {
		LongStream.iterate(next, operator)
	}
	
}

package class IterateLongIterableLimited implements LongIterable {
	
	val long seed
	val LongPredicate hasNext
	val LongUnaryOperator next
	
	new(long seed, LongPredicate hasNext, LongUnaryOperator next) {
		this.seed = seed
		this.hasNext = hasNext
		this.next = next
	}
	
	override OfLong iterator() {
		new IterateOfLongLimited(seed, hasNext, next)
	}
	
	override forEachLong(LongConsumer consumer) {
		val hasNextOp = hasNext
		val nextOp = next
		var next = seed
		while(hasNextOp.test(next)) {
			consumer.accept(next)
			next = nextOp.applyAsLong(next)
		}
	}
	
	// When setting minimum to Java 9, overwrite stream() method calling LongStream.iterate(seed, hasNext, next)
}

/**
 * {@code OfLong} implementation of an infinite iterator based on a seed value
 * and a function mapping the current value to the next one.
 */
package class IterateOfLongLimited implements OfLong {
	
	var long next
	val LongUnaryOperator operator
	val LongPredicate hasNext
	
	/**
	 * @param seed initial value to be returned by iterator
	 * @param hasNext predicate checking if a next value should be computed.
	 * @param next operation mapping the current iterator value to the next
	 */
	new(long seed, LongPredicate hasNext, LongUnaryOperator next) {
		this.next = seed
		this.operator = next
		this.hasNext = hasNext
	}
	
	override nextLong() {
		if(!hasNext.test(next)) {
			throw new NoSuchElementException
		}
		val curr = next
		next = operator.applyAsLong(curr)
		curr
	}
	
	override hasNext() {
		hasNext.test(next)
	}
	
	override forEachRemaining(LongConsumer action) {
		val op = operator
		val hasNext = this.hasNext
		var curr = next
		while(hasNext.test(curr)) {
			val localNext = op.applyAsLong(curr)
			next = localNext
			action.accept(curr)
			curr = localNext
		}
	}
	
}