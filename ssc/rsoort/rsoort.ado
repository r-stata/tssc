*! version 1.1  3June2013
*! Jean-Benoit Hardouin
************************************************************************************************************
* rsoort: Response Shift detection with the Oort procedure
*
* Historic:
* Version 1 (2013-02-25): Jean-Benoit Hardouin
* Version 1.1 (2013-06-03): Jean-Benoit Hardouin /*some improvements*/
*
*
* Jean-benoit Hardouin - Department of Biomathematics and Biostatistics - University of Nantes - France
* EA 4275-SPHERE "bioStatistics, Pharmacoepidemiology and Human sciEnces Research tEam"
* jean-benoit.hardouin@univ-nantes.fr
*
* Copyright 2013 Jean-Benoit Hardouin
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


/***********************************************************************************************************
INTRODUCTION
***********************************************************************************************************/


program define rsoort,eclass
syntax varlist(min=2 numeric) [if] [in] [,METHod(string) UNIFormrecalibration(varlist) NONUNIFormrecalibration(varlist) REPrioritization(varlist) noSearch]
version 12
tempfile saversoort
qui save `saversoort',replace

if "`if'"!=""|"`in'"!="" {
    qui keep `if' `in'
}

tokenize `varlist'
local nbitems:word count `varlist'
local mod=mod(`nbitems',2)
if `mod'!=0 {
  di in red "You must enter an even number of items : the first half of the items represents the items in time 1 and the second half the items in time 2"
  error
}

if "`method'"=="" {
   local method "ml"
}
local nbitems=`nbitems'/2

di _col(20) "{hline 30}"
di  _col(20) in gr "Time 1" _col(40) "Time 2"
di _col(20) "{hline 30}"
forvalues i=1/`nbitems' {
    di in ye _col(20) "``i''" _col(40) "``=`i'+`nbitems'''"
}
di _col(20) "{hline 30}"


/**************************************************************************************************************
Model 1
***************************************************************************************************************/

