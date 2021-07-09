{smcl}
{* *! version 0.91 }{...}
{cmd:help swpermute}{right: ({})}
{hline}


{vieweralsosee "[R] permute" "help permute"}{...}

{viewerjumpto "Syntax" "swpermute##syntax"}{...}
{viewerjumpto "Menu" "swpermute##menu"}{...}
{viewerjumpto "Description" "swpermute##description"}{...}
{viewerjumpto "Options" "swpermute##options"}{...}
{viewerjumpto "Examples" "swpermute##examples"}{...}
{viewerjumpto "Stored results" "swpermute##results"}{...}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col :{hi:swpermute} {hline 2}}Monte Carlo permutation tests for stepped wedge 
trial designs {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:swpermute}
	{it:{help exp}}
	{cmd:,} 
	{opth cluster(varname)}
	{opth period(varname)}
	{opth intervention(varname)}
	[{it:{help swpermute##options_table:options}}]
	{cmd::} {it:command}




{synoptset 29 tabbed}{...}
{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{p2coldent :* {opth cl:uster(varname)}}variable defining the clusters{p_end}
{p2coldent :* {opth per:iod(varname)}}variable defining the periods of the 
trial{p_end}
{p2coldent :* {opth int:ervention(varname)}}variable defining the intervention 
conditions. This 
must be a binary variable{p_end}
{synopt :{opt r:eps(#)}}perform {it:#} random permutations; default is {opt reps(1000)}{p_end}
{synopt :{opt lef:t}|{opt rig:ht}}compute one-sided p-values; default is two-sided{p_end}

{syntab :Options}
{synopt :{opth str:ata(varlist)}}permute within strata{p_end}
{synopt :{opth null(numlist)}}null hypothesis values to be tested. Only available 
for continuous outcomes and cluster-period level outcomes. The default is 0{p_end}
{synopt :{opth out:come(varname)}}variable defining the outcome in the analysis. 
This must be specified for null values other than 0{p_end}
{synopt :{help prefix_saving_option:{bf:{ul:sa}ving(}{it:filename, ...}{bf:)}}}save 
estimated effects of each permutation to {it:filename}; save estimates in double 
precision; save estimates to {it:filename} every # permutations{p_end}


{syntab :Within-period}
{synopt :{opt wi:thinperiod}}run {it:command} within each level of the variable 
defined in {opt period()} and combine using a weighted average{p_end}
{synopt :{opth we:ightperiod:(swpermute##weightperiod:weightperiod)}}the weight 
given to each period if a within-period analysis has been selected. The default 
is weightperiod(N) which weights periods by the number of clusters in each 
intervention condition{p_end}
	
	
{syntab :Reporting}
{synopt :{opt nodots}}suppress permutation dots{p_end}
{synopt :{opt lev:el(#)}}set confidence level; default is level(95)

{syntab :Advanced}
{synopt :{opt seed(#)}}set random-number seed to {it:#}{p_end}
{synoptline}
{pstd}*these options are required.
{p2colreset}{...}

{marker weightperiod}{...}
{synoptset 23}{...}
{synopthdr :weightperiod}
{synoptline}
{synopt :{opt none}}equal weight is given to all periods{p_end}
{synopt :{opt N}}periods are weighted by the number of clusters in the control and intervention conditions in that period: {bind:(1/s_0j + 1/s_1j)^-1} where s_0j is the number of clusters in the control condition in period j and s_1j is the number in the intervention condition in period j. This is the default{p_end}
{synopt :{opt var:iance} {it:exp}}periods are weighted by the inverse of the statistic  
{it:exp} calculated by the {it:command}. Usually {it:exp} will be a variance{p_end}
{synoptline}
{p2colreset}{...}

{marker menu}{...}
{title:Menu}

{pstd}
This command can be executed from a dialog box. To add {cmd:swpermute} to your menu 
type these commands:
{p_end}
{phang2}{cmd:. window menu append submenu "stUser" "&Cluster RCTs"}{p_end}
{phang2}{cmd:. window menu append item "Cluster RCTs" "Permute for stepped wedge trials (&swpermute)" "db swpermute"}{p_end}
{phang2}{cmd:. window menu refresh}{p_end}

{pstd}
To permanently install this command menu, place  the above code into your profile.do file.
Further information on how to do this and how to find your profile.do file see  
{helpb profilew}, {helpb profilem}, or {helpb profileu} for window, mac, or unix respectively.
{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:swpermute} estimates p-values for permutation tests using data from stepped-wedge 
cluster-randomised trial designs. The command can also be used for parallel cluster-randomised 
trial designs. 

{pstd}
In a stepped-wedge trial, clusters are assigned to sequences consisting of a number 
of periods receiving a control condition, followed by the remaining periods receiving the 
intervention condition. The variable defining the clusters is given in {opt cluster()}, 
the variable defining the periods is given in {opt period()}, and the variable defining 
the intervention is given in {opt intervention()}.

{pstd}
In this context, a permutation means assigning clusters to a different sequence, selected from the sequences observed in the trial.

{pstd}
The command uses Monte-Carlo permutations meaning that a number of permutations 
are selected at random, rather than using all possible arrangements of clusters 
to sequences. For more information about permutation tests, see the Stata help 
file for {helpb permute}.

{pstd}
The syntax for {cmd: swpermute} is similar to {helpb permute}. Typing

{pin}
{cmd: swpermute} {it:exp}, 
{opt cluster:(varname)}
{opt period:(varname)}
{opt intervention:(varname)}{cmd::}
{it:command}

{pstd}
randomly permutes clusters between the sequences that are present in the data. 
A specified number of permutations are completed as defined by {opt reps(#)} (the 
default is 500). For each permutation, {it:command}  is executed and the value given 
by the expression {it:exp} is collected. These values are compared to the value of 
{it:exp} given by the original data to calculate a p-value as 

{pin}
p = c/n

{pstd}
where n is the number of permutations and c is the number of permutations that 
resulted in {it:exp} the same as or more extreme than the value of {it:exp} given 
by the original data.

{pstd}
{it:command} defines the statistical command to be executed. Most Stata commands 
and user-written programs can be used with {cmd:swpermute}. 

{pstd}
{it:exp} specifies the expression to be collected from the execution of
{it:command} (see {helpb return} and the {it:command} help file for more details). 
Unlike the {helpb permute} command, you should not give this expression a name and 
do not need to enclose the expression in brackets.

{pstd}
If {opt withinperiod} is specified, the {it:command} is run within each level of 
the variable defined in {opt period()}. This results in a value of {it:exp} for 
each level. A weighted average of these values is calculated using the weights 
specified in {opt weightperiod()}. If {it:variance} is specified you must provide 
an expression in the {opt weightperiod()} option giving the variance expression 
to extract from {it:command}.

{pstd}
For continuous and cluster-period level outcomes, {opt null()} may be specified to test 
null values other than 0. This is useful to construct of confidence intervals. For 
each value given in {opt null()}, the value is subtracted from outcomes given in the variable defined in {opt outcome()} if the variable defined in {opt intervention()} is equal to 1. The permutations then proceeds as before. The seed is reset for each  null value to ensure the same set of permutations are selected so that there is consistency between the p-value and confidence interval.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth cluster:(varname)} specifies a numeric variable the gives the clusters. All 
observations within each {opt cluster()} must have the same value of {opt intervention()} 
in each {opt period()}. Observations with {opt cluster()} missing will be excluded from the analysis.

{phang}
{opth period:(varname)} specifies a numeric variable the gives the periods. Observations with {opt period()} missing will be excluded from the analysis.

{phang}
{opth intervention:(varname)} specifies a binary variable that gives the intervention 
assignment, where 0 and 1 represent the control and intervention conditions, respectively. All observations within each value of {opt cluster()} must have the same value of {opt intervention()} in each {opt period()}. If all values of {opt intervention()} are missing for a {opt cluster()} in a {opt period()}, this is assumed to be part of the sequence, for
example as a washout period, and the missing value will be permuted. Otherwise, observations with {opt intervention()} missing will be excluded from the analysis.

{phang}
{opt reps(#)} specifies the number of permutations to perform.  The default is 500.

{phang}
{opt left} or {opt right} requests that one-sided p-values be computed.
If {opt left} is specified, the p-value reported is the proportion of permutations 
where {it:exp} gives a value less than the value given by the original data. If 
{opt right} is specified, the p-value reported is the proportion of permutations 
where {it:exp} gives a value greater than the value given by the original data. The default, when neither left nor right is specified, is to calculate two-sided p-values, that is the proportion of permutations where {it:exp} gives a value further from 0 than the value given by the original data. 

{dlgtab:Options}

{phang}
{opth strata(varlist)} specifies that the permutations be performed within each 
stratum defined by the values of {it:varlist}. This option should be used if randomisation of clusters was stratified.

{phang}
{opt saving:(filename[, suboptions])} creates a Stata file (.dta file) consisting 
of a row for each permutation run for each value in {opt null()}. The dataset will contain 
three variables; one containing the null value, one containing the value of {it:exp}
in the observed data for that null value, and one for values of {it:exp} for each
permutation. 

{pmore}
See {it:{help prefix_saving_option}} for details about {it:suboptions}.

{phang}
{opth null(numlist)} specifies a list of null hypothesis values. For each value 
specified, a set of permutations will be run and a p-value will be calculated after 
subtracting the null value from outcomes assigned to {opt intervention()}==1. For each value in numlist the random seed is reset to the value specified in {opt seed()} or the value when the command was called. This option is only available for continuous outcomes (including cluster-period level outcomes). The null values are assumed to be on the same scale as the outcome (e.g. risks differences if the outcomes are cluster-period risks). For cluster-period level outcomes, ratios such as 
risk ratios, or odds ratios should be given on the log scale. The default is 
{opt null(0)}. When values other than the default are specified the option
{opt outcome(varname)} is required.

{phang}
{opth outcome(varname)} specifies the outcome variable from which the null value
will be subtracted.  The outcome variable is assumed to be on the same scale as 
the null values. Required if option {opt null()} is given with a value other 
than 0.

{dlgtab:Within period analysis}

{phang}
{opt withinperiod} requests {it:command} be run within each level of {opt period()}.
A weighted mean of the {it:exp} values from each level of {opt period()} is then 
calculated using the weights given in {opt weightperiod()}. This option allows what 
is known as a "vertical analysis" in stepped-wedge trial literature.

{phang}
{opth weightperiod:(swpermute##weightperiod:weightperiod)} specifies which weights 
to use when calculating the weighted mean of the {it:exp} values from a within-period
analysis. The default is {opt weightperiod(N)} which weights periods by the 
number of clusters in each condition during that period. Other options are {it:none}, 
or {it:variance}.

{dlgtab:Reporting}

{phang}
{opt nodots} suppresses display of the permutation dots.  By default, one 
dot character is displayed for each successful permutation.  A red 'x'
is displayed if {it:command} returns an error or if the statistic in
{it:exp} is missing for a permutation.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence 
intervals. The default is {cmd:level(95)}.

{dlgtab:Advanced}

{phang}
{opt seed(#)} sets the random-number seed.  Specifying this option is
equivalent to typing :

{pin2}
{cmd:. set seed} {it:#}

{pmore}
prior to calling {cmd:swpermute}.

{marker examples}{...}
{title:Examples}
    {hline}
    Setup
{phang2}{cmd:. webuse tbconfirmed, clear}{p_end}

{pstd}Run permutation test on the results of a mixed-effect model{p_end}
{phang2}{cmd:. swpermute _b[arm], intervention(arm) period(study_month) cluster(lab) reps(100): melogit confirmed arm i.study_month || lab :}{p_end}


    {hline}
    Setup
{phang2}{cmd:. webuse tbconfirmed, clear}{p_end}

{pstd}Calculate the risk of the outcome in each cluster-period{p_end}
{phang2}{cmd:. collapse (sum) cases=confirmed (count) N=confirmed, by(lab study_month arm)}{p_end}
{phang2}{cmd:. gen risk = cases / N}{p_end}

{pstd}Run a within period analysis on cluster-period level outcomes to calculate a risk difference{p_end}
{phang2}{cmd:. swpermute r(mu_2) - r(mu_1), intervention(arm) period(study_month) cluster(lab) withinperiod weightperiod(variance r(se)^2) reps(100): ttest risk, by(arm)}{p_end}

{pstd}Test different null values to generate a confidence interval{p_end}
{phang2}{cmd:. swpermute r(mu_2) - r(mu_1), outcome(risk) null(0.05 0.15) intervention(arm) period(study_month) cluster(lab) withinperiod weightperiod(variance r(se)^2) reps(100): ttest risk, by(arm)}{p_end}

    {hline}

	

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:swpermute} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N_cluster)}}number of clusters being permuted{p_end}
{synopt:{cmd:r(N_strata)}}number of strata if strata option is specified{p_end}
{synopt:{cmd:r(obs_value)}}value of {it:exp} observed in the original data{p_end}
{synopt:{cmd:r(N_reps)}}number of permutations{p_end}


{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(design)}}a matrix of 0 and 1 values showing the design of the SWT{p_end}
{synopt:{cmd:r(obs_period)}}value of {it:exp} observed in the original data within each value of period if a within period analysis is specified{p_end}
{synopt:{cmd:r(p)}}p-values with their confidence intervals for each null value{p_end}

{p2colreset}{...}

{marker references}{...}
{title:References}

{phang}
Thompson JA & Davey C, Fielding K, Hargreaves JR, Hayes RJ. Robust analysis of stepped wedge trials using cluster-level summaries within periods. Statistics in Medicine, 2018(37) 2487-2500. doi: 10.1002/sim.7668

{phang}
Ji X, Fink G, Robyn PJ, Small SS. Randomization inference for stepped-wedge cluster-randomised trials: An application to community-based health insurance. Annals of Applied Statistics. 2011(11) 1-20

{phang}
Wang, R., and De Gruttola, V. The use of permutation tests for the analysis of parallel and stepped-wedge cluster-randomized trials. Statistics in Medicine, 2017(36) 2831–2843. doi: 10.1002/sim.7329

{marker Authors}{...}
{title:Authors}

Jennifer Thompson
London School of Hygiene and Tropical Medicine
London, UK
jennifer.thompson@lshtm.ac.uk


