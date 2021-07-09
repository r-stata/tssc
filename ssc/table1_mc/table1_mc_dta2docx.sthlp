{smcl}
{* *! version 1.02 2020-04-29}{...}
{hline}
help for {cmd:table1_mc_dta2docx}
{hline}

{title:Title}

{p2colset 5 15 21 2}{...}
{p2col: {bf:table1_mc_dta2docx}}{hline 2} Generate Office Open XML (.docx) file containing output from {cmd:table1_mc, clear}


{title:Syntax}

{p 8 18 2}
{opt table1_mc_dta2docx} using {it:{help filename}} [, {it:options}]


{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt page:size(psize)}}sets the page size of the document.  {it:psize} may be
{cmd:letter}, {cmd:legal}, {cmd:A3}, {cmd:A4}, or {cmd:B4JIS}.  The default is
{cmd:pagesize(letter)}.{p_end}
{synopt:{opt land:scape}}changes the document orientation from portrait to landscape{p_end}
{synopt:{cmdab::font(}{it:{help putdocx##fspec:fspec}}{cmd:)}}general font, default is {cmd:font("Calibri", 11)}{p_end}
{synopt:{cmdab::datafont(}{it:{help putdocx##fspec:fspec}}{cmd:)}}font for data rows in main table, default is {cmd:datafont("Calibri", 10)}{p_end}
{synopt:{cmdab::datahalign(}{it:{help putdocx##rowcol_hvalue:hvalue}}{cmd:)}}set horizontal alignment for data columns in main table (excludes any variable called level or with prefix pvalue). 
The default is {cmd:datahalign(center)}.{p_end}
{synopt:{cmdab: tablenum:ber(}{it:string}{cmd:)}}specify e.g. {cmd:tablenumber("Table 1.")} to make a "Table 1." title appear (in bold){p_end}
{synopt:{cmdab: tableti:tle(}{it:string}{cmd:)}}specify e.g. {cmd:tabletitle("Baseline characteristics by group.")} to make a title appear (not in bold){p_end}
{synopt:{cmdab: foot:note(}{it:string}{cmd:)}}add a footnote after the main table and after footnote from {cmd:table1_mc} is reported{p_end}
{synopt:{cmdab: finside}}move footnote(s) inside the main table (as an additional row(s)){p_end}
{synopt:{cmdab::tabopts(}{it:{help putdocx##tabopts:table_options}}{cmd:)}}options for main table (other than layout and border){p_end}
{synopt:{opt replace}}specifies to overwrite {it:filename}, if it exists{p_end}
{synopt:{opt append}}specifies to append the contents of the document in memory to the end of {it:filename}. (Cannot be used with the replace option.){p_end}


{title:Description}

{phang}{bf:table1_mc_dta2docx} makes use of the {help putdocx:putdocx} command introduced in Stata 15. 
{bf:table1_mc_dta2docx} is used after {bf:table1_mc} has been used with the {bf:clear} option.{p_end}

{phang}The main table will consist of all variables without the prefix N_, m_, or _column. 
You might like to delete the (unfortunate) blank line between the table and the footnote(s). 
Or use the option {bf:finside}. 
Using the option {bf:finside}, footnote() is equivalent to tabopts(note()).{p_end}

{phang}The table showing the number of records used, and not used, in calculating summary statistics 
will consist of the variable called factor and all variables with the prefix N_ or m_. 
If there are no variables with the prefix N_ or m_, this table won't appear.{p_end}



{title:Examples [Stata 15.1 required]}

{pstd}{sf:. }{stata "sysuse auto, clear"} {break} 
{sf:. }{stata "table1_mc, by(foreign) vars(price conts \ weight contn %5.0f \ rep78 cate) extraspace clear"} {break}
{sf:Did the above command use the} {bf:clear} {sf:option? Yes! Then we are now ready to:} {break}
{sf:. }{stata `"table1_mc_dta2docx using "N:\example Table 1.docx", replace"'}{p_end}

{pstd}{sf:To prevent a pvalue column appearing in the main table in the coming .docx file:}{break}
{sf:. }{stata "drop pvalue"}{break}
{sf:To only report  - #records not used -  after the main table in the coming .docx file:}{break}
{sf:. }{stata "drop N_*"}{break}
{sf:Or, to report only the main table in the coming .docx file:}{break}
{sf:. }{stata "drop N_* m_*"}{break}
{sf:. }{stata `"table1_mc_dta2docx using "N:\example Table 1.docx", replace tablenumber("Table 1.") tabletitle("Car characteristics by car type.") footnote("Foreign cars included Audi, Datsun, Toyota and VW cars.")"'}{p_end}


{title:Author}

{p 4 4 2}
Mark Chatfield, The University of Queensland, Australia.{break}
m.chatfield@uq.edu.au{break}
