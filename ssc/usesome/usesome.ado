*! version 1.2.0 22dec2013 Daniel Klein

pr usesome ,rclass
	vers 10.1
	
	syntax [ anything(name = varspec id = "varspec" ) ] using/ ///
	[, CLEAR NOT IF(passthru) IN(str) noLabel FINDNAME FINDNAMENOT * ]
	
	// clear ok
	if (c(changed)) & ("`clear'" == "") err 4
	
	// ds and findname options
	if (`"`macval(options)'"' != "") {
		if (`: list posof "not" in options') {
			di as err "option not not allowed"
			e 198
		}
		loc cmd ds
	}
	if ("`findname'`findnamenot'" != "") {
		if ("`findname'" != "") & ("`findnamenot'" != "") {
			di as err "may not combine findname and findnamenot"
			e 198
		}
		if (`"`macval(options)'"' == "") {
			di as err "findname options required"
			e 198
		}
		if ("`findnamenot'" != "") loc options `options' not
		loc cmd findname
	}
	
	// get K and position of varnames in using
	m : mGetUsingK(`"`using'"', "K", "pos")
	
	// parse varspec
	if ("`varspec'`cmd'" == "") loc varspec *
	if ("`varspec'" != "") {
		if ((`: list posof "_all" in varspec') ///
		| (`: list posof "*" in varspec')) {
			loc varspec *
			loc cmd
		}
	}
	
	// split varspec into varnames and inidices
	ParseVarspec `varspec' ,k(`K') varnames(vnams) indices(idxs)
	
	// expand varnames and indices, reset varspec
	m : mExpandVarspec(`"`using'"', `K', `pos', "`vnams'", "`idxs'")
	
	// return varlist from using
	ret sca chunks = `chunks'
	ret sca k = `K'
	ret loc varlist `varlist'
	if (`chunks' > 1) {
		forv j = 1/`chunks' {
			ret loc varlist`j' `varlist`j''
		}
	}
	
	// s-options
	if ("`cmd'" != "") {
		preserve
		loc rc 0
		forv j = 1/`chunks' {
			qui u `varlist`j'' using `"`using'"' ,clear
			qui `cmd' ,`options'
			loc addvars `addvars' `r(varlist)'
			if ("`not'" != "") loc varspec : list varspec - addvars
			else loc varspec : list varspec | addvars
		}
		restore
	}
	
	// return varspec
	ret loc varspec `varspec'
	
	// output and load subset of dataset
	loc nvarspec : word count `varspec'
	
	di as txt _n "File: " as res `"`using'"'
	di as txt "vars: " as res _col(7) `nvarspec' "/" `K'
	
	if !(`nvarspec') err 102
	if (`nvarspec' >= c(maxvar)) err 900
	
	if ("`in'" != "") loc in in `in'
	
	preserve
	qui u `varspec' using `"`using'"' `if' `in' ,clear `label'
	restore ,not
end

pr ParseVarspec
	syntax [anything(name = varspec)] , k(numlist) ///
	varnames(name local) indices(name local)
	
	// split varspec
	while ("`varspec'" != "") {
		gettoken var varspec : varspec ,m(par)
		
		// varnames
		if ("`par'" == "") {
			if ("`var'" == "-") {
				gettoken var varspec : varspec
				foreach x in ~ ? * {
					if (strpos("`prev'", "`x'") | ///
					strpos("`var'", "`x'")) {
						di as err "- invalid name"
						e 198
					}
				}
				loc `varnames' ``varnames''-`var'
			}
			else loc `varnames' ``varnames'' `var'
			loc prev `var'
			continue
		}
		
		// indices
		loc var = stritrim(lower("`var'"))
		loc hask = strpos("`var'", "k")
		if (`hask') {
			loc var : subinstr loc var "k" "`k'" ,all
			loc done = !(strpos("`var'", "-") | strpos("`var'", "*"))
			if !(`done') {
				foreach ch in - * {
					loc var : subinstr loc var "`ch' " "`ch'" ,all
					loc var : subinstr loc var " `ch'" "`ch'" ,all
				}
				token `var' ,p(" /:()[]")
				loc var
				loc j = 0
				while ("``++j''" != "") {
					if (strpos("``j''", "-") | strpos("``j''", "*")) {
						loc var `var' `= ``j'''
					}
					else loc var `var' ``j''
				}
			}
		}
		numlist "`var'" ,int r(>0 <=`k')
		loc `indices' ``indices'' `r(numlist)'
	}
	
	c_local `varnames' ``varnames''
	c_local `indices' ``indices''
end

vers 10.1
m :
void mExpandVarspec(string scalar fn, 
					real scalar K, 
					real scalar pos,
					string scalar vars,
					string scalar inds)
{
	string rowvector varlist, vnams
	real rowvector idxs, m1, m2, m, mtch
	real scalar dsh
	string scalar varspec
	
	varlist = mGetVarlist(fn, K, pos)
	
	vnams = tokens(vars)
	idxs = strtoreal(tokens(inds))
	mtch = J(1, cols(varlist), 0)
	
	// user varnames
	for (i = 1; i <= cols(vnams); ++i) {
		dsh = strpos(vnams[1, i], "-")
		if (dsh) {
			m1 = mExpandTok(substr(vnams[1, i], ///
			1, (dsh - 1)), varlist, fn)
			m2 = mExpandTok(substr(vnams[1, i], ///
			(dsh + 1), .), varlist, fn)
			m1 = select(J(1, 1, (1..cols(m1))), (m1 :== 1))
			m2 = select(J(1, 1, (1..cols(m2))), (m2 :== 1))
			if (m2 < m1) {
				errprintf("%s \n", "variables out of order")
				exit(111)
			}
			mtch[1, (m1..m2)] = J(1, (1 + m2 - m1), 1)
		}
		else {
			m = mExpandTok(vnams[1, i], varlist, fn)
			mtch = mtch + m
		}
	}
	
	// user indices
	if (cols(idxs)) mtch[1, idxs] = J(1, cols(idxs), 1)
	
	// select
	if (st_local("not") != "") mtch = !(mtch)
	varspec = invtokens(select(varlist, mtch))
	
	if (strlen(varspec) > c("max_macrolen")) {
		errprintf("%s \n", "macro length exeeded")
		exit(1000)
	}
	
	st_local("varspec", varspec)
}

real rowvector mExpandTok(string scalar usr, 
							string rowvector lst,
							string scalar fn)
{
	real scalar tld, qmk, ast
	real rowvector m
	string scalar tok
	
	tld = strpos(usr, "~")
	qmk = strpos(usr, "?")
	ast = strpos(usr, "*")
	
	if (tld) {
		if (any((qmk, ast))) {
		errprintf("%s \n",  "may not combine ~ and *-or-? notation")
			exit(198)
		}
		tok = subinstr(usr, "~", "*")
	}
	else tok = usr
	
	m = strmatch(lst, tok)
	
	if (!(any(m))) {
		if (any((tld, qmk, ast))) {
	errprintf("no variables found matching %s in file %s \n" ,usr, fn)
			exit(111)
		}
		m = strmatch(lst, tok + "*")
		if (!(any(m))) {
			errprintf("variable %s not found in file %s \n", usr, fn)
			exit(111)
		}
		tld = 1
	}
	if ((tld) & (rowsum(m) > 1)) {
errprintf("%s matches more than one variable in file %s \n", usr, fn)
		exit(111)
	}
	
	return(m)
}

string rowvector mGetVarlist(string scalar fn, 
							real scalar K, 
							real scalar pos)
{
	string rowvector varlist
	real scalar chnks, chnk, p1, p2
	
	varlist = J(1, K, "")
	
	// get varnames from filename
	fh = fopen(fn, "r")
	fseek(fh, pos, -1)
	for (i = 1; i <= K; ++i) {
		varlist[1, i] = fread(fh, 33)
	}
	varlist = substr(varlist, 1, strpos(varlist, char(0)) :- 1)
	fclose(fh)
	
	// split varlist
	chnk = c("maxvar") - 1
	chnks = ceil(K / chnk)
	if (chnks > 1) {
		p1 = 1
		p2 = chnk
		for (i = 1; i <= chnks; ++i) {
			st_local("varlist" + strofreal(i), ///
			invtokens(varlist[1, (p1..p2)]))
			p1 = p1 + chnk
			if (i == (chnks - 1)) p2 = K
			else p2 = p2 + chnk
		}
	}
	else st_local("varlist", invtokens(varlist))
	st_local("chunks", strofreal(chnks))
	
	return(varlist)
}

void mGetUsingK(string scalar fn, 
				string scalar Knam, 
				string scalar pnam)
{
	real scalar fnfmt812, hilo, K, pos
	string rowvector Khex, poshex
	
	// check dta suffix
	if (pathsuffix(fn) == "") fn = fn + ".dta"
	if (pathsuffix(fn) != ".dta") exit(error(610))
	
	// check file exists
	fh = _fopen(fn, "r")
	if (fh < 0) exit(error(fh * (-1)))
	
	// file format
	fnfmt812 = (anyof(("71", "72", "73"), /// 
	inbase(16, ascii(fread(fh, 1)))))
	
	// get byteorder and number of variables
	if (fnfmt812) {
		hilo = (ascii(fread(fh, 1)) == 1)
		fseek(fh, 4, -1)
		Khex = inbase(16, ascii(fread(fh, 2)))
	}
	else {
		fseek(fh, 52, -1)
		hilo = (fread(fh, 1) == "M")
		fseek(fh, 70, -1)
		Khex = inbase(16, ascii(fread(fh, 2)))
		fseek(fh, 182, -1)
		poshex = inbase(16, ascii(fread(fh, 4)))
	}
	
	if (!(hilo)) Khex = Khex[1, cols(Khex)..1]
	if (Khex[1, 2] == "0") Khex[1, 2] = "00"
	K = frombase(16, Khex[1, 1] + Khex[1, 2])
	
	if (!(fnfmt812)) {
		if (!(hilo)) poshex = poshex[1, cols(poshex)..1]
		for (i = 2; i <= cols(poshex); ++i) {
			if (poshex[1, i] == "0") poshex[1, i] = "00"
			poshex[1, 1] = poshex[1, 1] + poshex[1, i]
		}
		pos = frombase(16, poshex[1, 1]) + 10
	}
	else pos = 109 + K
	
	// return to Stata locals
	st_local("using", fn)
	st_local(Knam, strofreal(K))
	st_local(pnam, strofreal(pos))
	
	fclose(fh)
}
end
e

1.2.0	22dec2013	Mata gets varlists from filename
					abbreviations allowed in varspec
					new -if()- option
					program rclass
					fix bug all types of numlists allowed in varspec
					compatible with Stata 13 dta format 117
					"k" is case-insensitive
1.1.1	22apr2012	may multiply "k"
1.1.0	23mar2012	"k" may be used in varspec
1.0.0	09feb2012	first release on SSC
