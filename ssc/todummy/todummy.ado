*! version 1.2.2 23aug2012 Daniel Klein

pr todummy ,sclass
	vers 9.2
	
	syntax varlist(num) [if][in] ///
	[ , Values(str) Percentile Cut Levels MEDian q ///
	STUB(namelist) Generate(namelist) PREfix(name) SUFFix(str) ///
	REPLACE noNAMes ///
	Label(str asis) RLabel(str asis) noVARLabel ///
	Missing noSKip NOSKip(str) RO(str) ///
	noEXClude  ///
	LEQ * ] // undocumented syntax from todummy1 
	
	// mark sample
	marksample touse ,nov
	qui cou if `touse'
	if !(r(N)) err 2000
	
	// get undocumented options (old syntax)
	if ("`options'" != "") {
		_oldsyntax ,`options'
		if ("`s(_td_vk)'" == "k") loc levels levels
		else {
			loc values `s(_td_vk)'
			loc `s(_td_opt)' `s(_td_opt)'
		}
		sret loc _td_vk
		sret loc _td_opt
	}
	if ("`leq'" != "") {
		if ("`options'" == "") {
			di as txt "(note: you are using old {cmd:todummy} " ///
			"syntax; see {help todummy} for new syntax)" 
		}
		if ("`ro'" != "") {
			if ("`ro'" != "<=") {
				di as err "option ro not allowed with leq"
				e 198
			}
		}
		else loc ro <=
	}
	
	// check options
	
		// values or keyword specified
	loc k = ("`levels'`median'`q'" != "")
	if ("`values'" == "") {
		if !(`k') {
			di as err "one of values or {it:keyword} must be specified"
			e 198
		}
		foreach opt in percentile cut {
			if ("``opt''" != "") {
				di as err "option `opt' only allowed with values"
				e 198
			}
		}
	}
	if ("`values'" != "") & (`k') {
		di as err "only one of values or {it:keyword} may be specified"
		e 198
	}
	if ("`percentile'" != "") & ("`cut'" != "") {
		di as err "only one of percentile or cut may be specified"
		e 198
	}
	if ("`median'" != "") & ("`q'" != "") {
		di as err "only one of median or q may be specified"
		e 198
	}
	
		// name options
	if ("`replace'" != "") {
		foreach opt in generate prefix suffix stub levels {
			if ("``opt''" != "") {
				di as err "option replace not allowed with `opt'"
				e 198
			}
		}
	}
	if ("`stub'" != "") {
		loc stubdup : list dups stub
		if ("`stubdup'" != "") {
			di as err "`: word 1 of `stubdup'' " ///
			"menitioned more than once"
			e 198
		}
		if ("`generate'" != "") {
			di as err "option stub not allowed with generate"
			e 198
		}
		if ("`names'" != "") {
			di as err "option stub not allowed with nonames"
			e 198
		}
	}
	if ("`generate'" != "") {
		loc gendup : list dups generate
		if ("`gendup'" != "") {
			di as err "`: word 1 of `gendup'' mentioned more than once"
			e 198
		}
	}
	if ("`names'" != "") & ("`levels'" == "") {
		di as err "option nonames only allowed with levels"
		e 198
	}
	
		// label options
	if (`"`macval(rlabel)'"' != "") {
		if (`"`macval(label)'"' != "") {
			di as err "option label not allowed with rlabel"
			e 198
		}	
		loc label `"`macval(rlabel)'"'
		loc oi i
	}
	if ("`varlabel'" != "") {
		if (`"`macval(label)'"' != "") {
			di as err "option novarlabel not allowed with [r]label"
			e 198
		}
	}	
		
		// advanced options
	if ("`noskip'" != "") {
		if ("`noskip'" != "drop") & ("`noskip'" != "replace") {
			di as err "invalid option noskip"
			e 198
		}
		if ("`skip'" != "") {
			di as err " noskip not allowed with noskip(`noskip')"
			e 198
		}
		loc skip drop
	}
	if ("`ro'" != "") {
		if ("`levels'" != "") | ///
		(("`percentile'`cut'`median'`q'" == "")) {
			di as err "option ro not allowed"
			e 198
		}
		if !inlist("`ro'", ">", "<", ">=", "<=", "==", "!=", "~=") {
			di as err "invalid option ro"
			e 198
		}
	}
	if ("`exclude'" != "") & ///
	("`percentile'`median'`q'`levels'" == "") {
		di as err "option noexclude only allowed " ///
		"with percentile or levels"
		e 198
	}
	
	// check/set default
	if ("`values'" != "") & ("`percentile'`cut'" == "") {
		loc default 1
	}
	else loc default 0
	
	// get values
	
		// settings
	if ("`median'" != "") | ("`q'" != "") {
		if ("`median'" != "") loc vlst1 50
		else loc vlst1 25 50 75
		loc nvlst 1
		loc eq1 0
		loc percentile percentile
		loc hasmiss1 0
	}
	if ("`values'" != "") {
		if ("`percentile'" != "") {
			loc opt r(>0 <100)
		}
		else {
			if (`default') {
				loc opt max(249)
				loc sep ,
			}
			else loc sep
			loc opt `opt' miss
		}
		
			// parse vlists
		loc i 0
		while ("`values'" != "") {
			loc ++i
			loc values : subinstr loc values "q" " 25 50 75 " ,all
			gettoken vlst values : values ,p(\)
			gettoken b values : values ,p(\)
			gettoken eq vlst : vlst ,p(=)
			if ("`eq'" != "=") {
				loc vlst `eq' 
				loc eq`i' 0
			}
			else loc eq`i' 1
			numlist "`vlst'" ,asc `opt' 
			loc vlst`i' `r(numlist)'
			loc hasmiss`i' 0
			if ("`percentile'" == "") {
				loc tmp
				loc ftmp
				foreach v of loc vlst`i' {
					if !(`hasmiss`i'') loc hasmiss`i' = mi(`v')
					loc tmp `tmp'`sep' `v'
					loc ftmp `ftmp'`sep' float(`v')
				}
				loc vlst`i' `tmp'
				loc fvlst`i' `ftmp'
			}
		}
		loc nvlst `i'
	}
	
	// final checks and settings
	
		// names
	loc nvars : word count `varlist'
	if ("`stub'" != "") {
		if (`: word count `stub'' != `nvars') {
			di as err "option stub: number of stubs does not " ///
			"match number of variables"
			e 198
		}
		loc cmd g byte
	}
	else {
		loc ndum 0 // overall dummies to be created
		if ("`levels'" != "") {
			foreach var of loc varlist {
				qui ta `var' `tou' ,`missing'
				loc ndum = `ndum' + r(r)
			}
		}
		else if ("`levels'" == "" ) {
			if (`default') loc ndum `nvlst'
			else {
				forval j = 1/`nvlst' {
					loc nvals : word count `vlst`j''
					loc pm 0
					if (`nvals' > 1) {
						loc pm = cond(`eq`j'', (-1), 1)
					}
					loc ndum = `ndum' + `nvals' + `pm'
				}
			}
		}
		loc mdum = cond(`ndum' > `nvars', 1, 0)
		if ("`replace'" != "") {
			if (`mdum') {
				di as err "option replace not allowed"
				e 198
			}
			loc cmd replace
		}
		else if ("`replace'" == "") {
			loc ngen : word count `generate'
			if !(`ngen') {
				if ("`prefix'`suffix'`levels'" == "") & !(`mdum') {
					di as txt "(note: default prefix {hi:d_} set)"
					loc prefix d_
				}
			}
			else if (`ngen') {
				if (`ngen' != `ndum') {
					di as err "option generate: number of names " ///
					"does not match number of dummies to be created"
					e 198
				}
				foreach g of loc generate {
					conf new v `prefix'`g'`suffix'
				}
			}
			loc cmd g byte
		}
	}
	
		// advanced options
	if ("`oi'" == "") loc oi o
	if ("`ro'" == "") loc ro >=
	if ("`exclude'" == "") loc tou "if `touse'"
	else loc tou

		// counters
	loc c 0 // count variables in varlist
	loc o 0 // count created dummies (overall)
	
	// temporary variable
	tempvar cpyvar
	
	// create dummies from variables
	foreach var of loc varlist {
		if ("`levels'" == "") {
			cap drop `cpyvar'
			qui g `: t `var'' `cpyvar' = `var'
		}
		
		loc ++c
		loc f = cond("`: t `var''" == "double", "", "f")
		
			// default (one)
		if (`default') {
			loc i 0 // count dummies per variable
			
			forval j = 1/`nvlst' { 
				loc ++i
				loc ++o
				loc notmiss = cond(`hasmiss`j'', "", "& !mi(`var')")
				
					// get/check name
				if ("`replace'" != "") loc nam `var'
				else {
					_gcnam `var' ,c(`c') i(`i') o(`o') ///
					mdum(`mdum') skip(`skip') stub(`stub') ///
					generate(`generate') prefix(`prefix') ///
					suffix(`suffix')
				
					`s(_td_con)'
					loc nam `s(_td_nam)'
				}
				
					// create dummy
				qui `cmd' `nam' = inlist(`var'``f'vlst`j'') ///
				if `touse' `notmiss'
				if ("`cmd'" == "replace") qui compress `nam'
				
					// copy missing values
				if (`hasmiss`j'') {
					if ("`missing'" != "") {
						qui replace `nam' = `cpyvar' ///
						if !(`nam') & mi(`cpyvar')
					}
				}
				else {
					if ("`missing'" != "") {
						qui replace `nam' = `cpyvar' ///
						if mi(`cpyvar') & `touse'
					}
				}
				
					// label
				if ("`varlabel'" == "") & (`"`macval(label)'"' != "") {
					_labd `nam' ,l(`"`macval(label)'"') oi(``oi'') 
				}
			}
			continue
		}
		
		// not default
		if !(`default') {
			
			// levels
			if ("`levels'" != "") {
				loc i 0 // count dummies per variable
				qui levelsof `var' `tou' ,`missing' l(lvls)
				foreach l of loc lvls {
					
					loc ++i 
					loc ++o
					loc labok 1
					
						// get/check name
					if ("`names'" != "") loc nam `var'`i'
					else {
						if ("`stub'" != "") {
							loc nam `: word `c' of `stub''`i'
						}
						else {
							loc nam : word `o' of `generate'
						}
						if ("`nam'" == "") {
							loc nam : lab (`var') `l' ,strict
							if (`"`macval(nam)'"' != "") {
								loc nam : subinstr loc nam "`" "_" ,all
								loc nam : subinstr loc nam " " "_" ,all
								cap conf name `nam'
								if _rc {
									if (c(stata_version) < 11) {
										loc nam `var'`i'
									}
									else {
										loc nam = ///
										strtoname(`"`macval(nam)'"')
									}
									
								}
								if (`"`macval(label)'"' == "") loc labok 0
							}
							else loc nam `var'`i'
						}
					}
					loc nam `prefix'`nam'`suffix'
					cap conf new v `nam'
					if _rc {
						if (_rc != 110) {
							if (`: length loc nam' > 32) {
								loc newnam : permname `nam'
								di as txt "(note: " as res "`nam' " ///
								as txt "invalid name; creating " ///
								as res "`newnam' " as txt "instead)"
								loc nam `newnam'
							}
							else {
								di as txt "(note: " as res "`nam' " ///
								as txt "invalid name)"
								continue
							}
						}
						else {
							if ("`skip'" != "") {
								if ("`skip'" == "drop") qui drop `nam'
								else {
									loc newnam : permname `nam'
									di as txt "(note: " as res ///
									"`nam' " as txt "already " ///
									"exists; creating " as res ///
									"`newnam' " as txt "instead)"	
									loc nam `newnam'
								}
							}
							else {
								di as txt "(note: " as res "`nam' " ///
								as txt "already exists)"
								continue
							}
						}
					}
					
						// create dummy
					if ("`f'" == "f") {
						qui g byte  `nam' = `var' == float(`l') ///
						if `touse'
					}
					else qui g byte `nam' = `var' == `l' if `touse'
					
						// copy missing values
					if ("`missing'" == "") {
						qui replace `nam' = `var' ///
						if mi(`var') & `touse'
					}
					
						// label
					if (`"`macval(varlabel)'"' == "") & (`labok') {
						loc def : lab (`var') `l' ,strict
						if (`"`macval(def)'"' == "") {
							loc def "`var' (`= round(`l', .01)')"
						}
						_labd `nam' ,l(`"`macval(label)'"') ///
						oi(``oi'') def(`def')
					}
				}
				continue
			}
			
			// percentile and cut
			loc i 0 //count dummies per variable
			
			forval j = 1/`nvlst' {
				
				loc notmiss = cond(`hasmiss`j'', "", "& !mi(`var')")
				
					// parse values percentiles or cutpoints
				loc n : word count `vlst`j''
				if ("`percentile'" != "") {
					_pctile `var' `tou' ,p(`vlst`j'')
				}
				
				forval k = 1/`n' {
					if ("`percentile'" != "") loc val`k' `r(r`k')'
					else loc val`k' : word `k' of ``f'vlst`j''
				}
				
					// only one value in numlist
				if (`n' == 1) {
					loc ++i
					loc ++o
				
						// get/check name
					if ("`replace'" != "") loc nam `var'
					else {
						_gcnam `var' ,c(`c') i(`i') o(`o') ///
						mdum(`mdum') skip(`skip') stub(`stub') ///
						generate(`generate') prefix(`prefix') ///
						suffix(`suffix')
				
						`s(_td_con)'
						loc nam `s(_td_nam)'
					}
					
						// create dummy
					qui `cmd' `nam' = `var' `ro' `val1' ///
					if `touse' `notmiss'
					if ("`cmd'" == "replace") qui compress `nam'
					
						// copy missing values
					if (`hasmiss`j'') {
						if ("`missing'" != "") {
							qui replace `nam' = `cpyvar' ///
							if !(`nam') & mi(`cpyvar')
						}
					}
					else {
						if ("`missing'" != "") {
							qui replace `nam' = `cpyvar' ///
							if mi(`cpyvar') & `touse'
						}
					}
					
						// label
					if ("`varlabel'" == "") & ("`median'" == "") {
						loc def "`var' (`ro' `=round(`val1', .01)')"
						_labd `nam' ,l(`"`macval(label)'"') ///
						oi(``oi'') def(`def')
					}
					continue
				}
	
					// more than on value in numlist
				if !(`eq`j'') {
				
					loc ++i
					loc ++o
				
						// get/check name
					if ("`replace'" != "") loc nam `var'
					else {
						_gcnam `var' ,c(`c') i(`i') o(`o') ///
						mdum(`mdum') skip(`skip') stub(`stub') ///
						generate(`generate') prefix(`prefix') ///
						suffix(`suffix')
				
						loc nam `s(_td_nam)'
					}
				
					if ("`s(_td_con)'" == "") {
				
							// create first dummy if needed
						qui g byte `nam' = `var' <= `val1' ///
						if `touse' `notmiss'
				
							// copy missing values
						if (`hasmiss`j'') {
							if ("`missing'" != "") {
								qui replace `nam' = `cpyvar' ///
								if !(`nam') & mi(`cpyvar')
							}
						}
						else {
							if ("`missing'" != "") {
								qui replace `nam' = `cpyvar' ///
								if mi(`cpyvar') & `touse'
							}
						}
						
							// label
						if ("`varlabel'" == "") {
							loc def "`var' (<= `= round(`val1', .01)')"
							_labd `nam' ,l(`"`macval(label)'"') ///
							oi(``oi'') def(`def')
						}
					}
				}
				
					// create more dummies
				forval k = 2/`n' {
					
					loc ++i
					loc ++o
								
						// get/check name
					if ("`replace'" != "") loc nam `var'
					else {
						_gcnam `var' ,c(`c') i(`i') o(`o') ///
						mdum(`mdum') skip(`skip') stub(`stub') ///
						generate(`generate') prefix(`prefix') ///
						suffix(`suffix')
				
						`s(_td_con)'
						loc nam `s(_td_nam)'
					}
					
						// create dummy
					loc pre = `k' - 1
					qui g byte `nam' = `var' > `val`pre'' ///
					& `var' <= `val`k'' if `touse' `notmiss'
					
						// copy missing values
					if (`hasmiss`j'') {
						if ("`missing'" != "") {
							qui replace `nam' = `cpyvar' ///
							if !(`nam') & mi(`cpyvar')
						}
					}
					else {
						if ("`missing'" != "") {
							qui replace `nam' = `cpyvar' ///
							if mi(`cpyvar') & `touse'
						}
					}
					
						// label
					if ("`varlabel'" == "") {
						loc v1 = round(`val`pre'', .01)
						loc v2 = round(`val`k'', .01)
						loc def "`var' (`v1'-`v2')"
						_labd `nam' ,l(`"`macval(label)'"') ///
						oi(``oi'') def(`def')
					}
				}
				
					// create last dummy in list if needed
				if !(`eq`j'') {
					
					loc ++i
					loc ++o
					
						// get/check name
					if ("`replace'" != "") loc nam `var'
					else {
						_gcnam `var' ,c(`c') i(`i') o(`o') ///
						mdum(`mdum') skip(`skip') stub(`stub') ///
						generate(`generate') prefix(`prefix') ///
						suffix(`suffix')
				
						`s(_td_con)'
						loc nam `s(_td_nam)'
					}
					
						// create dummy
					qui g byte `nam' = `var' > `val`n'' ///
					if `touse' `notmiss'
					
						// copy missing values
					if (`hasmiss`j'') {
						if ("`missing'" ! = "") { 
							qui replace `nam' = `cpyvar' ///
							if !(`nam') & mi(`cpyvar')
						}
					}
					else {
						if ("`missing'" != "") {
							qui replace `nam' = `cpyvar' ///
							if mi(`cpyvar') & `touse'
						}
					}
					
						// label
					if ("`varlabel'" == "") {
						loc def "`var' (> `= round(`val`n'', .01)')"
						_labd `nam' ,l(`"`macval(label)'"') ///
						oi(``oi'') def(`def')
					}
				}
			}
		}
	}
	sret loc _td_nam
	sret loc _td_con
end

pr _gcnam ,sclass
	syntax varname ///
	[ , c(numlist) i(numlist) o(numlist) mdum(numlist) skip(str) ///
	stub(namelist) generate(namelist) prefix(name) suffix(str) ]
	
	sret loc _td_nam
	sret loc _td_con
	loc var `varlist'
	
	// get name
	if ("`stub'" != "") {
		loc nam `: word `c' of `stub''`i'
	}
	else {
		loc nam : word `o' of `generate'
		if ("`nam'" == "") {
			if (`mdum') loc nam `var'`i'
			else loc nam `var'
		}
	}
	loc nam `prefix'`nam'`suffix'
	
	// check name
	cap conf new v `nam'
	if _rc {
		if (_rc == 110) {
			if ("`skip'" != "") {
				if ("`skip'" == "drop") qui drop `nam'
				else {
					loc newnam : permname `nam'
					di as txt "(note: " as res "`nam' " ///
					as txt "already exists; creating " ///
					as res "`newnam' " as txt "instead)"
					loc nam `newnam'
				}
			}
			else {
				di as txt "(note: " as res "`nam' " ///
				as txt "already exists)"
				sret loc _td_con "continue"
			}
		}
		else {
			if (`: length loc nam' > 32) {
				loc newname : permname `nam'
				di as txt "(note: " as res "`nam' " ///
				as txt "invalid name; creating " ///
				as res "`newnam' " as txt "instead)"
				loc nam `newnam'
			}
			else { // this should not happend
				di as txt "(note: " as res "`nam' " ///
				as txt "invalid name; `nam' not created"
				sret loc _td_con "continue"
			}
		}
	}
	sret loc _td_nam "`nam'"
end

pr _labd
	syntax varname [,l(str) oi(numlist) def(str)]
	loc lbl : word `oi' of `l'
	if (`"`macval(lbl)'"' == "") loc lbl `def'
	if strpos(`"`macval(lbl)'"', `"""') la var `varlist' `"`lbl'"'
	else la var `varlist' "`lbl'"
end

pr _oldsyntax ,sclass
	syntax [ , Percentile(numlist > 0 < 100 max = 1) ///
	Cut(numlist max = 1) One(str) Each Distinct ]
	
	di as txt "(note: you are using old {cmd:todummy} syntax; " ///
	"see {help todummy} for new syntax)" 
	
	loc addo 0
	foreach opt in percentile cut one each distinct {
		loc addo = `addo' + ("``opt''" != "")
	}
	if (`addo' > 1) {
		di as err "only one of percentile, cut, each " ///
		"or distinct is allowed"
		e 198
	}
	if ("`each'" != "") | ("`distinct'" != "") sret loc _td_vk k
	else {
		foreach opt in percentile cut one {
			if ("``opt''" != "") {
				sret loc _td_vk ``opt''
				sret loc _td_opt `opt'
				continue ,br
			}
		}
	}
end
e

1.2.2	23aug2012	proper error message if variable name is invalid
					code polish
1.2.1	08feb2012	compatibility with version 9.2
					code polish
1.2.0	21jul2011	code completely rewritten
					(version 1.1.2 still availiable on request)
1.1.2	21may2011	fix bug with double precision
1.1.1		na		add -binary- and -noskip- option
					extend -one()- option (allow multiple numlists)
					specifying more than one main option is an error
					add some checks
					add subroutine _err and _labd
1.1.0		na		fix problems with left single quotes
1.0.9		na		add -replace- option
					no longer check version
					minor changes in error messages
