package de.fhg.fokus.xtenders.concurrent.internal;

import java.time.Duration;
import java.util.concurrent.TimeUnit;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

/**
 * Conversion cause loss in time precision, if the converted duration exceeds Long.MAX_VALUE nanoseconds,
 * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one
 * second) may be stripped.
 */
@SuppressWarnings("all")
public class DurationToTimeConversion {
  /**
   * Holder class for an {@code amount} of time and its
   * time {@code unit}.
   */
  @Data
  public static class Time {
    public final long amount;
    
    public final TimeUnit unit;
    
    public Time(final long amount, final TimeUnit unit) {
      super();
      this.amount = amount;
      this.unit = unit;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + (int) (this.amount ^ (this.amount >>> 32));
      result = prime * result + ((this.unit== null) ? 0 : this.unit.hashCode());
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
      DurationToTimeConversion.Time other = (DurationToTimeConversion.Time) obj;
      if (other.amount != this.amount)
        return false;
      if (this.unit == null) {
        if (other.unit != null)
          return false;
      } else if (!this.unit.equals(other.unit))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("amount", this.amount);
      b.add("unit", this.unit);
      return b.toString();
    }
    
    @Pure
    public long getAmount() {
      return this.amount;
    }
    
    @Pure
    public TimeUnit getUnit() {
      return this.unit;
    }
  }
  
  /**
   * Shortcut for constructor of {@link Time}.
   */
  private static DurationToTimeConversion.Time operator_mappedTo(final long time, final TimeUnit unit) {
    return new DurationToTimeConversion.Time(time, unit);
  }
  
  /**
   * Possibly lossy conversion
   */
  public static DurationToTimeConversion.Time toTime(final Duration duration) {
    final long seconds = duration.getSeconds();
    final int nanos = duration.getNano();
    if ((seconds == 0)) {
      return DurationToTimeConversion.operator_mappedTo(((long) nanos), TimeUnit.NANOSECONDS);
    }
    if ((nanos == 0)) {
      return DurationToTimeConversion.operator_mappedTo(seconds, TimeUnit.SECONDS);
    }
    final long secondsInNanos = (seconds * 1_000_000_000);
    if ((secondsInNanos > seconds)) {
      final long overallNanos = (secondsInNanos + nanos);
      if (((overallNanos > secondsInNanos) && (overallNanos > nanos))) {
        return DurationToTimeConversion.operator_mappedTo(overallNanos, TimeUnit.NANOSECONDS);
      }
    }
    final long secondsInMillis = (seconds * 1_000);
    if ((secondsInMillis < seconds)) {
      return DurationToTimeConversion.operator_mappedTo(seconds, TimeUnit.SECONDS);
    }
    final int nanosInMillis = (nanos / 1_000_000);
    final long milliSum = (secondsInMillis + nanosInMillis);
    DurationToTimeConversion.Time _xifexpression = null;
    if ((milliSum < secondsInMillis)) {
      _xifexpression = DurationToTimeConversion.operator_mappedTo(
        Long.MAX_VALUE, TimeUnit.MILLISECONDS);
    } else {
      _xifexpression = DurationToTimeConversion.operator_mappedTo(milliSum, TimeUnit.MILLISECONDS);
    }
    return _xifexpression;
  }
}
