
{smcl}
{* *! version 1.0 Feb 2017}{...}
{cmd:help xtcaec}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{pstd}{cmd:xtcaec} {hline 2} Estimate heterogeneous error correction models in cross-sectional dependent panel data
{p2colreset}{...}


{title:Syntax}

{pstd}{cmd:xtcaec} {depvar} {indepvars} {ifin} [{cmd:,} {cmd:lags(}{it:num}{cmd:)} {cmd:select} {cmd:calags(}{it:num}{cmd:)} {cmd:cavars({varlist})} {cmd:noca} {cmd:trend} {cmd:det({varlist})} 
{cmd:avlr} {cmd:mg} {cmd:lrplot(num)} {cmd:res({newvar})} ]

{pstd}{cmd:xtcaec} is for use with panel data.  You must xtset your data before using {cmd:xtcaec}.

{pstd}{cmd:xtcaec} requires {cmd:xtcd2} and {cmd:coefplot} to be installed.


{title:Description}

{pstd}{cmd:xtcaec} augments error correction models with cross-sectional averages of selected variables in order to eliminate the differential impacts of unobserved common factors. The routine 
estimates individual error correction models for each panel member i and, then, calculates mean-group estimates of the error correction and the long-run coefficients. In addition, it 
investigates whether the empirical model can remove cross-sectional dependence from the model residual.{p_end}


{pstd}{cmd:Background:}

{pstd} Variable non-stationarity and cross-sectional dependence are two characteristics of panel data that have received attention in the macro-empirical literature.
While variable non-stationarity requires cointegration analysis, a common-correlated effects estimation (CCE) approach can concern cross-sectional dependence
(see Pesaran, 2006; Eberhardt and Teal, 2011, provide a helpful introduction to this topic).
The {cmd:xtcaec} command integrates both approaches in one framework.
It builds on the methodologies presented in Chudik and Pesaran (2015); Eberhadt and Presbitero (2015); and Gengenbach, Urbain, and Westerlund (2015).{p_end}

{pstd}{cmd:Empirical Approach:}

{pstd} In a first step, {cmd:xtcaec} estimates the following error correction model for each panel member separately (here depicted for one x), where all variables in levels are assumed to 
be I(1) and where ca() are the cross-sectional averages of the particular variables:{p_end}

{p 6 10}D.y_it = b0_i + b1_i1*y_it-1 + b2_i1*x_it-1 + a2_i0*D.x_it

		     + a1_i1*D.y_it-1 + ... +  a1_ip*D.y_it-p + a2_i1*D.x_it-1 + ... + a2_ip*D.x_it-p

                     + b1_i2*ca(y_it-1) + b2_i2*ca(x_it-1)

		     + c1_i1*D.ca(y_it-1) * ... + c1_ip*D.ca(y_it-p) + c2_i1*D.ca(x_it-1) + ... + c2_ip*D.ca(x_it-p)

		     + e_it .

{pstd} The mean-group coefficients of above model are calculated as unweighted means of the group-specific estimates. Their standard errors are derived non-parametrically following Pesaran and Smith (1995).{p_end}

{pstd}In a second step, {cmd:xtcaec} ananlyses the following:{p_end}

{p 6} 1. Cointegration between the variables by investigating the EC-coefficients b1_i1. Specifically, it calculates{p_end}

{p 8}(a) the unweighted mean-group EC-coefficient as sum_i(b_1_i1) / N,{p_end}

{p 8}(b) the unweighted average t-statistic of the EC-coefficients across panel members,{p_end}

{p 8}(b) its corresponding p-value 
that relates to the critical values presented in Gengenbach, Urbain, and Westerlund (2015);{p_end}


{p 6} 2. The long-run coefficient of each x and its significance to be different from zero. Therefore, it computes{p_end}

{p 8}(a) the long-run average coefficient as -(sum_i(b2_i1)/sum_i(b1_i1)),{p_end}

{p 8}(b) its standard error, t-statistic, and p-value (by the Delta method using {cmd:nlcom});{p_end}


{p 6} 3. It applies the Pesaran (2015) test on cross-sectional dependence to{p_end}

{p 8}(a) the dependent and independent variables in order to demonstrate potential cross-sectional dependence in the untransformed variables,{p_end}