qui sem (T1->`1'-``nbitems'')(T2->``=`nbitems'+1''-``=`nbitems'*2''),var(T1@1) var(T2@1) means(T1@0) means(T2@0)  method(`method')
qui estat gof, stat(all)
local tli1=r(tli)
local cfi1=r(cfi)
local srmr1=r(srmr)
local rmsea1=r(rmsea)
local ubrmsea1=r(ub90_rmsea)
local lbrmsea1=r(lb90_rmsea)
local chi21=r(chi2_ms)
local df1=r(df_ms)
local dfc1=6*`nbitems'+1
local p1=r(p_ms)
local bic1=r(bic)
*di
*di in green "          ***********************************Model 1********************************************"
*di in gr _col(14) "chi2" _col(22) "df" _col(35) "p" _col(41) "rmsea" _col(51) "IC90%(RMSEA)" _col(72) "SRMR" _col(83) "CFI" _col(93) "TLI"
*di in ye _col(10) %8.2f `chi21' _col(20) %4.0f `dfc1' _col(30) %6.4f `p1' _col(40) %6.4f `rmsea1' _col(50) %6.4f `lbrmsea1' "-" %6.4f `ubrmsea1'  _col(70) %6.4f `srmr1' _col(80) %6.2f `cfi1' _col(90) %6.2f `tli1'

/**************************************************************************************************************
Model 2
***************************************************************************************************************/

local sem
local var
forvalues i=1/`nbitems' {
   local sem`i' "(T1@load`i' _cons@int`i'->``i'') (T2@load`i' _cons@int`i'->``=`i'+`nbitems''')"
   local var`i' "var(e.``i''@var`i') var(e.``=`i'+`nbitems'''@var`i')"
   local sem `sem' `sem`i''
   local var `var' `var`i''
}

qui sem `sem',var(T1@1) var(T2) means(T1@0) means(T2) `var'     iterate(100)  method(`method')
tempname b V
matrix `b'=e(b)
matrix `V'=e(V)
local truechange2=`b'[1,`=`nbitems'*4+1']
local Vtruechange2=`V'[`=`nbitems'*4+1',`=`nbitems'*4+1']
qui estat gof, stat(all)
local tli2=r(tli)
local cfi2=r(cfi)
local srmr2=r(srmr)
local rmsea2=r(rmsea)
local ubrmsea2=r(ub90_rmsea)
local lbrmsea2=r(lb90_rmsea)
local chi22=r(chi2_ms)
local df2=r(df_ms)
local dfc2=3*`nbitems'+3
local p2=r(p_ms)
local bic2=r(bic)

local chi221=abs(`chi21'-`chi22')
local df21=`df2'-`df1'
local p21=1-chi2(`df21',`chi221')


di "{hline 51}"
di in gr                                /*_col(39) "Test of global Response-Shift "               _col(79) "Comparison with model 1"*/
di in gr "Models" _col(18)  "Chi-square" _col(32) "df" _col(36) "p-value" _col(48) "BIC"  /*_col(39) "Chi-square" _col(54) "df" _col(59) "p-value" *_col(79) "Chi-square" _col(94) "df" _col(99) "p-value"*/
di "{hline 51}"
di in gr "Model 1" _col(20) %8.2f in ye `chi21' _col(30) %4.0f `df1' _col(37) %6.4f `p1' _col(45) %7.2f `bic1'
di in gr "Model 2" _col(20) %8.2f in ye `chi22' _col(30) %4.0f `df2' _col(37) %6.4f `p2' _col(45) %7.2f `bic2' /*_col(40) %8.2f `=abs(`chi22'-`chi21')' _col(50) %6.0f `df21' %6.4f _col(60) `=1-chi2(`df21',abs(`chi22'-`chi21'))' *_col(82) %8.2f `=`=abs(`chi22'-`chi21')'' _col(90) %6.0f `df21' _col(100) %6.4f `=1-chi2(`df21',abs(`chi22'-`chi21'))'*/
di "{hline 51}"


/**************************************************************************************************************
Model 3
***************************************************************************************************************/


/**************************************************************************************************************
Model 3 / Non uniform recalibration
***************************************************************************************************************/

tempname RS  RSprec
qui matrix `RS'=J(`nbitems',3,0)
qui matrix `RSprec'=J(`nbitems',3,0)
local df3=`dfc2'

*set trace on


forvalues i=1/`nbitems' {
   local nbUR:word count `uniformrecalibration'
   forvalues j=1/`nbUR' {
      local itemj: word `j' of `uniformrecalibration'
      if "``i''"=="`itemj'" {
	     matrix `RS'[`i',2]=1
      }
   }
   local nbNUR:word count `nonuniformrecalibration'
   forvalues j=1/`nbNUR' {
      local itemj: word `j' of `nonuniformrecalibration'
     if "``i''"=="`itemj'" {
	     matrix `RS'[`i',1]=1
      }
   }
   local nbR:word count `reprioritization'
   forvalues j=1/`nbR' {
      local itemj: word `j' of `reprioritization'
      if "``i''"=="`itemj'" {
	     matrix `RS'[`i',3]=1
      }
   }
}
*matrix list `RS'

if "`search'"=="" {

di
di "{hline 88}"
di in green _col(40)  "Model 3"
di "{hline 88}"
di
di in white _col(10) "Non uniform Recalibration"

local continue=1
forvalues i=1/`nbitems' {
   local sem`i' "(T1@load`i' _cons@int`i'->``i'') (T2@load`i' _cons@int`i'->``=`i'+`nbitems''')"
   local var`i' "var(e.``i''@var`i') var(e.``=`i'+`nbitems'''@var`i')"
   local semrecU`i' "(T1@load`i' _cons->``i'') (T2@load`i' _cons->``=`i'+`nbitems''')"
   local semrep`i' "(T1 _cons@int`i'->``i'') (T2 _cons@int`i'->``=`i'+`nbitems''')"
   local varrecNU`i' "var(e.``i'') var(e.``=`i'+`nbitems''')"
}
local prec_chi2=`chi22'
local testNU_varchi2=0
local testNU_p=1
di "{hline 88}"
di in gr                                                                                _col(59) "Comparison with previous model"/*              _col(79) "Comparison with model 1"*/
di in gr "Items" _col(18)  "Chi-square" _col(32) "df" _col(36) "p-value" _col(48) "BIC" _col(59) "Chi-square" _col(73) "df" _col(82) "p-value" /*_col(79) "Chi-square" _col(94) "df" _col(99) "p-value"*/
di "{hline 88}"


while (`continue') {
   local cpt=0
   local testNU_varchi2_temp=0
   local testNU_p_temp=0
   local testNU_item_temp=0
   local chi2encours_temp=-1
   local continue=0
   local sem
   local var
   forvalues j=1/`nbitems' {
      local sem
      local var
      local already=0
      forvalues i=1/`nbitems' {
         if `RS'[`i',1]==0&`i'!=`j' {
            local sem `sem' `sem`i''
            local var `var' `var`i''
         }
         if `RS'[`i',1]==1&`i'!=`j' {
            local sem `sem' `sem`i''
            local var `var' `varrecNU`i''
         }
         else if `i'==`j'&`RS'[`j',1]==0 {
            local sem `sem' `sem`i''
            local var `var' `varrecNU`i''
         }
         else if `i'==`j'&`RS'[`j',1]==1 {
            local sem `sem' `sem`i''
            local var `var' `varrecNU`i''
            local already=1
         }
      }
      if (`already'!=1) {
         qui sem `sem',var(T1@1) var(T2) means(T1@0) means(T2) `var'  iterate(100)  method(`method')
         qui estat gof
         local chi2encours=r(chi2_ms)
         local dfencours=r(df_ms)
         local pencours=r(p_ms)
         local bicencours=r(bic)
         if (abs(`chi2encours'-`prec_chi2')>invchi2(1,0.95)&abs(`chi2encours'-`prec_chi2')>`testNU_varchi2_temp') {
            local continue=1
            local testNU_varchi2_temp =abs(`chi2encours'-`prec_chi2' )
            local testNU_p_temp =1-chi2(1,`testNU_varchi2_temp')
            local testNU_item_temp=`j'
            local chi2encours_tmp=`chi2encours'
            local tmp=`chi2encours'
         }
         di in gr "``j''" _col(20) %8.2f in ye `chi2encours' _col(30) %4.0f `dfencours' _col(37) %6.4f `pencours' _col(45) %7.2f `bicencours' _col(61) %8.2f `=abs(`chi2encours'-`prec_chi2' )' _col(74) "1" %6.4f _col(83) `=1-chi2(1,abs(`chi2encours'-`prec_chi2' ))' /*_col(82) %8.2f `=abs(`chi2encours'-`chi21')' _col(90) %6.0f `=abs(`df3'+1-`dfc1')' _col(100) %6.4f `=1-chi2(abs(`df3'+1-`dfc1'),abs(`chi2encours'-`chi21'))'*/
         local ++cpt
      }
   }
   if (`testNU_item_temp'!=0) {
      matrix `RS'[`testNU_item_temp',1]=1
      local ++df3
      local testNU_varchi2=`testNU_varchi2_temp'
      local testNU_p=`testNU_p_temp'
      local testNU_item_temp=0
      local prec_chi2=`tmp'
   }
   if (`cpt'!=0) {
      di "{hline 88}"
   }
}



