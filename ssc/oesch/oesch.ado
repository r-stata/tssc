********************************************************************************
* This is a little helper script to create 8- and 5-class versions of Oesch 
* class variables, based on code by Amal Tawfik, University of Geneva
* found at http://people.unil.ch/danieloesch/scripts/
* 
*
* see 'help oesch' for more Info
*
********************************************************************************
* May 2018 - Simon Kaiser, University of Bern
********************************************************************************

program define oesch
		version 7
		syntax newvarname, oesch(varname numeric) [eight five replace]
		
		tempvar originType
		
		qui levelsof `oesch'
		if "`r(levels)'" != "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16" {
			display as error "Error: The input variable is not coded correctly. Levels are not 1-16."
			exit 110
		}
		
		
		if "`eight'"=="eight" | "`five'"!="five" {
		
			capture confirm variable oesch8_`varlist'
			if !_rc & "`replace'"!="replace" {
				display as error "Error: One or multiple of the variables to be generated already exist. Specify option 'replace' to overwrite them."
				exit 110
			}
		}
		
		if "`five'"=="five"{

			capture confirm variable oesch5_`varlist'
			if !_rc & "`replace'"!="replace" {
				display as error "Error: One or multiple of the variables to be generated already exist. Specify option 'replace' to overwrite them."
				exit 110
			}
		}
				
		tempvar originVar
		qui gen `originVar' = `oesch'
		
		if "`eight'"=="eight" | "`five'"!="five"{
		
			capture confirm variable oesch8_`varlist'
			if !_rc & "`replace'"=="replace" {
				drop oesch8_`varlist'
			}
			qui recode `originVar' (1 2=1)(3 4=2)(5 6=3)(7 8=4)(9 10=5)(11 12=6)(13 14=7)(15 16=8), gen(oesch8_`varlist')
		
			display as text "Created 8-class variable:"
			ds oesch8_`varlist'
		
			label variable oesch8_`varlist' "`varlist' Oesch class position - 8 classes"
			label define oesch8_`varlist' ///
			1 "Self-employed professionals and large employers" ///
			2 "Small business owners" ///
			3 "Technical (semi-)professionals" ///
			4 "Production workers" ///
			5 "(Associate) managers" ///
			6 "Clerks" ///
			7 "Socio-cultural (semi-)professionals" ///
			8 "Service workers", replace
			label value oesch8_`varlist' oesch8_`varlist'
			tab oesch8_`varlist'
			
		}
		
		if "`five'"=="five"{

			capture confirm variable oesch5_`varlist'
			if !_rc & "`replace'"=="replace" {
				drop oesch5_`varlist'
			}
			qui recode `originVar' (1 2 5 9 13=1)(6 10 14=2)(3 4=3)(7 11 15=4)(8 12 16=5), gen(oesch5_`varlist')
			
			display as text "Created 5-class variable:"
			ds oesch5_`varlist'
			
			label variable oesch5_`varlist' "`varlist' Oesch class position - 5 classes"
			label define  oesch5_`varlist' ///
			1 "Higher-grade service class" ///
			2 "Lower-grade service class" ///
			3 "Small business owners" ///
			4 "Skilled workers" ///
			5 "Unskilled workers", replace
			label value oesch5_`varlist' oesch5_`varlist'
			tab oesch5_`varlist'
			
		}
		
end
