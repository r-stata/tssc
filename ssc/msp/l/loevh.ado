*! Version 8 8 December 2010
*! Jean-Benoit Hardouin
************************************************************************************************************
* Stata program : loevh
* Loevinger H indexes, Mokken Analysis
* Release 8: December 8, 2010  /*loevH is renamed loevh*/
*
*
* Historic :
* Version 1 (August 20, 2002) [Jean-Benoit Hardouin]
* Version 2 (June 22, 2003) [Jean-Benoit Hardouin]
* Version 3 (December 1, 2003) [Jean-Benoit Hardouin]
* Version 4 (January 20, 2004) [Jean-Benoit Hardouin]
* Version 5 (March 22, 2004) [Jean-Benoit Hardouin]
* Version 6 (July 3, 2004) [Jean-Benoit Hardouin]
* Version 6.1 (September 19, 2005) [Jean-Benoit Hardouin]
* Version 6.2 (January 31, 2006) [Jean-Benoit Hardouin]
* Release 6.3 (March 20, 2006) [Jean-Benoit Hardouin]  /*A bug with temporary files */
* Release 6.4 (January 19, 2007) [Jean-Benoit Hardouin]  /*Tests to compare Loevinger coefficients to 0 identical to the MSP software (dichotomous and polytomous case)*/
* Release 6.5 (January 22, 2007) [Jean-Benoit Hardouin]  /*Correction of a bug concerning the p-values with the pair option*/
* Release 6.6 (Februar 16, 2007) [Jean-Benoit Hardouin]  /*Correction of a bug with the displaying of Easyness with polytomous items, option graph, option generror, improvements*/
* Release 7: June 21, 2007  /*Check of  monotonicity and Non intersection via P matrices*/
* Release 7.1: November 6, 2008  /*Correction for the z-tests for the check of non intersection via P matrices*/
* Release 7.2: November 19, 2008  /*Implementation of the GPN indexes*/
* Release 7.3: August 15, 2009  /*Print the difficulties of the items instead of P(X=0)*/
*
* Jean-benoit Hardouin, phD, Assistant Professor
* Team of Biostatistics, Clinical Research and Subjective Measures in Health Sciences  (UPRES EA 4275)
* University of Nantes - Faculty of Pharmaceutical Sciences
* France
* jean-benoit.hardouin@anaqol.org
*
* Requiered Stata modules:
* -anaoption- (version 1)
* -traces- (version 3.2)
* -gengroup- (version 1)
* -guttmax- (version 1)
*
* News about this program :http://www.anaqol.org
* FreeIRT Project website : http://www.freeirt.org
*
* Copyright 2002-2008 Jean-Benoit Hardouin
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
***********************************************************************************************************

program define loevh , rclass
version 8.2
syntax varlist(min=2 numeric) [if] [,PAIRWise PAIR ppp pmm noADJust GENERror(string) REPlace GRaph MONOtonicity(string) NIRESTscore(string) NIPmatrix(string)]
preserve

local nbitems : word count `varlist'
tokenize `varlist'
tempname corr cov P1 P0 diff P11 P00 H1jk vHjk zHjk chi2Hjk dfHjk pvalHjk H1j vHj zHj pvalHj H1 vH zH pvalH Obs eGuttjk eGuttjk0 loevHjk eGuttj eGuttj0 loevHj eGutt eGutt0 loevH e1 e2
tempfile loevHfile
qui save "`loevHfile'"

if "`if'"!="" {
   qui keep `if'
}

if "`adjust'"!="" {
   local adj=0
}
else {
   local adj=1
}

qui count
local nbobs=r(N)

forvalues j=1/`nbitems' {
   if "`pairwise'"=="" {
       qui drop if ``j''==.
   }
}
qui count
local nbtotindnm=r(N)

matrix define `eGuttjk'=J(`nbitems',`nbitems',0)
matrix define `eGuttjk0'=J(`nbitems',`nbitems',0)
matrix define `loevHjk'=J(`nbitems',`nbitems',0)
matrix define `eGuttj'=J(1,`nbitems',0)
matrix define `eGuttj0'=J(1,`nbitems',0)
matrix define `loevHj'=J(1,`nbitems',0)
scalar define `eGutt'=0
scalar define `eGutt0'=0
scalar define `loevH'=0
matrix define `Obs'=J(`nbitems',`nbitems',0)
matrix define `P00'=J(`nbitems',`nbitems',0)

tempname modamax
scalar `modamax'=0
local scoremax=0
forvalues j=1/`nbitems' {
     qui su ``j''
     local m`j'=r(max)
     local scoremax=`scoremax'+`m`j''
     if r(max)>`modamax' {
        scalar `modamax'=r(max)
     }
     local nbHjkNS`j'=0
}

/*if "`generror'"!=""&`modamax'!=1 {
   di in ye "It is not possible to define the {cmd:generror} option with polytomous items"
   local generror
} */
*di "scoremax `scoremax'"
if "`graph'"!=""&`scoremax'>19 {
   di in ye "The {cmd:graph} option is disabled because of a large number of possible scores (>20)"
   local graph
}

matrix define `cov'=J(`nbitems',`nbitems',0)
matrix define `corr'=J(`nbitems',`nbitems',0)
matrix define `P11'=J(`nbitems',`nbitems',0)
matrix define `H1jk'=J(`nbitems',`nbitems',0)
matrix define `vHjk'=J(`nbitems',`nbitems',0)
matrix define `zHjk'=J(`nbitems',`nbitems',0)
matrix define `pvalHjk'=J(`nbitems',`nbitems',0)
matrix define `P1'=J(1,`nbitems',0)
matrix define `P0'=J(1,`nbitems',0)
matrix define `diff'=J(1,`nbitems',0)
matrix define `H1j'=J(1,`nbitems',0)
matrix define `vHj'=J(1,`nbitems',0)
matrix define `zHj'=J(1,`nbitems',0)
matrix define `pvalHj'=J(1,`nbitems',0)

