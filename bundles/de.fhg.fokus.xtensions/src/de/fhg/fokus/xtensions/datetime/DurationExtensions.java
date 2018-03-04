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
package de.fhg.fokus.xtensions.datetime;

import java.time.Duration;
import java.time.temporal.ChronoUnit;

import org.eclipse.xtext.xbase.lib.Inline;

/**
 * Operators and shortcut factory notations for {@link Duration} class for use in Xtend.
 * To use this functions, it is recommended to import this class with an extension import:
 * <pre><code>
 * import static extension de.fhg.fokus.xtenders.datetime.DurationExtensions.*
 * </code></pre>
 * All functions and operators are inlined to use functions of Duration directly.
 * This class provides arithmetic and compare operators, as well as factory methods
 * that can be used in more natural postfix notation, e.g. {@code 2.seconds}.
 *  
 * @author Max Bureck
 */
public final class DurationExtensions {
	
	/**
	 * Alias for {@link Duration#ofNanos(long)}.
	 * @param ns nanoseconds
	 * @return result of {@link Duration#ofNanos(long)} call with {@code ns}
	 */
	@Inline(value = "Duration.ofNanos($1)", imported = Duration.class)
	public static Duration nanoseconds(long ns) {
		return Duration.ofNanos(ns);
	}

	/**
	 * Alias for {@link Duration#ofMillis(long)}.
	 * @param ms milliseconds
	 * @return result of {@link Duration#ofMillis(long)} call with {@code ms}
	 */
	@Inline(value = "Duration.ofMillis($1)", imported = Duration.class)
	public static Duration milliseconds(long ms) {
		return Duration.ofMillis(ms);
	}
	
	/**
	 * Alias for {@code Duration.of(ms, ChronoUnit.MICROS)}.
	 * @param ms milliseconds
	 * @return result of {@code Duration.of(ms, ChronoUnit.MICROS)}
	 */
	@Inline(value = "Duration.of($1, ChronoUnit.MICROS)", imported = {Duration.class, ChronoUnit.class})
	public static Duration microseconds(long ms) {
		return Duration.of(ms, ChronoUnit.MICROS);
	}

	/**
	 * Alias for {@link Duration#ofSeconds(long)}.
	 * @param s seconds
	 * @return result of {@link Duration#ofSeconds(long)} call with {@code s}
	 */
	@Inline(value = "Duration.ofSeconds($1)", imported = Duration.class)
	public static Duration seconds(long s) {
		return Duration.ofSeconds(s);
	}

	/**
	 * Alias for {@link Duration#ofMinutes(long)}.
	 * @param min minutes
	 * @return result of {@link Duration#ofMinutes(long)} call with {@code min}
	 */
	@Inline(value = "Duration.ofMinutes($1)", imported = Duration.class)
	public static Duration minutes(long min) {
		return Duration.ofMinutes(min);
	}

	/**
	 * Alias for {@link Duration#ofHours(long)}.
	 * @param h hours
	 * @return result of {@link Duration#ofHours(long)} call with {@code h}
	 */
	@Inline(value = "Duration.ofHours($1)", imported = Duration.class)
	public static Duration hours(long h) {
		return Duration.ofHours(h);
	}

	/**
	 * Alias for {@link Duration#ofDays(long)}.
	 * @param d days
	 * @return result of {@link Duration#ofDays(long)} call with {@code d}
	 */
	@Inline(value = "Duration.ofDays($1)", imported = Duration.class)
	public static Duration days(long d) {
		return Duration.ofDays(d);
	}
	
	/**
	 * Alias for {@code Duration.of(w, ChronoUnit.WEEKS)}.
	 * @param w weeks
	 * @return result of {@code Duration.of(w, ChronoUnit.WEEKS)}
	 */
	@Inline(value = "Duration.of($1, ChronoUnit.WEEKS)", imported = {Duration.class, ChronoUnit.class})
	public static Duration weeks(long w) {
		return Duration.of(w,ChronoUnit.WEEKS);
	}

