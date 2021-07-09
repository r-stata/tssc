*! version 8.7  28 May 2013
*! Jean-Benoit Hardouin
*************************************************************************************************************
* Raschtestv7: Rasch model, fit tests and graphical representations
* Corresponds to the version 8 of Raschtest (http://freeirt.org) for Stata7
*
* Historic:
* Version 2.1 (2003-07-10): Jean-Benoit Hardouin
* Version 3.1 (2004-01-02) : Jean-Benoit Hardouin
* Version 7.1 (2005-03-30) : Jean-Benoit Hardouin
* Version 7.2.1 (2005-05-21) : Jean-Benoit Hardouin
* Version 7.3.1 (2005-07-02) : Jean-Benoit Hardouin
* Version 7.3.2 (2005-10-05) : Jean-Benoit Hardouin /*correction for the *genlt* option with *method(cml)**/
* Version 7.3.3 (2005-12-21) : Jean-Benoit Hardouin /*correction if scores are not represented with method(mml) or method(gee)*/
* Version 7.4.1 (2006-01-17) : Jean-Benoit Hardouin /*Standardized OUTFIT and INFIT, DIF option*/
* Version 7.4.2 (2006-03-21) : Jean-Benoit Hardouin /*Avoids a bug when the temporary files are saved in a directory containing special characters*/
* Version 7.4.3 (2006-11-15) : Jean-Benoit Hardouin /*Avoids a bug when the directory defined in the dirsave option contains special characters*/
* Version 7.5.1 (2007-04-20) : Jean-Benoit Hardouin /*Return results of the comp option*/
* Version 7.6.1 (2008-06-26) : Jean-Benoit Hardouin /*Nold option, corrects a bug with the genlt option*/
* Version 7.6.2 (2009-03-01) : Jean-Benoit Hardouin /*Correction of the SE of the latent trait, graph option, correction of a bug with the if option, PSI in MML*/
* Version 8.1 (2009-06-24) : Jean-Benoit Hardouin /*DIFFICULTIES option, COVARIATES option*/
* Version 8.2 (2009-07-15) : Jean-Benoit Hardouin /*Correction of a bug with CML*/
* Version 8.3 (2009-12-19) : Jean-Benoit Hardouin /*correction of a bug with DIFFICULTIES and COVARIATES options together*/
* Version 8.4 (2010-06-15) : Jean-Benoit Hardouin /*GENRES option */
* Version 8.5 (2011-12-20) : Jean-Benoit Hardouin /*Correction for the ss1 and ss3 suboptions of the COVARIATES option */
* Version 8.6 (2012-11-20) : Jean-Benoit Hardouin /*HTML option*/
* Version 8.7 (2013-05-28) : Jean-Benoit Hardouin /*Correction of a bug in the covariates option with ss1 and ss3*/
*
* Needed modules :
* gammasym version 2.2 (http://www.freeirt.org)
* gausshermite version 1 (http://www.freeirt.org)
* geekel2d version 4.3 (http://www.freeirt.org)
* genscore version 1.4 (http://www.freeirt.org)
* ghquadm (findit ghquadm)
* gllamm version 2.3.20 (ssc describe gllamm)
* gllapred version  2.3.8 (ssc describe gllapred)
* elapse (ssc describe elapse)
*
* Jean-benoit Hardouin - Department of Biomathematics and Biostatistics - University of Nantes - France
* EA 4275 "Biostatistics, Clinical Research and Subjective Measures in Health Sciences"
* jean-benoit.hardouin@univ-nantes.fr
*
* News about this program : http://www.anaqol.org
* FreeIRT Project : http://www.freeirt.org
*
* Copyright 2003-2013 Jean-Benoit Hardouin
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
DEFINITION / SYNTAX
***********************************************************************************************************/


program define raschtestv7,rclass
syntax varlist(min=1 numeric) [if] [in] , ID(varname) [HTML(string) MEANdiff DIRsave(string) FILESsave nodraw PAUse REPlace ICC INFormation SPLITtests FITgraph Method(string) group(numlist >0 ascen) AUTOGroup Test(string) q2 GENLT(string) GENSCOre(string) GENFIT(string) GENRES(string) GRAph v8 COMp(varname) dif(varlist) time TRace Details  nold iterate(int 200) DIFFiculties(string) COVariates(string)]

local covariables `covariates'

if "`if'"=="" {
   local if "if 1"
}

/***********************************************************************************************************
INTRODUCTION
***********************************************************************************************************/

if "`trace'"!="" {
  di in green "*** Tests of conformity"
}
if "`v8'"=="" {
        version 7.0
}
else {
        version 8.0
}
if "`html'"!="" {
   set scheme sj
   local htmlregion  "graphregion(fcolor(white) ifcolor(white))"
   local draw
}

local st = "$S_TIME"
local nbitems : word count `varlist'
marksample touse ,novarlist
if "`covariables'"!="" {
   tokenize "`covariables'",parse(" ,")
   local i=1
   local tcovariables
   while "``i''"!=","&"``i''"!="" {
     local covariable`i' ``i''
     local tcovariables `tcovariables' ``i''
     local ++i
   }
   local nbcovariables=`i'-1
   local ss1
   local ss3
   if "``i''"=="," {
      forvalues j=`=`i'+1'/`=`i'+2' {
         if "``j''"=="ss1" {
            local ss1 ss1
         }
         else if "``j''"=="ss3" {
            local ss3 ss3
         }
         else if "``j''"=="" {
*            di in green "option `j' vide"
         }
         else {
            di in red "Invalid option in the {hi:covariables} option"
            error 198
         }
      }
      local i=`i'+3
      if "``i''"!="" {
         di in red "There is too much options in the {hi:covariates} option."
         error 198
      }
   }
   local covariables `tcovariables'
}
else {
   local nbcovariables=0
}

isid `id'
tokenize `varlist'

local bad
forvalues i=1/`nbitems' {
   qui count if ``i''!=0&``i''!=1&``i''!=.
   local N=r(N)
   if `N'>0 {
      local bad `bad' ``i''
   }
}
if "`bad'"!="" {
   di in red "The item(s) {hi:`bad'} is(are) not binary item(s) (with responses 0 or 1)."
   exit
}



if "`method'"=="" {
    local method cml
}
if "`test'"=="" {
    local test R
}
local method=lower("`method'")
local test=upper("`test'")
if "`method'"!="mml"&"`method'"!="cml"&"`method'"!="gee" {
    di in red "Uncorrect method option."
    error 198
    exit
}

if "`test'"!="R"&"`test'"!="Q"&"`test'"!="WP"&"`test'"!="NONE" {
   di in red "Uncorrect test option."
   error 198
   exit
}

if "`genfit'"!="" {
   local nbwordgenfit:word count `genfit'
   if `nbwordgenfit'!=2 {
      di in red "Uncorrect genfit option."
      di in red "This option must contain exactly two words"
      error 198
      exit
   }
}


if "`genfit'"!=""|"`genlt'"!=""|"`genscore'"!=""|"`genres'"!="" {
   capture confirm new variable `genfit' `genscore' `genres'
   if "`genfit'"!="" {
      local o:word 1 of `genfit'
      forvalues i=1/`nbitems' {
         confirm new variable `o'``i''
      }
   }
   if "`genlt'"!="" {
       local 0 `genlt'
       gettoken left  0: 0,parse(",")
       gettoken right  0: 0,parse(",")
       local genlt `left'
       local replacegenlt `0'
       local length=length("`replacegenlt'")
       if `length'>=3&substr("`replacegenlt'",1,`length')==substr("replace",1,`length') {
          local replacegenlt replace
       }
       if "`replacegenlt'"!="replace"&"`replacegenlt'"!="" {
           di "Not allowed option in the {hi:genlt} option"
           error 198
       }
       else if "`replacegenlt'"=="" {
           confirm new variable `genlt'
       }
   }
}

preserve

tempfile saveraschtest
qui save `saveraschtest'
qui keep if `touse'==1

if "`autogroup'"!=""&"`group'"!="" {
   di in green "The autogroup and the group options cannot be defined in the same time"
   di in green "Only the group option is retained."
   local autogroup
}

if "`autogroup'"!="" {
   tempvar autoscore
   qui genscore `varlist',score(`autoscore')

   tempname matscore tmp
   matrix `matscore'=J(`=`nbitems'-1',3,0)
   forvalues i=1/`=`nbitems'-1' {
        matrix `matscore'[`i',1]=`i'
        matrix `matscore'[`i',2]=`i'
        qui count if `autoscore'==`i'
        matrix `matscore'[`i',3]=r(N)
   }
   local stop=0
   local j=0
   while `j'<=`=`nbitems'-3'&`stop'!=1 {
      local j=`j'+1
      local scoretogroup=99999999
      local rowtogroup1=0
      local rowtogroup2=0
      local stop=1
      forvalues i=1/`=`nbitems'-`j'' {
         if `matscore'[`i',1]>=0 & `matscore'[`i',3]<30 & `matscore'[`i',3]<`scoretogroup' {
            local scoretogroup=`matscore'[`i',3]
            local rowtogroup1=`i'
            local stop=0
         }
      }
      if `stop'!=1 {
         if `rowtogroup1'>1&`rowtogroup1'<`=`nbitems'-`j'' {
            if `matscore'[`=`rowtogroup1'-1',1]<`matscore'[`=`rowtogroup1'+1',1] {
               local rowtogroup2=`rowtogroup1'
               local rowtogroup1=`rowtogroup1'-1
            }
            else {
               local rowtogroup2=`rowtogroup1'+1
            }
         }
         else if `rowtogroup1'==1 {
            local rowtogroup2=2
         }
         else if `rowtogroup1'==`=`nbitems'-`j'' {
            local rowtogroup2=`nbitems'-`j'
            local rowtogroup1=`nbitems'-`j'-1
         }
         matrix `tmp'=`matscore'
         matrix `matscore'=J(`=`nbitems'-`j'',3,0)
         if `rowtogroup1'!=1 {
            matrix `matscore'[1,1]=`tmp'[1..`=`rowtogroup1'-1',1..3]
         }
         matrix `matscore'[`rowtogroup1',1]=`tmp'[`rowtogroup1',1]
         matrix `matscore'[`rowtogroup1',2]=`tmp'[`rowtogroup2',2]
         matrix `matscore'[`rowtogroup1',3]=`tmp'[`rowtogroup1',3]+`tmp'[`rowtogroup2',3]
         if `rowtogroup2'!=`=`nbitems'-`j'' {
            matrix `matscore'[`rowtogroup2',1]=`tmp'[`=`rowtogroup2'+1'..`=`nbitems'-`j'',1..3]
         }
      }
   }
   local nbrows=rowsof(`matscore')-1
   local thresholds
   forvalues i=1/`nbrows' {
      local tmp=`matscore'[`i',2]
      local thresholds `thresholds' `tmp'
   }
   local group `thresholds'
}


if "`group'"=="" {
	forvalues i=1/`=`nbitems'-1' {
		local group "`group' `i'"
	}
}
local nbgroups:word count `group'
local groupmax:word `nbgroups' of `group'
if `groupmax'>=`nbitems' {
	di in red "You cannot form a group with the higher possible score."
	di in red "The higher possible value of the group option is `=`nbitems'-1'."
        di in red "Please correct your group option."
	error 198
        exit
}
else {
	if `groupmax'!=`=`nbitems'-1' {
		local group "`group' `=`nbitems'-1'"
		local nbgroups=`nbgroups'+1
	}
}
local nbgroups=`nbgroups'+1

if "`dirsave'"!=""&"`filessave'"=="" {
        di in ye "If you want to save yours graphs, use the filessave option"
}
if "`filessave'"!="" {
        if "`dirsave'"=="" {
              local dirsave "`c(pwd)'"
        }
        di in ye "The graphs files will be saved in `dirsave'"
}
if "`dirsave'"!="" {
        if "`filesave'"=="" {
              local filesave "filesave"
        }
}


if "`pause'"!=""&"`draw'"=="" {
     pause on
}

if "`difficulties'"!="" {
    capture confirm matrix `difficulties'
    if _rc!=0  {
	di in red "The vector `difficulties' defined in the {hi:difficulties} option does not exist."
	error 198
        exit
    }
}

if "`difficulties'"!=""&"`method'"!="mml" {
   di in red "The {hi:difficulties} option can be defined only for MML method."
   error 198
   exit
}

if "`covariables'"!=""&"`method'"!="mml" {
   di in red "The {hi:covariables} option can be defined only for MML method."
   error 198
   exit
}
if "`covariables'"!=""&"`comp'"!="" {
   di in red "The {hi:covariables} and {hi:comp} options can be defined jointly."
   error 198
   exit
}





