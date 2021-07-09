*! Version 3.2 15 April 2010
*! Jean-Benoit Hardouin
************************************************************************************************************
* hcavar: Hierachical Clusters Analysis (HCA) of variables
* Version 3.2: April 15, 2010  /* Possibility to use Polytomous Items with CCOR, CCOV and MH*/
*
* Use the Detect Stata program (ssc install detect)
*
* Historic :
* Under the name of -hcaccprox-
* Version 1 [2004-01-18], Jean-Benoit Hardouin
* Version 2 [2004-05-12], Jean-Benoit Hardouin
* Version 3 [2005-12-31], Jean-Benoit Hardouin
* Version 3.1 [2006-01-15], Jean-Benoit Hardouin  /* correction if there is only one individual with a given score*/
*
* Jean-benoit Hardouin - Department of Biomathematics and Biostatistics - University of Nantes - France
* EA 4275 "Biostatistics, Clinical Research and Subjective Measures in Health Sciences"
* jean-benoit.hardouin@univ-nantes.fr
*
* News about this program :http://www.anaqol.org
*
* Copyright 2004-2006, 2010 Jean-Benoit Hardouin
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


program define hcavar , rclass
version 9
syntax varlist(min=2 numeric) [,PROX(string) METHod(string) PARTition(numlist) MEASures  DETect MATrix(string) noDENDROgram]

tempfile hcaccproxfile
qui save `hcaccproxfile',replace
preserve

local nbitems : word count `varlist'
tokenize `varlist'
local type=0
forvalues i=1/`nbitems' {
   qui drop if ``i''==.
   qui inspect ``i''
   if r(N_unique)>`type'&r(N_unique)!=. {
      local type=r(N_unique)
   }
   else if r(N_unique)>`type'&r(N_unique)==. {
      local type "100"
   }
}
if `type'==100 {
   local type ">99"
}

tempname proximity whereitems

local prox=lower("`prox'")
local method=lower("`method'")
matrix define `proximity'=J(`nbitems',`nbitems',0)
matrix define `whereitems'=J(`=`nbitems'-1',`nbitems',0)

/**************************PROXIMITIES MEASURES DESCRIPTION************************/

if "`matrix'"!="" {
   local desprox="Defined by the user"
}
if "`prox'"=="" {
   local prox="pearson"
}
else if "`prox'"=="a" {
   local prox="jaccard"
}
else if "`prox'"=="ad" {
   local prox="matching"
}
else if "`prox'"=="corr" {
   local prox="pearson"
}
if "`type'">"2"&"`prox'"!="pearson"&"`prox'"!="ccov"&"`prox'"!="ccor"&"`prox'"!="mh"  {
   di in red "Only the {hi:pearson}, {hi:ccov} and {hi:ccor} measures of proximity are available with ordinal or numerous variables"
   di in red "Please correct your {hi:prox} option."
   exit
}
if "`type'">"2"&"`detect'"!=""  {
   di in ye "The {hi:detect} option is available only with binary variables. This option is disabled."
   local detect
   di
}
local existmeas=0
foreach i in jaccard matching pearson russel dice ccor mh ccov {
   if "`prox'"=="`i'" {
      local existmeas=1
   }
}
if `existmeas'==0 {
   di in red "You must define an existing measure of proximity (jaccard(a), matching(ad), pearson(cor), russel, dice, ccov, ccor, mh)."
   di in red "Please correct your {hi:prox} option."
   exit
}
if "`prox'"=="ccov"|"`prox'"=="mh" {
   local proxmin=0
}

if "`prox'"=="matching" {
   local desprox="Matching"
}
else if "`prox'"=="jaccard" {
   local desprox="Jaccard"
}
else if "`prox'"=="russel" {
   local desprox="Russel"
}
else if "`prox'"=="dice" {
   local desprox="Dice"
}
else if "`prox'"=="pearson" {
   local desprox="Pearson"
}
else if "`prox'"=="ccov" {
   local desprox="Conditional covariances"
}
else if "`prox'"=="ccor" {
   local desprox="Conditional correlations"
}
else if "`prox'"=="mh" {
   local desprox="Mantel Hanzel"
}

