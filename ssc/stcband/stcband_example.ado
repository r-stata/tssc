*! version 1.0.1  15jul2008
program stcband_example
	if (_caller() <9) {
		di as err "This example requires version 9"
		exit 198
	}
	gettoken dsn 0 : 0, parse(" :")
	gettoken null 0 : 0, parse(" :")
	di as txt "-> " as res "preserve"
	preserve
	di
	cap findfile BMT.dta
	if _rc {
		di as err "file BMT.dta not found"
		exit 601 
	}
	local fileful `"`r(fn)'"'
	cap use `"`fileful'"',clear
	if _rc>900 { 
		window stopbox stop ///   
		"Dataset used in this example" ///
		"too large for Small Stata"
		exit _rc 
	}
	di 
	di as txt "-> " as res "use `dsn', clear"
	de
	di
	di as txt "-> " as res "stset Time2,f(DeathRelapse)"
	stset Time2,f(DeathRelapse)
	di 
	di as txt "-> " as res "Graph equal precision 95% confidence band in time interval 100 - 600 in patients with acute lymphoblastic leukemia" 
	di
	di as txt "-> " as res "stcband if Dis==1, nair tlower(100) tupper(600) xla(0(100)600) yla(0(.2)1, gstyle(minor))"
	stcband if Dis==1, nair tlower(100) tupper(600) xla(0(100)600) yla(0(.2)1, gstyle(minor))
	di 
	more
	di 
	di as txt "-> " as res "Generate and graph Hall-Wellner 95% confidence band in time interval 100 - 600" 
	di
	di as txt "-> " as res "stcband if Dis==1, tlower(100) tupper(600) genlo(lohw_band) genhi(uphw_band) xla(0(100)600) yla(0(.2)1, gstyle(minor))"
	stcband if Dis==1, tlower(100) tupper(600) genlo(lohw_band) genhi(uphw_band) xla(0(100)600) yla(0(.2)1, gstyle(minor))
	di
	more
	di
	di as txt "-> " as res "Graph simultaneously pointwise log-log confidence interval and Hall-Wellner arcsine transformed 95% confidence band" 
	di
	di as txt "-> " as res "sts gen pw_lo=lb(s) pw_hi= ub(s) if Dis==1"
	di as txt "-> " as res "stcband if Dis==1, tlower(100) tupper(600) transform(arcsine) xla(0(100)600) yla(0(.2)1, gstyle(minor)) legend(ring(0) pos(7) size(*.7)) plot(line pw_hi pw_lo _t if _t<600, sort c(J J) lc(red red))"
	sts gen pw_lo=lb(s) pw_hi= ub(s) if Dis==1
	stcband if Dis==1, tlower(100) tupper(600) xla(0(100)600) transform(arcsine) yla(0(.2)1, gstyle(minor)) legend(ring(0) pos(7) size(*.7)) plot(line pw_hi pw_lo _t if _t<600, sort c(J J) lc(red red))
	di 
	di as txt "-> " as res `"restore"'
end
