*! bcib.ado  1.1 31-5-09 by Robert Froud, Centre for Health Sciences, Barts and the London School of Medicine and Dentistry
/* 
A program to calculate Newcombe Method 10 CIs for the risk difference of benefit between clinical trial groups allowing for deteriorations
as well as improvements. 

Deteriorations and improvements should be defined by consensus thresholds. See:
Ostelo RWJG, Deyo RA, Stratford P, Waddell G, Croft PP, Von Korff M, et al. Interpreting Change Scores for Pain and Functional 
Status in Low Back Pain: Towards International Consensus Regarding Minimal Important Change. Spine 2008;33(1):90-94.

This ado contains modifed code from Joseph Coveney's -rdci-, which calculated CIs using four different methods, including Newcombe's method 10, on which this method is based,
for the risk difference of two independant proportions. 

In bcib Newcombe's Method 10 has been modified to include the extra varianve term introduced when considering individual deteriorations as well as improvements. See:
Froud R, Eldridge S, Lall R, Underwood M. Estimating Number Needed to Treat from continuous outcomes in randomised controlled trials: methodological challenges and worked  
example using data from the UK Back Pain Exercise and Manipulation (BEAM) trial. BMC Med Res Meth 2009;IN PRESS.

Program version is set at 10.1 as it has not yet been tested on earlier versions of Stata. However, I do not anticipate any difficulties on earlier versions. To run on earlier versions of Stata the version numbers
in the programs below must be redefined. 

*/
program define bcib, rclass
    version 10.1
    syntax anything(id="argument numlist") [, Level(real `c(level)')]

    tempname z z2 n0 n1 p0 p1 rd lb ub rlb1 rlb2 rub1 rub2 p0det p1det n0det n1det lb3 lb4 ub3 ub4 m3 m4 nnt nntuu nntll bracket chi2rd

    tokenize `anything'
    if ("`1'" == "miemar") `1' `2' `3' `4' `5' `6' `7' `8'
    else {
        local variable_tally : word count `anything'
        if (`variable_tally' > 8) exit = 103
        if (`variable_tally' < 8) exit = 102

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
        scalar define `n0' = `6' + `8'
        scalar define `n1' = `5' + `7'
        scalar define `p0' = `6' / `n0'
        scalar define `p1' = `5' / `n1'
        scalar define `lb' = .
        scalar define `ub' = .
	  scalar define `rlb1' = .
	  scalar define `rlb2' = .
	  scalar define `rub1' = .
	  scalar define `rub2' = .



        capture assert ( (`n0' > 0) & (`n1' > 0) )
        if _rc {
            display in smcl as error "Each exposure group must have at least one observation."
            exit = 499
        }

        return scalar p0 = `p0'
        return scalar p1 = `p1'

 * Newcombe's Method 10 confidence interval

        deteriorate `5' `6' `n1' `n0' `p1' `p0' `rd', lb(`lb') ub(`ub') z(`z') z2(`z2') rlb1(`rlb1') rlb2(`rlb2') rub1(`rub1') rub2(`rub2')


 * Carring variance terms forward

	scalar define `lb3' = `rlb1'
	scalar define `lb4' = `rlb2'
	scalar define `ub3' = `rub1'
	scalar define `ub4' = `rub2'
	scalar define `m3' = `6' + `8'
	scalar define `m4' = `5' + `7'

 * Redefining scalars

      scalar define `z' = invnormal(1 - (100 - `level') / 200 )
      scalar define `z2' = invchi2(1, `level' / 100)
      scalar define `n0' = `2' + `4'
      scalar define `n1' = `1' + `3'
      scalar define `p0' = `2' / `n0'
      scalar define `p1' = `1' / `n1'


	scalar define `n0det' = `6' + `8'
	scalar define `n1det' = `5' + `7'



	scalar define `p0det' = `6' / `n0det'
	scalar define `p1det' = `5' / `n1det'
      scalar define `rd' = `p1' - `p1det' - `p0' + `p0det'
      scalar define `nnt' = 1 / `rd'

 * Scalar defs for point estimate

      return scalar p0 = `p0'
      return scalar p1 = `p1'
	return scalar p0det = `p0det'
      return scalar p1det = `p1det'
      return scalar rd = `rd'
	return scalar nnt = `nnt' 

     newcombe `1' `2' `n1' `n0' `p1' `p0' `rd', lb(`lb') ub(`ub') z(`z') z2(`z2') lb3(`lb3') lb4(`lb4') ub3(`ub3') ub4(`ub4') m3(`m3') m4(`m4')

      return scalar lb_ne = `lb'
      return scalar ub_ne = `ub'

	scalar define `nntuu' = 1 / `lb'
	scalar define `nntll' = 1 / `ub'

	return scalar nntuu = `nntuu'
	return scalar nntll = `nntll'

        display in smcl as text "" _newline(2)
        display in smcl as text "       Risk of improvement for control (p0): " as result %05.3f return(p0)
        display in smcl as text "       Risk of improvement for intervention(p1): " as result %05.3f return(p1)
	  display in smcl as text " 	  Risk of deterioration for control (p0det): " as result %05.3f return(p0det)
	  display in smcl as text " 	  Risk of deterioration for intervention (p1det): " as result %05.3f return(p1det)
        display in smcl as text "       Risk difference (p1 - p1det - p0 + p0det): " as result %05.3f return(rd)
        display in smcl as text "       Newcombe Method 10" %4.1g `level' "% CI: " as result %05.3f return(lb_ne) ///
          as text "{c -}" ///
          as result %05.3f return(ub_ne)
        display in smcl as text "       Number needed to treat (Benefit): " as result %05.3f return(nnt)
	  display in smcl as text "       Bender's" %4.1g `level' "% CI: " as result %05.3f return(nntll) ///
         as text "{c -}" ///
         as result %05.3f return(nntuu)
        display in smcl _newline(1)


    }
