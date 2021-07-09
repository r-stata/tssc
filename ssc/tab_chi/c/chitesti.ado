*! 2.0.1 NJC 10 March 2004 
*! 2.0.0 NJC 9 July 2003
program chitesti
        version 8.0
        tokenize "`0'", parse(",\ ")
        local r 1
        local c 1
        local cols .
        while "`1'" != "" & "`1'" != "," {
                if "`1'" == "\" {
                        local ++r
                        if `r' == 3 {
                                di as err ///
                        	"only two rows allowed: observed and expected"
                                exit 198
                        }
                        if `cols' == . {
                                if `c' <  2 {
                                        di as err "too few categories"
                                        exit 198
                                }
                                local cols `c'
                        }
                        local c 1
                }
                else {
                        if `r' == 1 {
                                conf integer num `1'
                                if `1' < 0 error 411
                                local o`c' `1'
                                local ++c
                        }
                        if `r' == 2 {
                                local 1 = `1'
                                conf num `1'
                                if `1' <= 0 error 411
                                local e`c' `1'
                                local ++c 
                        }
                }
                mac shift
        }

        if `c' != `cols' & `cols' != . {
                di as err "rows do not match"
                exit 198
        }
        if `cols' == . local cols = `c'
        local --cols 
         
  	local 0 "`*'" 
        syntax [ , nfit(int 0) replace * ] 

        quietly {
                if "`replace'" != "" drop _all
                preserve
                drop _all
                local obs 1
                set obs 1
                gen double observed = .
                local varlist "observed"
                if `r' == 2 {
                        gen double expected = .
                        local varlist "observed expected"
                }
                forval c = 1 / `cols' {
                        set obs `obs++'
                        replace observed = `o`c'' in l
                        if `r' == 2 replace expected = `e`c'' in l 
                }

                noi chitest `varlist', nfit(`nfit') kb `options' 

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
