package de.fhg.fokus.xtenders.string

import java.util.regex.Matcher
import java.util.regex.Pattern
import java.util.Iterator
import java.util.NoSuchElementException
import java.util.Objects
import java.util.stream.Stream

/**
 * Utility class holding static extension functions to split strings.
 * This class is not intended to be instantiated.
 */
class StringSplitExtensions {

	private new() {
		throw new IllegalStateException("StringSplitExtensions not intended to be instantiated")
	}

	/**
	 * Iterator simply returning one empty String
	 */
	private static final class EmptyStringIterator implements Iterator<String> {

		private boolean read = false

		override hasNext() {
			!read
		}

		override next() {
			read = true
			""
		}
	}
	
	/**
	 * Iterator class that should behave like a lazy version of 
	 * {@link String#split(String, int)} with a positive integer as second
	 * parameter.
	 */
	private static class LimitedSplitIterator extends UnlimitedSplitIterator {
		private int limit
		private int readCount
		
		new(CharSequence toSplit, Pattern pattern, int limit) {
			super(toSplit, pattern)
			this.readCount = 0
			this.limit = limit
			
			readAndSetNext()
		}
		
		override protected void initializeNext() {
			// we do readAndSetNext in our own constructor
		}
		
		override readAndSetNext() {
			// intercept if last is reached
			readCount++
			if(readCount >= limit) {
				next = readLastPart()
			} else {
				super.readAndSetNext()
			}
		}
		
	}

	/**
	 * Iterator class that should behave like a lazy version of 
	 * {@link String#split(String, int)} with a negative integer as second
	 * parameter.
	 */
	private static class UnlimitedSplitIterator implements Iterator<String> {
		private final Matcher matcher
		protected String next
		private int index
		private CharSequence input

		new(CharSequence toSplit, Pattern pattern) {
			val m = pattern.matcher(toSplit)
			matcher = m
			index = 0
			input = toSplit
			initializeNext()
		}
		
		/**
		 * Called from constructor to read next value 
		 */
		protected def void initializeNext() {
			readAndSetNext()
		}

		def String readNext() {
			while (matcher.find) {
				val start = matcher.start
				val end = matcher.end
				val i = index // buffer to local variable
				if (!(i == 0 && start == 0 && start == end)) {
					var String res = input.subSequence(i, start).toString
					index = end
					return res
				}
			// else: leading empty substring: skip
			// try to find substring in next loop
			}
			// so we didn't find a match.
			readLastPart()
		}

		/**
		 * Reads the last parts of a string to split from the end of the
		 * last match to the end of the string to split
		 */
		protected def readLastPart() {
			// did we ever find a match? if not, return complete input
			if (index == 0) {
				// change index to end, so next time we return null
				index = input.length + 1
				return input.toString
			}

			// do we have a last split token to return?
			if (index <= input.length) {
				// change index to end, so next time we return null
				val res = input.subSequence(index, input.length).toString
				index = input.length + 1
				return res
			} else {
				// we already reached the end the last time
				return null
			}
		}

		protected def void readAndSetNext() {
			next = readNext
		}

		override hasNext() {
			next !== null
		}

		override next() {
			if (next === null) {
				throw new NoSuchElementException
			}
			var String result = next
			readAndSetNext()
			result
		}
	}

	private static final class UnlimitedSplitIteratorNoTrailingEmpty implements Iterator<String> {

		private static final val EMPTY = ""

		private final Matcher matcher
		private String next
		private String firstAfterEmpty
		private int index
		private int upcomingEmptyCount
		private CharSequence input

		new(CharSequence toSplit, Pattern pattern) {
			val m = pattern.matcher(toSplit)
			matcher = m
			index = 0
			input = toSplit
			upcomingEmptyCount = 0
			firstAfterEmpty = null
			readAndSetNext()
		}

		private def String readNext() {
			// did we skip over empty strings?
			if (upcomingEmptyCount > 0) {
				upcomingEmptyCount--;
				// did we return all empty strings now?
				if (upcomingEmptyCount == 0) {
					val res = firstAfterEmpty
					firstAfterEmpty = null
					return res
				} else {
					return EMPTY
				}
			}
			// no empty string we skipped over, go further
			while (matcher.find) {
				val start = matcher.start
				val end = matcher.end
				val i = index // buffer to local variable
				if (!(i == 0 && start == 0 && start == end)) {
					index = end
					val String res = if (i == start) {
						// we have an empty string
						// since we do not want trailing empty results
						// try to skip over the empty results
						skipTrailingEmptyStrings()
					} else {
						// regular result
						input.subSequence(i, start).toString
					}

					return res
				}
			// else: leading empty substring: skip
			// try to find substring in next loop
			}
			// so we didn't find a match.
			return readLastPart()
		}

