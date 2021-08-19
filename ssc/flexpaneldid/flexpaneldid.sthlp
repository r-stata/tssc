{smcl}

{title:Title}

{pstd}
{hi:flexpaneldid} {hline 1} Causal analysis of treatments with varying start dates and durations
{p_end}

{title:Syntax}

{p 4 25 2}
{cmd:flexpaneldid} {it:depvar}{cmd:,}
{cmd:id(}{it:varname}{cmd:)} 
{cmd:treatment(}{it:varname}{cmd:)} 
{cmd:time(}{it:varname}{cmd:)} 
{cmd:prepdataset(}{it:string}{cmd:)}
{break}
{cmd:statmatching(}{it:con(varlist) cat(varlist)}{cmd:)} [{cmd:ties} {cmd:radius(}{it:float}{cmd:)}]
{break}
{cmd:cemmatching(}{it:varname1 [(cutpoints1)] [varname2 [(cutpoints2)]...]} {cmd:[k2k])} 
{break} 
{cmd:outcometimerelstart(}{it:integer}{cmd:)} {cmd:outcometimerelend(}{it:integer}{cmd:)}
{break}
{cmd:[outcomedev(}{it:integer [integer]}{cmd:)} {cmd:test didmodel outcomemissing}{cmd:]}
{p_end}


{synoptset 30 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}
{synopt:{opt id(varname)}}name of the panel id variable{p_end}
{synopt:{opt treatment(varname)}}name of the treatment variable{p_end}
{synopt:{opt time(varname)}}name of the time variable{p_end}
{synopt:{opt prepdataset(filename)}}filename where preprocessed dataset is stored{p_end}

{syntab:Distance metric}
{synopt:{opt statmatching()}}use statistical distance function for matching{p_end}
{synopt:or}{p_end}
{synopt:{opt cemmatching()}}use {it:Coarsened Exact Matching} {help cem}{p_end}

{syntab:Outcome development}
{synopt:{opt outcometimerelstart()}}end of observed outcome development related to treatment start{p_end}
{synopt:or}{p_end}
{synopt:{opt outcometimerelend()}}end of observed outcome development related to treatment end{p_end}

{synopt:{opt outcomedev(int [int])}}pre treatment outcome level[development] is included in the matching{p_end}
{synopt:{opt test}}quality tests after matching{p_end}
{synopt:{opt didmodel}}robustness checks on standard two-way DID model{p_end}
{synopt:{opt outcomemissing}}disables a check if {it:depvar} is observable for the defined outcome development period{p_end}

{synoptline}


{title:Description}

{pstd}
{cmd:flexpaneldid} is a Stata package for causal analysis of treatments with varying start dates and varying treatment durations within panel data with more than two observation times. It consists of two commands based on each other, 
{cmd:flexpaneldid_preprocessing} and 
{cmd:flexpaneldid}. In  
{cmd:flexpaneldid_preprocessing}, the original data set is rearranged in that individual selection groups for every treated unit are created which contain all potential controls. The result of this preprocessing is a temporary dataset with information that are crucial for the use of {cmd:flexpaneldid}.
{p_end}

{pstd}
Based on the temporary data set, 
{cmd:flexpaneldid} estimates the average treatment effect for the treated. For this step, different matching approaches are available. Additionally, quality and robustness checks can be conducted.
{p_end}

{pstd}
The flexpaneldid package requires the installation of the Stata ado-files psmatch2, pstest and cem, which are used in the {cmd:flexpaneldid} command.
{p_end}

{pstd}
If you want to be able to replicate your results you should set {help seed} before calling {cmd:flexpaneldid}.


{title:Arguments}

{dlgtab:Main}

{phang}
{it:depvar} variable defines the analyzed outcome; input must be numerical.

{phang}
{opt id(varname)} uniquely identifies objects in the panel dataset. The variable must be an integer or string.

{phang}
{opt treatment(varname)} contains the variable defining the treatment. Input must be in 0-1 format.
{break}
IMPORTANT NOTE: The variable must equal to one for the whole treatment phase. In case of repeated treatments for one unit (identified by a unique id), the repeated treatments are handled as one treatment phase. 

{phang}
{opt time(varname)} identifies the time information in the panel. Input must be an integer indicating an absolute time, e. g. year, month, quarter.
{break}
IMPORTANT NOTE: If the data contain only information in date-format, this information must be converted into an integer.

{phang}
{opt prepdataset(string)} specifies the path where the preprocessing data set is stored. The information in this data is crucial for the use of the {cmd:flexpaneldid}.

{dlgtab:Options}

