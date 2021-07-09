{smcl}
{* *! version 3.1 5dec2018 Derek Wolfson}{...}
{findalias asfradohelp}{...}
{viewerjumpto "Syntax" "tex3pt##syntax"}{...}
{viewerjumpto "Description" "tex3pt##description"}{...}
{viewerjumpto "Options" "tex3pt##options"}{...}
{viewerjumpto "Remarks" "tex3pt##remarks"}{...}
{viewerjumpto "Examples" "tex3pt##examples"}{...}
{title:Title}

{phang}
{bf:tex3pt} {hline 2} creates LaTeX documents from {cmd:esttab} output using the LaTeX package threeparttable.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:tex3pt}
[{it:table}]
{cmd:using} {it:filename}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Table-Specific Options}
{synopt:{opt title}({it:string})} specify a title for the table{p_end}
{synopt:{opt tlab:el}({it:string})} specify a LaTeX label for the table{p_end}
{synopt:{opt note}({it:string})} specify notes for the below the table{p_end}
{synopt:{opt star:s}({it:startype})} include p-value star note below the table {p_end}
{synopt:{opt fontsize}({it:size})} specify text size{p_end}
{synopt:{opt cwidth}({it:width})} specify column width{p_end}
{synopt:{opt wide}} force table to document linewidth {p_end}
{synopt:{opt land:scape}} display table on a landscape page {p_end}
{synopt:{opt floatplacement}({it:placement character})} specify table float placement options {p_end}
{synopt:{opt clear:page}} add \clearpage after table insertion {p_end}


{syntab:LaTeX Document Options}
{synopt:{opt pre:amble}[({it:options})]} write .tex preamble.  Can run without {it:table} input to just create preamble.  See Example 4 for why this is helpful. {p_end}
{synopt:{opt pack:age}({it:packagelist})} adds user specified LaTeX packages to the preamble {p_end}
{synopt:{opt replace}} replace .tex file {p_end}
{synopt:{opt end:doc}} write \end{document} at the end of the .tex file.  Can run without {it:table} input to create just \end{document} tag (see Example 4). {p_end}
{synopt:{opt page}} equivalent to specifying the options preamble, replace and enddoc {p_end}
{synopt:{opt comp:ile}} run pdflatex using shell to output .pdf from .tex file.  Can run without {it:table} input to compile the {it:using} file (see Example 4). {p_end}
{synopt:{opt marg:ins}({it:size})} specify page margins {p_end}
{synopt:{opt relative:path}({it:string})} specify a relative path from the new .tex file to the .tex table {p_end}

{synopt:{opt font}({it:fontpackage}[,fopt({it:packageoptions})])} set text font for LaTeX document {p_end}

{synopt:{opt mathfont}({it:fontpackage}[,mfopt({it:packageoptions})])} set math font for LaTeX document {p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:tex3pt} takes .tex output from {cmd:esttab} and writes it into a LaTeX file using threeparttable. This
greatly improves the level of compatibility between LaTeX and {cmd:esttab}.  Since this program uses the LaTeX package threeparttable
the notes and title of the table will not bleed beyond the width of the table.  Multiple calls of {cmd:tex3pt} allows the user
to compile many tables in a single LaTeX document easily.

{marker options}{...}
{title:Options}

{dlgtab:Table-Specific Options}

{phang}
{opt title}{bf:({it:string})} takes a string argument and inserts it
as the title of the table. For example title(table title)
will insert \caption{table title} inside the threeparttable environment.

{phang}
{opt tlab:el}{bf:({it:string})} takes a string argument and inserts it
as the label for the the table in LaTeX.  For example, tlabel(table1) will
insert \label{table1} within the \caption{} command.

{phang}
{opt note}{bf:({it:string})}  takes a string argument and inserts it as a note
below the table in LaTeX.  The notes will be typeset in \footnotesize unless
size \scriptsize or \tiny is specified in the option fontsize.  If one of these
sizes is selected then the table notes will be typeset in \scriptsize or \tiny, respectively.
To force a line break in the notes insert a comma between notes.  For example,
note("note1", "note2") will insert note1 on one line and note2 on a separate line.
Your notes must be enclosed in quote if they contain a comma.  For example note("Hello,","Mister") will
insert Hello, on one line and Mister on a separate line.

