package de.fhg.fokus.xtensions.iteration.internal

import de.fhg.fokus.xtensions.iteration.Partition

/**
 * Very simple implementation of {@link Partition} simply
 * holding both partitions as fields given via constructor.
 */
class PartitionImpl<S,R> implements Partition<S,R> {
	
	val S selected
	val R rejected
	
	/**
	 * @param selected the selected partition to be returned via {@link #getSelected()}.
	 * @param rejected the rejected partition to be returned via {@link #getRejected()}.
	 */
	new(S selected, R rejected) {
		this.selected = selected
		this.rejected = rejected
	}
	
	override getSelected() {
		selected
	}
	
	override getRejected() {
		rejected
	}
	
	override asPair() {
		selected -> rejected
	}
	
}