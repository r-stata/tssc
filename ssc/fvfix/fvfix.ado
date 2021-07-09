***************************
**   Maximo Sangiacomo   **
** Jan 2013. Version 1.0 **
***************************
program define fvfix, rclass
	version 9
	syntax , cf(real) nper(integer) FREQuency(string) rate(real) [ PRESENTVALue(real 0) due(integer 0) RESult(string) ]
* Cash Flow
scalar cf = `cf'
if (scalar(cf)<0) {
disp as err "{bf:cf} should be a greater than zero (0)"
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
*Present Value
if `presentvalue'==0 {
	scalar presentval = `presentvalue'
}
else {
	scalar presentval = `presentvalue'
	if (scalar(presentval)<0) {
		disp as err "{bf:presentvalue} should be a greater than zero (0)"
		exit 198
	}
}
*Due
if (`due'!=0&`due'!=1) {
disp as err "{bf:due} should be one (1) or zero (0)"
exit 198
}

* Capitalization factors & Accum prin
if `due'==0 {
	scalar presentvalcap  = scalar(presentval)*(1+scalar(ip))^(scalar(`n'))
	scalar accfvcf = 0
	foreach k of numlist 1/`n' {
		scalar cap`k' = ((1+scalar(ip))^((scalar(n)-scalar(`k'))))
		scalar fvcf`k' = cf*scalar(cap`k')
		scalar accfvcf = accfvcf + scalar(fvcf`k')
	}
scalar fvcf1 = scalar(fvcf1)+scalar(presentvalcap) 
scalar accfvcf = accfvcf + scalar(presentvalcap) 
}
else {
	scalar presentvalcap  = scalar(presentval)*(1+scalar(ip))^(scalar(`n'))
	scalar accfvcf = 0
	foreach k of numlist 1/`n' {
		scalar cap`k' = ((1+scalar(ip))^((scalar(n)+1-scalar(`k'))))
		scalar fvcf`k' = cf*scalar(cap`k')
		scalar accfvcf = accfvcf + scalar(fvcf`k')
	}
scalar fvcf1 = scalar(fvcf1)+scalar(presentvalcap) 
scalar accfvcf = accfvcf + scalar(presentvalcap) 
}

* Results
tempname mres
mat `mres' = J(`n',3,.)
mat colnames `mres' = Nper "Capitalization factor" "CF's Future Value" 
foreach k of numlist 1/`n' {
mat `mres'[`k',1] = `k'
mat `mres'[`k',2] = scalar(cap`k')
mat `mres'[`k',3] = scalar(fvcf`k')
}
if "`result'" == "" {
local result "matfvcf"
}

disp as txt "Future Value: " as res scalar(accfvcf)
return scalar FV = scalar(accfvcf)
return scalar presentval = scalar(presentval)
return scalar due = `due'
return scalar iy  = scalar(iy)
return scalar freq = scalar(p)
return scalar nper = scalar(n)
return scalar cf = scalar(cf)
return mat `result' = `mres'
end
