package de.fhg.fokus.xtensions.incubation

import java.util.function.Supplier
import java.util.function.ToIntFunction
import java.util.function.Predicate

class Objects {

	// TODO: public static def <T> long getLong(T obj, long onNull, ToLongFunction<T> mapper)
	// TODO: public static def <T> double getLong(T obj, double onNull, ToDoubleFunction<T> mapper)
	static def <T> int getInt(T obj, int onNull, ToIntFunction<T> mapper) {
		if (obj === null) {
			onNull
		} else {
			mapper.applyAsInt(obj)
		}
	}

	static def <T> boolean getBool(T obj, boolean onNull, Predicate<T> mapper) {
		if (obj === null) {
			onNull
		} else {
			mapper.test(obj)
		}
	}

	/**
	 * Java 9 forward compatible alias for 
	 * {@link Objects#recoverNull(Object,org.eclipse.xtext.xbase.lib.Functions.Function0) recoverNull(T, =>T)}
	 */
	static def <T> T requireNonNullElseGet​(T obj, Supplier<? extends T> supplier) {
	}

	static def <T> T recoverNull(T toTest, =>T recovery) {
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
	static def <T> T requireNonNullElse​(T obj, T defaultObj) {
		obj.recoverNull(defaultObj)
	}

	static def <T> T recoverNull(T toTest, T recovery) {
		if (toTest !== null) {
			toTest
		} else {
			recovery
		}
	}

	/**
	 * This method calls the given {@code consumer} with {@code t}, if 
	 * {@code t !== null}.<br>
	 * This method is useful when using a value in a long
	 * {@code ?.} navigation chain. Instead of buffering the
	 * value into a variable and checking the variable for {@code null}
	 * or navigating the chain again.
	 */
	static def <T> ifNotNull(T t, (T)=>void consumer) {
		if (t !== null) {
			consumer.apply(t)
		}
	}
}
