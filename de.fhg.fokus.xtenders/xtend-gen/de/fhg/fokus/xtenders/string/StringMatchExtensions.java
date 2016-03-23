package de.fhg.fokus.xtenders.string;

import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.Objects;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.eclipse.xtend2.lib.StringConcatenation;

/**
 * This class provoides static functions to create iterators that lazily
 * provide all matches of given regular expressions on an input CharSequence (e.g. String).
 * This class is not intended to be instantiated.
 */
@SuppressWarnings("all")
public class StringMatchExtensions {
  /**
   * Iterator that allows iteration over all matched substrings of a given regular expression
   * in an input CharSequence.
   */
  private static class MatchStringIterator implements Iterator<String> {
    private Matcher matcher;
    
    private boolean hasNext;
    
    private CharSequence input;
    
    public MatchStringIterator(final CharSequence toMatch, final Pattern pattern) {
      this.input = toMatch;
      Matcher _matcher = pattern.matcher(toMatch);
      this.matcher = _matcher;
      boolean _find = this.matcher.find();
      this.hasNext = _find;
    }
    
    @Override
    public boolean hasNext() {
      return this.hasNext;
    }
    
    @Override
    public String next() {
      String _xblockexpression = null;
      {
        int _start = this.matcher.start();
        int _end = this.matcher.end();
        final CharSequence res = this.input.subSequence(_start, _end);
        boolean _find = this.matcher.find();
        this.hasNext = _find;
        _xblockexpression = res.toString();
      }
      return _xblockexpression;
    }
  }
  
  /**
   * Iterator over all MatchResults of a regular expression in an input char sequence.
   * The returned matches do not change states when another match is pulled from the iterator.
   */
  private static class MatchResultIterator implements Iterator<MatchResult> {
    private Matcher nextMatcher;
    
    private boolean hasNext;
    
    private CharSequence input;
    
    private Pattern pattern;
    
    public MatchResultIterator(final CharSequence toMatch, final Pattern p) {
      this.pattern = p;
      final Matcher m = p.matcher(toMatch);
      this.nextMatcher = m;
      boolean _find = m.find();
      this.hasNext = _find;
      this.input = toMatch;
    }
    
    @Override
    public boolean hasNext() {
      return this.hasNext;
    }
    
    @Override
    public MatchResult next() {
      Matcher _xblockexpression = null;
      {
        if ((!this.hasNext)) {
          throw new NoSuchElementException();
        }
        final Matcher res = this.nextMatcher;
        final Matcher next = this.pattern.matcher(this.input);
        this.nextMatcher = next;
        int _end = res.end();
        boolean _find = next.find(_end);
        this.hasNext = _find;
        _xblockexpression = res;
      }
      return _xblockexpression;
    }
  }
  
  private StringMatchExtensions() {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append(StringMatchExtensions.class, "");
    _builder.append(" is not intended to be instantiated");
    throw new IllegalStateException(_builder.toString());
  }
  
  /**
   * This function creates an iterator, that lazily finds matching strings according
   * to the given {@code pattern} sequentially in the input CharSequence.
   * This way of iterating over matches does not provide access to matching groups,
   * see {@link StringMatchExtensions#matchResultIt(CharSequence, Pattern) matchResultIt}
   * for full match access, including groups.
   * @see StringMatchExtensions#matchResultIt(CharSequence, Pattern)
   */
  public static Iterator<String> matchIt(final CharSequence toMatch, final Pattern pattern) {
    StringMatchExtensions.MatchStringIterator _xblockexpression = null;
    {
      Objects.<CharSequence>requireNonNull(toMatch);
      Objects.<Pattern>requireNonNull(pattern);
      _xblockexpression = new StringMatchExtensions.MatchStringIterator(toMatch, pattern);
    }
    return _xblockexpression;
  }
  
  /**
   * This function creates an iterator, that lazily finds matching strings according
   * to the given {@code pattern} regular expression sequentially in the input CharSequence.
   * This way of iterating over matches does not provide access to matching groups,
   * see {@link StringMatchExtensions#matchResultIt(CharSequence, String) matchResultIt}
   * for full match access, including groups.
   * @see StringMatchExtensions#matchResultIt(CharSequence, String)
   */
  public static Iterator<String> matchIt(final CharSequence toMatch, final String pattern) {
    Iterator<String> _xblockexpression = null;
    {
      Objects.<CharSequence>requireNonNull(toMatch);
      Objects.<String>requireNonNull(pattern);
      Pattern _compile = Pattern.compile(pattern);
      _xblockexpression = StringMatchExtensions.matchIt(toMatch, _compile);
    }
    return _xblockexpression;
  }
  
  /**
   * This function creates an iterator, that lazily finds MatchResults according
   * to the given {@code pattern} regular expression sequentially in the input CharSequence.
   * The returned MatchResults will not change their state when another result is pulled
   * from the iterator.
   */
  public static Iterator<MatchResult> matchResultIt(final CharSequence toMatch, final Pattern pattern) {
    return new StringMatchExtensions.MatchResultIterator(toMatch, pattern);
  }
  
  /**
   * This function creates an iterator, that lazily finds MatchResults according
   * to the given {@code pattern} regular expression sequentially in the input CharSequence.
   * The returned MatchResults will not change their state when another result is pulled
   * from the iterator.
   */
  public static Iterator<MatchResult> matchResultIt(final CharSequence toMatch, final String pattern) {
    Pattern _compile = Pattern.compile(pattern);
    return StringMatchExtensions.matchResultIt(toMatch, _compile);
  }
}
