*! version 1.1 02june2021 Matteo Pinna, matteo.pinna@gess.ethz.ch
* version 1.1 adds diagnostics for the perturbationtest, modifies/adds the display and command options, introduces the first option and sets regressions to run quietly by default for tests.
* Any feedback on issues and possible new features is very welcome.

cap program drop multicoefplot
program define multicoefplot, rclass sortpreserve

	version 15.1
	syntax namelist(min=1 max=1) [if] [in],    ///
	/* mandatory options */	 window(string) TREATMENT1(string) 	[  ///
	/* regression */ noCONStant savetables(string) savetex(string) level(string) first ///
	/* treatment */  treatment2(string) treatment3(string) ///
	/* FE's */ ABSORB1(string) absorb2(string) absorb3(string)  ///
	/* controls */ CONTROLS1(varlist) controls2(varlist) controls3(varlist) ///
	/* time controls */ TIMECONTROLS1(string) timecontrols2(string) timecontrols3(string) ///
	/* time absorb */ TIMEABSORB1(string) timeabsorb2(string) timeabsorb3(string) ///
	/* standard errors */ CLUSTER1(varname) VCE1(string) cluster2(varname) vce2(string) cluster3(varname) vce3(string) ///
	/* weights */ AWEIGHT1(varname) FWEIGHT1(varname) aweight2(varname) fweight2(varname) aweight3(varname) fweight3(varname) ///
	/* fstatistic tuplestest multitest leaveoneouttest and perturbationtest */ fstat tuplestest(varlist) multitest(string) perturbationtest(varname) leaveoneouttest(string) testcicolor(string) testcoefcolor(string) ///
	/* graph options */ time(string) SPECCOLOR1(string) speccolor2(string) speccolor3(string) offset(string) legend(string) symbols COMmand DIsplay ///
	SYMBOL1(string) symbol2(string) symbol3(string) ytitle(string) xtitle(string) yline(string) xline(string) ysize(string) xsize(string) xlabel(string) ylabel(string) ///
	]

	set more off
	* check programs
	* addplot check
	capt which coefplot
	if _rc !=0 {
	di as error "Multicoefplot requires coefplot to be installed. Coefplot can be installed by typing ssc install coefplot"
	}
	capt which reghdfe
	if _rc !=0 {
	di as error "Multicoefplot requires reghdfe to be installed. Reghdfe can be installed by typing ssc install reghdfe"
	}
	capt which ivreghdfe
	if _rc !=0 {
	di as error "Multicoefplot requires ivreghdfe to be installed. Ivreghdfe can be installed by typing ssc install ivreghdfe"
	}
	capt which tuples
	if _rc !=0 {
	di as error "Multicoefplot requires tuples to be installed. Tuples can be installed by typing ssc install tuples"
	}
	
	* Parse varlist into y-vars and x-var
	local y_vars=regexr("`namelist'"," `x_var'$","")
	local ynum=wordcount("`y_vars'")
	
	* Quiet for tests
	if ("`display'"=="") local display "qui"
	if ("`display'"=="display") local display ""
	
	* level perturbation
	if ("`level'"!="") local level_pt=`level'
	if ("`level'"=="") local level_pt=0.05
	
	* window parsing
	/* wip
	local forv_win1=strpos("`window'","(")
	local forv_win2=strpos("`window'","/")
	local forv_win3=strpos("`window'","to")
	local forv_win4=strpos("`window'",":")
	local forv_win=forv_win1+forv_win2+forv_win3+forv_win4
	*/
	
	local win_iter_counter=0
		forvalues win_iteration = `window' {
		local win_iter_counter=`win_iter_counter'+1
		if (`win_iter_counter'==1) local start=`win_iteration'
		if (`win_iter_counter'==2) local second=`win_iteration'
		local end=`win_iteration'
		}
	
	local window_rhs=subinstr("`window'","`start'","",1)
	* to think about ---- if ("`second'"=="") local second=`start'
	* OLD local start `: word 1 of `window''
	* OLD local end `: word 2 of `window''
	
	* errors and warnings
		
		* balanced outcome
		forvalues interval=`window'{
		capture confirm variable `y_vars'`interval'
			if _rc {
			di as error "`y_vars'`interval' does not exist - please include a balanced outcome variable"
			exit
			}
		}
		* balanced and time controls
			if ("`timecontrols1'"!="")|("`timecontrols2'"!="")|("`timecontrols3'"!="") {	   
			di as text "WARNING: timecontrols should always be checked to be balanced over the time of analysis"
			}
			if ("`treatment1'"=="") {	   
			di as error "Treatment1 must be specified"
			exit
			}			
		* TESTS
			if ("`tuplestest'"!="")&(("`multitest'"!="")|("`leaveoneouttest'"!="")|("`perturbationtest'"!="")) {	   
			di as error "Only one test at the time can be performed"
			exit
			}
			if ("`multitest'"!="")&(("`leaveoneouttest'"!="")|("`perturbationtest'"!="")) {	   
			di as error "Only one test at the time can be performed"
			exit
			}
			if ("`leaveoneouttest'"!="")&("`perturbationtest'"!="") {	   
			di as error "Only one test at the time can be performed"
			exit
			}					
			if ("`multitest'"!="") {	   
			di as text "WARNING: global names for the multitest should be as short as possible e.g. var1 or v1"
			}	
			
			if ("`tuplestest'"!="")|("`multitest'"!="")|("`perturbationtest'"!="")|("`leaveoneouttest'"!="") {	
				forvalues num=2/3{
					if ("`treatment`num''"!="")|("`absorb`num''"!="")|("`timecontrols`num''"!="")|("`controls`num''"!="")|("`cluster`num''"!="")|("`vce`num''"!="")|("`aweight`num''"!="")|("`fweight`num''"!="")|("`speccolor`num''"!=""){
					di as error "Only options for specification 1 can be specified when running a test"
					exit
					}
				}
			}		
			if ("`time'"!="") {	  
				if ("`time'"!="year")&("`time'"!="month")&("`time'"!="week")&("`time'"!="day") {	   
				di as error "WARNING: time can be either year, month, week or day"
				}
			}

	* which specs have to be run (SPECIFICATION 1 has to be run to run 2 and/or 3))
		forvalues spec = 1/3{
			if "`treatment`spec''"!="" | "`aweight`spec''"!="" | "`fweight`spec''"!="" | "`absorb`spec''"!="" | "`timecontrols`spec''"!="" | "`controls`spec''"!="" | "`vce`spec''"!="" | "`cluster`spec''"!="" {
			local spec_num`spec'="1"
			}
		}
		if "`spec_num1'"=="1" & "`spec_num2'"=="" & "`spec_num3'"==""{
		local spec_to_run="1/1"
		}
		if "`spec_num1'"=="1" & "`spec_num2'"=="1" & "`spec_num3'"==""{
		local spec_to_run="1/2"
		}
		if "`spec_num1'"=="1" & "`spec_num2'"=="" & "`spec_num3'"=="1"{
		local spec_to_run="1(2)3"
		}
		if "`spec_num1'"=="1" & "`spec_num2'"=="1" & "`spec_num3'"=="1"{
		local spec_to_run="1/3"
		}

	* length of window
		forvalues spec = `spec_to_run' {
		local win_length`spec'=wordcount("`treatment`spec''")
		}
	
	
	* If the specification is created, non-specified necessary elements (treatment) from specs 2 and 3 are replaced with those of the first spec
		forvalues num=2/3{
			if "`spec_num`num''"=="1"{
				if 	"`treatment`num''"=="" & "`treatment1'"!=""{
				local treatment`num'="`treatment1'"
				}
			}
		}
		
	* which regtype to run based on the string in the treatment and makes modification depending on 2sls or ols and whether the treatment (or iv are time-varying)

		forvalues spec = `spec_to_run' {
		local timepos`spec'=strpos("`treatment`spec''","varying(")
		* time option not specified
			if ("`timepos`spec''"=="0") {
			local equal`spec'= strpos("`treatment`spec''","=")
			local equalm1`spec'= `equal`spec''-1
				* 2sls
				if ("`equal`spec''"!="0") {
				local regtype`spec'="ivreghdfe"
				local treatmentstring`spec'="(`treatment`spec'')"
				local treatmentbeta`spec'=substr("`treatment`spec''",1,`equalm1`spec'')
				}
				* no 2sls
				if ("`equal`spec''"=="0") {
				local regtype`spec'="reghdfe"
				local treatmentstring`spec'="`treatment`spec''"
				local treatmentbeta`spec'="`treatment`spec''"
				}
			}
		* time option specified 
			if ("`timepos`spec''"!="0") {
			local starttimetreatments`spec'=`timepos`spec''+8
			local   endtimetreatments`spec'=length("`treatment`spec''")-`starttimetreatments`spec''
			local equal`spec'= strpos("`treatment`spec''","=")
			local equalm1`spec'= `equal`spec''-1
			local equalp1`spec'= `equal`spec''+1
			local stringtimetreatments`spec'=substr("`treatment`spec''",`starttimetreatments`spec'',`endtimetreatments`spec'')
			* 2sls
				if ("`equal`spec''"!="0") {
				local regtype`spec'="ivreghdfe"
				local endivlist`spec'=strpos("`treatment`spec''",",")
				local treatmentbeta`spec'=substr("`treatment`spec''",1,`equalm1`spec'')
				* if the instrumented var is time varying
				local treatmentinlist`spec'=0
					foreach var in `stringtimetreatments`spec''{
					if ("`var'"=="`treatmentbeta`spec''") local treatmentinlist`spec'=1
					}
					if `treatmentinlist`spec''==1 {
					local treatmentbeta`spec'="`treatmentbeta`spec''"+"`"+`"interval"'+"'"	
					}
				* if the instruments are time varying
				local ivlistlength`spec'=`endivlist`spec''-`equalp1`spec''
				local ivlist`spec'=substr("`treatment`spec''",`equalp1`spec'',`ivlistlength`spec'')
				local intersection`spec':list stringtimetreatments`spec' & ivlist`spec'
				local notime`spec':list ivlist`spec'-stringtimetreatments`spec'
				local intersectionnumber: word count `intersection`spec''
				tokenize `intersection`spec''
					if `treatmentinlist`spec''==1 { 
						if ("`intersectionnumber'"=="0") local treatmentstring`spec'="(`treatmentbeta`spec''" +"`"+`"interval"'+"'" + "=`notime`spec''" + ")"
						if ("`intersectionnumber'"=="1") local treatmentstring`spec'="(`treatmentbeta`spec''" +"`"+`"interval"'+"'" + "=`notime`spec''" + " " + "`1'" +"`"+`"interval"'+"'" + ")"
						if ("`intersectionnumber'"=="2") local treatmentstring`spec'="(`treatmentbeta`spec''" +"`"+`"interval"'+"'" + "=`notime`spec''" + " " + "`1'" +"`"+`"interval"'+"'" + " " + "`2'" +"`"+`"interval"'+"'" + ")"
						if ("`intersectionnumber'"=="3") local treatmentstring`spec'="(`treatmentbeta`spec''" +"`"+`"interval"'+"'" + "=`notime`spec''" + " " + "`1'" +"`"+`"interval"'+"'" + " " + "`2'" +"`"+`"interval"'+"'" + " " + "`3'" +"`"+`"interval"'+"'"+ ")"
						if ("`intersectionnumber'"=="4") local treatmentstring`spec'="(`treatmentbeta`spec''" +"`"+`"interval"'+"'" + "=`notime`spec''" + " " + "`1'" +"`"+`"interval"'+"'" + " " + "`2'" +"`"+`"interval"'+"'" + " " + "`3'" +"`"+`"interval"'+"'" + " " + "`4'" +"`"+`"interval"'+"'" + ")"
						if ("`intersectionnumber'"=="5") local treatmentstring`spec'="(`treatmentbeta`spec''" +"`"+`"interval"'+"'" + "=`notime`spec''" + " " + "`1'" +"`"+`"interval"'+"'" + " " + "`2'" +"`"+`"interval"'+"'" + " " + "`3'" +"`"+`"interval"'+"'" + " " + "`4'" +"`"+`"interval"'+"'" + " " + "`5'" +"`"+`"interval"'+"'"+ ")"
					}
					if `treatmentinlist`spec''==0 { 
						if ("`intersectionnumber'"=="1") local treatmentstring`spec'="(`treatmentbeta`spec''=`notime`spec''" + " " + "`1'" +"`"+`"interval"'+"'" + ")"
						if ("`intersectionnumber'"=="2") local treatmentstring`spec'="(`treatmentbeta`spec''=`notime`spec''" + " " + "`1'" +"`"+`"interval"'+"'" + " " + "`2'" +"`"+`"interval"'+"'" + ")"
						if ("`intersectionnumber'"=="3") local treatmentstring`spec'="(`treatmentbeta`spec''=`notime`spec''" + " " + "`1'" +"`"+`"interval"'+"'" + " " + "`2'" +"`"+`"interval"'+"'" + " " + "`3'" +"`"+`"interval"'+"'"+ ")"
						if ("`intersectionnumber'"=="4") local treatmentstring`spec'="(`treatmentbeta`spec''=`notime`spec''" + " " + "`1'" +"`"+`"interval"'+"'" + " " + "`2'" +"`"+`"interval"'+"'" + " " + "`3'" +"`"+`"interval"'+"'" + " " + "`4'" +"`"+`"interval"'+"'" + ")"
						if ("`intersectionnumber'"=="5") local treatmentstring`spec'="(`treatmentbeta`spec''=`notime`spec''" + " " + "`1'" +"`"+`"interval"'+"'" + " " + "`2'" +"`"+`"interval"'+"'" + " " + "`3'" +"`"+`"interval"'+"'" + " " + "`4'" +"`"+`"interval"'+"'" + " " + "`5'" +"`"+`"interval"'+"'"+ ")"
					}
				}
			* no 2sls
				if ("`equal`spec''"=="0") {
				local endlist`spec'=strpos("`treatment`spec''",",")-1
				local regtype`spec'="reghdfe"
				local treatmentstring`spec'=substr("`treatment`spec''",1,`endlist`spec'')+"`"+`"interval"'+"'"
				local treatmentbeta`spec'=substr("`treatment`spec''",1,`endlist`spec'')+"`"+`"interval"'+"'"
				}
			}
		}

	* idee 
	* create local with string before equal and string after, creating the local of strings after adding the interval
			*if ("`timetreatment`spec''"!=""){
			*local addinterval`spec'="`"+`"interval"'+"'"
			*}	
	/* ATTEMPT to make time ivs iteratively, problem in keeping local non-substituted after multiple loops
						local intersection_counter`spec'=0
					foreach var in `intersection`spec'' {
					local intersection_counter`spec'=`intersection_counter`spec''+1
						if `intersection_counter`spec''==1 {
						*local ivlist_withinterval`spec'="`var'"+"`"+`"interval"'+"'"
						local ivlist_withinterval`spec'="`var'"+"`"+"`"+"'+`"interval"'+`"+"'+"'"" /* PROBLEM need to add the addinterval local to the list - might have to define it in the regression */
						di "`ivlist_withinterval`spec'''"
						}
						if `intersection_counter`spec''>1 {
						local ivlist_withinterval`spec'="`ivlist_withinterval`spec''"+" "+"`var'"+`""`"`"interval"'"'""'
						}
					}
	*/
			
	* PERTURBATION TEST
	if ("`perturbationtest'"!="") {
	levelsof `perturbationtest', local(vals_perturbation_test)	
	local max_pt_iter: word count `vals_perturbation_test'
	local additeration "`"+"pt_iteration"+"'"
		if ("`if'"=="") local ifperturbationtest="if `perturbationtest'!=`additeration'"
		if ("`if'"!="") local ifperturbationtest="& `perturbationtest'!=`additeration'"
	}		
	
	* TUPLES TEST
	if ("`tuplestest'"!="") {
	tuples `tuplestest'
	local tuplesvarnumber: word count `tuplestest'
	local tuplesnumber=(2^`tuplesvarnumber')-1
		* the controls in controls that are inserted in tuplestest are dropped from controls
		local controls1: list controls1-tuplestest
	}		

	* LEAVE ONE OUT TEST
		if ("`leaveoneouttest'"!="") {
		local leaveoneoutvarnumber: word count `leaveoneouttest'
		local leave_counter=0
			foreach var in `leaveoneouttest'{
			local leave_counter=`leave_counter'+1
			local leave`leave_counter': list leaveoneouttest-var
			}
		}	
	
	/** Parse timecontrols OLD VERSION, WORKING ONLY WITH 2 VARS
	forvalues spec = `spec_to_run' {
		if ("`timecontrols`spec''"!="") {
			local counter_tvcontrols`spec'=0
			foreach timevaryingcontrol in `timecontrols`spec''{
			local counter_tvcontrols`spec'=`counter_tvcontrols`spec''+1
				if "`counter_tvcontrols`spec''"=="1"{
				local timecontrols`spec'= "`timevaryingcontrol'"+"`"+`"interval"'+"'"
				}
				if (`counter_tvcontrols`spec''>1){
				local timecontrols`spec'= "`timecontrols`spec''"+"`"+`"interval"'+"'"+" "+"`timevaryingcontrol'"+"`"+`"interval"'+"'"
				}
			}
		}
	}
	*/
	* Add interval to time controls
		forvalues spec = `spec_to_run' {
			if ("`timecontrols`spec''"!=""){
			local timecontrolsnumber`spec'=wordcount("`timecontrols`spec''")
			local timecontrols_clean`spec'="`: word 1 of `timecontrols`spec'''"+" "
				forvalues order=2/`timecontrolsnumber`spec''{
				cap local timecontrols_clean`spec'="`timecontrols_clean`spec''"+"`: word `order' of `timecontrols`spec'''"+" "
				}
				forvalues interval=`window'{
				local timecontrols`spec'_`interval'=subinstr("`timecontrols_clean`spec''"," ","`interval' ",.)
				}
			}
		}
		* Add interval to time absorb 
		if ("`timeabsorb1'"!="")|("`timeabsorb2'"!="")|("`timeabsorb3'"!=""){
			forvalues spec = `spec_to_run' {
			local timeabsorbnumber`spec'=wordcount("`timeabsorb`spec''")
			local timeabsorb_clean`spec'="`: word 1 of `timeabsorb`spec'''"+" "
				forvalues order=2/`timeabsorbnumber`spec''{
				cap local timeabsorb_clean`spec'="`timeabsorb_clean`spec''"+"`: word `order' of `timeabsorb`spec'''"+" "
				}
				forvalues interval=`window'{
				local timeabsorb`spec'_`interval'=subinstr("`timeabsorb_clean`spec''"," ","`interval' ",.)
				}
			}
		}
	
	* Creates strings to add as option to regressions to run ******
		forvalues spec = `spec_to_run' {
		* weights, either one can be specified
			if ("`aweight`spec''"!=""){
			local wt`spec' "[aweight=`aweight`spec'']"
			}
			if ("`fweight`spec''"!=""){
			local wt`spec' "[fweight=`fweight`spec'']"
			}
		* absorb 
			if ("`absorb`spec''"!="") | ("`timeabsorb`spec''"!="") {
			local regabsorb`spec'="absorb(" + "`absorb`spec''" + " " + "`" + "timeabsorb`spec'_"+"`"+`"interval"'+"'"+"'"+")"
			}
			if ("`absorb`spec''"=="") & ("`timeabsorb`spec''"=="")  {
				if "`regtype`spec''"=="reghdfe" {
				local regabsorb`spec'="noabsorb"
				}
				if "`regtype`spec''"=="ivreghdfe" {
				local regabsorb`spec'=""
				}
			}		
		* s.e., either one can be specified
			if ("`cluster`spec''"!=""){
			local addcluster`spec'="cluster(`cluster`spec'')"
			}
			if ("`vce`spec''"!=""){
			local addvce`spec'="vce(`vce`spec'')"
				if "`regtype`spec''"=="ivreghdfe" {
				local addvce`spec'="robust"
				}		
			}
		}
		* levels
			if ("`level'"!=""){
			local level="level(`level')"
			} 

	****** Estimation foreach interval and treatment ******
		* PERTURBATION TEST
		if "`perturbationtest'"!=""{
			if ("`if'"!="") local ifperturbation=substr("`if'",3,.)
			if ("`if'"!="") local ifperturbation="if (`ifperturbation')"
		local counter_saving=0
			foreach pt_iteration in `vals_perturbation_test' {
			local counter_saving=`counter_saving'+1
			eststo clear
				forvalues spec = 1/1 {
					if "`command'"!=""{
					di "`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `wt`spec'' `ifperturbation' `ifperturbationtest' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level' `first'"
					}
					forvalues interval=`window'{
						if "`savetables'"!=""{
						`display' eststo:`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `wt`spec'' `ifperturbation' `ifperturbationtest' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level' `first'
						}
						if "`savetables'"==""{
						`display' `regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `wt`spec'' `ifperturbation' `ifperturbationtest' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level' `first'
						}
					qui lincom _b[`treatmentbeta`spec'']
					local coef_`pt_iteration'_`spec'_`interval'=r(estimate)
					local lb_`pt_iteration'_`spec'_`interval'=r(lb)
					local ub_`pt_iteration'_`spec'_`interval'=r(ub)
					local pi_`pt_iteration'_`spec'_`interval'=r(p)
					}
				matrix esample_`pt_iteration'_`spec'=e(N)
				}
			* Generate strings for matrixes and matrixes - based on number of coefficients plotted and iterated 
				forvalues spec = 1/1 {
				* coefficients and rownames
				local coefmatrixstring_`pt_iteration'_`spec'="`coef_`pt_iteration'_`spec'_`start''"
				local rownamesstring_`pt_iteration'_`spec'="_`start'"
					forvalues interval=`second'`window_rhs' {
					local coefmatrixstring_`pt_iteration'_`spec'="`coefmatrixstring_`pt_iteration'_`spec''"+"\"+"`coef_`pt_iteration'_`spec'_`interval''"
					local rownamesstring_`pt_iteration'_`spec'="`rownamesstring_`pt_iteration'_`spec''"+" "+"_`interval'"
					}
				* pvalue
				local pimatrixstring_`pt_iteration'_`spec'="`pi_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local pimatrixstring_`pt_iteration'_`spec'="`pimatrixstring_`pt_iteration'_`spec''"+"\"+"`pi_`pt_iteration'_`spec'_`interval''"
					}
				* confidence interval
				local cimatrixstring_`pt_iteration'_`spec'="`lb_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+","+"`lb_`pt_iteration'_`spec'_`interval''"
					}
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+"\"+"`ub_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+","+"`ub_`pt_iteration'_`spec'_`interval''"
					}	
				matrix define matrix_coef_`pt_iteration'_`spec'=(`coefmatrixstring_`pt_iteration'_`spec'')
				matrix rownames matrix_coef_`pt_iteration'_`spec'=`rownamesstring_`pt_iteration'_`spec''
				matrix colnames matrix_coef_`pt_iteration'_`spec'=b	
				matrix matrix_coef_`pt_iteration'_`spec'=matrix_coef_`pt_iteration'_`spec''
				matrix define matrix_ci_`pt_iteration'_`spec'=(`cimatrixstring_`pt_iteration'_`spec'')
				matrix define matrix_pi_`pt_iteration'_`spec'=(`pimatrixstring_`pt_iteration'_`spec'')
				matrix matrix_pi_`pt_iteration'_`spec'=matrix_pi_`pt_iteration'_`spec''				
				}
				if "`savetables'"!=""{
					if `counter_saving'==1{
					esttab using `savetables', star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
					}
					if `counter_saving'>1{
					esttab using `savetables', star(+ 0.10 * 0.05 ** 0.01 *** 0.001) append
					}
				}
			}
		* Generate diagnostics	
		if "do"=="do" {
			forvalues spec = 1/1 {
				forvalues interval=`window'{
				qui `regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level' 
				qui lincom _b[`treatmentbeta`spec'']
				local m_coef_`spec'_`interval'=r(estimate)
				local m_lb_`spec'_`interval'=r(lb)
				local m_ub_`spec'_`interval'=r(ub)
				local m_pi_`spec'_`interval'=r(p)
				}
			matrix esample_1=e(N)
			}
			forvalues spec = 1/1 {
			* coefficients and rownames
			local m_coefmatrixstring_`spec'="`m_coef_`spec'_`start''"
			local m_rownamesstring_`spec'="_`start'"
				forvalues interval=`second'`window_rhs' {
				local m_coefmatrixstring_`spec'="`m_coefmatrixstring_`spec''"+"\"+"`m_coef_`spec'_`interval''"
				local m_rownamesstring_`spec'="`m_rownamesstring_`spec''"+" "+"_`interval'"
				}
			* pvalue
			local m_pimatrixstring_`spec'="`m_pi_`spec'_`start''"
				forvalues interval=`second'`window_rhs' {
				local m_pimatrixstring_`spec'="`m_pimatrixstring_`spec''"+"\"+"`m_pi_`spec'_`interval''"
				}	
			matrix define m_matrix_coef_`spec'=(`m_coefmatrixstring_`spec'')
			matrix rownames m_matrix_coef_`spec'=`m_rownamesstring_`spec''
			matrix colnames m_matrix_coef_`spec'=b	
			matrix m_matrix_coef_`spec'=m_matrix_coef_`spec''
			matrix define m_matrix_pi_`spec'=(`m_pimatrixstring_`spec'')
			matrix m_matrix_pi_`spec'=m_matrix_pi_`spec''		
			}
			* create matrix
			foreach pt_iteration in `vals_perturbation_test' {
				matrix m_matrix_coef_1=m_matrix_coef_1\matrix_coef_`pt_iteration'_1
				matrix m_matrix_pi_1=m_matrix_pi_1\matrix_pi_`pt_iteration'_1
				matrix esample_1=esample_1\esample_`pt_iteration'_1
			}	
			* Bulding data and run checks
			preserve
			cap drop *coef_pt* 
			cap drop *pi_pt* 
			cap drop sample_pt*
			svmat double m_matrix_coef_1, name(coef_pt)
			svmat double m_matrix_pi_1, name(pi_pt)			
			svmat double esample_1, name(sample_pt)
			
			qui keep *coef_pt* *pi_pt* sample_pt1
			qui dropmiss, obs force
			qui gen it=_n

				forvalues interval=1/`win_iter_counter'{
				qui replace pi_pt`interval'=pi_pt`interval'<=`level_pt'
				}
				forvalues interval=1/`win_iter_counter'{
				qui replace coef_pt`interval'=. if pi_pt`interval'==0 & it>1
				}
				forvalues interval=1/`win_iter_counter'{
				qui replace coef_pt`interval'=coef_pt`interval'>0 if coef_pt`interval'!=.
				}
				forvalues interval=1/`win_iter_counter'{
				qui gen change_coef_pt`interval'=coef_pt`interval'
					if change_coef_pt`interval'[1]==1{
					qui replace change_coef_pt`interval'=1 if coef_pt`interval'!=1 & coef_pt`interval'!=. & it>1
					qui replace change_coef_pt`interval'=0 if coef_pt`interval'==1 | coef_pt`interval'==. & it>1
					}
					if change_coef_pt`interval'[1]==0{
					qui replace change_coef_pt`interval'=0 if coef_pt`interval'==. & it>1
					}
				}
				forvalues interval=1/`win_iter_counter'{
				qui gen change_pi_pt`interval'=pi_pt`interval'
					if change_pi_pt`interval'[1]==1{
					qui replace change_pi_pt`interval'=1 if pi_pt`interval'!=1 & pi_pt`interval'!=. & it>1
					qui replace change_pi_pt`interval'=0 if pi_pt`interval'==1 & pi_pt`interval'!=. & it>1
					}
				}			
				
				foreach element in coef pi{
				qui gen tot_estim_change_`element'=0 if it>1 
					forvalues interval=1/`win_iter_counter'{
					qui egen tot_iter_change_`element'_pt`interval'=total(change_`element'_pt`interval') if it>1 & change_`element'_pt`interval'!=. /* column total */
					qui replace tot_estim_change_`element'=tot_estim_change_`element'+change_`element'_pt`interval' if it>1 /* row total */
					}				
				}
				foreach element in coef pi{
					forvalues interval=1/`win_iter_counter'{
						if `interval'==1{
						local total_`element'_changing=tot_iter_change_`element'_pt`interval'[2]
						}
						if `interval'>1{
						local total_`element'_changing=`total_`element'_changing'+tot_iter_change_`element'_pt`interval'[2] /* colums total is always the same, above line 1, so sum across intervals for tot num */
						}
					}
				if (`total_`element'_changing'==.) local total_`element'_changing=0
				}
				foreach element in coef pi{
					forvalues interval=1/`win_iter_counter'{
						qui gen tot_iter_change_`element'_pt`interval'_b1=tot_iter_change_`element'_pt`interval'>0 if tot_iter_change_`element'_pt`interval'!=. & it>1 /* columns if column>1, to track if there's at least 1 change for a single estimate different samples */
					}
				}	
				foreach element in coef pi{
				local est_1pert_`element'_changing=0
					forvalues interval=1/`win_iter_counter'{
					local est_1pert_`element'_changing= `est_1pert_`element'_changing' + tot_iter_change_`element'_pt`interval'_b1[2] /* how many estimates have issues in the samples */
					if (`est_1pert_`element'_changing'==.) local est_1pert_`element'_changing=0
					}
				}	
				local max_sample_size=sample_pt1[1]
				foreach element in coef pi{
				qui egen max_tot_estim_change_`element'=max(tot_estim_change_`element') if it>1 /* max number of estimates changed by a sample (or more than one) */
				local max_tot_estim_change_`element'=max_tot_estim_change_`element'[2]
				qui count if tot_estim_change_`element'>0 & it>1 /* how many samples are changing at least one estimate */
				local iter_1est_`element'_changing=r(N)		
				qui egen val_min_perturbation_`element'=min(sample_pt1) if tot_estim_change_`element'>0 & tot_estim_change_`element'!=. & it>1
				qui ereplace val_min_perturbation_`element'=max(val_min_perturbation_`element') if it>1
				local val_min_perturbation_`element'=val_min_perturbation_`element'[2]
				local val_min_perturbation_`element'=`max_sample_size'-`val_min_perturbation_`element''
				if (`val_min_perturbation_`element''==.) local val_min_perturbation_`element'=0
				qui egen val_max_perturbation_`element'=min(sample_pt1) if tot_estim_change_`element'==max_tot_estim_change_`element' & max_tot_estim_change_`element'!=0 & max_tot_estim_change_`element'!=. & it>1
				qui ereplace val_max_perturbation_`element'=max(val_max_perturbation_`element') if it>1
				local val_max_perturbation_`element'=val_max_perturbation_`element'[2]
				local val_max_perturbation_`element'=`max_sample_size'-`val_max_perturbation_`element''
				if (`val_max_perturbation_`element''==.) local val_max_perturbation_`element'=0
				}				
				**********
				foreach element in coef pi{
				local min_perturbation_`element'	= `val_min_perturbation_`element''*100/`max_sample_size'
				local max_perturbation_`element'	= `val_max_perturbation_`element''*100/`max_sample_size'
				local overall_stability_`element'	= `total_`element'_changing'*100/(`max_pt_iter'*`win_iter_counter')
				local total_estimations				= `max_pt_iter'*`win_iter_counter'
				local estimates_stability_`element'	= `est_1pert_`element'_changing'*100/`win_iter_counter'
				local samples_stability_`element'	= `iter_1est_`element'_changing'*100/`max_pt_iter'
			
				local min_perturbation_`element'	= round(`min_perturbation_`element'',0.01)
				local max_perturbation_`element'	= round(`max_perturbation_`element'',0.01)
				local overall_stability_`element'	= round(`overall_stability_`element'',0.01)
				local estimates_stability_`element'	= round(`estimates_stability_`element'',0.01)
				local samples_stability_`element'	= round(`samples_stability_`element'',0.01)
				}
				
				di "****************************************************************************************"
				di "  Sample Diagnostics	| Significance | Sign "					
				di " -------------------------------------------------------------------------------------- "
				di "  Minimum Perturbation	| `val_min_perturbation_pi'/`max_sample_size'=`min_perturbation_pi'% | `val_min_perturbation_coef'/`max_sample_size'= `min_perturbation_coef'% "
				di "  Maximum Perturbation	| `val_max_perturbation_pi'/`max_sample_size'=`max_perturbation_pi'% | `val_max_perturbation_coef'/`max_sample_size'= `max_perturbation_coef'% "
				di " ---------------------------"
				di "  Overall Stability		| `total_pi_changing'/`total_estimations'=`overall_stability_pi'% | `total_coef_changing'/`total_estimations'=`overall_stability_coef'% "
				di "  Estimates Stability	| `est_1pert_pi_changing'/`win_iter_counter'=`estimates_stability_pi'% | `est_1pert_coef_changing'/`win_iter_counter'=`estimates_stability_coef'% "
				di "  Samples Stability		| `iter_1est_pi_changing'/`max_pt_iter'=`samples_stability_pi'% | `iter_1est_coef_changing'/`max_pt_iter'=`samples_stability_coef'% "
				di "****************************************************************************************"
				di " " 
				di "  The Sample Diagnostics table offers some key statistics on the stability of the estimates in the main sample, throughout the subsamples."
				di "  The significance column shows changes in significance, while the sign column shows changes of sign, given that estimates are significant at the chosen threshold."
				di "  Minimum Perturbation: smallest sample drop causing a change of at least 1 estimate's significance/sign."
				di "  Maximum Perturbation: smallest sample drop causing a change of the highest number of estimates' significance/sign."
				di "  Overall Stability: number of estimates showing a change in significance/sign, summed across all subsamples, over the total number of estimatesXsubsamples."
				di "  Estimates Stability: number of estimates showing a change in significance/sign in at least 1 of the subsamples, over the total number estimates."
				di "  Samples Stability: number of subsamples showing a change in significance/sign for at least 1 of the estimates, over the total number of subsamples."
				di "  For more details, see Ash, Elliott and Pinna, Matteo, Automated checks for specification and sample sensitivity in panel data designs (2021) - soon to be available."
				restore
			}
		*
		}
		* TUPLES TEST
		if "`tuplestest'"!=""{	
			forvalues pt_iteration=1/`tuplesnumber'{
			eststo clear
				forvalues spec = 1/1 {
					if "`command'"!=""{
					di "`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `tuple`pt_iteration'' `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level' `first'"
					}
					forvalues interval=`window'{
						if "`savetables'"!=""{
						`display' eststo:`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `tuple`pt_iteration'' `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level'  `first'
						}						
						if "`savetables'"==""{
						`display' `regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `tuple`pt_iteration'' `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level'  `first'
						}
					qui lincom _b[`treatmentbeta`spec'']
					local coef_`pt_iteration'_`spec'_`interval'=r(estimate)
					local lb_`pt_iteration'_`spec'_`interval'=r(lb)
					local ub_`pt_iteration'_`spec'_`interval'=r(ub)
					}
				}
			* Generate strings for matrixes and matrixes - based on number of coefficients plotted and iterated 
				forvalues spec = 1/1 {
				* coefficients and rownames
				local coefmatrixstring_`pt_iteration'_`spec'="`coef_`pt_iteration'_`spec'_`start''"
				local rownamesstring_`pt_iteration'_`spec'="_`start'"
					forvalues interval=`second'`window_rhs' {
					local coefmatrixstring_`pt_iteration'_`spec'="`coefmatrixstring_`pt_iteration'_`spec''"+"\"+"`coef_`pt_iteration'_`spec'_`interval''"
					local rownamesstring_`pt_iteration'_`spec'="`rownamesstring_`pt_iteration'_`spec''"+" "+"_`interval'"
					}
				* confidence interval
				local cimatrixstring_`pt_iteration'_`spec'="`lb_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+","+"`lb_`pt_iteration'_`spec'_`interval''"
					}
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+"\"+"`ub_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+","+"`ub_`pt_iteration'_`spec'_`interval''"
					}	
				matrix define matrix_coef_`pt_iteration'_`spec'=(`coefmatrixstring_`pt_iteration'_`spec'')
				matrix rownames matrix_coef_`pt_iteration'_`spec'=`rownamesstring_`pt_iteration'_`spec''
				matrix colnames matrix_coef_`pt_iteration'_`spec'=b	
				matrix matrix_coef_`pt_iteration'_`spec'=matrix_coef_`pt_iteration'_`spec''
				matrix define matrix_ci_`pt_iteration'_`spec'=(`cimatrixstring_`pt_iteration'_`spec'')
				}
				if "`savetables'"!=""{
					if `pt_iteration'==1{
					esttab using `savetables', star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
					}
					if `pt_iteration'>1{
					esttab using `savetables', star(+ 0.10 * 0.05 ** 0.01 *** 0.001) append
					}
				}
			}
		}
		* Leave-one-out test
		if "`leaveoneouttest'"!=""{	
			forvalues pt_iteration=1/`leaveoneoutvarnumber'{
			eststo clear
				forvalues spec = 1/1 {
					if "`command'"!=""{
				 	di "`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `leave`pt_iteration'' `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level' `first'"
					}
					forvalues interval=`window'{
						if "`savetables'"!=""{
						`display' eststo:`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `leave`pt_iteration'' `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level'  `first'
						}						
						if "`savetables'"==""{
						`display' `regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `leave`pt_iteration'' `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level'  `first'
						}
					qui lincom _b[`treatmentbeta`spec'']
					local coef_`pt_iteration'_`spec'_`interval'=r(estimate)
					local lb_`pt_iteration'_`spec'_`interval'=r(lb)
					local ub_`pt_iteration'_`spec'_`interval'=r(ub)
					}
				}
			* Generate strings for matrixes and matrixes - based on number of coefficients plotted and iterated 
				forvalues spec = 1/1 {
				* coefficients and rownames
				local coefmatrixstring_`pt_iteration'_`spec'="`coef_`pt_iteration'_`spec'_`start''"
				local rownamesstring_`pt_iteration'_`spec'="_`start'"
					forvalues interval=`second'`window_rhs' {
					local coefmatrixstring_`pt_iteration'_`spec'="`coefmatrixstring_`pt_iteration'_`spec''"+"\"+"`coef_`pt_iteration'_`spec'_`interval''"
					local rownamesstring_`pt_iteration'_`spec'="`rownamesstring_`pt_iteration'_`spec''"+" "+"_`interval'"
					}
				* confidence interval
				local cimatrixstring_`pt_iteration'_`spec'="`lb_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+","+"`lb_`pt_iteration'_`spec'_`interval''"
					}
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+"\"+"`ub_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+","+"`ub_`pt_iteration'_`spec'_`interval''"
					}	
				matrix define matrix_coef_`pt_iteration'_`spec'=(`coefmatrixstring_`pt_iteration'_`spec'')
				matrix rownames matrix_coef_`pt_iteration'_`spec'=`rownamesstring_`pt_iteration'_`spec''
				matrix colnames matrix_coef_`pt_iteration'_`spec'=b	
				matrix matrix_coef_`pt_iteration'_`spec'=matrix_coef_`pt_iteration'_`spec''
				matrix define matrix_ci_`pt_iteration'_`spec'=(`cimatrixstring_`pt_iteration'_`spec'')
				}
				if "`savetables'"!=""{
					if `pt_iteration'==1{
					esttab using `savetables', star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
					}
					if `pt_iteration'>1{
					esttab using `savetables', star(+ 0.10 * 0.05 ** 0.01 *** 0.001) append
					}
				}
			}
		}
		* MULTI TEST
		if "`multitest'"!=""{
		local counter_saving=0
			foreach pt_iteration in `multitest'{
			local counter_saving=`counter_saving'+1
			eststo clear
			* the controls in controls that are inserted in multitest are dropped from controls
			local vars_multitest ${`pt_iteration'}
			local controls`pt_iteration': list controls1-vars_multitest
				forvalues spec = 1/1 {
					if "`command'"!=""{
					di "`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`pt_iteration'' ${`pt_iteration'} `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level' `first'" 
					}
					forvalues interval=`window'{
					if "`savetables'"!=""{
					`display' eststo:`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`pt_iteration'' ${`pt_iteration'} `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level'  `first'
					}
					if "`savetables'"==""{
					`display' `regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`pt_iteration'' ${`pt_iteration'} `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level'  `first'
					}
					qui lincom _b[`treatmentbeta`spec'']
					local coef_`pt_iteration'_`spec'_`interval'=r(estimate)
					local lb_`pt_iteration'_`spec'_`interval'=r(lb)
					local ub_`pt_iteration'_`spec'_`interval'=r(ub)
					}
				}
			* Generate strings for matrixes and matrixes - based on number of coefficients plotted and iterated 
				forvalues spec = 1/1 {
				* coefficients and rownames
				local coefmatrixstring_`pt_iteration'_`spec'="`coef_`pt_iteration'_`spec'_`start''"
				local rownamesstring_`pt_iteration'_`spec'="_`start'"
					forvalues interval=`second'`window_rhs' {
					local coefmatrixstring_`pt_iteration'_`spec'="`coefmatrixstring_`pt_iteration'_`spec''"+"\"+"`coef_`pt_iteration'_`spec'_`interval''"
					local rownamesstring_`pt_iteration'_`spec'="`rownamesstring_`pt_iteration'_`spec''"+" "+"_`interval'"
					}
				* confidence interval
				local cimatrixstring_`pt_iteration'_`spec'="`lb_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+","+"`lb_`pt_iteration'_`spec'_`interval''"
					}
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+"\"+"`ub_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+","+"`ub_`pt_iteration'_`spec'_`interval''"
					}	
				matrix define matrix_coef_`pt_iteration'_`spec'=(`coefmatrixstring_`pt_iteration'_`spec'')
				matrix rownames matrix_coef_`pt_iteration'_`spec'=`rownamesstring_`pt_iteration'_`spec''
				matrix colnames matrix_coef_`pt_iteration'_`spec'=b	
				matrix matrix_coef_`pt_iteration'_`spec'=matrix_coef_`pt_iteration'_`spec''
				matrix define matrix_ci_`pt_iteration'_`spec'=(`cimatrixstring_`pt_iteration'_`spec'')
				}
				if "`savetables'"!=""{
					if `counter_saving'==1{
					esttab using `savetables', star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
					}
					if `counter_saving'>1{
					esttab using `savetables', star(+ 0.10 * 0.05 ** 0.01 *** 0.001) append
					}
				}
			}
		}			
		* NORMAL REGS
		if "`perturbationtest'"=="" & "`tuplestest'"=="" & "`multitest'"=="" & "`leaveoneouttest'"=="" {
			forvalues spec = `spec_to_run' {
				if "`command'"!=""{
				di "`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level' `first'"
				}
			eststo clear
				forvalues interval=`window'{
				if "`savetables'"!="" | "`savetex'"!=""{
				eststo:`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level'  `first'
				}
				if "`savetables'"=="" & "`savetex'"==""{
				`regtype`spec'' `y_vars'`interval' `treatmentstring`spec'' `timecontrols`spec'_`interval'' `controls`spec'' `wt`spec'' `if' `in', `regabsorb`spec'' `addvce`spec'' `addcluster`spec'' `constant' `level' `first'
				}	
					if "`fstat'"==""{
					qui lincom _b[`treatmentbeta`spec'']
					local coef_`pt_iteration'_`spec'_`interval'=r(estimate)
					local lb_`pt_iteration'_`spec'_`interval'=r(lb)
					local ub_`pt_iteration'_`spec'_`interval'=r(ub)
					}
					if "`fstat'"!=""{
					local coef_`pt_iteration'_`spec'_`interval'=e(rkf)
					}				
				}
				if "`savetex'"!=""{
				esttab using `savetex'`spec'.tex, replace keep(`treatmentstring`spec''*) label order() collabels(, none) ml(,none) cells(b(star fmt (%9.3f)) se(par)) stats(r2 N, fmt(%9.3f %9.0g) labels("R$^2$" "N observations")) star(+ 0.10  * 0.05 ** 0.01 *** 0.001)
				}
				if "`savetables'"!=""{
					if `spec'==1{
					esttab using `savetables', star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
					}
					if `spec'>1{
					esttab using `savetables', star(+ 0.10 * 0.05 ** 0.01 *** 0.001) append
					}
				}
			}
		* Generate strings for matrixes and matrixes - based on number of coefficients plotted and iterated 
			if "`fstat'"==""{
				forvalues spec = `spec_to_run' {
				* coefficients and rownames
				local coefmatrixstring_`pt_iteration'_`spec'="`coef_`pt_iteration'_`spec'_`start''"
				local rownamesstring_`pt_iteration'_`spec'="_`start'"
					forvalues interval=`second'`window_rhs' {
					local coefmatrixstring_`pt_iteration'_`spec'="`coefmatrixstring_`pt_iteration'_`spec''"+"\"+"`coef_`pt_iteration'_`spec'_`interval''"
					local rownamesstring_`pt_iteration'_`spec'="`rownamesstring_`pt_iteration'_`spec''"+" "+"_`interval'"
					}	
				* confidence interval
				local cimatrixstring_`pt_iteration'_`spec'="`lb_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+","+"`lb_`pt_iteration'_`spec'_`interval''"
					}
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+"\"+"`ub_`pt_iteration'_`spec'_`start''"
					forvalues interval=`second'`window_rhs' {
					local cimatrixstring_`pt_iteration'_`spec'="`cimatrixstring_`pt_iteration'_`spec''"+","+"`ub_`pt_iteration'_`spec'_`interval''"
					}
				matrix define matrix_coef_`pt_iteration'_`spec'=(`coefmatrixstring_`pt_iteration'_`spec'')
				matrix rownames matrix_coef_`pt_iteration'_`spec'=`rownamesstring_`pt_iteration'_`spec''
				matrix colnames matrix_coef_`pt_iteration'_`spec'=b	
				matrix matrix_coef_`pt_iteration'_`spec'=matrix_coef_`pt_iteration'_`spec''
				matrix define matrix_ci_`pt_iteration'_`spec'=(`cimatrixstring_`pt_iteration'_`spec'')
				}	
			}
			if "`fstat'"!=""{
				forvalues spec = `spec_to_run' {
				* coefficients and rownames
				local coefmatrixstring_`pt_iteration'_`spec'="`coef_`pt_iteration'_`spec'_`start''"
				local rownamesstring_`pt_iteration'_`spec'="_`start'"
					forvalues interval=`second'`window_rhs' {
					local coefmatrixstring_`pt_iteration'_`spec'="`coefmatrixstring_`pt_iteration'_`spec''"+"\"+"`coef_`pt_iteration'_`spec'_`interval''"
					local rownamesstring_`pt_iteration'_`spec'="`rownamesstring_`pt_iteration'_`spec''"+" "+"_`interval'"
					}
				matrix define matrix_coef_`pt_iteration'_`spec'=(`coefmatrixstring_`pt_iteration'_`spec'')
				matrix rownames matrix_coef_`pt_iteration'_`spec'=`rownamesstring_`pt_iteration'_`spec''
				matrix colnames matrix_coef_`pt_iteration'_`spec'=b	
				matrix matrix_coef_`pt_iteration'_`spec'=matrix_coef_`pt_iteration'_`spec''
				}
			}
		}
	
		
	**** Coefplot ****

	* Set default settings
	* Titles
		if ("`ytitle'"=="") & ("`fstat'"=="")  local ytitle "`y_vars'"
		if ("`ytitle'"=="") & ("`fstat'"!="")  local ytitle "`y_vars' (F-stat)"
		if ("`time'"=="") & ("`xtitle'"=="") local xtitle ""
		if ("`time'"=="day") & ("`xtitle'"=="") local xtitle "Date"
		if ("`time'"=="week") & ("`xtitle'"=="") local xtitle "Date"
		if ("`time'"=="month") & ("`xtitle'"=="") local xtitle "Month"
		if ("`time'"=="year") & ("`xtitle'"=="") local xtitle "Year"
	* Spec color
	if ("`speccolor1'"=="") local speccolor1 "navy"
	if ("`speccolor2'"=="") local speccolor2 "maroon"
	if ("`speccolor3'"=="") local speccolor3 "teal"
	* Tests color
	if ("`testcicolor'"=="") local testcicolor "teal"
	if ("`testcoefcolor'"=="") local testcoefcolor "maroon"

	* Offset
	if("`offset'"=="") local offset=0.1
	* Legend 
	if ("`legend'"=="off") {
	local addlegend "off"	
	}
	if ("`legend'"!="off") { 
		if "`fstat'"==""{
			if ("`legend'"=="") {
				if ("`perturbationtest'"=="") & ("`multitest'"=="") & ("`tuplestest'"=="") & ("`leaveoneouttest'"==""){
					if "`spec_num1'"=="1" & "`spec_num2'"=="1" & "`spec_num3'"=="1"{
					local addlegend "order(7 "Specification 1" 8 "Specification 2" 9 "Specification 3")"
					}
					if "`spec_num1'"=="1" & "`spec_num2'"=="" & "`spec_num3'"==""{
					local addlegend "order(3 "Specification 1")"
					}
					if "`spec_num1'"=="1" & "`spec_num2'"=="1" & "`spec_num3'"==""{
					local addlegend "order(5 "Specification 1" 6 "Specification 2")"
					}
					if "`spec_num1'"=="1" & "`spec_num2'"=="" & "`spec_num3'"=="1"{
					local addlegend "order(5 "Specification 1" 6 "Specification 3")"
					}
				}
				if ("`perturbationtest'"!="") | ("`multitest'"!="") | ("`tuplestest'"!="")|("`leaveoneouttest'"!="") {
				local addlegend "off"
				}
			}
			
			if ("`legend'"!="") {
			tokenize `"`legend'"', parse("123")
				if ("`4'"=="")&("`6'"=="") {
				local addlegend=`"order(3"' + `"""' + `"`2'"' + `"""')"'
				}
				if ("`4'"!="") & ("`6'"=="") {
				local addlegend=`"order(5 "`2'" 6 "`4'")"'
				}			
				if ("`4'"!="") & ("`6'"!="") {
				local addlegend=`"order(7 "`2'" 8 "`4'" 9 "`6'")"'
				}						
			}
		}
		if "`fstat'"!=""{
			if ("`legend'"=="") {
				if ("`perturbationtest'"=="") & ("`multitest'"=="") & ("`tuplestest'"=="") & ("`leaveoneouttest'"==""){
					if "`spec_num1'"=="1" & "`spec_num2'"=="1" & "`spec_num3'"=="1"{
					local addlegend "order(1 "Specification 1" 2 "Specification 2" 3 "Specification 3")"
					}
					if "`spec_num1'"=="1" & "`spec_num2'"=="" & "`spec_num3'"==""{
					local addlegend "order(1 "Specification 1")"
					}
					if "`spec_num1'"=="1" & "`spec_num2'"=="1" & "`spec_num3'"==""{
					local addlegend "order(1 "Specification 1" 2 "Specification 2")"
					}
					if "`spec_num1'"=="1" & "`spec_num2'"=="" & "`spec_num3'"=="1"{
					local addlegend "order(1 "Specification 1" 3 "Specification 3")"
					}
				}
				if ("`perturbationtest'"!="") | ("`multitest'"!="") | ("`tuplestest'"!="")|("`leaveoneouttest'"!="") {
				local addlegend "off"
				}
			}
			
			if ("`legend'"!="") {
			tokenize `"`legend'"', parse("123")
				if ("`4'"=="")&("`6'"=="") {
				local addlegend=`"order(1"' + `"""' + `"`2'"' + `"""')"'
				}
				if ("`4'"!="") & ("`6'"=="") {
				local addlegend=`"order(1 "`2'" 2 "`4'")"'
				}			
				if ("`4'"!="") & ("`6'"!="") {
				local addlegend=`"order(1 "`2'" 2 "`4'" 3 "`6'")"'
				}						
			}
		}
	}
	
	* Symbols of graph of different shape
	if (("`symbols'"=="") & ("`symbol1'"=="") & ("`symbol2'"=="") & ("`symbol3'"=="")) local addsymbols "msize(medsmall) symbol(circle)" 
	
	if ("`symbols'"=="") & (("`symbol1'"!="") | ("`symbol2'"!="") | ("`symbol3'"!="")){
	local addsymbols "" 
	if ("`symbol1'"=="") local addsymbol1="symbol(circle)"
	if ("`symbol2'"=="") local addsymbol2="symbol(circle)"
	if ("`symbol3'"=="") local addsymbol3="symbol(circle)"
	if ("`symbol1'"!="") local addsymbol1="symbol(`symbol1')"
	if ("`symbol2'"!="") local addsymbol2="symbol(`symbol2')"
	if ("`symbol3'"!="") local addsymbol3="symbol(`symbol3')"
	}

	if ("`symbols'"!="") |  (("`symbols'"!="") & (("`symbol1'"!="") | ("`symbol2'"!="") | ("`symbol3'"!=""))) {
	local addsymbols "" 
	if ("`symbol1'"=="") local addsymbol1="symbol(square)"
	if ("`symbol2'"=="") local addsymbol2="symbol(X)"
	if ("`symbol3'"=="") local addsymbol3="symbol(circle)"
	if ("`symbol1'"!="") local addsymbol1="symbol(`symbol1')"
	if ("`symbol2'"!="") local addsymbol2="symbol(`symbol2')"
	if ("`symbol3'"!="") local addsymbol3="symbol(`symbol3')"
	}
	
	* Size
	if ("`xsize'"=="") local xsize "8"
	if ("`ysize'"=="") local ysize ""
	* Lines and labels
	if ("`yline'"=="") & ("`fstat'"=="") local yline "0, lpattern(dash) lcolor(gray)"
	if ("`yline'"=="") & ("`fstat'"!="") local yline "10, lpattern(dash) lcolor(gray)"
		* Locals with the date format for the xline
		local span=`win_iter_counter'
		local startp6=`end'+6
		local endp6=`end'+6
		local startday : di %tdMonth_dd `start'
		local endday : di %tdMonth_dd `end'
		local startmonth : di %tdMonth_YYYY `start'
		local endmonth : di %tdMonth_YYYY `end'
		local startweek : di %tdMon_dd `start'
		local endweek : di %tdMon_dd `end'
		local startweekp6 : di %tdMon_dd `startp6'
		local endweekp6: di %tdMon_dd `endp6'
		local startweek="`startweek'"+"_"+"-"+"`startweekp6'"
		local endweek="`endweek'"+"_"+"-"+"`endweekp6'"
	if ("`xline'"=="") & ("`xline'"!="off")  local addxline "xline(1 `span', lpattern(dash) lcolor(gray%60) lwidth(thin))"
	if ("`xline'"!="") & ("`xline'"!="off")  local addxline "xline(`xline')"
	* xlabel if not specified (xlabel not specified and from user have to be in this order)
	if ("`xlabel'"==""){
	if ("`time'"=="") local xlabel "1 "`start'" `span' "`end'""
	if ("`time'"=="year") local xlabel "1 "`start'" `span' "`end'""	
	if ("`time'"=="month") local xlabel "1 "`startmonth'" `span' "`endmonth'""		
	if ("`time'"=="week") local xlabel "1 "`startweek'" `span' "`endweek'""		
	if ("`time'"=="day") local xlabel "1 "`startday'" `span' "`endday'""		
	}
	* xlabel from user 	
	if ("`xlabel'"!="") {
	local counter_xlabel=0
		foreach element in `xlabel' {
		local counter_xlabel=`counter_xlabel'+1
			if `counter_xlabel'==1 {
			local xlabel ="`element'"+"§"
			}
			if `counter_xlabel'>1 {
				if mod(`counter_xlabel',2)==0{
				local xlabel ="`xlabel'"+"`element'"+"§§"	
				}
				if mod(`counter_xlabel',2)==1 {
				local xlabel ="`xlabel'"+"`element'"+"§"	
				}
			}
		}
	local xlabel=subinstr(`"`xlabel'"',"§§",`"" "',.)
	local xlabel=subinstr(`"`xlabel'"',"§",`" ""',.)
	}
	
	if ("`perturbationtest'"=="") & ("`multitest'"=="") & ("`tuplestest'"=="") & ("`leaveoneouttest'"=="") {
		if "`fstat'"==""{
		* fix offset in case only specs 1 and 2 are run (to match the labels)
		local addoffset="offset(-`offset')"
		if ("`spec_num2'"=="") & ("`spec_num3'"=="")  local addoffset="offset(0)"
		local coefplot_string_ci="(matrix(matrix_coef_`pt_iteration'_1), `addoffset' ci(matrix_ci_`pt_iteration'_1)  ciopts(color(`speccolor1'%50)) color(maroon%0))"
			forvalues spec = 2/3 {
				if "`spec_num`spec''"=="1"{
					if "`spec'"== "2"{
					if ("`spec_num2'"!="") & ("`spec_num3'"!="") local spacing=""
					if ("`spec_num2'"!="") & ("`spec_num3'"=="") local spacing="offset(+`offset')"
					local color="`speccolor2'%70"
					}
					if "`spec'"== "3"{
					local color="`speccolor3'%90"
					local spacing="offset(+`offset')"
					}
				local coefplot_string_ci="`coefplot_string_ci'"+"(matrix(matrix_coef_`pt_iteration'_`spec'), `spacing' ci(matrix_ci_`pt_iteration'_`spec')  ciopts(color(`color')) color(maroon%0))"
				}
			}	
			
			local coefplot_string_coef="(matrix(matrix_coef_`pt_iteration'_1), `addoffset' noci color(`speccolor1'%40) `addsymbol1' mlwidth(vthin))"
			forvalues spec = 2/3 {
				if "`spec_num`spec''"=="1"{
					if "`spec'"== "2"{
					if ("`spec_num2'"!="") & ("`spec_num3'"!="") local spacing=""
					if ("`spec_num2'"!="") & ("`spec_num3'"=="") local spacing="offset(+`offset')"
					local color="`speccolor2'%60"
					}
					if "`spec'"== "3"{
					local color="`speccolor3'%70"
					local spacing="offset(+`offset')"
					}
				local coefplot_string_coef="`coefplot_string_coef'"+"(matrix(matrix_coef_`pt_iteration'_`spec'), `spacing' noci `addsymbol`spec'' color(`color') mlwidth(vthin))"
				}
			}	
		}
		if "`fstat'"!=""{
		* fix offset in case only specs 1 and 2 are run (to match the labels)
		local addoffset="offset(-`offset')"
		if ("`spec_num2'"=="") & ("`spec_num3'"=="")  local addoffset="offset(0)"		
			local coefplot_string_coef="(matrix(matrix_coef_`pt_iteration'_1), `addoffset' noci color(`speccolor1'%40) `addsymbol1' mlwidth(vthin))"
			forvalues spec = 2/3 {
				if "`spec_num`spec''"=="1"{
					if "`spec'"== "2"{
					if ("`spec_num2'"!="") & ("`spec_num3'"!="") local spacing=""
					if ("`spec_num2'"!="") & ("`spec_num3'"=="") local spacing="offset(+`offset')"
					local color="`speccolor2'%60"
					}
					if "`spec'"== "3"{
					local color="`speccolor3'%70"
					local spacing="offset(+`offset')"
					}
				local coefplot_string_coef="`coefplot_string_coef'"+"(matrix(matrix_coef_`pt_iteration'_`spec'), `spacing' noci `addsymbol`spec'' color(`color') mlwidth(vthin))"
				}
			}	
		}
	}
		
	if ("`perturbationtest'"!="") {
		local first_element `: word 1 of `vals_perturbation_test''
		
		local coefplot_string_ci="(matrix(matrix_coef_`first_element'_1), ci(matrix_ci_`first_element'_1) cirecast(rarea) ciopts(color(`testcicolor'%7)) color(maroon%0))"
		local counter1=0
		foreach pt_iteration in `vals_perturbation_test' {
		local counter1=`counter1'+1
			if `counter1'>1 {
			local coefplot_string_ci="`coefplot_string_ci'"+"(matrix(matrix_coef_`pt_iteration'_1), ci(matrix_ci_`pt_iteration'_1) cirecast(rarea) ciopts(color(`testcicolor'%7)) color(maroon%0))"
			}
		}		
		local coefplot_string_ci2="(matrix(matrix_coef_`first_element'_1), ci(matrix_ci_`first_element'_1) cirecast(rline) ciopts(color(`testcicolor') lwidth(vthin)) color(navy%0))"
		local counter2=0
		foreach pt_iteration in `vals_perturbation_test' {
		local counter2=`counter2'+1
			if `counter2'>1 {
			local coefplot_string_ci2="`coefplot_string_ci2'"+"(matrix(matrix_coef_`pt_iteration'_1), ci(matrix_ci_`pt_iteration'_1) cirecast(rline) ciopts(color(`testcicolor') lwidth(vthin)) color(navy%0))"
			}
		}	
		local coefplot_string_coef="(matrix(matrix_coef_`first_element'_1), noci color(`testcoefcolor') mlwidth(thin))"
		local counter3=0
		foreach pt_iteration in `vals_perturbation_test' {
		local counter3=`counter3'+1
			if `counter3'>1 {
			local coefplot_string_coef="`coefplot_string_coef'"+"(matrix(matrix_coef_`pt_iteration'_1), noci color(`testcoefcolor') mlwidth(thin))"
			}	
		}	
	}

	if ("`tuplestest'"!="") {
		local coefplot_string_ci="(matrix(matrix_coef_1_1), ci(matrix_ci_1_1) cirecast(rarea) ciopts(color(`testcicolor'%7)) color(maroon%0))"
		forvalues pt_iteration=2/`tuplesnumber'{
		local coefplot_string_ci="`coefplot_string_ci'"+"(matrix(matrix_coef_`pt_iteration'_1), ci(matrix_ci_`pt_iteration'_1) cirecast(rarea) ciopts(color(`testcicolor'%7)) color(maroon%0))"
		}		
		local coefplot_string_ci2="(matrix(matrix_coef_1_1), ci(matrix_ci_1_1) cirecast(rline) ciopts(color(`testcicolor') lwidth(vthin)) color(navy%0))"
		forvalues pt_iteration=2/`tuplesnumber'{
		local coefplot_string_ci2="`coefplot_string_ci2'"+"(matrix(matrix_coef_`pt_iteration'_1), ci(matrix_ci_`pt_iteration'_1) cirecast(rline) ciopts(color(`testcicolor') lwidth(vthin)) color(navy%0))"
		}	
		local coefplot_string_coef="(matrix(matrix_coef_1_1), noci color(`testcoefcolor') mlwidth(thin))"
		forvalues pt_iteration=2/`tuplesnumber'{
		local coefplot_string_coef="`coefplot_string_coef'"+"(matrix(matrix_coef_`pt_iteration'_1), noci color(`testcoefcolor') mlwidth(thin))"
		}	
	}	
	
	if ("`leaveoneouttest'"!="") {
		local coefplot_string_ci="(matrix(matrix_coef_1_1), ci(matrix_ci_1_1) cirecast(rarea) ciopts(color(`testcicolor'%7)) color(maroon%0))"
		forvalues pt_iteration=2/`leaveoneoutvarnumber'{
		local coefplot_string_ci="`coefplot_string_ci'"+"(matrix(matrix_coef_`pt_iteration'_1), ci(matrix_ci_`pt_iteration'_1) cirecast(rarea) ciopts(color(`testcicolor'%7)) color(maroon%0))"
		}		
		local coefplot_string_ci2="(matrix(matrix_coef_1_1), ci(matrix_ci_1_1) cirecast(rline) ciopts(color(`testcicolor') lwidth(vthin)) color(navy%0))"
		forvalues pt_iteration=2/`leaveoneoutvarnumber'{
		local coefplot_string_ci2="`coefplot_string_ci2'"+"(matrix(matrix_coef_`pt_iteration'_1), ci(matrix_ci_`pt_iteration'_1) cirecast(rline) ciopts(color(`testcicolor') lwidth(vthin)) color(navy%0))"
		}	
		local coefplot_string_coef="(matrix(matrix_coef_1_1), noci color(`testcoefcolor') mlwidth(thin))"
		forvalues pt_iteration=2/`leaveoneoutvarnumber'{
		local coefplot_string_coef="`coefplot_string_coef'"+"(matrix(matrix_coef_`pt_iteration'_1), noci color(`testcoefcolor') mlwidth(thin))"
		}	
	}

	if ("`multitest'"!="") {
		local first_element `: word 1 of `multitest''
		
		local coefplot_string_ci="(matrix(matrix_coef_`first_element'_1), ci(matrix_ci_`first_element'_1) cirecast(rarea) ciopts(color(`testcicolor'%7)) color(maroon%0))"
		local counter1=0
		foreach pt_iteration in `multitest' {
		local counter1=`counter1'+1
			if `counter1'>1 {
			local coefplot_string_ci="`coefplot_string_ci'"+"(matrix(matrix_coef_`pt_iteration'_1), ci(matrix_ci_`pt_iteration'_1) cirecast(rarea) ciopts(color(`testcicolor'%7)) color(maroon%0))"
			}
		}		
		local coefplot_string_ci2="(matrix(matrix_coef_`first_element'_1), ci(matrix_ci_`first_element'_1) cirecast(rline) ciopts(color(`testcicolor') lwidth(vthin)) color(navy%0))"
		local counter2=0
		foreach pt_iteration in `multitest' {
		local counter2=`counter2'+1
			if `counter2'>1 {
			local coefplot_string_ci2="`coefplot_string_ci2'"+"(matrix(matrix_coef_`pt_iteration'_1), ci(matrix_ci_`pt_iteration'_1) cirecast(rline) ciopts(color(`testcicolor') lwidth(vthin)) color(navy%0))"
			}
		}	
		local coefplot_string_coef="(matrix(matrix_coef_`first_element'_1), noci color(`testcoefcolor') mlwidth(thin))"
		local counter3=0
		foreach pt_iteration in `multitest' {
		local counter3=`counter3'+1
			if `counter3'>1 {
			local coefplot_string_coef="`coefplot_string_coef'"+"(matrix(matrix_coef_`pt_iteration'_1), noci color(`testcoefcolor') mlwidth(thin))"
			}	
		}	
	}

	coefplot `coefplot_string_ci' `coefplot_string_ci2' `coefplot_string_coef' , nooffsets graphregion(margin(3 8 3 3)) graphregion(fcolor(white)) vertical yline(`yline') `addxline' ysize(`ysize') xsize(`xsize') ytitle(`ytitle') xtitle(`xtitle')  ylabel(`ylabel') xlabel(`xlabel') legend(`addlegend')  `addsymbols'

end	
