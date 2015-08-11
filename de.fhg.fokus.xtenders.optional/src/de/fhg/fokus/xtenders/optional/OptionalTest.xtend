package de.fhg.fokus.xtenders.optional

import java.util.Optional
import java.util.stream.Collectors
import org.eclipse.xtend.lib.annotations.Data

import static extension de.fhg.fokus.xtenders.optional.CollectionOptionalExtensions.*
import static extension de.fhg.fokus.xtenders.optional.ExceptionToOptional.*
import static extension de.fhg.fokus.xtenders.optional.OptionalExtensions.*
import static extension de.fhg.fokus.xtenders.optional.OptionalMath.*
import static extension de.fhg.fokus.xtenders.optional.OptionalFunctionExtensions.*

class OptionalTest {

	@Data static class Person {
		String name
	}

	def static void main(String[] args) {
//		val ra = some((0..-10).withStep(-3))
		val ra = none
		ra.forEachInt [
			println(it)
		]
		println("end")

		val l = " foo ".trimLen
		println(l)

		some("foo") >> [
			println(length)
		]
		
		val (Optional<String>) => String strOrEmpty = [it ?: ""]

		getOptional() => ifPresent [
			println(it)
		].elseDo [
			println("awww")
		]
		
		// same as filter empty -> extract value -> fold
		#[some("foo"), none, some("bar")].foldPresent("") [r, t| r + t] => [
			println(it)
		]
		
		#[some("foo"), none, some("bar")].reducePresent[a, b| a + b] >> [
			println(it)
		]

		none.notPresent [
			println("not there")
		]

		val li = some("hui") >>> Collectors::toList
		
		println(li)

		for (s : some("drrrr").toIterable) {
			println(s)
		}
		
		"bar".maybe.mapInt[length]

//		maybe("bar") => [
//			println(length)
//		]
//		(0..5).forEachInt [
//			System.out.println(it)
//		]
		some(5 .. 10).forEachInt [ num, index |
			println(index + ": " + num)
		]

		val String[] arrS = #["foo", "bar", "baz"]
		some(arrS).asList.forEach[]

		allPresent(#[some("foo"), some("bar"), some("baz")]) [
			println(it)
		]

		(some("foo") -> some(1).boxed) >> [a, b |
			
		]
		
		val display = maybe(fetchName()) ?: [fetchUserNick()]
		
		val nameLen = new Person("Bob")?.name?.trim?.length
		val person = some(new Person("Bob"))
		person -> [name] -> [length]
		(person -> [name] -> [trim]).mapInt[length] ?: 0
		person.mapInt[name?.trim?.length]

		some(#["foo", "bar", "baz"]).forEach [
			println(it)
		]

		( none || [none] || [some("bazzzz")] ) => ifPresent [
			println(it)
		].elseDo [
			println("awwww")
		]
		
		val o = "foo".onlyIf [length > 0]

		val bar = some("foo").filter(Integer);
		
		val baz = trySupply [
			somethingDangerous()
		].doRecover(NumberFormatException) [
			"bar"
		].doCatch(UnsupportedOperationException) [ 
			printStackTrace
		].doCatch [
			System.err.println("Something is seriously wrong")
			printStackTrace
		].eval
		println(baz)

		val boo = [|somethingDangerous()].doCatch
		
		println(boo)
		
		val foo = [|somethingDangerous()].doCatch [
			printStackTrace
		]
		println(foo)

		val map = newHashMap("hui" -> "buh")
		
		map.ifGet("hui") [
			println(it)
		]
		
		#["foo", null, "bar"].filter(nullToFalse[length > 0]) => [
			println(it)
		]
		
		map.getOpt("hui") >> [
			println(it)
		]
		
		val toUpper = [String it|toUpperCase].noNull
		toUpper.apply(map.get("hui")) >> [
			println(it)
		]
		
		val sqrt = [double d| d > 0.0d].preFor [Math.sqrt(it)]
		sqrt.apply(42.0) >> [
			println(it)
		]
		
		val sqrt2 = [Math.sqrt(it)].filter [!isNaN && !infinite]
		sqrt2.apply(42.0) >> [
			println(it)
		]
		
		#["foo", null, "bar"].map(ignoreNull [toUpperCase]) => [println(it)]
		
		
		some(42).filter[it>0]
		
		some(1.0) + some(2L)
		
	}
	
	def static String fetchUserNick() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	def static fetchName() {
		"wee"
	}
	
	def static String somethingDangerous() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def static getOptional() {
		some("Come get some!")
//		none
	}
	
def Optional<String> normalize(String s) {
	s.trim.toLowerCase.onlyIf [length > 3]
}

	def public static trimLen(String s) {
		s.maybe -> [trim] -> [length] ?: 0
	}

	def public static trimLen3(String s) {
		s.maybe.map[trim].mapInt[length] ?: 0
	}

	def public static trimLen1(String s) {
		Optional.ofNullable(s).map[trim].map[length].orElse(0)
	}

	def public static trimLen2(String s) {
		s?.trim?.toUpperCase?.length
	}
}