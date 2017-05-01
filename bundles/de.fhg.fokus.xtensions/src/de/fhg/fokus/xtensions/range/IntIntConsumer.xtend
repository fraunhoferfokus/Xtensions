package de.fhg.fokus.xtensions.range

/**
 * This functional interface defines a method consuming two {@code int} values.
 */
@FunctionalInterface
interface IntIntConsumer {
	
	def void accept(int a, int b)
	
}
