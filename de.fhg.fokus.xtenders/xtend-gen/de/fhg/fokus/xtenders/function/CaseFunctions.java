package de.fhg.fokus.xtenders.function;

import com.google.common.annotations.Beta;
import com.google.common.base.Objects;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.function.Predicate;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;

@Beta
@SuppressWarnings("all")
public class CaseFunctions {
  public static abstract class CaseResult<T extends Object> {
    private CaseResult() {
    }
    
    public abstract boolean isMatch();
    
    public abstract T result() throws NoSuchElementException;
    
    public abstract CaseFunctions.CaseResult<T> orElse(final Function0<? extends CaseFunctions.CaseResult<T>> provider);
    
    public abstract T orElseResult(final Function0<? extends T> provider);
    
    public abstract T orElseResult(final T result);
    
    public static <T extends Object> CaseFunctions.CaseResult<T> match(final T t) {
      return new CaseFunctions.Match<T>(t);
    }
    
    public static <T extends Object> CaseFunctions.CaseResult<T> noMatch() {
      return ((CaseFunctions.CaseResult<T>) CaseFunctions.NoMatch.INSTANCE);
    }
  }
  
  private static final class NoMatch<T extends Object> extends CaseFunctions.CaseResult<T> {
    private final static CaseFunctions.CaseResult<?> INSTANCE = new CaseFunctions.NoMatch<Object>();
    
    @Override
    public boolean isMatch() {
      return false;
    }
    
    @Override
    public T result() throws NoSuchElementException {
      throw new NoSuchElementException();
    }
    
    @Override
    public CaseFunctions.CaseResult<T> orElse(final Function0<? extends CaseFunctions.CaseResult<T>> provider) {
      return provider.apply();
    }
    
    @Override
    public T orElseResult(final Function0<? extends T> provider) {
      return provider.apply();
    }
    
    @Override
    public T orElseResult(final T result) {
      return result;
    }
  }
  
  private static final class Match<T extends Object> extends CaseFunctions.CaseResult<T> {
    private final T result;
    
    private Match(final T t) {
      this.result = this.result;
    }
    
    @Override
    public boolean isMatch() {
      return true;
    }
    
    @Override
    public T result() throws NoSuchElementException {
      return this.result;
    }
    
    @Override
    public CaseFunctions.CaseResult<T> orElse(final Function0<? extends CaseFunctions.CaseResult<T>> provider) {
      return this;
    }
    
    @Override
    public T orElseResult(final Function0<? extends T> provider) {
      return this.result;
    }
    
    @Override
    public T orElseResult(final T t) {
      return this.result;
    }
  }
  
  public static <I extends Object, O extends Object, T extends Object> Function1<? super I, ? extends CaseFunctions.CaseResult<O>> caseIs(final Function1<? super I, ? extends CaseFunctions.CaseResult<O>> switcher, final Class<T> clazz, final Function1<? super T, ? extends O> handler) {
    final Function1<I, CaseFunctions.CaseResult<O>> _function = (I it) -> {
      CaseFunctions.CaseResult<O> _apply = switcher.apply(it);
      final Function0<CaseFunctions.CaseResult<O>> _function_1 = () -> {
        CaseFunctions.CaseResult<O> _xifexpression = null;
        boolean _isInstance = clazz.isInstance(it);
        if (_isInstance) {
          O _apply_1 = handler.apply(((T) it));
          _xifexpression = CaseFunctions.CaseResult.<O>match(_apply_1);
        } else {
          _xifexpression = CaseFunctions.CaseResult.<O>noMatch();
        }
        return _xifexpression;
      };
      return _apply.orElse(_function_1);
    };
    return _function;
  }
  
  public static <I extends Object, O extends Object> Function1<? super I, ? extends CaseFunctions.CaseResult<O>> switcher() {
    final Function1<I, CaseFunctions.CaseResult<O>> _function = (I it) -> {
      return CaseFunctions.CaseResult.<O>noMatch();
    };
    return _function;
  }
  
  public static <I extends Object, O extends Object> Function1<? super I, ? extends CaseFunctions.CaseResult<O>> caseNull(final Function1<? super I, ? extends CaseFunctions.CaseResult<O>> switcher, final Function0<? extends O> handler) {
    final Function1<I, CaseFunctions.CaseResult<O>> _function = (I it) -> {
      CaseFunctions.CaseResult<O> _apply = switcher.apply(it);
      final Function0<CaseFunctions.CaseResult<O>> _function_1 = () -> {
        CaseFunctions.CaseResult<O> _xifexpression = null;
        boolean _equals = Objects.equal(it, null);
        if (_equals) {
          O _apply_1 = handler.apply();
          _xifexpression = CaseFunctions.CaseResult.<O>match(_apply_1);
        } else {
          _xifexpression = CaseFunctions.CaseResult.<O>noMatch();
        }
        return _xifexpression;
      };
      return _apply.orElse(_function_1);
    };
    return _function;
  }
  
