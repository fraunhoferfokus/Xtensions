package de.fhg.fokus.xtenders.iterator;

import java.util.PrimitiveIterator.OfInt;
import java.util.function.IntConsumer;
import java.util.stream.IntStream;

/**
 * This interface is a specialized version of an {@code Iterable<Integer>}
 * providing a {@link PrimitiveIterator.OfInt} which allows iteration over
 * unboxed primitive values.<br>
 * <br>
 * This abstraction can be used in situations where an {@link IntStream} would
 * be appropriate, but the user has to be able to create the stream multiple
 * times.<br>
 * <br>
 * This interface is also useful to abstract over the use of an {@code int[]}
 * array or an {@link org.eclipse.xtext.xbase.lib.IntegerRange IntegerRange}.
 * See classes {@link PrimitiveArrayExtensions} and
 * {@link de.fhg.fokus.xtenders.range.RangeExtensions RangeExtensions} how to
 * construct an IntIterable.
 * 
 * @see PrimitiveArrayExtensions#asIntIterable(int[])
 * @see de.fhg.fokus.xtenders.range.RangeExtensions#asIntIterable(org.eclipse.xtext.xbase.lib.IntegerRange)
 */
public interface IntIterable extends Iterable<Integer> {

	/**
	 * Returns a primitive iterator over elements of type {@code int}. This
	 * method specializes the super-interface method.
	 * 
	 * @return a PrimitiveIterator.OfInt
	 */
	OfInt iterator();

	/**
	 * Iterates over all elements of the iterable and calls {@code consumer} for
	 * each element. The default implementation uses {@link #iterator()} to get
	 * the elements of the iterable. Implementations are encouraged to overwrite
	 * this method with a more efficient implementation.
	 * 
	 * @param consumer
	 *            the action to be called for each element in the iterable.
	 */
	default void forEachInt(IntConsumer consumer) {
		final OfInt iterator = iterator();
		while (iterator.hasNext()) {
			int next = iterator.nextInt();
			consumer.accept(next);
		}
	}

	/**
	 * Returns an {@link IntStream} based on the elements in the iterable. <br>
	 * The default implementation returns a stream uses
	 * {@link PrimitiveIteratorExtensions#stream(OfInt)} with the iterator from
	 * {@link #iterator()} to construct the resulting stream. It is highly
	 * recommended for the implementations of this interface to provide an own
	 * implementation of this method.
	 * 
	 * @return an IntStream to iterate over the elements of this iterable.
	 */
	default IntStream stream() {
		final OfInt iterator = iterator();
		return PrimitiveIteratorExtensions.stream(iterator);
	}

	// TODO public static IntIterable generate(final IntSupplier s)
	// TODO public static IntIterable iterate(final int seed, final
	// IntUnaryOperator f)
}
