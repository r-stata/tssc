*! version 2.0.0 23aug2012 Daniel Klein

pr labrecode
	vers 9.2
	
	syntax anything(id = "namelist (rule)") ///
	[if] [in] /// if and in are not documented
	[ , noVars noCHange noLabel Add SEParate(str) noDELete noStrict ]
		// nochange is not documented
	
	// initial option check
	if ("`label'" != "") & ("`add'`separate'" != "") {
		loc opt = cond("`add'" != "", "add", "separate")
		di as err "`opt' and nolabel may not be combined"
		e 198
	}
	if ("`separate'" == "") loc separate " "
	
	if ("`change'" != "") loc vars vars
	
	// separate namelist from rules
	gettoken names rules : anything ,p("(")
	if ("`names'" == "(") {
		di as err "lblnamelist required"
		e 100
	}
	if (`"`macval(rules)'"' == "") {
		di as err "rules required"
		e 100
	}

	// create namelist
	loc ok 0
	if (`: list posof "_all" in names') {
		qui la di
		loc namelist `r(names)'
		loc ok 1
	}
	else {
		if ("`strict'" == "") {
			foreach n of loc names {
				cap conf v `n'
				if !(_rc) {
					unab _vn_ : `n'
					di as err "`_vn_' is a variable name; " ///
					"specify option nostrict"
					e 198
				}
			}
		}
		cap la li `names'
		if (!_rc) {
			loc namelist `names'
			loc ok 1
		}
		else {
			if ("`strict'" == "") la li `names' // error
			m : st_local("hasd", ///
			strofreal(strpos(st_local("names"), "-")))
			if (`hasd') {
				loc names : subinstr loc names "- " "-" ,all
				loc names : subinstr loc names " - " "-" ,all
				loc names : subinstr loc names " -" "-" ,all
			}
			while (`"`names'"' != "") {
				gettoken tok names : names
				cap la li `tok'
				if !(_rc) loc namelist `namelist' `tok'
				else loc varlist `varlist' `tok'
			}
			foreach v of varlist `varlist' {
				loc namelist `namelist' `: val l `v''
			}
		}
	}
	loc namelist : list uniq namelist
	if ("`namelist'" == "") {
		di as err "no value labels found"
		e 111
	}
	if !(`ok') qui la li `namelist'
	
	// parse rules
	loc nr 0
	while (`"`macval(rules)'"' != "") {
		loc ++nr
		gettoken rule rules : rules ,m(par)
		if ("`par'" == "") {
			di as err `"`macval(rule)': parentheses required"'
			e 198
		}
		gettoken numl rest : rule ,p(=)
		cap numlist "`numl'" ,miss max(249)
		if _rc {
			di as err `"(`macval(rule)': invalid rule)"'
			e _rc
		}
		loc numl`nr' `r(numlist)'
		loc rest : subinstr loc rest "=" ""
		gettoken num2 rest : rest ,p(`" ""')
		cap numlist "`num2'" ,miss max(1)
		if _rc {
			di as err `"(`macval(rule)'): invalid rule"'
			e _rc
		}
		loc num2`nr' `r(numlist)'
		loc hasl`nr' : word count `rest'
		if (`hasl`nr'') {
			if (`hasl`nr'' > 1) {
				di as err `"(`macval(rule)'): only one label allowed"'
				e 198
			}
			cap as `num2`nr'' == int(`num2`nr'')
			if _rc | (`num2`nr'' == .) {
				di as err `"(`macval(rule)'): "' ///
				"may not label `num2`nr''"
				e 198
			}
			loc label`nr' `rest'
		}
		foreach n of loc numl`nr' {
			loc num1`nr' `num1`nr'', `n'
			loc fnum1`nr' `fnum1`nr'', float(`n')
		}
	}
	
	// put varlists in labelnames
	if (c(k)) & ("`vars'" == "") {
		foreach var of varlist * {
			loc lbl : val l `var'
			if ("`lbl'" == "") | !(`: list lbl in namelist') continue
			loc `lbl' ``lbl'' `var'
		}
	}
	
	// modify value labels and recode variables
	tempvar to
	foreach lab of loc namelist {
		loc del
		forv j = 1/`nr' {
			cap as (`num2`j'' == int(`num2`j''))
			loc lok = !(_rc) & (`num2`j'' != .)
			loc text`j'
			
			foreach val of loc numl`j' {
				loc txt : lab `lab' `val' ,strict
				if (`"`macval(txt)'"' != "") {
					if ("`delete'" == "") loc del `del' `val' ""
					if !(`lok') | ("`label'" != "") continue
					if (`"`macval(label`j')'"' == "") & !(`hasl`j'') {
						cap conf e `text`j''
						if _rc {
							m : st_local("text`j'", st_local("txt"))
						}
						else m : st_local("text`j'", ///
						st_local("text`j'") + st_local("separate") ///
						+ st_local("txt"))
					}
				}
			}
			if (`"`macval(label`j')'"' == "") & !(`hasl`j'') ///
			& ("`add'" != "") {
				loc oldlbl : lab `lab' `num2`j'' ,strict
				if ("`macval(oldlbl)'"' != "") {
					cap conf e `text`j''
					if _rc {
						m : st_local("text`j'", st_local("txt"))
					}
					else {
						m : st_local("isin", strofreal(strpos( ///
						st_local("text`j'"), st_local("oldlbl"))))
						if !(`isin') {
							m : st_local("text`j'", ///
							st_local("oldlbl") + ///
							st_local("separate") + ///
							st_local("text`j'"))
						}
					}
				}
			}
			else {
				if (`"`macval(label`j')'"' != "") loc text`j' `label`j''
				else if (`hasl`j'') loc del `del' `num2`j'' ""
			}
		}
		if ("`del'" != "") la de `lab' `del' ,modify
		forv j = 1/`nr' {
			cap conf e `text`j''
			if _rc continue
			m : st_vlmodify("`lab'", `num2`j'', st_local("text`j'"))
		}
		di as txt "(value label " as res "`lab' " as txt "modified)"
		
		if ("`vars'" != "") continue
		
		// change variables	
		marksample touse ,nov
		foreach var of loc `lab' {
			loc ty : t `var'
			cap drop `to'
			qui g `ty' `to' = `var'
			loc f = cond("`ty'" == "double", "", "f")
			forv j = 1/`nr' {
				qui replace `to' = `num2`j'' ///
				if inlist(`var'``f'num1`j'') & `touse'
			}
			di as res "`var'"
			replace `var' = `to'
		}	
	}
end
e

2.0.0	23aug2012	new program name -labrecode-
					option -nostrict- allows variables in lblnamelist
					option -nochange- now -novar- (synonym)
					fix bug, code polish
(labrec)					
1.0.4	08jun2012	fix bug, code polish
1.0.3	06jan2012	use Mata to work around left single quotes
					empty value labels may be defined by user
					namelist may contain variable names
1.0.2	04nov2011	add option -nochange-
					minor changes in the code
1.0.1	13aug2011	code completely rewritten 
					(old code available on request)
					part of -labutil2- package
1.0.0	06aug2010
