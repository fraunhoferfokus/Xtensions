package de.fhg.fokus.xtensions.iteration

import org.junit.Test
import static org.junit.Assert.*
import java.util.PrimitiveIterator.OfInt
import static extension de.fhg.fokus.xtensions.iteration.PrimitiveIteratorExtensions.*
import java.util.NoSuchElementException
import java.util.PrimitiveIterator.OfLong
import java.util.PrimitiveIterator.OfDouble

class PrimitiveIteratorExtensionsTest {
	
	/////////////////////////////////////
	// stream(PrimitiveIterator.OfInt) //
	/////////////////////////////////////
	
	@Test def void testStreamIteratorOfInt() {
		val expected = #[0,900, Integer.MAX_VALUE, -600]
		val wrapped = expected.iterator
		val OfInt iterator = new OfInt() {
			override nextInt() {
				wrapped.next
			}
			override hasNext() {
				wrapped.hasNext
			}
		}
		val result = iterator.streamRemaining.toArray
		assertArrayEquals(expected, result)
	}
	
	@Test def void testStreamIteratorEmptyOfInt() {
		val OfInt iterator = new OfInt() {
			override nextInt() {
				throw new NoSuchElementException
			}
			override hasNext() {
				false
			}
		}
		val result = iterator.streamRemaining.toArray
		assertEquals(0, result.length)
	}
	
	/////////////////////////////////////////////
	// parallelStream(PrimitiveIterator.OfInt) //
	/////////////////////////////////////////////
	
	@Test def void testParallelStreamIteratorOfInt() {
		val expected = #[0,900, Integer.MAX_VALUE, -600]
		val wrapped = expected.iterator
		val OfInt iterator = new OfInt() {
			override nextInt() {
				wrapped.next
			}
			override hasNext() {
				wrapped.hasNext
			}
		}
		val result = iterator.parallelStreamRemaining.toArray
		assertArrayEquals(expected, result)
	}
	
	@Test def void testParallelStreamIteratorEmptyOfInt() {
		val OfInt iterator = new OfInt() {
			override nextInt() {
				throw new NoSuchElementException
			}
			override hasNext() {
				false
			}
		}
		val result = iterator.parallelStreamRemaining.toArray
		assertEquals(0, result.length)
	}
	
	//////////////////////////////////////
	// stream(PrimitiveIterator.OfLong) //
	//////////////////////////////////////
	
	@Test def void testStreamIteratorOfLong() {
		val expected = #[0L,600_000L, Long.MIN_VALUE, -600L]
		val wrapped = expected.iterator
		val OfLong iterator = new OfLong() {
			override nextLong() {
				wrapped.next
			}
			override hasNext() {
				wrapped.hasNext
			}
		}
		val result = iterator.streamRemaining.toArray
		assertArrayEquals(expected, result)
	}
	
	@Test def void testStreamIteratorEmptyOfLong() {
		val OfLong iterator = new OfLong() {
			override nextLong() {
				throw new NoSuchElementException
			}
			override hasNext() {
				false
			}
		}
		val result = iterator.streamRemaining.toArray
		assertEquals(0, result.length)
	}
	
	
	//////////////////////////////////////////////
	// parallelStream(PrimitiveIterator.OfLong) //
	//////////////////////////////////////////////
	
	@Test def void testParallelStreamIteratorOfLong() {
		val expected = #[0L,600_000L, Long.MIN_VALUE, -600L]
		val wrapped = expected.iterator
		val OfLong iterator = new OfLong() {
			override nextLong() {
				wrapped.next
			}
			override hasNext() {
				wrapped.hasNext
			}
		}
		val result = iterator.parallelStreamRemaining.toArray
		assertArrayEquals(expected, result)
	}
	
	@Test def void testParallelStreamIteratorEmptyOfLong() {
		val OfLong iterator = new OfLong() {
			override nextLong() {
				throw new NoSuchElementException
			}
			override hasNext() {
				false
			}
		}
		val result = iterator.parallelStreamRemaining.toArray
		assertEquals(0, result.length)
	}
	
	////////////////////////////////////////
	// stream(PrimitiveIterator.OfDouble) //
	////////////////////////////////////////
	
	@Test def void testStreamIteratorOfDouble() {
		val expected = #[0.0d,Double.NaN, 3e-6d, Double.MAX_VALUE]
		val wrapped = expected.iterator
		val OfDouble iterator = new OfDouble() {
			override nextDouble() {
				wrapped.next
			}
			override hasNext() {
				wrapped.hasNext
			}
		}
		val result = iterator.streamRemaining.toArray
		assertArrayEquals(expected, result, 1e-7d)
	}
	
	@Test def void testStreamIteratorEmptyOfDouble() {
		val OfDouble iterator = new OfDouble() {
			override nextDouble() {
				throw new NoSuchElementException
			}
			override hasNext() {
				false
			}
		}
		val result = iterator.streamRemaining.toArray
		assertEquals(0, result.length)
	}
	
	////////////////////////////////////////////////
	// parallelStream(PrimitiveIterator.OfDouble) //
	////////////////////////////////////////////////
	
	@Test def void testParallelStreamIteratorOfDouble() {
		val expected = #[0.0d,Double.NaN, 3e-6d, Double.MAX_VALUE]
		val wrapped = expected.iterator
		val OfDouble iterator = new OfDouble() {
			override nextDouble() {
				wrapped.next
			}
			override hasNext() {
				wrapped.hasNext
			}
		}
		val result = iterator.parallelStreamRemaining.toArray
		assertArrayEquals(expected, result, 1e-7d)
	}
	
	@Test def void testParallelStreamIteratorEmptyOfDouble() {
		val OfDouble iterator = new OfDouble() {
			override nextDouble() {
				throw new NoSuchElementException
			}
			override hasNext() {
				false
			}
		}
		val result = iterator.parallelStreamRemaining.toArray
		assertEquals(0, result.length)
	}
}