* version 1.0  07feb2018  David Fisher
*! version 1.1  08nov2018  David Fisher
*! based on geo2xy_run.ado by Robert Picard, picard@netbox.com

program define admetan_hlp_run

	version 11
	
	** Notes on "preserve/restore" behaviour:
	// 1. The default (i.e. specifying nothing) is to preserve the data originally in memory (assumed to be the user's own data)
	//        before reading in the contents of the help file and running it.
	//      Hence, the resulting example code should be entirely "self-sufficient", loading its own example data if necessary
	//        and the data orignally in memory will be restored upon completion.
	// 2. Specifying -restnot- cancels -preserve- once the contents of the help file have been run.
	// 3. Specifying -restpres- preserves the data originally in memory as above,
	//      but restores and *re-preserves* that data before running the code.
	//      Hence, the code is intended to apply to the data in memory at the time admetan_hlp_run was called.
	// 4. Specifying -restpresnot- is equivalent to specifying -restnot- and -restpres- together;
	//      which leaves behind the data originally in memory, but "damaged" by the contents of the help file.
	
	syntax anything(name=example_name id="example name") using/ ///
		, [RESTNOT RESTPRES RESTPRESNOT LIST]
	
	quietly {
		findfile `"`using'"'
		preserve
		
		// read in contents of help file
		infix str txt 1-244 using `"`r(fn)'"', clear
		replace txt = trim(txt)

		// identify example_start and example_end limits 
		gen long obs = _n
		summ obs if strpos(txt, "{* example_start - `example_name'}{...}")
		if r(min) == . {
			disp as err "example `example_name' not found"
			exit 111
		}
		local pos1 = r(min) + 1

		summ obs if strpos(txt, "{* example_end}{...}") & obs > `pos1'
		if r(min) == . {
			disp as err "example `example_name' incorrectly coded"
			exit 111
		}
		local pos2 = r(min) - 1
		keep in `pos1'/`pos2'
		replace obs = _n
		
		// In general, do-file command lines should *not* start with "{" or end with "}"
		// instead, the characters {} should be identifiers of SMCL.
		
		// Examples of specific patterns of SMCL to identify:
		//   {* comment} or {* comment}{directive}
		//   {directive:output} or {directive:output}{directive}
		//   {directive:output}{* comment} or {directive:output}{* comment}{directive}
		//   {c output} or {char output}
		
		// Strategy:
		// - Identify sets of brackets, i.e. {content}
		// - For each set of brackets, isolate content and test for {directive:output} or {* comment};
		//     if so, keep content; else, drop
		//     exception is {c output} or {char output}; these need conversion back to their original characters (see below)

		// Problem 1: what if SMCL tags {} are used for other purposes, e.g. loops within Stata commands?
		// Solution: onus is on help-file authors to replace such characters with {c -(} and {c -)} respectively.
		// These can then be converted back to {} before the final do-file is run.
		
		// Problem 2: how to deal with "{* ...}" ??  "..." could be either SMCL or Stata; no way to know in advance.
		// Solution: onus is on help-file authors not to use the syntax "{* [SMCL directive]}" within "example limits".
	
		gen str newtxt = ""
		gen str content = ""
		gen int strpos = .
		count if regexm(txt, "{")
		while r(N) {
			
			// identify anything before the next {
			replace strpos = cond(strpos(txt, "{"), strpos(txt, "{"), .)
			replace newtxt = newtxt + substr(txt, 1, strpos-1)
			replace txt = substr(txt, cond(strpos, strpos, 1), .)		// keep the "{" for matching with "}"

			// identify content within the next {}
			replace strpos = strpos(txt, "}")
			cap assert (strpos>0) == (substr(txt, 1, 1)=="{")
			if _rc {
				nois disp as err "found unpaired SMCL tags {}"
				nois list txt if (strpos>0) != (substr(txt, 1, 1)=="{")
				exit 132
			}
			replace content = trim(substr(txt, 1, strpos)) if substr(txt, 1, 1)=="{"
			replace txt = substr(txt, cond(strpos, strpos+1, 1), .)		// remaining part of original text

			// analyse content; look for {directive:output}
			replace newtxt = newtxt + regexs(1) if regexm(trim(content), "^{[a-z0-9_ ]+:(.*)}$")
			
			// analyse content; look for {* comment}
			replace newtxt = newtxt + regexs(1) if regexm(trim(content), "^{\*(.*)}$")
			
			// analyse content; look for {c ...} or {char ...}; add these wholesale to newtxt
			replace newtxt = newtxt + content if regexm(trim(content), "^{c (.*)}$") | regexm(trim(content), "^{char (.*)}$")

			// reset
			replace strpos = .
			replace content = ""
			
			// check for further tags in original text string;
			//   if yes, loop again
			// otherwise, add anything from the end, then check for *nested* tags in newtxt
			//   this must be done eventually; and from then on the useful code is stored in txt, not newtxt
			//   (hence:  drop if txt=="" )
			count if regexm(txt, "{")
			if !r(N) {
				replace newtxt = newtxt + txt
				drop txt
				rename newtxt txt
				gen str newtxt = ""
				count if regexm(txt, "{")
			}
		}
		drop if txt==""
		
		// tidy up:
		//  - convert SMCL characters to standard characters
		//  - remove initial periods, if present
		replace txt = subinstr(txt, "{c -(}", "{", .)
		replace txt = subinstr(txt, "{c -)}", "}", .)
		replace txt = subinstr(txt, "{c S|}", "$", .)
		replace txt = subinstr(txt, "{c 'g}", "`", .)
		replace txt = trim(subinstr(txt, ".", "", 1)) if substr(trim(txt), 1, 1)=="."
		
	}	// end quietly

	// Optionally list contents of do-file to be run
	if `"`list'"'!=`""' {
		disp _n _c
		format txt %-1s
		list txt, clean noheader
	}
	
	tempfile f
	outfile txt using "`f'", noquote
	if `"`restpres'`restpresnot'"'!=`""' {
		restore, preserve
	}
	
	disp _newline(2) as txt "{hline 27} {it:example do-file content} {hline 27}"
	do "`f'"
	disp as txt _n "{hline 23} {it:end of example do-file content} {hline 24}" _newline(2)

	if `"`restnot'`restpresnot'"'!=`""' {
		restore, not
	}
	
end
