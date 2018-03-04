package de.fhg.fokus.xtensions.incubation.showcase

import org.eclipse.xtend.lib.annotations.Accessors
import de.fhg.fokus.xtensions.incubation.immutable.Immutable

@Immutable(UPDATE_METHODS, FOCUS_METHODS, WITH_METHOD, CREATE_METHOD)
@Accessors(PUBLIC_GETTER)
class Person {
	
	@Immutable(UPDATE_METHODS) val String name
	val Person mom
	val Person dad
	
}
