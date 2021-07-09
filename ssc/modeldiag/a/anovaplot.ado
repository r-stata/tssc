*! 2.1.1 NJC 6 November 2004 
* 2.1.0 NJC 29 October 2004 
* 2.0.0 NJC 16 Feb 2003 
* 1.1.2 NJC 27 Sept 2001 
program anovaplot, sort 
	version 8.0
	syntax [varlist(max=3 numeric default=none)] /// 
 	[ , SOrt SCatter(str asis) plot(str asis) * ]

	// initial checking and picking up what -anova- leaves behind 
	if "`e(cmd)'" != "anova" { 
		di as err "anova estimates not found" 
		exit 301 
	} 

	local covars "`e(varnames)'" 
	if `: word count `covars'' > 3 { 
		di as err "too many predictors: should be 1, 2 or 3" 
		di as txt "(predictors: `covars')" 
		exit 103 
	} 	

	if "`varlist'" != "" { 
		if !`: list covars === varlist' {  
			di as txt "`varlist'" /// 
			as err  " not a permutation of " as txt "`covars'"
			exit 498 
		}
		local covars "`varlist'" 
	}	

	local response "`e(depvar)'" 
	tokenize `response' `covars' 
	args y x1 x2 x3

	quietly { 
		// get fit 
        	tempvar fit
		predict `fit' if e(sample) 

		if "`x2'" != "" {
			tempvar touse obsno group  
			gen `touse' = e(sample) 
			bysort `touse' `x2' : gen byte `group' = ///
				_n == 1 & `touse' 
			gen long `obsno' = _n 
			replace `group' = sum(`group')
			forval i = 1 / `= `group'[_N]' {
				tempvar f 
				gen `f' = `fit' if `group' == `i'
				su `obsno' if `group' == `i', meanonly
				local value = `x2'[`r(min)'] 
				local lbl : label (`x2') `value' 
				label var `f' `"`lbl'"' 
				local fits "`fits'`f' " 
			} 
			local sub `"`: variable label `x2''"' 
			if `"`sub'"' == "" local sub "`x2'" 
			local sub "sub(`"Profiles by `sub'"', place(w))"  
 			if "`x3'" != "" local sub3 `sub' 
			else local sub2 `sub' 
		} 
		else local fits "`fit'"
	
		// set up graph defaults
		numlist "2/`= 1 + `: word count `fits'''" 
		local order "`r(numlist)'"

		local what : variable label `y'
		if `"`what'"' == "" local what "`y'" 
		local ytitle "yti("`what'")" 
		if "`x3'" != "" local byby "by(`x3', `sub3')"
		 
		anova_terms 
		local cont "`r(continuous)'" 
		if !`: list x1 in cont' { 
			levels `x1' if e(sample), local(levels) 
			local xla "xla(`levels', valuelabels)" 
		} 	
		else local ms "ms(none ..)" 
  	} 
	
	// graph
	twoway scatter `y'  `x1' if e(sample), `scatter'                 /// 
	|| connected `fits' `x1' if e(sample),                           ///
	`ms' `xla' `ytitle' sort `byby' `sub2' legend(order(`order') pos(5)) ///  
	`options' ///
	|| `plot' 
end

/* Possibilities for future, suggested by Ken Higbee 7 Sept 2001: 

For small datasets plotting the points can be helpful, but even in those cases,
I find that the data labels (or even just plain numbers) fill up the plot to
the point that you can not see the forest because of all the trees.  I think
that an easier to view plot could be produced using more of an approach like
the -serrbar- command.  I am thinking along the lines of using -adjust- which
in addition to giving you the linear predictions can also give the errors.
[...]   
I would probably have some option that allowed you to get the data points
plotted and/or the error bars for each adjusted cell prediction.

With more than 3 vars, I believe to get meaningful views you need to set the
extra vars to some value (by default their mean for continuous vars and one of
the levels for a categorical var).  I would have it default to means for
continuous vars and first level for categorical vars with some syntax that
would allow users to specify if they desire something else.

*/ 


