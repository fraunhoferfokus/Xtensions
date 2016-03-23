package de.fhg.fokus.xtenders.range;

import de.fhg.fokus.xtenders.optional.IntIntConsumer;
import java.util.function.IntConsumer;
import org.eclipse.xtext.xbase.lib.IntegerRange;

@SuppressWarnings("all")
public class RangeExtensions {
  public static void forEachInt(final IntegerRange r, final IntConsumer consumer) {
    final int start = r.getStart();
    final int end = r.getEnd();
    final int step = r.getStep();
    if ((step > 0)) {
      int i = start;
      boolean _while = (i <= end);
      while (_while) {
        consumer.accept(i);
        int _i = i;
        i = (_i + step);
        _while = (i <= end);
      }
    } else {
      int i_1 = start;
      boolean _while_1 = (i_1 >= end);
      while (_while_1) {
        consumer.accept(i_1);
        int _i = i_1;
        i_1 = (_i + step);
        _while_1 = (i_1 >= end);
      }
    }
  }
  
  public static void forEachInt(final IntegerRange r, final IntIntConsumer consumer) {
    final int start = r.getStart();
    final int end = r.getEnd();
    final int step = r.getStep();
    int index = 0;
    if ((step > 0)) {
      int i = start;
      boolean _while = (i <= end);
      while (_while) {
        int _plusPlus = index++;
        consumer.accept(i, _plusPlus);
        int _i = i;
        i = (_i + step);
        _while = (i <= end);
      }
    } else {
      int i_1 = start;
      boolean _while_1 = (i_1 >= end);
      while (_while_1) {
        int _plusPlus = index++;
        consumer.accept(i_1, _plusPlus);
        int _i = i_1;
        i_1 = (_i + step);
        _while_1 = (i_1 >= end);
      }
    }
  }
}
