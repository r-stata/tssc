*! xtvar.ado v1.0.2 Cagala & Glogowsky 01apr2015
*! Friedrich-Alexander Universität Erlangen-Nuremberg
*! For an application see Cagala et al. (2014): Cooperation and Trustworthiness in Repeated Interaction
*! For Stata 12.0+
* Version history
* 1.0.1
* 1.0.2

capture program drop xtvar
program xtvar, eclass
version 12.0 //program is for STATA 12.0+
	eret clear
	
	syntax varlist [if] [,		///
		LAGs(integer 2)		///
		Reps(integer 200)	///
		STep(integer 8)		///
		Level(integer 95)	///
		SSAving(string)		///
		POoled			///
		bsn			///
		dbsn			///
		bsp			///
		mc			///
		STIrf			///
		norm			///
		nodraw			///
	]
	
/*set standard method for ci*/
	if "`bsn'`dbsn'`bsp'`mc'" == ""	{
		local bsn = "bsn"
	}
	if length("`bsn'`dbsn'`bsp'`mc'") > 4	{
		di "{err}please select only one method for computing confidence intervals"
		exit `rc'
	}
	
/*ERROR section*/
	*confirm variable names*
	while "`1'" != "" {
		if length("'1'") >= 3 {
			if strmatch("`1'", "cons") == 1{
				di "{err}input variables are not allowed to be named 'cons'"
				exit `rc'
			}
			if substr("`1'", 1, 3) == "l1_"{
				di "{err}input variables are not allowed to begin with 'l1_'"
				exit `rc'
			}
		}
		mac shift
	}
	
	*check if unbalanced panel*
	qui xtset
	if r(balanced) != "strongly balanced"{
		di "{err}panel is not strongly balanced"
		exit `rc'
	}
	
	*check if there are gaps in time variable"
	qui tsreport, panel
	if r(N_gaps) != 0{
		di "{err}there are gaps in the time variable"
		exit `rc'
	}
	
	tempname depvar b V V_s txt1 txt2 txt3	///
	panelvar timevar d cresv resv CI2 CI3 MSR
	
preserve	
capture noisily	{	
	/*allow for if statements*/
	if "`if'" != "" {
		quietly keep `if'
	}
	
	/*sort*/
	qui xtset
	sort `r(panelvar)' `r(timevar)'

	/*new xtset*/
	local ivar "`r(panelvar)'"
	egen `panelvar' = group(`ivar')
	by `ivar': gen `timevar' = _n
	qui xtset `panelvar' `timevar'
	
	/*generate local macros*/
	local cmdline "`0'"
	local tmax `r(tmax)'
	local imax `r(imax)'
	local depvars = wordcount("`varlist'")
	local rep 0
	local step = `step' + 1
	if missing("`rm'") {
		local cit "p"
	}
	else {
		local cit "n"
	}

	/*generate lagged variables & dummies*/
	genlagdum `varlist' ,		/// 
		d(`d')			///
		timevar(`timevar')	///
		panelvar(`panelvar')	///
		`pooled' 		///
		lags(`lags')
		
	local obs = _N //number of observations
	
	/*generate lists*/
	lists `varlist' ,		///
		d(`d')			///
		`pooled'		///
		lags(`lags')		///
		imax(`imax')		///
		rep(`rep')
		
	local indepvarlist "`r(indepvarlist)'"
	local constants "`r(constants)'"
	
	/*estimation*/
	estimation `varlist' ,				///
		resv(`resv')				///
		cresv(`cresv')				///
		panelvar(`panelvar')			///
		ci(`bsn' `dbsn' `bsp' `mc')		///
		depvars(`depvars')			///
		lags(`lags')				///
		rep(`rep')				///
		indepvarlist(`indepvarlist')		///
		constants(`constants')
		
	local res`rep' "`r(res`rep')'"
	if (!missing("`bsn'") | !missing("`dbsn'")) & `rep' == 0 {	
		local cres "`r(cres)'"
	}

	/*covariance matrix*/
	covariance ,			///
		`pooled'		///
		depvars(`depvars')	///
		lags(`lags')		///
		imax(`imax')		///
		obs(`obs')		///
		rep(`rep')		///
		res(`res`rep'')
		
	/*contemporary effects*/
	contemporary ,	/// 
		rep(`rep')

	/*variance coefficients*/
	varianceb `varlist' ,				///
		rep(`rep')				///
		indepvarlist(`indepvarlist')		///
		constants(`constants')			///
		ci(`bsn' `dbsn' `bsp' `mc')	
	
	/*irf*/
	irf , 				///
		`stirf'			///
		lags(`lags')		///
		step(`step')		///
		rep(`rep')		///
		depvars(`depvars')
	
	mat drop COL`rep'
	tempfile boot

	/*generate variables/dataset*/
	if missing("`mc'") { 
		keep `cres' `timevar' `panelvar'
		qui save "`boot'" //save dataset for bootestrap
	}	

	/*fevd*/
	fevd ,				///
		step(`step')		///
		rep(`rep')		///
		depvars(`depvars')
	
	local fevd "`r(fevd)'"
	
	/*prepare monte carlo*/
	if !missing("`mc'") {
		preparemc , 				///
			`pooled'			///
			obs(`obs')			///
			reps(`reps')			///
			rep(`rep')			///
			depvars(`depvars')		///
			constants(`constants')		///
			indepvarlist(`indepvarlist')	///
			depvarlist(`varlist')		///
			lags(`lags')			///	
			imax(`imax')

		local betau "`r(betau)'"
	}
	
	/*confidence intervals*/
	ci ,							///
		resv(`resv')					///
		timevar(`timevar')				///
		panelvar(`panelvar')				///
		`stirf'						///	
		`pooled'					///
		ci(`bsn' `dbsn' `bsp' `mc')			///
		step(`step')					///
		reps(`reps')					///
		obs(`obs')					/// 
		lags(`lags')					///
		imax(`imax')					///
		tmax(`tmax')					///
		level(`level')					///
		cres(`cres')  					///
		depvars(`depvars')				///
		res0(`res0')					///
		constants(`constants')				///
		indepvarlist(`indepvarlist')			///
		betau(`betau')					///
		boot(`boot')

	/*results: matrices*/
	if missing("`pooled'") {		
		mat `b'=vec(B_s0)'
		
		local i = 1 //drop rows with dummies
		while `i' <= (`depvars' * `lags' + `imax') * `depvars' {
			mat `V_s' = nullmat(`V_s') \	///
			V0[`i'..`i' + `depvars' * `lags' - 1, 1...]
			local i = `i' + `depvars' * `lags' + `imax'
		}
			local i = 1 //drop columns with dummies
		while `i' <= (`depvars' * `lags' + `imax') * `depvars' {
			mat `V' = nullmat(`V') ,	///
			`V_s'[1...,`i'..`i' + `depvars' * `lags' - 1]
			local i = `i' + `depvars' * `lags' + `imax'
		}
	}
	else {
		mat colnames B0 = `varlist'
		mat `b' = vec(B0)'
		mat `V' = V0
	}
	
	mat drop V0 B0 B_s0

	ereturn post `b' `V'
	
	eret mat Sigma = Sigma0, copy

	/*results: scalars*/
	eret scalar  N = `obs'
	eret scalar neqs = `depvars'
	
	if missing("`pooled'") {
		forvalues i = 1/`depvars' { 
			eret scalar k_`i' = `lags' * `depvars' + `imax'
			eret scalar  df_m = `lags' * `depvars'
			eret scalar df_m`i' = e(df_m)
			eret scalar  df_r = `obs' - e(df_m) - `imax'
			eret scalar df_r`i' = e(df_r)
		}
	}
	else {
		forvalues i = 1/`depvars' {
			eret scalar k_`i'= `lags' * `depvars' + 1
			eret scalar df_m = `lags' * `depvars'
			eret scalar df_m`i' = e(df_m)
			eret scalar df_r = `obs' - e(df_m) - 1
			eret scalar df_r`i' = e(df_r)
		}
	}

	mat `MSR' = vecdiag(Sigma0)
	mat drop Sigma0

	local i=1
	foreach var of local varlist {
		eret scalar r2_`i' = r2_`i'
		eret scalar tss_`i' = tss_`i'
		eret scalar rss_`i' = rss_`i'
		eret scalar mss_`i' = mss_`i'
		scalar MSR`var' = `MSR'[1,`i']
		eret scalar rmse_`i' = MSR`var'^(1/2)
		eret scalar F_`i' =  F_`i'
		eret scalar F_panel_`i' = F_panel_`i'
		eret scalar p_panel_`i' = p_panel_`i'
		scalar drop r2_`i' tss_`i' rss_`i' mss_`i'	///
		F_`i' F_`i' F_panel_`i' p_panel_`i' MSR`var'
		local i = `i' + 1
	}

	eret scalar N_g = `imax'
	eret scalar g = `obs'/`imax'
	
	/*results: macros*/
	eret local ivar "`ivar'"
	eret local eqnames "`varlist'"
	eret local cmd "xtvar"
	eret local cmdline `"`e(cmd)' `cmdline'"'

	/*display results*/
	if missing("`pooled'") {
		local txt1="Panel (LSDV) vector autoregression"
		local txt2="Group variable: "
		local txt3="`e(ivar)'"
	}
	else {
		local txt1="Pooled vector autoregression"
		local txt2=""
		local txt3=""
	}
	#delimit ;
	di _n in gr "`txt1'"
		_col(49) in gr "Number of obs" _col(68) "="
		_col(70) in ye %9.0f e(N) ;
	di in gr "`txt2'" in ye abbrev("`txt3'",12) in gr
		_col(49) "Number of groups" _col(68) "="
		_col(70) in ye %9.0g e(N_g) _n ;
	di in gr
		_col(49) in gr "Obs per group" _col(68) "="
		_col(70) in ye %9.0f e(g) ;
	#delimit cr
			
	di	
	_vardisprmse , est(var) small
		
	if missing("`pooled'") {
		di "F statistic for F("e(df_m) ","e(df_r) ")"
	}
	else {
		di "F statistic is for F("e(df_m) ","e(df_r) ")"
	}

	eret display, level(`level')

	di
	di

	mat rownames A0 = `varlist'
	mat colnames A0 = `varlist'
	
	di "Contemporary coefficients"
	mat list A0, noheader
	eret mat A = A0
	

	/*tables & graphs: lists*/
	order D* F* step
	qui ds
	tokenize "`r(varlist)'"
	while "`1'" != "" & "`1'" != "step" {
		local list "`1'_ll `1'_ul"
		foreach c of local list {
			local CIn "`CIn' n`c'"
			local CIp "`CIp' p`c'"
		}
		macro shift
	}	

	local cilist "p n"
	foreach c of local cilist {
		mat `CI2'`c' = CI`c'
		forvalues i = 1/`step' {
			mat `CI3'`c'= nullmat(`CI3'`c') \	///
			vec(`CI2'`c'[1..2 * `depvars' * `depvars', 1...]')'
			capture mat `CI2'`c' =	///
			`CI2'`c'[2 * `depvars' * `depvars' + 1..., 1...]
		}
		mat colnames `CI3'`c' = `CI`c''
		svmat `CI3'`c', names(col) 
		mat drop CI`c'
	}
	
	/*tables & graphs: names for ci*/
	foreach var of varlist *_ul {
		char `var'[varname] "Upper"
	}
	
	foreach var of varlist *_ll {
		char `var'[varname] "Lower"
	}
	
	foreach var of varlist D* {
		char `var'[varname] "IRF"
	}
	
	foreach var of varlist FEVD* {
		char `var'[varname] "FEVD"
	}
	
	foreach var1 of local varlist {
		foreach var2 of local varlist {
			local shock "`shock' `var1' `var2'"
		}
	}
	
	/*save datset*/
	if !missing("`ssaving'") {
		save `ssaving'
	}
	
	/*display tables & prepare graphs */
	local s = 1
	local r = 2
	local t = `depvars' * `depvars'
	tokenize `shock'
	forvalues i = 1/`t' {
		local IRF`i' "D0`i'"
		
		local IRF`i' "`IRF`i'' `cit'D0`i'_ll `cit'D0`i'_ul"
				
		/* *to show both confidence bands
		local IRF`i' "`IRF`i'' pD0`i'_ll pD0`i'_ul"
		local IRF`i' "`IRF`i'' nD0`i'_ll nD0`i'_ul"
		*/
		
		local IRFFE`i' "`IRF`i'' FEVD0`i'"
		
		/* *to show both confidence bands
		local IRFFE`i' "`IRFFE`i'' pFEVD0`i'_ll pFEVD0`i'_ul"
		local IRFFE`i' "`IRFFE`i'' nFEVD0`i'_ll nFEVD0`i'_ul"
		*/
		
		local IRFFE`i' "`IRFFE`i'' `cit'FEVD0`i'_ll `cit'FEVD0`i'_ul"
		local table_IRF`i' "s `IRFFE`i''"
		
		di
		di "Response of " in ye  "``r''" in gr " to shock in " in ye "``s''"
		
		local sep = round(`step'/2,1)
		list `table_IRF`i'', noob  subvarname separator(`sep')
		local k = `k' + 1
		
		twoway line `IRF`i'' step,	///
			name(IRF`i', replace) yline(0, lcolor(gs10) lwidth(medium))	///
			legend(off) subtitle(Response: ``r'', position(11)) nodraw
		local i = `i' + 1
		local s = `s' + 2
		local r = `r' + 2
	}
	
	if "`cit'" == "p" {
		di
		di in ye `level' "% lower and upper bounds reported; percentile ci"
	}
	else {
		di
		di in ye `level' "% lower and upper bounds reported; standard normal ci"
	}
	
	local i = 1
	local j = 1
	local k = 1
	forvalues i = 1/`t' {
		local GIRF`j' "`GIRF`j'' IRF`i'"
		if `k' == `depvars' {
			local j = `j' + 1	
			local k = 0
		}
		local k = `k' + 1
	}

	/*display graphs*/
	if missing("`draw'") {
	local i = 1
		while `i' <= `depvars' {
			foreach var of local varlist {
				if "`cit'" == "p" {
					gr combine `GIRF`i'',					///
					xcom imargin(0 0 0 0)					///
					subtitle(Impulse: `var', position(11))			///
					name(IRF_`var', replace)				///
					note("`level'% lower and upper bounds reported; percentile ci")
				}
				else {
					gr combine `GIRF`i'',					///
					xcom imargin(0 0 0 0)					///
					subtitle(Impulse: `var', position(11))			///
					name(IRF_`var', replace)				///
					note("`level'% lower and upper bounds reported; standard normal ci")
				}
		local i = `i' + 1
			}
		}
	
		tokenize `fevd'
		local k = 1
		foreach var of local varlist {
			local legend `" `legend' label(`k' "`var'") "'
			local k = `k' + 1
	    }
		local j = 1
		while `j' <= `depvars' {
			foreach var of local varlist {
				forvalues i = 1/`depvars' {
					local FEVD`j' "`FEVD`j'' `1'"
					macro shift
				}
				graph bar (sum) `FEVD`j'' if step >0,					///
					perc over(step) stack subtitle(FEVD: `var', position(11))	///
					name(FEVD_`var', replace)  legend(`legend')
				local j = `j' + 1
			}
		}
	}
}

if _rc != 0	{
	di
	di "{err}the program produced an error or was stopped"
	di "for information type: search rc " _rc
	di "clear matrix before running xtvar again"

}
restore		

end	

//GENERATE LAGGED VARIABLES AND GROUP DUMMIES
capture program drop genlagdum
program define genlagdum
	syntax varlist [ ,		///
		d(string)		///
		timevar(string)		///
		panelvar(string)	///
		pooled 			///
		lags(integer 2)		///
	]
	keep `varlist' `panelvar' `timevar'
	
	/*generate lagged variables*/
	foreach var of local varlist {
		forvalues i = 1 / `lags' {
				qui gen l`i'_`var' = l`i'.`var'
		}
	}
	
	/*generate group dummies/ constant*/
	if missing("`pooled'") {
		qui tab `panelvar', gen(`d')
	}
	else {
		gen cons = 1
	}

	/*drop missings*/
	foreach v of var * {
		qui drop if missing(`v')
	}
	
end


//LISTS
capture program drop lists
program define lists, rclass
	syntax varlist [, 		///
		d(string)		///
		pooled 			///
		lags(integer 2) 	/// 
		imax(integer 1)  	///
		rep(string) 		///
	]
	
	/*lists of dependent and independent variables*/
	 forvalues i = 1/`lags' {
		foreach var of local varlist {
			local indepvarlist "`indepvarlist' l`i'_`var'"
		}
	}
		
	return local indepvarlist "`indepvarlist'"
	
	/*list of dummies/ constant*/
	if missing("`pooled'") &  `rep' == 0 {
		forvalues i = 1/`imax' {
			local constants "`constants' `d'`i'" 
		}
	}
	if !missing("`pooled'")  &  `rep' == 0 {
		local constants "cons"
	}
		
	return local constants "`constants'"
	
end 

//ESTIMATION
capture program drop estimation
program define estimation, rclass
	syntax varlist [, 			///
		resv(string)			///
		cresv(string)			///
		panelvar(string)		///
		ci(string)			///
		lags(integer 2)			/// 
		indepvarlist(string) 		///
		constants(string)		/// 
		depvars(integer 1) 		///
		rep(string)			///
	]
	tempname TSS

	if `rep' == 0 & "`ci'" != "mc" {
		mkmat `indepvarlist' `constants', mat(INDEPVARLIST_CONS)
	}

	local i = 1
	foreach var of local varlist {	
		qui regress `var' `indepvarlist' `constants', nocons

		mat B`rep' = nullmat(B`rep') , e(b)'
		qui predict `resv'`i'`rep', res
		local res`rep' "`res`rep'' `resv'`i'`rep'"	
		
		/*centered residuals for bootstrapping (always around group mean)*/
		tempvar mres`i' mean_`var' demean_`var'
		if `rep' == 0 {
			if "`ci'" == "bsn" | "`ci'" == "dbsn" {
				by `panelvar': egen `mres`i'' = mean(`resv'`i')
				qui gen `cresv'`i' = `resv'`i' - `mres`i''
				local cres "`cres' `cresv'`i'"
			}
			qui egen `mean_`var'' = mean(`var')
			qui gen `demean_`var'' = `var' - `mean_`var''
			qui mat accum `TSS' = `demean_`var'' `demean_`var'', nocons
			scalar r2_`i' = 1 - e(rss) / `TSS'[1,1]
			scalar tss_`i' = `TSS'[1,1]
			scalar rss_`i' = e(rss)
			scalar mss_`i' = `TSS'[1,1] - e(rss)
			qui test `indepvarlist'
			scalar F_`i' = r(F)
			qui test `constants'
			scalar F_panel_`i' = r(F)
			scalar p_panel_`i' = r(p)
		}
		local i = `i' + 1
	}
	
	return local res`rep' "`res`rep''"
	
	if ("`ci'" == "bsn" | "`ci'" == "dbsn") & `rep' == 0 {	
		return local cres "`cres'"
	}

	mat colnames B`rep' = `varlist'
	
	mat B_s`rep' = B`rep'[1..`lags' * `depvars', 1...] //without dummies/constant

	if `rep' != 0 {
		mat drop B`rep'
	}

end

//COVARIANCE & CHOLESKY
capture program drop covariance
program define covariance
	syntax [,			/// 
		pooled			///
		obs(integer 1)	 	/// 
		depvars(integer 1) 	/// 
		lags(integer 2) 	/// 
		imax(integer 1) 	/// 
		res(string) 		/// 
		rep(string)		/// 
	]
	
	/*covariance*/
	qui mat accum Sigma`rep' = `res', nocons

	if missing("`pooled'") {
		mat Sigma`rep' = Sigma`rep'/(`obs' - `depvars'*`lags' - `imax')
	}
	else {
		mat Sigma`rep' = Sigma`rep'/(`obs' - `depvars'*`lags' - 1) 	
	}

	/*cholesky*/
	mat COL`rep' = cholesky(Sigma`rep') 
	
end

//CONTEMPORARY COEFFICIENTS
capture program drop contemporary
program define contemporary
	syntax [ ,		/// 
		rep(string)	///
	]
	
	mat A`rep' = COL`rep' * inv(diag(vecdiag(COL`rep')))

end

//COVARIANCE OF COEFFICIENTS
capture program drop varianceb
program define varianceb
	syntax [varlist] [ ,	///
	indepvarlist(string)	///
	constants(string)	///
	rep(string)		///
	ci(string)		///
	]

	mat colnames Sigma`rep' = `varlist'
	mat rownames Sigma`rep' = `varlist'

	if `rep' == 0 {
		qui mat accum XpX = `indepvarlist' `constants', nocons
		qui mat XpX = syminv(XpX)
	}
	
	mat V`rep' = Sigma`rep' # XpX 

end

//IRF
capture program drop irf
program define irf
	syntax [, 			///
		stirf 			///
		lags(integer 2) 	///
		depvars(integer 1)	///
		step(integer 8) 	///
		rep(integer 1)		///
	]

	tempname DS AS J C TEMP

	/*J matrix for extraction of elements*/ 
	if `lags' > 1 {
		mat `J' = I(`depvars'), J(`depvars', `lags' * `depvars' - `depvars',0)
		}  
	else {  
		mat `J' = I(`depvars')
	}

	/*companion matrix C*/
	if `lags' > 1 {
		mat `TEMP' = I(`lags' * `depvars' - `depvars'),	///
		J(`lags' * `depvars' - `depvars', `depvars', 0)    
		mat `C' = B_s`rep'' \ `TEMP'
	}
	else {
		mat `C' = B_s`rep''
	}

	/*response matrix*/
	mat `AS' = I(`lags' * `depvars')
	
	/*IRF*/
	forvalues i = 1 / `step' {
		if missing("`stirf'") {
			mat `DS' = `J' * `AS' * `J'' * COL`rep'
		}
		else {
			mat `DS' = `J' * `AS' * `J'' * A`rep'
        }
		mat `DS' = vec(`DS')
		mat D`rep' = nullmat(D`rep') \ `DS''
		mat `AS' = `AS' * `C'
	}

end

//FEVD
capture program drop fevd
program fevd, rclass
	syntax [ ,				///
		step(integer 8)			///
		depvars(integer 1)		///
		rep(string)			///
		ci(string)			///
	]
	tempname FEVD

	/*generate dataset*/
	qui svmat D`rep'

	qui keep if _n  <= `step'
	keep D*
	gen step = _n - 1
	
	/*generate MSE*/
	local i = 1
	while `i' <= `depvars' {
		tempname MSE`rep'`i'
		qui gen double `MSE`rep'`i'' = 0
		local j = `i'
		while `j' <= `depvars' * `depvars' {
			qui replace `MSE`rep'`i'' = `MSE`rep'`i'' + sum(D`rep'`j'^2)
			local j = `j' + `depvars'
		}
		local i = `i' + 1
	}

	/*FEVD*/
	local i = 1
	while `i' <= `depvars' {
		local j = `i'
		while `j' <= `depvars' * `depvars' {
			tempname H`j'
			qui gen `H`j'' = sum(D`rep'`j'^2) / `MSE`rep'`i''
			qui gen FEVD`rep'`j' = `H`j''[_n - 1]
			qui replace FEVD`rep'`j' = 0 if FEVD`rep'`j' == .
			local fevd "`fevd' FEVD`rep'`j'"
			local j = `j' + `depvars'
		}
		local i = `i' + 1
	}
	
	return local fevd "`fevd'"
	
	if `rep' == 0 {
		mkmat `fevd', mat(`FEVD') //bs residual matrix 
		mat D0FEVD = D`rep', `FEVD'
		mat D0FEVD = vec(D0FEVD')' //input vector for bstat
	}
		
	mat drop D`rep'
end

//PREPARE MC
capture program drop preparemc
program preparemc, rclass
	syntax [, 				///
		pooled  			///
		depvars(integer 1)		///
		obs(integer 1)  		///
		reps(integer 200)  		///
		indepvarlist(string)  		///
		depvarlist(string)		///
		constants(string) 	 	///
		rep(integer 1) 			///
		lags(integer 2)			///
		imax(integer 1)			///
	]

	tempname sigma_vec sigma_dnp Sigma_V Dnp

	/*Asymptotic Variance of Cov Matrix*/
	mata: st_matrix("Dn", Dmatrix(`depvars'))
	mat `Dnp' = (inv(Dn' * Dn)) * Dn'

	mat `sigma_vec' = vec(Sigma`rep')
	mat `sigma_dnp' = `Dnp' * `sigma_vec'

	if missing("`pooled'") {
		mat `Sigma_V' = 1 / (`obs' - `depvars' * `lags' - `imax') *	///
		2 * `Dnp' * (Sigma`rep' # Sigma`rep') * `Dnp''
	}
	else {
		mat `Sigma_V' = 1 / (`obs' - `depvars' * `lags' - 1) *	///
		2 * `Dnp' * (Sigma`rep' # Sigma`rep') * `Dnp''
	}
	
	/*draw cov-matrices*/
	local j=rowsof(`sigma_dnp')
	forvalues i = 1 / `j' {
		local sigma "`sigma' res`i'"
	}
			
preserve
	clear

	*mata: st_matrix("Sigma_V", makesymmetric(st_matrix("Sigma_V")))
	local repetitions = ceil(`reps' / 2)
	qui drawnorm `sigma', cov(`Sigma_V') mean(`sigma_dnp') n(`repetitions')
	mkmat `sigma', mat(SIGMA)

restore

	/*draw coefficients: preparation*/
	foreach depvar of local depvarlist {
		foreach indepvar of local indepvarlist { 
			local betau "`betau' `depvar'_`indepvar'"
		}
		foreach constant of local constants {
			local betau "`betau' `depvar'_`constant'"
		}
	}
	return local betau "`betau'"

end

//CI
capture program drop ci
program define ci
	syntax [, 				///
		timevar(string)			///
		panelvar(string)		///
		resv(string)			///
		stirf				///
		pooled 				///
		ci(string)			///
		res0(string)			///
		step(integer 8) 		///
		depvars(integer 1)	 	///
		reps(integer 200) 		///
		obs(integer 1) 			///
		lags(integer 2) 		///
		imax(integer 1) 		///
		tmax(integer 1)			///
		rep(string) 			///
		level(integer 95)		///
		cres(string)			///
		constants(string)		///
		indepvarlist(string)		///
		betau(string)			///
		boot(string)			///
	]
	
	tempname sim
	tempvar ireshape
	tempfile simulate

preserve
	
	/*dataset for ci*/
	local j = 2 * `step' * `depvars' * `depvars'
	forvalues  i = 1 / `j' {
		local l1 "`l1' IRF`i'"
	}
	
	qui postfile `sim' `l1' using "`simulate'", replace

	/*display progress*/
	di ".",  _continue
	forvalues i = 1 / `reps' {
		local rep = `rep' + 1
		if mod(`i',4) == 0 {
			if mod(`i',100) == 0 {
				di " `i'", _continue
				di
			}
		di ".",  _continue 
		}
		
		/*Monte Carlo loops*/
		if "`ci'"=="mc" {
			mc ,				///
				`stirf'			///
				`pooled'		///
				lags(`lags')		///
				imax(`imax')		///
				step(`step')		///
				rep(`rep')		///
				depvars(`depvars')	///
				betau(`betau')		///
				reps(`reps')

			qui clear 
		}
		
		/*bootstrapping*/
		else {
			bootstrapping ,						///
				timevar(`timevar')				///
				panelvar(`panelvar')				///
				resv(`resv')					///
				`stirf'						///
				`pooled'					///
				`ci' 						///
				rep(`rep')					///
				reps(`reps')					///
				imax(`imax')					///
				tmax(`tmax')					///
				obs(`obs')					///
				lags(`lags')					///
				step(`step')					///
				depvars(`depvars')				///
				res0(`res0')					///
				cres(`cres')					///
				constants(`constants')				///
				indepvarlist(`indepvarlist')			///
				boot(`boot')

		}
		
		/*call fevd*/
		fevd,				/// 
			depvars(`depvars')	///
			step(`step')		///
			rep(`rep')

		qui replace step = step+100000
		gen `ireshape' = 1
		qui reshape wide D* FEVD* , i(`ireshape') j(step)
		drop `ireshape'

		qui ds
		local vars "`r(varlist)'"
		foreach var of local vars {
			local l2`rep' "`l2`rep'' (`var')"
		}
		/*expand data set*/ 
		quietly post `sim' `l2`rep'' 
	}
	postclose `sim'
	/*confidence bands*/
	qui bstat using  "`simulate'", stat(D0FEVD) level(`level') 
	mat drop D0FEVD
	  
	mat CIp = e(ci_percentile)'
	mat CIn = e(ci_normal)'

restore
end

//MONTE CARLO
capture program drop mc
program mc, rclass
	syntax [,			///
		stirf			///
		pooled			///
		depvars(integer 1)	///
		lags(integer 2)		///
		imax(integer 1)		///
		rep(integer 1)		///
		betau(string) 		///
		step(integer 8)		///
		reps(integer 200)	///
	]
	tempname sigma_vec b_vec odd

	scalar `odd' = mod(`rep',2)
	if `odd' == 1 {
		local repetition = ceil(`rep'/2)
		
		/*covariance matrix*/
		mat `sigma_vec' = Dn * SIGMA[`repetition',1...]'
		
		vctomtx 		///
			`depvars'	///
			`depvars'+1	///
			`depvars'	///
			`sigma_vec'	///
			Sigma`rep'		
preserve
		clear

		/*draw coefficients*/
		varianceb, ///
			rep(`rep')
		
		*mata: st_matrix("V`rep'", makesymmetric(st_matrix("V`rep'")))
		qui drawnorm `betau', cov(V`rep') n(1)
		mkmat `betau', mat(betau)
		mat `b_vec' = vec(B0) + betau'
		mat drop V`rep'
		
restore
		
		/*contemporary effects*/
		mat COL`rep' = cholesky(Sigma`rep')
		if !missing("`stirf'") {
			contemporary ,	/// 
				rep(`rep')
		}
		
		mat drop Sigma`rep'
	}

	else {
		local rep_1 = `rep' - 1

		if !missing("`stirf'") {
			mat A`rep' = A`rep_1'
		}
		else {
			mat COL`rep' = COL`rep_1'
		}
		
		mat `b_vec' = vec(B0) - betau'
		mat drop betau 
		
		mat drop COL`rep_1'
	}
			
	/*coefficients matrix*/
	if missing("`pooled'") {
		vctomtx							///
			`lags'*`depvars'				///
			`lags'*`depvars'+`imax'+1			///
			`depvars'					///
			`b_vec'						///
			B_s`rep'
	}	
	else {
		vctomtx						///
			`lags'*`depvars'			///
			`lags'*`depvars'+1+1			///
			`depvars'				///
			`b_vec'					///
			B_s`rep'
	}
	
	/*IRF*/
	irf,				/// 
		`stirf' 		///
		step(`step') 		///
		rep(`rep')		///
		lags(`lags')		///
		depvars(`depvars')
		
	if `rep' == `reps' {
		capt mat drop betau 
		capt mat drop COL`rep'
		mat drop SIGMA Dn
		mat drop XpX
	}	
	
	capt mat drop B_s`rep'

	if `odd' == 0 {
		capt mat drop A`rep' 
		capt mat drop COL`rep'
	}
	
end

//BOOTSTRAP
capture program drop bootstrapping
program define bootstrapping
	syntax [,				///
		timevar(string)			///
		panelvar(string)		///
		resv(string)			///
		stirf				///
		pooled 				/// 
		bsn 				/// 
		dbsn 				/// 
		bsp				///
		imax(integer 1)			///
		tmax(integer 1)			///
		depvars(integer 1)		///
		res0(string)			///
		obs(integer 1)			///
		rep(integer 1)			///
		lags(integer 2) 		///
		cres(string)			///
		constants(string)		///
		reps(integer 200)		///
		indepvarlist(string)		///
		step(integer 8)			///
		boot(string)			///
	]
	
	tempfile boot2
	tempname nn nn2 H1 H2 INDEPVARLIST VARLIST
	
	local obs_b = `tmax' - `lags'
		
	/*parametric bootstrap*/
	if !missing("`bsp'") {
		clear
		qui drawnorm `res0', cov(Sigma0) n(`obs')
		mkmat `res0', mat(RES`rep')
	}

	/*temporal bootstrap*/
	else { 
		clear
		qui set obs `obs_b'
		generate long `timevar' = ///
		floor((`obs_b') * runiform() + (`lags' + 1)) //random draw of periods
		generate `nn' = _n //ordering
		joinby `timevar' using "`boot'" //create residual dataset 
		sort `panelvar' `nn' //same order for all groups
		mkmat `cres', mat(RES`rep')
	}
	
	mat `VARLIST' = J(`obs', `depvars', .)
	if missing("`pooled'") {
		mat `H2' = I(`depvars' * `lags') \	///
		J(`depvars' + `imax', `depvars' * `lags', 0) //to extract portion of H3
		mat `INDEPVARLIST' = J(`obs',`lags' * `depvars' + `imax', .)
	}
	else {
		mat `H2' = I(`depvars' * `lags') \	///
		J(`depvars' + 1, `depvars' * `lags', 0) 
		mat `INDEPVARLIST' = J(`obs', `depvars' * `lags' + 1, .)
	}

	/*generate bootstrap dataset recursively*/
	local n = 1
	forvalues i = 1(`obs_b')`obs' {
 		mat `H1' = INDEPVARLIST_CONS[`n',1...]
		forvalues j = 1 / `obs_b' {
			mat `INDEPVARLIST'[`n',1] = `H1'
			mat `VARLIST'[`n',1] = `H1' * B0 + RES`rep'[`n',1...]
			mat `H1' = (`VARLIST'[`n',1...], `H1') * `H2' //cut off old lags and dummies
			mat `H1' = (`H1', `INDEPVARLIST'[`n',`depvars' * `lags' + 1...]) //add dummies
			local n = `n' + 1
		}
	}
	
	mat drop RES`rep'

	svmat `VARLIST'

	forvalues i = 1 / `depvars' {
		local varlist "`varlist' `VARLIST'`i'" 
	}

	/*lists for estimation*/
	lists `varlist' , 	///
		`pooled'	///
		lags(`lags')	///
		imax(`imax')	///
		rep(`rep')
	
	local indepvarlist "`r(indepvarlist)'"

	mat colnames `INDEPVARLIST' = `indepvarlist' `constants'
	
	svmat `INDEPVARLIST', names(col)

	/*double resampling*/
	if !missing("`dbsn'") & missing("`bsp'") {
		qui save "`boot2'", replace
		clear
		local obs_b = `imax'
		qui set obs `obs_b'
		generate long `panelvar' = floor(`imax' * runiform() + 1) //random draw of groups
		generate `nn2' = _n //ordering
		joinby `panelvar' using "`boot2'" //create residual dataset 
		sort `nn2' `nn'
	}
	
		
//estimation
	estimation `varlist',				///
		resv(`resv')				///
		depvars(`depvars')			///
		lags(`lags')				/// 
		rep(`rep')				///
		indepvarlist(`indepvarlist')		///
		constants(`constants')
	
	local res`rep' "`r(res`rep')'"

//covariance matrix
	covariance , 			///
		`pooled'		///
		depvars(`depvars')	///
		lags(`lags')		///
		imax(`imax')		///
		obs(`obs')		///
		rep(`rep')		///
		res(`res`rep'')

	mat drop Sigma`rep'

//contemporary effects
	if !missing("`stirf'") {
		contemporary , 	/// 
			rep(`rep')
	}

//irf
	irf , 				///
		`stirf'			///
		lags(`lags')		///
		step(`step')		///
		rep(`rep')		///
		depvars(`depvars')

	mat drop B_s`rep'
	capt mat drop COL`rep'
	capt mat drop A`rep'
	
	if `rep' == `reps' {
		mat drop INDEPVARLIST_CONS
	}	
		
end

//TURN VECTOR INTO MATRIX
capture program drop vctomtx
program define vctomtx
//`1' rows of matrix; `2' is cut off value; `3' is number of columns;
// `4' is name of vector ; `5' name of matrix

	tempname column
	forvalues i = 1 / `3' {
		mat `column'`i' = `4'[1..`1',1] //extract first column matrix from vector
		capt mat `4' = `4'[`2'...,1] //cut elements off vector
		mat `5' = nullmat(`5') , `column'`i' //stack culumn vectors
	}
	
end
