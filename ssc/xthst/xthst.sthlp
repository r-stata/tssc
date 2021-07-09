{smcl}
{hline}
help {hi:xthst}{right: v. 1.2 - 27. February 2020}
{hline}
{title:Title}

{p 4 4}{cmd:xthst} - testing for slope homogeneity in large panels. 

{title:Syntax}

{p 4 13}{cmd:xthst} {depvar} {indepvars} [if] [,{cmd:partial({help varlist:varlist_p})} 
{cmdab:noconst:ant} 
{cmd:ar} 
{cmd:hac} 
{cmd:bw({it:{help integer}})}
{cmdab:white:ning}
{cmd:kernel(}{it:qs|bartlett|truncated}{cmd:)}
{cmdab:cr:osssectional(}{help varlist:varlist_cr}
{cmd: [,cr_lags(}{help numlist}{cmd:)])}
{cmdab:noout:put}
]{p_end}

{p 4 4}{it:depvar} and {it:indepvars} may contain time-series operators; see {help tsvarlist}.{break}
Data must be {cmd:xtset} before using {cmd:xthst}; see {help xtset}.
{p_end}

{p 4 4}{it:depvar} is the dependent variable of the model to be tested,
{it:indepvar} the independent variables.{break}
{it:varlist_p} are the variables to be partialled out, 
{it:varlist_cr} are variables added as cross-sectional averages.{p_end}

{title:Contents}

