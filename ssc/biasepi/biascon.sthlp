
{smcl}
{* 19April2019}{...}
{cmd:help biascon}{right:({browse "http://medical-statistics.dk/MSDS/epi/bias/bias.html":Quantitative Bais Aanlysis in Epidemiology})}
{hline}

{title:Title}

{p 4 4 2}{hi:biascon} {hline 2} performs {it:bias analysis} for unmeasured and/or unknown confounder


{title:Syntax}

{p 4 4 2}
{cmd:biascon}
{it:depvar indepvar}
{ifin}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt p0(#)}}the prevalence of the confounder among the unexposed and the default is 0.43{p_end}
{synopt :{opt p1(#)}}the prevalence of the confounder among the exposed and the default is 0.42{p_end}
{synopt :{opt effect0(#)}}the association between the confounder and the outcome among those who were not exposed and the default is 1.5{p_end}
{synopt :{opt effect1(#)}}the association between the confounder and the outcome among those who were exposed and the default equals to the {it:effect0} {p_end}
{synopt :{opt type:effect(#)}}the type of confounder-outcome association. 1: {it:risk ratio} which is the default; 2: {it:odds ratio}, and 3: {it:risk difference}{p_end}
{synopt :{opt gen:erate}}generate {it:newvar} containing the {it:predicted} binary confounding variable for each individual;{p_end}
{synopt :{opt seed}}specifies the initial value of the random-number {helpb seed};{p_end}
{synoptline}

{p 4 4 2}
{cmd:biasconi}
{it:a b c d}
{ifin}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt p0(#)}}the prevalence of the confounder among the unexposed and the default is 0.43{p_end}
{synopt :{opt p1(#)}}the prevalence of the confounder among the exposed and the default is 0.42{p_end}
{synopt :{opt effect0(#)}}the association between the confounder and the outcome among those who were not exposed and the default is 1.5{p_end}
{synopt :{opt effect1(#)}}the association between the confounder and the outcome among those who were exposed and the default equals to the {it:effect0} {p_end}
{synopt :{opt type:effect(#)}}the type of confounder-outcome association. 1: {it:risk ratio} which is the default; 2: {it:odds ratio}, and 3: {it:risk difference}{p_end}
{synoptline}

{title:Description}

{pstd}
Command {helpb biascon}, which is one of the command among the package {helpb biasepi}, performs {it:bias analysis} for unmeasured and unknown confounders.{p_end}
{pstd}
Combining the three commands ({helpb biasselect}, {helpb biascon}, {helpb biasmis}) is able to perform {it:multiple bias modelinging}. 
Combining the existing Stata commands for probalistic distributions, {helpb biascon} is able to perform {it: probalistic bias analysis}



{title:Options} 

{phang}
{opt p0} the prevalence of the confounder among the unexposed and the default is 0.43

{phang}
{opt p1} the prevalence of the confounder among the exposed and the default is 0.42

{phang}
{opt effect0} the association between the confounder and the outcome among those who were not exposed and the default is 1.5.

{phang}
{opt effect1} the association between the confounder and the outcome among those who were exposed. The default is {it:effect1}={it:effect0}, which indicates there is no effect modification.

{phang}
{opt typeeffect} the type of association between the confounder and outcome. 1: {it:risk ratio} which is the default; 2: {it:odds ratio}, and 3: {it:risk difference}

{title:Examples}

{pstd}

{phang}1. Simple bias analysis for unknown confounder, given the assocation between the confounder-outcome is risk ratio {p_end}
{phang}{stata "biasconi 232 133 4677 6031, p0(0.4325) p1(0.4247) effect0(1.51) typeeffect(1)": .biasconi 232 133 4677 6031, p0(0.4325) p1(0.4247) effect0(1.51) typeeffect(1)} {p_end}

{phang}2. Simple bias analysis for unknown confounder, given the assocation between the confounder-outcome is odds ratio: {p_end}
{phang}{stata "biasconi 232 133 4677 6031, p0(0.4325) p1(0.4247) effect0(1.53) typeeffect(2)": .biasconi 232 133 4677 6031, p0(0.4325) p1(0.4247) effect0(1.53) typeeffect(2)} {p_end}

{phang}3. Simple bias analysis for unknown confounder, given the assocation between the confounder-outcome is risk difference: {p_end}
{phang}{stata "biasconi 232 133 4677 6031, p0(0.4325) p1(0.4247) effect0(0.0137) typeeffect(3)": .biasconi 232 133 4677 6031, p0(0.4325) p1(0.4247) effect0(0.0137) typeeffect(3)} {p_end}


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
{cmd:biascon} and {cmd:biasconi} store the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(cRR)}}Observed risk ratio{p_end}
{synopt:{cmd:r(cOR)}}Observed odds ratio {p_end}
{synopt:{cmd:r(cRD)}}Observed risk difference{p_end}
{synopt:{cmd:r(RR_c1)}}Corrected risk ratio among the strata confounder=1{p_end}
{synopt:{cmd:r(OR_c1)}}Corrected odds ratio among the strata confounder=1{p_end}
{synopt:{cmd:r(RD_c1)}}Corrected risk difference among the strata confounder=1{p_end}
{synopt:{cmd:r(RR_c0)}}Corrected risk ratio among the strata confounder=0{p_end}
{synopt:{cmd:r(OR_c0)}}Corrected odds ratio among the strata confounder=0{p_end}
{synopt:{cmd:r(RD_c0)}}Corrected risk difference among the strata confounder=0{p_end}
{synopt:{cmd:r(mhRR)}}The Mantel Haenszel Method: risk ratio {p_end}
{synopt:{cmd:r(mhOR)}}The Mantel Haenszel Method: odds ratio{p_end}
{synopt:{cmd:r(mhRD)}}The Mantel Haenszel Method of Greenland and Robins: risk difference{p_end}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(O)}}Observed 2*2 table{p_end}
{synopt:{cmd:r(C1)}}2*2 table among the strata confounder=1{p_end}
{synopt:{cmd:r(C0)}}2*2 table among the strata confounder=0{p_end}
{synopt:{cmd:r(R)}}RR, OR, and RD{p_end}
{synopt:{cmd:r(P)}}Probabilities of confounder variable for the 2*2 table {p_end}


