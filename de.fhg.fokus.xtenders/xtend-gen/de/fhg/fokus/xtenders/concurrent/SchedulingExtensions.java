package de.fhg.fokus.xtenders.concurrent;

import de.fhg.fokus.xtenders.concurrent.internal.DurationToTimeConversion;
import java.time.Duration;
import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Delayed;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.function.BiConsumer;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

/**
 * This class provides static functions that can be used to schedule tasks that
 * are either repeated or delayed by a given amount of time.
 */
@SuppressWarnings("all")
public class SchedulingExtensions {
  /**
   * This class implements both {@link CompletableFuture} and {@link ScheduledFuture},
   * so it can be used in a non-blocking fashion, but still be asked for the delay for
   * the next execution of a scheduled task.<br>
   * This class is not intended to be sub-classed outside of the SchdulingExtensions.
   */
  public static abstract class ScheduledCompletableFuture<T extends Object> extends CompletableFuture<T> implements ScheduledFuture<T> {
    ScheduledCompletableFuture() {
    }
  }
  
  /**
   * Adds delay information to an action to be scheduled. When the {@link DelaySpecifier#withInitialDelay(long, Procedure0)}
   * method is called the scheduling will be started, by scheduling the given action according to the scheduling
   * information given to the function producing the DelaySpecifier and the given delay passed to withInitialDelay.<br>
   * This class is not intended to be sub-classed outside of the SchdulingExtensions.
   */
  public static abstract class DelaySpecifier {
    private DelaySpecifier() {
    }
    
    public abstract SchedulingExtensions.ScheduledCompletableFuture<?> withInitialDelay(final long initialDelay, final Procedure1<? super CompletableFuture<?>> action);
  }
  
  private SchedulingExtensions() {
  }
  
  /**
   * May cause loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds,
   * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one
   * second) may be stripped.
   */
  public static SchedulingExtensions.ScheduledCompletableFuture<?> repeatEvery(final Duration duration, final Procedure1<? super CompletableFuture<?>> action) {
    SchedulingExtensions.ScheduledCompletableFuture<?> _xblockexpression = null;
    {
      final DurationToTimeConversion.Time time = DurationToTimeConversion.toTime(duration);
      _xblockexpression = SchedulingExtensions.repeatEvery(time.amount, time.unit, action);
    }
    return _xblockexpression;
  }
  
  /**
   * May cause loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds,
   * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one
   * second) may be stripped.
   */
  public static SchedulingExtensions.ScheduledCompletableFuture<?> repeatEvery(final ScheduledExecutorService scheduler, final Duration duration, final Procedure1<? super CompletableFuture<?>> action) {
    SchedulingExtensions.ScheduledCompletableFuture<?> _xblockexpression = null;
    {
      final DurationToTimeConversion.Time time = DurationToTimeConversion.toTime(duration);
      _xblockexpression = SchedulingExtensions.repeatEvery(scheduler, time.amount, time.unit, action);
    }
    return _xblockexpression;
  }
  
  public static SchedulingExtensions.ScheduledCompletableFuture<?> repeatEvery(final long time, final TimeUnit unit, final Procedure1<? super CompletableFuture<?>> action) {
    return SchedulingExtensions.scheduleAtFixedRate(0, time, unit, action);
  }
  
  public static SchedulingExtensions.ScheduledCompletableFuture<?> repeatEvery(final ScheduledExecutorService scheduler, final long time, final TimeUnit unit, final Procedure1<? super CompletableFuture<?>> action) {
    SchedulingExtensions.ScheduledCompletableFuture<?> _xblockexpression = null;
    {
      Objects.<TimeUnit>requireNonNull(unit);
      _xblockexpression = SchedulingExtensions.scheduleAtFixedRate(scheduler, 0, time, unit, action);
    }
    return _xblockexpression;
  }
  
