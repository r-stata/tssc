*! version 1.0.1 13oct2011 Daniel Klein

pr dslab ,rclass
	vers 9.2
	
	syntax anything(id = "string pattern" equalok everything) /*
	*/ [ , /*
	*/ NOT /*
	*/ MATCH /*
	*/ CASEsensitive /*
	*/ VARiables(varlist num) /*
	*/ Alpha /*
	*/ ]
		
	* verify dataset has value labels
	qui la di
	if ("`r(names)'" == "") {
		di as err "no value labels found"
		e 111
	}
	
	* check all variables have value labels attached
	if ("`variables'" != "") {
		foreach v of loc variables {
			loc l : val l `v'
			if ("`l'" == "") {
				di as err "`v' has no value label attached"
				e 111
			}
			loc lab `lab' `l'
		}
	}
	
	* get value label info
	preserve
	qui uselabel `lab' ,clear v
	
	* transfer r() to locals
	foreach lblname in `r(__labnames__)' {
		loc `lblname' `r(`lblname')'
	}
	
	* search for string pattern
	loc fcn = cond("`match'" != "", "match", "pos")
	tempname flag
	qui g byte `flag' = 0
	if ("`casesensitive'" == "") qui replace label = lower(label)
	foreach strp of loc anything {
		loc dump : subinstr loc strp "`" "'" ,all c(loc chg)
		if (`chg') {
			if ("`casesensitive'" == "") loc strp = lower("`strp'")
			qui replace `flag' = str`fcn'(label, "`strp'") if !`flag'
		}
		else {
			if ("`casesensitive'" == "") loc strp = lower(`"`strp'"') 
			qui replace `flag' = str`fcn'(label, `"`strp'"') if !`flag'
		}
	}
	
	* not option
	if ("`not'" != "") {
		qui bys lname : replace `flag' = _n == _N & !sum(`flag')
	}
	
	* check for matches
	qui su `flag' ,mean
	if (r(max) == 0) {
		restore
		e 0
	}
	
	qui levelsof lname if `flag' ,loc(lvls)
	restore
	
	* get list of variables and labels
	foreach l of loc lvls {
		loc varlist `varlist' ``l''
		loc lbllist `lbllist' `l'
	}
	
	* output
	if ("`varlist'" == "") {
		la li `lbllist'
		di as txt _n "(note: value labels are not " /*
		*/ "attached to variables)"
	}
	else {
		if ("`alpha'" ! ="") {
			qui ds `varlist' ,a
			loc varlist `r(varlist)'
		}
		d `varlist'
		ret loc varlist `varlist'
	}
	ret loc lbllist `lbllist'
end
e

History

1.0.1	13oct2011	function -strpos- used as default (was strmatch)
					add option -match-
1.0.0	18aug2011	first version on SSC (part of labutil2)