end

************
* Programs *
************

program define deteriorate
    version 10.1
    syntax anything, lb(name) ub(name) z(name) z2(name)rlb1(name) rlb2(name) rub1(name) rub2(name)

    tempname a b c lb1 lb2 ub1 ub2 cl1 cl2
    tokenize `anything'

* Wilson intervals of the individual proportions (adapted from rdci by Joseph Coveny which was adapted from -ciwi- by N. J. Cox)

    forvalues i = 1/2 {
        local n`i' = ``=`i' + 2''
        local p = `i' + 4
        scalar define `a' = 2 * ``i'' + `z2'
        scalar define `b' = `z' * sqrt( `z2' + 4 * `n`i'' * ``p'' * (1 - ``p'') )
        scalar define `c' = 2 * (`n`i'' + `z2')
        scalar define `lb`i'' = (`a' - `b') / `c'
        scalar define `ub`i'' = (`a' + `b') / `c'
    }
	scalar define `rlb1' = `lb1'
	scalar define `rlb2' = `lb2'
	scalar define `rub1' = `ub1'
	scalar define `rub2' = `ub2'


end

program define newcombe
    version 10.1
    syntax anything, lb(name) ub(name) z(name) z2(name) lb3(name) lb4(name) ub3(name) ub4(name) m3(name) m4(name)
    tempname a b c lb1 lb2 ub1 ub2 cl1 cl2
    tokenize `anything'

* Wilson intervals of the individual proportions (adapted from rdci by Joseph Coveny which was adapted from -ciwi- by N. J. Cox)

    forvalues i = 1/2 {
        local n`i' = ``=`i' + 2''
        local p = `i' + 4
        scalar define `a' = 2 * ``i'' + `z2'
        scalar define `b' = `z' * sqrt( `z2' + 4 * `n`i'' * ``p'' * (1 - ``p'') )
        scalar define `c' = 2 * (`n`i'' + `z2')
        scalar define `lb`i'' = (`a' - `b') / `c'
        scalar define `ub`i'' = (`a' + `b') / `c'
    }

    scalar define `cl1' = `7' - `z' * sqrt( `lb1' * (1 - `lb1') / `n1' + `ub2' * (1 - `ub2') / `n2' + `lb3' * (1 - `lb3') / `m3' + `ub4' * (1 - `ub4') / `m4')
    scalar define `cl2' = `7' + `z' * sqrt( `ub1' * (1 - `ub1') / `n1' + `lb2' * (1 - `lb2') / `n2' + `ub3' * (1 - `ub3') / `m3' + `lb4' * (1 - `lb4') / `m4')
    scalar define `lb' = min(`cl1', `cl2')
    scalar define `ub' = max(`cl1', `cl2')

end





