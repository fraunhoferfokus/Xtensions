package de.fhg.fokus.xtenders.concurrent;

import de.fhg.fokus.xtenders.concurrent.internal.DurationToTimeConversion;
import java.time.Duration;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.Callable;
import java.util.concurrent.CancellationException;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.function.BiConsumer;
import java.util.function.BiFunction;
import java.util.function.Consumer;
import java.util.function.Function;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

/**
 * This class provides static methods (many of them to be used as extension methods)
 * that enrich the {@code CompletableFuture} class.
 * <p>
 * The extension methods for CompletableFuture make some common use cases easier. Some of these methods are:
 * <ul>
 * 	 <li>{@link #then(CompletableFuture, Function1)}</li>
 * 	 <li>{@link #then(CompletableFuture, Procedure1)}</li>
 * 	 <li>{@link #then(CompletableFuture, Procedure0)}</li>
 * 	 <li>{@link #whenSuccessfull(CompletableFuture, Procedure1)}</li>
 * 	 <li>{@link #whenCancelled(CompletableFuture, Procedure0)}</li>
 * 	 <li>{@link #whenException(CompletableFuture, Procedure1)}</li>
 * 	 <li>{@link #handleCancellation(CompletableFuture, Function0)}</li>
 * 	 <li>{@link #cancelOnTimeout(CompletableFuture, long, TimeUnit)}</li>
 * 	 <li>{@link #cancelOnTimeout(CompletableFuture, ScheduledExecutorService, long, TimeUnit)}</li>
 * 	 <li>{@link #forwardTo(CompletableFuture, CompletableFuture)}</li>
 * 	 <li>{@link #forwardCancellation(CompletableFuture, CompletableFuture)}</li>
 * </ul>
 * <p>
 */
@SuppressWarnings("all")
public class CompletableFutureExtensions {
  /**
   * Calls {@link CompletableFuture#cancel(boolean)} on the given {@code future}.
   * Since the boolean parameter {@code mayInterruptIfRunning} has no influence
   * on CompletableFuture instances anyway,  this method provides a cancel method
   * without the parameter.
   * @see CompletableFuture#cancel(boolean)
   */
  public static <R extends Object> boolean cancel(final CompletableFuture<R> future) {
    boolean _xblockexpression = false;
    {
      Objects.<CompletableFuture<R>>requireNonNull(future);
      _xblockexpression = future.cancel(false);
    }
    return _xblockexpression;
  }
  
