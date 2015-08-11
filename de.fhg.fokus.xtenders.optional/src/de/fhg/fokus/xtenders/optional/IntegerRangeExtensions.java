package de.fhg.fokus.xtenders.optional;

import java.util.function.IntConsumer;

import org.eclipse.xtext.xbase.lib.IntegerRange;

public class IntegerRangeExtensions {

	public static void forEachInt(IntegerRange r, IntConsumer consumer) {
		final int start = r.getStart();
		final int end = r.getEnd();
		final int step = r.getStep();
		if (step > 0) {
			for (int i = start; i <= end; i += step) {
				consumer.accept(i);
			}
		} else {
			for(int i = start; i >= end; i += step) {
				consumer.accept(i);
			}
		}
	}

	public static void forEachInt(IntegerRange r, IntIntConsumer consumer) {
		final int start = r.getStart();
		final int end = r.getEnd();
		final int step = r.getStep();
		int index = 0;
		if (step > 0) {
			for (int i = start; i <= end; i += step) {
				consumer.accept(i, index++);
			}
		} else {
			for(int i = start; i >= end; i += step) {
				consumer.accept(i, index++);
			}
		}
	}

}