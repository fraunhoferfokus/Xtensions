package de.fhg.fokus.xtensions.incubation.function

/**
 * The {@code Trampoline} allows recursive function style programming to be written
 * imperatively under the hood.<br>
 * This API is <em>not</em> thread safe. Do not use a {@code Trampoline} object 
 * concurrently.<br>
 * As the entry point, call {@link Trampoline#jump(Function1) Trampoline.jump}, in the passed
 * lambda, the first pseudo-tail-recursive call can be started.
 */
class Trampoline<T> {
	
	static Bounce nowCall = new Bounce
	static Bounce nowReturn = new Bounce
	
	T result
	(Trampoline<T>)=>Bounce toCall
	
	/**
	 * Starting point for pseudo-recursive call.
	 * @param jump Function starting 
	 */
	static def <T> T jump((Trampoline<T>)=>Bounce jump) {
		val trampoline = new Trampoline<T>
		trampoline.toCall = jump
		var Bounce r
		do {
			r = trampoline.toCall.apply(trampoline)
		} while (r !== nowReturn)
		trampoline.result
	}
	
	/**
	 * Start pseudo-recursive call
	 */
	def Bounce call((Trampoline<T>)=>Bounce callee) {
		this.toCall = callee
		nowCall
	}
	
	/**
	 * Return result a value
	 */
	def Bounce result(T t) {
		this.result = t
		nowReturn
	}
}

/**
 * Return value of functions, passed to {@link Trampoline#call(Functions.Function1) Trampoline.call((Trampoline<T>)=>Bounce)}.
 * The only way to create instances of {@code Bounce} is to call 
 * <ul>
 * <li>
 *   {@link Trampoline#call(Functions.Function1) Trampoline.call((Trampoline<T>)=>Bounce)} to initiate a pseudo-recursive call or 
 * </li>
 * <li>
 *   {@link Trampoline#result(Object) Trampoline.result(T)} to return a final result.
 * </li>
 * </ul>
 */
class Bounce {
	package new() {}
}