{p 4}{help xthst##options:Options}{p_end}
{p 4}{help xthst##description:Description}{p_end}
{p 4}{help xthst##econmetricmodel:Econometric Model}{p_end}
{p 4}{help xthst##saved_vales:Saved Values}{p_end}
{p 4}{help xthst##examples:Examples}{p_end}
{p 4}{help xthst##references:References}{p_end}
{p 4}{help xthst##vhist:Version History}{p_end}
{p 4}{help xthst##about:About}{p_end}

{marker description}{title:Description}

{p 4 4} {cmd:xthst} performs a test of slope homogeneity in panels with 
a large number observations of the cross-sectional (N) and time (T) dimension. 
The null hypothesis of the test is of homogenous slopes. 
This implies all slope coefficients are identical across cross-sectional units.{p_end}

{p 4 4} The test is a standardized version of Swamey's test for slope homogeneity presented by Peasaran and Yamagata (2008). 
The cross-section dimension (N) and the time dimension (T), are required to be large.
Slope heterogeneity yields consistent results if the true model has homogenous slopes. 
However the estimates are inefficient. 
If the true model consists of heterogeneous slopes, imposing slope homogeneity 
yields inconsistent and biased results.
{p_end}

{p 4 4}The test implicitly estimates two models and compares them. 
The restricted model is the weighted fixed effects estimator, which imposes
slope homogeneity. The unrestricted model, the model under the alternative,
is a cross-sectional unit specific OLS regression model.{break}
The test is based the difference of the two models. 
Large values of the test statistic imply a disagreement between fixed effects and unit specific
estimates and therefore the null of slope homogeneity can be rejected.{p_end}

{p 4 4} {cmd:xthst} can be used for both balanced and unbalanced panels. 
The program supports models with strictly exogenous regressors and an AR(p) model.
For the latter, an additional assumption is required: (N,T) jointly converge to
infinity, meaning that N/T needs to be constant.
The test allows for non-normally distributed errors, such as serial correlated errors.
{cmd: xthst} uses the HAC consistent test statistic derived by Blomquist and Westerlund (2013).
In addition, Bersvendsen and Ditzen (2020) show using simulation 
results that by adding cross sectional averages to the model,
the test works for situations with cross-section dependence in the error term and variables. {p_end}

{marker econmetricmodel}{title:Econometric Model}

{p 4 4} Based on Pesaran and Yamagata (2008), consider the following model with k = k1 + k2 regressors{p_end}

{p 8 8} y_it = alpha_i + x1_it * beta1_i + x2_it * beta2_i + e_it {p_end}

{p 4 4} or {p_end}

{p 8 8} y_it = z1_it * theta_i + x2_it * beta2_i + e_it {p_end}

{p 4 4} where z1_it = (1, x1_it), heta_i = (alpha_i, beta1_i}, 
x1_it contains k1 regressors and x2_it contains k2.
Suppose the coefficient of interest are those in {it:beta_i},
then the hypothesis of slope homogeneity is:{p_end} 

{p 8 12} H0: beta2_i = beta2, for all i = 1,...,N{p_end}

{p 4 4} The derived test statistic by Pesaran and Yamagata (2008) is:

{p 8 12} Delta = sqrt(N) ((1/N * S2_tilde - k_2)/sqrt(2*k_2)) {p_end}

{p 4 4} where, under the H0, the statistic is asymptotically Delta ~ N(0,1) distributed.
{p_end} 

{p 4 4} S2_tilde is defined as in equation 13 in Peasaran and Yamagata (2008):{p_end}

{p 8 12} S2_tidle = sum(i=1,N) (b2_i - b2_wfe)'((X2_i' * M1_i * X2_i)/sigma2_i)(b2_i - b2_wfe), {p_end}

{p 4 4} where b2_i is the estimate of beta2_i obtained from individual least squares regression.
The regressors which are not of interest, including the constant, 
are {ul:assumed to be heterogeneous} and are 
collected in {it:Z1_i} and partialled using the projection matrix 
M1_i = I_T - Z1_i(Z1_i'Z1_i)Z1_i'.
The sigma2_i is the standard error of regression of the fixed effects regression,
b2_wfe is the latter FE coefficient estimates weighted by sigma2_i.
{p_end}

{p 4 4} If one are interested in testing slope homogeneity for both beta1_i and beta2_i, 
the same test statistic is computed but only the constant is partialled out.
Therefore, k would replace k1 and k2 in the computations and X_i = (X1_i, X2_i) would replace X2_i.
The same result holds for an AR(p) model, see Pesaran and Yamagata (2008). {p_end}

{p 4 4} A HAC consistent test statistic is derived by Blomquist and Westerlund (2013).
In this case S2_tilde is replaced by S_hac: {p_end}

{p 8 12} S_hac = sum(i=1,N) T*(b_i - b)' (Q_i,T * inv(V_i,T) * Q_i,T) (b_i - b) {p_end}

{p 4 4} where b_i being the OLS estimator for cross-section unit i and, {p_end}

{p 8 12} b = inv(sum(i=1,N) T*Q_i,T * inv(V_i,T) * Q_i,T )*(sum(i=1,N) Q_i,T * inv(V_i,T) * X_i * M_t * y_i). {p_end}

{p 4 4} In the equation above, Q_i,T = (X_i'*M_t*X_i) / Ti. 
M_t is the projection matrix which partials out the constant or variables assumed to have heterogeneous slopes.
Heteroskedasticity and serial correlation are dealt with by the following HAC estimator:{p_end}
 
{p 8 12} V_i,T = L_i(0) + sum(j=1,bw)(kr(j/bw)[L_i(j) + L_i(j)']), {p_end}

{p 4 4} where, bw is the selected  bandwidth and kr the chosen kernel. 
Available kernels are {it:Bartlett} (default), {it:Quadratic Spectral} (QS) and {it:Truncated}. 
L_i(j) is the correlation between the residual of a fixed effects regression 
multiplied with the demeaned explanatory regressors in t and in t-j.
If not specified, the bandwith is automatically selected following  
Andrews and Monahan (1992) and Newey West (1994).
{p_end}

{marker options}{title:Options}

{p 4 4}{cmdab:noconst:ant} suppresses the individual heterogeneous constant, alpha_i. {p_end}

{p 4 4}{cmd:partial(}{help varlist:varlist_p}{cmd:)} requests exogenous regressors in {it:varlist_p} to be partialled out.
The constant is automatically partialled out, if included in the model.
Regressors in {it:varlist} will be included in z_it, explained in {help xthst##econmetricmodel:Econometric Model}.
These regressors are assumed to have heterogeneous slopes.{p_end}

{p 4 4}{cmd:ar} allows for an AR(p) model. The degree of freedom of S2_tilde is
adjusted. 
May not be combined with {cmd:hac}.{p_end}

{p 4 4}{cmd:hac} implements the HAC consistent test by Blomquist and Westerlund (2013).
If {cmd:kernel} and {cmd:bw} are not specified, kernel is set to {cmd:bartlett}. 
May not be combined with {cmd:ar}.{p_end}

{p 4 4}{cmd:kernel(}{help kernel}{cmd:)} specifies the kernel function used in calculating the HAC consistent test statistic.
Available kernels: {cmd:bartlett}, {cmd:qs} (quadratic spectral) and {cmd:truncated}.
Is only required in combination with {cmd:hac}.{p_end}

{p 4 4}{cmd:bw(#)} bandwidth equal to # for the HAC consistent test statistic, 
where # is an integer greater than zero.
Is only required in combination with {cmd:hac}. 
If not set then the automatic bandwidth selection from 
Andrews and Monahan (1992) and Newey West (1994) is used.{p_end}

{p 4 4}{cmdab:white:ning} performs prewhitening to reduce small-sample bias in HAC estimation,
see Andrews and Monahan (1992). 
Is only required in combination with {cmd:hac}.{p_end}

{p 4 4}{cmdab:cr:osssectional(}{help varlist:varlist_cr}{cmd: [,cr_lags(}{help numlist}{cmd:)])} 
defines the variables which are added as cross-sectional averages to the model to approximate cross-sectional dependence.
Variables in {it:varlist_cr} are partialled out.
{cmd:cr_lags}({help numlist}) sets the number of lags of the cross-sectional averages. 
If not defined, but {cmd:crosssectional()} contains a varlist, then only contemporaneous cross sectional averages are added but no lags. 
{cmd:cr_lags(0)} is the equivalent.
The number of lags can be different for different variables, where the order is the same as defined in {cmd:cr()}.
For example if {cmd:cr(y x)} and only contemporaneous cross-sectional averages of y but 2 lags of x are added,
then {cmd:cr_lags(0 2)}  {p_end}

{p 4 4}{cmdab:noout:put} omits output.  {p_end}

{marker saved_vales}{title:Saved Values}

{cmd:xthst} stores the following in {cmd:r()}:

{col 4} Scalars
{col 8}{cmd: r(bw)}{col 27} bandwidth

{col 4} Macros
{col 8}{cmd: r(crosssectional)}{col 27} variables of which cross-section averages are added
{col 8}{cmd: r(partial)}{col 27} variables partialled out
{col 8}{cmd: r(kernel)}{col 27} used kernel

{col 4} Matrices
{col 8}{cmd: r(delta)}{col 27} delta and adjusted delta
{col 8}{cmd: r(delta_p)}{col 27} p-values of above


{marker examples}{title:Examples}

{p 4 4}An example dataset taken from the Penn World Tables 8 is available 
for download {browse "https://drive.google.com/open?id=1mL4s0X_pUjvTLTccmLbGNtfVBQ63Mon2":here}.
The dataset contains yearly observations from 1960 until 2007 and is already xtset. 
The dataset contains real GDP (log_rgdpo), human capital (log_hc), 
physical captial (log_ck) and population growth 
added with break even investments of 5% (log_ngd).{p_end}

{p 4 4}We want to test whether slope coefficients in a simple Solow-type growth 
model are homo- or heterogeneous. 
If our model excludes the lag of the dependent variable (for exemplified purpose), 
the command line is:{p_end}

{p 8}{stata xthst d.log_rgdp log_hc log_ck log_ngd}.{p_end}

{p 4 4}The p-values for the non-adjusted and adjusted Delta test imply that the 
null of slope homogeneity can be rejected.{break} 
In the next step, the first lag
of log GDP is added and an ARDL(1,0) model estimated:{p_end}

{p 8}{stata xthst d.log_rgdp L.d.log_rgdp log_hc log_ck log_ngd}.{p_end}

{p 4 4}In case the assumption is that all variables except the lag of GDP are heterogeneous,
the {cmd:partial(}{help varlist:varlist_partial}{cmd:)} option can be used. 
In this case all variables defined {it:varlist_partial} are partialled out
and assumed to be heterogeneous:

{p 8}{stata xthst d.log_rgdp L.d.log_rgdp log_hc log_ck log_ngd, partial(log_hc log_ck log_ngd)}.{p_end}

{p 4 4}The test confirms that the coefficient of the lag of GDP is heterogeneous, 
however the test statistic decreased in comparison to the model above.{p_end}

{p 4 4}In a dynamic macro dataset it is likely that errors exhibit serial correlation.
To account for autocorrelation in the residual, the option {cmd:hac} can
be employed to use the HAC robust standard errors following 
Blomquist, Westerlund (2013):{p_end}

{p 8}{stata xthst d.log_rgdp L.d.log_rgdp log_hc log_ck log_ngd, hac}.{p_end}

{p 4 4}Instead of the bartlett kernel, we can use the Quadratic-Spehere kernel with,
say, a bandwidth of 6 by using the options {cmd:kernel()} and {cmd:bw()}:{p_end}

{p 8}{stata xthst d.log_rgdp L.d.log_rgdp log_hc log_ck log_ngd, hac kernel(qs)}.{p_end}

{p 4 4}In large panels cross-sectional dependence is likely, see 
{help xtdcce2}, {help xtcd2} and {help xtcse2}. 
{cmd:xthst} can remove cross-sectional dependence by adding cross-sectional averages.
The cross-sectional averages are partialled out.{break}
The option {cmdab:cr:osssectional(}{help varlist:varlist_csa}{cmd:[, lags(}{help numlist}{cmd:)])}
defines the variables to be added as cross-sectional averags and the number of lags.
For example we add the cross-sectional averages of the base of all variables and 
use 1 lag for log GDP, 2 lags for physical capital and 3 for the other variables,
the command line is:{p_end}

{p 8}{stata xthst d.log_rgdp L.d.log_rgdp log_hc log_ck log_ngd, cr(d.log_rgdpo log_hc log_ck log_ngd, cr_lags(1 3 2 3))}.{p_end}

{p 4 4}As a final example, the AR(p) adjusted test from Pesaran, Yamagata (2008)
can be employed using the option {cmd:ar}:{p_end}

{p 8}{stata xthst d.log_rgdp L(1/3).d.log_rgdp, ar}.{p_end}

{marker references}{title:References}


{p 4 8} Andrews, D. W. K. and J. C. Monahan. 1992.
An Improved Heteroskedasticity and Autocorrelation Consistent Covariance Matrix Estimator.
Econometrica 60(4), p. 953 - 966.{p_end}

{p 4 8}Bersvendsen, T. and J. Ditzen. 2020.
xthst: Testing for slope homogeneity in Stata. 
CEERP Working Paper Series No. 011.
{browse "https://ceerp.hw.ac.uk/RePEc/hwc/wpaper/011.pdf":Download}.{p_end}

{p 4 8} Blomquist, J. and J. Westerlund. 2013. Testing slope homogeneity in large panels with serial correlation.
Economics Letters 121, pp 374 - 378.{p_end}

{p 4 8} Newey, W. K. and K. D. West. 1994. Automatic Lag Selection in Covariance Matrix Estimation.
Review of Economic Studies 61(4), pp. 631-653.{p_end}

{p 4 8} Pesaran, M. H. and T. Yamagata. 2008. Testing slope homogeneity in large panels.
Journal of Econometrics 142, pp 50 - 93.{p_end}


{marker vhist}{title:Version History}
{p 4 8}This version: 1.2 - 27 February 2020{p_end}
{p 8 10} - Corrected output when cross-sectional averages used.{p_end}
{p 8 10} - Corrections and additions to help file.{p_end}
{p 4 8}Version 1.1 - 17. January 2020{p_end}
{p 8 10} - Improved Speed.{p_end}
{p 8 10} - Bug fix in small sample adjustment for S and S_HAC.{p_end}
{p 8 10} - Bug fix if hac used, first auto correlation was miscalculated.{p_end}


{marker about}{title:About}

{p 4}Tore Bersvendsen (University of Agder){p_end}
{p 4}Email: {browse "mailto:tore.bersvendsen@uia.no":tore.bersvendsen@uia.no}{p_end}

{p 4}Jan Ditzen (Heriot-Watt University){p_end}
{p 4}Email: {browse "mailto:j.ditzen@hw.ac.uk":j.ditzen@hw.ac.uk}{p_end}
{p 4}Web: {browse "www.jan.ditzen.net":www.jan.ditzen.net}{p_end}

{p 4}We are grateful to Jochen Jungeilges 
for providing many helpful comments and discussions. 
Johan Blomquist and Joakim Westerlund kindly provided their Gauss Code for
cross-checking.
All remaining errors are our own.{p_end}

