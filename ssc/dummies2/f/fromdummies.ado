* version 1.0.4 24jul2012 Daniel Klein

pr fromdummies
	vers 10.1
	
	syntax varlist(num) [if][in] , Generate(name) ///
	[ NAMes NOVALLabel VALLabel(name) VARLabel(str) force REFerence ]
		// force is no longer documented
	
	marksample touse
	qui cou if `touse'
	if !(r(N)) err 2000
	
	// check new name
	conf new v  `generate'
	
	// value label
	if ("`novallabel'" != "") {
		foreach opt in names vallabel {
			if ("``opt''" != "") {
				di as err "novallabel may not be combined with `opt'"
				e 198
			}
		}
	}
	if ("`novallabel'" == "") {
		if ("`vallabel'" == "") loc vallabel `generate'
		cap la li `vallabel'
		if !(_rc) {
			di as err "label `vallabel' already defined"
			e 110
		}
	}
	
	// varlist
	token `varlist'
	loc nvars : word count `varlist'
	
	// check dummies
	if ("`reference'" != "") loc force force
	mata : mfromdummiesck("`varlist'", "`touse'", "`force'")
	if ("`rc'" != "") {
		di as err "`rc'"
		e 459
	}
	
	// create categorical variable
	tempvar tmp
	qui g `tmp' = `= `nvars' + 1' if `touse'
	forv j = 1/`nvars' {
		qui replace `tmp' = `j' if (``j'') & `touse'
		
		// value label definition
		if ("`novallabel'" == "") {
			if ("`names'" != "") {
				loc def `def' `j' "``j''"
				continue
			}
			loc txt : var l ``j''
			if (`"`macval(txt)'"' == "") {
				loc def `def' `j' "``j''"
				continue
			}
			if strpos(`"`macval(txt)'"', `"""') {
				loc def `def' `j' `"`txt'"'
			}
			else loc def `def' `j' "`txt'"
		}
	}
	
	// add no category label
	cap as `tmp' != `= `nvars' + 1'
	if (_rc) & ("`novallabel'" == "") {
		loc def `def' `= `nvars' + 1' "reference"
	}
	
	// now make it final
	nobreak {
		qui {
			g `generate' = `tmp'
			compress `generate'
		}
		
		cap conf e `def'
		if !(_rc) {
			la de `vallabel' `def'
			la val `generate' `vallabel'
		}
		
		if (`"`macval(varlabel)'"' != "") {
			if strpos(`"`macval(varlabel)'"', `"""') {
				la var `generate' `"`varlabel'"'
			}
			else la var `generate' "`varlabel'"
		}
	}	
end

vers 10.1
mata :
void mfromdummiesck(string scalar vars, 
					string scalar tu,
					string scalar force)
{
	real matrix X, C
	
	X = st_data(., tokens(vars), tu)
	C = (X :== 0) + (X :== 1)
	if (anyof(C, 0)) {
		for (i = 1; i <= cols(C); ++i) {
			if (anyof(C[., i], 0)) {
				st_local("rc", "`" + strofreal(i) ///
				+ "'" + " not a binary variable")
				break
			}
		}
	}
	else {
		if (force == "force") {
			if (any(rowsum(X) :> 1)) {
				st_local("rc", "dummies are not mutually exclusive")
			}
		}
		else if (!allof(rowsum(X), 1)) {
			st_local("rc", "dummies are not mutually exclusive")
		}
	}
}
end
e

1.0.4	24jul2012	new coding for reference category
					option -force- renamed -reference-
					specifying onyl one dummy is allowed
1.0.3	23jul2012	declare version 10.1 (package with todummies)
1.0.2	05jun2012	new options
					temporary variable
1.0.1	17mar2012	check dummies before creating categorical variable
1.0.0	03feb2012
