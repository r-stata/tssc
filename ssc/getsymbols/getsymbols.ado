*! returnsqg, version 1.0, <<<<Oct 2017
* Author: Alberto Dorantes, Ph.D.  Monterrey Tech, Querétaro Campus, México
** Prepared to work with at least 3 free databases of Quandl.com: WIKI, CBOE, NASDAQOMX, and CHRIS
* See https://www.quandl.com/search?query=  to learn about these databases

capture program drop getsymbols
program def getsymbols, rclass
version 11.0

syntax anything(name=lista), [database(string)] [GOogle] [YAhoo] [VANtage]  [CURrency(string)] [fm(integer 1)] [fd(integer 1)] [fy(integer 1990)] [lm(integer 12)] [ld(integer 31)] [ly(integer 2099)] [FRequency(string)] [price(string)] [KEEPall] [CASEwise] [clear] [apikey(string)]
tempname i j NP simbolo stsimbolo ticks freq vari datevar listavar source urlgoogle urlquandl urlyahoo inidate enddate
tempfile arch1 archivo
tempvar temp1

local urlquandl = "https://www.quandl.com/api/v3/datasets/"
local urlgoogle = "http://finance.google.com/finance/historical?q="
local urlyahoo = "https://l1-query.finance.yahoo.com/v7/finance/chart/"
local urlvantage ="https://www.alphavantage.co/query?function="

