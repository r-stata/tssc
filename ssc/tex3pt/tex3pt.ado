program tex3pt
*! version 3.1 Derek Wolfson 5dec2018
syntax [anything(name=table id="tex table")] using/, ///
	[replace] [TITLE(string) TLABel(string) NOTE(string asis)] ///
	[FONT(string) MATHFONT(string) FONTSIZE(string)  CWIDTH(string) WIDE] /// OPTIONS REQ. SUBSEQUENT LOCALS
	[PREamblea(str asis) PREambleb  ENDdoc PACKage(string) PAGE LANDscape CLEARpage COMPile STARs(string) MARGins(string) RELATIVEpath(string) FLOATPLACEMENT(string)] //

version 12

	**CREATE LOCALS FOR USING AND TABLE SINCE THEY WILL BE CLEARED BY SUBSEQ. SYNTAX CALLS*
	local table1 : copy loc table
	local using1 : copy loc using

	**IF PAGE IS SELECTED THEN TURN ON REPLACE PREAMBLE ENDDOC**
	if "`page'"!=""{
		local replace "replace"
		local preambleb "preambleb"
		local enddoc "enddoc"
	}

	** ERROR if package is added without preamble
	if "`package'"!="" & "`preambleb'"=="" & "`preamblea'"==""{
	di as error "Syntax error: Must include option option -preamble- if option -package-  is selected"
	exit 198
	}

	**CREATE ERROR IF COMPILE IS USED BUT ENDDOC IS NOT**
	if "`compile'"!="" & "`enddoc'"==""{
	di as error "Syntax error: Must include option -enddoc- if option -compile- is selected"
	exit 198
	}

	**CREATE ERROR IF PREAMBLE IS USED BUT REPLACE IS NOT**
	if "`preamblea'"!="" & "`replace'"==""{
	di as error "Syntax error: Must include option -replace- if option -preamble- is selected"
	exit 198
	}

	if "`preambleb'"!="" & "`replace'"==""{
	di as error "Syntax error: Must include option -replace- if option -preamble- is selected"
	exit 198
	}

	**CREATE ERROR IF MFONT OR FONT IS USED BUT PREAMBLE IS NOT**
	if "`preamblea'"=="" & "`preambleb'"=="" & "`font'"!="" & "`mfont'"!=""{
	di as error "Syntax error: Must include option -preamble- if option -font- or -mfont- is selected"
	exit 198
	}

	if "`preamblea'"=="" & "`preambleb'"=="" & "`font'"!=""{
	di as error "Syntax error: Must include option -preamble- if option -font- is selected"
	exit 198
	}

	if "`preamblea'"=="" & "`preambleb'"=="" & "`mfont'"!=""{
	di as error "Syntax error: Must include option -preamble- if option -mfont- is selected"
	exit 198
	}

	if "`preamblea'"=="" & "`preambleb'"=="" & "`enddoc'" == "" &  `"`table1'"'==`""'{
	di as error "If -table- is not used, then preamble or enddoc must be selected"
	exit 198
	}

	**PREAMBLE OPTIONS**
		**LIST: INCLUDE LIST OF TABLES AT TOP OF DOCUMENT**
		local list = regexm("`preamblea'", "list")
			if `list'==0{
				local listtablelist ""
			}
			if `list'==1{
			local listtablelist "\listoftables\clearpage"
			}

		*FOOTER: INFORMATION ABOUT CREATOR AND CREATION DATE
		local footer = regexm("`preamblea'", "info")
		if `footer'==0 & `list'==1{
			local footinfo ""
		}
		if `footer'==1 & `list'==1{
			local footinfo "\thispagestyle{firststyle}"
		}

		**REPLACE PREAMBLEB LOCAL IF PREAMBLEA IS SPECIFIED CORRECTLY**
		if "`preamblea'"!=""{
			local preambleb preambleb
		}



	**FONT OPTION**
	loc 0 : copy loc font
	syntax [anything(name=fontname)], [FOPT(string)]

		if "`fontname'"==""{
			local textfont `"%DEFAULT"'
		}
		if "`fontname'"!="" & "`fopt'"==""{
			local textfont `"\usepackage{`fontname'}"'
		}
		if "`fontname'"!="" & "`fopt'"!=""{
			local textfont `"\usepackage[`fopt']{`fontname'}"'
		}
	**END FONT OPTION**

	**MFONT OPTION**
	loc 0 : copy loc mathfont
	syntax [anything(name=mfontname)], [MFOPT(string)]

		if "`mfontname'"==""{
			local mfont `"%DEFAULT"'
		}
		if "`mfontname'"!="" & "`mfopt'"==""{
			local mfont `"\usepackage{`mfontname'}"'
		}
		if "`mfontname'"!="" & "`mfopt'"!=""{
			local mfont `"\usepackage[`mfopt']{`mfontname'}"'
		}
	**END MFONT OPTION**
	
