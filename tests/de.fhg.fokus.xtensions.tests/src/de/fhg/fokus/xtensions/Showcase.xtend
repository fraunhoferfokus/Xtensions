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
import static extension de.fhg.fokus.xtensions.stream.StreamExtensions.*
import org.junit.Ignore
import java.util.Random
import java.util.stream.IntStream
import java.util.PrimitiveIterator
import java.util.stream.Collectors
import java.util.Optional
import java.util.regex.Pattern

//@Ignore
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
			println(it)
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
//		ints.print(5)
		ints.printHex
		
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
	
	private def print(IntIterable ints, int count) {
		ints.stream.limit(count).forEach [
			println(it)
		]
	}
	
	private def printHex(IntIterable ints) {
		ints.forEachInt [
			val hex = Long.toHexString(it)
			println(hex)
		]
	}
	
	private def printHex(IntIterable ints, int limit) {
		val PrimitiveIterator.OfInt iter = ints.iterator
		for(var counter = 0; iter.hasNext && counter < limit; counter++) {
			val i = iter.nextInt
			val hex = Integer.toHexString(i)
			println(hex)
		}
	}
	
	private def printHexOdd(IntIterable ints) {
		val IntStream s = ints.stream.filter[it % 2 == 1]
		s.forEach [
			val hex = Long.toHexString(it)
			println(hex)
		]
	}
	
	@Test def optionalDemo() {
		// Aliases for empty, filled, and possibly filled optionals
		val no = <String>none
		val yes = some("yesss!")
		val dunno = maybe(possiblyNull())
		
		// Filter by type
		val Optional<Object> optObj = some("Hi there!")
		val Optional<String> optStr = optObj.filter(String)
		optStr.ifPresent [
			println(it.toUpperCase)
		]
		
		// view as iterable
		for(str : yes.asIterable) {
			println("Iterating over: " + str)
		}
		for(str : no.asIterable) {
			println("I will never be printed")
		}
		
		// map to primitive optionals
		val size = dunno.mapInt[length]
		
		
		if(someOf(42) === someOf(42)) {
			println("someOf caches instances")
		}
		
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
	
	private def possiblyNull() {
		if(System.currentTimeMillis % 2 == 0) {
			"I'm in ur optional"
		} else {
			null
		}
	}
	
	@Test def void streamDemo() {
		val s = Stream.of(42, "Hello", Double.NaN, "World")
			.filter(String)
			.collect(Collectors.joining(" "))
		println(s)
		
		val list = Stream.of("Foo", "Hello" , "Boo", "World")
			.filter[!contains("oo")]
			.map[toUpperCase]
			.toList
	}
	
	
	@Test def void stringDemo() {
		
		// TIP: use pattern as extension object
		extension val pattern = Pattern.compile("(?<=oo)")
		"foobar".splitAsStream.forEach[println(it)]
	}
	
}