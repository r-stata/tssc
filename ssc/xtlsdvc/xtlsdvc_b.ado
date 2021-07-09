*! xtlsdvc_b V1.0.2   06sep2005
*! Giovanni S.F. Bruno, Universita' Bocconi, Milan, Italy, 
*! giovanni.bruno@unibocconi.it
*! Subroutine called by xtlsdvc for bootstrapping se.
*! It needs the matrix coeff of LSDVC estimates and the scalar sigma, 
*! left behind by xtlsdvc, to generate LSDVC estimates from a bootstrap sample.

*  Version history
*  V1.0.2 fixed a bug causing an over restriction of the size of the simulation sample
*         in the presence of missing values in the regressors 
*  V1.0.1 simulation estimates now permit non identification of some coefficients
*         in the simulated sample, as in the case of time indicators for the periods
*         corresponding and subsequent to the first gap encountered in the x's 

 
program define xtlsdvc_b, rclass

version 8.0


	syntax varlist [if] , Initial(string) [ BIas(integer 1)] 


local options initial(`initial') bi(`bias') 
/* check that data is tsset */


	qui tsset

	local ivar "`r(panelvar)'"
	
	local tvar "`r(timevar)'"
	
	
set type double

tempname touse
mark `touse' `if'


tokenize `varlist'



tempname    bc sigma bc_sim
tempvar     obsn  epsy y


local dim=2
while "``dim''"!="" {
		local xvar "`xvar' ``dim''"
		local dim=`dim'+1
	}

		


// LSDVC regression 

tokenize `varlist'

capture mat `bc'=coeff
if _rc!=0 {
	di as err "matrix coeff of LSDVC estimates not found"
	exit 111
	}
capture sca `sigma'=sigma
if _rc!=0 {
	di as error "the error sd estimate sigma not found"
	exit 111
	}

qui {
			preserve
			keep `varlist' `ivar' `tvar' `touse' 
			 	
}

tempname resc bxc theta gammac

sca `gammac'=`bc'[1,1]
local vars: colnames `bc'
tokenize `vars'

local dim1=2
while "``dim1''"!="" {
		tempname b`dim1'
		sca `b`dim1''=`bc'[1,`dim1']
		local g "`g' + `b`dim1''*``dim1''"
		local dim1=`dim1'+1
		}



qui gen double `bxc'=0 `g'

tokenize `varlist'

local Ly "L.`1'"
qui gen double `y'=`1' 
qui gen double `resc'=`1'-`gammac'*`Ly'-`bxc'

qui  by `ivar': egen double `theta'=mean(`resc')



		// simulate AR data given y0
qui keep if `touse'

/* update touse to consider missing values (both those original 
and those induced by taking lags) */
 
markout  `touse' `resc'

/* keep all usable observations along with all candidate
 start-up values */
  
qui keep if `touse'|(`touse'==0&F.`touse'==1)

qui by `ivar': gen  `obsn'=_n
qui by `ivar': gen double `epsy'=`sigma'*invnorm(uniform())

qui replace `y'= `gammac'*L.`y' + `bxc' +`theta' +`epsy' if `obsn'>1
 
capture assert `y'!=.
if _rc!=0 {
	di as text "Note: gaps detected; for some unit bootrap samples are truncated to"
	di as text "the first missing value"
	}




qui xtlsdvc_1 `y' `xvar', `options'			


mat `bc_sim'=e(b)

if colsof(`bc')==1 {
			matrix colnames `bc'=`1'_1 
		}

else {
			matrix colnames `bc'=`1'_1 _: 
		}

local vars: colnames `bc'
 
tokenize `vars'

/* simulation estimates allowing for non identification of some coefficients
in the simulated sample, as in the case of time indicators for periods corresponding
and subsequent to a gap in some of the x's */

local dim1=1
while "``dim1''"!="" {
		if `bc_sim'[1,`dim1']==. return scalar ``dim1''=0
		else return scalar ``dim1''=`bc_sim'[1,`dim1']
		local dim1=`dim1'+1
			}
end


