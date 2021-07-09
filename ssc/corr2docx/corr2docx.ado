* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@hust.edu.cn)
* Zhengxuan Zhao, China Stata Club(爬虫俱乐部)(Zhengxuan_ZHAO@foxmail.com)
* Haitao Si, China Stata Club(爬虫俱乐部)(sht_finance@foxmail.com)
* Updated by Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan@hust.edu.cn)
* August 4th, 2017
* Updated on November 27th, 2018
* Program written by Dr. Chuntao Li, Zhengxuan Zhao, Haitao Si and updated by Yuan Xue
* Report correlation matrix to formatted table in DOCX file.
* Can only be used in Stata version 15.0 or above

program define corr2docx
	if _caller() < 15.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 15.0 programs"
		exit 9
	}
	 
	syntax varlist(numeric min=2) [if] [in] [aweight fweight/] using/, ///
	[append replace title(string) fmt(string) STAR STAR2(string asis) note(string) NODiagonal ///
	pagesize(string) font(string) landscape pearson(string asis) spearman(string asis)]

	marksample touse, novarlist
	qui count if `touse'
	if `r(N)' == 0 exit 2000
     
	if "`append'" != "" & "`replace'" != "" {
		disp as error "you could not specify both append and replace"
		exit 198
	}

	mata option_token("pearson")
	if `optionerror' == 1 {
		disp as error "you specify the option pearson() wrong"
		exit 198
	}
	mata option_token("spearman")
	if `optionerror' == 1 {
		disp as error "you specify the option spearman() wrong"
		exit 198
	}
	if "`pearson_bonferroni'" != "" & "`pearson_sidak'" != "" {
		disp as error "you could not specify both bonferroni and sidak in the option pearson()"
		exit 198
	}
	if "`pearson_pw'" == "" & ("`pearson_bonferroni'" != "" | "`pearson_sidak'" != "") {
		disp as error "you could not specify bonferroni or sidak without pw in the option pearson()"
		exit 198
	}
	if "`spearman_bonferroni'" != "" & "`spearman_sidak'" != "" {
		disp as error "you could not specify both bonferroni and sidak in the option spearman()"
		exit 198
	}
	if "`pearson_ignore'" != "" & "`spearman_ignore'" != "" {
		disp as error "you could not specify ignore in both the option pearson() and spearman()"
		exit 198
	}

	if "`star'" != "" & "`star2'" == "" local star2 = "* 0.1 ** 0.05 *** 0.01"
	mata token_number(`"`star2'"')
	if mod(scalar(token_number), 2) != 0 {
		dis as error "you specify the option star() incorrectly"
		exit 198
	}

	local starnum = scalar(token_number)
	if `starnum' != 0 {
		forvalues star_i = 1/`=`starnum'/2' {
			local sym_`star_i' = word("`star2'", `=2*`star_i' - 1')
			local pval_`star_i' = word("`star2'", `=2*`star_i'')
		}
		local pval_`=`starnum'/2 + 1' = 0
	}
	
	mata token_number(`"`varlist'"')
	local number = scalar(token_number) + 1

	if "`fmt'" == "" local fmt %9.3f

	qui {
		putdocx clear
		if `"`pagesize'"' == "" local pagesize = "A4"
		if `"`font'"' == "" local font = "Times New Roman"

		putdocx begin, pagesize(`pagesize') font(`font') `landscape'
		putdocx paragraph, halign(center) spacing(after, 0)
		if `"`title'"' == "" local title = "Correlation Coefficient"
		putdocx text (`"`title'"')

		if `"`note'"' != "" {
			putdocx table corrtable = (`number', `number'), border(all, nil) border(top) halign(center) note(`"`note'"')
			putdocx table corrtable(`number', .), border(bottom)
		}
		else {
			putdocx table corrtable = (`number', `number'), border(all, nil) border(top) border(bottom) halign(center)
		}

		putdocx table corrtable(1, .), border(bottom)
		putdocx table corrtable(1, 1), border(right)

		local row = 2
		local col = 2
		foreach var in `varlist' {
			putdocx table corrtable(1, `col') = ("`var'"), halign(center) valign(center)
			putdocx table corrtable(`row', 1) = ("`var'"), halign(left) valign(center)
			putdocx table corrtable(`row', 1), border(right)
			local row = `row' + 1
			local col = `col' + 1
		}

		*Pearson
		if "`pearson_ignore'" == "" {
			if "`pearson_pw'" == "" {
				if "`weight'" != "" corr `varlist' [`weight' = `exp'] if `touse'
				else corr `varlist' if `touse'
				mat pear_C = r(C)
				mata cal_pear("pear_C", `=r(N)')
			}
			else {
				if "`weight'" != "" pwcorr `varlist' [`weight' = `exp'] if `touse', sig `pearson_bonferroni' `pearson_sidak'
				else pwcorr `varlist' if `touse', sig `pearson_bonferroni' `pearson_sidak'
				mat pear_C = r(C)
				mat pear_sig = r(sig)
			}
			forvalues rownum = 3/`number' {
				forvalues colnum = 2/`=`rownum' - 1' {
					local outstar = ""
					if `starnum' != 0 {
						forvalues star_i = 1/`=`starnum'/2' {
							if scalar(pear_sig[`=`rownum' - 1', `=`colnum' - 1']) < `pval_`star_i'' & scalar(pear_sig[`=`rownum' - 1', `=`colnum' - 1']) >= `pval_`= `star_i' + 1'' {
								local outstar = `"`sym_`star_i''"'
							}
						} 
					}
					putdocx table corrtable(`rownum', `colnum') = (`"`=subinstr("`: disp `fmt' scalar(pear_C[`=`rownum' - 1', `=`colnum' - 1'])'", " ", "", .)'`outstar'"'), halign(center) valign(center)
				}
			}

			*spearman
			if "`spearman_ignore'" == "" {
				spearman `varlist' if `touse', `spearman_pw' `spearman_bonferroni' `spearman_sidak'
				mat spear_C = r(Rho)
				mat spear_sig = r(P)

				forvalues rownum = 2/`number' {
					forvalues colnum = `=`rownum' + 1'/`number' {
						local outstar = ""
						if `starnum' != 0 {
							forvalues star_i = 1/`=`starnum'/2' {
								if scalar(spear_sig[`=`rownum' - 1', `=`colnum' - 1']) < `pval_`star_i'' & scalar(spear_sig[`=`rownum' - 1', `=`colnum' - 1']) >= `pval_`= `star_i' + 1'' {
									local outstar = `"`sym_`star_i''"'
								}
							} 
						}
						putdocx table corrtable(`rownum', `colnum') = (`"`=subinstr("`: disp `fmt' scalar(spear_C[`=`rownum' - 1', `=`colnum' - 1'])'", " ", "", .)'`outstar'"'), halign(center) valign(center)
					}
				}
			}
		}

		*Only spearman
		else {
			spearman `varlist' if `touse', `spearman_pw' `spearman_bonferroni' `spearman_sidak'
			mat spear_C = r(Rho)
			mat spear_sig = r(P)

			forvalues rownum = 3/`number' {
				forvalues colnum = 2/`=`rownum' - 1' {
					local outstar = ""
					if `starnum' != 0 {
						forvalues star_i = 1/`=`starnum'/2' {
							if scalar(spear_sig[`=`rownum' - 1', `=`colnum' - 1']) < `pval_`star_i'' & scalar(spear_sig[`=`rownum' - 1', `=`colnum' - 1']) >= `pval_`= `star_i' + 1'' {
								local outstar = `"`sym_`star_i''"'
							}
						} 
					}
					putdocx table corrtable(`rownum', `colnum') = (`"`=subinstr("`: disp `fmt' scalar(spear_C[`=`rownum' - 1', `=`colnum' - 1'])'", " ", "", .)'`outstar'"'), halign(center) valign(center)
				}
			}
		}

		if "`nodiagonal'" == "" {
			forvalue rownum = 2/`number' {
				putdocx table corrtable(`rownum',`rownum') = ("1"), halign(center) valign(center)	
			}
		}
		if "`replace'" == "" & "`append'" == "" {
			putdocx save `using'
		}
		else {
			putdocx save `using', `replace'`append'
		}
	}
	di as txt `"correlation matrix have been written to file {browse "`using'"}"'
end

cap mata mata drop token_number()
mata
	void function token_number(string scalar token_list) {

		string rowvector token_vector

		token_vector = tokens(token_list)
		st_numscalar("token_number", cols(token_vector))
	}
end

cap mata mata drop option_token()
mata
	void function option_token(string scalar option) {

		string rowvector option_vector

		option_vector = tokens(st_local(option))

		st_local("optionerror", "0")

		if (cols(option_vector) > 0) {
			for (i = 1; i <= cols(option_vector); i++) {
				if (option_vector[1, i] == "pw") st_local(sprintf("%s_pw", option), "pw")
				else if (option_vector[1, i] == "bonferroni") st_local(sprintf("%s_bonferroni", option), "bonferroni")
				else if (option_vector[1, i] == "sidak") st_local(sprintf("%s_sidak", option), "sidak")
				else if (option_vector[1, i] == "ignore") st_local(sprintf("%s_ignore", option), "ignore")
				else st_local("optionerror", "1")
			}
		}
	}
end

cap mata mata drop cal_pear()
mata
	void function cal_pear(string scalar pear_m, real scalar obs) {

		real matrix pear_C
		real matrix pear_sig

		pear_C = st_matrix(pear_m)
		pear_sig = 2 * ttail(obs - 2, abs(pear_C) :* sqrt(obs - 2) :/ sqrt( 1 :- pear_C :^ 2))
		for (i = 1; i <= rows(pear_C); i++) {
			for (j = 1; j <= rows(pear_C); j++) {
				if (pear_C[i, j] == .) pear_sig[i, j] = .
				else if (pear_C[i, j] >= 1) pear_sig[i, j] = 0
				else if (pear_sig[i, j] > 1) pear_sig[i, j] = 1
			}
		}
		st_matrix("pear_sig", pear_sig)
	}
end
