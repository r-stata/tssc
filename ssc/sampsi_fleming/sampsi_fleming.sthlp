{smcl}
{* *! version 1.02 7Aug2014}{...}
{cmd:help sampsi_fleming}
{hline}

{title:Title}

     {hi: Exact sample size calculation for single-stage designs}

{title:Syntax}

{p 8 17 2}
{cmdab:sampsi_fleming}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt p0:}(#)} specifies the null proportion. {p_end}
{synopt:{opt p1}(#)} specifies the alternative proportion.{p_end}
{synopt:{opt alpha}(#)} specifies the type I error, the default is 0.05.{p_end}
{synopt:{opt power}(#)} specifies the power, the default is 0.9.{p_end}
{synopt:{opt start}(#)} specifies the starting sample size of the search.{p_end}
{synopt:{opt n}(#)} specifies the sample size of the trial.{p_end}
{synopt:{opt r}(#)} specifies the number of responders to reject the null hypothesis.{p_end}
{synopt:{opt check}} specifies that p0. p1, n and r are fixed and will calculate the power and type 1 error of the design.{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
A single stage design requires all {hi:n} patients to receive and experimental treatment. 
Within a specified time period they will be observed to have responded (success) or not (failure).
The probability of a success in the trial is {hi:p} and this is compared to a fixed value {hi:p0}, which is the
probability of a success under the null hypothesis, this could represent no treatment or standard treatment. 
The trial therefore tests the null hypothesis {hi:H0:p=p0} against the alternative hypothesis {hi:H1:p>p0}. 
A particular value {hi:p1} ({hi:p1>p0}) is considered to be the desired probability of success.

{pstd}
The number of successes, {hi:S}, will follow a Binomial distribution with parameters {hi:n} and {hi:p}. A
sample size is found by using a search such that {hi:P(S>=u|p0)<=alpha} and {hi:P(S>=u|p1)>=power}. The design
is therefore characterised by the sample size {hi:n} and the critical value {hi:u}, the null hypothesis is 
rejected if there are {hi:u} or more successes in a trial of size {hi:n}.

{title:Latest Version}

{pstd}
The latest version is always kept on the SSC website. To install the latest version click
on the following link 

{pstd}
{stata ssc install sampsi_fleming, replace}.

{title:Options}

{dlgtab:Main}

{phang}
{opt p0(#)} specifies the null proportion. {p_end}

{phang}
{opt p1(#)} specifies the alternative proportion.{p_end}

{phang}
{opt alpha(#)} specifies the type I error, the default is 0.05.{p_end}

{phang}
{opt power(#)} specifies the power, the default is 0.9.{p_end}

{phang}
{opt Start(#)} specifies the starting sample size for the search.{p_end}

{phang}
{opt n(#)} specifies the sample size of the trial.{p_end}

{phang}
{opt r(#)} specifies the number of responders to reject the null hypothesis.{p_end}

{phang}
{opt check} specifies that p0. p1, n and r are fixed and will calculate the power and type 1 error of the design.{p_end}

{title: Examples}


{pstd}
The default sample size calculation

{pstd}
{space 2}{stata sampsi_fleming}

{pstd}
The default design has a sample size of 47 and a critical value of 15, the type I error is 0.0366 and power is 0.9012.

{pstd}
{space 2}{stata sampsi_fleming, p0(0.45) p1(0.5) s(800)}

{pstd}
A sample size of 861 and a critical value of 412 gives a type I error of 0.0499 and a power of 0.9024.
 
{pstd}
{space 2}{stata sampsi_fleming, a(0.01) p(0.8)}

{pstd}
A sample size of 52 and a critical value of 18 gives a type I error of 0.0099 and a power of 0.8245.

{pstd}
{space 2}{stata sampsi_fleming, p0(0.1) p1(0.35) a(0.01) p(0.8) }

{pstd}
A sample size of 25 and a critical value of 7 gives a type I error of 0.0095 and a power of 0.8266.

{pstd}
{space 2}{stata sampsi_fleming, p0(0.1) p1(0.2) start(84) power(0.8) a(0.05) }

{pstd}
Start searching for the above design at a sample size of 84, note there is a better design than this!

{pstd}
{space 2}{stata sampsi_fleming, p0(0.1) p1(0.2) n(84) r(13) check }

{pstd}
Shows that the selected design has a 0.0741 chance of a type I error and 88.22% power.

{title:Author}

{pstd}
Adrian Mander, MRC Biostatistics Unit, Cambridge, UK.{p_end}
{pstd}
Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}

{title:References}

{pstd}
R.P.A'Hern (2001) Sample size tables for exact single-stage phase II designs. {it:Statistics in Medicine} {bf:20}:859-866.

{pstd}
J.Whitehead (2008) Bayesian sample size for exploratory clinical trials incorporating historical data. {it:Statistics in Medicine} {bf:27}:2307-2327.

{pstd}
T.R. Fleming (1982) One-sample multiple testing procedure for phase II clinical trials. {it:Biometrics} {bf:38}:143-151.

{title:Also see}

{pstd}
Related commands

{pstd}
HELP FILES {space 13}SSC installation links{space 4}Description

{pstd}
{help samplesize} (if installed){space 4}({stata ssc install samplesize}){space 8}Sample Size graphics{p_end}
{pstd}
{help sampsi_reg} (if installed){space 4}({stata ssc install sampsi_reg}){space 8}Sample Size for linear regression{p_end}
{pstd}
{help sampsi_mcc} (if installed){space 4}({stata ssc install sampsi_mcc}){space 8}Sample Size for matched case/control studies{p_end}
{pstd}
{help sampsi_rho} (if installed){space 4}({stata ssc install sampsi_rho}){space 8}Sample Size for Pearson correlation{p_end}


