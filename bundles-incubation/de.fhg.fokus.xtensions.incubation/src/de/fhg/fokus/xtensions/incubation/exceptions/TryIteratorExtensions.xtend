package de.fhg.fokus.xtensions.incubation.exceptions

import java.util.Iterator
import java.util.List
import java.util.Set
import java.util.stream.Collector
import de.fhg.fokus.xtensions.incubation.exceptions.TryIterator.FailureStrategy

/**
 * This class allows incubation of new methods to be introduced later directly into the {@code TryIterator}.
 */
class TryIteratorExtensions {
	
	static final def <T> Iterator<T> filterOutFailureNullableEntry(TryIterator<T> context) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	static final def <T> Iterator<T> filterOutNonSuccess(TryIterator<T> context) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	/**
	 * Strips the iterator of empty and failed entries, passing the failures
	 * to the given {@code errorConsumer} e.g. for logging purposes.
	 */
	static final def <T> Iterator<T> divertFailureSkipEmpty(TryIterator<T> context, (Throwable)=>void errorConsumer) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	static final def <T> TryIterator<T> recoverFailure(TryIterator<T> context, (Throwable)=>T onError) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	static final def <T> Iterator<T> recover(TryIterator<T> context, ()=>T onEmpty, (Throwable)=>T onFailure) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	static final def <T> TryIterator<T> tryRecover(TryIterator<T> context, ()=>T onEmpty, (Throwable)=>T onFailure) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	
	static final def <T,Y> TryIterator<Y> filterFailure(TryIterator<T> context, Class<? extends Throwable> filterClass) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	static final def <T,Y> TryIterator<Y> tryMapSuccessFlatten(TryIterator<T> context, (T)=>Try<Y> mapper) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	static final def <T> TryIterator<T> peekFailure(TryIterator<T> context, (Throwable)=>void failureConsumer) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	static final def <T> TryIterator<T> peekSuccess(TryIterator<T> context, (T)=>void successConsumer) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	
	/**
	 * This methods pulls elements from the iterator and returns either the list of all successful elements, 
	 * excluding the empty entries. If one element is an error, however, the returned {@code Try} will be a failure holding
	 * the exception. The iterator will not pulled any further after the error. This may be 
	 * interesting for lazily generated iterators.
	 * 
	 * @return either a list of successful elements (no {@code null} entries), or a failure if one element
	 *  is a failure.
	 */
	static final def <T> Try<List<T>> toListSkipEmpty(TryIterator<T> context) {
		val result = newArrayList
		while(context.hasNext) {
			if(context.computeNext()) {
				return Try.completedExceptionally(context.failureResult)
			} else {
				val current = context.successfulResult
				if(current !== null) {
					result.add(current)
				}
			}
		}
		return Try.completedSuccessfully(result)
	}

	/**
	 * First error will make complete result fail
	 */
	static final def<T>  Try<Set<T>> toSetSkipEmpty(TryIterator<T> context) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	/**
	 * First error will make complete result fail
	 */
	static final def <T> Try<List<T>> toListNullableEntries(TryIterator<T> context) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	/**
	 * First error will make complete result fail
	 */
	static final def <T> Try<Set<T>> toSetNullableEntries(TryIterator<T> context) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	
	/** 
	 * First error will produce a failed result
	 */
	static final def <T, R, A> Try<R> collectSkipEmpty(TryIterator<T> context, Collector<? super T, A, R> collector) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	/** 
	 * First error will produce a failed result
	 */
	static final def <T, R, A> Try<R> collectNullableEntries(TryIterator<T> context, Collector<? super T, A, R> collector) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	
	static final def <T> void forEachSkipEmpty(TryIterator<T> context, (Throwable)=>void onFailure, (T)=>void onSuccess) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	static final def <T> void forEachSkipEmpty(TryIterator<T> context, FailureStrategy failureStrategy, (T)=>void onSuccess) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	static final def <T> void forEachSkipFailure(TryIterator<T> context, ()=>void onEmpty, (T)=>void onSuccess) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	static final def <T> void forEachNullableEntries(TryIterator<T> context, (Throwable)=>void onFailure, (T)=>void onSuccessNullable) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	static final def <T> Iterator<T> asThrowingNullableIterator(TryIterator<T> context) {
		//TODO: implement
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}