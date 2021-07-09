*! version 1.0.0 11nov2011 Daniel Klein

pr labmvs9
	vers 9.2

	syntax [varlist] [if] [in] , mv(str asis) /*
	*/ [ /*
	*/ ALLvars /*
	*/ CASEsensitive /*
	*/ noDELete /*
	*/ Fmvc(numlist int miss max = 1) /*
	*/ ]
	
	marksample touse ,nov
	qui cou if `touse'
	if (r(N) == 0) err 2000
	
	* first mvc
	loc nstr : word count `mv'
	loc abc `c(alpha)' // needed in list
	if !inlist("`fmvc'", "", ".a") {
		if (`fmvc' < .b) {
			di as err "option fmvc() -- must be one of .a, .b ..., .z"
			e 125
		}
		loc first : list posof "`= substr("`fmvc'", 2, .)'" in abc
		
		* check numlist
		if (`nstr' > 26 - (`first' - 1)) {
			di as err "option mv() -- too many {it:strings} specified"
			e 198
		}
	}
	else loc first 1
	
	* get lblname-list
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
	
	* allvars
	if ("`allvars'" ! = "") & (`: word count `varlist'' < c(k) - 1) {
		foreach v of varlist * {
			if (`: list v in varlist') continue
			loc lab : val l `v'
			if ("`lab'" == "") | /*
			*/ !(`: list lab in lblnamelist') continue
			loc `lab' ``lab'' `v'
		}
	}
	
	* option casesensitive
	if ("`casesensitive'" == "") {
		loc low low
		loc mv = lower(`"`mv'"')
	}
	
	* load value label information
	preserve
	uselabel `lblnamelist' ,clear
	
		// no tempvars needed; dataset is deleted anyway
	qui {
		g byte emvc = 0
		if ("`casesensitive'" == "") g lowlabel = lower(label)
		
		* flag matches (and change labels)
		loc i `first'
		forv j = 1/`nstr' {
			replace emvc = .`: word `first' of `c(alpha)'' /*
			*/ if strmatch(`low'label, "`: word `j' of `mv''") /*
			*/ & !mi(emvc)
			loc ++first
		}
		cap drop lowlabel
		
		* create definitions
		keep if emvc
		if c(N) == 0 e 0 // done
		
		g def = lname + " " + string(value) + " " /*
		*/ + string(emvc) + " " /*
		*/ + char(96) + char(34) + label + char(34) + char(39)
		levelsof def ,l(def)
		drop def
	}
	restore
	
	* modify value labels
	foreach d of loc def {
	
			// d is: <lblname> <value> <mvc> <label>
		tokenize `d'
		
		loc varl `varl' ``1''
		foreach v of loc `1' {
			qui cou if mi(`v') & `touse'
			loc nmis = r(N)
			qui replace `v' = `3' if `v' == `2' & `touse'
			qui cou if mi(`v') & `touse'
			loc dif = r(N) - `nmis'
			if ("`nch`v''" == "") loc nch`v' `dif'
			else loc nch`v' = `nch`v'' + `dif'
		}
		if ("`delete'" == "") la de `1' `2' "" `3' `"`4'"' ,modify
		else la de `1' `3' `"`4'"' ,modify
	}
	
	* show changes
	loc varl : list uniq varl
	foreach v of loc varl {
		di as txt "(" as res "`v'" as txt ": `nch`v'' " /*
		*/ `"`= plural(`nch`v'', "change")' made)"'
	}
end
