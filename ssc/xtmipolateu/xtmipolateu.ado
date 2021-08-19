*! version 1.1.0  31dec2020
program def xtmipolateu, rclass
	version 12.0
	/*
		This program inter-- and extrapolates missing values in a time series
		or multidimensional varlist with (SSC) mipolate, allowing the user to
		export descriptive statistics with (SSC) summarizeby and to write ts-
		and xtline graphs and tables with the statistics to a new or existing
		report document using putdocx or putpdf (the style is customizable).
		Author: Ilya Bolotov, MBA, Ph.D.
		Date: 20 November 2020
	*/
	syntax 																	///
	varlist(ts fv) [if] [in], [i(varlist)] t(varname)						///
	[/* ignore */ GENerate(string) /* ignore */]							///
	[export(string asis)]													///
	[put(string) PBReak NFORmat(string) SAving(string asis) *]
	local put = trim("`put'")
	local nformat = cond("`nformat'" != "", trim("`nformat'"), "%9.2fc")
	// adjust and preprocess options
	if ! regexm(`"`put'"', "^(docx|pdf|)$") {
		di as err "command put`put' is unrecognized"
		exit 199
	}
	tempname by1 by2 var1 var2
	tempvar hat
	// check for third-party packages from SSC
	qui which mipolate
	qui which summarizeby
	// preserve statistics and data for export or putting into a document
	qui {
		if `"`export'`put'"' != "" {
			qui {
				tempfile tmpf_stats
				local `by2' = cond("`i'" != "", "by(`i')", "")
				preserve
				keep `i' `t' `varlist'
				summarizeby mean=r(mean) sd=r(sd) min=r(min) max=r(max),	///
				``by2'' sa(`tmpf_stats')
				restore
			}
		}
		if `"`put'"' != "" {
			tempfile tmpf_dta tmpf_dta_hat
			save `tmpf_dta'
		}
	}
	// perform mipolate
	local `by1' = cond("`i'" != "", "by `i' (`t'), sort:", "")
	foreach `var1' of varlist `varlist' {
		``by1'' mipolate ``var1'' `t' `if' `in', gen(`hat') `options'
		``by1'' replace ``var1'' = `hat' if missing(``var1'')
		drop `hat'
	}
	// return results
	``by1'' count
	return scalar N_groups = `=_N' / `r(N)'
	// export statistics or put graph(s) and table(s) into a document
	tempname n a b l list
	/* export statistics */
	if `"`export'`put'"' != "" {
		preserve
		tempvar id1 id2
		qui {
			keep `i' `t' `varlist'
			summarizeby mean=r(mean) sd=r(sd) min=r(min) max=r(max),	///
			``by2'' clear
			append using `tmpf_stats', gen(`id1')
			label define dataset 0 "_hat" 1 "_orig"
			label values `id1' dataset
			decode `id1', gen(`id2')
			replace `id1' = _n
			reshape wide `id1' mean sd min max, string i(v `i') j(`id2')
			foreach `var1' of varlist *_orig {
				rename ``var1'' `=regexr("``var1''", "_orig$", "")'
			}
			order v `i' mean* sd* min* max*
			sort `id1'*
			drop `id1'*
			if `"`put'"' != "" {
				by v (`i'), sort: count
				local `n' = `r(N)' + 1	// include header
				ds v, not
				local `list' `"`r(varlist)'"'
				local `a' = 1
				foreach `var2' of varlist ``list'' {
					if strpos("``var2''", "_hat") {
						continue, break
					}
					local `a' = ``a'' + 1
				}
				local `b' : word count ``list''
			}
			save `tmpf_stats', replace
		}
		if `"`export'"' != "" {
			export `export'
		}
		restore
	}
	/* put graph(s) and table(s) into a document */
	if `"`put'"' != "" {
		cap put`put' begin	// if not opened by user beforehand
		save `tmpf_dta_hat'	// save data in file to nest preserve / restore
		tempvar g orig
		qui {
			g `hat' = .
			g `orig' = .
			append using `tmpf_dta', gen(`id1')
			reshape wide `varlist', i(`i' `t') j(`id1')
			foreach `var1' of varlist *1 {
				rename ``var1'' `=regexr("``var1''", "1$", "")'
			}
			`=cond("`i'"!="", "egen `g'=group(`i'), missing label", "g `g'=1")'
			sort `g' `t'	// sort data by `g'
			local `var2' : word 1 of `varlist'
			foreach `var1' of varlist `varlist' {
				forvalues `l' = 1/`=`g'[_N]' {
					sum ``var1'' if `g' == ``l''
					replace `orig' =										///
					(``var1''-r(min)) / (r(max)-r(min)) if `g' == ``l''
					replace `hat' =											///
					(``var1''0-r(min)) / (r(max)-r(min)) if `g' == ``l'' &	///
					missing(`orig')
				}
				if "``var1''" != "``var2''" {
					put`put' pagebreak
				}
				/* graph */
				put`put' paragraph
				label var `hat' "``var1''_hat"
				label var `orig' "``var1''"
				xtset `g' `t'
				`=cond("`i'"!="", "xt", "ts")'line `hat' `orig'
				gr export `tmpf_dta', as(png) replace
				put`put' image `tmpf_dta'
				`=cond("`pbreak'"!="", "put`put' pagebreak", "")'
				/* table (preformatted) */
				put`put' paragraph
				preserve
				use `tmpf_stats', clear
				put`put' table ``var1'' = data(``list'') 					///
				if v == "``var1''", varnames								///
				border(insideH, nil) border(insideV, nil)
				restore
				put`put' table ``var1''(1,.),								///
				halign(center) border(bottom) bold
				if `=``a''-1' {
					put`put' table ``var1''(.,1/`=``a''-1'),				///
					halign(center) border(right) bold
				}
				put`put' table ``var1''(1/``n'',``a''(2)``b''),				///
				border(left) bold
				put`put' table ``var1''(2/``n'',``a''/``b''),				///
				halign(right) nformat(`nformat')
			}
		}
		if `"`saving'"' != "" {
			put`put' save `saving'
		}
		use `tmpf_dta_hat', clear
	}
end
