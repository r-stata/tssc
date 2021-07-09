*! version 1.1.19 MLB 14Mar2013
* version 1.1.18 MLB 19Jul2012
* version 1.1.17 MLB 01May2012
* version 1.1.16 MLB 26Apr2012
* version 1.1.15 MLB 26Mar2012
* version 1.1.14 MLB 13Mar2012
* version 1.1.1  MLB 15Jul2009
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
program define seqlogitdecomp, rclass
	version 11.0
	syntax                  ///
	[varlist(default=none)] ///
	,                       ///
	[                       ///  
	overat(string)          ///
	at(string)              ///
	noatlegend              /// 
	SUBTitle(string asis)   ///
	EQLabel(string asis)    ///
	EQLEGEND                ///
	XLine(passthru)         ///
	YLine(passthru)         ///
	TItle(passthru)         ///
	NAme(passthru)          ///
	YSCale(passthru)        ///
	YLABel(passthru)        ///
	XSCale(passthru)        ///
	XLABel(passthru)        ///
	YSIZe(passthru)         ///
	XSIZe(passthru)         ///
	xtitle(passthru)        ///
	ytitle(passthru)        ///
	TABle                   ///
	format(passthru)        ///
	z                       ///
	marg                    ///
	over(passthru)          /// 
	overmain(passthru)      ///
	nose                    ///
	area                    ///
	certify                 /// 
	]


	if "`table'`overat'`area'" == "" {
		di as err "option overat() required when options table and area are not specified"
		exit 198
	}
	if "`table'" != "" & "`area'" != "" {
		di as err "options table and area may not be combined"
		exit 198
	}
	if "`table'" == "" & "`varlist'" != "" {
		di as err "varlist may only be specified with the table option"
		exit 198
	}
	if "`table'" == "" & "`format'`z'" != "" {
		di as err "options format() and z may only be specified with the table option"
		exit 198
	}
	if "`table'" != "" & (`"`overat'`subtitle'`eqlabel'`eqlegend'`yline'`xline'`title'`name'`yscale'`ylabel'`xscale'`xlabel'`ysize'`xsize'"'    != "" ) {
		di as err "option table may not be combined with options "
		di as err "overat(), subtitle(), eqlabel(), eqlegend, xline(), yline(),"
		di as err "title(), name(), yscale(), ylabel(), xscale(), xlabel(), ysize(), xsize()"
		exit 198
	}
	if "`area'" != "" &  (`"`overat'"'   != "" | ///
	                      `"`subtitle'"' != "" | ///
						  `"`marg'"'     != ""   ///  
						  ) {
		di as err "option area may not be combined with options marg, overat() and subtitle()"
		exit 198
	}

	if "`table'" != "" {
		if "`at'" != "" {
			local atopt "at(`at')"
		}
		Seqd_table `varlist', `atopt' `marg' `noatlegend' `format' `z' `se'
		tempname at res
		matrix `at' = r(at)
		matrix `res' = r(res)
		return matrix at = `at'
		return matrix res = `res'
		exit
	}
	
	if "`area'" != "" {
		if "`at'" != "" {
			local atopt "at(`at')"
		}
		if `"`eqlabel'"' != "" {
			local eqlopt "eqlabel(`eqlabel')"
		}
		Seqd_area, `atopt' `eqlopt' `xline' `yline' `title' `name'       ///
	             `yscale' `ylabel' `xscale' `xlabel'  ///
				 `ysize' `xsize' `certify' `xtitle' `ytitle' `overmain' `over'
				 
		if "`certify'" != "" {
			tempname resultset
			matrix `resultset' = r(resultset)
			return matrix resultset = `resultset'
		}		 
		exit
	}
	
/* parse general */
	if "`e(cmd)'" != "seqlogit" {
		di as err "seqlogitdecomp can only be used after seqlogit"
		exit 198
	}
	if "`e(ofinterest)'" == "" {
		di as err ///
		"seqlogitdecomp can only be used when the ofinterest option is specified in seqlogit"
	}

	parsename , `name'
	local grname "`r(grname)'"
	
/*Parse overat & deal with default subtitles*/
	local overvarst : subinstr local overat "," "", all
	local m = 1
	foreach loc of local overvarst {
		if mod(`m++',2) == 1 {
			local overvars "`overvars' `loc'"
		}
	}
	local overvars : list uniq overvars

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
	Strip_fv `over'
	local over_str `r(varlist)'
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
		foreach k of local over_str {
			local posinoverat : list posof "`k'" in overat`i'
			if `posinoverat' == 0 {
				di as err ///
				"the overat option needs to specify values for the variable(s) `over'"
				exit 198
			}
		}
	}
	
