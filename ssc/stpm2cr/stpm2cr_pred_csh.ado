*! version 2.3 19Nov2018

program stpm2cr_pred_csh, sortpreserve eclass
	version 14.1
	syntax newvarname [if] [in], [CIF Hazard XB DXB ///
									AT(string) CONtrast(string) ///
									REFerence(string) SURVival ///
									CI LEVel(real `c(level)') TIMEvar(varname) STDP CIFRATIO  ///
									Nodes(int 100) quadopt(string) zeros RMLat(numlist >0 integer) GRAPHrml]
									
	local newvarname `varlist'
	local causeNames `e(causeNames)'
	di in red "Note that post-estimation for these models is still in beta"
	ereturn local predict stpm2cr_pred_csh
	
	marksample touse, novarlist
	
	qui count if `touse'
	if r(N)==0 {
		error 2000          /* no observations */
	}
	
	if "`rmlat'" != "" {
		local rmltmp "rmltmp"
	}
	
	if wordcount(`"`cif' `hazard' `xb' `survival' `rmltmp'"') > 1 {
		display as error "You have specified more than one option for predict"
		exit 198
	}
	if "`rml'"!="" & "`rmltime'"=="" {
		di as error "Must specify numlist in rmltime() when using rml option"
		exit 198
	}
	if wordcount(`"`cif' `hazard' `xb' `rmltmp' `survival'"') == 0 {
		display as error "You must specify one of the predict options"
		exit 198
	}
	
	if "`hazard'" != "" | "`xb'" != "" | "`survival'" != "" {
		foreach cause in `causeNames' {
			qui estimates restore `cause'
			local string "`0'"
			gettoken del opts : string, parse(",")
			stpm2_pred `newvarname'_`cause' `opts'
		}
	}
	else {
		if "`timevar'" == "" {
			local timevar _t
		}
		stpm2cifgq `newvarname', timevar(`timevar') at(`at') rmlat(`rmlat') `ci' `graphrml' nodes(`nodes') quadopt(`quadopt') modelnames(`causeNames') `cif'
	}
	
	ereturn local predict stpm2cr_pred_csh
	ereturn local causeNames `causeNames'
	
end

	
	

	
	/*
	
	stpm2cifgq `newvarnames', timevar(`timevar') at(`at') rml(`rmlat') `ci' `graphrml' models(`e(causeNames)')
	
	*/
