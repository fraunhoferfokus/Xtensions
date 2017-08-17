package de.fhg.fokus.xtensions.incubation.iteration

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
}