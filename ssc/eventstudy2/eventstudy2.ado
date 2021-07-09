*eventstudy2.ado - performs state-of-the art event studies with raw returns or (multi)factor models and calculates various test statistics in Mata
*! version 3.0 T Kaspereit Nov2019

* Models in this version of eventstudy2:
	* No specification selected or "RAW"	-> 	Raw returns
	* "COMEAN"								-> 	Constant mean model
	* "MA" 									->	Market adjusted returns
	* "FM" 									-> 	Factor model, e.g. market model or Fama-French or Carhart model 
	* "BHAR"								->	Buy-and hold returns against index returns
	* "BHAR_raw"							->  Buy-and hold returns
	
capture: program drop eventstudy2
program define eventstudy2

quietly{
	version 12

	set more off
	capture: log close

	preserve

	syntax varlist(min=2 max=2) using [if] [in], RETurns(str asis) [DIAGnosticsfile(str asis) GRAPHfile(str asis) AARfile(str asis) CARfile(str asis) ARfile(str asis) CROSSfile(str asis) REPLACE MODel(str asis) MARKETFILE(str asis) MARketreturns(str asis) IDMARket(str asis) FACTOR1(str asis) FACTOR2(str asis) FACTOR3(str asis) FACTOR4(str asis) FACTOR5(str asis) FACTOR6(str asis) FACTOR7(str asis) FACTOR8(str asis) FACTOR9(str asis) FACTOR10(str asis) RISKfreerate(str asis) Prices(str asis) TRADINGvolume(str asis) EVWLB(int -20) EVWUB(int 20) ESWLB(int -270) ESWUB(int -21) MINEVW(int 1) MINESW(int 30) CAR1LB(int -20) CAR1UB(int 20) CAR2LB(int -20) CAR2UB(int 20) CAR3LB(int -20) CAR3UB(int 20) CAR4LB(int -20) CAR4UB(int 20) CAR5LB(int -20) CAR5UB(int 20) CAR6LB(int -20) CAR6UB(int 20) CAR7LB(int -20) CAR7UB(int 20) CAR8LB(int -20) CAR8UB(int 20) CAR9LB(int -20) CAR9UB(int 20) CAR10LB(int -20) CAR10UB(int 20) LOGreturns THIN(real 0.00) FILL NOKOLari DELweekend DATELINEthreshold(real 0.00) SHIFT(int 3) GARCH ARCHOption(str asis) GARCHOption(str asis) ARCHIterate(int 20) PARAllel PCLUSters(int 2) PROCessors(int 0) PARAPath(str asis) ARFILLEStimation ARFILLEVent SAVERAM CROSSONLY]
		
		
	* Ensuring that all user-written commands are installed:
	
	capture mata: mm_meancolvar(1)
		if _rc == 3499 {
			di as error "Please install the user-written program moremata before running eventstudy2 (type > ssc install moremata < in the command line)"
			exit = 3499
		}
	
	foreach p in nearmrg distinct _gprod rmse parallel{
		capture `p'
			if _rc == 199 {
				di as error "Please install the user-written program `p' before running eventstudy2 (type > ssc install `p' < in the command line)"
				exit = 199
			}
	}
	
	
	if "`parallel'" == "parallel"{
	
		parallel setclusters `pclusters'

		if "`parapath'" != ""{
			capture: confirm file "`parapath'/eventstudy2_parallel.do"
			
			tempname flash
			local `flash' = "/" 
			
			if _rc != 0{
				local parapath = c(sysdir_plus)
				local parapath = "`parapath'" + "e"
				capture: confirm file "`parapath'/eventstudy2_parallel.do"
				
				if _rc != 0{
					di as error "WARNING: eventstudy2_parallel.do not found. eventstudy2 has switched to non-parallel computing mode. The file eventstudy2_parallel.do can be obtained by typing > net get eventstudy2 <."
					local parallel = ""		
				}
			}
		}
		else{
			capture: confirm file "eventstudy2_parallel.do"
			
			if _rc != 0{
			
				tempname flash
				local `flash' = "/"
				
				local parapath = c(sysdir_plus)
				local parapath = "`parapath'" + "e"
				capture: confirm file "`parapath'/eventstudy2_parallel.do"
				
				if _rc != 0{
					di as error "WARNING: eventstudy2_parallel.do not found. eventstudy2 has switched to non-parallel computing mode. The file eventstudy2_parallel.do can be obtained by typing > net get eventstudy2 <."
					local parallel = ""		
				}
			}
		}
	}
		
	if "`archoption'" == ""{
		local archoption "1"
	}
	if "`garchoption'" == ""{
		local garchoption "1"
	}
	
	foreach v in NoDates dow dateline event_date original_event_date exp_id IPO DEL set eventcount group datenum target td dif thinvar event_window est_window factor_avail event_windowWithMKT count_event_obsWithMKT event_windowWithSecAndMKT count_event_obsWithSecAndMKT event_windowWithSec count_event_obsWithSec est_windowWithMKT est_windowWithSecAndMKT count_est_obsWithSecAndMKT est_windowWithSec count_est_obsWithSec count_est_obsWithMKT nvals predicted_return _id STDF zero p STDFtemp Acc N retp1 MKTp1 difp tstr acc cum_periods n cum_`returns' cum_intercept RMSE STDP t_arch last_AR last_AR_min first_cum_periods first_cum_periods_min{
		tempvar `v'
	}
	
	foreach v in `marketreturns' `factor1' `factor2' `factor3' `factor4' `factor5' `factor6' `factor7' `factor8' `factor9' `factor10' `riskfreerate'{
		tempvar cum_`v'
	}
	
	foreach v in z U df CAR_modified NoOfEntriesEventfile meanDates NoOfEntriesEventfileValid NoOfEntriesEventfileOnDateline NoEventsTotal NoEventsReturnsAvail NEWSuffSecAndMKT NoInsufficientEstObsSec NoInsufficientEventObsSec IPO_DEL_in_event_window NoInsufficientEstObsMKT NoInsufficientEventObsMKT NoEventsAvail O j MAreturns In{
		tempname `v'
	}
		
	if "`replace'" == "replace"{
		local replace = "replace"
	}
	
	foreach v in "diagnosticsfile" "graphfile" "aarfile" "carfile" "crossfile" "arfile"{
		if "``v''" == ""{
			local `v' = "`v'"
		}
		if "`replace'" != "replace"{
			capture: confirm file ``v''.dta
			if _rc == 0{
				di as error "The output file ``v'' is already present in the current working directory. Either specify a different file name using the option `v' or apply the replace option to overwrite existing output files."
				exit
			}
		}
	}
	
	if "`model'" == "BHAR"  | "`model'" == "BHAR_raw" {
		local fill "fill"
	}
	
	***** Returning error messages when input is inconsistent *****
	
	if "`if'" != ""{
		keep `if'
	}
	
	if "`in'" != ""{
		keep `in'
	}
	
	if ("`model'" == "FM" | "`model'" =="MA" | "`model'" == "BHAR") & ("`marketfile'" == "" | "`marketreturns'" == "") {
		di as error "If a factor model (FM), market adjusted returns (MA) or buy-and-hold abnormal returns (BHAR) is applied, options {it:marketfile} and {it:marketreturns} ({it:factor1, factor2}...) have to be specified."
		exit
	}

	scalar `df' = 0
	if "`model'" == "FM" {
		foreach v in `factor1' `factor2' `factor3' `factor4' `factor5' `factor6' `factor7' `factor8' `factor9' `factor10' {
			scalar `df' = `df' + 1
		}
		if `eswub' - `eswlb' < (`df' + 2) {
			di as error "Estimation window is chosen too short to calculate market or factor model."
			exit
		}
	}
	
	scalar `CAR_modified' = 0
	forvalues i = 1/10 {
		if `car`i'LB' < `evwlb' | `car`i'UB' > `evwub'{
			scalar `CAR_modified' = 1 
		}
		if `car`i'LB' < `evwlb' {
			local car`i'LB = `evwlb'
		}
		if `car`i'UB' > `evwub'	{	
			local car`i'UB = `evwub' 
		}

	}
	
	if "`model'" == "BHAR" | "`model'" == "BHAR_raw" {
		local nokolari = "nokolari"
	}
	
	***** Setting default values for options that are not specified *****		
	
	if "`model'" == ""{
		local model = "RAW"
	}

	local car0LB = `evwlb'
	local car0UB = `evwub'

	tostring `1', replace
	replace `1' = rtrim(ltrim(`1'))

	count 
	scalar `NoOfEntriesEventfile' = r(N)

	tempfile __Initial
	save "`__Initial'"

	***** Generating the dateline *****

	noisily: display "Generating dateline ..."
	
	if "`model'" == "MA" | "`model'" == "FM" | "`model'" == "BHAR" {
		use `marketfile', clear
		keep if `marketreturns' != .
	}
	else{
		use `using', clear
		keep if `returns' != .
	}
		if "`parallel'" != "parallel"{
			bysort `2': gen `NoDates' = _N
		}
		else{
			sort `2'
			parallel, proc(`processors') by(`2'): by `2': gen `NoDates' = _N
			
		}
		duplicates drop `2', force
	  
		if "`delweekend'" == "delweekend"{
			gen `dow' = dow(`2')
			drop if `dow' == 6 | `dow' == 7
		}
	 
		egen `meanDates' = mean(`NoDates')
		drop if `NoDates' < (`meanDates'*`datelinethreshold')
		keep `2'
	 
		sum `2'
		local start = r(min)
		local end = r(max)
	 
		tempfile __Dateline
		save "`__Dateline'"
		
		
	noisily: display "...succeeded"

	***** Preparation of the event list *****
	
	noisily: display "Preparation of event list ..."

	use "`__Initial'", clear

	keep if `1' != "" & `2' != .

	count
	scalar `NoOfEntriesEventfileValid' = r(N)

	nearmrg using "`__Dateline'", nearvar(`2') genmatch(`dateline') upper keep(1 3) nogen
		replace `dateline' =  . if (`dateline' - `2') > `shift'
	 
	replace `dateline' = . if `2' < `start' | `2' > `end'

	count if `dateline' != .
	scalar `NoOfEntriesEventfileOnDateline' = r(N)
	 
	rename `dateline' `event_date'
	rename `2' `original_event_date'
	 
	sort `1' `event_date'
	
	tempvar event_date_p
	gen `event_date_p' = `event_date'
	drop `event_date'
	
	tempvar event_date
	gen `event_date' = `event_date_p'
	drop `event_date_p'
	
	tempfile __temp
	save "`__temp'"

	drop if `event_date' == .
	 
	tempfile __Eventdates
	save "`__Eventdates'"
											
	use "`__temp'"

	keep if `event_date' == .

	tempfile __EventsOffDateline
	save "`__EventsOffDateline'"
	
	noisily: display "...succeeded"

	***** Preparation of security data *****
	
	noisily: display "Preparation of security return data..."

	use `using', clear

	if `thin' != 0 {
		replace `returns' = . if `tradingvolume' * `prices' < `thin'
	}

	foreach v in `1'{
		tostring `v', replace
		replace `v' = rtrim(ltrim(`v'))
	}
	
	capture: tostring `idmarket', replace
	capture: replace `idmarket' = rtrim(ltrim(`v'))


	egen `exp_id' = group(`1')
	sum `exp_id'
	local exp_no = r(max)
	 
	tempfile __Stockdatatemp
	save "`__Stockdatatemp'"
	 
	use "`__Dateline'", clear
	expand `exp_no'
	
	if "`parallel'" != "parallel"{
		quietly bysort `2': gen `exp_id' = cond(_N==1,1,_n)
	}
	else{
		sort `2'
		parallel, proc(`processors') by(`2'): bysort `2': gen `exp_id' = cond(_N==1,1,_n)
	}
	 
	sort `2' `exp_id'
	merge 1:1 `2' `exp_id' using "`__Stockdatatemp'", keep(1 3) nogen

	if "`parallel'" != "parallel"{
	
		if "`prices'" != ""{ 
			bysort 	`exp_id': egen `IPO' = min(`2') if `prices' != .  
			by 		`exp_id': egen `DEL' = max(`2') if `prices' != .
		}
		else{
			bysort 	`exp_id': egen `IPO' = min(`2') if `returns' != .  
			by 		`exp_id': egen `DEL' = max(`2') if `returns' != .
		}

		foreach v in `IPO' `DEL'{
			tempvar `v'temp
			by `exp_id': egen ``v'temp' = min(`v')
			replace `v' = ``v'temp'
			drop ``v'temp'
		}

		drop if `2' < `IPO' | `2' > `DEL'
		  
		sort `exp_id' `2'

		if "`fill'" == "fill"{
				foreach v in `tradingvolume' `prices'{
					by `exp_id': replace `v' = `v'[_n-1] if `v' == .
				}
				replace `returns' = 0 if `returns' == .
		}

		foreach v of var `1'{
			by `exp_id': replace  `v' =  `v'[_n-1] if `v' == ""
		}
		
		capture: by `exp_id': replace  `idmarket' =  `idmarket'[_n-1] if `idmarket' == ""
		
		gsort +`exp_id' -`2'
		 
		if "`fill'" == "fill"{
				foreach v in `tradingvolume' `prices'{
					by `exp_id': replace `v' = `v'[_n-1] if `v' == .
				}
				replace `returns' = 0 if `returns' == .
		}

		foreach v of var `1'{
			by `exp_id': replace  `v' =  `v'[_n-1] if `v' == ""
		}
		
		capture: by `exp_id': replace `idmarket' =  `idmarket'[_n-1] if `idmarket' == ""
		
	}
	else{
		if "`prices'" != ""{ 
			sort `exp_id'
			parallel, proc(`processors') by(`exp_id'): by `exp_id': egen `IPO' = min(`2') if `prices' != .
			sort `exp_id'
			parallel, proc(`processors') by(`exp_id'): by `exp_id': egen `DEL' = max(`2') if `prices' != .
		}
		else{
			sort `exp_id'
			parallel, proc(`processors') by(`exp_id'): by `exp_id': egen `IPO' = min(`2') if `returns' != .
			sort `exp_id'
			parallel, proc(`processors') by(`exp_id'): by `exp_id': egen `DEL' = max(`2') if `returns' != .
		}

		foreach v in `IPO' `DEL'{
			tempvar `v'temp
			sort `exp_id'
			parallel, proc(`processors') by(`exp_id'): by `exp_id': egen ``v'temp' = min(`v')
			replace `v' = ``v'temp'
			drop ``v'temp'
		}

		drop if `2' < `IPO' | `2' > `DEL'
		  
		sort `exp_id' `2'

		if "`fill'" == "fill"{
				foreach v in `tradingvolume' `prices'{
					by `exp_id': replace `v' = `v'[_n-1] if `v' == .
				}
				replace `returns' = 0 if `returns' == .
		}

		foreach v of var `1'{
			by `exp_id': replace  `v' =  `v'[_n-1] if `v' == ""
		}
		
		capture: by `exp_id': replace `idmarket' =  `idmarket'[_n-1] if `idmarket' == ""
		 
		gsort +`exp_id' -`2'
		 
		if "`fill'" == "fill"{
				foreach v in `tradingvolume' `prices'{
					by `exp_id': replace `v' = `v'[_n-1] if `v' == .
				}
				replace `returns' = 0 if `returns' == .
		}

		foreach v of var `1'{
			by `exp_id': replace  `v' =  `v'[_n-1] if `v' == ""
		}
		
		capture: by `exp_id': replace `idmarket' =  `idmarket'[_n-1] if `idmarket' == ""
	}
	 
	sort `exp_id' `2'
	drop if `1' == ""
	
	tempfile __temp
	save "`__temp'"
	
	noisily: display "...succeeded"
	
	if "`model'" == "MA" | "`model'" == "FM" | "`model'" == "BHAR" {
		noisily: display "Preparation of market and/or factor return data..."
		use `marketfile', clear
		capture: tostring `idmarket', replace
		capture: replace `idmarket' = rtrim(ltrim(`idmarket'))
		tempfile __Market
		save "`__Market'"
		noisily: display "...succeeded"
		use "`__temp'", clear
	}
	
	sort `1' `2'
	gen int `thinvar' = .
		by `1': replace `thinvar' = 1 if `returns'[_n-1] == . & `returns' != .  & _n != 1
	gen int `cum_periods' = 1
		by `1': replace `cum_periods' = `cum_periods' + `cum_periods'[_n-1] if (`returns' == . | `thinvar' == 1) & `returns'[_n-1] == .
		
	if "`logreturns'" != "logreturns" & ("`model'" == "RAW" | "`model'" == "COMEAN" | ) {
		replace `returns' = ln(`returns'+1)
	}

	if "`model'" == "MA" | "`model'" == "FM" | "`model'" == "BHAR" {
		capture: keep `1' `2' `returns' `prices' `tradingvolume' `shares' `idmarket' `IPO' `DEL' `cum_periods' `thinvar'
		if _rc == 111{
			keep `1' `2' `returns' `prices' `tradingvolume' `shares' `IPO' `DEL' `cum_periods' `thinvar'
			merge m:m `1' using "`__Eventdates'", keepus(`idmarket') nogen
			capture: tostring `idmarket', replace
			capture: replace `idmarket' = rtrim(ltrim(`idmarket'))
		}

		merge m:1 `2' `idmarket' using "`__Market'", keep(1 3) nogen keepus(`marketreturns' `factor1' `factor2' `factor3' `factor4' `factor5' `factor6' `factor7' `factor8' `factor9' `factor10' `factor11' `factor12' `factor13' `factor14' `factor15' `riskfreerate') 
		
		if "`logreturns'" != "logreturns" & ("`model'" == "MA"  | "`model'" == "FM") {
			foreach v in `returns' `marketreturns' `factor1' `factor2' `factor3' `factor4' `factor5' `factor6' `factor7' `factor8' `factor9' `factor10' `factor11' `factor12' `factor13' `factor14' `factor15' `riskfreerate'{
				replace `v' = ln(`v'+1)
			}
		}
	}
	
	sort `1' `2'
	
	if "`fill'" == "fill" & "`model'" != "RAW" & "`model'" != "COMEAN" & "`model'" != "BHAR_raw"{
		foreach v in `marketreturns' `factor1' `factor2' `factor3' `factor4' `factor5' `factor6' `factor7' `factor8' `factor9' `factor10' `factor11' `factor12' `factor13' `factor14' `factor15' `riskfreerate'{
			replace `v' = 0 if `v' == .
		}
		replace `cum_periods' = 1
	}
	
	if "`model'" == "MA" | "`model'" == "FM" | "`model'" == "RAW" | "`model'" == "COMEAN"{	
		foreach v in `marketreturns' `factor1' `factor2' `factor3' `factor4' `factor5' `factor6' `factor7' `factor8' `factor9' `factor10' `factor11' `factor12' `factor13' `factor14' `factor15' `riskfreerate'{
			gen `cum_`v'' = `v'
			by `1': replace `cum_`v'' = `cum_`v'' + `cum_`v''[_n-1] if `cum_periods' > 1 & `cum_periods' != . & `cum_`v''[_n-1] != .
			replace `cum_`v'' = `cum_`v'' / sqrt(`cum_periods')
		}	
		gen `cum_`returns'' = `returns' / sqrt(`cum_periods')
	}
					
	if "`logreturns'" == "logreturns" & ("`model'" == "BHAR" | "`model'" == "BHAR_raw") {
		replace `returns' = exp(`returns')-1
		capture: replace `marketreturns' = exp(`marketreturns')-1
	}
	
	if "`riskfreerate'" != ""{
		replace `returns' =  `returns' - `riskfreerate'
		replace `marketreturns' =  `marketreturns' - `riskfreerate'
	}

	tempfile __Stockdata
	save "`__Stockdata'"

	***** Merging the event file with stock market data *****
	
	noisily: display "Merging event dates and stock market data..."

	use "`__Eventdates.dta'", clear
		bysort `1': gen `set'=_n
		capture sort `1' `set'
		if _rc == 111{
			di as error "Please ensure that at least some of your security returns and factor returns cover the event period; probably your security return data and/or market return data spans a time period that is different from the time period of your events."
			exit = 111
		}
		capture: tostring `idmarket', replace
		tempfile __Eventdates_set
		save "`__Eventdates_set'", replace 
		count
		scalar `NoEventsTotal' = r(N)
		bysort `1': gen `eventcount'=_N 
		by `1': keep if _n==1 
		keep `1' `eventcount' 
	tempfile __Eventcount
	save "`__Eventcount'"

	use "`__Stockdata'", clear
		merge m:1 `1' using "`__Eventcount'", nogen keep(2)
		capture: levelsof `1', local(Noreturns) separate(,)
		keep `1' 
	tempfile __SecurityWithNoReturns
	save "`__SecurityWithNoReturns'" 

	use "`__Stockdata'", clear
	erase "`__Stockdata'"
	
		sort `1'
		merge m:1 `1' using "`__Eventcount'", nogen keep(3) 
		compress
		expand `eventcount' 
		drop `eventcount'
		bysort `1' `2': gen `set'=_n
		sort `1' `set'
		egen `group' = group(`1' `set')
		distinct `group'
		drop `group'
		scalar `NoEventsReturnsAvail' = r(ndistinct)

	merge m:1 `1' `set' using "`__Eventdates_set'", nogen keep(3)
		sort `1' `set' `2'
		by `1' `set': gen `datenum' = _n 
		by `1' `set': gen `target' = `datenum' if `2' == `event_date' 
		egen `td' = min(`target'), by(`1' `set') 
		gen `dif' = `datenum'-`td'
		
	by `1' `set': gen `event_window' = 1 if `dif' >= `evwlb' & `dif' <= `evwub' 
	by `1' `set': gen `est_window' = 1 if `dif' <= `eswub' & `dif' >= `eswlb'
	
	gen `factor_avail' = 1

	if "`model'" == "FM" | "`model'" == "BHAR" | "`model'" == "MA"{
		foreach v in `marketreturns' `factor1' `factor2' `factor3' `factor4' `factor5' `factor6' `factor7' `factor8' `factor9' `factor10' `factor11' `factor12' `factor13' `factor14' `factor15' {
			replace `factor_avail' = 0 if `v' == .
		}
	}

	by `1' `set': gen `event_windowWithMKT' = 1 if `dif' >= `evwlb' & `dif' <= `evwub' & `factor_avail' == 1
		egen `count_event_obsWithMKT' = count(`event_windowWithMKT'), by(`1' `set') 

	by `1' `set': gen `event_windowWithSecAndMKT' = 1 if `dif' >= `evwlb' & `dif' <= `evwub' & `factor_avail' == 1 & `returns' != . 
		egen `count_event_obsWithSecAndMKT' = count(`event_windowWithSecAndMKT'), by(`1' `set')

	by `1' `set': gen `event_windowWithSec' = 1 if `dif' >= `evwlb' & `dif' <= `evwub' & `returns' != . 
		egen `count_event_obsWithSec' = count(`event_windowWithSec'), by(`1' `set') 
		
	if "`model'" == "FM" | "`model'" == "MA" | "`model'" == "RAW" | "`model'" == "COMEAN"{
		by `1' `set': gen `est_windowWithMKT' = 1 if `dif' <= `eswub' & `dif' >= `eswlb' & `factor_avail' == 1
			egen `count_est_obsWithMKT' = count(`est_windowWithMKT'), by(`1' `set') 

		by `1' `set': gen `est_windowWithSecAndMKT' = 1 if `dif' <= `eswub' & `dif' >= `eswlb' & `factor_avail' == 1 & `returns' != . 
			egen `count_est_obsWithSecAndMKT' = count(`est_windowWithSecAndMKT'), by(`1' `set')
	}		
	
	if "`model'" == "FM" | "`model'" == "MA" | "`model'" == "RAW" | "`model'" == "COMEAN"{
		by `1' `set': gen `est_windowWithSec' = 1 if `dif' <= `eswub' & `dif' >= `eswlb' & `returns' != . 
			egen `count_est_obsWithSec' = count(`est_windowWithSec'), by(`1' `set')
	}
	 
	by `1' `set', sort: gen `nvals' = _n == 1 

	if "`model'" == "FM" | "`model'" == "MA" | "`model'" == "RAW" | "`model'" == "COMEAN"{
		count if `nvals' & `count_event_obsWithSecAndMKT' >= `minevw' & `count_est_obsWithSecAndMKT' >= `minesw'
	}
	else {
		count if `nvals' & `count_event_obsWithSecAndMKT' >= `minevw' /* Applicable since for models without benchmark (BHAR_raw and BHAR), factor_avail is always 1 */
	}
	
	scalar `NEWSuffSecAndMKT' = r(N)

	foreach v of var `IPO' `DEL' {
		tempvar `v'_dif
		gen ``v'_dif' = `dif' if `v' == `2'
			tempvar min`v'_dif
			egen `min`v'_dif' = min(``v'_dif'), by(`1' `set')
			replace ``v'_dif' = `min`v'_dif'
	}
	
	tempfile __temp		
	save "`__temp'"
	
	if "`model'" =="FM" | "`model'" =="RAW" | "`model'" =="MA" | "`model'" =="COMEAN"{
		keep if `count_est_obsWithSec' < `minesw' 
		capture: duplicates drop `1' `set', force
		keep `1' `event_date' `original_event_date'
		tempfile __InsufficientEstObsSec
		save "`__InsufficientEstObsSec'"
		count
		scalar `NoInsufficientEstObsSec' = r(N)
	}
		
	use "`__temp'", clear
		keep if `count_event_obsWithSec' < `minevw' 
		capture: duplicates drop `1' `set', force
		keep `1' `event_date' `original_event_date'
		tempfile __InsufficientEventObsSec
		save "`__InsufficientEventObsSec'"
		count
		scalar `NoInsufficientEventObsSec' = r(N)
		
	use "`__temp'", clear	
		keep if ``IPO'_dif' > `evwlb'  | ``DEL'_dif' < `evwub'
		capture: duplicates drop `1' `set', force
		keep `1' `event_date' `original_event_date'
		tempfile __IPO_DEL_in_event_window
		save "`__IPO_DEL_in_event_window'"
		count
		scalar `IPO_DEL_in_event_window' = r(N)
		
	if "`model'" == "FM" | "`model'" == "MA"{
		use "`__temp'", clear
			keep if `count_est_obsWithMKT' < `minesw' 
			capture: duplicates drop `1' `set', force
			keep `1' `event_date' `original_event_date'
			tempfile __InsufficientEstObsMKT
			save "`__InsufficientEstObsMKT'"
			count
			scalar `NoInsufficientEstObsMKT' = r(N)
	}
	
	if "`model'" == "FM" | "`model'" == "BHAR" | "`model'" == "MA"{
		use "`__temp'", clear
			keep if `count_event_obsWithMKT' < `minevw' 
			capture: duplicates drop `1' `set', force
			keep `1' `event_date' `original_event_date'
			tempfile __InsufficientEventObsMKT
			save "`__InsufficientEventObsMKT'"
			count
			scalar `NoInsufficientEventObsMKT' = r(N)	
	}

	use "`__temp'", clear
	
		if "`model'" == "FM" | "`model'" == "MA" {
			keep if `count_event_obsWithSecAndMKT' >= `minevw' & `count_est_obsWithSecAndMKT' >= `minesw' 
		}
		else if "`model'" == "RAW" | "`model'" == "COMEAN" {
			keep if `count_event_obsWithSec' >= `minevw' & `count_est_obsWithSec' >= `minesw'
		}
		else if "`model'" == "BHAR" {
			keep if `count_event_obsWithSecAndMKT' >= `minevw'
		}
		else if "`model'" == "BHAR_raw" {
			keep if `count_event_obsWithSec' >= `minevw'
		}
		
		drop if ``IPO'_dif' > `evwlb'  | ``DEL'_dif' < `evwub'
		
	tempfile __temp		
	save "`__temp'", replace
		
		capture: duplicates drop `1' `set', force
		count
		scalar `NoEventsAvail' = r(N)
		
	noisily: display "...succeeded"
	  
	use "`__temp'", clear

	***** Running regressions *****
	
	noisily: display "Calculating abnormal returns..."
	
	if "`model'" == "FM"{
		gen _BETA = .
	}
	
	gen `predicted_return' = .

	egen `_id' = group(`1' `set') 
	
	sort `_id' `2', stable
	
	if "`saveram'" == "saveram"{
		if "`model'" != "BHAR" & "`model'" != "BHAR_raw" {
			keep `set' `marketreturns' `returns' `dif' `event_date' `predicted_return' `_id' `1' `2' `original_event_date' `cum_periods' `cum_`returns'' `est_window' `event_window' `cum_`marketreturns'' `cum_`factor1'' `cum_`factor2'' `cum_`factor3'' `cum_`factor4'' `cum_`factor5'' `cum_`factor6'' `cum_`factor7'' `cum_`factor8'' `cum_`factor9'' `cum_`factor10'' `cum_`factor11'' `cum_`factor12'' `cum_`factor13'' `cum_`factor14'' `cum_`factor15''
		}
		else{
			keep `set' `marketreturns' `returns' `dif' `event_date' `predicted_return' `_id' `1' `2' `original_event_date' `est_window' `event_window' 
		}
	}
	
	compress

	if "`parallel'" == "parallel"{
		foreach v in  STDP RMSE STDFtemp p STDF set original_event_date j returns dif marketreturns predicted_return archoption garchoption architerate t_arch O cum_intercept cum_periods model garch zero est_window MAreturns factor1 factor2 factor3 factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11 factor12 factor13 factor14 factor15{
			if "`v'" != ""{
				global `v' = "``v''"
			}
		}
		foreach v in 1 2 {
			global special`v' = "``v''"
		}
		foreach v in returns marketreturns factor1 factor2 factor3 factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11 factor12 factor13 factor14 factor15{
			if "`v'" != ""{
				global cum_`v' = "`cum_``v'''"
			}
		}
		
		noisily: parallel do "`parapath'``flash''eventstudy2_parallel.do", by(`_id') proc(`processors')
	}
	else{
		summarize `_id'
		scalar `O' = r(max) 

		gen `STDF' = .
		
		gen `cum_intercept' = 1/sqrt(`cum_periods')
		
		if "`model'" == "FM" & "`garch'" == "garch"{
			tempfile __beforearch
		}
		
		if "`model'" != "BHAR" & "`model'" != "BHAR_raw" {
			gen `zero' = 0
			scalar `j' = 1
			
			
			if "`model'" == "MA" {
					
				replace `cum_`returns'' = `cum_`returns'' - `cum_`marketreturns''
				replace `returns' = `returns' - `marketreturns'
			}
								
			while `j' <= `O' { 
				ereturn clear
		
				if "`model'" == "RAW" {
					capture: reg `cum_`returns'' `zero' if `_id' == `j' & `est_window' == 1, nocons
				}						
				if "`model'" == "COMEAN" {											
					capture: reg `cum_`returns'' `cum_intercept' `zero'  if `_id' == `j' & `est_window' == 1, nocons
				}

				if "`model'" == "MA" {	
					capture: reg `cum_`returns'' `zero'  if `_id' == `j' & `est_window' == 1, nocons
				}
				
				if "`model'" == "FM" & "`garch'" != "garch"{
					capture: reg `cum_`returns'' `cum_intercept' `cum_`marketreturns'' `cum_`factor1'' `cum_`factor2'' `cum_`factor3'' `cum_`factor4'' `cum_`factor5'' `cum_`factor6'' `cum_`factor7'' `cum_`factor8'' `cum_`factor9'' `cum_`factor10'' `cum_`factor11'' `cum_`factor12'' `cum_`factor13'' `cum_`factor14'' `cum_`factor15'' if `_id' == `j' & `est_window' == 1, nocons
				
					if _rc == 0{
						capture: replace _BETA = _b[`cum_`marketreturns''] if `_id' == `j'
					}
				
				}
				
				if "`model'" == "FM" & "`garch'" == "garch"{
				
					save `__beforearch', replace
						keep if `_id' == `j' 
						sort `2'
						gen `t_arch' = _n
						tsset `t_arch'
						set seed 1
						parallel setclusters `pclusters'
						capture: arch `cum_`returns'' `cum_intercept' `cum_`marketreturns'' `cum_`factor1'' `cum_`factor2'' `cum_`factor3'' `cum_`factor4'' `cum_`factor5'' `cum_`factor6'' `cum_`factor7'' `cum_`factor8'' `cum_`factor9'' `cum_`factor10'' `cum_`factor11'' `cum_`factor12'' `cum_`factor13'' `cum_`factor14'' `cum_`factor15''  if `est_window' == 1, nocons arch(`archoption') garch(`garchoption') iterate(`architerate')
				}
				
				foreach v in returns marketreturns factor1 factor2 factor3 factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11 factor12 factor13 factor14 factor15{
					capture: gen save`cum_``v''' = `cum_``v'''
					capture: replace `cum_``v''' = `cum_``v''' * sqrt(`cum_periods')
				}
				
				gen save`cum_intercept' = `cum_intercept'
				replace `cum_intercept' = `cum_intercept' * sqrt(`cum_periods')
				
				tsset `_id' `2'
				capture: predict `p' if `_id' ==`j'			
				capture: replace `predicted_return' = `p' if `_id'==`j' & e(N) 
				
				if "`garch'" != "garch"{
					capture: predict `STDFtemp' if `_id'==`j', stdf 
					capture: replace `STDF'= `STDFtemp' if `_id'==`j'  & e(N) 
					capture: drop `STDFtemp'
					
					foreach v in returns marketreturns factor1 factor2 factor3 factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11 factor12 factor13 factor14 factor15{
						capture: replace `cum_``v''' = save`cum_``v''' 
					}
					
					capture: replace `cum_intercept' = save`cum_intercept'
					drop save*
				}
				else{
					capture: predict `STDP' if `_id'==`j', stdp
					local df_m = e(df_m)
					capture: rmse `p' `cum_`returns'', df_m(`df_m')
					capture: gen `RMSE' = r(`cum_`returns'') 
					capture: destring `RMSE', replace force
					capture: gen `STDFtemp' = sqrt(`STDP'^2+`RMSE'^2) if `_id'==`j'
					capture: replace `STDF'= `STDFtemp' if `_id'==`j'  & e(N) 
					capture: drop `STDFtemp' `RMSE' `STDP'
					capture: drop `p'
					local `z' = `j'
					tempfile __file_``z''
					capture: save `__file_``z''', replace empty
					use `__beforearch', clear
				}	
				
				capture: drop `p'
				noisily: display `j' " out of " `O' " events completed."
				scalar `j' = `j' + 1	
			}
				
			if "`garch'" == "garch"{
				clear
				local `U' = `O'
				forvalues i = 1/``U'' {
					capture: append using `__file_`i''
				}
				forvalues i = 1/``U'' {
					capture: erase `__file_`i''
				}
			} 
		}
		


		if "`model'" == "BHAR" {
			replace `predicted_return' = `marketreturns'
		}

		if "`model'" == "BHAR_raw"{
			replace `predicted_return' = 0
		}

		gen AR = `returns' - `predicted_return'		
		rename `original_event_date' original_event_date
	}
	
	
	if "`arfillevent'" == "arfillevent"{
		replace AR = 0 if AR == . & `event_window' == 1 
	}
	if "`arfillestimation'" == "arfillestimation"{
		replace AR = 0 if AR == . & `est_window' == 1
	}
	
	sort `_id' `2'

	tempfile preserve
	save `preserve', replace
	capture: drop __*
	saveold `arfile', `replace'
	use `preserve', clear

	if "`model'" != "BHAR" & "`model'" != "BHAR_raw" {
		forvalues i = 1/10 {
			by `_id': egen CAR`i' = sum(AR) if `dif' >= `car`i'LB' & `dif' <= `car`i'UB' 		
		
			if "`arfillevent'" != "arfillevent" {
				gen `last_AR' = AR if `dif' == `car`i'UB'
				by `_id': egen `last_AR_min' = min(`last_AR')
				by `_id': replace `last_AR' = `last_AR_min'
				
				gen `first_cum_periods' = `cum_periods' if `dif' == `car`i'LB'
				by `_id': egen `first_cum_periods_min' = min(`first_cum_periods')
				by `_id': replace `first_cum_periods' = `first_cum_periods_min'
					
				replace CAR`i' = . if `last_AR' == . | `first_cum_periods' > 1
				
				drop `last_AR_min' `last_AR' `first_cum_periods' `first_cum_periods_min'
			}
			
			tempvar CAR`i'temp
			by `_id': egen `CAR`i'temp' = min(CAR`i') 
			by `_id': replace CAR`i' = `CAR`i'temp' 
			drop `CAR`i'temp' 

		}  
	} 

	if "`model'" == "BHAR" | "`model'" == "BHAR_raw" {
		
		gen `retp1' = `returns' + 1
		forvalues i = 1/10 {
			tempvar Cret`i'
			by `_id': egen `Cret`i'' = prod(`retp1') if `dif' >= `car`i'LB' & `dif' <= `car`i'UB' 
		}
	}

	if "`model'" == "BHAR" {
		gen `MKTp1' = `marketreturns' + 1
		forvalues i = 1/10 {
			tempvar CMKT`i'
			by `_id': egen `CMKT`i'' = prod(`MKTp1') if `dif' >= `car`i'LB' & `dif' <= `car`i'UB' 
		}

	}

	if "`model'" == "BHAR" {
		forvalues i = 1/10 {
			gen BHAR`i' = `Cret`i'' - `CMKT`i''
			tempvar BHAR`i'temp
			by `_id': egen `BHAR`i'temp' = min(BHAR`i')
			by `_id': replace BHAR`i' = `BHAR`i'temp'
			drop `BHAR`i'temp' 
		}

	}

	if "`model'" == "BHAR_raw" {
		forvalues i = 1/10 {
			rename `Cret`i'' BHAR`i' 
		}
	}

	foreach v in `2' `idmarket' `set' `factor_avail' `nvals' `predicted_return' `datenum' `target' `td' `thinvar' `n' `factor1' `factor2' `factor3' `factor4' `factor5' `factor6' `factor7' `factor8' `factor9' `factor10' `factor11' `factor12' `factor13' `factor14' `factor15' `event_window' `event_windowWithMKT' `event_windowWithSecAndMKT' `event_windowWithSec' `est_window' `est_windowWithMKT' `est_windowWithSecAndMKT' `est_windowWithSec' `count_event_obsWithMKT' `count_event_obsWithSec' `count_event_obsWithSecAndMKT' `count_est_obsWithMKT' `count_est_obsWithSecAndMKT' `count_est_obsWithSec' `zero' `retp1' `MKTp1'{
		capture: drop `v'
	}
	
	forvalues i = 1/10 {
		capture: drop `Cret`i'' 
		capture: drop `CMKT`i'' 
	}
	
	tempfile __RawResults
	save "`__RawResults'"

	duplicates drop `_id', force
	
	foreach v in `dif' `STDF' `_id' AR `IPO' `DEL' `returns' ``IPO'_dif' ``DEL'_dif' `min`IPO'_dif' `min`DEL'_dif' `exp_id' `marketreturns' `tradingvolume' `prices' `idmarket' `riskfreerate'{
		capture: drop `v'
	}
	
	rename `event_date' event_date
	
	tempfile preserve2
	save `preserve2', replace
	capture: drop __*
	format event_date %d 
	format original_event_date %d
	
	forvalues i = 1/10{
		capture: label var CAR`i' "CAR[`car`i'LB';`car`i'UB']"
		capture: label var BHAR`i' "BHAR[`car`i'LB';`car`i'UB']"
	}
	
	save `crossfile', `replace'
	
	if "`crossonly'" == "crossonly"{
		exit, clear
	}
	
	
	use `preserve2', clear
	
	noisily: display "...succeeded"

	***** Caluclating test statistics *****
	
	noisily: display "Assessing statistical significance of abnormal returns..."

	use "`__RawResults'", clear
	
	if "`model'" =="FM" | "`model'" =="RAW" | "`model'" =="MA" | "`model'" =="COMEAN"{ 
		keep if `dif' <= `eswub' & `dif' >= `eswlb' 
		gen `difp' = `dif' - `eswlb'
		tempfile __temp
		save "`__temp'"
		keep `_id' AR `difp' 
		reshape wide AR, i(`_id') j(`difp')
		drop `_id'
		mata AR = st_data(.,.)' 
		mata: df = st_numscalar("`df'")
	}

	if "`nokolari'" != "nokolari"{
		use "`__temp'", clear
		capture: gen `STDF' = AR
		keep `_id' `STDF' `difp' 
		reshape wide `STDF' , i(`_id') j(`difp')
		drop `_id'
		mata STDF = st_data(.,.)' 
		mata: KolariADJ = KOLARI(AR,STDF,df)
	}
	else{
		mata: KolariADJ = 1
	}

	forvalues cari = 0/10 {
		use "`__RawResults'", clear
		tempfile __temp
		save "`__temp'"
		
		if "`model'" != "RAW" & "`model'" != "COMEAN" & "`model'" != "BHAR_raw" {
			keep if `dif' >= `car`cari'LB' & `dif' <= `car`cari'UB' 
			gen `difp' = `dif' - `evwlb'
			keep `_id' `marketreturns' `difp' 
			reshape wide `marketreturns', i(`_id') j(`difp')
			drop `_id'
			mata MRE = st_data(.,.)'
		}

		use "`__temp'", clear
		
		if "`model'" == "RAW" | "`model'" == "COMEAN" | "`model'" == "MA" | "`model'" == "FM" {
		
			keep if `dif' >= `car`cari'LB' & `dif' <= `car`cari'UB'
			
			if `cari' != 0 & "`arfillevent'" != "arfillevent" {
				gen `last_AR' = AR if `dif' == `car`cari'UB'
				by `_id': egen `last_AR_min' = min(`last_AR')
				by `_id': replace `last_AR' = `last_AR_min'
				
				gen `first_cum_periods' = `cum_periods' if `dif' == `car`cari'LB'
				by `_id': egen `first_cum_periods_min' = min(`first_cum_periods')
				by `_id': replace `first_cum_periods' = `first_cum_periods_min'
							
				replace AR = . if `last_AR' == . | `first_cum_periods' > 1
				
				drop `last_AR_min' `last_AR' `first_cum_periods' `first_cum_periods_min'
			}
			
			gen `difp' = `dif' - `evwlb'
			keep `_id' AR `difp'
			reshape wide AR, i(`_id') j(`difp')
			drop `_id'
			mata ARE = st_data(.,.)'

			if "`model'" =="FM" | "`model'" =="MA" {
				use "`__temp'", clear
				keep if `dif' <= `eswub' & `dif' >= `eswlb' 
				gen `difp' = `dif' - `eswlb'
				keep `_id' `marketreturns' `difp' 
				reshape wide `marketreturns', i(`_id') j(`difp')
				drop `_id'
				mata MR = st_data(.,.)'
			}
			
			use "`__temp'", clear
			keep if `dif' >= `car`cari'LB' & `dif' <= `car`cari'UB' 
			gen `difp' = `dif' - `evwlb'
			keep `_id' `STDF' `difp' 
			reshape wide `STDF', i(`_id') j(`difp')
			drop `_id'
			mata STDFE = st_data(.,.)'
			
			mata: NOMARKET = 0
			
			if "`model'" == "RAW" | "`model'" == "COMEAN"{
				mata: NOMARKET = 1
				mata: MR = AR :- AR
				mata: MRE = ARE :- ARE
			}
			
			mata: TESTSTATS = TESTSTATS(df,AR,ARE,MR,MRE,KolariADJ,STDFE,NOMARKET)
			
			clear
			local obs = -`car`cari'LB' + `car`cari'UB' + 1
			set obs `obs'
			
			foreach v in "NoFirms" "AARE" "NAAREt_test" "PAAREt_test" "NAARECDA" "PAARECDA" "NAAREPatell" "PAAREPatell" "NAAREPatellADJ" "PAAREPatellADJ" "NAAREBoehmer" "PAAREBoehmer" "NAAREKolari" "PAAREKolari" "NAARECorrado" "PAARECorrado" "NAAREZivney" "PAAREZivney" "NAAREGenSign" "PAAREGenSign"  "NAAREWilcox" "PAAREWilcox"  "CAARE" "NCAAREt_test" "PCAAREt_test" "NCAARECDA" "PCAARECDA" "NCAAREPatell" "PCAAREPatell" "NCAAREPatellADJ" "PCAAREPatellADJ" "NCAAREBoehmer" "PCAAREBoehmer" "NCAAREKolari" "PCAAREKolari" "NCAARECorrado_Cowan" "PCAARECorrado_Cowan" "NCAAREZivney_Cowan" "PCAAREZivney_Cowan" "NCAAREGenSign" "PCAAREGenSign" "NCAAREGRANKT" "PCAAREGRANKT" "NCAAREWilcox" "PCAAREWilcox"{
				gen `v' = .
			}
			mata: r = 0
			mata: st_view(r,.,.)
			mata: r[.,.] = TESTSTATS
			
			gen t= `car`cari'LB'
				replace t= t[_n-1]+1 if _n != 1
			sort t
			order t
			
			label variable AARE "AAR" 
			label variable NAAREt_test "t-stat. avg. abn. returns"
			label variable PAAREt_test "p-val. avg abn. returns"
			label variable NAARECDA "t-stat. avg. abn. returns CDA (Brown & Warner 1980/1985)"
			label variable PAARECDA "p-val. avg. abn. returns CDA (Brown & Warner 1980/1985)"
			label variable NAAREPatell "t-stat. avg. abn. stand. returns (Patell 1976)"
			label variable PAAREPatell "p-val. avg. abn. stand. returns (Patell 1976)"
			label variable NAAREPatellADJ "t-stat. avg. abn. stand. returns (Patell 1976) with KP (2010) adj."
			label variable PAAREPatellADJ "p-val. avg. abn. stand. returns (Patell 1976) with KP (2010) adj."
			label variable NAAREBoehmer "t-stat. avg. abn. cross. stand. returns (Boehmer et al. 1991)"
			label variable PAAREBoehmer "p-val. avg. abn. cross. stand. returns (Boehmer et al. 1991)"
			label variable NAAREKolari "t-stat. avg. abn. cross. stand. returns (Kolari and Pynnönen (2010))"
			label variable PAAREKolari "p-val. avg. abn. cross. stand. returns (Kolari and Pynnönen (2010))"
			label variable NAARECorrado "n-stat. rank test (Corrado 1989 / Corrado & Zivney 1992)"
			label variable PAARECorrado "p-val. rank test (Corrado 1989 / Corrado & Zivney 1992"
			label variable NAAREZivney "n-stat. cross. stand. rank test (Corrado & Zivney 1992 / Cowan 1992)"
			label variable PAAREZivney "p-val. cross. stand. rank test (Corrado & Zivney 1992 / Cowan 1992)"
			label variable NAAREGenSign "n-stat. generalized sign test (Cowan 1992)"
			label variable PAAREGenSign "p-val. generalized sign test test (Cowan 1992)"
			label variable NAAREWilcox "n-stat. Wilcoxson (1945) rank rest"
			label variable PAAREWilcox "p-val. Wilcoxson (1945) rank rest"

			label variable CAARE "CAAR"
			label variable NCAAREt_test "t-stat. cum. avg. abn. returns"
			label variable PCAAREt_test "p-val. cum. avg. abn. returns"
			label variable NCAARECDA "t-stat. cum. avg. abn. returns CDA (Brown & Warner 1980/1985)"
			label variable PCAARECDA "p-val. cum. avg. abn. returns CDA (Brown & Warner 1980/1985)"
			label variable NCAAREPatell "t-stat. cum avg. abn. stand. returns (Patell 1976)"
			label variable PCAAREPatell "p-val. cum avg. abn. stand returns (Patell 1976)"
			label variable NCAAREPatellADJ "t-stat. cum avg. abn. stand. returns (Patell 1976) with KP (2010) adj."
			label variable PCAAREPatellADJ "p-val. cum avg. abn. stand returns (Patell 1976) with KP (2010) adj."
			label variable NCAAREBoehmer "t-stat. cum avg. abn. cross. stand. returns (Boehmer et al. 1991)"
			label variable PCAAREBoehmer "p-val. cum avg. abn. cross. stand. returns (Boehmer et al. 1991)"
			label variable NCAAREKolari "t-stat. cum avg. abn. cross. stand. returns (Boehmer et al. 1991 / Kolari and Pynnönen (2010))"
			label variable PCAAREKolari "p-val. cum avg. abn. cross. stand. returns (Boehmer et al. 1991 / Kolari and Pynnönen(2010)"
			label variable NCAARECorrado_Cowan "n-stat. cum. rank test (Corrado & Zivney 1992 / Cowan 1992)"
			label variable PCAARECorrado_Cowan "p-val. cum. rank test (Corrado & Zivney 1992 / Cowan 1992)"
			label variable NCAAREZivney_Cowan "n-stat. cum. rank test (Corrado & Zivney 1992 / Cowan 1992)"
			label variable PCAAREZivney_Cowan "p-val. cum. rank test (Corrado & Zivney 1992 / Cowan 1992)"
			label variable NCAAREGenSign "n-stat. cum. generalized sign test (Cowan 1992)"
			label variable PCAAREGenSign "p-val. cum. generalized sign test (Cowan 1992)"
			label variable NCAAREGRANKT "t-stat. GRANK-T test (Kolari and Pynnönen (2011)"
			label variable PCAAREGRANKT "p-val. GRANK-T test (Kolari and Pynnönen (2011)"
			label variable NCAAREWilcox "n-stat. Wilcoxson (1945) rank rest"
			label variable PCAAREWilcox "p-val. Wilcoxson (1945) rank rest"
			
			if `cari' == 0 {
				drop NCAAREGRANKT PCAAREGRANKT
				save `aarfile', `replace'
			}
			else{
				tempfile __MataresultsReturns`cari'
				save "`__MataresultsReturns`cari''"
			}
		}
		
		mata: fill = 0
		
		if "`fill'" == "fill" {
			mata: fill = 1
		}
		
		if "`model'" == "BHAR" | "`model'" == "BHAR_raw" {
			keep if `dif' >= `car`cari'LB' & `dif' <= `car`cari'UB'
			gen `difp' = `dif' - `evwlb'
			keep `_id' `returns' `difp'
			reshape wide `returns', i(`_id') j(`difp')
			drop `_id'
			mata BHRE = st_data(.,.)'
			
			if "`model'" == "BHAR_raw" {
				mata: MRE = BHRE :- BHRE
			}
			
			mata: SkewAdjtCI = BHAR(BHRE,MRE,fill)
			
			clear
			local obs = -`car`cari'LB' + `car`cari'UB' + 1
			set obs `obs'
			
			foreach v in "NoFirms" "BHAR" "SkewAdjT" "Sig90Low" "Sig90Up" "Sig95Low" "Sig95Up" "Sig99Low" "Sig99Up" {
				gen `v' = .
			}
			mata: r = 0
			mata: st_view(r,.,.)
			mata: r[.,.] = SkewAdjtCI
			
			gen t= `car`cari'LB'
				replace t= t[_n-1]+1 if _n != 1
			sort t
			order t
			if `cari' == 0 {
				save `aarfile', `replace'
			}
			else{
				tempfile __MataresultsReturns`cari'
				save "`__MataresultsReturns`cari''"
			}
		}
	}

	clear
	 
	forvalues cari = 1/10{
		use "`__MataresultsReturns`cari''", clear
		keep if _n == _N 
		tempfile __MataresultsReturns`cari'_reduced
		save "`__MataresultsReturns`cari'_reduced'"
	 }
	
	clear
	*use `aarfile', clear
	*keep if _n == _N

	forvalues cari = 1/10 {
		append using "`__MataresultsReturns`cari'_reduced'"
	 }

	gen `tstr' = ""
		*replace `tstr' = "Full Event Window" in 1
	forvalues i = 0/9{
		scalar `In' = `i' +1
		local Inl = `In'
		replace `tstr' = "[" + "`car`Inl'LB'" +  ";" + "`car`Inl'UB'" + "]" in `Inl'
	}
	drop t 
	rename `tstr' t
	order t
	capture: keep CA* *CAA* t NoFirms

	saveold `carfile', `replace'
	
	noisily: display "...succeeded"

	***** Diagnostics of data availability *****
	
	noisily: display "Diagnosing events that are excluded from the analysis..."

	use "`__EventsOffDateline'", clear


	gen categorymissing = 0
	gen categorystring = "Event with event date off the dateline" if categorymissing == 0

	append using "`__SecurityWithNoReturns'" 
	replace categorymissing = 1 if categorymissing == . 
	replace categorystring = "Firm/security for which no data is available in the security returns file" if categorymissing == 1
	
	di "`'"


	if "`model'" =="FM" | "`model'" =="RAW" | "`model'" =="COMEAN" | "`model'" =="MA"{
		append using "`__InsufficientEstObsSec'"
		replace categorymissing = 2 if categorymissing == . 
		replace categorystring = "Event with an insufficient number of observations in the security returns file in the estimation period" if categorymissing == 2
	}
	
	append using "`__InsufficientEventObsSec'"
	replace categorymissing = 3 if categorymissing == . 
	replace categorystring = "Event with an insufficient number of observations in the security returns file in the event period" if categorymissing == 3

	if "`model'" =="FM" | "`model'" =="MA"  {
		append using "`__InsufficientEstObsMKT'"
		replace categorymissing = 4 if categorymissing == . 
		replace categorystring = "Event with an insufficient number of observations in the factor returns file in the estimation period" if categorymissing == 4
	}
		
	if "`model'" == "FM" | "`model'" == "MA" | "`model'" == "BHAR" {
		append using "`__InsufficientEventObsMKT'"
		replace categorymissing = 5 if categorymissing == . 
		replace categorystring = "Event with an insufficient number of observations in the factor returns file in the event period" if categorymissing == 5
	}

	append using "`__IPO_DEL_in_event_window'"
	replace categorymissing = 6 if categorymissing == . 
	replace categorystring = "Event for which the IPO (deletion) date of the event firm is later (earlier) than the first (last) day of the event window" if categorymissing == 6
	
	keep `1' `original_event_date' categorymissing categorystring
	rename `original_event_date' `2'
	save `diagnosticsfile', `replace'
	
	noisily: display "...succeeded"
}

