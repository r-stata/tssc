*! version 1.0.0  10may2007
program stcoxgof_example
	if (_caller() < 8) {
		di as err "This example requires version 8"
		exit 198
	}
	if (_caller() < 8.2)  version 8
	else		      version 8.2
	gettoken dsn 0 : 0, parse(" :")
	gettoken null 0 : 0, parse(" :")
	di as txt "-> " as res "preserve"
	preserve
	di
	cap findfile uis_gof.dta
	if _rc {
		di as err "file uis_gof.dta not found"
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
	di as txt "-> " as res "Example GOF test of a Cox model" 
	di as txt "-> " as res "use `dsn', clear"
	de
	di
	di as txt "-> " as res "stset time, failure(cens)"
	stset time, failure(cens)
	di 
	di as txt "-> " as res "stcox age beck ndrugfp1 ndrugfp2 ivh_3 race treat site agesite racesite, mgale(m) nolog"
        stcox age beck ndrugfp1 ndrugfp2 ivh_3 race treat site agesite racesite, mgale(m) nolog
	di 
	di as txt "-> " as res "Gronnesby and Borgan test" 
	di as txt "-> " as res "stcoxgof"
	stcoxgof
        di
	di as txt "-> " as res "stcoxgof,gr(5)"
	stcoxgof,gr(5)
	di
	di as txt "-> " as res "Moreau, O'Quigley and Lellouch test" 
	di as txt "-> " as res "stcoxgof,mol(4)"
	stcoxgof,mol(4)
	di
	di as txt "-> " as res "stcoxgof,gr(5) mol(4)"
	stcoxgof,gr(5) mol(4)
	di
	di as txt "-> " as res "stcoxgof,gr(5) molat(84 170 376)"
	stcoxgof,gr(5) molat(84 170 376)
	di
	di as txt "-> " as res "Arjas like plots" 
	di as txt "-> " as res "stcoxgof,arjas(4) scheme(lean1) legend(rows(1))"
	stcoxgof, arjas(4) scheme(lean1) legend(rows(1))
	di
	di as txt "-> " as res "Moreau, O'Quigley and Mesbah test" 
	di as txt "-> " as res "stcox ivh_3 race treat,  nolog"
        stcox ivh_3 race treat, nolog
	di 
	di as txt "-> " as res "stcoxgof,mom(4)"
	stcoxgof,mom(4)
	di
	di as txt "-> " as res "stcoxgof,momat(84 170 376)"
	stcoxgof,momat(84 170 376) 
	di
	di "Note that, since just a few categorical covariates are used in the model, a bad fit is expected."
	di as txt "-> " as res `"restore"'
end
