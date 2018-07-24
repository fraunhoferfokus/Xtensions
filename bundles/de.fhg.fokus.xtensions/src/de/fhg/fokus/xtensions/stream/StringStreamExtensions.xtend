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
import java.util.stream.Collectors

/**
 * This class provides extension methods for {@code Stream<String>} and in some cases for
 * {@code Stream<? extends CharSequence>}.
 */
final class StringStreamExtensions {
	
	// TODO filterNullOrEmpty
	
	private new() {
		throw new IllegalStateException
	}

	/**
	 * Shortcut for {@code stream.collect(Collectors.joining())}.
	 * @param stream the stream of character sequences to concatenate.
	 * @return concatenated string of all character sequences in {@code stream}
	 * @see Collectors#joining()
	 */
//	@Inline(value = "$1.collect(Collectors.joining())", imported = Collectors)
	static def String join(Stream<? extends CharSequence> stream) {
		stream.collect(joining)
	}

	/**
	 * Shortcut for {@code stream.collect(Collectors.joining(delimiter))}.
	 * @param stream the stream of character sequences to concatenate.
	 * @param delimiter will be used in between each element in {@code stream}
	 * @return concatenated string of all character sequences in {@code stream}
	 *  with {@code delimiter} as separator between elements.
	 * @see Collectors#joining(CharSequence)
	 */
//	@Inline(value = "$1.collect(Collectors.joining($2))", imported = Collectors)
	static def String join(Stream<? extends CharSequence> stream, CharSequence delimiter) {
		Objects.requireNonNull(delimiter, "separator string must not be null")
		stream.collect(joining(delimiter))
	}

	/**
	 * Shortcut for {@code stream.collect(Collectors.joining(delimiter,prefix))}.
	 * @param stream the stream of character sequences to concatenate.
	 * @param delimiter will be used in between each element in {@code stream}
	 * @param prefix will be prepended to the concatenated elements of {@code stream}.
	 * @param suffix fill be postpended after the concatenated elements of {@code stream}.
	 * @return concatenated string of all character sequences in {@code stream}
	 * @see Collectors#joining(CharSequence,CharSequence,CharSequence)
	 */
//	@Inline(value = "$1.collect(Collectors.joining($2,$3,$4))", imported = Collectors)
	static def String join(Stream<? extends CharSequence> stream, CharSequence delimiter, CharSequence prefix,
		CharSequence suffix) {
		Objects.requireNonNull(delimiter, "separator string must not be null")
		stream.collect(joining(delimiter, prefix, suffix))
	}

	/**
	 * Filtering the given {@code stream} by elements matching the given {@code pattern}.<br>
	 * This method is a wrapper calling {@link StringStreamExtensions#matching(Stream, Pattern) matching(Stream, Pattern)}
	 * by compiling the given {@code String pattern} to a {@link Pattern} object before the call.
	 * @param stream stream to be filtered to only contain elements matching the given {@code pattern}
	 * @param pattern the regex pattern to filter element in {@code stream} by.
	 * @param <S> Type extending {@link CharSequence} elements in {@code stream} are instance of
	 * @return {@code stream} filtered by the given {@code pattern}.
	 */
	static def <S extends CharSequence> Stream<S> matching(Stream<S> stream, String pattern) {
		Objects.requireNonNull(pattern, "Pattern must not be null")
		Objects.requireNonNull(stream, "Stream must not be null")
		val p = Pattern.compile(pattern)
		stream.matching(p)
	}

	/**
	 * Filtering the given {@code stream} by elements matching the given {@code pattern}.
	 * @param stream stream to be filtered to only contain elements matching the given {@code pattern}
	 * @param pattern the regex pattern to filter element in {@code stream} by.
	 * @param <S> Type extending {@link CharSequence} elements in {@code stream} are instance of
	 * @return {@code stream} filtered by the given {@code pattern}.
	 */
	static def <S extends CharSequence> Stream<S> matching(Stream<S> stream, Pattern pattern) {
		stream.filter[pattern.matcher(it).matches]
	}

