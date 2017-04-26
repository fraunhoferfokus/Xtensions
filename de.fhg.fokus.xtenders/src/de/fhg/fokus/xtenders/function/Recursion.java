package de.fhg.fokus.xtenders.function;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.Functions.Function3;
import org.eclipse.xtext.xbase.lib.Functions.Function4;
import org.eclipse.xtext.xbase.lib.Functions.Function5;
import org.eclipse.xtext.xbase.lib.Functions.Function6;

public class Recursion {
	
	private Recursion() {}
	
	public static <R> @NonNull Function0<R> recursive (@NonNull Function1<@NonNull Function0<R>, R> recFunc) {
		class RecFunc implements Function0<R> {
			@Override
			public R apply() {
				return recFunc.apply(this);
			}
		}
		return new RecFunc();
	}
	
	public static <T,R> @NonNull Function1<T,R> recursive (@NonNull Function2<@NonNull Function1<T,R>, T, R> recFunc) {
		class RecFunc implements Function1<T,R> {
			@Override
			public R apply(T t) {
				return recFunc.apply(this, t);
			}
		}
		return new RecFunc();
	}
	
	public static <T,U,R> @NonNull Function2<T,U,R> recursive (@NonNull Function3<@NonNull Function2<T,U,R>, T, U, R> recFunc) {
		class RecFunc implements Function2<T,U,R> {
			@Override
			public R apply(T t, U u) {
				return recFunc.apply(this, t, u);
			}
		}
		return new RecFunc();
	}
	
	public static <T,U,V,R> @NonNull Function3<T,U,V,R> recursive (@NonNull Function4<@NonNull Function3<T,U,V,R>, T, U, V, R> recFunc) {
		class RecFunc implements Function3<T,U,V,R> {
			@Override
			public R apply(T t, U u, V v) {
				return recFunc.apply(this, t, u, v);
			}
		}
		return new RecFunc();
	}
	
	public static <T,U,V,W,R> @NonNull Function4<T,U,V,W,R> recursive (@NonNull Function5<@NonNull Function4<T,U,V,W,R>, T, U, V, W, R> recFunc) {
		class RecFunc implements Function4<T,U,V,W,R> {
			@Override
			public R apply(T t, U u, V v, W w) {
				return recFunc.apply(this, t, u, v, w);
			}
		}
		return new RecFunc();
	}
	
	public static enum TailRecResult {
		FINISHED, RECURSE
	}
	
	public static final class TailRec1<T,R> {
		
		TailRec1(T param1) {
			this.recureseParam1 = param1;
		}
		
		private T recureseParam1;
		private R result;
		
		public TailRecResult result(R result) {
			this.result = result;
			return TailRecResult.FINISHED;
		}
		
		public TailRecResult call(T param) {
			recureseParam1 = param;
			return TailRecResult.RECURSE;
		}
	}
	
	public static <T,R> @NonNull Function1<T,R> tailrec(@NonNull Function2<@NonNull TailRec1<T,R>,T,@NonNull TailRecResult> func) {
		return (t) -> {
			TailRecResult state = null;
			TailRec1<T,R> rec = new TailRec1<>(t);
			do {
				state = func.apply(rec, rec.recureseParam1);
			} while(state != TailRecResult.FINISHED);
			return rec.result;
		};
	}
	
	public static final class TailRec2<T, U, R> {

		TailRec2(T param1, U param2) {
			this.recureseParam1 = param1;
			this.recureseParam2 = param2;
		}

		private T recureseParam1;
		private U recureseParam2;
		private R result;

		public TailRecResult result(R result) {
			this.result = result;
			return TailRecResult.FINISHED;
		}

		public TailRecResult apply(T param1, U param2) {
			recureseParam1 = param1;
			recureseParam2 = param2;
			return TailRecResult.RECURSE;
		}
	}

	public static <T, U, R> @NonNull Function2<T, U, R> tailrec(@NonNull Function3<@NonNull TailRec2<T, U, R>, T, U, @NonNull TailRecResult> func) {
		return (t, u) -> {
			TailRecResult state = null;
			TailRec2<T, U, R> rec = new TailRec2<>(t, u);
			do {
				state = func.apply(rec, rec.recureseParam1, rec.recureseParam2);
			} while (state != TailRecResult.FINISHED);
			return rec.result;
		};
	}
	
