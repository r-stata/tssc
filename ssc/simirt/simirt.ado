*! version 3.5 May 16, 2013
*! Jean-Benoit Hardouin
************************************************************************************************************
* Simirt: Simulation of dichotomous or polytomous data following an IRT model (Rasch model,
* OPLM, Birnbaum model, 3-PLM, 4-PLM, 5-PAM, RSM,PCM)
*
* Version 1 : May 9, 2005 (Jean-Benoit Hardouin)
* Version 1.1 : December 8, 2005 (Jean-Benoit Hardouin) /*group and deltagroup options*/
* Version 2 : January 20, 2006 (Jean-Benoit Hardouin) /*Rating Scale model*/
* Version 2.1 : Februar 2, 2006 (Jean-Benoit Hardouin) /*Threshold variables*/
* Version 2.2 : Februar 8, 2006 (Jean-Benoit Hardouin) /*Correction of an error with the RSM model*/
* Version 2.3 : October 22, 2006 (Jean-Benoit Hardouin) /*The "real" rating scale model*/
* Version 2.4 : July 7, 2008 (Jean-Benoit Hardouin) /*Title for the graphs*/
* Version 3 : October 14, 2008 (Jean-Benoit Hardouin) /*3 dimensions + correction for the mu vector*/
* Version 3.1 : December 11, 2008 (Jean-Benoit Hardouin) /*remove an useless output*/
* Version 3.2 : November 26, 2009 (Jean-Benoit Hardouin) /*covmatrix option*/
* Version 3.3 : October 25, 2011 (Jean-Benoit Hardouin) /*pcm option*/
* Version 3.4 : May 7, 2013 (Jean-Benoit Hardouin) /*Minor corrections, norandom option*/
* Version 3.5 : May 16, 2013 (Jean-Benoit Hardouin) /*Minor corrections*/
*
* Jean-benoit Hardouin, phD, Assistant Professor
* Team of Biostatistics, Pharmacoepidemiology and Subjective Measures in Health Sciences  (UPRES EA 4275 SPHERE)
* University of Nantes - Faculty of Pharmaceutical Sciences
* France
* jean-benoit.hardouin@univ-nantes.fr
*
* News about this program : http://www.anaqol.org
*
* Copyright 2005-2006, 2008-2009, 2011, 2013 Jean-Benoit Hardouin
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
program define simirt , rclass
version 8.0
syntax  [, NBObs(integer 2000) Dim(string) MU(string) COV(string) COVMatrix(string) DISc(string) DIFf(string) PMIN(string) PMAX(string) ACC(string) clear STOre(string) REPlace PREFix(string) DRAW GRoup(real 0) noRANDom DELtagroup(real 0) rsm1(string) rsm2(string)  THReshold TITle(string) PCM(string) id(string)]


/********************************************************************************
TESTS
********************************************************************************/


if `group'<0|`group'>1 {
   di in red "{p}The {hi:group} option defines a probability. The values defined by this option must be greater (or equal) to 0 and lesser (or equal) to 1.{p_end}"
   error 198
   exit
}

if "`clear'"==""&"`store'"=="" {
   di in red "You must use at least one of these two options: clear and/or store."
   error 198
   exit
}