/*Parse Overlodds*/	
	local overlodds "_b[`e(ofinterest)']"
	foreach k of local over {
		local overlodds "`overlodds' + _b[c.`ofinterest'#`k']*`k'"
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
	Strip_fv `in'
	local in `r(varlist)'
	local disc `r(disc)'
	local in : list in - out
	local in : list in - overvars
	
	
	foreach var of local in {
		sum `var' if e(sample), meanonly
		if `: list var in disc' {
			local m`var' = r(min)
		}
		else {
			local m`var' = r(mean)
		}
	}

/*Create a resultset ("dataset" containing results)*/	
	preserve
	qui {
		drop _all
		set obs `k_overat'
		tempname at_tot 
		
		// create variables specified in at
		tokenize `at2'
		forvalues i = 1(2)`end' {
			local j = `i' + 1
			gen ``i'' = ``j''
			matrix `at_tot' = nullmat(`at_tot') \ ``j''
			local rown "`rown' ``i''"
		}
		
		// fill in non-specified variables with their mean or min
		foreach var of local in {
			gen `var' = `m`var''
			matrix `at_tot' = nullmat(`at_tot') \ `m`var''
			local rown "`rown' `var'"
		}
		matrix rownames `at_tot' = `rown'
		matrix colnames `at_tot' = "value"
		if "`atlegend'" == "" {
			noi matlist `at_tot', format(%7.3g) title("At:") rowtitle("variable")
		} 

		
		// create variables specified in overat
		tempname temp overat_table
		foreach var of local overvars {
			gen `var' = .
		}
		forvalues i = 1/`k_overat' {
			tokenize `overat`i''
			local k : word count `overat`i''
			local end = `k' - 1
			capture matrix drop `temp'
			forvalues j = 1(2)`end' {
				local l = `j' + 1
				replace ``j'' = ``l'' in `i'
				matrix `temp' = nullmat(`temp') \ ``l''
			}
			matrix `overat_table' = nullmat(`overat_table'), `temp'
			local coln `"`coln' "col_`i'""'
		}
		matrix rownames `overat_table' = `overvars' 
		matrix colnames `overat_table' = `coln'
		if "`atlegend'" == "" {
			noi matlist `overat_table', format(%7.3g) title("Over:") rowtitle("variable") underscore
		} 
		
		// predict weights
		forvalues i = 1/`e(k_eq)' {
			local w "`w' w`i'"
			local v "`v' v`i'"
		}
		if "`marg'" == "" {
			predict `w', trweight 
		}
		else {
			predict `w', trmweight 
		}

		// log odds
		forvalues i = 1/`e(k_eq)' {
			local lodds : subinstr local overlodds "_b[" "[#`i']_b[", all
			gen lodds`i' = `lodds'
		}
		if "`marg'" != "" {
			predict `v', trvar
			forvalues i = 1/`e(k_eq)' {
				replace lodds`i' = lodds`i'*v`i' 
			}
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
			local leg `"legend( `lab' order(`order') size(small) symysize(*.75) symxsize(*.5)  cols(1) pos(4))"'
		}
		else {
			local legoff "off"
		}
		if "`marg'" == "" {
			local ytitle `"ytitle("log odds ratio", size(small))"'
		}
		else {
			local ytitle `"ytitle("marginal effect", size(small))"'
		}
		
		twoway `graph' , by(byby, col(`k_overat') compact /*
		                 */ note("") legend(pos(4) `legoff') `title' ) /*
		*/ ylabel(,nogrid) /*
		*/ `leg' /*
		*/ `ytitle' /*
		*/ xtitle("weight", size(small)) `xline' `yline' /*
		*/ `name' `yscale' `ylabel' `xscale' `xlabel' `ysize' `xsize' `ytitle' `xtitle' nodraw

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
		
		return matrix at   = `at_tot'
		return matrix over = `overat_table'
		
		if "`certify'" != "" {
			tempname resultset
			mkmat _all, matrix(`resultset')
			return matrix resultset = `resultset'
		}
		restore
	}

 end
 
 program define Strip_fv, rclass 
	syntax varlist(fv)
	
	fvexpand `varlist' if e(sample)
	local varlist `r(varlist)'
	tokenize `varlist'
	local k : word count `varlist'

	forvalues i = 1/`k' {
		if !strmatch("``i''","*#*") {
			Strip_fv_dot ``i''
			local varl "`varl' `r(varlist)'"
			local disc "`disc' `r(disc)'"
		}
		else {
			while "``i''" != "" {
				gettoken left `i' : `i', parse("#")
				Strip_fv_dot `left'
				local varl "`varl' `r(varlist)'"
				local disc "`disc' `r(disc)'"
				gettoken dash `i' : `i', parse("#")
				if 	substr("``i''",1,1) == "#" {
					gettoken dash `i' : `i', parse("#")
				}
			}
		}
	}
	local varl : list uniq varl
	local varl : list retokenize varl
	local disc : list uniq disc
	local disc : list retokenize disc
	return local varlist "`varl'"
	return local disc "`disc'"
