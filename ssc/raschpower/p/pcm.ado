*! Version 2.1 18october2011
************************************************************************************************************
* Stata program : pcm
* Estimate the parameters of the Partial Credit Model
* Version 1 : December 17, 2007
* Version 2 : July 15, 2011
* Version 2.1 : October 18th, 2011 : -fixedvar- option, new presentation
*
* Jean-benoit Hardouin, EA4275 Biostatistics, Clinical Research and Subjective Measures in Health Sciences
* Faculties of Pharmaceutical Sciences & Medicine - University of Nantes - France
* jean-benoit.hardouin@univ-nantes.fr
*
* News about this program : http://www.anaqol.org
* FreeIRT Project : http://www.freeirt.org
*
* Copyright 2007, 2011 Jean-Benoit Hardouin
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
************************************************************************************************************/


program define pcm,eclass
version 8.0
syntax varlist(min=3 numeric) [if] [in] [,rsm fixed(string) fixedvar(int -1) fixedmu short COVariates(varname)]
preserve
tempfile pcmfile
qui save `pcmfile',replace

if "`fixedmu'"!=""&`fixedvar'!=-1&"`covariates'"=="" {
   di in red "You cannot fix in the same time the mean (fixedmu option) and the variance (fixedvar option) of the latent trait without covariables"
   error 184
}
if "`fixed'"!=""&"`fixedmu'"==""&`fixedvar'!=-1&"`covariates'"=="" {
   di in red "You cannot fix in the same time the difficulties (fixed option) and the variance (fixedvar option) of the latent trait without covariables"
   error 184
}

/*******************************************************************************
ESTIMATION OF THE PARAMETERS
********************************************************************************/

marksample touse
qui keep if `touse'
qui count
local N=r(N)
tokenize `varlist'
local nbitems : word count `varlist'

if "`rsm'"=="" {
   di in gr "Model: " in ye "Partial Credit Model"
}
else {
   di in gr "Model: " in ye "Rating Scale Model"
}

tempname one var w id item it obs x chosen d score
qui gen `one'=1
qui gen `id'=_n
local modamax=0
forvalues i=1/`nbitems' {
   qui rename ``i'' `var'`i'
   qui su `var'`i'
   local moda`i'=`r(max)'
   if `modamax'<`r(max)' {
      local modamax=r(max)
   }
}
qui genscore `var'1-`var'`nbitems' ,score(`score')
qui collapse (sum) `w'=`one',by(`var'1-`var'`nbitems' `covariates')
qui gen `id'=_n
qui reshape long `var',i(`id') j(`item')
qui drop if `var'==.
qui gen `obs'=_n
qui expand `=`modamax'+1'
qui sort `id' `item' `obs'
by `obs', sort: gen `x'=_n-1

qui gen `chosen'=`var'==`x'
qui tab `item', gen(`it')
forvalues i=1/`nbitems' {
   forvalues g=1/`modamax' {
      qui gen `d'`i'_`g'=-1*`it'`i'*(`x'>=`g')
   }
}
qui rename `w' `w'2
bysort `id':egen score=sum(`x'*`chosen')
qui su score
local maxscore=r(max)


if "`covariates'"!="" {
   qui gen covw=`covariates'*`x'
   local listcov covw
}
else {
   local listcov
}
if `fixedvar'!=-1 {
   local tmp=sqrt(`fixedvar')
   constraint 1 `x'=`tmp'
   local listconstr "constraints(1)"
}
if "`rsm'"=="" {
   if "`fixed'"!="" {
      qui gen offset=0
      local l=1
      forvalues i=1/`nbitems' {
         forvalues mi=1/`moda`i'' {
            qui replace offset=offset+`fixed'[1,`l']*`d'`i'_`mi'
            local ++l
         }
      }
      if "`fixedmu'"!="" {
         local mu
      }
      else {
         local mu "`x'"
      }

      eq slope:`x'
      noi di "gllamm `x' `listcov' `mu',offset(offset) `listconstr' nocons i(`id') eqs(slope) link(mlogit) expand(`obs' `chosen' o) weight(`w') adapt trace"
      gllamm `x' `listcov' `mu',offset(offset) `listconstr' nocons i(`id') eqs(slope) link(mlogit) expand(`obs' `chosen' o) weight(`w') adapt trace 
   }
   else if "`short'"!="" {
      eq slope:`x'
      qui gllamm `x' `d'1_1-`d'`nbitems'_`modamax',i(`id') eqs(slope) link(mlogit) expand(`obs' `chosen' o) weight(`w') adapt trace nocons init
      tempname bsave Vsave
      matrix `bsave'=e(b)
      matrix `Vsave'=e(V)
      restore
      qui pcm `varlist' , fixed(`bsave')
   }
   else {
      di "no short"
      eq slope:`x'
      qui gen i=`id'
      constraint 1 `x'=1
      gllamm `x' `d'1_1-`d'`nbitems'_`modamax' `listcov',i(i) `listconstr' eqs(slope) link(mlogit) expand(`obs' `chosen' o) weight(`w') adapt trace nocons
   }
}
else {
   tempname step n
   forvalues i=2/`modamax' {
      qui gen `step'`i'=-1*(`x'>=`i')
   }
   forvalues i=1/`nbitems' {
      qui gen `n'`var'`i'=(-1)*(`it'`i')*(`x')
   }
   qui sort `id' `item' `x'
   eq slope:`x'
   gllamm `x' `n'`var'1-`n'`var'`nbitems' `step'2-`step'`modamax' `listcov', i(`id') `listconstr' eqs(slope) link(mlogit) expand(`obs' `chosen' o) weight(`w') adapt trace nocons
}

