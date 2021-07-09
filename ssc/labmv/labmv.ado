*! version 1.0.8 23aug2012 Daniel Klein

pr labmv ,rclass
	vers 9.2
	
	syntax [varlist] [if][in] , mv(numlist miss max = 52) ///
	[ALLvars noDELete Fmvc(numlist int miss max = 1) ENcode Current]
	
	marksample touse ,nov
	qui cou if `touse'
	if !(r(N)) err 2000
	
	// set first mvc
	if ("`fmvc'" == "") loc fmvc .a
	if (`fmvc' < .a) {
		di as err "fmvc() invalid -- must be one of .a, .b, ..., .z"
		e 125
	}
	
	// parse mv and set mvclist
	_pcrmvc `mv' ,fmvc(`fmvc') `encode'
	
	// multilingual labels
	qui la lang
	loc k `r(k)'
	if (`k' > 1) & ("`current'" == "") {
		loc lgs `r(languages)'
		loc clan `r(language)'
	}
	else loc lgs `r(language)'
	
	// allvars
	if ("`allvars'" ! = "") & (`: word count `varlist'' < c(k) - 1) {
		
		foreach lan of loc lgs {
			qui la lang `lan'
			
			 // get labelnames of variables in varlist
			foreach v of loc varlist {
				loc lab : val l `v'
				if ("`lab'" == "") continue
				if !(`: list lab in lblnamelist') {
					cap la li `lab'
					if (_rc) | (r(k) == 0) continue
					loc lblnamelist `lblnamelist' `lab'
				}
			}
		
			if ("`lblnamelist'" != "") {
			
				// now get all variables these labels are attached to
				foreach v of varlist * {
					if (`: list v in varlist') continue
					loc lab : val l `v'
					if ("`lab'" == "") continue
					if !(`: list lab in lblnamelist') continue
					loc varlist `varlist' `v'
				}
			}
		}
		if (`k' > 1) qui la lang `clan'
	}
	
	// create rules
	loc i 0
	foreach m of loc mv {
		loc mis : word `++i' of `abc'
		loc tok1 = cond("`encode'" == "", "`m'", "`mis'")
		loc tok2 = cond("`encode'" == "", "`mis'", "`m'")
		loc rules `rules' (`tok1' = `tok2')
		loc chk `chk', `tok1'
		loc floatchk `floatchk' ,float(`tok1')
	}
	
	// change numeric values to missings
	foreach v of loc varlist {
		cap conf numeric v `v'
		if (_rc) continue
		loc float = cond("`: t `v''" == "double", "", "float")
		cap as !inlist(`v'``float'chk')
		if !(_rc) continue
		
		recode `v' `rules' if `touse'
		loc cvarlist `cvarlist' `v'
		
		// change value labels
		foreach lan of loc lgs {
			qui la lang `lan'
			loc lbl : val l `v'
			if ("`lbl'" == "") | (`: list lbl in labelsdone') continue
			loc labelsdone `labelsdone' `lbl'
			loc i 0
			loc vt
			loc ok 0
			foreach m of loc mv {
				loc mis : word `++i' of `abc'
				loc tok1 = cond("`encode'" == "", "`m'", "`mis'")
				loc tok2 = cond("`encode'" == "", "`mis'", "`m'")
				loc t : lab `lbl' `tok1' ,strict
				if (`"`macval(t)'"' == "") continue
				loc ok 1
				if (`tok2' == int(`tok2')) {
					if strpos(`"`macval(t)'"', `"""') {
						loc vt `vt' `tok2' `"`t'"'
					}
					else loc vt `vt' `tok2' "`t'"
				}
				if ("`delete'" == "") loc vt `vt' `tok1' ""
			}
			if (`ok') {
				la de `lbl' `vt' ,modify
				di as txt "(value label " ///
				as res "`lbl' " as txt "modified)"
			}
		}
		if (`k' > 1) qui la lang `clan'
	}
	
	// return locals
	if (`k' > 1) ret loc languages `lgs'
	ret loc maxmvc `maxmvc'
	ret loc minmvc `minmvc'
	ret loc k `: word count `mv''
	ret loc lblnamelist `labelsdone'
	ret loc varlist `cvarlist'
	ret loc mvc `abc'
	ret loc values `mv'
end

pr _pcrmvc
	syntax anything(name = mv) ,fmvc(str)[encode]
	
	// pasre mv
	loc dups : list dups mv
	if ("`dups'" != "") {
		di as err "mv() invalid -- "
		"value `: word 1 of `dups'' mentioned more than once"
		e 124
	}
	if (`: list posof "." in mv') {
		di as err "mv() invalid -- may not contain ."
		e 125
	}
	
	m : st_local("mvmiss", ///
	strofreal(hasmissing(strtoreal(tokens(st_local("mv"))))))
	
	if (`mvmiss') {
		if ("`encode'" == "") gettoken tok : mv
		else loc tok : word `: word count `mv'' of `mv'
		if mi(`tok') {
			di as err "mv() invalid -- " ///
			"`tok' found where nonmissing expected"
			e 124
		}
		m : spltmv("`encode'")
		if (`rc') {
			di as err "mv() invalid -- " ///
			"may not contain consecutive {it:mvc}"
			e 124
		}
		c_local mv `smv'
	}
	else loc cnt : word count `mv'
	
	// create mvc list
	m : crmvcl(`fmvc', `cnt')
	if (`rc') {
		di as err "mv() invalid -- too many values specified"
		e 123
	}
	c_local minmvc `minmvc'
	c_local maxmvc `maxmvc'
	c_local abc `abc'
end

vers 9.2
m :
void spltmv(| string scalar encode)
{
	real rowvector mv ,rnv, sel
	
	// get mv
	mv = strtoreal(tokens(st_local("mv")))
	
	// select values with user defined mvc
	if (encode == "") sel = (colmissing(mv)[1, (2::cols(mv))], 0)
	else sel = (0, colmissing(mv)[1, (1::cols(mv) - 1)])
	rnv = select(mv, sel)
	
	// selct values w/o user defined mvc
	mv = select(mv, !(sel) :- colmissing(mv))
	st_local("cnt", strofreal(cols(mv)))
	
	// now put it back together
	mv = mv, rnv
	st_local("rc", strofreal(hasmissing(mv)))
	
	// back to Stata
	for (i = 1; i <= cols(mv); ++i) {
		st_local("smv", st_local("smv") + " " + strofreal(mv[1, i]))
	}
}

void crmvcl(real scalar fmvc, real scalar cnt)
{
	real rowvector mv
	string rowvector abc, rmv
	
	// set abc
	abc = "." :+ tokens(st_global("c(alpha)"))
	
	// get mvc from mv
	mv = strtoreal(tokens(st_local("mv")))	
	rmv = strofreal(select(mv, colmissing(mv)))
	
	if (cnt) {
	
		// remove mvc from abc
		abc = abc[1, ///
		(select(J(1, 1, (1..26)), strtoreal(abc) :== fmvc)::cols(abc))]
		for (i = 1; i <= cols(rmv); ++i) {
			abc = subinstr(abc, rmv[1, i], "")
		}
		abc = select(abc, abc :!= "")
	
		// check enough mvc left
		st_local("rc", strofreal(cols(abc) < cnt))
		if (cols(abc) < cnt) exit(0)

		// create mvclist	
		abc = abc[1, (1::(nonmissing(mv) - cols(rmv)))]
		if (cols(rmv)) abc = abc, rmv	
	}
	else abc = rmv
	
	// back to Stata
	for (i = 1; i <= cols(abc); ++i) {
		st_local("abc", st_local("abc") + " " + abc[1, i])
	}
	
	// minimum and maximum mv
	st_local("minmvc", strofreal(minmax(strtoreal(abc), 1)[1, 1]))
	st_local("maxmvc", strofreal(minmax(strtoreal(abc), 1)[1, 2]))
}
end
e

1.0.8	23aug2012	fix bugs in 1.0.8 beta 18aug2012
					user defined mvc in -mv- allowed
					new code: subroutine and Mata functions
					code polish
1.0.7	03feb2012	fix problems with left single and compound quotes
1.0.6	07jan2012	support multilingual datasets
1.0.5	24dec2011	fix bug: float precision
1.0.4	09nov2011	-if- and -in- are allowed
					option -allvars- added
1.0.3	19oct2011	add option -encode-
1.0.2	18aug2011	fix bug: check if label has already been modified
1.0.1	11aug2011	add -fmvc- option
					preserve single left quote
					part of -labutil2- package
1.0.0	07aug2011
