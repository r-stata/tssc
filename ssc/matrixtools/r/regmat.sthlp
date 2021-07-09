{smcl}
{* *! version 0.23}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Help log2markup (Is installed with matprint" "help log2markup"}{...}
{vieweralsosee "Help basetable (Is installed with matprint" "help basetable"}{...}
{vieweralsosee "Help sumat (Is installed with matprint" "help sumat"}{...}
{vieweralsosee "Help estout (if installed)" "help estout"}{...}
{viewerjumpto "Syntax" "regmat##syntax"}{...}
{viewerjumpto "Description" "regmat##description"}{...}
{viewerjumpto "Examples" "regmat##examples"}{...}
{viewerjumpto "Stored results" "regmat##results"}{...}
{viewerjumpto "Author and support" "regmat##author"}{...}
{title:Title}
{phang}
{bf:regmat} {hline 2} generating matrix of regression estimates for 
observational studies

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:regmat} [using]{cmd:,} 
{it:outcomes}(varlist) 
{it:exposures}(varlist)
[{it:adjustements}(varlist strings)
{it:noquietly}
{it:labels}
{it:base}
{it:keep(string)}
{it:drop(string)}
{help regmat##matprint:{it:Matprint options}}] {cmd:,} {it: regression template}

{synoptset 30 tabbed}{...}
{p2colset 6 30 30 2}
{synopthdr}
{synoptline}
{syntab:Main options}
{synopt:{opt o:utcomes(varlist)}} A non-empty varlist of outcome variables. 
An outcome is the dependent variable in a regression.{p_end}
{synopt:{opt e:xposures(varlist)}} A non-empty varlist of outcome variables.
Exposures are variables of whiech estimates are to be reported.{p_end}
{synopt:{opt a:djustments(string)}} A set of varlist strings.{break} 
A varlist string is a possibly empty set of adjustment variables.{break}
Each varlist string is surrounded in text quotes (").{break}
An empty string ("") means no adjustment.{break}
Adjustment variables are variables needed for the estimation of the exposures, 
but it is not necessary to report their estimates.{p_end}
{synopt:{opt noq:uietly}} If set, regression outputs are printed in the log.{p_end}
{synopt:{opt l:abels}} Use variable and value labels.{p_end}
{synopt:{opt ba:se}} Include base values at factor variables.{p_end}
{synopt:{opt k:eep}} To style output choose which calculations to keep.{break}
Choices are: {bf:b}(=estimate of exposure in regression), {bf:se}(=Se(estimate)), 
{bf:ci}(=Confidence interval - level is set with {help level:set level}), 
and {bf:p}(=P-value).{p_end}
{synopt:{opt dr:op}} To style output choose which calculations to drop.{break}
Choices are: {bf:b}(=estimate of exposure in regression), {bf:se}(=Se(estimate)), 
{bf:ci}(=Confidence interval - level is set with {help level:set level}), 
and {bf:p}(=P-value).{p_end}
{synopt:{opt ef:orm}} Exponentialise table contents.{p_end}
{synoptline}
{marker matprint}{...}
{syntab:Matprint options}
{synopt:{opt s:tyle(string)}} Style for output. One of the values {bf:smcl} (default), 
{bf:csv} (semicolon separated style), 
{bf:latex or tex} (latex style),
{bf:html} (html style) and
{bf:md} (markdown style, experimental) 
.{p_end}
{synopt:{opt d:ecimals(string)}} Matrix of integers specifying numbers of 
decimals at cell level. If the matrix is smaller than the data matrix the right
most column is copied to get the same number of columns. 
And likewise for the bottom row.{p_end}
{synopt:{opt ti:tle(string)}} Title/caption for the matrix output.{p_end}
{synopt:{opt to:p(string)}} String containing text prior to table content.
Default is dependent of the value of the style option.{p_end}
{synopt:{opt u:ndertop(string)}} String containing text between header and table 
content.
Default is dependent of the value of the style option.{p_end}
{synopt:{opt b:ottom(string)}} String containing text after to table content.
Default is dependent of the value of the style option.{p_end}
{synopt:{opt r:eplace}} Delete an existing {help using:using} file before adding table.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:regmat} is prefix command to a regression template.{break}
A regression template is simply a regression command.{break}
Each combination of one outcome variable, one exposure variable and one 
adjustment set is inserted just after the regression command.{break}
Then all regression estimates of exposures are placed in a matrix ordered by 
outcome and exposure variables rowwise and adjustment columnwise.

{pstd}
The resulting matrix is saved in the {help return:return list} for further 
usage.

{pstd}
The {help regmat##matprint:matprint options} makes it easy to integrate the
result table into a {help log2markup:log2markup output file}.

{pstd}
Together with the {help basetable:basetable} the command {cmd:regmat} 
generates the two typical tables for reporting epidemiological research.{break}
The resulting tables are easy to integrate into the final text using eg. {help log2markup:log2markup output file} or {help putexcel:putexcel}.

{marker examples}{...}
{title:Examples}

{pstd}Get example data:{p_end}

{phang}{stata `"sysuse nlsw88.dta, clear"'}{p_end}

{pstd}To estimate the effect of being married and having a college grade on 
wages and working hours, {it:wage} is primary outcome and 
{it:hours} is secondary outcome. Both are assumed continuous.{p_end}

{pstd}The variables {it:married} and {it:collgrad} are the two exposures whos effect 
are to be estimated.{p_end}

{pstd}We want crude estimates ("") and adjusted for {it:age} and {it:race} ("age i.race").{break}
In the regression we use the option vce(robust).{p_end}

{phang}{stata `"regmat, outcome(wage hours) exposure(i.married i.collgrad) adjustment("" "age i.race"): regress, vce(robust)"'}{p_end}

{pstd}The result is:{p_end}

    -----------------------------------------------------------------------------------------------------------------------------------
                     Adjustment 1                                              Adjustment 2                                            
                                b  se(b)  Lower 95% CI  Upper 95% CI  P value             b  se(b)  Lower 95% CI  Upper 95% CI  P value
    -----------------------------------------------------------------------------------------------------------------------------------
    wage   married          -0.49   0.26         -1.01          0.03     0.06         -0.78   0.28         -1.33         -0.24     0.00
           collgrad          3.62   0.30          3.02          4.21     0.00          3.52   0.31          2.92          4.13     0.00
    hours  married          -3.14   0.43         -3.99         -2.29     0.00         -3.06   0.44         -3.93         -2.20     0.00
           collgrad          2.11   0.56          1.00          3.21     0.00          2.22   0.56          1.12          3.32     0.00
    -----------------------------------------------------------------------------------------------------------------------------------

{pstd}The result matrix {it:r(regmat)} can also be exported to Excel in Stata 
13.1 and onwards using {help:putexcel}.
{p_end}

{browse "http://www.bruunisejs.dk/StataHacks/My%20commands/regmat/regmat_demo/":To see more examples}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:regmat} stores the following in {cmd:r()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 25 2: locals}{p_end}
{synopt:{cmd:r(Adjustment_#)}}Adjustment number #.{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 25 2: Matrix}{p_end}
{synopt:{cmd:r(regmat)}}The matrix containing regression estimates of the 
exposures{p_end}


{marker author}{...}
{title:Authors and support}

{phang}{bf:Author:}{break}
 	Niels Henrik Bruun, {break}
	Section for General Practice, {break}
	Dept. Of Public Health, {break}
	Aarhus University
{p_end}
{phang}{bf:Support:} {break}
	{browse "mailto:nhbr@ph.au.dk":nhbr@ph.au.dk}
{p_end}
