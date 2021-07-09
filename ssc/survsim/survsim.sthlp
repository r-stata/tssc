{smcl}
{* *! version 1.0.0}{...}
{vieweralsosee "survsim parametric" "help survsim parametric"}{...}
{vieweralsosee "survsim user" "help survsim user"}{...}
{vieweralsosee "survsim model" "help survsim model"}{...}
{vieweralsosee "survsim msm" "help survsim msm"}{...}
{vieweralsosee "merlin" "help merlin"}{...}
{vieweralsosee "galahad" "help galahad"}{...}
{title:Title}

{p2colset 5 16 16 2}{...}
{p2col :{cmd:survsim} {hline 2}}Simulate survival data from a parametric distribution, 
a user-defined distribution, from a fitted {helpb merlin} model, from a cause-specific 
hazards competing risks model, or from a general multi-state model{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:survsim} simulates survival data from:
{p_end}

{phang2}
{helpb survsim parametric:help survsim parametric} - a parametric distribution including the exponential, Gompertz and Weibull, 
and 2-component mixtures of them. Baseline covariates can be included, with specified associated log hazard ratios. 
Non-proportional hazards can also be included with all models; under an exponential or Weibull model covariates are interacted 
with log time, under a Gompertz model covariates are interacted with time. See {helpb survsim##paper1:Crowther and Lambert (2012)} 
for more details.
{p_end}

{phang2}
{helpb survsim user:help survsim user} - a user-defined distribution. Survival times can be simulated from bespoke, 
user-defined [log] [cumulative] hazard functions. The function must be specified in Mata code (using colon operators), 
with survival times generated using a combination of numerical integration and root finding techniques. Time-dependent 
effects can also be specified with a user-defined function of time. See {helpb survsim##paper2:Crowther and Lambert (2013)} 
for more details.
{p_end}

{phang2}
{helpb survsim model:help survsim model} - a fitted {helpb merlin} model. {helpb merlin} fits a broad class of survival models, 
including standard parametric models, spline-based survival models, and user-defined survival models. 
{p_end}

{phang2}
{helpb survsim msm:help survsim msm} - a competing risks or general multi-state model. Event times can be simulated from 
transition-specific hazards, where each transition hazard function can be a standard parametric distribution, or a 
user-defined complex hazard function. Covariates and time-dependent effects can be specified for each transition-specific 
hazard independently.
{p_end}


{title:Author}

{pstd}{cmd:Michael J. Crowther}{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{phang}Please report any errors you may find.{p_end}


{title:References}

{phang}Bender R, Augustin T and Blettner M. Generating survival times to simulate Cox proportional hazards models. {it:Statistics in Medicine} 2005;24:1713-1723.{p_end}

{phang}Beyersmann J, Latouche A, Buchholz A and Schumacher M. Simulating competing risks data in survival analysis. {it:Statistics in Medicine} 2009;28:956-971.{p_end}

{marker paper1}{...}
{phang}Crowther MJ and Lambert PC. {browse "http://www.stata-journal.com/article.html?article=st0275":Simulating complex survival data.}{it: The Stata Journal} 2012;12(4):674-687.{p_end}

{marker paper2}{...}
{phang}Crowther MJ and Lambert PC. {browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.5823/abstract":Simulating biologically plausible complex survival data.} {it:Statistics in Medicine} 2013;32(23):4118-4134.{p_end}

{phang}Jann, B. 2005. moremata: Stata module (Mata) to provide various functions. Available from http://ideas.repec.org/c/boc/bocode/s455001.html.{p_end}

