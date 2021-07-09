{smcl}
{* Help file update 2020-05-03,2011-05-13}{...}
{hline}
help for {hi:bipolar}{right:A. Fusco, P. Van Kerm (May 2020, May 2011)}
{hline}

{title:Title}

{pstd}{hi:bipolar} {hline 2} Measures of (Income) Bi-polarization


{title:Syntax}

{p 8 15 2}
{cmd:bipolar}
{it:varname} 
[{it:weight}] 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
[{cmd:,} {it:options}]

{synoptset 22 tabbed}
{synopthdr}
{synoptline}
{synopt :{opt r:ankcut(#)}}specifies a cut-off rank to split population into high and low income groups; default is 0.5{p_end}
{synopt :{opt l:evelcut(#)}}specifies a cut-off income level to split population into high and low income groups{p_end}
{synopt :{opt pos:only}}restricts estimation to positive values of {it:varname}{p_end}
{synopt :{opth for:mat(%fmt)}}display format; default is {cmd:format(%4.3f)}{p_end}
{synoptline}

{p 4 8 2}
  {it:varlist} may contain time-series operators; see {help tsvarlist}.
{p_end}
{p 4 6 2}{cmd:bootstrap}, {cmd:jackknife}, {cmd:svy bootstrap}, and {cmd:svy jackknife} prefixes are allowed; see {help prefix}.{p_end}
{p 4 6 2}{cmd:fweight}, {cmd:aweight} and {cmd:pweight} are allowed; see help {help weights:weights}.
{p_end}


{title:Description}

{pstd}
{hi:bipolar} calculates measures of income bi-polarization.
{p_end}

{pstd} 
{hi:bipolar} takes a numeric variable as input (typically data on income) 
and reports the bi-polarization measures suggested by Foster and Wolfson (1992,2010),
Zhang and Kanbur (2001), and Deutsch et al. (2007). 
{p_end}
 
{pstd}
Bi-polarization measures attempt to capture how much a random variable is concentrated around two `poles' (high and low (income) groups): 
bi-polarization measures increase with the concentration of observations within the two poles/groups and 
with the separation between the poles/groups. 
Bi-polarization measures require the groups to be determined a priori, typically (but not necessarily) as above vs. below the median---leading to two equally-sized groups.   
See section 4.4 of the {hi:sgini} {browse "http://www.vankerm.net/stata/manuals/sgini.pdf":online manual} 
for details about formulas of the indices calculated by {cmd:bipolar}. More generally, see Nissanov et al (2010) and Duclos and Taptue (2014) for surveys on measures 
of income (bi-)polarization.
{p_end}

{pstd} 
{cmd:bipolar} does not provide sampling variance estimates (as an r-class command) but it is easily bootstrapped using 
a {cmd:bootstrap} or {svy bootstrap} prefix.  
{p_end}


{title:Options}

{phang}
{opt r:ankcut(#)} specifies a cut-off rank (0<#<1) to split population into high and low income groups. Measures
of bi-polarization typically consider a population split in two equal-sized groups, that is
use a rank of 0.5. This is the default for {hi:bipolar}. An alternative rank for splitting 
the population into unequal-sized groups can be specified with {opt r:ankcut(#)}. 
The Foster Wolfson index becomes however undefined in this case.
{p_end}

{phang}
{opt l:evelcut(#)}} specifies a cut-off income level to split population into high and low income groups
as an alternative to specify an income rank. Choosing an income cut-off typically leads to unequal-sized groups 
(unless the median is specified and there is no tied observations at the median). 
The Foster Wolfson index is then undefined. {opt r:ankcut(#)} and {opt l:evelcut(#)} are mutually exclusive.
{p_end}

{phang}
{opt pos:only} restricts estimation to positive values for {it:varname}. By default, 
all data are included in computations: {hi:bipolar} will not discard observations with 
negative or zero income.
{p_end}  

{phang}
{opth format(%fmt)} controls the display format; default is {cmd:format(%4.3f)}.
{p_end}


{title:Saved Results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(sum_w)}}sum of weights{p_end}
{synopt:{cmd:r(share_low)}}sample proportion in low income group{p_end}
{synopt:{cmd:r(cutpoint)}}value splitting low and high income groups{p_end}
{synopt:{cmd:r(Gini)}}overall Gini index{p_end}
{synopt:{cmd:r(GB)}}'Between Group' Gini{p_end}
{synopt:{cmd:r(GW)}}'Within Group' Gini{p_end}
{synopt:{cmd:r(ZK)}}Zhang and Kanbur (2001) index{p_end}
{synopt:{cmd:r(FW)}}Foster and Wolfson (1992, 2010) index{p_end}
{synopt:{cmd:r(DHS)}}Deutsch Hanoka Silber (2007) index{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varname)}}{it:varlist}{p_end}


{title:Dependencies}

{pstd}
{hi:bipolar} requires {hi:sgini} available on the Statistical Software Components (SSC) archive
({net "describe sgini, from(http://fmwww.bc.edu/repec/bocode/s/)":ssc describe sgini}).
{p_end}


{title:Examples}

{p 8 12 2}{inp:. use http://www.stata-press.com/data/r9/nlswork , clear }

{p 8 12 2}{inp:. gen w = exp(ln_wage) }

{p 8 12 2}{inp:. bipolar w if year==88}

{p 8 12 2}{inp:. bipolar w if year==88 , rankcut(0.90) }

{p 8 12 2}{inp:. bootstrap FW=r(FW), reps(50): bipolar w if year==88 & !mi(w)}

{p 8 12 2}{inp:. jackknife FW=r(FW) : bipolar w if year==88 & !mi(w) }


{title:References}

{p 4 8 2}Deutsch, J., M. Hanoka & J. Silber (2007), On the Link between the Concepts of Kurtosis and Bipolarization, Economics Bulletin, 4(36): 1{c -}6.

{p 4 8 2}Duclos J.-Y., Taptue, A.-M. (2014), Polarization, in Atkinson, A.B. & F. Bourguignon (eds). Handbook of Income Distribution (vol 2A), chapter 5, North Holland.  

{p 4 8 2}Foster, J. E. & M. C. Wolfson (1992), Polarization and the Decline of the Middle Class: Canada and the U.S., mimeo.

{p 4 8 2}Foster, J. E. & M. C. Wolfson (2010), Polarization and the Decline of the Middle Class: Canada and the U.S., Journal of Economic Inequality 8(2): 247{c -}273.

{p 4 8 2}Nissanov Z., A. Poggi &  J. Silber (2010), Measuring bi-polarization and polarization: a survey, in Deutsch J. & J. Silber (eds). The Measurement of Individual Well-Being and group Inequalities. Essays in memory of Z.M. Berrebi, chapter 3.

{p 4 8 2}Zhang, X. & R. Kanbur (2001), What Difference Do Polarization Measures Make? An Application to China, Journal of Development Studies 37(3): 85{c -}98.


{title:Also see}

{psee}
Online:  {helpb sgini} (if installed), {helpb anogi} (if installed) among {stata "findit polarization":several others}


{title:Authors}

{pstd}Alessio Fusco, Luxembourg Institute of Socio-Economic Research, alessio.fusco@liser.lu

{pstd}Philippe Van Kerm, Luxembourg Institute of Socio-Economic Research and University of Luxembourg, philippe.vankerm@liser.lu


{title:Acknowledgments}

{pstd}
This work was part of the MeDIM and WealthPort projects 
supported by the Luxembourg Fonds National de la Recherche (contracts FNR/06/15/08 and C09/LM/04)
and by core funding for CEPS/INSTEAD by the
Ministry of Higher Education and Research of Luxembourg. 

{* Version 2.0 2020-05-03, 1.0 2011-05-13}

