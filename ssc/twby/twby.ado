*! version 1.1.0 20Sep2019 MLB
* if and in conditions and weights in graphs no longer cause an error
program define twby
	version 11.2
	
	mata : _parse_colon("hascolon", "graph")
	Ckgraph `graph'
	if `"`s(name)'"' == "" {
		local gr = "Graph"
	}
	else {
		local gr = s(name) 
	}

	capture confirm variable _fillin
	if !_rc {
		di as err "{p}twby uses fillin, which creates the variable _fillin, but this variable is already defined in the data{p_end}"
		exit 110
	}
	syntax varlist(min=2 max=2), [left xoffset(real 0)  MISSing ///
	        total Rows(string) Cols(string)  HOLes(string) COLFirst *]
	
	if `"`total'`rows'`cols'`holes'`colfirst'"' != "" {
		di as err "{p}Options total, rows(), cols(), holes(), and colfirst are not allowed{p_end}"
		exit 198
	}
	preserve
	
	gettoken r c : varlist
	qui levelsof `r', local(rlevs) `missing'
	qui levelsof `c', local(clevs) `missing'
	local kc : word count `clevs'
	local kr : word count `rlevs'	

	fillin `varlist'
	
	tempvar by 
	if "`missing'" == "" {
		marksample touse, strok
	}
	else {
		marksample touse , strok novarlist
	}	

	sort `varlist' `touse'
	qui by `varlist' `touse': gen `by' = _n == 1 if `touse' == 1
	qui replace `by' = sum(`by') if `touse' == 1
	
	capture confirm numeric variable `c'
	local cnum = _rc == 0
	capture confirm numeric variable `r'
	local rnum = _rc == 0
	
	forvalues i = 1/`kc' {
		local lev : word `i' of `clevs'
		if `cnum' {
			local lab : label (`c') `lev'
		}
		else {
			local lab `lev'
		}
		
		label define `by' `i' `"`lab'"', modify
	}
	forvalues i = `=`kc'+1'/ `=`kr'*`kc'' {
		label define `by' `i' " ", modify
	}
	label value `by' `by'
	local rlab : variable label `r'
	if `"`rlab'"' == "" local rlab `r'
	local clab : variable label `c'
	if `"`clab'"' == "" local clab `c'
	if "`left'" == "" {
		local rtitle r2title(`"`rlab'"', orientation(rvertical))
	}
	else {
		local rtitle l2title(`"`rlab'"')
	}
	
	`graph' || , by(`by', cols(`kc') note("") t2title(`"`clab'"') `rtitle' `options') nodraw
	
	local lcolor = "`.`gr'.plotregion1.subtitle[1].style.linestyle.color.rgb'"
	
	if "`left'" == "" {
		local j = 0
		forvalues i = `kc'(`kc')`=`kr'*`kc'' {
			local j = `j' + 1
			local lev : word `j' of `rlevs'
			if `rnum' {
				local lab : label (`r') `lev'
			}
			else {
				local lab `lev'
			}
			_gm_edit .`gr'.plotregion1.r1title[`i'].style.editstyle drawbox(yes) editcopy
			_gm_edit .`gr'.plotregion1.r1title[`i'].style.editstyle linestyle(color("`lcolor'")) editcopy
			_gm_edit .`gr'.plotregion1.r1title[`i'].as_textbox.setstyle, style(yes)
			_gm_edit .`gr'.plotregion1.r1title[`i'].text = {}
			_gm_edit .`gr'.plotregion1.r1title[`i'].text.Arrpush `lab'
			_gm_edit .`gr'.plotregion1.r1title[`i']._set_orientation rvertical 
			if `xoffset' != 0 {
				_gm_edit .`gr'.plotregion1.r1title[`i'].xoffset = `xoffset'
			}
		}
	}
	else {
		local j = 0
		forvalues i = 1(`kc')`=`kr'*`kc'' {
			local j = `j' + 1
			local lev : word `j' of `rlevs'
			if `rnum' {
				local lab : label (`r') `lev'
			}
			else {
				local lab `lev'
			}
			_gm_edit .`gr'.plotregion1.l1title[`i'].style.editstyle drawbox(yes) editcopy
			_gm_edit .`gr'.plotregion1.l1title[`i'].style.editstyle linestyle(color("`lcolor'")) editcopy
			_gm_edit .`gr'.plotregion1.l1title[`i'].as_textbox.setstyle, style(yes)
			_gm_edit .`gr'.plotregion1.l1title[`i'].text = {}
			_gm_edit .`gr'.plotregion1.l1title[`i'].text.Arrpush `lab'
			if `xoffset' != 0 {
				_gm_edit .`gr'.plotregion1.l1title[`i'].xoffset = `xoffset'
			}
		}
	}	
	graph display `gr'
	
	restore
end

program define Ckgraph, sclass
	version 11.2
	_parse expand c o : 0
	
	gettoken first rest : c_1
	if inlist(`"`first'"', "graph", "grap", "gra", "gr") {
		gettoken second rest : rest
		if inlist(`"`second'"', "twoway", "twowa", "twow", "two", "tw") {
			local ok = 1
		}
		else {
			local ok = 0
		}
	}
	else if inlist(`"`first'"', "twoway", "twowa", "twow", "two", "tw") {
		local ok = 1
	}
	else if inlist(`"`first'"', "scatter", "scatte", "scatt", "scat", "sca", "sc"){
		local ok = 1
	}
	else if inlist(`"`first'"', "line", "tsline", "tsrline") {
		local ok = 1
	}
	else {
		local ok = 0
	}
	if !`ok' {
		di as err "{p}The command after the colon must be a twoway graph{p_end}"
		exit 198
	}
	forvalues i = 1/`c_n' {
		Ckpart `c_`i''
	}
	Ckpart , `o_op'
	if `"`s(name)'"' != "" {
		sreturn local name = s(name)
	}
end	

program define Ckpart, sclass
	version 11.2
	syntax [anything] [if] [in] [fweight pweight aweight iweight], [by(string) name(string) *] // no, use _parse expand instead
	if `"`by'"' != "" {
		di as err "{p}by option in graph command not allowed{p_end}"
		exit 198
	}
	if "`name'" != "" {
		gettoken name rest : name, parse(",")
		sreturn local name "`name'"
	}
end