/*

					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de
								   
                    * These software come with no warranty *
	
	
	This program installs wkhtmltopdf software for Weaver package. The
	software are downloaded from http://www.stata-blog.com/ 			
*/
	
	
	
	
	program define weavermath
	version 11
	
	di _n
	di as txt 																	///
	" ____  _                      __        __    _ _   " _n 					///
	"|  _ \| | ___  __ _ ___  ___  \ \      / /_ _(_) |_ " _n 					///
	"| |_) | |/ _ \/ _` / __|/ _ \  \ \ /\ / / _` | | __|" _n 					///
	"|  __/| |  __/ (_| \__ \  __/   \ V  V / (_| | | |_ " _n 					///
	"|_|   |_|\___|\__,_|___/\___|    \_/\_/ \__,_|_|\__|" _n 
		
	di as txt "{p}make sure you are " 							///
	"connected to internet. This may take a while..." _n(2)
	
	//Test for Internet connection
	macro drop thenewestweaverversion
	cap qui do "http://www.haghish.com/packages/update.do"
	if missing("$thenewestweaverversion") {
		di as err "{p}Internet connection not found!"
		exit 0
	}

	
	//Test for Internet connection
	macro drop thenewestweaverversion
	
		
		
	********************************************************************
	*MICROSOFT WINDOWS 32BIT & 64BIT
	********************************************************************
	if "`c(os)'" == "Windows" {
			
		// save the current working directory
		qui local location "`c(pwd)'"
		qui cd "`c(sysdir_plus)'"
		qui cd Weaver
		local d : pwd
		
		di as txt "Installing MathJax in {browse `d'}" _n
		
		qui copy "http://www.haghish.com/software/MathJax-master.zip" 			///
		"MathJax-master.zip", replace

		qui unzipfile MathJax-master, replace
		cap qui erase MathJax-master.zip
			
		// GETTING THE PATH TO mathjax
		cap qui cd MathJax-master
		if _rc == 0  {
			local d : pwd
			global mathjax : di "`d'\MathJax.js"
		}
		
		qui cd "`location'"
		
	}

		
		
	********************************************************************
	*MAC 32BIT & 64BIT
	********************************************************************
	if "`c(os)'" == "MacOSX" {
			
		// save the current working directory
		qui local location "`c(pwd)'"
		qui cd "`c(sysdir_plus)'"
		cap qui mkdir Weaver
		qui cd Weaver
		local d : pwd
		
		di as txt "Installing MathJax in {browse `d'}" _n
		
		qui copy "http://www.haghish.com/software/MathJax-master.zip" 			///
		"MathJax-master.zip", replace
			
		qui unzipfile MathJax-master, replace
		cap qui erase MathJax-master.zip
			
		// GETTING THE PATH TO mathjax
		//When there is an error, _rc it's not 0
		
		cap qui cd MathJax-master
		if _rc == 0  {
			local d : pwd
			global mathjax : di "`d'/MathJax.js"
		}

		cd "`location'"
		
	}
		
		
	********************************************************************
	*UNIX 32BIT & 64BIT
	********************************************************************
	if "`c(os)'"=="Unix" {
			
		// save the current working directory
		qui local location "`c(pwd)'"
		qui cd "`c(sysdir_plus)'"
		cap qui mkdir Weaver
		qui cd Weaver
		local d : pwd
		
		di as txt "Installing MathJax in {browse `d'}" _n
		
		qui copy "http://www.haghish.com/software/MathJax-master.zip" 			///
		"MathJax-master.zip", replace
			
		qui unzipfile MathJax-master, replace
		cap qui erase MathJax-master.zip
			
		// GETTING THE PATH TO mathjax
		cap qui cd MathJax-master
		if _rc == 0  {
			local d : pwd
			global mathjax : di "`d'/MathJax.js"
		}
		
		cd "`location'"
		
	}
		
	
	di as txt "{hline}" 	
	di as smcl `"{bf:MathJax} successfully installed in "' _n					/// 
	"{browse $mathjax}"
	di as txt "{hline}"	_n
	

					
					
	end
	
	
	
	