		private def String readLastPart() {
			// did we ever find a match? if not, return complete input
			if (index == 0) {
				// change index to end, so next time we return null
				index = input.length
				return input.toString
			}

			// do we have a last split token to return?
			// empty last element is skipped
			if (index < input.length) {
				// change index to end, so next time we return null
				val res = input.subSequence(index, input.length).toString
				index = input.length
				return res
			} else {
				// we already reached the end the last time
				return null
			}
		}

		private def String skipTrailingEmptyStrings() {
			// count all subsequent empty strings
			while (matcher.find) {
				val start = matcher.start
				val end = matcher.end
				val i = index
				index = end
				upcomingEmptyCount++
				// do we have a non-empty string left?
				if (i != start) {
					firstAfterEmpty = input.subSequence(i, start).toString
					return EMPTY
				}
			}
			// if we already found last match, try reading the last part
			var after = readLastPart()
			if (after === null) {
				// if there is no last part, 
				upcomingEmptyCount = 0
				return null
			} else {
				upcomingEmptyCount = 1
				firstAfterEmpty = after
				return EMPTY
			}
		}

		private def readAndSetNext() {
			next = readNext
		}

		override hasNext() {
			next !== null
		}

		override next() {
			if (next === null) {
				throw new NoSuchElementException
			}
			var String result = next
			readAndSetNext()
			result
		}

	}

	/**
	 * Creates an iterator that splits the input parameter string {@code toSplit}
	 * at the given regular expression {@code pattern}. The splitting behavior 
	 * is modeled after the rules of {@link String#split(String,int)}, therefore 
	 * the parameter {@code limit} has the same semantics.<br>
	 * The returned Iterator performs the splitting operations as lazy as possible,
	 * so it is is suited well for finding tokens in a string and stop splitting
	 * as soon as a particular element is found. This also reduces memory copying
	 * to unused strings.
	 * @see String#split(String,int)
	 */
	public static def splitIt(String toSplit, String pattern, int limit) {
		toSplit.splitIt(Pattern.compile(pattern), limit)
	}
	
	/**
	 * Creates an iterator that splits the input parameter string {@code toSplit}
	 * at the given regular expression {@code pattern}. The splitting behavior 
	 * is modeled after the rules of {@link Pattern#split(CharSequence,int)}, therefore 
	 * the parameter {@code limit} has the same semantics.<br>
	 * The returned Iterator performs the splitting operations as lazy as possible,
	 * so it is is suited well for finding tokens in a string and stop splitting
	 * as soon as a particular element is found. This also reduces memory copying
	 * to unused strings.
	 * @see Pattern#split(CharSequence,int)
	 */
	public static def Iterator<String> splitIt(CharSequence toSplit, Pattern pattern, int limit) {
		if (toSplit.length == 0) {
			return new EmptyStringIterator
		}
		if(limit<0) {
			return new UnlimitedSplitIterator(toSplit, pattern)
		}
		if(limit == 0) {
			return new UnlimitedSplitIteratorNoTrailingEmpty(toSplit, pattern)
		}
		// else: limited iterator
		new LimitedSplitIterator(toSplit, pattern, limit)
	}

	/**
	 * Creates an iterator that splits the input parameter string {@code toSplit}
	 * at the given regular expression {@code pattern}. The splitting behavior 
	 * is modeled after the rules of {@link Pattern#split(CharSequence)}.<br>
	 * The returned Iterator performs the splitting operations as lazy as possible,
	 * so it is is suited well for finding tokens in a string and stop splitting
	 * as soon as a particular element is found. This also reduces memory copying
	 * to unused strings.
	 * @see Pattern#split(CharSequence)
	 * @param toSplit is the string to be split by the given pattern. Must not be null
	 * @throws NullPointerException if toSplit or pattern is null
	 */
	public static def Iterator<String> splitIt(CharSequence toSplit, Pattern pattern) {
		Objects.requireNonNull(toSplit)
		if (toSplit.length == 0) {
			new EmptyStringIterator
		} else {
			new UnlimitedSplitIteratorNoTrailingEmpty(toSplit, pattern)
		}
	}

	/**
	 * Creates an iterator that splits the input parameter string {@code toSplit}
	 * at the given regular expression {@code pattern}. The splitting behavior 
	 * is modeled after the rules of {@link String#split(String)}.<br>
	 * The returned Iterator performs the splitting operations as lazy as possible,
	 * so it is is suited well for finding tokens in a string and stop splitting
	 * as soon as a particular element is found. This also reduces memory copying
	 * to unused strings.
	 * @see String#split(String)
	 */
	public static def Iterator<String> splitIt(CharSequence toSplit, String pattern) {
		toSplit.splitIt(Pattern.compile(pattern))
	}
	
	/**
	 * This method is a shortcut extension method for <br>
	 * {@code java.util.regex.Pattern.compile(pattern).splitAsStream(toSplit)}.
	 * @param toSplit the string to split according to the given {@code pattern}
	 * @param pattern the pattern used to split the parameter {@code toSplit}
	 */
	public static def Stream<String> splitStream(CharSequence toSplit, String pattern) {
		Pattern.compile(pattern).splitAsStream(toSplit)
	}

}