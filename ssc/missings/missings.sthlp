{smcl}
{* 3sep2015/24sep2015/26nov2015/11may2017}{...}
{cmd:help missings}{right: ({browse "http://www.stata-journal.com/article.html?article=dm0085":SJ15-4: dm0085})}
{hline}

{title:Title}

{phang}
{cmd:missings} {hline 2} Various utilities for managing missing values


{title:Syntax}

{p 8 16 2}
{cmd:missings} {opt r:eport} [{varlist}] {ifin} [{cmd:,} {it:common_options}
{opt obs:ervations} {opt min:imum(#)} {opt p:ercent} {opt f:ormat(format)}
{opt sort} {opt show(#)} {it:{help list:list_options}}]


{p 8 16 2}
{cmd:missings} {opt l:ist} [{varlist}] {ifin}   
[{cmd:,} {it:common_options} {opt min:imum(#)}
{it:{help list_options}}]


{p 8 16 2}
{cmd:missings} {opt tab:le} [{varlist}] {ifin}   
[{cmd:,} {it:common_options} {opt min:imum(#)}
{it:{help tabulate_oneway:tabulate_options}}]


{p 8 16 2}
{cmd:missings} {opt tag} [{varlist}] {ifin}{cmd:,} {opt gen:erate(newvar)}
[{it:common_options}]


{p 8 16 2}
{cmd:missings dropvars} [{varlist}] 
[{cmd:,} {it:common_options} {opt force}]


{p 8 16 2}
{cmd:missings dropobs} [{varlist}] {ifin}   
[{cmd:,} {it:common_options} {opt force}]


{phang}
{it:common_options} are {opt num:eric}, {opt str:ing}, and {opt sys:miss}.

{pstd}
{cmd:by:} may be used with any of {cmd:missings report}, {cmd:missings list},
or {cmd:missings table}.  See {manhelp by D}.


{title:Description}

{pstd}
{cmd:missings} is a set of utility commands for managing variables that
may have missing values. By default, "missing" means numeric missing
(that is, the system missing value {cmd:.} or one of the extended missing
values {cmd:.a} to {cmd:.z}) for numeric variables and empty or {cmd:""} for
string variables.  See {helpb missing:[U] 12.2.1 Missing values} for further
information. 

{pstd}
If {varlist} is not specified, it is interpreted by default as all
variables. 

{pstd}
{cmd:missings report} issues a report on the number of missing values in
{varlist}. By default, counts of missings are given by variables;
optionally, counts are given by observations. 

{pstd}
{cmd:missings list} lists observations with missing values in {varlist}. 

{pstd}
{cmd:missings table} tabulates observations by the number of missing
values in {varlist}. 

{pstd} 
{cmd:missings tag} generates a variable containing the number of missing
values in each observation in {varlist}. 

{pstd}
{cmd:missings dropvars} drops any variables in {varlist} that are
missing on all values. 

{pstd}
{cmd:missings dropobs} drops any observations that are missing on all
values in {varlist}. 


{title:Options} 

{phang}
{opt numeric} (all subcommands) indicates to include numeric
variables only. If any string variables are named explicitly, such
variables will be ignored. 

{phang}
{opt string} (all subcommands) indicates to include string variables
only. If any numeric variables are named explicitly, such variables will
be ignored. 

{phang}
{opt sysmiss} (all subcommands) indicates to include system missing
{cmd:.} only. This option has no effect with string variables, for which
missing is deemed to be the empty string {cmd:""}, regardless. 

{phang}
{opt observations} ({cmd:missings report})  indicates counting of
missing values by observations, not the default of counting by
variables. 

{phang}
{opt minimum(#)}  ({cmd:missings report}, {cmd:missings list}, and
{cmd:missings table}) specifies the minimum number of missings to be
shown explicitly. With {cmd:missings table}, the default is {cmd:minimum(0)};
otherwise, it is {cmd:minimum(1)}.  

{phang}
{opt percent} ({cmd:missings report})  reports percents missing as well as
counts. Percents are calculated relative to the number of observations or
variables specified. 

{phang}
{opt format(format)} ({cmd:missings report})  specifies a display 
format for percents. The default is {cmd:format(%5.2f)}. This option has no
effect unless {opt percent} is also specified. 

{phang}
{opt sort} ({cmd:missings report})  specifies that variables should be sorted
according to the number of missing values. Variables with most missing values 
will be shown first. 

{phang}
{opt show(#)} ({cmd:missings report}) specifies that at most # variables 
with the most missing values be shown. This option has no
effect unless {opt sort} is also specified. 

{phang}
{it:list_options} ({cmd:missings report} and {cmd:missings list}) are
options listed in {manhelp list D} that may be specified when {cmd:list} is
used to show results. 

{phang}
{it:tabulate_options} ({cmd:missings table})  are options listed in
{manhelp tabulate_oneway R:tabulate oneway} that may be specified when
{cmd:tabulate} is used to show results. 

{phang}
{opt generate(newvar)} ({cmd:missings tag}) specifies the name of a new
variable. {cmd:generate()} is required.

{phang}
{opt force} ({cmd:missings dropvars} and {cmd:missings dropobs}) signals
that the dataset in memory is being changed and is a required
option when data are being dropped and the dataset in memory has not been
saved as such. 
  

{title:Remarks} 

{pstd}
{cmd:missings} is intended to unite and supersede the main ideas of 
{cmd:nmissing} (Cox 1999, 2001a, 2003, 2005) and 
{cmd:dropmiss} (Cox 2001b, 2008). 

{pstd}
Creating entirely empty observations (rows) and variables (columns)
is a habit of many spreadsheet users, but neither is helpful in Stata 
datasets. The subcommands {cmd:dropobs} and {cmd:dropvars} should 
help users clean up. Conversely, there is no explicit support here for
dropping observations or variables with some missing and some
nonmissing values. Users so minded will find other subcommands of use 
as an intermediate step, but multiple imputation might be a better way
forward. 


{title:Examples}

{phang}{cmd:. webuse nlswork}{p_end}
{phang}{cmd:. missings report}{p_end}
{phang}{cmd:. missings report, minimum(1000)}{p_end}
{phang}{cmd:. missings report, sort}{p_end}
{phang}{cmd:. missings report, sort show(10)}{p_end}
{phang}{cmd:. missings list, minimum(5)}{p_end}
{phang}{cmd:. missings table}{p_end}
{phang}{cmd:. bysort race: missings table}{p_end}
{phang}{cmd:. missings tag, generate(nmissing)}{p_end}
{phang}{cmd:. generate frog = .}{p_end}
{phang}{cmd:. generate toad = .a}{p_end}
{phang}{cmd:. generate newt = ""}{p_end}
{phang}{cmd:. missings dropvars frog toad newt, force sysmiss}{p_end}
{phang}{cmd:. missings dropvars toad, force sysmiss}{p_end}
{phang}{cmd:. set obs 30000}{p_end}
{phang}{cmd:. missings dropobs, force}{p_end}

        
{title:Stored results} 

{pstd}
{cmd:missings} stores the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 18 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations checked (all){p_end}
{synopt:{cmd:r(n_dropped)}}number of observations dropped ({cmd:missings dropobs}){p_end}

{p2col 5 16 18 2: Macros}{p_end}
{synopt:{cmd:r(varlist)}}varlist used ({cmd:missings report},
{cmd:missings list}, {cmd:missings table}, and {cmd:missings dropvars}){p_end}
{p2colreset}{...}


{title:Author}

{pstd}Nicholas J. Cox, Durham University, Durham, UK{p_end}
{pstd}n.j.cox@durham.ac.uk{p_end}


{title:Acknowledgments} 

{pstd}
Jeroen Weesie, Eric Uslaner, and Estie Sid Hudes contributed to the
earlier development of {cmd:nmissing} and {cmd:dropmiss}. 

{pstd}
A question from Fahim Ahmad on Statalist prompted the addition of {opt sort} 
and {opt show(#)} options to {cmd:missings report}. 


{title:References} 

{phang}
Cox, N. J. 1999.
{browse "http://www.stata.com/products/stb/journals/stb49.pdf":dm67: Numbers of missing and present values.}
{it:Stata Technical Bulletin} 49: 7-8.
Reprinted in {it:Stata Technical Bulletin Reprints}, vol. 9, pp. 26-27.
College Station, TX: Stata Press.

{phang}
------. 2001a.
{browse "http://www.stata.com/products/stb/journals/stb60.pdf":dm67.1: Enhancements to numbers of missing and present values}.
{it:Stata Technical Bulletin} 60: 2-3.
Reprinted in {it:Stata Technical Bulletin Reprints}, vol. 10, pp. 7-9.
College Station, TX: Stata Press.

{phang}
------. 2001b.
{browse "http://www.stata.com/products/stb/journals/stb60.pdf":dm89: Dropping variables or observations with missing values}.
{it:Stata Technical Bulletin} 60: 7-8.
Reprinted in {it:Stata Technical Bulletin Reprints}, vol. 10, pp. 44-46.
College Station, TX: Stata Press.

{phang}
------. 2003. Software Updates:
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=up0005":dm67_2: Numbers of missing and present values}.
{it:Stata Journal} 3: 449.

{phang}
------. 2005.
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=up0013":Software Updates: dm67_3: Numbers of missing and present values}.
{it:Stata Journal} 5: 607.

{phang}
------. 2008. Software Updates:
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=up0023":dm89_1: Dropping variables or observations with missing values}.
{it:Stata Journal} 8: 594.


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 4: {browse "http://www.stata-journal.com/article.html?article=dm0085":dm0085}{p_end}

{p 7 14 2}Help:  {helpb missing:[U] 12.2.1 Missing values},
{manhelp codebook D}, {manhelp egen D}, {manhelp ipolate D}
{manhelp misstable R}, {manhelp mvencode D}, {manhelp recode D},
{manhelp mi MI:intro},{break}
{helpb findname}, {helpb mipolate} (if installed){p_end}
