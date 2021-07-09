{smcl}
{* 09 July 2013}{...}
{cmd:help rhausman}{right: ({browse "http://staff.vwi.unibe.ch/kaiser/research.html"})}
{hline}

{title:Title}

{p2colset 5 25 22 2}{...}
{p2col :{hi: rhausman} {hline 2}}Robust Hausman Specification Test{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:rhausman} {model-1} {model-2}  {cmd:,}  [{it:options}]

{synoptset 31 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opth reps(integer)}}number of bootstrap repetitions{p_end}
{synopt:{opth subset(varlist)}}specify a subset of independent variables{p_end}
{synopt:{cmd: bsdata(}newdataset [, replace]{cmd:)}}save bootstrapped data to disk{p_end}
{synopt:{cmd: cluster}}use a cluster-robust bootstrap{p_end}
{synoptline}
{p2colreset}{...}
{phang} where {it:model-1} and {it:model-2} are names under
which estimation results were stored via {helpb estimates store}.{p_end}

{phang}Note: Factor variables (see {helpb fvvarlist}) are not allowed in the 
command lines of {it:model-1} and {it:model-2}.{...}
{p_end}



{title:Description}

{pstd}
{cmd:rhausman} performs a (cluster-)robust version of Hausman's specification test.
  To use {cmd:rhausman}, perform the following steps:

{p 6 10 2}(1) obtain an estimator that is {hi:consistent} whether or not the
              null hypothesis is true;
{p_end}
{p 6 10 2}(2) store the estimation results under {it:model-1} by using
              {helpb estimates store};
{p_end}
{p 6 10 2}(3) obtain an estimator that is {hi:consistent}
              under the null hypothesis, but {hi:inconsistent}
              otherwise;
{p_end}
{p 6 10 2}(4) store the estimation results under {it:model-2} by using
              {helpb estimates store};
{p_end}
{p 6 10 2}(5) use {cmd:rhausman} to perform the test

{p 14 14 2}{cmd:rhausman} {it:model-1} {it:model-2} [{cmd:,} {it:options}]


{pstd}
The command {cmd: rhausman}
implements a (cluster-)robust version of the Hausman test based on the
bootstrap and does not require one of the two estimators to be fully
efficient under the null hypothesis. 
The test statistic is of the form

{pstd}
      H= (b1-b2)' * [V_bootstrapped(b1-b2)]^(-1) * (b1-b2) ~ chi2(k)

{pstd}
where b1 and b2 are (k x 1) vectors of estimated coefficients from models 1 and 
2, respectively, and V_bootstrapped(b1-b2) is the covariance
matrix of (b1-b2) computed from the bootstrapped joint distribution.
See Camerion and Trivedi (2005, pp. 717) for more details.

{pstd}
{hi:Why should a robust version of the Hausman test be used?}
The traditional Hausman test (see {helpb hausman}) requires one estimator to
be fully efficient under the null hypothesis. This assumption is
demanding and will often be
violated in microeconometrics data. 
For example, when testing a random-effects (RE) model vs. 
a fixed-effects (FE) model, the traditional Hausman test (see {helpb hausman})
 cannot be used in the presence of heteroskedasticity or 
 serial correlation within panels because 
in this case, the RE-GLS estimator is not fully efficient. 

{pstd}
{hi:Independent Variables:} Note that the command automatically excludes 
from the test the intercept 
as well as all those coefficients
that are not identified in one (or both) model(s).  
 

{title:Options}

{phang} {cmd:reps(}{it:integer}{cmd:)} specifies the number of 
bootstrap repetitions. Default is 100.{p_end}

{phang} {cmd:subset(}{it:varlist}{cmd:)} can be used to perform the test
on a subset of the independent variables. {p_end}

{phang} {cmd: bsdata(}{it:newdataset} [, replace]{cmd:)} allows the user
to save the bootstrapped coefficients to disk.{p_end}

{phang} {cmd:cluster} uses a cluster-robust bootstrap procedure.
The cluster variable (panel variable) must be specified prior to the test,
either in
{helpb xtset} or in the option {cmd:vce( )} of {it:model-1} and {it:model-2}.{p_end}


 
{title:Example}

{phang2}{cmd:/* Fixed Effects vs. Random Effects  */}{p_end}
{phang2}{cmd:webuse nlswork, clear }{p_end}
{phang2}{cmd:xtset idcode}{p_end}
{phang2}{cmd:glo xlist "collgrad grade union msp nev_mar age race not_smsa south year"}{p_end}
{phang2}{cmd:xtreg ln_wage $xlist, fe}{p_end}
{phang2}{cmd:est sto myfe}{p_end}
{phang2}{cmd:xtreg ln_wage $xlist, re}{p_end}
{phang2}{cmd:est sto myre}{p_end}
{phang2}{cmd:rhausman myfe myre, reps(200) cluster}{p_end}



{title:Saved results}
 
{phang}{cmd:rhausman} saves the following in {cmd:r()}:{p_end}
 
{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(chi2)}}chi-squared test statistic{p_end}
{synopt:{cmd:r(rank)}}rank{p_end}
{synopt:{cmd:r(df)}}degrees of freedom{p_end}
{synopt:{cmd:r(p)}}p-value{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(b_dif)}}differences in coefficients{p_end}
{synopt:{cmd:r(b_dif_boot)}}differences in coefficients (boostrap means){p_end}
{synopt:{cmd:r(V_dif)}}bootstrapped covariance matrix{p_end}
 
 
 
{title:References}
 
{phang}Cameron, A. Colin, and Pravin K. Trivedi. 
{it:Microeconometrics: methods and applications.} 
Cambridge university press, 2005.{p_end}



{title:Please cite {cmd:rhausman} as follows}

{pstd}
Kaiser, Boris (2014). "RHAUSMAN: Stata module to perform a (cluster-)robust
Hausman test", University of Bern.{p_end}
 
 
 
{title:Disclaimer}

{p 4 4 2}THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. 

{p 4 4 2}IN NO EVENT WILL THE COPYRIGHT HOLDERS OR THEIR EMPLOYERS, OR ANY OTHER PARTY WHO
MAY MODIFY AND/OR REDISTRIBUTE THIS SOFTWARE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY 
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR 
INABILITY TO USE THE PROGRAM.

 
 
{title:Author}
 
{pstd}For questions, queries or suggestions, please contact{p_end}
{pstd}Boris Kaiser, bo.kaiser@gmx.ch{p_end}
 
