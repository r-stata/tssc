/*

					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de
								   
                    * These software come with no warranty *
	
	
	Weaver Check
	============
	
	This ado file is a part of Weaver package and is called within weave.ado
	file to check if wkhtmltopdf is installed on the system correctly and is 
	accessible for Weaver package. The supplmentary software is downloaded
	from http://www.haghish.com/ 
	
	Engine
	------
	
	If the "INSTALL" option is specified and PDF driver is not installed on the 
	machine, Stata will print an error and provide the option to install the 
	driver automatically within Stata or manually (by providing online help file)
	
	Updates on version 3.0
	----------------------
	
	The version 3.0 of Weaver no longer relies on Pandoc software and as a 
	result, the codes that checkes for Pandoc is deactivated. In addition, this 
	version of Weaver only supports wkhtmltopdf driver automatically and no 
	longer supports princexml pdf printer. 
*/

		
	
program define weavercheck
	version 11
	syntax [, install synoff ]
	
	qui local location "`c(pwd)'"					// *save the current wd
	
	//Create the Weaver directory
	qui cd "`c(sysdir_plus)'"
	cap qui mkdir Weaver
	qui cd "`location'"
	
	********************************************************************
	* CHECK Statax syntax highlighter is installed
	********************************************************************
	cap quietly findfile statax.ado
	
	if missing("`synoff'") {
		if "`r(fn)'" == "" & missing("`install'")  {
			di _n
			di as txt `"{p}The {bf:{help Statax}} package is required. Click on "' ///
			`"{ul:{bf:{stata "ssc install statax":Install statax Now}}} "' ///
			`"or type {ul:{bf:ssc install statax}}"'
			di as txt "(Statax is a JavaScript syntax highlighter for Stata)" _n
			exit 198
		}
	
		if "`r(fn)'" == "" & !missing("`install'") {
			ssc install statax
		}
	}	
				
	********************************************************************
	* CHECK WEAVER VERSION
	********************************************************************
	weaverversion
	
	********************************************************************
	* wkhtmltopdf SOFTWARE INSTALLATION
	********************************************************************
	
	// MICROSOFT WINDOWS 
	// =================
	if "`c(os)'"=="Windows" & "$weaverMarkup" == "html" {
		if "$setpath" == "" {			

			cap quietly findfile wkhtmltopdf.exe, 								///
			path("`c(sysdir_plus)'Weaver\wkhtmltopdf\bin\")
			
			if "`r(fn)'" ~= "" {
				qui local sub "`c(pwd)'"
				qui cd "`c(sysdir_plus)'/Weaver/wkhtmltopdf/bin"
				local d : pwd
				global setpath : di "`d'/wkhtmltopdf.exe"
				qui cd "`sub'"
			}
			
				
			if "`r(fn)'" == "" {
				if `"`install'"'  == "install" {
													
					weaverwkhtmltopdf				//call wkhtmltopdf installer
					local jumper 1					// run mathjax queitly
					
					qui local sub "`c(pwd)'"
					qui cd "`c(sysdir_plus)'/Weaver/wkhtmltopdf/bin"
					local d : pwd
					global setpath : di "`d'/wkhtmltopdf.exe"
					qui cd "`sub'"
				}
					
				if "`install'"  ~= "install" {
					if !missing("$pathWkhtmltopdf") global setpath "$pathWkhtmltopdf"
					else if missing("$nopdf") & "$weaverMarkup" == "html" {
						di as txt "$pathWkhtmltopdf"
						di as txt "{hline}" 
						di as error "{bf:wkhtmltopdf} software was not found" _n 	
						di as smcl `"{browse "http://www.haghish.com/packages/pdf_printer.php":    {c 149} Learn How To Install wkhtmltopdf PDF Drivers Manually}"'  
						di as smcl "{stata weaverwkhtmltopdf:    {c 149} Install "	///
						"wkhtmltopdf {bf:Automatically}}"		
						di as txt "{hline}"	_n
						quietly error 601
					}
				}
			}
		}	
	}
		
		
	
	// MACINTOSH 
	// =========
	
	if "`c(os)'"=="MacOSX" & "$weaverMarkup" == "html" {
			
		if "$setpath" == "" {
			cap quietly findfile wkhtmltopdf, 									///
			path("`c(sysdir_plus)'Weaver/wkhtmltopdf/")
			if "`r(fn)'" ~= "" {
				qui local sub "`c(pwd)'"
				qui cd "`c(sysdir_plus)'/Weaver/wkhtmltopdf"
				local d : pwd
				global setpath : di "`d'/wkhtmltopdf"
				qui cd "`sub'"
			}
				
			*If wkhtmltopdf does not exist, run weaverwkhtmltopdf program
			if "`r(fn)'" == "" {
				if `"`install'"'  == "install" {
					weaverwkhtmltopdf
					local jumper 1					// run mathjax queitly
					qui local sub "`c(pwd)'"
					qui cd "`c(sysdir_plus)'/Weaver/wkhtmltopdf"
					local d : pwd
					global setpath : di "`d'/wkhtmltopdf"
					qui cd "`sub'"
				}
					
				if `"`install'"'  ~= "install" {
					if !missing("$pathWkhtmltopdf") global setpath "$pathWkhtmltopdf"
					else if missing("$nopdf") & "$weaverMarkup" == "html" {
						di as txt "{hline}" 
						di as error "{bf:wkhtmltopdf} software was not found" _n 	
						di as smcl `"{browse "http://www.haghish.com/packages/"' 	///
						`"pdf_printer.php":    {c 149} Learn How To Install"'		///
						`"wkhtmltopdf PDF Drivers Manually}"'   
						di as smcl "{stata weaverwkhtmltopdf:    {c 149} Install "	///
						"wkhtmltopdf {bf:Automatically}}"		
						di as txt "{hline}"	_n
						quietly error 601
					}
				}
			}
		}	
	}
		
	// UNIX 
	// ====
	if "`c(os)'" == "Unix" & "$weaverMarkup" == "html" {

		if "$setpath" == "" {
		
			cap quietly findfile wkhtmltopdf, 									///
			path("`c(sysdir_plus)'Weaver/wkhtmltopdf/")
			if "`r(fn)'" ~= "" {
				qui local sub "`c(pwd)'"
				qui cd "`c(sysdir_plus)'/Weaver/wkhtmltopdf"
				local d : pwd
				global setpath : di "`d'/wkhtmltopdf"
				qui cd "`sub'"
			}
				
			// If wkhtmltopdf does not exist, run weaverwkhtmltopdf program
			if "`r(fn)'" == "" {	
							
				if `"`install'"'  == "install" {
					weaverwkhtmltopdf
					local jumper 1					// run mathjax queitly
					
					qui local sub "`c(pwd)'"
					qui cd "`c(sysdir_plus)'/Weaver/wkhtmltopdf"
					local d : pwd
					global setpath : di "`d'/wkhtmltopdf"
					qui cd "`sub'"
				}
					
				if `"`install'"'  ~= "install" {
					if !missing("$pathWkhtmltopdf") global setpath "$pathWkhtmltopdf"
					else if missing("$nopdf") & "$weaverMarkup" == "html" {
						di as txt "{hline}" 
						di as error "{bf:wkhtmltopdf} software was not found" _n 	
						di as smcl `"{browse "http://www.haghish.com/packages/"' 	///
						`"pdf_printer.php":    {c 149} Learn How To Install"'		///
						`"wkhtmltopdf PDF Drivers Manually}"'   
						di as smcl "{stata weaverwkhtmltopdf:    {c 149} Install "	///
						"wkhtmltopdf {bf:Automatically}}"		
						di as txt "{hline}"	_n
						quietly error 601
					}
				}			
			}
		}		
	}
		
	********************************************************************
	* pdfLaTeX
	*
	* This section does not install pdfLaTeX. But it attempts to find it 
	* on the users' operating system
	********************************************************************
	
	// MICROSOFT WINDOWS 
	// =================
	if "`c(os)'"=="Windows" & "$weaverMarkup" == "latex" & "$setpath" == "" {
		
		//windows seven 64bit
		cap quietly findfile pdflatex.exe, path("C:\Program Files\MiKTeX 2.9\miktex\bin\x64\")
		if "`r(fn)'" ~= "" {
			global setpath "C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe"
		}
		
	}
	
	// MACINTOSH 
	// =========
	if "`c(os)'"=="MacOSX" & "$weaverMarkup" == "latex" & "$setpath" == "" {
		cap quietly findfile pdflatex, path("/usr/texbin/")
		if "`r(fn)'" ~= "" {
			global setpath "/usr/texbin/pdflatex"
		}
		if missing("$setpath") {
			cap quietly findfile pdflatex, path("/Library/TeX/texbin/")
			if "`r(fn)'" ~= "" {
				global setpath "/Library/TeX/texbin/pdflatex"
			}
		}
	}
	
	// UNIX 
	// ====
	if "`c(os)'" == "Unix" & "$weaverMarkup" == "latex" & "$setpath" == "" {
		// Discover pdfLaTeX
	}
	
	********************************************************************
	* MathJax SOFTWARE INSTALLATION
	********************************************************************
	// MICROSOFT WINDOWS 
	if "`c(os)'"=="Windows" {
		cap qui cd "`c(sysdir_plus)'Weaver\MathJax-master\"
		local d : pwd
		cap quietly findfile MathJax.js, path("`d'") 
		
		if !missing("`r(fn)'") global mathjax "`r(fn)'"
		
		if missing("`r(fn)'") {
			if `"`install'"'  == "install" {
				if !missing("`jumper'") {
					
					// print the notice
					di as txt "Installing MathJax... " _n
					
					quietly weavermath
					
					// print the success output
					di as txt "{hline}" 	
					di `"{bf:MathJax} successfully installed in "' _n		 	/// 
					`"{browse $mathjax}"'
					di as txt "{hline}"	_n
					}
				if missing("`jumper'") weavermath 
			}
					
			if `"`install'"'  ~= "install" {
				
				if !missing("$pathMathJax") global mathjax "$pathMathJax"
				else if missing("$nopdf") & "$weaverMarkup" == "html" {	
					di as txt "{hline}" 
					di as error "{bf:MathJax} JavaScript was not found" _n 	
					di `"{browse "http://www.haghish.com/packages/mathjax.php":    "' ///
					`"{c 149} Learn How To Install MathJax Manually}"'   
					di as smcl "{stata weavermath:    {c 149} Install "				///
					"MathJax {bf:Automatically}}"		
					di as txt "{hline}"	_n
					quietly error 601
				}	
			}
		}	
	}
	
	// MACINTOSH AND UNIX
	if "`c(os)'" == "MacOSX" | "`c(os)'" == "Unix" {
		cap qui cd "`c(sysdir_plus)'Weaver/MathJax-master/"
		local d : pwd
		cap quietly findfile MathJax.js, 										///
		path("`d'") 
		
		if !missing("`r(fn)'") global mathjax "`r(fn)'"
		
		if missing("`r(fn)'") {
			if "`install'"  == "install" {
				if !missing("`jumper'") {
					di as txt "Installing MathJax... " _n
					quietly weavermath
					di as txt "{hline}" 	
					di `"{bf:MathJax} successfully installed in "' _n		 		/// 
					`"{browse $mathjax}"'
					di as txt "{hline}"	_n
				}
				
				if "`jumper'" != "1" weavermath 
			}
					
			if "`install'"  ~= "install" {
				if !missing("$pathMathJax") global mathjax "$pathMathJax"
				else if missing("$nopdf") & "$weaverMarkup" == "html" {
					di "{hline}{smcl}" 
					di as error "{bf:MathJax} JavaScript was not found{smcl}" _n 	
					di `"{browse "http://www.haghish.com/packages/mathjax.php":    "' ///
					`"{c 149} Learn How To Install MathJax Manually}"'   
					di as smcl "{stata weavermath:    {c 149} Install "				///
					"MathJax {bf:Automatically}}"		
					di as txt "{hline}"	_n
					quietly error 601
				}
			}
		}	
	}
	
	
			
	
	qui cd "`location'"								// go back to wd
													
end
	
