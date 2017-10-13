package de.fhg.fokus.xtensions.incubation.iteration

import java.util.function.IntConsumer

class Loop {
	
	static def <T> void forEach(Iterable<T> iterable, (LoopControl, T)=>void loopBody) {
		val control = new LoopControl
		val iterator = iterable.iterator
		while(iterator.hasNext) {
			val element = iterator.next
			loopBody.apply(control, element)
			if(control.stopAfterIteration) {
				return
			}
		}
	}
	
	static def <T> T loop((ReturnLoopControl<T>)=>void loopBody) {
		val control = new ReturnLoopControl<T>
		while(true) {
			loopBody.apply(control)
			if(control.resultSet) {
				return control.result
			}
		}
	}
	
	static def times(int times, IntConsumer loopBody) {
		if(times < 0) {
			throw new IllegalArgumentException("Iteration times must be positive")
		}
		for(var i = 0; i < times; i++) {
			loopBody.accept(i)
		}
	}
	
	static def times(int times, Runnable loopBody) {
		if(times < 0) {
			throw new IllegalArgumentException("Iteration times must be positive")
		}
		for(var i = 0; i < times; i++) {
			loopBody.run
		}
	}
}