	/**
	 * Operator shortcut for {@link Duration#plus(Duration) a.plus(b)}.
	 * @param a left hand side of operator
	 * @param b right hand side of operator
	 * @return result of {@code a.plus(b)}
	 */
	@Inline(value = "$1.plus($2)", imported = Duration.class)
	public static Duration operator_plus(Duration a, Duration b) {
		return a.plus(b);
	}

	/**
	 * Operator shortcut for {@link Duration#minus(Duration) a.minus(b)}
	 * @param a left hand side of operator
	 * @param b right hand side of operator
	 * @return result of {@code a.minus(b)}
	 */
	@Inline(value = "$1.minus($2)", imported = Duration.class)
	public static Duration operator_minus(Duration a, Duration b) {
		return a.minus(b);
	}

	/**
	 * Operator shortcut for {@link Duration#dividedBy(long) a.dividedBy(b)}
	 * @param a left hand side of operator
	 * @param b right hand side of operator
	 * @return result of {@code a.dividedBy(b)}
	 */
	@Inline(value = "$1.dividedBy($2)", imported = Duration.class)
	public static Duration operator_divide(Duration a, long b) {
		return a.dividedBy(b);
	}

	/**
	 * Operator shortcut for {@link Duration#multipliedBy(long) a.multipliedBy(b)}
	 * @param a left hand side of operator
	 * @param b right hand side of operator
	 * @return result of {@code a.multipliedBy(b)}
	 */
	@Inline(value = "$1.multipliedBy($2)", imported = Duration.class)
	public static Duration operator_multiply(Duration a, long b) {
		return a.multipliedBy(b);
	}

	/**
	 * Operator shortcut for {@link Duration#negated() a.negated()}
	 * @param a value to negate
	 * @return result of {@code a.negated()}
	 */
	@Inline(value = "$1.negated()", imported = Duration.class)
	public static Duration operator_minus(Duration a) {
		return a.negated();
	}

	/**
	 * Operator shortcut for {@link Duration#compareTo(Duration) a.compareTo(b)}.
	 * 
	 * @param a left hand side of operator
	 * @param b right hand side of operator
	 * @return result of {@code a.compareTo(b)}
	 */
	@Inline(value = "$1.compareTo($2)", imported = Duration.class)
	public static int operator_spaceship(Duration a, Duration b) {
		return a.compareTo(b);
	}

	/**
	 * Operator shortcut for {@link Duration#compareTo(Duration) a.compareTo(b) < 0}.
	 * 
	 * @param a left hand side of operator
	 * @param b right hand side of operator
	 * @return result of {@code a.compareTo(b) < 0}
	 */
	@Inline(value = "$1.compareTo($2) < 0")
	public static boolean operator_lessThan(Duration a, Duration b) {
		return a.compareTo(b) < 0;
	}

	/**
	 * Operator shortcut for {@link Duration#compareTo(Duration) a.compareTo(b) > 0}.
	 * 
	 * @param a left hand side of operator
	 * @param b right hand side of operator
	 * @return result of {@code a.compareTo(b) > 0}
	 */
	@Inline(value = "$1.compareTo($2) > 0")
	public static boolean operator_greaterThan(Duration a, Duration b) {
		return a.compareTo(b) > 0;
	}
	
	/**
	 * Operator shortcut for {@link Duration#compareTo(Duration) a.compareTo(b) <= 0}.
	 * 
	 * @param a left hand side of operator
	 * @param b right hand side of operator
	 * @return result of {@code a.compareTo(b) <= 0}
	 */
	@Inline(value = "$1.compareTo($2) <= 0")
	public static boolean operator_lessEqualsThan(Duration a, Duration b) {
		return a.compareTo(b) <= 0;
	}
	
	/**
	 * Operator shortcut for {@link Duration#compareTo(Duration) a.compareTo(b) >= 0}.
	 * 
	 * @param a left hand side of operator
	 * @param b right hand side of operator
	 * @return result of {@code a.compareTo(b) >= 0}
	 */
	@Inline(value = "$1.compareTo($2) >= 0")
	public static boolean operator_greaterEqualsThan(Duration a, Duration b) {
		return a.compareTo(b) >= 0;
	}
}