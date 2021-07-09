*metacum_examples

program metacum_examples
	version 9.0
	`1'
end

program define metacum_ex1
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear

	di in wh ""
	di ". sort year"
	sort year
	di ""
	di ". metacum tdeath tnodeath cdeath cnodeath, rd random"
	di "> label(namevar=id, yearid=year) 

	metacum tdeath tnodeath cdeath cnodeath, rd random ///
	label(namevar=id, yearid=year)
	restore
end

program define metacum_ex2
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	
	di ". sort year"
	sort year
	di ""
	di ". gen logor = ln( (tdeath*cnodeath)/(tnodeath*cdeath) ) )"
	di ""
	di ". gen selogor = sqrt( (1/tdeath) + (1/tnodeath) + (1/cdeath) + (1/cnodeath) )"
	di ""
	di ". metacum logor selogor, eform xlabel(0.6, 0.8, 1, 1.2, 1.4, 1.6)"
	di "> force xtick(0.7, 0.9, 1.1, 1.3, 1.5) effect(Odds ratio) lcols(id year country)"

	gen logor = ln( (tdeath*cnodeath)/(tnodeath*cdeath) )
	gen selogor = sqrt( (1/tdeath) + (1/tnodeath) + (1/cdeath) + (1/cnodeath) )
	gen ORdesc = string(exp(logor), "%5.2f") + " (" + string(exp(logor-1.96*selogor), "%5.2f") ///
	             + string(exp(logor+1.96*selogor), "%5.2f") + ")"
	label var ORdesc "Trail odds ratio"
	metacum logor selogor, eform xlabel(0.6, 0.8, 1, 1.2, 1.4, 1.6) ///
	  force xtick(0.7, 0.9, 1.1, 1.3, 1.5) effect(Odds ratio) lcols(id year country)
	restore
end


