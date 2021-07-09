*! version 1.9  Writes codebook to html file - 23Jun2010
program define cb2html, nclass
	version 10
	syntax [varlist] using/ [, replace TItle(str) PPrecision(integer 0) ///
            Fprecision(integer 0) SPrecision(integer 0) Upper Vallabel ///
		Maxvalues(integer 10) Notes TYpe COmbine(varlist min=2 max=2) ///
		PAgebreak(integer 0) STringmax(integer 0) SUmmarize(integer 0)]

	preserve

	// Check name of "using" file and remove .html suffix and all quotes.
	// Thanks to Kit Baum and Nick Cox for many ideas used in this program,
	// especially for this suffix-checking section.

	local using : subinstr local using ".html" "" 
	local using : subinstr local using ".htm" "" 
	local using : subinstr local using ".HTML" ""
	local using : subinstr local using ".HTM" ""
	local using : subinstr local using `"""' "", all /* '"' (for fooling emacs) */
	local using : subinstr local using "`" "", all 
	local using : subinstr local using "'" "", all 

	// If the "using" file exists, and the "replace" option isn't specified,
	// stop the program and tell the user to specify "replace".

	local usingflag = 0
	capture confirm file "`using'.html"
	if _rc==0 {
		local usingflag = 1
	}
	if `usingflag' == 1 & "`replace'" ~= "replace" {
		di as error "The using file `using'.html already exists."
		di as text "If you want to write over it, use the 'replace' option."
		restore
		exit
	}
      if `fprecision' < 0 | `fprecision' > 22 {
            di as error "The value of fprecision must be an integer in the range 0 - 22."
            restore
            exit
      }
      if `sprecision' < 0 | `sprecision' > 22 {
            di as error "The value of sprecision must be an integer in the range 0 - 22."
            restore
            exit
      }

	// Create a temporary file to write the html into.

	tempname ho
	tempfile tempho
	local outfile "`tempho'"
	file open `ho' using `"`outfile'"',w 

	// Write the html header info including the title. Use the user-supplied
	// title if supplied, otherwise use the data label.

	file write `ho' `"<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">"' _n
	file write `ho' "<html>" _n "<head>" _n

	if `"`title'"' ~= "" {
		file write `ho' `"<title>`title'</title>"' _n
	}
	else {
		local datalab : data label
		if `"`datalab'"' ~= "" {
			file write `ho' `"<title>`datalab'</title>"' _n
		}
	}

	file write `ho' `"<meta http-equiv="Content-type" content="text/html; charset=iso-8859-1">"' _n
	file write `ho' `"<meta http-equiv="Content-Style-Type" content="text/css">"' _n
	file write `ho' `"<STYLE TYPE="text/css">"' _n
	file write `ho' "  P.breakhere {page-break-before: always}" _n
	file write `ho' "</STYLE>" _n
	file write `ho' "</head>" _n



	// *** Start the html body ***

	file write `ho' "<body>" _n


	// HEADER: print the data label and first data note 

	// First print the data label, if one exists.
	// It should be used to identify the survey name and year.

	local datalab : data label
	if `"`datalab'"' ~= "" {

		file write `ho' `"<table cellpadding="6" cellspacing="2" border="1" style="text-align: center; width: 100%">"' _n
  		file write `ho' "   <tbody>" _n
  		file write `ho' "      <tr>" _n
		file write `ho' `"         <td style="vertical-align: top; width: 100%; font-family: times new roman,times,serif;">"' _n 
  		file write `ho' "            ""<h2>"`"`datalab'"'"</h2>" _n
  		file write `ho' "          </td>" _n
  		file write `ho' "      </tr>" _n
  		file write `ho' "   </tbody>" _n
  		file write `ho' "</table>" _n

	}
	else if `"`title'"' ~= "" {

		file write `ho' `"<table cellpadding="6" cellspacing="2" border="1" style="text-align: center; width: 100%">"' _n
  		file write `ho' "   <tbody>" _n
  		file write `ho' "      <tr>" _n
		file write `ho' `"         <td style="vertical-align: top; width: 100%; font-family: times new roman,times,serif;">"' _n 
  		file write `ho' "            ""<b>"`"`title'"'"</b>" _n
  		file write `ho' "          </td>" _n
  		file write `ho' "      </tr>" _n
  		file write `ho' "   </tbody>" _n
  		file write `ho' "</table>" _n

	}


	// Make a label addition for "maxvalues" variables, which can be 
	// concatenated to note1 and variable label as needed.

	local maxlabel = "NOTE: Smallest 5 and largest 5 values are displayed."

	// Make a label addition for strtype == "str" variables, which can be
	// concatenated to variable label when summary statistics are requested.

	local strlabel = "NOTE: Cannot create summary statistics for a string variable"

	// Check if there is a data note1 and "notes" is turned on.
	// If so, assume note1 is something the owner wants to print,
	// such as a section heading (Add Health format).

	local datanote : char _dta[note1]
	if `"`datanote'"' ~= "" & "`notes'" ~= "" {

		file write `ho' `"<table cellpadding="6" cellspacing="2" border="1" style="text-align: left; width: 100%">"' _n
  		file write `ho' "   <tbody>" _n
  		file write `ho' "      <tr>" _n
		file write `ho' `"         <td style="vertical-align: top; width: 100%; font-family: times new roman,times,serif;">"' _n 
  		file write `ho' "            "`"`datanote'"' _n
  		file write `ho' "          </td>" _n
  		file write `ho' "      </tr>" _n
  		file write `ho' "   </tbody>" _n
  		file write `ho' "</table>" _n

	}

      qui des, short
	local numobs = r(N)

		file write `ho' `"<table cellpadding="6" cellspacing="2" border="1" style="text-align: left; width: 100%">"' _n
  		file write `ho' "   <tbody>" _n
  		file write `ho' "      <tr>" _n
		file write `ho' `"         <td style="vertical-align: top; width: 100%; font-family: times new roman,times,serif;">"' _n 
  		file write `ho' "            "`"Number of observations: "' %20.0gc (`numobs') _n
  		file write `ho' "          </td>" _n
  		file write `ho' "      </tr>" _n
  		file write `ho' "   </tbody>" _n
  		file write `ho' "</table>" _n

	// If "combine" is on, get names of variables to be combined. 

	if "`combine'" ~= "" {
		local combsep1 = strpos("`combine'"," ") - 1
		local combsep2 = `combsep1' + 2
		local comblength = length("`combine'")
		local comb1 = substr("`combine'",1,`combsep1')
		local comb2 = substr("`combine'",`combsep2',`comblength')
	}
	local combflag = 0

	// Macros for user feedback.

	local totalvar : word count `varlist'
	local countvar = 0
	local quarter = 0
	local half = 0
	local threeqtr = 0
	di as text "`totalvar' variables will be written to the codebook."
	di as text "Writing the html file..."

	// Initialize count variable for number of lines per page, 
	// and start a new page for the first variable.

	local lines = 0
	file write `ho' "<br><br>" _n
	if `pagebreak' ~= 0 {
		file write `ho' `"<P CLASS="breakhere">"' _n
	}
	local firstvar = 1


	// ************************************************
	// ***** Loop over each variable in `varlist' *****
	// ************************************************

	foreach v of varlist `varlist' {

		local newlines = 0
		local vartype : type `v'
		local strtype = substr("`vartype'",1,3)


	// Give user some feedback on progress
            di as text " `v' "

		local countvar = `countvar' + 1
		local pctvar = `countvar'/`totalvar'
		if `pctvar' > 0.25 & `quarter' == 0 {
			local quarter = 1
                  di as text " "
			di as text "25% of file written..."
                  di as text " "
		}
		if `pctvar' > 0.5 & `half' == 0 {
			local half = 1
                  di as text " "
			di as text "50% of file written..."
                  di as text " "
		}
		if `pctvar' > 0.75 & `threeqtr' == 0 {
			local threeqtr = 1
                  di as text " "
			di as text "75% of file written..."
                  di as text " "
		}

	// If "combine" is on, and "v" is the first combine variable, 
	// combine the variables named and substitute "combined" for "v".
	// Don't print either of those vars, only print the combined variable.

		if "`combine'" ~= "" & (("`v'" == "`comb1'") | ("`v'" == "`comb2'")) {
			local vartype1 : type `comb1'
			local vartype2 : type `comb2'
			local strtype1 = substr("`vartype1'",1,3)
			local strtype2 = substr("`vartype2'",1,3)
			if "`strtype1'" == "str" & "`strtype2'" == "str" {
				gen str`comblength' combined = `comb1'+","+`comb2'
			}
			if "`strtype1'" == "str" & "`strtype2'" ~= "str" {
				gen str`comblength' combined = `comb1'+","+string(`comb2')
			}
			if "`strtype1'" ~= "str" & "`strtype2'" == "str" {
				gen str`comblength' combined = string(`comb1')+","+`comb2'
			}
			if "`strtype1'" ~= "str" & "`strtype2'" ~= "str" {
				gen str`comblength' combined = string(`comb1')+","+string(`comb2')
			}

	// Combine the variable labels and put them into a note for combined var.

			lab var combined "`comb1' combined with `comb2'"
			local varlab : variable label `comb1'
			local labpiece1 : piece 1 73 of `"`varlab'"'
			local labpiece2 : piece 2 73 of `"`varlab'"'
			local varlab : variable label `comb2'
			local labpiece3 : piece 1 73 of `"`varlab'"'
			local labpiece4 : piece 2 73 of `"`varlab'"'
			note combined: `labpiece1' `labpiece2' combined with ///
				`labpiece3' `labpiece4'

			if `combflag' == 1 {
				local combflag = 2
			}
			if `combflag' == 0 {
				local v = "combined"
				local combflag = 1
			}
		}

	// Do the remainder for all except the second combine variable.

		if `combflag' ~= 2 {

	// Calculate frequencies and percents - uses code from Nick Cox
	// that he supplied for checkvar - more efficient than how I was doing it.

		keep `v' 
		tempvar freq denom pct	
		gen `denom' = _N
		sort `v'
		by `v': gen `freq' = _N
		by `v': gen `pct' = (`freq' / `denom') * 100

	// Count number of distinct values in this var using egen's group function.
	// Figure out whether to do a frequencies or summarize on this var,
	// based on whether number of distinct values is <> summarize.
	// Only collapse file if doing a frequencies (values < summarize)
	// or if the user set a characteristic [freq] == "Yes".  **********************************************

		local freqchar : char `v'[freq] // get char [freq] 
        if `"`freqchar'"' == "yes" {
		    local freqchar = "Yes"
		}
		tempvar groupnum
		tempvar numgrps
		quietly egen `groupnum' = group(`v')
		quietly egen `numgrps' = max(`groupnum')
		if `numgrps' > `summarize' & `summarize' > 0 {
			local values = `numgrps'
		}
		if `numgrps' <= `summarize' | `summarize' == 0 | "`strtype'" == "str" | `"`freqchar'"' == "Yes" {
			quietly by `v': keep if _n == 1
			local values = _N
		}

	// Check number of values for this variable against maxvalues.

		local max = 0
		if `maxvalues' <10 {
			local maxvalues = 10
		}
		if `values' > `maxvalues' & `values'~=. {
			local max = 1
		}
		if `values' ==. {
			local max = 2
		}

	// Check number of values for this variable against summarize.

		local tab = 0
		if `values' > `summarize' & `summarize' > 0 & `"`freqchar'"' ~= "Yes"{
			local tab = 1
		}

		local gotlabel : value label `v'

	// Variable labels and notes

		local varnote : char `v'[note1]
		local skipnote : char `v'[note2]
		local prenote : char `v'[note3]
		local varlab : variable label `v'
		if `"`varnote'"' ~= "" & "`notes'" ~= "" {
			local varlabel `varnote'
		}
		else {
			local varlabel `varlab'
			if `"`varlab'"' == "" {
				local varlabel "&nbsp;"
			}
		}

	// If user supplied a value other than 0 for pagebreak, 
	// check whether there should be a page break here.
	// If there's a skipnote or prenote, estimate its lines and add to newlines.

		if `pagebreak' ~= 0 {
			if `"`skipnote'"' ~= "" & "`notes'" ~= "" {
				local notelength : length local skipnote
				local notelines = `notelength'/100
				local notelines = int(`notelines') + 1
				local newlines = `newlines' + `notelines' + 2
			}
			if `"`prenote'"' ~= "" & "`notes'" ~= "" {
				local notelength : length local prenote
				local notelines = `notelength'/100
				local notelines = int(`notelines') + 1
				local newlines = `newlines' + `notelines' + 2
			}
		
	// If there's a var note or label, estimate its lines and add to newlines.
	// This includes the var name and type, so it's a minimum of 3 lines.

			local vlablength : length local varlabel
			local vlablines = `vlablength'/60
			local vlablines = int(`vlablines') + 1
			local newlines = `newlines' + `vlablines' + 2

	// If the number of values exceeds maxvalues, then max=1,
	// so add 1 to newlines for the maxvalues Note in the variable label.

			if `max' ==1 {
				local newlines = `newlines' + 1
			}

	// Add 2 to newlines for the column header.

			local newlines = `newlines' + 2

	// Check length of value labels and add number of lines 
	// for each value to newlines.

			if `"`gotlabel'"' ~= "" {
				if `max' ~= 1 & `max' ~= 2 {
					forval i = 1/`values' {
						local x = `v'[`i']
						local vallab : label (`v') `x'
						local lablen : length local vallab
					local lablines = `lablen'/60
					local lablines = int(`lablines') + 1
					local newlines = `newlines' + `lablines' + 1
					}
				}
				if `max' == 1 {
					forval i = 1/`values' {
						if (`i' <=5) | (`i' >= (`values' - 4)) {
							local x = `v'[`i']
							local vallab : label (`v') `x'
							local lablen : length local vallab
							local lablines = `lablen'/60
							local lablines = int(`lablines') + 1
							local newlines = `newlines' + `lablines' + 1
						}
					}
				} 
				if `max' == 2 {
					local x = "."
					local vallab = "."
					local lablen = 1
					local lablines = `lablen'/60
					local lablines = int(`lablines') + 1
					local newlines = `newlines' + `lablines' + 1
				} 
			}
			if `"`gotlabel'"' == "" {
				if `max' ~= 1 {
					local newlines = `newlines' + (`values' *2)
				}
				if `max' == 1 {
					local newlines = `newlines' + 20
				}
			} 

	// Add 1 line for a space after this variable table.

			local newlines = `newlines' + 1

	// Add newlines to lines for this page and check against pagebreak.
	// If it's larger, table for this variable won't fit on this page, 
	// so write a pagebreak.

			local lines = `lines' + `newlines'
			if `lines' >= `pagebreak' {
				if `firstvar' ~= 1 {
					file write `ho' `"<P CLASS="breakhere">"' _n
				}
				if `newlines' <= `pagebreak' {
					local lines = `newlines'
				}
				if `newlines' > `pagebreak' {
					local lines = `newlines' - `pagebreak'
				}
			}

		} // end of pagebreak check

	// Check if there is a note3 and "notes" is turned on.
	// If so, print it in its own table before note 2 and the header for the question itself.

		if `"`prenote'"' ~= "" & "`notes'" ~= "" {

			file write `ho' `"<table cellpadding="6" cellspacing="2" border="1" style="text-align: left; width: 100%">"' _n
  			file write `ho' "   <tbody>" _n
  			file write `ho' "      <tr>" _n
			file write `ho' `"         <td style="vertical-align: top; width: 100%; font-family: times new roman,times,serif;">"' _n 
  			file write `ho' "            ""<b>" `"`prenote'"' "</b>" _n
  			file write `ho' "          </td>" _n
  			file write `ho' "      </tr>" _n
			file write `ho' "   </tbody>" _n
			file write `ho' "</table>" _n

		}

	// Check if there is a note2 and "notes" is turned on.
	// If so, print it in its own table before the header for the question itself.

		if `"`skipnote'"' ~= "" & "`notes'" ~= "" {

			file write `ho' `"<table cellpadding="6" cellspacing="2" border="1" style="text-align: left; width: 100%">"' _n
  			file write `ho' "   <tbody>" _n
  			file write `ho' "      <tr>" _n
			file write `ho' `"         <td style="vertical-align: top; width: 100%; font-family: times new roman,times,serif;">"' _n 
  			file write `ho' "            ""<b><i>" `"`skipnote'"' "</i></b>" _n
  			file write `ho' "          </td>" _n
  			file write `ho' "      </tr>" _n
			file write `ho' "   </tbody>" _n
			file write `ho' "</table>" _n

		}

	// Start a new table for this variable.

		file write `ho' `"<table cellpadding="6" cellspacing="2" border="1" style="text-align: left; width: 100%">"' _n
  		file write `ho' "   <tbody>" _n


	// Figure out size of strings.

		local vartype : type `v'
		local strtype = substr("`vartype'",1,3)
		if "`strtype'" == "str" {
			local lengthtype = length("`vartype'") - 3
			local strlength = substr("`vartype'",4,`lengthtype')
		}

	// If "type" is not turned on, then create universal format
	// for variable storage (num or string, and length).
	// Otherwise, print Stata's variable type (byte, float, etc.).

		if "`type'" == "" {
			if "`vartype'" == "byte" {
				local vartype = "Num"
			}
			else if "`vartype'" == "int" {
				local vartype = "Num"
			}
			else if "`vartype'" == "long" {
				local vartype = "Num"
			}
			else if "`vartype'" == "float" {
				local vartype = "Num"
			}
			else if "`vartype'" == "double" {
				local vartype = "Num"
			}
			else {
				local stype = "Char "
				local vartype = "`stype'"
			}
		}

      // Check whether user wants the variable name printed in upper case.

		local varname = "`v'"
            if "`upper'" != "" {
                  local varname = upper("`v'")
            }


	// HEADER: print the variable name and label for each variable.

	// Check if there is a note1 and "notes" is turned on. 
	// If so, assume note1 is the text of the question, and 
	// print it as the header information.
	// If note1 doesn't exist, or "notes" isn't turned on,
	// print the variable label (which might be a null string).
	// Print variable name and type after the note/label.

	// tab=0 is frequencies, tab=1 is means

		if `tab' == 0 | "`strtype'" == "str"  {
  			file write `ho' "      <tr>" _n
			file write `ho' `"         <td style="vertical-align: top; width: 10%; font-family: times new roman,times,serif;">"' _n 
  			file write `ho' "            ""<b>`varname'</b>" _n
  			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; width: 7%; font-family: times new roman,times,serif;">"' _n 
  			file write `ho' "            ""&nbsp;" _n
  			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; width: 12%; font-family: times new roman,times,serif;">"' _n 
  			file write `ho' "            ""`vartype'" _n
  			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; font-family: times new roman,times,serif;">"' _n 
  			file write `ho' "            ""`varlabel'" _n
			if `max' == 1 & `"`freqchar'"' ~= "Yes" file write `ho' "            ""<br>`maxlabel'" _n
			file write `ho' "          </td>" _n
  			file write `ho' "      </tr>" _n
		}
		if `tab' == 1 & "`strtype'" ~= "str" {
  			file write `ho' "      <tr>" _n
			file write `ho' `"         <td style="vertical-align: top; width: 10%; font-family: times new roman,times,serif;">"' _n 
  			file write `ho' "            ""<b>`varname'</b>" _n
  			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; width: 10%; font-family: times new roman,times,serif;">"' _n 
  			file write `ho' "            ""`vartype'" _n
  			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; width: 10%; font-family: times new roman,times,serif;">"' _n 
  			file write `ho' "            ""&nbsp;" _n
  			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; width: 10%; font-family: times new roman,times,serif;">"' _n 
			file write `ho' "            ""&nbsp;" _n
			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; font-family: times new roman,times,serif;">"' _n 
  			file write `ho' "            ""`varlabel'" _n
			file write `ho' "          </td>" _n
  			file write `ho' "      </tr>" _n
		}


	// Write column headers 
	// If values <= summarize or variable is string, write headers for frequency, percent, value, and label 

		if `tab' == 0 | "`strtype'" == "str"  {
			file write `ho' "      <tr>" _n
			file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 10%; font-family: times new roman,times,serif;">"' _n 
			file write `ho' "             ""Frequency" _n
			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 7%; font-family: times new roman,times,serif;">"' _n 
			file write `ho' "             ""Percent" _n
			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 12%; font-family: times new roman,times,serif;">"' _n 
			file write `ho' "             ""Value" _n
			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; text-align: left; font-family: times new roman,times,serif;">"' _n 
			file write `ho' "             ""Label" _n
			file write `ho' "          </td>" _n
			file write `ho' "      </tr>" _n
		}

	// If values > summarize, write headers for frequency, mean, std dev, min, and max 

		if `tab' == 1 & "`strtype'" ~= "str"  {
			file write `ho' "      <tr>" _n
			file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 10%; font-family: times new roman,times,serif;">"' _n 
			file write `ho' "             ""Frequency" _n
			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 10%; font-family: times new roman,times,serif;">"' _n 
			file write `ho' "             ""Mean" _n
			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 10%; font-family: times new roman,times,serif;">"' _n 
			file write `ho' "             ""Std Dev" _n
			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 10%; font-family: times new roman,times,serif;">"' _n 
			file write `ho' "             ""Min" _n
			file write `ho' "          </td>" _n
			file write `ho' `"         <td style="vertical-align: top; text-align: left; font-family: times new roman,times,serif;">"' _n 
			file write `ho' "             ""Max" _n
			file write `ho' "          </td>" _n
			file write `ho' "      </tr>" _n
		}

		if `"`gotlabel'"' ~= "" {
			local gotlabel = "Yes"
		}
		else {
			local gotlabel = "No"
		}

	// Before first call to DispFreq, replace null value of Vallabel with "No" so the argument has a value.

		if "`vallabel'" == "" {
			local vallabel = "No"
		}

	// If values <= maxvalues, and values <= summarize (or summarize = 0), display frequencies for all values. 
	// When calling DispFreq, "strlength" should be the last argument,
	// since it can be a null string (the others always have a value).

            local range = "0"
		if ((`max' == 0 & (`tab' == 0 | "`strtype'" == "str")) | `"`freqchar'"' == "Yes")  {

			forval i = 1/`values' {

				DispFreq `ho' `v' `i' `range' `freq' `pct' `pprecision' `fprecision' `gotlabel' `vallabel' `vartype' `strtype' `stringmax' `strlength'

			}
		}  

	// If values > maxvalues, and values <= summarize (or summarize = 0), display frequencies of only smallest 5 and largest 5 values.
      // Display a row showing the frequency, percent, and range of the omitted values.
