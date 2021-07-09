*! version 1.0.0 10Nov2015 MLB
*! Based on lvr2plot version 3.2.0  29sep2004
program define lvr2plot2 /* leverage vs. residual squared */
        version 10

        _isfit cons anovaok
        syntax [, lab(string) * ]

        _get_gropts , graphopts(`options') getallowed(plot addplot)
        local options `"`s(graphopts)'"'
        local plot `"`s(plot)'"'
        local addplot `"`s(addplot)'"'
		
		if "`lab'" != "" {
			parselab `lab'
			local lab `s(lab)'
			local all `s(all)'
		}

        if "`e(vcetype)'"=="Robust" { 
                di in red "leverage plot not available after robust estimation"
                exit 198
        }

        tempvar h r c
        quietly { 
                _predict `h' if e(sample), hat
                _predict `r' if e(sample), resid
				_predict `c' if e(sample), cooksd
                replace `r'=`r'*`r'
                sum `r', mean
                replace `r'=`r'/(r(mean)*r(N))
                local x=1/r(N)
                local y=(e(df_m)+1)*`x'
        }

		if "`lab'" != "" {
			if "`all'" == "" {
				local if "if `h' > `y' & `r' > `x'"
			}
			local labgraph scatter `h' `r' `if', msymbol(i) mlabel(`lab') mlabpos(0) legend(off)
		}
        label var `h' "Leverage"
        local yttl : var label `h'
        label var `r' "Normalized residual squared"
        local xttl : var label `r'
        version 8: graph twoway         ///
        (scatter `h' `r' [pw=`c'],        ///
                note("size proportional to Cook's D") ///
                ytitle(`"`yttl'"')      ///
                xtitle(`"`xttl'"')      ///
                yline(`y')              ///
                xline(`x')              ///
                `options'               ///
        )                               ///
        || `labgraph' || `plot' || `addplot'          ///
        // blank
end

program define parselab, sclass
	syntax varname [, all]
	sreturn local lab = "`varlist'"
	sreturn local all = "`all'"
end
