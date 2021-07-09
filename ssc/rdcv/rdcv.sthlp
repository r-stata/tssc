{smcl}
{* 09 July 2013}{...}
{cmd:help rdcv}{right: ({browse "http://staff.vwi.unibe.ch/kaiser/research.html"})}
{hline}

{title:Title}

{p2colset 5 25 22 2}{...}
{p2col :{hi: rdcv} {hline 2}}Sharp Regression Discontinuity Design with
Cross Validation Bandwidth Selection{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:rdcv} {depvar} {it:indepvar} {weight} {ifin} {cmd:,} 
({it:threshold(numeric)} | {it:notrd}) [{it:options}]

{synoptset 31 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opth thr:eshold(numeric)}}RD: threshold for treatment.{p_end}
{synopt:{cmdab:notrd}}use this option for local regression outside RD designs.{p_end}
{synopt:{opth k:ernel(lpoly##kernel:kernel)}}specify kernel function{p_end}
{synopt:{opt deg:ree(#)}}use polynomial of order #{p_end}
{synopt:{cmd: strict}}treatment is strictly above threshold (RD only){p_end}
{synopt:{opth vce(vcetype)}}variance estimator at threshold{p_end}

{syntab :cross validation (CV) options}
{synopt:{opth ng:rid(integer)}}specify number of grid points {p_end}
{synopt:{opth grid:points(numlist)}}user-specified grid{p_end}
{synopt:{opth cvs:ample(numeric)}}window around threshold to use for CV in % of sample{p_end}
{synopt:{cmd: wide}}use wide grid{p_end}

{syntab :other bandwidth choice methods}
{synopt:{cmdab: ik:bwidth}}uses Imbens-Kalyanaraman bandwidth instead of CV.{p_end}
{synopt:{cmdab: rot:bwidth}}uses ROT plug-in bandwidth instead of CV.{p_end}
{synopt:{opth bw:idth(numlist)}}user's bandwidth choice{p_end}

{syntab :define estimation points / save estimates}
{synopt:{opth at(varname)}}estimate reg. function at values specified in {it:varname}{p_end}
{synopt:{opt n(#)}}estimate reg. function at # points{p_end}
{synopt:{opth gen:erate(newvar)}}save estimates of reg. function  in {it:newvar}{p_end}
{synopt:{opth se(newvar)}}save estimates of standard error in {it:newvar}{p_end}

{syntab :graph options}
{synopt:{cmd: ci}}plots a confidence interval{p_end}
{synopt:{opth level(numeric)}}specifies the confidence level{p_end}
{synopt:{cmdab: gropt}}options for the combined graph{p_end}
{synopt:{cmdab: lineopt}}options of the line plot{p_end}
{synopt:{cmdab: areaopt}}options for the CI area plot{p_end}
{synopt:{cmdab: scatopt}}options for the scatter plot{p_end}
{synopt:{cmdab: nosc:atter}}suppresses the scatter plot{p_end}
{synopt:{cmdab: nogr:aph}}suppresses the graph{p_end}

{synoptline}
{p 4 6 2}
{cmd:aweight}s and {cmd:fweight}s are allowed; see {help weight}.{p_end}


{title:Description}

{pstd}
The command {cmd: rdcv}
implements estimation of (sharp) regression discontinuity
designs (RD) using a flexible cross-validation (CV) procedure for
optimal bandwidth selection. 
The CV criterion minimizes the integrated mean squared error
(see e.g. Hanson 2014, Ch. 11.6).
Estimation is based on nonparametric kernel methods 
(local linear or local polynomial regression). {p_end}

{pstd}
The bandwidth is determined automatically by an adaptive grid search, 
but the user may also specify his own set of gridpoints. As alternatives
to the CV bandwidth, the module can also compute bandwidths
based on the plug-in method (Stata default in {help lpoly}) or based
on the method in Imbens and Kalyanaraman (2012).{p_end}
 

{title:Options}

{phang} {cmdab:thr:eshold}{it:(numeric)} is required for the sharp regression 
discontinuity (RD) design. It is the value of {it:indepvar} corresponding
to the discontinuity. It generates D=(indepvar>=threshold).{p_end}

{phang} {cmdab:notrd} can be used to perform local kernel regression
outside RD designs, similar to the {help lpoly} command. 
The difference is that bandwidth selection is based on cross validation.{p_end}

{phang} {opth "kernel(lpoly##kernel:kernel)"} specifies the 
kernel function. Default is triangular.{p_end}

{phang} {cmdab:deg:ree}{it:(#)} specifies the polynomial degree 
of order #. Default is local linear regression, i.e. degree=1.{p_end}

{phang} {cmd:strict} allows the user to specify the treatment as a strict 
inequality: D=(indepvar>threshold).{p_end}

{phang} {cmdab:vce}{it:(vcetype)} specifies the variance estimator for
the estimation of the discontinuity.{p_end}

{phang} {cmdab:ng:rid}{it:(integer)} specifies the number of grid points for the 
cross validation (CV) procedure. The default is 20.{p_end}

{phang} {cmdab:grid:points}({it:numlist}) allows the user to specify the gridpoints
for the cross-validation (CV) procedure. Per default, the lowest (highest) grid point is half
(twice) the pilot bandwidth determined by the rule-of-thumb method.   {p_end}

{phang} {cmdab:cvs:ample(}{it:numeric}) allows the user to specify that only the x% closest 
 observations on each side of the threshold are used in the CV procedure. Default is to
 use all observations. Example: cvsample(50 50) requests that only the closest
 50% of observations on both sides of the threshold are used.{p_end}

{phang} {cmdab:wide} widens the default grid. This option should be used if the 
minimum MSE is in the corner of the grid.{p_end}

{phang} {cmdab:ik:bwidth} computes the optimal bandwidth according to the method 
of Imbens and Kalyanaraman (2012) instead of the CV method. {p_end}

{phang} {cmdab:rot:bwidth} computes the optimal bandwidth according to the 
plug in method (ROT) as performed by the {help lpoly} command. {p_end}

{phang} {cmdab:bw:idth}{it:(numlist)} overrides the optimal CV bandwidth with the user's
choice. The option takes two numbers in the RD case and one
number otherwise. {p_end}

{phang} {cmdab:at}{it:(varname)} estimates the regression function at the 
values specified in the variable {it:varname}. {p_end}

{phang} {cmdab:n}(#) estimates the regression function at # points. The 
points are computed uniformly from the 1st to the 99th percentile of the 
support of the independent variable. {p_end}

{phang} {cmdab:gen:erate}{it:(newvar)} saves estimates of the regression
function in the variable {it:newvar}. {p_end}

{phang} {cmdab:se}{it:(newvar)} saves estimates of the standard error of
the regression function in the variable {it:newvar}. {p_end}

{phang} {cmd:ci} requests a confidence interval to be included in the plot.{p_end}

{phang} {cmdab:level}{it:(numeric)} specifies the confidence level when {cmd:ci}
is specified. Default is a 95% interval. {p_end}

{phang} {cmdab:gr:opt}({it:options list}) allows the user to pass on {help twoway_options}
 options to edit the combined graph. Default is 
 "scheme(s1mono) legend({it:content depends on options}) 
 yti({it:label depvar}) xti({it:label indepvar}) xli({it:threshold value}, lp(dash))"{p_end}
 
{phang} {cmdab:line:opt}({it:options list}) allows the user to pass on 
 {help line} options to edit the line plot. Default is "sort lc(navy)".{p_end}
 
{phang} {cmdab:area:opt}({it:options list}) allows the user to pass on  {help rarea}
 options to edit the rarea plot (confidence band). 
 Default is "sort lc(gs13) fc(gs13)".{p_end}
 
{phang} {cmdab:scat:opt}({it:options list}) allows the user to pass on  {help scatter}
 options to edit the scatter plot. Default is "m(O) mc(green)".{p_end}

{phang} {cmdab:nosc:atter} supresses the production of the scatter plot.{p_end}

{phang} {cmdab:nogr:aph} supresses the production of the graph.{p_end}
 


{title:Example}

{phang2}{cmd:/* Simulated Example */}{p_end}
{phang2}{cmd:clear }{p_end}
{phang2}{cmd:set obs 200}{p_end}
{phang2}{cmd:set seed 123}{p_end}
{phang2}{cmd:g double x = runiform() * 6 }{p_end}
{phang2}{cmd:g y = (x>3) + sin(x) + 0.1*rnormal() }{p_end}
{phang2}{cmd:rdcv y x , thr(3) ci }{p_end}
{phang2}{cmd:rdcv y x , thr(3) ci kernel(rec) deg(3) }{p_end}
{phang2}{cmd:rdcv y x , thr(3) ci ngrid(10) }{p_end}
{phang2}{cmd:rdcv y x , thr(3) ci gen(mymu) se(myse) }{p_end}


{title:Saved results (depending on options)}
 
{phang}{cmd:rdcv} saves the following in {cmd:r()}:{p_end}
 
{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(jump)}}estimate of treatment effect (RD){p_end}
{synopt:{cmd:r(se_jump)}}standard error of r(jump) (RD){p_end}
{synopt:{cmd:r(b1)}}estimate below threshold (RD){p_end}
{synopt:{cmd:r(se1)}}standard error of r(b1) (RD){p_end}
{synopt:{cmd:r(b0)}}estimate above threshold (RD){p_end}
{synopt:{cmd:r(se0)}}standard error of r(b0) (RD){p_end}
{synopt:{cmd:r(bw0)}}bandwidth below threshold (RD){p_end}
{synopt:{cmd:r(bw1)}}bandwidth above threshold (RD){p_end}
{synopt:{cmd:r(N0)}}# observations below threshold (RD){p_end}
{synopt:{cmd:r(N1)}}# observations above threshold (RD){p_end}

{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(threshold)}}threshold value (RD){p_end}
{synopt:{cmd:r(degree)}}polynomial degree{p_end}
{synopt:{cmd:r(kernel)}}kernel function{p_end}
{synopt:{cmd:r(depvar)}}dependent variable{p_end}
{synopt:{cmd:r(indepvar)}}independent variable{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(R)}}estimation results from table (RD){p_end}
{synopt:{cmd:r(cv_bw0)}}cross-validation criteria below threshold{p_end}
{synopt:{cmd:r(cv_bw1)}}cross-validation criteria above threshold (RD){p_end}
 
 
{title:Requirements}

{phang} This command requires the packages {cmd:distinct} and {cmd:moremata}
 that you can find by typing {cmd:findit distinct} and {cmd:findit moremata},
 respectively. {p_end}
 
 
{title:References}
 
{phang}Imbens, Guido, and Karthik Kalyanaraman. 
"Optimal bandwidth choice for the regression discontinuity estimator." 
{it:The Review of Economic Studies} 79.3 (2012): 933-959.{p_end}

{phang}
Hanson, Bruce E. 2014. Econometrics. University of Wisconsin. 
{browse "http://www.ssc.wisc.edu/~bhansen/econometrics/Econometrics.pdf"}.{p_end}


{title:Please cite {cmd:rdcv} as follows}

{pstd}
Kaiser, Boris (2014). "RDCV: Stata module to estimate sharp regression discontinuity
designs using cross-validation bandwidth selection", University of Bern.{p_end}
 
 
{title:Disclaimer}

{p 4 4 2}THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. 

{p 4 4 2}IN NO EVENT WILL THE COPYRIGHT HOLDERS OR THEIR EMPLOYERS, OR ANY OTHER PARTY WHO
MAY MODIFY AND/OR REDISTRIBUTE THIS SOFTWARE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY 
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM.

 
{title:Author}
 
{pstd}For questions, queries or suggestions, please contact{p_end}
{pstd}Boris Kaiser, bo.kaiser@gmx.ch{p_end}
 
