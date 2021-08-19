/*

							  Stata Weaver Package
					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de

		
                  The Weaver Package comes with no warranty 
				  
	weaverversion checks the most recent published version of the Weaver package
	and notifies the user if there is an available update.
*/

	
program define weaverversion
	version 11
		
	cap qui do "http://www.haghish.com/packages/update.do"
		
	global weaverversion 3.38
	global weavermathversion 2.0

	if "$thenewestweaverversion" > "$weaverversion" {
				
		di _n(4)
				
		di "  _   _           _       _                __  " _n 				///
		   " | | | |_ __   __| | __ _| |_ ___       _  \ \ " _n 				///
		   " | | | | '_ \ / _` |/ _` | __/ _ \     (_)  | |" _n 				///
		   " | |_| | |_) | (_| | (_| | ||  __/      _   | |" _n 				///
		   "  \___/| .__/ \__,_|\__,_|\__\___|     (_)  | |" _n 				///
		   "       |_|                                 /_/ " _n 				///


		di as text "{p}{bf: Weaver} has a new update available! Click on " 		///
		`"{ul:{bf:{stata "adoupdate weaver, update":Update Weaver Now}}} "' 	///
		"or alternatively type {ul: {bf: adoupdate weaver, update}} to update " ///
		"the package"
				
		di as text "{p}For more information regarding the new features of " 	///
		`"Weaver, visit {browse "http://haghish.com/weaver"}{smcl}"' 
					
	}
	
end
