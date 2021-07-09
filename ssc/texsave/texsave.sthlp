{smcl}
{hi:help texsave}
{hline}
{title:Title}

{p 4 4 2}{cmd:texsave} {hline 2} Save dataset in LaTeX format.


{title:Syntax}

{p 8 14 2}{cmd:texsave} [{it:varlist}] {cmd:using} {it:filename} [if] [in] [, {cmd:title(}{it:string}{cmd:)} {cmd:size(}{it:string}{cmd:)}
{cmd:width(}{it:string}{cmd:)} {cmd:align(}{it:string}{cmd:)} {cmdab:loc:ation(}{it:string}{cmd:)}
{cmd:marker(}{it:string}{cmd:)} {cmd:autonumber} {cmd:hlines(}{it:numlist}{cmd:)} {cmd:footnote(}{it:footnote_options}{cmd:)}
{cmdab:varlab:els} {cmdab:land:scape}  {cmdab:geo:metry(}{it:string}{cmd:)}
{cmd:rowsep(}{it:string}{cmd:)} {cmd:frag} {cmd:nonames} {cmd:sw} {cmd:nofix} 
{cmd:headerlines(}{it:stringlist}{cmd:)} {cmd:headlines(}{it:stringlist}{cmd:)} {cmd:footlines(}{it:stringlist}{cmd:)}
{cmd:replace} {it:format_options}]

{p 4 4 2}where

{p 8 14 2}{it: numlist} is a list of numbers with blanks or commas in between (see {help numlist:[U] numlist} for details),

{p 8 14 2}{it: stringlist} is a list of quoted strings,

{p 8 14 2}{it:footnote_options} are

{p 12 14 2}{cmd:footnote(}{it:string} [, {cmd:size(}{it:string}{cmd:)} {cmd:width(}{it:string}{cmd:)}]{cmd:)}

{p 8 14 2}and {it:format_options} are

{p 12 14 2}{cmd:bold(}{it:stringlist}{cmd:)} {cmd:italics(}{it:stringlist}{cmd:)} {cmd:underline(}{it:stringlist}{cmd:)} {cmd:slanted(}{it:stringlist}{cmd:)} {cmd:smallcaps(}{it:stringlist}{cmd:)}
{cmd:sansserif(}{it:stringlist}{cmd:)} {cmd:monospace(}{it:stringlist}{cmd:)} {cmd:emphasis(}{it:stringlist}{cmd:)}


{title:Description}

{p 4 4 2}{cmd:texsave} outputs the dataset currently in memory to {it:filename} in LaTeX format. It uses the {it:booktabs}, {it:tabularx}, and {it:geometry} packages
to produce publication-quality tables.


{title:Options}


{p 4 8 2}
{cmd:title(}{it:string}{cmd:)} writes out {it:string} as a caption above the table.


{p 4 8 2}
{cmd:size(}{it:string}{cmd:)} specifies the size of your table.  Valid size options are tiny, scriptsize, footnotesize, small, normalsize, large, Large, LARGE, huge, and Huge.  
Alternatively, the user may specify a numeric value between 1 and 10, where 1 corresponds to tiny and 10 corresponds to Huge.


{p 4 8 2}
{cmd:width(}{it:string}{cmd:)} specifies the width of your table. Lengths can be specified in the same way as for {cmd:rowsep} (see below). The default is {it:\textwidth}.


{p 4 8 2}
{cmd:align(}{it:string}{cmd:)} specifies the column formatting. It generally consists of a sequence of the following specifiers, at least one for each of the columns: 

{p 8 8 2}l - a column of left-aligned items

{p 8 8 2}c - a column of centered items

{p 8 8 2}C - a column of centered items; column spacing for all 'C' columns are always the same.

{p 8 8 2}r - a column of right-aligned items

{p 8 8 2}| - a vertical line the full height and depth of the environment 

{p 8 8 2}The character '|' (the vertical bar, NOT the alphabetic character 'l') adds vertical lines to the table.  For example, 
if there are three columns, specify {cmd:align(}{it:|l|C|C|}{cmd:)} to surround all columns with vertical lines.
The default is to left-justify the first column and center and distribute space equally across the rest of the columns, which in the case of three columns corresponds to 
{cmd:align(}{it:lCC}{cmd:)}