/***********************************************************************************************************
POSSIBLE TEST
***********************************************************************************************************/

if ("`icc'"!=""|"`fitgraph'"!=""|"`splittest'"!=""|"`details'"!="")&"`test'"=="NONE" {
	di in green "You cannot use the {hi:details}, {hi:icc}, {hi:fitgraph} or {hi:splittest} options if you use {hi:test(none)}."
        di in green "These options are ignored."
	local details
	local icc
	local fitgraph
	local splittest
}
if "`comp'"!=""&"`method'"=="cml" {
   	di in green "You cannot compare two populations ({hi:comp} option) with the CML estimation method"
   	di in green "This option is ignored."
        local comp
}
if "`method'"!="cml"&"`test'"=="WP" {
	di in green "The Wright-Panchapakesan test is not authorized with MML or GEE."
	di in green "The WP tests are replaced by Van den Wollenberg Q tests."
        local test Q
}
if "`method'"=="gee"&"`ld'"!="" {
	di in green "You cannot use the {hi:nold} option with the GEE method of estimation"
	di in green "This option is ignored."
        local ld
}


if "`test'"==""|"`test'"=="R" {
   local test "R"
   if "`method'"=="cml" {
      local namewp "R1c"
      local descwp "R1c test"
   }
   else {
      local namewp="R1m"
      local descwp "R1m test"
   }
}
if `nbitems'>999999|"`test'"=="WP" {
	local namewp "  Y"
	local descwp "Wright-Panchapakesan Y test"
	local q2
}
 else if "`test'"=="Q" {
	local namewp " Q1"
	local descwp "Van den Wollenberg Q1 test"
}

if "`method'"!="cml"&"`meandiff'"!="" {
	di in green "The {hi:meandiff} option is not available with MML or GEE."
	di in green "This option is ignored."
        local meandiff
}

if "`method'"!="cml"&"`splittests'"!="" {
	di in green "The {hi:splittests} option is not available with MML or GEE."
	di in green "This option is ignored."
        local splittests
}
if "`method'"!="cml"&"`dif'"!="" {
	di in green "The {hi:dif} option is not available with MML or GEE."
	di in green "This option is ignored."
        local dif
}

/***********************************************************************************************************
SCORES AND GROUPS
************************************************************************************************************/

qui count if `touse'==1
local N=r(N)

qui keep `varlist' `comp' `covariables' `id' `touse'

tempname rep item
tempvar score realscore
qui genscore `varlist',score(`score')
qui count if `score'==.&`touse'==1
local nbindmiss=r(N)

if "`ld'"=="" {
   qui drop if `score'==.
}
forvalues i=1/`nbitems' {
	rename ``i'' `rep'`i'
}



local liminf0=0
local limsup0=0
local liminf`nbgroups'=`nbitems'
local limsup`nbgroups'=`nbitems'


local recode
forvalues i=1/`=`nbgroups'-1' {
	if `i'!= 1{
		local liminf`i' : word `=`i'-1' of `group'
	}
	else {
		local liminf1=0
	}
	local liminf`i'=`liminf`i''+1
	local limsup`i':word `i' of `group'

	local recode "`recode' `liminf`i''/`limsup`i''=`i'"
}
qui gen `realscore'=`score'
qui recode `score' `recode' `nbitems'=`nbgroups'

local smallgroup=0

forvalues i=0/`nbgroups' {
	qui count if `score'==`i'
	local effscore`i'=r(N)
	if `i'!=0&`i'!=`nbgroups'&`effscore`i''<30 {
		local smallgroup=1
	}
}
/***********************************************************************************************************
ESTIMATION OF THE DIFFICULTY PARAMETERS
************************************************************************************************************/
if "`trace'"!="" {
  di in green "*** Estimation of the difficulty parameters"
}


if "`covariables'"!=""&"`difficulties'"=="" {
  forvalues i=1/`nbcovariables' {
     qui su `covariable`i''
     local mean`covariable`i''=r(mean)
     qui replace `covariable`i''=`covariable`i''-`mean`covariable`i'''
  }
}

tempname ll coef var beta Vbeta est

if "`method'"=="gee" {
   qui geekel2d `rep'1-`rep'`nbitems',ll
   local nbobserv=r(N)

   if `r(error)'==1 {
       di "The variance of the latent trait probably is too high to made the GEE a efficient method to estimate the parameters."
       error 499
       exit
   }
   scalar `ll'=r(ll)
   local nbind=r(N)
   matrix `coef'=r(b)
   matrix `est'=`coef'
   matrix `est'[1,`=`nbitems'+1']=sqrt(`est'[1,`=`nbitems'+1'])
   matrix `var'=r(V)
   matrix `beta'=`coef'[1,1..`nbitems']
   matrix `Vbeta'=`var'[1..`nbitems',1..`nbitems']
   local sig=sqrt(`coef'[1,`=`nbitems'+1'])
   local sesig=sqrt(`var'[`=`nbitems'+1',`=`nbitems'+1'])/sqrt(`nbind')/(`sig'*2)
}

qui reshape long `rep', i(`id') j(`item')

tempvar diff tl
gen `diff'=0

forvalues i=1/`nbitems' {
	qui gen `rep'`i'=`item'==`i'
	qui replace `rep'`i'=-`rep'`i'
}


if "`method'"=="mml" {
   if "`difficulties'"==""{
      qui xtlogit `rep' `rep'1-`rep'`nbitems' `covariables', i(`id') nocons iterate(`iterate')
      matrix `est'=e(b)
      matrix `est'[1,`=`nbitems'+`nbcovariables'+1']=exp(`est'[1,`=`nbitems'+`nbcovariables'+1']/2)
   }
   else {
      tempname offset b
      qui gen `offset'=0
      forvalues i=1/`nbitems' {
          qui replace `offset'=-(`difficulties'[1,`i']) if `item'==`i'
      }
      qui gllamm `rep' `covariables'  , offset(`offset') i(`id') nocons iterate(`iterate') link(logit) fam(bin)
      matrix `b'=e(b)
      matrix `est'=`difficulties',`b'
      matrix `est'[1,`=`nbitems'+`nbcovariables'+1']=exp(`b'[1,`=`nbcovariables'+1']/2)
   }
}
else if "`method'"=="cml" {
	qui clogit `rep' `rep'1-`rep'`=`nbitems'-1' , group(`id')
}


if "`method'"!="gee" {
   if "`difficulties'"=="" {
      matrix `coef'=e(b)
      matrix `var'=e(V)
   }
   else {
      matrix `coef'=`difficulties'
      matrix `var'=J(`=`nbitems'+`nbcovariables'+1',`=`nbitems'+`nbcovariables'+1',.)
      matrix `var'[`=`nbitems'+1',`=`nbitems'+1']=e(V)
   }
   scalar `ll'=e(ll)
   local nbind=e(N)/`nbitems'
   local nbobserv=e(N)
   *di "nombre d'obs:`nbobserv'"

   if "`meandiff'"!="" {
      matrix `var'=J(`nbitems',`nbitems',.)
      matrix `coef'=J(1,`nbitems',.)
      local param
      local lin `rep'1
      forvalues j=2/`=`nbitems'-1' {
         local lin `lin'+`rep'`j'
      }
      local lin (`lin')/`nbitems'

      forvalues j=1/`=`nbitems'-1' {
         qui lincom `rep'`j'-`lin'
         matrix `coef'[1,`j']=`r(estimate)'
         matrix `var'[`j',`j']=`r(se)'^2
      }
      qui lincom -`lin'
      matrix `coef'[1,`nbitems']=`r(estimate)'
      matrix `var'[`nbitems',`nbitems']=`r(se)'^2
   }
   if "`method'"=="mml" {
	local sig=e(sigma_u)
	local sesig=sqrt(`var'[`=`nbitems'+`nbcovariables'+1',`=`nbitems'+`nbcovariables'+1'])*`sig'/2
        tempname betacov Vbetacov
	if "`difficulties'"=="" {
           matrix `beta'=`coef'[1,1..`nbitems']
           matrix `Vbeta'=`var'[1..`nbitems',1..`nbitems']
           if "`covariables'"!="" {
              matrix `betacov'=`coef'[1,`=`nbitems'+1'..`=`nbitems'+`nbcovariables'']
              matrix `Vbetacov'=`var'[`=`nbitems'+1'..`=`nbitems'+`nbcovariables'',`=`nbitems'+1'..`=`nbitems'+`nbcovariables'']
           }
           local sig=e(sigma_u)
	   local sesig=sqrt(`var'[`=`nbitems'+`nbcovariables'+1',`=`nbitems'+`nbcovariables'+1'])*`sig'/2
	}
	else {
	   tempname tmp
	   matrix `tmp'=e(b)
           matrix `beta'=`difficulties'
           if "`covariables'"!="" {
              matrix `betacov'=`tmp'[1,1..`nbcovariables']
           }
           local sig=`tmp'[1,`=`nbcovariables'+1']
           matrix `tmp'=e(V)
	   local sesig=sqrt(`tmp'[`=`nbcovariables'+1',`=`nbcovariables'+1'])
           matrix `Vbeta'=J(`nbitems',`nbitems',.)
           if "`covariables'"!="" {
              matrix `Vbetacov'=`tmp'[1..`nbcovariables',1..`nbcovariables']
           }
	}
   }
   else if "`method'"=="cml"&"`meandiff'"==""{
	matrix `beta'=`coef'[1,1..`=`nbitems'-1']
	matrix `Vbeta'=`var'[1..`=`nbitems'-1',1..`=`nbitems'-1']
   }
   else if "`method'"=="cml"&"`meandiff'"!=""{
	matrix `beta'=`coef'
	matrix `Vbeta'=`var'
   }
}

if ("`method'"=="mml"|"`method'"=="gee") {
   local colnames
   forvalues i=1/`nbitems' {
      local colnames "`colnames' `rep':`rep'`i'"
   }
   forvalues i=1/`nbcovariables'{
      local tmp:word `i' of `covariables'
      local colnames "`colnames' `rep':`tmp'"
   }
   local id2=substr("`id'",1,4)
   local colnames "`colnames' `id2'1:_cons"
   matrix colnames `est'=`colnames'

   qui gllamm `rep' `rep'1-`rep'`nbitems' `covariables', i(`id') allc nocons family(binom) link(logit) trace from(`est') eval
   tempname u
   qui gllapred `u',u fsample

   forvalues i=1/`nbcovariables' {
      local tmp:word `i' of `covariables'
      qui replace `u'm1=`u'm1+`betacov'[1,`i']*(`tmp')/*+`mean`covariable`i''')*/
   }
   tempname theta sdtheta
   matrix `theta'=J(1,`=`nbitems'+1',0)
   matrix `sdtheta'=J(`=`nbitems'+1',`=`nbitems'+1',0)
   qui su `u'm1 if `rep'1==-1
   local vartheta=r(Var)
   qui gen `u's2=`u's1^2
   qui su `u's2 if `rep'1==-1
   local meanse2=r(mean)
   local psi=1-`meanse2'/(`meanse2'+`vartheta')
   forvalues s=0/`nbitems' {
      qui su `u'm1 if `realscore'==`s'
      local theta`s'=r(mean)
      qui su `u's1 if `realscore'==`s'
      local sdtheta`s'=r(mean)
      matrix `theta'[1,`=`s'+1']=`theta`s''
      matrix `sdtheta'[`=`s'+1',`=`s'+1']=`sdtheta`s''
   }
   if "`genlt'"!="" {
      tempfile ltsave ltsavetmp
      qui save `ltsavetmp', replace
      qui keep if `rep'1==-1
      qui keep `u'm1 `u's1 `id'
      qui sort `id'
      qui save `ltsave'
      qui use `ltsavetmp'
   }
}

forvalues i=1/`nbitems' {
	if `i'==`nbitems'&"`method'"=="cml"&"`meandiff'"=="" {
		local beta`i'=0
		local sd`i' .
		local fixed`i' "*"
	}
	else {
		local beta`i'=`coef'[1,`i']
		local sd`i'=sqrt(`var'[`i',`i'])
	}
	qui replace `diff'=-`beta`i'' if `item'==`i'
}

/***********************************************************************************************************
COMPARISON OF TWO POPULATIONS
***********************************************************************************************************/

if "`comp'"!=""&"`method'"!="cml" {
   if "`trace'"!="" {
     di in green "*** Test of comparison of two populations"
   }
         qui inspect `comp'
         local unique=r(N_unique)
         if `unique'== 2 {
		qui su `comp'
		local mincomp=r(min)
		local maxcomp=r(max)
	    	tempname bmin bmax
	    	qui xtlogit `rep' if `comp'==`mincomp',offset(`diff') i(`id')
	    	matrix `bmin'=e(b)
	    	local meanmin=`bmin'[1,1]
	    	local varmin=e(sigma_u)^2
	    	local llmin=e(ll)
	    	local Nmin=e(N_g)
	    	qui xtlogit `rep' if `comp'==`maxcomp',offset(`diff') i(`id')
	    	matrix `bmax'=e(b)
	    	local meanmax=`bmax'[1,1]
	    	local varmax=e(sigma_u)^2
	    	local llmax=e(ll)
	    	local Nmax=e(N_g)
	    	local Zcomp=(`meanmin'-`meanmax')/sqrt(`varmin'/`Nmin'+`varmax'/`Nmax')
		local pvalue=1-norm(abs(`Zcomp'))
	 }
	 else {
	        di "It is impossible to compare more than two populations"
	        di "The comparison process is not run"
	        local comp
	 }
}

/***********************************************************************************************************
ESTIMATION OF THE ABILITY PARAMETERS  / CML
************************************************************************************************************/
if `nbitems'>=2 {
   if "`trace'"!="" {
      di in green "*** Estimation of the ability parameters"
   }
   if "`method'"=="cml" {
      tempfile verytmp
      qui save `verytmp',replace
      drop _all
      qui set obs 20001
      qui gen theta=(_n-10001)/1000
      qui gen A=1
      forvalues j=1/`nbitems' {
         qui gen u`j'=exp(theta-`beta`j'')
         qui gen p`j'=u`j'/(1+u`j')
         qui gen a`j'=1/u`j'
         qui replace A=A*a`j'
         qui gen i`j'=u`j'/(1+u`j')^2
         qui gen j`j'=(u`j'*(1-u`j'))/(1+u`j')^3
      }
      qui egen P=rsum(p*)
      qui egen I=rsum(i*)
      qui egen J=rsum(j*)
      qui gen V=1/I^2*(I+J^2)/(4*I^2)
      qui gen V2=1/I
      tempname theta sdtheta
      matrix `theta'=J(1,`=`nbitems'+1',0)
      matrix `sdtheta'=J(`=`nbitems'+1',`=`nbitems'+1',.)
      forvalues s=0/`nbitems' {
         qui gen f`s'=abs(`s'-P+.5*J/I)
         qui sort f`s'
         matrix `theta'[1,`=`s'+1']=theta[1]
         matrix `sdtheta'[`=`s'+1',`=`s'+1']=sqrt(V2[1])
      }
      use "`verytmp'",replace
   }
   qui gen `tl'=0
   forvalues s=0/`nbitems' {
      local theta`s'=`theta'[1,`=`s'+1']
      qui replace `tl'=`theta`s'' if `realscore'==`s'
      local sdtheta`s'=`sdtheta'[`=`s'+1',`= `s'+1']
   }
   tempname pred
   qui gen `pred'=log(exp(`rep'*(`tl'+`diff'))/(1+exp(`tl'+`diff')))

   qui su `pred'
   local globalll=r(sum)

   local nulscore=0
   forvalues i=0/`nbgroups' {
      qui count if `score'==`i'&`item'==1
      local nbscore`i'=r(N)
      if `nbscore`i''==0 {
         local nulscore=1
      }
   }
   if `nulscore' {
      di in green "{p}At least one group of scores concerns none individuals. Tests will be not computed.{p_end}"
      di in green "{p}Use the {hi:group} or the {hi:autogroup} options.{p_end}"
      local test "NONE"
      local details
      local icc
      local fitgraph
      local splittest
   }
   forvalues i=0/`nbitems' {
      qui count if `realscore'==`i'&`item'==1
      local nbrealscore`i'=r(N)
   }
}

