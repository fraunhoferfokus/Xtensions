package de.fhg.fokus.xtensions
import static extension de.fhg.fokus.xtensions.range.RangeExtensions.*
import static extension de.fhg.fokus.xtensions.iterator.PrimitiveArrayExtensions.*
import de.fhg.fokus.xtensions.iterator.IntIterable
//import static extension de.fhg.fokus.xtensions.iterator.IterableExtensions.*
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*
import org.junit.Test
import java.util.Optional
import java.util.stream.Stream

class Showcase {
	
	@Test def rangeDemo() {
		
		val range = (0..20).withStep(2)
		
		range.stream.filter[it % 5 == 0].sum
		
		range.forEachInt [
			println(it)
		]
		
		val intIt = range.intIterator
		while(intIt.hasNext) {
			val i = intIt.nextInt
			if(i>5) return
		}
	}
	
	@Test def arrayDemo() {
		val int[] arr = #[3,4,6]
		arr.forEachInt [
			println()
		]
		
		val sum = arr.stream.sum
	}
	
	@Test def iterableDemo() {
		val int[] arr = #[0,2,4,19,-10,10_000,Integer.MAX_VALUE,Integer.MIN_VALUE]
		var ints = arr.asIntIterable(1, arr.length - 1) // omit first and last
		ints.print(5)
		
		ints = (0..50).withStep(2).asIntIterable
		ints.print(5)
		
		ints = IntIterable.iterate(1)[it * 2] // infinite iterable
		ints.print(5)
	}
	
	def print(IntIterable ints, int count) {
		ints.stream.limit(count).forEach [
			println(it)
		]
	}
	
	@Test def optionalDemo() {
		// Aliases for empty, filled, and possibly filled optionals
		val no = <String>none
		val yes = some("yesss!")
		val dunno = maybe(possiblyNull())
		
		// view as iterable
		for(str : yes.asIterable) {
			println("Iterating over: " + str)
		}
		for(str : no.asIterable) {
			println("I will never be printed")
		}
		
		// map to primitive optionals
		val size = dunno.mapInt[length]
		
		
		//////////////////////////////////
		// Java 9 forward compatibility //
		//////////////////////////////////
		
		dunno.ifPresentOrElse([println(it)], [println("awwww!")])
		
		dunno.or[yes].ifPresent [println('''OR: «it»''')]
		
		(dunno || no).ifNotPresent[| println("Nothing to see here!")]
		
		Stream.of(no, yes, dunno).flatMap[stream​].forEach [
			// print non-empty optionals using stream extension method
			println(it)
		]
	}
	
	def possiblyNull() {
		if(System.currentTimeMillis % 2 == 0) {
			"I'm in ur optional"
		} else {
			null
		}
	}
	
}