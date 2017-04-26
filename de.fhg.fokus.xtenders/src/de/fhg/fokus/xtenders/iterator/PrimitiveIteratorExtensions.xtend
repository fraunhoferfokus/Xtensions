package de.fhg.fokus.xtenders.iterator

import java.util.PrimitiveIterator
import java.util.stream.IntStream
import java.util.Spliterators
import java.util.stream.StreamSupport
import java.util.Spliterator

class PrimitiveIteratorExtensions {
	private new() {
	}
	
	/**
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not null.
	 */
	static def IntStream stream(PrimitiveIterator.OfInt wrapped) { 
		val spliterator = wrapped.toSpliterator
		StreamSupport.intStream(spliterator, false)
	}
	
	/**
	 * Best effort transformation from iterator to stream. Does not make any assumptions,
	 * other than that the elements returned by the iterator are not null.
	 */
	static def IntStream parallelStream(PrimitiveIterator.OfInt wrapped) {  
		val spliterator = wrapped.toSpliterator
		StreamSupport.intStream(spliterator, true)
	}
	
	private static def Spliterator.OfInt toSpliterator(PrimitiveIterator.OfInt wrapped) {
		val characteristics = Spliterator.NONNULL
		val estimatedSize = 0
		Spliterators.spliterator(wrapped,estimatedSize,characteristics)
	}
	
	// TODO for other primitive iterators
}
