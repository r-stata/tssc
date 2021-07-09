clear all
set more off

capture mkdir d:\eventstudy\
cd d:\eventstudy\

set obs 1000000

gen int firm_id = _n/10000+23
replace firm_id =23 if firm_id==123
sort firm_id
by firm_id: gen trade_date = _n+mdy(8,29,2000)
format trade_date %dCY_N_D
drop if dow(trade_date)==0 | dow(trade_date)==6
drop if uniform()<.02

sort trade_date 
bysort trade_date: gen rmt =(uniform()-0.5)*0.05
gen rit=.
forval i = 23(1) 123 {
	local beta = uniform()*3-0.8
	qui replace rit = `beta'*rmt+invnorm(uniform())*0.03 if firm_id==`i'
}

sort firm_id trade_date
save trade, replace 
keep firm_id trade_date 

gen rand = uniform()
sort rand
keep if _n <= 10
rename rand event_control
sort firm_id trade_date 
gen event_id = _n 
rename trade_date event_date
save event, replace 

* define the event 
local event_file_name d:\eventstudy\event.dta
local event_id  event_id 
local event_firm_id firm_id 
local event_date event_date 
local event_control event_control
*define the trade data
local trade_file_name d:\eventstudy\trade.dta
local trade_rit rit 
local trade_rmt rmt 
local trade_firm_id firm_id
local trade_date trade_date

*define the event study
local event_window_st = -3
local event_window_end = 2
local est_window_st = -200
local est_window_end = -10

eventstudy using d:\result.dta ,event_file_name(`event_file_name') trade_file_name(`trade_file_name') rit(`trade_rit') ///
rmt(`trade_rmt') firm_id(`trade_firm_id') trade_date(`trade_date') event_id(`event_id') event_control(`event_control') /// 
event_firm_id(`event_firm_id') event_date(`event_date') event_window_st(`event_window_st')  ///
event_window_end(`event_window_end') est_window_st(`est_window_st') est_window_end(`est_window_end')

