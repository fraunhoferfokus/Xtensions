package de.fhg.fokus.xtensions.stream

import org.junit.Test
import java.util.stream.Stream
import static extension de.fhg.fokus.xtensions.stream.StreamExtensions.*
import static org.junit.Assert.*
import static extension java.util.Arrays.*
import java.util.concurrent.atomic.AtomicBoolean
import java.util.Optional
import java.util.stream.Collectors
import java.util.Set

class StreamExtensionsTest {
	
	///////////////////////
	// flatMap(Iterable) //
	///////////////////////
	
	@Test(expected=NullPointerException) def void testFlatMapStreamNull() {
		val Stream<String> stream = null;
		stream.flatMap[newArrayList]
	}
	
	@Test(expected=NullPointerException) def void testFlatMapMapperNull() {
		val stream = Stream.of("foo", "bar", "baz")
		val (String)=>Iterable<String> mapper = null
		stream.flatMap(mapper)
	}
	
	@Test def void testFlatMapEmptyStream() {
		val stream = Stream.<String>of()
		val (String)=>Iterable<String> mapper = [throw new IllegalStateException]
		val result = stream.flatMap(mapper)
		assertEquals(0, result.count)
	}
	
	@Test def void testFlatMapSingleElementStream() {
		val expected = "foo"
		val expectedOut = #["hui", "boo"]
		val stream = Stream.of(expected)
		val result = stream.flatMap[
			assertSame(expected,it)
			expectedOut
		].toArray
		assertArrayEquals(expectedOut, result)
	}
	
	@Test def void testFlatMapMultipleElements() {
		val input = #["hui", "boo", "bar"]
		val expectedOut = input.join
		val output = input.stream.flatMap [
			val Iterable<String> result = it.split("")
			result
		].collect(Collectors.joining)
		assertEquals(expectedOut, output)
	}
	
	@Test(expected = NullPointerException) def void testFlatMapMapperReturningNull() {
		val input = #["hui", "boo", "bar"]
		input.stream.flatMap [null].toArray
	}
	
	///////////////////
	// filter(Class) //
	///////////////////
	
	@Test def void testStreamFilterByClass() {
		val stream = Stream.of("foo", null, 3, new StringBuilder("bar"))
		val result = stream.filter(CharSequence).toArray
		assertEquals(2, result.length)
		assertEquals("foo", result.get(0))
		assertEquals("bar", result.get(1).toString)
	}
	
	////////////////
	// filterNull //
	////////////////
	
