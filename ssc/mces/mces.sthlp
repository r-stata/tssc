{smcl}
{* *! version 1.0.1  May 13, 2020}{...}
{cmd:help mces}
{cmd:help svysd}
{hline}
{viewerjumpto "Syntax" "mces##syntax"}{...}
{viewerjumpto "Options table" "mces##options_table"}{...}
{viewerjumpto "Description" "mces##description"}{...}
{viewerjumpto "Options" "mces##options"}{...}
{viewerjumpto "Examples" "mces##examples"}{...}
{viewerjumpto "Stored results" "mces##stored_results"}{...}
{viewerjumpto "References" "mces##references"}{...}

{title:Title}

{p2colset 4 9 12 2}{...}
{p2col:{bf: mces}}{hline 2} Standardized effect sizes for comparisons between
predicted values of continuous outcome variables after {cmd:margins} or
{cmd:mimrgns}{p_end}

{p2colset 3 9 12 2}{...}
{p2col:{bf: svysd}}{hline 2} Pooled standard deviations for continuous outcome
variables when data are {cmd:svyset} or {cmd:mi svyset}{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8 2}
Syntax after {cmd:margins, pwcompare post} or {cmd:mimrgns, pwcompare post} 
({cmd:contrast post} is also supported):

{p 8 15 2}
{cmd:mces,} sdbyvar({it:varname}) [{it:options}]


{p 4 8 2}
To calculate the standard deviation only:

{p 8 15 2}
{cmd:svysd} {it:outcomevar}, sdbyvar({it:varname}) [{it:options}]


{marker options_table}{...}
{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt sdby:var(varname)}}dichotomous indicator variable defining 
comparison groups{p_end}
{synopt:{opt coh:ensd}}estimate Cohen's {it:d} instead of Hedges's {it:g} [{cmd:mces} only]{p_end}
{synopt:{opt unw:eighted}}calculate the unweighted standard deviation used for Cohen's {it:d} [{cmd:svysd} only]{p_end}
{synopt:{opt sdu:pdate}}re-calculate the standard deviation{p_end}
{synopt:{opt now:arning}}suppress warning messages{p_end}
{synopt:{opt f:orce}}do not check for continuous outcome variable{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:mces} calculates the standardized effect size statistic Hedges's {it:g} 
(Hedges, 1981), or optionally Cohen's {it:d} (Cohen, 1988), for between-group 
contrasts of marginal effects obtained either from {cmd:margins} or 
{cmd:mimrgns} (Klein, 2016). Hedges's {it:g} is similar to Cohen's {it:d} 
but uses a pooled standard deviation (sd*) that is weighted by the sample sizes 
in each group, which is preferable in instances where the group sizes are 
unequal (Ellis, 2010). Hedges's {it:g} reduces to be equivalent to Cohen's 
{it:d} when the group sizes are the same. 

{pstd}
{cmd:mces} can process estimates when data are {cmd:svyset} or {cmd:mi svyset}. 
{cmd:mces} calls {cmd:svysd}, but remembers the standard deviation if 
the outcome variable remains the same. Note that the command uses the sampling 
weights to estimate population sample sizes, rather than the unweighted number 
of cases, when weighting the standard deviation. The {cmd:sdupdate} 
option forces {cmd:svysd} to update the standard deviation if necessary.
If only the pooled weighted standard deviation is desired, 
but not the effect size, then {cmd:svysd} can be used as a standalone command.

{pstd}
The {cmd:mces} command should work with most regression-type models followed by 
{cmd:margins, pwcompare post} or {cmd:mimrgns, pwcompare post} that store
their coefficients in {cmd:e(b_vs)}. Comparisons produced by 
{cmd:margins, contrast post} or {cmd:mimrgns, contrast post} and stored in
{cmd:e(b)} are also supported. However, unless you have a strong reason to 
prefer {cmd:contrast}, {cmd:pwcompare} is probably preferable, as it is 
more likely by default to estimate comparisons for which the pooled standard 
deviation (and thus the reported effect size) is valid. {cmd:mces} is not 
appropriate for multilevel/hierarchical linear/mixed-effects models (see Lorah,
2018). {cmd:svysd} is not a postestimation command and functions independently.

