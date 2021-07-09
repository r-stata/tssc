*! Version 2.17 10July2019
*! Jean-Benoit Hardouin
************************************************************************************************************
* Stata program : clv
* Clustering of variables around latent variables
* Version 2.14 : May 20th, 2010 /*dim and std options for biplots*/
*
* Historic
* Version 1 (2005-06-11): Jean-Benoit Hardouin
* Version 1.1 (2005-07-07): Jean-Benoit Hardouin /*small bug in the consolidation process with cluster of only one variable*/
* Version 1.2 (2005-07-08): Jean-Benoit Hardouin /*Bug in the consolidation procedure when there is negative correlation*/
* Version 2 (2005-09-03): Jean-Benoit Hardouin /*Horizontal dendrograms (with Stata 9)*/
* Version 2.1 (2005-09-08): Jean-Benoit Hardouin /*More flexibility to abbreviate the names of the variables (with Stata 9)*/
* Version 2.1.1 (2005-09-08): Jean-Benoit Hardouin /*Integration of some requests of Ronan Conroy*/
* Version 2.1.2 (2005-09-08): Jean-Benoit Hardouin /*Possibility to give a title and an X/Y caption*/
* Version 2.2 (2005-09-11): Jean-Benoit Hardouin /*Kernel option*/
* Version 2.3 (2005-09-12): Jean-Benoit Hardouin /*Polychoric option*/
* Version 2.4 (2005-09-13): Jean-Benoit Hardouin /*v2 option*/
* Version 2.5 (2005-09-21): Jean-Benoit Hardouin /*corrections*/
* Version 2.6 (2005-10-02): Jean-Benoit Hardouin /*centroid method, biplot*/
* Version 2.7 (2005-10-06): Jean-Benoit Hardouin /*return, multiple graphs, polychoric+consolidation*/
* Version 2.8 (2005-10-06): Jean-Benoit Hardouin /*fweights*/
* Version 2.9 (2006-01-26): Jean-Benoit Hardouin /*save the latent variables*/
* Version 2.10 (2006-07-10): Jean-Benoit Hardouin /*2nd order relative variation of the T criterion*/
* Version 2.11 (2006-10-09): Jean-Benoit Hardouin /*Size of the text in the dendrogram*/
* Version 2.12 (2006-12-01): Jean-Benoit Hardouin /*savedendro option*/
* Version 2.13 (2010-05-12): Jean-Benoit Hardouin /*corrections of bugs in KERNEL option and with METHOD(centroid)*/
* Version 2.14 (2010-05-20): Jean-Benoit Hardouin /*DIM and STD options for biplots*/
* Version 2.15 (2014-04-14): Jean-Benoit Hardouin /*save and use options*/
* Version 2.16 (2014-04-30): Jean-Benoit Hardouin, Bastien Perrot /*HTML option*/
* Version 2.17 (2019-07-10): Jean-Benoit Hardouin /*filesave and dirsave options*/
*
* Jean-benoit Hardouin, University of Nantes - Faculty of Pharmaceutical Sciences
* INSERM UMR 1246-SPHERE "Methods in Patient Centered Outcomes and Health Research", Nantes University, University of Tours
* jean-benoit.hardouin@univ-nantes.fr
*
* News about this program : http://anaqol.sphere-nantes.fr
*
* Copyright 2005-2006, 2010, 2014, 2019 Jean-Benoit Hardouin
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
program define clv,rclass
version 10
syntax [varlist(default=none)] [if] [in] [fweight] [, CUTnumber(int 40) bar CONSolidation(int 0) noDENdro SAVEDendro(string) noSTANDardized deltaT HORizontal SHOWcount ABBrev(int 14) TITle(string) CAPtion(string) KERnel(numlist) METHod(string) noBIPlot ADDvar genlv(string) replace TEXTSize(string) std dim(string) save(string) use(string) FILESave DIRSave(string)]
preserve
tempfile clvfile
tempvar id
gen `id'=_n
qui save `clvfile',replace
local matsize=c(matsize)
local none=0
if "`varlist'"==""&"`use'"=="" {
   capture confirm matrix r(vp)
   if _rc==0 {
      capture confirm matrix r(matclus)
      if _rc ==0 {
         local none=1
      }
   }
   if `none'==0 {
      di in red "You cannot use the {hi:clv} command without {hi:varlist} if you have not already run {hi:clv}"
      error 198
      exit
   }
}

if "`filesave'"!="" {
   if "`dirsave'"=="" {
      local dirsave `c(pwd)'
   }
   local fsb saving(`dirsave'//bar,replace)
   local fsd saving(`dirsave'//dendrogram,replace)
   local fsbi saving(`dirsave'//biplot,replace)
}
tempname matclus vp indexes

/*********TESTS**********/

if "`use'"!="" {
   local error=0
   capture matrix `vp'=`use'_vp
   if _rc!=0 {
      local error=_rc
   }
   capture matrix `matclus'=`use'_matclus
   if _rc!=0 {
      local error=_rc
   }
   local varlist $`use'_varlist
   local method $`use'_method
   local kernel $`use'_kernel
   if "`varlist'"==""|"`method'"=="" {
      local error=1
   }
   if `error'!=0 {
      di in red "You cannot use the {hi:use} option without a preliminary use of the {hi:save} option"
      error 198
      exit
   }
}
if `none'==1 {
   matrix `vp'=r(vp)
   matrix `matclus'=r(matclus)
   local varlist `r(varlist)'
   tokenize `varlist'
   local nbitems=rowsof(`matclus')
   if "`method'"!="" {
      di in green "The {hi:method} option can not be modified without specification of the varlist. {hi:method} is omitted."
   }
   local method `r(method)'
   local kernel `r(kernel)'
}
if "`method'"=="" {
   local method classical
}
if ("`method'"=="polychoric"|"`method'"=="polychoricv2")&"`standardized'"!="" {
   di in green "Initial variables are used with the {hi:polychoric} methods"
   di in green "But the procedure is based on the matrix of the polychoric correlations"
   di
}
if "`method'"!="classical"&"`method'"!="v2"&"`method'"!="centroid"&"`method'"!="polychoric"&"`method'"!="polychoricv2" {
   di in red "The {hi:method} `method' is unknown"
   error 198
   exit
}

tokenize `varlist'
local nbitems : word count `varlist'
marksample touse
qui keep if `touse'

local mat=max(`matsize',`=`nbitems'*2')
qui set matsize `mat'

if `nbitems'<3&`none'!=1 {
   di in red "You need at least 3 variables"
   error 198
   exit
}


/*******DEFINES THE LABELS AND STANDARDIZED THE VARIABLES (IF NECESSARY)*******/
forvalues i=1/`nbitems'{
   local label`i':variable label ``i''
   if "`label`i''"=="" {
      local label`i' ``i''
   }
   if "`method'"!="polychoric"&"`method'"!="polychoricv2" {
      qui su ``i'' [`weight'`exp']
      local mean=r(mean)
      if "`standardized'"=="" {
         local sd=r(sd)
      }
      else {
         local sd=1
      }
      qui replace ``i''=(``i''-`mean')/`sd'
   }
}

tempfile clvfiletmp
qui save `clvfiletmp',replace

qui su `1' [`weight'`exp']
local nbind=r(sum_w)


local cons=`consolidation'

/*COMPUTES THE TOTAL VARIANCE*/

if "`method'"!="polychoric"&"`method'"!="polychoricv2" {
   local totvar=0
   forvalues i=1/`nbitems' {
      qui su ``i'' [`weight'`exp']
      local totvar=`totvar'+`r(Var)'
   }
}
else {
   local totvar `nbitems'
}
local nbkerk=0
local nbkerg=0

/***** DEFINES THE KERNEL IF NECESSARY ********/

if "`kernel'"!="" {
   local nbkerg:word count `kernel'
   local fin0=0
   forvalues i=1/`nbkerg' {
      local nbi`i':word `i' of `kernel'
      local nbkerk=`nbkerk'+`nbi`i''
      local deb`i'=`fin`=`i'-1''+1
      local fin`i'=`deb`i''+`nbi`i''-1
      local list`i'
      forvalues j=`deb`i''/`fin`i'' {
         local list`i' `list`i'' ``j''
      }
   }
   tempname kerclus
   matrix `kerclus'=J(`=`nbkerk'-`nbkerg'',3,0)
   local ligne=1
   forvalues g=1/`nbkerg' {
       matrix `kerclus'[`ligne',1]=`nbitems'+`ligne'
       matrix `kerclus'[`ligne',2]=`deb`g''
       matrix `kerclus'[`ligne',3]=`deb`g''+1
       local clus`g'=`nbitems'+`ligne'
       local ligne=`ligne'+1
       if `nbi`g''>2 {
          forvalues i=2/`=`nbi`g''-1' {
             matrix `kerclus'[`ligne',1]=`nbitems'+`ligne'
             matrix `kerclus'[`ligne',2]=`deb`g''+`i'
             matrix `kerclus'[`ligne',3]=`nbitems'+`ligne'-1
             local clus`g'=`nbitems'+`ligne'
             local ligne=`ligne'+1
          }
      }
      local eigen2=0
   }
}
if `nbitems'<`nbkerk' {
   di in red "You cannot define more variables in the {hi:kernel} option than items in the {hi:varlist}"
   error 198
   exit
}

