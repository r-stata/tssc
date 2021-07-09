***************************
**   Maximo Sangiacomo   **
** Jan 2013. Version 1.0 **
***************************
program define pvfix, rclass
	version 9
	syntax , cf(real) nper(integer) FREQuency(string) rate(real) [ EXTRAPayment(real 0) due(integer 0) RESult(string) ]
* Cash Flow
scalar cf = `cf'
if (scalar(cf)<0) {
disp as err "{bf:cf} should be a greater than zero (0)"
exit 198
}
* Number of periods
scalar n = `nper'
scalar n1 = `nper'-1
local n = scalar(n)
local n1 = scalar(n)-1
if (scalar(n)<0) {
disp as err "{bf:nper} should be an integer greater than zero (0)"
exit 198
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
exit 198
}
scalar ip = scalar(iy)/scalar(p)
*Extra payment
if `extrapayment'==0 {
	scalar extrap = `extrapayment'
}
else {
	scalar extrap = `extrapayment'
	if (scalar(extrap)<0) {
		disp as err "{bf:extrapayment} should be a greater than zero (0)"
		exit 198
	}
}
*Due
if (`due'!=0&`due'!=1) {
disp as err "{bf:due} should be one (1) or zero (0)"
exit 198
}

* Discount factors & Accum prin
if `due'==0 {
	scalar extrapdesc  = scalar(extrap)*(1+scalar(ip))^(-scalar(`n'))
	scalar accpvcf = 0
	foreach k of numlist 1/`n' {
		scalar disc`k' = (1+scalar(ip))^(-scalar(`k'))
		scalar pvcf`k' = cf*scalar(disc`k')
		scalar accpvcf = accpvcf + scalar(pvcf`k')
	}
scalar pvcf`n' = scalar(pvcf`n')+scalar(extrapdesc) 
scalar accpvcf = accpvcf + scalar(extrapdesc) 
}
else {
	scalar extrapdesc  = scalar(extrap)*(1+scalar(ip))^(-scalar(`n1'))
	scalar accpvcf = 0
	foreach k of numlist 1/`n' {
		local j = `k'-1
		scalar disc`k' = (1+scalar(ip))^(-scalar(`j'))
		scalar pvcf`k' = cf*scalar(disc`k')
		scalar accpvcf = accpvcf + scalar(pvcf`k')
	}
scalar pvcf`n' = scalar(pvcf`n')+scalar(extrapdesc) 
scalar accpvcf = accpvcf + scalar(extrapdesc) 
}

* Results
tempname mres
mat `mres' = J(`n',3,.)
mat colnames `mres' = Nper "Discount factor" "CF's Present Value" 
foreach k of numlist 1/`n' {
mat `mres'[`k',1] = `k'
mat `mres'[`k',2] = scalar(disc`k')
mat `mres'[`k',3] = scalar(pvcf`k')
}
if "`result'" == "" {
local result "matpvcf"
}

disp as txt "Present Value: " as res scalar(accpvcf)
return scalar PV = scalar(accpvcf)
return scalar extrap = scalar(extrap)
return scalar due = `due'
return scalar iy  = scalar(iy)
return scalar freq = scalar(p)
return scalar nper = scalar(n)
return scalar cf = scalar(cf)
return mat `result' = `mres'
end
