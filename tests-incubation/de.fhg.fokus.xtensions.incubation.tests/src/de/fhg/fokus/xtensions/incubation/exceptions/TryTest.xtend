package de.fhg.fokus.xtensions.incubation.exceptions

import static extension org.junit.Assert.*
import de.fhg.fokus.xtensions.incubation.exceptions.Try
import static de.fhg.fokus.xtensions.incubation.exceptions.Try.*
import org.junit.Test
import static extension de.fhg.fokus.xtensions.incubation.Util.*
import java.util.Optional
import java.util.NoSuchElementException
import java.util.function.Predicate

class TryTest {

	///////////////
	// completed //
	///////////////

	@Test
	def void testCompletedElement() {
		val expected = new Object
		val result = Try.completed(expected)
		val succ = result.assertIsInstanceOf(Try.Success)
		expected.assertSame(succ.get)
	}

	@Test
	def void testCompletedNull() {
		val result = Try.completed(null)
		result.assertIsInstanceOf(Try.Empty)
	}

	
	///////////////////////////
	// completedSuccessfully //
	///////////////////////////

	@Test(expected = NullPointerException)
	def void testCompletedSuccessfullyNull() {
		Try.completedSuccessfully(null)
	}

	@Test
	def void testCompletedSuccessfully() {
		val expected = new Object
		val result = Try.completedSuccessfully(expected)
		val succ = result.assertIsInstanceOf(Try.Success)
		expected.assertSame(succ.get)
	}


	
	////////////////////
	// completedEmpty //
	////////////////////

	@Test
	def void testCompletedEmpty() {
		Try.completedEmpty.assertIsInstanceOf(Try.Empty)
	}

	
	////////////////////////////
	// completedExceptionally //
	////////////////////////////

	@Test(expected = NullPointerException)
	def void testCompletedExceptionallyNull() {
		Try.completedExceptionally(null)
	}

	@Test
	def void testCompletedExceptionally() {
		val e = new ArrayIndexOutOfBoundsException
		val result = Try.completedExceptionally(e)
		val failure = result.assertIsInstanceOf(Try.Failure)
		failure.get.assertSame(e)
	}

	///////////
	// tryCall //
	///////////

	@Test(expected = NullPointerException)
	def void testTryCallMethodNull() {
		Try.tryCall(null)
	}

	@Test
	def void testTryCallMethodProvidesNull() {
		val result = Try.tryCall[null]
		result.assertIsInstanceOf(Try.Empty)
	}

	@Test
	def void testTryCallMethodProvidesElement() {
		val expected = new Object
		val result = Try.tryCall[expected]
		val succ = result.assertIsInstanceOf(Try.Success)
		succ.get.assertSame(expected)
	}

	@Test
	def void testTryCallMethodThrows() {
		val expected = new IllegalStateException
		val result = Try.tryCall[
			throw expected
		]
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertSame(expected)
	}


	/////////////
	// tryWith //
	/////////////

	@Test(expected = NullPointerException)
	def void testTryWithResourceProviderNull() {
		tryWith(null)[]
	}

	@Test(expected = NullPointerException)
	def void testTryWithProviderNull() {
		tryWith([], null)
	}

	@Test
	def void testTryWithProviderNullResource() {
		extension val verdict = new Object() {
			var resourceProviderCalled = false
			var resourceIsNull = false
			var providerCalled = false
		}
		tryWith([resourceProviderCalled = true; null]) [
			providerCalled = true
			resourceIsNull = (it === null)
		]
		resourceProviderCalled.assertTrue
		resourceIsNull.assertTrue
		providerCalled.assertTrue
	}

	@Test
	def void testTryWithProviderResourceClosedOnSuccess() {
		val resource = new AutoCloseable() {
			var closed = false
			var closeCount = 0
			
			override close() throws Exception {
				closed = true
				closeCount++
			}
		}
		extension val verdict = new Object() {
			var sameResource = false
		}
		tryWith([resource]) [
			sameResource = (it === resource)
		]
		resource.closed.assertTrue
		resource.closeCount.assertEquals(1)
		sameResource.assertTrue
	}

