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

import java.util.PrimitiveIterator
import java.util.stream.IntStream
import java.util.Spliterators
import java.util.stream.StreamSupport
import java.util.Spliterator
import java.util.stream.LongStream
import java.util.stream.DoubleStream
import java.util.IntSummaryStatistics
import java.util.LongSummaryStatistics
import java.util.DoubleSummaryStatistics

/**
 * This class contains static methods for the primitive iterators defined in {@link PrimitiveIterator}.
 * The methods are intended to be used as extension methods.
 * The class is not intended to be instantiated.
 */
final class PrimitiveIteratorExtensions {
	
	// static def OptionalInt reduce(PrimitiveIterator.OfInt,IntBinaryOperator op)
	// static def int reduce(PrimitiveIterator.OfInt, int identity, IntBinaryOperator op)
	
	// * min, 
	// * max,
	// * average,
	// * sum​,
	// * count,
	
	// * anyMatch(XXXPredicate),
	// * allMatch(XXXPredicate)/noneMatch(XXXPredicate)
	// * findFirst​(XXXPredicate)
	// * findFirst
	// * filter(XXXPredicate)
	
	private new() {
		throw new IllegalStateException("PrimitiveIteratorExtensions not intended to be instantiated")
	}
	
	//////////////////////////////////
	// for PrimitiveIterator.OfInt  //
	//////////////////////////////////
	
	/**
	 * Convenience method to turn a primitive iterator into a stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not null.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 */
	static def IntStream streamRemaining(PrimitiveIterator.OfInt wrapped) { 
		val spliterator = wrapped.toSpliterator
		StreamSupport.intStream(spliterator, false)
	}
	
	/**
	 * Convenience method to turn a primitive iterator into a parallel stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not null.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 */
	static def IntStream parallelStreamRemaining(PrimitiveIterator.OfInt wrapped) {  
		val spliterator = wrapped.toSpliterator
		StreamSupport.intStream(spliterator, true)
	}
	
	private static def Spliterator.OfInt toSpliterator(PrimitiveIterator.OfInt wrapped) {
		val characteristics = Spliterator.NONNULL
		Spliterators.spliteratorUnknownSize(wrapped,characteristics)
	}
	
	
	/**
	 * This method will read all remaining {@code int} values from the given
	 * {@code iterator} and creates and returns an {@link IntSummaryStatistics} over all
	 * these elements.
	 * @param iterator primitive iterator over elements to be summarized
	 * @return a statistics object over all elements in {@code iterator}
	 * @throws NullPointerException if {@code iterator} is {@code null}.
	 */
	static def IntSummaryStatistics summarize(PrimitiveIterator.OfInt iterator) {
		val result = new IntSummaryStatistics
		while(iterator.hasNext) {
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
	 * other than that the elements returned by the iterator are not null.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 */
	static def LongStream streamRemaining(PrimitiveIterator.OfLong wrapped) { 
		val spliterator = wrapped.toSpliterator
		StreamSupport.longStream(spliterator, false)
	}
	
	/**
	 * Convenience method to turn a primitive iterator into a parallel stream. 
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not null.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 */
	static def LongStream parallelStreamRemaining(PrimitiveIterator.OfLong wrapped) {  
		val spliterator = wrapped.toSpliterator
		StreamSupport.longStream(spliterator, true)
	}
	
	private static def Spliterator.OfLong toSpliterator(PrimitiveIterator.OfLong wrapped) {
		val characteristics = Spliterator.NONNULL
		Spliterators.spliteratorUnknownSize(wrapped,characteristics)
	}
	
	/**
	 * This method will read all remaining {@code long} values from the given
	 * {@code iterator} and creates and returns an {@link LongSummaryStatistics} over all
	 * these elements.
	 * @param iterator primitive iterator over elements to be summarized
	 * @return a statistics object over all elements in {@code iterator}
	 * @throws NullPointerException if {@code iterator} is {@code null}.
	 */
	static def LongSummaryStatistics summarize(PrimitiveIterator.OfLong iterator) {
		val result = new LongSummaryStatistics
		while(iterator.hasNext) {
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
	 * other than that the elements returned by the iterator are not null.
	 * @param wrapped the iterator from which the returned stream is created from
	 * @return stream providing the remaining elements from {@code wrapped}
	 */
	static def DoubleStream streamRemaining(PrimitiveIterator.OfDouble wrapped) { 
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
		Spliterators.spliteratorUnknownSize(wrapped,characteristics)
	}
	
	/**
	 * This method will read all remaining {@code double} values from the given
	 * {@code iterator} and creates and returns an {@link DoubleSummaryStatistics} over all
	 * these elements.
	 * @param iterator primitive iterator over elements to be summarized
	 * @return a statistics object over all elements in {@code iterator}
	 * @throws NullPointerException if {@code iterator} is {@code null}.
	 */
	static def DoubleSummaryStatistics summarize(PrimitiveIterator.OfDouble iterator) {
		val result = new DoubleSummaryStatistics
		while(iterator.hasNext) {
			val next = iterator.nextDouble
			result.accept(next)
		}
		result
	}
}