	public static final class TailRec3<T, U, V, R> {

		TailRec3(T param1, U param2, V param3) {
			this.recureseParam1 = param1;
			this.recureseParam2 = param2;
			this.recureseParam3 = param3;
		}

		private T recureseParam1;
		private U recureseParam2;
		private V recureseParam3;
		private R result;

		public TailRecResult result(R result) {
			this.result = result;
			return TailRecResult.FINISHED;
		}

		public TailRecResult apply(T param1, U param2, V param3) {
			recureseParam1 = param1;
			recureseParam2 = param2;
			recureseParam3 = param3;
			return TailRecResult.RECURSE;
		}
	}

	public static <T, U, V, R> @NonNull Function3<T, U, V, R> tailrec(@NonNull Function4<@NonNull TailRec3<T, U, V, R>, T, U, V, @NonNull TailRecResult> func) {
		return (t, u, v) -> {
			TailRecResult state = null;
			TailRec3<T, U, V, R> rec = new TailRec3<>(t, u, v);
			do {
				state = func.apply(rec, rec.recureseParam1, rec.recureseParam2, rec.recureseParam3);
			} while (state != TailRecResult.FINISHED);
			return rec.result;
		};
	}
	
	public static final class TailRec4<T, U, V, W, R> {

		TailRec4(T param1, U param2, V param3, W param4) {
			this.recureseParam1 = param1;
			this.recureseParam2 = param2;
			this.recureseParam3 = param3;
			this.recureseParam4 = param4;
		}

		private T recureseParam1;
		private U recureseParam2;
		private V recureseParam3;
		private W recureseParam4;
		private R result;

		public TailRecResult result(R result) {
			this.result = result;
			return TailRecResult.FINISHED;
		}

		public TailRecResult apply(T param1, U param2, V param3, W param4) {
			recureseParam1 = param1;
			recureseParam2 = param2;
			recureseParam3 = param3;
			recureseParam4 = param4;
			return TailRecResult.RECURSE;
		}
	}

	public static <T, U, V, W, R> @NonNull Function4<T, U, V, W, R> tailrec(@NonNull Function5<@NonNull TailRec4<T, U, V, W, R>, T, U, V, W, @NonNull TailRecResult> func) {
		return (t, u, v, w) -> {
			TailRecResult state = null;
			TailRec4<T, U, V, W, R> rec = new TailRec4<>(t, u, v, w);
			do {
				state = func.apply(rec, rec.recureseParam1, rec.recureseParam2, rec.recureseParam3, rec.recureseParam4);
			} while (state != TailRecResult.FINISHED);
			return rec.result;
		};
	}
	
	public static final class TailRec5<T, U, V, W, X, R> {

		TailRec5(T param1, U param2, V param3, W param4, X param5) {
			this.recureseParam1 = param1;
			this.recureseParam2 = param2;
			this.recureseParam3 = param3;
			this.recureseParam4 = param4;
			this.recureseParam5 = param5;
		}

		private T recureseParam1;
		private U recureseParam2;
		private V recureseParam3;
		private W recureseParam4;
		private X recureseParam5;
		private R result;

		public TailRecResult result(R result) {
			this.result = result;
			return TailRecResult.FINISHED;
		}

		public TailRecResult apply(T param1, U param2, V param3, W param4, W param5) {
			recureseParam1 = param1;
			recureseParam2 = param2;
			recureseParam3 = param3;
			recureseParam4 = param4;
			return TailRecResult.RECURSE;
		}
	}

	public static <T, U, V, W, X, R> @NonNull Function5<T, U, V, W, X, R> tailrec(@NonNull Function6<@NonNull TailRec5<T, U, V, W, X, R>, T, U, V, W, X, @NonNull TailRecResult> func) {
		return (t, u, v, w, x) -> {
			TailRecResult state = null;
			TailRec5<T, U, V, W, X, R> rec = new TailRec5<>(t, u, v, w, x);
			do {
				state = func.apply(rec, rec.recureseParam1, rec.recureseParam2, rec.recureseParam3, rec.recureseParam4, rec.recureseParam5);
			} while (state != TailRecResult.FINISHED);
			return rec.result;
		};
	}
	

}
