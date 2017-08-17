package de.fhg.fokus.xtensions.incubation

import static extension de.fhg.fokus.xtensions.incubation.iteration.Loop.*
import static extension de.fhg.fokus.xtensions.incubation.iteration.IteratorExtensions.*
import org.junit.Test

class Showcase {
	
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