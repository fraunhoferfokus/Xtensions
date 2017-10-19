/*******************************************************************************
 * Copyright (c) 2017 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions

import de.fhg.fokus.xtensions.iteration.IntIterable
import java.util.stream.Stream
import org.junit.Test

import static java.util.stream.Collectors.*

import static extension de.fhg.fokus.xtensions.iteration.PrimitiveArrayExtensions.*
import static extension de.fhg.fokus.xtensions.function.FunctionExtensions.*
import static extension de.fhg.fokus.xtensions.string.StringMatchExtensions.*
import static extension de.fhg.fokus.xtensions.iteration.IterableExtensions.*
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*
import static extension de.fhg.fokus.xtensions.optional.OptionalIntExtensions.*
import static extension de.fhg.fokus.xtensions.range.RangeExtensions.*
import static extension de.fhg.fokus.xtensions.stream.StreamExtensions.*
import static extension de.fhg.fokus.xtensions.stream.StringStreamExtensions.*
import static extension de.fhg.fokus.xtensions.string.StringSplitExtensions.*
import static extension de.fhg.fokus.xtensions.pair.PairExtensions.*
import static extension java.util.Arrays.*
import static extension org.eclipse.xtext.xbase.lib.InputOutput.*
import static extension de.fhg.fokus.xtensions.datetime.DurationExtensions.*
import org.junit.Ignore
import java.util.Random
import java.util.stream.IntStream
import java.util.PrimitiveIterator
import java.util.stream.Collectors
import java.util.Optional
import java.util.regex.Pattern
import java.util.Iterator
import java.util.OptionalInt

import static extension de.fhg.fokus.xtensions.datetime.DurationExtensions.*
import org.junit.Assert

import static extension de.fhg.fokus.xtensions.concurrent.SchedulingUtil.*
import java.util.concurrent.TimeUnit
import java.time.Duration
import java.time.LocalDate
import java.nio.file.Paths

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
		var IntIterable ints = arr.asIntIterable(1, arr.length - 1) // omit first and last
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
		
		
		val summary = strings.collect(Collectors.summarizingInt[length])
		println("Average: " + summary.average)
		println("Max: " + summary.max)
		
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
		val OptionalInt lenOpt = dunno.mapInt[length]
		val len = lenOpt.orElse(0)
		println("Length is " + len)
		
		
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
			
	
		val min = Stream.of("ac", "aa", "ab").min
		Assert.assertEquals("aa", min.get)
		
		Stream.iterate("na ")[it + it]
			.filter[length > 15]
			.findFirst
			.ifPresent [
				println(it + "Batman!")
			]
		
		Stream.of("foo", "bar")
			.combinations(#["fun", "boo", "faz"])[a,b|a+b]
			.forEach[
				println(it)
			]
	}
	
	@Test def void stringStreamDemo() {
		val joined = Stream.of("Hello", "Xtend", "aficionados").join(" ")
		println(joined)
		
		Stream.of("foo", "bar", "kazoo", "baz", "oomph", "shoot")
			.matching(".+oo.*")
			.forEach [
				println(it)
			]
			
		Stream.of("Hello users", "welcome to this demo", "hope it helps")
			.flatSplit("\\s+")
			.forEach [
				println(it)
			]
		
		val Pattern pattern = Pattern.compile("(\\woo)")		
		Stream.of("Welcome to the zoo", "Where cows do moo", "And all animals poo")
			.flatMatches(pattern)
			.forEach [
				println(it)
			]
	}
	
	
	@Test def void stringDemo() {
		
		// TIP: use pattern as extension object
		extension val pattern = Pattern.compile("(?<=oo)")
		"foobar".splitAsStream.forEach[println(it)]
		
		val Iterator<String> i = "foozoobaar".splitIt("(?<=oo)")
		i.takeWhile[!startsWith("b")].forEach[
			println(it)
		]
	}
	
	@Test def void stringMatchIteratorDemo() {
		val String input = "foo bar boo"
		val Pattern pattern = Pattern.compile("(\\woo)")
		
		// Iterate over matches of pattern in input
		val matcher = pattern.matcher(input)
		while(matcher.find) {
			val match = input.subSequence(matcher.start, matcher.end)
			// Do something with match
			println(match)
		}
		
		// Same iteration, now with iterator
		input.matchIt(pattern).forEach [
			println(it)
		]
	}
	
	@Test def void pairDemo() {
		
		val pair = "Foo" -> 3
		pair => [k,v|
			println(k + ' -> ' + v)
		]
		
		pair.combine[k,v| k + ' -> ' + v].println
		
	}
	
	@Test def void schdulingDemo() {
		
		// Cancelling from outside
		val hundredMs = 100.milliseconds
		val fut = repeatEvery(hundredMs) [
			for(i : 0..Integer.MAX_VALUE) {
				if(cancelled) {
					println("I've been cancelled at iteration " + i)
					return
				}
			}
		]
		fut.cancel(false)
		
		val fut2 = repeatEvery(100, TimeUnit.MILLISECONDS).withInitialDelay(50) [
			println("Delayed start, repeated every 100 milis period")
		]
		
		delay(500.milliseconds) [
			fut2.cancel(false)
		]
	}
	
	@Test def void functionDemo() {
		val pair = getPair() >>> [k,v| k.toUpperCase -> v]
		println(pair)
		
		val ()=>LocalDate inOneYear = [LocalDate.now.plusYears(1)]
		val (LocalDate)=>String yearString = [it.year.toString]
		val ()=>String nextYear = inOneYear.andThen(yearString)
		println(nextYear.apply)

		
		val (LocalDate)=>LocalDate oneYearLater = [it.plusYears(1)]
		val (LocalDate)=>String yearAfter = oneYearLater >> yearString
		
		LocalDate.now >>> yearAfter >>> [println(it)]
		
		val path = System.getProperty("user.home") >>> [Paths.get(it)]
		println(path.parent)
		
		val (String)=>boolean notThere = [it.nullOrEmpty]
		val (String)=>boolean tooShort = [it.length < 3]
		val (String)=>boolean valid = notThere.or(tooShort).negate
		#["ay", "caramba", "", "we", "fools"]
			.filter(valid)
			.forEach[
				println(it)
			]
	}
	
	@Test def void durationDemo() {
		val Duration twoPointFiveSeconds = 2.seconds + 500.milliseconds
	}
	
	private def Pair<String,Integer> getPair() {
		"Foo" -> 3
	}
	
}