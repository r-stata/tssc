program def anovaplot7, sort 
*! renamed 14 Feb 2003  
*! 1.1.2 NJC 27 Sept 2001 
	version 7.0
	syntax [varlist(max=3 numeric default=none)] /* 
	*/ [ , Connect(str) L1title(str) Symbol(str) XLAbel XLAbel(str) /* 
	*/ YLAbel YLabel(str) SOrt TItle(str) * ]

	* initial checking and picking up what -anova- leaves behind 
	if "`e(cmd)'" != "anova" { 
		di as err "anova estimates not found" 
		exit 301 
	} 

	local covars "`e(varnames)'" 
	local ncovars : word count `covars'
	if `ncovars' > 3 { 
		di as err "too many covariates: should be 1, 2 or 3" 
		di as txt "(covariates: `covars')" 
		exit 103 
	} 	

	if "`varlist'" != "" { 
		local nvars : word count `varlist' 
		if `nvars' != `ncovars' { 
			Nomatch "`varlist'" "`covars'" 
		}	
         	foreach var of local varlist {
			local found = 0 
			foreach cov of local covars { 
				if "`cov'" == "`var'" { 
					local found = 1 
				}	
			}
			if !`found' { 
				Nomatch "`varlist'" "`covars'"  
			}
		}
		local covars "`varlist'" 
	}	

	local response "`e(depvar)'" 
	tokenize `response' `covars' 
	args y x1 x2 x3

	if "`x2'" != "" {
		qui tab `x2' if e(sample) 
		if r(r) > 19 { 
			di as error "too many groups in `x2': maximum 19" 
			exit 198 
		}
		local nlines = r(r) 
	}	
	else local nlines = 1 

	* get fit 
        tempvar fit
	qui predict `fit' if e(sample) 

	* this depends on Stata 7 dropping variables with a tempname as stub 
	if "`x2'" != "" { 
		tempname sep 
		qui separate `fit', by(`x2') gen(`sep')
	        unab fits : `sep'* 
		
		* fix variable labels 
		foreach v of varlist `fits' { 
			local label : variable label `v'
			local pos = index(`"`label'"',",") 
			local label = substr(`"`label'"',`pos' + 2,.)
			label variable `v' `"`label'"' 
		} 
	} 
	else local fits "`fit'"

	* set up graph defaults 
	if "`connect'" == "" { 
		local l : di _dup(`nlines') "l" 
		local connect ".`l'" 
	}
	
	* -anova_terms- added to Stata 6 Sept 2001
	if "`symbol'" == "" { 
		capture anova_terms 
		if _rc == 0 { 
			if "`x1'" == "`r(continuous)'" { 
				local nfits : word count `fits' 
				local invis : di _dup(`nfits') "i" 
			} 	
		} 	
		if "`invis'" == "" { 
			if "`x2'" != "" { 
				local symbol "[`x2']OSTopxdOSTopxdOSTop" 
			} 	
			local symbol "OSTopxdOSTopxdOSTopx"
		} 	
		else { 
			if "`x2'" != "" { 
				local symbol "[`x2']`invis'" 
			} 	
			else local symbol "O`invis'" 
		} 	
	}
	
	if `"`l1title'"' == "" { 
		local what : variable label `y'
		if `"`what'"' == "" { local what "`y'" } 
		if substr("`symbol'",1,1) == "i" { 
			local l1title "fit for `what'" 
		}
		else local l1title "data and fit for `what'" 
	} 
	
	if "`ylabel'" == "" { local yl "ylabel" } 
	else if "`ylabel'" != "ylabel" { local yl "yla(`ylabel')" }
	
	if "`xlabel'" == "" { local xl "xlabel" } 
	else if "`xlabel'" != "xlabel" { local xl "xla(`xlabel')" } 

	if "`x3'" != "" { 
		local byby "by(`x3')" 
		sort `x3'  
	} 

	if "`title'" == "" { local title " " } 
	
	* graph
	gra `y' `fits' `x1' if e(sample), co(`connect') l1(`"`l1title'"') /* 
	*/ ti(`"`title'"') sort `xl' `yl' s(`symbol') `byby' `options'  

end

program def Nomatch 
	version 7
	args v c 
	di as txt "`v'" as err " not a permutation of " as txt "`c'"
	exit 498 
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

