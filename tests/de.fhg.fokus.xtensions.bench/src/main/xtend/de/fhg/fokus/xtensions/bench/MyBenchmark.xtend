package de.fhg.fokus.xtensions.bench

import org.openjdk.jmh.annotations.Benchmark
import java.util.stream.IntStream

class RangeBenchmark {
	
	@Benchmark
    public def void testRange() {
    	(0..1_000_000).filter[it%2 == 0].fold(0)[$0+$1];
    }
    
	@Benchmark
    public def void testStream() {
    	IntStream.range(0, 1_000_000 + 1).filter[it%2 == 0].sum;
    }
}