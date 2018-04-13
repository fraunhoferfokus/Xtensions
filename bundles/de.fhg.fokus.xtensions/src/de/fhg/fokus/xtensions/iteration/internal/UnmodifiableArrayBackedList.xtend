package de.fhg.fokus.xtensions.iteration.internal

import java.util.AbstractList

/**
 * Read-only List wrapper around an array
 */
package class UnmodifiableArrayBackedList<T> extends AbstractList<T> {

	val T[] array

	new(T[] ts) {
		this.array = ts
	}

	override get(int index) {
		array.get(index)
	}

	override size() {
		array.length
	}

}
