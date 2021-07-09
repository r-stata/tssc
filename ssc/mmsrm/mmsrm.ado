*! Version 4 7December2012
************************************************************************************************************
* Stata program : mmsrm
* Estimate the parameters of the Multidimensional Marginally Sufficient Rasch Model (MMSRM)
* Version 4 : December 7, 2012 /* id option*/
*
* Historic :
* Version 1 (May 14, 2004) [Jean-Benoit Hardouin]
* Version 2 (May 26, 2004) [Jean-Benoit Hardouin]
* Version 3 (July 3, 2005) [Jean-Benoit Hardouin]
* Version 3.1 : July 8, 2010 /* correction of a bug for the name of the items */
*
* Jean-benoit Hardouin, phD, Assistant Professor
* Team of Biostatistics, Pharmacoepidemiology and Subjective Measures in Health Sciences  (UPRES EA 4275 SPHERE)
* University of Nantes - Faculty of Pharmaceutical Sciences
* France
* jean-benoit.hardouin@anaqol.org
*
* Use the Stata programs raschtest and gammasym who can be download on http://anaqol.free.fr
* Use the Stata program gllamm who can be obtained by :  ssc install gllamm
* News about this program :http://anaqol.free.fr
*
* Copyright 2004-2005, 2010, 2012 Jean-Benoit Hardouin
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*
************************************************************************************************************


program define mmsrm,eclass
version 8.0
syntax varlist(min=3 numeric) [if] [in] , id(varname) [PARTition(numlist) NODETails TRAce ITerate(int 30) ADapt METHod(string)]
preserve
tempfile mmsrmfile
qui save `mmsrmfile',replace

/*******************************************************************************
INTRODUCTION AND TESTS
********************************************************************************/

marksample touse
qui keep if `touse'

local nbitems : word count `varlist'
if "`partition'"=="" {
   local partition=`nbitems'
}
if "`method'"=="" {
   local method mml
}
local method=lower("`method'")
local nbpart:word count `partition'

if `nbpart'>3 {
     di in red "{p}The mmsrm module cannot estimate the parameters of the models with more than three dimensions.{p_end}"
     error 198
     exit
}
else if `nbpart'==3&"`method'"=="gee" {
     di in red "{p}You cannot estimate the parameters of a MMSRM with 3 dimension and the GEE method.{p_end}"
     error 198
     exit
}

if "`adapt'"!=""&"`method'"!="mml" {
     di in green "{p}the {cmd:adapt} option is ignored with GEE.{p_end}"
}

local comptitems=0
tokenize `varlist'
forvalues i=1/`nbpart' {
	local firstpart`i'=`comptitems'+1
	local part`i': word `i' of `partition'
	local set`i'
	local comptitems=`comptitems'+`part`i''
	forvalues j=`firstpart`i''/`comptitems' {
		local set`i' "`set`i'' ``j''"
	}
}

if `comptitems'<`nbitems' {
	di in error "{p}Your {cmd:partition} describes less items than the number of items defined in the {it:varlist}.{p_end}"
        error 198
        exit
}
if `comptitems'>`nbitems' {
	di in error "{p}Your {cmd:partition} describes more items than the number of items defined in the {it:varlist}.{p_end}"
	error 198
        exit
}

