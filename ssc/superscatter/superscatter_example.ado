*! Version 1.4 19Jun2018  of Example program executed by superscatter.sthlp  
program superscatter_example
	version 11.1
    preserve
		set more off
		capture prog drop superscatter
		
        if "`c(os)'"~="MacOSX" {
                qui set autotabgraphs on
        }
		args extorun
		
		`extorun'
	restore
end

prog define setup
		di _n as inp ".  sysuse lifeexp, clear" 
		sysuse lifeexp, clear 

		di _n as inp ".  qui gen loggnp = log10(gnppc)"
		qui gen loggnp = log10(gnppc)

		di as inp `".  label var loggnp "Log base 10 of GNP per capita""'
		label var loggnp "Log base 10 of GNP per capita"
		
		di as inp `". qui gen us_gnp0 = country if country=="United States" | country=="Haiti" | gnppc>=."'
		qui gen us_gnp0 = country if country=="United States" | country=="Haiti" | gnppc>=.

		di as inp `". label var us_gnp0 "Labels of selected countries""'
		label var us_gnp0 "Labels of selected countries"
		
		di as inp `".  describe"'
		describe
		di as inp `".  summarize, detail"'
		summarize

		qui snapshot erase _all  //  Assures the snapshot will be #1
		qui snapshot save, label("Superscatter example data")
end
		
prog define example1
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *    Border the scatter plot with histograms."
		di _n as inp ".  superscatter lexp loggnp, name(_example1, replace)"
		superscatter lexp loggnp, name(_example1, replace)
end

prog define example2
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	Same plot with various optional cosmetic touches."
		di as inp `"superscatter lexp loggnp, percent color(dkorange) mlabel(us_gnp0) m(s) msize(small)  xtitle("GNP per capita (log)") name(_example2, replace)"'
		superscatter lexp loggnp, percent color(dkorange) mlabel(us_gnp0) m(s) msize(small)  xtitle("GNP per capita (log)") name(_example2, replace)
end

prog define example3
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	Replace the histograms with kernel density plots and add median lines and cell counts."
		di _n as inp ".  superscatter lexp loggnp, kdensity medians tabulate(count) matname(tabout) detail name(_example3, replace) "
		superscatter lexp loggnp, kdensity medians tabulate(count) matname(tabout) detail name(_example3, replace) 
		
		di _n as inp ".  *	List the statistics used to construct the tabulations."
		di _n as inp ".  return list"
		return list
		
		di _n as inp ".  matrix list r(tabout)"
		matrix list r(tabout)
end

prog define example4
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	To the bordered plot of example 1, add the fitted regression line and position the legend."
		di _n as inp ".  superscatter lexp loggnp, means fittype(lfitci) fitoptions(lwidth(vthick)) legend(ring(0) cols(1) pos(5)) ytitle(Life Expectancy) name(_example4, replace) "
		superscatter lexp loggnp, means fittype(lfitci) fitoptions(lwidth(vthick)) legend(ring(0) cols(1) pos(5)) ytitle(Life Expectancy) name(_example4, replace) 
end

prog define example5
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	Overlay the scatter plot with a bivariate normal confidence ellipse."
		di _n as inp ".  superscatter lexp loggnp, ellipse quartiles ytitle(Life Expectancy) name(_example5, replace) "
		superscatter lexp loggnp, ellipse quartiles ytitle(Life Expectancy) name(_example5, replace)
		di _n as inp ".  *	List the descriptive statistics used to construct the ellipse."
		di _n as inp ".  return list"
		return list
end

prog define example6
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	Overlay the scatter plot with both an ellipse and a fitted line."
		di _n as inp ".  superscatter lexp loggnp, means fittype(lfit) fitoptions(lwidth(vthick)) ellipse ytitle(Life Expectancy) name(_example6, replace) "
		superscatter lexp loggnp, means fittype(lfit) fitoptions(lwidth(vthick)) ellipse ytitle(Life Expectancy) name(_example6, replace)
end

prog define example7
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	Compare observed to predicted life expectancy with respect to a 45 degree line."
		di _n as inp ".  regress lexp loggnp"
		regress lexp loggnp
		di _n as inp ".  predict lexp_hat, xb"
		predict lexp_hat, xb

		di _n as inp `".  lab var lexp_hat "Fitted value of life expectancy""'
		lab var lexp_hat "Fitted value of life expectancy"

		di _n as inp `".  local textadds `"text(68 82 "Predicted less" "than observed") text(78 68 "Predicted greater" "than observed")"'
		local textadds `"text(68 82 "Predicted less" "than observed") text(76 68 "Predicted greater" "than observed") "'

		di _n as inp ".  superscatter lexp_hat lexp, line45 opt45(lwidth(vthick)) legend(off) mlabel(us_gnp0) ytitle(Predicted Life Expectancy) xtitle(Observed Life Expectancy) xlabel(55(5)90) \`textadds' name(_example7, replace) "
		superscatter lexp_hat lexp , line45 opt45(lwidth(vthick)) legend(off) mlabel(us_gnp0) ///
			ytitle(Predicted Life Expectancy) xtitle(Observed Life Expectancy)   ///
			xlabel(55(5)90) `textadds' name(_example7, replace) 
