package de.fhg.fokus.xtensions.iteration

import java.util.Map
import java.util.AbstractMap
import java.util.Set
import java.util.NoSuchElementException
import static extension java.util.Objects.*
import java.util.AbstractMap.SimpleImmutableEntry

/**
 * This interface represents a collection of element partitioned into two parts.
 * The elements that were selected by the partition criterion are aggregated to the 
 * type {@code S} and returned via the {@link #getSelected()} method. The
 * elements that were reject by the partition criterion are aggregated to the 
 * type {@code R} and returned via the {@link #getRejected()} method.
 * 
 * @param <S> Aggregation partition type for the selected elements.
 * @param <R> Aggregation partition type for the rejected elements.
 */
interface Partition<S,R> {
	
	/**
	 * Returns the aggregation of the elements that were selected by the partition criterion.
	 * @return aggregation of the elements that were selected by the partition criterion.
	 */
	def S getSelected()
	
	/**
	 * Returns the aggregation of the elements that were rejected by the partition criterion.
	 * @return aggregation of the elements that were rejected by the partition criterion.
	 */
	def R getRejected()
	
	/**
	 * Returns the selected and rejected aggregations as a {@code Pair}.
	 * @return selected and rejected aggregations as a {@code Pair}.
	 */
	def Pair<S,R> asPair() { selected -> rejected }
	
	/**
	 * This extension method is wrapping a {@code Partition}, having the same type for selected
	 * and rejected part, into a {@code Map<Boolean,X>}. Under the key {@code true} the
	 * map will provide the selected part of the wrapped partition and under the key
	 * {@code false} the rejected part will be available. There is no guarantee for
	 * thread safety or mutablility of the returned map. The returned map does not support
	 * {@code null} keys and will throw a {@code NullPointerException} when asked for 
	 * the value for key {@code null}.
	 * @param partition the partition for which a map is created. The rejected part will be 
	 *  provided under key {@code true} and the rejected part under key {@code false}.
	 * @param <X> type of the selected and rejected parts of the given {@code partition}
	 * @return Map providing the {@code selected} part of {@code partition} for key {@code true}
	 *  and the {@code rejected} part for key {@code false}.
	 * @throws NullPointerException will be thrown if {@code partition} is {@code null}.
	 */
	static def <X> Map<Boolean, X> asMap(Partition<X,X> partition) {
		if(partition instanceof MapBasedPartition<?>) {
			partition.map as Map<Boolean,X>
		} else {
			new PartitionBasedMap(partition.requireNonNull)
		}
	}
	
	/**
	 * This extension method is wrapping a {@code Map<Boolean,X>} into a 
	 * {@code Partition<X,X>}. Partition will return the value to the 
	 * key {@code true} from the wrapped {@code map} when 
	 * {@link Partition#getSelected() getSelected()} is called. When
	 * {@link Partition#getRejected() getRejected()} is called on the
	 * returned partition, the value stored under key {@code false} in
	 * the wrapped {@code map} will be returned.
	 * 
	 * @param map the map to be wrapped in the returned partition.
	 * @return Partition, where the selected part will be provided by 
	 *  returning the value for key {@code true} from the wrapped {@code map} and
	 *  the value for key {@code false}.
	 * @param <X> type of the value elements in {@code map}
	 * @throws NullPointerException will be thrown if {@code map} is {@code null}.
	 */
	static def <X> Partition<X,X> asPartition(Map<Boolean, X> map) {
		if(map instanceof PartitionBasedMap<?>) {
			map.partition as Partition<X,X>
		} else {
			new MapBasedPartition(map.requireNonNull)
		}
	}
}

/**
 * {@code Partition} implementation wrapping around a given {@code Map}. The {@link #getSelected() selected} part will
 * provide the value for the {@code true} key from the wrapped map. The {@link #getRejected() rejected} part will return
 * the value stored under key {@code false} in the wrapped map.
 */
package class MapBasedPartition<X> implements Partition<X,X> {
	
	package val Map<Boolean, X> map
	
	new(Map<Boolean, X> map) {
		this.map = map
	}
	
	override getSelected() {
		map.get(Boolean.TRUE)
	}
	
	override getRejected() {
		map.get(Boolean.FALSE)
	}
	
}

/**
 * {@code Map} implementation wrapping around a given {@code Partition}. Under the key {@code true} the
 * map will provide the selected part of the wrapped partition and under the key
 * {@code false} the rejected part will be available. This class is optimized providing a
 * more efficient {@link #get(Object)} method. All other methods have the complexity of the
 * method implementations provided by {@code AbstractMap}.
 */
package class PartitionBasedMap<X> extends AbstractMap<Boolean,X> {
	
	transient var Set<Map.Entry<Boolean,X>> entrySet
	package val Partition<X,X> partition
	
	new(Partition<X,X> partition) {
		this.partition = partition
	}
	
	override entrySet() {
		if(entrySet === null) {
			entrySet = #{ Boolean.TRUE -> partition.selected, Boolean.FALSE -> partition.rejected}
		}
		entrySet
	}
	
	override get(Object key) {
		key.requireNonNull
		if(key instanceof Boolean) {
			if(key)
				partition.selected
			else
				partition.rejected
		} else { // not instanceof Boolean
			throw new NoSuchElementException
		}
	}
	
	private static def <X> Map.Entry<Boolean,X> -> (Boolean b, X x) {
		new SimpleImmutableEntry(b,x)
	}
}