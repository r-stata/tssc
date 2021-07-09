********************************************************************************
* RDDENSITY STATA PACKAGE -- rddensity
* Authors: Matias D. Cattaneo, Michael Jansson, Xinwei Ma
********************************************************************************
*!version 1.0 14-Jul-2019

capture program drop rddensityEST

program define rddensityEST, eclass
	syntax varlist(max=1) [if] [in] [, c(real 0) p(integer 2) q(integer 0) fitselect(string) kernel(string) h(string) bwselect(string) vce(string) all]

	marksample touse

	if (`q'==0) local q = `p' + 1
	if ("`fitselect'"=="") local fitselect = "unrestricted"
	local fitselect = lower("`fitselect'")
	if ("`kernel'"=="") local kernel = "triangular"
	local kernel = lower("`kernel'")
	if ("`bwselect'"=="") local bwselect = "comb"
	local bwselect = lower("`bwselect'")
	if ("`vce'"=="") local vce = "jackknife"
	local vce = lower("`vce'")
	
	tokenize `h'	
	local w : word count `h'
	if `w' == 0 {
		local hl 0
		local hr 0
	}
	if `w' == 1 {
		local hl `"`1'"'
		local hr `"`1'"'
	}
	if `w' == 2 {
		local hl `"`1'"'
		local hr `"`2'"'
	}
	if `w' >= 3 {
		di as error  "{err}{cmd:h()} only accepts two inputs."  
		exit 125
	}

	preserve
	qui keep if `touse'

	local x "`varlist'"

	qui drop if `x'==.
	
	qui su `x'
	local x_min = r(min)
	local x_max = r(max)
	local N = r(N)

	qui count if `x'<`c'
	local Nl = r(N)
	qui count if `x'>=`c'
	local Nr = r(N)

	****************************************************************************
	*** BEGIN ERROR HANDLING *************************************************** 
	if (`c'<=`x_min' | `c'>=`x_max'){
		di "{err}{cmd:c()} should be set within the range of `x'."  
		exit 125
	}
	
	if (`Nl'<10 | `Nr'<10){
		di "{err}Not enough observations to perform calculations."  
		exit 2001
	}
	
	if (`p'!=1 & `p'!=2 & `p'!=3 & `p'!=4 & `p'!=5 & `p'!=6 & `p'!=7){
		di "{err}{cmd:p()} should be an integer value less or equal than 7."  
		exit 125
	}
	
	if (`p'>=`q'){
		di "{err}{cmd:p()} should be an integer value smaller than {cmd:q()}."  
		exit 125
	}

	if ("`kernel'"!="uniform" & "`kernel'"!="triangular" & "`kernel'"!="epanechnikov"){
		di "{err}{cmd:kernel()} incorrectly specified."  
		exit 7
	}

	if ("`fitselect'"!="restricted" & "`fitselect'"!="unrestricted"){
		di "{err}{cmd:fitselect()} incorrectly specified."  
		exit 7
	}

	if (`hl'<0){
		di "{err}{cmd:hl()} must be a positive real number."  
		exit 411
	}

	if (`hr'<0){
		di "{err}{cmd:hr()} must be a positive real number."  
		exit 411
	}

	if ("`fitselect'"=="restricted" & `hl'!=`hr'){
		di "{err}{{cmd:hl()} and {cmd:hr()} must be equal in the restricted model."  
		exit 7
	}

	if ("`bwselect'"!="each" & "`bwselect'"!="diff" & "`bwselect'"!="sum" & "`bwselect'"!="comb"){
		di "{err}{cmd:bwselect()} incorrectly specified."  
		exit 7
	}

	if ("`fitselect'"=="restricted" & "`bwselect'"=="each"){
		di "{err}{cmd:bwselect(each)} is not available in the restricted model."  
		exit 7
	}

	if ("`vce'"!="jackknife" & "`vce'"!="plugin"){ 
		di "{err}{cmd:vce()} incorrectly specified."  
		exit 7
	}
	*** END ERROR HANDLING ***************************************************** 
	****************************************************************************

	****************************************************************************
	*** BEGIN BANDWIDTH SELECTION ********************************************** 
	if ("`h'"!="") {
        local bwmethod = "manual"
	}
	
	if (`hl'==0 | `hr'==0) {
	    local bwmethod = "`bwselect'"
		disp in ye "Computing data-driven bandwidth selectors."
		qui rdbwdensity `x', c(`c') p(`p') kernel(`kernel') fitselect(`fitselect') vce(`vce')
		mat out = e(h)
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="each" & `hl'==0) local hl = out[1,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="each" & `hr'==0) local hr = out[2,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="diff" & `hl'==0) local hl = out[3,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="diff" & `hr'==0) local hr = out[3,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="sum"  & `hl'==0) local hl = out[4,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="sum"  & `hr'==0) local hr = out[4,1]
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="comb" & `hl'==0) local hl = out[1,1]+out[3,1]+out[4,1] - min(out[1,1],out[3,1],out[4,1]) - max(out[1,1],out[3,1],out[4,1])
		if ("`fitselect'"=="unrestricted" & "`bwselect'"=="comb" & `hr'==0) local hr = out[2,1]+out[3,1]+out[4,1] - min(out[2,1],out[3,1],out[4,1]) - max(out[2,1],out[3,1],out[4,1])

		if ("`fitselect'"=="restricted" & "`bwselect'"=="diff" & `hl'==0) local hl = out[3,1]
		if ("`fitselect'"=="restricted" & "`bwselect'"=="diff" & `hr'==0) local hr = out[3,1]
		if ("`fitselect'"=="restricted" & "`bwselect'"=="sum"  & `hl'==0) local hl = out[4,1]
		if ("`fitselect'"=="restricted" & "`bwselect'"=="sum"  & `hr'==0) local hr = out[4,1]
		if ("`fitselect'"=="restricted" & "`bwselect'"=="comb" & `hl'==0) local hl = min(out[3,1],out[4,1])
		if ("`fitselect'"=="restricted" & "`bwselect'"=="comb" & `hr'==0) local hr = min(out[3,1],out[4,1])
	}
	*** END BANDWIDTH SELECTION ************************************************ 
	****************************************************************************

	qui keep if (-`hl' <= `x'-`c') & (`x'-`c' <= `hr')
	qui replace `x' = `x'-`c'
	
	qui count if `x'<0
	if (`r(N)'<5){
	 display("{err}Not enough observations on the left to perform calculations.")
	 exit(1)
	}
	local Nlh = r(N)

	qui count if `x'>=0
	if (`r(N)'<5){
	 display("{err}Not enough observations on the right to perform calculations.")
	 exit(1)
	}
	local Nrh = r(N)
	local Nh = `Nlh' + `Nrh'

	qui sort `x'

	****************************************************************************
	*** BEGIN MATA ESTIMATION ************************************************** 
	mata{
	X = st_data(.,("`x'"), 0); Y = range(`Nl'-`Nlh'+1,`Nl'+`Nrh',1)/(`N'-1)
	*display("got here!")
	fV_q = rddensity_fv(Y,X,`Nl',`Nr',`Nlh',`Nrh',`hl',`hr',`q',1,"`kernel'","`fitselect'","`vce'")
	T_q  = fV_q[3,1] / sqrt(fV_q[3,2])
	st_numscalar("f_ql", fV_q[1,1]); st_numscalar("f_qr", fV_q[2,1])
	st_numscalar("se_ql", sqrt(fV_q[1,2])); st_numscalar("se_qr", sqrt(fV_q[2,2]))
	st_numscalar("se_q", sqrt(fV_q[3,2]))
	st_numscalar("T_q", T_q); st_numscalar("pval_q", 2*normal(-abs(T_q)))

	if ("`all'"!=""){
		fV_p = rddensity_fv(Y,X,`Nl',`Nr',`Nlh',`Nrh',`hl',`hr',`p',1,"`kernel'","`fitselect'","`vce'")
		T_p  = fV_p[3,1] / sqrt(fV_p[3,2])
		st_numscalar("f_pl", fV_p[1,1]); st_numscalar("f_pr", fV_p[2,1])
		st_numscalar("T_p", T_p); st_numscalar("pval_p", 2*normal(-abs(T_p)))
	}
	*display("Estimation completed.") 
	}
	*** END MATA ESTIMATION **************************************************** 
	****************************************************************************

	****************************************************************************
	*** BEGIN OUTPUT TABLE ***************************************************** 
	disp ""
	disp "RD Manipulation Test using local polynomial density estimation." 

	disp ""
	disp in smcl in gr "{ralign 18: Cutoff c = `c'}" 			_col(19) " {c |}" 	_col(21) in gr "Left of " in ye "c"  		_col(33) in gr "Right of " in ye "c" 	_col(53) in gr "Number of obs = "  in ye %12.0f `N'
	disp in smcl in gr "{hline 19}{c +}{hline 22}"                                                                                                     					_col(53) in gr "Model         = "  in ye "{ralign 12:`fitselect'}"
	disp in smcl in gr "{ralign 18:Number of obs}"        		_col(19) " {c |} " 	_col(21) as result %9.0f `Nl'      			_col(34) %9.0f  `Nr'                   	_col(53) in gr "BW method     = "  in ye "{ralign 12:`bwmethod'}" 
	disp in smcl in gr "{ralign 18:Eff. Number of obs}"   		_col(19) " {c |} " 	_col(21) as result %9.0f `Nlh'     			_col(34) %9.0f  `Nrh'                  	_col(53) in gr "Kernel        = "  in ye "{ralign 12:`kernel'}"
	disp in smcl in gr "{ralign 18:Order est. (p)}" 			_col(19) " {c |} " 	_col(21) as result %9.0f `p'       			_col(34) %9.0f  `p'                    	_col(53) in gr "VCE method    = "  in ye "{ralign 12:`vce'}"
	disp in smcl in gr "{ralign 18:Order bias (q)}"         	_col(19) " {c |} " 	_col(21) as result %9.0f `q'       			_col(34) %9.0f  `q'                             
	disp in smcl in gr "{ralign 18:BW est. (h)}"				_col(19) " {c |} " 	_col(21) as result %9.3f `hl'      			_col(34) %9.3f  `hr'

	disp ""
	disp "Running variable: `x'."
	disp in smcl in gr "{hline 19}{c TT}{hline 27}"
	disp in smcl in gr "{ralign 18:Method}"                		_col(19) " {c |} " _col(27) "    T"          _col(40) "P>|T|" 
	disp in smcl in gr "{hline 19}{c +}{hline 27}"
	if ("`all'"!=""){
		disp in smcl in gr "{ralign 18:Conventional}"      		_col(19) " {c |} " _col(27) in ye %7.4f T_p  _col(39) %7.4f pval_p
	}
	disp in smcl in gr "{ralign 18:Robust}" 					_col(19) " {c |} " _col(27) in ye %7.4f T_q  _col(39) %7.4f pval_q

	disp in smcl in gr "{hline 19}{c BT}{hline 27}"
	disp ""

	if (`hl'>=`c'-`x_min') disp in red "WARNING: bandwidth {it:hl} greater than the range of the data."
	if (`hr'>=`x_max'-`c') disp in red "WARNING: bandwidth {it:hr} greater than the range of the data."
	if (`Nlh'<20 | `Nrh'<20) disp in red "WARNING: bandwidth {it:h} may be too low."
	*** END OUTPUT TABLE ******************************************************* 
	****************************************************************************

	restore

	ereturn clear
	ereturn scalar c = `c'
	ereturn scalar p = `p'
	ereturn scalar q = `q'
	ereturn scalar N_l = `Nl'
	ereturn scalar N_r = `Nr'
	ereturn scalar N_h_l = `Nlh'
	ereturn scalar N_h_r = `Nrh'
	ereturn scalar h_l = `hl'
	ereturn scalar h_r = `hr'
	ereturn scalar f_ql = f_ql
	ereturn scalar f_qr = f_qr
	ereturn scalar se_ql = se_ql
	ereturn scalar se_qr = se_qr
	ereturn scalar se_q = se_q
	ereturn scalar pv_q = pval_q

	if ("`all'"!=""){
		ereturn scalar f_pl = f_pl
		ereturn scalar f_pr = f_pr
		ereturn scalar pv_p = pval_p
	}
	
	ereturn local runningvar "`x'"
	ereturn local kernel = "`kernel'"
	ereturn local bwmethod = "`bwmethod'"
	ereturn local vce = "`vce'"

	mata: mata clear
	
