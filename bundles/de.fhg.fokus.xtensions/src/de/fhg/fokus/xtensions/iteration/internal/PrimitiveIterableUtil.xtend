/*******************************************************************************
 * Copyright (c) 2017 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.iteration.internal

import de.fhg.fokus.xtensions.iteration.IntIterable
import de.fhg.fokus.xtensions.iteration.LongIterable
import java.util.NoSuchElementException
import java.util.PrimitiveIterator.OfInt
import java.util.PrimitiveIterator.OfLong
import java.util.function.Consumer
import java.util.function.IntConsumer
import java.util.function.LongConsumer
import java.util.stream.IntStream
import java.util.stream.LongStream
import de.fhg.fokus.xtensions.iteration.DoubleIterable
import java.util.function.DoubleConsumer
import java.util.stream.DoubleStream
import java.util.PrimitiveIterator.OfDouble

/**
 * This is an internal class only to be used within this library.
 */
final class PrimitiveIterableUtil {

	new() {
		throw new IllegalStateException
	}

	public static final IntIterable EMPTY_INTITERABLE = new IntIterable() {

		override OfInt iterator() {
			return EMPTY_INTITERATOR;
		}

		override forEachInt(IntConsumer consumer) {
		}

		override forEach(Consumer<? super Integer> action) {
		}

		override IntStream stream() {
			IntStream.empty()
		}
	};

	public static OfInt EMPTY_INTITERATOR = new OfInt() {

		override hasNext() {
			false
		}

		override nextInt() {
			throw new NoSuchElementException();
		}

		override forEachRemaining(IntConsumer action) {}
	}

	public static final LongIterable EMPTY_LONGITERABLE = new LongIterable() {

		override OfLong iterator() {
			EMPTY_LONGITERATOR
		}

		override forEachLong(LongConsumer consumer) {
		}

		override forEach(Consumer<? super Long> action) {
		}

		override LongStream stream() {
			LongStream.empty()
		}
	}

	public static final OfLong EMPTY_LONGITERATOR = new OfLong() {

		override hasNext() {
			false
		}

		override nextLong() {
			throw new NoSuchElementException()
		}

		override forEachRemaining(LongConsumer action) {}
	};

	public static final OfDouble EMPTY_DOUBLEITERATOR = new OfDouble() {

		override hasNext() {
			false
		}

		override nextDouble() {
			throw new NoSuchElementException();
		}

		override forEachRemaining(DoubleConsumer action) {}
	};

	public static final DoubleIterable EMPTY_DOUBLEITERABLE = new DoubleIterable() {

		override iterator() {
			EMPTY_DOUBLEITERATOR
		}

		override forEachDouble(DoubleConsumer consumer) {}

		override forEach(java.util.function.Consumer<? super Double> action) {}

		override DoubleStream stream() {
			DoubleStream.empty()
		}
	};
}
