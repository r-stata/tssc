{smcl}
{cmd:help rioc}
{hline}

{title:Title}

{p 5 8 2}
{cmd:rioc} {hline 2} Relative improvement over chance (RIOC)


{title:Syntax}

{pstd}
Relative improvement over chance

{p 8 18 2}
{cmd:rioc} 
{it:{help varname:prediction}} 
{it:{help varname:outcome}}
{ifin} 
{weight}
[{cmd:,} {it:{help rioc##opts:options}} ]


{pstd}
Immediate command

{p 8 18 2}
{cmd:rioci}
{it:#TP} {it:#FP} [{cmd:\}] {it:#FN} {it:#TN}
[{cmd:, notab} 
{it:{help rioc##opts:options}} ]


{p 5 8 2}
where {it:prediction} (also: {it:classvar}) holds the predicted state 
(classification) and {it:outcome} (also: {it:refvar}) holds the true 
(actual) state. 

{p 8 8 2}
{it:#TP} is the number of true positives, {it:#FP} is the 
number of false positives, {it:#FN} is the number of false 
negatives, and {it:#TN} is the number of true negatives.


{synoptset 18 tabbed}{...}
{marker opts}{...}
{synopthdr}
{synoptline}
{synopt:{opt t:ab}}display contingency table
{p_end}
{synopt:{opt d:etail}}calculate the total (observed), chance (expected), 
and maximum possible proportion of correctly classified subjects
{p_end}
{synopt:{opt stat:s(stat)}}calculate additional proportions 
{p_end}
{synopt:{opt kappa}}calculate Cohen's kappa
{p_end}
{synopt:{opt sezero}}calculate the standard error for testing against zero
{p_end}
{synopt:{opt small:sample}}calculate confidence interval for RIOC in 
small samples
{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is 
{cmd:level({ccl level})}
{p_end}
{synopt:{it:{help rioc##opt_di:format_options}}}control column formats
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is allowed only with {cmd:rioc}; see {manlink D by}.
{p_end}
{p 4 6 2}
{cmd:fweight}s are allowed only with {cmd:rioc}; 
see {help weight}.


{title:Description}

{pstd}
{cmd:rioc} calculates the relative improvement over chance (RIOC) coefficient 
for 2 x 2 tables (Farrington & Loeber 1989, Copas & Loeber 1990). The RIOC 
corrects the observed proportion of correctly classified subjects for chance 
and maximum ceiling.

{pstd}
The command is implemented using methods and formulas discussed in 
Copas and Loeber (1990) and in Farrington and Loeber (1989). In both 
variables {it:prediction} and {it:outcome}, values equal to nonzero 
and nonmissing (typically values of one) indicate a true (positive)
state; values equal to zero indicate a false (negative) state.


{title:Remarks}

{pstd}
Although the syntax diagram implies that the order of the variables 
is always relevant, the relative improvement over chance (RIOC) does 
not depend on the orientation of the contingency table. The orientation 
of the contingency table does affect other statistics, such as the 
sensitivity and specificity.


{title:Options}

{phang}
{opt tab} displays the contingency table. This is the default for the 
immediate command, {cmd:rioci}; specify {opt notab} to suppress the 
contingency table.

{phang}
{opt detail} calculates the total (observed), chance (expected), and 
maximum possible proportion of correctly classified subjects. Confidence 
intervals are calculated using Stata's {helpb ci:cii} command with the 
default exact method.

{phang}
{opt stats(stat)} requests additional proportions. Confidence intervals 
are calculated using Stata's {helpb ci:cii} with the default exact method; 
{it:stat} is one or more of

{phang2}{cmd:TPR}{bind:  }true positive rate (sensitivity){p_end}
{phang2}{cmd:TNR}{bind:  }true negative rate (specificity){p_end}
{phang2}{cmd:PPV}{bind:  }positive predictive value{p_end}
{phang2}{cmd:NPV}{bind:  }negative predictive value{p_end}
{phang2}{cmd:all}{bind:  }all of the above{p_end}

{phang2}{...}
Note that all predefined {it:stats} require that the variables are 
specified in correct order: {it:prediction} {it:outcome}.

{phang}
{cmd:stats(}{it:name}{cmd::} {it:numerator}{cmd:/}{it:denominator}{cmd:)} is 
an alternative syntax for {opt stats()} that defines proportions to be 
calculated. Confidence intervals are calculated using Stata's {helpb ci:cii} 
with the default exact method. {it:name} is a valid name for the proportion, 
and {it:numerator} and {it:denominator} are {it:{help expression:expressions}} 
that typically refer to the cells of the contingency table. For example, in 
{it:numerator} and {it:denominator}, {cmd:a} refers to the number of true 
positives and {cmd:n} refers to the total number of subjects. The notation 
follows Copas and Loeber (1990):

{phang2}{cmd:a}{bind:  }true positives{bind:  }(synonym:{cmd: TP}){p_end}
{phang2}{cmd:b}{bind:  }false positives{bind: }(synonym:{cmd: FP}){p_end}
{phang2}{cmd:c}{bind:  }false negatives{bind: }(synonym:{cmd: FN}){p_end}
{phang2}{cmd:d}{bind:  }true negatives{bind:  }(synonym:{cmd: TN}){p_end}
{phang2}{cmd:e}{bind:  }{cmd:a} + {cmd:b}{bind:           }(synonym:{cmd: r1}){p_end}
{phang2}{cmd:f}{bind:  }{cmd:a} + {cmd:c}{bind:           }(synonym:{cmd: c1}){p_end}
{phang2}{cmd:n}{bind:  }{cmd:a} + {cmd:c} + {cmd:b} + {cmd:d}{bind:   }(synonym:  {cmd:N}){p_end}

{phang2}{...}
More than one {it:stat} may be defined. For example, sensitivity (the true 
positive rate) and specificity (the true negative rate) may be obtained as 

{p 12 12 2}
{cmd:. rioc} {it:...} {cmd:, stats(Sens: TP/(TP+FN) Spec: TN/(TN+FP))}

{phang2}{...}
Note that both {it:numerator} and {it:denominator} must be enclosed in 
parentheses if they contain spaces. More technically, the defined {it:stats} 
consist out of 5 tokens: {it:name}, {cmd::}, {it:numerator}, {cmd:/}, and 
{it:denominator}.

{phang2}
Although, technically, {cmd:rioc} can compute risk-ratios, e.g., 
{cmd: stats(LRpos: (a*(n-f))/(f*b))}, the confidence intervals 
are still calculated using {helpb ci:cii}; for risk-ratios, confidence 
intervals are not valid (see {helpb cs:csi}).

{phang}
{opt kappa} calculates Cohen's kappa. The standard error and the confidence 
interval are implemented according to Fleiss et al. (1969). Option 
{opt sezero} may be specified to obtain the same standard error as Stata's 
{helpb kap} command. 

{phang}
{opt sezero} calculates the standard error of RIOC (and kappa, if 
{opt kappa} is also specified) for testing against zero. For the RIOC, 
the p-value matches the p-value of Pearson's chi-squared test with 1 
degree of freedom; for kappa, the standard error and z-value match those 
of Stata's {helpb kap} commmand. Note that confidence intervals are not 
affected by {opt sezero}.

{phang}
{opt smallsample} calculates the confidence interval for RIOC in small 
samples. {opt smallsample} only affects the confidence interval for the 
RIOC; no confidence intervals are calculated for additional 
proportions and statistics. Also, when {opt smallsample} is specified, 
standard errors are not calculated, unless {opt sezero} is also specified.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for 
confidence intervals. The default is {cmd:level({ccl level})} 
(see {helpb level:c(level)}).

{marker opt_di}{...}
{phang}
{cmd:cformat(}{it:{help format:{bf:%}fmt}}{cmd:)} specifies how to format 
coefficients, standard errors, and confidence limits. The maximum format 
width is 9.

{phang}
{cmd:pformat(}{it:{help format:{bf:%}fmt}}{cmd:)} specifies how to format 
p-values. The maximum format width is 5.

{phang}
{cmd:sformat(}{it:{help format:{bf:%}fmt}}{cmd:)} specifies how to format 
test statistics. The maximum format width is 8.


{title:Examples}

{pstd}
Example 1: Table I (Farrington & Loeber 1989:202)

{phang2}{stata rioci 75 125 \ 25 175:. rioci 75 125 \ 25 175}

{pstd}
Example 1a: Keep the dataset in memory (Caution: clears the dataset)

{phang2}{stata rioci 75 125 \ 25 175 , replace:. rioci 75 125 \ 25 175 , replace}{p_end}

{pstd}
Example 2: More details, suppress table

{phang2}{stata rioc prediction outcome [fweight=pop] , notab detail:. rioc prediction outcome [fweight=pop] , notab detail}{p_end}

{pstd}
Example 3: Add Sensitivity and Specificity

{phang2}{stata rioc prediction outcome [fweight=pop] , tab detail stats(TPR TNR):. rioc prediction outcome [fweight=pop] , tab detail stats(TPR TNR)}{p_end}

{pstd}
Example 4: Add prevalence

{phang2}{stata "rioc prediction outcome [fweight=pop] , stats(Prevalence: (TP+FN)/N)":. rioc prediction outcome [fweight=pop] , stats(Prevalence: (TP+FN)/N)}{p_end}

{pstd}
Example 5: Replicate results from {helpb estat_classification:estat classification} 
(Caution: clears data)

{phang2}{stata sysuse nlsw88 , clear:. sysuse nlsw88 , clear}{p_end}
{phang2}{stata logit union i.collgrad:. logit union i.collgrad}{p_end}
{phang2}{stata estat classification , cutoff(`=1/(1+exp(-_b[_cons]))'):. estat classification , cutoff(`=1/(1+exp(-_b[_cons]))')}{p_end}
{phang2}{stata "rioc collgrad union , stats(all FPR_0: b/(n-f) FNR_1: c/f FPR_1: b/e FNR_0: c/(n-e)) percent":. rioc collgrad union , stats(all FPR_0: b/(n-f) FNR_1: c/f FPR_1: b/e FNR_0: c/(n-e)) percent}


{title:Saved results}

{pstd}
{cmd:rioc} saves the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 12 tabbed}{...}
{synopt:{cmd:r(N)}}number of subjects{p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}
{synopt:{cmd:r(rioc)}}relative improvement over chance (RIOC){p_end}

{pstd}
Macros{p_end}
{synoptset 12 tabbed}{...}
{synopt:{cmd:r(cmd)}}{cmd:rioc}{p_end}

{pstd}
Matrices{p_end}
{synoptset 12 tabbed}{...}
{synopt:{cmd:r(table)}}information from the coefficients table{p_end}


{title:References}

{pstd}
Cairney, J., & Streiner, D. L. 2011. Using relative improvement over 
chance (RIOC) to examine agreement between tests: Three case examples 
using studies of developmental coordination disorder (DCD) in 
children. Research in Developmental Disabilities, 32, 87--92.

{pstd}
Copas, J. B., & Loeber, R. 1990. Relative improvement over chance 
(RIOC) for 2 x 2 tables. British Journal of Mathematical and 
Statistical Psychology, 43, 293--307.

{pstd}
Farrington, D.P., & Loeber, R. 1989. Relative improvement over chance 
(RIOC) and phi as measures of predictive efficiency and strength of 
association in 2 x 2 tables. Journal of Quantitative Criminology, 
5, 201--213.

{pstd}
Fleiss, J. L., Cohen, J., & Everitt, B. S. 1969. Large sample standard 
errors of kappa and weighted kappa. Psychological Bulletin, 72, 323--327.


{title:Acknowledgments}

{pstd}
A first version of {cmd:rioc} appeared on 
{browse "https://www.statalist.org/forums/forum/general-stata-discussion/general/1590550-relative-improvement-over-chance-modified-kappa?p=1590918#post1590918":Statalist} as 
part of a discussion with Rich Goldstein, Eric Melse, and Mike Lacy. 


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb tabulate}, {helpb ci}, {helpb estat classification}, 
{helpb kap}
{p_end}

{psee}
if installed: {help diagt}, {help classtabi}, {help kappaetc}, {help riocplot}
{p_end}
