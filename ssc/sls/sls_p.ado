/*******************************************************************************
 Predict routine for sls.ado
*******************************************************************************/

*! sls_p version 1.0 2014-10-11 
*! author: Michael Barker mdb96@georgetown.edu

program sls_p 
	version 11
	syntax anything(id="newvarname_or_stub") [if] [in] ///
		[, xb ey TRim Residual deydi deydb SCore]  

	* check options and set defaults
	opts_exclusive "`xb' `score' `ey' `trim' `residual' `deydi' `deydb'" 
	marksample touse

	* linear prediction is always required
	* let "predict" set the sample
	tempvar I 
	_predict double `I' if `touse' , xb 

	* Markout any obs with missing Xs
	markout `touse' `I'

	if "`xb'" != "" {
		syntax newvarname [if] [in] [, xb]
		quietly: gen `typlist' `varlist' = `I'
		exit
	}

	if "`trim'" != "" {
		syntax newvarname [if] [in] [, TRim]
		tempname tx trimpc 
		quietly: gen `typelist' `tx' = .
		* create indicator trimming vector: 0 is trimmed.
		quietly: replace `tx'=1 if `touse'

		matrix `trimpc' = e(trimpc)
		local lb = `trimpc'[1,1]
		local ub = `trimpc'[1,2]

		foreach var of varlist `e(indepvars)' {
			if `lb'>0 {
				_pctile `var' if `touse' , p(`lb')
				quietly: replace `tx'=0 if `var'<r(r1) & `touse'
			}
			if `ub'<100 {
				_pctile `var' if `touse' , p(`ub')
				quietly: replace `tx'=0 if `var'>r(r1) & `touse'
			}
		}
		quietly: gen `typelist' `varlist' = `tx' 
		exit
	}

	* Remaining options all require y, so update touse to require y
	markout `touse' `e(depvar)'

	if "`ey'" != "" {
		syntax newvarname [if] [in] [, ey]
		mata: sls_p("`I'" , "`typlist'" , "`varlist'" , "`touse'", 1) 
		exit
	}

	if "`residual'" != "" {
		syntax newvarname [if] [in] [, Residual]
		mata: sls_p("`I'" , "`typlist'" , "`varlist'" , "`touse'", 2) 
		exit
	}

	if "`deydi'" != "" {
		syntax newvarname [if] [in] [, deydi]
		mata: sls_p("`I'" , "`typlist'" , "`varlist'" , "`touse'", 3) 
		exit
	}
	
	if "`score'" != "" {
		syntax newvarname [if] [in] [, SCore]
		mata: sls_p("`I'" , "`typlist'" , "`varlist'" , "`touse'", 4) 
		exit
	}
	
	if "`deydb'" != "" {
		local nvars : word count `e(indepvars)'
		_stubstar2names `anything' , nvars(`nvars')  	
		mata: sls_p("`I'" , "`s(typlist)'" , "`s(varlist)'" , "`touse'", 5) 
		exit
	}
	
	* Default: return xb
	syntax newvarname [if] [in] 
	quietly: gen `typlist' `varlist' = `I'

end	


local ey 	1
local r 	2
local deydi 3
local score 4
local deydb 5


mata:

void sls_p(string scalar indexvar, 
			string scalar newtyp , string scalar newvar , 
			string scalar touse, real scalar toreturn) {

	y = st_data(., st_global("e(depvar)") , touse)
	I = st_data(., indexvar , touse)

	// get bandwidth from ereturn
	h = st_matrix("e(h)")
	
	// compute for all observations: no trimming
	tx = J(rows(y),1,1)

	struct cexp_parameters scalar CE
    CE = cexp_define()
	ey = cexp(y , I , CE , tx , h) 

	// return cexp y
	if (toreturn==`ey') {
		st_store(., st_addvar(newtyp, newvar) , touse , ey)
		exit(0)
	}
	
	// return residual	
	r = y-ey
	if (toreturn==`r') {
		st_store(., st_addvar(newtyp, newvar) , touse , r)
		exit(0)
	}
	// return dey / di
	deydi = dcexpdI_vec(y , I , CE , tx , h)
	if (toreturn==`deydi') {
		st_store(., st_addvar(newtyp, newvar) , touse , deydi)
		exit(0)
	}
	// return score 
	score = -2 * r :* deydi
	if (toreturn==`score') {
		st_store(., st_addvar(newtyp, newvar) , touse , score)
		exit(0)
	}

	// return dey / db 
	X = st_data(., st_global("e(indepvars)") , touse)
	EX = cexp(X , I , CE)
	deydb = -2 * r :* deydi :* (X - EX) 
	if (toreturn==`deydb') {
		st_store(., st_addvar(tokens(newtyp),tokens(newvar)) , touse , deydb)
		exit(0)
	}
}

end

