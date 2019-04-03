package de.fhg.fokus.xtensions.incubation

import java.util.function.IntSupplier
import java.util.function.LongSupplier
import java.util.function.DoubleSupplier
import static de.fhg.fokus.xtensions.incubation.Primitives.BoolUnaryOperator.*
import java.util.Objects
import java.util.function.BooleanSupplier
import java.util.function.ToIntFunction
import java.util.OptionalInt
import java.util.function.ToLongFunction
import java.util.OptionalLong
import java.util.OptionalDouble
import java.util.function.ToDoubleFunction

/**
 * This class mostly provides static functions to be used as extension functions at the end 
 * of null-safe navigation chains. When the last return from a null-safe navigation chain is 
 * a primitive boolean  value, the Xtend compiler will issue a warning, since a {@code null} value at the 
 * second to last step will cause the chain to implicitly return of a primitive value specific default value. 
 * E.g. in the chain {@code foo?.bar?.baz?.someBool} will implicitly return {@code false}
 * if at {@code baz} the chain-expression is evaluated to {@code null}. This can be 
 * considered as a code smell.<br><br>
 */
final class Primitives {

	/**
	 * This function is intended to be used as an extension method on a {@code context} object to box a {@code boolean} property of 
	 * the {@code context} object into a boxed {@code Boolean} object. This can be handy if you want to box the last element
	 * of a null-safe navigation chain and use the {@code Boolean.TRUE == foo?.bar?.baz.box[boolProperty]} or
	 * {@code foo?.bar?.baz.box[boolProperty].isTrue} comparison pattern. 
	 * This circumvents having a primitive value with an implicit default value
	 * at the end of the call chain. An advantage of this type of comparison is that the {@code box} method can
	 * also be called with a null-safe navigation to have a uniform navigation pattern for the call 
	 * chain.
	 */
	static def <T> Boolean box(T context, (T)=>boolean mapper) {
		Objects.requireNonNull(mapper, "mapper function is not allowed to be null")
		if (context === null) {
			null
		} else {
			mapper.apply(context)
		}
	}
	
	/**
	 * This function is intended to be used as an extension method on a {@code context} object to box a primitive {@code number} property of 
	 * the {@code context} object into a boxed {@code Boolean} object. This can be handy if you want to box the last primitive value
	 * of a null-safe navigation chain. This can be followed with a call to {@link Primitives#isTrue(Object, Function1) isTrue(T, (T)=>boolean)}
	 * to check if the numeric value adheres to a certain condition. Alternatively a call to {@code boxNum} may be followed by a call to
	 * {@code onNull} to explicitly define a default value on {@code null}.
	 * This circumvents having a primitive value with an implicit default value
	 * at the end of the call chain. An advantage of this type of comparison is that the {@code box} method can
	 * also be called with a null-safe navigation to have a uniform navigation pattern for the call 
	 * chain.
	 */
	static def <T, N extends Number> N boxNum(T context, (T)=>N mapper) {
		Objects.requireNonNull(mapper, "mapper function is not allowed to be null")
		if (context === null) {
			null
		} else {
			mapper.apply(context)
		}
	}

	/**
	 * Tests if a {@code mapper} function applied to a given {@code context} object returns {@code true}. 
	 * If the context is {@code null} or the value returned from the {@code mapper} function is {@code null}
	 * this method will return {@code false}.<br>
	 * This method is intended to be used as an extension function at the end of null-safe navigation chains,
	 * e.g. like this: {@code foo?.bar?.baz.isTrue[someBoolProperty]}. The advantage of this method for 
	 * long call chains is that the condition is close to the 
	 * <br><br>
	 * Here is the logic table of the output of this method based on the inputs.
	 * Note that {@code -} means that the value does not matter.
	 * <table border="1">
	 *   <tr>
	 *     <th >context</th>
	 *     <th >return of {@code mapper.apply(context)}</th>
	 *     <th >result</th>
	 *   </tr>
	 *   <tr>
	 *     <td >null</td>
	 *     <td >-</td>
	 *     <td ><br>false</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >null<br></td>
	 *     <td >false</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >true</td>
	 *     <td >true</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >false</td>
	 *     <td >false</td>
	 *   </tr>
	 * </table>
	 * 
	 * <b>To be clear:</b> This method returns {@code false} if {@code context}
	 *  or the result of a call to {@code mapper} is {@code null}.
	 * @param context the element on which the {@code mapper} function is applied.
	 * @param mapper function that will be applied on the {@code context} value.
	 * @return {@code true} if {@code context} is not {@code null} and the {@code mapper} 
	 * 	function returns {@code true} when applied to the {@code context} value.
	 * @throws NullPointerException if {@code mapper} is {@code null}
	 */
	static def <T> boolean isTrue(T context, (T)=>boolean mapper) {
		val onNull = false
		context.checkNullOr(mapper, onNull, IDENTITY)
	}

