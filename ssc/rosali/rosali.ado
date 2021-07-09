*! version 2.4 june2020
*! Myriam Blanchin - Priscilla Brisson
************************************************************************************************************
* ROSALI: RespOnse-Shift ALgorithm at Item-level
* Response-shift detection based on Rasch models family
*
* Version 1 : December 21, 2016 (Myriam Blanchin) /*rspcm122016*/
* Version 1.1 : October 13, 2017 (Myriam Blanchin) /*option: MODA, automatic recoding of unused response categories*/
* Version 2 : April, 2018 (Myriam Blanchin - Priscilla Brisson) /*option: GROUP, dichotomous group variable*/
* Version 2.1 : October, 2018 (Myriam Blanchin - Priscilla Brisson) /* Version 1.1 + Version 2 */
* Version 2.2 : February, 2019 (Priscilla Brisson) /* option nodif, optimization */
* Version 2.3 : December, 2019 (Priscilla Brisson) /* option detail, + petites corrections */
* Version 2.4 : June, 2020 (Myriam Blanchin) /* debug option detail + step C, modifs sorties et help */
*
* Myriam Blanchin, SPHERE, Faculty of Pharmaceutical Sciences - University of Nantes - France
* myriam.blanchin@univ-nantes.fr
*
* Priscilla Brisson, SPHERE, Faculty of Pharmaceutical Sciences - University of Nantes - France
* priscilla.brisson@univ-nantes.fr
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

program define rosali, rclass

timer clear 1
timer on 1

syntax varlist(min=2 numeric) [if] [,GROUP(varlist) NODIF PRO DETail]

preserve 
version 15
tempfile saverspcm
capture qui save `saverspcm',replace
local save1=_rc

if "`if'"!="" {
    qui keep `if'
}

if "`pro'" != "" {
	di "START"
}

/**************************************************************************/
set more off
set matsize 5000

local gp "`group'"

tokenize `varlist'
local nbitems:word count `varlist'

	/* Vérif nb d'items pair */
local mod=mod(`nbitems',2)
if `mod'!=0 {
  di as error "You must enter an even number of items : the first half of the items represents the items at time 1 and the second half the items at time 2"
  error 198
  exit
}

local nbitems=`nbitems'/2


if "`group'"=="" & "`nodif'"!="" {
	di as error "nodif can only be used with the group option ({hi:nodif} option). Please correct this option."
	error 198
	exit
}

local nbc: word count `group'
if `nbc' >= 2 {
	di as error "Only one variable can be used for group option ({hi:group} option). Please correct this option."
	error 198
	exit
}

	/* Vérif qu'il y a 2 groupes si l'option groupe est choisie */
if "`group'"!="" {
  qui tab `group'
  local nbgrp = r(r)
  if `nbgrp' != 2 {
	di as error "Only 2 groups are possible for the group option ({hi:group} option). Please correct this option."
	error 420
	exit
  }
}
/* recoder la variable de groupe en 0, 1*/

if "`group'"!="" {
	qui tab `gp', matrow(rep)
	qui matrix list rep
	if rep[1,1]+rep[2,1] != 1 & rep[1,1]*rep[2,1] != 0 {  
		forvalues i=1/`=rowsof(rep)'{
			qui replace `gp'=`i'-1 if `gp'==rep[`i',1]
			di "WARNING : `gp' `=rep[`i',1]' is now `gp' `=`i'-1' "
		}
	}
	forvalues g = 0/1 {
		qui tab `gp' if `gp' == `g'
		local nbp_gp`g' = r(N)
	}
}



/*item rename*/
/*
Items au temps 1 : 1 à nbitems ``j''
Items au temps 2 : nbitems à 2*nbitems ``=`j'+`nbitems'''

Si t varie, puis num item : ``=(`t'-1)*`nbitems'+`j'''
*/


local com_z = 0 // Indicatrice de recodage
	/*verif modalités répondues*/
if "`gp'" == "" {							// Si pas d'option groupe
	forvalues j = 1 / `nbitems' {
		local recoda_`j' = 0
		qui tab ``j'', matrow(rect1_`j')				// Récupération des infos moda du temps 1
		local minm`j'_t1 = rect1_`j'[1,1]
		local maxm`j'_t1 = rect1_`j'[r(r),1]
		
		qui tab ``=`j'+`nbitems''', matrow(rect2_`j')			// Récupération des infos moda du temps 2
		local minm`j'_t2 = rect2_`j'[1,1]
		local maxm`j'_t2 = rect2_`j'[r(r),1]
		
		local minm_`j' = min(`minm`j'_t1',`minm`j'_t2')		// Info moda pour l'item j
		local maxm_`j' = max(`maxm`j'_t1',`maxm`j'_t2')
		local nbm_`j' = `=`maxm_`j''-`minm_`j'''
		
		if `minm_`j'' != 0 & `com_z' == 0 {
			local com_z = 1
		}

		
		//Recodage des réponses en 0, 1, 2, etc... 
		forvalues r = 0/`=`maxm_`j''-1'  {
				qui replace ``j'' = `r' if ``j'' == `=`r'+`minm_`j'''
				qui replace ``=`j'+`nbitems''' = `r' if ``=`j'+`nbitems''' == `=`r'+`minm_`j'''
		}
		
		// Vérif. Que toutes les modas sont utilisées & concordance entre temps
		forvalues m = 0/`nbm_`j'' {
			qui count if ``j'' == `m'
			local nb_rn1 = r(N)
			qui count if ``=`j'+`nbitems''' == `m'
			local nb_rn2 = r(N)
			local nb_rn = min(`nb_rn1',`nb_rn2')
			
			if `nb_rn' == 0 {		// Une moda n'est pas utilisée
				local recoda_`j' = 1
				if   `m' == 0 | `m' <= `minm`j'_t1' | `m' <= `minm`j'_t2' { // La moda 0 ou les moda min ne sont pas utilisées	
					local stop = 1
					forvalues k = 1/`=`nbm_`j''-`m'' {
						qui count if ``j'' == `=`m' + `k''
						local v`k'1 = r(N)
						qui count if ``=`j'+`nbitems''' == `=`m' + `k''
						local v`k'2 = r(N)
						if (`v`k'1' != 0 | `v`k'2' != 0) & `stop' != 0 {
							qui replace ``j''= `=`m'+`k'' if ``j''==`m'
							qui replace ``=`j'+`nbitems'''=`=`m'+`k'' if ``=`j'+`nbitems'''==`m'	
							di  "WARNING: items ``j'' & ``=`j'+`nbitems''': answers `m' and `=`m'+`k'' merged "
							local stop = 0
						}
					}
				}
				else if `m' >= `maxm`j'_t1' | `m' >= `maxm`j'_t2' | `m' == `maxm_`j'' {	// La (ou les) moda max ne sont pas utilisée(s)
					local stop = 1
					forvalues k = 1/`m' {
						qui count if ``j'' == `=`m' - `k''
						local v`k'1 = r(N)
						qui count if ``=`j'+`nbitems''' == `=`m' - `k''
						local v`k'2 = r(N)
						if (`v`k'1' != 0 | `v`k'2' != 0) & `stop' != 0 {
							qui replace ``j''=`=`m' - `k'' if ``j''==`m'
							qui replace ``=`j'+`nbitems'''=`=`m' - `k'' if ``=`j'+`nbitems'''==`m'
							di  "WARNING: items ``j'' & ``=`j'+`nbitems''': answers `m' and `=`m'-`k'' merged"
							local stop = 0
						}
					}
				}
				else {	
					if runiform()>0.5{											// Tirage au sort pour regrouper
						local stop = 1
						forvalues k = 1/`m' {
							qui count if ``j'' == `=`m' - `k''
							local v`k'1 = r(N)
							qui count if ``=`j'+`nbitems''' == `=`m' - `k''
							local v`k'2 = r(N)
							if (`v`k'1' != 0 | `v`k'2' != 0) & `stop' != 0 {
								qui replace ``j''= `=`m'-`k'' if ``j''==`m'
								qui replace ``=`j'+`nbitems''' =`=`m'-`k'' if ``=`j'+`nbitems''' ==`m'	
								di  "WARNING: items ``j'' & ``=`j'+`nbitems''': answers `m' and `=`m'-`k'' merged"
								local stop = 0
							}
						}
					}
					else {
						local stop = 1
						forvalues k = 1/`=`nbm_`j''-`m'' {
							qui count if ``j'' == `=`m' + `k''
							local v`k'1 = r(N)
							qui count if ``=`j'+`nbitems''' == `=`m' + `k''
							local v`k'2 = r(N)
							if (`v`k'1' != 0 | `v`k'2' != 0) & `stop' != 0 {
								qui replace ``j''=`=`m' + `k'' if ``j''==`m'
								qui replace ``=`j'+`nbitems'''=`=`m' + `k'' if ``=`j'+`nbitems'''==`m'
								di  "WARNING: items ``j'' & ``=`j'+`nbitems''': answers `m' and `=`m'+`k'' merged"
								local stop = 0
							}
							else {
								if `stop' != 0 {
									qui replace ``j''= `nbm_`j'' if ``j''==`m'
									qui replace ``=`j'+`nbitems'''= `nbm_`j'' if ``=`j'+`nbitems'''==`m'
									di  "WARNING: items ``j'' & ``=`j'+`nbitems''': answers `m' and `nbm_`j'' merged"
									local stop = 0
								}
							}
						}
					}
				}
			}
		}
	}
}
else {									// Cas où l'option groupe est utilisée
	forvalues j = 1 / `nbitems' {
		local recoda_`j' = 0
		qui tab ``j'' if `gp' == 0, matrow(rect1_g0_`j') matcell(nbrt1_g0_`j')					// Récupération des infos moda du temps 1pour chaque groupe
		local minm`j'_t1_g0 = rect1_g0_`j'[1,1]
		local maxm`j'_t1_g0 = rect1_g0_`j'[r(r),1]
		
		qui tab ``j'' if `gp' == 1, matrow(rect1_g1_`j') matcell(nbrt1_g1_`j')				
		local minm`j'_t1_g1 = rect1_g1_`j'[1,1]
		local maxm`j'_t1_g1 = rect1_g1_`j'[r(r),1]
		
		qui tab ``=`j'+`nbitems''' if `gp' == 0, matrow(rect2_g0_`j') matcell(nbrt2_g0_`j')				// Récupération des infos moda du temps 2 pour chaque groupe
		local minm`j'_t2_g0 = rect2_g0_`j'[1,1]
		local maxm`j'_t2_g0 = rect2_g0_`j'[r(r),1]
		
		qui tab ``=`j'+`nbitems''' if `gp' == 1	, matrow(rect2_g1_`j') matcell(nbrt2_g1_`j')				
		local minm`j'_t2_g1 = rect2_g0_`j'[1,1]
		local maxm`j'_t2_g1 = rect2_g0_`j'[r(r),1]
		
		local minm_`j' = min(`minm`j'_t1_g0',`minm`j'_t2_g0',`minm`j'_t1_g1',`minm`j'_t2_g1')		// Info moda pour l'item j
		local maxm_`j' = max(`maxm`j'_t1_g0',`maxm`j'_t2_g0',`maxm`j'_t1_g1',`maxm`j'_t2_g1')
		local nbm_`j' = `=`maxm_`j''-`minm_`j''+1'

		if `minm_`j'' != 0 & `com_z' == 0 {
			local com_z = 1
		}
		//Recodage des réponses en 0, 1, 2, etc... 
		forvalues r = 0/`=`maxm_`j''-1'  {
			qui replace ``j'' = `r' if ``j'' == `=`r'+`minm_`j'''
			qui replace ``=`j'+`nbitems''' = `r' if ``=`j'+`nbitems''' == `=`r'+`minm_`j'''
		}
		
		// Vérif. Que toutes les modas sont utilisées & concordance entre temps
		forvalues m = 0/`=`nbm_`j''-1' {
			qui count if ``j'' == `m' & `gp' == 0
			local nb_rn1_g0 = r(N)
			qui count if ``j'' == `m' & `gp' == 1
			local nb_rn1_g1 = r(N)
			qui count if ``=`j'+`nbitems''' == `m' & `gp' == 0
			local nb_rn2_g0 = r(N)
			qui count if ``=`j'+`nbitems''' == `m' & `gp' == 1
			local nb_rn2_g1 = r(N)			
			local nb_rn = min(`nb_rn1_g0',`nb_rn2_g0',`nb_rn1_g1',`nb_rn2_g1')
		
			if `nb_rn' == 0 {		// Une moda n'est pas utilisée
				local recoda_`j' = 1
				if  `m' == 0 | `m' < `minm`j'_t1_g0' | `m' < `minm`j'_t2_g0' | `m' < `minm`j'_t1_g1' | `m' < `minm`j'_t2_g1' { // La moda 0 n'est pas utilisée			
					local stop = 1
					forvalues k = 1/`=`nbm_`j''-`m'' {
						qui count if ``j'' == `=`m' + `k'' & `gp' == 0
						local v`k'1_0 = r(N)
						qui count if ``j'' == `=`m' + `k'' & `gp' == 1
						local v`k'1_1 = r(N)
						qui count if ``=`j'+`nbitems''' == `=`m' + `k'' & `gp' == 0
						local v`k'2_0 = r(N)
						qui count if ``=`j'+`nbitems''' == `=`m' + `k'' & `gp' == 1
						local v`k'2_1 = r(N)
						if (`v`k'1_0' != 0 | `v`k'2_0' != 0 | `v`k'1_1' != 0 | `v`k'2_1' != 0) & `stop' != 0 {
							qui replace ``j''= `=`m'+`k'' if ``j''==`m'
							qui replace ``=`j'+`nbitems'''=`=`m'+`k'' if ``=`j'+`nbitems'''==`m'	
							di  "WARNING: items ``j'' & ``=`j'+`nbitems''': answers `m' and `=`m'+`k'' merged"
							local stop = 0
						}
					}
				}
				else if `m' == `=`nbm_`j''-1' | `m' >= `maxm`j'_t2_g0' | `m' >= `maxm`j'_t1_g1' | `m' >= `maxm`j'_t2_g1' {	// La moda max n'est pas utilisée
					local stop = 1
					forvalues k = 1/`=`m'' {
						qui count if ``j'' == `=`m' - `k'' & `gp' == 0
						local v`k'1_0 = r(N)
						qui count if ``j'' == `=`m' - `k'' & `gp' == 1
						local v`k'1_1 = r(N)
						qui count if ``=`j'+`nbitems''' == `=`m' - `k'' & `gp' == 0
						local v`k'2_0 = r(N)
						qui count if ``=`j'+`nbitems''' == `=`m' - `k'' & `gp' == 1
						local v`k'2_1 = r(N)
						if (`v`k'1_0' != 0 | `v`k'2_0' != 0 | `v`k'1_1' != 0 | `v`k'2_1' != 0 ) & `stop' != 0 {
							qui replace ``j''= `=`m' - `k'' if ``j''==`m'
							qui replace ``=`j'+`nbitems'''= `=`m' - `k'' if ``=`j'+`nbitems'''==`m'
							di  "WARNING: items ``j'' & ``=`j'+`nbitems''': answers `m' and `=`m'-`k'' merged"
							local stop = 0
						}
					}
				} 
				else {														// Moda central non utilisée
					if runiform()>0.5{											// Tirage au sort pour regrouper
						local stop = 1
						forvalues k = 1/`m' {
							qui count if ``j'' == `=`m' - `k'' & `gp' == 0
							local v`k'1_0 = r(N)
							qui count if ``j'' == `=`m' - `k'' & `gp' == 1
							local v`k'1_1 = r(N)
							qui count if ``=`j'+`nbitems''' == `=`m' - `k'' & `gp' == 0
							local v`k'2_0 = r(N)
							qui count if ``=`j'+`nbitems''' == `=`m' - `k'' & `gp' == 1
							local v`k'2_1 = r(N)
							if (`v`k'1_0' != 0 | `v`k'2_0' != 0 | `v`k'1_1' != 0 | `v`k'2_1' != 0) & `stop' != 0 {
								qui replace ``j''= `=`m'-`k'' if ``j''==`m'
								qui replace ``=`j'+`nbitems'''=`=`m'-`k'' if ``=`j'+`nbitems'''==`m'	
								di  "WARNING: items ``j'' & ``=`j'+`nbitems''': answers `m' and `=`m'-`k'' merged"
								local stop = 0
							}
						}
					}
					else {
						local stop = 1
						forvalues k = 1/`=`nbm_`j''-`m'' {
							qui count if ``j'' == `=`m' + `k'' & `gp' == 0
							local v`k'1_0 = r(N)
							qui count if ``j'' == `=`m' + `k'' & `gp' == 1
							local v`k'1_1 = r(N)
							qui count if ``=`j'+`nbitems''' == `=`m' + `k'' & `gp' == 0
							local v`k'2_0 = r(N)
							qui count if ``=`j'+`nbitems''' == `=`m' + `k'' & `gp' == 1
							local v`k'2_1 = r(N)
							if (`v`k'1_0' != 0 | `v`k'2_0' != 0 | `v`k'1_1' != 0 | `v`k'2_1' != 0) & `stop' != 0{
								qui replace ``j''=`=`m' + `k'' if ``j''==`m'
								qui replace ``=`j'+`nbitems'''=`=`m' + `k'' if ``=`j'+`nbitems'''==`m'
								di  "WARNING: items ``j'' & ``=`j'+`nbitems''': answers `m' and `=`m'+`k'' merged"
								local stop = 0
							}
							else {
								if `stop' != 0 {
									qui replace ``j''= `nbm_`j'' if ``j''==`m'
									qui replace ``=`j'+`nbitems'''= `nbm_`j'' if ``=`j'+`nbitems'''==`m'
									di  "WARNING: items ``j'' & ``=`j'+`nbitems''': answers `m' and `nbm_`j'' merged"
									local stop = 0
								}
							}
						}
					}
				}
			}
		}
	}
}

if `com_z' == 1 {
	di
	di "WARNING : Automatic recoding, the first response category is 0. see {help rosali:help rosali}."
	di
}

forvalues j =1/`nbitems' {
		qui tab ``j'', matrow(rec)					// Récupération des infos moda du temps 1
		local nbm`j'_t1 = r(r)
		
		qui tab ``=`j'+`nbitems''' 					// Récupération des infos moda du temps 2
		local nbm`j'_t2 = r(r)

	local nbm_`j' = max(`nbm`j'_t1', `nbm`j'_t2')
	//Recodage des réponses en 0, 1, 2, etc... 
	forvalues r = 0/`=`nbm_`j''-1'  {
		qui replace ``j'' = `r' if ``j'' == `=rec[`=`r'+1',1]'
		qui replace ``=`j'+`nbitems''' = `r' if ``=`j'+`nbitems''' == `=rec[`=`r'+1',1]'
	}
}

/* Calcul de nbmoda & nbdif */
forvalues j = 1/`nbitems' {
	qui tab ``j''
	local nbmoda_`j' = r(r)
	local nbdif_`j' = r(r) - 1
}

local maxdif = 0
local nbmoda_sum = 0
forvalues j = 1/`nbitems' {
	if `maxdif' < `nbdif_`j'' {
		local maxdif = `nbdif_`j''
	}
	local nbmoda_sum = `nbmoda_sum' + `nbdif_`j''
}

/* Au moins 2 moda par item */
forvalues j=1/`nbitems' {
	if `nbmoda_`j'' == 1 {
	di as error "``j'' have only one response category, the analysis can be performed only if each item has at least 2 response categories"
		error 198
		exit
	}
}

