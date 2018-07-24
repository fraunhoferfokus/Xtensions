package de.fhg.fokus.xtensions.incubation.optional

import java.math.BigInteger
import java.util.Optional
import java.util.function.Predicate

 abstract class Either<L, R> {
	private new (){}
	
	abstract def <X, Y> Either<X, Y> map((L)=>X leftMapper, (R)=>Y rightMapper)

	abstract def <Y> Either<L, Y> mapRight((R)=>Y mapper)

	abstract def <Y> Either<Y, R> mapLeft((L)=>Y mapper)

	abstract def <Y> Either<L, Y> flatMapRight((R)=>Either<? extends L, ? extends Y> mapper)

	abstract def <Y> Either<Y, R> flatMapLeft((L)=>Either<? extends Y, ? extends R> mapper)

	abstract def Either<L, R> filterLeft(Predicate<L> test, (L)=>R rightProvider)

	abstract def Either<L, R> filterRight(Predicate<R> test, (R)=>L leftProvider)

	abstract def Optional<L> getLeft()

	abstract def Optional<L> getRight()

	abstract def Either<L, R> ifLeft((L)=>void leftConsumer)

	abstract def Either<L, R> ifRight((R)=>void rightConsumer)

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
	
	 static interface MatchLeft<L,X> {
		def X caseLeft((L)=>X caseBranch)
	}
	
	 static interface MatchRight<R,X> {
		def X caseRight((R)=>X caseBranch)
	}
	
	// TODO makes sense?
//	public abstract def Try<L> tryLeft()
//	public abstract def Try<L> tryLeft((R)=>Exception exceptionProducer)
//	public abstract def Try<L> tryRight()
//	public abstract def Try<L> tryRight((L)=>Exception exceptionProducer)
	
	
//	public static class Left<L,R> extends Either<L,R> {
//		private L left
//		new(L left) {
//			this.left = left
//		}
//		// TODO implement methods 
//		def L get() {left}
//	}
//
//	public static class Right<L,R> extends Either<L,R> {
//		private R right
//		new(R right) {
//			this.right = right
//		}
//		// TODO implement methods 
//		def R get() {right}
//		
//	}
	static def <L, R> Either<L, R> left(L l) {
//		new Left(l.requireNonNull)
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	static def <L, R> Either<L, R> right(R r) {
//		new Right(r.requireNonNull)
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	def static void main(String[] args) {
		val Either<BigInteger,Double> foo = Either::left(10BI)
		val Number bar = foo.available
		println(bar)
	}
	
	static def <T, L extends T, R extends T> T getAvailable(Either<L, R> either) {
//		// unfortunately the Xtend code gen is not good enough for a more concise expression
//		var T result
//		switch(either) {
//			Left<L,R>: result = either.left
//			Right<L,R>: result = either.right
//			default: throw new NullPointerException
//		}
//		result
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	// safe since L and R values are only consumed
	static def <L, R> Either<L, R> upcast(Either<? extends L, ? extends R> either) {
		either as Either<L, R>
	}
}
