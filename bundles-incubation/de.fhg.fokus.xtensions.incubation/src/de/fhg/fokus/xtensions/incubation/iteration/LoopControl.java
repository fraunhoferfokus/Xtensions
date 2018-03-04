package de.fhg.fokus.xtensions.incubation.iteration;

import org.eclipse.xtext.xbase.lib.Inline;

public class LoopControl {
	
	/*package*/ LoopControl(){}
	
	private boolean stopAfterIteration = true;
	
	public final void noop() {}

	@Inline(value="noop(); return", imported=LoopControl.class)
	public void CONTINUE() {}
	
	@Inline(value="setStopAfterIteration(true); return", imported=LoopControl.class)
	public void BREAK() {}
	
	public void setStopAfterIteration(boolean stop) {
		stopAfterIteration = stop;
	}
	
	public boolean getStopAfterIteration() {
		return stopAfterIteration;
	}
}