/***********************************************************************************************************
TESTS OF THE FIRST ORDER
************************************************************************************************************/

tempname Pi
matrix define `Pi'=J(`nbitems',`=`nbitems'-1',0)
if "`test'"!="NONE" {
   qui drop if `score'==.
   if "`trace'"!="" {
      di in green "*** Tests of the first order"
   }
   tempname Obs Obs2 Th Th2

   matrix define `Obs'=J(`nbitems',`=`nbitems'-1',0)
   matrix define `Obs2'=J(`nbitems',`=`nbgroups'-1',0)
   matrix define `Th'=J(`nbitems',`=`nbitems'-1',0)
   matrix define `Th2'=J(`nbitems',`=`nbgroups'-1',0)
   local listofitemsc

   /* Estimation of the gamma symetrical functions*/
   local c0 "1"
   local c`nbitems' "`nbitems'*x"
   forvalues j=1/`nbitems' {
      local listini`j'
      local listofitemsc "`listofitemsc' `beta`j''"
      local c0 `c0'*(1+exp(x-`beta`j''))
      local c`nbitems' `c`nbitems''-`beta`j''
      forvalues k=1/`nbitems' {
         local listini`j'k`k'
         if `k'!=`j' {
            local listini`j' "`listini`j'' `beta`k''"
         }
         forvalues l=1/`nbitems' {
            if `l'!=`j'&`l'!=`k' {
               local listini`j'k`k' "`listini`j'k`k'' `beta`l''"
            }
         }
      }
   }

   gammasym `listofitemsc'

   /*Estimation, for each value of the score s of the probability to respond to each item (Pi) and of the theorical number of positive responses (Ths) and of theorical number of positive respond per item pair (Ws)*/
   forvalues s=1/`nbitems' {
      local denom`s'=r(gamma`s')
      tempname  W`s'
      matrix define `W`s''=J(`nbitems',`nbitems',0)
   }
   tempvar prob prob2 z y v z2 y2 v2 c r q e
   qui gen `prob'=.
   qui gen `prob2'=.
   forvalues j=1/`nbitems' {
      forvalues s=1/`=`nbitems'-1' {
         qui count if `rep'==1&`item'==`j'&`realscore'==`s'
         matrix `Obs'[`j',`s']=r(N)
         if "`test'"!="WP" {
            gammasym `listini`j''
            local num`j'=r(gamma`=`s'-1')
            if "`method'"=="cml"|"`test'"=="Q" {
               matrix `Pi'[`j',`s']=exp(-`beta`j'')*`num`j''/`denom`s''
            }
            else {
               gausshermite exp(`s'*x)/(`c0'), sigma(`sig')
               local int`s'=r(int)
               if "`test'"=="R"&`nbrealscore`s''!=0{
                  local tmp=exp(-`beta`j'')*`num`j''*`int`s''*`nbind'/`nbrealscore`s''
                  matrix `Pi'[`j',`s']=`tmp'
               }
               else if `nbrealscore`s''==0 {
                  matrix `Pi'[`j',`s']=0
               }
            }
            if "`test'"=="R" {
               forvalues k=`=`j'+1'/`nbitems' {
                  if `s'>=2 {
                     gammasym `listini`j'k`k''
                     local num`j'k`k'=r(gamma`=`s'-2')
                     if "`method'"=="cml" {
                        matrix `W`s''[`j',`k']=`nbrealscore`s''*exp(-`beta`j'')*exp(-`beta`k'')*`num`j'k`k''/`denom`s''
                     }
                     else {
                        matrix `W`s''[`j',`k']=exp(-`beta`j'')*exp(-`beta`k'')*`num`j'k`k''*`int`s''*`nbind'
                     }
                     matrix `W`s''[`k',`j']=`W`s''[`j',`k']
                  }
               }
            }
         }
         else if "`test'"=="WP" {
            matrix `Pi'[`j',`s']=exp(`theta`s''-`beta`j'')/(1+exp(`theta`s''-`beta`j''))
         }
         matrix `Th'[`j',`s']=`Pi'[`j',`s']*`nbrealscore`s''
         qui replace `prob'=`Pi'[`j',`s'] if `realscore'==`s'&`item'==`j'
         qui replace `prob2'=exp(`theta`s''-`beta`j'')/(1+exp(`theta`s''-`beta`j'')) if `realscore'==`s'&`item'==`j'
         matrix `W`s''[`j',`j']=`nbrealscore`s''*`Pi'[`j',`s']
         if "`test'"!="R" {
            matrix `W`s''[`j',`j']=`W`s''[`j',`j']*abs(1-`Pi'[`j',`s'])
         }
      }
   }
   qui gen `v2'=abs(`prob'*(1-`prob'))
   qui gen `z2'=(`rep'-`prob')^2
   qui gen `y2'=`z2'/`v2'
   qui gen `c'=abs(`prob'*(1-`prob')*(`prob'^3+(1-`prob')^3))
   qui gen `r'=`c'/(`v2')^2
   qui gen `e'=`c'-(`v2')^2

   forvalues j=1/`nbitems' {
      qui su `y2' if `item'==`j'
      local outfit`j'=r(mean)
      qui su `r' if `item'==`j'
      local Voutfit`j'=r(sum)
      local Voutfit`j'=`Voutfit`j''/(`nbind')^2-1/`nbind'
      local outfitstd`j'=(`outfit`j''^(1/3)-1)*(3/sqrt(`Voutfit`j''))-sqrt(`Voutfit`j'')/3

      qui su `z2' if `item'==`j'
      local n=r(sum)
      qui su `v2' if `item'==`j'
      local d=r(sum)
      local infit`j'=`n'/`d'
      qui su `e' if `item'==`j'
      local sume=r(sum)
      local Vinfit`j'=`sume'/(`d')^2
      local infitstd`j'=(`infit`j''^(1/3)-1)*(3/sqrt(`Vinfit`j''))-sqrt(`Vinfit`j'')/3
   }
   tempname tmp stattest testitems

   /*Estimation, by scores group g, of the theorical number of positive response (Th2g) and of the positive respond to each items pair (W2g)*/
   scalar `stattest'=0
   forvalues g=1/`=`nbgroups'-1' {
      tempname  W2`g' d2`g'
      matrix define `W2`g''=J(`nbitems',`nbitems',0)
      forvalues s=`liminf`g''/`limsup`g'' {
         forvalues j=1/`nbitems' {
            matrix `Obs2'[`j',`g']=`Obs2'[`j',`g']+`Obs'[`j',`s']
            matrix `Th2'[`j',`g']=`Th2'[`j',`g']+`Th'[`j',`s']
            if "`test'"=="R" {
               forvalues k=`=`j'+1'/`nbitems' {
                  matrix `W2`g''[`j',`k']=`W2`g''[`j',`k']+`W`s''[`j',`k']
                  matrix `W2`g''[`k',`j']=`W2`g''[`j',`k']
               }
            }
            matrix `W2`g''[`j',`j']=`W2`g''[`j',`j']+`W`s''[`j',`j']
         }
      }

      /*Estimation of the d2g vectors*/
      matrix `d2`g''=`Obs2'[1..`nbitems',`g']-`Th2'[1..`nbitems',`g']

      /*Estimation of the influences on the test of each item (testitemsg matrix) and of the test statistic (stattest)*/
      tempname test`g' testitems`g'
      matrix `test`g''=`d2`g'''*syminv(`W2`g'')*`d2`g''
      capture matrix `testitems`g''=cholesky(syminv(`W2`g''))*`d2`g''
      if _rc!=0 {
         matrix `tmp'=J(`nbitems',`nbitems',0)
         forvalues j=1/`nbitems' {
            matrix `tmp'[`j',`j']=`W2`g''[`j',`j']
         }
         di in green "Group `g' (`liminf`g''/`limsup`g''): The weight matrix is not positive-definite, the diagonal matrix is used to estimate the contribution of the items on the `wpname' statistic"
         matrix list `tmp'
         matrix `testitems`g''=cholesky(syminv(`tmp'))*`d2`g''
      }
      else {
         matrix `testitems`g''=cholesky(syminv(`W2`g''))*`d2`g''
      }
      scalar `stattest'=`stattest'+`test`g''[1,1]
   }
   matrix `testitems'=J(`nbitems',1,0)
   forvalues j=1/`nbitems' {
      forvalues g=1/`=`nbgroups'-1' {
         matrix `testitems'[`j',1]=`testitems'[`j',1]+`testitems`g''[`j',1]^2
      }
   }

   /*Adaptation for the Q1 statistic*/
   if "`test'"=="Q" {
      scalar `stattest'=`stattest'*`=`nbitems'-1'/`nbitems'
   }

   /*Correction for R1m and Q1m*/
   if ("`test'"=="R"|"`test'"=="Q")&("`method'"=="mml"|"`method'"=="gee") {
      local c`nbitems' exp(`c`nbitems'')/(`c0')
      local c0 1/(`c0')
      gausshermite `c0', sigma(`sig')
      local ci0=r(int)*`nbind'
      gausshermite `c`nbitems'',sigma(`sig')
      local ci`nbitems'=`nbind'*r(int)
      scalar `stattest'=`stattest'+(`nbrealscore0'-`ci0')^2/`ci0'+(`nbrealscore`nbitems''-`ci`nbitems'')^2/`ci`nbitems''
  }



/***********************************************************************************************************
TESTS U
************************************************************************************************************/

   if "`method'"=="cml" {
      if "`trace'"!="" {
         di in green "*** Tests U"
      }

      local quartile=`nbind'/4
      local c1=0
      local n1=0
      while `n1'<`quartile' {
         local c1=`c1'+1
         local n1=`n1'+`nbrealscore`c1''
      }
      local c2=`nbitems'
      local n2=0
      while `n2'<`quartile' {
         local c2=`c2'-1
         local n2=`n2'+`nbrealscore`c2''
      }
      forvalues j=1/`nbitems' {
         local zu1=0
         local zu2=0
         forvalues s=1/`c1' {
            local zu1=`zu1'+`nbrealscore`s''*(`Obs'[`j',`s']/`nbrealscore`s''-`Pi'[`j',`s'])/sqrt(`nbrealscore`s''*`Pi'[`j',`s']*(1-`Pi'[`j',`s']))
         }
         forvalues s=`c2'/`=`nbitems'-1' {
            local zu2=`zu2'+`nbrealscore`s''*(`Obs'[`j',`s']/`nbrealscore`s''-`Pi'[`j',`s'])/sqrt(`nbrealscore`s''*`Pi'[`j',`s']*(1-`Pi'[`j',`s']))
         }
         local U`j'=(`zu1'-`zu2')/sqrt(`c1'+`nbitems'-`c2')
      }
   }



/***********************************************************************************************************
TESTS OF THE SECOND ORDER /*undocumented in beta test*/
************************************************************************************************************/

   if "`q2'"!="" {
      if "`trace'"!="" {
         di in green "*** Tests of the second order"
      }

      tempfile Q2file
      qui save "`Q2file'",replace
      qui use "`saveraschtest'",replace

      qui keep if `touse'==1
      gen `score'=0

      forvalues i=1/`nbitems' {
         local Q2i`i'
	 rename ``i'' `rep'`i'
	 qui replace `score'=`score'+`rep'`i'
      }
      qui recode `score' `recode'

      forvalues i=1/`nbitems' {
         local Q2i`i'=0
         forvalues j=`=`i'+1'/`nbitems' {
	    local listinci`i'j`j'
	    forvalues k=1/`nbitems' {
	       if `k'!=`i'&`k'!=`j' {
	          local listinci`i'j`j' "`listinci`i'j`j'' `beta`k''"
	       }
	    }
	 }
      }

      local Q2tot=0
      forvalues k=2/`=`nbitems'-1' {
         forvalues i=1/`=`nbitems'-1' {
	    forvalues j=`=`i'+1'/`nbitems' {
	       if `k'==1 {
	          local num=0
               }
	       else {
	          gammasym `listinci`i'j`j''
                  local num=r(gamma`=`k'-2')
               }
	       local athi`i'j`j'k`k'=exp(-`beta`i'')*exp(-`beta`j'')*`num'/`denom`k''
	       local bthi`i'j`j'k`k'=`nbth`i's`k''-`athi`i'j`j'k`k''
	       local cthi`i'j`j'k`k'=`nbth`j's`k''-`athi`i'j`j'k`k''
	       local dthi`i'j`j'k`k'=1-`athi`i'j`j'k`k''-`bthi`i'j`j'k`k''-`cthi`i'j`j'k`k''
            }
         }
      }
      forvalues k=1/`=`nbgroups'-1' {
         local Q2`k'=0
         forvalues i=1/`=`nbitems'-1' {
	    forvalues j=`=`j'+1'/`nbitems' {
	       qui count if  `rep'`i'==1&`rep'`j'==1&`score'==`k'
	       local aempi`i'j`j'k`k'=r(N)
	       local ath2i`i'j`j'k`k'=0
	       local bth2i`i'j`j'k`k'=0
	       local cth2i`i'j`j'k`k'=0
	       local dth2i`i'j`j'k`k'=0
	    }
	 }
         if `limsup`k''!=1 {
            forvalues l=`liminf`k''/`limsup`k'' {
	       forvalues i=1/`=`nbitems'-1' {
	          forvalues j=`=`i'+1'/`nbitems' {
		     if `l'!=1 {
		        local ath2i`i'j`j'k`k'=`ath2i`i'j`j'k`k''+`athi`i'j`j'k`l''*`nbrealscore`l''
			local bth2i`i'j`j'k`k'=`bth2i`i'j`j'k`k''+`bthi`i'j`j'k`l''*`nbrealscore`l''
			local cth2i`i'j`j'k`k'=`cth2i`i'j`j'k`k''+`cthi`i'j`j'k`l''*`nbrealscore`l''
			local dth2i`i'j`j'k`k'=`dth2i`i'j`j'k`k''+`dthi`i'j`j'k`l''*`nbrealscore`l''
                     }
		  }
               }
            }
	    forvalues i=1/`=`nbitems'-1' {
	       forvalues j=`=`i'+1'/`nbitems' {
	          local d2i`i'j`j'k`k'=(`aempi`i'j`j'k`k''-`ath2i`i'j`j'k`k'')^2
		  local Q2i`i'j`j'k`k'=`d2i`i'j`j'k`k''/`ath2i`i'j`j'k`k''+`d2i`i'j`j'k`k''/`bth2i`i'j`j'k`k''+`d2i`i'j`j'k`k''/`cth2i`i'j`j'k`k''+`d2i`i'j`j'k`k''/`dth2i`i'j`j'k`k''
		  local Q2i`i'=`Q2i`i''+`Q2i`i'j`j'k`k''
		  local Q2i`j'=`Q2i`j''+`Q2i`i'j`j'k`k''
		  local Q2`k'=`Q2`k''+`Q2i`i'j`j'k`k''
	       }
	    }
	 }
         local Q2tot=`Q2tot'+`Q2`k''
      }
      forvalues i=1/`nbitems' {
         di in green "Item ``i'' : Q2 = `Q2i`i''"
      }
      local Q2=`Q2tot'*(`nbitems'-3)/(`nbitems'-1)
      di in green "Q2 = `Q2tot'"
      qui use "`Q2file'",replace
   }

/***********************************************************************************************************
TEST LR Z
************************************************************************************************************/

   if "`method'"=="cml" {
      if "`trace'"!="" {
         di in green "*** Tests LR of Andersen"
      }
      local ssll=0
      tempfile Zfile
      qui save "`Zfile'", replace
      qui use "`saveraschtest'",replace
      qui keep if `touse'==1
      gen `score'=0
      forvalues j=1/`nbitems' {
         qui replace `score'=`score'+``j''
      }
      qui recode `score' `recode' `nbitems'=`nbgroups'
      forvalues i=1/`=`nbgroups'-1' {
         if `effscore`i''>0 {
            qui raschtestv7 `varlist' if `score'==`i', test(NONE) `ld'  id(`id')
            local ll`i'=r(cll)
            local ssll=`ssll'+(`ll`i'')
         }
      }
      local Z=2*`ssll'-2*`ll'
      use "`Zfile'",replace
      tempname AndersenZ
      matrix define `AndersenZ'=(`Z',`=(`nbgroups'-2)*(`nbitems'-1)',1-chi2(`=(`nbitems'-1)*(`nbgroups'-2)',`Z'))
   }
}


/***********************************************************************************************************
DISPLAYING RESULTS WITH TESTS
************************************************************************************************************/
if "`html'" != "" {
	di "<!-- SphereCalc start of response -->"
}

if "`test'"!="NONE" {
   local conttest= "_c"
}
di
tempname itemfit globalfit
matrix `globalfit'=J(1,3,0)
if "`method'"=="cml" {
   if "`html'" == "" {
   	di in green "Estimation method: " in yellow  "Conditional maximum likelihood (CML)"
   }
   else {
   	di "<p>Estimation method: Conditional maximum likelihood (CML)</p>"
   }
   local nbtest=`nbgroups'-1
   local line=77
}
else if "`method'"=="mml"{
   if "`html'" == "" {
   	di in green "Estimation method: " in yellow  "Marginal maximum likelihood (MML)"
   }
   else {
   	di "<p>Estimation method: Marginal maximum likelihood (MML)</p>"
   }
   local nbtest=`nbgroups'+1
   local line=70
}
else if "`method'"=="gee" {
   di in green "Estimation method: " in yellow  "Generalized Estimating Equations (GEE)"
   local nbtest=`nbgroups'+1
   local line=70
}
if "`test'"=="NONE" {
   local line=35
}

if "`html'" == "" {
	di in green  "Number of items: " in yellow  `nbitems'
	di in green  "Number of groups: " in yellow  `=`nbgroups'+1' `conttest'
	if "`test'"!="NONE" {
   	   di in green " (" in yellow "`nbtest'" in green " of them are used to compute the statistics of test)"
	}
}
else {
	di "Number of items: " `nbitems' "<br>"
	di "Number of groups: " `=`nbgroups'+1' `conttest'
	if "`test'"!="NONE" {
   	   di "<i> (`nbtest' of them are used to compute the statistics of test)</i>"
	}
	di "<br>"
}
if "`method'"=="cml" {
   local nbind=`nbind'+`effscore0'+`effscore`nbgroups''
   local cont "_c"
   matrix `itemfit'=J(`nbitems',6,0)
}
else {
   local cont
   matrix `itemfit'=J(`nbitems',5,0)
}
local missing=`N'-`nbind'
if "`html'" == "" {
	di in green "Number of individuals: " in yellow `N'
	di in green "Number of individuals with missing values: " in yellow `nbindmiss' _c
	if "`ld'"=="" {
   		di in green " (removed)"
	}
	else {
   		di
	}
	di in green  "Number of individuals with nul or perfect score: " in yellow `=`effscore0'+`effscore`nbgroups'''
}
else {
	di "Number of individuals: `N'<br>"
	di "Number of individuals with missing values: " `nbindmiss' 
	if "`ld'"=="" {
   		di " (removed)"
	}
	di "<br>"
	di "Number of individuals with nul or perfect score: " `=`effscore0'+`effscore`nbgroups''' "<br>"
}
if "`method'"=="cml" {
   if "`html'" == "" {
   	di in green  "Conditional log-likelihood: " in yellow %-13.4f `ll'
	di in green  "Log-likelihood: " in yellow %-13.4f `globalll'
   }
}
else {
   if "`html'" == "" {
   	di in green "Marginal log-likelihood: " in yellow %-13.4f `ll'
   	di in green  "Log-likelihood: " in yellow %-13.4f `globalll'
	di
   }
   else {
   	di "Marginal log-likelihood: " %-13.4f `ll' "<br>"
   	di "Log-likelihood: " %-13.4f `globalll' "<p/>"
   }
}

