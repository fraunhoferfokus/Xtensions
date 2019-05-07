package de.fhg.fokus.xtensions.incubation.exceptions

import static extension de.fhg.fokus.xtensions.incubation.exceptions.TryIteratorExtensions.*
import static extension org.junit.Assert.*
import java.util.List
import java.util.NoSuchElementException

class TryIteratorExtensionsTest {

	/////////////////////
	// toListSkipEmpty //
	/////////////////////

	def void testToListSkipEmpty() {
		
		val iterator = emptyTryIterator
		
		val Try<List<Object>> expectEmpty = iterator.toListSkipEmpty()
		switch(expectEmpty) {
			Try<List<Object>>: expectEmpty.isEmpty.assertTrue
			default: fail()
		}
	}
	
	
	private static def <T> TryIterator<T> emptyTryIterator() {
		new TryIterator {
			
			override protected computeNext() throws NoSuchElementException {
				throw new NoSuchElementException
			}
			
			override hasNext() {
				false
			}
			
		} as TryIterator as TryIterator<T>
	}
}