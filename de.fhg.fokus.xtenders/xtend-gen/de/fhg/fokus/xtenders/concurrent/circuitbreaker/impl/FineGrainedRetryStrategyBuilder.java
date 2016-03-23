package de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl;

import com.google.common.annotations.Beta;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.RetryStrategy;
import de.fhg.fokus.xtenders.concurrent.circuitbreaker.impl.Repeat;
import java.util.concurrent.TimeUnit;
import org.eclipse.xtext.xbase.lib.Functions.Function1;

@Beta
@SuppressWarnings("all")
class FineGrainedRetryStrategyBuilder {
  private FineGrainedRetryStrategyBuilder() {
  }
  
  public static FineGrainedRetryStrategyBuilder create() {
    return new FineGrainedRetryStrategyBuilder();
  }
  
  public FineGrainedRetryStrategyBuilder firstTimeout(final long time, final TimeUnit timeUnit) {
    return this;
  }
  
  public FineGrainedRetryStrategyBuilder repeatLogic(final Function1<? super Throwable, ? extends Repeat> mapper) {
    return this;
  }
  
  public RetryStrategy build() {
    throw new UnsupportedOperationException("not implemented yet");
  }
}
