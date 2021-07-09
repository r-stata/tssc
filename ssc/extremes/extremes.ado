*! 1.2.1 NJC 15 June 2017 
*! 1.2.0 NJC 16 May 2004 
* 1.1.0 NJC 13 May 2003 
* 1.0.0 NJC 19 January 2003 
program extremes, sortpreserve byable(recall)  
    version 8 
    syntax varlist [if] [in] [ , n(numlist max=1 int >=1) MISSing /// 
        iqr(numlist max=1 >=0) IQR2 FREQuencies HIgh LOw noHeader * ]

    if "`iqr'`iqr2'" != "" & "`frequencies'" != "" { 
        di as err "may not combine iqr and frequencies options"
        exit 198 
    }    
    
    tokenize `varlist' 
    local varname "`1'" 
    confirm numeric variable `varname' 
    mac shift 
    local varlist "`*'" 
    if "`frequencies'" != "" & "`varlist'" != "" { 
        di as err "may not specify other variables" ///
        " with frequencies option"
        exit 198 
    }    

    marksample touse, novarlist 
    markout `touse' `varname' 
    if _by() & "`missing'" == "" { 
        markout `touse' `_byvars', strok 
    }     

    qui count if `touse' 
    if r(N) == 0 error 2000 
    local use = r(N) 
    local notuse = _N - r(N)

        if "`high'" == "" & "`low'" == "" { 
        // default: want both 
        local high 1
        local low  1 
    }     
    else { 
        local high = "`high'" == "high" 
        local low  = "`low'" == "low" 
    }
    
    qui if "`frequencies'" == "" {
        tempvar obsno sobsno
        gen long `obsno' = _n 
        gen str `sobsno' = string(_n) + "." 
        char `sobsno'[varname] "obs:" 
    }     

    if "`iqr2'" != "" { 
        if "`iqr'" == "" local iqr = 1.5 
        // -iqr()- specified as well takes precedence 
    } 
    
    qui if "`iqr'" != "" { 
        tempvar dev 
        tempname IQR 
        su `varname' if `touse', detail 
        if r(p75) == r(p25) { 
            di as err "iqr is 0" 
            exit 459 
        }     
        scalar `IQR' = r(p75) - r(p25) 
        gen `dev' = (`varname' - r(p75)) / `IQR' /// 
            if `varname' >= r(p75) & `touse' 
        replace `dev' = (`varname' - r(p25)) / `IQR' /// 
            if `varname' <= r(p25) & `touse'
        format `dev' %4.3f 
        char `dev'[varname] "iqr:" 
        count if `dev' >= `iqr' & `dev' < . 
        local nhigh = r(N)
        count if `dev' <= -`iqr'
        local nlow = r(N)
        sort `touse' `varname' `obsno' 
        
        local blank 0 
        if `low' & `nlow' { 
            noi list `sobsno' `dev' `varname' `varlist'  ///
                if `dev' <= -`iqr', noobs subvarname ///
                `header' `options' 
            if "`header'" == "" local noheader "noheader"  
            local blank 1
        }     
            if `high' & `nhigh' { 
            if `blank' di
            noi list `sobsno' `dev' `varname' `varlist' ///
                if `dev' >= `iqr' & `dev' < .       ///
                    , `header' `noheader' noobs subvarname `options'
        } 
    }     
    else if "`frequencies'" != "" {
        if "`n'" == "" local n = 5 
                
        tempvar freq isfreq 
        qui bysort `touse' `varname' : ///
            gen long `freq' = _N * (_n == 1) * `touse'
        char `freq'[varname] "freq:" 
        by `touse' `varname' : gen byte `isfreq' = `freq' > 0 
            
        qui count if `isfreq'  
        local nfreq = r(N) 
        if `nfreq' <= `n' { 
                // irrespective of options, show all 
            local high 0 
            local low  1 
        }     
        
        local l1 = _N - `nfreq' + 1 
        local l2 = min(`l1' + `n' - 1, _N) 
        local h1 = max(_N -`n' + 1, `l2' + 1) 
        
            sort `touse' `isfreq' `varname'  
        local blank 0 
        if `low' { 
            list `freq' `varname' `varlist' in `l1'/`l2' ///
                , noobs subvarname `header' `options'
            if "`header'" == "" local noheader "noheader"  
            local blank 1
        }     
        if `high' { 
            if `blank' di
            list `freq' `varname' `varlist' in `h1'/l ///
                , `header' `noheader' noobs subvarname `options' 
        } 
    } 
    else { 
        if "`n'" == "" local n = 5 
        
        if `use' <= `n' { 
                // irrespective of options, show all 
            local high 0 
            local low  1 
        }     
        
        local l1 = `notuse' + 1 
        local l2 = min(`l1' + `n' - 1, _N) 
        local h1 = max(_N -`n' + 1, `l2' + 1) 
        
        sort `touse' `varname' `obsno' 
        local blank 0 
        if `low' { 
            list `sobsno' `varname' `varlist' in `l1'/`l2' ///
                , noobs subvarname `header' `options'
            if "`header'" == "" local noheader "noheader"  
            local blank 1
        }     
        if `high' { 
            if `blank' di
            list `sobsno' `varname' `varlist' in `h1'/l ///
                , `header' `noheader' noobs subvarname `options' 
        } 
        
        local goon 1
        local blank 1 
        if `low' & `varname'[`l2'] == `varname'[`l2'+1] {
            di 
            qui count if `varname' == `varname'[`l2'] & `touse'
            local show : di `: format `varname'' `varname'[`l2'] 
            local show = trim("`show'") 
            di as txt "note: " as res `r(N)' ///
                as txt " values of " as res "`show'" 
            local goon = `varname'[`l2'] != `varname'[`h1']  
            local blank 0 
        }     
        
        if `goon' & `high' & (`varname'[`h1'] == `varname'[`h1'-1]) { 
            if `blank' di 
            qui count if `varname' == `varname'[`h1'] & `touse'
            local show : di `: format `varname'' `varname'[`h1'] 
            local show = trim("`show'") 
            di as txt "note: " as res `r(N)' /// 
                as txt " values of "  as res "`show'" 
        } 
    }    
end
