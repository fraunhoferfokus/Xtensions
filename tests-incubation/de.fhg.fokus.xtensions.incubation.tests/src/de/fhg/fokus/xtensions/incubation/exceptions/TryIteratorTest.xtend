package de.fhg.fokus.xtensions.incubation.exceptions

import org.junit.Test
import static extension org.junit.Assert.*
import static extension de.fhg.fokus.xtensions.incubation.exceptions.TryIterator.*
import static extension de.fhg.fokus.xtensions.incubation.Util.*

class TryIteratorTest {
	
	////////////
	// tryMap //
	////////////

	@Test(expected = NullPointerException)
	def void testTryMapMapperNull() {
		#[].iterator.tryMap(null)
	}

	@Test(expected = NullPointerException)
	def void testTryMapContextNull() {
		null.tryMap[it]
	}
	
	@Test
	def void testTryMapEmptyIterator() {
		extension val verdict = new Object() {
			var result = true
		}
		val iterator = #[].iterator.tryMap[result = false; it]
		iterator.assertEmptyIterator
		result.assertTrue
	}

	@Test
	def void testTryMapSingleElementSuccess() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val expected = "bar"
		val start = "foo"
		val iterator = #[start].iterator.tryMap[
			count++;
			result = (start === it)
			expected
		]
		iterator.assertNextSuccessfull(expected)
		result.assertTrue
		1.assertEquals(count)
		
		iterator.assertEmptyIterator
	}

	@Test
	def void testTryMapSingleElementEmpty() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val start = "foo"
		val iterator = #[start].iterator.tryMap[
			count++;
			result = (start === it)
			null
		]
		iterator.assertNextEmpty
		result.assertTrue
		1.assertEquals(count)
		
		iterator.assertEmptyIterator
	}

	@Test
	def void testTryMapSingleElementFailure() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val start = "foo"
		val expected = new ArrayIndexOutOfBoundsException
		val iterator = #[start].iterator.tryMap [
			count++;
			result = (start === it)
			throw expected
		]
		iterator.assertNextFailure(expected)
		result.assertTrue
		1.assertEquals(count)
		
		iterator.assertEmptyIterator
	}

	@Test
	def void testTryMapSingleEmptyElement() {
		extension val verdict = new Object() {
			var result = true
		}

		val iterator = #[null].iterator.tryMap [
			result = false
			false
		]
		iterator.assertNextEmpty()
		iterator.assertEmptyIterator
		
		result.assertTrue
	}
	
	@Test
	def void testTryMapThreeElements() {
		extension val verdict = new Object() {
			var count = 0
		}
		val expectedException = new ArrayIndexOutOfBoundsException
		val expectedSuccess = "yippiekayeah"
		val iterator = #[1, 2, 3, null].iterator.tryMap [
			count++;
			switch(it) {
				case 1: throw expectedException
				case 2: null
				case 3: expectedSuccess
			}
		]
		iterator.assertNextFailure(expectedException)
		iterator.assertNextEmpty
		iterator.assertNextSuccessfull(expectedSuccess)
		iterator.assertNextEmpty
		iterator.assertEmptyIterator

		3.assertEquals(count)
	}


	////////////////////
	// tryMapNullable //
	////////////////////

	@Test(expected = NullPointerException)
	def void testTryMapNullableMapperNull() {
		#[].iterator.tryMapNullable(null)
	}

	@Test(expected = NullPointerException)
	def void testTryMapNullableContextNull() {
		null.tryMapNullable[it]
	}
	
	@Test
	def void testTryMapNullableEmptyIterator() {
		extension val verdict = new Object() {
			var result = true
		}
		val iterator = #[].iterator.tryMapNullable[result = false; it]
		iterator.assertEmptyIterator
		result.assertTrue
	}

	@Test
	def void testTryMapNullableSingleElementSuccess() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val expected = "bar"
		val start = "foo"
		val iterator = #[start].iterator.tryMapNullable [
			count++;
			result = (start === it)
			expected
		]
		iterator.assertNextSuccessfull(expected)
		result.assertTrue
		1.assertEquals(count)
		
		iterator.assertEmptyIterator
	}

	@Test
	def void testTryMapNullableSingleElementEmpty() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val start = "foo"
		val iterator = #[start].iterator.tryMapNullable [
			count++;
			result = (start === it)
			null
		]
		iterator.assertNextEmpty
		result.assertTrue
		1.assertEquals(count)
		
		iterator.assertEmptyIterator
	}

	@Test
	def void testTryMapNullableSingleElementFailure() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val start = "foo"
		val expected = new ArrayIndexOutOfBoundsException
		val iterator = #[start].iterator.tryMapNullable [
			count++;
			result = (start === it)
			throw expected
		]
		iterator.assertNextFailure(expected)
		result.assertTrue
		1.assertEquals(count)
		
		iterator.assertEmptyIterator
	}

	@Test
	def void testTryMapNullSingleEmptyElement() {
		extension val verdict = new Object() {
			var result = true
			var count = 0
		}
		val expected = "bla"
		val iterator = #[null].iterator.tryMapNullable [
			result = (it === null)
			count++
			expected
		]
		iterator.assertNextSuccessfull(expected)
		iterator.assertEmptyIterator
		
		result.assertTrue
	}
	
	@Test
	def void testTryMapNullableThreeElements() {
		extension val verdict = new Object() {
			var count = 0
		}
		val expectedException = new ArrayIndexOutOfBoundsException
		val expectedSuccess1 = "yippiekayeah"
		val expectedSuccess2 = "shoo"
		val iterator = #[1, 2, 3, null].iterator.tryMapNullable [
			count++;
			if(it === null) {
				return expectedSuccess2
			} 
			switch(it) {
				case 1: throw expectedException
				case 2: null
				case 3: expectedSuccess1
			}
		]
		iterator.assertNextFailure(expectedException)
		iterator.assertNextEmpty
		iterator.assertNextSuccessfull(expectedSuccess1)
		iterator.assertNextSuccessfull(expectedSuccess2)
		iterator.assertEmptyIterator

		4.assertEquals(count)
	}

	
	///////////////
	// tryFilter //
	///////////////

	@Test(expected = NullPointerException)
	def void testTryFilterIteratorNull() {
		null.tryFilter[true]
	}

	@Test(expected = NullPointerException)
	def void testTryFilterPredicateNull() {
		#["foo"].iterator.tryFilter(null)
	}
	
	@Test
	def void testTryFilterEmptyIterator() {
		extension val verdict = new Object() {
			var result = true
		}
		val iterator = #[].iterator.tryFilter [
			result = false
			true
		]
		iterator.assertEmptyIterator
		result.assertTrue
	}

	@Test
	def void testTryFilterOneElementFilterOut() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val element = "bla"
		val iterator = #[element].iterator.tryFilter [
			result = (it === element)
			count++
			false
		]
		iterator.assertEmptyIterator
		result.assertTrue
		1.assertEquals(count)
	}
	
	@Test
	def void testTryFilterOneElementNotFiltered() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val element = "bla"
		val iterator = #[element].iterator.tryFilter [
			result = (it === element)
			count++
			true
		]
		iterator.assertNextSuccessfull(element)
		iterator.assertEmptyIterator
		result.assertTrue
		1.assertEquals(count)
	}
	
	@Test
	def void testTryFilterOneElementFilterException() {
		extension val verdict = new Object() {
			var result = false
		}
		val element = "bla"
		val exception = new IllegalStateException
		val iterator = #[element].iterator.tryFilter [
			result = true
			throw exception
		]
		iterator.assertNextFailure(exception)
		iterator.assertEmptyIterator
		result.assertTrue
	}
	
	@Test
	def void testTryFilterOneEmptyElementNotFiltered() {
		extension val verdict = new Object() {
			var result = true
		}
		val iterator = #[null].iterator.tryFilter [
			result = false
			false
		]
		iterator.assertNextEmpty
		iterator.assertEmptyIterator
		result.assertTrue
	}

	@Test
	def void testTryFilterThreeElements() {
		extension val verdict = new Object() {
			var result = true
		}
		val exception = new IllegalStateException
		val Integer expected = 4
		val iterator = #[null,2,3,expected].iterator.tryFilter [
			switch(it) {
				case null: {
					// empty case should not be filtered
					result = false
					false	
				}
				case 2: throw exception
				case 3: false
				case 4: true
			}
		]
		iterator.assertNextEmpty
		iterator.assertNextFailure(exception)
		iterator.assertNextSuccessfull(expected)
		iterator.assertEmptyIterator
		result.assertTrue
	}

	///////////////////
	// tryFilterNull //
	///////////////////

	@Test(expected = NullPointerException)
	def void testTryFilterIteratorNullable() {
		null.tryFilterNullable[true]
	}

	@Test(expected = NullPointerException)
	def void testTryFilterNullablePredicateNull() {
		#["foo"].iterator.tryFilterNullable(null)
	}
	
	@Test
	def void testTryFilterNullableEmptyIterator() {
		extension val verdict = new Object() {
			var result = true
		}
		val iterator = #[].iterator.tryFilterNullable [
			result = false
			true
		]
		iterator.assertEmptyIterator
		result.assertTrue
	}

	@Test
	def void testTryFilterNullableOneElementFilterOut() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val element = "bla"
		val iterator = #[element].iterator.tryFilterNullable [
			result = (it === element)
			count++
			false
		]
		iterator.assertEmptyIterator
		result.assertTrue
		1.assertEquals(count)
	}
	
	@Test
	def void testTryFilterNullableOneElementNotFiltered() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val element = "bla"
		val iterator = #[element].iterator.tryFilterNullable [
			result = (it === element)
			count++
			true
		]
		iterator.assertNextSuccessfull(element)
		iterator.assertEmptyIterator
		result.assertTrue
		1.assertEquals(count)
	}
	
	@Test
	def void testTryFilterNullableOneElementFilterException() {
		extension val verdict = new Object() {
			var result = false
		}
		val element = "bla"
		val exception = new IllegalStateException
		val iterator = #[element].iterator.tryFilterNullable [
			result = true
			throw exception
		]
		iterator.assertNextFailure(exception)
		iterator.assertEmptyIterator
		result.assertTrue
	}
	
	@Test
	def void testTryFilterNullableOneEmptyElementNotFiltered() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val iterator = #[null].iterator.tryFilterNullable [
			result = (it === null)
			count++
			true
		]
		iterator.assertNextEmpty
		iterator.assertEmptyIterator
		1.assertEquals(count)
		result.assertTrue
	}
	
	@Test
	def void testTryFilterNullableOneEmptyElementFiltered() {
		extension val verdict = new Object() {
			var result = false
			var count = 0
		}
		val iterator = #[null].iterator.tryFilterNullable [
			result = (it === null)
			count++
			false
		]
		iterator.assertEmptyIterator
		1.assertEquals(count)
		result.assertTrue
	}

	@Test
	def void testTryFilterNullableThreeElements() {
		extension val verdict = new Object() {
			var result = true
		}
		val exception = new IllegalStateException
		val Integer expected = 4
		val iterator = #[null,2,3,expected].iterator.tryFilterNullable [
			switch(it) {
				case null: true
				case 2: throw exception
				case 3: false
				case 4: true
			}
		]
		iterator.assertNextEmpty
		iterator.assertNextFailure(exception)
		iterator.assertNextSuccessfull(expected)
		iterator.assertEmptyIterator
		result.assertTrue
	}

	//TODO: findFirstSuccess
	//TODO: findFirstSuccess(FailureStrategy)
	//TODO: filterOutFailure
	//TODO: filterOutEmpty
	//TODO: tryRecoverFailure((Throwable)=>T)
	//TODO: tryRecoverFailure(Class<X>,(X)=>T)
	//TODO: filterSuccess(Class<X>)
	//TODO: tryFilterSuccess(Predicate<X>)
	//TODO: tryMapSuccess((T)=>Y)
	//TODO: tryFlatMapSuccess
	//TODO: tryMapNullable
	//TODO: toListSkipEmpty
	//TODO: toSetSkipEmpty
	//TODO: collectSuccess
	//TODO: forEachSuccess
	//TODO: forEach
	

	//////////
	// util //
	//////////


	private static def <T> void assertNextSuccessfull(TryIterator<T> iterator, T expected) {
		iterator.hasNext.assertTrue
		val next = iterator.next
		next.assertNotNull
		val outcome = next.assertIsInstanceOf(Try.Success)
		outcome.get.assertSame(expected)
	}

	private static def <T> void assertNextEmpty(TryIterator<T> iterator) {
		iterator.hasNext.assertTrue
		val next = iterator.next
		next.assertNotNull
		next.assertIsInstanceOf(Try.Empty)
	}

	private static def <T> void assertNextFailure(TryIterator<T> iterator, Throwable expected) {
		iterator.hasNext.assertTrue
		val next = iterator.next
		next.assertNotNull
		val outcome = next.assertIsInstanceOf(Try.Failure)
		outcome.get.assertSame(expected)
	}
}