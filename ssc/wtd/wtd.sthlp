{smcl}
{* 30jun2006}{...}
{hline}
help for {hi:wtd}
{hline}

{title:Analysis of Waiting Time Distribution}

{p 4 4 2}
{cmd:wtd}

{title:Description}

{p 4 4 2}
The term wtd refers to Waiting Time Distribution data and the commands
for analyzing them, all of which begins with the letters wtd. For a
description of the Waiting Time Distribution concept, please refer to
Støvring and Vach (2005).  Estimation of prevalence
and incidence based on occurrence of health-related events.
{it:Stat Med} 2005; 24:3139-54.

{p 4 4 2} In short, the concept of the Waiting Time Distribution
allows estimation of incidence and prevalence of for example drug use,
based exclusively on occurrence of health-related events, in this case
individual drug redemptions from pharmacies. Another example is
incidence and prevalence of hypertension treatment based on occurrence
of hypertension related consultations with physicians.

{p 4 4 2} Consider for example redemption of oral antidiabetics. This
class of drugs is known to be a good indicator for treatment of type
II diabetes. The approach of the Waiting Time Distribution can then be
used to estimate the prevalence and incidence of treated type II
diabetes in a given population. The procedure can allow for
information on migration and survival if such data are available along
with data on individual redemptions of oral antidiabetics. The Waiting
Time Distribution has a characteristic shape which arise from only
considering the first event for each individual in a given time
window.

{p 4 4 2}
The first step to analyzing Waiting Time Distribution data is to
{cmd:wtdset} it. Then you can use any of the other wtd commands. This
is analogous to the {cmd:st} commands for survival time data, see help
{help st}. The wtd commands are

{p 8 24 2}{help wtdset}{space 4} Declare data to be
Waiting Time Distribution data.

{p 8 24 2}{help wtd}{space 7} Short descriptive table of the wtd data
currently in memory, cf. help {help wtdset}.

{p 8 24 2}{help wtdml}{space 5} Perform Maximum-likelihood estimation.

{p 8 24 2}{help wtddiag}{space 3} Diagnostic plots of observed waiting time
distribution

{p 8 24 2}{help wtdq}{space 6} Q-Q-plot of fitted versus empirical
Waiting Time Distribution.


{title:Remarks}

{p 4 4 2} For a detailed description of the Waiting Time Distribution
concept, please refer to 

{p 8 8 2} Støvring and Vach (2005). Estimation of
prevalence and incidence based on occurrence of health-related events.
{it:Stat Med} 2005; 24:3139-54.

{title:Author}

{p 4 4 2} {browse "http://www.biostat.sdu.dk/~stovring":H. Støvring},
Research Unit of General Practice, University of Southern Denmark.
Please email
{browse "mailto:hstovring@health.sdu.dk":hstovring@health.sdu.dk} if you have
comments, questions or observe any problems.


{title:Also see}


{p 0 19}On-line:  help for {help wtdset}; {help st}, {help ml}{p_end}
