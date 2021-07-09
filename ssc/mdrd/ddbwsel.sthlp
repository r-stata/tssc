{smcl}
{* *! version 1.0 21Sep2016}{...}
{vieweralsosee "rdrobust (if installed)" "help rdrobust"}{...}
{vieweralsosee "mdrd" "help mdrd"}{...}
{vieweralsosee "mdist" "help mdist"}{...}
{vieweralsosee "rdcorr" "help rdcorr"}{...}
{viewerjumpto "Syntax" "ddbwsel##syntax"}{...}
{viewerjumpto "Description" "ddbwsel##description"}{...}
{viewerjumpto "Options" "ddbwsel##options"}{...}
{viewerjumpto "Examples" "ddbwsel##examples"}{...}
{viewerjumpto "Stored results" "ddbwsel##saved_results"}{...}
{viewerjumpto "References" "ddbwsel##references"}{...}
{viewerjumpto "Author" "ddbwsel##author"}{...}

{title:Title}

{p 4 8}{cmd:ddbwsel} {hline 2} Bandwidth Selection Procedures for Regression-Discontinuity and Difference-in-Discontinuity Estimators.


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:ddbwsel } {it:depvar} {it:indepvar} {ifin}
[{it:{help ddbwsel##weight:weight}}]
[{cmd:,} 
{cmd:c(}{it:numlist}{cmd:)}
{cmdab:d:eriv(}{it:#}{cmd:)}
{cmdab:t:ime(}{it:timevar}{cmd:)} 
{cmd:nocut}
{cmd:p(}{it:#}{cmd:)} 
{cmd:q(}{it:#}{cmd:)}
{cmdab:het:er(}{it:hetervars}{cmd:)} 
{cmd:at(}{it:numlist}{cmd:)}
{cmdab:ker:nel(}{it:kernelfn}{cmd:)}
{cmd:rho(}{it:rho}{cmd:)}
{cmdab:bws:elect(}{it:bwmethod}{cmd:)}
{cmdab:scaler:egul(}{it:#}{cmd:)}
{cmd:vce(}{it:vcemethod}{cmd:)}
{cmdab:m:atches(}{it:#}{cmd:)}
{cmd:all}
{cmdab:nowarn:ing} 
]{p_end}
    {hline}
{p 4 6 2}{it:depvar}, {it:indepvar} and {it:hetervars} may contain time-series operators; see {help tsvarlist}.{p_end}
{marker weight}{...}
{p 4 6 2}{cmd:aweight}s are allowed; see {help weight}.{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:ddbwsel} implements bandwidth selectors for Regression-Discontinuity (RD), Regression-Kink
(RK), Difference-in-Discontinuity (DiD), Difference-in-Kink (DiK), and Difference-in-Slope (DiS) estimators, as
well as for difference and discontitnuity in higher-order derivatives. It computes the MSE-optimal bandwidth applying
the procedures proposed by {help ddbwsel##references:Calonico, Cattaneo and Titiunik (2014)} and 
{help ddbwsel##references:Imbens and Kalyanaraman (2012)}.

{p 4 8}For multidimensional designs, {it:indepvar} must be the distance between running (or forcing) variables
and the cutoffs, previously calculated by {cmd:{help mdist}}. The command output refers to this distance, and not the
original running variables.{p_end}

{marker options}{...}
{title:Options}

{p 4 8}{cmd:c(#)} specifies the cutoff in {it:indepvar}. Default is {cmd:c(0)}. For multidimensional 
designs, {it:indepvar} must be the distance between running (or forcing) variables
and the cutoffs, previously calculated by {cmd:{help mdist}}, and {cmd:c(#)} refers to a point along this
distance, preferably {cmd:c(0)}.

{p 4 8}{cmdab:d:eriv(}{it:#}{cmd:)} specifies the order of the derivative of the regression functions.
Default is {cmd:deriv(0)} (RD, or DiD if {cmd:time(.)} is also specified). Setting {cmd:deriv(1)} results in a RK design,
DiK if {cmd:time(.)} is also specified, or DiS if {cmd:time(.)} and {cmd:nocut} are also specified.

{p 4 8}{cmdab:t:ime(}{it:timevar}{cmd:)} specifies the time variable to implement DiD, DiK, and 
DiS designs. If specified, it must be a dummy variable.

{p 4 8}{cmd:nocut} if specified, bandwidths are for difference in functions over
time instead of discontinuity. For example, with {cmd:deriv(1)}, {cmd:ddbwsel} assumes DiS
instead of DiK. {cmd:c(}{it:#}{cmd:)} becomes a reference point on the
curve instead of a cutoff. This option may be used only if {cmd:time(.)} is specified.

{p 4 8}{cmd:p(}{it:#}{cmd:)} specifies the order of the local-polynomial used to construct the point estimator.
Default is {cmd:p(1)} (local linear regression).

{p 4 8}{cmd:q(}{it:#}{cmd:)} specifies the order of the local-polynomial used to construct the bias-correction.
Default is {cmd:q(2)} (local quadratic regression).

{p 4 8}{cmdab:het:er(}{it:hetervars}{cmd:)} specifies the variables that linearly interact with the design to evaluate the 
point estimate at specific values of {it:hetervars}. Option {cmd:at(.)} specifies these values. A discrete {it:hetervar} will
be treated as continuous. If not specified, badnwidths are for the average effect at the cutoff.

{p 4 8}{cmd:at(}{it:numlist}{cmd:)} specifies the values of {it:hetervars} where the point estimate is evaluated. It is used only if
{cmd:heter(.)} is specified. If specified, number of points in {cmd:at(.)} must be equal to the number of {it:hetervars}. Otherwise, default
is {cmd: at(}0 ... 0{cmd:)}. 

{p 4 8}{cmdab:ker:nel(}{it:kernelfn}{cmd:)} specifies the kernel function used to construct the local-polynomial estimator(s). Options are: {opt tri:angular}, {opt epa:nechnikov}, and {opt uni:form}. Default is {opt triangular}.

{p 4 8}{cmd:rho(}{it:#}{cmd:)} if specified, sets the pilot bandwidth {it:b} equal to {it:h}/{it:rho}, where {it:h} is computed using the method and options chosen below.

{p 4 8}{cmdab:bws:elect(}{it:bwmethod}{cmd:)} specifies the bandwidth selection procedure to be used. By default it computes both {it:h} and {it:b}, unless {cmd:rho(}{it:rho}{cmd:)} is
specified, in which case it only computes {it:h} and sets {it:b}={it:h}/{it:rho}.
Options are:{p_end}
{p 8 13}{opt CCT}{space 1}for bandwidth selector proposed by Calonico, Cattaneo and Titiunik (2014) ({it:default} option).{p_end}
{p 8 13}{opt IK}{space 2}for bandwidth selector proposed by Imbens and Kalyanaraman (2012).

{p 4 8}{cmdab:scaler:egul(}{it:#}{cmd:)} specifies scaling factor for the regularization terms of bandwidth selectors. {cmd:scaleregul(#)} must be greater than or equal to zero. Setting {cmd:scaleregul(0)} removes the regularization term. Default is {cmd:scaleregul(1)}.

{p 4 8}{cmd:vce(}{it:vcemethod}{cmd:)} specifies the procedure used to compute the variance-covariance matrix estimator. Options are:{p_end}
{p 8 15}{opt nn}{space 4}for nearest-neighbor matches residuals using {cmd:matches(}{it:#}{cmd:)} matches ({it:default} option).{p_end}
{p 8 15}{opt resid}{space 1}for estimated plug-in residuals using {cmd:h(}{it:h}{cmd:)} bandwidth.

{p 4 8}{cmdab:m:atches(}{it:#}{cmd:)} specifies the number of matches in the nearest-neighbor variance-covariance estimator. This option is used only when nearest-neighbor matches residuals are employed, {cmd:vce(nn)}. Default is {cmd:matches(6)}.

{p 4 8}{cmd:all} if specified, {cmd:ddbwsel} reports all MSE-based procedures:{p_end}
{p 8 12}{opt CCT} for bandwidth selector proposed by Calonico, Cattaneo and Titiunik (2014a).{p_end}
{p 8 12}{opt IK} for bandwidth selector proposed by Imbens and Kalyanaraman (2012).{p_end}

{p 4 8}{cmdab:nowarn:ing} if specified minor warning messages are omitted.{p_end}

		
{marker examples}{...}
{title:Examples}
   
{p 4 8}CCT bandwidth selection procedure for RD design{p_end}
{p 8 8}{cmd:. ddbwsel y x}{p_end}

{p 4 8}IK bandwidth selection procedure for RD design{p_end}
{p 8 8}{cmd:. ddbwsel y x, bwselect(IK)}{p_end}

{p 4 8}All bandwidth selection procedures for RD design{p_end}
{p 8 8}{cmd:. ddbwsel y x, all}{p_end}

{p 4 8}CCT bandwidth selection procedure for DiK design{p_end}
{p 8 8}{cmd:. generate time = year>=2005}{p_end}
{p 8 8}{cmd:. ddbwsel y x, deriv(1) time(time)}{p_end}

{p 4 8}IK bandwidth selection procedure for multidimensional RD design{p_end}
{p 8 8}{cmd:. mdist x1 x2, generate(d) c(20 150)}{p_end}
{p 8 8}{cmd:. ddbwsel y d, c(0)}{p_end}


{marker saved_results}{...}
{title:Stored results}

{p 4 8}{cmd:ddbwsel} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations used{p_end}
{synopt:{cmd:e(c)}}cutoff value{p_end}
{synopt:{cmd:e(p)}}order of the polynomial of the regression function{p_end}
{synopt:{cmd:e(q)}}order of the polynomial for the bias adjustment{p_end}
{synopt:{cmd:e(deriv)}}order of the estimated derivative function{p_end}
{synopt:{cmd:e(h_CCT)}}CCT main bandwidth for the regression function{p_end}
{synopt:{cmd:e(b_CCT)}}CCT pilot bandwidth for bias adjustment{p_end}
{synopt:{cmd:e(rho_CCT)}}ratio between CCT main bandwidth and CCT pilot bandwidth{p_end}
{synopt:{cmd:e(h_IK)}}IK main bandwidth for regression function{p_end}
{synopt:{cmd:e(b_IK)}}IK pilot bandwidth for bias adjustment{p_end}
{synopt:{cmd:e(rho_IK)}}ratio between IK main bandwidth and IK pilot bandwidth{p_end}

{p 6 8}If specified:{p_end}
{synopt:{cmd:e(at)}}values of {it:hetervars} where the point estimate is evaluated{p_end}
{synopt:{cmd:e(matches)}}number of matches in the nearest-neighbor variance estimator{p_end}

{p 6 8}For cross-sectional designs:{p_end}
{synopt:{cmd:e(N_l)}}number of observations to the left of cutoff{p_end}
{synopt:{cmd:e(N_r)}}number of observations to the right of cutoff{p_end}
{synopt:{cmd:e(range_l)}}range of distance to cutoff from the left{p_end}
{synopt:{cmd:e(range_r)}}range of distance to cutoff from the right{p_end}

{p 6 8}For difference-in-function designs (with no discontinuity):{p_end}
{synopt:{cmd:e(N_0)}}number of observations at time 0{p_end}
{synopt:{cmd:e(N_1)}}number of observations at time 1{p_end}
{synopt:{cmd:e(range_0)}}range of distance around cutoff at time 0{p_end}
{synopt:{cmd:e(range_1)}}range of distance around cutoff at time 1{p_end}

{p 6 8}For difference-in-discontinuity designs:{p_end}
{synopt:{cmd:e(N_l0)}}number of observations to the left of cutoff at time 0{p_end}
{synopt:{cmd:e(N_r0)}}number of observations to the right of cutoff at time 0{p_end}
{synopt:{cmd:e(N_l1)}}number of observations to the left of cutoff at time 1{p_end}
{synopt:{cmd:e(N_r1)}}number of observations to the right of cutoff at time 1{p_end}
{synopt:{cmd:e(range_l0)}}range of distance to cutoff from the left at time 0{p_end}
{synopt:{cmd:e(range_r0)}}range of distance to cutoff from the right at time 0{p_end}
{synopt:{cmd:e(range_l1)}}range of distance to cutoff from the left at time 1{p_end}
{synopt:{cmd:e(range_r1)}}range of distance to cutoff from the right at time 1{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(runningvar)}}running/forcing variable{p_end}
{synopt:{cmd:e(kernel)}}kernel function used to construct local-polynomial estimators{p_end}
{synopt:{cmd:e(bwselect)}}bandwidth selection procedure applied{p_end}
{synopt:{cmd:e(vce)}}procedure used to compute the variance-covariance matrix estimator{p_end}

{p 6 8}If specified:{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(heter)}}variables that linearly interact with the design{p_end}
{synopt:{cmd:e(time)}}time variable{p_end}

{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:Acknowledgements}

{p 4 8}{cmd:mdrd} package and {cmd:ddbwsel} were built upon {net sj 14-4 st0366:rdrobust} package. This is meant to be a supplement, not a replacement.


{marker references}{...}
{title:References}

{p 4 8}Calonico, S., Cattaneo, M. D., and R. Titiunik. 2014. Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs. {it:Econometrica} 82(6): 2295–2326.

{p 4 8}Imbens, G., and T. Lemieux. 2008. Regression Discontinuity Designs: A Guide to Practice. {it:Journal of Econometrics} 142(2): 615-635.

{p 4 8}Imbens, G. W., and K. Kalyanaraman. 2012. Optimal Bandwidth Choice for the Regression Discontinuity Estimator. {it:Review of Economic Studies} 79(3): 933-959.

{p 4 8}Matta, R., R. P. Ribas, B. Sampaio, and G. Sampaio. 2016. The effect of age at school entry on college admission and earnings: a regression-discontinuity approach. {it:IZA Journal of Labor Economics} 5(9):1-25.
{browse "http://izajole.springeropen.com/articles/10.1186/s40172-016-0049-5"}.

{marker author}{...}
{title:Author}

{p 4 8}Rafael P. Ribas,{p_end}
{p 4 8}University of Amsterdam, Finance Group, Netherlands.{p_end}
{p 4 8}{browse "mailto:rpribas.rs@gmail.com":rpribas.rs@gmail.com}.

