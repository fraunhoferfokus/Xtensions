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
package de.fhg.fokus.xtensions.iteration

import java.util.DoubleSummaryStatistics
import java.util.IntSummaryStatistics
import java.util.LongSummaryStatistics
import java.util.PrimitiveIterator
import java.util.Spliterator
import java.util.Spliterators
import java.util.stream.DoubleStream
import java.util.stream.IntStream
import java.util.stream.LongStream
import java.util.stream.StreamSupport
import de.fhg.fokus.xtensions.iteration.internal.DoubleStreamable
import de.fhg.fokus.xtensions.iteration.internal.IntStreamable
import de.fhg.fokus.xtensions.iteration.internal.LongStreamable

/**
 * This class contains static methods for the primitive iterators defined in {@link PrimitiveIterator}.
 * The methods are intended to be used as extension methods.
 * The class is not intended to be instantiated.
 * @since 1.1.0
 */
final class PrimitiveIteratorExtensions {

	// * min, 
	// * max,
	// * average,
	// * sum​,
	// * count,
	
	private new() {
		throw new IllegalStateException("PrimitiveIteratorExtensions not intended to be instantiated")
	}

	//////////////////////////////////
	// for PrimitiveIterator.OfInt  //
	//////////////////////////////////
	
	/**
	 * Convenience method to turn a primitive iterator into a stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not {@code null}.
	 * Note that this method does <em>not</em> guarantee that the given iterator will
	 * be exhausted. If the underlying iterator implementation is known the stream
	 * may not pull elements from the {@code wrapped} iterator.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 * @see PrimitiveIteratorExtensions#streamRemainingExhaustive(OfInt)
	 */
	static def IntStream streamRemaining(PrimitiveIterator.OfInt wrapped) {
		if (wrapped instanceof IntStreamable) {
			wrapped.streamInts
		} else {
			wrapped.streamRemainingExhaustive
		}
	}
	
	/**
	 * Convenience method to turn a primitive iterator into a stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not {@code null}.
	 * Note that this method does <em>not</em> guarantee that the given iterator will
	 * be exhausted. If the underlying iterator implementation is known the stream
	 * may not pull elements from the {@code wrapped} iterator in order to create
	 * a stream that may have better characteristics in some way.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 * @see PrimitiveIteratorExtensions#streamRemaining(OfInt)
	 * @since 1.1.0
	 */
	static def IntStream streamRemainingExhaustive(PrimitiveIterator.OfInt wrapped) {
		val spliterator = wrapped.toSpliterator
		StreamSupport.intStream(spliterator, false)
	}

	/**
	 * Convenience method to turn a primitive iterator into a parallel stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not {@code null}.
	 * Note that this method does <em>not</em> guarantee that the given iterator will
	 * be exhausted. If the underlying iterator implementation is known the stream
	 * may not pull elements from the {@code wrapped} iterator.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 */
	static def IntStream parallelStreamRemaining(PrimitiveIterator.OfInt wrapped) {
		val spliterator = wrapped.toSpliterator
		StreamSupport.intStream(spliterator, true)
	}

	private static def Spliterator.OfInt toSpliterator(PrimitiveIterator.OfInt wrapped) {
		val characteristics = Spliterator.NONNULL
		Spliterators.spliteratorUnknownSize(wrapped, characteristics)
	}

	/**
	 * This method will read all remaining {@code int} values from the given
	 * {@code iterator} and creates and returns an {@link IntSummaryStatistics} over all
	 * these elements.
	 * @param iterator primitive iterator over elements to be summarized
	 * @return a statistics object over all elements in {@code iterator}
	 * @throws NullPointerException if {@code iterator} is {@code null}.
	 * @since 1.1.0
	 */
	static def IntSummaryStatistics summarize(PrimitiveIterator.OfInt iterator) {
		val result = new IntSummaryStatistics
		while (iterator.hasNext) {
			val next = iterator.nextInt
			result.accept(next)
		}
		result
	}

	///////////////////////////////////
	// for PrimitiveIterator.OfLong  //
	///////////////////////////////////
	
	/**
	 * Convenience method to turn a primitive iterator into a stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not {@code null}.
	 * Note that this method does <em>not</em> guarantee that the given iterator will
	 * be exhausted. If the underlying iterator implementation is known the stream
	 * may not pull elements from the {@code wrapped} iterator in order to create
	 * a stream that may have better characteristics in some way.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 * @see PrimitiveIteratorExtensions#streamRemainingExhaustive(OfLong)
	 */
	static def LongStream streamRemaining(PrimitiveIterator.OfLong wrapped) {
		if(wrapped instanceof LongStreamable) {
			wrapped.streamLongs
		} else {
			val spliterator = wrapped.toSpliterator
			StreamSupport.longStream(spliterator, false)
		}
	}
	
