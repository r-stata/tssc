{smcl}
{* *! version 1.6 20150617}{...}
{cmd:help stphcoxrcs}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:stphcoxrcs} {hline 1}}Check proportional-hazards assumption using restricted cubic splines{p_end}
{p2colreset}{...}


{title:Syntax}
{phang}

{p 8 13 2}
{cmd:stphcoxrcs} {varname} [{cmd:,} {it:{help stphcoxrcs##stphcoxrcs_options:stphcoxrcs_options}}]

{synoptset 30 tabbed}{...}
{marker stphcoxrcs_options}{...}
{synopthdr :stphcoxrcs_options}
{synoptline}
{syntab :Main}
{synopt :{opt nk:nots}(#)}specifies the number of knots for the restricted cubic spline transformations of ln(analysis time); default is {opt nk:nots}(3){p_end}
{synopt :{opt splitevery}(#)}splits records when analysis time is a multiple of #{p_end}
{synopt :{opt splitat}({it:{help numlist}})}splits records at specified analysis times; default is {opt splitat}(failures){p_end}

{syntab :Other}
{synopt :{opt lrt:est}}performs a likelihood ratio test on the interaction terms instead of a Wald test{p_end}
{synopt :{opt ic}}displays Akaike's and Schwarz's Bayesian information criteria{p_end}

{syntab :Plot}
{synopt :{opt l:evel(#)}}sets confidence level; default is {cmd:level}(95){p_end}
{synopt :{opt noci}}suppresses the confidence intervals{p_end}
{synopt :{opt noyref}}suppresses the reference line (Hazard Ratio = 1.00){p_end}
{synopt :{opt lnt:ime}}plots the Hazard Ratio according to ln(analysis time){p_end}
{synopt :{opt nog:raph}}suppresses graph{p_end}
{synopt :{opt range(# #)}}specifies the range for analysis time {p_end}
{synopt :{opt gopts}({it:{help twoway_options}})}modifies the graph{p_end}
{synopt :{opt saving}({it:filename} [{it:, replace}])}saves a dataset with the variables needed to reproduce the graph of the time-varying hazard ratio{p_end}

{synoptline}
{p2colreset}{...}
{phang}Note: You must {help stset} your data using the id() option before using stphcoxrcs{p_end}


{title:Description}

{pstd}
{cmd:stphcoxrcs} checks the proportional-hazards assumption for one covariate of interest (binary or continuous) after fitting a model with {opt stcox}. In particular, {cmd:stphcoxrcs} models the natural logarithm of analysis time using restricted cubic splines transformations, which are interacted with the covariate specified in {it: varname}. A joint Wald (default) or likelihood ratio test of all the interaction terms is carried out to test the proportional-hazards assumption. Lastly, {cmd:stphcoxrcs} produces a graph of the time-varying Hazard Ratio.


{title:Options for stphcoxrcs}

{dlgtab:Main}

{phang}{opt nk:nots}(#) specifies the number of knots for the restricted cubic spline transformations of log analysis time. The number of knots must be between 3 (default) and 5. The default knot positions are based on Harrell's recommended percentiles of the distribution of the uncensored natural logarithm of analysis time. See {help mkspline}.

{phang}{opt splitevery}(#) splits the records a each positive multiple of #. See {help stsplit}.

{phang}{opt splitat}({it:{help numlist}}) splits records at specified analysis times; {opt splitat}(failures) splits the records at failure times (default). See {help stsplit}.

{dlgtab:Other}

{phang}{opt lrt:est} performs a likelihood ratio test on all the interaction terms instead of a Wald test.

{phang}{opt ic} displays Akaike's and Schwarz's Bayesian information criteria.

{dlgtab:Plot}

{phang}{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}{opt noci} suppresses the confidence intervals for the time-varying Hazard Ratio.

{phang}{opt noyref} suppresses the reference line at Hazard Ratio = 1.00.

{phang}{opt lnt:ime} specifies that the time-varying Hazard Ratio is plotted against the natural logarithm of analysis time (instead of analysis time itself).

{phang}{opt nog:raph} suppresses displaying the graph.

{phang}{opt range(# #)} specifies the range for analysis time.

{phang}{opt gopts}({it:{help twoway_options}}) are any of the options documented in {help twoway_options}.

{phang}{opt saving}({it:filename} [{it:, replace}]) saves in a separate .dta file the variables needed to reproduce the graph of the time-varying Hazard Ratio. The dataset contains the following variables: Hazard Ratio, upper and lower confidence interval bounds, and analysis time.

{hline}

{title:Examples}

{pstd}{stata "use http://www.biostatepi.org/data/hers, clear"}{p_end}
{pstd}{stata "stset pafu, f(pa) id(id)"}{p_end}
{pstd}{stata "stcox group"}{p_end}
{pstd}{stata "stphcoxrcs group, splitevery(.2) nknots(3) range(.25 6) noyref"}{p_end}

{hline}

{title:References}

{pstd}Heinzl, H., & Kaider, A. (1997). Gaining more flexibility in Cox proportional hazards regression models with cubic spline functions. Computer methods and programs in biomedicine, 54(3), 201-208.{p_end}

{pstd}Therneau, T. M., & Grambsch, P. M. (2000). Modeling survival data: extending the Cox model. Springer-Verlag. New York.{p_end}

{pstd}Royston, P., & Lambert, P. C. (2011). Flexible parametric survival analysis using Stata: beyond the Cox model. Stata Press books.{p_end}

{hline}

{title:Authors}

{pstd}{browse "http://anddis.github.io":Andrea Discacciati}{p_end}
{pstd}{browse "http://ki.se/imm/nutrition-en":Unit of Nutritional Epidemiology}{p_end}
{pstd}{browse "http://www.imm.ki.se/biostatistics/":Unit of Biostatistics}{p_end}
{pstd}{browse "http://ki.se/imm":Institute of Environmental Medicine, Karolinska Institutet}{p_end}
{pstd}Stockholm, Sweden{p_end}

{pstd}Viktor Oskarsson{p_end}
{pstd}{browse "http://ki.se/imm/nutrition-en":Unit of Nutritional Epidemiology}{p_end}
{pstd}{browse "http://ki.se/imm":Institute of Environmental Medicine, Karolinska Institutet}{p_end}
{pstd}Stockholm, Sweden{p_end}

{pstd}{browse "http://nicolaorsini.altervista.org":Nicola Orsini}{p_end}
{pstd}{browse "http://ki.se/imm/nutrition-en":Unit of Nutritional Epidemiology}{p_end}
{pstd}{browse "http://www.imm.ki.se/biostatistics/":Unit of Biostatistics}{p_end}
{pstd}{browse "http://ki.se/imm":Institute of Environmental Medicine, Karolinska Institutet}{p_end}
{pstd}Stockholm, Sweden{p_end}

{hline}

{title:Support}

{pstd}andrea.discacciati@ki.se{p_end}

{hline}

{title:Saved results}

{pstd}
{cmd:stphcoxrcs} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(chi2)}}chi-squared statistic{p_end}
{synopt:{cmd:e(df)}}test constraints degrees of freedom{p_end}
{synopt:{cmd:e(p)}}p-value{p_end}
{synopt:{cmd:e(N_knots)}}number of knots{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(S)}} 1 x 6 matrix of results:{p_end}
                       1. sample size                   4. degrees of freedom
                       2. log likelihood of null model  5. AIC
                       3. log likelihood of full model  6. BIC
