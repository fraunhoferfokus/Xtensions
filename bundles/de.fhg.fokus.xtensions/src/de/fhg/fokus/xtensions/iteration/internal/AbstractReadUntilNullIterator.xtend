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

import java.util.Iterator
import java.util.NoSuchElementException

/**
 * This abstract class provides an abstract implementation of {@link Iterator}
 * which will call {@link #readNext()} as long until it returns a {@code null}
 * value. The @code null} value will determine that no next value is present.
 * Note that the constructor of the subclass <em>must</em> call 
 * {@link #readAndSetNext()}!
 */
abstract class AbstractReadUntilNullIterator<T> implements Iterator<T> {
	protected T next
	
	/**
	 * Provides the next value to be returned via {@link #next()}, or a {@code null}
	 * value, if no further element can be supplied.
	 * @return the next value to be supplied by the iterator, or {@code null} to return
	 *  no further values.
	 */
	protected abstract def T readNext();
	
	/**
	 * Will read the next value via {@link #readNext()}
	 * and set the result to {@link #next}. Be careful overwriting
	 * this method!
	 */
	protected def void readAndSetNext() {
		next = readNext
	}

	final override hasNext() {
		next !== null
	}

	final override next() {
		if (next === null) {
			throw new NoSuchElementException
		}
		var T result = next
		readAndSetNext()
		result
	}
}