	@Test
	def void testTryWithResourceProviderThrowing() {
		extension val verdict = new Object() {
			var providerNotCalled = true
		}
		val expectedException = new IllegalArgumentException
		val result = tryWith([throw expectedException]) [
			providerNotCalled = false
		]
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertSame(expectedException)
		providerNotCalled.assertTrue
	}

	@Test
	def void testTryWithProviderResourceClosedOnThrow() {
		val resource = new AutoCloseable() {
			var closed = false
			var closeCount = 0
			
			override close() throws Exception {
				closed = true
				closeCount++
			}
		}
		val expectedException = new IllegalArgumentException
		val result = tryWith([resource]) [
			throw expectedException
		]
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertSame(expectedException)
		resource.closed.assertTrue
		resource.closeCount.assertEquals(1)
	}

	@Test
	def void testTryWithSuccess() {
		
		val resource = new AutoCloseable() {
			override close() throws Exception {
			}
		}
		val expected = new Object
		val result = tryWith([resource]) [
			expected
		]
		val succ = result.assertIsInstanceOf(Try.Success)
		succ.get.assertSame(expected)
	}

	/////////////
	// tryFlat //
	/////////////

	@Test(expected = NullPointerException)
	def void testTryFlatProviderNull() {
		tryFlat(null)
	}

	@Test
	def void testTryFlatProvidingSuccess() {
		val expected = completedSuccessfully("some result")
		val result = tryFlat [expected]
		result.assertSame(expected)
	}

	@Test
	def void testTryFlatProvidingEmpty() {
		val expected = completedEmpty
		val result = tryFlat [expected]
		result.assertSame(expected)
	}

	@Test
	def void testTryFlatProvidingFailure() {
		val expected = completedExceptionally(new IllegalArgumentException)
		val result = tryFlat [expected]
		result.assertSame(expected)
	}

	@Test
	def void testTryFlatThrowing() {
		val expected = new ArrayIndexOutOfBoundsException
		val result = tryFlat [ throw expected ]
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertSame(expected)
	}


	/////////////////
	// tryOptional //
	/////////////////

	@Test(expected = NullPointerException)
	def void testTryOptionalProviderNull() {
		tryOptional(null)
	}

	@Test
	def void testTryOptionalProvidingNull() {
		val result = tryOptional [null]
		result.assertIsInstanceOf(Try.Empty)
	}

	@Test
	def void testTryOptionalProvidingEmpty() {
		val result = tryOptional [Optional.empty]
		result.assertIsInstanceOf(Try.Empty)
	}

	@Test
	def void testTryOptionalProvidingValue() {
		val expected = "foo"
		val result = tryOptional [Optional.of(expected)]
		val succ = result.assertIsInstanceOf(Try.Success)
		succ.get.assertSame(expected)
	}

	@Test
	def void testTryOptionalThrowing() {
		val expected = new IllegalArgumentException
		val result = tryOptional [ throw expected ]
		val succ = result.assertIsInstanceOf(Try.Failure)
		succ.get.assertSame(expected)
	}

	///////////////////
	// tryCall input //
	///////////////////

	@Test(expected = NullPointerException)
	def void testTryCallInputProviderNull() {
		tryCall(new Object, null)
	}

	@Test
	def void testTryCallInputTestInputPassedOn() {
		val expected = new Object
		extension val verdict = new Object {
			var actual = null
		}
		tryCall(expected) [
			actual = it
			null
		]
		expected.assertSame(actual)
	}

	@Test
	def void testTryCallInputProvidingNull() {
		val result = tryCall(null) [
			null
		]
		result.assertIsInstanceOf(Try.Empty)
	}

	@Test
	def void testTryCallInputProvidingValue() {
		val expected = new Object
		val result = tryCall(null) [
			expected
		]
		result.assertIsInstanceOf(Try.Success).get.assertSame(expected)
	}

