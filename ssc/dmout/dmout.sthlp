{smcl}
{* *! version 1.1.0  30nov2012}{...}
{cmd:help dmout}
{hline}

{title:Title}

{phang}
{bf:dmout} {hline 2} Produce tables of difference in means tests 


{title:Syntax}

{p 8 17 2}
{cmd:dmout} {varlist} {ifin} {weight} {cmd:using} {it:filename}
{cmd:,} {opt by(varname)} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth by(varname)}}Group variable to take differences; Must take two values, string or numeric OK{p_end}
{synopt:{opth iv(varname)}}Exogenous variable for IV analysis; Must take two values, string or numeric OK{p_end}
{synopt:{opth ctrl:vars(varlist)}}Include control variables in difference (and IV) estimation{p_end}
{synopt:{opth vce(vcetype)}}Any vce accepted by regress (and ivregress) command{p_end}
{synopt:{opt st:at(stat)}}Report either {cmd:se} or {cmd:pval} for difference estimates; default is se{p_end}
{synopt:{opt cw}}Casewise exclusion of observations with missing data{p_end}

{syntab:Output}
{synopt:{opt list}}Display table in results window{p_end}
{synopt:{opt detail}}Display detailed regression results{p_end}
{synopt:{opt using}}Output file name; do not include .suffix{p_end}
{synopt:{opt replace}}Replace the output file, if it exists{p_end}
{synopt:{opt append}}Append results to existing output file{p_end}
{synopt:{opt csv}}Create csv output file{p_end}
{synopt:{opt txt}}Create tab-delimited text output file{p_end}
{synopt:{opt tex}}Create tex output file{p_end}
{synopt:{opt preamb:le}}include tex preamble{p_end}
{synopt:{opt enddoc}}include tex end of document{p_end}

