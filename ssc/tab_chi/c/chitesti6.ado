*! renamed NJC 9 July 2003 
*! 1.2.0 NJC 15 July 2000 
* 1.1.3 NJC 26 January 1999
* 1.1.2 2 Sept 1997
* evaluates expected before conf num
* 1.1.1 13 August 1997 call to chitest with kb option
* 1.1.0 2 August 1996
program define chitesti6
        version 6.0
        tokenize "`0'", parse(",\ ")
        local r 1
        local c 1
        local cols .
        while "`1'" != "" & "`1'" != "," {
                if "`1'" == "\" {
                        local r = `r' + 1
                        if `r' == 3 {
                                di in r /*
                        */ "only two rows allowed: observed and expected"
                                exit 198
                        }
                        if `cols' == . {
                                if `c' <  2 {
                                        di in r "too few categories"
                                        exit 198
                                }
                                local cols `c'
                        }
                        local c 1
                }
                else {
                        if `r' == 1 {
                                conf integer num `1'
                                if `1' < 0 { error 411 }
                                local o`c' `1'
                                local c = `c' + 1
                        }
                        if `r' == 2 {
                                local 1 = `1'
                                conf num `1'
                                if `1' <= 0 { error 411 }
                                local e`c' `1'
                                local c = `c' + 1
                        }
                }
                mac shift
        }

        if `c' != `cols' & `cols' != . {
                di in r "rows do not match"
                exit 198
        }
        if `cols' == . { local cols = `c' }
        local cols = `cols' - 1
         
  	local 0 "`*'" 
        syntax [ , nfit(int 0) replace ] 

        quietly {
                if "`replace'" != "" { drop _all }
                preserve
                drop _all
                local obs 1
                set obs 1
                gen observed = .
                local varlist "observed"
                if `r' == 2 {
                        gen expected = .
                        local varlist "observed expected"
                }
                local c 1
                while `c' <= `cols' {
                        set obs `obs'
                        replace observed = `o`c'' in l
                        if `r' == 2 { replace expected = `e`c'' in l }
                        local obs = `obs' + 1
                        local c = `c' + 1
                }

                noi chitest `varlist', nfit(`nfit') kb

                if _rc {
                        drop _all
                        exit `rc'
                }

                if "`replace'" != "" {
                        if `r' == 1 {
                                gen expected = `r(emean)' 
                        }
                        restore, not
                }
        }
end
