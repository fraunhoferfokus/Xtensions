package de.fhg.fokus.xtenders.pair

import java.util.Optional
import java.util.function.BiPredicate

class PairExtensions {
	
	static def <K,V> void consume(Pair<K,V> pair, (K,V)=>void consumer) {
		consumer.apply(pair.key, pair.value)
	}
	
	static def <K,V,R> R combine(Pair<K,V> pair, (K,V)=>R combiner) {
		return combiner.apply(pair.key,pair.value)
	}
	
	static def <K,V,R> boolean test(Pair<K,V> pair, BiPredicate<K,V> predicate) {
		return predicate.test(pair.key,pair.value)
	}
	
	static def <K,V,R> Optional<R> safeCombine(Pair<K,V> pair, (K,V)=>R combiner) {
		val key = pair.key
		if(key === null) {
			return Optional.empty
		}
		val value = pair.value
		if(value === null) {
			return Optional.empty
		}
		val result = combiner.apply(key,value)
		return Optional.ofNullable(result)
	}
	
}