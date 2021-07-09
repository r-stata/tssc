program metan_examples
	version 9.0
	`1'
end

program define metan_example_basic
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	di in wh ""
	di ". metan tdeath tnodeath cdeath cnodeath, rd random"
	di "> label(namevar=id, yearid=year) counts"

	metan tdeath tnodeath cdeath cnodeath, rd random ///
	label(namevar=id, yearid=year) counts
	restore
end

program define metan_example_cols
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	di in wh ""
	di ". metan tdeath tnodeath cdeath cnodeath,"
	di "> sortby(year) lcols(id year country) rcols(population)"
	di "> textsize(110) astext(60) double nostats nowt nohet notable"

	metan tdeath tnodeath cdeath cnodeath, ///
	  sortby(year) lcols(id year country) rcols(population) ///
	  textsize(110) astext(60) double nostats nowt nohet notable
	restore
end

program define metan_example_by
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	di in whi ""
	di ". metan tsample tmean tsd csample cmean csd,"
	di "> by(type_study) sgweight fixed second(random)"
	di "> rfdist counts label(namevar = id)"
	di "> favours(Treatment reduces blood pressure # Treatment increases blood pressure)"

	metan tsample tmean tsd csample cmean csd, ///
	  by(type_study) sgweight fixed second(random) ///
	  rfdist counts label(namevar = id) ///
	  favours(Treatment reduces blood pressure # Treatment increases blood pressure)
	restore
end

program metan_example_2param
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	di in whi ""
	di ""
	di ". gen logor = ln( (tdeath*cnodeath)/(tnodeath*cdeath) ) )"
	di ""
	di ". gen selogor = sqrt( (1/tdeath) + (1/tnodeath) + (1/cdeath) + (1/cnodeath) )"
	di ""
	di ". metan logor selogor, eform xlabel(0.5, 1, 1.5, 2, 2.5)"
	di "> force xtick(0.75, 1.25, 1.75, 2.25) effect(Odds ratio)"

	gen logor = ln( (tdeath*cnodeath)/(tnodeath*cdeath) )
	gen selogor = sqrt( (1/tdeath) + (1/tnodeath) + (1/cdeath) + (1/cnodeath) )
	metan logor selogor, eform xlabel(0.5, 1, 1.5, 2, 2.5) ///
	  force xtick(0.75, 1.25, 1.75, 2.25) effect(Odds ratio)
	restore
end

program define metan_example_diag
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	di in whi ""
	di ". metan percent lowerci upperci, wgt(n_positives)"
	di "> xlabel(0,10,20,30,40,50,60,70,80,90,100) force"
	di "> null(50) label(namevar=id) nooverall notable"
	di "> title(Sensitivity, position(6))"
	di in gr ""

	metan percent lowerci upperci, wgt(n_positives) ///
	  xlabel(0,10,20,30,40,50,60,70,80,90,100) force ///
	  null(50) label(namevar=id) nooverall notable ///
	  title(Sensitivity, position(6))
	restore
end

program define metan_example_user
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	di in whi ""
	di ". metan OR ORlci ORuci, wgt(bweight)"
	di "> first(0.924 0.753 1.095 Bayesian)"
	di "> firststats(param V=3.86, p=0.012)"
	di "> label(namevar=id)"
	di "> xlabel(0.25, 0.5, 1, 2, 4) force"
	di "> null(1) aspect(1.2) scheme(economist)"

	metan OR ORlci ORuci, wgt(bweight) ///
	  first(0.924 0.753 1.095 Bayesian) ///
	  firststats(param V=3.86, p=0.012) ///
	  label(namevar=id) ///
	  xlabel(0.25, 0.5, 1, 2, 4) force ///
	  null(1) aspect(1.2) scheme(economist)
	restore
end

program define metan_example_custom
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	di in whi ""
	di ""
	di `". gen counts = ". " + string(tdeath) + "/" + string(tdeath+tnodeath)"'
	di `"> + ", " + string(cdeath) + "/" + string(cdeath+cnodeath)"'
	di ""
	di ". metan tdeath tnodeath cdeath cnodeath,"
	di "> lcols(id year) notable"
	di "> boxopt( mcolor(forest_green) msymbol(triangle) )"
	di "> pointopt( msymbol(triangle) mcolor(gold) msize(tiny)"
	di "> mlabel(counts) mlabsize(vsmall) mlabcolor(forest_green) mlabposition(1) )"
	di "> ciopt( lcolor(sienna) lwidth(medium) )"

	gen counts = ". " + string(tdeath) + "/" + string(tdeath+tnodeath) ///
	  + ", " + string(cdeath) + "/" + string(cdeath+cnodeath)
	metan tdeath tnodeath cdeath cnodeath, ///
	  lcols(id year) notable ///
	  boxopt( mcolor(forest_green) msymbol(triangle) ) ///
	  pointopt( msymbol(triangle) mcolor(gold) msize(tiny) ///
	  mlabel(counts) mlabsize(vsmall) mlabcolor(forest_green) mlabposition(1) ) ///
	  ciopt( lcolor(sienna) lwidth(medium) )
	restore
end

program define funnel_example_immed
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	di in whi ""
	di ". metan tdeath tnodeath cdeath cnodeath, nograph notable"
	di ""
	di ". local ovratio=r(ES)"
	di ""
	di ". funnel, sample ysqrt xlabel(0.1,0.5,1,5,10)"
	di "> ylabel(0,500,1000) overall(`ovratio')"

	metan tdeath tnodeath cdeath cnodeath, nograph notable
	local ovratio=r(ES)
	funnel, sample ysqrt xlabel(0.1,0.5,1,5,10) ///
	  ylabel(0,500,1000) overall(`ovratio')
	restore
end

program define funnel_example_param
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	di in whi ""
	di ". gen logor = ln( (tdeath*cnodeath)/(tnodeath*cdeath) ) )"
	di ""
	di ". gen selogor = sqrt( (1/tdeath) + (1/tnodeath) + (1/cdeath) + (1/cnodeath) )"
	di ""
	di ". funnel OR selogor, xlabel(0.1,0.5,1,5,10)"
	di "> ylabel(0,1,2,3,4,5) xlog"

	gen logor = ln( (tdeath*cnodeath)/(tnodeath*cdeath) )
	gen selogor = sqrt( (1/tdeath) + (1/tnodeath) + (1/cdeath) + (1/cnodeath) )
	funnel OR selogor, xlabel(0.1,0.5,1,5,10) ///
	  ylabel(0,1,2,3,4,5) xlog
	restore
end

program define labbe_example
	preserve
	di ""
	use http://fmwww.bc.edu/repec/bocode/m/metan_example_data.dta, clear
	di in whi ""
	di ". labbe tdeath tnodeath cdeath cnodeath,"
	di "> xlabel(0,0.25,0.5,0.75,1) ylabel(0,0.25,0.5,0.75,1)"
	di "> rr(1.029) rd(0.014) null"

	labbe tdeath tnodeath cdeath cnodeath, ///
	  xlabel(0,0.25,0.5,0.75,1) ylabel(0,0.25,0.5,0.75,1) ///
	  rr(1.029) rd(0.014) null
	restore
end



