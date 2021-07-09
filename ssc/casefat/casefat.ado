*! version 3  7may2009
program define casefat, rclass
	
/* last updated 7th May 2009 */
	
version 8.2

syntax [if] [in] , dead(varname numeric) rec(varname numeric) t(varname numeric) [ origin(varname numeric)  cens(numlist max=1)  gen(string) replace greenwood untrans ] 

	/********************************************************************
	*********************************************************************
	*	Casefat estimates the case fatality ratio (CFR) using			*
	*	incomplete data such as would be available part-way 			*
	*	through an epidemic.											*
	*	A Kaplan-Meier-like estimate is used, with two naive			*
	*	estimates also calculated for comparison.						*
	*																	*
	*********************************************************************
	********************************************************************/

quietly{
	
	tempvar sort
	gen `sort'=_n
	sort `sort'
	
	preserve
	marksample touse
	keep if `touse'
	
	tempvar  groupdead grouprec groupevent sdead srec ndead nrec hdead hrec seTHETA varTHETA /*
		  */ THETA thsumdead thsumrec Adead Arec d devent
	tempname T J OM V hvdead hvrec Bdead Brec cov01
	
	
	/****************************************************************************/
	/****************************************************************************/
	/* censor the data at the specified time, if necessary */
	if "`cens'"~=""{
		if "`origin'"==""{
			n di as error "Censoring time only makes sense if calendar time is used, i.e. if origin() is specified"
			exit	
		}
		foreach endp in dead rec{
			replace ``endp''=0 if `t'>`cens'
		}
		replace `t'=`cens' if `t'>`cens'
	}
	if "`origin'"==""{
		tempvar origin
		gen `origin'=0
	}
	count if `dead'==1&`rec'==1
	if r(N)>0{
		n di as error "Cannot have both `dead'=1 and `rec'=1 for an observation"
		exit
	}
	
	/****************************************************************************/
	/****************************************************************************/
	/*  THETA calculated using composite endpoint */
	gen byte `d'=0
	replace `d'=1 if `dead'==1|`rec'==1
	stset `t', failure(`d') origin(time `origin')
	sts gen `THETA'=s
	sts gen `devent'=d
	sort _t `sort'
	egen `groupevent'=group(_t) if `devent'~=.&_t~=_t[_n-1]
	if "`greenwood'"~=""{
		sts gen `seTHETA'=se(s)
		gen `varTHETA'=(`seTHETA')^2
	}
	/****************************************************************************/
	/****************************************************************************/
	/* for each outcome considered separately, hazard contributions, 
		numbers at risk at each time point */
	foreach endp in dead rec{
		stset `t' , failure(``endp''=1) origin(time `origin')
		stdes
		local N`endp'=r(N_fail)
		if "`endp'"=="dead"{
			local Ntot=r(N_sub)
		}
		foreach p in n h {
			sts gen ``p'`endp''=`p'
		}
		replace `h`endp''=0 if `h`endp''==.&`devent'~=.
		replace `n`endp''=1 if `n`endp''==.&`devent'~=.
	}
	/****************************************************************************/
	/****************************************************************************/
	/* effective sample size, nstar */
	local Nevent=`Ndead'+`Nrec'
	local nstar=(`Ntot'+`Nevent')/2
	/****************************************************************************/
	/****************************************************************************/
	/* find theta for death and recovery, 
		estimated lower bounds for the probabilities that each outcome occurs */
	
	sort `groupevent'
	foreach endp in rec dead{
		gen `thsum`endp''=.
		replace `thsum`endp''=`h`endp'' if `groupevent'~=. in 1
		replace `thsum`endp''=`h`endp''*`THETA'[_n-1]  if `groupevent'~=.&_n>1
		replace `thsum`endp''=`thsum`endp''+`thsum`endp''[_n-1] if  `groupevent'~=.&_n>1
		su `thsum`endp'', meanonly
		local theta`endp'=r(max)
	} 
	
	local cfr=`thetadead'/(`thetadead'+`thetarec')
	
	/****************************************************************************/
	/****************************************************************************/
	/* standard error for CFR */
	sort `groupevent'
	count if `groupevent'~=.
	local nev=r(N)
	if c(matsize)<`nev'{
		if c(max_matsize)>=`nev'{
			set matsize `nev'
		}
		else{
			n di as error "Maximum permitted matsize is less than `nev', the number of distinct death or recovery times"
			exit
		}
	}
	
	if "`greenwood'"==""{
		mkmat `THETA' if `groupevent'~=. , matrix(`T') nomissing
		matrix `J'=J(`nev',1,1)
		matrix `OM'=`T'*(`J'-`T')'/`nstar'
		forval k=1/`nev'{
			local k1=`k'+1
			forval j=`k1'/`nev'{
				matrix `OM'[`k', `j']=`OM'[`j', `k']
			}
		}
	}
	else{
		mkmat `varTHETA' if `groupevent'~=. , matrix(`V') nomissing
		matrix `OM'=diag(`V')
		forval j=1/`nev'{
			local j1=`j'-1
			forval k=1/`j1'{
				matrix `OM'[`j', `k']=`varTHETA'[`k']*`THETA'[`j']/`THETA'[`k']
				matrix `OM'[`k', `j']=`varTHETA'[`k']*`THETA'[`j']/`THETA'[`k']
			}
		}
	}
	
	foreach endp in dead rec{
		mkmat `h`endp'' if `groupevent'~=., matrix(`hv`endp'') nomissing 
		matrix `B`endp''=`hv`endp'''*`OM'*`hv`endp''
		local b`endp'=`B`endp''[1, 1]
		
		gen `A`endp''=(`THETA')^2*`h`endp''/`n`endp'' if `groupevent'~=.
		su `A`endp'' , meanonly
		local var`endp'=r(sum)+`b`endp''
	}
	
	matrix `cov01'=`hvdead''*`OM'*`hvrec'
	local cov01=`cov01'[1,1]
	local varcfr=((`thetarec')^2*`vardead'+(`thetadead')^2*`varrec'-2*`thetadead'*`thetarec'*`cov01')/*
	 */ /(`thetadead'+`thetarec')^4
	local secfr=sqrt(`varcfr')
	
	if "`untrans'"~=""{
		local lcfr=`cfr'-1.96*`secfr'
		local ucfr=`cfr'+1.96*`secfr'
	}
	else{
		local logit=logit(`cfr')
		local varlogit=`vardead'/(`thetadead')^2+`varrec'/(`thetarec')^2-2*`cov01'/(`thetadead'*`thetarec')
		local selogit=sqrt(`varlogit')
		local llogit=`logit'-1.96*`selogit'
		local ulogit=`logit'+1.96*`selogit'
		local lcfr=invlogit(`llogit')
		local ucfr=invlogit(`ulogit')
	}
	/****************************************************************************/
	/****************************************************************************/
	/* two simpler CFR estimates  */
	
	cii `Ntot' `Ndead', jeffreys
	local e1=r(mean)
	local see1=r(se)
	local le1=r(lb)
	local ue1=r(ub)
	
	cii `Nevent' `Ndead', jeffreys 
	local e2=r(mean)
	local see2=r(se)
	local le2=r(lb)
	local ue2=r(ub)
	/****************************************************************************/
	/****************************************************************************/
	/* put results in r( )  */
	return scalar N_rec=`Nrec'
	return scalar N_dead=`Ndead'
	return scalar N_event=`Nevent'
	return scalar N_tot=`Ntot'
	return scalar N_cens=`Ntot'-`Nevent'
	
	if "`cens'"~=""{
		return scalar cens=`cens'
	}
	else{
		return scalar cens=.
	}
	
	return scalar ub_e2=`ue2'
	return scalar lb_e2=`le2'
	return scalar se_e2=`see2'
	return scalar e2=`e2'
	
	return scalar ub_e1=`ue1'
	return scalar lb_e1=`le1'
	return scalar se_e1=`see1'
	return scalar e1=`e1'
	
	return scalar ub_cfr=`ucfr'
	return scalar lb_cfr=`lcfr'
	return scalar se_cfr=`secfr'
	return scalar cfr=`cfr'
	
	return scalar theta1=`thetarec'
	return scalar theta0=`thetadead'
	
	/****************************************************************************/
	/****************************************************************************/
	/* display results  */
	n di as text _n _col(4) "Cases" _c
	n di as result _col(15) %8.0f return(N_tot) 
	n di as text  _col(4) "Died" _c
	n di as result _col(15)  %8.0f return(N_dead)
	n di as text  _col(4) "Recovered" _c
	n di as result _col(15)  %8.0f return(N_rec)
	n di as text  _col(4) "Censored" _c
	n di as result _col(15)  %8.0f return(N_cens)
	if "`cens'"~=""{
		n di as text  _n(1) _col(4) "Censoring time" 
		n di as result _col(4) "`t' = `cens'" 
	}
	
	n di as text _n(1) _col(2) "Estimates of case fatality ratio (CFR)" _n(1)
	n di as text _col(2) "Method" _col(14) "CFR" _col(27) "Std err" _col(42) "95% CI"
	
	n di as text _col(2) "{hline 56}"
	n di as text _col(2) "KM-like" _c
	n di as result _col(14)  %-8.5f return(cfr), _col(27) %-8.5f return(se_cfr), _col(42) %-8.5f return(lb_cfr),  %-8.5f return(ub_cfr)
	n di as text _col(2) "Simple 1" _c
	n di as result _col(14)  %-8.5f return(e1), _col(27) %-8.5f return(se_e1), _col(42) %-8.5f return(lb_e1),  %-8.5f return(ub_e1)
	n di as text _col(2) "Simple 2" _c
	n di as result _col(14)  %-8.5f return(e2), _col(27) %-8.5f return(se_e2), _col(42) %-8.5f return(lb_e2),  %-8.5f return(ub_e2)
	
	n di as text _n(1) _col(2) "Estimated lower and upper bounds for CFR" 
	n di as text _col(2) "{hline 40}"
	n di as text  _col(2) "Lower bound, theta0 = " _col(27) _c
	n di as result %-8.5f return(theta0) 
	n di as text  _col(2) "Upper bound, 1-theta1 = " _col(27) _c
	n di as result %-8.5f 1-return(theta1) 
	
	/****************************************************************************/
	/****************************************************************************/
	/* restore original dataset, with new variables added if requested  */
	if "`gen'"~=""{
		tempfile tempgen
		if "`replace'"~=""{
			capture drop `gen'time
			capture drop `gen'0
			capture drop `gen'1
		}
		rename _t `gen'time
		gen `gen'0=`thsumdead'
		gen `gen'1=`thsumrec'
		label var `gen'time "Time at risk of death or recovery"
		label var `gen'0 "Theta0"
		label var `gen'1 "Theta1"
		keep `gen'time `gen'0 `gen'1 `sort'
		sort `sort'
		save `tempgen'
	}
	
	restore
	
	if "`gen'"~=""{
		if "`replace'"~=""{
			capture drop `gen'time
			capture drop `gen'0
			capture drop `gen'1
		}
		capture confirm var _merge
		if _rc==0{
			local imerge=1
			tempname merge
			rename _merge `merge'
		}
		else{
			local imerge=0
		}
		capture drop _merge
		merge `sort' using `tempgen' 
		drop `sort' _merge
		if `imerge'==1{
			rename `merge' _merge
		}
	}

} /* end of quietly */

end