  /**
   * This method calls {@link #cancelOnTimeout(CompletableFuture, long , TimeUnit)} with a
   * best effort converting the given {@code Duration timeout} to a {@code long} of {@code
   * TimeUnit}.
   * May cause loss in time precision, if the overall timeout duration exceeds Long.MAX_VALUE nanoseconds,
   * which is roughly a duration of 292.5 years. At most at most 999,999,999 nanoseconds (less than one
   * second) may be stripped.
   * @param fut the future to be cancelled after {@code timeout}, provided the future
   *   is not completed before cancellation.
   * @param timeout specifies time to wait, before canceling {@code fut}. Must not be {@code null}.
   * @return result of call to {@link #cancelOnTimeout(CompletableFuture, long, TimeUnit)}
   * @see #cancelOnTimeout(CompletableFuture, long, TimeUnit)
   * @throws NullPointerException throws if {@code fut} or {@code timeout} is {@code null}
   */
  public static <R extends Object> CompletableFuture<R> cancelOnTimeout(final CompletableFuture<R> fut, final Duration timeout) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Duration>requireNonNull(timeout);
      final DurationToTimeConversion.Time time = DurationToTimeConversion.toTime(timeout);
      _xblockexpression = CompletableFutureExtensions.<R>cancelOnTimeout(fut, time.amount, time.unit);
    }
    return _xblockexpression;
  }
  
  /**
   * Defines a time out for the given future {@code fut}. When the time out is reached
   * {@code fut} will be cancelled, if the future was not completed already. To determine the time
   * to wait until performing the cancellation the time is specified by parameter {@code timeout} and
   * the unit of time is specified by parameter {@code unit}. This method
   * will create and use a scheduler internally to schedule the cancellation. To use an own
   * scheduler, use method {@link #cancelOnTimeout(CompletableFuture, ScheduledExecutorService, long, TimeUnit)}.
   * @param fut the future to be cancelled after {@code timeout} of time unit {@code unit}, provided the future
   *   is not completed before cancellation.
   * @param timeout specifies time to wait, before canceling {@code fut}. Must be &gt;=0
   * @param unit specifies the time unit of {@code timeout}
   * @return returns parameter {@code fut}
   * @see #cancelOnTimeout(CompletableFuture, ScheduledExecutorService, long, TimeUnit)
   * @throws NullPointerException throws if {@code fut} or {@code unit} is {@code null}
   */
  public static <R extends Object> CompletableFuture<R> cancelOnTimeout(final CompletableFuture<R> fut, final long timeout, final TimeUnit unit) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<TimeUnit>requireNonNull(unit);
      boolean _isDone = fut.isDone();
      if (_isDone) {
        return fut;
      }
      final ScheduledThreadPoolExecutor scheduler = CompletableFutureExtensions.getDefaultScheduler();
      final Runnable _function = () -> {
        try {
          CompletableFutureExtensions.<R>cancel(fut);
        } finally {
          scheduler.shutdown();
        }
        return;
      };
      final ScheduledFuture<?> task = scheduler.schedule(_function, timeout, unit);
      final BiConsumer<R, Throwable> _function_1 = (R $0, Throwable $1) -> {
        boolean _cancel = task.cancel(true);
        if (_cancel) {
          scheduler.shutdown();
        }
      };
      fut.whenCompleteAsync(_function_1, scheduler);
      _xblockexpression = fut;
    }
    return _xblockexpression;
  }
  
  /**
   * ScheduledThreadPoolExecutor using daemon threads and allow task
   * removal on cancellation of task.
   */
  private static ScheduledThreadPoolExecutor getDefaultScheduler() {
    ScheduledThreadPoolExecutor _xblockexpression = null;
    {
      ThreadFactory _daemonThreadFactory = CompletableFutureExtensions.getDaemonThreadFactory();
      final ScheduledThreadPoolExecutor scheduler = new ScheduledThreadPoolExecutor(0, _daemonThreadFactory);
      scheduler.setRemoveOnCancelPolicy(true);
      _xblockexpression = scheduler;
    }
    return _xblockexpression;
  }
  
  /**
   * Defines a time out for the given future {@code fut}. When the time out is reached
   * {@code fut} will be cancelled, if the future was not completed already. To determine the time
   * to wait until performing the cancellation the time is specified by parameter {@code timeout} and
   * the unit of time is specified by parameter {@code unit}. This method
   * will the given {@code scheduler} to schedule the cancellation. If the scheduler should be provided for
   * the caller, use method {@link #cancelOnTimeout(CompletableFuture, long, TimeUnit)}.
   * This method is not responsible for shutting down the given {@code scheduler}
   * @param fut future to be cancelled after timeout of {@code time} of time unit {@code unit}.
   * @param scheduler the timeout will be scheduled and the cancellation executed on this
   *   scheduling pool.
   * @param time timeout time in time unit {@code unit} after which {@code fut} will be cancelled.
   * @param unit time unit of timeout {@code time}.
   * @return same reference as parameter {@code fut}.
   * @see #cancelOnTimeout(CompletableFuture, long, TimeUnit)
   */
  public static <R extends Object> CompletableFuture<R> cancelOnTimeout(final CompletableFuture<R> fut, final ScheduledExecutorService scheduler, final long time, final TimeUnit unit) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<ScheduledExecutorService>requireNonNull(scheduler);
      Objects.<TimeUnit>requireNonNull(unit);
      boolean _isDone = fut.isDone();
      if (_isDone) {
        return fut;
      }
      final Callable<Boolean> _function = () -> {
        return Boolean.valueOf(CompletableFutureExtensions.<R>cancel(fut));
      };
      final ScheduledFuture<Boolean> task = scheduler.<Boolean>schedule(_function, time, unit);
      final BiConsumer<R, Throwable> _function_1 = (R $0, Throwable $1) -> {
        task.cancel(true);
      };
      fut.whenCompleteAsync(_function_1, scheduler);
      _xblockexpression = fut;
    }
    return _xblockexpression;
  }
  
  private static ThreadFactory getDaemonThreadFactory() {
    final ThreadFactory _function = (Runnable it) -> {
      Thread _xblockexpression = null;
      {
        ThreadFactory _defaultThreadFactory = Executors.defaultThreadFactory();
        final Thread t = _defaultThreadFactory.newThread(it);
        t.setDaemon(true);
        _xblockexpression = t;
      }
      return _xblockexpression;
    };
    return _function;
  }
  
  public static <R extends Object> CompletableFuture<R> withTimeout(final CompletableFuture<R> fut, final ScheduledExecutorService scheduler, final long time, final TimeUnit unit) {
    final Function0<Throwable> _function = () -> {
      return new TimeoutException();
    };
    return CompletableFutureExtensions.<R>withTimeout(fut, scheduler, time, unit, _function);
  }
  
  public static <R extends Object> CompletableFuture<R> withTimeout(final CompletableFuture<R> fut, final ScheduledExecutorService scheduler, final long time, final TimeUnit unit, final Function0<? extends Throwable> exceptionProvider) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<ScheduledExecutorService>requireNonNull(scheduler);
      Objects.<TimeUnit>requireNonNull(unit);
      boolean _isDone = fut.isDone();
      if (_isDone) {
        return fut;
      }
      final CompletableFuture<R> result = new CompletableFuture<R>();
      final Callable<Boolean> _function = () -> {
        boolean _xblockexpression_1 = false;
        {
          try {
            boolean _isDone_1 = result.isDone();
            boolean _not = (!_isDone_1);
            if (_not) {
              Throwable _apply = exceptionProvider.apply();
              result.completeExceptionally(_apply);
            }
          } catch (final Throwable _t) {
            if (_t instanceof Throwable) {
              final Throwable t = (Throwable)_t;
              result.completeExceptionally(t);
            } else {
              throw Exceptions.sneakyThrow(_t);
            }
          }
          _xblockexpression_1 = CompletableFutureExtensions.<R>cancel(fut);
        }
        return Boolean.valueOf(_xblockexpression_1);
      };
      final ScheduledFuture<Boolean> task = scheduler.<Boolean>schedule(_function, time, unit);
      final BiConsumer<R, Throwable> _function_1 = (R r, Throwable ex) -> {
        boolean _notEquals = (!com.google.common.base.Objects.equal(ex, null));
        if (_notEquals) {
          result.completeExceptionally(ex);
        } else {
          result.complete(r);
        }
        try {
          final Runnable _function_2 = () -> {
            task.cancel(true);
          };
          scheduler.execute(_function_2);
        } catch (final Throwable _t) {
          if (_t instanceof RejectedExecutionException) {
            final RejectedExecutionException ree = (RejectedExecutionException)_t;
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        }
      };
      fut.whenComplete(_function_1);
      CompletableFutureExtensions.forwardCancellation(result, fut);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> withTimeout(final CompletableFuture<R> fut, final long timeout, final TimeUnit unit) {
    final Function0<Throwable> _function = () -> {
      return new TimeoutException();
    };
    return CompletableFutureExtensions.<R>withTimeout(fut, timeout, unit, _function);
  }
  
  public static <R extends Object> CompletableFuture<R> withTimeout(final CompletableFuture<R> fut, final long timeout, final TimeUnit unit, final Function0<? extends Throwable> exceptionProvider) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<TimeUnit>requireNonNull(unit);
      boolean _isDone = fut.isDone();
      if (_isDone) {
        return fut;
      }
      final CompletableFuture<R> result = new CompletableFuture<R>();
      final ScheduledThreadPoolExecutor scheduler = CompletableFutureExtensions.getDefaultScheduler();
      final Runnable _function = () -> {
        try {
          boolean _isDone_1 = result.isDone();
          boolean _not = (!_isDone_1);
          if (_not) {
            Throwable _apply = exceptionProvider.apply();
            result.completeExceptionally(_apply);
          }
        } catch (final Throwable _t) {
          if (_t instanceof Throwable) {
            final Throwable t = (Throwable)_t;
            result.completeExceptionally(t);
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        } finally {
          CompletableFutureExtensions.<R>cancel(fut);
          scheduler.shutdown();
        }
        return;
      };
      final ScheduledFuture<?> task = scheduler.schedule(_function, timeout, unit);
      final BiConsumer<R, Throwable> _function_1 = (R r, Throwable ex) -> {
        boolean _notEquals = (!com.google.common.base.Objects.equal(ex, null));
        if (_notEquals) {
          result.completeExceptionally(ex);
        } else {
          result.complete(r);
        }
        try {
          final Runnable _function_2 = () -> {
            boolean _cancel = task.cancel(true);
            if (_cancel) {
              scheduler.shutdown();
            }
          };
          scheduler.execute(_function_2);
        } catch (final Throwable _t) {
          if (_t instanceof RejectedExecutionException) {
            final RejectedExecutionException ree = (RejectedExecutionException)_t;
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        }
      };
      fut.whenComplete(_function_1);
      CompletableFutureExtensions.forwardCancellation(result, fut);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * This function will forward the result of future {@code from} to future {@code to}. This is independent
   * of the result, this could be a regular or exceptional result (which includes cancellation). If future
   * {@code to} was completed before {@code from} got completed the attempt to forward will fail without
   * further feedback to the caller of this method. Returns a CompletableFuture that completes after
   * {@code to} was completed with the same result as the original, which includes cancellation
   * @param from the result of this future will be forwarded to future {@code to}
   * @param to the result of {@code from} will be forwarded to this future.
   * @return a CompletableFuture that will complete after the forwarding is complete.
   * @throws NullPointerException if {@code from} or {@code to} is {@code null}
   */
  public static <R extends Object> CompletionStage<R> forwardTo(final CompletionStage<R> from, final CompletableFuture<? super R> to) throws NullPointerException {
    CompletionStage<R> _xblockexpression = null;
    {
      Objects.<CompletionStage<R>>requireNonNull(from);
      Objects.<CompletableFuture<? super R>>requireNonNull(to);
      final BiConsumer<R, Throwable> _function = (R o, Throwable t) -> {
        boolean _notEquals = (!com.google.common.base.Objects.equal(t, null));
        if (_notEquals) {
          to.completeExceptionally(t);
        } else {
          to.complete(o);
        }
      };
      _xblockexpression = from.whenComplete(_function);
    }
    return _xblockexpression;
  }
  
  /**
   * This is the inverse operation of {@link CompletableFutureExtensions#forwardTo(CompletableFuture,
   * CompletableFuture) forwardTo}. This method will simply call forwardTo parameters in switched order.
   * @param toComplete the future that will be completed with the result of {@code with}.
   * @param with the future that provides the result that will be forwarded to {@code toComplete}.
   * @see CompletableFutureExtensions#forwardTo(CompletableFuture,
   * CompletableFuture)
   * @return a CompletableFuture that will complete after the forwarding is complete.
   */
  public static <R extends Object> CompletionStage<R> completeWith(final CompletableFuture<? super R> toComplete, final CompletionStage<R> with) {
    CompletionStage<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<? super R>>requireNonNull(toComplete);
      Objects.<CompletionStage<R>>requireNonNull(with);
      _xblockexpression = CompletableFutureExtensions.<R>forwardTo(with, toComplete);
    }
    return _xblockexpression;
  }
  
  /**
   * This function helps integration of CompletableFuture and blocking APIs. Blocking APIs may allow
   * cancellation via interrupting the thread the blocking call is performed on. When a blocking call
   * is performed on a thread pool it is crucial that the interruption is visible to other tasks that
   * may be run on the thread. This function is a bridge between cancellation of CompletableFuture and
   * thread interruption for blocking APIs. The {@interruptableBlock} is called by this method and only
   * while the block is executed cancellation of the future passed as parameter {@code fut} will lead
   * to interruption of the current thread executing this method and the {@code interruptableBlock}.
   * Thrown exceptions will be thrown to the caller of this method.<br>
   * After this method the interrupted flag of this thread is unset, even when the block throws an exception.
   * This way the thread calling this can safely be a pooled thread and may not interrupt some other task
   * submitted to the thread pool managing the thread. <br>
   * This is an example of how this message could be used:
   * <code><pre>
   * val blockOpPool = Executors.newCachedThreadPool
   * // ...
   * val sleepy = blockOpPool.asyncRun [
   *   whenCancelledInterrupt [|
   *     try {
   *       Thread.sleep(100)
   *     } catch (InterruptedException e) {
   *       println("Hey, I was cancelled")
   *     }
   *   ]
   * ]
   * </pre></code>
   * To make cancellation not interrupt the current thread outside of the context of the
   * {@code interruptableBlock}, blocking synchronization is needed at the end of execution
   * of {@code interruptableBlock} and in the handler registered on {@code fut} being executed
   * on cancellation.
   * 
   * @param fut future that if cancelled will interrupt the thread calling {@code interruptableBlock}.
   * @param interruptableBlock the block of code that is executed on the thread calling this method.
   *   If {@code fut} is cancelled during execution of the block, the calling thread will be interrupted.
   *   After execution of this block the thread's interrupted flag will be reset.
   *   This is also guaranteed if the block of code throws an exception.
   * @throws NullPointerException will be thrown if {@code fut} or {@code interruptableBlock} is {@code null}.
   */
  public static <R extends Object> void whenCancelledInterrupt(final CompletableFuture<R> fut, final Procedure0 interruptableBlock) {
    Objects.<CompletableFuture<R>>requireNonNull(fut);
    Objects.<Procedure0>requireNonNull(interruptableBlock);
    final AtomicBoolean interruptAllowed = new AtomicBoolean(true);
    final Thread interruptableThread = Thread.currentThread();
    final Procedure0 _function = () -> {
      boolean _get = interruptAllowed.get();
      boolean _not = (!_get);
      if (_not) {
        return;
      }
      synchronized (interruptAllowed) {
        boolean _get_1 = interruptAllowed.get();
        if (_get_1) {
          interruptableThread.interrupt();
        }
      }
    };
    CompletableFutureExtensions.<R>whenCancelled(fut, _function);
    try {
      interruptableBlock.apply();
    } finally {
      synchronized (interruptAllowed) {
        interruptAllowed.set(false);
        Thread.interrupted();
      }
    }
  }
  
  /**
   * The effect of calling this method is like using
   * {@link CompletableFuture#exceptionally(java.util.function.Function) CompletableFuture#exceptionally}
   * where the provided function is only called when {@code fut} is completed with a {@link CancellationException}.
   * If {@code fut} completes exceptionally, but not with a {@code CancellationException}, the exception is
   * re-thrown from the handler, so the returned future will be completed exceptionally with the same exception.
   * 
   * @param fut future {@code handler} is registered on. Must not be {@code null}.
   * @param handler the callback to be invoked when {@code fut} is completed with cancellation.
   *   Must not be {@code null}.
   * @return new CompletableFuture that either is completed with the result of {@code fut}, if
   *   {@code fut} completes successful. Otherwise the result provided from {@code handler} is
   *   used to complete the returned future.
   * @throws NullPointerException is thrown when {@code fut} or {@code handler} is {@code null}.
   */
  public static <R extends Object> CompletableFuture<R> handleCancellation(final CompletableFuture<R> fut, final Function0<? extends R> handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Function0<? extends R>>requireNonNull(handler);
      final Function<Throwable, R> _function = (Throwable ex) -> {
        try {
          R _xifexpression = null;
          if ((ex instanceof CancellationException)) {
            _xifexpression = handler.apply();
          } else {
            throw ex;
          }
          return _xifexpression;
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      _xblockexpression = fut.exceptionally(_function);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> handleCancellationAsync(final CompletableFuture<R> fut, final Function0<? extends R> handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Function0<? extends R>>requireNonNull(handler);
      ForkJoinPool _commonPool = ForkJoinPool.commonPool();
      _xblockexpression = CompletableFutureExtensions.<R>handleCancellationAsync(fut, _commonPool, handler);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> handleCancellationAsync(final CompletableFuture<R> fut, final Executor e, final Function0<? extends R> handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Executor>requireNonNull(e);
      Objects.<Function0<? extends R>>requireNonNull(handler);
      final BiFunction<R, Throwable, R> _function = (R o, Throwable t) -> {
        try {
          R _xifexpression = null;
          boolean _notEquals = (!com.google.common.base.Objects.equal(t, null));
          if (_notEquals) {
            R _xifexpression_1 = null;
            if ((t instanceof CancellationException)) {
              _xifexpression_1 = handler.apply();
            } else {
              throw t;
            }
            _xifexpression = _xifexpression_1;
          } else {
            _xifexpression = o;
          }
          return _xifexpression;
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      _xblockexpression = fut.<R>handleAsync(_function, e);
    }
    return _xblockexpression;
  }
  
  /**
   * This is a version of {@link CompletableFuture#exceptionally(Function) exceptionally} where the
   * handler is executed on the common ForkJoinPool.<br>
   * The future returned by this method either completes successfully, if parameter {@code fut} completes
   * successfully, or with the result of {@code handler}, if {@code fut} completes exceptionally. If
   * {@code handler} throws an exception, the returned future will complete exceptionally with the thrown
   * exception.
   * @param fut Future that's successful result will be forwarded to the returned future. If this future completes
   *   exceptionally {@code handler} will be called to determine the completion result of the returned future.
   * @param handler If {@code fut} completes exceptionally, this handler will be called to determine the result
   *   that will be set on the future returned by this method. If handler throws an exception, the returned
   *   future completes exceptionally with the exception thrown by {@code handler}. The handler not be {@code null}.
   * @return new future that will either complete with the result of {@code fut}, if it completes successfully,
   *  or with the result provided by {@code handler} if {@code fut} completes exceptionally.
   * @throws NullPointerException if {@code fut} or {@code handle} is {@code null}.
   * @see #exceptionallyAsync(CompletableFuture, Executor, Function1)
   */
  public static <R extends Object> CompletableFuture<R> exceptionallyAsync(final CompletableFuture<? extends R> fut, final Function1<? super Throwable, ? extends R> handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<? extends R>>requireNonNull(fut);
      Objects.<Function1<? super Throwable, ? extends R>>requireNonNull(handler);
      ForkJoinPool _commonPool = ForkJoinPool.commonPool();
      _xblockexpression = CompletableFutureExtensions.<R>exceptionallyAsync(fut, _commonPool, handler);
    }
    return _xblockexpression;
  }
  
  /**
   * This is a version of {@link CompletableFuture#exceptionally(Function) exceptionally} where the
   * handler is executed on the given {@code executor}.<br>
   * The future returned by this method either completes successfully, if parameter {@code fut} completes
   * successfully, or with the result of {@code handler}, if {@code fut} completes exceptionally. If
   * {@code handler} throws an exception, the returned future will complete exceptionally with the thrown
   * exception.
   * @param fut Future that's successful result will be forwarded to the returned future. If this future completes
   *   exceptionally {@code handler} will be called to determine the completion result of the returned future.
   * @param executor the executor used to check on the result of {@code fut} and execution of {@code handler}.
   * @param handler If {@code fut} completes exceptionally, this handler will be called to determine the result
   *   that will be set on the future returned by this method. If handler throws an exception, the returned
   *   future completes exceptionally with the exception thrown by {@code handler}. The handler not be {@code null}.
   * @return new future that will either complete with the result of {@code fut}, if it completes successfully,
   *  or with the result provided by {@code handler} if {@code fut} completes exceptionally.
   * @throws NullPointerException if {@code fut}, {@code executor}, or {@code handle} is {@code null}.
   * @see #exceptionallyAsync(CompletableFuture, Executor, Function1)
   */
  public static <R extends Object> CompletableFuture<R> exceptionallyAsync(final CompletableFuture<? extends R> fut, final Executor executor, final Function1<? super Throwable, ? extends R> handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<? extends R>>requireNonNull(fut);
      Objects.<Executor>requireNonNull(executor);
      final BiFunction<R, Throwable, R> _function = (R o, Throwable t) -> {
        R _xifexpression = null;
        boolean _notEquals = (!com.google.common.base.Objects.equal(t, null));
        if (_notEquals) {
          _xifexpression = handler.apply(t);
        } else {
          _xifexpression = o;
        }
        return _xifexpression;
      };
      _xblockexpression = fut.<R>handleAsync(_function, executor);
    }
    return _xblockexpression;
  }
  
  private static <T extends Object> BiConsumer<T, Throwable> whenCancelledHandler(final Procedure0 handler) {
    final BiConsumer<T, Throwable> _function = (T o, Throwable t) -> {
      boolean _and = false;
      boolean _notEquals = (!com.google.common.base.Objects.equal(t, null));
      if (!_notEquals) {
        _and = false;
      } else {
        _and = (t instanceof CancellationException);
      }
      if (_and) {
        handler.apply();
      }
    };
    return _function;
  }
  
  /**
   * Registers {@code handler} on the given future {@fut} to be called when the future is cancelled
   * (meaning completed with an instance of {@link CancellationException}).
   * @param fut the future {@code handler} is registered on for notification about cancellation.
   *   Must not be {@code null}.
   * @param handler callback to be registered on {@code fut}, being called when the future gets cancelled.
   *   Must not be {@code null}.
   * @return a CompletableFuture that will complete after the handler completes or if {@code fut} completes
   *  without being cancelled. If {@code fut} is cancelled the returned future will be completed exceptionally
   *  with a {@link java.util.concurrent.CancellationException CancellationException}, but will not itself count
   *  as cancelled ({@link CompletableFuture#isCancelled() isCancelled} will return {@code false}).
   *  When the original future completes exceptionally, callback methods on the returned future will provide a {@link java.util.concurrent.CompletionException CompletionException}
   *  wrapping the original exception. This includes {@code CancellationException}s.
   * @throws NullPointerException if {@code fut} or {@code handler} is {@code null}.
   */
  public static <R extends Object> CompletableFuture<R> whenCancelled(final CompletableFuture<R> fut, final Procedure0 handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Procedure0>requireNonNull(handler);
      BiConsumer<R, Throwable> _whenCancelledHandler = CompletableFutureExtensions.<R>whenCancelledHandler(handler);
      _xblockexpression = fut.whenComplete(_whenCancelledHandler);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> whenCancelledAsync(final CompletableFuture<R> fut, final Procedure0 handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Procedure0>requireNonNull(handler);
      ForkJoinPool _commonPool = ForkJoinPool.commonPool();
      _xblockexpression = CompletableFutureExtensions.<R>whenCancelledAsync(fut, _commonPool, handler);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> whenCancelledAsync(final CompletableFuture<R> fut, final Executor e, final Procedure0 handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Executor>requireNonNull(e);
      Objects.<Procedure0>requireNonNull(handler);
      BiConsumer<R, Throwable> _whenCancelledHandler = CompletableFutureExtensions.<R>whenCancelledHandler(handler);
      _xblockexpression = fut.whenCompleteAsync(_whenCancelledHandler, e);
    }
    return _xblockexpression;
  }
  
  private static <R extends Object> BiConsumer<R, Throwable> whenExcpetionHandler(final Procedure1<? super Throwable> handler) {
    final BiConsumer<R, Throwable> _function = (R o, Throwable t) -> {
      boolean _notEquals = (!com.google.common.base.Objects.equal(t, null));
      if (_notEquals) {
        handler.apply(t);
      }
    };
    return _function;
  }
  
  /**
   * Registers {@code handler} on the given future {@fut} to be called when the future completes
   * exceptionally. This also includes cancellation.
   * @param fut the future {@code handler} is registered on for notification about exceptional completion.
   *   Must not be {@code null}.
   * @param handler callback to be registered on {@code fut}, being called when the future completes with an exception.
   *   If the handler throws an exception, the returned future will be completed with the original exception.
   *   The handler must not be {@code null}.
   * @return a CompletableFuture that will complete after the handler completes or if {@code fut} completes
   *  successfully. If {@code fut} completes exceptionally the returned future will be completed exceptionally
   *  with the same exception.
   * @throws NullPointerException if {@code fut} or {@code handler} is {@code null}.
   */
  public static <R extends Object> CompletableFuture<R> whenException(final CompletableFuture<R> fut, final Procedure1<? super Throwable> handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Procedure1<? super Throwable>>requireNonNull(handler);
      BiConsumer<R, Throwable> _whenExcpetionHandler = CompletableFutureExtensions.<R>whenExcpetionHandler(handler);
      _xblockexpression = fut.whenComplete(_whenExcpetionHandler);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> whenExceptionAsync(final CompletableFuture<R> fut, final Procedure1<? super Throwable> handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Procedure1<? super Throwable>>requireNonNull(handler);
      ForkJoinPool _commonPool = ForkJoinPool.commonPool();
      _xblockexpression = CompletableFutureExtensions.<R>whenExceptionAsync(fut, _commonPool, handler);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> whenExceptionAsync(final CompletableFuture<R> fut, final Executor e, final Procedure1<? super Throwable> handler) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Executor>requireNonNull(e);
      Objects.<Procedure1<? super Throwable>>requireNonNull(handler);
      BiConsumer<R, Throwable> _whenExcpetionHandler = CompletableFutureExtensions.<R>whenExcpetionHandler(handler);
      _xblockexpression = fut.whenCompleteAsync(_whenExcpetionHandler, e);
    }
    return _xblockexpression;
  }
  
  /**
   * Registers a callback on future {@code from} so when the future is cancelled, the
   * future {@code to} will be attempted to be cancelled as well. If by the time {@code to} is already
   * completed, the cancellation of {@code from} will have no affect.
   * @param from if this future is cancelled, {@code to} will be tried to be cancelled as well..
   *    Must not be {@code null}.
   * @param to future to be cancelled when {@code from} is cancelled.
   * @throws NullPointerException thrown if {@code from} or {@code to} is {@code null}
   */
  public static void forwardCancellation(final CompletableFuture<?> from, final CompletableFuture<?> to) {
    Objects.<CompletableFuture<?>>requireNonNull(from);
    Objects.<CompletableFuture<?>>requireNonNull(to);
    final Procedure0 _function = () -> {
      CompletableFutureExtensions.cancel(to);
    };
    CompletableFutureExtensions.whenCancelled(from, _function);
  }
  
  /**
   * Registers a callback on future {@code from} so when the future is cancelled, the
   * future {@code to} and all futures in {@code toRest} will be attempted to be cancelled as well.
   * If by the time {@code to} or futures in {@code toRest} is already completed,
   * the cancellation of {@code from} will have no affect on the respective future.
   * @param from if this future is cancelled, {@code to} will be tried to be cancelled as well..
   *    Must not be {@code null}.
   * @param to first future to be cancelled when {@code from} is cancelled. Must not be {@code null}
   *   and must not contain any {@code null} references.
   * @param toRest additional futures to be cancelled when {@code from} is cancelled.
   * @throws NullPointerException thrown if {@code from}, {@code to}, {@code toRest}, or any
   *  of the fields of {@code toRest} is {@code null}.
   */
  public static void forwardCancellation(final CompletableFuture<?> from, final CompletableFuture<?> to, final CompletableFuture<?>... toRest) {
    Objects.<CompletableFuture<?>>requireNonNull(from);
    Objects.<CompletableFuture<?>>requireNonNull(to);
    Objects.<CompletableFuture<?>[]>requireNonNull(toRest);
    for (final CompletableFuture<?> cf : toRest) {
      Objects.<CompletableFuture<?>>requireNonNull(cf);
    }
    final Procedure0 _function = () -> {
      CompletableFutureExtensions.cancel(to);
      final Consumer<CompletableFuture<?>> _function_1 = (CompletableFuture<?> it) -> {
        CompletableFutureExtensions.cancel(it);
      };
      ((List<CompletableFuture<?>>)Conversions.doWrapArray(toRest)).forEach(_function_1);
    };
    CompletableFutureExtensions.whenCancelled(from, _function);
  }
  
  /**
   * This function is calling {@link CompletableFuture#thenAccept(Consumer)} on {@code fut}, adapting
   * {@code handler} as the parameter.
   * @param fut the future on which {@link CompletableFuture#thenAccept(Consumer) thenAccept} will be called.
   *   Must not be {@code null}.
   * @param handler the function that will be called as the consumer to {@code thenAccept}
   *   Must not be {@code null}.
   * @return resulting CompletableFuture of {@code thenAccept} call
   * @see #then(CompletableFuture, Function1)
   * @see #then(CompletableFuture, Procedure0)
   * @throws NullPointerException if either {@code fut} or {@code handler} is {@code null}
   */
  public static <R extends Object> CompletableFuture<Void> then(final CompletableFuture<R> fut, final Procedure1<? super R> handler) {
    CompletableFuture<Void> _xblockexpression = null;
    {
      Objects.<Procedure1<? super R>>requireNonNull(handler);
      _xblockexpression = fut.thenAccept(new Consumer<R>() {
          public void accept(R t) {
            handler.apply(t);
          }
      });
    }
    return _xblockexpression;
  }
  
  /**
   * This function is calling {@link CompletableFuture#thenApply(Function)} on {@code fut}, adapting
   * {@code handler} as the parameter.
   * @param fut the future on which {@link CompletableFuture#thenApply(Function) thenApply} will be called
   *   Must not be {@code null}.
   * @param handler the function that will be called as the consumer to {@code thenApply}
   *   Must not be {@code null}.
   * @return resulting CompletableFuture of {@code thenApply} call
   * @throws NullPointerException if either {@code fut} or {@code handler} is {@code null}
   * @see #then(CompletableFuture, Procedure0)
   * @see #then(CompletableFuture, Procedure1)
   */
  public static <R extends Object, U extends Object> CompletableFuture<U> then(final CompletableFuture<R> fut, final Function1<? super R, ? extends U> handler) {
    CompletableFuture<U> _xblockexpression = null;
    {
      Objects.<Function1<? super R, ? extends U>>requireNonNull(handler);
      _xblockexpression = fut.<U>thenApply(new Function<R, U>() {
          public U apply(R t) {
            return handler.apply(t);
          }
      });
    }
    return _xblockexpression;
  }
  
  /**
   * This function is calling {@link CompletableFuture#thenRun(Runnable)} on {@code fut}, adapting
   * {@code handler} as the parameter.
   * @param fut the future on which {@link CompletableFuture#thenRun(Runnable) thenRun} will be called
   * @param handler the function that will be called as the consumer to {@code thenRun}
   * @return resulting CompletableFuture of {@code thenRun} call
   * @throws NullPointerException if either {@code fut} or {@code handler} is {@code null}
   * @see #then(CompletableFuture, Function1)
   * @see #then(CompletableFuture, Procedure1)
   */
  public static <R extends Object> CompletableFuture<Void> then(final CompletableFuture<R> fut, final Procedure0 handler) {
    CompletableFuture<Void> _xblockexpression = null;
    {
      Objects.<Procedure0>requireNonNull(handler);
      _xblockexpression = fut.thenRun(new Runnable() {
          public void run() {
            handler.apply();
          }
      });
    }
    return _xblockexpression;
  }
  
  private static <R extends Object> void recover(final R r, final Throwable ex, final CompletableFuture<R> result, final Function1<? super Throwable, ? extends CompletionStage<? extends R>> recovery) {
    boolean _notEquals = (!com.google.common.base.Objects.equal(ex, null));
    if (_notEquals) {
      CompletionStage<? extends R> recoverFut = null;
      try {
        CompletionStage<? extends R> _apply = recovery.apply(ex);
        recoverFut = _apply;
      } catch (final Throwable _t) {
        if (_t instanceof Throwable) {
          final Throwable t = (Throwable)_t;
          result.completeExceptionally(t);
          return;
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
      boolean _equals = com.google.common.base.Objects.equal(recoverFut, null);
      if (_equals) {
        NullPointerException _nullPointerException = new NullPointerException();
        result.completeExceptionally(_nullPointerException);
      } else {
        CompletableFutureExtensions.forwardTo(recoverFut, result);
      }
    } else {
      result.complete(r);
    }
  }
  
  /**
   * If the given future {@code fut} completes successfully, the future returned from this method will be
   * completed with the result value. Otherwise the provider {@code recovery} will be called to provide
   * a future and the result of this future will be used to complete the returned future. This also means
   * that if the provided recovery future was completed exceptionally, the failure will be forwarded to the
   * returned future.
   * @param fut the future that may fail (complete exceptionally). If it completes successfully, the result
   *  value will be used to complete the returned future
   * @param recovery provides a CompletionStage in case {@code fut} completes exceptionally. In this case the result
   *  (either value or exception) will be used to complete the future returned from the function. If this
   *  supplier provides a {@code null} reference, the returned future will be completed with a {@link NullPointerException}.
   *  If the supplier throws an exception, the returned future will be completed with this exception.
   * @return future that will either complete successfully, if {@code fut} completes successfully. If {@code fut}
   *   completes exceptionally, otherwise {@code recovery} will be called and the result of the provided CompletionStage
   *   will be forwarded to the returned future.
   */
  public static <R extends Object> CompletableFuture<R> recoverWith(final CompletableFuture<R> fut, final Function1<? super Throwable, ? extends CompletionStage<? extends R>> recovery) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Function1<? super Throwable, ? extends CompletionStage<? extends R>>>requireNonNull(recovery);
      final CompletableFuture<R> result = new CompletableFuture<R>();
      final BiConsumer<R, Throwable> _function = (R r, Throwable ex) -> {
        CompletableFutureExtensions.<R>recover(r, ex, result, recovery);
      };
      fut.whenComplete(_function);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> recoverWithAsync(final CompletableFuture<R> fut, final Function1<? super Throwable, ? extends CompletionStage<? extends R>> recovery) {
    ForkJoinPool _commonPool = ForkJoinPool.commonPool();
    return CompletableFutureExtensions.<R>recoverWithAsync(fut, _commonPool, recovery);
  }
  
  public static <R extends Object> CompletableFuture<R> recoverWithAsync(final CompletableFuture<R> fut, final Executor e, final Function1<? super Throwable, ? extends CompletionStage<? extends R>> recovery) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<CompletableFuture<R>>requireNonNull(fut);
      Objects.<Function1<? super Throwable, ? extends CompletionStage<? extends R>>>requireNonNull(recovery);
      final CompletableFuture<R> result = new CompletableFuture<R>();
      final BiConsumer<R, Throwable> _function = (R r, Throwable ex) -> {
        CompletableFutureExtensions.<R>recover(r, ex, result, recovery);
      };
      fut.whenCompleteAsync(_function, e);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
}