local coln ""
forvalues j =1 /`nbitems' {
	local coln "`coln' ``j''"
}

matrix nbmod = J(2,`nbitems',.)

matrix colnames nbmod = `coln'
matrix rownames nbmod = NbModa Recoding

forvalues j = 1/`nbitems' {
	matrix nbmod[1,`j'] = `nbmoda_`j''
	matrix nbmod[2,`j'] = `recoda_`j''
}
	
*Erreur si plus de 200 difficultés
local nb_test = 0
forvalues j=1/`nbitems' {
	local nb_test = `nb_test'+`nbmoda_`j'' -1
}

if `nb_test' >= 200 {
	di as error "The total number of items difficulties to be estimated must be less than 200 ({hi:moda} option option)."
	error 198
	exit
}	

local nbitp = 0

forvalues j = 1/`nbitems' {	
	if `nbmoda_`j'' >= 2 {
		local nbitp = `nbitp' + 1
	}
}

qui count
local nbpat = r(N)


/*********************************
* AFFICHAGE INITIAL
*********************************/
di
di _col(5) "{hline 78}"
di  _col(15) "Time 1" _col(42) "Time 2" _col(65) "Nb of Answer Cat."
di _col(5) "{hline 78}"
forvalues j=1/`nbitems' {
    di as text _col(15) abbrev("``j''",20)  _col(42) abbrev("``=`j'+`nbitems'''",20) _col(65) `nbmoda_`j'' 
}
di _col(5) "{hline 78}"
if "`group'" != "" {
	di _col(10) "Nb of patients: "  abbrev("`gp'",20) " 0 = `nbp_gp0' ;", abbrev("`gp'",20) " 1 = `nbp_gp1'" 
	di _col(5) "{hline 78}"
}
else {
	di _col(10) "Nb. of patients: `nbpat'"
	di _col(5) "{hline 78}"
}
di
if `nbitems' == 1 {
	di as error "The analysis can only be performed with at least 2 items."
	error 198
	exit
}
forvalues j = 1/`nbitems' {
	if `nbmoda_`j'' == 2 {
		di "WARNING: ``j'' has only 2 response categories, no distinction can be made between uniform or non-uniform recalibration."
	}
	if `nbmoda_`j'' == 1 {
		di as error "Only `nbmoda_`j'' response categories of item ``j'' were used by the sample, the analysis cannot be performed."
		error 198
		exit
	}
	if `nbmoda_`j'' == 0 {
		di as error "No response categories of item ``j'' were used by the sample, the analysis cannot be performed."
		error 198
		exit
	}
}
di
if "`group'" != "" {
	di _col(2) as text "For all models : - mean of the latent trait in `gp' 0 at time 1 is constrained at 0"
	di _col(19) "- equality of variances between groups"
	di
}
else {
	di _col(2) as text "For all models : mean of the latent trait at time 1 is constrained at 0"
	di
}


	
/*********************************
* DEFINITION DES CONTRAINTES
*********************************/

if "`group'"!="" { // Contraintes si option groupe
	*EGALITE ENTRE GROUPES A T1 (1-200)
	forvalues j=1/`nbitems'{
		forvalues p=1/`nbdif_`j''{
			constraint `=0+`maxdif'*(`j'-1)+`p'' [`p'.``j'']0bn.`gp'=[`p'.``j'']1.`gp'
		}
	}

	*DIF UNIFORME A T1 (201-400)
	forvalues j=1/`nbitems'{
		forvalues p=2/`nbdif_`j''{
			constraint `=200+`maxdif'*(`j'-1)+`p'' [`p'.``j'']1.`gp'-[`p'.``j'']0bn.`gp'=`p'*[1.``j'']1.`gp'-`p'*[1.``j'']0bn.`gp'
		}
	}

	*EGALITES ENTRE T1 et T2, groupe 0 (401-600)
	forvalues j=1/`nbitems'{
		forvalues p=1/`nbdif_`j''{
			constraint `=400+`maxdif'*(`j'-1)+`p'' [`p'.``j'']0bn.`gp'=[`p'.``=`j'+`nbitems''']0bn.`gp'
		}
	}

	*EGALITES ENTRE T1 et T2, groupe 1 (601-800)
	forvalues j=1/`nbitems'{
		forvalues p=1/`nbdif_`j''{
			constraint `=600+`maxdif'*(`j'-1)+`p'' [`p'.``j'']1.`gp'=[`p'.``=`j'+`nbitems''']1.`gp'
		}
	}

	* RC COMMUNE (801-1000)
	forvalues j=1/`nbitems'{
		forvalues p=1/`nbdif_`j''{
			constraint `=800+`maxdif'*(`j'-1)+`p'' [`p'.``=`j'+`nbitems''']0bn.`gp'-[`p'.``j'']0bn.`gp'=[`p'.``=`j'+`nbitems''']1.`gp'-[`p'.``j'']1.`gp'
		}
	}

	* RC UNIFORME, groupe 0 (1001-1200)
	forvalues j=1/`nbitems'{
		forvalues p=2/`nbdif_`j''{
			constraint `=1000+`maxdif'*(`j'-1)+`p'' `p'*([1.``=`j'+`nbitems''']0bn.`gp'-[1.``j'']0bn.`gp')=[`p'.``=`j'+`nbitems''']0bn.`gp'-[`p'.``j'']0bn.`gp'
		}
	}

	* RC UNIFORME, groupe 1 (1201-1400)
	forvalues j=1/`nbitems'{
		forvalues p=2/`nbdif_`j''{
			constraint `=1200+`maxdif'*(`j'-1)+`p'' `p'*([1.``=`j'+`nbitems''']1.`gp'-[1.``j'']1.`gp')=[`p'.``=`j'+`nbitems''']1.`gp'-[`p'.``j'']1.`gp'
		}
	}
	
	*Sans interaction temps x groupe
	constraint 1999 [/]:mean(THETA2)#1.`gp'-[/]:mean(THETA2)#0bn.`gp'=[/]:mean(THETA1)#1.`gp'-[/]:mean(THETA1)#0bn.`gp'
}
else { //Contraintes si pas d'option groupe
	*EGALITE ENTRE T1 et T2 (401-600)
	forvalues j=1/`nbitems'{
		forvalues p=1/`nbdif_`j''{
			constraint `=400+`maxdif'*(`j'-1)+`p'' [`p'.``j'']:_cons = [`p'.``=`j'+`nbitems''']:_cons
		}
	}
	*RC UNIFORME (1001-1200)
	forvalues j=1/`nbitems'{
		forvalues p=2/`nbdif_`j''{
			constraint `=1000+`maxdif'*(`j'-1)+`p'' `p'*([1.``=`j'+`nbitems''']:_cons - [1.``j'']:_cons)=[`p'.``=`j'+`nbitems''']:_cons -[`p'.``j'']:_cons
		}
	}
}

/*********************************
* MATRICE DES RESULTATS
*********************************/
matrix dif_rc=J(`nbitems',8,.)
matrix colnames dif_rc=DIFT1 DIFU RC RC_DIF RCG0 RCUG0 RCG1 RCUG1
local rown ""

forvalues j =1 /`nbitems' {
	local rown "`rown' ``j''"
}
matrix rownames dif_rc = `rown'

*Nb modalité max
local nbdif_max = 0
forvalues j=1/`nbitems' {
	if `nbdif_max' < `nbdif_`j'' {
		local nbdif_max = `nbdif_`j''
	}
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////					PARTIE 1 : DIF A T1 ?						////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

if "`group'"!="" & "`nodif'"=="" { // PARTIE 1 = Slmt si option group & pas de "nodif"

		di _dup(49) "_ "
		di
		di  as input "PART 1: DETECTION OF DIFFERENCE IN ITEM DIFFICULTIES BETWEEN GROUPS AT TIME 1"
	
	*********************************
	**			MODEL B			   **
	*********************************
	
	local model ""
	forvalues j=1/`nbitems'{
		forvalues p=1/`nbdif_`j''{
			local model "`model' (`p'.``j''<-THETA@`p')"
		}
	}

	qui gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading cons) var(0: THETA@v) var(1:THETA@v) latent(THETA) nocapslatent
	/* Stockage des estimations du modèle */
	estimates store modeldifB
	matrix val_mB = r(table)
	matrix esti_B = e(b)


	/* Calcul des difficultés d'item (delta_j) */
	matrix delta_mB=J(`nbitems',`=`nbdif_max'*2',.)
	local name_partOneC ""
	
	forvalues p=1/`nbdif_max' {
		forvalues g=0/1 {
			local name_partOneC "`name_partOneC' delta_`p'_gp`g'"
		}
	}
	local name_partOneL ""
	
	forvalues j=1/`nbitems' {
			local name_partOneL "`name_partOneL' ``j''"
	}
	
	matrix colnames delta_mB = `name_partOneC'
	matrix rownames delta_mB = `name_partOneL'
		matrix delta_mB_se=J(`nbitems',`=`nbdif_max'*2',.)
	local name_partOneC_se ""

	forvalues p=1/`nbdif_max' {
		forvalues g=0/1 {
			local name_partOneC_se "`name_partOneC_se' delta_`p'_gp`g'_se"
		}
	}

	matrix colnames delta_mB_se = `name_partOneC_se'
	matrix rownames delta_mB_se = `name_partOneL'
	
	forvalues j=1/`nbitems'{
		forvalues p=1/`nbdif_`j''{
			forvalues g=0/1{
				qui lincom -[`p'.``j'']:`g'.`gp'
				local delta`j'_`p'g`g'mB=r(estimate)
				local delta`j'_`p'g`g'mB_se=r(se)	
				if `p'>1{
					qui lincom [`=`p'-1'.``j'']:`g'.`gp' - [`p'.``j'']:`g'.`gp' 
					local delta`j'_`p'g`g'mB = r(estimate)
					local delta`j'_`p'g`g'mB_se = r(se)
				}
				matrix delta_mB[`j',`=2*`p'-1+`g'']=`delta`j'_`p'g`g'mB'
				matrix delta_mB_se[`j',`=2*`p'-1+`g'']=`delta`j'_`p'g`g'mB_se'
			}
		}
	}

	matrix var_mB = (val_mB[1,"/var(THETA)#0bn.`gp'"]\val_mB[2,"/var(THETA)#0bn.`gp'"])

	/*group effect*/
	qui lincom [/]:mean(THETA)#1.`gp'-[/]:mean(THETA)#0bn.`gp'
	local geffmB=r(estimate)
	local segeffmB=r(se)
	qui test [/]:mean(THETA)#1.`gp'-[/]:mean(THETA)#0bn.`gp'=0
	local gcmBp=r(p)
	local gcmBchi=r(chi2)
	local gcmBdf=r(df)
	

	*********************************
	**			MODEL A			   **
	*********************************

	local model ""
	forvalues j=1/`nbitems'{
		forvalues p=1/`nbdif_`j''{
			local model "`model' (`p'.``j''<-THETA@`p')"
		}
	}

	 qui gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading means) var(0: THETA@v) var(1:THETA@v) from(esti_B, skip) latent(THETA) nocapslatent

	/* Stockage des estimations du modèle */
	estimates store modeldifA
	matrix val_mA = r(table)
	matrix esti_A = e(b)

	/* Calcul des difficultés d'item (delta_j) */
	matrix delta_mA=J(`nbitems',`=`nbdif_max'*2',.)
	local name_partOneC ""
	
	forvalues p=1/`nbdif_max' {
		forvalues g=0/1 {
			local name_partOneC "`name_partOneC' delta_`p'_gp`g'"
		}
	}
	local name_partOneL ""
	
	forvalues j=1/`nbitems' {
			local name_partOneL "`name_partOneL' ``j''"
	}
	matrix colnames delta_mA = `name_partOneC'
	matrix rownames delta_mA = `name_partOneL'
	matrix delta_mA_se=J(`nbitems',`=`nbdif_max'*2',.)
	local name_partOneC_se ""

	forvalues p=1/`nbdif_max' {
		forvalues g=0/1 {
			local name_partOneC_se "`name_partOneC_se' delta_`p'_gp`g'_se"
		}
	}

	matrix colnames delta_mA_se = `name_partOneC_se'
	matrix rownames delta_mA_se = `name_partOneL'

	forvalues j=1/`nbitems'{
		forvalues p=1/`nbdif_`j''{
			forvalues g=0/1{
				qui lincom -[`p'.``j'']:`g'.`gp'
				local delta`j'_`p'g`g'mA=r(estimate)
				local delta`j'_`p'g`g'mA_se=r(se)	
				if `p'>1{
					qui lincom [`=`p'-1'.``j'']:`g'.`gp' - [`p'.``j'']:`g'.`gp' 
					local delta`j'_`p'g`g'mA = r(estimate)
					local delta`j'_`p'g`g'mA_se = r(se)
				}
				matrix delta_mA[`j',`=2*`p'-1+`g'']=`delta`j'_`p'g`g'mA'
				matrix delta_mA_se[`j',`=2*`p'-1+`g'']=`delta`j'_`p'g`g'mA_se'
			}
		}
	}
	//Variance et se mA
	matrix var_mA = (val_mA[1,"/var(THETA)#0bn.`gp'"]\val_mA[2,"/var(THETA)#0bn.`gp'"])
	

	*************************************************************
	***********************AFFICHAGE*****************************
	*************************************************************
	

	//Affichage modèle A
	di 
	di as input "PROCESSING STEP A"
	di
		
	if "`detail'" != "" {		
		/* Affichage des estimations des difficultés modèle A */
		
		di  _col(5) as text "{ul:MODEL A:} Overall measurement non-invariance between groups"
		di
		di %~85s as text "Item difficulties: estimates (s.e.)"
		di _col(10) "{hline 65}"
		di  _col(31) as text abbrev("`gp'",20) "=0" _col(57) abbrev("`gp'",20) "=1"
		di _col(10) "{hline 65}"
		forvalues j=1/`nbitems' {
			di as text _col(10) abbrev("``j''", 18) 
			forvalues p=1/`nbdif_`j'' {
				di as text _col(10) "`p'" as result _col(30) %6.2f `delta`j'_`p'g0mA'  %6.2f " (" %3.2f `delta`j'_`p'g0mA_se' ")"  _col(56) %6.2f `delta`j'_`p'g1mA' " (" %3.2f  `delta`j'_`p'g1mA_se' ")"
			}
		}
		di as text _col(10) "{hline 65}"
		/* Affichage des estimations sur le trait latent du modèle A */
		di
		di %~85s as text "Latent trait distribution"
		di _col(10) "{hline 65}"
		di _col(31) "Estimate" _col(57) "Standard error"
		di _col(10) "{hline 65}"
		di _col(10)  "Variance" as result _col(31) %6.2f `=var_mA[1,1]' _col(55) %6.2f `=var_mA[2,1]'
		di _col(10) as text "Group effect" as result _col(31) "0 (constrained)" 
		di _col(10) as text "{hline 65}"
		di
		di _col(10) as text "No group effect: equality of the latent trait means between groups"
		di _col(10) as text "All item difficulties are freely estimated in both groups"
		di
	}
		//*Affichage modèle B

		di 
		di as input "PROCESSING STEP B"
		di
		
			/* Affichage des estimations des difficultés modèle B */
	if "`detail'" != "" {		
		di  _col(5) as text "{ul:MODEL B:} Overall measurement invariance between groups"
		di
		di %~85s as text "Item difficulties: estimates (s.e.)"
		di _col(10) "{hline 65}"
		di  _col(31) abbrev("`gp'",20) "=0" _col(57) abbrev("`gp'",20) "=1"
		di _col(10) "{hline 65}"
		
		forvalues j=1/`nbitems' {
			di _col(10) as text "``j''" 
			forvalues p=1/`nbdif_`j'' {
				di as text _col(10) "`p'" as result _col(30) %6.2f `delta`j'_`p'g0mB' " (" %3.2f `delta`j'_`p'g0mB_se' ")"   _col(56) %6.2f `delta`j'_`p'g1mB' " (" %3.2f `delta`j'_`p'g1mB_se' ")"
			}
		}
		
		di _col(10) as text "{hline 65}"
			/* Affichage des estimations sur le trait latent du modèle B */
		di
		di %~85s as text "Latent trait distribution"
		di _col(10) "{hline 65}"
		di _col(28) "Estimate" _col(42) "Standard error" _col(62) "P-value"
		di _col(10) "{hline 65}"
		di _col(10)  "Variance" as result _col(28) %6.2f `=var_mB[1,1]' _col(40) %6.2f `=var_mB[2,1]'
		di _col(10) as text "Group effect" as result _col(28) %6.2f `geffmB' _col(40) %6.2f `segeffmB' _col(62) %6.4f `gcmBp'
		di _col(10) as text "{hline 65}"
		di
		di _col(10) as text "Group effect estimated: mean of the latent trait of group 1 freely estimated"
		di _col(10) "Equality of the item difficulties between groups"
		di
	}
		
		*****************************************************
		*			Modèle A vs Modèle B 					*
		*****************************************************
		
		qui lrtest modeldifA modeldifB
		local diftestp=r(p)
		local diftestchi=r(chi2)
		local diftestdf=r(df)
	if "`detail'" != "" {	
		//affichage lrtest
		di as input "LIKELIHOOD-RATIO TEST"
		di
		di %~60s "Model A vs Model B"
		di _col(10) "{hline 40}"
		di _col(10) as text "Chi-square" _col(28) "DF" _col(40) "P-value"
		di _col(10) as result %6.2f `diftestchi' _col(28) %2.0f `diftestdf' _col(40) %6.4f `diftestp'
		di _col(10) as text "{hline 40}"
		di
	}

	if `diftestp'<0.05{
		di as result "DIFFERENCE IN ITEM DIFFICULTIES BETWEEN GROUPS LIKELY"
	}
	else{
		di as result "NO DIFFERENCE BETWEEN GROUPS DETECTED"
	}
	*********************************
	*************MODEL C*************
	*********************************
	// Etape itérative si lrtest significatif
	local nb_stepC = 0
	if `diftestp'<0.05{  /*If pvalue(LRtest)<0.05 then step C*/
		di 
		di as input "PROCESSING STEP C"
		di
		
		/*test DIF pour chaque item*/
		local boucle = 1
		local stop = 0
		while `boucle'<=`=`nbitp'-1' & `stop'==0{ /*on s'arrête quand on a libéré du DIF sur (tous les items-1) ou lorsqu'il n'y a plus de tests significatifs*/
			local nb_stepC = `boucle'
			local pajust=0.05/`=`nbitp'+1-`boucle''
			/*réinitialisation de la matrice de test*/
			matrix test_difu_`boucle'=J(`nbitems',3,.)
			matrix colnames test_difu_`boucle'=chi_DIFU df_DIFU pvalueDIFU
			matrix test_dif_`boucle'=J(`nbitems',3,.)
			matrix colnames test_dif_`boucle'=chi_DIF df_DIF pvalueDIF
			local nbsig=0
			local minpval=1
			local itemdif=0
			if "`detail'" != ""{
				
				di as text "Loop `boucle'"
				di as text _col(5) "Adjusted  alpha: " %6.4f  `pajust'
				di
				di as text _col(10) "{hline 65}"
				di as text _col(10) "Freed item" _col(31) "Chi-Square"  _col(48) "DF" _col(57) "P-Value"
				di as text _col(10) "{hline 65}"
			}
			/*boucle de test*/
			forvalues j=1/`nbitems'{
				//if `nbdif_`j'' > 2 {
					local model ""
					local listconst ""
					if dif_rc[`j',1]==. | dif_rc[`j',1]==0 { /*si pas de DIF déjà détecté sur l'item j*/
						/*on libère le DIF de l'item i: pas de contraintes*/
						forvalues k=1/`nbitems'{ /*contraintes pour les autres items (si DIF NU sur item k, pas de contraintes*/
							if `k'!=`j' & `nbmoda_`j'' >= 2 {
								if dif_rc[`k',1]==. | dif_rc[`k',1]==0 {/*pas de DIF sur item k: contraintes 1-200*/
									forvalues p=1/`nbdif_`k''{ 
										qui local listconst "`listconst' `=0+`maxdif'*(`k'-1)+`p''"
										qui constraint list `=0+`maxdif'*(`k'-1)+`p''
									}
								}
								else{
									if dif_rc[`k',2]!=. & dif_rc[`k',2]!= 0 & `nbmoda_`k'' > 2 { /*DIF U: contraintes 201-400*/
										forvalues p=2/`nbdif_`k''{
											qui local listconst "`listconst' `=200+`maxdif'*(`k'-1)+`p''"
											qui constraint list `=200+`maxdif'*(`k'-1)+`p''
										}
									}
								}
							}
						}
						forvalues jj=1/`nbitems'{
							forvalues p=1/`nbdif_`jj''{
								local model "`model' (`p'.``jj''<-THETA@`p')"
							}
						}
						qui gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading) var(0: THETA@v) var(1:THETA@v) constraint(`listconst') from(esti_B) latent(THETA) nocapslatent
						estimates store modeldif3b`boucle'it`i'
				
						*************************
						*****test DIF item i*****
						*************************
						qui test [1.``j'']1.`gp'=[1.``j'']0bn.`gp'
						if `nbmoda_`j'' > 2 {
							forvalues p=2/`nbdif_`j''{
								qui test [`p'.``j'']1.`gp'=[`p'.``j'']0bn.`gp', acc
							}
						}
						matrix test_dif_`boucle'[`j',1]=(r(chi2),r(df),r(p))

						/* Test DIF Uniforme */
						if `nbmoda_`j'' > 2 {
							qui test 2*([1.``j'']1.`gp'-[1.``j'']0bn.`gp')=[2.``j'']1.`gp'-[2.``j'']0bn.`gp'
							forvalues p=3/`nbdif_`j''{
								qui test `p'*([1.``j'']1.`gp'-[1.``j'']0bn.`gp')=[`p'.``j'']1.`gp'-[`p'.``j'']0bn.`gp', acc
							}
							matrix test_difu_`boucle'[`j',1]=(r(chi2), r(df), r(p))
						}							

						if test_dif_`boucle'[`j',3]<`pajust'{/*si DIF sur item i*/
							local ++nbsig
							if test_dif_`boucle'[`j',3]<`minpval'{
								local minpval=test_dif_`boucle'[`j',3]
								local itemdif=`j'
							}
						}
						if "`detail'" != "" {
							di as text  _col(10) abbrev("``j''",15)  as result _col(31) %6.3f test_dif_`boucle'[`j',1] _col(48) test_dif_`boucle'[`j',2] _col(57)  %6.4f test_dif_`boucle'[`j',3]
						}
					}
			}			
			/*si nb de tests significatifs=0, on arrête*/
			if `nbsig'==0{
				local stop=1
				if `boucle' == 1 {
					if "`detail'" != "" {
						di as text _col(10) "{hline 65}"
						di
						di as result  "No significant test: no difference between groups detected, no DIF detected"
						di
					}
				}
				else {
					if "`detail'" != ""{
						di as text _col(10) "{hline 65}"
						di
						di as result "No other significant tests"
						di
					}
				}
			}
			else{/*si nb de tests significatifs>0, mise à jour de la matrice de résultats*/
				matrix dif_rc[`itemdif',1]=`boucle'
				if "`detail'" != ""{
					di as text _col(10) "{hline 65}"
					di 
					di as result "Difference between groups on ``itemdif'' at time 1"
				}
				if `nbmoda_`itemdif'' > 2 {
					if "`detail'" != "" {

						di
						di %~60s as text "Test of uniform difference"
						di _col(10) "{hline 40}"
						di _col(10) as text "Chi-square" _col(28) "DF" _col(40) "P-value"
						di _col(10) as result %4.2f `=test_difu_`boucle'[`itemdif',1]' _col(28) `=test_difu_`boucle'[`itemdif',2]' _col(40) %4.2f `=test_difu_`boucle'[`itemdif',3]'
						di _col(10) as text "{hline 40}"
					}
					if test_difu_`boucle'[`itemdif',3]<0.05{	/*DIF NU détectée*/
						matrix dif_rc[`itemdif',2]=0						
							di
							di as result "``itemdif'' : Non-uniform differences of item difficulties between groups at T1"
							di 			
					}
					else{/*DIF U détectée*/
						matrix dif_rc[`itemdif',2]=`boucle'
							di
							di as result "``itemdif'' : Uniform differences of item difficulties between groups at T1"
							di 			
					}
				}
				else {
					// Différence entre groupes au temps 1 mais slmt 2 moda. donc pas de U ou NU
					di _col(15) _dup(60) "-"
				}
			}		
			local ++boucle
		}
	}

	/* MODELE FINAL DE LA PARTIE 1. Si DIFT1 détecté (=Au moins 2 boucles dans l'étape C)*/
	if `nb_stepC' > 1 {
		forvalues j=1/`nbitems'{
			local model ""
			local listconst ""
			if dif_rc[`j',1]==. | dif_rc[`j',1]==0 { /*si pas de DIF: contraintes 1-200*/
				forvalues p=1/`nbdif_`j''{ 
					qui local listconst "`listconst' `=0+`maxdif'*(`j'-1)+`p''"
					qui constraint list `=0+`maxdif'*(`j'-1)+`p''
				}
			}
			else {
				if dif_rc[`j',2]!=. & dif_rc[`j',2]!=0 { /*DIF U: contraintes 201-400*/
					forvalues p=2/`nbdif_`j''{
						qui local listconst "`listconst' `=200+`maxdif'*(`j'-1)+`p''"
						qui constraint list `=200+`maxdif'*(`j'-1)+`p''
					}
				}
			}
		}
		forvalues j=1/`nbitems'{
			forvalues p=1/`nbdif_`j''{
				local model "`model' (`p'.``j''<-THETA@`p')"
			}
		}

		qui gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading) var(0: THETA@v) var(1:THETA@v) constraint(`listconst') from(esti_B) latent(THETA) nocapslatent
		/* Stockage des estimations du modèle */
		estimates store modeldifCFin
		matrix val_mC = r(table)

		/* Calcul des difficultés d'item (delta_j) */
		matrix delta_mCFin=J(`nbitems',`=`nbdif_max'*2',.)
		local name_partOneC ""
		forvalues p=1/`nbdif_max' {
			forvalues g=0/1 {
				local name_partOneC "`name_partOneC' delta_`p'_gp`g'"
			}
		}
		local name_partOneL ""
		forvalues j=1/`nbitems' {
			local name_partOneL "`name_partOneL' ``j''"
		}
		matrix colnames delta_mCFin = `name_partOneC'
		matrix rownames delta_mCFin = `name_partOneL'
	
		matrix delta_mCFin_se=J(`nbitems',`=`nbdif_max'*2',.)
		local name_partOneC_se ""

		forvalues p=1/`nbdif_max' {
			forvalues g=0/1 {
				local name_partOneC_se "`name_partOneC_se' delta_`p'_gp`g'_se"
			}
		}
		matrix colnames delta_mCFin_se = `name_partOneC_se'
		matrix rownames delta_mCFin_se = `name_partOneL'
					
		forvalues j=1/`nbitems'{
			forvalues p=1/`nbdif_`j''{
				forvalues g=0/1{
					qui lincom -[`p'.``j'']:`g'.`gp'
					local delta`j'_`p'g`g'mCFin=r(estimate)
					local delta`j'_`p'g`g'mCFin_se=r(se)	
					if `p'>1{
						qui lincom [`=`p'-1'.``j'']:`g'.`gp' - [`p'.``j'']:`g'.`gp' 
						local delta`j'_`p'g`g'mCFin = r(estimate)
						local delta`j'_`p'g`g'mCFin_se = r(se)
					}
					matrix delta_mCFin[`j',`=2*`p'-1+`g'']=`delta`j'_`p'g`g'mCFin'
					matrix delta_mCFin_se[`j',`=2*`p'-1+`g'']=`delta`j'_`p'g`g'mCFin_se'
				}	
			}	
		}
		if "`group'" != "" { //Variance et se mA
			matrix var_mC = (val_mC[1,"/var(THETA)#0bn.`gp'"]\val_mC[2,"/var(THETA)#0bn.`gp'"])
		}
			/*group effect*/
		qui lincom [/]:mean(THETA)#1.`gp'-[/]:mean(THETA)#0bn.`gp'
		local geffmCFin=r(estimate)
		local segeffmCFin=r(se)
		qui	test [/]:mean(THETA)#1.`gp'-[/]:mean(THETA)#0bn.`gp'=0
		local gcmCFinp=r(p)
		local gcmCFinchi=r(chi2)
		local gcmCFindf=r(df)
	}
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////				PARTIE 2 : RECALIBRATION ?						////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