	@Test
	def void testTryCallInputThrowing() {
		val expected = new NoSuchElementException
		val result = tryCall(null) [
			throw expected
		]
		result.assertIsInstanceOf(Try.Failure).get.assertSame(expected)
	}
	
	/////////////////
	// upcast(Try) //
	/////////////////
	
	@Test
	def void testUpcastTryNull() {
		val Try<String> t = null
		val Try<CharSequence> result = upcast(t)
		result.assertNull
	}

	@Test
	def void testUpcastTrySuccess() {
		val Try<String> expected = completedSuccessfully("foo")
		val Try<CharSequence> result = upcast(expected)
		expected.assertSame(result)
	}

	@Test
	def void testUpcastTryFailure() {
		val Try<StringBuffer> expected = completedExceptionally(new Exception)
		val Try<CharSequence> result = upcast(expected)
		expected.assertSame(result)
	}

	@Test
	def void testUpcastTryEmpty() {
		val Try<Integer> expected = completedEmpty
		val Try<Number> result = upcast(expected)
		expected.assertSame(result)
	}

	/////////////////////
	// upcast(Success) //
	/////////////////////

	@Test
	def void testUpcastSuccessNull() {
		val Try.Success<String> t = null
		val Try.Success<CharSequence> result = upcast(t)
		result.assertNull
	}

	@Test
	def void testUpcastSuccessSuccess() {
		val Try.Success<String> expected = completedSuccessfully("foo")
		val Try.Success<CharSequence> result = upcast(expected)
		expected.assertSame(result)
	}

	///////////////////
	// upcast(Empty) //
	///////////////////

	@Test
	def void testUpcastEmptyNull() {
		val Try.Empty<String> t = null
		val Try.Empty<CharSequence> result = upcast(t)
		result.assertNull
	}

	@Test
	def void testUpcastEmptySuccess() {
		val Try.Empty<String> expected = completedEmpty
		val Try.Empty<CharSequence> result = upcast(expected)
		expected.assertSame(result)
	}

	/////////////////////
	// upcast(Failure) //
	/////////////////////

	@Test
	def void testUpcastFailureNull() {
		val Try.Failure<String> t = null
		val Try.Failure<CharSequence> result = upcast(t)
		result.assertNull
	}

	@Test
	def void testUpcastFailureSuccess() {
		val Try.Failure<String> expected = completedExceptionally(new RuntimeException)
		val Try.Failure<CharSequence> result = upcast(expected)
		expected.assertSame(result)
	}

	//////////////////
	// ifInstanceOf //
	//////////////////

	@Test
	def void testIsClass() {
		val expected = "Foo"
		val Try.Success<Comparable<?>> succ = completedSuccessfully(expected)
		extension val verdict = new Object {
			var result = false
		}
		succ.ifInstanceOf(String) [
			result = (expected === it)
		]
	}

	@Test
	def void testIsClassNot() {
		val Try.Success<Comparable<?>> succ = completedSuccessfully("Foo")
		succ.is(Boolean).assertFalse
	}

	///////////////
	// getOrNull //
	///////////////

	@Test
	def void testOrNullEmpty() {
		val t = Try.completedEmpty
		val result = t.orNull
		result.assertNull
	}

	@Test
	def void testOrNullFailure() {
		val t = Try.completedExceptionally(new Exception)
		val result = t.orNull
		result.assertNull
	}

	@Test
	def void testOrNullSuccess() {
		val expected = "foo"
		val t = Try.completedSuccessfully(expected)
		val result = t.orNull
		result.assertSame(expected)
	}

	///////////////
	// getOrThrow //
	///////////////

	@Test(expected = NoSuchElementException)
	def void testOrThrowEmpty() {
		val t = Try.completedEmpty
		t.orThrow
	}

