*! 2.0.0 Adam Ross Nelson 10mar2018 // Made ifable, inable, and byable.
*! 1.0.1 Adam Ross Nelson 20nov2017 // Merged smrfmn, smrcol, and smrtbl to same package.
*! 1.0.0 Adam Ross Nelson 05nov2017 // Original version.
*! Original author : Adam Ross Nelson
*! Description     : Produces table of indicator variable statistics (through putdocx).
*! Maintained at   : https://github.com/adamrossnelson/smrput

capture program drop smrcol
program smrcol
	version 15
	syntax varlist(min=1 numeric) [if] [in] [, NOCond DESCription(string) TItle(string)]

	// Test for an active putdocx.
	capture putdocx describe
	if _rc {
		di in smcl as error "ERROR: No active docx."
		exit = 119
	}
	local argcnt : word count `varlist'
	
	// Test that subsample with temp var touse is not empty.
	marksample touse
	quietly count if `touse'
	if `r(N)' == 0 {
		di as error "ERROR: No observations after if or in qualifier."
		error 2000
	}

	// Test that variables are binary 0 or 1.
	foreach cntr in `varlist' {
		capture assert `cntr' == 1 | `cntr' == 0 | `cntr' == .
		if _rc {
			di as error "ERROR: Variables must be numberic & binary."
			di as error "       `cntr' takes values other than 0 or 1"
			exit = 452
		}
	}

	local prog_rowvar : word 1 of `varlist'
	local prog_colvar : word 2 of `varlist'

	preserve
	qui keep if `touse'	

	if "`numlab'" == "numlab" {
		numlabel, add
	}

	putdocx paragraph
	putdocx text ("Table title: ")
	// Test for missing title. If no title, provide generic.
	if "`title'" == "" {
		local title = "_smrcol_table"
	}
	putdocx text ("`title'"), italic linebreak
	// Test for missing description. If no description, provide generic.
	if "`description'" == "" {
		local description = "smrcol generated _smrcol_table varlist: `varlist'"
	}
	putdocx text ("Description: `description'")
	smrgivconditions `if' `in', `nocond'
	local totrows = `argcnt' + 1
	putdocx table _smrcol_table = (`totrows',5)

	putdocx table _smrcol_table(1,2) = ("Missing"), halign(center)
	putdocx table _smrcol_table(1,3) = ("No"), halign(center)
	putdocx table _smrcol_table(1,4) = ("Yes"), halign(center)
	putdocx table _smrcol_table(1,5) = ("Pcnt Yes"), halign(center)

	local cntrow = 2
	foreach cntr in `varlist' {
		local vardesc : variable label `cntr'
		// Handle variables with empty variable label.  If no label, provide generic.
		if "`vardesc'" == "" {
			local vardesc = "Varname: `cntr'"
		}
		qui {
			putdocx table _smrcol_table(`cntrow',1) = ("`vardesc'"), halign(center)
			count if `cntr' == .
			putdocx table _smrcol_table(`cntrow',2) = (`r(N)'), halign(center)
			count if `cntr' == 0
			putdocx table _smrcol_table(`cntrow',3) = (`r(N)'), halign(center)
			count if `cntr' == 1
			putdocx table _smrcol_table(`cntrow',4) = (`r(N)'), halign(center)
			sum `cntr'
			local pcnt_of = round(`r(mean)' * 100,.01)
			putdocx table _smrcol_table(`cntrow',5) = (`pcnt_of'), halign(center)
			local cntrow = `cntrow' + 1
		}
	}


	restore

	di "smrcol Table production successful. Table named: _smrcol_table"
	
end