di
di as text _dup(49) "_ "
di 
if "`group'" != "" {
	di as input "PART 2 : DETECTION OF DIFFERENCE IN ITEM DIFFICULTIES ACROSS TIME (RECALIBRATION)"
}
else {
	di as input "DETECTION OF DIFFERENCE IN ITEM DIFFICULTIES ACROSS TIME (RECALIBRATION)"
}

	*********************************
	**			MODEL 2			   **
	*********************************

local listconst "" // liste des contraintes si option groupe
local listconst_g "" //LIste des contraintes sans option groupe (Notation peu logique !!) 

forvalues j=1/`nbitems'{ 
	if "`group'" == "" { // Contraintes pas de RC pour tous les items
		forvalues p=1/`nbdif_`j''{ 
			local listconst_g "`listconst_g' `=400+`maxdif'*(`j'-1)+`p''"
			qui constraint list `=400+`maxdif'*(`j'-1)+`p''
		}
	}
	else {
		if dif_rc[`j',1]==. | dif_rc[`j',1]==0 {/*pas de DIF à T1 sur item k: contraintes 1*/
			forvalues p=1/`nbdif_`j''{ 
				local listconst "`listconst' `=0+`maxdif'*(`j'-1)+`p''"
				qui constraint list `=0+`maxdif'*(`j'-1)+`p''
			}
		}
		else{
			if dif_rc[`j',2]!=. & dif_rc[`j',2] != 0 { /*diff T1 U: contraintes 200*/
				forvalues p=2/`nbdif_`j''{
					local listconst "`listconst' `=200+`maxdif'*(`j'-1)+`p''"
					qui constraint list `=200+`maxdif'*(`j'-1)+`p''
				}
			}
		}
		forvalues p=1/`nbdif_`j''{  /* egalites entre temps : groupe 0 (401-600)*/
			local listconst "`listconst' `=400+`maxdif'*(`j'-1)+`p''"
			qui constraint list `=400+`maxdif'*(`j'-1)+`p''
		}
			forvalues p=1/`nbdif_`j''{  /* egalites entre temps : groupe 1 (601-800)*/
			local listconst "`listconst' `=600+`maxdif'*(`j'-1)+`p''"
			qui constraint list `=600+`maxdif'*(`j'-1)+`p''
		}
	}
}	

local model ""
forvalues j=1/`nbitems'{
	forvalues p=1/`nbdif_`j''{
		local model "`model' (`p'.``j''<-THETA1@`p')(`p'.``=`j'+`nbitems'''<-THETA2@`p')"
	}
}

if "`group'" != "" {
*di "gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading) means(0: THETA1@0 THETA2@m20) means(1: THETA1@m11 THETA2@m21) var(0: THETA1@v1 THETA2@v2) var(1:THETA1@v1 THETA2@v2) cov(0: THETA1*THETA2@cov12) cov(1: THETA1*THETA2@cov12) constraint(`listconst') latent(THETA1 THETA2) nocapslatent"
	qui gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading) means(0: THETA1@0 THETA2@m20) means(1: THETA1@m11 THETA2@m21) var(0: THETA1@v1 THETA2@v2) var(1:THETA1@v1 THETA2@v2) cov(0: THETA1*THETA2@cov12) cov(1: THETA1*THETA2@cov12) constraint(`listconst') latent(THETA1 THETA2) nocapslatent
}
else {
	qui gsem `model', mlogit tol(0.01) iterate(100) means(THETA1@0 THETA2@m20) var(THETA1@v1 THETA2@v2) cov(THETA1*THETA2@cov12) constraint(`listconst_g') latent(THETA1 THETA2) nocapslatent
}

/*Stockage des données du modèle 2 */
estimates store model2
matrix val_m2 = r(table)
matrix esti_2 = e(b)

if "`group'" != "" {
	matrix var_m2 = (val_m2[1,"/var(THETA1)#0bn.`gp'"],val_m2[1,"/var(THETA2)#0bn.`gp'"]\val_m2[2,"/var(THETA1)#0bn.`gp'"],val_m2[2,"/var(THETA2)#0bn.`gp'"])
	matrix covar_m2 = (val_m2[1,"/cov(THETA1,THETA2)#0.`gp'"],val_m2[1,"/cov(THETA1,THETA2)#1.`gp'"]\val_m2[2,"/cov(THETA1,THETA2)#0.`gp'"],val_m2[2,"/cov(THETA1,THETA2)#1.`gp'"]\val_m2[4,"/cov(THETA1,THETA2)#0.`gp'"],val_m2[4,"/cov(THETA1,THETA2)#1.`gp'"])
}
else {
	matrix var_m2 = (val_m2[1,"/var(THETA1)"],val_m2[1,"/var(THETA2)"]\val_m2[2,"/var(THETA1)"],val_m2[2,"/var(THETA2)"])
	matrix covar_m2 = (val_m2[1,"/cov(THETA1,THETA2)"]\val_m2[2,"/cov(THETA1,THETA2)"]\val_m2[4,"/cov(THETA1,THETA2)"])
}

/*group effect*/
if "`group'" != "" {
	qui lincom [/]:mean(THETA1)#1.`gp'-[/]:mean(THETA1)#0bn.`gp'
	local geffm2=r(estimate)
	local segeffm2=r(se)
	local ubgeffm2 = r(ub)
	local lbgeffm2 = r(lb)
	qui test [/]:mean(THETA1)#1.`gp'-[/]:mean(THETA1)#0bn.`gp'=0
	local gpm2p=r(p)
	local gpm2chi=r(chi2)
	local gpm2df=r(df)
}

/*time effect*/
if "`group'" != "" {
	qui lincom [/]:mean(THETA2)#0bn.`gp'-[/]:mean(THETA1)#0bn.`gp'
	local teffm2=r(estimate)
	local seteffm2=r(se)
	local ubteffm2 = r(ub)
	local lbteffm2 = r(lb)
	qui test [/]:mean(THETA2)#0bn.`gp'-[/]:mean(THETA1)#0bn.`gp'=0
	local tm2p=r(p)
	local tm2chi=r(chi2)
	local tm2df=r(df)
}
else {
	qui lincom [/]:mean(THETA2) /* [/]:mean(THETA1)*/
	local teffm2=r(estimate)
	local seteffm2=r(se)
	local ubteffm2 = r(ub)
	local lbteffm2 = r(lb)
	qui test [/]:mean(THETA2) = 0 /* [/]:mean(THETA1)*/
	local tm2p=r(p)
	local tm2chi=r(chi2)
	local tm2df=r(df)
}

*INTERACTION
if "`group'" != "" {
	qui lincom [/]:mean(THETA2)#1.`gp'-[/]:mean(THETA2)#0bn.`gp'-[/]:mean(THETA1)#1.`gp'+[/]:mean(THETA1)#0bn.`gp'
	local interm2=r(estimate)
	local seinterm2=r(se)
	local ubinterm2 = r(ub)
	local lbinterm2 = r(lb)
	qui test [/]:mean(THETA2)#1.`gp'-[/]:mean(THETA2)#0bn.`gp'-[/]:mean(THETA1)#1.`gp'+[/]:mean(THETA1)#0bn.`gp' = 0
	local interm2p=r(p)
	local interm2chi=r(chi2)
	local interm2df=r(df)
}

