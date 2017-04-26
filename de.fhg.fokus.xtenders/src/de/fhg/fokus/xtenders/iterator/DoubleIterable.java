package de.fhg.fokus.xtenders.iterator;

import java.util.PrimitiveIterator.OfDouble;
import java.util.function.DoubleConsumer;

public interface DoubleIterable extends Iterable<Double> {
	
	@Override
	OfDouble iterator();
	
	default void forEachDouble(DoubleConsumer consumer) {
		final OfDouble iterator = iterator();
		while(iterator.hasNext()) {
			double next = iterator.nextDouble();
			consumer.accept(next);
		}
	}
}
