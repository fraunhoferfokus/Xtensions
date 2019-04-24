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
package de.fhg.fokus.xtensions.util

/**
 * This functional interface provides a method to pass a {@code boolean}
 * value for consumption.
 */
@FunctionalInterface
interface BooleanConsumer {

	/**
	 * Function to consume a {@code boolean} value.
	 * @param b boolean value to consume
	 */
	def void accept(boolean b)
}
