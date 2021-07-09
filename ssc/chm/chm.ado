*! version 1.0.7 27nov2011 Daniel Klein

pr chm ,by(o)
	vers 9.2

	* parse user input
	gettoken chmcall usercmd : 0 ,p(:)
	if (`"`chmcall'"' == ":") {
		di as err "varlist required"
		e 100
	}
	
		// command or prefix
	if (`"`chmcall'"' == `"`0'"') {
		
			// command
		loc iscmd 1
		loc ifin [if] [in]
		loc replace_opt REPLACE
		loc mi_opt MI
	}
	else {
	
			// prefix
		loc iscmd 0
		loc usercmd : subinstr loc usercmd ":" ""
		if (`"`usercmd'"' == "") {
			di as err "command required"
			e 100
		}
		unabcmd `: word 1 of `usercmd''
		loc cmd `r(cmd)'
		loc supported generate egen replace tabulate center
		if !(`: list cmd in supported') loc support 0
		else loc support 1
	}
	
	* parse args in standard syntax
	if _by() loc _byc by `_byvars' `_byrc0' :
	loc 0 `chmcall'
	
	syntax varlist(numeric) `ifin' , `replace_opt' /*
	*/ [ MVC(numlist miss max = 1) SOFT SYSmiss EXECute `mi_opt' ]
	
	* options
	if (`iscmd') & ("`mi'" == "") & (`: word count `varlist'' < 2) {
		err 102
	}
	
	if ("`mvc'" != "") {
		if (real("`mvc'") <= .) {
			di as err "{it:mvc} must be one of .a, .b, ..., .z"
			e 198
		}
	}
	
	if ("`sysmiss'" != "") loc soft soft
	
	if !(`iscmd') {
		if !(`support') {
			if ("`execute'" == "") {
				di as err "`cmd' currently not supported"
				e 101
			}
			di as txt "(note: `cmd' currently not supported)"
		}
	}
	
	* pass on to mi-subroutine
	if ("`mi'" != "") {
		_chmmidta `varlist' `if' `in' ,mvc(`mvc') `soft' by(`_byc')
		e 0 // done
	}
	else loc chmvars `varlist'

	* some settings
	if (`iscmd') {
		loc cpyto : word `: word count `chmvars'' of `chmvars'
		loc chmvars : list chmvars - cpyto
		
		* mark sample
		marksample touse ,nov
		qui cou if `touse'
		if (r(N) == 0) err 2000
	}
	else {
		loc 0 `usercmd'
		syntax [anything(equalok)] [if][in] [fw aw iw] [ , *]
			// weights not used by chm but not an error
		
		* mark sample
		marksample touse ,nov
		qui cou if `touse'
		if (r(N) == 0) err 2000
		
		loc cmd_ok 0
		
			// generate and egen
		if (inlist("`cmd'", "generate", "egen")) {
			loc cmd_ok 1
			gettoken new_var : usercmd ,p("=")
			if (strpos("`new_var'", ":")) {
				gettoken new_var : new_var ,p(":")
			}
			loc cpyto : word `: word count `new_var'' of `new_var'
		}
	
			// replace
		if ("`cmd'" == "replace") {
			tempname tmp_old	
			loc cmd_ok 1
			gettoken old_var : usercmd ,p("=")
			loc cpyto : word 2 of `old_var'
			qui g `: t `cpyto'' `tmp_old' = `cpyto'
			loc chmvars : list chmvars - cpyto
			loc chmvars `chmvars' `tmp_old'
		}

			// tabulate
		if ("`cmd'" == "tabulate") {
			loc cmd_ok 1
			loc 0 ,`options'
			syntax ,Generate(name) [ * ]
			loc stubname `generate'
		}
		
			// center
		if ("`cmd'" == "center") {
			loc cmd_ok 1
			loc anything : list anything - cmd
			loc 0 `anything' ,`options'
			syntax varlist [, Generate(string) PREfix(string) *]
			if ("`generate'" != "") loc cpyto `generate'
			else {
				if ("`prefix'" == "") loc prefix c_
				foreach center_var of loc varlist {
					loc cpyto `cpyto' `prefix'`center_var'
				}
			}
		}
		
		* excecute command
		`_byc' `usercmd'
		
		* command not supported
		if !(`support') e 101 // done
	
		* get cpyto if command is -tabulate-
		if ("`cmd'" == "tabulate") {
			forv j = 1/`r(r)' {
				loc cpyto `cpyto' `stubname'`j'
			}
		}
		
		* check numeric variable
		if inlist("`cmd'", "generate", "egen", "replace") {
			cap conf numeric v `cpyto'
			if _rc {
				if inlist("`cmd'", "generate", "egen") drop `cpyto'
				if ("`cmd'" == "replace") qui replace `cpyto' = `tmp_old'
				di as err "string variables not allowed with chm"
				e 109
			}
		}
	}
	
	* copy hard missings
	foreach v of loc chmvars {
		foreach c of loc cpyto {
			loc m_v_c = cond("`mvc'" != "", "mvc", "v")
			if ("`soft'" == "") loc nosoft & (`v' != .)
			qui `_byc' replace `c' = ``m_v_c'' /*
				*/ if !inrange(string(`c'), ".a", ".z") /*
				*/ & mi(`v') `nosoft' & `touse'
		}
	}	
end

prog _chmmidta

	* check mi data
	if ("`_dta[mi_id]'" == "_mi") {
		loc _miid _mi
		loc _mim _mj
	}
	else {
		u_mi_assert_set flong
		loc _miid _mi_id
		loc _mim _mi_m
	}
	
	syntax varlist [if][in] [, MVC(numlist miss) SOFT by(str)]
	
	* mark sample
	marksample touse ,nov
	qui replace `touse' = 0 if `_mim' == 0
	qui cou if `touse'
	if (r(N) == 0) err 2000
	
	* set locals
	if ("`soft'" != "") loc eq "="
	if ("`mvc'" != "") loc _mvc `mvc'
	
	foreach v of loc varlist {
		if ("`mvc'" == "") {
			qui levelsof `v' if (`v' >`eq' .) ,miss loc(_mvc)
			if (`: word count `_mvc'' == 0) continue
		}
		foreach _mv of loc _mvc {
			if ("`mvc'" == "") {
				qui levelsof `_miid' if (`v' == `_mv') ,loc(id2c)
			}
			else {
				qui levelsof `_miid' if (`v' >`eq' .) ,loc(id2c)
				if (`: word count `id2c'' == 0) continue
			}
			if (`: word count `id2c'' <= 249) {
				loc id2c : subinstr loc id2c " " "," ,all
				qui `by' replace `v' = `_mv' /*
				*/ if inlist(`_miid', `id2c') & `touse'
			}
			else {
				foreach id of loc id2c {
					qui `by' replace `v' = `_mv' /*
					*/ if (`_miid' == `id') & `touse'
				}
			}
		}
	}
end
e


History

1.0.7	27nov2011	clean code
					check fatal conditions earlier
					preserve double variables
					remove subroutine -errex-
					option -execute- no longer documented
1.0.6	11jun2011	-by- supports -rc0- option
					-sysmiss- as synonym for -soft- (not documented)
1.0.5	03jun2011	add -mi- option and subroutine
					downward compatibility with Stata 9.2
					change check commands (use unabcmd)
1.0.4	01apr2011	change check commands
1.0.3		na		fixed bug (missing -marksample-)
1.0.2 		na		add -center- command and -execute- option
					minor changes in error messages
1.0.1		na		do no longer run command quietly