if "`dim'"!="" {
   local nbdim:word count `dim'
   if `nbdim'>2&"`covmatrix'"==""  {
      di in red "You can simulate data with one or two dimensions, and you have indicated `nbdim' dimensions in the {hi:dim} option. Please correct it."
      error 198
      exit
   }
   if "`covmatrix'"!="" {
      local nbrowcovm=rowsof(`covmatrix')
      if `nbdim'!=`nbrowcovm'  {
         di in red "{p 0 0 0}You define `nbdim' dimension(s) with the {cmd:dim} option and `nbrowcovm' dimension(s) with the {cmd:covmatrix} option. Please correct that."
         error 198
         exit
      }
   }
   local nbitems=0
   forvalues d=1/`nbdim' {
      local dim`d':word `d' of `dim'
      local nbitems=`nbitems'+`dim`d''
   }
   local dim=`nbdim'

   if "`diff'"!="" {
      local nbdiff:word count `diff'
      local tmp:word 1 of `diff'
      if "`tmp'"=="gauss"|"`tmp'"=="uniform" {
         local typediff values
      }
      else if `nbdiff'!=`nbitems' {
            di in red "You have indicated a number of difficulty parameters ({hi:diff} option) different of the number of items to simulate ({hi:dim} option). Please correct these options."
            error 198
            exit
      }
   }
   else if "`diff'"=="" {
      local diff gauss
      forvalues d=1/`dim' {
         local diff `diff' 0 1
      }
      local typediff gauss
      local nbdiff:word count `diff'
   }
}
else if "`dim'"==""{
   if "`diff'"==""&"`pcm'"=="" {
      di in red "{p 0 0 0}You must indicate the number of items to simulate with the {hi:dim}, the {hi:pcm} or the {hi:diff} option(s)."
      error 198
      exit
   }
   else if "`covmatrix'"!= "" {
      local nbrowcovm=rowsof(`covmatrix')
      if `nbrowcovm'>1  {
         di in red "{p 0 0 0}You have define `nbrowcovm' dimensions with the {hi:covmatrix} option, but you do not affect each item to a specific dimension using the {hi:dim} option. Please define the {hi:dim} option."
         error 198
         exit
      }
   }
   else if "`pcm'"!="" {
      local nbitems=rowsof(`pcm')
      local dim=1
      local dim1=`nbitems'
   }
   else {
      local nbdiff:word count `diff'
      local nbitems=`nbdiff'
      local dim=1
      local dim1=`nbitems'
   }
}

if (`group'!=0|`deltagroup'!=0)&`dim'!=1 {
   di in red "The {hi:group} and the {hi:deltagroup} options are available only with unidimensional simulated data."
   error 198
   exit
}

if "`prefix'"=="" {
   local prefix item
}

local nbprefix:word count `prefix'
if `nbprefix'!=`dim'&`nbprefix'!=1 {
   di in red "{p 0 0 0}The {hi:prefix} option is incorrect because the number of defined prefixes (`nbprefix') is different of the number of dimensions (`dim'). Please correct it."
   error 198
   exit
}
if `nbprefix'==`dim' {
   forvalues d=1/`dim' {
      local prefix`d':word `d' of `prefix'
   }
}
else {
   forvalues d=1/`dim' {
      local tmp:word `d' of A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
      local prefix`d' `prefix'`tmp'
   }
}
*set trace on
if "`covmatrix'"=="" {
   local nbcov:word count `cov'

   if `dim'==1&`nbcov'>1 {
      di in red "You simulate one dimension. You must indicate only the variance of the simulated latent trait in the {hi:cov} option."
      error 198
      exit
   }
   else if `dim'==2&`nbcov'!=3&`nbcov'>0 {
      di in red "You simulate two dimensions. You must indicate exactly 3 values in the {hi:cov} option (Variance of the first simulated latent trait, Variance of the second simulated latent trait, Covariance between the two simulated latent traits)."
      error 198
      exit
   }
   else if `nbcov'==0 {
      if `dim'==1 {
         local cov "1"
      }
      else if `dim'==2 {
         local cov "1 1 0"
      }
      local nbcov:word count `cov'
   }

   if `nbcov'==1 {
      if `cov'<0 {
         di in red "The variance of your latent trait can not be negative. Please correct your {hi:cov} option."
         error 198
      }
   }
   else if `nbcov'==3 {
      local cov1:word 1 of `cov'
      local cov2:word 2 of `cov'
      local cov3:word 3 of `cov'
      local rho=`cov3'/sqrt(`cov1'*`cov2')
      if `cov1'<0|`cov2'<0|`rho'<-1|`rho'>1 {
         di in red "Your covariance matrix defined by the {hi:cov} option is not correct. Please correct it."
         error 198
         exit
      }
   }
   tempname covmatrix2
   if `dim'==1 {
      matrix `covmatrix2'=(`cov')
   }
   else if `dim'==2 {
      matrix `covmatrix2'=(`cov1' , `cov3' \ `cov3' , `cov2')
   }
   local covmatrix `covmatrix2'
   *matrix list `covmatrix2'
}

