*! version 1.0.1  02jan2008
program stpepemori_example
	if (_caller() < 9) {
		di as err "This example requires version 9"
		exit 198
	}
	gettoken dsn 0 : 0, parse(" :")
	gettoken null 0 : 0, parse(" :")
	di as txt "-> " as res "preserve"
	preserve
	di
	cap findfile follic.dta
	if _rc {
		di as err "file follic.dta not found"
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
	di as txt "->  Example Pepe Mori test comparing cumulative incidence and conditional probability between two groups" 
	di
	di as txt "-> " as res "use `dsn', clear"
	de
	di
	di as txt "-> " as res "g byte age65 = age>65"
	g byte age65 = age>65
	di 
	di as txt "-> " as res `"g byte evcens = (resp=="NR" | relsite!="") + 2*(resp=="CR" & relsite=="" & stat==1)"'
	g byte evcens = (resp=="NR" | relsite!="") + 2*(resp=="CR" & relsite=="" & stat==1)
	di 
	di as txt "-> " as res "stset dftime, failure(evcens==1)"
	stset dftime, failure(evcens==1)
	di 
	di as txt "-> " as res "stpepemori age65, compet(2)"
        stpepemori age65, compet(2) 
	di 
	di as txt "-> " as res "Saving results"
	di as txt "-> " as res `"local p_main = round(\`r(p1)',.001)"'
	local p_main = round(`r(p1)',.001)
	di
	di
	di as txt "->  Computing and graphing cumulative incidence functions for the main event"
	di
	di as txt "-> " as res "stcompet ci = ci, compet1(2) by(age65)"
	di as txt "-> " as res "gen CI_older_main     = ci if age65==1 & evcens==1"
	di as txt "-> " as res "gen CI_younger_main   = ci if age65==0 & evcens==1"
	di as txt "-> " as res "qui count"
	di as txt "-> " as res `"local nobs = \`r(N)' + 1"'
	di as txt "-> " as res `"set obs \`nobs'"'
	di as txt "-> " as res "gen time = cond(_n!=_N,_t,0)"
	di as txt "-> " as res "replace CI_older_main = 0 if _n==_N"
	di as txt "-> " as res "replace CI_younger_main = 0 if _n==_N"
	di as txt "-> " as res "su _t if age65==1, meanonly"
	di as txt "-> " as res "sort time CI_older_main"
	di as txt "-> " as res "replace CI_older_main   = CI_older_main[_n-1]   if CI_older_main==. & _t<=\`r(max)'"
	di as txt "-> " as res "su _t if age65==0, meanonly"
	di as txt "-> " as res "sort time CI_younger_main"
	di as txt "-> " as res "replace CI_younger_main   = CI_younger_main[_n-1]   if CI_younger_main==. & _t<=\`r(max)'"
	stcompet ci = ci, compet1(2) by(age65)
	qui {
		gen CI_older_main    = ci if age65==1 & evcens==1
		gen CI_younger_main  = ci if age65==0 & evcens==1
		count
		local nobs = `r(N)' + 1
		set obs `nobs'
		gen time = cond(_n!=_N,_t,0)
		replace CI_older_main = 0 if _n==_N
		replace CI_younger_main = 0 if _n==_N
		su _t if age65==1, meanonly
		sort time CI_older_main
		replace CI_older_main   = CI_older_main[_n-1]      if CI_older_main==. & _t<=`r(max)'
		su _t if age65==0, meanonly
		sort time CI_younger_main
		replace CI_younger_main = CI_younger_main[_n-1]    if CI_younger_main==. & _t<=`r(max)'
	}
	di as txt "-> " as res "twoway line CI_younger_main CI_older_main time, sort c(J J) "  ///
		`"yti("Cumulatitve incidence of relapse", size(*.8))"' _n ///
		`"xla(0(5)30) yla(0(.2)1, nogrid angle(0)) scheme(lean2) "'  ///
		`"legend(label(1 "Age > 65") label(2 "Age <= 65") pos(11) ring(0))"' _n ///
		`"text(0.8 0 "Pepe and Mori's test: p-value = 0`p_main'", place(e)"'
	twoway line CI_younger_main CI_older_main time, sort c(J J) ///
		yti("Cumulative incidence of relapse", size(*.8)) ///
		xla(0(5)30) yla(0(.2)1, nogrid angle(0)) scheme(lean2) ///
		legend(label(1 "Age <= 65") label(2 "Age > 65") pos(11) ring(0)) ///
		text(0.8 0 "Pepe and Mori's test: p-value = 0`p_main'" , place(e))
	more
	di
	di
	di as txt "-> Computing and graphing conditional probability functions for the main event"
	di
	di as txt "-> " as res "stpepemori age65, compet(2) conditional" 
	di as txt "-> " as res `"local p_main = round(\`r(p1)',.001)"'
	stpepemori age65, compet(2) conditional
	local p_main = round(`r(p1)',.0001)
        di
	di
	di as txt "-> " as res "gen CI_older_compet   = ci if age65==1 & evcens==2"
	di as txt "-> " as res "gen CI_younger_compet = ci if age65==0 & evcens==2"
	di as txt "-> " as res "sort time CI_older_compet" 
	di as txt "-> " as res "replace CI_older_compet   = 0 if _n==1"
	di as txt "-> " as res "su _t if age65==1, meanonly"
	di as txt "-> " as res "replace CI_older_compet = CI_older_compet[_n-1] if CI_older_compet==. & _t<=\`r(max)'"
	di as txt "-> " as res "su _t if age65==0, meanonly"
	di as txt "-> " as res "sort time CI_younger_compet" 
	di as txt "-> " as res "replace CI_younger_compet = 0 if _n==1"
	di as txt "-> " as res "replace CI_younger_compet = CI_younger_compet[_n-1] if CI_younger_compet==. & _t<=\`r(max)'" 
	di as txt "-> " as res "gen CP_younger_main    = CI_younger_main   / (1-CI_younger_compet)"
	di as txt "-> " as res "gen CP_older_main   = CI_older_main   / (1-CI_older_compet)"
	qui {
		gen CI_older_compet   = ci if age65==1 & evcens==2
		gen CI_younger_compet = ci if age65==0 & evcens==2
		sort time CI_older_compet
		replace CI_older_compet = 0 if _n==1
		su _t if age65==1, meanonly
		replace CI_older_compet = CI_older_compet[_n-1] if CI_older_compet==. & _t<=`r(max)'
		su _t if age65==0, meanonly
		sort time CI_younger_compet 
		replace CI_younger_compet = 0 if _n==1
		replace CI_younger_compet = CI_younger_compet[_n-1] if CI_younger_compet==. & _t<=`r(max)' 
		gen CP_younger_main    = CI_younger_main   / (1-CI_younger_compet)
		gen CP_older_main   = CI_older_main   / (1-CI_older_compet)
	}
	di as txt "-> " as res "twoway line CP_younger_main CP_older_main time, sort c(J J) "  ///
		`"yti("Conditional probability of relapse conditioned on death", size(*.8))"' _n ///
		`"xla(0(5)30) yla(0(.2)1, nogrid angle(0)) scheme(lean2) "'   ///
		`"legend(label(1 "Age > 65") label(2 "Age <= 65") pos(11) ring(0))"' _n ///
		`"text(0.82 0 "Pepe and Mori's test: p-value = 0`p_main'", place(e) size(*.8)"'
	twoway line CP_younger_main CP_older_main time, sort c(J J) ///
		yti("Conditional probability of relapse conditioned on death", size(*.8)) ///
		xla(0(5)30) yla(0(.2)1, nogrid angle(0)) scheme(lean2) ///
		legend(label(1 "Age <= 65") label(2 "Age > 65") pos(11) ring(0)) ///
		text(0.82 0 "Pepe and Mori's test: p-value = 0`p_main'", place(e) size(*.8))
end
