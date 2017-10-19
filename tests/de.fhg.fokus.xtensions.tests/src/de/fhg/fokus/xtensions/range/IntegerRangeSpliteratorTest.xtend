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
package de.fhg.fokus.xtensions.range

import org.junit.Test
import static org.junit.Assert.*
import java.util.function.IntConsumer
import de.fhg.fokus.xtensions.range.IntegerRangeSpliterator
import java.util.Spliterator.OfInt
import java.util.List

class IntegerRangeSpliteratorTest {

	// TODO this file may include multiple checks for same situations

	// /////////////
	// Advancing //
	// /////////////
	
	@Test def void trySplitFail() {
		val spliterator = new IntegerRangeSpliterator(5..5)
		val other = spliterator.trySplit
		assertNull(other)
	}
	
	@Test def void trySplitTwoElements() {
		val spliterator = new IntegerRangeSpliterator(5..6)
		val other = spliterator.trySplit
		
		assertEquals(1, spliterator.exactSizeIfKnown)
		assertEquals(1, other.exactSizeIfKnown)
		
		val int[] s1result = #[0]
		val IntConsumer c = [ s1result.set(0,it) ]
		var advanced = spliterator.tryAdvance(c)
		assertTrue(advanced)
		assertEquals(5, s1result.get(0))
		val IntConsumer noCall = [fail()]
		advanced = spliterator.tryAdvance(noCall)
		assertFalse(advanced)
		
		advanced = other.tryAdvance(c)
		assertTrue(advanced)
		assertEquals(6, s1result.get(0))
		advanced = other.tryAdvance(noCall)
		assertFalse(advanced)
	}
	