*set tracedepth 1
*set trace on
		if ((`max' == 1 & (`tab' == 0 | "`strtype'" == "str")) & `"`freqchar'"' ~= "Yes")  {

			forval i = 1/`values' {
				if (`i' <=5) {

					DispFreq `ho' `v' `i' `range' `freq' `pct' `pprecision' `fprecision' `gotlabel' `vallabel' `vartype' `strtype' `stringmax' `strlength'

				}
				if (`i' ==6) {

                              local templabel = "`gotlabel'"
                              local gotlabel = "Range"
                              local x = `v'[`i']
                              local range = "`x'"
                              local rangefreq = `freq'[`i']
                              local rangepct  = `pct'[`i']

                        }
				if (`i' == (`values' - 5) & `i' == 6) {

                              local rndprec = 1
                              local zeros = "00000000000000000000000000000000000000000000000000"
                              if `fprecision' != 0 {
                                   local numzero = `fprecision'-1
                                   local nzero = substr("`zeros'",1,`numzero')
                                   local rndprec = "0." + "`nzero'" + "1"
                              }
                              if "`strtype'" ~= "str" & strpos("`range'",".")~=0 {
                                   local range2 = round(`range',`rndprec')
                                   local rangelength = strpos("`range2'",".")+`fprecision'
                                   local range = substr("`range2'",1,`rangelength')
                              }
					DispFreq `ho' `v' `i' "`range'" `rangefreq' `rangepct' `pprecision' `fprecision' `gotlabel' `vallabel' `vartype' `strtype' `stringmax' `strlength'

				}
				if (`i' > 6 & `i' < (`values' - 5)) {

                              local rangefreq = `rangefreq' + `freq'[`i']
                              local rangepct  = `rangepct'  + `pct'[`i']

                        }

				if (`i' == (`values' - 5) & `i' ~= 6) {

                              local x = `v'[`i']
                              local rndprec = 1
                              local zeros = "00000000000000000000000000000000000000000000000000"
                              if `fprecision' != 0 {
                                   local numzero = `fprecision'-1
                                   local nzero = substr("`zeros'",1,`numzero')
                                   local rndprec = "0." + "`nzero'" + "1"
                              }
                              if "`strtype'" == "str" {
                                   local range = "Values omitted"
                              }
******************************************
                              if "`strtype'" ~= "str" {
                                   local range2 = round(`range',`rndprec')
                                   if strpos("`range2'",".")~=0 {
                                        local rangelength = strpos("`range2'",".")+`fprecision'
                                        local range3 = substr("`range2'",1,`rangelength')
                                   }
                                   if strpos("`range2'",".")==0 {
                                        local range3 = `range2'
                                   }
                                   if strpos("`x'",".")~=0 {
                                        local x = round(`x',`rndprec')                           
                                        local xlength = strpos("`x'",".")+`fprecision'
                                        local x3 = substr("`x'",1,`xlength')
                                   }
                                   if strpos("`x'",".")==0 {
                                        local x3 = `x'
                                   }
                                   local range = "`range3'" + "-" + "`x3'"
                              }
                              local rangefreq = `rangefreq' + `freq'[`i']
                              local rangepct  = `rangepct'  + `pct'[`i']
					DispFreq `ho' `v' `i' "`range'" `rangefreq' `rangepct' `pprecision' `fprecision' `gotlabel' `vallabel' `vartype' `strtype' `stringmax' `strlength'

				}
				if (`i' >= (`values' - 4)) {

                              local gotlabel = "`templabel'"
                              local range = "0"
					DispFreq `ho' `v' `i' "`range'" `freq' `pct' `pprecision' `fprecision' `gotlabel' `vallabel' `vartype' `strtype' `stringmax' `strlength'
				}
			}
		}  
*set trace off
	// If values > summarize, display summary statistics (regardless of maxvalues).

		if `tab' == 1 & "`strtype'" ~= "str" {

			quietly su `v'
			local num  = `r(N)'
                  if `num' ~= 0 {
			     local mean = `r(mean)'
			     local sd   = `r(sd)'
			     local min  = `r(min)'
			     local max  = `r(max)'
                  }
                  if `num' == 0 {
                       local mean = "."
                       local sd   = "."
                       local min  = "."
                       local max  = "."
                  }
			DispSum `ho' `num' `mean' `sd' `min' `max' `sprecision'
		}  


	// Restore the data to get another variable, and preserve it again.

		restore, preserve	

	// Close the table tags for this variable.
 
		file write `ho' "   </tbody>" _n
		file write `ho' "</table>" _n	

	// Put a blank line after writing each variable.

		file write `ho' "<br>"


		}	// end of loop for combflag ~= 2

		if `combflag' == 2 {
			local combflag = 0
		}

		if `firstvar' == 1 {
			local firstvar = 0
		}
	
	}	   // end of varlist loop

	// *******************************************************
	// ***** End of loop over each variable in `varlist' *****
	// *******************************************************

	// Close the body tag and close the output file.

	file write `ho' "</body>" _n "</html>" _n
	file close `ho'

	// If we got this far, the temporary html file has been written, 
	// and we can copy it into the permanent "using" filename.

	local tempflag = 0
	capture confirm file "`tempho'"
	if _rc==0 {
		local tempflag = 1
	}
	if `tempflag' == 1 {
		if "`replace'" == "replace" & `usingflag' == 1 {
			copy "`tempho'" `"`using'.html"', replace
			di as text "File `using'.html replaced"
		}
		else {
			copy "`tempho'" `"`using'.html"'
			di as text "File `using'.html created"
		}
	}
	else {
		di as error "The html file was not written."
		di as text "Please contact phil_bardsley@unc.edu"
	}

