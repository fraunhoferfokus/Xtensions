package de.fhg.fokus.xtensions.incubation.util

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