  public static <I extends Object, O extends Object, T extends Object> Function1<? super I, ? extends CaseFunctions.CaseResult<O>> caseObj(final Function1<? super I, ? extends CaseFunctions.CaseResult<O>> switcher, final Function1<? super I, ? extends Optional<T>> extractor, final Function1<? super T, ? extends O> handler) {
    final Function1<I, CaseFunctions.CaseResult<O>> _function = (I it) -> {
      CaseFunctions.CaseResult<O> _apply = switcher.apply(it);
      final Function0<CaseFunctions.CaseResult<O>> _function_1 = () -> {
        CaseFunctions.CaseResult<O> _xblockexpression = null;
        {
          final Optional<T> extracted = extractor.apply(it);
          CaseFunctions.CaseResult<O> _xifexpression = null;
          boolean _isPresent = extracted.isPresent();
          if (_isPresent) {
            T _get = extracted.get();
            O _apply_1 = handler.apply(_get);
            _xifexpression = CaseFunctions.CaseResult.<O>match(_apply_1);
          } else {
            _xifexpression = CaseFunctions.CaseResult.<O>noMatch();
          }
          _xblockexpression = _xifexpression;
        }
        return _xblockexpression;
      };
      return _apply.orElse(_function_1);
    };
    return _function;
  }
  
  public static <I extends Object, O extends Object> Function1<? super I, ? extends CaseFunctions.CaseResult<O>> caseIf(final Function1<? super I, ? extends CaseFunctions.CaseResult<O>> switcher, final Predicate<I> test, final Function1<? super I, ? extends O> handler) {
    final Function1<I, CaseFunctions.CaseResult<O>> _function = (I it) -> {
      CaseFunctions.CaseResult<O> _apply = switcher.apply(it);
      final Function0<CaseFunctions.CaseResult<O>> _function_1 = () -> {
        CaseFunctions.CaseResult<O> _xifexpression = null;
        boolean _test = test.test(it);
        if (_test) {
          O _apply_1 = handler.apply(it);
          _xifexpression = CaseFunctions.CaseResult.<O>match(_apply_1);
        } else {
          _xifexpression = CaseFunctions.CaseResult.<O>noMatch();
        }
        return _xifexpression;
      };
      return _apply.orElse(_function_1);
    };
    return _function;
  }
  
  public static <I extends Optional<T>, T extends Object, O extends Object> Function1<? super I, ? extends CaseFunctions.CaseResult<O>> casePresent(final Function1<? super I, ? extends CaseFunctions.CaseResult<O>> switcher, final Function1<? super T, ? extends O> handler) {
    final Function1<I, CaseFunctions.CaseResult<O>> _function = (I it) -> {
      CaseFunctions.CaseResult<O> _apply = switcher.apply(it);
      final Function0<CaseFunctions.CaseResult<O>> _function_1 = () -> {
        CaseFunctions.CaseResult<O> _xifexpression = null;
        boolean _isPresent = it.isPresent();
        if (_isPresent) {
          T _get = it.get();
          O _apply_1 = handler.apply(_get);
          _xifexpression = CaseFunctions.CaseResult.<O>match(_apply_1);
        } else {
          _xifexpression = CaseFunctions.CaseResult.<O>noMatch();
        }
        return _xifexpression;
      };
      return _apply.orElse(_function_1);
    };
    return _function;
  }
  
  public static <I extends Optional<T>, T extends Object, O extends Object> Function1<? super I, ? extends CaseFunctions.CaseResult<O>> casePresent(final Function1<? super I, ? extends CaseFunctions.CaseResult<O>> switcher, final Predicate<T> test, final Function1<? super T, ? extends O> handler) {
    final Function1<I, CaseFunctions.CaseResult<O>> _function = (I it) -> {
      CaseFunctions.CaseResult<O> _apply = switcher.apply(it);
      final Function0<CaseFunctions.CaseResult<O>> _function_1 = () -> {
        CaseFunctions.CaseResult<O> _xblockexpression = null;
        {
          boolean _isPresent = it.isPresent();
          boolean _not = (!_isPresent);
          if (_not) {
            return CaseFunctions.CaseResult.<O>noMatch();
          }
          final T optVal = it.get();
          CaseFunctions.CaseResult<O> _xifexpression = null;
          boolean _test = test.test(optVal);
          if (_test) {
            O _apply_1 = handler.apply(optVal);
            _xifexpression = CaseFunctions.CaseResult.<O>match(_apply_1);
          } else {
            _xifexpression = CaseFunctions.CaseResult.<O>noMatch();
          }
          _xblockexpression = _xifexpression;
        }
        return _xblockexpression;
      };
      return _apply.orElse(_function_1);
    };
    return _function;
  }
  
  public static <I extends Object, O extends Object, T extends Object> Function1<? super I, ? extends O> otherwise(final Function1<? super I, ? extends CaseFunctions.CaseResult<O>> switcher, final Function1<? super I, ? extends O> handler) {
    final Function1<I, O> _function = (I it) -> {
      CaseFunctions.CaseResult<O> _apply = switcher.apply(it);
      final Function0<O> _function_1 = () -> {
        return handler.apply(it);
      };
      return _apply.orElseResult(_function_1);
    };
    return _function;
  }
  
  public static <I extends Object, O extends Object> Function1<? super I, ? extends O> otherwise(final Function1<? super I, ? extends CaseFunctions.CaseResult<O>> switcher, final O altResult) {
    final Function1<I, O> _function = (I it) -> {
      CaseFunctions.CaseResult<O> _apply = switcher.apply(it);
      return _apply.orElseResult(altResult);
    };
    return _function;
  }
}
