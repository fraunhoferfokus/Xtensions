package de.fhg.fokus.xtensions.range

import org.junit.Test
import static org.junit.Assert.*
import static extension de.fhg.fokus.xtensions.range.RangeExtensions.*
import java.util.function.IntConsumer
import java.util.List

class RangeExtensionTests {
	
	////////////////
	// forEachInt //
	////////////////
	
	@Test def void forEachIntSingleValue() {
		val list = newArrayList
		val IntConsumer agg = [list.add(it)]
		(4..4).forEachInt(agg)
		assertEquals(#[4], list)
	}
	
	@Test def void forEachIntMulitValues() {
		val list = newArrayList
		val IntConsumer agg = [list.add(it)]
		(4..7).forEachInt(agg)
		assertEquals(#[4,5,6,7], list)
	}
	
	@Test def void forEachIntMultiValuesBackwards() {
		val list = newArrayList
		val IntConsumer agg = [list.add(it)]
		(7..4).forEachInt(agg)
		assertEquals(#[7,6,5,4], list)
	}
	
	@Test def void forEachIntStepMulitValues() {
		val list = newArrayList
		val IntConsumer agg = [list.add(it)]
		(4..8).withStep(2).forEachInt(agg)
		assertEquals(#[4,6,8], list)
	}
	
	@Test def void forEachIntStepMulitValuesOverhang() {
		val list = newArrayList
		val IntConsumer agg = [list.add(it)]
		(4..9).withStep(2).forEachInt(agg)
		assertEquals(#[4,6,8], list)
	} 
	
	@Test def void forEachIntBackwardsMulitValues() {
		val list = newArrayList
		val IntConsumer agg = [list.add(it)]
		(7..4).forEachInt(agg)
		assertEquals(#[7,6,5,4], list)
	}
	
	@Test def void forEachIntBackwardsStepMulitValues() {
		val list = newArrayList
		val IntConsumer agg = [list.add(it)]
		(8..4).withStep(-2).forEachInt(agg)
		assertEquals(#[8,6,4], list)
	}
	
	@Test def void forEachIntBackwardStepMulitValuesOverhang() {
		val list = newArrayList
		val IntConsumer agg = [list.add(it)]
		(9..4).withStep(-2).forEachInt(agg)
		assertEquals(#[9,7,5], list)
	}
	
		
	//////////////////////
	// forEachInt index //
	//////////////////////
	
	@Test def void forEachIntIndexSingleValue() {
		val list = newArrayList
		val IntIntConsumer agg = [i,index|list.add(i -> index)]
		(4..4).forEachInt(agg)
		assertEquals(#[4->0], list)
	}
	
	@Test def void forEachIntIndexMulitValues() {
		val List<Pair<Integer,Integer>> list = newArrayList()
		(4..7).forEachInt[ i, index|
			list.add(i -> index)
		]
		assertEquals(#[4->0, 5->1, 6->2, 7->3], list)
	}
	
	@Test def void forEachIntIndexMulitValuesBackwards() {
		val List<Pair<Integer,Integer>> list = newArrayList()
		(7..4).forEachInt[ i, index|
			list.add(i -> index)
		]
		assertEquals(#[7->0, 6->1, 5->2, 4->3], list)
	}
	
	@Test def void forEachIntIndexStepMulitValues() {
		val list = newArrayList
		val IntIntConsumer agg = [i,index|list.add(i -> index)]
		(4..8).withStep(2).forEachInt(agg)
		assertEquals(#[4->0, 6->1, 8->2], list)
	}
	
	@Test def void forEachIntIndexStepMulitValuesOverhang() {
		val list = newArrayList
		val IntIntConsumer agg = [i,index|list.add(i -> index)]
		(4..9).withStep(2).forEachInt(agg)
		assertEquals(#[4->0, 6->1, 8->2], list)
	} 
	
	@Test def void forEachIntIndexBackwardsMulitValues() {
		val list = newArrayList
		val IntIntConsumer agg = [i,index|list.add(i -> index)]
		(7..4).forEachInt(agg)
		assertEquals(#[7->0, 6->1, 5->2, 4->3], list)
	}
	
	@Test def void forEachIntIndexBackwardsStepMulitValues() {
		val list = newArrayList
		val IntIntConsumer agg = [i,index|list.add(i -> index)]
		(8..4).withStep(-2).forEachInt(agg)
		assertEquals(#[8->0, 6->1, 4->2], list)
	}
	
	@Test def void forEachIntIndexBackwardStepMulitValuesOverhang() {
		val list = newArrayList
		val IntIntConsumer agg = [i,index|list.add(i -> index)]
		(9..4).withStep(-2).forEachInt(agg)
		assertEquals(#[9->0, 7->1, 5->2], list)
	}
	
	//////////////
	// stream() //
	//////////////
	
	@Test def void singeElementStream() {
		val result = (1..1).stream().toArray
		assertNotNull(result)
		val int[] expected = #[1]
		assertArrayEquals(expected,result)
	}
	
	
	@Test def void simpleStreamStepOne() {
		val result = (1..4).stream().toArray
		assertNotNull(result)
		val int[] expected = #[1,2,3,4]
		assertArrayEquals(expected,result)
	}
	
	
	@Test def void simpleStreamWithStep() {
		val result = (1..5).withStep(2).stream().toArray
		assertNotNull(result)
		val int[] expected = #[1,3,5]
		assertArrayEquals(expected,result)
	}
	
	
	@Test def void simpleStreamWithStepAndEndOverhang() {
		val result = (1..6).withStep(2).stream().toArray
		assertNotNull(result)
		val int[] expected = #[1,3,5]
		assertArrayEquals(expected,result)
	}
	
	
	@Test def void simpleBackwardStreamStepOne() {
		val result = (4..1).stream().toArray
		assertNotNull(result)
		val int[] expected = #[4,3,2,1]
		assertArrayEquals(expected,result)
	}
	
	
	@Test def void simpleBackwardStreamWithStep() {
		val result = (5..1).withStep(-2).stream().toArray
		assertNotNull(result)
		val int[] expected = #[5,3,1]
		assertArrayEquals(expected,result)
	}
	
	
	@Test def void simpleBackwardStreamWithStepAndEndOverhang() {
		val result = (6..1).withStep(-2).stream().toArray
		assertNotNull(result)
		val int[] expected = #[6,4,2]
		assertArrayEquals(expected,result)
	}
	
	// TODO check range in negative range e.g. (-3..-5)
	
}