	@Test(expected = ArrayIndexOutOfBoundsException)
	def void testOrThrowFailure() {
		val t = Try.completedExceptionally(new ArrayIndexOutOfBoundsException)
		 t.orThrow
	}

	@Test
	def void testOrThrowSuccess() {
		val expected = "foo"
		val t = Try.completedSuccessfully(expected)
		val result = t.orThrow
		result.assertSame(expected)
	}

	//////////////////////
	// getOrThrow (=>E) //
	//////////////////////

	@Test(expected = NullPointerException)
	def void testOrThrowProviderSuccessLamdaNull() {
		val t = Try.completedSuccessfully("foo")
		t.getOrThrow(null)
	}

	@Test(expected = NullPointerException)
	def void testOrThrowProviderEmptyLamdaNull() {
		val t = Try.completedEmpty
		t.getOrThrow(null)
	}

	@Test(expected = NullPointerException)
	def void testOrThrowProviderFaildLamdaNull() {
		val t = Try.completedExceptionally(new NoSuchElementException)
		t.getOrThrow(null)
	}

	@Test(expected = IllegalStateException)
	def void testOrThrowProviderEmpty() {
		val t = Try.completedEmpty
		t.getOrThrow[new IllegalStateException]
	}

	@Test(expected = ArrayIndexOutOfBoundsException)
	def void testOrThrowProviderFailure() {
		val t = Try.completedExceptionally(new ArrayIndexOutOfBoundsException)
		 t.getOrThrow[new IllegalArgumentException]
	}

	@Test
	def void testOrThrowProviderSuccess() {
		val expected = "foo"
		val t = Try.completedSuccessfully(expected)
		val result = t.getOrThrow
		result.assertSame(expected)
	}

	///////////////
	// getResult //
	///////////////

	@Test
	def void testGetResultSuccess() {
		val expected = "foo"
		val t = Try.completedSuccessfully(expected)
		val result = t.getResult()
		result.assertNotNull
		result.get.assertSame(expected)
	}

	@Test
	def void testGetResultEmpty() {
		val t = Try.completedEmpty
		val result = t.getResult()
		result.assertNotNull
		result.isPresent.assertFalse
	}

	@Test
	def void testGetResultFailure() {
		val t = Try.completedExceptionally(new ArrayIndexOutOfBoundsException)
		val result = t.getResult()
		result.assertNotNull
		result.isPresent.assertFalse
	}

	//////////////////
	// getException //
	//////////////////

	@Test
	def void testGetExceptionSuccess() {
		val expected = "foo"
		val t = Try.completedSuccessfully(expected)
		val result = t.exception
		result.assertNotNull
		result.isPresent.assertFalse
	}

	@Test
	def void testGetExceptionEmpty() {
		val t = Try.completedEmpty
		val result = t.exception
		result.assertNotNull
		result.isPresent.assertFalse
	}

	@Test
	def void testGetExceptionFailure() {
		val expected = new ArrayIndexOutOfBoundsException
		val t = Try.completedExceptionally(expected)
		val result = t.exception
		result.assertNotNull
		result.get.assertSame(expected)
	}

	///////////////
	// isFailure //
	///////////////

	@Test
	def void testIsFailureEmpty() {
		val t = Try.completedEmpty
		t.isFailure.assertFalse
	}

	@Test
	def void testIsFailureSuccess() {
		val t = Try.completedSuccessfully("foo")
		t.isFailure.assertFalse
	}

	@Test
	def void testIsFailureFailure() {
		val t = Try.completedExceptionally(new IllegalStateException)
		t.isFailure.assertTrue
	}

	///////////////
	// isSuccess //
	///////////////

	@Test
	def void testIsSuccessfulEmpty() {
		val t = Try.completedEmpty
		t.isSuccessful.assertFalse
	}

	@Test
	def void testIsSuccessfulSuccess() {
		val t = Try.completedSuccessfully("foo")
		t.isSuccessful.assertTrue
	}

	@Test
	def void testIsSuccessfulFailure() {
		val t = Try.completedExceptionally(new IllegalStateException)
		t.isSuccessful.assertFalse
	}

