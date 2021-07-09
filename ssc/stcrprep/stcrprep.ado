*! version 1.0.3 25Nov2016
program define stcrprep, rclass
	version 11.2
	syntax [if] [in], EVents(varname) 			///
		[										///
			noSHorten 							///		Do not collapse over equal weights
			KEep(string) 						///		Variables to keep in analysis   
			EPSilon(real 1E-8)					///		Value to add when estimating censoring distribution
			TRans(numlist)						///    	Transitions of interest
			CENSvalue(integer 0)				///		Value to denote censoring
			BYG(varlist)						///		Estimate censoring distribution by varlist
			BYH(varlist)						///		Estimate delayed entry distribution by varlist
			WTSTPM2								/// 	use stpm2 for censoring (and delayed entry)
			CENSCOV(varlist)					///		covariates list for censoring distribution
			CENSDF(string)						///		df for censoring distribution (default(5))
			CENSTVC(varlist)					///		Variables to have time-dependent effects
			CENSTVCDF(string)					///		df for time-dependent effects for censoring distribution
			EVERY(string)						///		width of intervals after competing events (when using stpm2)
		]				
	st_is 2 analysis	

	
	
/* Marksample */	
	marksample touse
	qui replace `touse' = 0  if _st==0

	if `"`_dta[st_id]'"' == "" {
		di as err "stcrprep requires that you have previously stset an id() variable"
		exit 198
	}
 
	cap bysort `_dta[st_id]' : assert _N==1
	if _rc {
		di as err "stcrprep requires that the data are stset with only one observation per individual"
		exit 198
	}  

/* check that events variable corresponds to _d */	
	qui count if _d == 0 & `events' != `censvalue' & `touse'
	if `r(N)'>0 {
		display as error "Events variable (`events') and event indicator (_d) do not match"
		exit 198
	}
	qui count if _d==0 & `touse'
	if `r(N)'==	0 {
		di as error "There are no censored observed"
		exit 198
	}
// delayed entry	
	summ _t0 if `touse', meanonly
	if `r(max)'>0 {
		local delayed_entry 1
	}
	else {
		local delayed_entry 0
	}
// stcrprep's delayed entry implementation is experimental.

	if `delayed_entry' {
		if "`wtstpm2'" != "" {
			di as error "Can not currently use stpm2 to derive weights for left trunctation"
			exit 198
		}
		di as text "stcrprep's delayed entry implementation is experimental"
		di as text "Use with caution."
	}

// check stpm2 options not used with byg or byh options 
	if "`byg'`byh'" != "" {
		foreach opt in wtstpm2 censcov censdf censtvc censtvcdf every {
			if "``opt''" != "" {
				di as error "`opt' option cannot be used with byg option"
				di as error "Use `opt' with the censstpm2 option only"
				exit 198
			}
		}
	}
	preserve	
	tempvar id
	qui gen long `id' = `_dta[st_id]'
	local idname `_dta[st_id]'
	

/* Find number of events */
	qui tab `events'
	local Nevents  = `r(r)' - 1								
	qui levelsof `events', local(eventslist)
	local eventslist: subinstr local eventslist "`censvalue'" "", word

