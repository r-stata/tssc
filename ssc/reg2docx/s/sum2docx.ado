* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@hust.edu.cn)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan@hust.edu.cn)
* July 13rd, 2017
* Updated on November 27th, 2018
* Program written by Dr. Chuntao Li and Yuan Xue
* Report summary statistics to formatted table in DOCX file.
* Can only be used in Stata version 15.0 or above

program define sum2docx

	if _caller() < 15.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 15.0 programs"
		exit 9
	}

	syntax varlist(numeric) [if] [in] [aweight fweight iweight/] using/, [append replace title(string) ///
		stats(string asis) note(string) pagesize(string) font(string) landscape]

	marksample touse, novarlist
	qui count if `touse'
	if `r(N)' == 0 exit 2000

	if "`append'" != "" & "`replace'" != "" {
		disp as error "you could not specify both append and replace"
		exit 198
	}

	local stats_list = "N sum_w mean var sd skewness kurtosis sum min max p1 p5 p10 p25 median p75 p90 p95 p99"

	if `"`stats'"' == "" local stats = "N mean"

	if ustrregexm(`"`stats'"', "N\(.*?\)") {
		disp as error "you could not specify the format of N in option stats()"
		exit 198
	}

	scalar error_num = 0

	mata get_stat_name(`"`stats'"')

	if "`weight'" == "iweight"  {
		forvalues token_i = 1/`=scalar(tokennumber)' {
			if ustrregexm("skewness kurtosis p1 p5 p10 p25 p50 p75 p90 p95 p99", "\b`stat_`token_i''\b") {
				disp as error "iweights not allowed"
				exit 101
			}
		}
	}

	if scalar(error_num) == 1 {
		disp as error `"the `error_name' you specified in option stats() is invalid"'
		exit 198
	}

	mata var_number(`"`varlist'"')
	local colnum = scalar(tokennumber) + 1
	local rownum = scalar(var_number) + 1

	qui {
		if `"`pagesize'"' == "" local pagesize = "A4"
		if `"`font'"' == "" local font = "Times New Roman"
		putdocx clear
		putdocx begin, pagesize(`pagesize') font(`font') `landscape'
		
		if `"`title'"' == "" local title = "Summary Statistics"
		putdocx paragraph, spacing(after, 0) halign(center)
		putdocx text (`"`title'"')

		if `"`note'"' != "" {
			putdocx table sumtable = (`rownum', `colnum'), border(all, nil) border(top) halign(center) note(`"`note'"')
			putdocx table sumtable(`rownum', .), border(bottom)
		}
		else {
			putdocx table sumtable = (`rownum', `colnum'), border(all, nil) border(top) border(bottom) halign(center)
		}
		putdocx table sumtable(1, .), border(bottom)
		putdocx table sumtable(1, 1) = ("VarName"), halign(left) valign(center)
		forvalues i = 2/`colnum' {
			putdocx table sumtable(1, `i') = (`"`stat_`=`i'-1'_name'"'), halign(right) valign(center)
		}
		local i = 2
		foreach var of varlist `varlist' {
			if "`weight'" == "" {
				sum `var' if `touse', d
			}
			else if "`weight'" == "iweight" {
				sum `var' [`weight' = `exp'] if `touse'
			}
			else {
				sum `var' [`weight' = `exp'] if `touse', d
			}
			putdocx table sumtable(`i', 1) = ("`var'"), halign(left) valign(center)
			forvalues col = 2/`colnum' {
				if "`stat_`=`col'-1''" != "N" {
					putdocx table sumtable(`i', `col') = (`"`=subinstr("`: disp `stat_`=`col'-1'_fmt' `=r(`stat_`=`col'-1'')''", " ", "", .)'"'), halign(right) valign(center)
				}
				else {
					putdocx table sumtable(`i', `col') = (`=r(`stat_`=`col'-1'')'), halign(right) valign(center)
				}
			}
			local i = `i' + 1
		}
		
		if "`replace'" == "" & "`append'" == "" {
			putdocx save `"`using'"'
		}
		else {
			putdocx save `"`using'"', `replace'`append'
		}
	}
	di as txt `"summary statistics have been written to file {browse "`using'"}"'
