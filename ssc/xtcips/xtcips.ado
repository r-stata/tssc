* Maximo Sangiacomo
* Nov. 2018
* v 4.0
* Based on: Pesaran, M. H. (2007). "A Simple Panel Unit Root Test In The Presence Of Cross-section Dependence." 
* Journal Of Applied Econometrics 22: 265–312

program define xtcips, rclass
version 9
syntax varname(ts) [if] [in] , MAXLags(numlist min=1 max=1 int >=1) BGLags(numlist int >=1) [ Q Trend Noc ]  

qui tsset
local id `r(panelvar)'
local time `r(timevar)'
if ("`noc'"!=""&"`trend'"!="") {
	disp in smcl in r "{opt noconstant} cannot be used with the {opt trend} option"
	error 198
}
tempname Vals pgr cv
tempvar vvar vvarm dvvar dvvarm res
local case 2
local text "constant"
scalar k1 = 6.19
scalar k2 = 2.61
if "`noc'" != "" {
	local noc ", noc"
	local case 1
	local text "no constant nor trend"
	scalar k1 = 6.12
	scalar k2 = 4.16
}
if  "`trend'" != "" { 
	local trend "`time'"
	local case 3
       	local text "constant & trend"
	scalar k1 = 6.42
	scalar k2 = 1.70
}
marksample touse
markout `touse' `time'
qui tsreport if `touse', report panel
if r(N_gaps) {
	di in red "sample may not contain gaps"
	error 198
}
qui xtsum `time' if `touse'
local N `r(n)'
local T `r(Tbar)'
if int(`T')*`N' != r(N) {
	di in red "panel must be balanced"
	error 198
}
local tmin `r(min)'
local tmax `r(max)'
* copy variable to prevent alteration and allow ts ops
qui gen double `vvar' = `varlist' if `touse'
* cross-section averages
qui gen double `vvarm' = . if `touse'
qui gen double `dvvarm' = . if `touse'
qui gen double `dvvar' = D.`vvar' if `touse'
local vvarm "`vvarm'"
local dvvarm "`dvvarm'"
forv t = `tmin'/`tmax' {
	qui { 
		sum `vvar' if `time' == `t' & `touse'
		replace `vvarm' = r(mean) if `time' == `t' & `touse'
		sum `dvvar' if `time' == `t' & `touse'
		replace `dvvarm' = r(mean) if `time' == `t' & `touse'
	}
}
* define unit identifier
qui tab `id' if `touse', matrow(`Vals') 
local nvals = r(r)
local i = 1
while `i' <= `nvals' {
	local val = `Vals'[`i',1]
	local vals "`vals' `val'"
	local ++i 
}
*Lags criterion decision
*Q
if "`q'" != "" {
	qui {
		foreach i of local vals {
			local psr`i' = 0
			local tpsr`i'
			reg D.`vvar' L.`vvar' L.`vvarm' `dvvarm' `trend' if `id' == `i'  & `touse' `noc'
			predict `res' if `id' == `i'  & `touse', resid
			wntestq `res' if `id' == `i'  & `touse'
   			scalar tsq`i' = r(p)
			drop `res'
			while (scalar(tsq`i')<.05 & `psr`i'' <= `maxlags') {
				local ++psr`i' 
				local tpsr`i' "L(1/`psr`i'')D.`vvar' L(1/`psr`i'').`dvvarm'"			
				reg D.`vvar' L.`vvar' L.`vvarm' `dvvarm' `tpsr`i'' `trend' if `id' == `i'  & `touse' `noc'
				predict `res' if `id' == `i'  & `touse', resid
				wntestq `res' if `id' == `i'  & `touse'
		   		scalar tsq`i' = r(p)
				drop `res'
			}
		}
	}
}
*F
else {
	qui {
		foreach num of numlist 1/`maxlags' {
			local list L`num'D.`vvar' L`num'.`dvvarm'
			local list_t "`list_t' `list'"
		}
		local psr = `maxlags'
		local tpsr "L(1/`psr')D.`vvar' L(1/`psr').`dvvarm'"
		local lag1 = `maxlags'-1
		foreach i of local vals {
			local list_t`i' "`list_t'"
			local tpsr`i'
			local psr`i' = 0
			reg D.`vvar' L.`vvar' L.`vvarm' `dvvarm' `tpsr' `trend' if `id' == `i'  & `touse' `noc'
			test `list_t'
			scalar tsf`i' = r(p)
			if scalar(tsf`i')<.05 & `lag1' > 0 {
				while (scalar(tsf`i')<.05 & `psr`i'' < `maxlags') {
					local ++psr`i'
					gettoken first list_t`i': list_t`i'
					gettoken first list_t`i': list_t`i'
					test `list_t`i''
					scalar tsf`i' = r(p)
					local tpsr`i' "L(1/`psr`i'')D.`vvar' L(1/`psr`i'').`dvvarm'"			
				}
			}
		}
	}
}
*B-G lags
local bgnpi : word count `bglags'
local bgslags : list sort bglags
local bgmaxlag : word `bgnpi' of `bgslags'
if `bgnpi' == 1 {
	foreach i of local vals {
		local bgps`i' = `bglags'
	}
}
else if `bgnpi' != `N' {
	di in r "Error: `N' panel units, either 1 or `N' lag lengths must be specified in Breusch-Godfrey"
	error 198
}
else {
	local j = 0
	foreach i of local vals {
		local ++j
		local bgps`i' : word `j' of `bglags'
	}
}
*Panel Unit Root Test
scalar cips = 0
scalar nt = 0
foreach i of local vals {
	qui {	
		reg D.`vvar' L.`vvar' L.`vvarm' `dvvarm' `tpsr`i'' `trend' if `id' == `i' & `touse' `noc'
		mat b = e(b)
    		mat v = e(V)
    		scalar nt = nt + e(N)
		scalar _tst = b[1,1]/sqrt(v[1,1])
		scalar tst_`i' = b[1,1]/sqrt(v[1,1])
*truncation
		if (scalar(tst_`i')>-scalar(k1) & scalar(tst_`i')<scalar(k2)) {
			scalar tst_`i'_s = scalar(tst_`i')
		}
		else if scalar(tst_`i')<=-scalar(k1) {
			scalar tst_`i'_s  = -scalar(k1)
			local trunc "trunc"
		}
		else {
			scalar tst_`i'_s  = scalar(k2)
			local trunc "trunc"
		}
*Breusch-Godfrey
		estat bgodfrey, small lags(`bgps`i'')
		mat pbg`i' = r(p)
		scalar pbg`i' = pbg`i'[1,1]

		scalar cips = cips + tst_`i'_s
   	}
}

di in gr _n "Pesaran Panel Unit Root Test with cross-sectional and first difference mean included for " in ye "`varlist'"  /* 
*/ _n in gr "Deterministics chosen: " in ye "`text'"
if "`q'" != "" {
	di in gr _n "Dynamics: lags criterion decision" in y " Portmanteau (Q) " in g "test for" in y " white noise"
}
else {
	di in gr _n "Dynamics: lags criterion decision" in y " General to Particular " in g "based on" in y " F joint test"
}
if "`trunc'" != "" {
	di in gr _n "Individual" in y " ti" in g " were" in y " truncated" in g " during the aggregation process"
	local ast "*"
}

di in gr _n "{bf:H0 (homogeneous non-stationary):}" in y " bi = 0" in g " for all" in y " i"


*Results
mat `pgr' = J(`N',6,.)			
if "`q'" != "" {
	mat colnames `pgr' = id t t* "pv Q test" "# lags" "pv BG LMtest"
}
else {
	mat colnames `pgr' = id t t* "pv F test" "# lags" "pv BG LMtest"
}
local i = 1
foreach num of local vals {
	mat `pgr'[`i',1] = `num'
	mat `pgr'[`i',2] = scalar(tst_`num')
	mat `pgr'[`i',3] = scalar(tst_`num'_s)
	if "`q'" != "" {
		mat `pgr'[`i',4] = scalar(tsq`num')
	}
	else {
		mat `pgr'[`i',4] = scalar(tsf`num')
	}
	mat `pgr'[`i',5] = `psr`num''
	mat `pgr'[`i',6] = scalar(pbg`num')
	local ++i
}
scalar cips = cips/`N'
return scalar cips = scalar(cips)
return mat W = `pgr'

di in gr _n "CIPS`ast' = " in ye %9.3f scalar(cips) in gr "        N,T = (" in y "`N'" in gr "," in y "`T'" in gr ")" 

_getCIPS, case(`case') n(`N')  t(`T') trunc(`trunc')
mat `cv'=J(1,3,.)
mat colnames `cv' =  "10%"  "5%"  "1%" 
mat rownames `cv' = "Critical values at" 
mat `cv'[1,1] = r(cvag10)
mat `cv'[1,2] = r(cvag5)
mat `cv'[1,3] = r(cvag1)
_matrix_table `cv'
return mat cv = `cv'
end		

program define _getCIPS, rclass
version 8.2
syntax , Case(string) N(string) T(string) [ trunc(string) ] 

tempname en te msdaag1 msdaag5 msdaag10 
local capt `t'
local capn `n'

mat `en' = (10,15,20,30,50,70,100,200)
mat `te' = (10,15,20,30,50,70,100,200)
if  "`trunc'" == "" {
	if `case' == 1 {
    	mat `msdaag1' = (-2.16, -2.02, -1.93, -1.85, -1.78, -1.74, -1.71, -1.70 \ /*
		*/ -2.03, -1.91, -1.84, -1.77, -1.71, -1.68, -1.66, -1.63 \ /*
		*/ -2.00, -1.89, -1.83, -1.76, -1.70, -1.67, -1.65, -1.62 \ /*
		*/ -1.98, -1.87, -1.80, -1.74, -1.69, -1.67, -1.64, -1.61 \ /*
		*/ -1.97, -1.86, -1.80, -1.74, -1.69, -1.66, -1.63, -1.61 \ /*
		*/ -1.95, -1.86, -1.80, -1.74, -1.68, -1.66, -1.63, -1.61 \ /*
		*/ -1.94, -1.85, -1.79, -1.74, -1.68, -1.65, -1.63, -1.61 \ /*
		*/ -1.95, -1.85, -1.79, -1.73, -1.68, -1.65, -1.63, -1.61)
    	mat `msdaag5' = (-1.80, -1.71, -1.67, -1.61, -1.58, -1.56, -1.54, -1.53 \ /*
		*/ -1.74, -1.67, -1.63, -1.58, -1.55, -1.53, -1.52, -1.51 \ /*
		*/ -1.72, -1.65, -1.62, -1.58, -1.54, -1.53, -1.52, -1.50 \ /*
		*/ -1.72, -1.65, -1.61, -1.57, -1.55, -1.54, -1.52, -1.50 \ /*
		*/ -1.72, -1.64, -1.61, -1.57, -1.54, -1.53, -1.52, -1.51 \ /*
		*/ -1.71, -1.65, -1.61, -1.57, -1.54, -1.53, -1.52, -1.51 \ /*
		*/ -1.71, -1.64, -1.61, -1.57, -1.54, -1.53, -1.52, -1.51 \ /*
		*/ -1.71, -1.65, -1.61, -1.57, -1.54, -1.53, -1.52, -1.51)
    	mat `msdaag10' = (-1.61, -1.56, -1.52, -1.49, -1.46, -1.45, -1.44, -1.43 \ /*
		*/ -1.58, -1.53, -1.50, -1.48, -1.45, -1.44, -1.44, -1.43 \ /*
		*/ -1.58, -1.52, -1.50, -1.47, -1.45, -1.45, -1.44, -1.43 \ /*
		*/ -1.57, -1.53, -1.50, -1.47, -1.46, -1.45, -1.44, -1.43 \ /*
		*/ -1.58, -1.52, -1.50, -1.47, -1.45, -1.45, -1.44, -1.43 \ /*
		*/ -1.57, -1.52, -1.50, -1.47, -1.46, -1.45, -1.44, -1.43 \ /*
		*/ -1.56, -1.52, -1.50, -1.48, -1.46, -1.45, -1.44, -1.43 \ /*
		*/ -1.57, -1.53, -1.50, -1.47, -1.45, -1.45, -1.44, -1.43)
    	}
    if `case' == 2 {
        mat `msdaag1' = (-2.97, -2.76, -2.64, -2.51, -2.41, -2.37, -2.33, -2.28 \ /*
		*/ -2.66, -2.52, -2.45, -2.34, -2.26, -2.23, -2.19, -2.16 \ /*
		*/ -2.60, -2.47, -2.40, -2.32, -2.25, -2.20, -2.18, -2.14 \ /*
		*/ -2.57, -2.45, -2.38, -2.30, -2.23, -2.19, -2.17, -2.14 \ /*
		*/ -2.55, -2.44, -2.36, -2.30, -2.23, -2.20, -2.17, -2.14 \ /*
		*/ -2.54, -2.43, -2.36, -2.30, -2.23, -2.20, -2.17, -2.14 \ /*
		*/ -2.53, -2.42, -2.36, -2.30, -2.23, -2.20, -2.18, -2.15 \ /*
		*/ -2.53, -2.43, -2.36, -2.30, -2.23, -2.21, -2.18, -2.15)
        mat `msdaag5' = (-2.52, -2.40, -2.33, -2.25, -2.19, -2.16, -2.14, -2.10 \ /*
		*/ -2.37, -2.28, -2.22, -2.17, -2.11, -2.09, -2.07, -2.04 \ /*
		*/ -2.34, -2.26, -2.21, -2.15, -2.11, -2.08, -2.07, -2.04 \ /*
		*/ -2.33, -2.25, -2.20, -2.15, -2.11, -2.08, -2.07, -2.05 \ /*
		*/ -2.33, -2.25, -2.20, -2.16, -2.11, -2.10, -2.08, -2.06 \ /*
		*/ -2.33, -2.25, -2.20, -2.15, -2.12, -2.10, -2.08, -2.06 \ /*
		*/ -2.32, -2.25, -2.20, -2.16, -2.12, -2.10, -2.08, -2.07 \ /*
		*/ -2.32, -2.25, -2.20, -2.16, -2.12, -2.10, -2.08, -2.07)
        mat `msdaag10' = (-2.31, -2.22, -2.18, -2.12, -2.07, -2.05, -2.03, -2.01 \ /*
		*/ -2.22, -2.16, -2.11, -2.07, -2.03, -2.01, -2.00, -1.98 \ /*
		*/ -2.21, -2.14, -2.10, -2.07, -2.03, -2.01, -2.00, -1.99 \ /*
		*/ -2.21, -2.14, -2.11, -2.07, -2.04, -2.02, -2.01, -2.00 \ /*
		*/ -2.21, -2.14, -2.11, -2.08, -2.05, -2.03, -2.02, -2.01 \ /* 
		*/ -2.21, -2.15, -2.11, -2.08, -2.05, -2.03, -2.02, -2.01 \ /*
		*/ -2.21, -2.15, -2.11, -2.08, -2.05, -2.03, -2.03, -2.02 \ /*
		*/ -2.21, -2.15, -2.11, -2.08, -2.05, -2.04, -2.03, -2.02)
        }
       if `case' == 3 {
        mat `msdaag1' = (-3.88, -3.61, -3.46, -3.30, -3.15, -3.10, -3.05, -2.98 \ /*
		*/ -3.24, -3.09, -3.00, -2.89, -2.81, -2.77, -2.74, -2.71 \ /*
		*/ -3.15, -3.01, -2.92, -2.83, -2.76, -2.72, -2.70, -2.65 \ /*
		*/ -3.10, -2.96, -2.88, -2.81, -2.73, -2.69, -2.66, -2.63 \ /*
		*/ -3.06, -2.93, -2.85, -2.78, -2.72, -2.68, -2.65, -2.62 \ /*
		*/ -3.04, -2.93, -2.85, -2.78, -2.71, -2.68, -2.65, -2.62 \ /*
		*/ -3.03, -2.92, -2.85, -2.77, -2.71, -2.68, -2.65, -2.62 \ /*
		*/ -3.03, -2.91, -2.85, -2.77, -2.71, -2.67, -2.65, -2.62) 
        mat `msdaag5' = (-3.27, -3.11, -3.02, -2.94, -2.86, -2.82, -2.79, -2.75 \ /*
		*/ -2.93, -2.83, -2.77, -2.70, -2.64, -2.62, -2.60, -2.57 \ /*
		*/ -2.88, -2.78, -2.73, -2.67, -2.62, -2.59, -2.57, -2.55 \ /*
		*/ -2.86, -2.76, -2.72, -2.66, -2.61, -2.58, -2.56, -2.54 \ /*
		*/ -2.84, -2.76, -2.71, -2.65, -2.60, -2.58, -2.56, -2.54 \ /*
		*/ -2.83, -2.76, -2.70, -2.65, -2.61, -2.58, -2.57, -2.54 \ /*
		*/ -2.83, -2.75, -2.70, -2.65, -2.61, -2.59, -2.56, -2.55 \ /*
		*/ -2.83, -2.75, -2.70, -2.65, -2.61, -2.59, -2.57, -2.55)
        mat `msdaag10' = (-2.98, -2.89, -2.82, -2.76, -2.71, -2.68, -2.66, -2.63 \ /*
		*/ -2.76, -2.69, -2.65, -2.60, -2.56, -2.54, -2.52, -2.50 \ /*
		*/ -2.74, -2.67, -2.63, -2.58, -2.54, -2.53, -2.51, -2.49 \ /*
		*/ -2.73, -2.66, -2.63, -2.58, -2.54, -2.52, -2.51, -2.49 \ /*
		*/ -2.73, -2.66, -2.63, -2.58, -2.55, -2.53, -2.51, -2.50 \ /*
		*/ -2.72, -2.66, -2.62, -2.58, -2.55, -2.53, -2.52, -2.50 \ /*
		*/ -2.72, -2.66, -2.63, -2.59, -2.55, -2.53, -2.52, -2.50 \ /*
		*/ -2.73, -2.66, -2.63, -2.59, -2.55, -2.54, -2.52, -2.51)
        }
 }
 else {
	if `case' == 1 {
    	mat `msdaag1' = (-2.14, -2.00, -1.91, -1.84, -1.77, -1.73, -1.71, -1.69 \ /*
		*/ -2.03, -1.91, -1.84, -1.77, -1.71, -1.68, -1.66, -1.63 \ /*
		*/ -2.00, -1.89, -1.83, -1.76, -1.70, -1.67, -1.65, -1.62 \ /*
		*/ -1.98, -1.87, -1.80, -1.74, -1.69, -1.67, -1.64, -1.61 \ /*
		*/ -1.97, -1.86, -1.80, -1.74, -1.69, -1.66, -1.63, -1.61 \ /*
		*/ -1.95, -1.86, -1.80, -1.74, -1.68, -1.66, -1.63, -1.61 \ /*
		*/ -1.94, -1.85, -1.79, -1.74, -1.68, -1.65, -1.63, -1.61 \ /*
		*/ -1.95, -1.85, -1.79, -1.73, -1.68, -1.65, -1.63, -1.61)
    	mat `msdaag5' = (-1.79, -1.71, -1.66, -1.61, -1.57, -1.55, -1.53, -1.52 \ /*
		*/ -1.74, -1.67, -1.63, -1.58, -1.55, -1.53, -1.52, -1.51 \ /*
		*/ -1.72, -1.65, -1.62, -1.58, -1.54, -1.53, -1.52, -1.50 \ /*
		*/ -1.72, -1.65, -1.61, -1.57, -1.55, -1.54, -1.52, -1.50 \ /*
		*/ -1.72, -1.64, -1.61, -1.57, -1.54, -1.53, -1.52, -1.51 \ /*
		*/ -1.71, -1.65, -1.61, -1.57, -1.54, -1.53, -1.52, -1.51 \ /*
		*/ -1.71, -1.64, -1.61, -1.57, -1.54, -1.53, -1.52, -1.51 \ /*
		*/ -1.71, -1.65, -1.61, -1.57, -1.54, -1.53, -1.52, -1.51)
    	mat `msdaag10' = (-1.61, -1.55, -1.52, -1.48, -1.46, -1.45, -1.43, -1.43 \ /*
		*/ -1.58, -1.53, -1.50, -1.48, -1.45, -1.44, -1.44, -1.43 \ /*
		*/ -1.58, -1.52, -1.50, -1.47, -1.45, -1.45, -1.44, -1.43 \ /*
		*/ -1.57, -1.53, -1.50, -1.47, -1.46, -1.45, -1.44, -1.43 \ /*
		*/ -1.58, -1.52, -1.50, -1.47, -1.45, -1.45, -1.44, -1.43 \ /*
		*/ -1.57, -1.52, -1.50, -1.47, -1.46, -1.45, -1.44, -1.43 \ /*
		*/ -1.56, -1.52, -1.50, -1.48, -1.46, -1.45, -1.44, -1.43 \ /*
		*/ -1.57, -1.53, -1.50, -1.47, -1.45, -1.45, -1.44, -1.43)
    	}
    if `case' == 2 {
        mat `msdaag1' = (-2.85, -2.66, -2.56, -2.44, -2.36, -2.32, -2.29, -2.25 \ /*
		*/ -2.66, -2.52, -2.45, -2.34, -2.26, -2.23, -2.19, -2.16 \ /*
		*/ -2.60, -2.47, -2.40, -2.32, -2.25, -2.20, -2.18, -2.14 \ /*
		*/ -2.57, -2.45, -2.38, -2.30, -2.23, -2.19, -2.17, -2.14 \ /*
		*/ -2.55, -2.44, -2.36, -2.30, -2.23, -2.20, -2.17, -2.14 \ /*
		*/ -2.54, -2.43, -2.36, -2.30, -2.23, -2.20, -2.17, -2.14 \ /*
		*/ -2.53, -2.42, -2.36, -2.30, -2.23, -2.20, -2.18, -2.15 \ /*
		*/ -2.53, -2.43, -2.36, -2.30, -2.23, -2.21, -2.18, -2.15)
        mat `msdaag5' = (-2.47, -2.35, -2.29, -2.22, -2.16, -2.13, -2.11, -2.08 \ /*
		*/ -2.37, -2.28, -2.22, -2.17, -2.11, -2.09, -2.07, -2.04 \ /*
		*/ -2.34, -2.26, -2.21, -2.15, -2.11, -2.08, -2.07, -2.04 \ /*
		*/ -2.33, -2.25, -2.20, -2.15, -2.11, -2.08, -2.07, -2.05 \ /*
		*/ -2.33, -2.25, -2.20, -2.16, -2.11, -2.10, -2.08, -2.06 \ /*
		*/ -2.33, -2.25, -2.20, -2.15, -2.12, -2.10, -2.08, -2.06 \ /*
		*/ -2.32, -2.25, -2.20, -2.16, -2.12, -2.10, -2.08, -2.07 \ /*
		*/ -2.32, -2.25, -2.20, -2.16, -2.12, -2.10, -2.08, -2.07)
        mat `msdaag10' = (-2.28, -2.20, -2.15, -2.10, -2.05, -2.03, -2.01, -1.99 \ /*
		*/ -2.22, -2.16, -2.11, -2.07, -2.03, -2.01, -2.00, -1.98 \ /*
		*/ -2.21, -2.14, -2.10, -2.07, -2.03, -2.01, -2.00, -1.99 \ /*
		*/ -2.21, -2.14, -2.11, -2.07, -2.04, -2.02, -2.01, -2.00 \ /*
		*/ -2.21, -2.14, -2.11, -2.08, -2.05, -2.03, -2.02, -2.01 \ /* 
		*/ -2.21, -2.15, -2.11, -2.08, -2.05, -2.03, -2.02, -2.01 \ /*
		*/ -2.21, -2.15, -2.11, -2.08, -2.05, -2.03, -2.03, -2.02 \ /*
		*/ -2.21, -2.15, -2.11, -2.08, -2.05, -2.04, -2.03, -2.02)
        }
       if `case' == 3 {
        mat `msdaag1' = (-3.51, -3.31, -3.20, -3.10, -3.00, -2.96, -2.93, -2.88 \ /*
		*/ -3.21, -3.07, -2.98, -2.88, -2.80, -2.76, -2.74, -2.70 \ /*
		*/ -3.15, -3.01, -2.92, -2.83, -2.76, -2.72, -2.70, -2.65 \ /*
		*/ -3.10, -2.96, -2.88, -2.81, -2.73, -2.69, -2.66, -2.63 \ /*
		*/ -3.06, -2.93, -2.85, -2.78, -2.72, -2.68, -2.65, -2.62 \ /*
		*/ -3.04, -2.93, -2.85, -2.78, -2.71, -2.68, -2.65, -2.62 \ /*
		*/ -3.03, -2.92, -2.85, -2.77, -2.71, -2.68, -2.65, -2.62 \ /*
		*/ -3.03, -2.91, -2.85, -2.77, -2.71, -2.67, -2.65, -2.62) 
        mat `msdaag5' = (-3.10, -2.97, -2.89, -2.82, -2.75, -2.73, -2.70, -2.67 \ /*
		*/ -2.92, -2.82, -2.76, -2.69, -2.64, -2.62, -2.59, -2.57 \ /*
		*/ -2.88, -2.78, -2.73, -2.67, -2.62, -2.59, -2.57, -2.55 \ /*
		*/ -2.86, -2.76, -2.72, -2.66, -2.61, -2.58, -2.56, -2.54 \ /*
		*/ -2.84, -2.76, -2.71, -2.65, -2.60, -2.58, -2.56, -2.54 \ /*
		*/ -2.83, -2.76, -2.70, -2.65, -2.61, -2.58, -2.57, -2.54 \ /*
		*/ -2.83, -2.75, -2.70, -2.65, -2.61, -2.59, -2.56, -2.55 \ /*
		*/ -2.83, -2.75, -2.70, -2.65, -2.61, -2.59, -2.57, -2.55)
        mat `msdaag10' = (-2.87, -2.78, -2.73, -2.67, -2.63, -2.60, -2.58, -2.56 \ /*
		*/ -2.76, -2.68, -2.64, -2.59, -2.55, -2.53, -2.51, -2.50 \ /*
		*/ -2.74, -2.67, -2.63, -2.58, -2.54, -2.53, -2.51, -2.49 \ /*
		*/ -2.73, -2.66, -2.63, -2.58, -2.54, -2.52, -2.51, -2.49 \ /*
		*/ -2.73, -2.66, -2.63, -2.58, -2.55, -2.53, -2.51, -2.50 \ /*
		*/ -2.72, -2.66, -2.62, -2.58, -2.55, -2.53, -2.52, -2.50 \ /*
		*/ -2.72, -2.66, -2.63, -2.59, -2.55, -2.53, -2.52, -2.50 \ /*
		*/ -2.73, -2.66, -2.63, -2.59, -2.55, -2.54, -2.52, -2.51)
        }
 }
forv t = 1/8 {
	if `capt' <= `te'[1,`t'] {
		forv n = 1/8 {
			if `capn' <= `en'[1,`n'] {
				return scalar cvag1 = `msdaag1'[`t',`n']
				return scalar cvag5 = `msdaag5'[`t',`n']
				return scalar cvag10 = `msdaag10'[`t',`n'] 
				continue,break
			}
		}
		continue,break
	}
}
end
