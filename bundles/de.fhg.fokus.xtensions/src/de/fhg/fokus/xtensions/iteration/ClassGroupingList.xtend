package de.fhg.fokus.xtensions.iteration

import java.util.List
import java.util.Map

/**
 * Special {@link ClassGrouping} where the objects are grouped in {@link List}s.
 * @see de.fhg.fokus.xtensions.iteration.IterableExtensions#groupIntoListBy(Iterable, Class, Class, Class...)
 * @see de.fhg.fokus.xtensions.iteration.IteratorExtensions#groupIntoListBy(java.util.Iterator, Class, Class, Class...)
 */
interface ClassGroupingList extends ClassGrouping {
	
	/**
	 * {@inheritDoc}
	 */
	override <T> List<T> get(Class<T> clazz)
	
 	/**
	 * Returns map representation of this grouping.
	 * Note that unlinke the {@link #get(Class)} method, the map
	 * will return {@code null} if the key class is not one of the 
	 * classes returned by {@link #getGroupingClasses()}.
	 * @return Map representation of the {@code ClassGroupingList}
	 */
	def Map<Class<?>,List<?>> asMap();
}