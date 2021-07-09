*! version 1.1.15 MLB 22Mar2012
* version 1.1.14 MLB 13Mar2012
* version 1.1.1 MLB 15Jul2009
* change the way the certification option works
* let the levels() be specified in seqlogit
* version 1.1.0 MLB 23Okt2008
* fix bug in weight computation (no longer ignore the levels() option)
* version 1.0.5 MLB 24Aug2008
* simplify the syntax
* version 1.0.4 MLB 19Okt2007
* add -exact- to -confirm variable- in line 176
* version 1.0.3 MLB 24Aug2007 
* decreased the fontsize of the legend
* version 1.0.1 MLB 10Aug2007
* version 1.0.0 MLB 21May2007
program define seqlogitdecomp10, rclass
	syntax ,               /// 
	overat(string)         ///
	[                      ///  
	at(string)             /// 
	SUBTitle(string asis)  ///
	EQLabel(string asis)   ///
	EQLEGEND               ///
	XLine(passthru)        ///
	YLine(passthru)        ///
	TItle(passthru)        ///
	NAme(string asis)      ///
	YSCale(passthru)       ///
	YLABel(passthru)       ///
	XSCale(passthru)       ///
	XLABel(passthru)       ///
	YSIZe(passthru)        ///
	XSIZe(passthru)        ///
	certify                /// 
	]


/* parse name */
	if "`name'" != "" {
		gettoken grname : name
		if substr("`grname'", -1,.) == "," {
			local lgrname = length("`grname'") - 1
			local grname = substr("`grname'", 1, `lgrname')
		}
		local name `"name(`name')"'
	}
	else local grname "Graph"

/* parse general */
	if "`e(cmd)'" != "seqlogit10" {
		di as err "seqlogitdecomp10 can only be used after seqlogit10"
		exit 198
	}
	if "`e(ofinterest)'" == "" {
		di as err ///
		"seqlogitdecomp10 can only be used when the ofinterest option is specified in seqlogit10"
	}

/*Parse overat & deal with default subtitles*/
	// split overat()
	local k = 0
	while `"`overat'"' != "" {
		local `k++' 
		gettoken left overat : overat, parse(",")
		local overat`k' `left'
		gettoken comma overat : overat, parse(",")
	}
	local k_overat `k'
	
	// check if # elements is even
	forvalues i = 1/`k_overat' {
		local even : word count `overat`k''
		local even = `even' / 2
		capture confirm integer number `even'
		if _rc  {
			di as err "option overat() must contain an even number of elements"
			exit 198
		}
	}
	
	// check if odd elements are variables and even elements are numbers
	forvalues i = 1/`k_overat' {
		local j = 0
		foreach l of local overat`i' {
			if mod(`++j',2) == 1 {
				capture unab var : `l'
				if _rc {
					di as err "every odd element of option overat() should be a variable"
					exit 198
				}
				capture unab var : `l', max(1)
				if _rc {
					di as err "`l' in option overat() is an ambiguous abbreviation"
					exit 111
				}
			}
			if mod(`j',2) == 0 {
				capture confirm number `l'
				if _rc {
					capture confirm scalar `l'
					if _rc {
						di as err "every even element in option overat() should be a number"
						exit 198
					}
				}		
			}
		}
	}
	
	// subtitles
	if `"`subtitle'"' == "" {
		forvalues i = 1/`k_overat' {
			local s : word 2 of `overat`i''
			local subtitle `"`subtitle' `s'"'
		}
	}

	// add interaction terms between ofinterest() and over()
	local over `e(over)'
	local ofinterest `e(ofinterest)'
	
	local posinat : list posof "`ofinterest'" in at
	if `posinat' == 0 {
		sum `ofinterest' if e(sample), meanonly
		local valinat = r(mean)
	}
	else {
		local posinat = `posinat' + 1
		local valinat : word `posinat' of `at'
	}

	forvalues i = 1/`k_overat' {
		foreach k of local over {
			if `: list posof "_`ofinterest'_X_`k'" in overat`i'' == 0 {
				local posinoverat : list posof "`k'" in overat`i'
				if `posinoverat' == 0 {
					di as err ///
					"the overat option needs to specify values for the variable(s) `over'"
					exit 198
				}
				local posinoverat = `posinoverat' + 1
				local valinoverat : word `posinoverat' of `overat`i''
				local val = `valinoverat'*`valinat'
				local overat`i' "`overat`i'' _`ofinterest'_X_`k' `val'"
			}
		}
	}
	local overat "`overat1'"
	forvalues i = 2/`k_overat' {
		local overat "`overat', `overat`i''" 
	}

/*Parse Overlodds*/	
	local overlodds "_b[`e(ofinterest)']"
	foreach k of local over {
		local overlodds "`overlodds' + _b[_`ofinterest'_X_`k']*`k'"
	}