	@Test def void trySplitWithStep() {
		val spliterator = new IntegerRangeSpliterator((3..9).withStep(2))
		val other = spliterator.trySplit
		
		assertEquals(2, spliterator.exactSizeIfKnown)
		assertEquals(2, other.exactSizeIfKnown)
		
		spliterator.checkElements(#[3,5])
		other.checkElements(#[7,9])
	}
	
	@Test def void trySplitUneven() {
		val spliterator = new IntegerRangeSpliterator(10..12)
		val other = spliterator.trySplit
		
		assertEquals(1, spliterator.exactSizeIfKnown)
		assertEquals(2, other.exactSizeIfKnown)
		
		spliterator.checkElements(#[10])
		other.checkElements(#[11,12])
	}
	
	@Test def void trySplitUnevenWithStep() {
		val spliterator = new IntegerRangeSpliterator((8..20).withStep(3))
		val other = spliterator.trySplit
		
		assertEquals(2, spliterator.exactSizeIfKnown)
		assertEquals(3, other.exactSizeIfKnown)
		
		spliterator.checkElements(#[8,11])
		other.checkElements(#[14,17,20])
	}
	
	@Test def void trySplitWithStepAndOverhang() {
		val spliterator = new IntegerRangeSpliterator((3..10).withStep(2))
		val other = spliterator.trySplit
		
		assertEquals(2, spliterator.exactSizeIfKnown)
		assertEquals(2, other.exactSizeIfKnown)
		
		spliterator.checkElements(#[3,5])
		other.checkElements(#[7,9])
	}
	
	def checkElements(OfInt spliterator, List<Integer> expected) {
		val List<Integer> actual = newArrayList
		val IntConsumer sink = [actual.add(it)]
		spliterator.forEachRemaining(sink)
		assertEquals(expected, actual)
		
		val IntConsumer doFail = [fail()]
		val advanced = spliterator.tryAdvance(doFail)
		assertFalse(advanced)
	}
	
	@Test def void trySplitBackwardTwoElements() {
		val spliterator = new IntegerRangeSpliterator((6..5).withStep(-1))
		val other = spliterator.trySplit
		
		assertEquals(1, spliterator.exactSizeIfKnown)
		assertEquals(1, other.exactSizeIfKnown)
		
		val int[] s1result = #[0]
		val IntConsumer c = [ s1result.set(0,it) ]
		var advanced = spliterator.tryAdvance(c)
		assertTrue(advanced)
		assertEquals(6, s1result.get(0))
		val IntConsumer noCall = [fail()]
		advanced = spliterator.tryAdvance(noCall)
		assertFalse(advanced)
		
		advanced = other.tryAdvance(c)
		assertTrue(advanced)
		assertEquals(5, s1result.get(0))
		advanced = other.tryAdvance(noCall)
		assertFalse(advanced)
	}
	
	@Test def void trySplitWithStepBackwards() {
		val spliterator = new IntegerRangeSpliterator((9..3).withStep(-2))
		val other = spliterator.trySplit
		
		assertEquals(2, spliterator.exactSizeIfKnown)
		assertEquals(2, other.exactSizeIfKnown)
		
		spliterator.checkElements(#[9,7])
		other.checkElements(#[5,3])
	}
	
	@Test def void trySplitWithStepBackwardsWithOverhang() {
		val spliterator = new IntegerRangeSpliterator((9..2).withStep(-2))
		val other = spliterator.trySplit
		
		assertEquals(2, spliterator.exactSizeIfKnown)
		assertEquals(2, other.exactSizeIfKnown)
		
		spliterator.checkElements(#[9,7])
		other.checkElements(#[5,3])
	}
	
	@Test
	def void testAdvanceOneStep() {
		val range = 0 .. 1
		checkCountingUp(range)
	}

	@Test
	def void testCountTwoSteps() {
		val range = 0 .. 1
		val s = new IntegerRangeSpliterator(range)
		assertEquals(2, s.estimateSize)
	}

	@Test
	def void testAdvanceOneElement() {
		val range = 1 .. 1
		checkCountingUp(range)
	}

	@Test
	def void testCountOneStep() {
		val range = 1 .. 1
		val s = new IntegerRangeSpliterator(range)
		assertEquals(1, s.estimateSize)
	}

	@Test
	def void testAdvanceOneElementZero() {
		val range = 0 .. 0
		checkCountingUp(range)
	}

	@Test
	def void testCountOneZero() {
		val range = 0 .. 0
		val s = new IntegerRangeSpliterator(range)
		assertEquals(1, s.estimateSize)
	}

	@Test
	def void testAdvanceOneStepStartingHigh() {
		val range = 1_000 .. 1_001
		checkCountingUp(range)
	}

	@Test
	def void testAdvanceStartingAndEndingNegative() {
		val range = -5 .. -2
		checkCountingUp(range)
	}

	@Test
	def void testCountStartingingAndEndingNegative() {
		val range = -5 .. -2
		val s = new IntegerRangeSpliterator(range)
		assertEquals(4, s.estimateSize)
	}

	@Test
	def void testCountStartingingAndEndingNegativeSplit() {
		val range = -5 .. -2
		val s = new IntegerRangeSpliterator(range)
		val split = s.trySplit
		assertEquals(4, s.exactSizeIfKnown + split.exactSizeIfKnown)
	}

	@Test
	def void testSplitUnspilittable() {
		val range = 10 .. 10
		val s = new IntegerRangeSpliterator(range)
		val split = s.trySplit
		assertNull(split)
	}

	@Test
	def void testCountStartingingAndEndingNegativeCountDownSplit() {
		val range = -2 .. -5
		val s = new IntegerRangeSpliterator(range)
		val split = s.trySplit
		assertEquals(4, s.exactSizeIfKnown + split.exactSizeIfKnown)
//		val IntConsumer c = [println(it)]
//		split.forEachRemaining(c)
//		s.forEachRemaining(c)
	}

	@Test
	def void testAdvanceNegativeToPositive() {
		val range = -5 .. 2
		checkCountingUp(range)
	}

	@Test
	def void testCountNegativeToPositive() {
		val range = -5 .. 2
		val s = new IntegerRangeSpliterator(range)
		assertEquals(8, s.estimateSize)
	}

	@Test
	def void testAdvanceStepTwoExcludingEnd() {
		val range = (0 .. 7).withStep(2)
		checkCountingUp(range)
	}

	@Test
	def void testCountStepTwoExcludingEnd() {
		val range = (0 .. 7).withStep(2)
		val s = new IntegerRangeSpliterator(range)
		assertEquals(4, s.estimateSize)
	}

	@Test
	def void testAdvanceStepTwoIncludingEnd() {
		val range = (1 .. 5).withStep(2)
		checkCountingUp(range)
	}

	@Test
	def void testCountStepTwoIncludingEnd() {
		val range = (1 .. 5).withStep(2)
		val s = new IntegerRangeSpliterator(range)
		assertEquals(3, s.estimateSize)
	}

	@Test
	def void testCountDown() {
		val range = 1 .. 0
		checkCountingDown(range)
	}

	@Test
	def void testCountRangeDown() {
		val range = (1 .. 0).withStep(-1)
		val s = new IntegerRangeSpliterator(range)
		assertEquals(2, s.estimateSize)
	}

	@Test
	def void testCountRangeDownUneven() {
		val range = (7 .. 0).withStep(-3)
		val s = new IntegerRangeSpliterator(range)
		assertEquals(3, s.estimateSize)
	}

	@Test
	def void testCountRangeDownUnevenSplit() {
		val range = (7 .. 0).withStep(-3)
		val s = new IntegerRangeSpliterator(range)
		val split = s.trySplit;
		assertEquals(3, split.exactSizeIfKnown + s.exactSizeIfKnown)
	}

	@Test
	def void testCountSplitAtZero() {
		val range = (5 .. -5).withStep(-5)
		val s = new IntegerRangeSpliterator(range)
		val split = s.trySplit;
		assertEquals(3, split.exactSizeIfKnown + s.exactSizeIfKnown)
	}

	@Test
	def void testCountSplitInTheMiddle() {
		val range = (0 .. 25).withStep(5)
		val s = new IntegerRangeSpliterator(range)
		val split = s.trySplit;
		assertEquals(6, split.exactSizeIfKnown + s.exactSizeIfKnown)
	}

	@Test
	def void testCountSplitCountDownInTheMiddle() {
		val range = (25 .. 0).withStep(-5)
		val s = new IntegerRangeSpliterator(range)
		val split = s.trySplit;
		assertEquals(6, split.exactSizeIfKnown + s.exactSizeIfKnown)
	}
	
	def void testStepBiggerThanEnd() {
		val range = (5 .. 10).withStep(15)
		val s = new IntegerRangeSpliterator(range)
		val split = s.trySplit
		assertNull(split)
	}

	@Test
	def void testSplitNotInCenter() {
		val range = (1 .. 17).withStep(5)
		val s = new IntegerRangeSpliterator(range)
		val split = s.trySplit;
		assertEquals(4, split.exactSizeIfKnown + s.exactSizeIfKnown)
	}

	def void checkCountingUp(IntegerRange range) {
		val s = new IntegerRangeSpliterator(range)
		for (var i = range.start; i <= range.end; i += range.step) {
			val expected = i
			val IntConsumer c = [assertEquals(expected, it)]
			assertTrue(s.tryAdvance(c))
		}
		val IntConsumer noop = []
		assertFalse(s.tryAdvance(noop))
	}

	def void checkCountingDown(IntegerRange range) {
		val s = new IntegerRangeSpliterator(range)
		for (var i = range.start; i >= range.end; i += range.step) {
			val expected = i
			val IntConsumer c = [assertEquals(expected, it)]
			assertTrue(s.tryAdvance(c))
		}
		val IntConsumer noop = []
		assertFalse(s.tryAdvance(noop))
	}

}