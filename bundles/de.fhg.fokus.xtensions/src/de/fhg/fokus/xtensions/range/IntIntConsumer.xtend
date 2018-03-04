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
package de.fhg.fokus.xtensions.range

/**
 * This functional interface defines a method consuming two {@code int} values.
 */
@FunctionalInterface
interface IntIntConsumer {
	
	/**
	 * Method consuming the given two {@code int} values {@code a} and {@code b}.
	 * @param a first value to be consumed
	 * @param b second value to be consumed
	 */
	def void accept(int a, int b)
	
}
