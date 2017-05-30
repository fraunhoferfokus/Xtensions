package de.fhg.fokus.xtensions.optional;

import java.util.function.BiConsumer;
import java.util.function.Consumer;

/**
 * Class with method {@link Else#elseDo(Runnable) elseDo(Runnable)}, which either
 * executes the given runnable or not, depending on the sub-class.
 * @see OptionalExtensions#whenPresent(java.util.Optional, Consumer)
 * @see OptionalIntExtensions#whenPresent(java.util.OptionalInt, java.util.function.IntConsumer)
 * @see OptionalLongExtensions#whenPresent(java.util.OptionalLong, java.util.function.LongConsumer)
 * @see OptionalDoubleExtensions#whenPresent(java.util.OptionalDouble, java.util.function.DoubleConsumer)
 */
public abstract class Else {
	/*package*/ static final Else PRESENT = new Else() {
		@Override
		public void elseDo(Runnable elseBlock) {
		}

		@Override
		public <T> void elseDo(T val, Consumer<T> elseBlock) {
		}

		@Override
		public <T, U> void elseDo(T t, U u, BiConsumer<T, U> elseBlock) {
		}
	};
	/*package*/ static final Else NOT_PRESENT = new Else() {
		@Override
		public void elseDo(Runnable elseBlock) {
			elseBlock.run();
		}

		@Override
		public <T> void elseDo(T val, Consumer<T> elseBlock) {
			elseBlock.accept(val);
		}

		@Override
		public <T, U> void elseDo(T t, U u, BiConsumer<T, U> elseBlock) {
			elseBlock.accept(t,u);
		}
	};
	private Else(){}
	
	/**
	 * This method either executes the given {@code elseBlock} or not,
	 * based on the sub-class of {@code Else}.
	 * @param elseBlock code to be executed or not.
	 */
	public abstract void elseDo(Runnable elseBlock);
	
	/**
	 * This method either executes the given {@code elseBlock} or not,
	 * based on the sub-class of {@code Else}. The given {@code val} will
	 * be forwarded to the elseBlock on execution. This allows the usage of non-capturing
	 * lambdas, allowing better execution performance.
	 * @param val value to be forwarded to {@code elseBlock}, if it is executed.
	 * @param elseBlock code to be executed or not.
	 */
	public abstract <T> void elseDo(T val, Consumer<T> elseBlock);
	
	/**
	 * This method either executes the given {@code elseBlock} or not,
	 * based on the sub-class of {@code Else}. The given {@code t} and {@code u} will
	 * be forwarded to the elseBlock on execution. This allows the usage of non-capturing
	 * lambdas, allowing better execution performance.
	 * @param t value to be forwarded to {@code elseBlock}, if it is executed.
	 * @param u value to be forwarded to {@code elseBlock}, if it is executed.
	 * @param elseBlock code to be executed or not.
	 */
	public abstract <T, U> void elseDo(T t, U u, BiConsumer<T,U> elseBlock);
}