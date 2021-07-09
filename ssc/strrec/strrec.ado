*! version 1.0.8 31may2011
*	1.0.7	-labelsof- no longer needed
*			replaced with mata function
*	1.0.8	changes in -vallab- option (add -nodelete-)

program strrec ,sclass
	version 11.1

	syntax anything(equalok id = "varlist (rule) [(rule)]") [if][in] ///
	[, PREfix(name) Generate(namelist) REPLACE ///
	SUB WILDcards CASEsensitive STRing ///
	DEFine(name) noLabel ///
	ELSEMISS COPYrest ///
	VALLab VLab LABREC noDELete]
	
	local alloptions replace sub casesensitive string label copyrest ///
	elsemiss vallab
	local binopt rplc sub case str nolab copy elsemiss vallab
	
	/*get input and do some checks
	-------------------------------*/
	local uif `if'
	local uin `in'
	gettoken vars anything : anything ,parse("(")
	if `"`vars'"' == "(" errorexit varlist
	unab varlist : `vars'
	loc dup : list dups varlist
	loc varlist : list varlist - dup
	if `"`anything'"' == "" errorexit rules
	if `"`wildcards'"' != "" local sub sub
	if "`labrec'" != "" | "`vlab'" != "" local vallab vallab
	if "`vallab'"' == "" {
		marksample touse ,nov
		qui count if `touse'
		if r(N) == 0 errorexit noobs
		drop `touse'
		if "`replace'" == "" {
			if "`generate'" != "" {
				if "`prefix'" == "" confirm new var `generate'
				else {
					foreach g of local generate {
						confirm new var `prefix'`g'
					}
				}
				local ngen : word count `generate'
				local nvar : word count `varlist'
				if `ngen' != `nvar' {
					local fewmany = cond(`ngen' < `nvar' ///
					,"few" ,"many")
					errorexit "`fewmany'" 
				}
			}
			else {
				if "`prefix'" == "" local prefix "r_"
				foreach v of local varlist {
					confirm new var `prefix'`v'
				}
			}
		}
		else {
			local prefix ""
			local generate `varlist'
		}
	}
	else {
		local string ""
		local label ""
	}
	sret clear

	/*options to s()
	-----------------*/
	forval j = 1/`: word count `alloptions'' {
		local opt_`: word `j' of `binopt'' = ///
			("``: word `j' of `alloptions'''" != "")
		sret local opt_`: word `j' of `binopt'' ///
			`opt_`: word `j' of `binopt'''
	}
	
	srgetrules `anything'
	
	/*define mode and select subroutine
	------------------------------------*/
	local mode2 = cond(`s(mode)' == 1 ///
	, cond(`s(opt_vallab)' == 1 ,3 ,1) ///
	,cond(`s(opt_vallab)' == 1 ,4 ,2))
	if `s(mode)' != `mode2' sret local mode `mode2'
	if `s(mode)' <= 2 srstrrec `varlist' `uif' `uin' ///
		, prefix(`prefix') generate(`generate') define(`define')
	else srvallab `varlist' ,`delete'
	sret clear
end

program srstrrec
	syntax varlist [if][in] ///
	[, Prefix(name) Generate(namelist) DEFine(name)]
	
	marksample touse ,nov
	
	tempvar tmp_var rplc_var
	
	local varcnt 0
	foreach var of local varlist {
		local ++varcnt
		cap confirm str var `var'
		if _rc {
			di "{txt}note: omitted numeric variable {res}`var'"
			continue
		}
		
		/*copy var to make changes
		---------------------------*/		
		qui g `tmp_var' = cond(`s(opt_case)' == 1 ///
		,`var' ///
		,itrim(trim(lower(`var'))))

		/*check substrings and change tmp_var
		--------------------------------------*/		
		if `s(opt_sub)' {	
			forval j = 1/`s(nrules)' {
				tokenize `"`s(_org_`j')'"' ,parse(",")
				local tok 0
				while `"``++tok''"' != "" {
					qui replace `tmp_var' = "``tok''" ///
						if strmatch(`tmp_var',"``tok''")
					local ++tok
				}
			}	
		}
		
		/*name new var
		---------------*/
		local newvar = cond("`generate'" == "" ///
		,"`prefix'`var'" ,"`prefix'`: word `varcnt' of `generate''")
		di "{res}`newvar'"
		
		/*settings
		-----------*/
		if !`s(opt_copy)' local cpy if `touse'
		else local cpy ""
		local oldvarlab : var lab `var'
		if `s(opt_rplc)' {
			order `tmp_var' ,before(`var')
			if `s(mode)' == 1 {
				drop `var'
				qui g `newvar' = .
			}
			else {
				if !`s(opt_elsemiss)' {
					qui g `rplc_var' = `var' `cpy'
					drop `var'
					qui g `newvar' = `rplc_var'
					drop `rplc_var'
				}
				else {
					local oldtype : type `var'
					drop `var'
					qui g `oldtype' `newvar' = ""
				}
			}
			order `newvar' ,before(`tmp_var')
		}
		else {
			if `s(mode)' == 1 qui g `newvar' = .
			else { 
				local oldtype : type `var'
				if `s(opt_elsemiss)' qui g `oldtype' `newvar' = ""
				else qui g `newvar' = `var' `cpy'
			}
		}

		/*recode procedure
		-------------------*/
		if `s(mode)' == 1 {
			forval j = 1/`s(nrules)' {
				replace `newvar' = `s(_des_`j')' ///
					if inlist(`tmp_var',`s(_org_`j')') & `touse'
				if !`s(opt_nolab)' {
					local tmpnam = cond("`define'" == "" ///
						,"`newvar'" ,"`define'")
					cap assert `s(_des_`j')' == int(`s(_des_`j')')
					if !_rc & `s(_des_`j')' != . ///
					lab def `tmpnam' ///
						`s(_des_`j')' "`s(_lab_`j')'" ,modify
				}
			}
			if !`s(opt_nolab)' lab val `newvar' `tmpnam'
		}
		else {
			forval j = 1/`s(nrules)' {
				replace `newvar' = `"`s(_des_`j')'"' ///
					if inlist(`tmp_var',`s(_org_`j')') & `touse'
			}
		}
		drop `tmp_var'
		qui compress `newvar'
		if `"`oldvarlabel'"' != "" lab var `newvar' `"`oldvarlabel'"'
	}
end

program srvallab ,sclass
	syntax varlist [ ,noDELete]
	
	tempname _vals
	
	/*strip duplicates
	-------------------*/
	loc dup : list dups varlist
	loc varlist : list varlist - dup

	/*get variable list for value labels (borrowed from uselabel.ado)
	------------------------------------------------------------------*/
	foreach var of varlist * {
		local lbl_vars : val lab `var'
		if "`lbl_vars'" != "" {
			sret local `lbl_vars' `s(`lbl_vars')' `var'
			if (`s(mode)' == 3) loc vars2copy `vars2copy' cpy_`var'
		}
		else local omitvars `omitvars' `var'
	}
	
	/*create copy of variables to be recoded
	-----------------------------------------*/
	if (`s(mode)' == 3) {
		tempvar `vars2copy'
		foreach tv in `vars2copy' {
			loc ovar = substr("`tv'", 5, .)
			loc typ : t `ovar'
			qui g `typ' ``tv'' = `ovar'
		}
	}	
	
	/*main loop over variables
	---------------------------*/
	foreach var of local varlist {
		if `: list posof "`var'" in omitvars' != 0 continue
		if `: list posof "`var'" in varsdone' != 0 continue

		local tmp_lab_nam : val lab `var'
		cap la li `tmp_lab_nam'
		if _rc {
			if _rc == 111 continue
			else errorexit other `var' `tmp_lab_nam' _rc
		}
		mata : st_vlload("`tmp_lab_nam'", vl = ., lbltxt = .)
		mata : st_matrix("`_vals'", vl)
		di "{res}`tmp_lab_nam' {txt}({res}`s(`tmp_lab_nam')'{txt})"	

		/*get labels (name,text and integer part)
		------------------------------------------*/
		forval j = 1/`= rowsof(`_vals')' {
			loc tmp_lab_val = `_vals'[`j', 1]
			local tmp_lab_txt : lab `tmp_lab_nam' `tmp_lab_val'
			local tmp_lab_txt : subinstr loc tmp_lab_txt "`" "'" ,all
			if !`s(opt_case)' /// 
				local tmp_lab_txt = itrim(trim(lower(`"`tmp_lab_txt'"')))

			/*sub option
			-------------*/
			if `s(opt_sub)' {
				local skip ""
				forval j = 1/`s(nrules)' {
					`skip'
					tokenize `"`s(_org_`j')'"' ,parse(",")
					local tok 0
					while `"``++tok''"' != "" {
						if strmatch(`"`tmp_lab_txt'"',"``tok''") {
							local tmp_lab_txt `"``tok''"'
							local skip continue ,break
							`skip'
						}
						local ++tok				
					}
				}
			}
			
			/*recode value labels
			----------------------*/
			forval j = 1/`s(nrules)' {
				if inlist("`tmp_lab_txt'",`s(_org_`j')') {
					if `s(mode)' == 4 {
						lab def `tmp_lab_nam' ///
							`tmp_lab_val' "`s(_des_`j')'" ,modify
						foreach addv in `s(`tmp_lab_nam')' {
							loc varsdone `varsdone' `addv'
						}
					}
					else if (`s(mode)' == 3) ///
					& (`s(_des_`j')' != `tmp_lab_val') {
						if ("`delete'" == "") {
							lab def `tmp_lab_nam' `tmp_lab_val' "" ,modify
						}
						cap assert `s(_des_`j')' == int(`s(_des_`j')')
						if !_rc & `s(_des_`j')' != . {
							lab def `tmp_lab_nam' `s(_des_`j')' ///
							"`s(_lab_`j')'" ,modify
						}
						/*recode variables
						-------------------*/
						foreach addv in `s(`tmp_lab_nam')' {
							replace `addv' = `s(_des_`j')' ///
								if `cpy_`addv'' == `tmp_lab_val'
							local varsdone `varsdone' `addv'
						}
					}
				}
			}
		}
	}
end

program srgetrules ,sclass
	local nrules 0
	
	while `"`0'"' != "" {
		local ++nrules
		gettoken err_r : 0 ,match(m)
		gettoken rule 0 : 0 ,match(m)
		local tok ""
		while `"`tok'"' != "=" {
			gettoken tok rule : rule ,parse(`"=" "')
			if `"`tok'"' != "=" {
				local sep = cond(`"`org`nrules''"' == "" ,"",",")
				if !`s(opt_case)' ///
					local tok = itrim(trim(lower(`"`tok'"')))
				local org`nrules' `"`org`nrules''`sep'"`tok'""'
			}
			if `"`tok'"' == "" errorexit invalidrule `"`err_r'"'
		}
		if (`"`org`nrules''"' == "") | (`"`rule'"' == "") ///
			errorexit invalidrule `"`err_r'"'
		tokenize `"`rule'"' ,parse(`"" "')
		
		chkset_mode `"`1'"' `nrules' `"`err_r'"'
		
		local des`nrules' `"`1'"'
		if `s(mode)' == 1 & !`s(opt_nolab)' {
			if `"`2'"' == "" {
				gettoken lab`nrules' : org`nrules' ,parse(",")
			}
			else local lab`nrules' `"`2'"'
		}
	}
	
	sret local nrules `nrules'
	forval j = 1/`nrules' {
		foreach x in org des lab {
			sret local _`x'_`j' "``x'`j''"
		}
	}
end

program chkset_mode ,sclass
	if !`s(opt_str)' {
		cap conf num `1'
		if _rc {
			cap as `1' == int(`1')
			if _rc {
				if `2' == 1 {
					local mode 2
					sret local mode `mode'
				}
				if `s(mode)' == 1 errorexit invalidrule `"`3'"'
			}
			else if `2' == 1 local mode 1
		}
		else if `2' == 1 local mode 1
	}
	else local mode 2
	if `2' == 1 & "`s(mode)'" == "" sret local mode `mode'
end

program errorexit
	if "`1'" == "noobs" {
		di "{err}no observations"
		exit 2000
	}
	if inlist("`1'","varlist","rules") {
		di `"{err}`1' expected"'
		exit 198
	}
	if inlist("`1'","few","many") {
		di "{err}option generate() : too `1' names specified"
		exit 198
	}
	if "`1'" == "invalidrule" {
		di `"{err}invalid rule: (`2');"'
		di `"all rules must either be "' ///
		`"("str" = # ["lbl"]) or ("str" = "newstr")"'
		exit 198
	}
	if "`1'" == "other" {
		di "{err}`2' (`3')"
		exit `4'
	}
end
