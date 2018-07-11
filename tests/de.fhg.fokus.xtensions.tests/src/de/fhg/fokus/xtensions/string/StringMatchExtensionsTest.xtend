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
package de.fhg.fokus.xtensions.string

import static extension de.fhg.fokus.xtensions.string.StringMatchExtensions.*
import org.junit.Test
import static org.junit.Assert.*
import java.util.Iterator
import org.hamcrest.CustomTypeSafeMatcher
import java.util.Objects
import org.hamcrest.Description
import de.fhg.fokus.xtensions.Util
import java.util.NoSuchElementException
import java.util.regex.Pattern

class StringMatchExtensionsTest {

	@Test def void testTwoSubsequentMatches() {
		val iter = "abab".matchIt("ab")
		val String[] expected = #["ab", "ab"]
		assertThat(iter, provides(expected))
	}
	
	@Test def void testOneMatch() {
		val iter = "aaa".matchIt("aa")
		val String[] expected = #["aa"]
		assertThat(iter, provides(expected))
	}
	
	@Test def void testOneMatchInMiddle() {
		val iter = "baba".matchIt("ab")
		val String[] expected = #["ab"]
		assertThat(iter, provides(expected))
	}
	
	@Test def void testNoMatch() {
		val iter = "baba".matchIt("cc")
		val String[] expected = #[]
		assertThat(iter, provides(expected))
	}
	
	@Test def void testMatchComplete() {
		val iter = "abab".matchIt("abab")
		val String[] expected = #["abab"]
		assertThat(iter, provides(expected))
	}
	
	@Test def void testMatchResultItEmpty() {
		val iter = "".matchResultIt("\\s")
		assertFalse(iter.hasNext)
		Util.expectException(NoSuchElementException) [
			iter.next
		]
	}
	
	@Test def void testMatchResultItNoMatch() {
		val iter = "azcnw".matchResultIt("bc")
		assertFalse(iter.hasNext)
		Util.expectException(NoSuchElementException) [
			iter.next
		]
	}
	
	@Test def void testMatchResultItMatches() {
		val iter = "azfobarcesfoobeerOOfooobaaarnw".matchResultIt("(fo*o)(ba*ar)?")
		assertTrue(iter.hasNext)
		val firstMatch = iter.next
		assertEquals(2, firstMatch.groupCount)
		assertEquals("fo", firstMatch.group(1))
		assertEquals("bar", firstMatch.group(2))
		assertTrue(iter.hasNext)
		val secondMatch = iter.next
		assertEquals(2, secondMatch.groupCount)
		assertEquals("foo", secondMatch.group(1))
		assertNull(secondMatch.group(2))
		assertTrue(iter.hasNext)
		val thirdMatch = iter.next
		assertEquals(2, thirdMatch.groupCount)
		assertEquals("fooo", thirdMatch.group(1))
		assertEquals("baaar", thirdMatch.group(2))
		assertFalse(iter.hasNext)
		Util.expectException(NoSuchElementException) [
			iter.next
		]
	}
	
	@Test def void testMatchResultItPatternEmpty() {
		val pattern = Pattern.compile("\\s")
		val iter = "".matchResultIt(pattern)
		assertFalse(iter.hasNext)
		Util.expectException(NoSuchElementException) [
			iter.next
		]
	}
	
	@Test def void testMatchResultItPatternNoMatch() {
		val pattern = Pattern.compile("bc")
		val iter = "azcnw".matchResultIt(pattern)
		assertFalse(iter.hasNext)
		Util.expectException(NoSuchElementException) [
			iter.next
		]
	}
	
	@Test def void testMatchResultItPatternMatches() {
		val pattern = Pattern.compile("(fo*o)(ba*ar)?")
		val iter = "azfobarcesfoobeerOOfooobaaarnw".matchResultIt(pattern)
		assertTrue(iter.hasNext)
		val firstMatch = iter.next
		assertEquals(2, firstMatch.groupCount)
		assertEquals("fo", firstMatch.group(1))
		assertEquals("bar", firstMatch.group(2))
		assertTrue(iter.hasNext)
		val secondMatch = iter.next
		assertEquals(2, secondMatch.groupCount)
		assertEquals("foo", secondMatch.group(1))
		assertNull(secondMatch.group(2))
		assertTrue(iter.hasNext)
		val thirdMatch = iter.next
		assertEquals(2, thirdMatch.groupCount)
		assertEquals("fooo", thirdMatch.group(1))
		assertEquals("baaar", thirdMatch.group(2))
		assertFalse(iter.hasNext)
		Util.expectException(NoSuchElementException) [
			iter.next
		]
	}

	private static def <T> provides(T[] content, String description) {
		new IteratorContentMatcher(description, content)
	}
	
	private static def <T> provides(T[] content) {
		new IteratorContentMatcher("Elements provided by iterator", content)
	}

	private static class IteratorContentMatcher<T> extends CustomTypeSafeMatcher<Iterator<T>> {

		val T[] content

		new(String description, T[] content) {
			super(description)
			this.content = content
		}

		override protected matchesSafely(Iterator<T> iter) {
			for(i : (0..<content.length)) {
				if(!iter.hasNext) {
					return false
				}
				if(!Objects.equals(content.get(i), iter.next)) {
					return false
				}
			}
			Util.expectException(NoSuchElementException) [
				iter.next
			]
			iter.hasNext == false;
		}


		override protected describeMismatchSafely(Iterator<T> item, Description mismatchDescription) {
			super.describeMismatchSafely(item, mismatchDescription)
			mismatchDescription.appendText("Either too short or has non matching values");
		}
		
	}

}