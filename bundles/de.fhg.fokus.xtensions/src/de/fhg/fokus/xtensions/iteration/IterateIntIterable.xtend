package de.fhg.fokus.xtensions.iteration

import java.util.PrimitiveIterator.OfInt
import java.util.function.IntUnaryOperator
import java.util.function.IntConsumer

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
	
}

package class IterateOfInt implements OfInt {
	
	var int next
	val IntUnaryOperator operator
	
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
