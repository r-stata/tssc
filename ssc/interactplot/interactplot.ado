*! v1.1, 24jun2018, Jan Helmdag

/*
Abstract: Generate plots for interaction terms after
	multiplicative regressions

Change log:
	- Now able to run on Stata v.12 or newer
	- Now allows for prefixes in both dependent and independent variables
	- Resolved an isssue for inclusion of options in regression command
	- Identification of interaction terms now more accurate
	- Added title option
	- Included yline-option
	- Minor changes
*/

program interactplot
version 12.0
*---------------------------------------------------------------
capture which catplot
	if _rc == 111 {
		display as error "command catplot not found as either built-in or ado-file"
		quietly net from "http://fmwww.bc.edu/RePEc/bocode/c/"
		display as text "click {stata net install catplot.pkg:here} to install"
		exit
	}
*---------------------------------------------------------------
syntax, ///
	[Term(integer 1)] ///
	[SCHeme(string)] ///
	[byplot] ///
	[SUBplot(string)] ///
	[INTersteps(integer 30)] ///
	[Level(cilevel)] ///
	[REVerse] ///
	[cme] ///
	[YLABnum(integer 5)] [XLABnum(integer 5)] ///
	[bars(integer 100)] ///
	[name(string)] ///
	[kernel(string)] [KDArea] ///
	[FINTensity(integer 50)] ///
	[ADDscatter(string)] ///
	[FYsize(integer 25)] ///
	[yline(real 0)]
*---------------------------------------------------------------
	marksample touse
	preserve
*---------------------------------------------------------------
*Can only specify predict observed with addscatter

	if "`addscatter'"!="" & ("`addscatter'"!="predict" & "`addscatter'"!="observed") {
		display as error "Option addscatter(`addscatter') not allowed"
		exit 197
	}

	if "`subplot'"!="" & ("`subplot'"!="hist" & "`subplot'"!="kdens") {
		display as error "Option subplot(`subplot') not allowed"
		exit 197
	}
*---------------------------------------------------------------
*Define default plot to be density plot
	if regexm("`subplot'","hist")  {
		local subplot histogram
	}

	if regexm("`subplot'","kdens")  {
		local subplot kdensity
	}

	if "`subplot'" == ""  {
		local subplot kdensity
	}
*---------------------------------------------------------------
*Define label for recast of kdensity
	if regexm("`kdarea'","kdarea") {
		local kdarea recast(area)
	}
*---------------------------------------------------------------
*Define default kernel
	if "`kernel'" == "" {
		local kernel kernel(epanechnikov)
	}
*---------------------------------------------------------------
*Generate temporary dependent variable and extract variable label
	tempvar yvar
		quietly generate double `yvar' = `e(depvar)'
		label var `yvar' "`e(depvar)'"
		capture local ylab: var label `e(depvar)'

	if "`ylab'" == "" {
		local ylab "`e(depvar)'"
	}
*---------------------------------------------------------------
*Determine factors in interaction term if option term is empty

	*Free command line of comma and options (if applicable)
	local cmdline = regexr("`e(cmdline)'","\,[a-z]*","")

	if `term' == 1 {
		tokenize `cmdline'

		forvalues i = 1/1000 {
			if regexm("``i''", "#") {
				local intterm "``i''"
				continue, break
			}
		}

		local terms = regexr("`intterm'","#", " ")
		local terms = regexr("`terms'","#", " ")

		tokenize `terms'

		local first `1'
		local second `2'
	}

	else {
		tokenize `cmdline'

		forvalues i = 1/1000 {
			if regexm("``i''", "#") {
				local `term' `--term'
					if `term' == 0 {
						local intterm "``i''"
						continue, break
					}
			}
		}

		local terms = regexr("`intterm'","#", " ")
		local terms = regexr("`terms'","#", " ")

		tokenize `terms'

		local first `1'
		local second `2'
	}

	*Switch terms if reverse is on
	if regexm("`reverse'","reverse")==1 {
		local first `2'
		local second `1'
		local 1 `first'
		local 2 `second'
	}

	if "`first'" == "" | "`second'" == "" {
		display as error "No interaction term found"
		exit 111
	}
*---------------------------------------------------------------
*Set yline
	if `yline' == 0 {
		local yline "yline(0)"
	}
	else {
		local yline "yline(`yline')"
	}
