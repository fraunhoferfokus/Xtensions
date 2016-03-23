package de.fhg.fokus.xtenders.optional;

import java.util.Optional;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.jdt.annotation.Nullable;
import org.eclipse.xtext.xbase.lib.Inline;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

public final class ExceptionToOptional {

	private ExceptionToOptional() {
		throw new IllegalStateException("ExceptionToOptional is not allowed to be instantiated");
	}
	
	@FunctionalInterface
	public static interface ThrowingSupplier<T> {
		
		public @Nullable T supply() throws Exception;

		@SuppressWarnings("null")// cast result to T
		public default @NonNull Optional<T> eval() {
			try {
				return Optional.ofNullable((T)supply());
			} catch (Exception e) {
				return Optional.empty();
			}
		}

		public default ThrowingSupplier<T> doCatch(Consumer<Exception> catching) {
			return () -> {
				try {
					return this.supply();
				} catch (Exception e) {
					catching.accept(e);
					// return null value so eval will turn it into an empty optional
					return null;
				}
			};
		}

		public default ThrowingSupplier<T> doCatch() {
			return () -> {
				try {
					return this.supply();
				} catch (Exception e) {
					// swallow exception
					// return null value so eval will turn it into an empty optional
					return null;
				}
			};
		}
		
		@SuppressWarnings("unchecked") // cast is safe
		public default <X extends Exception> ThrowingSupplier<T> doCatch(Class<X> exceptionType, Consumer<X> catching) {
			return () -> {
				try {
					return this.supply();
				} catch (Exception e) {
					if (exceptionType.isInstance(e)) {
						catching.accept((X) e);
						// return null value so eval will turn it into an empty optional
						return null;
					}
					// re-throw exception if it is not of exceptionType
					throw e;
				}
			};
		}
		
		@SuppressWarnings("unchecked") // cast is safe
		public default <X extends Exception> ThrowingSupplier<T> doRecover(Class<X> exceptionType, Function<X, T> catching) {
			return () -> {
				try {
					return this.supply();
				} catch (Exception e) {
					if (exceptionType.isInstance(e)) {
						return catching.apply((X) e);
						// return null value so eval will turn it into an empty optional
					}
					// re-throw exception if it is not of exceptionType
					throw e;
				}
			};
		}
	}
	
	public static <T> @NonNull Optional<T> catching(@NonNull Supplier<T> self, @NonNull Consumer<? super Exception> handler) {
		try {
			return Optional.ofNullable(self.get());
		} catch(Exception e) {
			handler.accept(e);
			return Optional.empty();
		}
	}
	
	public static <T> @NonNull Optional<T> doCatch(@NonNull Function0<T> self, @NonNull Consumer<? super Exception> handler) {
		try {
			return Optional.ofNullable(self.apply());
		} catch(Exception e) {
			handler.accept(e);
			return Optional.empty();
		}
	}
	
	public static <T> @NonNull Optional<T> doCatch(@NonNull Function0<T> self) {
		try {
			return Optional.ofNullable(self.apply());
		} catch(Exception e) {
			return Optional.empty();
		}
	}

	@Inline(value = "$1", imported=ThrowingSupplier.class)
	public static <T> @NonNull ThrowingSupplier<T> trySupply(@NonNull ThrowingSupplier<T> supplier) {
		return supplier;
	}
}
