package de.fhg.fokus.xtensions.iteration;

import java.util.PrimitiveIterator;
import java.util.PrimitiveIterator.OfInt;
import java.util.function.IntConsumer;
import java.util.function.IntSupplier;
import java.util.function.IntUnaryOperator;
import java.util.function.Supplier;
import java.util.stream.IntStream;

import de.fhg.fokus.xtensions.iteration.IterateIntIterable;
import de.fhg.fokus.xtensions.iteration.PrimitiveArrayExtensions;
import de.fhg.fokus.xtensions.iteration.PrimitiveIteratorExtensions;
import de.fhg.fokus.xtensions.iteration.SupplierIntIterable;

/**
 * This interface is a specialized version of an {@code Iterable<Integer>}
 * providing a {@link PrimitiveIterator.OfInt} which allows iteration over a
 * (possibly infinite) amount of unboxed primitive values.<br>
 * <br>
 * This abstraction can be used in situations where an {@link IntStream} would
 * be appropriate, but the user has to be able to create the stream multiple
 * times. It can also be used as an immutable view on an {@code int[]}
 * array.<br>
 * <br>
 * This interface is also useful to abstract over different datatypes providing
 * int values such as {@code int[]} array,
 * {@link org.eclipse.xtext.xbase.lib.IntegerRange IntegerRange}, or one of the
 * generator functions {@link IntIterable#generate(Supplier) generate} and
 * {@link IntIterable#iterate(int, IntUnaryOperator) iterate}.
 * 
 * @see PrimitiveArrayExtensions#asIntIterable(int[])
 * @see de.fhg.fokus.xtensions.range.RangeExtensions#asIntIterable(org.eclipse.xtext.xbase.lib.IntegerRange)
 */
public interface IntIterable extends Iterable<Integer> {

	/**
	 * Returns a primitive iterator over elements of type {@code int}. This
	 * method specializes the super-interface method.
	 * 
	 * @return a PrimitiveIterator.OfInt
	 */
	@Override
	OfInt iterator();

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
	 * {@link PrimitiveIteratorExtensions#streamRemaining(OfInt)} with the iterator from
	 * {@link #iterator()} to construct the resulting stream. It is highly
	 * recommended for the implementations of this interface to provide an own
	 * implementation of this method.
	 * 
	 * @return an IntStream to iterate over the elements of this iterable.
	 */
	default IntStream stream() {
		final OfInt iterator = iterator();
		return PrimitiveIteratorExtensions.streamRemaining(iterator);
	}

	/**
	 * Creates a new IntIterable that will produce an infinite
	 * {@link PrimitiveIterator.OfInt} or {@link IntStream} based on the
	 * {@link IntSupplier} provided by supplier {@code s}.
	 * 
	 * @param s
	 *            supplier, that provides an {@link IntSupplier} for each
	 *            iterator or stream created.
	 * @return IntIterable based on the supplier {@code s}.
	 */
	public static IntIterable generate(final Supplier<IntSupplier> s) {
		return new SupplierIntIterable(s);
	}

	/**
	 * Creates {@link IntIterable} an infinite providing an infinite source of
	 * numbers, starting with the given {@code seed} value and in every
	 * subsequent step the result of the given {@code operator} applied on the
	 * last step's value. So in the second step this would be
	 * {@code op.applyAsInt(seed)} and so on.
	 * 
	 * @param seed
	 *            first value to be provided and used as seed fed to {@code op}
	 *            in second step.
	 * @param op
	 *            this operator must be side-effect free.
	 * @return and {@link IntIterable} providing infinite source of numbers
	 *         based on {@code seed} and {@code op}.
	 */
	public static IntIterable iterate(final int seed, final IntUnaryOperator op) {
		return new IterateIntIterable(seed, op);
	}

	// TODO public static IntIterable iterate(final int seed, IntPredicate hasNext, final IntUnaryOperator next)
}