if "`group'" != "" {
	matrix mod2 = J(7,`=`nbmoda_sum'*4+6',.)
	local name_partTwoC ""
	forvalues j = 1/`nbitems' {
		forvalues p=1/`nbdif_`j'' {
			forvalues t=1/2 {
				forvalues g = 0/1 {
					local name_partTwoC "`name_partTwoC' d_j`j'_p`p'_gp`g'_t`t'"
				}
			}
		}
	}
	local name_partTwoC "`name_partTwoC' VAR(THETA1) VAR(THETA2) COV(TH1,TH2) GROUP_Effect TIME_Effect INTER_TxG  "
	matrix colnames mod2 = `name_partTwoC'
	matrix rownames mod2 =  Estimate se Upper_b Lower_b Chi_square DF pvalue
}
else {
	matrix mod2 = J(7,`=`nbmoda_sum'*2+4',.)
	local name_partTwoC ""
	forvalues j = 1/`nbitems' {
		forvalues p=1/`nbdif_`j'' {
			forvalues t=1/2 {
				local name_partTwoC "`name_partTwoC' d_j`j'_p`p'_t`t'"
			}
		}
	}
	local name_partTwoC "`name_partTwoC' VAR(THETA1) VAR(THETA2) COV(TH1,TH2) TIME_Effect "
	matrix colnames mod2 = `name_partTwoC'
	matrix rownames mod2 =  Estimate se Upper_b Lower_b Chi_square DF pvalue
}

*Difficultés
forvalues j=1/`nbitems'{
	forvalues p=1/`nbdif_`j''{	
		forvalues t=1/2{
			if "`group'" != "" { // groupe binaire
				forvalues g=0/1 {
					qui lincom -[`p'.``=(`t'-1)*`nbitems'+`j''']:`g'.`gp'
					local delta`t'_`j'_`p'g`g'm2= r(estimate)
					local delta`t'_`j'_`p'g`g'm2_se= r(se)
					local delta`t'_`j'_`p'g`g'm2_ub=r(ub)
					local delta`t'_`j'_`p'g`g'm2_lb=r(lb)
					local delta`t'_`j'_`p'g`g'm2_p=r(p)
					if `p'>1 {
						qui lincom [`=`p'-1'.``=(`t'-1)*`nbitems'+`j''']:`g'.`gp' - [`p'.``=(`t'-1)*`nbitems'+`j''']:`g'.`gp'
						local delta`t'_`j'_`p'g`g'm2=r(estimate)
						local delta`t'_`j'_`p'g`g'm2_se=r(se)
						local delta`t'_`j'_`p'g`g'm2_ub=r(ub)
						local delta`t'_`j'_`p'g`g'm2_lb=r(lb)
						local delta`t'_`j'_`p'g`g'm2_p=r(p)
					}
					local place = 0
					local compt = 1
					while `compt' < `j' {
						local place = `place' + `nbdif_`compt''
						local ++compt
					}
					if `t' == 1 {
						matrix mod2[1,`=4*(`p'-1)+`g'+`t'+4*`place'']=`delta`t'_`j'_`p'g`g'm2'
						matrix mod2[2,`=4*(`p'-1)+`g'+`t'+4*`place'']=`delta`t'_`j'_`p'g`g'm2_se'
						matrix mod2[3,`=4*(`p'-1)+`g'+`t'+4*`place'']=`delta`t'_`j'_`p'g`g'm2_ub'
						matrix mod2[4,`=4*(`p'-1)+`g'+`t'+4*`place'']=`delta`t'_`j'_`p'g`g'm2_lb'
						matrix mod2[7,`=4*(`p'-1)+`g'+`t'+4*`place'']=`delta`t'_`j'_`p'g`g'm2_p'
					}
					if `t' == 2 {
						matrix mod2[1,`=4*(`p'-1)+`g'+`t'+1+4*`place'']=`delta`t'_`j'_`p'g`g'm2'
						matrix mod2[2,`=4*(`p'-1)+`g'+`t'+1+4*`place'']=`delta`t'_`j'_`p'g`g'm2_se'
						matrix mod2[3,`=4*(`p'-1)+`g'+`t'+1+4*`place'']=`delta`t'_`j'_`p'g`g'm2_ub'
						matrix mod2[4,`=4*(`p'-1)+`g'+`t'+1+4*`place'']=`delta`t'_`j'_`p'g`g'm2_lb'
						matrix mod2[7,`=4*(`p'-1)+`g'+`t'+1+4*`place'']=`delta`t'_`j'_`p'g`g'm2_p'
					}
				}
			}
			else { // groupe unique (=gp0)
				qui lincom -[`p'.``=(`t'-1)*`nbitems'+`j''']_cons
				local delta`t'_`j'_`p'g0m2= r(estimate)
				local delta`t'_`j'_`p'g0m2_se= r(se)
				local delta`t'_`j'_`p'g0m2_ub=r(ub)
				local delta`t'_`j'_`p'g0m2_lb=r(lb)
				local delta`t'_`j'_`p'g0m2_p=r(p)
				if `p'>1{
					qui lincom [`=`p'-1'.``=(`t'-1)*`nbitems'+`j''']_cons - [`p'.``=(`t'-1)*`nbitems'+`j''']_cons
					local delta`t'_`j'_`p'g0m2=r(estimate)
					local delta`t'_`j'_`p'g0m2_se=r(se)
					local delta`t'_`j'_`p'g0m2_ub=r(ub)
					local delta`t'_`j'_`p'g0m2_lb=r(lb)
					local delta`t'_`j'_`p'g0m2_p=r(p)
				}
				local place = 0
				local compt = 1
				while `compt' < `j' {
					local place = `place' + `nbdif_`compt''
					local ++compt
				}
				if `t' == 1 {
					matrix mod2[1,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m2'
					matrix mod2[2,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m2_se'
					matrix mod2[3,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m2_ub'
					matrix mod2[4,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m2_lb'
					matrix mod2[7,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m2_p'
				}
				if `t' == 2 {
					matrix mod2[1,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m2'
					matrix mod2[2,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m2_se'
					matrix mod2[3,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m2_ub'
					matrix mod2[4,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m2_lb'
					matrix mod2[7,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m2_p'
				}
			}
		}
	}
}

if "`group'" != "" {
	matrix mod2[1,`=4*`nbmoda_sum'+1'] = (val_m2[1,"/var(THETA1)#0bn.`gp'"], val_m2[1,"/var(THETA2)#0bn.`gp'"])
	matrix mod2[2,`=4*`nbmoda_sum'+1'] = (val_m2[2,"/var(THETA1)#0bn.`gp'"],val_m2[2,"/var(THETA2)#0bn.`gp'"])
	matrix mod2[3,`=4*`nbmoda_sum'+1'] = (val_m2[6,"/var(THETA1)#0bn.`gp'"],val_m2[6,"/var(THETA2)#0bn.`gp'"])
	matrix mod2[4,`=4*`nbmoda_sum'+1'] = (val_m2[5,"/var(THETA1)#0bn.`gp'"],val_m2[5,"/var(THETA2)#0bn.`gp'"])
	
	matrix mod2[1,`=4*`nbmoda_sum'+2+1'] = (val_m2[1,"/cov(THETA1,THETA2)#0.`gp'"])
	matrix mod2[2,`=4*`nbmoda_sum'+2+1'] = (val_m2[2,"/cov(THETA1,THETA2)#0.`gp'"])
	matrix mod2[3,`=4*`nbmoda_sum'+2+1'] = (val_m2[6,"/cov(THETA1,THETA2)#0.`gp'"])
	matrix mod2[4,`=4*`nbmoda_sum'+2+1'] = (val_m2[5,"/cov(THETA1,THETA2)#0.`gp'"])

	matrix mod2[1,`=4*`nbmoda_sum'+2+1+1'] = `geffm2'
	matrix mod2[2,`=4*`nbmoda_sum'+2+1+1'] = `segeffm2'
	matrix mod2[3,`=4*`nbmoda_sum'+2+1+1'] = `ubgeffm2'
	matrix mod2[4,`=4*`nbmoda_sum'+2+1+1'] = `lbgeffm2'	
	matrix mod2[5,`=4*`nbmoda_sum'+2+1+1'] = `gpm2chi'
	matrix mod2[6,`=4*`nbmoda_sum'+2+1+1'] = `gpm2df'
	matrix mod2[7,`=4*`nbmoda_sum'+2+1+1'] = `gpm2p'
	
	matrix mod2[1,`=4*`nbmoda_sum'+2+1+1+1'] = `teffm2'
	matrix mod2[2,`=4*`nbmoda_sum'+2+1+1+1'] = `seteffm2'
	matrix mod2[3,`=4*`nbmoda_sum'+2+1+1+1'] = `ubteffm2'
	matrix mod2[4,`=4*`nbmoda_sum'+2+1+1+1'] = `lbteffm2'	
	matrix mod2[5,`=4*`nbmoda_sum'+2+1+1+1'] = `tm2chi'
	matrix mod2[6,`=4*`nbmoda_sum'+2+1+1+1'] = `tm2df'
	matrix mod2[7,`=4*`nbmoda_sum'+2+1+1+1'] = `tm2p'

	matrix mod2[1,`=4*`nbmoda_sum'+2+1+1+1+1'] = `interm2'
	matrix mod2[2,`=4*`nbmoda_sum'+2+1+1+1+1'] = `seinterm2'
	matrix mod2[3,`=4*`nbmoda_sum'+2+1+1+1+1'] = `ubinterm2'
	matrix mod2[4,`=4*`nbmoda_sum'+2+1+1+1+1'] = `lbinterm2'
	matrix mod2[5,`=4*`nbmoda_sum'+2+1+1+1+1'] = `interm2chi'
	matrix mod2[6,`=4*`nbmoda_sum'+2+1+1+1+1'] = `interm2df'
	matrix mod2[7,`=4*`nbmoda_sum'+2+1+1+1+1'] = `interm2p'
}
else {
	matrix mod2[1,`=2*`nbmoda_sum'+1'] = (val_m2[1,"/var(THETA1)"],val_m2[1,"/var(THETA2)"])
	matrix mod2[2,`=2*`nbmoda_sum'+1'] = (val_m2[2,"/var(THETA1)"],val_m2[2,"/var(THETA2)"])
	matrix mod2[3,`=2*`nbmoda_sum'+1'] = (val_m2[6,"/var(THETA1)"],val_m2[6,"/var(THETA2)"])
	matrix mod2[4,`=2*`nbmoda_sum'+1'] = (val_m2[5,"/var(THETA1)"],val_m2[5,"/var(THETA2)"])
	
	matrix mod2[1,`=2*`nbmoda_sum'+2+1'] = (val_m2[1,"/cov(THETA1,THETA2)"])
	matrix mod2[2,`=2*`nbmoda_sum'+2+1'] = (val_m2[2,"/cov(THETA1,THETA2)"])
	matrix mod2[3,`=2*`nbmoda_sum'+2+1'] = (val_m2[6,"/cov(THETA1,THETA2)"])
	matrix mod2[4,`=2*`nbmoda_sum'+2+1'] = (val_m2[5,"/cov(THETA1,THETA2)"])
	
	matrix mod2[1,`=2*`nbmoda_sum'+2+1+1'] = `teffm2'
	matrix mod2[2,`=2*`nbmoda_sum'+2+1+1'] = `seteffm2'
	matrix mod2[3,`=2*`nbmoda_sum'+2+1+1'] = `ubteffm2'
	matrix mod2[4,`=2*`nbmoda_sum'+2+1+1'] = `lbteffm2'	
	matrix mod2[5,`=2*`nbmoda_sum'+2+1+1'] = `tm2chi'
	matrix mod2[6,`=2*`nbmoda_sum'+2+1+1'] = `tm2df'
	matrix mod2[7,`=2*`nbmoda_sum'+2+1+1'] = `tm2p'
}

	*********************************
	**			MODEL 1			   **
	*********************************


/*PCM longitudinal, no true change, group effect, interaction*/
local listconst ""
forvalues j=1/`nbitems'{ /*contraintes pour les autres items (si DIF NU sur item k, pas de contraintes*/
	if dif_rc[`j',1]==. | dif_rc[`j',1]==0 {/*pas de DIF sur item k: contraintes 1*/
		forvalues p=1/`nbdif_`j''{ 
			local listconst "`listconst' `=0+`maxdif'*(`j'-1)+`p''"
			qui constraint list `=0+`maxdif'*(`j'-1)+`p''
		}
	}
	else{
		if `nbdif_`j'' > 1 {
			if dif_rc[`j',2]!=. & dif_rc[`j',2] != 0 { /*diff T1 U: contraintes 201*/
				forvalues p=2/`nbdif_`j''{
					local listconst "`listconst' `=200+`maxdif'*(`j'-1)+`p''"
					qui constraint list `=200+`maxdif'*(`j'-1)+`p''
				}
			}
		}
	}
}	


local model ""
forvalues j=1/`nbitems'{
	forvalues p=1/`nbdif_`j''{
		local model "`model' (`p'.``j''<-THETA1@`p')(`p'.``=`j'+`nbitems'''<-THETA2@`p')"
	}
}

if "`group'"!="" {
	qui gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading) means(0: THETA1@0 THETA2@0) means(1: THETA1@m1 THETA2@m1) var(0: THETA1@v1 THETA2@v2) var(1:THETA1@v1 THETA2@v2) cov(0: THETA1*THETA2@cov12) cov(1: THETA1*THETA2@cov12) constraint(`listconst') from(esti_2, skip) latent(THETA1 THETA2) nocapslatent
}
else {
	qui gsem `model', mlogit tol(0.01) iterate(100) means(THETA1@0 THETA2@0) var(THETA1@v1 THETA2@v2) cov(THETA1*THETA2@cov12) from(esti_2, skip) latent(THETA1 THETA2) nocapslatent
}

/* Stockage des estimations du modèle 1 */
estimates store model1
matrix val_m1 = r(table)

/* Calcul des difficultés d'item (delta_j) */
matrix delta_m1 = J(`nbitems',`=`nbdif_max'*4',.)
local name_partTwoC ""
forvalues p=1/`nbdif_max' {
	forvalues t=1/2 {
		forvalues g = 0/1 {
			local name_partTwoC "`name_partTwoC' delta_t`t'_`p'_gp`g'"
		}
	}
}

local name_partTwoL ""
forvalues j=1/`=`nbitems'*2' {
	if `j' <= `nbitems' {
		local name_partTwoL "`name_partTwoL' ``j''"
	}
	else {
		local name_partTwoL "`name_partTwoL' ``=`nbitems'+`j'''"
	}
}

matrix colnames delta_m1 = `name_partTwoC'
matrix rownames delta_m1 = `name_partTwoL'

matrix delta_m1_se = J(`nbitems',`=`nbdif_max'*4',.)
local name_partTwoC_se ""

forvalues p=1/`nbdif_max' {
	forvalues t=1/2 {
		forvalues g = 0/1 {
			local name_partTwoC_se "`name_partTwoC_se' delta_t`t'_`p'_gp`g'_se"
		}
	}
}

matrix colnames delta_m1_se = `name_partTwoC_se'
matrix rownames delta_m1_se = `name_partTwoL'

if "`group'"!="" {
	forvalues t=1/2{
		forvalues j=1/`nbitems'{
			forvalues p=1/`nbdif_`j''{
				forvalues g=0/1{
					qui lincom -[`p'.``=(`t'-1)*`nbitems'+`j''']:`g'.`gp'
					local delta`t'_`j'_`p'g`g'm1= r(estimate)
					local delta`t'_`j'_`p'g`g'm1_se= r(se)				
					if `p'>1{
						qui lincom [`=`p'-1'.``=(`t'-1)*`nbitems'+`j''']:`g'.`gp' - [`p'.``=(`t'-1)*`nbitems'+`j''']:`g'.`gp'
						local delta`t'_`j'_`p'g`g'm1=r(estimate)
						local delta`t'_`j'_`p'g`g'm1_se=r(se)
					}
					if `t' == 1 {
						matrix delta_m1[`j',`=4*(`p'-1)+`g'+`t'']=`delta`t'_`j'_`p'g`g'm1'
						matrix delta_m1_se[`j',`=4*(`p'-1)+`g'+`t'']=`delta`t'_`j'_`p'g`g'm1_se'
					}
					if `t' == 2 {
						matrix delta_m1[`j',`=4*(`p'-1)+1+`g'+`t'']=`delta`t'_`j'_`p'g`g'm1'
						matrix delta_m1_se[`j',`=4*(`p'-1)+1+`g'+`t'']=`delta`t'_`j'_`p'g`g'm1_se'
					}
				}
			}
		}
	}
}
else {
	forvalues t=1/2 {
		forvalues j=1/`nbitems' {
			forvalues p = 1/`nbdif_`j'' {
				qui lincom -[`p'.``=(`t'-1)*`nbitems'+`j''']:_cons
				local delta`t'_`j'_`p'g0m1= r(estimate)
				local delta`t'_`j'_`p'g0m1_se= r(se)				
				if `p'>1{
					qui lincom [`=`p'-1'.``=(`t'-1)*`nbitems'+`j''']:_cons - [`p'.``=(`t'-1)*`nbitems'+`j''']:_cons
					local delta`t'_`j'_`p'g0m1=r(estimate)
					local delta`t'_`j'_`p'g0m1_se=r(se)
				}
				if `t' == 1 {
					matrix delta_m1[`j',`=4*(`p'-1)+`t'']=`delta`t'_`j'_`p'g0m1'
					matrix delta_m1_se[`j',`=4*(`p'-1)+`t'']=`delta`t'_`j'_`p'g0m1_se'
				}
				if `t' == 2 {
					matrix delta_m1[`j',`=4*(`p'-1)+1+`t'']=`delta`t'_`j'_`p'g0m1'
					matrix delta_m1_se[`j',`=4*(`p'-1)+1+`t'']=`delta`t'_`j'_`p'g0m1_se'
				}
			}
		}
	}
}

if "`group'" != "" {
	matrix var_m1 = (val_m1[1,"/var(THETA1)#0bn.`gp'"],val_m1[1,"/var(THETA2)#0bn.`gp'"]\val_m1[2,"/var(THETA1)#0bn.`gp'"],val_m1[2,"/var(THETA2)#0bn.`gp'"])
	matrix covar_m1 = (val_m1[1,"/cov(THETA1,THETA2)#0.`gp'"],val_m1[1,"/cov(THETA1,THETA2)#1.`gp'"]\val_m1[2,"/cov(THETA1,THETA2)#0.`gp'"],val_m1[2,"/cov(THETA1,THETA2)#1.`gp'"]\val_m1[4,"/cov(THETA1,THETA2)#0.`gp'"],val_m1[4,"/cov(THETA1,THETA2)#1.`gp'"])
}
else {
	matrix var_m1 = (val_m1[1,"/var(THETA1)"],val_m1[1,"/var(THETA2)"]\val_m1[2,"/var(THETA1)"],val_m1[2,"/var(THETA2)"])
	matrix covar_m1 = (val_m1[1,"/cov(THETA1,THETA2)"]\val_m1[2,"/cov(THETA1,THETA2)"]\val_m1[4,"/cov(THETA1,THETA2)"])
}

/*group effect*/
if  "`group'"!="" {
	qui lincom [/]:mean(THETA1)#1.`gp'-[/]:mean(THETA1)#0bn.`gp'
	local geffm1=r(estimate)
	local segeffm1=r(se)
	qui test [/]:mean(THETA1)#1.`gp'-[/]:mean(THETA1)#0bn.`gp' = 0
	local gpm1p=r(p)
	local gpm1chi=r(chi2)
	local gpm1df=r(df)
}

	*************************************************************
	***********************AFFICHAGE*****************************
	*************************************************************
	di 
	di as input "PROCESSING STEP 1"
	di
	
if "`detail'" != "" {		
	// Affichage du modèle 1

		/* Affichage des estimations des difficultés */

	if "`group'" != "" {
		di  _col(5) as text "{ul:MODEL 1:} Overall longitudinal measurement non-invariance across time (RS on all items)"
		di
		di %~105s as text "Item difficulties: estimates (s.e.)"
		di _col(10) "{hline 85}"
		di _col(38) "Time 1" _col(76) "Time 2"
		di as text _col(26) abbrev("`gp'",15) "=0" _col(44) abbrev("`gp'",15) "=1" _col(64) abbrev("`gp'",15) "=0" _col(82) abbrev("`gp'",15) "=1" 
		di _col(10) "{hline 85}"
	}
	else {
		di  _col(5) as text "{ul:MODEL 1:} Overall longitudinal measurement non-invariance across time (RS on all items)"
		di
		di %~70s as text as text "Item difficulties: estimates (s.e.)"
		di _col(10) "{hline 50}"
		di _col(25) "Time 1" _col(42) "Time 2"
		di _col(10) "{hline 50}"
	}

	forvalues j=1/`nbitems' {
		di as text _col(10) "``j''" 
		forvalues p=1/`nbdif_`j'' {
			if "`group'" != "" {
				di as text _col(10) "`p'" as result _col(25) %6.2f `delta1_`j'_`p'g0m1' " (" %4.2f `delta1_`j'_`p'g0m1_se' ")" _col(43) %6.2f `delta1_`j'_`p'g1m1' " (" %4.2f `delta1_`j'_`p'g1m1_se' ")" ///
				_col(63) %6.2f `delta2_`j'_`p'g0m1' " (" %4.2f `delta2_`j'_`p'g0m1_se' ")" _col(81) %6.2f `delta2_`j'_`p'g1m1' " (" %4.2f `delta2_`j'_`p'g1m1_se' ")"
			}
			else {
				di as text _col(10) "`p'" as result _col(25) %6.2f `delta1_`j'_`p'g0m1' " (" %4.2f `delta1_`j'_`p'g0m1_se' ")" _col(42) %6.2f `delta2_`j'_`p'g0m1' " (" %4.2f `delta2_`j'_`p'g0m1_se' ")"
			}
		}
	}
	if "`group'" != "" {
		di _col(10) as text "{hline 85}"
	}
	else {
		di _col(10) as text "{hline 50}"
	}
		/* Affichage des estimations du trait latent du modèle 1 */

	di
	if "`group'" != "" {
		di %~85s as text "Latent trait distribution"
		di _col(10) "{hline 65}"
		di _col(28) "Estimate" _col(46) "Standard error" _col(62) "P-value"
		di _col(10) "{hline 65}"
	}
	else {
		di %~70s as text "Latent trait distribution"
		di _col(10) "{hline 50}"
		di  _col(28) as text "Estimate" _col(44) "Standard error" "
		di _col(10) "{hline 50}"
	}
	di  _col(10) as text "Variance Time 1" as result _col(28) %6.2f `=var_m1[1,1]' _col(44) %6.2f `=var_m1[2,1]'
	di  _col(10) as text "Variance Time 2" as result _col(28) %6.2f `=var_m1[1,2]' _col(44) %6.2f `=var_m1[2,2]'
	di  _col(10) as text "Covariance" as result _col(28) %6.2f `=covar_m1[1,1]' _col(44) %6.2f `=covar_m1[2,1]'
	if "`group'" != "" {
		di _col(10) as text "Group effect" as result _col(28) %6.2f `geffm1' _col(44) %6.2f `segeffm1' _col(62) %6.4f `gpm1p'
	}
	di _col(10) as text "Time effect" as result _col(28) "0 (constrained)"
	if "`group'" != "" {
		di _col(10) as text "TimexGroup inter" as result _col(28) "0 (constrained)"
	}
	if "`group'" != "" {
		di _col(10) as text "{hline 65}"
	}
	else {
		di _col(10) as text "{hline 50}"
	}
	di
	if "`group'" != "" {
		di _col(10) as text "Group effect estimated: mean of the latent trait of group 1 at time 1 freely estimated"
		di _col(10) as text "No time effect: equality of means of the latent trait of group 0 across time"
		di _col(10) as text "All item difficulties freely estimated across time"
	}
	else{
		di _col(10) as text "No time effect: equality of means of the latent trait across time"
		di _col(10) as text "All item difficulties freely estimated across time"
	}
}
	//Affichage du modèle 2
