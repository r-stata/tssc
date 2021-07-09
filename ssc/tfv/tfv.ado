*! version 1.1.0 16mar2014 Daniel Klein

/*
	tfv -- Transformations of variables
	
	Syntax
	
		tfv [, <options> ] [:] [<cmd> | <tfvterm> [<tfvterm> ...]]
		
		
	Transformations (<tfvterm>) are one of
		
		(1) t(<fcn>).varname
		(2) t.(<expr>)
		
		(3) t<fcn>.varname
		(4) t.<expr>
		
	(3) and (4) are not documented
	
	So to get the square root of varname we can code
		
		t(sqrt).varname
		
	or (2)
		t.(sqrt(varname))
		
	or (3)
		tsqrt.varname
		
	or (4)
		t.sqrt(varname)
	
	
	Factor variable operators are specified before the t. operator
	
		tfv reg t(ln).wage c.t.(hours/100)##c.t.(hours/100) i.t.(race - 1)
		
	
	With syntaxes (3) and (4) even this is allowed
		
		tfv reg tln.wage c.t.hours/100##c.t.hours/100 i.t.race-1
		
	(note no blanks in <expr>)
		
*/

pr tfv ,sclass
	vers 11.2
	
	tempname rres
	cap _ret hold `rres'
	sret loc tfvvarlist
	
	loc call : copy loc 0
	
	// tfv command
	cap unabcmd `call'
	if !(_rc) {
		TfvCmd `r(cmd)'
		e 0 // done
	}
	
	// tfv options
	gettoken cc : call ,p(",:")
	if inlist(`"`cc'"', ",", ":") {
		if (`"`cc'"' == ",") {
			gettoken opts call : call ,p(":")
			loc 0 : copy loc opts
			TfvOpts `opts'
		}
		gettoken col call : call ,p(":")
		loc 0 : copy loc call
	}
	
	// set locals
	loc Ctfv 0 // count (new) tfv terms
	loc Cnam 0 // count names
	loc Cndt 0 // no dot in token
	loc exit e 0
	
	// create transformations of variables
	while (`"`0'"' != "") {
		gettoken tok 0 : 0 ,p(" .")
		if (`"`tok'"' != ".") {
			loc bfr : copy loc tok
			loc ++Cndt
			if (`Cndt' > 1) | (`"`0'"' == "") {
				loc exit
			}
			continue
		}
		
		gettoken t bfr : bfr ,p("Tt")
		if (strlower(`"`t'"') != "t") continue
		loc Cndt 0
		
		gettoken vn_or_xp 0 : 0 ,p(" #") m(p)
		if ("`p'" == "(") loc p2 ")"
		else loc p2
		if (`"`bfr'"' != "") { // t(<fcn>).varname
			fvunab unabvarn : `vn_or_xp'
			gettoken fcn : bfr ,m(p)
			if ("`p'" == "(") loc p2 ")"
			loc tusr `t'`p'`fcn'`p2'.`vn_or_xp'
			loc expr `fcn'(`unabvarn')
		}
		else { // t.(<expr>)
			loc tusr `t'.`p'`vn_or_xp'`p2'
			loc expr : copy loc vn_or_xp
		}
		
		// variable names
		loc ++Cnam
		loc tnam : word `Cnam' of `generate'
		if ("`stub'"!= "") loc tnam `stub'`Cnam'
		if ("`tnam'" == "") {
			loc tnam = strtoname(stritrim(`"`expr'"'))
			loc us 1
			while (`us') {
				loc tnam : subinstr loc tnam "__" "_" ///
				,all c(loc us)
			}
			loc lent : length loc tnam
			if (substr("`tnam'", `lent', .) == "_") {
				loc tnam = substr("`tnam'", 1, `lent' - 1)
			}
		}
		loc tusr`tnam' `"`tusr`tnam'' "`tusr'""'
		
		// substitution
		loc call : ///
		subinstr loc call `"`tusr'"' "`tnam'" ,all
		
		if (`: list tnam in tnams') continue
		
		loc ++Ctfv
		cap conf new v `tnam'
		loc dropt`Ctfv' = (_rc)
		if (_rc) {
			if (`"`: char `tnam'[_istfv]'"' != "true") ///
			| ("`protect'" != "") {
				di as err "`tnam' already defined"
				e 110
			}
		}
		loc tnams `tnams' `tnam'
		
		// create temporary transformed variables
		cap _ret res `rres'
		tempvar tmp`Ctfv'
		qui g `type' `tmp`Ctfv'' = `expr'
		la var `tmp`Ctfv'' `"`expr'"'
	}
	
	// no tfvterms
	if !(`Ctfv') di as txt "(note: no {it:tfvterms})"
	
	// create final variables
	token `tnams'
	forv t = 1/`Ctfv' {
		if (`dropt`t'') drop ``t''
		ren `tmp`t'' ``t''
		char ``t''[_istfv] true
		foreach tusr of loc tusr``t'' {
			di as txt "`tusr'" _col(34) "``t''" 
		}
	}
	
	// return variable names and set characteristics
	sret loc tfvvarlist `tnams'
	loc _dta_tfv_varlist : char _dta[_tfv_varlist] 
	loc tfv_varlist : list _dta_tfv_varlist | tnams
	char _dta[_tfv_varlist] `tfv_varlist'
	
	// no command
	`exit'
	
	// execute cmd
	`call'
end

pr TfvCmd
	args cmd
	loc varlist : char _dta[_tfv_varlist]	
	if ("`cmd'" == "drop") {
		foreach tfv of loc varlist {
			cap conf v `tfv'
			if !(_rc) {
				if ("`: char `tfv'[_istfv]'" == "true") {
					drop `tfv'
				}
			}
			loc dropped `dropped' `tfv'
		}
		char _dta[_tfv_varlist] `: list varlist - dropped'
	}
	else `cmd' `varlist'
end

pr TfvOpts
	syntax [ , ///
	Generate(namelist) STUB(name) Type(str) ///
	noReplace Protect DROP ]
	
	if ("`replace'" != "") loc protect protect
	if ("`generate'" != "") & ("`stub'" != "") {
		di as err "generate and stub not both allowed"
		e 198
	}
	if ("`drop'" != "") {
		if ("`protect'" != "") {
			di as err "option drop not allowed"
			e 198
		}
		TfvCmd drop
	}
	
	c_local generate : copy loc generate
	c_local stub : copy loc stub
	c_local type : copy loc type
	c_local protect : copy loc protect
end
e

1.1.0	16mar2014	hold r() results
					new syntax allows options
					version on SSC
1.0.0	05mar2014	first draft
