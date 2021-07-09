{smcl}
{cmd:help kappaetc_choosing}{right: ({browse "http://www.stata-journal.com/article.html?article=st0544":SJ18-4: st0544})}
{hline}

{title:Choosing an appropriate method of analysis}

{p 5 5 2}
The table below is intended to assist in choosing an appropriate method for 
analyzing agreement or reliability given the data level of measurement 
(compare Gwet [2014, 24]).

{col 6}Data/ratings{col 31}Method{col 55}Command
{col 6}{hline}
{col 6}categorical{...}
{col 31}unweighted agreement{...}
{col 55}{helpb kappaetc}
{col 6}nominal{...}
{col 31}coefficients

{col 6}ordinal{...}
{col 31}agreement coefficients{...}
{col 55}{helpb kappaetc##opt_wgt:kappaetc, wgt(ordinal)}
{col 31}with ordinal weights

{col 6}interval{...}
{col 31}agreement coefficients{...}
{col 55}{helpb kappaetc##opt_wgt:kappaetc, wgt(linear)}
{col 6}(predetermined ratings){...}
{col 31}with linear, quadratic,{...}
{col 55}{helpb kappaetc##opt_wgt:kappaetc, wgt(quadratic)}
{col 31}or radical weights{...}
{col 55}{helpb kappaetc##opt_wgt:kappaetc, wgt(radical)}

{col 6}ratio{...}
{col 31}agreement coefficients{...}
{col 55}{helpb kappaetc##opt_wgt:kappaetc, wgt()}
{col 6}(predetermined ratings){...}
{col 31}with any weights

{col 6}interval or ratio{...}
{col 31}intraclass correlation{...}
{col 55}{helpb kappaetc_icc:kappaetc, icc()}
{col 31}coefficients

{col 6}interval or ratio{...}
{col 31}intraclass correlation{...}
{col 55}{helpb kappaetc_icc:kappaetc, icc() id()}
{col 6}(intrarater reliability){...}
{col 31}coefficients
{col 6}{hline}


{marker krippendorff}{...}
{title:Krippendoff's (2011, 2013) metric difference functions}

{pstd}
Krippendorff (2011, 2013) uses the term "metric difference functions" for the
weights that account for partial agreement or disagreement implied by the
data's level of measurement.  The weights that correspond to the respective
metric difference functions are summarized below.

{col 8}Metric{col 29}Corresponding
{col 8}difference function{col 29}weight{col 44}Command
{col 8}{hline}
{col 8}categorical{...}
{col 29}none{...}
{col 44}{helpb kappaetc}
{col 8}nominal{...}
{col 29}identity{...}
{col 44}{helpb kappaetc##opt_wgt:kappaetc, wgt(identity)}

{col 8}ordinal{...}
{col 29}ordinal{...}
{col 44}{helpb kappaetc##opt_wgt:kappaetc, wgt(ordinal, krippendorff)}

{col 8}interval{...}
{col 29}quadratic{...}
{col 44}{helpb kappaetc##opt_wgt:kappaetc, wgt(quadratic)}

{col 8}ratio{...}
{col 29}ratio{...}
{col 44}{helpb kappaetc##opt_wgt:kappaetc, wgt(ratio)}

{col 8}circular{...}
{col 29}circular{...}
{col 44}{helpb kappaetc##opt_wgt:kappaetc, wgt(circular)}

{col 8}bipolar{...}
{col 29}bipolar{...}
{col 44}{helpb kappaetc##opt_wgt:kappaetc, wgt(bipolar)}
{col 8}{hline}


{title:References}

{phang}
Gwet, K. L. 2014. {it:Handbook of Inter-Rater Reliability: The Definitive Guide to Measuring the Extent of Agreement Among Raters}. 4th ed. Gaithersburg, 
MD: Advanced Analytics.

{phang}
Krippendorff, K. 2011. Computing Krippendorff's alpha-reliability.  
{browse "https://repository.upenn.edu/asc_papers/43/"}.

{phang}
------. 2013. {it:Content Analysis. An Introduction to Its Methodology}. 3rd
ed. Thousand Oaks, CA: Sage.


{title:Author}

{pstd}
Daniel Klein{break}
International Centre for Higher Education Research Kassel{break}
Kassel, Germany{break}
klein@incher.uni-kassel.de


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 4: {browse "http://www.stata-journal.com/article.html?article=st0544":st0544}{p_end}

{p 7 14 2}
Help:  {helpb kappaetc} (if installed){p_end}
