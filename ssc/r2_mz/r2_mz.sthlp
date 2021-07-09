{smcl}
{* January 04, 2012 @ 12:30:00 DE}{...}
{hi:help r2_mz}
{hline}

{title:Title}

{pstd}
{cmd:r2_mz} - McKelvey & Zavoina's R2 for multilevel logistic regression and random effects logit and probit models
{p_end}

{title:Syntax}
{phang}

   {cmd: r2_mz}

{title:Description}

{pstd} {cmd:r2_mz} is a post-estimation command that computes McKelvey & Zavoina's R2 for
multilevel logistic regression, random effects, and fixed effects logit and probit models.
At least for fixed effects models, according to Windmeijer (1995) "... it seems to be the
best measure to use" (p. 114). {cmd:r2_mz} works after the following: {cmd:xtmelogit},
{cmd:xtlogit}, {cmd:xtprobit}, {cmd:logit}, {cmd:logistic}, {cmd:probit}.{p_end}

{title:Example}

{phang}{cmd:. webuse towerlondon, clear}{p_end}
{phang}{cmd:. xtmelogit dtlm difficulty i.group || family: || subject:}{p_end}
{phang}{cmd:. r2_mz}{p_end}

{title:Saved Results}

{pstd} {cmd:r2_mz} adds the following in e(): {p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(r2_mz)}}McKelvey & Zavoina's R2{p_end}
{synopt:{cmd:e(deviance)}}Model Deviance{p_end}
{synopt:{cmd:e(Var_u)}}Total Variance of Random Effects{p_end}
{synopt:{cmd:e(Var_u#)}}Variance of Level-# random effects{p_end}

{title:References}

{phang}Windmeijer, F. A. G. (1995). {browse "http://www.tandfonline.com/doi/abs/10.1080/07474939508800306":Goodness-of-fit measures in binary choice models}. {it:Econometric Reviews}, {it:14}, 101-116.{p_end}

{title:Also see}

{psee}
Manual:{space 2}{hi:[R] xtmelogit, xtlogit, xtprobit }{p_end}
{psee}
Online:{space 2}Help for {help xtmelogit}, {help xtlogit}, {help xtprobit}; ssc package {cmd:fitstat} ({net "describe fitstat, from(http://fmwww.bc.edu/RePEc/bocode/f)":click here}){p_end}
{psee}
Web:{space 5}{browse "http://stata.com":Stata's Home}{p_end}

{title:Acknowledgments}

{pstd}Thanks to Ulrich Kohler (WZB Berlin) for providing a template of the Mata program used!{p_end}

{title:Author}

{phang}Dirk Enzmann{p_end}
{phang}Institute of Criminal Sciences, Hamburg{p_end}
{phang}email: {browse "mailto:dirk.enzmann@uni-hamburg.de"}{p_end}
