package de.fhg.fokus.xtensions.iteration.internal

import com.google.common.collect.ImmutableListMultimap
import java.util.List
import de.fhg.fokus.xtensions.iteration.ClassGroupingList
import java.util.Map

/**
 * Implementation of {@link ClassGroupingList}, based on {@link ImmutableListMultimap}.
 */
final class ClassGroupingListImpl extends AbstractClassGrouping implements ClassGroupingList {
	
	val ImmutableListMultimap<Class<?>, Object> backingMap
	
	new(ImmutableListMultimap<Class<?>,Object> map, Class<?>[] keys) {
		super(keys)
		this.backingMap = map
	}
	
	override <T> List<T> get(Class<T> clazz) {
		backingMap.get(clazz) as List<T>
	}
	
	override Map<Class<?>,List<?>> asMap() {
		backingMap.asMap as Map as Map<Class<?>,List<?>> // we know this cast chain is safe
	}
	
}