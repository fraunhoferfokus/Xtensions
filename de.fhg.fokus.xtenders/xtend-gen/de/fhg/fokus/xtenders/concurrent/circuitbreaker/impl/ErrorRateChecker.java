package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.ErrorRateStatistics;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.ErrorStatisticsChecker;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Statistics checking if the last N operation do not exceed a given
 * threshold of error count.
 */
@SuppressWarnings("all")
class ErrorRateChecker implements ErrorStatisticsChecker {
  private final AtomicReference<ErrorRateStatistics> statistics;
  
  private final int maxErrorCount;
  
  /**
   * Creates an ErrorRateChecker that checks if there is a maximum of {@code maxErrorCount}
   * in the last {@code size} results.
   * @param size sample size used to check error count. must be &gt; 0.
   * @param maxErrorCount maximum amount of errors that can occur in the amount of {@code size}
   *          results. must be &gt;=0
   * @throws IllegalArgumentException if any precondition on the arguments is not respected.
   */
  public ErrorRateChecker(final int size, final int maxErrorCount) {
    if ((size <= 0)) {
      throw new IllegalArgumentException("Size must be greater than 0.");
    }
    if ((maxErrorCount < 0)) {
      throw new IllegalArgumentException("Maximum error count must be equal to or greater than 0.");
    }
    ErrorRateStatistics _errorRateStatistics = new ErrorRateStatistics(size);
    AtomicReference<ErrorRateStatistics> _atomicReference = new AtomicReference<ErrorRateStatistics>(_errorRateStatistics);
    this.statistics = _atomicReference;
    this.maxErrorCount = maxErrorCount;
  }
  
  /**
   * Returns {@code false} if the maximum amount of errors is reached within
   * the last N elements. Otherwise returns {@code true}
   */
  @Override
  public boolean addErrorAndCheck() {
    while (true) {
      {
        final ErrorRateStatistics stat = this.statistics.get();
        final ErrorRateStatistics newStat = stat.addError();
        boolean _compareAndSet = this.statistics.compareAndSet(stat, newStat);
        if (_compareAndSet) {
          int _errors = newStat.errors();
          return (_errors <= this.maxErrorCount);
        }
      }
    }
  }
  
  @Override
  public void addSuccess() {
    while (true) {
      {
        final ErrorRateStatistics currStat = this.statistics.get();
        final ErrorRateStatistics newStat = currStat.addSuccess();
        boolean _compareAndSet = this.statistics.compareAndSet(currStat, newStat);
        if (_compareAndSet) {
          return;
        }
      }
    }
  }
}