{p 4 8 2}
{cmd:location(}{it:string}{cmd:)} specifies the location of your table in the document.  It consists of one or more of the following specifiers:

{p 8 8 2}h - "Here": at the position in the text where the environment appears

{p 8 8 2}t - "Top": at the top of a text page

{p 8 8 2}b - "Bottom": at the bottom of a text page

{p 8 8 2}p - "Page": on a separate page containing no text, only figures and tables

{p 8 8 2}The default is {cmd:location(}{it:tbp}{cmd:)}.


{p 4 8 2}
{cmd:marker(}{it:string}{cmd:)} uses LaTeX's \label option to mark your table with the key {it:string}.


{p 4 8 2}
{cmd:autonumber} writes out "(1)", "(2)"... in the first row of the table header, beginning with column two.  
This is useful when outputting regression results stored by a command like {help regsave:regsave} (if installed).


{p 4 8 2}
{cmd:hlines(}{it:numlist}{cmd:)} draws horizontal lines below each row specified in {it:numlist}.  Specify a row's number twice to output a double line. Negative 
values are interpreted as the distance from the end of the table.


{p 4 8 2}
{cmd:footnote(}{it:string} [, {cmd:size(}{it:string}{cmd:)} {cmd:width(}{it:string}{cmd:)}]{cmd:)} writes out {it:string}
in a left-justified footnote at the bottom of the table.  The suboptions allow you to set the size and width of the 
footnote, using the syntax described by the {cmd:size(}{it:string}{cmd:)} and {cmd:width(}{it:string}{cmd:)} options.


{p 4 8 2}
{cmd:varlabels} specifies that variable labels be written in the table header instead of variable names.


{p 4 8 2}
{cmd:landscape} specifies a landscape orientation instead of a portrait orientation. This requires the {it:pdflscape} package.


{p 4 8 2}
{cmd:geometry(}{it:string}{cmd:)} specifies the page dimensions using the {it:geometry} package. The default is "margin=1in".


{p 4 8 2}
{cmd:rowsep(}{it:string}{cmd:)} adds vertical spacing of length {it:string} to the rows via the {it:\addlinespace} command. 
The length can be expressed in the following units: {it:cm} (centimetres), {it:em} (the width of the letter M in the current font), {it:ex} 
(the height of the letter x in the current font), {it:in} (inches), {it:pc} (picas), {it:pt} (points) or {it:mm} (millimetres). 
For example, {cmd:rowsep(}{it:1cm}{cmd:)} adds one centimeter of vertical space between rows.

{p 4 8 2}
{cmd:frag} omits from the output LaTeX code like {it:\begin{c -(}document{c )-}} that is needed to create a standalone document.  This makes {it:filename} a fragment, which
is useful if you plan to link your table to another document via LaTeX's {it:\input{c -(}table{c )-}} command.


{p 4 8 2}
{cmd:nonames} specifies that variable names not be added to the table header.


{p 4 8 2}
{cmd:sw} instructs {cmd:texsave} to include macro code that can be read by Scientific Word (SW) so that full SW functionality is retained.


{p 4 8 2}
{cmd:nofix} instructs {cmd:texsave} to write out all data, titles and footnotes exactly as they appear in Stata.  Many of the non-alphanumeric characters have special meaning in LaTeX, namely _, %, #, $, &, ~, ^^, \, {, }.
By default, {cmd:texsave} tries to fix this by adding a backslash (\) in front of these characters.  (It is not always successful, though).
Specify {cmd:nofix} if you are intentionally outputting LaTeX code and don't want {cmd:texsave} to incorrectly modify it.


{p 4 8 2}
{cmd:headerlines(}{it:stringlist}{cmd:)} specifies a list of lines of LaTeX code to appear before the table header.  Each line of code should be surrounded by quotation marks (see example 5 below).


{p 4 8 2}
{cmd:headlines(}{it:stringlist}{cmd:)} specifies a list of lines of LaTeX code to appear before the table code in the output.  Each line of code should be surrounded by quotation marks (see example 4 below).


