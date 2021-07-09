{smcl}
{* 14Apr2018}{...}
{hline}
help for {hi:itspower}
{hline}
                                                                                                                                    
{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:itspower} {hline 2}} Simulation based power calculations for linear interrupted time series (ITS) designs {p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 8 2}
{cmd:itspower}
{cmd:,} sn({it:#}) nuts({it:#}) prepoints({it:#}) lvlmn({it:#}) corr({it:string}) sd({it:string}) [{it:{help itspower##optional:optional}}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :required}
{synopt :{opt sn(#)}}Number of simulations to execute
{p_end}
{synopt :{opt nuts(#)}}Number of units (e.g. patients or general practices)
{p_end}
{synopt :{opt prepoints(#)}}Number of pre-interention time-points
{p_end}
{synopt :{opt lvlmn(#)}}Mean level change assumption for the 1st time point post-intervention
{p_end}
{synopt :{opt corr(string)}}Correlation matrix
{p_end}
{synopt :{opt sd(string)}}Standard deviation matrix
{p_end}
{synoptline}
{syntab :optional}
{synopt :{opt lvlsd(#)}}Standard deviation for the level change
{p_end}
{synopt :{opt clvl(#)}}Set alpha level
{p_end}
{synopt :{opt seed(#)}}Set seed number
{p_end}
{synopt :{opt moreon}}Set more on (default is off)
{p_end}

{title:Description}

{p 4 4 2}
{cmd:itspower} is a simulations-based command that calculates power for linear interrupted time series (ITS) designs.
The command proceeds in two steps. First, it generates the outcome data according to the specified inputs and then uses
linear regression modelling (defining panel data with {cmd:xtset} and analysing the time-series using {cmd:xtreg}) to
estimate the power for the model to detect the specified level change. Level change is defined as the increase above
(or decrease below) the expected overall mean, for the time-point following the intervention.
Power indicates the percentage of iterations in which the level change was found to be statistically significant and of
the same direction as the hypothesised. The 95% confidence interval (as default), or any other confidence interval as 
specified by option {opt clvl(#)}, for the power is also reported.

{p 4 4 2}
Note that the level of the outcome or the pre-intervention trend are irrelevant, at least for power calculations for the
level change in the first post-intervention time point. In the future the command may be expanded to include power calculation
for the slope change post-intervention, if requested by users (for which the pre-intervention trend will be relevant).

{p 4 4 2}
Also note that the simulations assume no autocorrelation/seasonality. In other words, if you plan to analyse using an ARIMA
model and expect or can measure seasonality, do not use this command since it is assuming linearity.

{title:Required}

{phang}
{opt sn(#)} Number ({it:integer}) of simulations to execute. At least 1000 are recommended for relatively narrow confidence intervals.

{phang}
{opt nuts(#)} Number ({it:integer}) of units. For example, general practices in England.

{phang}
{opt prepoints(#)} Number ({it:integer}) of pre-intervention time-points. The minimum allowed is two.

{phang}
{opt lvlmn(#)} Mean level change ({it:real}) for the first post-intervention time-point. The effect/association of interest
in this command.

{phang}
{opt corr(string)} Matrix for the correlation structure of the modelled time points, including the post-interention
time-point. If {it:N} pre-intervention time-points are specified, a two-dimensional {it:N+1} by {it:N+1} correlation
matrix is expected (with all diagonal cells being {it:N} and all other cells in the {it:[0,1)} range). 

{phang}
{opt sd(string)} Matrix for the standard deviation of the outcome in each time-point, including the post-intervention
time point. If {it:N} pre-intervention time-points are specified, a single dimension matrix with {it:N+1} positive cells
is expected. 

{marker optional}{...}
{title:Optional}

{phang}
{opt lvlsd(#)} Standard deviation ({it:real>0}) for the level change in the post-intervention time point.
The default is 0, which implies a fixed level change across all units (as defined by {opt lvlmn(#)}).

{phang}
{opt clvl(#)} Set confidence level. The default is 95% (alpha level of 5%). See {help level}.

{phang}
{opt seed(#)} Set initial value of random-number seed, for the simulations. See {help set seed}.

{phang}
{opt moreon} Set {help more} on (default is off).


{title:Example}

{p 4 4 2}
1000 simulations, 50 general practice, 3 pre-intervention time-points, to detect a mean increase of 1 in agreggate quaility
scores post-intervention (with no variance across units).
First, the two matrices need to be defined. The correlation matrix is defined to model a modest correlation for
the practice scores at neighbouring time-points, which becomes weaker over time:

{phang2}{cmd:. matrix Cmat = (1, 0.5, 0.4, 0.3 \ 0.5, 1, 0.5, 0.4 \ 0.4, 0.5, 1, 0.5 \ 0.3, 0.4, 0.5, 1)}{p_end}
 
The standard deviation matrix is defined to model high variation, in relation to the level change we wish to measure:
 
{phang2}{cmd:. matrix Smat = (3, 3, 3, 3)}{p_end} 
 
{phang2}{cmd:. itspower, sn(1000) nuts(50) lvlmn(1) prepoints(3) sd(Smat) corr(Cmat) lvlsd(0) seed(7)}{p_end}


{title:Saved results}

{pstd}
{cmd:itspower} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(pow)}}Power to detect specified effect{p_end}
{synopt:{cmd:r(lpow)}}Lower confidence interval for power estimate (default 95%){p_end}
{synopt:{cmd:r(upow)}}Upper confidence interval for power estimate (default 95%){p_end}


{title:Author}

{p 4 4 2}
Evangelos Kontopantelis, Faculty of Biology, Medicine and Health

{p 29 4 2}
University of Manchester, e.kontopantelis@manchester.ac.uk


{title:Please cite as}

{phang}
Kontopantelis E. 2018.
{it:itspower: Simulation based power calculations for linear interrupted time series (ITS) designs}.


{title:Other references}

{p 4 4 2}
Kontopantelis E et al. Regression based quasi-experimental approach when randomisation is not an option:
interrupted time series analysis. The British Medical journal, 2015 June; 350 doi: {browse "https://doi.org/10.1136/bmj.h2750":https://doi.org/10.1136/bmj.h2750}.

{title:Also see}

{p 4 4 2}
help for {help ipdpower}