**OPTIONS STORED IN LOCALS**
	**MARGIN SIZE**
	if "`margins'"!=""{
	local MARGINSIZE  "`margins'"
	}
	else{
	local MARGINSIZE  "1.5cm"
	}

	**Package**
	if "`package'"!=""{
	local PACKAGELIST  "`package'"
	}
	else{
	local PACKAGELIST  ""
	}

	**FONTSIZE OPTION**
	if "`fontsize'"==""{
		local fontsizechoice "\normalsize"
		local notefontsize "\footnotesize"
	}
	else if "`fontsize'"=="scriptsize"{
		local fontsizechoice "\scriptsize"
		local notefontsize "\scriptsize"
	}
	else if "`fontsize'"=="tiny"{
		local fontsizechoice "\tiny"
		local notefontsize "\tiny"
	}
	else if "`fontsize'"!=""{
		local fontsizechoice "\\`fontsize'"
		local notefontsize "\footnotesize"
	}
	**END FONTSIZE OPTION**

	**M(ath)FONT OPTION**
		tokenize "`mfont'", parse(",")
		local mathchoice1 `1'
		local mathchoice2 `3'

		if "`font'"==""{
			local mathfont "%DEFAULT"
		}
		if "`mathchoice1'"!="" & "`mathchoice2'"==""{
			local mathfont "\usepackage{`fontchoice1'}"
		}
		if "`mathchoice1'"!="" & "`mathchoice2'"!=""{
			local mathfont "\usepackage[`mathchoice2']{`mathchoice1'}"
		}
	**END M(ath)FONT OPTION**

	**TABLE LABEL OPTION**
	if "`tlabel'"==""{
		local tablelabel ""
	}
	else{
		local tablelabel "\label{`tlabel'}"
	}
	**END TABLE LABEL OPTION**



	**C(olumn) WIDTH*
	if "`cwidth'"==""{
		local columnwidth = ""
	}
	else{
		local columnwidth = ",table-column-width=`cwidth'"
	}

	**STARS**
	if "`stars'"==""{
		local starnote ""
	}
	else if "`stars'"=="ols"{
		local starnote "\Figtext{{`notefontsize' Standard errors in parentheses. *~\${p<.10}$, **~\${p<.05}$, ***~\${p<.01}$.}}"
	}
	else if "`stars'"=="robust"{
		local starnote "\Figtext{{`notefontsize' Heteroskedasticity-robust standard errors in parentheses. *~\${p<.10}$, **~\${p<.05}$, ***~\${p<.01}$.}}"
	}
	tokenize "`stars'"
	local stars1 `1'
	local stars2 `2'
	local stars2: subinstr local stars2 "_" "\textunderscore "
	else if "`stars1'"=="cluster"{
		local starnote "\Figtext{{`notefontsize' Standard errors clustered by `stars2' in parentheses. *~\${p<.10}$, **~\${p<.05}$, ***~\${p<.01}$.}}"
	}
	else {
	di as error "Syntax error: stars option undefined.  Stars option must be either ols, robust or cluster clustervar."
	exit 198
	}

	**END STARS**

	**WIDE TABLE**
	if "`landscape'"==""{
		if "`wide'"!=""{
			local outputtype "wide"
		}
		else{
			local outputtype "auto"
		}
	}
	if "`landscape'"!=""{
		if "`wide'"!=""{
			local outputtype "wideland"
		}
		else{
			local outputtype "auto"
		}
	}

