{smcl}
{* 	*! version 1.0.3 25Nov2016}{...}
{cmd:help stcrprep} 
{right:also see:  {help stcrreg}, {help stcox}}
{hline}

{title:Title}

{p2colset 5 18 16 2}{...}
{p2col :{hi:stcrprep} {hline 2}}Prepare data for competing risks analysis using time-dependent weights{p_end}
{p2colreset}{...}


{title:Syntax}
{p 8 16 2}{cmd:stcrprep} {ifin}, {opt events(varname)} [{it:options}]

{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options}
{synopt :{opt byg:(varlist)}}calculate censoring weights separately by {varlist}{p_end}
{synopt :{opt byh:(varlist)}}calculate delayed entry weights separately by {varlist}{p_end}
{synopt :{opt censv:alue(#)}}value for censoring for events variable{p_end}
{synopt :{opt eps:ilon(#)}}value to add to ensure censoring occurs after event{p_end}
{synopt :{opt ev:ents(varname)}}name of variable defining different events{p_end}
{synopt :{opt keep:(varlist)}}name of variables to keep in dataset{p_end}
{synopt :{opt nosh:orten}}do not collapse over same weights within individuals{p_end}
{synopt :{opt tr:ans(numlist)}}Values of events variables that define the transitions of interest{p_end}

The following options are use when a parametric model is used for the censoring distribution.
{synopt :{opt wtstpm2:}}estimate censoring distribution using {help stpm2}{p_end}
{synopt :{opt censcov(varlist)}}variables to include in censoring model{p_end}
{synopt :{opt censdf(#)}}degrees of freedom for the baseline censoring distribution{p_end}
{synopt :{opt censtvc(varlist)}}variables with time-dependent effects for censoring distribution{p_end}
{synopt :{opt censtvcdf(#)}}degrees of freedom for time-dependent effects for censoring distribution{p_end}

{p2colreset}{...}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:stcrprep} prepares data for estimating and modelling cause-specific cumulative incidence functions using
time-dependent weights. Once the data has been prepared and the weights incorporated using {cmd:stset} it is possible to obtain a graph of the non-parametric estimates of the cause-specific cumulative incidence function using {cmd:sts graph}. 
In addition a model that estimates subhazard ratios (equivalent to the Fine and Gray model) can be fitted using {cmd:stcox}. It is also possible to fit parametric models to directly estimate the cause-specific CIF.

{pstd}
The data must be {cmd:stset} before using {cmd:stcrprep}. As the data is expanded the {cmd:id()} option of {cmd:stset} must be used. There should only be 1 row of data per subject before using {cmd:stcrprep}.

{pstd}
Note the {cmd:stcrprep} currently allows for delayed entry when using the Kaplan-Meier method to derive weights, but not currently when using fitting a parametric model for using the {cmd:wtstpm2} option. 
However, the delayed entry implementation is experimental and has not been fully tested, so please use with caution. 

{pstd}
The command is based on the R function, {cmd:crprep} written by Ronald Geskus, which is part of the {cmd:mstate} package available from Cran ({browse "http://cran.r-project.org"}).

{title:Options}

{phang}
{opt byg(varlist)} calculate censoring weights separately by {varlist}.

{phang}
{opt byh(varlist)} calculate left truncation weights separately by {varlist}.

{phang}
{opt censvalue(#)} value that denotes a censored observation in the variable used to define the different events. 
The default value is 0

{phang}
{opt epsilon(#)} values added to survival time when calculating probability of censoring to ensure that events occur before censoring.

{phang}
{opt event(varname)} name of the variable defining the different events. This is a compulsory option 

{phang}
{opt keep(varlist)} names of variables to keep in expanded dataset. This is generally a list of the variables that you want to include in the analysis.

{phang}
{opt noshorten} do not collapse over rows with equal weights. 

{phang}
{opt trans(numlist)} Values of events variable that are the event types of interest. {cmd:stcrprep} will create the 
weights for any of the events listed in this option. By default all events are included with these
denoted by the {cmd: failcode} variable in the new data set. 


The following options fits a parametric model using {help stpm2} for the censoring distribution.

{phang}
{opt wtstpm2} requests that the censoring distribution is estimated by fitting a flexible 
parametric survival model using {help stpm2}.

{phang}
{opt censcov(varlist)} covariates to include in the model for the censoring distribution.

{phang}
{opt censdf(#)} gives the degrees of freedom used for the baseline when using {help stpm2} to obtain the 
censoring distribution. The default is 5 df.

{phang}
{opt censtvc(varlist)} gives any variables to be included as time-dependent effects when using {help stpm2} to estimate the censoring distribution.

{phang}
{opt censtvcdf(#)} gives the degrees of freedom used for any time-dependent effects when using {help stpm2} to obtain the 
censoring distribution. The default is 3 df.


{title:Remarks}

{pstd}
Using {cmd: stcrprep} to Fit Fine and Gray models with large data sets can be substantially faster than using {cmd: stcrreg}. this is because the time-dependent weights needed in the estimation process only have to be calculated once rather than 
each time a model is fitted. 

{title:Example 1: Use sts graph to plot cumulative incidence functions.}

{pstd}Load and stset the data{p_end}
{tab}{cmd:. use "http://www.stata-journal.com/software/sj4-2/st0059/prostatecancer"}
{tab}{cmd:. stset time, failure(status=1,2,3) id(id) scale(12)}

{pstd} Use stcrprep to expand data and calculate weights{p_end}
{tab}{cmd:. stcrprep, events(status) byg(treatment) keep(treatment)}
{tab}{cmd:. gen event = failcode == status}

{pstd}Incorporate weights when using stset{p_end}
{tab}{cmd:. stset tstop [iw=weight_c], failure(event==1) enter(tstart)}

{pstd}Plot cumulative incidence functions{p_end}
{tab}{cmd:. forvalues i  = 1/3  {c -(}}
{tab}{tab}{cmd:local event: label (failcode) `i'}
{tab}{tab}{cmd:sts graph if failcode==`i', by(treatment) failure ///}
{tab}{tab}{cmd: 		title("`event'") name(`event',replace)}
{tab}{cmd: {c )-}}	

{title:Example 2: Use stcox to fit a Fine and Gray model}

{pstd}Load and stset the data{p_end}
{tab}{cmd:. use "http://www.stata-journal.com/software/sj4-2/st0059/prostatecancer"}
{tab}{cmd:. stset time, failure(status=1,2,3) id(id) scale(12)}

{pstd}Expand data. Here we only keep the data relevant for modelling the CIF for cancer.{p_end}
{tab}{cmd:. stcrprep, events(status) keep(treatment age) trans(1)}
{tab}{cmd:. gen event = failcode == status}

{pstd}Incorporate weights when using stset{p_end}
{tab}{cmd:. stset tstop [pw=weight_c], failure(event==1) enter(tstart)}

{pstd}Using stcox will now fit a Fine and Gray model{p_end}
{tab}{cmd:. stcox treatment age}

{pstd}Assessing proportional subhazards assumption{p_end}
{tab}{cmd:. estat phtest, plot(treatment) yline(0 `=_b[treatment]')}
{tab}{cmd:. estat phtest, detail}


{title:Example 3: Fit a parametric model for the CIF}

{pstd}Load and stset the data{p_end}
{tab}{cmd:. use "http://www.stata-journal.com/software/sj4-2/st0059/prostatecancer"}
{tab}{cmd:. stset time, failure(status=1,2,3) id(id) scale(12)}

{pstd}Expand data. Use a parametric model for the censoring distribution.
Allow censoring distribution to depend on treatment/age.
Split every 0.25 years after competing events{p_end}
{tab}{cmd:. stcrprep, events(status) keep(treatment age) wtstpm2 censcov(treatment age) every(0.25)}
{tab}{cmd:. gen event = failcode == status}

{pstd}Incorporate weights when using stset{p_end}
{tab}{cmd:. stset tstop [iw=weight_c], failure(event==1) enter(tstart)} 

{pstd}Fit parametric model for the CIF using stpm2{p_end}
{tab}{cmd:. stpm2 treatment if failcode == 1, scale(hazard) df(4)}

{pstd}Plot CIFs{p_end}
{tab}{cmd:. predict CIF if failcode ==1, failure}
{tab}{cmd:. twoway (line CIF _t if treatment == 0, sort) (line CIF _t if treatment == 1, sort)}

{title:Author}

{pstd}
Paul Lambert, University of Leicester, UK.
({browse "mailto:paul.lambert@leicester.ac.uk":paul.lambert@leicester.ac.uk})

{pstd}
The command is based on the R function, {cmd:crprep} written by Ronald Geskus, which is part of the {cmd:mstate} package 
available from({browse "http://cran.r-project.org"}).

{title:References}

{phang}
R. B. Geskus. Cause-specific cumulative incidence estimation and the Fine and Gray model under both left truncation and right censoring. Biometrics 2011:67:39-49.

{phang}
L. de Wreede, M. Fiocco, H. Putter. {cmd:mstate}: An R package for the analysis of competing risks and multi-state models Journal of Statistical Software, 2011, 38

{title:Also see}

{psee}
Online:  {manhelp stcrreg ST: stcox ST: sts graph};
{manhelp stset ST}
{p_end}
