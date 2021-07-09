 capture program drop gsdata
 program define gsdata,rclass
 version 13.1
 syntax anything(name=stkcd),y(string) m(string) d(string)
 
 local address http://quotes.money.163.com/cjmx/
 tempfile xlsfile

if `stkcd'>=600000{
qui capture copy "`address'`y'/`y'`m'`d'/0`stkcd'.xls"  `xlsfile'.xls,replace
if _rc~= 0{
disp as error `"`stkcd' is an invalid stock code"'
display "Please make sure you are online and/or redefine your date"
exit 601
}
}

else {
qui capture copy "`address'`y'/`y'`m'`d'/1`stkcd'.xls"  `xlsfile'.xls,replace
if _rc~= 0{
disp as error `"`stkcd' is an invalid stock code"'
display "Please make sure you are online and/or redefine your date"
exit 601
}
}

preserve
import excel using `xlsfile'.xls,clear 
drop in 1
label var A "time"
label var B "price"
label var C "the variation in prices"
label var D "volume"
label var E "amount"
label var F "buy or sell"
rename A closing_time
rename B closing_price
rename C price_change
rename D trading_volume
rename E trading_amount
rename F trading_direction
save `stkcd',replace
restore

display _n "Data for `y' `m' `d' written to `stkcd'.dta"
end


