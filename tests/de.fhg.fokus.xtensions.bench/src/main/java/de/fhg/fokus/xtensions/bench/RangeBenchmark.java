package de.fhg.fokus.xtensions.bench;

import java.util.function.IntPredicate;
import java.util.stream.IntStream;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

@SuppressWarnings("all")
public class RangeBenchmark {
  /* @Benchmark
   */public void testRange() {
    final Function1<Integer, Boolean> _function = (Integer it) -> {
      return Boolean.valueOf((((it).intValue() % 2) == 0));
    };
    final Function2<Integer, Integer, Integer> _function_1 = (Integer $0, Integer $1) -> {
      return Integer.valueOf((($0).intValue() + ($1).intValue()));
    };
    IterableExtensions.<Integer, Integer>fold(IterableExtensions.<Integer>filter(new IntegerRange(0, 1_000_000), _function), Integer.valueOf(0), _function_1);
  }
  
  /* @Benchmark
   */public void testStream() {
    final IntPredicate _function = (int it) -> {
      return ((it % 2) == 0);
    };
    IntStream.range(0, (1_000_000 + 1)).filter(_function).sum();
  }
}
