***************************
**   Maximo Sangiacomo   **
** Jan 2013. Version 1.0 **
***************************
program define payper, rclass
	version 9
	syntax , pv(real) nper(integer) FREQuency(string) rate(real) [ RESult(string) ]
* Present value
scalar PV = `pv'
if (scalar(PV)<0) {
disp as err "{bf:pv} should be a greater than zero (0)"
err 198
}
* Number of periods
scalar n = `nper'
local n = scalar(n)
if (scalar(n)<0) {
disp as err "{bf:nper} should be an integer greater than zero (0)"
err 198
}
* Frecuency
if ("`frequency'"!="m"&"`frequency'"!="h"&"`frequency'"!="q"&"`frequency'"!="y") {
	di in red "{bf:frequency} of payments could be one of the following possibilities:" 
	di "{inp} m: monthly"
	di "{inp} q: quarterly"
	di "{inp} h: halfyearly"
	di "{inp} y: yearly" 
	exit 198
}
if "`frequency'"=="m" {
local freqnum = 12
}
if "`frequency'"=="q" {
local freqnum = 4
}
if "`frequency'"=="h" {
local freqnum = 2
}
if "`frequency'"=="y" {
local freqnum = 1
}
scalar p = `freqnum'
* Annual interest rate 
scalar iy = `rate'
if (scalar(iy)<0|(scalar(iy)>1&scalar(iy)!=.)) {
disp as err "rate should be set in decimal form, so a number between 0 and 1 is expected"
err 198
}
scalar ip = scalar(iy)/scalar(p)

* Payments
if scalar(iy) == 0 {
scalar PMT = scalar(PV)/scalar(n)
}
else { 
scalar PMT = (scalar(PV)*scalar(ip))/(1-(1+scalar(ip))^(-scalar(n)))
}
* Accum prin
scalar accprin = 0
foreach k of numlist 1/`n' {
scalar prin`k' = scalar(PMT)*((1+scalar(ip))^(-(scalar(n)+1-scalar(`k'))))
scalar int`k' = scalar(PMT)*(1-(1+scalar(ip))^(-(scalar(n)+1-scalar(`k'))))
scalar accprin = accprin + scalar(prin`k')
scalar saldo`k' = scalar(PV) - scalar(accprin)
}

* Results
tempname mres
mat `mres' = J(`n',5,.)
mat colnames `mres' = Nper Principal Interest Balance PMT
foreach k of numlist 1/`n' {
mat `mres'[`k',1] = `k'
mat `mres'[`k',2] = scalar(prin`k')
mat `mres'[`k',3] = scalar(int`k')
mat `mres'[`k',4] = scalar(saldo`k')
mat `mres'[`k',5] = scalar(PMT)
}
if "`result'" == "" {
local result "matpay"
}

disp as txt "Payment: " as res scalar(PMT)
return scalar PMT = scalar(PMT)
return scalar iy  = scalar(iy)
return scalar freq = scalar(p)
return scalar nper = scalar(n)
return scalar pv = scalar(PV)
return mat `result' = `mres'
end
