*! version 1.0.3 10feb2012 Daniel Klein

pr labunab
	vers 9.2
	
	* get lmacname
	gettoken lmacname 0 : 0 ,p(:)
	loc 0 : subinstr loc 0 ":" "" ,c(loc col)
	if !(`col') err 198
	
	syntax anything(id = "lblname-list" equalok everything) /*
	*/ [, All clear]
	
	* check lmacname and clear previous results
	loc 0 `lmacname'
	syntax name(local)
	if ("`clear'" != "") c_local `lmacname'
	
	* get value labels from memory
	qui la di
	loc lablist `r(names)'
	
	* get additional value labels
	if ("`all'" != "") {
		foreach v of varlist * {
			loc lb : val l `v'
			if ("`lb'" == "") | (`: list lb in lablist') continue
			loc lablist `lablist' `lb'
		}
	}
	
	if ("`lablist'" == "") {
		di as err "no value labels found"
		e 111
	}
	
	* unabbreviate namelist
	foreach nam of loc anything {
	
		* nam is * or _all
		if inlist("`nam'", "*", "_all") {
			loc unablist `unablist' `lablist'
			continue
		}
		
		* check for wildcards
		loc dump : subinstr loc nam "*" "" ,all c(loc ast)
		loc dump : subinstr loc nam "?" "" ,all c(loc qm)
		loc _nam : subinstr loc nam "~" "*" ,all c(loc til)
		if  !(`ast') & !(`qm') & !(`til') {
			loc _nam "`nam'*"
			loc mone 1
		}
		else {
			if (`til') & ((`ast') | (`qm')) {
				di as err "`nam':  " /*
				*/ "may not combine ~ and *-or-? notation"
				e 198
			}
			if !(`til') loc _nam `nam'
			loc mone = `til'
		}
		
		* find matches
		mata : mlabunab("`_nam'", "`lablist'")
		if !(`nm') {
			di as err "value label `nam' not found"
			e 111
		}
		if (`nm' > 1) & (`mone') {
			di as err "`nam' ambiguous abbreviation"
			e 111
		}
		loc unablist `unablist' `lab'
	}
	
	* return results
	c_local `lmacname' `unablist'
end

vers 9.2
mata :
void mlabunab(string scalar nam, string scalar lablist)
{
	string rowvector lblst, mtch
	string scalar lab
	real scalar i
	
	lblst = tokens(lablist)
	lab = ""
	
	mtch = select(lblst, strmatch(lblst, nam))
	for (i = 1; i <= cols(mtch); ++i) {
		if (i == 1) lab = mtch[1, i]
		else lab = lab + " " + mtch[1, i]
	}
	st_local("lab", lab)
	st_local("nm", strofreal(cols(mtch)))
}
end
e

1.0.3	10feb2012	mata function replaces loop
1.0.2	23nov2011	check valid macro name
1.0.1	03sep2011	option -clear- added
1.0.0	22aug2011
