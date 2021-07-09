*! 1.1.1 NJC 27 April 2016
* 1.1.0 NJC 13 April 2016
* 1.0.4 NJC 1 Nov 2007 
* 1.0.3 NJC 30 Oct 2007 
* 1.0.2 NJC 25 Oct 2007 
* 1.0.1 NJC 19 Oct 2007
* 1.0.0 NJC 17 Oct 2007
program spineplot, rclass 
	version 8.2 
	// -levels- or -levelsof- must be present 
	if _caller() >= 9 local of "of" 

	forval i = 1/20 {
		local baropts `baropts' bar`i'(str asis)
	}
	syntax varlist(min=2 max=2 numeric) [fweight aweight/] [if] [in] ///
	[, MISSing PERCent `baropts' text(str asis) barall(str asis) * ]

	quietly {
		if "`missing'" != "" marksample touse, novarlist zeroweight
		else marksample touse, zeroweight
		count if `touse'
		if r(N) == 0 error 2000

		if `"`text'"' != "" { 
			gettoken textvar text : text, parse(",") 
			capture confirm variable `textvar' 
			if _rc { 
				di as err "`textvar' not a variable"
				exit 198 
			} 
			gettoken comma text : text, parse(",") 
		} 

		tokenize "`varlist'"
		args y x
		preserve
		tempvar f xf xF xmid tag yF ymid xshow

		keep if `touse'
		if "`exp'" == "" local exp = 1 
		bysort `x' `y': gen double `f' = sum(`exp') 
		by `x' `y': keep if _n == _N
		fillin `x' `y'
		replace `f' = 0 if `f' == .
		drop _fillin
		compress `f'

		if "`percent'" != "" {
			local factor 100
			local la 0 25 50 75 100
			local what "percent"
		}
		else {
			local factor 1
			local la 0 .25 .5 .75 1
			local what "fraction"
		}

		bysort `x' (`y'): gen `xf' = sum(`f')
		by `x' : replace `xf' = `xf'[_N]

		by `x' : gen byte `tag' = _n == 1
		gen `xF' = sum(`xf' * `tag')
		local total = `xF'[_N]
		replace `xF' = (`factor' * `xF') / `total' 
		replace `xf' = (`factor' * `xf') / `total' 
		by `x': gen `xmid' = `xF'[_N] - 0.5 * `xf'[_N]

		by `x' : gen `yF' = sum(`f')
		by `x' : gen `ymid' = `yF' - 0.5 * `f'
		by `x' : replace `ymid' = `factor' * `ymid'/ `yF'[_N]
		by `x' : replace `yF' = `factor' * `yF'/ `yF'[_N]

		local first = _N + 1
		expand 2 if `x' == `x'[_N]
		replace `yF' = . in `first'/l
		sort `y' `x' `yF'
		by `y' : gen `xshow' = cond(_n == 1, 0, `xF'[_n - 1])

		local xtitle : var label `x'
		if `"`xtitle'"' == "" local xtitle `x'
		local ytitle : var label `y'
		if `"`ytitle'"' == "" local ytitle `y'

		// returned label specification uses 4 d.p. only 
		// to simplify macro contents 
		levels`of' `x', local(levels)
		foreach l of local levels {
			su `xmid' if `x' == `l', meanonly
			local l : label (`x') `l'
			local min : di %5.4f r(min) 
			local toreturn `" `toreturn' `min' "`l'" "'  
			local XLA `" `XLA' `r(min)' "`l'" "'
		}

		return local catlabels `toreturn' 
		drop `f' `xf' `xF' `tag'

		levels`of' `y', local(levels)
		local ny : word count `levels'
		tokenize `levels'
		forval i = `ny'(-1)1 {
			local pipe = cond(`i' > 1, "||", "")
			local I = `ny' - `i' + 1

			local call `call' ///
			bar `yF' `xshow' if `y' == ``i'' ///
			, bartype(spanning) blcolor(bg) blw(medium) ///
			`barall' `bar`I'' `pipe'

			local which : label (`y') ``i''
			local lgnd `lgnd' `I' `"`which'"'
		}

		if `"`textvar'"' != "" { 
			local texttoplot mla(`textvar') mlabpos(0) 
		}
	}

	twoway `call'                                    ///
	xaxis(1 2)                                       ///
	xsc(r(0, `factor') axis(1))                      ///
	xsc(r(0, `factor') axis(2))                      ///
	xla(`XLA', axis(2) noticks)                      ///
	xla(`xla', axis(1))                              ///
	yaxis(1 2)                                       ///
	ysc(r(0, `factor'))                              /// 
	yla(`la', ang(h) nogrid axis(2))                 ///
	yla(none, ang(h) nogrid axis(1))                 ///
	xtitle(`"`xtitle'"', axis(2))                    ///
	xtitle(`"`what' by `xtitle'"', axis(1))          /// 
        ytitle(`"`what' by `ytitle'"', axis(2))          /// 
        ytitle("", axis(1))                              /// 
	legend(order(`lgnd') col(1) pos(3))              ///
	`options'                                        ///
	|| scatter `ymid' `xmid' if !missing(`textvar'), ///
	ms(none)                                         /// 
	`texttoplot' `text'  
end

