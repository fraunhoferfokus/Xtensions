package de.fhg.fokus.xtensions.iteration;

import java.util.PrimitiveIterator;
import java.util.PrimitiveIterator.OfDouble;
import java.util.function.DoubleConsumer;
import java.util.stream.DoubleStream;

import de.fhg.fokus.xtensions.iteration.PrimitiveIteratorExtensions;

/**
 * This interface is a specialized version of an {@code Iterable<Double>}
 * providing a {@link PrimitiveIterator.OfDouble} which allows iteration over
 * a (possibly infinite) amount of unboxed primitive values.<br>
 * <br>
 * This abstraction can be used in situations where an {@link DoubleStream} would
 * be appropriate, but the user has to be able to create the stream multiple
 * times. It can also be used as an immutable view on an {@code double[]} array.
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

	/**
	 * Iterates over all elements of the iterable and calls {@code consumer} for
	 * each element. The default implementation uses {@link #iterator()} to get
	 * the elements of the iterable. Implementations are encouraged to overwrite
	 * this method with a more efficient implementation.<br>
	 * Be aware that on inifinite iterables this method only returns when the 
	 * {@code consumer} throws an exception or terminates the runtime.
	 * 
	 * @param consumer
	 *            the action to be called for each element in the iterable.
	 */
	default void forEachDouble(DoubleConsumer consumer) {
		final OfDouble iterator = iterator();
		while (iterator.hasNext()) {
			double next = iterator.nextDouble();
			consumer.accept(next);
		}
	}

	/**
	 * Returns an {@link DoubleStream} based on the elements in the iterable. <br>
	 * The default implementation returns a stream uses
	 * {@link PrimitiveIteratorExtensions#streamRemaining(OfDouble)} with the iterator from
	 * {@link #iterator()} to construct the resulting stream. It is highly
	 * recommended for the implementations of this interface to provide an own
	 * implementation of this method.
	 * 
	 * @return a DoubleStream to iterate over the elements of this iterable.
	 */
	default DoubleStream stream() {
		final OfDouble iterator = iterator();
		return PrimitiveIteratorExtensions.streamRemaining(iterator);
	}

	// TODO public static DoubleIterable generate(final DoubleSupplier s)
	// TODO public static DoubleIterable iterate(final double seed, final DoubleUnaryOperator f)
	// TODO public static DoubleIterable iterate(final double seed, DoublePredicate hasNext, final DoubleUnaryOperator next)
}
