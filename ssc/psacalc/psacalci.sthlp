{smcl}

{title:Title}

{phang}
{bf:psacalc} {hline 2} Calculate treatment effects or bounds under proportional selection of observables and unobservables


{marker syntax}{...}
{title:Syntax}

{pstd}
Proportional Selection Bias Calculation

{p 8 17 2}
{cmdab:psacalc}
{indep_var}
[{cmd:,} {it:options}]

{pstd}
Immediate form of selection bias calculation

{p 8 17 2}
{cmdab:psacalci}
{it:uncont_beta}
{it:uncont_r-squared}
{it:control_beta}
{it:control_r-squared}
{it:depvar_variance}
[{cmd:,} {it:options2}]


{synoptset 20 tabbed}{...}
{synopthdr:options1}
{synoptline}
{syntab:Main}
{synopt:{opt mcontrol(varlist)}} controls to be included in all regressions{p_end}
{synopt:{opt rmax(#)}} maximum r-squared;
        default is {cmd:rmax(1)}{p_end}
{synopt:{opt delta(#)}} value of delta if exact calculation of treatment effect is requested;
        default is to calculate value of delta where beta=0 {p_end}
{synopt:{opt beta(#)}} value of beta if requesting a value of delta to match exact beta;
	default is beta=0 {p_end}
{synopt:{opt model(string)}} full syntax of model to be estimated; not required if running after estimation {p_end}
{synopt:{opt weight(string)}} weighting command if weights used (i.e. {cmd:weight(pw=length)}). {p_end}

{synoptline}
{p2colreset}{...}




{synoptset 20 tabbed}{...}
{synopthdr:options2}
{synoptline}
{syntab:Main}
{synopt:{opt rmax(#)}} maximum r-squared;
        default is {cmd:rmax(1)}{p_end}
{synopt:{opt delta(#)}} value of delta if exact calculation of treatment effect is requested;
        default is to calculate value of delta where beta=0 {p_end}
{synopt:{opt beta(#)}} value of beta if requesting a value of delta to match exact beta;
	default is beta=0 {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd: psacalc} This command is preformed after linear regression to evaluate the possible degree of omitted variable bias under the assumption that the selection on the observed controls is proportional to the selection on the unobserved controls.
Details of the calculation and theory are in Oster (2013).  The command requires the user to identify the independent variable of interest from the regression. 
The default is to produce a value of proportionality of selection (delta from Oster(2013)) which would result in a treatment effect of zero.  The two other options are: (1) produce a value of delta to match a particular
non-zero treatment effect or (2) produce an estimated treatment effect given a value of delta. The command gives the option to specify a maximum r-squared which would result if controls for the unobservables could be included; the default is 1. 
The command also gives the option to specify a subset of the observables which are not informative about the unobservables.   This can be run as post-estimation.  It can also be run as a single line command if the full model 
is specified with the {opt model} option.  


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt mcontrol} allows the user to input a list of variables which do not relate to a proportional set of unobservables. 

{phang}
{opt rmax(#)} allows the user to specify the maximum r-squared which would result if all unobservables were be included in the regression; default is 1.0.

{phang}
{opt delta(#)} requests that the program calculate an exact value for the causal treamtebnt effect, under an assumed delta.  An option of exact(1) would calculate the treatment effect under equal selection. 
The default is to calculate the value of delta such that beta=0.

{phang}
{opt beta(#)} requests that the program calculate a value for delta to match a beta which is not zero.  Calculation is done similarly to the default bounding but with non-zero beta.

{phang}
{opt model} provides the full model to be estimated.  This option is not required if running this as a post-estimation command but is useful if using a bootstrap.

{marker remarks}{...}
{title:Remarks}

{pstd}
For detailed information on psacalc, see Oster(2013).


{marker examples}{...}
{title:Examples}

    Setup
{phang2}{cmd:. sysuse auto.dta, clear }{p_end}
{phang2}{cmd:. regress price foreign mpg weight headroom trunk }{p_end}

{pstd}Obtain value of delta such that the effect of foreign is equal to zero, under assumption that mpg, headroom and trunk are proportional to unobservables, weight is fully observed and maximum r-squared is 0.7.
{p_end}
{phang2}{cmd:. psacalc foreign, mcontrol(weight) rmax(.7)}{p_end}

    With Model option

{phang2}{cmd:. psacalc foreign, mcontrol(weight) rmax(.7) model(regress price foreign mpg weight headroom trunk) }{p_end}


{marker saved}{...}
{title:Saved Results}

{pstd}
{cmd:psacalc} and {cmd:psacalci} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{synopt:{cmd:r(output)}}output value, either delta bound or beta calculation{p_end}

{marker ref}{...}
{title:References}

{pstd}
Oster, Emily.  "Unobservable Selection and Coefficient Stability: Theory and Validation."  NBER Working Paper, No. 19054.