local nbmu:word count `mu'
if `nbmu'!=`dim'&`nbmu'!=0 {
   di in red "You must indicate as many values in the {hi:mu} option as the number of dimension(s) (`dim')"
   error 198
   exit
}
local nbdisc:word count `disc'
if `nbdisc'!=`nbitems'&`nbdisc'!=0 {
   di in red "You must indicate as many values in the {hi:disc} option as items defined by the {hi:dim} and the {hi:diff} options (`nbitems')"
   error 198
   exit
}
local nbpmin:word count `pmin'
if `nbpmin'!=`nbitems'&`nbpmin'!=0 {
   di in red "You must indicate as many values in the {hi:pmin} option as items defined by the {hi:dim} and the {hi:diff} options (`nbitems')"
   error 198
   exit
}
local nbpmax:word count `pmax'
if `nbpmax'!=`nbitems'&`nbpmax'!=0 {
   di in red "You must indicate as many values in the {hi:pmax} option as items defined by the {hi:dim} and the {hi:diff} options (`nbitems')"
   error 198
   exit
}
local nbacc:word count `acc'
if `nbacc'!=`nbitems'&`nbacc'!=0 {
   di in red "You must indicate as many values in the {hi:acc} option as items defined by the {hi:dim} and the {hi:diff} options (`nbitems')"
   error 198
   exit
}

if ("`threshold'"!="")&("`disc'"!=""|"`pmin'"!=""|"`pmax'"!=""|"`acc'"!="") {
   di in red "If you use the {hi:threshold} option, you cannot define the {hi:disc}, {hi:pmin}, {hi:pmax} or {hi:acc} options"
   error 198
   exit
}
if ("`rsm1'"!=""|"`rsm2'"!="")&("`disc'"!=""|"`pmin'"!=""|"`pmax'"!=""|"`acc'"!="") {
   di in red "If you use the {hi:rsm1} and/or {hi:rsm2} option(s), you cannot define the {hi:disc}, {hi:pmin}, {hi:pmax} or {hi:acc} options"
   error 198
   exit
}
if "`rsm2'"!=""&`dim'==1 {
   di in red "You cannot define the {hi:rsm2} option if you simulate only one dimension"
   error 198
   exit
}
if "`id'"=="" {
    local id="id"
}

preserve

tempfile saveraschbin
capture qui save `saveraschbin'




/********************************************************************************
PARAMETERS
********************************************************************************/


local hour=real(substr("$S_TIME",1,2))
local min=real(substr("$S_TIME",4,2))
local sec=real(substr("$S_TIME",7,2))
local jour=real(substr("$S_DATE",1,2))




if "$seed"!="" {
   global seed2=int($seed)
}
else {
   global seed2=0
}
global seed=$seed2+256484+`sec'*1000000+`min'*10000+`hour'*100+`jour'
while $seed>2^31-1 {
   global seed=int($seed/231)
}
qui set seed $seed

if "`typediff'"=="uniform" {
      if `nbdiff'==`=`dim'*2+1' {
         local min`d':word `=(`d'-1)*2+2' of `diff'
         local max`d':word `=(`d'-1)*2+3' of `diff'
      }
      else if `nbdiff'==1 {
         local min`d'=-2
         local max`d'=2
      }
      else {
         di in red "Your {hi:diff} option is uncorrect. Please correct it."
         exit
      }
      local diff
      forvalues d=1/`dim' {
         forvalues i=1/`dim`d'' {
            local diff `diff' `=`min`d''+(`max`d''-`min`d'')*`i'/(`dim`d''+1)'
         }
      }
}
*set trace on
if "`typediff'"=="gauss" {
   if `nbdiff'==`=`dim'*2+1' {
         forvalues d=1/`dim' {
            local mean`d':word `=(`d'-1)*2+2' of `diff'
            local var`d':word `=(`d'-1)*2+3' of `diff'
         }
   }
   else if `nbdiff'==1 {
         forvalues d=1/`dim' {
            local mean`d'=0
            local var`d'=1
         }
   }
   else {
        di in red "Your {hi:diff} option is uncorrect. Please correct it."
        error 198
        exit
   }
   local diff
   forvalues d=1/`dim' {
         forvalues i=1/`dim`d'' {
            local tmp=invnorm(`i'/(`dim`d''+1))*sqrt(`var`d'')+`mean`d''
            local diff `diff' `tmp'
         }
   }
}
*set trace off

