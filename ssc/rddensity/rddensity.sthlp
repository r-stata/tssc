{smcl}
{* *! version 1.0 14-Jul-2019}{...}
{viewerjumpto "Syntax" "rdrobust##syntax"}{...}
{viewerjumpto "Description" "rdrobust##description"}{...}
{viewerjumpto "Options" "rdrobust##options"}{...}
{viewerjumpto "Examples" "rdrobust##examples"}{...}
{viewerjumpto "Saved results" "rdrobust##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:rddensity} {hline 2} Manipulation Testing using Local-Polynomial Density Estimation.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rddensity} {it:var} {ifin} 
[{cmd:,} 
{cmd:c(}{it:#}{cmd:)} 
{cmd:p(}{it:#}{cmd:)} 
{cmd:q(}{it:#}{cmd:)}
{cmd:fitselect(}{it:fitmethod}{cmd:)}
{cmd:kernel(}{it:kernelfn}{cmd:)}
{cmd:h(}{it:# #}{cmd:)} 
{cmd:bwselect(}{it:bwmethod}{cmd:)}
{cmd:vce(}{it:vcemethod}{cmd:)}
{cmd:all}
{cmd:plot}  
{cmd:plot_range(}{it:# #}{cmd:)} 
{cmd:plot_n(}{it:# #}{cmd:)} 
{cmd:plot_grid(}{it:gridmethod}{cmd:)}
{cmd:genvars(}{it:varname}{cmd:)}
{cmd:level(}{it:#}{cmd:)}
{cmd:graph_options(}{it:...}{cmd:)}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rddensity} implements manipulation testing procedures using the local polynomial density estimators proposed in
{browse "https://sites.google.com/site/rdpackages/rddensity/Cattaneo-Jansson-Ma_2019_JASA.pdf":Cattaneo, Jansson and Ma (2019)}.
For a review on manipulation testing see McCrary (2008).{p_end}

{p 4 8}A detailed introduction to this Stata command is given in {browse "https://sites.google.com/site/rdpackages/rddensity/Cattaneo-Jansson-Ma_2018_Stata.pdf":Cattaneo, Jansson and Ma (2018)}.{p_end}
{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://sites.google.com/site/rdpackages/rddensity":here}.{p_end}

{p 4 8}Related Stata and R packages useful for inference in regression discontinuity (RD) designs are described in the following website:{p_end}

{p 8 8}{browse "https://sites.google.com/site/rdpackages/":https://sites.google.com/site/rdpackages/}{p_end}



{marker options}{...}
{title:Options}

{p 4 8}{cmd:c(}{it:#}{cmd:)} specifies the threshold or cutoff value in the support of in {it:indepvar}, which determes the two samples (e.g., control and treatment units in RD settings).
Default is {cmd:c(0)}.{p_end}

{p 4 8}{cmd:p(}{it:#}{cmd:)} specifies the order of the local-polynomial used to construct the density point estimators.
Default is {cmd:p(2)} (local quadratic approximation).{p_end}

{p 4 8}{cmd:q(}{it:#}{cmd:)} specifies the order of the local-polynomial used to construct the bias-corrected density point estimators.
Default is {cmd:q(p({it:#})+1)} (local cubic approximation for default {cmd:p(2)}).{p_end}

{p 4 8}{cmd:fitselect(}{it:fitmethod}{cmd:)} specifies whether restrictions should be imposed. Options are:{p_end}
{p 8 12}{opt unrestricted} for density estimation without any restrictions (two-sample, unrestricted inference). This is the default option.{p_end}
{p 8 12}{opt restricted} for density estimation assuming equal c.d.f. and higher-order derivatives.{p_end}

{p 4 8}{cmd:kernel(}{it:kernelfn}{cmd:)} specifies the kernel function used to construct the local-polynomial estimator(s). Options are: {opt triangular}, {opt epanechnikov}, and {opt uniform}.
Default is {opt triangular}.{p_end}

{p 4 8}{cmd:h(}{it:#} {it:#}{cmd:)} specifies the bandwidth ({it:h}) used to construct the density estimators on the two sides of the cutoff. If not specified, the bandwidth {it:h} is computed by the companion command
{help rdbwdensity:rdbwdensity}. If two bandwidths are specified, the first bandwidth is used for the data below the cutoff and the second bandwidth is used for the data above the cutoff.{p_end}

{p 4 8}{cmd:bwselect(}{it:bwmethod}{cmd:)} specifies the bandwidth selection procedure to be used. Options are:{p_end}
{p 8 12}{opt each} bandwidth selection based on MSE of each density separately (two distinct bandwidths, {it:hl} and {it:hr}).{p_end}
{p 8 12}{opt diff} bandwidth selection based on MSE of difference of densities (one common bandwidth, {it:hl}={it:hr}).{p_end}
{p 8 12}{opt sum} bandwidth selection based on MSE of sum of densities (one common bandwidth, {it:hl}={it:hr}).{p_end}
{p 8 12}{opt comb} bandwidth is selected as a combination of the alternatives above:{p_end}
{p 12 16}For {cmd:fitselect(}{opt unrestricted}{cmd:)}, it selects median({opt each},{opt diff},{opt sum}).{p_end}
{p 12 16}For {cmd:fitselect(}{opt restricted}{cmd:)}, it selects min({opt diff},{opt sum}).{p_end}
{p 12 16}This is the default option.{p_end}

{p 4 8}{cmd:vce(}{it:vcemethod}{cmd:)} specifies the procedure used to compute the variance-covariance matrix estimator.
Options are:{p_end}
{p 8 12}{opt plugin} for asymptotic plug-in standard errors.{p_end}
{p 8 12}{opt jackknife} for jackknife standard errors. This is the default option.{p_end}

{p 4 8}{cmd:all} if specified, {cmd:rddensity} reports two testing procedures (given choices {cmd:fitselect(}{it:fitmethod}{cmd:)} and {cmd:bwselect(}{it:bwmethod}{cmd:)}):{p_end}
{p 8 12}1. Conventional test statistic (not valid when using MSE-optimal bandwidth choice).{p_end}
{p 8 12}2. Robust bias-corrected statistic. This is the default option.{p_end}

{p 4 8}{cmd:plot} if specified, {cmd:rddensity} plots density around the cutoff (this feature depends on a companion package {cmd:lpdensity}). Note that additional estimation (computing time) is need.{p_end}

{p 4 8}{cmd:plot_range(}{it:#} {it:#}{cmd:)} specifies the lower and upper bound of the plotting region. By default it is three bandwidths around the cutoff. {p_end}

{p 4 8}{cmd:plot_n(}{it:#} {it:#}{cmd:)} specifies the number of grid points used for plotting on the two sides of the cutoff. By default it is {cmd:plot_n(10 10)} (that is, 10 points are used on each side).{p_end}

{p 4 8}{cmd:plot_grid(}{it:gridmethod}{cmd:)} specifies how the grids are positioned. Options are:{p_end}
{p 8 12}{opt es} evenly spaced.{p_end}
{p 8 12}{opt qs} quantile spaced.{p_end}

{p 4 8}{opt gen:vars}({it:VarName}) specifies if new varaibles should be generated to store estimation results for plotting. If {it:VarName} is provided, the following new varaibles will be
generated: {p_end}
{p 8 12}{it:VarName_grid} (grid points), {p_end}
{p 8 12}{it:VarName_bw} (bandwidth), {p_end}
{p 8 12}{it:VarName_f} (point estimate with polynomial order {cmd:p(}{it:#}{cmd:)}), {p_end}
{p 8 12}{it:VarName_cil} and {it:VarName_cir} (confidence interval constructed with polynomial order {cmd:q(}{it:#}{cmd:)}), {p_end}
{p 8 12}{it:VarName_group} (equals 1 if the grid point is to the right of the cutoff). {p_end}

{p 4 8}{opt l:evel}({it:#}) controls the level of the confidence interval, and should be between 0 and 100. Default is {cmd:level(95)}.{p_end}

{p 4 8}{opt gra:ph_options}({it:...}) specifies options for plotting. {p_end}

{hline}
	
		
{marker examples}{...}
{title:Example: Cattaneo, Frandsen and Titiunik (2015) Incumbency Data}.

{p 4 8}Load dataset (cutoff is 0 in this dataset):{p_end}
{p 8 8}{cmd:. use rddensity_senate.dta}{p_end}

{p 4 8}Manipulation test using default options: {p_end}
{p 8 8}{cmd:. rddensity margin}{p_end}

{p 4 8}Manipulation test using all three method available:{p_end}
{p 8 8}{cmd:. rddensity margin, all}{p_end}

{p 4 8}Manipulation test using manual bandwidths choices and plug-in standard errors:{p_end}
{p 8 8}{cmd:. rddensity margin, h(10 20) vce(plugin)}{p_end}

{p 4 8}Plot density and save results to variables:{p_end}
{p 8 8}{cmd:. capture drop temp_*}{p_end}
{p 8 8}{cmd:. rddensity margin, plot plot_range(-50 50) plot_n(100 100) genvars(temp) graph_options(title("RDDENSITY PLOT: Senate Data") xtitle("margin"))}{p_end}



{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rddensity} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(c)}}cutoff value{p_end}
{synopt:{cmd:e(p)}}order of the polynomial used for density estimation{p_end}
{synopt:{cmd:e(q)}}order of the polynomial used for bias-correction estimation{p_end}
{synopt:{cmd:e(N_l)}}sample size to the left of the cutoff{p_end}
{synopt:{cmd:e(N_r)}}sample size to the right of the cutoff{p_end}
{synopt:{cmd:e(N_h_l)}}effective sample size (within bandwidth) to the left of the cutoff{p_end}
{synopt:{cmd:e(N_h_r)}}effective sample size (within bandwidth) to the right of the cutoff{p_end}
{synopt:{cmd:e(h_l)}}bandwidth used to the left of the cutoff{p_end}
{synopt:{cmd:e(h_r)}}bandwidth used to the right of the cutoff{p_end}
{synopt:{cmd:e(f_ql)}}bias-corrected density estimate to the left of the cutoff{p_end}
{synopt:{cmd:e(f_qr)}}bias-corrected density estimate to the right of the cutoff{p_end}
{synopt:{cmd:e(se_ql)}}standard error for bias-corrected density estimate to the left of the cutoff{p_end}
{synopt:{cmd:e(se_qr)}}standard error for bias-corrected density estimate to the right of the cutoff{p_end}
{synopt:{cmd:e(se_q)}}standard error for bias-corrected density test{p_end}
{synopt:{cmd:e(pv_q)}}p-value for bias-corrected density test{p_end}
{synopt:{cmd:e(runningvar)}}running variable used{p_end}
{synopt:{cmd:e(kernel)}}kernel used{p_end}
{synopt:{cmd:e(fitmethod)}}model used{p_end}
{synopt:{cmd:e(bwmethod)}}bandwidth selection method used{p_end}
{synopt:{cmd:e(vce)}}standard errors estimator used{p_end}


{title:References}

{p 4 8}Cattaneo, M. D., Frandsen, B., and R. Titiunik. 2015.
{browse "https://sites.google.com/site/rdpackages/rdlocrand/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Randomization Inference in the Regression Discontinuity Design: An Application to the Study of Party Advantages in the U.S. Senate}.{p_end}
{p 8 8}{it:Journal of Causal Inference} 3(1): 1-24.{p_end}

{p 4 8}Cattaneo, M. D., Michael Jansson, and Xinwei Ma. 2018. {browse "https://sites.google.com/site/rdpackages/rddensity/Cattaneo-Jansson-Ma_2018_Stata.pdf": Manipulation Testing based on Density Discontinuity}.{p_end}
{p 8 8}{it:Stata Journal} 18(1): 234-261.{p_end}

{p 4 8}Cattaneo, M. D., Michael Jansson, and Xinwei Ma. 2019. {browse "https://sites.google.com/site/rdpackages/rddensity/Cattaneo-Jansson-Ma_2019_JASA.pdf":Simple Local Polynomial Density Estimators}.{p_end}
{p 8 8}{it:Journal of the American Statistical Association}, forthcoming.{p_end}

{p 4 8}McCrary, J. 2008. Manipulation of the running variable in the regression discontinuity design: A density test.{p_end}
{p 8 8}{it:Journal of Econometrics} 142(2): 698-714.{p_end}


{title:Authors}

{p 4 8}Matias D. Cattaneo, Princeton University, Princeton, NJ.
{browse "mailto:cattaneo@princeton.edu":cattaneo@princeton.edu}.

{p 4 8}Michael Jansson, University of California Berkeley, Berkeley, CA.
{browse "mailto:mjansson@econ.berkeley.edu":mjansson@econ.berkeley.edu}.

{p 4 8}Xinwei Ma, University of California San Diego, La Jolla, CA.
{browse "mailto:x1ma@ucsd.edu":x1ma@ucsd.edu}.



