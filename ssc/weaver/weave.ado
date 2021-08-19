/*

							   Weaver Package
					   
					   Developed by E. F. Haghish (2014)
					   
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						  haghish@imbi.uni-freiburg.de
						  
                   The Weaver Package comes with no warranty    	
				  
				  
	DESCRIPTION
	==============================
	
	The weave command is used both for openning a HTML/LaTeX log file as well as 
	closing it, turning it temporarily off, or on. This is the most important 
	ado file of the package that installs the required software on demand and 
	ensures the software is running propperly. 
*/

program define weave
    version 11
    syntax [anything] [using/], 												///
	[INSTALl]			/// install the required software
	[NOpdf] 			/// avoid printing PDF
	[pdf]				/// avoif error due to "nopdf" option. 
	[PRINTer(str)] 		/// path to executable wkhtmltopdf or pdflatex
	[MARKup(name)] 		/// document markup (HTML or LaTeX)
	[append|replace]	/// append or replace the dynamic report
	[PAPERsize(name)] 	/// define the PDF paper size
	[Margin(numlist max=4 min=4 int >=3 <=50)] /// top right bottom left margins
	[STYle(name)] 		/// document style
	[TEMPlate(str)] 	/// attach CSS file or extract LaTeX heading
	[LANDscape] 		/// print landscape mode PDF
	[toc] 				/// create table of content in HTML and LaTeX
	[Font(str)]			/// document font
	[TITle(str)] 		/// title of the document
	[AUthor(str)] 		/// author of the document
	[AFFiliation(str)] 	/// author's affiliation
	[ADDress(str)] 		/// email or mailing address or any relevant information 
	[SUMmary(str)] 		/// document abstract
	[Date] 				/// document creation date 
	[SYNoff]			/// turn syntax highlighter off in HTML document
	[NOIsily]			/// noisy performance; print on results window
	//[math(name)] 		/// default math in HTML document
	//[css(str)] 		/// attach CSS document in HTML document
	//[NOScheme]
	//[GRAYscale]
	//[EXEcute]
	
	****************************************************************************
	* ESSENTIAL SYNTAX PROCESSING FOR CATEGORIZING THE COMMAND
	****************************************************************************
	//Execute User-defined Weaver Paths
	capture prog drop weaversetup			// because it may have just changed
	capture weaversetup						// because it may not exist YET
	
	if missing("`papersize'") & !missing("$doc_paper") local papersize "$doc_paper"
	
	if !missing("`noisily'") | "$noisyWeaver" == "yes" {
		global noisyWeaver "yes"
	}	
	else global noisyWeaver "no"
	
	if missing("`paper'") local paper a4	//define default paper
	
	//return an error for "weave" command alone
	if missing("`anything'") & missing("`using'") {
		di as err "invalid syntax"
		exit 198
	}
	
	if !missing("`anything'") {
		if "`anything'" ~= "c" & "`anything'" ~= "cl" & "`anything'" ~= "clo" &	///
		   "`anything'" ~= "clos" & "`anything'" ~= "close" & 			 		///
		   "`anything'" ~= "on" & "`anything'" ~= "of" & "`anything'" ~= "off"  ///
		   & "`anything'" ~= "query" & "`anything'" ~= "quer" &					///
		   & "`anything'" ~= "que" & "`anything'" ~= "qu" &					    ///
		   & "`anything'" ~= "q" & "`anything'" ~= "pdf" &					///
		   "`anything'" ~= "mer" & "`anything'" ~= "merg" & 					///
		   "`anything'" ~= "merge" & "`anything'" ~= "preserve" & 				///
		   "`anything'" ~= "restore" & "`anything'" ~= "setup" {
			di as err "invalid syntax"
			exit 198
		}
			
		// `using' and `anything' together, return error if it is not merging 
		if "`anything'" ~= "mer" & "`anything'" ~= "merg" & 					///
		   "`anything'" ~= "merge" & !missing("`using'") {
			di as err "invalid syntax"
			exit 198
		}
		
		// Make sure `using' is defined with merge
		if "`anything'" == "mer" | "`anything'" == "merg" | 					///
		   "`anything'" == "merge" {
			if missing("`using'") {
				di as err "invalid syntax"
				exit 198
			}
		}
			
		// Check syntax for options and weave commands
		if !missing("`append'")          				 						///
		 | !missing("`synoff'")    | !missing("`toc'")         					///
		 | !missing("`landscape'") ///| !missing("`papersize'")   				///
		 | !missing("`margin'")    | !missing("`title'")       				 	///
		 | !missing("`author'")    | !missing("`affiliation'") 				 	///
		 | !missing("`address'")   | !missing("`date'")       	 			 	///
		 | !missing("`summary'")   | !missing("`style'")       				 	///
		 | !missing("`markup'")	   | !missing("`font'")        				 	///
		 | !missing("`install'")   | !missing("`printer'")     				 	///
		 | !missing("`template'") {
			di as err "invalid syntax"
			exit 198	 
		}
		
		if "`anything'" == "off"   | "`anything'" == "on"      			 	 	///
		 | "`anything'" == "query" | "`anything'" == "q" | "`anything'" == "qu" ///
		 | "`anything'" == "que"   | "`anything'" == "quer" {
			if !missing("`replace'") {
				di as err "invalid syntax"
				exit 198
			}
		}
	}
	
	// Setting up the Mathematics default
	// the weavermath global changes behavior of "txt" command
	
	global weavermath mathlatex

		
	****************************************************************************
	* weave quary : check the log status
	*
	* check if the log is open and if it is "off" (saved in weaversaver global)
	****************************************************************************
	if "`anything'" == "query" | "`anything'" == "q" | "`anything'" == "qu"     ///
		 | "`anything'" == "que"   | "`anything'" == "quer" {	
		
		// If the log file is closed or off
		if missing("$weaver") {				
			if  missing("$weaversaver") di as txt "(Weaver log closed)" _n
			if !missing("$weaversaver") {
			
				di as txt _n                                            	 	///
				"{hline}" _n                                        	 	///
			   `"      name:  {ul:{bf:{browse `"${weaverFullPath}"':$htmldoc}}} "' _n  	 	///
				"       log:  {bf:$weaverFullPath}"  _n                     	 		///
				"  log type:  {bf:$weaverMarkup} "  _n       				///
				"    status:  {bf:off}" _n
			}
		}
			
		// If the log file is open
		if !missing("$weaver") {			
			di as txt _n                                            		 	///
			"{hline}" _n                                        		 		///
			`"      name:  {ul:{bf:{browse `"${weaverFullPath}"':$htmldoc}}} "' _n  ///
			 "       log:  {bf:{bf:$weaverFullPath}}"  _n                     	///
			 "  log type:  {bf:$weaverMarkup} "  _n       						///
			 "    status:  {bf:on}" _n
		}	
	}
	
	****************************************************************************
	* weave off : Turning the Weaver log off
	****************************************************************************
	if "`anything'" == "off" | "`anything'" == "of" {
		
		// If the log file is closed
		if missing("$weaver") {
			if missing("$weaversaver") {
				di as err "no weaver log file open"
				exit 606
			}
			else di as txt "($weaverMarkup log already off)"
		}
			
		// If the log file is open
		if !missing("$weaver") {
			
			di as txt _n "{hline}" _n     	                         		 	///
			`"      name:  {ul:{bf:{browse `"${weaverFullPath}"':$htmldoc}}} "' _n  ///
			 "       log:  {bf:$weaverFullPath}"  _n                     		 			///
			 "  log type:  {bf:$weaverMarkup} "  _n       						///
			 " paused on:  {bf:`c(current_date)', `c(current_time)'}" _n
			
			// Print information about the log as comment
			tempname canvas 
			capture file open `canvas' using "$htmldoc" , write text append
			
			if "$weaverMarkup" == "html" {
				file write `canvas' 											///
				`"<!-- name      : ${htmldoc} -->"' _n 							///
				`"<!-- log       : $weaverFullPath -->"' _n 					///
				 "<!-- software  : Weaver package $weaverversion on Stata" 	 	///
				 "`c(stata_version)' -->" _n 									///
				 "<!-- machine   : `c(machine_type)' version `c(osdtl)' -->" _n ///
				 "<!-- resumed on: `c(current_date)', `c(current_time)' -->" _n ///
				 "<!-- username  : `c(username)' -->" _n 
			 }
			if "$weaverMarkup" == "latex" {
				file write `canvas' 											///
				`"%   name      : $htmldoc"' _n 	///
				`"%   log       : $weaverFullPath "' _n 						///
				 "%   software  : Weaver package $weaverversion on Stata" 	 	///
				 "`c(stata_version)'" _n 										///
				 "%   machine   : `c(machine_type)' version `c(osdtl)'" _n 		///
				 "%   resumed on: `c(current_date)', `c(current_time)'" _n 		///
				 "%   username  : `c(username)'" _n 
			 }
			
			global weaversaver $weaver
			global weaver  						//reset weaver
		}	
	}
		
	****************************************************************************
	* weave on Command
	****************************************************************************
	if "`anything'" == "on" {
			
		// If log file is already on
		if !missing("$weaver") {
			di as txt "($weaverMarkup log file already on)"
		}
		if missing("$weaver") {
			if missing("$weaversaver") {
				di as err "no weaver log file open"
				exit 606
			}
		}
			
		// If the log file is off
		if missing("$weaver") {
			if !missing("$weaversaver") {
		
				di as txt _n                                            	 	///
				"{hline}" _n                                        	 		///
				`"      name:  {ul:{bf:{browse `"${weaverFullPath}"':$htmldoc}}} "' _n  	 	///
				 "       log:  {bf:$weaverFullPath}"  _n                     	 			///
				 "  log type:  {bf:$weaverMarkup} "  _n       					///
				 "resumed on:  {bf:`c(current_date)', `c(current_time)'}" _n
				
				tempname canvas 
				capture file open `canvas' using "$htmldoc" , write text append
				
				if "$weaverMarkup" == "html" {
					file write `canvas' 										///
					`"<!-- name      : ${htmldoc} -->"' _n 						///
					`"<!-- log       : $weaverFullPath -->"' _n 						 	///
					`"<!-- software  : Weaver package $weaverversion on Stata"' ///
					 "`c(stata_version)' -->" _n 								///
					`"<!-- machine   : `c(machine_type)' version `c(osdtl)' -->"'_n ///
					`"<!-- resumed on: `c(current_date)', `c(current_time)' -->"'_n ///
					`"<!-- username  : `c(username)' -->"' _n 
				}	
				
				if "$weaverMarkup" == "latex" {
					file write `canvas' 										///
					`"%   name      : ${htmldoc}"' _n 						///
					`"%   log       : $weaverFullPath"' _n 						 	///
					`"%   software  : Weaver package $weaverversion on Stata"' ///
					 "`c(stata_version)'" _n 								///
					`"%   machine   : `c(machine_type)' version `c(osdtl)'"'_n ///
					`"%   resumed on: `c(current_date)', `c(current_time)'"'_n ///
					`"%   username  : `c(username)'"' _n 
				}
				
				global weaver $weaversaver
				global weaversaver 					//reset to nothing
			}
		}
	}
	
	****************************************************************************
	* weave preserve
	****************************************************************************
	if "`anything'" == "preserve" {
		
		// if no log is "open" or "on" return an error
		if missing("$weaver") {
			if missing("$weaversaver") {
				di as err "no weaver log file open"
				exit 606
			}
		}
		
		// If log file is already on
		if !missing("$weaver") {
			capture quietly copy "$weaverFullPath" "$weaverFullPathPreserve", replace public
		}
		
		// If the log file is off
		if missing("$weaver") {
			if !missing("$weaversaver") {
				*capture quietly copy "$weaversaver" "_$weaversaver", replace public
				capture quietly copy "$weaversaver" "$weaverFullPathPreserve", replace public
			}
		}
		
		di as txt "(log preserved in _$htmldoc)"
	}
	
	****************************************************************************
	* weave restore
	****************************************************************************
	if "`anything'" == "restore" {
		
		// if weaversaver and weaver are missing return an error
		if missing("$weaver") {
			if missing("$weaversaver") {
				di as err "no weaver log file open"
				exit 606
			}
		}
		
		// If log file is already on or else, it is off
		if !missing("$weaver") | missing("$weaver") & !missing("$weaversaver") {
			
			//check that the preserve file exists
			*cap quietly findfile "_$weaver" 
			cap quietly findfile "_$htmldoc", path("$weaverDir")
			if "`r(fn)'" != "" {
				*capture quietly copy "_$weaver" "$weaver", replace
				copy "$weaverFullPathPreserve" "$weaverFullPath", replace
			}
			else {
				di as err "restored $weaverMarkup log not found"
				exit 601
			}
			di as txt "($weaverMarkup log restored)"
		}
		
		// If the log file is off
		/*
		if missing("$weaver") {
			if !missing("$weaversaver") {
				
				//check that the preserve file exists
				*cap quietly findfile "_$weaversaver" 
				cap quietly findfile "_$weaver", path("$weaverDir")
				if "`r(fn)'" != "" {
					capture quietly copy "_$weaversaver" "$weaversaver", replace
				}
				else {
					di as err "restored $weaverMarkup log not found"
					exit 601
				}
			}
		}
		*/
	}
	
	
	****************************************************************************
	* weave setup : editing the default file paths
	****************************************************************************
	if "`anything'" == "setup" {
		
		capture quietly findfile weaversetup.ado
		if _rc != 0 {
			local d : pwd
			qui cd "`c(sysdir_plus)'w"
			capture copy weavercontroller.ado weaversetup.ado
			qui cd "`d'"
		}
		
		quietly findfile weaversetup.ado
		local fp `"`r(fn)'"'
		local root : environment HOME
		if strpos(`"`fp'"', "~") == 1 & !missing(`"`root'"') {
			local file : subinstr local file "~" "`root'"
		}
		di as txt "{p} edit the file below to setup the default file path for " ///
		"the required software"
		di as smcl `"{browse `"`fp'"' }"'

		doedit `"`fp'"'	
	}
	
	****************************************************************************
	* weave merge Command
	****************************************************************************
	if "`anything'" == "mer" | "`anything'" == "merg" | "`anything'" == "merge" {
		
		//Make sure the Weaver Log exists
		cap quietly findfile "$htmldoc", path("$weaverDir")
		if "`r(fn)'" == "" {
			findfile "$htmldoc"					//return an error 
		}
			
		// If log file is off
		if missing("$weaver") {
			if !missing("$weaversaver") {
				di as err "$weaverMarkup log file not on"
				exit 606
			}
			else {
				di as err "no Weaver log file open"
				exit 606
			}
		}
		
		// check the suffix of the appended file
		confirm file `using'
		local suffix : display substr("`using'",-4,.)
		if "`suffix'" ~= "html" & "`suffix'" ~= "HTML" & "`suffix'" ~= 		///
		".htm" & "`suffix'" ~= ".HTM" & "`suffix'" ~= ".tex"  {
			di as txt "{p}({it:filename} does not have {bf:html}, {bf:htm} ," ///
			" {bf:xhtml}, or  {bf:tex} suffix)"
		}

		*if "$weaver" != "" cap confirm file "$weaver"
		
		tempname canvas needle
		*cap file open `canvas' using "$weaver", write text append 
		cap file open `canvas' using "$weaverFullPath", write text append 
		file open `needle' using "`using'", read
		file read `needle' line
		
		if "$weaverMarkup" == "html" {
			while r(eof)==0 {
				
				local word1 : word 1 of `"`line'"'
				
				local line : subinstr local line "<pre" `"<pre style="white-space:pre;" "', all
				
				//Erase and cancel java scripts
				//local line : subinstr local line `"<script type="text/javascript" src='http://haghish.com/statax/Statax.js'></script>"' "" 
				//local line : subinstr local line "<script" "<!-- script", all
				//local line : subinstr local line "/script> " "/script-->", all
				
				if `"`macval(line)'"' == `"<script type="text/javascript" src='http://haghish.com/statax/Statax.js'></script>"' ///
				{
					cap file read `needle' line
					local word1 : word 1 of `"`line'"'
				}
				
				//If the document has JavaScript give a warning
				if substr(`"`word1'"',1,7) == "<script" {
					local warning 1
				}
				
				cap file write `canvas' `"`macval(line)'"' _n      
				cap file read `needle' line
			}
		}
		
		if "$weaverMarkup" == "latex" {
			
			//CHECK IF THE LATEX INCLUDES "\begin{document}"
			while r(eof)==0 {
				
				local word1 : word 1 of `"`line'"'
				if substr(`"`macval(line)'"',1,16) == "\begin{document}" {
					local begin 1
				}
				cap file read `needle' line
			}
			
			//If there was no "\begin{document}", append everything
			if missing("`begin'") {
				file close `needle'
				file open `needle' using "`using'", read
				cap file write `canvas' _n
				file read `needle' line
				
				while r(eof)==0 {
					cap file write `canvas' `"`macval(line)'"' _n
					cap file read `needle' line
					local word1 : word 1 of `"`line'"'
				}
				
			}
			
			
			// IF THE DOCUMENT INCLUDED "\begin{document}"
			if "`begin'" == "1" {
				
				file close `needle'
				file open `needle' using "`using'", read
				cap file write `canvas' _n
				file read `needle' line
				
				while r(eof)==0  {		
				
					local word1 : word 1 of `"`line'"'
					
					while substr(`"`macval(line)'"',1,16) != "\begin{document}" &	///
					r(eof) == 0 {
						cap file write `canvas' `"%`macval(line)'"' _n
						cap file read `needle' line
						local word1 : word 1 of `"`line'"'
					}
					
					//JUMP FROM THE BEGINNING
					if substr(`"`macval(line)'"',1,16) == "\begin{document}" {
						cap file write `canvas' `"%`macval(line)'"' _n
						cap file read `needle' line
						local word1 : word 1 of `"`line'"'
						local warning 2
					}
					
					while substr(`"`macval(line)'"',1,14) != "\end{document}" &	///
					r(eof) == 0 {
						
						if substr(`"`macval(line)'"',1,7) == "\title{" {
							cap file write `canvas' `"%`macval(line)'"' _n
							cap file read `needle' line
							local word1 : word 1 of `"`line'"'
						}
						
						if substr(`"`macval(line)'"',1,8) == "\author{" {
							cap file write `canvas' `"%`macval(line)'"' _n
							cap file read `needle' line
							local word1 : word 1 of `"`line'"'
						}
						
						if substr(`"`macval(line)'"',1,10) == "\maketitle" {
							cap file write `canvas' `"%`macval(line)'"' _n
							cap file read `needle' line
							local word1 : word 1 of `"`line'"'
						}
						
						if substr(`"`macval(line)'"',1,6) == "\date{" {
							cap file write `canvas' `"%`macval(line)'"' _n
							cap file read `needle' line
							local word1 : word 1 of `"`line'"'
						}
						
						cap file write `canvas' `"`macval(line)'"' _n  
						cap file read `needle' line
						local word1 : word 1 of `"`line'"'
					}
					
					if substr(`"`macval(line)'"',1,14) != "\end{document}" {
						cap file write `canvas' `"%`macval(line)'"' _n
					}
					 
					cap file read `needle' line
				}	
			}
		}
		
		file close `needle'
		
		if !missing("`warning'") {
			di as txt _n(2) "{hline}"
			di as error "{bf:Warning}" _n
			
			if "`warning'" == "1" di as txt "{p}the merged document includes "	///
			"JavaScript which could {it:potentially but not necessarily} "		///
			"damage the dynamic document."	_n 
			
			if "`warning'" == "2" di as txt "{p}the merged document included "	///
			"{bf:\begin{document}} command which could damage the dynamic " 	///
			"document but Weaver attempted to remove it automatically. " 		///
			"Make sure the LaTeX files you merge only includes the content, " 	///
			"without packages, title page, beginning and ending of the document" _n
			
			di as txt "{hline}{smcl}"	_n
		}		
	}

	****************************************************************************
	* weave close Command
	****************************************************************************
	if "`anything'" == "c"   | "`anything'" == "cl"   						 	///
	| "`anything'" ==  "clo" | "`anything'" == "clos" 						 	///
	| "`anything'" == "close"  {	
		if missing("$weaver") {
			if missing("$weaversaver") {
				di as err "no log file open"
				exit 606
			}
			
			// If the log file is off
			if !missing("$weaversaver") {	
				global weaver $weaversaver			 //it no longer matters
				global weaversaver 					 //reset
			}
		} 
		
		//>>>>> ADDING REPLACE OPTION FOR "WEAVE CLOSE" WAS SO ANNOYING
		// If the log file is on
		if !missing("$weaver") {
			
			// check if the pdfdoc is existing
			//local path : pwd
			//cap qui findfile "$pdfdoc", path("`path'")
			//if !missing("`r(fn)'") {
			//	if missing("`replace'") {
			//		di as err "{bf:replace} option is required"	
			//		di as err "{p}file `r(fn)' already exists{smcl}"
			//		exit 602
			//	}
			//	if !missing("`replace'") weavend
			//}
			//if missing("`r(fn)'") {
			//}
			
			//Make sure the Weaver Log exists
			cap quietly findfile "$htmldoc", path("$weaverDir")
			
			if "`r(fn)'" == "" {
				di as err "file $htmldoc not found"			//return an error 
				quietly weavend
			}
			
			else {
				
				//If the file is in LaTeX, first end it
				noisily weavend 						// CALL THE WEAVEND PROGRAM
			} 
		}
	}
	
	****************************************************************************
	* weave pdf : creating pdf "report"
	****************************************************************************
	if "`anything'" == "pdf"  {
			
		// If $weaver and $weaversaver log are missing
		*if missing("$weaver") & missing("$weaversaver") {
		*	di as err "no log file open" _n
		*	exit 606
		*} 
			
		// If the log file is off
		if missing("$weaver") & !missing("$weaversaver") {
			//turn log on, temporarily (for report.ado)
			local temp temp
			global weaver $weaversaver
		}
			
		// If the log file is on
		if !missing("$weaver") {
			
			//Make sure the Weaver Log exists
			cap quietly findfile "$htmldoc", path("$weaverDir")
			if "`r(fn)'" == "" {
				findfile "$htmldoc"					//return an error 
			}
			
			// check if the pdfdoc is existing
			local path : pwd
			cap qui findfile "$pdfdoc", path("$weaverDir")
			if !missing("`r(fn)'") {
				if missing("`replace'") {
					di as err "{bf:replace} option is required"	
					di as err "{p}file `r(fn)' already exists{smcl}"
					exit 602
				}
				if !missing("`replace'") report
			}
			if missing("`r(fn)'") {
				
				// If the program is written in LaTeX, make a preview copy of it, 
				// terminate the preview, and print the pdf
				
				*capture quietly copy "$weaver" "_$weaver_preview", replace public
				
				report 								// CALL THE REPORT PROGRAM
			} 
		}		
		
		//make the log off again
		if "`temp'" == "temp" global weaver 		//turn it off
	}
		
		
	****************************************************************************
	*
	*
	* weave using Command : THIS IS THE MAIN BODY OF THE WEAVE COMMAND
	*
	*
	****************************************************************************
	if missing("`anything'") & !missing("`using'") {
		
		// If for unrecognized reason, Weaver failes to open a HTML log, 
		// Remove all the global macros 
		if !missing("$ErrorDetected") {
			macro drop weaver
			macro drop weaversaver
			macro drop weaverFullPathPreserve		// full path preserved log
			macro drop format						// for img command
			macro drop nopdf2						// for printing pdf document
			macro drop doc_toc
			//macro drop gray_scale
			macro drop doc_orientation
			macro drop doc_paper
			macro drop footer_font
			macro drop margin_top
			macro drop margin_right
			macro drop margin_left
			macro drop margin_bottom
			macro drop weavermath 					// for MathJax markup
			macro drop mathjax						// MathJax path
			macro drop weaverstyle 					// for div & codes command
			macro drop savescheme
			macro drop printer
			macro drop setpath
			macro drop htmldoc
			macro drop pdfdoc
			macro drop pandoc
			macro drop weaverexecute				// runs pdf docs 
			macro drop weaverMarkup					// markup language
			*macro drop pathMathJax					// path to MathJax
			*macro drop pathPdflatex				// path to pathPdflatex
			*macro drop pathWkhtmltopdf				// path to pathWkhtmltopdf
		}
		
		global ErrorDetected 1						// error exists in the process
		
		
		// Make sure the log file is not already open or even temporarily off
		if !missing("$weaver") {
            di as err "$weaverMarkup log file already open"
			exit 604
		}    
		if missing("$weaver") & !missing("$weaversaver") {
			di as err "$weaverMarkup log file already open"
			exit 604
		}
		

		// DEFINE THE MARKUP LANGUAGE
		// ==============================
		if "`markup'" == "HTML" | "`markup'" == "html" {
			global weaverMarkup html
		}
		else if "`markup'" == "LATEX" | "`markup'" == "LaTeX" | "`markup'" == 	///
		"tex" | "`markup'" == "latex" {
			global weaverMarkup latex
		}
		else if !missing("`markup'") {
			di as err "invalid syntax"
			exit 198
		}
		
		// DEFINING THE FILE NAMES
		// ==============================
		if missing("`markup'") {
			local suffix : display substr("`using'",-4,.)
			if "`suffix'" == "html" {
				local using : display substr("`using'",1,length("`using'")-5)
				global weaverMarkup html
				local markup html
			}
			else if "`suffix'" == ".tex" {
				local using : display substr("`using'",1,length("`using'")-4)
				global weaverMarkup latex
				local markup latex
			}
			
			if "`suffix'" != "html" & "`suffix'" != ".tex" {
				//di as err "{p}define the {bf: markup(}{it:name}{bf:)} option "	///
				//"or specify the file suffix which can be {bf:.html} or {bf:.tex}" _n
				//exit 198
				global weaverMarkup html
				local markup html
			}
		}
		
		
		if "`markup'" == "html"  {
			local suffix : display substr("`using'",-4,.)
			if "`suffix'" == "html" {
				local using : display substr("`using'",1,length("`using'")-5)
			}
			global using    "`using'" 		  			// name of the file 
			global pdfdoc  `"`using'.pdf"' 				// name of PDF file 
			global htmldoc `"`using'.html"'	  			// HTML Log
		}
		
		if "`markup'" == "latex" {
			local suffix : display substr("`using'",-3,.)
			if "`suffix'" == "tex" {
				local using : display substr("`using'",1,length("`using'")-4)
			}
			global using    "`using'" 		  			// name of the file 
			global pdfdoc  `"`using'.pdf"' 				// name of PDF file 
			global htmldoc `"`using'.tex"'	  			// LaTeX Log File
		}
													
		// WEAVER SAVINGS
		// ==============================
		qui global location "`c(pwd)'" 				// current working directory		
		if "$weaverMarkup" == "html" {
			global printer wkhtmltopdf				// Define the PDF printer
		}	
		if "$weaverMarkup" == "latex" {
			global printer pdfLaTeX				// Define the PDF printer
		}
		global weaverDir     : pwd					// Weaver log directory
		if "`c(os)'"=="Unix" | "`c(os)'" == "MacOSX"  {
			global weaverFullPath : di "$weaverDir""/""$htmldoc"
			global weaverFullPathPDF : di "$weaverDir""/""$pdfdoc"
			global weaverFullPathPreserve : di "$weaverDir""/_""$htmldoc"			
		}	
		if "`c(os)'"=="Windows"  {
			global weaverFullPath : di "$weaverDir""\""$htmldoc"
			global weaverFullPathPDF : di "$weaverDir""\""$pdfdoc"
			global weaverFullPathPreserve : di "$weaverDir""\_""$htmldoc"	
		}
		global savescheme `c(scheme)'				// default scheme
		global weaverstyle "`style'"				// alters "div" & "codes"
		global weaversynoff "`synoff'"				// alters "div" & "codes"
		global weaverexecute `execute'				// runs the pdf files
		if !missing("`nopdf'") global nopdf2 1 		// for img command
		if missing("`landscape'") global format "normal"
		if !missing("`landscape'") global format "landscape"	// for img command

		************************************************************************
		* PRINTER, , PRINTER PATH, DOCUMENT MARGINS, PAPERSIZE
		************************************************************************
		if "`toc'" == "toc" global doc_toc 										///
		"toc --page-offset -1 --toc-text-size-shrink 1.0 " 
		
		//if !missing("`grayscale'") global gray_scale "--grayscale" 
		if !missing("`landscape'") global doc_orientation "--orientation Landscape"
		if !missing("`paper'") {
			foreach lname in A0 a0 A1 a1 A2 a2 A3 a3 A4 a4 A5 a5 A6 a6 A7 a7 	///
				A8 a8 A9 a9 B0 b0 B1 b1 B2 b2 B3 b3 B4 b4 B5 b5 B6 b6 B7 		///
				b7 B8 b8 B9 b9 B10 b10 C5E c5e Comm10E comm10e DLE dle 			///
				Executive executive Folio folio Ledger Legal legal Letter 		///
				letter Tabloid tabloid {
				
				// if the defined name exists in the list
				if "`paper'" == "`lname'" {
					global doc_paper "--page-size `paper'"
				}
			}
			
			if !missing("`paper'") & missing("$doc_paper") {
				di as err "invalid syntax"
				exit 198
			}
		}
		
		local latexFont
		if !missing("`font'") & "`markup'" == "latex" {
			foreach nam in cmtt lmtt pcr cmss lmss pag phv cmr lmr pbk bch pnc 	///
			ppl ptm {
				if "`font'" == "`nam'" {
					local latexFont "`nam'"
				}	
			}
			if missing("`latexFont'") {
				display as err "{p}{bf:`font'} is not a valid " ///
				"LaTeX font name. Visit the link below for more information" ///
				`"{browse "https://en.wikibooks.org/wiki/LaTeX/Fonts#Available_LaTeX_Fonts_.5B2.5D"}"'
				
				exit 198
			}
		}
		
		if !missing("`margin'") {
			local i = 0
			tokenize `"`margin'"' , parse(" ")
			while `"`1'"' ~= "" {
				loc i `++i'
				local m`i' = `"`1'"'
				macro shift
			}
		}
		 
		if !missing("`landscape'") {
			if missing("`margin'") {
				global margin_top "--margin-top 12mm"
				global margin_right "--margin-right 13mm"
				global margin_left "--margin-left 6mm"
				global margin_bottom "--margin-bottom 6mm"
			}
		}
		
		if missing("`landscape'") {
			if missing("`margin'") {
				global margin_top "--margin-top 10mm"
				global margin_right "--margin-right 15mm"
				global margin_bottom "--margin-bottom 10mm"
				global margin_left "--margin-left 15mm"
			}
		}
		
		if !missing("`margin'") {
			global margin_top "--margin-top `m1'mm"
			global margin_right "--margin-right `m2'mm"
			global margin_bottom "--margin-bottom `m3'mm"
			global margin_left "--margin-left `m4'mm"
		}
		
		// check the Printer path
		if !missing("`printer'") {
			global setpath `"`printer'"'
			confirm file "$setpath"
		}
		
		************************************************************************
		* CHECKING THE SYNTAX COMMANDS AND OPTIONS
		************************************************************************
		// check the options that can be used with append 
		if !missing("`append'") {
			if !missing("`replace'") local a1 "{bf:replace}" 
			if !missing("`synoff'") local a3 "{bf:synoff}"
			if !missing("`font'") local a4 "{bf:font()}"
			if !missing("`title'") local a5 "{bf:title()}"
			if !missing("`author'") local a6 "{bf:author()}"
			if !missing("`address'") local a7 "{bf:address()}"
			if !missing("`affiliation'") local a8 "{bf:affiliation()}"
			if !missing("`date'") local a9 "{bf:date}"
			if !missing("`summary'") local a10 "{bf:summary()}"
			if !missing("`template'") & "$weaverMarkup" == "html" local a10 "{bf:css()}"
			
			local j 1 
			forvalues i = 1/11 {
				if !missing("`a`i''") {
					local name`j' `a`i''
					local j = `j'+1
					//di as err "option `a`i'' not allowed" 
				}	
			}
			if `j' == 2 {
				di as err "option `name1' not allowed" _n
				exit 198
			}
			if `j' > 2 {
				local k 2
				di as err "options `name1'" _c
				while `j' != `k' {
					if `k'+1 != `j' di as err ", `name`k''" _c
					if `k'+1 == `j' di as err ", and `name`k''" _c
					local k = `k'+1
				}
				di as err " not allowed"
				exit 198
			}
		}	
			
			//di as err "option {bf:append} not allowed" _n e 198
				
		// Setup Style, Font, & Scheme
		// ==============================
		
		//DEFAULT STYLE IS STATA
		if "`style'" == "" local style stata
		
		if !missing("`style'") & "`style'" ~= "modern" & "`style'" ~= "minimal" ///
			& "`style'" ~= "elegant" & "`style'" ~= "classic" & "`style'" ~=	///
			"stata" & "`style'" ~= "empty" {
			di as err "option {bf:style(`style')} not allowed"
            exit 198
		}
		
		if "`style'" == "modern" {
			if missing("`font'") {
				local font Arial, Helvetica, sans-serif
				global footer_font --footer-font-name "Arial" 
			}
			else global footer_font --footer-font-name "`font'" 	
			//if missing("`noscheme'") cap set scheme s2color8
		}
		
		if "`style'" == "classic" {
			if missing("`font'") {
				local font Times New Roman, Times, serif
				global footer_font --footer-font-name "Times New Roman" 
			}
			else global footer_font --footer-font-name "`font'" 		
			//if missing("`noscheme'") cap set scheme s1color		
		}
				
		if "`style'" == "minimal" {
			if missing("`font'") {
				local font Times New Roman, Times, serif
				global footer_font --footer-font-name "Times New Roman" 
			}
			else global footer_font --footer-font-name "`font'" 		
			//if missing("`noscheme'") cap set scheme s1mono 			
		}
				
		if "`style'" == "elegant" {
			if missing("`font'") {
				local font Arial, Helvetica, sans-serif
				global footer_font --footer-font-name "Arial" 
			}
			else global footer_font --footer-font-name "`font'" 			
			//if missing("`noscheme'") cap set scheme s1color			
		}

		if "`style'" == "stata" {
			if missing("`font'") {
				local font Arial, Helvetica, sans-serif
				global footer_font --footer-font-name "Arial" 
			}
			else global footer_font --footer-font-name "`font'" 		
			//if "`noscheme'" == "" cap set scheme s2color		
		}

		
		
		
		************************************************************************
		* CHECKING THE REQUIRED SOFTWARE
		*
		* note that weavercheck requires $weaverMarkup global
		************************************************************************
		weavercheck, `install' `synoff'
		
		************************************************************************
		* OPEN A PARALLEL LOG FILE
		************************************************************************
		local path : pwd
		cap qui findfile "$htmldoc", path("`path'") 
		

        tempname canvas 
        file open `canvas' using "$htmldoc", write text all				///
		`append' `replace' 
		
		// checking if the Weaver canvas already exists 
        if _rc == 602 { 
			di as err `"{p}file `r(fn)' already exists{smcl}"' 
			exit 602
		}
		
		// If it does not exist, create the weaver global
		global weaver "$htmldoc" 
        
		************************************************************************
		* IF APPEND IS SPECIFIED, PREPARE THE LOG
		************************************************************************
		if !missing("`append'") {
			
			global weaverAppend 1						// for IMG command
			
			if "`markup'" == "latex" | "$weaverMarkup" == "latex" {
				
				tempfile tmp
				tempname testcanvas needle
				cap file open `testcanvas' using "`tmp'", write text append 
				file open `needle' using "$htmldoc", read
				file read `needle' line
				while r(eof)==0 {
				
					local word1 : word 1 of `"`line'"'
					
					
					while substr(`"`macval(line)'"',1,14) != "\end{document}" &	///
					r(eof) == 0 {
						cap file write `testcanvas' `"`macval(line)'"' _n  
						cap file read `needle' line
						local word1 : word 1 of `"`line'"'
						local warning 1
					}
					 
					cap file read `needle' line
				}
				file close `needle'
				file close `testcanvas'
				file close `canvas'
				
				if !missing("`warning 1'") copy "`tmp'" "$htmldoc", replace
				if _rc != 0 & !missing("`warning 1'") {
					di as err "{p}`using' includes {bf:\end{document}} command which will " ///
					"cause trouble in typesetting the LaTeX document (i.e. multiple document problem). Weaver " ///
					"attempted to remove {bf:\end{document}} but failed to replace" ///
					" the file due to limited access rights in the working " ///
					"directory. Erase {bf:\end{document}} from `using' manually " 	///
					"and try again. {smcl}" 
					
					exit 198
				}
				
				tempname canvas 
				capture file open `canvas' using "$htmldoc", write text all				///
				`append' `replace' 
				
				// checking if the Weaver canvas already exists 
				if _rc == 602 { 
					di as err `"{p}file `r(fn)' already exists{smcl}"' 
					exit 602
				}
			}

		
			local path : pwd
			cap qui findfile "$htmldoc", path("`path'")
			local sep "`r(fn)'"
			if "`c(os)'" == "Windows" {
				local sep : subinstr local sep "/" "\", all
			}
		
		
			if "`markup'" == "html" | "$weaverMarkup" == "html" {
				file write `canvas' 												///
				`"<!-- name      : ${htmldoc} -->"' _n 								///
				`"<!-- log       : $weaverFullPath -->"' _n 								///
				"<!-- software  : Weaver package $weaverversion on Stata "			///
				"`c(stata_version)' -->" _n 										///
				`"<!-- machine   : `c(machine_type)' version `c(osdtl)' -->"'_n 	///
				`"<!-- append on : `c(current_date)', `c(current_time)' -->"'_n 	///
				"<!-- username  : `c(username)' -->" _n 
			}	
			
			if "$weaverMarkup" == "latex" {
				file write `canvas' 												///
				"%    name      : ${htmldoc} " _n 								///
				"%    log       : $weaverFullPath " _n 								///
				"%    software  : Weaver package $weaverversion on Stata "			///
				"`c(stata_version)' " _n 										///
				"%    machine   : `c(machine_type)' version `c(osdtl)' "_n 	///
				"%    append on : `c(current_date)', `c(current_time)' "_n 	///
				"%    username  : `c(username)' " _n 
			}	
		}
		
		************************************************************************
		* IF APPEND IS NOT SPECIFIED, COPY ALL THE STYLE AND JAVASCRIPT FILES
		************************************************************************
		if missing("`append'") {
            
			local path : pwd
			cap qui findfile "$htmldoc", path("`path'")
			local sep "`r(fn)'"
			if "`c(os)'" == "Windows" {
				local sep : subinstr local sep "/" "\", all
			}
			
			if "`markup'" == "html" {
				
				if "`style'" != "empty" {
					file write `canvas' `"<!doctype html>"' _n(4)
				}
				
				file write `canvas' 											///
				`"<!-- name      : ${htmldoc} -->"' _n 							///
				`"<!-- log       : $weaverFullPath -->"' _n 								///
				"<!-- software  : Weaver package $weaverversion on Stata "		///
				"`c(stata_version)' -->" _n 									///
				`"<!-- machine   : `c(machine_type)' version `c(osdtl)' -->"'_n ///
				`"<!-- opened on : `c(current_date)', `c(current_time)' -->"'_n ///
				"<!-- username  : `c(username)' -->" _n 						///
				"<!-- Weaver package is developed by E. F. Haghish "			///
				"(http://www.haghish.com) -->" _n(3)							
				
				if "`style'" != "empty" {
					file write `canvas' `"<html>"' _n							///
					"<head>" _n														///
					`"<meta charset="UTF-8">"' _n 									///
					`"<meta name="description" content="Weaver Analysis Document."' ///
					`" Learn more on http://www.haghish.com">"' _n 					///
					`"<meta name="author" content="E. F. Haghish">"' _n(2)
						
					if !missing("`title'") {
						file write `canvas' `"<title>`title'</title>"' _n
					}
				}	
			}
			  
			if "`markup'" == "latex"  {

				file write `canvas'  _n											///
				`"%   name      : ${htmldoc}"' _n 								///
				`"%   log       : $weaverFullPath"' _n 									///
				"%   software  : Weaver package $weaverversion on Stata "		///
				"`c(stata_version)'" _n 										///
				`"%   machine   : `c(machine_type)' version `c(osdtl)'"' _n 	///
				`"%   opened on : `c(current_date)', `c(current_time)'"' _n 	///
				"%   username  : `c(username)'" _n 								///
				"%   Weaver package is developed by E. F. Haghish "				///
				"(http://www.haghish.com)" _n(3)								
				
				if "`style'" != "empty" {
				file write `canvas' "\documentclass[11pt]{article}" _n			///
					"\usepackage{geometry}         %change page dimensions" _n 	///
					"\usepackage{booktabs}         %for tables" _n				///
					"\usepackage{caption}          %for caption alignment"	_n	///
					"\usepackage{hyperref}         %create links" _n 			///
					"\usepackage[utf8]{inputenc}   %table of content" _n 		///
					"\usepackage{pdfpages}         %insert PDF" _n 				///
					"\usepackage{epsfig}           %insert PostScript" _n 		///
					"\usepackage{graphicx}         %insert figures" _n 			///
					"\geometry{`paper'paper" _n									///
				
					if !missing("`margin'") {
						file write `canvas' ///
						", top=`m1'mm, right=`m2'mm, bottom=`m3'mm, left=`m4'mm" _n
					}
				
					file write `canvas' 										///
					"}                             %paper size & margins" _n															///
					
				
					if !missing("`landscape'") {
						file write `canvas' 									///
						"\geometry{landscape}          %landscape document" _n
					}
					
					if !missing("`latexFont'") {
						
						//Roman fonts
						foreach nam in cmr lmr pbk bch pnc ppl ptm {
							if "`latexFont'" == "`nam'" file write `canvas' 			///
							"\renewcommand{\familydefault}{\rmdefault}" _n
						}
						
						//Sans Serif Fonts
						foreach nam in cmss lmss pag phv {
							if "`latexFont'" == "`nam'" file write `canvas' 			///
							"\renewcommand{\familydefault}{\sfdefault}" _n
						}
						
						//Typewriter Fonts
						foreach nam in cmtt lmtt pcr {
							if "`latexFont'" == "`nam'" file write `canvas' 			///
							"\renewcommand{\familydefault}{\ttdefault}" _n
						}
						
						
						file write `canvas' 									///
						"\usepackage{sectsty}          %change the font" _n 	///
						"\sectionfont{\fontfamily{`latexFont'}\selectfont}" _n 		///
						"\subsectionfont{\fontfamily{`latexFont'}\selectfont}" _n	///
						"\subsubsectionfont{\fontfamily{`latexFont'}\selectfont}" _n
					}
					
					file write `canvas' 										///
					"\makeatletter				   %reduce verbatim font" _n	///
					"\def\verbatim@font{\ttfamily\footnotesize}" _n				///
					"\makeatother" _n											
				}
				
				// Append external template file
				if !missing("`template'") {
					confirm file "`template'"
					tempname latexstyle
					file open `latexstyle' using "`template'", read
					file read `latexstyle' line
					while r(eof)==0 & substr(trim(`"`macval(line)'"'),1,16) != 	///
					"\begin{document}"{
						cap file write `canvas' `"`macval(line)'"' _n
						cap file read `latexstyle' line
					}
					file close `latexstyle'
				}
			}
			********************************************************************
			* ADD DOCUMENT CSS STYLES TO HTML LOG
			********************************************************************
			file close `canvas'
			
			weaverstyle, style("`style'") font("`font'")  `landscape' markup("`markup'")
			
			qui file open `canvas' using "$htmldoc" , write text append
			
			
			********************************************************************
			* ADD WEAVER MARKUP TO HTML LOG
			********************************************************************
			if "`markup'" == "html" & "`style'" != "empty" {
	
				
				file close `canvas'
			
				weavermarkup 

				capture file open `canvas' using "$htmldoc" , write text append
				
				********************************************************************
				* JQuary files
				********************************************************************
				file write `canvas' _n 											///
				"<script src=" `""http://ajax.googleapis.com/ajax/libs/"'		///
				`"jquery/1.8.3/jquery.js"></script> "' _n  						///
				//`"<script src="http://ajax.googleapis.com/"' ///
				//`"ajax/libs/jquery/1.11.3/jquery.min.js"></script> "' _n(2)   ///	
				
				
				
				
				//cap quietly findfile "jquery.min.js", path("`c(sysdir_plus)'Weaver")
				//if "`r(fn)'" == "" {
				//	local install install
				//	if `"`install'"'  == "install" {
				//		qui local sub "`c(pwd)'"
				//		qui cd "`c(sysdir_plus)'/Weaver"
				//		cap qui copy "http://www.haghish.com/software/jquery.min.js" ///
				//		"jquery.min.js", replace  
				//		qui cd "`sub'"
				//		local jqinstalled 1
				//	}
					
				//	if `"`install'"'  ~= "install" {
				//		file write `canvas' _n `"<script src="http://ajax.googleapis.com/"' ///
				//		`"ajax/libs/jquery/1.11.3/jquery.min.js"></script> "' _n(2)   			
				//	}
				//}
				
				//if "`r(fn)'" ~= "" | !missing("`jqinstalled'") {
				//	qui local sub "`c(pwd)'"
				//	qui cd "`c(sysdir_plus)'/Weaver"
				//	local d : pwd
				//	local jqpath : di "`d'/jquery.min.js"
				//	file write `canvas' _n `"<script src="`jqpath'"></script> "' _n(2) 
					
					//tempname jq
					//qui file open `jq' using "`jqpath'" , read
					//file read `jq' line
					
					//file write `canvas' _n "<script>" _n
					//while r(eof)==0 {
					//	cap file write `canvas' `"`macval(line)'"' _n      
					//	cap file read `jq' line
					//}
					//file write `canvas' _n "</script>" _n
					//qui file close `jq'
				//	qui cd "`sub'"
				//}

				
				
				****************************************************************
				* JavaScript "Easing" and Smooth Zoom Codes
				****************************************************************
				file close `canvas'
				
				weaverzoom
				
				qui file open `canvas' using "$htmldoc" , write text append
					
				****************************************************************
				* JavaScript Syntax Highlighter for Stata
				****************************************************************
				if "`synoff'" ~= "synoff" {
					
					file close `canvas'
					global weaverstatax weaverstatax	// Communicates with Statax
					statax using "$htmldoc",  css("`template'") append 
					capture file open `canvas' using "$htmldoc" , write text append
				}
			
			}
			
			
			********************************************************************
			* ADD STATAX LATEX SYNTAXHIGHLIGHTER
			********************************************************************		
			if "`markup'" == "latex" & "`style'" != "empty" & missing("`synoff'") {						
				capture quietly findfile statax.tex
				if _rc == 0 {
					tempname stx
					qui local sub "`c(pwd)'"
					qui cd "`c(sysdir_plus)'s"
					local d : pwd
					local statax : di "`d'/statax.tex"
					qui cd "`sub'"				
					file open `stx' using "`statax'" , read
					file read `stx' line
					while r(eof) == 0 {
						qui file write `canvas' `"`macval(line)'"' _n      
						qui file read `stx' line
					}
					qui file close `stx'
				}
			}
			
			
			********************************************************************
			* Adding MathJax.js script
			*
			* Copyright (c) 2009-2015 The MathJax Consortium
			* license: http://www.apache.org/licenses/LICENSE-2.0
			* Developed by https://www.mathjax.org/
			********************************************************************
			if !missing("$mathjax") { 
				
				if "`markup'" == "html" {
					file write `canvas' _n(3) 								///
					_n(2) `"<script type="text/x-mathjax-config">"' _n 		///
					_skip(4) "MathJax.Hub.Config({tex2jax: {inlineMath" 	///
					///": [['§','§'],['##','##'], ['\\(','\\)']]}});" _n 	///
					": [['\\(','\\)']]}});" _n 				///
					"</script>" _n(2) 										///
					"<script type="`"""'"text/javascript"`"""' 				/// 
					/// _skip(4) "src="`"""'"http://cdn.mathjax.org/
					///mathjax/latest/MathJax.js" 						///
					_skip(4) "src="`"""'"$mathjax" 						///
					"?config=TeX-AMS-MML_HTMLorMML"`"""'">" _n 			///
					"</script>" _n(2)		
				}	
			}
			
			// If missing, add the online link to the HTML file!
			else if "`markup'" == "html" {
				
				global localMathJax 1					// tell TXT command
			
				file write `canvas' _n(3) 									///
				"<script type="`"""'"text/javascript"`"""'" async" _n		///
				_skip(4) "src="`"""'"https://cdn.mathjax.org/mathjax/latest/"	///
				"MathJax.js?config=TeX-MML-AM_CHTML"`"""'">" _n 			///	
				"</script>" _n(2) 											///
				_n(2) `"<script type="text/x-mathjax-config">"' _n 			///
				_skip(4) "MathJax.Hub.Config({tex2jax: {inlineMath" _n 		///
				": [['§','§'],['##','##'], ['\\(','\\)']]}});" _n 			///
				"</script>" _n(2) 											
			}
				
			********************************************************************
			*
			* LOADING ALL THE JavaScript codes
			*
			********************************************************************
			if "`markup'" == "html" {	
				file write `canvas' _n(3) 											///
				`"<script language="javascript">"' _n 								///
				_skip(4) "function start(){ "_n 									///
					_skip(8) "correction(); "_n 									/// //Load Weaver Markup
					_skip(8) "sh_highlightDocument(); "_n 							///	//Load Statax
				/// _skip(8) `"generateTOC(document.getElementById("'"'toc'"`"));"' ///	//Load dynamic table
				_skip(8) "$('img').smoothZoom({ });"_n 								///	//Load easing zoom
				_skip(4) "} "_n 													///
				"</script> "_n(2) 													///
				`"<script type="text/javascript" language="javascript">"' _n 		///
					  _skip(4) "window.onload = function() "_n 						///
					  _skip(4) "{ "_n 												///
						  _skip(8) "start(); "_n 									///
					  _skip(4) "}; "_n 												///
				"</script> "_n(4) 
			}
			
			
			
			********************************************************************
			* ending the HTML head tag, printing title, author, and doc info
			********************************************************************
			if "`markup'" == "html" {
				file write `canvas' "</head>" _n(2) 								///
				`"<body>"' _n(10)
				
				// defining the title of the report, which appears on the first page 
				if !missing("`title'") 	  | !missing("`author'") | 					///
				!missing("`affiliation'") | !missing("`address'") {
					file write `canvas' `"<header>`title'</header>"' _n
				}	
				
				if "`author'" ~= "" {
					file write `canvas' `"<span class="author">`author'</span>"' _n
				}
				
				if "`affiliation'" ~= "" {
					file write `canvas' `"<span class="author">`affiliation'</span>"' _n
				}	

				if `"`address'"' ~= "" {
					file write `canvas' `"<span class="author">`address'</span>"' _n
				}
				
				if "`date'" == "date" {
					file write `canvas' 											///
					`"<span style="font-size: 14px;text-align:center;"' 			///
					`"display:block; padding: 0 0 36px 0;">"' 						///
					`"`c(current_date)'</span>"' _n(2)
				}
			
				if `"`summary'"' ~= "" {
					file write  `canvas' _n(4) 										///
					`"<p style="padding-right:15%;padding-left:15%;padding:"' 		///
					`"-top100px;text-align:justify;text-justify:inter-word;">"' 	///
					`"`summary'</p><br />"' _n
				}
			
				if !missing("`title'") | !missing("`author'") | 					///
				!missing("`affiliation'") | !missing("`address'") {
					file write `canvas' `"<div class= "pagebreak" ></div>"' _n
				}
			}
			
			if "`markup'" == "latex" & "`style'" != "empty" {
				
				file write  `canvas' _n(5) "\begin{document}" _n 
				
				if !missing("`latexFont'") file write `canvas' ///
				"\fontfamily{`latexFont'}\selectfont" _n
				
				if "`title'" ~= "" {
					file write `canvas' `"\title{`title'}"' _n
				}
				
				if !missing("`author'") | !missing("`affiliation'") ///
				| !missing("`address'") {
					file write `canvas' "\author{"
					
					
					if "`author'" ~= "" file write `canvas' `"`author' "' 
				
				
					if "`affiliation'" ~= "" file write `canvas' "\\ `affiliation' "
					

					if `"`address'"' ~= "" file write `canvas' "\\ `address' " 
					
					file write `canvas' "}" _n
					
					if missing("`date'") file write `canvas' "\date{}"  _n(2)
				}
				
				if "`date'" == "date" {
					file write `canvas' 											///
					`"\date{`c(current_date)'}"'  _n(2)
				}
				
				if !missing("`title'") | !missing("`author'") | 					///
				!missing("`affiliation'") | !missing("`address'") 	{
					file write `canvas' `"\maketitle"' _n(5)
				}
				
				if `"`summary'"' ~= "" {
					file write  `canvas' `"\begin{abstract}"' _n		///
					`"`summary'"' _n 	///
					`"\end{abstract}"' _n(2)
				}
				
				if !missing("`toc'") {
					file write  `canvas' "\clearpage" _n		///
					"\tableofcontents" _n		///
					"\clearpage" _n(2)		
				}
			}
			
			
		} 											

		
		local path : pwd
		cap qui findfile "$htmldoc", path("`path'")
		
		local sep "`r(fn)'"
		if "`c(os)'" == "Windows" {
			local sep : subinstr local sep "/" "\", all
		}
			
		di as txt _n                                           					///
			"{hline}" _n                                        				///
		   `"      name:  {ul:{bf:{browse `"${weaverFullPath}"':$htmldoc}}} "' _n  	///
			"       log:  {bf:$weaverFullPath}"  _n                     					///
			"  log type:  {bf:$weaverMarkup}"  _n       									///
			"  software:  {bf:Weaver $weaverversion on Stata "   				///
			"`c(stata_version)'}" _n											///
			"  hardware:  {bf:`c(machine_type)' version `c(osdtl)'}"_n       	///
			" opened on:  {bf:`c(current_date)', `c(current_time)'}" _n(2)
		
		macro drop ErrorDetected					// log was created error-free
	}
	
	
end
