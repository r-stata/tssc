{smcl}
{* *!1.0.1  Brent Mcsharry brent@focused-light.net 6May2018}{...}
{cmd:help oeratio}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:oeratio} {hline 2}}ratio of observed to expected outcomes{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmdab:oeratio}
[{depvar predictvar}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt se:only}}suppress the display; calculate only the standard error; 
	programmer's option{p_end}
{synopt:{opth lev:el(#)}}specify confidence level; if not specified system default is used.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is allowed; see {manhelp by D}.
{p_end}

{title:Description}

{pstd}
{cmd:oeratio} calculates the ratio of the number of observed and expected outcomes. 
If {depvar} and {it:predictvar} (the variable specifying the individual probability of a 
positive outcome for each subject) are not specified, the command must follow a {cmd:logit} 
or {cmd:logistic} command.

{title:Options}

{dlgtab:Main}

{phang}
{opt seonly} restricts the calculation to only make calculations required to generate the
standard error and ratio of observed to expected outcomes. 

{phang}
{opt level} set the confidence level. If not specified, the default confidence level is
used; see {manhelp level R}.


{title:Remarks}

{pstd}
The variance is calculated using the Bernoulli distribution: that is if p is the prediction 
variable: variance = sum(p*(1-p)). In its current form the standard error, confidence 
intervals and z-score calculated do not take into account the error of the model.

{pstd}
When the command is used without arguments (following a {cmd:logit} 
or {cmd:logistic} command) and no {ifin} arguments are provided, only the estimation sample {cmd:e(sample)} is used. 
If you want to use the entire data set for the calculation, not just the estimation sample, you can specify {cmd:oeratio if 1}. When providing the {depvar predictvar} variable names,
any observations in which {it:either} variable contains missing will be excluded from the calculation.

{pstd}
This command was developed in order to calculate the standardized mortality ratio (SMR) 
for intensive care units (ICU) when applying logistic mortality prediction models such as
MPM, APACHE, PRISM or PIM models to unit data as part of benchmarking procedures.

{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse lbw2}{p_end}
{pstd}Logistic regression on even records{p_end}
{phang2}{cmd:. logit low age lwt race2 race3 smoke ptl ht ui if mod(id,2)==0}{p_end}
{pstd}Ratio of observed to expected outcomes when model applied to odd records{p_end}
{phang2}{cmd:. oeratio if mod(id,2)==1}{p_end}
    {hline}
{pstd}externally validated logistic regression model covariates applied to lbw data{p_end}
{phang2}{cmd:. generate p = invlogit(-2 + (0.05* age))}{p_end}
{phang2}{cmd:. oeratio low p}{p_end}
    {hline}

{title:Saved Results}

{pstd}
{cmd:oeratio} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(predicted)}}number of outcomes predicted{p_end}
{synopt:{cmd:e(obs)}}number of outcomes observed{p_end}
{synopt:{cmd:e(ratio)}}ratio of observed to predicted outcomes{p_end}
{synopt:{cmd:e(se)}}standard error{p_end}
{synopt:{cmd:e(z)}}z score of the difference between observed and predicted outcome{p_end}


{title:Also see}

{psee}
Calculating standardised mortality {it:rate} (as opposed to {it:ratio}) {manhelp stptime ST};{break}
{p_end}
