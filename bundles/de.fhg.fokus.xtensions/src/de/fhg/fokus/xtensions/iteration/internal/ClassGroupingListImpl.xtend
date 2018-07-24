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