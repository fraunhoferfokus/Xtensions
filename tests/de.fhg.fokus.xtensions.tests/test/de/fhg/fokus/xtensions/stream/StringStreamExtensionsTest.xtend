/*******************************************************************************
 * Copyright (c) 2017 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.stream

import static extension de.fhg.fokus.xtensions.stream.StringStreamExtensions.*
import static org.junit.Assert.*
import org.junit.Test
import java.util.stream.Stream
import java.util.regex.Pattern

class StringStreamExtensionsTest {

	// ////////
	// join //
	// ////////
	@Test def void testJoinEmpty() {
		val result = Stream.<String>empty.join
		assertEquals("", result)
	}

	@Test def void testJoin() {
		val result = Stream.of("foo", "bar", "baz").join
		assertEquals("foobarbaz", result)
	}

	// ////////////////////
	// join (delimiter) //
	// ////////////////////
	@Test def void testJoinDelimiterEmpty() {
		val result = Stream.<String>empty.join(',')
		assertEquals("", result)
	}

	@Test def void testJoinDelimiter() {
		val result = Stream.of("foo", "bar", "baz").join(',')
		assertEquals("foo,bar,baz", result)
	}

	// ////////////////////////////////////
	// join (delimiter, prefix, suffix) //
	// ////////////////////////////////////
	@Test def void testJoinDelimiterPrefixSuffixEmpty() {
		val result = Stream.<String>empty.join(',', '`', '´')
		assertEquals("`´", result)
	}

	@Test def void testJoinDelimiterPrefixSuffix() {
		val result = Stream.of("foo", "bar", "baz").join(',', '`', '´')
		assertEquals("`foo,bar,baz´", result)
	}
	
	///////////////
	// flatSplit //
	///////////////
	
	@Test def void testFlatSplitEmpty() {
		val result = Stream.empty.flatSplit("\\s+").toArray
		assertEquals(0, result.length)
	}
	
	@Test def void testFlatSplit() {
		val result = Stream.of("foo bar", "fizz\tbuzz").flatSplit("\\s+").toArray
		assertArrayEquals(#["foo","bar","fizz", "buzz"], result)
	}
	
	@Test def void testFlatSplitNoMatch() {
		val String[] expected = #["bla foo bar", "hui buh"]
		val result = Stream.of(expected).flatSplit("w").toArray
		assertArrayEquals(expected, result)
	}
	
	/////////////////////////
	// flatSplit (pattern) //
	/////////////////////////
	
	@Test def void testFlatSplitPatternEmpty() {
		val pattern = Pattern.compile("\\s+")
		val result = Stream.empty.flatSplit(pattern).toArray
		assertEquals(0, result.length)
	}
	
	@Test def void testFlatSplitPattern() {
		val pattern = Pattern.compile("\\s+")
		val result = Stream.of("foo bar", "fizz\tbuzz").flatSplit(pattern).toArray
		assertArrayEquals(#["foo","bar","fizz", "buzz"], result)
	}
	
	@Test def void testFlatSplitPatternNoMatch() {
		val String[] expected = #["bla foo bar", "hui buh"]
		val pattern = Pattern.compile("w")
		val result = Stream.of(expected).flatSplit(pattern).toArray
		assertArrayEquals(expected, result)
	}
	
	///////////////////////
	// flatSplit (limit) //
	///////////////////////
	
	@Test def void testFlatSplitLimitEmpty() {
		val result = Stream.<String>empty.flatSplit("\\s+", 2).toArray
		assertEquals(0, result.length)
	}
	
	@Test def void testFlatSplitLimit() {
		val result = Stream.of("foo bar baz", "hui ", "", "boo ya").flatSplit("\\s+", 2).toArray
		val String[] expected = #["foo", "bar baz", "hui", "", "", "boo", "ya"]
		assertArrayEquals(expected, result)
	}
	
	@Test def void testFlatSplitLimitZero() {
		// omitting trailing empty string matches
		val result = Stream.of("foo bar baz", "hui", "", "boo  ya \t ").flatSplit("\\s", 0).toArray
		val String[] expected = #["foo", "bar","baz", "hui", "boo", "", "ya"]
		assertArrayEquals(expected, result)
	}
	
	@Test def void testFlatSplitLimitNegative() {
		val result = Stream.of("foo bar baz", "hui", "", "boo  ya \t ").flatSplit("\\s", -1).toArray
		val String[] expected = #["foo", "bar","baz", "hui", "", "boo", "", "ya", "", "", ""]
		assertArrayEquals(expected, result)
	}
	
	////////////////////////////////
	// flatSplit (pattern, limit) //
	////////////////////////////////
	
	@Test def void testFlatSplitLimitPatternEmpty() {
		val pattern = Pattern.compile("\\s+")
		val result = Stream.<String>empty.flatSplit(pattern, 2).toArray
		assertEquals(0, result.length)
	}
	
	@Test def void testFlatSplitLimitPatter() {
		val pattern = Pattern.compile("\\s+")
		val result = Stream.of("foo bar baz", "hui ", "", "boo ya").flatSplit(pattern, 2).toArray
		val String[] expected = #["foo", "bar baz", "hui", "", "", "boo", "ya"]
		assertArrayEquals(expected, result)
	}
	
	@Test def void testFlatSplitLimitPatterZero() {
		// omitting trailing empty string matches
		val pattern = Pattern.compile("\\s")
		val result = Stream.of("foo bar baz", "hui", "", "boo  ya \t ").flatSplit(pattern, 0).toArray
		val String[] expected = #["foo", "bar","baz", "hui", "boo", "", "ya"]
		assertArrayEquals(expected, result)
	}
	
	@Test def void testFlatSplitLimitPatterNegative() {
		val pattern = Pattern.compile("\\s")
		val result = Stream.of("foo bar baz", "hui", "", "boo  ya \t ").flatSplit(pattern, -1).toArray
		val String[] expected = #["foo", "bar","baz", "hui", "", "boo", "", "ya", "", "", ""]
		assertArrayEquals(expected, result)
	}
	
	/////////////////
	// flatMatches //
	/////////////////
	
	@Test def void flatMatchesEmpty() {
		val result = Stream.<String>empty.flatMatches("\\s").toArray
		assertEquals(0, result.length)
	}
	
	@Test def void flatMatchesNoMatch() {
		val stream = Stream.of("bar baz", "hui", "buh")
		val result = stream.flatMatches("fo*o").toArray
		assertArrayEquals(#[], result)
	}
	
	@Test def void flatMatches() {
		val stream = Stream.of("bar baz", "fo", "", "boo foooo loo", "kafoom")
		val result = stream.flatMatches("fo*o").toArray
		val String[] expected = #["fo", "foooo", "foo"]
		assertArrayEquals(expected, result)
	}
	
	///////////////////////////
	// flatMatches (pattern) //
	///////////////////////////
	
	@Test def void flatMatchesPatternEmpty() {
		val pattern = Pattern.compile("\\s")
		val result = Stream.<String>empty.flatMatches(pattern).toArray
		assertEquals(0, result.length)
	}
	
	@Test def void flatMatchesPatternNoMatch() {
		val stream = Stream.of("bar baz", "hui", "buh")
		val pattern = Pattern.compile("fo*o")
		val result = stream.flatMatches(pattern).toArray
		assertArrayEquals(#[], result)
	}
	
	@Test def void flatMatchesPattern() {
		val stream = Stream.of("bar baz", "fo", "", "boo foooo loo", "kafoom")
		val pattern = Pattern.compile("fo*o")
		val result = stream.flatMatches(pattern).toArray
		val String[] expected = #["fo", "foooo", "foo"]
		assertArrayEquals(expected, result)
	}
	
	//////////////
	// matching //
	//////////////
	
	@Test def void testMatchingEmpty() {
		val result = Stream.<String>empty.matching("\\s").toArray
		assertEquals(0, result.length)
	}
	
	@Test def void testMatchingNoMach() {
		val result = Stream.of("foo", "bar", "kaboom").matching("\\s").toArray
		assertEquals(0, result.length)
	}
	
	@Test def void testMatching() {
		val result = Stream.of("bar", "fo", "shoo", "fooooo", "kafoom").matching("fo*o").toArray
		val String[] expected = #["fo", "fooooo"]
		assertArrayEquals(expected, result)
	}
	
	/////////////////////////
	// matching (patterns) //
	/////////////////////////
	
	@Test def void testMatchingPatternEmpty() {
		val pattern = Pattern.compile("\\s")
		val result = Stream.<String>empty.matching(pattern).toArray
		assertEquals(0, result.length)
	}
	
	@Test def void testMatchingPatternNoMach() {
		val pattern = Pattern.compile("\\s")
		val result = Stream.of("foo", "bar", "kaboom").matching(pattern).toArray
		assertEquals(0, result.length)
	}
	
	@Test def void testMatchingPattern() {
		val pattern = Pattern.compile("fo*o")
		val result = Stream.of("bar", "fo", "shoo", "fooooo", "kafoom").matching(pattern).toArray
		val String[] expected = #["fo", "fooooo"]
		assertArrayEquals(expected, result)
	}
}