forvalues j=1/`nbitems' {
    qui su ``j''
    matrix `cov'[`j',`j']=r(Var)
    matrix `corr'[`j',`j']=1
    local tmp=`j'+1
    qui count if ``j''!=.
    matrix `Obs'[`j',`j']=r(N)
    forvalues k=`tmp'/`nbitems' {
        qui count if ``j''!=.&``k''!=.
        matrix `Obs'[`j',`k']=r(N)
        matrix `Obs'[`k',`j']=r(N)
        qui corr ``j'' ``k'',cov
        matrix `cov'[`j',`k']=r(cov_12)
        matrix `cov'[`k',`j']=r(cov_12)
        qui corr ``j'' ``k''
        matrix `corr'[`j',`k']=r(rho)
        matrix `corr'[`k',`j']=r(rho)
        matrix `zHjk'[`j',`k']=`corr'[`j',`k']*(`Obs'[`j',`k']-`adj')^.5
        matrix `zHjk'[`k',`j']=`H1jk'[`j',`k']
        matrix `pvalHjk'[`j',`k']=1-norm(`zHjk'[`j',`k'])
        matrix `pvalHjk'[`k',`j']=`pvalHjk'[`j',`k']
        if `pvalHjk'[`j',`k']>0.05 {
           local nbHjkNS`j'=`nbHjkNS`j''+1
           local nbHjkNS`k'=`nbHjkNS`k''+1
        }
        forvalues mod1=1/`m`j'' {
            forvalues mod2=1/`m`k'' {
                qui count if ``j''<`mod1'&``k''>=`mod2'&``j''!=.&``k''!=.
                scalar `e1'=r(N)
                qui count if ``j''>=`mod1'&``k''<`mod2'&``j''!=.&``k''!=.
                scalar `e2'=r(N)
                matrix `eGuttjk'[`j',`k']=`eGuttjk'[`j',`k']+min(`e1',`e2')
                qui count if ``j''<`mod1'&``j''!=.&``k''!=.
                local t1=r(N)
                qui count if ``k''<`mod2'&``j''!=.&``k''!=.
                local t2=r(N)
                qui count if ``j''>=`mod1'&``j''!=.&``k''!=.
                local t3=r(N)
                qui count if ``k''>=`mod2'&``j''!=.&``k''!=.
                local t4=r(N)
                if min(`e1',`e2')==`e1' {
                    matrix `eGuttjk0'[`j',`k']=`eGuttjk0'[`j',`k']+`t1'*`t4'/`Obs'[`j',`k']
                }
                else {
                    matrix `eGuttjk0'[`j',`k']=`eGuttjk0'[`j',`k']+`t2'*`t3'/`Obs'[`j',`k']
                }

            }
        }
        qui count if ``j''==0&``k''==0
        matrix `P00'[`j',`k']=r(N)/`Obs'[`j',`k']
        matrix `P00'[`k',`j']=r(N)/`Obs'[`k',`j']
        if `modamax'==1 {
           qui count if ``j''==1&``k''==1
           matrix `P11'[`j',`k']=r(N)/`Obs'[`j',`k']
           matrix `P11'[`k',`j']=r(N)/`Obs'[`k',`j']
        }

        matrix `eGuttjk'[`k',`j']=`eGuttjk'[`j',`k']
        matrix `eGuttj'[1,`j']=`eGuttj'[1,`j']+`eGuttjk'[`j',`k']
        matrix `eGuttj'[1,`k']=`eGuttj'[1,`k']+`eGuttjk'[`j',`k']
        matrix `eGuttjk0'[`k',`j']=`eGuttjk0'[`j',`k']
        matrix `eGuttj0'[1,`j']=`eGuttj0'[1,`j']+`eGuttjk0'[`j',`k']
        matrix `eGuttj0'[1,`k']=`eGuttj0'[1,`k']+`eGuttjk0'[`j',`k']

        matrix `loevHjk'[`j',`k']=1-`eGuttjk'[`j',`k']/`eGuttjk0'[`j',`k']
        matrix `loevHjk'[`k',`j']=`loevHjk'[`j',`k']

    }
    qui count if ``j''!=.
    local tmp=r(N)
    qui count if ``j''==1
    matrix `P1'[1,`j']=r(N)/`tmp'
    qui count if ``j''==0
    matrix `P0'[1,`j']=r(N)/`tmp'
    qui su ``j''
    matrix `diff'[1,`j']=r(mean)
    matrix `loevHj'[1,`j']=1-`eGuttj'[1,`j']/`eGuttj0'[1,`j']
    scalar `eGutt'=`eGutt'+`eGuttj'[1,`j']/2
    scalar `eGutt0'=`eGutt0'+`eGuttj0'[1,`j']/2
}
scalar `H1'=0
scalar `vH'=0
scalar `zH'=0
forvalues j=1/`nbitems'{
   forvalues k=1/`nbitems' {
      if `j'!=`k' {
         matrix `zHj'[1,`j']=`zHj'[1,`j']+`cov'[`j',`k']
         matrix `vHj'[1,`j']=`vHj'[1,`j']+`cov'[`j',`j']*`cov'[`k',`k']/(`Obs'[`j',`k']-`adj')
      }
      if `j'<`k' {
         scalar `zH'=`zH'+`cov'[`j',`k']
         scalar `vH'=`vH'+`cov'[`j',`j']*`cov'[`k',`k']/(`Obs'[`j',`k']-`adj')
      }
   }
   matrix `zHj'[1,`j']=`zHj'[1,`j']/sqrt(`vHj'[1,`j'])
   matrix `pvalHj'[1,`j']=1-norm(`zHj'[1,`j'])
}
scalar `zH'=`zH'/sqrt(`vH')
scalar `pvalH'=1-norm(`zH')
scalar `loevH'=1-`eGutt'/`eGutt0'

if `modamax'==1 {
   local text="Easyness"
   local value=1
   local col=23
}
else {
   local text="Difficulty"
   local value=0
   local col=21
}


di in green  _col(35) "Observed" _col(47) "Expected" _col(93) "Number"
di in green _col(27) "Mean" _col(36) "Guttman" _col(48) "Guttman" _col(59) "Loevinger" _col(83) "H0: Hj<=0" _col(94) "of NS"
di in green "Item"  _col(15) "Obs" _col(26) "Score" _col(37) "errors" _col(49) "errors" _col(61) "H coeff" _col(73) "z-stat." _col(85) "p-value" _col(96) "Hjk"
di in green "{hline 99}"
forvalues j=1/`nbitems' {
     di in green "``j''" in yellow _col(15) `Obs'[`j',`j'] _col(25) %6.4f `diff'[1,`j'] _col(38) %5.0f `eGuttj'[1,`j'] _col(47) %8.2f `eGuttj0'[1,`j'] _col(61) %7.5f `loevHj'[1,`j'] _col(72) %8.4f `zHj'[1,`j'] _col(85) %7.5f `pvalHj'[1,`j'] _col(97) %2.0f `nbHjkNS`j''
}
di in green "{hline 99}"
if "`pairwise'"=="" {
   local nb=`nbtotindnm'
}
else {
   local nb=`nbobs'
}
di in green "Scale" in yellow _col(15) `nb' _col(38) %5.0f `eGutt' _col(47) %8.2f `eGutt0' _col(61) %-8.5f `loevH' _col(71) %9.4f `zH' _col(85) %7.5f `pvalH'

if "`pair'"!="" {
   di
   di in green _col(45) "Observed" _col(57) "Expected"
   di in green _col(`=`col'+10') "`text'" _col(46) "Guttman" _col(58) "Guttman" _col(69) "Loevinger" _col(92) "H0: Hjk<=0"
   di in green "Items"  _col(25) "Obs" _col(29) "P(Xj=`value',Xk=`value')" _col(47) "errors" _col(59) "errors" _col(71) "H coeff" _col(83) "z-stat." _col(95) "p-value"
   di in green "{hline 101}"
   forvalues j=1/`nbitems' {
      forvalues k=`=`j'+1'/`nbitems' {
         qui count if ``j''!=.
         local obs=r(N)
         di in green "``j''" _col(10) "``k''" in yellow _col(25) `Obs'[`j',`k'] _col(35) %6.4f `P`value'`value''[`j',`k'] _col(48) %5.0f `eGuttjk'[`j',`k'] _col(57) %8.2f `eGuttjk0'[`j',`k'] _col(70) %8.5f `loevHjk'[`j',`k'] _col(81) %9.4f `zHjk'[`j',`k'] _col(95) %7.5f `pvalHjk'[`j',`k']
      }
   }
   di in green "{hline 101}"
}
/*if `modamax'>1&"`ppp'"!="" {
   di in green "It is not possible to obtain the P++ diagnostics with polytomous items"
   local ppp
}
if `modamax'>1&"`pmm'"!="" {
   di in green "It is not possible to obtain the P-- diagnostics with polytomous items"
   local pmm
} */

