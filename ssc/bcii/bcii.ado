*! bcii.ado Version 1.1 31-5-09 by Robert Froud, Centre for Health Sciences, Barts and the London School of Medicine and Dentistry

/*
A program to calculate Newcombe Method 10 CIs for the risk difference of benefit between clinical trial groups and reciprocally transform the results giving NNTs 
with upper and lower CIs, ad described by Bender. 

Improvements on continuous scales can be defined by consensus thresholds. See:
Ostelo RWJG, Deyo RA, Stratford P, Waddell G, Croft PP, Von Korff M, et al. Interpreting Change Scores for Pain and Functional 
Status in Low Back Pain: Towards International Consensus Regarding Minimal Important Change. Spine 2008;33(1):90-94.


This ado has been modifed from Joseph Coveney's -rdci- which calculated CIs using four different methods, including Newcombe's method 10. 
See:
Froud R, Eldridge S, Lall R, Underwood M. Estimating Number Needed to Treat from continuous outcomes in randomised controlled trials: methodological challenges and worked  
example using data from the UK Back Pain Exercise and Manipulation (BEAM) trial. BMC Med Res Meth 2009;IN PRESS.

*/

program define bcii, rclass
    version 10.1
    syntax anything(id="argument numlist") [, Level(real `c(level)')]

    tempname z z2 n0 n1 p0 p1 rd lb ub nnt nntuu nntll bracket chi2rd

    tokenize `anything'
    if ("`1'" == "miemar") `1' `2' `3' `4' `5' `6' `7' `8'
    else {
        local variable_tally : word count `anything'
        if (`variable_tally' > 4) exit = 103
        if (`variable_tally' < 4) exit = 102

        forvalues i = 1/4 {
            capture confirm integer number ``i''
            if _rc {
                display in smcl as error "`id' must all be numeric."
                exit = 499
            }
        }
        forvalues i = 1/4 {
            capture assert ``i'' >= 0
            if _rc {
                display in smcl as error "`id' must all be nonnegative."
                exit = 499
            }
        }
        if !inrange(`level', 0.1, 99.9) {
            display in smcl as error "Level must lie between 0.1 and 99.9."
            exit = 499
        }

        scalar define `z' = invnormal(1 - (100 - `level') / 200 )
        scalar define `z2' = invchi2(1, `level' / 100)
        scalar define `n0' = `2' + `4'
        scalar define `n1' = `1' + `3'
        scalar define `p0' = `2' / `n0'
        scalar define `p1' = `1' / `n1'
        scalar define `rd' = `p1' - `p0'
        scalar define `lb' = .
        scalar define `ub' = .
	scalar define `nnt' = 1 / `rd'

        capture assert ( (`n0' > 0) & (`n1' > 0) )
        if _rc {
            display in smcl as error "Each exposure group must have at least one observation."
            exit = 499
        }

      return scalar p0 = `p0'
      return scalar p1 = `p1'
      return scalar rd = `rd'
	return scalar nnt = `nnt'

 * Newcombe's Method 10 confidence interval

      newcombe `1' `2' `n1' `n0' `p1' `p0' `rd', lb(`lb') ub(`ub') z(`z') z2(`z2')

      return scalar lb_ne = `lb'
      return scalar ub_ne = `ub'

	scalar define `nntuu' = 1 / `lb'
	scalar define `nntll' = 1 / `ub'

	return scalar nntuu = `nntuu'
	return scalar nntll = `nntll'


        display in smcl as text " " _newline(2)
        display in smcl as text "       Risk of improvement for control (p0): " as result %05.3f return(p0)
        display in smcl as text "       Risk of improvement for intervention (p1): " as result %05.3f return(p1)
        display in smcl as text "       Risk difference (p1 - p0): " as result %05.3f return(rd)
        display in smcl as text "       Newcombe Method 10" %4.1g `level' "% CI: " as result %05.3f return(lb_ne) ///
         as text "{c -}" ///
          as result %05.3f return(ub_ne)
        display in smcl as text "       Number needed to treat (Improvement): " as result %05.3f return(nnt)
	  display in smcl as text "       Bender's" %4.1g `level' "% CI: " as result %05.3f return(nntll) ///
         as text "{c -}" ///
          as result %05.3f return(nntuu)
        display in smcl _newline(1)
    }
end
program define newcombe
    version 10.1
    syntax anything, lb(name) ub(name) z(name) z2(name)

    tempname a b c lb1 lb2 ub1 ub2 cl1 cl2
    tokenize `anything'

* Wilson intervals of the individual proportions (adapted from -ciwi- by N. J. Cox)
    forvalues i = 1/2 {
        local n`i' = ``=`i' + 2''
        local p = `i' + 4
        scalar define `a' = 2 * ``i'' + `z2'
        scalar define `b' = `z' * sqrt( `z2' + 4 * `n`i'' * ``p'' * (1 - ``p'') )
        scalar define `c' = 2 * (`n`i'' + `z2')
        scalar define `lb`i'' = (`a' - `b') / `c'
        scalar define `ub`i'' = (`a' + `b') / `c'
    }

    scalar define `cl1' = `7' - `z' * sqrt( `lb1' * (1 - `lb1') / `n1' + `ub2' * (1 - `ub2') / `n2' )
    scalar define `cl2' = `7' + `z' * sqrt( `ub1' * (1 - `ub1') / `n1' + `lb2' * (1 - `lb2') / `n2' )
    scalar define `lb' = min(`cl1', `cl2')
    scalar define `ub' = max(`cl1', `cl2')

end