di 
di as input "PROCESSING STEP 2"
di
if "`detail'" != "" {
		/* Affichage des estimations des difficultés */
	di  _col(5) as text "{ul:MODEL 2:} Overall longitudinal measurement invariance across time (no RS)"
	di
	if "`group'" != "" {
		di %~105s as text "Item difficulties: estimates (s.e.)"
		di _col(10) "{hline 85}"
		di _col(38) "Time 1" _col(76) "Time 2"
		di as text _col(26) abbrev("`gp'",15) "=0" _col(44) abbrev("`gp'",15) "=1" _col(64) abbrev("`gp'",15) "=0" _col(82) abbrev("`gp'",15) "=1" 
		di _col(10) "{hline 85}"
	}
	else {
		di %~70s as text as text "Item difficulties: estimates (s.e.)"
		di _col(10) "{hline 50}"
		di _col(25) "Time 1" _col(42) "Time 2"
		di _col(10) "{hline 50}"
	}

	forvalues j=1/`nbitems' {
		di as text _col(10) "``j''" 
		forvalues p=1/`nbdif_`j'' {
			if "`group'" != "" {
				di as text _col(10) "`p'" as result _col(25) %6.2f `delta1_`j'_`p'g0m2' " (" %4.2f `delta1_`j'_`p'g0m2_se' ")" _col(43) %6.2f `delta1_`j'_`p'g1m2' " (" %4.2f `delta1_`j'_`p'g1m2_se' ")" ///
				_col(63) %6.2f `delta2_`j'_`p'g0m2' " (" %4.2f `delta2_`j'_`p'g0m2_se' ")" _col(81) %6.2f `delta2_`j'_`p'g1m2' " (" %4.2f `delta2_`j'_`p'g1m2_se' ")"
			}
			else {
				di as text _col(10) "`p'" as result _col(25) %6.2f `delta1_`j'_`p'g0m2' " (" %4.2f `delta1_`j'_`p'g0m2_se' ")" 	_col(42) %6.2f `delta2_`j'_`p'g0m2' " (" %4.2f `delta2_`j'_`p'g0m2_se' ")" 
			}
		}
	}
	if "`group'" != "" {
		di as text _col(10) "{hline 85}"
	}
	else {
		di as text _col(10) "{hline 50}"
	}
		/* Affichage des estimations du trait latent du modèle 2 */
	di
	di %~85s as text "Latent trait distribution"
	di _col(10) "{hline 65}"
	di  _col(28) as text "Estimate" _col(46) "Standard error" _col(64) "P-value"
	di _col(10) "{hline 65}"

	if "`group'" == "" {
		local fact_k = 2
	}
	else {
		local fact_k = 4
	}

	di  _col(10) as text "Variance Time 1" as result _col(28) %6.2f `=mod2[1,`=`fact_k'*`nbmoda_sum'+1']' _col(44) %6.2f =mod2[2,`=`fact_k'*`nbmoda_sum'+1']
	di  _col(10) as text "Variance Time 2" as result _col(28) %6.2f `=mod2[1,`=`fact_k'*`nbmoda_sum'+2']' _col(44) %6.2f `=mod2[2,`=`fact_k'*`nbmoda_sum'+2']'
	di  _col(10) as text "Covariance" as result _col(28) %6.2f `=mod2[1,`=`fact_k'*`nbmoda_sum'+3']' _col(44) %6.2f `=mod2[2,`=`fact_k'*`nbmoda_sum'+3']'
	if "`group'" != "" {
		di _col(10) as text "Group effect" as result _col(28) %6.2f `geffm2' _col(44) %6.2f `segeffm2' _col(62) %6.4f `gpm2p'
	}
	di _col(10) as text "Time effect" as result _col(28) %6.2f `teffm2' _col(44) %6.2f `seteffm2' _col(62) %6.4f `tm2p'
	if "`group'" != "" {
		di _col(10) as text "TimexGroup inter" as result _col(28) %6.2f `interm2' _col(44) %6.2f `seinterm2' _col(62) %6.4f `interm2p'
	}
	di as text _col(10) "{hline 65}"
	di
	if "`group'" != "" {
		di _col(10) as text "Group effect estimated: mean of the latent trait of group 1 at time 1 freely estimated"
		di _col(10) as text "Time effect estimated: mean of the latent trait of group 0 at time 2 freely estimated"
		di _col(10) as text "Equality of all item difficulties across time"
	}
	else {
		di _col(10) as text "Time effect estimated: mean of the latent trait at time 2 freely estimated"
		di _col(10) as text "Equality of all item difficulties across time"
	}
	di
}

	*****************************************************
	*			Modèle 1 vs Modèle 2 					*
	*****************************************************
qui lrtest model2 model1