tempname P11g P00g item id id2 p1 monlabel

/*if "`monotonicity'"!=""&`modamax'>1 {
   di in green "It is not possible to obtain the latent monotonicity diagnostics with polytomous items"
   local monotonicity
}  */

if  "`monotonicity'"!="" {
*set trace on
   if "`monotonicity'"=="*" {
      anaoption
   }
   else {
      anaoption,`monotonicity'
   }
   local minvi=r(minvi)
   local siglevel=r(siglevel)
   local minsize=r(minsize)
   local details `r(details)'
   if `minsize'==0 {
      if `nbobs'>500 {
         local minsize=round(`nbobs'/10)
      }
      else if `nbobs'>250 {
         local minsize=round(`nbobs'/5)
      }
      else {
         local minsize=max(50,round(`nbobs'/3))
      }
   }

*set trace on
   tempname score
   qui genscore `varlist',score(`score')
   di
   di in green _col(10) "Summary per item for check of monotonicity"
   di in green _col(10) "Minvi=" in ye %5.3f `minvi' _col(25) in green "Minsize=" in ye %5.0f `minsize' _col(40) in green "Alpha=" in ye %5.3f `siglevel'
   di
   di in green "Items"  _col(20) "#ac" _col(28) "#vi" _col(32) "#vi/#ac" _col(44) "maxvi" _col(56) "sum" _col(62) "sum/#ac" _col(75) "zmax"  _col(84) "#zsig"  _col(93) "Crit"
   di in green "{hline 97}"
*set trace on
   local vi=0
   local ac=0
   local sumvi=0
   local maxvi=0
   local zmaxvi=0
   local nbzvi=0
   forvalues i=1/`nbitems' {
      tempname restscore`i'
      qui gen `restscore`i''=`score'-``i''
      local restscoremax`i'=`scoremax'-`m`i''
      tempname restgroup`i'
      qui gengroup `restscore`i'',newvariable(`restgroup`i'') minsize(`minsize')
      local list`i'=r(list)
      qui su `restgroup`i''
      local nbgroups`i'=r(max)
      forvalues j=0/`nbgroups`i'' {
         qui count if `restgroup`i''==`j'
         local rgroup`j'=r(N)
      }
      local vi`i'=0
      local ac`i'=0
      local sumvi`i'=0
      local maxvi`i'=0
      local zmaxvi`i'=0
      local nbzvi`i'=0
      forvalues l=1/`m`i'' {
         local vi`i'_m`l'=0
         local ac`i'_m`l'=0
         local sumvi`i'_m`l'=0
         local maxvi`i'_m`l'=0
         local zmaxvi`i'_m`l'=0
         local nbzvi`i'_m`l'=0
      }
      forvalues l=1/`m`i'' {
         local vi`i'_`l'=0
         local ac`i'_`l'=0
         local sumvi`i'_`l'=0
         local maxvi`i'_`l'=0
         local zmaxvi`i'_`l'=0
         local nbzvi`i'_`l'=0
         forvalues j=1/`nbgroups`i'' {
            qui count if `restgroup`i''==`j'&``i''>=`l'
            local nbitem`i'rgroup`j'_`l'=r(N)
            forvalues k=1/`=`j'-1' {
               local diff=`nbitem`i'rgroup`k'_`l''/`rgroup`k''-`nbitem`i'rgroup`j'_`l''/`rgroup`j''
               if `nbitem`i'rgroup`j'_`l''!=`rgroup`j''&`nbitem`i'rgroup`k'_`l''!=0 {
                  local ac`i'_`l'=`ac`i'_`l''+1
                  if `diff'>`minvi' {
                     local vi`i'_`l'=`vi`i'_`l''+1
                     local sumvi`i'_`l'=`sumvi`i'_`l''+`diff'
                     if `diff'>`maxvi`i'_`l'' {
                        local maxvi`i'_`l'=`nbitem`i'rgroup`k'_`l''/`rgroup`k''-`nbitem`i'rgroup`j'_`l''/`rgroup`j''
                     }
                     local p=(`nbitem`i'rgroup`k'_`l''+`nbitem`i'rgroup`j'_`l'')/(`rgroup`j''+`rgroup`k'')
                     *local z=`diff'/sqrt(`p'*(1-`p')*(1/`rgroup`j''+1/`rgroup`k''))
                     *di "local z=abs(2*(sqrt(`nbitem`i'rgroup`j'_`l''+1)*sqrt(`rgroup`k''-`nbitem`i'rgroup`k'_`l''+1)-sqrt((`rgroup`j''-`nbitem`i'rgroup`j'_`l'')*`nbitem`i'rgroup`k'_`l''))/sqrt(`rgroup`j''+`rgroup`k''-1))      "
                     local z=abs(2*(sqrt(`nbitem`i'rgroup`j'_`l''+1)*sqrt(`rgroup`k''-`nbitem`i'rgroup`k'_`l''+1)-sqrt((`rgroup`j''-`nbitem`i'rgroup`j'_`l'')*`nbitem`i'rgroup`k'_`l''))/sqrt(`rgroup`j''+`rgroup`k''-1))
                     *di "=`z'"
                     if `z'>`=invnorm(1-`siglevel')' {
                        local nbzvi`i'_`l'=`nbzvi`i'_`l''+1
                     }
                     if `z'>`zmaxvi`i'_`l'' {
                        local zmaxvi`i'_`l'=`z'
                     }
                  }
               }
            }
            if `j'==`nbgroups`i'' {
               local vi`i'_m`l'=`vi`i'_`l''
               local ac`i'_m`l'=`ac`i'_`l''
               local sumvi`i'_m`l'=`sumvi`i'_`l''
               local maxvi`i'_m`l'=`maxvi`i'_`l''
               local zmaxvi`i'_m`l'=`zmaxvi`i'_`l''
               local nbzvi`i'_m`l'=`nbzvi`i'_`l''
            }
         }
         local vi`i'=`vi`i''+`vi`i'_`l''
         local ac`i'=`ac`i''+`ac`i'_`l''
         local sumvi`i'=`sumvi`i''+`sumvi`i'_`l''
         local nbzvi`i'=`nbzvi`i''+`nbzvi`i'_`l''
         if `maxvi`i''<`maxvi`i'_`l'' {
            local maxvi`i'=`maxvi`i'_`l''
         }
         if `zmaxvi`i''<`zmaxvi`i'_`l'' {
            local zmaxvi`i'=`zmaxvi`i'_`l''
         }
      }

      if "`details'"!=""&`m`i''!=1 {
         forvalues l=1/`m`i'' {
            if `vi`i'_m`l''!=0 {
               di in green "``i''>=`l'" in yellow _col(15) %8.0f `ac`i'_m`l'' _col(23) %8.0f `vi`i'_m`l'' _col(33) %6.4f `=`vi`i'_m`l''/`ac`i'_m`l''' _col(43) %6.4f `maxvi`i'_m`l'' _col(53) %6.4f `sumvi`i'_m`l'' _col(63) %6.4f `=`sumvi`i'_m`l''/`ac`i'_m`l''' _col(73) %6.4f `zmaxvi`i'_m`l'' _col(81) %8.0f `nbzvi`i'_m`l''
            }
            else {
               di in green "``i''>=`l'" in yellow _col(15) %8.0f `ac`i'_m`l'' _col(23) %8.0f `vi`i'_m`l''
            }
         }
         di in green "{dup 97:-}"
      }
      local vi=`vi'+`vi`i''
      local ac=`ac'+`ac`i''
      local sumvi=`sumvi'+`sumvi`i''
      local nbzvi=`nbzvi'+`nbzvi`i''
      if `maxvi'<`maxvi`i'' {
         local maxvi=`maxvi`i''
      }
      if `zmaxvi'<`zmaxvi`i'' {
         local zmaxvi=`zmaxvi`i''
      }
      *set trace on
      local t=`loevHj'[1,`i']
      local crit`i'=50*(.3-`t')+sqrt(`vi`i'')+100*`vi`i''/`ac`i''+100*`maxvi`i''+10*sqrt(`sumvi`i'')+1000*`sumvi`i''/`ac`i''+5*`zmaxvi`i''+10*sqrt(`nbzvi`i'')+100*`nbzvi`i''/`ac`i''
      if `vi`i''!=0 {
         di in green "``i''" in yellow _col(15) %8.0f `ac`i'' _col(23) %8.0f `vi`i'' _col(33) %6.4f `=`vi`i''/`ac`i''' _col(43) %6.4f `maxvi`i'' _col(53) %6.4f `sumvi`i'' _col(63) %6.4f `=`sumvi`i''/`ac`i''' _col(73) %6.4f `zmaxvi`i'' _col(81) %8.0f `nbzvi`i'' _col(93) %4.0f `crit`i'' _col(99) "{stata  traces `varlist',rest nodrawcomb cumulative onlyone(``i'') thres(`list`i''):graph}"
      }
      else {
         di in green "``i''" in yellow _col(15) %8.0f `ac`i'' _col(23) %8.0f `vi`i''  _col(93) %4.0f `crit`i'' _col(99) "{stata  traces `varlist',rest nodrawcomb cumulative onlyone(``i'') thres(`list`i''):graph}"
      }
      if "`details'"!=""&`i'!=`nbitems' {
         di in green "{dup 97:-}"
      }
      local ac=`ac'+`ac`i''
      local vi=`vi'+`vi`i''
   }
   di in green "{hline 97}"
      di in green "Total" in yellow _col(15) %8.0f `ac' _col(23) %8.0f `vi' _col(33) %6.4f `=`vi'/`ac'' _col(43) %6.4f `maxvi' _col(53) %6.4f `sumvi' _col(63) %6.4f `=`sumvi'/`ac'' _col(73) %6.4f `zmaxvi' _col(81) %8.0f `nbzvi'
   di in green "{hline 97}"
}
/*if  "`nirestscore'"!="" {
*set trace on
   if "`nirestscore'"=="*" {
      anaoption
   }
   else {
      anaoption,`nirestscore'
   }
   local minvi=r(minvi)
   local siglevel=r(siglevel)
   local minsize=r(minsize)
   local details `r(details)'
   if `minsize'==0 {
      if `nbobs'>500 {
         local minsize=round(`nbobs'/10)
      }
      else if `nbobs'>250 {
         local minsize=round(`nbobs'/5)
      }
      else {
         local minsize=max(50,round(`nbobs'/3))
      }
   }

*set trace on
   tempname score
   qui genscore `varlist',score(`score')
   di
   di in green _col(10) "Summary per item for check of Non-Intersection via Rest-score"
   di in green _col(10) "Minvi=" in ye %5.3f `minvi' _col(25) in green "Minsize=" in ye %5.0f `minsize' _col(40) in green "Alpha=" in ye %5.3f `siglevel'
   di
   di in green "Items"  _col(20) "#ac" _col(28) "#vi" _col(32) "#vi/#ac" _col(44) "maxvi" _col(56) "sum" _col(62) "sum/#ac" _col(75) "zmax"  _col(84) "#zsig"  _col(93) "Crit"
   di in green "{hline 97}"
*set trace on
   local vi=0
   local ac=0
   local sumvi=0
   local maxvi=0
   local zmaxvi=0
   local nbzvi=0
   forvalues i=1/`nbitems' {
      local vi`i'`j'=0
      local ac`i'=0
      local sumvi`i'=0
      local maxvi`i'=0
      local zmaxvi`i'=0
      local nbzvi`i'=0
      forvalues l=1/`m`i'' {
         local vi`i'_m`l'=0
         local ac`i'_m`l'=0
         local sumvi`i'_m`l'=0
         local maxvi`i'_m`l'=0
         local zmaxvi`i'_m`l'=0
         local nbzvi`i'_m`l'=0
         local vi`i'_`l'=0
         local ac`i'_`l'=0
         local sumvi`i'_`l'=0
         local maxvi`i'_`l'=0
         local zmaxvi`i'_`l'=0
      }
      forvalues j=1/`nbitems' {
         if `j'!=`i' {
            tempname restscorei`i'j`j'
            qui gen `restscorei`i'j`j''=`score'-``i''-``j''
            local restscoremax`i'=`scoremax'-`m`i''
            tempname restgroupi`i'j`j'
            qui gengroup `restscorei`i'j`j'',newvariable(`restgroupi`i'j`j'') minsize(`minsize')
            local listi`i'j`j'=r(list)
            qui su `restgroupi`i'j`j''
            local nbgroupsi`i'j`j'=r(max)
            forvalues k=0/`nbgroupsi`i'j`j'' {
               qui count if `restgroupi`i'j`j''==`k'
               local rgroup`k'=r(N)
            }
            forvalues l=1/`m`i'' {
               forvalues k=1/`m`j'' {
                  forvalues m=1/`nbgroupsi`i'j`j'' {
                      qui count if `restgroupi`i'j`j''==`m'&``i''>=`l'&``j''>=`k'
                      local nbitemi`i'j`j'rgroup`m'_`l'_`k'=r(N)
                      forvalues n=1/`=`m'-1' {
                         local diff=`nbitemi`i'j`j'rgroup`m'_`l'_`k''/`rgroup`m''-`nbitemi`i'j`j'rgroup`m'_`l'_`k''/`rgroup`m''
                         if `nbitemi`i'j`j'rgroup`m'_`l'_`k''!=`rgroup`m''&`nbitemi`i'j`j'rgroup`m'_`l'_`k''!=0 {
                         local ac`i'_`l'=`ac`i'_`l''+1
                         if `diff'>`minvi' {
                            local vi`i'_`l'=`vi`i'_`l''+1
                            local sumvi`i'_`l'=`sumvi`i'_`l''+`diff'
                            if `diff'>`maxvi`i'_`l'' {
                               local maxvi`i'_`l'=`nbitemi`i'j`j'rgroup`m'_`l'_`k''/`rgroup`m''-`nbitemi`i'j`j'rgroup`m'_`l'_`k''/`rgroup`m''
                            }
                            local p=(`nbitemi`i'j`j'rgroup`m'_`l'_`k''+`nbitemi`i'j`j'rgroup`m'_`l'_`k'')/(`rgroup`m''+`rgroup`n'')
                            local z=abs(2*(sqrt(`nbitemi`i'j`j'rgroup`m'_`l'_`k''+1)*sqrt(`rgroup`m''-`nbitemi`i'j`j'rgroup`m'_`l'_`k''+1)-sqrt((`rgroup`m''-`nbitemi`i'j`j'rgroup`m'_`l'_`k'')*`nbitemi`i'j`j'rgroup`m'_`l'_`k''))/sqrt(`rgroup`m''+`rgroup`n''-1))
                            if `z'>`=invnorm(1-`siglevel')' {
                               local nbzvi`i'_`l'=`nbzvi`i'_`l''+1
                            }
                            if `z'>`zmaxvi`i'_`l'' {
                               local zmaxvi`i'_`l'=`z'
                            }
                         }
                      }
                      if `m'==`nbgroupsi`i'j`j'' {
                         local vi`i'_m`l'=`vi`i'_`l''
                         local ac`i'_m`l'=`ac`i'_`l''
                         local sumvi`i'_m`l'=`sumvi`i'_`l''
                         local maxvi`i'_m`l'=`maxvi`i'_`l''
                         local zmaxvi`i'_m`l'=`zmaxvi`i'_`l''
                         *local nbzvi`i'_m`l'=`nbzvi`i'_`l''
                      }
                  }
               }
               local vi`i'=`vi`i''+`vi`i'_`l''
               local ac`i'=`ac`i''+`ac`i'_`l''
               local sumvi`i'=`sumvi`i''+`sumvi`i'_`l''
               *local nbzvi`i'=`nbzvi`i''+`nbzvi`i'_`l''
               if `maxvi`i''<`maxvi`i'_`l'' {
                  local maxvi`i'=`maxvi`i'_`l''
               }
               if `zmaxvi`i''<`zmaxvi`i'_`l'' {
                  local zmaxvi`i'=`zmaxvi`i'_`l''
               }
            }
         }
      }
      if "`details'"!=""&`m`i''!=1 {
         forvalues l=1/`m`i'' {
            if `vi`i'_m`l''!=0 {
               di in green "``i''>=`l'" in yellow _col(15) %8.0f `ac`i'_m`l'' _col(23) %8.0f `vi`i'_m`l'' _col(33) %6.4f `=`vi`i'_m`l''/`ac`i'_m`l''' _col(43) %6.4f `maxvi`i'_m`l'' _col(53) %6.4f `sumvi`i'_m`l'' _col(63) %6.4f `=`sumvi`i'_m`l''/`ac`i'_m`l''' _col(73) %6.4f `zmaxvi`i'_m`l'' _col(81) %8.0f `nbzvi`i'_m`l''
            }
            else {
               di in green "``i''>=`l'" in yellow _col(15) %8.0f `ac`i'_m`l'' _col(23) %8.0f `vi`i'_m`l''
            }
         }
         di in green "{dup 97:-}"
      }
      local vi=`vi'+`vi`i''
      local ac=`ac'+`ac`i''
      local sumvi=`sumvi'+`sumvi`i''
      local nbzvi=`nbzvi'+`nbzvi`i''
      if `maxvi'<`maxvi`i'' {
         local maxvi=`maxvi`i''
      }
      if `zmaxvi'<`zmaxvi`i'' {
         local zmaxvi=`zmaxvi`i''
      }
      *set trace on
      local t=`loevHj'[1,`i']
      local crit`i'=50*(.3-`t')+sqrt(`vi`i'')+100*`vi`i''/`ac`i''+100*`maxvi`i''+10*sqrt(`sumvi`i'')+1000*`sumvi`i''/`ac`i''+5*`zmaxvi`i''+10*sqrt(`nbzvi`i'')+100*`nbzvi`i''/`ac`i''
      if `vi`i''!=0 {
         di in green "``i''" in yellow _col(15) %8.0f `ac`i'' _col(23) %8.0f `vi`i'' _col(33) %6.4f `=`vi`i''/`ac`i''' _col(43) %6.4f `maxvi`i'' _col(53) %6.4f `sumvi`i'' _col(63) %6.4f `=`sumvi`i''/`ac`i''' _col(73) %6.4f `zmaxvi`i'' _col(81) %8.0f `nbzvi`i'' _col(93) %4.0f `crit`i'' _col(99) "{stata  traces `varlist',rest nodrawcomb cumulative onlyone(``i'') thres(`list`i''):graph}"
      }
      else {
         di in green "``i''" in yellow _col(15) %8.0f `ac`i'' _col(23) %8.0f `vi`i''  _col(93) %4.0f `crit`i'' _col(99) "{stata  traces `varlist',rest nodrawcomb cumulative onlyone(``i'') thres(`list`i''):graph}"
      }
      if "`details'"!=""&`i'!=`nbitems' {
         di in green "{dup 97:-}"
      }
      local ac=`ac'+`ac`i''
      local vi=`vi'+`vi`i''
   }
   di in green "{hline 97}"
      di in green "Total" in yellow _col(15) %8.0f `ac' _col(23) %8.0f `vi' _col(33) %6.4f `=`vi'/`ac'' _col(43) %6.4f `maxvi' _col(53) %6.4f `sumvi' _col(63) %6.4f `=`sumvi'/`ac'' _col(73) %6.4f `zmaxvi' _col(81) %8.0f `nbzvi'
   di in green "{hline 97}"
}    */

if "`ppp'"!=""|"pmm"!=""|"`nipmatrix'"!=""|"`generror'"!="" {
    local list
    local listi
    local listm
    local listv
    forvalues i=1/`nbitems' {
       forvalues l=1/`m`i'' {
          tempname item`i'_`l'
          qui gen `item`i'_`l''=``i''>=`l' if ``i''!=.
          local list `list' ``i''_`l'
          local listi `listi' ``i''
          local listm `listm' `l'
          local listv `listv' `item`i'_`l''
       }
    }
    tempname matppp matpmm
    matrix `matppp'=J(`=`scoremax'',`=`scoremax'+2',0)
    matrix `matpmm'=J(`=`scoremax'',`=`scoremax'+2',0)
    local row=1
    forvalues i=1/`nbitems' {
       forvalues k=1/`m`i'' {
          local col=1
          forvalues j=1/`nbitems' {
             forvalues l=1/`m`j'' {
                if `i'!=`j' {
                   qui count if `item`i'_`k''!=.&`item`j'_`l''!=.
                   local denom=r(N)
                   qui count if `item`i'_`k''==1&`item`j'_`l''==1
                   local pos=r(N)
                   matrix `matppp'[`row',`col']=`=`pos'/`denom''
                   qui count if `item`i'_`k''==0&`item`j'_`l''==0
                   local pos=r(N)
                   matrix `matpmm'[`row',`col']=`=`pos'/`denom''
                }
                else {
                   matrix `matppp'[`row',`col']=-1
                   matrix `matpmm'[`row',`col']=-1
                }
                local col=`col'+1
             }
          }
          qui count if `item`i'_`k''!=.
          local denom=r(N)
          qui count if `item`i'_`k''==1
          local pos=r(N)
          matrix `matppp'[`row',`col']=`=`pos'/`denom''
          qui count if `item`i'_`k''==0
          local pos=r(N)
          matrix `matpmm'[`row',`col']=`=`pos'/`denom''
          matrix `matppp'[`row',`=`scoremax'+2']=`i'
          matrix `matpmm'[`row',`=`scoremax'+2']=`i'
          local row=`row'+1
       }
    }
    matrix colnames `matppp'=`list' p1 item
    matrix rownames `matppp'=`list'
    matrix colnames `matpmm'=`list' p1 item
    matrix rownames `matpmm'=`list'
    if "`nipmatrix'"!="" {
       if "`nipmatrix'"=="*" {
          anaoption
       }
       else {
          anaoption,`nipmatrix'
       }
       local minvi=`r(minvi)'
       local siglevel=`r(siglevel)'
       local minsize=`r(minsize)'
       local details `r(details)'
       if `minsize'==0 {
          if `nbobs'>500 {
             local minsize=round(`nbobs'/10)
          }
          else if `nbobs'>250 {
             local minsize=round(`nbobs'/5)
          }
          else {
             local minsize=max(50,round(`nbobs'/3))
          }
       }
       forvalues i=1/`nbitems' {
          local nbacpp`i'=0
          local nbvipp`i'=0
          local maxvipp`i'=0
          local sumvipp`i'=0
          local zmaxpp`i'=0
          local nbsigzpp`i'=0
          local nbacmm`i'=0
          local nbvimm`i'=0
          local maxvimm`i'=0
          local sumvimm`i'=0
          local zmaxmm`i'=0
          local nbsigzmm`i'=0
       }
    }

}
tempfile temporaryfile
qui save `temporaryfile'

if "`ppp'"!=""|"`nipmatrix'"!=""|"`generror'"!="" {
    drop *
    qui svmat `matppp',names(col)
    qui recode `list' (-1=.)
    qui gen `id'=_n
    qui gen str9 `item'=""
    local connect "l"
    local list2
    local listw2
    sort p1
    qui set obs `=`scoremax'+1'
    local listitem
    forvalues i=1/`scoremax' {
        local t=item[`i']
        local listitem `listitem' `t'
        local w:word `i' of `list'
        qui replace `item'="`w'" if `id'==`i'
        qui replace `w'=. if `id'==`i'
        local connect "`connect' l"
        local z=regexr("`w'","_",">=")
        label define `monlabel' `i' "`z'", add
        label variable `w' "`z'"
        qui su p1 if `id'==`i'
        local prop=r(mean)
        qui replace `w'=`prop' in `=`scoremax'+1'
    }
    forvalues i=1/`scoremax' {
        local v=`item'[`i']
        local list2 `list2' `v'
        local v=`id'[`i']
        local listw2 `listw2' `v'
    }
    label define `monlabel' `=`scoremax'+1' "Prop",add
    order `list2'
    qui gen `id2'=_n
    label value `id2' `monlabel'
    label variable `id2' " "
    if "`graph'"!="" {
       twoway conn `list' `id2' in 1/`scoremax',connect(`connect') ytitle("") title("P++ diagnostics") name(ppp,replace)
    }
    format `list' %5.3f
    label variable `id' "Item"
    rename `id' Item
    label value Item `monlabel'
    qui replace Item=`=`scoremax'+1' in `=`scoremax'+1'
    tempname matpp
    matrix define `matpp'=J(`scoremax',`scoremax',0)
    forvalues i=1/`scoremax' {
       forvalues j=1/`scoremax' {
          local ti:word `i' of `listv'
          local tj:word `j' of `listv'
          local t:word `j' of `list2'
          matrix `matpp'[`i',`j']=`t'[`i']
       }
    }
    matrix colnames `matpp'=`list2'
    matrix rownames `matpp'=`list2'
    if "`ppp'"!="" {
       di
       di in green _col(10) "P++ values per items pair (The values should be increasing in each column)"

       matrix list `matpp',format(%5.3f)  nohalf   noheader
    }
    label drop `monlabel'
    *set trace on
    qui use "`temporaryfile'",clear
    if "`nipmatrix'"!="" {
       forvalues i=1/`scoremax' {
          forvalues j=1/`scoremax' {
             forvalues k=`=`j'+1'/`scoremax' {
*di "`listv' `listw2'"
                local ti:word `i' of `listitem'
                local tj:word `j' of `listitem'
                local tk:word `k' of `listitem'
                if `tj'!=`tk'&`tj'!=`ti'&`ti'!=`tk'/*`matmm'[`k',`i']!=.&`matmm'[`j',`i']!=.*/ {
                   local ++nbacpp`ti'
                   *local ++nbacmm`tk'
                   local diff=`matpp'[`j',`i']-`matpp'[`k',`i']
                   if `diff'>`minvi'&`diff'!=. {
                      local ++nbvipp`tj'
                      local ++nbvipp`tk'
                      local sumvipp`tj'=`sumvipp`tj''+`diff'
                      local sumvipp`tk'=`sumvipp`tk''+`diff'
                      if `diff'>`maxvipp`tj'' {
                         local maxvipp`tj'=`diff'
                      }
                      if `diff'>`maxvipp`tk'' {
                         local maxvipp`tk'=`diff'
                      }
                      local wi:word `i' of `listw2'
                      local wj:word `j' of `listw2'
                      local wk:word `k' of `listw2'
                      local li:word `wi' of `listv'
                      local lj:word `wj' of `listv'
                      local lk:word `wk' of `listv'
                      local ii:word `wi' of `list'
                      local ij:word `wj' of `list'
                      local ik:word `wk' of `list'

                      qui count if `li'==1&`lj'==1&`lk'==0
                      local a=r(N)
                      qui count if `li'==1&`lj'==0&`lk'==1
                      local b=r(N)
                      local n=`a'+`b'
                      local k=`b'
                      local b=((2*`k'+1-`n')^2-10*`n')/(12*`n')
                      local z=sqrt(2*`k'+2+`b')-sqrt(2*`n'-2*`k'+`b')
                      *di "++ `li', `lj', `lk', `ii', `ij', `ik' : `n', `k', `z'"

                      if abs(`z')>`=invnorm(1-`siglevel')'&`z'!=. {
                         local ++nbsigzpp`tj'
                         if abs(`z')>`zmaxpp`tj'' {
                            local zmaxpp`tj'=abs(`z')
                         }
                         local ++nbsigzpp`tk'
                         if abs(`z')>`zmaxpp`tk'' {
                            local zmaxpp`tk'=abs(`z')
                         }
                      }
                   }
                }
             }
          }
       }
    }
