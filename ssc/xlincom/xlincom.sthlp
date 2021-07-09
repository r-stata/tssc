{smcl}
{* *! version 1.0.3  26jun2020}{...}
{vieweralsosee "[R] lincom" "mansection R lincom"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] nlcom" "help nlcom"}{...}
{vieweralsosee "[R] test" "help test"}{...}
{vieweralsosee "[R] testnl" "help testnl"}{...}
{viewerjumpto "Syntax" "xlincom##syntax"}{...}
{viewerjumpto "Description" "xlincom##description"}{...}
{viewerjumpto "Options" "xlincom##options"}{...}
{viewerjumpto "Examples" "xlincom##examples"}{...}
{viewerjumpto "Stored results" "xlincom##results"}{...}
{viewerjumpto "Acknowledgments" "xlincom##acknowledgments"}{...}
{viewerjumpto "Author" "xlincom##author"}{...}
{viewerjumpto "See also" "xlincom##see_also"}{...}


{title:Title}

{phang}
{bf:xlincom} {hline 2} Multiple linear combinations of parameters


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:xlincom} {cmd:(}[({it:name})] {it:{help exp}}{cmd:)} [{cmd:(}[({it:name})] {it:{help exp}}{cmd:)} ...] [{cmd:,} {it:options}]

{synoptset 16}{...}
{synopthdr}
{synoptline}
{synopt :{opt ef:orm(string)}}user-specified label{p_end}
{synopt :{opt or}}odds ratio{p_end}
{synopt :{opt hr}}hazard ratio{p_end}
{synopt :{opt shr}}subhazard ratio{p_end}
{synopt :{opt ir:r}}incidence-rate ratio{p_end}
{synopt :{opt rr:r}}relative-risk ratio{p_end}