/*Parse other options*/	
	if `"`subtitle'"' != `""' {
		local k_title : word count `subtitle'
		if `k_overat' != `k_title' {
			di as error /*
			*/ "number of subtitles should equal the number of comparisons specified in overat()"
			exit 198
		}
	}
	if `"`eqlabel'"' != `""' {
		local k_lab : word count `eqlabel'
		if `k_lab' != `e(k_eq)' {
			di as error /*
			*/ "number of labels specified in eqlabel() should equal the number of equations"
			exit 198
		}
	}
	if "`toteffect'" != "" {
		local k_toteffect : word count `toteffect'
		if `k_toteffect' != 2 {
			di as error ///
			"2 new variable names must be specified in the option toteffect()"
			exit 198
		}
		confirm new variable `toteffect'
	}

/* Get a list of all variables in model that are not specified in at() or overat()
and store their means in locals */
	local k_at : word count `at'
	local end = `k_at'-1
	tokenize `at'
	forvalues i = 1(2)`end' {
		local j = `i' + 1
		unab var : ``i''
		local at2 "`at2' `var' ``j''"
		local out "`out' `var'"
	}
	tempname b
	matrix `b' = e(b)
	local in : colnames `b'
	local in : list uniq in
	local cons "_cons"
	local in : list in - cons
	local in : list in - out
	
	local overvarst : subinstr local overat "," "", all
	local m = 1
	foreach loc of local overvarst {
		if mod(`m++',2) == 1 {
			local overvars "`overvars' `loc'"
		}
	}
	local overvars : list uniq overvars
	local in : list in - overvars
	
	foreach var of local in {
		sum `var' if e(sample), meanonly
		local m`var' = r(mean)
	}

/*Create a resultset ("dataset" containing results)*/	
	preserve
	qui {
		drop _all
		set obs `k_overat'
		
		// create variables specified in at
		tokenize `at2'
		forvalues i = 1(2)`end' {
			local j = `i' + 1
			gen ``i'' = ``j''
		}
		
		// fill in non-specified variables with their mean
		foreach var of local in {
			gen `var' = `m`var''
		}
				
		// create variables specified in overat
		foreach var of local overvars {
			gen `var' = .
		}
		forvalues i = 1/`k_overat' {
			tokenize `overat`i''
			local k : word count `overat`i''
			local end = `k' - 1
			forvalues j = 1(2)`end' {
				local l = `j' + 1
				replace ``j'' = ``l'' in `i'
			}
		}
		
		// predict weights
		forvalues i = 1/`e(k_eq)' {
			local w "`w' w`i'"
		}
		predict `w', trweight 
		
		// log odds
		forvalues i = 1/`e(k_eq)' {
			local lodds : subinstr local overlodds "_b[" "[#`i']_b[", all
			gen lodds`i' = `lodds'
		}
		
		// reshape the data
		gen group = _n
		expand 2
		gen first = _n <= `k_overat'
		
		forvalues i = 1/`e(k_eq)' {
			replace w`i' = 0 if first
		}
		
		gen zero = 0
		expand `e(k_eq)'
		bys first group : gen byte tr = _n
		forvalues i = 1/`e(k_eq)' {
			replace w`i' = 0 if tr != `i'
			replace lodds`i' = 0 if tr != `i'
			local graph "`graph' (rarea zero lodds`i' w`i')"
		}
		replace tr = -tr
		sort tr group first
		gen byby = ceil(_n/2)

		tokenize `"`subtitle'"'
		forvalues i = 1/`k_overat' {
			label define byby `i' "``i''", add
		}

		local begin = `k_overat' + 1
		local end = `e(k_eq)'*`k_overat'
		forvalues i = `begin'/`end' {
			label define byby `i' " ", add
		}
		
		label values byby byby

		if `"`eqlabel'"' == `""' {
			forvalues i = 1 / `e(Ntrans)' {
				local endeq = `e(Nchoice`i')' - 1
				forvalues j = 1/`endeq' {
					local eqlabel `"`eqlabel' "`e(tr`i'choice`j')' v `e(tr`i'choice0)'""'
				}
			}
		} 
		if "`eqlegend'" != "" {
			tokenize `"`eqlabel'"'
			forvalues i = 1/`e(k_eq)' {
				local lab `"`lab' label (`i' ``i'')"'
			}
		
			forvalues i = 1/`e(k_eq)' {
				local order "`i' `order'"
			}
			local leg `"legend( `lab' order(`order') size(small) symysize(*.75) symxsize(*.5) )"'
		}
		else {
			local legoff "off"
		}

		twoway `graph' , by(byby, col(`k_overat') compact /*
		                 */ note("") legend(pos(4) `legoff') `title' ) /*
		*/ ylabel(,nogrid) /*
		*/ `leg' /*
		*/ ytitle("log odds ratio", size(small)) /*
		*/ xtitle("weight", size(small)) `xline' `yline' /*
		*/ `name' `yscale' `ylabel' `xscale' `xlabel' `ysize' `xsize' nodraw

		local eqlabel : list clean eqlabel
		tokenize `"`eqlabel'"'

		// add titles for transitions at the right of the graph
		local i = 1
		forvalues j = `end'(`=-1*`k_overat'')`k_overat'{
			_gm_edit .`grname'.plotregion1.r1title[`j'].text = {}
			_gm_edit .`grname'.plotregion1.r1title[`j']._set_orientation rvertical
			_gm_edit .`grname'.plotregion1.r1title[`j'].style.editstyle drawbox(yes) editcopy
			gettoken left : `i', qed(quote)
			if `quote' {
				while `"``i''"' != "" {
					gettoken part `i' : `i'
					_gm_edit .`grname'.plotregion1.r1title[`j'].text.Arrpush `"`part'"'
				}
			}
			else {
				_gm_edit .`grname'.plotregion1.r1title[`j'].text.Arrpush `"``i''"'
			}
			_gm_edit .`grname'.plotregion1.r1title[`j'].as_textbox.setstyle, style(yes)
			local `i++'
		}
		graph display `grname'

		if "`certify'" != "" {
			tempname resultset
			mkmat _all, matrix(`resultset')
			return matrix resultset = `resultset'
		}
		restore
	}

 end
 