/**************************PROXIMITIES MEASURES DESCRIPTION************************/

if "`method'"=="upgma"|"`method'"=="" {
   local method="average"
}
if "`method'"=="wpgma"|"`method'"=="" {
   local method="waverage"
}
local vermethod=0
foreach i in average waverage single centroid median complete wards {
   if "`method'"=="`i'" {
      local vermethod=1
   }
 }

if `vermethod'==0 {
   di in red "You must define an existing method to define the proximity between two clusters of items:"
   di in red _col(10) "- single: single linkage"
   di in red _col(10) "- complete: complete linkage "
   di in red _col(10) "- average(UPGMA): Unweighted Pair-Group Method of Average"
   di in red _col(10) "- waverage(WPGMA): Unweighted Pair-Group Method of Average"
   di in red _col(10) "- wards: Ward's linkage"
   di in red "Please correct your method option"
   exit
}
if "`method'"=="single"|"`method'"=="singlelinkage" {
   local method single
   local desmethod="Single linkage"
}
else if "`method'"=="complete"|"`method'"=="completelinkage" {
   local desmethod="Complete linkage"
}
else if "`method'"=="median"|"`method'"=="medianlinkage" {
   local desmethod="Median linkage (no dendrogram)"
}
else if "`method'"=="centroid"|"`method'"=="centroidlinkage" {
   local desmethod="Centroid linkage (no dendrogram)"
}
else if "`method'"=="average"|"`method'"=="averagelinkage" {
   local desmethod="Unweighted Pair-Group Method of Average"
}
else if "`method'"=="waverage"|"`method'"=="waveragelinkage" {
   local desmethod="Weighted Pair-Group Method of Average"
}
else if "`method'"=="wards"|"`method'"=="wardslinkage" {
   local desmethod="Ward's linkage"
}

forvalues i=1/`nbitems' {
	matrix `whereitems'[1,`i']=`i'
}

tempvar score
genscore `varlist',score(`score')
qui su `score'
local maxscore=r(max)
forvalues k=0/`maxscore' {
	qui count if `score'==`k'
	local nk`k'=r(N)
}

qui count
local N=r(N)


di in green "{hline 80}"
di in green "Number of individuals with none missing values: " in ye `N'
di in green "Maximal number of modalities for a variable: " in ye "`type'"
di in green "Proximity measures: " in ye "`desprox'"
di in green "Method to aggregate clusters: " in ye "`desmethod'"
di in green "{hline 80}"
di
di