{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt df(#)}}use t distribution with {it:#} degrees of freedom for
       computing p-values and confidence intervals{p_end}
{synopt :{opt post}}post estimation results{p_end}
{synopt :{opt covzero}}set all covariances to zero{p_end}
{synopt :{opt nohead:er}}suppress header output{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
{it:exp} is any linear combination of coefficients that is valid
syntax for {helpb lincom:lincom}. The exception is when option {opt post}
without {opt covzero} is specified, see {helpb xlincom##remarks:remarks}. All linear combinations must 
be contained within parentheses. An optional {it:name} may be specified, within parentheses,
to label the transformation; {it:name} can be any valid Stata name. 


{marker description}{...}
{title:Description}

{pstd}
{cmd:xlincom} computes point estimates, standard errors, t or z statistics,
p-values, and confidence intervals for multiple linear combinations of coefficients as well as their 
covariances. {helpb nlcom:nlcom} is also able to do this, but {cmd:xlincom} is much faster 
(up to 300 times for complex models). {cmd:xlincom} internally calls {helpb lincom:lincom}
for each linear combination and extracts estimates and variances from its output.

{pstd}
If option {opt post} is specified, estimation results will be posted in {cmd:e()} for exporting to pretty tables
or subsequent testing. In this case {cmd:xlincom} also calculates covariances by default, but this
makes it about 2 times slower. Since {cmd:xlincom} is intended as a fast alternative to {helpb nlcom:nlcom}
for linear combinations, the option {opt covzero} may be specified. In this case {cmd:xlincom} does not
compute covariances, setting them to 0 instead. If covariances are set to zero the estimates of the 
transformations should not be tested against each other as that will yield invalid results.


{marker options}{...}
{title:Options}

{phang}
{opt eform(string)}, {opt or}, {opt hr}, {opt shr},  {opt irr}, and {opt rrr} all report
coefficient estimates as exp(b) rather than b. Only one of these options may be 
specified. {opt or} is the default after {cmd:logistic}. See {helpb lincom:help lincom} 
for more information about these options. 

{phang}
{opt level(#)} specifies the confidence level. The default is {cmd:level(95)} 
or as set by {helpb set level}.

{phang}
{opt df(#)} specifies that the t distribution with {it:#} degrees of
freedom be used for computing p-values and confidence intervals.
The default is to use {cmd:e(df_r)} degrees of freedom or the standard normal
distribution if {cmd:e(df_r)} is missing.

{phang}
{opt post} posts estimation results in e() for exporting results to pretty tables
or testing. The syntax is constrained if this option is specified without {opt covzero},
see {helpb xlincom##remarks:remarks}.

{phang}
{opt covzero} causes {cmd:xlincom} to set covariances to zero, which speeds it up
by about two times, and the syntax will not be constrained. The transformations should
not be tested against each other if this option is specified as that will yield invalid 
results. 

{phang}
{opt noheader} suppresses header output.


{marker remarks}{...}
{title:Remarks}

{pstd} 
If option {opt post} is not specified or {opt post} is specified together with option 
{opt covzero}, {cmd:xlincom} does not have to calculate covariances and {cmd:xlincom} will 
accept any syntax that is valid for {helpb lincom:lincom}. However, if covariances need to be
calculated, {cmd:xlincom} needs to interpret the equations. {cmd:xlincom} has its own parser
to do that, which is not as smart as Stata's inbuilt parser. It will only recognize parameters
as they are found in {cmd:e(V)}. Type {cmd:matrix list e(V)} after the estimation command to see how
parameters are named. Furthermore, it will only accept one multiplication or division per 
parameter. For example, {cmd:2/3 * mpg} would be invalid. Instead, type {cmd:0.667 * mpg} 
or {cmd:mpg / 1.5}.


{marker examples}{...}
{title:Examples}

{pstd}Example taken from {helpb lincom:help lincom}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse regress}{p_end}
{phang2}{cmd:. regress y x1 x2 x3}{p_end}

{pstd}Estimate linear combinations of coefficients with {cmd:lincom}{p_end}
{phang2}{cmd:. lincom x2-x1}{p_end}
{phang2}{cmd:. lincom 3*x1 + 500*x3}{p_end}
{phang2}{cmd:. lincom 3*x1 + 500*x3 - 12}{p_end}

{pstd}Estimate linear combinations of coefficients with {cmd:xlincom}{p_end}
{phang2}{cmd:. xlincom (x2-x1) (3*x1 + 500*x3) (3*x1 + 500*x3 - 12)}{p_end}

{pstd}Estimate linear combinations of coefficients with {cmd:xlincom}, label transformations{p_end}
{phang2}{cmd:. xlincom ((name1) x2-x1) ((name2) 3*x1 + 500*x3) ((name3) 3*x1 + 500*x3 - 12)}{p_end}

{pstd}Estimate linear combinations of coefficients with {cmd:xlincom}, label transformations and post results{p_end}
{phang2}{cmd:. xlincom ((name1) x2-x1) ((name2) 3*x1 + 500*x3) ((name3) 3*x1 + 500*x3 - 12), post}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:xlincom} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(table)}}coefficient table{p_end}
{p2colreset}{...}

{pstd}
If option {opt post} is specified, {cmd:xlincom} stores the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_r)}}degrees of freedom{p_end}

{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(predict)}}xlincom_p{p_end}
{synopt:{cmd:e(cmd)}}xlincom{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}
{p2colreset}{...}


{marker acknowledgments}{...}
{title:Acknowledgments}

{pstd} 
I would like to thank Roger Newson, as some of the code of {cmd:xlincom} 
is based on the code of his command {cmd:lincomest}. 

{pstd}
Since much of {cmd:xlincom}'s options are the same as {cmd:lincom}'s I have 
used information from the help file of {helpb lincom:lincom} while making 
this help file for consistency and clarity, especially for shared options.


{marker author}{...}
{title:Author}

{pstd}
Wouter Wakker, wouter.wakker@outlook.com


{marker see_also}{...}
{title:See also}

{pstd}
{helpb lincom:lincom}, {helpb nlcom:nlcom}, {helpb test:test}, {helpb testnl:testnl}
