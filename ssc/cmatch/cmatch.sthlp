{smcl}
{* *! version 1.1.0 7.October.2017}{...}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:cmatch}{hline 1}}Tabulation of matched pairs in 1:1 case control study by exposure status{p2colreset}{...}

{title:Syntax}

{p 4 4 2}
{cmd:cmatch} {hi: Y} {hi: xvar} {hi: group} [if] [in]

{p 4 4 2}
where:
{p_end}

{p 4 4 2}
{hi:Y}: The name of the binary indicator (0: control, 1: case) of the case and control status.
{p_end}
{p 4 4 2}
{hi:xvar}: The name of the exposure categorical variable.
{p_end}
{p 4 4 2}
{hi:group}: The name of the variable which identifies the matched 1:1 pair.
{p_end}

{title:Description}

{p 4 4 2 120}
Matched case-control studies are a {hi: classical Epidemiology} study design. Case-control study designs are used
to estimate the relative risk for a disease from a specific risk factor. The estimate is the odds ratio, which is 
a good estimate of the relative risk especially when the disease is rare. {hi: cmatch} tabulates the number of 
matched pairs by {hi:c} levels of an exposure variable. {hi: cmatch} forms a {hi:c x c} table of matched pairs 
by the exposure status of the case and the exposure status of the control. The data must be in the form of individual records.
{p_end}

{title:Example}

webuse lowbirth2
cmatch low smoke pairid
clogit low smoke, group(pairid) or vsquish

.  webuse lowbirth2
(Applied Logistic Regression, Hosmer & Lemeshow)

.  cmatch low smoke pairid
1:1 matched pairs (case-control) by levels of the exposure variable: smoke

           |         Cases
  Controls |         0          1 |     Total
-----------+----------------------+----------
         0 |        18         22 |        40 
         1 |         8          8 |        16 
-----------+----------------------+----------
     Total |        26         30 |        56 

Matched pairs by smoke:  26

. clogit low smoke, group(pairid) or vsquish
Conditional (fixed-effects) logistic regression
                                                Number of obs     =        112
                                                LR chi2(1)        =       6.79
                                                Prob > chi2       =     0.0091
Log likelihood = -35.419282                     Pseudo R2         =     0.0875

------------------------------------------------------------------------------
         low | Odds Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
       smoke |       2.75   1.135369     2.45   0.014     1.224347    6.176763
------------------------------------------------------------------------------

{title:Remarks} 

{p 4 4 2 120}
Remember: {hi:Y} must be a binary indicator variable coded (0, 1); {hi:xvar} must be a categorical
variable and, {hi:group} is the variable that identifies the 1:1 matched pair. 
{p_end}

{title:References}

{p 4 4 2 120}
Hosmer DW, Lemeshow S (2000) Applied logistic regression (Wiley series in probability and statistics). Wiley, New York
{p_end}

{title:Authorship and developer}

{phang}Authorship: EPM304-London School of Hygiene and Tropical Medicine{p_end}
{phang}Developer: Miguel Angel Luque-Fernandez{p_end}
{phang}Department of Epidemiology and Population Health, London School of Hygiene and Tropical Medicine, London, U.K.{p_end}
{phang}E-mail:{browse "mailto:miguel-angel.luque@lshtm.ac.uk":miguel-angel.luque@lshtm.ac.uk}{p_end}  

{title:Also see}

{psee}
Online:  {helpb clogit}
{p_end}