end

program define Strip_fv_dot, rclass
	syntax varname(fv)
	
	gettoken a b : varlist, parse(".")
	if "`a'" == "`varlist'" {
		local varl "`a'"
	}
	else {
		gettoken dot b : b, parse(".")
		local varl "`b'"
		if !strpos("`a'","c") {
			local disc "`b'" 
		}
	}
	return local varlist "`varl'"
	return local disc "`disc'"
 end
 
 program define Seqd_table, rclass
	syntax [varlist(default=none)] , ///
	[                                ///
	at(string)                       ///
	marg                             ///
	noatlegend                       ///
	format(string)                   /// 
	z                                ///
	nose                             ///
	]
	
	if "`varlist'" == "" {
		local varlist "*"
	}
	
	if "`marg'" != "" {
		local m "m"
	}
	
	if "`format'" != "" {
		capture display `format' 1
		if _rc {
			di as err "invalid %format specified in option format()"
			exit 120
		}
	}
	else {
		local format "%7.3g"
	}
	
	local trnames : coleq e(b)
	local trnames : list uniq trnames

	
// Add the default at to all variables not specified in at() option
// min for categorical factor variables
// mean for all other variables
	tempname at_tot
	local k_at : word count `at'
	local end = `k_at'-1
	tokenize `at'
	forvalues i = 1(2)`end' {
		local j = `i' + 1
		unab var : ``i'', max(1)
		local out "`out' `var'"
		local at2 "`at2' `var' ``j''"
		matrix `at_tot' = nullmat(`at_tot') \ ``j''
	}
	local at `at2'
	
	tempname b
	matrix `b' = e(b)
	local in : colnames `b'
	local in : list uniq in
	local cons "_cons"
	local in : list in - cons
	Strip_fv `in'
	local in `r(varlist)'
	local disc `r(disc)'
	local in : list in - out
	
	foreach var of local in {
		sum `var' if e(sample), meanonly
		if `: list var in disc' {
			local at `at' `var' `r(min)'
			matrix `at_tot' = nullmat(`at_tot') \ `r(min)'
		}
		else {
			local at `at' `var' `r(mean)'
			matrix `at_tot' = nullmat(`at_tot') \ `r(mean)'
		}
	}
	matrix rownames `at_tot' = `out' `in'
	matrix colname  `at_tot' = "value"
	if "`atlegend'" == "" {
		noi matlist `at_tot', format(%7.3g) title("At:") rowtitle("variable")
	} 
	
	// prepare at for use with -margins-
	tokenize `at'
	local k_at : word count `at'
	forvalues i = 1(2)`k_at' {
		local j = `i' + 1
		local at_opt "`at_opt' ``i''=``j''"
	}
	local at_opt "at(`at_opt')"
	
	// total effect
	qui margins if e(sample), dydx(`varlist') `at_opt' `se'
	tempname tot temp
	Bse , mat(`tot') `z' `se'
	local k_vars = rowsof(`tot')
	forvalues i = 1/`k_vars' {
		local roweqn "`roweqn' tot"
	}
	local trn : word 1 of `trnames'
	matrix coleq `tot' = `trn' `=cond("`se'"!= "", "", "`trn'")'
	matrix roweq `tot' = `roweqn'
	
	forvalues i = 2/`e(eqs)' {
		matrix `temp' = J(`k_vars',`=cond("`se'" != "", 1, 2)', .z)
		local trn : word `i' of `trnames'
		matrix coleq `temp' = `trn':b `=cond("`se'"!="", "", `"`trn':`=cond("`z'" != "", "se", "z")'"')'
		matrix roweq `temp' = `roweqn'
		matrix `tot' = `tot', `temp'
	}
	
	// weights
	tempname w temp2 temp3 temp4 temp5
	local k = 1
	forvalues i = 1/`e(Ntrans)'{
		forvalues j = 1/ `=`e(Nchoice`i')'-1' {
			qui margins if e(sample), predict(tr`m'w transition(`i') choice(`j')) `at_opt' `se'
			Bse, mat(`temp') `z' `se'
			qui margins if e(sample), predict(tra transition(`i') ) `at_opt' `se'
			Bse, mat(`temp2') `z' `se'
			if "`m'" == "" {
				qui margins if e(sample), predict(trv transition(`i') choice(`j')) `at_opt' `se'
				Bse, mat(`temp3') `z' `se'
			}
			qui margins if e(sample), predict(trg transition(`i') choice(`j'))  `at_opt' `se'
			Bse, mat(`temp4') `z' `se'
			qui margins if e(sample), predict(trpr transition(`i') choice(`j'))  `at_opt' `se'
			Bse, mat(`temp5') `z' `se'
			if "`m'" == "" {
				matrix `temp' = `temp' \ `temp2' \ `temp3' \ `temp4' \ `temp5'
			}
			else {
				matrix `temp' = `temp' \ `temp2' \ `temp4' \ `temp5'
			}
			local trn : word `k++' of `trnames'
			matrix coleq `temp' = `trn' `=cond("`se'"!="", "", "`trn'")'
			if "`m'" == "" {
				matrix roweq `temp'=weight:weight weight:at_risk weight:variance weight:gain pr(pass):pr
			}
			else {
				matrix roweq `temp'=weight:weight weight:at_risk weight:gain pr(pass):pr
			}
			matrix `w' = nullmat(`w'), `temp'
		}
	}
	tempname res 
	matrix `res' = `w' \ `tot'
	
	// effects on each transition
	tempname tr
	local k = 1
	forvalues i = 1/`e(Ntrans)'{
		forvalues j = 1/ `=`e(Nchoice`i')'-1' {
			if "`m'" == "" {
				qui margins if e(sample), dydx(`varlist') `at_opt' predict(xb eq(#`k')) force `se'
			}
			else {
				qui margins if e(sample), dydx(`varlist') `at_opt' predict(trpr transition(`i') choice(`j')) force `se'
			}
			Bse, mat(`temp') `z' `se'
			local roweqn ""
			forvalues j = 1/`k_vars' {
				local roweqn "`roweqn' trans"
			}
			local trn : word `k' of `trnames'
			matrix coleq `temp' = `trn' `=cond("`se'" != "", "", "`trn'")'
			matrix roweq `temp' = `roweqn'
			matrix `tr' = nullmat(`tr'), `temp'
			local k = `k' + 1
		}
	}
	matrix `res' = `tr' \ `res'
	if "`atlegend'" == "" {
		local ti "title(Decomposition:)"
	} 
	matlist `res', format(`format') nodotz showcoleq(lcombined) underscore colorcoleq(res) `ti'
	return matrix res = `res'
	return matrix at  = `at_tot'
end

program define Bse
	syntax, mat(name) [z nose]
	if "`se'" != "" {
		matrix `mat' = r(b)'
		matrix colnames `mat' = "b"
	}
	else {
		
		if c(stata_version) >= 12 {
			matrix `mat' = r(table)
			local k_vars = colsof(`mat')
			matrix `mat' = `mat'[1..2, 1..`k_vars']'
		}
		else {
			tempname b V se
			matrix `b' = r(b)
			matrix `V' = r(V)
			
			local k_vars= colsof(`b')
			matrix `se' = J(`k_vars',1,.)
			forvalues i = 1/`k_vars' {
				matrix `se'[`i',1] = cond(`V'[`i',`i']==0, . ,sqrt(`V'[`i',`i']))
			}
			matrix `mat' = `b'', `se'
		}
		if "`z'" != "" {
			local rown: rownames `mat'
			mata: Makez("`mat'")
			matrix colnames `mat' = "b" "z"
			matrix rownames `mat' = `rown'
		}
		else {
			matrix colnames `mat' = "b" "se"
		}
	}
end

program define Seqd_area, rclass
	syntax  , ///
	[                                ///
	at(string)                       ///
	noatlegend                       ///
	over(varlist max=1)              /// 
	EQLabel(string asis)             ///
	XLine(passthru)                  ///
	YLine(passthru)                  ///
	TItle(passthru)                  ///
	NAme(passthru)                ///
	YSCale(passthru)                 ///
	YLABel(passthru)                 ///
	XSCale(passthru)                 ///
	XLABel(passthru)                 ///
	YSIZe(passthru)                  ///
	XSIZe(passthru)                  ///
	xtitle(passthru)                 ///
	ytitle(passthru)                 ///
	certify                          ///  
	overmain(varlist)                ///
	]
	
	local gropts `xline' `yline' `title' `name'       ///
	             `yscale' `ylabel' `xscale' `xlabel'  ///
				 `ysize' `xsize' `xtitle' `ytitle'
	
	if `"`eqlabel'"' == "" {
		local eqlabel : coleq e(b), quoted
		local eqlabel : list uniq eqlabel
	}
	
// Add the default at to all variables not specified in at() option
// min for categorical factor variables
// mean for all other variables
	preserve
	
	tempname at_tot
	local k_at : word count `at'
	local end = `k_at'-1
	tokenize `at'
	forvalues i = 1(2)`end' {
		local j = `i' + 1
		unab var : ``i'', max(1)
		local out "`out' `var'"
		local at2 "`at2' `var' ``j''"
		matrix `at_tot' = nullmat(`at_tot') \ ``j''
		
		qui replace `var' = ``j''
	}
	local at `at2'

	if "`over'" != "" & "`at'" != "" {
		if `: list over in at' {
			di as err "a variable specified in over() may not be specified in at()"
			exit 198
		}
	}
	
	tempname b
	matrix `b' = e(b)
	local in : colnames `b'
	local in : list uniq in
	local cons "_cons"
	local in : list in - cons
	Strip_fv `in'
	local in `r(varlist)'
	local disc `r(disc)'
	keep `in'
	local in : list in - out
	
	if "`over'" == "" {
		local over2 "`e(over)'"
		Strip_fv `over2'
		local over2 `r(varlist)'
		
		if `: word count `over2'' == 1  {
			local over `over2'
		}
		else {
			di as err "the over() option needs to be specified in combination with the area option"
			di as err "if the seqlogit command did not use the over() option or"
			di as err "more than one variable was specified in the over() option"
			exit 198
		}
	}
	
	local in : list in - over
	if "`overmain'" != "" {
		local in : list in - overmain
	}
	
	foreach var of local in {
		sum `var' if e(sample), meanonly
		if `: list var in disc' {
			local at `at' `var' `r(min)'
			matrix `at_tot' = nullmat(`at_tot') \ `r(min)'
			
			qui replace `var' = `r(min)'
		}
		else {
			local at `at' `var' `r(mean)'
			matrix `at_tot' = nullmat(`at_tot') \ `r(mean)'
			
			qui replace `var' = `r(mean)'
		}
	}
	
	qui bys `over' : keep if _n == 1
	
	matrix rownames `at_tot' = `out' `in'
	matrix colname  `at_tot' = "value"
	if "`atlegend'" == "" {
		noi matlist `at_tot', format(%7.3g) title("At:") rowtitle("variable")
	} 
	
	local eqs `e(eqs)'
	forvalues i = 1/`eqs' {
		tempvar treff`i'
		local pred "`pred' `treff`i''"
	}
	predict `pred', treff
	
	tempvar eff 
	predict `eff', eff
	local gr "twoway"
	
	tempvar c0 cm0
	qui gen byte `c0'  = 0
	qui gen byte `cm0' = 0
	local k = 1
	forvalues i = 1/`eqs' {
		local pass = 0
		tempvar c`i'  cm`i'
		local j = `i' - 1
		gen `c`i''  = `c`j''  + cond(`treff`i''>0, `treff`i'', 0)
		gen `cm`i'' = `cm`j'' + cond(`treff`i''<0, `treff`i'', 0)
		capture assert `treff`i'' <	 0
		if _rc {
			local gr "`gr' rarea  `c`j''  `c`i'' `over', pstyle(p`i'area) ||"
		}
		capture assert `treff`i'' > 0 
		if _rc {
			local gr "`gr' rarea `cm`j'' `cm`i'' `over', pstyle(p`i'area) ||"
		}
	}
	local gr `"`gr' line `eff' `over', lpatter(solid) lwidth(thick)"'
	
	local order `"`=`e(eqs)'+1' "total effect""'
	foreach i of numlist `e(eqs)'(-1)1 {
		local order `"`order' `i' "'
		local lab `"`lab' lab(`i' `: word `i' of `eqlabel'')"'
	}
	
	
	`gr'  plotregion(margin(zero)) ytitle("effect of `e(ofinterest)'") `gropts' ///
	      legend(order(`order') `lab' size(small) symysize(*.75) symxsize(*.5) cols(1) pos(4))
	
	if "`certify'" != "" {
		tempname resultset
		mkmat _all, matrix(`resultset')
		return matrix resultset = `resultset'
	}
	restore
end

program define parsename, rclass
	syntax , [ name(string) ]
	if "`name'" != "" {
		gettoken name : name, parse(",")
	}
	else {
		local name "Graph"
	}
	return local grname "`name'"
end

mata 
void Makez(string scalar matname) {
	mat = st_matrix(matname)
	mat[.,2] = mat[.,1]:/mat[.,2]
	st_matrix(matname,mat)
}
end
