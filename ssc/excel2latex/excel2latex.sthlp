{smcl}
{* documented: 27aug2015}{...}

{cmd:help excel2latex}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:excel2latex} {hline 2}}Convert Excel table to LaTeX table {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:excel2latex,}[{it:options}]

{marker excel2latexoptions}{...}
{synoptset 20 tabbed}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt sav:ing(["]destfile["],s_options)}} Save the coverted table to {it:destfile}. Note that
         {it: destfile} can contain the directory where it is located. The {it: s_options} specifies how to 
         save the coverted table. It has two options: {opt replace} 
         and {opt append}. {opt replace} will overwrite an existing file or create a new file if the
         "{it:destfile.filetype}" does not exist. {opt append} just writes the converted table to
         the end of the existing file. {p_end}
{synopt :{opt as(filetype)}} Specify the type of file to save, e.g., {it:.txt, tex} or {it:.log}; 
        the default type is {it:.tex}.{p_end}
{synopt :{opt disp:lay}} Display the latex table in the Stata results window. At least one option of {opt sav:ing()}
        and {opt disp:lay} must be specfied. If {opt sav:ing()} is not
        specified but {opt disp:lay} is or {opt sav:ing(destfile,replace} are specified, then the latest table will be
        displayed in the results window; if {opt sav:ing(destfile,append)} is specified, all
        tables contained in the the {it:destfil}, including the latest table will be displayed. {p_end}        
{synopt :{opt us:ing(["]sourcefile[": sheetname],u_options)}} Import the table which is intended to be coverted. 
         {it: u_options} tells Stata the data format of the {it: sourcefile}. Currently, {cmd: excel2latex} 
         supports four types of files: Excel spreadsheet, text (tab delimited), csv and Stata data files. 
         Correspondingly, {it: u_options} has four possible values: {opt excel}, {opt txt}, {opt csv} and {opt dta}. 
         For spreadsheet in Excel, if the {it: sheetname} is not specified, the
         first sheet will be imported to Stata for the conversion, for example, {cmd: using("tables": table 1,excel)} 
         and {cmd: using("tables",excel)} performs the same task if "table 1" is the first sheet of "tables.xls". 
         If two .xlsx and .xls files have the same name, e.g., "tables.xlsx" and "tables.xls", and they are in the 
         same directory, Stata imports the tables in the .xls file when the extension name is not specified in the {opt us:ing()} option. 
         If {opt us:ing()} is not specified or is empty (i.e., {opt us:ing()}), the current active data in 
         the memory will be converted into a LaTeX table. When importing the table in other formats as data
         to Stata, {cmd: excel2latex} removes the empty columns. {p_end}
{synopt :{opt l:andscape}} Set the layout of the table to be landscape; the default is portrait. {p_end}
{synopt :{opt cap:tion(text)}} The title of the table. {p_end}
{synopt :{opt titlec:ell(#1 #2 #3)}} #1 and #2 are the row and column numbers of the cell in which
         the title is located in the spread sheet or data set; #3 is the number of letter from which
         the "real" title starts. For example, if the title in the Excel spreadsheet is "Table 3: 
         Robustness checks", #3 should be 10 because the first 9 letters (including blank space)
         just mark the order of the table, which will be done automatically in Latex. If {opt caption} 
         and {opt titlecell} are both specified, the title in {opt caption()} rather than that 
         in the original {it: sourcefile} will be added to the resulting Latex table. {p_end}
{synopt :{opt lab:el(text)}} The label of the table, which is used to refer to the table 
         in the text of the paper. This can be used only if either {opt titlec:ell()} or {opt cap:tion()}
         is specified.  {p_end}
{synopt :{opt makebox(#)}} The width of the table (as a # multiple of the standard text width); 
         this option is often used in the case where the table width is wider than the standard text 
         width (the default  table width) {p_end}
{synopt: {opt basel:ine(#)}} The line spacing. The default is single line spacing. {p_end}
{synopt: {opt arrray:stretch(#)}} The the space between the rows of the table. The default
         is 1.2. {p_end}       
{synopt :{opt tabpos(text)}} The position of table; it may be {opt h}, {opt t}, {opt b}, {opt H}, 
         {opt !thb} and so on; the default is {opt h}, namely, here; note that to use the position {opt H}, 
         the Latex package {bf:float} should be used {p_end}
{synopt :{opt fonts:ize}} The font size of the text in the table, such as {opt large}, {opt footnotesize}, etc. 
	       The default font size is {opt small}. {p_end} 
{synopt :{opt notefonts:ize}} Specify the font size of the notes. Without using this option, the font size of the note
         is the same as that specified by {opt fonts:ize}. {p_end} 
{synopt :{opt notec:ell(#1 #2,#2 #3,...)}} A table may inclue more than one note.
         #1 and #2 are the numbers of the row and column where the first note is located; #3 and #4 are
         the numbers of the row and column where the second note is located, etc.{p_end}
{synopt :{opt notes:content(string)}} The content of the notes. If this option is specified,
         the content of the notes will replace the content in the row #1 and column #2 (and so on) in Excel 
         spreadsheet (if it is specified by {opt notec:ell()}).{p_end}
{synopt :{opt non:ote}} There is no note for the table regardless of whether {opt notes:content} and {opt notec:ell()}
         are specified. Without this as well as {opt notec:ell()} and 
         {opt notes:content()}, {cmd: excel2latex} will leave the place for note ("Note: ..."),  
         although there may be no note in the original table. {p_end}
{synopt :{opt hline(numlist)}} Draw horizontal lines below the rows specified by {opt hline}. For
         example, {bf: hline(4 10)} means drawing two horizontal lines below rows 4 and 10. {p_end}  
{synopt :{opt dropr:ow(numlist)}} Drop the rows specified by {bf: droprow()}. For example, 
         {bf: dropr(11)} means dropping the 11th row of the original table when coverting it to the
         LaTeX table. {p_end}
{synopt :{opt cola:lignment(alignment[,force])}} Specify the alignment of columns, e.g., {bf: lccc} 
         or {bf: lcc|cc}. The number of alignments specified should be equal to the number of columns.
         If some sophiscated alignment is used here, e.g., {bf: p{2cm}cccc}, it is neccessary to add 
         the otpion {opt force}. {p_end}     
{synopt :{opt multic:olumn(#1 #2 #3 alignment1, #4 #5 #6 alignment2,...)}} #1 and #2 are the numers of the 
         row and column in which the first multi-collumn cell begin, #3 is the number of columns 
         included in the cell, and {it: alignment1} specifies the alignment in the multi-column cell #4, #5, #6 and 
         {it: alignment2} are for the second multi-column cell, and so on. For example, {opt multic(2 2 3 l)}
         means the multi-column cell begins from the seond row and second column, it includes 3 columns
         and the content in the cell should be left aligned. {p_end}  

{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:excel2latex} converts Excel tables to LaTeX tables. The basic idea is to import the 
an Excel table to Stata as a data set and then write the data into an ASCII file in the 
format of a LaTeX table. Altough the main purpose of {cmd: excel2latex} is to covert the 
Excel table to LaTeX table, it also supports tables in .txt, .csv or .dta format. Actually, any data in 
the memory can export into a LaTeX table. Thus, we can just import the data/table
into Stata, make some modification and then export them into a LaTeX table using 
{cmd: excel2latex}. Note that {cmd:excel2latex}
may not be able to create the table exactly as desired, but it can help perform the most 
tedious task involved in making tables in LaTeX. In addition, the LaTeX tables made by 
{cmd: excel2latex} are based on the {cmd: tabularx} package.  To compile the .tex file, 
users should install this package and import it by adding "{bf:\usepackage{tabularx}}" in the preamble. 

{pstd}
There is one point to be noted: If a table contains _, #, $, > and <, {cmd: excel2latex} replaces them with \_, \#, \$, $>$ and $<$, respectively, in the resulting LaTeX table. If there are greek letters and another symbols in the table, users can edit the table either before or after using {cmd: excel2latex}. The example 2 below show how to edit the table using Stata before the conversion.

{synoptline}
{p2colreset}{...}
{pstd}
All the examples below use the ancillary files: "tables.xlsx", "tables.xls", "table 1.dta", "table 2.txt", "table 3.csv".

{title:Example 1: convert a table in Excel spreadsheet to LaTeX}

{phang2}{cmd: excel2latex,using("tables",excel) saving(table,replace) as(tex) titlecell(1 1 9) multicolumn(2 2 3 c, 2 5 3 c) notecell(19 1, 20 1) fonts(footnotesize) makebox(1.1) hline(4) label(summary) notefonts(scriptsize) disp}{p_end}
{phang2}{cmd: excel2latex,using(tables:Table 2,excel) saving(table,append) notecel(49 1, 50 1) fonts(footnotesize) titlec(1 1) hline(4) multicolumn(2 2 2 c, 2 4 2 c) makebox(1.05) nonote label(tb:OLS_Lewbel)}{p_end}

{title:Example 2: import an Excel table into Stata, edit it, and then covert it to a Latex table}

{phang2}{cmd: import excel using "tables.xlsx", clear sheet("tab1")}{p_end}
{phang2}{cmd: rename (_all)(var1 var2 var3 var4 var5 var6)}{p_end}
{phang2}{cmd: cap tostring var4,replace}{p_end}
{phang2}{cmd: replace var4="~"}{p_end}
{phang2}{cmd: foreach i in 2 3 5 6 {c -(}}{p_end}
          {cmd: destring var`i',gen(tmp`i') force}
          {cmd: tostring tmp`i',replace format(%10.2f) force}
          {cmd: replace var`i'=tmp`i' in 1/14 if tmp`i'~="."}
{phang2}{cmd: {c )-}}{p_end}
{phang2}{cmd: drop tmp?}{p_end}

{phang2}{cmd: replace var1=subinstr(var1,"levela","level\textsuperscript{a}",1)}{p_end}
{phang2}{cmd: replace var1=subinstr(var1,"schoolb","school\textsuperscript{b}",1)}{p_end}
{phang2}{cmd: replace var2="\textbf{"+var2+"}" in 2}{p_end}
{phang2}{cmd: replace var5="\textbf{"+var5+"}" in 2}{p_end}
{phang2}{cmd: replace var1="\cline{2-3} \cline{5-6}" + var1 in 3}{p_end}

{phang2}{cmd: foreach i in 2 3 5 6 {c -(}}{p_end}
          {cmd: gen tmp`i'=strpos(var`i',".") in 4/14}
          {cmd: qui sum tmp`i'}
          {cmd: local maxtmp`i'=r(max)}
          {cmd: if `maxtmp`i''>0 {c -(}}
          {cmd:    forvalues j=1/`maxtmp`i'' {c -(}}
          {cmd:       replace var`i'="~"+var`i' if strpos(var`i',".")<`maxtmp`i'' in 4/14}
          {cmd:    {c )-}}
          {cmd: {c )-}}
{phang2}{cmd: {c )-}}{p_end}
{phang2}{cmd: drop tmp?}{p_end}

{phang2}{cmd: local cola=">{\centering\arraybackslash}p{0.3\textwidth}" }{p_end}

{phang2}{cmd: excel2latex, saving(table,append) as(tex) makebox(1.1) titlecell(1 1 9) multicolumn(2 2 2 `cola', 2 5 2 `cola', 15 2 2 c, 15 5 2 c) notecell(16 1) fonts(scriptsize) hline(3 14) label(tab1) notefonts(scriptsize) }{p_end}

{title:Example 3: convert a table in .txt, .csv and .dta files to LaTeX}

{phang2}{cmd: excel2latex,using("table 1",dta) saving(table,append) as(tex) titlecell(1 1 9) multicolumn(2 2 3 c, 2 5 3 c) notecell(19 1, 20 1) fonts(footnotesize) makebox(1.1) hline(4) label(summary) notefonts(scriptsize)}{p_end}

{phang2}{cmd: excel2latex,using("table 2.txt",txt) saving(table,append) notecel(49 1, 50 1) fonts(footnotesize) titlec(1 1) hline(4) multicolumn(2 2 2 c, 2 4 2 c) arraystretch(1.1) notefonts(scriptsize)}{p_end}

{phang2}{cmd: excel2latex,using("table 3",csv) saving(table,append) fonts(footnotesize) titlec(1 1 10) droprow(19 20) notecell(19 1, 20 1) multicolumn(2 2 2 c, 2 4 2 c, 5 1 5 l, 11 1 5 l) hline(4 10)}{p_end}

{synoptline}

{title:Authors}

{phang2}Guochang Zhao{p_end}
{phang2}Research Institute of Economics and Management{p_end}
{phang2}Southwestern University of Finance and Economics {p_end}
{phang2}Chengdu, China{p_end}
{phang2}{browse "mailto:gc_zhao@foxmail.com?subject=NLDECOMPOSE":gc_zhao@foxmail.com}{p_end}

{phang2}Mengmeng Guo{p_end}
{phang2}Research Institute of Economics and Management{p_end}
{phang2}Southwestern University of Finance and Economics {p_end}
{phang2}Chengdu, China{p_end}