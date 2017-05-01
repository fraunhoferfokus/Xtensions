package de.fhg.fokus.xtensions.stream

import java.util.stream.Stream
import java.util.Spliterator
import java.util.Spliterators
import java.util.regex.Pattern
import static extension de.fhg.fokus.xtensions.string.StringSplitExtensions.*
import static extension de.fhg.fokus.xtensions.string.StringMatchExtensions.*
import java.util.Objects
import static java.util.stream.Collectors.*
import java.util.function.Supplier
import java.util.stream.StreamSupport

class StringStreamExtensions {
		static def String join(Stream<? extends CharSequence> stream) {
		stream.collect(joining)
	}

	static def String join(Stream<? extends CharSequence> stream, CharSequence delimiter) {
		Objects.requireNonNull(delimiter, "separator string must not be null")
		stream.collect(joining(delimiter))
	}

	static def String join(Stream<? extends CharSequence> stream, CharSequence delimiter, CharSequence prefix,
		CharSequence suffix) {
		Objects.requireNonNull(delimiter, "separator string must not be null")
		stream.collect(joining(delimiter, prefix, suffix))
	}

	static def <S extends CharSequence> Stream<S> matching(Stream<S> stream, String pattern) {
		Objects.requireNonNull(pattern, "Pattern must not be null")
		Objects.requireNonNull(stream, "Stream must not be null")
		val p = Pattern.compile(pattern)
		stream.matching(p)
	}

	static def <S extends CharSequence> Stream<S> matching(Stream<S> stream, Pattern pattern) {
		stream.filter[pattern.matcher(it).matches]
	}

	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, String pattern) {
		val p = Pattern.compile(pattern)
		stream.flatSplit(p)
	}

	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, Pattern pattern) {
		stream.flatMap[pattern.splitAsStream(it)]
	}

	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, String pattern, int limit) {
		val p = Pattern.compile(pattern)
		stream.flatSplit(p, limit)
	}

	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, Pattern pattern, int limit) {
		stream.flatMap[splitStream(pattern, limit)]
	}

	private static def Stream<String> splitStream(CharSequence input, Pattern pattern, int limit) {
		if (limit == 0) {
			// take platform native implementation for default behavior
			pattern.splitAsStream(input)
		} else {
			val Supplier<Spliterator<String>> s = [|
				val characteristics = Spliterator.ORDERED.bitwiseOr(Spliterator.NONNULL)
				Spliterators.spliteratorUnknownSize(input.splitIt(pattern, limit), characteristics)
			]
			StreamSupport.stream(s, 0, false)
		}
	}

	static def Stream<String> flatMatches(Stream<String> stream, Pattern pattern) {
		stream.flatMap[matchStream(pattern)]
	}

	static def Stream<String> flatMatches(Stream<String> stream, String pattern) {
		stream.flatMatches(Pattern.compile(pattern))
	}

	private static def Stream<String> matchStream(String input, Pattern pattern) {
		// TODO characteristics!!
		val Supplier<Spliterator<String>> s = [|
			Spliterators.spliteratorUnknownSize(input.matchIt(pattern), 0)
		]
		StreamSupport.stream(s, 0, false)
	}
	
// Stream<String>#matches, groups to stream (reading lazy)?
// Stream<String>#matching(String) and #matching(Pattern)
}