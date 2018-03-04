package de.fhg.fokus.xtensions.incubation.function

/**
 * Allowing for currying all parameters except for the first one to allow 
 * simple chaining of functions using the {@link de.fhg.fokus.xtensions.function.FunctionExtensions#operator_tripleGreaterThan(Object,Function1) >>>} 
 * operator.
 */
class FunctionChaining {
	
	static def <T,U,R> (T)=>R rcurry((T,U)=>R func, U param) {
		[func.apply(it, param)]
	}
	
	static def <T,U,V,R> (T)=>R rcurry((T,U,V)=>R func, U param1, V param2) {
		[func.apply(it, param1, param2)]
	}
	
	static def <T,U,V,W,R> (T)=>R rcurry((T,U,V,W)=>R func, U param1, V param2, W param3) {
		[func.apply(it, param1, param2, param3)]
	}
	
	static def <T,U,V,W,X,R> (T)=>R rcurry((T,U,V,W,X)=>R func, U param1, V param2, W param3, X param4) {
		[func.apply(it, param1, param2, param3, param4)]
	}
	
	static def <T,U,V,W,X,Y,R> (T)=>R rcurry((T,U,V,W,X,Y)=>R func, U param1, V param2, W param3, X param4, Y param5) {
		[func.apply(it, param1, param2, param3, param4, param5)]
	}
	
}