package de.fhg.fokus.xtensions.incubation.iteration;

import org.eclipse.xtext.xbase.lib.Inline;

public class ReturnLoopControl<T> {
	
	/*package*/ ReturnLoopControl() {
	}

	private boolean resultSet = false;
	private T result = null;
	
	public void noop(){}
	
	@Inline("setResult($1); return")
	public void RETURN(T result) {
	}
	
	@Inline("noop(); return")
	public void CONTINUE() {
	}
	
	public void setResult(T result) {
		resultSet = true;
		this.result = result;
	}
	
	public boolean isResultSet() {
		return resultSet;
	}
	
	public T getResult() {
		return result;
	}
}
