package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.ErrorStatisticsChecker;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * This checker allows only a maximum number of consecutive errors
 * to occur.
 */
@SuppressWarnings("all")
class ErrorSequnceChecker implements ErrorStatisticsChecker {
  private final AtomicInteger subsequentErrorCount = new AtomicInteger(0);
  
  private final int failCount;
  
  /**
   * @param failCount number of subsequent errors that is not allowed to occur. Must be {@code >0}
   * @throws IllegalArgumentException if {@code failCount <= 0}
   */
  public ErrorSequnceChecker(final int failCount) throws IllegalArgumentException {
    if ((failCount <= 0)) {
      throw new IllegalArgumentException("Maximum number of consecutive errors must be greater 0.");
    }
    this.failCount = failCount;
  }
  
  @Override
  public boolean addErrorAndCheck() {
    int _incrementAndGet = this.subsequentErrorCount.incrementAndGet();
    return (_incrementAndGet < this.failCount);
  }
  
  @Override
  public void addSuccess() {
    this.subsequentErrorCount.set(0);
  }
}