{phang}
{opt star:s}{bf:({it:startype})}  displays the standard p-value significance
stars note at the bottom of the table.  You must specify {it:startype}
as either ols, robust or cluster clustervariable. Specifying stars(ols)
will add the following note to the bottom of the table: Standard errors
in parentheses. * p<.10 ** p<.05 *** p<.01. Specifying stars(robust) will
add the following note to the bottom of the table: Heteroskedasticity-robust
standard errors in parentheses * p<.10 ** p<.05 *** p<.01.  Specifying
stars(cluster village) will add the following note to the bottom of the table:
Standard errors clustered by village in parentheses. * p<.10 ** p<.05 *** p<.01.
{it:Note}: This option does not support t-values, brackets other than parentheses or
other significance levels. If you need a custom note for significance levels,
you may add it to the note option for your table.

{phang}
{opt fontsize}{bf:({it:size})} sets the size of the text for the table.  You must specify
size as one of the standard LaTeX text sizes.  In ascending order the available text
sizes are tiny, scriptsize, footnotesize, small, normalsize, large, Large, LARGE,
huge, Huge.  If the fontsize option is not defined then \normalsize is used.

{phang}
{opt cwidth}{bf:({it:width})} sets the width of all columns in the table.  You must specify
a {it:width} that LaTeX understands, such as 15mm or 1.5in. If cwidth is not defined
then {cmd:tex3pt} will set the column width automatically.

{phang}
{opt wide} sets the width of the table to the linewidth of your document. This
option automatically spaces the columns. Wide overrides the option cwidth. If both
cwidth and wide are not specified then {cmd:tex3pt} will set the column width automatically.

{phang}
{opt land:scape} writes the table on a landscape page using the \begin{landscape} and
\end{landscape} tags included by the LaTeX package pdflscapes.

{phang}
{opt floatplacement} sets {browse "https://www.sharelatex.com/learn/Positioning_images_and_tables#The_table_environment":LaTeX float placement options}.
For example, floatplacement(!htbp) creates \begin{table}[!htbp]. If this option is not specified the default float placement parameter (tbp in article class) is used.

{phang}
{opt clear:page} forces LaTeX to clear the page after the table is written to the document.
This writes the command \clearpage after the table is inserted to the document. Specifying
the clearpage option after every call of tex3pt will allow the user to force the document
to have only one table per page.

{dlgtab:LaTeX Document Options}

{phang}
{opt pre:amble}{bf:[{it:suboptions}]} writes the preamble required to use the {cmd:esttab} output in the
LaTeX document that {cmd:tex3pt} writes. You must specify the option replace if you specify the option preamble.
The {it:suboptions} include {it:list} and {it:info}.  The {it:list} suboption will include a list of tables
(with hyperlinks) as the first page of the document. The {it:info} will write who created
the document and when the document was created in the first page footer.  The {it:info} suboption requires that you
also specify the {it:list} suboption.

{phang}
{opt pack:age}{bf:({it:packagelist})} Adds LaTeX packages from packagelist to the preamble. You must specify the option preamble if you specify the option package.

{phang}
{opt replace} permits {cmd:tex3pt} to overwrite the {it:using} file.  If replace is not specified then
{cmd:tex3pt} appends to the {it:using} file.

{phang}
{opt end:doc} writes the LaTeX command \end{document} after including the table in the {it:using} .tex file.

{phang}
{opt page} is the equivalent of specifying {it:preamble}, {it:replace} and {it:enddoc}.  This option exists purely
for convenience in the case the user wants to create a self-contained .tex document for a single table.

{phang}
{opt comp:ile} compiles the .tex file into a .pdf.  This option opens the shell and runs pdflatex.
This option requires that the option {it:enddoc} or {it:page} is also called.  This option all cleans up
any auxilary files created by pdflatex so that only the .tex and .pdf file remain. This option only works on Windows
and OS X.

