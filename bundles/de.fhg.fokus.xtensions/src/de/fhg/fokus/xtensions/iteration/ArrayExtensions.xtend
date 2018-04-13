package de.fhg.fokus.xtensions.iteration

import java.lang.reflect.Array
import static extension java.util.Objects.*

/**
 * Extension methods for object arrays.
 */
package class ArrayExtensions {
	
	// TODO make class and forEach method public when API is documented and tested throughly for edge cases
	
	private new() {
		throw new IllegalStateException()
	}
	
	/**
	 * Allows iteration over elements of the given {@code array} without 
	 * allocating an {@code Iterable} and {@code Iterator}.
	 */
	package static def <T> void forEach(T[] array, (T)=>void action) {
		for(var i=0;i<array.length;i++) {
			action.apply(array.get(i))
		}
	}
	
	package static def <T> T[] copyIntoNewArray(Class<T> arrayElementType, T first, T second, T... additional) {
		arrayElementType.requireNonNull
		first.requireNonNull
		second.requireNonNull
		val T[] result = if(additional === null) {
				arrayElementType.createGenericArray(2)
			} else {
				additional.forEach [ requireNonNull ]
				arrayElementType.createGenericArray(additional.length + 2) => [
					// fill result with elements from additional, leave spot 0 free for first.
					System.arraycopy(additional,0,it,2,additional.length)
				]
			}
		result.set(0,first)
		result.set(1,second)
		result
	}
	
	private static def <T> T[] createGenericArray(Class<T> arrayElementType, int length) {
		Array.newInstance(arrayElementType, length) as T[]
	}
}