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
package de.fhg.fokus.xtensions

import static org.junit.Assert.*
import java.util.NoSuchElementException
import java.util.PrimitiveIterator.OfInt
import java.util.PrimitiveIterator.OfLong
import java.util.PrimitiveIterator.OfDouble

class Util {
	
	public static def <X extends Exception> X expectException(Class<X> exClass, ()=>void action) {
		try {
			action.apply
		} catch(Exception e) {
			if(exClass.isInstance(e)) {
				return exClass.cast(e)
			}
			val msg = "Exception not instance of " + exClass.name + "; Actual class: " + e.class.name
			throw new AssertionError(msg, e)
		}
		throw new AssertionError("Expected exception of type " + exClass.name)
	}
	
	
	public static def assertEmptyIntIterator(OfInt iterator) {
		assertNotNull(iterator)
		assertFalse(iterator.hasNext)
		expectException(NoSuchElementException) [
			iterator.nextInt
		]
	}
	
	public static def assertEmptyLongIterator(OfLong iterator) {
		assertNotNull(iterator)
		assertFalse(iterator.hasNext)
		expectException(NoSuchElementException) [
			iterator.nextLong
		]
	}
	
	public static def assertEmptyDoubleIterator(OfDouble iterator) {
		assertNotNull(iterator)
		assertFalse(iterator.hasNext)
		expectException(NoSuchElementException) [
			iterator.nextDouble
		]
	}
}