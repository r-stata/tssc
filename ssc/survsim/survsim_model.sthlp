{smcl}
{* *! version 1.0.0}{...}
{vieweralsosee "survsim" "help survsim"}{...}
{vieweralsosee "survsim parametric" "help survsim parametric"}{...}
{vieweralsosee "survsim user" "help survsim user"}{...}
{vieweralsosee "survsim msm" "help survsim msm"}{...}
{vieweralsosee "merlin" "help merlin"}{...}
{vieweralsosee "galahad" "help galahad"}{...}
{viewerjumpto "Syntax" "survsim model##syntax"}{...}
{viewerjumpto "Description" "survsim model##description"}{...}
{viewerjumpto "Options" "survsim model##options"}{...}
{viewerjumpto "Examples" "survsim model##examples"}{...}
{title:Title}

{p2colset 5 16 16 2}{...}
{p2col :{cmd:survsim} {hline 2}}Simulate survival data from a parametric distribution, 
a user-defined distribution, from a fitted {helpb merlin} model, from a cause-specific 
hazards competing risks model, or from a general multi-state model{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}
Syntax for simulating survival times from a fitted {helpb merlin} survival model:

{phang2}
{cmd: survsim} {it:newvarname1} {it:newvarname2} {cmd:,} {opt mod:el(name)} {opt maxt:ime(#|varname)}


{synoptset 36 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt mod:el(name)}}the {helpb estimates store} {it:name} of the fitted {helpb merlin} model; see details{p_end}
{synopt:{opt maxt:ime(#|varname)}}right censoring time(s); either a common number or a {varname}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{helpb survsim} simulates survival data from a parametric distribution, a user-defined distribution, from a fitted 
{helpb merlin} model, from a cause-specific hazards competing risks model, or from a Markov multi-state model. 
This help file centres on simulating from a fitted {helpb merlin} model.
{p_end} 
{pstd}
Survival times can be simulated from the estimated model, using the variables in your current dataset. The variables can simply 
be altered, to provide a flexible framework to simulate using the estimated parameter vector.
{p_end}

{pstd}
{it:newvarname1} specifies the new variable name to contain the generated survival times. {it:newvarname2} specifies the 
new variable name to contain the generated event indicator. 
{p_end}


{marker options}{...}
{title:Options}

{phang}{opt model(name)} specifies the name of the {helpb estimates store} object containing the estimates of the model 
fitted. The survival must be estimated using the {helpb merlin} command. For example,{p_end}

{phang2}{cmd:. merlin (_t trt , family(weibull, failure(_d)))}{p_end}
{phang2}{cmd:. estimates store m1}{p_end}
{phang2}{cmd:. survsim stime died, model(m1) maxtime(10)}{p_end}

{phang2}{cmd:survsim} will simulate from the fitted model, using covariate values that are in your current dataset.{p_end}

{phang}{opt maxtime(#|varname)} specifies the right censoring time(s). Either a common maximum follow-up time {cmd:#} can be 
specified for all observations, or observation specific censoring times can be specified by using a {varname}. {p_end}


{title:Remarks}

{pstd}Always {helpb set seed}, to ensure reproducibility.{p_end}


{marker examples}{...}
{title:Examples}

{phang}Simulate from a fitted Weibull survival model:{p_end}
{phang2}{cmd:. webuse brcancer}{p_end}
{phang2}{cmd:. stset rectime, failure(censrec) scale(365)}{p_end}
{phang2}{cmd:. merlin (_t hormon , family(weibull, failure(_d)))}{p_end}
{phang2}{cmd:. estimates store m1}{p_end}
{phang2}{cmd:. survsim stime died, model(m1) maxtime(10)}{p_end}

{phang}Simulate from a fitted Royston-Parmar spline-based survival model:{p_end}
{phang2}{cmd:. webuse brcancer}{p_end}
{phang2}{cmd:. stset rectime, failure(censrec) scale(365)}{p_end}
{phang2}{cmd:. merlin (_t hormon , family(rp, failure(_d) df(3)))}{p_end}
{phang2}{cmd:. estimates store m2}{p_end}
{phang2}{cmd:. survsim stime died, model(m2) maxtime(10)}{p_end}


{title:Author}

{pstd}{cmd:Michael J. Crowther}{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{phang}Please report any errors you may find.{p_end}


{title:References}

{phang}Bender R, Augustin T and Blettner M. Generating survival times to simulate Cox proportional hazards models. {it:Statistics in Medicine} 2005;24:1713-1723.{p_end}

{marker paper1}{...}
{phang}Crowther MJ and Lambert PC. {browse "http://www.stata-journal.com/article.html?article=st0275":Simulating complex survival data.}{it: The Stata Journal} 2012;12(4):674-687.{p_end}

{marker paper2}{...}
{phang}Crowther MJ and Lambert PC. {browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.5823/abstract":Simulating biologically plausible complex survival data.} {it:Statistics in Medicine} 2013;32(23):4118-4134.{p_end}

{phang}Jann, B. 2005. moremata: Stata module (Mata) to provide various functions. Available from http://ideas.repec.org/c/boc/bocode/s455001.html.{p_end}