/*    if "`nipmatrix'"!="" {
       forvalues i=1/`scoremax' {
          forvalues j=1/`scoremax' {
             forvalues k=`=`j'+1'/`scoremax' {
                local ti:word `i' of `listitem'
                local tj:word `j' of `listitem'
                local tk:word `k' of `listitem'
                if `tj'!= `tk'&`ti'!=`tk'&`ti'!=`tj' {
                   local ++nbacpp`ti'
                   local diff=`matpp'[`j',`i']-`matpp'[`k',`i']
                   if `diff'>`minsize'&`diff'!=. {
                      local ++nbvipp`tj'
                      local ++nbvipp`tk'
                      local sumvipp`tj'=`sumvipp`tj''+`diff'
                      local sumvipp`tk'=`sumvipp`tk''+`diff'
                      if `diff'>`maxvipp`tj'' {
                         local maxvipp`tj'=`diff'
                      }
                      if `diff'>`maxvipp`tk'' {
                         local maxvipp`tk'=`diff'
                      }
                   }
                }
             }
          }
       }
    }
*/
}
if "`pmm'"!=""|"`nipmatrix'"!="" {
    drop _all
    qui svmat `matpmm',names(col)
    qui recode `list' (-1=.)
    qui gen `id'=_n
    qui gen str9 `item'=""
    local connect "l"
    local list2
    local listw2
    gsort -p1
    qui set obs `=`scoremax'+1'
    forvalues i=1/`scoremax' {
        local w:word `i' of `list'
        qui replace `item'="`w'" if `id'==`i'
        qui replace `w'=. if `id'==`i'
        local connect "`connect' l"
        local z=regexr("`w'","_",">=")
        label define `monlabel' `i' "`z'", add
        label variable `w' "`z'"
        qui su p1 if `id'==`i'
        local prop=r(mean)
        qui replace `w'=`prop' in `=`scoremax'+1'
    }
    forvalues i=1/`scoremax' {
        local v=`item'[`i']
        local list2 `list2' `v'
        local v=`id'[`i']
        local listw2 `listw2' `v'
    }
    label define `monlabel' `=`scoremax'+1' "Prop",add
    order `list2'
    qui gen `id2'=_n
    label value `id2' `monlabel'
    label variable `id2' " "
    if "`graph'"!="" {
       twoway conn `list' `id2' in 1/`scoremax',connect(`connect') ytitle("") title("P-- diagnostics") name(pmm,replace)
    }
    format `list' %5.3f
    label variable `id' "Item"
    rename `id' Item
    label value Item `monlabel'
    qui replace Item=`=`scoremax'+1' in `=`scoremax'+1'
    tempname matmm
    matrix define `matmm'=J(`scoremax',`scoremax',0)
    forvalues i=1/`scoremax' {
       forvalues j=1/`scoremax' {
          local t:word `j' of `list2'
          matrix `matmm'[`i',`j']=`t'[`i']
       }
    }
    matrix colnames `matmm'=`list2'
    matrix rownames `matmm'=`list2'
    if "`pmm'"!="" {
       di
       di in green _col(10) "P-- values per items pair (The values should be decreasing in each column)"
       matrix list `matmm',format(%5.3f)  nohalf   noheader
    }
    label drop `monlabel'
    qui use "`temporaryfile'",clear
    if "`nipmatrix'"!="" {
       forvalues i=1/`scoremax' {
          forvalues j=1/`scoremax' {
             forvalues k=`=`j'+1'/`scoremax' {
*di "`listv' `listw2'"
                local ti:word `i' of `listitem'
                local tj:word `j' of `listitem'
                local tk:word `k' of `listitem'
                if `tj'!=`tk'&`tj'!=`ti'&`ti'!=`tk'/*`matmm'[`k',`i']!=.&`matmm'[`j',`i']!=.*/ {
                   local ++nbacmm`ti'
                   *local ++nbacmm`tk'
                   local diff=`matmm'[`k',`i']-`matmm'[`j',`i']
                   if `diff'>`minvi'&`diff'!=. {
                      local ++nbvimm`tj'
                      local ++nbvimm`tk'
                      local sumvimm`tj'=`sumvimm`tj''+`diff'
                      local sumvimm`tk'=`sumvimm`tk''+`diff'
                      if `diff'>`maxvimm`tj'' {
                         local maxvimm`tj'=`diff'
                      }
                      if `diff'>`maxvimm`tk'' {
                         local maxvimm`tk'=`diff'
                      }
                      local wi:word `i' of `listw2'
                      local wj:word `j' of `listw2'
                      local wk:word `k' of `listw2'
                      local li:word `wi' of `listv'
                      local lj:word `wj' of `listv'
                      local lk:word `wk' of `listv'
                      local ii:word `wi' of `list'
                      local ij:word `wj' of `list'
                      local ik:word `wk' of `list'

                      qui count if `li'==0&`lj'==1&`lk'==0
                      local a=r(N)
                      qui count if `li'==0&`lj'==0&`lk'==1
                      local b=r(N)
                      local n=`a'+`b'
                      local k=`b'
                      local b=((2*`k'+1-`n')^2-10*`n')/(12*`n')
                      local z=sqrt(2*`k'+2+`b')-sqrt(2*`n'-2*`k'+`b')
                      *di "-- `li', `lj', `lk', `ii', `ij', `ik' : `n', `k', `z'"

                      if abs(`z')>`=invnorm(1-`siglevel')'&`z'!=. {
                         local ++nbsigzmm`tj'
                         if abs(`z')>`zmaxmm`tj'' {
                            local zmaxmm`tj'=abs(`z')
                         }
                         local ++nbsigzmm`tk'
                         if abs(`z')>`zmaxmm`tk'' {
                            local zmaxmm`tk'=abs(`z')
                         }
                      }
                   }
                }
             }
          }
       }
    }
}
if "`nipmatrix'"!="" {
   *set trace on
   di
   di in green _col(10) "Summary per item for check of non-Intersection via Pmatrix"
   di in green _col(10) "Minvi=" in ye %5.3f `minvi' _col(25) /*in green "Minsize=" in ye %5.0f `minsize' _col(40)*/ in green "Alpha=" in ye %5.3f `siglevel'
   di
   di in green "Items"  _col(20) "#ac" _col(28) "#vi" _col(32) "#vi/#ac" _col(44) "maxvi" _col(56) "sum" _col(62) "sum/#ac" _col(75) "zmax"  _col(84) "#zsig"  _col(93) "Crit"
   di in green "{hline 97}"
   forvalues i=1/`nbitems' {
      local nbac`i'=`nbacpp`i''+`nbacmm`i''
      local nbvi`i'=`nbvipp`i''+`nbvimm`i''
      local maxvi`i'=max(`maxvipp`i'',`maxvimm`i'')
      local sumvi`i'=`sumvipp`i''+`sumvimm`i''
      local zmaxvi`i'=max(`zmaxpp`i'',`zmaxmm`i'')

      local nbzsig`i'=`nbsigzpp`i''+`nbsigzmm`i''
      local zmax`i'=0
      *local nbsigz`i'=0
      local t=`loevHj'[1,`i']
