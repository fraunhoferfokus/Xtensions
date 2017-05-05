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
			fail("Exception not instance of " + exClass.name)
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