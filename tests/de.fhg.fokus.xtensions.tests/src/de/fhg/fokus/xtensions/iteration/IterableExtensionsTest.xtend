package de.fhg.fokus.xtensions.iteration

import org.junit.Test
import static extension de.fhg.fokus.xtensions.iteration.IterableExtensions.*
import static org.junit.Assert.*
import static java.util.stream.Collectors.*

class IterableExtensionsTest {

	@Test def testCollect() {
		val joined = #["foo", "bar", "baz"].collect(joining(",", "'", "'"))
		assertEquals("'foo,bar,baz'", joined)
		
		val joinedEmpty = #[].collect(joining(",", "'", "'"))
		assertEquals("''", joinedEmpty)
	}

}
