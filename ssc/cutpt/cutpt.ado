*! -cutpt- version 1.3	Phil Clayton	2013-04-29

/* -cutpt- estimates the optimal cutpoint for a diagnostic test using the
   method suggested by Liu, Youden, or nearest to (0,1) method:
   
   Liu X. Classification accuracy and cut point selection. Stat Med. 2012 Feb. 3.
   Youden WJ. Index for rating diagnostic tests. Cancer 1950; 3:32-35.
   
   Empirical adjustment of cutpoint for continuous tests recommeded by Fluss:
   Fluss R, Faraggi D, Reiser B. Estimation of the Youden Index and its
     associated cutoff point. Biom J. 2005 Aug;47(4):458Ð72. 
      
   Syntax:
   cutpoint refvar classvar
*/

* version history
* 2013-04-29	v1.3	Support for nearest to (0,1) method
* 2013-04-19	v1.2	Added option for empirical adjustment of cutpoint
*						Youden method now defaults to using adjustment
* 2013-04-18	v1.1	Renamed cutpt
*						Improved speed by avoiding -egen-
*						Check for ties
*						Report Youden's J with standard error
* 2012-04-15	v1.0	Initial version (named cutpoint)

capture program drop cutpt
program define cutpt, sortpreserve
	version 12.1
	syntax varlist(min=2 max=2 numeric) [if] [in] , [liu youden NEARest noADJust]

	* validate input
	marksample touse
	qui count if `touse'
	if r(N)==0 error 2000
	
	tokenize `varlist'
	local refvar="`1'"
	local classvar="`2'"
	capture assert `refvar'==0 | `refvar'==1 if `touse'
	if _rc {
		di as error "Reference variable must be 0 (negative) or 1 (positive)"
		exit 198
	}
	sum `refvar' if `touse', meanonly
	capture assert r(min)==0 & r(max)==1 
	if _rc {
		di as error "Reference variable must contain both positive and negative outcomes"
		exit 198
	}

	* the default method is Liu
	if "`liu'"=="" & "`youden'"=="" & "`nearest'"=="" {
		cutpoint_liu `touse' `refvar' `classvar' `adjust'
	}
	else {
		if "`liu'"=="liu" cutpoint_liu `touse' `refvar' `classvar' `adjust'
		else if "`youden'"=="youden" cutpoint_youden `touse' `refvar' `classvar' `adjust'
		else if "`nearest'"=="nearest" cutpoint_nearest `touse' `refvar' `classvar' `adjust'
	}
end

/* 
   Liu method (the default)
   Essentially this method is to find the cutpoint that maximises the product
   of sensitivity and specificity
*/
capture program drop cutpoint_liu
program define cutpoint_liu
	args touse refvar classvar adjust
	
	tempvar sumpos sumneg czx
	tempname classvar1 cutpoint

	* order by classification variable and determine cumulative number of
	* positive refvars (false negatives) and negative refvars (true negatives)
	sort `touse' `classvar' 
	qui gen double `sumpos'=sum(`refvar') if `touse'
	local totalpos=`sumpos'[_N]
	qui gen double `sumneg'=sum(!`refvar') if `touse'
	local totalneg=`sumneg'[_N]

	* czx is the product of sens and spec for each value of classvar
	qui by `touse' `classvar': gen `czx'= ///
		(`totalpos' - `sumpos') * `sumneg' / ///
		(`totalpos' * `totalneg') if `touse' & _n==_N	

	* find the classvar with the highest czx
	sum `czx', meanonly
	sum `classvar' if `czx'==r(max), meanonly
	
	* check for ties
	capture assert r(min)==r(max)
	if _rc {
		di as error "Ties found - optimal cutpoint can't be determined"
		error 498
	}
	
	* classvar1 is the classvar with highest czx
	scalar `classvar1'=r(mean)
	
	* if the classvar is continuous, we use the adjustment recommended by
	* Fluss et al
	if "`adjust'"=="" {
		* the optimal cutpoint is the mean of the classvar with the highest czx and
		* the following one (ie the one with the next (higher) value of the classvar)

		* there must be at least 2 levels of czx
		qui count if !missing(`czx')
		if r(N)<2 {
			di as error "Not enough levels of `classvar' to determine cutpoint"
			error 498
		}

		sum `classvar' if `classvar'>`classvar1' & `touse', meanonly
		scalar `cutpoint'=(r(min) + `classvar1') / 2
	}
	else {
		* otherwise we simply use the classvar with the highest czx
		scalar `cutpoint'=`classvar1'
	}

	* report results
	cutpoint_report Liu `touse' `refvar' `classvar' `totalpos' `totalneg' `cutpoint'
end

