*! rollreg  1.0.8  05mar2005 CFBaum
* based on ssc routine rollreg for RATS (van Norden)
* 1.0.1: implement move option, handle noconstant option
* 1.0.2: implement robust and HAC options, latter using ivreg2 bw() and kernel() 
*        since newey does not provide r^2 nor RMSE. Also graph(summary) v (full).
* 1.0.3: NJC assistance with formatting
* 1.0.4: add constant regression results to graph output, enable onepanel
* 1.0.5: allow mult panels, relocate const regr to subprogram
* 1.0.6: use c_local to simplify code
* 1.0.7: check for existence ivreg2 if needed
* 1.0.8: correct alignment of first regression run 

capt program drop rollreg
program rollreg, rclass
	version 8.2

	syntax varlist(ts min=2) [if] [in],  STUB(string) /// 
	[ ADD(integer -1) DROPfirst(integer -1) MOVE(integer -1) ///
	ROBust BW(integer 1) Kernel(string) NOCONStant Graph(string) SUPER ]

	* validate add / drop / move options:
	*
	* add       : run regression with first "add" observations, enlarge sample until complete
	* dropfirst : run regression over full sample, then drop obs until first "drop" obs are omitted
	* move      : run regression with "move" observations, roll that forward through sample

	* check for options	
	if `add'+`dropfirst'+`move' == -3 {
		di as err _n "must specify add(), dropfirst() or move() options"
		exit 198
	}
	
	local oo 0
	foreach o in add dropfirst move {
		if ``o'' == -1 local ++oo
	}
	
	if `oo' != 2 {
		di as err _n "must specify only one of options add(), dropfirst(), move()"
		exit 198
	}
	
	if "`bw'" != "" {
		capt which ivreg2
		if _rc==111 {
			di as err _n "Error: you must have ivreg2 installed to use the bw() option."
			di as err    "Please ssc install ivreg2."
			exit 198
			}
		}
		
	if "`graph'" != "" & "`graph'" != "summary" & "`graph'" != "full" {
		di as err _n "graph() must be summary or full"
		exit 198
	}
		
* select data to use 
	marksample touse
	qui tsset
	local by `r(panelvar)'
	local timevar `r(timevar)'
    markout `touse' `timevar'
    tsreport if `touse', report list panel
    if r(N_gaps) {
    	di as err "sample may not contain gaps"
    	exit 198 
    }
* check for multiple panels in defined sample; if onepanel, turn off by
    capt _ts tv pv if `touse', onepanel
    if _rc==0 local by ""
    
    if "`by'" != "" & "`graph'" ~= "" {
    	di _n "Note: graphs not available in panel data" _n
    	}
        
    qui count if `touse'
	if r(N) == 0 error 2000
	local fullsample = r(N)
	
	tempvar obsno
	g long `obsno' = _n
		
* generate SE prefix from robust, bw(), [kernel()] options
	local estrtn "regress"
	if "`robust'" != "" local seprefix "_Rob"
		
	if `bw' > 1 {
		if "`robust'" != "" local seprefix "_HAC"
		else local seprefix = "_AC"
		
		local estrtn "ivreg2"
		local robust "`robust' bw(`bw')"
		if "`kernel'" != "" local robust "`robust' kernel(`kernel')"
	}
		
* validate each new varname defined by stub()
	local k: word count `varlist'
	local varlist2: subinstr local varlist "." "_", all
	local depvar: word 1 of `varlist'
	
	qui forval i = 2/`k' {
		local v: word `i' of `varlist2'
		local vr: word `i' of `varlist'
		confirm new var `stub'_`v'
		confirm new var `stub'`seprefix'_se_`v'
		gen `stub'_`v' = .
		gen `stub'`seprefix'_se_`v' = .
		local reglist "`reglist' `vr'"
		local reglist2 "`reglist2' `v'"
	}
	
	qui if "`noconstant'" == "" {
		confirm new var `stub'_cons
		confirm new var `stub'`seprefix'_se_cons
		gen `stub'_cons = .
		gen `stub'`seprefix'_se_cons = .
	}
	
	qui { 
		confirm new var `stub'_r2
		gen `stub'_r2 = .
		confirm new var `stub'_RMSE
		gen `stub'_RMSE = .
		confirm new var `stub'_N
		gen `stub'_N = .
	} 	
	
	qui if "`graph'" != "" {
		tempvar tcrit lb ub
		local level2 = (100-$S_level)/200
		local ci "$S_level% CI"
		g `lb' = .
		g `ub' = .
	}

