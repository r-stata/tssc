{smcl}
{* 28sept2017}{...}
{cmd:help mkern}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col: {hi:mkern }{hline 1}}Multivariate nonparametric kernel regression{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:mkern}
{it:covariates}{cmd:,}
{cmd:y}{cmd:(}{it:outcome}{cmd:)}
{cmd:y_fit}{cmd:(}{it:name}{cmd:)}
{cmd:h}{cmd:(}{it:#}{cmd:)}
{cmd:k}{cmd:(}{it:{help mkern##kerneltype:kerneltype}}{cmd:)}
{cmd:model}{cmd:(}{it:{help mkern##modeltype:modeltype}}{cmd:)}
[{cmd:graph}
{cmd:save_graph}{cmd:(}{it:graphname}{cmd:)}]

{title:Description}

{pstd}{cmd:mkern} extimates a multivariate nonparametric local kernel regression, by a "radial" local mean or local linear
approach using various Kernel functions as weighting schemes (at user's choice). 
Using the companion command {helpb min_cv_mkern}, one can also compute the "optimal bandwidth", i.e. the bandwidth 
minimizing the integrated mean square error (IMSE), 
via a (computational) cross-validation (CV) approach. Users can also provide their own choice of the bandwidth, 
thus producing estimation for both oversmoothing and undersmoothing cases. 
Finally, as an option, {cmd:mkern} offers a graphical plot of the row data against predicted values 
to assess the degree of {it:smoothness} of the provided estimation.


{phang} According to the {cmd:mkern} syntax:

{phang} {it:covariates}: is the set of covariates predicting the outcome.

{phang} {cmd:y}{cmd:(}{it:outcome}{cmd:)}: is the outcome variable.

{phang} {cmd:y_fit}{cmd:(}{it:name}{cmd:)}: defines the name of the variable containing the estimated fitted values.

{phang} {cmd:h}{cmd:(}{it:#}{cmd:)}: specifies the bandwidth of the kernel weighting function.
       
{phang} {cmd:k}{cmd:(}{it:kerneltype}{cmd:)}: specifies the type of kernel function to use.

{phang} {cmd:model}{cmd:(}{it:modeltype}{cmd:)}: specifies the type of smoothing techniques to use. It may be either
"mean" (i.e., kernel local mean), or "linear" (i.e., kernel local linear).

{title:Options}

{phang} {cmd:graph}: provides a graphical plot of the row data against the predicted values.
   
{phang} {cmd:save_graph}{cmd:(}{it:graphname}{cmd:)} allows to save "graph" with a name a declared in {it:graphname}.


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
{cmd:mkern} returns the following objects:

{pmore}
{cmd:y_fit}{cmd:(}{it:name}{cmd:)} is a generated variable containing model's fitted values.

{pmore}
{inp:e(band)} is a scalar containing the bandwidth used to estimate the model.

{pmore}
{inp:e(CV)} is a scalar containing the value of the cross-validation objective function.

{pmore}
{inp:e(kern)} is a local macro containing the name of the kernel function used.



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
. min_cv_mkern $y $xvars , kern($KERNEL) modeltype($MODEL)
. global H=e(opt_bandw)
*2.Compute the "multivariate kernel fitted values"
. mkern $xvars , y($y) y_fit(y_fitted) h($H) k($KERNEL) model($MODEL) graph

*** Example 2 ***
. global KERNEL "parzen"  
. global MODEL "linear" 
. use http://www.stata-press.com/data/r14/motorcycle , clear
*1.Compute the "optimal bandwidth"
. min_cv_mkern accel time , kern($KERNEL) modeltype($MODEL)
. global H=e(opt_bandw) 
*2.Compute the "multivariate kernel fitted values"
. mkern time , y(accel) y_fit(y_fitted) h($H) k($KERNEL) model($MODEL)
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
Online: {helpb min_cv_mkern}, {helpb lpoly}, {helpb locreg}, {helpb npregress}
{p_end}
