/*** DO NOT EDIT THIS LINE -----------------------------------------------------
Version:
Title: img
Description: captures and imports images and graphs into the dynamic document. 
This command belongs to {bf:{help Weaver}} package but it also supports the 
{bf:{help MarkDoc}} package. This document only describes __txt__ in Weaver package. 
For using the command in MarkDoc package, 
[read the MarkDoc manual](https://github.com/haghish/MarkDoc/wiki/img/). 
----------------------------------------------------- DO NOT EDIT THIS LINE ***/


/***
Syntax
======

    Import graphical files in the dynamic document
	
	{cmdab:img} [using {it:{help filename}}] [{cmd:,} {opt tit:le(str)} {opt w:idth(int)} {opt h:eight(int)} {opt left} {opt center}  ]

    Automatically include the {it:current graph} from Stata in the dynamic document
	
	{cmdab:img} [{cmd:,} {opt tit:le(str)} {opt w:idth(int)} {opt h:eight(int)} {opt left} {opt center}  ]

Description
===========

The __img__ command imports images and graphs into the dynamic document. 
Any graphical file that is compatible with a web-browser can be inserted in the 
html log. This command belongs to {help Weaver} package but it also supports the 
{help MarkDoc} package. The syntax for both packages is the same but
the __img__ command behave differently based on which of the packages is in use. 
If Weaver html log and smcl log are open at the same time, the command 
only functions for Weaver and not for MarkDoc. In contrast, when Weaver html log is
not open and scml log is on, it will function for MarkDoc package. 

Options
=======

{phang}{cmdab:tit:tle(}{it:str}{cmd:)} specify a header string (title) for the figure {p_end}

{phang}{opt w:idth(int)} define the width of the figure. This option must be used 
with {opt h:ight(int)} option. Otherwise, it will keep the actual hight of the 
figure and only changes the width. {p_end}

{phang}{opt h:ight(int)} define the hight of the figure. This option must be used 
with {opt w:idth(int)} option for the same reason mentioned above. {p_end}
 
{phang}{cmdab::left} this option is the default and it aligns the figure to the 
left-side of the dynamic document. {p_end}

{phang}{cmdab::center} aligns the figure to the center of the dynamic document. {p_end}

Examples
=================

You have created a graph in Stata. Before importing in the HTML log, you should 
export it in a format that can be interpreted in html. Such as PNG which is recommended 
because it is lossless format and the same file can be used for publication. 

        . sysuse auto
        . histogram price
        . graph export price.png, replace 

        . img using price.png
        . img using price.png, title("Histogram of the Price variable")
        . img using price.png, w(300) h(200) center
    
	Alternatively, the image can be obtained from Stata automatically

        . histogram mpg
        . img, title("Histogram of the MPG variable")

Author
======

__E. F. Haghish__     
Center for Medical Biometry and Medical Informatics     
University of Freiburg, Germany     
_and_        
Department of Mathematics and Computer Science       
University of Southern Denmark     
haghish@imbi.uni-freiburg.de     
      
[Weaver Homepage](www.haghish.com/weaver)         
Package Updates on [Twitter](http://www.twitter.com/Haghish)  

- - -

_This help file was dynamically produced by[MarkDoc Literate Programming package](http://www.haghish.com/markdoc/)_ 
***/

