package de.fhg.fokus.xtensions.incubation.iteration

import java.util.Collections
import java.util.Optional
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*

/**
 * <br>
 * All extension methods here will never return a {@code null} value and 
 * functions passed to the functions will never receive a {@code null} value.
 */
class SafeIterable {
	
	public static def <T,U> safeMap(Iterable<T> iterable, extension (T)=>U mapper) {
		iterable?.map[it?.apply]?.filterNull.orEmpty // maybe replace with filterOrMap when done
	}
	
	public static def <T,U> safeFilter(Iterable<T> iterable, extension (T)=>boolean test) {
		iterable?.filter[it?.apply ?: false].orEmpty
	}
	
	public static def <T> Optional<T> safeFindFirst(Iterable<T> iterable, extension (T)=>boolean test) {
		iterable?.findFirst[it?.apply ?: false].maybe
	}
	
	private static def <T> Iterable<T> orEmpty(Iterable<T> iterable) {
		iterable ?: Collections.emptyList
	}
}