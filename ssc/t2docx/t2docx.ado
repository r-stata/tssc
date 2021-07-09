* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@hust.edu.cn)
* Zijian LI, China Stata Club(爬虫俱乐部)(jeremylee_41@163.com)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan@hust.edu.cn)
program define t2docx

	if _caller() < 15.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 15.0 programs"
		exit 9
	}

	syntax varlist(numeric) [if] [in] using/, [append replace title(string) ///
		fmt(string) NOSTAr STAR STAR2(string asis) staraux noT p se note(string) ///
		pagesize(string) font(string) landscape UNEqual Welch] by(varname)

	marksample touse, strok
	qui count if `touse'
	if `r(N)' == 0 exit 2000

	if "`append'" != "" & "`replace'" != "" {    
		disp as error "you could not specify both append and replace"
		exit 198
	}

	if ("`nostar'" != "") & ("`star'" != "" | "`star2'" != "" | "`staraux'" != "") {
		disp as error "you could not specify both nostar and star[()]|staraux"
		exit 198
	}

	if "`t'" != "" & "`staraux'" != "" {
		disp as error "you could not specify both not and staraux"
		exit 198
	}

	if "`p'" != "" & "`se'" != "" {
		disp as error "you could not specify both p and se"
		exit 198
	}

	mata var_number(`"`varlist'"')
	local rownum = scalar(var_number) + 1
	local colnum = 7
	if "`t'" != "" & "`p'" == "" & "`se'" == "" local colnum = 6

	qui {
		if `"`pagesize'"' == "" local pagesize = "A4"
		if `"`font'"' == "" local font = "Times New Roman"
		putdocx clear
		putdocx begin, pagesize(`pagesize') font(`font') `landscape'
		putdocx paragraph, spacing(after, 0) halign(center)

		if `"`title'"' == "" local title = "T-test Table"
		putdocx text (`"`title'"')

		if `"`note'"' != "" {
			putdocx table ttbl = (`rownum', `colnum'), border(all, nil) border(top) halign(center) note(`"`note'"')
			putdocx table ttbl(`rownum', .), border(bottom)
		}
		else {
			putdocx table ttbl = (`rownum', `colnum'), border(all, nil) border(top) border(bottom) halign(center)
		}

		forval i = 1(1)`colnum'{
			putdocx table ttbl(1, `i'), border(bottom) 
		}
		tabstat `varlist' if `touse', by(`by') save

		putdocx table ttbl(1, 1) = ("varname"), halign(left)
		putdocx table ttbl(1, 2) = ("obs(`r(name1)')"), halign(right)
		putdocx table ttbl(1, 3) = ("mean(`r(name1)')"), halign(right)
		putdocx table ttbl(1, 4) = ("obs(`r(name2)')"), halign(right)
		putdocx table ttbl(1, 5) = ("mean(`r(name2)')"), halign(right)
		putdocx table ttbl(1, 6) = ("mean-diff"), halign(right)
		if "`t'" == "" & "`p'" == "" & "`se'" == "" putdocx table ttbl(1, 7) = ("t"), halign(right)
		else if "`p'" != "" putdocx table ttbl(1, `colnum') = ("p"), halign(right)
		else if "`se'" != "" putdocx table ttbl(1, `colnum') = ("se"), halign(right)
		
		if "`fmt'" == "" local fmt %9.3f

		if `"`star2'"' == "" {
			local star_1 *
			local star_2 **
			local star_3 ***
			local siglevel1 = 0.1
			local siglevel2 = 0.05
			local siglevel3 = 0.01
			local siglevel4 = 0
			local levelnum = 3
		}
		else {
			mata var_number(`"`star2'"')
			local levelcount = scalar(var_number)
			if mod(`levelcount', 2) == 1 {
				disp as error "you specify the option star() incorrectly"
				exit 198
			}
			else {
				token `"`star2'"'
				local levelnum = `levelcount'/2
				forvalue i = 1(1)`levelnum' {
					local star_`i' ``=`i'*2-1''
					local siglevel`i' ``=`i'*2''
				}
			}
			local siglevel`=`levelnum'+1' = 0
		}

		local row = 2
		foreach v of varlist `varlist'{
			putdocx table ttbl(`row', 1) = (`"`v'"'), halign(left) 
			local row = `row' + 1
		}

		local row = 2	
		foreach v of varlist `varlist'{
			ttest `v' if `touse', by(`by') `welch' `unequal'

			local staroutput = ""
			local bstar = ""
			local tstar = ""
			forvalues i = 1/`levelnum' {
				if `r(p)' < `siglevel`i'' & `r(p)' >= `siglevel`=`i'+1'' {
					local staroutput `star_`i''
				}
			}

			if "`staraux'" == "" local bstar `staroutput'
			else local tstar `staroutput'
			
			if "`nostar'" != "" {
				local bstar = ""
				local tstar = ""
			}

			putdocx table ttbl(`row', 2) = (`"`=subinstr("`: disp `bfm' r(N_1)'", " ", "", .)'"'), halign(right) 
			putdocx table ttbl(`row', 3) = (`"`=subinstr("`: disp `fmt' r(mu_1)'", " ", "", .)'"'), halign(right) 
			putdocx table ttbl(`row', 4) = (`"`=subinstr("`: disp `bfm' r(N_2)'", " ", "", .)'"'), halign(right)
			putdocx table ttbl(`row', 5) = (`"`=subinstr("`: disp `fmt' r(mu_2)'", " ", "", .)'"'), halign(right) 
			putdocx table ttbl(`row', 6) = (`"`=subinstr("`: disp `fmt' r(mu_1)-r(mu_2)'", " ", "", .)'`bstar'"'), halign(right) 
			if "`t'" == "" & "`p'" == "" & "`se'" == "" putdocx table ttbl(`row', 7) = (`"`=subinstr("`: disp `fmt' r(t)'", " ", "", .)'`tstar'"'), halign(right) 
			else if "`p'" != "" putdocx table ttbl(`row', 7) = (`"`=subinstr("`: disp `fmt' r(p)'", " ", "", .)'`tstar'"'), halign(right)
			else if "`se'" != "" putdocx table ttbl(`row', 7) = (`"`=subinstr("`: disp `fmt' r(se)'", " ", "", .)'`tstar'"'), halign(right)

			local row = `row' + 1
		}

		if "`replace'" == "" & "`append'" == "" {
			putdocx save `"`using'"'
		}
		else {
			putdocx save `"`using'"', `replace'`append'
		}
	}
	di as txt `"t-test table have been written to file {browse "`using'"}"'
end

mata
	void function var_number(string scalar var_list) {

		string rowvector var_vector

		var_vector = tokens(var_list)
		st_numscalar("var_number", cols(var_vector))
	}
end
