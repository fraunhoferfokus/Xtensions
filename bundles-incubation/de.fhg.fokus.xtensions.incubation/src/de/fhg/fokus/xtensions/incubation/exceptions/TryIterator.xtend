package de.fhg.fokus.xtensions.incubation.exceptions

import java.util.Iterator
import java.util.List
import java.util.Set
import java.util.stream.Collector
import java.util.NoSuchElementException
import java.util.function.Predicate
import java.util.Optional
import de.fhg.fokus.xtensions.incubation.exceptions.TryIterator.FailureStrategy
import de.fhg.fokus.xtensions.exceptions.Try
import static extension java.util.Objects.*

/**
 * This class represents an iterator where the operation on elements may have failed.
 * Elements of this iterator may one of three states: Success, empty, failure.
 * A successful element is the regular case where the operation leading to this element
 * succeeded. An empty element is the case a {@code null} element is provided. The failure
 * case represents the state that the operation leading to the element failed with an exception.<br>
 * <br>
 * Note that under the covers the {@code  TryIterator} implementations makes sure not to allocate new 
 * {@link Try} objects along the way of iterator chains.
 * If extension methods from {@link org.eclipse.xtext.xbase.lib.IteratorExtensions IteratorExtensions} 
 * are used, the class will be used as a regular iterator, which will lead to allocations
 * of {@code Try} objects.
 */
abstract class TryIterator<T> implements Iterator<Try<T>> {

	package new(){}

	/**
	 * Represents a successful result to be returned via the {@link #next()}
	 * method.<br>
	 * Has to be set latest in {@code #computeNext()}, but it is also valid
	 * to be set in {@link #hasNext()}.
	 */
	protected T successfulResult = null
	
	/**
	 * Represents a failed result to be returned via the {@link #next()}
	 * method.<br>
	 * Has to be set latest in {@code #computeNext()}, but it is also valid
	 * to be set in {@link #hasNext()}.
	 */
	protected Throwable failureResult = null

	/**
	 * Strategy how to handle a failure in a "terminal" operation 
	 * on {@link TryIterator}, handling all 
	 */
	static enum FailureStrategy {
		/**
		 * This strategy will end the iteration over elements of a {@code TryIterator}
		 * when the first failure is reached. The failure will not be processed
		 */
		ON_FAILURE_STOP,
		
		/**
		 * When choosing this strategy, failures will simply filtered out, all other
		 * elements of the iterator are iterated over
		 */
		ON_FAILURE_SKIP,
		
		/**
		 * This strategy will cause the captured exception of the first failure case be
		 * re-thrown.
		 */
		ON_FAILURE_RETHROW
	}

	final override Try<T> next() {
		if(computeNext()) {
			Try.completed(successfulResult)
		} else {
			Try.completedFailed(failureResult)
		}
	}

	/**
	 * Will be called in {@link #next()} to compute the next value. After this method
	 * {@link #successfulResult} or {@link #failureResult} have to be set and return {@code true} if the 
	 * successful result was set and {@code false} if the 
	 * @return true if the next element is a success or empty, false if the result is a failure
	 */
	abstract protected def boolean computeNext() throws NoSuchElementException;

	final def Optional<T> findFirstSuccess(Predicate<T> test) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	/**
	 * Will skip over empty or failure results
	 */
	final def Optional<T> findFirstSuccess() {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def Optional<T> findFirstSuccess(FailureStrategy failureStrategy) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def TryIterator<T> filterOutFailure() {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def TryIterator<T> filterOutEmpty() {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def TryIterator<T> tryRecoverFailure((Throwable)=>T onError) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def <X extends Throwable> TryIterator<T> tryRecoverFailure(Class<X> errorClass, (X)=>T onError) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def <Y> TryIterator<Y> filterSuccess(Class<Y> filterClass) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}


	final def TryIterator<T> tryFilterSuccess(Predicate<T> mapper) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def <Y> TryIterator<Y> tryMapSuccess((T)=>Y mapper) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def <Y> TryIterator<Y> tryFlatMapSuccess((T)=>Iterator<Y> mapper) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	/**
	 * Map success and empty elements with one {@code mapper} function to elements of type
	 * {@code Y}. This will pass {@code null} to the mapper function on empty entries.
	 */
	final def <Y> TryIterator<Y> tryMapNullable((T)=>Y mapper) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def List<T> toListSkipEmpty(FailureStrategy failureStratey) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def Set<T> toSetSkipEmpty(FailureStrategy failureStratey) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}


	final def <R, A> R collectSuccess(FailureStrategy failureStratey, Collector<? super T, A, R> collector) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}


