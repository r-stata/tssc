{smcl}
{* 08feb2016}{...}
{cmd:help for xtmixedioupredict}{right:Rachael Hughes}
{hline}

{title:Title}

{p2colset 5 26 18 2}{...}
{p2col :{hi:xtmixedioupredict} {hline 2}}Obtains predictions after estimation of the linear mixed effects Integrated Ornstein-Uhlenbeck (IOU) model{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:predict} {newvar} {ifin} 
[{cmd:,} {it:options} ] 

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt xb}}linear prediction for the fixed portion of the model only; the default{p_end}
{synopt :{opt stdp}}standard error of the fixed portion linear prediction{p_end}
{synopt :{opt fit:ted}}fitted values, fixed portion linear prediction plus contributions based on predicted random effects and realizations of IOU (or Brownian Motion) process{p_end}
{synopt :{opt res:iduals}}residuals, response minus fitted values{p_end}
{synoptline}


{title:Description}

    xtmixedioupredict creates a new variable containing predictions such as linear predictions, standard errors, fitted values and residuals.

{title:Options}

{dlgtab:main}

{phang}
{opt xb}, the default, calculates the linear prediction xb based on the estimated fixed effects (coefficients) in the model.  

{phang}
{opt stdp} calculates the standard error of the linear predictor xb.

{phang}
{opt fitted} calculates fitted values, which are equal to the fixed portion linear predictor plus contributions based on predicted random effects and the realizations
of the IOU (or Brownian Motion) process, or in mixed-model notation xb + Zu + w.  

{phang}
{opt residuals} calculates (level-1) residuals, equal to the responses minus fitted values, or in mixed-model notation y - xb - Zu - w. 


{title:Examples}

{synoptline}

{phang}
Generate liner prediction for the fixed portion of the model{p_end}
{space 10}{cmd:. predict xbvar} 
{space 4}or 
{space 10}{cmd:. predict xbvar, xb}

{phang}
Generate standard error of the linear predictor xb{p_end}
{space 10}{cmd:. predict stdpvar, stdp}

{phang}
Generate fitted values{p_end}
{space 10}{cmd:. predict fittedvar, fit}

{phang}
Generate (level-1) residuals{p_end}
{space 10}{cmd:. predict residualvar, res}

{synoptline}
	
