package de.fhg.fokus.xtenders.iterator;

import java.util.PrimitiveIterator.OfInt;
import java.util.function.IntConsumer;

public interface IntegerIterable extends Iterable<Integer> {
	
	OfInt iterator();
	
	default void forEachInt(IntConsumer consumer) {
		final OfInt iterator = iterator();
		while(iterator.hasNext()) {
			int next = iterator.nextInt();
			consumer.accept(next);
		}
	}
}
