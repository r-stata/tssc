*! 1.0.0 NJC 9 August 2016 
program lvalues, sort 
	version 11.2 
	syntax varlist(numeric) [if] [in] ///
	[, GENerate(string) BY(varlist) A(real `=1/3') List * DISPLAYonly] 

	// observations to use 
	marksample touse 
	quietly count if `touse' 
	if r(N) == 0 exit 2000 

	// check variable names (default or supplied) 
	local nvars : word count `varlist' 
	local nneed = `nvars' + 3 

	// display only: use temporary names 
	if "`displayonly'" != "" {
		if "`generate'" != "" { 
			noisily di as txt "{p}displayonly and generate() " ///
			"incompatible: generate() ignored{p_end}" 
			local generate 
		}	

		forval j = 1/`nneed' { 
			tempvar g 
			local generate `generate' `g' 
		}
	} 

	// new variables to be created 
	else { 
		// default names 
		forval j = 1/`nvars' { 
			local default `default' _lv`j' 
		} 
		local default `default' _rank _depth _ppos 
		capture confirm new var `default' 

		// if default names won't work, and no user specification, 
		// then bail out now 
		if "`generate'" == "" & _rc { 
			di as err "default names `default' problematic" 
			exit _rc 
		} 
	 
		// if user specification, make up any gaps from default, 
		// and then test whether new 
		if "`generate'" != ""  { 
			local g "`generate'" 
			local nnew : word count `g'  

			if `nnew' > (`nvars' + 3) { 
				di as err "too many new variable names" 
				exit 498 
			} 
			else if `nnew' < (`nvars' + 3) { 
				if `nnew' == (`nvars' + 2) local g `g' _ppos 
				else if `nnew' == (`nvars' + 1) local g `g' _depth _ppos 
				else if `nnew' == `nvars' local g `g' _rank _depth _ppos 
				else { 
					local nlack = `nvars' - `nnew' 
					forval j = 1/`nlack' { 
						local g `g' _lv`j' 
					}
					local g `g' _rank _depth _ppos 
				}
			}

			capture confirm new var `g' 
			if _rc { 
				di as err "implied names `g' problematic" 
				exit _rc 
			} 

			local generate `g'  
		} 

		// otherwise, use default 
		else local generate `default' 
	}

	// by() option? 
	if "`by'" == "" { 
		tempvar by 
		gen byte `by' = 1 
	} 
	else quietly { 
		tempvar group 
		egen `group' = group(`by') if `touse' 
		local byvar `by' 
		local by `group'
	} 
	su `by', meanonly 
	local nby = r(max) 

	// main call 
	tempvar thisuse 
	gen byte `thisuse' = 0 

	local first = 1 
	quietly forval i = 1/`nby' { 
		replace `thisuse' = -`touse' * (`by' == `i') 
		sort `thisuse', stable 

		// on first call, `first' is 1, but not afterwards 
		mata: mylvalue("`varlist'", "`thisuse'", "`generate'", `first', `a') 

		local first = 0 
	} 

	// variable labels; compress 
	local newnames `generate' 
	tokenize `varlist' 

	if "`displayonly'" != "" { 
		forval j = 1/`nvars' { 
			gettoken v generate : generate 
			local newvars `newvars' `v' 
			char `v'[varname] "``j''" 
		} 

		tokenize "`generate'" 
		char `1'[varname] "rank" 
		char `2'[varname] "depth" 
		char `3'[varname] "fraction" 
		format `3' %4.3f 

		local sub subvarname  
		local list list 
	}
	
	else { 

		forval j = 1/`nvars' { 
			local vlbl : var label ``j'' 
			gettoken v generate : generate 
			local newvars `newvars' `v' 
			if `"`vlbl'"' != "" label var `v' `"`vlbl'"' 
			else label var `v' "``j'' 
		} 

		tokenize "`generate'" 
		label var `1' "rank" 
		label var `2' "depth" 
		label var `3' "fraction" 
		format `3' %4.3f 
	
	} 

	quietly compress `newnames' 

	/// optional list 
	if "`list'" != "" { 
		quietly replace `thisuse' = -`thisuse' 
		sort `thisuse', stable 

		if "`byvar'" != "" { 
			if `"`options'"' == "" { 
				local options noobs sepby(`byvar') `sub' 
			} 
			list `byvar' `generate' `newvars' if `3' < ., `options' 
		} 
		else { 
			if `"`options'"' == "" local options noobs sep(0) `sub' 
			list `generate' `newvars' if `3' < ., `options' 
		} 
	} 
end 

mata: 

void mylvalue(
string scalar varlist, 
string scalar tousename, 
string scalar newnames, 
numeric scalar first, 
numeric scalar a 
) { 

real matrix data  
real vector work, ranks, depths 
scalar n, j, d, nout 
string scalar varname 

st_view(data = ., ., varlist, tousename) 
n = rows(data) 

if (n <= 7) { 
	ranks = (1::n) 
}
else { 
	d = (1 + n)/2 
	ranks = (floor(d), (d == floor(d) ? d : ceil(d)))   

	while(d > 1) {
		d = (1 + floor(d))/2 
		ranks = ranks \ (floor(d) , (d == floor(d) ? d : ceil(d))) 
	} 

	ranks = ranks \ (1 :+ n :- ranks[|2,1 \ rows(ranks),2|]) 
	ranks = sort(ranks, (1, 2)) 
} 

nout = rows(ranks) 
newnames = tokens(newnames)

for(j = 1; j <= cols(data); j++) { 
	work = sort(data[., j], 1)
	varname = newnames[j] 
	if (first) (void) st_addvar("double", varname)
	if (n <= 7) st_store(1::nout, varname, work[ranks])  
	else st_store(1::nout, varname, (work[ranks[,1]] + work[ranks[,2]])/2)  
} 

varname = newnames[cols(newnames) - 2] 
if (first) (void) st_addvar("double", varname)
if (n > 7) ranks = (ranks[,1] + ranks[,2])/2 
st_store(1::nout, varname, ranks)

varname = newnames[cols(newnames) - 1] 
if (first) (void) st_addvar("double", varname)
depths = rowmin((ranks, ranks[nout..1])) 
st_store(1::nout, varname, depths)

varname = newnames[cols(newnames)] 
if (first) (void) st_addvar("double", varname)
st_store(1::nout, varname, ((ranks :- a) :/ (n - (2 * a) + 1)))
  
} 
    	
end 

