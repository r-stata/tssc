*! Package basetable v 0.2.21
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk
*! version 0.2.21	2019-08-12	> bugfix quotation around `r(fn)' after run: if "`r(fn)'" != "" & !`toxl_exists' run `"`r(fn)'"'
*! version 0.2.2	2019-02-27	> lmatrixtools.mata updated

* TODO: Count unique by
* TODO: Set decimals on totals
* TODO: toxl insert in (row, col) plus update sheet
* TODO: Header layout = space above, line below. Christine Geyti
* TODO: Not only 95% ci
* TODO: Control columnwidth in toxl. Force adjustment similar to style. Only from Stata 14
* TODO: Option for no total row at top

*version 0.2.1	2018-10-04	> Option for smoothing data when returning median and quartiles
*version 0.2.1	2018-09-20	> Variable label in header
*version 0.2.1	2018-09-20	> Right adjusted table output in toxl excel books, v14 and up
*version 0.2.1	2018-09-20	> Option for column witdh in toxl option, v14 and up
*version 0.2.1	2018-09-18	> Option for drop p-value in print
*version 0.2.1	2018-09-18	> Option for drop total in print
*version 0.2.1	2018-09-17	> Hidesmall for for missings
*version 0.2.0	2017-08-31	> Option pvalueformat is changed to pvformat (as used in the documentation)
*version 0.1.9	2017-03-12	> Bug calculating slct in basetable::n_pct_by_value() fixed
*version 0.1.9	2017-07-26	> Problem with . and : in nhb_sae_summary_row() in variable labels solved for version 14 and up
*version 0.1.9	2017-07-17	> Bug in nhb_msa_variable_description() and nhb_mt_matrix_v_sep() regarding value labels fixed
*version 0.1.9	2017-06-09	> bugfix when repeating basetable after style md
*version 0.1.9	2017-06-09	> latex tablefit in nhb_mt_mata_string_matrix_styled
*version 0.1.8	2017-03-21	> Thousands separator count. Claus Hørup
*version 0.1.8	2017-03-12	> Code partly based on lmatrixtools
*version 0.1.8	2017-03-12	> CI for proportions. Christine Geyti
*version 0.1.8	2017-03-12	> Test values with different decimals, default 2. Christine Geyti
*version 0.1.8	2017-03-12	> col/row pct to col/row %. Christine Geyti
*version 0.1.8	2017-01-18  > Handling all missing values for a variable
*version 0.1.7	2016-09-01	> summarize_by() in lbasetable, all continous variables: Now total correct, when colvar has missing values
*version 0.1.7	2016-09-01	> Error in using output corrected
*version 0.1.7	2016-09-01	> MD modified
*version 0.1.7	2016-09-01	> Caption added
*version 0.1.6	2016-02-24	> Runs at version 12
*version 0.1.6	2016-02-24	> Local if in headers! NOT local in -  can't be controlled. Note error text from comparing medians !!!!
*version 0.1.6	2016-02-24	> Output as xl, csv, md, html and LaTex
*version 0.1.6	2016-02-24	> Option Using together with output except xl - replace append
*version 0.1.6	2016-02-24	> Validate Continousreport and style
*version 0.1.5	2016-02-24	> Most Mata code back in mlib
*version 0.1.41	17dec2015	> Bug with value label has to have same name as variable fixed. Thank you to Richard Goldstein
*version 0.1.41	17dec2015	> Function to validate variable refined
*version 0.1.4	02nov2015	> Global if and in are added, nhb
*version 0.1.4	02nov2015	> Better (as text row/col) marker row/col total in n_pct_by, nhb
*version 0.1.4	02nov2015	> Local type of summary for continous variables. Thank you to Pia Deichgræber
*version 0.1.4	02nov2015	> replace for book and sheet. Thank you to Georgios Bouliotis and Pia Deichgræber
*version 0.1.4	02nov2015	> Tabulate function like summary_by, nhb
*version 0.1.4	02nov2015	> Function summary_by as base for continous variables, nhb
*version 0.1.4	02nov2015	> pi prediction interval, nhb
*version 0.1.4	02nov2015	> iqi interquartile interval, nhb
*version 0.1.4	02nov2015	> Handle when Stata do not return all columns, crashes now - ignored report, nhb
*version 0.1.4	02nov2015	> Hidesmall works on totals, nhb
*version 0.1.4	02nov2015	> Insert Header, nhb
*version 0.1.4	02nov2015	> Logging optional, nhb
*version 0.1.4	02nov2015	> Missing table optional. Thank you to Richard Goldstein
*version 0.1.4	02nov2015	> Move all Mata to basetable.ado, nhb 
*version 0.1.31	13aug2015	> Bug with hidesmall fixed. Thank you to Georgios Bouliotis
*version 0.1.3	05aug2015	> Total and missing report added
*version 0.1.2	06may2015	> toxl is moved from mlib to ado file due to version 14. Tahnk you to Eric Melse

