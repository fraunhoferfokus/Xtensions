/*******************************************************************************
 * Copyright (c) 2017-2018 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.iteration

import java.util.function.LongSupplier
import java.util.function.LongConsumer
import java.util.stream.LongStream
import java.util.PrimitiveIterator.OfLong
import de.fhg.fokus.xtensions.iteration.internal.LongStreamable

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

package class SupplierLongInterator implements OfLong, LongStreamable {
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
	
	override streamLongs() {
		LongStream.generate(supplier)
	}
	
}