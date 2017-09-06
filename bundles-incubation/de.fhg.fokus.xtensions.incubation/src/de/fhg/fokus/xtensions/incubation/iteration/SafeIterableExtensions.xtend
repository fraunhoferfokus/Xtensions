package de.fhg.fokus.xtensions.incubation.iteration

import java.util.Collections
import java.util.Optional
import static extension de.fhg.fokus.xtensions.optional.OptionalExtensions.*
import java.util.Objects

/**
 * <br>
 * All extension methods here will never return a {@code null} value and 
 * functions passed to the functions will never receive a {@code null} value.<br>
 * Be aware that these methods perform a lot of {@code null} checks, more than 
 * sometimes needed, especially when chaining the operations. However, if clarity and 
 * stability is more valuable than performance, the extension methods provided in this
 * class can make code more robust and clear.
 */
class SafeIterableExtensions {
	
//	public static def <T extends Comparable<? super T>> Optional<T> safeMax(Iterable<T> iterable) {...}
//	public static def <T> Optional<T> safeMax(Iterable<T> iterable, Comparator<? super T> comparator) {...}
//	public static def <T extends Comparable<? super T>> Optional<T> safeMin(Iterable<T> iterable) {...}
//	public static def <T> Optional<T> safeMin(Iterable<T> iterable, Comparator<? super T> comparator) {...}
	
//	public static def <T> safeExists(Iterable<T> iterable, Predicate<T> test) {
//		if(iterable === null) {
//			false
//		} else {
//			iterable.filterNull.exists2(test)
//		}
//	}
	
	public static def <T,U> safeMap(Iterable<T> iterable, extension (T)=>U mapper) {
		iterable?.map[it?.apply]?.filterNull.orEmpty // maybe replace with filterOrMap when done
	}
	
	public static def <T,U> safeFilter(Iterable<T> iterable, extension (T)=>boolean test) {
		iterable?.filter[it?.apply ?: false].orEmpty
	}
	
	public static def <T,U> Iterable<U> safeFilter(Iterable<T> iterable, Class<U> clazz) {
		Objects.requireNonNull(clazz)
		iterable?.filter(clazz).orEmpty
	}
	
	// TODO static def <T,Y> Optional<Y> safeFindFirst(Iterable<T> iterable, Class<? extends Y> clazz)
	public static def <T> Optional<T> safeFindFirst(Iterable<T> iterable, extension (T)=>boolean test) {
		iterable?.findFirst[it?.apply ?: false].maybe
	}
	
	public static def <T> Optional<T> safeHead(Iterable<T> iterable) {
		if(iterable === null) {
			none
		} else {
			iterable.head.maybe
		}
	}
	
	private static def <T> Iterable<T> orEmpty(Iterable<T> iterable) {
		iterable ?: Collections.emptyList
	}
}