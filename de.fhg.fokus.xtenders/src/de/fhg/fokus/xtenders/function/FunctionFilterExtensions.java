package de.fhg.fokus.xtenders.function;

import static de.fhg.fokus.xtenders.optional.OptionalExtensions.*;

import java.util.Optional;
import java.util.function.Function;
import java.util.function.Predicate;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.Functions.Function3;
import org.eclipse.xtext.xbase.lib.Functions.Function4;
import org.eclipse.xtext.xbase.lib.Functions.Function5;
import org.eclipse.xtext.xbase.lib.Functions.Function6;

public final class FunctionFilterExtensions {
	
	private FunctionFilterExtensions() {
		throw new IllegalStateException("FunctionFilterExtensions not intended to be instantiated");
	}
	
	@Pure
	public static <T,R> @NonNull Function1<T, Optional<R>> filterResult(@NonNull Function1<T, R> self, @NonNull Predicate<R> predicate) {
		return (t) -> maybe(self.apply(t)).filter(predicate);
	}
	
	// TODO filterResult for Functions with more inputs
	// TODO filterResult by class
	
	@Pure
	public static <T,R> @NonNull Function1<T, R> safe(@NonNull Function1<T, R> func) {
		return t -> t == null ? null : func.apply(t);
	}
	
	@Pure
	public static <T,U,R> @NonNull Function2<T, U, R> safe(@NonNull Function2<T, U, R> func) {
		return (t,u) -> (t == null || u == null) ? null : func.apply(t,u);
	}
	
	@Pure
	public static <T,U,V,R> @NonNull Function3<T, U, V, R> safe(@NonNull Function3<T, U, V, R> func) {
		return (t,u,v) -> (t == null || u == null || v == null) ? null : func.apply(t,u,v);
	}
	
	// TODO ignore safe for more functions
	
	@Pure
	public static <T,R> @NonNull Function1<T, Optional<R>> noNull(@NonNull Function1<T, R> func) {
		return (t) -> (t == null) ? none() : maybe(func.apply(t));
	}
	
	@Pure
	public static <T, U, R> @NonNull Function2<T, U, Optional<R>> noNull(@NonNull Function2<? super T, ? super U, ? extends R> func) {
		return (t, u) -> (t == null || u == null) ? none() : maybe(func.apply(t, u));
	}
	
	@Pure
	public static <T, U, V, R> @NonNull Function3<T, U, V, Optional<R>> noNull(@NonNull Function3<? super T, ? super U, ? super V, ? extends R> func) {
		return (t, u, v) -> (t == null || u == null || v == null) ? none() : maybe(func.apply(t, u, v));
	}
	
	@Pure
	public static <T, U, V, W, R> @NonNull Function4<T, U, V, W, Optional<R>> noNull(@NonNull Function4<? super T, ? super U, ? super V, ? super W, ? extends R> func) {
		return (t, u, v, w) -> (t == null || u == null || v == null || w == null) ? none() : maybe(func.apply(t, u, v, w));
	}
	
	@Pure
	public static <T, U, V, W, X, R> @NonNull Function5<T, U, V, W, X, Optional<R>> noNull(@NonNull Function5<? super T, ? super U, ? super V, ? super W, ? super X, ? extends R> func) {
		return (t, u, v, w, x) -> (t == null || u == null || v == null || w == null || x == null) ? none() : maybe(func.apply(t, u, v, w, x));
	}
	
	@Pure
	public static <T, U, V, W, X, Y, R> @NonNull Function6<T, U, V, W, X, Y, Optional<R>> noNull(@NonNull Function6<? super T, ? super U, ? super V, ? super W, ? super X, ? super Y, ? extends R> func) {
		return (t, u, v, w, x, y) -> (t == null || u == null || v == null || w == null || x == null || y == null) ? none() : maybe(func.apply(t, u, v, w, x, y));
	}

	
}
