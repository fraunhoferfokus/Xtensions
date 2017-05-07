package de.fhg.fokus.xtensions.pair

import org.junit.Test
import static org.junit.Assert.*
import static extension de.fhg.fokus.xtensions.pair.PairExtensions.*
import java.util.concurrent.atomic.AtomicBoolean

class PairExtensionTests {
	
	@Test def void testConsume() {
		val expectedKey = "foo"
		val expectedVal = 3
		val tst = expectedKey -> expectedVal
		val called = new AtomicBoolean(false)
		tst.consume[k, v|
			assertEquals(expectedKey, k)
			assertEquals(expectedVal, v)
			called.set(true)
		]
		assertTrue(called.get)
	}
	
	@Test def void testConsumeKeyNull() {
		val String expectedKey = null
		val expectedVal = 3
		val tst = expectedKey -> expectedVal
		val called = new AtomicBoolean(false)
		tst.consume[k, v|
			assertEquals(expectedKey, k)
			assertEquals(expectedVal, v)
			called.set(true)
		]
		assertTrue(called.get)
	}
	
	@Test def void testConsumeValueNull() {
		val expectedKey = "foo"
		val Integer expectedVal = null
		val tst = expectedKey -> expectedVal
		val called = new AtomicBoolean(false)
		tst.consume[k, v|
			assertEquals(expectedKey, k)
			assertEquals(expectedVal, v)
			called.set(true)
		]
		assertTrue(called.get)
	}
}