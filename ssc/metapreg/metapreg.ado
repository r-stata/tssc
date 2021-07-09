/* 	Updates History as metaprop_one
	1. 22-10-2014:
	- Fixing ftt when all studies have p almost zero.
	- Fixing percent.
	- Change percent to allow other scales.
	
	2. 03-02-2015
	- sgweight bug fix.

	3. 23-02-2015
	- dp fix.
	
	4. 09-03-2015
	- Weight displayed to reflect sgweights.
	- Return appropriate values after ftt.
	
	5. 26-11-2015
	- Fix rfdist with ftt and logit
	
	6. 20-07-2016
	- Fix noOverall and NoSubroup
	
	7. 21-09-2015
	- Include one-sized stratum in the between group test of heterogeneity
	
	8. 04-08-2018
	- Allow metaregression with logit. 
	- Use binreg and meqrlogit instead of melogit
	- Add modelopts for optimisation control
	- Sumstat() for summary statistic
	- Fix rfdist with ftt and logit when power is used
	- Include prediction intervals
	- comparative analysis (Independent/dependent samples)
	- ci optios for rr: koopman
	- Allow more ci options: wald, wilson, agresti, exact, jeffreys.
	- Removed keep/nokeep option
	- Maybe have a file name to save the dataset plotted??
	
	Updates History as metapreg:
	
	Suggestions:
	- Bootstrap prediction intervals for RR
	- other ci optios for rr
	- check the random-effects and suggest model simplification
*/
/*===============================================================================================*/
/*==================================== METAPREG  ================================================*/
/*===============================================================================================*/

capture program drop metapreg
program define metapreg, rclass sortpreserve byable(recall)