**CHANGE \ to / FOR LATEX INPUT**
	local table1: subinstr local table1 "\" "/", all
	local using1: subinstr local using1 "\" "/", all

**CHANGE LOCALS TO NOT INCLUDE .tex**
	local using1: subinstr local using1 ".tex" "", all
	local table1: subinstr local table1 ".tex" "", all
	local table1: subinstr local table1 `"""' "", all
	local table1 "`table1'.tex"


**CREATE LOCAL FOR NUMBER OF COLUMNS & NUMBER OF DIGITS BEFORE AND AFTER DECIMAL POINT**
if "`table1'" != ".tex"{ // only run if table is specified
	get_params, table("`table1'")
	loc NUMBEROFCOLUMNS = r(NUMBEROFCOLUMNS)
	loc N_ALIGN = `NUMBEROFCOLUMNS'+1
	*loc DIGITSBEFOREDECIMAL = r(COUNT1)
	*loc DIGITSAFTERDECIMAL = r(COUNT2)

	forvalues i = 2 / `N_ALIGN'{
	loc DBEFOREDEC	= r(COL`i'_C1)
	local DAFTERDEC = r(COL`i'_C2)
		if r(COL`i'_STARS) == 3{
			local STARSPACE = ",table-space-text-post=***"
		}
		else if r(COL`i'_STARS) == 2{
			local STARSPACE = ",table-space-text-post=**"
		}
		else if r(COL`i'_STARS) == 1{
			local STARSPACE = ",table-space-text-post=*"
		}
		else{
			local STARSPACE = ""
		}
	local COLALIGN `COLALIGN' S[table-format=`DBEFOREDEC'.`DAFTERDEC' `STARSPACE' `columnwidth']
	}
}

**CREATE WORKING DIRECTORY LOCALS**
	*CURRENT DIRECTORY*
	local CWD "`c(pwd)'"
	*NEW WORKING DIRECTORY FOR LATEX*"
	mata: st_local("NWD", parent_dir(st_local("using1")))

/* REMOVED IN VERSION
**SUBSTITUTE SPECIAL LATEX CHARACTERS** NOT WORKING FIX THIS LATER
foreach string in title note{
		local `string': subinstr local `string' "\" "\text{\}", all
		local `string': subinstr local `string' "\$" "\\\$", all
	foreach character in "%" "&" "{" "}" "_" "#"{
		local `string': subinstr local `string' "`character'" "\\`character'", all
	}
}
*/

