package de.fhg.fokus.xtensions.iteration

import org.junit.Test
import static extension de.fhg.fokus.xtensions.iteration.IterableExtensions.*
import static org.junit.Assert.*
import static java.util.stream.Collectors.*
import java.util.Arrays

class IterableExtensionsTest {

	/////////////
	// collect //
	/////////////

	@Test def testCollect() {
		val joined = #["foo", "bar", "baz"].collect(joining(",", "'", "'"))
		assertEquals("'foo,bar,baz'", joined)
		
		val joinedEmpty = #[].collect(joining(",", "'", "'"))
		assertEquals("''", joinedEmpty)
	}

	////////////
	// stream //
	////////////
	
	@Test def iterableEmptyCollectionStream() {
		val Iterable<String> iterable = #[]
		val result = iterable.stream.toArray
		assertEquals(0, result.length)
	}

	@Test def iterableCollectionStream() {
		val String[] expected = #["foo", null, "bar", ""]
		val Iterable<String> iterable = Arrays.asList(expected)
		val result = iterable.stream.toArray
		assertArrayEquals(expected, result)
	}
	
	@Test def iterableEmptyIterableStream() {
		val Iterable<String> iterable = [#[].iterator]
		val result = iterable.stream.toArray
		assertEquals(0, result.length)
	}

	@Test def iterableIterableStream() {
		val String[] expected = #["foo", null, "bar", ""]
		val Iterable<String> iterable = [expected.iterator]
		val result = iterable.stream.toArray
		assertArrayEquals(expected, result)
	}

	////////////////////
	// parallelStream //
	////////////////////

	
	@Test def iterableEmptyCollectionParallelStream() {
		val Iterable<String> iterable = #[]
		val result = iterable.parallelStream.toArray
		assertEquals(0, result.length)
	}

	@Test def iterableCollectionParallelStream() {
		val String[] expected = #["foo", null, "bar", ""]
		val Iterable<String> iterable = Arrays.asList(expected)
		val result = iterable.parallelStream.toArray
		assertArrayEquals(expected, result)
	}
	
	@Test def iterableEmptyIterableParallelStream() {
		val Iterable<String> iterable = [#[].iterator]
		val result = iterable.parallelStream.toArray
		assertEquals(0, result.length)
	}

	@Test def iterableIterableParallelStream() {
		val String[] expected = #["foo", null, "bar", ""]
		val Iterable<String> iterable = [expected.iterator]
		val result = iterable.parallelStream.toArray
		assertArrayEquals(expected, result)
	}

}
