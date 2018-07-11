package de.fhg.fokus.xtensions.iteration

import java.util.Map
import java.util.Set

/**
 * Special {@link ClassGrouping} where the objects are grouped in {@link Set}s.
 * @see de.fhg.fokus.xtensions.iteration.IterableExtensions#groupIntoSetBy(Iterable, Class, Class, Class...)
 * @see de.fhg.fokus.xtensions.iteration.IteratorExtensions#groupIntoSetBy(java.util.Iterator, Class, Class, Class...)
 */
interface ClassGroupingSet extends ClassGrouping {
	
	/**
	 * {@inheritDoc}
	 */
	override <T> Set<T> get(Class<T> clazz)
	
 	/**
	 * Returns map representation of this grouping.
	 * Note that unlinke the {@link #get(Class)} method, the map
	 * will return {@code null} if the key class is not one of the 
	 * classes returned by {@link #getGroupingClasses()}.
	 */
	def Map<Class<?>,Set<?>> asMap();
}