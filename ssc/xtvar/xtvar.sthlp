{smcl}
{* *! version 1.2.16  18may2011}{...}
{viewerdialog var "dialog var"}{...}
{vieweralsosee "[TS] var" "mansection TS var"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[TS] var postestimation" "help var postestimation"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[TS] dfactor" "help dfactor"}{...}
{vieweralsosee "[TS] mgarch" "help mgarch"}{...}
{vieweralsosee "[TS] sspace" "help sspace"}{...}
{vieweralsosee "[TS] tsset" "help tsset"}{...}
{vieweralsosee "[TS] var svar" "help svar"}{...}
{vieweralsosee "[TS] varbasic" "help varbasic"}{...}
{vieweralsosee "[TS] vec" "help vec"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[TS] var intro" "help var_intro"}{...}
{viewerjumpto "Syntax" "var##syntax"}{...}
{viewerjumpto "Description" "var##description"}{...}
{viewerjumpto "Options" "var##options"}{...}
{viewerjumpto "Examples" "var##examples"}{...}
{viewerjumpto "Saved results" "var##saved_results"}{...}

{p2colset 5 20 22 2}{...}
{p2col :{manlink R xtvar} {hline 2}}Panel vector autoregressive models (PVARs){p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:xtvar}
{depvarlist}
[if]
[{cmd:,}
{it:options}]

{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Model}
{synopt:{opt la:gs(#)}}use {it:#} lags in the PVAR; default is {cmd:lags(2)}{p_end}
{synopt:{opt po:oled}}estimate pooled PVAR{p_end}

{syntab:Impulse Response Function (IRF) and Forecast Error Variance Decomposition (FEVD)}
{synopt:{opt sti:rf}}calculate IRFs and FEVDs to one-unit shocks instead of IRFs and FEVDs to 
one-standard deviation shocks{p_end}
{synopt:{opt st:ep(#)}}set forecast horizon to {it:#}; default is {cmd:step(8)}{p_end}
{synopt:{cmdab:ssa:ving(}{it:{help filename}}[{cmd:, replace}]{cmd:)}}save 
IRFs, FEVDs and corresponding confidence intervals in the data set {it:filename}{p_end}

{synopt:{opt bsn}}obtain IRF confidence intervals and FEVD confidence intervals using a nonparametric 
temporal resampling bootstrap {cmd:default}{p_end}
{synopt:{opt dbsn}}obtain IRF confidence intervals and FEVD confidence intervals using a nonparametric 
double resampling bootstrap{p_end}
{synopt:{opt bsp}}obtain IRF confidence intervals and FEVD confidence intervals using a parametric
 bootstrap{p_end}
{synopt:{opt mc}}obtain IRF confidence intervals and FEVD confidence intervals using a Monte-Carlo 
simulation{p_end}
{synopt:{opt norm}}obtain standard normal confidence intervals{p_end}
{synopt:{opt r:eps(#)}}use {it:#} bootstrap or Monte-Carlo 
replications; default is {cmd:reps(200)}{p_end}

{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default 
is {cmd:level(95)}{p_end}
{synopt:{opt nodraw}}suppress graphs{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must {cmd:xtset} your data before using {cmd: xtvar}; see 
{helpb xtset:[XT] xtset}. {cmd:xtvar} requires a balanced panel dat aset.
{p_end} 



{marker description}{...}
{title:Description}

{ul:General}

{pstd}
{cmd:xtvar} fits a multivariate panel regression of each dependent variable on lags of itself and on 
lags of all the other dependent variables using the least squares dummy variable estimator (LSDV),
see e.g. Bun and Kiviet (2006). The LSDV estimator is consistent when the number of time observations 
in the data set tends to infinity, see e.g. Nickell (1981) and Hahn and Kuersteiner (2002). For an 
application see Cagala et al. (2014). Variables in the {depvarlist} have to follow the causal ordering.
A variable that is higher in the ordering causes contemporaneous changes in subsequent variables.
Variables that are lower in the ordering affect previous variables with a lag.


{ul:Impulse Response Function (IRF)}

{pstd}
{cmd: xtvar} estimates IRFs, reports IRFs in tables, and visualizes IRFs in graphs. See Lütkepohl
(2005) for the estimation of IRFs. You can choose between two types of IRFs:

{p2colset 8 65 44 2}{...}
{p2col:IRFs to one-standard deviation shocks} after {cmd:xtvar}{p_end}
{p2col:IRFs to one-unit shocks} after {cmd:xtvar}, {opt stirf}{p_end}
{p2colreset}{...}

{pstd}
Use the option {cmd: ssaving(}{it:filename}[{cmd:, replace}]{cmd:) } to save IRFs, FEVDs and 
corresponding confidence intervals in the data set {it:filename}.



{ul:Forecast error variance decomposition (FEVD)}

{pstd}
{cmd: xtvar} estimates FEVDs, reports FEVDs in tables, and visualizes FEVDs in graphs. See Lütkepohl 
(2005) for the estimation of FEVDs. You can choose between two types of FEVDs:

{p2colset 8 65 44 2}{...}
{p2col:FEVDs based on IRFs to one-standard deviation shocks}after {cmd:xtvar}{p_end}
{p2col:FEVDs based on IRFs to one-unit shocks}after {cmd:xtvar}, {opt stirf}{p_end}
{p2colreset}{...}

{pstd}
Use the option {cmd: ssaving(}{it:filename}[{cmd:, replace}]{cmd:) } to save IRFs, FEVDs and 
corresponding confidence intervals in the data set {it:filename}.



{ul:Confidence Intervals for IRFs and FEVDs}

{pstd}
{cmd: xtvar} computes confidence intervals for IRFs and FEVDs. {cmd: xtvar} computes confidence 
intervals optionally based on (I) a non-parametric residual bootstrap algorithm ({opt bsn} 
or {opt dbsn}), (II) a parametric residual bootstrap algorithm ({opt bsp}), or (III) a Monte-Carlo 
simulation algorithm {opt mc}.


{syntab:(I) Nonparametric residual bootstrap algorithm, see Lütkepohl (2005) Appendix D.3}

	(1) Estimate the parameters of the PVAR model under consideration. Compute 
	    the residuals û_it. Calculate IRFs and FEVDs. 
	
	(2) Compute centered residuals {it:û^k_i1 - ü^k_i,..., û^k_iT - ü^k_i} for equation 
	    {it:k} and group {it:}i, where {it:ü^k_i} is group {it:i}'s average residual over {it:t}. Obtain 
	    bootstrap residuals by randomly drawing with replacement from the centered 
	    residuals. {opt bsn} and {opt dbsn} refer to different resampling schemes. For a
 	    detailed description of the resampling schemes see Kapetanios (2008).
	
		{marker temporal}{...}

		{opt bsn} refers to a {it: temporal resampling scheme}. Define the residual matrix 
 		{it:U_k} as {it:U_k = (u^k_1 ,..., u^k_i ,..., u^k_N)} with {it:u^k_i = (u^k_i1 ,...,} 
		{it: u^k_iT)'}. For the {it:TxN} residual matrix {it:U_k} of equation {it:k}, temporal 
		resampling is the operation of constructing a {it:TxN} matrix {it:U_k*}, where the 
		rows of {it:U_k*} are obtained by resampling with replacement rows of 
		{it:U_k}. Use this resampling method if the rows of {it:U_k} are independent (no 
		temporal dependence). 

		{marker double}{...}

		{opt dbsn} refers to a {it:double resampling scheme}, which is a combination of  
	        {it:temporal resampling} and {it:cross-sectional resampling}. For a {it:TxN} residual 
		matrix {it:U_k} of equation {it:k}, double resampling is the operation of 
		constructing a {it:TxN} matrix {it:U_k**}. First, residuals are temporal resampled 
		and {it:U_k*} is obtained, see {opt bsn}. Second, residuals obtained by temporal 
		resampling {it:U_k*} are cross-sectional resampled by resampling with 
		replacement columns of {it:U_k*}. Use this resampling method if the rows of 
		{it:U_k} and the columns of {it:U_k*} are independent (no temporal and no 
		cross-sectional dependence).

	(3) Compute a bootstrap panel data set recursively, including all variables {it:k} as

		{it:y*^k_it = â0_i + â1 * y*^k_it-1 + ... + âp * y*^k_it-p + u*^k_it}.   

	    where {it:y*^k_it-1} to {it:y*^k_it-p} are true initial values.

	(4) Reestimate the parameters of the PVAR model using the bootstrap panel data 
	    set. Obtain a bootstrap version of IRFs and FEVDs. 
	
	(5) Repeat these steps {opt step(#)} times, where {opt step(#)} is a large number.



{syntab:(II) Parametric residual bootstrap algorithm}

	(1) Estimate the parameters of the PVAR model under consideration. Compute 
	    the residuals û_it. Calculate IRFs and FEVDs. 

	(2) Construct a {it:TxN} matrix {it:U_k*} by randomly dawing from a normal-distribution
	    {it:N ~ [0; Variance^k_u]}, where {it:Variance^k_u} is the mean-square-error (MSE) of 
            equation {it:k}.

	(3) Compute a bootstrap panel data set recursively, including all variables {it:k} as

		{it:y*^k_it = â0_i + â1 * y*^k_it-1 + ... + âp * y*^k_it-p + u*^k_it}.   

	    where {it:y*^k_it-1} to {it:y*^k_it-p} are true initial values.

	(4)	Reestimate the parameters of the PVAR model using the bootstrap panel data 
	    set. Obtain a bootstrap version of IRFs and FEVDs. 
	
	(5) Repeat these steps {opt step(#)} times, where {opt step(#)} is a large number.



{syntab:(III) Monte-Carlo algorithm, see Doan (2007) and Hamilton (1994)}
	
	(1) Estimate the parameters of the PVAR model under consideration. 
		
	(2) Draw a new innovation covariance matrix using the asymptotic distribution of the
	    innovation covariance matrix. Use the Cholesky factorization to obtain contemporary
	    coefficients.
	
	(3) Derive the new coefficient covariance matrix from the the drawn innovation 
	    covariance matrix.
	
	(4) Draw a vector of random components using the new coefficient covariance matrix.
	
	(5) Calculate two sets of coefficients. To obtain the first set, add the random vector to 
	    the coefficient vector. To obtain the second set, deduct the random component 
	    from the coefficient vector.
	
	(6) Calculate an impulse response function for each of the sets of coefficients.
		
	(7) Repeat these steps {opt step(#)} times, where {opt step(#)} is a large number.

{syntab:(IV) Computation of confidence intervals}

{pstd}
{cmd:xtvar} either computes standard percentile intervals (default) or standard normal confidence 
intervals ({opt norm}). See Lütkepohl (2005) Appendix D.3 for a detailed description. {helpb bstat} 
serves as basis for the computation of the confidence intervals.  



{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
	{opt lags(#)} specifies the lags to be included in the model. The default is {cmd:lags(2)}. 
	This option takes an integer for the maximum lag. For example, {cmd:lags(2)} would include 
	the first two lags in the model.

{phang}
	{opt pooled} specifies that {cmd: xtvar} estimates a multivariate least squares model with 
	common intercept for cross-sectional units. 

{dlgtab:Impulse Response Function}

{phang}
	{opt stirf} specifies that {cmd: xtvar} estimates IRFs to one-unit shocks and 	FEVDs based 
	on IRFs to one-unit shocks. If {opt stirf} is not specified {cmd: xtvar} estimates IRFs to 
	one-standard deviation shocks and FEVDs based on IRFs to one-standard deviation shocks. 

{phang}
	{opt step(#)} specifies the step (forecast) horizon. The default is eight periods.
   
{phang}
	{cmd:ssaving(}{it:filename}[{cmd:, replace}]{cmd:)} creates the data set {it:filename} and 
	saves IRFs, FEVDs, and corresponding confidence intervals in it. The new file {it:filename} 
	is a {opt .dta} data set that can be loaded using {helpb use}. If {it:filename} is specified
	without an extension, {opt .dta} is assumed.   

{phang}
	{opt bsn} specifies that {cmd: xtvar} estimates confidence intervals for IRFs and FEVDs 
	using the nonparametric residual bootstrap algorithm with the 
	{help xtvar##temporal:{bf:temporal resampling scheme}}. You have to specify one of the 
	following options: {opt bsn}, {opt dbsn}, {opt bsp}, or {opt bsn}. 
		
{phang}
	{opt dbsn} specifies that {cmd: xtvar} estimates confidence intervals for IRFs and FEVDs 
	using the nonparametric residual bootstrap algorithm with 
	{help xtvar##double:{bf:double resampling scheme}}. You have to specify one of the 
	following options: {opt bsn}, {opt dbsn}, {opt bsp}, or {opt bsn}. 
	
{phang}
    	{opt bsp} specifies that {cmd: xtvar} estimates confidence intervals for IRFs and FEVDs 
	using the parametric residual algorithm bootstrap. 
	You have to specify one of the following options: {opt bsn}, {opt dbsn}, {opt bsp}, or 
	{opt bsn}. 

{phang}
	{opt mc} specifies that {cmd: xtvar} estimates confidence intervals for IRFs and FEVDs 
	using the Monte-Carlo simulation algorithm.
	You have to specify one of the following options: {opt bsn}, {opt dbsn}, {opt bsp}, or 
	{opt bsn}. 

{phang}
	{opt norm} specifies that {cmd: xtvar} computes standard normal confidence intervals instead 
	of standard percentile intervals. 

{phang}
	{opt reps(#)} specifies the number of bootstrap replications to be performed. The default is 
	200. The number of replications must be larger than 2.

{dlgtab:Reporting}

{phang}
	{opt level(#)} specifies the confidence level for confidence intervals as a percentage. The 
	default is 95. 

{phang}
	{opt nodraw} suppresses graphs of IRFs and FEVDs. 
   
   
   
{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:xtvar} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(neqs)}}number of dependent variables{p_end}
{synopt:{cmd:e(N_g)}}number of groups{p_end}
{synopt:{cmd:e(g)}}number of observations per group{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(k_#)}}number of parameters in equation #{p_end}
{synopt:{cmd:e(df_m#)}}model degrees of freedom for equation #{p_end}
{synopt:{cmd:e(df_r#)}}residual degrees of freedom for equation #{p_end}
{synopt:{cmd:e(r2_#)}}R-squared for equation #{p_end}
{synopt:{cmd:e(tss_#)}}total sum of squares for equation #{p_end}
{synopt:{cmd:e(rss_#)}}residual sum of squares for equation #{p_end}
{synopt:{cmd:e(mss_#)}}model sum of squares for equation #{p_end}
{synopt:{cmd:e(rmse_#)}}root mean squared error for equation #{p_end}
{synopt:{cmd:e(F_#)}}F statistic for equation #{p_end}
{synopt:{cmd:e(F_panel_#)}}F-Test lagged variables for equation #{p_end}
{synopt:{cmd:e(p_panel_#)}}p-Value of F-Test lagged variables for equation #{p_end}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:xtvar}{p_end}
{synopt:{cmd:e(eqnames)}}names of equations{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}
{synopt:{cmd:e(ivar)}}name of panel variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(A)}}contemporaneous coefficient matrix{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(Sigma)}}Sigma hat matrix{p_end}




{marker references}{...}
{title:References}

{marker BK2006}{...}
{phang}
Bun, M. J. G. and J. F. Kiviet. 2006. 
{it: The effects of dynamic feedbacks on LS and MM estimator}
{it: accuracy in panel data models.} 
Journal of Econometrics. 
132(2).
409-444.

{marker C2014}{...}
{phang}
Cagala, T., U. Glogowsky, V. Grimm & J. Rincke, 2014.
{it:  Cooperation and Trustworthiness in Repeated Interaction.} 

{marker D2007}{...}
{phang}
Doan, T. A. 2007.
{it: RATS Version 7 User's Guide.}
Evanston, IL: Estima.

{marker H1994}{...}
{phang}
Hamilton, J. D. 1994.
{it: Time Series Analysis.}
Princeton, NJ: Princeton University Press.

{marker HK2002}{...}
{phang}
Hahn, J., and G. Kuersteiner. 2002. 
{it: Asymptotically Unbiased Inference for a Dynamic Panel} 
{it: Model with Fixed Effects when Both n and T Are Large.}
Econometrica.
70(4).
1639-1657.

{marker K2008}{...}
{phang}
Kapetanios, G. 2008
{it: A bootstrap procedure for panel data sets with} 
{it: many cross-sectional units.}
Econometrics Journal.
11(2).
377-395.

{marker L2005}{...}
{phang}
Lütkepohl, H. 2005.
{browse "http://www.stata.com/bookstore/multiple-time-series-analysis/":{it: New Introduction to Multiple Time Series Analysis}.}
Berlin: Springer.

{marker N1981}{...}
{phang}
Nickell, S. J. 1981. 
{it: Biases in Dynamic Models with Fixed Effects.}
Econometrica. 
49(6).
1417-26.
{p_end}



{title:Authors}

{p 4}Tobias Cagala and Ulrich Glogowsky{p_end}
{p 4}Department of Economics{p_end}
{p 4}Friedrich-Alexander University of Erlangen-Nuremberg{p_end}
{p 4}tobias.cagala@fau.de / ulrich.glogowsky@fau.de{p_end}



{title:Citation}

{p 4}If you use the program in a paper, please cite the tool as:

{marker C2014}{...}
{phang}
Cagala, T. and Glogowsky, U. 2014.
{it: Panel Vector Autoregressions for Stata (xtvar).}




