*! version 1.0.4 23aug2012 Daniel Klein

pr labren
	vers 9.2
	
	syntax [anything(id = "lblname-list")] ///
	[ , csis(str) x(str) Dryrun * ]
	
	// parse
	if (`"`options'"' != "") _labchg `0'
	else {
		if (`"`csis'"' != "") {
			if (`"`x'"' != "") {
				di as err "option csis not allowed"
				e 198
			}
			loc x `"`csis'"'
		}
		loc dmp : subinstr loc anything "#" "" ,c(loc has)
		if (`has') | ("`x'" != "") _csis `0'
		else _labren `0'
	}
end

pr _labren
	syntax anything(id = "lblname-list") [ , Dryrun]
		
	// get old and new
	gettoken old anything : anything ,m(p)
	gettoken new anything : anything ,m(p)
	if (`"`anything'"' != "") err 198
	if (`: list posof "_all" in old') {
		qui la di
		loc rnames `r(names)'
		m : st_local("old", ///
		subinstr(st_local("old"), "_all", st_local("rnames")))
	}
	loc nold : word count `old'
	loc nnew : word count `new'
	if inlist(0, `nnew', `nold') err 198
	if (`nold' != `nnew') {
		di as err "corresponding {it:oldlblname-list} " ///
		"and {it:newlblname-list} mismatch"
		e 198
	}
	qui la li `old'
	cap noi conf name `new'
	if _rc e 198
	
	// rename single label
	if (`nold' == 1) {
		if ("`dryrun'" != "") {
			di as err "options not allowed"
			e 101
		}
		if ("`old'" == "`new'") {
			_dry
			e 0 // done
		}
		cap la li `new'
		if !(_rc) {
			di as err "label `new' already defined"
			e 110
		}
		
		// copy and get varlist label is attached to
		m : _matalabcpy("`old'", "`new'")
		_getvars `old'
		la drop `old'
	}
	
	// rename multiple labels
	else {
		foreach x in old new {
			loc dups : list dups `x'
			if ("`dups'" != "") {
				di as err "{it:`x'lblname}: " ///
				"`: word 1 of `dups'' mentioned more than once"
				e 198
			}
		}
		
		// remove old == new
		loc nnew 0
		forv j = 1/`nold' {
			loc o : word `j' of `old'
			loc n : word `j' of `new'
			if ("`o'" != "`n'") {
				loc nn `nn' `n'
				loc no `no' `o'
				loc ++nnew
			}
		}
		if ("`no'" == "") {
			_dry
			e 0 // done
		}
		loc new `nn'
		loc old `no'
		loc nold `nnew'
		
		// check new exists and not in old
		foreach n of loc new {
			cap la li `n'
			if !(_rc) & !(`: list n in old') {
				di as err "label `n' already defined"
				e 110
			}
		}
		
		// dryrun?
		if ("`dryrun'" != "") {
			_dry ,old(`old') new(`new')
			e 0 // done
		}

		// copy to tempname
		forv j = 1/`nold' {
			tempname tlab`j'
			m : _matalabcpy("`: word `j' of `old''", "`tlab`j''")
		}
		_getvars `old'
		la drop `old'
		foreach _new of loc new {
			cap la drop `_new'
		}
		
		// copy to new
		forv j = 1/`nnew' {
			m : _matalabcpy("`tlab`j''", "`: word `j' of `new''")
		}
	}
	
	// attach value labels to variables
	qui la lang
	foreach lan in `r(languages)' {
		if (r(k) > 1) qui la lang `lan'
		forv j = 1/`nnew' {
			foreach v of loc __vlst_`j'`lan' {
				la val `v' `: word `j' of `new''
			}
			c_local __vlst_`j'`lan'
		}
	}
	if (r(k) > 1) qui la lang `r(language)'
end

pr _labchg
	syntax [namelist(id = "lblname-list")] ///
	[ , Upper Lower PREfix(str) SUFFix(str) ///
	BEFore(name) AFTer(name) noEXClude ///
	SUBst(str asis) STRFCN(str asis) SYmbol(str) ///
	Dryrun ]
	
	// check options
	if ("`upper'" != "") & ("`lower'" != "") {
		di as err "options upper and lower not both allowed"
		e 198
	}
	loc uplo `upper'`lower'
	
	if (`"`before'"' != "") & (`"`after'"' != "") {
		di as err "options before and after not both allowed"
		e 198
	}
	
	loc exclude = ("`exclude'" == "")
	
	if (`"`subst'"' != "") {
		if (`: word count `subst'' != 2) {
			di as err "subst must be two strings"
			e 198
		}
		loc f : word 1 of `subst'
		loc t : word 2 of `subst'
	}
	
	cap conf e `strfcn'
	loc is_strfcn = !(_rc)
	if !(`is_strfcn') & ("`symbol'" != "") {
		di as err "symbol may only be specified with strfcn"
		e 198
	}
	if ("`symbol'" != "") {
		if (length("`symbol'") > 1) {
			di as err "option symbol must be one character"
			e 198
		}
	}
	else if (`is_strfcn') loc symbol @

	// get old
	if ("`namelist'" == "") loc namelist _all
	if (`: list posof "_all" in namelist') {
		qui la di
		loc rnames `r(names)'
		m : st_local("old", ///
		subinstr(st_local("namelist"), "_all", st_local("rnames")))
		if ("`old'" == "") {
			di as err "no value labels defined"
			e 111
		}
	}
	else loc old `namelist'
	qui la li `old'
	
	// create new
	foreach o of loc old {
		loc n `o'
		
		// before after
		if (`"`before'"' != "") | (`"`after'"' != "") {
			loc ba `"`before'`after'"'
			loc pos = strpos(`"`n'"', `"`ba'"')
			if (`pos') {
				loc add = length(`"`ba'"')
				if (`"`before'"' != "") {
					loc strt 1
					loc stp = `pos' - 1
					if !(`exclude') {
						loc stp = `stp' + `add'
					}
				}
				if (`"`after'"' != "") {
					loc stop .
					loc strt `pos'
					if (`exclude') {
						loc strt = `strt' + `add'
					}
				}
				loc n = substr(`"`n'"', `strt', `stp')
			}
		}
		
		// substitute
		if (`"`subst'"' != "") {
			loc n : subinstr loc n `"`f'"' `"`t'"' ,all
		}
		
		// upper lower
		if ("`uplo'" != "") loc n = `uplo'("`n'")
		
		// string fuction
		if (`"`macval(strfcn)'"' != "") {
			loc _cpy_strfcn : subinstr ///
			loc strfcn `"`symbol'"' `"`n'"' ,all
			cap noi loc n = `_cpy_strfcn'
			if _rc {
				di as err "invalid strfcn() returned error"
				e _rc
			}
		}
		
		// prefix suffix
		loc n `"`prefix'`n'`suffix'"'		
		
		// check and add name
		if (`"`n'"' != `"`o'"') {
			cap conf name `n'
			if (_rc) | (`: word count `n'' != 1) {
				di as err `"`n' invalid name"'
				e 198
			}
			loc new `new' `n'
		}
		else loc rmv `rmv' `o'
	}
	loc old : list old - rmv
	
	// to _labren
	if ("`dryrun'" != "") | ("`new'" == "") _dry ,old(`old') new(`new')
	else _labren (`old')(`new')
end

pr _csis
	
	syntax anything(id = "lblname-list") [ , csis(str) x(str) Dryrun]
	
	// get old and new
	gettoken old anything : anything ,m(par1)
	gettoken new anything : anything ,m(par2)
	if (`"`anything'"' != "") err 198
	if (`: list posof "_all" in old') {
		qui la di
		loc rnames `r(names)'
		m : st_local("old", ///
		subinstr(st_local("old"), "_all", st_local("rnames")))		
	}
	loc nold : word count `old'
	loc nnew : word count `new'
	if inlist(0, `nnew', `nold') err 198
	
	// csis to x
	if (`"`csis'"' != "") loc x `"`csis'"'
	
	// reset anything and set x
	loc anything `old' `new'
	if (`"`x'"' == "") loc x # 1/`nold'
	
	// parse x
	loc i 0
	while (`"`x'"' != "") {
	
		// get symbol
		gettoken sym x : x
		if (length("`sym'") != 1) {
			di as err `"`sym' invalid symbol; "' ///
			"symbol must be one character"
			e 198
		}
		loc dmp : subinstr loc anything `"`sym'"' "" ,c(loc has)
		if !(`has') {
			di as err `"`sym' not found in `anything'"'
			e 198
		}
		if (`: list sym in symlist') {
			di as err `"symbol `sym' multiply defined"'
			e 198
		}
		loc symlist `symlist' `sym'
		
		// get list
		gettoken lst x : x ,p(\)
		if (`"`lst'"' == "") | (`"`lst'"' == "\") {
			di as err "symbol `sym': no list found"
			e 198
		}
		cap numlist `"`lst'"' ,int r(>=0)
		if !(_rc) loc lst `r(numlist)'
		else if (_rc != 121) err _rc
		loc lst`++i' `lst'
		
		// get backslash if any
		gettoken bs x : x ,p(\)
	}
	
	// create old and new
	foreach on in old new {
		token ``on''
		loc chg
		forv j = 1/`n`on'' {
		
			loc tochg ``j''
			forv k = `i'(-1)1 {
				loc sym : word `k' of `symlist'
				if !(strpos(`"`tochg'"', `"`sym'"')) continue
				foreach el of loc lst`k' {
					loc _chg : subinstr loc tochg `"`sym'"' "`el'" ,all
					loc chg `chg' `_chg'
				}
				loc tochg `chg'
				loc chg
			}
			loc cr_`on' `cr_`on'' `tochg'
		}
	}
	
	// to _labren
	if ("`dryrun'" != "") _dry ,old(`cr_old') new(`cr_new')
	else _labren (`cr_old')(`cr_new')
end

pr _getvars
	syntax namelist
	qui la lang
	foreach lan in `r(languages)' {
		if (r(k) > 1) qui la lang `lan'
		foreach v of varlist * {
			loc lb : val l `v'
			if ("`lb'" == "") | !(`: list lb in namelist') continue
			loc `lb'`lan' ``lb'`lan'' `v'
		}
		loc i 0
		foreach nam of loc namelist {
			c_local __vlst_`++i'`lan' ``nam'`lan''
		}
	}
	if (r(k) > 1) qui la lang `r(language)'
end

pr _dry
	syntax [ , old(str) new(str)]
	if ("`old'`new'" == "") {
		di %2s as txt " " "(all {it:newnames}=={it:oldnames})"
		e 0 // done
	}
	di as txt _n %37s "{it:oldlblname}" " - " "{it:newlblname}"
	loc s = max(`: word count `old'', `: word count `new'')
	forv j = 1/`s' {
		di as res %32s "`: word `j' of `old''" ///
		" - "  "`: word `j' of `new''"
	}	
end

vers 9.2
m : 
void _matalabcpy(string scalar oldlbl, string scalar newlbl)
{
	st_vlload(oldlbl, vals = ., txt = "")
	st_vlmodify(newlbl, vals, txt)
}
end
e

1.0.4	23aug2012	minor changes and code polish
1.0.3	05jan2012	fix bug if _all was specified as oldlblname
1.0.2	29nov2011	fix bug in -suffix- and -prefix- (name -> str)
					allow characters "*", "?" and "~" as symbols
					rename option -x- -csis-
1.0.1	11nov2011	fix bugs with option -dryrun-
					add checks for -x()- option
1.0.0	03oct2011
