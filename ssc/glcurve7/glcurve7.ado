*! version 2.0 Philippe Van Kerm - Stephen P. Jenkins, 19 Feb 2001 (TSJ-1: gr0001)
*! version 1.2 Stephen P. Jenkins - Philippe Van Kerm, Apr 1999 STB-49 sg107.1
* Syntax: glcurve7 y [fw aw] [if in], [GLvar(x1) Pvar(x2) SOrtvar(svar) 
*            Lorenz RTIP(string) ATIP(string)
*            BY(gvar) SPlit GRaph REPLACE graph_options]

cap pr drop glcurve7
pr def glcurve7

	version 7.0
	syntax varname [if] [in] [fweight aweight] /*
		*/ [, GLvar(string) Pvar(string) SOrtvar(varname) /*
		*/ Lorenz RTIP(string) ATIP(string) /*
		*/ BY(varname numeric) SPlit NOGRaph REPLACE /*
		*/ Symbol(string) Connect(string)* ] 

	tempvar inc cumwy cumw maxw badinc touse wi gl p
	tempname byname
	
	if "`nograph'"~="" {loc graph ""}
	else {loc graph "graph"}

	if "`by'"~="" {
		if "`graph'"~="" & "`split'"=="" {
			di in red "-split- must be used to combine -by()- with a graph." _c
        di in red " -nograph- option assumed."
			loc graph = ""  
			}
		}
	else {
		if "`split'"~="" {
			di in red "Option -split- must be combined with -by()-." _c
			di in red " -split- ignored."
			loc split ""
			}
		}

	if "`replace'"~="" {
		if "`split'"~="" & "`by'"~="" {
*			loc prefix = substr(trim("`glvar'"),1,4)
			loc prefix "`glvar'"  /* new OK with Stata 7 long names! */
			cap drop `prefix'_*
			cap drop `pvar'
			}
		else {  
			cap drop `glvar'
			cap drop `pvar'
			} 
		}

	if "`weight'" == "" {qui ge byte `wi' = 1}
	else {qui ge `wi' `exp'}

	marksample touse 
	markout `touse' `sortvar' `by'

	if "`split'"==""{
		if "`glvar'" ~= "" {
			confirm new variable `glvar'
			di in blue "New variable " in ye "`glvar'" in blue " created."
			}
		else {tempvar glvar}
		}
	else {
		if "`glvar'" == "" {
			qui tab `by' `by' if  `touse', matrow(`byname')
			loc i = 1	
			while `i' <= rowsof(`byname') {
				tempvar newvar`i'
				loc i = `i'+1
				}
			}
		else {
			qui tab `by' `by' if  `touse', matrow(`byname')
*			loc prefix = substr(trim("`glvar'"),1,4)
			loc prefix "`glvar'"  /* new OK with Stata 7 long names */
			loc i = 1	
			while `i' <= rowsof(`byname') {
				loc suffix = `byname'[`i',1]
				loc newvar`i' "`prefix'_`suffix'" 
				confirm new variable `newvar`i''
   			di in blue "New variable " in ye "`newvar`i''" in blue " created."
				loc i = `i'+1
				}
			}
		}


	if "`pvar'" ~= "" {
		confirm new variable `pvar'
		di in blue "New variable " in ye "`pvar'" in blue " created."
		}
	else {tempvar pvar}

	qui gen `inc' = `varlist' if `touse' 

	if "`atip'"~="" {
		if "`rtip'"~=""{
			di in red "You cannot use options -atip()- and -rtip()- together." 
			exit
			}
		if "`lorenz'"~=""{
			di in red "You cannot use option -atip()- in conjunction with -lorenz-." 
			exit
			}
		qui replace `inc' = max(0,`atip'-`varlist')  if `touse' 
		if "`sortvar'" =="" {loc sortvar "`varlist'"}
		}

	if "`rtip'"~="" {
		if "`lorenz'"~=""{
			di in red "You cannot use option -rtip()- in conjunction with -lorenz-." 
			exit
			}
		qui replace `inc' = max(0,(`rtip'-`varlist')/`rtip')  if `touse' 
		if "`sortvar'" =="" {loc sortvar "`varlist'"}
		}



	
	quietly {

	count if `inc' < 0 & `touse'
	local ct = _result(1)
	if `ct' > 0 {
		noi di " "
		noi di in blue "Warning: `inc' has `ct' values < 0." _c
		noi di in blue " Used in calculations"
		}

	tempvar placebo
	if "`by'"=="" {
		gen `placebo' = 1
		loc by = "`placebo'"
		}

	if "`sortvar'" == "" {gsort `by' `inc'}
	else {gsort `by' `sortvar'}
	by `by': ge double `cumwy' = sum(`wi'*`inc') if `touse' 
	by `by': ge double `cumw' = sum(`wi') if `touse'
	egen `maxw' = max(`cumw') , by(`by') 
	ge double `pvar' = `cumw'/`maxw' if `touse'
	label variable `pvar' "Cum. Pop. Prop." 

	if "`split'"=="" {
				ge `glvar' = `cumwy'/`maxw' if `touse'
				if "`lorenz'"~=""{label variable `glvar' "Lorenz(`varlist')"} 
				  else {label variable `glvar' "GLorenz(`varlist')"} 
				if "`lorenz'"~=""{
					su `inc' [`weight' `exp'] if `touse', meanonly 					
					replace `glvar' = `glvar'/r(mean)
					}
				if "`graph'"~="" {
					if "`symbol'"=="" {loc symbol "i"}
					if "`connect'"=="" {loc connect "l"} 	
					graph `glvar' `pvar' if `touse', s(`symbol') c(`connect') `options' 
					} 
				}
	else {
		loc lname : value label `by'
		loc i = 1
		while "`newvar`i''"~="" {
			if "`sortvar'" == "" {gsort `by' `inc'}
			else {gsort `by' `sortvar'}
			by `by': ge `newvar`i'' = `cumwy'/`maxw'  /*		
					*/ if `touse' & `by'==`byname'[`i',1]
			if "`lorenz'"~=""{
				su `inc' [`weight' `exp'] if `touse' & `by'==`byname'[`i',1] , meanonly 					
				replace `newvar`i'' = `newvar`i''/r(mean)
				}
			if "`lname'"~="" {
				loc cl = `byname'[`i',1]
				loc lab : label `lname' `cl' 
				label variable `newvar`i'' "`varlist'[`lab']" 
				}
			local listvar "`listvar' `newvar`i''"
			loc i = `i'+1
			}
		if "`graph'"~="" {
			if "`symbol'"=="" {loc symbol "iiiiiiiiii"}
			if "`connect'"=="" {loc connect "ll[_]l[-]l[_..]l[.]l[-.-.]llll"} 	
			graph `listvar' `pvar' if `touse' , s(`symbol') c(`connect') `options' 
			} 
		}
	}

end
