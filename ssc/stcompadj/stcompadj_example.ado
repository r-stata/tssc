*! version 1.0.1  21jun2009
program stcompadj_example
	if (_caller() <10) {
		di as err "This example requires version 10"
		exit 198
	}
	gettoken dsn1 0 : 0, parse(" :")
	gettoken dsn2 0 : 0, parse(" :")

	di as txt "-> " as res "preserve"
	preserve
	di
	cap findfile malignantmelanoma.dta
	if _rc {
		di as err "file malignantmelanoma.dta not found"
		exit 601 
	}
	local fileful `"`r(fn)'"'
	di in smcl as text "{title:First Example: showing the model and listing the estimates}"
	di
	di as txt "-> " as res "use `dsn1', clear"
	use `"`fileful'"',clear
	di
	di as txt "-> " as res "stset time,f(cause==1)"
	stset time,f(cause==1)
	di
	di as txt "-> " as res "stcompadj sex=1 thick=2, compet(2) maineffect(thick) showmod nolog nohr"
	stcompadj sex=1 thick=2, compet(2) maineffect(thick)  showmod nolog nohr
	di
	di in smcl as res "{p}The variable {it:thick} having effect only on the main event is included in the Cox model" ///
		" as {it:Main_thick}. {it:Compet_} prefixes the name of the variables having effect only on the competing event.{p_end}"
	di
	di in smcl as res "{p}The cumulative incidence estimates can be also obtained by using a flexible parametric model.{p_end}"
	di
	di as txt "-> " as res "stcompadj sex=1 thick=2, compet(2) maineffect(thick) flexible gen(FlexMain FlexCompet) showmod nolog"
	stcompadj sex=1 thick=2, compet(2) maineffect(thick)  flexible gen(FlexMain FlexCompet) showmod nolog
	format  CI_Main FlexMain CI_Compet FlexCompet %5.4f
	di
	di as txt "-> " as res "The list of the cumulative incidence for the main and competing event obtained by two methods is listed for the first 30 times"
	di
	di as txt "-> " as res "sort _t"
	sort _t
	di as txt "-> " as res "l _t cause CI_Main FlexMain CI_Compet FlexCompet in 1/30"
	l _t cause CI_Main FlexMain CI_Compet FlexCompet in 1/30
	di
	di
	di in smcl as text "{title:Second Example: Producing graphs}"
	di
	cap findfile si.dta
	if _rc {
		di as err "file si.dta not found"
		exit 601 
	}
	local fileful `"`r(fn)'"'
	di as txt "-> " as res "use `dsn2', clear"
	use `"`fileful'"',clear
	di as txt "-> " as res "stset time, f(status==1)"
	stset time, f(status==1)
	di 
	di as txt "-> " as res"stcompadj ccr=0 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main0 Compet0)"
	stcompadj ccr=0 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main0 Compet0)
	di
	di as txt "-> " as res "stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main1 Compet1)"
	stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main1 Compet1)
	di 
	di in smcl as txt "{p}-> " as res `"twoway line Main0 Main1 _t, sort c(J J) scheme(lean2) xti("Years from HIV Infection") yti("Cumulative Incidence")"' ///
		`" yla(0(.1).5,glp(shortdash)) xla(0(2)12) legend(pos(11) ring(0) label(1 "WW") label(2 "WM")) ti("AIDS"){p_end}"'
	twoway line Main0 Main1 _t, sort c(J J) scheme(lean2) xti("Years from HIV Infection") yti("Cumulative Incidence") ///
		yla(0(.1).5,glp(shortdash)) xla(0(2)12) legend(pos(11) ring(0) label(1 "WW") label(2 "WM")) ti("AIDS")
	more
	di
	di in smcl as txt "{p}-> " as res `"twoway line Compet0 Compet1 _t if _t<13.5, sort c(J J) scheme(lean2) xti("Years from HIV Infection")"' ///
		`"yti("Cumulative Incidence") yla(0(.1).5,glp(shortdash)) xla(0(2)12) legend(pos(11) ring(0) label(1 "WW") label(2 "WM")) ti("SI Appearance"){p_end}"'
	twoway line Compet0 Compet1 _t if _t<13.5, sort c(J J) scheme(lean2) xti("Years from HIV Infection") ///
		yti("Cumulative Incidence") yla(0(.1).5,glp(shortdash)) xla(0(2)12) legend(pos(11) ring(0) label(1 "WW") label(2 "WM")) ti("SI Appearance")
	more
	di
	drop Main* Compet*
	di
	di in smcl as text "{title:Third Example: Confidence Interval by resampling dataset}"
	di
	di as txt "-> " as res "stcompadj ccr=0 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main0 Compet0) bootci rep(100)"
	di as txt "-> " as res "(Replications are set to rep(100) only for speeding up the execution of the command)"
	di
	stcompadj ccr=0 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main0 Compet0) bootci rep(100)
	di as txt "-> " as res "stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main1 Compet1) bootci rep(100)"
	stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main1 Compet1) bootci rep(100)
	di
	di in smcl as txt "{p}-> " as res `"twoway line Main1 Hi_Main1 Lo_Main1 Main0 Hi_Main0 Lo_Main0 _t , sort c(J J J J J J)"' ///
		`"lp(l - - l - -) lc(red red red black black black) scheme(lean2) xti("Years from HIV Infection") yti("Cumulative Incidence") yla(0(.1).65,nogrid) "' ///
		`"xla(0(2)12) legend(pos(11) ring(0) label(1 "WW") label(4 "WM") order(1 4)) ti("AIDS"){p_end}"'
	twoway line Main1 Hi_Main1 Lo_Main1 Main0 Hi_Main0 Lo_Main0 _t , sort c(J J J J J J) ///
		lp(l - - l - -) lc(red red red black black black) scheme(lean2) xti("Years from HIV Infection") yti("Cumulative Incidence") yla(0(.1).65,nogrid) ///
		xla(0(2)12) legend(pos(11) ring(0) label(1 "WW") label(4 "WM") order(1 4)) ti("AIDS")
	more
	di
	di
	di in smcl as text "{title:Fourth Example: Confidence Interval by using a flexible parametric model}"
	di
	di as txt "-> " as res "stcompadj ccr=0 , compet(2) maineffect(ccr) competeffect(ccr) gen(Fl_Main0 Fl_Compet0) flexible ci "
	di
	stcompadj ccr=0 , compet(2) maineffect(ccr) competeffect(ccr) gen(Fl_Main0 Fl_Compet0) flexible ci
	di as txt "-> " as res "stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) gen(Fl_Main1 Fl_Compet1) flexible ci"
	stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) gen(Fl_Main1 Fl_Compet1) flexible ci
	di
	di in smcl as txt "{p}-> " as res `"twoway line Fl_Main1 Hi_Fl_Main1 Lo_Fl_Main1 Fl_Main0 Hi_Fl_Main0 Lo_Fl_Main0 _t , sort c(J J J J J J)"' ///
		`"lp(l - - l - -) lc(red red red black black black) scheme(lean2) xti("Years from HIV Infection") yti("Cumulative Incidence") yla(0(.1).65,nogrid)"' ///
		`"xla(0(2)12) legend(pos(11) ring(0) label(1 "WW") label(4 "WM") order(1 4)) ti("AIDS"){p_end}"'
	twoway line Fl_Main1 Hi_Fl_Main1 Lo_Fl_Main1 Fl_Main0 Hi_Fl_Main0 Lo_Fl_Main0 _t , sort c(J J J J J J) ///
		lp(l - - l - -) lc(red red red black black black) scheme(lean2) xti("Years from HIV Infection") yti("Cumulative Incidence") yla(0(.1).65,nogrid) ///
		xla(0(2)12) legend(pos(11) ring(0) label(1 "WW") label(4 "WM") order(1 4)) ti("AIDS")
	more
	di
	di
	di in smcl as text "{title:Fifth Example: Test of equality of the covariate effect on the main and on the competing event}"
	di
	di as txt "-> " as res "stcompadj ccr=1 , compet(2) savexp(silong,replace)"
	stcompadj ccr=1 , compet(2) savexp(silong,replace)
	di
	di as txt "-> " as res "use silong,clear"
	use silong,clear
	di
	di as txt "-> " as res "xi: stcox i.ccr*i.stratum, strata(stratum) nohr nolog"
	xi: stcox i.ccr*i.stratum, strata(stratum) nohr nolog
	di
	di in smcl as res "{p}The z and p-value for the term interacting ccr and stratum are the results of this test.{p_end}" 
	more
	di
	di
	di
	di in smcl as text "{title:Sixth Example: Test of equality of the hazards of the main and competing event under the assumption that they are proportional}"
	di
	di as txt "-> " as res "use si.dta,clear"
	use si.dta,clear
	di
	di as txt "-> " as res "stset time, f(status==1)"
	stset time, f(status==1)
	di
	di as txt "-> " as res "stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) savexp(silong,replace)"
	stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) savexp(silong,replace)
	di
	di as txt "-> " as res "use silong,clear"
	use silong,clear
	di
	di as txt "-> " as res "xi: stcox Main_ccr Compet_ccr stratum, nohr nolog"
	xi: stcox Main_ccr Compet_ccr stratum, nohr nolog
	di
	di in smcl as res "{p}The z and p-value for the stratum variable are the results of this test.{p_end}" 
	di
	di as txt "-> " as res `"restore"'
end
