package de.fhg.fokus.xtensions.incubation

import static extension de.fhg.fokus.xtensions.incubation.iteration.Loop.*
import static extension de.fhg.fokus.xtensions.incubation.iteration.IteratorExtensions.*
import org.junit.Test
import de.fhg.fokus.xtensions.incubation.showcase.Person
import de.fhg.fokus.xtensions.incubation.function.Trampoline
import de.fhg.fokus.xtensions.incubation.function.Bounce
import de.fhg.fokus.xtensions.incubation.Showcase.Parity

class Showcase {
	
	@Test
	def void demoImmutable() {
		val rita = Person.create [
			name = "Rita"
		]
		val sven = Person.create [
			name = "Sven"
		]
		val hank = Person.create [
			name = "Hank"
			dad = sven
			mom = rita
		]
		
		val julie = Person.create [
			name = "Julie"
		]
		val ron = Person.create [
			name = "Ron"
		]
		val jane = Person.create [
			name = "Jane"
			mom = julie
			dad = ron
		]
		
		var mike = Person.create [
			name = "Mike"
			mom = jane
			dad = hank
		]
		
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
		
		val julius = mike.with [
			name = "Julius"
		]
		
		println(julius.name)
	}
	
	@Test
	def void demoTrampoline() {
		val first = 99
		val firstResult = Trampoline.jump[even(first)]
		println('''«first» is «firstResult»''')

		val second = 104
		val secondResult = Trampoline.jump[even(second)]
		println('''«second» is «secondResult»''')
	}
	
	enum Parity {EVEN, ODD}
	
	static def Bounce even(Trampoline<Parity> it, int value) {
		if(value == 0) {
			result(Parity.EVEN)
		} else {
			call[odd(value - 1)]
		}
	}
	
	static def Bounce odd(Trampoline<Parity> it, int value) {
		if(value == 0) {
			result(Parity.ODD)
		} else {
			call[even(value - 1)]
		}
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