  public static SchedulingExtensions.DelaySpecifier repeatEvery(final long time, final TimeUnit unit) {
    return new SchedulingExtensions.DelaySpecifier() {
      @Override
      public SchedulingExtensions.ScheduledCompletableFuture<?> withInitialDelay(final long initialDelay, final Procedure1<? super CompletableFuture<?>> action) {
        return SchedulingExtensions.scheduleAtFixedRate(initialDelay, time, unit, action);
      }
    };
  }
  
  public static SchedulingExtensions.DelaySpecifier repeatEvery(final ScheduledExecutorService scheduler, final long time, final TimeUnit unit) {
    return new SchedulingExtensions.DelaySpecifier() {
      @Override
      public SchedulingExtensions.ScheduledCompletableFuture<?> withInitialDelay(final long initialDelay, final Procedure1<? super CompletableFuture<?>> action) {
        return SchedulingExtensions.scheduleAtFixedRate(scheduler, initialDelay, time, unit, action);
      }
    };
  }
  
  public static SchedulingExtensions.ScheduledCompletableFuture<?> repeatWithFixedDelay(final long time, final TimeUnit unit, final Procedure1<? super CompletableFuture<?>> action) {
    return SchedulingExtensions.scheduleWithFixedDelay(0, time, unit, action);
  }
  
  public static SchedulingExtensions.DelaySpecifier repeatWithFixedDelay(final long delay, final TimeUnit unit) {
    return new SchedulingExtensions.DelaySpecifier() {
      @Override
      public SchedulingExtensions.ScheduledCompletableFuture<?> withInitialDelay(final long initialDelay, final Procedure1<? super CompletableFuture<?>> action) {
        return SchedulingExtensions.scheduleWithFixedDelay(initialDelay, delay, unit, action);
      }
    };
  }
  