* Logic for single timeseries
if "`by'" == "" {
* ADD
	if `add' != -1 {
		if `add' <= `k' {
			di as err "add must be > `k'"
			exit 198
		}
		su `obsno' if `touse', meanonly 
		local f = r(min)
		local T = r(max)
* 5303
		local l = `f' + `add' -1
		local f0 = `l'
		local l0 = `T'
		if `l' > `T' {
			di as err "add of `add' too large"
			exit 198
		}
		if "`graph'" != "" & "`by'" == "" {		
			_estcons `depvar', estrtn(`estrtn') reglist(`reglist') touse(`touse') ///
				noconstant(`noconstant') robust(`robust') level2(`level2') reglist2(`reglist2')
		}
		local chosen ADD
		local arg `add'
		label var `timevar' "Last obs. of sample"
		_estroll `depvar', 	estrtn(`estrtn') reglist(`reglist') ///
			noconstant(`noconstant') robust(`robust') reglist2(`reglist2') ///
			stub(`stub') seprefix(`seprefix') lower(`l') upper(`T') chosen(`chosen') in1(`f') in2(0)
		}
* DROPFIRST
	if `dropfirst' != -1 {
		if `dropfirst' <= 0 {
			di as err "dropfirst must be > 0"
			exit 198
		}
		su `obsno' if `touse', meanonly 
		local f = r(min)
		local f0 = `f'
		local T = r(max)
		if	`dropfirst' > `T'-`f' {
			di as err "dropfirst of `dropfirst' too large"
			exit 198
		}
		if "`graph'" != "" & "`by'" == "" {		
			_estcons `depvar', estrtn(`estrtn') reglist(`reglist') touse(`touse') ///
				noconstant(`noconstant') robust(`robust') level2(`level2') reglist2(`reglist2')
		}
		local chosen DROPFIRST
		local arg `dropfirst'
		label var `timevar' "First obs. of sample"
		local lf = `dropfirst'+`f'
		local l0 = `lf'
		_estroll `depvar', 	estrtn(`estrtn') reglist(`reglist') ///
			noconstant(`noconstant') robust(`robust') reglist2(`reglist2') ///
			stub(`stub') seprefix(`seprefix') lower(`f') upper(`lf') chosen(`chosen') in1(first) in2(`T')
		}
		
* MOVE
	if `move' != -1 {
		if `move' <= `k' {
			di as err "move must be > `k'"
			exit 198
		}
		su `obsno' if `touse', meanonly
		local f = r(min)
		local T = r(max)
