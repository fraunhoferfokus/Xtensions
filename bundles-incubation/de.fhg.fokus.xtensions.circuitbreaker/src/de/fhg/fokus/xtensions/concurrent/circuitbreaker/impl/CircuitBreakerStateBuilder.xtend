package de.fhg.fokus.xtensions.concurrent.circuitbreaker.impl

import java.util.function.LongSupplier
import de.fhg.fokus.xtensions.concurrent.circuitbreaker.CircuitBreakerState
import de.fhg.fokus.xtensions.concurrent.circuitbreaker.TimeoutStrategy
import java.util.concurrent.atomic.AtomicReference
import java.util.concurrent.TimeUnit
import java.util.UUID
import static de.fhg.fokus.xtensions.concurrent.circuitbreaker.impl.TimeoutStrategies.*
import java.util.Objects
import java.util.concurrent.Executor
import java.util.concurrent.ForkJoinPool
import java.util.concurrent.RejectedExecutionException

/**
 * This builder class can be used to create a basic implementation of a
 * {@link CircuitBreakerState} based on the configuration of this builder.
 * The implemented state is completely non-blocking at the expense of creating
 * some garbage during operation.
 */
final class CircuitBreakerStateBuilder implements Cloneable {

	package static final ()=>TimeoutStrategy DEFAULT_HALF_OPEN_TIME = [fixedTimeout(30, TimeUnit.SECONDS)]
	package static final LongSupplier DEFAULT_TIME_SUPPLIER = [System.nanoTime]

	package var LongSupplier timeSupplier = DEFAULT_TIME_SUPPLIER
	package var int subsequentFailureCount = 5
	package var int rateFailureCount = 0
	package var int rateTotalCount = 0
	package var int perTimeFailureCount = -1
	package var long perTimeInTime = 0
	package var TimeUnit perTimeTimeUnit = null
	package var Class<? extends Throwable>[] neverRecord = null
	package var Class<? extends Throwable>[] onlyRecord = null
	package var ()=>TimeoutStrategy toHalfOpenStrategyProvider = DEFAULT_HALF_OPEN_TIME
	package var CircuitBreakerStateSwitchListener listener = null
	package var Executor listenerExecutor = ForkJoinPool.commonPool
	package var String name = null

	private new() {
	}

	/**
	 * Creates new new instance of CircuitBreakerStateBuilder.
	 */
	static def create() {
		new CircuitBreakerStateBuilder
	}

	/**
	 * Sets the name of the circuit breaker state. If not set a random
	 * UUID will be generated as name. If set to {@code null}, also a
	 * UUID will be used.<br>
	 * The name will be passed to listener on state change (see {@link #listener(CircuitBreakerStateSwitchListener)})
	 * @param name of the circuit breaker. If called with {@code null} a default name
	 *  will be selected
	 * @return new CircuitBreakerStateBuilder with changed option
	 */
	def CircuitBreakerStateBuilder name(String name) {
		val result = this.clone
		result.name = name
		result
	}

	/**
	 * This method sets the time provider that is used to check for timeouts. This 
	 * is especially useful when testing timing issues.<br>
	 * The default provider uses {@link System#nanoTime()}. To reset to the default
	 * provider, call with {@code nanoTimeProvider = null}.
	 * @param nanoTimeProvider function providing the current system time. If {@code null}
	 *   the default time provider will be used. 
	 * @return new CircuitBreakerStateBuilder with changed option
	 */
	def CircuitBreakerStateBuilder nanoTimeProvider(LongSupplier nanoTimeProvider) {
		val result = this.clone
		result.timeSupplier = if(nanoTimeProvider === null) DEFAULT_TIME_SUPPLIER else nanoTimeProvider
		result
	}

	/**
	 * Sets the count of consecutive errors that will cause the state to switch to open state.<br> 
	 * If this option is enabled with other  opening criteria, the state will switch to open 
	 * if <em>any</em> of the criteria matches.<br>
	 * If {@code count = 0} the option will be disabled.<br>
	 * Default value: 5
	 * @param count maximum allowed number or consecutive errors to occur. Must be {@code >=0}.
	 *  If set to {@code = 0} the option will be disabled.
	 * @return new CircuitBreakerStateBuilder with changed option
	 * 
	 * @see #openOnFailureRate(int, int)
	 * @see #openOnFailureCountInTime(int, long, TimeUnit)
	 */
	def CircuitBreakerStateBuilder openOnSubsequentFailureCount(int count) {
		if (count < 0) {
			throw new IllegalArgumentException("Subsequent error count must be >= 0")
		}
		val result = this.clone
		result.subsequentFailureCount = count
		result
	}

