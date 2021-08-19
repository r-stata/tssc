/*

							  Stata Weaver Package
					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de

		
                  The Weaver Package comes with no warranty    	
	
	
	DESCRIPTION
	==============================
	
	The Weavend command closes the HTML log file and prints it into PDF
*/

program define weavend
    version 11
	if "$noisyWeaver" == "no" local qui quietly
	//syntax , /*[replace]*/ 
		
	// checking that log exists
    if missing("$weaver") {
		if missing("$weaversaver") {
			di as err "no Weaver log open" 
			exit 606
		}
		if !missing("$weaversaver") {
			global weaver $weaversaver
			global weaversaver 					// reset the global
		}
	}
		
	if !missing("$weaver") {
		
		*cap confirm file `"$weaver"'
		cap confirm file `"$weaverFullPath"'
		if _rc == 0 {
			tempname canvas         
            *file open `canvas' using `"$weaver"', write text append 
			file open `canvas' using `"$weaverFullPath"', write text append 
			
			if "$weaverMarkup" == "html" & "$weaverstyle" != "empty" {
				file write `canvas' _n "</body>" _n  
				file write `canvas' _n "</html>" _n(4)
			}	
			
			/*
			local path : pwd
			cap qui findfile "$htmldoc", path("`path'")
			
			local sep "`r(fn)'"
			if "`c(os)'" == "Windows" {
				local sep : subinstr local sep "/" "\", all
			}
			*/
			
			if "$weaverMarkup" == "html" {
				file write `canvas' _n(2)												///
				`"<!-- name      : ${htmldoc} -->"' _n 								///
				`"<!-- log       : $weaverFullPath -->"' _n 					///
				`"<!-- log type  : $weaverMarkup -->"' _n 									///
				`"<!-- software  : Weaver package $weaverversion on Stata"' 		///
				`"`c(stata_version)' -->"' _n 										///
				`"<!-- machine   : `c(machine_type)' version `c(osdtl)' -->"'_n 	///
				`"<!-- closed on : `c(current_date)', `c(current_time)' -->"'_n 	///
				"<!-- username  : `c(username)' -->" _n 							///
				`"<!-- Weaver package is developed by E. F. Haghish "' 				///
				`"(http://www.haghish.com) -->"' _n(4)
			}
			
			if "$weaverMarkup" == "latex" {
											
				if "$weaverstyle" != "empty" {
					file write `canvas' _n(2) "\end{document}" _n(2)
				}
				
				file write `canvas' _n												///
				`"%    name      : ${htmldoc}    "' _n 								///
				`"%    log       : $weaverFullPath    "' _n 					///
				`"%    log type  : $weaverMarkup    "' _n 									///
				`"%    software  : Weaver package $weaverversion on Stata"' 		///
				`"`c(stata_version)'    "' _n 										///
				///`"%    machine   : `c(machine_type)' version `c(osdtl)'    "'_n 	///
				`"%    closed on : `c(current_date)', `c(current_time)'    "'_n 	///
				///"%    username  : `c(username)'    " _n 							///
				`"%    Weaver package is developed by E. F. Haghish "' 				///
				`"(http://www.haghish.com)    "' _n	
			}
		}
	}
	
	capture file close `canvas'
				
	****************************************************************************
	*EXPORTING PDF
	****************************************************************************
	
	//PRINTING THE HTML LOG
	//---------------------
	if missing("$nopdf2") & "$weaverMarkup" == "html" {
	
		// Microsoft Windows
		if "`c(os)'"=="Windows" {	
			if "$printer" == "wkhtmltopdf" {
				`qui' shell "$setpath" 											///
				$doc_paper $doc_orientation /*$gray_scale*/  					///
				$margin_top $margin_right $margin_left $margin_bottom  			///
				$footer_font --footer-center [page] --footer-font-size 10 		///
				--no-stop-slow-scripts --javascript-delay 2000 					///
				--enable-javascript  $doc_toc --debug-javascript 				///
				"$weaverFullPath" "$pdfdoc"
				//"$htmldoc" "$pdfdoc"
			}		
		}

		// Macintosh
		if "`c(os)'" == "MacOSX" {
			if "$printer" == "wkhtmltopdf" {
				`qui' shell "$setpath" 											///
				$doc_paper $doc_orientation /*$gray_scale*/  					///
				$margin_top $margin_right $margin_left $margin_bottom  			///
				$footer_font --footer-center [page] --footer-font-size 10 		///
				--no-stop-slow-scripts --javascript-delay 2000 					///
				--enable-javascript  $doc_toc --debug-javascript 				///
				"$weaverFullPath" "$pdfdoc"	
				//"$htmldoc" "$pdfdoc"
			}
		}

		// UNIX
		if "`c(os)'"=="Unix" {	
			if "$printer" == "wkhtmltopdf" {
				`qui' shell "$setpath" 											///
				$doc_paper $doc_orientation /*$gray_scale*/  					///
				$margin_top $margin_right $margin_left $margin_bottom  			///
				$footer_font --footer-center [page] --footer-font-size 10 		///
				--no-stop-slow-scripts --javascript-delay 2000 					///
				--enable-javascript  $doc_toc --debug-javascript 				///
				"$weaverFullPath" "$pdfdoc"	
				//"$htmldoc" "$pdfdoc"
			}
		}
	}	
	
	
	//PRINTING THE LATEX LOG
	//----------------------
	if missing("$nopdf2") & "$weaverMarkup" == "latex" {
	
		if !missing("$setpath") {
			*capture shell "$setpath" "$htmldoc" "$pdfdoc" 
			*capture shell "$setpath" "$weaverFullPath" "$pdfdoc" 
			qui shell "$setpath"  -jobname="$using" "$weaverFullPath"
		}
		*else shell pdflatex "$htmldoc" "$pdfdoc"
		*else shell pdflatex "$weaverFullPath" "$pdfdoc"
		else shell pdflatex -jobname="$using" "$weaverFullPath"
	}	
	
	********************************************************************
	*PRINT THE NOTIFICATION IN STATA WINDOW
	********************************************************************		
	
	// SEARCH FOR THE PDF
	if missing("$nopdf2"){ 
	
		cap quietly findfile "$pdfdoc"
		if "`r(fn)'" != "" {
			

			
			di as txt _n                                           			 	///
			"{hline}" _n                                        		 		///
			`"      pdf :  {ul:{bf:{browse `"${weaverFullPathPDF}"':$pdfdoc}}} "' _n  		 	///
			`"     name :  {ul:{bf:{browse `"${weaverFullPath}"':$htmldoc}}} "' _n  		///
			 "      log :  {bf:$weaverFullPath}"  _n                     	///
			 " log type :  {bf:$weaverMarkup} "  _n       					///
			 "closed on :  {bf:`c(current_date)', `c(current_time)'}" _n  		
		}
				
		cap quietly findfile "$pdfdoc"
		if "`r(fn)'" == "" {
			
			cap quietly findfile "$htmldoc", path("$weaverDir")
			if "`r(fn)'" != "" {
				
				/*
				local path : pwd
				cap qui findfile "$weaver", path("`path'")
				
				local sep "`r(fn)'"
				if "`c(os)'" == "Windows" {
					local sep : subinstr local sep "/" "\", all
				}
				*/
			
				di as txt _n                                           			///
				"{hline}" _n                                        		 	///
			   `"     name :  {ul:{bf:{browse `"${weaverFullPath}"':$htmldoc}}} "' _n  	///
				"      log :  {bf:$weaverFullPath}"  _n                     			///
				" log type :  {bf:$weaverMarkup} "  _n       						///
				"closed on :  {bf:`c(current_date)', `c(current_time)'}"_n  	
				 
				di as error `"{p}{bf:no pdf was generated. }"'	 				///
				`"This could be due to a problem in accessing the pdf "' 		///
				`"driver. Visit {browse "http://www.haghish.com/weaver"} "' 	///
				`"for more information. alternatively, you can print "' 		///
				`"{browse `"${htmldoc}"'} to pdf using your web-browser or "'	///
				"other software)" _n
			}
		}
	}		
	
	if !missing("$nopdf2"){
		
		/*
		local sep "`r(fn)'"
		if "`c(os)'" == "Windows" {
			local sep : subinstr local sep "/" "\", all
		}
		*/

			
		di as txt _n                                           					///
		"{hline}" _n                                        		 			///
	   `"     name :  {ul:{bf:{browse `"${weaverFullPath}"':$htmldoc}}} "' _n  			///
		"      log :  {bf:$weaverFullPath}"  _n                     					///
		" log type :  {bf:$weaverMarkup} "  _n       								///
		"closed on :  {bf:`c(current_date)', `c(current_time)'}"_n  
	}
	
	
	********************************************************************
	* OPEN THE PDF DOCUMENT
	********************************************************************
		//if !missing("$weaverexecute") {
		//	cap quietly findfile "$pdfdoc" 
		//    if "`r(fn)'" != "" {
		// 		if "`c(os)'"=="Windows" {
		// 			winexec explorer "$pdfdoc"
		// 		}
		// 		
		// 		if "`c(os)'"=="MacOSX" {
		// 			shell open "$pdfdoc"
		// 		}
		 		
		// 		if "`c(os)'"=="Unix" {
		// 			shell xdg-open "$pdfdoc"
		// 		}	
		// 	}
		//}
		
		
		
	****************************************************************************
	* RESTORE USERS' DEFAULT SETTINGS
	****************************************************************************
	
	//Erase restored Weaver
	cap quietly findfile "_$htmldoc", path("$weaverDir")
	if "`r(fn)'" != "" {
		capture quietly erase "$weaverFullPathPreserve"
	}
	
	
	cap set scheme $savescheme						//restore default scheme

	// DROP GLOBAL MACROS
	// ==============================
	macro drop weaver								// log name
	macro drop weaversaver							// preserved document
	macro drop weaverDir							// path to weaver file
	macro drop weaverFullPath						// full path to weaver log
	macro drop weaverFullPathPDF					// full path to pdf
	macro drop weaverFullPathPreserve				// full path preserved log
	macro drop format								// for img command
	macro drop nopdf2								// for printing pdf document
	macro drop doc_toc
	//macro drop gray_scale
	macro drop doc_orientation
	macro drop doc_paper
	macro drop footer_font
	macro drop margin_top
	macro drop margin_right
	macro drop margin_left
	macro drop margin_bottom
	macro drop weavermath 							// for MathJax markup
	macro drop mathjax								// MathJax path
	macro drop weaverstyle 							// for div & codes command
	macro drop weaversynoff							// for div & code command
	macro drop savescheme
	macro drop setpath
	macro drop htmldoc
	macro drop pdfdoc
	macro drop pandoc
	macro drop localMathJax							// if MathJax is missing
	macro drop weaverAppend							// indicator for IMG command
	macro drop weaverexecute						// runs pdf docs
	macro drop ErrorDetected						// log was created error-free
	macro drop weaverMarkup							// defines the markup language
	macro drop pathMathJax							// path to MathJax
	macro drop pathPdflatex							// path to pathPdflatex
	macro drop pathWkhtmltopdf						// path to pathWkhtmltopdf
	// macro drop doc_header
	// macro drop useMarkDoc 
	// macro drop format
	
	
		
end

