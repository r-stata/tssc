{smcl}
{* *! version 1.0.0 3mar2014}{...}
{cmd: help treatoprobit postestimation}
{right:also see: {help treatoprobit}}
{hline}

{title:Treatment Effects Ordered Probit Postestimation}

{p2colset 5 36 38 2}{...}
{p2col:{hi: treatoprobit postestimation} {hline 2}}Postestimation
tools for treatobprobit{p_end}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict}
{dtype}
{newvar}
{ifin}
[{cmd:,} {it:options}]

{marker options}{...}
{synoptset 13 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{synopt:{opt p11}}joint probability of treatment and outcome 1(the default){p_end}
{synopt:{opt p1*}}joint probability of treatment and outcome *{p_end}
{synopt:{opt p0*}}joint probability of non-treatment and outcome * {p_end}
{synopt:{opt te*}}treatment effect on outcome * {p_end}
{synopt:{opt tt*}}treatment effect on treated for outcome * {p_end}
{synopt:{opt sete*}} standard error of treatment effect on outcome * {p_end}
{synopt:{opt sett*}} standard error of treatment on treated for outcome * {p_end}
{synopt:{opt ptr}}probability of treatment {p_end}
{synopt:{opt xbout}}linear prediction for outcome{p_end}
{synopt:{opt lf}}likelihood contribution {p_end}

{synoptline}
{p2colreset}{...}


{title:Options for predict}

{dlgtab:Main}

{phang}
{opt p11} calculates the joint probability of participation in treatment and outcome #1; the default.

{phang}
{opt p1*} caluclates the joint probability of participation in treatment and outcome #*.

{phang}
{opt po*} caluclates the joint probability of non-participation in treatment and outcome #*.

{phang}
{opt te*} caluclates the treatment effect on outcome #*.

{phang}
{opt tt*} caluclates the treatment effect on the treated for outcome #*.

{phang}
{opt sete*} caluclates the standard error of the treatment effect on outcome #*.

{phang}
{opt sett*} caluclates the standard error of the treatment effect on the treated for outcome #*.

{phang}
{opt xbout} calculates the linear predictions for the outcome variable.

{phang}
{opt ptr} calculates the probability of treatment.

{phang}
{opt lf} calculates the likelihood contribution for each observation.


{title:Examples}

{phang}{cmd:. treatoprobit y x1 x2, treat(d=x1 x2 z) vce(robust)}{p_end}
{phang}{cmd:. predict pr11}{p_end}
{phang}{cmd:. predict ate1, te1}{p_end}
{phang}{cmd:. predict att3, tt3}{p_end}

{title:Also see}

{psee}
Online:  
{helpb treatprobit}{break}
{p_end}