{smcl}
{* *! version 1.3.2 30aug2017}{...}
{* *! version 1.1 27may2015}{...}
{vieweralsosee "mvmeta (if installed)" "mvmeta"}{...}
{vieweralsosee "metareg (if installed)" "metareg"}{...}
{viewerjumpto "Syntax" "network##syntax"}{...}
{viewerjumpto "Description" "network##description"}{...}
{viewerjumpto "Data formats" "network##formats"}{...}
{viewerjumpto "Features of interest to methodologists" "network##formethodologists"}{...}
{viewerjumpto "Troubleshooting and limitations" "network##limitations"}{...}
{viewerjumpto "Examples" "network##examples"}{...}
{viewerjumpto "References" "network##refs"}{...}
{viewerjumpto "Changes from version 1.2.x to version 1.5" "network##whatsnew"}{...}
{viewerjumpto "Future developments" "network##future"}{...}
{viewerjumpto "Author and updates" "network##updates"}{...}
{title:Title}


{phang}
{bf:network} {hline 2} Suite of commands for network meta-analysis


{title:Syntax}{marker syntax}

Get started

{col 7}{bf:{help network_setup:network setup}}{...}
{col 30}set up data from arm-specific counts

{col 7}{bf:{help network_import:network import}}{...}
{col 30}import data set of pairwise comparisons 

Descriptive tables and figures

{col 7}{bf:{help network_table:network table}}{...}
{col 30}tabulate data

{col 7}{bf:{help network_pattern:network pattern}}{...}
{col 30}pattern of network

{col 7}{bf:{help network_map:network map}}{...}
{col 30}map of network

Utilities

{col 7}{bf:{help network_convert:network convert}}{...}
{col 30}convert data between formats

{col 7}{bf:{help network_query:network query}}{...}
{col 30}display network settings

{col 7}{bf:{help network_unset:network unset}}{...}
{col 30}delete network settings (rarely needed)

Analyses

{col 7}{bf:{help network_meta:network meta}}{...}
{col 30}perform network meta-analysis

{col 7}{bf:{help network_rank:network rank}}{...}
{col 30}rank treatments after network meta-analysis 

{col 7}{bf:{help network_sidesplit:network sidesplit}}{...}
{col 30}fit side-splitting (node-splitting) model(s)

{col 7}{bf:{help network_compare:network compare}}{...}
{col 30}tabulate all comparisons estimated from the network

Graphs of results

{col 7}{bf:{help network_forest:network forest}}{...}
{col 30}forest plot


{marker description}{...}
{title:Description}

{pstd}
{cmd:network} is a suite of programs for 
importing data for network meta-analysis,
running a contrast-based network meta-analysis using {help mvmeta} or {help metareg},
assessing inconsistency,
and graphing the data and results. 
The data in each arm of each study are assumed to be available 
either as binomial counts (successes/total) 
or as mean, standard deviation and number of individuals for a quantitative variable.

