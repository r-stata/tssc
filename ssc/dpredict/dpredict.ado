*! version 1.7 16july2006

program define dpredict, rclass
	version 9.0


	_on_colon_parse `0'	// parse the whole input in two macros `s(after)' `s(before)'
					// `s(after)' contains the part after the colon, `s(before)' the rest

	local command `"`s(after)'"'
	local 0 `"`s(before)'"'		//the macro `0' will be parsed by the syntax command below

	_prefix_command dpredictn :`command' //parse the `command' macro into `s(...)' macros

	local cmd		`"`s(command)'"'
	local cmdname   	`"`s(cmdname)'"'
	local cmdargs   	`"`s(anything)'"'
	local cmdif     	`"`s(if)'"'
	local cmdopts   	`"`s(options)'"'

	tokenize `cmdargs'	
	local count_arima_args=1		// count the number of variables going to arima (incl. the dependent)
	while "``count_arima_args''" ~= "" {
		local ++count_arima_args
	}
	local --count_arima_args


	if ("`cmdname'"!="arima") {
		di as error "dpredict supports only arima (`s(cmdname)' not supported)"
		exit 199
	}

	syntax [varlist(default=none)], From(numlist >0 max=1 integer) To(numlist >0 max=1 integer) Periods(numlist>0 max=1 integer) [NORecursive] [THReshold(real 0)] [Lvl]

	tokenize `varlist'	
	local count_var_args=1		// count the number of variables supplied to dpredict
	while "``count_var_args''" ~= "" {
		local ++count_var_args
	}
	local --count_var_args

	if (`threshold'<0) {
		di as error "The threshold parameter must be non-negative."
		exit 199
	}

	if (`from'>`to') {
		di as error "The from-parameter must be smaller or equal to the to-parameter."
		exit 199
	}

	disp _newline,, as txt"Pre-run summary:"	
	disp as input "Running dynamic predictions on: " as txt "`command'"as input "."
	disp as input "Out-of-sample prediction horizon: " as txt "`periods'" as input "."
	if "`norecursive'"=="" {
		disp as input "Subsamples from " as txt "1/`from'" as input " to " as txt "1/" min(`to',_N-`periods') as input" (growing window size; norecursive-option not specified)."
	}
	else {
		disp as input "Subsamples from " as txt "1/`from'" as input " to " as txt  min(`to',_N-`periods')- `from' + 1 "/" min(`to',_N-`periods') as input" (fixed window size; norecursive-option specified)."
	}
	if ("`lvl'"=="") {
		di as error "Warning: " as input "Lvl-option not specified, the forecast statistics will be computed assuming that the dependent variable is in " as txt "`periods'" as input "-period differences (after applying all specified time-series and arima(.,d,.) operators)."
	}
	

	local use_actual = 0
	if (`count_arima_args'~=`count_var_args') {
		if (`count_var_args'>0) {
			di as error "Warning: " as input "Number of vars supplied to dpredict isn't equal to the number of arima variables. Using actual values."
		}
		local use_actual = 1
	}


	tempvar yhat res dep 
	tempname pred_var doc_var res_var 

	mat `pred_var' = J(_N,1,.)
	mat `doc_var' = J(_N,1,.)
	mat `res_var' = J(_N,1,.)

	local rmse = 0
	local mae  = 0
	local doc  = 0

	local count=0
	local count_doc=0
	local start = 1
	local j=`from'

	while `j'<=min(`to',_N-`periods') {		//run only until `periods'-ahead predictions can be computed		


		if (~`use_actual') {			// replace the last observation of each variable by the supplied predicted var
			preserve				// need to preserve, since variables from the dataset are changed
			tokenize `varlist' `cmdargs' 
			local counter=1
			while `counter'<=`count_var_args' {
				local pos = `count_var_args'+`counter'
					tsrevar ``pos'' , list
				qui replace `r(varlist)'=``counter'' in `j'
				local ++counter
			}
		}
	
		if ("`norecursive'"~="") {
			local start  = `start' + 1
		}

		capture: arima `cmdargs' `cmdif' in `start'/`j', `cmdopts'		//run the arima - estimation 

		if _rc{								//if the arima produced an error exit the program
			di as err"Error: "as input"Executing the command " as txt "arima `cmdargs' `cmdif' in 1/`j', `cmdopts'" as input " produced an error (code " _rc "):"
			di as input"See the help for an explanation of the error code and the help for the arima command."
			err _rc		
		}		

		quietly: predict `res' , residuals dynamic(e(tmax)+1)
 		quietly: predict `yhat',  dynamic(e(tmax)+1)

		local pos = `j' + `periods'					//need to define this, the "in #" doesnt accept expressions in place of #

		mat `pred_var'[`pos',1]=`yhat'[`pos']	// save the current prediction and residual (these will be returned as matrices)
		mat `res_var'[`pos',1] =`res'[`pos']

		if (`yhat'[`pos']>=.)  {							// sometimes the prediction is null (e.g. when the indep vars needed for
			disp as input" - Warning: Null-prediction encountered -.",,_continue	// the prediction are null)
		}
		else if (`res'[`pos']>=.) {							//and sometimes the residual is null
			disp as input " - Warning: Null-residual encountered -.",,_continue		//exclude both of this cases for computing the forecast stats
		}
		else {
			tsrevar `e(depvar)'	//strip the time-series operator from the dependent var, name of the temporary var is saved in r(varlist)

			if ("`lvl'"~="") {	//if the lvl options is given transform the prediction,yhat, and dependent variable,r(varlist), to differences, such that same code can be used as when lvl is not specified
				qui gen `dep' = s`periods'.`r(varlist)'
				qui replace `yhat' = `yhat' - l`periods'.`r(varlist)' in `pos'
			}
			else {
				qui gen `dep' = `r(varlist)'
			}

			if (`dep'[`pos'])*(`yhat'[`pos'])>`threshold'{ // check the direction of change
				local ++doc					// count the correctly predicted directions
				mat `doc_var'[`pos',1]=1			// direction predicted correctly
				local ++count_doc

			}
			else if (`dep'[`pos'])*(`yhat'[`pos'])<(-`threshold') {
				mat `doc_var'[`pos',1]=0
				local ++count_doc
			}
	
			local mae=`mae' + abs(`res'[`pos'])
			local rmse=`rmse' + (`res'[`pos'])^2

			disp ".",,_continue
			local ++count						// count the non-null predictions

		}

		cap drop `dep'
		cap drop `yhat' `res' 	// need to drop these, otherwise predict complains
		local ++j
		if (~`use_actual') restore

	}


	local rmse=sqrt(`rmse' / `count')
	local mae=`mae' / `count'
	local doc=`doc' / `count_doc'

	di _newline,,as txt"After-run summary:"

	di as input"dpredict `0' : `command'"

	disp "//The RMSE is: " `rmse'
	disp "//The MAE is:  " `mae'
	disp "//The DOC is:  " `doc'

	return matrix Yhat = `pred_var'
	return matrix DOCmat  = `doc_var'
	return matrix ResMat  = `res_var'

	return local RMSE = `rmse'
	return local MAE = `mae'
	return local DOC = `doc'


end
