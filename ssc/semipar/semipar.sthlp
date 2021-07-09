{smcl}
{* *! version 1.0  5march2011}{...}
{cmd:help semipar} {right: (Vincenzo Verardi and Nicolas Debarsy)}
{hline}

{title:Title}

{p 4 18 2}
{hi:semipar}

{title:Syntax}

{pstd}
Robinson's (1988) semiparametric regression estimator

{p 8 12 2}
{cmd:semipar} {varlist} {ifin} {weight}{cmd:,} {opt nonpar(varname)}
[{it:{help semipar##semiparopts:options}}]


{synoptset 19 tabbed}
{marker semiparopts}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt nonpar(varname)}}Specifies the variable that enters the model nonlinearly{p_end}
{synopt:{opt gen:erate(varname)}}Generate the nonparametric fit of the dependent variable{p_end}
{synopt:{opt par:tial(varname)}}Generate the dependent variable partialled out from the parametric fit{p_end}
{synopt:{opt degree(#)}}Specifies the degree of the local weighted polynomial fit used in the kernel; default is 1 (see {helpb lpoly}){p_end}
{synopt:{opt trim(#)}}Specifies the level of trimming for the pdf of the variable entering the model nonlinearly; default is 0 (no trimming){p_end}
{synopt:{opt kernel(kernel)}}Specifies kernel function; default is {cmd:kernel(gaussian)}{p_end} 
{synoptline}
{syntab: Kernels}
{synopt:{opt gaussian}} Gaussian kernel function, the default{p_end}
{synopt:{opt epanechnikov}} Epanechnikov kernel function{p_end}
{synopt:{opt epan2}} Alternative epanechnikov kernel function{p_end}
{synopt:{opt biweight}} Biweight kernel function{p_end}
{synopt:{opt cosine}} Cosine trace kernel function{p_end}
{synopt:{opt parzen }} Parzen kernel function{p_end}
{synopt:{opt rectangle}} Rectangle kernel function{p_end}
{synopt:{opt triangle}} Triangle kernel function{p_end}
{synoptline}
{syntab:Graphics}
{synopt:{opt nog:raph}}Prevents from showing the graph of the nonparametric fit{p_end}
{synopt:{opt ci}}Shows the confidence interval around the nonparametric fit{p_end}
{synopt:{opt title()}}Specifies the title of the graph for the nonparametric fit{p_end}
{synopt:{opt ytitle()}}Specifies the label of y-axis in the graph of the nonparametric fit{p_end}
{synopt:{opt xtitle()}}Specifies the label of x-axis in the graph of the nonparametric fit{p_end}
{synoptline}
{syntab:Standard errors}
{synopt:{opt robust}}Uses the sandwich variance formula to compute standard errors of the estimated parameters{p_end}  
{synopt:{opt cluster(varname)}}Computes clustered-corrected standard errors of the estimated parameters{p_end}
{synoptline}
{syntab: Specification test}
{synopt:{opt test(#)}}Computes Hardle and Mammen's (1993) specification test to assess if the nonparametric fit can be approximated by a parametric adjustment of order (#). With the cluster option specified, bootstrap sample of clusters are drawn{p_end}

{synopt:{opt nsim(#)}}Specifies the number of bootstrap replicates to be done to do inference on the test; default is 100{p_end}

{synopt:{opt weight_test()}}Allows to weight the distance between the nonparametric and parametric fits for the test; default is 1/n.{p_end}

{synopt:{opt level(#)}}Specifies the level of confidence for inference; default is {cmd:level(95)}{p_end}
{synoptline}
{syntab: {cmd:fweights} and {cmd:aweights} are allowed; see {helpb weight}}
{p2colreset}{...}

{title:Description}

{pstd}
semipar estimates the Robinson's (1988) double residual estimator and estimates the nonlinear relation between the variable set in {bf:nonpar} and the dependent variable. 
The nonparametric estimator used is a gaussian kernel weighted local polynomial fit. 

{pstd}
Besides, the {bf:test} option allows the user to assess whether a polynomial adjustment could be used to approximate the nonparametric fit. 



{title:Examples}

{phang2}{cmd:. use http://fmwww.bc.edu/ec-p/data/wooldridge/HPRICE3}{p_end}
{phang2}{cmd:. gen lprice =log(price)} {p_end}
{phang2}{cmd:. semipar lprice ldist larea lland rooms bath age, nonpar(linst) xtitle(linst) ci}{p_end}


Same as above, but testing for the appropriateness of a polynomial adjustment of order 2 for linst

{phang2}{cmd:. semipar lprice ldist larea lland rooms bath age, nonpar(linst) xtitle(linst) ci test(2)}{p_end}


{title:References}

Hardle W., E. Mammen (1993), Comparing nonparametric versus parametric regression fits, 
Annals of Statistics, 21, 1926-1947.

Robinson P.M. (1988), Root-N consistent semiparametric regression, Econometrica, 56, 931-954.
