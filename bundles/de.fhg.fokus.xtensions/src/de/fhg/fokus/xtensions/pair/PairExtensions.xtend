package de.fhg.fokus.xtensions.pair

import java.util.Optional
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*

/**
 * Provides static extension methods for the {@code Pair} class.
 */
final class PairExtensions {

	private new() {
		throw new IllegalStateException
	}
	
	/**
	 * Will call the given {@code consumer} with the key and value extracted from {@code pair}.
	 * If the given {@code consumer} throws an exception it will be thrown out of this method.
	 * @param pair the Pair from which key and value are taken and passed to {@code consumer}.
	 * @param consumer will be called with key and value from {@code pair}
	 * @return the same reference passed in as {@code pair}
	 */
	static def <K,V> Pair<K,V> =>(Pair<K,V> pair, (K,V)=>void consumer) {
		consumer.apply(pair.key, pair.value)
		pair
	}
	
	/**
	 * Will call the {@code combiner} with the key and the value of {@code pair} and returns
	 * the result of the {@code combiner} call. This function can be used as a {@code flatMap}
	 * function by returning a new {@code Pair}.
	 * @param pair the Pair from which key and value are taken and passed to {@code combiner}
	 * @param combiner the function to be called with key and value from {@code pair}
	 * @return result returned by {@code combiner}.
	 */
	static def <K,V,R> R combine(Pair<K,V> pair, (K,V)=>R combiner) {
		combiner.apply(pair.key,pair.value)
	}
	
	/**
	 * If {@code pair}, or key or value of the given {@code pair} is {@code null}, this function returns an empty {@code Optional}.
	 * Otherwise the {@code combiner} will be called with the key and the value of {@code pair} and returns
	 * the result of the {@code combiner} call wrapped in an {@code Optional}. If the result of {@code combiner} 
	 * is {@code null} an empty Optional will be returned.
	 * @param pair the Pair from which key and value are taken and passed to {@code combiner} if none of them is {@code null}.
	 * @param combiner the function to be called with non-null key and value from {@code pair}
	 * @return result returned by {@code combiner} wrapped in an Optional
	 */
	static def <K,V,R> Optional<R> safeCombine(Pair<K,V> pair, (K,V)=>R combiner) {
		if(pair === null) {
			return none
		}
		val key = pair.key
		if(key === null) {
			return none
		}
		val value = pair.value
		if(value === null) {
			return none
		}
		val result = combiner.apply(key,value)
		maybe(result)
	}
	
	// TODO really useful? basically special case of combine (without boxing of boolean).
//	/**
//	 * Will check if key and value from {@code pair} the test true with the given {@code predicate}.
//	 * The result of the test is returned by this function.
//	 * @param pair the Pair, that's key and value are tested by the given {@code predicate}.
//	 * @param predicate will test key and value
//	 * @return the result of {@code predicate} applied to key and value of {@code pair}
//	 */
//	static def <K,V> boolean test(Pair<K,V> pair, BiPredicate<K,V> predicate) {
//		predicate.test(pair.key,pair.value)
//	}
}