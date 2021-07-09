*! version 1.0.4 27mar2013 Daniel Klein

pr labmvs ,rclass
	vers 9.2
	
	syntax [varlist] [if] [in] , mv(str asis) ///
	[ ALLvars CASEsensitive noDELete Fmvc(numlist int miss max = 1) ]
	
	marksample touse ,nov
	qui cou if `touse'
	if !(r(N)) err 2000
	
	// first mvc
	loc nstr : word count `mv'
	loc abc `c(alpha)'
	if !inlist("`fmvc'", "", ".a") {
		if (`fmvc' < .b) {
			di as err "option fmvc() -- must be one of .a, .b ..., .z"
			e 125
		}
		loc first : list posof "`= substr("`fmvc'", 2, .)'" in abc
		
		// check numlist
		if (`nstr' > 26 - (`first' - 1)) {
			di as err "option mv() -- too many {it:labels} specified"
			e 198
		}
	}
	else loc first 1
	
	// get lblname-list
	foreach v of loc varlist {
		loc lab : val l `v'
		if ("`lab'" == "") continue
		if !(`: list lab in lblnamelist') {
			cap la li `lab'
			if _rc | (r(k) == 0) continue
			loc lblnamelist `lblnamelist' `lab'
		}
		loc `lab' ``lab'' `v'
	}
	if ("`lblnamelist'" == "") {
		di as txt "(note: no value labels)"
		e 0 // done
	}
	
	// allvars
	if ("`allvars'" ! = "") & (`: word count `varlist'' < c(k) - 1) {
		foreach v of varlist * {
			if (`: list v in varlist') continue
			loc lab : val l `v'
			if ("`lab'" == "") | !(`: list lab in lblnamelist') {
				continue
			}
			loc `lab' ``lab'' `v'
		}
	}
	
	// option casesensitive
	loc low = ("`casesensitive'" == "")
	if (`low') {
		m : st_local("mv", strlower(st_local("mv")))
	}
	
	// delete
	loc del = ("`delete'" == "")
	
	// modify value labels and change values
	foreach lb of loc lblnamelist {
		loc rle // rle is filled with "mvc numlist \ ..."
		
		// modify value labels
		m : _mlabmvs("`lb'", `low', `first', `del')
		if ("`rle'" == "") continue
		di as txt "(value label " as res "`lb' " as txt "modified)"
		
		// recode variables
		while ("`rle'" != "") {
			gettoken r rle : rle ,p(\)
			gettoken bs rle : rle ,p(\)
			gettoken emv vals : r
			m : st_local("vals", strtrim(st_local("vals")))
			foreach v of loc `lb' {
				qui cou if mi(`v') & `touse'
				loc nmis = r(N)
				qui replace `v' = `emv' if inlist(`v', `vals') & `touse'
				qui cou if mi(`v') & `touse'
				loc dif = r(N) - `nmis'
				if ("`nchg`v''" == "") loc nchg`v' `dif'
				else loc nchg`v' = `nchg`v'' + `dif'
				ret loc `v' `return(`v')' ///
				`: subinstr loc vals "," " ", all'
			}
		} 
		foreach v of loc `lb' {
			di as txt "(" as res "`v'" as txt ": `nchg`v'' " ///
			`"`= plural(`nchg`v'', "change")' made)"'
			if (`nchg`v'') {
				loc rvars `v' `rvars'
			}
		}
	}
	ret loc lblnamelist `lblnamelist'
	ret loc varlist `rvars'
	ret loc minmvc `fmvc'
end

vers 9.2
m :
void _mlabmvs(string scalar lbl, 
				real scalar low, 
				real scalar f, 
				real scalar del)
{
	string colvector mv, mvcs
	string colvector t, vs
	string scalar invvs
	real scalar i
	
		// get stuff from Stata locals
	mv = tokens(st_local("mv"))'
	mvcs = "." :+ tokens(st_global("c(alpha)"))'
	
		// load value label
	st_vlload(lbl, val = ., txt = "")
	if (low) t = strlower(txt)
	else t = txt
	
		// find matches
	for (i = 1; i <= rows(mv); ++i) {
		m = strmatch(t, mv[i, 1])
		if (colsum(m) == 0) {
			++f
			continue
		}
		
			// get values back to Stata
		val = st_vlsearch(lbl, txt :* m)
		vs = strofreal(val) :* !rowmissing(val)
		invvs = ""
		for (j = 1; j <= rows(vs); ++j) {
			invvs = invvs + " " + vs[j, 1]
		}
		vs = strtrim(stritrim(invvs))
		if (vs == "") continue
		val = strtoreal(tokens(vs))'
		vs = subinstr(vs, " ", ", ")
		st_local("rle", ///
		st_local("rle") + " " + mvcs[f, 1] + " " + vs + " \")
		
			// modify value label
		txt = st_vlmap(lbl, val)	
		st_vlmodify(lbl, strtoreal(J(rows(txt), 1, mvcs[f, 1])), txt)
		if (del) { // delete values
			st_vlmodify(lbl, val, J(rows(val), 1, ""))
		}
		++f
		
			// reload
		st_vlload(lbl, val = ., txt = .)
		if (low) t = strlower(txt)
		else t = txt
	}
}
end
e

1.0.4	27mar2013	fix bug in output
1.0.3	23aug2012	return lblnamelist
					code polish
1.0.2	09apr2012	fix bug in mata loop
					make it rclass
1.0.1	05jan2012	fix bug with -if- and -in- qualifier
					fix bug with left single quote
					use loop instead of -invtokens()-
					compatible with Stata 9.2
1.0.0	10nov2011	first version on SSC (labutil2)
