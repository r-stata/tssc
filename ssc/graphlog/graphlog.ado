********************************************************************************************************************************
***																															 ***
***		graphlog 1.6																										 ***
***                                                                                                                          ***
*** 	This program is used to convert Stata log files (.log, .txt or .smcl) to PDF files, embedding the graphs that are	 ***
***		described in the log file.							 																 ***
*** 	To use this program, you need to have a LaTeX compiler with pdflatex installed on your computer. See the help file	 ***
***		for more info (type "help graphlog" in Stata).		 																 ***
***																															 ***
********************************************************************************************************************************

********************************************************************************************************************************
*** Initializing program *******************************************************************************************************
********************************************************************************************************************************

// Define the name of the program and the version of Stata it was written for.
program	graphlog
		version 12.1
		syntax using/ ///
		[, GDIRectory(string) PSize(string) POrientation(string) FSize(real 11) MSize(real 0.5) LSpacing(real 0.7) ///
		SPLIToutput SEPFigures FWidth(real 1) ENumerate KEEPtex OPENpdf ENCoding(string) COLor(string) replace ///
		///
		papersize(string) pageorientation(string) fontsize(real 11) marginsize(real 0.5) linespacing(real 0.7) ///
		separatefigures figurewidth(real 1)]
	
// Clean up to avoid interference with the code below.
	local drop _rc

//	Define a standard error message
	local pClosed = `""graphlog closed without generating PDF.""'

********************************************************************************************************************************
*** Converting options in old format to new format, ensuring backward compatibility ********************************************
********************************************************************************************************************************	
	
if `"`papersize'"' != "" {
	local psize = `"`papersize'"'
	}
if `"`pageorientation'"' != "" {
	local porientation = `"`pageorientation'"'
	}