/* Number of transitions */
	if "`trans'" == "" {
		local trans `eventslist'
	}
	local Ntrans: word count `trans'

/*	Use KM weights */	
	if "`wtstpm2'" == "" {

// combine byg byh
		local bygh `byg' `byh'
		local bygh: list uniq bygh

		keep _t _t0 _d _st `id' `idname' `events' `keep' `bygh' `touse'
		qui drop if `touse'==0

		tempfile keepvars
		qui save `keepvars'
	
/* combined G and H groups */
		tempname grpGH
		qui egen `grpGH' = group(`bygh')
		qui levelsof `grpGH'
		local grpGHlevels `r(levels)'
		local nGHgrps: word count `grpGHlevels'	
		qui count if `grpGH' == .
		if `r(N)'>0 {
			display in green "Note droping `r(N)' values due to missing values for variables listed in byg() or byH() option"
			qui drop if `grpGH' == .
		}

/* copies of st variables */
		tempvar _old_t _old_t0 _old_d G dup cens grpG H grpH
		qui gen double `_old_t' = _t
		qui gen double `_old_t0' = _t0							// check needed
		qui gen double `_old_d' = _d			
		qui gen byte `cens' = 1 - _d
	
/* generate G(t) */									
		qui replace _d = 1 - _d									// censoring is now the event
		qui replace _t = cond(_d==0,_t-`epsilon',_t)  			// what if delayed entry? (not currently implemented)
		qui egen `grpG' = group(`byg')
		qui levelsof `grpG'
		local grpGlevels `r(levels)'
		local nGgrps: word count `grpGlevels'	
		if "`byg'" != "" {
			local bygopt by(`grpG')
		}
		qui sts gen `G' = s, `bygopt'

/* generate H(t) */

		if `delayed_entry' {
			summ `_old_t', meanonly
			local max_t `r(max)'
			qui replace _t0 = -`_old_t' + `max_t'
			qui replace _t = -`_old_t0' + `max_t' + `epsilon'
			qui replace _d = 1
			
			qui egen `grpH' = group(`byh')
			qui levelsof `grpH'
			local grpHlevels `r(levels)'
			local nHgrps: word count `grpHlevels'	
			if "`byh'" != "" {
				local byhopt by(`grpH')
			}
			qui sts gen `H' = s, `byhopt'					// add by option?
			tempname t_H
			gen double `t_H' = _t - `max_t' - `epsilon'
			mata H_to_t()
		}
		else {
			gen `H' = 1
		}
		

// use original variables		
		qui replace _t = `_old_t'
		qui replace _t0 = `_old_t0'
		qui replace _d = `_old_d'
		sort _t

/* get unique event times */
		sort _t _d
		qui duplicates tag _t if _d==1, gen(`dup')
		qui bysort `grpGH' _t `events' (_d): replace `dup' = _n==1
		
	
/* Get weights and unique time into mata */	
// !!
// MODIFIED crprep function 
// !! Look for *findexternal("`A'")
		tempname A 
		cap noi {

		mata: crprep(	"`events'", 		///
						"`eventslist'",		///
						"`G'",				///
						"`H'",				///
						"`dup'",			///
						"`grpGH'",			///
						"`grpGHlevels'",	///
						"`A'")

/* expand data dependent on number of selected transitions */
		qui expand `Ntrans', 
		sort `id'
		egen failcode = seq(), from(1) to(`Ntrans') 
		forvalues i = 1/`Ntrans'  {
			qui replace failcode = `= word("`trans'",`i')'  if failcode == `i'
		}	
		tempvar select first otherevent last dropnone tmpselect drop dropall extradropnone
		qui gen double tstart = .
		qui gen double tstop = .
		qui gen double wt_c = .
		qui gen double wt_t = .
		foreach ev in `trans' {
			foreach gr in `grpGHlevels' {
				qui gen `select' = _d==1 & `events' == `ev' & `grpGH' == `gr' & failcode == `ev'
				qui gen `otherevent' = _d==1 & `events' != `ev' & `grpGH' == `gr' & failcode == `ev'
			
				qui count if `select' == 1
				local Nselect `r(N)'
			
/* populate depending on event */
				local tmpevent: subinstr local eventslist "`ev'" "", word
				foreach i in `tmpevent' {
					qui gen `tmpselect' = `otherevent'*(`events' == `i')
					qui count if `tmpselect' == 1
					local Nselect `r(N)'				
					qui expand `expand`ev'`gr'' if `tmpselect',
					sort failcode `grpGH' `idname' (_t)
					mata: st_store(.,("tstop","wt_c","wt_t"	),"`tmpselect'",J(`Nselect',1,asarray(*findexternal("`A'"),(`ev',`gr'))))
					drop `tmpselect'
				}
				
				qui gen `drop' = (tstop<=_t) & `otherevent' 
				qui bysort failcode `grpGH' `idname' (tstop): egen `dropnone' = max(`drop')
				qui replace `dropnone' = 1 - `dropnone'
				qui bysort failcode `grpGH' `idname' (tstop): egen `dropall' = min(`drop')
				qui bysort failcode `grpGH' `idname' (tstop): gen `last' = `dropall' == 1 & _n==_N 
			
				qui drop if `drop' & !`last' 
				qui bysort failcode `grpGH' `idname' (tstop): gen `first' = _n==1 if `otherevent' 

				
/* deal with situation if no censored obs before event */
				qui expand 2 if `first' & `last'==0 & `otherevent', gen(`extradropnone')
				qui replace wt_c = `G' if `extradropnone' & `otherevent'
				qui replace wt_t = `H' if `extradropnone' & `otherevent'
				qui replace tstop = _t if `extradropnone'
			
				summ _t if `otherevent', meanonly
		
				qui bysort failcode `grpGH' `idname' (tstop): replace `first' = _n==1 if `otherevent'
				qui replace tstop = _t if !`otherevent' & failcode == `ev' & `grpGH'==`gr'
				qui replace wt_c = 1 if !`otherevent' & failcode == `ev' & `grpGH'==`gr'
				qui replace wt_t = 1 if !`otherevent' & failcode == `ev' & `grpGH'==`gr'
				qui replace tstart = _t0 if !`otherevent' & failcode == `ev' & `grpGH'==`gr'
				qui replace tstart = _t0 if `otherevent' & `first'
				qui replace tstop = _t if `first' & `otherevent'
				qui bysort failcode `grpGH' `idname' (tstop): replace tstart = tstop[_n-1] if `otherevent' & !`first' 
				sort failcode `idname' (tstop)
				
				drop `select' `first' `otherevent' `dropnone' `dropall' `extradropnone' `last' `drop'
			}
		}	
		}
		local rc = _rc
		mata: rmexternal("`A'")	
		if `rc' {
			exit `rc'
		}
		bys failcode `idname' (tstop): gen double weight_c = wt_c/wt_c[1]	// generate G weights
		bys failcode `idname' (tstop): gen double weight_t = wt_t/wt_t[1]	// generate H weights
		drop _t _t0 _d _st wt_c wt_t
/* collapse over the same weights */	
		if "`shorten'" == "" {
/* keep same variable labels */	
			foreach v of varlist `keep' `events' {
				local labvar_`v' : variable label `v'
				local labval_`v' : value label `v'
			}
			tempvar firstobs									// do not collapse first obs
			bys failcode `idname' (tstop): gen `firstobs' = _n==1
			collapse (first) tstart `events' `keep'  (last)  tstop, by(failcode `idname' weight_c weight_t `firstobs')
/* restore variable labels */
			foreach v of varlist `keep' `events' * {
				label variable `v' "`labvar_`v''"
				if "`labval_`v''" != "" {
					label values `v' "`labval_`v''"
				}
			}
		}
		restore, not
		if "`labval_`events''" != "" {
			label values failcode "`labval_`events''"
		}
		sort failcode `idname' tstop
	}
*******************
/* stpm2 weights */
*******************
	else {
		local censvars `censcov' `censtvc'
		local censvars: list uniq censvars	
		keep _t _t0 _d _st `id' `idname' `events' `keep' `censvars' `touse'
		qui drop if `touse'==0

		tempfile keepvars
		qui save `keepvars'	
	
		if "`censdf'" != "" {
			confirm number `censdf'
		}
		else {
			local censdf 4
		}
		if "`every'" == "" {
			display as error "The every() option is compulsory when using the wtstpm2 option".
			exit 198
		}
		if "`every'" != "" {
			confirm number `every'
		}

		
/* Check stpm2 is installed */
        capture which stpm2
        if _rc >0 {
                display in yellow "You need to install the command stpm2. This can be installed using,"
                display in yellow ". {stata ssc install stpm2}"
                exit  198
        }

	
/* censoring distribution prediction */
		tempname grp _old_t _old_d
		qui gen double `_old_t' = _t
		qui gen `_old_d' = _d
		qui replace _d = 1 - _d
		
		if "`censcov'`censtvc'" != "" {
			tempvar missflag
			gen byte `missflag' = 0
			foreach var in `censcov' `tvc' {
				qui replace `missflag' = 1 if missing(`var')
			}
			qui count if `missflag' == 1 
			if `r(N)' >0 {
				display as text "Note dropping `r(N)' observations due to missing values for variables in censcov/censtvc options"
				qui drop if `missflag' == 1
			}
		}
		if "`censtvc'" != ""  {
			local tvcopt tvc(`censtvc') dftvc(`censtvcdf')
		}
		
		// exclude administrative censoring towards end (probably better way to do this)
		summ _t if _d == 1, meanonly
		local tmax `r(max)'
		qui replace _d = 0 if _t==`r(max)'		
		
		tempname stpm2cens_mod
		qui stpm2 `censcov', scale(hazard) df(`censdf') `tvcopt' failconvlininit 		
		estimates store `stpm2cens_mod'
		local bhknots `e(ln_bhknots)'
		local Nparams `e(rank)'
		tempname Rmatbh b
		matrix `Rmatbh' = e(R_bh)

		matrix `b' = e(b)
		matrix `b' = `b'[1,1..`Nparams']
		
		qui replace _d = `_old_d'
		qui replace _t = `_old_t'

/* expand depending on number of transitions */
		qui expand `Ntrans'
		bysort `id': gen failcode = _n
		forvalues i = 1/`Ntrans' {
			local tmptrans: word `i' of `trans'
			qui replace failcode = `tmptrans' if failcode==`i'
		}

		qui gen double tstop = .
		qui gen double tstart = .
		qui gen double wt = .

/* loop over transitions */
		tempvar tmpt sptime otherevent lnt lnchwt _old_t tmpwt
		qui gen double `_old_t' = _t
		foreach tr in `trans' {
	
/* gen t* for those with competing event */
			qui gen `tmpt' = cond(`events' != `tr' & `events' != `censvalue',`tmax',`_old_t') if failcode == `tr'

			qui stset `tmpt' if failcode == `tr', failure(`events' == `tr') id(`id')
			qui gen `otherevent' = `events' != `tr' & `events' != `censvalue' & failcode == `tr'
			
			qui stsplit `sptime' if `otherevent' & failcode == `tr', after(time = asis(`_old_t')) every(`every') 
			qui drop if failcode == `tr' & `sptime' < (`=0-`every'-0.000001')
			qui bys failcode `id' (_t): replace _t0 = 0 if _n==1 			// change for delayed entry

			qui bys failcode `id' (_t): gen tpred = cond(_n==1,_t,(_t0+_t)/2)
			qui predict `tmpwt' if failcode == `tr' & `otherevent', survival timevar(tpred)
			drop tpred

			qui replace wt =  cond(failcode == `tr' & `otherevent',`tmpwt',1) if failcode == `tr'
			qui replace tstart = _t0 if failcode == `tr'  
			sort `failcode' `id' (_t)
			qui replace tstop = _t if failcode == `tr'  
		
			capture drop `otherevent' `tmpwt' `sptime' `tmpt'
		}
		capture drop __tmprcs*		
		qui bys failcode `idname' (tstop):  gen weight_c = wt/wt[1]

		keep `idname' `events' tstart tstop wt weight_c failcode `keep'
		tempvar tmpevents	
		bysort `idname' (tstop): egen `tmpevents' = max(`events')
		qui replace `events' = `tmpevents'		
		restore, not
		if "`labval_`events''" != "" {
			label values failcode "`labval_`events''"
		}
		sort failcode `idname' tstop
	}
end

/* crprep function */
/* Forms matrix for each event (and group) 
	- first column the time of unique events
	- second column the KM estimate of the censoring distibution
	- second third column the KM estimate of the entry time distibution
*/
mata:
 function crprep(	string scalar eventsname,				// name of events variable
					string scalar eventslist,				// list of possible events (failcode)
					string scalar Gname,					// name of G function variable
					string scalar Hname,					// name of H function variable
					string scalar dupname,					// name of duplicates variable
					string scalar grpname,					// name of group variable
					string scalar grplistname,				// name of group levels
					string scalar aname
) 
{
	pointer() scalar A 
	eventslist = strtoreal(tokens(eventslist))
	events = st_data(.,eventsname)
	t = st_data(.,"_t")
	t0 = st_data(.,"_t0")
	d = st_data(.,"_d")
	G = st_data(.,Gname)
	H = st_data(.,Hname)
	dup = st_data(.,dupname)
	grp = st_data(.,grpname)
	grplist = strtoreal(tokens(grplistname))
	ngrps = cols(grplist)
	A = crexternal(aname)
	*A = asarray_create("real",2)
	
	for(i=1;i<=cols(eventslist);i++) {
		for(j=1;j<=ngrps;j++) {
			asarray(*A,(eventslist[1,i],j),sort(select((t,G,H),(events :== eventslist[1,i]) 
														:& (d:==1) :& (dup:==1) :& (grp :== j)),1))
			st_local("expand"+strofreal(eventslist[1,i])+strofreal(j),strofreal(rows(asarray(*A,(eventslist[1,i],j)))))			
		}
	}

}

void function H_to_t()
{
	t = st_data(.,st_local("_old_t")) 	// original time scale
	grp = st_data(.,st_local("grpH"))  // 
	P = sort(uniqrows(st_data(.,(st_local("t_H"),st_local("H"),st_local("grpH")))),(3,1))		// (t_H,H,grp)
	ngrps = strtoreal(st_local("nHgrps"))
	
	t_H = J(0,1,.)
	H = J(0,1,.)
	for(j=1;j<=ngrps;j++) {
		t_H = t_H\revorder(-select(P[,1],P[,3]:==j))
		H = H\revorder(select(P[1::(rows(t_H)-1),2],P[1::(rows(t_H)-1),3]:==j)) \ 1
	}
	H_grp = P[,3]
	N = rows(t)
	newH = J(N,1,.)
	for(i=1;i<=N;i++) {
		d =  t[i] :- select(t_H,H_grp :== grp[i]) 
		d = (d:<0):*999999 :+ (d:>=0):*d
	
		minindex(d,1,j=.,w=.)
		if(rows(j) > 1) newH[i] = 1
		else newH[i] = select(H,H_grp :== grp[i])[j]
	}
	st_store(.,st_local("H"),.,newH)
}
end