/**************************************************************************************************************
Model 3 / Uniform recalibration
***************************************************************************************************************/

di
di in white _col(10) "Uniform Recalibration"

local continue=1
local var
forvalues i=1/`nbitems' {
   local sem`i' "(T1@load`i' _cons@int`i'->``i'') (T2@load`i' _cons@int`i'->``=`i'+`nbitems''')"
   local semrecU`i' "(T1@load`i' _cons->``i'') (T2@load`i' _cons->``=`i'+`nbitems''')"
   local semrep`i' "(T1 _cons@int`i'->``i'') (T2 _cons@int`i'->``=`i'+`nbitems''')"
   local var`i' "var(e.``i''@var`i') var(e.``=`i'+`nbitems'''@var`i')"
   local varrecNU`i' "var(e.``i'') var(e.``=`i'+`nbitems''')"
   if `RS'[`i',1]==1 {
      local var "`var' `varrecNU`i''"
   }
   if `RS'[`i',1]==0 {
      local var "`var' `var`i''"
   }
}
local testU_varchi2=0
local testU_p=1
di "{hline 88}"
di in gr                                                                                _col(59) "Comparison with previous model"/*              _col(79) "Comparison with model 1"*/
di in gr "Items" _col(18)  "Chi-square" _col(32) "df" _col(36) "p-value" _col(48) "BIC" _col(59) "Chi-square" _col(73) "df" _col(82) "p-value" /*_col(79) "Chi-square" _col(94) "df" _col(99) "p-value"*/
di "{hline 88}"

