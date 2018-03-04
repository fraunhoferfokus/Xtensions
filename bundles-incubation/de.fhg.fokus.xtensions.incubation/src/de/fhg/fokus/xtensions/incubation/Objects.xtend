package de.fhg.fokus.xtensions.incubation

import java.util.function.Supplier

class Objects {

	/**
	 * Java 9 forward compatible alias for 
	 * {@link Objects#recoverNull(Object,org.eclipse.xtext.xbase.lib.Functions.Function0) recoverNull(T, =>T)}
	 */
	public static def <T> T requireNonNullElseGet​(T obj, Supplier<? extends T> supplier) {
	}

	public static def <T> T recoverNull(T toTest, =>T recovery) {
		if (toTest !== null) {
			toTest
		} else {
			recovery.apply
		}
	}

	/**
	 * Java 9 forward compatible alias for 
	 * {@link Objects#recoverNull(Object,Object) recoverNull(T,T)}
	 */
	public static def <T> T requireNonNullElse​(T obj, T defaultObj) {
		obj.recoverNull(defaultObj)
	}

	public static def <T> T recoverNull(T toTest, T recovery) {
		if (toTest !== null) {
			toTest
		} else {
			recovery
		}
	}

}