{pstd}
{cmd:network} is primarily aimed to simplify the task of data analysis.
However, it also has several features of interest to methodologists: 
see {help network##formethodologists:Features of interest to methodologists}.


{marker formats}{...}
{title:Data formats}

{pstd}Three data formats are available. 
They are most easily illustrated in the context of a network meta-analysis involving treatments A, B and C, 
with A as reference and using default variable naming.

{pstd}In format {cmd:augmented}, the data are the contrasts of each treatment with the reference treatment.
Thus _y_B compares B with A, while _y_C compares C with A.
In any trial which does not include a reference treatment arm, 
such an arm is created ("augmented") to contain a very small amount of data.

{pstd}In format {cmd:standard}, the data are contrasts with each trial's baseline treatment. 
Thus _y_1 compares each trial's 2nd treatment with its first: _y_1 compares B with A in an A-B trial and C with B in a B-C trial.
An A-B-C trial would be represented by _y_1 (B vs. A) and _y_2 (C vs. A).

{pstd}In format {cmd:pairs}, the data are all possible contrasts between the trial's treatments.
Thus a two-arm B-C trial is represented by a single record _y (C vs. B),
while a three-arm, A-B-C trial is represented by three records comparing B vs. A, C vs. A and C vs. B.


{marker formethodologists}{...}
{title:Features of interest to methodologists}

{pstd}{cmd:network} makes it easy to show that results using the "augmented" data format are 
numerically almost identical to results using the "standard" data format 
(and also to results using the "pairs" data format, in the absence of multi-arm trials).
It also makes it easy to show that results are not affected by choice of reference category.

{pstd}{cmd:network sidesplit} introduces a small modification to the procedure of {help network##Dias++10:Dias et al}.
This makes side-splitting symmetrical even in the presence of multi-arm trials
(that is, splitting A vs. B gives the same model as splitting B vs. A).

{pstd}{cmd:network forest} offers a new data display which generalises the forest plot for pairwise meta-analysis.


{marker limitations}{...}
{title:Troubleshooting and limitations}

{pstd}{cmd:network} can handle only up to about 90 treatments.
This is because of the large number of variables required in augmented format.
{cmd:network setup} is not currently able to set the data up directly in other formats,
but goes via augmented format.

{pstd}I-squared is not usually available after {cmd:network meta}.
Although {cmd:mvmeta}'s {cmd:i2} option can be called, it usually fails because of network sparsity. 
We are working on a suitable I-squared measure for network meta-analysis.

{pstd}If a full forest plot is drawn, 
then the inconsistency model must be the last mvmeta model fitted: 
that is, neither {cmd:network sidesplit} nor {cmd:network meta, c} 
must have been fitted since {cmd:network meta, i}.

{pstd}{cmd:network map} gives poor results if a monochrome color scheme is used. 
Try {cmd:set scheme s2color}.

{pstd}Unlike other commands, {cmd:network table} orders the treatments in alphabetical order of their names, 
not of their codes.

{pstd}{cmd:network rank} and {cmd:network sidesplit} only work when the data are in augmented format.

{pstd}A page of frequently asked questions is available at {browse "http://www.homepages.ucl.ac.uk/~rmjwiww/stata/meta/networkFAQs.htm"}.


{marker examples}{...}
{title:Examples}

{pstd}Load the {ul:smoking data}

{pin}. {stata "use http://www.homepages.ucl.ac.uk/~rmjwiww/stata/meta/smoking, clear"}

{pin}. {stata "network setup d n, studyvar(stud) trtvar(trt)"}

{pstd}Draw a network graph using {help networkplot} if installed 

{pin}. {stata "network map"}

{pstd}Fit consistency model

{pin}. {stata "network meta c"}

{pstd}Rank treatments, noting that larger treatment effects indicate better treatments

{pin}. {stata "network rank max"}

{pstd}Fit inconsistency model

{pin}. {stata "network meta i"}

{pstd}Forest plot of results, adding a title and reducing the square size from its default of *0.2

{pin}. {stata "network forest, title(Smoking network) msize(*0.15)"}

{pstd}Explore inconsistency by side-splitting

{pin}. {stata "network sidesplit all"}


{pstd}Load the {ul:thrombolytics data}

{pin}. {stata "use http://www.homepages.ucl.ac.uk/~rmjwiww/stata/meta/thromb.dta, clear"}

{pin}. {stata "network setup r n, studyvar(study) trtvar(treat)"}

{pstd}Draw a network map using {help networkplot} if installed 

{pin}. {stata "network map"}

{pstd}Improve this map

{pin}. {stata "network map, improve"}

{pin}. {stata "network map, triangular(5) improve"}

{pstd}Fit consistency model

{pin}. {stata "network meta c"}

{pstd}Rank treatments using a rankogram, 
noting that smaller treatment effects indicate better treatments

{pin}. {stata "network rank min, line cumul"}

{pstd}Fit inconsistency model

{pin}. {stata "network meta i"}

{pstd}Forest plot of results, adding titles, using a hollow plotting symbol, 
and reducing the size of the text labelling the contrasts

{pin}. {stata "network forest, xtitle(Log odds ratio and 95% CI) title(Thrombolytics network) msym(Sh) contrastopt(mlabsize(small))"}

{pstd}Explore inconsistency by side-splitting

{pin}. {stata "network sidesplit all"}


{title:Details}{marker details}

{p 0 0 0}
Various parts of the network suite require the additional program {help mvmeta}.

{p 0 0 0}
In pairs format, {cmd:network meta} requires the additional program {help metareg}.

{p 0 0 0}
{cmd:network map} requires the additional program {help networkplot}.


{title:Known problems}{marker problems}

{p 0 0 0}With large numbers of treatments, you may run into memory problems.
Please try increasing {help maxvar} and {help matsize} if your version of Stata allows you to do so.
The problem arises with augmented format and I hope to find a workaround in future. 

{p 0 0 0}Please report any other problems to ian.white@ucl.ac.uk.


{title:Changes from version 1.2.1 to version 1.5}{marker whatsnew}

{p 0 0 0}I have made some bug fixes and minor improvements to {help  network setup}, {help  network meta} and {help  network forest}.

{p 0 0 0}{help  network compare} may be run after {cmd:network meta consistency}.
It outputs a table of all comparisons estimated from the network.

{p 0 0 0}{help  network setup} assesses the network to see whether it is disconnected.


{title:Future developments}{marker future}

{p 0 0 0}{cmd:network bayes} (currently under test) writes WinBUGS models,
runs WinBUGS and reads the MCMC samples back into Stata.

{p 0 0 0}{cmd:network import} from standard format.


{title:References}{marker refs}

{phang}{marker Dias++10}
Dias S, Welton NJ, Caldwell DM, Ades AE. 
Checking consistency in mixed treatment comparison meta-analysis.
Statistics in Medicine 2010;29:932-944.
{browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.3767/abstract"}

{phang}{marker Higgins++12}Higgins JPT, Jackson D, Barrett JL, Lu G, Ades AE, White IR. 
Consistency and inconsistency in network meta-analysis: 
concepts and models for multi-arm studies. 
Research Synthesis Methods 2012; 3: 98-110.
{browse "http://onlinelibrary.wiley.com/doi/10.1002/jrsm.1044/abstract"}

{phang}{marker LuAdes06}Lu G, Ades AE. 
Assessing evidence inconsistency in mixed treatment comparisons. 
Journal of the American Statistical Association 2006; 101: 447-459.
{browse "http://amstat.tandfonline.com/doi/abs/10.1198/016214505000001302"}

{phang}{marker Salanti++11}Salanti G, Ades A, Ioannidis J. 
Graphical methods and numerical summaries for presenting results from multiple-treatment meta-analysis: 
an overview and tutorial. Journal of Clinical Epidemiology 2011; 64: 163-171.
{browse "http://www.ncbi.nlm.nih.gov/pubmed/20688472"}

{phang}{marker White09}White IR. Multivariate random-effects meta-analysis. 
Stata Journal 2009; 9: 40-56.
{browse "http://www.stata-journal.com/article.html?article=st0156"}

{phang}{marker White11}White IR. Multivariate random-effects meta-regression: Updates to mvmeta. 
Stata Journal 2011; 11: 255-270.
{browse "http://www.stata-journal.com/article.html?article=st0156_1"}

{phang}{marker White++12}White IR, Barrett JK, Jackson D, Higgins JPT. 
Consistency and inconsistency in network meta-analysis: 
model estimation using multivariate meta-regression.
Research Synthesis Methods 2012; 3: 111-125.
{browse "http://onlinelibrary.wiley.com/doi/10.1002/jrsm.1045/abstract"}

{phang}{marker WhiteThomas05}White IR, Thomas J. 
Standardised mean differences in individually-randomised and cluster-randomised trials, 
with applications to meta-analysis. 
Clinical Trials 2005; 2: 141-151.
{browse "http://ctj.sagepub.com/content/2/2/141.short"}


{title:Author and updates}{marker updates}

{p}Ian White, MRC Clinical  Trials Unit at UCL, London, UK. 
Email {browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}.

{p}You can get the latest version of this and my other Stata software using 
{stata "net from http://www.homepages.ucl.ac.uk/~rmjwiww/stata/"}.


{title:See Also}

{help mvmeta} (if installed)

{help metareg} (if installed)

Programs by Anna Chaimani: {stata "net from http://www.mtm.uoi.gr"}

