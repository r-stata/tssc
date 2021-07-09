{smcl}
{* 2009-05-02}
{* help file to accompany sampsi_sccs 1.3.0}
{cmd:help sampsi_sccs}
{hline}

{title:Title}

{p 4 16 2}
{bf:sampsi_sccs {c -} Sample size estimation for the self-controlled case series study design}


{title:Syntax}

{p 8 17 2}
{bf:sampsi_sccs} {space 1}[{bf:,}{space 1}{it:options}] {p_end}

{p 8 17 2}
{bf:sampsi_sccs} {space 1}{bf:?} {p_end}

{p 5 17 2}
where the second syntax displays the syntax diagram for the first syntax.{p_end}


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options}
{p2colset 7 35 37 2}{...}
{synopt :{opt a:lpha(#)}}type 1 error level{p_end}
{synopt :{opt p:ower(#)}}power{p_end}
{synopt :{opt rho(#)}}relative incidence of outcome in post-exposure risk period compared to baseline{p_end}
{synopt :{opt me:thod(string)}}method of sample size estimation{p_end}
{synopt :{opt one:sided}}use one-sided alpha{p_end}

{synoptline}


{title:Description}

{pstd}
{cmd:sampsi_sccs} estimates the sample size for a self-controlled case series study design (see Whitaker et al (2006)).
Optionally, one may control for the confounding effects of age. The formulae are taken from Musonda et al (2006). 
The program gives the required number of events rather than the number of subjects, but Musonda recommends (p2626) taking 
n{it:_subjects} = n{it:_events}. {p_end}


{title:Options}

{dlgtab:Options}

{phang}
{opt alpha(#)}  specifies the type 1 error level; default is 0.05 {p_end}

{phang}
{opt power(#)}  specifies the power; default is 0.90 {p_end}

{phang}
{opt rho(#)}  specifies the incidence rate of the event in the post-exposure risk period relative to that in the baseline (unexposed) period; 
default is 2 {p_end}

{phang}
{opt method(string)}  specifies the method of estimation. {it:string} is one of {bf:bin}, {bf:srl} or {bf:age}; the default is {bf:bin}.{p_end}

{p 8 12 2}
{bf:bin}  specifies the binomial method [Eqns (6) and (3) of Musonda] using an arcsin transformation. {p_end}
{p 8 12 2}
{bf:srl}  ({it:that's "el"}) specifies the signed root likelihood ratio method [Eqns (9) and (3) of Musonda]. {p_end}
{p 8 12 2}
{bf:age}  specifies the signed root likelihood ratio method with adjustment for the effect of age [Eqn (12) of Musonda].{p_end}

{phang}
{opt onsesided} specifies a one-sided alpha; the default is a two-sided alpha. {p_end}


{title:Examples}

{p 6 10 2}
(1) Use the binomial method to estimate the sample size required to show a 5-fold increase in incidence 
of disease during a 2 day period of risk following exposure when the entire observation period is 200 days and all 
subjects are exposed. Power is 0.9 for a two-tailed test at the 0.05 level. The program will prompt for 
relevant input.{p_end}

{p 10 10 2}
{cmd:. sampsi_sccs , rho(5)}

{space 10}Binomial method

{space 10}input duration of post-exposure risk period (e.g.  2)                     . 2
{space 10}input duration of entire observation period (e.g.  200)                   . 200
{space 10}input proportion of subjects exposed at all during obs period (e.g. 1)    . 1

{space 10}==================================================================
{space 10}========== sample size for SCCS Design: binomial method ==========
{space 10}==================================================================

{space 10}  2-tailed alpha is:                                          .05
{space 10}  power is:                                                   .9
{space 10}  relative incidence associated with exposure is:             5
{space 10}  post-exposure risk period is:                               2

{space 10}  total number of events required in exposed subjects is:    94

{space 10}  total number of events required in unexposed subjects is:   0

{space 10}  Total number of events required is:                        94
{space 10}==================================================================

{p 11 20 2}
Note 1: all subjects were exposed, so zero events would be seen in the unexposed.
{p_end}
{p 11 20 2}
Note 2: the sample size depends, {it:inter alia}, on the ratio of risk period to total 
observation period, and not on where within the observation period the risk is experienced.
{p_end}


{p 6 10 2}
(2) Use the signed root likelihood ratio method to estimate the sample size required to show a 3-fold increase
in incidence of disease in infants during a 42 day post-exposure risk period when the observation period is the second 
year of life (days 366-730), and this total observation period is broken into 4 age sub-periods: the first 3 are of 91 
days each, and the last is 92 days.  The proportions exposed in each age group are 0.6, 0.2, 0.05 and 0.05 respectively.
The incidence of disease within age groups, relative to the first age are 1, 0.6, 0.4 and 0.4 respectively. Desired 
power is 0.8 for a two-tailed test at the 0.05 level. This example is from Musonda section 7.3.{p_end}

{p 10 10 2}
{cmd:. sampsi_sccs , power(.8) rho(3) method(age)}{p_end}

{space 10}Signed root likelihood method controlling for age effects

{space 10}input number of age groups    (e.g. 5)                                    . 4

{space 10}input age specific incidence [relative to age group 1] in age group 2     . .6
{space 10}input age specific incidence [relative to age group 1] in age group 3     . .4
{space 10}input age specific incidence [relative to age group 1] in age group 4     . .4

{space 10}input length of observation period for age group 1                        . 91
{space 10}input length of observation period for age group 2                        . 91
{space 10}input length of observation period for age group 3                        . 91
{space 10}input length of observation period for age group 4                        . 92

{space 10}input post-exposure risk period [assumed the same for each group]         . 42

{space 10}input proportion of subjects exposed during obs period in age group 1     . .6
{space 10}input proportion of subjects exposed during obs period in age group 2     . .2
{space 10}input proportion of subjects exposed during obs period in age group 3     . .05
{space 10}input proportion of subjects exposed during obs period in age group 4     . .05

{space 10}==================================================================
{space 10}========== sample size for SCCS Design with age effects ==========
{space 10}==================================================================

{space 10}  2-tailed alpha is:                                        .05
{space 10}  power is:                                                 .8
{space 10}  relative incidence associated with exposure is:            3
{space 10}  common post-exposure risk period is:                      42


{space 10}  total number of events required in exposed subjects is:   35

{space 10}  total number of events required in unexposed subjects is:  2

{space 10}  Total number of events required is:                       37
{space 10}==================================================================


{title:Saved results}

{p 4 8 2}
{cmd:sampsi_sccs} saves the following in {bf:r()}{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(n_total)}}total sample size {p_end}
{synopt:{cmd:r(n_exp)}}sample size required among the exposed{p_end}
{synopt:{cmd:r(n_unexp)}}sample size required among the unexposed{p_end}
{p2colreset}{...}


{title:References}

{p 4 8 2}
Whitaker HJ, Farrington CP, Spiessens B, Musonda P [2006]. 
Tutorial in biostatistics: The self-controlled case series method. Statistics in Medicine 25(10), 1768–1797.{p_end}

{p 4 8 2}
Musonda P, Farrington CP, Whitaker HJ [2006]. Sample sizes for self-controlled case series studies. 
Statistics in Medicine 25(15), 2618–2631.{p_end}


{title:Acknowledgements}

{p 4 4 2}
Thanks to Tony Lachenbruch, Oregon State University, for pointing out an error in an early version of the code and for 
other helpful comments and assistance with testing. Thanks also to Paddy Farrington, Open University UK, for suggesting 
an approach to resolving the aforementioned error.{p_end}



{title:Author}

{p 4 4 2}Philip Ryan{break}
Data Management & Analysis Centre{break}
Discipline of Public Health{break}
Faculty of Health Sciences{break}
University of Adelaide{break}
South Australia{break}
philip.ryan@adelaide.edu.au