/* 
   Youden method
   This method finds the cutpoint that maximises the sum of sensitivity and specificity
*/
capture program drop cutpoint_youden
program define cutpoint_youden
	args touse refvar classvar adjust
	
	tempvar sumpos sumneg j
	tempname jmax classvar1 cutpoint

	* order by classification variable and determine cumulative number of
	* positive refvars (false negatives) and negative refvars (true negatives)
	sort `touse' `classvar' 
	qui gen double `sumpos'=sum(`refvar') if `touse'
	local totalpos=`sumpos'[_N]
	qui gen double `sumneg'=sum(!`refvar') if `touse'
	local totalneg=`sumneg'[_N]

	* j is the sum of sensitivity and specificity for each value of classvar minus 1
	qui by `touse' `classvar': gen `j'= ///
		((`totalpos' - `sumpos')/`totalpos') + /// sensitivity +
		(`sumneg'/`totalneg') - 1 /// specificity - 1
		if `touse' & _n==_N	

	* find the classvar with the highest j
	sum `j', meanonly
	scalar `jmax'=r(max)
	sum `classvar' if `j'==`jmax', meanonly
	
	* check for ties
	capture assert r(min)==r(max)
	if _rc {
		di as error "Ties found - optimal cutpoint can't be determined"
		error 498
	}
	
	* classvar1 is the classvar with highest j
	scalar `classvar1'=r(mean)
	
	* if the classvar is continuous, we use the adjustment recommended by
	* Fluss et al
	if "`adjust'"=="" {
		* the optimal cutpoint is the mean of the classvar with the highest j and
		* the following one (ie the one with the next (higher) value of the classvar)

		* there must be at least 2 levels of j
		qui count if !missing(`j')
		if r(N)<2 {
			di as error "Not enough levels of `classvar' to determine cutpoint"
			error 498
		}

		sum `classvar' if `classvar'>`classvar1' & `touse', meanonly
		scalar `cutpoint'=(r(min) + `classvar1') / 2
	}
	else {
		* otherwise we simply use the classvar with the highest j
		scalar `cutpoint'=`classvar1'
	}

	* report results
	cutpoint_report Youden `touse' `refvar' `classvar' `totalpos' `totalneg' ///
		`cutpoint'	`jmax'
end


/* 
   Nearest to (0,1)
   This method finds the cutpoint that has a sens & spec closest to the
   top left (0,1) of the ROC space
*/
capture program drop cutpoint_nearest
program define cutpoint_nearest
	args touse refvar classvar adjust
	
	tempvar sumpos sumneg d
	tempname classvar1 cutpoint

	* order by classification variable and determine cumulative number of
	* positive refvars (false negatives) and negative refvars (true negatives)
	sort `touse' `classvar' 
	qui gen double `sumpos'=sum(`refvar') if `touse'
	local totalpos=`sumpos'[_N]
	qui gen double `sumneg'=sum(!`refvar') if `touse'
	local totalneg=`sumneg'[_N]

	* d is the distance from (0,1) each value of classvar
	qui by `touse' `classvar': gen `d'= ///
		sqrt((1 - (`totalpos' - `sumpos')/`totalpos')^2 + /// (1-sensitivity)^2
		(1 - `sumneg'/`totalneg')^2) /// (1-specificity)^2
		if `touse' & _n==_N	

	* find the classvar with the lowest d
	sum `d', meanonly
	sum `classvar' if `d'==r(min), meanonly
	
	* check for ties
	capture assert r(min)==r(max)
	if _rc {
		di as error "Ties found - optimal cutpoint can't be determined"
		error 498
	}
	
	* classvar1 is the classvar with lowest d
	scalar `classvar1'=r(mean)

	* if the classvar is continuous, we use the adjustment recommended by
	* Fluss et al
	if "`adjust'"=="" {
		* the optimal cutpoint is the mean of the classvar with the lowest d and
		* the following one (ie the one with the next (higher) value of the classvar)

		* there must be at least 2 levels of d
		qui count if !missing(`d')
		if r(N)<2 {
			di as error "Not enough levels of `classvar' to determine cutpoint"
			error 498
		}

		sum `classvar' if `classvar'>`classvar1' & `touse', meanonly
		scalar `cutpoint'=(r(min) + `classvar1') / 2
	}
	else {
		* otherwise we simply use the classvar with the lowest d
		scalar `cutpoint'=`classvar1'
	}

	* report results
	cutpoint_report "Nearest to (0,1)" `touse' `refvar' `classvar' ///
		`totalpos' `totalneg' `cutpoint'
end


/* report results */
capture program drop cutpoint_report
program define cutpoint_report, eclass
	args method touse refvar classvar totalpos totalneg cutpoint j
	tempname sej sens spec auc

	* calculate sens, spec and auc at the cutpoint
	qui count if `classvar'>`cutpoint' & `refvar' & `touse'
	local truepos=r(N)
	local falseneg=`totalpos' - `truepos'
	scalar `sens'=`truepos' / `totalpos'
	qui count if `classvar'<=`cutpoint' & !`refvar' & `touse'
	local trueneg=r(N)
	local falsepos=`totalneg' - `trueneg'
	scalar `spec'=`trueneg' / `totalneg'
	scalar `auc'=(`sens' + `spec')/2

	di
	di as result "Empirical cutpoint estimation"
	di as text "Method:" _col(40) as result "`method'"
	di as text "Reference variable:" _col(40) "`refvar' (0=neg, 1=pos)"
	di as text "Classification variable:" _col(40) "`classvar'"

	di as text "Empirical optimal cutpoint:" _col(40) as result `cutpoint'

	* report J with SE if method is Youden
	if "`method'"=="Youden" {
		scalar `sej'=sqrt(`truepos'*`falseneg'/(`totalpos')^3 ///
			+ `falsepos'*`trueneg'/(`totalneg')^3)
		di as text "Youden index (J):" _col(40) as result %04.3f `j'
		di as text "SE(J):" _col(40) as result %05.4f `sej'
	}
			
	di as text "Sensitivity at cutpoint:" _col(40) %03.2f as result `sens'
	di as text "Specificity at cutpoint:" _col(40) %03.2f as result `spec'
	di as text "Area under ROC curve at cutpoint:" _col(40) as result %03.2f `auc'

	ereturn post, esample(`touse')
	if "`method'"=="Youden" {
		ereturn scalar j=`j'
		ereturn scalar sej=`sej'
	}
	ereturn local method="`method'"
	ereturn scalar cutpoint=`cutpoint'
	ereturn scalar sens=`sens'
	ereturn scalar spec=`spec'
	ereturn scalar auc=`auc'
end