	/**
	 * When the given rate of failures ({@code failureCount} errors in the last 
	 * {@code totalCount} operations) is reached in the built CircuitBreakerState,
	 * the state will switch to open, not permitting further operations to be carried out.<br>
	 * If this option is enabled with other opening criteria, the state will switch
	 * to open if <em>any</em> of the criteria matches.<br> 
	 * To disable this option, call with {@code totalCount = 0}<br>
	 * By default no failure rate configured.
	 * @param failureCount amount of failures in {@code totalCount} of last reported 
	 *   ended operations (success and failure) that will cause the circuit to open.
	 *   Must be {@code > 0}.
	 * @param totalCount amount of last operation outcomes that will be recorded to 
	 *   check for {@code failureCount} errors. Must be {@code >= 0}. If is 0, the 
	 *   option will be disabled.
	 * @throws IllegalArgumentException if the precondition of any parameter is violated.
	 * 
	 * @see #openOnSubsequentFailureCount(int)
	 * @see #openOnFailureCountInTime(int, long, TimeUnit)
	 */
	def CircuitBreakerStateBuilder openOnFailureRate(int failureCount, int totalCount) {
		if (failureCount <= 0) {
			throw new IllegalArgumentException("failureCount must be greater than 0.")
		}
		if (totalCount < 0) {
			throw new IllegalArgumentException("failureCount must be greater than or equal to 0.")
		}
		val result = this.clone
		result.rateFailureCount = failureCount
		result.rateTotalCount = totalCount
		result
	}

	// TODO version with Duration
	/**
	 * Configures that closed state switches to open, when in time interval {@code time} of 
	 * {@code unit} more than {@code failureCount} errors occur.
	 * Internally the state will calculate in nanoseconds, so any configured time exceeding 
	 * {@link Long#MAX_VALUE} nanoseconds (around 292.5 years) will be limited to {@code MAX_VALUE} nanoseconds.<br>
	 * If this option is enabled with other opening criteria, 
	 * the state will switch to open if <em>any</em> of the criteria matches.<br><br>
	 * By default, no failure count in time is configured. To disable the option, call with
	 * {@code failureCount = 0} or {@code time = 0} or {@code unit = null}.
	 * @param failureCount the maximum allowed count of errors to occur in a time-slice
	 *   of length of {@code time} in {@code unit}. Must be {@code >= 0}. If {@code = 0}
	 *   the option will be disabled.
	 * @param time length of time slice in {@code unit} in which errors are counted. 
	 *   Must be {@code >= 0}. If {@code = 0} the option will be disabled.
	 * @param unit time unit of time slice of size {@code time}. If {@code = null} the
	 *   option will be disabled.
	 * @throws IllegalArgumentException if any of the preconditions are not met.
	 * 
	 * @see #openOnFailureRate(int, int)
	 * @see #openOnSubsequentFailureCount(int)
	 */
	def CircuitBreakerStateBuilder openOnFailureCountInTime(int failureCount, long time, TimeUnit unit) {
		if (time < 0) {
			throw new IllegalArgumentException("time must be greater than or equal to 0.")
		}
		if (failureCount < 0) {
			throw new IllegalArgumentException("failureCount must be greater than or equal to 0.")
		}
		val result = this.clone
		result.perTimeFailureCount = failureCount
		result.perTimeInTime = time
		result.perTimeTimeUnit = unit
		result
	}

	/**
	 * If this option is set exceptions instance of the given classes are never regarded for 
	 * calculation if the circuit state should switch to open state. This option can be disabled 
	 * by calling this method with either an empty array or {@code null}.<br>
	 * This option will always regarded, no matter if {@link #onlyRecord(Class[]) onlyRecord(Class...)} 
	 * is set or not (neverRecord has precedence over onlyRecord).
	 * <br><br>
	 * No default values set.
	 * @param classes if not {@code null} then declares the classes of {@code Throwable}s that are never
	 *   regarded as errors and never lead to the state to switch to open mode. No class on the array
	 *   is allowed to be {@code null}. If the array reference itself is {@code null} the option will
	 *   be disabled.
	 * @return new CircuitBreakerStateBuilder with changed option
	 * @throws IllegalArgumentException if any of the given classes is {@code null}
	 */
	def CircuitBreakerStateBuilder neverRecord(Class<? extends Throwable>... classes) throws IllegalArgumentException {
		if (classes !== null) {
			classes.forEach [
				if (it === null) {
					throw new IllegalArgumentException("Null is not allowed as class")
				}
			]
		}
		val result = this.clone
		result.neverRecord = classes
		result
	}

