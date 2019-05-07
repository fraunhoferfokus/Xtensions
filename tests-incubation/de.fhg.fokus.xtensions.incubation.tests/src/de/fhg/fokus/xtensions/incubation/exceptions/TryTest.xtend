package de.fhg.fokus.xtensions.incubation.exceptions

import static extension org.junit.Assert.*
import de.fhg.fokus.xtensions.incubation.exceptions.Try
import static de.fhg.fokus.xtensions.incubation.exceptions.Try.*
import org.junit.Test
import static extension de.fhg.fokus.xtensions.incubation.Util.*

class TryTest {

	@Test
	def void testCompletedElement() {
		val expected = new Object
		val result = Try.completed(expected)
		val succ = result.assertIsInstanceOf(Try.Success)
		expected.assertSame(succ.get)
	}

	@Test
	def void testCompletedNull() {
		val result = Try.completed(null)
		result.assertIsInstanceOf(Try.Empty)
	}

	@Test(expected = NullPointerException)
	def void testCompletedSuccessfullyNull() {
		Try.completedSuccessfully(null)
	}

	@Test
	def void testCompletedSuccessfully() {
		val expected = new Object
		val result = Try.completedSuccessfully(expected)
		val succ = result.assertIsInstanceOf(Try.Success)
		expected.assertSame(succ.get)
	}

	@Test
	def void testCompletedEmpty() {
		Try.completedEmpty.assertIsInstanceOf(Try.Empty)
	}

	@Test(expected = NullPointerException)
	def void testCompletedExceptionallyNull() {
		Try.completedExceptionally(null)
	}

	@Test
	def void testCompletedExceptionally() {
		val e = new ArrayIndexOutOfBoundsException
		val result = Try.completedExceptionally(e)
		val failure = result.assertIsInstanceOf(Try.Failure)
		failure.get.assertSame(e)
	}

	@Test
	def void testDoTryMethodNull() {
		Try.doTry(null)
	}

	@Test
	def void testDoTryMethodProvidesNull() {
		val result = Try.doTry[null]
		result.assertIsInstanceOf(Try.Empty)
	}

	@Test
	def void testDoTryMethodProvidesElement() {
		val expected = new Object
		val result = Try.doTry[expected]
		val succ = result.assertIsInstanceOf(Try.Success)
		succ.get.assertSame(expected)
	}

	@Test
	def void testDoTryMethodThrows() {
		val expected = new IllegalStateException
		val result = Try.doTry[
			throw expected
		]
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertSame(expected)
	}
}