/*******************************************************************************
FORMATING AND ESTIMATION (with MML)
********************************************************************************/
if `nbpart'== 1 {
   raschtestv7 `varlist', test(none) method(`method')    id(`id')
   local ll=r(ll)
   tempname beta1 Varbeta1 M
   matrix `beta1'=r(beta)
   matrix `Varbeta1'=r(Varbeta)
   local sigma1=r(sigma)
   matrix `M'=(`sigma1'^2)
}
else if "`method'"=="mml" {
   forvalues i=1/`nbpart' {
	if "`details'"=="" {
		di in green "{p}Estimation of the difficulty parameters of the dimension `i'.{p_end}"
	}
        *set trace on
	if `part`i''>1 {
	   qui raschtestv7 `set`i'',meth(`method') test(none) id(`id')
	   tempname beta`i' Varbeta`i'
	   matrix `beta`i''=r(beta)
	   matrix `Varbeta`i''=r(Varbeta)
	   local sigma`i'=r(sigma)
	   forvalues j=1/`part`i'' {
		local parambeta`=`firstpart`i''+`j'-1'=`beta`i''[1,`j']
           }
	}
        else {
           qui count
           local N=r(N)
           qui count if ``firstpart`i'''==1
           local pos=r(N)
           local parambeta`firstpart`i''=-log(`pos'/(`N'-`pos'))
           local sigma`i'=0
        }
   }

   if "`details'"=="" {
	di
	di in green "{p}Estimation of the parameters of the distribution of the multidimensional latent trait.{p_end}"
	di in green "{p}This process could be long to run. Be patient !{p_end}"
   }

   keep `varlist'

   tempname rep id item offset
   forvalues i=1/`nbitems' {
	rename ``i'' `rep'`i'
   }

   gen `id'=_n
   qui reshape long `rep', i(`id') j(`item')

   gen `offset'=0
   label variable `offset' "offset"

   forvalues i=1/`nbitems' {
	qui replace `offset'=-`parambeta`i'' if `item'==`i'
   }

   local eqs
   forvalues i=1/`nbpart' {
	tempname B`i'
	gen `B`i''=0
	eq sc`i':`B`i''
	local eqs `eqs' sc`i'
	forvalues j=`firstpart`i''/`=`firstpart`i''+`part`i''-1' {
		qui replace `B`i''=1 if `item'==`j'
	}
   }

   label variable `rep' "response"
   label variable `id' "identifiant"

   tempname first
   local four=substr("`id'",1,3)
   matrix define `first'=(0,`sigma1',0,`sigma2')
   matrix colnames `first'=`rep':_cons `four'1_1:`B1' `four'1_2:`B2' `four'1_2_1:_cons

   if "`trace'"!="" {
      local quigllamm
   }
   else {
      local quigllamm qui
   }

   `quigllamm' gllamm `rep', from(`first') link(logit) fam(bin)  i(`id')  offset(`offset') nrf(`nbpart') eqs(`eqs')  nip(6) dots `trace' `adapt' iterate(`iterate')
   local ll=e(ll)
   tempname cosig varsig L M
   matrix `cosig'=e(b)
   matrix `varsig'=e(V)
   matrix `L'=e(chol)
   matrix `M'=`L'*`L''
}
/*******************************************************************************
FORMATING AND ESTIMATION (with GEE)
********************************************************************************/
else if "`method'"=="gee" {
    tempname coef
    matrix `coef'=J(`nbitems',`nbpart',0)
    forvalues i=1/`nbpart' {
       forvalues j=`firstpart`i''/`=`firstpart`i''+`part`i''-1' {
            matrix `coef'[`j',`i']=1
       }
    }
    if "`trace'"!="" {
        local quigee 
    }
    else {
        local quigee quietly
    }
    `quigee' geekel2d `varlist',coef(`coef') ll nbit(`iterate')
    local ll=r(ll)
    tempname cosig varsig M
    matrix `cosig'=r(b)
    matrix `M'=J(2,2,0)
    matrix `M'[1,1]=`cosig'[1,`=`nbitems'+1']
    matrix `M'[2,2]=`cosig'[1,`=`nbitems'+2']
    matrix `M'[1,2]=`cosig'[1,`=`nbitems'+3']
    matrix `M'[2,1]=`cosig'[1,`=`nbitems'+3']
    matrix `cosig'=`cosig'[1,1..`nbitems']
    matrix `varsig'=r(V)
    matrix `varsig'=`varsig'[1..`nbitems',1..`nbitems']
    forvalues i=1/`nbpart' {
       tempname beta`i' Varbeta`i'
       matrix `beta`i''=`cosig'[1,`firstpart`i''..`=`firstpart`i''+`part`i''-1']
       matrix `Varbeta`i''=`varsig'[`firstpart`i''..`=`firstpart`i''+`part`i''-1',`firstpart`i''..`=`firstpart`i''+`part`i''-1']
       if `part`i''==1 {
          local parambeta`firstpart`i''=`cosig'[1,`firstpart`i'']
       }
    }
}

/*******************************************************************************
DISPLAYING OF THE RESULTS
********************************************************************************/

local AIC=-2*`ll'+2*(`nbitems'+`nbpart'*(`nbpart'+1)/2)

if `nbpart'>1 {
   forvalues i=1/`nbpart' {
      local var`i'=`M'[`i',`i']
      forvalues j=`=`i'+1'/`nbpart' {
         local cov`i'`j'=`M'[`i',`j']
      }
   }
   di
   di in green _col(4) "Log-likelihood:" in yellow %-12.4f `ll'
   di
   noi di in green _col(4) "Items" _col(16) "Parameters" _col(29) "std Err."
   di in green _col(4) "{hline 33}"
   forvalues p=1/`nbpart' {
      forvalues i=1/`part`p'' {
         local name:word `i' of `set`p''
         if `part`p''!=1 {
            noi di in yellow _col(4) "`name'" _col(18) %8.5f `beta`p''[1,`i'] _col(30) %6.5f sqrt(`Varbeta`p''[`i',`i'])
         }
         else {
            noi di in yellow _col(4) "`name'" _col(18) %8.5f `parambeta`firstpart`p''' _col(30) "."
         }
      }
   }
   di in green _col(4) "{hline 33}"

   forvalues i=1/`nbpart' {
          noi di in yellow _col(4) "Var`i'" _col(18) %8.5f `var`i''
   }

   forvalues i=1/`nbpart' {
      forvalues j=`=`i'+1'/`nbpart' {
         di in green _col(4) in yellow "cov`i'`j'" _col(18) %8.5f `cov`i'`j''
      }
   }
   di in green _col(4) "{hline 33}"
}
if "`trace'"==""&"`details'"=="" {
                 di in green "{p}Add the -trace- option to obtain the standard errors of the elements of the covariance matrix of the latent traits.{p_end}"
}

/*******************************************************************************
OUTPUTS
********************************************************************************/

ereturn clear
ereturn scalar AIC=`AIC'
ereturn scalar ll=`ll'
ereturn scalar dimension=`nbpart'
forvalues i=1/`nbpart' {
	ereturn scalar nbitems`i'=`part`i''
	ereturn local set`i' `set`i''
	if `part`i''>1 {
	        matrix colnames `beta`i''=`set`i''
	        matrix rownames `beta`i''=beta
		ereturn matrix beta`i'=`beta`i''
		matrix colnames `Varbeta`i''=`set`i''
		matrix rownames `Varbeta`i''=`set`i''
	        ereturn matrix Varbeta`i' `Varbeta`i''
	}
	else  {
		ereturn scalar beta`i'=`parambeta`firstpart`i'''
        }
}

tempname matrixsigma
matrix `matrixsigma'=`M'
local list
forvalues i=1/`nbpart' {
   local list `list' latenttrait`i'
}
matrix colnames `matrixsigma'=`list'
matrix rownames `matrixsigma'=`list'
ereturn matrix covar=`matrixsigma'

drop _all
qui use `mmsrmfile'
end
