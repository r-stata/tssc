*! version 1.0.5 22aug2012 Daniel Klein

pr labvars
	vers 9.2
	
	syntax [anything(id = varlist equalok everything)] ///
	[, Remove Carryon Alternate NAMes ]
	
	if !(c(k)) {
		di as err "no variables defined"
		e 111
	}
	
	// check options and pass to subroutine
	if ("`alternate'`names'" != "") {
		if ("`alternate'" != "") labvars_alt `0'
		if ("`names'" != "") labvars_nam `0'
		e 0 // done
	}
	
	loc opt : word count `remove' `carryon'
	if (`opt' > 1) {
		di as err "options remove and carryon not both allowed"
		e 198
	}
	
	// parse user
	if (`"`macval(anything)'"' == "") {
		if !(`opt') {
			di as err `"`c(k)' `= plural(`c(k)', "variable")' "' ///
			"but 0 labels specified"
			e 100
		}
		else loc varlist *
	}
	else {
		gettoken quotes : anything ,p(`"`""'\"') qed(q)
		if (`q') loc varlist *
		else {
			gettoken varlist anything : anything ,p("\")
			if (`"`macval(varlist)'"' == "\") loc varlist *
			else if (`"`macval(anything)'"' == "") {
				gettoken varlist anything : varlist ,p(`"`""'"')
			}
			else gettoken bs anything : anything ,p("\")
		}
	}
	
	// check varlist and match
	unab varlist : `varlist'
	loc nvar : word count `varlist'
	loc nlab : word count `anything'
	if (`nvar' != `nlab') {
		if (`nvar' < `nlab') loc opt 0
		if !(`opt') {
			di as err `"`nvar' `= plural(`nvar', "variable")' "' /*
			*/ `"but `nlab' `= plural(`nlab', "label")' specified"'
			e 198
		}
	}
	if ("`carryon'" == "") loc remove remove
	
	// label variables
	token `"`macval(anything)'"'
	loc l 0
	foreach v of loc varlist {
		loc ++l	
		if (`"`macval(`l')'"' != "") | ("`remove'" != "") {
			loc lbl "``l''"
		}
		if strpos(`"`macval(lbl)'"', `"""') la var `v' `"`lbl'"'
		else la var `v' "`lbl'"
	}
end

pr labvars_alt
	syntax [anything(id = varname equalok everything)] ,Alternate
	
	// check
	loc nany : word count `anything'
	if !(`nany') err 102
	if mod(`nany', 2) {
		loc nvar = ceil(`nany'/2)
		loc nlab = floor(`nany'/2)
		di as err `"`nvar' `= plural(`nvar', "variable")' "' ///
		`"but `nlab' `= plural(`nlab', "label")' specified"'
		e 198
	}
	
	// check varlist
	token `"`macval(anything)'"'
	forv j = 1(2)`nany' {
		loc varlist `varlist' ``j''
	}
	conf v `varlist'
	
	// label variables
	loc l 2
	foreach v of loc varlist {
		if strpos(`"`macval(`l')'"', `"""') {
			la var `v' `"``l''"'
		}
		else la var `v' "``l''"
			loc l = `l' + 2
		}
end

pr labvars_nam
	syntax [varlist] ,NAMes
	
	// label variables
	foreach v of loc varlist {
		la var `v' "`v'"
	}
end
e

1.0.5	22aug2012	fix small bug
1.0.4	27jun2012	new option -names-
					subroutines label variables
1.0.3	01mar2012	enhanced syntax: 
						backslash no longer needed
						varlist is optional
						variable names and labels may alternate
					fix bug with single left quote
1.0.2	06jun2011	version 9.2 compatibility
					changes in options/default:
					option -remove- added
					option -carryon- replaces -unique- (default change)
					option -test- and -echo- removed
1.0.1	22nov2010