log using `diagnosticsfile', `replace'
	display ""
	if `CAR_modified' == 1 {
		di as error "Warning: Some CAR window definitions (options car{it:X}LB and car{it:X}UB) have been changed because they were outside the event window." 
	}
	display as text ""
	display "Number of events in the event file: " `NoOfEntriesEventfile'
	display "-- thereof: Number of events for which security identifiers and event dates are available: " `NoOfEntriesEventfileValid'
	display "-- thereof: Number of events for which event dates are in the range of dates in the security file: " `NoOfEntriesEventfileOnDateline'
	if "`model'" =="FM" | "`model'" =="RAW" | "`model'" =="COMEAN" | "`model'" =="MA"{
		display "-- thereof: Number of events in the analysis (not deleted because of any insufficient data in the estimation or event period): " `NoEventsAvail'
	}
	else{
		display "-- thereof: Number of events in the analysis (not deleted because of any insufficient data in the event period): " `NoEventsAvail'
	}
	display ""
	display "List of security identifiers for which no security market data was available: " `Noreturns'
	display "" 
	if "`model'" =="FM" | "`model'" =="RAW" | "`model'" =="COMEAN" | "`model'" =="MA" {
		display "ANALYSIS OF ESTIMATION PERIOD"
		display ""
		display "Number of events with insufficient security return data: " `NoInsufficientEstObsSec'
		if "`model'" == "FM" | "`model'" == "MA" {
			display "Number of events with insufficient market index/factor return data: " `NoInsufficientEstObsMKT'
		}
	
	display ""
	}
	display "ANALYSIS OF EVENT PERIOD"
	display ""
	display "Number of events with insufficient security return data: " `NoInsufficientEventObsSec'
	if "`model'" == "FM" | "`model'" == "MA" | "`model'" == "BHAR" {
		display "Number of events with insufficient market/index factor return data: " `NoInsufficientEventObsMKT'
	}
	display "Events for which the IPO (deletion) date of the event firm is later (earlier) than the first (last) day of the event window: " `IPO_DEL_in_event_window'
	display ""
log close



use `aarfile', clear

if "`model'" == "BHAR" | "`model'" == "BHAR_raw" {
	
	quietly: twoway (line BHAR t), nodraw
	quietly: graph save "`graphfile'", `replace'
		
	use `carfile', clear
	
	quietly {
		gen Significance = "*" if (SkewAdjT < Sig90Low) | (SkewAdjT > Sig90Up)
			replace Significance = "**" if (SkewAdjT < Sig95Low) | (SkewAdjT > Sig95Up)
			replace Significance = "***" if (SkewAdjT < Sig99Low) | (SkewAdjT > Sig99Up)
	}
		
	log using `diagnosticsfile', append
		list t NoFirms BHAR Significance, clean noobs ab(20) 
	log close
}
else{

	quietly: twoway (line CAARE t), nodraw
	quietly: graph save "`graphfile'", `replace'
	
	quietly {
		foreach v in "t_test" "CDA" "Patell" "PatellADJ" "Boehmer" "Kolari" "Corrado" "Zivney" "GenSign" "Wilcox" {
			gen `v' = "*" if PAARE`v' < 0.1
				replace `v' = "**" if PAARE`v' < 0.05
				replace `v' = "***" if PAARE`v' < 0.01
		}
			
		rename AARE AAR
	}
	log using `diagnosticsfile', append
		list t NoFirms AAR t_test CDA Patell PatellADJ Boehmer Kolari Corrado Zivney GenSign Wilcox, clean noobs ab(20) 
	log close
	
	use `carfile', clear
	
	quietly {
		foreach v in "t_test" "CDA" "Patell" "PatellADJ" "Boehmer" "Kolari" "Corrado_Cowan" "Zivney_Cowan" "GenSign" "GRANKT" "Wilcox"{
			gen `v' = "*" if PCAARE`v' < 0.1
				replace `v' = "**" if PCAARE`v' < 0.05
				replace `v' = "***" if PCAARE`v' < 0.01
		}
		rename CAARE CAAR
	}
	log using `diagnosticsfile', append
		list t NoFirms CAAR t_test CDA Patell PatellADJ Boehmer Kolari Corrado_Cowan Zivney_Cowan GenSign GRANKT Wilcox, clean noobs ab(20) 
	log close
}

log using `diagnosticsfile', append
	display "The following result files are available in the evenstata directory and are loaded into memory by clicking."
	if "`model'" != "BHAR" & "`model'" != "BHAR_raw" {
		display "Graph of cumulative average abnormal returns: {stata graph use `graphfile': `graphfile'}"
	}
	else {
		display "Graph of average buy-and-hold abnormal returns: {stata graph use `graphfile': `graphfile'}"
	}
	if "`model'" != "BHAR" & "`model'" != "BHAR_raw" {
		display "Average abnormal returns (daily basis): {stata use `aarfile', clear: `aarfile'}"
	}
	if "`model'" != "BHAR" & "`model'" != "BHAR_raw" {
		display "Cumulative average abnormal returns: {stata use `carfile', clear: `carfile'}"
	}
	else {
		display "Cumulative average buy-and-hold abnormal returns: {stata use `carfile', clear: `carfile'}"
	}
	if "`model'" != "BHAR" & "`model'" != "BHAR_raw" {
		display "Abnormal returns: {stata use `arfile', clear: `arfile'}"
	}
	else {
		display "Abnormal buy-and-hold abnormal returns: {stata use `arfile', clear: `arfile'}"
	}
	if "`model'" != "BHAR" & "`model'" != "BHAR_raw" {
		display "Cumulative abnormal returns for cross-sectional analyses: {stata use `crossfile', clear: `crossfile'}"
	}
	else{
		display "Buy-and-hold abnormal returns for cross-sectional analyses: {stata use `crossfile', clear: `crossfile'}"
	}
	display "Diagnostic of events that are excluded: {stata use `diagnosticsfile', clear: `diagnosticsfile'}"
	display "Logfile: {stata view `diagnosticsfile'.smcl: `diagnosticsfile'}"
log close

end

***** Test statistics in Mata *****

clear mata

mata:
function KOLARI(AR,STDF,df)
{
	TEst = colsum((AR:+100):/(AR:+100))
	siEst = J(rows(AR),1,(colsum(AR:^2):/(TEst:-(2+df))):^(0.5))  
	CitEst=STDF:/siEst 
	VitEst=AR:/siEst:/(CitEst:^(0.5)) 
	colsEst = cols(VitEst)
	workload = colsEst^2
	progress = 0
	psave = J(colsEst*colsEst,1,.)
	for (i=1; i <= colsEst; i=i+1) {
		for (j=1; j <= colsEst; j=j+1) {
			a = VitEst[1...,i],VitEst[1...,j]
			p = correlation(a)
			psave[(i-1)*colsEst+j,] = p[2,1]
			progress = progress+1
			progress, workload
		}
	}
	nKolari = round(0.5 + sqrt(0.25 + colsum(((psave:-1):/(psave:-1))))) 
	rKolari = mean((psave:-1):/(psave:-1):*psave)
	KolariADJ = ((1-rKolari)/(1+(nKolari-1)*rKolari))^(0.5)
	return(KolariADJ)
}
end

mata:
function TESTSTATS(df,AR,ARE,MR,MRE,KolariADJ,STDFE,NOMARKET)
{
	T = colsum((AR:+100):/(AR:+100))
	AAR = (mm_meancolvar(AR')[1,.])' /* mm_meancolvar(AR') first, then taking the first row */
	AARE = (mm_meancolvar(ARE')[1,.])'
	CAARE = rowsum(mm_colrunsum(ARE):*((ARE:+100):/(ARE:+100))):/ rowsum(((ARE:+100):/(ARE:+100)))
	
	si = J(rows(ARE),1,(colsum(AR:^2):/(T:-(2+df))):^(0.5)) /* See Patell 1976 p. 255: df == zero for market model and 1 for market model plus 1 additional factor */
	Cit = STDFE:/si /* See Patell 1976 p. 256 */  
	/* Some code that proves that this is true: First generate arbitrtay dataset with variables est (dummy indicating estimation and event window), Ri and Rm
		reg Ri Rm if est == 1
		predict AR, resid
		predict stdf, stdf
		predict stdp, stdp
		egen Rmbar = sum(Rm) if est == 1 
		replace Rmbar = Rmbar / 10
		gen Rmtau_minus_Rmbar_squared = (Rm - Rmbar)^2
		egen sum_Rmtau_minus_Rmbar_squared = sum(Rmtau_minus_Rmbar_squared)
		replace Rmbar = Rmbar[_n-1] if Rmbar[_n-1] != .
		egen sit = sum(AR^2) if est == 1 
		replace sit = sqrt(sit / (8))
		replace sit = sit[_n-1] if sit[_n-1] != .
		gen Cit = 1 + 1/10 + (Rm - Rmbar)^2 / sum_Rmtau_minus_Rmbar_squared
		gen Cit_sqrt = sqrt(Cit)
		gen sit_Cit_sqrt = Cit_sqrt * sit

	*/
	
	Vit = ARE:/si:/(Cit:^(0.5))
	Zvt = rowsum(Vit):/(rowsum( (T:-(2+df)):/(T:-(4+df)) )^(0.5))
	NAAREPATELL = Zvt
	PAAREPATELL = 2*normal(-abs(Zvt))
	
	NAAREPATELLADJ = Zvt :* KolariADJ
	PAAREPATELLADJ = 2*normal(-abs(Zvt :* KolariADJ))
	
	L = mm_colrunsum((ARE:+100):/(ARE:+100)):* ((ARE:+100):/(ARE:+100))
	WiL = mm_colrunsum(Vit:/(L:^(0.5))) :* ((ARE:+100):/(ARE:+100))
	ZWL = rowsum(WiL):/(rowsum( (T:-(2+df)):/(T:-(4+df)) )^(0.5))   
	NCAAREPATELL = ZWL
	PCAAREPATELL = 2*normal(-abs(ZWL))
	
	NCAAREPATELLADJ = ZWL :* KolariADJ
	PCAAREPATELLADJ = 2*normal(-abs(ZWL :* KolariADJ))
	
	SARAARE=(rowsum(STDFE:^2):/(rowsum((ARE:+100):/(ARE:+100)):^2)):^0.5 
	NAARE=AARE:/SARAARE
	PAARE=2*ttail(rows(AAR)-(2+df),abs(NAARE))
	
	/* What follows is the Theil 1971 correction for standard error of forecast, e.g. shown in Patell 1976 p. 256; though it does not account for the correction of degrees of freeding in the calculation of standard deviation of ARs as in Eq. (3) in Patell 1976 p. 255 */
	RmbarE = J(rows(ARE),1,mm_meancolvar(MR)[1,.])
	Rmbar = J(rows(AR),1,mm_meancolvar(MR)[1,.])
	denom = J(rows(ARE),1,colsum((MR-Rmbar):^2))
	nomcum = mm_colrunsum(MRE-L:*RmbarE):^2
	if (NOMARKET == 0){
		Citcum = L+L:/J(1,cols(ARE),rowsum((ARE:+100):/(ARE:+100))):+nomcum:/denom
	}
	if (NOMARKET == 1){
		Citcum = L
	}
	sicum = si:*((Citcum):^(0.5)) /* si is the standard deviation of ARs from the estimation period; Citcum take into account the length of the window */
	CAARVARAR = 1:/(rowsum((ARE:+100):/(ARE:+100)):^2):*rowsum(sicum:^2)
	NCAARE = CAARE:/((CAARVARAR):^(0.5)) 
	PCAARE = 2*ttail(rows(AAR)-(2+df),abs(NCAARE)) 
	
	VARAARECRUDE = variance(AAR)*(rows(AAR)-1)/(rows(AAR)-(2+df))  																								   
	NAARECRUDE=AARE/((VARAARECRUDE)^(0.5))
	PAARECRUDE=2*ttail(rows(AAR)-(2+df),abs(NAARECRUDE))     
  
	VARCAARCRUDE = mm_colrunsum(J(rows(ARE),1,1))*VARAARECRUDE
	NCAARECRUDE=CAARE:/((VARCAARCRUDE):^(0.5))
	PCAARECRUDE=2*ttail(rows(AAR)-(2+df),abs(NCAARECRUDE))   
  
	NAAREBOEHMER = (rowsum(Vit):/rowsum((ARE:+100):/(ARE:+100)))  :/    ((rowsum((ARE:+100):/(ARE:+100)):^(-1):*mm_colvar(Vit')'):^(0.5))
	PAAREBOEHMER = 2*ttail(rows(AAR)-(2+df),abs(NAAREBOEHMER)) 
	NCAAREBOEHMER = (rowsum(WiL):/rowsum((ARE:+100):/(ARE:+100))):/((rowsum((ARE:+100):/(ARE:+100)):^(-1):*mm_colvar(WiL')'):^(0.5))
	PCAAREBOEHMER = 2*ttail(rows(AAR)-(2+df),abs(NCAAREBOEHMER))  

	NAAREBOEHMERADJ = NAAREBOEHMER :* KolariADJ
	PAAREBOEHMERADJ = 2*ttail(rows(AAR)-(2+df),abs(NAAREBOEHMERADJ)) /*see Savickas 2003 p. 167 and keep in mind that the term of the variance also includes n-1*/   
	NCAAREBOEHMERADJ = NCAAREBOEHMER:* KolariADJ
	PCAAREBOEHMERADJ = 2*ttail(rows(AAR)-(2+df),abs(NCAAREBOEHMERADJ))
	
	/*GRANK T*/
	SCARstari = (WiL * KolariADJ) :/(((rowsum((ARE:+100):/(ARE:+100)):^(-1):*mm_colvar(WiL')'):^(0.5)) * J(1,cols(WiL),1)) /* WiL is equivalent to SCARitau because it is CAR adjusted for standard deviation of ARs (time-series) incl. prediction error Cit; KolariADJ see Fn 6 in K+P 2011; the remaining part equals the cross-sectional standard deviation of CARs */
	SCARstariLASTROW = SCARstari[rows(SCARstari),.]
	S_ARi = J(rows(AR),1,(colsum(AR:^2):/(T:-(2+df))):^(0.5))
	SARit = AR :/ S_ARi
	ARTOTALGRANK = (SARit\SCARstariLASTROW)
	ARTOTALRANKGRANK = mm_ranks(ARTOTALGRANK)
	ARTOTALRANKGRANK = ARTOTALRANKGRANK :*((ARTOTALGRANK:+100):/(ARTOTALGRANK:+100))
	Uit = ARTOTALRANKGRANK:*((ARTOTALRANKGRANK:+100):/(ARTOTALRANKGRANK:+100)) :/J(rows(ARTOTALRANKGRANK),1,colsum((ARTOTALRANKGRANK:+100):/(ARTOTALRANKGRANK:+100)):+1)  :-0.5
	U_tbar = rowsum(Uit):/ rowsum((Uit:+100):/(Uit:+100)) /* includes Ubar_0 in Eq 13 in K+P 2011 p. 956 */
	T_GRANK = colsum((U_tbar:+100):/(U_tbar:+100)):-1
	S_Ubar = sqrt(T_GRANK :^(-1)  :*  colsum(rowsum((Uit[1::(rows(U_tbar)-1),.]:+100):/(Uit[1::(rows(U_tbar)-1),.]:+100))     :/  rowsum((SCARstariLASTROW:+100):/(SCARstariLASTROW:+100))   :*     U_tbar[1::(rows(U_tbar)-1),.]:^2)  )
	ZGRANK =  U_tbar[rows(U_tbar),.] :/ S_Ubar
	tGRANK = ZGRANK * sqrt((T_GRANK- 2) /(T_GRANK -1 - ZGRANK^2))
	NCAAREGRANKT = tGRANK * rowsum((SCARstari :+ 100) :/ (SCARstari :+ 100)) :/ rowsum((SCARstari :+ 100) :/ (SCARstari :+ 100))
	PCAAREGRANKT =2*ttail(T_GRANK-2,abs(NCAAREGRANKT))
	
	ARTOTAL = (AR\ARE)
	ARTOTALRANK = mm_ranks(ARTOTAL)
	ARTOTALRANK = ARTOTALRANK :*((ARTOTAL:+100):/(ARTOTAL:+100)) /* is Kit in Corrado 1989 p. 388 */
	Onehundert25point5= colsum((ARTOTAL:+100):/(ARTOTAL:+100)) :/2 :+ 0.5
	SKbracket = rowsum((ARTOTALRANK)-  J(rows(ARTOTAL),1,Onehundert25point5)) :/ rowsum((ARTOTAL:+100):/(ARTOTAL:+100))
	SKbracketsqrt = SKbracket :^2
	SK244p5sum = colsum(SKbracketsqrt)
	SKundersqrt = 1/rows(ARTOTAL) * SK244p5sum
	SK = SKundersqrt^0.5
	Tthree = 1:/rowsum((ARTOTAL:+100):/(ARTOTAL:+100)) :* rowsum( rowsum((ARTOTALRANK)-  J(rows(ARTOTAL),1,Onehundert25point5))/ SK)
	NCORRADO = Tthree
	NAARECORRADO = NCORRADO[(rows(AR)+1)::rows(ARTOTAL),1]
	PAARECORRADO = 2*normal(-abs(NAARECORRADO)) 
	
	d12 = mm_colrunsum(J(rows(ARE), 1, 1)):^(0.5) /* The number of cumulated days; Cowan 1992 p. 346 */
	KDbar = (rowsum(mm_colrunsum(ARTOTALRANK[(rows(AR)+1)::rows(ARTOTAL),.])))  :/   mm_colrunsum(rowsum((ARE:+100):/(ARE:+100))) /* KD is the average rank across the n stocks and d days of the event window; Cowan 1992 p. 346 */
	FiftySixNom = mm_colrunsum(rowsum((J(rows(ARE),1,colsum((ARTOTAL:+100):/(ARTOTAL:+100))) :/ 2 :+ 0.5) :* ((ARE:+100):/(ARE:+100))))   :/ mm_colrunsum(rowsum((ARE:+100):/(ARE:+100)))
	Ktbar = rowsum(ARTOTALRANK):/ rowsum((ARTOTAL:+100):/(ARTOTAL:+100)) /* Kt is the average rank across n stocks on day t of the 111 day combined estimation and event period; Cowan 1992 p. 346 */
	onehundredeleven=colsum((Ktbar:+100):/(Ktbar:+100))
	FiftySixDenom = rowsum((J(rows(ARTOTAL),1,colsum((ARTOTAL:+100):/(ARTOTAL:+100))) :/ 2 :+ 0.5) :* ((ARTOTAL:+100):/(ARTOTAL:+100)))   :/ rowsum((ARTOTAL:+100):/(ARTOTAL:+100))
	denomCOWAN = (colsum((Ktbar - FiftySixDenom):^2) / onehundredeleven)^0.5

	NCAARECORRADOCOWAN = (d12 :* (KDbar-FiftySixNom)) :/ denomCOWAN
	PCAARECORRADOCOWAN =2*normal(-abs(NCAARECORRADOCOWAN))
	
	ARSTD = AR :/ ((mm_colvar(AR) :* J(1,1,colsum((AR:+100):/(AR:+100))) :/ ( J(1,1,colsum((AR:+100):/(AR:+100))) :- 1)) ):^0.5 
	ARESTD = ARE :/ ((mm_colvar(AR) :* J(1,1,colsum((AR:+100):/(AR:+100))) :/ ( J(1,1,colsum((AR:+100):/(AR:+100))) :- 1)) ):^0.5
	ARECROSSSECSTD =(  (mm_colvar(ARESTD'))' :* J(1,1,rowsum((ARESTD:+100):/(ARESTD:+100))) :/ ( J(1,1,rowsum((ARESTD:+100):/(ARESTD:+100))) :- 1)):^0.5 
	
	ARESTDBOTHTIMECROSS = ARESTD :/ ARECROSSSECSTD
	ARTOTALZ = (ARSTD\ARESTDBOTHTIMECROSS)

	ARTOTALRANKZ = mm_ranks(ARTOTALZ)
	UiZero = ARTOTALRANKZ:*((ARTOTALZ:+100):/(ARTOTALZ:+100)) :/J(rows(ARTOTALZ),1,colsum((ARTOTALZ:+100):/(ARTOTALZ:+100)):+1)
	UiZeroMinusOneHalf = UiZero:-0.5
	SUbracket = J(1,1,rowsum((ARTOTALZ:+100):/(ARTOTALZ:+100))):^(-0.5) :* rowsum(UiZeroMinusOneHalf) 
	SUbracketsqrt = SUbracket :^2

	SU244p5sum = colsum(SUbracketsqrt)
	SUundersqrt = 1/rows(ARTOTALZ) * SU244p5sum
	SU = SUundersqrt^0.5
	TthreeZ = (J(1,1,rowsum((ARTOTALZ:+100):/(ARTOTALZ:+100)))):^(-0.5) :* rowsum(UiZeroMinusOneHalf / SU)
	NZIVNEY = TthreeZ
	NAAREZIVNEY = NZIVNEY[(rows(AR)+1)::rows(ARTOTALZ),1]
	PAAREZIVNEY = 2*normal(-abs(NAAREZIVNEY)) 

	d12Z = mm_colrunsum(J(rows(ARE), 1, 1)):^(0.5)
	KDbarZ =(rowsum(mm_colrunsum(UiZero[(rows(AR)+1)::rows(ARTOTALZ),.])))  :/   mm_colrunsum(rowsum((ARE:+100):/(ARE:+100)))
	KDbarZminusOneHalf = KDbarZ :- 0.5
	KtbarZ = rowsum(UiZero) :/ J(1,1,rowsum((ARTOTALZ:+100):/(ARTOTALZ:+100)))
	denomCOWANZ = ((colsum((KtbarZ:-0.5):^2) )  / onehundredeleven) :^0.5
	NCAAREZIVNEYCOWAN = (d12Z :* (KDbarZminusOneHalf)) / denomCOWANZ
	PCAAREZIVNEYCOWAN = 2*normal(-abs(NCAAREZIVNEYCOWAN)) 
 
	p = sum(sign(AR))/(2*sum(sign((AR:+100):/(AR:+100))))+0.5
	NAAREGENSIGN = ((rowsum(sign(sign(ARE):+1))):-(rowsum((ARE:+100):/(ARE:+100)):*p)) :/ ( (rowsum((ARE:+100):/(ARE:+100)):*p:*(1:-p)):^(0.5))
	PAAREGENSIGN = 2*normal(-abs(NAAREGENSIGN))
   
	NCAAREGENSIGN = ((rowsum(sign(sign(mm_colrunsum(ARE):*((ARE:+100):/(ARE:+100))):+1))):-(rowsum((ARE:+100):/(ARE:+100)):*p)) :/  ((rowsum((ARE:+100):/(ARE:+100)):*p:*(1:-p)):^(0.5))
	PCAAREGENSIGN = 2*normal(-abs( NCAAREGENSIGN))
	
	/*Calculating Wilcoxson test*/ 
	Sn=rowsum(sign(sign(ARE):+1):*mm_ranks((abs(ARE))')')
	ESn=rowsum((ARE:+100):/(ARE:+100)):*(rowsum((ARE:+100):/(ARE:+100)):+1):/4
	Sigma2Sn=rowsum((ARE:+100):/(ARE:+100)):*(rowsum((ARE:+100):/(ARE:+100)):+1) :*(2:*rowsum((ARE:+100):/(ARE:+100)):+1):/24
	NAAREWILCOX=(Sn:-ESn):/(Sigma2Sn:^(0.5))
	PAAREWILCOX=2*normal(-abs(NAAREWILCOX))

	NCAAREWILCOXsave=.
	PCAAREWILCOXsave=.
  
	rc=1
	quietly: while (rc <= rows(ARE)) { 
		Sn=rowsum(sign   (sign(   vec(ARE[1..rc,.]')  '):+1)  :*mm_ranks(abs(vec(ARE[1..rc,.]')')')')
		
		ESn=rowsum((vec(ARE[1..rc,.]')':+100):/(vec(ARE[1..rc,.]')':+100)):*(rowsum((vec(ARE[1..rc,.]')':+100):/(vec(ARE[1..rc,.]')':+100)):+1)  :/4
		
		Sigma2Sn= rowsum((vec(ARE[1..rc,.]')':+100):/(vec(ARE[1..rc,.]')':+100)):*(rowsum((vec(ARE[1..rc,.]')':+100):/(vec(ARE[1..rc,.]')':+100)):+1)    :*    (rowsum((vec(ARE[1..rc,.]')':+100):/(vec(ARE[1..rc,.]')':+100)) :*2 :+1)  :/ 24
		
		NCAAREWILCOX=(Sn:-ESn):/(Sigma2Sn:^(0.5))
		PCAAREWILCOX=2*normal(-abs(NCAAREWILCOX))
		vec(ARE[1..rc,.]')'
		NCAAREWILCOXsave=NCAAREWILCOXsave\NCAAREWILCOX
		PCAAREWILCOXsave=PCAAREWILCOXsave\PCAAREWILCOX
		rc++
	}
	NCAAREWILCOX=NCAAREWILCOXsave[2..rows(NCAAREWILCOXsave),1..1]
	PCAAREWILCOX=PCAAREWILCOXsave[2..rows(PCAAREWILCOXsave),1..1]
	
	NoFirms = rowsum((ARE:+100):/(ARE:+100))
	
	return(NoFirms,AARE,NAARE,PAARE,NAARECRUDE,PAARECRUDE,NAAREPATELL,PAAREPATELL,NAAREPATELLADJ,PAAREPATELLADJ,NAAREBOEHMER,PAAREBOEHMER,NAAREBOEHMERADJ,PAAREBOEHMERADJ,NAARECORRADO,PAARECORRADO,NAAREZIVNEY,PAAREZIVNEY,NAAREGENSIGN,PAAREGENSIGN,NAAREWILCOX, PAAREWILCOX, CAARE,NCAARE,PCAARE,NCAARECRUDE,PCAARECRUDE,NCAAREPATELL,PCAAREPATELL,NCAAREPATELLADJ,PCAAREPATELLADJ,NCAAREBOEHMER,PCAAREBOEHMER, NCAAREBOEHMERADJ,PCAAREBOEHMERADJ,NCAARECORRADOCOWAN,PCAARECORRADOCOWAN,NCAAREZIVNEYCOWAN,PCAAREZIVNEYCOWAN,NCAAREGENSIGN,PCAAREGENSIGN, NCAAREGRANKT, PCAAREGRANKT, NCAAREWILCOX, PCAAREWILCOX)
}
end

mata:
function SkewAdjtNonBS(X) 
{
	ARb = mm_meancolvar(X)[1,.]
	S = ARb:/(mm_colvar(X):^0.5)
	y = sqrt(colsum((X:+100):/(X:+100)) :*        (colsum((X:+100):/(X:+100)):-1))           :/ (colsum((X:+100):/(X:+100)):-2)   :/ (colsum((X:+100):/(X:+100)))  :*   colsum((X:-J(rows(X),1,ARb)):^3) :/  (mm_colvar(X):^0.5):^3 /* Lyon and Barber 1999 p. 174 say that y is an estimate of the coefficient of skewness -> sample skewness, see https://www.itl.nist.gov/div898/handbook/eda/section3/eda35b.htm */ 
	t = (colsum((X:+100):/(X:+100))):^0.5 :* (S + 1/3:*y:*S:^2 + 1/6:/colsum((X:+100):/(X:+100)):*y)
	return(t)
}
end

mata:
function SkewAdjt(X,w,ARNonBS)
{
	ARb = mm_meancolvar(X)[1,.]
	S = (ARb:-ARNonBS):/(mm_colvar(X):^0.5)
	y = sqrt(colsum((X:+100):/(X:+100)) :*        (colsum((X:+100):/(X:+100)):-1))           :/ (colsum((X:+100):/(X:+100)):-2)   :/ (colsum((X:+100):/(X:+100)))  :*   colsum((X:-J(rows(X),1,ARb)):^3) :/  (mm_colvar(X):^0.5):^3
	/* Lyon and Barber 1999 p. 174 say that y is an estimate of the coefficient of skewness -> sample skewness, see https://www.itl.nist.gov/div898/handbook/eda/section3/eda35b.htm */ 
	t = (colsum((X:+100):/(X:+100))):^0.5 :* (S + 1/3:*y:*S:^2 + 1/6:/colsum((X:+100):/(X:+100)):*y)
	return(t)
}


mata:
function BHAR(BHRE,MRE,fill)
{
	BHRE1 = BHRE :+ 1
	_editmissing(BHRE1,1)
	  MRE1 = MRE :+ 1 
	_editmissing(MRE1,1)
	
	for (i=2; i<=rows(BHRE1); i++) {
		BHRE1[i,.] = BHRE1[i-1,.] :* BHRE1[i,.]
	}
	
	if (fill != 1) {
		BHRE1 = BHRE1 :* ((BHRE:+100):/(BHRE:+100)) 
	}
	
	BHREACC = BHRE1 :- 1
	 
	for (i=2; i<=rows(MRE1); i++) {
		MRE1[i,.] = MRE1[i-1,.] :* MRE1[i,.]
	}

	if (fill != 1) {
		MRE1 = MRE1 :* ((MRE:+100):/(MRE:+100)) 
	}
	
	MREACC = MRE1 :- 1 
	
	NoFirms = rowsum((BHRE1:+100):/(BHRE1:+100):*(MRE1:+100):/(MRE1:+100))'
	
	BHREACC = BHREACC :- MREACC
	BHREACC = BHREACC'
	
	ARbar = mm_meancolvar(BHREACC)[1,.]
	
	ARbNonBS = mm_meancolvar(BHREACC)[1,.]  
	
	bs = mm_bs(&SkewAdjt(),BHREACC,1,1000,rows(BHREACC)/4,0,strata=.,cluster=.,stat=.,ARbNonBS)
	
	SkewAdjtCI = (NoFirms\ARbNonBS\SkewAdjtNonBS(BHREACC)\mm_bs_report(bs,"p",90)\mm_bs_report(bs,"p",95)\mm_bs_report(bs,"p",99))'
	
	return(SkewAdjtCI)
}
end
