{smcl}
{* 15aug2014}{...}
{title:Title}

{pstd}{hi:hte} {hline 2} Heterogeneous Treatment Effect Analysis


{title:Syntax}

{pstd}
    Stratification-Multilevel Method (SM):

{p 8 15 2}
    {helpb hte sm} {it:...}

{pstd}
    Matching-Smoothing Method (MS):

{p 8 15 2}
    {helpb hte ms} {it:...}

{pstd}
    Smoothing-Differencing Method (SD):

{p 8 15 2}
    {helpb hte sd} {it:...}


{title:Description}

{pstd}
    {cmd:hte} performs heterogeneous treatment effect analyses as proposed by
    Xie, Brand, and Jann (2012). Three methods are supported, the 
    stratification-multilevel method (see help {helpb hte sm}), the 
    matching-smoothing method (see help {helpb hte ms}), and the
    smoothing-differencing method (see help {helpb hte sd}).


{title:Dependencies}

{pstd}
    {helpb hte sm} requires {cmd:pscore} (Becker and Ichino 2002) and 
    {helpb hte ms} requires {cmd:psmatch2} (Leuven and Sianesi 2003). To 
    install these programs on your system, type:
    
        . {stata "net install st0026_2, from(http://www.stata-journal.com/software/sj5-3)"}
        . {stata "ssc install psmatch2"}


{title:References}

{phang}
    Becker, Sascha O., Andrea Ichino. 2002. Estimation of average treatment
    effects based on propensity 
    scores. {browse "http://www.stata-journal.com/article.html?article=st0026":The Stata Journal 2(4):358-377}.
    {p_end}

{phang}
    Leuven, E. and B. Sianesi. 2003. PSMATCH2: Stata module to perform full Mahalanobis and
    propensity score matching, common support graphing, and covariate imbalance testing.
    Available from {browse "http://ideas.repec.org/c/boc/bocode/s432001.html"}.
    {p_end}

{phang}
    Xie, Yu, Jennie E. Brand, Ben Jann. 2012. Estimating Heterogeneous Treatment 
    Effects with Observational 
    Data. {browse "http://dx.doi.org/10.1177/0081175012452652":Sociological Methodology 42: 314-347}.
    {p_end}


{title:Authors}

{pstd}
    Ben Jann (University of Bern, jann@soz.unibe.ch)
    {p_end}
{pstd}
    Jennie E. Brand (UCLA, brand@soc.ucla.edu)
    {p_end}
{pstd}
    Yu Xie (University of Michigan, yuxie@isr.umich.edu)
    {p_end}

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B., J. E. Brand, Y. Xie. 2010. hte: Stata module to perform
    heterogeneous treatment effect analysis. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s457129.html"}.


{title:Also see}

{psee}
    Online:  help for
    {helpb hte sm}, {helpb hte ms}, {helpb hte sd}
