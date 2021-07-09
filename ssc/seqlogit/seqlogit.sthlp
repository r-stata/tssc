{smcl}
{* MLB 02Apr2012}{...}
{* MLB 10Apr2010}{...}
{* MLB 14Jul2009}{...}
{hline}
help for {hi:seqlogit}
{hline}

{title:Sequential logit model}

{p 8 17 2}
{cmd:seqlogit} {depvar} [{indepvars}] {ifin} {weight} 
{cmd:,} 
{opt tree(tree)}
[ 
{opt ofint:erest(varname)}
{opt over(varlist)}
{opt x#(varlist)}
{opt levels(#=#, #=#, etc.)}
{opt sd(numlist)}
{opt deltasd(varname numlist)}
{opt rho(#)}
{cmd:{c -(} }
{opt pr(numlist)} |
{opt mn(# # , # # [, # #, etc.])} |
{opt uniform}
{cmd:{c )-}} 
{opt draws(#)}
{opt drawstart(#)}
{cmd:or}
{opt c:onstraints(numlist)}
{cmdab:r:obust}
{opt cl:uster(clustervar)}
{cmd:nolog}
{opt l:evel(#)} 
{it:{help seqlogit##maximize_options:maximize_options}} 
]

{p 4 4 2}{cmd:by} {it:...} {cmd::} may be used with {cmd:seqlogit}; see help
{help by}. 

{p 4 4 2}{cmd:pweight}s, {cmd:fweight}s and {cmd:iweight}s are allowed; see 
help {help weights}.

{p 4 4 2}{it:indepvars}, {cmd:over()} and {cmd:x#(varlist)} may contain factor
variables, see {help fvvarlist}.


{title:Description}

{p 4 4 2} {cmd:seqlogit} fits a sequential logit model. This 
model is know under a variety of other names: sequential response model 
(maddala 1983), continuation ratio logit (Agresti 2002), model for nested 
dichotomies (fox 1997), and the Mare model (shavit and blossfeld93) (after 
(Mare 1981)). 

{p 4 4 2}A sequential logit model can be estimated quite simply by estimating 
a number of {help logit} models. The {cmd:seqlogit} package serves three 
additional purposes: First, it makes it easier to {help test} hypotheses across
transitions since the entire model is estimated simultaneously. Second, it
implements the decomposition proposed by Buis (2010a) of the effect of an 
explanatory variable on the outcome of the process described by the sequential 
logit into the contributions of each of the transitions. The implementation is 
discussed in {help seqlogit postestimation}. Third, it implements and extends
the strategy proposed by Buis (2011) of doing a sensitivity analysis to 
investigate the potential influence of unobserved variables.

{p 4 4 2} For this last purpose, the {cmd:seqlogit} package allows one to 
estimate a sequential logit given a scenario concerning the unobserved 
variables. These effects will only be estimated when the {opt sd()} option is
specified. A regular sequential logit model, which assumes that there is no 
unobserved heterogeneity, is estimated if the {opt sd()} option is not 
specified. The scenarios assume that these unobserved variables either add up 
to a standardized normally (Gaussian) distributed variable (the default), or 
to a standardized discrete variable (when the {opt pr()} option is specified), or
a mixture of normal distributions (when the {opt mn()} option is specified), or
a uniform distribution (when the {opt uniform} distribution is specified. The 
effects of this agregate unobserved variable during each transition are specified 
in the {opt sd()} option. One can allow the effect of the unobserved variable to
change over another variable using the {opt deltasd()} option. The correlation 
during the first transition between this unobserved variable and the variable 
specified in the {cmd:ofinterest()} option is specified in the {cmd:rho()} 
option. The scenarios are estimated using maximum simulated likelihood, 
while the regular sequential logit model is estimated using regular maximum 
likelihood. Advise on how to use these different scenarios in a sensitivity
analysis is given here: {help seqlogit_sensitivity}.


{title:Options}

{dlgtab:Model}

{phang}
{opt tree(tree)} specifies the sequence of transitions that make up the model.
The transitions are seperated with commas and the choices within transitions
are seperated with colons. The levels are represented by the levels of the
{it:depvar}. It is thus convenient to code {it:depvar} as a series of integers. For
example, say there are three levels, 1, 2, and 3, and the first transition 
consist of a choice between value 1 versus values 2 or 3, and the second 
transition consists (for those who didn't choose value 1) of a choice between 
values 2 and 3. The tree option should than be: tree(1 : 2 3 , 2 : 3).

{p 8 8 2}All values of {it:depvar} must be specified in the tree and all 
values in the tree must occur in {it:depvar}. Furthermore, all levels must be 
reachable through one and only one path through the tree. 

{phang}
{opt ofint:erest(varname)} specifies the variable whose effect will be 
decomposed when using the 
{helpb seqlogit postestimation##seqlogitdecomp:seqlogitdecomp} command. 
The variable specified is added to the list of explanatory variables. 

{phang}
{opt over(varlist)} specifies the variable(s) over which the effect of 
the variable specified in the {opt ofinterest()} option is allowed to change.
This/these variable(s) and the interaction effect between the variable(s) 
spefied in {opt over()} and {opt ofinterest()} are added to the list of 
explanatory variables. {opt ofinterest()} needs to be specified when
specifying {opt over()}.

{phang}
{opt x#(varlist)} specifies variables that are to be included in the #th 
transition. The number of the transition corresponds with the order in which
it appears in the {cmd:tree()} option. So, if we have specified as 
tree(1 : 2  3 : 4 5, 2 : 3, 4 : 5) Than, 1 : 2  3 : 4 5 is the first 
transition, 2 : 3 the second, and 4 : 5 the third transition.

{phang}
{opt levels(#=#, #=#, etc.)} specifies the values assigned to each end-state. 
For example, if one is studying education, than it would be the value (often 
measured in (pseudo-)years of education) of each level of education. The number 
to the left of the equal sign is the number used in {it:depvar} and the 
{cmd:tree()} option, and the number to the right of the equal sign is the value
that is to be assigned to that state. The default is to use the values in 
{it:depvar} as the values. These values will not influence the model, but will 
play an important role in the decomposition of the effects on the final outcome
into the effects on each transitions and weights assigned to each transition, as
implemented in {helpb seqlogit postestimation##seqlogitdecomp:seqlogitdecomp}.

{pmore}
A convenient trick is possible when it is hard (impossible) to assign values to the 
different stages, but there is one outcome of particular interest. Say, one is 
studying the process through which a respondent comes to participate in a survey 
as two stages: a potential respondent is succesfully contacted or not, and given 
that (s)he is contacted (s)he can decide to participate or not. In that case it 
is hard to assign values to the states "not contacted" and "contacted but refused". 
However, we typically care about the overall probablity of participating. In 
that case we can assign a 1 to "contacted and participated" and a 0 to all other 
states. In that case the effect on the final outcome is the effect on the probability 
of participating.

{phang}
{opt c:onstraints(numlist)} specifies linear constraints to be applied during
estimation, see {helpb constraint}.


{dlgtab:Scenarios}

{phang}
{opt sd(numlist)} specifies for each transition the effect of the 
standardized unobserved variable. If only one number is specified, this
effect will be assumed constant over transitions, otherwise the first
number will refer to the first transition, the second number to the second
transition, etc. The default is 0.

{phang}
{opt deltasd(varname numlist)} specifies how the effect of the unobserved
variable changes over {it:varname}. If only one number is specified,
this change will be assumed constant over transitions, otherwise the first
number will refer to the first transition, the second number to the second
transition, etc. The default is that the effect of the unobserved variable
is constant over all variables.

{phang}
{opt rho(#)} specifies the correlation of the unobserved variable and the 
variable specified in {cmd:ofinterest()}. The default is 0.

{phang}
The {cmd:pr()}, {cmd:mn()}, and {cmd:uniform} options govern the distribution
of the unobserved variable. They are mutually exclusive. If the {cmd:pr()}, 
{cmd:mn()}, and {cmd:uniform} are not specified but the {cmd:sd()} option is 
specified, than the unobserved variable will be represented by a standard 
normal distribution.

{phang}
{opt pr(numlist)} specifies that the unobserved variable is to be represented
by a discrete distribution. The numbers in {cmd:pr()} represent the 
proportion of observations that belong to each category. Since the numbers are
propotions, they all need to be larger than 0 and they need to add up to 1. 
The location of these categories will be chosen such that the mean is 0, the 
standard deviation is 1, and all categories are separated by the same distance.
The {cmd:pr()} option may not be specified without specifying the {cmd:sd()} 
option. 

{phang}
{opt mn(# # , # # [, # #, etc.])} specified that the unobserved variable is to
be represented as a mixture of normal distributions. This option should consist
of multiple elements separated by commas, whereby each element consists of 
two numbers, the first is the proprotion the latter a mean of one of the 
components of the mixture distribution. The proportions should add up to 1. The
means of the components will be transformed such that the mean of the of the 
distribution equals 0. The variances of the components are assumed to be equal
and are choses such that the overall variance equals 1. This means that not
all proportion-mean combination will lead to valid mixture distributions, in
which case {cmd:seqlogit} will report an error and stop. 

{phang}
{opt uniform} specifies that the unobserved variable is to be represented by
a uniform distribution with mean 0 and standard deviation 1. This could make
sense when we think that it is the rank order on the unobserved variables that
influences the outcome rather than some metric value, as the distribution of
rank scores is a uniform distribution.  This assumption could be justified  
when we assume that the unobserved variables are also be hard to observe for 
the actors themselves, and that the rank score is easier to observe (Jill is
smarter than Jack, we just don't know how much smarter.). 

{phang}
{opt draws(#)} specifies the number of pseudo random draws per observation used 
when calculating the simulated likelihood. The default is 100. Because maximum 
simulated likelihood is only used when the {cmd:sd()} option is specified, the 
{opt draws()} option can only be specified when the {cmd:sd()} option is specified.

{phang}
{opt drawstart(#)} specifies the index at which the Halton sequence starts. The
default is 15.


{dlgtab:Reporting}

{phang}
{opt or} report odds ratios 

{phang}
{opt r:obust} specifies that the Huber/White/sandwich estimator
of variance is to be used in place of the traditional calculation; see
{hi:[U] 23.14 Obtaining robust variance estimates}.  {cmd:robust}
combined with {cmd:cluster()} allows observations which are not
independent within cluster (although they must be independent between
clusters). 

{phang}
{opt c:luster(clustervar)} specifies that the observations
are independent across groups (clusters) but not necessarily within groups.
{it:clustervar} specifies to which group each observation belongs; e.g.,
{cmd:cluster(personid)} in data with repeated observations on individuals.  See
{hi:[U] 23.14 Obtaining robust variance estimates}.  Specifying {cmd:cluster()}
implies {cmd:robust}.

{phang}
{opt l:evel(#)} specifies the confidence level, in percent,
for the confidence intervals of the coefficients; see help {help level}.

{phang}
{opt nolog} suppresses an iteration log of the log likelihood

{marker maximize_options}{...}
{phang}
{opt maximize_options}:
{opt diff:icult},
{opt tech:nique(algorithm_spec)},
{opt iter:ate(#)},
{opt tr:ace},
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt shownr:tolerance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt gtol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance(#)};
see {help maximize}.  These options are seldom used.


{title:Example}

{cmd}{...}
    use "http://fmwww.bc.edu/repec/bocode/g/gss.dta", clear
		
    recode degree 4=3
    label define degree 0 "lt high school" ///
                        1 "high school"    ///
                        2 "junior college" ///
                        3 "college", modify
    label value degree degre

    seqlogit degree south                   ///
         c.coh##c.coh if black == 0 ,       ///
         tree(0 : 1 2 3 , 1 : 2 3 , 2 : 3 ) ///
         ofinterest(paeduc)                 ///
         over(c.coh##c.coh)                 ///
         levels(0=9, 1=12, 2=14, 3=16)

    seqlogitdecomp, overat(coh 1.5,       ///
                           coh 2.5,       ///
                           coh 3.5,       ///
                           coh 4.5,       ///
                           coh 5.5,       ///
                           coh 6.5)       ///
       at(south 0 paeduc 12)              ///
       yline(0) xline(0)                  ///
       subtitle("1915" "1925" "1935"      ///
                "1945" "1955" "1965")     ///
       eqlabel(`""less than high school" "versus" "high school or more""' ///
               `""high school" "versus" "any college""'                   ///
               `""junior college" "versus" "college""' )
		
    seqlogitdecomp paeduc, at(coh 1.5 south 0 paeduc 12) table

    seqlogit degree south                   ///
         c.coh##c.coh if black == 0 ,       ///
         tree(0 : 1 2 3 , 1 : 2 3 , 2 : 3 ) ///
         ofinterest(paeduc)                 ///
         over(c.coh##c.coh)                 ///
         levels(0=9, 1=12, 2=14, 3=16)      ///
         or sd(1)
    
    uhdesc
{txt}


{title:Author}

{p 4 4 2}Maarten L. Buis, Universitaet Tuebingen{break}maarten.buis@uni-tuebingen.de


{title:Suggested citation if using seqlogit in published work}

{p 4 4 2}
{cmd:seqlogit} is not an official Stata command. It is a free contribution 
to the research community, like a paper. Please cite it as such.

{p 4 4 2}
Buis, Maarten L.  2007. "SEQLOGIT: Stata module to fit a sequential logit model" 
{browse "http://ideas.repec.org/c/boc/bocode/s456843.html"}

{p 4 4 2} or:

{p 4 4 2}
Buis, Maarten L. 2010
``Chapter 6, Not all transitions are equal: The relationship between inequality of 
educational opportunities and inequality of educational outcomes'', In:
Buis, Maarten L. ``Inequality of Educational Outcome and Inequality of 
Educational Opportunity in the Netherlands during the 20th Century''.
PhD thesis.
{browse "http://www.maartenbuis.nl/dissertation/chap_6.pdf"}

{p 4 4 2}
Buis, maarten L. 2011 
``The Consequences of Unobserved Heterogeneity in a Sequential Logit Model'', 
Research in Social Stratification and Mobility, 29(3), pp. 247-262.


{title:Acknowledgements}
{pstd}
I appreciate the useful comments I received at the 2009 Summer meeting of the 
RC28, Dominik Becker and Jeremy Freese.


{title:References}

{p 4 4 2}
Agresti, Alan 2002 . 
{it:Categorical Data Analysis, 2nd edition.}
Hoboken, NJ: Wiley-Interscience. 

{p 4 4 2}
Buis, Maarten L. 2010a
``Chapter 6, Not all transitions are equal: The relationship between inequality of 
educational opportunities and inequality of educational outcomes'', In:
Buis, Maarten L. ``Inequality of Educational Outcome and Inequality of 
Educational Opportunity in the Netherlands during the 20th Century''.
PhD thesis.
{browse "http://www.maartenbuis.nl/dissertation/chap_6.pdf"}

{p 4 4 2}
Buis, maarten L. 2011 
``The Consequences of Unobserved Heterogeneity in a Sequential Logit Model'', 
Research in Social Stratification and Mobility, 29(3), pp. 247-262.
{browse "http://dx.doi.org/10.1016/j.rssm.2010.12.006"}

{p 4 4 2}
Fox, John 1997
{it:Applied Regression Analysis, Linear Models, and Related Methods.}
Thousand Oaks: Sage.

{p 4 4 2}
Maddala, G.S. 1983
{it:Limited Dependent and Qualitative Variables in Econometrics}
Cambridge: Cambridge University Press.

{p 4 4 2}
Mare, Robert D. 1981
``Change and Stability in educational Stratification''
{it:American Sociological Review}, 46(1), p.p. 72-87.

{p 4 4 2}
Shavit, Yossi and Hans-Peter Blossfeld 1993
{it:Persistent Inequality: Changing Educational Attainment in Thirteen Countries}
Boulder: Westview Press.

{title:Also see}

{p 4 13 2}
Online: help for {help seqlogit postestimation}, {help seqlogit_sensitivity} help for {help logit}, {help mlogit}  

