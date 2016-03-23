package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import com.google.common.base.Objects;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.ErrorStatisticsChecker;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.LongSupplier;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

/**
 * This checker tests if the error count in certain time intervals stays
 * under a certain threshold. The checker uses fixed time intervals, and is
 * not starting a new interval whenever a new message is coming in (which
 * would need management of multiple time-slices).
 */
@SuppressWarnings("all")
class ErrorPerTimeChecker implements ErrorStatisticsChecker {
  /**
   * Holds the state when the last time-slot boundary was crossed
   * and how many errors occurred in the current time-slot.
   */
  @Data
  public static class ErrorState {
    private final long lastReset;
    
    private final long errorCount;
    
    public ErrorState(final long lastReset, final long errorCount) {
      super();
      this.lastReset = lastReset;
      this.errorCount = errorCount;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + (int) (this.lastReset ^ (this.lastReset >>> 32));
      result = prime * result + (int) (this.errorCount ^ (this.errorCount >>> 32));
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      ErrorPerTimeChecker.ErrorState other = (ErrorPerTimeChecker.ErrorState) obj;
      if (other.lastReset != this.lastReset)
        return false;
      if (other.errorCount != this.errorCount)
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("lastReset", this.lastReset);
      b.add("errorCount", this.errorCount);
      return b.toString();
    }
    
    @Pure
    public long getLastReset() {
      return this.lastReset;
    }
    
    @Pure
    public long getErrorCount() {
      return this.errorCount;
    }
  }
  
  private final LongSupplier timeSupplier;
  
  private final long maxCount;
  
  private final long nanoResetInterval;
  
  private final AtomicReference<ErrorPerTimeChecker.ErrorState> state;
  
  /**
   * Creates a new ErrorPerTimeChecker that checks if a maximum number
   * of {@code maxCount} errors occur in intervals of {@code nanoResetInterval}
   * starting from the current time provided by {@code timeSuplier}. The
   * {@code timeSuplier} is also used to check the time on arrival of error messages,
   * reported via {@link #addErrorAndCheck()}.
   * @param maxCount maximum amount of errors allowed in one time slice of size {@code nanoResetInterval}.
   *   Must be {@code <= 0}.
   * @param nanoResetInterval size of time slice in which errors are counted. Must be {@code < 0}.
   * @param timeSupplier provides the current system time in nanoseconds. Must not be {@code null}.
   * @throws IllegalArgumentException if any of the parameter preconditions are not respected.
   */
  ErrorPerTimeChecker(final long maxCount, final long nanoResetInterval, final LongSupplier timeSupplier) throws IllegalArgumentException {
    if ((maxCount < 0)) {
      throw new IllegalArgumentException("Maximum number of errors per time must at least be 0.");
    }
    if ((nanoResetInterval <= 0)) {
      throw new IllegalArgumentException(
        "Time interval in which errors are counted must be greater than 0 nanoseconds.");
    }
    boolean _equals = Objects.equal(timeSupplier, null);
    if (_equals) {
      throw new IllegalArgumentException("System time supplier must not be null.");
    }
    this.maxCount = maxCount;
    this.nanoResetInterval = nanoResetInterval;
    this.timeSupplier = timeSupplier;
    long _asLong = timeSupplier.getAsLong();
    ErrorPerTimeChecker.ErrorState _errorState = new ErrorPerTimeChecker.ErrorState(_asLong, 0);
    AtomicReference<ErrorPerTimeChecker.ErrorState> _atomicReference = new AtomicReference<ErrorPerTimeChecker.ErrorState>(_errorState);
    this.state = _atomicReference;
  }
  
  /**
   * Adds error and checks if the maximum number of errors is reached
   * in the current time-slice.
   */
  @Override
  public boolean addErrorAndCheck() {
    boolean _xblockexpression = false;
    {
      boolean finished = false;
      while ((!finished)) {
        {
          final long currTime = this.timeSupplier.getAsLong();
          final ErrorPerTimeChecker.ErrorState currState = this.state.get();
          final long lastReset = currState.lastReset;
          final long diff = (currTime - lastReset);
          if ((diff > this.nanoResetInterval)) {
            final long newResetTime = ((lastReset + diff) - (diff % this.nanoResetInterval));
            final int newErrorCount = 1;
            final ErrorPerTimeChecker.ErrorState newState = new ErrorPerTimeChecker.ErrorState(newResetTime, newErrorCount);
            boolean _compareAndSet = this.state.compareAndSet(currState, newState);
            finished = _compareAndSet;
          } else {
            final long currErrorCount = currState.errorCount;
            if ((currErrorCount == this.maxCount)) {
              return false;
            }
            final long newErrorCount_1 = (currErrorCount + 1);
            final ErrorPerTimeChecker.ErrorState newState_1 = new ErrorPerTimeChecker.ErrorState(currState.lastReset, newErrorCount_1);
            boolean _compareAndSet_1 = this.state.compareAndSet(currState, newState_1);
            finished = _compareAndSet_1;
          }
        }
      }
      _xblockexpression = true;
    }
    return _xblockexpression;
  }
  
  @Override
  public void addSuccess() {
  }
}
