//Last version: 2014/02/04 by Malte Hoffmann
program define surloads
version 11.2
di "Surload requires rotated loadings"
	if "`e(cmd)'" != "factor" {
		dis as err "factor estimation results not found"
		error 301
	}
	
	if e(f) == 0 { 
		dis as err "no factors retained"
		exit 321
	}	

	local vnames : rownames e(C)
	unab evnames : `vnames' 
	if !`:list evnames == vnames' { 
		dis as err "impossible to predict; variables not found"
		exit 111
	}
	capture noisily confirm numeric variable `vnames'
	if _rc {
		dis as err "impossible to predict;"
		dis as err "factor variables no longer numeric"
		exit 111
	}
	local nvar : list sizeof vnames

syntax anything(name=vlist)
	local nv = e(f)
	if strpos("`vlist'","*") {
		_stubstar2names `vlist', nvars(`nv')
		local vlist `s(varlist)'
		local typlist `s(typlist)'
	}
	if strpos("`vlist'","-") {
		/*String length*/
		loc leng=strlen("`vlist'")
		/*Where is the dash?*/
		loc pos=strpos("`vlist'","-")
		/*How many vars are there?*/
		/*Name1-Name888*/
		loc name=substr("`vlist'",1,`pos'-2)
		loc namelength=strlen("`name'")
		loc varlength=substr("`vlist'",`namelength'*2+3,.)
		forvalues i=1/`varlength' {
		loc templist "`templist' `name'`i'"
		}
		loc vlist `templist'

	}
	else {

	}
	local nf : list sizeof varlist
	if `nf' > e(f) {
		// this behavior is for backward compatibility
		dis as txt "(excess variables dropped)"
		local nf = e(f)
	}

mat loadings=e(r_L) /*Loadings Matrix*/
local extracted: word count `vlist'
loc numfactors=e(f) /*Number of Factors*/
loc numvars=rowsof(e(r_L)) /*Number of Variables (saved in Rows)*/
loc namesn : word count `names'  /*Number of Variables (saved in Rows)*/
mat b = e(r_L) /*Acquire the names of the variables */
local names : rownames b
local number=min(`numfactors',`extracted')
forvalues i=1/`number'{
	loc temp " "

		forvalues j=1/`numvars'{
			loc names_v`j': word `j' of `names'
			loc loading=loadings[`j',`i']
			loc temp`j'="`loading'*`names_v`j''"
		}
		loc temp `temp1'
		forvalues j=2/`numvars'{
		loc plus="+"
		loc temp `temp' `plus' `temp`j''
		}
	local dv: word `i' of  `vlist'
	quietly gen `dv'=`temp'
	dis "Factor `i' generated - saved in `dv'."
}
end



