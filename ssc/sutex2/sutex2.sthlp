{smcl}
{vieweralsosee "sutex" "sutex"}{...}
{viewerjumpto "Syntax" "sutex2##syntax"}{...}
{viewerjumpto "Description" "sutex2##description"}{...}
{viewerjumpto "Options" "sutex2##options"}{...}
{viewerjumpto "Remarks" "sutex2##remarks"}{...}
{viewerjumpto "Examples" "sutex2##examples"}{...}
{viewerjumpto "Author" "sutex2##author"}{...}
{title:Title}

{phang}
{bf:sutex2} {hline 2} LaTeX tables for summary statistics


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:sutex2}
[{varlist}]
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Statistics}
{synopt:{opt min:max}}includes minimum and maximum in the table{p_end}
{synopt:{opt perc:entiles(numlist)}}includes specified percentile(s) in the table{p_end}
{syntab:Text format}
{synopt:{opt dig:its(#)}}sets the number of decimal digits to be printed; default is {cmd:digits(3)}{p_end}
{synopt:{opt varlab:els}}shows variable labels{p_end}
{synopt:{opt na(string)}}prints the text {it:string} when missing values occur; default is {cmd:na(.)}{p_end}
{syntab:LaTeX options}
{synopt:{opt caption(string)}}defines the caption of the {it:table}/{it:longtable} LaTeX environment{p_end}
{synopt:{opt tablab:el(string)}}defines the label of the {it:table}/{it:longtable} LaTeX environment{p_end}
{synopt:{opt pl:acement(string)}}specifies the position of the table in LaTeX documents{p_end}
{synopt:{opt long:table}}produces the output as a {it:longtable} LaTeX environment{p_end}
{synopt:{opt tabular}}produces only the {it:tabular} LaTeX environment{p_end}
{synopt:{opt nocheck}}avoids the check for special characters{p_end}
{syntab:Output options}
{synopt:{opt sav:ing(string)}}saves the output as a file{p_end}
{synopt:{opt append}}appends the output to an existing file{p_end}
{synopt:{opt repla:ce}}replaces the output file{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is allowed; see {manhelp by D}.{p_end}
{p 4 6 2}
{cmd:fweight}s and {cmd:aweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:sutex2} produces LaTeX tables ({it:table}, {it:longtable} or {it:tabular}) including the number of observations, the mean and the standard deviation of {varlist}.
Optionally, you can include minimum, maximum and percentiles.{p_end}
{pstd}
It extends and updates the {help sutex} command by Antoine Terracol (2001).
Some of the options included in {help sutex} are not present in {cmd:sutex2}, while others have been added. In particular, {cmd:sutex2} allows the inclusion of percentiles.{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Statistics}

{phang}
{opt min:max} includes in the table also minimum and maximum values.

{phang}
{opt perc:entiles(numlist)} includes in the output the percentile(s) specified by {it:numlist} among those computed by the {help summarize} command, that is any combination of: 1, 5, 10, 25, 50, 75, 90, 95, 99.

{dlgtab:Text format}

{phang}
{opt dig:its(#)} sets the number of decimal digits to be printed. It cannot be less than 0 or more than 20; default is {cmd:digits(3)}.

{phang}
{opt varlab:els} shows variable labels instead of variable names.

{phang}
{opt na(string)} prints the text {it:string} when missing values occur; default is {cmd:na(.)}.

{dlgtab:LaTeX options}

{phang}
{opt caption(string)} defines the caption of the {it:table} LaTeX environment. It prints a "\caption{{it:string}}" text in the first line of the output; default is {cmd:caption(Summary statistics)}.

{phang}
{opt tablab:el(string)} defines the label of the {it:table} LaTeX environment. It prints a "\label{{it:string}}" text in the first line of the output; default is {cmd:tablabel(sumstat)}.

{phang}
{opt pl:acement(string)} specifies the preferred position of the table in the page as an option of the {it:table} LaTeX environment; default is {cmd:placement(htbp)}.

{phang}
{opt long:table} produces the output as a {it:longtable} LaTeX environment instead of the default {it:table}. It should be specified only for a large number of variables.

{phang}
{opt tabular} produces the {it:tabular} LaTeX environment without the {it:table} LaTeX environment. It cannot be specified together with {cmd:longtable}. 
Moreover, {cmd:caption} and {cmd:tablabel} have no effects on the {it:tabular}.

{phang}
{opt nocheck} avoids the special character replacement into LaTeX readable format. 
By default the following characters: #, $, %, &, ~, _, ^, {, }, >, <, \ are replaced by the LaTeX-compatible counterparts (\#, \$, \%, \&, \~{}, \_, \^{}, \{, \}, \>, \<, $\backslash$).
It should be only specified if variable names or labels are already compatible with LaTeX.

{dlgtab:Output options}

{phang}
{opt sav:ing(string)} saves the output in the {it:string} file.
If this option is not specified, the output is printed in the result window only.
If no extension is declared, .tex is assumed. 
If the string includes one "." character, what follows is assumed to be the extension. Therefore, if you want to include a "." in the file name, you need to specify the file extension as well.{p_end}
{phang}
i.e.: {cmd:saving(myfile)} and {cmd:saving(myfile.tex)} produce the same result (the output saved in {it:myfile.tex}), 
while {cmd:saving(my.file)} and {cmd:saving(my.file.tex)} produce different results (the output is saved as {it:my.file} and {it:my.file.tex}, respectively).{p_end}

{phang}
{opt append} prints the output in the existing file identified by {cmd:saving(string)}. It requires the option {cmd:saving(string)}.

{phang}
{opt repla:ce} replaces the output file identified by {cmd:saving(string)}. It requires the option {cmd:saving(string)}.


{marker remarks}{...}
{title:Remarks}

{pstd}
All the statistics displayed in the output derive from the {help summarize} command.

{pstd}
All the variables in the dataset are shown if {varlist} is empty.

{pstd}
The header of the table is by default:{p_end}
{pstd}
\begin{table}[htbp]\centering\caption{Summary statistics\label{sumstat}}{p_end}
{pstd}
{opt pl:acement(string)} turns [htbp] in [{it:string}];{p_end}
{pstd}
{opt caption(string)} changes the caption;{p_end}
{pstd}
{opt tablab:el(string)} changes the label;{p_end}
{pstd}
{opt tabular} suppresses the header and the footer.{p_end}


{marker examples}{...}
{title:Examples}

{phang}{cmd:. sutex2}{p_end}

{phang}{cmd:. sutex2, min perc(1 10 50 90 99) dig(2) varlab na(na) replace}{p_end}

{phang}{cmd:. sutex2, pl(t!) caption(Any title) tablabel(tab_1) long append}{p_end}


{marker author}{...}
{title:Author}

{pstd}Francesco Scervini{p_end}
{pstd}Universitˆ di Torino{p_end}
{pstd}For any comment, bug-report, clarifications: francesco.scervini@unito.it{p_end}