tempname b V chol
matrix b=e(b)
matrix V=e(V)
local ll=e(ll)
matrix chol=e(chol)


if "`rsm'"=="" {
   di
   di in gr "Number of observations: " in ye `N'
   di in gr "Number of items: " in ye `nbitems'
   di in gr "Number of parameters: " in  ye `=`nbitems'*`modamax'+1'
   di in gr "Log-likelihood: " in ye `ll'
   di
   di
   di in gr "{hline 100}"
   di in gr "Item" _col(10) "Modality" _col(20) "Parameter" _col(30) "Std Error"
   di in gr "{hline 100}"
   if "`fixed'"=="" {
      forvalues i=1/`nbitems' {
         forvalues j=1/`modamax' {
            if `j'==1 {
               di in ye "``i''" _cont
            }
            local k=(`i'-1)*`modamax'+`j'
            if "`short'"!="" {
               di in ye _col(17) `j' _col(20) %9.6f `bsave'[1,`k'] in ye _col(30) %9.6f (`Vsave'[`k',`k'])^.5
            }
            else {
               di in ye _col(17) `j' _col(20) %9.6f b[1,`k'] in ye _col(30) %9.6f (V[`k',`k'])^.5
            }
         }
         di in gr "{dup 100:-}"
      }
   }
   else {
      forvalues i=1/`nbitems' {
         forvalues j=1/`modamax' {
            if `j'==1 {
               di in ye "``i''" _cont
            }
            local k=(`i'-1)*`modamax'+`j'
            di in ye _col(17) `j' _col(20) %9.6f `fixed'[1,`k'] in ye _col(32) "(fixed)"
         }
         di in gr "{dup 100:-}"
      }
   }
   if "`fixed'"==""&"`short'"=="" {
      local k=`nbitems'*`modamax'+1
   }
   else if "`fixed'"!=""&"`fixedmu'"=="" {
      di in ye "Mu" in ye _col(20) %9.6f b[1,1] _col(29) %10.6f  (V[1,1])^.5
      local k=2
   }
   else if "`fixed'"!=""&"`fixedmu'"!="" {
      di in ye "Mu" in ye _col(20) %9.6f 0 _col(32) %10.6f  "(fixed)"
      local k=1
   }
   else {
      local k=1
   }
   if "`covariates'"!="" {
      di in ye "`covariates'" in ye _col(20) %9.6f b[1,`k'] _col(29) %10.6f  (V[`k',`k'])^.5
      local k=`k'+1
   }
   if `fixedvar'==-1 {
      di in ye "Sigma" in ye _col(20) %9.6f b[1,`k'] _col(29) %10.6f  (V[`k',`k'])^.5
      di in ye "Variance" in ye _col(20) %9.6f b[1,`k']^2  _col(29) %10.6f  2*(V[`k',`k'])^.5*b[1,`k']
   }
   else {
      di in ye "Sigma" in ye _col(20) %9.6f `fixedvar'^.5 _col(32) %10.6f  "(fixed)"
      di in ye "Variance" in ye _col(20) %9.6f `fixedvar'  _col(32) %10.6f  "(fixed)"
   }
   di in gr "{hline 100}"
   di
   di
}

end
