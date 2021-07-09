*! version 1.0.1 19apr2011 Daniel Klein
*	1.0.1	fix typo in _ft_clear (missing "loc")
*			add clear s(_false#_)
*			add parenthesis to conditions

prog filtertrace ,sclass 
	version 11.2
	
	/*checkset
	-----------*/
	if "`s(_nfifl_)'" == "" sret loc _nfifl_ 0 
	
	/*select subroutine
	--------------------*/
	loc _abbrev = length("`1'")
	loc 0 : list 0 - 1
	if `"`1'"' == "" _ft_list
	else if `"`1'"' == substr("define", 1, `_abbrev') _ft_def `0'
	else if `"`1'"' == substr("check", 1, `_abbrev') _ft_chk `0'
	else if `"`1'"' == substr("import", 1, `_abbrev') _ft_imp `0'
	else if `"`1'"' == substr("export", 1, `_abbrev') _ft_exp `0'
	else if inlist(`"`1'"', "clear", "drop") _ft_clear `1' `0'
	else _mess unrec `"`1'"'
end


/*filtertrace check 
--------------------*/
prog _ft_chk ,sclass
	if `s(_nfifl_)' == 0 {
		_mess nofifl
		exit 0
	}
	
	syntax anything(id = "varlist (filter#) [exp]" equalok) ///
	[, Generate(name) FULLexp noFlag]
	
	/*get options as syntax is used again later
	--------------------------------------------*/
	loc fullexp `fullexp'
	loc flag `flag'
		
	/*return user _con
	-------------------*/
	if "`generate'" != "" {
		if "`flag'" != "" _mess notboth generate noflag
		loc _tmp `s(_user_con_hist_)'
		if "`_tmp'" != "" {
			if !`: list posof "`generate'" in _tmp' ///
				loc _tmp "`_tmp' `s(_user_con_hist_)'"
		}
		else loc _tmp `generate'
		sret loc _user_con_hist_ "`_tmp'"
		sret loc _user_con_ "`generate'"
	}
	
	/*set con if generate not specified
	------------------------------------*/
	if "`generate'" == "" & "`flag'" == "" loc generate _con
	
	/*get vfes
	-----------*/
	loc i 0
	while `"`anything'"' != "" {
		gettoken vfe`++i' anything : anything ,p(;)
		gettoken sep anything : anything ,p(;)
	}

	/*check condtions
	------------------*/
	tempvar contra
	/*borrowed from Krishnan Bhaskaran (datacheck.ado)*/
	tempname M
	loc cnt 0
	
	forval j = 1/`i' {
	
		/*check some input errors
		--------------------------*/
		if !strmatch(`"`vfe`j''"', "*(*)*") _mess invvfc `"`vfe`j''"'
		gettoken vars rest : vfe`j' ,p("(")
		gettoken fifl cnd : rest ,match(m)
		
		/*set cnd
		----------*/
		if `"`cnd'"' == "" loc cnd != .
		
		/*check fifl
		-------------*/
		if strmatch("`fifl'", "*T*") | strmatch("`fifl'", "*t*") {
			loc true 1
			foreach t in T t {
				loc fifl : subinstr loc fifl "`t'" " " ,all
			}
		}
		else loc true 0
		cap numlist "`fifl'" ,int range(>0 <=`s(_nfifl_)')
		if _rc _mess invnum filter `"`vfe`j''"'
		loc flist `r(numlist)'
		
		/*check vars
		-------------*/
		if strmatch("`vars'", "*:*") {
			gettoken list vars : vars ,p(:)
			loc vars : subinstr loc vars ":" "" ,all
			if !strmatch("`vars'", "*@*") _mess noplc `"`vars'"'
			loc mm : word count `flist'
			cap numlist "`list'" ,int min(`mm') max(`mm')
			if _rc {
				if _rc != 121 _mess invnum list `"`vfe`j''"'
			}
			else loc list `r(numlist)'
			loc nelements : word count `list'
			if `mm' != `nelements' _mess invnum nlist `"`vfe`j''"'
			loc _sbs 1
		}
		else {
			loc list 1 //pseudo list
			loc _sbs 0
		}
			
		/*assert expressions
		---------------------*/
		loc cl 0
		foreach p of loc list { //extra loop over (pseudo) list
			if `_sbs' {
				loc _cpy_vars : subinstr loc vars "@" "`p'" ,all
				loc _cpy_flist : word `++cl' of `flist'
			}
			else {
				loc _cpy_vars `vars'
				loc _cpy_flist `flist'
			}
		/*no closing brace } here 
		also no tab stop hereafter 
		for readability reasons*/
	
		foreach var of varlist `_cpy_vars' {
			
			/*add varname or replace placeholders
			--------------------------------------*/
			if !strmatch(`"`cnd'"', "*@*") {
				if strmatch(`"`cnd'"', "*&*") | strmatch(`"`cnd'"', "*|*") ///
				_mess noplc `"`cnd'"'
				else loc _cpy_cnd `"(`var' `cnd')"'
			}
			else {
				loc _cpy_cnd : subinstr loc cnd "@" "`var'" ,all
				loc _cpy_cnd `"(`_cpy_cnd')"'
			}
			
			/*add not filter
			-----------------*/
			if !`true' {
				loc _not_cnd `"!(`_cpy_cnd')"'
				loc _toflist _cpy_cnd _not_cnd
			}
			else loc _toflist _cpy_cnd
			
			/*loop over filters
			--------------------*/
			di _n(2) "{txt}variable: {res}`var'" _n
			foreach fn of loc _cpy_flist {
				foreach tof of loc _toflist {
					if "`tof'" == "_not_cnd" {
						loc _not !
						loc _discol 6
					}
					else {
						loc _not
						loc _discol 7
					}
					di _col(`_discol')`"{res}`_not'{txt}({res}`fn'{txt})"'
					di _col(11) `"{txt}checking {res}``tof''"'
				
					/*mark the sample
					------------------*/
					loc 0 `s(_ifin`fn'_)'
					syntax [if][in]
					marksample touse
				
					/*assert
					---------*/
					cap as ``tof'' if `_not'(`s(_fltrflg`fn'_)') & `touse'
					if _rc {
						loc ++cnt
						cap drop `contra'
						qui g byte `contra' = !(``tof'') ///
						& `_not'(`s(_fltrflg`fn'_)') & `touse'
					
						/*report
						---------*/
						if "`tof'" == "_not_cnd" loc trfl false
						else loc trfl true
						qui ta `contra' ,matcell(`M')
						loc r = r(r)
						if `r' == 0 loc _tmp_c .
						else loc _tmp_c = `M'[`r' ,1]
						sret loc _ncon`cnt'_ `_tmp_c'
						sret loc _Ncon`cnt'_ = r(N)
						if "`fullexp'" != "" ///
							sret loc _cndcon`cnt'_ ///
							`"`_not'(`s(_fltrflg`fn'_)') & ``tof''"'
						else ///
							sret loc _cndcon`cnt'_ `"`_not'(`fn') & ``tof''"'
						di _col(11) `"{res}`_tmp_c'"' ///
						`" {txt}`=plural(`_tmp_c', "contradiction")'"' ///
						`" in {res}`s(_`trfl'`fn'_)' {txt}observations"'
				
						/*create contra flags if requested
						-----------------------------------*/
						if "`generate'" != "" {
							cap drop `generate'`cnt'
							qui g byte `generate'`cnt' = `contra'
							if "`fullexp'" != "" loc varlb /// 
							`"`s(_fltrflg`fn'_)' `s(_ifin`fn'_)' & ``tof''"'
							else loc varlb `"& ``tof''"'
							la var `generate'`cnt' `"`_not'(`fn') `varlb'"'
							di _col(11) `"{txt}(created indicator"' ///
							`" variable {res}`generate'`cnt'{txt})"'
						}
					}
					else di _col(11) "{txt}no contradictions"
				}
			}
		}
		} //extra loop over (pseudo) list
	}
	
	/*summarize contradictions
	---------------------------*/
	di _n(3) "{txt}Contradictions" _n
	if `cnt' == 0 di col(11) "{txt}no contradictions"
	forval c = 1/`cnt' {
		di _col(11) "{res}"`s(_ncon`c'_)' _col(17) ///
		"{txt}`= plural(`s(_ncon`c'_)', "contradiction")' " ///
		"in condition {res}`s(_cndcon`c'_)'"
		if "`generate'" != "" {
			di _col(17) "{txt}tagged in {res}`generate'`c' " ///
			"{txt}(N = {res}`s(_Ncon`c'_)'{txt})"		
		}
	}
end


/*define filters
-----------------*/
prog _ft_def ,sclass
	syntax anything(id = "conditions" equalok) [if][in] ///
	[, Add REPLACE(numlist int > 0) Generate(name)]
		
	/*check options
	----------------*/
	if `s(_nfifl_)' > 0 {
		if "`add'" == "" & "`replace'" == "" _mess exist
	}
	if "`add'" != "" & "`replace'" != "" _mess notboth add replace
	if `s(_nfifl_)' == 0 & ("`add'" != "" | "`replace'" != "") {
		loc messadd = cond("`add'" != "", "add", "replace")
		_mess nofifl addreplace `messadd'
		loc add
		loc replace
	}
	
	/*get -ifin-
	--------------*/
	loc ifin "`if' `in'"
	
	/*check and return generate
	----------------------------*/
	if "`generate'" != "" {
		cap conf new v `generate'
		if _rc _mess stubexists `generate'
		loc _tmp `s(_user_fltrflg_hist_)'
		if "`_tmp'" != "" {
			if !`: list posof "`generate'" in _tmp' ///
				loc _tmp "`generate' `_tmp'"
		}
		else loc _tmp `generate'
		sret loc _user_fltrflg_hist_ "`_tmp'"
		sret loc _user_fltrflg_ "`generate'"
	}
	
	/*get all conditions separated by ; and check for varlists
	-----------------------------------------------------------*/
	loc i 0
	while `"`anything'"' != "" {
		gettoken cnd`++i' anything : anything ,p(;)
		gettoken sep anything : anything ,p(;)
		
		/*check for varlist and extract
		--------------------------------*/
		if strmatch(`"`cnd`i''"', "*:*") {
			gettoken vars cnd`i' : cnd`i' ,p(:)
			loc cnd_oneforall : subinstr loc cnd`i' ":" "" ,all
			foreach v of varlist `vars' {
			
				/*replace placeholders in complex condition
				--------------------------------------------*/
				loc cpy_cnd = trim(`"`cnd_oneforall'"')
				if !strmatch(`"`cpy_cnd'"', "*@*") {
					if strmatch(`"`cpy_cnd'"' ,"*&*") ///
					| strmatch(`"`cpy_cnd'"', "*|*") ///
						_mess noplc `"`cnd_oneforall'"'
					else loc cpy_cnd `"`v' `cpy_cnd'"'
				}
				else loc cpy_cnd : subinstr loc cpy_cnd "@" "`v'" ,all
				loc cnd`i' `"`cpy_cnd'"'
				loc ++i
			}
			loc --i
		}
	}
	
	/*define filter flags
	----------------------*/
	if "`replace'" != "" {
		if `i' != `: word count `replace'' _mess manyfew
		loc w 1
		foreach r in `replace' {
			if `"`s(_fltrflg`r'_)'"' == "" _mess notfound "`r'"
			else {
				loc cnd`w' = trim(`"`cnd`w''"')
				sret loc _fltrflg`r'_ `"(`cnd`w'')"'
				if "`ifin'" != "" sret loc _ifin`r'_ "`ifin'"
			}
			loc ++w
		}
	}
	if "`add'" != "" {
		loc lastone = `s(_nfifl_)' + `i'
		forval j = 1/`i' {
			forval k = 1/`lastone' {
				if `"`s(_fltrflg`k'_)'"' == "" {
					loc cnd`j' = trim(`"`cnd`j''"')
					sret loc _fltrflg`k'_ `"(`cnd`j'')"'
					if "`ifin'" != "" sret loc _ifin`k'_ "`ifin'"
					sret loc _nfifl_ = `s(_nfifl_)' + 1
					continue, break
				}
			}
		}
	}
	if "`add'" == "" & "`replace'" == "" {
		forval j = 1/`i' {
			loc cnd`j' = trim(`"`cnd`j''"')
			sret loc _fltrflg`j'_ `"(`cnd`j'')"'
			if "`ifin'" != "" sret loc _ifin`j'_ "`ifin'"
			sret loc _nfifl_ = `s(_nfifl_)' + 1
		}
	}
	
	/*create filter flags and list
	-------------------------------*/
	_ft_makefilters
	_ft_list
end


/*list defined filters
-----------------------*/
prog _ft_list ,sclass
	if `s(_nfifl_)' == 0 _mess nofifl
	else {
		forval j = 1/`s(_nfifl_)' {
			di _n _col(7) "{txt}({res}`j'{txt}) " ///
			`"{res}`s(_fltrflg`j'_)' `s(_ifin`j'_)'"'
			if "`s(_user_fltrflg_)'" != "" ///
			di _n _col(11) "{txt}variable: {res}`s(_user_fltrflg_)'`j'"
			di _n _col(11) "{txt}true {res}" `s(_true`j'_)'
			di _col(11) "{txt}(N = {res}`s(_N`j'_)'{txt})"
		}
	}
end


/*clear filters or drop flags
------------------------------*/
prog _ft_clear ,sclass
	if `s(_nfifl_)' == 0 _mess nofifl
	if `"`2'"' != "" { 						//clear or drop all
		if `"`2'"' != "all" _mess unrec clear `"`1' `2'"'
		else {
			if `"`1'"' == "clear" sret clear
			else if `"`1'"' == "drop" {
				foreach f in _con `s(_user_con_hist_)' ///
				`s(_user_fltrflg_hist_)'{
					set varabbrev off
					cap conf v `f'
					set varabbrev on
					if !_rc {
						loc rb 1
						qui rename `f' _`f'__
					}
					else loc rb 0
					cap drop `f'*
					di "{txt}drop {res}`f'#"
					if `rb' qui rename _`f'__ `f'
				}
				sret loc _user_fltrflg_
				sret loc _user_fltflg_hist_
				sret loc _user_con_
				sret loc _user_con_hist_
			}
		}
	}
	else { 									//clear or drop filters
		if `"`1'"' == "clear" {
			forval j = 1/`s(_nfifl_)' {
				foreach s in _fltrflg`j'_ _ifin`j'_ _N`j'_ _true`j'_  ///
				_false`j'_ _user_fltrflg_ _user_fltrflg_hist_ {
					sret loc `s'
				}
			}
			sret loc _nfifl_ 0
		}
		else if `"`1'"' == "drop" {
			foreach f in `s(_user_fltrflg_hist_)' {
				set varabbrev off
				cap conf v `f'
				set varabbrev on
				if !_rc {
					loc rb 1
					qui rename `f' _`f'__
				}
				else loc rb 0
				cap drop `f'*
				di "{txt}drop {res}`f'#"
				if `rb' qui rename _`f'__ `f'
			}
			sret loc _user_fltrflg_
			sret loc _user_fltrflg_hist_
		}
	}
