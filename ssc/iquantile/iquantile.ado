*! NJC 1.0.0 19 January 2009 
program iquantile, sort rclass 
version 9 
syntax varlist(numeric) [if] [in] [fweight aweight/] ///
[, p(numlist >0 <100 int) by(varlist) format(str) ABbreviate(int 12) * ] 

quietly { 
	if "`format'" != "" { 
		confirm numeric format `format' 
	} 

	marksample touse
	if "`by'" != "" markout `touse' `by', strok 
	count if `touse' 
	if r(N) == 0 error 2000

	if "`p'" == "" local p 50 
	local nq : word count `p' 

	tempvar w group work vuse guse 
	tempname iqu ep

	if "`weight'" != "" { 
		gen `w' = `exp' 
	}
	else gen byte `w' = 1 

	if "`by'" == "" { 
		tempvar by 
		gen byte `by' = 1 
	} 

	egen `group' = group(`by') if `touse' 
	su `group' if `touse', meanonly 
	local ng = r(max) 

	gen double `work' = .
	gen byte `vuse' = . 
	gen byte `guse' = . 
	tokenize `varlist' 
	local warn = 0 
	local nv : word count `varlist' 

	forval v = 1/`nv' {
		local V = abbrev("``v''", 16) 
		sort `touse' `group' ``v'' 
		by `touse' `group': replace `work' = sum(`w') 
		by `touse' `group' ``v'': replace `work' = `work'[_N]
		by `touse' `group': replace `work' = `work'/`work'[_N] 
		by `touse' `group' ``v'': ///
			replace `vuse' = (_n == _N) & `touse' 

		forval q = 1/`nq' { 
			tempvar show 
			gen `show' = .
			if "`format'" != "" { 
				format `format' `show' 
			} 
			local showlist `showlist' `show' 

			local P : word `q' of `p' 
			if `nv' == 1  char `show'[varname] "`P'%" 
			else char `show'[varname] "`P'% ``v''" 
		
			forval g = 1/`ng' { 
				replace `guse' = `vuse' & (`group' == `g') 
mata: i_quantile("``v''", "`work'", "`guse'", `P'/100, "`iqu'", "`ep'")   
				local warn = `warn' + (scalar(`ep') == 1) 
				return scalar `V'_`P'_`g' = scalar(`iqu') 
				return scalar `V'_`P'_`g'_epolate = scalar(`ep')
				replace `show' = scalar(`iqu') if `group' == `g'
			} // loop over groups 
		} // loop over quantiles 
	} // loop over variables 

	bysort `touse' `group': replace `touse' = `touse' & (_n == _N) 
}

if `ng' == 1 list `showlist' if `touse', ///
	subvarname noobs ab(`abbreviate') `options' 
else list `by' `showlist' if `touse', ///
	subvarname noobs ab(`abbreviate') `options' 

if `warn' { 
	di _n "warning: `warn' " plural(`warn', "quantile") " extrapolated" 
} 

end 	

mata: 
void i_quantile(
	string scalar varname, 
	string scalar cupname, 
	string scalar tousename, 
	real scalar P, 
	string scalar qname, 
	string scalar epname 
) 
{ 
real colvector var, cup, ucup 
real scalar np, i, i1, i2, iqu  

var = st_data(., varname, tousename) 
ucup = cup = st_data(., cupname, tousename) 
np = length(cup) 

if (np == 1) { 
	st_numscalar(qname, var[1]) 
	st_numscalar(epname, 0) 
	exit(0)  
} 

i1 = 1 
ucup[1] = 0.5 * cup[1] 
for(i = 2; i <= np; i++) { 
	ucup[i] = cup[i] - 0.5 * (cup[i] - cup[i-1]) 
	if (ucup[i] <= P) i1 = i 	
} 

i2 = i1 == np ? i1 - 1 : i1 + 1 
iqu = var[i1] + (var[i2] - var[i1]) * (P - ucup[i1]) / (ucup[i2] - ucup[i1])  

st_numscalar(qname, iqu) 
st_numscalar(epname, (P < ucup[1] | P > ucup[np])) 
}

end 