forvalues d=1/`dim' {
   if "`rsm`d''"!="" {
      local nbrsm`d':word count `rsm`d''
      forvalues i=2/`=`nbrsm`d''+1' {
         local rsm`d'`i':word `=`i'-1' of `rsm`d''
         if "`threshold'"!=""&`rsm`d'`i''<0 {
            di in red "With the {hi:threshold} option, the numbers defined in the {hi:rsm1} and {hi:rsm2} options must be positive."
            error 198
            exit
         }
      }
   }
}
if "`pcm'"!="" {
   local nbmodas=colsof(`pcm')
   forvalues j=1/`nbitems' {
      local pcmpj`j'k0=-999999999999999
      forvalues k=1/`nbmodas' {
         local pcmpj`j'k`k'=`pcm'[`j',`k']
         local tmp=`k'-1
         if "`threshold'"!=""&`pcmpj`j'k`k''<`pcmpj`j'k`tmp'' {
            di in red "With the {hi:threshold} option, the difficulties of a given item must increase."
            error 198
            exit
         }
      }
   }
}

tempname matmu matcov matdiff matdisc matpmin matpmax matacc
matrix define `matdiff'=J(`nbitems',1,0)
matrix define `matdisc'=J(`nbitems',1,0)
matrix define `matpmin'=J(`nbitems',1,0)
matrix define `matpmax'=J(`nbitems',1,0)
matrix define `matacc'=J(`nbitems',1,0)
matrix define `matmu'=J(`dim',1,0)
matrix define `matcov'=J(`=(`dim'+1)*`dim'/2',1,0)

if "`pcm'"=="" {
   forvalues i=1/`nbitems' {
      local tmp:word `i' of `diff'
      matrix `matdiff'[`i',1]=`tmp'
      if `nbdisc'!=0 {
         local tmp:word `i' of `disc'
         matrix `matdisc'[`i',1]=`tmp'
      }
      else {
         matrix `matdisc'[`i',1]=1
      }
      if `nbpmin'!=0 {
         local tmp:word `i' of `pmin'
         matrix `matpmin'[`i',1]=`tmp'
      }
      else {
         matrix `matpmin'[`i',1]=0
      }
      if `nbpmax'!=0 {
         local tmp:word `i' of `pmax'
         matrix `matpmax'[`i',1]=`tmp'
      }
      else {
         matrix `matpmax'[`i',1]=1
      }
      if `nbacc'!=0 {
         local tmp:word `i' of `acc'
         matrix `matacc'[`i',1]=`tmp'
      }
      else {
         matrix `matacc'[`i',1]=1
      }
   }
}

if "`covmatrix'"=="" {
   if `nbcov'==3|`nbcov'==1 {
      local tmp:word 1 of `cov'
      matrix `matcov'[1,1]=`tmp'
      if `nbcov'==3&`dim'==2 {
         local tmp:word 2 of `cov'
         matrix `matcov'[2,1]=`tmp'
         local tmp:word 3 of `cov'
         matrix `matcov'[3,1]=`tmp'
      }
   }
}
else if 6==9{
   matrix `matcov'[1,1]=1
   if `dim'==2 {
      matrix `matcov'[2,1]=1
      matrix `matcov'[3,1]=0
   }
}
else if "`covmatrix'"!="" {
   matrix `matcov'=`covmatrix'
}
if (`nbmu'==`dim') {
*   local tmp:word 1 of `mu'
*   matrix `matmu'[1,1]=`tmp'
   forvalues d=1/`dim' {
      local tmp:word `d' of `mu'
      matrix `matmu'[`d',1]=`tmp'
   }
