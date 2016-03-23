package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.TimeoutStrategy;
import java.util.concurrent.TimeUnit;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@Data
@SuppressWarnings("all")
class Repeat {
  private final long timeout;
  
  private final TimeUnit timeUnit;
  
  public boolean doRepeat() {
    return (this.timeout >= 0);
  }
  
  public void ifRepeat(final TimeoutStrategy.TimeConsumer func) {
    boolean _doRepeat = this.doRepeat();
    if (_doRepeat) {
      func.accept(this.timeout, this.timeUnit);
    }
  }
  
  public static Repeat NO_REPEAT = new Repeat((-1), null);
  
  public static Repeat REPEAT_WITHOUT_TIMEOUT = new Repeat(0, null);
  
  public static Repeat operator_mappedTo(final long time, final TimeUnit unit) {
    return new Repeat(time, unit);
  }
  
  public static Repeat NANOSECONDS(final long time) {
    return new Repeat(time, TimeUnit.NANOSECONDS);
  }
  
  public static Repeat MILLISECONDS(final long time) {
    return new Repeat(time, TimeUnit.MILLISECONDS);
  }
  
  public static Repeat SECONDS(final long time) {
    return new Repeat(time, TimeUnit.SECONDS);
  }
  
  public static Repeat MINUTES(final long time) {
    return new Repeat(time, TimeUnit.MINUTES);
  }
  
  public static Repeat HOURS(final long time) {
    return new Repeat(time, TimeUnit.HOURS);
  }
  
  public static Repeat DAYS(final long time) {
    return new Repeat(time, TimeUnit.DAYS);
  }
  
  public Repeat(final long timeout, final TimeUnit timeUnit) {
    super();
    this.timeout = timeout;
    this.timeUnit = timeUnit;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + (int) (this.timeout ^ (this.timeout >>> 32));
    result = prime * result + ((this.timeUnit== null) ? 0 : this.timeUnit.hashCode());
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
    Repeat other = (Repeat) obj;
    if (other.timeout != this.timeout)
      return false;
    if (this.timeUnit == null) {
      if (other.timeUnit != null)
        return false;
    } else if (!this.timeUnit.equals(other.timeUnit))
      return false;
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("timeout", this.timeout);
    b.add("timeUnit", this.timeUnit);
    return b.toString();
  }
  
  @Pure
  public long getTimeout() {
    return this.timeout;
  }
  
  @Pure
  public TimeUnit getTimeUnit() {
    return this.timeUnit;
  }
}
