{smcl}
{* 20aug2009}{...}
help for {cmd:stcompadj}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:stcompadj} {hline 2}}Adjusted Cumulative Incidence in the presence of competing risks{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:stcompadj} {it:var} [{opt =} {it:#} {it:var ...}] {ifin} {cmd:,} 
	{cmd:compet(}{it:#} [{it:...}] {cmd:)} [
	{cmdab:mainef:fect(}{it:varlist}{cmd:)} 
	{cmdab:competef:fect(}{it:varlist}{cmd:)} 
	{cmdab:fle:xible}
	{cmd:df(}{it:#}{cmd:)}
	{cmdab:gen:erate(}{it:newvar newvar}{cmd:)}
	{cmdab:savexp:anded(}{it:filename [,replace]}{cmd:)}
	{cmd:bootci}
	{cmdab:rep:s(}{it:#}{cmd:)} 
	{cmd:ci}
	{cmd:showmod}
	{cmdab:l:evel(}{it:#}{cmd:)} ]


{synoptset 29 tabbed}
{synopthdr}
{synoptline}
{syntab:Options}
{synopt :{opt compet(# [#])}}A failure of a competing event occurs whenever failvar specified in the previous stset takes on any of
the values of this numlist. It is not an option.{p_end}
{synopt :{opt mainef:fect(varlist)}}covariates acting only on the main event.{p_end}
{synopt :{opt competef:fect(varlist)}}covariates acting only on the competing event.{p_end}
{synopt :{opt fle:xible}}cause a flexible parametric, instead of a Cox, model is fitted to the data.{p_end}
{synopt :{opt df(#)}}degrees of freedom for the underlying flexible parametric model.{p_end}
{synopt :{opt gen:erate(newvar1 newvar2)}}specify the names of covariates containing the cumulative incidence of the main and competing event{p_end}
{synopt :{opt savexp:anded(filename)}}save the data file in the expanded format suitable for further analysis.{p_end}
{synopt :{opt bootci}}compute bootstrap confidence intervals of the cumulative incidence functions. {p_end}
{synopt :{opt rep:s(#)}}specify {it:#} bootstrap replications; default is {opt rep:s(1000)}.{p_end}
{synopt :{opt ci}}compute confidence intervals of the cumulative incidence functions after a flexible parametric model.{p_end}
{synopt :{opt showmod}}shows the fitted model (Cox or flexible parametric){p_end}
{synopt :{opt l:evel}}set confidence level. Default is 95{p_end}


{p 4 4 2}You must {cmd:stset} your data before using {cmd:stcompadj}. In previous stset you must specify
failure(varname==numlist) where numlist refers to the event of interest; see {helpb stset}{p_end}


{p 4 4 2}The {cmd:moremata} user package must be installed on the system (Jann 2005). 
See {net "describe moremata, from(http://fmwww.bc.edu/repec/bocode/m/)":ssc describe moremata}.



{title:Options}

{phang}
{opt compet(# [#])} is not an option. A failure of a competing event occurs whenever  {it:failvar} specified in the previous {cmd:stset } takes on 
any of the values of this {it:numlist}. 

{phang}
{opt maineffect(varlist)} {it:varlist} is the list of the variables acting only on the main event.

{phang}
{opt competeffect(varlist)} {it:varlist} is the list of the variables acting only on the competing event. Note that the same variable can be specified both in {opt mainef:fect(varlist)}
and {opt competef:fect(varlist)}. Then, this variable is assumed to have different effects on the main and competing event. Variables not specified either in {opt mainef:fect(varlist)}
or in {opt competef:fect(varlist)} are assumed to have the same effect on the main and the competing event.

{phang}
{opt flexible} switches {cmd:stcompadj} to fit a flexible parametric model to the expanded data. 
This allows to easily obtain the confidence intervals of the covariate-adjusted CI.

{phang}
{opt df(#)} specifies the degrees of freedom for the restriced cubic spline function used for the flexible parametric model.
This option has effect only when {opt flexible} is also specified. Allowed values are 1-10.  The default is 4.

{phang}
{opt generate(newvarname1 newvarname2)} gives two alternative names to the variables containing the covariate-adjusted CI 
function for the main and competing event. Default names are CI_Main and CI_Compet.

{phang}
{opt savexpanded(filename [,replace])} states the name of the file where the expanded data are to be saved. See examples below for the use of this file.

{phang}
{opt bootci} computes CI confidence intervals by resampling observations  from the expanded dataset. 
This method is only available when the Cox model is used for fitting the effect of the covariates. 

{phang}
{opt reps(#)} sets the number of bootstrap replications to be performed.  The default is 1000.

{phang}
{opt ci} estimates CI confidence intervals when a parametric flexible model is used for fitting the effect of the covariates. 
When data are sparse a small number of df is recommended for estimating confidence intervals.

{phang}
{opt showmod} shows the model, Cox or flexible parametric, fitted to the expanded data. This can be usefull for checking
that the model fitted is as you expect. 

{phang}
{opt level(#)} sets the confidence level; default is level(95) or as set by {help set level}



{title:Remarks}

{p}{cmd:stcompadj} estimates the adjusted cumulative incidence function based on a Cox or a flexible parametric regression model in the presence of competing risks.{p_end}

{p}Cox regression in the presence of competing risks is usually performed by fitting separate models for each failure type.
It is possible to obtain the same results by using a single analysis after appropriately adapting the data set. In short this consists
of expanding each observation for each cause of failure, creating a stratum indicator taking on a value of 1 for the first {it:n} records, 2 for 
the following {it:n} records and so on, and modifying the failure indicator so that it attains the value 1 for each
observation of death caused by the main event in the first stratum, for each observation of death caused by the competing event 
in the second stratum and so on. This way of representing data (expanded format) allows to model both identical and different effects of the same covariate on the main
and competing events. Note that at present {cmd:stcompadj} handles the presence of one event competing with the main.
For more details see reference.{p_end}

{p}After adapting the data set {cmd:stcompadj} fits a Cox model whose covariates are the variables specified in {it:var} [[{opt =}
{it:#}] {it: var ...}]. Then, from the baseline cumulative hazard and the linear predictor it computes and saves in two variables
the cumulative incidence (CI) function for the main and competing event adjusted to the mean or to the specified number of each covariate if the = # part is specified.{p_end}

{p}As an alternative to the Cox model, a flexible parametric model can be fitted to the expanded data set by specifying {opt fle:xible}. This allows one to easily estimate the 
confidence intervals of the CI function. The {cmd:stpm2} (Lambert 2009) and {cmd:rcsgen} (Nelson, Lambert, Rutherford 2008) 
user packages must be installed on the system. See{net "describe stpm2, from(http://www2.le.ac.uk/Members/pl4/stpm2)": net describe stpm2} 
and {net "describe rcsgen, from(http://fmwww.bc.edu/repec/bocode/r/)":ssc describe rcsgen}.{p_end}

{p}By default the fitted model considers the covariates as having the same effect on the main as on the competing event. 
The options {opt mainef:fect(varlist)} and {opt competef:fect(varlist)} allow to fit a model where some of the previously stated variables 
have effect only on the main or on the competing event. If the same variable is specified both in {opt mainef:fect(varlist)}
and {opt competef:fect(varlist)} then it is assumed that it has different effects on the main and competing event.{p_end}

{p}By default the CI function for the main and competing event is saved in two variables named CI_Main and CI_Compet. Other names
can be specified by using {opt gen:erate(newvar1 newvar2)}. If {opt bootci} or {opt ci} is also specified then higher and lower confidence bounds of
the CI are saved in four new variables whose names are prefixed by Hi_ and Lo_.{p_end}

{p}Data in the expanded format can be saved by using {opt savexp:anded(filename)}. This format allows to test the equality of the effects
of a covariate on the main and on the competing event and the difference between the hazards of the main and competing
event under the assumption of the cause-specific hazards being proportional (see example below).{p_end}



{title:Examples}

{p}The cumulative incidence is estimated in a model where sex has the same effect on the main as on the competing event, and thick
has effect only on the main event. The function is evaluated for males (sex=1) and thickness of the tumor 2 mm above the mean (thick=2):{p_end}

{phang}
{cmd: use "C:\Data\malignantmelanoma", clear}{p_end}
{phang}
{cmd: stset time,failure(cause==1)}{p_end}

{phang}
{cmd: stcompadj sex=1 thick=2, compet(2) maineffect(thick) showmod nolog nohr}{p_end}
{phang}
{cmd: sort _t}{p_end}
{phang}
{cmd: l _t  CI_Main CI_Compet in 1/12}{p_end}


{p}Adjusted cumulative incidence is estimated for two levels of a covariate and two graphs
are produced for the main and competing event (fig. 5 in the second reference).{p_end}

{phang}
{cmd: use si.dta,clear}{p_end}
{phang}
{cmd: stset time, f(status==1)}{p_end}

{phang}
{cmd: stcompadj ccr=0 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main0 Compet0)}{p_end}
{phang}
{cmd: stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main1 Compet1)}{p_end}
{phang}
{cmd: twoway line Main0 Main1 _t, sort c(J J) scheme(lean2) xti("Years from HIV Infection") yti("Cumulative Incidence")}
{cmd: yla(0(.1).5,glp(shortdash)) xla(0(2)12) legend(pos(11) ring(0) label(1 "WW") label(2 "WM")) ti("AIDS")}{p_end}

{phang}
{cmd: twoway line Compet0 Compet1 _t if _t<13.5, sort c(J J) scheme(lean2) xti("Years from HIV Infection") yti("Cumulative Incidence")}
{cmd: yla(0(.1).5,glp(shortdash)) xla(0(2)12) legend(pos(11) ring(0) label(1 "WW") label(2 "WM")) ti("SI Appearance")}{p_end}



{p}Confidence intervals of the cumulative incidence are estimated by sampling with replacement (see {help bsample}) from data.{p_end}

{phang}
{cmd:stcompadj ccr=0 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main0 Compet0) bootci}{p_end}
{phang}
{cmd:stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) gen(Main1 Compet1) bootci}{p_end}

{phang}
{cmd:twoway line Main1 Hi_Main1 Lo_Main1 Main0 Hi_Main0 Lo_Main0 _t , sort c(J J J J J J) lp(l - - l - -)"}  
{cmd:scheme(lean2) xti("Years from HIV Infection") yti("Cumulative Incidence") yla(0(.1).65,nogrid) xla(0(2)12) legend(pos(11) ring(0)}
{cmd:label(1 "WW") label(4 "WM") order(1 4)) ti("AIDS")}{p_end}

{p}The estimate of the confidence intervals may be time and memory consuming mainly if starting data are large. Note also that
the confidence intervals obtained by using this approach is not yet validated.{p_end} 


{p}Confidence intervals of the cumulative incidence are now obtained by fitting a flexible parametric model (see {help stpm2}) to the expanded data set.{p_end}

{phang}
{cmd:stcompadj ccr=0 , compet(2) maineffect(ccr) competeffect(ccr) gen(Fl_Main0 Fl_Compet0) flexible ci}{p_end}
{phang}
{cmd:stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) gen(Fl_Main1 Fl_Compet1) flexible ci}{p_end}

{phang}
{cmd:twoway line Fl_Main1 Hi_Fl_Main1 Lo_Fl_Main1 Fl_Main0 Hi_Fl_Main0 Lo_Fl_Main0 _t , sort c(J J J J J J) lp(l - - l - -)"}  
{cmd:scheme(lean2) xti("Years from HIV Infection") yti("Cumulative Incidence") yla(0(.1).65,nogrid) xla(0(2)12) legend(pos(11) ring(0)}
{cmd:label(1 "WW") label(4 "WM") order(1 4)) ti("AIDS")}{p_end}


{p}After saving data in the expanded format the equality of the effect of a covariate on the main and competing event can be tested as follows: {p_end}

{p 0 4}- Saving expanding format data assuming that the covariate {it:ccr} has the same effect on the main and competing event{p_end}

{phang}
{cmd: stcompadj ccr=1 , compet(2) savexp(silong,replace)}{p_end}

{p 0 4}- Fit a Cox model where the ccr effect interacts with stratum indicator variable{p_end}
{phang}
{cmd: use silong,clear}{p_end}
{phang}
{cmd: xi: stcox i.ccr*i.stratum, strata(stratum) nohr nolog}{p_end}

{p}The coefficient for the interaction term represents the difference in the {it:ccr} effect on the main and competing
event. The corresponding {it:z} and {it:p} value assess the significance of this difference.{p_end}


{p}In the expanded data format the difference of the hazards of the main and competing event can also be checked under the 
assumption that they are proportional.{p_end}

{p 0 4}- Saving expanded data format assuming that the covariate {it:ccr} has different effects on the main and competing event{p_end}
{phang}
{cmd: stcompadj ccr=1 , compet(2) maineffect(ccr) competeffect(ccr) savexp(silong,replace)}{p_end}

{p 0 4}- Fit a Cox model whose covariates are the two {it:ccr} effects and the stratum indicator variable.{p_end}
{phang}
{cmd: use silong,clear}{p_end}
{phang}
{cmd: xi: stcox Main_ccr Compet_ccr stratum, nohr nolog}{p_end}

{p}The coefficient for the stratum term represents the difference of the cause-specific hazards of the competing vs. the main event
under the assumption that they are proportional.{p_end}



{p}Downloading ancillary files in one of your {cmd:`"`c(adopath)'"'} directory you can run this example.{p_end}

	  {it:({stata "stcompadj_example malignantmelanoma si":click to run})}



{title:Also see}

{psee}
On-line:  help for {help stcompet}, {help stpepemori} (if installed).
{p_end}



{title:References}

{p}Rosthoj S., Andersen P. K., and Abildstrom S. Z. SAS macros for estimation of the cumulative incidence functions based on a Cox
regression model for competing risks. Computer methods and Programs in Biomedicine (2004) 74: 69-75.{p_end}

{p}Putter H., Fiocco M., and Geskus R. B. Tutorial in biostatistics: Competing risks and multi-state models.
Statistics in Medicine (2007) 26: 2389-2430.{p_end}



{title:Aknowledgments}

{p}Thanks to Kerry Kammire of the tech-support for his suggestion in writing the Mata code.{p_end}



{title:Author}
{p}Enzo Coviello ({browse "mailto:enzo.coviello@alice.it":enzo.coviello@alice.it}){p_end}

