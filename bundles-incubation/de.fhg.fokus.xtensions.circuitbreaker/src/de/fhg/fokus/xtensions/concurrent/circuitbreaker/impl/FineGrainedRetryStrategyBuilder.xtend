package de.fhg.fokus.xtensions.concurrent.circuitbreaker.impl

import java.util.concurrent.TimeUnit
import org.eclipse.xtend.lib.annotations.Data
import static java.util.concurrent.TimeUnit.*
import com.google.common.annotations.Beta
import de.fhg.fokus.xtensions.concurrent.circuitbreaker.RetryStrategy
import de.fhg.fokus.xtensions.concurrent.circuitbreaker.TimeoutStrategy.TimeConsumer

@Beta
package class FineGrainedRetryStrategyBuilder {

	private new() {
	}

	static def FineGrainedRetryStrategyBuilder create() {
		new FineGrainedRetryStrategyBuilder
	}
	
	
	// TODO def retryScheduler(ScheduledExecutorService breakerExecutor)
	// TODO def enforceTimeoutAsDelay(boolean toggle), 
	// TODO def maxRetries(int retries)
	
	def FineGrainedRetryStrategyBuilder firstTimeout(long time, TimeUnit timeUnit) {
		// TODO implement
		this
	}
	
	def FineGrainedRetryStrategyBuilder repeatLogic((Throwable)=>Repeat mapper) {
		// TODO implement
		this
	}

	def RetryStrategy build() {
		// TODO implement
		throw new UnsupportedOperationException("not implemented yet")
	}
}

// TODO make public when finished
@Data
package class Repeat {
	val long timeout;
	val TimeUnit timeUnit;

	def boolean doRepeat() {
		return timeout >= 0;
	}

	def void ifRepeat(TimeConsumer func) {
		if (doRepeat) {
			func.accept(timeout, timeUnit)
		}
	}

	public static Repeat NO_REPEAT = new Repeat(-1, null)

	public static Repeat REPEAT_WITHOUT_TIMEOUT = new Repeat(0, null)

	static def ->(long time, TimeUnit unit) {
		new Repeat(time, unit)
	}

	static def Repeat NANOSECONDS(long time) {
		new Repeat(time, NANOSECONDS)
	}

	static def Repeat MILLISECONDS(long time) {
		new Repeat(time, MILLISECONDS)
	}

	static def Repeat SECONDS(long time) {
		new Repeat(time, SECONDS)
	}

	static def Repeat MINUTES(long time) {
		new Repeat(time, MINUTES)
	}

	static def Repeat HOURS(long time) {
		new Repeat(time, HOURS)
	}

	static def Repeat DAYS(long time) {
		new Repeat(time, DAYS)
	}
}