*      di "local crit`i'=50*(.3-`t')+sqrt(`nbvi`i'')+100*`nbvi`i''/`nbac`i''+100*`maxvi`i''+10*sqrt(`sumvi`i'')+1000*`sumvi`i''/`nbac`i''+5*`zmax`i''+10*sqrt(`nbzsig`i'')+100*`nbzsig`i''/`nbac`i''     "
      local crit`i'=50*(.3-`t')+sqrt(`nbvi`i'')+100*`nbvi`i''/`nbac`i''+100*`maxvi`i''+10*sqrt(`sumvi`i'')+1000*`sumvi`i''/`nbac`i''+5*`zmaxvi`i''+10*sqrt(`nbzsig`i'')+100*`nbzsig`i''/`nbac`i''

      *di `nbac`i'' "   " `nbvi`i'' "   " `sumvi`i''
      if `nbvi`i''!=0 {
         di in green "``i''" in yellow _col(15) %8.0f `nbac`i'' _col(23) %8.0f `nbvi`i'' _col(33) %6.4f `=`nbvi`i''/`nbac`i''' _col(43) %6.4f `maxvi`i'' _col(53) %6.4f `sumvi`i'' _col(63) %6.4f `=`sumvi`i''/`nbac`i''' _col(73) %6.4f `zmaxvi`i'' _col(81) %8.0f `nbzsig`i'' _col(93) %4.0f `crit`i''
      }
      else {
         di in green "``i''" in yellow _col(15) %8.0f `nbac`i'' _col(23) %8.0f `nbvi`i''  _col(93) %4.0f `crit`i''
      }
   }
}

/*if "`pmm'"!="" {
    drop _all
    matrix `P00g'=`P00',`P1''
    matrix colnames `P00g'=`varlist' `p1'
    matrix rownames `P00g'=`varlist'
    qui svmat `P00g' , names(col)
    qui gen `id'=_n
    qui gen str9 `item'=""
    local connect "l"
    forvalues i=1/`nbitems' {
        qui replace `item'="``i''" if `id'==`i'
        qui replace ``i''=. if `id'==`i'
        local connect "`connect' l"
        label define `monlabel' `i' "``i''", add
    }
    sort `p1'
    qui gen `id2'=_n
    label value `id2' `monlabel'
    label variable `id2' " "
    if "`graph'"!="" {
       twoway connected `varlist' `id2',connect(`connect') ytitle("") title("P-- diagnostics") name(pmm,replace)
    }
    format `varlist' %5.3f
    label variable `id' "Item"
    label value `id' `monlabel'
    di
    di in green _col(10) "P-- values per items pair (The values should be decreasing in each column)"
    list `id' `varlist' , table compress separator(`nbitems') noobs divider
    label drop `monlabel'
}



if "`pairwise'"=="" {
   restore, not
}*/


*di "listw2:`listw2'"
*di "listv:`listv'"
*di "list:`list'"
*di "listi:`listi'"
*di "listm:`listm'"
*di "listitem:`listitem'"


qui use "`loevHfile'",clear
*set trace on
if "`generror'"!="" {
   if "`replace'"!="" {
      capture drop `generror'_0
      capture drop `generror'_H
      capture drop `generror'_max
      capture drop `generror'_GPN
      capture drop `generror'
   }
   qui gen `generror'=0
   *forvalues i=1/`nbitems' {
   *   qui gen `generror'_``i''=0
   *}
   qui gen `generror'_0=`eGutt0'/`nb'
   local nbsteps:word count `listitem'
   if "`pairwise'"=="" {
      forvalues i=1/`nbitems' {
         qui replace `generror'=. if ``i''==.
         qui replace `generror'_0=. if ``i''==.
      }
   }
   forvalues i=0/`nbsteps' {
       qui guttmax `listitem', score(`i')
       local errmax`i'=r(maxegutt)
   }
*   matrix list `P0'
   forvalues i=1/`nbsteps' {
      forvalues j=`=`i'+1'/`nbsteps' {
         local w2i:word `i' of `listw2'
         local w2j:word `j' of `listw2'
         local itemi:word `w2i' of `listi'
         local modai:word `w2i' of `listm'
         local itemj:word `w2j' of `listi'
         local modaj:word `w2j' of `listm'
         qui replace `generror'=`generror'+1 if `itemi'>=`modai'&`itemj'<`modaj'&`itemi'!=.&`itemj'!=.
         *qui replace `generror'_`itemi'=`generror'_`itemi'+1 if `itemi'>=`modai'&`itemj'<`modaj'&`itemi'!=.&`itemj'!=.
         *qui replace `generror'_`itemj'=`generror'_`itemj'+1 if `itemi'>=`modai'&`itemj'<`modaj'&`itemi'!=.&`itemj'!=.
*         qui replace `generror'=`generror'+.5 if `itemi'>=`modai'&`itemj'<`modaj'&`itemi'!=.&`itemj'!=.&`P1'[1,`i']==`P1'[1,`j']
         *qui replace `generror'=`generror'+.5 if `P1'[1,`i']==`P1'[1,`j']&``i''==1&``j''==0
      }
   }
*   set trace on
   tempvar flag
   qui gen `flag'=0
   qui replace `flag'=1 `if'
   qui replace `generror'=. if `flag'==0
   qui replace `generror'_0=.  if `flag'==0
   qui gen `generror'_H=1-`generror'/`generror'_0
   tempvar score
   qui genscore `varlist' `if',score(`score')
   qui gen `generror'_max=.
   forvalues i=1/`nbsteps' {
      qui replace `generror'_max=`errmax`i'' if `score'==`i'
   }
   qui gen `generror'_GPN=`generror'/`generror'_max
   label variable `generror' "Number of Guttman errors per individual"
   label variable `generror'_H "H indice per individual"
   if "`graph'"!="" {
      qui histogram `generror',discrete freq name(errors,replace)
      qui histogram `generror'_H,discrete freq name(H,replace)
   }
   qui su `generror'  ,det
   local meane=r(mean)
   local mede=r(p50)
   local mine=r(min)
   local maxe=r(max)
   qui su `generror'_GPN  ,det
   local meanGPN=r(mean)
   local medGPN=r(p50)
   local minGPN=r(min)
   local maxGPN=r(max)
   di
   di in green "Number of Guttman errors by individual"        _col(50) in green "Normalized number of Guttamn errors by individual"
   di in green "            Mean number: " in ye %7.2f `meane' _col(50) in green "            Mean number: " in ye %7.2f `meanGPN'
   di in green "          Median number: " in ye %7.2f `mede'  _col(50) in green "          Median number: " in ye %7.2f `medGPN'
   di in green "         Minimal number: " in ye %7.2f `mine'  _col(50) in green "         Minimal number: " in ye %7.2f `minGPN'
   di in green "         Maximal number: " in ye %7.2f `maxe'  _col(50) in green "         Maximal number: " in ye %7.2f `maxGPN'
   di in green "Expected Guttman errors: " in ye %7.2f `=`eGutt0'/`nb''
   qui count if `generror'_H<0
   di in green "           Rate of Hn<0: " in ye %7.2f `=r(N)/`nb'*100' "%"

}

matrix colnames `loevHj'=`varlist'
matrix rownames `loevHj'=Hj
return matrix loevHj `loevHj'

matrix colnames `loevHjk'=`varlist'
matrix rownames `loevHjk'=`varlist'
return matrix loevHjk `loevHjk'

matrix colnames `eGuttj'=`varlist'
matrix rownames `eGuttj'=ej
return matrix eGuttj `eGuttj'

matrix colnames `eGuttjk'=`varlist'
matrix rownames `eGuttjk'=`varlist'
return matrix eGuttjk `eGuttjk'

matrix colnames `eGuttj0'=`varlist'
matrix rownames `eGuttj0'=ejk
return matrix eGuttj0 `eGuttj0'

matrix colnames `eGuttjk0'=`varlist'
matrix rownames `eGuttjk0'=`varlist'
return matrix eGuttjk0 `eGuttjk0'

return scalar loevH=`loevH'
return scalar eGutt =`eGutt'
return scalar eGutt0 =`eGutt0'

if `modamax'==1 {
   matrix colnames `P11'=`varlist'
   matrix rownames `P11'=`varlist'
   return matrix P11 `P11'
}

matrix colnames `P00'=`varlist'
matrix rownames `P00'=`varlist'
return matrix P00 `P00'

if "`ppp'"!=""|"`nipmatrix'"!="" {
   return matrix ppp=`matpp'
}
if "`pmm'"!=""|"`nipmatrix'"!="" {
   return matrix pmm=`matmm'
}

matrix colnames `zHj'=`varlist'
matrix rownames `zHj'=zHj
return matrix zHj `zHj'

matrix colnames `pvalHj'=`varlist'
matrix rownames `pvalHj'=pval
return matrix pvalHj `pvalHj'

return scalar zH=`zH'
return scalar pvalH=`pvalH'
if "`pair'"!="" {
    matrix colnames `zHjk'=`varlist'
    matrix rownames `zHjk'=`varlist'
    return matrix zHjk `zHjk'

    matrix colnames `pvalHjk'=`varlist'
    matrix rownames `pvalHjk'=`varlist'
    return matrix pvalHjk `pvalHjk'
}

matrix colnames `Obs'=`varlist'
matrix rownames `Obs'=`varlist'
return matrix Obs `Obs'

capture restore, not

end
