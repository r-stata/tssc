// postestimation command of boost : make a  barchart of influence of variables in boosting
// command uses e(influence) from the preceeding boost command
// creates variable "influence"

program influence_barchart 
	version 14.0
	syntax  , [ MIN_influence(real -1) CATegory(int 1) top(int 15) plotonly tidytext(str) counttext   * ]

	if ("`plotonly'"=="") {

		matrix influence = e(influence)
		confirm matrix e(influence)
		local mynames : rownames influence
		// di "`mynames'"

		tempvar id
		qui gen `id'=""
		local k : word count `mynames' 
		// if more variables than obs
		if `k'>_N {
			set obs `k'
		}

		forvalues i = 1(1)`k' {
			local aword : word `i' of `mynames'
			capture confirm variable `aword'
			if !_rc {
			local alabel : variable label `aword'
			}
			if ("`alabel'"!="") 	qui replace `id'= "`alabel'" in `i'
			else 			qui replace `id'= "`aword'" in `i'
		}

		// Stata bug in graph hbar: plotting problem when single quote ' in the label.
		// see  http://www.statalist.org/forums/forum/general-stata-discussion/general/393872-make-room-for-labels-on-bar-or-hbar
		// remove all single quotes ' 
		// when specifying the fourth argument, 10, this works. When omitting it, it does not work.
		qui gen influence_id=  ustrtrim(subinstr(`id',"'","",10))
		cap svmat influence	
		if _rc!=0 di as err "Variables Influence1,...,Influence# could not be created; they may exist already"
	}
	if ("`tidytext'"!="") {
		qui replace influence_id=  ustrregexrf(influence_id,"`tidytext'$"," ")    // replace " in `tidytext'"  
	}
	if ("`counttext'"=="") {
		qui replace influence_id=  ustrregexrf(influence_id,"^# of "," ")  // if binarizing, remove " # of " at beginning  
	}
	local c = `category'
	confirm variable influence`c', exact 
	confirm variable influence_id, exact
	qui count if influence_id != ""
	local nxvars = r(N)
	local mypctile = 100 - `top' * 100 / `nxvars'
	local influence_pc = `min_influence'
	if `influence_pc' < 0 {
		if `mypctile' > 0 {
			_pctile influence`c', percentiles(`mypctile')
			local influence_pc = r(r1)
		}
		else local influence_pc = 0
	}
	
	
	graph hbar (asis) influence`c' if influence`c'>`influence_pc' & !missing(influence`c') , ///
		over(influence_id, sort(influence`c') descending) ///
		ytitle("Percentage Influence") `options'
end
