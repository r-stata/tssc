{smcl}
{* *! version 1.1.0 10Aug2013}{...}
{* *! version 1.0.0 30Jul2013}{...}
{cmd:help svysampsi}
{hline}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col :{hi:svysampsi} {hline 2}}Sample size for surveys with a dichotomous outcome variable {p_end}
{p2colreset}{...}


{title:Syntax}

{pstd} {cmd:svysampsi} {it:#population} 
       [{cmd:,} {cmdab:p:roportion}{cmd:(}{it:#}{cmd:)} 
	{cmdab:moe:}{cmd:(}{it:#}{cmd:)} 
        {cmdab:lev:el}{cmd:(}{it:#}{cmd:)} 
        {cmdab:resp:onse}{cmd:(}{it:#}{cmd:)} ]
	
{p 8 14 2}{it:#population} is the size of the target population.{p_end}
 	

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt p:roportion(#)} specifies the proportion of the sample 
with the expected outcome. The default is {cmd:prop(0.50)}, and values must be
between 0 and 1.0.

{phang}
{opt moe(#)} specifies the margin of error, as a percent. The default is {cmd:moe(5.0)}, and values must be
between 0 and 100.
 
{phang}
{opt resp:onse(#)} 	specifies the expected response rate. When {cmd:response} is
specified, {cmd:svysampi} provides an adjusted sample size estimate. Values must be
between 0 and 1.0.

{phang}
{opt lev:el(#)} specifies the confidence level, as a percentage, for
confidence intervals.  The default is {cmd:level(95)} or as set by 
{helpb set level}.

{synoptline}
{p2colreset}{...}
	
{title:Description}

{pstd}
{cmd:svysampsi} estimates the finite population corrected sample size
for a simple random survey in which the primary variable under study is
dichotomous. {cmd:svysampsi} is an immediate command; see {help immed}
for more on immediate commands. {p_end}


{synoptline}
{p2colreset}{...}

{title:Remarks} 

{pstd}
There are many situations in which the primary variable being measured
in a survey is dichotomous or binary, and thus aggregates to a
proportion (e.g., the proportion of smokers in a population, the
proportion of voters that view a candidate favorably, etc.). In
estimating the sample size needed for the survey, the researcher must
consider three criteria:

{phang}1.  The {it:proportion} of the population expected to respond
positively to the question. Higher (or lower) proportions indicate
greater homogeneity in the population on this attribute, whereas a
proportion of 0.50 indicates the greatest amount of variability (50/50
split). When an a priori assumption cannot be made about a population's
expected level of the attribute, researchers typically set the
{it:proportion} at 0.50 to derive a conservative sample size estimate.
{p_end}

{phang}2.  The {it:margin of error} (or sampling error) represents the
range in which the true value of the population is expected to lie.
Thus, with 50% of a hypothetical survey sample indicating that they
smoke, and a 5% {it:margin of error}, we would estimate that between 45%
and 55% of the overall population are smokers. Other things being equal,
larger margins of error produce smaller sample size estimates.   

{phang}3.  The {it:confidence level} is used in conjunction with the
{it:margin of error}. For example, assuming a normally distributed
variable and a 95% confidence level, we would expect that 95 out of 100
randomly drawn samples will elicit a true population proportion that is
within the range of the {it:proportion} +/- the {it:margin of error}.
Other things being equal, lower confidence levels produce lower sample
size estimates. 

{pstd}
In addition, the researcher may want to oversample from the population
to account for non-response. In {cmd:svysampsi}, when the expected
response rate is specified, an additional "over-sample" size estimate is
provided. {p_end}

{pstd}
Lastly, {cmd:svysampsi} estimates the sample size assuming a simple
random sample design is being utilized. If a more complex design is
planned, such as stratified random sampling, sample sizes at the level
of strata should be estimated. An example is provided below for how
{cmd:svysampsi} can be modified for this purpose.{p_end}
  

{title:Examples}

{pstd}
Example 1: Assumes default settings; prop=0.50, level=95.0, moe=5.0

{cmd}{...}
    . svysampsi 10000
{txt}{...}
 
{pstd}
Example 2: Specifies all options, including an expected response rate of 65%

{cmd}{...}
    . svysampsi 10000, prop(0.80) moe(3.0) lev(99) resp(0.65)
{txt}{...}

{pstd}
Example 3: A routine for estimating sample sizes by strata, and then
summing them to provide an overall value.  Here we specify 3 strata with
population sizes of 390, 121 and 42, with respective proportions of 0.5,
0.2, and 0.3.  We set the moe=3.0, and level=95

{cmd}{...}
    scalar ss_all = 0
    forval k = 1/3 {
             local i : word `k' of 390 121 42
             local j : word `k' of 0.5 0.2 0.3
             svysampsi `i', p(`j') lev(95) moe(3.0) 
             scalar ss_all = ss_all + r(adjss) 
    }
    di scalar(ss_all)
    di as text "Estimated total required sample size:" 
    di as text "       n = " as result scalar(ss_all) 
{txt}{...}

{pstd} Or for a somewhat different look...

{cmd}{...}
    tempname resmat
    forvalues k = 1/3 {
         local i : word `k' of 390 121 42
         local j : word `k' of 0.5 0.2 0.3
         svysampsi `i', p(`j') lev(95) moe(3.0) 
        matrix `resmat' = nullmat(`resmat') \ r(adjss)
        local names `"`names' `"`i'"'"'
    }
    mat colnames `resmat' = "Sample Size"
    mat rownames `resmat' = `names'
    matlist `resmat' , row("Strata Size")
{txt}{...}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:svysampsi} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(pop)}} user-entered population size {p_end}
{synopt:{cmd:r(prop)}} user-entered proportion {p_end}
{synopt:{cmd:r(moe)}} user-entered margin of error {p_end}
{synopt:{cmd:r(resp)}} user-entered response rate {p_end}
{synopt:{cmd:r(ss)}} unadjusted sample size {p_end}
{synopt:{cmd:r(adjss)}} finite population corrected sample size {p_end}
{synopt:{cmd:r(resp_adjss)}} response-rate adjusted sample size {p_end}

{p2colreset}{...}


{title:References}

{p 4 8 2}
Lohr, Sharon L. 2010. {it:Sampling: Design and Analysis, 2nd Ed.} Boston: Cengage Learning.{p_end}

{p 4 8 2}
Cochran, William G. 1977. {it:Sampling Techniques, 3nd Ed.} New York: John Wiley and Sons, Inc.{p_end}

{p 4 8 2}
Sudman, Seymour. 1976. {it:Applied Sampling.} New York: Academic Press.{p_end}

{p 4 8 2}
Kish, Leslie. 1965. {it:Survey Sampling.} New York: John Wiley and Sons, Inc.{p_end}

{marker citation}
{title:Citation of {cmd:svysampsi}}

{p 4 8 2}{cmd:svysampsi} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 4 2}
Linden, Ariel (2013). svysampsi: Stata module for estimating sample size for surveys with a dichotomous outcome variable. 
{browse "http://www.lindenconsulting.org":http://www.lindenconsulting.org} {p_end}


{title:Author}

{p 4 8 2}	Ariel Linden{p_end}
{p 4 8 2}	President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}	Ann Arbor, MI, USA{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
{p 4 8 2}{browse "http://www.lindenconsulting.org"}{p_end}

         
{title:Acknowledgments} 

{p 4 4 2} I would like to thank Nicholas J. Cox for providing helpful guidance in writing the code used in Example 3, as
well as providing a review of the overall program code and help file.


{title:Also see}

{p 4 8 2} Manual: {bf:[R] sampsi,} {bf:[D] sample}{p_end} 

{p 4 8 2} Online:  {helpb sampsi,} {helpb sample}{p_end}

