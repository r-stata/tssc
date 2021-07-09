*---------------------------eventstudy.ado
*!----version 1.0.2
*!----programmer: Chuntao Li, Xin Xu
*!----Email Address: chtl@znufe.edu.cn; xinkexuxin@gmail.com
*!----date 04mar2013
* 
capture program drop eventstudy
program define eventstudy, rclass
version 12
syntax  using/, event_file_name(string) trade_file_name(string) rit(string) ///
rmt(string) firm_id(string) trade_date(string) event_id(string) event_control(string)  ///
event_firm_id(string) event_date(string) event_window_st(int) ///
event_window_end(int) est_window_st(int) est_window_end(int)
version 12.0 

qui{
use `"`event_file_name'"', clear
sort `event_firm_id' `event_date'
mkmat `event_id' `event_firm_id' `event_date', mat(EVENT)
local EVENT_NUM = _N
drop _all 

capture mkdir `"d:\temp"'

use `"`trade_file_name'"', clear
keep `firm_id' `trade_date' `rit' `rmt'
sort `firm_id' `trade_date'
forvalues i=1/`EVENT_NUM'{ 
	outsheet using `"d:\temp\before_event_`i'.txt"' if `firm_id'==scalar(EVENT[`i',2])& ///
	`trade_date'<scalar(EVENT[`i',3])&`trade_date'>=scalar(EVENT[`i',3])+`est_window_st',replace
	outsheet using d:\temp\after_event_`i'.txt if `firm_id'==scalar(EVENT[`i',2])& ///
	`trade_date'>=scalar(EVENT[`i',3])&`trade_date'<=scalar(EVENT[`i',3])-`est_window_st',replace
}
forval i=1/`EVENT_NUM'{
	insheet using `"d:\temp\before_event_`i'.txt"',clear
	gen temp=date(`trade_date',"YMD")
	format temp %tdCY_N_D
	drop `trade_date'
	rename temp `trade_date'
	drop if abs(`rit')>0.11
	gsort -`trade_date'
	gen time=-_n
	save `"d:\temp\before_event_`i'.dta"',replace
	
	insheet using `"d:\temp\after_event_`i'.txt"',clear
	gen temp=date(`trade_date',"YMD")
	format temp %tdCY_N_D
	drop `trade_date'
	rename temp `trade_date'
	drop if abs(`rit')>0.11 
	sort `trade_date'
	gen time=_n-1	
	save `"d:\temp\after_event_`i'.dta"',replace
}

local j=0

forval i=1/`EVENT_NUM'{
	use `"d:\temp\before_event_`i'.dta"',clear
	tab `firm_id'
	if r(N)<(`est_window_end'-`est_window_st')/3{
		continue
	}
	use `"d:\temp\after_event_`i'.dta"',clear
	tab `firm_id'
	if r(N)<(`est_window_end'-`est_window_st')/3{
		continue
	}
	local j=`j'+1
	append using `"d:\temp\before_event_`i'.dta"'
	sort time	
	keep if time<=`est_window_end'|(time>=`event_window_st'&time<=`event_window_end')
	*gen event=`j'
	gen `event_id'=scalar(EVENT[`i',1])
	save `"d:\temp\event_`j'.dta"',replace
	describe
}
forvalues i=1/`j'{
	use `"d:\temp\event_`i'.dta"',clear
	regress `rit' `rmt' if time>=`est_window_st'&time<=`est_window_end'
	predict AR if time>=`event_window_st'&time<=`event_window_end',residual
	keep if AR!=.  //equal to the condition that : time>=`event_window_st'&time<=`event_window_end'
	save `"d:\temp\event_`i'.dta"',replace
	describe
}
use `"d:\temp\event_1.dta"',clear
capture erase `"d:\temp\event_1.dta"'
forvalues i=2/`j'{
	append using `"d:\temp\event_`i'.dta"'
	capture erase `"d:\temp\event_`i'.dta"'
}
disp `event_id'
sort `event_id' time
bysort `event_id': gen CAR=sum(AR)
merge m:1 `event_id' using `"`event_file_name'"'
keep if _m==3
drop _merge



keep `event_id' `event_date' `event_control' `event_firm_id' `trade_date' time AR CAR
order `event_id' `event_date' `event_control' `event_firm_id' `trade_date' time AR CAR

forvalues i=1/`EVENT_NUM'{
	capture erase `"d:\temp\before_event_`i'.dta"'
	capture erase `"d:\temp\after_event_`i'.dta"'
	capture erase `"d:\temp\before_event_`i'.txt"'
	capture erase `"d:\temp\after_event_`i'.txt"'
	capture erase `"d:\temp\event`i'.dta"'
}
capture erase `"d:\temp\event_set.dta"'
capture rmdir `"d:\temp"'
}

save `"`using'"',replace
end