/*******DISPLAY THE FIRST RESULTS *******/

di
di in green "{hline 32}"
di in green "TOTAL VARIANCE: " in ye %16.5f `totvar'
di in green "NUMBER OF INDIVIDUALS: " in ye %9.0f `nbind'
di in green "METHOD:" in ye _col(`=33-length("`method'")') "`=upper("`method'")'"
di in green "{hline 32}"
di

if "`kernel'"!="" {
   forvalues i=1/`nbkerg' {
      di in green "The kernel numbered " in ye `clus`i'' in green " is composed of `nbi`i'' variables: " in ye "`list`i''"
      di
   }
}
else {
   local nbkerk=0
   local nbkerg=0
}

/******** CLASSIFICATION PROCEDURE*******/

tempname Ev
if `none'!=1 {
   matrix `matclus'=J(`nbitems',`nbitems',0)
   matrix `vp'=J(`=2*`nbitems'-1',12,0)
   matrix `indexes'=J(`nbitems',8,0)
   forvalues i=1/`nbitems' {
      matrix `matclus'[`i',1]=`i'
      if "`method'"!="polychoric"&"`method'"!="polychoric" {
         qui su ``i'' [`weight'`exp']
         matrix `vp'[`i',10]=r(Var)
      }
      else {
         matrix `vp'[`i',10]=1
      }
      matrix `vp'[`i',1]=`i'
      matrix `vp'[`i',2]=`nbitems'
      matrix `vp'[`i',8]=`totvar'
      matrix `vp'[`i',9]=100
   }
   matrix `vp'[`nbitems',5]=`nbitems'
   if "`method'"=="centroid" {
      local crit G
      di in green "{hline 101}"
      di in green _col(93) "2nd order"
      di in green _col(7) "Number of" _col(69) "`crit'" _col(71) "Explained" _col(82) "Relative" _col(94) "Relative"
      di in green "Step" _col(8) "clusters" _col(20) "Child 1" _col(33) "Child 2" _col(46) "Parent" _col(53) "`crit' value" _col(61) "variation" _col(72) "Variance"  _col(81) "Variation" _col(93) "Variation"
      di in green "{hline 101}"
   }
   else {
      local crit T
      di in green "{hline 111}"
      if "`method'"=="v2"|"`method'"=="polychoricv2" {
         di in green _col(84) "Maximal" _col(103) "2nd order"
      }
      else {
         di in green _col(84) "Current" _col(103) "2nd order"
      }
      di in green _col(7) "Number of" _col(69) "`crit'" _col(71) "Explained" _col(85) "Second" _col(93) "Relative" _col(104) "Relative"
      di in green "Step" _col(8) "clusters" _col(20) "Child 1" _col(33) "Child 2" _col(46) "Parent" _col(53) "`crit' value" _col(61) "variation" _col(72) "Variance" _col(81) "Eigenvalue" _col(92) "Variation" _col(103) "Variation"
      di in green "{hline 111}"
   }
   tempname threshold
   matrix `threshold'=J(`nbitems',3,0)
   forvalues i=1/`=`nbitems'-1' {
      local clus=`nbitems'+`i'
      local minegenval=999999
      local minegenval2=999999
      forvalues k=1/`=`clus'-1' {
         local list`k'
         local numlist`k'
         forvalues j=1/`clus' {
            if (`matclus'[`j',`i']==`k') {
               local list`k' `list`k'' ``j''
               local numlist`k' `numlist`k'' `j'
            }
         }
      }
      if `clus'>`nbitems'+`nbkerk'-`nbkerg' {
         if "`method'"=="centroid" {
            tempname centrj centrk diffjk
         }
         forvalues j=1/`clus' {
            local nblistj:word count `list`j''
            forvalues k=`=`j'+1'/`clus' {
               local nblistk:word count `list`k''
               if `nblistj'!=0&`nblistk'!=0 {
                  if "`method'"=="centroid" {
                     qui genscore `list`j'',score(`centrj') mean
                     qui su `centrj' [`weight'`exp']
                     local Varj=r(Var)
                     qui genscore `list`k'',score(`centrk') mean
                     qui su `centrk' [`weight'`exp']
                     local Vark=r(Var)
                     qui gen `diffjk'=`centrk'-`centrj'
                     qui su `diffjk' [`weight'`exp']
                     local Varjk=r(Var)
                     drop `centrj' `centrk' `diffjk'
                     local ev=(`nblistj'*`nblistk')/(`nblistj'+`nblistk')*`Varjk'
                     if `ev'<`minegenval' {
                        local minegenval=`ev'
                        local minj `j'
                        local mink `k'
                        local eigen=0
                        local eigen2=0
                     }
                  }
                  else {
                     if "`method'"=="classical"|"`method'"=="v2" {
                        qui pca `list`j'' `list`k'' [`weight'`exp'] ,cov
                        matrix `Ev'=e(Ev)
                     }
                     else if "`method'"=="polychoric"|"`method'"=="polychoricv2" {
                        qui polychoricpca `list`j'' `list`k'' [`weight'`exp']
                        matrix `Ev'=r(eigenvalues)
                     }
                     local lambda1=`Ev'[1,1]
                     local lambda2=`Ev'[1,2]
                     local ev=`vp'[`j',10]+`vp'[`k',10]-`lambda1'
                     local ev2=max(`vp'[`j',11],`vp'[`k',11],`lambda2')
                     if ("`method'"=="v2"|"`method'"=="polychoricv2")&`ev'<`minegenval' {
                        local minegenval=`ev'
                        local eigen=`lambda1'
                        local minj `j'
                        local mink `k'
                        local eigen2=`lambda2'
                     }
                     else if ("`method'"=="classical"|"`method'"=="polychoric")&`ev2'<`minegenval2' {
                        local minegenval=`ev'
                        local minegenval2=`ev2'
                        local eigen=`lambda1'
                        local minj `j'
                        local mink `k'
                        local eigen2=`ev2'
                     }
                  }
               }
            }
         }
      }
      else {
         local ligne=`clus'-`nbitems'
         local j=`kerclus'[`ligne',2]
         local k=`kerclus'[`ligne',3]
         if "`method'"!="centroid" {
            if "`method'"=="classical"|"`method'"=="v2" {
               qui pca `list`j'' `list`k'' [`weight'`exp'],cov
               matrix `Ev'=e(Ev)
            }
            else if "`method'"=="polychoric"|"`method'"=="polychoricv2"{
               qui polychoricpca `list`j'' `list`k''  [`weight'`exp']
               matrix `Ev'=r(eigenvalues)
            }
            local lambda1=`Ev'[1,1]
            local lambda2=`Ev'[1,2]
            local ev=`vp'[`j',10]+`vp'[`k',10]-`lambda1'
            local minegenval=`ev'
            local eigen=`lambda1'
            local minj `j'
            local mink `k'
            local eigen2=`lambda2'
         }
         else if "`method'"=="centroid" {
            local nblistj:word count `list`j''
            local nblistk:word count `list`k''
            tempname v1 v2 v12
            qui genscore `list`j'',score(`v1') mean
            qui genscore `list`k'',score(`v2') mean
            qui gen `v12'=`v1'-`v2'
            qui su `v12' [`weight'`exp']
            local varj=r(Var)
            local minegenval=(`nblistj'*`nblistk')/(`nblistj'+`nblistk')*`varj'
            local minj `j'
            local mink `k'
         }
      }
      if `minj'<=`nbitems' {
         local nomj=abbrev("``minj''",14)
      }
      else {
         local nomj `minj'
      }
      if `mink'<=`nbitems' {
         local nomk=abbrev("``mink''",14)
      }
      else {
         local nomk `mink'
      }
      forvalues j=1/`nbitems' {
         matrix `matclus'[`j',`=`i'+1']=`matclus'[`j',`i']
      }
      matrix `vp'[`clus',1]=`nbitems'+`i'                      /*PARENT*/
      matrix `vp'[`clus',2]=`=`nbitems'-`i''                   /*NUMBER OF CLUSTERS*/
      matrix `vp'[`clus',3]=`minj'                             /*CHILD 1*/
      matrix `vp'[`clus',4]=`mink'                             /*CHILD 2*/
      matrix `vp'[`clus',6]=`minegenval'                       /*VARIATION OF THE T or G CRITERION*/
      matrix `vp'[`clus',5]=`vp'[`=`clus'-1',5]-`vp'[`clus',6] /*T or G CRITERION*/
      matrix `vp'[`clus',7]=(`vp'[`clus',6]-`vp'[`=`clus'-1',6])/`vp'[`=`clus'-1',6] /*RELATIVE VARIATION OF THE T OR G CRITERION*/
      matrix `vp'[`clus',8]=`vp'[`=`clus'-1',8]-`minegenval'   /*EXPLAINED VARIANCE*/
      matrix `vp'[`clus',9]=`vp'[`clus',8]/`totvar'*100        /*% OF EXPLAINED VARIANCE*/
      if "`method'"!="centroid" {
         matrix `vp'[`clus',10]=`eigen'                        /*FIRST EIGEN VALUE OF THE NEW CLUSTER*/
         matrix `vp'[`clus',11]=`eigen2'                       /*SECOND EIGEN VALUE OF THE NEW CLUSTER*/
      }
      if `vp'[`=`clus'-1',7]!=0 {
         matrix `vp'[`clus',12]=(`vp'[`clus',7]-`vp'[`=`clus'-1',7])/abs(`vp'[`=`clus'-1',7]) /*2ND ORDER RELATIVE VARIATION OF THE T or G CRITERION*/
      }
      matrix `indexes'[`i',1]=`i'                              /*PARENT*/
      matrix `indexes'[`i',2]=`nbitems'-`i'                    /*NUMBER OF CLUSTERS*/
      matrix `indexes'[`i',3]=`minegenval'                     /*VARIATION OF THE T or G CRITERION*/
      matrix `indexes'[`i',4]=`vp'[`clus',7]                   /*RELATIVE VARIATION OF THE T OR G CRITERION*/
      matrix `indexes'[`i',5]=max(`eigen2',`indexes'[`=`i'-1',5]) /*MAXIMUM SECOND EIGENVALUE*/
      matrix `indexes'[`i',7]=`vp'[`clus',12]                     /*2nd order RELATIVE VARIATION OF THE T OR G CRITERION*/
      foreach j of numlist `numlist`minj'' `numlist`mink''  {
         matrix `matclus'[`j',`=`i'+1']=`clus'
      }
      local varlistgen
      local nbvarlistgen
      forvalues j=1/`=`nbitems'+`i'' {
         local varlist`j'
         forvalues k=1/`nbitems' {
             if `matclus'[`k',`=`i'+1']==`j' {
                local varlist`j' `varlist`j'' ``k''
             }
         }
         local nbvarlist`j': word count `varlist`j''
         local varlistgen `varlistgen' `varlist`j''
         local nbvarlistgen `nbvarlistgen' `nbvarlist`j''
      }
      local newlist
      foreach m in `nbvarlistgen' {
          if `m'!=0 {
              local newlist `newlist' `m'
          }
      }
      if "`kernel'"!=""&`i'==`=`nbkerk'-`nbkerg'+1' {
         local T=`vp'[`=`clus'-1',8]
         di _col(0) in ye "init" _col(12) %4.0f `=`nbitems'-`nbkerk'+`nbkerg'' _col(52) %8.4f `T' _col(62) %8.4f `=`totvar'-`T'' _col(72) %7.3f `=`T'/`totvar'*100' "%"
      }
      if `clus'>`nbitems'+`nbkerk'-`nbkerg' {
         matrix `threshold'[`=`nbitems'-`i'+1',3]=`minegenval'
         if  `clus'==`nbitems'+`nbkerk'-`nbkerg'+1 {
            local relv
            local percent
            local relv2
         }
         else {
            local relv=`indexes'[`i',4]*100
            local percent %
            if `indexes'[`i',7]!=. {
               local relv2=`indexes'[`i',7]*100
            }
            else {
               local relv2=0
            }
            matrix `threshold'[`=`nbitems'-`i'+1',1]=`relv'
            matrix `threshold'[`=`nbitems'-`i'+1',2]=`relv2'
         }
         if "`method'"=="centroid" {
            di _col(0) in ye %4.0f `=`i'-`nbkerk'+`nbkerg'' _col(12) %4.0f `=`nbitems'-`i'' _col(20) "`nomj'" _col(33) "`nomk'" _col(45) %7.0f `=`i'+`nbitems'' _col(52) %8.4f `vp'[`clus',8] _col(62) %8.4f `minegenval' _col(72) %7.3f `vp'[`clus',9] "%" _col(83) _col(84) %5.2f `relv' "`percent'" _col(93) %8.2f `relv2' "`percent'"
         }
         else {
            di _col(0) in ye %4.0f `=`i'-`nbkerk'+`nbkerg'' _col(12) %4.0f `=`nbitems'-`i'' _col(20) "`nomj'" _col(33) "`nomk'" _col(45) %7.0f `=`i'+`nbitems'' _col(52) %8.4f `vp'[`clus',8] _col(62) %8.4f `minegenval' _col(72) %7.3f `vp'[`clus',9] "%" _col(83) %8.4f `vp'[`clus',11] _col(94) %6.2f `relv' "`percent'" _col(103) %8.2f `relv2' "`percent'"
         }
      }
   }
   matrix `indexes'[`nbitems',3]=`vp'[`=2*`nbitems'-1',5] /*RELATIVE VARIATION OF THE T OR G CRITERION*/
   matrix `indexes'[`nbitems',7]=`indexes'[`nbitems',3]/`indexes'[`=`nbitems'-1',3] /*RELATIVE VARIATION OF THE T OR G CRITERION*/
   local i=2*`nbitems'-1
   matrix `threshold'[1,1]=`vp'[`i',5]/`vp'[`i',6]*100-100
   matrix `threshold'[1,2]=(`threshold'[1,1]-`threshold'[2,1])/abs(`threshold'[2,1])*100
   matrix `threshold'[1,3]=`vp'[`i',5]
   if "`method'"=="centroid" {
      di in ye _col(62) %8.4f `threshold'[1,3] _col(83) %6.2f `threshold'[1,1] "`percent'" _col(93) %8.2f `threshold'[1,2] "`percent'"
   }
   else {
      di in ye _col(62) %8.4f `threshold'[1,3] _col(94) %6.2f `threshold'[1,1] "`percent'" _col(103) %8.2f `threshold'[1,2] "`percent'"
   }
   local best=0
   local maxbest=0
   local best2=0
   local maxbest2=0
   local demipart=int(`nbitems'/2)+1
   forvalues i=1/`demipart' {
      if `threshold'[`i',3]>`maxbest2' {
         if `threshold'[`i',3]>`maxbest' {
            local maxbest2=`maxbest'
            local best2=`best'
            local maxbest=`threshold'[`i',3]
            local best=`i'
         }
         else {
            local maxbest2=`threshold'[`i',3]
            local best2=`i'
         }
      }
   }
   di in green "{hline 111}"
   di
   di in green "{hline 60}"
   di in green "PROPOSED BEST PARTITIONS (AMONG THE `demipart' SMALLER PARTITIONS)"
   di in green "{hline 60}"
   di
   di in yellow _col(4) "Based on the variation of the T criterion: " _col(60) in gr "Partitions in " in ye `best' " or " `best2' in gr " clusters"
   return local bestvariation `best' `best2'
   local bestt=0
   local bestt2=0
   local var=0
   local var2=0
   forvalues i=1/`nbitems' {
       if `threshold'[`i',1]>`var2'&`i'<`demipart' {
           if `threshold'[`i',1]>`var' {
              local bestt2=`bestt'
              local var2=`var'
              local var=`threshold'[`i',1]
              local bestt=`i'
           }
           else {
              local var2=`threshold'[`i',1]
              local bestt2=`i'
           }
       }
   }
   di in yellow _col(4) "Based on the research of a threshold: " _col(60) in gr "Partitions in "  in ye `bestt' " or " `bestt2' in gr " clusters"
   forvalues i=`=`nbitems'+1'/`=`nbitems'+`nbkerk'-`nbkerg'' {
      matrix `vp'[`i',6]=`totvar'-`T'
      matrix `vp'[`i',8]=`T'
      matrix `vp'[`i',9]=`T'/`nbitems'*100
   }
   return local bestthresold `bestt' `bestt2'
   forvalues i=1/`nbitems' {
       if `threshold'[`i',2]>`var2'&`i'<`demipart' {
           if `threshold'[`i',2]>`var' {
              local bestt2=`bestt'
              local var2=`var'
              local var=`threshold'[`i',2]
              local bestt=`i'
           }
           else {
              local var2=`threshold'[`i',2]
              local bestt2=`i'
           }
       }
   }
   di in yellow _col(4) "Based on the research of a threshold (second order): " _col(60) in gr "Partitions in " in ye `bestt' " or " `bestt2' in gr " clusters"
   return local bestthresold2 `bestt' `bestt2'
}
/******BAR CHART *******/
if "`bar'"!="" {
   drop _all
   qui set obs `nbitems'
   qui svmat `indexes' ,names(v)
   qui gen id=`nbitems'-_n
   qui replace v7=. in 1
   qui drop if id>`nbitems'-`nbkerk'+`nbkerg'-1
   label variable id "Number of clusters"
   label variable v3 "T variation"
   qui su v3 if id!=0
   local maxv3=ceil(r(max)*5)/5
   local minv3=floor(r(min)*5)/5
   label variable v4 "Relative T variation"
   label variable v7 "Relative T variation order 2"
   qui graph twoway (bar v3 id, name(bar,replace) `fsb' vert yaxis(1))(line v4 id,yaxis(2))/*(line v6 id,yaxis(3))(line v5 id,yaxis(4))*/(line v7 id,yaxis(5)) if id!=0,ylabel(`minv3'(0.2)`maxv3') xlabel(1(1)`=`nbitems'-`nbkerk'+`nbkerg'-1')
}
/****** DENDROGRAM********/
   drop _all
   qui set obs `nbitems'
   qui svmat `matclus' ,names(v)
   local listorder
   forvalues i=`nbitems'(-1)1 {
      local listorder `listorder' v`i'
   }
   qui gen id=_n
   qui sort `listorder'

   capture cluster delete clv,zap
   qui cluster complete v* ,name(clv)

   qui replace clv_id=_n
   qui replace clv_ord=id
   qui replace clv_hgt=.

   qui  gen fait=0
   qui gen clus=0
   forvalues i=2/`nbitems' {
      local ligne=`nbitems'+`i'-1
      if (`vp'[`ligne',3]<=`nbitems') {
         local first=`vp'[`ligne',3]
         gsort +fait -v`i'  +clv_id
      }
      else {
         local first=`vp'[`ligne',4]
         gsort +fait -v`i'  +clv_id
      }
      if "`deltaT'"!="" {
         qui replace clv_hgt=`vp'[`ligne',6] in 1
      }
      else {
         qui replace clv_hgt=100-`vp'[`ligne',9] in 1
      }
      qui replace fait=1 in 1
      qui replace clus=`vp'[`ligne',1] in 1
   }