version 14.1

	#delimit ;

	syntax varlist(min=2 default=none) [if] [in] ,	
		STUdyid(varname) [  
		AStext(integer 50) 
		BOXOpt(string) 
		BOXSca(real 100.0) 
		BReps(integer 1000)
		BY(string)
		CC(string) 
		CImethod(string) 
		CIOpt(string) 
		CLassic
		DIAMopt(string) 
		DOUBLE 
		DOWNload(string) 
		DP(integer 2) 
		FOrce 
		FTt 
		ILevel(integer 95) 
		INTeraction
		IV
		LABEL(string) 
		LCols(varlist) 
		Model(string) 
		noBOX
		noGRaph 
		NOHET  
		noOVerall 
		noOVLine 
		noSECSub  
		noSTats 
		noSUBgroup 
		noTAble 
		noWT 
		OLevel(integer 95) 
		OLineopt(string) 
		OUTPlot(string)
		OUTTable(string)
		PAIRed
		PLOTStat(string asis)
		POINTopt(string) 
		POwer(integer 0)
		PREDciOpt(string)
		RCols(varlist) 
		RFdist 
		RFLevel(integer 95) 
		SECond(string) 
		SGWeight 
		SORtby(passthru) 
		SUBLine
		SUMMARYonly
		TABLEStat(string asis)
		TEXts(real 100.0) 
		WGT(varname numeric)
		XLAbel(passthru) 
		XTick(passthru) 
		* ];

		#delimit cr
		
		preserve

		marksample touse, strok 
		qui drop if !`touse'
		
		qui count
		if `=r(N)' < 2 {
			di as err "Insufficient data to perform this meta-analysis"
			exit 
		}
		
		cap drop mu
		gen mu = 1
		
		if _by() {
			global by_index_ = _byindex()
			if "`graph'" == "" & "$by_index_" == "1" {
				cap graph drop _all
			}
		}
		
		/*check fixed/random/model options*/
		if "`wgt'" != "" {
			local model "fixed"
		}
		else {
			tokenize "`model'", parse(",")
			local model  = strlower("`1'")
			local modelopts = "`3'"
		}
		
		local otheropts `"`options'"'
		
		if (("`paired'" == "" & "`model'" == "fixed") | ("`paired'" != "" & "`model'" == "marginal")) & "`rfdist'" != "" {
			di as res _n  "Note: Option rfdist has no effect and is ignored."
			local rfdist
		}
		
		//Dont do marginalisation
		if (("`model'" == "marginal") | ("`model'" == "fixed" & "`paired'" == "")) & "`conditional'" != "" {
			di as res _n  "Note: Option noconditional is unnecessary and is ignored."
			local conditional ""
		}

		if `astext' > 90 | `astext' < 10 {
			di as error "Percentage of graph as text (ASTEXT) must be within 10-90%"
			di as error "Must have some space for text and graph"
			exit
		}
		if `texts' < 20 | `texts' > 500 {
			di as error "Text scale (TEXTSize) must be within 20-500"
			di as error "Value is character size relative to graph"
			di as error "Outside range will either be unreadable or too large"
			exit
		}

		if ("`by'"=="" & "`overall'"!="") {
			local wt "nowt"
		}
		if `ilevel'<1 {
			local ilevel `ilevel'*100
		}
		if `ilevel'>99 | `ilevel'<10 {
			local ilevel 95
		}

		if `olevel'<1 {
			local olevel `olevel'*100
		}
		if `olevel'>99 | `olevel'<10 {
			local olevel 95
		}

		if `rflevel'<1 {
			local rflevel `rflevel'*100
		}
		if `rflevel'>99 | `olevel'<10 {
			local rflevel 95
		}

		forvalues i = 1/14 {  /**************Here I create the global scalar macros S_i*/
			local S_`i' .
		}
		local hmean .
		local fittedmodel 
			
		*If not using own weights set fixed as default
		if "`model'"=="" & ( "`wgt'"=="" ) {
			local model "fixed"
		}

		if "`wgt'"!="" {
		*User defined weights verification
			confirm numeric variable `wgt'
			*local wgt "`wgt'"
		}
		*declare study labels for display
		if "`label'"!="" {
			tokenize "`label'", parse("=,")
			while "`1'"!="" {
				cap confirm var `3'
				if _rc!=0  {
					di as err "Variable `3' not defined"
					exit
				}
				local `1' "`3'"
				mac shift 4
			}
		}
		
		tempvar code

		qui {
			*put name/year variables into appropriate macros

			if "`namevar'"!="" {
				local lbnvl : value label `namevar'
				if "`lbnvl'"!=""  {
					quietly decode `namevar', gen(`code')
				}
				else {
					gen str10 `code'=""
					cap confirm string variable `namevar'
					if _rc==0 {
						replace `code'=`namevar'
					}
					else if _rc==7 {
						replace `code'=string(`namevar')
					}
				}
			}
			if "`namevar'"=="" & "`lcols'" != "" {
				local var1 = word("`lcols'",1)
				cap confirm var `var1'
				if _rc!=0  {
					di in re "Variable `var1' not defined"
					exit _rc
				}
				local namevar "`var1'"
				local lbnvl : value label `namevar'
				if "`lbnvl'"!=""  {
					quietly decode `namevar', gen(`code')
				}
				else {
					gen str10 `code'=""
					cap confirm string variable `namevar'
					if _rc==0 {
						replace `code'=`namevar'
					}
					else if _rc==7 {
						replace `code'=string(`namevar')
					}
				}	
			}
			if "`namevar'"=="" & "`lcols'" == "" {
				/*if "`paired'" != "" {
					gen str3 `code' = string(_n)
				}
				else {*/
					cap confirm numeric variable `studyid'
					if _rc != 0 {
						gen `code' = `studyid'
					}
					if _rc == 0{
						gen `code' = string(`studyid')
					}
				*}
			}
			if "`yearvar'"!="" {
				local yearvar "`yearvar'"
				cap confirm string variable `yearvar'
				if _rc==7 {
					local str "string"
				}
				if "`namevar'"=="" {
					replace `code'=`str'(`yearvar')
				}
				else {
					replace `code'=`code'+" ("+`str'(`yearvar')+")"
				}
			}
			if "`wgt'"!="" {
				*User defined weights verification
				if "`model'" !="fixed" {
					di as err "Option model(random) invalid with user-defined weights"
					exit
				}
				confirm numeric variable `wgt'
				local wgt "wgt(`wgt')"
			}
		} /* End of quietly loop */

		tokenize "`varlist'", parse(" ")

		if "`dependent'" == "" {
			cap assert `2' >= `1' if (`1' ~= .)
			if _rc != 0 {
				di as err " order should be {n, N}"
				exit _rc
			}
			local dep "`1' `2'"
			macro shift 2
		}
		if "`dependent'" != "" {
			if "`4'" == "" {
				di as error " order should be a b c d [covariates]"
				exit
			}
			forvalues num = 1/4 {
				cap confirm integer number `num'
				if _rc != 0 {
					di as error "`num' found where integer expected"
					exit
				}
			}
			local dep "`1' `2' `3' `4'"
			macro shift 4
		}
		local regressors "`*'"
		local p: word count `regressors'
		
		if `p' < 2 & "`interaction'" !="" {
			di as error "Interactions allowed with atleast 2 covariates"
			exit
		}
		
		local mixedcov = 0
		if "`regressors'" != "" {		
			foreach cov of local regressors {
				cap confirm string variable `cov'
				if _rc != 0 {
					local mixedcov = 1
				}
			}
		}
		if "`paired'" != "" {
			cap assert `p' > 0
			if _rc != 0 {
				di as error "Repeated measures analysis requires at least 1 covariate to be specified"
				exit _rc
			}
			cap assert "`studyid'" != ""
			if _rc != 0 {
				di as error "Please specify study identifier in studyid() option"
				exit _rc
			}
		}
		if "`outplot'" == "rr" {
			cap assert `p' > 0
			if _rc != 0 {
				di as error "Option outtable(rr) requires at least 1 covariate to be specified"
				exit _rc
			}
		}
		
		if "`outplot'" == "" {
			local outplot abs
		}
		else {
			local outplot = strlower("`outplot'")
			if "`outplot'" == "rr" {
				cap assert "`paired'" != "" 
				if _rc != 0 {
					di as error "Option outplot(rr) only avaialable for repeated measures analysis"
					di as error "Repeated measures analysis specified with -paired- option"
					exit _rc
				}
			}
		}
		
		if "`cc'" != "" {
			cap assert `cc'>= 0 
			if _rc!=0 {
				di as err "Continuity correction must be positive"
				exit _rc
			}
			cap assert ("`iv'" != "") == 1
			if _rc!=0 {
				di as err "CC only allowed in the inverse-variance weighted analysis"
				di as err "specify the inverse-variance weighted analysis with IV option"
				exit _rc
			}
		}
		
		cap assert ("`cc'" != "")  + ("`ftt'" != "") < 2
		if _rc!=0 {
			di as err "CC and FTT should not be used together"
			exit _rc
		}
		
		if ("`ftt'" != "") {
			cap assert ("`iv'" != "") == 1
			if _rc!=0 {
				di as err "FTT only allowed in the inverse-variance weighted analysis"
				di as err "specify the inverse-variance weighted analysis with IV option"
				exit _rc
			}
		}
		
		if  (("`cc'" != "")  & ("`iv'" != "")) | (("`ftt'" != "")  & ("`iv'" != "")) | ("`iv'" != "")  {
			local logit "nologit"
		}

		cap assert "`studyid'" != ""
		if _rc!=0 {
			di as err "The study identifier variable is not specified"
			di as err "Specify it with STUDYID(varname) "
			exit _rc
		}
		
		
		/*Comparative((inde)dependent) analysis only allowed in logistic regression*/
		if "`paired'" !="" | "`dependent'" !="" {	
			if "`iv'" != "" {
				di as err "Comparative analysis only allowed in logistic regression"
				exit
			}
		}
		
		if "`iv'" != "" {
			local callalg "iv_init"
		} 
		else {
			local callalg "maxll"
		}
		/*regressors and by not entered by the user simultaneously*/	
		if "`regressors'" != "" {
			if "`by'"!="" {
				di as error "either specify by() or covariates but not both"
				exit
			}
			foreach reg of local regressors {
				cap confirm var `reg'
				if _rc!=0 {
					di in red "Variable `reg' does not exist"
					exit _rc
				}
			}
			/*Send to by if necessary*/
			if (((`p' == 1 & "`outplot'" == "abs") | (`p' == 2 & "`outplot'" == "rr")) & `mixedcov' != 1) {
				local by "`regressors'" 
			}
		}

		if "`plotstat'" == "" {
			if "`outplot'" == "abs" {
				local plotstat "Proportion"
			}
			if "`outplot'" == "rr" {
				local plotstat "RelRatio"
			}
		}
		
		if "`by'" != "" {
			foreach vby of local by {
				cap confirm var `vby'
				if _rc!=0 {
					di in red "Variable `vby' does not exist"
					exit _rc
				}
			}
			local by "by(`by')"
			local nextcall "nextcall(`callalg')"
			local callalg "metanby"
			*local sstat "sumstat(`sumstat')"
		}
		if "`by'" != "" {
			local subline "`subline'"
		}

		//Second model
		if "`second'" != "" {
			tokenize "`second'", parse(",")
			local model_2   = strlower("`1'")
			local model_2opts = "`3'"
		}
		if "`callalg'" != "preg" & "`logit'" == "" {
			//Second model
			if "`second'" != "" {
				local nu = "mu"	
				local VarX: word 1 of `regressors'			
				forvalues i=1/`p' {
					local c:word `i' of `regressors'
					if "`interaction'" == "" {
						local nu = "`nu' + {c ss}_`i'*`c'"
					}
					else {
						if `i' == 1 {
							local nu 
						}
						else if `i' == 2{
							local nu = "{c ss}_`i'*`c'*`VarX'"
						}
						else {
							local nu = "`nu' + {c ss}_`i'*`c'*`VarX'"
						}
					}
				} 
				if "`paired'" == "" {
					if "`model_2'" == "random" {
						local nu = "`nu' + `studyid'"
					}
				}
				else {
					if "`model_2'" == "random" {
						local nu = "`nu' + `studyid' + `VarX'"
					}
					if "`model_2'" == "fixed" {
						local nu = "`nu' + `studyid'"
					}
				}
				di as res _n "*********************************** Second fitted model ***************************************"  _n
				tokenize `varlist'
				di "{phang} `1' ~ binomial(logit(p), `2'){p_end}"
				di "{phang} logit(p) = `nu'{p_end}"
				
				if "`paired'" == "" {
					if "`model_2'" == "random" {	
						di "{phang}`studyid' ~ normal(0, tau_b){p_end}"
					}
				}
				else {
					if "`model_2'" == "random" {
						di "{phang}`studyid' ~ normal(0, tau_b){p_end}"
						local VarX: word 1 of `regressors'
						di "{phang}`VarX' ~ normal(0, tau_w){p_end}"
					}
					else if ("`model_2'" == "fixed") {
						di "{phang}`studyid' ~ normal(0, tau_b){p_end}"
					}
				}
				local ftitle "First"
			}
			//First model
			local nu = "mu"	
			local VarX: word 1 of `regressors'
			forvalues i=1/`p' {
				local c:word `i' of `regressors'
				if "`interaction'" == "" {
					local nu = "`nu' + {c ss}_`i'*`c'"
				}
				else {
					if `i' == 1 {
						local nu 
					}
					else if `i' == 2{
						local nu = "{c ss}_`i'*`c'*`VarX'"
					}
					else {
						local nu = "`nu' + {c ss}_`i'*`c'*`VarX'"
					}
				}
			} 
			if "`paired'" == "" {
				if "`model'" == "random" {
					local nu = "`nu' + `studyid'"
				}
			}
			else {
				if "`model'" == "random" {
					local nu = "`nu' + `studyid' + `VarX'"
				}
				if "`model'" == "fixed" {
					local nu = "`nu' + `studyid'"
				}
			}
			
			di as res _n "*********************************** `ftitle' Fitted model ***************************************"  _n
			
			tokenize `varlist'
			di "{phang} `1' ~ binomial(logit(p), `2'){p_end}"
			di "{phang} logit(p) = `nu'{p_end}"
			
			if "`paired'" == "" {
				if "`model'" == "random" {	
					di "{phang}`studyid' ~ normal(0, tau_b){p_end}"
				}
			}
			else {
				if "`model'" == "random" {
					di "{phang}`studyid' ~ normal(0, tau_b){p_end}"
					local VarX: word 1 of `regressors'
					di "{phang}`VarX' ~ normal(0, tau_w){p_end}"
				}
				else if ("`model'" == "fixed") {
					di "{phang}`studyid' ~ normal(0, tau_b){p_end}"
				}
			}
			di _n"*********************************** ************* ***************************************" _n
		}
		
		if "`boxopt'" != "" {
			local boxopt = "boxopt(`boxopt')" 
		}
		if "`logit'" == "" {
			local breps = "breps(`breps')"
		}
		else {
			local breps
		}
		if "`cc'"  != "" {
			local cc = "cc(`cc')"
		}
		if "`ciopt'" != "" {
			local ciopt = "ciopt(`ciopt')"
		}
		if "`diamopt'" != "" {
			local diamopt = "diamopt(`diamopt')"
		} 
		if "`download'" != "" {
			local download = "download(`download')"
		}
		if "`lcols'" != "" {
			local lcols = "lcols(`lcols')"
		}
		if "`olineopt'" != "" {
			local olineopt = "olineopt(`olineopt')"
		} 
		if "`outtable'" != "" {
			local outtable = "outtable(`outtable')"
		}
		if "`plotstat'" != "" {
			local plotstat = "plotstat(`plotstat')"
		}
		if "`pointopt'" != "" {
			local pointopt = "pointopt(`pointopt')"
		} 
		if "`predciopt'"!= "" {
			local predciopt = "predciopt(`predciopt')"
		} 
		if "`rcols'" != "" {
			local rcols = "rcols(`rcols')"
		} 
		if "`modelopts'" != "" {
			local modelopts = "modelopts(`modelopts')"
		}
		if "`second'" != "" {
			local model_2 = "model(`second')"
			local model2 = "model2(`second')"
		} 
		if "`model_2opts'" != "" {
			local model_2opts = "modelopts(`model_2opts')"
			local model2opts = "model2opts(`model_2opts')"
		}
		if "`sortby'" != "" {
			local sortby = "`sortby'"
		}
		if "`tablestat'" != "" {
			local tablestat = "tablestat(`tablestat')"
		}
		if "`xlabel'"  != "" {
			local xlabel = "`xlabel'"
		}
		if "`xtick'" != "" {
			local xtick = "`xtick'"
		}
		if "`options'" != "" {
			local otheropts = "otheropts(`options')"
		}
		
		
		if "`second'" != "" {
			if "`callalg'" != "metanby" {		// just run through twice
				if  "`outtable'" != ""  {
					di as res _n "*********************************** Second fitted model ***************************************"  _n
				}
				#delimit ;
				
				`callalg' `varlist', 
				studyid(`studyid') astext(`astext') `boxopt' boxsca(`boxsca') `breps' `by' `cc' cimethod(`cimethod') 
				`ciopt' `classic' `paired' `diamopt' `double' `download' dp(`dp') `force' `ftt'  ilevel(`ilevel') 
				`interaction' `logit' label(`code') `lcols' `model_2' `model_2opts' `box' nograph `het'  `overall'  `ovline' `secsub'  `stats' 
				`subgroup'  notable `wt'  `nextcall' olevel(`olevel') `olineopt' outplot(`outplot') `outtable' `otheropts' 
				`plotstat' `pointopt' power(`power') `predciopt' `rcols' `rfdist'  rflevel(`rflevel') rjhsecond 
				`sgweight' `sortby' `subline' `summaryonly' `tablestat' texts(`texts') `wgt' `xlabel'  `xtick';
				
				#delimit cr
			
				local MA_second_ES = r(ES)			
				local MA_second_SE_ES = r(seES)
				local MA_second_LCI = r(ci_low)
				local MA_second_UCI = r(ci_upp)
				local MA_second_Z = r(z)
				local MA_second_P_Z = r(p_z)
				local MA_second_HET = r(het)
				local MA_second_DF = r(df)
				local MA_second_P_HET = r(p_het)
				local MA_second_CHI2 = r(chi2)
				local MA_second_PCHI2 = r(p_chi2)
				local MA_second_TAU2 = r(tau2)
				local MA_second_WTAU2 = r(wtau2)
				local MA_second_I2 = r(i_sq)
				local MA_second_hmean = r(hmean)
				local MA_second_model = r(model)
				
				if "`logit'" != "" & "`callalg'" != "preg" {
				tempname MA_second_raw MA_second_logodds MA_second_absout MA_second_rrout MA_second_predci MA_second_opredci
					if ("`outtable'" == "raw") | (strpos("`outtable'", "raw") != 0) {
						mat `MA_second_raw' = r(raw)
					}
					if ("`outtable'" == "logodds") | (strpos("`outtable'", "logodds") != 0) {
						mat `MA_second_logodds' = r(logodds)
					}			
					if ("`outplot'" == "abs")  | ("`outtable'" == "abs") | (strpos("`outtable'", "abs") != 0) {
						mat `MA_second_absout' = r(absout)
					}				
					if ("`outplot'" == "rr") | ("`outtable'" == "rr") | (strpos("`outtable'", "rr") != 0) {
						mat `MA_second_rrout' = r(rrout)
					}				
					if "`rfdist'" != "" {
						mat `MA_second_predci' = r(predci)
						mat `MA_second_opredci' = r(opredci)
					}
				}
				if  "`outtable'" != ""  {
					di as res _n "*********************************** First fitted model ***************************************"  _n
				}
				#delimit ;
				`callalg' `varlist',
				studyid(`studyid') astext(`astext') `boxopt' boxsca(`boxsca') `breps' `by' `cc' cimethod(`cimethod') 
				`ciopt' `classic' `paired'  `diamopt' `double' `download' dp(`dp') `force' `ftt'  ilevel(`ilevel') 
				`interaction' `logit' label(`code') `lcols' model(`model') `modelopts' `nextcall' `box' `graph' `het'  `overall'  `ovline' `secsub'   `stats' `subgroup'  `table'  `wt'  olevel(`olevel') `olineopt'`otheropts' outplot(`outplot') `outtable' `plotstat'`pointopt' power(`power') `predciopt' `rcols' `rfdist'  rflevel(`rflevel') `sgweight' 
				`sortby' `subline' `summaryonly' `tablestat' texts(`texts') `wgt' `xlabel'  `xtick'
				ma_second_model(`MA_second_model') ma_second_es(`MA_second_ES')  ma_second_se_es(`MA_second_SE_ES') ma_second_lci(`MA_second_LCI') ma_second_uci(`MA_second_UCI')
				ma_second_z(`MA_second_Z') ma_second_p_z(`MA_second_P_Z') ma_second_het(`MA_second_HET') ma_second_df(`MA_second_DF') ma_second_p_het(`MA_second_P_HET') ma_second_chi2(`MA_second_CHI2') ma_second_pchi2(`MA_second_PCHI2') ma_second_tau2(`MA_second_TAU2') ma_second_wtau2(`MA_second_WTAU2') ma_second_i2(`MA_second_I2') ;
				
				#delimit cr
			}

			if "`callalg'" == "metanby" {		// if by, then send to metanby and sort out there			
				#delimit ;
				
				`callalg' `varlist',
				studyid(`studyid') astext(`astext') `boxopt' boxsca(`boxsca') `breps' `by' `cc' cimethod(`cimethod') 
				`ciopt' `classic' `paired'  `diamopt' `double' `download' dp(`dp') `force' `ftt'  ilevel(`ilevel') 
				`interaction' `logit' label(`code') `lcols' model(`model') `modelopts'  `model2' `model2opts'  `nextcall' `box' `graph' `het'  `overall'  `ovline' `secsub'   `stats'  `subgroup'  `table'   `wt'  olevel(`olevel') `olineopt' `otheropts' outplot(`outplot') `outtable' `plotstat' `pointopt' power(`power') `predciopt' `rcols' `rfdist'  rflevel(`rflevel') `sgweight' `sortby' `subline' `summaryonly' `tablestat' texts(`texts') `wgt' `xlabel'  `xtick';

				#delimit cr
			}
		}

		if "`second'" == "" {

			if "`callalg'" != "metanby" {
				#delimit ;
				`callalg' `varlist',
				studyid(`studyid') astext(`astext') `boxopt' boxsca(`boxsca') `breps' `by' `cc' cimethod(`cimethod') 
				`ciopt' `classic' `paired'  `diamopt' `double' `download' dp(`dp') `force' `ftt'  ilevel(`ilevel') 
				`interaction' `logit' label(`code') `lcols' model(`model') `modelopts' `box' `graph' `het'  `overall'  `ovline' `secsub'   `stats' 
				`subgroup'  `table'   `wt'  olevel(`olevel') `olineopt'`otheropts' outplot(`outplot') `outtable' `plotstat' `pointopt' power(`power') `predciopt' `rcols' `rfdist'  rflevel(`rflevel') `sgweight' 
				`sortby' `subline' `summaryonly' `tablestat' texts(`texts') `wgt' `xlabel'  `xtick';

				#delimit cr

			}
			if "`callalg'" == "metanby" {
				#delimit ;
				`callalg' `varlist', 
				studyid(`studyid') astext(`astext') `boxopt' boxsca(`boxsca') `breps' `by' `cc' cimethod(`cimethod') 
				`ciopt' `classic' `paired'  `diamopt' `double' `download' dp(`dp') `force' `ftt'  ilevel(`ilevel') 
				`interaction' `logit' label(`code') `lcols' model(`model') `modelopts' `nextcall'  `box' `graph' `het'  `overall'  `ovline' `secsub'   `stats' `subgroup'  `table'   `wt'  olevel(`olevel') `olineopt' `otheropts' outplot(`outplot') `outtable' `plotstat' `pointopt' power(`power') `predciopt'  `rcols' `rfdist'  rflevel(`rflevel') `sgweight' 
				`sortby' `subline' `summaryonly' `tablestat'  texts(`texts') `wgt' `xlabel'  `xtick';
				#delimit cr
			}			
		}

		local S_1 = r(ES)			
		local S_2 = r(seES)
		local S_3 = r(ci_low)
		local S_4 = r(ci_upp)
		local S_5 = r(z)
		local S_6 = r(p_z)
		local S_7 = r(het)
		local S_8 = r(df)
		local S_9 = r(p_het)
		local S_10 = r(chi2)
		local S_11 = r(p_chi2)
		local S_12 = r(tau2)
		local S_13 = r(wtau2)
		local S_14 = r(i_sq)
		local hmean = r(hmean)
		local model = r(model)
		if "`logit'" == "" {
			tempname raw logodds rrout absout predci opredci
			mat `raw' = r(raw)
			mat `logodds' = r(logodds)
			mat `absout' = r(absout)
			if "`regressors'" != "" {
				mat `rrout' = r(rrout)
			}
			
			if "`rfdist'" != "" {
				mat `predci' = r(predci)
				mat `opredci' = r(opredci)
			}				
		}
	
		if "`model2'" != "" {
			local MA_second_ES = r(ES_2)			
			local MA_second_SE_ES = r(seES_2)
			local MA_second_LCI = r(ci_low_2)
			local MA_second_UCI = r(ci_upp_2)
			local MA_second_Z = r(z_2)
			local MA_second_P_Z = r(p_z_2)
			local MA_second_HET = r(het_2)
			local MA_second_DF = r(df_2)
			local MA_second_P_HET = r(p_het_2)
			local MA_second_CHI2 = r(chi2_2)
			local MA_second_PCHI2 = r(p_chi2_2)
			local MA_second_TAU2 = r(tau2_2)
			local MA_second_WTAU2 = r(wtau2_2)
			local MA_second_I2 = r(i_sq_2)
			local MA_second_model = r(model_2)
			if "`logit'" == "" {
				tempname MA_second_raw MA_second_logodds MA_second_rrout MA_second_absout MA_second_predci MA_second_opredci
				mat `MA_second_raw' = r(raw_2)
				mat `MA_second_logodds' = r(logodds_2)
				mat `MA_second_absout' = r(absout_2)
				if "`regressors'" != "" {
					mat `MA_second_rrout' = r(rrout_2)
				}
				if "`rfdist'" != "" {
					mat `MA_second_predci' = r(predci_2)
					mat `MA_second_opredci' = r(opredci_2)
				}				
			}
		}
		

				
		if "`ftt'" != "" & "`by'" == "" {
		/*===============================================================================================*/
		/*==================================== FTT back transformation ==================================*/
		/*===============================================================================================*/

			tempname mintes1 maxtes1 mintes2 maxtes2 effect1 lci1 uci1 effect2 lci2 uci2
		 
			scalar `mintes1' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
			scalar `maxtes1' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
			
			if `S_1' < `mintes1' {
				local effect1 = 0 
			} 
			else if `S_1' > `maxtes1' {
				local effect1 = 1 
			}
			else {
				local effect1 = 0.5 * (1 - sign(cos(`S_1')) * sqrt(1 - (sin(`S_1') + (sin(`S_1') - 1/sin(`S_1'))/(`hmean'))^2)) 
			}

			if `S_3' < `mintes1' {
				local lci1 = 0 
			} 
			else if `S_3' > `maxtes1' {
				local lci1  = 1 
				}
			else {
				local lci1  = 0.5 * (1 - sign(cos(`S_3')) * sqrt(1 - (sin(`S_3') + (sin(`S_3') - 1/sin(`S_3'))/(`hmean'))^2)) 
				}

			if `S_4' < `mintes1' {
				local uci1  = 0 
			} 
			else if `S_4' > `maxtes1' {
				local uci1  = 1 
			}
			else {
				local uci1  = 0.5 * (1 - sign(cos(`S_4' )) * sqrt(1 - (sin(`S_4' ) + (sin(`S_4' ) - 1/sin(`S_4'))/(`hmean'))^2)) 
			}
			
			local S_1 =`effect1'
			local S_3 =`lci1'
			local S_4 =`uci1'
			
			if "`model_2'" != "" {
				scalar `mintes2' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
				scalar `maxtes2' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
				if `MA_second_ES' < `mintes2' {
					local effect2 = 0 
				} 
				else if `MA_second_ES' > `maxtes2' {
					local effect2 = 1 
				}
				else {
					local effect2 = 0.5 * (1 - sign(cos(`MA_second_ES')) * sqrt(1 - (sin(`MA_second_ES') + (sin(`MA_second_ES') - 1/sin(`MA_second_ES'))/(`hmean'))^2)) 
				}

				if `MA_second_LCI' < `mintes2' {
					local lci2 = 0 
				} 
				else if `MA_second_LCI' > `maxtes2' {
					local lci2  = 1 
					}
				else {
					local lci2  = 0.5 * (1 - sign(cos(`MA_second_LCI')) * sqrt(1 - (sin(`MA_second_LCI') + (sin(`MA_second_LCI') - 1/sin(`MA_second_LCI')/(`hmean'))^2)) 
					}

				if `MA_second_UCI' < `mintes2' {
					local uci2  = 0 
				} 
				else if `MA_second_UCI' > `maxtes2' {
					local uci2  = 1 
				}
				else {
					local uci2  = 0.5 * (1 - sign(cos(`MA_second_UCI')) * sqrt(1 - (sin(`MA_second_UCI') + (sin(`MA_second_UCI') - 1/sin(`MA_second_UCI'))/(`hmean'))^2)) 
				}
				local MA_second_ES=`effect2'
				local MA_second_LCI =`lci2'
				local MA_second_UCI =`uci2'	
			}		
		}
		
		return scalar ES		= `S_1'
		return scalar seES	= `S_2'
		return scalar ci_low	=`S_3'
		return scalar ci_upp	=`S_4'
		return scalar z		= `S_5'
		return scalar p_z	= `S_6'
		return scalar het	= `S_7'
		return scalar df		= `S_8'
		return scalar p_het	= `S_9'
		return scalar chi2	= `S_10'
		return scalar p_chi2	= `S_11'
		return scalar tau2	= `S_12'
		return scalar wtau2	= `S_13'
		return scalar i_sq	= `S_14'		
		return local model 	=  "`model'"
		
		if "`second'" != "" {
			return scalar ES_2		= `MA_second_ES'
			return scalar seES_2	= `MA_second_SE_ES'
			return scalar ci_low_2	= `MA_second_LCI'
			return scalar ci_upp_2	= `MA_second_UCI'
			return scalar z_2		= `MA_second_Z'
			return scalar p_z_2		= `MA_second_P_Z'
			return scalar het_2		= `MA_second_HET'
			return scalar df_2		= `MA_second_DF'
			return scalar p_het_2	= `MA_second_P_HET'
			return scalar chi2_2	= `MA_second_CHI2'
			return scalar p_chi2_2	= `MA_second_PCHI2'
			return scalar tau2_2	= `MA_second_TAU2'
			return scalar wtau2_2	= `MA_second_WTAU2'
			return scalar i_sq_2	= `MA_second_I2'
			return local model_2 	= "`MA_second_model'"
		}
		if "`paired'" != "" {
			return local paired "Yes"
		}
		else{
			return local paired "No"
		}
		if "`ftt'" != "" {
			return local ftt "Yes"
		}
		else{
			return local ftt "No"
		}
		
		if "`logit'" == "" {
			if "`second'" != "" {			
				cap confirm matrix `MA_second_predci'
				if _rc == 0 {
					return matrix predci_2 = `MA_second_predci'
				}
				
				cap confirm matrix `MA_second_logodds'
				if _rc == 0 {
					return matrix logodds_2 = `MA_second_logodds'
				}
				
				cap confirm matrix `MA_second_absout'
				if _rc == 0 {
					return matrix absout_2 = `MA_second_absout'
				}
				
				cap confirm matrix `MA_second_rrout'
				if _rc == 0 {
					return matrix rrout_2 = `MA_second_rrout'
				}
			}	
			cap confirm matrix `predci'
			if _rc == 0 {
				return matrix predci = `predci'
			}

			cap confirm matrix `raw'
			if _rc == 0 {
				return matrix raw = `raw'
			}
			
			cap confirm matrix `logodds'
			if _rc == 0 {
				return matrix logodds = `logodds'
			}
			
			cap confirm matrix `absout'
			if _rc == 0 {
				return matrix absout = `absout'
			}
				
			cap confirm matrix `rrout'
			if _rc == 0 {
				return matrix rrout = `rrout'
			}		
		}
		restore
		if _bylastcall() {
			macro drop by_index_
		}
		if "`logit'" == ""  {
			qui estimates restore metapreg_modest
		}
	end

	/*===============================================================================================*/
	/*==================================== METANBY   ================================================*/
	/*===============================================================================================*/
	capture program drop metanby
	program define metanby

	version 14.1

	#delimit ;

	syntax varlist(min=2 default=none) [if] [in] [,
		AStext(integer 50) 
		BOXOpt(string) 
		BOXSca(real 100.0) 
		BReps(integer 1000)
		BY(string) 
		CC(string)
		CImethod(string) 
		CIOpt(string) 
		CLassic
		paired 
		DIAMopt(string) 
		DOUBLE 
		download(string)
		DP(integer 2) 
		FORCE 
		FTT 
		ILevel(integer 95) 
		interaction 
		noLOGIT 
		LABEL(string) 
		LCOLS(varlist) 
		model(string) 
		modelopts(string)
		model2(string) 
		model2opts(string)
		NEXTCALL(string) 
		noBOX 
		noGRAPH 
		NOHET  
		noOVERALL  
		noOVLine 
		NOSECSUB
		noSTATS 
		noSUBGROUP 
		noTABLE  
		
		noWT 
		OLevel(integer 95) 
		OLineopt(string) 
		outplot(string) 
		outtable(string) 
		plotstat(string asis) 
		POINTopt(string) 
		POwer(integer 0)
		PREDciopt(string)
		RCOLS(varlist) 
		RFdist 
		RFLevel(integer 95) 
		SGWEIGHT
		SORTBY(varlist) 
		STUDYID(varname)
		SUBLINE 
		SUMMARYonly
		tablestat(string asis) 
		TEXts(real 100.0) 
		WGT(passthru) 
		XLAbel(passthru) 
		XTICK(passthru) 
		otheropts(string)	
		];

	#delimit cr

		if ("`subgroup'"!="" & "`overall'`sgweight'"!="") { 
			local wt "nowt" 
		}

		if "`logit'" == "" {
			local wt = "nowt"
			local show "noi"
		}

		tempvar n N use by2 newby incr r1 r2 rawdata effect se lci uci weight wtdisp  mean weightrandom weightedest   ///
			hetc hetdf hetp i2 tau2 wtau2 df tsig psig expand tlabel id weightedsquare_first weightedsquare_second mintes maxtes teffect tlci tuci ///
			fittedmodel a b c d echi2 pchi2

		tempname mintes maxtes teffect tlci tuci sumweights sumweightedest
	
		qui {
			gen `use'=1 `if' `in'
			replace `use' = 9 if `use' == .

			tokenize `varlist'
			if "`dependent'" == "" {
				gen `n' = `1' 
				gen `N' = `2' 
				
				replace `use' = 9 if (`n'==. | `N'==.)
				
				local dep "`1' `2'"
				macro shift 2 /*Obtain the independent variables after the second variable*/

			}
			else {
				gen `a' = `1' 
				gen `b' = `2' 
				gen `c' = `3' 
				gen `d' = `4'
				gen `N' = `a' + `b' + `c' + `d'
				
				replace `use' = 9 if `N'==.	
				
				local dep "`1' `2' `3' `4'"
				macro shift 4 /*Obtain the independent variables after the second variable*/
			}
			local regressors "`*'" /*take the regressor if supplied*/
			local p: word count `regressors'
			/*Collect string regressors*/
			local byreg
			foreach reg of local regressors {
				cap confirm integer number `reg'
				if _rc!=0 {
					local byreg "`byreg' `reg'" 
				}
			}

			gen double `incr' = . 
			
			if "`cc'" != "" {
				replace `incr' = `cc' if  (`n' == 0 | `n'==`N') 
			}
						
			if ("`ftt'" == ""  & "`logit'" != "") {
				if (`incr' == . | `incr' == 0 ) {
					replace `use' = 2 if (`n' == 0 | `n'==`N') & `use'==1 
				}
			}
			
			replace `use' = 2 if `N' == 0 & `use' == 1 
			count if `use' == 1
			if r(N) < 2 {
				*no trials - bomb out
				di as error "Insufficient data"
				exit
			}

			if "`outplot'" == "rr" {
				local h0=1
			}
			else {
				if "`logit'" != "" {
					local h0=0
				}
				else {
					local h0=0.5
				}
			}
			
			if "`logit'" == "" {
				local sid = "studyid(`studyid')"
				if "`paired'" != "" {
					local VarX: word 1 of `regressors'
				}
			}

			*RJH- second estimate

			if "`model2'" != "" {
				if  "`outtable'" != ""  {
					noi di as res _n "*********************************** Second fitted model ***************************************"  _n
				}
				#delimit ;
				`show' `nextcall' `dep' `regressors' if `use'==1,
				studyid(`studyid')  breps(`breps') by(`by') cc(`cc') cimethod(`cimethod') 
				ciopt(`ciopt') `classic' `paired'  `double' download(`download') dp(`dp') `force' `ftt'  ilevel(`ilevel') 
				`interaction' `logit' label(`label')  model(`model2') modelopts(`model2opts') nograph notable  olevel(`olevel') outplot(`outplot') power(`power') `rfdist'  rflevel(`rflevel')  rjhsecond wgt(`wgt') ;
				#delimit cr

				local MA_second_ES 		= r(ES)			
				local MA_second_SE_ES 	= r(seES)
				local MA_second_LCI 	= r(ci_low)
				local MA_second_UCI 	= r(ci_upp)
				local MA_second_Z 		= r(z)
				local MA_second_P_Z 	= r(p_z)
				local MA_second_HET 	= r(het)
				local MA_second_DF 		= r(df)
				local MA_second_P_HET 	= r(p_het)
				local MA_second_CHI2 	= r(chi2)
				local MA_second_PCHI2 	= r(p_chi2)
				local MA_second_TAU2 	= r(tau2)
				local MA_second_WTAU2 	= r(wtau2)
				local MA_second_I2 		= r(i_sq)
				local MA_second_model 	= r(model)
				
				if "`logit'" == "" {
				tempname MA_second_raw MA_second_logodds MA_second_absout MA_second_rrout MA_second_predci MA_second_opredci
					mat `MA_second_raw' = r(raw)
					mat `MA_second_logodds' = r(logodds)
					mat `MA_second_rrout' = r(rrout)
					mat `MA_second_absout' = r(absout)
					
					if "`rfdist'" != "" {
						mat `MA_second_predci' = r(predci)
						mat `MA_second_opredci' = r(opredci)
					}
					
					if (`p' == 0 & "`paired'" == "") | (`p' == 1 & "`paired'" != "" & "`outplot'" == "rr") | (`p' == 0 & "`paired'" != "" & "`outplot'" == "abs") {
						estimates restore metapreg_Null
						estimates store metapreg_second_Nest
						estimates drop metapreg_Null
					}
					if (`p' > 0 & "`paired'" == "") | (`p' == 2 & "`paired'" != "" & "`outplot'" == "rr") | (`p' == 1 & "`paired'" != "" & "`outplot'" == "abs") {
						estimates restore metapreg_Full
						estimates store metapreg_second_Fest
						estimates drop metapreg_Full
					}
					if `p' == 1 & "`outplot'" == "abs" {
						estimates restore metapreg_Null
						estimates store metapreg_second_Nest
						estimates drop metapreg_Null
					}
					
					if `p' == 2 & "`outplot'" == "rr" {
						estimates restore metapreg_reducedFull
						estimates store metapreg_second_reducedFull
						estimates drop metapreg_reducedFull
						if "`model2'" == "random" {
							estimates restore metapreg_fixedFull
							estimates store metapreg_second_fixedFull
							estimates drop metapreg_fixedFull
						}	
					}
				}
			}
			
			if  "`oouttable'" != ""  {
				noi di as res _n "*********************************** First fitted model ***************************************"  _n
			}
			
			#delimit ;
			`show' `nextcall' `dep' `regressors' if `use'==1,
				studyid(`studyid')  breps(`breps') by(`by') cc(`cc') cimethod(`cimethod') 
				ciopt(`ciopt') `classic' `paired' `double' download(`download') dp(`dp') `force' `ftt'  ilevel(`ilevel') 
				`interaction' `logit' label(`label') model(`model') modelopts(`modelopts') nograph notable olevel(`olevel') outplot(`outplot') power(`power') `rfdist'  rflevel(`rflevel') wgt(`wgt');
			#delimit cr

			local MA_first_ES 		= r(ES)			
			local MA_first_SE_ES 	= r(seES)
			local MA_first_LCI 		= r(ci_low)
			local MA_first_UCI 		= r(ci_upp)
			local MA_first_Z 		= r(z)
			local MA_first_P_Z 		= r(p_z)
			local MA_first_HET 		= r(het)
			local MA_first_DF 		= r(df)
			local MA_first_P_HET 	= r(p_het)
			local MA_first_CHI2 	= r(chi2)
			local MA_first_PCHI2 	= r(p_chi2)
			local MA_first_TAU2 	= r(tau2)
			local MA_first_WTAU2 	= r(wtau2)
			local MA_first_I2 		= r(i_sq)
			local MA_first_model 	= r(model)
			local hmean 			= r(hmean)
			if "`logit'" == "" {
				tempname MA_first_raw MA_first_logodds MA_first_rrout MA_first_absout MA_first_predci MA_first_opredci
				mat `MA_first_raw' = r(raw)
				mat `MA_first_logodds' = r(logodds)
				mat `MA_first_absout' = r(absout)
				if "`regressors'" != "" {
					mat `MA_first_rrout' = r(rrout)
				}

				if "`rfdist'" != "" {
					mat `MA_first_predci' = r(predci)
					mat `MA_first_opredci' = r(opredci)
				}
			}
			
			preserve
			
			gen `lci'= .
			gen `uci'= .
			gen double `se' = .
			gen double `effect' = .
			
			replace `effect' = _ES
			replace `lci'=_LCI
			replace `uci'=_UCI
			
			if "`outplot'" == "abs" {
				replace `effect' = (`n')/(`N')
				replace `se' = sqrt((`effect'*(1 - `effect'))/`N')
				replace `se' = sqrt((`n' + `incr') * (`N' - `n' + `incr')/(`N' + 2 * `incr')^3) if  (`n' != . & `N' > 0 & `incr' !=.)

			}
			if "`logit'" != "" {
				gen `weight'=_WT

				*put overall weight into var if requested
				if ("`sgweight'"=="" & "`overall'"=="" )  {
					gen `wtdisp'=_WT
				}
				else {
					gen `wtdisp'=.
				}
			}
			else {
				gen `wtdisp'=.
				gen `weight'=.
			}
			gen `id'=_n
		}
		if "`byreg'" != "" {
			if "`outplot'" == "rr" {
				local by: word 2 of `regressors' /*Loop over either by or byreg*/
			}
			else {
				local by "`regressors'"
			}
		}
		else {
			local by "`by'" /*Loop over either by or byreg*/
		}
		
		*foreach by of local byvariables {
			
		qui {
			local regressor "`by'"
			
			my_ncod `by2', oldvar(`by')
			*global confounder "`by2'"  //for use in the subline command
			
			*Keep only neccesary data 
			sort `by2' `sortby' `id'
			qui drop if `use' == 9

			*Can now forget about the if/in conditions specified: unnecc rows have been removed

			*subgroup component of heterogeneity
			gen `hetc'=.
			gen `hetdf'=.
			gen `hetp'=.
			gen `i2'=.
			gen `tau2'=.
			gen `wtau2' = 0
			gen `df' = .
			gen `tsig'=.
			gen `psig'=.
			gen `echi2' = .
			gen `pchi2' = .
			gen `fittedmodel' = ""

			*Create new "by" variable to take on codes 1,2,3.. 
			gen `newby'=(`by2' > `by2'[_n-1])
			replace `newby'=1 + sum(`newby')
			local ngroups = `newby'[_N]

			if "`overall'" == "" {
				*If requested, add an extra line to contain overall stats
				local nobs1 = _N+1
				set obs `nobs1'
				replace `use'= 5 in `nobs1'
				replace `newby' = `ngroups' + 1 in `nobs1'	
				replace `fittedmodel' = strproper("`MA_first_model'") in `nobs1'
				
				//predictions
				if "`rfdist'" != "" {
					local nobs11  = _N + 1
					set obs `nobs11'
					replace `use'= 6 in `nobs11'
					replace `newby' = `ngroups' + 1 in `nobs11'	
					if "`logit'" == "" {
						cap confirm matrix `MA_first_predci'
						if _rc == 0 {
							local nrows = rowsof(`MA_first_predci')
							replace `lci' = `MA_first_predci'[`nrows',1] in `nobs11'
							replace `uci' = `MA_first_predci'[`nrows',2] in `nobs11'
						}
					}
				}
	/*===============================================================================================*/
	/*==================    Finish the Freeman Tukey Back tranformation      ========================*/
	/*===============================================================================================*/
				if "`ftt'"  != ""  {
					tempname mintes maxtes
					scalar `mintes' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
					scalar `maxtes' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
					
					if `MA_first_ES' < `mintes' {
						qui replace `effect' = 0 in `nobs1'
					}
					else if `MA_first_ES' > `maxtes' {
						qui replace `effect' = 1 in `nobs1'
					}
					else {
						qui replace `effect' = 0.5 * (1 - sign(cos(`MA_first_ES')) * sqrt(1 - (sin(`MA_first_ES') + (sin(`MA_first_ES') - 1/sin(`MA_first_ES'))/(`hmean'))^2)) in `nobs1' 
					}
					
					if `MA_first_LCI' < `mintes' {
						qui replace `lci' = 0 in `nobs1'
					}
					else if `MA_first_LCI' > `maxtes' {
						qui replace `lci' = 1 in `nobs1'
					}
					else {
						qui replace `lci' = 0.5 * (1 - sign(cos(`MA_first_LCI')) * sqrt(1 - (sin(`MA_first_LCI') + (sin(`MA_first_LCI') - 1/sin(`MA_first_LCI'))/(`hmean'))^2)) in `nobs1' 
					}				
					if `MA_first_UCI' < `mintes' {
						qui replace `uci' = 0 in `nobs1'
					}
					else if `MA_first_UCI' > `maxtes' {
						qui replace `uci' = 1 in `nobs1'
					}
					else {
						qui replace `uci' = 0.5 * (1 - sign(cos(`MA_first_UCI')) * sqrt(1 - (sin(`MA_first_UCI') + (sin(`MA_first_UCI') - 1/sin(`MA_first_UCI'))/(`hmean'))^2)) in `nobs1' 
					}
					
					if "`rfdist'" != "" {
						tempname fttlci fttuci
						scalar `fttlci' = `MA_first_ES' - invttail((`S_8'), 0.5-`rflevel'/200)*sqrt(`MA_first_TAU2' + `MA_first_SE_ES'^2) 
						scalar `fttuci' = `MA_first_ES' + invttail((`S_8'), 0.5-`rflevel'/200)*sqrt(`MA_first_TAU2' + `MA_first_SE_ES'^2) 
					
						replace `lci' = 0 if `fttlci' < `mintes' in `nobs11'
						replace `lci' = 1 if `fttlci' > `maxtes' in `nobs11'
						replace `lci' = 0.5 * (1 - sign(cos(`fttlci')) * sqrt(1 - (sin(`fttlci') + (sin(`fttlci') - 1/sin(`fttlci'))/(`hmean'))^2)) if (`fttlci' <= `maxtes') & (`fttlci' >= `mintes') in `nobs11'
						
						replace `uci' = 0 if `fttuci' < `mintes' in `nobs11'
						replace `uci' = 1 if `fttuci' > `maxtes' in `nobs11'
						replace `uci' = 0.5 * (1 - sign(cos(`fttuci')) * sqrt(1 - (sin(`fttuci') + (sin(`fttuci') - 1/sin(`fttuci'))/(`hmean'))^2)) if (`fttuci' <= `maxtes') & (`fttuci' >= `mintes') in `nobs11'
					}
	/*===============================================================================================*/
	/*==================    Finish the Freeman Tukey Back tranformation      ========================*/
	/*===============================================================================================*/
				} 
				else {
					replace `effect'= (`MA_first_ES') in `nobs1'
					replace `lci'=(`MA_first_LCI') in `nobs1'
					replace `uci'=(`MA_first_UCI') in `nobs1'
					
				}
				*RJH plus another line if second estimate
				if "`model2'" != "" {
					local nobs2 = _N + 1
					set obs `nobs2'
					replace `use' = 17 in `nobs2'
					replace `newby'=`ngroups' + 1 in `nobs2'	
					replace `fittedmodel' = strproper("`MA_second_model'") in `nobs2'
					
					//predictions
					if "`rfdist'" != "" {
						local nobs21  = _N+1
						set obs `nobs22'
						replace `use'= 18 in `nobs22'
						replace `newby' = `ngroups' + 1 in `nobs22'	
						if "`logit'" != "" {
							cap confirm matrix `MA_second_predci'
							if _rc == 0 {
								local nrows = rowsof(`MA_second_predci')
								replace `lci' = `MA_second_predci'[`nrows',1] in `nobs22'
								replace `uci' = `MA_second_predci'[`nrows',2] in `nobs22'
							}
						}
					}
	/*===============================================================================================*/
	/*==================    Begin the Freeman Tukey Back tranformation      ========================*/
	/*===============================================================================================*/
					if "`ftt'"  != ""  { 
						tempname mintes maxtes
						
						scalar `mintes' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
						scalar `maxtes' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
						
						if `MA_second_ES' < `mintes' {
							qui replace `effect' = 0 in `nobs2'
						}
						else if `MA_second_ES' > `maxtes' {
							qui replace `effect' = 1 in `nobs2'
						}
						else {
							qui replace `effect' = 0.5 * (1 - sign(cos(`MA_second_ES')) * sqrt(1 - (sin(`MA_second_ES') + (sin(`MA_second_ES') - 1/sin(`MA_second_ES'))/(`hmean'))^2)) in `nobs2' 
						}
						
						if `MA_second_LCI' < `mintes' {
							qui replace `lci' = 0 in `nobs2'
						}
						else if `MA_second_LCI' > `maxtes' {
							qui replace `lci' = 1 in `nobs2'
						}
						else {
							qui replace `lci' = 0.5 * (1 - sign(cos(`MA_second_LCI')) * sqrt(1 - (sin(`MA_second_LCI') + (sin(`MA_second_LCI') - 1/sin(`MA_second_LCI'))/(`hmean'))^2)) in `nobs2' 
						}
						
						if `MA_second_UCI' < `mintes' {
							qui replace `uci' = 0 in `nobs2'
						}
						else if `MA_second_UCI' > `maxtes' {
							qui replace `uci' = 1 in `nobs2'
						}
						else {
							qui replace `uci' = 0.5 * (1 - sign(cos(`MA_second_UCI')) * sqrt(1 - (sin(`MA_second_UCI') + (sin(`MA_second_UCI') - 1/sin(`MA_second_UCI'))/(`hmean'))^2)) in `nobs2' 
						}
						if "`rfdist'" != "" {
							tempname fttlci fttuci
							scalar `fttlci' = `MA_second_ES' - invttail((`MA_second_DF'), 0.5-`rflevel'/200)*sqrt(`MA_second_TAU2' + `MA_second_SE_ES'^2) 
							scalar `fttuci' = `MA_second_ES' + invttail((`MA_second_DF'), 0.5-`rflevel'/200)*sqrt(`MA_second_TAU2' + `MA_second_SE_ES'^2) 
						
							replace `lci' = 0 if `fttlci' < `mintes' in `nobs11'
							replace `lci' = 1 if `fttlci' > `maxtes' in `nobs11'
							replace `lci' = 0.5 * (1 - sign(cos(`fttlci')) * sqrt(1 - (sin(`fttlci') + (sin(`fttlci') - 1/sin(`fttlci'))/(`hmean'))^2)) if (`fttlci' <= `maxtes') & (`fttlci' >= `mintes') in `nobs11'
							
							replace `uci' = 0 if `fttuci' < `mintes' in `nobs11'
							replace `uci' = 1 if `fttuci' > `maxtes' in `nobs11'
							replace `uci' = 0.5 * (1 - sign(cos(`fttuci')) * sqrt(1 - (sin(`fttuci') + (sin(`fttuci') - 1/sin(`fttuci'))/(`hmean'))^2)) if (`fttuci' <= `maxtes') & (`fttuci' >= `mintes') in `nobs11'
						}						
	/*===============================================================================================*/
	/*==================    Finish the Freeman Tukey Back tranformation      ========================*/
	/*===============================================================================================*/	
					}  
					else {
						replace `effect'= (`MA_second_ES') in `nobs2'
						replace `se'=(`MA_second_SE_ES') in `nobs2'
						replace `lci'=(`MA_second_LCI') in `nobs2'
						replace `uci'=(`MA_second_UCI') in `nobs2'
					}
					replace `wtau2' = `MA_second_WTAU2' in `nobs2'
					replace `tau2' = `MA_second_TAU2' in `nobs2'
					replace `hetdf' = `MA_second_DF' in `nobs2'
					replace `tsig'=`MA_second_Z' in `nobs2'
					replace `psig'=`MA_second_P_Z' in `nobs2'
					replace `label' = "Overall" in `nobs2' /**/
				}
				
				if "`logit'" != "" {
					replace `hetc' =(`MA_first_HET') in `nobs1'
					replace `hetdf'=(`MA_first_DF') in `nobs1'
					replace `hetp' =(`MA_first_P_HET') in `nobs1'
				}
				else {
					replace `hetc' =(`MA_first_CHI2') in `nobs1'
					replace `hetdf'= (`MA_first_DF') in `nobs1'
					replace `hetp' =(`MA_first_PCHI2') in `nobs1'
				}
				replace `se'= `MA_first_SE_ES' in `nobs1'
				replace `tsig'=`MA_first_Z' in `nobs1'
				replace `psig'=`MA_first_P_Z' in `nobs1'
				replace `df' = `MA_first_DF' in `nobs1'
				replace `tau2' = `MA_first_TAU2' in `nobs1'
				replace `wtau2' = `MA_first_WTAU2' in `nobs1'
				replace `i2' = `MA_first_I2' in `nobs1'
				replace `label' = "Overall" in `nobs1' /**/
				if "`sgweight'"=="" { 
					replace `wtdisp'=100 in `nobs1' 
				}				
			} /* end if overall */


			*Create extra 2 or 3 lines per bygroup: one to label, one for gap
			*and one for overall effect size (unless no subgroup combining is done)
			*RJH- add another line if SECOND sub estimates

			sort `newby' `use' `sortby' `id'

			by `newby': gen `expand'=1 + 2*(_n==1) 
			replace `expand'=1 if `use'==5 | `use' == 17
			expand `expand'
			gsort `newby' -`expand' `use' `sortby' `id'
			by `newby': replace `use'=0  if `expand'>1 & _n==2   /* row for by label */
			by `newby': replace `use'=8  if `expand'>1 & _n==3   /* row for blank line */
			
			if "`subgroup'"=="" {
				replace `expand'=1
				by `newby': replace `expand'=1  + (_n==1) 
				replace `expand'=1 if `use'==5 | `use' == 17
				expand `expand'
				gsort `newby' -`expand' `use' `sortby' `id'
				by `newby': replace `use'=3  if `expand'>1 & _n==2   /* (if specified) row to hold subgp effect sizes */
			}
			
			if "`rfdist'"!="" {
				replace `expand'=1
				by `newby': replace `expand'=1  + (_n==1)
				replace `expand'=1 if `use'==5 | `use' == 17				
				expand `expand'
				gsort `newby' -`expand' `use' `sortby' `id'
				by `newby': replace `use'=4  if `expand'>1 & _n==2   /* (if specified) row to hold subgp prediction */
			}
			
			if ("`model2'"!="" & "`nosecsub'"=="") {
				replace `expand'=1
				by `newby': replace `expand'=1  + (_n==1)
				replace `expand'=1 if `use'==5 | `use' == 17				
				expand `expand'
				gsort `newby' -`expand' `use' `sortby' `id'
				by `newby': replace `use'=19  if `expand'>1 & _n==2   /* (if specified) RJH extra line for second estimate */
			}
			* blank out effect sizes in new rows
			replace `effect'=.  if `use'==0 | `use'==8 | `use'==3 | `use'==4 | `use'==19
			replace `se'=.  if `use'==0 | `use'==8 | `use'==3 | `use'==4 | `use'==19    
			replace `lci'=. if `use'==0 | `use'==8 | `use'==3 | `use'==4 | `use'==19
			replace `uci'=. if `use'==0 | `use'==8 | `use'==3 | `use'==4 | `use'==19
			replace `weight' =. if `use'==0 | `use'==8 | `use'==3 | `use'==4 | `use'==19  
			replace `fittedmodel' = "" if `use'==0 | `use'==8 | `use'==3 | `use'==4 | `use'==19
	/*===============================================================================================*/
	/*=================================    Subgroup Analyses      ===================================*/
	/*===============================================================================================*/
			local j = 1
			while `j'<=`ngroups' {		// HUGE LOOP THROUGH EACH SUBGROUP
				if "`subgroup'"=="" {
					*First ensure the by() category has any data
					count if (`newby'==`j' & `use'==1)
					local N = r(N)

					if `N'==0 {
						*No data in subgroup=> fill variables with missing and move on
						replace `effect'=. if (`use'==3 & `newby'==`j')
						replace `se'=. if (`use'==3 & `newby'==`j')
						replace `lci'=. if (`use'==3 & `newby'==`j')
						replace `uci'=. if (`use'==3 & `newby'==`j')
						if "`rfdist'" != "" {	
							replace `lci'=. if (`use'==4 & `newby'==`j')
							replace `uci'=. if (`use'==4 & `newby'==`j')	
						}
						replace `wtdisp' = 0 if `newby'==`j'
						replace `weight' = 0 if `newby'==`j'
						replace `hetc'=. if `newby'==`j'
						replace `hetdf'=. if `newby'==`j'
						replace `hetp'=. if `newby'==`j'
						replace `i2'=. if `newby'==`j'
						replace `tsig'=. if `newby'==`j'
						replace `psig'=. if `newby'==`j'
						replace `tau2'=. if `newby'==`j'
						replace `wtau2'=0 if `newby'==`j'
						replace `fittedmodel'="" if `newby'==`j'
					}
					else if `N'==1 {
						summ `effect' if (`newby'==`j' & `use'==1)
						replace `effect'=r(sum) if (`use'==3 & `newby'==`j')
						replace `se'=. if (`use'==3 & `newby'==`j')
						summ `lci' if (`newby'==`j' & `use'==1)
						replace `lci'=r(sum) if (`use'==3 & `newby'==`j')
						summ `uci' if (`newby'==`j' & `use'==1)
						replace `uci'=r(sum) if (`use'==3 & `newby'==`j')
						if "`rfdist'" != "" {	
							replace `lci'=. if (`use'==4 & `newby'==`j')
							replace `uci'=. if (`use'==4 & `newby'==`j')	
						}
						replace `wtdisp' = 0 if `newby'==`j'
						replace `weight' = 0 if `newby'==`j'
						replace `hetc'=. if `newby'==`j'
						replace `hetdf'=0 if `newby'==`j'
						replace `hetp'=. if `newby'==`j'
						replace `i2'=. if `newby'==`j'
						replace `tsig'=. if `newby'==`j'
						replace `psig'=. if `newby'==`j'
						replace `tau2'=. if `newby'==`j'
						replace `wtau2'=0 if `newby'==`j'
						replace `fittedmodel'="" if `newby'==`j'
					}
					else {
						/* SECOND SUB-ESTIMATES */
						if "`model2'" != "" & "`nosecsub'" == "" {
							if "`byreg'" == "" {
								#delimit ;			
								`nextcall' `varlist' if (`newby'==`j' & `use'==1),
									studyid(`studyid')  breps(`breps') by(`by') cc(`cc') cimethod(`cimethod') 
									ciopt(`ciopt') `classic' `paired' `double' download(`download') dp(`dp') `force' `ftt'  ilevel(`ilevel') 
									`interaction' `logit' label(`label') model(`model2') modelopts(`model2opts') nograph notable olevel(`olevel') outplot(`outplot') power(`power') `rfdist'  rflevel(`rflevel') wgt(`wgt') ;
								#delimit cr
								
								local S_1 = r(ES)			
								local S_2 = r(seES)
								local S_3 = r(ci_low)
								local S_4 = r(ci_upp)
								local S_5 = r(z)
								local S_6 = r(p_z)
								local S_7 = r(het)
								local S_8 = r(df)
								local S_9 = r(p_het)
								local S_10 = r(chi2)
								local S_11 = r(p_chi2)
								local S_12 = r(tau2)
								local S_13 = r(wtau2)
								local S_14 = r(i_sq)
								local hmean = r(hmean)
								local model = r(model)
							  }
							  else {
								 /*Obtain estimates*/
								 if "`outplot'" == "abs"{
									local S_1 = `MA_second_absout'[`j', 1]
									local S_2 = `MA_second_absout'[`j', 2]
									local S_3 = `MA_second_absout'[`j', 5]
									local S_4 = `MA_second_absout'[`j', 6]
									local S_5 = `MA_second_absout'[`j', 3]
									local S_6 = `MA_second_absout'[`j', 4]
								}
								if "`outplot'" == "rr" {
									local S_1 = `MA_second_rrout'[`j', 1] //effect
									local S_2 = `MA_second_rrout'[`j', 2] //se
									local S_3 = `MA_second_rrout'[`j', 5] //lci
									local S_4 = `MA_second_rrout'[`j', 6] //uci
									local S_5 = `MA_second_rrout'[`j', 3] //z-value in the log scale
									local S_6 = `MA_second_rrout'[`j', 4] //p-value in the log scale									
								}
								
								local S_7 = .
								local S_8 = `MA_second_DF'
								local S_9 = .
								local S_10 = .
								local S_11 = .
								local S_12 = `MA_second_TAU2'
								local S_13 = `MA_second_WTAU2'
								local S_14 = .
								local model = "`MA_second_model'"
								
								if "`rfdist'" !=  "" {
									replace `lci' = `MA_second_predci'[`j', 1] if `use'==20 & `newby'==`j'
									replace `uci' = `MA_second_predci'[`j', 2] if `use'==20 & `newby'==`j'
								}
							}

	/*===============================================================================================*/
	/*==================    Start the Freeman Tukey Back tranformation       ========================*/
	/*===============================================================================================*/		
							if "`ftt'"  != ""  {
								tempname mintes maxtes
								scalar `mintes' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
								scalar `maxtes' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
								if `S_1' < `mintes' {
									replace `effect' = 0 if `use'==19 & `newby'==`j'
								} 
								else if `S_1' > `maxtes' {
									replace `effect' = 1 if `use'==19 & `newby'==`j'
								}
								else {
									replace `effect' = 0.5 * (1 - sign(cos(`S_1')) * sqrt(1 - (sin(`S_1') + (sin(`S_1') - 1/sin(`S_1'))/(`hmean'))^2)) if `use'==19 & `newby'==`j'
								}
				
								if `S_3' < `mintes' {
									replace `lci' = 0 if `use'==19 & `newby'==`j'
								} 
								else if `S_3' > `maxtes' {
									replace `lci' = 1 if `use'==19 & `newby'==`j'
									}
								else {
									replace  `lci' = 0.5 * (1 - sign(cos(`S_3')) * sqrt(1 - (sin(`S_3') + (sin(`S_3') - 1/sin(`S_3'))/(`hmean'))^2)) if `use'==19 & `newby'==`j'
								}

								if `S_4' < `mintes' {
									replace `uci' = 0 if `use'==19 & `newby'==`j'
								} 
								else if `uci'[`i'] > `maxtes' {
									replace `uci' = 1 if `use'==19 & `newby'==`j'
								}
								else {

									replace `uci' = 0.5 * (1 - sign(cos(`S_4')) * sqrt(1 - (sin(`S_4') + (sin(`S_4') - 1/sin(`S_4'))/(`hmean'))^2)) if `use'==19 & `newby'==`j'
								}
								if "`rfdist'" != "" {
									tempname fttlci fttuci
									scalar `fttlci' = `S_1' - invttail((`S_8'), 0.5-`rflevel'/200)*sqrt(`S_12' + `S_2'^2) 
									scalar `fttuci' = `S_1' + invttail((`S_8'), 0.5-`rflevel'/200)*sqrt(`S_12' + `S_2'^2) 
								
									replace `lci' = 0 if `fttlci' < `mintes' & `use'==20 & `newby'==`j'
									replace `lci' = 1 if `fttlci' > `maxtes' & `use'==20 & `newby'==`j'
									replace `lci' = 0.5 * (1 - sign(cos(`fttlci')) * sqrt(1 - (sin(`fttlci') + (sin(`fttlci') - 1/sin(`fttlci'))/(`hmean'))^2)) if (`fttlci' <= `maxtes') & (`fttlci' >= `mintes') & `use'==20 & `newby'==`j'
									
									replace `uci' = 0 if `fttuci' < `mintes' & `use'==20 & `newby'==`j'
									replace `uci' = 1 if `fttuci' > `maxtes' & `use'==20 & `newby'==`j'
									replace `uci' = 0.5 * (1 - sign(cos(`fttuci')) * sqrt(1 - (sin(`fttuci') + (sin(`fttuci') - 1/sin(`fttuci'))/(`hmean'))^2)) if (`fttuci' <= `maxtes') & (`fttuci' >= `mintes') & `use'==20 & `newby'==`j'
								}
	/*===============================================================================================*/
	/*==================    Finish the Freeman Tukey Back tranformation      ========================*/
	/*===============================================================================================*/	
							} 

							else {
								replace `effect'=(`S_1') if `use'==19 & `newby'==`j'
								replace `lci'=(`S_3') if `use'==19 & `newby'==`j'
								replace `uci'=(`S_4') if `use'==19 & `newby'==`j'
							}
							replace `se'=(`S_2') if `use'==19 & `newby'==`j'
							replace `hetdf' = `S_8' if `use'==19 & `newby'==`j'
							replace `tau2' = `S_12' if `use'==19 & `newby'==`j'
							replace `wtau2' = `S_13' if `use'==19 & `newby'==`j'
							replace `tsig'=(`S_5') if `use'==19 & `newby'==`j'
							replace `psig'=(`S_6') if `use'==19 & `newby'==`j'
							replace `fittedmodel' = strproper("`MA_second_model'") if `use'==19 & `newby'==`j'
						}

						/* THEN GET REGULAR ESTIMATES AS USUAL */
						if "`byreg'" == "" {
								#delimit ;			
								`nextcall' `varlist' if (`newby'==`j' & `use'==1),
									studyid(`studyid')  breps(`breps') by(`by') cc(`cc') cimethod(`cimethod') 
									ciopt(`ciopt') `classic' `paired' `double' download(`download') dp(`dp') `force' `ftt'  ilevel(`ilevel') 
									`interaction' `logit' label(`label') model(`model') modelopts(`modelopts') nograph notable olevel(`olevel') outplot(`outplot') power(`power') `rfdist'  rflevel(`rflevel') wgt(`wgt') ;
								#delimit cr
								
								local S_1 = r(ES)			
								local S_2 = r(seES)
								local S_3 = r(ci_low)
								local S_4 = r(ci_upp)
								local S_5 = r(z)
								local S_6 = r(p_z)
								local S_7 = r(het)
								local S_8 = r(df)
								local S_9 = r(p_het)
								local S_10 = r(chi2)
								local S_11 = r(p_chi2)
								local S_12 = r(tau2)
								local S_13 = r(wtau2)
								local S_14 = r(i_sq)
								local hmean = r(hmean)
								local model = r(model)
						}
						else {							  
							/*Obtain estimates*/
							 if "`outplot'" == "abs"{
								local S_1 = `MA_first_absout'[`j', 1]
								local S_2 = `MA_first_absout'[`j', 2]
								local S_3 = `MA_first_absout'[`j', 5]
								local S_4 = `MA_first_absout'[`j', 6]
								local S_5 = `MA_first_absout'[`j', 3]
								local S_6 = `MA_first_absout'[`j', 4]
							}
							if "`outplot'" == "rr" {
								local S_1 = `MA_first_rrout'[`j', 1] //effect
								local S_2 = `MA_first_rrout'[`j', 2] //se
								local S_3 = `MA_first_rrout'[`j', 5] //lci
								local S_4 = `MA_first_rrout'[`j', 6] //uci
								local S_5 = `MA_first_rrout'[`j', 3] //z-value in the log scale
								local S_6 = `MA_first_rrout'[`j', 4] //p-value in the log scale									
							}
							local S_7 = .
							local S_8 = `MA_first_DF'
							local S_9 = .
							local S_10 = .
							local S_11 = .
							local S_12 = `MA_first_TAU2'
							local S_13 = `MA_first_WTAU2'
							local S_14 = .
							local model = "`MA_first_model'"
							if "`rfdist'" !=  "" {
								replace `lci' = `MA_first_predci'[`j', 1] if `use'==4 & `newby'==`j'
								replace `uci' = `MA_first_predci'[`j', 2] if `use'==4 & `newby'==`j'
							}
						}
	/*===============================================================================================*/
	/*==================    Start the Freeman Tukey Back tranformation       ========================*/
	/*===============================================================================================*/
						if "`ftt'"  != ""  {
								tempname mintes maxtes
								scalar `mintes' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
								scalar `maxtes' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
								if `S_1' < `mintes' {
									replace `effect' = 0 if `use'==3 & `newby'==`j'
								} 
								else if `S_1' > `maxtes' {
									replace `effect' = 1 if `use'==3 & `newby'==`j'
								}
								else {
									replace `effect' = 0.5 * (1 - sign(cos(`S_1')) * sqrt(1 - (sin(`S_1') + (sin(`S_1') - 1/sin(`S_1'))/(`hmean'))^2)) if `use'==3 & `newby'==`j'
								}
				
								if `S_3' < `mintes' {
									replace `lci' = 0 if `use'==3 & `newby'==`j'
								} 
								else if `S_3' > `maxtes' {
									replace `lci' = 1 if `use'==3 & `newby'==`j'
									}
								else {
									replace  `lci' = 0.5 * (1 - sign(cos(`S_3')) * sqrt(1 - (sin(`S_3') + (sin(`S_3') - 1/sin(`S_3'))/(`hmean'))^2)) if `use'==3 & `newby'==`j'
									}

								if `S_4' < `mintes' {
									replace `uci' = 0 if `use'==3 & `newby'==`j'
								} 
								else if `S_4' > `maxtes' {
									replace `uci' = 1 if `use'==3 & `newby'==`j'
								}
								else {
									replace `uci' = 0.5 * (1 - sign(cos(`S_4' )) * sqrt(1 - (sin(`S_4' ) + (sin(`S_4' ) - 1/sin(`S_4'))/(`hmean'))^2)) if `use'==3 & `newby'==`j'
								}
								if "`rfdist'" != "" {
									tempname fttlci fttuci
									scalar `fttlci' = `S_1' - invttail((`S_8'), 0.5-`rflevel'/200)*sqrt(`S_12' + `S_2'^2) 
									scalar `fttuci' = `S_1' + invttail((`S_8'), 0.5-`rflevel'/200)*sqrt(`S_12' + `S_2'^2) 
								
									replace `lci' = 0 if `fttlci' < `mintes' & `use'==4 & `newby'==`j'
									replace `lci' = 1 if `fttlci' > `maxtes' & `use'==4 & `newby'==`j'
									replace `lci' = 0.5 * (1 - sign(cos(`fttlci')) * sqrt(1 - (sin(`fttlci') + (sin(`fttlci') - 1/sin(`fttlci'))/(`hmean'))^2)) if (`fttlci' <= `maxtes') & (`fttlci' >= `mintes') & `use'==4 & `newby'==`j'
									
									replace `uci' = 0 if `fttuci' < `mintes' & `use'==4 & `newby'==`j'
									replace `uci' = 1 if `fttuci' > `maxtes' & `use'==4 & `newby'==`j'
									replace `uci' = 0.5 * (1 - sign(cos(`fttuci')) * sqrt(1 - (sin(`fttuci') + (sin(`fttuci') - 1/sin(`fttuci'))/(`hmean'))^2)) if (`fttuci' <= `maxtes') & (`fttuci' >= `mintes') & `use'==4 & `newby'==`j'
								}
	/*===============================================================================================*/
	/*==================    Finish the Freeman Tukey Back tranformation       ========================*/
	/*===============================================================================================*/	
							}  
							else {
								replace `effect'=(`S_1') if `use'==3 & `newby'==`j'
								replace `lci'=(`S_3') if `use'==3 & `newby'==`j'
								replace `uci'=(`S_4') if `use'==3 & `newby'==`j'
							} 
					
						replace `se'=(`S_2') if `use'==3 & `newby'==`j'	
					
						*Put within-subg weights in if nooverall or sgweight options specified
						if "`logit'" != "" {
							if ("`overall'`sgweight'"!="" )  {
								replace `wtdisp'=_WT if `newby'==`j'
								replace `wtdisp'=100 if (`use'==3 & `newby'==`j')
							}
							else {
								qui sum `wtdisp' if (`use'==1 & `newby'==`j')
								replace `wtdisp' = r(sum) if (`use'==3 & `newby'==`j')
							}
							sum `weight' if `newby'==`j'
							replace `weight'= r(sum) if `use'==3 & `newby'==`j'
							
							replace `hetc' =(`S_7') if `use'==3 & `newby'==`j'
							replace `hetdf'=(`S_8') if `use'==3 & `newby'==`j'
							replace `hetp' =(`S_9') if `use'==3 & `newby'==`j'
							
						}
						else {					
							replace `hetc' =(`S_10') if `use'==3 & `newby'==`j'
							replace `hetp' = (`S_11') if `use'==3 & `newby'==`j'
							if "`byreg'" == "" {
								replace `hetdf'= (`S_8') if `use'==3 & `newby'==`j'
							}
							else {
								replace `hetdf'= (`=`N'-1') if `use'==3 & `newby'==`j'
							}
						}							
						replace `tsig'=(`S_5') if `use'==3 & `newby'==`j'
						replace `psig'=(`S_6') if `use'==3 & `newby'==`j'						
						replace `tau2' = `S_12' if `use'==3 & `newby'==`j'
						replace `wtau2' = `S_13' if `use'==3 & `newby'==`j'
						replace `i2' = (`S_14') if `use'==3 & `newby'==`j'
						replace `fittedmodel' = strproper("`model'") if `use'==3 & `newby'==`j'
				
					} /* END OF IF SUBGROUP N > 0 */

					*Whether data or not - put cell counts in subtotal row if requested (will be 0/n1;0/n2 or blank if all use>1)
				} /* END OF if "`subgroup'" == "" */		
				*Label attatched (if any) to byvar

				local lbl: value label `by2'
				sum `by2' if `newby'==`j'
				local byvlu=r(mean)
				
				if "`lbl'"=="" { 
					local lab "`by2'==`byvlu'" 
				}
				else { 
					local lab: label `lbl' `byvlu' 
				}

				replace `label' = "`lab'" if ( `use'==0 & `newby'==`j')
				replace `label' = "Summary" if ( `use'==3 & `newby'==`j') /**/

				/* RMH I^2 added in next line 
					RJH- also p-val as recommended by Mike Bradburn */
				if ("`model'" == "fixed" & "`paired'" == "")  | ("`model'" == "marginal" & "`logit'" == "") {
					replace `label' = "Summary" if ( `use'==3 & `newby'==`j')
				}
				if ("`model'" != "fixed" & "`paired'" == "") | ("`model'" != "marginal" & "`paired'" != ""){						
					if "`logit'" != "" {
						replace `label' = "Summary  (I^2 = " + string(`i2', "%5.1f")+ "%, p = " + ///
						string(`hetp', "%10.`=`dp''f") + ")" if ( `use'==3 & `newby'==`j' & "`het'" == "")
					}	
					if "`'logit" == "" & "`byreg'" == "" {
						replace `label' = "Summary  (I^2 = " + string(`S_14', "%10.`=`dp''f") + ", p = " + ///
						string(`hetp', "%10.`=`dp''f") + ")" if  (`use'==3 & `newby'==`j') & `S_14' != .
					}
				}
									
				replace `label' = "" if ( `use'==3 & `newby'==`j' & `hetdf' == 0) 
					
				local j=`j'+1
			} /* 	FINALLY, THE END OF THE WHILE LOOP! */
		if ("`MA_first_model'" == "fixed" & "`paired'" == "")  | ("`MA_first_model'" == "marginal" & "`logit'" == "") {
			replace `label' = "Overall" if (`use'==5 )
		}
		if ("`MA_first_model'" != "fixed" & "`paired'" == "") | ("`MA_first_model'" != "marginal" & "`paired'" != ""){	
			if "`logit'" != "" {
				replace `label' = "Overall  (I^2 = " + string(`i2', "%10.`=`dp''f")+ "%, p = " + ///
				string(`hetp', "%10.`=`dp''f") + ")" if ( `use'==5 & "`het'" == "")
			}
			if "`logit'" == "" & "`byreg'" == "" {
				replace `label' = "Overall  (I^2 = " + string(`S_14', "%10.`=`dp''f") + ", p = " + ///
				string(`hetp', "%10.`=`dp''f") + ")" if  (`use'==5) & `S_14' != .
			}
		}
		replace `label' = "" if ( `use'==5 & `hetdf' == 0) 
		
		//PREDICTIONS
		if "`logit'" != "" & "`ftt'" == "" & "`rfdist'" != "" {
			replace `df' = `df'-1 if `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20	
			replace `lci' = `effect' - invttail((`df'), 0.5-`rflevel'/200)*sqrt(`tau2'+`se'^2) if `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20
			replace `uci' = `effect' + invttail((`df'), 0.5-`rflevel'/200)*sqrt(`tau2'+`se'^2) if `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20
			
			replace `lci' = 0 if `lci' < 0  & (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
			replace `uci' = 1 if `lci'  > 1  & (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		}
	} /*End of quietly loop*/
	*Put table up (if requested)

	tempvar rjhorder
	qui gen `rjhorder' = `use'
	qui replace `rjhorder' = 3.5 if `use' == 19	// SWAP ROUND SO BLANK IN RIGHT PLACE
	sort `newby' `rjhorder' `sortby'  `id'

	// need to ditch this if SECOND specified
	if "`subgroup'" != "" {
		qui drop if `use' == 3 | `use' == 4 |`use' == 19 |`use' == 20
	}
	if "`table'"=="" {
		di as res _n"****************************************************************************************"
        di as res "{pmore2} Study specific, subgroup and overall measures  : `plotstat'{p_end}"
		di as res "****************************************************************************************"
		qui gen str20 `tlabel'=`label'
		
		if "`paired'" != "" {
			local mfmt "(paired)"
		}
		tempvar tlabellen 
		qui gen `tlabellen' = strlen(`tlabel')
		qui summ `tlabellen'
		local maxlabellen = r(max) + 1
		
		local nlen  = strlen("`MA_first_model'`mfmt'  `plotstat'") + 3
		local nlen = max(`nlen', `maxlabellen')
		
		local nlen2  = strlen("`plotstat'") + 1
		
		if "`model2'" != "" {
			local nlen = max(`nlen', `=strlen("`MA_second_model'`mfmt'  `plotstat'") + 3')
		}
		
		if "`logit'" == "" {
			local wt "nowt"
		}
		
		if "`wt'"=="" { 
			local ww  "% Weight" 
		}
		di _n as txt _col(12) "Study" _col(`nlen') "|"  " " _skip(5) "`plotstat'" /*
			 */  _col(`=`nlen' + `nlen2' + 15') "[`ilevel'% Conf. Interval]"  _col(`=`nlen' + `nlen2' + 40') "`ww'"
		di  _dup(`=`nlen'-1') "-" "+" _dup(51) "-"

		*legend for pooled confidence intervals
	
		local i=1
		while `i'<= _N {

			if (`use'[`i'])==0 { 
				*by label
				di _col(6) as txt `tlabel'[`i'] 
			}
			if "`wt'"=="" { 
				local ww=`wtdisp'[`i'] 			
			}
			else { 
				local ww 
			}

			if (`use'[`i'])==1 { 
				*trial results
				di as txt `tlabel'[`i'] _col(`nlen') "|  " as res  %10.`=`dp''f  `effect'[`i']*(10^`power') /* 
					*/ _col(`=`nlen' + `nlen2' + 12') %10.`=`dp''f `lci'[`i']*(10^`power') "  " %10.`=`dp''f `uci'[`i']*(10^`power') _col(`=`nlen' + `nlen2' + 37')  %10.`=`dp''f `ww' 
			}

			if (`use'[`i'])==2 {
				*excluded trial
				di as txt `tlabel'[`i'] _col(`nlen') "|  (Excluded)"
			}

			if ((`use'[`i']==3 | `use'[`i']==19) & "`subgroup'"=="") | (`use'[`i']==5 | `use'[`i']==17) {

				*Subgroup effect size or overall effect size
				if (`use'[`i'])==3 & `hetdf'[`i'] != 0 { 
					di as txt " Summary" _col(`nlen') "|"
				}
				if `use'[`i']==17 | `use'[`i']==5{ 
					if `ilevel' != `olevel' { 
						local insert "[`olevel'% Conf. Interval]" 
					}
					if `use'[`i'] == 5{
						di as txt "Overall"  _col(`nlen') "|" _col(34) "`insert'"
					}
				}

				if "`ww'"=="." { 
					local ww 
				}

				// RJH

				if (`use'[`i'] == 3 | `use'[`i'] == 5 ) & `hetdf'[`i'] > 0 {
					di as txt " [" `fittedmodel'[`i'] "`mfmt'" "]" " `plotstat'" _col(`nlen') "|  " as res  %10.`=`dp''f /*
					*/ `effect'[`i']*(10^`power') _col(`=`nlen' + `nlen2' + 12') %10.`=`dp''f  `lci'[`i']*(10^`power') "  "  %10.`=`dp''f `uci'[`i']*(10^`power') _col(`=`nlen' + `nlen2' + 37') %10.`=`dp''f `ww'
				}
				if (`use'[`i'] == 19 | `use'[`i'] == 17) & `hetdf'[`i'] > 0 {
					di as txt " [" `fittedmodel'[`i'] "`mfmt'"  "]" " `plotstat'" _col(`nlen') "|  " as res  %10.`=`dp''f /*
					*/ `effect'[`i']*(10^`power') _col(`=`nlen' + `nlen2' + 12') %10.`=`dp''f  `lci'[`i']*(10^`power') "  "  %10.`=`dp''f `uci'[`i']*(10^`power')
				}

				if (`use'[`i'])==5 & "`model2'" == "" | `use'[`i'] == 17{ 
					di as txt _dup(`=`nlen'-1') "-" "+" _dup(51) "-" 
				}
			}

			if (`use'[`i'])==8 { 
				*blank line separator (need to put line here in case nosubgroup was selected)
				di as txt _dup(`=`nlen'-1') "-" "+" _dup(51) "-" 
			}

			local i=`i'+1

		} /* END OF WHILE LOOP */

		*Skip next bits if nooverall AND nosubgroup
		if ("`subgroup'"=="" | "`overall'"=="") {		
			if ("`MA_first_model'" == "random") | ("`MA_first_model'" == "fixed" & "`paired'" != "")  {

				if "`logit'" != "" {
					di as txt _n "Test(s) of heterogeneity:" _n _col(16) "Heterogeneity  degrees of"
					di as txt _col(18) "statistic     freedom      	    P       I^2**" _cont
					if "`MA_first_model'"=="random" { 
						di as txt _skip(8) "Tau^2" 
					}
				}
				if "`logit'" == "" {
					if "`byreg'" != "" {
						di as txt _n "Test of heterogeneity:" _n _col(16) "RE-FE:LR Test"  _skip(2) "degrees of"
						di as txt _col(18) "statistic" _skip(6) "freedom"      _skip(8)"P"   _skip(10) "Tau^2" _cont
					}
					else {
						di as txt _n "Test of heterogeneity:" _n _col(16) "RE-FE:LR Test"  _skip(2) "degrees of"
						di as txt _col(18) "statistic" _skip(6) "freedom"      _skip(8)"P"   _skip(8) "I^2**" _skip(10) "Tau^2" _cont
					}
					if ("`MA_first_model'" == "random" & "`paired'" != "")  { 
						di as txt _skip(8) "W.Tau^2" 
					} 
				}				

				local maxHet = 0
				local i=1
				local runonce = 0
				while `i'<= _N {
					if (("`subgroup'"=="" & (`use'[`i'])==0) | ( (`use'[`i'])==5)) {
						if "`byreg'" != "" & `runonce' == 0 {
								di as txt _n "Overall" _cont
						}
						if "`byreg'" == ""  {
							if `use'[`i'] != 5 {
								di as txt _n `tlabel'[`i'] _cont
							}
							else {
								di as txt _n  "Overall" _cont 
							}
						}
					}					
					if "`logit'" != ""  {
						if ( ((`use'[`i'])==3) | ((`use'[`i'])==5) ) { 

							di as res _col(20) %10.`=`dp''f `hetc'[`i'] _col(35) %3.0f `hetdf'[`i']   /*
							  */  _col(43) %10.`=`dp''f `hetp'[`i'] _col(51) %10.`=`dp''f `i2'[`i'] "%" _col(66) %10.`=`dp''f `tau2'[`i']  _cont
							if `use'[`i'] == 3{
								local maxHet = max(`maxHet',`i2'[`i'])
							}
							if `use'[`i'] == 5{
								local ovHet = `i2'[`i']
							}
						}
					}
					if "`maxHet'" == "" {
						local maxHet = 0
					}
					if "`logit'" == "" {						
						if `runonce' == 0 {
							if (((`use'[`i'])==3) | ((`use'[`i'])==5) ) { 
								di as res _col(20) %10.`=`dp''f `hetc'[`i'] _col(35) %3.0f `hetdf'[`i']   /*
								  */  _col(40) %10.`=`dp''f `hetp'[`i'] _col(48) %10.`=`dp''f `i2'[`i'] "%" _col(66) %10.`=`dp''f `tau2'[`i']  _cont
								if `use'[`i'] == 3 {
									local maxHet = max(`maxHet',`i2'[`i'])
								}
								if `use'[`i'] == 5{
									local ovHet = `i2'[`i']
								}
							}
							if "`byreg'" == "" {
								local runonce = 0
							}
							else {								
								if "`paired'" == "" | ("`MA_first_model'"  == "fixed" & "`paired'" != "") {
									qui estimates restore metapreg_Full
									di as res _col(20) %10.`=`dp''f e(chi2_c) _col(35) %3.0f e(df_c)   /*
									  */  _col(40) %10.`=`dp''f e(p_c)  _col(48) %10.`=`dp''f `MA_first_TAU2' _cont
								}
								else {
									qui lrtest 	metapreg_Full metapreg_fixedFull, force
									
									di as res _col(15) %10.`=`dp''f r(chi2) _col(35) %3.0f r(df)   /*
									  */  _col(40) %10.`=`dp''f r(p)  _col(54) %10.`=`dp''f `MA_first_TAU2'  _col(68) %10.`=`dp''f `MA_first_WTAU2'  _cont

								}

								local runonce = 1
							}
						}
					}
					local i = `i'+1
				}
			}
			
			qui count if `hetdf' !=. &  `use'==3
			local df = r(N) - 1	
			if "`subgroup'"=="" {
				if "`byreg'" == "" {
					tempvar est
					if "`ftt'" != "" {
						qui gen double `est' = `fttes'
					}
					else{
						qui gen double `est' = `effect'
					}

					if "`MA_first_model'" == "fixed" {
						scalar `mean' = `MA_first_ES'
					}
					else {
						qui gen `weightedest' = `est'/(`se'^2) 
						qui sum `weightedest' if `use'==3
						scalar `sumweightedest' = r(sum)
						qui gen `weightrandom' = 1/(`se'^2)
						qui sum `weightrandom' if `use'==3
						scalar `sumweights' = r(sum)
						scalar `mean' = `sumweightedest'/`sumweights'
					}
					qui gen `weightedsquare_first' = (1/(`se')^2)*(`est' - `mean')^2 
					qui sum `weightedsquare_first' if `use' == 3
					local btwghet_first = r(sum)
					local rjhHetGrp = chiprob(`df', `btwghet_first')
					di _n as txt "`=strproper("`MA_first_model'")': Test for heterogeneity between sub-groups: " _n    		/*
					*/ as res _col(20) %10.`=`dp''f `btwghet_first' _col(35) %3.0f `df'  _col(43) %10.`=`dp''f  /*
					*/ 	(chiprob(`df', `btwghet_first'))
					if ("`model2'" != ""){
						if "`MA_second_model'" == "fixed" {
							scalar `mean' = `MA_second_ES'
						}
						else {
							qui gen `weightedest' = `est'/(`se'^2) 
							qui sum `weightedest' if `use'==19
							scalar `sumweightedest' = r(sum)
							qui gen `weightrandom' = 1/(`se'^2)
							qui sum `weightrandom' if `use'==19
							scalar `sumweights' = r(sum)
							scalar `mean' = `sumweightedest'/`sumweights'
						}
						qui gen `weightedsquare_second' = (1/(`se')^2)*(`est' - `mean')^2 
						qui sum `weightedsquare_second' if `use' == 19
						local btwghet_second = r(sum)	
						di _n as txt "`=strproper("`MA_second_model'")': Test for heterogeneity between sub-groups: " _n   /*
						*/ as res _col(20) %10.`=`dp''f `btwghet_second' _col(35) %3.0f `df'  _col(43) %10.`=`dp''f  /*
						*/ 	(chiprob(`df', `btwghet_second'))
					}
					
					if "`MA_first_model'" == "random" {
						if "`logit'" != "" {
							local stat = "`plotstat'"
						}
						else {
							local stat = "log-odds"
						}
						di _n as txt "** I^2: the variation in `stat' attributable to between study heterogeneity" _n
					}
				}
				else {
					di _n(2) as txt "`=strproper("`MA_first_model'")': Test for heterogeneity between sub-groups: " 
					if `p' == 1 {
						di as txt "(LR Test model with & without: `byreg')" _n 
						qui lrtest metapreg_Full metapreg_Null, force
					}
					else {
						di as txt "(LR Test model with & without interactions)" _n 
						qui lrtest metapreg_Full metapreg_reducedFull, force
					}
					if  ("`MA_first_model'" == "marginal") {	
						di as txt  _col(30) "degrees of"
						di as txt _col(20) "statistic" _col(32) "freedom"      _skip(8)"P"  _n
					}
					local rjhHetGrp = r(p)
					di as res _col(20) %10.`=`dp''f r(chi2) _col(35) %3.0f r(df)   /*
					  */  _col(43) %8.`=`dp''f r(p)   _cont
					if r(df) == 0 {
						di as res "Warning: Invalid test"
					}
					if "`model2'" != "" {
						di _n as txt "`=strproper("`MA_second_model'")': Test for heterogeneity between sub-groups: " 
						if `p' == 1 {
							qui lrtest metapreg_second_Fest metapreg_second_Nest, force
							di as txt "(LR Test model with & without: `byreg')" _n 
						}
						else {
							qui lrtest metapreg_second_Fest metapreg_second_reducedFull, force //with and without interaction
							di as txt "(LR Test model with & without interactions)" _n 
						}					
						
						di as res _col(20) %10.`=`dp''f r(chi2) _col(35) %3.0f r(df)   /*
						  */  _col(43) %8.`=`dp''f r(p)    _cont
						if r(df) == 0 {
							di as res "Warning: Invalid test"
						}
					}
				}
			}	
			
			// DISPLAY BETWEEN-GROUP TEST WARNINGS
			if "`overall'" == ""  & "`byreg'" == "" {
				if "`maxHet'" == "" {
					local maxHet = 0
				}
				if `maxHet' < 50 & `maxHet' > 0 & ("`model'" == "random"){
					di as txt "Some heterogeneity observed (up to "%4.1f `maxHet' "%) in one or more sub-groups,"
					di as txt "Test for heterogeneity between sub-groups may be invalid"						
				}
				if `maxHet' < 75 & `maxHet' >= 50 & ("`model'" == "random"){
					di as txt "Moderate heterogeneity observed (up to "%4.1f `maxHet' "%) in one or more sub-groups,"
					di as txt "Test for heterogeneity between sub-groups likely to be invalid"
				}
				if `maxHet' < . & `maxHet' >= 75 & ("`model'" == "random"){
					di as txt "Considerable heterogeneity observed (up to "%4.1f `maxHet' "%) in one or more sub-groups,"
					di as txt "Test for heterogeneity between sub-groups likely to be invalid"
				}
			}
			*part 3: test statistics
			di _n as txt "Significance test(s) of  `plotstat' = "as res "`h0'" 
			if "`model2'" != "" {
				di _n as txt "`=strproper("`MA_second_model'")' model"
				local i=1
				while `i'<= _N {
					if ("`nosecsub'"=="" & (`use'[`i'])==0) | ( (`use'[`i'])==17) { 
						if `use'[`i'] != 17{
							di as txt _n `tlabel'[`i'] _cont 
						}
						else{
							di as txt _n  "Overall" _cont 
						}
					}

					if ( ((`use'[`i'])==17) | ((`use'[`i'])==19) ) { 
						di as txt _col(23) "z= " as res %-10.`=`dp''f `tsig'[`i'] _col(35) as txt  /*
							*/ " p = "  as res %-10.`=`dp''f `psig'[`i'] _cont
					}
					local i=`i'+1
				}
				di _n _n as txt "`=strproper("`MA_first_model'")' model"
			}
			

			local i=1
			while `i'<= _N {
				if ("`subgroup'"=="" & (`use'[`i'])==0) | ( (`use'[`i'])==5) { 
					if `use'[`i'] != 5{
						di as txt _n `tlabel'[`i'] _cont 
					}
					else{
						di as txt _n  "Overall" _cont 
					}
				}

				if ( ((`use'[`i'])==3) | ((`use'[`i'])==5) ) { 
					di as txt _col(23) "z= " as res %-10.`=`dp''f `tsig'[`i'] _col(35) as txt  /*
						*/ " p = "  as res %-10.`=`dp''f `psig'[`i'] _cont
				}
				local i=`i'+1
			}
			di _n as txt _dup(73) "-" 

		} /* end of if ("`subgroup'"=="" | "`overall'"=="") */

	} /* end of table display */

	if "`overall'"=="" {
		local S_1 = `MA_first_ES' 
		local S_2 = `MA_first_SE_ES' 
		local S_3 = `MA_first_LCI' 
		local S_4 = `MA_first_UCI' 
		local S_5 = `MA_first_Z' 
		local S_6 = `MA_first_P_Z' 
		local S_7 = `MA_first_HET'
		local S_8 = `MA_first_DF' 
		local S_9 = `MA_first_P_HET' 
		local S_10 = `MA_first_CHI2' 
		local S_11 = `MA_first_PCHI2' 
		local S_12 = `MA_first_TAU2'
		local S_13 = `MA_first_WTAU2' 
		local S_14 = `MA_first_I2'

	} /* end if overall */
	else {
		forvalues i = 1/14{
			local S_`i' .
		}
	}
	if "`graph'" == "" {
	
		tempvar hetGroupLabel expandOverall orderOverall
		qui {
			if  "`het'" == "" {
				qui count
				local prevMax = r(N)
				gen `orderOverall' = _n
				gen `expandOverall' = 1
				replace `expandOverall' = 2 if `use' == 5
				expand `expandOverall'
				replace `orderOverall' = `orderOverall' -0.5 if _n > `prevMax'
				gen `hetGroupLabel' = "Heterogeneity between groups: p = " + ///
					  string(`rjhHetGrp', "%5.3f") if _n > `prevMax'
				replace `use' = 8 if _n > `prevMax'
				sort `orderOverall'
			}
			else{
				gen `hetGroupLabel' = .
			}
		}
	
		#delimit ;
		_dispgby `effect' `lci' `uci' `weight' `wtdisp' `use' `label'  `hetdf' `tau2' `wtau2' `hetGroupLabel',
			studyid(`studyid') astext(`astext') boxopt(`boxopt') boxsca(`boxsca') by(`by')  
			ciopt(`ciopt') `classic' `paired'  diamopt(`diamopt') `double' download(`download') dp(`dp') `force' `ftt'  ilevel(`ilevel') `logit' lcols(`lcols') model(`model') model2(`MA_second_model')
			`box' `graph' `het'  `overall'  `ovline' `secsub'  `stats' 
			`subgroup'   `wt'  olevel(`olevel') olineopt(`olineopt') outplot(`outplot') plotstat(`plotstat')
			pointopt(`pointopt') power(`power') predciopt(`predciopt') rcols(`rcols') `rfdist'  rflevel(`rflevel')  `sgweight' 
			sortby(`sortby') `subline' `summaryonly' tablestat(`tablestat') texts(`texts') wgt(`wgt') `xlabel'  `xtick' regressors(`regressors') by2(`by2') otheropts(`otheropts') `options';
		#delimit cr

	}
	qui {
		cap drop _ES 
		cap drop _seES	
		gen _ES  =`effect'*(10^`power')
		label var _ES "`plotstat'"

		gen _seES = `se'
		label var _seES "se(`plotstat')"
		
		#delimit ;
		cap drop _WT;		
		cap drop _LCI; gen _LCI =`lci'*(10^`power');   label var _LCI "Lower CI (`plotstat')";
		cap drop _UCI; gen _UCI =`uci'*(10^`power');   label var _UCI "Upper CI (`plotstat')";
		#delimit cr
	   
	*correct weight if subgroup weights given	
		if ("`sgweight'"=="" & "`overall'"=="" ) & "`logit'" != ""  { 
			gen _WT=`weight' 
		}
		else if "`subgroup'"=="" & ("`overall'`sgweight'"!="" ) & "`logit'" != ""  {
			tempvar tempsum ordering
			gen `ordering' = _n
			bysort `by2': gen `tempsum'=sum(`weight')
	
			local N = _N
			if "`model2'" != ""{
				local N = _N-1
			}
			bysort `by2': replace `tempsum'=`tempsum'[`N']
			gen _WT=`weight'*100/`tempsum'
			local sg "(subgroup) "
			sort `ordering'
		}
		cap label var _WT "`model' `sg'% weight"
	}
	#delimit ;
	metapregsummary, 
		ma_first_model(`MA_first_model') ma_first_es(`MA_first_ES') ma_first_se_es(`MA_first_SE_ES') ma_first_lci(`MA_first_LCI') ma_first_uci(`MA_first_UCI') ma_first_z(`MA_first_Z') ma_first_p_z(`MA_first_P_Z') ma_first_het(`MA_first_HET') ma_first_df(`MA_first_DF') ma_first_p_het(`MA_first_P_HET') ma_first_chi2(`MA_first_CHI2') ma_first_pchi2(`MA_first_PCHI2') ma_first_tau2(`MA_first_TAU2') ma_first_wtau2(`MA_first_WTAU2') ma_first_i2(`MA_first_I2')  hmean(`hmean') ma_first_raw(`MA_first_raw') ma_first_absout(`MA_first_absout') ma_first_logodds(`MA_first_logodds') ma_first_rrout(`MA_first_rrout') ma_first_predci(`MA_first_predci') ma_first_opredci(`MA_first_opredci')
		ma_second_model(`MA_second_model') ma_second_es(`MA_second_ES')  ma_second_se_es(`MA_second_SE_ES') ma_second_lci(`MA_second_LCI') ma_second_uci(`MA_second_UCI') ma_second_z(`MA_second_Z') ma_second_p_z(`MA_second_P_Z') ma_second_het(`MA_second_HET') ma_second_df(`MA_second_DF') ma_second_p_het(`MA_second_P_HET') ma_second_chi2(`MA_second_CHI2') ma_second_pchi2(`MA_second_PCHI2') ma_second_tau2(`MA_second_TAU2') ma_second_wtau2(`MA_second_WTAU2') ma_second_i2(`MA_second_I2') ma_second_raw(`MA_second_raw') ma_second_logodds(`MA_second_logodds') ma_second_absout(`MA_second_absout') ma_second_rrout(`MA_second_rrout') ma_second_predci(`MA_second_predci') ma_second_opredci(`MA_second_opredci');
	#delimit cr
	if "`download'" != "" {
		qui gen _LABEL = `label'
		if "`logit'" != "" {
			local wt "_WT"
			local se "_seES"
		}
		else {
			local wt
			local se
		}
		keep _ID _LABEL _ES `se'  `wt' _LCI _UCI
		di _n
		save "`download'", replace
	}
	restore
	end
	*##########################################################################################################################################################
	*##########################################################################################################################################################
	capture program drop maxll
	program define maxll, rclass

	version 14.1

	#delimit ;

	syntax varlist(min=2 default=none) [if] [in] [,
		BReps(integer 1000)
		BY(string) 
		cci(varname) 
		CImethod(string) 
		paired 
		DP(integer 2) 
		ILevel(integer 95) 
		interaction
		LABEL(varname) 
		lcols(varlist)
		model(string) 
		modelopts(string)
		OLevel(integer 95) 
		outplot(string) 
		outtable(string) 
		plotstat(string asis) 
		POwer(integer 0)
		rcols(varlist)
		RFdist 
		RFLevel(integer 95)
		RJHSECOND		
		STUDYID(varname)
		tablestat(string asis) 
		ma_second_model(string) 
		ma_second_es(string)
		ma_second_se_es(string)
		ma_second_lci(string)
		ma_second_uci(string)
		ma_second_z(string)
		ma_second_p_z(string)
		ma_second_het(string)
		ma_second_df(string)
		ma_second_p_het(string)
		ma_second_chi2(string)
		ma_second_pchi2(string)
		ma_second_tau2(string)
		ma_second_wtau2(string)
		ma_second_i2(string)
		ma_second_raw(name)
		ma_second_logodds(name)
		ma_second_absout(name)
		ma_second_rrout(name)
		ma_second_predci(name)
		ma_second_opredci(name)
 			*];

	#delimit cr

	qui {
		tempvar n N a b c d incr es est use ill iul ipoints gid 
		
		tokenize "`varlist'", parse(" ")
		if "`dependent'" == "" {
			gen double `n' = `1'
			gen double  `N' = `2'
			local dep "`1' `2'"
			macro shift 2
		}
		else {
			gen double `a' = `1'
			gen double  `b' = `2'
			gen double `c' = `3'
			gen double  `d' = `4'
			local dep "`1' `2' `3' `4'"
			macro shift 4
		}
		local regressors "`*'"
		local p: word count `regressors'
		local VarX: word 1 of `regressors'
		if "`paired'" != ""  & "`VarX'" == ""{
			local paired
		}
		
		tokenize `tablestat'
		if "`1'" != "" {
			local tablestat1 "`1'"
		}
		else {
			local tablestat1 "Log_odds"
		}
		
		if "`2'" != "" {
			local tablestat2 "`2'"
		}
		else {
			local tablestat2 "Proportion"
		}
		
		if "`3'" != "" {
			local tablestat3 "`3'"
		}
		else {
			local tablestat3 "Rel_Ratio"
		}
		if (("`model'" == "marginal") | ("`model'" == "fixed" & "`paired'" == "")) {
			local conditional ""
		}
		
		gen double `use' = 1 `if' `in'
		replace `use' = 9 if `use' == .
		
		if "`dependent'" == "" {
			replace `use' = 9 if (`n' ==. | `N' == .)
		}
		else {
			replace `use' = 9 if (`a' ==. | `b' == .|`c' ==. | `d' == .)
		}
		
		count if `use'==1
		local Nstudies = r(N) 

		if `Nstudies' == 0 {
			exit
			di as err "Insufficient data"
		}
		if "`outplot'" == "abs" {
			tempvar es ill iul
			
			metapreg_propci `N' `n' if `use'==1, p(`es') lowerci(`ill') upperci(`iul') cimethod(`cimethod') level(`ilevel')
			*gen double  `ill' = ll
			*gen double  `iul' = ul
			*drop ul ll 
			
			*gen `es' = proportion
			*drop proportion
		}
		forvalues l=1/14 {
			local S_`l' = .
		}
		preserve		
		if `Nstudies' > 1 {
			if "`model'"=="random" & (`Nstudies' < 3) & "`paired'" == "" {
				local model "fixed"
				local rfdist ""
			}
			if "`model'"!="marginal" & (`Nstudies' < 3) & "`paired'" != "" {
				local model "marginal"
				local rfdist ""
			}
			local fittedmodel "`model'"
			qui ameans `N' if `use'==1 
			local hmean = r(mean_h)
			
			/*******************************  	Run Logistic Regression *********************************************/
			/*Begin doczone**********/
			/*
			use "D:\WIV\Projects\Stata\Metapreg\Data\bcg.dta", clear
			import delimited using "D:\WIV\Projects\Stata\Metadta\Data\ascus.csv", clear
			gen dis = tp + fn

			local varlist "cases_tb population bcg lat"
			local model "marginal"
			local paired "paired"
			local studyid "study"
			local use "use"
			 local VarX bcg
			gen use=1
			local interaction "interaction"
			cap drop mu
			gen mu = 1
			local outtable "all"
			local modelopts ""
			*/
			/*End doczone************/
			tempname Ocoef VOcoef raw logodds absout rrout predci opredci 
			
			buildregexpr `varlist', `interaction'
			local regexpression = r(regexpression)
			if "`regexpression'" == "mu" {
				local catreg  
			}
			else {
				local catreg = r(catreg)
			}
			
			
			/*Fit the model*/
			qui logitreg `varlist' if `use'==1, regexpression(`regexpression') model(`model') sid(`studyid') ///
				  modelopts(`modelopts') `paired' cci(`VarX') olevel(`olevel')
			
			estimates store metapreg_modest
			
			if (`p' == 0 & "`paired'" == "") | (`p' == 1 & "`paired'" != "" & "`outplot'" == "rr") | (`p' == 0 & "`paired'" != "" & "`outplot'" == "abs") {
				estimates store metapreg_Null
				local S_7 = 0
				*local S_8 = e(N) -  e(k)
				local S_9 = .
			}
			if (`p' > 0 & "`paired'" == "") | (`p' == 2 & "`paired'" != "" & "`outplot'" == "rr") | (`p' == 1 & "`paired'" != "" & "`outplot'" == "abs") {
				estimates store metapreg_Full
			}
			local S_8 = e(N) -  e(k)
			/*Obtained coefficients*/
			
			mat `Ocoef' = e(b)
			mat `VOcoef' = e(V)
			
			if("`outtable'" != "") {
				statlabel, `tablestat'
				local rawlabel = r(labraw)
				local loddslabel = r(lablodds)
				local abslabel = r(lababs)
				local rrlabel = r(labrr)
			}
			//RAW
			if ("`outtable'" == "all") |(strpos("`outtable'", "raw") != 0){
				local depname : word 1 of `varlist'
				noi estraw, estimates(metapreg_modest) sumstat(`rawlabel') depname(`depname') `paired' model(`model') 
			}
			else {
				local depname : word 1 of `varlist'
				estraw, estimates(metapreg_modest)  sumstat(`rawlabel')  depname(`depname') `paired' model(`model') noprint 
			}
			mat `raw' = r(outmatrix)

			//LOG ODDS
			if ("`outtable'" == "all") |(strpos("`outtable'", "logodds") != 0){
				noi estp, estimates(metapreg_modest)  sumstat(`loddslabel') grand catreg(`catreg') olevel(`olevel')
			}
			else {
				estp, estimates(metapreg_modest)  sumstat(`loddslabel') grand noprint catreg(`catreg') olevel(`olevel')
			}
			mat `logodds' = r(outmatrix)

			//ABS
			if ("`outtable'" == "all") |(strpos("`outtable'", "abs") != 0) {
				noi estp, estimates(metapreg_modest)  sumstat(`abslabel') grand expit catreg(`catreg') olevel(`olevel') power(`power')
			}
			else {
				estp, estimates(metapreg_modest)  sumstat(`abslabel') grand expit noprint catreg(`catreg') olevel(`olevel') 
			}
			mat `absout' = r(outmatrix)

			//RR
			if ("`outtable'" == "all") |(strpos("`outtable'", "rr") != 0) & `p' > 0 {
				noi estr, estimates(metapreg_modest) sumstat(`rrlabel') `paired' catreg(`catreg') olevel(`olevel') power(`power')
			}
			else {
				estr, estimates(metapreg_modest) sumstat(`rrlabel') `paired' noprint catreg(`catreg') olevel(`olevel')
			}
			
			if !_rc {
				mat `rrout' = r(outmatrix)
			}

			
			local npar = colsof(`Ocoef')
			if "`paired'" == "" {
				if "`model'" == "random" {
					local tau_b2 = exp(`Ocoef'[1, `npar'])^2
					local tau_t2 = 0
				}
				else {
					local tau_b2 = 0
					local tau_t2 = 0
				}
			}
			else {
				if "`model'" == "random"{
					local tau_b2 = exp(`Ocoef'[1, `=`npar'-1'])^2 //between-study
					local tau_t2 = exp(`Ocoef'[1, `npar'])^2 //within-study
				}
				else if "`model'" == "fixed" {
					local tau_b2 = exp(`Ocoef'[1, `npar'])^2 //between-study
					local tau_t2 = 0 //within-study
				}
				else {
					local tau_b2 = 0 //between-study
					local tau_t2 = 0 //within-study
				}
			}
			//Predictions
			if "`rfdist'" != "" {
				if "`outplot'" == "abs" {
					local nmu = rowsof(`absout')
					mat `predci' = J(`nmu', 2, .)
					forvalues r = 1/`nmu' {
						mat `predci'[`r', 1] = invlogit(logodds[`r',1] - invttail((`df'), 0.5-`rflevel'/200) * sqrt(`logodds'[`r',2]^2 + `tau_b2'^2 + `tau_t2'^2))
						mat `predci'[`r', 2] = invlogit(logodds[`r',1] + invttail((`df'), 0.5-`rflevel'/200)* sqrt(`logodds'[`r',2]^2 + `tau_b2'^2 + `tau_t2'^2))
					}
				}
				else {
					estimates restore metapreg_modest
					cap drop nu
					predict nu, xb
					
					cap drop sigma_nu
					predict sigma_nu, stdp
					local nlevs = rowsof(`rrout')
					noi bootprops, regexpression(`regexpression') nlevs(`nlevs') breps(`breps') model(`model') gid(`studyid') total(`N') `paired' cci(`VarX') outplot(`outplot') rfdist  regressors(`regressors') conditional olevel(`olevel')
					mat `predci' = r(ci)
					
					estimates restore metapreg_modest
					cap drop nu
					predict nu, xb
					
					cap drop sigma_nu
					predict sigma_nu, stdp
					local nlevs = 2
					noi bootprops, regexpression(`regexpression') nlevs(`nlevs') breps(`breps') model(`model') gid(`studyid') total(`N') `paired' cci(`VarX') outplot(`outplot') regressors(`regressors') rfdist conditional overall olevel(`olevel')
					mat `opredci' = r(ci)
					mat `opredci' = `opredci'[2, 1...2]
					mat `predci' = `predci', `opredci'
					mat drop `opredci'
				}
				//Return the widest CI for prediction
				/*if "`rfdist'" != "" {			
					if "`outplot'" == "abs" {
						local nrows = rowsof(absout)
						forvalues r = 1/`nrows' {
							mat predci[`r', 1] = min(predci[`r', 1], absout[`r', 5])
							mat predci[`r', 2] = max(predci[`r', 2], absout[`r', 6])	
						}
					}
					
					if "`outplot'" == "rr" {
						local nrows = rowsof(rrout)
						forvalues r = 1/`nrows' {
							mat predci[`r', 1] = min(predci[`r', 1], rrout[`r', 5])
							mat predci[`r', 2] = max(predci[`r', 2], rrout[`r', 6])	
						}
					}
				}*/
			}
			
			if `p' == 0 {
			/*Compute I2*/
				tempvar invN
				qui gen `invN' = 1/`N'
				qui summ `invN' if `use' == 1
				local invtotalN = r(sum)
				local K = r(N)
				
				local Etausq = (exp(`tau_b2'*0.5 + `logodds'[1,1]) + exp(`tau_b2'*0.5 - `logodds'[1,1]) + 2)*(1/(`K'))*`invtotalN'
				local S_14 = `tau_b2'/(`Etausq' + `tau_b2')*100	
			}
			else {			
				/*Fit null model*/
				if `p' == 1 & "`outplot'" == "abs" { 	
					logitreg `dep' if `use'==1, regexpression(mu) model(`model') sid(`studyid') ///
						modelopts(`modelopts') `paired' cci(`VarX') olevel(`olevel')
						
					estimates store metapreg_Null
					lrtest metapreg_Full metapreg_Null, force
					local S_7 = r(chi2)
					*local S_8 = r(df)
					local S_9 = r(p)
				}
				/*Fit reduced models: without interactions, fixed, and with cc only*/
				if `p' == 2 & "`outplot'" == "rr" & "`interaction'" != "" {
							
					restore, preserve
					
					buildregexpr `varlist'
					local regexpression = r(regexpression)
					
					logitreg `varlist' if `use'==1, regexpression(`regexpression') model(`model') sid(`studyid') ///
						modelopts(`modelopts') `paired' cci(`VarX') olevel(`olevel')
						
					estimates store metapreg_reducedFull	
					lrtest metapreg_Full metapreg_reducedFull, force
					local S_7 = r(chi2)
					*local S_8 = r(df)
					local S_9 = r(p)					
				}
				if "`model'" == "random" {	
					restore, preserve
				
					buildregexpr `varlist',`interaction'
					local regexpression = r(regexpression)
					if "`regexpression'" == "mu" {
						local catreg  
					}
					else {
						local catreg = r(catreg)
					}
					
					logitreg `varlist' if `use'==1, regexpression(`regexpression') model(fixed) sid(`studyid')  ///
						modelopts(`modelopts') `paired'  cci(`VarX') olevel(`olevel')
						
					estimates store metapreg_fixedFull
					lrtest metapreg_modest metapreg_fixedFull, force
					local S_10 = r(chi2)
					local S_11 = r(p)
				}
				local S_14 = .
			}

			if ("`model'" == "random" & "`paired'" == "") | ("`model'" == "fixed" & "`paired'" != ""){
				estimates restore metapreg_modest
				local S_10 = e(chi2_c)
				local S_11 = e(p_c)
			}

			if "`outplot'" == "abs" {
				local nrows = rowsof(`absout')
				local S_1 = `absout'[`nrows', 1] //p
				local S_2 = `absout'[`nrows', 2] //se
				local S_3 = `absout'[`nrows', 5] //ll
				local S_4 = `absout'[`nrows', 6] //ul
				local S_5 = `absout'[`nrows', 3] //z
				local S_6 = `absout'[`nrows', 4] //pvalue
			}
			else {
				local nrows = rowsof(`rrout')
				local S_1 = `rrout'[`nrows', 1] //rr
				local S_2 = `rrout'[`nrows', 2] //se
				local S_3 = `rrout'[`nrows', 5] //ll
				local S_4 = `rrout'[`nrows', 6] //ul
				local S_5 = `rrout'[`nrows', 3] //z
				local S_6 = `rrout'[`nrows', 4] //pvalue
			}
			
			restore, preserve
			
			/*Generate the RR*/
			if "`outplot'" == "rr" {
				if "`dependent'" != "" {
					cmlci `a' `b' `c' `d', rr(relrat) upperci(ul) lowerci(ll) alpha(`=1 - `ilevel'*0.01')
					
					gen double `es' = relrat
					gen double  `ill' = ll
					gen double  `iul' = ul
					drop relrat ul ll 
				} 
				else {				
					widesetup `n' `N' `regressors', sid(`studyid')
					local vlist = r(vlist)
					local cc0 = r(cc0)
					local cc1 = r(cc1)
					
					if "`cimethod'" == "bayes" {
							bayesci `n'1 `N'1 `n'0 `N'0, rr(relrat) upperci(ul) lowerci(ll) ///
								betaparms(`betaparms') betasucc(`betasucc') betafail(`betafail') ///
								nsim(`nsim') seed(`seed') alpha(`=1 - `ilevel'*0.01')
					}
					else {/*koopman*/
						koopmanci `n'1 `N'1 `n'0 `N'0, rr(`es') upperci(`iul') lowerci(`ill') alpha(`=1 - `ilevel'*0.01')
					}
					*gen double `es' = relrat
					*gen double  `ill' = ll
					*gen double  `iul' = ul
					*drop relrat ul ll 
				}

				//make new lcols, rcols
				local lcols_rr 
				local rcols_rr 
				
				foreach v of local lcols {
					if strpos("`vlist'", "`v'") != 0 {
						rename `v'0 `v'_`cc0'
						label var `v'_`cc0' "`v'_`cc0'"
						rename `v'1 `v'_`cc1'
						label var `v'_`cc1' "`v'_`cc1'"
						local lcols_rr "`lcols_rr' `v'_`cc0' `v'_`cc1'"
					}
					else {
						local lcols_rr "`lcols_rr' `v'"
					}
				}
				
				foreach v of local rcols {
					if strpos("`vlist'", "`v'") != 0 {
						rename `v'0 `v'_`cc0'
						label var `v'_`cc0' "`v'_`cc0'"
						rename `v'1 `v'_`cc1'
						label var `v'_`cc1' "`v'_`cc1'"
						local rcols_rr "`rcols_rr' `v'_`cc0' `v'_`cc1'"
					}
					else {
						local rcols_rr "`rcols_rr' `v'"
					}
				}
				local lcols "`lcols_rr'"
				local rcols "`rcols_rr'"
			}
			local S_1 = `S_1'
			local S_2 = `S_2'
			local S_3 = `S_3'
			local S_4 = `S_4'
			local S_5 = `S_5'
			local S_6 = `S_6'
			local S_7 = `S_7'
			local S_8 = `S_8'
			local S_9 = `S_9'
			local S_10 = `S_10'
			local S_11 = `S_11'
			local S_12 = `tau_b2'
			local S_13 = `tau_t2'
			local S_14 = `S_14'
		}
		if `Nstudies' == 1   {
			sum `es' if `use'==1
			local S_1 `r(sum)'
			
			local S_2 = .
			
			sum `ill' if `use'==1
			local S_3 `r(sum)'
			
			sum `iul' if `use'==1
			local S_4 `r(sum)'
			
			local S_5 = .
			local S_6 = .
			local S_7 = .
			local S_8 = 0
			local S_9 = .
			local S_10 = .
			local S_11 = .
			local S_12 = .
			local S_13 = .
			local S_14 = .
		}
	}  /* End of quietly loop  */
	
	tempname  ma_first_raw	ma_first_logodds 	ma_first_absout	 ma_first_rrout	 ma_first_predci ma_first_opredci
	
	mat define `ma_first_raw' = matrix(`raw')
	mat define `ma_first_logodds' = matrix(`logodds')
	mat define  `ma_first_absout' = matrix(`absout')
	
	cap confirm matrix `rrout'
	if _rc == 0 {
		mat define `ma_first_rrout' = matrix(`rrout')
	}
	if "`rfdist'" != ""{
		mat define `ma_first_predci' = matrix(`predci')
		mat define `ma_first_opredci' = matrix(`opredci')
	}

	#delimit ;
	metapregsummary, 
		ma_first_model(`fittedmodel') ma_first_es(`S_1') ma_first_se_es(`S_2') ma_first_lci(`S_3') ma_first_uci(`S_4') ma_first_z(`S_5') ma_first_p_z(`S_6') ma_first_het(`S_7') ma_first_df(`S_8') ma_first_p_het(`S_9') ma_first_chi2(`S_10') ma_first_pchi2(`S_11') ma_first_tau2(`S_12') ma_first_wtau2(`S_13') ma_first_i2(`S_14')	
		hmean(`hmean')
		
		ma_first_raw(`ma_first_raw') ma_first_logodds(`ma_first_logodds') ma_first_absout(`ma_first_absout') ma_first_rrout(`ma_first_rrout') ma_first_predci(`ma_first_predci') ma_first_opredci(`ma_first_opredci') 
		
		ma_second_model(`ma_second_model') ma_second_es(`ma_second_es')  ma_second_se_es(`ma_second_se_es') ma_second_lci(`ma_second_lci') ma_second_uci(`ma_second_uci') ma_second_z(`ma_second_z') ma_second_p_z(`ma_second_p_z') ma_second_het(`ma_second_het') ma_second_df(`ma_second_df') ma_second_p_het(`ma_second_p_het') ma_second_chi2(`ma_second_chi2') ma_second_pchi2(`ma_second_pchi2') ma_second_tau2(`ma_second_tau2') ma_second_wtau2(`ma_second_wtau2') ma_second_i2(`ma_second_i2')
		
		
		ma_second_raw(`ma_second_raw') ma_second_logodds(`ma_second_logodds') ma_second_absout(`ma_second_absout') ma_second_rrout(`ma_second_rrout') ma_second_predci(`ma_second_predci') ma_second_opredci(`ma_second_opredci')
		;
		
	#delimit ;
	_disptab `es' `ill' `iul' `use' `label',  by(`by') `paired' dp(`dp') ilevel(`ilevel') lcols(`lcols')
		model(`model') model2(`ma_second_model') olevel(`olevel') outplot(`outplot') plotstat(`plotstat') power(`power') rcols(`rcols') regressors(`regressors') `rfdist' rflevel(`rflevel') `rjhsecond' studyid(`studyid') `options' ;
	#delimit cr

	cap confirm matrix `raw'
	if _rc == 0 {
		return matrix raw = `raw'
	}
	cap confirm matrix `logodds'
	if _rc == 0 {
		return matrix logodds = `logodds'
	}
	cap confirm matrix `absout'
	if _rc == 0 {
		return matrix absout = `absout'
	}
		
	cap confirm matrix `rrout'
	if _rc == 0 {
		return matrix rrout = `rrout'
	}
	cap confirm matrix `predci'
	if _rc == 0 {
		return matrix predci = `predci'
	}
	cap confirm matrix `opredci'
	if _rc == 0 {
		return matrix opredci = `opredci'
	}	
	
	return local ES 	= `S_1'
	return local seES 	= `S_2'
	return local ci_low = `S_3'
	return local ci_upp = `S_4'
	return local z 		= `S_5'
	return local p_z 	= `S_6'
	return local het 	= `S_7'
	return local df 	= `S_8'
	return local p_het 	= `S_9'
	return local chi2 	= `S_10'
	return local p_chi2 = `S_11'
	return local tau2 	= `S_12'
	return local wtau2 	= `S_13'
	return local i_sq 	= `S_14'		
	return local model 	=  "`model'"
	return local hmean 	= `hmean'
	
	if "`rjhsecond'" == "" { 
		restore, not
	} 
	else {
		restore
	}
	end

	*############################################################################
	*############################################################################
	capture program drop iv_init
	program define iv_init, rclass

	version 14.1

	#delimit ;

	syntax varlist(min=2 default=none) [if] [in] [, 
		CC(string)
		CImethod(string) 
		FTT 
		ILevel(integer 95) 
		LABEL(varname) 
		model(string)
		OLevel(integer 95) 
		WGT(passthru) 
		ma_second_model(string) 
		ma_second_es(string)
		ma_second_se_es(string)
		ma_second_lci(string)
		ma_second_uci(string)
		ma_second_z(string)
		ma_second_p_z(string)
		ma_second_het(string)
		ma_second_df(string)
		ma_second_p_het(string)
		ma_second_chi2(string)
		ma_second_pchi2(string)
		ma_second_tau2(string)
		ma_second_wtau2(string)
		ma_second_i2(string)
		*] ;

	#delimit cr

	qui {

		tempvar n N incr es est se use v ill iul weight id rawdata
		tokenize "`varlist'", parse(" ")
		gen double `n' = `1'
		gen double  `N' = `2'

		gen double `incr' = . 
		if "`cc'"  != "" {
			replace `incr' = `cc' if  (`n' == 0 | `n'==`N')
			}

		if "`ftt'" != "" { /**************************Begin the freeman tukey arcsine transformation*/

			gen double `es' = asin(sqrt(`n'/(`N' + 1))) + asin(sqrt((`n' + 1)/(`N' + 1 )))
			gen double `se' = sqrt(1/(`N' + .5)) if (`n' != . & `N' > 0)

		} /***********************End of the freeman tukey arcsine transformation*/
		else {
			gen double  `es'=`n'/`N'
			gen double `se' = sqrt((`es'*(1 - `es'))/`N')
			replace `se' = sqrt((`n' + `incr') * (`N' - `n' + `incr')/(`N' + 2 * `incr')^3) if  (`n' != . & `N' > 0 & `incr' !=.)
		}

		gen double `use'=1 `if' `in'
		replace `use'=9 if `use'==.
		replace `use'=9 if (`es'==. | `se'==.)
		replace `use'=2 if (`use'==1 & `se' <= 0 )
		count if `use'==1
		local Nstudies = r(N)
		if `Nstudies'  == 0 {
			exit
		}
		ameans `N' if `use'==1 
		local hmean = r(mean_h)

		if "`model'"=="random" & (`Nstudies' < 4) { /*Random-effects for more than 3 studies*/
			local model "fixed"
		}

			
		replace `es' =. if `use'!=1
		replace `se' =. if `use'!=1
		gen double `v'=(`se')^2
		
		tempvar ll ul proportion
		
		metapreg_propci `N' `n' if `use'==1, p(`proportion') lowerci(`ill') upperci(`iul') cimethod(`cimethod') level(`ilevel')

		drop `proportion'
			
		if `Nstudies'  > 1 {
			iv  `es' `v' if `use'==1 , model(`model') `ftt'  wgt(`wgt') olevel(`olevel')
			local S_1 = r(ES)
			local S_2 = r(seES)
			local S_3 = r(ci_low)
			local S_4 = r(ci_upp)
			local S_5 = r(z)
			local S_6 = r(p_z)
			local S_7 = r(het)
			local S_8 = r(df)
			local S_9 = r(p_het)
			local S_10 = r(chi2)
			local S_11 = r(p_chi2)
			local S_12 = r(tau2)
			local S_13 = r(wtau2) 
			local S_14 = r(i_sq) 

			if "`wgt'" == "" {
				gen `weight'=100/((`v' + `S_12')*(1/((`S_2')^2)))
			} 
			else {
				gen `weight'=100*`wgt'/(1/((`S_2')^2))) 
			}
							
			/*********************Ensure that the parameters passed are free of transformation*/

			if "`ftt'" == "" {
				drop `es' `se'
				gen double  `es'=`n'/`N'
				gen double `se' = sqrt((`es'*(1 - `es'))/`N')
				replace `se' = sqrt((`n' + `incr') * (`N' - `n' + `incr')/(`N' + 2 * `incr')^3) if  (`n' != . & `N' > 0 & `incr' !=.)
				}
			else {
				replace `es' = 0.5 * (1 - sign(cos(`es')) * sqrt(1 - (sin(`es') + (sin(`es') - 1/sin(`es'))/(`N'))^2))
			}
		}
		if `Nstudies'  == 1 {		
			cap drop `est'
			gen `est' =`n'/`N'
			sum `est' if `use'==1
			local S_1  `r(sum)'
			local S_2 = .
			sum `ill' if `use'==1
			local S_3 `r(sum)'
			sum `iul' if `use'==1
			local S_4 `r(sum)'
			local S_5 = .
			local S_6 = .
			local S_7 = .
			local S_8 = 0
			local S_9 = .
			local S_10 = .
			local S_11 = .
			local S_12 = .
			local S_13 = .
			local S_14 = .
		}
	}  /* End of quietly loop  */
		#delimit ;
	metapregsummary, 
		ma_first_model(`model') ma_first_es(`S_1') ma_first_se_es(`S_2') ma_first_lci(`S_3') ma_first_uci(`S_4') ma_first_z(`S_5') ma_first_p_z(`S_6') ma_first_het(`S_7') ma_first_df(`S_8') ma_first_p_het(`S_9') ma_first_chi2(`S_10') ma_first_pchi2(`S_11') ma_first_tau2(`S_12') ma_first_wtau2(`S_13') ma_first_i2(`S_14')	
		hmean(`hmean')
		ma_second_model(`ma_second_model') ma_second_es(`ma_second_es')  ma_second_se_es(`ma_second_se_es') ma_second_lci(`ma_second_lci') ma_second_uci(`ma_second_uci') ma_second_z(`ma_second_z') ma_second_p_z(`ma_second_p_z') ma_second_het(`ma_second_het') ma_second_df(`ma_second_df') ma_second_p_het(`ma_second_p_het') ma_second_chi2(`ma_second_chi2') ma_second_pchi2(`ma_second_pchi2') ma_second_tau2(`ma_second_tau2') ma_second_wtau2(`ma_second_wtau2') ma_second_i2(`ma_second_i2');
		
	_disptab `es' `se' `ill' `iul' `weight' `use' `label',  
		`ftt' ilevel(`ilevel') model(`model') olevel(`olevel') `wgt'  `options';
	#delimit cr
	
	return local ES 	= `S_1'
	return local seES 	= `S_2'
	return local ci_low = `S_3'
	return local ci_upp = `S_4'
	return local z 		= `S_5'
	return local p_z 	= `S_6'
	return local het 	= `S_7'
	return local df 	= `S_8'
	return local p_het 	= `S_9'
	return local chi2 	= `S_10'
	return local p_chi2 = `S_11'
	return local tau2 	= `S_12'
	return local wtau2 	= `S_13'
	return local i_sq 	= `S_14'		
	return local model 	=  "`model'"
	return local hmean 	= `hmean'
	
	end
	*##########################################################################################################################################################
	*##########################################################################################################################################################
	capture program drop iv
	program define iv, rclass

	version 14.1

	#delimit ;

	syntax varlist(min=2 max=2 default=none numeric) [if] [in] [, 
		model(string) 
		WGT(string) 
		FTT 
		OLevel(integer 95) 
		*] ;

		#delimit cr

		tempvar stat v w qhet w2 wnew e_w e_wnew
		tempname W W2 C T2 E_W E_WNEW OV OVL OVU vOV QHET mintes maxtes

		tokenize "`varlist'", parse(" ")
		gen `stat'=`1'
		gen `v'   =`2'
		
		local ZOVE = -invnorm((100-`olevel')/200)
		count 
		local S_8 = r(N)  - 1
		if "`wgt'" == ""{
			gen `w' = 1/`v'
		} 
		else {
			gen `w' = `wgt' if `stat' !=.
			sum `w',meanonly
			scalar `W'=r(sum)
			if `W'==0 {
				di as err "Usable weights sum to zero: the table below will probably be nonsense"
			}
		}

		sum `w', meanonly /*Summarize but suppress the outplot*/
		scalar `W'=r(sum) /*This is a temporal scalar*/

		if ("`model'"!="random") { 	
			gen `e_w' =`stat'*`w'
			sum `e_w',meanonly
			scalar `E_W'=r(sum)
			local MA_W =`W'
			local  S_1 =`E_W'/`W'
			local S_12=0
			local S_7 = .
			local S_9 = .
			local S_14 = .
		}
		else { 
			gen `e_w' =`stat'*`w'
			sum `e_w',meanonly
			scalar `E_W'=r(sum)
			local S_1 =`E_W'/`W'

			*  Heterogeneity
			gen `qhet' =((`stat'- `S_1')^2)/`v'
			sum `qhet', meanonly
			scalar `QHET'=r(sum)
			local S_7=`QHET'

			gen `w2'  =`w'*`w'
			sum `w2',meanonly
			scalar `W2' =r(sum)
			scalar `C'  =`W' - `W2'/`W'
			local S_12 =max(0, ((`QHET'- `S_8')/`C') )
			*local RJH_TAU2 = `S_12'
			gen `wnew'  =1/(`v' + `S_12')
			gen `e_wnew'=`stat'*`wnew'
			sum `wnew',meanonly
			local MA_W =r(sum)
			sum `e_wnew',meanonly
			scalar `E_WNEW'=r(sum)
			local S_1 =`E_WNEW'/`MA_W'
		}

		local S_2 = sqrt(1/`MA_W')

		local S_3 = `S_1' - `ZOVE'*(`S_2')
		local S_4 = `S_1' + `ZOVE'*(`S_2')

		if "`ftt'" != "" {
			scalar  `mintes' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
			if `S_1' > `mintes' {
				local S_5 = abs((`S_1' - `mintes')/(`S_2'))
			} 
			else{
				local S_5 = 0
			}
		}
		else{
			local S_5 =abs((`S_1')/(`S_2'))
		}

		local S_6 =normprob(-abs(`S_5'))*2
		local S_9 = chiprob(`S_8', `S_7')
		local S_10 = .		
		local S_11 = .
		local S_13 = 0
		local S_14 = max(0, ( 100*(`S_7'-`S_8'))/(`S_7'))
	
		return local ES=`S_1'
		return local seES=`S_2'
		return local ci_low=`S_3'
		return local ci_upp=`S_4'
		return local z=`S_5'
		return local p_z=`S_6'
		return local het=`S_7'
		return local df=`S_8'
		return local p_het=`S_9'
		return local chi2=`S_10'
		return local p_chi2=`S_11'
		return local tau2=`S_12'
		return local wtau2=`S_13'
		return local i_sq=`S_14'		
	end
	/*===============================================================================================*/
	/*==================================== _DISPTAB  ================================================*/
	/*===============================================================================================*/
	capture program drop _disptab
	program define _disptab

	version 14.1

	#delimit ;

	syntax varlist(min=5) [if] [in] [, 
		BY(string) 
		paired 
		download(string)
		DP(integer 2) 
		FTT 
		ILevel(integer 95)  
		model(string)
		model2(string) 
		noGRAPH 
		noLOGIT		
		noOVERALL  
		noTABLE  
		noWT 
		OLevel(integer 95) 
		outplot(string) 
		plotstat(string asis)
		power(integer 0)
		regressors(string)
		RFdist 
		RFLevel(integer 95) 
		RJHSECOND
		SORTBY(varlist) 
		STUDYID(varname)
	*] ;

	#delimit cr

	tempvar effect se lci uci weight wtdisp use label tlabel rawdata id tau2 wtau2  df  
	tempname OVL OVU mintes maxtes
	
	tokenize "`varlist'", parse(" ")

	if "`logit'" == "" {
		local wt "nowt"
	}

	qui {
	//Obtain the summarries
		local S_1 = r(ES)			
		local S_2 = r(seES)
		local S_3 = r(ci_low)
		local S_4 = r(ci_upp)
		local S_5 = r(z)
		local S_6 = r(p_z)
		local S_7 = r(het)
		local S_8 = r(df)
		local S_9 = r(p_het)
		local S_10 = r(chi2)
		local S_11 = r(p_chi2)
		local S_12 = r(tau2)
		local S_13 = r(wtau2)
		local S_14 = r(i_sq)
		local hmean = r(hmean)
		local model = r(model)
		
		if "`model2'" != "" {
			local MA_second_ES = r(ES_2)			
			local MA_second_SE_ES = r(seES_2)
			local MA_second_LCI = r(ci_low_2)
			local MA_second_UCI = r(ci_upp_2)
			local MA_second_Z = r(z_2)
			local MA_second_P_Z = r(p_z_2)
			local MA_second_HET = r(het_2)
			local MA_second_DF = r(df_2)
			local MA_second_P_HET = r(p_het_2)
			local MA_second_CHI2 = r(chi2_2)
			local MA_second_PCHI2 = r(p_chi2_2)
			local MA_second_TAU2 = r(tau2_2)
			local MA_second_WTAU2 = r(wtau2_2)
			local MA_second_I2 = r(i_sq_2)
			local MA_second_model = r(model_2)
		}
		if "`rfdist'" != "" {
		tempname opredci second_opredci
			mat `opredci' = r(opredci)
			mat `second_opredci' = r(opredci_2)
		}
		
		local p: word count `regressors'
		
		gen str10 `label' = ""

		if "`logit'" != "" {
			gen `effect'=`1'
			gen `se'    =`2'
			gen `lci'   =`3'
			gen `uci'   =`4'
			gen `weight'=`5'
			format `weight' %5.1f
			
			gen byte `use'=`6'
			replace `label'=`7'
			
			}
		else {
			gen `effect'=`1'
			gen `lci'   =`2'
			gen `uci'   =`3'
			gen byte `use'=`4'
			replace `label'=`5'
			
			gen `weight'= .
		}
		local ilevel:  displ %2.0f `ilevel'

		gen `tau2' = .
		gen `wtau2' = .
		gen `df' = .
		
		cap drop _ES
		gen _ES  = `effect'
		label var _ES "`plotstat'"
		
		cap drop _seES
		cap drop _WT	

		if "`logit'" != "" {
			gen _seES=`se'
			label var _seES "se(`plotstat')"

			gen _WT=`weight'
			label var _WT "`model' weight"
		}
			
		cap drop _LCI
		gen _LCI =`lci'
		label var _LCI "Lower CI (`plotstat')"
		
		cap drop _UCI
		gen _UCI =`uci'
		label var _UCI "Upper CI (`plotstat')"
		 
		preserve
		count if `use'==1
		local usetot = r(N)
			
		if "`by'" == "" {
			gen str20 `tlabel'= `label' 
			sort `use' `sortby' 
			
			if "`overall'"=="" & "`rjhsecond'" == "" {		// only do this on main run
				**Put a blank line first
				local nobs1 = _N+1
				set obs `nobs1'
				replace `use' = 8 in `nobs1'				
			
				**If overall figure requested, add an extra line to contain overall stats
				local nobs1 = _N+1
				set obs `nobs1'
				replace `weight' = 100 in `nobs1'
									//predictions
				if "`rfdist'" != "" {
					local nobs11 = _N+1
					set obs `nobs11'
					replace `use' = 6 in `nobs11'
				}

				/*===============================================================================================*/
				/*=======================  Start the Freeman Tukey Back tranformation ===========================*/
				/*===============================================================================================*/
				if "`ftt'"  != ""  { 
					tempname mintes maxtes
					scalar `mintes' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
					scalar `maxtes' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
					
					if `S_1' < `mintes' {
						qui replace `effect' = 0 in `nobs1'
					}
					else if `S_1' > `maxtes' {
						qui replace `effect' = 1 in `nobs1'
					}
					else {
						qui replace `effect' = 0.5 * (1 - sign(cos(`S_1')) * sqrt(1 - (sin(`S_1') + (sin(`S_1') - 1/sin(`S_1'))/(`hmean'))^2)) in `nobs1' 
					}
					
					if `S_3' < `mintes' {
						qui replace `lci' = 0 in `nobs1'
					}
					else if `S_3' > `maxtes' {
						qui replace `lci' = 1 in `nobs1'
					}
					else {
						qui replace `lci' = 0.5 * (1 - sign(cos(`S_3')) * sqrt(1 - (sin(`S_3') + (sin(`S_3') - 1/sin(`S_3'))/(`hmean'))^2)) in `nobs1' 
					}
					
					if `S_4' < `mintes' {
						qui replace `uci' = 0 in `nobs1'
					}
					else if `S_4' > `maxtes' {
						qui replace `uci' = 1 in `nobs1'
					}
					else {
						qui replace `uci' = 0.5 * (1 - sign(cos(`S_4')) * sqrt(1 - (sin(`S_4') + (sin(`S_4') - 1/sin(`S_4'))/(`hmean'))^2)) in `nobs1' 
					}
					if "`rfdist'" != "" {
						tempname mintes maxtes fttlci fttuci
						scalar `mintes' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
						scalar `maxtes' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
						
						scalar `fttlci' = `S_1' - invttail((`S_8'), 0.5-`rflevel'/200)*sqrt(`S_12' + `S_2'^2) in `nobs11'
						scalar `fttuci' = `S_1' + invttail((`S_8'), 0.5-`rflevel'/200)*sqrt(`S_12' + `S_2'^2) in `nobs11'
					
						replace `lci' = 0 if `fttlci' < `mintes' in `nobs11'
						replace `lci' = 1 if `fttlci' > `maxtes' in `nobs11'
						replace `lci' = 0.5 * (1 - sign(cos(`fttlci')) * sqrt(1 - (sin(`fttlci') + (sin(`fttlci') - 1/sin(`fttlci'))/(`hmean'))^2)) if (`fttlci' <= `maxtes') & (`fttlci' >= `mintes') in `nobs11'
						
						replace `uci' = 0 if `fttuci' < `mintes' in `nobs11'
						replace `uci' = 1 if `fttuci' > `maxtes' in `nobs11'
						replace `uci' = 0.5 * (1 - sign(cos(`fttuci')) * sqrt(1 - (sin(`fttuci') + (sin(`fttuci') - 1/sin(`fttuci'))/(`hmean'))^2)) if (`fttuci' <= `maxtes') & (`fttuci' >= `mintes') in `nobs11'
					}					
				/*===============================================================================================*/
				/*======================= Finish the Freeman Tukey Back tranformation ===========================*/
				/*===============================================================================================*/
				}  
				else {
					replace `effect'= (`S_1') in `nobs1'
					if `S_8' > 0 {
						replace `lci'=(`S_3') in `nobs1'
						replace `uci'=(`S_4') in `nobs1'
					}
				}
				
				replace `use' = 5 in `nobs1'
				replace `tau2' = `S_12' in `nobs1'
				replace `wtau2' = `S_13' in `nobs1'
				replace `df' = `S_8' in `nobs1'
				
				if (`S_8' > 0) & (`S_8' != .) {
					if "`logit'" != "" {
						if "`model'" == "random" {
							replace `label' = "Overall  (I^2 = " + string(`S_14', "%10.`=`dp''f")+ "%, p = " + ///
							string(`S_9', "%10.`=`dp''f") + ")" in `nobs1'
						}
						else {
							replace `label' = "Overall " in `nobs1'
						}
					} 
					else if ("`logit'" == "") {
						if ("`model'" == "random" & "`paired'" == "") |("`model'" != "marginal" & "`paired'" != "") {
							if `p' == 0 {
								replace `label' = "Overall  (I^2 = " + string(`S_14', "%10.`=`dp''f")+ "%, p = " + ///
								string(`S_11', "%10.`=`dp''f") + ")" in `nobs1'
							}
							else {
								replace `label' = "Overall (LR Test: RE vs. FE p = " + ///
								string(`S_11', "%10.`=`dp''f") + ")" in `nobs1'
							}
						}
						else {
							replace `label' = "Overall " in `nobs1'
						}
					}
				}
				* RJH code for second model
				if "`model2'" != "" {
					local nobs1 = _N+1
					set obs `nobs1'
					replace `weight'=100 in `nobs1'	
					//predictions
					if "`rfdist'" != "" {
						local nobs11 = _N + 1
						set obs `nobs11'
						replace `use' = 18 in `nobs11'
					}
					
					/*===============================================================================================*/
					/*=======================  Start the Freeman Tukey Back tranformation ===========================*/
					/*===============================================================================================*/
					if "`ftt'"  != ""  { 
							tempname mintes maxtes
							scalar `mintes' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean'+ 1 )))
							scalar `maxtes' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
							
							if `MA_second_ES' < `mintes' {
								qui replace `effect' = 0 in `nobs1'
							}
							else if `MA_second_ES' > `maxtes' {
								qui replace `effect' = 1 in `nobs1'
							}
							else {
								qui replace `effect' = 0.5 * (1 - sign(cos(`MA_second_ES')) * sqrt(1 - (sin(`MA_second_ES') + (sin(`MA_second_ES') - 1/sin(`MA_second_ES'))/(`hmean'))^2)) in `nobs1' 
							}
							
							if `MA_second_LCI' < `mintes' {
								qui replace `lci' = 0 in `nobs1'
							}
							else if `MA_second_LCI' > `maxtes' {
								qui replace `lci' = 1 in `nobs1'
							}
							else {
								qui replace `lci' = 0.5 * (1 - sign(cos(`MA_second_LCI')) * sqrt(1 - (sin(`MA_second_LCI') + (sin(`MA_second_LCI') - 1/sin(`MA_second_LCI'))/(`hmean'))^2)) in `nobs1' 
							}
							
							if `MA_second_UCI' < `mintes' {
								qui replace `uci' = 0 in `nobs1'
							}
							else if `MA_second_UCI' > `maxtes' {
								qui replace `uci' = 1 in `nobs1'
							}
							else {
								qui replace `uci' = 0.5 * (1 - sign(cos(`MA_second_UCI')) * sqrt(1 - (sin(`MA_second_UCI') + (sin(`MA_second_UCI') - 1/sin(`MA_second_UCI'))/(`hmean'))^2)) in `nobs1' 
							}
							if "`rfdist'" != "" {
								tempname mintes maxtes fttlci fttuci
								scalar `mintes' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
								scalar `maxtes' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
								
								scalar `fttlci' = `MA_second_ES' - invttail((`MA_second_DF'), 0.5-`rflevel'/200)*sqrt(`MA_second_TAU2' + `MA_second_SE_ES'^2) in `nobs11'
								scalar `fttuci' = `MA_second_ES' + invttail((`MA_second_DF'), 0.5-`rflevel'/200)*sqrt(`MA_second_TAU2' + `MA_second_SE_ES'^2) in `nobs11'
							
								replace `lci' = 0 if `fttlci' < `mintes' in `nobs11'
								replace `lci' = 1 if `fttlci' > `maxtes' in `nobs11'
								replace `lci' = 0.5 * (1 - sign(cos(`fttlci')) * sqrt(1 - (sin(`fttlci') + (sin(`fttlci') - 1/sin(`fttlci'))/(`hmean'))^2)) if (`fttlci' <= `maxtes') & (`fttlci' >= `mintes') in `nobs11'
								
								replace `uci' = 0 if `fttuci' < `mintes' in `nobs11'
								replace `uci' = 1 if `fttuci' > `maxtes' in `nobs11'
								replace `uci' = 0.5 * (1 - sign(cos(`fttuci')) * sqrt(1 - (sin(`fttuci') + (sin(`fttuci') - 1/sin(`fttuci'))/(`hmean'))^2)) if (`fttuci' <= `maxtes') & (`fttuci' >= `mintes') in `nobs11'
							}							
			/*===============================================================================================*/
			/*======================= Finish the Freeman Tukey Back tranformation ===========================*/
			/*===============================================================================================*/
						}  
					else {
						replace `effect'= `MA_second_ES' in `nobs1'
						replace `lci'=`MA_second_LCI' in `nobs1'
						replace `uci'=`MA_second_UCI' in `nobs1'
					}
					replace `use'=17 in `nobs1'
					replace `tau2' = `MA_second_TAU2' in `nobs1'
					replace `wtau2' = `MA_second_WTAU2'  in `nobs1'
					replace `df' = `MA_second_DF' in `nobs1'
					
					if (`MA_second_DF' > 0) & (`MA_second_DF' != .) {
						if "`logit'" != "" {
							if "`model2'" == "random" {
								replace `label' = "Overall  (I^2 = " + string(`MA_second_I2', "%10.`=`dp''f")+ "%, p = " + ///
								string(`MA_second_P_HET', "%10.`=`dp''f") + ")" in `nobs1'
							}
							else {
								replace `label' = "Overall " in `nobs1'
							}
						} 
						else if ("`logit'" == "") {
							if ("`model2'" == "random" & "`paired'" == "") |("`model2'" != "marginal" & "`paired'" != "") {
								if `p' == 0 {
									replace `label' = "Overall  (I^2 = " + string(`MA_second_I2', "%10.`=`dp''f")+ "%, p = " + ///
									string(`MA_second_PCHI2', "%10.`=`dp''f") + ")" in `nobs1'
								}
								else {
									replace `label' = "Overall (LR Test: RE vs. FE p = " + ///
									string(`MA_second_PCHI2', "%10.`=`dp''f") + ")" in `nobs1'
								}
							}
							else {
								replace `label' = "Overall " in `nobs1'
							}
						}
					}

				}
			} /* end overall stuff */
					//PREDICTIONS
		if "`rfdist'" != "" {
			if "`logit'" != "" & "`ftt'" == ""  {
				replace `df' = `df'-1 if `use' == 6 | `use' == 18
				replace `lci' = `effect' - invttail((`df'), 0.5-`rflevel'/200)*sqrt(`tau2'+`se'^2) if `use' == 6 | `use' == 18 
				replace `uci' = `effect' + invttail((`df'), 0.5-`rflevel'/200)*sqrt(`tau2'+`se'^2) if `use' == 6 | `use' == 18 
				
				replace `lci' = 0 if `lci' < 0  & (`use' == 6 | `use' == 18 )
				replace `uci' = 1 if `lci'  > 1  & (`use' == 6 | `use' == 18 )
			}
			if "`logit'" == "" {
				if "`outplot'" == "abs" {
					replace `lci' = `opredci'[1,1] if `use' == 6
					replace `uci' = `opredci'[1,2] if `use' == 6
				}
				else {
					replace `lci' = `opredci'[2,1] if `use' == 6
					replace `uci' = `opredci'[2,2] if `use' == 6
				}
				
				if "`model2'" != "" {
					if "`outplot'" == "abs" {
						replace `lci' = `second_opredci'[1,1] if `use' == 18
						replace `uci' = `second_opredci'[1,2] if `use' == 18
					}
					else {
						replace `lci' = `second_opredci'[2,1] if `use' == 18
						replace `uci' = `second_opredci'[2,2] if `use' == 18
					}
				}				
			}
		}
		count if `use' == 2
		local alltot=r(N) + `usetot'
		gen `id'=_n

		*tempvar rjhorder
		*qui gen `rjhorder' = `use'
		*qui replace `rjhorder' = 3.5 if `use' == 19	// SWAP ROUND SO BLANK IN RIGHT PLACE
		*sort `rjhorder' `sortby'  `id'
		} /* End of table(1) loop */	
	}/* End of quietly loop */
	
	if "`table'" == "" {
		di as res _n"****************************************************************************************"
        di as res "{pmore2} Study specific and overall measures : `plotstat'{p_end}"
		di as res "****************************************************************************************"
		if "`paired'" != "" {
			local mfmt = "(paired)"
		}
		tempvar tlabellen 
		qui gen `tlabellen' = strlen(`tlabel')
		qui summ `tlabellen'
		local maxlabellen = r(max) + 1
		
		local nlen  = strlen(" `model'`mfmt'  `plotstat'") + 3
		local nlen = max(`nlen', `maxlabellen')
		local nlen2  = strlen("`plotstat'") + 1
		
		if "`overall'`wt'"=="" {
			local ww "% Weight"
		}

		if `ilevel' != `olevel' {
			locall OVE: displ %2.0f `olevel'
			local insert "[`OVE'% Conf. Interval]"
		}
		else {
			local insert "--------------------"
		}
		local studylb: variable label `studyid'
		if "`studylb'" == "" {
			local studylb "`studyid'"
		}
		di _n as txt _col(7) "`studylb'" _col(`nlen') "|"  " " _skip(5) "`plotstat'" /*
		*/  _col(`=`nlen' + `nlen2' + 15') "[`ilevel'% Conf. Interval]"  _col(`=`nlen' + `nlen2' + 40') "`ww'" _n _dup(`=`nlen'-1') "-" "+" _dup(51) "-"


		local i=1
		while `i'<=_N {	// BEGIN WHILE LOOP

			if "`overall'`wt'"=="" {
				local ww=`weight'[`i']
			}
			else {
				local ww
			}
			if (`use'[`i'])==2 {
				*excluded trial
				di as txt `tlabel'[`i'] _col(`nlen') "|  (Excluded)"
			}
			* IF NORMAL TRIAL, OR OVERALL EFFECT
			if ( (`use'[`i']==1) | (`use'[`i']==5) | `use'[`i'] == 17 ) {
				if (`use'[`i'])==1 {
					*trial results
					di as txt `tlabel'[`i']  _cont
				}
				else {
				if (`df'[`i']!=0 & `df'[`i']!=.) {
						*overall
						// RJH
						if `use'[`i'] == 5 {
							local dispM1 = strproper("`model'")

							*di as txt _dup(`=`nlen'-1') "-" "+" _dup(11) "-"  "`insert'" _dup(20) "-" _n ///
							*  "[`dispM1'`mfmt']  `plotstat'" _cont
							di as txt _dup(`=`nlen'-1') "-" "+" _dup(11) "-"  "`insert'" _dup(20) "-" 
							di as res  "Overall" as txt _col(`nlen') "| "  
							di as txt " [" strproper("`model'") "`mfmt'" "] `plotstat'"  _cont
						}
						if `use'[`i'] == 17 {	// SECOND EST
							local dispM2 = "`model2'"
							di as txt /*"Overall  `plotstat'" */ " [" strproper("`model2'") "`mfmt'" "]" ""  _cont
						}
					}
				}
				if (`use'[`i'])==1 {
					di as txt _col(`nlen') "| " as res  %10.`=`dp''f `effect'[`i']*(10^`power') /*
					*/ _col(`=`nlen' + `nlen2' + 12') %10.`=`dp''f `lci'[`i']*(10^`power') "   " %10.`=`dp''f `uci'[`i']*(10^`power') _col(`=`nlen' + `nlen2' + 37')  %6.2f `ww'
				}
				else{
					if  (`df'[`i']!=0 & `df'[`i']!=.){
						di as txt _col(`nlen') "| " as res  %10.`=`dp''f `effect'[`i']*(10^`power') /*
						*/ _col(`=`nlen' + `nlen2' + 12') %10.`=`dp''f  `lci'[`i']*(10^`power') "   " %10.`=`dp''f  /*
						*/ `uci'[`i']*(10^`power') _col(`=`nlen' + `nlen2' + 37')  %6.2f `ww' 
					}
				}
			}
			local i=`i'+1
		} 

		di as txt _dup(`=`nlen'-1') "-" "+" _dup(51) "-"

		if "`overall'"=="" {
			*Heterogeneity etc
			if "`outplot'" == "rr" {
				local h0=1
			}
			else {
			 if "`logit'" != "" {
				local h0=0
				}
				else {
					local h0="0.5"
				}
			}
			if "`model2'" == "" {
				local whichmodel 
			}
			else {
				local whichmodel = " [" + strproper("`model'") + "`mfmt']"
			}
			if "`logit'" != "" {
				if "`model'"=="random" {
					di as res _n "`whichmodel'"
					di  as txt "  Heterogeneity chi^2 = " as res %10.`=`dp''f `S_7' as txt /*
					*/  " (d.f. = " as res `S_8' as txt  ") p = "   as res %10.`=`dp''f `S_9'
					di as txt "  I^2 (variation in `plotstat' attributable to between-study " /*
					*/  "heterogeneity) =" as res %10.`=`dp''f `S_14' "%"
				}
			}

			if "`logit'" == "" & "`paired'" == "" & "`model'"=="random" {
				di as res _n "`whichmodel'"
				di  as txt "  LR test: RE vs FE Model chi^2 = " as res %10.`=`dp''f `S_10' as txt /*
				*/  " (d.f. =  " as res 1 as txt  ") p = "   as res %10.`=`dp''f `S_11'
				
				di as txt "  I^2 (variation in logodds attributable to " /*
				*/  "heterogeneity) =" as res %10.`=`dp''f `S_14' "%"
			}
			if "`logit'" == "" & ("`paired'" != "" & "`model'" != "marginal" ) {
				di as res _n "`whichmodel'"
				di  as txt "  LR test: RE vs FE Model chi^2 = " as res %10.`=`dp''f `S_10' as txt /*
				*/  " (d.f. =  " as res 1 as txt  ") p = "   as res %10.`=`dp''f `S_11'
			}

			if ("`model'"=="random" & "`paired'" == "") | ("`model'" != "marginal" & "`paired'" != ""){
				di as txt "  Estimate of between-study variance " /*
				*/ "Tau^2 = " as res %10.`=`dp''f `S_12'
				if ("`model'" == "random" & "`paired'" != "") {
					di as txt "  Estimate of within-study variance " /*
					*/ "W.Tau^2 = " as res %10.`=`dp''f `S_13'
				}
			}

			di _n as txt "  Test of `plotstat'=`h0': z= " as res %10.`=`dp''f `S_5'  /*
			*/  as txt  " p = "  as res %10.`=`dp''f `S_6'
			
			if "`model2'" != "" {
			di as res _n " [" strproper("`model2'") "`mfmt'" "]"
				if "`logit'" != "" {
					if "`model2'"=="random" {						
						di _n as txt "  Heterogeneity chi^2 = " as res %10.`=`dp''f `MA_second_HET' as txt /*
						*/  " (d.f. = " as res `MA_second_DF' as txt  ") p = "   as res %10.`=`dp''f `MA_second_P_HET'
						di as txt "  I^2 (variation in `plotstat' attributable to between-study " /*
						*/  "heterogeneity) =" as res %10.`=`dp''f `MA_second_I2' "%"
					}
				}

				if "`logit'" == "" & "`paired'" == "" & "`MA_second_model'"=="random" {
					di _n as txt "  LR test: RE vs FE Model chi^2 = " as res %10.`=`dp''f `MA_second_CHI2' as txt /*
					*/  " (d.f. =  " as res 1 as txt  ") p = "   as res %10.`=`dp''f `MA_second_PCHI2'
					
					di as res "  I^2 (variation in logodds attributable to " /*
					*/  "heterogeneity) =" as res %10.`=`dp''f `MA_second_I2' "%"
				}
				if "`logit'" == "" & ("`paired'" != "" & "`model2'" != "marginal" ) {
					di _n as txt "  LR test: RE vs FE Model chi^2 = " as res %10.`=`dp''f `MA_second_CHI2' as txt /*
					*/  " (d.f. =  " as res 1 as txt  ") p = "   as res %10.`=`dp''f `MA_second_PCHI2'
				}

				if ("`model2'"=="random" & "`paired'" == "") | ("`model2'" != "marginal" & "`paired'" != ""){
					di as txt "  Estimate of between-study variance " /*
					*/ "Tau^2 = " as res %10.`=`dp''f `MA_second_TAU2'
					if ("`MA_second_model'" == "random" & "`paired'" != "") {
						di as txt "  Estimate of within-study variance " /*
						*/ "W.Tau^2 = " as res %10.`=`dp''f `MA_second_WTAU2'
					}
				}

				di _n as txt "  Test of `plotstat'=`h0': z= " as res %10.`=`dp''f `MA_second_Z' /*
				*/  as txt  " p = "  as res %10.`=`dp''f `MA_second_P_Z'
			}
		}

		*capture only 1 trial scenario

		qui {
			count
			if r(N)==1 {
				set obs 2
				replace `use'=99 in 2
				replace `weight' = 0 if `use' == 99
			}
		} /*end of qui. */
		

	} // end if table(2)

	if "`graph'"=="" & `usetot' > 0 {
		qui drop if `use' == 9
		
		qui gen `wtdisp' = `weight'
		
		#delimit ;
		_dispgby `effect' `lci' `uci' `weight' `wtdisp' `use' `label' `df' `tau2' `wtau2',
			studyid(`studyid') by(`by') `paired' download(`download') dp(`dp') `ftt' ilevel(`ilevel') 
			 model(`model') model2(`model2') `graph' `logit' `overall' `table' `wt'  olevel(`olevel') outplot(`outplot') plotstat(`plotstat')
			power(`power') `rfdist'  rflevel(`rflevel') `rjhsecond' sortby(`sortby')  `options';
		#delimit cr
		
	}
	if "`download'" != "" & "`by'" == "" {
		qui cap drop _ID
		qui gen _ID = `id'
		qui gen _LABEL = `label'
		if "`logit'" != "" {
			local wt "_WT"
			local se "_seES"
		}
		else{
			local wt
			local se
		}
		keep _ID _LABEL _ES `se'  `wt' _LCI _UCI
		di _n
		save "`download'", replace
	}
	restore
	end
	/*===============================================================================================*/
	/*==================================== _DISPGBY  ================================================*/
	/*===============================================================================================*/
	**********************************************************
	***                                                    ***
	***                        NEW                         ***
	***                 _DISPGBY PROGRAM                   ***
	***                    ROSS HARRIS                     ***
	***                     JULY 2006                      ***
	***                       * * *                        ***
	***                                                    ***
	**********************************************************

	capture program drop _dispgby
	program define _dispgby
	version 14.1	

	//	AXmin AXmax ARE THE OVERALL LEFT AND RIGHT COORDS
	//	DXmin dxMAX ARE THE LEFT AND RIGHT COORDS OF THE GRAPH PART

	#delimit ;
	syntax varlist(min=10 max=14 default=none ) [if] [in] [,
		AStext(integer 50) 
		BOXOpt(string) 
		BOXSca(real 100.0) 
		BY(string)
		by2(varname)		
		CC(string)
		CIOpt(string) 
		CLassic
		paired 
		DIAMopt(string) 
		DOUBLE 
		download(string)
		DP(integer 2) 
		FORCE 
		FTT 
		ILevel(integer 95) 
		LCOLS(varlist) 
		model(string) 
		model2(string) 
		noBOX 
		noGRAPH 
		NOHET
		noLOGIT 		
		noOVERALL  
		noOVLine 
		NOSECSUB
		noSTATS 
		noSUBGROUP 
		noWT 
		OLevel(integer 95) 
		OLineopt(string) 
		outplot(string) 
		outtable(string) 
		plotstat(string asis) 
		POINTopt(string) 
		POwer(integer 0)
		PREDciopt(string)
		RCOLS(varlist)
		regressors(string)		
		RFdist 
		RFLevel(integer 95) 
		SGWEIGHT
		SORTBY(varlist) 
		STUDYID(varname)
		SUBLINE 
		SUMMARYonly
		tablestat(string asis) 
		TEXts(real 100.0) 
		WGT(varname) 
		XLAbel(string) 
		XTICK(string) 
		otheropts(string)
	  ];
	#delimit cr

	tempvar effect lci uci weight wtdisp use label tlabel id yrange xrange Ghsqrwt  i2 mylabel tau2 wtau2 df hmean fttes hetGroupLabel ///
	
	tokenize "`varlist'", parse(" ")

	qui {
		gen `effect'=`1'*(10^`power')
		gen `lci'   =`2'*(10^`power')
		gen `uci'   =`3'*(10^`power')
		gen `weight'=`4'	// was 4
		gen `wtdisp'=`5'
		gen byte `use'=`6'
		gen str `label'=`7'
		gen str `mylabel'=`7'		
		gen `df' = `8'
		gen `tau2' = `9'
		gen `wtau2' = `10'
		
		if "`by'" != "" {
			gen `hetGroupLabel' = `11'
		}

		if "`lcols'" == "" {
			local lcols "`mylabel'"
			local studylb: variable label `studyid'
			if "`studylb'" == "" {
				label var `mylabel' "`studyid'"
			}
			else {
				label var `mylabel' "`studylb'"
			}
		}
		
		if "`logit'" == "" {
			local box "nobox"
			local wt "nowt"
		}

		if "`summaryonly'" != ""{
			drop if `use' == 1
		}

		// SET UP EXTENDED CIs FOR RANDOM EFFECTS DISTRIBUTION
		// THIS CODE IS A BIT NASTY AS I SET THIS UP BARandomY INITIALLY
		// REQUIRES MAJOR REWORK IDEALLY...

		tempvar tauLCI tauUCI SE tauLCIinf tauUCIinf
		replace `tau2' = .b if `df' == 0	// inestimable predictive distribution in one study
		replace `tau2' = . if (`use' == 4 | `use' == 6) & (("`model'" != "random" & "`paired'" == "") | ("`model'" == "marginal" & "`paired'" != ""))
		replace `tau2' = . if (`use' == 18 | `use' == 20) & (("`model2'" != "random" & "`paired'" == "") | ("`model2'" == "marginal" & "`paired'" != ""))

		gen `tauLCI' = .
		gen `tauUCI' = .
		gen `tauLCIinf' = .
		gen `tauUCIinf' = .
		gen `SE' = .

		tempvar estText weightText RFdistText RFdistLabel
		gen str `estText' = string(`effect', "%10.`=`dp''f") + " (" + string(`lci', "%10.`=`dp''f") + ", " + string(`uci', "%10.`=`dp''f") + ")"  if `use' != 8 
		replace `estText' = "(Excluded)" if `use' == 2

		replace `estText' = " " if (`use' == 3 | `use' == 5) & `df' == 0 /* Dont display if one study*/

		// don't show effect size again, just CI
		gen `RFdistLabel' = "with estimated predictive interval" if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20) & (`lci' != . & `uci' != .)
		gen `RFdistText' =  "     . (" + string(`lci', "%10.`=`dp''f") + ", " + string(`uci', "%10.`=`dp''f") ///
			+ ")" if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20) & (`lci' != . & `uci' != .)

		/*replace `RFdistLabel' = "No observed heterogeneity" if `use' == 4 & `tau2' == .a
		replace `RFdistText' = string(`effect', "%10.`=`dp''f") + " (" + string(`lci', "%10.`=`dp''f") + ", " +string(`uci', "%10.`=`dp''f") ///
			+ ")" if `use' == 4 & `tau2' == .a
		*/

		// don't show effect size again, just CI
		replace `RFdistLabel' = "Inestimable predictive distribution"  if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20) & `df' == 0
		replace `RFdistText' =  ".       (  -  ,  -  )" if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20) & `df' == 0

		qui replace `estText' = " " +  `estText' if `effect' >= 0 & (`use' != 4 & `use' != 6 & `use' != 18 & `use' != 20)
		gen str `weightText' = string(`wtdisp', "%4.2f")

		replace `weightText' = "" if `use' == 17 | `use' == 19 // can cause confusion and not necessary
		replace `weightText' = " " if (`use' == 3 | `use' == 5) & `df' == 0 /* Dont display if one study*/

		if "`logit'" == "" {
			replace `weightText' = ""
		}

		/* RJH - probably a better way to get this but I've just used globals from earlier */

		if "`overall'" == "" & "`nohet'" != "" {
			replace `label' = "Overall" if `use' == 5 | `use' == 17
		}
		
		replace `label' = " " if (`use' == 4 | `use' == 8  | `use' == 19 |`use' == 18 | `use' == 20)
		replace `label' = "Summary" if `use' == 19

		qui count if (`use'==1 | `use'==2)
		local ntrials=r(N)
		qui count if (`use'>=0 & `use'<=5)
		local ymax=r(N)
		gen `id'=`ymax'-_n+1 if `use'<9 | `use' == 17 | `use' == 19 |`use' == 18 | `use' == 20

		if "`model2'" != "" {
			local dispM1 = "`model'"
			local dispM2 = "`model2'"

			replace `label' = "`dispM1'" + " " + `label' if (`use' == 3 | `use' == 5) & substr(`label',1,3) != "het"
			replace `label' = "`dispM2'" + " " + `label' if `use' == 17 | `use' == 19 & substr(`label',1,3) != "het"
		}
		
		// GET MIN AND MAX DISPLAY
		// SORT OUT TICKS- CODE PINCHED FROM MIKE AND FIRandomED. TURNS OUT I'VE BEEN USING SIMILAR NAMES...
		// AS SUGGESTED BY JS JUST ACCEPT ANYTHING AS TICKS AND RESPONSIBILITY IS TO USER!
	
		qui summ `lci', detail
		local DXmin = r(min)
		qui summ `uci', detail
		local DXmax = r(max)
				
				if "`outplot'" == "rr" {
			local h0 = 1
		}
		else {
			local h0 = 0
		}

		// THIS BIT CHANGED- THE USER CAN PUT ANYTHING IN
		local flag1=0
		if ("`xlabel'"=="" | "`xtick'" == "") { 		// if no xlabel or tick
			local xtick  "`h0'"
		}

		if "`xlabel'"=="" {
			local xlabel "`DXmin',`h0',`DXmax'"
		}

		local DXmin2 = min(`xlabel',`DXmin')
		local DXmax2 = max(`xlabel',`DXmax')
		
		if "`force'" == "" {
			if "`xlabel'" != "" {
				local xlabel "`h0',`xlabel'"
			}
		}
		
		if "`force'" != ""{
			local DXmin = min(`xlabel')
			local DXmax = max(`xlabel')
			local xlabel "`h0',`xlabel'"
		}
		local lblcmd ""
		tokenize "`xlabel'", parse(",")
		while "`1'" != ""{
			if "`1'" != ","{
				local lbl = string(`1',"%7.3g")
				local val = `1'
				local lblcmd `lblcmd' `val' "`lbl'"
			}
			mac shift
		}
		
		if "`xtick'" == ""{
			local xtick = "`xlabel'"
		}

		local xtick2 = ""
		tokenize "`xtick'", parse(",")
		while "`1'" != ""{
			if "`1'" != ","{
				local xtick2 = "`xtick2' " + string(`1')
			}
			if "`1'" == ","{
				local xtick2 = "`xtick2'`1'"
			}
			mac shift
		}
		local xtick = "`xtick2'"

		local DXmin= (min(`xlabel',`xtick',`DXmin'))
		local DXmax= (max(`xlabel',`xtick',`DXmax'))

		// JUNK
		*noi di "min: `DXmin', `DXminLab'; h0: `h0', `h0Lab'; max: `DXmax', `DXmaxLab'"
		local DXwidth = `DXmax'-`DXmin'
		/*if `DXmin' > 0 {
			local h0 = 1
		}*/
	} // END QUI

	// END OF TICKS AND LABLES
	/*===============================================================================================*/
	/*==================================== COLUMNS   ================================================*/
	/*===============================================================================================*/
	// OPTIONS FOR L-R JUSTIFY?
	// HAVE ONE MORE COL POSITION THAN NECESSARY, COULD THEN R-JUSTIFY
	// BY ADDING 1 TO LOOP, ALSO HAVE MAX DIST FOR OUTER EDGE
	// HAVE USER SPECIFY % OF GRAPH USED FOR TEXT?

	qui{	// KEEP QUIET UNTIL AFTER DIAMONDS
		local titleOff = 0

		if "`lcols'" == "" {
			local lcols = "`label'"
			local titleOff = 1
		}

		// DOUBLE LINE OPTION
		if "`double'" != "" & ("`lcols'" != "" | "`rcols'" != "") {
			tempvar expand orig
			gen `orig' = _n
			gen `expand' = 1
			replace `expand' = 2 if `use' == 1
			expand `expand'
			sort `orig'
			replace `id' = `id' - 0.45 if `id' == `id'[_n-1]
			replace `use' = 2 if mod(`id',1) != 0 & `use' != 5
			replace `effect' = .  if mod(`id',1) != 0
			replace `lci' = . if mod(`id',1) != 0
			replace `uci' = . if mod(`id',1) != 0
			replace `estText' = "" if mod(`id',1) != 0
			cap replace `raw1' = "" if mod(`id',1) != 0
			cap replace `raw2' = "" if mod(`id',1) != 0
			replace `weightText' = "" if mod(`id',1) != 0

			foreach var of varlist `lcols' `rcols'{
			   cap confirm string var `var'
			   if _rc == 0 {				
				tempvar length words tosplit splitwhere best
				gen `splitwhere' = 0
				gen `best' = .
				gen `length' = length(`var')
				summ `length', det
				gen `words' = wordcount(`var')
				gen `tosplit' = 1 if `length' > r(max)/2+1 & `words' >= 2
				summ `words', det
				local max = r(max)
				forvalues i = 1/`max'{
					replace `splitwhere' = strpos(`var',word(`var',`i')) ///
					 if abs( strpos(`var',word(`var',`i')) - length(`var')/2 ) < `best' ///
					 & `tosplit' == 1
					replace `best' = abs(strpos(`var',word(`var',`i')) - length(`var')/2) ///
					 if abs(strpos(`var',word(`var',`i')) - length(`var')/2) < `best' 
				}

				replace `var' = substr(`var',1,(`splitwhere'-1)) if `tosplit' == 1 & mod(`id',1) == 0
				replace `var' = substr(`var',`splitwhere',length(`var')) if `tosplit' == 1 & mod(`id',1) != 0
				replace `var' = "" if `tosplit' != 1 & mod(`id',1) != 0 & `use' != 5
				drop `length' `words' `tosplit' `splitwhere' `best'
			   }
			   if _rc != 0{
				replace `var' = . if mod(`id',1) != 0 & `use' != 5
			   }
			}
		}

		summ `id' if `use' != 9
		local max = r(max)
		local new = r(N)+4
		if `new' > _N { 
			set obs `new' 
		}

		forvalues i = 1/4 {	// up to four lines for titles
			local multip = 1
			local add = 0
			if "`double'" != ""{		// DOUBLE OPTION- CLOSER TOGETHER, GAP BENEATH
				local multip = 0.45
				local add = 0.5
			}
			local idNew`i' = `max' + `i'*`multip' + `add'
			local Nnew`i'=r(N)+`i'
			local tmp = `Nnew`i''
			replace `id' = `idNew`i'' + 1 in `tmp'
			replace `use' = 1 in `tmp'
			if `i' == 1{
				local borderline = `idNew`i''-0.25
			}
		}

		local maxline = 1
		if "`lcols'" != "" {
			tokenize "`lcols'"
			local lcolsN = 0

			while "`1'" != "" {
				cap confirm var `1'
				if _rc!=0  {
					di in re "Variable `1' not defined"
					exit _rc
				}
				local lcolsN = `lcolsN' + 1
				tempvar left`lcolsN' leftLB`lcolsN' leftWD`lcolsN'
				cap confirm string var `1'
				if _rc == 0{
					gen str `leftLB`lcolsN'' = `1'
				}
				if _rc != 0{
					cap decode `1', gen(`leftLB`lcolsN'')
					if _rc != 0{
						local f: format `1'
						gen str `leftLB`lcolsN'' = string(`1', "`f'")
						replace `leftLB`lcolsN'' = "" if `leftLB`lcolsN'' == "."
					}
				}
				replace `leftLB`lcolsN'' = "" if (`use' != 1 & `use' != 2)
				local colName: variable label `1'
				if "`colName'"==""{
					local colName = "`1'"
				}

				// WORK OUT IF TITLE IS BIGGER THAN THE VARIABLE
				// SPREAD OVER UP TO FOUR LINES IF NECESSARY
				local titleln = length("`colName'")
				tempvar tmpln
				gen `tmpln' = length(`leftLB`lcolsN'')
				qui summ `tmpln' if `use' != 0
				local otherln = r(max)
				drop `tmpln'
				// NOW HAVE LENGTH OF TITLE AND MAX LENGTH OF VARIABLE
				local spread = int(`titleln'/`otherln') + 1
				if `spread' > 4{
					local spread = 4
				}
				local line = 1
				local end = 0
				local count = -1
				local c2 = -2

				local first = word("`colName'",1)
				local last = word("`colName'",`count')
				local nextlast = word("`colName'",`c2')

				while `end' == 0 {
					replace `leftLB`lcolsN'' = "`last'" + " " + `leftLB`lcolsN'' in `Nnew`line''
					local check = `leftLB`lcolsN''[`Nnew`line''] + " `nextlast'"	// what next will be

					local count = `count'-1
					local last = word("`colName'",`count')
					if "`last'" == ""{
						local end = 1
					}

					if length(`leftLB`lcolsN''[`Nnew`line'']) > `titleln'/`spread' | ///
					  length("`check'") > `titleln'/`spread' & "`first'" == "`nextlast'"{
						if `end' == 0{
							local line = `line'+1
						}
					}
				}
				if `line' > `maxline'{
					local maxline = `line'
				}
				mac shift
			}
		}

		if `titleOff' == 1	{
			forvalues i = 1/4{
				replace `leftLB1' = "" in `Nnew`i'' 		// get rid of horrible __var name
			}
		}
		replace `leftLB1' = `label' if `use' != 1 & `use' != 2	// put titles back in (overall, sub est etc.)

		//	STUFF ADDED FOR JS TO INCLUDE EFFICACY AS COLUMN WITH OVERALL
		if "`wt'" == "" {
			local rcols = "`weightText' " + "`rcols'"
			if "`logit'" != "" {
				if "`model2'" != "" {
					label var `weightText' "% Weight (`model')"
				}
				else{
					label var `weightText' "% Weight"
				}
			}
		}

		if "`stats'" == "" {
			local rcols = "`estText' " + "`rcols'"
			label var `estText' "`plotstat' (`ilevel'% CI)"
		}	

		tempvar extra
		gen `extra' = ""
		label var `extra' " "
		local rcols = "`rcols' `extra'"

		local rcolsN = 0
		if "`rcols'" != "" {
			tokenize "`rcols'"
			local rcolsN = 0
			while "`1'" != ""{
				cap confirm var `1'
				if _rc!=0  {
					di in re "Variable `1' not defined"
					exit _rc
				}
				local rcolsN = `rcolsN' + 1
				tempvar right`rcolsN' rightLB`rcolsN' rightWD`rcolsN'
				cap confirm string var `1'
				if _rc == 0{
					gen str `rightLB`rcolsN'' = `1'
				}
				if _rc != 0{
					local f: format `1'
					gen str `rightLB`rcolsN'' = string(`1', "`f'")
					replace `rightLB`rcolsN'' = "" if `rightLB`rcolsN'' == "."
				}
				local colName: variable label `1'
				if "`colName'"==""{
					local colName = "`1'"
				}

				// WORK OUT IF TITLE IS BIGGER THAN THE VARIABLE
				// SPREAD OVER UP TO FOUR LINES IF NECESSARY
				local titleln = length("`colName'")
				tempvar tmpln
				gen `tmpln' = length(`rightLB`rcolsN'')
				qui summ `tmpln' if `use' != 0
				local otherln = r(max)
				drop `tmpln'
				// NOW HAVE LENGTH OF TITLE AND MAX LENGTH OF VARIABLE
				local spread = int(`titleln'/`otherln')+1
				if `spread' > 4{
					local spread = 4
				}

				local line = 1
				local end = 0
				local count = -1
				local c2 = -2

				local first = word("`colName'",1)
				local last = word("`colName'",`count')
				local nextlast = word("`colName'",`c2')

				while `end' == 0{
					replace `rightLB`rcolsN'' = "`last'" + " " + `rightLB`rcolsN'' in `Nnew`line''
					local check = `rightLB`rcolsN''[`Nnew`line''] + " `nextlast'"	// what next will be

					local count = `count'-1
					local last = word("`colName'",`count')
					if "`last'" == ""{
						local end = 1
					}
					if length(`rightLB`rcolsN''[`Nnew`line'']) > `titleln'/`spread' | ///
					  length("`check'") > `titleln'/`spread' & "`first'" == "`nextlast'"{
						if `end' == 0{
							local line = `line'+1
						}
					}
				}
				if `line' > `maxline'{
					local maxline = `line'
				}
				mac shift
			}
		}

		// now get rid of extra title rows if they weren't used
		if `maxline'==3 {
			drop in `Nnew4'
		}
		if `maxline'==2 {
			drop in `Nnew3'/`Nnew4'
		}
		if `maxline'==1 {
			drop in `Nnew2'/`Nnew4'
		}
			

		/* BODGE SOLU- EXTRA COLS */
		while `rcolsN' < 2{
			local rcolsN = `rcolsN' + 1
			tempvar right`rcolsN' rightLB`rcolsN' rightWD`rcolsN'
			gen str `rightLB`rcolsN'' = " "
		}
		local skip = 1
		if "`stats'" == "" & "`wt'" == ""{				// sort out titles for stats and weight, if there
			local skip = 3
		}

		if "`stats'" != "" & "`wt'" == ""{
			local skip = 2
		}
		if "`stats'" == "" & "`wt'" != ""{
			local skip = 2
		}

		/* SET TWO DUMMY RCOLS IF NOSTATS NOWEIGHT */

		forvalues i = `skip'/`rcolsN'{					// get rid of junk if not weight, stats or counts
			replace `rightLB`i'' = "" if (`use' != 1 & `use' != 2)
		}
		forvalues i = 1/`rcolsN'{
			replace `rightLB`i'' = "" if (`use' == 0)
		}

		local leftWDtot = 0
		local rightWDtot = 0
		local leftWDtotNoTi = 0

		forvalues i = 1/`lcolsN'{
			getWidth `leftLB`i'' `leftWD`i''
			qui summ `leftWD`i'' if `use' != 0 & `use' != 8 & `use' != 3 & `use' != 5 & ///
				`use' != 17 & `use' != 19	// DON'T INCLUDE OVERALL STATS AT THIS POINT
			local maxL = r(max)
			local leftWDtotNoTi = `leftWDtotNoTi' + `maxL'
			replace `leftWD`i'' = `maxL'
		}
		tempvar titleLN				// CHECK IF OVERALL LENGTH BIGGER THAN REST OF LCOLS
		getWidth `leftLB1' `titleLN'	
		qui summ `titleLN' if `use' != 0 & `use' != 8
		local leftWDtot = max(`leftWDtotNoTi', r(max))

		forvalues i = 1/`rcolsN'{
			getWidth `rightLB`i'' `rightWD`i''
			qui summ `rightWD`i'' if `use' != 0 & `use' != 8
			replace `rightWD`i'' = r(max)
			local rightWDtot = `rightWDtot' + r(max)
		}

		// CHECK IF NOT WIDE ENOUGH (I.E., OVERALL INFO TOO WIDE)
		// LOOK FOR EDGE OF DIAMOND summ `lci' if `use' == ...

		tempvar maxLeft
		getWidth `leftLB1' `maxLeft'
		qui count if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
		if r(N) > 0 {
			summ `maxLeft' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19	// NOT TITLES THOUGH!
			local max = r(max)
			if `max' > `leftWDtotNoTi'{
				// WORK OUT HOW FAR INTO PLOT CAN EXTEND
				// WIDTH OF LEFT COLUMNS AS FRACTION OF WHOLE GRAPH
				local x = `leftWDtot'*(`astext'/100)/(`leftWDtot'+`rightWDtot')
				tempvar y
				// SPACE TO LEFT OF DIAMOND WITHIN PLOT (FRAC OF GRAPH)
				gen `y' = ((100-`astext')/100)*(`lci'-`DXmin') / (`DXmax'-`DXmin') 
				qui summ `y' if `use' == 3 | `use' == 5
				local extend = 1*(r(min)+`x')/`x'
				local leftWDtot = max(`leftWDtot'/`extend',`leftWDtotNoTi') // TRIM TO KEEP ON SAFE SIDE
													// ALSO MAKE SURE NOT LESS THAN BEFORE!
			}

		}
		local LEFT_WD = `leftWDtot'
		local RIGHT_WD = `rightWDtot'
		
		local ratio = `astext'		// USER SPECIFIED- % OF GRAPH TAKEN BY TEXT (ELSE NUM COLS CALC?)
		local textWD = (`DXwidth'/(1-`ratio'/100)-`DXwidth') /(`leftWDtot'+`rightWDtot')

		forvalues i = 1/`lcolsN'{
			gen `left`i'' = `DXmin' - `leftWDtot'*`textWD'
			local leftWDtot = `leftWDtot'-`leftWD`i''
		}

		gen `right1' = `DXmax'
		forvalues i = 2/`rcolsN'{
			local r2 = `i' - 1
			gen `right`i'' = `right`r2'' + `rightWD`r2''*`textWD'
		}

		local AXmin = `left1'
		local AXmax = `DXmax' + `rightWDtot'*`textWD'

		foreach type in "" "inf"{
			replace `tauLCI`inf'' = `DXmin' if `tauLCI' < `DXmin' & `tauLCI`inf'' != .
			replace `tauLCI`inf'' = . if `lci' < `DXmin'
			replace `tauLCI`inf'' = . if `tauLCI`inf'' > `lci'
			
			replace `tauUCI`inf'' = `DXmax' if `tauUCI`inf'' > `DXmax' & `tauUCI`inf'' != .
			replace `tauUCI`inf'' = . if `uci' > `DXmax'
			replace `tauUCI`inf'' = . if `tauUCI`inf'' < `uci'
			
			replace `tauLCI`inf'' = . if (`use' == 3 | `use' == 5) & (("`model'" != "random" & "`paired'" == "") |(("`model'" == "marginal" & "`paired'" != "")))
			replace `tauUCI`inf'' = . if (`use' == 3 | `use' == 5) & "`model'" != "random"
			replace `tauLCI`inf'' = . if (`use' == 17 | `use' == 19) & "`model2'" != "random"
			replace `tauUCI`inf'' = . if (`use' == 17 | `use' == 19) & "`model2'" != "random"
		}

		// DIAMONDS TAKE FOREVER...I DON'T THINK THIS IS WHAT MIKE DID
		tempvar DIAMleftX DIAMrightX DIAMbottomX DIAMtopX DIAMleftY1 DIAMrightY1 DIAMleftY2 DIAMrightY2 DIAMbottomY DIAMtopY

		gen `DIAMleftX' = `lci' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
		replace `DIAMleftX' = `DXmin' if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
		replace `DIAMleftX' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

		/*If one study, no diamond*/
		replace `DIAMleftX' = . if `df' < 1 & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)


		gen `DIAMleftY1' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
		replace `DIAMleftY1' = `id' + 0.4*( abs((`DXmin'-`lci')/(`effect'-`lci')) ) if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
		replace `DIAMleftY1' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

		gen `DIAMleftY2' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
		replace `DIAMleftY2' = `id' - 0.4*( abs((`DXmin'-`lci')/(`effect'-`lci')) ) if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
		replace `DIAMleftY2' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

		gen `DIAMrightX' = `uci' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
		replace `DIAMrightX' = `DXmax' if `uci' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
		replace `DIAMrightX' = . if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

		/*If one study, no diamond*/
		replace `DIAMrightX' = . if `df' < 1 & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)


		gen `DIAMrightY1' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
		replace `DIAMrightY1' = `id' + 0.4*( abs((`uci'-`DXmax')/(`uci'-`effect')) ) if `uci' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
		replace `DIAMrightY1' = . if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

		gen `DIAMrightY2' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
		replace `DIAMrightY2' = `id' - 0.4*( abs((`uci'-`DXmax')/(`uci'-`effect')) ) if `uci' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

		replace `DIAMrightY2' = . if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

		gen `DIAMbottomY' = `id' - 0.4 if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
		replace `DIAMbottomY' = `id' - 0.4*( abs((`uci'-`DXmin')/(`uci'-`effect')) ) if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
		replace `DIAMbottomY' = `id' - 0.4*( abs((`DXmax'-`lci')/(`effect'-`lci')) ) if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

		gen `DIAMtopY' = `id' + 0.4 if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
		replace `DIAMtopY' = `id' + 0.4*( abs((`uci'-`DXmin')/(`uci'-`effect')) ) if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
		replace `DIAMtopY' = `id' + 0.4*( abs((`DXmax'-`lci')/(`effect'-`lci')) ) if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

		gen `DIAMtopX' = `effect' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
		replace `DIAMtopX' = `DXmin' if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
		replace `DIAMtopX' = `DXmax' if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
		replace `DIAMtopX' = . if (`uci' < `DXmin' | `lci' > `DXmax') & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

		gen `DIAMbottomX' = `DIAMtopX'

	} // END QUI

	// v1.11 TEXT SIZE SOLU
	// v1.16 TRYING AGAIN!
	// IF aspect IS USED IN "`otheropts'" (OTHER GRAPH OPTS) THEN THIS HELPS TO CALCULATE TEXT SIZE
	// IF NO ASPECT, BUT xsize AND ysize USED THEN FIND RATIO MANUALLY
	// STATA ALWAYS TRIES TO PRODUCE A GRAPH WITH ASPECT ABOUT 0.77 - TRY TO FIND "NATURAL ASPECT"

	local aspect = .

	if strpos(`"`otheropts'"',"aspect") > 0 {
		local aspectTXT = substr( `"`otheropts'"', (strpos(`"`otheropts'"',"aspect")), (length(`"`otheropts'"')) )
		local aspectTXT = substr( "`aspectTXT'", 1, ( strpos("`aspectTXT'",")")) )
		local aspect = real( substr(   "`aspectTXT'", ( strpos("`aspectTXT'","(") +1 ), ///
						( strpos("`aspectTXT'",")") - strpos("`aspectTXT'","(") -1   )   ))
	}

	if strpos(`"`otheropts'"',"xsize") > 0 ///
	  & strpos(`"`otheropts'"',"ysize") > 0 ///
	  & strpos(`"`otheropts'"',"aspect") == 0 {

		local xsizeTXT = substr( `"`otheropts'"', (strpos(`"`otheropts'"',"xsize")), (length(`"`otheropts'"')) )

		// Ian White's bug fix!
		local xsizeTXT = substr( `"`xsizeTXT'"', 1, ( strpos(`"`xsizeTXT'"',")")) )
		local xsize = real( substr(   `"`xsizeTXT'"', ( strpos(`"`xsizeTXT'"',"(") +1 ), ///
						 ( strpos(`"`xsizeTXT'"',")") - strpos(`"`xsizeTXT'"',"(") -1   )   ))
		local ysizeTXT = substr( `"`otheropts'"', (strpos(`"`otheropts'"',"ysize")), (length(`"`otheropts'"')) )	
		local ysizeTXT = substr( `"`ysizeTXT'"', 1, ( strpos(`"`ysizeTXT'"',")")) )
		local ysize = real( substr(   `"`ysizeTXT'"', ( strpos(`"`ysizeTXT'"',"(") +1 ), ///
						 ( strpos(`"`ysizeTXT'"',")") - strpos(`"`ysizeTXT'"',"(") -1   )   ))

		local aspect = `ysize'/`xsize'
	}
	
	local approx_chars = (`LEFT_WD' + `RIGHT_WD')/(`astext'/100)
	qui count if `use' != 9
	local height = r(N)
	local natu_aspect = 1.3*`height'/`approx_chars'

	if `aspect' == . {
		// sort out relative to text, but not to ridiculous degree
		local new_asp = 0.5*`natu_aspect' + 0.5*1 
		local otheropts `"`otheropts' aspect(`new_asp')"'
		local aspectRat = max( `new_asp'/`natu_aspect' , `natu_aspect'/`new_asp' )
	}
	if `aspect' != . {
		local aspectRat = max( `aspect'/`natu_aspect' , `natu_aspect'/`aspect' )
	}
	local adj = 1.25
	if `natu_aspect' > 0.7{
		local adj = 1/(`natu_aspect'^1.3+0.2)
	}

	local texts2 = `adj' * `texts' / (`approx_chars' * sqrt(`aspectRat') )
	local texts = `adj' * `texts' / (`approx_chars' * sqrt(`aspectRat') )	
	
	forvalues i = 1/`lcolsN'{
		local lcolCommands`i' "(scatter `id' `left`i'' if `use' != 8, msymbol(none) mlabel(`leftLB`i'') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
	}
	forvalues i = 1/`rcolsN'{
		local rcolCommands`i' "(scatter `id' `right`i'' if `use' != 8, msymbol(none) mlabel(`rightLB`i'') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
	}
	
	/*PREDCIopts*/
	if `"`predciopt'"' != "" & strpos(`"`predciopt'"',"lcolor") == 0 {
		local predciopt = `"`predciopt' lcolor(red)"' 
	}
	if `"`predciopt'"' != "" & strpos(`"`predciopt'"',"lwidth") == 0 {
		local predciopt = `"`predciopt' lwidth(medium)"' 
	}
	if `"`predciopt'"' == "" {
		local predciopt "lcolor("255 0 0")"
	}
	else{
		if strpos(`"`predciopt'"',"hor") != 0 | strpos(`"`predciopt'"',"vert") != 0 {
			di as error "Options horizontal/vertical not allowed in predciopt()"
			exit
		}
		if strpos(`"`predciopt'"',"con") != 0{
			di as error "Option connect() not allowed in predciopt()"
			exit
		}
		if strpos(`"`predciopt'"',"lp") != 0{
			di as error "Option lpattern() not allowed in predciopt()"
			exit
		}
		local predciopt `"`predciopt'"'
	}	
	
	if "`rfdist'" != "" {
		if "`stats'" == "" {
			local predIntCmd "(scatter `id' `right1' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), msymbol(none) mlabel(`RFdistText') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
		}
		if "`het'" == "" {
			local predIntCmd2 "(scatter `id' `left1' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), msymbol(none) mlabel(`RFdistLabel') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
		}
		if "`predci'" =="" { 
			local predIntCmd3 "(pcspike `id' `lci' `id' `uci' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), `predciopt')"
		}
	}
	if "`het'" == "" & "`by'" != "" {
		local hetGroupCmd  "(scatter `id' `left1' if `use' == 8, msymbol(none) mlabel(`hetGroupLabel') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
	}

	// OTHER BITS AND BOBS

	local dispBox "none"
	if "`nobox'" == ""{
		local dispBox "square	"
	}

	local boxsize = `boxsca'/150
	
	if `h0' != . {
		local leftfp = `DXmin' + (`h0'-`DXmin')/2
		local rightfp = `h0' + (`DXmax'-`h0')/2
	}
	else{
		local leftfp = `DXmin'
		local rightfp = `DXmax'
	}
	// GRAPH APPEARANCE OPTIONS- ADDED v1.15

	if `"`boxopt'"' != "" & strpos(`"`boxopt'"',"msymbol") == 0{	// make defaults if unspecified
		local boxopt = `"`boxopt' msymbol(square)"'
	}
	if `"`boxopt'"' != "" & strpos(`"`boxopt'"',"mcolor") == 0{	// make defaults if unspecified
		local boxopt = `"`boxopt' mcolor("180 180 180")"'
	}
	if `"`boxopt'"' == ""{
		local boxopt "msymbol(`dispBox') msize(`boxsize') mcolor("180 180 180")"
	}
	else{
		if strpos(`"`boxopt'"',"mla") != 0{
			di as error "Option mlabel() not allowed in boxopt()"
			exit
		}
		if strpos(`"`boxopt'"',"msi") != 0{
			di as error "Option msize() not allowed in boxopt()"
			exit
		}
		local boxopt `"`boxopt' msize(`boxsize')"' 
	}
	if "`classic'" != ""{
		local boxopt "mcolor(black) msymbol(square) msize(`boxsize')"
	}
	if "`box'" != ""{
		local boxopt "msymbol(none)"
	}

	if `"`diamopt'"' == ""{
		local diamopt "lcolor("0 0 100")"
	}
	else{
		if strpos(`"`diamopt'"',"hor") != 0 | strpos(`"`diamopt'"',"vert") != 0{
			di as error "Options horizontal/vertical not allowed in diamopt()"
			exit
		}
		if strpos(`"`diamopt'"',"con") != 0{
			di as error "Option connect() not allowed in diamopt()"
			exit
		}
		if strpos(`"`diamopt'"',"lp") != 0{
			di as error "Option lpattern() not allowed in diamopt()"
			exit
		}
		local diamopt `"`diamopt'"'
	}
	
	if `"`pointopt'"' != "" & strpos(`"`pointopt'"',"msymbol") == 0{(
		local pointopt = `"`pointopt' msymbol(diamond)"' 
	}
	if `"`pointopt'"' != "" & strpos(`"`pointopt'"',"msize") == 0{(
		local pointopt = `"`pointopt' msize(vsmall)"' 
	}
	if `"`pointopt'"' != "" & strpos(`"`pointopt'"',"mcolor") == 0{(
		local pointopt = `"`pointopt' mcolor(black)"' 
	}
	if `"`pointopt'"' == ""{
		local pointopt "msymbol(diamond) msize(vsmall) mcolor("0 0 0")"
	}
	else{
		local pointopt `"`pointopt'"'
	}
	if "`classic'" != "" & "`box'" == ""{
		local pointopt "msymbol(none)"
	}

	if `"`ciopt'"' != "" & strpos(`"`ciopt'"',"lcolor") == 0{(
		local ciopt = `"`ciopt' lcolor(black)"' 
	}
	if `"`ciopt'"' == ""{
		local ciopt "lcolor("0 0 0")"
	}
	else{
		if strpos(`"`ciopt'"',"hor") != 0 | strpos(`"`ciopt'"',"vert") != 0{
			di as error "Options horizontal/vertical not allowed in ciopt()"
			exit
		}
		if strpos(`"`ciopt'"',"con") != 0{
			di as error "Option connect() not allowed in ciopt()"
			exit
		}
		if strpos(`"`ciopt'"',"lp") != 0{
			di as error "Option lpattern() not allowed in ciopt()"
			exit
		}
		local ciopt `"`ciopt'"'
	}

	// END GRAPH OPTS
	if "`overall'" != "" {
		local overallCommand ""
		qui drop if `use' == 5
		qui summ `id'
		local DYmin = r(min)
		cap replace `noteposy' = r(min) -.5 in 1
	}

	// quick bodge to get overall- can't find log version!
	tempvar tempOv overrallLine ovMin ovMax h0Line
	qui gen `tempOv' = `effect' if `use' == 5
	sort `tempOv'
	qui summ `id'
	local DYmin = r(min)-2
	local DYmax = r(max)+1

	qui gen `overrallLine' = `tempOv' in 1
	qui gen `ovMin' = r(min)-2 in 1
	qui gen `ovMax' = `borderline' in 1
	qui gen `h0Line' = `h0' in 1

	if `"`olineopt'"' == "" {
		local olineopt "lwidth(thin) lcolor(maroon) lpattern(shortdash)"
	}
	local overallCommand `" (pcspike `ovMin' `overrallLine' `ovMax' `overrallLine', `olineopt') "'

	if `overrallLine' > `DXmax' | `overrallLine' < `DXmin' | "`ovline'" != "" {	// ditch if not on graph
		local overallCommand ""
	}
	
	if "`ovline'" != "" {
		local overallCommand ""
		qui drop if `use' == 5
		qui summ `id'
		local DYmin = r(min)
		cap replace `noteposy' = r(min) -.5 in 1
	}

	if "`subline'" != "" & "`by'" != "" {
		local sublineCommand ""
		if "`outplot'" == "abs" {
			local confariate: word 1 of `regressors'
		}
		else {
			local confariate: word 2 of `regressors'
		}
		tempname confariate
		*my_ncod `confariate', oldvar(`confounder')
		qui label list `confariate'
		local nlevels = r(max)
		forvalues l = 1/`nlevels' {
			qui summ `id' if `use' == 1 & `by2' == `l'
			local lmax = r(max) + 1
			local lmin = r(min) - 2
			qui count if `use' == 1 & `by2' == `l'
			if r(N) > 1 {
				if "`outplot'" == "abs" {
					local sublineCommand `" `sublineCommand' (pci `lmax' `=`absout'[`l', 1]' `lmin'  `=`absout'[`l', 1]', `olineopt')"'
				}
				else {
					local sublineCommand `" `sublineCommand' (pci `lmax' `=`rrout'[`l', 1]' `lmin'  `=`rrout'[`l', 1]', `olineopt')"'
				}
			}
		}
	}
	// if summary only must not have weights
	local awweight "[aw= `wtdisp']"
	if ("`summaryonly'" != "") | ("`wt'" != ""){
		local awweight ""
	}
	qui summ `weight'
	if r(N) == 0 {
		local awweight ""
		}
		
	if "`logit'" == "" {
		local awweight ""
	}

	if strpos(`"`otheropts'"', "xsize") == 0 & strpos(`"`otheropts'"',"ysize") == 0 ///
	  & strpos(`"`otheropts'"',"aspect") > 0 {

		local aspct = substr(`"`otheropts'"', (strpos(`"`otheropts'"',"aspect(")+7 ) , length(`"`otheropts'"') )
		local aspct = substr(`"`aspct'"', 1, (strpos(`"`aspct'"',")")-1) )
		if `aspct' > 1{
			local xx = (11.5+(2-2*1/`aspct'))/`aspct'
			local yy = 12
		}
		if `aspct' <= 1{
			local yy = 12*`aspct'
			local xx = 11.5-(2-2*`aspct')
		}
		local otheropts = `"`otheropts'"' + " xsize(`xx') ysize(`yy')"
	}
	qui {
		//Generate indicator on direction of the off-scale arro
		tempvar rightarrow leftarrow biarrow rightlimit leftlimit offRhiY offRhiX offRloY offRloX offLloY offLloX offLhiY offLhiX
		gen `rightarrow' = 0
		gen `leftarrow' = 0
		gen `biarrow' = 0
		gen `rightlimit' = .
		gen `leftlimit' = .
		local arrowWidth = 0.05
		local arrowHeight = 0.4/2
		gen `offRhiY' = . 
		gen `offRhiX' = . 
		gen `offLhiY' = . 
		gen `offLhiX' = . 
		gen `offRloY' = . 
		gen `offRloX' = .
		gen `offLloY' = . 
		gen `offLloX' = .
		
		replace `rightarrow' = 1 if ///
			(round(`uci', 0.001) > round(`DXmax', 0.001)) & ///
			(round(`lci', 0.001) >= round(`DXmin', 0.001))  & ///
			(`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20) & ///
			(`uci' != .) & (`lci' != .)
			
		replace `leftarrow' = 1 if ///
			(round(`lci', 0.001) < round(`DXmin', 0.001)) & ///
			(round(`uci', 0.001) <= round(`DXmax', 0.001)) & ///
			(`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20) & ///
			(`uci' != .) & (`lci' != .)
		
		replace `biarrow' = 1 if ///
			(round(`lci', 0.001) < round(`DXmin', 0.001)) & ///
			(round(`uci', 0.001) > round(`DXmax', 0.001)) & ///
			(`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20) & ///
			(`uci' != .) & (`lci' != .)
		
		//Right arrow
		replace `rightlimit' = `DXmax' if `rightarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offRhiY' = `id' + `arrowHeight' if `rightarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offRhiX' = `rightlimit' - `arrowWidth' if `rightarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offRloY' = `id' - `arrowHeight' if `rightarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offRloX' = `rightlimit' - `arrowWidth' if `rightarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		
		//Left arrow
		replace `leftlimit' = `DXmin' if `leftarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offLhiY' = `id' + `arrowHeight' if `leftarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offLhiX' = `leftlimit' + `arrowWidth' if `leftarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offLloY' = `id' - `arrowHeight' if `leftarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offLloX' = `leftlimit' + `arrowWidth' if `leftarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		
		//Bi-arrow
		replace `rightlimit' = `DXmax' if `biarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `leftlimit' = `DXmin' if `biarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		
		replace `offRhiY' = `id' + `arrowHeight' if `biarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offRhiX' = `rightlimit' - `arrowWidth' if `biarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offRloY' = `id' - `arrowHeight' if `biarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offRloX' = `rightlimit' - `arrowWidth' if `biarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		
		replace `offLhiY' = `id' + `arrowHeight' if `biarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offLhiX' = `leftlimit' + `arrowWidth' if `biarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offLloY' = `id' - `arrowHeight' if `biarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `offLloX' = `leftlimit' + `arrowWidth' if `biarrow' == 1 & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
			
		count if `rightarrow' == 1 & (`use' == 1 | `use' == 2 )
		if r(N) > 0 {
			local ICICmd1 ""
			local ICICmd1 `"`ICICmd1' (pcspike `offRhiY' `offRhiX' `id' `rightlimit' if (`use' == 1 | `use' == 2 ), `ciopt')"' 
			local ICICmd1 `"`ICICmd1'(pcspike `offRloY' `offRloX' `id' `rightlimit' if (`use' == 1 | `use' == 2 ), `ciopt')"'
		}
		count if `leftarrow' == 1 & (`use' == 1 | `use' == 2 )
		if r(N) > 0 {
			local ICICmd2 "" 
			local ICICmd2 `"`ICICmd2' (pcspike `offLhiY' `offLhiX' `id' `leftlimit' if (`use' == 1 | `use' == 2 ), `ciopt')"' 
			local ICICmd2 `"`ICICmd2' (pcspike `offLloY' `offLloX' `id' `leftlimit' if (`use' == 1 | `use' == 2 ), `ciopt')"'
		}
		count if `biarrow' == 1 & (`use' == 1 | `use' == 2 )
		if r(N) > 0 {
			local ICICmd3 "" 
			local ICICmd3 `"`ICICmd3' (pcspike `offRhiY' `offRhiX' `id' `rightlimit' if (`use' == 1 | `use' == 2 ), `ciopt')"'
			local ICICmd3 `"`ICICmd3' (pcspike `offRloY' `offRloX' `id' `rightlimit' if (`use' == 1 | `use' == 2 ), `ciopt')"'
			local ICICmd3 `"`ICICmd3' (pcspike `offLhiY' `offLhiX' `id' `leftlimit' if (`use' == 1 | `use' == 2 ), `ciopt')"'
			local ICICmd3 `"`ICICmd3'(pcspike `offLloY' `offLloX' `id' `leftlimit' if (`use' == 1 | `use' == 2 ), `ciopt')"'
		}
		
		if "`rfdist'" != "" {			
			count if `rightarrow' == 1 & (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
			if r(N) > 0 {
				local predIntCmd3_1 ""
				local predIntCmd3_1 `"`predIntCmd3_1' (pcspike `offRhiY' `offRhiX' `id' `rightlimit' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), `predciopt')"' 
				local predIntCmd3_1 `"`predIntCmd3_1' (pcspike `offRloY' `offRloX' `id' `rightlimit' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), `predciopt')"'
			}
			count if `leftarrow' == 1 & (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
			if r(N) > 0 {			
				local predIntCmd3_2 ""
				local predIntCmd3_2 `"`predIntCmd3_2' (pcspike `offRhiY' `offRhiX' `id' `leftlimit' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), `predciopt')"' 
				local predIntCmd3_2 `"`predIntCmd3_2' (pcspike `offRloY' `offRloX' `id' `leftlimit' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), `predciopt')"'
			}
			count if `biarrow' == 1 & (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
			if r(N) > 0 {		
				local predIntCmd3_3 ""
				local predIntCmd3_3 `"`predIntCmd3_3' (pcspike `offRhiY' `offRhiX' `id' `rightlimit' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), `predciopt')"' 
				local predIntCmd3_3 `"`predIntCmd3_3' (pcspike `offRloY' `offRloX' `id' `rightlimit' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), `predciopt')"'
				local predIntCmd3_3 `"`predIntCmd3_3' (pcspike `offRhiY' `offRhiX' `id' `leftlimit' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), `predciopt')"' 
				local predIntCmd3_3 `"`predIntCmd3_3' (pcspike `offRloY' `offRloX' `id' `leftlimit' if (`use' == 4 | `use' == 6 | `use' == 18 | `use' == 20), `predciopt')"'
			}
		}
	
		replace `lci' = `DXmin' if `lci' < `DXmin' & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `uci' = `DXmax' if (`uci' > `DXmax') & (`uci' !=.) & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		
		replace `lci' = . if `uci' < `DXmin' & (`uci' !=. ) & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `uci' = . if (`lci' > `DXmax') & (`lci' !=. ) & (`use' == 1 | `use' == 2 | `use' == 4 | `use' == 6 | `use' == 18 | `use' == 20)
		replace `effect' = . if `effect' < `DXmin' & (`use' == 1 | `use' == 2)
		replace `effect' = . if `effect' > `DXmax' & (`use' == 1 | `use' == 2)
	}	// end qui

	/*===============================================================================================*/
	/*====================================  GRAPH    ================================================*/
	/*===============================================================================================*/
	#delimit ;

	twoway
	/* NOTE FOR RF, AND OVERALL LINES FIRST */ 
		`notecmd' `overallCommand' `sublineCommand' `predIntCmd' `predIntCmd2' `hetGroupCmd'
	/* PLOT BOXES AND PUT ALL THE GRAPH OPTIONS IN THERE */ 
		(scatter `id' `effect' `awweight' if `use' == 1,  
		  `boxopt' 
		  yscale(range(`DYmin' `DYmax') noline )
		  ylabel(none) ytitle("")
		  xscale(range(`AXmin' `AXmax'))
		  xlabel(`lblcmd', labsize(`texts2') )
		  yline(`borderline', lwidth(thin) lcolor(gs12))
	/* THIS BIT DOES favours. NOTE SPACES TO SUPPRESS IF THIS IS NOT USED */
		  xmlabel(`leftfp' "`leftfav' " `rightfp' "`rightfav' ", noticks labels labsize(`texts') 
		  `gap' /* PUT LABELS UNDER xticks? Yes as labels now extended */ ) 
		  xtitle("") legend(off) xtick("`xtick'") )
	/* END OF FIRST SCATTER */
	/* HERE ARE THE CONFIDENCE INTERVALS */
		(pcspike `id' `lci' `id' `uci' if `use' == 1, `ciopt')
	/* HERE ARE THE PREDICTION INTERVALS */	
		`predIntCmd3' `predIntCmd3_1' `predIntCmd3_2' `predIntCmd3_3'
	/* ADD ARROWS IF OFFSCALE USING offLeftX offLeftX2 offRightX offRightX2 offYlo offYhi */
		`ICICmd1' `ICICmd2' `ICICmd3'
		/*(pcspike `id' `offLeftX' `offYlo' `offLeftX2' if `use' == 1, `ciopt')
		(pcspike `id' `offLeftX' `offYhi' `offLeftX2' if `use' == 1, `ciopt')
		(pcspike `id' `offRightX' `offYlo' `offRightX2' if `use' == 1, `ciopt')
		(pcspike `id' `offRightX' `offYhi' `offRightX2' if `use' == 1, `ciopt')*/
	/* DIAMONDS FOR SUMMARY ESTIMATES -START FROM 9 O'CLOCK */
		(pcspike `DIAMleftY1' `DIAMleftX' `DIAMtopY' `DIAMtopX' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19), `diamopt')
		(pcspike `DIAMtopY' `DIAMtopX' `DIAMrightY1' `DIAMrightX' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19), `diamopt')
		(pcspike `DIAMrightY2' `DIAMrightX' `DIAMbottomY' `DIAMbottomX' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19), `diamopt')
		(pcspike `DIAMbottomY' `DIAMbottomX' `DIAMleftY2' `DIAMleftX' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19), `diamopt') 
	/* EXTENDED CI FOR RANDOM EFFECTS, SHOW DISTRIBUTION AS RECOMMENDED BY JULIAN HIGGINS 
	   DOTTED LINES FOR INESTIMABLE DISTRIBUTION */
		/*
		(pcspike `DIAMleftY1' `DIAMleftX' `DIAMleftY1' `lci' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' < ., `diamopt')
		(pcspike `DIAMrightY1' `DIAMrightX' `DIAMrightY1' `uci' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' < ., `diamopt')
		(pcspike `DIAMleftY1' `DIAMleftX' `DIAMleftY1' `lci' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' ==.b, `diamopt' lpattern(shortdash))
		(pcspike `DIAMrightY1' `DIAMrightX' `DIAMrightY1' `uci' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' ==.b, `diamopt' lpattern(shortdash)) 
		*/
	/* DIAMOND EXTENSION FOR RF DIST ALSO HAS ARROWS... */
		/*(pcspike `id' `offLeftX' `offYlo' `offLeftX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt')
		(pcspike `id' `offLeftX' `offYhi' `offLeftX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt')
		(pcspike `id' `offRightX' `offYlo' `offRightX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt')
		(pcspike `id' `offRightX' `offYhi' `offRightX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt') */
	/* COLUMN VARIABLES */
		`lcolCommands1' `lcolCommands2' `lcolCommands3' `lcolCommands4' `lcolCommands5' `lcolCommands6'
		`lcolCommands7' `lcolCommands8' `lcolCommands9' `lcolCommands10' `lcolCommands11' `lcolCommands12'
		`rcolCommands1' `rcolCommands2' `rcolCommands3' `rcolCommands4' `rcolCommands5' `rcolCommands6'
		`rcolCommands7' `rcolCommands8' `rcolCommands9' `rcolCommands10' `rcolCommands11' `rcolCommands12'
		(scatter `id' `right1' if  (`use' != 8 & `use' != 0),
		  msymbol(none) mlabel(`rightLB1') mlabcolor("0 0 0") mlabpos(3) mlabsize(`texts'))
		(scatter `id' `right2' if (`use' != 8 & `use' != 0),
		  msymbol(none) mlabel(`rightLB2') mlabcolor("0 0 0") mlabpos(3) mlabsize(`texts'))
	/* 	(scatter `id' `right2', mlabel(`use'))   JUNK, TO SEE WHAT'S WHERE */
	/* LAST OF ALL PLOT EFFECT MARKERS TO CLARIFY AND OVERALL EFFECT LINE */
		(scatter `id' `effect' if `use' == 1, `pointopt')
		, `otheropts' /* RMH added */ plotregion(margin(zero));


		#delimit cr	
		if "$by_index_" != "" {
			qui graph dir
			local gnames = r(list)
			local gname: word 1 of `gnames'
			tokenize `gname', parse(".")
			local gname `1'
			if "`3'" != "" {
				local ext =".`3'"
			}
			
			qui graph rename `gname'`ext' `gname'$by_index_`ext', replace
		}
		
		qui cap drop _ID
		qui gen _ID = `id'
	end
	/*===============================================================================================*/
	/*==================================== GETWIDTH  ================================================*/
	/*===============================================================================================*/
	capture program drop getWidth
	program define getWidth
	version 14.1

	//	ROSS HARRIS, 13TH JULY 2006
	//	TEXT SIZES VARY DEPENDING ON CHARACTER
	//	THIS PROGRAM GENERATES APPROXIMATE DISPLAY WIDTH OF A STRING
	//	FIRST ARG IS STRING TO MEASURE, SECOND THE NEW VARIABLE

	//	PREVIOUS CODE DROPPED COMPLETELY AND REPLACED WITH SUGGESTION
	//	FROM Jeff Pitblado

	qui {
		gen `2' = 0
		count
		local N = r(N)
		forvalues i = 1/`N' {
			local this = `1'[`i']
			local width: _length "`this'"
			replace `2' =  `width' + 1 in `i'
		}
	} // end qui

	end

	/*++++++++++++++++	SUPPORTING FUNCTIONS: BUILDEXPRESSIONS +++++++++++++++++++++
				buildexpressions the regression and estimation expressions
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop buildregexpr
	program define buildregexpr, rclass
	version 14.1
		
		syntax varlist, [INTeraction]
		
		tokenize `varlist'
		
		macro shift 2
		local regressors "`*'"
		local p: word count `regressors'
		
		local mixedcov = 0
		if "`regressors'" != "" {		
			foreach cov of local regressors {
				cap confirm string variable `cov'
				if _rc != 0 {
					local mixedcov = 1
				}
			}
		}
	
		local catreg
		foreach v of local regressors {
			cap confirm string variable `v'
			if !_rc {
				local catreg "`catreg' `v'"
			}
		}
		if "`interaction'" == "" | `mixedcov' == 1 {
			local regexpression = `"mu"'
		}
		else {
			local regexpression
		}
		tokenize `regressors'
		forvalues i = 1(1)`p' {			
			capture confirm numeric var ``i''
			if _rc != 0 {			
				my_ncod holder, oldvar(``i'')
				drop ``i''
				rename holder ``i''
				local prefix_`i' "i"
			}
			else {
				local prefix_`i' "c"
			}
			/*Add the proper expression for regression*/
			if "`interaction'" == "" {
				local regexpression = "`regexpression' `prefix_`i''.``i''"
			}
			else {
				if `i' == 1  {
					local regexpression = "`regexpression' `prefix_`i''.``i''"
				}
				else {
					if "`prefix_`i''" == "i" {
						if `i' == 2 &  `mixedcov' == 0 { 
							local regexpression 
						}
						local regexpression = "`regexpression' `prefix_`i''.``i''#`prefix_1'.`1'#c.mu"
					}
					else {
						local regexpression = "`regexpression' `prefix_`i''.``i'' `prefix_1'.`1'#`prefix_`i''.``i''"
					}
				}
			}	
		}
		return local  regexpression = "`regexpression'"
		return local  catreg = "`catreg'"
	end	
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: logitreg +++++++++++++++++++++++++
								Fit the logistic regression
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	 
	cap program drop logitreg
	program define logitreg
	version 14.1
		
		#delimit ;
		syntax varlist [if] [in], regexpression(string) model(string) sid(varname) 
		[modelopts(string asis) paired cci(varname) olevel(integer 95)];
		
		#delimit cr
		
		if strpos("`modelopts'", "level") == 0 {
			local modelopts = "`modelopts' level(`olevel')"
		}
		
		tokenize `varlist'
		*cap drop mu
		*gen mu = 1
	
		if ("`model'" == "fixed" & "`paired'" == "") | ("`model'" =="marginal" & "`paired'" != "") {		
			binreg `1' `regexpression'  `if' `in' , noconstant n(`2') ml `modelopts' l(`olevel')	
		} 
		if ("`model'" == "random" & "`paired'" == "") | ("`model'" != "marginal" & "`paired'" != "")    {
			
			if ("`model'" == "random" & "`paired'" != "")	{
				if "`3'" != "" {
					cap drop cci
					gen cci = `3' - 1
					local ccire "|| (cci:)"
				}
				if "`cci'" != "" {
					local ccire "|| (`cci':)"
				}
			}
			if strpos(`"`modelopts'"', "iterate") == 0  {
				local modelopts = `"iterate(30) `modelopts'"'
			}
			if strpos(`"`modelopts'"', "intpoi") == 0  {
				qui count
				if `=r(N)' < 7 {
					local modelopts = `"intpoints(`=r(N)') `modelopts'"'
				}
			}
			/*Fit the model and check if it converged*/
			#delim ;
			capture noisily meqrlogit (`1' `regexpression' `if' `in', noc )||
			  (`sid':) `ccire',
			  binomial(`2') `modelopts' l(`olevel');
			#delimit cr
			
			/*If not converging, try again*/
			if strpos(`"`modelopts'"', "refineopts") == 0 {
				local converged = e(converged)
				local try = 1
				while `try' < 3 & `converged' == 0 {
				
					#delim ;
					capture noisily meqrlogit (`1' `regexpression' `if' `in', noc )||
					  (`sid':) `ccire',
					  binomial(`2') `modelopts' l(`olevel') refineopts(iterate(`=10 * `try''));
					#delimit cr
					
					local converged = e(converged)
					local try = `try' + 1
				}
			}
			*Try matlog if still difficult
			if (strpos(`"`modelopts'"', "matlog") == 0) & ((`converged' == 0) | (_rc != 0)) {
				#delim ;
				capture noisily meqrlogit (`1' `regexpression' `if' `in', noc )||
				  (`sid':) `ccire',
				  binomial(`2') `modelopts' l(`olevel') refineopts(iterate(`=5 * `try'')) matlog;
				#delimit cr
				local converged = e(converged)
				*If not converged, exit and offer possible solutions
				if (`converged' == 0) {
					di as res "Model could not converge after 5 attempts"
					di as res "Try fitting a fixed-effect model"
					exit
				}
			}	
		}		
		*drop mu
		cap drop cci
		end
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: myncod +++++++++++++++++++++++++
								Decode by order of data
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/	
	cap program drop my_ncod
	program define my_ncod
	version 14.1

		syntax newvarname(gen), oldvar(varname)
		
		qui {
			cap confirm numeric var `oldvar'
			tempvar by_num 
			
			if _rc == 0 {				
				decode `oldvar', gen(`by_num')
				drop `oldvar'
				rename `by_num' `oldvar'
			}

			* The _by variable is generated according to the original
			* sort order of the data, and not done alpha-numerically

			qui count
			local N = r(N)
			cap drop `varlist'
			gen `varlist' = 1 in 1
			local lab = `oldvar'[1]
			cap label drop `oldvar'
			if "`lab'" != ""{
				label define `oldvar' 1 "`lab'"
			}
			local found1 "`lab'"
			local max = 1
			forvalues i = 2/`N'{
				local thisval = `oldvar'[`i']
				local already = 0
				forvalues j = 1/`max'{
					if "`thisval'" == "`found`j''"{
						local already = `j'
					}
				}
				if `already' > 0{
					replace `varlist' = `already' in `i'
				}
				else{
					local max = `max' + 1
					replace `varlist' = `max' in `i'
					local lab = `oldvar'[`i']
					if "`lab'" != ""{
						label define `oldvar' `max' "`lab'", modify
					}
					local found`max' "`lab'"
				}
			}

			label values `varlist' `oldvar'
		}
	end
	/*++++++++++++++++++++++	SUPPORTING FUNCTIONS: PREG ++++++++++++++++
							Transform data to long format
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

	cap program drop preg
	program define preg, rclass
	version 14.1

		#delimit ;
		syntax varlist [if] [in], 
			studyid(varname) [
			AStext(integer 50) 
			BOXOpt(string) 
			BOXSca(real 100.0) 
			BReps(integer 1000)
			BY(string) 
			CC(string)
			cci(varname) 
			CImethod(string) 
			CIOpt(string) 
			CLassic
			paired 
			DIAMopt(string) 
			DOUBLE 
			download(string)
			DP(integer 2) 
			FORCE 
			FTT 
			ILevel(integer 95) 
			interaction  
			LABEL(string) 
			LCOLS(string) 
			model(string) 
			modelopts(string)
			noBOX 
			noGRAPH 
			NOHET
			noLOGIT		
			noOVERALL  
			noOVLine 
			NOSECSUB
			noSTATS 
			noSUBGROUP 
			noTABLE  
			
			noWT 
			OLevel(integer 95) 
			OLineopt(string) 
			outplot(string) 
			outtable(string) 
			plotstat(string asis) 
			POINTopt(string) 
			POwer(integer 0)
			PREDciOpt(string)
			RCOLS(string) 
			RFdist 
			RFLevel(integer 95)
			RJHSECOND		
			SGWEIGHT
			SORTBY(string) 
			SUBLINE 
			SUMMARYonly
			tablestat(string asis) 
			TEXts(real 100.0) 
			WGT(passthru) 
			XLAbel(passthru) 
			XTICK(passthru) 
			otheropts(string)
		*];
		#delimit cr
		
		tokenize `varlist'
		if "`dependent'" == "" {
			macro shift 2
			local regressors "`*'"
			local p: word count `regressors'
		}
		tokenize `regressors'
		
		preserve
		/********
		cap drop mu
		gen mu = 1
		local varlist cases_tb population bcg
		local model marginal
		********/
		buildregexpr `varlist',  `interaction'
		local regexpression = r(regexpression)
		if "`regexpression'" == "mu" {
			local catreg  
		}
		else {
			local catreg = r(catreg)
		}
		
		if "`paired'" != "" {
			local VarX : word 1 of `regressors'
		}
		if "`by'" == "" {
			/*Fitted model*/
			tokenize `varlist'
			local nu = "mu"
			forvalues i=1/`p' {
				local c:word `i' of `regressors'
				if "`interaction'" == "" {
					local nu = "`nu' + {c ss}_`i'*`c'"
				}
				else {
					if `i' == 1 {
						local nu 
					}
					else if `i' == 2{
						local nu = "{c ss}_`i'*`c'*`VarX'"
					}
					else {
						local nu = "`nu' + {c ss}_`i'*`c'*`VarX'"
					}
				}
			}
			if "`paired'" == "" {
				if "`model'" == "random" {
					local nu = "`nu' + `studyid'"
				}
			}
			else {
				if "`model'" == "random" {
					local nu = "`nu' + `studyid' + `VarX'"
				}
				if "`model'" == "fixed" {
					local nu = "`nu' + `studyid'"
				}
			}
			di as res _n "*********************************** Fitted model ***************************************"  _n
			di "{phang} `1' ~ binomial(logit(p), `2'){p_end}"
			di "{phang} logit(p) = `nu'{p_end}"
			
			if "`paired'" == "" {
				if "`model'" == "random" {	
					di "{phang}`studyid' ~ normal(0, tau_b){p_end}"
				}
			}
			else {
				if "`model'" == "random" {
					di "{phang}`studyid' ~ normal(0, tau_b){p_end}"
					di "{phang}`VarX' ~ normal(0, tau_w){p_end}"
				}
				else if ("`model'" == "fixed") {
					di "{phang}`studyid' ~ normal(0, tau_b){p_end}"
				}
			}
		}		
		
		qui logitreg `varlist', regexpression(`regexpression') model(`model') sid(`studyid') ///
				  modelopts(`modelopts') `paired' cci(`VarX') olevel(`olevel')
				  
		local S_8 = e(N) -  e(k)
		
		tempname Ocoef VOcoef raw logodds absout rrout 
		
		mat `Ocoef' = e(b)
		mat `VOcoef' = e(V)		  
		estimates store metapreg_pregest
		
		local npar = colsof(`Ocoef')
		if "`paired'" == "" {
			if "`model'" == "random" {
				local tau_b2 = exp(`Ocoef'[1, `npar'])^2
				local tau_t2 = 0
			}
			else {
				local tau_b2 = 0
				local tau_t2 = 0
			}
		}
		else {
			if "`model'" == "random"{
				local tau_b2 = exp(`Ocoef'[1, `=`npar'-1'])^2 //between-study
				local tau_t2 = exp(`Ocoef'[1, `npar'])^2 //within-study
			}
			else if "`model'" == "fixed" {
				local tau_b2 = exp(`Ocoef'[1, `npar'])^2 //between-study
				local tau_t2 = 0 //within-study
			}
			else {
				local tau_b2 = 0 //between-study
				local tau_t2 = 0 //within-study
			}
		}
		
		if("`outtable'" != "") {
			statlabel, `tablestat'
			local rawlabel = r(labraw)
			local loddslabel = r(lablodds)
			local abslabel = r(lababs)
			local rrlabel = r(labrr)
		}
		//RAW
		if ("`outtable'" == "all") |(strpos("`outtable'", "raw") != 0){
			local depname : word 1 of `varlist'
			noi estraw, estimates(metapreg_pregest) matrix(`raw') sumstat(`rawlabel') depname(`depname') `paired' model(`model') 
		}
		else {
			local depname : word 1 of `varlist'
			estraw, estimates(metapreg_pregest) matrix(`raw') sumstat(`rawlabel')  depname(`depname') `paired' model(`model') noprint 
		}
		mat `raw' = r(raw)
		//LOG ODDS
		if ("`outtable'" == "all") |(strpos("`outtable'", "logodds") != 0){
			noi estp, estimates(metapreg_pregest) matrix(`logodds') sumstat(`loddslabel') grand catreg(`catreg') olevel(`olevel')
		}
		else {
			estp, estimates(metapreg_pregest) matrix(`logodds') sumstat(`loddslabel') grand noprint catreg(`catreg') olevel(`olevel')
		}
		mat `logodds' = r(logodds)
		//ABS
		if ("`outtable'" == "all") |(strpos("`outtable'", "abs") != 0) {
			noi estp, estimates(metapreg_pregest) matrix(`absout') sumstat(`abslabel') grand expit catreg(`catreg') olevel(`olevel')
		}
		else {
			estp, estimates(metapreg_pregest) matrix(`absout') sumstat(`abslabel') grand expit noprint catreg(`catreg') olevel(`olevel')
		}
		mat `absout' = r(absout)
		//RR
		if ("`outtable'" == "all") |(strpos("`outtable'", "rr") != 0) & `p' > 0 {
			noi estr, estimates(metapreg_pregest) matrix(`rrout') sumstat(`rrlabel') `paired' catreg(`catreg') olevel(`olevel')
		}
		else {
			estr, estimates(metapreg_pregest) matrix(`rrout') sumstat(`rrlabel') `paired' noprint catreg(`catreg') olevel(`olevel')
		}
		mat `rrout' = r(rrout)

		qui estimates restore metapreg_pregest
		
		if "`outplot'" == "abs" {
			local nrows = rowsof(`absout')
			local S_1 = `absout'[`nrows', 1] //p
			local S_2 = `absout'[`nrows', 2] //se
			local S_3 = `absout'[`nrows', 5] //ll
			local S_4 = `absout'[`nrows', 6] //ul
			local S_5 = `absout'[`nrows', 3] //z
			local S_6 = `absout'[`nrows', 4] //pvalue
		}
		else {
			local nrows = rowsof(rrout)
			local S_1 = rrout[`nrows', 1] //rr
			local S_2 = rrout[`nrows', 2] //se
			local S_3 = rrout[`nrows', 5] //ll
			local S_4 = rrout[`nrows', 6] //ul
			local S_5 = rrout[`nrows', 3] //z
			local S_6 = rrout[`nrows', 4] //pvalue
		}
		
		local S_7 = .
		local S_8 = `S_8'
		local S_9 = .
		local S_10 = .
		local S_11 = .
		local S_12 = `tau_b2'
		local S_13 = `tau_t2'
		local S_14 = .
			
		cap confirm matrix `raw'
		if _rc == 0 {
			return matrix raw = `raw'
		}
		cap confirm matrix `logodds'
		if _rc == 0 {
			return matrix logodds = `logodds'
		}
		cap confirm matrix `absout'
		if _rc == 0 {
			return matrix absout = `absout'
		}
		cap confirm matrix `rrout'
		if _rc == 0 {
			return matrix rrout = `rrout'
		}
		return matrix Ocoef = `Ocoef'
		return matrix VOcoef = `VOcoef'
		
		return local S_1 = `S_1'
		return local S_2 = `S_2'
		return local S_3 = `S_3'
		return local S_4 = `S_4'
		return local S_5 = `S_5'
		return local S_6 = `S_6'
		return local S_7 = `S_7'
		return local S_8 = `S_8'
		return local S_9 = `S_9'
		return local S_10 = `S_10'
		return local S_11 = `S_11'
		return local S_12 = `S_12'
		return local S_13 = `S_13'
		return local S_14 = `S_14'
		return local model "`model'"		
		restore
	end

		/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: WIDESETUP +++++++++++++++++++++++++
							Transform data to wide format
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop widesetup
	program define widesetup, rclass
	version 14.1

	syntax varlist, sid(varname) 

		qui{
			tokenize `varlist'
					
			/*The two variables should contain numbers*/
			forvalue i=1(1)2 {
				capture confirm numeric var ``i''
				if _rc != 0 {
					di as error "The variable ``i'' must be numeric"
					exit
				}	
			}
			
			tempvar cci_ cci modey diffy
			
			if "`3'" == "" {
				di as error "Variable uniquely identifying the observations per study required"
			}
			else {				
				my_ncod `cci_', oldvar(`3')
				gen `cci' = `cci_' - 1
				drop `cci_'
			}
			
			/*Check for varying variable and store them*/
			ds
			local vnames = r(varlist)
			local vlist
			local byrr = "`3'"
			foreach v of local vnames {	
				cap drop `modey' `diffy'
				bysort `sid': egen `modey' = mode(`v'), minmode
				egen `diffy' = diff(`v' `modey')
				sum `diffy'
				local sumy = r(sum)
				if (strpos(`"`varlist'"', "`v'") == 0) & (`sumy' > 0) & "`v'" != "`cci'" & "`v'" != "`byrr'" {
					local vlist "`vlist' `v'"
				}
			}
			cap drop `modey' `diffy'
			
			sort `sid' `cci'
			
			/*2 variables per study : n N*/			
			reshape wide `1' `2'  `3' `vlist', i(`sid') j(`cci')
			local cc0 = `3'0[1]
			local cc1 = `3'1[1]
			
			return local vlist = "`vlist'"
			return local cc0 = "`cc0'"
			return local cc1 = "`cc1'"
		}
	end	
	
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: LONGSETUP +++++++++++++++++++++++++
							Transform data to long format
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop longsetup
	program define longsetup
	version 14.1

	syntax varlist, case(name) control(varname) 

		qui{
			tokenize `varlist'
					
			/*The four variables should contain numbers*/
			forvalue i=1(1)4 {
				capture confirm numeric var ``i''
				if _rc != 0 {
					di as error "The variable ``i'' must be numeric"
					exit
				}	
			}
			
			/*4 variables per study : a b c d*/
			gen event1 = `1' + `2'  /*event1*/
			gen event0 = `1' + `3'  /*event0*/	
			gen total = `1' + `2' + `3' + `4'
			gen rid = _n		
			reshape long event, i(rid) j(cci)
			tostring cci, replace
			replace cci = `case' if cci=="1"
			replace cci = `control' if cci=="0"
		}
	end
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS:  ESTRAW +++++++++++++++++++++++++
							estimate absolutes after modelling
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/	
	cap program drop estraw
	program define estraw, rclass
	version 14.1
		syntax, estimates(string) [sumstat(string) noprint depname(string) paired model(string) DP(integer 2) ]
		
			tempname outmatrix
			qui estimates restore `estimates'
			qui ereturn display
			mat `outmatrix' = r(table)'
			
			local rnames :rownames `outmatrix'
			local nrows = rowsof(`outmatrix')

			local rownames = ""
			local rspec = "-" /*draw lines or not between the rows*/
			local rownamesmaxlen = 10 /*Default*/
			
			if "`paired'" == "" {
				if "`model'" == "fixed"{
					local nrowss = `nrows'
				}
				else {
					local nrowss = `nrows' - 1
				}
			}
			else{
				if "`model'" == "marginal" {
					local nrowss = `nrows'
				}
				else if "`model'" == "fixed" {
					local nrowss = `nrows' - 1
				}
				else {
					local nrowss = `nrows' - 2
				}
			}
			
			mat `outmatrix' = `outmatrix'[1..`nrowss', 1..6]

			forvalues r = 1(1)`nrowss' {
				if (`r' == 1) {
					local rspec = "`rspec'-"
				}
				else{
					local rspec = "`rspec'&"
				}
				local rname`r':word `r' of `rnames'
				
				if strpos("`rname`r''", "#") == 0 {
					tokenize `rname`r'', parse(".")
					if "`3'" != "" {
						if strpos("`rname`r''", "1b") == 0 {
							local lab:label `3' `1'
						}
						else {
							local lab:label `3' 1
						}
					}
					else {
						local lab "`1'"
					}
					local eqlab = "`3'"
					if "`eqlab'" != "" {
						local nlencov : strlen local eqlab
					}					
				}
				else{
					tokenize `rname`r'', parse("#")
					local left = "`1'"
					local right = "`3'"
					
					tokenize `left', parse(.)
					local leftv = "`3'"
					local leftlabel = "`1'"
					
					tokenize `right', parse(.)
					local rightv = "`3'"
					local rightlabel = "`1'"
					
					if strpos("`leftlabel'", "c") == 0 {
						if strpos("`leftlabel'", "o") != 0 {
							local indexo = strlen("`leftlabel'") - 1
							local leftlabel = substr("`leftlabel'", 1, `indexo')
						}
						if strpos("`leftlabel'", "1b") == 0 {
							local llab:label `leftv' `leftlabel'
						}
						else {
							local llab:label `leftv' 1
						}
					} 
					else {
						local llab
					}
					
					if strpos("`rightlabel'", "c") == 0 {
						if strpos("`rightlabel'", "o") != 0 {
							local indexo = strlen("`rightlabel'") - 1
							local rightlabel = substr("`rightlabel'", 1, `indexo')
						}
						if strpos("`rightlabel'", "1b") == 0 {
							local rlab:label `rightv' `rightlabel'
						}
						else {
							local rlab:label `rightv' 1
						}
					} 
					else {
						local rlab
					}
					
					if (("`rlab'" != "") + ("`llab'" != "")) ==  0 {
						local lab = "`leftv'&`rightv'"
						local eqlab = ""
					}
					if (("`rlab'" != "") + ("`llab'" != "")) ==  1 {
						local lab = "`llab'`rlab'" 
						local eqlab = "`leftv'&`rightv'"
					}
					if (("`rlab'" != "") + ("`llab'" != "")) ==  2 {
						local lab = "`llab'&`rlab'" 
						local eqlab = "`leftv'&`rightv'"
					}
					local nlencovl : strlen local leftv
					local nlencovr : strlen local rightv
					local nlencov = `nlencovl' + `nlencovr' + 1
				}
				local lab = ustrregexra("`lab'", " ", "_")
				local rownames = "`rownames' `eqlab':`lab'"
				local nlenlab : strlen local lab
				if "`eqlab'" != "" {
					local nlencov = `nlencov'
				}
				else {
					local nlencov = 0
				}
				local rownamesmaxlen = max(`rownamesmaxlen', min(`=`nlenlab' + `nlencov' + 1', 32)) /*Check if there is a longer name*/
				if (`r' == `nrowss'){
					local rspec = "`rspec'-" /*Last line*/
				}
			}

			mat rownames `outmatrix' = `rownames'
			mat colnames `outmatrix' = `sumstat' SE z P>|z| Lower Upper
			
			if "`print'" == "" {
				local nlensstat : strlen local sumstat
				local nlensstat = max(10, `nlensstat')
				di as res _n "****************************************************************************************"
				di as res "{pmore2} Conditional summary measures of test accuracy : Raw coefficients {p_end}"
				di as res    "****************************************************************************************" 
				tempname mat2print
				mat `mat2print' = `outmatrix'
				local nrows = rowsof(`mat2print')
				forvalues r = 1(1)`nrows' {
					local cellr2 = `mat2print'[`r', 2] 
					if "`cellr2'" == "." {
						forvalues c = 1(1)6 {
							mat `mat2print'[`r', `c'] == .z
						}
					}
				}
				#delimit ;
				noi matlist `mat2print', rowtitle(`depname') 
							cspec(& %`rownamesmaxlen's |  %`nlensstat'.`=`dp''f &  %9.`=`dp''f &  %8.`=`dp''f &  %15.`=`dp''f &  %8.`=`dp''f &  %8.`=`dp''f o2&) 
							rspec(`rspec') underscore  nodotz
				;
				#delimit cr
			}
		return matrix outmatrix = `outmatrix'
	end
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: ESTP +++++++++++++++++++++++++
							estimate absolutes after modelling
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/	
	cap program drop estp
	program define estp, rclass
	version 14.1
		syntax, estimates(string) [catreg(varlist) sumstat(string) noprint EXpit grand noconditional model(string) studyid(varname) paired olevel(integer 95) DP(integer 2) power(integer 0)]
		
			tempname outmatrix
			qui estimates restore `estimates'
			qui margins `catreg', predict(xb) `grand' l(`olevel')
			mat `outmatrix' = r(table)'
			
			local rnames :rownames `outmatrix'
			local nrows = rowsof(`outmatrix')
			mat `outmatrix' = `outmatrix'[1..`nrows', 1..6]

			local rownames = ""
			local rspec = "-" /*draw lines or not between the rows*/
			local rownamesmaxlen = 10 /*Default*/
			
			if "`expit'" != "" {
				forvalues r = 1(1)`nrows' {
					mat `outmatrix'[`r', 1] = invlogit(`outmatrix'[`r', 1])
					mat `outmatrix'[`r', 5] = invlogit(`outmatrix'[`r', 5])
					mat `outmatrix'[`r', 6] = invlogit(`outmatrix'[`r', 6])
				}
			}			
			if "`grand'" == "" {
				local nrowss = `nrows'
			}
			else {
				local nrowss = `nrows' - 1
			}
			forvalues r = 1(1)`nrowss' {
				if `r' == 1 {
					local rspec = "`rspec'-"
				}
				else{
					local rspec = "`rspec'&"
				}
				local rname`r':word `r' of `rnames'
				
				tokenize `rname`r'', parse(".")
				if strpos("`rname`r''", "1bn") == 0 {
					local lab:label `3' `1'
				} 
				else {
					local lab:label `3' 1
				}
				local lab = ustrregexra("`lab'", " ", "_")
				local rownames = "`rownames' `3':`lab'"
				local nlenlab : strlen local lab
				local nlencov : strlen local `3'
				local rownamesmaxlen = max(`rownamesmaxlen', min(`=`nlenlab' + `nlencov' + 1', 32)) /*Check if there is a longer name*/
			}
			if "`grand'" == "" {
				local rspec = "`rspec'-" /*Last line*/
			}
			else {
				if `nrows' == 1 {
					local rspec = "`rspec'--" /*Last line*/
				}
				else {
					local rspec = "`rspec'&-" /*Last line*/
				}
				local rownames = "`rownames' :Overall"
			}
			mat rownames `outmatrix' = `rownames'
			if "`expit'" != "" {
				mat colnames `outmatrix' = `sumstat' SE(logit) z(logit) P>|z|(logit) Lower Upper
			}
			else {
				mat colnames `outmatrix' = `sumstat' SE z P>|z| Lower Upper
			}
			if "`print'" == "" {
				local nlensstat : strlen local sumstat
				local nlensstat = max(10, `nlensstat')
				di as res _n "****************************************************************************************"
				di as res "{pmore2} Conditional summary measures of test accuracy : `sumstat' {p_end}"
				di as res    "****************************************************************************************" 
				tempname mat2print
				mat `mat2print' = `outmatrix'
				local nrows = rowsof(`mat2print')
				forvalues r = 1(1)`nrows' {
					mat `mat2print'[`r', 1] = `mat2print'[`r', 1]*10^`power'
					mat `mat2print'[`r', 5] = `mat2print'[`r', 5]*10^`power'
					mat `mat2print'[`r', 6] = `mat2print'[`r', 6]*10^`power'
				}
				#delimit ;
				noi matlist `mat2print', rowtitle(Covariate) 
							cspec(& %`rownamesmaxlen's |  %`nlensstat'.`=`dp''f &  %9.`=`dp''f &  %8.`=`dp''f &  %15.`=`dp''f &  %8.`=`dp''f &  %8.`=`dp''f o2&) 
							rspec(`rspec') underscore
				;
				#delimit cr
			}
		return matrix outmatrix = `outmatrix'
	end
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: ESTR +++++++++++++++++++++++++
							Estimate RR after modelling
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop estr
	program define estr, rclass
	version 14.1
		syntax, estimates(string) [catreg(varlist) sumstat(string) noprint paired olevel(integer 95) DP(integer 2) power(integer 0)]
		
		local ZOVE -invnorm((100-`olevel')/200)
		
		qui estimates restore `estimates'
		if "`catreg'" == "" {
			exit
		}
		tokenize `catreg'
		if "`paired'" != "" {
			local VarX `1'
			macro shift 1
		}
		
		local marginexpr `*'
		
		local rownames = ""
		local rspec = "-" /*draw lines or not between the rows*/
		local rownamesmaxlen = 10 /*Default*/
		
		tempname lcoef lV outmatrix
		
		if "`marginexpr'" != "" {
			qui margins `marginexpr', predict(xb) over(`VarX') post
			
			local EstRlnexpression
			foreach c of local marginexpr {	
				qui label list `c'
				local nlevels = r(max)
				if "`paired'" != "" {
					forvalues l = 1/`nlevels' {
						local EstRlnexpression = "`EstRlnexpression' (`c'_`l': ln(invlogit(_b[2.`VarX'#`l'.`c'])) - ln(invlogit(_b[1.`VarX'#`l'.`c'])))"	
					}
				}
				else {
					forvalues l = 2/`nlevels' {
						local EstRlnexpression = "`EstRlnexpression' (`c'_`l': ln(invlogit(_b[`l'.`c'])) - ln(invlogit(_b[1.`c'])))"	
					}
				}
			}
						
			qui nlcom `EstRlnexpression'
			
			mat `lcoef' = r(b)
			mat `lV' = r(V)
			mat `lV' = vecdiag(`lV')
			
			local ncols = colsof(`lcoef') /*length of the vector*/
			
			local rnames :colnames `lcoef'
			
			if "`paired'" != "" {
				mat `outmatrix' = J(`=`ncols' + 1', 6, .)
			}
			else {
				mat `outmatrix' = J(`ncols', 6, .)
			}
			local ncols = colsof(`lcoef') /*length of the vector*/
			forvalues r = 1(1)`ncols' {
				mat `outmatrix'[`r', 1] = exp(`lcoef'[1,`r']) /*Estimate*/
				mat `outmatrix'[`r', 2] = sqrt(`lV'[1, `r']) /*se in log scale, power 1*/
				mat `outmatrix'[`r', 3] = `lcoef'[1,`r']/sqrt(`lV'[1, `r']) /*Z in log scale*/
				mat `outmatrix'[`r', 4] =  normprob(-abs(`outmatrix'[`r', 3]))*2 /*p-value*/
				mat `outmatrix'[`r', 5] = exp(`lcoef'[1, `r'] - `ZOVE' * sqrt(`lV'[1, `r'])) /*lower*/
				mat `outmatrix'[`r', 6] = exp(`lcoef'[1, `r'] + `ZOVE' * sqrt(`lV'[1, `r'])) /*upper*/
				
				if `r' == 1 {
					local rspec = "`rspec'-"
				}
				else {
					local rspec = "`rspec'&"
				}
				local rname`r':word `r' of `rnames'
				
				tokenize `rname`r'', parse("_")
				local lab:label `1' `3'
				local lab = ustrregexra("`lab'", " ", "_")
				local nlen : strlen local lab
				local rownamesmaxlen = max(`rownamesmaxlen', min(`nlen', 32)) /*Check if there is a longer name*/

				local lab = ustrregexra("`lab'", " ", "_")
				local rownames = "`rownames' `1':`lab'"
			}
		}
		else {
			mat `outmatrix' = J(1, 6, .)
			local ncols = 0
		}
		if "`paired'" != "" {
			qui estimates restore `estimates'
			*local VarX bcg
			qui margins `VarX', predict(xb) post
					
			//log metric
			qui nlcom (Rp_2_1: ln(invlogit(_b[2.`VarX'])) - ln(invlogit(_b[1.`VarX'])))
			mat `lcoef' = r(b)
			mat `lV' = r(V)
			
			mat `outmatrix'[`=`ncols' + 1', 1] = exp(`lcoef'[1, 1])  //rr
			mat `outmatrix'[`=`ncols' + 1', 2] = sqrt(`lV'[1,1]) //se
			mat `outmatrix'[`=`ncols' + 1', 3] = `lcoef'[1, 1]/sqrt(`lV'[1,1]) //zvalue
			mat `outmatrix'[`=`ncols' + 1', 4] = normprob(-abs(`lcoef'[1, 1]/sqrt(`lV'[1,1])))*2 //pvalue
			mat `outmatrix'[`=`ncols' + 1', 5] = exp(`lcoef'[1,1] - `ZOVE'*sqrt(`lV'[1,1])) //ll
			mat `outmatrix'[`=`ncols' + 1', 6] = exp(`lcoef'[1,1] + `ZOVE'*sqrt(`lV'[1,1])) //ul
			/* Next improvement, left asis on 5th April 2019
			if "`conditional'" == "" {
				widesetup
			}
			*/
			if `ncols' == 0 {
				local rspec = "`rspec'--" /*Last line*/
			}	
			else {
				local rspec = "`rspec'&-" /*Last line*/
			}
			local rownames = "`rownames' :Overall"
		}
		else {
			local rspec = "`rspec'-" /*Last line*/
		}
		
		mat colnames `outmatrix' = `sumstat' SE(log) z(log) P>|z|(log) Lower Upper
		mat rownames `outmatrix' = `rownames'
		local nlensstat : strlen local sumstat
		local nlensstat = max(8, `nlensstat')
		if "`print'" == "" {
			di as res _n "****************************************************************************************"
			di as res "{pmore2} Conditional summary measures of test accuracy : `sumstat' {p_end}"
			di as res    "****************************************************************************************" 
			tempname mat2print
			mat `mat2print' = `outmatrix'
			local nrows = rowsof(`mat2print')
			forvalues r = 1(1)`nrows' {
				mat `mat2print'[`r', 1] = `mat2print'[`r', 1]*10^`power'
				mat `mat2print'[`r', 5] = `mat2print'[`r', 5]*10^`power'
				mat `mat2print'[`r', 6] = `mat2print'[`r', 6]*10^`power'
			}
			#delimit ;
			noi matlist `mat2print', rowtitle(Confounder) 
						cspec(& %`rownamesmaxlen's |  %`nlensstat'.`=`dp''f &  %8.`=`dp''f &  %8.`=`dp''f &  %13.`=`dp''f &  %8.`=`dp''f &  %8.`=`dp''f o2&) 
						rspec(`rspec') underscore
			;
			#delimit cr
		}
		return matrix outmatrix = `outmatrix'
	end
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: BOOTREP +++++++++++++++++++++++++
							Parametric bootstrapping
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop bootrep
	program define bootrep, rclass
	version 14.1

		syntax, gid(varname) Total(varname) model(string) seed(integer) [regexpression(string) regressors(varlist) outplot(string) paired modelopts(string asis) cci(varname) rfdist conditional overall olevel(integer 95)]
		qui {
			/*local seed 1
			local model fixed
			local paired paired
			local gid study
			local total dis
			local regressors "sample setting"
			local u_b u_b
			local cci sample
			local VarX sample
			local outplot "rr"
			local t_b t_b
			local pi_b "pi_b"
			local pred_sigma "pred_sigma"
			local pred_nu "pred_nu"
			local pred_sigma_u "pred_sigma_u"
			local pred_u_b "pred_u_b"
			local pred_sigma_t "pred_sigma_t"
			local pred_t_b "pred_t_b"
			local pred_nu "pred_nu"
			local pred_pi_b "pred_pi_b"
			local n_b "n_b"
			local pred_n_b "pred_n_b"
			*/			
			
			//parametric bootstrap		
			local ncols = colsof(Ocoef)
			if ("`model'" == "fixed" & "`paired'" != "") | ("`model'" == "random" & "`paired'" == "") {
				local mu_lnsigma_u = Ocoef[1,`ncols']
				local sd_lnsigma_u = sqrt(VOcoef[`ncols', `ncols']) 
			}
			if ("`model'" == "random" & "`paired'" != "") {
				//between study variance
				local mu_lnsigma_u = Ocoef[1,`=`ncols'-1']
				local sd_lnsigma_u = sqrt(VOcoef[`=`ncols'-1', `=`ncols'-1']) 
				
				//between treatment group variance
				local mu_lnsigma_t = Ocoef[1,`ncols']
				local sd_lnsigma_t = sqrt(VOcoef[`ncols', `ncols']) 
			}
			//generate the normal random effects per study
			set seed `seed'
			tempname u_b
			bys `gid': gen `u_b' = rnormal(0, `=exp(`mu_lnsigma_u')') if _n == 1
			bys `gid': replace `u_b' = `u_b'[1]
			
			if ("`model'" == "random" & "`paired'" != "") {
				//generate the normal random effects per treatment group
				set seed `seed'
				tempname t_b
				bys `cci': gen `t_b' = rnormal(0, `=exp(`mu_lnsigma_t')') if _n == 1
				bys `cci': replace `t_b' = `t_b'[1]
				
				tempname pi_b
				gen `pi_b' = invlogit(nu + `u_b' + `t_b')
			}
			else {
				tempname pi_b
				gen `pi_b' = invlogit(nu + `u_b')
			}
			local Nobs = _N
			if "`rfdist'" != "" {
				//Generate the variance parameter
				set seed `seed'
				tempname pred_sigma_u
				gen `pred_sigma_u' = exp(rnormal(`mu_lnsigma_u', `sd_lnsigma_u')) in 1
				replace `pred_sigma_u' = `pred_sigma_u'[1]
				
				set seed `seed'
				tempname pred_u_b
				bys `gid': gen `pred_u_b' = rnormal(0, `pred_sigma_u') if _n == 1
				bys `gid': replace `pred_u_b' = `pred_u_b'[1]
				
				if ("`model'" == "random" & "`paired'" != "") {
					//Generate the second variance parameter
					set seed `seed'
					tempname pred_sigma_t
					gen `pred_sigma_t' = exp(rnormal(`mu_lnsigma_t', `sd_lnsigma_t')) in 1
					replace `pred_sigma_t' = `pred_sigma_t'[1]
					
					set seed `seed'
					tempname pred_t_b
					bys `cci': gen `pred_t_b' = rnormal(0, `pred_sigma_t') if _n == 1
					bys `cci': replace `pred_t_b' = `pred_t_b'[1]
				}
					
				//generate the linear predictor
				tempname pred_nu
				gen `pred_nu' = .
				forvalues r = 1/`Nobs' {
					set seed `seed'
					qui replace `pred_nu' = rnormal(nu, sigma_nu) in `r'	
				}
				 
				
				if ("`model'" == "random" & "`paired'" != "") {
					tempname pred_pi_b
					gen `pred_pi_b' = invlogit(`pred_nu' + `pred_u_b' + `pred_t_b')
					replace `pred_pi_b' = invlogit(`pred_nu' + `pred_u_b') if (`pred_u_b' !=.) & (`pred_t_b' == .)
					replace `pred_pi_b' = invlogit(`pred_nu' + `pred_t_b') if (`pred_u_b' ==.) & (`pred_t_b' != .)
					replace `pred_pi_b' = invlogit(`pred_nu') if (`pred_u_b'== .) & (`pred_t_b' == .)
				}
				else{
					tempname pred_pi_b
					gen `pred_pi_b' = invlogit(`pred_nu' + `pred_u_b')
					replace `pred_pi_b' = invlogit(`pred_nu') if `pred_u_b' == .
				}
			}
			//Generate the binomial outcome
			if "`rfdist'" == "" {
				tempname n_b
				gen `n_b' = .
				forvalues r = 1/`Nobs' {
					set seed `seed'
					qui replace `n_b' = rbinomial(`total', `pi_b') in `r'
				}
			}
			if "`rfdist'" != "" {
				tempname pred_n_b
				gen `pred_n_b' = .
				forvalues r = 1/`Nobs' {
					set seed `seed'
					qui replace `pred_n_b' = rbinomial(`total', `pred_pi_b') in `r'
				}
			}
		}
		if "`rfdist'" == "" {
			//fit the model with fixed efects
			*noi list `n_b' `total', noobs clean
			qui logitreg `n_b' `total' `regressors', regexpression(`regexpression') model(`model') sid(`gid') `paired' modelopts(`modelopts') cci(`cci') olevel(`olevel')
			
			if "`overall'" == "" {
				margmean,  model(`model') over(`regressors') gid(`gid') outplot(`outplot') `paired'
			}
			else {
				local VarX: word 1 of `regressors' 
				margmean,  model(`model') over(`VarX') gid(`gid') outplot(`outplot') `paired'
			}
		}

		if "`rfdist'" != "" {
			//fit the model treating fixed effects as random
			*noi list `pred_n_b' `total', noobs clean
			qui logitreg `pred_n_b' `total' `regressors', regexpression(`regexpression') model(`model') sid(`gid') `paired' modelopts(`modelopts') cci(`cci') olevel(`olevel')
			
			if "`conditional'" == "" {
				if "`overall'" == "" {
					margmean,  model(`model') over(`regressors') gid(`gid') outplot(`outplot') `paired'
				}
				else {
					local VarX: word 1 of `regressors' 
					margmean,  model(`model') over(`VarX') gid(`gid') outplot(`outplot') `paired'
				}
			}
			if "`conditional'" != "" & "`outplot'" == "rr"  {
				if "`overall'" == "" {
					estr, matrix(bpred)
					local nlevs = rowsof(bpred)
				}
				else {
					local nlevs = 2
					local VarX: word 1 of `regressors'
					margins `VarX', predict(xb) post
					nlcom (Rp_2_1: ln(invlogit(_b[2.`VarX'])) - ln(invlogit(_b[1.`VarX'])))
					
					mat blcoef = r(b)
					mat blV = r(V)
				}
			}
			
		}
		if ("`conditional'" == "") {
			forvalues r=1/`nlevs' {
				return scalar mmean`r' = r(mmean`r')
			}
		}
		if "`conditional'" != "" & "`outplot'" == "rr" {
			if "`overall'" == "" {
				forvalues r=1/`nlevs' {
					return scalar mmean`r' = bpred[`r', 1]
				}
			}
			else {
				return scalar mmean1 = 1
				return scalar mmean2 = exp(blcoef[1, 1]) //rr
			}
		}
		
	end
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: MARGMEAN +++++++++++++++++++++++++
								Mean computation
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop margmean
	program define margmean, rclass
	version 14.1
		syntax, gid(varname) model(string) [over(varlist) outplot(string) paired]
		cap drop nu_b
		predict nu_b, xb
		
		cap drop pi_int
		gen pi_int = .
		
		tempname gindex
		egen `gindex' = group(`gid')
		summ `gindex'
		local len = r(N)
		
		if ("`model'" == "fixed" & "`paired'" != "") | ("`model'" == "random" & "`paired'" == "") {
			mata: numint_fe(`len')
		}
		else{
			mata: numint_re(`len')
		}
		mean pi_int, over(`over', nolab)
		mat mmean = e(b)
		mat vmmean = e(V)
		local nbpar = colsof(mmean)  
		
		
		if "`outplot'" == "rr" {
			if `nbpar' > 2 {
				local nlevs = `nbpar'/2
				forvalues l=1/`nlevs' {
					local mmean`l' = mmean[1,`=`l' + `nlevs'']/mmean[1,`l']
				}
			}
			else {
				local nlevs = `nbpar'
				forvalues l=1/`nlevs' {
					local mmean`l' = mmean[1,`l']/mmean[1,1]
				}
			}
		}
		else {
			local nlevs = `nbpar'
			forvalues l=1/`nlevs' {
				local mmean`l' = mmean[1,`l']
			}
		}

		forvalues r=1/`nlevs' {
			return scalar mmean`r' = `mmean`r''
		}
		return matrix mmean = mmean
		return matrix vmmean = vmmean
	end
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: BOOTPROPS +++++++++++++++++++++++++
								Bootstrap replications
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop bootprops
	program define bootprops, rclass
	version 14.1

		syntax , gid(varname) Total(varname) model(string) nlevs(string) [regexpression(string)  outplot(string) regressors(varlist) breps(integer 1000) paired cci(varname) rfdist conditional overall olevel(integer 95)]
		mata: bootmmean = J(`breps', `nlevs', .)
		di as txt "Simulations (" as res `breps' as txt ")"
		local unsucb = 0
		forvalues b = 1/`breps' {
			set seed `b'
			capture bootrep, regexpression(`regexpression') regressors(`regressors') seed(`b') gid(`gid') total(`total') model(`model') `paired' cci(`cci') `rfdist' `conditional' outplot(`outplot') `overall' olevel(`olevel')
			if (_rc != 0) {
				di as error "x" _cont
				local ++unsucb
				continue			
			} 
			forvalues p=1/`nlevs' {
				mata: mmean = st_numscalar("r(mmean`p')")
				mata: bootmmean[`b', `p'] = mmean
			}

			noi _dots `b' 0
		}
		mata: st_matrix("bootmmean", bootmmean)
		preserve
		qui svmat bootmmean, names(bootmmean)
		if `nlevs' == 1 {
			_pctile bootmmean, p(`=100-`olevel'', `=`olevel'')
			mat ci = (r(r1), r(r2))
		}
		else {
			mat ci = J(`nlevs', 2, .)
			forvalues l = 1/`nlevs' {
				_pctile bootmmean`l', p(`=100-`olevel'', `=`olevel'')
				mat ci[`l',1] = r(r1)
				mat ci[`l',2] = r(r2)
			}
		}
		di _n as res   `=`breps'-`unsucb'' as txt "/" as res `breps' as txt " Simulations successful."
		return matrix ci = ci
		restore
	end
	
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: STATLABEL +++++++++++++++++++++++++
								Link the labels for the stats
	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop statlabel
	cap program drop statlabel
	program define statlabel, rclass
	version 14.1
		syntax, [raw(string asis) logodds(string asis) abs(string asis) rr(string asis)]

		if "`raw'" !="" {
			return local labraw = "`raw'"
		}
		else {
			return local labraw = "raw_coeff"
		}
		if "`logodds'" !="" {
			return local lablodds = "`logodds'"
		}
		else {
			return local lablodds = "Log_odds"
		}
		if "`abs'" !="" {
			return local lababs = "`abs'"
		}
		else {
			return local lababs = "Proportion"
		}
		if "`rr'" !="" {
			return local labrr = "`rr'"
		}
		else {
			return local labrr = "Rel_Ratio"
		}
	end
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: METAPREG_PROPCI +++++++++++++++++++++++++
								CI for proportions
	++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop metapreg_propci
	program define metapreg_propci
	version 14.1

		syntax varlist [if] [in], p(name) lowerci(name) upperci(name) [cimethod(string) level(real 95)]
		
		qui {	
			tokenize `varlist'
			gen `p' = .
			gen `lowerci' = .
			gen `upperci' = .
			
			count `if' `in'
			forvalues i = 1/`r(N)' {
				local N = `1'[`i']
				local n = `2'[`i']

				cii proportions `N' `n', `cimethod' level(`level')
				
				replace `p' = r(proportion) in `i'
				replace `lowerci' = r(lb) in `i'
				replace `upperci' = r(ub) in `i'
			}
		}
	end
	
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: 	KOOPMANCI +++++++++++++++++++++++++
								CI for RR
	++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop koopmanci
	program define koopmanci
	version 14.1

		syntax varlist, RR(name) lowerci(name) upperci(name) [alpha(real 0.05)]
		
		qui {	
			tokenize `varlist'
			gen `rr' = . 
			gen `lowerci' = .
			gen `upperci' = .
			
			count
			forvalues i = 1/`r(N)' {
				local n1 = `1'[`i']
				local N1 = `2'[`i']
				local n2 = `3'[`i']
				local N2 = `4'[`i']

				koopmancii `n1' `N1' `n2' `N2', alpha(`alpha')
				mat ci = r(ci)
				
				if (`n1' == 0) &(`n2'==0) {
					replace `rr' = 0 in `i'
				}
				else {
					replace `rr' = (`n1'/`N1')/(`n2'/`N2')  in `i'	
				}
				replace `lowerci' = ci[1, 1] in `i'
				replace `upperci' = ci[1, 2] in `i'
			}
		}
	end
	
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: KOOPMANCII +++++++++++++++++++++++++
								CI for RR
	++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop koopmancii
	program define koopmancii, rclass
	version 14.1
		syntax anything(name=data id="data"), [alpha(real 0.05)]
		
		local len: word count `data'
		if `len' != 4 {
			di as error "Specify full data: n1 N1 n2 N2"
			exit
		}
		
		foreach num of local data {
			cap confirm integer number `num'
			if _rc != 0 {
				di as error "`num' found where integer expected"
				exit
			}
		}
		
		tokenize `data'
		cap assert ((`1' <= `2') & (`3' <= `4'))
		if _rc != 0{
			di as err "Order should be n1 N1 n2 N2"
			exit _rc
		}
		
		mata: koopman_ci((`1', `2', `3', `4'), `alpha')
		
		return matrix ci = ci
		return scalar alpha = `alpha'	

	end
	
	/*+++++++++++++++++++++++++	SUPPORTING FUNCTIONS: metapregsummary +++++++++++++++++++++++++
								Keep all the summaries together
	++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	cap program drop metapregsummary
	program define metapregsummary, rclass
	version 14.1
		#delimit ;
		syntax , 
			ma_first_model(string) 
			ma_first_es(string)
			ma_first_se_es(string)
			ma_first_lci(string)
			ma_first_uci(string)
			ma_first_z(string)
			ma_first_p_z(string)
			ma_first_het(string)
			ma_first_df(string)
			ma_first_p_het(string)
			ma_first_chi2(string)
			ma_first_pchi2(string)
			ma_first_tau2(string)
			ma_first_wtau2(string)
			ma_first_i2(string) 
			
			hmean(string)
			[
			
			ma_second_model(string) 
			ma_second_es(string)
			ma_second_se_es(string)
			ma_second_lci(string)
			ma_second_uci(string)
			ma_second_z(string)
			ma_second_p_z(string)
			ma_second_het(string)
			ma_second_df(string)
			ma_second_p_het(string)
			ma_second_chi2(string)
			ma_second_pchi2(string)
			ma_second_tau2(string)
			ma_second_wtau2(string)
			ma_second_i2(string)
			
			ma_first_raw(name)
			ma_first_logodds(name)
			ma_first_absout(name)
			ma_first_rrout(name)
			ma_first_predci(name)
			ma_first_opredci(name)
			
			ma_second_raw(name)
			ma_second_logodds(name)
			ma_second_absout(name)
			ma_second_rrout(name)
			ma_second_predci(name)
			ma_second_opredci(name)
			];
		#delimit cr
		
		return local ES 			= `ma_first_es' 		
		return local seES 			= `ma_first_se_es'
		return local ci_low 		= `ma_first_lci' 
		return local ci_upp 		= `ma_first_uci'
		return local z 				= `ma_first_z' 
		return local p_z			= `ma_first_p_z'
		return local het 			= `ma_first_het' 
		return local df 			= `ma_first_df' 
		return local p_het			= `ma_first_p_het' 
		return local chi2			= `ma_first_chi2'
		return local p_chi2			= `ma_first_pchi2'
		return local tau2			= `ma_first_tau2' 
		return local wtau2   		= `ma_first_wtau2' 
		return local i_sq			= `ma_first_i2' 
		return local model 			= "`ma_first_model'"		
		
		return local hmean 			= `hmean'
		
		if "`ma_second_model'" != "" {
			return local ES_2 		= `ma_second_es' 		
			return local seES_2 	= `ma_second_se_es'
			return local ci_low_2 	= `ma_second_lci' 
			return local ci_upp_2 	= `ma_second_uci'
			return local z_2 		= `ma_second_z' 
			return local p_z_2		= `ma_second_p_z'
			return local het_2 		= `ma_second_het' 
			return local df_2 		= `ma_second_df' 
			return local p_het_2	= `ma_second_p_het' 
			return local chi2_2		= `ma_second_chi2'
			return local p_chi2_2	= `ma_second_pchi2'
			return local tau2_2		= `ma_second_tau2' 
			return local wtau2_2   	= `ma_second_wtau2' 
			return local i_sq_2		= `ma_second_i2' 
			return local model_2   	= "`ma_second_model'"
		}
		
		cap confirm matrix `ma_first_raw'
		if _rc == 0 {
			return matrix raw = `ma_first_raw'
		}
		cap confirm matrix `ma_first_logodds'
		if _rc == 0 {
			return matrix logodds = `ma_first_logodds'
		}
		
		cap confirm matrix `ma_first_absout'
		if _rc == 0 {
			return matrix absout = `ma_first_absout'
		}
			
		cap confirm matrix `ma_first_rrout'
		if _rc == 0 {
			return matrix rrout = `ma_first_rrout'
		}
		cap confirm matrix `ma_first_predci'
		if _rc == 0 {
			return matrix predci = `ma_first_predci'
		}
		cap confirm matrix `ma_first_opredci'
		if _rc == 0 {
			return matrix opredci = `ma_first_opredci'
		}
			cap confirm matrix `ma_second_raw'
		if _rc == 0 {
			return matrix raw_2 = `ma_second_raw'
		}
		cap confirm matrix `ma_second_logodds'
		if _rc == 0 {
			return matrix logodds_2 = `ma_second_logodds'
		}
		
		cap confirm matrix `ma_second_absout'
		if _rc == 0 {
			return matrix absout_2 = `ma_second_absout'
		}
			
		cap confirm matrix `ma_second_rrout'
		if _rc == 0 {
			return matrix rrout_2 = `ma_second_rrout'
		}
		cap confirm matrix `ma_second_predci'
		if _rc == 0 {
			return matrix predci_2 = `ma_second_predci'
		}
		cap confirm matrix `ma_second_opredci'
		if _rc == 0 {
			return matrix opredci_2 = `ma_second_opredci'
		}
		
	end
exit