**BREAK NOTE INTO LINES**
tokenize `"`macval(note)'"', parse(",")
local token = 1
local notelines = 1
while "``token''" != "" {
 if "``token''" == "," {
  local ++notelines
 }
 else {
  local note`notelines' "`macval(note`notelines')' `macval(`token')'"
 }
 local ++token
}

**DEFINE TEMPNAME FOR FILE HANDLE**
tempname tex_file
**REPLACE OR APPEND**
cap file close `tex_file'

	if "`replace'"!=""{
	local REPLACEORAPPEND replace
	}
	if "`replace'"==""{
	local REPLACEORAPPEND append
	}

	file open `tex_file' using "`using1'.tex", write `REPLACEORAPPEND'
	file close `tex_file'

*WRITE PREAMBLE IF OPTION IS ON**
	if "`preambleb'"!=""{
	file open `tex_file' using "`using1'.tex", write append
		file write `tex_file' ///
	`"%==============================================%"' _n ///
	`"% Originally written by: `c(username)'"' _n ///
	`"% Originally written on: `c(current_date)' `c(current_time)'"' _n ///
	`"%==============================================%"' _n _n _n ///
	`"\documentclass[11pt]{article}% Your documentclass"' _n ///
	`"\usepackage{verbatim}"' _n ///
	`"\usepackage[margin=`MARGINSIZE']{geometry}"' _n /// USES MARGINSIZE MACRO
	`"\usepackage{dcolumn}"' _n ///
	`"\usepackage{comment}"' _n ///
	`"\usepackage{fancyhdr}"' _n
	if "`PACKAGELIST'"!=""{
		foreach pack of local PACKAGELIST{
			file write `tex_file' ///
			`"\usepackage{`pack'}"' _n
		}
	}

	if `footer' == 1{
		file write `tex_file' ///
	`" \fancypagestyle{firststyle}"' _n ///
     "  { " _n ///
     "   \fancyhf{}" _n ///
     "   \renewcommand{\headrulewidth}{0pt}" _n ///
     "   \fancyfoot[L]{Created by: `c(username)'}" _n ///
     "   \fancyfoot[R]{Created on: `c(current_date)' `c(current_time)'}" _n ///
     "  }" _n _n
	 } //end if footer==1


		file write `tex_file' ///
	`"% Necessary packages"' _n ///
	`"\usepackage[T1]{fontenc}% Must be loaded for proper fontencoding when using pdfLaTeX"' _n ///
	`"\usepackage[utf8]{inputenx}% For proper input encoding"' _n _n ///
	`"% Packages for tables"' _n ///
	`"\usepackage{booktabs}% Pretty tables"' _n ///
	`"\usepackage{threeparttable}% For Notes below table"' _n ///
	`"\usepackage[skip=5pt, justification=centering]{caption}"' _n ///
	`"\usepackage{longtable}"' _n ///
	`"\usepackage{pdflscape}"' _n ///
	`"\usepackage{amsmath}"' _n  ///
	"\usepackage{morefloats}" _n ///
	"%INCLUDE HYPERREF AT END" _n ///
	"\usepackage{hyperref}" _n ///
	"\hypersetup{" _n ///
	"  colorlinks   = true, %Colours links instead of ugly boxes" _n ///
	"  linkcolor    = blue, %Colour of internal links" _n ///
	"}" _n ///
	`"%%NEED THIS TO WORK WITH TABLES%%"' _n ///
	`"	\makeatletter"' _n ///
	"	\edef\originalbmathcode{%" _n ///
	"	    \noexpand\mathchardef\noexpand\@tempa\the\mathcode`\(\relax}" _n ///
	"	\def\resetMathstrut@{%" _n ///
	"	  \setbox\z@\hbox{%" _n ///
	"	    \originalbmathcode" _n ///
	`"	    \def\@tempb##1"##2##3{\the\textfont"##3\char"}%"' _n ///
	"	    \expandafter\@tempb\meaning\@tempa \relax" _n ///
	"	  }%" _n ///
	"	  \ht\Mathstrutbox@\ht\z@ \dp\Mathstrutbox@\dp\z@" _n ///
	"	}" _n ///
	"	\makeatother" _n _n ///
	"%TEXTFONT" _n ///
	" \usepackage{mweights}" _n ///
	" `textfont'" _n ///
	"%MATHFONT" _n ///
	" `mfont'" _n ///
	"% *****************************************************************" _n ///
	"% siunitx" _n ///
	"% *****************************************************************" _n ///
	"\newcommand{\sym}[1]{\rlap{#1}} % Thanks to Joseph Wright & David Carlisle" _n ///
	"" _n ///
	"\usepackage{siunitx}" _n ///
	"	\sisetup{" _n ///
	"		detect-mode," _n ///
	"		group-digits			= false," _n ///
	"		input-symbols			= ( ) [ ] - +," _n ///
	"		table-align-text-post	= false," _n ///
	"		input-signs             = ," _n ///
	"        }	" _n _n ///
	"% Character substitution that prints brackets and the minus symbol in text mode. Thanks to David Carlisle" _n ///
	"\def\yyy{%" _n ///
	"  \bgroup\uccode" "`" "\~\expandafter" "`\string-%" _n ///
	"  \uppercase{\egroup\edef~{\noexpand\text{\llap{\textendash}\relax}}}%" _n ///
	"  \mathcode\expandafter""`""\string-"`""8000 }"' _n _n ///
	"\def\xxxl#1{%" _n ///
	"\bgroup\uccode""`""\~\expandafter""`""\string#1%" _n ///
	"\uppercase{\egroup\edef~{\noexpand\text{\noexpand\llap{\string#1}}}}%" _n ///
	"\mathcode\expandafter""`""\string"`"#1"8000 }"' _n _n ///
	"\def\xxxr#1{%" _n ///
	"\bgroup\uccode""`""\~\expandafter""`""\string#1%" _n ///
	"\uppercase{\egroup\edef~{\noexpand\text{\noexpand\rlap{\string#1}}}}%" _n ///
	"\mathcode\expandafter""`"`"\string#1"8000 }"' _n _n ///
	"\def\textsymbols{\xxxl[\xxxr]\xxxl(\xxxr)\yyy}" _n ///
	"% *****************************************************************" _n ///
	"% Estout related things" _n ///
	"% *****************************************************************" _n ///
	"\let\estinput=\input % define a new input command so that we can still flatten the document" _n ///
	"" _n ///
	"\newcommand{\estwide}[3]{" _n ///
	"		\vspace{.75ex}{" _n ///
	"			\textsymbols" _n ///
	"			\begin{tabular*}" _n ///
	"			{\textwidth}{@{\hskip\tabcolsep\extracolsep\fill}l*{#2}{#3}}" _n ///
	"			\toprule" _n ///
	"			\estinput{#1}" _n ///
	"			\bottomrule" _n ///
	"			\addlinespace[0.75ex]" _n ///
	"			\end{tabular*}" _n ///
	"			}" _n ///
	"		}	" _n ///
	"" _n ///
	"\newcommand{\estwideland}[3]{" _n ///
	"		\vspace{.75ex}{" _n ///
	"			\textsymbols" _n ///
	"			\begin{tabular*}" _n ///
	"			{\linewidth}{@{\hskip\tabcolsep\extracolsep\fill}l*{#2}{#3}}" _n ///
	"			\toprule" _n ///
	"			\estinput{#1}" _n ///
	"			\bottomrule" _n ///
	"			\addlinespace[0.75ex]" _n ///
	"			\end{tabular*}" _n ///
	"			}" _n ///
	"		}	" _n ///
	"" _n ///
	"\newcommand{\estauto}[3]{" _n ///
	"		\vspace{.75ex}{" _n ///
	"			\textsymbols" _n ///
	"			\begin{tabular}{l*{#2}{#3}}" _n ///
	"			\toprule" _n ///
	"			\estinput{#1}" _n ///
	"			\bottomrule" _n ///
	"			\addlinespace[.75ex]" _n ///
	"			\end{tabular}" _n ///
	"			}" _n ///
	"		}" _n ///
	"" _n ///
	"% Allow line breaks with \\ in specialcells" _n ///
	"\newcommand{\specialcell}[2][c]{%" _n ///
	"    \begin{tabular}[#1]{@{}c@{}}#2\end{tabular}" _n ///
	"}" _n ///
	"" _n ///
	"% *****************************************************************" _n ///
	"% Custom subcaptions" _n ///
	"% *****************************************************************" _n ///
	"% Note/Source/Text after Tables" _n ///
	"% The new approach using threeparttables to generate notes that are the exact width of the table." _n ///
	"\newcommand{\Figtext}[1]{%" _n ///
	"	\begin{tablenotes}[para,flushleft]" _n ///
	"	{" _n ///
	"	#1" _n ///
	"	}" _n ///
	"	\end{tablenotes}" _n ///
	"	" _n ///
	"	}" _n ///
	"% *****************************************************************" _n ///
	"% END PREAMBLE" _n ///
	"% *****************************************************************" _n _n  ///
	"\begin{document}" _n ///
	"`footinfo'" _n ///
	"`listtablelist'" _n _n _n _n ///
	"%=================================================%" _n ///
	"%============BEGIN TABLE OUTPUT===================%" _n ///
	"%=================================================%" _n
	file close `tex_file'
	}
***END PREAMBLE***


**INCLUDE TABLE**
if "`table1'" != ".tex"{
file open `tex_file' using "`using1'.tex", write append
file write `tex_file' ///
	"%==================BEGIN TABLE=================%" _n ///
	"%= `macval(title)' =%" _n 																/// USES TITLE MACRO HERE
	"%==============================================%" _n ///

	**INCLUDE LANDSCAPE OPENING**
	if "`landscape'"!=""{
	file write `tex_file' ///
		"\begin{landscape}" _n _n
	}

	**USE RELATIVE PATH FOR TABLE REFERENCE**
	if "`relativepath'"!=""{
		_getfilename "`table1'"
		local table1 "`relativepath'`r(filename)'"
	}

	**CREATE FLOAT PLACEMENT MACRO
	if "`floatplacement'" != ""{
		local fplace "[`floatplacement']"
	}
	else{
		local fplace ""
	}

	file write `tex_file' ///
		"\begin{table}`fplace'\centering""`fontsizechoice'" _n 								/// USES FONT SIZE MACRO HERE & FLOAT PLACEMENT
		"  \begin{threeparttable}" _n ///
		"    \caption{`tablelabel'`macval(title)'} %%TABLE TITLE" _n 						/// USES TITLE MACRO HERE
		`"    \est`outputtype'{"`table1'"}{`NUMBEROFCOLUMNS'}{`COLALIGN'}"' _n 	/// MACROS: OUTPUTTYPE DIGITSAFTER(BEFORE)DECIMAL COLUMNWIDTH
		`"	`macval(starnote)' "' _n														/// USES STARNOTE MACRO HERE

	**WRITE NOTES**
		forvalues i = 1/`notelines'{
			file write `tex_file' ///
		`"\Figtext{{`notefontsize' `macval(note`i')'}} %%TABLE NOTE"' _n 										// USES NOTE & NOTEFONTSIZE MACRO HERE
			}

	**FINISH TABLE**
		file write `tex_file' ///
			"  \end{threeparttable}" _n ///
		"\end{table}" _n
	file close `tex_file'


	**INCLUDE LANDSCAPE CLOSURE
		if "`landscape'"!=""{
			file open `tex_file' using "`using1'.tex", write append
			file write `tex_file' ///
				"\end{landscape}" _n _n
			file close `tex_file'
		}

	**INCLUDE CLEARPAGE IF OPTION IS SELECTED**
		if "`clearpage'"!=""{
			file open `tex_file' using "`using1'.tex", write append
			file write `tex_file' ///
				"\clearpage" _n
			file close `tex_file'
		}

	**ADD WHITESPACE AND ENDTABLE TO TEX DOCUMENT*
		file open `tex_file' using "`using1'.tex", write append
		file write `tex_file' ///
			"%==================END TABLE=================" _n _n _n _n
		file close `tex_file'

