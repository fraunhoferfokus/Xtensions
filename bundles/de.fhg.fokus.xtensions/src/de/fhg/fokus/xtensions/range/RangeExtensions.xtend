package de.fhg.fokus.xtensions.range

import java.util.function.IntConsumer
import java.util.stream.IntStream
import java.util.stream.StreamSupport
import java.util.Spliterator
import java.util.Comparator
import java.util.PrimitiveIterator
import java.util.NoSuchElementException
import de.fhg.fokus.xtensions.iteration.IntIterable
import java.util.Objects

/**
 * This class provides static extension methods to {@link IntegerRange}. To use these methods in Xtend, import this class via <br>
 * {@code import static extension de.fhg.fokus.xtensions.range.RangeExtensions.*}
 * <br>
 * This class is not intended to be instantiated.
 */
class RangeExtensions {
		
	private new() {}
	
	// TODO count (of steps)
	// TODO random access by index

	/**
	 * This method iterates over all integers in range {@code r} and applies the given {@code consumer} for every element.<br>
	 * This method is more efficient than the generic iteration extension method 
	 * {@link org.eclipse.xtext.xbase.lib.IterableExtensions#forEach(Iterable, org.eclipse.xtext.xbase.lib.Procedures.Procedure1) IterableExtensions#forEach} 
	 * because it uses {@link IntConsumer} as the receiver of elements in the range, which prevents boxing of the integer values.
	 * @param r the range to iterate over. Must not be {@code null}
	 * @param consumer the function that is called for each element in the range {@code r}.
	 * @thorws NullPointerException if {@code r} or {@code consumer} is {@code null}
	 */
	def static void forEachInt(IntegerRange r, IntConsumer consumer) {
		val int start = r.getStart()
		val int end = r.getEnd()
		val int step = r.getStep()
		if (step > 0) {
			for (var int i = start; i <= end; i += step) {
				consumer.accept(i)
			}
		} else {
			for (var int i = start; i >= end; i += step) {
				consumer.accept(i)
			}
		}
	}
	
	/**
	 * This method iterates over all integers in range {@code r} and applies the given {@code consumer} for every element, additionally with the index in the range (starting with index 0).
	 * The first element passed to the consumer is an element from the range, the second one the index.<br>
	 * This method is more efficient than the generic iteration extension method 
	 * {@link org.eclipse.xtext.xbase.lib.IterableExtensions#forEach(Iterable, org.eclipse.xtext.xbase.lib.Procedures.Procedure2) IterableExtensions#forEach} 
	 * because it uses {@link IntIntConsumer} as the receiver of elements in the range, which prevents boxing of the integer values.
	 * @param r the range to iterate over. Must not be {@code null}
	 * @param consumer the function that is called for each element in the range {@code r} and the index in the range (starting with 0).
	 * @thorws NullPointerException if {@code r} or {@code consumer} is {@code null}
	 */
	def static void forEachInt(IntegerRange r, IntIntConsumer consumer) {
		val int start = r.getStart()
		val int end = r.getEnd()
		val int step = r.getStep()
		var int index = 0
		if (step > 0) {
			for (var int i = start; i <= end; i += step) {
				consumer.accept(i, index++)
			}
		} else {
			for (var int i = start; i >= end; i += step) {
				consumer.accept(i, index++)
			}
		}
	}

	def static IntStream stream(IntegerRange r) {
		//val spliterator = new IntegerRangeSpliterator(r)
		val spliterator = new IntegerRangeSpliterator(r)
		StreamSupport.intStream(spliterator, false)
	}

	def static IntStream parallelStream(IntegerRange r) {
		val spliterator = new IntegerRangeSpliterator(r)
		StreamSupport.intStream(spliterator, true)
	}
	
	def static PrimitiveIterator.OfInt intIterator(IntegerRange r) {
		new IntegerRangeIntIterator(r)
	}
	
	/**
	 * Provides an {@link IntIterable} view on the given {@code IntegerRange r}.
	 * @param r range to create the view for
	 * @return {@link IntIterable} view on the given {@code IntegerRange r}.
	 */
	def static IntIterable asIntIterable(IntegerRange r) {
		new IntegerRangeIntIterable(r)
	}

// TODO ExclusiveRange#intIterator() -> PrimitiveIterator.OfInt
// TODO same extensions for ExclusiveRange ??? 
// TODO ExclusiveRange#toIntegerRange -> Optional<IntegerRange>
}

package class IntegerRangeIntIterable implements IntIterable {
	val IntegerRange range
	
	new (IntegerRange range) {
		this.range = Objects.requireNonNull(range)
	}
	
	override iterator() {
		new IntegerRangeIntIterator(range)
	}
	
	override forEachInt(IntConsumer consumer) {
		RangeExtensions.forEachInt(range, consumer)
	}
	
	override stream() {
		RangeExtensions.stream(range)
	}
	
}

package class IntegerRangeIntIterator implements PrimitiveIterator.OfInt {
	
	val IntegerRange range
	var int next;
	
	new(IntegerRange range) {
		this.range = range
		this.next = range.start
	}
	
	override nextInt() {
		if (!hasNext()) {
			throw new NoSuchElementException()
		}
		val int value = next
		next += range.step
		return value;
	}
	
	override hasNext() {
		extension val r = range
		if (step < 0)
				return next >= end
			else
				return next <= end
	}
	
}

/**
 * Implementation of {@code Spliterator.OfInt} for {@code org.eclipse.xtext.xbase.lib.IntegerRange}
 * without wrapping it, but copying it's details (start, end, step) over. This spliterator allows 
 * splitting, as well as parallel execution
 */
package class IntegerRangeSpliterator implements Spliterator.OfInt {

	val int start
	var int end
	val int step
	var int next
	val int characteristics

	new(IntegerRange r) {
		this(r.start, r.end, r.step)
	}

	new(int start, int end, int step) {
		if (step == 0) {
			throw new IllegalArgumentException
		}
		this.start = start
		this.end = end
		this.step = step
		this.next = start
		this.characteristics = Spliterator.DISTINCT.bitwiseOr(Spliterator.SIZED).bitwiseOr(Spliterator.SUBSIZED).
			bitwiseOr(Spliterator.CONCURRENT).bitwiseOr(Spliterator.IMMUTABLE).bitwiseOr(Spliterator.DISTINCT).
			bitwiseOr(Spliterator.SORTED).bitwiseOr(NONNULL)
	}

	override tryAdvance(IntConsumer action) {
		if (!hasNext()) {
			return false
		}
		val result = next
		next += step;
		action.accept(result)
		return true
	}

	override trySplit() {
		val stepCount = size()
		// on too few elements, do not split
		if (stepCount <= 1) {
			return null
		}
		// new details of this spliterator after split
		val newStepCount = (stepCount / 2)
		val newEnd = next + (step * (newStepCount - 1))
		
		// calc bounds of returned spliterator
		val otherEnd = end
		val otherStart = newEnd + step // start after the end of this spliterator
		val other = new IntegerRangeSpliterator(otherStart, otherEnd, step)
		
		// shorten range for this spliterator
		end = newEnd
		return other
	}

	override getComparator() {
		val naturalOrder = Comparator.naturalOrder
		if (end > start) {
			naturalOrder
		} else {
			naturalOrder.reversed
		}
	}

	override characteristics() {
		characteristics
	}

	override estimateSize() {
		size()
	}

	override getExactSizeIfKnown() {
		size()
	}

	private def int size() {
		(end - next) / step + 1
	}

	private def boolean hasNext() {
		if (step < 0)
			next >= end
		else
			next <= end
	}
}
