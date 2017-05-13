package de.fhg.fokus.xtensions.stream

import org.junit.Test

import static org.junit.Assert.*

import static extension de.fhg.fokus.xtensions.string.StringSplitExtensions.*
import de.fhg.fokus.xtensions.Util
import java.util.NoSuchElementException

class SplitStringExtensionsTest {

	// //////////////////////////////////////////
	// Regular split, removing trailing empty //
	// //////////////////////////////////////////
	@Test def void testSplitEmpty() {
		checkSplit("", ";")
	}
	@Test def void testSplitEmptyWithEmpty() {
		checkSplit("", "")
	}

	@Test def void testSplitWithLeadingZeroSizedMatch() {
		checkSplit("ab", "")
	}

	@Test def void testSplitToEmpty() {
		checkSplit(";", ";")
	}

	@Test def void testSplitToEmpty2() {
		checkSplit(";;", ";")
	}

	@Test def void testSplitIntoTwo() {
		checkSplit("foo;bar", ";")
	}

	@Test def void testSplitIntoThreeWithEncapsulatedEmpty() {
		checkSplit("foo;;bar", ";")
	}

	@Test def void testSplitIntoTwoWithSkiptedEmptyEnd() {
		checkSplit("foo;bar;;", ";")
	}

	@Test def void testSplitIntoTwoWithSkiptedEmptyStart() {
		checkSplit(";;foo;bar", ";")
	}

	@Test def void testSplitNoSplit() {
		checkSplit("foo.bar", ";")
	}

	// /////////////
	// Unlimited //
	// /////////////
	@Test def void testSplitEmptyUnlimited() {
		checkSplitUnlimited("", ";")
	}

	@Test def void testSplitWithLeadingZeroSizedMatchUnlimited() {
		checkSplitUnlimited("ab", "")
	}

	@Test def void testSplitToEmptyUnlimited() {
		checkSplitUnlimited(";", ";")
	}

	@Test def void testSplitToEmpty2Unlimited() {
		checkSplitUnlimited(";;", ";")
	}

	@Test def void testSplitIntoTwoUnlimited() {
		checkSplitUnlimited("foo;bar", ";")
	}

	@Test def void testSplitIntoThreeWithEncapsulatedEmptyUnlimited() {
		checkSplitUnlimited("foo;;bar", ";")
	}

	@Test def void testSplitIntoTwoWithSkiptedEmptyEndUnlimited() {
		checkSplitUnlimited("foo;bar;;", ";")
	}

	@Test def void testSplitIntoTwoWithSkiptedEmptyStartUnlimited() {
		checkSplitUnlimited(";;foo;bar", ";")
	}

	@Test def void testSplitNoSplitUnlimited() {
		checkSplitUnlimited("foo.bar", ";")
	}
	
	@Test def void testSplitEmptyWithEmptyUnlimited() {
		checkSplitUnlimited("", "")
	}

	// ///////////
	// Limited //
	// ///////////
	@Test def void testSplitWithLeadingZeroSizedMatchLimit1() {
		checkSplitLimited("ab", "", 1)
	}

	@Test def void testSplitWithLeadingZeroSizedMatchLimit2() {
		checkSplitLimited("ab", "", 2)
	}

	@Test def void testSplitIntoThreeLimitTwo() {
		checkSplitLimited("foo:bar:baz", ":", 2)
	}

	@Test def void testSplitIntoThreeLimitThree() {
		checkSplitLimited("foo:bar:baz", ":", 3)
	}

	@Test def void testSplitIntoThreeLimitFour() {
		checkSplitLimited("foo:bar:baz", ":", 3)
	}

	// //////////////////
	// Helper Methods //
	// //////////////////
	private def void checkSplit(String toSplit, String pattern) {
		val split = toSplit.split(pattern)
		val iter = toSplit.splitIt(pattern)
		for (int i : ( 0 ..< split.length)) {
			val String msg = '''iterator stopped at iteration «i», but should have «split.length» iterations''';
			assertTrue(msg, iter.hasNext)
			val expected = split.get(i)
			val actual = iter.next
			assertEquals(expected, actual)
		}
		val msg = "iterator has more entries than String.split"
		assertFalse(msg, iter.hasNext)
		Util.expectException(NoSuchElementException) [
			iter.next
		]
	}

	private def void checkSplitLimited(String toSplit, String pattern, int limit) {
		val split = toSplit.split(pattern, limit)
		val iter = toSplit.splitIt(pattern, limit)
		for (int i : ( 0 ..< split.length)) {
			val String msg = '''iterator stopped at iteration «i», but should have «split.length» iterations''';
			assertTrue(msg, iter.hasNext)
			val expected = split.get(i)
			val actual = iter.next
			assertEquals(expected, actual)
		}
		val msg = "iterator has more entries than String.split"
		assertFalse(msg, iter.hasNext)
		Util.expectException(NoSuchElementException) [
			iter.next
		]
	}

	private def void checkSplitUnlimited(String toSplit, String pattern) {
		val split = toSplit.split(pattern, -2)
		val iter = toSplit.splitIt(pattern, -2)
		for (int i : ( 0 ..< split.length)) {
			val String msg = '''iterator stopped at iteration «i», but should have «split.length» iterations''';
			assertTrue(msg, iter.hasNext)
			val expected = split.get(i)
			val actual = iter.next
			assertEquals(expected, actual)
		}
		val msg = "iterator has more entries than String.split"
		assertFalse(msg, iter.hasNext)
		Util.expectException(NoSuchElementException) [
			iter.next
		]
	}
}