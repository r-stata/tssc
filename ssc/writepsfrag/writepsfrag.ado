*! writepsfrag creates a TeX file which contains all of the psfrag commands necessary
*! to replace all occurences of text in a Stata EPS file
*! Author: Ryan E. Kessler
*! version: 1.2 

program define writepsfrag, nclass
	version 10.0
	syntax anything using/ [, replace append textsize(string) scale(real 1) 		///
	body(string asis) SUBstitute(string asis)]
	
	confirm file `anything'
	local epsfile `anything'
	local eps_test    : subinstr local epsfile ".eps" "", count(local eps_count)
	if `eps_count' != 1 {
		di in red "`anything' invalid file format; .eps required"
		exit 198
	}
	local outfile `using'
	if "`replace'"!="" & "`append'"!="" {
		di as error `"Cannot specify both "replace" and "append""'
		exit 198
	}
	if "`replace'"=="" & "`append"=="" confirm new file `"`outfile'"'
	else {
		capture confirm file `"`outfile'"'
		if _rc !=0 & _rc != 601 exit _rc
	}
	
	local tsize "`textsize'"
	if "`tsize'"=="" local tsize "\normalsize"
	else if substr("`tsize'",1,1) !="\" local tsize "\\`tsize'"
	local ts_list "\tiny \scriptsize \footnotesize \small \normalsize \large \Large \LARGE \huge \Huge"
	local ts_test : list tsize in ts_list
	if `ts_test'==0 {
			di in red "`tsize' invalid text size; you must choose from `ts_list'"
			exit 198
	}
	
	GetAlignment `epsfile'
	
	tempname eps psfrag
	file open `eps' using `epsfile', read
	file open `psfrag' using `outfile', write `replace' `append'
	if "`append'" !="" file write `psfrag' "" _n _n 
	file read `eps' line
	
	if `"`macval(body)'"' != "" ParseBodySubopts `macval(body)'
	if `"`macval(body_alignment)'"' == "" local body_alignment "htbp"
	
	if `"`body'"' == "document" {
		file write `psfrag' "\documentclass{article}" 		_n _n
		local packages "graphicx psfrag amsmath"
		if `"`body_packages'"' != "" {
			foreach p in `macval(body_packages)' {
				local pack_test : list p in packages 
				if `pack_test' == 0 local packages `"`packages' `p'"'
			}
		}
		foreach p in `macval(packages)' {
			file write `psfrag' `"\usepackage{`p'}"' 	_n
		}
		file write `psfrag' "" _n 
		file write `psfrag' "\begin{document}" 			_n _n
	}
	if `"`body'"' != "" {
		file write `psfrag' `"\begin{figure}[`macval(body_alignment)']"'  	_n
		file write `psfrag' "\centering" 					_n
	}
	
	while r(eof) == 0 {
	
		if "`return_alignment'" == "xratio" {
			if `"`line'"' == "2 div xratio div" {
				local texposition "c"
				local psposition "c"
			}
			else if `"`line'"' == "xratio div"  {
				local texposition "r"
				local psposition "r"
			}
		}
		if "`return_alignment'" == "void" {
				local texposition "B"
				local psposition "B"
		}
		
		if regexm(`"`line'"', "(\()(.*)(\) Stxt[lcr])") {
			
			if "`return_alignment'" == "xratio" & 	///
			"`texposition'" == "" & "`psposition'" == "" {
				local texposition "l"
				local psposition "l"
			}
			else if "`return_alignment'" == "stxt"  {
				local texposition = substr(regexs(3), length(regexs(3)), 1)
				local psposition  = substr(regexs(3), length(regexs(3)), 1)
			}
		
			local print_line = regexs(2)
			if `"`print_line'"'=="" {
				file read `eps' line
				continue
			}
			
			local print_line : subinstr local print_line "\(" "(", all
			local print_line : subinstr local print_line "\)" ")", all
			
			local clean_print_line `"`macval(print_line)'"'
			
			local psescape "$ \\$ \\ \ \dbs \\"
			local psesc_wc : word count `macval(psescape)'
			forval w= 1(2)`psesc_wc' {
				local from: word `w' of `macval(psescape)'
				local to:  word `=`w'+1' of `macval(psescape)'
				if "`macval(from)'"!="" & "`macval(to)'"!="" {
					local clean_print_line : subinstr local clean_print_line "`macval(from)'" "`macval(to)'", all
				}
			}
			if `"`macval(substitute)'"' != "" {
				local sub_wc : word count `macval(substitute)'
				if mod(`sub_wc',2) !=0 {
					di as error "substitute option misspecified"
					exit 198
				}
				forval w= 1(2)`sub_wc' {
					local from: word `w' of `macval(substitute)'
					local to:  word `=`w'+1' of `macval(substitute)'
					if "`macval(from)'"!="" & "`macval(to)'"!="" {
						local clean_print_line : subinstr local clean_print_line "`macval(from)'" "`macval(to)'", all
					}
				}
			}

			local clean_print_line : subinstr local clean_print_line `" ""' " ``", all
			file write `psfrag' `"\psfrag{`macval(print_line)'}[`texposition'][`psposition'][`scale'][0]{`tsize' `macval(clean_print_line)'}"' 	_n
			
			local texposition 
			local psposition
		}
		file read `eps' line
	}

	if `"`body'"' != "" {
		file write `psfrag' `"\resizebox{`body_width'\linewidth}{!}{\includegraphics{`epsfile'}}"' 	_n
		if `"`macval(body_caption)'"' != "" {
			local body_caption : subinstr local body_caption `" ""' " ``", all
			file write `psfrag' `"\caption{`macval(body_caption)'}"' 	_n
		}
		if `"`macval(body_label)'"' != "" file write `psfrag' `"\label{`macval(body_label)'}"' 		_n
		file write `psfrag' `"\end{figure}"' 		_n
	}
	if `"`body'"' == "document" {
		file write `psfrag' "" _n
		file write `psfrag' "\end{document}" _n
	}
	file close `eps' 
	file close `psfrag'
	
	di as text `"------------------  BEGIN `outfile'  ------------------"'
	type `outfile'
	di as text `"------------------   END  `outfile'  ------------------"'

