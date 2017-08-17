package de.fhg.fokus.xtensions.incubation.optional
import static extension java.util.Objects.*
import java.util.Optional
import java.math.BigInteger
import java.util.function.Predicate
import de.fhg.fokus.xtensions.incubation.exceptions.Try

public abstract class Either<L, R> {
	private new (){}
	
	public abstract def <Y> Either<L, Y> mapRight((R)=>Y mapper)
	public abstract def <Y> Either<Y, R> mapLeft((L)=>Y mapper)
	public abstract def <Y> Either<L, Y> flatMapRight((R)=>Either<? extends L, ? extends Y> mapper)
	public abstract def <Y> Either<Y, R> flatMapLeft((L)=>Either<? extends Y,? extends R> mapper)
	public abstract def Either<L, R> filterLeft(Predicate<L> test, (L)=>R rightProvider)
	public abstract def Either<L, R> filterRight(Predicate<R> test, (R)=>L leftProvider)
	public abstract def Optional<L> getLeft()
	public abstract def Optional<L> getRight()
	public abstract def Either<L, R> ifLeft((L)=>void leftConsumer)
	public abstract def Either<L, R> ifRight((R)=>void rightConsumer)
	public abstract def boolean isLeft()
	public abstract def boolean isRight()
	public abstract def L leftOr(L alternative)
	public abstract def R rightOr(L alternative)
	public abstract def L leftOrCompute((R)=>L alternative)
	public abstract def R rightOrCompute((L)=>R alternative)
	public abstract def <X extends Exception> R rightOrThrow((L)=>X exceptionProvider) throws X
	public abstract def <X extends Exception> R leftOrThrow((R)=>X exceptionProvider) throws X
	public abstract def <X> X transform((L)=>X leftTransform,(R)=>X rightTransform)
	public abstract def <X> X consume((L)=>void leftConsumer,(R)=>void rightConsumer)
	public abstract def Either<R,L> swap()
	
	// TODO makes sense?
//	public abstract def Try<L> tryLeft()
//	public abstract def Try<L> tryLeft((R)=>Exception exceptionProducer)
//	public abstract def Try<L> tryRight()
//	public abstract def Try<L> tryRight((L)=>Exception exceptionProducer)
	
	
//	private static class Left<L,R> extends Either<L,R> {
//		private L left
//		new(L left) {
//			this.left = left
//		}
//		// TODO implement methods 
//		
//	}
//
//	private static class Right<L,R> extends Either<L,R> {
//		private R right
//		new(R right) {
//			this.right = right
//		}
//		// TODO implement methods 
//		
//	}
	
	public static def <L,R> Either<L,R> left(L l) {
//		new Left(l.requireNonNull)
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	public static def <L,R> Either<L,R> right(R r) {
//		new Right(r.requireNonNull)
		throw new UnsupportedOperationException("Not implemented yet")
	}
	
	def static void main(String[] args) {
		val Either<BigInteger,Double> foo = Either::left(10BI)
		val Number bar = foo.get
		println(bar)
	}
	
	public static def <T, L extends T, R extends T> T get(Either<L,R> either) {
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
}
