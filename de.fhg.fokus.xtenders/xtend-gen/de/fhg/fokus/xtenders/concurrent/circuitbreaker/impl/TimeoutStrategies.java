package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.TimeoutStrategy;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

/**
 * Default builder for instances of {@link BackoffStrategy}.
 */
@SuppressWarnings("all")
public final class TimeoutStrategies {
  private TimeoutStrategies() {
  }
  
  /**
   * Creates new TimeoutStrategy that always returns the same timeout of the
   * given time and the given time unit.
   * 
   * @param time amount of time of time unit {@code unit} that is always provided
   *   by the returned TimeoutStrategy. Must be {@code >=0}
   * @param unit time unit of the given {@code time} that will always be provided
   *   by the returned TimeoutStrategy. Must not be {@code null}
   * @return TimeoutStrategy always returning the same timeout of the given
   *   {@code time} and {@code unit}
   * @throws IllegalArgumentException if any of the parameter constraints are not regarded.
   */
  public static TimeoutStrategy fixedTimeout(final long time, final TimeUnit unit) {
    TimeoutStrategy _xblockexpression = null;
    {
      if ((time < 0)) {
        throw new IllegalArgumentException("Timeout time must be greater or equal to 0.");
      }
      Objects.<TimeUnit>requireNonNull(unit, "Timeout TimeUnit must not be null.");
      final TimeoutStrategy _function = new TimeoutStrategy() {
        @Override
        public <T extends Object> T next(final long oldTime, final TimeUnit oldUnit, final TimeoutStrategy.TimeFactory<T> mapper) {
          return mapper.apply(time, unit);
        }
      };
      _xblockexpression = _function;
    }
    return _xblockexpression;
  }
  
  /**
   * Returns a TimeoutStrategy that when called returns the last time amount multiplied
   * with the given {@code factor}. If the result of the multiplication exceeds the given
   * {@code maxTimeoutTime} of {@code unit}, then the timeout will be limited to {@code maxTimeoutTime}.
   * When the strategy is called initially (with {@code previousTimeout} 0), then the given
   * {@code startTimoutTime} and {@code unit}
   * will be returned as timeout time.
   * @param startTimoutTime initial timeout returned by the TimeoutStrategy when called with
   *    {@code previousTimeout = 0}. Must be {@code > 0}
   * @param unit time unit of {@code startTimoutTime} and {@code maxTimoutTime}. Must not be {@code null}.
   * @param maxTimoutTime maximum timeout provided by the returned TimeoutStrategy. Must be {@code >= startTimoutTime}.
   * @param factor used to multiply must be {@code >= 1}.
   * @return TimeoutStrategy that backs off exponentially according to {@code factor},
   *    starting with {@code startTimoutTime}.
   * @throws IllegalArgumentException if any of the parameter constraints are not regarded.
   */
  public static TimeoutStrategy exponentialBackoff(final long startTimoutTime, final TimeUnit unit, final long maxTimoutTime, final double factor) {
    TimeoutStrategy _xblockexpression = null;
    {
      if ((factor < 1.0d)) {
        throw new IllegalArgumentException("Factor must be greater than, or equal to 1.0.");
      }
      if ((startTimoutTime <= 0)) {
        throw new IllegalArgumentException("Starting timeout time must be greater than 0.");
      }
      if ((maxTimoutTime < startTimoutTime)) {
        throw new IllegalArgumentException("Maximum timeout time must be greater than or equal to the starting timeout time.");
      }
      Objects.<TimeUnit>requireNonNull(unit, "Timeout TimeUnit must not be null.");
      final TimeoutStrategy _function = new TimeoutStrategy() {
        @Override
        public <T extends Object> T next(final long oldTime, final TimeUnit oldUnit, final TimeoutStrategy.TimeFactory<T> mapper) {
          T _xblockexpression = null;
          {
            long _xifexpression = (long) 0;
            if ((oldTime == 0)) {
              _xifexpression = startTimoutTime;
            } else {
              long _xblockexpression_1 = (long) 0;
              {
                final long increased = ((long) (oldTime * factor));
                long _xifexpression_1 = (long) 0;
                if ((increased > oldTime)) {
                  _xifexpression_1 = increased;
                } else {
                  _xifexpression_1 = maxTimoutTime;
                }
                _xblockexpression_1 = _xifexpression_1;
              }
              _xifexpression = _xblockexpression_1;
            }
            final long newTimeout = _xifexpression;
            final long limitedTimeout = Math.min(maxTimoutTime, newTimeout);
            _xblockexpression = mapper.apply(limitedTimeout, unit);
          }
          return _xblockexpression;
        }
      };
      _xblockexpression = _function;
    }
    return _xblockexpression;
  }
}
