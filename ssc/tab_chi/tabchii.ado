*! NJC 1.4.0 20 June 2020 
* NJC 1.3.1 19 Sept 2000 
* NJC 1.3.0 15 July 2000 
* NJC 1.2.2 26 January 1999
* 1.2.1  13 January 1998
program define tabchii
    version 6.0
    tokenize "`0'", parse(",\ ")

    local r 1
    local c 1
    local cols . 
	
    while "`1'" != "" & "`1'" != "," {
        if "`1'" == "\" {
            local r = `r' + 1
            if `cols' == . {
                if `c' <= 2 {
                    di in r "too few columns"
                    exit 198
                }
                local cols `c'
            }
            else if `c' != `cols' { error 198 }
            local c 1
        }
        else {
            conf integer num `1'
            if `1' < 0 { error 411 }
            local n`r'_`c' `1'
            local c = `c' + 1
        }
        mac shift
    }
	
    if `c' != `cols' { error 198 }
	
    local cols = `cols' - 1
    local rows = `r'
    local 0 "`*'" 
	
    syntax [ , REPLACE Raw Pearson Adjust Cont noO noE * ] 
    quietly {
        if "`replace'" != "" {  drop _all }
        preserve
        drop _all
        local obs 1
        set obs 1
        gen byte row = .
        gen byte col = .
        gen long observed = .
        local r 1
		
        while `r' <= `rows' {
            local c 1
            while `c' <= `cols' {
                set obs `obs'
                replace row = `r' in l
                replace col = `c' in l
                replace observed = `n`r'_`c'' in l
                local obs = `obs' + 1
                local c = `c' + 1
            }
            local r = `r' + 1
        }
		
        sort col
        by col: gen double colsum = sum(observed)
        by col: replace colsum = colsum[_N]
        sort row col
        by row: gen double rowsum = sum(observed)
        by row: replace rowsum = rowsum[_N]
        su observed, meanonly
        local tabsum = r(sum)
        gen double expected = (rowsum * colsum) / `tabsum'
        count if expected < 5
        local lt5 = r(N)
        count if expected < 1
        local lt1 = r(N)
        gen double raw = observed - expected
        gen double Pearson = (observed - expected) / sqrt(expected)
        gen double cont = ((observed - expected)^2) / expected
        gen double adjusted = Pearson / sqrt((1 - rowsum / `tabsum') /*
        */                                 *(1 - colsum/`tabsum'))
        format expected raw Pearson cont adjusted %9.3f
        
		noi di
        noi if "`o'" != "noo" {
            di in g _dup(10) " " "observed frequency"
        }
        noi if "`e'" != "noe" {
            di in g _dup(10) " " "expected frequency"
        }
        noi if "`raw'" == "raw" {
            di in g _dup(10) " " "raw residual"
            local res "raw"
        }
        noi if "`pearson'" == "pearson" {
            di in g _dup(10) " " "Pearson residual"
            local res "`res' Pearson"
        }
        noi if "`cont'" == "cont" {
            di in g _dup(10) " " "contribution to chi-square"
            local res "`res' cont"
        }
        noi if "`adjust'" == "adjust" {
            di in g _dup(10) " " "adjusted residual"
            local res "`res' adjusted"
        }
        if "`o'" != "noo" { local show "observed" }
        if "`e'" != "noe" { local show "`show' expected" }
        noi {
            if "`show'`res'" != "" {
                tabdisp row col, c(`show' `res') `options'
            }
            local s = cond(`lt5' > 1, "s", "") 
            if `lt5' >= 1 {
                di _n in g "`lt5' cell`s' with expected frequency < 5"
            }
            local s = cond(`lt1' > 1, "s", "") 
            if `lt1' >= 1 {
                di in g "`lt1' cell`s' with expected frequency < 1"
            }
        }
		
        tabulate row col [fw=observed], chi2 lrchi2
        local df = (`rows' - 1) * (`cols' - 1)
        noi di _n in g _dup(9) " " "Pearson chi2(" in y "`df'"      /*
               */ in g ") = " in y %8.4f r(chi2) in g "   Pr = "    /*
               */ in y %5.3f r(p)
        noi di in g "likelihood-ratio chi2(" in y "`df'"            /*
               */ in g ") = " in y %8.4f r(chi2_lr) in g "   Pr = " /*
               */ in y %5.3f r(p_lr) 

        if "`replace'"!="" {
            drop rowsum colsum
            label var observed "observed frequency"
            label var expected "expected frequency"
            label var raw "raw residual"
            label var Pearson "Pearson residual"
            label var cont "contribution to chi-square"
            label var adjusted "adjusted residual"
            restore, not
        }
    }
end
