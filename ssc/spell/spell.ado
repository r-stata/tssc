*! 1.7.1 NJC 22 Nov 2000 
* 1.7.0 NJC 6 Sept 2000 
* 1.6.0 NJC 25 July 2000 
* 1.5.0 NJC 19 July 2000 
* 1.4.1 NJC 9 June 2000 
* 1.4.0 NJC 31 March 1999
* 1.3.1 NJC & RG 25 June 1998
* 1.0.0 NJC 14 August 1997
program define spell 
    version 6.0
    #delimit ; 
    syntax [varlist(default=none max=1)] [if] [in] 
    [, BY(str) Cond(str asis) Fcond(str asis) replace 
    Pcond(str asis) End(str) Seq(str) SPell(str) CEnsor(str) resort ] ;
    #delimit cr
    
    local nopts = /* 
    */ (`"`cond'"' != "") + (`"`fcond'"' != "") + (`"`pcond'"' != "") 
    if `nopts' > 1 { 
    	di in r "must specify at most one of cond( ), fcond( ), pcond( )" 
	exit 198 
    }
    
    if `"`pcond'"' != "" { 
    	local cond `"((`pcond') > 0 & (`pcond') < .)"' 
    } 	

    if `"`cond'"' == "" & `"`fcond'"' == "" {
        if "`varlist'" != "" {
            local fcond "`varlist' != `varlist'[_n-1]"
        }
        else {
            di in r "insufficient information"
            exit 198
        }
    }
    
    if "`censor'" != "" {
        if trim("`censor'") == "." {
            local cl "_cl"
            local cr "_cr"
        }
        else {
            local nwords : word count `censor'
            if `nwords' != 2 {
                di in r "censor: two variable names required"
                exit 198
            }
            local cl : word 1 of `censor'
            local cr : word 2 of `censor'
       }
       
       if "`replace'" != "" { 
            capture confirm new variable `cl'
	    if _rc { drop `cl' } 
       } 
       else confirm new variable `cl' 
       
       if "`replace'" != "" { 
            capture confirm new variable `cr'
	    if _rc { drop `cr' } 
       } 
       else confirm new variable `cr' 
    }

    local end = cond("`end'" == "", "_end", "`end'")
    if "`replace'" != "" { 
         capture confirm new variable `end'
	 if _rc { drop `end' } 
    } 
    else confirm new variable `end' 
    
    local seq = cond("`seq'" == "", "_seq", "`seq'")
    if "`replace'" != "" { 
         capture confirm new variable `seq'
	 if _rc { drop `seq' } 
    } 
    else confirm new variable `seq' 

    local spell = cond("`spell'" == "", "_spell", "`spell'")
    if "`replace'" != "" { 
         capture confirm new variable `spell'
	 if _rc { drop `spell' } 
    } 
    else confirm new variable `spell' 

    tempvar touse id byid

    mark `touse' `if' `in'
    qui replace `touse' = -`touse'
    gen long `id' = _n
    local srtdby : sortedby 
    sort `touse' `by' `id' /* needed obs put first */

    qui {
        by `touse' `by' : gen byte `byid' = _n == 1
        replace `byid' = sum(`byid')

	if `"`fcond'"' != "" { 
		by `touse' `by' : gen long `spell' = sum(`fcond' & `touse')  
		sort `touse' `by' `spell' `id' 
		by `touse' `by' `spell' : gen long `seq' = _n * (`spell' > 0) 
	} 	
        else { 
		by `touse' `by' : gen long `seq' = `cond' & `touse'
	        by `touse' `by' : replace `seq' = /* 
		*/ `seq'[_n-1] + 1 if _n > 1 & `seq'
	        by `touse' `by' : gen long `spell' = /* 
		*/ cond(`seq', sum(`seq' == 1), 0)
	} 
	
        by `touse' `by' : gen byte `end' = /*
         */ cond(_n != _N, (`seq' >= `seq'[_n+1]) & `seq', `seq'[_N] > 0)
        compress `seq' `spell'
    }

    if "`censor'" != "" {
        gen byte `cl' = `seq' == 1 & ((`byid' > `byid'[_n-1]) | _n == 1)
        gen byte `cr' = `end' == 1 & `byid' < `byid'[_n+1]
    }

    if "`resort'" == "resort" { sort `srtdby' `id' }
end

