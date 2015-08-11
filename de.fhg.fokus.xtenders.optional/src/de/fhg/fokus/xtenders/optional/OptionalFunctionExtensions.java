package de.fhg.fokus.xtenders.optional;

import static de.fhg.fokus.xtenders.optional.OptionalExtensions.*;

import java.util.Optional;
import java.util.function.Predicate;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.Functions.Function3;
import org.eclipse.xtext.xbase.lib.Functions.Function4;
import org.eclipse.xtext.xbase.lib.Functions.Function5;
import org.eclipse.xtext.xbase.lib.Functions.Function6;

public class OptionalFunctionExtensions {

	public static <T> @NonNull Function1<T, Boolean> notNull() {
		return t -> t != null;
	}
	
	@Pure
	public static <T,R> @NonNull Function1<T, Optional<R>> noNull(@NonNull Function1<T, R> func) {
		return (t) -> (t == null) ? none() : maybe(func.apply(t));
	}
	
	@Pure
	public static <T,R> @NonNull Function1<T, Optional<R>> filter(@NonNull Function1<T, R> self, @NonNull Predicate<R> predicate) {
		return (t) -> maybe(self.apply(t)).filter(predicate);
	}
	
	// TODO filter for Functions with more inputs
	// TODO filter by class
	
	@Pure
	public static <T,R> @NonNull Function1<T, Optional<R>> filterFlat(@NonNull Function1<T, @NonNull Optional<R>> self, @NonNull Predicate<R> predicate) {
		return (t) -> self.apply(t).filter(predicate);
	}
	
	@Pure
	public static <T,R> @NonNull Function1<T, Optional<R>> preFor(@NonNull Function1<? super T, Boolean> self, @NonNull Function1<? super T, ? extends R> func) {
		return t -> self.apply(t) ? maybe(func.apply(t)) : none();
	}
	
	@Pure
	public static <T,R> @NonNull Function1<T,Boolean> nullToFalse(@NonNull Function1<T,Boolean> self) {
		return t -> t == null ? false : self.apply(t);
	}
	
	@Pure
	public static <T,R> @NonNull Function1<T, R> ignoreNull(@NonNull Function1<T, R> func) {
		return t -> t == null ? null : func.apply(t);
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