if "`dendro'"=="" {
   qui gen label=""
   forvalues i=1/`nbitems' {
      qui replace label=abbrev("`label`i''",`abbrev') if clv_id==`i'
   }
   sort clv_id
   if `nbitems'>`cutnumber' {
      local var "Groups of variables"
      local cut cutnumber(`cutnumber') /*labcutn*/
   }
   else {
      local var "Variables"
      local cut label(label)
   }
   qui su clv_hgt
   local tmp=r(max)
   local max=floor(`tmp')+.5
   if `tmp'>`max' {
      local max=`max'+.5
   }
   local maxvar=`max'+5
   if "`title'"=="" {
      local title "Clustering around Latent Variables (CLV)"
   }
   if "`caption'"!="" {
      local var "`caption'"
   }
   if "`deltaT'"!="" {
      local titleL "Variation of the T criterion"
      local yl "0(.5)`max'"
   }
   else {
      local titleL "% Unexplained Variance"
      local yl "0(25)`maxvar'"
   }
   if "`textsize'"==""  {
      local textsize: word `=min(int(`nbitems'/15)+1,5)' of medium medsmall small vsmall tiny
   }
   if "`horizontal'"!="" {
   *matrix list clv
      qui cluster dendro clv,  name (dendrogram,replace) `fsd' hor ytitle("`var'") `showcount' xtitle("`titleL'") title("`title'",span) xlabel(`yl') ylabel(,angle(0)  labsize(`textsize')) `cut'
   }
   else {
      qui cluster dendro clv, name(dendrogram,replace) `fsd' xtitle("`var'") `showcount' ytitle("`titleL'") title("`title'",span) ylabel(`yl') xlabel(,labsize(`textsize')) `cut'
   }
   if "`savedendro'"!="" {
      qui graph save dendrogram `savedendro'
   }
}

/***** END DENDROGRAM*****/

/**** TEST ********/
if `cons'>`nbitems'-`nbkerk'+`nbkerg' {
   di in ye "The {hi:consolidation} is not possible for a number of clusters superior to the initial number of clusters"
   local cons=0
}


/***** CONSOLIDATION PROCEDURE ********/
if `cons'!=0 {
   sort v`=`nbitems'-`cons'+1'
   gen cut`cons'=1
   local g=1
   forvalues i=2/`nbitems' {
      if v`=`nbitems'-`cons'+1'[`i']!=v`=`nbitems'-`cons'+1'[`=`i'-1'] {
         local g=`g'+1
      }
      qui replace cut`cons'=`g' in `i'
   }
   sort id
   tempname group
   mkmat cut`cons',matrix(`group')

   use `clvfiletmp',replace

   local n=1
   local env=1
   while (`env'==1) {
      forvalues g=1/`cons' {
         local list`g'
         forvalues i=1/`nbitems' {
            if `group'[`i',1]==`g' {
               local list`g' `list`g'' ``i''
            }
         }
      }
      di
      if `n'==1 {
         di in green "{hline 30}"
         di in green "PARTITION BEFORE CONSOLIDATION"
         di in green "{hline 30}"
      }
      di
      local col=13
      local max=0
      local critT=0
      forvalues g=1/`cons' {
         di _col(`col') in green "CLUSTER " %2.0f `g' _c
         local col=`col'+12
         local tmp`g':word count `list`g''
         if `tmp`g''>`max' {
            local max `tmp`g''
         }
         tempvar f1`g'
         if "`method'"=="centroid" {
               qui genscore `list`g'',score(`f1`g'') mean
               qui su `f1`g'' [`weight'`exp']
               local var=r(Var)
               local critT=`critT'+`tmp`g''*`var'
               qui pca `list`g'' [`weight'`exp'] ,cov
               local trace=e(trace)
               local explained`g'=`tmp`g''*`var'/`trace'
         }
         else {
            if `tmp`g''>1 {
               if "`method'"=="classical"|"`method'"=="v2" {
                  qui pca `list`g'' [`weight'`exp'] ,cov
                  matrix `Ev'=e(Ev)
                  local trace=e(trace)
                  qui predict `f1`g''
               }
               else if "`method'"=="polychoric"|"`method'"=="polychoric" {
                  qui polychoricpca `list`g'' [`weight'`exp'] ,score(`f1`g'') nscore(1)
                  matrix `Ev'=r(eigenvalues)
                  local trace=0
                  forvalues m=1/`tmp`g''{
                     local trace =`trace'+`r(lambda`m')'
                  }
                  rename `f1`g''1 `f1`g''
               }
               local lambda1=`Ev'[1,1]
               local explained`g'=`lambda1'/`trace'
               local critT=`critT'+`lambda1'
            }
            else {
               local explained`g'=1
               qui gen `f1`g''=`list`g''
               if "`standardized'"=="" {
                   local critT=`critT'+1
               }
               else  {
                  qui su [`weight'`exp']
                  local critT=`critT'+`r(Var)'
               }
            }
         }
      }
      di
      di _col(1) in green "ITEMS :" _c
      forvalues i=1/`max' {
         local col=15
         forvalues g=1/`cons' {
            local tmpv:word `i' of `list`g''
            local tmpv=abbrev("`tmpv'",8)
            di _col(`col') in ye %8s "`tmpv'"  _c
            local col= `col'+12
         }
         di
      }
      local col=16
      di _col(1) in green "Expl. Var:" _c
      forvalues g=1/`cons' {
         di _col(`col') in ye %6.2f `=`explained`g''*100' in green "%"  _c
         local col= `col'+12
      }
      di
      di
      di in green "Variance Explained : " in ye %6.3f  `=`critT'/`totvar'*100' in green "%"
      di in green "T criterion : " in ye %6.4f  `critT'
      di
      di in green "{hline 21}"
      di in green "CONSOLIDATION: STEP `n'"
      di in green "{hline 21}"
      local n=`n'+1
      local env=0
      if "`method'"=="polychoric"|"`method'"=="polychoricv2" {
         local command polychoric
      }
      else {
         local command corr
      }
      forvalues i=1/`nbitems' {
         local env`i'=0
         local gr=`group'[`i',1]
         qui `command' ``i'' `f1`gr'' [`weight'`exp']
         local corr`i'=r(rho)
         local corrs`i'=r(rho)
         forvalues g=1/`cons' {
            qui `command' ``i'' `f1`g'' [`weight'`exp']
            local tmpcorr=r(rho)
            if `g'!=`gr'&(((`corr`i'')<(`tmpcorr')&"`method'"=="centroid")|((`corr`i'')^2<(`tmpcorr')^2& "`method'"!="centroid")) {
               local env=1
               local env`i'=1
               matrix `group'[`i',1]=`g'
               local corr`i'=`tmpcorr'
            }
         }
         if `env`i''==1 {
            local g=`group'[`i',1]
            di in green  "The variable " in ye "``i'' " in green "is assigned to the `g'th group" _c
            if "`method'"!="centroid" {
               di in green " (corr^2=" %6.4f in ye  (`corr`i'')^2 in green " vs " in ye %6.4f (`corrs`i'')^2 in green ")"
            }
            else {
               di in green " (corr=" %6.4f in ye  (`corr`i'') in green " vs " in ye %6.4f (`corrs`i'') in green ")"
            }

         }
      }
      if `env'==0 {
         local latent
         forvalues g=1/`cons' {
             label variable `f1`g'' "Latent variable `g'"
             if "`genlv'"!="" {
                if "`replace'"!=""{
                   capture drop `genlv'`g'
                }
                gen `genlv'`g'=`f1`g''
             }
             local latent `latent' `f1`g''
             return local cluster`g' `list`g''
         }
         matrix `group'=`group''
         matrix colnames `group'=`varlist'
         return matrix affect=`group'
         di in ye "Stability of the partition is achieved"
         if `cons'<=7 {
            di
            di in green "{hline 42}"
            di in green "CORRELATION MATRIX OF THE LATENT VARIABLES"
            di in green "{hline 42}"
            di
            di in green "{hline `=(`cons')*13+15'}"
            forvalues g=1/`cons' {
               di _col(`=13*(`g'-1)+23') in green "Latent" _c
            }
            di
            forvalues g=1/`cons' {
               di _col(`=13*(`g'-1)+19') in green "variable `g'" _c
            }
            di
            di in green "{hline `=(`cons')*13+15'}"
            forvalues g=1/`cons' {
               di in green "Latent variable `g'" _c
               forvalues h=1/`g' {
                  local loc=13*`h'+10
                  qui corr `f1`g'' `f1`h'' [`weight'`exp']
                  local rho=r(rho)
                  di _col(`loc') in ye %6.4f `rho' _c
               }
               di
            }
            di in green "{hline `=(`cons')*13+15'}"
            di
         }
         if `nbind'<=800&"`biplot'"==""&"`weight'"=="" {
            local max=max(`matsize',`nbind')
            qui set matsize `max'
            if "`addvar'"!="" {
               local add `varlist'
            }
            if "`dim'"=="" {
               local dim 1 2
            }
            qui qui biplotvlab `latent' `add', name(biplot,replace) `fsbi' norow colopts(name(latent variables)) alpha(0) title(Biplot of the latent variables) labdes(size(vsmall) color(blue)) stretch(1) `std' dim(`dim')
         }
         else if `nbind'>800&"`biplot'"==""&"`weight'"==""{
            di in green "There is more than 800 individuals, so the {hi:biplot} option is disabled"
         }
         else if "`weight'"!=""&&"`biplot'"==""{
            di in green "The {hi:biplot} option is disabled because you use weights"
         }
      }
      forvalues g=1/`cons' {
         drop `f1`g''
      }
   }
}
/***** END OF THE CONSOLIDATION PROCEDURE********/

qui set matsize `matsize'
if "`genlv'"!="" {
   qui keep `id' `genlv'1-`genlv'`cons'
   tempfile lvfile
   qui sort `id'
   qui save `lvfile',replace
}
use `clvfile',replace
if "`genlv'"!="" {
   qui sort `id'
   qui merge `id' using `lvfile'
}
qui drop  `id'
capture drop _merge
capture cluster delete clv,zap
matrix colnames `vp'="Parent" "Number of clusters" "Child 1" "Child 2" "T" "DeltaT" "deltaT" "Explained Variance" "Explained Variance (%)" "First eigenvalue" "Second Eigenvalue" "2nd order deltaT"
if "`save'"!="" {
   qui matrix `save'_vp=`vp'
   qui matrix `save'_matclus=`matclus'
   qui global `save'_varlist `varlist'
   qui global `save'_method `method'
   qui global `save'_kernel `kernel'
}

return matrix vp=`vp'
return matrix matclus=`matclus'
return local varlist `varlist'
return local method `method'
return local kernel `kernel'
restore,not
end
