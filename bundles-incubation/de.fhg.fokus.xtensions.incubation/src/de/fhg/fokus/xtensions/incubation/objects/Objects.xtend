package de.fhg.fokus.xtensions.incubation.objects

import java.util.function.Supplier
import java.util.function.ToIntFunction
import java.util.function.Predicate
import static extension java.util.Objects.*

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


}
