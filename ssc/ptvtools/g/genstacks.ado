capture program drop genstacks
program define genstacks
	version 9.0
	syntax namelist, [CONtextvars(varlist)] [STAckid(name)] [ITEmname(name)] [TOTstackname(name)] [REPlace] [RESpid(name)] [NOCheck] [fe(namelist)] [FEPrefix(string)]
	
	gettoken firststub otherstubs: namelist
	
	// namelist contains stubs
	// stackvars contains vars which identify a set of PTVS: e.g. cid respid

	set more off
	
	display in smcl
	display as text

	display "{text}{pstd}"
	
		
		/* diagnosing batteries with different sizes: */
		
		if ("`nocheck'"!="nocheck") {
		
			local diffsize = 0
			local previousvarsize = 0
			foreach stub of local namelist {
				local varexists = 0
				if (`varexists'!=`previousvarsize') local diffsize = 1
				
				//display "`stub'*"
				
				
				
				foreach var of varlist `stub'* {
					
					// if what comes after the stub is not numeric, skip
					// this is useful if different batteries share part of the stub (e.g. rsym and rsymp)
					local strindex = substr("`var'",strlen("`stub'")+1,.)
					//display "`strindex'"
					
					if (real("`strindex'")==.) continue
					
					local varexists = `varexists' + 1
				}
				
				
				if (`varexists'==0) {
					// unreachable anyway: it stops earlier with an error 
					display "No variables starting with {bf:`stub'}"
					exit
				}
				else {
					display "Battery {bf:`stub'} contains `varexists' variables{break}"
				}
				local previousvarsize = `varexists'
			}
			display ""
			if (`diffsize'==1) {
				display "ERROR: Not all batteries have the same size!"
				display "Processing stopped."
				error 416
			}
		}
		/* */
		
		
		
		
		
		
		
		//local itemlist = ""
				
		foreach var of varlist `firststub'* {
			local strindex = substr("`var'",strlen("`firststub'")+1,.)
			if (real("`strindex'")==.) continue
			
			//local itemlist = "`itemlist'`strindex',"
			local itemlist `itemlist' `strindex'
			
		}
		// remove extra comma
		//local itemlist = substr("`itemlist'",1,strlen("`itemlist'")-1)
		
		display "***`itemlist'***"
		
		local error = 0
		
		foreach stub of local otherstubs {
			
			foreach var of varlist `stub'* {
				local strindex = substr("`var'",strlen("`stub'")+1,.)
				
				if (real("`strindex'")==.) continue
				
				local thisindex = real("`strindex'")
				local thislist `thisindex'
				
				local isinlist : list thislist in itemlist
				
				display "--(`isinlist')--`thislist' > `itemlist'"
				//if (inlist(real("`strindex'"),`itemlist')==0) {
				if (`isinlist'==0) {
					display "ERROR: battery {bf:`stub'} includes item with code {bf:`strindex'}, which is not present in master battery {bf:`firststub'}.{break}"
					local error = 1
				}
			}
			if (`error'==1) {
				display " {break} {break}"
			}
		}
		
		if (`error'==1) {
			display "Processing stopped."
			error 416
		}
	
	display ""
	
	display "{text}{pstd}"
	
	
	capture drop _respid
	egen _respid=fill(1/2)
	local stkvars = "_respid"
	
	if ("`contextvars'" == "") {
		//display "not set"
		capture drop _ctx_temp
		gen _ctx_temp = 1
		local ctxvar = "_ctx_temp"
		//local stkvars = "_ctx_temp `stackvars'"
	}
	else {
		
		capture drop _ctx_temp
		capture label drop _ctx_temp
		quietly _mkcross `contextvars', generate(_ctx_temp) missing
		
		//display "contextvar set as `contextvar'"
		local ctxvar = "_ctx_temp"
		//local stkvars = "`stackvars'"
	}
	
	//exit
	
	// loads all values of the context variable
	quietly levelsof `ctxvar', local(contexts)
	
	// stacked variable "party" can be different from stacked variable "stack", if parties are not always used consecutively!!!
	capture drop genstacks_stack
	capture drop genstacks_item
	
	quietly generate genstacks_stack = .
	quietly generate genstacks_item = .
	
	// create stacked variables
	foreach stub of local namelist {
		display "Creating empty stacked variable {result:`stub'}..." _continue
		capture drop `stub'
		quietly gen `stub' = .
		display "done.{break}"
	}	
	
	display ""
	
	capture drop genstacks_totstacks
	generate genstacks_totstacks = .
	
	// now the beef.
	
	// loops over all contexts
	foreach context in `contexts' {
		display "{text}{pstd}Context {result:`context'} uses " _continue
		
		/* 1. finding used PTVs in this context */
		// NOTE: ONLY THE FIRST STUB IS USED
		// FOR TESTING how many parties are used
		
		
		// count observations in this context
		quietly count if `ctxvar'==`context'
		quietly return list
		local numobs = r(N)
		
		local countUsedPTVs = 0
		local usedPTVs = ""
		
		// new
		//display "Looping over stubs"
		
		local countProcessedStubs = 0
		
		foreach stub of local namelist {
			local theseIndices = ""
			
			//display "`stub' ["
			
			foreach var of varlist `stub'* {
				// if what comes after the stub is not numeric, skip
				// this is useful if different batteries share part of the stub (e.g. rsym and rsymp)
				local strindex = substr("`var'",strlen("`stub'")+1,.)
				//display "`strindex'"
				if (real("`strindex'")==.) continue
				
				
				// count missing values for this item within this context
				quietly count if `var'==. & `ctxvar'==`context'
				quietly return list
				local missingptvs = r(N)
				
				// if no. of missing values less than no. of observations, this PTV is used
				if `missingptvs'<`numobs' {
					local theseIndices "`theseIndices' `strindex'"
				}
			}
			//display "`theseIndices'] "
			if (`countProcessedStubs'==0) {
				local usedIndices "`theseIndices'"
			}
			else {
				local usedIndices: list usedIndices | theseIndices
				
				// this is alphabetical!
				//local usedIndices: list sort usedIndices
			}
			local countProcessedStubs = `countProcessedStubs' + 1
			//display "`usedIndices'"
		}
		
		local countUsedIndices : list sizeof usedIndices
		
		display "{result:`countUsedIndices'} items" " " "({result:" trim("`usedIndices'") "})." _continue
		display ""
		
		replace genstacks_totstacks = `countUsedIndices' if `ctxvar'==`context'

		/* 2. expanding and numbering stacks */
		
		//{text}{pmore}
		display "{break}Expanding cases..." _continue
		
		// expand cases
		quietly expand `countUsedIndices' if `ctxvar'==`context'	    /* create as many cases as ptvs in country */
		// assign stack number
		quietly: bysort `stkvars': replace genstacks_stack = _n if `ctxvar'==`context' /* stack variable identifies each case 
									  within each respondent id                */
		
		display "done. " _continue //{break}
		
		/* 3. copying data */
		
		display "Copying values: " _continue
		
		// processing different stubs
		foreach stub of local namelist {
			
			local stack = 0
			//display "Copying values for `stub' (" _continue
			display " `stub'" _continue
			foreach thisIndex in `usedIndices' {
				local stack = `stack' + 1
				//local thisIndex = subinstr("`thisptv'", "`ptvstub'","",.)
				
				//display "`stub'" "`thisIndex' " _continue
				capture quietly replace `stub' = `stub'`thisIndex' if genstacks_stack==`stack' & `ctxvar'==`context'
				if _rc {
					//display "WARNING: `_rc'"
				}
				
				quietly replace genstacks_item = `thisIndex' if genstacks_stack==`stack' & `ctxvar'==`context'
			}
			// )
			//display "done." _continue
			//display ""
		
		}
		display ""
		display ""
		
	}

	display "{text}{pstd}"
	
	// labeling, based on last usedPTVs
	foreach stub of local namelist {

		gettoken firstIndex : usedIndices
		
		//local firstIndex = subinstr(word("`usedIndices'",1), "","",.)
		local firstvar = "`stub'" + "`firstIndex'"
		local label1 : variable label `firstvar'
		local valindex = strpos("`label1'", "`firstIndex'")
		//local label = subinstr("`label1'", "`firstIndex'","_",.)
		local label = substr("`label1'", 1, `valindex'-1)
		display "Labeling {result:`stub'}: `label'"
		label var `stub' "`label'*" // copy from first label, by replacing 'stack' with nothing		
		display "{break}"
	}
	
	display ""
	
	// optionally dropping original vars
	if ("`replace'"=="replace") {
		display "{text}{pstd}"
		foreach stub of local namelist {
			// preserve new, stacked vars (they have plain stub names)
			quietly rename `stub' tmp`stub'
			display "As requested, dropping {result:`stub'*}.{break}"
			drop `stub'*	
			quietly rename tmp`stub' `stub' 
		}
	}
	
	sort `stkvars' genstacks_stack	
	
	if ("`fe'"!="") {
		if ("`feprefix'"!="") {
			local fpref = "`feprefix'"
		}
		else {
			local fpref = "mean_"
		}
		
		display "{text}{pstd}Applying fixed-effects treatment (saving and subtracting the respondent-level mean){break}"
		display "to variables "
		foreach var of local fe {
			display "`var'..."
			capture drop `fpref'`var'
			bysort _respid: egen `fpref'`var' = mean(`var')
			replace `var' = `var' - `fpref'`var'
		}
		display "{break}done."
	}
	
	
	if ("`respid'"!="") {
		rename _respid `respid'
	}
	else {
		capture drop _respid
	}
	
	
	//if ("`contextvar'"=="") {
		capture drop _ctx_temp
	//}
	
	// NOTE: this drops existing variables if the user specifies them as names of variables to create,
	// and does so without requiring a "replace" option (this might be contra Stata practices)
	
	if ("`stackid'"!="") {
		capture drop `stackid'
		rename genstacks_stack `stackid'
	}
	
	if ("`itemname'"!="") {
		capture drop `itemname'
		rename genstacks_item `itemname'
	} 

	if ("`totstackname'"!="") {
		capture drop `totstackname'
		rename genstacks_totstacks `totstackname'
	}
	else {
		capture drop genstacks_nstacks
		rename genstacks_totstacks genstacks_nstacks
	}

	
end
