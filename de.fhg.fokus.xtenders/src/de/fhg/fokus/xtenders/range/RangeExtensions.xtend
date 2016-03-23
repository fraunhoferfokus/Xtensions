package de.fhg.fokus.xtenders.range

import de.fhg.fokus.xtenders.optional.IntIntConsumer
import java.util.function.IntConsumer

class RangeExtensions {
	
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
	
	// TODO IntegerRange#intIterator() -> PrimitiveIterator.OfInt
	// TODO ExclusiveRange#intIterator() -> PrimitiveIterator.OfInt
	// TODO same extensions for ExclusiveRange
	// TODO ExclusiveRange#toIntegerRange -> Optional<IntgegerRange>
	// TODO ExclusiveRange#withStep() -> Optional<IntegerRange>
	// TODO #intIterator() -> Iterator.OfInt
}