if "`html'" == "" {
   noi di in green  _col(16) "Difficulty" `conttest'
   if "`test'"!="NONE" {
	di in green _col(58) "Standardized"
   }
   noi di in green _col(9) "Items" _col(16) "parameters" _col(28) "std Err." `conttest'
   if "`test'"!="NONE" {
   	local varin=int(2/sqrt(`nbind')*100)/100
   	local varout=int(6/sqrt(`nbind')*100)/100
   	di _col(41) "`namewp'" _col(47) "df" _col(50) "p-value" _col(58) "Outfit" _col(66) "Infit" `cont'
   	if "`method'"=="cml" {
      		di in green _col(77) "U"
   	}
   }
   di in green  "{hline `line'}"
}
else {
   di "<table id=" _char(34) "raschtestdifftable" _char(34) "class=" _char(34) "restable" _char(34) ">"
   di "<caption></caption>"
   di "<thead><tr><th></th><th>Difficulty</th><th></th>"
   if "`test'"!="NONE" {
	di "<th colspan=3></th><th colspan=2>Standardized</th>"
   }
   di "</tr>"
   di "<tr><th>Items</th><th>parameters</th><th>std Err.</th>"
   if "`test'"!="NONE" {
   	local varin=int(2/sqrt(`nbind')*100)/100
   	local varout=int(6/sqrt(`nbind')*100)/100
   	di "<th>`namewp'</th><th>df</th><th><i>p</i>-value</th><th>Outfit</th><th>Infit</th>"
   	if "`method'"=="cml" {
      		di "<th>U</th>"
   	}
   }
   di "</tr></thead><tbody>"
}

forvalues i=1/`nbitems' {
   if "`html'" == "" {
	noi di in yellow _col(3) %12s abbrev("``i''`fixed`i''" ,12) in yellow _col(18) %8.5f `beta`i'' _col(29) %6.5f `sd`i'' `conttest'
   }
   else {
	di "<tr><td>" %12s abbrev("``i''`fixed`i''" ,12) "</td><td>" %8.5f `beta`i'' "</td><td>" %6.5f `sd`i'' "</td>"
   }
   if "`test'"!="NONE" {
   	if "`html'" == "" {
      		di _col(36) %8.3f `testitems'[`i',1] _col(46) %3.0f `=`nbgroups'-2' _col(51) %6.4f 1-chi2(`=`nbgroups'-2',`testitems'[`i',1]) _col(58) %6.3f `outfitstd`i'' _col(65) %6.3f `infitstd`i''  /*_col(72) %6.3f `outfit`i'' _col(79) %6.3f `infit`i''*/  `cont'
	}
	else {
      		di "<td>" %8.3f `testitems'[`i',1] "</td><td>" %3.0f `=`nbgroups'-2' "</td><td>" %6.4f 1-chi2(`=`nbgroups'-2',`testitems'[`i',1]) "</td><td>" %6.3f `outfitstd`i'' "</td><td>" %6.3f `infitstd`i'' "</td>"
	}
      matrix `itemfit'[`i',1]=`testitems'[`i',1]
      matrix `itemfit'[`i',2]=`=`nbgroups'-2'
      matrix `itemfit'[`i',3]=1-chi2(`=`nbgroups'-2',`testitems'[`i',1])
      matrix `itemfit'[`i',4]=`outfitstd`i''
      matrix `itemfit'[`i',5]=`infitstd`i''
      if "`method'"=="cml" {
   	if "`html'" == "" {
         	di in ye _col(72) %6.3f `U`i''
	}
	else {
         	di "<td>"  %6.3f `U`i'' "</td>"
	}
        matrix `itemfit'[`i',6]=`U`i''
      }
      if "`html'" != "" {
         di "</tr>"
      }
   }
}
if "`html'" == "" {
	di in green  "{hline `line'}"
}
else {
	di "</tbody>"
}
if "`test'"!="NONE" {
   if "`method'"=="cml" {
      local df=(`nbgroups'-2)*(`nbitems'-1)
   }
   else {
      local df=(`nbgroups'-1)*(`nbitems'-1)-1
   }
   matrix `globalfit'=(`stattest',`df',1-chi2(`df',`stattest'))
   if "`html'" == "" {
   	noi di in green _col(6) "`descwp'" _col(32) in gr "`namewp'=" _col(36) in ye %8.3f `globalfit'[1,1] _col(46) %3.0f `globalfit'[1,2] _col(51) %6.4f `globalfit'[1,3]
   	if "`method'"=="cml" {
      		noi di in green _col(6) "Andersen LR test" _col(34) "Z=" in yellow _col(36) %8.3f `AndersenZ'[1,1] _col(46) %3.0f `AndersenZ'[1,2] _col(51) %6.4f `AndersenZ'[1,3]
   	}
   	di in green  "{hline `line'}"
   }
   else {
   	di "<tfoot><tr><td>`descwp'</td><td></td><td>`namewp'=</td><td>" %8.3f `globalfit'[1,1] "</td><td>" %3.0f `globalfit'[1,2] "</td><td>" %6.4f `globalfit'[1,3] "</td><td></td><td></td></tr>"
   	if "`method'"=="cml" {
      		di "<tr><td>Andersen LR test</td><td></td><td>Z=</td><td>" %8.3f `AndersenZ'[1,1] "</td><td>" %3.0f `AndersenZ'[1,2] "</td><td>" %6.4f `AndersenZ'[1,3] "</td><td></td><td></td></tr>"
   	}
   	di "</tfoot></table>"
   }
}

if "`html'" == "" {
   if "`method'"=="cml"&"`meandiff'"==""{
	di in green "*: The difficulty parameter of this item had been fixed to 0"
   }
   if "`method'"=="cml"&"`meandiff'"!=""{
   	di in green "The mean of the difficulty parameters is fixed to 0"
   }
   if `smallgroup'==1&"`test'"!="NONE" {
   	di in green "You have groups of scores with less than 30 individuals. The tests can be invalid."
   }
   if "`method'"!="cml"&"`test'"=="Q" {
   	di in green "The Q statistics is approximated in the `method' approach. It is preferable to use the R1m test."
   }

   di
}
else {
   if "`method'"=="cml"&"`meandiff'"==""{
	di "*: The difficulty parameter of this item had been fixed to 0<br>"
   }
   if "`method'"=="cml"&"`meandiff'"!=""{
   	di "The mean of the difficulty parameters is fixed to 0<br>"
   }
   if `smallgroup'==1&"`test'"!="NONE" {
   	di "You have groups of scores with less than 30 individuals. The tests can be invalid.<br>"
   }
   if "`method'"!="cml"&"`test'"=="Q" {
   	di "The Q statistics is approximated in the `method' approach. It is preferable to use the R1m test.<br>"
   }
   di "<p/>"
}

if "`html'" == "" {
   if "`method'"!="cml" {
	di in green  "{hline 56}"
	noi di in green _col(5) "Parameters" _col(21) "Coef." _col(28) "std Err." _col(43) "z" _col(52) "P>|z|"
	di in green  "{hline 56}"
	local zsig=`sig'/`sesig'
	local pzsig=2*(1-norm(abs(`zsig')))
	di in green _col(10) in yellow "Sigma" _col(18) %8.5f `sig' _col(29) %6.5f `sesig' _col(38) %6.3f `zsig' _col(50) %7.4f `pzsig'
	di in green  "{hline 56}"
   }
}
else {
   if "`method'"!="cml" {
   	di "<table id=" _char(34) "raschtestsigmatable" _char(34) "class=" _char(34) "restable" _char(34) ">"
   	di "<caption></caption>"
   	di "<thead><tr><th>Parameters</th><th>Coef.</th><th>std Err.</th><th>z</th><th>P>|z|</th></tr></thead>"
	local zsig=`sig'/`sesig'
	local pzsig=2*(1-norm(abs(`zsig')))
	di "<tbody><tr><td>Sigma</td><td>" %8.5f `sig' "</td><td>" %6.5f `sesig' "</td><td>" %6.3f `zsig' "</td><td>" %7.4f `pzsig' "</td></tr></tbody></table>"
   }
}



*set trace on
if "`covariables'"!="" {
   tempname zcovariates pcovariates
   matrix `zcovariates'=J(1,`nbcovariables',0)
   matrix `pcovariates'=J(1,`nbcovariables',0)
   forvalues i=1/`nbcovariables' {
      local tmp :word `i' of `covariables'
      local zcov=`betacov'[1,`i']/`Vbetacov'[`i',`i']^.5
      local pzcov=2*(1-norm(abs(`zcov')))
      matrix `zcovariates'[1,`i']=`zcov'
      matrix `pcovariates'[1,`i']=`pzcov'
      di in green _col(3) %12s in yellow abbrev("`tmp'",12) _col(18) %8.5f `betacov'[1,`i'] _col(29) %6.5f `Vbetacov'[`i',`i']^.5 _col(38) %6.3f `zcov' _col(50) %7.4f `pzcov'
   }
   di in green  "{hline 56}"
   local difficulties2
   if "`difficulties'"!="" {
      local difficulties2 diff(`difficulties')
   }
   if "`ss1'"!="" {
      tempfile ss1save
      qui save `ss1save'
      qui use `saveraschtest'
      qui keep if `touse'==1

      qui raschtestv7 `varlist' ,id(`id') meth(`method') test(none) `ld' `difficulties2'
      local sigma0=r(sigma)
      local var0=`sigma0'^2
      local nbobs=r(N_obs)
      *di "nbobs=`nbobs'"
      local df0=`nbobs'-(`nbitems'+1)-1
      local ss10=`var0'*(`df0')
      local ss1c0=0
      di
      di in green "Type 1 Sum of Squares (sequential)"
      di "{hline 85}"
      di in green _col(44) "Degrees" _col(56) "Variance of the"  _col(77) "Explained"
      di in green _col(4) "Covariates" _col(25) "SS" _col(35) "Diff" _col(41) "of freedom"_col(59) "latent trait" _col(78) "Variance"
      di "{hline 85}"
      di _col(10) in green  "None" _col(15) in ye %12.3f `ss10' _col(47) %4.0f `df0' _col(63) %8.3f `var0'
      di in green "{dup 85:-}"
      local covariablesss1
      forvalues i=1/`nbcovariables' {
         local covariablesss1 `covariablesss1' `covariable`i''
         qui raschtestv7 `varlist' ,id(`id') meth(`method') covariates(`covariablesss1') test(none)  `ld' `difficulties2'
         local nbobs=r(N_obs)
         local sigma`i'=r(sigma)
         local var`i'=`sigma`i''^2
         local nbcovtmp:word count `covariablesss1'
         *di " ss1`i'=`var`i''*`=`nbobs'-(`nbitems'+1+`nbcovtmp')-1'"
         local df`i'=`nbobs'-(`nbitems'+1+`nbcovtmp')-1
         *di "local df`i'=`nbobs'-(`nbitems'+1+`nbcovtmp')-1 (cov:`covariablesss1')"
         local ss1`i'=`var`i''*`df`i''
         *di "cov : `covariablesss1' var=`var`i'' df=`df`i''"
         di _col(2) %12s in yellow abbrev("`covariable`i''",12) _col(15) %12.3f in ye `ss1`i'' _col(25) %12.3f `=`ss1`=`i'-1''-`ss1`i''' _col(47) %4.0f `df`i'' _col(63) %8.3f `var`i'' _col(81) %5.3f (`=`ss1`=`i'-1''-`ss1`i''')/`ss10'
      }
      di in green "{hline 85}"
      qui use `ss1save'
   }
   if "`ss3'"!="" {
      tempfile ss3save
      qui save `ss3save'
      qui use `saveraschtest'
      qui keep if `touse'==1
      if "`ss1'"=="" {
         qui raschtestv7 `varlist' ,id(`id') meth(`method') test(none) `ld' `difficulties2'
         local sigma0=r(sigma)
         local var0=`sigma0'^2
         local nbobs=e(N_obs)
         local df0=`nbobs'-(`nbitems'+1)-1
         local ss30=`var0'*(`df0')
      }
      else {
         local ss30=`ss10'
      }
      local ss3ref=`=`sig'^2*(`df0'-`nbcovariables')'
      di
      di in green "Type 3 Sum of Squares "
      di "{hline 85}"
      di in green _col(44) "Degrees" _col(56) "Variance of the"  _col(77) "Explained"
      di in green _col(4) "Covariates" _col(25) "SS" _col(35) "Diff" _col(41) "of freedom"_col(59) "latent trait" _col(78) "Variance"
      di "{hline 85}"
      di _col(10) in green  "None" _col(15) in ye %12.3f `ss30' _col(47) %4.0f `df0' _col(63) %8.3f `var0'
      di _col(6) in green  "Complete" _col(15) in ye %12.3f `ss3ref' _col(25) %12.3f `=`ss30'-`ss3ref''  _col(47) %4.0f `=`df0'-`nbcovariables'' _col(63) %8.3f `sig'^2  _col(81) %5.3f 1-`sig'^2*(`df0'+`nbcovariables')/`ss30'
      di in green "{dup 85:-}"
      forvalues i=1/`nbcovariables' {
         local covariablesss3
         forvalues j=1/`nbcovariables' {
            if `i'!=`j' {
               local covariablesss3 `covariablesss3' `covariable`j''
            }
         }
         qui raschtestv7 `varlist' ,id(`id') meth(`method') covariates(`covariablesss3') test(none) `ld' `difficulties2'
         *ereturn list
         local sigmas`i'=r(sigma)
         local vars`i'=`sigmas`i''^2
         local nbobs=e(N)
         local dfs`i'=`nbobs'-(`nbitems'+1)-1-(`nbcovariables'-1)
         *di "local dfs`i'=`nbobs'-(`nbitems'+1)-1-(`nbcovariables'-1)"
         local ss3s`i'=`vars`i''*`dfs`i''
         local vara`i'=`sig'^2
         local dfa`i'=`nbobs'-(`nbitems'+1)-1-`nbcovariables'
         local ss3a`i'=`vara`i''*`dfa`i''
         *di "cov : `covariablesss3' var=`vars`i'' df=`dfs`i''"
         di _col(2) %12s in green abbrev("`covariable`i''",12) _col(15) in ye %12.3f `ss3s`i'' _col(25) %12.3f in ye `=`ss3s`i''-`ss3a`i''' _col(47) %4.0f `=`df0'-`nbcovariables'+1' _col(63) %8.3f `vars`i'' _col(80) %6.3f (`=`ss3s`i''-`ss3a`i''')/`ss30'
      }
      di in green "{hline 85}"
      qui use `ss3save'
   }
}



/*Tabular of the estimated values of the latent trait*/

if "`covariables'"=="" {
   if "`html'" == "" {
   	di
   	di
   	noi di in green _col(33) "Ability" _col(60) "Expected"
   	noi di in green _col(17) "Group" _col(23) "Score" _col(30) "parameters" _col(42) "std Err." _col(54) "Freq." _col(63) "Score"_c
   	if "`method'"=="cml"&"`test'"!="NONE" {
      		noi di in green _col(75) "ll"
   	}
   	else {
      		noi di ""
   	}
   	if "`method'"=="cml"&"`test'"!="NONE" {
      		local line=62
   	}
   	else {
     		local line=51
   	}
   	di in green _col(17) "{hline `line'}"
   }
   else {
   	di "<table id=" _char(34) "raschtestabilitytable" _char(34) "class=" _char(34) "restable" _char(34) ">"
	di "<caption></caption>"
	di "<thead><tr><th>Group</th><th>Score</th><th>Ability<br>parameters</th><th>std Err.</th><th>Freq.</th><th>Expected<br>Score</th>"
   	if "`method'"=="cml"&"`test'"!="NONE" {
      		di "<th>ll</th>"
   	}
	di "</tr></thead><tbody>"
   }

   local nonul=0
   forvalues g=0/`nbgroups' {
      if `g'!=0 {
         if "`html'" == "" {
		di in green _col(17) "{dup `line':-}"
	}
      }
      forvalues s=`liminf`g''/`limsup`g'' {
         if `s'==`liminf`g'' {
            local tmp `ll`g''
            local gr `g'
         }
         else {
            local tmp
            local gr
         }
         local expscore`nonul'=0
         forvalues i=1/`nbitems' {
            local expscore`nonul'=`expscore`nonul''+1/(1+exp(-`theta`nonul''+`beta`i''))
         }
         if "`method'"=="cml" {
            local format1 %8.3f
         }
         else {
            local format1 %8.5f
         }
	if "`html'" == "" {
         	noi di in yellow _col(17) %5s "`gr'"_col(23) %5s "`s'" _col(32) `format1' `theta`nonul'' _col(42) `format1' `sdtheta`nonul'' _col(55) %4.0f `nbrealscore`s'' _col(64) % 4.2f `expscore`nonul'' _col(68) %11.4f `tmp'
	}
	else {
         	di "<tr><td>" %5s "`gr'" "</td><td>" %5s "`s'" "</td><td>" `format1' `theta`nonul'' "</td><td>" `format1' `sdtheta`nonul'' "</td><td>" %4.0f `nbrealscore`s'' "</td><td>" % 4.2f `expscore`nonul'' "</td><td>" %11.4f `tmp' "</td>"
	}
         local nonul=`nonul'+1
      }
   }
   if "`html'" == "" {
   	di in green _col(17) "{hline `line'}"
   }
   else {
	di "</tr></tbody></table>"
   }
}

if "`method'"=="mml"|"`method'"=="gee" {
   if "`html'" == "" {
       di
       *di in green "Variance of the estimated latent trait" _col(45) in ye %10.4f `vartheta'
       di in green "Mean variance of the error" _col(45) in ye %10.4f `meanse2'
       local sig2=`sig'^2
       di in green "Estimated variance of the latent trait" _col(45) in ye %10.4f `sig2'
       local psi2=1-`meanse2'/`sig2'
       di in green "Personal Separation Index (PSI)" _col(45) in ye %10.4f `psi2'
       di in green "Adjusted PSI on covariates (PSIadj)" _col(45) in ye %10.4f `psi'
   }
   else {
   	di "<table id=" _char(34) "raschtestsummarytable" _char(34) "class=" _char(34) "restable" _char(34) ">"
	di "<caption></caption>"
	di "<thead></thead><tbody>"
       di "<tr><th>Mean variance of the error</th><td>" %10.4f `meanse2' "</td></tr>"
       local sig2=`sig'^2
       di "<tr><th>Estimated variance of the latent trait</th><td>" %10.4f `sig2' "</td></tr>"
       local psi2=1-`meanse2'/`sig2'
       di "<tr><th>Personal Separation Index (PSI)</th><td>" %10.4f `psi2' "</td></tr>"
       di "<tr><th>Adjusted PSI on covariates (PSIadj)</th><td>" %10.4f `psi' "</td></tr>"
       di "</tbody></table>"
   }
}


/***********************************************************************************************************
DETAILS OPTION
************************************************************************************************************/

if "`details'"!="" {
  if "`html'"=="" {
   forvalues g=0/`nbgroups' {
      if (`g'!=0&`g'!=`nbgroups')|"`method'"!="cml" {
         di
         di in  green "{hline 44}"
         di in green "Group: " in ye "`g'" in green " from " in ye "`liminf`g''" in green " to " in ye "`limsup`g''" in green " (n=" in ye "`nbscore`g''" in green")"
         di
         di _col(3) "Item" _col(10) "Observed" _col(23) "Expected" _col(37) "Scaled"
         di in green "{dup 44:-}"
      }
      if `g'!=0&`g'!=`nbgroups' {
         forvalues j=1/`nbitems' {
            local tmp=`d2`g''[`j',1]/sqrt(`W2`g''[`j',`j'])
            di _col(3) in ye "``j''" _col(14) %4.0f `Obs2'[`j',`g'] _col(25) %6.2f `Th2'[`j',`g'] _col(36) %7.4f `tmp'
         }
         di in green "{dup 44:-}"
         di in green "Contribution to the `namewp' statistics: " %8.4f in ye `test`g''[1,1]
      }
      else if "`method'"!="cml" {
         if `g'==0 {
            local h=0
         }
         else {
            local h=`nbitems'
         }
         local tmp=abs(`nbrealscore`h''-`ci`h'')/sqrt(`ci`h'')
         di in ye _col(14) %4.0f `nbrealscore`h'' _col(25) %6.2f `ci`h'' _col(36) %7.4f `tmp'
         di in green "{dup 44:-}"
         local tmp=`tmp'^2
         di in green "Contribution to the `namewp' statistics: " %8.4f in ye `tmp'
      }
   }
  }
  else {
   forvalues g=0/`nbgroups' {
      if (`g'!=0&`g'!=`nbgroups')|"`method'"!="cml" {
	 di in gr "<table id=" _char(34) "raschtestdetail`g'table" _char(34) "class=" _char(34) "restable" _char(34) ">"
	 di in gr "<caption>Group: `g' from `liminf`g'' to `limsup`g'' (n=`nbscore`g'')</caption>"
	 di in gr  "<thead><tr><th>Item</th><th>Observed</th><th>Expected</th><th>Scaled</th></tr></thead><tbody>"
      }
      if `g'!=0&`g'!=`nbgroups' {
         forvalues j=1/`nbitems' {
            local tmp=`d2`g''[`j',1]/sqrt(`W2`g''[`j',`j'])
            di "<tr><th>``j''</th><td>" %4.0f `Obs2'[`j',`g'] "</td><td>" %6.2f `Th2'[`j',`g'] "</td><td>" %7.4f `tmp' "</td></tr>"
         }
         di "</tbody><tfoot><tr><th colspan=3>Contribution to the `namewp' statistics:</th><td>" %8.4f `test`g''[1,1] "</td></tr></tfoot>"
      }
      else if "`method'"!="cml" {
         if `g'==0 {
            local h=0
         }
         else {
            local h=`nbitems'
         }
         local tmp=abs(`nbrealscore`h''-`ci`h'')/sqrt(`ci`h'')
         di "<tr><th></th><td>" %4.0f `nbrealscore`h'' "</td><td>" %6.2f `ci`h'' "</td><td>" %7.4f `tmp' "</td></tr>"
         local tmp=`tmp'^2
         di "</tbody><tfoot><tr><th colspan=3>Contribution to the `namewp' statistics:</th><td>" %8.4f `tmp' "</td></tr></tfoot>"
      }
      di "</table>"
   }
  }
}

/***********************************************************************************************************
OPTION ICC
************************************************************************************************************/
*set trace on
if "`icc'"!="" {
   if "`trace'"!="" {
      di in green "*** Items Characteristic Curves"
   }
   tempvar proba propemp propth propthb
   qui replace `tl'=. if `realscore'==0|`realscore'==`nbitems'|`realscore'==.
   qui gen `propemp'=.
   qui gen `propth'=.
   qui gen `propthb'=.
   label variable `propth' "Expected ICC"
   label variable `propemp' "Observed ICC"
   label variable `propthb' "Expected ICC"
   label variable `tl' "Latent trait"
   global iccs
   forvalues i=1/`nbitems' {
      forvalues s=1/`=`nbitems'-1' {
         qui replace `propthb'=exp(`theta`s''-`beta`i'')/(1+exp(`theta`s''-`beta`i'')) if `item'==`i'&`realscore'==`s'
      }
      qui replace `propemp'=.
      qui replace `propth'=.
      tempvar propemp`i' propth`i'
      qui bysort `realscore' `item' : egen `propth`i''=mean(`propthb') if `item'==`i'
      qui bysort `realscore' `item' : egen `propemp`i''=mean(`rep') if `item'==`i'
      qui replace `propth'=`propth`i'' if `item'==`i'
      qui replace `propemp'=`propemp`i'' if `item'==`i'
      local mintl=floor(`theta1')
      local maxtl=floor(`theta`=`nbitems'-1'')+1
      if "`filessave'"!=""{
         local saving "`dirsave'\\icc``i''"
      }
      if "`html'"!="" {
         local saving "`c(tmpdir)'/`html'_icc_``i''"
      }
      if "`v8'"!=""|"`html'"!="" {
         graph twoway (line  `propemp' `propth' `tl') if `item'==`i' , `htmlregion' name(icc``i'',replace) ytitle("")  ylabel(0(.25)1) title("Observed and Expected ICC for the item ``i''") xlabel(`mintl'(1)`maxtl') xsize(12) ysize(9) `draw'
         if "html"=="" {
            pause
         }
         else {
            qui graph save icc``i''  "`saving'" , `replace'
            qui graph export `c(tmpdir)'/`html'_icc_``i''.eps, replace
            di "<img src=" _char(34) "/data/`html'_icc_``i''.png" _char(34) 
	    di " class=" _char(34) "resgraph" _char(34) " alt=" _char(34) "icc graph" _char(34) " title= " _char(34) "ICC graph for ``i'' - click to enlarge" _char(34) " >"
 
         }
         if "`filessave'"!="" {
            qui graph save icc``i''  "`saving'" , `replace'
         }
      }
      else {
         if "`filessave'"!="" {
            local saving "saving(`saving'"
            if "`replace'"=="" {
               local saving "`saving')"
            }
            else {
               local saving "`saving',replace)"
            }
         }
         qui graph `propemp' `propth' `tl' if `item'==`i' , twoway `saving' c(ll) ylabel(0(.25)1)   xlabel(`mintl'(1)`maxtl') title("Observed and Expected ICC for the item ``i''")
         pause
      }
   }
}

/***********************************************************************************************************
OPTION INFORMATION
************************************************************************************************************/

if "`information'"!="" {
   if "`trace'"!="" {
      di in green "*** Information graph"
   }

   tempfile saveinfo
   qui save "`saveinfo'",replace
   tempvar info latent
   drop _all
   qui set obs 2001
   gen `latent'=((_n-1)/1001-1)*3
   label variable `latent' "latent trait"
   gen `info'=0
   forvalues i=1/`nbitems' {
      qui replace `info'=`info'+exp(`latent'-`beta`i'')/(1+exp(`latent'-`beta`i''))^2
   }
   local saving "`dirsave'\\information"
   if "`html'"!="" {
      local saving "`c(tmpdir)'/`html'_information"
   }
   if "`v8'"!=""|"`html'"!="" {
   *set trace on
      graph twoway (line  `info' `latent') , `htmlregion'  name(information,replace) ytitle("Information") xlabel(-3(1)3) title("Information graph of the scale") xsize(12) ysize(9) `draw'
      if "`filessave'"!="" {
         graph save information "`saving'" , `replace'
      }
      if "`html'"=="" {
         pause
      }
      else  {
         qui graph save information  "`saving'" , `replace'
         qui graph export `c(tmpdir)'/`html'_information.eps, replace
	 di "<img src=" _char(34) "/data/`html'_information.png" _char(34) 
	 di " class=" _char(34) "resgraph" _char(34) " alt=" _char(34) "information graph" _char(34) " title= " _char(34) "Information graph - click to enlarge" _char(34) " >"
      }
   }
   else {
      if "`filessave'"!="" {
         local saving "saving(`saving'"
         if "`replace'"=="" {
            local saving "`saving')"
         }
         else {
            local saving "`saving',replace)"
         }
      }
      if "`filessave'"=="" {
         local saving
      }
      qui graph `info' `latent' , twoway  `saving' c(l) xlabel(-3(1)3) title("Information graph of the scale")
      pause
   }
   qui use "`saveinfo'",replace
}

/***********************************************************************************************************
OPTION FITGRAPH
************************************************************************************************************/

if "`fitgraph'"!="" {
   if "`trace'"!="" {
      di in green "*** Graphical validation of the fit"
   }
   *set trace on
   tempname outfit meanz2 meanv2 sumd infit Voutfit outfitstd Vinfit infitstd
   qui egen `outfit'=mean(`y2'),by(`id')
   qui egen `Voutfit'=sum(`r'),by(`id')
   qui replace `Voutfit'=`Voutfit'/(`nbitems')^2-1/`nbitems'
   qui gen `outfitstd'=(`outfit'^(1/3)-1)*(3/sqrt(`Voutfit'))-sqrt(`Voutfit')/3
   qui egen `meanz2'=sum(`z2'),by(`id')
   qui egen `meanv2'=sum(`v2'),by(`id')
   qui gen `infit'=`meanz2'/`meanv2'
   qui egen `Vinfit'=sum(`e'),by(`id')
   qui replace `Vinfit'=`Vinfit'/(`meanv2')^2
   qui gen `infitstd'=(`infit'^(1/3)-1)*(3/sqrt(`Vinfit'))-sqrt(`Vinfit')/3

   qui su `outfitstd'
   local mino=floor(2*min(`r(min)',-2))/2
   local maxo=ceil(2*max(`r(max)',2))/2
   qui su `infitstd'
   local mini=floor(2*min(`r(min)',-2))/2
   local maxi=ceil(2*max(`r(max)',2))/2
   if "`filessave'"!=""{
      local savingo "`dirsave'\\outfitind"
      local savingi "`dirsave'\\infitind"
   }
   if "`v8'"!="" {
      graph twoway (scatter `outfitstd' `id'), `htmlregion' name(outfit,replace) yline(-2 2) title("Outfit indexes") xtitle("Individual indexes") ytitle("Outfit") ylabel(`mino'(.5)`maxo') `draw'
      if "`html'"=="" {
         pause
      }
      graph twoway (scatter `infitstd' `id'), `htmlregion' name(infit,replace) yline(-2 2) title("Infit indexes") xtitle("Individual indexes") ytitle("Infit") ylabel(`mini'(.5)`maxi') `draw'
      if "`html'"=="" {
         pause
      }
      if "`filessave'"!=""|"`html'"!="" {
         qui graph save outfit "`savingo'" , `replace'
         if "`html'"!=""  {
            qui graph export `c(tmpdir)'/`html'_outfit.eps, replace
         }
         qui graph save infit "`savingi'" , `replace'
         if "`html'"!=""  {
            qui graph export `c(tmpdir)'/`html'_infit.eps, replace
         }
      }
   }
   else {
      if "`filessave'"!="" {
         local savingo "saving(`savingo'"
         local savingi "saving(`savingi'"
         if "`replace'"=="" {
            local savingo "`savingo')"
            local savingi "`savingi')"
         }
         else {
            local savingo "`savingo',replace)"
            local savingi "`savingi',replace)"
         }
      }
      graph `outfitstd' `id', `savingo' twoway sy(.) c(.) yline(-2 2) title("Outfit indexes") b2title("Individual indexes") l1("") l2title("Outfit") ylabel(`mino'(.5)`maxo')
      pause
      graph `infitstd' `id', `savingi' twoway sy(.) c(.) yline(-2 2) title("Infit indexes") b2title("Individual indexes") l1("")  l2title("Infit") ylabel(`mini'(.5)`maxi')
      pause
   }
   drop _all
   qui set obs `nbitems'
   tempvar name betap outfitstdj infitstdj
   qui gen str9 `name'=""
   qui gen `betap'=.
   qui gen `outfitstdj'=.
   qui gen `infitstdj'=.
   local mino=-2
   local maxo=2
   local mini=-2
   local maxi=2
   forvalues j=1/`nbitems' {
      qui replace `name'="``j''" in `j'
      qui replace `betap'=`beta`j'' in `j'
      qui replace `outfitstdj'=`outfitstd`j'' in `j'
      qui replace `infitstdj'=`infitstd`j'' in `j'
      local mino=floor(min(`mino',`outfitstd`j'')*2)/2
      local mini=floor(min(`mini',`infitstd`j'')*2)/2
      local maxo=ceil(max(`maxo',`outfitstd`j'')*2)/2
      local maxi=ceil(max(`maxi',`infitstd`j'')*2)/2
   }
   if "`filessave'"!=""{
      local savingo "`dirsave'\\outfititems"
      local savingi "`dirsave'\\infititems"
   }
   if "`v8'"!="" {
      graph twoway (scatter `outfitstdj' `betap',`htmlregion' name(outfititem,replace) mlabel(`name')), yline(-2 2) title("Outfit indexes") xtitle("Difficulty") ytitle("Outfit") ylabel(`mino'(.5)`maxo') `draw'
      if "`html"=="" {
         pause
      }
      graph twoway (scatter `infitstdj' `betap',`htmlregion' name(infititem,replace) mlabel(`name')), yline(-2 2) title("Infit indexes") xtitle("Difficulty") ytitle("Infit") ylabel(`mini'(.5)`maxi') `draw'
      if "`html"=="" {
         pause
      }
      if "`filessave'"!=""|"`html'"!="" {
         qui graph save outfititem "`savingo'" , `replace'
         if "`html'"!=""  {
            qui graph export `c(tmpdir)'/`html'_outfititem.eps, replace
         }
         qui graph save infititem "`savingi'" , `replace'
         if "`html'"!=""  {
            qui graph export `c(tmpdir)'/`html'_infititem.eps, replace
         }
      }
   }
   else {
      if "`filessave'"!="" {
         local savingo "saving(`savingo'"
         local savingi "saving(`savingi'"
         if "`replace'"=="" {
            local savingo "`savingo')"
            local savingi "`savingi')"
         }
         else {
            local savingo "`savingo',replace)"
            local savingi "`savingi',replace)"
         }
      }
      graph `outfitstdj' `betap', `savingo' twoway c(.) yline(-2 2) title("Outfit indexes") b2title("Difficulty") l1title("") l2title("Outfit") ylabel(`mino'(.5)`maxo') sy([`name'])
      pause
      graph `infitstdj' `betap', `savingi' twoway c(.) yline(-2 2) title("Infit indexes") b2title("Difficulty") l1title("") l2title("Infit") ylabel(`mini'(.5)`maxi') sy([`name'])
      pause
   }
}


/***********************************************************************************************************
OPTION SPLITTESTS
************************************************************************************************************/

if "`splittests'"!="" {
   if "`trace'"!="" {
      di in green "*** Splitting tests"
   }
   forvalues j=1/`nbitems' {
      tempname estneg`j' estpos`j'
      local listitems
      forvalues k=1/`nbitems' {
         if `j'!=`k' {
            local listitems `listitems' ``k''
         }
      }
      qui use "`saveraschtest'",replace
      qui keep if `touse'==1
      qui raschtestv7 `listitems' if ``j''==0,test(NONE) meth(cml) `ld' id(`id')
      matrix `estneg`j''=r(beta)
      local llneg=r(cll)
      qui raschtestv7 `listitems' if ``j''==1,test(NONE) meth(cml) `ld'  id(`id')
      matrix `estpos`j''=r(beta)
      local llpos=r(cll)
      qui raschtestv7 `listitems',test(NONE) meth(cml) `ld' id(`id')
      local llnegpos=r(cll)
      local nbcol=colsof(`estneg`j'')
      local meanneg=0
      local meanpos=0
      forvalues k=1/`nbcol' {
         local meanneg=`meanneg'+`estneg`j''[1,`k']
         local meanpos=`meanpos'+`estpos`j''[1,`k']
      }
      local meanneg=`meanneg'/`nbitems'
      local meanpos=`meanpos'/`nbitems'
      forvalues k=1/`nbcol' {
         matrix `estneg`j''[1,`k']=`estneg`j''[1,`k']-`meanneg'
         matrix `estpos`j''[1,`k']=`estpos`j''[1,`k']-`meanpos'
         if "`method'"=="cml" {
            matrix `estneg`j''=`estneg`j'',-`meanneg'
            matrix `estpos`j''=`estpos`j'',-`meanpos'
         }
      }
      drop _all
      qui set obs `=`nbitems'+1'
      tempvar neg pos name diag
      qui gen `neg'=.
      qui gen `pos'=.
      qui gen str9 `name'=""
      local min=`estneg`j''[1,1]
      local max=`estneg`j''[1,1]
      forvalues k=1/`=`nbitems'-1' {
         qui replace `neg'=`estneg`j''[1,`k'] in `k'
         qui replace `pos'=`estpos`j''[1,`k'] in `k'
         local min=min(`min',`estneg`j''[1,`k'],`estpos`j''[1,`k'])
         local max=max(`max',`estneg`j''[1,`k'],`estpos`j''[1,`k'])
         local tmp:word `k' of `listitems'
         qui replace `name'="`tmp'" in `k'
      }
      local min=floor(`min')
      local max=floor(`max')+1
      qui gen `diag'=.
      qui replace `diag'=`min' in `nbitems'
      qui replace `diag'=`max' in `=`nbitems'+1'
      local Zgr=round(2*(`llneg'+`llpos'-`llnegpos'),0.001)
      local Zgr=substr("`Zgr'",1,6)
      local pgr=round(1-chi2(`=`nbitems'-1',`Zgr'),0.0001)
      local pgr=substr("`pgr'",1,5)
      local note="Z=`Zgr', df=`=`nbitems'-1' , p=`pgr'"
      if "`filessave'"!=""{
         local saving "`dirsave'\\split``j''"
      }
      if "`v8'"!="" {
         graph twoway (scatter `pos' `neg' ,mlabel(`name')) (line `diag' `diag'), ytitle("Positive answer") xtitle("Negative answer") xlabel(`min'(1)`max') ylabel(`min'(1)`max') title(Splitting on ``j'') `draw' legend(off) note("Andersen Z test: `note'") name(split,replace) `draw'
         pause
         if "`filessave'"!="" {
            graph save split "`saving'" , `replace'
         }
      }
      else {
         if "`filessave'"!="" {
            local saving "saving(`saving'"
            if "`replace'"=="" {
               local saving "`saving')"
            }
            else {
               local saving "`saving',replace)"
            }
         }
         qui replace `diag'=`neg' if `diag'==.
         graph  `pos' `diag' `diag', `saving' c(.l) sy([`name']i) l1title("") l2title("Positive answer") b2title("Negative answer") xlabel(`min'(1)`max') ylabel(`min'(1)`max') title("Splitting on ``j'' (`note')") `draw'
         pause
      }
   }
}

/***********************************************************************************************************
OPTION GRAPH
************************************************************************************************************/

if "`graph'"!=""&"`v8'"!="" {
   if "`trace'"!="" {
      di in green "*** Graph option"
   }
   tempvar  latent2  tl2 delta2 tlth2 labdelta2 labtl2
   drop _all
   qui set obs 1001
   gen `latent2'=(_n-501)/100
   label variable `latent2' "latent trait"
   qui gen `tl2'=.
   qui gen `labtl2'=""
   forvalues i=0/`nbitems' {
      *if (`i'!=0&`i'!=`nbitems')|"`method'"!="cml" {
         qui replace `tl2'=`nbrealscore`i''/`N' if round(`latent2',0.01)==round(`theta`i'',0.01)
         qui replace `labtl2'="`i'" if round(`latent2',0.01)==round(`theta`i'',0.01)
      *}
   }
   qui gen `delta2'=.
   qui gen `labdelta2'=""
   forvalues i=1/`nbitems' {
      qui replace `delta2'=-.05 if round(`latent2',0.01)==round(`beta`i'',0.01)
      qui replace `labdelta2'="``i''" if round(`latent2',0.01)==round(`beta`i'',0.01)
   }
   if "`method'"=="mml"|"`method'"=="gee" {
      qui gen `tlth2'=1/(2*_pi*`sig')*exp(-.5*(`latent2'/`sig')^2)
      label variable `tlth2' "Theorical distribution"
      local graphmml line `tlth2' `latent2'
   }
   label variable `tl2' "Score"
   label variable `delta2' "Items"
   local saving "`dirsave'\\graph"
   if "`html'"!="" {
      local saving "`c(tmpdir)'/`html'_map"
   }
   local min=-2
   local max=2
   forvalues j=1/`nbitems' {
      if `beta`j''<`min' {
         local min=`beta`j''-.5
      }
      if `beta`j''>`max'&`beta`j''!=. {
         local max=`beta`j''+.5
      }
   }
   if "`method'"=="cml" {
      if `theta0'<`min' {
         local min=`theta0'-.5
      }
      if `theta`=`nbitems'-1''>`max' {
         local max=`theta`=`nbitems'-1''+.5
      }
   }
   else if "`method'"!="cml" {
      if `theta0'<`min'&`theta0'!=. {
         local min=`theta0'-.5
      }
      if `theta`nbitems''>`max'&`theta`nbitems''!=. {
         local max=`theta`nbitems''+.5
      }
   }
   local min=floor(`min')
   local max=floor(`max')+1
   qui su `tl2'
   local max2=r(max)
   if "`method'"!="cml" {
      qui su `tlth2'
      local max2=max(`max2',`r(max)')
   }
   qui replace `latent2'=. if `latent2'<`min'|`latent2'>`max'
   if "`v8'"!="" {
      graph twoway (bar `tl2' `latent2',/*mlabel(`labtl2')*/ barwidth(.3) ) (dropline `delta2' `latent2',mlabel(`labdelta2') mlabposition(6)) (`graphmml'), `htmlregion' name(graph,replace) ytitle("") xlabel(`min'(1)`max') ylabel(-.1 0(0.05)`max2') title("Individuals/items representations") xsize(12) ysize(9) `draw'
      if "`filessave'"!="" {
         graph save graph "`saving'" , `replace'
      }
      if "`html'"=="" {
         pause
      }
      else  {
         qui graph save graph  "`saving'" , `replace'
         qui graph export `c(tmpdir)'/`html'_map.eps, replace
	 di "<img src=" _char(34) "/data/`html'_map.png" _char(34) 
	 di " class=" _char(34) "resgraph" _char(34) " alt=" _char(34) "distributions graph" _char(34) " title= " _char(34) "Distributions graph - click to enlarge" _char(34) " >"
      }
   }
}
else if "`graph'"!=""&"`v8'"=="" {
   di in ye "The graph option is not available with Stata 7"
}

