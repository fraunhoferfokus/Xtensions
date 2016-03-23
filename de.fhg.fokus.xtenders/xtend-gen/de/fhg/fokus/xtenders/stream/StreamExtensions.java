package de.fhg.fokus.xtenders.stream;

import de.fhg.fokus.xtenders.stream.IntRangeSpliterator;
import de.fhg.fokus.xtenders.string.StringMatchExtensions;
import de.fhg.fokus.xtenders.string.StringSplitExtensions;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.Spliterator;
import java.util.Spliterators;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.function.Supplier;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collector;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;
import java.util.stream.StreamSupport;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.eclipse.xtext.xbase.lib.Pair;

@SuppressWarnings("all")
public class StreamExtensions {
  /**
   * Creates a {@link Stream} instance for processing the elements
   * of the Iterable {@code it}.<br/>
   * If the given {@link Iterable} is instance of {@link Collection}, the
   * {@link Collection#stream() stream} method of the Collection interface will
   * be called. Otherwise uses {@link StreamSupport} to create a Stream with the
   * Spliterator created using {@link Iterable#spliterator()}.
   * @param Iterable from which the returned Stream is created
   * @return Stream to process all elements of the given Iterator {@code it}.
   */
  public static <T extends Object> Stream<T> stream(final Iterable<T> it) {
    Stream _xblockexpression = null;
    {
      Objects.<Iterable<T>>requireNonNull(it);
      Stream _xifexpression = null;
      if ((it instanceof Collection)) {
        _xifexpression = ((Collection)it).stream();
      } else {
        Spliterator<T> _spliterator = it.spliterator();
        _xifexpression = StreamSupport.<T>stream(_spliterator, false);
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  /**
   * Creates a parallel {@link Stream} instance for processing the elements
   * of the Iterable {@code it}.<br/>
   * If the given {@link Iterable} is instance of {@link Collection}, the
   * {@link Collection#parallelStream() parallelStream} method of the Collection interface will
   * be called. Otherwise uses {@link StreamSupport} to create the parallel Stream with the
   * Spliterator created using {@link Iterable#spliterator()}.
   * @param Iterable from which the returned Stream is created
   * @return parallel Stream to process all elements of the given Iterator {@code it}.
   */
  public static <T extends Object> Stream<T> parallelStream(final Iterable<T> it) {
    Stream _xblockexpression = null;
    {
      Objects.<Iterable<T>>requireNonNull(it);
      Stream _xifexpression = null;
      if ((it instanceof Collection)) {
        _xifexpression = ((Collection)it).parallelStream();
      } else {
        Spliterator<T> _spliterator = it.spliterator();
        _xifexpression = StreamSupport.<T>stream(_spliterator, true);
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  /**
   * Creates an {@link IntStream} for processing of all integers of the
   * given {@code range}.
   * @param range The source providing the elements to the returned IntStream
   * @return stream of all integers defined by the range
   */
  public static IntStream intStream(final IntegerRange range) {
    IntRangeSpliterator _intRangeSpliterator = new IntRangeSpliterator(range);
    return StreamSupport.intStream(_intRangeSpliterator, false);
  }
  
  /**
   * Creates a parallel {@link IntStream} for processing of all integers of the
   * given {@code range}.
   * @param range The source providing the elements to the returned IntStream
   * @return parallel IntStream of all integers defined by the range
   */
  public static IntStream parallelIntStream(final IntegerRange range) {
    IntRangeSpliterator _intRangeSpliterator = new IntRangeSpliterator(range);
    return StreamSupport.intStream(_intRangeSpliterator, true);
  }
  
  public static <T extends Object, U extends Object> Stream<U> filter(final Stream<T> input, final Class<? extends U> clazz) {
    Stream<U> _xblockexpression = null;
    {
      Objects.<Stream<T>>requireNonNull(input);
      Objects.<Class<? extends U>>requireNonNull(clazz);
      final Predicate<T> _function = (T it) -> {
        return clazz.isInstance(it);
      };
      Stream<T> _filter = input.filter(_function);
      _xblockexpression = ((Stream<U>) _filter);
    }
    return _xblockexpression;
  }
  
  public static <T extends Object> Stream<T> filterNull(final Stream<T> stream) {
    Stream<T> _xblockexpression = null;
    {
      Objects.<Stream<T>>requireNonNull(stream);
      final Predicate<T> _function = (T it) -> {
        return (!com.google.common.base.Objects.equal(it, null));
      };
      _xblockexpression = stream.filter(_function);
    }
    return _xblockexpression;
  }
  
  public static <T extends Object> List<T> toList(final Stream<T> stream) {
    Collector<T, ?, List<T>> _list = Collectors.<T>toList();
    return stream.collect(_list);
  }
  
  public static <T extends Object> Set<T> toSet(final Stream<T> stream) {
    Collector<T, ?, Set<T>> _set = Collectors.<T>toSet();
    return stream.collect(_set);
  }
  
  public static <T extends Object, C extends Collection<T>> C toCollection(final Stream<T> stream, final Supplier<C> collectionFactory) {
    Collector<T, ?, C> _collection = Collectors.<T, C>toCollection(collectionFactory);
    return stream.collect(_collection);
  }
  
  public static String join(final Stream<? extends CharSequence> stream) {
    Collector<CharSequence, ?, String> _joining = Collectors.joining();
    return stream.collect(_joining);
  }
  
  public static String join(final Stream<? extends CharSequence> stream, final CharSequence delimiter) {
    String _xblockexpression = null;
    {
      Objects.<CharSequence>requireNonNull(delimiter, "separator string must not be null");
      Collector<CharSequence, ?, String> _joining = Collectors.joining(delimiter);
      _xblockexpression = stream.collect(_joining);
    }
    return _xblockexpression;
  }
  
  public static String join(final Stream<? extends CharSequence> stream, final CharSequence delimiter, final CharSequence prefix, final CharSequence suffix) {
    String _xblockexpression = null;
    {
      Objects.<CharSequence>requireNonNull(delimiter, "separator string must not be null");
      Collector<CharSequence, ?, String> _joining = Collectors.joining(delimiter, prefix, suffix);
      _xblockexpression = stream.collect(_joining);
    }
    return _xblockexpression;
  }
  
  public static <S extends CharSequence> Stream<S> matching(final Stream<S> stream, final String pattern) {
    Stream<S> _xblockexpression = null;
    {
      Objects.<String>requireNonNull(pattern, "Pattern must not be null");
      Objects.<Stream<S>>requireNonNull(stream, "Stream must not be null");
      final Pattern p = Pattern.compile(pattern);
      _xblockexpression = StreamExtensions.<S>matching(stream, p);
    }
    return _xblockexpression;
  }
  
  public static <S extends CharSequence> Stream<S> matching(final Stream<S> stream, final Pattern pattern) {
    final Predicate<S> _function = (S it) -> {
      Matcher _matcher = pattern.matcher(it);
      return _matcher.matches();
    };
    return stream.filter(_function);
  }
  
  public static Stream<String> flatSplit(final Stream<? extends CharSequence> stream, final String pattern) {
    Stream<String> _xblockexpression = null;
    {
      final Pattern p = Pattern.compile(pattern);
      _xblockexpression = StreamExtensions.flatSplit(stream, p);
    }
    return _xblockexpression;
  }
  
  public static Stream<String> flatSplit(final Stream<? extends CharSequence> stream, final Pattern pattern) {
    final Function<CharSequence, Stream<? extends String>> _function = (CharSequence it) -> {
      return pattern.splitAsStream(it);
    };
    return stream.<String>flatMap(_function);
  }
  
  public static Stream<String> flatSplit(final Stream<? extends CharSequence> stream, final String pattern, final int limit) {
    Stream<String> _xblockexpression = null;
    {
      final Pattern p = Pattern.compile(pattern);
      _xblockexpression = StreamExtensions.flatSplit(stream, p, limit);
    }
    return _xblockexpression;
  }
  
  public static Stream<String> flatSplit(final Stream<? extends CharSequence> stream, final Pattern pattern, final int limit) {
    final Function<CharSequence, Stream<? extends String>> _function = (CharSequence it) -> {
      return StreamExtensions.splitStream(it, pattern, limit);
    };
    return stream.<String>flatMap(_function);
  }
  
  private static Stream<String> splitStream(final CharSequence input, final Pattern pattern, final int limit) {
    Stream<String> _xifexpression = null;
    if ((limit == 0)) {
      _xifexpression = pattern.splitAsStream(input);
    } else {
      Stream<String> _xblockexpression = null;
      {
        final Supplier<Spliterator<String>> _function = () -> {
          Spliterator<String> _xblockexpression_1 = null;
          {
            final int characteristics = (Spliterator.ORDERED | Spliterator.NONNULL);
            Iterator<String> _splitIt = StringSplitExtensions.splitIt(input, pattern, limit);
            _xblockexpression_1 = Spliterators.<String>spliteratorUnknownSize(_splitIt, characteristics);
          }
          return _xblockexpression_1;
        };
        final Supplier<Spliterator<String>> s = _function;
        _xblockexpression = StreamSupport.<String>stream(s, 0, false);
      }
      _xifexpression = _xblockexpression;
    }
    return _xifexpression;
  }
  
  public static Stream<String> flatMatches(final Stream<String> stream, final Pattern pattern) {
    final Function<String, Stream<? extends String>> _function = (String it) -> {
      return StreamExtensions.matchStream(it, pattern);
    };
    return stream.<String>flatMap(_function);
  }
  
  public static Stream<String> flatMatches(final Stream<String> stream, final String pattern) {
    Pattern _compile = Pattern.compile(pattern);
    return StreamExtensions.flatMatches(stream, _compile);
  }
  
  private static Stream<String> matchStream(final String input, final Pattern pattern) {
    Stream<String> _xblockexpression = null;
    {
      final Supplier<Spliterator<String>> _function = () -> {
        Iterator<String> _matchIt = StringMatchExtensions.matchIt(input, pattern);
        return Spliterators.<String>spliteratorUnknownSize(_matchIt, 0);
      };
      final Supplier<Spliterator<String>> s = _function;
      _xblockexpression = StreamSupport.<String>stream(s, 0, false);
    }
    return _xblockexpression;
  }
  
  public static <T extends Object, Z extends Object> Stream<Pair<T, Z>> combinations(final Stream<T> stream, final Iterable<Z> combineWith) {
    Stream<Pair<T, Z>> _xblockexpression = null;
    {
      Objects.<Iterable<Z>>requireNonNull(combineWith);
      final Function<T, Stream<? extends Pair<T, Z>>> _function = (T t) -> {
        Stream<Z> _stream = StreamExtensions.<Z>stream(combineWith);
        final Function<Z, Pair<T, Z>> _function_1 = (Z it) -> {
          return Pair.<T, Z>of(t, it);
        };
        return _stream.<Pair<T, Z>>map(_function_1);
      };
      _xblockexpression = stream.<Pair<T, Z>>flatMap(_function);
    }
    return _xblockexpression;
  }
  
  public static <T extends Object, Z extends Object> Stream<Pair<T, Z>> combinations(final Stream<T> stream, final Collection<Z> combineWith) {
    Stream<Pair<T, Z>> _xblockexpression = null;
    {
      Objects.<Collection<Z>>requireNonNull(combineWith);
      final Function<T, Stream<? extends Pair<T, Z>>> _function = (T t) -> {
        Stream<Z> _stream = combineWith.stream();
        final Function<Z, Pair<T, Z>> _function_1 = (Z it) -> {
          return Pair.<T, Z>of(t, it);
        };
        return _stream.<Pair<T, Z>>map(_function_1);
      };
      _xblockexpression = stream.<Pair<T, Z>>flatMap(_function);
    }
    return _xblockexpression;
  }
  
  /**
   * On every call the given {@code streamSupplier) has to return a stream of the same elements.
   */
  public static <T extends Object, Z extends Object> Stream<Pair<T, Z>> combinations(final Stream<T> stream, final Function0<? extends Stream<Z>> streamSupplier) {
    Stream<Pair<T, Z>> _xblockexpression = null;
    {
      Objects.<Function0<? extends Stream<Z>>>requireNonNull(streamSupplier);
      final Function<T, Stream<? extends Pair<T, Z>>> _function = (T t) -> {
        Stream<Z> _apply = streamSupplier.apply();
        final Function<Z, Pair<T, Z>> _function_1 = (Z it) -> {
          return Pair.<T, Z>of(t, it);
        };
        return _apply.<Pair<T, Z>>map(_function_1);
      };
      _xblockexpression = stream.<Pair<T, Z>>flatMap(_function);
    }
    return _xblockexpression;
  }
  
  public static <T extends Object> Stream<T> operator_plus(final Stream<? extends T> first, final Stream<? extends T> second) {
    return Stream.<T>concat(first, second);
  }
  
  public static <T extends Object, V extends Object> Stream<V> flatMap(final Stream<T> stream, final Function1<? super T, ? extends Collection<? extends V>> mappingFunc) {
    Stream<V> _xblockexpression = null;
    {
      Objects.<Function1<? super T, ? extends Collection<? extends V>>>requireNonNull(mappingFunc);
      final Function<T, Stream<? extends V>> _function = (T it) -> {
        Collection<? extends V> _apply = mappingFunc.apply(it);
        return _apply.stream();
      };
      _xblockexpression = stream.<V>flatMap(_function);
    }
    return _xblockexpression;
  }
  
  public static <T extends Object, V extends Object> Stream<V> flatMapIter(final Stream<T> stream, final Function1<? super T, ? extends Iterable<? extends V>> mappingFunc) {
    Stream<V> _xblockexpression = null;
    {
      Objects.<Function1<? super T, ? extends Iterable<? extends V>>>requireNonNull(mappingFunc);
      final Function<T, Stream<? extends V>> _function = (T it) -> {
        Iterable<? extends V> _apply = mappingFunc.apply(it);
        return StreamExtensions.stream(_apply);
      };
      _xblockexpression = stream.<V>flatMap(_function);
    }
    return _xblockexpression;
  }
}