while (`continue') {
   local cpt=0
   local testU_varchi2_temp=0
   local testU_p_temp=0
   local testU_item_temp=0
   local chi2encours_temp=-1
   local continue=0
   local sem
   forvalues j=1/`nbitems' {
      local sem
      local already=0
      forvalues i=1/`nbitems' {
         if `RS'[`i',2]==0&`i'!=`j' {
            local sem `sem' `sem`i''
         }
         if `RS'[`i',2]==1&`i'!=`j' {
            local sem `sem' `semrecU`i''
         }
         else if `i'==`j'&`RS'[`j',2]==0 {
            local sem `sem' `semrecU`i''
         }
         else if `i'==`j'&`RS'[`j',2]==1 {
            local sem `sem' `semrecU`i''
            local already=1
         }
      }
      if (`already'!=1) {
         qui sem `sem',var(T1@1) var(T2) means(T1@0) means(T2) `var'  iterate(100)  method(`method')
         qui estat gof
         local chi2encours=r(chi2_ms)
         local dfencours=r(df_ms)
         local pencours=r(p_ms)
         local bicencours=r(bic)
         if (abs(`chi2encours'-`prec_chi2')>invchi2(1,0.95)&abs(`chi2encours'-`prec_chi2')>`testU_varchi2_temp') {
            local continue=1
            local testU_varchi2_temp =abs(`chi2encours'-`prec_chi2' )
            local testU_p_temp =1-chi2(1,`testU_varchi2_temp')
            local testU_item_temp=`j'
            local chi2encours_tmp=`chi2encours'
            local tmp=`chi2encours'
         }
         di in gr "``j''" _col(20) %8.2f in ye `chi2encours' _col(30) %4.0f `dfencours' _col(37) %6.4f `pencours' _col(45) %7.2f `bicencours' _col(61) %8.2f `=abs(`chi2encours'-`prec_chi2' )' _col(74) "1" %6.4f _col(83) `=1-chi2(1,abs(`chi2encours'-`prec_chi2' ))' /*_col(82) %8.2f `=abs(`chi2encours'-`chi21')' _col(90) %6.0f `=abs(`df3'+1-`dfc1')' _col(100) %6.4f `=1-chi2(abs(`df3'+1-`dfc1'),abs(`chi2encours'-`chi21'))'*/
         local ++cpt
      }
   }
   if (`testU_item_temp'!=0) {
      matrix `RS'[`testU_item_temp',2]=1
      local ++df3
      local testU_varchi2=`testU_varchi2_temp'
      local testU_p=`testU_p_temp'
      local testU_item_temp=0
      local prec_chi2=`tmp'
   }
   if (`cpt'!=0) {
      di "{hline 88}"
   }
}




/**************************************************************************************************************
Model 3 / Reprioritization
***************************************************************************************************************/

di
di in white _col(10) "Reprioritization"