{pstd}
One of the following two options for the distance metric for matching must be selected: 

{phang}
{opt statmatching(con(varlist) cat(varlist)} indicates that a statistical distance function is used for matching. The variable names included in {it}con(varlist) {sf} indicate the continuous matching variables, which must be numerical variables;
{it:cat(varlist)} contains the categorical variables, which must be integers. 
{break}
The default matching algorithm is a nearest neighbor matching with replacement (and refers to {cmd:psmatch2,} {cmd:neighbor(}{it:1}{cmd:)} {cmd:pscore(}{it:statistical distance}{cmd:)}). Alternatively, one can chose between the options {opt ties}
and
{opt radius(float)}. Option {opt ties} means that if more than one nontreated is the best partner for a treated observation, the counterfactual outcome is constructed using all nontreated with equal distance. Option {opt radius(float)} indicates that all nontreated within the defined radius are used to construct the counterfactual outcome. The defined radius must be a float number in the range between 0 and 1. 

{phang}
{opt cemmatching(varname1 [(cutpoints1)] [varname2 [(cutpoints2)] ... ])} indicates that the {it:Coarsened Exact Matching} will be executed. Like in the {cmd:cem} command, including cutpoints for the matching variables is possible, either formats 
{it:(#integer)}
or
{it:(numlist)} are allowed. Using option {opt k2k} creates matched strata with equal numbers of treated and controls.
{break}
See Blackwell et al. (2009) for more details on the {cmd:cem} command.

{pstd}
The command enables the user to define the period of outcome development that should be compared between treated and controls. (The starting point of the observed development coincides to the start of the treatment.) 
One of the two options must be selected:

{phang}
{opt outcometimerelstart(integer)} is a relative time specification that defines the end of the outcome development in relation to the treatment start. In case of repeated treatments, the relative time refers to the start of the first treatment.
{break}
IMPORTANT NOTE: The dimension of the parameter in parentheses depends on the dimension that is defined for {opt time}.
{break}
For example, {opt outcometimerelstart(3)} means we observe the outcome development from the individual treatment start to three years after the start of the treatment, if the dimension of the time variable is years.

{phang}
{cmd:outcometimerelend(}{it:integer}{cmd:)} is a relative time specification that defines the end of the outcome development in relation to the treatment end. In case of repeated treatments, the relative time refers to the end of the last treatment.
{break}
IMPORTANT NOTE: The dimension of the parameter in parentheses depends on the dimension that is defined for {opt time}.
{break}
For example, {opt outcometimerelend(2)} means we compare the outcome development from the treatment start to two years after the treatment is finished, if the dimension of the time variable is years.
 
{pstd}
There are two possibilities for considering the pre-treatment outcome in the matching process:

{phang}
{opt outcomedev(integer)} selects the level value of the outcome at a time defined in relation to the treatment start. 
{opt outcomedev(integer integer)} defines the outcome development, the two integers give the start and the end of the development in relation to the treatment start.
{break}
IMPORTANT NOTES: The dimension of the parameter in parentheses depends on the dimension that is defined for {cmd:time}. 
Both parameters are required to be integer <= 0. For example, 
{opt outcomedev(-3 -1)} means the outcome development from three to one year(s) before the individual treatment starts is considered for matching, if the dimension of the time variable is years. 
{opt outcomedev(-3)} considers the outcome level three years before treatment starts as additional matching variable.

{phang}
{opt test} executes quality tests after matching. The tests conducted in {cmd:pstest} and {it:quantile-quantile plots} are presented.
Further tests are presented depending on the matching process that is selected: For 
{opt cemmatching()} additionally the overall imbalance measure L1 and univariate imbalance measures are displayed. For 
{opt statmatching()}, {it:KS-tests} for continuous variables and {it:chi-square tests} for the categorical variables are executed in addition.

{phang}
{opt didmodel} is an option for robustness checks on the basis of a standard two-way DID model. The first model mimics the 2x2 case (two groups and two observation times) in a fixed effects model, namely the treatment start and the end of the defined period of outcome development. The second model is a canonical fixed effects DID model with standard errors allowing for intragroup correlations. The observation period is trimmed at the defined end of the outcome development. (Both models are estimated using {cmd:xtreg}. The exact specification of the models is given in the output.)
{break}
IMPORTANT NOTE: Since both models are based on the assumption of homogeneous effects, they should be used as robustness checks only, but not as standalone estimations.  

{phang}
{opt outcomemissing} disables a (default) check if the 
{it:depvar} is observable for the defined period of outcome development before matching is performed. Disabling the check will result in the best control group in terms of comparability, but will reduce the sample size for the estimation.


{title:Output}

{synoptset 30 tabbed}{...}
{synopt:{cmd:id}}id variable as defined in {cmd:id()} option{p_end}
{synopt:{cmd:treatment}}treatment variable as defined in {cmd:treatment()} option{p_end}
{synopt:{cmd:first_treatment}}first treatment time of treated and it's matched control{p_end}
{synopt:{cmd:last_treatment}}last treatment time of treated and it's matched control{p_end}
{synopt:{cmd:nt_multi_select}}number of assignments for multiple assigned controls; for controls assigned only once, this variable contains a missing{p_end}
{synopt:{cmd:time}}time variable as defined in {cmd:time()} option{p_end}
{synopt:{cmd:outcome}}outcome variable as defined in {cmd:depvar}{p_end}
{synopt:{cmd:panel_id}}panel identifier for internal use{p_end}
{synopt:{cmd:post_treat_dummy}}dummy variable indicating the observations after treatment{p_end}
{synopt:{cmd:post_treat_dummy_rel_time}}variable indicating relative time after treatment{p_end} 


{title:Stored reslts}

{pstd}{cmd:flexpaneldid} saves the following in {cmd:r()}:

{synoptset 30 tabbed}{...}
{p2col 5 20 25 2: Scalars}{p_end}
{synopt:{cmd:r(num_treated)}}number of unique treated{p_end}
{synopt:{cmd:r(num_controls)}}number of unique controls{p_end}
{synopt:{cmd:r(num_mean_matches)}}mean number of controls per treated{p_end}
{synopt:{cmd:r(mean_dif_treated)}}mean development of {it:depvar} for the treated{p_end}
{synopt:{cmd:r(mean_dif_controls)}}mean development of {it:depvar} for the controls{p_end}
{synopt:{cmd:r(did)}}mean difference in {it:depvar} development between treated and controls{p_end}
{synopt:{cmd:r(se)}}AI robust standard error{p_end}
{synopt:{cmd:r(z)}}z-value{p_end}
{synopt:{cmd:r(p)}}p-value{p_end}

{p2col 5 20 25 2: Strings}{p_end}
{synopt:{cmd:r(outcome_var)}}varname of {it:depvar}{p_end}
{synopt:{cmd:r(estimator)}}estimator{p_end}
{synopt:{cmd:r(metric)}}distance metric{p_end}


{title:Example}

{pstd}Preprocessing{p_end}

{phang}{cmd: . use flexpaneldid_example_data.dta, clear}{p_end}
{phang}{cmd: . flexpaneldid_preprocessing, id(cusip) treatment(treatment) time(year) matchvars(employ stckpr rnd sales return pats_cat rndstck_cat rndeflt_cat) matchtimerel(-1) matchvarsexact(sic_cat) prepdataset("preprocessed_data.dta") replace} {p_end}

{pstd}flexpaneldid{p_end}

{phang}{cmd: . use flexpaneldid_example_data.dta, clear}{p_end}
{phang}{cmd: . flexpaneldid patents, id(cusip) treatment(treatment) time(year) statmatching(con(employ stckpr rnd sales) cat(pats_cat rndstck_cat)) outcometimerelstart(3) outcomedev(-2 -1) test prepdataset("preprocessed_data.dta")} {p_end}


{title:Also see}

{pstd}
{help flexpaneldid_preprocessing}, {help psmatch2}, {help cem}
{p_end}


{title:Authors}

{pstd}Eva Dettmann, Halle Institute for Economic Research (IWH), eva.dettmann@iwh-halle.de{p_end}

{pstd}Alexander Giebler, Halle Institute for Economic Research (IWH), alexander.giebler@iwh-halle.de{p_end}

{pstd}Antje Weyh, Institute for Employment Research (IAB), antje.weyh@iab.de


{title:References}

{phang}
Blackwell, M.; Iacus, S.; King, G.; Porro, G. (2009): cem: Coarsened exact matching in Stata. The Stata Journal 9 (4), pp. 524-546. 

{phang}
Leuven, E.; Sianesi, B. (2003): PSMATCH2: Stata module to perform full Mahalanobis and propensity score matching, common support graphing, and covariate imbalance testing. Techinical report, University of Oslo.
{break}
http://ideas.repec.org/c/boc/bocode/s432001.html


{title:Thanks for citing the toolbox as follows}

{pstd}
E. Dettmann, A. Giebler and A. Weyh. (2020). flexpaneldid. A Stata toolbox for causal analysis with varying treatment time and duration.
{break}
https://ideas.repec.org/p/zbw/iwhdps/32020.html
{p_end} 