{p 4 8 2}
{cmd:footlines(}{it:stringlist}{cmd:)} specifies a list of lines of LaTeX code to appear after the table code in the output.  Each line of code should be surrounded by quotation marks (see example 4 below).


{p 4 8 2}
{cmd:replace} overwrites {it:filename}.


{p 4 8 2}
{it:format_options}: {cmd:bold(), italics(), underline(), slanted(), smallcaps(), sansserif(), monospace(),} and {cmd:emphasis()} allow you to format the data values in your table.  
For example, {cmd:underline(}{it:"word1" "word2"}{cmd:)} underlines all data values containing either {it:"word1"} or {it:"word2"}.


{title:Remarks}

{p 4 8 2} It is sometimes difficult to make {cmd:texsave} output a literal "$" because this can be interpreted by Stata as a global macro.
For example, "$R^2$" will be incorrectly outputted as "^2$".  You can avoid this problem by using the alternative LaTeX syntax "\(R^2\)".

{p 4 8 2} {cmd:texsave} performs some basic error checking. For example, it issues an error if you specify horizontal lines at row values that do not exist. 
However, it does not check that tables with lots of alignment specifications etc. will compile correctly. 
It is your responsibility to ensure that you are supplying valid LaTeX code when specifying options such as {cmd:headlines()}, {cmd:align()} etc. 
See {browse "http://en.wikibooks.org/wiki/LaTeX/Tables"} to learn more about writing LaTeX code for tables.


{title:Notes}

{p 4 8 2}{cmd:texsave} has been tested on Scientific WorkPlace 5.0 and TeXShop 2.18 (as supplied by the August 28, 2008 distribution of MacTeX).
Please contact the author if you notice problems with other compilers.

{title:Examples}

{p 4 4 2}1.  Output a table with a title and a footnote.

{col 8}{cmd:. {stata sysuse auto.dta, clear}}

{col 8}{cmd:. {stata texsave make mpg trunk if price > 8000 using "example1.tex", title(MPG and trunk space) footnote(Variable trunk measured in cubic feet) replace}}


{p 4 4 2}2.  Output a table with a small font size and some horizontal lines.

{col 8}{cmd:. {stata sysuse auto.dta, clear}}

{col 8}{cmd:. {stata texsave make mpg trunk weight length displacement turn using "example2.tex" in 1/30, size(2) hlines(3 10/13 19 23 25 -2 30) replace}}


{p 4 4 2}3.  Output a table with non-variable name headers and LaTeX math code in the footnote.

{col 8}{cmd:. {stata sysuse auto.dta, clear}}

{col 8}{cmd:. {stata label var make "Car make"}}

{col 8}{cmd:. {stata label var mpg "Miles per gallon"}}

{col 8}{cmd:. {stata label var trunk "Trunk space"}}

{col 8}{cmd:. {stata texsave make mpg trunk if price > 8000 using "example3.tex", title(MPG and trunk space) varlabels footnote("Variable trunk measured in ft\(^3\)") nofix replace}}


{p 4 4 2}4. Output a table with additional LaTeX code.

{col 8}{cmd:. sysuse auto.dta, clear}

{col 8}{cmd:. texsave make mpg trunk if price > 8000 using "example4.tex", loc(h) headlines("\begin{center}" "My headline" "\end{center}") footlines("My footline") replace}


{p 4 4 2}5. Output a table with a complicated header and bold-face the first observation.

{col 8}{cmd:. sysuse auto.dta, clear}

{col 8}{cmd:. texsave make mpg trunk if price > 8000 using "example5.tex", bold("Buick") headerlines("& \multicolumn{2}{c}{\textbf{Data}}" "\cmidrule{2-3}\addlinespace[-2ex]") nofix replace}


{title:Author}

{p 4 4 2}Julian Reif, University of Illinois at Urbana-Champaign

{p 4 4 2}jreif@illinois.edu


{p 4 4 2}Thanks to Kit Baum for helpful suggestions and feedback.


{title:Also see}

{p 4 4 2}
{help regsave:regsave} (if installed),
{help outreg2:outreg2} (if installed),
{help filefilter:filefilter}