*   if `dim'>1 {
*      local tmp:word 2 of `mu'
*      matrix `matmu'[2,1]=`tmp'
*   }
}
if `dim'==2 {
   local corr=`matcov'[3,1]/sqrt(`matcov'[1,1]*`matcov'[2,1])
}

/********************************************************************************
ITEMS CHARACTERISTIC CURVES
********************************************************************************/


if "`draw'"!="" {
   *set trace on
   drop _all
   qui set obs 2001
   qui gen lt1=_n
   qui replace lt1=(lt1-1001)/1000*4*sqrt(`covmatrix'[1,1])+`matmu'[1,1]
   label variable lt1 "Latent trait"
   local dess


   if "`rsm1'"==""&"`pcm'"=="" {
      if "`title'"=="" {
         local title2="Item Characteristics Curves of the items"
      }
      else {
         local title2="`title'"
      }
      forvalues i=1/`dim1' {
         if "`threshold'"=="" {
            qui gen `prefix1'`i'=`matpmin'[`i',1]+(`matpmax'[`i',1]-`matpmin'[`i',1])*(1/(1+exp(-`matdisc'[`i',1]*(lt1-`matdiff'[`i',1]))))^(`matacc'[`i',1])
         }
         else {
            qui gen `prefix1'`i'=lt1>`matdiff'[`i',1]
          }
         local dess `dess' (line `prefix'`i' lt1)
      }
      graph twoway `dess' , ylabel(0(.25)1) legend(off) ytitle("Probability of a positive response" title"") title("`title2'")
   }
   else if "`pcm'"==""{
      forvalues i=1/`dim1' {
         if "`title'"=="" {
            local title2="Item `i'"
         }
         else {
            local title2="`title'"
         }
         local dess
         local tau0=0
         local tau1=`matdiff'[`i',1]
         local D "1+exp(lt`d'-`tau1')"
         forvalues k=2/`=`nbrsm1'+1' {
            local tau`k'=`tau`=`k'-1''+`matdiff'[`i',1]+`rsm1`k''
            local D "`D'+exp(`k'*lt1-`tau`k'') "
         }
         forvalues k=`=`nbrsm1'+1'(-1)0 {
            tempname prob`k'
            qui gen `prob`k''=exp(`k'*lt1-`tau`k'')/(`D')
            local dess `dess' (line `prob`k'' lt1)
            label variable `prob`k'' "`k'"
         }
          graph twoway `dess' , ylabel(0(.25)1) legend(on) ytitle("Probability of response to each modality") title("`title2'") name(item`i',replace)
      }
   }
   else if "`pcm'"!=""{
      forvalues j=1/`dim1' {
         if "`title'"=="" {
            local title2="Item `j'"
         }
         else {
            local title2="`title'"
         }
         local dess
         local tauj`j'k0=0
         forvalues k=1/`nbmodas' {
            local tauj`j'k`k'=`tauj`j'k`=`k'-1''+`matdiff'[`j',`k']
            local D "`D'+exp(`k'*lt1-`tauj`j'k`k'') "
         }
         forvalues k=`=`nbrsm1'+1'(-1)0 {
            tempname prob`k'
            qui gen `prob`k''=exp(`k'*lt1-`tauj`j'k`k'')/(`D')
            local dess `dess' (line `prob`k'' lt1)
            label variable `prob`k'' "`k'"
         }
          graph twoway `dess' , ylabel(0(.25)1) legend(on) ytitle("Probability of response to each modality") title("`title2'") name(item`i',replace)
      }
   }
}


/********************************************************************************
SIMULATION
********************************************************************************/


drop _all
qui set obs `nbobs'
gen `id'=_n
local names
forvalues d=1/`dim' {
  qui gen x`d'=invnorm(uniform())
  qui compress
  local names `names' lt`d'
}
/*mkmat lt1-lt`dim' , matrix(lt)
matrix Chol=cholesky(corr(`covmatrix'))
*matrix list lt
*matrix list Chol
matrix lt=lt*Chol'
matrix colnames lt=`names'

*matrix list lt
drop _all
qui svmat lt*/

matrix Chol=cholesky(corr(`covmatrix'))
forvalues d=1/`dim' {
   qui gen lt`d'=0
   forvalues i=1/`d' {
      qui replace lt`d'=lt`d'+Chol[`d',`i']*x`i'
   }
   qui compress
}
qui drop x*
forvalues d=1/`dim' {
   qui replace lt`d'=lt`d'*sqrt(`covmatrix'[`d',`d'])+`matmu'[`d',1]
   qui compress
}

if `dim'==1&`group'!=0 {
   if "`random'"=="" {
       qui gen group=uniform()<`group'
   }
   else {
       qui gen group=`id'<=`group'*`nbobs'
   }
   qui replace lt1=lt1+`deltagroup'*(1-`group') if group==1
   qui replace lt1=lt1-`deltagroup'*`group' if group==0
   qui compress
}

di in gr "Number of individuals: " in ye `nbobs'
di

if "`threshold'"==""&"`rsm1'"=="" {
   local line di in gr "{hline 75}"
}
else {
   local line di in gr "{hline 27}"
}

