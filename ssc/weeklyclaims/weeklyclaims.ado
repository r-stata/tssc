*! version on 2.0 07jun2012


/*
   We HTTP GET from www.askitas.com which HTTP POSTs to workforcesecurity.doleta.gov.
   Dear STATA, 
   For next Christmas pleaase make stata do HTTP POST, ok? Data should come 
   from the net with provision APIs. You got it half right so far by making 
   stata into an almost browser.
   Yours,
   N.
   Dear US Dept of Labor,
   you need to go into data provisioning and not just presentation. I know many people
   glue things the pedestrian way with excel and other such cilivizational deficits but...
   Please expose a CGI which can be programmed and returns some structured data which
   can be consumed by statistical or web applications. What the world can 
   do with anyone's data is a gazillion times grander than what any single entity 
   can...
   Yours,
   N.
   Think of this as a little data advocacy application and have fun with it!
   weeklyclaims US
   weeklyclaims IN
*/

program def weeklyclaims
version 9.0

syntax anything(name=level)

local url = "http://www.askitas.com/cgi-bin/weeklyclaims.cgi"


set more off
qui tempfile ijc_raw

if regexm("`level'", "US"){
 local level =lower("US")
}

if regexm("`level'", "us"){

 qui copy "http://www.askitas.com/cgi-bin/weeklyclaims.cgi?level=`level'" `ijc_raw'
 qui insheet using `ijc_raw', tab clear
 if _N ==0 {
  di "The web service at the US Dept of Labor appears to be out of service. Please try again later."
  di "If this error persists please contact: weeklyclaims@askitas.com"
  exit
 }

 gen date = date(datestring, "MDY")
 format date %td
 drop datestring

 qui label data "Initial Jobless Claims US to date, Source: US Dept of Labor via askitas.com "
 describe
}

if !regexm("`level'", "us"){
 if (length("`level'") >2){
  display as error "Sorry: `level' does not seem to be a state."
  exit
 }

 *set trace on
 qui copy "http://www.askitas.com/cgi-bin/weeklyclaims.cgi?level=state&states[]=`level'" `ijc_raw'
 qui insheet using `ijc_raw', tab clear
 if _N ==0 {
  di "The web service at the US Dept of Labor appears to be out of service. Please try again later."
  di "If this error persists please contact: weeklyclaims@askitas.com"
  exit
 }

qui gen d = date(filed_week_ended,"MDY")
format d %td
drop filed_week_ended
rename d filed_week_ended

qui gen d = date(reflecting_week_ended,"MDY")
format d %td
drop reflecting_week_ended
rename d reflecting_week_ended
 
 qui label data "Initial Jobless Claims `level' to date, Source: US Dept of Labor via askitas.com "
 des
}
end


