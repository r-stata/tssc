*! version 1.0.4 beta 17nov2012 Daniel Klein

pr lookfor_val ,rclass
	vers 9.2
	
	syntax [varlist] [if][in] [, Pattern(str) ///
	INSEnsitive Missing STRing NUMeric Format(str) ///
	Values SEParate(str) Describe List TAbulate noPrint ]
	
	// sample
	marksample touse ,s nov
	qui cou if `touse'
	if !(r(N)) err 2000
	
	// options
	if (`"`macval(format)'"' != "") {
		cap conf for `format'
		if (_rc) {
			di as err `"invalid format `macval(format)'"'
			e 198
		}
	}
	if ("`list'`tabulate'" != "") {
		loc values values
		loc print noprint
	}
	if ("`values'" != "") & ("`describe'" != "") {
		di as err "option describe not allowed with values"
		e 198
	}
	if ("`numeric'" != "") & ("`string'" != "") {
		loc numeric
		loc string
	}
	if (`"`macval(separate)'"' == "") loc separate " "
	
	cap conf e `pattern'
	if (_rc) {
		if ("`missing'" == "") {
			di as txt "(note: no pattern specified)"
			loc pattern *
		}
		else loc pattern = cond("`numeric'" != "", ".", "")
	}
	
	// loop thru varlist
	foreach v of loc varlist {
		cap conf `numeric' `string' v `v'
		if (_rc) continue
		
		m : lookforval("`v'", "`touse'")
		
		if !(`addit') continue
		loc varlst `varlst'`separate'`v'
		
		if ("`values'" == "") continue
		loc values_`v' : list uniq values_`v'
		loc values_`v' : list sort values_`v'
		
		if ("`list'`tabulate'" == "") continue
		
		if ("`list'" != "") l `v' if `mtch' & `touse'
		if ("`tabulate'" != "") {
			ta `v' if `mtch' & `touse' ,`missing'
		}
		drop `mtch'
	}
	
	// return results
	if ("`varlst'" == "") e 0 // done
	
	if ("`values'" == "") {
		if ("`print'" == "") di as txt "`varlst'"
		if ("`describe'" != "") d `varlst'
		ret loc varlist `varlst'
	}
	else {
		foreach v of loc varlst {
			if ("`print'" == "") {
				di as txt _c "values_`v': "
				m : display(st_local("values_`v'"), .)
			}
			cap ret loc values_`v' `"`macval(values_`v')'"'
			if (_rc) di as txt "(note: cannot return values_`v')"
		}
	}
end

vers 9.2
m:
void lookforval(string scalar varn, string scalar tu)
{
	real scalar isnum
	transmorphic colvector x
	real colvector xnmis, mtch
	string scalar fmt
	
	// get var
	isnum = !(st_isstrvar(varn))
	if (isnum) {
		x = st_data(., varn, tu)
		if (st_local("missing") == "") xnmis = (x :< .)
		fmt = st_local("format")
		if (fmt == "") fmt = st_varformat(varn)
		x = strofreal(x, fmt)
	}
	else x = st_sdata(., varn, tu)
	
	// find pattern
	if (st_local("insensitive") == "") {
		mtch = strmatch(x, st_local("pattern"))
	}
	else mtch = strmatch(strlower(x), strlower(st_local("pattern")))
	if (st_local("missing") == "") {
		if (!(isnum)) mtch = (mtch :* (x :!= ""))
		else mtch = (mtch :* xnmis)
	}
	
	// select matches
	x = select(x, mtch)
	
	// return result to Stata
	if (rows(x)) st_local("addit", "1")
	else st_local("addit", "0")
	
	// values specified
	if (st_local("values") != "") {
		lookforval_values(x, mtch, isnum, varn, tu)
	}
}

void lookforval_values(string colvector x,
						real colvector mtch,
						real scalar isnum,
						string scalar varn,
						string scalar tu)
{
	string scalar val, vals
	real scalar tmpv
	
	for (i = 1; i <= rows(x); ++i) {
		val = x[i, 1]
		if (!(isnum)) {
			if (!strpos(val, `"""')) val = `"""' + val + `"""'
			else val = "`" + `"""' + val + `"""' + "'"
		}
		if (i == 1) vals = val
		else vals = vals + st_local("separate") + val
	}
	st_local("values_" + varn, vals)
	
	// create tempvar if necessary
	if ((st_local("list") != "") | (st_local("tabulate") != "")) {
		tmpv = st_addvar("byte", st_tempname())
		st_store(., tmpv, tu, mtch)
		st_local("mtch", st_varname(tmpv))
	}
}
end
e

1.0.4	17nov2012	Mata subroutine
					change how values are displayed
1.0.3	15nov2012	complete rewrite code
					move things to Mata
					version 9.2 required
					fix minor bugs
					add -if- and -in- qualifier
					add option -format-
1.0.2	14nov2010	
