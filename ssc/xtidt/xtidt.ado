*! xtidt , id(3) t(5) panel(id) year(year) time(time) dumcs(Cs) dumts(Ts) list
*! xtidt V2.0 15dec2011
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define xtidt
version 10.0
syntax [varlist] [if] [in] , id(str) t(str) panel(str) year(str) ///
 [TIME(str) dumcs(str) dumts(str) list *]
scalar Dim = `t'*`id'
local MSize= Dim
qui set matsize `MSize'
qui cap set obs `MSize'
qui cap drop `panel'
qui cap drop `year'
qui local tm `t'
qui local id `id'
qui local tot=`tm'*`id'
preserve
tempvar TimeN
qui cap gen `TimeN' =.
qui forvalues i = 1/`tot' {
qui cap set obs `i'
qui replace `TimeN'= `i' in `i'
 }
qui replace `TimeN'=_n in 1/`tot'
qui mkmat `TimeN' in 1/`tot' , matrix(TimeN)
restore
qui svmat TimeN , name(`TimeN')
qui rename `TimeN'1 `TimeN'
qui cap gen `year' =. in 1/`tot'
qui cap gen `panel'=. in 1/`tot'
qui forvalues i = 1/`id' {
qui summ `TimeN' , meanonly
qui local min=`tm'*`i'-`tm'+1
qui local max=`tm'*`i'
qui replace `year' = `TimeN'-`min'+1 in `min'/`max'
qui replace `panel'= `i' in `min'/`max' 
 }
qui replace `year'= `year' in 1/`tot' 
qui replace `panel'= `panel' in 1/`tot' 
label variable `panel' `"Panel ID"'
label variable `year' `"Year ID"'
qui order `panel' `year'
if "`time'"!= "" {
qui cap drop `time'
qui gen `time'= _n in 1/`tot'
label variable `time' `"Time Trend"'
qui order `panel' `year'  `time'
 }
if "`dumcs'"!= "" {
qui cap drop `dumcs'*
qui tabulate `panel' in 1/`tot' , generate(`dumcs')
forval i=1/`id' {
label variable `dumcs'`i' `"Panel (`i')"'
 }
 }
if "`dumts'"!= "" {
qui cap drop `dumts'*
qui tabulate `year' in 1/`tot' , generate(`dumts')
qui forval i=1/`tm' {
label variable `dumts'`i' `"Year (`i')"'
 }
 }
if "`list'"!= "" {
list `panel' `year' `time' in 1/`MSize' , separator(`tm')
 }
di _dup(78) "{bf:{err:=}}"
di as res _col(5) "Total Observations       = `MSize' "
di as res _col(5) "Number of Time Periods   = `tm' "
di as res _col(5) "Number of Cross Sections = `id' "
di _dup(78) "{bf:{err:=}}"
qui cap drop `TimeN'
end

