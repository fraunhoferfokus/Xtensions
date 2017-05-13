package de.fhg.fokus.xtensions.incubation.immutable

import java.util.Optional

/**
 * Focus objects can be used to "zoom" into a nested object structure
 * without having to care if all objects exist along the structure.
 * When zoomed into a data structure and applying a change down in the 
 * hierarchy (using the {@link Focus#apply(org.eclipse.xtext.xbase.lib.Functions.Function1) 
 * apply((O)=>O)} method) 
 */
abstract class Focus<I, O> implements ((O)=>O)=>Optional<I> {

	package static final Focus<?, ?> EMPTY_FOCUS = new Focus<Object, Object>() {

		override <Y> zoom((Object)=>Focus<Object, Y> focusProvider) {
			EMPTY_FOCUS as Focus<Object, Y>
		}

		override getOpt() {
			Optional.empty
		}

		override apply((Object)=>Object mapper) {
			Optional.empty
		}

		override get() {
			null
		}

	}

	package new() {
	}

	public static def <I, O> Focus<I, O> create(((O)=>O)=>I updater, O wrapped) {
		if (wrapped == null) {
			EMPTY_FOCUS as Focus<I, O>
		} else {
			new ValueFocus<I, O>(updater, wrapped)
		}
	}
	
	// creating object if not there
	// maybe has to be part of Focus-Getter instead?
	// TODO def Focus<I,Y> zoomOrCreate((O)=>Focus<O, Y> focusProvider, =>Y factory) 

	/**
	 * Focus on a feature on the focused feature
	 */
	abstract def <Y> Focus<I, Y> zoom((O)=>Focus<O, Y> focusProvider)

	abstract def O get()

	abstract def Optional<O> getOpt()

	/**
	 * Applies an operation on the feature in focus and returns the 
	 * changed root element along the zoom operations. Along the 
	 * zoom-path an element is not available, the method returns an 
	 * empty object, otherwise the returned option will contain the
	 * changed root object.
	 * @param mapper function modifying the focused feature
	 * @return optional containing the changed root object, if all
	 *  elements along the zoom path exists, otherwise an empty optional
	 *  will be returned.
	 */
	abstract override Optional<I> apply((O)=>O mapper)
}

package final class ValueFocus<I, O> extends Focus<I, O> {

	private val ((O)=>O)=>I updater
	private val O value // must be not null

	package new(((O)=>O)=>I updater, O wrapped) {
		this.updater = updater
		this.value = wrapped
	}

	override <Y> zoom((O)=>Focus<O, Y> focusProvider) {
		val zoomedFocus = focusProvider.apply(value)
		switch (zoomedFocus) {
			case EMPTY_FOCUS:
				EMPTY_FOCUS as Focus<I, Y>
			ValueFocus: {
				val newWrapped = zoomedFocus.value as Y
				val focusUpdater = zoomedFocus.updater as ((Y)=>Y)=>O
				val zoomedUpdate = zoomedUpdater(focusUpdater)
				new ValueFocus(zoomedUpdate, newWrapped)
			}
		}
	}

	private def <Y> ((Y)=>Y)=>I zoomedUpdater(((Y)=>Y)=>O focusUpdater) {
		[ (Y)=>Y innerMapper |
			updater.apply [
				if (it == null) {
					return null
				}
				focusUpdater.apply(innerMapper)
			]
		]
	}

	override get() {
		value
	}

	override getOpt() {
		Optional.of(value)
	}

	override apply((O)=>O mapper) {
		Optional.ofNullable(value).map[updater.apply(mapper)]
	}

}