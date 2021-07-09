{smcl}
{* 12 May 2020}{...}
{hline}
help for {hi:clustersampsim}
{hline}

{title:Title}

{phang2}{cmdab:clustersampsim} {hline 2} simulates cluster-randomized trial sample size requirements for a given range of numbers of clusters or cluster sizes for up to two sets of assumptions

{title:Syntax}

{phang2}
{cmdab:clustersampsim}, {{cmdab:clusters(}{it:{help numlist}}{cmd:)} | {cmdab:clustersizes(}{it:{help numlist}}{cmd:)}}
{{cmdab:mdes(}{it:effect_size}{cmd:)} {cmdab:rho(}{it:icc}{cmd:)}} {cmdab:base_correl(}{it:corr}{cmd:)} {cmdab:alpha(}{it:sig_level}{cmd:)}
{cmdab:beta(}{it:power}{cmd:)} {cmdab:savesims(}{it:{help filename}}{cmd:)} {cmdab:noplot}{cmd:} {cmdab:mdes2(}{it:effect_size}{cmd:)}
{cmdab:rho2(}{it:icc}{cmd:)} {cmdab:base_correl2(}{it:corr}{cmd:)} {cmdab:alpha2(}{it:sig_level}{cmd:)} {cmdab:beta2(}{it:power}{cmd:)}

{phang2}Where {it:{help numlist}} is a list of desired numbers of clusters or average cluster sizes to simulate.  

{marker opts}{...}
{synoptset 23}{...}
{synopthdr:options}
{synoptline}
{pstd}{it:    {ul:{hi:Required options:}}}{p_end}

{pstd}{it:One of these options must be used:}{p_end}
{synopt :{cmdab:clusters(}{it:{help numlist}}{cmd:)}} Simulate the required number sample per cluster for a list of numbers of clusters (per arm){p_end}
{synopt :{cmdab:clustersizes(}{it:{help numlist}}{cmd:)}}  Simulate the required number of clusters (per arm) for a list of cluster sizes{p_end}

{pstd}{it:All of these options must be specified:}{p_end}
{synopt :{cmdab:mdes(}{it:effect_size}{cmd:)}} Desired minimum detectable effect size for the simulation{p_end}
{synopt :{cmdab:rho(}{it:icc}{cmd:)}} Intra-class correlation in outcome measure{p_end}

{pstd}{it:    {ul:{hi:Optional options}}}{p_end}

{marker columnoptions}{...}
{pstd}{it:    Graphing and output options:}{p_end}
{synopt :{cmdab:noplot}} Suppress graphical output of simulations. If this option is chosen, {cmdab:savesims(}{it:{help filename}}{cmd:)} must be specified. {p_end}
{synopt :{cmdab:savesims(}{it:{help filename}}{cmd:)}} Save results of the simulation to a Stata .dta file.{p_end}

{marker labeloptions}{...}
{pstd}{it:    Additional parameter specifications:}{p_end}
{synopt :{cmdab:base_correl(}{it:corr}{cmd:)}} Baseline-endline correlation. Default is 0. {p_end}
{synopt :{cmdab:alpha(}{it:sig_level}{cmd:)}} Significance level. Default is .05. {p_end}
{synopt :{cmdab:beta(}{it:power}{cmd:)}} Level of statistical power. Default is .8. {p_end}

{marker statsoptions}{...}
{pstd}{it:    Optional second set of assumptions:}{p_end}
{synopt :{cmdab:mdes2(}{it:effect_size}{cmd:)}} Desired minimum detectable effect size for second set of simulations.{p_end}
{synopt :{cmdab:rho2(}{it:icc}{cmd:)}} Intra-class correlation in outcome measure for second set of simulations.{p_end}
{synopt :{cmdab:base_correl2(}{it:corr}{cmd:)}} Baseline-endline correlation for second set of simulations.{p_end}
{synopt :{cmdab:alpha2(}{it:sig_level}{cmd:)}} Significance level for second set of simulations.{p_end}
{synopt :{cmdab:beta2(}{it:power}{cmd:)}} Level of statistical power for second set of simulations.{p_end}

{synoptline}

{title:Description}

