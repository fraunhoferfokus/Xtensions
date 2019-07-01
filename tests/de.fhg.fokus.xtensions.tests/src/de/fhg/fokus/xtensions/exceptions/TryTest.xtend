package de.fhg.fokus.xtensions.exceptions

import static extension org.junit.Assert.*
import de.fhg.fokus.xtensions.exceptions.Try
import static de.fhg.fokus.xtensions.exceptions.Try.*
import org.junit.Test
import static extension de.fhg.fokus.xtensions.Util.*
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
		result.assertSuccess(expected)
	}

	@Test
	def void testCompletedNull() {
		val result = Try.completed(null)
		result.assertEmpty
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
		result.assertSuccess(expected)
	}


	
	////////////////////
	// completedEmpty //
	////////////////////

	@Test
	def void testCompletedEmpty() {
		Try.completedEmpty.assertEmpty
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
		result.assertFailedWith(e)
	}

	///////////
	// tryCall //
	///////////

	@Test
	def void testTryCallMethodNull() {
		val result = Try.tryCall(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryCallMethodProvidesNull() {
		val result = Try.tryCall[null]
		result.assertEmpty
	}

	@Test
	def void testTryCallMethodProvidesElement() {
		val expected = new Object
		val result = Try.tryCall[expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryCallMethodThrows() {
		val expected = new IllegalStateException
		val result = Try.tryCall[
			throw expected
		]
		result.assertFailedWith(expected)
	}


	/////////////
	// tryWith //
	/////////////

	@Test
	def void testTryWithResourceProviderNull() {
		val result = tryWith(null)[]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryWithProviderNull() {
		val result = tryWith([], null)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryWithProviderNullResource() {
		extension val verdict = new Object {
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
		extension val verdict = new Object {
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
		extension val verdict = new Object {
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
		result.assertSuccess(expected)
	}

	/////////////
	// tryFlat //
	/////////////

	@Test
	def void testTryFlatProviderNull() {
		val result = tryFlat(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryFlatProviderReturnsNull() {
		val result = tryFlat [
			null
		]
		result.assertFailedWithNPE
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
		result.assertFailedWith(expected)
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
		result.assertFailedWithNPE
	}

	@Test
	def void testTryOptionalProvidingEmpty() {
		val result = tryOptional [Optional.empty]
		result.assertEmpty
	}

	@Test
	def void testTryOptionalProvidingValue() {
		val expected = "foo"
		val result = tryOptional [Optional.of(expected)]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryOptionalThrowing() {
		val expected = new IllegalArgumentException
		val result = tryOptional [ throw expected ]
		result.assertFailedWith(expected)
	}

	///////////////////
	// tryCall input //
	///////////////////

	@Test
	def void testTryCallInputProviderNull() {
		val result = tryCall(new Object, null)
		result.assertFailedWithNPE
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
		result.assertEmpty
	}

	@Test
	def void testTryCallInputProvidingValue() {
		val expected = new Object
		val result = tryCall(null) [
			expected
		]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryCallInputThrowing() {
		val expected = new NoSuchElementException
		val result = tryCall(null) [
			throw expected
		]
		result.assertFailedWith(expected)
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

	@Test(expected = NullPointerException)
	def void testIfInstanceOfClazzNull() {
		completedSuccessfully("foo").ifInstanceOf(null) []
	}

	@Test(expected = NullPointerException)
	def void testIfInstanceOfActionNull() {
		completedSuccessfully("foo").ifInstanceOf(String, null)
	}

	@Test
	def void testIfInstanceOf() {
		val expected = "Foo"
		val Try.Success<Comparable<?>> succ = completedSuccessfully(expected)
		extension val verdict = new Object {
			var result = false
		}
		succ.ifInstanceOf(String) [
			result = (expected === it)
		].assertSame(succ)
		result.assertTrue
	}

	@Test
	def void testIfInstanceOfSubclass() {
		val expected = "Foo"
		val Try.Success<Comparable<?>> succ = completedSuccessfully(expected)
		extension val verdict = new Object {
			var result = false
		}
		succ.ifInstanceOf(CharSequence) [
			result = (expected === it)
		].assertSame(succ)
		result.assertTrue
	}

	@Test
	def void testIfInstanceOfNotInstance() {
		val Try.Success<Comparable<?>> succ = completedSuccessfully("Foo")
		extension val verdict = new Object {
			var notCalled = true
		}
		succ.ifInstanceOf(Integer) [
			notCalled = false
		].assertSame(succ)
		notCalled.assertTrue
	}

	////////////////
	// Success#is //
	////////////////

	@Test(expected = NullPointerException)
	def void testSuccessIsClassNull() {
		val succ = completedSuccessfully("Foo")
		succ.is(null)
	}

	@Test
	def void testSuccessIsClassInstanceOf() {
		val Try.Success<Comparable<?>> succ = completedSuccessfully("Foo")
		succ.is(CharSequence).assertTrue
	}

	@Test
	def void testSuccessIsClassMatching() {
		val Try.Success<Comparable<?>> succ = completedSuccessfully("Foo")
		succ.is(String).assertTrue
	}

	@Test
	def void testSuccessIsClassNot() {
		val Try.Success<Comparable<?>> succ = completedSuccessfully("Foo")
		succ.is(Boolean).assertFalse
	}

	////////////////
	// Failure#is //
	////////////////

	@Test(expected = NullPointerException)
	def void testFailureIsClassNull() {
		val fail = completedFailed(new IllegalArgumentException)
		fail.is(null)
	}

	@Test
	def void testFailureIsClassInstanceOf() {
		val fail = completedFailed(new IllegalArgumentException)
		fail.is(RuntimeException).assertTrue
	}

	@Test
	def void testFailureIsClassMatching() {
		val fail = completedFailed(new IllegalArgumentException)
		fail.is(IllegalArgumentException).assertTrue
	}

	@Test
	def void testFailureIsClassNot() {
		val fail = completedFailed(new IllegalArgumentException)
		fail.is(ArrayIndexOutOfBoundsException).assertFalse
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
		val result = t.getOrThrow[new IllegalArgumentException]
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
		extension val context = new Object {
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
		extension val context = new Object {
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
		extension val context = new Object {
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
		result.assertEmpty
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
		result.assertEmpty
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
		result.assertSuccess(expected)
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
		result.assertEmpty
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
	def void testIfFailureClassClassFailureMatchingFirst() {
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
	def void testIfFailureClassClassFailureMatchingSecond() {
		extension val verdict = new Object {
			var isCalled = false
			var actual = null
		}

		val expected = new IllegalStateException
		val t = Try.completedFailed(expected)
		t.ifFailure(NullPointerException, RuntimeException) [
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
		val wrapped = new NoSuchElementException
		val t = Try.completedFailed(wrapped)
		t.assertMapExceptionLambdaNull.assertSuppressed(wrapped)
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
		result.assertFailedWith(expected)
	}

	@Test
	def void testMapExceptionFailureLambdaThrows() {
		val expected = new IllegalStateException
		val toBeMapped = new NoSuchElementException
		val t = Try.completedFailed(toBeMapped)
		val result = t.tryMapException[throw expected]
		result.get.assertSame(expected)
		expected.assertSuppressed(toBeMapped)
	}

	@Test
	def void testMapExceptionFailureLambdaReturnsNull() {
		val toBeMapped = new NoSuchElementException
		val t = Try.completedFailed(toBeMapped)
		val result = t.tryMapException[null]
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(toBeMapped)
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

	def NullPointerException assertMapExceptionLambdaNull(Try<String> t) {
		val result = t.tryMapException(null)
		result.assertFailedWithNPE
	}

	////////////////
	// tryRecover //
	////////////////

	@Test
	def void testTryRecoverSuccessfullRecoveryNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecover(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverEmptyRecoveryNull() {
		val t = Try.completedEmpty
		val result = t.tryRecover(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureRecoveryNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val result = t.tryRecover(null)
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
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
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverEmpty() {
		val t = Try.completedEmpty
		val expected = "bar"
		val result = t.tryRecover[expected]
		result.assertSuccess(expected)
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
		result.assertFailedWith(expected)
		expected.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverEmptyThrowException() {
		val t = Try.completedEmpty
		val expected = new NoSuchElementException
		val result = t.tryRecover[throw expected]
		result.assertFailedWith(expected)
	}

	@Test
	def void testTryRecoverSuccessNullRecovery() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryRecover[null]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverEmptyNullRecovery() {
		val t = Try.completedEmpty
		val result = t.tryRecover[null]
		result.assertEmpty
	}

	@Test
	def void testTryRecoverFailureNullRecovery() {
		val t = Try.completedFailed(new IllegalStateException)
		val result = t.tryRecover[null]
		result.assertEmpty
	}

	/////////////////////
	// tryRecoverEmpty //
	/////////////////////

	@Test
	def void testTryRecoverEmptySuccessfullRecoveryNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverEmpty(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverEmptyEmptyRecoveryNull() {
		val t = Try.completedEmpty
		val result = t.tryRecoverEmpty(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverEmptyFailureRecoveryNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val result = t.tryRecoverEmpty(null)
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
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
		result.assertSuccess(expected)
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
		result.assertFailedWith(expected)
	}

	@Test
	def void testTryRecoverEmptySuccessNullRecovery() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryRecoverEmpty[null]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverEmptyEmptyNullRecovery() {
		val t = Try.completedEmpty
		val result = t.tryRecover[null]
		result.assertEmpty
	}

	@Test
	def void testTryRecoverEmptyFailureNullRecovery() {
		val t = Try.completedFailed(new IllegalStateException)
		val result = t.tryRecover[null]
		result.assertEmpty
	}

	///////////////////////
	// tryRecoverFailure //
	///////////////////////

	@Test
	def void testTryRecoverFailureSuccessfullRecoveryNull() {
		val t = Try.completedSuccessfully("bar")
		val (Throwable)=>String mapper = null
		val result = t.tryRecoverFailure(mapper)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureEmptyRecoveryNull() {
		val t = Try.completedEmpty
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(mapper)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureFailureRecoveryNull() {
		val t = Try.completedFailed(new IllegalArgumentException)
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(mapper)
		result.assertFailedWithNPE
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
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureFailureExceptionPassedToLambda() {
		extension val result = new Object {
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
		result.assertFailedWith(expected)
		expected.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverFailureEmptyThrowException() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure[new NoSuchElementException]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureSuccessNullRecovery() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryRecoverFailure[null]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverClassFailureEmptyNullRecovery() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(IllegalArgumentException)[null]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureFailureNullRecovery() {
		val t = Try.completedFailed(new IllegalStateException)
		val result = t.tryRecoverFailure[null]
		result.assertEmpty
	}


	/////////////////////////////////////////
	// tryRecoverFailure(Class<E>, (E)=>R) //
	/////////////////////////////////////////

	@Test
	def void testTryRecoverFailureClassSuccessfullRecoveryNull() {
		val t = Try.completedSuccessfully("bar")
		val (Throwable)=>String mapper = null
		val result = t.tryRecoverFailure(NullPointerException, mapper)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassEmptyRecoveryNull() {
		val t = Try.completedEmpty
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(NullPointerException, mapper)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassFailureRecoveryNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(NullPointerException, mapper)
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
	}


	@Test
	def void testTryRecoverFailureClassEmptyClassNull() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(null) [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassSuccessfullClassNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure(null) [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassFailureClassNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val result = t.tryRecoverFailure(null) [
			"foo"
		]
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
	}


	@Test
	def void testTryRecoverFailureClassSuccess() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure(NullPointerException)["foo"]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassFailureMatching() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(ArrayIndexOutOfBoundsException)[expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassFailureSuperType() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(RuntimeException)[expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassFailureNotMatching() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(NoSuchElementException)[expected]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassFailureExceptionPassedToLambda() {
		extension val result = new Object {
			var actualException = null
		}
		val expected = new ArrayIndexOutOfBoundsException
		val t = Try.completedFailed(expected)
		t.tryRecoverFailure(ArrayIndexOutOfBoundsException)[
			actualException = it
		]
		actualException.assertSame(expected)
	}

	@Test
	def void testTryRecoverFailureClassEmpty() {
		val t = Try.completedEmpty
		val expected = "bar"
		val result = t.tryRecoverFailure(ArrayIndexOutOfBoundsException)[expected]
		result.assertSame(t)
	}


	@Test
	def void testTryRecoverFailureClassSuccessThrowException() {
		val t = Try.completedSuccessfully("bar")
		val expected = new NoSuchElementException
		val result = t.tryRecoverFailure(Throwable)[throw expected]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassFailureThrowException() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val expected = new NoSuchElementException
		val result = t.tryRecoverFailure(IllegalArgumentException)[throw expected]
		result.assertFailedWith(expected)
		expected.assertSuppressed(wrapped)
	}


	@Test
	def void testTryRecoverFailureClassFailureThrowExceptionClassNotMatching() {
		val t = Try.completedFailed(new IllegalArgumentException)
		val result = t.tryRecoverFailure(IllegalStateException)[new NoSuchElementException]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassEmptyThrowException() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(Exception)[new NoSuchElementException]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassSuccessNullRecovery() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryRecoverFailure(NoSuchElementException)[null]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureEmptyNullRecovery() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(NoSuchElementException)[null]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassFailureNullRecovery() {
		val t = Try.completedFailed(new IllegalStateException)
		val result = t.tryRecoverFailure(RuntimeException)[null]
		result.assertEmpty
	}

	///////////////////////////////////////////////////////////////////////
	// tryRecoverFailure(Class<? extends E>, Class<? extends E>, (E)=>R) //
	///////////////////////////////////////////////////////////////////////

	@Test
	def void testTryRecoverFailureClassClassSuccessfullRecoveryNull() {
		val t = Try.completedSuccessfully("bar")
		val (Throwable)=>String mapper = null
		val result = t.tryRecoverFailure(NullPointerException, IllegalStateException, mapper)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassClassEmptyRecoveryNull() {
		val t = Try.completedEmpty
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(NullPointerException, IllegalStateException, mapper)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassClassFailureRecoveryNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(NullPointerException, IllegalStateException, mapper)
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverFailureClassClassEmptyFirstClassNull() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(null, NullPointerException) [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassClassEmptySecondClassNull() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(NullPointerException, null) [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassClassSuccessfullFirstClassNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure(null, NoSuchElementException) [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassClassSuccessfullSecondClassNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure(NoSuchElementException, null) [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassClassFailureFirstClassNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val result = t.tryRecoverFailure(null, NoSuchElementException) [
			"foo"
		]
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverFailureClassClassFailureSecondClassNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val result = t.tryRecoverFailure(NoSuchElementException, null) [
			"foo"
		]
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverFailureClassClassSuccess() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure(NullPointerException, NoSuchElementException)["foo"]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassClassFailureFirstMatching() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(ArrayIndexOutOfBoundsException, NoSuchElementException)[expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassClassFailureSecondMatching() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(NoSuchElementException, ArrayIndexOutOfBoundsException)[expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassFailureFirstSuperType() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(RuntimeException, NoSuchElementException)[expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassClassFailureSecondSuperType() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(NoSuchElementException, RuntimeException)[expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassClassFailureNotMatching() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val result = t.tryRecoverFailure(NoSuchElementException, IllegalArgumentException)["bar"]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassClassFailureExceptionPassedToLambda() {
		extension val result = new Object {
			var actualException = null
		}
		val expected = new ArrayIndexOutOfBoundsException
		val t = Try.completedFailed(expected)
		t.tryRecoverFailure(ArrayIndexOutOfBoundsException, RuntimeException)[
			actualException = it
		]
		actualException.assertSame(expected)
	}

	@Test
	def void testTryRecoverFailureClassClassEmpty() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(ArrayIndexOutOfBoundsException, RuntimeException)["bar"]
		result.assertSame(t)
	}


	@Test
	def void testTryRecoverFailureClassClassSuccessThrowException() {
		val t = Try.completedSuccessfully("bar")
		val expected = new NoSuchElementException
		val result = t.tryRecoverFailure(Throwable, NoSuchElementException)[throw expected]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassClassFailureThrowException() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val expected = new NoSuchElementException
		val result = t.tryRecoverFailure(RuntimeException, IllegalArgumentException)[throw expected]
		result.assertFailedWith(expected)
		expected.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverFailureClassClassFailureThrowExceptionClassNotMatching() {
		val t = Try.completedFailed(new IllegalArgumentException)
		val result = t.tryRecoverFailure(IllegalStateException, NoSuchElementException)[new NoSuchElementException]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassClassEmptyThrowException() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(Exception, Throwable)[new NoSuchElementException]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassClassSuccessNullRecovery() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryRecoverFailure(NoSuchElementException, Throwable)[null]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassClassEmptyNullRecovery() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(NoSuchElementException, Exception)[null]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassClassFailureNullRecovery() {
		val t = Try.completedFailed(new IllegalStateException)
		val result = t.tryRecoverFailure(RuntimeException, IllegalStateException)[null]
		result.assertEmpty
	}

	//////////////////////////////////////////////
	// tryRecoverFailure(Class<? extends E>...) //
	//////////////////////////////////////////////

	@Test
	def void testTryRecoverFailureClassArraySuccessArrayNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure(null as Class<Throwable>[]).with[]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassArrayEmptyArrayNull() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(null as Class<Throwable>[]).with[]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassArrayFailedArrayNull() {
		val expectedSuppressed = new NoSuchElementException
		val t = Try.completedFailed(expectedSuppressed)
		val result = t.tryRecoverFailure(null as Class<Throwable>[]).with[]
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(expectedSuppressed)
	}

	@Test
	def void testTryRecoverFailureClassArraySuccessfullRecoveryNull() {
		val t = Try.completedSuccessfully("bar")
		val (Throwable)=>String mapper = null
		val result = t.tryRecoverFailure(NullPointerException, IllegalStateException, NoSuchElementException).with(mapper)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassArrayEmptyRecoveryNull() {
		val t = Try.completedEmpty
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(NullPointerException, IllegalStateException, NoSuchElementException).with(mapper)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureRecoveryNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val (Throwable)=>Object mapper = null
		val result = t.tryRecoverFailure(NullPointerException, IllegalStateException, NoSuchElementException).with(mapper)
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverFailureClassArrayEmptyFirstClassNull() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(null, NullPointerException, NoSuchElementException).with [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassArrayEmptyThirdClassNull() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(NullPointerException, NoSuchElementException, null as Class<Throwable>).with [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassArrayEmptySecondClassNull() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(NullPointerException, null, NoSuchElementException).with [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassArraySuccessfullFirstClassNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure(null, NoSuchElementException, NullPointerException).with [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassArraySuccessfullSecondClassNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure(NoSuchElementException, null, NullPointerException).with [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassArraySuccessfullThirdClassNull() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure(NoSuchElementException, NullPointerException, null as Class<Throwable>).with [
			"foo"
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureFirstClassNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val result = t.tryRecoverFailure(null, NoSuchElementException, NullPointerException).with [
			"foo"
		]
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureSecondClassNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val result = t.tryRecoverFailure(NoSuchElementException, null, NullPointerException).with [
			"foo"
		]
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureThirdClassNull() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val result = t.tryRecoverFailure(NoSuchElementException, NullPointerException, null as Class<Throwable>).with [
			"foo"
		]
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverFailureClassArraySuccess() {
		val t = Try.completedSuccessfully("bar")
		val result = t.tryRecoverFailure(NullPointerException, NoSuchElementException, IllegalArgumentException).with ["foo"]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureFirstMatching() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(ArrayIndexOutOfBoundsException, NoSuchElementException, IllegalArgumentException).with [expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureSecondMatching() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(NoSuchElementException, ArrayIndexOutOfBoundsException, IllegalArgumentException).with [expected]
		result.assertSuccess(expected)
	}


	@Test
	def void testTryRecoverFailureClassArrayFailureThirdMatching() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(NoSuchElementException, IllegalArgumentException, ArrayIndexOutOfBoundsException).with [expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureFirstSuperType() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(RuntimeException, NoSuchElementException, NullPointerException).with [expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureSecondSuperType() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(NoSuchElementException, RuntimeException, NullPointerException).with [expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureThirdSuperType() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val expected = "bar"
		val result = t.tryRecoverFailure(NoSuchElementException, NullPointerException, RuntimeException).with [expected]
		result.assertSuccess(expected)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureNotMatching() {
		val t = Try.completedFailed(new ArrayIndexOutOfBoundsException)
		val result = t.tryRecoverFailure(NoSuchElementException, IllegalArgumentException, NullPointerException).with ["bar"]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureExceptionPassedToLambda() {
		extension val result = new Object {
			var actualException = null
		}
		val expected = new ArrayIndexOutOfBoundsException
		val t = Try.completedFailed(expected)
		t.tryRecoverFailure(ArrayIndexOutOfBoundsException, RuntimeException, NullPointerException).with [
			actualException = it
		]
		actualException.assertSame(expected)
	}

	@Test
	def void testTryRecoverFailureClassArrayEmpty() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(ArrayIndexOutOfBoundsException, RuntimeException, NullPointerException).with ["bar"]
		result.assertSame(t)
	}


	@Test
	def void testTryRecoverFailureClassArraySuccessThrowException() {
		val t = Try.completedSuccessfully("bar")
		val expected = new NoSuchElementException
		val result = t.tryRecoverFailure(Throwable, NoSuchElementException, NullPointerException).with [throw expected]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureThrowException() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val expected = new NoSuchElementException
		val result = t.tryRecoverFailure(RuntimeException, IllegalArgumentException, NullPointerException).with [throw expected]
		result.assertFailedWith(expected)
		expected.assertSuppressed(wrapped)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureThrowExceptionClassNotMatching() {
		val t = Try.completedFailed(new IllegalArgumentException)
		val result = t.tryRecoverFailure(IllegalStateException, NoSuchElementException, NullPointerException).with [new NoSuchElementException]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassArrayEmptyThrowException() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(Exception, Throwable, NullPointerException).with [new NoSuchElementException]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassArraySuccessNullRecovery() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryRecoverFailure(NoSuchElementException, Throwable, NullPointerException).with [null]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassArrayEmptyNullRecovery() {
		val t = Try.completedEmpty
		val result = t.tryRecoverFailure(NoSuchElementException, Exception, NullPointerException).with [null]
		result.assertSame(t)
	}

	@Test
	def void testTryRecoverFailureClassArrayFailureNullRecovery() {
		val t = Try.completedFailed(new IllegalStateException)
		val result = t.tryRecoverFailure(RuntimeException, IllegalStateException, NullPointerException).with [null]
		result.assertEmpty
	}

	/////////////
	// thenTry //
	/////////////

	@Test
	def void testThenTrySuccessActionNull() {
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTry(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryEmptyActionNull() {
		val t = Try.completedEmpty
		val result = t.thenTry(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryFailedActionNull() {
		val expectedSuppressed = new NoSuchElementException
		val t = Try.completedFailed(expectedSuppressed)
		val result = t.thenTry(null)
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(expectedSuppressed)
	}

	@Test
	def void testThenTrySuccessSuccess() {
		val Integer expected = 42
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTry [
			expected
		]
		result.assertSuccess(expected)
	}

	@Test
	def void testThenTrySuccessTestInput() {
		val expectedMapped = "bla"
		val t = Try.completedSuccessfully(expectedMapped)
		extension val context = new Object {
			var actualMapped = null
		}
		t.thenTry [
			actualMapped = it
			42
		]
		actualMapped.assertSame(expectedMapped)
	}

	@Test
	def void testThenTryFailureSuccess() {
		val t = Try.completedFailed(new NoSuchElementException)
		val result = t.thenTry [
			42
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryEmptySuccess() {
		val t = Try.completedEmpty
		val result = t.thenTry [
			42
		]
		result.assertSame(t)
	}


	@Test
	def void testThenTrySuccessEmpty() {
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTry [
			null
		]
		result.assertEmpty
	}

	@Test
	def void testThenTryFailureEmpty() {
		val t = Try.completedFailed(new NoSuchElementException)
		val result = t.thenTry [
			null
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryEmptyEmpty() {
		val t = Try.completedEmpty
		val result = t.thenTry [
			null
		]
		result.assertSame(t)
	}


	@Test
	def void testThenTrySuccessThrowing() {
		val t = Try.completedSuccessfully("bla")
		val expectedException = new IllegalArgumentException
		val result = t.thenTry [
			throw expectedException
		]
		result.assertFailedWith(expectedException)
	}

	@Test
	def void testThenTryFailureThrowing() {
		val t = Try.completedFailed(new NoSuchElementException)
		val result = t.thenTry [
			throw new IllegalArgumentException
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryEmptyThrowing() {
		val t = Try.completedEmpty
		val result = t.thenTry [
			throw new IllegalArgumentException
		]
		result.assertSame(t)
	}

	/////////////////////
	// thenTryOptional //
	/////////////////////

	@Test
	def void testThenTryOptionalSuccessActionNull() {
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTryOptional(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryOptionalEmptyActionNull() {
		val t = Try.completedEmpty
		val result = t.thenTryOptional(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryOptionalFailedActionNull() {
		val expectedSuppressed = new NoSuchElementException
		val t = Try.completedFailed(expectedSuppressed)
		val result = t.thenTryOptional(null)
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(expectedSuppressed)
	}

	@Test
	def void testThenTryOptionalSuccessSuccessPresent() {
		val Integer expected = 42
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTryOptional [
			Optional.of(expected)
		]
		result.assertSuccess(expected)
	}

	@Test
	def void testThenTryOptionalSuccessSuccessEmpty() {
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTryOptional [
			Optional.empty
		]
		result.assertEmpty
	}

	@Test
	def void testThenTryOptionalSuccessTestInput() {
		val expectedMapped = "bla"
		val t = Try.completedSuccessfully(expectedMapped)
		extension val context = new Object {
			var actualMapped = null
		}
		t.thenTryOptional [
			actualMapped = it
			Optional.empty
		]
		actualMapped.assertSame(expectedMapped)
	}

	@Test
	def void testThenTryOptionalFailureSuccess() {
		val t = Try.completedFailed(new NoSuchElementException)
		val result = t.thenTryOptional [
			Optional.of(42)
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryOptionalEmptySuccess() {
		val t = Try.completedEmpty
		val result = t.thenTryOptional [
			Optional.of(42)
		]
		result.assertSame(t)
	}


	@Test
	def void testThenTryOptionalSuccessNull() {
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTryOptional [
			null
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryOptionalFailureNull() {
		val t = Try.completedFailed(new NoSuchElementException)
		val result = t.thenTryOptional [
			null
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryOptionalEmptyNill() {
		val t = Try.completedEmpty
		val result = t.thenTryOptional [
			null
		]
		result.assertSame(t)
	}


	@Test
	def void testThenTryOptionalSuccessThrowing() {
		val t = Try.completedSuccessfully("bla")
		val expectedException = new IllegalArgumentException
		val result = t.thenTryOptional [
			throw expectedException
		]
		result.assertFailedWith(expectedException)
	}

	@Test
	def void testThenTryOptionalFailureThrowing() {
		val t = Try.completedFailed(new NoSuchElementException)
		val result = t.thenTryOptional [
			throw new IllegalArgumentException
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryOptionalEmptyThrowing() {
		val t = Try.completedEmpty
		val result = t.thenTryOptional [
			throw new IllegalArgumentException
		]
		result.assertSame(t)
	}


	/////////////
	// thenTry //
	/////////////

	private static class CloseableImpl implements AutoCloseable {
		
		public var closed = false
		
		override close() throws Exception {
			closed = true
		}
		
	}
	
	@Test
	def void testThenTryWithSuccessActionNull() {
		val t = Try.completedSuccessfully("bla")
		extension val context = new Object {
			var resourceProducerNotCalled = true
		}
		val result = t.thenTryWith([resourceProducerNotCalled = false; null], null)
		resourceProducerNotCalled.assertTrue
		result.assertFailedWithNPE
	}
	
	@Test
	def void testThenTryWithSuccessRessourceProviderNull() {
		val t = Try.completedSuccessfully("bla")
		extension val context = new Object {
			var actionNotCalled = true
		}
		val result = t.thenTryWith(null) [
			actionNotCalled = false
		]
		actionNotCalled.assertTrue
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryWithEmptyActionNull() {
		val t = Try.completedEmpty
		extension val context = new Object {
			var resourceProducerNotCalled = true
		}
		val result = t.thenTryWith([resourceProducerNotCalled = false; null], null)
		resourceProducerNotCalled.assertTrue
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryWithEmptyRessourceProviderNull() {
		val t = Try.completedEmpty
		extension val context = new Object {
			var actionNotCalled = true
		}
		val result = t.thenTryWith(null) [
			actionNotCalled = false
		]
		actionNotCalled.assertTrue
		result.assertFailedWithNPE
	}
	
	@Test
	def void testThenTryWithFailedActionNull() {
		val t = Try.completedFailed(new IllegalStateException)
		extension val context = new Object {
			var resourceProducerNotCalled = true
		}
		val result = t.thenTryWith([resourceProducerNotCalled = false; null], null)
		resourceProducerNotCalled.assertTrue
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryWithFailedRessourceProviderNull() {
		val t = Try.completedFailed(new IllegalStateException)
		extension val context = new Object {
			var actionNotCalled = true
		}
		val result = t.thenTryWith(null) [
			actionNotCalled = false
		]
		actionNotCalled.assertTrue
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryFailedWithActionNull() {
		val expectedSuppressed = new NoSuchElementException
		val t = Try.completedFailed(expectedSuppressed)
		extension val context = new Object {
			var resourceProducerNotCalled = true
		}
		val result = t.thenTryWith([resourceProducerNotCalled = false; null], null)
		resourceProducerNotCalled.assertTrue
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(expectedSuppressed)
	}

	@Test
	def void testThenTryWithSuccessSuccess() {
		val Integer expected = 42
		val t = Try.completedSuccessfully("bla")
		val closeable = new CloseableImpl
		val result = t.thenTryWith([closeable]) [
			expected
		]
		result.assertSuccess(expected)
		closeable.closed.assertTrue
	}

	@Test
	def void testThenTryWithSuccessTestInput() {
		val expectedMapped = "bla"
		val t = Try.completedSuccessfully(expectedMapped)
		extension val context = new Object {
			var actualMapped = null
		}
		t.thenTryWith([new CloseableImpl]) [r,i|
			actualMapped = i
			42
		]
		actualMapped.assertSame(expectedMapped)
	}

	@Test
	def void testThenTrySuccessTestCloseable() {
		val expectedMapped = "bla"
		val t = Try.completedSuccessfully(expectedMapped)
		extension val context = new Object {
			var actualResource = null
		}
		val closeable = new CloseableImpl
		t.thenTryWith([closeable]) [r,i|
			actualResource = r
			42
		]
		actualResource.assertSame(closeable)
	}

	@Test
	def void testThenTrySuccessTestResourceNull() {
		val expected = "bla"
		val t = Try.completedSuccessfully("foo")
		extension val context = new Object {
			var actualResource = null
		}
		val result = t.thenTryWith([null]) [r,i|
			actualResource = r
			expected
		]
		result.assertSuccess(expected)
		actualResource.assertNull
	}

	@Test
	def void testThenTrySuccessTestCloseableThrowing() {
		val t = Try.completedSuccessfully( "bla")
		val expectedException = new IllegalArgumentException
		val result = t.thenTryWith([[throw expectedException]]) [r,i|
			42
		]
		result.assertFailedWith(expectedException)
	}
	
	@Test
	def void testThenTrySuccessTestCloseableProviderThrowing() {
		val t = Try.completedSuccessfully("bla")
		val expectedException = new IllegalStateException
		val result = t.thenTryWith([throw expectedException]) [r,i|
			42
		]
		result.assertFailedWith(expectedException)
	}

	@Test
	def void testThenTryWithFailureSuccess() {
		val t = Try.completedFailed(new NoSuchElementException)
		val result = t.thenTryWith([new CloseableImpl]) [r,i|
			42
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryWithEmptySuccess() {
		val t = Try.completedEmpty
		val result = t.thenTryWith([new CloseableImpl]) [
			42
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryWithSuccessEmpty() {
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTryWith([new CloseableImpl]) [
			null
		]
		result.assertEmpty
	}

	@Test
	def void testThenTryWithFailureEmpty() {
		val t = Try.completedFailed(new NoSuchElementException)
		val result = t.thenTryWith([new CloseableImpl]) [
			null
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryWithEmptyEmpty() {
		val t = Try.completedEmpty
		val result = t.thenTryWith([new CloseableImpl]) [
			null
		]
		result.assertSame(t)
	}


	@Test
	def void testThenTryWithSuccessThrowing() {
		val t = Try.completedSuccessfully("bla")
		val expectedException = new IllegalArgumentException
		val closeable = new CloseableImpl
		val result = t.thenTryWith([closeable]) [
			throw expectedException
		]
		result.assertFailedWith(expectedException)
		closeable.closed.assertTrue
	}

	@Test
	def void testThenTryWithFailureThrowing() {
		val t = Try.completedFailed(new NoSuchElementException)
		val result = t.thenTryWith([new CloseableImpl]) [
			throw new IllegalArgumentException
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryWithEmptyThrowing() {
		val t = Try.completedEmpty
		val result = t.thenTryWith([new CloseableImpl]) [
			throw new IllegalArgumentException
		]
		result.assertSame(t)
	}


	/////////////////
	// thenTryFlat //
	/////////////////

	@Test
	def void testThenTryFlatSuccessActionNull() {
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTryFlat(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryFlatEmptyActionNull() {
		val t = Try.completedEmpty
		val result = t.thenTryFlat(null)
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryFlatFailedActionNull() {
		val expectedSuppressed = new NoSuchElementException
		val t = Try.completedFailed(expectedSuppressed)
		val result = t.thenTryFlat(null)
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(expectedSuppressed)
	}

	@Test
	def void testThenTryFlatSuccessActionReturnsSuccess() {
		val Integer expected = 42
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTryFlat [
			completedSuccessfully(expected)
		]
		val succ = result.assertIsInstanceOf(Try.Success)
		succ.get.assertSame(expected)
	}

	@Test
	def void testThenTryFlatSuccessActionReturnsEmpty() {
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTryFlat [
			completedEmpty
		]
		result.assertEmpty
	}

	@Test
	def void testThenTryFlatSuccessActionReturnsFailure() {
		val expected = new IllegalArgumentException
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTryFlat [
			completedFailed(expected)
		]
		result.assertFailedWith(expected)
	}

	@Test
	def void testThenTryFlatSuccessActionReturnsNull() {
		val t = Try.completedSuccessfully("bla")
		val result = t.thenTryFlat [
			null
		]
		result.assertFailedWithNPE
	}

	@Test
	def void testThenTryFlatSuccessTestInput() {
		val expectedMapped = "bla"
		val t = Try.completedSuccessfully(expectedMapped)
		extension val context = new Object {
			var actualMapped = null
		}
		t.thenTryFlat [
			actualMapped = it
			completedEmpty
		]
		actualMapped.assertSame(expectedMapped)
	}

	@Test
	def void testThenTryFlatFailureSuccess() {
		val t = Try.completedFailed(new NoSuchElementException)
		val result = t.thenTryFlat [
			completedEmpty
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryFlatEmptySuccess() {
		val t = Try.completedEmpty
		val result = t.thenTryFlat [
			completedEmpty
		]
		result.assertSame(t)
	}

	@Test
	def void testThenTryFlatSuccessThrowing() {
		val t = Try.completedSuccessfully("bla")
		val expectedException = new IllegalArgumentException
		val result = t.thenTryFlat [
			throw expectedException
		]
		result.assertFailedWith(expectedException)
	}


	//////////////////
	// tryTransform //
	//////////////////

	@Test
	def void testTryTransformResultTransformerNullEmpty() {
		val t = Try.completedEmpty
		val result = t.tryTransform(null,["foo"], ["bar"])
		result.assertFailedWithNPE
	}

	@Test
	def void testTryTransformResultTransformerNullSuccess() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryTransform(null,["foo"], ["bar"])
		result.assertFailedWithNPE
	}

	@Test
	def void testTryTransformResultTransformerNullFailure() {
		val expectedException = new IllegalArgumentException
		val t = Try.completedFailed(expectedException)
		val result = t.tryTransform(null,["foo"], ["bar"])
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(expectedException)
	}


	@Test
	def void testTryTransformExceptionTransformerNullEmpty() {
		val t = Try.completedEmpty
		val result = t.tryTransform(["foo"], null, ["bar"])
		result.assertFailedWithNPE
	}

	@Test
	def void testTryTransformExceptionTransformerNullSuccess() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryTransform(["foo"], null, ["bar"])
		result.assertFailedWithNPE
	}

	@Test
	def void testTryTransformExceptionTransformerNullFailure() {
		val expectedException = new IllegalArgumentException
		val t = Try.completedFailed(expectedException)
		val result = t.tryTransform(["foo"], null, ["bar"])
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(expectedException)
	}


	@Test
	def void testTryTransformEmptyTransformerNullEmpty() {
		val t = Try.completedEmpty
		val result = t.tryTransform(["foo"], ["bar"], null)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryTransformEmptyTransformerNullSuccess() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryTransform(["foo"], ["bar"], null)
		result.assertFailedWithNPE
	}

	@Test
	def void testTryTransformEmptyTransformerNullFailure() {
		val expectedException = new IllegalArgumentException
		val t = Try.completedFailed(expectedException)
		val result = t.tryTransform(["foo"], ["bar"], null)
		val ex = result.assertFailedWithNPE
		ex.assertSuppressed(expectedException)
	}

	@Test
	def void testTryTransformSuccessTransformerResultSuccess() {
		val t = Try.completedSuccessfully(42)
		val expected = "whoot"
		val result = t.tryTransform([expected],["foo"], ["bar"])
		result.assertSuccess(expected)
	}

	@Test
	def void testTryTransformSuccessTransformerResultSuccessTestInput() {
		val expected = "foo"
		val t = Try.completedSuccessfully(expected)
		extension val context = new Object {
			var lambdaParam = null
		}
		t.tryTransform([
			lambdaParam = it
			""
		],["foo"], ["bar"])
		expected.assertEquals(lambdaParam)
	}

	@Test
	def void testTryTransformSuccessTransformerReturnsNullSuccess() {
		val t = Try.completedSuccessfully("foo")
		val result = t.tryTransform([null],["foo"], ["bar"])
		result.assertEmpty
	}

	@Test
	def void testTryTransformSuccessTransformerThrowingSuccess() {
		val t = Try.completedSuccessfully("foo")
		val expectedException = new IllegalStateException
		val result = t.tryTransform([throw expectedException],["foo"], ["bar"])
		result.assertFailedWith(expectedException)
	}


	@Test
	def void testTryTransformExceptionTransformerResultFailure() {
		val t = Try.completedFailed(new IllegalArgumentException)
		val expected = "bar"
		val result = t.tryTransform(["foo"], [expected], ["bar"])
		result.assertSuccess(expected)
	}

	@Test
	def void testTryTransformExceptionTransformerResultFailureTestInput() {
		val expectedException = new IllegalArgumentException
		val t = Try.completedFailed(expectedException)
		extension val context = new Object {
			var actualLambdaParam = null
		}
		t.tryTransform(["foo"], [
			actualLambdaParam = it
			"baz"
		], ["bar"])
		expectedException.assertSame(actualLambdaParam)
	}

	@Test
	def void testTryTransformExceptionTransformerEmptyFailure() {
		val t = Try.completedFailed(new IllegalArgumentException)
		val result = t.tryTransform(["foo"], [null], ["bar"])
		result.assertEmpty
	}

	@Test
	def void testTryTransformExceptionTransformerThrowingFailure() {
		val wrapped = new IllegalArgumentException
		val t = Try.completedFailed(wrapped)
		val expectedException = new ArrayIndexOutOfBoundsException
		val result = t.tryTransform(["foo"], [throw expectedException], ["bar"])
		result.assertFailedWith(expectedException)
		expectedException.assertSuppressed(wrapped)
	}

	@Test
	def void testTryTransformEmptyTransformerResultEmpty() {
		val t = Try.completedEmpty
		val expected = 42
		val result = t.tryTransform([33],[22],[expected])
		result.assertSuccess(expected)
	}

	@Test
	def void testTryTransformEmptyTransformerReturnsNullEmpty() {
		val t = Try.completedEmpty
		val result = t.tryTransform(["foo"],["bar"],[null])
		result.assertEmpty
	}

	@Test
	def void testTryTransformEmptyTransformerThrowsEmpty() {
		val t = Try.completedEmpty
		val expectedException = new IllegalArgumentException
		val result = t.tryTransform(["foo"],["bar"],[throw expectedException])
		result.assertFailedWith(expectedException)
	}

	///////////
	// utils //
	///////////


	private def NullPointerException assertFailedWithNPE(Try<?> result) {
		val fail = result.assertIsInstanceOf(Try.Failure)
		fail.get.assertIsInstanceOf(NullPointerException)
	}

	private def <T> void assertSuccess(Try<T> result, T expectedValue) {
		val succ = result.assertIsInstanceOf(Try.Success)
		expectedValue.assertSame(succ.get)
	}

	private def <E extends Exception> void assertFailedWith(Try<?> result, E e) {
		val failure = result.assertIsInstanceOf(Try.Failure)
		failure.get.assertSame(e)
	}

	private def void assertEmpty(Try<?> result) {
		result.assertIsInstanceOf(Try.Empty)
	}
	
	private def void assertSuppressed(Exception e, Exception suppressed) {
		e.suppressed.assertArrayEquals(#[suppressed])
	}
}