	/**
	 * When this option is set, the default behavior where all exceptions are used to
	 * calculate if the. This option can be disabled by calling this method with either
	 * an empty array or {@code null}.<br>
	 * If an exception is instance of a class set via {@link #neverRecord(Class[]) neverRecord(Class...)}, the
	 * exception will not recorded though (neverRecord has precedence over onlyRecord).
	 * <br><br>
	 * No default values set.
	 * @param classes if not {@code null} then declares the classes of {@code Throwable}s that are the only ones 
	 *   regarded as errors allow the mode to switch to open mode. No other classes will be regarded as errors. 
	 *   No class in the array is allowed to be {@code null}. If the array reference itself is {@code null} 
	 *   the option will be disabled.
	 * @return new CircuitBreakerStateBuilder with changed option
	 * @throws IllegalArgumentException if any of the given classes is {@code null}
	 */
	def CircuitBreakerStateBuilder onlyRecord(Class<? extends Throwable>... classes) {
		Objects.requireNonNull(classes)
		if (classes !== null) {
			classes.forEach [
				if (it === null) {
					throw new IllegalArgumentException("Null is not allowed as class")
				}
			]
		}
		val result = this.clone
		result.onlyRecord = if(classes.length == 0) null else classes
		result
	}

	/**
	 * Defines the strategy to .Must not be called with {@code null}. 
	 * The strategy will be called again to provide
	 * new timeout, if the state switches back from half open to open state. This way the 
	 * time from open to half open can increase when it flips back from half open to open
	 * multiple times. Be aware that timeouts in the CircuitBreakerState implementation
	 * is tracked internally in nanoseconds, so all defined timeouts are limited to 
	 * {@link Long#MAX_VALUE} nanoseconds, no matter if the TimeoutStrategy defines a longer
	 * timeout in a different time unit.
	 * <br><br>
	 * By default uses a fixed timeout of 30 seconds. Be aware that the default may change
	 * and it is advised to always set this option. 
	 * @param toHalfOpenStrategyProvider provider of strategy of timeout, when open circuit 
	 *  should switch to half open state. The same strategy is used until the circuit switches
	 *  back to closed state. Must <em>not</em> be {@code null}.
	 * @return new CircuitBreakerStateBuilder with changed option
	 * @throws NullPointerException if {@code toHalfOpenStrategyProvider} is {@code null}
	 * @see TimeoutStrategies
	 */
	def CircuitBreakerStateBuilder toHalfOpenPeriod(()=>TimeoutStrategy toHalfOpenStrategyProvider) {
		Objects.requireNonNull(toHalfOpenStrategyProvider)
		val result = this.clone
		result.toHalfOpenStrategyProvider = toHalfOpenStrategyProvider
		result
	}

	/**
	 * Sets the executor that will be used to run the calls to the listener ({@link #listener(CircuitBreakerStateSwitchListener)}
	 * by the created CircuitBreaker builder. 
	 * If called with {@code listenerExecutor = null} option will be 
	 * reset to its default value. If the executor rejects the action to call the listener with a
	 * {@link RejectedExecutionException} the notification to the listener will be lost.<br>
	 * By default the listeners will be run on the {@link ForkJoinPool#commonPool() common ForkJoinPool}.
	 * @param listenerExecutor executor used to invoke the calls to listener. Can be {@code null}, in this
	 *  case the default executor will be selected.
	 * @return new CircuitBreakerStateBuilder with changed option
	 * @see #listener(CircuitBreakerStateSwitchListener)
	 */
	def CircuitBreakerStateBuilder listenerExecutor(Executor listenerExecutor) {
		val result = this.clone
		result.listenerExecutor = if(listenerExecutor === null) ForkJoinPool.commonPool else listenerExecutor
		result
	}

	/**
	 * Only a single listener is supported, so calling this method again will
	 * overwrite the previously set listener. If multiple listeners are desired,
	 * the user has to implement a compound listener himself/herself.<br><br>
	 * By default no listener is configured. To reset this option, call with {@code listener = null}.
	 * @param listener Will be called whenever the internal state of the circuit breaker changes.
	 *    Can be {@code null}, in this case the listener will be disabled.
	 * @return new CircuitBreakerStateBuilder with changed option
	 * @see #listener(CircuitBreakerStateSwitchListener)
	 */
	def CircuitBreakerStateBuilder listener(CircuitBreakerStateSwitchListener listener) {
		val result = this.clone
		result.listener = listener
		result
	}

