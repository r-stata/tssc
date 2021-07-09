*! version 1.3.0 MLB 14Feb2017
program define fmlogit_ex
	Msg preserve
	preserve
	Xeq use http://fmwww.bc.edu/repec/bocode/c/citybudget.dta, clear
	Xeq gen pol = minorityleft + 2*noleft
    Xeq label define pol 0 "left parties are majority" ///
                         1 "left parties are minority" /// 
                         2 "no left party"                
	Xeq label value pol pol
	Xeq label var pol "political orientation of city government"
	Xeq fmlogit governing safety education recreation social urbanplanning, ///
    eta(i.pol houseval popdens)
	Xeq margins, dydx(*) predict(outcome(governing))
    Xeq margins, dydx(*) predict(outcome(safety))
    Xeq margins, dydx(*) predict(outcome(education))
    Xeq margins, dydx(*) predict(outcome(recreation))
    Xeq margins, dydx(*) predict(outcome(social))
    Xeq margins, dydx(*) predict(outcome(urbanplanning)) 
	Msg restore 
	restore
end

program Msg
        di as txt
        di as txt "-> " as res `"`0'"'
end

program Xeq, rclass
        di as txt
        di as txt `"-> "' as res `"`0'"'
        `0'
end
