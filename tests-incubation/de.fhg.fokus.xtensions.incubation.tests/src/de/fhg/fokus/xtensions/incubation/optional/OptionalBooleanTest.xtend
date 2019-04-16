package de.fhg.fokus.xtensions.incubation.optional

import static org.junit.Assert.*
import org.junit.Test
import de.fhg.fokus.xtensions.incubation.optional.OptionalBoolean
import de.fhg.fokus.xtensions.incubation.optional.OptionalBoolean.TrueOptional
import de.fhg.fokus.xtensions.incubation.optional.OptionalBoolean.FalseOptional
import de.fhg.fokus.xtensions.incubation.optional.OptionalBoolean.EmptyOptional
import static extension de.fhg.fokus.xtensions.incubation.optional.OptionalBoolean.asOptional

class OptionalBooleanTest {

	////////////////
	// asOptional //
	////////////////

	@Test
	def void testAsOptionalEmpty() {
		val o = null.asOptional
		assertNotNull(o)
		o.assertInstanceOf(EmptyOptional)
	}

	@Test
	def void testAsOptionalTrue() {
		val o = true.asOptional
		assertNotNull(o)
		o.assertInstanceOf(TrueOptional)
	}

	@Test
	def void testAsOptionalFalse() {
		val o = false.asOptional
		assertNotNull(o)
		o.assertInstanceOf(FalseOptional)
	}

	////////////////
	// ofNullable //
	////////////////

	@Test
	def void testOfNullableEmpty() {
		val o = OptionalBoolean.ofNullable(null)
		assertNotNull(o)
		o.assertInstanceOf(EmptyOptional)
	}

	@Test
	def void testOfNullableTrue() {
		val o = OptionalBoolean.ofNullable(true)
		assertNotNull(o)
		o.assertInstanceOf(TrueOptional)
	}

	@Test
	def void testOfNullableFalse() {
		val o = OptionalBoolean.ofNullable(false)
		assertNotNull(o)
		o.assertInstanceOf(FalseOptional)
	}
	
	///////////
	// empty //
	///////////
	
	@Test
	def void testEmpty() {
		val o = OptionalBoolean.empty
		o.assertInstanceOf(EmptyOptional)
	}

	////////////
	// ofTrue //
	////////////
	
	@Test
	def void testOfTrue() {
		val o = OptionalBoolean.ofTrue
		o.assertInstanceOf(TrueOptional)
	}

	////////////
	// ofFalse //
	////////////
	
	@Test
	def void testOfFalse() {
		val o = OptionalBoolean.ofFalse
		o.assertInstanceOf(FalseOptional)
	}

	////////
	// of //
	////////

	@Test
	def void testOfWithTrue() {
		val o = OptionalBoolean.of(true)
		o.assertInstanceOf(TrueOptional)
	}
	
	@Test
	def void testOfWithFalse() {
		val o = OptionalBoolean.of(false)
		o.assertInstanceOf(FalseOptional)
	}
	
	///////////////
	// isPresent //
	///////////////
	
	@Test
	def void testEmptyIsPresent() {
		val o = OptionalBoolean.empty
		assertFalse(o.isPresent)
	}

	@Test
	def void testTrueIsPresent() {
		val o = OptionalBoolean.ofTrue
		assertTrue(o.isPresent)
	}

	@Test
	def void testFalseIsPresent() {
		val o = OptionalBoolean.ofFalse
		assertTrue(o.isPresent)
	}

	/////////////
	// isEmpty //
	/////////////
	
	@Test
	def void testEmptyIsEmpty() {
		val o = OptionalBoolean.empty
		assertTrue(o.isEmpty)
	}

	@Test
	def void testTrueIsEmpty() {
		val o = OptionalBoolean.ofTrue
		assertFalse(o.isEmpty)
	}

	@Test
	def void testFalseIsEmpty() {
		val o = OptionalBoolean.ofFalse
		assertFalse(o.isEmpty)
	}

	////////////
	// isTrue //
	////////////
	
	@Test
	def void testEmptyIsTrue() {
		val o = OptionalBoolean.empty
		assertFalse(o.isTrue)
	}

	@Test
	def void testTrueIsTrue() {
		val o = OptionalBoolean.ofTrue
		assertTrue(o.isTrue)
	}

	@Test
	def void testFalseIsTrue() {
		val o = OptionalBoolean.ofFalse
		assertFalse(o.isTrue)
	}

	//////////
	// util //
	//////////	
	
	private def assertInstanceOf(Object o, Class<?> clazz) {
		if(!clazz.isInstance(o)) {
			fail('''Object expected to be instance of «clazz.name» but is of type «o.class.name»''')
		}
	}

}