	/**
	 * Here is the logic table of the output of this method based on the inputs.
	 * Note that {@code -} means that the value does not matter.
	 * <table border="1">
	 *   <tr>
	 *     <th >context</th>
	 *     <th >return of {@code mapper.apply(context)}</th>
	 *     <th >result</th>
	 *   </tr>
	 *   <tr>
	 *     <td >null</td>
	 *     <td >-</td>
	 *     <td ><br>false</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >null<br></td>
	 *     <td >false</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >true</td>
	 *     <td >false</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >false</td>
	 *     <td >true</td>
	 *   </tr>
	 * </table>
	 * @param context the element on which the {@code mapper} function is applied.
	 * @param mapper function that will be applied on the {@code context} value.
	 * @return {@code true} if {@code context} is not {@code null} and the {@code mapper} 
	 * 	function returns {@code false} when applied to the {@code context} value.
	 * @throws NullPointerException if {@code mapper} is {@code null}
	 */
	static def <T> boolean isFalse(T context, (T)=>boolean mapper) {
		val onNull = false
		context.checkNullOr(mapper, onNull, NOT)
	}

	/**
	 * Here is the logic table of the output of this method based on the inputs.
	 * Note that {@code -} means that the value does not matter.
	 * <table border="1">
	 *   <tr>
	 *     <th >context</th>
	 *     <th >return of {@code mapper.apply(context)}</th>
	 *     <th >result</th>
	 *   </tr>
	 *   <tr>
	 *     <td >null</td>
	 *     <td >-</td>
	 *     <td ><br>true</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >null<br></td>
	 *     <td >true</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >true</td>
	 *     <td >true</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >false</td>
	 *     <td >false</td>
	 *   </tr>
	 * </table>
	 * @param context the element on which the {@code mapper} function is applied.
	 * @param mapper function that will be applied on the {@code context} value.
	 * @return {@code true} if {@code context} is {@code null}, or the {@code mapper} 
	 * 	function returns {@code null}, or the {@code mapper} function returns {@code true} 
	 *  when applied to the {@code context} value.
	 * @throws NullPointerException if {@code mapper} is {@code null}
	 */
	static def <T> boolean isNullOrTrue(T context, (T)=>boolean mapper) {
		val onNull = true
		context.checkNullOr(mapper, onNull, IDENTITY)
	}

	/**
	 * Here is the logic table of the output of this method based on the inputs.
	 * Note that {@code -} means that the value does not matter.
	 * <table border="1">
	 *   <tr>
	 *     <th >context</th>
	 *     <th >return of {@code mapper.apply(context)}</th>
	 *     <th >result</th>
	 *   </tr>
	 *   <tr>
	 *     <td >null</td>
	 *     <td >-</td>
	 *     <td ><br>true</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >null<br></td>
	 *     <td >true</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >true</td>
	 *     <td >false</td>
	 *   </tr>
	 *   <tr>
	 *     <td >non null</td>
	 *     <td >false</td>
	 *     <td >true</td>
	 *   </tr>
	 * </table>
	 * @param context the element on which the {@code mapper} function is applied.
	 * @param mapper function that will be applied on the {@code context} value.
	 * @return {@code true} if {@code context} is {@code null}, or the {@code mapper} 
	 * 	function returns {@code null}, or the {@code mapper} function returns {@code false} 
	 *  when applied to the {@code context} value.
	 * @throws NullPointerException if {@code mapper} is {@code null}
	 */
	static def <T> boolean isNullOrFalse(T context, (T)=>boolean mapper) {
		val onNull = true
		context.checkNullOr(mapper, onNull, NOT)
	}

	/**
	 * Tests if the given {@code Boolean b} is not {@code null} and holds the value {@code true}.
	 * @param b value to be tested
	 * @return {@code true} if given value {@code b} is not {@code null} and wraps the primitive value {@code true}, otherwise returns {@code false}.
	 */
	static def boolean isTrue(Boolean b) {
		if (b !== null) {
			b.booleanValue
		} else {
			false
		}
	}

