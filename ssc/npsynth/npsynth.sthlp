{smcl}
{* 22June2020}{...}
{cmd:help npsynth}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col: {hi:npsynth} {hline 1}}Nonparametric Synthetic Control Method{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:npsynth}
{it: outcome} 
{it:varlist}{cmd:,}
{cmd:trperiod}{cmd:(}{it:#}{cmd:)}
{cmd:bandw}{cmd:(}{it:#}{cmd:)}
{cmd:panel_var}{cmd:(}{it:varname}{cmd:)}
{cmd:time_var}{cmd:(}{it:varname}{cmd:)}
{cmd:trunit}{cmd:(}{it:#}{cmd:)}
{cmd:kern}{cmd:(}{it:{help npsynth##kerneltype:kerneltype}}{cmd:)}
[{cmd:npscv}
{cmd:n_grid}{cmd:(}{it:#1,#2}{cmd:)}
{cmd:save_res}{cmd:(}{it:filename}{cmd:)}
{cmd:w_median}
{cmd:gr_y_name}{cmd:(}{it:name}{cmd:)}
{cmd:gr_tick}{cmd:(}{it:#}{cmd:)}
{cmd:gr1}
{cmd:gr2}
{cmd:gr3}
{cmd:save_gr1}{cmd:(}{it:graphname1}{cmd:)}
{cmd:save_gr2}{cmd:(}{it:graphname2}{cmd:)}
{cmd:save_gr3}{cmd:(}{it:graphname3}{cmd:)}]


{title:Description}

{pstd}{cmd:npsynth} extends the Synthetic Control Method (SCM)
for program evaluation proposed by Abadie and Gardeazabal (2003) and Abadie, Diamond, 
and Hainmueller (2010) to the case of a nonparametric identification of the synthetic 
(or counterfactual) time pattern of a treated unit. The model assumes that the treated unit
- such as a country, a region, a city, etc. - underwent a specific intervention in a given year,
and estimates its counterfactual time pattern, the one without intervention, as a weighted linear combination of 
control units based on the predictors of the outcome. The nonparametric imputation of the counterfactual is computed using 
weights proportional to the vector-distance between the treated unit's and the controls' predictors, using a kernel function with pre-fixed bandwidth.
The routine provides a graphical representation of the results for validation purposes. 


{phang} According to the {cmd:npsynth} syntax:

{phang} {it:outcome}: is the target variable over which measuring the impact of the treatment

{phang} {it:varlist}: is the set of covariates (or observable confounding) predicting the outcome in the pre-treatment period
   
{phang} {cmd:kern}{cmd:(}{it:kerneltype}{cmd:)} specifies the type of kernel function to use for building synthetic weights.  

{phang} {cmd:trunit}{cmd:(}{it:#}{cmd:)} specifies the treated unit, with value {it:#} in 'panel_var'. 

{phang} {cmd:trperiod}{cmd:(}{it:#}{cmd:)} specifies the time in which treatment starts.
 
{phang} {cmd:bandw}{cmd:(}{it:#}{cmd:)} specifies the bandwidth of the kernel weighting function.

{phang} {cmd:panel_var}{cmd:(}{it:varname}{cmd:)} specifies the panel variable.

{phang} {cmd:time_var}{cmd:(}{it:varname}{cmd:)} specifies the time variable.


{title:Options}

{phang} {cmd:npscv}: allows for computing the optimal bandwidth minimizing the pre-treatment RMSPE. 
The default length of the grid over which finding the optimal bandwidth is 20, which means that the bandwidths' grid is [0.1, 0.2, ..., 2]. 
This option returns the optimal bandwidth in the e-class object {inp:e(opt_band)}.

{phang} {cmd:n_grid}{cmd:(}{it:#1,#2}{cmd:)} allows to specify the length of the grid over which finding the optimal bandwidth. 
The default values are (1,20), which means that the bandwidths' grid is [0.1, 0.2, ..., 2].

{phang} {cmd:save_res}{cmd:(}{it:filename}{cmd:)} allows to save the treated factual and counterfactual time patterns in {it:filename.dta}.

{phang} {cmd:w_median} specifies that the unique vector of synthetic weights is calculated by the yearly weights' median (the default uses the mean).

{phang} {cmd:gr_y_name}{cmd:(}{it:name}{cmd:)} allows to give a convenient name to the outcome variable to appear in the graphs.

{phang} {cmd:gr_tick}{cmd:(}{it:#}{cmd:)} allows to set the tick of the time in the time axis of the graphs.  

{phang} {cmd:gr1}: allows to plot the the pre-treatment balancing and parallel trend graph.

{phang} {cmd:gr2}: allows to plot the overall treated/synthetic pattern comparison graph.
   
{phang} {cmd:gr3}: allows to plot the overall pattern of the difference between the treated and synthetic pattern graph.

{phang} {cmd:save_gr1}{cmd:(}{it:graphname1}{cmd:)} allows to save graph 1, i.e. the pre-treatment balancing and parallel trend.

{phang} {cmd:save_gr2}{cmd:(}{it:graphname2}{cmd:)} allows to save graph 2, i.e. the overall treated/synthetic pattern comparison.

{phang} {cmd:save_gr3}{cmd:(}{it:graphname3}{cmd:)} allows to save graph 3, i.e. the overall pattern of the difference between the treated and synthetic pattern.


{marker kerneltype}{...}
{synopthdr:kerneltype_options}
{synoptline}
{syntab:kern}
{p2coldent : {opt epan}}uses a Epanechnikov kernel{p_end}
{p2coldent : {opt normal}}uses a Normal kernel {p_end}
{p2coldent : {opt biweight}}uses a Biweight (or Quartic) kernel{p_end}
{p2coldent : {opt uniform}}uses a Uniform kernel{p_end}
{p2coldent : {opt triangular}}uses a Triangular kernel{p_end}
{p2coldent : {opt tricube}}uses a Tricube kernel{p_end}
{synoptline}

{pstd}
{cmd:npsynth} returns the following objects:

{pmore}
{inp:e(bandh)} is the bandwidth used within the selected kernel function.

{pmore}
{inp:e(RMSPE)} is the Root Mean Squared Prediction Error of the estimated model.

{pmore}
{inp:e(W)} is the vector of (kernel) weights.


{title:Remarks} 

{pstd} - The panel dataset must be perfectly balanced, and must not contain missing values.

{pstd} - Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.


{title:Example}

. use Ita_exp_euro , clear
. tsset reporter year
. global xvars "ddva1 log_distw sum_rgdpna comlang contig"
. npsynth ddva1 $xvars , panel_var(reporter) time_var(year) ///
  trperiod(2000) trunit(11) bandw(0.4) kern(triangular) gr1 gr2 gr3 ///
  save_gr1(gr1) save_gr2(gr2) save_gr3(gr3) ///
  gr_y_name("Domestic Direct Value Added Export (DDVA)") gr_tick(5)

   
{title:References}

{phang}
Abadie, A., Diamond, A., and Hainmueller, J., 2010. 
Synthetic Control Methods for Comparative Case Studies:
Estimating the Effect of California's Tobacco Control Program, 
{it:Journal of the American Statistical Association}, 105, 490, 493-505.
{p_end}

{phang}
Abadie, A., and Gardeazabal, J., 2003. The Economic Costs of Conflict:
A Case Study of the Basque Country, {it:American Economic Review}, 93, 1, 112-132.
{p_end}

{phang}
Cerulli, G. 2015. {it:Econometric Evaluation of Socio-Economic Programs: Theory and Applications},
Springer.
{p_end}

{phang}
Cerulli, G., 2019. A flexible Synthetic Control Method for modeling policy evaluation, {it:Economics Letters}, 182, 40-44.
{p_end}


{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}IRCrES-CNR{p_end}
{phang}Research Institute on Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}

{title:Also see}

{psee}
Online: {helpb synth}
{p_end}
