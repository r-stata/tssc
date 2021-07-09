*! version 1.0.2 18mar2011 Daniel Klein
* 	1.0.1 add -mvc- option
*	1.0.2 make program r-class

prog genicv ,rclass
	version 11.1
	
	syntax varlist(numeric min = 2 max = 3) [if][in] ///
	[ ,REPLACE X(string) SEPvars(name) MVC(numlist miss max = 1) ///
	Local(name local)]
	
/*check chm-option*/
	if "`mvc'" != "" {
		if  `mvc' <= . {
			di "{err}{bf:mvc()} should be hard missing (.a, ..., .z)"
			exit 498
		}
		loc novar novar
	}
	if "`local'" == "" loc local icv
	
/*check observations*/
	marksample touse ,`novar'
	qui count if `touse'
	if r(N) == 0 err 2000	
	
	if `"`x'"' == "" local x "*"
	if "`sepvars'" == "" local sepvars "_"
	
	local nvars : word count `varlist'
	local nvars1 = `nvars' - 1
/*reorder varlist*/
	if `: list posof "`: list dups varlist'" in varlist' == 1 ///
		& `: word 1 of `varlist'' != `: word 2 of `varlist'' {
			local uneq : word 2 of `varlist'
			local varlist : list varlist - uneq
			local varlist `varlist' `uneq'
	}
	
/*get varnames and labels*/
	forval j = 1/`nvars' {
		local var`j' : word `j' of `varlist'
		local lbl`j' : var l `var`j''
		local chkmaxlen `chkmaxlen'`var`j''
	}
	if length("`chkmaxlen'") > 32 - `nvars1' * length("`sepvars'") {
		di "{err}new name has more than 32 characters"
		exit 198
	}
	
/*create interactions if valid names*/
	tempname tmp_mvc
	local i 1
	forval j = 1/`nvars1' {
		local ++i
		forval k = `i'/`nvars' {
			if "`var`j''" == "`var`k''" local tmp_nam `var`j''2
			else local tmp_nam `var`j''`sepvars'`var`k''
			cap conf new var `tmp_nam'
			if !_rc {
				if "`mvc'" != "" {
					qui g `tmp_mvc' = (mi(`var`j'') & `var`j'' != .) ///
						| (mi(`var`k'') & `var`k'' != .)
				}
				qui g `tmp_nam' = `var`j'' * `var`k'' if `touse'
				if "`mvc'" != "" {
					qui replace `tmp_nam' = `mvc' if `tmp_mvc' & `touse'
					drop `tmp_mvc'
				}
				local ncvars `"`ncvars' ,"`tmp_nam'""'
				loc `local' ``local'' `tmp_nam'
			}
			else {
				if "`replace'" == "" {
					if !inlist("`tmp_nam'" ,""`ncvars') ///
						di "{res}`tmp_nam' {txt}already defined"
					continue
				}
				else {
					if "`mvc'" != "" {
						qui g `tmp_mvc' = (mi(`var`j'') & `var`j'' != .) ///
							| (mi(`var`k'') & `var`k'' != .)
					}
					qui replace `tmp_nam' = `var`j'' * `var`k'' ///
						if `touse'
					if "`mvc'" != "" {
						qui replace `tmp_nam' = `mvc' if `tmp_mvc' & `touse'
						drop `tmp_mvc'
					}
					loc `local' ``local'' `tmp_nam'
				}
			}
/*label variables*/
			if "`lbl`j''" != "" & "`lbl`k''" != "" {
				if "`lbl`j''" == "`lbl`k''" local tmp_lbl "`lbl`j'' squared"
				else local tmp_lbl "`lbl`j'' `x' `lbl`k''"
				lab var `tmp_nam' "`tmp_lbl'"
			}
		}
	}
/*add triple*/
	if `nvars' == 3 {
		if `: word count `: list dups varlist'' == 2 local tmp_nam `var1'3
		else if "`var1'" == "`var2'" local tmp_nam `var3'`sepvars'`var1'2
		else if "`var2'" == "`var3'" local tmp_nam `var1'`sepvars'`var2'2
		else local tmp_nam `var1'`sepvars'`var2'`sepvars'`var3'
		cap conf new var `tmp_nam'
		if !_rc {
			if "`mvc'" != "" {
					qui g `tmp_mvc' = (mi(`var1') & `var1' != .) ///
						| (mi(`var2') & `var2' != .) ///
						| (mi(`var3') & `var3' != .)
			}
			qui g `tmp_nam' = `var1' * `var2' * `var3' if `touse'
			if "`mvc'" != "" {
				qui replace `tmp_nam' = `mvc' if `tmp_mvc' & `touse'
				drop `tmp_mvc'
			}
			local skplbl 0
			loc `local' ``local'' `tmp_nam'
		}
		else {
			if "`replace'" == "" {
				di "{res}`tmp_nam' {txt}already defined"
				local skplbl 1
			}
			else {
				if "`mvc'" != "" {
						qui g `tmp_mvc' = (mi(`var1') & `var1' != .) ///
							| (mi(`var2') & `var2' != .) ///
							| (mi(`var3') & `var3' != .)
				}	
				qui replace `tmp_nam' = `var1' * `var2' * `var3' if `touse'
				if "`mvc'" != "" {
					qui replace `tmp_nam' = `mvc' if `tmp_mvc' & `touse'
					drop `tmp_mvc'
				}				
				local skplbl 0
				loc `local' ``local'' `tmp_nam'
			}
		}
		if !`skplbl' & "`lbl1'" != "" & "`lbl2'" != "" & "`lbl3'" != "" {
			if "`lbl1'" == "`lbl2'" & "`lbl1'" == "`lbl3'" ///
				local tmp_lbl "`lbl1' cubic"
			else if "`lbl1'" == "`lbl2'" local tmp_lbl "`lbl3' `x' `lbl1' squared"
			else if "`lbl2'" == "`lbl3'" local tmp_lbl "`lbl1' `x' `lbl2' squared"
			else local tmp_lbl "`lbl1' `x' `lbl2' `x' `lbl3'"
			lab var `tmp_nam' "`tmp_lbl'"
		}
	}
	ret loc `local' ``local''
end
