package de.fhg.fokus.xtenders.concurrent;

import com.google.common.base.Objects;
import de.fhg.fokus.xtenders.concurrent.CompletableFutureExtensions;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

/**
 * The static methods of this class start asynchronous computation, such as the {@code async}, {@code asyncSupply},
 * and {@code asyncRun} methods.
 */
@SuppressWarnings("all")
public class AsyncCompute {
  /**
   * An instance of this class has to be provided by the function passed to
   * any of the {@code async} methods. Since this
   * Create instance using one of the following functions:
   * <ul>
   * 	<em>{@link #completeAsync()}</em>
   * 	<em>{@link #completedAllready()}</em>
   * 	<em>{@link #completeNow(Object)}</em>
   * 	<em>{@link #completeWith(CompletableFuture)}</em>
   * </ul>
   */
  public static class FutureCompletion<T extends Object> {
    FutureCompletion() {
    }
  }
  
  private static class NowFutureCompletion<T extends Object> extends AsyncCompute.FutureCompletion<T> {
    private final T value;
    
    NowFutureCompletion(final T t) {
      this.value = t;
    }
  }
  
  private static class FutureFutureCompletion<T extends Object> extends AsyncCompute.FutureCompletion<T> {
    private final CompletableFuture<? extends T> value;
    
    FutureFutureCompletion(final CompletableFuture<? extends T> f) {
      this.value = f;
    }
  }
  
  /**
   * Factory method to create a FutureCompletion instance that can be used
   * as a return value in a function passed to an async function. The created
   * FutureCompletion indicates, that the result future is completed asynchronously.
   * This means that the CompletedFuture passed into the function must be called
   * "manually". This can also be done asynchronously on a different thread.
   * @see #async(Function1)
   * @see #async(Executor, Function1)
   * @see #async(long, TimeUnit, Function1)
   * @see #async(long, TimeUnit, Executor, Function1)
   * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
   * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
   */
  public static <T extends Object> AsyncCompute.FutureCompletion<T> completeAsync() {
    return ((AsyncCompute.FutureCompletion<T>) ((AsyncCompute.FutureCompletion<?>) AsyncCompute.NO_OP_COMPLETION));
  }
  
  /**
   * Factory method to create a FutureCompletion instance that can be used
   * as a return value in a function passed to an async function.
   * TODO FURTHER DESCRIPTION
   * 
   * @see #async(Function1)
   * @see #async(Executor, Function1)
   * @see #async(long, TimeUnit, Function1)
   * @see #async(long, TimeUnit, Executor, Function1)
   * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
   * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
   */
  public static <T extends Object> AsyncCompute.FutureCompletion<T> completedAlready() {
    return ((AsyncCompute.FutureCompletion<T>) ((AsyncCompute.FutureCompletion<?>) AsyncCompute.NO_OP_COMPLETION));
  }
  
  /**
   * Factory method to create a FutureCompletion instance that can be used
   * as a return value in a function passed to an async function.
   * TODO FURTHER DESCRIPTION
   * 
   * @see #async(Function1)
   * @see #async(Executor, Function1)
   * @see #async(long, TimeUnit, Function1)
   * @see #async(long, TimeUnit, Executor, Function1)
   * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
   * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
   */
  public static <T extends Object> AsyncCompute.FutureCompletion<T> completeNow(final T t) {
    return new AsyncCompute.NowFutureCompletion<T>(t);
  }
  
  /**
   * Factory method to create a FutureCompletion instance that can be used
   * as a return value in a function passed to an async function.
   * TODO FURTHER DESCRIPTION, cancellation forward
   * 
   * @see #async(Function1)
   * @see #async(Executor, Function1)
   * @see #async(long, TimeUnit, Function1)
   * @see #async(long, TimeUnit, Executor, Function1)
   * @see #async(ScheduledExecutorService, long, TimeUnit, Executor, Function1)
   * @see #async(ScheduledExecutorService, long, TimeUnit, Function1)
   */
  public static <T extends Object> AsyncCompute.FutureCompletion<T> completeWith(final CompletableFuture<? extends T> t) {
    return new AsyncCompute.FutureFutureCompletion<T>(t);
  }
  
  private final static AsyncCompute.FutureCompletion<Object> NO_OP_COMPLETION = new AsyncCompute.FutureCompletion<Object>();
  
  public static <R extends Object> CompletableFuture<R> async(final Function1<? super CompletableFuture<R>, ? extends AsyncCompute.FutureCompletion<R>> runAsync) {
    ForkJoinPool _commonPool = ForkJoinPool.commonPool();
    return AsyncCompute.<R>async(_commonPool, runAsync);
  }
  
