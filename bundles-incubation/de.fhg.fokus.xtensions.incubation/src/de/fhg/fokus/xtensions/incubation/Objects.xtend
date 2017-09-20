package de.fhg.fokus.xtensions.incubation

class Objects {
	
	public static def <T> T recoverNull(T toTest, =>T recovery){
		if(toTest !== null) {
			toTest
		} else {
			recovery.apply
		}
	}
	
}