	/**
	 * Tests if the given {@code Boolean b} is not {@code null} and holds the value {@code false}.
	 * @param b value to be tested
	 * @return {@code true} if given value {@code b} is not {@code null} and wraps the primitive value {@code false}, otherwise returns {@code false}.
	 */
	static def boolean isFalse(Boolean b) {
		if (b !== null) {
			!b.booleanValue
		} else {
			false
		}
	}

	/**
	 * Tests if the given {@code Boolean b} is either {@code null} or holds the value {@code true}.
	 * @param b value to be tested
	 * @return {@code true} if given value {@code b} either {@code null} or wraps the primitive value {@code true}, otherwise returns {@code false}.
	 */
	static def boolean isNullOrTrue(Boolean b) {
		if (b !== null) {
			b.booleanValue
		} else {
			true
		}
	}

	/**
	 * Tests if the given {@code Boolean b} is either {@code null} or holds the value {@code false}.
	 * @param b value to be tested
	 * @return {@code true} if given value {@code b} either {@code null} or wraps the primitive value {@code false}, otherwise returns {@code false}.
	 */
	static def boolean isNullOrFalse(Boolean b) {
		if (b !== null) {
			!b.booleanValue
		} else {
			true
		}
	}

	private static def <T> checkNullOr(T context, (T)=>boolean mapper, boolean onNull, BoolUnaryOperator endOp) {
		Objects.requireNonNull(mapper, "mapper function is not allowed to be null")
		if (context === null) {
			onNull
		} else {
			val mapped = mapper.apply(context)
			if (mapped === null) {
				onNull
			} else {
				endOp.apply(mapped)
			}
		}
	}

	private static interface BoolUnaryOperator {
		def boolean apply(boolean input)

		val BoolUnaryOperator NOT = [!it]
		val BoolUnaryOperator IDENTITY = [it]
	}
	
	/**
	 * <b>Important</b>: Do <em>not</em> call this method via null-safe navigation! 
	 * This defeats the purpose of this method of providing an instance that safely can
	 * be queried for a value.
	 */
	static def <T> OptionalInt optionalInt(T t, ToIntFunction<T> mapper) {
		if(t === null) {
			OptionalInt.empty
		} else {
			OptionalInt.of(mapper.applyAsInt(t))
		}
	}
	
	/**
	 * <b>Important</b>: Do <em>not</em> call this method via null-safe navigation! 
	 * This defeats the purpose of this method of providing an instance that safely can
	 * be queried for a value.
	 */
	static def <T> OptionalLong optionalLong(T t, ToLongFunction<T> mapper) {
		if(t === null) {
			OptionalLong.empty
		} else {
			OptionalLong.of(mapper.applyAsLong(t))
		}
	}
	
	/**
	 * <b>Important</b>: Do <em>not</em> call this method via null-safe navigation! 
	 * This defeats the purpose of this method of providing an instance that safely can
	 * be queried for a value.
	 */
	static def <T> OptionalDouble optionalDouble(T t, ToDoubleFunction<T> mapper) {
		if(t === null) {
			OptionalDouble.empty
		} else {
			OptionalDouble.of(mapper.applyAsDouble(t))
		}
	}

	/**
	 * Unboxes and returns the {@code Boolean b}, or if {@code b} is {@code null},
	 * returns the value provided by {@code fallback}. This is similar to using the 
	 * {@code ?:} operator, but allows lazy computation for the fallback value.
	 * @param b
	 * @param fallback
	 * @return
	 */
	static def boolean onNull(Boolean b, BooleanSupplier fallback) {
		if (b !== null) {
			b.booleanValue
		} else {
			fallback.asBoolean
		}
	}

	/**
	 * Unboxes and returns the {@code Integer i}, or if {@code i} is {@code null},
	 * returns the value provided by {@code fallback}. This is similar to using the 
	 * {@code ?:} operator, but allows lazy computation for the fallback value.
	 * @param i
	 * @param fallback
	 * @return
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
	 * returns the value provided by {@code fallback}. This is similar to using the 
	 * {@code ?:} operator, but allows lazy computation for the fallback value.
	 * @param l
	 * @param fallback
	 * @return
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
	 * returns the value provided by {@code fallback}. This is similar to using the 
	 * {@code ?:} operator, but allows lazy computation for the fallback value.
	 * @param d
	 * @param fallback
	 * @return
	 */
	static def double onNull(Double d, DoubleSupplier fallback) {
		if (d !== null) {
			d.doubleValue
		} else {
			fallback.asDouble
		}
	}
}