local continue=1
local var
local sem
forvalues i=1/`nbitems' {
   local sem`i' "(T1@load`i' _cons@int`i'->``i'') (T2@load`i' _cons@int`i'->``=`i'+`nbitems''')"
   local semrecU`i' "(T1@load`i' _cons->``i'') (T2@load`i' _cons->``=`i'+`nbitems''')"
   local semrecUrep`i' "(T1 _cons->``i'') (T2 _cons->``=`i'+`nbitems''')"
   local semrep`i' "(T1 _cons@int`i'->``i'') (T2 _cons@int`i'->``=`i'+`nbitems''')"
   local var`i' "var(e.``i''@var`i') var(e.``=`i'+`nbitems'''@var`i')"
   local varrecNU`i' "var(e.``i'') var(e.``=`i'+`nbitems''')"
   if `RS'[`i',1]==1 {
      local var "`var' `varrecNU`i''"
   }
   if `RS'[`i',1]==0 {
      local var "`var' `var`i''"
   }
}
local testU_varchi2=0
local testU_p=1
di "{hline 88}"
di in gr                                                                                _col(59) "Comparison with previous model"/*              _col(79) "Comparison with model 1"*/
di in gr "Items" _col(18)  "Chi-square" _col(32) "df" _col(36) "p-value" _col(48) "BIC" _col(59) "Chi-square" _col(73) "df" _col(82) "p-value" /*_col(79) "Chi-square" _col(94) "df" _col(99) "p-value"*/
di "{hline 88}"