**END INCLUDE TABLE**
}

**ADD \ENDDOCUMENT MARKUP IF OPTION IS SELECTED**
	if "`enddoc'"!=""{
		file open `tex_file' using "`using1'.tex", write append
		file write `tex_file' ///
			"\end{document}" _n
		file close `tex_file'
	}

	**COMPILE COMPLETED TEX DOCUMENT** (THANKS RAYMOND)
	if "`compile'"!=""{
		if "`c(os)'" == "Windows" | "`c(os)'" == "MacOSX" {
			qui cd "`NWD'"
			cap rm "`using1'.pdf"
			*run pdflatex twice for hyperref
			if "`c(os)'" == "Windows" {
				!pdflatex "`using1'.tex" & pdflatex "`using1'.tex"
			}
			else if "`c(os)'" == "MacOSX" {
				!PATH=\$PATH:/usr/local/bin:/usr/texbin:/Library/TeX/texbin ///
					&& pdflatex "`using1'".tex ///
					&& pdflatex "`using1'".tex
			}
			*erase aux files
			cap rm "`using1'.log"
			cap rm "`using1'.aux"
			cap rm "`using1'.lot"
			cap rm "`using1'.out"
			cap rm "`using1'.ttt"

			*.tex and .pdf messages
			di as txt `"(TEX output written to {browse "`using1'.tex"})"'
			cap confirm file "`using1'.pdf"
			if _rc != 0 {
			di as error "(Compile failed - Check pdflatex error or compile manually)"
			}
			else{
			di as txt `"(PDF output written to {browse "`using1'.pdf"})"'
			}
			*change directory back to original
			qui cd "`CWD'"
		}

		else {
			di as txt   `"(TEX output written to {browse "`using1'.tex"})"'
			di as error `"(The tex3pt compile option does not currently support `c(os)' at this time)"'
		}
}
	**IF COMPILE IS NOT SELECTED**
	else {
		di as txt   	`"(TEX output written to {browse "`using1'.tex"})"'
	}