  private static SchedulingExtensions.ScheduledCompletableFuture<?> scheduleAtFixedRate(final long initialDelay, final long rate, final TimeUnit unit, final Procedure1<? super CompletableFuture<?>> action) {
    SchedulingExtensions.ScheduledCompletableFuture<?> _xblockexpression = null;
    {
      final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
      final SchedulingExtensions.ScheduledCompletableFuture<?> result = SchedulingExtensions.scheduleAtFixedRate(scheduler, initialDelay, rate, unit, action);
      final BiConsumer<Object, Throwable> _function = (Object $0, Throwable $1) -> {
        scheduler.shutdown();
      };
      result.whenComplete(_function);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  private static SchedulingExtensions.ScheduledCompletableFuture<?> scheduleAtFixedRate(final ScheduledExecutorService scheduler, final long initialDelay, final long rate, final TimeUnit unit, final Procedure1<? super CompletableFuture<?>> action) {
    abstract class __SchedulingExtensions_4 extends SchedulingExtensions.ScheduledCompletableFuture<Void> {
      final __SchedulingExtensions_4 _this__SchedulingExtensions_4 = this;
      
      Runnable task;
      
      ScheduledFuture<?> scheduled;
      
      @SuppressWarnings("unused")
      CompletableFuture<Void> afterCancel;
    }
    
    __SchedulingExtensions_4 _xblockexpression = null;
    {
      final __SchedulingExtensions_4 result = new __SchedulingExtensions_4() {
        {
          task = ((Runnable) () -> {
            try {
              action.apply(this);
            } catch (final Throwable _t) {
              if (_t instanceof Throwable) {
                final Throwable t = (Throwable)_t;
                this.completeExceptionally(t);
              } else {
                throw Exceptions.sneakyThrow(_t);
              }
            }
          });
          
          scheduled = scheduler.scheduleAtFixedRate(this.task, initialDelay, rate, unit);
          
          afterCancel = this.whenComplete(((BiConsumer<Void, Throwable>) (Void $0, Throwable $1) -> {
            this.scheduled.cancel(false);
          }));
        }
        @Override
        public long getDelay(final TimeUnit unit) {
          return this.scheduled.getDelay(unit);
        }
        
        @Override
        public int compareTo(final Delayed o) {
          return this.scheduled.compareTo(o);
        }
      };
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  private static SchedulingExtensions.ScheduledCompletableFuture<?> scheduleWithFixedDelay(final long initialDelay, final long rate, final TimeUnit unit, final Procedure1<? super CompletableFuture<?>> action) {
    SchedulingExtensions.ScheduledCompletableFuture<?> _xblockexpression = null;
    {
      final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
      final SchedulingExtensions.ScheduledCompletableFuture<?> result = SchedulingExtensions.scheduleWithFixedDelay(scheduler, initialDelay, rate, unit, action);
      final BiConsumer<Object, Throwable> _function = (Object $0, Throwable $1) -> {
        scheduler.shutdown();
      };
      result.whenComplete(_function);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  private static SchedulingExtensions.ScheduledCompletableFuture<?> scheduleWithFixedDelay(final ScheduledExecutorService scheduler, final long initialDelay, final long rate, final TimeUnit unit, final Procedure1<? super CompletableFuture<?>> action) {
    abstract class __SchedulingExtensions_5 extends SchedulingExtensions.ScheduledCompletableFuture<Void> {
      final __SchedulingExtensions_5 _this__SchedulingExtensions_5 = this;
      
      Runnable task;
      
      ScheduledFuture<?> scheduled;
      
      @SuppressWarnings("unused")
      CompletableFuture<Void> afterCancel;
    }
    
    __SchedulingExtensions_5 _xblockexpression = null;
    {
      final __SchedulingExtensions_5 result = new __SchedulingExtensions_5() {
        {
          task = ((Runnable) () -> {
            try {
              action.apply(this);
            } catch (final Throwable _t) {
              if (_t instanceof Throwable) {
                final Throwable t = (Throwable)_t;
                this.completeExceptionally(t);
              } else {
                throw Exceptions.sneakyThrow(_t);
              }
            }
          });
          
          scheduled = scheduler.scheduleWithFixedDelay(this.task, initialDelay, rate, unit);
          
          afterCancel = this.whenComplete(((BiConsumer<Void, Throwable>) (Void $0, Throwable $1) -> {
            this.scheduled.cancel(false);
          }));
        }
        @Override
        public long getDelay(final TimeUnit unit) {
          return this.scheduled.getDelay(unit);
        }
        
        @Override
        public int compareTo(final Delayed o) {
          return this.scheduled.compareTo(o);
        }
      };
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  private static SchedulingExtensions.ScheduledCompletableFuture<Void> waitForInternal(final long time, final TimeUnit unit, final ScheduledExecutorService scheduler) {
    abstract class __SchedulingExtensions_6 extends SchedulingExtensions.ScheduledCompletableFuture<Void> {
      final __SchedulingExtensions_6 _this__SchedulingExtensions_6 = this;
      
      Runnable task;
      
      ScheduledFuture<?> scheduled;
      
      @SuppressWarnings("unused")
      CompletableFuture<Void> afterCancel;
    }
    
    __SchedulingExtensions_6 _xblockexpression = null;
    {
      final __SchedulingExtensions_6 result = new __SchedulingExtensions_6() {
        {
          task = ((Runnable) () -> {
            this.complete(null);
          });
          
          scheduled = scheduler.schedule(this.task, time, unit);
          
          afterCancel = this.whenComplete(((BiConsumer<Void, Throwable>) (Void $0, Throwable $1) -> {
            this.scheduled.cancel(false);
          }));
        }
        @Override
        public long getDelay(final TimeUnit unit) {
          return this.scheduled.getDelay(unit);
        }
        
        @Override
        public int compareTo(final Delayed o) {
          return this.scheduled.compareTo(o);
        }
      };
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  private static SchedulingExtensions.ScheduledCompletableFuture<?> waitForInternal(final long time, final TimeUnit unit, final ScheduledExecutorService scheduler, final Procedure1<? super CompletableFuture<?>> then) {
    abstract class __SchedulingExtensions_7 extends SchedulingExtensions.ScheduledCompletableFuture<Void> {
      final __SchedulingExtensions_7 _this__SchedulingExtensions_7 = this;
      
      Runnable task;
      
      ScheduledFuture<?> scheduled;
      
      @SuppressWarnings("unused")
      CompletableFuture<Void> afterCancel;
    }
    
    __SchedulingExtensions_7 _xblockexpression = null;
    {
      final __SchedulingExtensions_7 result = new __SchedulingExtensions_7() {
        {
          task = ((Runnable) () -> {
            try {
              then.apply(this);
              this.complete(null);
            } catch (final Throwable _t) {
              if (_t instanceof Throwable) {
                final Throwable t = (Throwable)_t;
                this.completeExceptionally(t);
              } else {
                throw Exceptions.sneakyThrow(_t);
              }
            }
          });
          
          scheduled = scheduler.schedule(this.task, time, unit);
          
          afterCancel = this.whenComplete(((BiConsumer<Void, Throwable>) (Void $0, Throwable $1) -> {
            this.scheduled.cancel(false);
          }));
        }
        @Override
        public long getDelay(final TimeUnit unit) {
          return this.scheduled.getDelay(unit);
        }
        
        @Override
        public int compareTo(final Delayed o) {
          return this.scheduled.compareTo(o);
        }
      };
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * The thread calling this method will not block, but immediately return
   * a CompletableFuture that will be completed after the delay specified
   * by the parameters.
   * The returned CompletableFuture will be completed on a new thread.
   * So all non-asynchronous callbacks will be executed on that thread.
   */
  public static SchedulingExtensions.ScheduledCompletableFuture<?> waitFor(final long time, final TimeUnit unit) {
    SchedulingExtensions.ScheduledCompletableFuture<Void> _xblockexpression = null;
    {
      Objects.<TimeUnit>requireNonNull(unit);
      final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
      final SchedulingExtensions.ScheduledCompletableFuture<Void> result = SchedulingExtensions.waitForInternal(time, unit, scheduler);
      final BiConsumer<Void, Throwable> _function = (Void $0, Throwable $1) -> {
        scheduler.shutdown();
      };
      result.whenComplete(_function);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * May cause loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds,
   * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one
   * second) may be stripped.
   */
  public static SchedulingExtensions.ScheduledCompletableFuture<?> waitFor(final Duration duration) {
    SchedulingExtensions.ScheduledCompletableFuture<?> _xblockexpression = null;
    {
      DurationToTimeConversion.Time time = DurationToTimeConversion.toTime(duration);
      _xblockexpression = SchedulingExtensions.waitFor(time.amount, time.unit);
    }
    return _xblockexpression;
  }
  
  /**
   * May cause loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds,
   * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one
   * second) may be stripped.
   */
  public static SchedulingExtensions.ScheduledCompletableFuture<?> waitFor(final Duration duration, final Procedure1<? super CompletableFuture<?>> then) {
    SchedulingExtensions.ScheduledCompletableFuture<?> _xblockexpression = null;
    {
      final DurationToTimeConversion.Time time = DurationToTimeConversion.toTime(duration);
      _xblockexpression = SchedulingExtensions.waitFor(time.amount, time.unit, then);
    }
    return _xblockexpression;
  }
  
  public static SchedulingExtensions.ScheduledCompletableFuture<?> waitFor(final long time, final TimeUnit unit, final Procedure1<? super CompletableFuture<?>> then) {
    SchedulingExtensions.ScheduledCompletableFuture<?> _xblockexpression = null;
    {
      Objects.<TimeUnit>requireNonNull(unit);
      final ScheduledThreadPoolExecutor scheduler = new ScheduledThreadPoolExecutor(1);
      final SchedulingExtensions.ScheduledCompletableFuture<?> result = SchedulingExtensions.waitForInternal(time, unit, scheduler, then);
      final BiConsumer<Object, Throwable> _function = (Object $0, Throwable $1) -> {
        scheduler.shutdown();
      };
      result.whenComplete(_function);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  public static SchedulingExtensions.ScheduledCompletableFuture<?> waitFor(final ScheduledExecutorService scheduler, final long time, final TimeUnit unit, final Procedure1<? super CompletableFuture<?>> action) {
    SchedulingExtensions.ScheduledCompletableFuture<?> _xblockexpression = null;
    {
      Objects.<ScheduledExecutorService>requireNonNull(scheduler);
      Objects.<Procedure1<? super CompletableFuture<?>>>requireNonNull(action);
      _xblockexpression = SchedulingExtensions.waitForInternal(time, unit, scheduler, action);
    }
    return _xblockexpression;
  }
  
  public static <T extends Object> SchedulingExtensions.ScheduledCompletableFuture<T> delay(final long delayTime, final TimeUnit delayUnit, final Function1<? super CompletableFuture<?>, ? extends T> delayed) {
    SchedulingExtensions.ScheduledCompletableFuture<T> _xblockexpression = null;
    {
      final ScheduledThreadPoolExecutor scheduler = new ScheduledThreadPoolExecutor(1);
      final SchedulingExtensions.ScheduledCompletableFuture<T> result = SchedulingExtensions.<T>delayInternal(scheduler, delayTime, delayUnit, delayed);
      final BiConsumer<T, Throwable> _function = (T $0, Throwable $1) -> {
        scheduler.shutdown();
      };
      result.whenComplete(_function);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * May cause loss in time precision, if the overall duration exceeds Long.MAX_VALUE nanoseconds,
   * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one
   * second) may be stripped.
   */
  public static <T extends Object> SchedulingExtensions.ScheduledCompletableFuture<T> delay(final Duration delayBy, final Function1<? super CompletableFuture<?>, ? extends T> delayed) {
    SchedulingExtensions.ScheduledCompletableFuture<T> _xblockexpression = null;
    {
      DurationToTimeConversion.Time time = DurationToTimeConversion.toTime(delayBy);
      _xblockexpression = SchedulingExtensions.<T>delay(time.amount, time.unit, delayed);
    }
    return _xblockexpression;
  }
  
  public static <T extends Object> SchedulingExtensions.ScheduledCompletableFuture<T> delay(final ScheduledExecutorService scheduler, final long time, final TimeUnit unit, final Function1<? super CompletableFuture<?>, ? extends T> action) {
    SchedulingExtensions.ScheduledCompletableFuture<T> _xblockexpression = null;
    {
      Objects.<ScheduledExecutorService>requireNonNull(scheduler);
      Objects.<Function1<? super CompletableFuture<?>, ? extends T>>requireNonNull(action);
      _xblockexpression = SchedulingExtensions.<T>delayInternal(scheduler, time, unit, action);
    }
    return _xblockexpression;
  }
  
  private static <T extends Object> SchedulingExtensions.ScheduledCompletableFuture<T> delayInternal(final ScheduledExecutorService scheduler, final long time, final TimeUnit unit, final Function1<? super CompletableFuture<?>, ? extends T> action) {
    abstract class __SchedulingExtensions_8 extends SchedulingExtensions.ScheduledCompletableFuture<T> {
      final __SchedulingExtensions_8 _this__SchedulingExtensions_8 = this;
      
      Runnable task;
      
      ScheduledFuture<?> scheduled;
      
      @SuppressWarnings("unused")
      CompletableFuture<T> afterCancel;
    }
    
    __SchedulingExtensions_8 _xblockexpression = null;
    {
      final __SchedulingExtensions_8 result = new __SchedulingExtensions_8() {
        {
          task = ((Runnable) () -> {
            try {
              final T computationResult = action.apply(this);
              this.complete(computationResult);
            } catch (final Throwable _t) {
              if (_t instanceof Throwable) {
                final Throwable t = (Throwable)_t;
                this.completeExceptionally(t);
              } else {
                throw Exceptions.sneakyThrow(_t);
              }
            }
          });
          
          scheduled = scheduler.schedule(this.task, time, unit);
          
          afterCancel = this.whenComplete(((BiConsumer<T, Throwable>) (T $0, Throwable $1) -> {
            this.scheduled.cancel(false);
          }));
        }
        @Override
        public long getDelay(final TimeUnit unit) {
          return this.scheduled.getDelay(unit);
        }
        
        @Override
        public int compareTo(final Delayed o) {
          return this.scheduled.compareTo(o);
        }
      };
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
}
