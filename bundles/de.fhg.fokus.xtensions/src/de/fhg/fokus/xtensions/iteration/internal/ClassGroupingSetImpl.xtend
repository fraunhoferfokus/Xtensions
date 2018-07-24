/*******************************************************************************
 * Copyright (c) 2017-2018 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.iteration.internal

import de.fhg.fokus.xtensions.iteration.ClassGroupingSet
import com.google.common.collect.ImmutableSetMultimap
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