cap prog drop img
program define img
version 11
		
    syntax [using/], [Width(numlist max=1 >0 <=14000)] 							///
	[Height(numlist max=1 int >0 <=14000)] [TITle(str)] [left|center] 			///
	[Markup(str)]
			    
	
	************************************************************************
	* GENERAL SYNTAX PROCESSING
	*
	* - load global values
	* - make sure "`using'" is a filename
	* - if `using' is missing, automaticaly export the image and define it
	* - check that only one of the align options is selected
	* - defining the default image alignment
	* - check the markup option (FOR MARKDOC ONLY)
	************************************************************************
	
	if !missing("`using'") {
		confirm file "`using'"
	}
	
	else {
		local autoimg 1
		// WF : Weaver-figure directory or Log-file directory for MarkDoc
		if "$weaver" != "" {
			if "`c(os)'"=="Windows" local WF = "$weaverDir" + "\Weaver-figure\"
			if "`c(os)'"!="Windows" local WF = "$weaverDir" + "/Weaver-figure/"
		}
		if "$weaver" == "" {
			quietly log query
			if "`r(status)'" == "on" {
				local path = r(filename)
				if "`c(os)'" == "Windows" {
					local path : subinstr local path "/" "\", all
					tokenize "`path'", parse("\")					 
				}
				else tokenize "`path'", parse("/")
					
				while !missing("`1'") {
					if !missing("`3'") local WF = "`WF'" +"`1'"	//avoid the last 2 
					macro shift
				} 
				
				// define the path to Weaver-figure
				if "`c(os)'" == "Windows" local WF = "`WF'" + "\Weaver-figure\"
				if "`c(os)'" != "Windows" local WF = "`WF'" + "/Weaver-figure/"
			}
		}
	
		// try to navigate to Weaver-figure, to check if it already exists
		local d : pwd
		capture cd "`WF'"
		if _rc != 0 {
			mkdir "`WF'", public
		}
		else { 
			quietly cd "`d'"
		}	
		
		// the first time img is called, erase the previous figures, if the 
		// weaver log IS NOT APPENDED or if Weaver is not in use
		if missing("$currentFigure") {
			global currentFigure 1
			if !missing("$weaver") & missing("$weaverAppend") | 				///
			missing("$weaver") {
				local files : dir "`WF'" files "*.png"
				foreach lname in `files' {
					capture erase "`WF'`lname'"
				}	
			}
		}
		
		else global currentFigure = $currentFigure + 1 
		
		// EXPORTING THE GRAPH for Weaver & MarkDoc
		local exp = "`WF'" + "figure_$currentFigure" + ".png"
		if !missing("$weaver")  {
			qui graph export "`exp'", replace
		}	
		if missing("$weaver")  {
			if missing("`width'") local w 400
			else local w `width'
			qui graph export "`exp'", replace width(`w')
		}
		
		// define using for the rest of the program
		local using = "Weaver-figure/figure_$currentFigure" + ".png"
		
	}
	
	
	if "`left'" == "left" & "`center'" == "center" {
		di as err `"{p}The {bf:left} and "' ///
		`"{bf:center} options cannot be used together"'
		exit 198
	}
	
	// make center the default location of the figure for HTML and LaTeX
	if missing("`left'") & missing("`center'") {
		local center center
	}
	
	if "`center'" == "center" {
		local centerClass class="center"
		local centerStyle style="text-align:center;"
	}
	
	if "$weaver" == "" {
		if !missing("`markup'") & "`markup'" != "markdown" & 				///
		"`markup'" != "html" & "`markup'" != "latex" {
			di as err `"{p}{bf:`markup'} is not recognized"' 
			exit 198
		}
	}
	
	
	************************************************************************
	* FOR WEAVER PACKAGE
	*
	* - setup the default image size for HTML log
	* - write the image title in html 
	* - print the LaTeX code
	************************************************************************
	if "$weaver" != "" {
		
		tempname canvas
		file open `canvas' using `"$weaverFullPath"', write text append
		
		if "$weaverMarkup" == "html" {		
			if "$format" == "normal" & missing("`width'") {
				local width 343
			}
		
			if "$format" == "normal" & missing("`height'") {
				local height 250
			}
		
			if "$format" == "landscape" & missing("`width'") {
				local width 1020
			}
		
			if "$format" == "landscape" & missing("`height'") {
				local height 694
			}
		
			/*
			if 	"$format" == "normal" & "`width'" > "694" {
				display as error "{p}image width cannot be more than {bf:694} " ///
				"pixles, unless you choose the {help landscape} option " ///
				"from the {help weave} command"
				exit 198
			}
				
			if 	"$format" == "normal" & "`height'" > "1000" {
				display as error "{p}image height cannot be more than {bf:1000} pixles"
				exit 198
			}
				
			if 	"$format" == "landscape" & "`width'" > "1020" {
				display as error "{p}image width cannot be more than {bf:1000} pixles"
				exit 198
			}
				
			if 	"$format" == "landscape" & "`height'" > "694" {
				display as error "image height cannot be more than 694 " ///
				"pixles, unless you {bf:remove} the {help landscape} " ///
				"option from the {help weave} command"
				exit 198
			}
			*/
			
			file write `canvas' `"<img rel="zoom"  src="`using'" "' 			///
				`"`centerClass' width="`width'" height="`height'" >"'
			
			if "`title'" ~= "" {
				file write `canvas' _n `"<span class="tble" "'					///
				`"`centerStyle'>`title'</span>"' 								///
				 _n "<br />" _n 
			}
		}
		
		if "$weaverMarkup" == "latex" {
			
			if missing("`width'") & missing("`height'") {
				local width  225
				local height 150
			}
			if !missing("`width'") & missing("`height'") {
				local miss h
			}
			if missing("`width'") & !missing("`height'") {
				local miss w
			}
			
			file write `canvas' _n "\begin{figure}[h]" _n 	
			
			if !missing("`center'") file write `canvas' "    \centering" _n
			else file write `canvas' "    \captionsetup{justification="			///
			"raggedright,singlelinecheck=false}" _n

			if "`miss'" == "w" file write `canvas' 								///
			"    \includegraphics[height=`height'px]{`using'}" _n
			else if "`miss'" == "h" file write `canvas' 						///
			"    \includegraphics[width=`width'px]{`using'}" _n
			else  file write `canvas' "    \includegraphics[width=`width'px, "	///
			"height=`height'px]{`using'}" _n
			
			if "`title'" ~= "" file write `canvas' "    \caption{`title'}" _n
			
			file write `canvas' "\end{figure}" _n(2)

		}
	}
		
		
	************************************************************************
	* FOR MarkDoc PACKAGES
	************************************************************************
	
	if "$weaver" == "" | "$noisyWeaver" == "yes" {
		
		//If the smcl log file is on
		quietly log query
		if "`r(status)'" == "on" {
			
			if missing("`width'") & missing("`height'") {
				local width 350
				local height 250
			}						
					
			// -----------------------------------------------------------------
			// Define the Markup language and print the output
			// =================================================================
			if missing("`markup'") & !missing("$markdocDefault") {
				local markup "$markdocDefault"
			}
			if missing("`markup'") & missing("$markdocDefault") {
				local markup "markdown" 
			}
	
			// -----------------------------------------------------------------
			// Markdown syntax 
			// -----------------------------------------------------------------
			if "`markup'" == "markdown" {
				noisily display as txt _n ">![`title'](`using')" _n 
			}
			
			// -----------------------------------------------------------------
			// HTML syntax 
			// -----------------------------------------------------------------
			if "`left'" == "left" & "`markup'" == "html" {
				if "`title'" ~= "" {
					noisily display as txt 									///
					`"><p style="text-align:left; margin-bottom:0;">`title'</p>"' _n
				}
				noisily display as txt `"><img src="`using'" "' 			///
				`"width="`width'" height="`height'" >"' _newline 
			}
			
			if "`center'" == "center" & "`markup'" == "html" {
				if "`title'" ~= "" {
					noisily display as txt 									///
					`"><p style="text-align:center; margin-bottom:0;">`title'</p>"' _n
				}
				noisily display `"><img src="`using'" "' 					///
				`"class="center"   width="`width'" height="`height'" >"' _n
			}
			
			
			// -----------------------------------------------------------------
			// LaTeX syntax 
			// =================================================================
			if "`markup'" == "latex" {
			
				if missing("`width'") & missing("`height'") {
					local width  225
					local height 150
				}
				if !missing("`width'") & missing("`height'") {
					local miss h
				}
				if missing("`width'") & !missing("`height'") {
					local miss w
				}
				
				//if !missing("`autoimg'") noisily display _n "\end{verbatim}" _n
				
				noisily display _n ">\begin{figure}[h]" 
			
				if !missing("`center'") noisily display ">\centering" 
				
				else noisily display ">\captionsetup{justification="		///
				"raggedright,singlelinecheck=false}" 

				if "`miss'" == "w" noisily display 								///
				">\includegraphics[height=`height'px]{`using'}" 
				
				else if "`miss'" == "h" noisily display							///
				">\includegraphics[width=`width'px]{`using'}" 
				
				else  noisily display ">\includegraphics[width=`width'px, "	///
				"height=`height'px]{`using'}" 
			
				if "`title'" ~= "" noisily display ">\caption{`title'}" 
			
				noisily display ">\end{figure}" _n
				
				//if !missing("`autoimg'") noisily display _n "\begin{verbatim}" _n
			}	
		}
	}
	
	// Check the Status of the log files for Weaver and MarkDoc					
	qui log query
	if "`r(status)'" ~= "on" & "$weaver" == "" {
		di as txt _n(2) "{hline}"
		di as error "{bf:Warning}" _n
		di as txt "{p}log file is off! " _n 
		di as txt "{c 149} If you wish to use {help weaver}  package, turn the html log on"  
		di as txt "{c 149} If you wish to use {help markdoc} package, turn the smcl log on"		
		di as txt "{hline}{smcl}"	_n
	}
		
end


// DYNAMIC HELP FILE
// ===================================

markdoc img.ado, export(sthlp) replace