/*************************Measure of proximities*********************************/
if "`matrix'"=="" {
   forvalues i=1/`nbitems' {
	forvalues j=`=`i'+1'/`nbitems' {
		/***********************************Proximity AD*************************/
		if "`prox'"=="matching" {  /*ad*/
			qui count if ``i''==1&``j''==1
			local tmp11=r(N)
			qui count if ``i''==0&``j''==0
			local tmp00=r(N)

			matrix `proximity'[`i',`j']=sqrt(1-(`tmp11'+`tmp00')/`N')
			matrix `proximity'[`j',`i']=`proximity'[`i',`j']
		}

		/***********************************Proximity A**************************/
		else if "`prox'"=="jaccard" {   /*a*/
			qui count if ``i''==1&``j''==1
			local tmp11=r(N)
			qui count if ``i''==0&``j''==0
			local tmp00=r(N)

			matrix `proximity'[`i',`j']=sqrt(1-`tmp11'/(`N'-`tmp00'))
			matrix `proximity'[`j',`i']=`proximity'[`i',`j']
		}

		/***********************************Proximity Russel**************************/
		else if "`prox'"=="russel" {
			qui count if ``i''==1&``j''==1
			local tmp11=r(N)

			matrix `proximity'[`i',`j']=sqrt(1-`tmp11'/`N')
			matrix `proximity'[`j',`i']=`proximity'[`i',`j']
		}

		/***********************************Proximity A**************************/
		else if "`prox'"=="dice" {
			qui count if ``i''==1&``j''==1
			local tmp11=r(N)
			qui count if ``i''==0&``j''==0
			local tmp00=r(N)

			matrix `proximity'[`i',`j']=sqrt(1-2*`tmp11'/(`N'+`tmp11'-`tmp00'))
			matrix `proximity'[`j',`i']=`proximity'[`i',`j']
		}

		/**********************************Proximity COR*************************/
                else if "`prox'"=="pearson" {   /*corr*/
			qui corr ``i'' ``j''
			matrix `proximity'[`i',`j']=sqrt(2*(1-r(rho)))
			matrix `proximity'[`j',`i']=`proximity'[`i',`j']
		}

		/***********************************Proximity CCOV**********************/
		else if "`prox'"=="ccov" {
			local dij=0
			local Ntemp=`N'
			forvalues k=1/`=`maxscore'-1' {
				if `nk`k''!=0 {
				   if `nk`k''>1 {
				      qui corr ``i'' ``j'' if `score'==`k',cov
                                      local covi`i'j`j'k`k'=r(cov_12)
				   }
				   else if `nk`k''==1 {
				      local Ntemp=`Ntemp'-1
                                      local covi`i'j`j'k`k'=0
                                   }
				   else {
                                      local covi`i'j`j'k`k'=0
				   }
				   local dij=`dij'+`covi`i'j`j'k`k''*`nk`k''
				}
			}

			matrix `proximity'[`i',`j']=-`dij'/`Ntemp'
			matrix `proximity'[`j',`i']=`proximity'[`i',`j']
			if `proxmin'<`dij'/`Ntemp' {
				local proxmin=`dij'/`Ntemp'
			}
		}

		/***********************************Proximity CCOR**********************/

		else if "`prox'"=="ccor" {
			local dij=0
			local nnull=0
			local Ntemp=`N'
			forvalues k=1/`=`maxscore'-1' {
				if `nk`k''!=0 {
				   if `nk`k''>1 {
                                      qui corr ``i'' ``j''  if `score'==`k'
				      local cori`i'j`j'k`k'=r(rho)
	                           }
	                           else if `nk`k''==1 {
                                      local Ntemp=`Ntemp'-1
      				      local cori`i'j`j'k`k'=0
	                           }
	                           else {
      				      local cori`i'j`j'k`k'=0
	                           }
				   if `cori`i'j`j'k`k''!=. {
					local dij=`dij'+`cori`i'j`j'k`k''*`nk`k''
				   }
				   else if `cori`i'j`j'k`k''==. {
				      local nnull=`nnull'+`nk`k''
                                   }
				}
			}

			matrix `proximity'[`i',`j']=sqrt(2*(1-`dij'/(`Ntemp'-`nnull')))
			matrix `proximity'[`j',`i']=`proximity'[`i',`j']
		}


		/***********************************Proximity MH************************/

		else if "`prox'"=="mh" {
			local numij=0
			local denom=0
			forvalues k=1/`=`maxscore'-1' {
				if `nk`k''!=0 {
					qui count if ``i''==1&``j''==1&`score'==`k'
					local A=r(N)
					qui count if ``i''==0&``j''==1&`score'==`k'
					local B=r(N)
					qui count if ``i''==1&``j''==0&`score'==`k'
					local C=r(N)
					qui count if ``i''==0&``j''==0&`score'==`k'
					local D=r(N)
					local numij=`numij'+`A'*`D'/`nk`k''
					local denomij=`denomij'+`B'*`C'/`nk`k''
				}
			}

			matrix `proximity'[`i',`j']=-log(`numij'/`denomij')
			matrix `proximity'[`j',`i']=`proximity'[`i',`j']
			if `proxmin'<log(`numij'/`denomij') {
				local proxmin=-`proximity'[`i',`j']
			}
		}
	}
   }
   if "`prox'"=="ccov"|"`prox'"=="mh" {
	forvalues i=1/`nbitems' {
		forvalues j=`=`i'+1'/`nbitems' {
			matrix `proximity'[`i',`j']=`proximity'[`i',`j']+`proxmin'
			if `proximity'[`i',`j']<0 {
			   matrix `proximity'[`i',`j']=0
                        }
			matrix `proximity'[`j',`i']=`proximity'[`i',`j']
		}
	}
   }
}
/**********************END OD THE COMPUTING OF THE PROXIMITIES**************************************/
else {
   matrix `proximity'=`matrix'
}

