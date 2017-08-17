package de.fhg.fokus.xtensions.incubation

import static extension de.fhg.fokus.xtensions.incubation.iteration.Loop.*
import static extension de.fhg.fokus.xtensions.incubation.iteration.IteratorExtensions.*
import org.junit.Test
import de.fhg.fokus.xtensions.incubation.showcase.Person

class Showcase {
	
	@Test
	def void demoFocus() {
		val rita = new Person("Rita", null, null)
		val sven = new Person("Sven", null, null)
		val hank = new Person("Hank", rita, sven)
		
		val julie = new Person("Julie", null, null)
		val ron = new Person("Ron", null, null)
		val jane = new Person("Jane", julie, ron)
		
		var mike = new Person("Mike", jane, hank)
		
		
		// change name of mike's mom's dad to John
		mike = mike.mom[
			it?.dad[
				it?.name["John"] // Ron is now John
			]
		]
		
		println(mike.mom.dad.name)
		
		// Change name back to Ron
		// using linear focus-zoom sequence instead of nested modifiers
		mike = mike.momFocus
			.zoom[dadFocus]
			.apply[name["Ron"]]
			.orElse(mike) // return mike unchanged if a focus on the path is empty
		
		println(mike.mom.dad.name)
	}
	
	@Test
	def void demoLoop() {
		
		val foo = loop [
			val i = Math.round(Math.random * 100)
			if(!(i%5 == 0)) {
				CONTINUE
			}
			if(i%2 == 0) {
				RETURN(i)
			}
		]
		println(foo)
	}
	
	@Test
	def void iteratorDemo() {
		#[1,-2,3,-4].iterator.filterOrMap[
			val el = element
			if(el > 0)
				map(el * 2)
			else 
				filter
		].forEach [println(it)]
	}
}