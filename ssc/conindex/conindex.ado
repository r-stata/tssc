*! conindex 1.5  18 July 2018
*! Copyright (C) 2015 Owen O'Donnell, Stephen O'Neill, Tom Van Ourti & Brendan Walsh.
*! svy option added (16 Feb 2016)
*| using lorenz.ado for graphs (18 July 2018)

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
capture program drop conindex
program define conindex, rclass sortpreserve byable(recall)
version 11.0
syntax varname [if] [in] [fweight aweight pweight]  , [RANKvar(varname)] [, robust] [, CLUSter(varname)] [, truezero] [, LIMits(numlist min=1 max=2 missingokay)] [, generalized][, generalised] [, bounded] [, WAGstaff] [, ERReygers]  [, v(string)] [,beta(string)] [, graph] [, loud] [, COMPare(varname)] [, KEEPrank(string)] [, ytitle(string)] [, xtitle(string)] [,compkeep(numlist)] [,extended] [,symmetric] [,bygroup(numlist)] [,svy] 
marksample touse
tempname grouptest counter
tempvar wght sumw cumw cumw_1 cumwr cumwr_1 frnk temp sigma2 meanlhs meanlhs_star cumlhs cumlhs1 lhs rhs1 rhs2 xmin xmax varlist_star weight1 meanweight1 tempx temp1x sumlhsx  temps tempex lhsex rhs1ex rhs2ex sigma2ex exrank tempgx  lhsgex lhsgexstar symrank smrankmean tempsym sigma2sym lhssym lhssymstar rhs1sym rhs2sym lhsgsym tempgxstar raw_rank_c wi_c cusum_c wj_c rank_c var_rank_c mean_c lhs_c split_c ranking  extwght temp1 meanweight  sumlhs sumwr  counts meanoverall tempdis temp0 meanlhs2  rhs temp2  frnktest meanlhsex2  equality group lhscomp  rhs1comp rhs2comp rhscomp intercept scale  
local weighted [`weight'`exp'] 
if "`weight'" != "" local weighted [`weight'`exp'] 
if "`weight'" == "" qui gen byte `wght' = 1 
else qui gen `wght'`exp'

if "`svy'"!=""{
	if "`weight'" != ""  {
		di as error "When the svy option is used, weights should only be specified using svyset."
		exit 498 
	}
	if "`cluster'"!="" {
		di as error "Warning: cluster option is redundant when using the svy option. svyset should be used to identify the survey design characteristics"
	}
	if "`robust'"!="" {
		di as error "Warning: robust option is redundant when using the svy option. svyset should be used to identify the survey design characteristics"
	}
	qui svyset
	if r(settings) == ", clear"{
		di as error "svyset must be used to identify the survey design characteristics prior to running conindex with the svy option."
		exit 498 
	}
	local wtype = r(wtype)
	local wvar = r(wvar)
	if "`wtype'" != "." {
		local weighted "[`wtype' = `wvar']" 
		qui replace `wght'=`wvar'
	}
	else replace `wght'=1
	local survey "svy:"
}

markout `touse' `rankvar' `wght' `clus' `compare'

quietly {
	local xxmin: word 1 of `limits'
	local xxmax: word 2 of `limits'

	if _by()==1 {
		if "`compare'"!="" {
			di as error "The option compare cannot be used in conjunction with by."
			exit 498 
		}
	}
	if "`compkeep'"=="" local bygroup = _byindex() 
	
	if "`generalised'"=="generalised" local generalized="generalized"
	
	if "`extended'"!="" | "`symmetric'"!="" {
		di as error "Please see the help file for the correct syntax for the extended and symmetric indices"
		exit 498 
	}
	
	if "`xxmin'"=="" {
		scalar xmin=.
	}
	else scalar xmin=`xxmin'
	if "`xxmax'"=="" {
		scalar xmax=.
	}
	else scalar xmax=`xxmax'
	
	if "`weight'"!="" {
		sum `varlist' [aweight`exp'] if `touse'
	}
	else sum `varlist' if `touse'
	return scalar N=r(N)
	
	scalar testmean=r(mean)
	count if `varlist' < 0 & `touse'
	if r(N) > 0 {
		noisily disp as txt _n "Note: `varlist' has `r(N)' values less than 0"
	}
	
	if "`rankvar'" == "`varlist'" | "`rankvar'" ==""{
		local index = "Gini"
	}
	else local index = "CI"
	
	gen double `ranking'=`varlist'
	if "`rankvar'" != "" {
		replace `ranking'=`rankvar'	
		local label : variable label `rankvar'
		label variable `ranking' `"`label'"'	
	}	
	gen double `varlist_star'=`varlist'
	
	local CompWT_options = " `varlist'"
	if "`if'"!="" {
		local compif0="`if' & `compare'==0"
		local compif1="`if' & `compare'==1"
	}
	else {
		local compif0=" if `compare'==0"
		local compif1=" if `compare'==1"
	}
	forvalues i=0(1)1 {
		if "`weight'"!=""{
			local CompWT_options`i' = "`CompWT_options' [`weight'`exp'] `compif`i'' `in',"
		}
		else local CompWT_options`i' = "`CompWT_options' `compif`i'' `in',"
	}
	if "`rankvar'"!="" {
		local Comp_options = "`Comp_options' rankvar(`rankvar')"
	}
	if "`cluster'"!="" {
		local Comp_options = "`Comp_options' cluster(`cluster')"
	}
	if xmin!=. {
		local Comp_options = "`Comp_options' limits(`limits')"
	}
	if "`v'"!="" {
		local Comp_options = "`Comp_options' v(`v')"
	}
	if "`beta'"!="" {
		local Comp_options = "`Comp_options' beta(`beta')"
	}
	if "`loud'"!="" {
		local Comp_options = "`Comp_options' loud"
	}
	if "`'"!="" {
		local Comp_options = "`Comp_options' "
	}
	foreach opt in robust truezero generalized bounded wagstaff erreygers svy{
		if "``opt''"!="" {
			local Comp_options = "`Comp_options' `opt'"
		}
	}
	
	local extended=0
	local symmetric=0
	local modified=0
	local problem=0
	
	if "`truezero'"=="truezero" {
		if testmean==0 {
			if `problem'==0  di as err="The mean of the variable (`varlist') is 0 - the standard concentration index is not defined in this case." 
			local problem=1
		}
		if xmin != . {
			if xmin>0 {
				if `problem'==0 di as err="The lower bound for a ratio scale variable cannot be greater than 0." 
				local problem=1
			}
		}
	}	
	if "`generalized'"=="generalized" {
		local generalized=1 
	}
	else local generalized=0
	if "`truezero'"!="truezero" {
		if `generalized'==1 {
			if `problem'==0  di as err="The option truezero must be used when specifying the generalized option."
			local problem=1
		}	
		else local generalized=0 
	}
	
	if "`bounded'"!="" {
		if xmax==. {
			if `problem'==0 di as err="For bounded variables, the limits option must be specified as limits(#1 #2) where #1 is the minimum and #2 is the maximum."
			local problem=1	
		}
		local bounded=1 
		if xmin > xmax |xmin == xmax | xmin ==.{
			if `problem'==0 di as err="For bounded variables, the limits option must be specified as limits(#1 #2) where #1 is the minimum and #2 is the maximum."
			local problem=1
		}
		sum `varlist'
		if xmin!=.{
			if r(min)<xmin |r(max)>xmax{
				if `problem'==0 di as err="The variable (`varlist') takes values outside of the specified limits."
				local problem=1
			}	
			if r(min)>=xmin & r(max)<=xmax{		
				replace `varlist_star'=(`varlist'-xmin)/(xmax-xmin)		
			}
		}
	}
	else local bounded=0
	if "`wagstaff'"=="wagstaff" local wagstaff=1 
		else local wagstaff=0
	if "`erreygers'"=="erreygers" local erreygers=1 
		else local erreygers=0	
	if `bounded'==0 & (`erreygers'==1| `wagstaff'==1){
		di as err="Wagstaff and Erreygers Normalisations are only for use with bounded variables."
		di as err="Hence the bounded and limits(#1 #2) options must be used to specify the theoretical minimum (#1) and maximum (#2)."
		local problem=1
	}	
	if (`erreygers'==1 & `wagstaff'==1){
		di as err="The option wagstaff cannot be used in conjunction with the option erreygers."	
		local problem=1
	}
	if "`v'"!="" {
		capture confirm number `v'
		if _rc {
			di as err="For the option v(#), # must be a number greater than 1."
			local problem=1
		}
		if `v'<=1 & _rc==0 {
			di as err="For the option v(#), # must not be less than 1."
			local problem=1
		}
		local extended=1
	}
	if "`beta'"!=""  {
		capture  confirm number `beta'
		if _rc {
			di as err="For the option beta(#), # must be a number greater than 1."
			local problem=1
		}
		if `beta'<=1 & _rc==0 {
			di as err="For the option beta(#), # must not be less than 1."
			local problem=1
		}
		local symmetric=1
	}
	
	if `extended'==1 & `symmetric'==1{
		di as err="The option v(#) cannot be used in conjunction with the option beta(#)."
		local problem=1
	}
	
	if (`extended'==1 | `symmetric'==1) & (`erreygers'==1| `wagstaff'==1){
		di as err="Wagstaff and Erreygers Normalisations are not supported for extended/symmetric indices."
		local problem=1
	}	
	
	if (`generalized'==1) & (`erreygers'==1| `wagstaff'==1){
		di as err="Cannot specify generalized in conjunction with Wagstaff or Erreygers Normalisations."
		local problem=1
	}	
	
	if xmin != . {
		sum `varlist'
		if r(min)<xmin{
			if `problem'==0 di as err="The variable (`varlist') takes values outside of the specified limits."
			exit 498
		}
		if "`truezero'"=="truezero" {
			di as txt="Note: The option truezero has been specified in conjunction with the limits option."
			if `extended'==1 | `symmetric'==1{
				di as txt="      The index will be calculated using the standardised variable (`varlist' - min)/(max - min)." 
			}
			else di as txt="      The limits are redundant as the variable is assumed to be ratio scaled (or fixed)." 
		}
	}
		
	if "`truezero'"!="truezero" & `extended'==0 & `symmetric'==0 & `erreygers'==0 & `wagstaff'==0  & `generalized'==0 & `bounded'==0{
		local modified=1
		if xmin == . | xmax != . {
			di as err="For the modified concentration index, the limits option must be specified as limits(#1) where #1 is the minimum." 
			di as err="If you require an alternative index, please look at the help file by typing - help conindex - to find the correct syntax." 
			local problem=1
		}	
		if xmin == . {
			di as err="For the modified concentration index (the default), a missing value (.) may not be used as the lower limit. "
			local problem=1
		}
		sum `varlist'
		if r(min)==r(max){
			di as err="The modified concentration index cannot be computed since the variable (`varlist') is always equal to its minimum value."
			local problem=1
		}
	}
	
	if "`truezero'"!="truezero" {
		if `extended'==1 | `symmetric'==1{
			di as err="The extended and symmetric indices should be used for ratio-scale variables and hence truezero must be specified also."
			local problem=1
		}
	}	
	
	if "`graph'"=="graph"{
		if "`truezero'"!="truezero" & `bounded'!=0{
			di as err="Graph option only available for ratio-scale variables - please also specify the truezero option if the variable is ratio-scale or the bounded option if the variable is bounded."
			local problem=1
		}
		if "`wagstaff'"=="wagstaff" | "`erreygers'"=="erreygers"{
			di as err="Graph option not supported for Wagstaff or Erreygers Normalisations."
			local problem=1
		}
		if `extended'==1 | `symmetric'==1{
			di as err="Graph option not supported for Extended or Symmetric Indices."
			local problem=1
		}
	}
	
	if "`loud'"=="loud" local noisily="noisily"	
	if `problem'==1  exit 498 
	if `generalized'==1 & `extended'==1 noisily disp as txt _n "Note: The extended index equals the Erreygers normalised CI when v=2"
	if `generalized'==1 & `symmetric'==1 noisily disp as txt _n "Note: The symmetric index equals the Erreygers normalised CI when beta=2"
	
	if "`robust'"=="robust" | "`cluster'"!=""{
		local SEtype="Robust std. error"
	}
	else local SEtype="Std. error"


	if "`svy'"!="" & (`extended'==0 & `symmetric'==0) gen `scale'=1
	else gen double `scale'=sqrt(`wght')
	
	gsort -`touse' `ranking'
	egen double `sumw'=sum(`wght') if `touse'
	gen double `cumw'=sum(`wght') if `touse'
	gen double `cumw_1'=`cumw'[_n-1] if `touse'
	replace `cumw_1'=0 if `cumw_1'==.
	bys `ranking': egen double `cumwr'=max(`cumw') if `touse'
	bys `ranking': egen double `cumwr_1'=min(`cumw_1') if `touse'
	gen double `frnk'=(`cumwr_1'+0.5*(`cumwr'-`cumwr_1'))/`sumw' if `touse'
	gen double `temp'=(`wght'/`sumw')*((`frnk'-0.5)^2) if `touse'
	egen double `sigma2'=sum(`temp') if `touse'
	replace `temp'=`wght'*`varlist_star'
	egen double `meanlhs'=sum(`temp') if `touse'
	replace `meanlhs'=`meanlhs'/`sumw'
	
	if  `modified'==1 & `bounded'==0{
		replace `meanlhs'=`meanlhs'-xmin
	}


	if "`graph'"=="graph" {
 		capture which lorenz
 		if _rc==111 disp "conindex requires the lorenz.ado by Ben Jahn to produce graphs. Please install this before using conindex." 
		if "`ytitle'" ==""{
			local ytext : variable label `varlist' 
			if "`ytext'" == "" local ytext "`varlist'" 
			local ytitle = "Cumulative share of `ytext'"
			if `generalized'==1 {
				if "`ytext'" == "" local ytext "`varlist'" 
				local ytitle = "Cumulative average of `ytext'"
			}
		}
		if "`xtitle'" ==""{
			if "`rankvar'"  == "" local xtext : variable label `varlist' 
			if "`rankvar'"  != "" local xtext : variable label `ranking' 
			if "`xtext'" == "" local xtext "`rankvar'" 
			if "`xtext'" == "" local xtext "`varlist'" 
			local xtitle = "Rank of `xtext'"
		}	
		if `generalized'== 0{
			lorenz estimate `varlist_star', pvar(`ranking')
			lorenz graph, ytitle(`ytitle', size(medsmall)) yscale(titlegap(5))  xtitle(`xtitle', size(medsmall))  ytitle(`ytitle', size(medsmall)) graphregion(color(white)) bgcolor(white) 
		}
		if `generalized'==1 {
			lorenz estimate `varlist_star', pvar(`ranking') generalized 
			lorenz graph, ytitle(`ytitle', size(medsmall)) yscale(titlegap(5))  xtitle(`xtitle', size(medsmall))  ytitle(`ytitle', size(medsmall)) graphregion(color(white)) bgcolor(white) 
		}	
	}

	
	noisily  di in smcl ///
        "{hline 19}{c TT}{hline 13}{c TT}{hline 13}{c TT}{hline 19}" _c
	noi di in smcl  "{c TT}{hline 10}{c TRC}"

	noisily  di in text "Index:" _col(20) "{c |} No. of obs." _col(34) ///
          "{c |} Index value" _col(48) "{c |} `SEtype'" _col(68) ///
          "{c |} p-value" _col(79) "{c |}"
	noisily  di in smcl ///
        "{hline 19}{c +}{hline 13}{c +}{hline 13}{c +}{hline 19}" _c
	noi di in smcl  "{c +}{hline 10}{c RT}"
	
	gen double `lhs'=2*`sigma2'*(`varlist_star'/`meanlhs')*`scale' if `touse'
	gen double `intercept'=`scale' if `touse'
	gen double `rhs'=`frnk'*`scale' if `touse'
	
	local type = "`index'"
	
	if  `modified'==1 & `bounded'==0{
		replace `meanlhs'=`meanlhs'+xmin
	}
	
	if `generalized'==0 & `erreygers'==0 & `wagstaff'==0{
		`noisily'  disp "`index'"
		local type = "`index'"
	}
	if `modified'==1 {
		`noisily'  disp "Modified `index'"
		local type = "Modified `index'"
		replace `lhs'=`lhs'*(`meanlhs')/(`meanlhs'-xmin) if `touse' ==1
	}	
	if `wagstaff'==1{
		`noisily'  disp "Wagstaff Normalisation"
		local type = "Wagstaff norm. `index'"
		replace `lhs'= `lhs'/(1-`meanlhs') if `touse' 
	}
	if `erreygers'==1{
		`noisily'  disp "Errygers Normalisation"
		local type = "Erreygers norm. `index'"
		replace `lhs'= `lhs'*(4*`meanlhs') if `touse'
	}
	if `generalized'==1 {
		`noisily'  disp "Gen. standard `index'"
		local type = "Gen. `index'"
		replace `lhs'=`lhs'*`meanlhs' if `touse'
	}	
	
	if `extended'==1 | `symmetric'==1{
		gsort -`touse' `frnk'
		gen double `temp1'=`wght'*`varlist_star' if `touse'
		egen double `sumlhs'=sum(`temp1') if `touse'
		bys `ranking': egen double `sumwr'=sum(`wght') if `touse'
		bys `ranking': egen double `counts'=count(`temp1') if `touse'
		gen `meanoverall'=`sumlhs'/`sumw' if `touse'
		bys `ranking': egen double `temp0'=rank(`ranking') if `touse', unique
		bys `ranking': egen double `meanlhs2'=sum(`temp1') if `touse'
		replace `meanlhs2'=`meanlhs2'/`sumwr' if `touse'
	}	
	
	
	if `extended'==1{
		capture drop `lhs'
		capture drop `rhs'
		capture drop `temp2' 
		gen double `rhs'=((`sumwr'/`sumw')+((1-(`cumwr'/`sumw'))^`v')-((1-(`cumwr_1'/`sumw'))^`v')) if `temp0'==1
		egen double `temp2'=sum(`rhs'^2) if `temp0'==1
		gen double `lhs'=(`meanlhs2'/`meanoverall')*`temp2' if `touse' & `temp0'==1
		local type = "Extended `index'"	
		if `generalized'==1{
			local type = "Gen. extended `index'"
			replace `lhs'=(`meanlhs2'*(`v'^(`v'/(`v'-1)))/(`v'-1))*`temp2' if `touse' & `temp0'==1
		}
	}			
	
	if `symmetric'==1{
		capture drop `lhs'
		capture drop `rhs'
		capture drop `temp2' 
		gen double `rhs'=(2^(`beta'-2))*(abs((`cumwr'/`sumw'-0.5))^`beta'-(abs(`cumwr_1'/`sumw'-0.5))^`beta') if `temp0'==1
		egen double `temp2'=sum(`rhs'^2) if `temp0'==1
		gen double `lhs'=(`meanlhs2'/`meanoverall')*`temp2' if `touse' & `temp0'==1
		local type = "Symmetric `index'"
	
		if `generalized'==1{
			local type = "Gen. symmetric `index'"
			replace `lhs'=`meanlhs2'*4*`temp2' if `touse' & `temp0'==1
		}
	}
	`noisily'  regress `lhs' `rhs' `intercept' if `touse'==1, `robust' cluster(`cluster') noconstant
	if "`survey'"=="" `noisily'  regress `lhs' `rhs' `intercept' if `touse'==1, `robust' cluster(`cluster') noconstant
	if "`survey'"=="svy:" `noisily' svy: regress `lhs' `rhs' `intercept' if `touse'==1,  noconstant

	
	return scalar RSS=e(rss)
 	mat b=e(b)
 	mat V=e(V)
 	return scalar CI= b[1,1]
 	return scalar CIse= sqrt(V[1,1])

	if `extended'==1 | `symmetric'==1{
		`noisily'   regress `lhs' `rhs'  if `temp0'==1, robust
		return scalar RSS=e(rss)
		mat b=e(b)
		mat V=e(V)
		return scalar CI= b[1,1]
		return scalar CIse = .
	}
	
	return scalar Nunique= e(N)
	local nclus= e(N_clust) 
	local t=return(CI)/return(CIse)
 	local p=2*ttail(e(df_r),abs(`t'))
 	noisily  di in text "`type'" _col(20) "{c |} " as result return(N) ///
	    _col(34) "{c |} " as result return(CI) _col(48) "{c | }" ///
 	    as result return(CIse) _col(68) "{c |} " as result %7.4f ///
	    `p' _col(79)"{c |}"
 	noisily  di in smcl ///
        "{hline 19}{c BT}{hline 13}{c BT}{hline 13}{c BT}{hline 19}" _c
	noi di in smcl  "{c BT}{hline 10}{c BRC}"

	if `nclus'!=. noisily  di in text "(Note: Std. error adjusted for `nclus' clusters in `cluster')"
	if return(Nunique)!=return(N) noisily  di in text "(Note: Only " return(Nunique) " unique values for `rankvar')"
	if `extended'==1 | `symmetric'==1{
		noisily  di in text "(Note: Standard errors for the extended and symmetric indices are not calculated by the current version of conindex.)"
	}
	
	if "`keeprank'"!="" {
		tempname savedrank
		gen  double `savedrank'=`frnk'
		if _by()==0  {
			confirm new variable `keeprank'`compkeep'
			gen  double `keeprank'`compkeep'=`savedrank'
		}
		if _by()==1 {
			gen  double `keeprank'_`bygroup'=`savedrank'
			}			
	} 
	



	if "`compkeep'"!="" {
		confirm new variable templhs
		gen double templhs=`lhs'
		confirm new variable temprhs
		gen double temprhs=`rhs'
	}
	if "`compare'"!=""{
		egen `group' = group(`compare')
		qui sum `group' if `touse' , meanonly
		scalar gmax=r(max)
		noisily  di in text ""
		noisily  di in text ""
		noisily  di in text "For groups:"
		noisily  di in text ""
		noisily  di in text ""
		
		gen double `lhscomp'=.  
		gen double `rhscomp'=.
		foreach i of num 1/`=scalar(gmax)'  {
			if "`if'"!="" {
				local compif`i'="`if' & `group'==`i'"
			}
			else {
				local compif`i'=" if `group'==`i'"
			}
			if "`weight'"!=""{
				local CompWT_options`i' = "`CompWT_options' [`weight'`exp'] `compif`i'' `in',"
			}
			else local CompWT_options`i' = "`CompWT_options' `compif`i'' `in',"
			qui sum `compare' if `touse' & `group'==`i', meanonly 
			noisily  di in text "CI for group `i': `compare' = "r(mean)
			noisily conindex `CompWT_options`i'' `Comp_options' keeprank(`keeprank') compkeep(`i') 
			noisily  di in text ""
			replace `lhscomp'=templhs if `touse' & `group'==`i'
			replace `rhscomp'=temprhs if `touse' & `group'==`i'
			drop templhs temprhs
			}	
		`noisily'  regress `lhscomp' c.`rhscomp' i.`group' if `touse',  `robust' cluster(`cluster')
		return scalar N_restricted=e(N)
		return scalar SSE_restricted=e(rss)
		`noisily'  regress `lhscomp' c.`rhscomp'##i.`group' if `touse',  `robust' cluster(`cluster')
		noisily  di in text ""
		return scalar SSE_unrestricted=e(rss)
		return scalar N_unrestricted=e(N)

		return scalar F=[(return(SSE_restricted)-return(SSE_unrestricted))/(gmax-1)]/(return(SSE_unrestricted)/(return(N_restricted)-2*gmax))
		local p=1 - F(gmax-1,(return(N_restricted)- 2*gmax), return(F))						/* OO'D made two changes to second df 28.5.14 */
		noisily  di in text "Test for stat. significant differences with Ho: diff=0 (assuming equal variances)" _col(50) "
		noi di in smcl "{hline 19}{c TT}{hline 19}{c TRC}"
		noisily  di in text "F-stat = " as result return(F) _col(20) "{c |} p-value= "  as result %7.4f `p' _col(40) "{c |}"		
		noi di in smcl "{hline 19}{c BT}{hline 19}{c BRC}"

		if gmax==2{
			disp "Group: `compare'=0"
			conindex `CompWT_options1' `Comp_options' 
			return scalar CI0=r(CI)
			return scalar CIse0=r(CIse)
			disp "Group: `compare'=1"

			conindex `CompWT_options2' `Comp_options' 
			return scalar CI1=r(CI)
			return scalar CIse1=r(CIse)
			return scalar Diff= return(CI1)-return(CI0)
	
			return scalar Diffse= sqrt((return(CIse0))^2 + (return(CIse1))^2)
			return scalar z=return(Diff)/return(Diffse)
			local p=2*(1-normal(abs(return(z))))
			noisily  di in text "Test for stat. significant differences with Ho: diff=0 " _col(50) "(large sample assumed)"
			noi di in smcl ///
				"{hline 19}{c TT}{hline 23}{c TT}{hline 17}{c TT}{hline 18}{c TRC}"
			noisily  di in text "Diff. = " as result return(Diff) _col(20) ///
				"{c |} Std. err. = " as result return(Diffse) _col(44) ///
				"{c |} z-stat = " as result %7.2f return(z) _col(59) "{c |} p-value = " as result %7.4f `p' _col(79)"{c |}"				
			noi di in smcl ///
				"{hline 19}{c BT}{hline 23}{c BT}{hline 17}{c BT}{hline 18}{c BRC}"
		}
	}	
}
end

