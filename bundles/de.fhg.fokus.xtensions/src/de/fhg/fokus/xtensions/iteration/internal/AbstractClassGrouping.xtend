package de.fhg.fokus.xtensions.iteration.internal

import de.fhg.fokus.xtensions.iteration.ClassGrouping
import java.util.List

/**
 * Abstract {@link ClassGrouping} only implementing key storage and method {@link #getGroupingClasses()}.
 */
package abstract class AbstractClassGrouping implements ClassGrouping {
	
	Class<?>[] keys
	private transient var List<Class<?>> keysList

	new(Class<?>[] keys) {
		this.keys = keys
		this.keysList = null
	}

	override final List<Class<?>> getGroupingClasses() {
		val result = keysList
		if (result === null) {
			keysList = new UnmodifiableArrayBackedList(keys)
		} else {
			result
		}
	}
	
}