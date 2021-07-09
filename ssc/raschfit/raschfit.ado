*! Raschfit version 4 (19 December 2012)
*! Jean-Benoit Hardouin
************************************************************************************************************
* Stata program : Raschfit
* The Raschfit and the Raschfit-fast procedures to construct sub-scales of items
*
* Historic
* Version 1 (2004-05-06) [Jean-Benoit Hardouin]
* Version 2 (2004-06-08) [Jean-Benoit Hardouin]
* Version 3 (2005-12-28) [Jean-Benoit Hardouin]
* Release 3.1 (January 29, 2006) [Jean-Benoit Hardouin] /*MEAN option in raschtestv7, correction of a bug when there is several scales*/
* Release 4 (December 19, 2019) [Jean-Benoit Hardouin] /*identifiant variable for raschtest and mmsrm*/
*
* Jean-benoit Hardouin, phD, Assistant Professor
* Team of Biostatistics, Pharmacoepidemiology and Subjective Measures in Health Sciences  (UPRES EA 4275 SPHERE)
* University of Nantes - Faculty of Pharmaceutical Sciences
* France
* jean-benoit.hardouin@anaqol.org
*
* News about this program :http://www.anaqol.org
*
* Copyright 2004-2006, 2012 Jean-Benoit Hardouin
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


program define raschfit,rclass
version 7
syntax varlist(min=2 numeric) [,KERnel(integer 0) NBSCales(integer 1) ITEMSorder(string) nofast ]
if "`itemsorder'"=="" {
        local itemsorder mspinv
}
local nbitemstot : word count `varlist'
tokenize `varlist'

tempfile raschfitfile
qui save `raschfitfile',replace
preserve

tempname affect
matrix define `affect'=J(1,`nbitemstot',0)
matrix colnames  `affect'=`varlist'

tempvar id
gen `id'=_n

tempname rep item  matbetadim1 matbetadim2
if `kernel'!=0 {
   local listkernel
   forvalues i=1/`kernel' {
             local listkernel `listkernel' `rep'`i'
             matrix `affect'[1,`i']=1
   }
}

local dim=0
local nbitemsnosel=`nbitemstot'
local nbitemstotdim1=`nbitemstot'
local nbitemsnoselukernel=`nbitemstot'-`kernel'


tempvar id betadim1 betadim2
forvalues i=1/`nbitemstot' {
      qui drop if ``i''==.
      rename ``i'' `rep'`i'
}
qui gen `id'=_n
tempfile filescale
qui save `filescale',replace

di in green "{hline 55}"
qui count
local N=r(N)
if "`fast'"!="" {
   di in green "Method: " in ye "Raschfit"
}
else {
   di in green "Method: " in ye "Raschfit-Fast"
}
di in green "Number of individuals: " in ye `N' in green " (with none missing values)"
di in green "Number of items: " in ye `nbitemstot'
di in green "{hline 55}"
di
di in green "{hline 100}"
if "`fast'"!="" {
   di in green "Model 1: " in ye "Rasch model"
   di in green "Model 2: " in ye "MMSRM"
}
else {
   di in green "Model 1: " in ye "Rasch model"
   di in green "Model 2: " in ye "Adapted Rasch model (the response of the new item is not influenced by the latent trait)"
}
di in green "Order of the items:" _c
if "`itemsorder'"=="order" {
   di in ye " order of {it:varlist}"
}
else if "`itemsorder'"=="msp" {
   di in ye " Obtained with MSP (from the first selected item to the last one)"
}
else if "`itemsorder'"=="mspinv" {
   di in ye " Obtained with MSP (from the last selected item to the first one)"
}
if `kernel'!=0 {
   di in green "Kernel of the first scale: " _c
   forvalues i=1/`kernel' {
       di in ye " ``i''" _c
   }
   di
}
di in green "{hline 100}"
di

