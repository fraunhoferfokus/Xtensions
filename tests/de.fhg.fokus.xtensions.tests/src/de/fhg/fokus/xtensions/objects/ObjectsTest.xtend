package de.fhg.fokus.xtensions.objects

import static extension de.fhg.fokus.xtensions.objects.Objects.*
import org.junit.Test
import org.junit.Assert
import static extension org.junit.Assert.*

class ObjectsTest {
	
	////////////
	// asType //
	////////////

	@Test
	def void testAsTypeIsSubTypeNotNull() {
		"foo".asType(CharSequence).assertNotNull
	}

	@Test
	def void testAsTypeIsSubTypeReturnsSame() {
		val expected = "foo"
		val actual = expected.asType(CharSequence)
		expected.assertSame(actual)
	}

	@Test
	def void testAsTypeIsTypeNotNull() {
		"foo".asType(String).assertNotNull
	}

	@Test
	def void testAsTypeIsTypeReturnsSame() {
		val expected = "foo"
		val actual = expected.asType(String)
		expected.assertSame(actual)
	}

	@Test
	def void testAsTypeIsNotType() {
		"foo".asType(Integer).assertNull
	}

	///////////////
	// ifNotNull //
	///////////////

	@Test
	def void testIfNotNullOnNull() {
		extension val test = new Object {
			var result = true
		}
		null.ifNotNull[result = false]
		assertTrue(result)
	}

	@Test
	def void testIfNotNullNotNull() {
		extension val test = new Object {
			var actual = null
		}
		val expected = new Object
		expected.ifNotNull[actual = it]
		expected.assertSame(actual)
	}
	
	///////////////////////
	// recoverNull(T, T) //
	///////////////////////

	@Test
	def void testRecoverNullObjNotNull() {
		val expected = "foo"
		val actual = expected.recoverNull("other")
		expected.assertSame(actual)
	}

	@Test
	def void testRecoverNullObjNull() {
		val expected = "foo"
		val actual = null.recoverNull(expected)
		expected.assertSame(actual)
	}

	@Test(expected = NullPointerException)
	def void testRecoverNullObjNullRecoveryNull() {
		val String context = null
		val String recovery = null
		context.recoverNull(recovery)
	}

	/////////////////////////
	// recoverNull(T, =>T) //
	/////////////////////////

	@Test
	def void testRecoverNullRecoveryObjNotNull() {
		val expected = "foo"
		val actual = expected.recoverNull["other"]
		expected.assertSame(actual)
	}

	@Test
	def void testRecoverNullRecoveryObjNull() {
		val expected = "foo"
		val actual = null.recoverNull[expected]
		expected.assertSame(actual)
	}

	@Test(expected = NullPointerException)
	def void testRecoverNullRecoveryNull() {
		val =>String recovery = null
		"foo".recoverNull(recovery)
	}

	@Test(expected = NullPointerException)
	def void testRecoverNullRecoveryObjNullRecoveryNull() {
		val String context = null
		val =>String recovery = [null]
		context.recoverNull(recovery)
	}
	

	//////////////////////////////
	// requireNonNullElse​(T, T) //
	//////////////////////////////
 
	@Test
	def void testRequireNonNullElseObjNotNull() {
		val expected = "foo"
		val actual = expected.requireNonNullElse​("other")
		expected.assertSame(actual)
	}

	@Test
	def void testRequireNonNullElseObjNull() {
		val expected = "foo"
		val actual = null.requireNonNullElse​(expected)
		expected.assertSame(actual)
	}

	@Test(expected = NullPointerException)
	def void testRequireNonNullElseObjNullRecoveryNull() {
		val String context = null
		val String recovery = null
		context.requireNonNullElse​(recovery)
	}

	///////////////////////////////////////////
	// requireNonNullElseGet​(T, Supplier<T>) //
	///////////////////////////////////////////

@Test
	def void testRequireNonNullElseGetRecoveryObjNotNull() {
		val expected = "foo"
		val actual = expected.requireNonNullElseGet​["other"]
		expected.assertSame(actual)
	}

	@Test
	def void testRequireNonNullElseGetRecoveryObjNull() {
		val expected = "foo"
		val actual = null.requireNonNullElseGet​[expected]
		expected.assertSame(actual)
	}

	@Test(expected = NullPointerException)
	def void testRequireNonNullElseGetRecoveryNull() {
		"foo".requireNonNullElseGet​(null)
	}

	@Test(expected = NullPointerException)
	def void testRequireNonNullElseGetRecoveryObjNullRecoveryNull() {
		val String context = null
		val =>String recovery = [null]
		context.requireNonNullElseGet​(recovery)
	}
}