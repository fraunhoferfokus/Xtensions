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
}