if "`threshold'"==""&"`rsm1'"==""&"`pcm'"=="" {
   `line'
   di _col(1) in gr "Items" _col(18) "Difficulty" _col(34) "Discr." _col(45) "Pmin" _col(58) "Pmax" _col(73) "Acc"
}
else {
   `line'
   di _col(1) in gr "Items" _col(18) "Difficulty"
}
local dim0=0

*set trace on

local deb1=1
local fin1=`dim1'

forvalues d=1/`dim' { /* FOREACH DIMENSION*/
   local deb`d'=`fin`=`d'-1''+1
   local fin`d'=`deb`d''+`dim`d''-1
   `line'
   local p=`d'-1
   local q=1
   forvalues i=`deb`d''/`fin`d'' { /*FOREACH ITEM*/
      *set trace on
      *local q=`i'-`dim`p''*/
      qui compress
      if "`pcm'"=="" {
         tempname prob`=`nbrsm`d''+2'
         qui gen `prob`=`nbrsm`d''+2''=0
         local tau1=`matdiff'[`i',1]
         local D "1+exp(lt`d'-`tau1')"
         forvalues k=2/`=`nbrsm`d''+1' {
            local tau`k'=`tau`=`k'-1''+`matdiff'[`i',1]+`rsm`d'`k''
            *di "tau`k'=`tau`k''"
            local D "`D'+exp(`k'*lt`d'-`tau`k'') "
         }
      }
      else {
         tempname prob`=`nbmodas'+1'
         qui gen `prob`=`nbmodas'+1''=0
         local tau1=`pcm'[`i',1]
         local D "1+exp(lt`d'-`tau1')"
         forvalues k=2/`nbmodas' {
            local tau`k'=`tau`=`k'-1''+`pcm'[`i',`k']
            *di "tau`k'=`tau`k''"
            local D "`D'+exp(`k'*lt`d'-`tau`k'') "
         }
      }
      if "`threshold'"==""/*&"`rsm1'"==""*/ {
         if "`rsm`d''"==""&"`pcm'"=="" {
            tempname prob1
            qui gen `prob1'=`prob`=`nbrsm`d''+2''+`matpmin'[`i',1]+(`matpmax'[`i',1]-`matpmin'[`i',1])*(1/(1+exp(-`matdisc'[`i',1]*(lt`d'-`matdiff'[`i',1]))))^(`matacc'[`i',1])
            qui compress
         }
         else if "`rsm`d''"!=""{
            forvalues k=`=`nbrsm`d''+1'(-1)1 {
               tempname prob`k'
               qui gen `prob`k''=exp(`k'*lt`d'-`tau`k'')/(`D')+`prob`=`k'+1''
               qui compress
            }
         }
         else if "`pcm'"!="" {
            forvalues k=`nbmodas'(-1)1 {
               tempname prob`k'
               qui gen `prob`k''=exp(`k'*lt`d'-`tau`k'')/(`D')+`prob`=`k'+1''
               qui compress
            }
         }
         qui gen `prefix`d''`q'=0
         if "`rsm1'"==""&"`pcm'"=="" {
            di _col(1) in gr "`prefix`d''`q'" _col(20) in ye %8.4f `matdiff'[`i',1] _col(32) %8.4f `matdisc'[`i',1] _col(44) %6.4f `matpmin'[`i',1] _col(56) %6.4f `matpmax'[`i',1] _col(68) %8.4f `matacc'[`i',1]
         }
         else if "`rsm1'"!="" {
            di _col(1) in gr "`prefix`d''`q'" _col(20) in ye %8.4f `matdiff'[`i',1]
         }
         else if "`pcm'"!="" {
            forvalues k=1/`nbmodas' {
               di _col(1) in gr "`prefix`d''`q'_`k'" _col(20) in ye %8.4f `pcm'[`i',`k']
            }
         }
         tempname uni
         qui gen `uni'=uniform()
         qui compress
         if "`pcm'"=="" {
            forvalues k=1/`=`nbrsm`d''+1' {
               qui replace `prefix`d''`q'=`k' if `uni'<=`prob`k''
               qui drop `prob`k''
               qui compress
            }
         }
         else {
            forvalues k=1/`nbmodas' {
               qui replace `prefix`d''`q'=`k' if `uni'<=`prob`k''
               qui drop `prob`k''
               qui compress
            }
         }
      }
      else { /*if "`threshold'"!=""*/
	     if "`pcm'"=="" {
			 di _col(1) in gr "`prefix`d''`q'" _col(20) in ye %8.4f `matdiff'[`i',1]
			 qui gen `prefix`d''`q'=lt`d'>`matdiff'[`i',1]
			 qui compress
			 forvalues k=1/`=`nbrsm`d''+1' {
				qui replace `prefix`d''`q'=`k' if lt`d'>=`tau`k''
				qui compress
			 }
	     }
		 else {
		     qui gen `prefix`d''`q'=lt`d'>`pcm'[`i',1]
             forvalues k=1/`nbmodas' {
				 di _col(1) in gr "`prefix`d''`q'_`k'" _col(20) in ye %8.4f `pcm'[`i',`k']
		         qui replace `prefix`d''`q'=`k' if lt`d'>`pcm'[`i',`k']
				 qui compress
			 }
		 }
      }
      local q=`q'+1
   }
   forvalues k=2/`=`nbrsm`d''+1' {
      di _col(1) in gr "tau`k'" _col(20) in ye %8.4f `rsm`d'`k''
   }
}
`line'
di
*set trace on


forvalues d=1/`dim' {
   qui su lt`d'
   local var_`d'=r(Var)
   local mean_`d'=r(mean)
   forvalues l=`=`d'+1'/`dim' {
       qui corr lt`d' lt`l' ,cov
       local cov_`d'_`l'=r(cov_12)
       return scalar cov_`d'_`l'=`cov_`d'_`l''
   }
   return scalar mean_`d'=`mean_`d''
   return scalar var_`d'=`var_`d''
}
forvalues d=1/`dim' {
   forvalues l=`=`d'+1'/`dim' {
       local corr_`d'_`l'=`cov_`d'_`l''/sqrt(`var_`d''*`var_`l'')
       return scalar corr_`d'_`l'=`corr_`d'_`l''
   }
}


if `dim'==1&`group'!=0 {
   qui su lt1 if group==0
   local mean_0=r(mean)
   qui su lt1 if group==1
   local mean_1=r(mean)
   local delta=`mean_1'-`mean_0'
}

