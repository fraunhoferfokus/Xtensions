package de.fhg.fokus.xtensions.stream

import org.junit.Test
import java.util.stream.Stream
import static extension de.fhg.fokus.xtensions.stream.StreamExtensions.*
import static org.junit.Assert.*

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
	
	
	
	//////////////////
	// combinations //
	//////////////////
}