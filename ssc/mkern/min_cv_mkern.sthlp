{smcl}
{* 28sept2017}{...}
{cmd:help min_cv_mkern}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col: {hi:min_cv_mkern}} - Optimal bandwidth for multivariate nonparametric kernel regression{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:min_cv_mkern}
{it:outcome}{cmd:}
{it:covariates}{cmd:,}
{cmd:k}{cmd:(}{it:{help min_cv_mkern##kerneltype:kerneltype}}{cmd:)}
{cmd:modeltype}{cmd:(}{it:{help min_cv_mkern##modeltype:modeltype}}{cmd:)}
[{cmd:cvfile}{cmd:(}{it:filename}{cmd:)}
{cmd:graph}]


{title:Description}

{pstd}{cmd:min_cv_mkern} computes the "optimal bandwidth" for the multivariate nonparametric 
local kernel regression implemented via the command {helpb mkern}. {cmd:min_cv_mkern}
finds the bandwidth minimizing the Integrated Mean Square Error (IMSE) 
through a (computational) cross-validation (CV) approach. 

{phang} According to the {cmd:min_cv_mkern} syntax:

{phang} {it:outcome}: is the dependent variable.

{phang} {it:covariates}: is the set of covariates predicting the outcome.
    
{phang} {cmd:k}{cmd:(}{it:kerneltype}{cmd:)}: specifies the type of kernel function to use.

{phang} {cmd:model}{cmd:(}{it:modeltype}{cmd:)}: specifies the type of smoothing techniques to use. It may be either
"mean" (i.e., kernel local mean), or "linear" (i.e., kernel local linear).

{title:Options}

{phang} {cmd:cvfile}{cmd:(}{it:filename}{cmd:)}: allows to store cross-validation results in {it:filename.dta}.

{phang} {cmd:graph}: provides a graphical plot of the cross-validation loss function against the grid of bandwidths.


{marker kerneltype}{...}
{synopthdr:kerneltype_options}
{synoptline}
{syntab:kern}
{p2coldent : {opt epanechnikov}}uses a Epanechnikov kernel{p_end}
{p2coldent : {opt epan2}}uses a Epan2 kernel{p_end}
{p2coldent : {opt gaussian}}uses a Normal kernel {p_end}
{p2coldent : {opt biweight}}uses a Biweight (or Quartic) kernel{p_end}
{p2coldent : {opt rectangle}}uses a Uniform kernel{p_end}
{p2coldent : {opt triangle}}uses a Triangular kernel{p_end}
{p2coldent : {opt tricube}}uses a Tricube kernel{p_end}
{p2coldent : {opt parzen}}uses a Parzen kernel{p_end}
{p2coldent : {opt cosine}}uses a Cosine kernel{p_end}
{p2coldent : {opt triweight}}uses a Triweight kernel{p_end}
{synoptline}


{marker modeltype}{...}
{synopthdr:modeltype_options}
{synoptline}
{syntab:model}
{p2coldent : {opt mean}}Smoothing technique: kernel local mean{p_end}
{p2coldent : {opt linear}}Smoothing technique: kernel local linear{p_end}
{synoptline}


{pstd}
{cmd:min_cv_mkern} returns the following objects:

{pmore}

{pmore}
{inp:e(opt_bandw)} is a scalar containing the optimal bandwidth.

{pmore}
{inp:e(min_CV)} is a a scalar containing the minimum of the cross-validation loss function.


{title:Remarks} 

{pstd} - Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.


{title:Example}

*** Example 1 ***
. global KERNEL "parzen"  
. global MODEL "linear" 
. global y "price"
. global xvars "mpg weight trunk"
. sysuse auto , clear
*1.Compute the "optimal bandwidth"
. min_cv_min_cv_mkern $y $xvars , kern($KERNEL) modeltype($MODEL)
. global H=e(opt_bandw)
*2.Compute the "multivariate kernel fitted values"
. min_cv_mkern $xvars , y($y) y_fit(y_fitted) h($H) k($KERNEL) model($MODEL) graph

*** Example 2 ***
. global KERNEL "parzen"  
. global MODEL "linear" 
. use http://www.stata-press.com/data/r14/motorcycle , clear
*1.Compute the "optimal bandwidth"
. min_cv_min_cv_mkern accel time , kern($KERNEL) modeltype($MODEL)
. global H=e(opt_bandw) 
*2.Compute the "multivariate kernel fitted values"
. min_cv_mkern time , y(accel) y_fit(y_fitted) h($H) k($KERNEL) model($MODEL)
*3.Plot the results
. tw (scatter accel time ) (mspline y_fitted time)

  
{title:References}

{phang}Li, Q., Racine, J.S., 2006. {it:Nonparametric Econometrics: Theory and Practice}. Princeton University Press.{p_end}

{phang}Pagan, A., Ullah, A., 1999. {it:Nonparametric econometrics}. Cambridge University Press: Cambridge, UK.{p_end}

{phang}Hastie, T., Tibshirani, R., Freedman J., 2001. {it:The Elements of Statistical Learning: Data Mining, Inference, and Prediction}. Springer, New York.{p_end}


{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}IRCrES-CNR{p_end}
{phang}Research Institute on Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}


{title:Also see}

{psee}
Online: {helpb mkern}, {helpb lpoly}, {helpb locreg}, {helpb npregress}
{p_end}
