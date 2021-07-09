*! version 1.1.2  2/28/95                       (STB-24, ssi5.4)
program define ridder 
        version 3.1
        parse "`*'", parse(" X=")

        local toload "exp1"
        while "`1'"!="=" & "`1'"!="returns" & "`1'"!="" {
                if "`1'"=="X" {
                        if "`toload'"=="exp2" {
                                di in red "X may be specifed only once"
                                exit 198
                        }
                        local toload "exp2"
                }
                else {
                        local `toload' "``toload'' `1'"
                }
                mac shift
        }
        if "`toload'"!="exp2" {
                di in red "X must be specified"
                exit 198
        }
        if "`1'"=="" { error 198 }
        if "`1'"=="returns" {
                if "`2'"=="macro" {
                        local type "`3'"
                        local rtnval
                }
                else if "`2'"=="exp" {
                        local rtnval "`3'"
                        local type
                }
                else    error 198
                mac shift 3
                local progttl "`exp1' X `exp2'"
                local inline "*"
        }
        else {
                local progttl = substr("`exp2'",2,.)
                local progttl "`exp1'X`progttl'"
                local callout "*"
        }
        if "`1'" != "=" { 
                di in red "=exp required"
                exit 198
        }
        mac shift
        local toload "mval"
        while "`1'"!="" {
                if "`1'"=="to" {
                        local toload "mhi"
                }
                else if "`1'"=="from" {
                        local toload "mlo"
                }
                else if "`1'"=="tol" {
                        local toload "mtol"
                }
                else if "`1'"=="ltol" {
                        local toload "mltol"
                }
                else {
                        local `toload' "``toload''`1'"
                }
                mac shift
        }
        if "`mval'"=="" { 
                di in red "= must be followed by expression"
                exit 198
        }
        if "`mhi'"=="" { 
                di in red "to specifier requried"
                exit 198 
        } 
        if "`mlo'"=="" { 
                di in red "from specifier required"
                exit 198 
        }
        tempname flo fhi val lo hi hold ftry ftry2 tol ltol
        if "`mtol'"=="" & "`mltol'"=="" {
                scalar `tol' = 1e-6
                scalar `ltol' = .
        }
        else if "`mltol'"=="" {
                scalar `tol' = `mtol'
                scalar `ltol'= .
        }
        else if "`mtol'"=="" {
                scalar `tol' = .
                scalar `ltol' =`mltol'
        }
        else {
                scalar `tol' = `mtol'
                scalar `ltol' = `mltol'
        }
        scalar `val' = `mval' 
        scalar `lo' = `mlo' 
        scalar `hi' = `mhi' 
        scalar `ltol' = max(`ltol'*abs(`val'),`ltol')
        local maxiter 64

        if `lo'>`hi' { 
                scalar `hold' = `lo'
                scalar `lo' = `hi'
                scalar `hi' = `hold'
        }

        local ttl : di "Find `progttl'=f() == c=" `val' ", |X_error|<" `tol' /*
                */ ", |f()-c|<" `ltol'
        local skip = max(0,int((72-length("`ttl'"))/2))
        di in gr _n _skip(`skip') "`ttl'" _n

        `callout' quietly `exp1' `lo' `exp2'
        `callout' scalar `flo' = ${`type'} `rtnval' - `val'
        `inline'  scalar `flo' = (`exp1' `lo' `exp2') - `val'

        `callout' quietly `exp1' `hi' `exp2'
        `callout' scalar `fhi' = ${`type'} `rtnval' - `val'
        `inline'  scalar `fhi' = (`exp1' `hi' `exp2') - `val' 

        di in gr /*
                */ _col(17) "lower" _col(39) "upper" _col(59) "weighted" _n /*
                */ "iteration" _col(17) "bound" _col(27) "f()-c" /*
                */ _col(39) "bound" _col(49) "f()-c" /*
                */ _col(59) "midpoint" _col(72) "f()-c" _n /*
                */ _dup(76) "-"


        /* verify we bound the solution */
        if `flo'*`fhi'>0 | `flo'*`fhi'==. { 
                di in gr %8.0f 0 ".   " %9.0g `lo' " " %9.0g `flo' /*
                        */ "   " %9.0g `hi' " " %9.0g `fhi'
                display in red "range does not bound solution"
                exit 409
        }
        if `flo'==0 {
                scalar `fhi' = `flo'
                scalar `hi' = `lo'
        }
        else if `fhi'==0 {
                scalar `flo' = `fhi'
                scalar `lo' = `hi'
        }

        local try = (`lo'+`hi')/2
        local lasttry = `try'
        `callout' quietly `exp1' `try' `exp2'
        `callout' scalar `ftry' = ${`type'} `rtnval' - `val'
        `inline'  scalar `ftry' = (`exp1' `try' `exp2') - `val' 
        local try = `try'+(`try'-`lo')*sign(`flo'-`fhi')*`ftry' / /*
                        */      sqrt(`ftry'^2 - `flo'*`fhi')
        `callout' quietly `exp1' `try' `exp2'
        `callout' scalar `ftry' = ${`type'} `rtnval' - `val'
        `inline'  scalar `ftry' = (`exp1' `try' `exp2') - `val' 
        local iter 0 
        while `ftry'~=0 &((abs(`lasttry'-`try')>`tol' |abs(`ftry')>`ltol')) {
                di in gr %8.0f `iter' ".   " %9.0g `lo' " " %9.0g `flo' /*
                        */ "   " %9.0g `hi' " " %9.0g `fhi' "    " /*
                        */ in ye %9.0g `try' " " %9.0g `ftry'
                local lasttry = `try'
                if `flo'*`ftry'<0 { 
                        scalar `fhi' = `ftry'
                        scalar `hi'=`try'
                }
                else {
                        scalar `flo' = `ftry'
                        scalar `lo' = `try'
                }
                local try = (`lo'+`hi')/2
                `callout' quietly `exp1' `try' `exp2'
                `callout' scalar `ftry' = ${`type'} `rtnval' - `val'
                `inline'  scalar `ftry' = (`exp1' `try' `exp2') - `val'
                local try = `try'+(`try'-`lo')*sign(`flo'-`fhi')*`ftry' / /*
                        */      sqrt(`ftry'^2 - `flo'*`fhi')
                `callout' quietly `exp1' `try' `exp2'
                `callout' scalar `ftry' = ${`type'} `rtnval' - `val'
                `inline'  scalar `ftry' = (`exp1' `try' `exp2') - `val' 
                local iter = `iter' + 1
                if `iter' > `maxiter' {
                        global S_1 = `try'
                        di in red "Convergence not achieved"
                        exit 430
                }
        }
        di in gr %8.0f `iter' ".   " %9.0g `lo' " " %9.0g `flo' /*
                */ "   " %9.0g `hi' " " %9.0g `fhi' "    " /*
                */ in ye %9.0g `try' " " %9.0g `ftry'
        di in ye _col(57) "|X_error|<=" %9.0g abs(`try'-`lasttry')
        global S_1 = `try'
end
exit

binsear .002 .005 1e-6


-------------------
Note:
        specify:
                rtnval:         S_1             to mean $S_1
                rtnval:         "exp <exp>"     to mean <exp>

        Logic:
                $exp <exp> will evaluate to <exp>

Find simul()=f() == c=.22071

         1         2         3         4         5         6         7         8
12345678901234567890123456789012345678901234567890123456789012345678901234567890
                lower                 upper
iteration       bound     f()-c       bound     f()-c     midpoint     f()-c
----------------------------------------------------------------------------
123456789   123456789 123456789   123456789 123456789    123456789 123456789
         1         2         3         4         5         6         7         8
12345678901234567890123456789012345678901234567890123456789012345678901234567890

