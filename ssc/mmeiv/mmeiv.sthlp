{smcl}

{title:Title}

{p 4 8}{cmd:mmeiv} {hline 2} Multiple Marginal Effects IV Estimation

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:mmeiv} {depvar} [{it:{help varlist:varlist_W2}}]
{cmd:(}{it:{help varlist:varlist_X}} {cmd:=}
        {it:{help varname:varname_T}} { {it:{help varlist:varlist_W1}} }{cmd:)} {ifin}
[{it:{help ivregress##weight:weight}}]
[{cmd:,} {it:options}]


{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:mmeiv} implements a multiple marginal effects estimation using instrumental variables, as proposed in {browse "http://www.dropbox.com/s/hf94cqp61e56l88/CaetanoEscanciano.pdf?dl=0":Caetano and Escanciano}.

{p 4 4} Following the notation in the paper, {cmd:mmeiv} estimates multiple marginal effects of {it:varlist_X} on {it:depvar} using the instrument {it:varname_T} and covariates {it:varlist_W1}. {it:varlist_X} and {it:varlist_W1} are endogenous variables. {it:varlist_W1} is the same as {bf:W} as discussed in Caetano and Escanciano. Note that {it:varlist_W1} must have at least as many elements as {it:varlist_X} minus one. {it:varlist_W2} are additional exogenous controls.

{marker options}{...}
{title:Options}

{p 4 8}{opt xk:nots(# [# #...])} specifies the # of knots that are used in creating linear splines for each variable in {it:varlist_X}. Knots are placed at percentiles of the data. Specifying multiple knots for an element of {it:varlist_X} is akin to assuming that this element may have different marginal effects for different values of the variable. By default each element in {it:varlist_X} has only one marginal effect (linear).

{p 4 8}{opt wk:nots(# [# #...])} specifies the # of knots that are used in creating linear splines for each variable in {it:varlist_W1}. Knots are placed at percentiles of the data. Specifying multiple knots for an element of {it:varlist_W1} is akin to transforming that element into multiple controls, each of which controls for pieces of the support of that variable separately. By default each element in {it:varlist_W1} is used only as itself.

{p 4 8}{opt vce(vcetype)} {it:vcetype} may be {opt un:adjusted},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap},
   {opt jack:knife}, or {opt hac} {help ivregress##kernel:{it:kernel}}. Default is {cmd: unadjusted}.

{p 4 8}{opt predict} stores marginal effect estimate and standard errors of the marginal effect of each variable in {it:varlist_X}.

{p 4 8}{opt plot} plots the estimated marginal effect of each variable in {it:varlist_X} on {depvar}.

{p 4 8}{opt graphop:tions(string)} passes through{help twoway_options: twoway options} to the plotted graphs.


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mmeiv} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(mss)}}model sum of squares{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(rss)}}residual sum of squares{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(r2)}}R-squared{p_end}
{synopt:{cmd:e(r2_a)}}adjusted R-squared{p_end}
{synopt:{cmd:e(F)}}F statistic{p_end}
{synopt:{cmd:e(rmse)}}root mean squared error{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(wlagopt)}}lags used in HAC weight matrix (if Newey-West
            algorithm used){p_end}
{synopt:{cmd:e(vcelagopt)}}lags used in HAC VCE matrix (if Newey-West
            algorithm used){p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:mmeiv}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(instd)}}instrumented variable{p_end}
{synopt:{cmd:e(insts)}}instruments{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(hac_kernel)}}HAC kernel{p_end}
{synopt:{cmd:e(hac_lag)}}HAC lag{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(exogr)}}exogenous regressors{p_end}
{synopt:{cmd:e(properties)}}{mmeiv:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{marker references}{...}
{title:References}

{pstd}
Caetano, C. and J. C. Escanciano (2019): {browse "http://www.dropbox.com/s/hf94cqp61e56l88/CaetanoEscanciano.pdf?dl=0":"Identifying Multiple Marginal Effects with a Single Instrument,"} working paper.


{marker authors}{...}
{title:Authors}

{p 4 4} Carolina Caetano {break}
University of Georgia {break}
Athens, GA {break}
{ browse "mailto:carol.caetano@uga.edu" : carol.caetano@uga.edu }

{p 4 4} Juan Carlos Escanciano {break}
University of Indiana {break}
Bloomington, IN {break}
{browse "mailto:jescanci@indiana.edu" : ailto:jescanci@indiana.edu }
 
{p 4 4}  Alon Bergman {break}
The Wharton School {break}
Philadelphia, PA {break}
{browse "mailto:alonberg@wharton.upenn.edu" : alonberg@wharton.upenn.edu }

