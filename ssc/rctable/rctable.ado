*! version 1.4  07/02/2020
version 16.0
cap program drop rctable
program define rctable
set more off
syntax [varlist] [using] [if] [pw aw fw], TREATment(varlist) [CONTrol(varlist fv) BASEControl(varlist) CLUSTer(varlist)  ESTimator(namelist) treated(varlist) pval keep quiet sd sheet(string asis)]
pause on


if "`keep'"=="" {
	preserve 
	quiet for any  VAR LAB  N_ind N_clust M C COEF* : cap drop X 
}

local c=1
foreach i in `treatment'  {
	quiet: gen COEF`c' ="" 
	local c=`c'+1
}

local c=`c'-1
	
forval h=1/`c' {
	local COEFS "`COEFS' COEF`h'"
}

foreach i in VAR LAB  N_ind N_clust M C   {
	 quiet: gen `i'=""
}
	 

local j=1
local k=1
foreach i in `varlist' {
	
	if "`estimator'"=="" | "`estimator'"=="ITT" | "`estimator'"=="itt" {
	if "`quiet'" =="" dis "*******"
	if "`quiet'" =="" dis "Outcome `i'"
	if "`quiet'" =="" dis "Intent-to-Treat estimation"
	if "`quiet'" =="" dis "********"
	* if basecontrol is missing: do nothing special
	
		if "`basecontrol'"=="" {
			if "`quiet'" !="" { 
			quietly  xi:reg  `i' `treatment'  `control' [`weight'`exp'] `if' , cluster(`cluster')  r
			}
			if "`quiet'" =="" { 
			xi:reg  `i' `treatment'  `control' [`weight'`exp'] `if' , cluster(`cluster')  r
			}
		}
		
	* if basecontrol is not missing, first verify the number of baseline cont
	if "`basecontrol'"!="" {
	cap assert wordcount("`basecontrol'") == wordcount("`varlist'")	
		
		if _rc!=0 {
		dis as error  "Number of variables different from number of baseline control"
		exit 100
		}	
	* then add the control variable that corresponds to the control
	local cont: word `k' of `basecontrol'
	if "`quiet'" !="" { 
		quietly  xi:reg  `i' `treatment'  `control' `cont' [`weight'`exp'] `if' , cluster(`cluster')  r
	}
	if "`quiet'" =="" { 
		xi:reg  `i' `treatment'  `control' `cont' [`weight'`exp'] `if' , cluster(`cluster')  r
	}
	}
	}
	
	if "`estimator'"=="LATE" | "`estimator'"=="late" {
	if "`quiet'" =="" dis "*******"
	if "`quiet'" =="" dis "Outcome `i'"
	if "`quiet'" =="" dis "Local Average Treatment Effect estimation"
	if "`quiet'" =="" dis "********"
		if "`treated'"=="" {
		dis as error  "treated variable is missing"
		exit 100
		}
		
		else {
			
			if "`basecontrol'"=="" {
			dis "Treatment on the treated estimation"
				if "`quiet'" !="" { 
				quiet xi:ivregress 2sls  `i'  (`treatment'=`treated')  `control' [`weight'`exp'] `if' , cluster(`cluster')  r	
				}
				if "`quiet'" =="" { 
				xi:ivregress 2sls  `i'  (`treatment'=`treated')  `control' [`weight'`exp'] `if' , cluster(`cluster')  r
				}
			
			}
			
			if "`basecontrol'"!="" { 
			 assert wordcount("`basecontrol'") == wordcount("`varlist'")
				
				if _rc!=0 {
				dis as error  "Number of variables different from number of baseline control"
				exit 100
				}	
			local cont: word `k' of `basecontrol'
				if "`quiet'" !="" { 
				xi:ivregress 2sls  `i'  (`treatment'=`treated')  `control' `cont' [`weight'`exp'] `if' , cluster(`cluster')  r	
				}
				if "`quiet'" =="" { 
				xi:ivregress 2sls  `i'  (`treatment'=`treated')  `control' `cont' [`weight'`exp'] `if' , cluster(`cluster')  r	
				}
			
			}
		}
	}	
	
	local t:  variable label `i'
	quiet: replace VAR="`i'" if _n==`j'
	quiet: replace LAB="`t'" if _n==`j'
	tokenize `treatment'
	forval v=2/`c' {
		if "``v''"!= "" {
			local cond "`cond' & ``v''==0"
		}
	}
	
	if "`if'"=="" {
		quiet: sum `i' [`weight'`exp'] if `1'==0 `cond'	, d
		quiet: replace C=string(round(r(mean),0.001)) if _n==`j'
		if "`sd'" !="" {
			quiet {
			replace C=string(round(r(sd),0.001)) if _n==`j'+1
			replace C="0"+C if substr(C,1,1)=="." & _n==`j'+1
			replace C="["+C+"]" if  _n==`j'+1
			replace C="(.)" if C=="(0)" & _n==`j'+1
			}
	}
	
		quiet: replace C="0"+C if substr(C,1,1)=="." & _n==`j'
		quiet: replace C=subinstr(C,"-.","-0.",.) if  _n==`j'
		quiet: sum `i' [`weight'`exp'], d
		quiet: replace M=string(round(r(mean),0.001)) if _n==`j'
	
		if "`sd'" !="" {
			quiet {
			replace M=string(round(r(sd),0.001)) if _n==`j'+1
			replace M="0"+M if substr(M,1,1)=="." & _n==`j'+1
			replace M="["+M+"]" if  _n==`j'+1
			replace M="(.)" if M=="(0)" & _n==`j'+1
			}
		}
		quiet {
		replace M="0"+M if substr(M,1,1)=="." & _n==`j'
		replace M=subinstr(M,"-.","-0.",.) if  _n==`j'
		}
	}
	
	else {
		quiet:sum `i' [`weight'`exp'] `if' & `1'==0 `cond' , d
		quiet: replace C=string(round(r(mean),0.001)) if _n==`j'
		if "`sd'" !="" {
		quiet{ 
			replace C=string(round(r(sd),0.001)) if _n==`j'+1
			replace C="0"+C if substr(C,1,1)=="." & _n==`j'+1
			replace C="["+C+"]" if  _n==`j'+1
			replace C="(.)" if C=="(0)" & _n==`j'+1
		}
		}
		quiet {
		replace C="0"+C if substr(C,1,1)=="." & _n==`j'
		replace C=subinstr(C,"-.","-0.",.) if  _n==`j'
		}
		quiet: sum `i' [`weight'`exp'] `if' , d
		
		if "`sd'" !="" {
		quiet { 
		quiet: replace M=string(round(r(sd),0.001)) if _n==`j'+1
			replace M="0"+M if substr(M,1,1)=="." & _n==`j'+1
			replace M="["+M+"]" if  _n==`j'+1
			replace M="(.)" if M=="(0)" & _n==`j'+1
		}
		}
		quiet {
		replace M=string(round(r(mean),0.001)) if _n==`j'
		replace M="0"+M if substr(M,1,1)=="." & _n==`j'
		replace M=subinstr(M,"-.","-0.",.) if  _n==`j'
}
		}
quiet {
	replace N_ind=string(e(N)) if _n==`j'
	replace N_clust=string(e(N_clust)) if _n==`j'
	}
	
	forval h=1/`c' {
	quiet{
	replace COEF`h'=string(round(_b[``h''],0.001)) if _n==`j'
		replace COEF`h'="0"+COEF`h' if substr(COEF`h',1,1)=="." & _n==`j'
		replace COEF`h'=subinstr(COEF`h',"-.","-0.",.) if   _n==`j' 
		replace COEF`h'=COEF`h'+"*" if   _n==`j' & 2*ttail(e(N)-e(df_m)-1,abs(_b[``h'']/_se[``h'']))<=0.1
		replace COEF`h'=COEF`h'+"*" if   _n==`j' & 2*ttail(e(N)-e(df_m)-1,abs(_b[``h'']/_se[``h'']))<=0.05
		replace COEF`h'=COEF`h'+"*" if   _n==`j' & 2*ttail(e(N)-e(df_m)-1,abs(_b[``h'']/_se[``h'']))<=0.01
		replace COEF`h'=string(round(_se[``h''],0.001)) if _n==`j'+1
		replace COEF`h'="0"+COEF`h' if substr(COEF`h',1,1)=="." & _n==`j'+1
		replace COEF`h'=subinstr(COEF`h',"-.","-0.",.) if  _n==`j'+1
		replace COEF`h'="("+COEF`h'+")" if  _n==`j'+1
		replace COEF`h'="(.)" if COEF`h'=="(0)" & _n==`j'+1
	}
	}
	if "`pval'" !="" {
		forval h=1/`c' {
			local t=_b[``h'']/_se[``h'']
			quiet{
			replace COEF`h'=string(round(2*ttail(e(N)-e(df_m)-1,abs(`t')),0.001)) if _n==`j'+2
			replace COEF`h'="0"+ COEF`h' if substr(COEF`h',1,1)=="." & _n==`j'+2
			replace COEF`h'="["+ COEF`h' + "]" if _n==`j'+2
			}
		}
		local j= `j'+3
	}
	else{
		local j= `j'+2
	}
