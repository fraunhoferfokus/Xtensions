package de.fhg.fokus.xtensions.incubation.iteration

import java.util.stream.Stream
import java.util.Iterator
import java.util.stream.StreamSupport
import java.util.Spliterator
import java.util.Spliterators
import com.google.common.collect.AbstractIterator
import java.util.function.Predicate

/**
 * Extension methods to the {@link Iterator} class.
 */
class IteratorExtensions {
	
	// TODO excluding(T... obj) /*maybe use set under the hood*/, excluding(Iterable<T>), excluding(Set<T>)
	// TODO public static def <T,Y> Iterator<Y> mapIf(Iterator<T>, Predicate<T>, Function1<T,Y>)
	// TODO public static def <T,Y> Optional<Y> findFirst(Iterator<T>, Class<? extends Y> clazz)
	// TODO public static def <T  extends Comparable<? super T>> Optional<Pair<T,T>> minMax(Iterator<T>)
	// TODO public static def <T> Optional<Pair<T,T>> minMax(Iterator<T>, Comparator<? super T> comparator)
	// TODO filter2(Predicate<T>), exists2(Predicate<T>), dropWhile2(Predicate<T>), takeWhile2(Predicate<T>), Optional<T> findLast2(Predicate<T>), forall2(Predicate<T>)
	// TODO all of the above for Iterable
	
	/**
	 * Creates a Java 8 stream of all remaining elements provided by the {@code iterator}.
	 */
	public static def <T> Stream<T> streamRemaining(Iterator<T> iterator) {
		val spliterator = Spliterators.spliteratorUnknownSize(iterator, Spliterator.ORDERED)
		StreamSupport.stream(spliterator,false);
	}
	
	// TODO create same for Iterable
	/**
	 * This function will either map elements of the given {@code iterator} to elements 
	 * of type {@code U} or filter elements.<br>
	 * The instance of {@code FilterOrMapResult} returned by {@code filterMapper} must be created
	 * by calling {@link FilterOrMap#filter()} or {@link FilterOrMap#mapTo(Object)} on the 
	 * {@code FilterOrMap} instance passed as the parameter to {@code filterMapper}.<br>
	 * The {@code FilterOrMap} object passed to {@code filterMapper} must only be used in the 
	 * {@code filterMapper} function, because it is not guaranteed to stay stable between iterations.
	 * Meaning that after {@code filterMapper} returns the values of the {@code FilterOrMap} instance
	 * may change.
	 * <br><br>
	 * Example: <pre>{@code 
	 * #[1,-2,3,-4].iterator.filterOrMap[
	 * 	val el = element
	 * 		if(el > 0)
	 * 			map(el * 2)
	 * 		else 
	 * 			filter
	 * ]}</pre>
	 * @param iterator
	 * @param filterMapper
	 * @return
	 */
	public static def <T,U> Iterator<U> filterOrMap(Iterator<T> iterator, (FilterOrMap<T,U>)=>FilterOrMapResult<U> filterMapper) {
		val result = new AbstractIterator<U> {

			val context = new FilterOrMap<T,U>
			val result = context.result
			
			override protected computeNext() {
				while(iterator.hasNext) {
					// work on stack references
					val context = this.context
					// reset context for next filterMapper call
					context.current = iterator.next
					result => [
						mapped = null
						filter = false
					]
					var ret = filterMapper.apply(context)
					// if element not filtered, provide mapped value as next element
					if(!ret.filter) {
						return ret.mapped
					} // else continue in loop with next element
				}
				endOfData
			}
			
		}
		result
	}
	
	public static def <Y,T extends Y> Iterator<Y> mapIf(Iterator<T> iterator, Predicate<T> test, (T)=>Y mapper) {
		new Iterator<Y>() {
			
			override hasNext() {
				iterator.hasNext
			}
			
			override next() {
				val current = iterator.next
				if(test.test(current)) {
					mapper.apply(current)
				} else {
					current
				}
			}
			
		}
	}

	private static def <T,U> Iterator<U> nextIterator(Iterator<T> iterator, (T)=>Iterator<U> mapper) {
		while(iterator.hasNext) {
			val nextEl = iterator.next
			val nextIt = mapper.apply(nextEl)
			if(nextIt !== null && nextIt.hasNext) {
				return nextIt
			}
		}
		// no further iterator found
		null
	}
	
	/**
	 * Instances of this class can only be accessed by calling
	 * <ul>
	 * 	<li>{@link FilterOrMap#filter()} or</li>
	 * 	<li>{@link FilterOrMap#mapTo(Object)}</li>
	 * </ul>
	 */
	public static class FilterOrMapResult<U> {
		private var U mapped
		private var filter = false
		private new(){}
	}
	
	public static class FilterOrMap<T,U> {
		private var T current
		private val result = new FilterOrMapResult<U>
		private new(){}
		
		/**
		 * Returning the current element iterated over
		 */
		def T element() {current}
		
		/**
		 * Filters the current element from the returned iterator
		 */
		def FilterOrMapResult<U> filter(){
			result.filter = true
			result
		}
		
		/**
		 * Maps the current element (provided via {@link #element()}) to
		 * an element of type {@code U}.
		 */
		def FilterOrMapResult<U> map(U mapped){
			result.mapped = mapped
			result
		}
	}
	
	
}