	/////////////
	// isEmpty //
	/////////////

	@Test
	def void testIsEmptyEmpty() {
		val t = Try.completedEmpty
		t.isEmpty.assertTrue
	}

	@Test
	def void testIsEmptySuccess() {
		val t = Try.completedSuccessfully("foo")
		t.isEmpty.assertFalse
	}

	@Test
	def void testIsEmptyFailure() {
		val t = Try.completedExceptionally(new IllegalStateException)
		t.isEmpty.assertFalse
	}

	////////////////////////////
	// filterSuccessPredicate //
	////////////////////////////

	@Test(expected = NullPointerException)
	def void testFilterSuccessPredicateOnEmptyPredicateNullEmpty() {
		val t = Try.completedEmpty
		val Predicate<Object> predicate = null
		t.filterSuccess(predicate)
	}

	@Test(expected = NullPointerException)
	def void testFilterSuccessPredicateOnSuccessPredicateNullEmpty() {
		val t = Try.completedSuccessfully("foo")
		val Predicate<String> predicate = null
		t.filterSuccess(predicate)
	}

	@Test(expected = NullPointerException)
	def void testFilterSuccessPredicateOnFailurePredicateNullEmpty() {
		val t = Try.completedExceptionally(new RuntimeException)
		val Predicate<String> predicate = null
		t.filterSuccess(predicate)
	}

	@Test
	def void testFilterSuccessPredicateOnEmpty() {
		val t = Try.completedEmpty
		extension val context = new Object() {
			var notCalled = true
		} 
		val result = t.filterSuccess [
			notCalled = false
			throw new IllegalStateException
		]
		t.assertSame(result)
		notCalled.assertTrue
	}

	@Test
	def void testFilterSuccessPredicateOnFailure() {
		val t = Try.completedExceptionally(new ArrayIndexOutOfBoundsException)
		extension val context = new Object() {
			var notCalled = true
		} 
		val result = t.filterSuccess [
			notCalled = false
			throw new IllegalStateException
		]
		t.assertSame(result)
		notCalled.assertTrue
	}

	@Test
	def void testFilterSuccessPredicateOnSuccessContextCorrect() {
		val expected = "foo"
		val t = Try.completedSuccessfully(expected)
		extension val context = new Object() {
			var contextCorrect = false
		} 
		t.filterSuccess [
			contextCorrect = (expected === it)
			true
		]
		contextCorrect.assertTrue
	}

	@Test
	def void testFilterSuccessPredicateOnSuccessPredicateTrue() {
		val expected = "foo"
		val t = Try.completedSuccessfully(expected)
		val result = t.filterSuccess [
			true
		]
		result.assertSame(t)
	}

	@Test
	def void testFilterSuccessPredicateOnSuccessPredicateFalse() {
		val expected = "foo"
		val t = Try.completedSuccessfully(expected)
		val result = t.filterSuccess [
			false
		]
		result.assertIsInstanceOf(Try.Empty)
	}

	////////////////////////
	// filterSuccessClass //
	////////////////////////

	@Test(expected = NullPointerException)
	def void testFilterSuccessClassSuccessClassNull() {
		val expected = "foo"
		val t = Try.completedSuccessfully(expected)
		val Class<?> clazz = null
		t.filterSuccess(clazz)
	}

	@Test(expected = NullPointerException)
	def void testFilterSuccessClassEmptyClassNull() {
		val t = Try.completedEmpty
		val Class<?> clazz = null
		t.filterSuccess(clazz)
	}

	@Test(expected = NullPointerException)
	def void testFilterSuccessClassFailureClassNull() {
		val t = Try.completedExceptionally(new ClassCastException)
		val Class<?> clazz = null
		t.filterSuccess(clazz)
	}

	@Test
	def void testFilterSuccessClassEmpty() {
		val t = Try.completedEmpty
		val result = t.filterSuccess(String)
		result.assertSame(t)
	}

