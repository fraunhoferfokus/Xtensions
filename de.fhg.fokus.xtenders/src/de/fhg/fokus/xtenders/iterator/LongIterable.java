package de.fhg.fokus.xtenders.iterator;

import java.util.PrimitiveIterator.OfLong;
import java.util.function.LongConsumer;

/**
 * This is a specialized {@link Iterable} returning an {@link OfLong} as iterator
 * allowing to iterate over long values without boxing them.
 */
public interface LongIterable extends Iterable<Long> {
	
	public OfLong iterator();
	
	default void forEachLong(LongConsumer consumer) {
		final OfLong iterator = iterator();
		while(iterator.hasNext()) {
			long next = iterator.nextLong();
			consumer.accept(next);
		}
	}
	
//	default LongStream stream() {
//	final OfLong iterator = iterator();
//	return PrimitiveIteratorExtensions.stream(iterator);
//}
}
