{smcl}
{* *! version 1.0  Jan 2015}{...}
{cmd:help itercenter}{right: ({browse "http://www.stata-journal.com/article.html?article=st0409":SJ15-3: st0409})}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{cmd:itercenter} {hline 2}}Demean variables with respect to multiple categorical variables{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmdab:itercenter} {varlist} {ifin} {weight}{cmd:,} {cmd:fe(}{it:{help varlist:fe_varlist}}{cmd:)} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt fe(fe_varlist)}}specify the list of variables used for the iterative demeaning process; must include at least one categorical variable{p_end}
{synopt:{opt tolerance(#)}}specify the convergence criteria; default is {helpb epsfloat()}{p_end}
{synopt:{opt maxiter(#)}}specify the maximum number of iterations allowed; default is {cmd:maxiter(10000)}{p_end}
{synopt:{opt mean}}calculate mean in transformed data{p_end}
{synopt:{opt replace}}replace the original variable with the transformed data{p_end}
{synopt:{opt xfe(str)}}create a new variable with the transformed data{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
* {cmd:fe()} is required.{p_end}
{p 4 6 2}
{cmd:aweight}s, {cmd:fweight}s, {cmd:iweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:itercenter} implements an iterative demeaning process of all variables in
{it:varlist} with respect to the variables declared in the {cmd:fe()} option.  The
transformed variable is stored in double format, and it substitutes the
current one.  If the {cmd:mean} option is specified, the transformed variable
will preserve the overall mean (this is the
default option when using {helpb regxfe}).


{marker options}{...}
{title:Options}

{phang}
{opt fe(fe_varlist)} specifies the categorical variables used for the iterative demeaning
process.  The user must include at least one categorical
variable to proceed with demeaning transformation. {cmd:fe()} is required.

{phang}
{opt tolerance(#)} specifies the convergence criteria to be used to
transform variables. Using low tolerance levels can slow down the processing
time but increase the accuracy of the estimates. The default is 
{helpb epsfloat()}.

{phang}
{opt maxiter(#)} specifies the maximum number of iterations allowed. If
convergence is not achieved, a small number of iterations reduce the accuracy
of the results. The default is {cmd:maxiter(10000)}.

{phang}
{opt mean} specifies to calculate the mean in the transformed data and
preserve the overall mean. This is the default option for {helpb regxfe}.

{phang}
{opt replace} specifies to replace an existing variable with the same name
with the transformed data.  This cannot be used in combination with 
{opt xfe(str)}, but one option must be selected.

{phang}
{opt xfe(str)} specifies to create a new variable with the transformed
data using the indicated prefix for the new variable name. Original variables are
kept in the dataset. This cannot be used in combination with {cmd:replace}, but one
option must be selected.


{title:Remarks}

{pstd}
The program uses the command {helpb center}. 


{marker examples}{...}
{title:Examples}

{phang}{cmd:. webuse nlswork}{p_end} 
{phang}{cmd:. itercenter ln_wage age grade union, fe(ind_code occ_code idcode year) replace}{p_end}

{phang}{cmd:. itercenter ln_wage age grade union, fe(ind_code occ_code idcode year) mean xfe(d)}{p_end}

 
{marker Author}{...}
{title:Author}

{pstd}Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Blithewood-Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org


{marker also_see}{...}
{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 3: {browse "http://www.stata-journal.com/article.html?article=st0409":st0409}{p_end}
