package de.fhg.fokus.xtensions.string

import static extension de.fhg.fokus.xtensions.string.StringMatchExtensions.*
import org.junit.Test
import static org.junit.Assert.*
import java.util.Iterator
import org.hamcrest.CustomTypeSafeMatcher
import java.util.Objects
import org.hamcrest.Description

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

	private static def <T> provides(T[] content, String description) {
		new IteratorContentMatcher(description, content)
	}
	
	private static def <T> provides(T[] content) {
		new IteratorContentMatcher("Elements provided by iterator", content)
	}

	private static class IteratorContentMatcher<T> extends CustomTypeSafeMatcher<Iterator<T>> {

		private val T[] content

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
			iter.hasNext == false;
		}


		override protected describeMismatchSafely(Iterator<T> item, Description mismatchDescription) {
			super.describeMismatchSafely(item, mismatchDescription)
			mismatchDescription.appendText("Either too short or has non matching values");
		}
		
	}

}