local rstestp=r(p)
local rstestchi=r(chi2)
local rstestdf=r(df)
if "`detail'" != "" {
	
	di as input "LIKELIHOOD-RATIO TEST 
	di
	di %~60s "Model 1 vs Model 2"
	di _col(10) "{hline 40}"
	di _col(10) as text "Chi-square" _col(28) "DF" _col(40) "P-value"
	di _col(10) as result %6.2f `rstestchi' _col(28) %2.0f `rstestdf' _col(40) %6.4f `rstestp'
	di _col(10) as text "{hline 40}"
	di
}
if `rstestp'<0.05{
	di as result "DIFFERENCE IN ITEM DIFFICULTIES ACROSS TIME LIKELY"
}
else{
	di as result "NO DIFFERENCE IN ITEM DIFFICULTIES ACROSS TIME DETECTED, NO RECALIBRATION DETECTED"
}
	*********************************
	*************MODEL 3*************
	*********************************
// Etape itérative si lrtest significatif
local nb_step3=0
		
if `rstestp' < 0.05 { /* If pvalue(LRtest)<0.05 then step 3 */
	di
	di as input "PROCESSING STEP 3"
	di

	/*test RC pour chaque item*/
	local boucle = 1
	local stop = 0
	//matrix list dif_rc
	while `boucle' <= `=`nbitp'-1' & `stop' == 0 { /*on s'arrête quand on a libéré du RC sur (tous les items-1) ou lorsqu'il n'y a plus de tests significatifs*/
		local nb_step3 = `boucle'
		local pajust=0.05/`=`nbitp'+1-`boucle''    // local pajust=0.05/`=`nbitems'+1-`boucle'
		if "`group'" != "" {
			local pajust2 = 0.05/`nbgrp'
		}
		/*réinitialisation de la matrice de test*/
		matrix test_rc_`boucle'=J(`nbitems',9,.)
		matrix test_rcCOMM_`boucle'=J(`nbitems',3,.)
		matrix test_rcU_`boucle'=J(`nbitems',6,.)
		matrix colnames test_rc_`boucle'= chi_RC df_RC pvalue_RC chi_RCg0 df_RCg0 pvalue_RCg0 chi_RCg1 df_RCg1 pvalue_RCg1
		matrix colnames test_rcCOMM_`boucle'= chi_RCCOMM df_RCCOMM pvalue_RCCOMM
		matrix colnames test_rcU_`boucle'= chi_RCUg0 df_RCUg0 pvalue_RCUg0 chi_RCUg1 df_RCUg1 pvalue_RCUg1
		local nbsig=0
		local minpval=1
		local itemrc=0
		if "`detail'" != "" {
			di  as text "Loop `boucle'" 
			di _col(5) "Adjusted alpha : " %6.4f `pajust'
			di
			di as text _col(10) "{hline 65}"
			di as text _col(10) "Freed item" _col(31) "Chi-Square"  _col(48) "DF" _col(57) "P-Value"
			di as text _col(10) "{hline 65}"
		}
		
				
				/*boucle de test*/
		forvalues j=1/`nbitems'{
			if `nbdif_`j'' >= 1 {
				local model ""
				local listconst ""
				local listconst_g ""
				if dif_rc[`j',3]==. { /*si pas de RC déjà détecté sur l'item j -> test item j*/
					/*on libère la RC de l'item j: pas de contraintes*/
					forvalues k=1/`nbitems'{
						if "`group'" == "" {
							if `k'!=`j'{
								if dif_rc[`k',3]==. | dif_rc[`k',3]==0 {/*pas de RC sur item k: contraintes 401-600*/
									forvalues p=1/`nbdif_`k''{ 
										local listconst_g "`listconst_g' `=400+`maxdif'*(`k'-1)+`p'' "
										qui constraint list `=400+`maxdif'*(`k'-1)+`p'' 
									}
								}
								else {
									if dif_rc[`k',6]!=. & dif_rc[`k',6]!=0 { // RC commune unif.
										if `nbmoda_`k'' > 2 {
											forvalues p=2/`nbdif_`k''{          
												local listconst_g "`listconst_g' `=1000+`maxdif'*(`k'-1)+`p''"
												qui constraint list `=1000+`maxdif'*(`k'-1)+`p''
											}
										}
									}
								}
							}
						}
						else {
					/* Contraintes de DIF */
							if dif_rc[`k',1]==.|dif_rc[`k',1]==0 { // contraintes si pas de DIF (1-200)
								forvalues p=1/`nbdif_`k''{ 
									local listconst "`listconst' `=0+`maxdif'*(`k'-1)+`p''"
									qui constraint list `=0+`maxdif'*(`k'-1)+`p''
								}
							}	 
							else { // Présence de DIF
								if dif_rc[`k',2]!=. & dif_rc[`k',2]!=0 { // contraintes de DIF U (201-400)
									if `nbmoda_`k'' > 2 {
										forvalues p=2/`nbdif_`k''{ 
											local listconst "`listconst' `=200+`maxdif'*(`k'-1)+`p''"
											qui constraint list `=200+`maxdif'*(`k'-1)+`p''
										}
									}
								}
							}			
							if `k'!=`j'{ /*contraintes pour les autres items */
								if dif_rc[`k',3]==. | dif_rc[`k',3]==0 {/*pas de RC sur item k: contraintes 401-600 601-800*/
									forvalues p=1/`nbdif_`k''{ 
										local listconst "`listconst' `=400+`maxdif'*(`k'-1)+`p'' `=600+`maxdif'*(`k'-1)+`p''"
										qui constraint list `=400+`maxdif'*(`k'-1)+`p'' `=600+`maxdif'*(`k'-1)+`p''
									}
								}
								else { //RC détectée sur l'item k
									if dif_rc[`k',4]==0{ /*RC commune: contraintes 801-1000*/
										forvalues p=1/`nbdif_`k''{           /***************************** j=1 ou 2 ?****/
											local listconst "`listconst' `=800+`maxdif'*(`k'-1)+`p''"
											qui constraint list `=800+`maxdif'*(`k'-1)+`p''
										}
										if dif_rc[`k',6]!=. & dif_rc[`k',6]!=0 { // RC commune unif.
											if `nbmoda_`k'' > 2 {
												forvalues p=2/`nbdif_`k''{          
													local listconst "`listconst' `=1000+`maxdif'*(`k'-1)+`p''"
													qui constraint list `=1000+`maxdif'*(`k'-1)+`p''
												}
											}
										}
									}
									else { // RC diff
										if dif_rc[`k',5]==. | dif_rc[`k',5]==0 { // RC gp0 (400)
											forvalues p=1/`nbdif_`k''{          
												local listconst "`listconst' `=400+`maxdif'*(`k'-1)+`p''"
												qui constraint list `=400+`maxdif'*(`k'-1)+`p''
											}	
										}
										if dif_rc[`k',6]!=. & dif_rc[`k',6]!=0 { // RCU gp0 (1001-1200)
											if `nbmoda_`k'' > 2 {
												forvalues p=2/`nbdif_`k''{          
													local listconst "`listconst' `=1000+`maxdif'*(`k'-1)+`p''"
													qui constraint list `=1000+`maxdif'*(`k'-1)+`p''
												}
											}	
										}
										if dif_rc[`k',7]==. | dif_rc[`k',7]==0 { // RC gp1 (600)
											forvalues p=1/`nbdif_`k''{          
												local listconst "`listconst' `=600+`maxdif'*(`k'-1)+`p''"
												qui constraint list `=600+`maxdif'*(`k'-1)+`p''
											}	
										}	
										if dif_rc[`k',8]!=. & dif_rc[`k',8]!=0 { // RCU gp1 (1201-1400)
											if `nbmoda_`k'' > 2 {
												forvalues p=2/`nbdif_`k''{          
													local listconst "`listconst' `=1200+`maxdif'*(`k'-1)+`p''"
													qui constraint list `=1200+`maxdif'*(`k'-1)+`p''
												}
											}
										}
									}
								}
							}
						}
					}
					
					local model ""
					forvalues jj=1/`nbitems'{
						forvalues p=1/`nbdif_`jj''{
							local model "`model' (`p'.``jj''<-THETA1@`p')(`p'.``=`jj'+`nbitems'''<-THETA2@`p')"
						}
					}
					if "`group'" == "" { // Sans l'option group
						qui gsem `model', mlogit tol(0.01) iterate(100) means(THETA1@0 THETA2@m20) var(THETA1@v1 THETA2@v2) cov(THETA1*THETA2@cov12) constraint(`listconst_g') from(esti_2, skip) latent(THETA1 THETA2) nocapslatent
					
							/*****************/
							/*tests RC item j*/
							/*****************/
					
							/* RC ? */
						qui test [1.``j'']_cons =[1.``=`j'+`nbitems''']_cons
						if `nbmoda_`j'' > 2 {
							forvalues p=2/`nbdif_`j''{
								qui test [`p'.``j'']_cons =[`p'.``=`j'+`nbitems''']_cons, acc
							}
						}
						matrix test_rc_`boucle'[`j',1]=(r(chi2),r(df),r(p))
						
																					
							/* RCU  ? */
						if `nbmoda_`j'' > 2 {
							qui test 2*([1.``=`j'+`nbitems''']_cons -[1.``j'']_cons)=[2.``=`j'+`nbitems''']_cons -[2.``j'']_cons
							forvalues p=3/`nbdif_`j''{
								qui test `p'*([1.``=`j'+`nbitems''']_cons -[1.``j'']_cons)=[`p'.``=`j'+`nbitems''']_cons -[`p'.``j'']_cons , acc
							}	
							matrix test_rcU_`boucle'[`j',1]=(r(chi2), r(df),r(p))
						}
					}
					else { // Avec l'option group
						qui gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading) means(0: THETA1@0 THETA2@m20) means(1: THETA1@m11 THETA2@m21) var(0: THETA1@v1 THETA2@v2) var(1:THETA1@v1 THETA2@v2) cov(0: THETA1*THETA2@cov12) cov(1: THETA1*THETA2@cov12) constraint(`listconst') from(esti_2, skip) latent(THETA1 THETA2) nocapslatent

							/*****************/
							/*tests RC item i*/
							/*****************/
							
							/* RC ? */
						qui test [1.``j'']0bn.`gp'=[1.``=`j'+`nbitems''']0bn.`gp'
						if `nbmoda_`j'' > 2 {
							forvalues p=2/`nbdif_`j''{
								qui test [`p'.``j'']0bn.`gp'=[`p'.``=`j'+`nbitems''']0bn.`gp', acc
							}
						}
						qui test [1.``j'']1.`gp'=[1.``=`j'+`nbitems''']1.`gp', acc
						if `nbmoda_`j'' > 2 {
							forvalues p=2/`nbdif_`j''{
								qui test [`p'.``j'']1.`gp'=[`p'.``=`j'+`nbitems''']1.`gp', acc
							}				
						}
						matrix test_rc_`boucle'[`j',1]=(r(chi2),r(df),r(p))
												/* RC COMMUNE ? */
						qui test [1.``=`j'+`nbitems''']0bn.`gp'-[1.``j'']0bn.`gp'=[1.``=`j'+`nbitems''']1.`gp'-[1.``j'']1.`gp'
						if `nbmoda_`j'' > 2 {
							forvalues p=2/`nbdif_`j''{
								qui test [`p'.``=`j'+`nbitems''']0bn.`gp'-[`p'.``j'']0bn.`gp'=[`p'.``=`j'+`nbitems''']1.`gp'-[`p'.``j'']1.`gp', acc
							}
						}
						matrix test_rcCOMM_`boucle'[`j',1]=(r(chi2),r(df),r(p))
												/* RC groupe 0 ? */
						qui test [1.``j'']0bn.`gp'=[1.``=`j'+`nbitems''']0bn.`gp'
						if `nbmoda_`j'' > 2 {
							forvalues p=2/`nbdif_`j''{
								qui test [`p'.``j'']0bn.`gp'=[`p'.``=`j'+`nbitems''']0bn.`gp', acc
							}
						}
						matrix test_rc_`boucle'[`j',4]=(r(chi2),r(df),r(p))
					
						/* RCU grp 0 ? */
						if `nbmoda_`j'' > 2 {
							qui test 2*([1.``=`j'+`nbitems''']0bn.`gp'-[1.``j'']0bn.`gp')=[2.``=`j'+`nbitems''']0bn.`gp'-[2.``j'']0bn.`gp'
							forvalues p=3/`nbdif_`j''{
									qui test `p'*([1.``=`j'+`nbitems''']0bn.`gp'-[1.``j'']0bn.`gp')=[`p'.``=`j'+`nbitems''']0bn.`gp'-[`p'.``j'']0bn.`gp', acc
							}	
							matrix test_rcU_`boucle'[`j',1]=(r(chi2),r(df),r(p))
						}
					
						/* RC groupe 1 ? */
						qui test [1.``j'']1.`gp'=[1.``=`j'+`nbitems''']1.`gp'
						if `nbmoda_`j'' > 2 {
							forvalues p=2/`nbdif_`j''{
								qui test [`p'.``j'']1.`gp'=[`p'.``=`j'+`nbitems''']1.`gp', acc
							}	
						}
						matrix test_rc_`boucle'[`j',7]=(r(chi2),r(df),r(p))
											
						/* RCU grp 1 ? */
						if `nbmoda_`j'' > 2 {
							qui test 2*([1.``=`j'+`nbitems''']1.`gp'-[1.``j'']1.`gp')=[2.``=`j'+`nbitems''']1.`gp'-[2.``j'']1.`gp'
							forvalues p=3/`nbdif_`j''{
								qui test `p'*([1.``=`j'+`nbitems''']1.`gp'-[1.``j'']1.`gp')=[`p'.``=`j'+`nbitems''']1.`gp'-[`p'.``j'']1.`gp', acc
							}
							matrix test_rcU_`boucle'[`j',4]=(r(chi2),r(df),r(p))
						}
					}
					/******* Matrice test complète *********/
					if "`detail'" != "" {
						di as text _col(10) abbrev("``j''",22) as result _col(31)  %6.3f test_rc_`boucle'[`j',1] _col(48) test_rc_`boucle'[`j',2] _col(57) %6.4f test_rc_`boucle'[`j',3] 	
					}
				}
			}
		}
		//matrix list test_rc_`boucle'
		forvalues j=1/`nbitems'{
			if test_rc_`boucle'[`j',3]<`pajust'{/*si RC sur item i*/
				if test_rc_`boucle'[`j',3]<`minpval'{
					local minpval=test_rc_`boucle'[`j',3]
					local itemrc=`j'
				}
			}
		}
		if `itemrc' != 0 { // itemrc = numéro de l'item avec le test le + sig.
			if "`group'" == "" { // Recalibration si pas d'option groupe
				local ++nbsig
				matrix dif_rc[`itemrc',3]=`boucle'
				matrix dif_rc[`itemrc',5]=`boucle'
				if `nbmoda_`itemrc'' > 2 {
					if "`detail'" != "" {
						di as text _col(10) "{hline 65}"
						di
						di as result "Recalibration on ``itemrc''"
						di
						di as text _col(10) "{hline 65}"
						di as text _col(10) "Test" _col(31) "Chi-Square"  _col(48) "DF" _col(57) "P-Value"
						di as text _col(10) "{hline 65}"
						di as text _col(10) "Uniform RC? " as result _col(31) %4.2f  `=test_rcU_`boucle'[`itemrc',1]'  _col(48) `=test_rcU_`boucle'[`itemrc',2]'  _col(57) %6.4f `=test_rcU_`boucle'[`itemrc',3]'
						di as text _col(10) "{hline 65}"
					}
					if test_rcU_`boucle'[`itemrc',3] >= 0.05 { //RC Uniforme sur itemRC
						matrix dif_rc[`itemrc',6]=`boucle'
							di
							di as result "``itemrc'' : Uniform RC"
							di 
					}
					else {
						matrix dif_rc[`itemrc',6]=0
							di
							di as result "``itemrc'' : Non-uniform RC"
							di 
					}
				}
				else {
						di
						di as result "``itemrc'' : Recalibration "
						di 
				}
			}
			else { // Option groupe
				if "`detail'" != "" {
					di as text _col(10) "{hline 65}"
					di
					di as result "Recalibration on ``itemrc''"
					di
					di as text _col(10) "{hline 65}"
					di as text _col(10) "Test" _col(31) "Chi-Square"  _col(48) "DF" _col(57) "P-Value"
					di as text _col(10) "{hline 65}"
					di _col(10) as text "Common RC? " as result _col(31) %4.2f `=test_rcCOMM_`boucle'[`itemrc',1]' _col(48) `=test_rcCOMM_`boucle'[`itemrc',2]' _col(57) %6.4f `=test_rcCOMM_`boucle'[`itemrc',3]' 
				}
				if test_rcCOMM_`boucle'[`itemrc',3] < 0.05 { //RC différentielle
					if "`detail'" != "" {
						di _col(10) as text "RC group 0? " as result _col(31) %4.2f  `=test_rc_`boucle'[`itemrc',4]' _col(48) `=test_rc_`boucle'[`itemrc',5]' _col(57) %6.4f `=test_rc_`boucle'[`itemrc',6]'  "{it: - with adjusted alpha = `pajust2' }"
					}
					if test_rc_`boucle'[`itemrc',6] < `pajust2' { //RC gp 0
						local ++nbsig
						matrix dif_rc[`itemrc',3]=`boucle'
						matrix dif_rc[`itemrc',4]=`boucle'
						matrix dif_rc[`itemrc',5]=`boucle'
						if `nbmoda_`itemrc'' > 2 {
							di _col(10) as text "Uniform RC group 0? " as result _col(31) %4.2f `=test_rcU_`boucle'[`itemrc',1]' _col(48) `=test_rcU_`boucle'[`itemrc',2]'  _col(57) %6.4f `=test_rcU_`boucle'[`itemrc',3]'
							if test_rcU_`boucle'[`itemrc',3] >= 0.05 { // RCU gp 0
								matrix dif_rc[`itemrc',6]=`boucle'	
								local phrase_diff = "``itemrc'' : Uniform differential RC in group 0."
							}
							else {
								matrix dif_rc[`itemrc',6]=0
								local phrase_diff = "``itemrc'' : Non-uniform differential RC in group 0."
							}
						}
						else {
							local phrase_diff = "``itemrc'' : Differential RC in group 0."
						}
					}
					if "`detail'" != "" {
						di _col(10) as text "RC group 1?" as result _col(31) %4.2f  `=test_rc_`boucle'[`itemrc',7]' _col(48) `=test_rc_`boucle'[`itemrc',8]' _col(57) %6.4f `=test_rc_`boucle'[`itemrc',9]' "{it: - with adjusted alpha = `pajust2' }"
					}
					if test_rc_`boucle'[`itemrc',9] < `pajust2' { //RC gp 1
						local ++nbsig
						matrix dif_rc[`itemrc',3]=`boucle'
						matrix dif_rc[`itemrc',4]=`boucle'
						matrix dif_rc[`itemrc',7]=`boucle'
						if `nbmoda_`itemrc'' > 2 {
							if "`detail'" != "" {
								di _col(10) as text "Uniform RC group 1? " as result _col(31) %4.2f `=test_rcU_`boucle'[`itemrc',4]' _col(48) `=test_rcU_`boucle'[`itemrc',5]'  _col(57) %6.4f `=test_rcU_`boucle'[`itemrc',6]'
							}
							if test_rcU_`boucle'[`itemrc',6] >= 0.05 { // RCU gp 1
								matrix dif_rc[`itemrc',8]=`boucle'
								if dif_rc[`itemrc',5] != `boucle' { //RC slmt sur g1
									local phrase_diff = "``itemrc'' : Differential RC, uniform RC in group 1."
								}
								else {
									if dif_rc[`itemrc',6] == 0 { // + RCNU g0
										local phrase_diff = "``itemrc'' : Differential RC, non-uniform RC in group 0 and uniform RC in group 1."
									}
									else { // + RCU G0
										local phrase_diff = "``itemrc'' : Differential RC, uniform RC in group 0 and uniform RC in group 1."
									}
								}
							}
							else { //RCNU gp 1
								matrix dif_rc[`itemrc',8]=0
								if "`detail'" != "" {
									di
								}
								if dif_rc[`itemrc',5] != `boucle' {
									local phrase_diff = "``itemrc'' : Differential RC, non-uniform RC in group 1."
								}
								else {
									if dif_rc[`itemrc',6] == 0 { // + RCNU g0
										local phrase_diff = "``itemrc'' : Differential RC, non-uniform RC in group 0 and non-uniform RC in group 1."
									}
									else { // + RCU G0
										local phrase_diff = "``itemrc'' : Differential RC, uniform RC in group 0 and non-uniform RC in group 1."
									}
								}
							}
						}
						else {
							if dif_rc[`itemrc',5] != `boucle' {
									local phrase_diff = "``itemrc'' : Differential RC in group 1."
							}
							else {
								local phrase_diff = "``itemrc'' : Differential RC in group 0 and differential RC in group 1."
							}
						}
					}
					if "`detail'" != "" {
						di as text _col(10) "{hline 65}"
					}
					di
					di as result "`phrase_diff'"
					di 
				}
				else { // RC commune -> MAJ modèle 3
	/*******************************************************************************************************************/
					if `nbmoda_`itemrc'' == 2 {
						if "`detail'" != "" {
							di
							di as result "{ul:``itemrc''}: recalibration"
							di _col(20) in ye "Common " in gr "{it:(Chi-s: " %4.2f `=test_rcCOMM_`boucle'[`itemrc',1]' ", DF: `=test_rcCOMM_`boucle'[`itemrc',2]' p-val. : " %4.2f `=test_rcCOMM_`boucle'[`itemrc',3]' ")}"
						}
						matrix dif_rc[`itemrc',3]=`boucle'
						matrix dif_rc[`itemrc',4]=0
						matrix dif_rc[`itemrc',5]=`boucle'
						matrix dif_rc[`itemrc',7]=`boucle'
						local ++nbsig
					}
					else {
						matrix dif_rc[`itemrc',3]=`boucle'
						matrix dif_rc[`itemrc',4]=0
						matrix dif_rc[`itemrc',5]=`boucle'
						matrix dif_rc[`itemrc',7]=`boucle'
						//matrix list dif_rc
						local model ""
						local listconst ""					
						forvalues j=1/`nbitems'{ 
							/* Contraintes de DIF */
							if dif_rc[`j',1]==.|dif_rc[`j',1]==0 { // contraintes si pas de DIF (1-200)
								forvalues p=1/`nbdif_`j''{ 
									qui local listconst "`listconst' `=0+`maxdif'*(`j'-1)+`p''"
									qui constraint list `=0+`maxdif'*(`j'-1)+`p''								
								}
							} 
							else { // Présence de DIF
								if dif_rc[`j',2]!=. & dif_rc[`j',2]!=0 { // contraintes de DIF U (201-400)
									if `nbmoda_`j'' > 2 {
										forvalues p=2/`nbdif_`j''{ 
											qui local listconst "`listconst' `=200+`maxdif'*(`j'-1)+`p''"
											qui constraint list `=200+`maxdif'*(`j'-1)+`p''
										}
									}
								}
							}
							if `j' != `itemrc'{ /*contraintes pour les autres items */
								if dif_rc[`j',3]==. | dif_rc[`j',3]==0 {/*pas de RC sur item p: contraintes 401-600 601-800*/
									forvalues p=1/`nbdif_`j''{ 
										qui local listconst "`listconst' `=400+`maxdif'*(`j'-1)+`p'' `=600+`maxdif'*(`j'-1)+`p''"
										qui constraint list `=400+`maxdif'*(`j'-1)+`p'' `=600+`maxdif'*(`j'-1)+`p''
									}
								}
								else { //RC détectée sur l'item p
									if dif_rc[`j',4]==0{ /*RC commune: contraintes 801-1000*/
										forvalues p=1/`nbdif_`j''{           
											qui local listconst "`listconst' `=800+`maxdif'*(`j'-1)+`p''"
											qui constraint list `=800+`maxdif'*(`j'-1)+`p''
										}
										if dif_rc[`j',6]!=. & dif_rc[`j',6]!=0 { // RC commune unif.
											if `nbmoda_`j'' > 2 {
												forvalues p=2/`nbdif_`j''{          
													qui local listconst "`listconst' `=1000+`maxdif'*(`j'-1)+`p''"
													qui constraint list `=1000+`maxdif'*(`j'-1)+`p''
												}	
											}
										}
									}
									else if dif_rc[`j',4] != 0 & dif_rc[`j',4]!=0. { // RC diff
										if dif_rc[`j',5]==. | dif_rc[`j',5]==0 { // RC gp0 (400)
											forvalues p=1/`nbdif_`j''{          
												qui local listconst "`listconst' `=400+`maxdif'*(`j'-1)+`p''"
												qui constraint list `=400+`maxdif'*(`j'-1)+`p''
											}	
										}
										if dif_rc[`j',6]!=. & dif_rc[`j',6]!=0 { // RCU gp0 (1001-1200)
											if `nbmoda_`j'' > 2 {
												forvalues p=2/`nbdif_`j''{          
													qui local listconst "`listconst' `=1000+`maxdif'*(`j'-1)+`p''"
													qui constraint list `=1000+`maxdif'*(`j'-1)+`p''
												}	
											}
										}
										if dif_rc[`j',7]==. | dif_rc[`j',7]==0 { // RC gp1 (600)
											forvalues p=1/`nbdif_`j''{          
												qui local listconst "`listconst' `=600+`maxdif'*(`j'-1)+`p''"
												qui constraint list `=600+`maxdif'*(`j'-1)+`p''
											}	
										}
										if dif_rc[`j',8]!=. & dif_rc[`j',8]!=0 { // RCU gp1 (1201-1400)
											if `nbmoda_`j'' > 2 {
												forvalues p=2/`nbdif_`j''{          
													qui local listconst "`listconst' `=1200+`maxdif'*(`j'-1)+`p''"
													qui constraint list `=1200+`maxdif'*(`j'-1)+`p''
												}
											}
										}	
									}
								}
							}
							else { // Contrainte de RC commune pour l'itemrc
								forvalues p=1/`nbdif_`j''{          
									qui local listconst "`listconst' `=800+`maxdif'*(`itemrc'-1)+`p''"
									qui constraint list `=800+`maxdif'*(`itemrc'-1)+`p''
								}	
							}
						}	
						qui di "`listconst'"
						local model ""
						forvalues jj=1/`nbitems'{
							forvalues p=1/`nbdif_`jj''{
								local model "`model' (`p'.``jj''<-THETA1@`p')(`p'.``=`jj'+`nbitems'''<-THETA2@`p')"
							}
						}
						qui gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading) means(0: THETA1@0 THETA2@m20) means(1: THETA1@m11 THETA2@m21) var(0: THETA1@v1 THETA2@v2) var(1:THETA1@v1 THETA2@v2) cov(0: THETA1*THETA2@cov12) cov(1: THETA1*THETA2@cov12) constraint(`listconst') from(esti_2, skip) latent(THETA1 THETA2) nocapslatent

						/************************/
						/*tests RC item `itemrc'*/
						/************************/
						matrix commU_`boucle'=J(`nbitems',3,.) //Matrice des tests de RCU slmt si RC commune 
						matrix colnames commU_`boucle'= chi_RCU df_RCU p_RCU
						
						/* RCU grp 0 ? */
						if `nbmoda_`itemrc'' > 2 {
							qui test 2*([1.``=`itemrc'+`nbitems''']0bn.`gp'-[1.``itemrc'']0bn.`gp')=[2.``=`itemrc'+`nbitems''']0bn.`gp'-[2.``itemrc'']0bn.`gp'
							forvalues j=3/`nbdif_`itemrc''{
								qui test `j'*([1.``=`itemrc'+`nbitems''']0bn.`gp'-[1.``itemrc'']0bn.`gp')=[`j'.``=`itemrc'+`nbitems''']0bn.`gp'-[`j'.``itemrc'']0bn.`gp', acc
							}	
							matrix commU_`boucle'[`itemrc',1]=(r(chi2),r(df),r(p))
							if "`detail'" != "" {
								di _col(10) as text "Uniform RC?" as result _col(31) %4.2f  `=commU_`boucle'[`itemrc',1]' _col(48) `=commU_`boucle'[`itemrc',2]' _col(57) %6.4f `=commU_`boucle'[`itemrc',3]'
							}
							if commU_`boucle'[`itemrc',3] >= 0.05 { // RCU
								local ++nbsig
								matrix dif_rc[`itemrc',6]=`boucle'
								matrix dif_rc[`itemrc',8]=`boucle'
								di
								//di as result "{ul:``itemrc''}: recalibration"
								//di _col(20) "Common " in gr "{it:(Chi-s: " %4.2f `=test_rcCOMM_`boucle'[`itemrc',1]' ", DF: `=test_rcCOMM_`boucle'[`itemrc',2]' p-val. : " %4.2f `=test_rcCOMM_`boucle'[`itemrc',3]' ")}"
								di as result "``itemrc'' : Uniform common RC"
								di 
							}
							else {
								local ++nbsig
								matrix dif_rc[`itemrc',6]=0
								matrix dif_rc[`itemrc',8]=0
								di
								di as result "``itemrc'' : Non-uniform common RC"
								di 
							}
						}
					} 
				}  // fin de RC commune
			}
		}
		else {
			local stop = 1
		}							
	/*******************************************************************************************************************/
		// Fin de RC sur item i
		if `nbsig'==0{
			local stop=1
			if `boucle' == 1 {
					di as text _col(10) "{hline 65}"
					di
					di as result "No significant tests, no recalibration detected"
					di
			}
			else {
				if "`detail'" != "" {
					di as text _col(10) "{hline 65}"
					di
					di as result "No other significant tests"
					di
				}
			}
		}
		local ++boucle
	}
}
	


	*********************************
	 ***		BILAN  			***
	*********************************

	if "`group'" != "" & "`nodif'" == "" {
	di
	di %~84s as result "SUMMARY"
	di as result _col(2)  "{hline 80}"
	di as result 		 _col(18) "Difference in"
	di as result _col(2) "Item" _col(18) "groups at T1" _col(36) "Recalibration"  _col(54) "RC " abbrev("`gp'",10) " 0"  _col(72) "RC " abbrev("`gp'",10) " 1" 
	di as result _col(2) "{hline 80}"
	forvalues j=1/`nbitems' {
		local RC
		local RCg0
		local RCg1
		local difft1
		if (dif_rc[`j',3] != . & dif_rc[`j',3] != 0 & dif_rc[`j',4] == 0) {
			local RC "Common"
		}
		if (dif_rc[`j',3] != . & dif_rc[`j',3] != 0 & dif_rc[`j',4] != 0) {
			local RC "Differential"
		}
		if `nbmoda_`j'' > 2 {
			if (dif_rc[`j',6]!=. & dif_rc[`j',6] != 0) {
				local RCg0 "Uniform"
			}
			if (dif_rc[`j',6] == 0) {
				local RCg0 "Non-uniform"
			}
				if (dif_rc[`j',8]!=. & dif_rc[`j',8] != 0) {
				local RCg1 "Uniform"
			}
			if ( dif_rc[`j',8] == 0) {
				local RCg1 "Non-uniform"
			}
			if (dif_rc[`j',1] != . ) {
				if (dif_rc[`j',2]!=0) {
					local difft1 "Uniform"
				}
				else {
					local difft1 "Non-uniform"
				}
			}
		}
		else {
			if dif_rc[`j',6] != . {
				local RCg0 " X "
			}
			if dif_rc[`j',8] != . {
				local RCg1 " X "
			}
			if dif_rc[`j',1] != . {
				local difft1 " X "
			}
		}
		di as result _col(2) abbrev("``j''",15) as text _col(18) "`difft1'"  _col(36) "`RC'"  _col(54) "`RCg0'"  _col(72) "`RCg1'"
	}
	di as result _col(2) "{hline 80}"
	di
}
else if "`group'" != "" & "`nodif'" != "" {
	di
	di %~90s as result "SUMMARY"
	di as result _col(10)  "{hline 70}"
	di as result _col(10) "Item" _col(26) "Recalibration"  _col(46) "RC `gp' 0"  _col(62) "RC `gp' 1" 
	di _col(10) "{hline 70}"
	forvalues j=1/`nbitems' {
		local RC
		local RCg0
		local RCg1
		if (dif_rc[`j',3] != . & dif_rc[`j',3] != 0 & dif_rc[`j',4] == 0) {
			local RC "Common"
		}
		if (dif_rc[`j',3] != . & dif_rc[`j',3] != 0 & dif_rc[`j',4] != 0) {
			local RC "Differential"
		}
		if `nbmoda_`j'' > 2 {
			if (dif_rc[`j',6]!=. & dif_rc[`j',6] != 0) {
				local RCg0 "Uniform"
			}
			if (dif_rc[`j',6] == 0) {
				local RCg0 "Non-uniform"
			}
			if (dif_rc[`j',8]!=. & dif_rc[`j',8] != 0) {
				local RCg1 "Uniform"
			}
			if ( dif_rc[`j',8] == 0) {
				local RCg1 "Non-uniform"
			}
		}
		else {
			if dif_rc[`j',6] != . {
				local RCg0 " X "
			}
			if dif_rc[`j',8] != . {
				local RCg1 " X "
			}
		}
		di as result _col(10) "``j''" as text  _col(26) "`RC'"  _col(44) "`RCg0'"  _col(62) "`RCg1'"
	}
	di as result _col(10) "{hline 70}"
}
else if "`group'" == "" {
	di
	di %~60s as result "SUMMARY"
	di as result _col(10)  "{hline 40}"
	di _col(10) "Item" _col(36) "Recalibration"  
	di _col(10) "{hline 40}"
	forvalues j=1/`nbitems' {
		local RC
		if dif_rc[`j',3] != . {
			if `nbmoda_`j'' > 2 {
				if (dif_rc[`j',6]!=. & dif_rc[`j',6] != 0) {
					local RC "Uniform"
				}
				if (dif_rc[`j',6] == 0) {
					local RC "Non-uniform"
				}
			}
			else {
				local RC " X "
			}				
		}
		di as result _col(10) "``j''" as text  _col(38) "`RC'"  
	}
	di as result _col(10) "{hline 40}"
	di
}	


	*********************************
	**			MODEL 4			   **
	*********************************
if "`detail'" != "" {
	di
	di as input "PROCESSING STEP 4"
	di
}
	//matrix list dif_rc, title ("Constraints")

local model ""
local listconst ""
local listconst_g ""
forvalues j=1/`nbitems'{
	if "`group'" != "" {
		if dif_rc[`j',1]==.|dif_rc[`j',1]==0 { /*si pas de DIF: contraintes 1-200 */
			forvalues p=1/`nbdif_`j''{ 
				local listconst "`listconst' `=0+`maxdif'*(`j'-1)+`p''"
				qui constraint list `=0+`maxdif'*(`j'-1)+`p''
			}
		} 
		else { // Présence de DIF
			if dif_rc[`j',2]!=. & dif_rc[`j',2]!=0 { // contraintes de DIF U (201-400)
				if `nbmoda_`j'' > 2 {
					forvalues p=2/`nbdif_`j''{ 
						local listconst "`listconst' `=200+`maxdif'*(`j'-1)+`p''"
						qui constraint list `=200+`maxdif'*(`j'-1)+`p''
					}
				}
			}
		}
	}
	if dif_rc[`j',3]==. | dif_rc[`j',3]==0 { /*pas de RC : contraintes 401-600 601-800*/
		forvalues p=1/`nbdif_`j''{
			if "`group'" == "" {
				local listconst_g "`listconst_g' `=400+`maxdif'*(`j'-1)+`p''"
				qui constraint list `=400+`maxdif'*(`j'-1)+`p''
			}
			else {
				local listconst "`listconst' `=400+`maxdif'*(`j'-1)+`p'' `=600+`maxdif'*(`j'-1)+`p''"
				qui constraint list `=400+`maxdif'*(`j'-1)+`p'' `=600+`maxdif'*(`j'-1)+`p''
			}
		}
	}
	else { //RC détectée sur l'item j
		if "`group'" == "" {
			if dif_rc[`j',6]!=. & dif_rc[`j',6]!=0 { // RC unif.
				if `nbmoda_`j'' > 2 {
					forvalues p=2/`nbdif_`j''{          
						local listconst_g "`listconst_g' `=1000+`maxdif'*(`j'-1)+`p''"
						qui constraint list `=1000+`maxdif'*(`j'-1)+`p''
					}
				}
			}
		}
		else {
			if dif_rc[`j',4]==0{ /*RC commune: contraintes 801-1000*/
				forvalues p=1/`nbdif_`j''{           
					local listconst "`listconst' `=800+`maxdif'*(`j'-1)+`p''"
					qui constraint list `=800+`maxdif'*(`j'-1)+`p''
				}
				if dif_rc[`j',6]!=. & dif_rc[`j',6]!=0 { // RC commune unif.
					if `nbmoda_`j'' > 2 {
						forvalues p=2/`nbdif_`j''{          
							local listconst "`listconst' `=1000+`maxdif'*(`j'-1)+`p''"
							qui constraint list `=1000+`maxdif'*(`j'-1)+`p''
						}
					}
				}
			}
			else { // RC diff
				if dif_rc[`j',5]==. | dif_rc[`j',5]==0 { // RC gp0 (400)
					forvalues p=1/`nbdif_`j''{          
						local listconst "`listconst' `=400+`maxdif'*(`j'-1)+`p''"
						qui constraint list `=400+`maxdif'*(`j'-1)+`p''
					}		
				}
				if dif_rc[`j',6]!=. & dif_rc[`j',6]!=0 { // RCU gp0 (1001-1200)
					if `nbmoda_`j'' > 2 {
						forvalues p=2/`nbdif_`j''{          
							local listconst "`listconst' `=1000+`maxdif'*(`j'-1)+`p''"
							qui constraint list `=1000+`maxdif'*(`j'-1)+`p''
						}
					}
				}
				if dif_rc[`j',7]==. | dif_rc[`j',7]==0 { // RC gp1 (600)
					forvalues p=1/`nbdif_`j''{          
						local listconst "`listconst' `=600+`maxdif'*(`j'-1)+`p''"
						qui constraint list `=600+`maxdif'*(`j'-1)+`p''
					}	
				}
				if dif_rc[`j',8]!=. & dif_rc[`j',8]!=0 { // RCU gp1 (1201-1400)
					if `nbmoda_`j'' > 2 {
						forvalues p=2/`nbdif_`j''{          
							local listconst "`listconst' `=1200+`maxdif'*(`j'-1)+`p''"
							qui constraint list `=1200+`maxdif'*(`j'-1)+`p''
						}
					}
				}	
			}
		}
	}
}

local model ""

forvalues jj=1/`nbitems'{
	forvalues p=1/`nbdif_`jj''{
		local model "`model' (`p'.``jj''<-THETA1@`p')(`p'.``=`jj'+`nbitems'''<-THETA2@`p')"
	}
}

if "`group'" != "" {
	qui gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading) means(0: THETA1@0 THETA2@m20) means(1: THETA1@m11 THETA2@m21) var(0: THETA1@v1 THETA2@v2) var(1:THETA1@v1 THETA2@v2) cov(0: THETA1*THETA2@cov12) cov(1: THETA1*THETA2@cov12) constraint(`listconst') from(esti_2, skip) latent(THETA1 THETA2) nocapslatent
}
else {
	qui gsem `model', mlogit tol(0.01) iterate(100)  means( THETA1@0 THETA2@m2) var(THETA1@v1 THETA2@v2)  cov(THETA1*THETA2@cov12)  constraint(`listconst_g') from(esti_2, skip) latent(THETA1 THETA2) nocapslatent
}
	/* Stockage des estimations du modèle */
matrix val_m4 = r(table)
matrix esti_4 = e(b)

if "`group'" != "" {
	matrix var_m4 = (val_m4[1,"/var(THETA1)#0bn.`gp'"],val_m4[1,"/var(THETA2)#0bn.`gp'"]\val_m4[2,"/var(THETA1)#0bn.`gp'"],val_m4[2,"/var(THETA2)#0bn.`gp'"])
	matrix covar_m4 = (val_m4[1,"/cov(THETA1,THETA2)#0.`gp'"],val_m4[1,"/cov(THETA1,THETA2)#1.`gp'"]\val_m4[2,"/cov(THETA1,THETA2)#0.`gp'"],val_m4[2,"/cov(THETA1,THETA2)#1.`gp'"]\val_m4[4,"/cov(THETA1,THETA2)#0.`gp'"],val_m4[4,"/cov(THETA1,THETA2)#1.`gp'"])
}
else {
	matrix var_m4 = (val_m4[1,"/var(THETA1)"],val_m4[1,"/var(THETA2)"]\val_m4[2,"/var(THETA1)"],val_m4[2,"/var(THETA2)"])
	matrix covar_m4 = (val_m4[1,"/cov(THETA1,THETA2)"]\val_m4[2,"/cov(THETA1,THETA2)"]\val_m4[4,"/cov(THETA1,THETA2)"])
}

/* Matrice des tests effet grp, tps et inter */
matrix effet = J(5,3,.)
matrix colnames effet= Groupe Temps Interaction  
matrix rownames effet = Esti Std_Err Pvalue Chi DF

/*group effect*/
if "`group'" != "" {
	qui lincom [/]:mean(THETA1)#1.`gp'-[/]:mean(THETA1)#0bn.`gp'
	matrix effet[1,1] =r(estimate)
	matrix effet[2,1]=r(se)
	qui test [/]:mean(THETA1)#1.`gp'-[/]:mean(THETA1)#0bn.`gp' = 0
	matrix effet[3,1]=r(p)
	matrix effet[4,1]=r(chi2)
	matrix effet[5,1]=r(df)
}

/*time effect*/
if "`group'" != "" {
	qui lincom [/]:mean(THETA2)#0bn.`gp'-[/]:mean(THETA1)#0bn.`gp'
	matrix effet[1,2]=r(estimate)
	matrix effet[2,2]=r(se)
	qui test [/]:mean(THETA2)#0bn.`gp'-[/]:mean(THETA1)#0bn.`gp' = 0
	matrix effet[3,2]=r(p)
	matrix effet[4,2]=r(chi2)
	matrix effet[5,2]=r(df)
}
else {
	qui lincom [/]:mean(THETA2)	/* -[/]:mean(THETA1)*/
	local teffm4=r(estimate)
	local seteffm4=r(se)
	local ubteffm4 = r(ub)
	local lbteffm4 = r(lb)
	qui test [/]:mean(THETA2) /* -[/]:mean(THETA1) */ = 0
	local tm4p=r(p)
	local tm4chi=r(chi2)
	local tm4df=r(df)
}

*INTERACTION
if "`group'" != "" {
	qui lincom [/]:mean(THETA2)#1.`gp'-[/]:mean(THETA2)#0bn.`gp'-[/]:mean(THETA1)#1.`gp'+[/]:mean(THETA1)#0bn.`gp'
	matrix effet[1,3]=r(estimate)
	matrix effet[2,3]=r(se)
	local ubinterm4=r(ub)
	local lbinterm4=r(lb)
	qui test [/]:mean(THETA2)#1.`gp'-[/]:mean(THETA2)#0bn.`gp'-[/]:mean(THETA1)#1.`gp'+[/]:mean(THETA1)#0bn.`gp' = 0
	matrix effet[3,3]=r(p)
	matrix effet[4,3]=r(chi2)
	matrix effet[5,3]=r(df)
}

if "`group'" != "" {
	local effet_tps = 0
	local effet_grp = 0

	if effet[3,3] >= 0.05 { // Si option group, on s'interesse à l'interaction temps x group, et MAJ modèle >>> modèle final = modèle 4 + contrainte 1999 (Interaction = 0)
			/* Affichage des estimations sur le trait latent du modèle 4  */
		if "`detail'" != "" {
			di
			di %~85s as text "Latent trait distribution"
			di _col(10) "{hline 65}"
			di  _col(28) as text "Estimate" _col(46) "Standard error" _col(62) "P-value"
			di _col(10) "{hline 65}"
			di  _col(10) as text "Variance Time 1" as result _col(28) %6.2f `=var_m4[1,1]' _col(44) %6.2f `=var_m4[2,1]'
			di  _col(10) as text "Variance Time 2" as result _col(28) %6.2f `=var_m4[1,2]' _col(44) %6.2f `=var_m4[2,2]'
			di  _col(10) as text "Covariance" as result _col(28) %6.2f `=covar_m4[1,1]' _col(44) %6.2f `=covar_m4[2,1]'
			if "`group'" != "" {
				di _col(10) as text "Group effect" as result _col(28) %6.2f effet[1,1] _col(44) %6.2f effet[2,1] _col(62) %6.4f effet[3,1]
			}
			di _col(10) as text "Time effect" as result _col(28) %6.2f effet[1,2] _col(44) %6.2f effet[2,2] _col(62) %6.4f effet[3,2]

			if "`group'" != "" { 
				di _col(10) as text "TimexGroup inter" as result _col(28) %6.2f effet[1,3] _col(44) %6.2f effet[2,3] _col(62) %6.4f effet[3,3]
			}
			di as text _col(10) "{hline 65}"
			di
			di as result "Time x group interaction : test not significant
			di "Reestimation of model 4 with time x group interaction constrained at 0 "
			di
		}
		local yn_inter = 0
		local listconst "`listconst' 1999"
		qui di "`listconst'"
		local model ""
		forvalues jj=1/`nbitems'{
			forvalues p=1/`nbdif_`jj''{
				local model "`model' (`p'.``jj''<-THETA1@`p')(`p'.``=`jj'+`nbitems'''<-THETA2@`p')"
			}
		}
		qui gsem `model', mlogit tol(0.01) iterate(100) group(`gp') ginvariant(coef loading) means(0: THETA1@0 THETA2@m20) means(1: THETA1@m11 THETA2@m21) var(0: THETA1@v1 THETA2@v2) var(1:THETA1@v1 THETA2@v2) cov(0: THETA1*THETA2@cov12) cov(1: THETA1*THETA2@cov12) constraint(`listconst') from(esti_4, skip) latent(THETA1 THETA2) nocapslatent
			
		matrix val_m4 = r(table)
	}
	else {
		local yn_inter = 1
	}
	
	/*group effect*/
	qui lincom [/]:mean(THETA1)#1.`gp'-[/]:mean(THETA1)#0bn.`gp'
	local geffm4=r(estimate)
	local segeffm4=r(se)
	local ubgeffm4=r(ub)
	local lbgeffm4=r(lb)
	qui test [/]:mean(THETA1)#1.`gp'-[/]:mean(THETA1)#0bn.`gp'=0
	local gpm4p=r(p)
	local gpm4chi=r(chi2)
	local gpm4df=r(df)

	/*time effect*/
	qui lincom [/]:mean(THETA2)#0bn.`gp'-[/]:mean(THETA1)#0bn.`gp'
	local teffm4=r(estimate)
	local seteffm4=r(se)
	local lbteffm4=r(lb)
	local ubteffm4=r(ub)
	qui test [/]:mean(THETA2)#0bn.`gp'-[/]:mean(THETA1)#0bn.`gp'=0
	local tm4p=r(p)
	local tm4chi=r(chi2)
	local tm4df=r(df)
}

	/* Calcul des difficultés (delta_j) */
if "`group'" != "" {
	matrix mod4 = J(7,`=`nbmoda_sum'*4+6',.)
	local name_partTwoC ""
	forvalues j = 1/`nbitems' {
		forvalues p=1/`nbdif_`j'' {
			forvalues t=1/2 {
				forvalues g = 0/1 {
					local name_partTwoC "`name_partTwoC' d_j`j'_p`p'_gp`g'_t`t'"
				}
			}
		}
	}
	local name_partTwoC "`name_partTwoC' VAR(THETA1) VAR(THETA2) COV(TH1,TH2) GROUP_Effect TIME_Effect INTER_TxG  "
	matrix colnames mod4 = `name_partTwoC'
	matrix rownames mod4 =  Estimate se Upper_b Lower_b Chi_square DF pvalue
}
else {
	matrix mod4 = J(7,`=`nbmoda_sum'*2+4',.)
	local name_partTwoC ""
	forvalues j = 1/`nbitems' {
		forvalues p=1/`nbdif_`j'' {
			forvalues t=1/2 {
				local name_partTwoC "`name_partTwoC' d_j`j'_p`p'_t`t'"
			}
		}
	}
	local name_partTwoC "`name_partTwoC' VAR(THETA1) VAR(THETA2) COV(TH1,TH2) TIME_Effect "
	matrix colnames mod4 = `name_partTwoC'
	matrix rownames mod4 =  Estimate se Upper_b Lower_b Chi_square DF pvalue
}

*Difficultés
forvalues j=1/`nbitems'{
	forvalues p=1/`nbdif_`j''{	
		forvalues t=1/2{
			if "`group'" != "" { // groupe binaire
				forvalues g=0/1 {
					qui lincom -[`p'.``=(`t'-1)*`nbitems'+`j''']:`g'.`gp'
					local delta`t'_`j'_`p'g`g'm4= r(estimate)
					local delta`t'_`j'_`p'g`g'm4_se= r(se)
					local delta`t'_`j'_`p'g`g'm4_ub=r(ub)
					local delta`t'_`j'_`p'g`g'm4_lb=r(lb)
					local delta`t'_`j'_`p'g`g'm4_p=r(p)
					if `p'>1 {
						qui lincom [`=`p'-1'.``=(`t'-1)*`nbitems'+`j''']:`g'.`gp' - [`p'.``=(`t'-1)*`nbitems'+`j''']:`g'.`gp'
						local delta`t'_`j'_`p'g`g'm4=r(estimate)
						local delta`t'_`j'_`p'g`g'm4_se=r(se)
						local delta`t'_`j'_`p'g`g'm4_ub=r(ub)
						local delta`t'_`j'_`p'g`g'm4_lb=r(lb)
						local delta`t'_`j'_`p'g`g'm4_p=r(p)
					}
					local place = 0
					local compt = 1
					while `compt' < `j' {
						local place = `place' + `nbdif_`compt''
						local ++compt
					}
					if `t' == 1 {
						matrix mod4[1,`=4*(`p'-1)+`g'+`t'+4*`place'']=`delta`t'_`j'_`p'g`g'm4'
						matrix mod4[2,`=4*(`p'-1)+`g'+`t'+4*`place'']=`delta`t'_`j'_`p'g`g'm4_se'
						matrix mod4[3,`=4*(`p'-1)+`g'+`t'+4*`place'']=`delta`t'_`j'_`p'g`g'm4_ub'
						matrix mod4[4,`=4*(`p'-1)+`g'+`t'+4*`place'']=`delta`t'_`j'_`p'g`g'm4_lb'
						matrix mod4[7,`=4*(`p'-1)+`g'+`t'+4*`place'']=`delta`t'_`j'_`p'g`g'm4_p'
					}
					if `t' == 2 {
						matrix mod4[1,`=4*(`p'-1)+`g'+`t'+1+4*`place'']=`delta`t'_`j'_`p'g`g'm4'
						matrix mod4[2,`=4*(`p'-1)+`g'+`t'+1+4*`place'']=`delta`t'_`j'_`p'g`g'm4_se'
						matrix mod4[3,`=4*(`p'-1)+`g'+`t'+1+4*`place'']=`delta`t'_`j'_`p'g`g'm4_ub'
						matrix mod4[4,`=4*(`p'-1)+`g'+`t'+1+4*`place'']=`delta`t'_`j'_`p'g`g'm4_lb'
						matrix mod4[7,`=4*(`p'-1)+`g'+`t'+1+4*`place'']=`delta`t'_`j'_`p'g`g'm4_p'
					}
				}
			}
			else { // groupe unique (=gp0)
				qui lincom -[`p'.``=(`t'-1)*`nbitems'+`j''']_cons
				local delta`t'_`j'_`p'g0m4= r(estimate)
				local delta`t'_`j'_`p'g0m4_se= r(se)
				local delta`t'_`j'_`p'g0m4_ub=r(ub)
				local delta`t'_`j'_`p'g0m4_lb=r(lb)
				local delta`t'_`j'_`p'g0m4_p=r(p)
				if `p'>1{
					qui lincom [`=`p'-1'.``=(`t'-1)*`nbitems'+`j''']_cons - [`p'.``=(`t'-1)*`nbitems'+`j''']_cons
					local delta`t'_`j'_`p'g0m4=r(estimate)
					local delta`t'_`j'_`p'g0m4_se=r(se)
					local delta`t'_`j'_`p'g0m4_ub=r(ub)
					local delta`t'_`j'_`p'g0m4_lb=r(lb)
					local delta`t'_`j'_`p'g0m4_p=r(p)
				}
				local place = 0
				local compt = 1
				while `compt' < `j' {
					local place = `place' + `nbdif_`compt''
					local ++compt
				}
				if `t' == 1 {
					matrix mod4[1,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m4'
					matrix mod4[2,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m4_se'
					matrix mod4[3,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m4_ub'
					matrix mod4[4,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m4_lb'
					matrix mod4[7,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m4_p'
				}
				if `t' == 2 {
					matrix mod4[1,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m4'
					matrix mod4[2,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m4_se'
					matrix mod4[3,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m4_ub'
					matrix mod4[4,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m4_lb'
					matrix mod4[7,`=2*(`p'-1)+`t'+2*`place'']=`delta`t'_`j'_`p'g0m4_p'
				}
			}
		}
	}
}

if "`group'" != "" {
	matrix mod4[1,`=4*`nbmoda_sum'+1'] = (val_m4[1,"/var(THETA1)#0bn.`gp'"], val_m4[1,"/var(THETA2)#0bn.`gp'"])
	matrix mod4[2,`=4*`nbmoda_sum'+1'] = (val_m4[2,"/var(THETA1)#0bn.`gp'"],val_m4[2,"/var(THETA2)#0bn.`gp'"])
	matrix mod4[3,`=4*`nbmoda_sum'+1'] = (val_m4[6,"/var(THETA1)#0bn.`gp'"],val_m4[6,"/var(THETA2)#0bn.`gp'"])
	matrix mod4[4,`=4*`nbmoda_sum'+1'] = (val_m4[5,"/var(THETA1)#0bn.`gp'"],val_m4[5,"/var(THETA2)#0bn.`gp'"])
	
	matrix mod4[1,`=4*`nbmoda_sum'+2+1'] = (val_m4[1,"/cov(THETA1,THETA2)#0.`gp'"])
	matrix mod4[2,`=4*`nbmoda_sum'+2+1'] = (val_m4[2,"/cov(THETA1,THETA2)#0.`gp'"])
	matrix mod4[3,`=4*`nbmoda_sum'+2+1'] = (val_m4[6,"/cov(THETA1,THETA2)#0.`gp'"])
	matrix mod4[4,`=4*`nbmoda_sum'+2+1'] = (val_m4[5,"/cov(THETA1,THETA2)#0.`gp'"])

	matrix mod4[1,`=4*`nbmoda_sum'+2+1+1'] = `geffm4'
	matrix mod4[2,`=4*`nbmoda_sum'+2+1+1'] = `segeffm4'
	matrix mod4[3,`=4*`nbmoda_sum'+2+1+1'] = `ubgeffm4'
	matrix mod4[4,`=4*`nbmoda_sum'+2+1+1'] = `lbgeffm4'	
	matrix mod4[5,`=4*`nbmoda_sum'+2+1+1'] = `gpm4chi'
	matrix mod4[6,`=4*`nbmoda_sum'+2+1+1'] = `gpm4df'
	matrix mod4[7,`=4*`nbmoda_sum'+2+1+1'] = `gpm4p'

	
	matrix mod4[1,`=4*`nbmoda_sum'+2+1+1+1'] = `teffm4'
	matrix mod4[2,`=4*`nbmoda_sum'+2+1+1+1'] = `seteffm4'
	matrix mod4[3,`=4*`nbmoda_sum'+2+1+1+1'] = `ubteffm4'
	matrix mod4[4,`=4*`nbmoda_sum'+2+1+1+1'] = `lbteffm4'	
	matrix mod4[5,`=4*`nbmoda_sum'+2+1+1+1'] = `tm4chi'
	matrix mod4[6,`=4*`nbmoda_sum'+2+1+1+1'] = `tm4df'
	matrix mod4[7,`=4*`nbmoda_sum'+2+1+1+1'] = `tm4p'

	if `yn_inter' == 1 { //Slmt si model avec interaction
		matrix mod4[1,`=4*`nbmoda_sum'+2+1+1+1+1'] = effet[1,3]
		matrix mod4[2,`=4*`nbmoda_sum'+2+1+1+1+1'] = effet[2,3]
		matrix mod4[3,`=4*`nbmoda_sum'+2+1+1+1+1'] = `ubinterm4'
		matrix mod4[4,`=4*`nbmoda_sum'+2+1+1+1+1'] = `lbinterm4'
		matrix mod4[5,`=4*`nbmoda_sum'+2+1+1+1+1'] = effet[4,3]
		matrix mod4[6,`=4*`nbmoda_sum'+2+1+1+1+1'] = effet[5,3]
		matrix mod4[7,`=4*`nbmoda_sum'+2+1+1+1+1'] = effet[3,3]
	}
		
}
else {
	matrix mod4[1,`=2*`nbmoda_sum'+1'] = (val_m4[1,"/var(THETA1)"],val_m4[1,"/var(THETA2)"])
	matrix mod4[2,`=2*`nbmoda_sum'+1'] = (val_m4[2,"/var(THETA1)"],val_m4[2,"/var(THETA2)"])
	matrix mod4[3,`=2*`nbmoda_sum'+1'] = (val_m4[6,"/var(THETA1)"],val_m4[6,"/var(THETA2)"])
	matrix mod4[4,`=2*`nbmoda_sum'+1'] = (val_m4[5,"/var(THETA1)"],val_m4[5,"/var(THETA2)"])
	
	matrix mod4[1,`=2*`nbmoda_sum'+2+1'] = (val_m4[1,"/cov(THETA1,THETA2)"])
	matrix mod4[2,`=2*`nbmoda_sum'+2+1'] = (val_m4[2,"/cov(THETA1,THETA2)"])
	matrix mod4[3,`=2*`nbmoda_sum'+2+1'] = (val_m4[6,"/cov(THETA1,THETA2)"])
	matrix mod4[4,`=2*`nbmoda_sum'+2+1'] = (val_m4[5,"/cov(THETA1,THETA2)"])
	
	matrix mod4[1,`=2*`nbmoda_sum'+2+1+1'] = `teffm4'
	matrix mod4[2,`=2*`nbmoda_sum'+2+1+1'] = `seteffm4'
	matrix mod4[3,`=2*`nbmoda_sum'+2+1+1'] = `ubteffm4'
	matrix mod4[4,`=2*`nbmoda_sum'+2+1+1'] = `lbteffm4'	
	matrix mod4[5,`=2*`nbmoda_sum'+2+1+1'] = `tm4chi'
	matrix mod4[6,`=2*`nbmoda_sum'+2+1+1'] = `tm4df'
	matrix mod4[7,`=2*`nbmoda_sum'+2+1+1'] = `tm4p'
}


	/* Affichage des estimations des difficultés */
di  _col(5) as text "{ul:MODEL 4} = Final model"
di
if "`group'" != "" {
	di %~105s as text "Item difficulties: estimates (s.e.)"
	di _col(10) "{hline 85}"
	di _col(38) "Time 1" _col(76) "Time 2"
	di as text _col(25) abbrev("`gp'",15) "=0" _col(43) abbrev("`gp'",15) "=1" _col(64) abbrev("`gp'",15) "=0" _col(82) abbrev("`gp'",15) "=1" 
	di _col(10) "{hline 85}"
}
else {
	di %~70s as text as text "Item difficulties: estimates (s.e.)"
	di _col(10) "{hline 50}"
	di _col(25) "Time 1" _col(43) "Time 2"
	di _col(10) "{hline 50}"
}

forvalues j=1/`nbitems' {
	di as text _col(10) "``j''" 
	forvalues p=1/`nbdif_`j'' {
		if "`group'" != "" {
			di as text _col(10) "`p'" as result _col(25) %6.2f `delta1_`j'_`p'g0m4' " (" %4.2f `delta1_`j'_`p'g0m4_se' ")" _col(43) %6.2f `delta1_`j'_`p'g1m4' " (" %4.2f `delta1_`j'_`p'g1m4_se' ")" ///
			_col(63) %6.2f `delta2_`j'_`p'g0m4' " (" %4.2f `delta2_`j'_`p'g0m4_se' ")" _col(81) %6.2f `delta2_`j'_`p'g1m4' " (" %4.2f `delta2_`j'_`p'g1m4_se' ")"
		}
		else {
			di as text _col(10) "`p'" as result _col(25) %6.2f `delta1_`j'_`p'g0m4' " (" %4.2f `delta1_`j'_`p'g0m4_se' ")" _col(43) %6.2f `delta2_`j'_`p'g0m4' " (" %4.2f `delta2_`j'_`p'g0m4_se' ")"
		}
	}
}

if "`group'" != "" {
	di as text _col(10) "{hline 85}"
}
else {
	di as text _col(10) "{hline 50}"
}

	/* Affichage des estimations sur le trait latent du modèle final */
di
di %~85s as text "Latent trait distribution"
di _col(10) "{hline 65}"
di  _col(28) as text "Estimate" _col(44) "Standard error" _col(62) "P-value"
di _col(10) "{hline 65}" 

if "`group'" == "" {
	local fact_k = 2
}
else {
	local fact_k = 4
}

di  _col(10) as text "Variance Time 1" as result _col(28) %6.2f `=mod4[1,`=`fact_k'*`nbmoda_sum'+1']' _col(44) %6.2f =mod4[2,`=`fact_k'*`nbmoda_sum'+1']
di  _col(10) as text "Variance Time 2" as result _col(28) %6.2f `=mod4[1,`=`fact_k'*`nbmoda_sum'+2']' _col(44) %6.2f `=mod4[2,`=`fact_k'*`nbmoda_sum'+2']'
di  _col(10) as text "Covariance" as result _col(28) %6.2f `=mod4[1,`=`fact_k'*`nbmoda_sum'+3']' _col(44) %6.2f `=mod4[2,`=`fact_k'*`nbmoda_sum'+3']'

if "`group'" != "" {

	di _col(10) as text "Group effect" as result _col(28) %6.2f `geffm4' _col(44) %6.2f `segeffm4' _col(62) %6.4f `gpm4p'
}
di _col(10) as text "Time effect" as result _col(28) %6.2f `teffm4' _col(44) %6.2f `seteffm4' _col(62) %6.4f `tm4p'

if "`group'" != "" {
	if effet[3,3] < 0.05 {
		di _col(10) as text "TimexGroup inter" as result _col(28) %6.2f effet[1,3] _col(44) %6.2f effet[2,3] _col(62) %6.4f effet[3,3]
	}
	else {
		di _col(10) as text "TimexGroup inter" as result _col(28) "0 (constrained)" 
	}
}

di as text _col(10) "{hline 65}"

/***************************************/
/* Calcul des valeurs de DIF et de RC */
/*************************************/

forvalues j=1/`nbitems' {
	if `nbmoda_`j'' >= 2 {
		matrix valeur_difrc_`j' = J(`nbdif_`j'',8,.)
		matrix colnames valeur_difrc_`j' = DIFT1 DIFT1_SE RC_GP0 RC_GP0_SE RC_GP1 RC_GP1_SE 
	}
}

forvalues j=1/`nbitems'{
	if `nbmoda_`j'' >= 2 {
		if "`group'" != "" {
			*DIF
			if "`nodif'"=="" {
				if (dif_rc[`j',1] != . ) {
					forvalues p=1/`nbdif_`j'' {
						if `p' == 1 {
							qui lincom -[1.``j'']:1.`gp'+[1.``j'']:0.`gp'
							matrix valeur_difrc_`j'[`p',1] = r(estimate)
							matrix valeur_difrc_`j'[`p',2] = round(r(se),0.01)
						}
						if `p' > 1 {
							qui lincom [`=`p'-1'.``j'']:1.`gp' - [`p'.``j'']:1.`gp' -[`=`p'-1'.``j'']:0.`gp' + [`p'.``j'']:0.`gp' 
							matrix valeur_difrc_`j'[`p',1] = r(estimate)
							matrix valeur_difrc_`j'[`p',2] = round(r(se),0.01)
						}
					}
				}
			}
			*RC GROUP 0
			if (dif_rc[`j',3] != . & dif_rc[`j',5] != . )  {
				forvalues p=1/`nbdif_`j'' {
					qui lincom -[1.``=`j'+`nbitems''']:0.`gp' + [1.``j'']:0.`gp'
					matrix valeur_difrc_`j'[`p',3] = r(estimate)
					matrix valeur_difrc_`j'[`p',4] = round(r(se),0.01)
					if `p' > 1 {
						qui lincom [`=`p'-1'.``=`j'+`nbitems''']:0.`gp' - [`p'.``=`j'+`nbitems''']:0.`gp' -[`=`p'-1'.``j'']:0.`gp' + [`p'.``j'']:0.`gp'
						matrix valeur_difrc_`j'[`p',3] = r(estimate)
						matrix valeur_difrc_`j'[`p',4] = round(r(se),0.01)
					}
				}
			}
			*RC GROUP 1
			if (dif_rc[`j',3] != . & dif_rc[`j',7] != . ) {
				forvalues p=1/`nbdif_`j'' {
					qui lincom -[1.``=`j'+`nbitems''']:1.`gp' + [1.``j'']:1.`gp'
					matrix valeur_difrc_`j'[`p',5] = r(estimate)
					matrix valeur_difrc_`j'[`p',6] = round(r(se),0.01)
					if `p' > 1 {
						qui lincom [`=`p'-1'.``=`j'+`nbitems''']:1.`gp' - [`p'.``=`j'+`nbitems''']:1.`gp' -[`=`p'-1'.``j'']:1.`gp' + [`p'.``j'']:1.`gp'
						matrix valeur_difrc_`j'[`p',5] = r(estimate)
						matrix valeur_difrc_`j'[`p',6] = round(r(se),0.01)
					}	
				}
			}
		}
		else {
			forvalues p=1/`nbdif_`j'' {
				qui lincom -[1.``=`j'+`nbitems''']_cons + [1.``j'']_cons
				matrix valeur_difrc_`j'[`p',3] = r(estimate)
				matrix valeur_difrc_`j'[`p',4] = round(r(se),0.01)
				if `p' > 1 {
					qui lincom [`=`p'-1'.``=`j'+`nbitems''']_cons - [`p'.``=`j'+`nbitems''']_cons -[`=`p'-1'.``j'']_cons + [`p'.``j'']_cons
					matrix valeur_difrc_`j'[`p',3] = r(estimate)
					matrix valeur_difrc_`j'[`p',4] = round(r(se),0.01)						
				}
			}
		}
	}
}

