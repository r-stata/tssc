/*******************************************************************************

							  Stata Weaver Package
					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de

		
                  The Weaver Package comes with no warranty    	
				  
*******************************************************************************/

	*note: The report check does not require marker
	
	
	program define reportcheck
	version 11
	
	*save the current working directory
	qui global location "`c(pwd)'"
	
	********************************************************************
	*PRINCE SOFTWARE INSTALLATION
	********************************************************************
	
	if "`c(os)'"=="Windows" {
		
			if "$printer" == "prince" & "$setpath" == "" | ///
			"$printer" == "" & "$setpath" == "" {	
			
					*Search for Prince
					cap quietly findfile prince.exe, path("`c(sysdir_plus)'Weaver\Prince\Engine\bin\")
					if "`r(fn)'" ~= "" {
							*save the current working directory
							qui local sub "`c(pwd)'"
		
							*GETTING THE PATH TO PRINCE
							qui cd "`c(sysdir_plus)'Weaver\Prince\Engine\bin"
							local d : pwd
							global setpath : di "`d'\prince.exe"
					
							*GO BACK TO THE WORKING DIRECTORY
							qui cd "`sub'"

							}

					*If Prince does not exist, run weaverprince program
					if "`r(fn)'" == "" {
					
							if "`weaverpandoc'" == "weaverpandoc"	qui weaverprince
							if "`weaverpandoc'" != "weaverpandoc"	weaverprince	
					
							cap quietly findfile prince.exe, path("`c(sysdir_plus)'Weaver\Prince\Engine\bin\")
							*save the current working directory
							qui local sub "`c(pwd)'"
		
							*GETTING THE PATH TO PANDOC
							qui cd "`c(sysdir_plus)'Weaver\Prince\Engine\bin"
							local d : pwd
							global setpath : di "`d'\prince.exe"
					
							*GO BACK TO THE WORKING DIRECTORY
							qui cd "`sub'"
					
							* Create a marker
							local weaverprince weaverprince
							}
					}
			}		
		
	
	
	if "`c(os)'"=="MacOSX" {
		
			if "$printer" == "prince" & "$setpath" == "" | ///
			"$printer" == "" & "$setpath" == "" {	
			
					*Search for Pandoc
					cap quietly findfile prince, path("`c(sysdir_plus)'Weaver/Prince/bin/")
					if "`r(fn)'" ~= "" {
							*save the current working directory
							qui local sub "`c(pwd)'"
		
							*GETTING THE PATH TO PANDOC
							qui cd "`c(sysdir_plus)'/Weaver/Prince/bin"
							local d : pwd
							global setpath : di "`d'/prince"
					
							*GO BACK TO THE WORKING DIRECTORY
							qui cd "`sub'"
							}
				
					*If Prince does not exist, run weaverprince program
					if "`r(fn)'" == "" {
							if "`weaverpandoc'" == "weaverpandoc"	qui weaverprince
							if "`weaverpandoc'" != "weaverpandoc"	weaverprince
					
							*save the current working directory
							qui local sub "`c(pwd)'"
		
							*GETTING THE PATH TO PANDOC
							qui cd "`c(sysdir_plus)'/Weaver/Prince/bin"
							local d : pwd
							global setpath : di "`d'/prince"
					
							*GO BACK TO THE WORKING DIRECTORY
							qui cd "`sub'"
					
							* Create a marker
							local weaverprince weaverprince
							}
					}	
			}
		
		

	
	if "`c(os)'"=="Unix" {
			
			if "$printer" == "prince" & "$setpath" == "" | ///
			"$printer" == "" & "$setpath" == "" {	
		
					*Search for Prince
					cap quietly findfile prince, path("`c(sysdir_plus)'Weaver/Prince/bin/")
					if "`r(fn)'" ~= "" {
							*save the current working directory
							qui local sub "`c(pwd)'"
		
							*GETTING THE PATH TO PANDOC
							qui cd "`c(sysdir_plus)'/Weaver/Prince/bin"
							local d : pwd
							global setpath : di "`d'/prince"
					
							*GO BACK TO THE WORKING DIRECTORY
							qui cd "`sub'"
							}
				
					*If Prince does not exist, run weaverprince program
				
					if "`r(fn)'" == "" {
							if "`weaverpandoc'" == "weaverpandoc"	qui weaverprince
							if "`weaverpandoc'" != "weaverpandoc"	weaverprince
					
							if "`r(fn)'" ~= "" {
							*save the current working directory
							qui local sub "`c(pwd)'"
		
							*GETTING THE PATH TO PANDOC
							qui cd "`c(sysdir_plus)'/Weaver/Prince/bin"
							local d : pwd
							global setpath : di "`d'/prince"
					
							*GO BACK TO THE WORKING DIRECTORY
							qui cd "`sub'"
							}
					
							* Create a marker
							local weaverprince weaverprince
							}
					}
			}
	
	
	
	
	
	
	
	
	
	
	
	
	********************************************************************
	*wkhtmltopdf SOFTWARE INSTALLATION
	********************************************************************
	
	if "`c(os)'"=="Windows" {
			
			if "$printer" == "wkhtmltopdf" & "$setpath" == "" | ///
			"$printer" == "wk" & "$setpath" == "" {
		
					*Search for wkhtmltopdf
					cap quietly findfile wkhtmltopdf.exe, path("`c(sysdir_plus)'Weaver\wkhtmltopdf\bin\")
					if "`r(fn)'" ~= "" {
							*save the current working directory
							qui local sub "`c(pwd)'"
		
							*GETTING THE PATH TO PANDOC
							qui cd "`c(sysdir_plus)'Weaver/wkhtmltopdf/bin"
							local d : pwd
							global setpath : di "`d'\wkhtmltopdf.exe"
					
							*GO BACK TO THE WORKING DIRECTORY
							qui cd "`sub'"
							}
				
					*If wkhtmltopdf does not exist, run weaverwkhtmltopdf program
				
					if "`r(fn)'" == "" {
				
							if "`weaverpandoc'" == "weaverpandoc"	| ///
							"`weaverprince'" == "weaverprince" qui weaverwkhtmltopdf
					
							if "`weaverpandoc'" != "weaverpandoc"	& ///
							"`weaverprince'" != "weaverprince" weaverwkhtmltopdf
					
							qui local sub "`c(pwd)'"
							qui cd "`c(sysdir_plus)'Weaver\wkhtmltopdf\bin"
							local d : pwd
							global setpath : di "`d'\wkhtmltopdf.exe"
							qui cd "`sub'"
							}
					}	
			}
		
		
	
	if "`c(os)'"=="MacOSX" {
			
			if "$printer" == "wkhtmltopdf" & "$setpath" == "" | ///
			"$printer" == "wk" & "$setpath" == "" {
		
					*Search for wkhtmltopdf
					cap quietly findfile wkhtmltopdf, path("`c(sysdir_plus)'Weaver/wkhtmltopdf/")
					if "`r(fn)'" ~= "" {
							qui local sub "`c(pwd)'"
							qui cd "`c(sysdir_plus)'/Weaver/wkhtmltopdf"
							local d : pwd
							global setpath : di "`d'/wkhtmltopdf"
							qui cd "`sub'"
							}
				
					*If wkhtmltopdf does not exist, run weaverwkhtmltopdf program
					if "`r(fn)'" == "" {
				
							if "`weaverpandoc'" == "weaverpandoc"	| ///
							"`weaverprince'" == "weaverprince" qui weaverwkhtmltopdf
					
							if "`weaverpandoc'" != "weaverpandoc"	& ///
							"`weaverprince'" != "weaverprince" weaverwkhtmltopdf
					
							qui local sub "`c(pwd)'"
							qui cd "`c(sysdir_plus)'/Weaver/wkhtmltopdf"
							local d : pwd
							global setpath : di "`d'/wkhtmltopdf"
							qui cd "`sub'"
							}
					}	
			}
		
		
	
	if "`c(os)'" == "Unix" {
			
			if "$printer" == "wkhtmltopdf" & "$setpath" == "" | ///
			"$printer" == "wk" & "$setpath" == "" {
		
					*Search for wkhtmltopdf
					cap quietly findfile wkhtmltopdf, path("`c(sysdir_plus)'Weaver/wkhtmltopdf/")
					if "`r(fn)'" ~= "" {
							qui local sub "`c(pwd)'"
							qui cd "`c(sysdir_plus)'/Weaver/wkhtmltopdf"
							local d : pwd
							global setpath : di "`d'/wkhtmltopdf"
							qui cd "`sub'"
							}
				
					*If wkhtmltopdf does not exist, run weaverwkhtmltopdf program
				
					if "`r(fn)'" == "" {	
							if "`weaverpandoc'" == "weaverpandoc"	| ///
							"`weaverprince'" == "weaverprince" qui weaverwkhtmltopdf
					
							if "`weaverpandoc'" != "weaverpandoc"	& ///
							"`weaverprince'" != "weaverprince" weaverwkhtmltopdf
					
							qui local sub "`c(pwd)'"
							qui cd "`c(sysdir_plus)'/Weaver/wkhtmltopdf"
							local d : pwd
							global setpath : di "`d'/wkhtmltopdf"
							qui cd "`sub'"
							}
					}		
			}
		
	

	
	*go back to the previous working directory
	qui cd "$location"
	macro drop location
		
	
	end
	
