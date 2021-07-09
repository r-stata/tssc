/*******************************************************************************

					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de
								   
                    * Synlight package comes with no warranty *


	
	Synlight version 1.0  August, 2014 
	Synlight version 1.1  September, 2014 */
	
	program synlightversion
		version 11
		
		*> make sure that Stata does not repeat this every time
		if "$thenewestsynlightversion" == "" {
				
				cap qui do "http://www.stata-blog.com/packages/update.do"
				
				}
				
		global synlightversion 1.1
				
		if "$thenewestsynlightversion" > "$synlightversion" {
				
				di _n(4)
				
				di "  _   _           _       _                __  " _n ///
" | | | |_ __   __| | __ _| |_ ___       _  \ \ " _n ///
" | | | | '_ \ / _` |/ _` | __/ _ \     (_)  | |" _n ///
" | |_| | |_) | (_| | (_| | ||  __/      _   | |" _n ///
"  \___/| .__/ \__,_|\__,_|\__\___|     (_)  | |" _n ///
"       |_|                                 /_/ "  _n ///


		di as text "{p}{bf: Synlight} has a new update available! Please click on " ///
		`"{ul:{bf:{stata "adoupdate synlight, update":Update Synlight Now}}} to update the package"'
				
		di as text "{p}For more information regarding the new features of {help synlight}, " ///
		`"see the {browse "http://stata-blog.com/synlight.php":{it:http://stata-blog.com/synlight}}"'		
				
				}
				
				
	end