/***********************************************************************************************************
COMPARISON OF TWO POPULATION
************************************************************************************************************/

if "`comp'"!=""&"`method'"!="cml" {
      di
      di _col(4) "{hline 30}"
      di _col(4) in green "Comparison of two populations"
      di _col(4) "{hline 30}"
      di
      di _col(4) in green "`comp'==`mincomp':" _col(20) "N=" _col(22) in yellow %7.0f `Nmin' _col(30) in green "mean= "       _col(35) in yellow %8.4f `meanmin' _col(45) in green "variance=" _col(55) in yellow %8.4f `varmin'
      di _col(4) in green "`comp'==`maxcomp':" _col(20) "N=" _col(22) in yellow %7.0f `Nmax' _col(30) in green "mean= "       _col(35) in yellow %8.4f `meanmax' _col(45) in green "variance=" _col(55) in yellow %8.4f `varmax'
      di                                                                       _col(33) in green "Z= " _col(35) in yellow %8.4f `Zcomp' _col(47) in green "pvalue= "    _col(57) in yellow %6.4f `pvalue'
}

/***********************************************************************************************************
TEST DIF
************************************************************************************************************/

if "`method'"=="cml"&"`dif'"!=""&"`test'"!="NONE" {
   if "`trace'"!="" {
      di in green "*** Tests of DIF"
   }
   local ssll=0
   tempname DIFfile
   qui save "`DIFfile'", replace
   qui use "`saveraschtest'",replace
   qui keep if `touse'==1
   unab list:`dif'
   local nbdif:word count `list'
   tempname DIF
   matrix define `DIF'=J(`nbdif',4,0)
   local count=1
   di
   di _col(4) in green "{hline 45}"
   di _col(4) in green "Test of Differential Item Functioning (DIF)"
   di _col(4) in green "{hline 45}"
   foreach j in `list' {
      qui inspect `j'
      local nbdif=r(N_unique)
      qui su `j'
      local maxdif=r(max)
      if `nbdif'>10&`maxdif'<=10 {
         di in ye "The {hi:dif} option is available with variables containing 10 or less modalities (coded from 0 or 1 to k<10)."
         di in ye "The variable `j' (`nbdif' modalities) is omitted."
      }
      else {
         local ssll=0
         forvalues i=0/10 {
            qui count if `j'==`i'
            local effdif=r(N)
            if `effdif'>0 {
               qui raschtestv7 `varlist' if `j'==`i', test(NONE) id(`id')
               local ll`i'=r(cll)
               local ssll=`ssll'+(`ll`i'')
            }
         }
         local Z=2*`ssll'-2*`ll'
         local ddl=(`nbdif'-1)*(`nbitems'-1)
         matrix define `DIF'[`count',1]=(`count',`Z',`ddl',1-chi2(`ddl',`Z'))
         di
         di _col(4) in green "Variable:" in ye " `j' " in green "   Number of groups: "  in ye "`nbdif'"
         di _col(4) in green "LR Test Z=" in ye %8.3f `Z' in gr "   ddl=" in ye %4.0f `ddl' in gr "    p-value=" in ye %6.4f `=1-chi2(`ddl',`Z')'
         di
      }
      local ++count
   }
   use "`DIFfile'",replace
}

