package de.fhg.fokus.xtensions.incubation.function

import static extension de.fhg.fokus.xtensions.function.FunctionExtensions.*

public class Trampoline<T> {
	
	private static Bounce nowCall = new Bounce
	private static Bounce nowReturn = new Bounce
	
	private T result
	private (Trampoline<T>)=>Bounce toCall
	
	public static def <T> T jump((Trampoline<T>)=>Bounce jump) {
		val trampoline = new Trampoline<T>
		trampoline.toCall = jump
		var Bounce r
		do {
			r = trampoline.toCall.apply(trampoline)
		} while(r !== nowReturn)
		trampoline.result
	}
	
	public def Bounce call((Trampoline<T>)=>Bounce callee) {
		this.toCall = callee
		nowCall
	}
	
	public def Bounce result(T t) {
		this.result = t
		nowReturn
	}
}
	
public class Bounce {
	package new() {}
}