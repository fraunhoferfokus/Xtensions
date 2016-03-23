package de.fhg.fokus.xtenders.string;

import com.google.common.base.Objects;
import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Utility class holding static extension functions to split strings.
 * This class is not intended to be instantiated.
 */
@SuppressWarnings("all")
public class StringSplitExtensions {
  /**
   * Iterator simply returning one empty String
   */
  private static final class EmptyStringIterator implements Iterator<String> {
    private boolean read = false;
    
    @Override
    public boolean hasNext() {
      return (!this.read);
    }
    
    @Override
    public String next() {
      String _xblockexpression = null;
      {
        this.read = true;
        _xblockexpression = "";
      }
      return _xblockexpression;
    }
  }
  
  /**
   * Iterator class that should behave like a lazy version of
   * {@link String#split(String, int)} with a positive integer as second
   * parameter.
   */
  private static class LimitedSplitIterator extends StringSplitExtensions.UnlimitedSplitIterator {
    private int limit;
    
    private int readCount;
    
    public LimitedSplitIterator(final CharSequence toSplit, final Pattern pattern, final int limit) {
      super(toSplit, pattern);
      this.readCount = 0;
      this.limit = limit;
      this.readAndSetNext();
    }
    
    @Override
    protected void initializeNext() {
    }
    
    @Override
    public void readAndSetNext() {
      this.readCount++;
      if ((this.readCount >= this.limit)) {
        String _readLastPart = this.readLastPart();
        this.next = _readLastPart;
      } else {
        super.readAndSetNext();
      }
    }
  }
  
  /**
   * Iterator class that should behave like a lazy version of
   * {@link String#split(String, int)} with a negative integer as second
   * parameter.
   */
  private static class UnlimitedSplitIterator implements Iterator<String> {
    private final Matcher matcher;
    
    protected String next;
    
    private int index;
    
    private CharSequence input;
    
    public UnlimitedSplitIterator(final CharSequence toSplit, final Pattern pattern) {
      final Matcher m = pattern.matcher(toSplit);
      this.matcher = m;
      this.index = 0;
      this.input = toSplit;
      this.initializeNext();
    }
    
    /**
     * Called from constructor to read next value
     */
    protected void initializeNext() {
      this.readAndSetNext();
    }
    
    public String readNext() {
      String _xblockexpression = null;
      {
        while (this.matcher.find()) {
          {
            final int start = this.matcher.start();
            final int end = this.matcher.end();
            final int i = this.index;
            if ((!(((i == 0) && (start == 0)) && (start == end)))) {
              CharSequence _subSequence = this.input.subSequence(i, start);
              String res = _subSequence.toString();
              this.index = end;
              return res;
            }
          }
        }
        _xblockexpression = this.readLastPart();
      }
      return _xblockexpression;
    }
    
    /**
     * Reads the last parts of a string to split from the end of the
     * last match to the end of the string to split
     */
    protected String readLastPart() {
      if ((this.index == 0)) {
        int _length = this.input.length();
        int _plus = (_length + 1);
        this.index = _plus;
        return this.input.toString();
      }
      int _length_1 = this.input.length();
      boolean _lessEqualsThan = (this.index <= _length_1);
      if (_lessEqualsThan) {
        int _length_2 = this.input.length();
        CharSequence _subSequence = this.input.subSequence(this.index, _length_2);
        final String res = _subSequence.toString();
        int _length_3 = this.input.length();
        int _plus_1 = (_length_3 + 1);
        this.index = _plus_1;
        return res;
      } else {
        return null;
      }
    }
    
    protected void readAndSetNext() {
      String _readNext = this.readNext();
      this.next = _readNext;
    }
    
    @Override
    public boolean hasNext() {
      return (!Objects.equal(this.next, null));
    }
    
    @Override
    public String next() {
      String _xblockexpression = null;
      {
        boolean _equals = Objects.equal(this.next, null);
        if (_equals) {
          throw new NoSuchElementException();
        }
        String result = this.next;
        this.readAndSetNext();
        _xblockexpression = result;
      }
      return _xblockexpression;
    }
  }
  