while (`continue') {
   local cpt=0
   local testR_varchi2_temp=0
   local testR_p_temp=0
   local testR_item_temp=0
   local chi2encours_temp=-1
   local continue=0
   local sem
   forvalues j=1/`nbitems' {
      local sem
      local already=0
      forvalues i=1/`nbitems' {
         if `RS'[`i',3]==0&`RS'[`i',2]==0&`i'!=`j' {
            local sem `sem' `sem`i''
         }
         else if `RS'[`i',3]==0&`RS'[`i',2]==1&`i'!=`j' {
            local sem `sem' `semrecU`i''
         }
         else if `RS'[`i',3]==1&`RS'[`i',2]==0&`i'!=`j' {
            local sem `sem' `semrep`i''
         }
         else if `RS'[`i',3]==1&`RS'[`i',2]==1&`i'!=`j' {
            local sem `sem' `semrecUrep`i''
         }
         else if `i'==`j'&`RS'[`j',3]==0&`RS'[`i',2]==0 {
            local sem `sem' `semrep`i''
         }
         else if `i'==`j'&`RS'[`j',3]==0&`RS'[`i',2]==1&`RS'[`i',1]==0 {
            local sem `sem' `semrecUrep`i''
         }
         else if `i'==`j'&`RS'[`j',3]==0&`RS'[`i',2]==1&`RS'[`i',1]==1 {
            local already=1
         }
         else if `i'==`j'&`RS'[`j',3]==1&`RS'[`i',2]==0 {
            local sem `sem' `semrep`i''
            local already=1
         }
         else if `i'==`j'&`RS'[`j',3]==1&`RS'[`i',2]==1 {
            local sem `sem' `semrecUrep`i''
            local already=1
         }
      }
      if (`already'!=1) {
         qui sem `sem',var(T1@1) var(T2) means(T1@0) means(T2) `var'  iterate(100)  method(`method')
         qui estat gof
         local chi2encours=r(chi2_ms)
         local dfencours=r(df_ms)
         local pencours=r(p_ms)
         local bicencours=r(bic)
         if (abs(`chi2encours'-`prec_chi2')>invchi2(1,0.95)&abs(`chi2encours'-`prec_chi2')>`testR_varchi2_temp'&`chi2encours'<`prec_chi2') {
            local continue=1
            local testR_varchi2_temp =abs(`chi2encours'-`prec_chi2' )
            local testR_p_temp =1-chi2(1,`testR_varchi2_temp')
            local testR_item_temp=`j'
            local chi2encours_tmp=`chi2encours'
            local tmp=`chi2encours'
         }
         if ( `chi2encours'<`prec_chi2') {
         di in gr "``j''" _col(20) %8.2f in ye `chi2encours' _col(30) %4.0f `dfencours' _col(37) %6.4f `pencours' _col(45) %7.2f `bicencours' _col(61) %8.2f `=abs(`chi2encours'-`prec_chi2' )' _col(74) "1" %6.4f _col(83) `=1-chi2(1,abs(`chi2encours'-`prec_chi2' ))' /*_col(82) %8.2f `=abs(`chi2encours'-`chi21')' _col(90) %6.0f `=abs(`df3'+1-`dfc1')' _col(100) %6.4f `=1-chi2(abs(`df3'+1-`dfc1'),abs(`chi2encours'-`chi21'))'*/
         }
         else {
            di in gr "``j''" _col(20) %8.2f in ye `chi2encours' _col(40) "Anavailable"
         }
         local ++cpt
      }
   }
   if (`testR_item_temp'!=0) {
      matrix `RS'[`testR_item_temp',3]=1
      local ++df3
      local testR_varchi2=`testR_varchi2_temp'
      local testR_p=`testR_p_temp'
      local testR_item_temp=0
      local prec_chi2=`tmp'
   }
   if (`cpt'!=0) {
      di "{hline 105}"
   }
}
}

/**************************************************************************************************************
Model 3 Final
***************************************************************************************************************/

di
local continue=1
local var
local sem
forvalues i=1/`nbitems' {
   local sem`i' "(T1@load`i' _cons@int`i'->``i'') (T2@load`i' _cons@int`i'->``=`i'+`nbitems''')"
   local semrecU`i' "(T1@load`i' _cons->``i'') (T2@load`i' _cons->``=`i'+`nbitems''')"
   local semrecUrep`i' "(T1 _cons->``i'') (T2 _cons->``=`i'+`nbitems''')"
   local semrep`i' "(T1 _cons@int`i'->``i'') (T2 _cons@int`i'->``=`i'+`nbitems''')"
   local var`i' "var(e.``i''@var`i') var(e.``=`i'+`nbitems'''@var`i')"
   local varrecNU`i' "var(e.``i'') var(e.``=`i'+`nbitems''')"
   if `RS'[`i',1]==1 {
      local var "`var' `varrecNU`i''"
   }
   if `RS'[`i',1]==0 {
      local var "`var' `var`i''"
   }
   if `RS'[`i',2]==0&`RS'[`i',3]==0 {
      local sem "`sem' `sem`i''"
   }
   if `RS'[`i',2]==0&`RS'[`i',3]==1 {
      local sem "`sem' `semrep`i''"
   }
   if `RS'[`i',2]==1&`RS'[`i',3]==0 {
      local sem "`sem' `semrecU`i''"
   }
   if `RS'[`i',2]==1&`RS'[`i',3]==1 {
      local sem "`sem' `semrecUrep`i''"
   }
}
qui sem `sem',var(T1@1) var(T2) means(T1@0) means(T2) `var'  iterate(100)   method(`method')
tempname b V
matrix `b'=e(b)
matrix `V'=e(V)
local truechange=`b'[1,`=`nbitems'*4+1']
local Vtruechange=`V'[`=`nbitems'*4+1',`=`nbitems'*4+1']
qui estat gof
local tli3=r(tli)
local cfi3=r(cfi)
local srmr3=r(srmr)
local rmsea3=r(rmsea)
local ubrmsea3=r(ub90_rmsea)
local lbrmsea3=r(lb90_rmsea)
local chi23=r(chi2_ms)
local dfc3=`df3'
local p3=r(p_ms)
local bic3=r(bic)


/**************************************************************************************************************
Bilan
***************************************************************************************************************/

di
di  "{hline 74}"
di in gr           _col(22) "Non uniform"       _col(46) "Uniform"
di in gr "Items" _col(20) "Recalibration" _col(40) "Recalibration" _col(58) "Reprioritization"
di  "{hline 74}"
forvalues i=1/`nbitems' {
   local recNU
   local recU
   local rep
   if (`RS'[`i',1]==1) {
      local recNU "*"
   }
   if (`RS'[`i',2]==1) {
      local recU "*"
   }
   if (`RS'[`i',3]==1) {
      local rep "*"
   }
   di in gr "``i''" in ye _col(32) "`recNU'" _col(52) "`recU'" _col(73) "`rep'"
}
di  "{hline 74}"


