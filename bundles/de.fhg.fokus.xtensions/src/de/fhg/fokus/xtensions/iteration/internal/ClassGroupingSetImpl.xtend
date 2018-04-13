package de.fhg.fokus.xtensions.iteration.internal

import de.fhg.fokus.xtensions.iteration.ClassGroupingSet
import com.google.common.collect.ImmutableSetMultimap
import java.util.List
import java.util.Map
import java.util.Set

/**
 * Implementation of {@link ClassGroupingSet} based on {@link ImmutableSetMultimap}.
 */
final class ClassGroupingSetImpl extends AbstractClassGrouping implements ClassGroupingSet {

	ImmutableSetMultimap<Class<?>, Object> backingMap

	new(ImmutableSetMultimap<Class<?>, Object> map, Class<?>[] keys) {
		super(keys)
		this.backingMap = map
	}

	override <T> Set<T> get(Class<T> clazz) {
		backingMap.get(clazz) as Set<T>
	}

	override Map<Class<?>, Set<?>> asMap() {
		backingMap.asMap as Map as Map<Class<?>, Set<?>> // we know this is safe
	}

}