{marker options}{...}
{title:Options}

{it:{dlgtab:Identifying the comparison groups}}

{phang}
{opt sdbyvar(varname)} specifies the variable name that indicates assignment to 
one of the two groups whose marginal effects are contrasted (e.g., the treatment 
group and the control group). The {cmd:sdbyvar} must be dichotomous.
The program will return an error message if the variable has more than two 
values, even if options such as {cmd:at} or {cmd:subpop} mean 
that only two of the levels are used by {cmd:margins}. The 
{cmd:recode, generate()} command is useful for creating dichotomous grouping
variables to help ensure a valid estimate of the standard deviation.

{it:{dlgtab:Options for Cohen's d}}

{phang}
{opt cohensd} (for {cmd:mces}) requests estimates of Cohen's {it:d} instead of 
the default Hedges's {it:g}. 

{phang}
{opt unweighted} (for {cmd:svysd}) requests the unweighted pooled standard 
deviation used for Cohen's {it:d}.

{it:{dlgtab:Other options}}

{phang}
{opt sdupdate} requests the re-calculation of the pooled standard 
deviation. {cmd:mces} stores the standard deviation from the last estimation 
in a scalar, and typically does not re-estimate it if the outcome variable is 
the same. Use the {cmd:sdupdate} option to update the standard deviation if 
necessary (e.g., if the dataset has changed).

{phang}
If there are comparisons reported by {cmd:margins, pwcompare} (or {cmd:contrast})
for which the reported effect size might not be applicable, the program will return a
warning message. The {opt nowarning} option suppresses these messages.

{phang}
{opt force} bypasses the program's attempt to ensure that the outcome variable
is continuous. While Hedges's {it:g} and Cohen's {it:d} are designed for 
continuous outcome variables, this option allows you to use it (at your own 
risk!) for categorical outcomes if you are sure that the estimated standard 
deviation is correct and applicable, and that the coefficients from 
{cmd:margins} are comparable in this way. 

{marker examples}{...}
{title:Examples}

{pstd}Simple example{p_end}
{phang2}{stata "sysuse nlsw88"}{p_end}
{phang2}{stata "reg wage age hours i.union i.married i.union#i.married"}{p_end}
{phang2}{stata "margins union, pwcompare post"}{p_end}
{phang2}{stata "mces, sdby(union)"}{p_end}

{pstd}Two comparison variables{p_end}
{phang2}{stata "reg wage age hours i.union i.married i.union#i.married"}{p_end}
{phang2}{stata "margins union, over(married) pwcompare post"}{p_end}
{phang2}{stata "mces, sdby(union)"}{p_end}
{pstd}
Note the warning message: sd* applies to only "all else equal"
comparisons between {cmd:union=0} and {cmd:union=1}. Accordingly, 
{it:g} is only valid for rows 1 and 6 in the results. (Row 2, for example,
would need an sd* by {cmd:married}, and row 3 is not ceteris paribus). The 
program can't ensure that the results make sense--that's up to you!

{pstd}Cohen's {it:d}{p_end}
{phang2}{stata "reg wage age hours i.union i.married i.union#c.hours"}{p_end}
{phang2}{stata "margins union, at(hours=(20 40) married=1) pwcompare post"}{p_end}
{phang2}{stata "mces, sdby(union) cohensd"}{p_end}

{pstd}Simple {cmd:svyset} example{p_end}
{phang2}{stata "webuse nmihs"}{p_end}
{phang2}{stata "svyset [pweight=finwgt], strata(stratan)"}{p_end}
{phang2}{stata "svy: regress birthwgt age i.race i.multiple i.race#i.multiple"}{p_end}
{phang2}{stata "margins multiple, pwcompare(effects) post"}{p_end}
{phang2}{stata "mces, sdbyvar(multiple)"}{p_end}

{pstd}Using {cmd:mimrgns}{p_end}
{phang2}{stata "webuse nhanes2"}{p_end}
{phang2}{stata "mi set mlong"}{p_end}
{phang2}{stata "mi register imputed diabetes"}{p_end}
{phang2}{stata "mi impute chained (logit) diabetes = bpsystol female race age bmi, rseed(1111) add(5)"}{p_end}
{phang2}{stata "mi svyset [pw=finalwgt], psu(psu) strata(strata) singleunit(centered)"}{p_end}
{phang2}{stata "mi estimate: svy: regress bpsystol i.female race age i.diabetes i.diabetes#i.female"}{p_end}
{phang2}{stata "mimrgns female, at(diabetes=(0 1) (median) age) pwcompare post"}{p_end}
{phang2}{stata "mces, sdbyvar(female)"}{p_end}

{pstd}{cmd:svysd} as a standalone command{p_end}
{phang2}{stata "webuse nmihs"}{p_end}
{phang2}{stata "svyset [pweight=finwgt], strata(stratan)"}{p_end}
{phang2}{stata "svysd birthwgt, sdby(multiple)"}{p_end}


{marker stored_results}{...}
{title:Stored results}

{pstd}
{cmd:mces} and {cmd:svysd} save the following in {cmd:r()}: 

{pstd}Scalars:{p_end}
{synoptset 24 tabbed}{...}

{synopt:{cmd:r(sdstar)}}sd*, the pooled weighted standard deviation for Hedges's {it:g}{p_end}
       or
{synopt:{cmd:r(pooledsd)}}the unweighted pooled weighted standard deviation for Cohen's {it:d}{p_end}

{synopt:{cmd:r(n_{sdbyvar}_at_#)}}the sample size in the group {cmd:sdbyvar=#}{p_end}
{synopt:{cmd:r(n_{sdbyvar}_at_#)}}the sample size in the group {cmd:sdbyvar=#}{p_end}
{synopt:{cmd:r(sd_{sdbyvar}_at_#)}}the standard deviation for the group {cmd:sdbyvar=#}{p_end}
{synopt:{cmd:r(sd_{sdbyvar}_at_#)}}the standard deviation for the group {cmd:sdbyvar=#}{p_end}

{pstd}Matrices ({cmd:mces} only):{p_end}
{synopt:{cmd:r(g)}}the estimated Hedges's {it:g} values{p_end}
       or
{synopt:{cmd:r(d)}}the estimated Cohen's {it:d} values{p_end}

{pstd}Macros:{p_end}
{synopt:{cmd:r(depvar)}}the outcome variable{p_end}
{synopt:{cmd:r(sdbyvar)}}the margins variable{p_end}

{marker references}{...}
{title:References}

{pstd}Cohen, J. (1988). Statistical power analysis for the behavioral sciences. 
Lawrence Erlbaum Associates.

{pstd}Ellis, P. D. (2010). The essential guide to effect sizes: Statistical 
power, meta-analysis, and the interpretation of research results. Cambridge 
University Press.

{pstd}Hedges, L. V. (1981). Distribution theory for Glass’s estimator of effect 
size and related estimators. Journal of Educational Statistics, 6(2), 107–128. 
{browse "https://doi.org/10.3102/10769986006002107"}

{pstd}Klein, D. (2016). Marginal effects in multiply imputed datasets. 
14th German Stata Users Group Meeting, Cologne, Germany. 
{browse "https://www.stata.com/meeting/germany16/slides/de16_klein.pdf"}{p_end}

{pstd}Lorah, J. (2018). Effect size measures for multilevel models: definition, 
interpretation, and TIMSS example. Large-scale Assessments in Educucation, 6, 8. 
{browse "https://doi.org/10.1186/s40536-018-0061-2"}{p_end}

{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
Miguel Dorta and Daniel Klein contributed helpful advice during the development 
process.{p_end}

{marker author}{...}
{title:Author}

{pstd}Brian Shaw, Indiana University, USA{p_end}
{pstd}bpshaw@indiana.edu{p_end}