end


program define DispFreq
	args ho v i range freq pct pprecision fprecision gotlabel vallabel vartype strtype stringmax strlength
*set tracedepth 1
*set trace on

	// If v is a string longer than 10 characters,
	// trim leading and trailing blanks, and truncate to
	// first 10 characters for display.
	// If v is a string and missing, change its value
	// to a single blank, so the cell shows up in html table.

	if "`strtype'" == "str" {
		if `stringmax' > 0 {
			quietly replace `v' = substr(trim(`v'),1,`stringmax') in `i'
		}
		if `v' == "" {
			quietly replace `v' = "&nbsp;" in `i'
		}
	}	

	// Initialize vallab to blank.
	// Put the current value's label into vallab if there is one.
	// Put the current value's value into vallab if vallabel is turned on and there is no label.
	// Write the word "Missing" if the value is a missing numeric or string.

	local vallab = "&nbsp;"
	local flength = `pprecision' + 4
	local pfmt = "%`flength'.`pprecision'f"
      if "`gotlabel'" ~= "Range" {
	      local x = `v'[`i']
      	local f = `freq'[`i']
	      local p = `pct'[`i']
      }
      if "`gotlabel'" == "Range" {
	      local x = "`range'"
            local f = `freq'
            local p = `pct'
            local vallab = "NOTE: Range of values omitted from display"
      }
	local vx = "`v'"
	local vfmt : format `vx'
	local vtx : type `vx'
      local fmtdot = strpos("`vfmt'",".")-2
      local fmt1 = substr("`vfmt'",2,`fmtdot')
*      local fmt1 = `fmt1' + `fprecision' + 20
      local fmt1 = `fmt1' + `fprecision'
      local rndprec = 1*10^-`fprecision'

      if ("`vtx'" == "float" | "`vtx'" == "double") { 
            if `fprecision' != 0 {
                  local vfmt = "%" + "`fmt1'" + "." + "`fprecision'" + "f"
            }
            if `fprecision' == 0 {
                  local vfmt = "%" + "`fmt1'" + "." + "0f"
            }
      }
