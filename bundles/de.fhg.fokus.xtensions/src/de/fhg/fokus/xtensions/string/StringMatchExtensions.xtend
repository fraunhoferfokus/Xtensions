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

import java.util.Iterator
import java.util.regex.Pattern
import java.util.regex.Matcher
import java.util.regex.MatchResult
import java.util.NoSuchElementException
import java.util.Objects

/**
 * This class provoides static functions to create iterators that lazily 
 * provide all matches of given regular expressions on an input CharSequence (e.g. String).
 * This class is not intended to be instantiated.
 */
final class StringMatchExtensions {
	
	private new() {
		throw new IllegalStateException('''«StringMatchExtensions» is not intended to be instantiated''')
	}
	
	/**
	 * Iterator that allows iteration over all matched substrings of a given regular expression
	 * in an input CharSequence.
	 */
	private static class MatchStringIterator implements Iterator<String> {

		private Matcher matcher;
		private boolean hasNext
		private CharSequence input

		new(CharSequence toMatch, Pattern pattern) {
			input = toMatch
			matcher = pattern.matcher(toMatch)
			hasNext = matcher.find
		}

		override hasNext() {
			hasNext
		}

		override next() {
			if(!hasNext) {
				throw new NoSuchElementException
			}
			val res = input.subSequence(matcher.start, matcher.end)
			hasNext = matcher.find
			res.toString
		}
	}
	
	/**
	 * Iterator over all MatchResults of a regular expression in an input char sequence.
	 * The returned matches do not change states when another match is pulled from the iterator.
	 */
	private static class MatchResultIterator implements Iterator<MatchResult> {
		
		private Matcher nextMatcher
		private boolean hasNext
		private CharSequence input
		private Pattern pattern
		
		new(CharSequence toMatch, Pattern p) {
			pattern = p
			val m = p.matcher(toMatch)
			nextMatcher = m
			hasNext = m.find
			input = toMatch
		}
		
		override hasNext() {
			hasNext
		}
		
		override next() {
			if(!hasNext) {
				throw new NoSuchElementException
			}
			val res = nextMatcher
			val next = pattern.matcher(input)
			nextMatcher = next
			hasNext = next.find(res.end)
			res
		}
		
	}

	/**
	 * This function creates an iterator, that lazily finds matching strings according
	 * to the given {@code pattern} sequentially in the input CharSequence.
	 * This way of iterating over matches does not provide access to matching groups,
	 * see {@link StringMatchExtensions#matchResultIt(CharSequence, Pattern) matchResultIt}
	 * for full match access, including groups.
	 * @see StringMatchExtensions#matchResultIt(CharSequence, Pattern)
	 */
	public static def Iterator<String> matchIt(CharSequence toMatch, Pattern pattern) {
		Objects.requireNonNull(toMatch)
		Objects.requireNonNull(pattern)
		new MatchStringIterator(toMatch, pattern)
	}

	/**
	 * This function creates an iterator, that lazily finds matching strings according
	 * to the given {@code pattern} regular expression sequentially in the input CharSequence.
	 * This way of iterating over matches does not provide access to matching groups,
	 * see {@link StringMatchExtensions#matchResultIt(CharSequence, String) matchResultIt}
	 * for full match access, including groups.
	 * @see StringMatchExtensions#matchResultIt(CharSequence, String)
	 */
	public static def Iterator<String> matchIt(CharSequence toMatch, String pattern) {
		Objects.requireNonNull(toMatch)
		Objects.requireNonNull(pattern)
		matchIt(toMatch, Pattern.compile(pattern))
	}
	
	/**
	 * This function creates an iterator, that lazily finds MatchResults according
	 * to the given {@code pattern} regular expression sequentially in the input CharSequence.
	 * The returned MatchResults will not change their state when another result is pulled 
	 * from the iterator.
	 */
	public static def Iterator<MatchResult> matchResultIt(CharSequence toMatch, Pattern pattern) {
		new MatchResultIterator(toMatch, pattern)
	}
	
	/**
	 * This function creates an iterator, that lazily finds MatchResults according
	 * to the given {@code pattern} regular expression sequentially in the input CharSequence.
	 * The returned MatchResults will not change their state when another result is pulled 
	 * from the iterator.
	 */
	public static def Iterator<MatchResult> matchResultIt(CharSequence toMatch, String pattern) {
		toMatch.matchResultIt(Pattern.compile(pattern))
	}
	
	// TODO: matchStream (see StringStreamExtensions), matchResultStream
}