* 5303
		local l = `f'+`move'-1
		local f0 = `l'
		local l0 = `T'
		if	`l' > `T' {
			di as err "move of `move' too large"
			exit 198
		}
		if "`graph'" != "" & "`by'" == "" {		
			_estcons `depvar', estrtn(`estrtn') reglist(`reglist') touse(`touse') ///
				noconstant(`noconstant') robust(`robust') level2(`level2') reglist2(`reglist2')
		}
		local chosen MOVE
		local arg `move'
		label var `timevar' "Last obs. of sample"		
		_estroll `depvar', 	estrtn(`estrtn') reglist(`reglist') ///
			noconstant(`noconstant') robust(`robust') reglist2(`reglist2') ///
			stub(`stub') seprefix(`seprefix') lower(`l') upper(`T') chosen(`chosen') in1(`f') in2(`move')
		}
* graph option: only feasible for single timeseries or onepanel
	if "`graph'" != "" & "`by'" == "" {
		if "`super'" != "" label var `stub'_r2 "R{c 178}"
		else label var `stub'_r2 "R-squared"
		label var `stub'_RMSE "RMSE"
		tsline `stub'_RMSE in `f0'/`l0', nodraw yline(`crmse') ti("Rolling regression RMSE (Full-sample value displayed)") name(rmse,replace) 
		if "`super'" != "" tsline `stub'_r2 in `f0'/`l0', nodraw yline(`cr2') ti("Rolling regression R{c 178} (Full-sample value displayed)") name(r2,replace)
		else tsline `stub'_r2 in `f0'/`l0', nodraw yline(`cr2') ti("Rolling regression R-squared (Full-sample value displayed)") name(r2,replace)
		qui graph combine rmse r2, col(1) ti("Option : `chosen'(`arg') for `depvar'") subti("regressed on: `reglist'") saving(`stub'_summ, replace)
		di _n "Summary graph saved as `stub'_summ.gph"
	}	
	
	if "`graph'" == "full" & "`by'" == "" {
		qui gen `tcrit' = invttail(`stub'_N,`level2')
		foreach v of local reglist2 {
			qui replace `lb' = `stub'_`v' - `tcrit'*`stub'`seprefix'_se_`v'
			qui replace `ub' = `stub'_`v' + `tcrit'*`stub'`seprefix'_se_`v'
			label var `lb' " "
			label var `ub' " "
			tsline `lb'	`stub'_`v' `ub' in `f0'/`l0', nodraw clp(shortdash_dot solid shortdash_dot) ///
			yline(`cb_`v'') yline(`cb_`v'_ll' `cb_`v'_ul', lp(dash_dot)) ///
			ti("Coefficient on `v' (`ci')") t1("vs full-sample estimate") legend(off) name(`stub'_`v',replace)		
			local allcoef "`allcoef' `stub'_`v'"
		}		
		qui graph combine `allcoef', iscale(0.5) ti("Rolling regression estimates for `depvar'") saving(`stub'_coeff,replace) 
		di _n "Coefficient graph saved as `stub'_coeff.gph"
	}
* End of single timeseries logic
} 
else {
* Logic for multiple panels
	tempvar group thisgp touse2
	qui g `touse2' = .
	qui g `thisgp' = .
	qui egen `group' = group(`by') if `touse'
	su `group', meanonly
	local max = `r(max)'
	forv iii = 1 / `max' {
		qui replace `touse2' = `touse'
		qui replace `thisgp' = 1 if `group' == `iii'
* Identify the chosen subsample
		markout `touse' `thisgp'
* ADD
	if `add' != -1 {
		if `add' <= `k' {
			di as err "add must be > `k'"
			exit 198
		}
		su `obsno' if `touse', meanonly 
		local f = r(min)
		local T = r(max)
* 5303
		local l = `f' + `add' -1
		local f0 = `l'
		local l0 = `T'
		if `l' > `T' {
			di as err "add of `add' too large"
			exit 198
		}
		if "`graph'" != "" & "`by'" == "" {		
			_estcons `depvar', estrtn(`estrtn') reglist(`reglist') touse(`touse') ///
				noconstant(`noconstant') robust(`robust') level2(`level2') reglist2(`reglist2')
		}
		local chosen ADD
		local arg `add'
		label var `timevar' "Last obs. of sample"
		_estroll `depvar', 	estrtn(`estrtn') reglist(`reglist') ///
			noconstant(`noconstant') robust(`robust') reglist2(`reglist2') ///
			stub(`stub') seprefix(`seprefix') lower(`l') upper(`T') chosen(`chosen') in1(`f') in2(last)
		}
* DROPFIRST
	if `dropfirst' != -1 {
		if `dropfirst' <= 0 {
			di as err "dropfirst must be > 0"
			exit 198
		}
		su `obsno' if `touse', meanonly 
		local f = r(min)
		local f0 = `f'
		local T = r(max)
		if	`dropfirst' > `T'-`f' {
			di as err "dropfirst of `dropfirst' too large"
			exit 198
		}
		if "`graph'" != "" & "`by'" == "" {		
			_estcons `depvar', estrtn(`estrtn') reglist(`reglist') touse(`touse') ///
				noconstant(`noconstant') robust(`robust') level2(`level2') reglist2(`reglist2')
		}
		local chosen DROPFIRST
		local arg `dropfirst'
		label var `timevar' "First obs. of sample"
		local lf = `dropfirst'+`f'
		local l0 = `lf'
		_estroll `depvar', 	estrtn(`estrtn') reglist(`reglist') ///
			noconstant(`noconstant') robust(`robust') reglist2(`reglist2') ///
			stub(`stub') seprefix(`seprefix') lower(`f') upper(`lf') chosen(`chosen') in1(first) in2(`T')
		}
* MOVE
	if `move' != -1 {
		if `move' <= `k' {
			di as err "move must be > `k'"
			exit 198
		}
		su `obsno' if `touse', meanonly 
		local f = r(min)
		local T = r(max)