end


/*reimport filters
-------------------*/
prog _ft_imp ,sclass
	tempname R M
	if `s(_nfifl_)' != 0 _mess exist imp
	syntax name
	cap d `namelist'* ,varl
	loc _tmp : word count `r(varlist)'
	if `_tmp' == 0 _mess notfound `namelist'
	else {
		
		/*check all names are valid variables
		--------------------------------------*/
		forval j = 1/`_tmp' {
			conf v `namelist'`j'
		}
		
		/*return filters in s()
		------------------------*/
		sret loc _nfifl_ `_tmp'
		sret loc _user_fltrflg_ `namelist'
		loc _tmp `s(_user_fltrflg_hist_)'
		if "`_tmp'" != "" {
			if !`: list posof "`namelist'" in _tmp' ///
				sret loc _user_fltrflg_hist_ ///
				"`namelist' `_tmp'"
		}
		else sret loc _user_fltrflg_hist_ `namelist'
		forval j = 1/`s(_nfifl_)' {
			loc lbl : var l `namelist'`j'
			if `"`lbl'"' == "" {
				_mess notlab `j'
				loc lbl .
			}
			sret loc _fltrflg`j'_ `lbl'
			sret loc _ifin`j'_ if `namelist'`j' != .
			qui ta `namelist'`j' ,matrow(`R') matcell(`M')
			
			/*check dummy
			--------------*/
			if r(r) != 2 {
				if r(r) == 0 {
					_mess noobs `j'
					mat `M' = .\.
				}
				else {
					if `R'[1, 1] == 0 loc _tmp false
					else loc _tmp true
					_mess truefalse `j' `_tmp'
				}
			}
			sret loc _N`j'_ = r(N)
			sret loc _true`j'_ = `M'[2, 1]
			sret loc _false`j'_ = `M'[1, 1]
		}
	}
	_ft_list