matrix rowname `proximity'=`varlist'
matrix colname `proximity'=`varlist'

if "`measures'"!="" {
	di in green "{hline 50}"
        di in green "Measures of proximity between the items"
	di in green "{hline 50}"
	matrix list `proximity', noheader
	di
}

/**********************CLUSTERING PROCEDURE **********************************************/


qui clustermat `method' `proximity',clear labelvar(name)
local hor "hor"
if "`method'"!="centroid"&"`method'"!="median"&"`dendrogram'"=="" {
   qui cluster dendro ,labels(name) hor ylabel(,angle(0)) title("Hierarchical Cluster Analysis on variables") subtitle("`desmethod'") xtitle("`desprox' proximities")
}

if "`partition'"!="" {
   foreach i of numlist `partition' {
      qui cluster gen cluster`i'=group(`i')
   }
   tempname clusters
   mkmat cluster* ,mat(`clusters')
   matrix rownames `clusters'=`varlist'
   local compteur=0
   foreach i of numlist `partition' {
      local ++compteur
      di
      di in green "{hline 30}"
      di in green "Partition in `i' cluster(s)"
      di in green "{hline 30}"
      di
      forvalues j=1/`i' {
         local cluster`i'_`j'
         local nbi`i'_`j'=0
         forvalues k=1/`nbitems' {
            if `clusters'[`k',`compteur']==`j' {
               local cluster`i'_`j' `cluster`i'_`j'' ``k''
               local ++nbi`i'_`j'
            }
         }
         di in green "Cluster `j': " in ye "`cluster`i'_`j''"
      }
   }
   return matrix clusters=`clusters'
}

/**********************DETECT OPTION **************************************************/

use `hcaccproxfile',clear
if "`detect'"!="" {
        foreach i of numlist `partition' {
           local liste
           local part
           forvalues j=1/`i' {
              local liste "`liste' `cluster`i'_`j''"
              local part "`part' `nbi`i'_`j''"
           }
           qui detect `liste',part(`part')
           local detect`i'=r(DETECT)
           local Iss`i'=r(Iss)
           local R`i'=r(R)
        }
        tempname indexes
        matrix define `indexes'=J(`compteur',4,0)
        matrix colnames `indexes'=Clusters DETECT Iss R
	di ""
	di in green "{hline 50}"
	di in green "Indexes to compare the partitions of the items"
	di in green "{hline 50}"
	di ""
	di in green _col(29) "DETECT" _col(43) "Iss" _col(56) "R"
	local compteur=0
        foreach k of numlist `partition' {
                local ++compteur
	        matrix  `indexes'[`compteur',1]=`k'
	        matrix  `indexes'[`compteur',2]=`detect`k''
	        matrix  `indexes'[`compteur',3]=`Iss`k''
	        matrix  `indexes'[`compteur',4]=`R`k''
		di  _col(5) in green "`k' cluster(s):" _col(27) in yellow %8.5f `detect`k'' _col(38) %8.5f  `Iss`k'' _col(49) %8.5f `R`k''
	}
        return matrix indexes=`indexes'
}
return local nbvar=`nbitems'
return matrix measures=`proximity'
restore, not
*use `hcaccproxfile',clear

end
