*! version 8.6  19november2012
*! Jean-Benoit Hardouin
************************************************************************************************************
* Raschtest: Rasch model, fit tests and graphical validation
*
* Historic:
* Version 1 (2003-06-30): Jean-Benoit Hardouin
* Version 2 (2003-07-07): Jean-Benoit Hardouin
* Version 3 (2004-01-02): Jean-Benoit Hardouin
* Version 4 (2004-01-21): Jean-Benoit Hardouin
* Version 5 (2004-01-24): Jean-Benoit Hardouin
* Version 6 (2004-02-05): Jean-Benoit Hardouin
* Version 6.1 (2004-03-29): Jean-Benoit Hardouin
* Version 6.2 (2004-04-06): Jean-Benoit Hardouin
* Version 6.3 (2004-07-08) : Jean-Benoit Hardouin
* Version 7  (2005-04-02) : Jean-Benoit Hardouin
* Version 7.2  (2005-05-20) : Jean-Benoit Hardouin
* Version 7.3  (2005-07-02) : Jean-Benoit Hardouin
* Version 7.4  (2006-01-15) : Jean-Benoit Hardouin
* Version 7.5  (2006-04-20) : Jean-Benoit Hardouin
* Version 7.6  (2008-06-20) : Jean-Benoit Hardouin /*nold option*/
* Version 8  (2009-06-20) : Jean-Benoit Hardouin /*DIFFICULTIES and COVARIATES options*/
* Version 8.3  (2010-06-15) : Jean-Benoit Hardouin /*GENRES option*/
* Version 8.6  (2012-11-19) : Jean-Benoit Hardouin /*HTML option*/
*
* Needed modules :
* raschtestv7 version 8.1 (http://freeirt.free.fr)
* gammasym version 2.2 (http://www.freeirt.org)
* gausshermite version 1 (http://www.freeirt.org)
* geekel2d version 4.3 (http://www.freeirt.org)
* genscore version 1.4 (http://www.freeirt.org)
* ghquadm (findit ghquadm)
* gllamm version 2.3.14 (ssc describe gllamm)
* gllapred version  2.3.7 (ssc describe gllapred)
* elapse (ssc describe elapse)
*
* Jean-benoit Hardouin - Department of Biomathematics and Biostatistics - University of Nantes - France
* EA 4275 "Biostatistics, Clinical Research and Subjective Measures in Health Sciences"
* jean-benoit.hardouin@univ-nantes.fr
*
* News about this program : http://www.anaqol.org
* FreeIRT Project : http://www.freeirt.org
*
* Copyright 2003-2012 Jean-Benoit Hardouin
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


program define raschtest,eclass
syntax varlist(min=1 numeric) [if] [in] , ID(varname) [HTML(string) MEANdiff DIRsave(string) FILESsave nodraw PAUse REPlace ICC INFormation SPLITtests FITgraph Method(string) group(numlist >0 ascen) AUTOGroup Test(string) q2 GENLT(string) GENSCOre(string) GENFIT(string) GRAph COMp(varname) dif(varlist) time TRace Details nold iterate(int 200)  DIFFiculties(string) COVariates(string) GENRes(string)]

local nbitems:word count `varlist'
if "`method'"=="" {
   local method "cml"
}
else {
   local method=lower("`method'")
}
if "`test'"=="" {
   local test "R"
}
else {
   local test=upper("`test'")
}
if "`dirsave'"!="" {
   local dirsavev8 "dirsave(`dirsave')"
}
if "`method'"!="" {
   local methodv8 "method(`method')"
}
if "`test'"!="" {
   local testv8 "test(`test')"
}
if "`group'"!="" {
   local groupv8 "group(`group')"
}
if "`genlt'"!="" {
   local genltv8 "genlt(`genlt')"
}
if "`genscore'"!="" {
   local genscorev8 "genscore(`genscore')"
}
if "`genres'"!="" {
   local gensresv8 "genres(`genres')"
}
if "`genfit'"!="" {
   local genfitv8 "genfit(`genfit')"
}
if "`comp'"!="" {
   local compv8 "comp(`comp')"
}
if "`dif'"!="" {
   local difv8 "dif(`dif')"
}
if "`iterate'"!="" {
   local iteratev8 "iterate(`iterate')"
}
if "`difficulties'"!="" {
   local difficultiesv8 "difficulties(`difficulties')"
}
if "`covariates'"!="" {
   local covariatesv8 "covariates(`covariates')"
}

raschtestv7 `varlist' `if' `in' , id(`id') html(`html') `meandiff' `dirsavev8' `filessave' `nodraw' `pause' `replace' `icc' `information' `splittests' `fitgraph' `methodv8' `groupv8' `autogroup' `testv8' `q2' `genltv8' `genscorev8' `genresv8' `genfitv8' `graph' v8 `compv8' `difv8' `time' `trace' `details' `ld' `iteratev8' `difficultiesv8' `covariatesv8'

/***********************************************************************************************************
RETURN
************************************************************************************************************/

ereturn clear
if `nbitems'>=3 {
	if "`method'"=="cml" {
	        if "`test'"!="none" {
                   tempname AndersenZv8
                   matrix `AndersenZv8'=r(AndersenZ)
                   ereturn matrix AndersenZ=`AndersenZv8'
                }
	        if "`dif'"!="" {
                   tempname DIFv8
                   matrix `DIFv8'=r(DIF)
                   ereturn matrix DIF=`DIFv8'
                }
                tempname cllv8
		scalar `cllv8'=r(cll)
                ereturn scalar cll=`cllv8'

	}
	if "`test'"!="NONE" {
	        tempname itemFitv8 globalFitv8
	        matrix `itemFitv8'=r(itemFit)
	        matrix `globalFitv8'=r(globalFit)
         	ereturn matrix itemFit=`itemFitv8'
		ereturn matrix globalFit=`globalFitv8'
	}
}

if "`method'"!="cml" {
        tempname sigmav8 sesigmav8
        local `sigmav8'=`r(sigma)'
        local `sesigmav8'=`r(sesigma)'
	ereturn scalar sigma=``sigmav8''
	ereturn scalar sesigma=``sesigmav8''
}

tempname betav8 Varbetav8 thetav8 Varthetav8 llv8 AICv8
matrix `betav8'=r(beta)
matrix `Varbetav8'=r(Varbeta)
ereturn matrix beta=`betav8'
ereturn matrix Varbeta=`Varbetav8'
matrix `thetav8'=r(theta)
matrix `Varthetav8'=r(Vartheta)
ereturn matrix theta=`thetav8'
ereturn matrix Vartheta=`Varthetav8'
scalar `llv8'=`r(ll)'
scalar `AICv8'=`r(AIC)'
ereturn scalar ll=`llv8'
ereturn scalar AIC=`AICv8'
ereturn scalar Zcomp=r(Zcomp)
ereturn scalar pZcomp=r(pZcomp)


if "`method'"=="mml" {
   local psi=r(PSI)
   local psiadj=r(PSIadj)
   ereturn scalar PSI=`psi'
   ereturn scalar PSIadj=`psiadj'
}
if "`covariates'"!="" {
   tempname betacovariates Vbetacovariates zcovariates pcovariates
   matrix `betacovariates'=r(betacovariates)
   matrix `Vbetacovariates'=r(Vbetacovariates)
   matrix `zcovariates'=r(zcovariates)
   matrix `pcovariates'=r(pcovariates)

   ereturn matrix betacovariates=`betacovariates'
   ereturn matrix Vbetacovariates=`Vbetacovariates'
   ereturn matrix zcovariates=`zcovariates'
   ereturn matrix pcovariates=`pcovariates'
}




return clear

end