	/**
	 * Splitting the elements of the given {@code stream} by the given {@code pattern} and returning
	 * a single stream of all results of the splits. This can e.g. be useful to split the content
	 * of a file into words:
	 * <pre> {@code 
	 * 	Files.lines(Paths.get("text.txt"))
	 *       .flatSplit("\\s+")
	 * }</pre>
	 * This method is a wrapper around {@link StringStreamExtensions#flatSplit(Stream, Pattern) flatSplit(Stream, Pattern)}
	 * first compiling the parameter {@code pattern} to a {@link Pattern} object then delegating to the wrapped function.
	 * @param stream the stream to be split elements using {@code pattern}
	 * @param pattern the pattern used to split elements in {@code stream}
	 * @return stream of all results of the splits of all elements in {@code stream} using {@code pattern}
	 */
	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, String pattern) {
		val p = Pattern.compile(pattern)
		stream.flatSplit(p)
	}

	/**
	 * Splitting the elements of the given {@code stream} by the given {@code pattern} and returning
	 * a single stream of all results of the splits. Note that the result will. This can e.g. be useful to split the content
	 * of a file into words:
	 * <pre> {@code 
	 * 	Files.lines(Paths.get("text.txt"))
	 *       .flatSplit("\\s+")
	 * }</pre>
	 * @param stream the stream to be split elements using {@code pattern}
	 * @param pattern the pattern used to split elements in {@code stream}
	 * @return stream of all results of the splits of all elements in {@code stream} using {@code pattern}
	 */
	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, Pattern pattern) {
		stream.flatMap[pattern.splitAsStream(it)]
	}

	/**
	 * Splitting the elements of the given {@code stream} by the given {@code pattern} and returning
	 * a single stream of all results of the splits. The maximum number of elements produced by a split
	 * can be set via the {@code limit} parameter. It follows the semantics of the {@link String#split(String,int)}
	 * method, so negative values will result in no limit in split elements and a value of {@code 0} leads 
	 * to an unlimited amount of split elements, but will drop trailing empty strings.<br>
	 * This method is a wrapper around {@link StringStreamExtensions#flatSplit(Stream, Pattern, int) flatSplit(Stream, Pattern, int)}
	 * first compiling the parameter {@code pattern} to a {@link Pattern} object then delegating to the wrapped function.
	 * @param stream the stream to be split elements using {@code pattern}
	 * @param pattern the pattern used to split elements in {@code stream}
	 * @param limit limits the amount of elements in which {@code stream} elements are split into, according
	 *  to the rules above
	 * @return stream of all results of the splits of all elements in {@code stream} using {@code pattern}
	 */
	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, String pattern, int limit) {
		val p = Pattern.compile(pattern)
		stream.flatSplit(p, limit)
	}

	/**
	 * Splitting the elements of the given {@code stream} by the given {@code pattern} and returning
	 * a single stream of all results of the splits. The maximum number of elements produced by a split
	 * can be set via the {@code limit} parameter. It follows the semantics of the {@link String#split(String,int)}
	 * method, so negative values will result in no limit in split elements and a value of {@code 0} leads 
	 * to an unlimited amount of split elements, but will drop trailing empty strings.
	 * @param stream the stream to be split elements using {@code pattern}
	 * @param pattern the pattern used to split elements in {@code stream}
	 * @param limit limits the amount of elements in which {@code stream} elements are split into, according
	 *  to the rules above
	 * @return stream of all results of the splits of all elements in {@code stream} using {@code pattern}
	 */
	static def Stream<String> flatSplit(Stream<? extends CharSequence> stream, Pattern pattern, int limit) {
		stream.flatMap[splitStream(pattern, limit)]
	}

	private static def Stream<String> splitStream(CharSequence input, extension Pattern pattern, int limit) {
		if (limit == 0) {
			// take platform native implementation for default behavior
			input.splitAsStream
		} else {
			val Supplier<Spliterator<String>> s = [|
				val characteristics = Spliterator.ORDERED.bitwiseOr(Spliterator.NONNULL)
				Spliterators.spliteratorUnknownSize(input.splitIt(pattern, limit), characteristics)
			]
			StreamSupport.stream(s, 0, false)
		}
	}

	/**
	 * Takes {@code stream}, finds matches in each element of the stream according to
	 * the given {@code pattern} and provides all matches in a single stream returned 
	 * as the result.
	 * @param stream elements which are searched for matches according to {@code pattern}
	 * @param pattern to find matches in elements of {@code stream}
	 * @return stream containing all matches in input {@code stream} according to {@code pattern}
	 */
	static def Stream<String> flatMatches(Stream<String> stream, Pattern pattern) {
		stream.flatMap[matchStream(pattern)]
	}

	/**
	 * Takes {@code stream}, finds matches in each element of the stream according to
	 * the given {@code pattern} and provides all matches in a single stream returned 
	 * as the result.<br>
	 * This method is a wrapper around {@link StringStreamExtensions#flatMatches(Stream, Pattern) flatMatches(Stream, Pattern)}
	 * first compiling the parameter {@code pattern} to a {@link Pattern} object then delegating to the wrapped function.
	 * @param stream elements which are searched for matches according to {@code pattern}
	 * @param pattern to find matches in elements of {@code stream}
	 * @return stream containing all matches in input {@code stream} according to {@code pattern}
	 */
	static def Stream<String> flatMatches(Stream<String> stream, String pattern) {
		stream.flatMatches(Pattern.compile(pattern))
	}

	// TODO publish as part of StringMatchExtensions
	private static def Stream<String> matchStream(String input, Pattern pattern) {
		// TODO characteristics!!
		val Supplier<Spliterator<String>> s = [|
			// TODO think about custom spliterator instead of wrapping the iterator
			Spliterators.spliteratorUnknownSize(input.matchIt(pattern), 0)
		]
		StreamSupport.stream(s, 0, false)
	}

// Stream<String>#matches, groups to stream (reading lazy)?
// Stream<String>#matching(String) and #matching(Pattern)
}
