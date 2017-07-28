# Xtensions Library

This library is mainly a collection of [Xtend](https://www.eclipse.org/xtend/) extension methods
for classes in the Java 8 standard library and the Xtend standard library. A few goals are:

* Smooth iterop between Java 8 JDK types and types from the Xtend standard library
* Making a select few Java 9 methods available on Java 8
* Providing support for iteration over primitive values without having to use boxing
* Adding some useful additional methods to existing standard classes

## Usage

This chapter will provide a high level overview on how to use the different parts of this library.
Unfortunately 

### Extensions to Optional

TODO: Describe map to primitive Optionals
TODO: Describe Java 9 forward compatibility: 

#### Java 9 Forward Compatibility

TODO: Describe or
TODO: Describe ifPresentOrElse
TODO: Describe stream​

#### Factory Functions
TODO: Describe some / none / noInt / noLong / noDouble / onlyIf

#### Function Shortcut Aliases
TODO: ?: operators

#### Extensions to Optionals
TODO: 

#### Operators on Optionals
TODO: Describe || operator

#### From Optional to Collection
TODO: Describe toSet, toList

#### Extensions to Primitive Optionals
TODO: Describe map/mapX/filter to IterableX

### Extensions to IntegerRange
TODO: Describe stream(), 
Exmaple: 

	val range = (0..20).withStep(2)
	range.stream.filter[it % 5 == 0].sum

TODO: asIntIterable(), 
TODO: forEachInt, etc.

### Extensions on Primitive Arrays
TODO Describe int[]#forEachInt, asXIterable etc.

### Stream Extensions

TODO: Describe filter by class

TODO: Describe common Collectors to extension methods toList, toSet, toCollection
TODO: Describe concatenation operator +
TODO: Describe Java 9 forward compatibility for Stream.iterate 
TODO: Describe combinations extension methods

### Extensions to Primitive Stream 


### Extensions to Duration 

TODO: Describe constructor extensions (e.g. long#seconds)
TODO: Describe operators (+, -, /, *, >, <, >=, <=)


### Primitive Iterables

The JDK provides a generic `java.util.Iterator<T>` interface and primitive versions of the Iterator in form of the sub-interfaces of `java.util.PrimitiveIterator<T,T_CONS>`. However, there are no primitive versions of the `Iterable<T>` interface, constructing primitive iterators.

So the JDK is missing an interface to abstract over "a bunch" of primitive numbers. A primitive iterator or primitive stream can only traversed once, which is not very satisfying in many cases. Ideally there should be in interface allowing the iteration over a (possibly infinite) sequence of primitive numbers. We want to be able to get a primitive iterator, a primitive stream, or directly iterate over the elements with a `forEach` method. A set of these interfaces is provided in package `de.fhg.fokus.xtensions.iteration`.<br>
The primitive Iterable versions provided in the package all specialize `java.lang.Iterable` with the boxed
number type, but also provide specialized functions for providing primitive iterators, primitive streams, and 
forEach methods that do not rely on boxing the primitive values when passing them on to the consumer.

In the following sections we will explore the ways to create those primitive Iterables.

Examples:

	import de.fhg.fokus.xtensions.iteration.IntIterable
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
	var ints = arr.asIntIterable(1, arr.length - 1)  // omit first and last


#### From Computations

Currently only available on IntIterable

TODO: Describe IntIterable.generate
Example:

	import de.fhg.fokus.xtensions.iteration.IntIterable
	...
	val ints = IntIterable.generate [
		val rand = new Random;
		[rand.nextInt]
	]


TODO: Describe IntIterable.iterate(int, IntUnaryOperator)
Example:

	import de.fhg.fokus.xtensions.iteration.IntIterable
	...
	val ints = IntIterable.iterate(1)[it * 2]


TODO: Describe IntIterable.iterate(int, IntPredicate, IntUnaryOperator)
Example:

	import de.fhg.fokus.xtensions.iteration.IntIterable
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


### Primitive Array Extensions
TODO: Describe stream / toIterable / forEach

### Function Extensions

#### Function Composition
TODO: Describe andThen etc.

#### Throwing Functions
TODO: Describe Function#filterException, Function#recoverException, etc.

#### Lambda Recursion

### Concurrency Extensions

## Build

To build the libraries from source, simply drop into the root directory and call `mvn clean package`.
The main library will be located in `bundles/de.fhg.fokus.xtensions/target`

## Setting up the Development Environment