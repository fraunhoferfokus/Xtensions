package de.fhg.fokus.xtenders.stream;

import java.util.Objects;
import java.util.Spliterator;
import java.util.function.IntConsumer;

import org.eclipse.xtext.xbase.lib.IntegerRange;

/**
 * Implementation of {@link Spliterator.OfInt} for {@link IntegerRange}.
 * @author Max Bureck
 */
public class IntRangeSpliterator implements Spliterator.OfInt {

	private static final int characteristics = Spliterator.ORDERED | Spliterator.IMMUTABLE | Spliterator.SIZED
			| Spliterator.SUBSIZED | Spliterator.DISTINCT;
	private final int stepSize;
	private final int stepSignum;
	private int next;
	private int fence;

	public IntRangeSpliterator(IntegerRange range) {
		this.stepSize = range.getStep();
		this.stepSignum = Integer.signum(stepSize);
		this.next = range.getStart();
		this.fence = range.getEnd() + stepSignum;
	}

	private IntRangeSpliterator(int stepSize, int stepSignum, int index, int fence) {
		this.stepSize = stepSize;
		this.stepSignum = stepSignum;
		this.next = index;
		this.fence = fence;
	}

	@Override
	public long estimateSize() {
		return getExactSizeIfKnown();
	}

	@Override
	public int characteristics() {
		return characteristics;
	}

	@Override
	public java.util.Spliterator.OfInt trySplit() {
		int lo = next, mid = (lo + fence) / 2;
		int diff = lo - mid;
		// split at multiple of stepSize
		mid += diff % stepSize;
		// if other spliterator would hold no value, return null.
		// otherwise return spliterator from lo to (but excluding) mid.
		// This spliterator shrinks to (and including) mid to this.fence -1
		return (diff / stepSize >= 0) ? null : new IntRangeSpliterator(stepSize, stepSignum, lo, next = mid);
	}

	@Override
	public boolean tryAdvance(IntConsumer action) {
		Objects.requireNonNull(action);
		if (advancePossible()) {
			int value = next;
			next += stepSize;
			action.accept(value);
			return true;
		}
		return false;
	}

	@Override
	public long getExactSizeIfKnown() {
		return (fence - stepSignum - next) / stepSize + 1;

	}

	private boolean advancePossible() {
		return (fence - stepSignum - next) * stepSignum >= 0;
	}

}
