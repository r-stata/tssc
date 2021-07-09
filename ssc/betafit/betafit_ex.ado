*! version 1.1.7 MLB 07Apr2011
*! version 1.1.6 MLB 06Apr2011
program define betafit_ex
	if "`1'" == "" {
		Msg preserve
		preserve
		Xeq use http://fmwww.bc.edu/repec/bocode/c/citybudget.dta, clear
		Xeq betafit governing, mu(minorityleft noleft houseval popdens)
		Xeq dbetafit, at(minorityleft 0 noleft 0 )
		Msg restore 
		restore
	}
	if "`1'" == "1" {
		Msg preserve
		preserve
		Xeq use http://fmwww.bc.edu/repec/bocode/c/citybudget.dta, clear
        Xeq gen byte baseline = 1
	
        Xeq gen byte touse = !missing(governing, minorityleft, ///
	                                  noleft, houseval, popdens)
        Xeq sum popdens if touse, meanonly
        Xeq gen cpopdens = popdens - r(mean)
    
        Xeq sum houseval if touse, meanonly
        Xeq gen chouseval = houseval - r(mean)
    
        Xeq betafit governing, rpr ///
            mu(minorityleft noleft chouseval cpopdens baseline, nocons) 
		Msg restore 
		restore
	}
end

program Msg
        di as txt
        di as txt "-> " as res `"`0'"'
end

program Xeq, rclass
        di as txt
        di as txt `"-> "' as res `"`0'"'
        `0'
		if "`r(mean)'" != "" {
			return scalar mean = r(mean)
		}
end