forvalues j = 1/`nbitems' {
	if `nbmoda_`j'' >= 2 {
		forvalues p = 1/`nbdif_`j'' {
			forvalues k = 1/8 {
				if valeur_difrc_`j'[`p',`k'] == . {
					matrix valeur_difrc_`j'[`p',`k'] = 0
				}
			}
		}
	}
}

	/* Affichage des estimations des valeurs de DIF et de RC */
if "`group'" != "" {
	di
	di %~85s as text "Estimates of differences between groups and recalibration"
}
else {
	di
	di %~50s as text "Estimates of recalibration"
}
if "`group'" != "" & "`nodif'"==""{
	di _col(10) "{hline 65}"
	di _col(27) "Difference of" _col(52) "RECALIBRATION"
	di _col(27) "groups at T1" _col(47) abbrev("`gp'",15) "=0" _col(62) abbrev("`gp'",15) "=1" 
	di _col(10) "{hline 65}"
}
else if "`group'" != "" & "`nodif'"!="" {
	di _col(10) "{hline 50}"
	di _col(32) "RECALIBRATION"
	di in ye  _col(27) "`gp'=`=rep[1,1]'" _col(47) "`gp'=`=rep[2,1]'"
	di _col(10) "{hline 50}"
}
else {
	di _col(10) "{hline 30}"
	di _col(25) "RECALIBRATION"
	di _col(10) "{hline 30}"
}