	@Test
	def void testFilterSuccessClassFailure() {
		val t = Try.completedExceptionally(new NullPointerException)
		val result = t.filterSuccess(String)
		result.assertSame(t)
	}

	@Test
	def void testFilterSuccessClassSuccessIsInstance() {
		val Try<CharSequence> t = Try.<CharSequence>completedSuccessfully("f00")
		val Try<String> result = t.filterSuccess(String)
		result.assertSame(t)
	}

	@Test
	def void testFilterSuccessClassSuccessNotInstance() {
		val Try<CharSequence> t = Try.<CharSequence>completedSuccessfully("f00")
		val Try<Integer> result = t.filterSuccess(Integer)
		result.assertIsInstanceOf(Try.Empty)
	}

	////////////
	// stream //
	////////////

	@Test
	def void testStreamSuccess() {
		val expected = "the result"
		val t = Try.completedSuccessfully(expected)
		t.stream.toArray.assertArrayEquals(#[expected])
	}

	@Test
	def void testStreamFailure() {
		val t = Try.completedExceptionally(new IllegalArgumentException)
		t.stream.count.assertEquals(0l)
	}

	@Test
	def void testStreamEmpty() {
		val t = Try.completedEmpty
		t.stream.count.assertEquals(0l)
	}

	//////////////
	// iterator //
	//////////////

	@Test
	def void testIteratorEmpty() {
		val t = Try.completedEmpty
		t.iterator.assertEmptyIterator
	}

	@Test
	def void testIteratorFailure() {
		val t = Try.completedExceptionally(new NoSuchElementException)
		t.iterator.assertEmptyIterator
	}

	@Test
	def void testIteratorSuccess() {
		val expected = new Object
		val t = Try.completedSuccessfully(expected)
		val iterator = t.iterator
		iterator.hasNext.assertTrue
		iterator.next.assertSame(expected)
		iterator.assertEmptyIterator
	}

	/////////////
	// recover //
	/////////////

	@Test
	def void testRecoverSuccess() {
		val expected = "the result"
		val recovery = "not the result"
		val t = Try.completedSuccessfully(expected)
		val result = t.recover(recovery)
		result.assertSame(expected)
	}

	@Test
	def void testRecoverEmpty() {
		val expected = "the result"
		val t = Try.completedEmpty
		val result = t.recover(expected)
		result.assertSame(expected)
	}

	@Test
	def void testRecoverFailure() {
		val expected = "the result"
		val t = Try.completedExceptionally(new IllegalStateException)
		val result = t.recover(expected)
		result.assertSame(expected)
	}

	@Test
	def void testRecoverEmptyWithNull() {
		val t = Try.completedEmpty
		val result = t.recover(null)
		result.assertNull
	}

	@Test
	def void testRecoverFailureWithNull() {
		val t = Try.completedExceptionally(new IllegalStateException)
		val result = t.recover(null)
		result.assertNull
	}

	//////////////////
	// recoverEmpty //
	//////////////////

	@Test
	def void testRecoverEmptySuccess() {
		val expected = "the result"
		val recovery = "not the result"
		val t = Try.completedSuccessfully(expected)
		val result = t.recoverEmpty(recovery)
		result.assertSame(t)
	}

	@Test
	def void testRecoverEmptyEmpty() {
		val expected = "the result"
		val t = Try.completedEmpty
		val result = t.recoverEmpty(expected)
		result.assertIsInstanceOf(Try.Success).get.assertSame(expected)
	}

	@Test
	def void testRecoverEmptyFailure() {
		val expected = "the result"
		val t = Try.completedExceptionally(new IllegalStateException)
		val result = t.recoverEmpty(expected)
		result.assertSame(t)
	}

	@Test
	def void testRecoverEmptyEmptyWithNull() {
		val t = Try.completedEmpty
		val result = t.recoverEmpty(null)
		result.assertIsInstanceOf(Try.Empty)
	}
}