  private static final class UnlimitedSplitIteratorNoTrailingEmpty implements Iterator<String> {
    private final static String EMPTY = "";
    
    private final Matcher matcher;
    
    private String next;
    
    private String firstAfterEmpty;
    
    private int index;
    
    private int upcomingEmptyCount;
    
    private CharSequence input;
    
    public UnlimitedSplitIteratorNoTrailingEmpty(final CharSequence toSplit, final Pattern pattern) {
      final Matcher m = pattern.matcher(toSplit);
      this.matcher = m;
      this.index = 0;
      this.input = toSplit;
      this.upcomingEmptyCount = 0;
      this.firstAfterEmpty = null;
      this.readAndSetNext();
    }
    
    private String readNext() {
      if ((this.upcomingEmptyCount > 0)) {
        this.upcomingEmptyCount--;
        if ((this.upcomingEmptyCount == 0)) {
          final String res = this.firstAfterEmpty;
          this.firstAfterEmpty = null;
          return res;
        } else {
          return StringSplitExtensions.UnlimitedSplitIteratorNoTrailingEmpty.EMPTY;
        }
      }
      while (this.matcher.find()) {
        {
          final int start = this.matcher.start();
          final int end = this.matcher.end();
          final int i = this.index;
          if ((!(((i == 0) && (start == 0)) && (start == end)))) {
            this.index = end;
            String _xifexpression = null;
            if ((i == start)) {
              _xifexpression = this.skipTrailingEmptyStrings();
            } else {
              CharSequence _subSequence = this.input.subSequence(i, start);
              _xifexpression = _subSequence.toString();
            }
            final String res_1 = _xifexpression;
            return res_1;
          }
        }
      }
      return this.readLastPart();
    }
    
    private String readLastPart() {
      if ((this.index == 0)) {
        int _length = this.input.length();
        this.index = _length;
        return this.input.toString();
      }
      int _length_1 = this.input.length();
      boolean _lessThan = (this.index < _length_1);
      if (_lessThan) {
        int _length_2 = this.input.length();
        CharSequence _subSequence = this.input.subSequence(this.index, _length_2);
        final String res = _subSequence.toString();
        int _length_3 = this.input.length();
        this.index = _length_3;
        return res;
      } else {
        return null;
      }
    }
    
    private String skipTrailingEmptyStrings() {
      while (this.matcher.find()) {
        {
          final int start = this.matcher.start();
          final int end = this.matcher.end();
          final int i = this.index;
          this.index = end;
          this.upcomingEmptyCount++;
          if ((i != start)) {
            CharSequence _subSequence = this.input.subSequence(i, start);
            String _string = _subSequence.toString();
            this.firstAfterEmpty = _string;
            return StringSplitExtensions.UnlimitedSplitIteratorNoTrailingEmpty.EMPTY;
          }
        }
      }
      String after = this.readLastPart();
      boolean _equals = Objects.equal(after, null);
      if (_equals) {
        this.upcomingEmptyCount = 0;
        return null;
      } else {
        this.upcomingEmptyCount = 1;
        this.firstAfterEmpty = after;
        return StringSplitExtensions.UnlimitedSplitIteratorNoTrailingEmpty.EMPTY;
      }
    }
    
    private String readAndSetNext() {
      String _readNext = this.readNext();
      return this.next = _readNext;
    }
    
    @Override
    public boolean hasNext() {
      return (!Objects.equal(this.next, null));
    }
    
    @Override
    public String next() {
      String _xblockexpression = null;
      {
        boolean _equals = Objects.equal(this.next, null);
        if (_equals) {
          throw new NoSuchElementException();
        }
        String result = this.next;
        this.readAndSetNext();
        _xblockexpression = result;
      }
      return _xblockexpression;
    }
  }
  
  private StringSplitExtensions() {
    throw new IllegalStateException("StringSplitExtensions not intended to be instantiated");
  }
  
