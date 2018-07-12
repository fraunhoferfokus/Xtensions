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

import java.util.function.DoubleSupplier
import java.util.function.DoubleConsumer
import java.util.stream.DoubleStream
import java.util.PrimitiveIterator.OfDouble

/**
 * DoubleSupplier based DoubleInterable that should be created via the static factory method
 * {@link DoubleIterable#generate(org.eclipse.xtext.xbase.lib.Functions.Function0)}
 */
package class SupplierDoubleIterable implements DoubleIterable {
	
	val ()=>DoubleSupplier supplier
	
	new(()=>DoubleSupplier supplier) {
		this.supplier = supplier
	}
	
	override iterator() {
		new SupplierDoubleInterator(supplier.apply)
	}
	
	override stream() {
		DoubleStream.generate(supplier.apply)
	}
	
	override forEachDouble(DoubleConsumer consumer) {
		val ints = supplier.apply
		while(true) {
			val i = ints.getAsDouble
			consumer.accept(i)
		}
	}
	
}

package class SupplierDoubleInterator implements OfDouble {
	val DoubleSupplier supplier
	
	new(DoubleSupplier supplier) {
		this.supplier = supplier
	}
	
	override nextDouble() {
		supplier.asDouble
	}
	
	override hasNext() {
		true
	}
	
	override forEachRemaining(DoubleConsumer action) {
		val Doubles = supplier
		while(true) {
			val l = Doubles.getAsDouble
			action.accept(l)
		}
	}
}