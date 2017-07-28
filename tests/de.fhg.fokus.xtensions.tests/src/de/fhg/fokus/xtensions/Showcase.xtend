package de.fhg.fokus.xtensions

import de.fhg.fokus.xtensions.iteration.IntIterable
import java.util.stream.Stream
import org.junit.Test

import static java.util.stream.Collectors.*

import static extension de.fhg.fokus.xtensions.iteration.IterableExtensions.*
import static extension de.fhg.fokus.xtensions.iteration.PrimitiveArrayExtensions.*
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*
import static extension de.fhg.fokus.xtensions.optional.OptionalIntExtensions.*
import static extension de.fhg.fokus.xtensions.range.RangeExtensions.*
import org.junit.Ignore
import java.util.Random

@Ignore
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
		
		// int[].forEachInt(IntConsumer)
		arr.forEachInt [
			println()
		]
		
		// int[].stream()
		val sum = arr.stream.sum
	}
	
	@Test def void iterableDemo() {
		
		/////////////////////////
		// Primitive iterables //
		/////////////////////////
		
		
		// From array
		val int[] arr = #[0,2,4,19,-10,10_000,Integer.MAX_VALUE,Integer.MIN_VALUE]
		var ints = arr.asIntIterable(1, arr.length - 1) // omit first and last
		ints.print(5)
		
		// From IntegerRange
		ints = (0..50).withStep(2).asIntIterable
		ints.print(5)
		
		// From IntIterable.iterate
		ints = IntIterable.iterate(1)[it * 2] // infinite iterable
		ints.print(5)
		
		// From IntIterable.generate
		ints = IntIterable.generate [
			val rand = new Random;
			[rand.nextInt]
		]
		ints.stream.limit(10).forEach[println(it)]
		
		// From IntIterable.iterate with end
		ints = IntIterable.iterate(0, [it<=10], [it+2])
		ints.forEach[println(it)]
		
		// From optional
		ints = some(42).asIterable
		ints.forEach[println(it)]
		
		/////////////////
		// Iterable<T> //
		/////////////////
		
		val Iterable<String> strings = #["fooooo", "baar", "baz"]
		
		// collect directly on Iterable
		val avg = strings.collect(averagingInt[length])
		println('''Average length: «avg»''')
		
		// stream() from Iterable
		val charSum = strings.stream.flatMapToInt[it.chars].sum
		println('''Char sum: «charSum»''')
		
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
		
		
		(dunno || no).ifNotPresent[| println("Nothing to see here!")]
		
		//////////////////////////////////
		// Java 9 forward compatibility //
		//////////////////////////////////
		
		dunno.or[yes].ifPresent [println('''OR: «it»''')] // alternatively || operator
		
		dunno.ifPresentOrElse([println(it)], [println("awwww!")])
		
		// Optional.stream()
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