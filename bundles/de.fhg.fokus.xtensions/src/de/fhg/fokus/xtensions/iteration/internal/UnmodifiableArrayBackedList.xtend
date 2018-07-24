/*******************************************************************************
 * Copyright (c) 2017 Max Bureck (Fraunhofer FOKUS) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     Max Bureck (Fraunhofer FOKUS) - initial API and implementation
 *******************************************************************************/
package de.fhg.fokus.xtensions.iteration.internal

import java.util.AbstractList

/**
 * Read-only List wrapper around an array
 */
package class UnmodifiableArrayBackedList<T> extends AbstractList<T> {

	val T[] array

	new(T[] ts) {
		this.array = ts
	}

	override get(int index) {
		array.get(index)
	}

	override size() {
		array.length
	}

}