{syntab:Table}
{synopt:{opt t:itle(title)}}Table title{p_end}
{synopt:{opt subt:itle(subtitle)}}Table subtitle{p_end}
{synopt:{opt cap:tion(caption)}}Table caption{p_end}
{synopt:{opt d:ecimal(#)}}Decimal places for reporting levels. Differences have one additional decimal place.{p_end}
{synopt:{opt note:s(notes)}}Table notes: enclose multiple notes in quotes{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see {help weight}.


{title:Description}

{pstd}
{cmd:dmout} produces difference-in-means tables. Means of each variable in {varlist} 
are compared across the values of the {cmd:by()} variable. {cmd:dmout} is useful 
when comparing several variables across two groups, such as treatment and control 
groups in an RCT, or attriters and non-attriters in longitudinal data. 

{pstd}
The two groups should be designated by the {cmd:by()} variable. {cmd:by()} may be a
numeric or string variable. It must take exactly two values within the analysis sample.
Column headings are taken from the value labels of the {cmd:by()} variable. Row labels 
are taken from the variable label of each variable in {varlist}. 

{pstd}
Mean/difference estimates, standard errors, and p-values are computed using regress or ivregress.
If the default, non-robust standard errors are used for a simple difference estimate, the
p-values calculated by dmout are equivalent those from a two-group, two-tailed 
ttest where the groups have equal variance (pooled). 

{pstd}
The analysis sample may change between the dependent variables specified in {varlist}, due to 
missing data. By default, the full sample is used for each dependent variable. Sample size is 
reported in the table anytime the current regression has a different sample size than the
preceding regression. To use a single, non-missing sample, the user may specify the {cmd:cw} option.


{title:Options}

{dlgtab:Main}

{phang}
{opth by(varname)} specifies the group variable over which to take differences. The variable may
be string or numeric, but it must take exactly two values within the estimation sample.{p_end}

{phang}
{opth iv(varname)} specifies the exogenous variable for IV analysis. The variable may
be string or numeric, but it must take exactly two values within the estimation sample. IV 
estimates will be recorded in a new column.{p_end}

{phang}
{opth ctrl:vars(varlist)} Include control variables in difference estimation. Difference coefficient 
from regression with controls will be recorded in a new column. If the IV option is specified,
an additional column will be included for IV estimates with controls.{p_end}

{phang}
{opth vce(vcetype)} specifies the type of standard error reported. This option is passed through to the
regress or ivregress command. If the {opth iv(varname)} option is used, the vcetype should be consistent 
with both regress and ivregress. Otherwise it just needs to be consistent with regress.{p_end}

{phang}
{opt st:at(stat)} specifies the statistice to report in the table. It may be either {cmd:se} for
standard errors, or {cmd:pval} for p-values. The default is {cmd:se}.{p_end} 

{phang}
{opt cw} specifies casewise exclusion of observations with missing data. The default behavior uses the full 
available data for each dependent variable. If the number of observations differs between two rows
of the table, a line is printed with the number of observations used in the previous regression(s). {p_end}

{dlgtab:Output}

{phang}
{opt using} specifies the file name to save output. Do not include any suffix with the file name. The suffix 
will be added according to the selected output format, csv, tex, or txt.{p_end}

{phang}
{opt csv} creates a comma-separated-value output file. Rows are named by variable label. If the variable label
contains a comma, it will incorrectly increment the column alignment. {p_end}

{phang}
{opt txt} creates a tab-delimited output file.{p_end}

{phang}
{opt tex} creates a LaTeX output file. No provision is made to escape special LaTeX characters. Table rows are
named with variable labels if present, and variable names otherwise. Avoid special LaTeX characters in variable
labels or names. This includes underscores in variable names (unless they are labeled). LaTeX output relies 
on the following packages: geometry, threeparttable, booktabs, dcolumn. These packages are specified if the 
{opt preamb:le} option is specified. {p_end}

{phang}
{opt preamb:le} includes the LaTeX preamble in the .tex output file.

{phang}
{opt enddoc} includes the LaTeX end of document statement in the .tex output file.

{phang}
{opt list} Display table in results window. May be used in conjunction with an output file or in place
of an output file. {p_end}

{phang}
{opt replace} replaces the output file, if the output file already exists. {p_end}

{phang}
{opt append} appends the current table to the existing output file, if the output file already exists.{p_end}

{dlgtab:Table}

{phang}
{opt t:itle(title)} specifies the table title.{p_end}

{phang}
{opt subt:itle(subtitle)} specifies the table subtitle, which appears below the title.{p_end}

{phang}
{opt cap:tion(caption)} specifies the table caption. The table caption is primarily used for LaTeX output. For other output
file types, the caption appears above the title caption. {p_end}

{phang}
{opt d:ecimal(#)} specifies the number of decimal places for reporting levels of variables. Differences have one additional decimal place.{p_end}

{phang}
{opt note:s(notes)} specifies table notes to appear at the bottom of the table. Two notes appear by default. The
first describes how stars are printed in the table according to coefficient significance levels. The second
specifies whether standard errors or p-values are reported under coefficients. If control variables are used, a third 
automatic note is generated listing the control variables. To specify multiple additional 
notes, enclose each note in quotation marks.{p_end}


{title:Examples}

{phang}{cmd:. sysuse auto.dta} 

{phang}{cmd:. dmout weight mpg length using automeans , by(foreign) csv list}


{title:Author}

{pstd} Michael Barker {p_end}
{pstd} Georgetown University {p_end}
{pstd} mdb96@georgetown.edu {p_end}


{title:Also see}

{psee}
{space 2}Net:  
{net `"describe outreg2		, from(http://fmwww.bc.edu/repec/bocode/o)"' : outreg2 } ,
{net `"describe tabout		, from(http://fmwww.bc.edu/repec/bocode/t)"' : tabout  } ,
{net `"describe outtable	, from(http://fmwww.bc.edu/repec/bocode/o)"' : outtable} ,
{net `"describe estout		, from(http://fmwww.bc.edu/repec/bocode/e)"' : estout  } ,
{net `"describe diff 		, from(http://fmwww.bc.edu/repec/bocode/d)"' : diff}
{p_end}