	/**
	 * Creates an instance of {@link CircuitBreakerState} based on the
	 * configuration of this builder.
	 * @return new instance of {@link CircuitBreakerState} according to the 
	 *   configuration of this builder.
	 */
	def CircuitBreakerState build() {
		val conf = this.clone
		if (conf.name === null) {
			conf.name = UUID.randomUUID.toString
		}
		new SimpleCircuitBreakerState(conf)
	}

	override protected CircuitBreakerStateBuilder clone() throws CloneNotSupportedException {
		super.clone as CircuitBreakerStateBuilder
	}

}

/**
 * Can be registered on {@link SimpleCircuitBreakerStateBuilder} and possibly other
 * implementations of CircuitBreaker. An implementation of this interface can be 
 * registered to be notified about internal changes of a CircuitBreaker instance.
 * This can e.g. be used for logging purposes.
 */
interface CircuitBreakerStateSwitchListener {

	/**
	 * Will be called on switch to open state, if registered on CircuitBreakerState (by setting on
	 * {@link CircuitBreakerBuilder} and building an instance).
	 * @param circuitBreakerState name of circuit breaker state calling this listener
	 * @param successfulCircuitBreaker name of circuit breaker reporting the error causing the state to
	 *   switch to open mode
	 */
	def void onOpen(String circuitBreakerState, String successfulCircuitBreaker)

	/**
	 * Will be called on switch to closed state, if registered on CircuitBreakerState (by setting on
	 * {@link CircuitBreakerBuilder} and building an instance).
	 * @param circuitBreakerState name of circuit breaker state calling this listener
	 * @param successfulCircuitBreaker name of circuit breaker reporting success that 
	 *   causes switch to closed mode
	 */
	def void onClose(String circuitBreakerState, String unsuccessfulCircuitBreaker)

	/**
	 * Will be called on switch to half closed state, if registered on CircuitBreakerState (by setting on
	 * {@link CircuitBreakerBuilder} and building an instance).
	 * @param circuitBreakerState name of circuit breaker state calling this listener
	 * @param successfulCircuitBreaker name of circuit breaker causing switch to half-open mode
	 *   by asking if a call is possible.
	 */
	def void onHalfOpen(String circuitBreakerState, String successfulCircuitBreaker)
}

/**
 * Implementation of CircuitBreakerState created by {@link CircuitBreakerStateBuilder}.
 */
