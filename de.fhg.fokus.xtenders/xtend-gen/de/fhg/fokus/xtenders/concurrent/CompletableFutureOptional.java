package de.fhg.fokus.xtenders.concurrent;

import de.fhg.fokus.xtenders.concurrent.CompletableFutureExtensions;
import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;

@SuppressWarnings("all")
public class CompletableFutureOptional {
  /**
   * If handler provides {@code null} value, the returned future will be completed
   * exceptionally with a {@link NullPointerException}.
   * @throws NullPointerException if either {@code fut}, {@code handler} is null.
   */
  public static <T extends Object> CompletableFuture<T> recoverNotPresent(final CompletableFuture<T> fut, final Function0<? extends T> handler) throws NullPointerException {
    CompletableFuture<T> _xblockexpression = null;
    {
      Objects.<CompletableFuture<T>>requireNonNull(fut);
      Objects.<Function0<? extends T>>requireNonNull(handler);
      final Function1<T, T> _function = (T it) -> {
        T _xifexpression = null;
        boolean _equals = com.google.common.base.Objects.equal(it, null);
        if (_equals) {
          _xifexpression = handler.apply();
        } else {
          _xifexpression = it;
        }
        return _xifexpression;
      };
      _xblockexpression = CompletableFutureExtensions.<T, T>then(fut, _function);
    }
    return _xblockexpression;
  }
}
