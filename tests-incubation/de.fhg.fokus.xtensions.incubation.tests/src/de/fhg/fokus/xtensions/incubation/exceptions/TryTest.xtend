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
	// completedFailed //
	////////////////////////////

	@Test(expected = NullPointerException)
	def void testcompletedFailedNull() {
		Try.completedFailed(null)
	}

	@Test
	def void testcompletedFailed() {
		val e = new ArrayIndexOutOfBoundsException
		val result = Try.completedFailed(e)
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
		val expected = completedFailed(new IllegalArgumentException)
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
		val Try<StringBuffer> expected = completedFailed(new Exception)
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
		val Try.Failure<String> expected = completedFailed(new RuntimeException)
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
		result.assertTrue
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
		val t = Try.completedFailed(new Exception)
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
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
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
		val t = Try.completedFailed(new NoSuchElementException)
		t.getOrThrow(null)
	}

	@Test(expected = IllegalStateException)
	def void testOrThrowProviderEmpty() {
		val t = Try.completedEmpty
		t.getOrThrow[new IllegalStateException]
	}

	@Test(expected = ArrayIndexOutOfBoundsException)
	def void testOrThrowProviderFailure() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
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
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
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
		val t = Try.completedFailed(expected)
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
		val t = Try.completedFailed(new IllegalStateException)
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
		val t = Try.completedFailed(new IllegalStateException)
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
		val t = Try.completedFailed(new IllegalStateException)
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
		val t = Try.completedFailed(new RuntimeException)
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
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
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
		val t = Try.completedFailed(new ClassCastException)
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
		val t = Try.completedFailed(new NullPointerException)
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
		val t = Try.completedFailed(new IllegalArgumentException)
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
		val t = Try.completedFailed(new NoSuchElementException)
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
		val t = Try.completedFailed(new IllegalStateException)
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
		val t = Try.completedFailed(new IllegalStateException)
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
		val t = Try.completedFailed(new IllegalStateException)
		val result = t.recoverEmpty(expected)
		result.assertSame(t)
	}

	@Test
	def void testRecoverEmptyEmptyWithNull() {
		val t = Try.completedEmpty
		val result = t.recoverEmpty(null)
		result.assertIsInstanceOf(Try.Empty)
	}

	/////////////
	// ifEmpty //
	/////////////

	@Test(expected = NullPointerException)
	def void testIfEmptyEmptyNullHandler() {
		val t = Try.completedEmpty
		t.ifEmpty(null)
	}

	@Test(expected = NullPointerException)
	def void testIfEmptySuccessNullHandler() {
		val t = Try.completedSuccessfully("woo")
		t.ifEmpty(null)
	}

	@Test(expected = NullPointerException)
	def void testIfEmptyFailureNullHandler() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		t.ifEmpty(null)
	}

	@Test
	def void testIfEmptyEmpty() {
		extension val verdict = new Object {
			var isCalled = false
		}

		val t = Try.completedEmpty
		t.ifEmpty [
			isCalled = true
		]
		isCalled.assertTrue
	}

	@Test
	def void testIfEmptySuccess() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedSuccessfully(new Object)
		t.ifEmpty [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	@Test
	def void testIfEmptyFailure() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedFailed(new Exception)
		t.ifEmpty [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	///////////////
	// ifSuccess //
	///////////////

	@Test(expected = NullPointerException)
	def void testIfSuccessEmptyNullHandler() {
		val t = Try.completedEmpty
		t.ifSuccess(null)
	}

	@Test(expected = NullPointerException)
	def void testIfSuccessSuccessNullHandler() {
		val t = Try.completedSuccessfully("woo")
		t.ifSuccess(null)
	}

	@Test(expected = NullPointerException)
	def void testIfSuccessFailureNullHandler() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		t.ifSuccess(null)
	}

	@Test
	def void testIfSuccessEmpty() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedEmpty
		t.ifSuccess [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	@Test
	def void testIfSuccessSuccess() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new Object
		val t = Try.completedSuccessfully(expected)
		t.ifSuccess [
			isCalled = true
			actual = it 
		]
		isCalled.assertTrue
		actual.assertSame(expected)
	}

	@Test
	def void testIfSuccessFailure() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedFailed(new Exception)
		t.ifSuccess [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	///////////////
	// ifFailure //
	///////////////

	@Test(expected = NullPointerException)
	def void testIfFailureEmptyNullHandler() {
		val t = Try.completedEmpty
		val (Throwable)=>void handler = null
		t.ifFailure(handler)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureSuccessNullHandler() {
		val t = Try.completedSuccessfully("woo")
		val (Throwable)=>void handler = null
		t.ifFailure(handler)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureFailureNullHandler() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val (Throwable)=>void handler = null
		t.ifFailure(handler)
	}

	@Test
	def void testIfFailureEmpty() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedEmpty
		t.ifFailure [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	@Test
	def void testIfFailureFailure() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new IllegalStateException
		val t = Try.completedFailed(expected)
		t.ifFailure [
			isCalled = true
			actual = it 
		]
		isCalled.assertTrue
		actual.assertSame(expected)
	}

	@Test
	def void testIfFailureSuccess() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedSuccessfully("foo")
		t.ifFailure [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	//////////////////////
	// ifFailure(Class) //
	//////////////////////

	@Test(expected = NullPointerException)
	def void testIfFailureClassEmptyNullHandler() {
		val t = Try.completedEmpty
		val (Throwable)=>void handler = null
		t.ifFailure(Throwable,handler)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassEmptyNullClass() {
		val t = Try.completedEmpty
		val Class<Throwable> clazz = null
		t.ifFailure(clazz)[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassSuccessNullHandler() {
		val t = Try.completedSuccessfully("woo")
		val (Throwable)=>void handler = null
		t.ifFailure(Throwable,handler)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassSuccessNullClass() {
		val t = Try.completedSuccessfully("daaaamn")
		val Class<Throwable> clazz = null
		t.ifFailure(clazz)[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassFailureNullHandler() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val (Throwable)=>void handler = null
		t.ifFailure(Throwable,handler)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassFailureNullClass() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val Class<Throwable> clazz = null
		t.ifFailure(clazz)[]
	}

	@Test
	def void testIfFailureClassEmpty() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedEmpty
		t.ifFailure(Throwable) [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	@Test
	def void testIfFailureClassFailureMatching() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new IllegalStateException
		val t = Try.completedFailed(expected)
		t.ifFailure(RuntimeException) [
			isCalled = true
			actual = it 
		]
		isCalled.assertTrue
		actual.assertSame(expected)
	}

	@Test
	def void testIfFailureClassFailureSame() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new NoSuchElementException
		val t = Try.completedFailed(expected)
		t.ifFailure(NoSuchElementException) [
			isCalled = true
			actual = it 
		]
		isCalled.assertTrue
		actual.assertSame(expected)
	}

	@Test
	def void testIfFailureClassFailureNotMatching() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val expected = new IllegalStateException
		val t = Try.completedFailed(expected)
		t.ifFailure(NullPointerException) [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	@Test
	def void testIfFailureClassSuccess() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedSuccessfully("foo")
		t.ifFailure(Throwable) [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	////////////////////////////
	// ifFailure(Class,Class) //
	////////////////////////////

	@Test(expected = NullPointerException)
	def void testIfFailureClassClassEmptyNullHandler() {
		val t = Try.completedEmpty
		val (Throwable)=>void handler = null
		t.ifFailure(Throwable, Exception, handler)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassClassEmptyNullClass() {
		val t = Try.completedEmpty
		val Class<Throwable> clazz = null
		t.ifFailure(clazz, Throwable)[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassClassEmptyNullClass2() {
		val t = Try.completedEmpty
		val Class<Throwable> clazz = null
		t.ifFailure(Throwable, clazz)[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassClassSuccessNullHandler() {
		val t = Try.completedSuccessfully("woo")
		val (Throwable)=>void handler = null
		t.ifFailure(Throwable, Exception, handler)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassClassSuccessNullClass() {
		val t = Try.completedSuccessfully("daaaamn")
		val Class<Throwable> clazz = null
		t.ifFailure(clazz, Throwable)[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassClassSuccessNullClass2() {
		val t = Try.completedSuccessfully("daaaamn")
		val Class<Throwable> clazz = null
		t.ifFailure(Throwable, clazz)[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassClassFailureNullHandler() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val (Throwable)=>void handler = null
		t.ifFailure(Throwable, Exception, handler)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassClassFailureNullClass() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val Class<Throwable> clazz = null
		t.ifFailure(clazz, Throwable)[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassClassFailureNullClass2() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val Class<Throwable> clazz = null
		t.ifFailure(Throwable, clazz)[]
	}

	@Test
	def void testIfFailureClassClassEmpty() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedEmpty
		t.ifFailure(Throwable, Exception) [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	@Test
	def void testIfFailureClassClassFailureMatching() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new IllegalStateException
		val t = Try.completedFailed(expected)
		t.ifFailure(RuntimeException, Exception) [
			isCalled = true
			actual = it 
		]
		isCalled.assertTrue
		actual.assertSame(expected)
	}

	@Test
	def void testIfFailureClassClassFailureOneMatching() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new IllegalStateException
		val t = Try.completedFailed(expected)
		t.ifFailure(RuntimeException, IllegalArgumentException) [
			isCalled = true
			actual = it 
		]
		isCalled.assertTrue
		actual.assertSame(expected)
	}

	@Test
	def void testIfFailureClassClassFailureSame() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new NoSuchElementException
		val t = Try.completedFailed(expected)
		t.ifFailure(NoSuchElementException, NoSuchElementException) [
			isCalled = true
			actual = it 
		]
		isCalled.assertTrue
		actual.assertSame(expected)
	}

	@Test
	def void testIfFailureClassClassFailureNotMatching() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val expected = new IllegalStateException
		val t = Try.completedFailed(expected)
		t.ifFailure(NullPointerException, ArrayIndexOutOfBoundsException) [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	@Test
	def void testIfFailureClassClassSuccess() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedSuccessfully("foo")
		t.ifFailure(Throwable, Exception) [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	////////////////////////
	// ifFailure(Class[]) //
	////////////////////////

	@Test(expected = NullPointerException)
	def void testIfFailureClassArrayEmptyNullHandler() {
		val t = Try.completedEmpty
		t.ifFailure(Throwable, Exception).then(null)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArrayEmptyNullClassArray() {
		val t = Try.completedEmpty
		val Class<Throwable>[] errors = null
		t.ifFailure(errors).then[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArrayEmptyNullClass() {
		val t = Try.completedEmpty
		val Class<Throwable> clazz = null
		t.ifFailure(clazz, Throwable).then[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArrayEmptyNullClass2() {
		val t = Try.completedEmpty
		val Class<Throwable> clazz = null
		t.ifFailure(Throwable, clazz).then[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArraySuccessNullHandler() {
		val t = Try.completedSuccessfully("woo")
		val (Throwable)=>void handler = null
		t.ifFailure(Throwable, Exception, handler)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArraySuccessNullClassArray() {
		val t = Try.completedSuccessfully("daaaamn")
		val Class<Throwable>[] errors = null
		t.ifFailure(errors).then[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArraySuccessNullClass() {
		val t = Try.completedSuccessfully("daaaamn")
		val Class<Throwable> clazz = null
		t.ifFailure(clazz, Throwable).then[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArraySuccessNullClass2() {
		val t = Try.completedSuccessfully("daaaamn")
		val Class<Throwable> clazz = null
		t.ifFailure(Throwable, clazz).then[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArrayFailureNullHandler() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val (Throwable)=>void handler = null
		t.ifFailure(Throwable, Exception).then(handler)
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArrayFailureNullClassArray() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val Class<Throwable>[] classes = null
		t.ifFailure(classes).then[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArrayFailureNullClass() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val Class<Throwable> clazz = null
		t.ifFailure(clazz, Throwable).then[]
	}

	@Test(expected = NullPointerException)
	def void testIfFailureClassArrayFailureNullClass2() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val Class<Throwable> clazz = null
		t.ifFailure(Throwable, clazz).then[]
	}

	@Test
	def void testIfFailureClassArrayEmpty() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedEmpty
		t.ifFailure(Throwable, Exception).then [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	@Test
	def void testIfFailureClassArrayFailureMatching() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new IllegalStateException
		val t = Try.completedFailed(expected)
		t.ifFailure(RuntimeException, Exception).then [
			isCalled = true
			actual = it 
		]
		isCalled.assertTrue
		actual.assertSame(expected)
	}

	@Test
	def void testIfFailureClassArrayFailureOneMatching() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new IllegalStateException
		val t = Try.completedFailed(expected)
		t.ifFailure(RuntimeException, IllegalArgumentException).then [
			isCalled = true
			actual = it 
		]
		isCalled.assertTrue
		actual.assertSame(expected)
	}

	@Test
	def void testIfFailureClassArrayFailureSame() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new NoSuchElementException
		val t = Try.completedFailed(expected)
		t.ifFailure(NoSuchElementException, NoSuchElementException).then [
			isCalled = true
			actual = it 
		]
		isCalled.assertTrue
		actual.assertSame(expected)
	}

	@Test
	def void testIfFailureClassArrayFailureNotMatching() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val expected = new IllegalStateException
		val t = Try.completedFailed(expected)
		t.ifFailure(NullPointerException, ArrayIndexOutOfBoundsException).then [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	@Test
	def void testIfFailureClassArraySuccess() {
		extension val verdict = new Object {
			var isNotCalled = true
		}

		val t = Try.completedSuccessfully("foo")
		t.ifFailure(Throwable, Exception).then [
			isNotCalled = false
		]
		isNotCalled.assertTrue
	}

	//////////////////
	// mapException //
	//////////////////

	@Test
	def void testMapExceptionSuccess() {
		val t = Try.completedSuccessfully("foo")
		t.assertMapExceptionLambdaNotCalled
	}

	@Test
	def void testMapExceptionSuccessLambdaNull() {
		val t = Try.completedSuccessfully("foo")
		t.assertMapExceptionLambdaNull
	}

	@Test
	def void testMapExceptionEmpty() {
		val t = Try.completedEmpty
		t.assertMapExceptionLambdaNotCalled
	}

	@Test
	def void testMapExceptionEmptyLambdaNull() {
		val t = Try.completedEmpty
		t.assertMapExceptionLambdaNull
	}

	@Test
	def void testMapExceptionFailureLambdaNull() {
		val t = Try.completedFailed(new NoSuchElementException)
		t.assertMapExceptionLambdaNull
	}

	@Test
	def void testMapExceptionFailureLambdaCalledWithCorrectException() {
		val expected = new NoSuchElementException
		val t = Try.completedFailed(expected)
		extension val context = new Object {
			var actual = null
		}
		t.tryMapException [
			actual = it
			new ArrayIndexOutOfBoundsException
		]
		actual.assertSame(expected)
	}

	@Test
	def void testMapExceptionFailureReturnedWrappsCorrectException() {
		val expected = new NoSuchElementException
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val result = t.tryMapException [
			expected
		]
		result.assertIsInstanceOf(Try.Failure).get.assertSame(expected)
	}

	@Test
	def void testMapExceptionFailureLambdaThrows() {
		val expected = new IllegalStateException
		val toBeMapped = new NoSuchElementException
		val t = Try.completedFailed(toBeMapped)
		val result = t.tryMapException[throw expected]
		result.get.assertIsInstanceOf(FailureOperationException) => [
			cause.assertSame(expected)
			wrappedException.assertSame(toBeMapped)
		]
	}

	@Test
	def void testMapExceptionFailureLambdaReturnsNull() {
		val toBeMapped = new NoSuchElementException
		val t = Try.completedFailed(toBeMapped)
		val result = t.tryMapException[null]
		result.get.assertIsInstanceOf(FailureOperationException) => [
			cause.assertIsInstanceOf(NullPointerException)
			wrappedException.assertSame(toBeMapped)
		]
	}

	def void assertMapExceptionLambdaNotCalled(Try<String> t) {
		extension val verdict = new Object {
			var notCalled = true
		}
		t.tryMapException [
			notCalled = false
			null
		]
		notCalled.assertTrue
	}

	def void assertMapExceptionLambdaNull(Try<String> t) {
		val result = t.tryMapException(null)
		result.assertIsInstanceOf(Try.Failure).get.assertIsInstanceOf(NullPointerException)
	}

	////////////////
	// tryRecover //
	////////////////

	@Test
	def void testTryRecoverSuccessfullRecoveryNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecover(null)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverEmptyRecoveryNull() {
		val t = Try.completedEmpty
		val result = t.tryRecover(null)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverFailureRecoveryNull() {
		val t = Try.completedFailed(new IllegalArgumentException)
		val result = t.tryRecover(null)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverSuccess() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecover["foo"]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailure() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecover[expected]
		val succ = result.assertIsInstanceOf(Try.Success)
		succ.get.assertSame(expected)
	}

	@Test
	def void testTryRecoverEmpty() {
		val t = Try.completedEmpty
		val expected = "bar"
		val result = t.tryRecover[expected]
		val succ = result.assertIsInstanceOf(Try.Success)
		succ.get.assertSame(expected)
	}


	@Test
	def void testTryRecoverSuccessThrowException() {
		val t = Try.completedSuccessfully("bar")
		val expected = new NoSuchElementException
		val result = t.tryRecover[throw expected]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureThrowException() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val expected = new NoSuchElementException
		val result = t.tryRecover[throw expected]
		val fail = result.assertIsInstanceOf(Try.Failure)
		val ex = fail.get().assertIsInstanceOf(FailureOperationException)
		ex.cause.assertSame(expected)
		ex.wrappedException.assertSame(wrapped)
	}

	@Test
	def void testTryRecoverEmptyThrowException() {
		val t = Try.completedEmpty
		val expected = new NoSuchElementException
		val result = t.tryRecover[throw expected]
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get().assertSame(expected)
	}

	def void testTryRecoverSuccessNullRecovery() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryRecover[null]
		result.assertSame(t)
	}

	def void testTryRecoverEmptyNullRecovery() {
		val t = Try.completedEmpty
		val result = t.tryRecover[null]
		result.assertIsInstanceOf(Try.Empty)
	}

	def void testTryRecoverFailureNullRecovery() {
		val t = Try.completedFailed(new IllegalStateException)
		val result = t.tryRecover[null]
		result.assertIsInstanceOf(Try.Empty)
	}

	/////////////////////
	// tryRecoverEmpty //
	/////////////////////

	@Test
	def void testTryRecoverEmptySuccessfullRecoveryNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverEmpty(null)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverEmptyEmptyRecoveryNull() {
		val t = Try.completedEmpty
		val result = t.tryRecoverEmpty(null)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverEmptyFailureRecoveryNull() {
		val t = Try.completedFailed(new IllegalArgumentException)
		val result = t.tryRecoverEmpty(null)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverEmptySuccess() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecover["foo"]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverEmptyFailure() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverEmpty[expected]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverEmptyEmpty() {
		val t = Try.completedEmpty
		val expected = "bar"
		val result = t.tryRecover[expected]
		val succ = result.assertIsInstanceOf(Try.Success)
		succ.get.assertSame(expected)
	}


	@Test
	def void testTryRecoverEmptySuccessThrowException() {
		val t = Try.completedSuccessfully("bar")
		val expected = new NoSuchElementException
		val result = t.tryRecoverEmpty[throw expected]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverEmptyFailureThrowException() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val expected = new NoSuchElementException
		val result = t.tryRecoverEmpty[throw expected]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverEmptyEmptyThrowException() {
		val t = Try.completedEmpty
		val expected = new NoSuchElementException
		val result = t.tryRecoverEmpty[throw expected]
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get().assertSame(expected)
	}

	def void testTryRecoverEmptySuccessNullRecovery() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryRecoverEmpty[null]
		result.assertSame(t)
	}

	def void testTryRecoverEmptyEmptyNullRecovery() {
		val t = Try.completedEmpty
		val result = t.tryRecover[null]
		result.assertIsInstanceOf(Try.Empty)
	}

	def void testTryRecoverEmptyFailureNullRecovery() {
		val t = Try.completedFailed(new IllegalStateException)
		val result = t.tryRecover[null]
		result.assertSame(t)
	}

	///////////////////////
	// tryRecoverFailure //
	///////////////////////

	@Test
	def void testTryRecoverFailureSuccessfullRecoveryNull() {
		val t = Try.completedSuccessfully("bar")
		val (Throwable)=>String mapper = null
		val result = t.tryRecoverFailure(mapper)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverFailureEmptyRecoveryNull() {
		val t = Try.completedEmpty
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(mapper)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverFailureFailureRecoveryNull() {
		val t = Try.completedFailed(new IllegalArgumentException)
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(mapper)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverFailureSuccess() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure["foo"]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureFailure() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure[expected]
		val succ = result.assertIsInstanceOf(Try.Success)
		succ.get.assertSame(expected)
	}

	@Test
	def void testTryRecoverFailureFailureExceptionPassedToLambda() {
		extension val result = new Object() {
			var actualException = null
		}
		val expected = new ArrayIndexOutOfBoundsException
		val t = Try.completedFailed(expected)
		t.tryRecoverFailure[
			actualException = it
		]
		actualException.assertSame(expected)
	}

	@Test
	def void testTryRecoverFailureEmpty() {
		val t = Try.completedEmpty
		val expected = "bar"
		val result = t.tryRecoverFailure[expected]
		result.assertSame(t)
	}


	@Test
	def void testTryRecoverFailureSuccessThrowException() {
		val t = Try.completedSuccessfully("bar")
		val expected = new NoSuchElementException
		val result = t.tryRecoverFailure[throw expected]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureFailureThrowException() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val expected = new NoSuchElementException
		val result = t.tryRecoverFailure[throw expected]
		val fail = result.assertIsInstanceOf(Try.Failure)
		val ex = fail.get().assertIsInstanceOf(FailureOperationException)
		ex.cause.assertSame(expected)
		ex.wrappedException.assertSame(wrapped)
	}

	@Test
	def void testTryRecoverFailureEmptyThrowException() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure[new NoSuchElementException]
		result.assertSame(t)
	}

	def void testTryRecoverFailureSuccessNullRecovery() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryRecoverEmpty[null]
		result.assertSame(t)
	}

	def void testTryRecoverFailureEmptyNullRecovery() {
		val t = Try.completedEmpty
		val result = t.tryRecover[null]
		result.assertSame(t)
	}

	def void testTryRecoverFailureFailureNullRecovery() {
		val t = Try.completedFailed(new IllegalStateException)
		val result = t.tryRecover[null]
		result.assertIsInstanceOf(Try.Empty)
	}


	/////////////////////////////////////////
	// tryRecoverFailure(Class<E>, (E)=>R) //
	/////////////////////////////////////////

	@Test
	def void testTryRecoverFailureClassSuccessfullRecoveryNull() {
		val t = Try.completedSuccessfully("bar")
		val (Throwable)=>String mapper = null
		val result = t.tryRecoverFailure(NullPointerException, mapper)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverFailureClassEmptyRecoveryNull() {
		val t = Try.completedEmpty
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(NullPointerException, mapper)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	@Test
	def void testTryRecoverFailureClassFailureRecoveryNull() {
		val t = Try.completedFailed(new IllegalArgumentException)
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(NullPointerException, mapper)
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	// TODO: class is null
//
//	@Test
//	def void testTryRecoverFailureSuccess() {
//		val t = Try.completedSuccessfully("bar")
//		val result = t.tryRecoverFailure["foo"]
//		result.assertSame(t)
//	}
//
//	@Test
//	def void testTryRecoverFailureFailure() {
//		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
//		val expected = "bar"
//		val result = t.tryRecoverFailure[expected]
//		val succ = result.assertIsInstanceOf(Try.Success)
//		succ.get.assertSame(expected)
//	}
// TODO: test non matching excpetion class
//
//	@Test
//	def void testTryRecoverFailureFailureExceptionPassedToLambda() {
//		extension val result = new Object() {
//			var actualException = null
//		}
//		val expected = new ArrayIndexOutOfBoundsException
//		val t = Try.completedFailed(expected)
//		t.tryRecoverFailure[
//			actualException = it
//		]
//		actualException.assertSame(expected)
//	}
//
//	@Test
//	def void testTryRecoverFailureEmpty() {
//		val t = Try.completedEmpty
//		val expected = "bar"
//		val result = t.tryRecoverFailure[expected]
//		result.assertSame(t)
//	}
//
//
//	@Test
//	def void testTryRecoverFailureSuccessThrowException() {
//		val t = Try.completedSuccessfully("bar")
//		val expected = new NoSuchElementException
//		val result = t.tryRecoverFailure[throw expected]
//		result.assertSame(t)
//	}
//
//	@Test
//	def void testTryRecoverFailureFailureThrowException() {
//		val wrapped = new IllegalArgumentException
//		val t = Try.completedFailed(wrapped)
//		val expected = new NoSuchElementException
//		val result = t.tryRecoverFailure[throw expected]
//		val fail = result.assertIsInstanceOf(Try.Failure)
//		val ex = fail.get().assertIsInstanceOf(FailureOperationException)
//		ex.cause.assertSame(expected)
//		ex.wrappedException.assertSame(wrapped)
//	}
//
//	@Test
//	def void testTryRecoverFailureEmptyThrowException() {
//		val t = Try.completedEmpty
//		val result = t.tryRecoverFailure[new NoSuchElementException]
//		result.assertSame(t)
//	}
//
//	def void testTryRecoverFailureSuccessNullRecovery() {
//		val t = Try.completedSuccessfully("foo")
//		val result = t.tryRecoverEmpty[null]
//		result.assertSame(t)
//	}
//
//	def void testTryRecoverFailureEmptyNullRecovery() {
//		val t = Try.completedEmpty
//		val result = t.tryRecover[null]
//		result.assertSame(t)
//	}
//
//	def void testTryRecoverFailureFailureNullRecovery() {
//		val t = Try.completedFailed(new IllegalStateException)
//		val result = t.tryRecover[null]
//		result.assertIsInstanceOf(Try.Empty)
//	}

	//TODO: tryRecoverFailure(Class<? extends E> exceptionType, Class<? extends E> exceptionType2, (E)=>R recovery)
	//TODO: tryRecoverFailure(Class<? extends E>... exceptionType)
	//TODO: transform
	//TODO: thenTry
	//TODO: thenTryOptional
	//TODO: thenTryWith
	//TODO: thenTryFlat
	//TODO: Success#is
	//TODO: Failure#is
	
}