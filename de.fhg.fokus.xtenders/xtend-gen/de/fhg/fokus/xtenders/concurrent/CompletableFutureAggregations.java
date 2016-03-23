package de.fhg.fokus.xtenders.concurrent;

import de.fhg.fokus.xtenders.concurrent.CompletableFutureExtensions;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import java.util.function.Consumer;
import java.util.function.Function;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.Functions.Function3;
import org.eclipse.xtext.xbase.lib.Functions.Function4;
import org.eclipse.xtext.xbase.lib.Functions.Function5;
import org.eclipse.xtext.xbase.lib.Functions.Function6;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class CompletableFutureAggregations {
  public static void cancelAll(final CompletableFuture<?>... toCancel) {
    Objects.<CompletableFuture<?>[]>requireNonNull(toCancel);
    final Consumer<CompletableFuture<?>> _function = (CompletableFuture<?> it) -> {
      if (it!=null) {
        CompletableFutureExtensions.cancel(it);
      }
    };
    ((List<CompletableFuture<?>>)Conversions.doWrapArray(toCancel)).forEach(_function);
  }
  
  public static <U extends Object, V extends Object, R extends Object> CompletableFuture<R> allCompleted(final CompletableFuture<U> a, final CompletableFuture<V> b, final Function2<? super U, ? super V, ? extends R> onSuccess) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Function2<? super U, ? super V, ? extends R>>requireNonNull(onSuccess);
      CompletableFuture<Void> _allOf = CompletableFuture.allOf(a, b);
      final Function<Void, R> _function = (Void it) -> {
        try {
          U _get = a.get();
          V _get_1 = b.get();
          return onSuccess.apply(_get, _get_1);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      _xblockexpression = _allOf.<R>thenApply(_function);
    }
    return _xblockexpression;
  }
  
  public static <U extends Object, V extends Object, W extends Object, R extends Object> CompletableFuture<R> allCompleted(final CompletableFuture<U> a, final CompletableFuture<V> b, final CompletableFuture<W> c, final Function3<? super U, ? super V, ? super W, ? extends R> onSuccess) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Function3<? super U, ? super V, ? super W, ? extends R>>requireNonNull(onSuccess);
      CompletableFuture<Void> _allOf = CompletableFuture.allOf(a, b, c);
      final Function<Void, R> _function = (Void it) -> {
        try {
          U _get = a.get();
          V _get_1 = b.get();
          W _get_2 = c.get();
          return onSuccess.apply(_get, _get_1, _get_2);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      _xblockexpression = _allOf.<R>thenApply(_function);
    }
    return _xblockexpression;
  }
  
  public static <U extends Object, V extends Object, W extends Object, X extends Object, R extends Object> CompletableFuture<R> allCompleted(final CompletableFuture<U> a, final CompletableFuture<V> b, final CompletableFuture<W> c, final CompletableFuture<X> d, final Function4<? super U, ? super V, ? super W, ? super X, ? extends R> onSuccess) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Function4<? super U, ? super V, ? super W, ? super X, ? extends R>>requireNonNull(onSuccess);
      CompletableFuture<Void> _allOf = CompletableFuture.allOf(a, b, c, d);
      final Function<Void, R> _function = (Void it) -> {
        try {
          U _get = a.get();
          V _get_1 = b.get();
          W _get_2 = c.get();
          X _get_3 = d.get();
          return onSuccess.apply(_get, _get_1, _get_2, _get_3);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      _xblockexpression = _allOf.<R>thenApply(_function);
    }
    return _xblockexpression;
  }
  
  public static <U extends Object, V extends Object, W extends Object, X extends Object, Y extends Object, R extends Object> CompletableFuture<R> allCompleted(final CompletableFuture<U> a, final CompletableFuture<V> b, final CompletableFuture<W> c, final CompletableFuture<X> d, final CompletableFuture<Y> e, final Function5<? super U, ? super V, ? super W, ? super X, ? super Y, ? extends R> onSuccess) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Function5<? super U, ? super V, ? super W, ? super X, ? super Y, ? extends R>>requireNonNull(onSuccess);
      CompletableFuture<Void> _allOf = CompletableFuture.allOf(a, b, c, d, e);
      final Function<Void, R> _function = (Void it) -> {
        try {
          U _get = a.get();
          V _get_1 = b.get();
          W _get_2 = c.get();
          X _get_3 = d.get();
          Y _get_4 = e.get();
          return onSuccess.apply(_get, _get_1, _get_2, _get_3, _get_4);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      _xblockexpression = _allOf.<R>thenApply(_function);
    }
    return _xblockexpression;
  }
  
  public static <U extends Object, V extends Object, W extends Object, X extends Object, Y extends Object, Z extends Object, R extends Object> CompletableFuture<R> allCompleted(final CompletableFuture<U> a, final CompletableFuture<V> b, final CompletableFuture<W> c, final CompletableFuture<X> d, final CompletableFuture<Y> e, final CompletableFuture<Z> f, final Function6<? super U, ? super V, ? super W, ? super X, ? super Y, ? super Z, ? extends R> onSuccess) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Function6<? super U, ? super V, ? super W, ? super X, ? super Y, ? super Z, ? extends R>>requireNonNull(onSuccess);
      CompletableFuture<Void> _allOf = CompletableFuture.allOf(a, b, c, d, e, f);
      final Function<Void, R> _function = (Void it) -> {
        try {
          U _get = a.get();
          V _get_1 = b.get();
          W _get_2 = c.get();
          X _get_3 = d.get();
          Y _get_4 = e.get();
          Z _get_5 = f.get();
          return onSuccess.apply(_get, _get_1, _get_2, _get_3, _get_4, _get_5);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      _xblockexpression = _allOf.<R>thenApply(_function);
    }
    return _xblockexpression;
  }
  
  public static <U extends Object, V extends Object, R extends Object> CompletableFuture<R> allCompletedCancelOnError(final CompletableFuture<U> a, final CompletableFuture<V> b, final Function2<? super U, ? super V, ? extends R> onSuccess) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Function2<? super U, ? super V, ? extends R>>requireNonNull(onSuccess);
      CompletableFuture<Void> _allOf = CompletableFuture.allOf(a, b);
      final Function<Void, R> _function = (Void it) -> {
        try {
          U _get = a.get();
          V _get_1 = b.get();
          return onSuccess.apply(_get, _get_1);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      final CompletableFuture<R> result = _allOf.<R>thenApply(_function);
      final Procedure1<Throwable> _function_1 = (Throwable it) -> {
        CompletableFutureAggregations.cancelAll(a, b);
      };
      _xblockexpression = CompletableFutureExtensions.<R>whenException(result, _function_1);
    }
    return _xblockexpression;
  }
  
  public static <U extends Object, V extends Object, W extends Object, R extends Object> CompletableFuture<R> allCompletedCancelOnError(final CompletableFuture<U> a, final CompletableFuture<V> b, final CompletableFuture<W> c, final Function3<? super U, ? super V, ? super W, ? extends R> onSuccess) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Function3<? super U, ? super V, ? super W, ? extends R>>requireNonNull(onSuccess);
      CompletableFuture<Void> _allOf = CompletableFuture.allOf(a, b, c);
      final Function<Void, R> _function = (Void it) -> {
        try {
          U _get = a.get();
          V _get_1 = b.get();
          W _get_2 = c.get();
          return onSuccess.apply(_get, _get_1, _get_2);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      final CompletableFuture<R> result = _allOf.<R>thenApply(_function);
      final Procedure1<Throwable> _function_1 = (Throwable it) -> {
        CompletableFutureAggregations.cancelAll(a, b, c);
      };
      _xblockexpression = CompletableFutureExtensions.<R>whenException(result, _function_1);
    }
    return _xblockexpression;
  }
  
  public static <U extends Object, V extends Object, W extends Object, X extends Object, R extends Object> CompletableFuture<R> allCompletedCancelOnError(final CompletableFuture<U> a, final CompletableFuture<V> b, final CompletableFuture<W> c, final CompletableFuture<X> d, final Function4<? super U, ? super V, ? super W, ? super X, ? extends R> onSuccess) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Function4<? super U, ? super V, ? super W, ? super X, ? extends R>>requireNonNull(onSuccess);
      CompletableFuture<Void> _allOf = CompletableFuture.allOf(a, b, c, d);
      final Function<Void, R> _function = (Void it) -> {
        try {
          U _get = a.get();
          V _get_1 = b.get();
          W _get_2 = c.get();
          X _get_3 = d.get();
          return onSuccess.apply(_get, _get_1, _get_2, _get_3);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      final CompletableFuture<R> result = _allOf.<R>thenApply(_function);
      final Procedure1<Throwable> _function_1 = (Throwable it) -> {
        CompletableFutureAggregations.cancelAll(a, b, c, d);
      };
      _xblockexpression = CompletableFutureExtensions.<R>whenException(result, _function_1);
    }
    return _xblockexpression;
  }
  
  public static <U extends Object, V extends Object, W extends Object, X extends Object, Y extends Object, R extends Object> CompletableFuture<R> allCompletedCancelOnError(final CompletableFuture<U> a, final CompletableFuture<V> b, final CompletableFuture<W> c, final CompletableFuture<X> d, final CompletableFuture<Y> e, final Function5<? super U, ? super V, ? super W, ? super X, ? super Y, ? extends R> onSuccess) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Function5<? super U, ? super V, ? super W, ? super X, ? super Y, ? extends R>>requireNonNull(onSuccess);
      CompletableFuture<Void> _allOf = CompletableFuture.allOf(a, b, c, d, e);
      final Function<Void, R> _function = (Void it) -> {
        try {
          U _get = a.get();
          V _get_1 = b.get();
          W _get_2 = c.get();
          X _get_3 = d.get();
          Y _get_4 = e.get();
          return onSuccess.apply(_get, _get_1, _get_2, _get_3, _get_4);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      final CompletableFuture<R> result = _allOf.<R>thenApply(_function);
      final Procedure1<Throwable> _function_1 = (Throwable it) -> {
        CompletableFutureAggregations.cancelAll(a, b, c, d, e);
      };
      _xblockexpression = CompletableFutureExtensions.<R>whenException(result, _function_1);
    }
    return _xblockexpression;
  }
  
  public static <U extends Object, V extends Object, W extends Object, X extends Object, Y extends Object, Z extends Object, R extends Object> CompletableFuture<R> allCompletedCancelOnError(final CompletableFuture<U> a, final CompletableFuture<V> b, final CompletableFuture<W> c, final CompletableFuture<X> d, final CompletableFuture<Y> e, final CompletableFuture<Z> f, final Function6<? super U, ? super V, ? super W, ? super X, ? super Y, ? super Z, ? extends R> onSuccess) {
    CompletableFuture<R> _xblockexpression = null;
    {
      Objects.<Function6<? super U, ? super V, ? super W, ? super X, ? super Y, ? super Z, ? extends R>>requireNonNull(onSuccess);
      CompletableFuture<Void> _allOf = CompletableFuture.allOf(a, b, c, d, e, f);
      final Function<Void, R> _function = (Void it) -> {
        try {
          U _get = a.get();
          V _get_1 = b.get();
          W _get_2 = c.get();
          X _get_3 = d.get();
          Y _get_4 = e.get();
          Z _get_5 = f.get();
          return onSuccess.apply(_get, _get_1, _get_2, _get_3, _get_4, _get_5);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      final CompletableFuture<R> result = _allOf.<R>thenApply(_function);
      final Procedure1<Throwable> _function_1 = (Throwable it) -> {
        CompletableFutureAggregations.cancelAll(a, b, c, d, e);
      };
      _xblockexpression = CompletableFutureExtensions.<R>whenException(result, _function_1);
    }
    return _xblockexpression;
  }
  
  /**
   * The returned future will hold the result of the first future found to be complete.
   * Be aware that the first completed may be completed exceptionally, or was cancelled.
   * If the returned future is cancelled, all given futures are cancelled with it.
   * When the result is available, all futures are being canceled, because their result
   * is not needed.<br>
   * Due to the sequential traversal of the {@code futures} the result may not be from
   * the actual fastest result, but it is the one found the fastest.
   * 
   * @param futures are checked for a result. The first future found to be completed completes
   *  the returned future. Must not be {@code null}. If any field of the array is {@code null}
   *  the field is skipped.
   * @return Future holding the result of the first of the given {@code futures}
   * @throws NullPointerException if {@code futures} array is {@code null}
   */
  public static <V extends Object> CompletableFuture<V> firstAndCancelOthers(final CompletableFuture<? extends V>... futures) {
    CompletableFuture<V> _xblockexpression = null;
    {
      Objects.<CompletableFuture<? extends V>[]>requireNonNull(futures);
      final CompletableFuture<V> result = CompletableFutureAggregations.<V>first(futures);
      final Procedure1<V> _function = (V it) -> {
        final Consumer<CompletableFuture<? extends V>> _function_1 = (CompletableFuture<? extends V> it_1) -> {
          if (it_1!=null) {
            CompletableFutureExtensions.cancel(it_1);
          }
        };
        ((List<CompletableFuture<? extends V>>)Conversions.doWrapArray(futures)).forEach(_function_1);
      };
      CompletableFutureExtensions.<V>then(result, _function);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
  
  /**
   * The returned future will hold the value of the first future found to be complete.
   * Be aware that the first completed may be completed exceptionally, or was cancelled.
   * If the returned future is cancelled, all given futures are cancelled with it.
   * 
   * @param futures are checked for a result. The first future found to be completed completes
   *  the returned future. Must not be {@code null}. If any field of the array is {@code null}
   *  this field is skipped.
   * @return Future holding the result of the first of the given {@code futures}
   * @throws NullPointerException if {@code futures} array is {@code null}
   */
  public static <V extends Object> CompletableFuture<V> first(final CompletableFuture<? extends V>... futures) {
    CompletableFuture<V> _xblockexpression = null;
    {
      Objects.<CompletableFuture<? extends V>[]>requireNonNull(futures);
      final CompletableFuture<V> result = new CompletableFuture<V>();
      final Consumer<CompletableFuture<? extends V>> _function = (CompletableFuture<? extends V> it) -> {
        boolean _notEquals = (!com.google.common.base.Objects.equal(it, null));
        if (_notEquals) {
          CompletableFutureExtensions.forwardTo(it, result);
          CompletableFutureExtensions.forwardCancellation(result, it);
        }
      };
      ((List<CompletableFuture<? extends V>>)Conversions.doWrapArray(futures)).forEach(_function);
      _xblockexpression = result;
    }
    return _xblockexpression;
  }
}
