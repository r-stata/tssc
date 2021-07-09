cap prog drop scale_transformation
prog def scale_transformation
	version 13
	syntax, Type(integer) score1(varname numeric) score2(varname numeric) ///
	[COMPGroup(varname numeric) ///
	CONTrols(varlist numeric) controls1(varlist numeric) controls2(varlist numeric) Weights(varname numeric) ///
	ITERations(integer 1000) MAXOPTITERations(integer 25) BOUNDDown(integer -1500) BOUNDUp(integer 1500) ///
	SINGHMEThod(integer 1) MONOtonicity(integer 1) monofile(string) timeroff save(string) seed(integer -987654321) ///
	robust(integer 0)]
	
	** Initial checks
	if inlist(`type',1,2,7)==1 & "`compgroup'"=="" {
		di ""
		di as err "Error:  Variable compgroup should be specified if type is 1, 2 or 7."
		e
		}
	if "`compgroup'"!="" {
		if !mod(`compgroup',1)==0 | `compgroup'<0 {
			di ""
			di as err "Error: Variable compgroup should only take on integers greater or equal to 0"
			exit
			}
		if inlist(`type',3,4,5,6)==1  {
			di ""
			di as err "Error:  Variable compgroup should NOT be specified if type is 3, 4, 5 or 6."
			e
			}
		}
	if inlist(`type',1,2,3,4,5,6,7)==0 {
		di ""
		di as err "Error: Type should be 1 and 2 for Gap Growth max and min; 3 and 4 for Correlation max and min; 5 and 6 for R-squared max and min; or 7 for Controls Explanation Index max, respectively."
		e
		}
	if inlist(`type',7)==1 & ("`controls'"=="" & "`controls1'"=="" & "`controls2'"=="")  {
		di ""
		di as err "Error: At least one control variable needed (i.e. controls1 or controls2) for Controls Explanation max"
		e
		}
	if inlist(`type',3,4,5,6)==1 & ("`controls'"!="" | "`controls1'"!="" | "`controls2'"!="")  {
		di ""
		di as err "Error: Control variables not allowed for Correlation or R-squared max and min"
		e
		}
	if inlist(`singhmethod',1,2)==0 { 
		di ""
		di as err "Error: Singular H Method should be 1 for `"`"hybrid"'"' (recommended), a mixture of steepest descent and Newton, or 2 for modified Marquardt algorithm"
		e
		}
	if `iterations'<=0 {
		di ""
		di as err "Error: Iterations should be greater than 0"
		e
		}
	if inlist(`monotonicity',1,2,3)==0 {
		di ""
		di as err "Error: Monotonicity check should be 1 for Standard, 2 for Sample, or 3 for External"
		e
		}
	if `monotonicity'==3 & "`monofile'"=="" {
		di ""
		di as err " Error: Monotonicity filename should be specified if monotonicity check is to use external file"
		e 
		}
	if `monotonicity'!=3 & "`monofile'"!="" {
		di ""
		di as err "Error: Monotonicity filename specified when monotonicity check is NOT set to use external file"
		e 
		}
	if `seed'!=-987654321 & (`seed'<0 | `seed'>2147483647) {
		di ""
		di as err "Error: Seed should be an integer greater or equal to 0 and less or equal to 2,147,483,647."
		e 
		}		
	if ( `score1'<0 | (`score1'>1 & `score1'!=.) ) | ( `score2'<0 | (`score2'>1 & `score2'!=.) ) {
		qui sum `score1'
		local s1min = r(min)
		local s1max = r(max)
		qui sum `score2'
		local s2min = r(min)
		local s2max = r(max)
		local max = ceil(max(`s1max',`s2max'))
		local min = floor(min(`s1min',`s2min'))
		qui replace `score1' = (`score1'-`min') / (`max'-`min')
		qui replace `score2' = (`score2'-`min') / (`max'-`min')
			if ( `score1'<0 | (`score1'>1 & `score1'!=.) ) | ( `score2'<0 | (`score2'>1 & `score2'!=.) ) {
				di ""
				di as err "Error: Re-scaling of variables `score1' and `score2' to be between 0 and 1 did not work." "Please re-scale them manually."
				e
				}
		}
	if `robust'!=0 & (`robust'<20 | `robust'>300 | mod(`robust',2)==1) {
		di ""
		di as err "Error: Robust option should only contain even, positive integers greater or equal to 20 and less than 300."
		di as err "This additional number of max/min iterations (half each) should allow for enough sign checks."
		e 
		}
	if `robust'!=0 & (`robust'>=20 & `robust'<=300 & mod(`robust',2)==0) & inlist(`type',3,4,5,6,7)==1  {
		di ""
		di as err "Error:  Robust option can only be specify with Gap Growth Max or Min (i.e. type is 1 or 2)."
		e
		} 
	
	** Save using DTA
	qui {
		set more off
		timer clear
		timer on 1
		mata: mata clear
		marksample touse
		keep if `touse'
		tempfile theData
		save `theData', replace
		clear
		}
	
	** Locals
	if `seed'==-987654321 {
		local seed = round(uniform()*100000000)
		}
	set seed `seed'
	local today_str = string(date("`c(current_date)'","DMY"),"%tdCCYYNNDD") + "_" + subinstr(substr("`c(current_time)'",1,5),":","h_",1) + "m"
	local curdir : pwd
	m: type = `type'
	if `type'==1 | `type'==2 {
		local type2 = "Gap_Growth"
		}
	else if `type'==3 | `type'==4 {
		local type2 = "Correlation"
		}
	else if `type'==5 | `type'==6 {
		local type2 = "R-squared"
		}
	else if `type'==7 {
		local type2 = "Explanation"
		}
	if `type'==1 | `type'==3 | `type'==5 | `type'==7 {
		local type = "max"
		}
	else if `type'==2 | `type'==4 | `type'==6 {
		local type = "min"
		}
	if `singhmethod'==1 {
		local singhmethod = "hybrid"
		}
	else if `singhmethod'==2 {
		local singhmethod = "m-marquardt"
		}
	if `monotonicity'==1 {
		local montype = "Standard"
		}
	else if `monotonicity'==2 {
		local montype = "Sample"
		}
	else if `monotonicity'==3 {
		local montype = "External"
		}
	local timer_status = "On"
	if "`timeroff'"=="timeroff" local timer_status = "Off"
	local n_controls: word count `controls'	
	local weights_status = "No"
	if "`weights'"!="" local weights_status = "Yes"
	local robust_status = "No"
	if `robust'>0 local robust_status = "Yes (`robust' iterations)"

	
	di "" _newline(1)
	di in y "**************************************************************"
	di in y "Optimization Type: " proper("`type'") " " proper("`type2'")
	di in y "Seed Number (for replication): `seed'" 
	di in y "Singular H Method: " proper("`singhmethod'")
	di in y "Monotonicity check: `montype'"
	di in y "Control variables: `n_controls'"
	di in y "Weights: `weights_status'"
	di in y "Timer: `timer_status'"
	di in y "Robust option: `robust_status'"
	
	
	** Gen random starting parameters
	if `robust'>0 {
		local iterations = `iterations' + `robust'
		}
	qui set obs `iterations'
	foreach param in a b c d e f g {
		gen `param' = runiform(`bounddown',`boundup')
		}

	m: init_params=st_data(.,.)	
	qui count
	local obs = `r(N)'
	
	* Restore data
	use `theData', clear
	
	* Create control for others not in comparisons groups
	if "`compgroup'"!="" {
		qui {
			sum `compgroup'
			local compgroupmin= `r(min)'
			local compgroupmax= `r(max)'
			levelsof `compgroup', local(theGroups)
			foreach x of local theGroups {
				gen temp_g`x' = (`compgroup'==`x')
				}
			local gmin = "temp_g`compgroupmin'"
			local gmax = "temp_g`compgroupmax'"
			gen temp_other_group_crtl = (`compgroup'!=`compgroupmin' & `compgroup'!=`compgroupmax')
			}
		}
	else {
		qui gen temp_other_group_crtl = .
		}
	
	* Create weights = 1 if no weights specified
	if "`weights_status'" == "No" {
		qui gen temp_weight = 1
		local weights "temp_weight"
		}
	* Import external monotonicity data, if available
	preserve
		qui {
			if `monotonicity'==3 {
				if regexm("`monofile'","dta$") {
					use "`monofile'", clear 
					}
				else if regexm("`monofile'","xls$") | regexm("`monofile'","xlsx$") {
					import excel "`monofile'", clear firstrow
					}
				else if regexm("`monofile'","csv$") {
					import delimited "`monofile'", clear varnames(1) case(lower)
					}
				ds
				tokenize `r(varlist)'
				local monovar = "`1'"
				di "`monovar'"
				keep `monovar'
				sort `monovar'
				drop if `monovar'==.
				m: mono_data = st_data(.,.,("`monovar'"))
				m: mono_data = uniqrows(mono_data)
				}
			else if `monotonicity'==2 {
				m: mono_data = ("a","a")
				}
			else if `monotonicity'==1 {
				m: st_view(irt1=.,.,("`score1'"))
				m: mono_data = J(rows(irt1),0,.)
				}
			}
	restore	
	* Prepare for grid search
	m {
		st_view(sesgroup=.,.,("`gmax' temp_other_group_crtl"))
		st_view(irt1=.,.,("`score1'"))
		st_view(irt2=.,.,("`score2'"))
		st_view(w=.,.,("`weights'"))
		st_view(controls=.,.,("`controls'"))
		st_view(c1=.,.,("`controls1'"))
		st_view(c2=.,.,("`controls2'"))
		results = J(0,17,.)
		results_robust = J(0,17,.)
		}

	
	* Robustness test max/min N observations
	if `robust'>0 {
		
		forv row = 1/`robust' {
			local half = `robust'/2
			local half_plus = `half'+1
			if `row'<=`half' local rtype "max"
			if `row'>`half' local rtype "min"
			
			m: init_cond = init_params[`row',1..7]
			m: S=optimize_init()
			m: optimize_init_evaluator(S, &objf())
			m: optimize_init_evaluatortype(S,"d0")
			m: optimize_init_which(S, "`rtype'")
			m: optimize_init_argument(S,1,sesgroup)
			m: optimize_init_argument(S,2,irt1)
			m: optimize_init_argument(S,3,irt2)
			m: optimize_init_argument(S,4,controls)
			m: optimize_init_argument(S,5,c1)
			m: optimize_init_argument(S,6,c2)
			m: optimize_init_argument(S,7,w)
			m: optimize_init_argument(S,8,mono_data)
			m: optimize_init_argument(S,9,type)
			m: optimize_init_singularHmethod(S,"`singhmethod'")
			m: optimize_init_trace_params(S,"on")
			m: optimize_init_conv_maxiter(S,`maxoptiterations')
			m: optimize_init_verbose(S,0)
			m: optimize_init_params(S, init_cond) 
				
			di ""  _newline(1) 	
			local RTYPE = upper("`rtype'")
			di "Optimizing - Iteration `row'/`robust' ROBUST `RTYPE'"  _newline(1) 
			cap noi m: _optimize(S)
			
			m: row = strtoreal("`row'")
			m: conditional(row,results_robust,S)
					
			if `c(rc)'==1 {
				qui cap drop temp_g* temp_other_group_crtl temp_weight
				error(1)
				e
				}
			}

		preserve
			clear
			getmata (obj b1 b2 b3 b4 b5 b6 c init_b1 init_b2 init_b3 init_b4 init_b5 init_b6 init_c gapgrowth nc_gapgrowth) = results_robust, double
			qui sum obj if _n<=`half'
			local max_avg = `r(mean)'
			qui sum obj if _n>`half'
			local min_avg = `r(mean)'
			if ("`type'"=="max" & `max_avg'>`min_avg') {
				local type "max"  
				m: results = results_robust[1..`half',.]
				}
			if ("`type'"=="max" & `min_avg'>`max_avg') {
				local type "min"  
				m: results = results_robust[`half_plus'..`robust',.]
				}
			if ("`type'"=="min" & `max_avg'>`min_avg') {
				local type "min"  
				m: results = results_robust[`half_plus'..`robust',.]
				}
			if ("`type'"=="min" & `min_avg'>`max_avg') {
				local type "max"  
				m: results = results_robust[1..`half',.]				
				}
			local TYPE = upper("`type'")
		restore
		}
	
	* Run loop using random sets of initial parameters
	local start = 1
	if `robust'>0  {
		local start = 1+`robust'
		}
		
	local counter = 0
	forv row = `start'/`obs' {
		local ++counter
		local denom = `obs'-`robust'
		m {
			init_cond = init_params[`row',1..7]
			S=optimize_init()
			optimize_init_evaluator(S, &objf())
			optimize_init_evaluatortype(S,"d0")
			optimize_init_which(S, "`type'")
			optimize_init_argument(S,1,sesgroup)
			optimize_init_argument(S,2,irt1)
			optimize_init_argument(S,3,irt2)
			optimize_init_argument(S,4,controls)
			optimize_init_argument(S,5,c1)
			optimize_init_argument(S,6,c2)
			optimize_init_argument(S,7,w)
			optimize_init_argument(S,8,mono_data)
			optimize_init_argument(S,9,type)
			optimize_init_singularHmethod(S,"`singhmethod'")
			optimize_init_trace_params(S,"on")
			optimize_init_conv_maxiter(S,`maxoptiterations')
			optimize_init_verbose(S,0)
			optimize_init_params(S, init_cond)
			}
		di ""  _newline(1) 	
		di "Optimizing - Iteration `counter'/`denom'"  _newline(1) 
		cap noi m: _optimize(S)

		m {
			if (optimize_result_errorcode(S)==0) {
				p =  optimize_result_params(S)
				max_min = optimize_result_value(S)
				init_vals = optimize_init_params(S)
				if ("`nc_gapgrowth'"!="") {
					nc_gapgrowth = strtoreal("`nc_gapgrowth'")
					}
				else {
					nc_gapgrowth= J(1,1,.)
					}
				if ("`gapgrowth'"!="") {
					gapgrowth = strtoreal("`gapgrowth'")
					}
				else {
					gapgrowth= J(1,1,.)
					}
				results = results \ (max_min, p , init_vals, nc_gapgrowth, gapgrowth)
				}
			if (optimize_result_errorcode(S)!=0) {
				p =  J(1,7,.)
				max_min = J(1,1,.)
				nc_gapgrowth= J(1,1,.)
				gapgrowth = J(1,1,.)
				init_vals = optimize_init_params(S)
				results = results \ (max_min, p , init_vals, nc_gapgrowth, gapgrowth)
				}
			results
			S=optimize_init()
			}
	
		if `c(rc)'==1 {
			qui cap drop temp_g* temp_other_group_crtl temp_weight
			error(1)
			e
			}
		}
	
	* Save results into Stata
	clear
	getmata (obj b1 b2 b3 b4 b5 b6 c init_b1 init_b2 init_b3 init_b4 init_b5 init_b6 init_c gapgrowth nc_gapgrowth) = results, double
	qui foreach var in gapgrowth nc_gapgrowt {
		count if `var'!=.
		if r(N)==0 drop `var' 
		}
	m: mata clear
	di "" 
 	di "**** Program (finally!) completed :) ****"
	if "`save'"!="" {
		save `save', replace
		}
	
	qui {
		timer off 1
		timer list
		}
	if "`timer_status'"=="On" {
		di "" 	
		di in y "Total program time: " round(r(t1)/60,.01) " minutes"
		}
		
	end


	** Define optimization functions 

m
	/*Optimization function*/
	void function objf(todo, p, sesgroup, irt1, irt2, controls, c1, c2, w, mono_data, type, obj, g, H) {

		real vector s_irt1
		real vector s_irt2
		real vector b_irt1
		real vector b_irt2
		real vector nc_b_irt1
		real vector nc_b_irt2
		real vector scores
		real vector r
		real vector Z
		real vector V
		real vector s_irt1_pred

		real matrix X
		real matrix X1
		real matrix X2
	   
		real scalar gap_irt1
		real scalar gap_irt2
		real scalar nc_gap_irt1
		real scalar nc_gap_irt2
		real scalar i
		real scalar b_corr
		real scalar gapgrowth
		real scalar nc_gapgrowth

	   
		r = p
	   
		s_irt1= r[1]:*(irt1:+r[7]) + r[2]:*(irt1:+r[7]):^2 + r[3]:*(irt1:+r[7]):^3 + r[4]:*(irt1:+r[7]):^4 + r[5]:*(irt1:+r[7]):^5 + r[6]:*(irt1:+r[7]):^6
		s_irt2 = r[1]:*(irt2:+r[7]) + r[2]:*(irt2:+r[7]):^2 + r[3]:*(irt2:+r[7]):^3 + r[4]:*(irt2:+r[7]):^4 + r[5]:*(irt2:+r[7]):^5 + r[6]:*(irt2:+r[7]):^6
		
		s_irt_comb = s_irt1 \ s_irt2
		mean_s_irt_comb = mean(s_irt_comb)
		var_s_irt_comb = variance(s_irt_comb)
		s_irt_comb = (s_irt_comb:-mean_s_irt_comb):/(var_s_irt_comb^.5)
		
		s_irt1 = s_irt_comb[1..rows(s_irt1),.]
		s_irt2 = s_irt_comb[rows(s_irt1)+1..rows(s_irt_comb),.]
		
		
		/*Optimization Objects*/		
		if (type==1|type==2) {
			X1 = (sesgroup,controls,c1)
			X1 = (X1,J(rows(X1),1,1))
			b_irt1 = invsym(cross(X1,w,X1))*cross(X1,w,s_irt1)
			X2 = (sesgroup,controls,c2)
			X2 = (X2,J(rows(X2),1,1))
			b_irt2 = invsym(cross(X2,w,X2))*cross(X2,w,s_irt2)
			gap_irt1 = b_irt1[1]
			gap_irt2 = b_irt2[1]
			if (gap_irt1<0) {
				obj = -(gap_irt2 - gap_irt1)
				}
			else {
				obj = gap_irt2 - gap_irt1
				}
			}
		else if (type==3|type==4) {
			Z = (s_irt2,J(rows(s_irt2),1,1))
			b_corr = invsym(cross(Z,w,Z))*cross(Z,w,s_irt1)
			obj = b_corr[1]
			}
		else if (type==5|type==6) {
			V = (s_irt1,s_irt2)
			obj = correlation(V,w)
			obj = obj[1,2]^2
			}
		else {
			X = (sesgroup,controls)
			X = (X,J(rows(X),1,1))
			nc_b_irt1 = invsym(cross(X,w,X))*cross(X,w,s_irt1)
			nc_b_irt2 = invsym(cross(X,w,X))*cross(X,w,s_irt2)
			nc_gap_irt1 = nc_b_irt1[1]
			nc_gap_irt2 = nc_b_irt2[1]
			if (nc_gap_irt1<0) {
				nc_gapgrowth = -(nc_gap_irt2 - nc_gap_irt1)
				}
			else {
				nc_gapgrowth = nc_gap_irt2 - nc_gap_irt1
				}
			st_local("nc_gapgrowth",strofreal(nc_gapgrowth))
			X1 = (sesgroup,controls,c1)
			X1 = (X1,J(rows(X1),1,1))
			b_irt1 = invsym(cross(X1,w,X1))*cross(X1,w,s_irt1)
			X2 = (sesgroup,controls,c2)
			X2 = (X2,J(rows(X2),1,1))
			b_irt2 = invsym(cross(X2,w,X2))*cross(X2,w,s_irt2)
			gap_irt1 = b_irt1[1]
			gap_irt2 = b_irt2[1]
			if (gap_irt1<0) {
				gapgrowth = -(gap_irt2 - gap_irt1)
				}
			else {
				gapgrowth = gap_irt2 - gap_irt1
				}
			st_local("gapgrowth",strofreal(gapgrowth))
			obj = abs(nc_gapgrowth - gapgrowth)
			}
		
			
		/*Monotonicity Checks*/
			if (cols(mono_data)==1) {
						scores = mono_data'
						}
			else if (cols(mono_data)==2) {
						scores = (irt2 \ irt1)
						scores =  uniqrows(scores)
						scores = scores[1..rows(scores)-1,.]
						scores = scores'
						}
			else { 
				scores = J(1,round(10000*max(irt2))-round(10000*min(irt1))+2,0)
				for (i=1; i<=cols(scores); i++) {
					scores[i]= round(10000*min(irt1)) + i -2 
					}
				scores = scores:/10000
				}
		
		scores = r[1]:*(scores:+r[7]) + r[2]:*(scores:+r[7]):^2 + r[3]:*(scores:+r[7]):^3 + r[4]:*(scores:+r[7]):^4 + r[5]:*(scores:+r[7]):^5 + r[6]:*(scores:+r[7]):^6
		
		scores = scores[| 1,2 \ .,. |]:-scores[| 1,1 \ .,cols(scores)-1 |]
		scores =  rowmin(scores)
		
		if (type==2|type==4|type==6) {
			if (scores<0) obj = obj + 1
			}
		else {
			if (scores<0) obj = obj - 1
			}
	   }

end  

m	
	/*Conditional Sub-routine (needed as the if-loop breaks without it)*/
	void conditional(row,results_robust,S) {

		real scalar p
		real scalar nc_gapgrowth
		real scalar gapgrowth
		
		real matrix max_min
		real matrix init_vals

		if (optimize_result_errorcode(S)==0) {
				p =  optimize_result_params(S)
				max_min = optimize_result_value(S)
				init_vals = optimize_init_params(S)
				nc_gapgrowth= J(1,1,.)
				gapgrowth= J(1,1,.)
				
				results_robust = results_robust \ (max_min, p , init_vals, nc_gapgrowth, gapgrowth)
			}
		
		else {
				p =  J(1,7,.)
				max_min = J(1,1,.)
				nc_gapgrowth= J(1,1,.)
				gapgrowth = J(1,1,.)
				init_vals = optimize_init_params(S)
				results_robust = results_robust \ (max_min, p , init_vals, nc_gapgrowth, gapgrowth)
				}

		results_robust
		S=optimize_init() 
		}
end