local k= `k'+1
}

* Summary variable at the bottom of the table
quietly {
if "`if'"=="" { 
		
	replace VAR="Observations" if _n==`j' 
	replace N_ind=string(_N) if _n==`j'
	count if `1'==0
	replace C=string(r(N)) if _n==`j'
	
	if "`cluster'"!="" { 
	replace VAR="Clusters" if _n==`j'+1
	duplicates report `cluster' 
	replace N_ind=string(r(unique_value)) if _n==`j'+1
	duplicates report `cluster' if `1' ==0
	replace C=string(r(unique_value)) if _n==`j'+1
	}
}
	
if "`if'"!="" { 
	replace VAR="Observations" if  _n==`j' 
	count `if' 
	replace N_ind=string(r(N)) if _n==`j'
	count `if' & `1'==0
	replace C=string(r(N)) if _n==`j'
	
	if "`cluster'"!="" { 
	replace VAR="Clusters" if _n==`j'+1
	duplicates report `cluster' `if'
	replace N_ind=string(r(unique_value)) if _n==`j'+1
	duplicates report `cluster' `if' & `1'==0
	replace C=string(r(unique_value)) if _n==`j'+1
	
	}
}
}

	if `"`using'"'!="" {
		if `"`sheet'"'!="" { 
		gettoken worksheet option: sheet, parse(,)
		export excel   VAR LAB   N_ind N_clust M C COEF*   `using',   sheet(`worksheet' `option')  first(var)
		}
		else { 
		export excel   VAR LAB   N_ind N_clust M C COEF*   `using', firstrow(var) replace
		}
	}
	
	if "`keep'"=="" {
	restore
	}
end

