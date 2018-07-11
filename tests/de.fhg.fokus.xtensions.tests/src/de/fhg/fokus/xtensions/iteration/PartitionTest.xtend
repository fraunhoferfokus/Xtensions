package de.fhg.fokus.xtensions.iteration

import org.junit.Test
import static org.junit.Assert.*
import static extension de.fhg.fokus.xtensions.iteration.Partition.*
import java.util.Map
import java.util.Set
import java.util.AbstractMap
import de.fhg.fokus.xtensions.Util
import java.util.NoSuchElementException

class PartitionTest {
	
	@Test 
	def testAsPair() {
		val expectedSelected = "expected"
		val expectedRejected = "rejected"
		val partition = new Partition() {
			
			override getSelected() {
				expectedSelected
			}
			
			override getRejected() {
				expectedRejected
			}
			
		}
		val pair = partition.asPair
		assertSame(expectedSelected, pair.key)
		assertSame(expectedRejected, pair.value)
	}
	
	@Test(expected = NullPointerException)
	def testAsMapOnNull() {
		val Partition<String,String> partition = null;
		partition.asMap
		fail()
	}
	
	@Test
	def testAsMap() {
		val expectedSelected = "expected"
		val expectedRejected = "rejected"
		val partition = new Partition<String,String>() {
			
			override getSelected() {
				expectedSelected
			}
			
			override getRejected() {
				expectedRejected
			}
			
		}
		val Map<Boolean, String> map = partition.asMap
		assertSame(expectedSelected, map.get(true))
		assertSame(expectedRejected, map.get(false))
		
		val Set<Map.Entry<Boolean,String>> expectedSet = newHashSet(
			new AbstractMap.SimpleEntry(true, expectedSelected),
			new AbstractMap.SimpleEntry(false, expectedRejected)
		)
		
		Util.expectException(NullPointerException) [
			map.get(null)
		]
		
		Util.expectException(NoSuchElementException) [
			map.get("foo")
		]
		
		assertEquals(expectedSet, map.entrySet)
	}
	
	@Test
	def void testAsPartition() {
		val expectedSelcted = "bar"
		val expectedRejected = "foo"
		val map = newHashMap(true -> expectedSelcted, false -> expectedRejected)
		val partition = map.asPartition
		assertNotNull(partition)
		assertSame(expectedSelcted, partition.selected)
		assertSame(expectedRejected, partition.rejected)
	}
	
	@Test
	def testAsMapAsPartition() {
		val expectedSelected = "expected"
		val expectedRejected = "rejected"
		val partition = new Partition<String,String>() {
			
			override getSelected() {
				expectedSelected
			}
			
			override getRejected() {
				expectedRejected
			}
			
		}
		val partition2 = partition.asMap.asPartition
		assertEquals(partition, partition2)
	}
	
	@Test
	def void testAsPartitionAsMap() {
		val expectedSelcted = "bar"
		val expectedRejected = "foo"
		val map = newHashMap(true -> expectedSelcted, false -> expectedRejected)
		val map2 = map.asPartition.asMap
		assertEquals(map, map2)
	}
}