  /**
   * Creates an iterator that splits the input parameter string {@code toSplit}
   * at the given regular expression {@code pattern}. The splitting behavior
   * is modeled after the rules of {@link String#split(String,int)}, therefore
   * the parameter {@code limit} has the same semantics.<br>
   * The returned Iterator performs the splitting operations as lazy as possible,
   * so it is is suited well for finding tokens in a string and stop splitting
   * as soon as a particular element is found. This also reduces memory copying
   * to unused strings.
   * @see String#split(String,int)
   */
  public static Iterator<String> splitIt(final String toSplit, final String pattern, final int limit) {
    Pattern _compile = Pattern.compile(pattern);
    return StringSplitExtensions.splitIt(toSplit, _compile, limit);
  }
  
  /**
   * Creates an iterator that splits the input parameter string {@code toSplit}
   * at the given regular expression {@code pattern}. The splitting behavior
   * is modeled after the rules of {@link Pattern#split(CharSequence,int)}, therefore
   * the parameter {@code limit} has the same semantics.<br>
   * The returned Iterator performs the splitting operations as lazy as possible,
   * so it is is suited well for finding tokens in a string and stop splitting
   * as soon as a particular element is found. This also reduces memory copying
   * to unused strings.
   * @see Pattern#split(CharSequence,int)
   */
  public static Iterator<String> splitIt(final CharSequence toSplit, final Pattern pattern, final int limit) {
    StringSplitExtensions.LimitedSplitIterator _xblockexpression = null;
    {
      int _length = toSplit.length();
      boolean _equals = (_length == 0);
      if (_equals) {
        return new StringSplitExtensions.EmptyStringIterator();
      }
      if ((limit < 0)) {
        return new StringSplitExtensions.UnlimitedSplitIterator(toSplit, pattern);
      }
      if ((limit == 0)) {
        return new StringSplitExtensions.UnlimitedSplitIteratorNoTrailingEmpty(toSplit, pattern);
      }
      _xblockexpression = new StringSplitExtensions.LimitedSplitIterator(toSplit, pattern, limit);
    }
    return _xblockexpression;
  }
  
  /**
   * Creates an iterator that splits the input parameter string {@code toSplit}
   * at the given regular expression {@code pattern}. The splitting behavior
   * is modeled after the rules of {@link Pattern#split(CharSequence)}.<br>
   * The returned Iterator performs the splitting operations as lazy as possible,
   * so it is is suited well for finding tokens in a string and stop splitting
   * as soon as a particular element is found. This also reduces memory copying
   * to unused strings.
   * @see Pattern#split(CharSequence)
   * @param toSplit is the string to be split by the given pattern. Must not be null
   * @throws NullPointerException if toSplit or pattern is null
   */
  public static Iterator<String> splitIt(final CharSequence toSplit, final Pattern pattern) {
    Iterator<String> _xblockexpression = null;
    {
      java.util.Objects.<CharSequence>requireNonNull(toSplit);
      Iterator<String> _xifexpression = null;
      int _length = toSplit.length();
      boolean _equals = (_length == 0);
      if (_equals) {
        _xifexpression = new StringSplitExtensions.EmptyStringIterator();
      } else {
        _xifexpression = new StringSplitExtensions.UnlimitedSplitIteratorNoTrailingEmpty(toSplit, pattern);
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  /**
   * Creates an iterator that splits the input parameter string {@code toSplit}
   * at the given regular expression {@code pattern}. The splitting behavior
   * is modeled after the rules of {@link String#split(String)}.<br>
   * The returned Iterator performs the splitting operations as lazy as possible,
   * so it is is suited well for finding tokens in a string and stop splitting
   * as soon as a particular element is found. This also reduces memory copying
   * to unused strings.
   * @see String#split(String)
   */
  public static Iterator<String> splitIt(final CharSequence toSplit, final String pattern) {
    Pattern _compile = Pattern.compile(pattern);
    return StringSplitExtensions.splitIt(toSplit, _compile);
  }
}