return scalar nbobs=`nbobs'
tempname matcorr
*matrix list `matcov'
matrix `matcorr'=corr(`matcov')

di in gr "{hline 50}"
di _col(1) in gr  "Latent trait" _c
if `dim'==2 {
   di in gr "s"_c
}
di in gr _col(30) "Expected" _col(42) "Observed"
di in gr "{hline 50}"
forvalues i=1/`dim' {
   di _col(1) in gr "Mean(lt`i')" _col(30) in ye %8.4f `matmu'[`i',1] _col(42) %8.4f `mean_`i''
   di _col(1) in gr "Variance(lt`i')" _col(30) in ye %8.4f `matcov'[`i',`i'] _col(42) %8.4f `var_`i''
   forvalues d=`=`i'+1'/`dim' {
           di _col(1) in gr "Covariance `i'_`d'" _col(30) in ye %8.4f `matcov'[`i',`d'] _col(42) %8.4f `cov_`i'_`d''
           di _col(1) in gr "Correlation `i'_`d'" _col(31) in ye %7.4f `matcorr'[`i',`d'] _col(43) %7.4f `corr_`i'_`d''
        }
   di in gr "{hline 50}"
}
if `dim'==1&`group'!=0 {
   di _col(1) in gr "Mean(lt1) group 0" _col(30) in ye %8.4f `matmu'[1,1]-`deltagroup'*`group' _col(42) %8.4f `mean_0'
   di _col(1) in gr "Mean(lt1) group 1" _col(30) in ye %8.4f `matmu'[1,1]+`deltagroup'*(1-`group') _col(42) %8.4f `mean_1'
   qui count if group==1
   local prop=r(N)/`nbobs'
   di _col(1) in gr "Proportion group 1" _col(30) in ye %8.4f `group' _col(42) %8.4f `prop'
   di in gr "{hline 50}"
}

/********************************************************************************
CLEAR AND/OR STORE
********************************************************************************/
qui compress

if "`clear'"!="" {
   restore, not
   preserve
}
if "`store'"!="" {
   save "`store'",`replace'
}
if "`clear'"=="" {
   use "`saveraschbin'",replace
}
end