	@Test def void testStreamFilterNull() {
		val stream = Stream.of("foo", null, 3, #[5.0d], null)
		val result = stream.filterNull.toArray
		val Object[] expected = #["foo", 3, #[5.0d]]
		assertArrayEquals(expected, result)
	}
	
	@Test def void testStreamFilterEmpty() {
		val stream = Stream.empty
		val result = stream.filterNull.toArray
		assertArrayEquals(#[], result)
	}
	
	@Test def void testStreamFilterAllNull() {
		val stream = Stream.of(null, null, null)
		val result = stream.filterNull.toArray
		assertArrayEquals(#[], result)
	}
	
	////////////
	// toList //
	////////////
	
	@Test def void testToListEmpty() {
		val result = Stream.empty.toList
		assertTrue(result.empty)
	}
	
	@Test def void testToList() {
		val Object[] expected = #["foo", 3, null, 800_000bd]
		val result = Stream.of(expected).toList
		assertEquals(expected.asList ,result)
	}
	
	////////////
	// toSet  //
	////////////
	
	@Test def void testToSetEmpty() {
		val result = Stream.empty.toSet
		assertTrue(result.empty)
	}
	
	@Test def void testToSet() {
		val expected = #{"foo", 3, null, 800_000bd}
		val result = Stream.of(expected.toArray).toSet
		assertEquals(expected ,result)
	}
	
	///////////////////
	// toCollection  //
	///////////////////
	
	
	@Test def void testToCollectionEmpty() {
		val AtomicBoolean ab = new AtomicBoolean(false)
		val result = Stream.empty.toCollection[ab.set(true);newArrayList]
		assertTrue(ab.get)
		assertTrue(result.empty)
	}
	
	@Test def void testToCollection() {
		val Object[] expected = #["foo", 3, null, Optional.empty]
		val AtomicBoolean ab = new AtomicBoolean(false)
		val result = Stream.of(expected).toCollection[ab.set(true);newArrayList]
		assertTrue(ab.get)
		assertArrayEquals(expected, result.toArray)
	}
	
	///////////////////
	// concatenation //
	///////////////////
	
	@Test def void testPlus() {
		val concat = Stream.of("foo", "bar") + Stream.of("baz", "boo")
		val result = concat.toArray
		val expected = #["foo", "bar","baz", "boo"]
		assertArrayEquals(expected, result)
	}
	
	/////////////////////////////
	// combinations (iterable) //
	/////////////////////////////
	
	@Test def void combinationsIterableEmptyStream() {
		val arr = Stream.empty.combinations(#["foo", "bar"]).toArray
		assertEquals(0, arr.length)
	}
	
	@Test def void combinationsIterableEmptyIterable() {
		val arr = Stream.of("foo", "bar").combinations(#[]).toArray
		assertEquals(0, arr.length)
	}
	
	@Test def void combinationsIterable() {
		val result = Stream.of("foo", "bar").combinations(#[1,2]).collect(Collectors.toSet)
		val Set<Pair<String,Integer>> expected = #{"foo"->1, "bar"->1, "foo"->2, "bar"->2}
		assertEquals(expected, result)
	}
	
	/////////////////////////////
	// combinations (stream) //
	/////////////////////////////
	
	@Test def void combinationsIterableStreamStream() {
		val arr = Stream.empty.combinations[Stream.of("foo", "bar")].toArray
		assertEquals(0, arr.length)
	}
	
	@Test def void combinationsStreamEmptyStream() {
		val arr = Stream.of("foo", "bar").combinations[Stream.empty].toArray
		assertEquals(0, arr.length)
	}
	
	@Test def void combinationsStream() {
		val result = Stream.of("foo", "bar").combinations[Stream.of(1,2)].collect(Collectors.toSet)
		val Set<Pair<String,Integer>> expected = #{"foo"->1, "bar"->1, "foo"->2, "bar"->2}
		assertEquals(expected, result)
	}
	
	
	///////////////////////////////////////
	// combinations (iterable, combiner) //
	///////////////////////////////////////
	
	@Test def void combinationsIterableCombinerEmptyStream() {
		val arr = Stream.<String>empty.combinations(#["foo", "bar"])[$0+$1].toArray
		assertEquals(0, arr.length)
	}
	
	@Test def void combinationsIterableCombinerEmptyIterable() {
		val arr = Stream.of("foo", "bar").combinations(#[])[$0+$1].toArray
		assertEquals(0, arr.length)
	}
	
	@Test def void combinationsCombinerIterable() {
		val result = Stream.of("foo", "bar").combinations(#["hui","buh"])[$0+$1].collect(Collectors.toSet)
		val Set<String> expected = #{"foohui", "barhui", "foobuh", "barbuh"}
		assertEquals(expected, result)
	}
	
	/////////////////////////////
	// combinations (stream) //
	/////////////////////////////
	
	@Test def void combinationsStreamCombinerEmptyStream() {
		val arr = Stream.empty.combinations([Stream.of("foo", "bar")])[$0+$1].toArray
		assertEquals(0, arr.length)
	}
	
	@Test def void combinationsStreamCombinerEmptyStream2() {
		val arr = Stream.of("foo", "bar").combinations([Stream.empty])[$0+$1].toArray
		assertEquals(0, arr.length)
	}
	
	@Test def void combinationsStreamCombiner() {
		val result = Stream.of("foo", "bar").combinations([Stream.of("hui","buh")])[$0+$1].collect(Collectors.toSet)
		val Set<String> expected = #{"foohui", "barhui", "foobuh", "barbuh"}
		assertEquals(expected, result)
	}
	
	/////////////
	// iterate //
	/////////////
	
	@Test def void iterateEmpty() {
		val Stream<Integer> s = Stream.iterate​(1,[it<1],[it+1])
		assertEquals(0,s.count)
	}
	
	@Test def void iterateTwoElements() {
		val Stream<Integer> s = Stream.iterate​(0,[it<3],[it+2])
		val actual = s.toArray()
		val Integer[] expected = #[0,2]
		assertArrayEquals(expected,actual)
	}
	
	@Test def void iterateFiveElements() {
		val Stream<Integer> s = Stream.iterate​(1,[it!=32],[it*2])
		val actual = s.toArray()
		val Integer[] expected = #[1,2,4,8,16]
		assertArrayEquals(expected,actual)
	}
	
	///////////////
	// findFirst //
	///////////////
	
	@Test def void findFirstEmptyStream() {
		val Stream<String> stream = Stream.empty
		val opt = stream.findFirst[true]
		assertFalse(opt.present)
		
		val Stream<String> stream2 = Stream.empty
		val opt2 = stream2.findFirst[false]
		assertFalse(opt2.present)
	}
	
	@Test def void findFirstNotMatchingStream() {
		val stream = Stream.of("boo", "foo", "zoo")
		val opt = stream.findFirst[startsWith("go")]
		assertFalse(opt.present)
	}
	
	@Test def void findFirstOneMatchingStream() {
		val expected = "foo"
		val stream = Stream.of("boo", expected, "zoo")
		val opt = stream.findFirst[startsWith("fo")]
		assertTrue(opt.present)
		val result = opt.get
		assertSame(expected, result)
	}
	
	@Test def void findFirstMultipleMatchingStream() {
		val expected = "fog"
		val stream = Stream.of("boo", expected, "foo", "zoo", "foul")
		val opt = stream.findFirst[startsWith("fo")]
		assertTrue(opt.present)
		val result = opt.get
		assertSame(expected, result)
	}
	
	/////////////
	// findAny //
	/////////////
	
	@Test def void findAnyEmptyStream() {
		val Stream<String> stream = Stream.empty
		val opt = stream.findAny[true]
		assertFalse(opt.present)
		
		val Stream<String> stream2 = Stream.empty
		val opt2 = stream2.findAny[false]
		assertFalse(opt2.present)
	}
	
	@Test def void findAnyNotMatchingStream() {
		val stream = Stream.of("boo", "foo", "zoo")
		val opt = stream.findAny[startsWith("go")]
		assertFalse(opt.present)
	}
	
	@Test def void findAnyOneMatchingStream() {
		val expected = "foo"
		val stream = Stream.of("boo", expected, "zoo")
		val opt = stream.findAny[startsWith("fo")]
		assertTrue(opt.present)
		val result = opt.get
		assertSame(expected, result)
	}
	
	@Test def void findAnyMultipleMatchingStream() {
		val expected = #{"fog", "foo", "foo"}
		val stream = Stream.of("boo", "fog", "foo", "zoo", "foo")
		val opt = stream.findFirst[startsWith("fo")]
		assertTrue(opt.present)
		val result = opt.get
		assertTrue(expected.contains(result))
	}
	
	
	/////////
	// min //
	/////////
	
	@Test def void minEmptyStream() {
		val opt = Stream.<String>empty.min
		assertFalse(opt.present)
	}
	
	@Test def void minOneElementStream() {
		val expected = "something"
		val opt = Stream.of(expected).min
		assertTrue(opt.present)
		assertSame(expected, opt.get)
	}
	
	@Test def void minMultipleElementStream() {
		val expected = "aa"
		val opt = Stream.of("ac", expected, "ab").min
		assertTrue(opt.present)
		assertSame(expected, opt.get)
	}
	
	
	/////////
	// max //
	/////////
	
	@Test def void maxEmptyStream() {
		val opt = Stream.<String>empty.max
		assertFalse(opt.present)
	}
	
	@Test def void maxOneElementStream() {
		val expected = "something"
		val opt = Stream.of(expected).max
		assertTrue(opt.present)
		assertSame(expected, opt.get)
	}
	
	@Test def void maxMultipleElementStream() {
		val expected = "ac"
		val opt = Stream.of("aa", expected, "ab").max
		assertTrue(opt.present)
		assertSame(expected, opt.get)
	}
}