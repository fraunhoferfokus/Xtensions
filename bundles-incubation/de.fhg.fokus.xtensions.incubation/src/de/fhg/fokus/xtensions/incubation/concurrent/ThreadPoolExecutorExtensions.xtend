package de.fhg.fokus.xtensions.incubation.concurrent

import java.util.concurrent.TimeUnit
import java.util.concurrent.BlockingQueue
import java.util.concurrent.ThreadFactory
import java.util.concurrent.RejectedExecutionHandler
import java.util.concurrent.SynchronousQueue
import java.util.concurrent.Executors
import java.util.concurrent.ThreadPoolExecutor.AbortPolicy
import java.util.concurrent.ThreadPoolExecutor
import static extension de.fhg.fokus.xtensions.function.FunctionExtensions.*

class ThreadPoolExecutorExtensions {

	public static class ThreadPoolExecutorParam {
		private static val defaultPolicy = new AbortPolicy

		var int corePoolSize = 0
		var int maximumPoolSize = Integer.MAX_VALUE
		var long keepAliveTime = 60L
		var TimeUnit unit = TimeUnit.SECONDS
		var BlockingQueue<Runnable> workQueue = new SynchronousQueue<Runnable>()
		var ThreadFactory threadFactory = Executors.defaultThreadFactory()
		var RejectedExecutionHandler handler = defaultPolicy
		
		// TODO setters, setKeepAlive(Pair<Long, TimeUnit>) + setKeepAlive(Duration)
	}

	new() {
	}

	public def static create(Class<ThreadPoolExecutor> clazz, (ThreadPoolExecutorParam)=>void builder) {
		val params = new ThreadPoolExecutorParam
		builder.apply(params)
		params >>> [			
			new ThreadPoolExecutor(
				corePoolSize, 
				maximumPoolSize, 
				keepAliveTime, 
				unit, 
				workQueue, 
				threadFactory, 
				handler)
		]
	}

}
