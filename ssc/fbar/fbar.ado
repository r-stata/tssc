program def fbar, sort   
*! NJC 1.1.1 20 June 2001 
* NJC 1.1.0 19 June 2001 
* NJC 1.0.0 15 June 2001
	version 7.0 
	syntax varname [if] [in] [aweight fweight iweight/] /* 
	*/ [ , L2title(str) B2title(str) T2title(str) PERCent Totalpc /* 
	*/ BY(varname) YLAbel YLAbel(str) Gap(int 4) Fsort RFsort * ]

	if "`fsort'" != "" & "`rfsort'" != "" { 
		di in r "must choose between fsort and rfsort options" 
		exit 198 
	} 
	
	* set up `touse' and test any by()
	marksample touse, strok 
	if "`by'" != "" { 
		markout `touse' `by', strok 
		qui tab `by' if `touse' 
		if `r(r)' > 6 { 
			di in r "too many categories in by() variable"
			exit 198 
		} 	
	}
	
	* initialise `q', quantity to be summed 
	tempvar q 
	gen `q' = `touse' 
	if "`exp'" != "" { qui replace `q' = `q' * `exp' }
	
	* percents?
	if "`totalpc'" != "" { local percent "percent" } 

	qui if "`percent'" != "" { 
		if "`by'" == "" | "`totalpc'" != "" {
			su `q', meanonly
			replace `q' = `q' * (100 / r(sum))  
			local pctext "percent of total" 
		} 
		else { 
			tempvar bysum
			sort `varlist' 
			by `varlist' : gen `bysum' = sum(`q')
			by `varlist' : replace `bysum' = `bysum'[_N] 
			replace `q' = `q' * (100 / `bysum') if `q' 
			local pctext "percent of category" 
		} 	
	}	
	
	* set up what is to be shown 
	if "`by'" == "" { 
		local show "`q'" 
	} 
	else { 
		qui separate `q' if `touse', by(`by') 
		local show "`r(varlist)'" 
		foreach X of varlist `show' { 
			local label : variable label `X' 
			local pequal = index(`"`label'"',"=") 
			local label = substr(`"`label'"',`pequal' + 2, .) 
			label variable `X' `"`label'"'
		} 
	}	
	
	* b2title default 
	if `"`b2title'"' == "" { 
		local label : variable label `varlist' 
		if length("`label'") == 0 | length("`label'") > 50 { 
			local label "`varlist'" 
		}	
	        local b2title `"`label'"' 
	} 
	
	* l2title default 
	if `"`l2title'"' == "" { 
		local l2title = cond("`percent'" != "", "`pctext'", "frequency") 
		if "`by'" != "" { 
			local label : variable label `by' 
			if length("`label'") == 0 | length("`label'") > 32 { 
				local label "`by'" 
			}	
		        local l2title `"`l2title', subdivided by `label'"' 
		} 
	}

	* t2title default blank with one variable 
	if `"`t2title'"' == "" & "`by'" == "" { local t2title " " }
	
	* ylabel  
	if "`ylabel'" == "" { local ylabel "ylabel" } 
	else if "`ylabel'" != "ylabel" { 
		local ylabel "yla(`ylabel')" 
	} 

	* sort order 
	sort `varlist' 
	qui if "`fsort'`rfsort'" == "" /* 
	*/ | ("`by'" != "" & "`percent'" != "" & "`totalpc'" == "") { 
		local sortvar "`varlist'" 
	}
	else qui { 
		tempvar freq which id 
		tempname wlabel 
		capture confirm string variable `varlist' 
		local isstr = cond(_rc == 0, "*", "") 
		
		* category frequencies 
		by `varlist' : gen `freq' = sum(`q') 
		if "`fsort'" != "" { 
			by `varlist' : replace `freq' = `freq'[_N] 
		} 
		else by `varlist': replace `freq' = -`freq'[_N] 
		
		* mapping labels and sorting 
		sort `touse' `freq' `varlist'
		by `touse' `freq' `varlist' : gen `which' = (_n == 1) * `touse' 
		replace `which' = sum(`which')
		gen long `id' = _n 
		su `which', meanonly
		forval i = 1 / `r(max)' { 
			su `id' if `which' == `i', meanonly  
			local label = `varlist'[`r(min)'] 
			`isstr' local label : label (`varlist') `label' 
			label def `wlabel' `i' `"`label'"', modify 
		} 
		label val `which' `wlabel'
		sort `which'
		local sortvar "`which'" 
	} 

	graph `show' if `q', bar `options' `ylabel' gap(`gap') /* 
	*/ by(`sortvar') l2("`l2title'") b2("`b2title'") t2("`t2title'") 
 
end    

