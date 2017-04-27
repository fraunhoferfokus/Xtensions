package de.fhg.fokus.xtenders.iterator;

import java.util.PrimitiveIterator.OfInt;
import java.util.function.IntConsumer;
import java.util.stream.IntStream;

/**
 * This class is particularly useful to abstract over the use of an {@code int[]} array or an {@link org.eclipse.xtext.xbase.lib.IntegerRange IntegerRange}.
 * See classes {@link PrimitiveArrayExtensions} and {@link de.fhg.fokus.xtenders.range.RangeExtensions RangeExtensions} how to construct an IntIterable. 
 * 
 * @see PrimitiveArrayExtensions#asIntIterable(int[])
 * @see de.fhg.fokus.xtenders.range.RangeExtensions#asIntIterable(org.eclipse.xtext.xbase.lib.IntegerRange)
 */
public interface IntIterable extends Iterable<Integer> {
	
	OfInt iterator();
	
	default void forEachInt(IntConsumer consumer) {
		final OfInt iterator = iterator();
		while(iterator.hasNext()) {
			int next = iterator.nextInt();
			consumer.accept(next);
		}
	}
	
	default IntStream stream() {
		final OfInt iterator = iterator();
		return PrimitiveIteratorExtensions.stream(iterator);
	}
	
	// TODO public static IntIterable of(Iterable<Integer>)
}
