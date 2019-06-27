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

import org.junit.Test

import static extension de.fhg.fokus.xtensions.iteration.ArrayExtensions.*
import static extension org.junit.Assert.*
import java.time.LocalDateTime
import java.time.ZoneId
import de.fhg.fokus.xtensions.iteration.ArrayExtensions.ElementAndIndexConsumer

/**
 * Test cases for {@link ArrayExtensions}
 */
class ArrayExtensionsTest {

	/////////////////////////
	// forArray((T)=>void) //
	/////////////////////////
	
	@Test(expected=NullPointerException)
	def void testForEachArrayNull() {
		val Object[] arr = null
		arr.forEach [
			fail()
		]
	}

	@Test(expected=NullPointerException) def void testForEachActionNull() {
		val Object[] arr = #[]
		arr.forEach(null as (Object)=>void)
	}

	@Test def void testForEachEmptyArray() {
		val Object[] arr = #[]
		arr.forEach [
			fail()
		]
	}

	@Test def void testForEachOneElementArray() {
		val Object[] arr = #["foo"]
		val result = newArrayList
		arr.forEach [
			result.add(it)
		]
		assertArrayEquals(arr, result)
	}

	@Test def void testForEachSomeElementsArray() {
		val Object[] arr = #["foo", 42, LocalDateTime.now(ZoneId.systemDefault)]
		val result = newArrayList
		arr.forEach [
			result.add(it)
		]
		assertArrayEquals(arr, result)
	}

	///////////////////////////////////////
	// forArray(ElementAndIndexConsumer) //
	///////////////////////////////////////
	
	@Test(expected=NullPointerException)
	def void testForEachIndexedArrayNull() {
		val Object[] arr = null
		arr.forEach [e,i|
			fail()
		]
	}

	@Test(expected=NullPointerException) def void testForEachIndexedActionNull() {
		val Object[] arr = #[]
		arr.forEach(null as ElementAndIndexConsumer<Object>)
	}

	@Test def void testForEachIndexedEmptyArray() {
		val Object[] arr = #[]
		arr.forEach [e,i|
			fail()
		]
	}

	@Test def void testForEachIndexedOneElementArray() {
		val expected = "foo"
		val Object[] arr = #[expected]
		extension val result = new Object() {
			var element = null
			var index = -100
		}
		arr.forEach [e,i|
			element = e
			index = i
		]
		element.assertSame(expected)
		index.assertSame(0)
	}

	@Test def void testForEachIndexedSomeElementsArray() {
		val Object[] arr = #["foo", 42, LocalDateTime.now(ZoneId.systemDefault)]
		val result = newArrayList
		val indices = newArrayList
		arr.forEach [e,i|
			result.add(e)
			indices.add(i)
		]
		assertArrayEquals(arr, result)
		assertArrayEquals(#[0,1,2], indices)
	}
}