version 12

program define basetable
	* input_list is required by syntax, so input_list is not empty 
	syntax anything(name=input_list) [if] [in] [using/]/*
		*/[,/*
			*/Toxl(string) /*
			*/Nthousands /*
			*/PCtformat(string) /*
			*/PVformat(string) /*
			*/Continuousreport(string) /*
			*/CAPtion(string) /*
			*/top(string) /*
			*/undertop(string) /*
			*/bottom(string) /*
			*/Log /*
			*/Missing /*
			*/Hidesmall /*
			*/SMOothdata /*
			*/SMall(integer 5) /*
			*/STyle(string) /*
			*/Replace /*
			*/noPvalue /*
			*/noTotal /*
		*/]
	
	local QUIETLY "quietly"
	if "`log'" == "log" local QUIETLY ""
	if !inlist("`continousreport'", "", "sd", "iqr", "iqi", "ci", "pi") {
		display `"{error}The value of continousreport must be one of sd, iqr, iqi, ci, pi. Not "`continousreport'""'
		display "The value of continousreport is set to default, sd"
		local continousreport sd
	}
	if !inlist("`style'", "", "smcl", "csv", "html", "latex", "tex", "md") {
		display `"{error}The value of style must be one of smcl, csv, html, latex or tex, or md. Not "`style'""'
		display "The value of style is set to the default: smcl"
		local style smcl
	}
	mata: hide = ("`hidesmall'" == "hidesmall" ? strtoreal("`small'") : 0)
	mata: smooth_width = ("`smoothdata'" == "smoothdata" ? strtoreal("`small'") : 0)
	mata: st_local("nformat", "`nthousands'" != "" ? "%500.0fc" : "%500.0f")
	mata: st_local("pctformat", st_isnumfmt("`pctformat'") ? "`pctformat'" : "%6.1f")
	
	mata: pvformat = "`pvformat'"
	mata: pv_to_top = regexm(pvformat, "^(.*), *to?p?$")
	mata: pvformat = pv_to_top ? regexs(1) : pvformat
	mata: st_local("pvformat", st_isnumfmt(pvformat) ? pvformat : "%6.2f")

	`QUIETLY' mata: tbl = basetable_parser("`input_list'", "`nformat'", "`pctformat'", ///
		"`pvformat'", pv_to_top, "`continuousreport'", hide, smooth_width, ///
		"`missing'" == "missing", `"`if'"', `"`in'"')
	mata: tbl.log_print("`style'", "`using'", "`replace'" != "", ///
						"`caption'", "`top'", "`undertop'", "`bottom'", ///
						"`pvalue'" != "", "`total'" != "")
	if "`toxl'" != "" {
		capture mata: findexternal("__basetable_to_xl()")
		local toxl_exists = _rc != 0
		if `c(stata_version)' >= 13 & `c(stata_version)' < 14 {
			capture quietly findfile "basetable2xlv13.mata", path(`".;`c(adopath)'"')
		}
		else if `c(stata_version)' >= 14 {
			capture quietly findfile "basetable2xlv14.mata", path(`".;`c(adopath)'"')
		}
		else {
			display "{error:Option toxl do not work in version 12 for Stata.}" 
			display "Specify an csv output file at the {help using:using} modifier combined with the option style(csv) instead"
		}
		if "`r(fn)'" != "" & !`toxl_exists' run `"`r(fn)'"'
		if `c(stata_version)' >= 13 mata: __basetable_to_xl(tbl, "`toxl'", "`pvalue'" != "", "`total'" != "")
		if inlist("`style'", "", "smcl") display "Table send to Excel succesfully..." _n
	} 
end
