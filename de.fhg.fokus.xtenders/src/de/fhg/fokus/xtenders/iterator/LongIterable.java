package de.fhg.fokus.xtenders.iterator;

import java.util.PrimitiveIterator.OfLong;
import java.util.function.LongConsumer;
import java.util.stream.LongStream;

/**
 * This interface is a specialized version of an {@code Iterable<Double>}
 * providing a {@link PrimitiveIterator.OfDouble} which allows iteration over
 * unboxed primitive values.
 */
public interface LongIterable extends Iterable<Long> {
	
	/**
	 * Returns a primitive iterator over elements of type {@code long}. This
	 * method specializes the super-interface method.
	 * 
	 * @return a PrimitiveIterator.OfLong
	 */
	public OfLong iterator();
	
	default void forEachLong(LongConsumer consumer) {
		final OfLong iterator = iterator();
		while(iterator.hasNext()) {
			long next = iterator.nextLong();
			consumer.accept(next);
		}
	}
	
	default LongStream stream() {
		final OfLong iterator = iterator();
		return PrimitiveIteratorExtensions.stream(iterator);
	}
}
