
{smcl}
{* 19April2019}{...}
{cmd:help biasmis}{right: ({browse "http://medical-statistics.dk/MSDS/epi/bias/bias.html":Quantitative Bais Aanlysis in Epidemiology})}
{hline}

{title:Title}

{p 4 4 2}{hi:biasmis} {hline 2} performs {it:bias analysis} for misclassification


{title:Syntax}

{p 4 4 2}
{cmd:biasmis}
{it:depvar indepvar}
{ifin}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt sa(#)}}Specify the sensitivity and the default is 0.75{p_end}
{synopt :{opt sb(#)}}Specify the specificity/sensitivity. The default is 0.95{p_end}
{synopt :{opt sc(#)}}Specify the sensitivity/specificity. The default is 0.75{p_end}
{synopt :{opt sd(#)}}Specify the specificity and the default value is 0.95{p_end}
{synopt :{opt mis:type(#)}}Specify the type of the misclassification. The default is 1, which indicates the exposure Misclassification{p_end}
{synopt :{opt gen:erate}}generate {it:newvar} containing the {it:predicted} binary true classification variable for each individual;{p_end}
{synopt :{opt seed}}specifies the initial value of the random-number {helpb seed};{p_end}
{synoptline}

{p 4 4 2}
{cmd:biasmisi}
{it:a b c d}
{ifin}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt sa(#)}}Specify the sensitivity and the default is 0.75{p_end}
{synopt :{opt sb(#)}}Specify the specificity/sensitivity. The default is 0.95{p_end}
{synopt :{opt sc(#)}}Specify the sensitivity/specificity. The default is 0.75{p_end}
{synopt :{opt sd(#)}}Specify the specificity and the default value is 0.95{p_end}
{synopt :{opt mis:type(#)}}Specify the type of the misclassification. The default is 1, which indicates the exposure Misclassification{p_end}
{synoptline}

{title:Description}

{pstd}
Command {helpb biasmis}, which is one of the command among the package {helpb biasepi}, performs {it:simple bias analysis} and {it:multidimensional bias analysis} for misclassification.{p_end}
{pstd}
Combining the three commands ({helpb biasselect}, {helpb biascon}, {helpb biasmis}) is able to perform {it:multiple bias modelinging}.
Combining the existing Stata commands for probalistic distributions, {helpb biascon} is able to perform {it: probalistic bias analysis}

{title:Options} 


{phang} 
{opt sa} {it:sa} is the sensitivity for the exposure among the cases when mistype=1. {it:sa} is the sensitivity for the cases among the exposed when mistype=2.

{phang} 
{opt sb} {it:sb} is the specificity for the unexposed among the cases when mistype=1. {it:sb} is the sensitivity for the cases among the unexposed when mistype=2. 

{phang} 
{opt sc} {it:sc} is the sensitivity for the exposure among the noncases when mistype=1. {it:sc} is the specificity for the noncases among the exposed when mistype=2.

{phang} 
{opt sd} {it:sd} is the specificity for the unexposure among the noncases when mistype=1. {it:sd} is specificity for the noncases among the unexposed when mistype=2.

{phang} 
{opt mistype} Specifies the type of misclassification: mistype=1 indicates {it:the exposure misclassification}, which is the default.
mistype=2 indicates {it:the outcome misclassification}.



{title:Examples}

{pstd}

{phang}1. Exposure misclassification:  {p_end}
{phang}{stata "biasmisi 232 133 4677 6031, sa(0.75) sb(0.95) sc(0.75) sd(0.95) mistype(1)": .biasmisi 232 133 4677 6031, sa(0.75) sb(0.95) sc(0.75) sd(0.95) mistype(1)} {p_end}


{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/epi/bias/bias.html":her}

{title:References} 

{phang}Lash, Timothy L., Fox, Matthew P., Fink, Aliza K. 2009.{p_end}
{phang}Applying Quantitative Bias Analysis to Epidemiologic Data {p_end}
{phang}{browse "https://sites.google.com/site/biasanalysis/": The online resource for the reference textbook.}


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}


{title:Also see}

{p 7 14 2}
Help: {helpb biasepi}, {helpb biasselect}, {helpb biascon}, {helpb biasmis}, {helpb biassurv}, {helpb biastab2}
{p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:biasmis} and {cmd:biasmisi} store the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(illegal)}}indicator for illegal value (0: no, 1:yes){p_end}
{synopt:{cmd:r(RR_Observed)}}Risk ratio for the observed 2*2 table{p_end}
{synopt:{cmd:r(OR_Observed)}}Odds ratio for the observed 2*2 table{p_end}
{synopt:{cmd:r(RD_Observed)}}Risk difference for the observed 2*2 table{p_end}
{synopt:{cmd:r(RR_Corrected)}}Risk ratio for the corrected 2*2 table{p_end}
{synopt:{cmd:r(OR_Corrected)}}Odds ratio for the corrected 2*2 table{p_end}
{synopt:{cmd:r(RD_Corrected)}}Risk difference for the corrected 2*2 table{p_end}
{p2colreset}{...}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(O)}}Observed 2*2 table{p_end}
{synopt:{cmd:r(SE)}}Stardard error for the observed 2*2 table{p_end}
{synopt:{cmd:r(C)}}Corrected 2*2 table{p_end}
{synopt:{cmd:r(P)}}probability to be corrected classification{p_end}
{synopt:{cmd:r(S)}}clasification table{p_end}


