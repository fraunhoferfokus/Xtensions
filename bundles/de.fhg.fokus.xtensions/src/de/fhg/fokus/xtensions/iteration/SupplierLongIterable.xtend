package de.fhg.fokus.xtensions.iteration

import java.util.function.LongSupplier
import java.util.function.LongConsumer
import java.util.stream.LongStream
import java.util.PrimitiveIterator.OfLong

/**
 * LongSupplier based LongInterable that should be created via the static factory method
 * {@link LongIterable#generate(org.eclipse.xtext.xbase.lib.Functions.Function0)}
 */
package class SupplierLongIterable implements LongIterable {
	
	val ()=>LongSupplier supplier
	
	new(()=>LongSupplier supplier) {
		this.supplier = supplier
	}
	
	override iterator() {
		new SupplierLongInterator(supplier.apply)
	}
	
	override stream() {
		LongStream.generate(supplier.apply)
	}
	
	override forEachLong(LongConsumer consumer) {
		val ints = supplier.apply
		while(true) {
			val i = ints.getAsLong
			consumer.accept(i)
		}
	}
	
}

package class SupplierLongInterator implements OfLong {
	val LongSupplier supplier
	
	new(LongSupplier supplier) {
		this.supplier = supplier
	}
	
	override nextLong() {
		supplier.asLong
	}
	
	override hasNext() {
		true
	}
	
	override forEachRemaining(LongConsumer action) {
		val longs = supplier
		while(true) {
			val l = longs.getAsLong
			action.accept(l)
		}
	}
}