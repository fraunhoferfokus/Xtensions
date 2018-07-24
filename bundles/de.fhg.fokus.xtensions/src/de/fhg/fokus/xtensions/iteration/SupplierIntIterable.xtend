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

import java.util.function.IntSupplier
import java.util.PrimitiveIterator.OfInt
import java.util.stream.IntStream
import java.util.function.IntConsumer
import de.fhg.fokus.xtensions.iteration.internal.IntStreamable

/**
 * IntSupplier based IntInterable that should be created via the static factory method
 * {@link IntIterable#generate(Supplier)}
 */
package class SupplierIntIterable implements IntIterable {
	
	val ()=>IntSupplier supplier
	
	new(()=>IntSupplier supplier) {
		this.supplier = supplier
	}
	
	override iterator() {
		new SupplierIntInterator(supplier.apply)
	}
	
	override stream() {
		IntStream.generate(supplier.apply)
	}
	
	override forEachInt(IntConsumer consumer) {
		val ints = supplier.apply
		while(true) {
			val i = ints.getAsInt
			consumer.accept(i)
		}
	}
	
}

package class SupplierIntInterator implements OfInt, IntStreamable {
	
	val IntSupplier supplier
	
	new(IntSupplier supplier) {
		this.supplier = supplier
	}
	
	override nextInt() {
		supplier.asInt
	}
	
	override hasNext() {
		true
	}
	
	override forEachRemaining(IntConsumer action) {
		val ints = supplier
		while(true) {
			val i = ints.getAsInt
			action.accept(i)
		}
	}
	
	override streamInts() {
		IntStream.generate(supplier)
	}
	
} 