package final class SimpleCircuitBreakerState implements CircuitBreakerState {

	extension val CircuitBreakerStateBuilder config
	val AtomicReference<State> state

	new(CircuitBreakerStateBuilder config) {
		this.config = config
		val initialState = newClosedState()
		state = new AtomicReference(initialState);
	}

	private def newClosedState() {
		val rateChecker = createErrorRateChecker()
		val perTimeChecker = createPerTimeChecker()
		val subsequentChecker = createSubsequentChecker()
		val checkers = filterNull(rateChecker, perTimeChecker, subsequentChecker)
		new ClosedState(checkers)
	}

	private static def ErrorStatisticsChecker[] filterNull(ErrorStatisticsChecker... checkers) {
		var count = checkers.moveNullToEnd
		var result = newArrayOfSize(count)
		System.arraycopy(checkers, 0, result, 0, count)
		result
	}

	private static def moveNullToEnd(ErrorStatisticsChecker[] from) {
		var curr = 0
		for (var i = 0; i < from.length; i++) {
			val el = from.get(i)
			if (el !== null) {
				from.set(curr, el)
				curr++
			}
		}
		curr
	}

	private def ErrorPerTimeChecker createPerTimeChecker() {
		if (perTimeInTime == 0 || perTimeTimeUnit === null) {
			null
		} else {
			val nanoTime = perTimeTimeUnit.toNanos(perTimeInTime)
			// else
			new ErrorPerTimeChecker(perTimeFailureCount, nanoTime, timeSupplier)
		}
	}

	private def ErrorRateChecker createErrorRateChecker() {
		if (rateFailureCount < 0 || rateTotalCount <= 0)
			null
		else
			new ErrorRateChecker(rateTotalCount, rateFailureCount)

	}

	private def ErrorSequnceChecker createSubsequentChecker() {
		if (subsequentFailureCount <= 0)
			null
		else
			new ErrorSequnceChecker(subsequentFailureCount)
	}

	override isCallPossible(String cbName) {
		val state = checkStateChangeAndGetState(cbName)
		state.isCallPossible
	}

	private def checkStateChangeAndGetState(String cbName) {
		var state = this.state.get
		if (state instanceof OpenState) {
			switchToHalfOpenIfTimeoutReached(state, cbName)
		} else {
			state
		}
	}

	private def State switchToHalfOpenIfTimeoutReached(OpenState openState, String cbName) {
		var oldState = openState
		val currTime = try {
			timeSupplier.asLong
		} catch (Throwable t) {
			// fall back to system time
			System.nanoTime
		}
		while (true) {
			// target time not reached?
			if (currTime < oldState.targetTime) {
				return oldState
			}
			// target time reached, try to switch to half open
			val newState = new HalfOpenState(oldState.toHalfOpenTimeoutStrategy, oldState.lastTimeout,
				oldState.lastTimeoutUnit)
			if (this.state.compareAndSet(oldState, newState)) {
				// we were able to switch to half open
				notifyOnHalfOpen(cbName)
				return newState
			} else {
				// switch did not work, check updated state
				var updatedState = this.state.get
				if (updatedState instanceof OpenState) {
					// we have an open state again, so lets check again in next iteration
					oldState = updatedState
				} else {
					// updated state is no longer open, return new state
					return updatedState
				}
			}
		}
	}

	override successfulCall(String cbName) {
		// based on internal state
		var state = this.state.get
		switch (state) {
			ClosedState:
				onClosedNotifySuccessfulCall(state)
			HalfOpenState:
				onHalfOpenNotifySuccessfulCall(state, cbName)
			OpenState: { /* ignore, delayed operation finish has no influence on open state */
			}
		}
	}

	private def onHalfOpenNotifySuccessfulCall(HalfOpenState oldState, String cbName) {
		// switch to closed state if operation is successful in half open state
		val newState = newClosedState
		// if state changed in the meantime, ignore our state change
		if (state.compareAndSet(oldState, newState)) {
			// inform listener about state change
			notifyOnClose(cbName)
		}
	}

	private def onClosedNotifySuccessfulCall(ClosedState info) {
		val checkers = info.checkers
		for (var i = 0; i < checkers.length; i++) {
			checkers.get(i).addSuccess
		}
	}

	override exceptionalCall(Throwable ex, String cbName) {
		// based on internal state
		var state = this.state.get
		switch (state) {
			ClosedState:
				onClosedStateNotifyError(state, ex, cbName)
			HalfOpenState:
				onHalfOpenNotifyError(state, ex, cbName)
			OpenState: { /* additional results are simply ignored in open state */
			}
		}
	}

	private def onClosedStateNotifyError(ClosedState state, Throwable throwable, String cbName) {
		// if exception is not recordable we forget about it
		if (!throwable.isRecordable) {
			return
		}
		// test if checkers trip the state to switch to open state
		val checkers = state.checkers
		var trip = false
		for (var i = 0; i < checkers.length && !trip; i++) {
			trip = trip || !checkers.get(i).addErrorAndCheck
		}
		if (trip) {
			switchToOpenState(cbName)
		}
	}

	private def <U> U recoverWith(()=>U action, ()=>U recovery) {
		try {
			val U result = action.apply
			if(result !== null) result else recovery.apply
		} catch (Throwable t) {
			recovery.apply
		}
	}

	/**
	 * Always switches to open state (no matter the previous state)
	 */
	private def switchToOpenState(String cbName) {
		val toHalfOpenStrategy = toHalfOpenStrategyProvider.recoverWith(
			CircuitBreakerStateBuilder.DEFAULT_HALF_OPEN_TIME)
		switchToOpenState(cbName, toHalfOpenStrategy, 0, TimeUnit.NANOSECONDS)
	}

	/**
	 * Always switches to open state (no matter the previous state)
	 */
	private def switchToOpenState(String cbName, TimeoutStrategy toHalfOpenStrategy, long lastTimeout,
		TimeUnit lastTimeoutUnit) {
		try {
			switchToOpenState(toHalfOpenStrategy, cbName, lastTimeout, lastTimeoutUnit)
		} catch (Throwable t) {
			// if there is an error, lets try with the default strategy
			// we don't trust the user provided one for now
			val defaultTimeout = CircuitBreakerStateBuilder.DEFAULT_HALF_OPEN_TIME.apply
			switchToOpenState(defaultTimeout, cbName, lastTimeout, lastTimeoutUnit)
		}
	}

	/**
	 * Always switches to open state (no matter the previous state)
	 */
	private def void switchToOpenState(TimeoutStrategy toHalfOpenStrategy, String cbName, long lastTimeout,
		TimeUnit lastTimeoutUnit) {
		// calculate time when to switch to half open
		toHalfOpenStrategy.next(lastTimeout, lastTimeoutUnit) [ time, unit |
			val currTime = try {
				timeSupplier.asLong
			} catch (Throwable t) {
				// fall back to system time
				System.nanoTime
			}
			val targetTime = currTime + unit.toNanos(time)
			// set state
			val newState = new OpenState(toHalfOpenStrategy, targetTime, time, unit)
			state.set(newState)
			notifyOnOpen(cbName)
		]
	}

	private def onHalfOpenNotifyError(HalfOpenState state, Throwable throwable, String cbName) {
		// if exception is not recordable we forget about it
		if (!throwable.isRecordable) {
			return
		}
		switchToOpenState(cbName, state.toHalfOpenTimeoutStrategy, state.lastTimeout, state.lastTimeoutUnit)
	}

	private def boolean isRecordable(Throwable t) {
		// since neverRecord trumps onlyRecord we check this first
		if (neverRecord !== null) {
			for (var i = 0; i < neverRecord.length; i++) {
				if (neverRecord.get(i).isInstance(t)) {
					return false
				}
			}
		}
		// now check if only certain exception types are recorded
		if (onlyRecord !== null) {
			for (var i = 0; i < onlyRecord.length; i++) {
				if (onlyRecord.get(i).isInstance(t)) {
					return true
				}
			}
			// if the error is not explicitly recordable, it is not
			return false
		}
		// if there is no limit, the error is recordable
		true
	}

	// Helper methods to invoke listener
	private def void notifyOnOpen(String cbName) {
		if (listener !== null) {
			try {
				listenerExecutor.execute [
					listener.onOpen(name, cbName)
				]
			} catch (RejectedExecutionException t) {
				/* Well, that notification is lost ... sorry */
			}
		}
	}

	private def void notifyOnClose(String cbName) {
		if (listener !== null) {
			try {
				listenerExecutor.execute [
					listener.onClose(name, cbName)
				]
			} catch (RejectedExecutionException t) {
				/* Well, that notification is lost ... sorry */
			}
		}
	}

	private def void notifyOnHalfOpen(String cbName) {
		if (listener !== null) {
			try {
				listenerExecutor.execute [
					listener.onHalfOpen(name, cbName)
				]
			} catch (RejectedExecutionException t) {
				/* Well, that notification is lost ... sorry */
			}
		}
	}
}

