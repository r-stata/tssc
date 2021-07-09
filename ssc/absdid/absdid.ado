*! 2.0 08jan2016 K. Houngbedji

cap program drop absdid
program define absdid, eclass sortpreserve
	version 13
	if !replay() {
		syntax [varname] [if] [in] [, TVar(varname) XVar(varlist fv) YXVar(varlist fv) ORDer(integer 1) CSInf(real 0) CSUp(real 1) sle Level(cilevel)]        
		marksample touse
		local depv "`varlist'"
		preserve
			qui keep if `touse' 
			qui count if `touse' 
			local nobs = r(N)
			tempvar deltay treated pim 
			tempname ones xm xkm b V
			
			gen `treated' = `tvar'
			gen `deltay'  = `depv'
			
			*>>>> Expanding list of control variables
			
			fvexpand `xvar', 
			local exvar `r(varlist)'
			
			*>>>> Separating dichotomous from continuous variables
			
			fvrevar `exvar', substitute
			local ixvars `r(varlist)'
			foreach var of local ixvars {
				tempvar tag
				qui egen `tag' = tag(`var')
				qui count if `tag'
				if r(N) <= 2 {
					local dxvar `dxvar' `var'
				}
				else {
					local cxvar `cxvar' `var'
				}
			} 
						
			*>>>> power function of continuous variables
			
			if "`cxvar'" ~= "" {
				foreach var of local cxvar {
					if `order' == 1 {
						local ccxvar `ccxvar' `var'	
					}
					else {
						forvalues k = 1/`order' {
							tempname `var'`k'
							g ``var'`k'' = `var'^`k'
							local ccxvar `ccxvar' ``var'`k''		
						}
					}
				}
			}
			
			*>>>> Estimating of the propensity score
			
			local pimxvars `ccxvar' `dxvar' 

			if "`sle'" ~= "" {
				qui logit `treated' `pimxvars'
				qui predict double `pim', pr
			}
			else {
				qui reg `treated' `pimxvars'
				qui predict double `pim', xb
			}
			
			*>>>> List of variables used to approximate the propensity score
			
			local coln : colnames e(b)
			foreach var of local coln {
				_ms_parse_parts `var'
				if !`r(omit)' local nxvar `nxvar' `var'
			}
			local nxvar : subinstr local nxvar "_cons" ""
			
			*>>>> Trimming observations
			
			qui keep if (`pim' > `csinf' & `pim' < `csup')
			
			*>>>> List of variables for heterogeneity analysis
			
			qui reg `deltay' `yxvar'
			local coln : colnames e(b)
			foreach var of local coln {
				_ms_parse_parts `var'
				if !`r(omit)' local nyxvar `nyxvar' `var'
			}
			local nxyvarc : subinstr local nyxvar "_cons" ""			
			fvrevar `nxyvarc', substitute
			local iyxvars `r(varlist)'
			
			*>>>> Estimating the ATT
						
			foreach var of varlist `deltay' `treated' `pim' {
				mata : st_view(`var' = ., . , "`var'")
			}
			
			mata : `ones' = J(rows(`treated'), 1 , 1)
			
			mata : `xm' = J(rows(`treated'), 0 , .)
			foreach var of varlist `nxvar' {
				mata : st_view(`var' = ., . , "`var'")
				cap mata : `xm' = `xm' , `var'
				cap mata : mata drop `var'
			}
			mata : `xm' = `xm' , `ones'
			
			if "`yxvar'" ~= "" {
				mata : `xkm' = J(rows(`treated'), 0 , .)
				foreach var of varlist `iyxvars' {
					mata : st_view(`var' = ., . , "`var'")
					cap mata : `xkm' = `xkm' , `var'
					cap mata : mata drop `var'
				}
				mata : `xkm' = `xkm' , `ones'
			}
			else mata : `xkm' = `ones'
			
			mata : __sdiff(`deltay', `treated' , `pim' , `xm' , `xkm' )
				
			*>>>> OUTPUT
			
			matrix `b' = r(b)'
			matrix `V' = r(V)
			
			local eobs = r(N)
			foreach var of local nyxvar {
				local names `names' ATT:`var' 
			}				
			mat coln `b' = `names'
			mat coln `V' = `names'
			mat rown `V' = `names'
		restore
		
		ereturn post `b' `V', obs(`eobs') depname(`depv') esample(`touse')
		ereturn local depvar "`depv'"
		ereturn local cmd "absdid"
		
		mata : mata drop `deltay' `treated' `pim' `xm' `xkm' `ones'
	}
	else { 
		if "`e(cmd)'"!="absdid" error 301
		syntax [, Level(cilevel)]
	}
	if "`eobs'" == "" local eobs = e(N) 
	di
	di as txt "Abadie's semi-parametric diff-in-diff" _col(49) "Number of obs" _col(67) "= " as res %10.0f `eobs' _n
	ereturn display, level(`level')
end

*****************
* MATA FUNCTION *
*****************
	
capture mata : mata drop __sdiff()
version 10
mata:
void __sdiff(
	real colvector deltay ,
	real colvector treated,
	real colvector pim,
	real matrix xm,
	real matrix xkm
)
{

	real colvector psi, B2 , b
	real matrix B1, D , Sm , E , E1, E2 , E3 , V
	real scalar n

	n = rows(treated)
	psi = (treated - pim):/(pim :* (1 :- pim))
	
	B1 = cross(xkm , pim , xkm )
	B2 = xkm'*(pim :* psi :* deltay)
	b  = invsym(B1)*B2
	
	D  = cross(xkm , (deltay:*(treated :-1):/((1 :- pim):^2) - xkm*b) , xm )
	Sm = invsym(xm'*xm)
	D  = D*Sm
	
	E1 = cross(xkm , ((pim :* ( psi :* deltay - xkm*b)):^2) , xkm )
	
	E2 = cross(xm , ((treated - pim):^2) , xm )
	E2 = D*E2*D'
	
	E3 = cross(xkm , ( pim :* (psi :* deltay - xkm*b):*(treated-pim)), xm*D')
	
	E  = E1 + E2 + E3 + E3'
	
	V  = invsym(B1)*E*invsym(B1)
	
	st_eclear()
	st_matrix("r(b)",b)
	st_matrix("r(V)",V)
	st_numscalar("r(N)",n)
	
}
end

***** END:
