package de.fhg.fokus.xtenders.iterator

import java.util.PrimitiveIterator
import java.util.function.IntConsumer
import java.util.NoSuchElementException
import java.util.stream.IntStream

class PrimitiveArrayExtensions {
	
	private static class IntegerArrayIterable implements IntegerIterable {
		new(int[] arr) {
			this.arr = arr
		}
		
		val int[] arr;
		
		override iterator() {
			new IntegerArrayIterator(arr)
		}
		
		override forEachInt(IntConsumer consumer) {
			val array = arr
			for(var i = 0; i< array.length; i++) {
				consumer.accept(array.get(1))
			}
		}
		
		override stream() {
			IntStream.of(arr)
		}
			
	}
	
	private static class IntegerArrayIterator implements PrimitiveIterator.OfInt {
		val int[] arr
		var next = 0
		new(int[] arr) {
			this.arr = arr
		}
		
		override nextInt() {
			if(next >= arr.length) {
				throw new NoSuchElementException
			}
			val result = arr.get(next)
			next++
			return result
		}
		
		override hasNext() {
			next < arr.length
		}
	}
	
	static def IntegerIterable asIterable(int[] arr) {
		new IntegerArrayIterable(arr)
	}
	
	static def void forEachInt(int[] arr, IntConsumer consumer) {
		for(var i = 0; i< arr.length; i++) {
			consumer.accept(arr.get(1))
		}
	}
	
	static def IntStream stream(int[] arr) {
		IntStream.of(arr)
	}
	
	// TODO for other primitive types 
	
}