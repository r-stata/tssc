{smcl}
{* Sally R. Hinchliffe & Paul C. Lambert 18May2015 }{...}
{cmd:help stpm2cif} 
{right:also see:  {helpb stpm2{space 2}}{helpb stpm2_postestimation{space 2}}}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:stpm2cif} {hline 2}}Competing risks post-estimation tool to estimate cumulative incidence function after stpm2{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd: stpm2cif} {it:newvarlist} [{cmd:,} {it:options}]


{synoptset 34}{...}
{synopthdr}
{synoptline}
{synopt:{opt cause1}{it:...}{opt cause10}} covariate patterns for each cause {p_end}
{synopt:{opt obs}} specifies the number of observations (of time) to predict for {p_end}
{synopt:{opt ci}} calculates confidence intervals for cumulative incidence function {p_end}
{synopt:{opt maxt}} the maximum value of follow up time {p_end}
{synopt:{opt time:name}} name of created time variable{p_end}
{synopt:{opt haz:ard}} predict cause-specific hazard function for each cause {p_end}
{synopt:{opt contmort}} predict the relative contribution to total mortality {p_end}
{synopt:{opt conthaz}} predict the relative contribution to hazard {p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}{cmd:stpm2cif} can be used after {helpb stpm2} to obtain cumulative incidence functions for up to 10 causes of death. 


{title:Options}

{phang}
Note: in the table below, {it:vn} is an abbreviation for {it:varname}.

{dlgtab:Main}

{phang}
{opt cause1(vn # [vn # ..])}{it:..}{opt cause10(vn # [vn # ..])} requests that the covariates specified by 
the listed {it:varname(s)} be set to # when predicting the cumulative incidence functions for each cause. 
It is complusory to specify cause1 and cause2. Note that any covariates no specified are set to zero.{p_end}

{phang}
{opt obs(integer)} specifies the number of observations (of time) to predict for (default 1000). Observations are evenly 
spread between 0 and maximum value of follow-up time. Note that a trapezium rule is used for the numerical integration to estimate the CIF. If the number of observations is small then this will not give an accurate result. {p_end}

{phang}
{opt ci} calculates a 95% confidence interval for the cumulative incidence function and
stores the confidence limits in {cmd:CIF_}{it:newvar}{cmd:_lci} and {cmd:CIF_}{it:newvar}{cmd:_uci}. {p_end}

{phang}
{opt maxt(#)} the maximum value of follow up time. The default is set as the maximum event time from {helpb stset}. {p_end}

{phang}
{opt timename(newvarname)} this is the time variable generated during predictions for the cumulative incidence function (default {cmd:_newt}). Note that this is the variable for time that needs to be used when plotting curves for the cumulative incidence function and the cause-specific hazard function. {p_end}

{phang}
{opt hazard} predicts cause-specific hazard function for each cause. {p_end}

{phang}
{opt contmort} predicts the relative contribution to total mortality. {p_end}

{phang}
{opt conthaz} predicts the relative contribution to hazard. {p_end}

{title:Examples}

{phang}

This example is taken from a paper by Putter et al. (2007) where data were analyzed on 324 homosexual men from the 
Amsterdam Cohort Studies on HIV infection and AIDS. For a more detailed description of the web based data see 
Example 4 in the following document http://www.stata.com/features/competing-risks/stcrreg.pdf.

{phang}

Expand the data set so that each patient has a row of data for each of the two competing events - time to SI 
phenotype appearance and diagnosis of AIDS. 

{phang2} {stata "webuse hiv_si"}{p_end}
{phang2} {stata "gen id=_n"} {p_end}
{phang2} {stata "expand 2"} {p_end}

{phang}

Create a cause variable variable for each of the two competing events. Generate an event indicator by setting 
the cause variable equal to the status variable. The status variable indicates whether the patient has experienced
either of the two events. Once this has been generated use it to {helpb stset} the data.

{phang}

{phang2} {stata "bysort id: gen cause= _n"} {p_end}
{phang2} {stata "gen si=cause==1"} {p_end}
{phang2} {stata "gen aids=cause==2"} {p_end}
{phang2} {stata "gen event=(cause==status)"} {p_end}
{phang2} {stata "stset time, failure(event)"} {p_end} 


Run {helpb stpm2} including each of the two competing events in the model.

{phang}

{phang2} {stata "stpm2 si aids, scale(hazard) tvc(si aids) nocons rcsbaseoff dftvc(3)"} {p_end}



Run{cmd: stpm2cif} to obtain the cumulative incidence function for each cause. Note that the names in the newvarlist 
are in capital letters so as not to overwrite the original variables with those names.

{phang}

{phang2} {stata "stpm2cif SI AIDS, cause1(si 1) cause2(aids 1)"} {p_end}


A plot of the two cumulative incidence functions for SI appearance and diagnosis of AIDS can be obtained as follows:

{phang}

{phang2} {stata "twoway (line CIF_SI _newt)(line CIF_AIDS _newt), xtitle(Years from HIV infection) ytitle(Cumulative Incidence Function) ylabel(, angle(0))"}{p_end}

The variables {opt CIF_SI} and {opt CIF_AIDS} are the cumulative incidence functions generated by the{cmd: stpm2cif} command.
Note that the curve is plotted against {opt _newt} which is the new time variable generate by{cmd: stpm2cif} during the predictions.

{phang}

In order to plot a stacked graph of the cumulative incidence functions you need to sum up the two functions.

{phang}

{phang2} {stata "gen tot1=CIF_SI"} {p_end}
{phang2} {stata "gen tot2=CIF_SI+CIF_AIDS"} {p_end}

{phang}

Now the stacked cumulative incidence graph can be plotted as follows:

{phang}

{phang2} {stata "twoway (area tot2 _newt)(area tot1 _newt), xtitle(Years from HIV infection) ytitle(Cumulative Incidence Function) ylabel(, angle(0))"} {p_end}

{phang}

Note that the legend shows {opt tot1} which represents {opt CIF_SI} and {opt tot2} which represents {opt CIF_AIDS}.

{title:Also see}

{psee}
Online:  {manhelp stpm2 ST} {manhelp stpm2_postestimation ST}; 
{p_end}



