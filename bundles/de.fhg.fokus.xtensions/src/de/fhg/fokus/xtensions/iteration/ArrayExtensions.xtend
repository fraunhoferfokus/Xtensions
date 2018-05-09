package de.fhg.fokus.xtensions.iteration

import java.lang.reflect.Array
import static extension java.util.Objects.*

/**
 * Extension methods for object arrays.
 */
class ArrayExtensions {
	
	// TODO make class and forEach method public when API is documented and tested throughly for edge cases
	
	private new() {
		throw new IllegalStateException()
	}
	
	/**
	 * Allows iteration over elements of the given {@code array} and 
	 * invoking a given {@code action} for every element without 
	 * allocating an {@code Iterable} and {@code Iterator} (as done when
	 * using the built in version of Xtend).
	 * 
	 * @param array the array to be iterated over.
	 * @param action the action being applied to every element in {@code array}.
	 * @param <T> Element type of {@code array}
	 * @throws NullPointerException if {@code array} or {@code action} is {@code null}.
	 */
	static def <T> void forEach(T[] array, (T)=>void action) {
		array.requireNonNull("array")
		action.requireNonNull("action")
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