* 5303
		local l = `f'+`move'-1
		local f0 = `l'
		local l0 = `T'
		if	`l' > `T' {
			di as err "move of `move' too large"
			exit 198
		}
		if "`graph'" != "" & "`by'" == "" {		
			_estcons `depvar', estrtn(`estrtn') reglist(`reglist') touse(`touse') ///
				noconstant(`noconstant') robust(`robust') level2(`level2') reglist2(`reglist2')
		}
		local chosen MOVE
		local arg `move'
		label var `timevar' "Last obs. of sample"		
		_estroll `depvar', 	estrtn(`estrtn') reglist(`reglist') ///
			noconstant(`noconstant') robust(`robust') reglist2(`reglist2') ///
			stub(`stub') seprefix(`seprefix') lower(`l') upper(`T') chosen(`chosen') in1(`f') in2(`move')
		}
		
* Restore the full sample
		qui replace `touse' = `touse2'
		qui replace `thisgp' = .
	}
* End of multiple panels logic
}
	return scalar N = `fullsample'
	return local rolloption `chosen'
	return local rollobs `arg'	
	return local stub `stub'
	return local depvar `depvar'
	return local reglist `reglist'
	if "`seprefix'" == "" {
		return local Vtype OLS
	} 
	else {
		return local Vtype `seprefix'
	}
	if "`graph'" != ""  & "`by'" == "" {
		return local eroutine `estrtn'
		return scalar c_rmse = `crmse'
		return scalar c_r2 = `cr2'
	}
end

program _estcons, rclass
	version 8.2
	syntax varlist(max=1 ts), ESTrtn(string) REGLIST(string) Touse(string) [Noconstant(string)  ///
		ROBust(string)] Level2(string) REGLIST2(string)
		
			local depvar `varlist'
			qui `estrtn' `depvar' `reglist' if `touse', `noconstant' `robust'
			c_local cr2 `e(r2)'
			c_local crmse `e(rmse)'
			local tt = invttail(e(N),`level2')
			if "`noconstant'" == "" {
				local ccons = _b[_cons]
				c_local ccons `ccons'
				}
			local i 1
			foreach v of local reglist2	{
				local vr: word `i' of `reglist'
				local cb_`v' = _b[`vr']
				c_local cb_`v' `cb_`v''
				local cb_`v'_ll = _b[`vr'] - `tt' * _se[`vr'] 
				c_local cb_`v'_ll `cb_`v'_ll'
				local cb_`v'_ul = _b[`vr'] + `tt' * _se[`vr']
				c_local cb_`v'_ul `cb_`v'_ul'
				local ++i
				}
end

program _estroll, rclass
	version 8.2
	syntax varlist(max=1 ts), ESTrtn(string) REGLIST(string) [Noconstant(string)  ///
		ROBust(string)] STUB(string) [SEPrefix(string)] REGLIST2(string) LOWer(string) ///
		UPPer(string) CHOSEN(string) IN1(string) IN2(string)

		local depvar `varlist'
		local f `in1'
		local move `in2' 
		qui forv last = `lower'/`upper' {
			if "`chosen'" == "ADD" {
				`estrtn' `depvar' `reglist' in `f'/`last', `noconstant' `robust'
				}
			else if "`chosen'" == "MOVE" {
* 5303 postincrement f
				`estrtn' `depvar' `reglist' in `f'/`last', `noconstant' `robust'
				local ++f
				local l = `f'+`move'
				}
			else if "`chosen'" == "DROPFIRST" {
				`estrtn' `depvar' `reglist' in `last'/`in2', `noconstant' `robust'
				}
				
* store coeffs, RMSE, r^2 in new variables
			if "`noconstant'" == "" {
				replace `stub'_cons = _b[_cons] in `last'/`last'
				replace `stub'`seprefix'_se_cons = _se[_cons] in `last'/`last'
			}
			local i 1
			foreach v of local reglist2	{
				local vr: word `i' of `reglist'
				replace `stub'_`v' = _b[`vr'] in `last'/`last'
				replace `stub'`seprefix'_se_`v' = _se[`vr'] in `last'/`last'
				local ++i
			}
			replace `stub'_r2 = e(r2) in `last'/`last'
			replace `stub'_RMSE = e(rmse) in `last'/`last'
			replace `stub'_N = e(N) in `last'/`last'
		}
end

exit