/*
	if "`gotlabel'" == "Yes" {
		local vallab : label (`v') `x', strict
            if "`vallab'" == "" & "`vallabel'" ~= "No" {
                  local vallab = string(round(`x',`rndprec'))
            }
            if "`vallab'" == "" & "`vallabel'" == "No" {
                  local vallab = "&nbsp;"
            }
	}
	if "`gotlabel'" == "No" & "`strtype'" ~= "str" {
            if "`vallabel'" ~= "No" {
                  local vallab = string(round(`x',`rndprec'))
            }
            if "`vallabel'" == "No" {
                  local vallab = "&nbsp;"
            }
	}
      if "`strtype'" == "str" {
		if "`vallabel'" ~= "No" {
            	local vallab = "`x'"
		}
		if "`vallabel'" == "No" {
            	local vallab = "&nbsp;"
		}
      }
*/
	// Write line v[i] (frequencies, percent, value, and label).
	// (Note: parentheses instead of quotes are required for the percent to be formatted properly.)

	file write `ho' "      <tr>" _n
	file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 10%; font-family: times new roman,times,serif;">"' _n 
	file write `ho' "            " "`f'" _n
	file write `ho' "          </td>" _n
	file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 7%; font-family: times new roman,times,serif;">"' _n 
	file write `ho' "            " `pfmt' (`p') "%" _n
	file write `ho' "          </td>" _n
	file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 12%; font-family: times new roman,times,serif;">"' _n 
	if "`vtx'" == "float" | "`vtx'" == "double" {
            if "`gotlabel'" ~= "Range" {
		      file write `ho' "            " `vfmt' (`x') _n
            }
            if "`gotlabel'" == "Range" {
		      file write `ho' "            " `"`x'"' _n
            }
	}
	else {
		file write `ho' "            " `"`x'"' _n
	}
	file write `ho' "          </td>" _n
	file write `ho' `"         <td style="vertical-align: top; text-align: left; font-family: times new roman,times,serif;">"' _n 
	if "`gotlabel'" == "Yes" {
		local vallab : label (`v') `x', strict
            if "`vallab'" == "" & "`vallabel'" ~= "No" {
			if `x' ~= . {
		      	file write `ho' "            " `vfmt' (`x') _n
			}
			if `x' == . {
                		file write `ho' "            " "Missing" _n
			}
            }
            if "`vallab'" == "" & "`vallabel'" == "No" {
			if `x' ~= . {
		      	file write `ho' "            " "&nbsp;" _n
			}
			if `x' == . {
                		file write `ho' "            " "Missing" _n
			}
            }
            if "`vallab'" ~= "" {
            	file write `ho' "            " "`vallab'"  _n
		}
	}
	if "`gotlabel'" == "No" & "`strtype'" ~= "str" {
            if "`vallabel'" ~= "No" {
			if `x' ~= . {
		      	file write `ho' "            " `vfmt' (`x') _n
			}
			if `x' == . {
                		file write `ho' "            " "Missing" _n
			}
            }
            if "`vallabel'" == "No" {
            	file write `ho' "            " "&nbsp;" _n
            }
	}
      if "`gotlabel'" == "Range" & "`strtype'" ~= "str" { 
           file write `ho' "            " "`vallab'"  _n
      }
      if "`strtype'" == "str" {
		if "`vallabel'" ~= "No" {
            	file write `ho' "            " "`x'" _n
		}
		if "`vallabel'" == "No" {
            	file write `ho' "            " "&nbsp;" _n
		}
      }

	file write `ho' "          </td>" _n
	file write `ho' "      </tr>" _n
*set trace off
end


program define DispSum
	args ho num mean sd min max sprecision

	// Write line v[i] (, percent, value, and label).
	// (Note: parentheses instead of quotes are required when specifying a format, such as sfmt.)
      if `sprecision' != 0 {
            local sfmt = "%" + "23" + "." + "`sprecision'" + "f"
      }
      if `sprecision' == 0 {
            local sfmt = "%" + "23" + "." + "0f"
      }

	file write `ho' "      <tr>" _n
	file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 10%; font-family: times new roman,times,serif;">"' _n 
	file write `ho' "            " "`num'" _n
	file write `ho' "          </td>" _n
	file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 10%; font-family: times new roman,times,serif;">"' _n 
	file write `ho' "            " `sfmt' (`mean') _n
	file write `ho' "          </td>" _n
	file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 10%; font-family: times new roman,times,serif;">"' _n 
	file write `ho' "            " `sfmt' (`sd') _n
	file write `ho' "          </td>" _n
	file write `ho' `"         <td style="vertical-align: top; text-align: right; width: 10%; font-family: times new roman,times,serif;">"' _n 
	file write `ho' "            " `sfmt' (`min') _n
	file write `ho' "          </td>" _n
	file write `ho' `"         <td style="vertical-align: top; text-align: left; font-family: times new roman,times,serif;">"' _n 
	file write `ho' "            " `sfmt' (`max') _n
	file write `ho' "          </td>" _n
	file write `ho' "      </tr>" _n

end

exit

HISTORY

Version 1.9:

23Jun2010

    looks for variable characteristic varname[freq] == "Yes", and if it finds that value it prints
	   all values for the variable regardless of the settings of maxvalues() or summarize()
	define the characteristics like this:
	   foreach v of varlist var1 var2 var3 ... {
          char def `v'[freq] Yes 
       }

Version 1.8:

13Mar2010

	adds option to copy value into label field instead of making it automatic
	reverts to using the format in the dataset instead of imposing a format - if the user
	   wants to avoid scientific notation he must format the variable himself

Version 1.7:

23Feb2010

      formats the label to round those long ugly numbers when the values are stored imprecisely
      added 20 to formats to get rid of scientific notation: local fmt1 = `fmt1' + `fprecision' + 20
         this is a tradeoff - I used the variable's current format up to now, but in a codebook,
         scientific notation is not useful, but this approach is misleading in that the format 
         in the data is much shorter - the real data won't behave the way the codebook suggests

03nov2009

	handles string variables much better now
	writes value as label when there's no value label

11dec2008

      write the name of the current variable to the results screen, so that if there's a problem with the
      note or label, the user knows which variable has the problem

27feb2008

      converted some compound quotes to single quotes for use in version 10

28nov2007

      bug fix for variables with all missing values

11sep2007

	remove 244 character limit on notes 
      option to specify decimal display precision for floating point values (fprecision option)
      option to specify decimal display precision for summarized variables (sprecision option)
      upper case display of variable names (upper option)

Version 1.3:

16jan2007

      added row with range and n when all rows are not displayed (smallest 5/largest 5 condition)
      fixed problem when all obs have missing values for a variable

Version 1.2:

10dec2006

	added note 3 to display more info, such as section headings, pretext, interviewer instructions, etc. 

Version 1.1:

05jan2005

	added summarize option to display summary statistics 

20jan2004

	fixed null variable label error
	no longer truncates string values, and added option to substr them (stringmax)
	uses display format to write float and double variable values
	reduced maxvalues from 100 to 10


Version 1.0 (published in SSC Archive 18jan2004):

08jan2004

	added page-break option for printing

09dec2003

	fixed message when "replace" option used with new files
	improved efficiency using Nick Cox's code (intended for checkvar)
	(got rid of egen altogether)

24nov2003

	made combined-variable logic a little easier to follow
	replaced egen concatenation with string operator concatenation

20jun2003

	long numeric values will push the column over a bit - not sure if I want to
		truncate them, since they'll be rare.
	handles:
		strings: first 10 characters (trims leading and trailing blanks,
			then substrings first 10 characters of what's left),
			but this is easily extended 
		variable labels: 80 characters (max in Stata/SE 8)
		value labels: 244 characters (max in Stata/SE 8)
		notes: the whole thing (max in Stata/SE 8 is 67,784)



