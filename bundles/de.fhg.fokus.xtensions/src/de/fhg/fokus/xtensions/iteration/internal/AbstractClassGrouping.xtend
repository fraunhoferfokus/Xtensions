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

import de.fhg.fokus.xtensions.iteration.ClassGrouping
import java.util.List

/**
 * Abstract {@link ClassGrouping} only implementing key storage and method {@link #getGroupingClasses()}.
 */
package abstract class AbstractClassGrouping implements ClassGrouping {
	
	Class<?>[] keys
	transient var List<Class<?>> keysList

	new(Class<?>[] keys) {
		this.keys = keys
		this.keysList = null
	}

	override final List<Class<?>> getGroupingClasses() {
		val result = keysList
		if (result === null) {
			keysList = new UnmodifiableArrayBackedList(keys)
		} else {
			result
		}
	}
	
}