end
	
********************************************************************************
* MAIN PROGRAM
********************************************************************************

capture program drop rddensity

program define rddensity, eclass
	syntax 	varlist(max=1) 			///
			[if] [in] [, 			///
			/* FIRST LIST */		///
			c(real 0) 				///
			p(integer 2) 			///
			q(integer 0) 			///
			fitselect(string) 		///
			kernel(string) 			///
			h(string) 				///
			bwselect(string) 		///
			vce(string) 			///
			all 					///
			/* SECOND LIST */		///
			plot					///
			plot_range(string)		///
			plot_n(string)			///
			plot_grid(string)		///
			graph_options(string)	///
			genvars(string)			///
			level(real 95) 			///
			]

	marksample touse
	
	local x "`varlist'"
	
	****************************************************************************
	*** CALL: RDDENSITY ********************************************************
	if ("`all'" != "") {
		rddensityEST `x' if `touse', ///
			c(`c') p(`p') q(`q') fitselect(`fitselect') kernel(`kernel') h(`h') bwselect(`bwselect') vce(`vce') all
	}
	else {
		rddensityEST `x' if `touse', ///
			c(`c') p(`p') q(`q') fitselect(`fitselect') kernel(`kernel') h(`h') bwselect(`bwselect') vce(`vce')
	}
	
	/// save ereturn results
	local c 			= e(c)
    local p 			= e(p)
	local q 			= e(q)
	local N_l 			= e(N_l)
	local N_r 			= e(N_r)
    local N_h_l 		= e(N_h_l)
    local N_h_r 		= e(N_h_r)
    local h_l 			= e(h_l)
    local h_r 			= e(h_r)
    local f_ql 			= e(f_ql)
    local f_qr 			= e(f_qr)
    local se_ql 		= e(se_ql)
    local se_qr 		= e(se_qr)
    local se_q 			= e(se_q)
    local pv_q 			= e(pv_q)
	
	if ("`all'" != ""){
    local f_pl 			= e(f_pl)
    local f_pr 			= e(f_pr)
    local pv_p 			= e(pv_p)
	}
	
	local vce 			= e(vce)
	local bwmethod 		= e(bwmethod)
    local kernel 		= e(kernel)
    local runningvar 	= e(runningvar)
	****************************************************************************
	*** END CALL: RDDENSITY ****************************************************
	
	****************************************************************************
	*** DEFAULT OPTIONS ********************************************************
	
	// plot_range
	tokenize `plot_range'	
	local w : word count `plot_range'
	if `w' == 0 {
		qui sum `x'
		if (`c' - 3 * `h_l' < r(min)) {
			local plot_range_l = r(min)
		} 
		else {
			local plot_range_l = `c' - 3 * `h_l'
		}
		if (`c' + 3 * `h_r' > r(max)) {
			local plot_range_r = r(max)
		} 
		else {
			local plot_range_r = `c' + 3 * `h_r'
		}
	}
	if `w' == 1 {
		di as error  "{err}{cmd:plot_range()} takes two inputs."  
		exit 125
	}
	if `w' == 2 {
		local plot_range_l `"`1'"'
		local plot_range_r `"`2'"'
	}
	if `w' >= 3 {
		di as error  "{err}{cmd:plot_range()} takes two inputs."  
		exit 125
	}
	
	// plot_n
	tokenize `plot_n'	
	local w : word count `plot_n'
	if `w' == 0 {
		local plot_n_l = 10
		local plot_n_r = 10
	}
	if `w' == 1 {
		di as error  "{err}{cmd:plot_n()} takes two inputs."  
		exit 125
	}
	if `w' == 2 {
		local plot_n_l `"`1'"'
		local plot_n_r `"`2'"'
	}
	if `w' >= 3 {
		di as error  "{err}{cmd:plot_n()} takes two inputs."  
		exit 125
	}
	
	// plot_grid
	if ("`plot_grid'" == "") {
		local plot_grid "es"
	}
	else {
		if ("`plot_grid'" != "es" & "`plot_grid'" != "qs") {
			di as error  "{err}{cmd:plot_grid()} incorrectly specified."  
			exit 125
		}
	}
	
	// level
	if (`level' <= 0 | `level' >= 100) {
	di as err `"{err}{cmd:level()}: incorrectly specified"'
	exit 198
	}
	
	// plot
	if ("`plot'" != "") {
		local plot = 1
		capture which lpdensity
		if (_rc == 111) {
			di as error  `"{err}plotting feature requires command {cmd:lpdensity}, install with"'
			di as error  `"{err}net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace"'
			exit 111
		}
	}
	else {
		local plot = 0
	}
	
	****************************************************************************
	*** END DEFAULT OPTIONS ****************************************************

	****************************************************************************
	*** CALL: LPDENSITY ********************************************************
	if (`plot' == 1) {
		
		if (`plot_n_l' + `plot_n_r' > _N) {
			local newN = `plot_n_l' + `plot_n_r'
			set obs `newN'
		}
		tempvar temp_grid
		qui gen `temp_grid' = .
		tempvar temp_bw
		qui gen `temp_bw' = .
		tempvar temp_f
		qui gen `temp_f' = .
		tempvar temp_cil
		qui gen `temp_cil' = .
		tempvar temp_cir
		qui gen `temp_cir' = .
		tempvar temp_group
		qui gen `temp_group' = .
		
	}
	
	// MATA
	mata{	
	ng = `plot_n_l' + `plot_n_r'
	if (`plot' == 1) {
		// generate grid
		if ("`plot_grid'" == "es") {
			grid = ( rangen(`plot_range_l', `c' - ( (`c' - `plot_range_l') / (`plot_n_l' - 1) ), `plot_n_l' - 1) \ `c' \ `c' \ rangen(`c' + ( (`plot_range_r' - `c') / (`plot_n_r' - 1) ), `plot_range_r', `plot_n_r' - 1) )
		} else {
			x = st_data(., "`x'", "`touse'")
			temp1 = mean(x :<= `plot_range_l')
			temp2 = mean(x :<= `c')
			temp3 = mean(x :<= `plot_range_r')
			grid = ( rangen(temp1, temp2 - ( (temp2 - temp1) / (`plot_n_l' - 1) ), `plot_n_l' - 1) \ temp2 \ temp2 \ rangen(temp2 + ( (temp3 - temp2) / (`plot_n_r' - 1) ), temp3, `plot_n_r' - 1) )
			for (j=1; j<=length(grid); j++) {
				grid[j] = rddensity_quantile(x, grid[j])
			}
			grid[`plot_n_l'] = `c'
			grid[`plot_n_l' + 1] = `c'
		}
		
		// generate group
		group = ( J(`plot_n_l', 1, 0) \ J(`plot_n_r', 1, 1) )
		// generate bandwidth
		bw = ( J(`plot_n_l', 1, `h_l') \ J(`plot_n_r', 1, `h_r') )

		st_store((1..ng)', "`temp_grid'", grid)
		st_store((1..ng)', "`temp_group'", group)
		st_store((1..ng)', "`temp_bw'", bw)
	}
	}
	
	if (`plot' == 1) {
	local scale_l = (`N_l' - 1) / (`N_l' + `N_r' - 1)
	local scale_r = (`N_r' - 1) / (`N_l' + `N_r' - 1)
	
	// left estimation
	tempvar temp_grid_l
		qui gen `temp_grid_l' = `temp_grid' if `temp_group' == 0
	tempvar temp_bw_l
		qui gen `temp_bw_l' = `temp_bw' if `temp_group' == 0
	
	qui lpdensity `x' if `touse' & `x' <= `c', /// 
		grid(`temp_grid_l') bw(`temp_bw_l') p(`p') q(`q') v(1) kernel(`kernel') scale(`scale_l') level(`level') 
	}
		
	mata{
	if (`plot' == 1) {
		left = st_matrix("e(result)")
		st_store((1..`plot_n_l')', "`temp_f'", 	 left[., 4])
		st_store((1..`plot_n_l')', "`temp_cil'", left[., 8])
		st_store((1..`plot_n_l')', "`temp_cir'", left[., 9])
	}
	}
	
	if (`plot' == 1) {
	// right estimation
	tempvar temp_grid_r
		qui gen `temp_grid_r' = `temp_grid' if `temp_group' == 1
	tempvar temp_bw_r
		qui gen `temp_bw_r' = `temp_bw' if `temp_group' == 1
	
	qui lpdensity `x' if `touse' & `x' >= `c', /// 
		grid(`temp_grid_r') bw(`temp_bw_r') p(`p') q(`q') v(1) kernel(`kernel') scale(`scale_r') level(`level') 
	}
	
	mata{
	if (`plot' == 1) {
		right = st_matrix("e(result)")
		st_store(((`plot_n_l'+1)..(`plot_n_l'+`plot_n_r'))', "`temp_f'",   right[., 4])
		st_store(((`plot_n_l'+1)..(`plot_n_l'+`plot_n_r'))', "`temp_cil'", right[., 8])
		st_store(((`plot_n_l'+1)..(`plot_n_l'+`plot_n_r'))', "`temp_cir'", right[., 9])
	}
	}
		
	if ("`genvars'" != "" & `plot' == 1) {
		qui gen `genvars'_grid 	= `temp_grid'
		qui gen `genvars'_bw 	= `temp_bw'
		qui gen `genvars'_f 	= `temp_f'
		qui gen `genvars'_cil 	= `temp_cil'
		qui gen `genvars'_cir 	= `temp_cir'
		qui gen `genvars'_group = `temp_group'
		label variable `genvars'_grid	"rddensity plot: grid"
		label variable `genvars'_bw		"rddensity plot: bandwidth"
		label variable `genvars'_f		"rddensity plot: point estimate"
		label variable `genvars'_cil	"rddensity plot: `level'% CI, left"
		label variable `genvars'_cir	"rddensity plot: `level'% CI, right"
		label variable `genvars'_group	"rddensity plot: =1 if grid >= `c'"
	}
	****************************************************************************
	*** END CALL: LPDENSITY ****************************************************

	if (`plot' == 1) {
	
		if (`"`graph_options'"'=="" ) local graph_options = `"title("rddensity plot (p=`p', q=`q')", color(gs0)) xtitle("`x'") ytitle("")"'
		twoway 	(rarea `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 0, sort color(gs12)) ///
				(rarea `temp_cil' `temp_cir' `temp_grid' if `temp_group' == 1, sort color(gs12)) ///
				(line `temp_f' `temp_grid' if `temp_group' == 0,  lcolor(black) sort lwidth(medthin) lpattern(solid)) ///
				(line `temp_f' `temp_grid' if `temp_group' == 1,  lcolor(black) sort lwidth(medthin) lpattern(solid)), ///
				xline(`c', lcolor(black) lwidth(medthin) lpattern(solid)) legend(cols(2) order(3 "point estimate" 1 "`level'% C.I." )) `graph_options'
	}
	
	ereturn clear 
	ereturn scalar c = `c' 
	ereturn scalar p = `p' 
	ereturn scalar q = `q' 
	ereturn scalar N_l = `N_l' 
	ereturn scalar N_r = `N_r'
	ereturn scalar N_h_l = `N_h_l' 
	ereturn scalar N_h_r = `N_h_r'
	ereturn scalar h_l = `h_l'
	ereturn scalar h_r = `h_r'
	ereturn scalar f_ql = `f_ql'
	ereturn scalar f_qr = `f_qr'
	ereturn scalar se_ql = `se_ql'
	ereturn scalar se_qr = `se_qr'
	ereturn scalar se_q = `se_q'
	ereturn scalar pv_q = `pv_q'

	if ("`all'"!=""){
	ereturn scalar f_pl = `f_pl'
	ereturn scalar f_pr = `f_pr'
	ereturn scalar pv_p = `pv_p'
	}
	
	ereturn local runningvar  "`runningvar'"
	ereturn local kernel  "`kernel'"
	ereturn local bwmethod  "`bwmethod'"
	ereturn local vce  "`vce'"
	
	mata: mata clear
	
end
	
