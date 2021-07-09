*! Source code of llog2markup.mlib
*! version 1.0.8 Niels Henrik Bruun	2018-??-??
*!	2018-11-20 > Bug: No code_end or sample_end after last line if needed 
*!	2018-11-20 > Bug when lines starts with | fixed. Bug created 2018-05-08 
*!	2018-05-08 > Code blocks starts with . or : 
*!	2018-05-08 > Validation of log file at log 4 is modified to line 4 or 5 
*! version 1.0.7 Niels Henrik Bruun	2018-02-13
*!	2017-12-07 > Now handling Mata code lines. 
*!				 Mata code blocks should be surrounded by "mata {" and "}", not "mata" and "end".
* version 1.0.6 Niels Henrik Bruun	2017-10-10
*	2017-10-10 > Modified loglines2markup() with strlst2file()
*	2017-10-10 > Added strlst2file() and collapse_line_pattern()
* version 1.0.5	Niels Henrik Bruun	2017-05-19
*	2017-05-19 > lines2markup(): Added sampleline to handle broken sample lines
*	2017-02-12 > TODO: Handling for-loops. Workaround: /***/display `"code"'
*	2016-09-01 > In case "Ignore code, keep pure sample" string trimming is removed
*	2016-08-18 > Added remove_line_pattern() and substitute_line_pattern() to simplify code and sample output
*	2016-03-16 > Removing dots after samples
*	2016-03-16 > Commented code (starting with a * or // are ignored in the output
*	2016-03-02 > keep_sample not set properly to 0 when markup block starts
*	2016-03-02 > Left aligned output for option log
* version 1.0.1	Niels Henrik Bruun	2016-02-15
*	2016-02-15 > Kit Baum discovered bug when logfile doesn't exist. Thanks
* version 1.0		Niels Henrik Bruun	2016-02-15
*	2016-02-22 > ignore blanks after ***/ so that that blanks do not prevent closing of textblocks

version 12

mata:
	mata clear
	mata set matalnum on

	string colvector file2mata(string scalar filename)
	// consider using cat
	{
		string colvector lines
		string scalar line
		real scalar fh

		if (fileexists(filename)) {
			fh = fopen(filename, "r")
			lines = J(0,1,"")
			while ( (line=fget(fh)) != J(0,0,"") ) {
				lines = lines \ line
			}
		} else {
			printf(`"{error} File "%s" does not exist!"', filename)
			lines = J(0,0,"")
		}
		fclose(fh)
		return(lines)
	}
	
	void strlst2file(	string scalar filename,
						string colvector lines,
						|real scalar replace)
	{
		real scalar fh, rc, r, R

		replace = replace == . ? 0 : replace
		if ( replace ) rc = _unlink(filename)
		if (!fileexists(filename)) {
			fh = fopen(filename, "w")
			R  = rows(lines)
			for(r=1;r<=R;r++) rc = _fput(fh, lines[r]) 
			fclose(fh)
		} else printf(`"{error} File "%s" already exist!"', filename)
	}

	string colvector prune_code(string colvector lines)
	/*
		Requires:	A string vector log lines without log start and log end
		Returns:	A string vector without code blocks within //OFF and //ON
	*/
	{
		real scalar keep, r
		string colvector new_lines 
		
		new_lines = J(0,1,"")
		keep = 1
		for(r=1;r<=rows(lines);r++){
			keep = keep & !regexm(lines[r], "^\. //OFF")
			if ( keep ) {
				new_lines = new_lines \ lines[r]
			} else {
				keep = regexm(lines[r], "^\. //ON")
			}
		}
		return(new_lines)
	}

	string colvector prune_comment(string colvector lines)
	/*
		Requires:	A string vector log lines without log start and log end
		Returns:	A string vector without comments within /* and */
	*/
	{
		real scalar keep, r
		string colvector new_lines 
		
		new_lines = J(0,1,"")
		keep = 1
		for(r=1;r<=rows(lines);r++){
			if ( regexm(lines[r], "^\. //") ) continue
			if ( regexm(lines[r], "^\. \*") 
				& !regexm(lines[r], "^\. \*\*\*/") ) continue
			keep = (keep & !(regexm(lines[r], "^\. /\*") 
								& !regexm(lines[r], "^\. /\*\*")))
			if ( keep ) {				
				new_lines = new_lines \ lines[r]
			} else {
				keep = (regexm(lines[r], "\*/$") 
								& !regexm(lines[r], "\*\*\*/ *$"))
			}
		}
		return(new_lines)
	}

	string colvector lines2markup(string colvector lines, string scalar code_start, code_end, sample_start, sample_end)
	/*
		Requires:	Log lines pruned for log start, log end, comments and code 
					blocks to be ignored.
		Returns: 	md lines with code marked as code and output as quote
	*/
	{
		string scalar codeline, sampleline
		string colvector md_lines 
		real scalar r, R, is_md, is_code, is_sample
		real scalar keep_code, keep_sample
		
		is_md = 0
		is_code = 0
		is_sample = 0
		keep_code = 0
		keep_sample = 0
		md_lines = J(0,1,"")
		R = rows(lines)
		for(r=1;r<=R;r++){
			// Not markup block
			if ( !is_md ) {
				// markup block starts
				if ( is_md=regexm(lines[r], "^\. /\*\*\*") 
							& !regexm(lines[r], "^\. /\*+/") ) {
					if ( is_sample ) {
						is_sample = 0
						if ( keep_sample ) {
							if ( keep_sample == 1 ) md_lines = md_lines \ sample_end
							md_lines = md_lines \ ""
							keep_sample = 0
						}
					}
					if ( regexm(lines[r], "^\. /\*\*\*(.*)") & regexs(1) != "" ) {
						md_lines = md_lines \ "" \ regexs(1)
					}
				// Or line is in a code/sample block 
				} else {
					// Code block starts
					if ( regexm(lines[r], "^[\.:] (.+)") ) {
						if ( is_sample ) {
							is_sample = 0
							if ( keep_sample == 1 ) md_lines = md_lines \ sample_end
							md_lines = md_lines \ ""
						}
						codeline = regexs(1)
						is_code = 1
						// Ignore code, keep verbatim sample
						if ( regexm(codeline, "^/\*\*\*/") ) {
							keep_code = 0
							keep_sample = 1
						// Keep verbatim code, ignore sample
						} else if ( regexm(codeline, "^/\*\*/ *(.+)") ) {
							codeline = regexs(1)
							keep_code = 1
							keep_sample = 0
						// Ignore code, keep pure sample
						} else if ( regexm(codeline, "^/\*\*\*\*/")) {
							keep_code = 0
							keep_sample = 2
						} else {
							keep_code = 1
							keep_sample = 1
						}
						if ( keep_code ) {
							md_lines = md_lines \ code_start
							md_lines = md_lines \ codeline
						}						
					// Code block continues
					} else if ( !is_sample & regexm(lines[r], "^> (.*)") ) {
						if ( keep_code ) md_lines = md_lines \ regexs(1)
					// Code block ends and sample block starts
					} else if ( is_code & !regexm(lines[r], "^> .*") ) {
						if ( keep_code ) md_lines = md_lines \ code_end
						if ( keep_sample == 1 ) md_lines = md_lines \ "" \ sample_start
						is_code = 0
						is_sample = 1
						// keep verbatim sample
						if ( keep_sample ) sampleline = lines[r]
					// Sample block continues
					} else if ( is_sample ) {
						// Sample block ends
						if ( regexm(lines[r], "^\. *$") ) {
							is_sample = 0
							if ( keep_sample == 1 ) {
								md_lines = md_lines \ sampleline \ sample_end \ ""
							} else if ( keep_sample == 2 ) {
								md_lines = md_lines \ sampleline \ ""
							}
						} else if ( keep_sample ) {
							if ( regexm(lines[r], "^> (.*)") ) {
								sampleline = sampleline + regexs(1)
							} else {
								md_lines = md_lines \ sampleline
								sampleline = lines[r]
							}
						}
					}
				}
			// markup block ends
			} else if ( is_md & regexm(lines[r], "^> (.*)\*\*\*/ *$") ) {
				// Save last markup line
				md_lines = md_lines \ regexs(1) \ ""
				is_md = 0
			// markup block continues
			} else if ( is_md & regexm(lines[r], "^> (.*)") ) {
				md_lines = md_lines \ regexs(1)
			}
		}
		if ( is_code & keep_code ) md_lines = md_lines \ code_end
		if ( is_sample & keep_sample == 1 ) md_lines = md_lines \ sample_end
		return(md_lines)
	}

	string colvector remove_line_pattern(	string colvector lines, 
											string colvector pattern)
	{
		real scalar r, np, R
		string colvector out
		
		out = J(0,1,"")
		np = rows(pattern) - 1
		R = rows(lines)
		for(r=1;r<=R;r++) {
			if ( r < R - np ) {
				if ( lines[(r..r+np)] != pattern ) out = out \ lines[r]
				if ( lines[(r..r+np)] == pattern ) r = r + np
			} else {
				out = out \ lines[r]
			}
		}
		return(out)
	}	

	string colvector substitute_line_pattern(	string colvector lines, 
												string colvector pattern, 
												string colvector replacelines)
	{
		real scalar r, np, R
		string colvector out
		
		out = J(0,1,"")
		np = rows(pattern) - 1
		R = rows(lines)
		for(r=1;r<=R;r++) {
			if ( r <= R - np ) {
				if ( lines[(r..r+np)] != pattern ) out = out \ lines[r]
				if ( lines[(r..r+np)] == pattern ) {
					r = r + np
					out = out \ replacelines
				}
			} else {
				out = out \ lines[r]
			}
		}
		return(out)
	}

	string colvector collapse_line_pattern(	string colvector lines, 
											string scalar pattern)												
	{
		real scalar r, R
		string colvector out
		
		out = J(0,1,"")
		R = rows(lines)
		for(r=1;r<=R;r++) {
			if ( r <= R - 1 ) {
				if ( lines[r] != pattern ) out = out \ lines[r]
				if ( lines[r] == pattern ) {
					r = r + 1
					out = out \ pattern + lines[r]
				}
			} else {
				out = out \ lines[r]
			}
		}
		return(out)
	}
	
	string colvector loglines2markup(string scalar logfile, extension, code_start, code_end, sample_start, sample_end, real scalar log, replace)
	/*
		Requires:	Path and name on a text log file in a string
		TODO: 		Verify string input as an existing text! log file
	*/
	{	
		string colvector lines
		string scalar fn
		real scalar rc, fh, r

		if ( !fileexists(logfile) ) _error(sprintf("File %s do not exist!!", logfile))
		lines = file2mata(logfile)
		if ( !(lines[4] != "  log type:  text" | lines[5] != "  log type:  text") ) {
			_error(sprintf("File %s is not a Stata text log file!!", logfile))
		}
		lines = lines[6..rows(lines)-6] // Remove log start and log end
		lines = prune_code(lines)
		lines = prune_comment(lines)
		lines = lines2markup(lines, code_start, code_end, sample_start, sample_end)

		lines = substitute_line_pattern(lines, ("" \ code_start), (code_start))
		lines = substitute_line_pattern(lines, (code_end \ ""), (code_end))
		lines = substitute_line_pattern(lines, (sample_start \ ""), (sample_start))
		lines = substitute_line_pattern(lines, ("" \ sample_end), (sample_end))
		lines = substitute_line_pattern(lines, ("" \ sample_end), (sample_end))

		lines = remove_line_pattern(lines, (sample_start \ sample_end))
		lines = remove_line_pattern(lines, (code_end \ code_start))
		lines = remove_line_pattern(lines, (code_end \ "" \ code_start))
		
		if ( log ) {
			for(r=1;r<=2;r++) ""	// Empty lines before printing
			for(r=1;r<=rows(lines);r++) lines[r]
		} else {
			fn = subinstr(logfile,".log", sprintf(".%s", extension))
			strlst2file(fn, lines, replace)
		}
		return(lines)
	}
end