{phang}
{opt marg:ins}{bf:({it:size})} sets the margins for the document.  The default margins are 1.5cm to allow
for extra space for tables.  This option sets all margins to the same value (i.e. top, bottom, left, right)
using the LaTeX package geometry.  For example, specifying the option margins(1in) will set all margins to
one inch.  The user must specify a {it:size} that LaTeX understands, such as 15mm or 1.5in.

{phang}
{opt relative:path}{bf:({it:string})} creates a relative, rather than absolute, path from the new .tex file to
the .tex table.  For example, specifying the option relativepath("./") will cause the new .tex file to look in the
same folder to find the .tex table produced by {cmd:esttab}.  An absolute path is still required for the
{cmd:using} parameter.

{phang}
{opt font}{bf:({it:fontpackage}[, fopt({it:packageoptions})])} sets the text font for the document.
For example, the option font(lmodern) will set the font of your document to Latin Modern by writing
\usepackage{lmodern} to the preamble.  The option font(comfortaa, fopt(default)) will set the
font to Comfortaa with the default option by writing \usepackage[default]{comfortaa} to the preamble.
If the option font is not specified then the document will use the default LaTeX font.

{phang}
{opt mathfont}{bf:({it:mathfontpackage}[, mfopt({it:packageoptions})])} sets the math font
for the document. For example, the option mathfont(eulervm) will set the math font of your document to Euler
Virtual Math by writing \usepackage{eulervm} to the preamble.  The option mathfont(eulervm, mfopt(small, euler-digits))
will set the math font to Euler Virtual Math using the small and euler-digits options by writing
\usepackage[small, euler-digits]{eulervm} to the preamble.  If the option font is not specified the default
LaTeX math font Computer Modern is used.

{dlgtab:\specialcell{} syntax}

{pstd}
The LaTeX preamble that this command writes includes the user-written LaTeX command \specialcell{}.  With \specialcell{} you can specify line breaks.
This is especially helpful when you want to have complex column titles.  For example if you define a column title in {cmd:esttab} as "Foreign Cars (Non-Rotary)"
it will be problematic for LaTeX since it will not add any line in the column title.  You can get around this by using the \specialcell{} syntax. The correct syntax for
the column title above is \specialcell{Foreign Cars \\ (Non-Rotary)}.  \specialcell{} will create a column title with line breaks defined at each "\\".
Example 2.1 uses this syntax.

{marker remarks}{...}
{title:Remarks}

{pstd}
This package is intended to work with {cmd:esttab}.  If you do not have this packages use
{stata ssc install estout:ssc install estout} to install the {cmd:estout} package (which includes {cmd:esttab}).

{pstd}
To use this package with {cmd:esttab} output you must supply the options {it:booktabs fragment} or {it:tex fragment} to {cmd:esttab}.
This is the format that {cmd:tex3pt} expects, and it will not work otherwise. This package is not currently compatible with the
LaTeX package longtable, however a solution is in the works.

