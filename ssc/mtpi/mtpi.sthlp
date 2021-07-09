{smcl}
{* *! version 1.0 14 Jul 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "mtpi##syntax"}{...}
{viewerjumpto "Description" "mtpi##description"}{...}
{viewerjumpto "Options" "mtpi##options"}{...}
{viewerjumpto "Remarks" "mtpi##remarks"}{...}
{viewerjumpto "Examples" "mtpi##examples"}{...}
{title:Title}
{phang}
{bf:mtpi} {hline 2} A command for the modified Toxicity Probability Interval design

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:mtpi}
[{help varlist}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt ep1(#)}}  specifies the lower bound of the interval around the TTL that is safe.

{pstd}
{p_end}
{synopt:{opt ep2(#)}}  specifies the upper bound of the interval around the TTL that is safe.

{pstd}
{p_end}
{synopt:{opt safe1(#)}}  specifies the safety cutoff for declaring the lowest dose to be safe.

{pstd}
{p_end}
{synopt:{opt safe2(#)}}  specifies the safety cutoff for declating the dose to be safe.

{pstd}
{p_end}
{synopt:{opt ttl(#)}}  specifies the target toxicity level that defines the maximum tolerated dose.

{pstd}
{p_end}
{synopt:{opt simn(#)}}  specifes the number of simulations used

{pstd}
{p_end}
{synopt:{opt sampsize(#)}}  specifies the sample size of each trial in the simulations.

{pstd}
{p_end}
{synopt:{opt csize(#)}}  specifies the cohort size used in the trial. 

{pstd}
{p_end}
{synopt:{opt startdose(#)}}  specifies the starting dose. 

{pstd}
{p_end}
{synopt:{opt priora(#)}}   specifies the a parameter of the prior Beta distribution.

{pstd}
{p_end}
{synopt:{opt priorb(#)}}  specifies the a parameter of the prior Beta distribution.

{pstd}
{p_end}
{synopt:{opt truep(numlist ascending  >=0  <=1)}}  specifies a vector of true probabilities of DLT for each dose level.

{pstd}
{p_end}
{synopt:{opt decisiontable}}  specifies that the single cohort decision rules be displayed as a lookup table.

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
The modified Toxicity Probability Interval design is an attempt to implement a method
that is as simple as a 3+3 decision but based on statistical distributions rather
than a pure rule-based approach. This method produces decision making tables for the fully
trial so a statistician need not be involved in all the dose escalation decisions.

{pstd}
The command {cmd:mtpi} performs simulations to find the operating characteristics alongside
the decision matrix given a sample size and number of DLTs.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt ep1(#)}     specifies the lower bound of the interval around the TTL that is safe.

{pstd}
{p_end}
{phang}
{opt ep2(#)}     specifies the upper bound of the interval around the TTL that is safe.

{pstd}
{p_end}
{phang}
{opt safe1(#)}     specifies the safety cutoff for declaring the lowest dose to be safe.

{pstd}
{p_end}
{phang}
{opt safe2(#)}     specifies the safety cutoff for declating the dose to be safe.

{pstd}
{p_end}
{phang}
{opt ttl(#)}     specifies the target toxicity level that defines the maximum tolerated dose.

{pstd}
{p_end}
{phang}
{opt simn(#)}     specifes the number of simulations used

{pstd}
{p_end}
{phang}
{opt sampsize(#)}     specifies the sample size of each trial in the simulations.

{pstd}
{p_end}
{phang}
{opt csize(#)}     specifies the cohort size used in the trial. 

{pstd}
{p_end}
{phang}
{opt startdose(#)}     specifies the starting dose. 

{pstd}
{p_end}
{phang}
{opt priora(#)}      specifies the a parameter of the prior Beta distribution.

{pstd}
{p_end}
{phang}
{opt priorb(#)}     specifies the a parameter of the prior Beta distribution.

{pstd}
{p_end}
{phang}
{opt truep(numlist ascending  >=0  <=1)}     specifies a vector of true probabilities of DLT for each dose level.

{pstd}
{p_end}
{phang}
{opt decisiontable}     specifies that the single cohort decision rules be displayed as a lookup table.

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
The basic command will do a simulation

{pstd}
 {stata mtpi}

{pstd}
The results show a table of each dose level with the true probabilities of a DLTs
 and the proportion of time those doses are recommended, experimented 
on and how many DLTs were observed on average.


{title:References}
{pstd}

{pstd}
Yuan Ji, Ping Liu, Yisheng Li and NB Bekele (2010) A modified toxicity probability
 interval method for dose-finding trials. Clin. Trials 7(6) 653-663.


{title:Author}
{p}

Prof Adrian Mander, Cardiff University.

Email {browse "mailto:mandera@cardiff.ac.uk":mandera@cardiff.ac.uk}



{title:See Also}
Related commands:

{help crm} (if installed)  {stata ssc install crm} (to install this command)

