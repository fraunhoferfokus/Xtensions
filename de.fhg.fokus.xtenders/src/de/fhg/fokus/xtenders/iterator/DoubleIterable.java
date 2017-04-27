package de.fhg.fokus.xtenders.iterator;

import java.util.PrimitiveIterator.OfDouble;
import java.util.function.DoubleConsumer;
import java.util.stream.DoubleStream;

/**
 * This interface is a specialized version of an {@code Iterable<Double>}
 * providing a {@link PrimitiveIterator.OfDouble} which allows iteration over
 * unboxed primitive values.
 */
public interface DoubleIterable extends Iterable<Double> {

	/**
	 * Returns a primitive iterator over elements of type {@code double}. This
	 * method specializes the super-interface method.
	 * 
	 * @return a PrimitiveIterator.OfDouble
	 */
	@Override
	OfDouble iterator();

	default void forEachDouble(DoubleConsumer consumer) {
		final OfDouble iterator = iterator();
		while (iterator.hasNext()) {
			double next = iterator.nextDouble();
			consumer.accept(next);
		}
	}

	default DoubleStream stream() {
		final OfDouble iterator = iterator();
		return PrimitiveIteratorExtensions.stream(iterator);
	}
}