/**************************************************************************************************************
Model 4
***************************************************************************************************************/

qui sem `sem',var(T1@1) var(T2) means(T1@0) means(T2) `var'  iterate(100)
tempname b V
matrix `b'=e(b)
matrix `V'=e(V)
local truechange=`b'[1,`=`nbitems'*4+1']
local Vtruechange=`V'[`=`nbitems'*4+1',`=`nbitems'*4+1']
qui estat gof,stat(all)
local tli4=r(tli)
local cfi4=r(cfi)
local srmr4=r(srmr)
local rmsea4=r(rmsea)
local ubrmsea4=r(ub90_rmsea)
local lbrmsea4=r(lb90_rmsea)
local chi24=r(chi2_ms)
local dfc4=`df3'+1
local p4=r(p_ms)
local chi2encours=r(chi2_ms)
local bic4=r(bic)

local z=`truechange'/sqrt(`Vtruechange')


di
di  "{hline 95}"
di in gr "Models" _col(14) "chi2" _col(22) "df" _col(31) "p" _col(40) "BIC" _col(47) "RMSEA" _col(55) "IC90%(RMSEA)" _col(72) "SRMR" _col(83) "CFI" _col(93) "TLI"
di  "{hline 95}"
di in green "Model 1" in ye _col(10) %8.2f `chi21' _col(20) %4.0f `dfc1' _col(26) %6.4f `p1' _col(36) %7.2f `bic1' _col(46) %6.4f `rmsea1' _col(54) %6.4f `lbrmsea1' "-" %6.4f `ubrmsea1'  _col(70) %6.4f `srmr1' _col(80) %6.2f `cfi1' _col(90) %6.2f `tli1'
di in green "Model 2" in ye _col(10) %8.2f `chi22' _col(20) %4.0f `dfc2' _col(26) %6.4f `p2' _col(36) %7.2f `bic2' _col(46) %6.4f `rmsea2' _col(54) %6.4f `lbrmsea2' "-" %6.4f `ubrmsea2'  _col(70) %6.4f `srmr2' _col(80) %6.2f `cfi2' _col(90) %6.2f `tli2'
*di in green "Model 3" in ye _col(10) %8.2f `chi23' _col(20) %4.0f `dfc3' _col(30) %6.4f `p3' _col(40) %6.4f `rmsea3' _col(50) %6.4f `lbrmsea3' "-" %6.4f `ubrmsea3'  _col(70) %6.4f `srmr3' _col(80) %6.2f `cfi3' _col(90) %6.2f `tli3'
di in green "Model 4" in ye _col(10) %8.2f `chi24' _col(20) %4.0f `dfc4' _col(26) %6.4f `p4' _col(36) %7.2f `bic4' _col(46) %6.4f `rmsea4' _col(54) %6.4f `lbrmsea4' "-" %6.4f `ubrmsea4'  _col(70) %6.4f `srmr4' _col(80) %6.2f `cfi4' _col(90) %6.2f `tli4'
di  "{hline 95}"



di
di  "{hline 77}"
di _col(23) in gr "Estimation" _col(44) "s.e." _col(60) "z" _col(71) "p-value"
di  "{hline 77}"
di in gr "True change (Model 2)" in ye _col(25) %8.4f `truechange2' _col(40) %8.4f `=sqrt(`Vtruechange2')' _col(56) %6.2f `=`truechange2'/sqrt(`Vtruechange2')' _col(72) %6.4f `=2-2*normal(abs(`truechange2')/sqrt(`Vtruechange2'))'
di in gr "True change (Model 4)" in ye _col(25) %8.4f `truechange' _col(40) %8.4f `=sqrt(`Vtruechange')' _col(56) %6.2f `=`truechange'/sqrt(`Vtruechange')' _col(72) %6.4f `=2-2*normal(abs(`truechange')/sqrt(`Vtruechange'))'
di  "{hline 77}"

di
qui use `saversoort',clear



end