/***********************************************************************************************************
RETURN
************************************************************************************************************/

if "`trace'"!="" {
  di in green "*** Returns"
}
local colnametheta

forvalues i=0/`nbgroups' {
         local colnametheta `colnametheta' score_`i'
}


return clear

if `nbitems'>=3&"`test'"!="NONE" {
        matrix colnames `globalfit'=`namewp' df p
	matrix rownames `globalfit'=`method'
	matrix rownames `itemfit'=`varlist'
        matrix roweq `itemfit'=`method'

	if "`method'"=="cml" {
                matrix colnames `itemfit'=`namewp' df p outfit infit U
		matrix rownames `AndersenZ'=`method'
		matrix colnames `AndersenZ'=Z df p
		return matrix AndersenZ=`AndersenZ'
                if "`dif'"!="" {
		   matrix rownames `DIF'=`list'
		   matrix colnames `DIF'=num Z df p
		   return matrix DIF=`DIF'
                }
	}
	else {
                matrix colnames `itemfit'=`namewp' df p outfit infit
	}
	return matrix itemFit=`itemfit'
	return matrix globalFit=`globalfit'
}

matrix colnames `theta'=`colnametheta'
matrix rownames `theta'=theta
return matrix theta `theta'
matrix colnames `sdtheta'=`colnametheta'
matrix rownames `sdtheta'=`colnametheta'
return matrix Vartheta `sdtheta'
local varlist2
matrix coleq `beta'=`method'
matrix coleq `Vbeta'=`method'
matrix roweq `Vbeta'=`method'
if "`method'"=="cml" {
	forvalues i=1/`=`nbitems'-1' {
		local varlist2 `varlist2' ``i''
	}
        return scalar cll=`ll'
        return scalar ll=`globalll'
	local AIC=-2*`globalll'+2*(`nbitems'-1)
}
else {
        return scalar ll=`ll'
	local varlist2 `varlist'
	return scalar sigma=`sig'
	return scalar sesigma=`sesig'
	local AIC=-2*`ll'+2*(`nbitems'+1)
}

