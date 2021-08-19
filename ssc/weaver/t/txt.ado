/***
{smcl}
{marker title}{...}
{title:Title}

{phang}
{cmdab:txt} {hline 2} Prints string and values of scalar expressions or macros 
in dynamic document. By default, the command writes a 
text paragraph. The primary purpose of the command is writing dynamic text to 
interpret analysis results in the dynamic document. This command belongs 
to {help Weaver} package, but it also supports the 
{help MarkDoc} package. The syntax for both packages is similar, but
the {cmdab:txt} command behaves differently based on which package is in use. 
If Weaver log is on, {cmd:txt} functions for Weaver package only. 
This document only describes the __txt__ command in Weaver package. For using the 
command in {help MarkDoc} package 
[see the MarkDoc documentation on GitHub wiki](https://github.com/haghish/MarkDoc/wiki/txt)

{marker syntax}{...}
{title:Syntax}

Prints dynamic text on the Weaver log or smcl log. The {opt c:ode} subcommand 
prints the output "as is" in the dynamic document. 
	
	{cmdab:txt} [{opt c:ode}] [{it:display_directive} [{it:display_directive} [{it:...}]]]

{pstd}where the {it:display_directive} is

	{help weaver_markup:Weaver Markup}
	{cmd:"}{it:double-quoted string}{cmd:"}
{p 8 16 2}{cmd:`"}{it:compound double-quoted string}{cmd:"'}{p_end}
	[{help format:{bf:%}{it:fmt}}] [{cmd:=}]{it:{help exp}}
	{cmd:_skip(#)}
	{cmdab:_col:umn:(}{it:#}{cmd:)}
	{cmdab:_n:ewline}[{cmd:(}{it:#}{cmd:)}]
	{cmdab:_d:up:(}{it:#}{cmd:)}
	{cmd:,}
	{cmd:,,}

{marker description}{...}
Description
===========

__txt__ prints dynamic text i.e. strings and values of scalar expressions or macros in the Weaver or the 
smcl log-file. {cmd:txt} also prints output from the user-written Stata programs. Any of the 
supported markup languages can be used to alter the string and scalar expressions. This command 
is to some extent similar to {cmd:display} command in Stata. For example, 
it can be used to carry out a mathematical calculation by typing {cmd:txt 1+1}. It also 
supports many of the display directives as well. 

Note that in contrast to the {help display} command that prints the 
{help scalar} unformatted, the {cmd:txt} command uses the default 
{bf:%10.2f} format for displaying the scalar. This feature helps the users avoid 
specifying the format for every scalar, due to popularity of this 
format. However, specifying the format expression can overrule the default format. 
For example:

	{cmd:. scalar num = 10.123}
	{cmd:. txt "The value of the scalar is " %5.1f num}
	
{pstd}
The example above will print the scalar with only 1 decimal number. 
This feature only supports scalar interpretation and does not affect 
the {help macro} contents.  


{title:Display directives}

{pstd}
The supported {it:display_directive}s are used in do-files and programs
to produce formatted output.  The directives are		 

{synoptset 32}
{synopt:{bf:{help weaver_markup:Weaver Markup}}}A simplified markup language for 
	annotating the content of the HTML log{p_end}
			  
{synopt:{cmd:"}{it:double-quoted string}{cmd:"}}displays the string without
              the quotes{p_end}

{synopt:{cmd:`"}{it:compound double-quoted string}{cmd:"'}}display the string
              without the outer quotes; allows embedded quotes{p_end}

{synopt:[{cmd:%}{it:fmt}] [{cmd:=}] {cmd:exp}}allows results to be formatted;
         see {bf:{mansection U 12.5FormatsControllinghowdataaredisplayed:[U] 12.5 Formats: Controlling how data are displayed}}.{p_end}

{synopt:{cmd:_skip(}{it:#}{cmd:)}}skips {it:#} columns{p_end}

{synopt:{cmd:_column(}{it:#}{cmd:)}}skips to the {it:#}th column{p_end}

{synopt:{cmd:_newline}}goes to a new line{p_end}

{synopt:{cmd:_newline(}{it:#}{cmd:)}}skips {it:#} lines{p_end}

{synopt:{cmd:_dup(}{it:#}{cmd:)}}repeats the next directive {it:#} times{p_end}
		 
{synopt:{cmd:,}}displays one blank between two directives{p_end}

{synopt:{cmd:,,}}places no blanks between two directives{p_end}
{p2colreset}{...}

Mathematical notations
======================

The __txt__ command can be used for writing mathematical notations in Weaver 
package, both in HTML and LaTeX log files. Writing mathematical notations in the 
HTML log is made possible by including {bf:MathJax} engine, a JavaScript-based 
engine for rendering LaTeX notations in HTML format. 
To do so, notations should begin with "{bf:\(}" and end with "{bf:\)}" for 
rendering notations within the text and double dollar sign "{bf:$$}" or alternatively, 
the "{bf:\[}" and "{bf:\]}" for rendering 
notations in a separate line. For more information in this 
regard, see {help Weaver_mathematical_notation:mathematical notations} documentation. 

When Weaver package is running, the {opt c:ode} subcommand appends the dynamic text to the 

{marker examples}{...}
Examples
========

{pstd}As a hand calculator:

{phang2}{cmd:. txt 2 * 2}

{pstd}As might be used in do-files and programs:

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. summarize price}{p_end}
{phang2}{cmd:. txt "mean of Price variable is " r(mean) " and SD is " %9.3f r(sd)}{p_end}

{pstd}If the text only includes string and macro, the double quotations can be ignored. 
The {cmd:txt} command will interpret all of the {it:display_directives} and 
scalars as string (so it's not recommended):

{phang2}{cmd:. local n 9.9}{p_end}
{phang2}{cmd:. txt Not recommended, but you may also print the value of `n' without double quote}{p_end}

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

This help file was dynamically produced by {help markdoc:MarkDoc Literate Programming package}
***/