end

mata
	void function get_stat_name(string scalar stats) {
		
		string rowvector token
		real scalar i

		token = tokens(stats)
		st_numscalar("tokennumber", cols(token))

		for (i = 1; i <= cols(token); i++) {
			
			if (strpos(token[1, i], "(") != 0) {
				st_local(sprintf("stat_%g", i), substr(token[1, i], 1, strpos(token[1, i], "(") - 1))
			}
			else {
				st_local(sprintf("stat_%g", i), token[1, i])
			}

			if (ustrregexm(st_local("stats_list"), sprintf("\b%s\b", st_local(sprintf("stat_%g", i)))) == 0) {
				st_numscalar("error_num", 1)
				st_local("error_name", st_local(sprintf("stat_%g", i)))
				break
			}
			else if (strpos(token[1, i], "(") != 0) {
				st_local(sprintf("stat_%g_fmt", i), substr(token[1, i], strpos(token[1, i], "(") + 1, strpos(token[1, i], ")") - strpos(token[1, i], "(") - 1))
			}
			else if (st_local(sprintf("stat_%g", i)) != "N") {
				st_local(sprintf("stat_%g_fmt", i), "%9.3f")
			}

			if (st_local(sprintf("stat_%g", i)) == "N") st_local(sprintf("stat_%g_name", i), "Obs")
			else if (st_local(sprintf("stat_%g", i)) == "sum_w") st_local(sprintf("stat_%g_name", i), "Sum_W")
			else if (st_local(sprintf("stat_%g", i)) == "mean") st_local(sprintf("stat_%g_name", i), "Mean")
			else if (st_local(sprintf("stat_%g", i)) == "var") {
				st_local(sprintf("stat_%g_name", i), "Variance")
				st_local(sprintf("stat_%g", i), "Var")
			}
			else if (st_local(sprintf("stat_%g", i)) == "sd") st_local(sprintf("stat_%g_name", i), "SD")
			else if (st_local(sprintf("stat_%g", i)) == "skewness") st_local(sprintf("stat_%g_name", i), "Skewness")
			else if (st_local(sprintf("stat_%g", i)) == "kurtosis") st_local(sprintf("stat_%g_name", i), "Kurtosis")
			else if (st_local(sprintf("stat_%g", i)) == "sum") st_local(sprintf("stat_%g_name", i), "Sum")
			else if (st_local(sprintf("stat_%g", i)) == "min") st_local(sprintf("stat_%g_name", i), "Min")
			else if (st_local(sprintf("stat_%g", i)) == "max") st_local(sprintf("stat_%g_name", i), "Max")
			else if (st_local(sprintf("stat_%g", i)) == "p1") st_local(sprintf("stat_%g_name", i), "P1")
			else if (st_local(sprintf("stat_%g", i)) == "p5") st_local(sprintf("stat_%g_name", i), "P5")
			else if (st_local(sprintf("stat_%g", i)) == "p10") st_local(sprintf("stat_%g_name", i), "P10")
			else if (st_local(sprintf("stat_%g", i)) == "p25") st_local(sprintf("stat_%g_name", i), "P25")
			else if (st_local(sprintf("stat_%g", i)) == "median") {
				st_local(sprintf("stat_%g_name", i), "Median")
				st_local(sprintf("stat_%g", i), "p50")
			}
			else if (st_local(sprintf("stat_%g", i)) == "p75") st_local(sprintf("stat_%g_name", i), "P75")
			else if (st_local(sprintf("stat_%g", i)) == "p90") st_local(sprintf("stat_%g_name", i), "P90")
			else if (st_local(sprintf("stat_%g", i)) == "p95") st_local(sprintf("stat_%g_name", i), "P95")
			else st_local(sprintf("stat_%g_name", i), "P99")
		}
	}

	void function var_number(string scalar var_list) {
		
		string rowvector var_vector

		var_vector = tokens(var_list)
		st_numscalar("var_number", cols(var_vector))
	}
end