/**
 * Superclass of classes representing the internal state.
 * The state determines if calls can be performed or not.
 */
package interface State {

	/**
	 * Checks if call can be performed in the current state.
	 */
	def boolean isCallPossible()
}

package final class OpenState implements State {

	public val TimeoutStrategy toHalfOpenTimeoutStrategy;
	public val long targetTime
	public val long lastTimeout
	public val TimeUnit lastTimeoutUnit

	new(TimeoutStrategy strategy, long targetTime, long lastTimout, TimeUnit lastTimeoutUnit) {
		this.toHalfOpenTimeoutStrategy = strategy
		this.targetTime = targetTime
		this.lastTimeout = lastTimout
		this.lastTimeoutUnit = lastTimeoutUnit
	}

	override isCallPossible() {
		false
	}

}

package final class ClosedState implements State {

	public val ErrorStatisticsChecker[] checkers;

	new(ErrorStatisticsChecker[] checkers) {
		this.checkers = checkers
	}

	override isCallPossible() {
		true
	}

}

package final class HalfOpenState implements State {

	public val TimeoutStrategy toHalfOpenTimeoutStrategy;
	public val long lastTimeout
	public val TimeUnit lastTimeoutUnit

	new(TimeoutStrategy strategy, long lastTimeout, TimeUnit lastTimeoutUnit) {
		this.toHalfOpenTimeoutStrategy = strategy
		this.lastTimeout = lastTimeout
		this.lastTimeoutUnit = lastTimeoutUnit
	}

	override isCallPossible() {
		true
	}

}