end

**PROGRAM FOR GETTING COLUMN NUMBRS AND DIGITS BEFORE/AFTER
pr get_params, rclass
syntax, table(str)
quietly{
preserve
	cap which chewfile
	if _rc!=0{
	di as error "Tex3pt requires the SSC command chewfile." _n ///
	"Please install chewfile ({stata ssc install chewfile}) and try again."
	exit 162
	}
qui describe
if `r(k)' != 0{
chewfile using "`table'", parse("&") semiclear
}
else{ 
chewfile using "`table'", parse("&") clear
}
local NUM = c(k)
ret sca NUMBEROFCOLUMNS = c(k)-1

**CREATE VARIABLE FOR MAX NUMBER OF STARS PER COLUMN**
forv i=2/`c(k)'{
gen star`i' = .
	replace star`i' = 1 if regexm(var`i',"\\sym{\*}")
	replace star`i' = 2 if regexm(var`i',"\\sym{\*\*}")
	replace star`i' = 3 if regexm(var`i',"\\sym{\*\*\*}")
}
forv i = 2/`NUM'{
qui sum star`i'
ret sca COL`i'_STARS = r(max)
}

**EXTRACT X.Y FOR NUMBER OF DIGITS BEFORE AND AFTER DECIMAL POINT
chewfile using "`table'", parse("&") semiclear
local NUM = c(k)

forvalues i = 2/`c(k)'{
drop if regexm(var`i', "^\\multicolumn")
gen n`i' = regexs(2) if regexm(var`i', "(^|[^0-9.])([0-9]+(\.[0-9]+)?)([^0-9]|$)")
}
drop var*


forvalues i = 2/`NUM'{
	tab n`i'
	if r(N)==0{
		ret sca COL`i'_C1 = 1
		ret sca COL`i'_C2 = 0
	}
	else{
		qui split n`i', parse(.) gen(s`i')
		ret sca COL`i'_C2 = 0
		forv k = 1/`r(nvars)'{
			gen len = length(s`i'`k')
			su len
			ret sca COL`i'_C`k' = r(max)
		 drop len
		}
	}
}

} //end quietly
end



vers 12.1

mata:

string scalar parent_dir(string scalar _path) {
	string scalar parent, child

	pragma unset parent
	pragma unset child
	pathsplit(_path, parent, child)

	return(parent)
}

end
