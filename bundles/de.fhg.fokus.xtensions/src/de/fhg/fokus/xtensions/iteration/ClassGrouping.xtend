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
package de.fhg.fokus.xtensions.iteration

import java.util.List
import java.util.Collection

/**
 * Grouping of objects by a list of classes. The group of classes by which 
 * elements are grouped is provided by 
 */
interface ClassGrouping {
	
	/**
	 * List of classes the grouping grouped object instances by.
	 * The returned list will be unmodifiable.
	 * @return classes elements are grouped by
	 */
	def List<Class<?>> getGroupingClasses()
	
	/**
	 * Returns a collection of elements grouped by the given class {@code clazz}.
	 * This method will always return non {@code null} value. Am empty collection is 
	 * returned if there was no instance of a grouping class found or if {@code class} 
	 * is no partitioning class (not contained in the list returned by {@link #getGroupingClasses()}).
	 * Note that this method is <em>not</em> aware of subclasses of {@code clazz}.
	 * This means that you have to provide the class object exactly one of the grouping classes,
	 * not one of the subclasses of the grouping class.
	 * @param clazz the class object used for grouping
	 * @return the collection of objects that were grouped by class {@code clazz}
	 * @param <T> Type defined by {@code clazz} the returned elements are grouped by
	 */
 	def <T> Collection<T> get(Class<T> clazz)
 	
}