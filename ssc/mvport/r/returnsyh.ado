*! returnsyh, version 1.0, Sep 2013
* Author: Alberto Dorantes, ITESM, Querétaro, México
capture program drop returnsyh
program def returnsyh, rclass
version 11.0

syntax anything(name=lista), fm(integer) fd(integer) fy(integer) lm(integer) ld(integer) ly(integer) frequency(string) price(string) [CASEwise]
tempname i NP simbolo stsimbolo bugfm buglm ticks
local i=0
tempfile arch1 archivo
local ticks=""
foreach simbolo in `lista'{ 
  local url = "http://ichart.finance.yahoo.com/table.csv"
  if ("`frequency'" != "d" & "`frequency'" != "w" & "`frequency'" != "m"){
   display as error "frequency may be one of d,w or m"
  exit
  }
  local bugfm = `fm'-1
  local buglm = `lm'-1
  tempfile stockquote
  capture quietly copy "`url'?s=`simbolo'&a=`bugfm'&b=`fd'&c=`fy'&d=`buglm'&e=`ld'&f=`ly'&g=`frequency'&ignore=.csv" `stockquote'
  if _rc != 0{
   display as error "Yahoo does not have the ticker `simbolo' or could not be reached"
   display "Please make sure you are online and/or redefine your range"
   *exit
  }
  else {
  clear
  quietly insheet using `stockquote'
  qui su
  if r(N)==1 {
   display as error "The ticker `simbolo' only has 1 observation; it will not be processed. Expand the time window"
   exit
  }
  local ticks="`ticks' `simbolo'"
  gen daten=date(date,"YMD")
  format daten %td
  sort daten
  local i=`i'+1
  local stsimbolo=strtoname("`simbolo'",0)  
  gen t=_n
  if ("`frequency'"=="m") {
    gen period=mofd(daten)
    format period %tm
	label var period "Month"
	qui tsset period
  } 
  else if ("`frequency'"=="w") {
    gen period=wofd(daten)
    format period %tw
	label var period "Week"
    qui tsset t
	qui drop if period==l1.period
	qui tsset period
  }
  else {
    gen period=daten
	format period %td
	label var period "Day"
	qui tsset t
  } 
  capture gen r_`stsimbolo'=ln(`price'/L1.`price')
  if (_rc!=0) {
    display as error "Error price name. Valid price names are close, adjclose, open, high, low"
	exit
  }
  quietly gen R_`stsimbolo'=`price'/L1.`price' - 1 
  ren `price' p_`price'_`stsimbolo'
  ren volume vol_`stsimbolo'

  keep period p_`price'_`stsimbolo' r_`stsimbolo' R_`stsimbolo' vol_`stsimbolo'
  label var r_`stsimbolo' "`stsimbolo' Continuously Compounded Ret"
  label var R_`stsimbolo' "`stsimbolo' Simple Return"
  label var p_`price'_`stsimbolo' "`stsimbolo' `price' Price"
  label var vol_`stsimbolo' "`stsimbolo' Volumen"
  quietly save `arch1', replace
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
  }
}
*qui sort period
qui order period, first
qui tsset period

quietly su period
local NP=`r(N)'
display as result "`i' stocks from Yahoo Finanzas were downloaded; `NP' periods in the time series"
if "`casewise'"=="casewise" {
 display "Casewise deletion was applied in case there were no match between the stock series"
} 
display "Number of observations with valid continuously compounded returns for all stocks:", r(N)," out of ",`NP'
label data "Source: http://finance.yahoo.com"
display "Means and correlations of Continuously Compounded returnrs r:"
capture corr r*, mean
if _rc!=0 {
  display "Correlation matrix could not be estimated due to missing values after casewise deletion"
}  
else {
corr r*, mean
}
return local tickerlist "`ticks'"
return scalar numtickers=`i'
end