{pstd}{cmdab:clustersampsim} is an extension of the {help clustersampsi} command that allows the user to specify either 1) a range of numbers of clusters per study arm to find the required sample sizes per cluster 2) a range of cluster sizes to find the numbers of required clusters per study arm. In addition to providing either {cmdab:clusters(}{it:{help numlist}}{cmd:)} or {cmdab:clustersizes(}{it:{help numlist}}{cmd:)}, the user must specify, at a minimum, {cmdab:mdes(}{it:effect_size}{cmd:)}, the minimum detectable effect size for the simulation and {cmdab:rho(}{it:icc}{cmd:)}, the intra-class correlation. In addition, the user may specify the amount of variance at endline explained by baseline with {cmdab:base_correl(}{it:corr}{cmd:)}, the significance level with {cmdab:alpha(}{it:sig_level}{cmd:)}, and the statistical power desired with {cmdab:beta(}{it:power}{cmd:)}.  

{pstd} By default, the command will produce a plot of the simulations. In addition, the resulting simulations can be saved to a Stata .dta by specifying the {cmdab:savesims(}{it:{help filename}}{cmd:)} option. The {cmdab:noplot} option supppresses the graphical output. If {cmdab:noplot} is applied, {cmdab:savesims(}{it:{help filename}}{cmd:)} must also be applied. 

{pstd} Up to two sets of assumptions are supported by the program. If any of the options {cmdab:mdes2(}{it:effect_size}{cmd:)}, {cmdab:rho2(}{it:icc}{cmd:)}, {cmdab:base_correl2(}{it:corr}{cmd:)}, {cmdab:alpha2(}{it:sig_level}{cmd:)}, or {cmdab:beta2(}{it:power}{cmd:)} are specified, the program will automatically produce two sets of simulations. Only one "2" option is required to produce the second set of simulations. Unless otherwise specified, the second set of simulations will take on the specified values for the first set of assumptions.  

{title:Examples}

{pstd} {hi:Example 1.}

{pmore}{inp:clustersampsim, clusters(30/60) mdes(.3) rho(.1)} 

{pmore}In Example 1, we want to have a cluster-RCT to detect and effect size of .3 given an ICC of .1. We want to consider how large each sample per cluster should be for the range of 30-60 clusters. In the resulting graph, we can see that with 30 clusters per arm, we will have to sample 14 units per cluster. Conversely, with 60 clusters, we can get away with only 4 sampled units per cluster.   


{pstd} {hi:Example 2.}

{pmore}{inp:clustersampsim, clustersizes(5/15) mdes(.3) rho(.1)} 

{pmore} Example 2 is the counterpoint to Example 1. Here, we want to see how many clusters per arm we require if we sample 5-15 units per cluster. The resulting graph shows us that we require 50 clusters per arm if we sample 5 units per cluster, and fewer than 30 clusters per arm if we sample 15.  

{pstd} {hi:Example 3.}

{pmore}{inp:clustersampsim, clusters(5/15) mdes(.3) rho(.1)}

{pmore} Example 3 will generate an error because there are no solutions to detect an effect size of .3 and an ICC of .1 with 15 or fewer clusters. To fix this error, we must either increase our allowable numbers per cluster, increase the MDES, or decrease the ICC.  

{pstd} {hi:Example 4.}

{pmore}{inp:clustersampsim, clusters(30/60) mdes(.3) rho(.1) mdes2(.25)}

{pmore} Example 4 introduces a double simulation. Here we simulate both for an MDES of .3 and .25. Note that only parameters appended with "2" are different in the second simulation. All other parameters will be inherited from the primary simulatino. In the resulting graph, we can see that the small-cluster solutions have huge differences between the required sample per cluster, but as the cluster number growth, difference become much smaller.   

{pstd} {hi:Example 5.}

{pmore}{inp:clustersampsim, clusters(30/60) mdes(.3) rho(.1) alpha(.1) beta(.9) mdes2(.25) rho2(.08)}

{pmore} Example 5 builds on Example 4, but also specifies that the ICC for the second simulation is smaller.

{pstd} {hi:Example 6.}

{pmore}{inp:clustersampsim, clusters(30/60) mdes(.3) rho(.1) alpha(.1) beta(.9) mdes2(.25) rho2(.08) savesims(simulation_results) noplot}

{pmore} Example 6 builds on Example 5, but suppresses the graphical output, and saves the results of the simulations to simulation_results.dta.


{title:Acknowledgements}

{phang}This command is based entirely on {help clustersampsi} developed by Karla Hemming and Jen Marsh. Thank you to the following for testing and feedback (in alphabetic order):{p_end}
{pmore}Kabira Namit

{title:Author}

{pstd}Jonathan Seiden{break}Harvard Graduate School of Education{break}jseiden@g.harvard.edu

{phang}I appreciate comments, feedback, and bug reports made by email or through my {browse "https://github.com/jmseiden/clustersampsim":GitHub repository}.{p_end}