*---------------------------------------------------------------
*Factor # factor
	if regexm("`first'","^i\.") + regexm("`second'","^i\.") == 2 {

		local xvar1 = regexr("`1'","i.", "")
		local xvar2 = regexr("`2'","i.", "")

		forvalues i = 1/2 {
			quietly levelsof `xvar`i'' if e(sample) & `touse', local(at`i')
		}

		quietly summ `xvar1' if e(sample) & `touse'
			local min = `r(min)'-.3
			local max = `r(max)'+.3
			local xrange "`min' `max'"
			local xlabnum: word count `at1'

		*Extract variable labels and value labels
			forvalues i = 1/2 {

				local xlab`i': var label `xvar`i''

				if "`xlab`i''"=="" {
					local xlab`i' `xvar`i''
				}
			}

			local forlab1: value label `xvar1'
			local forlab2: value label `xvar2'

		*Create labels for legend
			local counter 1
			foreach l of local at2 {

				if "`forlab2'" != "" {
					local label: label `forlab2' `l'
					local order `order' `counter' `"`label'"'
					local counter `++counter'
				}

				if "`forlab2'" == "" {
					local order `order' `counter' "`xvar2'==`l'"
					local counter `++counter'
				}
			}

		*Calculate margins
			quietly margins if e(sample), at(`xvar1'=(`at1') `xvar2'=(`at2')) level(`level')
			local title "Adjusted predictions with `level'% CIs"

		*Overlaid Plot
			if regexm("`byplot'","byplot")==0 {

				quietly marginsplot, ///
					scheme(`scheme') ///
					title(`title') ///
					ylabel(#`ylabnum', format(%9.0g) angle(ninety)) ///
					xlabel(, format(%9.0g)) ///
					ytitle("Linear pred. of `ylab'") xtitle("") ///
					xscale(alt range(`xrange')) ///
					legend(off) xtitle() recast(scatter) ///
					name(margins, replace) nodraw

				foreach l of local at2 {
					local freq "`freq' _freq`l'"
				}

				quietly contract `xvar1' `xvar2' if e(sample), nomiss
				quietly reshape wide _freq, i(`xvar1') j(`xvar2')

				quietly graph bar `freq', over(`xvar1') ///
					legend(on position(6) order(`order') rows(1)) scheme(`scheme') ///
					ylabel(#3, format(%9.0g) angle(ninety)) ///
					fysize(`fysize') ytitle("Frequency") stack ///
					name(bar, replace) nodraw

				graph combine margins bar, scheme(`scheme') xcommon cols(1) ///
					name(`name') note("Graphs by `xlab2'", size(vsmall))
			}

		*by-plot
			if regexm("`byplot'","byplot")==1 {

				quietly marginsplot, ///
					scheme(`scheme') ///
					ylabel(#`ylabnum', format(%9.0g) angle(ninety)) ///
					xlabel(#`xlabnum', format(%9.0g)) ///
					ytitle("Linear pred. of `ylab'") xtitle("") ///
					by(`xvar2') byopts(rows(1) title(`title')) legend(off) xtitle("") recast(scatter) ///
					xscale(range(`xrange') alt) xlabel(none) ///
					name(margins, replace) nodraw

				quietly catplot `xvar1' if e(sample) & `touse', by(`xvar2', row(1) note("")) ///
					subtitle("", nobox)  ///
					fysize(`fysize') recast(bar) scheme(`scheme') ///
					ylabel(#3, format(%9.0g) angle(ninety)) ///
					ytitle("Frequency") ///
					name(bar, replace) nodraw

				graph combine margins bar, ///
					scheme(`scheme') ///
					xcommon cols(1) ///
					name(`name') note("Graphs by `xlab2' over `xlab1'", size(vsmall))
			}
	}

*---------------------------------------------------------------
*Factor # continuous
	if regexm("`first'","^i\.") + regexm("`second'","^c\.") == 2 {

		tempvar xvar2
		quietly gen double `xvar2' = `second'

		local xvar1 = regexr("`1'","^i\.", "")
		*local xvar2 = regexr("`2'","c.", "")

		*Get summary statistics for graphs
			quietly summ `xvar2' if e(sample), detail
				local interim = (`r(max)'-`r(min)')/`intersteps'
				local at2 "`r(min)' (`interim') `r(max)'"
				local width = (`r(max)'-`r(min)')/`bars'
				local kdensrange "`r(min)' `r(max)'"

			quietly levelsof `xvar1' if e(sample), local(at1)

		*Extract variable labels and value labels

			*Continuous variable
				capture local xvar2woc = regexr("`second'", "^c\.", "")
				capture local xlab2: var label `xvar2woc'

				if "`xlab2'"=="" {
					local xlab2 "`xvar2woc'"
				}

			*Factor variable
				local xlab1: var label `xvar1'

				if "`xlab1'" == "" {
					local xlab1 `xvar1'
				}

				local forlab1: value label `xvar1'

			*Create labels for legend
				local counter 1
				foreach l of local at1 {

					if "`forlab1'" != "" {
						local label: label `forlab1' `l'
						local order `order' `counter' `"`label'"'
						local counter `++counter'
					}

					if "`forlab1'" == "" {
						local order `order' `counter' "`xvar1'==`l'"
						local counter `++counter'
					}
				}

		*Addscatter()
		if "`addscatter'" != "" {
			local nodraw
		}
		else {
			local nodraw nodraw
		}

		if regexm("`addscatter'","predict") == 1 {
			tokenize `at1'
			local num `1'
			local maxtoken: word count `at1'

			foreach i of local at1 {
				tempvar predictvar`i'
				predict `predictvar`i'' if e(sample) & `touse' & `xvar1'==`i'

					if `i'==``maxtoken'' {
						local addscatterplot "`addscatterplot' scatter `predictvar`i'' `xvar2' if e(sample) & `touse', nodraw"
							continue, break
					}

					local addscatterplot "`addscatterplot' scatter `predictvar`i'' `xvar2' if e(sample) & `touse' ||"

					local num `++num'
			}
		}

		if regexm("`addscatter'","observed") == 1 {
			tokenize `at1'
			local num `1'
			local maxtoken: word count `at1'

			foreach i of local at1 {

				if `i'==``maxtoken'' {
					local addscatterplot "`addscatterplot' scatter `yvar' `xvar2' if e(sample) & `touse' & `xvar1'==`i', nodraw"
							continue, break
					}

					local addscatterplot "`addscatterplot' scatter `yvar' `xvar2' if e(sample) & `touse' & `xvar1'==`i' ||"

					local num `++num'
			}
		}

		*Calculate margins
			quietly margins if e(sample), at(`second'=(`at2') `xvar1'=(`at1')) `atmeans' level(`level')
			local title "Adjusted predictions with `level'% CIs"

		*Overlaid plot
			if regexm("`byplot'","byplot") == 0 {

				tokenize `at1'

				local num 1
				foreach l of local at1 {
						local ciopts "`ciopts' ci`num'opts(lpattern(dash))"
						local num `++num'
				}

				*Marginsplot
					quietly marginsplot, ///
						scheme(`scheme') ///
						title(`title') ///
						ylabel(#`ylabnum', format(%9.0g) angle(ninety)) ///
						`yline' ///
						xlabel(#`xlabnum', format(%9.0g)) ///
						xtitle("") ytitle("Linear pred. of `ylab'") ///
						recast(line) recastci(rline) `ciopts' xscale(alt) legend(off) ///
						addplot(`addscatterplot') ///
						name(margins, replace) `nodraw'

				*Density plot
					local num `1'
					local maxtoken: word count `at1'

					foreach l of local at1 {
						local kdens "`kdens' kdensity `xvar2' if `xvar1'==`num', `kernel' `kdarea'"

						if `l'==``maxtoken'' {
							local kdens "`kdens' `kdarea' scheme(`scheme') legend(on position(6) rows(1) order(`order')) fysize(`fysize') ylabel(#1, format(%4.0g) angle(ninety)) xlabel(#`xlabnum', format(%9.0g)) range(`kdensrange') ytitle(kdens. `xlab2') xtitle("`xlab2'") name(kdens, replace) nodraw"
							continue, break
						}

						local kdens "`kdens' || "
						local num `++num'
					}

					quietly twoway `kdens'

				*Combine graphs
					graph combine margins kdens, scheme(`scheme') xcommon cols(1) ///
						name(`name')
			}

		*By-plot
			if regexm("`byplot'","byplot") == 1 {

				*Marginsplot
					quietly marginsplot, ///
						scheme(`scheme') ///
						ylabel(#`ylabnum', format(%9.0g) angle(ninety)) ///
						`yline' ///
						xlabel(#`xlabnum', format(%9.0g)) ///
						ytitle("Linear pred. of `ylab'") xtitle("") ///
						recast(line) recastci(rline) ci1opts(lpattern(dash)) xscale(alt) ///
						legend(off) by(`xvar1') byopts(row(1) title(`title')) unique ///
						addplot(`addscatterplot') ///
						name(margins, replace) nodraw

				*Histogram
					if regexm("`subplot'","^hi") == 1 {
						quietly histogram `xvar2' if e(sample), ///
							by(`xvar1', rows(1)) scheme(`scheme') ///
							ylabel(#2, format(%9.0g) angle(ninety)) ///
							xlabel(#`xlabnum', format(%9.0g)) ///
							width(`width') freq fysize(`fysize') title("") ///
							ytitle("Frequency") xtitle("`xlab2'") ///
							subtitle(, size(zero) nobox) ///
							name(`subplot', replace) nodraw
					}

				*Density plot
					if regexm("`subplot'","^kd") == 1 {
						quietly twoway kdensity `xvar2' if e(sample), ///
							by(`xvar1', rows(1)) `kernel' `kdarea' scheme(`scheme') ///
							ylabel(#1, format(%6.0g) angle(ninety)) ytitle("Kernel dens.") ///
							xlabel(#`xlabnum', format(%9.0g)) ///
							fysize(`fysize') title("") xtitle("`xlab2'") ///
							range(`kdensrange') ///
							subtitle(, size(zero) nobox) ///
							name(`subplot', replace) nodraw
					}

				*Combine graphs
					graph combine margins `subplot', ///
						scheme(`scheme') ///
						xcommon cols(1) ///
						name(`name')
				*}
			}
	}
*---------------------------------------------------------------
*Continuous # factor

	if regexm("`first'","^c\.") + regexm("`second'","^i\.") == 2 {

		tempvar xvar1
		quietly gen double `xvar1' = `first'

		*local xvar1 = regexr("`1'","c.", "")
		local xvar2 = regexr("`2'","i.", "")

	quietly levelsof `xvar2' if e(sample), local(at2)

	*Extend range for optical reasons
			quietly summ `xvar2' if e(sample) & `touse'
				local min = `r(min)'-.3
				local max = `r(max)'+.3
				local xrange "`min' `max'"

	*Extract variable labels and value labels

		*Continuous variable
			capture local xvar1woc = regexr("`first'", "^c\.", "")
			capture local xlab1: var label `xvar1woc'

			if "`xlab1'"=="" {
				local xlab1 "`xvar1woc'"
			}

		*Factor variable
			local xlab2: var label `xvar2'

			if "`xlab2'" == "" {
				local xlab2 `xvar2'
			}

			local forlab2: value label `xvar2'

	*Create labels for legend
		local counter 1
		foreach l of local at2 {

			if "`forlab2'" != "" {
				local label: label `forlab2' `l'
				local order `order' `counter' `"`label'"'
				local counter `++counter'
			}

			if "`forlab2'" == "" {
				local order `order' `counter' "`xvar2'==`l'"
				local counter `++counter'
			}
		}

	*Calculate margins
		if "`cme'" == "" {
			quietly margins if e(sample), at(`xvar2'=(`at2')) atmeans level(`level')
			local title "Adjusted predictions with `level'% CIs"
		}

		else {
			quietly margins if e(sample), at(`xvar2'=(`at2')) atmeans level(`level') dydx(`first')
			local title "Cond. marginal effects of `xlab1' with `level'% CIs"
		}

	*Overlaid plot
		if regexm("`byplot'","byplot") == 0 {

			*Marginsplot
				quietly marginsplot,  ///
					scheme(`scheme') ///
					title(`title') ///
					ylabel(#`ylabnum', format(%9.0g) angle(ninety)) ///
					`yline' ///
					xlabel(, format(%9.0g)) ///
					xtitle("") ytitle("Linear pred. of `ylab'") ///
					recast(scatter) `ciopts' legend(off) plotdimension(`xvar2') ///
					xscale(alt) xlabel(#0, noticks) xmtick(none, noticks) ///
					name(margins, replace) nodraw

				foreach l of local at2 {
						local freq "`freq' num`l'"
					}

				quietly collapse (count) `xvar1' if e(sample) & `touse', by(`xvar2')
				quietly gen num = _n
				quietly reshape wide num, i(`xvar1') j(`xvar2')


				quietly graph bar (count) `freq' [fweight=`xvar1'], ///
						legend(on position(6) order(`order') rows(1)) scheme(`scheme') ///
						ylabel(#3, format(%9.0g) angle(ninety)) ///
						fysize(`fysize') ytitle("Frequency") stack ///
						name(bar, replace) nodraw

			*Combine graphs
				graph combine margins bar, scheme(`scheme') xcommon cols(1) ///
					name(`name') note("Graph over `xlab2'", size(vsmall))
		}

	*By-plot
		if regexm("`byplot'","byplot")==1 {

			*Marginsplot
				quietly marginsplot, ///
					scheme(`scheme') ///
					title(`title') ///
					ylabel(#`ylabnum', format(%9.0g) angle(ninety)) ///
					`yline' ///
					xlabel(, format(%9.0g)) ///
					xtitle("") ytitle("Linear pred. of `ylab'") ///
					recast(scatter) `ciopts' xscale(range(`xrange') alt) legend(off) ///
					name(margins, replace) nodraw

			*Catplot
				catplot `xvar2' if e(sample), ///
				recast(bar)	fysize(`fysize') scheme(`scheme') ///
					ylabel(#2, format(%9.0g) angle(ninety)) ///
					ytitle("Frequency") ///
					name(bar, replace) nodraw

			*Combine graphs
				graph combine margins bar, ///
					scheme(`scheme') ///
					xcommon cols(1) ///
					name(`name') ///
					note("Graphs by `xlab2'", size(vsmall))
		}
	}

*---------------------------------------------------------------
*Continuous1 # Continuous2
	if regexm("`first'","^c\.") + regexm("`second'","^c\.") == 2 {

		local margins margins

		if regexm("`byplot'","byplot") == 1 {
			display as error "byplot not possible with two metric variables"
			exit 197
		}

		tempvar xvar1
		tempvar xvar2

		quietly gen double `xvar1' = `first'
		quietly gen double `xvar2' = `second'

		*Addscatter()
		if "`addscatter'" != "" {
			local nodraw
		}
		else {
			local nodraw nodraw
		}

		if regexm("`addscatter'","predict") == 1 {
			tempvar predictvar
			predict `predictvar' if e(sample) & `touse'
			local addscatter addplot(scatter `predictvar' `xvar1' if e(sample) & `touse', nodraw)
		}

		if regexm("`addscatter'","observed") == 1 {
			local addscatter addplot(scatter `yvar' `xvar1' if e(sample) & `touse', nodraw)
		}

		*Extract variable labels and value labels
			capture local xvar1woc = regexr("`first'", "^c\.", "")
			capture local xvar2woc = regexr("`second'", "^c\.", "")

			capture local xlab1: var label `xvar1woc'
			capture local xlab2: var label `xvar2woc'

			if "`xlab1'"=="" {
				local xlab1 "`xvar1woc'"
			}

			if "`xlab2'"=="" {
				local xlab2 "`xvar2woc'"
			}

		*Get summary statistics for graphs
			quietly summ `xvar1' if e(sample)
				local interim = (`r(max)'-`r(min)')/`intersteps'
				local at1 "`r(min)' (`interim') `r(max)'"
				local width = (`r(max)'-`r(min)')/`bars'
				local kdensrange "`r(min)' `r(max)'"

			*quietly summ `xvar2' if e(sample), detail
				*local at2 "`r(p1)' `r(p25)' `r(p50)' `r(p75)' `r(p99)'"

				/*tempvar quantiles
					gen `quantiles' = cond(inrange(`xvar2',`r(p1)',`r(p25)'),0, ///
					cond(inrange(`xvar2',`r(p25)',`r(p50)'),1, ///
					cond(inrange(`xvar2',`r(p50)',`r(p75)'),2, ///
					cond(inrange(`xvar2',`r(p75)',`r(p99)'),3,.))))

					levelsof `quantiles', local(quantat)
				*/

		if "`cme'" == "cme" {

			if "`addscatter'" != "" {
				display as error "Option addscatter not allowed with option cme"
				exit 197
			}

			quietly margins if e(sample), at(`first'=(`at1')) dydx(`second') atmeans level(`level')

			if "`yline'" == "" {
				local yline yline(0)
			}

			quietly marginsplot, ///
				scheme(`scheme') ///
				title("Conditional marginal effects of `xlab2' with `level'% CIs") ///
				ylabel(#`ylabnum', format(%9.0g) angle(ninety)) ///
				`yline' ///
				xtitle("") ytitle("Effects on linear pred. of `ylab'") ///
				xlabel(#`xlabnum', format(%9.0g)) ///
				recast(line) recastci(rline) ci1opts(lpattern(dash)) xscale(alt) ///
				name(margins, replace) nodraw
			}

		if "`cme'" == "" {

			quietly margins if e(sample), at(`first'=(`at1')) atmeans level(`level')

			quietly marginsplot, ///
				scheme(`scheme') ///
				title("Adj. pred. at `xlab2'=0 with `level'% CIs") ///
				ylabel(#`ylabnum', format(%9.0g) angle(ninety)) ///
				`yline' ///
				xtitle("") ytitle("Linear pred. of `ylab'") ///
				xlabel(#`xlabnum', format(%9.0g)) ///
				recast(line) recastci(rline) ci1opts(lpattern(dash)) xscale(alt) legend(off) ///
				`addscatter' ///
				name(margins, replace) `nodraw'
		}

		*Density plot
			if regexm("`subplot'","^kd") == 1 {

				quietly twoway kdensity `xvar1' if e(sample), scheme(`scheme') ylabel(#2, format(%9.0g) angle(ninety)) ///
					xtitle("`xlab1'") ytitle("Kernel dens.") ///
					`kernel' `kdarea' range(`kdensrange') fintensity(`fintensity') fysize(`fysize') title("") note("") ///
					xlabel(#`xlabnum', format(%9.0g)) ///
					name(`subplot', replace) nodraw
			}

		*Histogram plot
			if regexm("`subplot'","^hi") == 1 {

				quietly histogram `xvar1' if e(sample), scheme(`scheme') ylabel(#2, format(%9.0g) angle(ninety)) ///
					width(`width') fraction fintensity(`fintensity') fysize(`fysize') title("") note("") ///
					xlabel(#`xlabnum', format(%9.0g)) xtitle("Frequency") ///
					name(`subplot', replace) nodraw
			}

		*Combine graphs
			quietly graph combine `margins' `subplot', ///
				scheme(`scheme') ///
				xcommon cols(1) ///
				name(`name')
	}
*---------
*Clear up
	capture graph drop margins
*---------
end
