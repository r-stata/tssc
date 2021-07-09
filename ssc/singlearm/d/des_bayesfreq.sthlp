{smcl}
{* *! version 1.0 14 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "des_bayesfreq##syntax"}{...}
{viewerjumpto "Description" "des_bayesfreq##description"}{...}
{viewerjumpto "Options" "des_bayesfreq##options"}{...}
{viewerjumpto "Remarks" "des_bayesfreq##remarks"}{...}
{viewerjumpto "Examples" "des_bayesfreq##examples"}{...}
{title:Title}
{phang}
{bf:des_bayesfreq} {hline 2} Design a Bayesian-frequentist single-arm trial for a single binary endpoint

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:des_bayesfreq}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt j(#)}} The maximal number of stages to allow. Defaults to 2.{p_end}
{synopt:{opt pi0(#)}} The (undesirable) response probability used in the definition of the null hypothesis. Defaults to 0.1.{p_end}
{synopt:{opt pi1(#)}} The (desirable) response probability at which the trial is powered. Defaults to 0.3.{p_end}
{synopt:{opt a:lpha(#)}} The desired maximal type-I error-rate. Defaults to 0.05.{p_end}
{synopt:{opt b:eta(#)}} The desired maximal type-II error-rate. Defaults to 0.2.{p_end}
{synopt:{opt mu(#)}} The first shape parameter of the Beta distribution. Defaults to 0.1.{p_end}
{synopt:{opt nu(#)}} The second shape parameter of the Beta distribution. Defaults to 0.9.{p_end}
{synopt:{opt nmin(#)}} The minimal total sample size to allow in considered designs. Defaults to 1.{p_end}
{synopt:{opt nmax(#)}} The maximal total sample size to allow in considered designs. Defaults to 30.{p_end}
{synopt:{opt optimality(string)}} The choice of optimal design criteria. Must be one of ess or minimax. Defaults to ess.{p_end}
{synopt:{opt control(string)}} Error-rates to control. Should be either  frequentist, bayesian, or both. Defaults to both.{p_end}
{synopt:{opt eq:ual_n(#)}} An integer indicating that the sample size of each stage should be equal (equal = 1). Default value is 0.{p_end}
{synopt:{opt pl(#)}} Predictive probability value used in determining when to stop the trial early for futility. Defaults to 0.5.{p_end}
{synopt:{opt pu(#)}} Predictive probability value used in determining when to stop the trial early for futility. Defaults to 0.9.{p_end}
{synopt:{opt pt(#)}} Terminal predictive probability value used in determining when the trial is a success. Defaults to 0.95.{p_end}
{synopt:{opt sum:mary(#)}} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.{p_end}
{synopt:{opt pl:ot}} Indicates that the stopping boundaries of the identified optimal design should be plotted.{p_end}
{synopt:{opt *}} Additional options to use during plotting.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

Determines optimised single- and two-stage Bayesian-frequentst single-arm clinical
trial designs for a single binary primary endpoint, using exact calculations.

Designs controlling Bayesian, frequentist, or Bayesian and frequentist operating
characteristics can be determining, which optimise either the Bayesian expected
sample size or the maximal sample size.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt j(#)} The maximal number of stages to allow. Defaults to 2.

{phang}
{opt pi0(#)} The (undesirable) response probability used in the definition of the
null hypothesis. Defaults to 0.1.

{phang}
{opt pi1(#)} The (desirable) response probability at which the trial is powered.
Defaults to 0.3.

{phang}
{opt a:lpha(#)} The desired maximal type-I error-rate. Defaults to 0.05.

{phang}
{opt b:eta(#)} The desired maximal type-II error-rate. Defaults to 0.2.

{phang}
{opt mu(#)} The first shape parameter of the Beta distribution. Defaults to 0.1.

{phang}
{opt nu(#)} The second shape parameter of the Beta distribution. Defaults to 0.9.

{phang}
{opt nmin(#)} The minimal total sample size to allow in considered designs.
Defaults to 1.

{phang}
{opt nmax(#)} The maximal total sample size to allow in considered designs.
Defaults to 30.

{phang}
{opt optimality(string)} The choice of optimal design criteria. Must be one of ess or minimax. Defaults to ess.

{phang}
{opt control(string)} Error-rates to control. Should be either  frequentist, bayesian, or both. Defaults to both.

{phang}
{opt eq:ual_n(#)} An integer indicating that the sample size of each stage should be equal (equal = 1). Default value is 0.

{phang}
{opt pl(#)} Predictive probability value used in determining when to stop the trial early for futility. Defaults to 0.5.

{phang}
{opt pu(#)} Predictive probability value used in determining when to stop the trial early for futility. Defaults to 0.9.

{phang}
{opt pt(#)} Terminal predictive probability value used in determining when the trial is a success. Defaults to 0.95.

{phang}
{opt sum:mary(#)} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.

{phang}
{opt pl:ot} Indicates that the stopping boundaries of the identified optimal design should be plotted.

{phang}
{opt *} Additional options to use during plotting.

{marker examples}{...}
{title:Examples}

{phang}
{stata des_bayesfreq}

{phang}
{stata des_bayesfreq, j(1)}

{title:Author}
{p}

Michael J. Grayling, MRC Biostatistics Unit, Cambridge.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}