if "`comp'"!="" {
   return scalar Zcomp=`Zcomp'
   return scalar pZcomp=`pvalue'
}

matrix colnames `beta'=`varlist2'
matrix rownames `beta'=beta
return matrix beta `beta'

matrix colnames `Vbeta'=`varlist2'
matrix rownames `Vbeta'=`varlist2'
return matrix Varbeta `Vbeta'

return scalar AIC=`AIC'
return scalar N=`nbind'
return scalar N_obs=`nbobserv'

if "`method'"=="mml" {
   return scalar PSI=`psi2'
   return scalar PSIadj=`psi'
}
if "`covariables'"!="" {
   local tmp
   local tmp2
   forvalues i=1/`nbcovariables' {
      local tmp `tmp' `covariable`i''
      local tmp2 "`tmp2' :`covariable`i''"
   }
   matrix colnames `betacov'=`tmp2'
   matrix rownames `Vbetacov'=`tmp2'
   matrix colnames `Vbetacov'=`tmp2'
   matrix colnames `zcovariates'=`tmp'
   matrix colnames `pcovariates'=`tmp'
   return matrix betacovariates=`betacov'
   return matrix Vbetacovariates=`Vbetacov'
   return matrix zcovariates=`zcovariates'
   return matrix pcovariates=`pcovariates'
}
if "`pause'"!="" {
   pause off
}