{pstd}
This package extracts all the necessary input directly from the .tex file it is inputting, so there is no
need to run {cmd:tex3pt} right after your {cmd:esttab} calls.  The key component of this program is
writing the following in a .tex document: \estauto{{it:table}}{{it:#1}}{S[table-format={it:#2}.{it:#3} ]}
where {it:table} is the file that you created using {cmd:esttab}, {it:#1} is the number of columns in your table not
including the first column of variable names, {it:#2} is the maximum number of digits before the decimal
point in your table and {it:#3} is the maximum number of digits after the decimal point in your table. These
parameters are key to creating a nicely aligned table.  This program extracts these parameters
from the raw .tex input and the {cmd:tex3pt} call.{p_end}

{pstd}
{cmd:Tex3pt} was specifically set up to deal with regressions, so if we use it for tabulation or
summary statistics tables we have to ensure that the text for the column headers are encased in the
environment "\multicolumn{#}{c}{{it:columnheaders}}".  You can do this by using the prefix and suffix options
for the {bf:collabel} and {bf:eqlabel} options for {cmd:esttab}.  See the examples for usage of the prefix and
suffix options in {cmd:esttab}.

{pstd}
Since the .ado depends on the siunitx package for LaTeX the table output from {cmd:esttab} cannot
contain commas.  Siunitx treats commas as a protected characters in table mode.  You can remove the
commas from your output by simply including the option substitute("," "") in {cmd:esttab}.

{pstd}
As of Version 2.0.5, this package {bf:no longer} replaces special LaTeX characters like "$" with "\$" in the {it:notes} and {it:title} strings to
avoid errors. {p_end}

{marker examples}{...}
{title:Examples}

{pstd}
The following examples assume that the user knows how to use {cmd:esttab} fairly well.
See {helpb esttab} or {helpb estout} if you want to understand the options
used for {cmd:esttab} in these examples. I also suggest you read
{browse "http://repec.org/bocode/e/estout/esttab.html#esttab012":using LaTeX with esttab}
and {browse "http://repec.org/bocode/e/estout/advanced.html#advanced500":advanced LaTeX with esttab}.

{pstd}
{bf: Note:} These examples will store estimates and create .tex and .pdf files in your working directory.
I suggest you start with empty Stata instance and change your directory to somewhere familiar so
you may find and remove these files.

	{pmore}
	{bf:{ul:Example 1.1 - Regression Output, Single Table}}{p_end}
	{pmore}
	{it:Copy the text below into a do-file editor and run this code to output a regression table table using {cmd:tex3pt}:}
	{p_end}

		sysuse auto
		replace price=price/1000

		qui eststo example111: reg price mpg weight
		qui eststo example112: reg price mpg weight headroom trunk length
		qui eststo example113: reg price mpg weight i.foreign
		qui eststo example114: reg price mpg weight headroom trunk length i.foreign

		esttab example11* using "test11", ///
			replace fragment booktabs ///
			label b(3) se(3) se ///
			star(* .1 ** .05 *** .01) ///
			mgroups("Group 1" "Group 2", ///
			 pattern(1 0 1 0) ///
			 prefix(\multicolumn{@span}{c}{) ////
			 suffix(}) ///
			 span erepeat(\cmidrule(lr){@span}) ///
			) ///end mgroups
			stats(r2 N, ///
			 fmt(3 0) ///
			 layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
			 labels("R-Sq" "Observations") ///
			) // end stats

		tex3pt "test11.tex" using "master11.tex", ///
			page ///
			clearpage compile ///
			title("Tex3pt Example Table") ///
			tlabel("tab1") ///
			star(ols) ///
			note("This is a note in tex3pt!")

	{pmore}
	{bf:{ul:Example 1.2 - Regression Output, Multiple Tables}}{p_end}
	{pmore}
	{it:Copy the text below into a do-file editor and run this code to output a document with two tables and a list on the first page using {cmd:tex3pt}:}
	{p_end}

		sysuse auto
		replace price=price/1000

		qui eststo example121: reg price mpg weight
		qui eststo example122: reg price mpg weight headroom trunk length
		qui eststo example123: reg price mpg weight i.foreign
		qui eststo example124: reg price mpg weight headroom trunk length i.foreign


		esttab example121 example122 using "test121", ///
			replace fragment booktabs ///
			label b(3) se(3) se ///
			star(* .1 ** .05 *** .01) ///
			stats(r2 N, ///
			 fmt(3 0) ///
			 layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
			 labels("R-Sq" "Observations") ///
			) // end stats


		esttab example123 example124 using "test122", ///
			replace fragment booktabs ///
			label b(3) se(3) se ///
			star(* .1 ** .05 *** .01) ///
			stats(r2 N, ///
			 fmt(3 0) ///
			 layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
			 labels("R-Sq" "Observations") ///
			) // end stats



		tex3pt "test121.tex" using "master12.tex", ///
			preamble(list info)	replace  ///
			clearpage cwidth(20mm) ///
			title("Regression Example Table 1") ///
			tlabel("tab1") ///
			star(ols) ///
			note("This is a note in tex3pt!")


		tex3pt "test122.tex" using "master12.tex", ///
			enddoc compile ///
			clearpage cwidth(20mm) ///
			title("Regression Example Table 2") ///
			tlabel("tab2") ///
			star(ols) ///
			note("This is a note in tex3pt!")

	{pmore}
	{bf:{ul:Example 2.1 - Summary Statistics Table}} {p_end}
	{pmore}
	{it:Copy the text below into a do-file editor and run this code to output a document with a table of summary statistics using {cmd:tex3pt}:}
	{p_end}

		sysuse auto
		replace price=price/1000

		eststo example211: estpost summarize mpg rep78 foreign, listwise

		esttab example211 using example211, ///
			replace fragment booktabs noobs ///
			nomtitle nonumber ///
			cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0))") ///
			collabels("N" "Mean" "\specialcell{Std. \\ Dev.}" "Min" "Max", ///
			 prefix({) ///
			 suffix(}) ///
			) // end collabels

		tex3pt example211.tex using master21.tex, ///
			page ///
			compile ///
			title("Summary Statistics")


	{pmore}
	{bf:{ul:Example 3.1 - Tabulation Table}}{p_end}
	{pmore}
	{it:Copy the text below into a do-file editor and run this code to output a tabulation table using {cmd:tex3pt}:}{p_end}

		sysuse auto
		replace price=price/1000

		eststo example311: estpost tabulate rep78 foreign

		esttab example311 using test311.tex, ///
			replace booktabs fragment ///
			unstack nodepvars noobs ///
			onecell compress nogaps ///
			nonumbers nomtitles ///
			varlabels(, blist(Total "\midrule ")) ///
			eqlabels("Domestic" "Foreign", ///
			  prefix(\multicolumn{@span}{c}{) ///
			  suffix(}) ///
			) /// end eqlabels
			collabels("" "", ///
			  lhs("\multicolumn{1}{c}{Repair Record}") ///
			) // end collabels

		tex3pt "test311.tex" using "master31.tex", ///
			page ///
			compile ///
			title("Tabulation Table")

		{pmore}
		{bf:Note}: If your tabulation includes any values >=1000 they will be interpreted by {cmd:esttab} as "1,000".  Those commas will be problematic for the
		alignment of table.  Add the option substitute("," "") to the {cmd:esttab} call to erase those commas.


	{pmore}
	{bf:{ul:Example 4 - Simplifying Programming}}{p_end}
	{pmore}
	{it:The example below shows how to use {cmd:tex3pt} within a more dynamic programming environment:}{p_end}

		// create preamble shell file
		tex3pt using master4.tex, preamble(list info) replace

		// run analysis
		sysuse auto
		replace price=price/1000
		eststo example41: reg price mpg
		eststo example42: reg price mpg weight
		esttab example41 using test41.tex, b se fragment booktabs replace
		esttab example42 using test42.tex, b se fragment booktabs replace

		// add tables to shell file
		tex3pt "test41.tex" using "master4.tex", title("example 4.1")
		tex3pt "test42.tex" using "master4.tex", title("example 4.2")

		// end tex3pt file and compile
		tex3pt using "master4.tex", enddoc compile
		{pmore}

{marker author}{...}
{title:Authors}
	Derek Wolfson, UC Berkeley (formerly of Innovations for Poverty Action)
	{browse "mailto: derekwolfson@gmail.com":derekwolfson@gmail.com}
	Nils Enevoldsen, MIT (formerly of EPOD)

{marker github}{...}
{title:Github}
{pstd}
You can find the source code for this .ado file at {browse "https://github.com/derekwolfson/tex3pt.git":https://github.com/derekwolfson/tex3pt.git}

{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
I am extremely grateful to Jorg Weber and all the work he did in creating the wonderful preamble and LaTeX commands that this program uses.  You
can find all that discourse {browse "http://goo.gl/D2GzNm":here}, {browse "http://goo.gl/iVa3wX":here} and {browse "http://goo.gl/YDv0hH":here}.
I also tip my hat to Innovations for Poverty Action, Matt White and Raymond Guiteras for help with the program and Roy Wada for writing -chewfile-.
