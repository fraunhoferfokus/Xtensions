package de.fhg.fokus.xtensions.incubation

import java.util.function.IntSupplier
import java.util.function.LongSupplier
import java.util.function.DoubleSupplier

class Primitives {
	
	/**
	 * Unboxes and returns the {@code Integer i}, or if {@code i} is {@code null},
	 * returns the value provided by {@code fallback}.
	 */
	static def int onNull(Integer i, IntSupplier fallback) {
		if (i !== null) {
			i.intValue
		} else {
			fallback.asInt
		}
	}

	/**
	 * Unboxes and returns the {@code Long l}, or if {@code l} is {@code null},
	 * returns the value provided by {@code fallback}.
	 */
	static def long onNull(Long l, LongSupplier fallback) {
		if (l !== null) {
			l.longValue
		} else {
			fallback.asLong
		}
	}	

	/**
	 * Unboxes and returns the {@code Double d}, or if {@code l} is {@code null},
	 * returns the value provided by {@code fallback}.
	 */
	static def double onNull(Double d, DoubleSupplier fallback) {
		if (d !== null) {
			d.doubleValue
		} else {
			fallback.asDouble
		}
	}
}