{smcl}
{* *! version 1.0.0 02Aug2020}{...}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi:diagsampsi} {hline 2}} Sample size for a single diagnostic test with a binary outcome {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}
Sample size for sensitivity:

{p 8 14 2}
{cmd:diagsampsi} {opt sens:itivity}
{it: sn}
[{cmd:,}
{opt p:rev(#)}
{opt w:idth(#)}
{opt lev:el(#)}
]

{pstd}
Sample size for specificity:

{p 8 14 2}
{cmd:diagsampsi} {opt spec:ificity}
{it: sp}
[{cmd:,} 
{opt p:rev(#)}
{opt w:idth(#)}
{opt lev:el(#)}
]


{pstd}
In the syntax for {cmd:diagsampsi} {opt sensitivity}, {it:sn} refers to the expected sensitivity of the new diagnostic test 
and in the syntax for {cmd:diagsampsi} {opt specificity}, {it:sp} refers to the expected specificity of the new diagnostic test



{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt p:rev(#)}}specify the prevalence of disease in the target population (ranging from 0.01 to 1.0); default is {cmd: prev(0.50)}{p_end}
{synopt :{opt w:idth(#)}}specify the maximum clinically acceptable width of the confidence interval (ranging from 0.01 to 1.0); default is {cmd: width(0.10)}{p_end}
{synopt:{opt lev:el(#)}}set confidence level; default is {cmd:level(95)} or as set by {helpb set level}{p_end}
{synoptline}



{marker description}{...}
{title:Description}

{pstd}
{opt diagsampsi} performs sample size calculations for sensitivity and specificity of a single diagnostic test with a binary outcome, according to Buderer (1996). {cmd:diagsampsi} is an immediate command; see {help immed}
for more on immediate commands. {p_end}

{pstd}
The sample size computation depends on 3 quantities that the user must specify: 
(1) the expected sensitivity (specificity) of the new diagnostic test,
(2) the prevalence of disease in the target population, and
(3) a clinically acceptable width of the a confidence interval for the estimates. Optionally, {opt diagsampsi} allows the user to choose the confidence level. 

{pstd}
In many cases, the user will want to compute a sample size that accounts for a different level of sensitivity and specificity 
(e.g. 80% and 60% for sensitivity and specificity, respectively). In this case, the larger of the two sample size estimates should be used to ensure the desired
precision is preserved.



{title:Options}

{p 4 8 2}
{opt p:rev(#)} specifies the prevalence of disease in the target population (ranging from 0.01 to 1.0); default is {cmd: prev(0.50)}. 
(Note that this is an entirely arbitrary level and a known or estimated level is always preferred). For sensitivity, a higher prevalence requires a smaller
sample size, whereas for specificity, a higher prevalence requires a higher sample size.  

{p 4 8 2}
{opt w:idth(#)} specifies the maximum clinically acceptable width of the confidence interval (ranging from 0.01 to 1.0); default is {cmd: width(0.10)}.
The narrower the specified {opt width} the larger the sample size required, and vice versa.

{p 4 8 2}
{opt lev:el(#)} specifies the confidence level, as a percentage, for confidence intervals. The default is {cmd:level(95)} or as set by 
{helpb set level}.



{title:Examples}

{pstd}
{opt 1) Sample size for sensitivity:}{p_end}

{pmore} Sensitivity example from Buderer (1996) {p_end}
{pmore2}{bf:{stata "diagsampsi sens 0.90, prev(0.20) width(0.10)": . diagsampsi sens 0.90, prev(0.20) width(0.10)}} {p_end}

{pstd}
{opt 2) Sample size for specificity:}{p_end}

{pmore} Specificity example from Buderer (1996) {p_end}
{pmore2}{bf:{stata "diagsampsi spec 0.85, prev(0.20) width(0.10)": . diagsampsi spec 0.85, prev(0.20) width(0.10)}} {p_end}

{pmore} If the user is interested in identifying a sample size appropriate for both sensitivity and specificity, 
then the larger of the two estimates should be used (in this case, the N for sensitivity = 173, and is larger than the N for 
specificity = 62) {p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:diagsampsi} stores the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}the estimated sample size{p_end}
{synopt:{cmd:r(prev)}}the user specified prevalence{p_end}
{synopt:{cmd:r(width)}}the user specified width of the confidence interval{p_end}
{synopt:{cmd:r(level)}}the user specified confidence interval{p_end}
{synopt:{cmd:r(sens)}}the user specified expected sensitivity {p_end}
{synopt:{cmd:r(spec)}}the user specified expected specificity {p_end}

{p2colreset}{...}



{title:References}

{p 4 8 2}
Buderer, N. M. (1996). Statistical methodology: I. Incorporating the prevalence of disease into the sample size calculation for sensitivity and specificity. 
{it: Acad Emerg Med}. 3: 895-900. 



{marker citation}{title:Citation of {cmd:diagsampsi}}

{p 4 8 2}{cmd:diagsampsi} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A (2020). DIAGSAMPSI: Stata module for computing sample size for a single diagnostic test with a binary outcome.



{title:Author}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb power oneproportion}{p_end}

