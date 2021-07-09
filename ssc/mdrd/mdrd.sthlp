{smcl}
{* *! version 1.0 10Sep2016}{...}
{vieweralsosee "rdrobust (if installed)" "help rdrobust"}{...}
{vieweralsosee "ddbwsel" "help ddbwsel"}{...}
{vieweralsosee "mdist" "help mdist"}{...}
{vieweralsosee "rdcorr" "help rdcorr"}{...}
{viewerjumpto "Syntax" "mdrd##syntax"}{...}
{viewerjumpto "Description" "mdrd##description"}{...}
{viewerjumpto "Options" "mdrd##options"}{...}
{viewerjumpto "Examples" "mdrd##examples"}{...}
{viewerjumpto "Stored results" "mdrd##saved_results"}{...}
{viewerjumpto "References" "mdrd##references"}{...}
{viewerjumpto "Author" "mdrd##author"}{...}

{title:Title}

{p 4 8}{cmd:mdrd} {hline 2} Multi and Unidimensional Regression-Discontinuity
and Difference-in-Discontinuity.


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:mdrd} {it:depvar} {it:indepvars} {ifin} 
[{it:{help mdrd##weight:weight}}]
[{cmd:,} 
{cmd:c(}{it:numlist}{cmd:)}
{cmdab:d:eriv(}{it:#}{cmd:)}
{cmdab:t:ime(}{it:timevar}{cmd:)} 
{cmd:nocut}
{cmd:itt(}{it:ittvar}{cmd:)} 
{cmdab:dist:ance(}{it:distfn}{cmd:)} 
{cmdab:arg:ument(}{it:#}{cmd:)} 
{cmd:unit(}{it:distunit}{cmd:)} 
{cmd:p(}{it:#}{cmd:)} 
{cmd:q(}{it:#}{cmd:)}
{cmdab:f:uzzy(}{it:fuzzyvar}{cmd:)}
{cmdab:het:er(}{it:hetervars}{cmd:)} 
{cmd:at(}{it:numlist}{cmd:)}
{cmdab:hc:oef}
{cmd:control(}{it:controlvars}{cmd:)} 
{cmdab:ker:nel(}{it:kernelfn}{cmd:)}
{cmd:h(}{it:h}{cmd:)} 
{cmd:b(}{it:b}{cmd:)}
{cmd:rho(}{it:rho}{cmd:)}
{cmdab:bws:elect(}{it:bwmethod}{cmd:)}
{cmdab:scaleb:w(}{it:#}{cmd:)}
{cmdab:scalep:ar(}{it:#}{cmd:)}
{cmdab:scaler:egul(}{it:#}{cmd:)}
{cmd:vce(}{it:vcemethod}{cmd:)}
{cmdab:m:atches(}{it:#}{cmd:)}
{cmdab:l:evel(}{it:#}{cmd:)}
{cmd:all}
{cmdab:nowarn:ing} 
]{p_end}
    {hline}
{p 4 6 2}{it:depvar}, {it:indepvars}, {it:fuzzyvar}, {it:hetervars} and {it:controlvars} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}{it:controlvar} may contain factor variables; see {help fvvarlist}.{p_end}
{marker weight}{...}
{p 4 6 2}{cmd:aweight}s are allowed; see {help weight}.{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:mdrd} implements point estimators for Regression-Discontinuity (RD),
Regression-Kink (RK), Difference-in-Discontinuity (DiD), Difference-in-Kink (DiK),
and Difference-in-Slope (DiS), as well as difference and discontitnuity in higher-order
derivatives, with robust confidence intervals. The running (or forcing) variable
({it:indepvars}) may have either one or many dimensions.

{p 4 8}Polynomial bias-correction and robust confindence intervals are computed
as proposed in {help mdrd##references:Calonico, Cattaneo and Titiunik (2014)}.

{marker options}{...}
{title:Options}

{p 4 8}{cmd:c(}{it:numlist}{cmd:)} specifies the cutoff(s) in {it:indepvars}. Default is {cmd:c(0)}. The number of cutoffs must be either
one or equal to the number of {it:indepvars}. If only one cutoff is specified, all {it:indepvars} have the same cutoff value.

{p 4 8}{cmdab:d:eriv(}{it:#}{cmd:)} specifies the order of the derivative of the regression functions to be estimated.
Default is {cmd:deriv(0)} (RD, or DiD if {cmd:time(.)} is also specified). Setting {cmd:deriv(1)} results in estimation of a RK design,
DiK if {cmd:time(.)} is also specified, or DiS if {cmd:time(.)} and {cmd:nocut} are also specified.

{p 4 8}{cmdab:t:ime(}{it:timevar}{cmd:)} specifies the time variable to implement DiD, DiK, and 
DiS estimations. If specified, it must be a dummy variable.

{p 4 8}{cmd:nocut} if specified, {cmd:mdrd} estimates difference in functions over
time instead of discontinuity. For example, with {cmd:deriv(1)}, {cmd:mdrd} estimates DiS
instead of DiK. {cmd:c(}{it:#}{cmd:)} becomes a reference point on the
curve instead of a cutoff. This option may be used only if {cmd:time(.)} is specified.

{p 4 8}{cmd:itt(}{it:ittvar}{cmd:)} specifies the intended-to-treat variable. If
observation is intended for treatment, then {it:ittvar}=1. Otherwise, {it:ittvar}=0. This option is used only if the number of 
{it:indepvars} is greater than one. The default is {it:ittvar}=1 if all {it:indepvars} are greater than or equal 
to the respective cutoff at {cmd:c(}{it:numlist}{cmd:)}, and {it:ittvar}=0 otherwise. However, {cmd:itt(.)} allows
for different rules for {it:indepvars} and {cmd:c(.)}.

{p 4 8}{cmdab:dist:ance(}{it:distfn}{cmd:)} specifies the distance function if the number of 
{it:indepvars} is greater than one. Options are:{p_end}
{p 8 37}{cmdab:maha:lanobis}{space 17}for Mahalanobis distance ({it:default} option).{p_end}
{p 8 37}{cmdab:eucl:idean} or {opt L2}{space 13}for Euclidean (L2) distance.{p_end}
{p 8 37}{cmdab:abs:olute} or {cmdab:manhat:tan} or {opt L1}{space 1}for Manhattan (L1) distance.{p_end}
{p 8 37}{cmdab:mink:owski}{space 19}for Minkowski distance of order #, specified by {cmd:argument(.)}.{p_end}
{p 8 37}{cmdab:l:atlong} or {cmdab:l:onglat}{space 10}for Latitude/Longitude distance, whose unit is specified by {cmd: unit(.)}. {it:indepvars} should be preferably named {ul:la}titude and {ul:lo}ngitude.

{p 4 8}{cmdab:arg:ument(}{it:#}{cmd:)} specifies the order of Minkowski distance if {cmd:distance(minkowski)} is specified. Default is
{cmd:argument(2)}.

{p 4 8}{cmd:unit(}{it:distunit}{cmd:)} specifies the distance unit if {cmd:distance(latlong)} is specified. Options are:{p_end}
{p 8 27}{cmdab:kil:ometers} or {opt km}{space 3}for kilometers ({it:default} option).{p_end}
{p 8 27}{cmdab:met:ers} or {opt m}{space 8}for meters.{p_end}
{p 8 27}{cmdab:mil:es} or {opt mi}{space 8}for miles.{p_end}
{p 8 27}{opt foot} or {opt feet} or {opt ft}{space 1}for feet.{p_end}
{p 8 27}{cmdab:yard:s} or {opt yd} {space 7}for yards.

{p 4 8}{cmd:p(}{it:#}{cmd:)} specifies the order of the local-polynomial used to construct the point estimator.
Default is {cmd:p(1)} (local linear regression).

{p 4 8}{cmd:q(}{it:#}{cmd:)} specifies the order of the local-polynomial used to construct the bias-correction.
Default is {cmd:q(2)} (local quadratic regression).

{p 4 8}{cmdab:f:uzzy(}{it:fuzzyvar}{cmd:)} specifies the treatment status variable to implement Fuzzy (two-stage) estimation. If
not specified, {cmd: mdrd} implements a Sharp design for RD, RK, DiD, DiK, or DiS. {ul:Note}: For fuzzy 
designs, bandwidths are estimated using a reduced-form (sharp) specification.

{p 4 8}{cmdab:het:er(}{it:hetervars}{cmd:)} specifies the variables that linearly interact with the design to evaluate the 
point estimate at specific values of {it:hetervars}. Option {cmd:at(.)} specifies these values. A discrete {it:hetervar} will
be treated as continuous. If not specified, {cmd: mdrd} estimates the average effect at the cutoff.

{p 4 8}{cmd:at(}{it:numlist}{cmd:)} specifies the value of each {it:hetervar} where the point estimate is evaluated. It is used only if
{cmd:heter(.)} is specified. If specified, number of points in {cmd:at(.)} must be equal to the number of {it:hetervars}. Otherwise, default
is {cmd: at(}0 ... 0{cmd:)}. 

{p 4 8}{cmdab:hc:oef} if specified along with {cmd:heter(.)}, the marginal effect of {it:hetervars} on the point estimate is reported and
stored in {cmd:e()}.

{p 4 8}{cmd:control(}{it:controlvars}{cmd:)} specifies independent (control) variables besides the running
variables, {it:indepvars}. If not specified, {cmd: mdrd} estimates the unconditional relationship between {it:depvar} (and
{it:fuzzyvar} if specified) and {it:indepvars}. {ul:Note}: The selection of optimal bandwidths ignores {it:controlvars}.

{p 4 8}{cmdab:ker:nel(}{it:kernelfn}{cmd:)} specifies the kernel function used to construct the local-polynomial estimator(s). Options are: {opt tri:angular}, {opt epa:nechnikov}, and {opt uni:form}. Default is {opt triangular}.

{p 4 8}{cmd:h(}{it:h}{cmd:)} specifies the main bandwidth ({it:h}) used to construct the point estimator. Value {it:h} must be
greater than 0. If the number of {it:indepvars} is greater than one, then {it:h} refers to the distance to the cutoff, defined by
{cmd:distance(.)}. If not specified, bandwidth {it:h} is computed by the companion command {help ddbwsel:ddbwsel}.

{p 4 8}{cmd:b(}{it:b}{cmd:)} specifies the pilot bandwidth ({it:b}) used to construct the bias-correction estimator. Value {it:b} must be
greater than 0. If the number of {it:indepvars} is greater than one, then {it:b} refers to the distance to the cutoff, defined by
{cmd:distance(.)}. If not specified, bandwidth {it:b} is computed by the companion command {help ddbwsel:ddbwsel}.

{p 4 8}{cmd:rho(}{it:rho}{cmd:)} specifies the value of {it:rho}, so that the pilot bandwidth {it:b} equals {it:b}={it:h}/{it:rho}. {it:rho} must lie between 0 and 1. Default
is {cmd:rho(1)} if {cmd:h(.)} is specified but {cmd:b(.)} is not. 

{p 4 8}{cmdab:bws:elect(}{it:bwmethod}{cmd:)} specifies the bandwidth selection procedure to be used. By default it computes both {it:h} and {it:b}, unless {cmd:rho(}{it:rho}{cmd:)} is
specified, in which case it only computes {it:h} and sets {it:b}={it:h}/{it:rho}.
Options are:{p_end}
{p 8 13}{opt CCT}{space 1}for bandwidth selector proposed by Calonico, Cattaneo and Titiunik (2014) ({it:default} option).{p_end}
{p 8 13}{opt IK}{space 2}for bandwidth selector proposed by Imbens and Kalyanaraman (2012).

{p 4 8}{cmdab:scaleb:w(}{it:#}{cmd:)} specifies scaling factor for the optimal bandwidth. This option is useful to verify
the sensitivity of estimates to the bandwidth choice. It is used only if {cmd:h(.)} is not specified. {cmd:scalebw(}{it:#}{cmd:)} must be greater than zero. Default is {cmd:scalebw(1)}.

{p 4 8}{cmdab:scalep:ar(}{it:#}{cmd:)} specifies scaling factor for the parameter of interest. This option is useful when the population parameter of interest involves a known multiplicative factor (e.g., sharp kink RD). Default is {cmd:scalepar(1)}.

{p 4 8}{cmdab:scaler:egul(}{it:#}{cmd:)} specifies scaling factor for the regularization terms of bandwidth selectors. {cmd:scaleregul(#)} must be greater than or equal to zero. Setting {cmd:scaleregul(0)} removes the regularization term. See companion command {help ddbwsel:ddbwsel} for more details. Default is {cmd:scaleregul(1)}.

{p 4 8}{cmd:vce(}{it:vcemethod}{cmd:)} specifies the procedure used to compute the variance-covariance matrix estimator. Options are:{p_end}
{p 8 15}{opt nn}{space 4}for nearest-neighbor matches residuals using {cmd:matches(}{it:#}{cmd:)} matches ({it:default} option).{p_end}
{p 8 15}{opt resid}{space 1}for estimated plug-in residuals using {cmd:h(}{it:h}{cmd:)} bandwidth.

{p 4 8}{cmdab:m:atches(}{it:#}{cmd:)} specifies the number of matches in the nearest-neighbor variance-covariance estimator. This option is used only when nearest-neighbor matches residuals are employed, {cmd:vce(nn)}. Default is {cmd:matches(6)}.

{p 4 8}{cmdab:l:evel(}{it:#}{cmd:)} specifies confidence level for confidence intervals. Default is {cmd:level(95)}.

{p 4 8}{cmd:all} if specified, {cmd:mdrd} reports three different estimates:{p_end}
{p 8 15}(i){space 3}conventional estimates with conventional variance estimator.{p_end}
{p 8 15}(ii){space 2}bias-corrected estimates with conventional variance estimator.{p_end}
{p 8 15}(iii){space 1}bias-corrected estimates with robust variance estimator.{p_end}

{p 4 8}{cmdab:nowarn:ing} if specified minor warning messages are omitted.{p_end}

		
{marker examples}{...}
{title:Examples}

{p 4 8}Sharp RD design{p_end}
{p 8 8}{cmd:. mdrd y x}{p_end}

{p 4 8}Sharp DiD design{p_end}
{p 8 8}{cmd:. mdrd y x, time(t)}{p_end}

{p 4 8}Fuzzy RD design{p_end}
{p 8 8}{cmd:. mdrd y x, fuzzy(z)}{p_end}

{p 4 8}Sharp DiK design{p_end}
{p 8 8}{cmd:. mdrd y x, deriv(1) time(t)}{p_end}

{p 4 8}Sharp DiS design{p_end}
{p 8 8}{cmd:. mdrd y x, deriv(1) time(t) nocut}{p_end}

{p 4 8}Fuzzy RK design{p_end}
{p 8 8}{cmd:. mdrd y x, deriv(1) fuzzy(z)}{p_end}

{p 4 8}Fuzzy DiS design with control variables {cmd:w1}, {cmd:w2}, and {cmd:w3}{p_end}
{p 8 8}{cmd:. mdrd y x, time(t) nocut fuzzy(z) control(w1 w2 w3)}{p_end}

{p 4 8}Sharp multidimensional RD design, {cmd:x1}'s cutoff at 2 and {cmd:x2}'s cutoff at 5{p_end}
{p 8 8}{cmd:. mdrd y x1 x2, c(2 5)}{p_end}

{p 4 8}Sharp multidimensional RK design, {cmd:x1}'s cutoff at 2 and {cmd:x2}'s cutoff at 5{p_end}
{p 8 8}{cmd:. generate itt = x1<=2 & x2>5}{p_end}
{p 8 8}{cmd:. mdrd y x1 x2, c(2 5) itt(itt) deriv(1) fuzzy(z)}{p_end}

{p 4 8}Fuzzy multidimensional RD design, with spatial data{p_end}
{p 8 8}{cmd:. mdrd y lon lat, c(4.861895 52.358943) deriv(1) fuzzy(z) distance(latlong) unit(miles)}{p_end}

{p 4 8}Sharp RD design with heterogeneous effects{p_end}
{p 8 8}{cmd:. centile het, c(5 50 95)}{p_end}
{p 8 8}{cmd:. local h05 = r(c_1)}{p_end}
{p 8 8}{cmd:. local h50 = r(c_2)}{p_end}
{p 8 8}{cmd:. local h95 = r(c_3)}{p_end}
{p 8 8}{cmd:. mdrd y x, heter(het) at(`h05')}{p_end}
{p 8 8}{cmd:. mdrd y x, heter(het) at(`h50')}{p_end}
{p 8 8}{cmd:. mdrd y x, heter(het) at(`h95')}{p_end}

{p 4 8}Verify sensitivity to bandwidth selected by CCT method{p_end}
{p 8 8}{cmd:. mdrd y x, bwselect(CCT)}{p_end}
{p 8 8}{cmd:. mdrd y x, bwselect(CCT) scalebw(0.5)}{p_end}
{p 8 8}{cmd:. mdrd y x, bwselect(CCT) scalebw(1.5)}{p_end}


{marker saved_results}{...}
{title:Stored results}

{p 4 8}{cmd:mdrd} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations used{p_end}
{synopt:{cmd:e(p)}}order of the polynomial of the regression function{p_end}
{synopt:{cmd:e(q)}}order of the polynomial for the bias adjustment{p_end}
{synopt:{cmd:e(deriv)}}order of the estimated derivative function{p_end}
{synopt:{cmd:e(bw_h)}}main bandwidth of the regression function{p_end}
{synopt:{cmd:e(bw_b)}}pilot bandwidth used for bias adjustment{p_end}
{synopt:{cmd:e(rho)}}ratio between main bandwidth and pilot bandwidth{p_end}
{synopt:{cmd:e(tau_cl)}}conventional local-polynomial estimate{p_end}
{synopt:{cmd:e(tau_bc)}}bias-corrected local-polynomial estimate{p_end}
{synopt:{cmd:e(se_cl)}}conventional std. error of the local-polynomial estimate{p_end}
{synopt:{cmd:e(se_rb)}}robust std. error of the local-polynomial estimate{p_end}
{synopt:{cmd:e(pv_cl)}}p-value of the conventional local-polynomial estimate{p_end}
{synopt:{cmd:e(pv_bc)}}p-value of the bias-corrected local-polynomial estimate{p_end}
{synopt:{cmd:e(pv_rb)}}p-value of the robust local-polynomial estimate{p_end}
{synopt:{cmd:e(level)}}confidence level{p_end}

{p 6 8}If specified:{p_end}
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

{p 6 8}For fuzzy designs:{p_end}
{synopt:{cmd:e(tau_Z_cl)}}conventional first-stage estimate{p_end}
{synopt:{cmd:e(tau_Z_bc)}}bias-corrected first-stage estimate{p_end}
{synopt:{cmd:e(se_Z_cl)}}conventional std. error of the first-stage estimate{p_end}
{synopt:{cmd:e(se_Z_rb)}}robust std. error of the first-stage estimate{p_end}
{synopt:{cmd:e(pv_Z_cl)}}p-value of the conventional first-stage estimate{p_end}
{synopt:{cmd:e(pv_Z_bc)}}p-values of the bias-corrected first-stage estimate{p_end}
{synopt:{cmd:e(pv_Z_rb)}}p-values of the robust first-stage estimate{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(runningvar)}}running/forcing variables{p_end}
{synopt:{cmd:e(kernel)}}kernel function used to construct local-polynomial estimators{p_end}
{synopt:{cmd:e(bwselect)}}bandwidth selection procedure applied{p_end}
{synopt:{cmd:e(vce)}}procedure used to compute the variance-covariance matrix estimator{p_end}

{p 6 8}If specified:{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(fuzzy)}}fuzzy treatment variable{p_end}
{synopt:{cmd:e(control)}}control variables{p_end}
{synopt:{cmd:e(heter)}}variables that linearly interact with the design{p_end}
{synopt:{cmd:e(itt)}}intented-to-treat variable{p_end}
{synopt:{cmd:e(time)}}time variable{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of point estimates{p_end}
{synopt:{cmd:e(V)}}variance (diagonal) matrix of the estimators{p_end}
{synopt:{cmd:e(c)}}cutoff values{p_end}
{synopt:{cmd:e(yhat)}}table of predicted outcomes per group{p_end}
{synopt:{cmd:e(ci)}}table of confidence intervals{p_end}

{p 6 8}If specified:{p_end}
{synopt:{cmd:e(at)}}values of {it:hetervars} where the point estimate is evaluated{p_end}
{synopt:{cmd:e(hcoef)}}vector of marginal effects of {it:hetervars} on the point estimate{p_end}
{synopt:{cmd:e(Vhcoef)}}variance matrix of marginal effects of {it:hetervars} on the point estimate{p_end}

{p 6 8}For fuzzy designs:{p_end}
{synopt:{cmd:e(zhat)}}table of predicted treatment per group in the first stage{p_end}
{synopt:{cmd:e(z_ci)}}table of confidence intervals in the first stage{p_end}

{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:Acknowledgements}

{p 4 8}{cmd:mdrd} package was built upon {net sj 14-4 st0366:rdrobust} package. This is meant to be a supplement, not a replacement.

		
{marker references}{...}
{title:References}

{p 4 8}Calonico, S., Cattaneo, M. D., and R. Titiunik. 2014. Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs. {it:Econometrica} 82(6): 2295-2326.

{p 4 8}Giambona, E., R. P. Ribas, 2017. The External Cost of Prostitution. Working Paper, University of
Amsterdam, {browse "https://sites.google.com/site/r4ribas/research/prostitution.pdf":link}.

{p 4 8}Imbens, G., and T. Lemieux. 2008. Regression Discontinuity Designs: A Guide to Practice. {it:Journal of Econometrics} 142(2): 615-635.

{p 4 8}Imbens, G. W., and K. Kalyanaraman. 2012. Optimal Bandwidth Choice for the Regression Discontinuity Estimator. {it:Review of Economic Studies} 79(3): 933-959.

{p 4 8}Matta, R., R. P. Ribas, B. Sampaio, and G. Sampaio. 2016. The effect of age at school entry on college admission and earnings: a regression-discontinuity approach. {it:IZA Journal of Labor Economics} 5(9):1-25,
{browse "http://izajole.springeropen.com/articles/10.1186/s40172-016-0049-5"}.

{marker author}{...}
{title:Author}

{p 4 8}Rafael P. Ribas,{p_end}
{p 4 8}University of Amsterdam, Finance Group, Netherlands.{p_end}
{p 4 8}{browse "mailto:rpribas.rs@gmail.com":rpribas.rs@gmail.com}.

