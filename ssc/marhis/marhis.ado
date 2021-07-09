*! Version 1.0 12Feb2016
* Enrique.Hernandez@EUI.eu
* Predictive margins and marginal effects plots with histogram in the back after regress, logit, xtmixed and mixed.

capture program drop marhis
program define marhis
		version 13.0
		syntax varlist(max=1), [mar(varname)] [cate(varname)] [points(integer 15)] [percent] [discrete] [level(integer 95)] [label(integer 4)]  [summaryno] [confidenceno] [atmeans]
		local cmd = e(cmd)
		if  "`cmd'" != "logit" & "`cmd'" !=  "xtmixed" & "`cmd'" !=  "mixed" & "`cmd'" !=  "regress" {
			display as error "`cmd' not supported. marhis can only be used after: regress, logit, xtmixed, mixed"
			exit 301
		}
		local labell = `label'+1
		if "`percent'" == "" {
			local measure = "Density"
		}
		if "`percent'" != "" {
			local measure = "Percent"
		}
		if "`mar'" == "" & "`cate'" == "" {
				local depvar = e(depvar)
				quietly {
						tempvar sample 
						gen `sample' = e(sample) 
						local coeff = _b[`varlist']
						local se = _se[`varlist']
						local t = `coeff'/`se'
						local coeff = round(`coeff', .001)
						local t = round(`t', .01)
						sum `varlist' if `sample' == 1
						local min = r(min)
						local max = r(max) 
						local steps = (`max'-`min')/`points'
						local lab = (`max'-`min')/`labell'
				}
				display "Estimating margins"
				quietly {
						if "`atmeans'" == "" {
								margins, at(`varlist'=(`min'(`steps')`max')) level(`level')
								local sti = "margins, at(`varlist'=(`min'(`steps')`max')) level(`level')"
								local estimation = r(predict_label)
								local estimation2 = "Average Adjusted Predictions (AAPs)"
						}
						if "`atmeans'" != "" {
								margins, atmeans at(`varlist'=(`min'(`steps')`max')) level(`level')
								local sti = "margins, atmeans at(`varlist'=(`min'(`steps')`max')) level(`level')"
								local estimation = r(predict_label)
								local estimation2 = "Adjusted Predictions at Means (APMs)"
						}
				}
				display "Margins obtained through: `sti'"
				display "Graphing `estimation2' of `depvar' across values of `varlist'"
				quietly {
						matrix A = r(at) 
						matrix B = r(table)'
						local maxat = `points' + 1 
						matrix D = A[1..`maxat', "`varlist'"]
						matrix C = B, D
						tempname tempr
						svmat C, name(`tempr')
						if  "`cmd'" == "regress" {
								if "`summaryno'" == "" {
										if "`confidenceno'" == "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max')  yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' `depvar' with `level' percent CI", size(small))) ///
												(rline `tempr'5 `tempr'6 `tempr'10, lpattern(dash) yaxis(1) lcolor(navy)) , ///
												legend(off) note(Coefficient `varlist' = `coeff'   t-statistic = `t' )
												drop `tempr'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' `depvar'", size(small))), ///
												legend(off) note(Coefficient `varlist' = `coeff'   t-statistic = `t' )
												drop `tempr'*
												exit
										}							
								}
								if "`summaryno'" != "" {
										if "`confidenceno'" == "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14)  ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' `depvar' with `level' percent CI", size(small))) ///
												(rline `tempr'5 `tempr'6 `tempr'10, lpattern(dash) yaxis(1) lcolor(navy)) , ///
												legend(off) 
												drop `tempr'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' `depvar'", size(small))), ///
												legend(off) 
												drop `tempr'*
												exit
										}							
								}
						}
						if  "`cmd'" == "logit" | "`cmd'"  ==  "xtmixed" | "`cmd'"  ==  "mixed" {
								if "`summaryno'" == "" {
										if "`confidenceno'" == "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' with `level' percent CI", size(small))) ///
												(rline `tempr'5 `tempr'6 `tempr'10, lpattern(dash) yaxis(1) lcolor(navy)) , ///
												legend(off) note(Coefficient `varlist' = `coeff'   z-statistic = `t' )
												drop `tempr'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14)  ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation'", size(small))), ///
												legend(off) note(Coefficient `varlist' = `coeff'   z-statistic = `t' )
												drop `tempr'*
												exit
										}							
								}
								if "`summaryno'" != "" {
										if "`confidenceno'" == "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14)  ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' with `level' percent CI", size(small))) ///
												(rline `tempr'5 `tempr'6 `tempr'10, lpattern(dash) yaxis(1) lcolor(navy)) , ///
												legend(off) 
												drop `tempr'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14)  ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation'", size(small))), ///
												legend(off) 
												drop `tempr'*
												exit
										}							
								}
						}
				}
		}
		if "`mar'" != "" {
				local depvar = e(depvar)
				local cmd = e(cmd)
				quietly {
						tempvar sample case
						gen `sample' = e(sample) 
						local coeff = _b[c.`varlist'#c.`mar']
						local se = _se[c.`varlist'#c.`mar']
						local t = `coeff'/`se'
						local coeff = round(`coeff', .001)
						local t = round(`t', .01)
						sum `varlist' if `sample' == 1
						local min = r(min)
						local max = r(max) 
						local steps = (`max'-`min')/`points'
						local lab = (`max'-`min')/`labell'
				}
				display "Estimating margins"
				quietly {
						if "`atmeans'" == "" {
								margins, dydx(`mar') at(`varlist'=(`min'(`steps')`max')) level(`level')
								local sti = "margins, dydx(`mar') at(`varlist'=(`min'(`steps')`max')) level(`level')"
								local estimation = r(predict_label)
								local estimation2 = "Average Marginal Effects (AMEs)"
						}
						if "`atmeans'" != "" {
								margins, atmeans dydx(`mar') at(`varlist'=(`min'(`steps')`max')) level(`level')
								local sti = "margins, atmeans dydx(`mar') at(`varlist'=(`min'(`steps')`max')) level(`level')"
								local estimation = r(predict_label)
								local estimation2 = "Marginal Effects at Means (MEMs)"
						}
				}
				display "Margins obtained through: `sti'"
				display "Graphing `estimation2' of `mar' on `depvar' across values of `varlist''"
				if  "`cmd'" == "regress" {
						matrix A = r(at) 
						matrix B = r(table)'
						local maxat = `points' + 1 
						matrix D = A[1..`maxat', "`varlist'"]
						matrix C = B, D
						tempname tempr
						svmat C, name(`tempr')
						quietly {
								if "`summaryno'" == "" {
										if "`confidenceno'" == "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(function y=0 if `sample' == 1, ra(`min' `max')) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("Effects of `mar' on `estimation' with `level' percent CI", size(small))) ///
												(rline `tempr'5 `tempr'6 `tempr'10, lpattern(dash) yaxis(1) lcolor(navy)) ///
												, legend(off) note(Coefficient of product term = `coeff'  t-statistic = `t')
												drop `tempr'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(function y=0 if `sample' == 1, ra(`min' `max')) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("Effects of `mar' on `estimation' with `level' percent CI", size(small))) ///
												, legend(off) note(Coefficient of product term = `coeff'  t-statistic = `t')
												drop `tempr'*
												exit
										}										
								}
								if "`summaryno'" != "" {
										if "`confidenceno'" == "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(function y=0 if `sample' == 1, ra(`min' `max')) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("Effects of `mar' on `estimation' with `level' percent CI", size(small))) ///
												(rline `tempr'5 `tempr'6 `tempr'10, lpattern(dash) yaxis(1) lcolor(navy)) ///
												, legend(off)
												drop `tempr'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(function y=0 if `sample' == 1, ra(`min' `max')) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("Effects of `mar' on `estimation' with `level' percent CI", size(small))) ///
												, legend(off)
												drop `tempr'*
												exit
										}										
								}				
						}
				}
				if  "`cmd'" == "logit" | "`cmd'"  ==  "xtmixed" | "`cmd'"  ==  "mixed"  {
						matrix A = r(at) 
						matrix B = r(table)'
						local maxat = `points' + 1 
						matrix D = A[1..`maxat', "`varlist'"]
						matrix C = B, D
						tempname tempr
						svmat C, name(`tempr')
						quietly {
								if "`summaryno'" == "" {
										if "`confidenceno'" == "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(function y=0, ra(`min' `max')) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("Effects of `mar' on `estimation' with `level' percent CI", size(small))) ///
												(rline `tempr'5 `tempr'6 `tempr'10, lpattern(dash) yaxis(1) lcolor(navy)) ///
												, legend(off) note(Coefficient of product term = `coeff'  z-statistic = `t')
												drop `tempr'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(function y=0, ra(`min' `max')) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("Effects of `mar' on `estimation' with `level' percent CI", size(small))) ///
												, legend(off) note(Coefficient of product term = `coeff'  z-statistic = `t')
												drop `tempr'*
												exit
										}										
								}
								if "`summaryno'" != "" {
										if "`confidenceno'" == "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(function y=0, ra(`min' `max')) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("Effects of `mar' on `estimation' with `level' percent CI", size(small))) ///
												(rline `tempr'5 `tempr'6 `tempr'10, lpattern(dash) yaxis(1) lcolor(navy)) ///
												, legend(off)
												drop `tempr'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway (hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist', size(small))) ///
												(function y=0, ra(`min' `max')) ///
												(line `tempr'1 `tempr'10, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("Effects of `mar' on `estimation' with `level' percent CI", size(small))) ///
												, legend(off)
												drop `tempr'*
												exit
										}										
								}
						}
				}				
		}
		if "`cate'" != "" {
				quietly: ta `cate' 
				local ncat = r(r) 
				local depvar = e(depvar)
				local labelling : value label `cate'
				if "`labelling'" == "" {
						display as error "Values of categorical term of the interaction (`cate') are not labelled."
						exit 182
				}
				if `ncat' > 5 {
						display as error "Number of categories of categorical term of the interaction exceeds maximum of 5"
						exit 149
				}
				if `ncat' >= 2 {
						tempvar sample x h 
						gen `sample' = e(sample) 
						quietly {
								sum `varlist' if `sample' == 1
								local min = r(min)
								local max = r(max) 
								local steps = (`max'-`min')/`points'
								local lab = (`max'-`min')/`labell'
						}
						quietly {
								levelsof `cate', local(levels)
								local lbe : value label `cate'
								foreach l of local levels {
										local f`l' : label `lbe' `l'
								}
						}
						display "Estimating margins"
						quietly {
								if "`atmeans'" == "" {
										margins `cate',  at(`varlist'=(`min'(`steps')`max')) level(`level')
										local sti = "margins `cate',  at(`varlist'=(`min'(`steps')`max')) level(`level')"
										local estimation = r(predict_label)
										local estimation2 = "Average Adjusted Predictions (AAPs)"
								}
								if "`atmeans'" != "" {
										margins `cate', atmeans at(`varlist'=(`min'(`steps')`max')) level(`level')
										local sti = "margins `cate', atmeans at(`varlist'=(`min'(`steps')`max')) level(`level')"
										local estimation = r(predict_label)
										local estimation2 = "Adjusted Predictions at Means (APMs)"
								}
						}
						display "Margins obtained through: `sti'"
						display "Graphing `estimation2' of `depvar' for categories of `cate' across values of `varlist'"
						if `ncat' == 2{
								quietly{
										matrix C = r(table)'
										matrix A = r(at)
										local maxat = `points' + 1
										matrix A = A[1..`maxat',"`varlist'"]
										levelsof `cate', local(values)
										matrix input Z = (`values')
										forval cat = 1/2{
												local cat`cat' = Z[1,`cat']
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat1'.`cate'", "b".."ul"]
												if `i' == 1 matrix F = b
												else matrix F = (F \ b)	
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat2'.`cate'", "b".."ul"]
												if `i' == 1 matrix G = b
												else matrix G = (G \ b)
										}
										matrix ca1 = A,F
										matrix ca2 = A,G
										tempname catt1
										svmat ca1, name(`catt1')
										tempname catt2
										svmat ca2, name(`catt2')
										if "`confidenceno'" == "" {
												twoway ///
												(hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist',size(small))) ///
												(line `catt1'2 `catt1'1, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' with `level' percent CI", size(small))) ///
												(rcap `catt1'7 `catt1'6 `catt1'1, lpattern(solid) yaxis(1) lcolor(navy)) /// 
												(line `catt2'2 `catt2'1, yaxis(1) lcolor(maroon) lpattern(dash))  ///
												(rcap `catt2'7 `catt2'6 `catt2'1, lpattern(solid) yaxis(1) lcolor(maroon)) ///
												, legend(order(2 "`f`cat1''" 4 "`f`cat2''"))
												drop `catt1'*  `catt2'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway ///
												(hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14)  ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist',size(small))) ///
												(line `catt1'2 `catt1'1, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation'", size(small))) ///
												(line `catt2'2 `catt2'1, yaxis(1) lcolor(maroon) lpattern(dash))  ///
												, legend(order(2 "`f`cat1''" 3 "`f`cat2''"))
												drop `catt1'*  `catt2'*
												exit
										}							
								}
						}
						if `ncat' == 3{
								quietly{
										matrix C = r(table)'
										matrix A = r(at)
										local maxat = `points' + 1
										matrix A = A[1..`maxat',"`varlist'"]
										levelsof `cate', local(values)
										matrix input Z = (`values')
										forval cat = 1/3{
												local cat`cat' = Z[1,`cat']
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat1'.`cate'", "b".."ul"]
												if `i' == 1 matrix F = b
												else matrix F = (F \ b)	
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat2'.`cate'", "b".."ul"]
												if `i' == 1 matrix G = b
												else matrix G = (G \ b)
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat3'.`cate'", "b".."ul"]
												if `i' == 1 matrix H = b
												else matrix H = (H \ b)
										}
										matrix ca1 = A,F
										matrix ca2 = A,G
										matrix ca3 = A,H
										tempname catt1
										svmat ca1, name(`catt1')
										tempname catt2
										svmat ca2, name(`catt2')
										tempname catt3
										svmat ca3, name(`catt3')
										if "`confidenceno'" == "" {
												twoway ///
												(hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist',size(small))) ///
												(line `catt1'2 `catt1'1, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' with `level' percent CI", size(small))) ///
												(rcap `catt1'7 `catt1'6 `catt1'1, lpattern(solid) yaxis(1) lcolor(navy)) /// 
												(line `catt2'2 `catt2'1, yaxis(1) lcolor(maroon) lpattern(dash))  ///
												(rcap `catt2'7 `catt2'6 `catt2'1, lpattern(solid) yaxis(1) lcolor(maroon)) ///
												(line `catt3'2 `catt3'1, yaxis(1) lcolor(dkgreen) lpattern(dot))  ///
												(rcap `catt3'7 `catt3'6 `catt3'1, lpattern(solid) yaxis(1) lcolor(dkgreen)) ///
												, legend(order(2 "`f`cat1''" 4 "`f`cat2''" 6 "`f`cat3''" )) 
												drop `catt1'*  `catt2'* `catt3'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway ///
												(hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist',size(small))) ///
												(line `catt1'2 `catt1'1, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' `depvar'", size(small))) ///
												(line `catt2'2 `catt2'1, yaxis(1) lcolor(maroon) lpattern(dash))  ///
												(line `catt3'2 `catt3'1, yaxis(1) lcolor(dkgreen) lpattern(dot))  ///
												, legend(order(2 "`f`cat1''" 3 "`f`cat2''" 4 "`f`cat3''" )) 
												drop `catt1'*  `catt2'*
											exit
										}
						
								}	
							
						}
						if `ncat' == 4{
								quietly{
										matrix C = r(table)'
										matrix A = r(at)
										local maxat = `points' + 1
										matrix A = A[1..`maxat',"`varlist'"]
										levelsof `cate', local(values)
										matrix input Z = (`values')
										forval cat = 1/4{
												local cat`cat' = Z[1,`cat']
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat1'.`cate'", "b".."ul"]
												if `i' == 1 matrix F = b
												else matrix F = (F \ b)	
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat2'.`cate'", "b".."ul"]
												if `i' == 1 matrix G = b
												else matrix G = (G \ b)
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat3'.`cate'", "b".."ul"]
												if `i' == 1 matrix H = b
												else matrix H = (H \ b)
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat4'.`cate'", "b".."ul"]
												if `i' == 1 matrix I = b
												else matrix I = (I \ b)
										}
										matrix ca1 = A,F
										matrix ca2 = A,G
										matrix ca3 = A,H
										matrix ca4 = A,I								
										tempname catt1
										svmat ca1, name(`catt1')
										tempname catt2
										svmat ca2, name(`catt2')
										tempname catt3
										svmat ca3, name(`catt3')
										tempname catt4
										svmat ca4, name(`catt4')
										if "`confidenceno'" == "" {
												twoway ///
												(hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist',size(small))) ///
												(line `catt1'2 `catt1'1, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' with `level' percent CI", size(small))) ///
												(rcap `catt1'7 `catt1'6 `catt1'1, lpattern(solid) yaxis(1) lcolor(navy)) /// 
												(line `catt2'2 `catt2'1, yaxis(1) lcolor(maroon))  ///
												(rcap `catt2'7 `catt2'6 `catt2'1, lpattern(solid) yaxis(1) lcolor(maroon)) ///
												(line `catt3'2 `catt3'1, yaxis(1) lcolor(dkgreen))  ///
												(rcap `catt3'7 `catt3'6 `catt3'1, lpattern(solid) yaxis(1) lcolor(dkgreen)) ///
												(line `catt4'2 `catt4'1, yaxis(1) lcolor(red))  ///
												(rcap `catt4'7 `catt4'6 `catt4'1, lpattern(solid) yaxis(1) lcolor(red)) ///
												, legend(order(2 "`f`cat1''" 4 "`f`cat2''" 6 "`f`cat3''" 8 "`f`cat4''")) 
												drop `catt1'*  `catt2'* `catt3'* `catt4'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway ///
												(hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist',size(small))) ///
												(line `catt1'2 `catt1'1, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' with `level' percent CI", size(small))) ///
												(line `catt2'2 `catt2'1, yaxis(1) lcolor(maroon))  ///
												(line `catt3'2 `catt3'1, yaxis(1) lcolor(dkgreen))  ///
												(line `catt4'2 `catt4'1, yaxis(1) lcolor(red))  ///
												, legend(order(2 "`f`cat1''" 3 "`f`cat2''" 4 "`f`cat3''" 5 "`f`cat4''")) 
												drop `catt1'*  `catt2'* `catt3'* `catt4'*
												exit
										}						
								}			
						}		
						if `ncat' == 5{
								quietly{
										matrix C = r(table)'
										matrix A = r(at)
										local maxat = `points' + 1
										matrix A = A[1..`maxat',"`varlist'"]
										levelsof `cate', local(values)
										matrix input Z = (`values')
										forval cat = 1/5{
												local cat`cat' = Z[1,`cat']
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat1'.`cate'", "b".."ul"]
												if `i' == 1 matrix F = b
												else matrix F = (F \ b)	
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat2'.`cate'", "b".."ul"]
												if `i' == 1 matrix G = b
												else matrix G = (G \ b)
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat3'.`cate'", "b".."ul"]
												if `i' == 1 matrix H = b
												else matrix H = (H \ b)
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat4'.`cate'", "b".."ul"]
												if `i' == 1 matrix I = b
												else matrix I = (I \ b)
										}
										forval i = 1/`maxat' {
												local num = `i'
												matrix b = C["`i'._at#`cat5'.`cate'", "b".."ul"]
												if `i' == 1 matrix J = b
												else matrix J = (J \ b)
										}
										matrix ca1 = A,F
										matrix ca2 = A,G
										matrix ca3 = A,H
										matrix ca4 = A,I
										matrix ca5 = A,J								
										tempname catt1
										svmat ca1, name(`catt1')
										tempname catt2
										svmat ca2, name(`catt2')
										tempname catt3
										svmat ca3, name(`catt3')
										tempname catt4
										svmat ca4, name(`catt4')
										tempname catt5
										svmat ca5, name(`catt5')
										if "`confidenceno'" == "" {
												twoway ///
												(hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist',size(small))) ///
												(line `catt1'2 `catt1'1, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' with `level' percent CI", size(small))) ///
												(rcap `catt1'7 `catt1'6 `catt1'1, lpattern(solid) yaxis(1) lcolor(navy)) /// 
												(line `catt2'2 `catt2'1, yaxis(1) lcolor(maroon))  ///
												(rcap `catt2'7 `catt2'6 `catt2'1, lpattern(solid) yaxis(1) lcolor(maroon)) ///
												(line `catt3'2 `catt3'1, yaxis(1) lcolor(dkgreen))  ///
												(rcap `catt3'7 `catt3'6 `catt3'1, lpattern(solid) yaxis(1) lcolor(dkgreen)) ///
												(line `catt4'2 `catt4'1, yaxis(1) lcolor(red))  ///
												(rcap `catt4'7 `catt4'6 `catt4'1, lpattern(solid) yaxis(1) lcolor(red)) ///
												(line `catt5'2 `catt5'1, yaxis(1) lcolor(blue))  ///
												(rcap `catt5'7 `catt5'6 `catt5'1, lpattern(solid) yaxis(1) lcolor(blue)) ///
												, legend(order(2 "`f`cat1''" 4 "`f`cat2''" 6 "`f`cat3''" 8 "`f`cat4''" 10 "`f`cat5''")) 
												drop `catt1'*  `catt2'* `catt3'* `catt4'* `catt5'*
												exit
										}
										if "`confidenceno'" != "" {
												twoway ///
												(hist `varlist' if `sample' == 1, yaxis(2) `percent' `discrete' xlabel(`min'(`lab')`max') yscale(axis(2) alt) color(gs14) ytitle("`measure' `varlist'", axis(2) size(small)) xtitle(`varlist',size(small))) ///
												(line `catt1'2 `catt1'1, yaxis(1) yscale(axis(1) alt) lcolor(navy) ytitle("`estimation' with `level' percent CI", size(small))) ///
												(line `catt2'2 `catt2'1, yaxis(1) lcolor(maroon))  ///
												(line `catt3'2 `catt3'1, yaxis(1) lcolor(dkgreen))  ///
												(line `catt4'2 `catt4'1, yaxis(1) lcolor(red))  ///
												(line `catt5'2 `catt5'1, yaxis(1) lcolor(blue))  ///
												, legend(order(2 "`f`cat1''" 3 "`f`cat2''" 4 "`f`cat3''" 5 "`f`cat4''" 6 "`f`cat5''")) 
												drop `catt1'*  `catt2'* `catt3'* `catt4'* `catt5'*
												exit
										}					
								}	
						}
				}
		}
end