	/**
	 * Skips empty and failure entries
	 */
	final def void forEachSuccess((T)=>void consumer) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	final def void forEach((Throwable)=>void onFailure, (T)=>void onSuccess, ()=>void onEmpty) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	/**
	 * Method mapping non {@code null} elements of an iterator via the {@code mapper} method, returning
	 * a new iterator which provides the mapped elements. <br>
	 * Note that the mapper method may throw an exception, which is then not thrown to the caller
	 * of the {@code next} method. The returned {@link TryIterator} carries the state "failed"
	 * with the thrown exception for the element. {@code null} elements will result in {@code null}
	 * elements provided by the returned iterator.<br>
	 * This method is meant to be used as an extension method on {@code context}.
	 * 
	 * @param context the iterator for which a wrapper is created mapping the elements
	 *  using the {@code mapper}. Must not be {@code null}.
	 * @param mapper the function mapping the elements of {@code context}. Elements passed
	 * to the {@code mapper} are never {@code null}. This parameter must not be {@code null}.
	 * @param <T> type of elements provided by {@code context}
	 * @param <Y> type of mapped elements provided by the returned iterator
	 * @return an iterator providing the mapped values, or failures, in cases the 
	 *  given {@code mapper} throws an exception.
	 * @see #tryMapNullable(Iterator, Function1)
	 */
	static def <T,Y> TryIterator<Y> tryMap(Iterator<T> context, (T)=>Y mapper) {
		context.requireNonNull("context must not be null")
		mapper.requireNonNull("mapper must not be null")
		new TryIterator<Y>() {
			
			override protected computeNext() throws NoSuchElementException {
				val toMap = context.next
				try {
					this.successfulResult = 
						if (toMap === null) {
							null
						} else {
							mapper.apply(toMap)
						}
					true
				} catch(Throwable t) {
					this.failureResult = t
					false
				}
			}
			
			override hasNext() {
				context.hasNext
			}
			
		}
	}

	/**
	 * Method mapping elements of an iterator via the {@code mapper} method, returning
	 * a new iterator which provides the mapped elements. Note that {@code null} entries
	 * provided by {@code context} will also passed to the {@code mapper} functions.<br>
	 * Note that the {@code mapper} method may throw an exception, which is then not thrown to the caller
	 * of the {@code next} method. The returned {@link TryIterator} carries the state "failed"
	 * with the thrown exception for the element.<br>
	 * This method is meant to be used as an extension method on {@code context}.
	 * 
	 * @param context the iterator for which a wrapper is created mapping the elements
	 *  using the {@code mapper}. Must not be {@code null}.
	 * @param mapper The function mapping the elements of {@code context}. Elements passed
	 * to the {@code mapper} may be {@code null}. This parameter must not be {@code null}.
	 * @param <T> type of elements provided by {@code context}
	 * @param <Y> type of mapped elements provided by the returned iterator
	 * @return an iterator providing the mapped values, or failures, in cases the 
	 *  given {@code mapper} throws an exception.
	 * @see #tryMap(Iterator, Function1)
	 */
	static def <T,Y> TryIterator<Y> tryMapNullable(Iterator<T> context, (T)=>Y mapper) {
		context.requireNonNull("context must not be null")
		mapper.requireNonNull("mapper must not be null")
		new TryIterator<Y>() {
			
			override protected computeNext() throws NoSuchElementException {
				val toMap = context.next
				try {
					val mapped = mapper.apply(toMap)
					this.successfulResult = mapped
					true
				} catch(Throwable t) {
					this.failureResult = t
					false
				}
			}
			
			override hasNext() {
				context.hasNext
			}
			
		}
	}

	/**
	 * Method filtering elements of an iterator via the {@code predicate} method, returning
	 * a new iterator which provides all elements for which the {@code predicate} returns {@code true}. 
	 * Note that {@code null} entries provided by {@code context} will not passed to the {@code predicate}
	 * and will not filtered out.<br>
	 * Also note that the {@code predicate} function may throw an exception, which is then not thrown to the caller
	 * of the {@code next} method. The returned {@link TryIterator} carries the state "failed"
	 * with the thrown exception for the element.<br>
	 * This method is meant to be used as an extension method on {@code context}.
	 * 
	 * @param context iterator, that's elements are filtered by {@code predicate}
	 * @param predicate function that filters the elements of {@code context}. When the
	 *  predicate returns {@code true} for a given element, the element will be provided
	 *  by the returned iterator, otherwise it will be filtered out. {@code null} elements
	 *  are not passed to the {@code predicate}.
	 * @param <T> type of elements to be filtered
	 * @return an iterator of elements, empty elements (null), or failures (when {@code predicate} throws an exception)
	 * @see #tryFilterNullable(Iterator,Predicate)
	 */
	static def <T> TryIterator<T> tryFilter(Iterator<T> context, Predicate<T> predicate) {
		context.requireNonNull("context must not be null")
		predicate.requireNonNull("predicate must not be null")
		new FilteredIterator<T>(context, predicate, false)
	}
	
