{smcl}
{* *! version 1.1.1 30may2013}{...}
{viewerjumpto "Syntax" "stlda##syntax"}{...}
{viewerjumpto "Description" "lstlda##description"}{...}
{viewerjumpto "Remarks" "stlda##remarks"}{...}
{viewerjumpto "Options" "stlda##options"}{...}
{viewerjumpto "Examples" "stlda##examples"}{...}
{viewerjumpto "Saved results" "stlda##saved_results"}{...}
{viewerjumpto "Author" "stlda##author"}{...}
{viewerjumpto "References" "stlda##references"}{...}

{title:Title}

{p2colset 5 14 14 2}{...}
{p2col:{hi:stlda} {hline 2}}Limiting dilution analysis{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd:stlda} {it: cellsvar} {it:nvar} {it:negvar} {ifin} {cmd:,} [{it:stlda_options}]

{synoptset 20 tabbed}{...}
{synopthdr:stlda_options}
{synoptline}
{synopt:{opt m:ethod(methodtype)}}set the method used for computing confidence intervals; default is {cmd:method(wald1)}{p_end}
{synopt:{opt l:evel(#)}}set the confidence level of the confidence interval; default is {cmd:level(95)}{p_end}
{synopt:{opt p:lot}}display a graphical summary of the fitted model{p_end}
{synoptline}

{pstd}
{it:cellsvar} specifies the variable giving the expected number of cells, or dose, tested at each dilution level.{p_end}

{pstd}
{it:nvar} specifies the variable giving the number of replicate cultures at each dilution level.{p_end}

{pstd}
{it:negvar} specifies the variable giving the number of negative cultures observed at each dilution level.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:stlda} performs analysis of limiting dilution assays. Point and confidence interval (CI) estimates of the frequency of
 biologically active cells are computed. The CI can be constructed by three different methods (see below the {cmd: method} option).
 A single-hit model is assumed, which is fitted by maximum likelihood within the framework of generalized linear models (GLM); see
 Bonnefoix {it:et al.} (1996) for details. Also several goodness-of-fit tests are computed. Besides tests based on deviance and 
 Pearson chi-squared statistics (as performed, e.g., by L-Calc software, StemCell Technologies), tests of the single-hit hypothesis 
 (similar to those performed by the ELDA webtool {browse "http://bioinf.wehi.edu.au/software/elda"}) are included. These single-hit
 hypothesis tests are defined in the context of an extended GLM which includes a linear term modelling the effect of the dose (see Hu
 and Smyth, 2009). In these tests, here implemented using Wald, score and likelihood ratio statistics, the null hypothesis that the 
 coefficient of the linear term (the slope) of the GLM is equal to one is tested.{p_end}
 
{marker options}{...}
{title:Options}

{phang}
{opt method(methodtype)} specifies the method of CI construction to be used. The accepted values of {it:methodtype} are {cmd:wald1}, {cmd:wald2}
 and {cmd:prlik}. Either {cmd:wald1} or {cmd:wald2} determine the computation of different versions of Wald CIs. With {cmd:wald1} the
 CI limits are obtained by exponentiating the corresponding limits of a Wald CI for the logarithm of the frequency. With {cmd:wald2}
 the CI limits are obtained by a direct application of the Wald method to the frequency estimate, deriving its standard error from the
 standard error of the estimate of its logarithm by means of the delta method. When the argument is {cmd:prlik}, a profile likelihood CI
 is computed. The default is {cmd: method(wald1)}.

{phang}
{opt level(#)} specifies the confidence level of the CI as a percentage. The default is {cmd: level(95)}.

{phang}
{opt plot} specifies if a plot with the fitted mean proportion of negative cultures and their confidence intervals is to be
 displayed. The plot also shows the observed proportion of negative cultures of the experiment.

{marker remarks}{...}
{title:Remarks}

{pstd}
Note that, although some checking of the correctness of the input variables (i.e., the mandatory variables {it:cellsvar}, {it:nvar}
 and {it:negvar}) is done, the order in which they are entered must be respected. If not, either spurious results or an error message
 will be generated.{p_end}

{pstd}
{cmd:stlda} requires that the Stata module -moremata- (Jann, 2005) be installed.{p_end}

{marker examples}{...}
{title:Examples} 

{pstd}
Load the example dataset (Table III, from Strijbosch {it:et al.}, 1987):{p_end}
{pmore}
{stata "use http://fmwww.bc.edu/repec/bocode/s/stlda":. use "http://fmwww.bc.edu/repec/bocode/s/stlda"}{p_end}

{pstd}
Analysis using the default options:{p_end}
{pmore}
{stata "stlda cells n neg":. stlda cells n neg}{p_end}

{pstd}
An analysis giving the estimates of Table IV of Strijbosch {it:et al.} (1987) (the first group of replicate cultures is omitted):{p_end}
{pmore}
{stata "stlda cells n neg in 2/L, method(wald2)":. stlda cells n neg in 2/L, method(wald2)}{p_end}

{pstd}
A 99% level CI constructed using the profile likelihood method:{p_end}
{pmore}
{stata "stlda cells n neg, method(prlik) l(99)":. stlda cells n neg, method(prlik) l(99)}{p_end}

{pstd}
The same, but with a plot summarizing the fitted model:{p_end}
{pmore}
{stata "stlda cells n neg, method(prlik) level(99) plot":. stlda cells n neg, method(prlik) level(99) plot}{p_end}

{marker saved_results}{...}
{title:Saved results}

{cmd:stlda} saves the following in {cmd:r()}:

Scalars

{p2colset 5 22 26 2}{...}
{p2col:{cmd:r(freq)}}frequency estimate{p_end}
{p2col:{cmd:r(ci_ll)}}lower limit of the CI for the frequency{p_end}
{p2col:{cmd:r(ci_ul)}}upper limit of the CI for the frequency{p_end}
{p2col:{cmd:r(deviance)}}deviance test statistic{p_end}
{p2col:{cmd:r(p_deviance)}}p-value of the deviance test{p_end}
{p2col:{cmd:r(pearson)}}Pearson chi-squared test statistic{p_end}
{p2col:{cmd:r(p_pearson)}}p-value of the Pearson chi-squared test{p_end}
{p2col:{cmd:r(df)}}degrees of freedom of the deviance and Pearson chi-squared tests{p_end}
{p2col:{cmd:r(slope)}}slope estimate{p_end}
{p2col:{cmd:r(wald_slope)}}statistic of the Wald test for slope{p_end}
{p2col:{cmd:r(p_wald_slope)}}p-value of the Wald test for slope{p_end}
{p2col:{cmd:r(score_slope)}}statistic of the score test for slope{p_end}
{p2col:{cmd:r(p_score_slope)}}p-value of the score test for slope{p_end}
{p2col:{cmd:r(lr_slope)}}statistic of the likelihood ratio test for slope{p_end}
{p2col:{cmd:r(p_lr_slope)}}p-value of the likelihood ratio test for slope{p_end}
{p2colreset}{...}

{marker author}{...}
{title:Author}

{pstd}Ignacio López de Ullibarri{p_end}
{pstd}Department of Mathematics{p_end}
{pstd}University of A Coruña, Spain{p_end}
{pstd}E-mail: {browse "mailto:ilu@udc.es":ilu@udc.es}{p_end}

{marker references}{...}
{title:References}

{phang}
Bonnefoix T, Bonnefoix P, Verdiel P and Sotto JJ (1996), Fitting limiting dilution experiments with generalized linear
models results in a test of the single-hit Poisson assumption, {it:Journal of Immunological Methods}, 194: 113-119

{phang}
Hu Y and Smyth GK (2009), ELDA: Extreme limiting dilution analysis for comparing depleted and enriched populations in
 stem cell and other assays, {it:Journal of Immunological Methods}, 347: 70-78

{phang}
Jann B (2005), {it:moremata: Stata module (Mata) to provide various functions}, available from 
 {browse "http://ideas.repec.org/c/boc/bocode/s455001.html"}

{phang}
Strijbosch LWG, Buurman WA, Does RJMM and Zinken PH (1987), Limiting dilution assays. Experimental design and statistical
 analysis, {it:Journal of Immunological Methods}, 97: 133-140
 
