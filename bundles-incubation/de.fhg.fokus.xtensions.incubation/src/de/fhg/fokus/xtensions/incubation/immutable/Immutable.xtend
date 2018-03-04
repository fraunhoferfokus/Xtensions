package de.fhg.fokus.xtensions.incubation.immutable

import org.eclipse.xtend.lib.macro.Active
import java.lang.annotation.ElementType
import java.lang.annotation.Target

@Target(ElementType.TYPE, ElementType.FIELD)
@Active(ImmutableProcessor)
annotation Immutable {
	public ImmutableFeature[] value = #[ImmutableFeature.UPDATE_METHODS]
}