end
prog define example8
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	Scale both axes by the square-root."
		di _n as inp `".  superscatter lexp gnppc, sqrt (Life Expectancy on square-root scale) xtitle(GNP per capita on square-root scale) name(_example8, replace) "'
		superscatter lexp gnppc, sqrt ytitle(Life Expectancy on square-root scale) xtitle(GNP per capita on square-root scale)name(_example8, replace)
end

prog define example9a
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	Scaling both axes using the option -logh10pluszero- omits 7 observations."
		di _n as inp `".  superscatter popgrowth gnppc, log10pluszero ytitle(Population growth rates > 0 on log scale) xtitle(GNP per capita on log scale) mlabel(us_gnp0) mlabangle(45) name(_example9a, replace) "'
		superscatter popgrowth gnppc, log10pluszero ytitle(Population growth rates > 0 on log scale) xtitle(GNP per capita on log scale) mlabel(us_gnp0) mlabangle(45) name(_example9a, replace)
end

prog define example9b
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	Scale both axes by log to the base 10 after adding 1.0 to the variable."
		di _n as inp `".  superscatter popgrowth gnppc, log10plusone ytitle(Population growth rates > -1 on log scale) xtitle(GNP per capita on log scale) mlabel(us_gnp0) mlabangle(45) name(_example9b, replace) "'
		superscatter popgrowth gnppc, log10plusone ytitle(Population growth rates > -1 on log scale) xtitle(GNP per capita on log scale) mlabel(us_gnp0) mlabangle(45) name(_example9b, replace)
end

prog define example9c
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	Create a version of gnppc with zeros replacing missing values."

		di _n as inp ".  gen gnp0 = gnppc"
		gen gnp0 = gnppc
		
		di _n as inp ".  replace gnp0 = 0 if gnppc >=."
		replace gnp0 = 0 if gnppc >=.
		
		di _n as inp `".  label var gnp0 "Zero-filled GNP per capita" "'
		label var gnp0 "Zero-filled GNP per capita"
		
		di _n as inp ".  *	Scale both axes by log to the base 10 after adding 1.0 to the variable."
		di _n as inp `".  superscatter popgrowth gnp0, log10plusone ytitle(Population growth rates > -1 on log scale) xtitle(GNP per capita on log scale) mlabel(us_gnp0) mlabangle(45) name(_example9c, replace) "'
		superscatter popgrowth gnp0, log10plusone ytitle(Population growth rates > -1 on log scale) xtitle(GNP per capita on log scale) mlabel(us_gnp0) mlabangle(45) name(_example9c, replace)
end

prog define example10
		capture snapshot restore 1
			if _rc~=0  {
				di _n as err "Must {stata superscatter_example setup:click to set up data} before running any superscatter example from this help file."
				exit 111
			}
		di _n as inp ".  *	Highlight the North American countries."
		di _n as inp `".  superscatter lexp gnppc, hilite(region==2) hide(region==2) legend(order(1 "North America" 2 "Other regions") ring(0) pos(4) col(1)) name(_example10, replace)"'
		superscatter lexp gnppc, hilite(region==2) hide(region==2) legend(order(1 "North America" 2 "Other regions") ring(0) pos(4) col(1)) name(_example10, replace)
end
*	Version 1.0 by Keith Kranker <keith.kranker@gmail.com> on 2011/04/19 20:56:24 (revision b8ba72488bca)
*	Version 1.1 10Oct2015 by Mead Over to show additional features of superscatter
*	Version 1.2 26Jun2017 Allow user to "click to run" each example.  Add demonstrations of more additional features 
*	Version 1.3 18Jul2017 Add version 11.1
*	Version 1.31 25Jul2017 Add example 10
*	Version 1.4 19Jun2018 Change the option -line45options- to -opt45-.  Fix Ex. 7 so predicted is on y-axis