local f1=date("`fd'-`fm'-`fy'","DMY")
local f2=date("`ld'-`lm'-`ly'","DMY")
if (missing(`f1') | missing(`f2')) {
  display as error "Your initial or end date are not valid.."
  exit
}
else if (`f2'<`f1') {
  display as error "Your start date must be an earlier date compared with end date"
  exit
}  
else if (`f2'>date(c(current_date),"DMY") & `ly'!=2099) { 
  local ld=day(date(c(current_date),"DMY")-1)
  local lm=month(date(c(current_date),"DMY")-1)
  local ly=year(date(c(current_date),"DMY")-1)
  display "You specified a future date, so the last date was changed to today's date"
} 

local source="Quandl"
if "`google'"!="" {
  local source="Google"
}
if "`yahoo'"!="" {
  local source="Yahoo"
}

if "`vantage'"!="" {
  local source="Alpha Vantage"
}


if "`clear'"!="" { 
   clear
}
else {
capture count
if r(N)>0 {
  display as error "You have to start with an empty dataset before downloading data"
  exit
}
}
local i=0
local ticks=""
  if "`database'"=="" {
    local database="WIKI"
  }	
  if ("`frequency'"=="") {
    local frequency="d"
  }	

if "`source'"=="Yahoo" {

  local datestr1="`fd'/`fm'/`fy'"
  local period1: di %22.0f (date("`datestr1'","DMY")-3653)*(86400)
  * 86400=24*60*60
  local datestr2="`ld'/`lm'/`ly'"
  local period2: di %22.0f (date("`datestr2'","DMY")-3652)*(86400)
  local period1 = trim("`period1'")
  local period2 = trim("`period2'")
  local freq="1d"
  if ("`frequency'" != "d" & "`frequency'" != "w" & "`frequency'" != "m" & "`frequency'"!="q" ///
     & "`frequency'"!="1min" & "`frequency'"!="5min" & "`frequency'"!="15min" & "`frequency'"!="30min") {
   display as error "Frequency may be one of d,w, m, or q or mins"
   exit
  }
  else {
    if "`frequency'"=="m" {
	   local freq="1mo"
	} 
	else if "`frequeny'"=="w" {
	   local freq="1wk"
	}
	else if "`frequency'"=="q" {
	   local freq="3mo"
	}
  }
  *display "Fecha inicial: `fd'/`fm'/`fy', fecha inicial yahoo: `period1'"
}
else {
* if source is either Quandl or Google Finance or Vantage
  local freq="daily"
  if "`database'"=="" {
    local database="WIKI"
  }	
  if ("`frequency'" != "d" & "`frequency'" != "w" & "`frequency'" != "m" & "`frequency'"!="q" & "`frequency'" !="a"  ///
     & "`frequency'"!="1min" & "`frequency'"!="5min" & "`frequency'"!="15min" & "`frequency'"!="30min") {
   display as error "Frequency may be one of d,w, m, or q or mins"  
   exit
  }
  else { 
    if ("`frequency'"=="m" & "`google'"=="") {
	   local freq="monthly"
	} 
	else if ("`frequeny'"=="w" & "`google'"=="")  {
	   local freq="weekly"
	}
	else if ("`frequency'"=="q" & "`google'"=="")  {
	   local freq="quarterly"
	}
	else if ("`frequency'"=="a" & "`google'"=="")  {
	   local freq="annual"
	}
	else if ("`frequency'"!="d" & "`google'"!="") {
	  display "Google has only daily data"
	}
  }  
  if `fm'<10 local fm="0`fm'"
  if `fd'<10 local fd="0`fd'"
}
  
foreach simbolo in `lista'{
  tempfile stockquote
  if "`source'"=="Yahoo" {
     capture quietly copy "`urlyahoo'`simbolo'?interval=3mo " `stockquote'
	 if _rc==0 {
	   if "`price'"=="" local keepall="keepall" 
	   quietly: mata: m_getsymbol("`urlyahoo'", "`simbolo'","`period1'", "`period2'","`freq'", "`keepall'", "`price'") 
	   if (r(rc)!=0) {
	     display as error "Yahoo Finance does not have complete/formatted data for the symbol: `simbolo'" 
	     exit 
		}
	 }
	 else {
	   display as error "Error while getting data from Yahoo Finance: " _rc
	   display as error "The ticker `simbolo' might not exist or did not exist in the specified dates."
	   exit
	 }
  }
  else {
  
  if "`source'"=="Google" {
    local url = "`urlgoogle'"
    capture quietly copy "`url'`simbolo'&startdate=`fm'/`fd'/`fy'&enddate=`lm'/`ld'/`ly'&collapse=`freq'&output=csv " `stockquote'
	*display "`url'`simbolo'&startdate=`fm'/`fd'/`fy'&enddate=`lm'/`ld'/`ly'&collapse=`freq'&output=csv "
  }
  else if "`source'"=="Quandl" {
  local url = "`urlquandl'`database'/"
  if "`apikey'"=="" {
    capture quietly copy "`url'`simbolo'.csv?start_date=`fy'-`fm'-`fd'&end_date=`ly'-`lm'-`ld'&order=asc&collapse=`freq' " `stockquote'
	*display "url: `url'`simbolo'.csv?start_date=`fy'-`fm'-`fd'&end_date=`ly'-`lm'-`ld'&order=asc&collapse=`freq' "
  } 
  else {
    capture quietly copy "`url'`simbolo'.csv?start_date=`fy'-`fm'-`fd'&end_date=`ly'-`lm'-`ld'&order=asc&collapse=`freq'&api_key=`apikey' " `stockquote'
	*display "url: `url'`simbolo'.csv?start_date=`fy'-`fm'-`fd'&end_date=`ly'-`lm'-`ld'&order=asc&collapse=`freq'&api_key=`apikey' "
  }
  }
  else if "`source'"=="Alpha Vantage" {
  local url = "`urlvantage'"
  local func="TIME_SERIES_DAILY_ADJUSTED"
   if ("`frequency'"=="d" & ("`price'"=="adjusted_close" | "`price'"=="")) {
      local func="TIME_SERIES_DAILY_ADJUSTED"
   }
   else if ("`frequency'"=="d" & "`price'"=="close") {
      local func="TIME_SERIES_DAILY"
   }
   else if ("`frequency'"=="m"  & ("`price'"=="adjustedclose" | "`price'"=="")) {
      local func="TIME_SERIES_MONTHLY_ADJUSTED"
   }	  
   else if ("`frequency'"=="m" & "`price'"=="close") {
      local func="TIME_SERIES_MONTHLY" 
   }
   else if ("`frequency'"=="w" & ("`price'"=="adjustedclose" | "`price'"=="")) {
      local func="TIME_SERIES_WEEKLY_ADJUSTED" 
   }
   else if ("`frequency'"=="w" & "`price'"=="close") {
     local func="TIME_SERIES_WEEKLY" 
   }
   else if ("`frequency'"=="30min" | "`frequency'"=="15min" | "`frequency'"=="5min" | "`frequency'"=="1min") {
     local func="TIME_SERIES_INTRADAY"
   }
   if ("`frequency'"=="d" & "`currency'"!="") {
      local func="DIGITAL_CURRENCY_DAILY"
   }
   else if ("`frequency'"=="m"  & "`currency'"!="") {
      local func="DIGITAL_CURRENCY_MONTHLY"
   }	  
   else if ("`frequency'"=="w" & "`currency'"!="") {
      local func="DIGITAL_CURRENCY_WEEKLY" 
   }
   if (("`frequency'"=="d" | "`frequency'"=="m" | "`frequency'"=="w" | "`frequency'"=="q" | "`frequency'"=="a") & ("`currency'"==""))  {
     capture quietly copy "`url'`func'&symbol=`simbolo'&outputsize=full&datatype=csv&apikey=`apikey' " `stockquote'
	}
   else if 	(("`frequency'"=="d" | "`frequency'"=="m" | "`frequency'"=="w" | "`frequency'"=="q" | "`frequency'"=="a") & ("`currency'"!=""))  {
     capture quietly copy "`url'`func'&symbol=`simbolo'&market=`currency'&datatype=csv&apikey=`apikey' " `stockquote'
   }
   else {
     capture quietly copy "`url'`func'&symbol=`simbolo'&interval=`frequency'&outputsize=full&datatype=csv&apikey=`apikey' " `stockquote'
   
   }
    *display "`url'`func'&symbol=`simbolo'&market=`currency'&datatype=csv&apikey=`apikey' " 
  }
  if _rc != 0 {
   display as error "Error while getting data from `source': " _rc
   display as error "`source' does not have the ticker `simbolo' or could not be reached"
*   display "Please make sure you are online and/or redefine your range"
   *display "url: `url';  ticker: `simbolo'  dates: start_date=`fy'-`fm'-`fd'&end_date=`ly'-`lm'-`ld'&order=asc&collapse=`freq'"
   exit
  }
  clear
  quietly insheet using `stockquote'
  }
  local j=0
  local listavar=""
  foreach vari of varlist * {
     local j=`j'+1
	 if `j'==1 local datevar="`vari'"
	 else local listavar="`listavar' `vari'"
  }
  if "`listavar'"=="" {
     display as error "The symbol `simbolo' might not exist or it has no variables"
	 if "`source'"=="Alpha Vantage" {
	   display as error "It is also possible that you need to specify a valid apikey; you can get one from the Alpha Vantage site"
	 }
	 clear
	 capture use `archivo', clear 
	 exit
  }
  if `i'==0 {
    display as txt "The data is being pulled from `source'.com ; the variables of this dataset are:"
	display as txt "     `listavar'"
  }
  
  local ticks="`ticks' `simbolo'"
  if "`source'"=="Google" {
   gen daten=date(`datevar',"DMY",2050)
   format daten %td
   sort daten
  }
  else if (("`source'"=="Quandl" | "`source'"=="Alpha Vantage") & ("`frequency'"=="d" | "`frequency'"=="m" | "`frequency'"=="w" | "`frequency'"=="q")) {
   capture gen daten=date(`datevar',"YMD")
   if _rc!=0 { 
     capture gen daten=date(`datevar',"MDY")
	 if _rc!=0 {
	   capture gen daten=date(`datevar',"YMD")
	   if _rc!=0 {
	     capture gen daten=date(`datevar',"DMY")
	   }
	 }
   }
   if _rc==0 {
   format daten %td 
   sort daten
   }
   else { 
     display "First variable of the dataset is not a date variable... ")
     gen daten=`datevar'
   }	 
  }
   else if "`source'"=="Alpha Vantage" {
    *sort `datevar'
   gen daten=`datevar'
   *drop `datevar'
   *gen daten=date(substr(`datevar',1,10),"YMD")
/*
   gen `temp1'=substr(`datevar',12,2)
   qui destring `temp1',gen(`hr1')
   qui replace `temp1'=substr(`datevar',15,2)
   qui destring `temp1', gen(`min1')
   qui replace `temp1'=substr(`datevar',18,2)
   qui destring `temp1', gen(`seg1')
   *exit
   *gen tspn=Cdhms(d1,hr1,min1,seg1)
   *exit
   *format tspn %tC
   exit
   qui drop temp1 d1 hr1 min1 seg1
   *exit
*/  
  } 
  else {
   ren date daten
   format daten %td
  }

  if ("`source'"=="Alpha Vantage" & ("`frequency'"=="d" | "`frequency'"=="m" | "`frequency'"=="w")) {
    local inidate=date("`fy'/`fm'/`fd'","YMD")
	local enddate=date("`ly'/`lm'/`ld'","YMD")
	capture keep if daten>=`inidate' & daten<=`enddate'
  }
  sort daten
  local i=`i'+1
  local stsimbolo=strtoname("`simbolo'",0)
  if strlen("`stsimbolo'")>20 {
     local stsimbolo=substr("`stsimbolo'",1,20)
  }
  gen t=_n
  
  if ("`frequency'"=="m") {
    gen period=mofd(daten)
    format period %tm
	label var period "Month"
    capture tsset t
	qui drop if period==F1.period
	capture tsset period
  } 
  else if ("`frequency'"=="w") {
    gen period=wofd(daten)
    format period %tw
	label var period "Week"
    capture tsset t
	qui drop if period==l1.period
	capture tsset period
  }
  else if ("`frequency'"=="q") {
    gen period=qofd(daten)
    format period %tq
	label var period "Quarter"
	capture tsset period
  }
  else if ("`frequency'"=="a") {
    gen period=year(daten)
	label var period "Year"
	capture tsset period
  }
  else if ("`frequency'"=="d") {
    gen period=daten
	format period %td
	label var period "Day"
	capture tsset t
	qui drop if period==l1.period
  } 
  else {
    gen period=`datevar'
	drop `datevar'
	*format period %td
    capture tsset t
  }
  if "`price'"!="" {
  capture gen r_`stsimbolo'=ln(`price'/L1.`price')
  if (_rc!=0) {
    display as error "Error price name; price `price' does not exist. Error " _rc
	display as text "According to this database, you can specify as price any of the following: `listavar'"
	display as text "Returns will not be calculated" 
  }
  else {
  quietly gen R_`stsimbolo'=`price'/L1.`price' - 1 
  label var r_`stsimbolo' "`stsimbolo' Continuously Compounded Ret"
  label var R_`stsimbolo' "`stsimbolo' Simple Return"
   if `i'==1 display "Period returns were calculated using the variable: `price' and only this variable was kept; if you want to keep all variables use the option keepall"
  }
  }
  
  if "`price'"!="" capture ren `price' p_`price'_`stsimbolo'
  local listavar: list listavar - price
  foreach vari of local listavar {
     ren `vari' `vari'_`stsimbolo'
  }
  
  if ("`keepall'"=="" & "`price'"!="") {
    capture keep period p_`price'_`stsimbolo' r_`stsimbolo' R_`stsimbolo' vol*
	if _rc!=0 capture keep period p_`price'_`stsimbolo' r_`stsimbolo' R_`stsimbolo' 
	capture order period p_`price'_`stsimbolo' r_`stsimbolo' R_`stsimbolo' vol*
    capture label var p_`price'_`stsimbolo' "`stsimbolo' `price' Price"
  }
  else { 
    capture order period, first
	capture order daten, after(period)
  }	
  capture drop t
  qui save `arch1', replace
  
   if (`i'==1) {
   quietly save `archivo', replace
   
  }	
  else {
    use `archivo', clear 
	quietly merge 1:1 period using `arch1'
	if "`casewise'"!="" { 
	   keep if _merge==3
	}
    drop _merge
	quietly save `archivo', replace
  }  
  *}
  display as input "Symbol `simbolo' was downloaded"

  }
*qui sort period
capture order period, first
capture order daten, after(period)
capture tsset period

capture su period
if r(N)>0 {
 local NP=`r(N)'
 display as result "`NP' periods of `i' symbol(s) from `source' were downloaded."
}
if "`casewise'"=="casewise" {
 display "Casewise deletion was applied; only periods with data for all symbols were kept."
} 

capture corr p_*
if _rc==0 {
display "Number of observations with valid prices for all symbols:", r(N)," out of ",`NP'
}

if "`source'"=="Google" {
label data "Source: Google Finance"
}
else if "`source'"=="Yahoo" { 
label data "Source: Yahoo Finance!" 
}
else if "`source'"=="Alpha Vantage" {
 label data "Source: Alpha Vantage" 
}
else {
label data "Source: Quandl.com, database: `database'"
}
/*
display "Means and correlations of Continuously Compounded returnrs r:"
capture corr r*, mean
if _rc!=0 {
  display "Correlation matrix could not be estimated due to missing values after casewise deletion"
}  
else {
corr r*, mean
}
*/
return local tickerlist "`ticks'"
return scalar numtickers=`i'
end


