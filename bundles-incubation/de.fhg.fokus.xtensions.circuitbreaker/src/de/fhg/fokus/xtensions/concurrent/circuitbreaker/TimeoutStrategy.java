package de.fhg.fokus.xtensions.concurrent.circuitbreaker;

import java.util.concurrent.TimeUnit;
import org.eclipse.xtext.xbase.lib.Pair;

/**
 * This interface can be used to implement strategies to choose timeout times.
 * Implementations may be stateful or purely functional. The first retry will be
 * called with {@code previousTimeout = 0}.
 */
@FunctionalInterface
public interface TimeoutStrategy {

	/**
	 * Creates an object of type {@code T} holding the given {@code timeout}
	 * of time unit {@code unit}.
	 * @param <T> type of the create type
	 */
	interface TimeFactory<T> {
		T apply(long timeout, TimeUnit timeUnit);
	}

	/**
	 * Consumer of {@code timeout} of time unit {@code timeUnit}.
	 */
	interface TimeConsumer {
		void accept(long timeout, TimeUnit timeUnit);
	}

	/**
	 * Returns the next timeout time based on the previous timeout.
	 * @param previousTimeout amount of last timeout time. If this parameter is 0
	 *   the initial timeout time is requested.
	 * @param previousTimeUnit time unit of the last timeout
	 * @param factory factory producing the returned values from the next timeout time
	 * @return object created from given {@code factory} from the next timeout time.
	 */
	<T> T next(long previousTimeout, TimeUnit previousTimeUnit, TimeFactory<T> factory);
	
	/**
	 * Calls {@code #next(long, TimeUnit, TimeFactory)} with the constructor of {@link Pair},
	 * so the pair of the next timeout time and the according time unit will be returned. The 
	 * time will be boxed into a {@code Long}.
	 * @param previousTimeout amount of last timeout time. If this parameter is 0
	 *   the initial timeout time is requested.
	 * @param previousTimeUnit time unit of the last timeout
	 * @return Pair holding the next timeout time and time unit
	 */
	default Pair<Long,TimeUnit> next(long previousTimeout, TimeUnit previousTimeUnit) {
		return next(previousTimeout, previousTimeUnit,(TimeFactory<Pair<Long,TimeUnit>>)Pair::new);
	}

	/**
	 * Alternative next method to {@link #next(long, TimeUnit, TimeFactory)} to just consume the next timeout and timeout time unit.<br>
	 * The default implementation will actually call {@link #next(long, TimeUnit, TimeFactory)} 
	 * to read the next time value.
	 * @param previousTimeout amount of last timeout time. If this parameter is 0
	 *   the initial timeout time is requested.
	 * @param previousTimeUnit time unit of the last timeout.
	 * @param consumer Will be called with the new timeout time.
	 */
	default void next(long previousTimeout, TimeUnit previousTimeUnit, TimeConsumer consumer) {
		next(previousTimeout, previousTimeUnit, (timeout, timeUnit) -> {
			consumer.accept(timeout, timeUnit);
			return null;
		});
	}

}