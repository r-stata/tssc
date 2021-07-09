/*******************************************************************************

					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de
								   
                    * Synlight package comes with no warranty *


	
	Synlight version 1.0  August, 2014 
	Synlight version 1.1  September, 2014 */

	program synlight
		version 11
		syntax anything(name=smclfile id="The smclfile name is")  ///
		[, erase replace CFont(str) Font(str) Title(str) Size(numlist) ///
		STYle(name) css(str)]
		
		
		*read the Global Macro including the word lists
		synlightlist
		
		
		********************************************************************
		*SYNTAX PROCESSING
		********************************************************************
		
		local input `smclfile'	
		
		if (!index(lower("`input'"),".smcl")) {
				local html "`input'.html"
				local tempfile  "`input'_temp.html"
				local corrected  "`input'_temp.smcl"
				local input  "`input'.smcl"
				}
				

		
		/* DEFINING THE FONT */
		if "`cfont'" == "" {
						local cfont Menlo-Regular, monaco, Courier New;
						}
						
				if "`font'" == "" {
						local font Courier New;
						}	
				
				if "`size'" == "" {
						local size 12
						}
				
				
				
	if "`css'" == "" {					
		/* STATA STYLES */
		if "`style'" == "" | "`style'" == "stata" | "`style'" == "Stata" ///
		| "`style'" == "st"  {
						
				*> colors
				local command .command{color:#00008A;font-size:`size'px;font-family:`cfont'}
				local function .function{color:#00F;font-family:`cfont'}
				local macro .macro{color:#008080;font-family:`cfont'}
				local string .string{color:#800000;font-family:`cfont'}
				local overstring color:#800000;
				local digit .digit{color:#0052FF;font-family:`cfont'}
				local comment .comment{color:#0F7F11;font-family:`cfont'}
				local overcomment color:#0F7F11;
				local brace .brace{color:#FF2600;font-family:`cfont'}
				local sign .sign{color:#000;font-family:`cfont'}
				local error .error{color:#F00;font-family:`cfont'}
				
				*> body
				local general body, code, div, span {font-family:`font'}
				local body body{padding:20px 3% 0 3%; }
				local header header{font-size:28px; text-align:center; padding-bottom:28px;}
				local code .code{background-color:#EBEBEB;display:block; ///
						padding:10px; font-size:`size'px; font-family:`cfont'}
				local output .output{display:block; white-space:pre; font-size:`size'px;font-family:`font'}
				local p p{white-space:normal; font-family:`font'}
				}
	
	
		/* DARING STYLES */
		if "`style'" == "daring" | "`style'" == "dar" {
				
				*> colors
				local command .command{color:#5E97F4;font-size:`size'px;font-family:`cfont'}
				local function .function{color:#96A6C8;font-family:`cfont'}
				local macro .macro{color:#95A99F;font-family:`cfont'}
				local string .string{color:#73C935;font-family:`cfont'}
				local overstring color:#73C935;
				local digit .digit{color:#FFDC33;font-family:`cfont'}
				local comment .comment{color:#CC8C3C;font-family:`cfont'}
				local overcomment color:#CC8C3C;
				local brace .brace{color:#906;font-family:`cfont'}
				local sign .sign{color:#FFB052;font-family:`cfont'}
				local error .error{color:#F00;font-family:`cfont'}
				
				*> body
				local code .code{background-color:#333333;display:block; ///
					padding:10px; font-size:`size'px; font-family:`cfont'; color: white; border-radius:7px;}
				local output .output{color:#F4F4FF; display:block; white-space:pre; font-size:`size'px;font-family:`font'}
				local general body, code, div, span {font-family:`font'}
				local body body{padding:20px 3% 0 3%; background-color:#282828;}
				local header header{font-size:28px; text-align:center; padding-bottom:28px;color:white;}
				local p p{white-space:normal; font-family:`font'; color:#F4F4FF;}
				}
	
	
		/* MIDNIGHT STYLE*/
		if "`style'" == "midnight" | "`style'" == "mid" {
				
				*> colors
				local command .command{color:#D31795;font-size:`size'px;font-family:`cfont'}
				local function .function{color:#FEFFFE;font-family:`cfont'}
				local macro .macro{color:#E47C48;font-family:`cfont'}
				local string .string{color:#FF2C38;font-family:`cfont'}
				local overstring color:#FF2C38;
				local digit .digit{color:#786DFF;font-family:`cfont'}
				local comment .comment{color:#41CC45;font-family:`cfont'}
				local overcomment color:#41CC45;
				local brace .brace{color:#FEFFFE;font-family:`cfont'}
				local sign .sign{color:#4971FA;font-family:`cfont'}
				local error .error{color:#F00;font-family:`cfont'}
				
				*> body
				local code .code{background-color:#564F30;display:block; ///
					padding:10px; font-size:`size'px; font-family:`cfont'; color:white;}
				local output .output{color:#FEFFFE; display:block; white-space:pre; font-size:`size'px;font-family:`font'}
				local general body, code, div, span {font-family:`font'}
				local body body{padding:20px 3% 0 3%; background-color:black;}
				local header header{font-size:28px; text-align:center; padding-bottom:28px;color:#837C60;}
				local p p{white-space:normal; font-family:`font'; color:#FEFFFE;}
				}
	
	
		/* SUNSET STYLE */
		if "`style'" == "sunset" | "`style'" == "sun" {
				
				*> colors
				local command .command{color:#294277;font-size:`size'px;font-family:`cfont'}
				local function .function{color:#4E7CBD;font-family:`cfont'}
				local macro .macro{color:#646485;font-family:`cfont'}
				local string .string{color:#DF0707;font-family:`cfont'}
				local overstring color:#DF0707;
				local digit .digit{color:#294277;font-family:`cfont'}
				local comment .comment{color:#C3741C;font-family:`cfont'}
				local overcomment color:#C3741C;
				local brace .brace{color:#CD5C5C;font-family:`cfont'}
				local sign .sign{color:#4268CC;font-family:`cfont'}
				local error .error{color:#F00;font-family:`cfont'}
				
				*> body
				local code .code{background-color:#F9DF9C;display:block; ///
					padding:10px; font-size:`size'px; font-family:`cfont'; border:0px solid; border-radius: 10px;}
				local output .output{display:block; white-space:pre; font-size:`size'px;font-family:`font'}
				local general body, code, div, span {font-family:`font'}
				local body body{padding:20px 3% 0 3%;background-color:#FFFCE5;}
				local header header{font-size:28px; text-align:center; padding-bottom:28px;}
				local p p{white-space:normal; font-family:`font';}
				}
		
		
		/* IMBI STYLE */
		if "`style'" == "IMBI" | "`style'" == "imbi" {
				
				*> colors
				local command .command{color:#00008A;font-size:`size'px;font-family:`cfont'}
				local function .function{color:#9A88C6;font-family:`cfont'}
				local macro .macro{color:#718C00;font-family:`cfont'}
				local string .string{color:#F66;font-family:`cfont'}
				local overstring color:#F66;
				local digit .digit{color:#F1A517;font-family:`cfont'}
				local comment .comment{color:#0F7F11;font-family:`cfont'}
				local overcomment color:#0F7F11;
				local brace .brace{color:#49AABE;font-family:`cfont'}
				local sign .sign{color:#FF7312;font-family:`cfont'}
				local error .error{color:#F00;font-family:`cfont'}
				
				*> body
				local code .code{background-color:#F5F5F5;display:block; ///
					padding:10px; font-size:`size'px; font-family:`cfont'; border:0px solid; border-radius:10px; -moz-box-shadow: 1px 2px 3px #d4d4d4;-webkit-box-shadow: 1px 1px 3px #d4d4d4;box-shadow: 1px 1px 3px #d4d4d4; color:#585858;}
				local output .output{display:block; white-space:pre; font-size:`size'px;font-family:`cfont';color:#6D6D6D;}
				local general body, code, div, span {font-family:`cfont'}
				local body body{padding:20px 3% 0 3%; background-color: #FBFBFB;}
				local header header{font-size:28px; text-align:center; padding-bottom:28px;}
				local p p{white-space:normal; font-family:`cfont';}
				}
				
		
		/* COBALT STYLE */
		if "`style'" == "cobalt" | "`style'" == "cob" {
				
				*> colors
				local command .command{color:#EA9B27;font-size:`size'px;font-family:`cfont'}
				local function .function{color:#FF8000;font-family:`cfont'}
				local macro .macro{color:#FF378E;font-family:`cfont'}
				local string .string{color:#FF6;font-family:`cfont'}
				local overstring color:#FF6;
				local digit .digit{color:#66F;font-family:`cfont'}
				local comment .comment{color:#0088FB;font-family:`cfont'}
				local overcomment color:#0088FB;
				local brace .brace{color:#FF2600;font-family:`cfont'}
				local sign .sign{color:#0080FF;font-family:`cfont'}
				local error .error{color:#F00;font-family:`cfont'}
				
				*> body
				local code .code{background-color:#062851;display:block; ///
					padding:10px; font-size:`size'px; font-family:`cfont'; color:white;}
				local output .output{display:block; white-space:pre; font-size:`size'px;font-family:`font';color:#FBFBFB;}
				local general body, code, div, span {font-family:`font'}
				local body body{padding:20px 3% 0 3%; background-color: #002240;}
				local header header{font-size:28px; text-align:center; padding-bottom:28px;color:#FF0080;}
				local p p{white-space:normal; font-family:`font';}
				}
				
			
		/* BLACKFOREST STYLE */
		if "`style'" == "blackforest" | "`style'" == "bl" {
				
				*> colors
				local command .command{color:#B4881D;font-size:`size'px;font-family:`cfont'}
				local function .function{color:#85981C;font-family:`cfont'}
				local macro .macro{color:#2C9E97;font-family:`cfont'}
				local string .string{color:#FD97C8;font-family:`cfont'}
				local overstring color:#FD97C8;
				local digit .digit{color:#2D6092;font-family:`cfont'}
				local comment .comment{color:#5C7782;font-family:`cfont'}
				local overcomment color:#5C7782;
				local brace .brace{color:#49AABE;font-family:`cfont'}
				local sign .sign{color:#FF7312;font-family:`cfont'}
				local error .error{color:#F00;font-family:`cfont'}
				
				*> body
				local code .code{background-color:#063642;display:block; ///
					padding:10px; font-size:`size'px; font-family:`cfont'; color:#8EA1A1;}
				local output .output{display:block; white-space:pre; font-size:`size'px;font-family:`font';color:#6D6D6D;}
				local general body, code, div, span {font-family:`font'}
				local body body{padding:20px 3% 0 3%; background-color: #002B35;}
				local header header{font-size:28px; text-align:center; padding-bottom:28px;color:#5C7782;}
				local p p{white-space:normal; font-family:`font';}
				}
				
				
				
		/* DESERT STYLE */
		if "`style'" == "desert" | "`style'" == "des" {
				
				*> colors
				local command .command{color:#C5783B;font-size:`size'px;font-family:`cfont'}
				local function .function{color:#85981C;font-family:`cfont'}
				local macro .macro{color:#2C9E97;font-family:`cfont'}
				local string .string{color:#C2BB5F;font-family:`cfont'}
				local overstring color:#C2BB5F;
				local digit .digit{color:#FFEF6F;font-family:`cfont'}
				local comment .comment{color:#B5925C;font-family:`cfont'}
				local overcomment color:#B5925C;
				local brace .brace{color:#AC0202;font-family:`cfont'}
				local sign .sign{color:#FF7312;font-family:`cfont'}
				local error .error{color:#F00;font-family:`cfont'}
				
				*> body
				local code .code{background-color:#363636;display:block; ///
					padding:10px; font-size:`size'px; font-family:`cfont'; color:#EBEBEB;}
				local output .output{display:block; white-space:pre; font-size:`size'px;font-family:`font';color:#C8BCA3;}
				local general body, code, div, span {font-family:`font'}
				local body body{padding:20px 3% 0 3%; background-color: #303030;}
				local header header{font-size:28px; text-align:center; padding-bottom:28px;color:#B5925C;}
				local p p{white-space:normal; font-family:`font';}
				}
			}
		
		
		
		
		
	if "`css'" ~= "" {	
			*> body
			local general body, code, div, span {font-family:`font'}
			local body body{padding:20px 3% 0 3%; }
			local header header{font-size:28px; text-align:center; padding-bottom:28px;}
			local code .code{background-color:#EBEBEB;display:block; ///
			padding:10px; font-size:`size'px; font-family:`cfont'}
			local output .output{display:block; white-space:pre; font-size:`size'px;font-family:`font'}
			local p p{white-space:normal; font-family:`font'}
				
			}
		
		
		
		if "`style'" ~= "cobalt" &  "`style'" ~= "cob" & ///
		"`style'" ~= "imbi" &  ///
		"`style'" ~= "blackforest" & "`style'" ~= "bl" & ///
		"`style'" ~= "desert" & "`style'" ~= "des" & ///
		"`style'" ~= "sunset" & "`style'" ~= "sun" & ///
		"`style'" ~= "midnight" & "`style'" ~= "mid" & ///
		"`style'" ~= "daring" & "`style'" ~= "dar" & ///
		"`style'" ~= "" & "`style'" ~= "stata" & "`style'" ~= "Stata" & ///
		"`style'" ~= "st" {
				di as error "{p}{bf:`style'} style was not found. The available styles are {bf:stata}, {bf:daring}, {bf: midnught}, {bf:sunset}, {bf:imbi}, or {bf:cobalt} is expected{smcl}"
				exit 198
				}
				
				
				
				
				
		********************************************************************
		*CORRECTING THE SMCL LOG FILE
		********************************************************************		
		qui copy `input' `corrected', replace
	
		tempname hitch canvas 
		file open `hitch' using `"`input'"', read
		file open `canvas' using `"`corrected'"', write replace
		file read `hitch' line
		while r(eof) == 0 {						
				
				local word1 : word 1 of `"`macval(line)'"'
				
				*>removing indents 
				foreach i of numlist 64/0  {						
						local indent : di _dup(`i') " "
						local b = `i'+1
						
						*removing the indents after ">"				
						if substr(`"`macval(word1)'"',1,2) == "> " {						
								local indent : di _dup(`b') " "
								local line : subinstr local line ///
								`">`indent'"' ">", all
								}
								
								
						*Indents after after "."
						if substr(`"`macval(word1)'"',1,`b') == ".`indent'" ///
						& `"`line'"' >= ".`indent'" {
								local line : subinstr local line ///
								`".`indent'"' ".", all
								}
						
						*Indents after after "{com}."
						local b = `i'+7
						if substr(`"`macval(word1)'"',1,`b') == "{com}. `indent'" {
								cap local line : subinstr local line ///
								"{com}. `indent'" "{com}. ", all
								}
						}
						
				*> replacing the "dots" with "{com}. "
				if substr(`"`macval(word1)'"',1,1) == "." & `"`line'"' > "." {	
						local h : di substr(`"`macval(line)'"',2,.) 
						local line `"{com}. `macval(h)'"'
						}
				
				
				file write `canvas' `"`macval(line)'"' _n 
				file read `hitch' line
				
				}
				
		file close `canvas'
		file close `hitch'
		
	
		********************************************************************
		*TRANSLATING SMCL to HTML
		********************************************************************
		qui log html `corrected' `html', `replace'		

		if "`erase'" == "erase" {
				cap qui erase `input'
				}
		
		cap qui erase `corrected'

		
		********************************************************************
		*PROCESSING THE HTML FILE
		********************************************************************
		*APPENDING LONG LINES
		qui copy `html' `tempfile', replace
		
		tempname hitch canvas 
		file open `hitch' using `"`tempfile'"', read
		file open `canvas' using `"`html'"', write replace
		file read `hitch' line
		while r(eof) == 0 {						
				local word1 : word 1 of `"`line'"'
				
				local line : subinstr local line "<pre>" "", all
				local line : subinstr local line "</pre>" "", all
				
				
				****************************************************************
				*REMOVING THE LINES THAT ONLY HAVE DOTS
				****************************************************************
				*REMOVING LINES THAT ARE ONLY A DOT
				if `"`line'"' == "." {
						local line : subinstr local line "." " "
						}
				
				if `"`line'"' == ". " {
						local line : subinstr local line ". " "  "
						}
						
				if substr(`"`word1'"',1,4) == "&gt;" {
						local line : subinstr local line `"&gt;"' `"<br />"'
						}
/*				
				local word1 : word 1 of `"`macval(line)'"'
				while substr(`"`word1'"',1,2) == ". " {
						local host `"`macval(line)'"'
						file read `hitch' line
						local word1 : word 1 of `"`macval(line)'"'
						while substr(`"`word1'"',1,4) == "&gt;" {
								local line : di substr(`"`macval(line)'"',5,.)
								local host `"`macval(host)' `macval(line)'"'
								file read `hitch' line
								local word1 : word 1 of `"`macval(line)'"'
								}
						
						file write `canvas' `"`macval(host)'"' _n
						
						}
*/				
				file write `canvas' `"`macval(line)'"' _n 
				file read `hitch' line
				
				}
				
		file close `canvas'
		file close `hitch'
		

	
		
		*COMMANDS WITH BRACE
		qui copy `html' `tempfile', replace
		
		tempname hitch canvas 
		file open `hitch' using `"`tempfile'"', read
		file open `canvas' using `"`html'"', write replace
		file read `hitch' line
		
		while r(eof) == 0 {
		
				local word1 : word 1 of `"`line'"'
				
				if substr(`"`word1'"',1,2) == ". " {
				
						if substr(`"`word1'"',-2,.) == " {" | ///
						substr(`"`word1'"',-2,.) == "{ " | ///
						substr(`"`word1'"',-2,.) ~= " {" & ///
						substr(`"`word1'"',-2,.) ~= "{ " & ///
						substr(`"`word1'"',-1,.) == "{"  {
								
								local host `"`macval(line)'"'
						
								file read `hitch' line
								local word1 : word 1 of `"`line'"'
						
								
								*jump over empty line
								if `"`line'"' == "<p>" | `"`line'"' == "."  {
										file read `hitch' line
										local word1 : word 1 of `"`line'"'
										}
								

								while substr(`"`word1'"',1,2) == "  " & ///
								substr(`"`word1'"',1,3) ~= "   " {
										local host `"`macval(host)'"'`"<br />"'`"`macval(line)'"'
										file read `hitch' line
										local word1 : word 1 of `"`line'"'
										}
						
								*if there are more than 9 lines...
								if substr(`"`word1'"',1,4) == " 10." {
										while substr(`"`word1'"',1,1) == " " & ///
										substr(`"`word1'"',1,2) ~= "  " {
												local host `"`macval(host)'"'`"<br />"'`"`macval(line)'"'
												file read `hitch' line
												local word1 : word 1 of `"`line'"'
												}
										}

										
										
								file write `canvas' `"`macval(host)'"' _n
								file write `canvas' `"`macval(line)'"' _n
						
								file read `hitch' line
								local word1 : word 1 of `"`line'"' 
								}
						}

				file write `canvas' `"`macval(line)'"' _n
				file read `hitch' line
				}
				
		file close `canvas'
		file close `hitch'
		
		
	
		
		********************************************************************
		*REPLACING QUOTES
		********************************************************************
		qui copy `html' `tempfile', replace
		tempname hitch canvas 
		file open `hitch' using `"`tempfile'"', read
		file open `canvas' using `"`html'"', write replace
		file read `hitch' line
		while r(eof) == 0 {
				local word1 : word 1 of `"`line'"'
				if substr(`"`word1'"',1,2) == ". " {
						local line : subinstr local line ///
						`"""' `"&quot;"', all
						}
				
				/* FIXING THE COMMENTS */
				if substr(`"`word1'"',1,4) == ". /*" {
						local line : subinstr local line ///
						`". /*"' `"<p class="comment">/*"', all
						}	
				
				local line : subinstr local line `"*/"' `"*/</p>"', all
				
				*REMOVE QUI LOG C
				local line : subinstr local line ". qui log c" "", all
				
				file write `canvas' `"`macval(line)'"' _n
				file read `hitch' line
				}
				
		file close `canvas'
		file close `hitch'
		
		
			
		
		*PART 5: HANDLING THE COMMENTS
		qui copy `html' `tempfile', replace
		
		tempname hitch canvas 
		file open `hitch' using `"`tempfile'"', read
		file open `canvas' using `"`html'"', write replace
		file read `hitch' line
	
	
		while r(eof) == 0 {						
				
				local word1 : word 1 of `"`line'"'
				
				*DEFINING "///" "//" "{" "}" "
				if substr(`"`word1'"',1,2) == ". " & `"`line'"' > ". " {
								
						local line : subinstr local line ///
						"///" `"<span class="comment">///</span><br />"', all
						
						local line : subinstr local line ///
						" // " `" <span class="comment">//</span> "', all
					
						local line : subinstr local line ///
						"{" "<span class=brace>{</span>", all
								
						local line : subinstr local line "}" ///
						"<span class=brace>}</span>", all
							
						/* CREATING THE MACRO COLOR */
						local line : subinstr local line ///
						"`" "<span class=macro>`" , all
						
						local line : subinstr local line ///
						"'" "'</span>" , all


	
		
						
						/* COMMAND HIGHLIGHT */
						* some lines end with a command, add a " " at the end
						*> of the line...
						foreach com of global synlightlist {
								
								local a : di length("`com'")
								local a = -`a'
								if substr(`"`lone'"',`a',.) == "`com'" { 
										local line : subinstr local line " `com'" ///
										`" <span class="command">`com'</span>"', all
										}
										
								else {
										local line : subinstr local line " `com' " ///
										`" <span class="command">`com'</span> "', all
										}
								}		
						
						/* FUNCTIONS HIGHLIGHT */
						foreach fun of global synfunclist {
								*removing the parentheses
								local a : di length("`fun'")
								local a = `a'-1
								local a : di substr("`fun'",1,`a')
								local line : subinstr local line " `fun'" ///
								`" <span class="function">`a'</span>("', all
								}
						
						
						/* NUMBERS HIGHLIGHT */
						foreach word of local line {
						
								local word2 `"`macval(word)'"'
						
								if substr(`"`macval(word)'"', 1, 1) == "." | ///
								   substr(`"`macval(word)'"', 1, 1) == "/" | ///
								   substr(`"`macval(word)'"', 1, 1) == "(" | ///
								   substr(`"`macval(word)'"', 1, 1) == "[" | ///
								   substr(`"`macval(word)'"', 1, 1) == "+" | ///
								   substr(`"`macval(word)'"', 1, 1) == "-" | ///
								   substr(`"`macval(word)'"', 1, 1) == "0" | ///
								   substr(`"`macval(word)'"', 1, 1) == "1" | ///
								   substr(`"`macval(word)'"', 1, 1) == "2" | ///
								   substr(`"`macval(word)'"', 1, 1) == "3" | ///
								   substr(`"`macval(word)'"', 1, 1) == "4" | ///
								   substr(`"`macval(word)'"', 1, 1) == "5" | ///
								   substr(`"`macval(word)'"', 1, 1) == "6" | ///
								   substr(`"`macval(word)'"', 1, 1) == "7" | ///
								   substr(`"`macval(word)'"', 1, 1) == "8" | ///
								   substr(`"`macval(word)'"', 1, 1) == "9" {
											
											foreach num of numlist 0 1 2 3 4 5 6 7 8 9 {
													local word : subinstr local word "`num'" ///
													`"<span class="digit">`num'</span>"', all
													}
						
											local line : subinstr local line `"`word2'"' `"`word'"'  
											}
									}
									
								
						/* OPERATORS HIGHLIGHTING */
						local signlist + - &gt;= &gt; &lt;= &lt; &amp; | == / = * %  ^  :
						foreach sn of local signlist {
								local line : subinstr local line " `sn' " ///
								`" <span class="sign">`sn'</span> "', all
								}

						}
				

						
				
				
				file write `canvas' `"`macval(line)'"' _n 
				file read `hitch' line
		
				}
				
		file close `canvas'
		file close `hitch'		
				

	
		*PART 6: HANDLING THE COMMANDS AND OUTPUTS
		qui copy `html' `tempfile', replace
		
		tempname hitch canvas 
		file open `hitch' using `"`tempfile'"', read
		file open `canvas' using `"`html'"', write replace
		file read `hitch' line
	
	
		while r(eof) == 0 {						
				
				local word1 : word 1 of `"`line'"'

				/* DEFINE STATA COMMANDS */
				if substr(`"`word1'"',1,2) == ". " & `"`line'"' > ". "{
						local line : subinstr local line ". " ""
						file write `canvas' `"<code class="code">"'`"`macval(line)'"'`"</code>"' _n
						
						file write `canvas' `"<div class="output">"' _n
						file read `hitch' line
						}
				
				/* DEFINE STATA OUTPUT */
				if `"`line'"' == ". " {
						local line : subinstr local line ///
						". " `"</div>"', all
						}
						
				
				*>> define the output
				if `"`line'"' == "<p>" {
						local line : subinstr local line "<p>" "", all
						}
						
				file write `canvas' `"`macval(line)'"' _n 
				file read `hitch' line
				
				}
				
		file close `canvas'
		file close `hitch'		
		
	
		
	*REMOVING EMPTY LINES
	qui copy `html' `tempfile', replace
		
		tempname hitch canvas 
		file open `hitch' using `"`tempfile'"', read
		file open `canvas' using `"`html'"', write replace
		file read `hitch' line
		while r(eof) == 0 {						
				local word1 : word 1 of `"`line'"'				
				
				
				*JUMP OVER EMPTY LINE
				if `"`line'"' == "" {
						local host `"`line'"'
						file read `hitch' line
						local word1 : word 1 of `"`line'"'
						
						if `"`line'"' == "</div>" {
								file write `canvas' `"`macval(line)'"' _n
								file read `hitch' line
								local word1 : word 1 of `"`line'"'
								}
						}
				
				if substr(`"`word1'"',1,20) == `"<div class="output">"' {

						local host `"`line'"'					
						
						file read `hitch' line
						local word1 : word 1 of `"`line'"'
						
						*IF THE NEXT LINE HAS NO OUTPUT, REMOVE IT
						if substr(`"`word1'"',1,19) == `"<code class="code">"' {
								file read `hitch' line
								local word1 : word 1 of `"`line'"'
								}

						
						*JUMP OVER EMPTY LINE
						if `"`line'"' == "" {
								file read `hitch' line
								local word1 : word 1 of `"`line'"'
								}
						
						if substr(`"`word1'"',1,19) ~= `"<code class="code">"' & `"`line'"' ~= "" {
						 
								file write `canvas' `"`macval(host)'"' _n
								}
								
						file write `canvas' `"`macval(line)'"' _n
						file read `hitch' line
						}
				
				file write `canvas' `"`macval(line)'"' _n 
				file read `hitch' line
				}
		file close `canvas'
		file close `hitch'
				
	
		
		
		
		********************************************************************
		*STRING (QUOTE) SYNTAX HIGHLIGHT
		********************************************************************
		qui copy `html' `tempfile', replace
		
		tempname hitch canvas 
		file open `hitch' using `"`tempfile'"', read
		file open `canvas' using `"`html'"', write replace
		file read `hitch' line
		while r(eof) == 0 {						
				local word1 : word 1 of `"`line'"'
				
				
				
				if substr(`"`macval(word1)'"',1,19) == `"<code class="code">"' {
						
						forval i = 1/20 {

								local line = subinstr(`"`macval(line)'"', ///
								"&quot;",`"<span class="string">""',1)
				
								local line = subinstr(`"`macval(line)'"', ///
								"&quot;",`""</span>"',1)  
								}
						}	
				
				
				file write `canvas' `"`macval(line)'"' _n 
				file read `hitch' line
				}
		file close `canvas'
		file close `hitch'
		
		
	
		
		********************************************************************
		*GLOBAL MACRO SYNTAX HIGHLIGHT
		********************************************************************
		qui copy `html' `tempfile', replace
		
		tempname hitch canvas 
		file open `hitch' using `"`tempfile'"', read
		file open `canvas' using `"`html'"', write replace
		file read `hitch' line
		while r(eof) == 0 {						
				
				local word1 : word 1 of `"`line'"'
				
				if substr(`"`word1'"',1,19) == `"<code class="code">"'  { 
				
						local line : subinstr local line "$" "&#36;", all
				
						local b  `"`macval(line)'"'
						
						foreach word of local line {
						
								if substr(`"`word'"', 1, 5) == "&#36;" {
								
										local b : di subinstr(`"`macval(b)'"',`"`macval(word)'"', ///
										`"<span class="macro">`macval(word)'</span>"',1)
														}
								}
						
								
						local line  `"`macval(b)'"'
						}		
				
				file write `canvas' `"`macval(line)'"' _n 
				file read `hitch' line
				}
		file close `canvas'
		file close `hitch'
	
	
	
	
	
	
	
		********************************************************************
		*CREATING THE HTML FILE
		********************************************************************
		qui copy `html' `tempfile', replace
		
		tempname hitch canvas 
		file open `hitch' using `"`tempfile'"', read
		file open `canvas' using `"`html'"', write replace
		
		file write `canvas' `"<!doctype html>"' _newline
		file write `canvas' `"<html>"' _newline
		file write `canvas' `"<head>"' _newline
		file write `canvas' `"<meta charset="UTF-8">"' _newline ///
		`"<meta name="keywords" content="Stata-blog.com, reproducible research, Stata, Syntax highlighter, Stata CSS">"' _n ///
		`"<meta name="Website" content="http://www.stata-blog.com">"' _n ///
		`"<meta name="author" content="E. F. Haghish">"' _n
		
		file write `canvas' `"<title>`title'</title>"' _newline
		

		file write `canvas' `"<style type="text/css">"' _newline
	if "`css'" == "" {			
		file write `canvas' "`command'" _newline
		file write `canvas' "`function'" _newline
		file write `canvas' "`macro'" _newline
		file write `canvas' "`string'" _newline
		file write `canvas' "`digit'" _newline 
		file write `canvas' "`comment'" _newline 
		file write `canvas' "`brace'" _newline 
		file write `canvas' "`sign'" _newline 
		file write `canvas' "`error'" _newline 
			}
			
		file write `canvas' "`code'" _newline 
		file write `canvas' "`output'" _newline 
		file write `canvas' `"`general'"' _newline 
		file write `canvas' "`body'" _newline 
		file write `canvas' "`header'" _newline 
		file write `canvas' "`p'" _newline 
		
		file write `canvas' ".string > .macro {`overstring'}" _newline
		file write `canvas' ".string > .digit {`overstring'}" _newline
		file write `canvas' ".string > .command {`overstring'}" _newline
		file write `canvas' ".string > .function {`overstring'}" _newline(2)

		file write `canvas' ".comment > .macro {`overcomment'}" _newline
		file write `canvas' ".comment > .digit {`overcomment'}" _newline
		file write `canvas' ".comment > .command {`overcomment'}" _newline
		file write `canvas' ".comment > .string {`overcomment'}" _newline
		file write `canvas' ".comment > .function {`overcomment'}" _newline(2)
		
		file write `canvas' "</style>" _n(4)
		
	if "`css'" ~= "" {
		file write `canvas' `"<link rel="stylesheet" href="`css' />"'
		}
		
		file write `canvas' "</head>" _newline
		
		file write `canvas' "<body>" _newline
		file write `canvas' `"<header>`title'</header>"' _newline
		
		file read `hitch' line
	
		while r(eof) == 0 {						
				
				local word1 : word 1 of `"`line'"'
				file write `canvas' `"`macval(line)'"' _n 
				file read `hitch' line
	
				}
		
		file write `canvas' "</body>" _newline
		file write `canvas' "</html>" _newline
		file close `canvas'
		file close `hitch'	
	
	
	cap qui erase `tempfile'
	
	di _n(4)
	di as txt " (~|_|._ | o(~||_ _|_"
	di as txt " _) _|| ||_| _|| | |  created "`"{bf:{browse "`html'"}} "' _n(2)"
	
	
	* drop wordlist macros
	macro drop synlightlist
	macro drop synfunclist
	
	
	*check for synlight updates
	synlightversion
	
	end	

	
