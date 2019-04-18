package de.fhg.fokus.xtensions.incubation.optional

import java.util.Optional
import java.util.function.Predicate
import de.fhg.fokus.xtensions.incubation.optional.Either.LeftConsumer
import de.fhg.fokus.xtensions.incubation.optional.Either.RightConsumer

abstract class Either<L, R> {
	private new() {
	}

	abstract def <X, Y> Either<X, Y> map((L)=>X leftMapper, (R)=>Y rightMapper)

	abstract def <Y> Either<L, Y> mapRight((R)=>Y mapper)

	abstract def <Y> Either<Y, R> mapLeft((L)=>Y mapper)

	abstract def <Y> Either<L, Y> flatMapRight((R)=>Either<? extends L, ? extends Y> mapper)

	abstract def <Y> Either<Y, R> flatMapLeft((L)=>Either<? extends Y, ? extends R> mapper)

	abstract def Either<L, R> filterLeft(Predicate<? extends L> test, (L)=>R rightProvider)

	abstract def Either<L, R> filterRight(Predicate<? extends R> test, (R)=>L leftProvider)

	abstract def Optional<L> getLeft()

	abstract def Optional<R> getRight()

	abstract def Either<L, R> ifLeft((L)=>void leftConsumer)

	abstract def Either<L, R> ifRight((R)=>void rightConsumer)

	abstract def Either<L, R> ifType(Class<L> type, LeftConsumer<? extends L> consumer)

	abstract def Either<L, R> ifType(Class<R> type, RightConsumer<? extends R> consumer)

	abstract def <X> MatchRight<R, X> caseLeft((L)=>X caseBranch)

	abstract def <X> MatchLeft<L, X> caseRight((R)=>X caseBranch)

	abstract def boolean isLeft()

	abstract def boolean isRight()

	abstract def L leftOr(L alternative)

	abstract def R rightOr(R alternative)

	abstract def L leftOrCompute((R)=>L alternative)

	abstract def R rightOrCompute((L)=>R alternative)

	abstract def <X extends Exception> R rightOrThrow((L)=>X exceptionProvider) throws X

	abstract def <X extends Exception> R leftOrThrow((R)=>X exceptionProvider) throws X

	abstract def <X> X transform((L)=>X leftTransform, (R)=>X rightTransform)

	abstract def <X> X consume((L)=>void leftConsumer, (R)=>void rightConsumer)

	abstract def Either<R, L> swap()

	static interface MatchLeft<L, X> {
		def X caseLeft((L)=>X caseBranch)
	}

	static interface MatchRight<R, X> {
		def X caseRight((R)=>X caseBranch)
	}

	// TODO makes sense?
//	public abstract def Try<L> tryLeft()
//	public abstract def Try<L> tryLeft((R)=>Exception exceptionProducer)
//	public abstract def Try<L> tryRight()
//	public abstract def Try<L> tryRight((L)=>Exception exceptionProducer)
//  public abstract def L leftOrThrow() throws NoSuchElementException
//  public abstract def R rightOrThrow() throws NoSuchElementException
//	abstract def <T, T extends L> Either<L,R> ifSubType(Class<T> type, LeftConsumer<T> consumer)
//	abstract def <T, T extends R> Either<L,R> ifSubType(Class<T> type, RightConsumer<T> consumer)

	/**
	 * Representing the state of {@link Either} where the left element of type {@code L}
	 * is present.
	 */
	static final class Left<L, R> extends Either<L, R> {
		val L left

		private new(L left) {
			this.left = left
		}

		def L get() { left }

		override <X, Y> map((L)=>X leftMapper, (R)=>Y rightMapper) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <Y> mapRight((R)=>Y mapper) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <Y> mapLeft((L)=>Y mapper) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <Y> flatMapRight((R)=>Either<? extends L, ? extends Y> mapper) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <Y> flatMapLeft((L)=>Either<? extends Y, ? extends R> mapper) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override filterLeft(Predicate<? extends L> test, (L)=>R rightProvider) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override filterRight(Predicate<? extends R> test, (R)=>L leftProvider) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override getLeft() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override getRight() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override ifLeft((L)=>void leftConsumer) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override ifRight((R)=>void rightConsumer) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X> caseLeft((L)=>X caseBranch) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X> caseRight((R)=>X caseBranch) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override isLeft() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override isRight() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override leftOr(L alternative) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override rightOr(R alternative) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override leftOrCompute((R)=>L alternative) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override rightOrCompute((L)=>R alternative) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X extends Exception> rightOrThrow((L)=>X exceptionProvider) throws X {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X extends Exception> leftOrThrow((R)=>X exceptionProvider) throws X {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X> transform((L)=>X leftTransform, (R)=>X rightTransform) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X> consume((L)=>void leftConsumer, (R)=>void rightConsumer) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override swap() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override ifType(Class<L> type, LeftConsumer<? extends L> consumer) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override ifType(Class<R> type, RightConsumer<? extends R> consumer) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

	}

	/**
	 * Representing the state of {@link Either} where the right element of type {@code R}
	 * is present.
	 */
	static class Right<L, R> extends Either<L, R> {
		val R right

		private new(R right) {
			this.right = right
		}

		def R get() { right }

		override <X, Y> map((L)=>X leftMapper, (R)=>Y rightMapper) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <Y> mapRight((R)=>Y mapper) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <Y> mapLeft((L)=>Y mapper) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <Y> flatMapRight((R)=>Either<? extends L, ? extends Y> mapper) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <Y> flatMapLeft((L)=>Either<? extends Y, ? extends R> mapper) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override filterLeft(Predicate<? extends L> test, (L)=>R rightProvider) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override filterRight(Predicate<? extends R> test, (R)=>L leftProvider) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override getLeft() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override getRight() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override ifLeft((L)=>void leftConsumer) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override ifRight((R)=>void rightConsumer) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X> caseLeft((L)=>X caseBranch) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X> caseRight((R)=>X caseBranch) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override isLeft() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override isRight() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override leftOr(L alternative) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override rightOr(R alternative) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override leftOrCompute((R)=>L alternative) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override rightOrCompute((L)=>R alternative) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X extends Exception> rightOrThrow((L)=>X exceptionProvider) throws X {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X extends Exception> leftOrThrow((R)=>X exceptionProvider) throws X {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X> transform((L)=>X leftTransform, (R)=>X rightTransform) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override <X> consume((L)=>void leftConsumer, (R)=>void rightConsumer) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override swap() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override ifType(Class<L> type, LeftConsumer<? extends L> consumer) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override ifType(Class<R> type, RightConsumer<? extends R> consumer) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

	}

	@FunctionalInterface
	static interface LeftConsumer<L> {
		def void consume(L value)
	}

	@FunctionalInterface
	static interface RightConsumer<L> {
		def void consume(L value)
	}

	static def <L, R> Either<L, R> left(L l) {
//		new Left(l.requireNonNull)
		throw new UnsupportedOperationException("Not implemented yet")
	}

	static def <L, R> Either<L, R> right(R r) {
//		new Right(r.requireNonNull)
		throw new UnsupportedOperationException("Not implemented yet")
	}

	static def <T, L extends T, R extends T> T getAvailable(Either<L, R> either) {
		// unfortunately explicit cast to T needed in cases, due to limitation of Xtend compiler
		var T result = switch (either) {
			Left<L,R>: either.left as T
			Right<L,R>: either.right as T
			default: throw new NullPointerException
		}
		result
	}

	// safe since L and R values are only consumed
	static def <L, R> Either<L, R> upcast(Either<? extends L, ? extends R> either) {
		either as Either<L, R>
	}
}
