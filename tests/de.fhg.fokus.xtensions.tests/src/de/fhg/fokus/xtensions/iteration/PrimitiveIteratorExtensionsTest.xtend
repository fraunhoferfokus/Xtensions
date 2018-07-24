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
	
	////////////////////////////////////////
	// summarize(PrimitiveIterator.OfInt) //
	////////////////////////////////////////
	
	@Test(expected = NullPointerException) def void testSummarizeNull() {
		val OfInt i = null
		i.summarize
	}
	
	@Test def void testSummarizeNoElement() {
		val OfInt iter = new OfInt {
			override nextInt() {
				throw new NoSuchElementException
			}
			
			override hasNext() {
				false
			}
		}
		val summary =  iter.summarize
		assertEquals(0, summary.sum)
		assertEquals(0, summary.count)
		assertEquals(0.0d, summary.average,0.0d)
		assertEquals(Integer.MIN_VALUE, summary.max)
		assertEquals(Integer.MAX_VALUE, summary.min)
	}
	
	@Test def void testSummarizeSingleElement() {
		val expected = 42
		val OfInt iter = new OfInt {
			var read = false
			override nextInt() {
				if(read) {
					throw new NoSuchElementException
				}
				read = true
				expected
			}
			override hasNext() {
				!read
			}
		}
		val summary =  iter.summarize
		assertEquals(expected, summary.sum)
		assertEquals(1, summary.count)
		assertEquals(expected as double, summary.average,0.0d)
		assertEquals(expected, summary.max)
		assertEquals(expected, summary.min)
	}
	
	@Test def void testSummarizeMultipleElements() {
		val expectedVals = #[2,5,3]
		val OfInt iter = new OfInt {
			var read = 0
			override nextInt() {
				if(read == expectedVals.size) {
					throw new NoSuchElementException
				}
				val result = expectedVals.get(read)
				read++
				result
			}
			override hasNext() {
				read < expectedVals.size
			}
		}
		val summary =  iter.summarize
		assertEquals(10, summary.sum)
		assertEquals(expectedVals.size, summary.count)
		assertEquals(3.33d, summary.average,0.01d)
		assertEquals(expectedVals.max, summary.max)
		assertEquals(expectedVals.min, summary.min)
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
	
	/////////////////////////////////////////
	// summarize(PrimitiveIterator.OfLong) //
	/////////////////////////////////////////
	
	@Test(expected = NullPointerException) def void testSummarizeOfLongNull() {
		val OfLong i = null
		i.summarize
	}
	
	@Test def void testSummarizeOfLongNoElement() {
		val OfLong iter = new OfLong {
			override nextLong() {
				throw new NoSuchElementException
			}
			
			override hasNext() {
				false
			}
		}
		val summary =  iter.summarize
		assertEquals(0L, summary.sum)
		assertEquals(0L, summary.count)
		assertEquals(0.0d, summary.average,0.0d)
		assertEquals(Long.MIN_VALUE, summary.max)
		assertEquals(Long.MAX_VALUE, summary.min)
	}
	
	@Test def void testSummarizeOfLongSingleElement() {
		val expected = 42L
		val iter = new OfLong {
			var read = false
			override nextLong() {
				if(read) {
					throw new NoSuchElementException
				}
				read = true
				expected
			}
			override hasNext() {
				!read
			}
		}
		val summary =  iter.summarize
		assertEquals(expected, summary.sum)
		assertEquals(1L, summary.count)
		assertEquals(expected as double, summary.average,0.0d)
		assertEquals(expected, summary.max)
		assertEquals(expected, summary.min)
	}
	
	@Test def void testSummarizeOfLongMultipleElements() {
		val expectedVals = #[2L,5L,3L]
		val iter = new OfLong {
			var read = 0
			override nextLong() {
				if(read == expectedVals.size) {
					throw new NoSuchElementException
				}
				val result = expectedVals.get(read)
				read++
				result
			}
			override hasNext() {
				read < expectedVals.size
			}
		}
		val summary =  iter.summarize
		assertEquals(10, summary.sum)
		assertEquals(expectedVals.size, summary.count)
		assertEquals(3.33d, summary.average,0.01d)
		assertEquals(expectedVals.max, summary.max)
		assertEquals(expectedVals.min, summary.min)
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
	
	/////////////////////////////////////////
	// summarize(PrimitiveIterator.OfDouble) //
	/////////////////////////////////////////
	
	@Test(expected = NullPointerException) def void testSummarizeOfDoubleNull() {
		val OfDouble i = null
		i.summarize
	}
	
	@Test def void testSummarizeOfDoubleElement() {
		val iter = new OfDouble {
			override nextDouble() {
				throw new NoSuchElementException
			}
			
			override hasNext() {
				false
			}
		}
		val summary =  iter.summarize
		assertEquals(0.0d, summary.sum, 0.0d)
		assertEquals(0L, summary.count)
		assertEquals(0.0d, summary.average,0.0d)
		assertEquals(Double.NEGATIVE_INFINITY , summary.max, 0.0d)
		assertEquals(Double.POSITIVE_INFINITY, summary.min, 0.0d)
	}
	
	@Test def void testSummarizeOfDoubleSingleElement() {
		val expected = 42.0d
		val iter = new OfDouble {
			var read = false
			override nextDouble() {
				if(read) {
					throw new NoSuchElementException
				}
				read = true
				expected
			}
			override hasNext() {
				!read
			}
		}
		val summary =  iter.summarize
		assertEquals(expected, summary.sum, 0.0d)
		assertEquals(1L, summary.count)
		assertEquals(expected as double, summary.average,0.0d)
		assertEquals(expected, summary.max, 0.0d)
		assertEquals(expected, summary.min, 0.0d)
	}
	
	@Test def void testSummarizeOfDoubleMultipleElements() {
		val expectedVals = #[2.0d,5.0d,3.0d]
		val iter = new OfDouble {
			var read = 0
			override nextDouble() {
				if(read == expectedVals.size) {
					throw new NoSuchElementException
				}
				val result = expectedVals.get(read)
				read++
				result
			}
			override hasNext() {
				read < expectedVals.size
			}
		}
		val summary =  iter.summarize
		assertEquals(10.0d, summary.sum, 0.01d)
		assertEquals(expectedVals.size, summary.count)
		assertEquals(3.33d, summary.average, 0.01d)
		assertEquals(expectedVals.max, summary.max, 0.01d)
		assertEquals(expectedVals.min, summary.min, 0.01d)
	}
}