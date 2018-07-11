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
import java.nio.file.Paths
import java.time.Duration
import java.time.LocalDate
import java.util.ArrayList
import java.util.Iterator
import java.util.List
import java.util.Map
import java.util.Optional
import java.util.OptionalDouble
import java.util.OptionalInt
import java.util.PrimitiveIterator
import java.util.Random
import java.util.Set
import java.util.concurrent.CompletableFuture
import java.util.concurrent.CompletionException
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledThreadPoolExecutor
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeoutException
import java.util.concurrent.atomic.AtomicBoolean
import java.util.function.Function
import java.util.regex.Pattern
import java.util.stream.IntStream
import java.util.stream.Stream
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.junit.Assert
import org.junit.Ignore
import org.junit.Test

import static de.fhg.fokus.xtensions.concurrent.SchedulingUtil.*
import static java.util.concurrent.CompletableFuture.*
import static java.util.stream.Collectors.*

import static extension de.fhg.fokus.xtensions.concurrent.AsyncCompute.*
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*
import static extension de.fhg.fokus.xtensions.datetime.DurationExtensions.*
import static extension de.fhg.fokus.xtensions.function.FunctionExtensions.*
import static extension de.fhg.fokus.xtensions.iteration.IterableExtensions.*
import static extension de.fhg.fokus.xtensions.iteration.IteratorExtensions.*
import static extension de.fhg.fokus.xtensions.iteration.PrimitiveArrayExtensions.*
import static extension de.fhg.fokus.xtensions.iteration.PrimitiveIteratorExtensions.*
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*
import static extension de.fhg.fokus.xtensions.optional.OptionalIntExtensions.*
import static extension de.fhg.fokus.xtensions.pair.PairExtensions.*
import static extension de.fhg.fokus.xtensions.range.RangeExtensions.*
import static extension de.fhg.fokus.xtensions.stream.StreamExtensions.*
import static extension de.fhg.fokus.xtensions.stream.StringStreamExtensions.*
import static extension de.fhg.fokus.xtensions.string.StringMatchExtensions.*
import static extension de.fhg.fokus.xtensions.string.StringSplitExtensions.*
import static extension java.util.Arrays.stream
import java.util.stream.Collectors

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
		
		
		val summary = strings.collect(summarizingInt[length])
		println("Average length: " + summary.average)
		println("Max length: " + summary.max)
		
		#["foo", null, "BAR", "bazzzz"]
			.filterNull
			.averageSize
			.ifPresent [
				println('''The average string lenght is «it»''')
			]
			
		val s = #["I", "boo", "pity", "char", "the", "fool"]
			.withoutAll(#{"boo", "char"})
			.join(" ")
		println(s)
	}
	
	private def OptionalDouble averageSize(Iterable<String> strings) {
		strings.stream.mapToInt[length].average
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
	
	@Test def void iteratorDemo() {
		val Iterable<String> strings = #["fooooo", "baar", "baz"]
		val summary = strings.iterator.mapInt[length].summarize
		println("Size of longest string is " + summary.max)
		
		val s = #["I", "boo", "pity", "char", "the", "fool"]
			.iterator
			.withoutAll(#{"boo", "char"})
			.join(" ")
		println(s)
	}
	
	@Test def void primitiveIteratorDemo() {
		val range = 1..100
		val summary = range.intIterator.summarize
		println('''Sum of elements in range [«range.start»..«range.end»] is «summary.sum»''')
	}
	
	@Test def void optionalDemo() {
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
		
		val noVal = Optional.empty
		noVal.whenPresent [
			val value = noVal.get
			println("Here is your value: "+ value)
		].elseDo [
			println("Awww, no value")
		]
		
		val captureMe = "no value"
		noVal.whenPresent [
			println("Here is your value: "+ it)
		].elseDo(captureMe) [
			println("Awww, " + it)
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
			
		Stream.of(42.0, null, "foo", 100_000_000_000bi)
			.filterNull
			.forEach [
				// it is guaranteed to be != null 
				println(it.toString.toUpperCase)
			]
			
		
		val stream = Stream.of(
			new Developer("Max", #{"Java", "Xtend", "Rust", "C++"}), 
			new Developer("Joe", #{"Xtend", "JavaScript", "Dart"}) 
		);
		
		// Mapping language name to number of occurrences
		val Map<String, Long> langPopularity = stream
			.flatMap[languages]
			.collect(groupingBy(Function.identity, counting))
		
		langPopularity.entrySet
			.stream
			.max(Map.Entry.comparingByValue)
			.ifPresent [
				println('''Most pobular language: «it.key», count: «it.value»''')
			]
		
		// Combined example
		
		val max = new Person("Max","Bureck") => [
			vehicles += new Car("Imaginary Cars")
		]
		val persons = #[max,null]
		persons.stream
			.filter[it !== null]
			.flatMap[vehicles.stream]
			.filter[it instanceof Car]
			.map[it as Car]
			.collect(toList)
		// same as compact
		persons.stream
			.filterNull
			.flatMap[vehicles]
			.filter(Car)
			.toList
	}
	
	@FinalFieldsConstructor
	@Accessors
	static class Developer {
		val String name
		val Set<String> languages;
	}
	
	@Accessors
	static class Person {
		val String firstName
		val String lastName
		val List<Vehicle> vehicles = new ArrayList 
	}
	
	abstract static class Vehicle {
	}
	
	@Accessors
	@FinalFieldsConstructor
	static class Car extends Vehicle {
		val String make
	}
	
	@Accessors
	@FinalFieldsConstructor
	static class Bicycle extends Vehicle {
		val String manufacturer
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
		
		val s = pair.combine[k,v| k + ' -> ' + v].toLowerCase
		println(s)
	}
	
	@Test def void schedulingDemo() {
		
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
		
		val repeatingFut = repeatEvery(100, TimeUnit.MILLISECONDS).withInitialDelay(50) [
			println("Delayed start, repeated every 100 milis period")
		]
		
		waitFor(50.milliseconds) [
			repeatingFut.cancel(false)
		]
		
		val result = new CompletableFuture<String>
		result.thenAccept [
			println(it)
		]
		
		Executors.newCachedThreadPool.submit [
			Thread.sleep(100)
			result.complete("late response")
		]
		
		delay(50.milliseconds) [
			"default value"
		].forwardTo(result)
		
		result.join
	}
	
	@Test def void asyncDemo() {
		
		// Java 8
		val ex = Executors.newCachedThreadPool
		val isCancelled = new AtomicBoolean(false)
		runAsync([
			if(isCancelled.get) {
				println("Oh no, I've been cancelled")
			} else {
				println("I'm fine")				
			}
		], ex)
		isCancelled.set(true)
		
		// using AsyncCompute
		val pool = Executors.newCachedThreadPool
		val fut = pool.asyncRun [
			if(cancelled) {
				println("Oh no, I've been cancelled")
			} else {
				println("I'm fine")				
			}
		]
		fut.cancel(false)
		
		ex.shutdown()
		ex.awaitTermination(500, TimeUnit.MILLISECONDS)
		pool.shutdown()
		pool.awaitTermination(500, TimeUnit.MILLISECONDS)
		
		asyncSupply(10, TimeUnit.MILLISECONDS) [
			// some poor integration approximation
			val fx = [double x| x*x + 10 - (2*x)]
			var sum = 0.0d;
			for(i : 0..100_000) {
				
				// every now and then, check if we timed out
				if(i % 100 == 0) {
					if(done) {
						return 0.0d;
					}
				}
				// also using poor double accumulation
				sum += fx.apply(i as double)
			}
			sum
		].whenComplete[result, error | 
			if(error !== null) {
				println("Whoops, timeout")
			} else {
				println("result = " + result)
			}
		].join
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
		#["ay", "caramba", null, "we", "fools"]
			.filter(valid)
			.forEach[
				println(it)
			]
			
		val list = #["foo", "bar", "foo", "baz", "foo", "bar"]
		list.splitHead 
			>>> [head,tail| head -> tail.toSet.size]
			>>> [head,tailSize| '''Head: "«head»", remaining: «tailSize» unique elements''']
			>>> [println(it)]
	}
	
	def <T> Pair<T,Iterable<T>> splitHead(Iterable<T> elements) {
		elements.head -> elements.tail
	}
	
	@Test def void durationDemo() {
		val Duration twoPointFiveSeconds = 2.seconds + 500.milliseconds
	}
	
	@Test def void futureDemo() {
		val pool = Executors.newSingleThreadExecutor
		val fut = CompletableFuture.supplyAsync([
			new Random().nextInt(1000)
		],pool).then [ // thenApply, since has input and output value
			it / 10.0
		].then [ // thenAccept, since has input, but expression does not return value
			System.out.println('''Random percent: «it»''')
		].then [| // thenRun, since lambda does not take input
			System.out.println("The end.")
		]
		
		fut.join
		pool.shutdown()
		
		val toCancel = new CompletableFuture
		toCancel.whenCancelled [|
			println("I've been canceled")
		]
		toCancel.cancel
		
		CompletableFuture.supplyAsync [
			throw new IllegalStateException
		].whenException [
			println('''failed with «it.class» and cause «it.cause.class»''')
		]
		
		CompletableFuture.supplyAsync [
			throw new IllegalStateException("Boom!")
		].recoverWith[
			if(it.cause instanceof IllegalStateException)
				CompletableFuture.supplyAsync [
					"I was expecting you! Here is your asynchronous backup value."
				]
			else
				throw new IllegalArgumentException("Did not expect this!", it)
		].thenAccept [
			println(it)
		].join
		
		val lateVal = CompletableFuture.supplyAsync [
			// Do not do this at home!
			// We are blocking the common pool
			Thread.sleep(1000) 
			"here is some belated value."
		]
	
		val withBackup = lateVal.handleCancellation [
			"Here is some default value."
		].thenAccept [
			println(it)
		]
		
		// let's be impatient
		lateVal.cancel
		withBackup.join
		
		// Example for forwardCancellation (see someCancellableComposition)
		val forwarded = new CompletableFuture
		completeWithResult(forwarded, true)
	
		val executor = Executors.newCachedThreadPool
		val cancellable = someCancellableComposition(executor)
		cancellable.cancel
		executor.shutdown()
		executor.awaitTermination(100, TimeUnit.MILLISECONDS)
		
		
		// Example for cancelOnTimeout
		
		CompletableFuture.supplyAsync [
			Thread.sleep(100) // Never actually do this!
			"Wow, so late"
		].cancelOnTimeout(50, TimeUnit.MILLISECONDS)
		.whenCancelled[|
			println("Oh no! It took too long.")
		]
		
		// Example for complex orTimeout
		
		val slowFut = CompletableFuture.supplyAsync [
			Thread.sleep(100) // Never actually do this!
			"Phew, so late"
		]
		val withTimeout = slowFut.orTimeout [
			backwardPropagateCancel = false // do not cancel slowFut if withTimeout is cancelled
			cancelOriginalOnTimeout = false // do not cancel slowFut on timeout
			exceptionProvider = [new TimeoutException] // exception used to complete withTimeout on timeout
			scheduler = new ScheduledThreadPoolExecutor(1) // scheduler used for timeout
			timeout = (50L -> TimeUnit.MILLISECONDS) // time after which withTimeout is completed exceptionally
			tryShutdownScheduler = true // if true tries to shutdown the given scheduler when slowFut completes
		]
		
		try {
			withTimeout.join
		} catch(CompletionException e) {
			println("Value was too late.")
		}
		
		// whenCancelledInterrupt demo
		
		val blockOpPool = Executors.newCachedThreadPool
		val sleepy = blockOpPool.asyncRun [ CompletableFuture<?> it | 
			it.whenCancelledInterrupt [|
				try {
					Thread.sleep(100)
				} catch (InterruptedException e) {
					println("Hey, I was cancelled")
				}
			]
		]
		sleepy.cancel // may interrupt Thread.sleep
		blockOpPool.shutdown()
		blockOpPool.awaitTermination(100,TimeUnit.MILLISECONDS)
	}
	
	def void completeWithResult(CompletableFuture<String> res, boolean heavy) {
		if(heavy){
			doSomeHeavyWork().forwardTo(res)
		} else {
			res.complete("Some light work")
		}
	}
	
	def CompletableFuture<String> doSomeHeavyWork() {
		CompletableFuture.supplyAsync [
			"Did some heavy lifting"
		]
	}
	
	def CompletableFuture<String> someCancellableComposition(Executor executor) {
		val result = new CompletableFuture<String>
		val CompletableFuture<String> firstStep = firstStep(executor)
		result.forwardCancellation(firstStep)
		firstStep.thenCompose [
			val secondStep = secondStep(executor,it)
			result.forwardCancellation(secondStep)
			secondStep
		].forwardTo(result)
		
		result
	}
	
	def CompletableFuture<String> firstStep(Executor executor) {
		val result = new CompletableFuture<String>
		executor.execute [|
			Thread.sleep(10) // evil!
			if(result.cancelled) {
				println("cancelled in first step")
			} else {
				result.complete("Some result")
			}
		]
		result
	}
	
	def CompletableFuture<String> secondStep(Executor executor, String input) {
		val result = new CompletableFuture<String>
		executor.execute [|
			if(result.cancelled) {
				println("cancelled in first step")
			} else {
				val output = input.toUpperCase
				result.complete(output)
			}
		]
		result
	}
	
	private def Pair<String,Integer> getPair() {
		"Foo" -> 3
	}
	
	@Test
	def void groupByDemo() {
		val foo = "foo"
		val bar = "bar"
		val baz = "baz"
		val traverseMe = #[foo, #[bar], baz, #[foo], bar]
		val groups = traverseMe.groupIntoSetBy(String, List)
		
		val Set<String> strings = groups.get(String)
		val Set<List> lists = groups.get(List)
		val inNoList = strings
			.filter[str| 
				!lists.exists[it.contains(str)]
			].toList
		println("Elements contained in no list: " + inNoList)
	}
	
	@Test
	def void partitionByClassDemo() {
		val char[] chars = #[0x0020 as char, 0x0034 as char]
		val List<CharSequence> list = #[
			"Hello", 
			new StringBuilder().append(chars), 
			"Xtend", 
			new StringBuilder().append(0x0032 as char)
		]
		list.iterator.partitionBy(String) => [
			println('''Selected: "«selected.join(" ")»"''')	
			println('''Rejected: "«rejected.join("")»"''')
		]
	}
	
	@Test
	def void partitionByPredicateCollectors() {
		val list = #["foo", "bla", "foo", "hui", "fun"]
		val partition = list.iterator.partitionBy([startsWith("f")], Collectors::toSet, Collectors::toList)
		val Set<String> selected = partition.selected
		val List<String> rejected = partition.rejected
		println("Unique words starting with 'f' : " + selected.join(", "))
		println("Other words: " + rejected.join(", "))
	}
}