while `nbitemsnosel'>2&`dim'<`nbscales' {
      use `filescale',replace
      local iteration=0
      local dim=`dim'+1
      if `dim'>1 {
         local kernel=0
         local listkernel
      }

      di in green "SCALE: " in yellow `dim'
      di in green "{hline 9}"
      di
      tempname result`dim'
      local listitemsnosel
      local varlist`dim'
      tokenize `varlist'
      forvalues i=1/`nbitemstot' {
            if `affect'[1,`i']==0 {
                   local varlist`dim' `varlist`dim'' ``i''
                   local listitemsnosel `listitemsnosel' `rep'`i'
            }
      }
      local nbitemsnosel:word count `listitemsnosel'
      if `dim'>1 {
            local nbitemstotdim`dim':word count `listitemsnosel'
      }

      if `kernel'>=2 {
            local fixed=`kernel'
      }
      else {
            local fixed=2
      }
      matrix define `result`dim''=J(`=`nbitemstotdim`dim''-`fixed'',`=`nbitemstotdim`dim''+7',0)

      tempname order`dim' affect`dim'
      matrix `order`dim''=J(1,`nbitemstotdim`dim'',0)
      matrix `affect`dim''=J(1,`nbitemstotdim`dim'',0)

      if "`itemsorder'"=="msp"|"`itemsorder'"=="mspinv" {
            di in green _col(0) "The program is ordering the items"
            di
            qui msp `listkernel' `listitemsnosel',c(-99)  notest kernel(`kernel')
            local scale1 "`r(scale1)'"
            local scalenum1 "`r(scalenum1)'"
            tokenize `scalenum1'
            local listitemsselnum
            forvalues j=`=`nbitemstotdim`dim''+1-`fixed''/`nbitemstotdim`dim'' {
                matrix `order`dim''[1,`j']=1
                local k:word `j' of `scalenum1'
                matrix `affect`dim''[1,`k']=1
                local listitemsselnum `listitemsselnum' `k'
            }
            forvalues j=1/`nbitemsnosel' {
                matrix `order`dim''[1,`j']=`=`nbitemsnosel'+1-`j''
            }
            tokenize `scale1'
            local listitemssel ``=`nbitemstotdim`dim''-1'' ``nbitemstotdim`dim'''

            local listitemsnosel
            local listitemsnoselnum

            if "`itemsorder'"=="mspinv" {
                forvalues j=1/`=`nbitemstotdim`dim''-`fixed'' {
                      local listitemsnosel `listitemsnosel' ``j''
                      local k:word `j' of `scalenum1'
                      local listitemsnoselnum `listitemsnoselnum' `k'
                }
            }
            else if "`itemsorder'"=="msp"{
                 forvalues j=`=`nbitemstotdim`dim''-`fixed''(-1)1 {
                      local listitemsnosel  `listitemsnosel' ``j''
                      local k:word `j' of `scalenum1'
                      local listitemsnoselnum  `listitemsnoselnum' `k'
                 }
            }
      }
      else if "`itemsorder'"=="order" {
           tokenize `listkernel' `varlist`dim''
           local listitemssel
           local listitemsselnum
           local listitemsnosel
           local listitemsnoselnum
           forvalues j=1/`fixed'{
                     local listitemssel `listitemssel' `rep'`j'
                     local listitemsselnum `listitemsselnum' `j'
                     matrix `affect`dim''[1,`j']=1
           }
           forvalues j=`=`fixed'+1'/`nbitemstotdim`dim'' {
                     local listitemsnosel `listitemsnosel' `rep'`j'
                     local listitemsnoselnum `listitemsnoselnum' `j'
           }
      }

      if `dim'>1 {
             tokenize `varlist`dim''
      }
      else {
             tokenize `varlist'
      }

      local nbitemsnosel:word count `listitemsnosel'
      local list
      tokenize `varlist`dim''
      forvalues i=1/`=`nbitemsnosel'+`fixed'' {
            local tmp:word `i' of `listitemsnoselnum' `listitemsselnum'
            local list `list' ``tmp''
      }
      matrix colnames `result`dim''=`list'  Iteration Nbitems ll1 AIC1 ll2 AIC2 Selected

      di _col(0) in green "The kernel of the scale is " in yellow _continue
      forvalues i=1/`fixed' {
            local inum:word `i' of `listitemsselnum'
            di in yellow "``inum'' " _continue
      }
      di
      di
      tokenize `listitemsnosel'
      di in green "{hline 90}"
      di in green _col(36) "Log-Likelihood" _col(58) "Akaike Criterion (AIC)"
      di in green _col(4) "Iteration" _col(20) "New Item" _col(34) "Model 1" _col(47) "Model 2" _col(60) "Model 1" _col(73) "Model 2" _col(81) "Selected"
      di in green "{hline 90}"
      forvalues i=1/`=`nbitemsnosel-2'' {
            local iteration=`iteration'+1
            qui use `filescale' , clear
            local i2:word `i' of `listitemsnosel'
            local i2num:word `i' of `listitemsnoselnum'
            qui keep `id' `listitemssel' `i2'
            tempname score1 score2
            qui gen `score2'=0
            tokenize `listitemssel'
            local nbitemssel: word count `listitemssel'
            forvalues j=1/`i' {
                      local j2num:word `j' of `listitemsnoselnum'
                      if `affect`dim''[1,`j2num']==1 {
                            matrix `result`dim''[`iteration',`j']=1
                      }
            }
            forvalues j=1/`nbitemssel' {
                      local j2:word `j' of `listitemssel'
                      local j2num:word `j' of `listitemsselnum'
                      qui replace `score2'=`score2'+`j2'
            }
            tokenize `listitemsnosel'
            qui gen `score1'=`score2'+`i2'
            forvalues j=`=`nbitemsnosel'+1'/`=`nbitemsnosel'+`nbitemssel'' {
                      matrix `result`dim''[`iteration',`j']=1
            }
            matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+1']=`iteration'
            matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+2']=`nbitemssel'
            matrix `result`dim''[`iteration',`i']=2

            if "`fast'"=="" {
                        qui count
                        local N=r(N)
*                        di "qui raschtestv7 `listitemssel' `i2' , mean method(cml) test(none)"
                        qui raschtestv7 `listitemssel' `i2' , mean method(cml) test(none) id(`id')
                        matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+3']=r(ll)
                        matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+4']=2*(-r(ll)+(2*`nbitemssel'+3))

                        local nb1:word count `listitemssel'
                        qui raschtestv7 `listitemssel',trace test(none) mean id(`id')
                        matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+5']=r(ll)
                        qui logit `i2'
                        matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+5']=`result`dim''[`iteration',`=`nbitemstotdim`dim''+5']+e(ll)
                        matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+6']=2*(-`result`dim''[`iteration',`=`nbitemstotdim`dim''+5']+(2*`nbitemssel'+3))
            }
            else {
                        qui count
                        local N=r(N)
                        qui raschtestv7 `listitemssel' `i2' , method(mml) test(none) id(`id')
                        matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+3']=r(ll)
                        matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+4']=2*(-r(ll)+`nbitemssel'+2)

                        local nb1:word count `listitemssel'
                        qui mmsrm `listitemssel' `i2' , part(`nb1' 1) iterate(20) id(`id')
                        matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+5']=e(ll)
                        matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+6']=2*(-e(ll)+`nbitemssel'+4)
            }
            tokenize `listkernel' `varlist`dim''
            di in ye _col(4) %9.0f `iteration' _col(14) %14s abbrev("``i2num''",14) _col(29) %12.4f `result`dim''[`iteration',`=`nbitemstotdim`dim''+3'] _col(42) %12.4f `result`dim''[`iteration',`=`nbitemstotdim`dim''+5'] _col(55) %12.4f `result`dim''[`iteration',`=`nbitemstotdim`dim''+4'] _col(68) %12.4f `result`dim''[`iteration',`=`nbitemstotdim`dim''+6'] _c
            if `result`dim''[`iteration',`=`nbitemstot'+4']<=`result`dim''[`iteration',`=`nbitemstot'+6'] {
                 matrix `result`dim''[`iteration',`i']=1
                 matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+7']=1
                 local nbitemssel=`nbitemssel'+1
                 local nbitemsnosel=`nbitemsnosel'-1
*                 local listitemssel `listitemssel' `rep'`i2num'
                 local listitemssel `listitemssel' `i2'
                 local listitemsselnum `listitemsselnum' `i2num'
                 matrix `affect`dim''[1,`i2num']=1
                 di in ye _col(88) "X"
            }
            else {
                 matrix `result`dim''[`iteration',`=`nbitemstotdim`dim''+7']=2
                 di
            }
     }
     di in green "{hline 90}"
     return matrix result`dim' `result`dim''
     local j=`kernel'+1
     forvalues i=`=`kernel'+1'/`nbitemstot' {
            if `affect'[1,`i']==0 {
                 if `affect`dim''[1,`j']==1 {
                        matrix `affect'[1,`i']=`dim'
                 }
            local j=`j'+1
            }
     }
}
use `raschfitfile',clear

return matrix affect `affect'

end
