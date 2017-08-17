package de.fhg.fokus.xtensions.incubation.showcase

import org.eclipse.xtend.lib.annotations.Accessors
import de.fhg.fokus.xtensions.incubation.immutable.Focus

@Accessors(PUBLIC_GETTER)
class Person {
	
	val String name
	val Person mom
	val Person dad
	
	public def momFocus() {
		Focus.create(mom) [new Person(name, it, dad)]
	}

	public def dadFocus() {
		Focus.create(dad) [new Person(name, mom, it)]
	}
	
	public def Person name((String)=>String newName) {
		new Person(newName.apply(name), mom, dad)
	}
	
	public def Person dad((Person)=>Person update) {
		new Person(name, mom, update.apply(dad))
	}
	
	public def Person mom((Person)=>Person update) {
		new Person(name, update.apply(mom), dad)
	}
}