  public static <R extends Object> CompletableFuture<R> async(final Executor executor, final Function1<? super CompletableFuture<R>, ? extends AsyncCompute.FutureCompletion<R>> runAsync) {
    CompletableFuture<R> _xblockexpression = null;
    {
      final CompletableFuture<R> fut = new CompletableFuture<R>();
      final Runnable _function = () -> {
        try {
          AsyncCompute.FutureCompletion<R> _apply = runAsync.apply(fut);
          final AsyncCompute.FutureCompletion<R> result = _apply;
          boolean _matched = false;
          if (!_matched) {
            if (result instanceof AsyncCompute.NowFutureCompletion) {
              _matched=true;
              fut.complete(((AsyncCompute.NowFutureCompletion<R>)result).value);
            }
          }
          if (!_matched) {
            if (result instanceof AsyncCompute.FutureFutureCompletion) {
              _matched=true;
              final CompletableFuture<? extends R> resultFut = ((AsyncCompute.FutureFutureCompletion<R>)result).value;
              boolean _equals = Objects.equal(resultFut, null);
              if (_equals) {
                fut.complete(((R) null));
              } else {
                CompletableFutureExtensions.forwardTo(resultFut, fut);
                CompletableFutureExtensions.forwardCancellation(fut, resultFut);
              }
            }
          }
        } catch (final Throwable _t) {
          if (_t instanceof Throwable) {
            final Throwable t = (Throwable)_t;
            fut.completeExceptionally(t);
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        }
      };
      executor.execute(_function);
      _xblockexpression = fut;
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> async(final long timeout, final TimeUnit unit, final Function1<? super CompletableFuture<R>, ? extends AsyncCompute.FutureCompletion<R>> runAsync) {
    CompletableFuture<R> _xblockexpression = null;
    {
      final CompletableFuture<R> fut = AsyncCompute.<R>async(runAsync);
      _xblockexpression = CompletableFutureExtensions.<R>cancelOnTimeout(fut, timeout, unit);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> async(final long timeout, final TimeUnit unit, final Executor executor, final Function1<? super CompletableFuture<R>, ? extends AsyncCompute.FutureCompletion<R>> runAsync) {
    CompletableFuture<R> _xblockexpression = null;
    {
      final CompletableFuture<R> fut = AsyncCompute.<R>async(executor, runAsync);
      _xblockexpression = CompletableFutureExtensions.<R>cancelOnTimeout(fut, timeout, unit);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> async(final ScheduledExecutorService scheduler, final long timeout, final TimeUnit unit, final Function1<? super CompletableFuture<R>, ? extends AsyncCompute.FutureCompletion<R>> runAsync) {
    CompletableFuture<R> _xblockexpression = null;
    {
      final CompletableFuture<R> fut = AsyncCompute.<R>async(runAsync);
      _xblockexpression = CompletableFutureExtensions.<R>cancelOnTimeout(fut, scheduler, timeout, unit);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> async(final ScheduledExecutorService scheduler, final long timeout, final TimeUnit unit, final Executor executor, final Function1<? super CompletableFuture<R>, ? extends AsyncCompute.FutureCompletion<R>> runAsync) {
    CompletableFuture<R> _xblockexpression = null;
    {
      final CompletableFuture<R> fut = AsyncCompute.<R>async(executor, runAsync);
      _xblockexpression = CompletableFutureExtensions.<R>cancelOnTimeout(fut, scheduler, timeout, unit);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> asyncSupply(final Function1<? super CompletableFuture<?>, ? extends R> runAsync) {
    ForkJoinPool _commonPool = ForkJoinPool.commonPool();
    return AsyncCompute.<R>asyncSupply(_commonPool, runAsync);
  }
  
  public static <R extends Object> CompletableFuture<R> asyncSupply(final Executor executor, final Function1<? super CompletableFuture<?>, ? extends R> runAsync) {
    CompletableFuture<R> _xblockexpression = null;
    {
      final CompletableFuture<R> fut = new CompletableFuture<R>();
      final Runnable _function = () -> {
        try {
          final R result = runAsync.apply(fut);
          fut.complete(result);
        } catch (final Throwable _t) {
          if (_t instanceof Throwable) {
            final Throwable t = (Throwable)_t;
            fut.completeExceptionally(t);
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        }
      };
      executor.execute(_function);
      _xblockexpression = fut;
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> asyncSupply(final long timeout, final TimeUnit unit, final Function1<? super CompletableFuture<?>, ? extends R> runAsync) {
    CompletableFuture<R> _xblockexpression = null;
    {
      final CompletableFuture<R> fut = AsyncCompute.<R>asyncSupply(runAsync);
      _xblockexpression = CompletableFutureExtensions.<R>cancelOnTimeout(fut, timeout, unit);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> asyncSupply(final ScheduledExecutorService scheduler, final long timeout, final TimeUnit unit, final Function1<? super CompletableFuture<?>, ? extends R> runAsync) {
    CompletableFuture<R> _xblockexpression = null;
    {
      final CompletableFuture<R> fut = AsyncCompute.<R>asyncSupply(runAsync);
      _xblockexpression = CompletableFutureExtensions.<R>cancelOnTimeout(fut, scheduler, timeout, unit);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> asyncSupply(final long timeout, final TimeUnit unit, final Executor executor, final Function1<? super CompletableFuture<?>, ? extends R> runAsync) {
    CompletableFuture<R> _xblockexpression = null;
    {
      final CompletableFuture<R> fut = AsyncCompute.<R>asyncSupply(executor, runAsync);
      _xblockexpression = CompletableFutureExtensions.<R>cancelOnTimeout(fut, timeout, unit);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<R> asyncSupply(final ScheduledExecutorService scheduler, final long timeout, final TimeUnit unit, final Executor executor, final Function1<? super CompletableFuture<?>, ? extends R> runAsync) {
    CompletableFuture<R> _xblockexpression = null;
    {
      final CompletableFuture<R> fut = AsyncCompute.<R>asyncSupply(executor, runAsync);
      _xblockexpression = CompletableFutureExtensions.<R>cancelOnTimeout(fut, scheduler, timeout, unit);
    }
    return _xblockexpression;
  }
  
  /**
   * Calls {@link #asyncRun(Executor,Function1) asyncRun(Executor,(CompletableFuture<?>)=>void)} with
   * the common {@code ForkJoinPool} as the executor.
   */
  public static <R extends Object> CompletableFuture<?> asyncRun(final Procedure1<? super CompletableFuture<?>> runAsync) {
    ForkJoinPool _commonPool = ForkJoinPool.commonPool();
    return AsyncCompute.<Object>asyncRun(_commonPool, runAsync);
  }
  
  public static <R extends Object> CompletableFuture<?> asyncRun(final Executor executor, final Procedure1<? super CompletableFuture<?>> runAsync) {
    CompletableFuture<Object> _xblockexpression = null;
    {
      java.util.Objects.<Executor>requireNonNull(executor);
      java.util.Objects.<Procedure1<? super CompletableFuture<?>>>requireNonNull(runAsync);
      final CompletableFuture<Object> fut = new CompletableFuture<Object>();
      final Runnable _function = () -> {
        try {
          boolean _isCancelled = fut.isCancelled();
          if (_isCancelled) {
            return;
          }
          runAsync.apply(fut);
          fut.complete(null);
        } catch (final Throwable _t) {
          if (_t instanceof Throwable) {
            final Throwable t = (Throwable)_t;
            fut.completeExceptionally(t);
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        }
      };
      executor.execute(_function);
      _xblockexpression = fut;
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<?> asyncRun(final long timeout, final TimeUnit unit, final Procedure1<? super CompletableFuture<?>> runAsync) {
    ForkJoinPool _commonPool = ForkJoinPool.commonPool();
    return AsyncCompute.<Object>asyncRun(timeout, unit, _commonPool, runAsync);
  }
  
  public static <R extends Object> CompletableFuture<?> asyncRun(final long timeout, final TimeUnit unit, final Executor executor, final Procedure1<? super CompletableFuture<?>> runAsync) {
    CompletableFuture<?> _xblockexpression = null;
    {
      final CompletableFuture<?> fut = AsyncCompute.<Object>asyncRun(executor, runAsync);
      _xblockexpression = CompletableFutureExtensions.cancelOnTimeout(fut, timeout, unit);
    }
    return _xblockexpression;
  }
  
  public static <R extends Object> CompletableFuture<?> asyncRun(final ScheduledExecutorService scheduler, final long timeout, final TimeUnit unit, final Executor executor, final Procedure1<? super CompletableFuture<?>> runAsync) {
    CompletableFuture<?> _xblockexpression = null;
    {
      final CompletableFuture<?> fut = AsyncCompute.<Object>asyncRun(executor, runAsync);
      _xblockexpression = CompletableFutureExtensions.cancelOnTimeout(fut, scheduler, timeout, unit);
    }
    return _xblockexpression;
  }
}