forvalues j=1/`nbitems' {
	if `nbmoda_`j'' >= 2 {
		if "`group'" != "" & "`nodif'" == "" {
			di as text _col(10) "``j''" 
		}
		else {
			di as text _col(10) "``j''" 
		}
		forvalues p=1/`nbdif_`j'' {
			if "`group'" != "" & "`nodif'"=="" { 
				di as text _col(10) "`p'" as result _col(27) %6.2f `=valeur_difrc_`j'[`p',1]' " (" %4.2f `=valeur_difrc_`j'[`p',2]' ")"  ///
				_col(47) %6.2f `=valeur_difrc_`j'[`p',3]' " (" %4.2f `=valeur_difrc_`j'[`p',4]' ")" _col(62) %6.2f `=valeur_difrc_`j'[`p',5]' " (" %4.2f `=valeur_difrc_`j'[`p',6]' ")" 
			}
			else if "`group'" != "" & "`nodif'"!="" {
				di as text _col(10) "`p'" as result _col(25) %6.2f `=valeur_difrc_`j'[`p',3]' " (" %4.2f `=valeur_difrc_`j'[`p',4]' ")" _col(45) %6.2f `=valeur_difrc_`j'[`p',5]' " (" %4.2f `=valeur_difrc_`j'[`p',6]' ")" 
			}
			else {
				di as text _col(10) "`p'" as result _col(25) %6.2f `=valeur_difrc_`j'[`p',3]' " (" %4.2f `=valeur_difrc_`j'[`p',4]' ")"
			}
		}
	}
}

if "`group'" != "" & "`nodif'"=="" {
	di as text _col(10) "{hline 65}"	
}
else if "`group'" != "" & "`nodif'"!=""{
	di as text _col(10) "{hline 50}"
}
else {
	di as text _col(10) "{hline 30}"
}
di


*******************************************************************************
* New outputs

if "`group'" == "" {
	matrix testlrm = J(1,3,.)
	matrix colnames testlrm = chi_square df pvalue
	matrix rownames testlrm = m1_vs_m2
	matrix testlrm[1,1] = (`rstestchi',`rstestdf',`rstestp')
	return matrix test_model = testlrm
}
else if "`nodif'" != "" {
	matrix testlrm = J(1,3,.)
	matrix colnames testlrm = chi_square df pvalue
	matrix rownames testlrm = m1_vs_m2
	matrix testlrm[1,1] = (`rstestchi',`rstestdf',`rstestp')
	return matrix test_model = testlrm
}
else {
	matrix testlrm = J(2,3,.)
	matrix colnames testlrm = chi_square df pvalue
	matrix rownames testlrm = mA_vs_mB m1_vs_m2
	matrix testlrm[1,1] = (`diftestchi',`diftestdf',`diftestp')
	matrix testlrm[2,1] = (`rstestchi',`rstestdf',`rstestp')
	return matrix test_model = testlrm
}

return matrix model_4 = mod4
return matrix model_2 = mod2

capture qui use `saverspcm', clear

end	
	