	/**
	 * Convenience method to turn a primitive iterator into a stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not {@code null}.
	 * Note that this method does <em>not</em> guarantee that the given iterator will
	 * be exhausted. If the underlying iterator implementation is known the stream
	 * may not pull elements from the {@code wrapped} iterator.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 * @see PrimitiveIteratorExtensions#streamRemaining(OfLong)
	 * @since 1.1.0
	 */
	static def LongStream streamRemainingExhaustive(PrimitiveIterator.OfLong wrapped) {
		val spliterator = wrapped.toSpliterator
		StreamSupport.longStream(spliterator, false)
	}

	/**
	 * Convenience method to turn a primitive iterator into a parallel stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not {@code null}.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 */
	static def LongStream parallelStreamRemaining(PrimitiveIterator.OfLong wrapped) {
		val spliterator = wrapped.toSpliterator
		StreamSupport.longStream(spliterator, true)
	}

	private static def Spliterator.OfLong toSpliterator(PrimitiveIterator.OfLong wrapped) {
		val characteristics = Spliterator.NONNULL
		Spliterators.spliteratorUnknownSize(wrapped, characteristics)
	}

	/**
	 * This method will read all remaining {@code long} values from the given
	 * {@code iterator} and creates and returns an {@link LongSummaryStatistics} over all
	 * these elements.
	 * @param iterator primitive iterator over elements to be summarized
	 * @return a statistics object over all elements in {@code iterator}
	 * @throws NullPointerException if {@code iterator} is {@code null}.
	 * @since 1.1.0
	 */
	static def LongSummaryStatistics summarize(PrimitiveIterator.OfLong iterator) {
		val result = new LongSummaryStatistics
		while (iterator.hasNext) {
			val next = iterator.nextLong
			result.accept(next)
		}
		result
	}

	/////////////////////////////////////
	// for PrimitiveIterator.OfDouble  //
	/////////////////////////////////////
	
	/**
	 * Convenience method to turn a primitive iterator into a stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not {@code null}.
	 * Note that this method does <em>not</em> guarantee that the given iterator will
	 * be exhausted. If the underlying iterator implementation is known the stream
	 * may not pull elements from the {@code wrapped} iterator in order to create
	 * a stream that may have better characteristics in some way.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 * @see PrimitiveIteratorExtensions#streamRemainingExhaustive(OfDouble)
	 */
	static def DoubleStream streamRemaining(PrimitiveIterator.OfDouble wrapped) {
		if (wrapped instanceof DoubleStreamable) {
			wrapped.streamDoubles
		} else {
			wrapped.streamRemainingExhaustive
		}
	}
	
	/**
	 * Convenience method to turn a primitive iterator into a stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not {@code null}.
	 * Note that this method <em>does</em> guarantee that the given iterator will
	 * be exhausted. All elements provided by the stream are taken from the {@code wrapped}
	 * iterator.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 * @see PrimitiveIteratorExtensions#streamRemaining(OfDouble)
	 * @since 1.1.0
	 */
	static def DoubleStream streamRemainingExhaustive(PrimitiveIterator.OfDouble wrapped) {
		val spliterator = wrapped.toSpliterator
		StreamSupport.doubleStream(spliterator, false)
	}

	/**
	 * Convenience method to turn a primitive iterator into a parallel stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not null.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 */
	static def DoubleStream parallelStreamRemaining(PrimitiveIterator.OfDouble wrapped) {
		val spliterator = wrapped.toSpliterator
		StreamSupport.doubleStream(spliterator, true)
	}

	private static def Spliterator.OfDouble toSpliterator(PrimitiveIterator.OfDouble wrapped) {
		val characteristics = Spliterator.NONNULL
		Spliterators.spliteratorUnknownSize(wrapped, characteristics)
	}

	/**
	 * This method will read all remaining {@code double} values from the given
	 * {@code iterator} and creates and returns an {@link DoubleSummaryStatistics} over all
	 * these elements.
	 * @param iterator primitive iterator over elements to be summarized
	 * @return a statistics object over all elements in {@code iterator}
	 * @throws NullPointerException if {@code iterator} is {@code null}.
	 * @since 1.1.0
	 */
	static def DoubleSummaryStatistics summarize(PrimitiveIterator.OfDouble iterator) {
		val result = new DoubleSummaryStatistics
		while (iterator.hasNext) {
			val next = iterator.nextDouble
			result.accept(next)
		}
		result
	}
}
