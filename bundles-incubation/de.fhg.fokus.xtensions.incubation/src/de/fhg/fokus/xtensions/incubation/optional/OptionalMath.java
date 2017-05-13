package de.fhg.fokus.xtensions.incubation.optional;

import java.util.OptionalDouble;
import java.util.OptionalInt;
import java.util.OptionalLong;

import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.xbase.lib.Pure;

import com.google.common.annotations.Beta;

@Beta
public class OptionalMath {

	/////////////////
	// OptionalInt //
	/////////////////

	@Pure
	public static <T> @NonNull OptionalInt operator_plus(@NonNull OptionalInt self, int rhs) {
		return self.isPresent() ? OptionalInt.of(self.getAsInt() + rhs) : OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_plus(int lhs, @NonNull OptionalInt rhs) {
		return rhs.isPresent() ? OptionalInt.of(lhs + rhs.getAsInt()) : OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_plus(@NonNull OptionalInt lhs, @NonNull OptionalInt rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalInt.of(lhs.getAsInt() + rhs.getAsInt())
				: OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_minus(@NonNull OptionalInt self, int rhs) {
		return self.isPresent() ? OptionalInt.of(self.getAsInt() - rhs) : OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_minus(int lhs, @NonNull OptionalInt rhs) {
		return rhs.isPresent() ? OptionalInt.of(lhs - rhs.getAsInt()) : OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_minus(@NonNull OptionalInt lhs, @NonNull OptionalInt rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalInt.of(lhs.getAsInt() - rhs.getAsInt())
				: OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_multiply(@NonNull OptionalInt self, int rhs) {
		return self.isPresent() ? OptionalInt.of(self.getAsInt() * rhs) : OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_multiply(@NonNull OptionalInt lhs, @NonNull OptionalInt rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalInt.of(lhs.getAsInt() * rhs.getAsInt())
				: OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_multiply(int lhs, @NonNull OptionalInt rhs) {
		return rhs.isPresent() ? OptionalInt.of(lhs * rhs.getAsInt()) : OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_divide(@NonNull OptionalInt self, int rhs) {
		return self.isPresent() ? OptionalInt.of(self.getAsInt() / rhs) : OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_divide(int lhs, @NonNull OptionalInt rhs) {
		return rhs.isPresent() ? OptionalInt.of(lhs / rhs.getAsInt()) : OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_modulo(@NonNull OptionalInt self, int rhs) {
		return self.isPresent() ? OptionalInt.of(self.getAsInt() % rhs) : OptionalInt.empty();
	}

	@Pure
	public static <T> @NonNull OptionalInt operator_modulo(int lhs, @NonNull OptionalInt rhs) {
		return rhs.isPresent() ? OptionalInt.of(lhs % rhs.getAsInt()) : OptionalInt.empty();
	}

	// interop with OptionalLong, result upcast to OptionalLong

	@Pure
	public static <T> @NonNull OptionalLong operator_plus(@NonNull OptionalLong lhs, @NonNull OptionalInt rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsLong() + rhs.getAsInt())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_plus(@NonNull OptionalInt lhs, @NonNull OptionalLong rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsInt() + rhs.getAsLong())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_minus(@NonNull OptionalLong lhs, @NonNull OptionalInt rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsLong() - rhs.getAsInt())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_minus(@NonNull OptionalInt lhs, @NonNull OptionalLong rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsInt() - rhs.getAsLong())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_divide(@NonNull OptionalLong lhs, @NonNull OptionalInt rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsLong() / rhs.getAsInt())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_divide(@NonNull OptionalInt lhs, @NonNull OptionalLong rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsInt() / rhs.getAsLong())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_multiply(@NonNull OptionalLong lhs, @NonNull OptionalInt rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsLong() * rhs.getAsInt())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_multiply(@NonNull OptionalInt lhs, @NonNull OptionalLong rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsInt() * rhs.getAsLong())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_modulo(@NonNull OptionalLong lhs, @NonNull OptionalInt rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsLong() % rhs.getAsInt())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_modulo(@NonNull OptionalInt lhs, @NonNull OptionalLong rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsInt() % rhs.getAsLong())
				: OptionalLong.empty();
	}

	//////////////////
	// OptionalLong //
	//////////////////

	@Pure
	public static <T> @NonNull OptionalLong operator_plus(@NonNull OptionalLong self, long rhs) {
		return self.isPresent() ? OptionalLong.of(self.getAsLong() + rhs) : OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_plus(long lhs, @NonNull OptionalLong rhs) {
		return rhs.isPresent() ? OptionalLong.of(lhs + rhs.getAsLong()) : OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_plus(@NonNull OptionalLong lhs, @NonNull OptionalLong rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsLong() + rhs.getAsLong())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_minus(@NonNull OptionalLong self, long rhs) {
		return self.isPresent() ? OptionalLong.of(self.getAsLong() - rhs) : OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_minus(long lhs, @NonNull OptionalLong rhs) {
		return rhs.isPresent() ? OptionalLong.of(lhs - rhs.getAsLong()) : OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_minus(@NonNull OptionalLong lhs, @NonNull OptionalLong rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsLong() - rhs.getAsLong())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_multiply(@NonNull OptionalLong self, long rhs) {
		return self.isPresent() ? OptionalLong.of(self.getAsLong() * rhs) : OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_multiply(@NonNull OptionalLong lhs, @NonNull OptionalLong rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalLong.of(lhs.getAsLong() * rhs.getAsLong())
				: OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_multiply(long lhs, @NonNull OptionalLong rhs) {
		return rhs.isPresent() ? OptionalLong.of(lhs * rhs.getAsLong()) : OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_divide(@NonNull OptionalLong self, long rhs) {
		return self.isPresent() ? OptionalLong.of(self.getAsLong() / rhs) : OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_divide(long lhs, @NonNull OptionalLong rhs) {
		return rhs.isPresent() ? OptionalLong.of(lhs / rhs.getAsLong()) : OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_modulo(@NonNull OptionalLong self, long rhs) {
		return self.isPresent() ? OptionalLong.of(self.getAsLong() % rhs) : OptionalLong.empty();
	}

	@Pure
	public static <T> @NonNull OptionalLong operator_modulo(long lhs, @NonNull OptionalLong rhs) {
		return rhs.isPresent() ? OptionalLong.of(lhs % rhs.getAsLong()) : OptionalLong.empty();
	}

	////////////////////
	// OptionalDouble //
	////////////////////

	@Pure
	public static <T> @NonNull OptionalDouble operator_plus(@NonNull OptionalDouble self, double rhs) {
		return self.isPresent() ? OptionalDouble.of(self.getAsDouble() + rhs) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_plus(double lhs, @NonNull OptionalDouble rhs) {
		return rhs.isPresent() ? OptionalDouble.of(lhs + rhs.getAsDouble()) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_plus(@NonNull OptionalDouble lhs, @NonNull OptionalDouble rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsDouble() + rhs.getAsDouble())
				: OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_minus(@NonNull OptionalDouble self, double rhs) {
		return self.isPresent() ? OptionalDouble.of(self.getAsDouble() - rhs) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_minus(double lhs, @NonNull OptionalDouble rhs) {
		return rhs.isPresent() ? OptionalDouble.of(lhs - rhs.getAsDouble()) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_minus(@NonNull OptionalDouble lhs, @NonNull OptionalDouble rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsDouble() - rhs.getAsDouble())
				: OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_multiply(@NonNull OptionalDouble self, double rhs) {
		return self.isPresent() ? OptionalDouble.of(self.getAsDouble() * rhs) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_multiply(@NonNull OptionalDouble lhs,
			@NonNull OptionalDouble rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsDouble() * rhs.getAsDouble())
				: OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_multiply(double lhs, @NonNull OptionalDouble rhs) {
		return rhs.isPresent() ? OptionalDouble.of(lhs * rhs.getAsDouble()) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_divide(@NonNull OptionalDouble self, double rhs) {
		return self.isPresent() ? OptionalDouble.of(self.getAsDouble() / rhs) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_divide(double lhs, @NonNull OptionalDouble rhs) {
		return rhs.isPresent() ? OptionalDouble.of(lhs / rhs.getAsDouble()) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_modulo(@NonNull OptionalDouble self, double rhs) {
		return self.isPresent() ? OptionalDouble.of(self.getAsDouble() % rhs) : OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_modulo(double lhs, @NonNull OptionalDouble rhs) {
		return rhs.isPresent() ? OptionalDouble.of(lhs % rhs.getAsDouble()) : OptionalDouble.empty();
	}

	// interop with OptionalInt and OptionalLong with upcast to double

	@Pure
	public static <T> @NonNull OptionalDouble operator_multiply(@NonNull OptionalInt lhs, @NonNull OptionalDouble rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsInt() * rhs.getAsDouble())
				: OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_multiply(@NonNull OptionalDouble lhs, @NonNull OptionalInt rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsDouble() * rhs.getAsInt())
				: OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_multiply(@NonNull OptionalLong lhs,
			@NonNull OptionalDouble rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsLong() * rhs.getAsDouble())
				: OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_multiply(@NonNull OptionalDouble lhs,
			@NonNull OptionalLong rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsDouble() * rhs.getAsLong())
				: OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_plus(@NonNull OptionalInt lhs, @NonNull OptionalDouble rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsInt() + rhs.getAsDouble())
				: OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_plus(@NonNull OptionalDouble lhs, @NonNull OptionalInt rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsDouble() + rhs.getAsInt())
				: OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_plus(@NonNull OptionalLong lhs, @NonNull OptionalDouble rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsLong() + rhs.getAsDouble())
				: OptionalDouble.empty();
	}

	@Pure
	public static <T> @NonNull OptionalDouble operator_plus(@NonNull OptionalDouble lhs, @NonNull OptionalLong rhs) {
		return lhs.isPresent() && rhs.isPresent() ? OptionalDouble.of(lhs.getAsDouble() + rhs.getAsLong())
				: OptionalDouble.empty();
	}

	// TODO double / int,long interop for operators / - %
}
