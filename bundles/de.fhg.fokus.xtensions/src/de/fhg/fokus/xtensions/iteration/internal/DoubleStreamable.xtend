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

import java.util.stream.DoubleStream

/**
 * This API is internal and should not be used directly by users of the Xtensions library.<br>
 * This interface provides the {@link DoubleStreamable#streamDoubles() streamDoubles} method for providing a stream of {@code double} values.
 */
interface DoubleStreamable {

	/**
	 * Provides a stream of {@code double} values. This method must not return {@code null}.
	 * @return stream of primitive {@code double} values.
	 */
	def DoubleStream streamDoubles()

}