end 

capture program drop ParseBodySubopts
program ParseBodySubopts
    syntax [anything] [, alignment(string) width(real 1) caption(string asis) 	///
	label(string asis) packages(string)]
	
	foreach opt in alignment width caption label packages {
		c_local body_`opt' `macval(`opt')'
	}
	if `"`macval(anything)'"'!="figure" & `"`macval(anything)'"'!="document" {
		di as error "body option misspecified"
	exit 198
	}
	else if `"`macval(anything)'"'=="figure" & `"`macval(packages)'"'!="" {
		di as error "packages suboption misspecified"
		exit 198
	}
	else c_local body `"`anything'"'
end

capture program drop GetAlignment
program GetAlignment
	syntax [anything]
	tempname alignment 
	file open `alignment' using `anything', read
	file read `alignment' line 
	local xratio_count = 0
	local stxt_count = 0
	while r(eof) == 0 {
		if `"`line'"' == "2 div xratio div" | 			///
		`"`line'"' == "xratio div" {
			local ++xratio_count
		}
		else if regexm(`"`line'"', "(\()(.*)(\) Stxt[cr])") {
			local ++stxt_count
		}
		file read `alignment' line
	}
	file close `alignment'
	
	if `xratio_count' > 0 & `stxt_count' == 0 {
		c_local return_alignment "xratio"
	}
	else if `xratio_count' == 0 & `stxt_count' > 0 	{
		c_local return_alignment "stxt"
	}
	else if (`xratio_count' > 0 & `stxt_count' > 0) | 		///
	(`xratio_count' == 0 & `stxt_count' == 0) {
		di as text `"Trouble determining alignment; resorting to "B""'
		c_local return alignment "void"
	}
end

