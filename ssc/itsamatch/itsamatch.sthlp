{smcl}
{* 21Nov2017}{...}
{* 27Oct2017}{...}
{title:Title}

{p2colset 5 18 22 2}{...}
{p2col :{hi:itsamatch} {hline 2}} Matching for multiple group interrupted time-series analysis {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:itsamatch} {it:{varlist}} {ifin} {weight}{cmd:,}
{opt trp:eriod(#)}
{opt treat:id(#)}
[ {opt p:r(#)}
{opt l:ag(#)}
{opt prais}
{opt l:ocal(macname)} 
{it:model_options} ]


{pstd}
The panel variable must be declared by using either {cmd:tsset} {it:panelvar} {it:timevar} 
or {cmd:xtset} {it:panelvar} {it:timevar}. See {helpb tsset} or {helpb xtset}.{p_end}


{synoptset 19 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt trp:eriod(#)}}specifies the time period when the intervention begins{p_end}
{p2coldent:* {opt treat:id(#)}}specifies the identifier of the single treated unit{p_end}
{synopt:{opt p:r(#)}}specifies the minimum significance level ({it:P}-value) for assessing balance{p_end}
{synopt :{opt l:ag(#)}}specifies the maximum lag to be considered when a {cmd:newey} model is chosen; 
the default is {cmd:lag(0)}.{p_end}
{synopt:{opt prais}}specifies to fit a {helpb prais} model; the default model is {helpb newey}{p_end}
{synopt:{opt l:ocal(macname)}}stores the control identifiers in local macro {it:macname}, making them accessible for later use.{p_end}
{synopt:{it:model_options}}specifies all available options for {help prais} when the {cmd:prais} 
option is chosen; otherwise all available options of {help newey} {p_end}
{synoptline}
{marker weight}{...}
{p 4 6 2}* Both {opt trperiod(#)} and {opt treatid(#)} must be specified.{p_end}
{p 4 6 2}{opt aweight}s are allowed when a {helpb newey} model is specified; see
{help weight}.{p_end}


{title:Description}

{pstd}
{cmd:itsamatch} is a data pre-processing procedure that identifies units not-exposed 
to the intervention that will best serve as matched controls for the single treatment unit, 
in multiple group interrupted time-series analysis (ITSA). Matches are defined by assessing 
balance on the baseline level and trend of each variable specified in the varlist -- where 
balance is determined by a user-defined minimum significance level ({it:P}-value). 

{pstd}
{cmd:itsamatch} generates a list of control group identifiers that can be passed on to {helpb itsa}
to assess treatment effects. Under the ignorability assumption, we approximate a randomized experiment
by evaluating outcomes using matches that are balanced on observed pretreatment characteristics.{p_end}

   
{title:Options}

{phang}
{cmd:trperiod(}{it:#}{cmd:)} specifies the time period when the
intervention begins. The values entered for time period must be in the same
units as the panel time variable specified in {cmd:tsset} {it:timevar}; see
{helpb tsset}. {cmd:trperiod()} is required.

{phang}
{cmd:treatid(}{it:#}{cmd:)} specifies the identifier of the single treated
unit. The value entered must be in the same units as the panel variable 
specified in {cmd:tsset} {it:panelvar timevar}; see {helpb tsset}.
{cmd:treatid()} is required.

{phang}
{cmd:pr(}{it:#}{cmd:)} specifies the minimum significance level ({it:P}-value) for determining
balance on each variable in the {it:{varlist}}. While {cmd:pr} can be set to any value between
0 and 1.0, 0.05 is the usual convention for considering balance. Naturally, higher values will
ensure closer balance, but it comes at a trade-off of losing observations as potential matches.

{phang}
{cmd:prais} specifies to fit a {helpb prais} model.  If {cmd:prais} is
not specified, {cmd:itsa} will use {helpb newey} as the default model.

{phang}
{cmd:lag(}{it:#}{cmd:)} specifies the maximum lag to be considered in the
autocorrelation structure when a {cmd:newey} model is chosen.  If the user
specifies {cmd:lag(0)}, the default, the output is the same as {cmd:regress,}
{cmd:vce(robust)}.  An error message will appear if both {cmd:prais} and
{cmd:lag()} are specified, because {cmd:prais} implements an AR(1) model by
design.

{phang}
{cmd:local(}{it:macname}{cmd:)} stores the control identifiers in local macro {it:macname} within the calling program's space, 
thereby making the control identifiers accessible after {cmd:itsamatch} has finished. This is helpful for later use with {help itsa}.

{phang}
{it:model_options} specify all available options for {helpb prais} when the
{cmd:prais} option is chosen; otherwise, all available options for 
{helpb newey} other than {cmd:lag()} are specified.


{title:Remarks} 

{pstd}
In the ITSA context, an investigator will want to find control units that are comparable to the treated
unit on the baseline level and trend of the outcome variable (see [Linden 2015, 2017a, 2017b, 2017c] for
examples). However, ensuring balance on covariates (i.e. possible confounders) will further improve causal 
inference. Whereas the synthetic controls [Abadie et al. 2010] and propensity score weighting 
[Linden and Adams 2011] methods reweight observations to adjust for observed confounders, {cmd:itsamatch} 
matches on the variables directly. In doing so, it retains the straightforward interpretation of 
the estimates derived from the ITSA model (see [Linden 2017a] for these estimates).   

{pstd}
The basic regression model for a multiple group ITSA is as follows (Linden 2015):

{pmore} Y_t = Beta_0 + Beta_1(T) + Beta_2(X_t) + Beta_3(TX_t) +
Beta_4(Z) + Beta_5(ZT) + Beta_6(ZX_t) + Beta_7(ZTX_t){space 5}

{pstd}
The two parameters Beta_4 and Beta_5 play a particularly important role in establishing whether 
the treatment and control groups are balanced on both the level and the trajectory of the dependent 
variable in the pre-intervention period.  If these data were from a randomized controlled trial, we would
expect similar levels and slopes before the intervention.  However, in an observational study 
where equivalence between groups cannot be ensured, any observed differences will likely raise 
concerns about the ability to draw causal inferences about the relationship between the intervention 
and the outcomes (Linden and Adams 2011).  

{pstd} 
{cmd:itsamatch} assesses the {it:P}-value for the Beta_4 and Beta_5 coefficients for each variable specified
by the user in the varlist by replacing Y_t with the covariate. Thus, good matches will be identified 
as those having non-statistically significant differences on baseline level (Beta_4) and baseline trend
(Beta_5) for any variables tested.

{pstd}
A final note relating to "the curse of dimensionality." As the number of variables assessed for matching
grows, fewer matches will likely be found. Naturally, this is also a function of heterogenity in the sample, so fewer
matches will be found in a heterogeneous sample on even one variable. In such situations, the investigator may
choose to limit the variables to only those that are most important for causal inference (i.e. outcome variable and 
perhaps one or two other suspected confounders) or consider rescaling all the variables to reduce heterogeneity and
increase likelihood of matching on more variables. 


{title:Examples}

{pmore}
Load data and declare the dataset as panel: {p_end}

{phang3}{cmd:. use cigsales, clear}{p_end}
{phang3}{cmd:. tsset state year}{p_end}

{pmore}
We find controls that match the treated unit(3) on the outcome variable "cigsale". We set the minimum
cutoff {it:P}-value at 0.20, specify autocorrelation at lag 1, and specify that the the stored local macro be named "controls".{p_end}

{phang3}{cmd:. itsamatch cigsale, treatid(3) trperiod(1989) pr(0.20) lag(1) local(controls)}{p_end}

{pmore}
Three matches were found, control units 4, 8, and 9. We now plug those values in {cmd:contid()} in an {helpb itsa} model using the stored {cmd: local(controls)}.{p_end}

{phang3}{cmd:. itsa cigsale, treatid(3) trperiod(1989) contid(`controls') lag(1) replace figure(xlabel(1970(5)2000)) posttrend}{p_end}

{pmore}
We now add the covariate "retprice" to varlist and rerun {cmd: itsamatch}.{p_end}

{phang3}{cmd:. itsamatch cigsale retprice, treatid(3) trperiod(1989) pr(0.20) lag(1) local(controls)}{p_end}

{pmore}
The same three matches were found, control units 4, 8, and 9. We now verify (numerically and visually) the balance on "retprice"
by specifying "retprice" as the dependent variable in the {helpb itsa} model.{p_end}

{phang3}{cmd:. itsa retprice, treatid(3) trperiod(1989) contid(`controls') lag(1) replace figure(xlabel(1970(5)2000)) posttrend}{p_end}


{title:Stored results}

{pstd}
{cmd:itsamatch} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: matrices}{p_end}
{synopt:{cmd:r(contids)}}matrix containing control identifiers{p_end}


{title:Acknowledgments}

{p 4 4 2}
I wish to thank Nicholas J. Cox for his support in developing {cmd: itsamatch}.


{title:References}

{phang}
Abadie, A., A. Diamond, and J. Hainmueller. 2010. Synthetic control methods for comparative
case studies: Estimating the effect of California’s tobacco control program.
Journal of the American Statistical Association 105: 493–505.

{phang}
Linden, A. 2015.
{browse "http://www.stata-journal.com/article.html?article=st0389":Conducting interrupted time series analysis for single and multiple group comparisons}.
{it:Stata Journal}.
15: 480-500.

{phang}
------. 2017a.
{browse "http://www.stata-journal.com/article.html?article=st0389_3":A comprehensive set of postestimation measures to enrich interrupted time-series analysis}.
{it:Stata Journal}
17: 73-88.

{phang}
------. 2017b.
Challenges to validity in single-group interrupted time series analysis.
{it:Journal of Evaluation in Clinical Practice}.
23: 413-418.

{phang}
------. 2017c.
Persistent threats to validity in single-group interrupted time series analysis with a crossover design.
{it:Journal of Evaluation in Clinical Practice}.
23: 419-425.

{phang}
------. 2017d.
A matching framework to improve causal inference in interrupted time series analysis.
{it:Journal of Evaluation in Clinical Practice}.
DOI:10.1111/jep.12874

{phang} 
Linden, A., and J. L. Adams. 2011. 
Applying a propensity-score based weighting model to interrupted time
series data: Improving causal inference in program evaluation. 
{it:Journal of Evaluation in Clinical Practice} 
17: 1231-1238.



{title:Author}

{pstd}Ariel Linden{p_end}
{pstd}Linden Consulting Group, LLC{p_end}
{pstd}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
       
 
{title:Also see}

{p 7 14 2}Help:  {helpb newey}, {helpb prais}, {helpb itsa} (if installed)
 {p_end}
