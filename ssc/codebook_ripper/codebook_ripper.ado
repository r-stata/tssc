!* version 0.11

version 12

program define codebook_ripper
	/*
	Generate do file with variable specification for variables in column 
	`variable' in spreadsheet `using' in sheet `sheet'. 
	
	Label values are in `label'.
	
	The do file gets the same name as the spreadsheet underscore sheetname with
	extension do.
	*/
	syntax using/, VARiable(name) LABel(name) Sheet(string) ///
		[REName(name) VALuelabels(name) DELimiter(string) EQual_to(string) ///
		NOTes(namelist) noLOWername /// 
		DOFile(string) OUTpath(string) ///
		REPlace RUN DO OPEN]

	preserve
		import excel `"`using'"', sheet("`sheet'") firstrow allstring clear
		
		*** Validating *********************************************************
		unab vlst: *
		local vlst `=subinstr(`"`vlst'"', " ", ", ", .)'

		capture confirm variable `variable'
		if _rc mata: _error("Variable |`variable'| is not in list [`vlst']")
		capture confirm variable `label'
		if _rc mata: _error("Label |`label'| is not in list [`vlst']")
		if "`valuelabels'" != "" {
			capture confirm variable `valuelabels'
			if _rc mata: _error("Valuelabels |`valuelabels'| is not in list [`vlst']")
		}
		
		if "`delimiter'" == "" local delimiter ";"
		if "`equal_to'" == "" local equal_to "="

		if "`dofile'" == "" {
			local dofile `"`=subinstr("`using'", ".xlsx", "_`sheet'.do", .)'"'
			local dofile `"`=subinstr("`dofile'", ".xls", "_`sheet'.do", .)'"'
			if "`outpath'" != "" local dofile `"`outpath'/`dofile'"'
		}
		else {
			local dofile "`outpath'/`dofile'.do"
		}
		
		if "`notes'" != "" {
			foreach var in `notes' {
				capture confirm variable `var'
				if _rc mata: _error("Note |`var'| is not in list [`vlst']")
			}
		}

		*** Do file content generated ******************************************
		mata: do_file_generator("`variable'", "`rename'", `="`lowername'" == ""', "`label'", ///
								"`valuelabels'", "`delimiter'", "`equal_to'", ///
								"`notes'", "`dofile'", `="`replace'" == "replace"')
	restore
	if "`open'" == "open" doedit `"`dofile'"'
	if "`run'" == "run" run `"`dofile'"'
	if "`run'" != "run" & "`do'" == "do" do `"`dofile'"'
end


mata
    function tokensplit(string scalar txt, delimiter)
    {
        string vector  row
        string scalar filter
        row = J(1,0,"")
        filter = sprintf("(.*) *%s *(.*)", delimiter)
        while (regexm(txt, filter)) {
            txt = regexs(1)
            row = regexs(2), row
        }
        row = txt, row
        return(row)
    }
	
	function do_file_generator(	string scalar varcol, 
								string scalar renamecol,
								real scalar name_lower,
								string scalar lblcol, 
								string scalar vlblcol, 
								string scalar delimiter, 
								string scalar equal_to, 
								string scalar strnotes, 
								string scalar dofile, 
								real scalar replace
								)
	{
		real scalar r, R, c, C, fh, rc
		string scalar varname, lbl, vlbl, filter
		string vector oldnames, varnames, lbls, varlabels, notenames, tmp, out
		string matrix notes
		
		varnames = st_sdata(., varcol)
		R = rows(varnames)
		if ( renamecol != "" ) {
			oldnames = varnames
			varnames = st_sdata(., renamecol)
		}
		lbls = strtrim(stritrim(st_sdata(., lblcol)))
		if ( vlblcol != "" ) varlabels = strtrim(stritrim(st_sdata(., vlblcol)))
		if ( strnotes != "" ) {
			notenames = tokens(strnotes)
			notes = st_sdata(., strnotes)
		}
		out = J(0,1,"") 
		filter = sprintf("([0-9]+) *%s *(.+)", equal_to)
		for(r=1;r<=R;r++){
			//varname = strtoname(strtrim(strlower(varnames[r])))
			varname = strtoname(strtrim(varnames[r]))
			if ( name_lower ) varname = strlower(varname)
			if ( varname == "" ) continue
			out = out \ sprintf("*** %s", varname)
			if ( renamecol != "" ) {
				out = out \ sprintf(`"rename %s %s"', oldnames[r], varname)
				out = out \ sprintf("notes %s: renamed from %s", varname, oldnames[r])
			}
			if ( (lbl=lbls[r]) == "" ) lbl = varname
			out = out \ sprintf(`"label variable %s "%s""', varname, lbl)
			if ( vlblcol != "" ) {
				vlbl = ""
				tmp = tokensplit(varlabels[r], delimiter)
				for(c=1;c<=cols(tmp);c++){
					if ( regexm(tmp[c], filter) ) {
						vlbl = sprintf(`"%s%s "%s" "', vlbl, regexs(1), regexs(2))
					}
				}
				if ( vlbl != "" ) {
					out = out \ sprintf("label define %s %s", varname, vlbl)
					out = out \ sprintf("label values %s %s", varname, varname)
				}
			}
			if ( strnotes != "" ) {
				C = cols(notes)
				for(c=1;c<=C;c++){
					out = out \ sprintf("notes %s: %s - %s",	// "notes %s: {red:{bf:%s}} - %s", 
										varname, 
										st_varlabel(notenames[c]), 
										notes[r,c])
				}
			}
			out = out \ ""
		}
		if ( replace ) rc = _unlink(dofile)
		fh = fopen(dofile, "w")
		for(r=1;r<rows(out);r++) fput(fh, out[r])
		fclose(fh)
		if ( replace ) printf(`"Do file "%s" is replaced\n"', dofile)
		else if ( replace ) printf(`"Do file "%s" is written\n"', dofile)
	}
end