if `fontsize' != 11 & `fsize' == 11 {
	local fsize = `fontsize'
	}
if `marginsize' != 0.5 & `msize' == 0.5 {
	local msize = `marginsize'
	}
if `linespacing' != 0.7 & `lspacing' == 0.7 {
	local lspacing = `linespacing'
	}
if `"`separatefigures'"' != "" {
	local sepfigures = `"`separatefigures'"'
	}
if `figurewidth' != 1 & `fwidth' == 1 {
	local fwidth = `figurewidth'
	}
		
********************************************************************************************************************************
*** Inputting default settings for conversion **********************************************************************************
********************************************************************************************************************************

if `"`psize'"' == "" local psize = "a4"
if `"`porientation'"' == "" local porientation = "portrait"

********************************************************************************************************************************
*** Control if a valid file was specified for conversion ***********************************************************************
********************************************************************************************************************************	
	
//	Extract the name of the input file.
local inputfilename = regexr(`"`using'"',"using ","")	
	
// Check if the specified file exists
if "$S_OS" != "Windows" {
	local inputfilename = subinstr(`"`inputfilename'"',"\\","/",.)
	}
else {
	local inputfilename = subinstr(`"`inputfilename'"',"/","\",.)
	}
capture confirm file `"`inputfilename'"'
if _rc {
	if _rc == 601 {
		display `"{error}file {bf:"`inputfilename'"} not found."' _n `pClosed'
		exit 601
		}
	else {
		local errCode = _rc
		display `"{error}Invalid file specification: {bf:"`inputfilename'"} not allowed."' _n `pClosed'
		exit `errCode'
		}
	}
	
//	Check if the specified file is compatible with graphlog
if regexm(`"`inputfilename'"',".txt$") == 0 & regexm(`"`inputfilename'"',".log$") == 0 & regexm(`"`inputfilename'"',".smcl$") == 0 {
	display `"{error}Invalid file: {bf:"`inputfilename'"} is not in .txt, .log or .smcl format."' _n `pClosed'
	exit 198
	}	

//	Check for pre-existing PDF and TeX files.
	if "`replace'" == "" {
		capture confirm file `"`inputfilename'.pdf"'
		if !_rc {
			local errCode = _rc
			display `"{error}file "`inputfilename'.pdf" already exists"' _n `pClosed'
			exit `errCode'
			}
		if "`keeptex'" != "" {
			capture confirm file `"`inputfilename'.tex"'
			if !_rc {
				local errCode = _rc
				display `"{error}file "`inputfilename'.tex" already exists"' _n `pClosed'
				exit `errCode'
				}
			}
		}
	
//	Check if the specified graph directory exists (using code modified from Dan Blachette's confirmdir command).
	local cwd `"`c(pwd)'"'
	quietly capture cd `"`gdirectory'"'
	if _rc {
		quietly cd `"`cwd'"'
		display `"{error}Invalid gdirectory(): folder {bf:"`gdirectory'"} does not exist."' _n `pClosed'
		exit 601
		}
	quietly cd `"`cwd'"'
	
********************************************************************************************************************************
*** Checking conversion settings for errors ************************************************************************************
********************************************************************************************************************************	

//	Paper size
	if `"`psize'"' == "a4" | `"`psize'"' == "a" {
		local psize = "a4paper"
		}
	else {
		if `"`psize'"' == "letter"  | `"`psize'"' == "l" {
			local psize = "letter"
			}
		else {
			display `"{error}Invalid psize(): {bf:`psize'} not allowed."' _n `pClosed'
			exit 100
			}
		}
	
//	Page orientation
	if `"`porientation'"' == "p" {
		local porientation = "portrait"
		}
	if `"`porientation'"' == "l" {
		local porientation = "landscape"
		}
	if `"`porientation'"' != "portrait" & `"`porientation'"' != "landscape" {
		display `"{error}Invalid porientation(): {bf:`porientation'} not allowed."' _n `pClosed'
		exit 100
		}
	
//	Font size
	if `"`fsize'"' != "10" & `"`fsize'"' != "11" & `"`fsize'"' != "12" {
		display `"{error}Invalid fsize(): {bf:`fsize'} not allowed."' _n `pClosed'
		exit 100
		}

//	Margin size
	if `msize'<0.1 {
		display `"{error}Invalid msize(): {bf:`msize'} not allowed (minimum value is 0.1)."' _n `pClosed'
		exit 100
		}
	if `msize'>2.5 {
		display `"{error}Invalid msize(): {bf:`msize'} not allowed (maximum value is 2.5)."' _n `pClosed'
		exit 100
		}

// Calculating how many characters will fit on a line, based on page size/orientation, font size and margins.
	if "`psize'" == "a4paper" & "`porientation'" == "portrait" {
		local paperwidth = 8.27
		local paperheight = 11.69
		}
	if "`psize'" == "a4paper" & "`porientation'" == "landscape" {
		local paperwidth = 11.69
		local paperheight = 8.27
		}
	if "`psize'" == "letter" & "`porientation'" == "portrait" {
		local paperwidth = 8.5
		local paperheight = 11
		}
	if "`psize'" == "letter" & "`porientation'" == "landscape" {
		local paperwidth = 11
		local paperheight = 8.5
		}

	local maxnumletters = round((`paperwidth'-2*`msize')/(((11.69-1)/132)*`fsize'/11),1)
	local maxnumlines = round((`paperheight'-2*`msize')/(((11.69-2)/67)*`fsize'/11)*(1.7/(`lspacing'+1)),1)
		
//	Figure width	
	if `fwidth'<=0 {
		display `"{error}Invalid fwidth(): {bf:`fwidth'} not allowed (must be >= 0)."' _n `pClosed'
		exit 100
		}
	if `fwidth'*(`paperwidth'-2*`msize')>`paperwidth' {
		display `"Automatically corrected fwidth(): {bf:`fwidth'} > the maximum value for this document and was corrected to "' ///
			round(`paperwidth'/(`paperwidth'-2*`msize'),.1)
		local fwidth = `paperwidth'/(`paperwidth'-2*`msize')
		}
		
//	Character encoding
	if "$S_OS" != "Windows" & "`encoding'" == "" {
		local encoding = "utf8"
		}
	if "$S_OS" == "Windows" & "`encoding'" == "" {
		local encoding = "ansinew"
		}
	if "`encoding'" == "utf-8" {
		local encoding = "utf8"
		}

		
//	Text color
	if "`color'" == "" {
		local color = "black"
		}
		
if "`openpdf'" != "" {
	if "$S_OS" != "Windows" {
		display `"Option openpdf is only available for Windows. You will have to open the PDF file manually."'
		}
	}

********************************************************************************************************************************
*** Finding out where to place the PDF and the temporary files used for generating it ******************************************
********************************************************************************************************************************

tempfile temppath
local temppath = subinstr(`"`temppath'"',"\","/",.)
local temppath = reverse(`"`temppath'"')
local lastpathcharacter = strpos(`"`temppath'"',"/") + 1
local temppath = substr(`"`temppath'"',`lastpathcharacter',.)
local temppath = reverse(`"`temppath'"')

if regexm(`"`inputfilename'"',"/") == 0 & regexm(`"`inputfilename'"',"\\") == 0 {
	local subpath
	local shortfilename = `"`inputfilename'"'
	}
else {
	local subpath = `"`inputfilename'"'
	local subpath = subinstr(`"`subpath'"',"\","/",.)
	local subpath = reverse(`"`subpath'"')
	local lastslash = strpos(`"`subpath'"',"/")
	local shortfilename = substr(`"`inputfilename'"',-`lastslash'+1,.)
	local subpath = substr(`"`subpath'"',`lastslash'+1,.)
	local subpath = reverse(`"`subpath'"')
	}
if ("$S_OS" == "Windows" & regexm(`"`subpath'"',":") == 1) | ("$S_OS" != "Windows" & regexm(`"`subpath'"',"^/") == 1) {
	local fullpath = `"`subpath'"'
	}
else {
	local mainpath = `"`c(pwd)'"'
	local fullpath = `"`mainpath'"'
	if `"`subpath'"' != "" {
		local fullpath = `"`fullpath'"' + "/" + `"`subpath'"'
		}
	}
	
local sourcefilename = `"`fullpath'"' + "/" + `"`shortfilename'"'
local texfile = `"`temppath'"' + "/" + `"`shortfilename'"' + ".tex"
local pdffile = `"`fullpath'"' + "/" + `"`shortfilename'"' + ".pdf"
if "$S_OS" == "Windows" {
	local texfile = subinstr(`"`texfile'"',"/","\",.)
	local pdffile = subinstr(`"`pdffile'"',"/","\",.)
	}

foreach macroName in fullpath mainpath subpath sourcefilename texfile pdffile {
	local `macroName' = subinstr(`"``macroName''"',"//","/",.)
	local `macroName' = regexr(`"``macroName''"',"/$","") 
	}

if regexm(`"`sourcefilename'"',".smcl$") == 1 {
	quietly set linesize `maxnumletters'
	tempfile convertedsourcefilename
	capture quietly translate "`sourcefilename'" "`convertedsourcefilename'", translator(smcl2log) logo(off) cmdnumber(off) replace
	if _rc {
		local errCode = _rc
		display `"{error}Could not translate file "`sourcefilename'"' _n `pClosed'
		exit `errCode'
		}
	}
	
********************************************************************************************************************************
*** If gdirectory was specified, work out the absolute path to the folder containing graph files *******************************
********************************************************************************************************************************

if `"`gdirectory'"' != "" {
	if ("$S_OS" == "Windows" & regexm(`"`gdirectory'"',":") == 1) | ("$S_OS" != "Windows" & regexm(`"`gdirectory'"',"^/") == 1) {
		local gdirAbs = `"`gdirectory'"'
		}
	else {
		local gdirAbs = `"`c(pwd)'"' + "/" + `"`gdirectory'"'
		}
	}
else {
	local gdirAbs
	}	
	
********************************************************************************************************************************
*** Opening files and reading/writing the first line ***************************************************************************
********************************************************************************************************************************	

tempname sourcefile
tempname outputfile

if `"`convertedsourcefilename'"' == "" {
	file open `sourcefile' using `"`sourcefilename'"', read
	}
else {
	file open `sourcefile' using `"`convertedsourcefilename'"', read
	}
quietly file open `outputfile' using "`texfile'", write replace

file write `outputfile' "\documentclass[`fsize'pt,`psize',`porientation']{letter}" _n ///
	"\usepackage[margin=`msize'in]{geometry}" _n ///
	"\usepackage[pdftex]{graphicx}" _n ///
	"\usepackage[export]{adjustbox}" _n ///
	"\usepackage{fancyvrb}" _n ///
	"\usepackage[`encoding']{inputenc}" _n ///
	"\usepackage[T1]{fontenc}" _n ///
	"\usepackage{lmodern}" _n ///
	"\usepackage[usenames,dvipsnames,svgnames,table]{xcolor}" _n ///
	"\color{`color'}" _n ///
	"\usepackage{pdflscape}" _n ///
	"\usepackage[space,extendedchars]{grffile}" ///
	"\pagestyle{empty}" _n "\setlength{\parskip}{0cm}" _n "\linespread{`lspacing'}" _n
if "`enumerate'" != "" {
	file write `outputfile' ///
		"\usepackage{fancyhdr}" _n ///
		"\usepackage{lastpage}" _n ///
		"\pagestyle{fancy}" _n ///
		"\cfoot{\texttt{Page \thepage\ of \pageref{LastPage}}}" _n ///
		"\renewcommand{\headrulewidth}{0pt}" _n
	}
file write `outputfile' "\begin{document}" _n
file write `outputfile' "\begin{Verbatim}"
if `"`splitoutput'"' == "" {
	file write `outputfile' "[samepage=true]"
	}
file write `outputfile' _n

file read `sourcefile' line
local concatenatedlines = `"`macval(line)'"'
local numspaces = 0

local currentpath = "`fullpath'"
local changepath = .
local filecounter = 0
local roundcounter = 0
local endoffile = r(eof)
	
********************************************************************************************************************************
*** Reading the rest of the source file, keeping track of the number of rounds the code has run ********************************
********************************************************************************************************************************	
	
while `endoffile' == 0 {
	if `roundcounter' > 0 {
		file read `sourcefile' line
		local endoffile = r(eof)
		}
	local roundcounter = `roundcounter' + 1

********************************************************************************************************************************
*** Re-flow the text in the log file and write it to the LaTeX file ************************************************************
********************************************************************************************************************************

	local previousnumspaces = `numspaces'
	local previousconcatenatedlines `"`macval(concatenatedlines)'"'
	if regexm(`"`macval(line)'"',"^> ") == 1 {
		local concatenatedlines = `"`macval(concatenatedlines)'"' + regexr(`"`macval(line)'"',"^> ","")
		}
	else {
		local numspaces = strlen(`"`macval(line)'"') - strlen(ltrim(`"`macval(line)'"'))
		
		local concatenatedlines = `"`macval(line)'"'
		if `"`macval(previousconcatenatedlines)'"' != "" & `roundcounter' != 1 {
			if `changepath' == 1 {
				if regexm("`macval(previousconcatenatedlines'","^unable to") == 0 {
					local currentpath = "`macval(previousconcatenatedlines)'"
					local currentpath = subinstr("`currentpath'","\\","/",.)
					local currentpath = subinstr("`currentpath'","//","/",.)
					}
				local changepath = .
				}
			if regexm(`"`macval(previousconcatenatedlines)'"',"\.*cd") == 1 | regexm(`"`macval(previousconcatenatedlines)'"',"\.*pwd") == 1 {
				local cdfound = 1
				local changepath = 1
				}
				
			if `"`splitoutput'"' == "" {
				if regexm(`"`macval(previousconcatenatedlines)'"',"^\.") == 1 {
					file write `outputfile' "\end{Verbatim}" _n "\vspace{-10pt}" _n "\begin{Verbatim}[samepage=true]" _n
					local numlines = 0
					}
				}
			scalar linebreaks = 0
			local numspaceswritten = 0
			local remainingtobewritten = `"`macval(previousconcatenatedlines)'"'

			while `"`macval(remainingtobewritten)'"' != "" {
				if linebreaks == 0 {
					while `numspaceswritten' != `previousnumspaces' {
						local ++numspaceswritten
						file write `outputfile' " "
						}
					local endingpoint = `maxnumletters'-`numspaceswritten'
					local brokenline = substr(`"`macval(remainingtobewritten)'"',1,`endingpoint')
					}
				else {
					local endingpoint = `maxnumletters'-2
					local brokenline = "> " + substr(`"`macval(remainingtobewritten)'"',1,`endingpoint')
					}
				local remainingtobewritten = substr(`"`macval(remainingtobewritten)'"',`endingpoint'+1,.)
				scalar linebreaks = linebreaks + 1
				local numlines = `numlines' + 1
					
				capture file write `outputfile' `"`macval(brokenline)'"' _n
				if _rc {
					if _rc == 198 {
						local linebreak = char(10)
						file write `outputfile' `"`macval(brokenline)'"' `"`linebreak' \end{Verbatim} `linebreak' %' `linebreak' \vspace{-10pt} `linebreak' \begin{Verbatim}"' _n	
						}
					else {
						local errCode = _rc
						display `"{error}File I/O error when building TeX file."' _n `pClosed'
						exit `errCode'
						}
					}
					
				if `"`splitoutput'"' == "" {
					if `numlines' >= `maxnumlines' == 1 {
						file write `outputfile' "\end{Verbatim}" _n "\vspace{-10pt}" _n "\begin{Verbatim}[samepage=true]" _n
						local numlines = 0
						}
					}
				}
				
********************************************************************************************************************************
*** Detect references to graph files, convert them if necessary and insert them in the LaTeX document **************************
********************************************************************************************************************************
			
			if regexm(`"`macval(previousconcatenatedlines)'"',"^\(file*") == 1 | regexm(`"`macval(previousconcatenatedlines)'"',"^file*") == 1 {
				local graphpath = regexr(`"`macval(previousconcatenatedlines)'"',"^\(","")
				local graphpath = regexr(`"`macval(graphpath)'"',"^file ","")
				
				foreach string in " written" " saved" {
					if regexm(`"`macval(previousconcatenatedlines)'"',"`string'") == 1 {
						local graphpathpos = strpos(`"`graphpath'"',"`string'")
						local graphpathpos = `graphpathpos' - 1
						}
					}	
				local graphpath = substr(`"`graphpath'"',1,`graphpathpos')
				
				if `"`gdirAbs'"' == "" {
					if "$S_OS" == "Windows" {
						if regexm(`"`graphpath'"',":") == 0 {
							local graphpath = `"`currentpath'"' + "/" + `"`graphpath'"'
							}
						}
					else {
						if regexm(`"`graphpath'"',"^/") == 0 {
							local graphpath = `"`currentpath'"' + "/" + `"`graphpath'"'
							}
						}
					local graphpath = subinstr(`"`graphpath'"',"\","/",.)
					local graphpath = subinstr(`"`graphpath'"',"//","/",.)
					local graphpath = subinstr(`"`graphpath'"',`"""',"",.)
					}
				else {
					local graphpath = subinstr(`"`graphpath'"',`"""',"",.)
					local graphpath = subinstr(`"`graphpath'"',"\","/",.)
					if regexm(`"`graphpath'"',"/") == 1 { 
						local graphpath = reverse(`"`graphpath'"')
						local slashpos = strpos(`"`graphpath'"',"/")
						local graphpath = substr(`"`graphpath'"',1,`slashpos'-1)
						local graphpath = reverse(`"`graphpath'"')
						}
					local graphpath = `"`gdirAbs'"' + "/" + `"`graphpath'"'
					local graphpath = subinstr(`"`graphpath'"',"//","/",.)
					local graphpath = subinstr(`"`graphpath'"',"\","/",.)
					}				
								
				if 	regexm(`"`graphpath'"',`"\.ps$"')  == 1 | regexm(`"`graphpath'"',`"\.eps$"') == 1 | regexm(`"`graphpath'"',`"\.wmf$"') == 1 | ///
					regexm(`"`graphpath'"',`"\.emf$"') == 1 | regexm(`"`graphpath'"',`"\.tif$"') == 1 | regexm(`"`graphpath'"',`"\.gph$"') == 1 | ///
					regexm(`"`graphpath'"',`"\.pdf$"') == 1 | regexm(`"`graphpath'"',`"\.png$"') {
					
					local filecounter = `filecounter' + 1
					
					file write `outputfile' "\end{Verbatim}" _n(2)
					
					capture confirm file "`graphpath'"
					if _rc {
						local filenotfound = 1
						if `"`cdfound'"' == "1" {
							display `"{error}Graphics omitted from the PDF log: file {bf:"`graphpath'"} not found."'
							file write `outputfile' "\bigskip" _n "{\color{red} {\bf Graphics omitted: file not found.}}" _n(2)
							}
						if `"`cdfound'"' != "1" {
							display `"{error}Graphics omitted from the PDF log: file {bf:"`graphpath'"} not found."' ///
								" Issue the command pwd at least once during the logged session, or use option gdirectory()."
							file write `outputfile' "\bigskip" _n "{\color{red} {\bf Graphics omitted: file not found.}}" _n(2)
							}
						}
					else {
						if 	regexm(`"`graphpath'"',`"\.wmf$"') == 1 | regexm(`"`graphpath'"',`"\.emf$"') == 1 | regexm(`"`graphpath'"',`"\.tif$"') == 1 | regexm(`"`graphpath'"',`"\.ps$"') | regexm(`"`graphpath'"',`"\.eps$"') == 1{
							display `"{error}Graphics omitted from the PDF log: file {bf:"`graphpath'"} is not in .png, .pdf or .gph format."'
							file write `outputfile' "\bigskip" _n "{\color{red} {\bf Graphics omitted: file is not in .png, .pdf or .gph format.}}"
							}
						if 	regexm(`"`graphpath'"',`"\.gph$"') == 1 {
							local filenotconverted = 0
							local tempgraphname = `"`temppath'"' + `"/graphlog_temp_`filecounter'.pdf"'
							local tempgraphname = subinstr(`"`tempgraphname'"',"//","/",.)
							tempname graphlog_temp
							graph use `"`graphpath'"', name(`graphlog_temp', replace)
							quietly graph export `tempgraphname', name(`graphlog_temp') replace
							graph drop `graphlog_temp'
							capture confirm file `tempgraphname'
							if _rc {
								local filenotconverted = 1
								display `"{error}Graphics omitted from the PDF log: file {bf:"`graphpath'"} could not be converted."'
								file write `outputfile' "\bigskip" _n "{\color{red} {\bf Graphics omitted: file could not be converted.}}" _n(2)
								}
							local graphpath = `"`tempgraphname'"'
							}					
						}
							
							if `"`filenotconverted'"' != "1" & `"`filenotfound'"' != "1" {
								if `"`sepfigures'"' != "" {
									file write `outputfile' "\clearpage "
									if "`porientation'" == "portrait" file write `outputfile' "\begin{landscape} " 
									file write `outputfile' "\centerline{\includegraphics[height=\textheight, max width=`fwidth'\linewidth,keepaspectratio]{{" `"`graphpath'"' "}}} "
									file write `outputfile' "\clearpage "
									if "`porientation'" == "portrait" file write `outputfile' "\end{landscape} "
									file write `outputfile' _n
									}
								else {
									file write `outputfile' "\centerline{\includegraphics[width=`fwidth'\linewidth, max height =\textheight,keepaspectratio]{{" `"`graphpath'"' "}}}" _n
									}
								}
							
						file write `outputfile' "\begin{Verbatim}"
						if `"`splitoutput'"' == "" {
							file write `outputfile' "[samepage=true]"
							}
						file write `outputfile' _n(2)
						}
				}	
			local previousconcatenatedlines
			}
		}
	}

********************************************************************************************************************************
*** Upon reaching the end of the log file, we finalize the LaTeX document ******************************************************
********************************************************************************************************************************
	
file write `outputfile' "\end{Verbatim}" _n "\end{document}" _n
file close _all

********************************************************************************************************************************
*** Saving a copy of the TeX file if requested *********************************************************************************
********************************************************************************************************************************

if "`keeptex'" != "" {
	capture copy "`texfile'" "`sourcefilename'.tex", replace
	if !_rc {
		display `"(file `sourcefilename'.tex written in TeX format.)"'
		}
	else {
		display `"{error}TeX file could not be saved. Wait for generation of PDF."'
		}	
	}

********************************************************************************************************************************
*** Converting the TeX file to PDF *********************************************************************************************
********************************************************************************************************************************

local convertedfile = regexr(`"`texfile'"',"\.tex$",".pdf")
capture confirm file `"`convertedfile'"'
if !_rc {
	capture rm `"`convertedfile'"'
	if _rc {
		display `"{error}Error writing PDF file."'_n `pClosed'
		exit _rc
		}
	}
if _rc {
	if _rc != 601 {
		display `"{error}Error writing PDF file."'_n `pClosed'
		exit _rc
		}
	}

if "$S_OS" == "Windows" {
	! pdflatex --enable-write18 -interaction=nonstopmode -output-directory="`temppath'" "`texfile'"
	if "`enumerate'" != "" {
		! pdflatex --enable-write18 -interaction=nonstopmode -output-directory="`temppath'" "`texfile'"
		}
	capture confirm file `"`convertedfile'"'
	if _rc {
		! pdflatex --shell-escape -interaction=nonstopmode -output-directory="`temppath'" "`texfile'"
		if "`enumerate'" != "" {
			! pdflatex --shell-escape -interaction=nonstopmode -output-directory="`temppath'" "`texfile'"
			}		
		capture confirm file `"`convertedfile'"'
		}
	}
else {
	graphlog_pdflatex_path
	! $pdflatexPath --enable-write18 -interaction=nonstopmode -output-directory="`temppath'" "`texfile'"
	if "`enumerate'" != "" {
		! $pdflatexPath --enable-write18 -interaction=nonstopmode -output-directory="`temppath'" "`texfile'"
		}
	capture confirm file `"`convertedfile'"'
	if _rc {
		! $pdflatexPath --shell-escape -interaction=nonstopmode -output-directory="`temppath'" "`texfile'"
		if "`enumerate'" != "" {
			! $pdflatexPath --shell-escape -interaction=nonstopmode -output-directory="`temppath'" "`texfile'"
			}	
		capture confirm file `"`convertedfile'"'
		}
	}

if !_rc {
	capture copy "`convertedfile'" "`pdffile'", replace
	if !_rc {
		disp "(file " `"`pdffile'"' " written in PDF format.)" 
		}
	else {
		display `"{error}Error writing PDF file."'_n `pClosed'
		exit _rc
		}
	}
else {
	local errCode = _rc
	display `"{error}Error writing PDF file: Check that you have installed LaTeX with pdflatex"'_n `pClosed'
	exit `errCode'
	}
	
********************************************************************************************************************************
*** Opening the generated PDF file if requested ********************************************************************************
********************************************************************************************************************************

if "`openpdf'" != "" {
	if "$S_OS" == "Windows" {
		! `pdffile'
		}
	}

********************************************************************************************************************************
*** Ending the program *********************************************************************************************************
********************************************************************************************************************************

end