*capture program drop txt
program define txt
version 11
	
	****************************************************************************
	* Allowing Scalar interpretation
	****************************************************************************
/*
	if "$weaver" != "" {
	capture local m : display `0'					
	if _rc == 0 {
		local 0 `m'
	}
}
*/
	****************************************************************************
	* Processing "code" suffix
	*
	* - check if the "code" subcomman is defined after "txt"
	* - if there is no code subcommand, define local "code = 0"
	* - if yes, remove it and append the rest to Weaver log
	* - interpret the scalars in the command, if there is any
	* - define a local macro identifier "code = 1",  if there is a code
	****************************************************************************
	
	capture tokenize "`0'" 							// add quotes to avoid "comma" error

	if  missing("`2'") local code = 0
	if !missing("`2'") {
		
		if "`1'" == "c" | "`1'" == "co" | "`1'" == "cod" | "`1'" == "code" {
			local 0 : subinstr local 0 "`1'" ""	
			local code = 1
		}
													
		else {
			local code = 0							// no code tag
		}	
	}
	
	****************************************************************************
	* If Weaver package is in use and there is no code subcommand 
	*
	* - change MathJax notation based on the markups
	* - print the text in Weaver log based on the Weaver markup
	*
	* Specifying the Mathematics Notation
	* ===================================
	*
	* It'd be nice to use a similar syntax for both ASCII and LaTeX notations, 
	* but there are some challenges:
	*
	* - first of all, if the "$" is connected, Stata considers it as a 
	*	Global Macro, both in LaTeX and HTML log
	*		
	* - if the "$" is specified for JavaScript engine in HTML log, JS will 
	*	remove the "$" of global macros in commands as well... So this notation 
	*	must no be specified in the JS engine. Besides, $ appears very often in
	*	documents and is not a distinct sign
	* 
	* - For ASCII math, MathJax supports "`" delimites which interfere with 
	*	Markdown syntax for mono-space font! Thus, it must not be used... 
	*
	* - One solution is applying "\(" "\)" and "\[" "\]" for both ASCII and LaTeX
	* - Making "$$" available for both ASCII and LaTeX
	****************************************************************************
	
	// Why not applying LaTeX syntax for all? 
	
	if "$weaver" != ""  {	
		
		/*
		if "$weaverMarkup" == "html" {
		
			if "$weavermath" == "mathlatex" {
				local 0 : subinstr local 0 "§§" "$$", all
				local 0 : subinstr local 0 "###" "$$", all
				*local 0 : subinstr local 0 "##" "§", all
			}
			
			
			if "$weavermath" == "mathascii" {
				forvalues i = 1(1)20 {
					local 0 : subinstr local 0 "###" `"<span class="math">\("'
					local 0 : subinstr local 0 "###" "\) </span>"
					local 0 : subinstr local 0 "§§" `"<span class="math">\("'
					local 0 : subinstr local 0 "§§" "\) </span>"
					local 0 : subinstr local 0 "\[" `"<span class="math">\("'
					local 0 : subinstr local 0 "\]" "\) </span>"
					local 0 : subinstr local 0 "$$" `"<span class="math">\("'
					local 0 : subinstr local 0 "$$" "\) </span>"
				}
			}
		}
		*/

		tempname canvas
		cap file open `canvas' using `"$weaverFullPath"', write text append
	
		/*
		if "$weaverMarkup" == "html" {
			cap file write `canvas' "<p>" 	
			cap file write `canvas' `"`macval(0)'"' 
			cap file write `canvas' "</p>" _n
		}
		
		if "$weaverMarkup" == "latex" {
			cap file write `canvas' _n `"`macval(0)'"' _n
		}
		*/
		
		if "`code'" == "0" & "$weaverMarkup" == "html" cap file write `canvas' "<p>" _c
		if "$weaverMarkup" == "latex" cap file write `canvas' _n    
		
		// ---------------------------------------------------------------------
		// Engine
		// =====================================================================
		local 0 : subinstr local 0 "`" "{c 96}", all
		local 0 : subinstr local 0 "'" "{c 39}", all

		tokenize `"`macval(0)'"'  , parse(`"""')
		
		while `"`1'"' ~= "" {
			
			*local 1 : subinstr local 1 "//(" "\(", all
			
			local 1 : subinstr local 1 "{c 96}" "`", all
			local 1 : subinstr local 1 "{c 39}" "'", all
			
			local test : display real("`1'")	// exclude real numbers (macros)
			
			if "`test'" != "." cap file write `canvas' "`1'" _c
		
			if "`test'" == "." {
			
				if substr("`1'",1,2) != "_n" & substr("`1'",1,2) != "_s" &	///
				   substr("`1'",1,2) != "_c" & substr("`1'",1,2) != "_d" &  ///
				   substr("`1'",1,2) != "_r" {
			   
					// Non-Integer Scalars
					capture local test2 : display `1'
				
					// Integer Scalar
					capture local test3 : display int(`test2') 
				}	
								

				// `1' is an integer Scalar
				if !missing("`test2'") & "`test3'" == "`test2'" {
					if substr("`1'",1,2) != "_n" & substr("`1'",1,2) != "_s" &	///
					substr("`1'",1,2) != "_c" & substr("`1'",1,2) != "_d" &  	///
				    substr("`1'",1,2) != "_r" {
						capture local m : display `1'
						if _rc == 0 {
							local 1 `m'
							cap file write `canvas' "`1'" _c
						}	
					}	
				}		
					
				// Real 
				else if !missing("`test3'") & "`test3'" != "`test2'" {							
					capture local m : display %10.2f `1'
					if _rc == 0 {
						local 1 : display trim("`m'")     // Avoid extra space
						cap file write `canvas' "`1'" _c
					}
				}
				
				// Several scalars or numeric macros
				else if !missing("`test2'") & missing("`test3'") {							
					capture local m : display %10.2f `1'
					if _rc == 0 {
						local 1 : display trim("`m'")     // Avoid extra space
						cap file write `canvas' "`1'" _c
					}
				}
				
				
				//Strings
				if missing("`test2'") {	
					
					// New Lines
					if substr("`1'",1,2) == "_n" {
					
						cap file write `canvas' `1'  _c
					}
					
					//Duplicates
					else if substr("`1'",1,2) == "_d" {
						local memo "`1'"
						macro shift
						local memo2: display `memo' "`1'"
						cap file write `canvas' "`memo2'" _c
					}
					
					//Avoid _char()
					else if substr("`1'",1,6) =="_char(" {
						display as err _n(2) "`1' is not allowed" 
						err 198
					}
					
		
					// Other directives
					else if substr("`1'",1,2) == "_s" |							///
					   substr("`1'",1,2) == "_c" | substr("`1'",1,2) == "_r" {
						cap file write `canvas' `1' _c
					}
					
					// All other strings
					else {
						cap file write `canvas' "`1'" _c
					}
					
				}
			}
			
			macro shift
			local test
			local test2
			local test3	
		}
		// ---------------------------------------------------------------------

		
		if "$weaverMarkup" == "html" & "`code'" == "0" cap file write `canvas' "</p>" _n
		if "$weaverMarkup" == "latex" cap file write `canvas' _n  
	}	
		
	
	
	
	
	
	
	************************************************************************
	* MarkDoc: if Weaver package is NOT in use
	*
	* print the text output to smcl log anyway
	* if smcl log file is not on, notify the user
	************************************************************************
	
	if "$weaver" == "" | "$noisyWeaver" == "yes" {
		
		if "`code'" == "0" display as txt _n(2) `"> "' _c
		if "`code'" == "1" display as txt _n(2) ">~~~" _n ">" _c
		
		local 0 : subinstr local 0 "`" "{c 96}", all
		local 0 : subinstr local 0 "'" "{c 39}", all
		
		tokenize `"`macval(0)'"' , parse(`"""')	
		
		
	
		while `"`1'"' ~= "" {
			
			local 1 : subinstr local 1 "{c 96}" "`", all
			local 1 : subinstr local 1 "{c 39}" "'", all
			
			local test : display real("`1'")	// exclude real numbers (macros)
			
			if "`test'" != "." display as txt "`1'" _c
		
			if "`test'" == "." {
			
				if substr("`1'",1,2) != "_n" & substr("`1'",1,2) != "_s" &	///
				   substr("`1'",1,2) != "_c" & substr("`1'",1,2) != "_d" &  ///
				   substr("`1'",1,2) != "_r" {
			   
					// Non-Integer Scalars
					capture local test2 : display `1'
				
					// Integer Scalar
					capture local test3 : display int(`test2') 
				}	
								

				// `1' is an integer Scalar
				if !missing("`test2'") & "`test3'" == "`test2'" {
					if substr("`1'",1,2) != "_n" & substr("`1'",1,2) != "_s" &	///
					substr("`1'",1,2) != "_c" & substr("`1'",1,2) != "_d" &  	///
				    substr("`1'",1,2) != "_r" {
						capture local m : display `1'
						if _rc == 0 {
							local 1 `m'
							display "`1'" _c
						}	
					}	
				}		
					
				// Real 
				else if !missing("`test3'") & "`test3'" != "`test2'" {							
					capture local m : display %10.2f `1'
					if _rc == 0 {
						local 1 : display trim("`m'")     // Avoid extra space
					}
					display "`1'" _c
				}
			
				// Several scalars or numeric macros
				else if !missing("`test2'") & missing("`test3'") {							
					capture local m : display %10.2f `1'
					if _rc == 0 {
						local 1 : display trim("`m'")     // Avoid extra space
					}
					display "`1'" _c
				}
				
				//Strings
				if missing("`test2'") {	
					
					// New Lines
					if substr("`1'",1,2) == "_n" {
						display as txt `1' "> " _c
					}
					
					//Duplicates
					else if substr("`1'",1,2) == "_d" {
						local memo "`1'"
						macro shift
						display `memo' "`1'" _c
					}
					
					//Avoid _char()
					else if substr("`1'",1,6) =="_char(" {
						display as err _n(2) "`1' is not allowed" 
						err 198
					}
					
					// Other directives
					else if substr("`1'",1,2) == "_s" |							///
					   substr("`1'",1,2) == "_c" | substr("`1'",1,2) == "_r" {
						display `1' _c
					}
					
					// All other strings
					else {
						display "`1'" _c
					}
				}
			}
			
			macro shift
			local test
			local test2
			local test3
	
		}
		
		if "`code'" == "1" display _n ">~~~" 
	}

	// Check the Status of the log files for Weaver and MarkDoc					
/*
	qui log query
	if "`r(status)'" ~= "on" & "$weaver" == "" {
		di as txt _n(2) "{hline}"
		di as error "{bf:Warning}" _n
		di as txt "{p}log file is off! " _n 
		di as txt "{c 149} If you wish to use {help weaver}  package, turn the html log on"  
		di as txt "{c 149} If you wish to use {help markdoc} package, turn the smcl log on"		
		di as txt "{hline}{smcl}"	_n
	}
*/	
	/*
	if "$weaver" == "" & "`code'" == "1" {
		capture local m : display `0'					
		if _rc == 0 {
			local 0 `m'
		}
		display as smcl  
		display ">~~~" _n `">`macval(0)'"' _n ">~~~" 
		display in smcl	
	}
	*/
end


// create the help file
// ====================
*markdoc txt.ado, exp(sthlp) replace template(empty)

