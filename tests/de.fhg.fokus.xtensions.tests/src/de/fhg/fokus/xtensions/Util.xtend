package de.fhg.fokus.xtensions

import static org.junit.Assert.*

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
}