{p 8}(b) the model residuals in order to test whether the empirical model is powerful in resolving cross-sectional dependence.{p_end}


{title:Note}

{pstd}{cmd:xtcaec} calculates the cross-sectional averages over the whole sample that has been loaded into memory. Thus, cross-sectional averages are not affected by 
{ifin}. This allows to directly compare the results across subsets of groups. {cmd: xtcaec} requires a well prepared and adjusted data set.{p_end} 

{title:Options}

{p 4 4 2}{cmd: lags(# [#])} specifies the number of lagged first differences that are included in the error correction equation (default is 0). If one number is specified, it either determines the fixed number of lags or the upper lag limit
for the {cmd: select} option; a second (lower) number would determine the lower lag limit.{p_end}

{p 4 8 2}{cmd: select} enables automatic General-to-Specific lag selection that allows for heterogeneous lag orders: For each panel member i and each variable, the largest lag in first differences is dropped
 from the regressions if it is insignificant (at the 10%-level); then, the regressions and the selection procedure are repeated. This option ensures that the largest lags of the variables in first differences are significant.
(This option refers only to the (untransformed) variables in first differences, not to the differenced cross-sectional averages that are specified in the {cmd:calags(#)} option. 
Therefore, {cmd: select} should be combined with the {cmd:lags(#)} option.){p_end}

{p 4 4 2}{cmd: calags(#)} specifies the number of lags of cross-sectional averages in first differences that are included in the estimations (default is 0).{p_end}

{p 4 8 2}{cmd: cavars({varlist})} , if enabled, allows to specify the variables that are included as cross-sectional averages. Default option is to use all variables from {depvar} and {indepvars}.{p_end}

{p 4 8 2}{cmd: noca} avoids including cross-sectional averages in the error correction model.{p_end}

{p 4 8 2}{cmd: trend} includes a (unrestricted) group-specific linear trend in the error correction model.{p_end}

{p 4 8 2}{cmd: det({varlist})} defines additional deterministics that are included in the error correction model.{p_end}

{p 4 4 2}{cmd: avlr} additionally displays the average long-run coefficient of each x that is calculated as sum_i(-b2_i1/b1_i1) (cf. Eberhardt and Presbitero, 2015). Note that the average long-run coefficient is very sensitive to positive 
outliers in the group-specific EC-coefficients.{p_end}

{p 4 8 2}{cmd: mg} displays the mean-group error correction model.{p_end}

{p 4 8 2}{cmd: lrplot(#)} plots the group-specific long-run coefficients of the {cmd: #}th independent variable specified in {indepvars}. Look for outliers!{p_end}

{p 4 8 2}{cmd: res({newvar})} save residuals as a new variable.{p_end}


{title:Return values}

{p 0}Scalars{p_end}

{p 4 8}{cmd:e(N)} The number of observations.{p_end}

{p 4 8}{cmd:e(ng)} The number of groups.{p_end}

{p 4 8}{cmd:e(rmse)} The root mean square error.{p_end}

{p 0}Matrices{p_end}

{p 4 8}{cmd:e(b)} Matrix of mean-group coefficients.{p_end}

{p 4 8}{cmd:e(V)} Variance-covariance matrix of mean-group coefficients.{p_end}

{p 4 8}{cmd:e(ib)} Matrix of group-specific regression coefficients.{p_end}

{p 4 8}{cmd:e(se_ib)} Standard errors of group-specific coefficients.{p_end}

{p 4 8}{cmd:e(t_ib)} T-statistics of group-specific coefficients.{p_end}

{p 4 8}{cmd:e(ilr)} Matrix of group-specific long-run coefficients.{p_end}

{p 4 8}{cmd:e(se_ilr)} Standard errors of group-specific long-run coefficients.{p_end}

{p 4 8}{cmd:e(t_ilr)} T-statistics of group-specific long-run coefficients.{p_end}



{title:Example}

{p 0 4 2}Download the Westerlund (2007) data on GDP and health expenditures:{p_end}
{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/x/xtwestdata.dta": .use http://fmwww.bc.edu/repec/bocode/x/xtwestdata.dta}.{p_end}

{p 0 4 2}xtset your data:{p_end}
{p 4 8 2}{stata "xtset ctr year": .xtset ctr year}

{p 0 4 2}Following Eberhardt and Presbitero (2015), apply an error correction representation of the Chudik and Pesaran (2015) dynamic CCE estimator. Include a fixed number of lagged differences of cross-sectional averages
 according to [T^(1/3)]-1=2:{p_end}
{p 4 8 2}{stata "xtcaec loghex loggdp, calags(2)": .xtcaec loghex loggdp,  calags(2)}

{p 0 4 2}In order to account for potential short-run dynamics in the cointegrating relationship, allow for heterogeneous lag orders in the variable first differences by enabling lag selection:
Now, the t-bar statistic indicates cointegration at the 1%-level, 
the long-run coefficient is still significant, and the estimation residuals are cross-sectional
 independent:
 {p_end}
{p 4 8 2}{stata "xtcaec loghex loggdp, calags(2) lags(3) select": .xtcaec loghex loggdp,  calags(2) lags(3) select}

{p 0 2}Take a look at the group-specific coefficient matrix to grasp the results of the lag selection procedure:{p_end}
{p 4 8 2}{stata "mat list e(ib)": .mat list e(ib)}

{p 0 2}Plot the individual-specific long-run coefficients and display the average long-run coefficient:{p_end}
{p 4 8 2}{stata "xtcaec loghex loggdp, calags(2) lags(3) select avlr lrplot(1) ": .xtcaec loghex loggdp, calags(2) lags(3) select avlr lrplot(1) }




{title:References and related studies}


{p 0 4}Campos, Ericsson, and Hendry (2005) 'General-to-specific modeling: an overview and selected bibliography,' {it: FRB International Finance Discussion Paper No. 838}{p_end}

{p 0 4}Chudik and Pesaran (2015) 'Common correlated effects estimation of heterogeneous dynamic panel data models with weakly exogenous regressors,' {it:Journal of Econometrics}{p_end}

{p 0 4}Eberhardt (2012) 'Estimating panel time-series models with heterogeneous slopes,' {it:The Stata Journal 12}{p_end}

{p 0 4}Eberhardt and Teal (2011) 'Econometrics For Grumblers: A New Look At The Literature On Cross-Country Growth Empirics,' {it:Journal of Economic Surveys}{p_end}

{p 0 4}Eberhardt and Presbitero (2015) 'Public debt and growth: Heterogeneity and non-linearity,' {it:Journal of International Economics}{p_end}

{p 0 4}Gengenbach, Urbain, and Westerlund (2015) 'Error correction testing in panels with global stochastic trends,' {it:Journal of Applied Econometrics}{p_end}

{p 0 4}Jann (2013) 'Coefplot: Stata module to plot regression coefficients and other results.'{it: University of Bern Social Sciences Working Papers Nr. 1.}{p_end}

{p 0 4}Persyn and Westerlund (2008) 'Error correction based cointegration tests for panel data,' {it:The Stata Journal 8}{p_end}

{p 0 4}Pesaran (2006) 'Estimation and Inference in Large Heterogeneous Panels with a Multifactor Error Structure,' {it:Econometrica}{p_end}

{p 0 4}Pesaran and Smith (1995) 'Estimating long-run relationships from dynamic heterogeneous panels,' Journal of Econometrics{p_end}

{p 0 4}Pesaran (2015) 'Testing weak cross-sectional dependence in large panels,' Econometric Reviews{p_end}

{p 0 4}Ver Hoef (2012) 'Who invented the delta method?,' {it:The American Statistician 66}{p_end}

{p 0 4}Westerlund (2007) 'Testing for Error Correction in Panel Data,' {it:Oxford Bulletin of Economics and Statistics 69}{p_end}


{title:Acknowledgements}

{p 0 0 2}{cmd: xtcaec} implements empirical frameworks that are proposed in the existing literature. Any errors are of course my own.
The code of this routine is inspired by the {help xtmg} command written by Markus Eberhardt and the {help xtwest} command written by Damiaan Persyn and Joakim Westerlund. Many thanks to Kit Baum!{p_end}   


{title:Author}

Korbinian Nagel
Helmut Schmidt University Hamburg
{browse "mailto:xtcaec@korbinian-nagel.de":xtcaec@korbinian-nagel.de}
{browse "mailto:korbinian.nagel@hsu-hh.de":korbinian.nagel@hsu-hh.de}






