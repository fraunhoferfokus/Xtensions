package de.fhg.fokus.xtensions
import static extension de.fhg.fokus.xtensions.range.RangeExtensions.*
import static extension de.fhg.fokus.xtensions.iterator.PrimitiveArrayExtensions.*
import de.fhg.fokus.xtensions.iterator.IntIterable
import org.junit.Test

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
			if(i>5) return;
		}
	}
	
	@Test def iterableDemo() {
		var ints = #[0,2,4].asIntIterable
		ints.print(2)
		
		ints = (0..10).withStep(2).asIntIterable
		ints.print(2)
		
		ints = IntIterable.iterate(1)[it * 2]
		ints.print(2)
	}
	
	def print(IntIterable ints, int count) {
		ints.stream.limit(2).forEach [
			println(it)
		]
	}
}