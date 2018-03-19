package de.fhg.fokus.xtensions.iteration

import java.util.Iterator
import java.util.function.ToIntFunction
import java.util.PrimitiveIterator.OfInt
import java.util.PrimitiveIterator.OfLong
import java.util.function.ToLongFunction
import java.util.PrimitiveIterator.OfDouble
import java.util.function.ToDoubleFunction
import static extension java.util.Objects.*

/**
 * Extension methods for the {@link Iterator} class. 
 */
class IteratorExtensions {

	private new() {
		throw new IllegalStateException("IteratorExtensions not intended to be instantiated")
	}

	/**
	 * This function maps an {@link Iterator} to a {@link OfInt PrimitiveIterator.OfInt}, using the 
	 * {@code mapper} function for each element of the original {@code iterator}. 
	 * The returned {@code PrimitiveIterator.OfInt} is lazy, only calling
	 * the {@code mapper} function when a next element is pulled from it.
	 * @param iterator the {@code Iterator} of which each element should be mapped to {@code int} values.
	 * @param mapper the mapping function, mapping each element of {@code iterator} to an {@code int} value.
	 * @param <T> type of elements in {@code iterator}, that are mapped to {@code int}s via {@code mapper}.
	 * @return a {@code PrimitiveIterator.OfInt} mapped from the elements of the input {@code iterator}.
	 * @throws NullPointerException if {@code iterator} or {@code mapper} is {@code null}
	 */
	public static def <T> OfInt mapInt(Iterator<T> iterator, ToIntFunction<T> mapper) {
		iterator.requireNonNull
		mapper.requireNonNull
		new OfInt {

			override nextInt() {
				val current = iterator.next
				mapper.applyAsInt(current)
			}

			override hasNext() {
				iterator.hasNext
			}

		}
	}

	/**
	 * This function maps an {@link Iterator} to a {@link OfLong PrimitiveIterator.OfLong}, using the 
	 * {@code mapper} function for each element of the original {@code iterator}. 
	 * The returned {@code PrimitiveIterator.OfLong} is lazy, only calling
	 * the {@code mapper} function when a next element is pulled from it.
	 * @param iterator the {@code Iterator} of which each element should be mapped to {@code long} values.
	 * @param mapper the mapping function, mapping each element of {@code iterator} to an {@code long} value.
	 * @param <T> type of elements in {@code iterator}, that are mapped to {@code long}s via {@code mapper}.
	 * @return a {@code PrimitiveIterator.OfLong} mapped from the elements of the input {@code iterator}.
	 * @throws NullPointerException if {@code iterator} or {@code mapper} is {@code null}
	 */
	public static def <T> OfLong mapLong(Iterator<T> iterator, ToLongFunction<T> mapper) {
		iterator.requireNonNull
		mapper.requireNonNull
		new OfLong {

			override nextLong() {
				val current = iterator.next
				mapper.applyAsLong(current)
			}

			override hasNext() {
				iterator.hasNext
			}

		}
	}

	/**
	 * This function maps an {@link Iterator} to a {@link OfLong PrimitiveIterator.OfDouble}, using the 
	 * {@code mapper} function for each element of the original {@code iterator}. 
	 * The returned {@code PrimitiveIterator.OfDouble} is lazy, only calling
	 * the {@code mapper} function when a next element is pulled from it.
	 * @param iterator the {@code Iterator} of which each element should be mapped to {@code double} values.
	 * @param mapper the mapping function, mapping each element of {@code iterator} to an {@code double} value.
	 * @param <T> type of elements in {@code iterator}, that are mapped to {@code double}s via {@code mapper}.
	 * @return a {@code PrimitiveIterator.OfDouble} mapped from the elements of the input {@code iterator}.
	 * @throws NullPointerException if {@code iterator} or {@code mapper} is {@code null}
	 */
	public static def <T> OfDouble mapDouble(Iterator<T> iterator, ToDoubleFunction<T> mapper) {
		iterator.requireNonNull
		mapper.requireNonNull
		new OfDouble {
			override nextDouble() {
				val current = iterator.next
				mapper.applyAsDouble(current)
			}

			override hasNext() {
				iterator.hasNext
			}

		}
	}

}
