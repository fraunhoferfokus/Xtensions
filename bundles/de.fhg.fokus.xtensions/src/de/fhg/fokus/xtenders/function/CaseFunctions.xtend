package de.fhg.fokus.xtenders.function

import java.util.function.Predicate
import java.util.Optional
import java.util.NoSuchElementException
import de.fhg.fokus.xtenders.function.CaseFunctions.CaseResult
import static extension de.fhg.fokus.xtenders.function.CaseFunctions.CaseResult.*;
import com.google.common.annotations.Beta

@Beta
class CaseFunctions {

	public static abstract class CaseResult<T> {
		private new() {
		}

		public abstract def boolean isMatch()

		public abstract def T result() throws NoSuchElementException

		public abstract def CaseResult<T> orElse(=>CaseResult<T> provider)

		public abstract def T orElseResult(=>T provider)

		public abstract def T orElseResult(T result)

		public static def <T> CaseResult<T> match(T t) {
			new Match(t)
		}

		public static def <T> CaseResult<T> noMatch() {
			NoMatch.INSTANCE as CaseResult<T>
		}

	}

	private static final class NoMatch<T> extends CaseResult<T> {

		private static final CaseResult<?> INSTANCE = new NoMatch

		override isMatch() {
			false
		}

		override result() throws NoSuchElementException {
			throw new NoSuchElementException();
		}

		override orElse(=>CaseResult<T> provider) {
			provider.apply
		}

		override orElseResult(=>T provider) {
			provider.apply
		}

		override orElseResult(T result) {
			result
		}

	}

	private static final class Match<T> extends CaseResult<T> {
		val T result

		private new(T t) {
			this.result = t
		}

		override isMatch() {
			true
		}

		override result() throws NoSuchElementException {
			result
		}

		override orElse(=>CaseResult<T> provider) {
			this
		}

		override orElseResult(=>T provider) {
			result
		}

		override orElseResult(T t) {
			result
		}

	}

	public static def <I, O, T> (I)=>CaseResult<O> caseIs((I)=>CaseResult<O> switcher, Class<T> clazz, (T)=>O handler) {
		[
			switcher.apply(it).orElse [
				if (clazz.isInstance(it))
					handler.apply(it as T).match
				else
					noMatch
			]
		]
	}

	public static def <I, O> (I)=>CaseResult<O> switcher() {
		[noMatch]
	}


	public static def <I, O> (I)=>CaseResult<O> caseNull((I)=>CaseResult<O> switcher, =>O handler) {
		[
			switcher.apply(it).orElse [
				if (it === null)
					match(handler.apply)
				else
					noMatch
			]
		]
	}

	public static def <I, O, T> (I)=>CaseResult<O> caseObj((I)=>CaseResult<O> switcher, (I)=>Optional<T> extractor,
		(T)=>O handler) {
		[
			switcher.apply(it).orElse [
				val extracted = extractor.apply(it)
				if (extracted.isPresent)
					handler.apply(extracted.get).match
				else
					noMatch
			]
		]
	}

	public static def <I, O> (I)=>CaseResult<O> caseIf((I)=>CaseResult<O> switcher, Predicate<I> test, (I)=>O handler) {
		[
			switcher.apply(it).orElse [
				if (test.test(it))
					handler.apply(it).match
				else
					noMatch
			]
		]
	}

	public static def <I extends Optional<T>, T, O> (I)=>CaseResult<O> casePresent((I)=>CaseResult<O> switcher,
		(T)=>O handler) {
		[
			switcher.apply(it).orElse [
				if (it.present)
					handler.apply(it.get).match
				else
					noMatch
			]
		]
	}

	public static def <I extends Optional<T>, T, O> (I)=>CaseResult<O> casePresent((I)=>CaseResult<O> switcher,
		Predicate<T> test, (T)=>O handler) {
		[
			switcher.apply(it).orElse [
				if (!it.present)
					return noMatch
				val optVal = it.get
				if (test.test(optVal))
					handler.apply(optVal).match
				else
					noMatch
			]
		]
	}

	public static def <I, O, T> (I)=>O otherwise((I)=>CaseResult<O> switcher, (I)=>O handler) {
		[switcher.apply(it).orElseResult[handler.apply(it)]]
	}

	public static def <I, O> (I)=>O otherwise((I)=>CaseResult<O> switcher, O altResult) {
		[switcher.apply(it).orElseResult(altResult)]
	}

}