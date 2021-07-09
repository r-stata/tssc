*! 2.0.0 Adam Ross Nelson 10mar2018 // Made ifable, inable, byable, added NUMLab option.
*! 1.0.1 Adam Ross Nelson 20nov2017 // Merged smrfmn, smrcol, and smrtbl to same package
*! 1.0.0 Adam Ross Nelson 01nov2017 // Original version
*! Original author : Adam Ross Nelson
*! Description     : Produces one- or two-way tables (through putdocx).
*! Maintained at   : https://github.com/adamrossnelson/smrput

capture program drop smrtbl
program smrtbl
	
	version 15
	syntax varlist(min=1 max=2) [if] [in] ///
	[, NUMLab NOCond DESCription(string) TItle(string)]
	
	// Test for an active putdocx.
	capture putdocx describe
	if _rc {
		di as error "ERROR: No active docx."
		exit = 119
	}

	// Test that subsample with temp var touse is not empty.
	marksample touse, strok
	quietly count if `touse'
	if `r(N)' == 0 {
		di as error "ERROR: No observations after if or in qualifier."
		error 2000
	}

	local prog_rowvar : word 1 of `varlist'
	local prog_colvar : word 2 of `varlist'

	preserve
	
	qui keep if `touse'	
	local argcnt : word count `varlist'
	
	if "`numlab'" == "numlab" {
		numlabel, add
	}

	/* Produce a two way table */
	if `argcnt' == 2 {
		capture decode `prog_rowvar', gen(dec`prog_rowvar')
		if _rc {
			capture confirm numeric variable `prog_rowvar'
			if !_rc {
				qui tostring `prog_rowvar', gen(dec`prog_rowvar')
			}
			else if _rc {
				gen dec`prog_rowvar' = `prog_rowvar'
			}
		}
		
		capture decode `prog_colvar', gen(dec`prog_colvar')
		if _rc {
			capture confirm numeric variable `prog_colvar'
			if !_rc {
				qui tostring `prog_colvar', gen(dec`prog_colvar')
			}
			else if _rc {
				gen dec`prog_colvar' = `prog_colvar'
			}
		}
		
		tab dec`prog_rowvar' dec`prog_colvar'
		local totrows = `r(r)' + 1
		local totcols = `r(c)' + 1
		if `totrows' > 55 | `totcols' > 20 {
			di as error "ERROR: smrtble supports a maximum of 55 rows and 20 columns."
			di as error "Reduce the number of categories before proceeding."
			exit = 452
		}
		local rowtitle: variable label `prog_rowvar'
		local coltitle: variable label `prog_colvar'
		putdocx paragraph
		putdocx text ("Table title: ")
		// Test for missing title. If no title, provide generic.
		if "`title'" == "" {
			local title = "_`prog_rowvar'_`prog_colvar'_table"
		}
		if "`description'" == "" {
			local description = "smrfmn generated _`1'_tbl varlist : `varlist'"
		}
		putdocx text ("Description: `description'"), linebreak
		putdocx text ("`title'"), italic linebreak 
		putdocx text ("Row variable label: ")
		putdocx text ("`rowtitle'."), italic linebreak 
		putdocx text ("Column variable label: ")
		putdocx text ("`coltitle'."), italic
		smrgivconditions `if' `in', `nocond'
		putdocx table _`prog_rowvar'_`prog_colvar'_table = (`totrows',`totcols')
		qui levelsof dec`prog_rowvar', local(row_names)
		qui levelsof dec`prog_colvar', local(col_names)
		local count = 2
		qui foreach lev in `row_names' {
			putdocx table _`prog_rowvar'_`prog_colvar'_table(`count',1) = ("`lev'")
			local ++count
		}
		local count = 2
		qui foreach lev in `col_names' {
			putdocx table _`prog_rowvar'_`prog_colvar'_table(1,`count') = ("`lev'")
			local ++count
		}
		local rowstep = 2
		local colstep = 2
		qui foreach rlev in `row_names' {
			foreach clev in `col_names' {
				count if dec`prog_rowvar' == "`rlev'" & dec`prog_colvar' == "`clev'"
				local curcnt = `r(N)'
				putdocx table _`prog_rowvar'_`prog_colvar'_table(`rowstep',`colstep') = ("`curcnt'")
				local ++colstep
			}
			local colstep = 2
			local ++rowstep
		}
		di "smrtbl Two-way table production successful. Table named: `description'"
	}
	/* Produce a one way table */
	else if `argcnt' == 1 {
		capture decode `prog_rowvar', gen(dec`prog_rowvar')
		if _rc {
			capture confirm numeric variable `prog_rowvar'
			if !_rc {
				qui tostring `prog_rowvar', gen(dec`prog_rowvar')
			}
			else if _rc {
				gen dec`prog_rowvar' = `prog_rowvar'
			}
		}
		tab dec`prog_rowvar'
		local rowtitle: variable label `prog_rowvar'
		putdocx paragraph
		putdocx text ("Table title: ")
		// Test for missing description. If no description, provide generic.
		if "`description'" == "" {
			local description = "_`prog_rowvar'_`prog_colvar'_table"
		}
		putdocx text ("`description'"), italic linebreak 
		putdocx text ("Row variable label: ")
		putdocx text ("`rowtitle'."), italic
		smrgivconditions `if' `in', `nocond'
		local totrows = `r(r)' + 1
		if `totrows' > 55 {
			di in smcl as error "ERROR: smrtble supports a maximum of 55 rows and 20 columns. Reduce"
			di in smcl as error "the number of categories before proceeding."
			exit = 452
		}
		putdocx table _`prog_rowvar'_table = (`totrows',2)
		qui levelsof dec`prog_rowvar', local(row_names)
		local count = 2
		putdocx table _`prog_rowvar'_table(1,2) = ("Counts")
		qui foreach lev in `row_names' {
			putdocx table _`prog_rowvar'_table(`count',1) = ("`lev'")
			count if dec`prog_rowvar' == "`lev'"
			local curcnt = `r(N)'
			putdocx table _`prog_rowvar'_table(`count',2) = ("`curcnt'")
			local ++count
		}
		di "smrtbl One-way table production successful. Table named: `description'"
	}


	restore

end
