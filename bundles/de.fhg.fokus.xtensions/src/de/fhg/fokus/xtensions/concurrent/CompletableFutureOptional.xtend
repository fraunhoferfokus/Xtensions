package de.fhg.fokus.xtensions.concurrent

import java.util.concurrent.CompletableFuture
import static extension de.fhg.fokus.xtensions.concurrent.CompletableFutureExtensions.*
import java.util.Objects

class CompletableFutureOptional {
	
	/**
	 * If handler provides {@code null} value, the returned future will be completed
	 * exceptionally with a {@link NullPointerException}.
	 * @throws NullPointerException if either {@code fut}, {@code handler} is null.
	 */
	static def <T> CompletableFuture<T> recoverNotPresent(CompletableFuture<T> fut, ()=>T handler) throws NullPointerException {
		Objects.requireNonNull(fut)
		Objects.requireNonNull(handler)
		fut.then[if(it===null) handler.apply else it]
	}
	
	//static def <T> CompletableFuture<Void> ifNonNull(CompletableFuture<T> fut, (T)=>void mapper){} // use if not interested in null case, otherweise see nonNull
	//static def <T> CompletableFuture<Void> ifNonNullAsync(CompletableFuture<T> fut, Executor e, (U)=>void mapper){}	
	//static def <T> CompletableFuture<Void> ifNonNullAsync(CompletableFuture<T> fut, (T)=>void mapper){} 
	
	//static def <T,U> CompletableFuture<T> recoverNull(CompletableFuture<T> fut, ()=>CompletionStage<? extends T> mapper){}
	// recover null or failed?
	
	//private static def <T> CompletableFuture<T> nullPointerFuture() // completed with NullPointerException
	//static def <T,U> CompletableFuture<U> nonNull(CompletableFuture<T> fut, (T)=>U) // + (T)=>void version + async versions. Completes with NullPointerException if null
	//static def <T,U> CompletableFuture<U> nonNullCompose(CompletableFuture<T> fut, (T)=>CompletionStage<? extends U> mapper){}
	//static def <T,U> CompletableFuture<U> nonNullComposeAsync(CompletableFuture<T> fut, Executor e, (U)=>CompletionStage<? extends U> mapper){}	
	//static def <T,U> CompletableFuture<U> nonNullComposeAsync(CompletableFuture<T> fut, (U)=>CompletionStage<? extends U> mapper){}
	
	// To make use of OptionalExtensions.ifPresent
	//static def <T> void =>(CompletableFuture<T> fut, (Optional<T>)=>void handler){}
	
	// + Async versions 
	/////// To CompletableFuture<Optional<T>>
	// static def <T> CompletableFuture<U> maybe(CompletableFuture<T>, (Optional<T>)=>U) // + (Optional<T>)=>void 
	// static def <T> CompletableFuture<Optional<T>> void findAsync(CompletableFuture<T>, Predicate<T>) // + version with Executor
	/////// On CompletableFuture<Optional<T>>
	// static def CompletableFuture<Void> void ifPresent(CompletableFuture<Optional<T>>, (T)=>void)
	// static def <T> CompletableFuture<T> orElseCompose(CompletableFuture<Optional<T>>, ()=>CompletableFuture<T>)
	// on empty or exception???
	// static def <T> CompletableFuture<Optional<U>> mapCompose(CompletableFuture<Optional<T>> fut, (T)=>CompletableFuture<U> mapper){}
	// static def <T> CompletableFuture<Optional<U>> flatMapCompose(CompletableFuture<Optional<T>> fut, (T)=>CompletableFuture<Optional<U>> mapper){}
}