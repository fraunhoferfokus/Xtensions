# Xtensions Library

This library is mainly a collection of [Xtend](https://www.eclipse.org/xtend/) extension methods
for classes in the Java 8 standard library and the Xtend standard library. A few goals are:

* Smooth iterop between Java 8 JDK types and types from the Xtend standard library
* Making a select few Java 9 methods available on Java 8
* Providing support for iteration over primitive values without having to use boxing
* Adding some useful additional methods to existing standard classes

## Usage

This chapter will provide a high level overview on how to use the different parts of this library.
Unfortunately there is currently no built available via a maven or p2 repository. So the library
has to be built from source. See chapter [Build](#build).

When using the library in OSGi it is recommended to use package imports since the library may evolve
and split into multiple bundles in future releases.

### Extensions to Optional

The static factory Methods for creating `Optional` instances are not really meant to be used as 
statically imported methods. They have no meaningful names to be used this way. They also differ from
the commonly used names `some`, `none` and `maybe` which are used in many other languages.  
The class `OptionalIntExtensions` provides static factory methods with these common names
which are implemented to be inlined to the factory methods used by the JDK.

Examples:

	import static extension de.fhg.fokus.xtensions.optional.OptionalIntExtensions.*
	...
	val Optional<String> no = none
	val Optional<String> yes = some("yesss!")
	val Optional<String> dunno = maybe(possiblyNull())
	...
	private def possiblyNull() {
		if(System.currentTimeMillis % 2 == 0) {
			"I'm in ur optional"
		} else {
			null
		}
	}

The optional class does not provide a `filter` method, that filters the optional based on the class
of the object wrapped. The `OptionalIntExtensions` adds such a method, providing an instance
check of the wrapped value.

Example:

	val Optional<Object> optObj = some("Hi there!")
	val Optional<String> optStr = optObj.filter(String)
	optStr.ifPresent [
		println(it.toUpperCase)
	]

To bridge between APIs providing an `Optional` value and ones that expect
multiple values, the extension methods `asIterable`, `toList` and `toSet`
are provided to create immutable implementations of common JVM collection APIs.

Examples:

	import static extension de.fhg.fokus.xtensions.optional.OptionalIntExtensions.*
	...
	val Optional<String> yes = some("yesss!")
	
	// view as iterable
	for(str : yes.asIterable) {
		println("Iterating over: " + str)
	}
	
	// TODO view as List
	yes.toList
	
	// TODO view as Set
	yes.toSet


TODO: Describe map to primitive Optionals  

TODO: describe Java 9 Forward Compatibility  
* TODO: Describe or  
* TODO: Describe ifPresentOrElse  
* TODO: Describe stream  

TODO: Describe || operator ?: operators
​

### Extensions to Primitive Optionals

TODO: Describe noInt / noLong / noDouble

The Oracle JDK currently does not cache OptionalInt and OptionalLong instances in the static factory method 
`OptionalInt.of(int)` and `OptionalLong.of(long)` as it is currently done for Integer creation in 
`Integer.valueOf(int)`. To provide such a caching static factory methods, the 
`OptionalIntExtensions.someOf(int)` and `OptionalLongExtensions.someOf(long)` method were 
introduced.

Example:

	if(someOf(42) === someOf(42)) {
		println("someOf caches instances")
	}


TODO: Describe map/mapX/filter to IterableX

### Extensions to IntegerRange

IntegerRange is a handy type from the Xtend standard library which can
be constructed using the `..` operator. But the only way to iterate 
over the elements of the range is by boxing the integers while iterating.

The extensions provided by this library allow iterating over the primitive
values of the range.

One way to iterate over the range is to use Java 8 streams, by using the 
`stream` or `parallelStream` extension method from the class 
`de.fhg.fokus.xtensions.range.RangeExtensions`.
  
Exmaple: 

	import static extension de.fhg.fokus.xtensions.range.RangeExtensions.*
	...
	val range = (0..20).withStep(2)
	range.stream.filter[it % 5 == 0].sum

Another way to iterate over the elements of a range is to use the `forEachInt` method.

Example:

	import static extension de.fhg.fokus.xtensions.range.RangeExtensions.*
	...
	val range = (0..20).withStep(2)
	range.forEachInt [
		println(it)
	]

To interact with consumers expecting an `IntIterable` (see [Primitive Iterables](#primitive-iterables)), which is a generic interface 
for iteration over primitive int values provided by this library, the extension method
`asIntIterable` was provided.

### Extensions to Pair

TODO: Describe with operator  
TODO: Describe combine   
TODO: Describe safeCombine   

### Extensions to Primitive Arrays

The class `de.fhg.fokus.xtensions.iteration.PrimitiveArrayExtensions` contains extension methods for 
arrays of primitive values (int, long, double) to iterate with a forEach method consuming primitive values.

Example:

	val int[] arr = #[3,4,6]
	arr.forEachInt [
		println(it)
	]

Additionally the class allows to create primitive iterable wrapper objects (see [Primitive Iterables](#primitive-iterables)).

Tip:

Note that the JDK class [`java.util.Arrays`](http://docs.oracle.com/javase/8/docs/api/java/util/Arrays.html) already contains 
static `stream` methods that can be used as extension methods to create Java 8 streams from primitive arrays.


### Extensions to Streams

The class `de.fhg.fokus.xtensions.stream.StreamExtensions`

Java 8 streams are missing a few methods known from the Xtend iterable extension methods.
The one method that is probably most often used is the method to filter by type. This can easily
be retrofitted on the Streams API by an extension method. This extension method is provided
in the `StreamExtensions` class.

Example: 


	import static extension de.fhg.fokus.xtensions.stream.StreamExtensions.*
	...
	val s = Stream.of(42, "Hello", Double.NaN, "World")
		.filter(String)
		.collect(Collectors.joining(" "))

Note: Since joining Strings is a common operation, the `StringStreamExtensions` allow to call `join`
directly on the Stream. Have a look at [Extensions to Streams of Strings](#extensions-to-streams-of-strings).

Some other collectors, especially the ones bridging to the collections API are also used very often,
but using the collect method with the methods from the `Collectors` class is a bit verbose.  
As a shortcut the `StreamExtensions` class provides `toList`, `toSet`, and `toCollection` 
extension methods to the `Stream` class.

Example:

	import static extension de.fhg.fokus.xtensions.stream.StreamExtensions.*
	...
	val list = Stream.of("Foo", "Hello" , "Boo", "World")
		.filter[!contains("oo")]
		.map[toUpperCase]
		.toList


TODO: Describe concatenation operator +  
TODO: Describe Java 9 forward compatibility for Stream.iterate  
TODO: Describe combinations extension methods  

### Extensions to Streams of Strings

TODO: Describe join collector extension method  
TODO: Describe matching filter extension method  
TODO: Describe flatSplit mapping extension method  
TODO: Describe flatMatches mapping extension method  
TODO: Describe join collector

### Extensions to Iterable

`de.fhg.fokus.xtensions.iteration.IterableExtensions`

TODO: Describe extension method `stream`  
TODO: Describe extension method `parallelStream`  
TODO: Describe extension method `collect`  

### Extensions to PrimitiveIterators

TODO: Describe extension methods `streamRemaining` / `streamRemainingAsync`  


### Primitive Iterables

The JDK provides a generic [`java.util.Iterator<T>`](http://docs.oracle.com/javase/8/docs/api/java/util/Iterator.html) interface and primitive versions of the Iterator in form of the sub-interfaces of [`java.util.PrimitiveIterator<T,T_CONS>`](http://docs.oracle.com/javase/8/docs/api/java/util/PrimitiveIterator.html). However, there are no primitive versions of the [`java.lang.Iterable<T>`](http://docs.oracle.com/javase/8/docs/api/java/lang/Iterable.html) interface, constructing primitive iterators.

So the JDK is missing an interface to abstract over "a bunch" of primitive numbers to iterate over. A primitive iterator or primitive stream can only traversed once, which is not very satisfying in many cases. Ideally there should be in interface allowing the iteration over a (possibly infinite) sequence of primitive numbers. We want to be able to get a primitive iterator, a primitive stream, or directly iterate over the elements with a `forEach` method. A set of these interfaces is provided in package `de.fhg.fokus.xtensions.iteration`.<br>
The primitive Iterable versions provided in the package all specialize `java.lang.Iterable` with the boxed
number type, but also provide specialized functions for providing primitive iterators, primitive streams, and 
forEach methods that do not rely on boxing the primitive values when passing them on to the consumer.

In the following sections we will explore the ways to create those primitive Iterables.

Examples:

	import static extension de.fhg.fokus.xtensions.iteration.IntIterable.*
	...
	
	def printHex(IntIterable ints) {
		ints.forEachInt [
			val hex = Long.toHexString(it)
			println(hex)
		]
	}
	
	def printHex(IntIterable ints, int limit) {
		val PrimitiveIterator.OfInt iter = ints.iterator
		for(var counter = 0; iter.hasNext && counter < limit; counter++) {
			val i = iter.nextInt
			val hex = Integer.toHexString(i)
			println(hex)
		}
	}
	
	def printHexOdd(IntIterable ints) {
		val IntStream s = ints.stream.filter[it % 2 == 1]
		s.forEach [
			val hex = Long.toHexString(it)
			println(hex)
		]
	}


#### From Arrays

The `asIntIterable` extension method method creates a primitive iterable for primitive arrays.
There are two versions: One version creates an iterable over the complete array, the other one produces
an iterable over a section of the array. The section can be specified by defining the start index and
an excluding end index. 

Example:

	import static extension de.fhg.fokus.xtensions.iteration.PrimitiveArrayExtensions.*
	...
	val int[] arr = #[0,2,4,19,-10,10_000,Integer.MAX_VALUE,Integer.MIN_VALUE]
	var ints = arr.asIntIterable(1, arr.length - 1)  // omit first and last element


#### From Computations

Currently only available on IntIterable

TODO: Describe IntIterable.generate  

Example:

	import static extension de.fhg.fokus.xtensions.iteration.IntIterable.*
	...
	val ints = IntIterable.generate [
		val rand = new Random;
		[rand.nextInt]
	]


TODO: Describe IntIterable.iterate(int, IntUnaryOperator)  

Example:

	import static extension de.fhg.fokus.xtensions.iteration.IntIterable.*
	...
	val ints = IntIterable.iterate(1)[it * 2]


TODO: Describe IntIterable.iterate(int, IntPredicate, IntUnaryOperator)  

Example:

	import static extension de.fhg.fokus.xtensions.iteration.IntIterable.*
	...
	val ints = IntIterable.iterate(0, [it<=10], [it+2])


#### From Xtend Ranges

Creating iterables from `org.eclipse.xtext.xbase.lib.IntegerRange` can be done via the extensions 
class `de.fhg.fokus.xtensions.range.RangeExtensions`.

Example:

	import static org.eclipse.xtext.xbase.lib.IntegerRange.*
	...
	val iter = (0..50).withStep(2).asIntIterable


Creating iterables from `org.eclipse.xtext.xbase.lib.ExclusiveRange`s is currently not supported,
due to the API limitations on that class. 


#### From Primitive Optionals

The extension classes for primitive Optionals allow the creation of primitive iterables allowing 
iteration over either one or no value, depending on the source Optional.

Example:

	import static extension de.fhg.fokus.xtensions.optional.OptionalIntExtensions.*
	...
	val ints = some(42).asIterable

### Extensions to String 

TODO: Describe extension method matchIt  
TODO: Describe extension method matchResultIt  
TODO: Describe extension method splitIt  
TODO: Describe extension method splitStream  


### Extensions to Duration 

TODO: Describe constructor extensions (e.g. long#seconds)  
TODO: Describe operators (+, -, /, *, >, <, >=, <=)

### Extensions to Functions

Function Composition  
TODO: Describe andThen etc.

Throwing Functions  
TODO: Describe Function#filterException, Function#recoverException, etc.

Lambda Recursion

### Extensions to CompletableFuture

TODO: Describe then-Methods  
TODO: Describe whenCancelled/whenCancelledAsync extension method  
TODO: Describe whenException/whenExceptionAsync extension method  
TODO: Describe whenException/whenExceptionAsync extension method  
TODO: Describe recoverWith/recoverWithAsnyc extension method  
TODO: Describe handleCancellation/handleCancellationAsync extension method  
TODO: Describe forwardTo extension method  
TODO: Describe forwardCancellation extension method  
TODO: Describe cancelOnTimeout extension method  
TODO: Describe whenCancelledInterrupt method  

TODO: Describe Java 9 forward compatibility  
* TODO: Describe extension method orTimeout
* TODO: Describe extension method copy

### Async Computations

TODO: Describe asyncRun methods  
TODO: Describe asyncSupply methods  
TODO: Describe async methods

### Scheduling

TODO: Describe repeatEvery methods  
TODO: Describe repeatWithFixedDelay methods  
TODO: Describe waitFor methods  
TODO: Describe delay methods  

## Build

The build is based on maven tycho, so [Maven 3.0](http://maven.apache.org/download.cgi) or higher has to be installed on 
the machine.

To build the libraries from source, simply drop into the root directory and call `mvn clean package`.
The main library will be located in `bundles/de.fhg.fokus.xtensions/target`

## Setting up the Development Environment