drop _all

restore,not
use "`saveraschtest'"

/***********************************************************************************************************
CREATE EVENTUAL NEW VARIABLES
************************************************************************************************************/

*set trace on
if "`genres'"!="" {
   qui sort `id'
   qui merge `id' using `ltsave'
   qui rename `u'm1 `genlt'
   qui rename `u's1 se`genlt'
   qui drop _merge se`genlt'
   forvalues i=1/`nbitems' {
      gen `genres'`i'=exp(``i''*(`genlt'-`beta`i''))/(1+exp(`genlt'-`beta`i''))/sqrt(exp(`genlt'-`beta`i'')/(1+exp(`genlt'-`beta`i''))^2)
   }
   corr `genres'*
   pca `genres'*
   drop `u'm1
}
if "`genfit'"!=""|"`genlt'"!=""|"`genscore'"!="" {
        tempname genlt2 genscore2 outfit2 infit2
        qui gen `score'=0 `if'
        forvalues i=1/`nbitems' {
           qui replace `score'=`score'+``i'' `if'
        }
        if "`genscore'"!="" {
           qui gen `genscore'=`score' `if'
        }
        if "`genlt'"!="" {
           if "`replacegenlt'"=="replace" {
              capture drop `genlt'
              capture drop se`genlt'
           }
           if "`method'"=="mml" {
              qui sort `id'
              qui merge `id' using `ltsave'
              qui rename `u'm1 `genlt'
              qui rename `u's1 se`genlt'
              qui drop _merge
           }
           else if "`method'"!="mml" {
              qui gen `genlt2'=. `if'
              forvalues i=0/`nbitems' {
                 qui replace `genlt2'=`theta`i'' `if'&`score'==`i'
              }
              qui gen `genlt'=`genlt2' `if'
           }
        }
        if "`genfit'"!="" {
           local outfit:word 1 of `genfit'
           local infit:word 2 of `genfit'
           qui gen `outfit'=0 `if'
           qui gen `infit'=0  `if'
           tempname infit1 infit2
           qui gen `infit1'=0 `if'
           qui gen `infit2'=0 `if'
           forvalues j=1/`nbitems' {
               tempname pi`j'
               qui gen `pi`j''=exp(`genlt2'-`beta`j'')/(1+exp(`genlt2'-`beta`j'')) `if'
               qui replace `pi`j''=0  `if'
               forvalues s=1/`nbitems' {
                  qui replace `pi`j''=`Pi'[`j',`s'] `if'&`score'==`s'
               }
               qui gen `outfit'``j''=(``j''-`pi`j'')^2/(`pi`j''*(1-`pi`j'')) `if'
               qui replace `infit1'=`infit1'+(``j''-`pi`j'')^2  `if'
               qui replace `infit2'=`infit2'+(`pi`j''*(1-`pi`j'')) `if'
               qui replace `outfit'=`outfit'+`outfit'``j''/`nbitems' `if'
           }
           qui replace `infit'=`infit1'/`infit2'  `if'
        }
}

if "`trace'"!=""|"`time'"!="" {
    capture qui elapse `st'
    di in green "** Time : " in yellow "$S_elap " in green "seconds"
}

end
