/*

							  Stata Weaver Package
					   
					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de

		
                   The Weaver Package comes with no warranty    	
				  
				  
	DESCRIPTION
	==============================
	
	This program is only executed by "weave.ado" program to add the CSS styles 
	to the Weaver document. This code is separated in a CSS file to encourage 
	other users add new document styles. If you are not familiar with CSS, read 
	the following cheat sheets:
	
	http://www.w3schools.com/cssref/css_selectors.asp
	http://www.w3schools.com/cssref/trysel.asp?selector=pluss
	
	CSS Documentation (recommended)
	http://www.w3.org/TR/CSS2/selector.html
	
*/

		
program define weaverstyle

    version 11
    syntax [anything] , [STYle(name)] [Font(str)] [LANDscape] [css(str)] 		///
	[markup(str)]
	
	tempname canvas 
	capture file open `canvas' using "$htmldoc" , write text append
			
	********************************************************************
	* Stata STYLE
	********************************************************************
	if "`style'" == "stata" &  "`markup'" == "html" {
		
		file write `canvas' _n(2) "<!-- Stata Style  -->" _n(2) 				///
		`"<style type="text/css">"' _n 											///
			"@page {" _n ///
				_skip(8) "size: auto;" _n ///
				_skip(8) "margin: 10mm 20px 15mm 20px;" _n ///
				_skip(8) "color:#828282;" _n ///
				_skip(8) "font-family: `font';" _n ///
				_skip(8) "}" _n(2) ///		
			"header {" _n ///
				_skip(8) "font-size:28px;" _n ///
				_skip(8) "padding-bottom:20px; " _n ///
				_skip(8) "margin:0px 0 20px 0;" _n ///
				_skip(8) "font-family: `font';" _n ///
				_skip(8) "}" _n(2) ///		
			"h1, h1 > a, h1 > a:link {" _n ///
				_skip(8) "margin:24px 0px 2px 0px;" _n ///
				_skip(8) "padding: 0;" _n ///
				_skip(8) "font-family: `font';" _n ///
				_skip(8) "font-size: 22px;" _n ///
				_skip(8) "}" _n(2) ///
			"h1 > a:hover, h1 > a:hover{" _n ///
				"color:#345A8A;" _n ///
				"} " _n(2) ///
			"h2, h2 > a, h2 > a, h2 > a:link {" _n ///
				_skip(8) "margin:14px 0px 2px 0px;" _n ///
				_skip(8) "padding: 0;" _n ///
				_skip(8) "font-family: `font';" _n ///
				_skip(8) "font-size: 18px;" _n ///
				_skip(8) "font-weight:bold;" _n ///
				_skip(8) "}" _n(2) ///	
			"h3, h3 > a,h3 > a, h3 > a:link,h3 > a:link {" _n ///
				_skip(8) "margin:14px 0px 0px 0px;" _n ///
				_skip(8) "padding: 0;" _n ///
				_skip(8) "font-family: `font';" _n ///
				_skip(8) "font-size: 16px;" _n ///
				_skip(8) "font-weight:bold;" _n ///
				_skip(8) "}" _n(2) ///
			"h4, .h4 {" _n ///
				_skip(8) "margin:10px 0px 0px 0px;" _n ///
				_skip(8) "padding: 0;" _n ///
				_skip(8) "font-family: `font';" _n ///
				_skip(8) "font-size: 16px;" _n ///
				_skip(8) "font-weight:bold;" _n ///
				_skip(8) "font-style:italic;" _n ///
				_skip(8) "}" _n(2) ///
			"h5, .h5 {" _n ///
				_skip(8) "font-family: `font';" _n ///
				_skip(8) "font-size: 14px;" _n ///
				_skip(8) "font-weight:normal;" _n ///
				_skip(8) "}" _n(2) ///				
			"h6, .h6 {"  _n ///
				_skip(8) "font-size:14px;" _n ///
				_skip(8) "font-family: `font';" _n 								///
				_skip(8) "font-weight:normal;" _n 								///
				_skip(8) "font-style:italic;" _n 								///
				_skip(8) "}" _n(2) 												///
			"p {" _n 															///
				_skip(8) "font-family: `font';" _n 								///
				_skip(8) "font-weight:normal;" _n 								///
				_skip(8) "font-size:14px;" _n 									///
				_skip(8) "line-height: 16px;" _n 								///
				_skip(8) "margin-bottom:16px;" _n 								///
				_skip(8) "}" _n(2) ///
			"code, p > .sh_stata, .sh_stata {" _n(2) ///
						_skip(8) "color: black;" _n ///
						_skip(8) "padding: 4px 4px 2px 5px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:12px;" _n ///
						///_skip(8) "font-weight:bold;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "background-color:#EAF2F3;" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "border:thin;" _n ///
						_skip(8) "border-color: #E1EBEE; " _n ///
						_skip(8) "border-style: solid;" _n ///
						_skip(8) "margin-top:10px;" _n ///
						_skip(8) "}" _n(2) ///
			".code, #code {" _n ///
						_skip(8) "color: black;" _n ///
						_skip(8) "margin: 15px 30px 15px 30px;" _n /// 
						_skip(8) "padding: 15px 15px 15px 15px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height:16px;" _n 						///
						_skip(8) "font-family: `font';" _n 						///
						_skip(8) "text-shadow:#FFF;" _n 						///
						_skip(8) "background-color:#EAF2F3;" _n 				///
						_skip(8) "font-family: `font';" _n 						///
						_skip(8) "text-shadow:#FFF;" _n 						///
						_skip(8) "border:thin;" _n 								///
						_skip(8) "border-color: #E1EBEE; " _n 					///
						_skip(8) "border-style: solid;" _n 						///
						_skip(8) "border-radius:10px;" _n 						///
						_skip(8) "}" _n(2) 										///
			"onlycode {" _n ///		
						_skip(8) "color: black;" _n ///
						_skip(8) "padding: 4px 4px 2px 5px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "margin-top:5px;" _n ///
						_skip(8) "border-radius:10" ///	
						_skip(8) "}" _n(2) ///
			"pre.output, pre > code {" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:thin; " _n ///
						_skip(8) "border-color: #E1EBEE; " _n ///
						_skip(8) "border-style: solid; " _n ///
						_skip(8) "padding:5px 0 10px 5px;" _n ///
						_skip(8) "border-top-style:none;" _n /// 
						_skip(8) "}" _n(2) ///
			"result {" _n 														///
				_skip(8) "display: block;" _n 									///
				_skip(8) "font-family:Courier New, Courier, monospace;" _n 		///
				_skip(8) "font-size:11px; " _n 									///
				_skip(8) "line-height: 11px;" _n 								///
				_skip(8) "}" _n(2) ///		
			".border, #border {" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:thin; " _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid; " _n ///
						_skip(8) "padding:5px 0 10px 5px;" _n ///
						_skip(8) "}" _n(2) ///	
			"resultbox {" _n ///
				_skip(8) "display: block;" _n ///
				_skip(8) "unicode-bidi: embed;" _n ///
				_skip(8) "white-space:pre;" _n ///
				_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
				_skip(8) "font-size:11px; " _n ///
				_skip(8) "line-height: 11px;" _n ///
				_skip(8) "margin-bottom:5px;" _n ///
				_skip(8) "border:thin; " _n ///
				_skip(8) "border-color: #EBEBEB; " _n ///
				_skip(8) "border-style: solid; " _n ///
				_skip(8) "padding:5px 0 10px 5px;" _n ///
				_skip(8) "}" _n(2) ///	
			/// Anything that appears after commands			
			"pre.sh_stata + * {" _n 											///
				_skip(8) "margin-top:14px;" _n 									/// 
				_skip(8) "}" _n(2) 												///
			/// Successive DIVE CODE (code block) 			
			"pre.sh_stata + pre.sh_stata {" _n 									///
				_skip(8) "margin-top:0px;" _n 									/// 
				_skip(8) "border-top: 0px;" _n 									/// 
				_skip(8) "}" _n(2) 												///	
			///  Code and Results 													
			"pre.sh_stata + pre.output {" _n 										///
				_skip(8) "margin-top:0px;" _n 									/// 
				_skip(8) "}" _n(2) 												///			
		"</style>" _n(4)
	}		

			
	********************************************************************
	*MODERN (DEFAULT) STYLE
	********************************************************************		
	
	if "`style'" == "modern" & "`markup'" == "html" {
		
				file write `canvas' _n(2) "<!-- Modern Style  -->" _n(2) 		///
				`"<style type="text/css">"' _n									///
				"@page {" _n 													///
					_skip(8) "size: auto;" _n 									///
					_skip(8) "margin: 10mm 20px 15mm 20px;" _n 					///
					_skip(8) "color:#828282;" _n 								///
					_skip(8) "font-family: `font';" _n 							///
					_skip(8) "}" _n(2) 											///		
				"header {" _n 													///
					_skip(8) "font-size:28px;" _n 								///
					_skip(8) "padding-bottom:20px; " _n 						///
					_skip(8) "margin:0px 0 20px 0;" _n 							///
					_skip(8) "font-family: `font';" _n 							///
					_skip(8) "}" _n(2) 											///		
				"h1, h1 > a, h1 > a:link {" _n 									///
					_skip(8) "margin:24px 0px 2px 0px;" _n 						///
					_skip(8) "padding: 0;" _n 									///
					_skip(8) "font-family: `font';" _n 							///
					_skip(8) "color:#17365D;" _n 								///
					_skip(8) "font-size: 22px;" _n 								///
					_skip(8) "}" _n(2) 											///
				"h1 > a:hover, h1 > a:hover{" _n 								///
					"color:#345A8A;" _n 										///
					"} " _n(2) 													///
				"h2, h2 > a, h2 > a, h2 > a:link {" _n 							///
					_skip(8) "margin:14px 0px 5px 0px;" _n 						///
					_skip(8) "padding: 0;" _n 									///
					_skip(8) "font-family: `font';" _n 							///
					_skip(8) "color:#345A8A;" _n 								///
					_skip(8) "font-size: 18px;" _n 								///
					_skip(8) "font-weight:bold;" _n 							///
					_skip(8) "}" _n(2) 											///	
				"h3, h3 > a,h3 > a, h3 > a:link,h3 > a:link {" _n 				///
					_skip(8) "margin:14px 0px 0px 0px;" _n 						///
					_skip(8) "padding: 0;" _n 									///
					_skip(8) "font-family: `font';" _n 							///
					_skip(8) "color:#4F81BD;" _n 								///
					_skip(8) "font-size: 14px;" _n 								///
					_skip(8) "font-weight:bold;" _n 							///
					_skip(8) "}" _n(2) 											///
				"h4, .h4 {" _n 													///
					_skip(8) "margin:10px 0px 0px 0px;" _n 						///
					_skip(8) "padding: 0;" _n 									///
					_skip(8) "font-family: `font';" _n 							///
					_skip(8) "font-size: 14px;" _n 								///
					_skip(8) "color:#4F81BD;" _n 								///
					_skip(8) "font-weight:bold;" _n 							///
					_skip(8) "font-style:italic;" _n 							///
					_skip(8) "}" _n(2) 											///
				"h5, .h5 {" _n 													///
					_skip(8) "font-family: `font';" _n 							///
					_skip(8) "font-size: 14px;" _n 								///
					_skip(8) "font-weight:normal;" _n 							///
					_skip(8) "color:#4F81BD;" _n 								///
					_skip(8) "}" _n(2) 											///				
				"h6, .h6 {"  _n 												///
					_skip(8) "font-size:14px;" _n 								///
					_skip(8) "font-family: `font';" _n 							///
					_skip(8) "font-weight:normal;" _n 							///
					_skip(8) "font-style:italic;" _n 							///
					_skip(8) "color:#4F81BD;" _n 								///
					_skip(8) "}" _n(2) 											///
				"p {" _n ///
					_skip(8) "font-family: `font';" _n 							///
					_skip(8) "font-weight:normal;" _n 							///
					_skip(8) "font-size:14px;" _n 								///
					_skip(8) "line-height: 16px;" _n 							///
					_skip(8) "margin-bottom:10px;" _n 							///
					_skip(8) "}" _n(2) 											///
				///"code, p > code {" _n 										///
				"code, p > .sh_stata, .sh_stata {" _n(2) 						///
					_skip(8) "color: black;" _n 								///
					_skip(8) "padding: 4px 4px 2px 5px;" _n 					/// 
					_skip(8) "display:block;" _n 								///
					_skip(8) "font-size:14px;" _n 								///
					_skip(8) "line-height:16px;" _n 							///
					_skip(8) "background-color:#E1E6F0;" _n 					///
					_skip(8) "font-family:Courier New, Courier, monospace;" _n  ///
					_skip(8) "text-shadow:#FFF;" _n 							///
					_skip(8) "border:thin;" _n 									///
					_skip(8) "border-color: #345A8A; " _n 						///
					_skip(8) "border-style: solid;" _n 							///
					_skip(8) "margin-top:5px;" _n 								///
					_skip(8) "}" _n(2) 											///
				".code, #code {" _n 											///
					_skip(8) "color: black;" _n 								///
					_skip(8) "margin: 15px 30px 15px 30px;" _n 					/// 
					_skip(8) "padding: 15px 15px 15px 15px;" _n 				/// 
					_skip(8) "display:block;" _n 								///
					_skip(8) "font-size:14px;" _n 								///
					_skip(8) "line-height:16px;" _n 							///
					_skip(8) "background-color:#E1E6F0;" _n 					///
					_skip(8) "font-family: `font';" _n 							///
					_skip(8) "text-shadow:#FFF;" _n 							///
					_skip(8) "border:thin;" _n 									///
					_skip(8) "border-color: #345A8A; " _n 						///
					_skip(8) "border-style: solid;" _n 							///
					_skip(8) "}" _n(2) 											///	
				"onlycode {" _n 												///		
					_skip(8) "color: black;" _n 								///
					_skip(8) "padding: 4px 4px 2px 5px;" _n 					/// 
					_skip(8) "display:block;" _n 								///
					_skip(8) "font-size:14px;" _n 								///
					_skip(8) "line-height:16px;" _n 							///
					_skip(8) "background-color:#DDD;" _n	 					///
					_skip(8) "font-family:Courier New, Courier, monospace;" _n  ///
					_skip(8) "text-shadow:#FFF;" _n 							///
					_skip(8) "margin-top:5px;" _n 								///
					_skip(8) "}" _n(2) 											///
				"pre.output, pre > code {" _n 										///
					_skip(8) "margin-bottom:5px;" _n 							///
					_skip(8) "border:thin; " _n 								///
					_skip(8) "border-color: #345A8A; " _n 						///
					_skip(8) "border-style: solid; " _n 						///
					_skip(8) "padding:5px 0 10px 5px;" _n 						///
					_skip(8) "border-top-style:none;" _n 						/// 
					_skip(8) "}" _n(2) 											///
				"result {" _n 													///
					_skip(8) "display: block;" _n 								///
					_skip(8) "font-family:Courier New, Courier, monospace;" _n  ///
					_skip(8) "font-size:11px; " _n 								///
					_skip(8) "line-height: 11px;" _n 							///
					_skip(8) "}" _n(2) 											///		
				".border, #border {" _n 										///
					_skip(8) "margin-bottom:5px;" _n 							///
					_skip(8) "border:thin; " _n 								///
					_skip(8) "border-color: #EBEBEB; " _n 						///
					_skip(8) "border-style: solid; " _n 						///
					_skip(8) "padding:5px 0 10px 5px;" _n 						///
					_skip(8) "}" _n(2) 											///	
				"resultbox {" _n 												///
					_skip(8) "display: block;" _n 								///
					_skip(8) "unicode-bidi: embed;" _n 							///
					_skip(8) "white-space:pre;" _n 								///
					_skip(8) "font-family:Courier New, Courier, monospace;" _n  ///
					_skip(8) "font-size:11px; " _n 								///
					_skip(8) "line-height: 11px;" _n 							///
					_skip(8) "margin-bottom:5px;" _n 							///
					_skip(8) "border:thin; " _n 								///
					_skip(8) "border-color: #EBEBEB; " _n 						///
					_skip(8) "border-style: solid; " _n 						///
					_skip(8) "padding:5px 0 10px 5px;" _n 						///
					_skip(8) "}" _n(2) 											///		
				"</style>" _n(4)
			}		
		
			
		
		
		
		
		
			********************************************************************
			* CLASSIC STYLE
			********************************************************************
			if "`style'" == "classic" & "`markup'" == "html" {
		
				file write `canvas' _n(2) "<!-- CLASSIC Style  -->" _n(2) ///
				`"<style type="text/css">"' _n ///
				"@page {" _n ///
						_skip(8) "size: auto;" _n ///
						_skip(8) "margin: 10mm 20px 15mm 20px;" _n ///
						_skip(8) "color:#828282;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "}" _n(2) ///		
				"header {" _n ///
						_skip(8) "font-size:28px;" _n ///
						_skip(8) "padding-bottom:20px; " _n ///
						_skip(8) "margin:0px 0 20px 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "}" _n(2) ///		
				"h1, h1 > a, h1 > a:link {" _n ///
						_skip(8) "margin:24px 0px 2px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 22px;" _n ///
						_skip(8) "}" _n(2) ///
				"h1 > a:hover, h1 > a:hover{" _n ///
						"color:#345A8A;" _n ///
						"} " _n(2) ///
				"h2, h2 > a, h2 > a, h2 > a:link {" _n ///
						_skip(8) "margin:14px 0px 2px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 18px;" _n ///
						_skip(8) "font-weight:bold;" _n ///
						_skip(8) "}" _n(2) ///	
				"h3, h3 > a,h3 > a, h3 > a:link,h3 > a:link {" _n ///
						_skip(8) "margin:14px 0px 0px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 14px;" _n ///
						_skip(8) "font-weight:bold;" _n ///
						_skip(8) "}" _n(2) ///
				"h4, .h4 {" _n ///
						_skip(8) "margin:10px 0px 0px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 14px;" _n ///
						_skip(8) "font-weight:bold;" _n ///
						_skip(8) "font-style:italic;" _n ///
						_skip(8) "}" _n(2) ///
				"h5, .h5 {" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 14px;" _n ///
						_skip(8) "font-weight:normal;" _n ///
						_skip(8) "}" _n(2) ///				
				"h6, .h6 {"  _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-weight:normal;" _n ///
						_skip(8) "font-style:italic;" _n ///
						_skip(8) "}" _n(2) ///
				"p {" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-weight:normal;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height: 16px;" _n ///
						_skip(8) "margin-bottom:10px;" _n ///
						_skip(8) "}" _n(2) ///
				///"code, p > code {" _n ///
				"code, p > .sh_stata, .sh_stata {" _n(2) ///
						_skip(8) "color: black;" _n ///
						_skip(8) "padding: 4px 4px 2px 5px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "background-color:#EBEBEB;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "border:thin;" _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid;" _n ///
						_skip(8) "margin-top:5px;" _n ///
						_skip(8) "}" _n(2) ///
				".code, #code {" _n ///
						_skip(8) "color: black;" _n ///
						_skip(8) "margin: 15px 30px 15px 30px;" _n /// 
						_skip(8) "padding: 15px 15px 15px 15px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "background-color:#EBEBEB;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "border:thin;" _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid;" _n ///
						_skip(8) "}" _n(2) ///
				"onlycode {" _n ///		
						_skip(8) "color: black;" _n ///
						_skip(8) "padding: 4px 4px 2px 5px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "background-color:#DDD;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "margin-top:5px;" _n ///
						/*_skip(8) "border-radius:10"  
				*/		_skip(8) "}" _n(2) ///
				"pre.output, pre > code {" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:thin; " _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid; " _n ///
						_skip(8) "padding:5px 0 10px 5px;" _n ///
						_skip(8) "border-top-style:none;" _n /// 
						_skip(8) "}" _n(2) ///
				"result {" _n ///
						_skip(8) "display: block;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "font-size:11px; " _n ///
						_skip(8) "line-height: 11px;" _n ///
						_skip(8) "}" _n(2) ///		
				".border, #border {" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:thin; " _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid; " _n ///
						_skip(8) "padding:5px 0 10px 5px;" _n ///
						_skip(8) "}" _n(2) ///	
				"resultbox {" _n ///
						_skip(8) "display: block;" _n ///
						_skip(8) "unicode-bidi: embed;" _n ///
						_skip(8) "white-space:pre;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "font-size:11px; " _n ///
						_skip(8) "line-height: 11px;" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:thin; " _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid; " _n ///
						_skip(8) "padding:5px 0 10px 5px;" _n ///
						_skip(8) "}" _n(2) ///		
				"</style>" _n(4)
			}		
	
	
	
	
	
	
			********************************************************************
			* MINIMAL STYLE
			********************************************************************
			if "`style'" == "minimal" & "`markup'" == "html" {
		
				file write `canvas' _n(2) "<!-- Minimal Style  -->" _n(2) ///
				`"<style type="text/css">"' _n ///
				"@page {" _n ///
						_skip(8) "size: auto;" _n ///
						_skip(8) "margin: 10mm 20px 15mm 20px;" _n ///
						_skip(8) "color:#828282;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "}" _n(2) ///		
				"header {" _n ///
						_skip(8) "font-size:28px;" _n ///
						_skip(8) "padding-bottom:20px; " _n ///
						_skip(8) "margin:0px 0 20px 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "}" _n(2) ///		
				"h1, h1 > a, h1 > a:link {" _n ///
						_skip(8) "margin:24px 0px 2px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 22px;" _n ///
						_skip(8) "}" _n(2) ///
				"h1 > a:hover, h1 > a:hover{" _n ///
						"color:#345A8A;" _n ///
						"} " _n(2) ///
				"h2, h2 > a, h2 > a, h2 > a:link {" _n ///
						_skip(8) "margin:14px 0px 2px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 18px;" _n ///
						_skip(8) "font-weight:bold;" _n ///
						_skip(8) "}" _n(2) ///	
				"h3, h3 > a,h3 > a, h3 > a:link,h3 > a:link {" _n ///
						_skip(8) "margin:14px 0px 0px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 16px;" _n ///
						_skip(8) "font-weight:bold;" _n ///
						_skip(8) "}" _n(2) ///
				"h4, .h4 {" _n ///
						_skip(8) "margin:10px 0px 0px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 16px;" _n ///
						_skip(8) "font-weight:bold;" _n ///
						_skip(8) "font-style:italic;" _n ///
						_skip(8) "}" _n(2) ///
				"h5, .h5 {" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 14px;" _n ///
						_skip(8) "font-weight:normal;" _n ///
						_skip(8) "}" _n(2) ///				
				"h6, .h6 {"  _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-weight:normal;" _n ///
						_skip(8) "font-style:italic;" _n ///
						_skip(8) "}" _n(2) ///
				"p {" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-weight:normal;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height: 16px;" _n ///
						_skip(8) "margin-bottom:10px;" _n ///
						_skip(8) "}" _n(2) ///
				///"code, p > code {" _n ///
				"code, p > .sh_stata, .sh_stata {" _n(2) ///
						_skip(8) "color: black;" _n ///
						_skip(8) "padding: 4px 4px 0px 5px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:12px;" _n ///
						_skip(8) "font-weight:bold;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						/// _skip(8) "border:thin;" _n ///
						/// _skip(8) "background-color:#EBEBEB;" _n ///
						///_skip(8) "border-style: dotted;" _n ///
						_skip(8) "margin-top:10px;" _n ///
						///_skip(8) "border-radius:10px" ///
						_skip(8) "}" _n(2) ///
				".code, #code {" _n ///
						_skip(8) "color: black;" _n ///
						_skip(8) "margin: 15px 30px 15px 30px;" _n /// 
						_skip(8) "padding: 15px 15px 15px 15px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "background-color:#EBEBEB;" _n ///
						_skip(8) "border:thin;" _n ///
						_skip(8) "border-color: #828282; " _n ///
						_skip(8) "border-style: dotted;" _n ///
						_skip(8) "}" _n(2) ///	
				"onlycode {" _n ///		
						_skip(8) "color: black;" _n ///
						_skip(8) "padding: 4px 4px 2px 5px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "margin-top:5px;" _n ///
						_skip(8) "border-radius:10" ///	
						_skip(8) "}" _n(2) ///
				"pre.output, pre > code {" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:none;" _n /// 
						_skip(8) "}" _n(2) ///
				"result {" _n ///
						_skip(8) "display: block;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "font-size:11px; " _n ///
						_skip(8) "line-height: 11px;" _n ///
						_skip(8) "}" _n(2) ///		
				".border, #border {" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:thin; " _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid; " _n ///
						_skip(8) "padding:5px 0 10px 5px;" _n ///
						_skip(8) "}" _n(2) ///	
				"resultbox {" _n ///
						_skip(8) "display: block;" _n ///
						_skip(8) "unicode-bidi: embed;" _n ///
						_skip(8) "white-space:pre;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "font-size:11px; " _n ///
						_skip(8) "line-height: 11px;" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:thin; " _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid; " _n ///
						_skip(8) "padding:5px 0 10px 5px;" _n ///
						_skip(8) "}" _n(2) ///		
				"</style>" _n(4)
			}		





			********************************************************************
			* ELEGANT STYLE
			********************************************************************
			if "`style'" == "elegant" & "`markup'" == "html" {
		
				file write `canvas' _n(2) "<!-- ELEGANT Style  -->" _n(2) ///
				`"<style type="text/css">"' _n ///
				"@page {" _n ///
						_skip(8) "size: auto;" _n ///
						_skip(8) "margin: 10mm 20px 15mm 20px;" _n ///
						_skip(8) "color:#828282;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "}" _n(2) ///		
				"header {" _n ///
						_skip(8) "font-size:28px;" _n ///
						_skip(8) "padding-bottom:20px; " _n ///
						_skip(8) "margin:0px 0 20px 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "}" _n(2) ///		
				"h1, h1 > a, h1 > a:link {" _n ///
						_skip(8) "margin:24px 0px 2px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 22px;" _n ///
						_skip(8) "}" _n(2) ///
				"h1 > a:hover, h1 > a:hover{" _n ///
						"color:#345A8A;" _n ///
						"} " _n(2) ///
				"h2, h2 > a, h2 > a, h2 > a:link {" _n ///
						_skip(8) "margin:14px 0px 2px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 18px;" _n ///
						_skip(8) "font-weight:bold;" _n ///
						_skip(8) "}" _n(2) ///	
				"h3, h3 > a,h3 > a, h3 > a:link,h3 > a:link {" _n ///
						_skip(8) "margin:14px 0px 0px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 16px;" _n ///
						_skip(8) "font-weight:bold;" _n ///
						_skip(8) "}" _n(2) ///
				"h4, .h4 {" _n ///
						_skip(8) "margin:10px 0px 0px 0px;" _n ///
						_skip(8) "padding: 0;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 16px;" _n ///
						_skip(8) "font-weight:bold;" _n ///
						_skip(8) "font-style:italic;" _n ///
						_skip(8) "}" _n(2) ///
				"h5, .h5 {" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-size: 14px;" _n ///
						_skip(8) "font-weight:normal;" _n ///
						_skip(8) "}" _n(2) ///				
				"h6, .h6 {"  _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-weight:normal;" _n ///
						_skip(8) "font-style:italic;" _n ///
						_skip(8) "}" _n(2) ///
				"p {" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "font-weight:normal;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height: 16px;" _n ///
						_skip(8) "margin-bottom:10px;" _n ///
						_skip(8) "}" _n(2) ///
				///"code, p > code {" _n ///
				"code, p > .sh_stata, .sh_stata {" _n(2) ///
						_skip(8) "color: black;" _n ///
						_skip(8) "padding: 4px 4px 2px 5px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:12px;" _n ///
						///_skip(8) "font-weight:bold;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "background-color:#EBEBEB;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "border:thin;" _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid;" _n ///
						_skip(8) "margin:10px 0 5px 0;" _n ///
						_skip(8) "border-radius:10px;" _n ///
						_skip(8) "}" _n(2) ///
				".code, #code {" _n ///
						_skip(8) "color: black;" _n ///
						_skip(8) "margin: 15px 30px 15px 30px;" _n /// 
						_skip(8) "padding: 15px 15px 15px 15px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "background-color:#EBEBEB;" _n ///
						_skip(8) "font-family: `font';" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "border:thin;" _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid;" _n ///
						_skip(8) "border-radius:10px;" _n ///
						_skip(8) "}" _n(2) ///	
				"onlycode {" _n ///		
						_skip(8) "color: black;" _n ///
						_skip(8) "padding: 4px 4px 2px 5px;" _n /// 
						_skip(8) "display:block;" _n ///
						_skip(8) "font-size:14px;" _n ///
						_skip(8) "line-height:16px;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "text-shadow:#FFF;" _n ///
						_skip(8) "margin-top:5px;" _n ///
						_skip(8) "border-radius:10" ///	
						_skip(8) "}" _n(2) ///
				"pre.output, pre > code {" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:thin; " _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-bottom-style: solid; " _n ///
						_skip(8) "padding:5px 0 10px 5px;" _n ///
						_skip(8) "border-top-style:none;" _n /// 
						_skip(8) "}" _n(2) ///
				"result {" _n ///
						_skip(8) "display: block;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "font-size:11px; " _n ///
						_skip(8) "line-height: 11px;" _n ///
						_skip(8) "}" _n(2) ///		
				".border, #border {" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:thin; " _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid; " _n ///
						_skip(8) "padding:5px 0 10px 5px;" _n ///
						_skip(8) "}" _n(2) ///	
				"resultbox {" _n ///
						_skip(8) "display: block;" _n ///
						_skip(8) "unicode-bidi: embed;" _n ///
						_skip(8) "white-space:pre;" _n ///
						_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
						_skip(8) "font-size:11px; " _n ///
						_skip(8) "line-height: 11px;" _n ///
						_skip(8) "margin-bottom:5px;" _n ///
						_skip(8) "border:thin; " _n ///
						_skip(8) "border-color: #EBEBEB; " _n ///
						_skip(8) "border-style: solid; " _n ///
						_skip(8) "padding:5px 0 10px 5px;" _n ///
						_skip(8) "}" _n(2) ///		
				"</style>" _n(4)
			}		

			********************************************************************
			* CSS STYLING
			********************************************************************
		if "`style'" != "empty" & "`markup'" == "html" {
			file write `canvas'  _n(2) ///
			"<!-- General Style  -->" _n(2) ///
			`"<style type="text/css">"' _n ///
			"body {" _n(2) ///
					_skip(8) "min-height:900px;" _n
		
			
			file write `canvas'  ///
					_skip(8) "font-family: `font';" _n ///
					_skip(8) "}" _n(2) ///
			"@page {" _n ///
					_skip(8) "size: auto;" _n ///
					_skip(8) "margin: 10mm 20px 15mm 20px;" _n ///
					_skip(8) "color:#828282;" _n ///
					_skip(8) "font-family: `font';" _n ///
					`" @top-left "' ///
					`"{  : "`runhead'" ; font-size:11px; margin-top:5px; } "' _n /// 
					"@bottom {" _n ///
					_skip(8) `"content: "Page " counter(page); font-size:14px; "' _n ///
					_skip(8) "}" _n ///
					_skip(8) "}" _n(2) ///		
			"@page:first {" _n ///
					"@top-left {" _n ///
					_skip(8) "content: normal" _n ///
					_skip(8) "}" _n ///
					"@bottom {" _n ///
					_skip(8) "content: normal" _n ///
					_skip(8) "}" _n ///
					_skip(8) "}" _n(2) ///		
			"header {" _n ///
					_skip(8) "margin-top:0;" _n ///
					_skip(8) "padding-top:200px; " _n ///
					_skip(8) "background-color:white; " _n ///
					_skip(8) "text-align:center;" _n ///
					_skip(8) "display:block;" _n ///
					_skip(8) "}" _n(2) ///
			"h1, h1 > a, h1 > a:link {" _n ///
					_skip(8) "text-align: left;" _n ///
					_skip(8) "}" _n(2) ///	
			"h2, h2 > a, h2 > a, h2 > a:link {" _n ///
					_skip(8) "text-align: left;" _n ///
					_skip(8) "}" _n(2) ///	
			"h3, h3 > a,h3 > a, h3 > a:link,h3 > a:link {" _n ///
					_skip(8) "text-align: left;" _n ///
					_skip(8) "}" _n(2) ///
			"h4, .h4 {" _n ///
					_skip(8) "text-align: left;" _n ///
					_skip(8) "}" _n(2) ///
			"h5, .h5 {" _n ///
					_skip(8) "text-align: left;" _n ///
					_skip(8) "}" _n(2) ///		
			"h6 {"  _n ///
					_skip(8) "text-align:center;" _n ///
					_skip(8) "}" _n(2) ///	
			"p {" _n ///
					_skip(8) `"font-family:`font';"' _n  _n ///
					///_skip(8) "margin:0;" _n _n ///
					_skip(8) "display: block;" _n ///
					_skip(8) "line-height:16px;" _n ///
					_skip(8) "font-size:14px;" _n  ///
					_skip(8) "text-align:justify;" _n  ///
					_skip(8) "text-justify:inter-word;" _n ///
					_skip(8) "}" _n(2) ///
			"ul {"	_skip(8) "list-style:circle;" _n ///
					_skip(8) "margin-top:14px;" _n ///
					_skip(8) "margin-bottom:0;" _n ///
					_skip(8) "line-height:14px;" _n ///
					_skip(8) "font-size:14px;" _n ///
					_skip(8) "}" _n(2) /// 
			"li {"	_skip(8) "margin-top:2px;" _n ///
					_skip(8) "}" _n(2) /// 		
			"div ul a {" _n ///
					_skip(8) "color:black;" _n ///
					_skip(8) "text-decoration:none;" _n ///
					_skip(8) "}" _n(2) ///
			"div ul {" _n ///
					_skip(8) "list-style: none;" _n ///
					_skip(8) "margin: 0px 0 10px -15px;" _n ///
					_skip(8) "padding-left:15px;" _n ///
					_skip(8) "}" _n(2) /// 
			"div ul li {" _n ///
					_skip(8) "font-weight:bold;" _n ///
					_skip(8) "margin-top:20px;" _n ///
					_skip(8) "}" _n(2) ///	
			"div ul li ul li {" _n ///
					_skip(8) "font-weight: normal;" _n ///
					_skip(8) "margin-left:20px;" _n ///
					_skip(8) "margin-top:5px;" _n ///
					_skip(8) "}" _n(2) ///
			"div ul li ul li ul li {" _n ///
					_skip(8) "font-weight: normal;" _n ///
					_skip(8) "font-style:none;" _n ///
					_skip(8) "margin-top:5px;" _n ///
					_skip(8) "}" _n(2) ///
			"div ul li ul li ul li ul li {" _n ///
					_skip(8) "font-weight: normal;" _n ///
					_skip(8) "font-style:italic;" _n ///
					_skip(8) "margin-top:5px;" _n ///
					_skip(8) "}" _n(2) ///	
			"img {" _n ///
					_skip(8) "margin: 5px 0 5px 0;" _n ///
					_skip(8) "padding: 0px;" _n ///
					_skip(8) "cursor:-webkit-zoom-in;" _n ///
					_skip(8) "cursor:-moz-zoom-in;" _n ///
					_skip(8) "display:inline-block;" _n ///
					_skip(8) "text-align: left;" _n ///
					_skip(8) "clear: both;" _n ///
					_skip(8) "-webkit-box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );" _n ///
					_skip(8) "-moz-box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );" _n ///
					_skip(8) "box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );" _n ///
					_skip(8) "}" _n(2) ///							
			"h1,h2,h3,h4,h5,h6		{" _n ///
					_skip(8) `"font-family:`font';"' _n   /// 
					_skip(8) `"text-align: left;"' _n    ///
					_skip(8) "}" _n(2) ///
			"pre {" _n ///
					_skip(8) "padding:0;" _n  /// 
					_skip(8) "margin: 0;" _n    ///
					_skip(8) "white-space:normal;" _n ///
					_skip(8) "background: white;" _n ///
					_skip(8) "min-width:500px;" _n ///
					_skip(8) "}" _n(2) ///
			"p > code {" _n ///
					_skip(8) "display:block;" _n /// 
					_skip(8) "margin:10px 0 0 0;" _n   ///
					_skip(8) "line-height:14px;" _n   ///
					_skip(8) "font-size:14px;" _n   ///
					_skip(8) "font-weight:normal;" _n  ///
					_skip(8) "}" _n(2) ///
			"pre.output {" _n ///
					_skip(8) "display:block;" _n /// 
					_skip(8) "unicode-bidi: embed;" _n ///
					_skip(8) "margin:0 0 14px 0;" _n  ///
					_skip(8) "line-height:11px;" _n  ///
					_skip(8) "font-size:11px;" _n  ///
					_skip(8) "font-weight:normal;" _n ///
					_skip(8) "border-top:hidden;" _n ///
					_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
					_skip(8) "background-color:transparent;" _n ///
					_skip(8) "white-space:pre;" _n ///
					_skip(8) "}" _n(2) ///		
			"pre > code {" _n ///
					_skip(8) "display:block;" _n /// 
					_skip(8) "unicode-bidi: embed;" _n ///
					_skip(8) "margin:0 0 14px 0;" _n  ///
					_skip(8) "padding:8px 0px 0 0px;" _n  ///
					_skip(8) "line-height:12px;" _n  ///
					_skip(8) "font-size:12px;" _n  ///
					_skip(8) "font-weight:normal;" _n ///
					_skip(8) "border-top:hidden;" _n ///
					_skip(8) "font-family:Courier New, Courier, monospace;" _n ///
					_skip(8) "background-color:transparent;" _n ///
					_skip(8) "white-space:pre;" _n ///
					_skip(8) "}" _n(2) ///		
			"pre.output:empty, pre > code:empty  {" _n ///
					_skip(8) "display: none;" _n(2) ///
					_skip(8) "}" _n(2) ///	
			"code:empty, p > code:empty  {" _n ///
					_skip(8) "display: none;" _n(2) ///
					_skip(8) "}" _n(2) ///			
			"result {" _n ///
					_skip(8) "display: block;" _n ///
					_skip(8) "unicode-bidi: embed;" _n ///
					_skip(8) "white-space:pre;" _n ///
					_skip(8) "}" _n(2) ///			
			"point {" _n ///
					_skip(8) "font-size:160%;" _n ///
					_skip(8) "line-height:14px;" _n ///
					_skip(8) "color:#FFC500;" _n ///
					_skip(8) "vertical-align:-15%" _n ///
					_skip(8) "}" _n(2) ///		
			".center, #center {" _n ///
					_skip(8) "display: block;" _n ///
					_skip(8) "margin-left: auto;" _n ///
					_skip(8) "margin-right: auto;" _n ///
					_skip(8) "-webkit-box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );" _n ///
					_skip(8) "-moz-box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );" _n ///
					_skip(8) "box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );" _n(2) ///
					_skip(8) "padding: 0px;" _n ///
					_skip(8) "border-width: 0px;" _n ///
					_skip(8) "border-style: solid;" _n ///
					_skip(8) "cursor:-webkit-zoom-in;" _n ///
					_skip(8) "cursor:-moz-zoom-in;" _n ///
					_skip(8) "}" _n(2) ///
			".right, #right {" _n ///
					_skip(8) "display: block;" _n ///
					_skip(8) "margin-right: 5px;" _n ///	
					_skip(8) "-webkit-box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );" _n ///
					_skip(8) "-moz-box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );" _n ///
					_skip(8) "box-shadow: 0px 0px 2px rgba( 0, 0, 0, 0.5 );" _n(2) ///
					_skip(8) "padding: 0px;" _n ///
					_skip(8) "border-width: 0px;" _n ///
					_skip(8) "border-style: solid;" _n ///
					_skip(8) "cursor:-webkit-zoom-in;" _n ///
					_skip(8) "cursor:-moz-zoom-in;" _n ///
					_skip(8) "}" _n(2) ///				
			"empty {" _n ///
					_skip(8) "display:none;" _n ///
					_skip(8) "}" _n(2) ///			
			"pagebreak {" _n ///
					_skip(8) "page-break-before: always;" _n ///
					_skip(8) "}" _n(2) ///
			".pagebreak, #pagebreak {" _n ///
					_skip(8) "page-break-before: always;" _n ///
					_skip(8) "}" _n(2) ///
			".blue, #blue {" _n ///
					_skip(8) "color:#00F;" _n ///
					_skip(8) "}" _n(2) ///		
			".pink, #pink {" _n ///
					_skip(8) "color:#FF0080;" _n ///
					_skip(8) "}" _n(2) ///	
			".purple, #purple {" _n ///
					_skip(8) "color:#8000FF;" _n ///
					_skip(8) "}" _n(2) ///		
			".green, #green {" _n ///
					_skip(8) "color:#408000;" _n ///
					_skip(8) "}" _n(2) ///
			".orange, #orange {" _n ///
					_skip(8) "color:#FF8000;" _n ///
					_skip(8) "}" _n(2) ///
			".red, #red {" _n ///
					_skip(8) "color:#F00;" _n ///
					_skip(8) "}" _n(2) ///
			".bkblue, #bkblue {" _n ///
					_skip(8) "background-color:#ABC5F6;" _n ///
					_skip(8) "}" _n(2) ///
			".bkyellow, #bkyellow {" _n ///
					_skip(8) "background-color:#FAE768;" _n ///
					_skip(8) "}" _n(2) ///
			".bkgreen, #bkgreen {" _n ///
					_skip(8) "background-color:#CBEF66;" _n ///
					_skip(8) "}" _n(2) ///
			".bkpink, #bkpink {" _n ///
					_skip(8) "background-color:#F1A8D0;" _n ///
					_skip(8) "}" _n(2) ///		
			".bkpurple, #bkpurple {" _n ///
					_skip(8) "background-color:#D6ABEF;" _n ///
					_skip(8) "}" _n(2) ///	
			".bkgray, #bkgray {" _n ///
					_skip(8) "background-color:#D6D6D6;" _n ///
					_skip(8) "}" _n(4) ///		
							///
			"/* ---- This is Smooth Zoom CSS ---- */" _n /// 
			"#lightwrap {" _n ///
					_skip(8) "position:fixed;" _n ///
					_skip(8) "top:0;" _n ///
					_skip(8) "left:0;" _n ///
					_skip(8) "width:100%;" _n ///
					_skip(8) "height:100%;" _n ///
					_skip(8) "text-align:center;" _n ///
					_skip(8) "cursor:-webkit-zoom-out;" _n ///
					_skip(8) "cursor:-moz-zoom-out;" _n ///
					_skip(8) "z-index:999;" _n ///
					_skip(8) "}" _n(2) ///
			/// /* overlay covering website */
			"#lightbg {" _n ///
					_skip(8) "position:fixed;" _n ///
					_skip(8) "display:none;" _n ///
					_skip(8) "top:0;" _n ///
					_skip(8) "left:0;" _n ///
					_skip(8) "width:100%;" _n ///
					_skip(8) "height:100%;" _n ///
					_skip(8) "background:rgba(255, 255, 255, .9);}" _n(2) ///
			"#lightwrap img {" _n ///
					_skip(8) "position:absolute;" _n ///
					_skip(8) "display:none;" _n ///
					_skip(8) "cursor:-webkit-zoom-out;cursor:-moz-zoom-out;" _n ///
					_skip(8) "}" _n(2) ///
			"#lightzoomed {" _n ///
					_skip(8) "opacity:0;" _n ///
					_skip(8) "}" _n(2) ///
			"#off-screen {" _n ///
					_skip(8) "position: fixed;" _n ///
					_skip(8) "right:100%;" _n ///
					_skip(8) "opacity: 0;" _n ///
					_skip(8) "}" _n(2) ///
			"p + p {" _n 														///
					_skip(8) "margin-bottom:14px;" _n 							///
					_skip(8) "}" _n(2) 											///
			".math {" _n 														///
					_skip(8) "text-align:center;" _n 							///
					_skip(8) "display:block;" _n 								///
					_skip(8) "margin-top: 14px;" _n 							///
					_skip(8) "margin-bottom: 14px;" _n 							///
					_skip(8) "}" _n(2) 											///
			".mono {" _n 														///
					_skip(8) "font-family:Courier, Courier New, monospace;" _n 	///
					_skip(8) "color: #606060;" _n 								///
					_skip(8) "}" _n(2) 											///	
			".tble {" _n 														///
					_skip(8) "display:block;" _n 								///
					_skip(8) "margin-top: 10px;" _n 							///
					_skip(8) "margin-bottom: 0px;" _n 							///
					_skip(8) "font-size: 12px;" _n 								///
					_skip(8) "margin-bottom: 0px;" _n 							///
					_skip(8) "}" _n(2) 											///	
			".tblecenter {" _n 													///
					_skip(8) "display:block;" _n 								///
					_skip(8) "margin-top: 10px;" _n 							///
					_skip(8) "margin-bottom: 0px;" _n 							///
					_skip(8) "font-size: 12px;" _n 								///
					_skip(8) "margin-bottom: 0px;" _n 							///
					_skip(8) "text-align:center;" _n 							///
					_skip(8) "}" _n(2) 											///	
			"span.tblecenter + table, span.tble + table, span.tble + img {" _n  ///
					_skip(8) "margin-top: 2px;" _n 								///
					_skip(8) "}" _n(2) 											///		
			"</style>" _n(4)
		
        
        
        
        
        
        
        

 
			********************************************************************
			* LANDSCAPE MODE STYLING
			********************************************************************	
			if `"`landscape'"' == "landscape" {
				file write `canvas' `"<style type="text/css">"' _n 				///
				"@page {" _n 													///
					_skip(8) "size: A4 landscape" _n 							/// 
					_skip(8) "}" _n(2) 											///
					"</style>" _n(4)
			}	
			else {
				file write `canvas' `"<style type="text/css">"' _n 				///
				"@page {" _n 													///
					_skip(8) "size: A4 " _n 									/// 
					_skip(8) "}" _n(2) 											///
					"</style>" _n(4)
			}			
			
				file write `canvas' `"<style type="text/css">"' _n 				///
				".author {display:block;text-align:center;" 					///
				"font-size:16px;margin-bottom:3px;}" _n 						///
				"</style>" _n(4)	

			********************************************************************
			* Dynamic Table style
			********************************************************************
			file write `canvas' "<style>" _n 									///
				"table {" _n 													///
					_skip(4) "border-collapse: collapse;" _n		 			///
					_skip(4) "border-bottom:1px solid black;" _n 				///
					_skip(4) "padding:5px;" _n 									///
					_skip(4) "margin-top:14px;" _n 								///
					_skip(4) "margin-bottom:14px;" _n 							///
					_skip(4) "font-size: 14px;" _n 								///
				"}" _n(2) 														///
				"th {" _n 														///
					_skip(4) "border-bottom:1px solid black;" _n 				///
					_skip(4) "border-top:1px solid black;" _n 					///
				"}" _n(2) 														///
				"td {" _n 														///
					/// "padding-right:20px;" _n 								///
				"}" _n 															///
				"</style>" _n(3)
		}
			
	****************************************************************************
	* Importing External style
	****************************************************************************
	// is run from the Statax program
			
	file close `canvas'
end