end


/*export filters
-----------------*/
prog _ft_exp ,sclass
	if `s(_nfifl_)' == 0 {
		_mess nofifl
		exit 0
	}
	syntax name
	/*check names not used
	-----------------------*/
	forval j = 1/`s(_nfifl_)' {
		conf new v `namelist'`j'
	}
	sret loc _user_fltrflg_ `namelist'
	loc _tmp `s(_user_fltrflg_hist_)'
	if "`_tmp'" != "" {
		if !`: list posof "`namelist'" in _tmp' ///
			sret loc _user_fltrflg_hist_ "`namelist' `_tmp'"
	}
	else sret loc _user_fltrflg_hist_ `namelist'
	_ft_makefilters
end


/*create filter flags (make filters)
-------------------------------------*/
prog _ft_makefilters ,sclass
	tempvar _fltrflg
	tempname R M
	
	/*check defined filters
	------------------------*/
	forval j = 1/`s(_nfifl_)' {
		cap g byte `_fltrflg' = (`s(_fltrflg`j'_)') `s(_ifin`j'_)'
		if _rc {
			_mess invalid `j'
			continue
		}
		qui ta `_fltrflg' `s(_ifin`j'_)' ,matrow(`R') matcell(`M')

		/*check dummy
		--------------*/
		if r(r) != 2 {
			if r(r) == 0 {
				_mess noobs `j'
				mat `M' = .\.
			}
			else {
				if `R'[1, 1] == 0 loc _tmp false
				else loc _tmp true
				_mess truefalse `j' `_tmp'
			}
		}
		
		sret loc _N`j'_ = r(N)
		sret loc _true`j'_ = `M'[2, 1]
		sret loc _false`j'_ = `M'[1, 1]
	
		/*create variables if requested
		--------------------------------*/
		if "`s(_user_fltrflg_)'" != "" {
			cap drop `s(_user_fltrflg_)'`j'
			qui g byte `s(_user_fltrflg_)'`j' = `_fltrflg'
			la var `s(_user_fltrflg_)'`j' `"`s(_fltrflg`j'_)' `s(_ifin`j'_)'"'
		}
		drop `_fltrflg'
	}
end


/*error messages
-----------------*/
prog _mess
	if "`1'" == "unrec" {
		di `"{err}unrecognized subcommand: {bf:`2' `3'}"'
		exit 198
	}
	if "`1'" == "exist" {
		di "{err}filters already defined;"
		if "`2'" != "imp" {
			di "{err}use {bf:add} or {bf:replace} to add new " ///
			"filters or modify existing filters"
		}
		di "use {stata filtertrace clear} " ///
		"to clear existing flags"
		exit 110
	}
	if "`1'" == "notboth" {
		di "{err}{bf:`2'} and {bf:`3'} not both allowed"
		exit 198
	}
	if "`1'" == "manyfew" {
		di "{err}invalid {bf:replace()}: " ///
		"number of {it:conditions} does not "///
		"equal number of filters to be replaced"
		exit 198
	}
	if "`1'" == "notfound" {
		di "{err}filter (`2') not found"
		exit 111
	}
	if "`1'" == "invvfc" {
		di `"{err}invalid `2'"'
		di "{err}{it:vfe} must be {it:varlist} ({it:filter#}) [{it:exp}]"
		exit 198
	}
	if "`1'" == "noplc" {
		di `"{err}invalid `2' : no @ found"'
		exit 198
	}
	if "`1'" == "invnum" {
		if "`2'" == "filter" {
			di "{err}invalid {it:filter#} in `3'"
		}
		if "`2'" == "list" {
			di "{err}invalid {it:list} in `3'"
		}
		if "`2'" == "nlist" {
			di "{err}invalid {it:list} in `3';"
			di "number of elements must equal number of filters"
		}
		exit 198
	}
	
	/*non errors
	-------------*/
	if "`1'" == "nofifl" {
		di "{txt}no filters defined"
		if "`2'" == "addreplace" {
			di "{txt}ignoring option {res}`3'"
		}
		exit 0
	}
	if "`1'" == "invalid" {
		di "{txt}note: invalid {res}`s(_fltrflg`2'_)'"
		exit 0
	}
		if "`1'" == "noobs" {
		di "{txt}no observations for ({res}`2'{txt})" ///
		" {res}`s(_fltrflg`2'_)' {txt}`s(_ifin`2'_)'"
		exit 0
	}
	if "`1'" == "truefalse" {
		di "{txt}note: {txt}({res}`2'{txt}) {res}`s(_fltrflg`2'_)'" ///
		" {txt}is {res}`3' {txt}for all observations"
		exit 0
	}
	if "`1'" == "notlab" {
		di "{txt}note: no conditon found in ({res}`2'{txt})"
		exit 0
	}
	if "`1'" == "stubexists" {
		di "{txt}caution: {res}`2' {txt}already exists;" 
		di "{txt}using {bf:filtertrace drop} will drop {res}`2'"
		exit 0
	}
end