	/**
	 * Method filtering elements of an iterator via the {@code predicate} method, returning
	 * a new iterator which provides all elements for which the {@code predicate} returns {@code true}. 
	 * Note that {@code null} entries provided by {@code context} <em>are</em> passed to the {@code predicate}
	 * so predicates have to be prepared.<br>
	 * Also note that the {@code predicate} function may throw an exception, which is then not thrown to the caller
	 * of the {@code next} method. The returned {@link TryIterator} carries the state "failed"
	 * with the thrown exception for the element.<br>
	 * This method is meant to be used as an extension method on {@code context}.
	 * 
	 * @param context iterator, that's elements are filtered by {@code predicate}
	 * @param predicate function that filters the elements of {@code context}. When the
	 *  predicate returns {@code true} for a given element, the element will be provided
	 *  by the returned iterator, otherwise it will be filtered out. {@code null} elements
	 *  <em>are</em> passed to the {@code predicate}, so it has to be prepared.
	 * @param <T> type of elements to be filtered
	 * @return an iterator of elements, empty elements (null), or failures (when {@code predicate} throws an exception)
	 * @see #tryFilterNullable(Iterator,Predicate)
	 */
	static def <T> TryIterator<T> tryFilterNullable(Iterator<T> context, Predicate<T> predicate) {
		context.requireNonNull("context must not be null")
		predicate.requireNonNull("predicate must not be null")
		new FilteredIterator<T>(context, predicate, true)
	}
}

/**
 * Filtered {@code Iterator<T>} catching exceptions along the way
 */
package class FilteredIterator<T> extends LazyTryIterator<T> {
	
	val Iterator<T> context
	val boolean testNull
	val Predicate<T> predicate
	
	package new(Iterator<T> context, Predicate<T> predicate, boolean testNull) {
		this.context = context
		this.testNull = testNull
		this.predicate = predicate
	}
	
	override LazyIteratorState computeNextProvideState() {
		while(context.hasNext) {
			val toTest = context.next
			try {
				// we do not test null / empty elements
				if(!testNull && toTest === null) {
					successfulResult = null
					failureResult = null
					return LazyIteratorState.NEXT_COMPUTED_SUCCESS
				}
				if(predicate.test(toTest)) {
					successfulResult = toTest
					failureResult = null
					return LazyIteratorState.NEXT_COMPUTED_SUCCESS
				}
			} catch(Throwable t) {
				successfulResult = null
				failureResult = t
				return LazyIteratorState.NEXT_COMPUTED_FAILURE
			}
		}
		// no more elements
		successfulResult = null
		failureResult = null
		return LazyIteratorState.DONE
	}
	
}

package abstract class LazyTryIterator<T> extends TryIterator<T> {

	var state = LazyIteratorState.NEXT_PENDING

	final override protected computeNext() throws NoSuchElementException {
			val currState = computeNextIfNeeded()
			if(currState === LazyIteratorState.DONE) {
				throw new NoSuchElementException
			}
			val result = (currState === LazyIteratorState.NEXT_COMPUTED_SUCCESS)
			this.state = LazyIteratorState.NEXT_PENDING
			result
	}

	final private def LazyIteratorState computeNextIfNeeded() {
		val state = this.state
		if(state !== LazyIteratorState.NEXT_PENDING) {
			state
		} else {
			this.state = computeNextProvideState();
		}
	}

	protected abstract def LazyIteratorState computeNextProvideState();

	final override hasNext() {
		var state = computeNextIfNeeded()
		state !== LazyIteratorState.DONE
	}

}

package abstract class FilteringTryIterator<T> extends LazyTryIterator<T> {

	val FilteringTryIterator<T> source 

	new(FilteringTryIterator<T> source) {
		this.source = source
	}

	override LazyIteratorState computeNextProvideState() {
		while(source.hasNext) {
			try {
				val prevSuccess = source.successfulResult
				val prevFailure = source.failureResult
				if(tryFilter(prevFailure, prevSuccess)) {
					successfulResult = prevSuccess
					failureResult = prevFailure
					return LazyIteratorState.NEXT_COMPUTED_SUCCESS
				}
			} catch(Throwable t) {
				successfulResult = null
				failureResult = t
				return LazyIteratorState.NEXT_COMPUTED_FAILURE
			}
		}
		// no more elements
		successfulResult = null
		failureResult = null
		return LazyIteratorState.DONE
	}

	abstract def boolean tryFilter(Throwable prevFailureResult, T prevSuccessfullResult)

}

package enum LazyIteratorState {
	DONE,
	
	/**
	 * Includes empty elements
	 */
	NEXT_COMPUTED_SUCCESS,
	NEXT_COMPUTED_FAILURE,
	NEXT_PENDING
}
