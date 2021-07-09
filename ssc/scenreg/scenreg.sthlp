{smcl}
{* *! version 1.0.0  MLB 07Nov2010}{...}
{hline}
help for {hi:scenreg}
{hline}

{title:title}

{phang}
{bf:scenreg} {hline 2} Scenarios for models with binary dependent variables


{title:Syntax}

{p 8 17 2}
{cmd:scenreg}
[{varlist}]
{ifin}
{weight}
{cmd:,} 
{opt sd(exp)}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt link(link_name)}}specifies the link function{p_end}
{synopt:{opt dist(dist_name)}}specifies the distribution of the unobserved variable{p_end}
{synopt:{opt rho(varname #)}}specifies the correlation between {it:varname} and the unobserved variable{p_end}
{synopt:{opt nocons:tant}}suppresses the constant{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt opg}, {opt boot:strap},
   or {opt jack:knife}{p_end}

{syntab:Display}
{synopt:{opt or}}report odds ratios{p_end}
{synopt:{opt rr}}report risk ratios{p_end}
{synopt:{opt hr}}report hazard ratios{p_end}
{synopt:{opt l:evel(#)}}set confidence level{p_end}
{synopt :{opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}

{syntab:Maximization}
{synopt :{it:{help scenreg##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:fweight}s and {cmd:pweight}s are allowed; see {help weight}.


{title:Description}

{pstd}
The results of many models for binary dependent variables can be influenced by 
unobserved variables, even when these unobserved variable are uncorrelated with any
of the observed variables {help scenreg##neuhaus_jewell:Neuhaus and Jewell (1993)}, 
{help scenreg##allison:Allison (1999)}, {help scenreg##williams:Williams (2009)}, 
and {help scenreg##mood:Mood (2010)}.  With {cmd:scenreg} one can explore the seriousness
of this potential problem for your data and hypotheses by allowing one to estimate
the results given a wide set of scenarios concerning the unobserved variable.  In 
that sense it is similar to {help scenreg##rosenbaum_rubin:Rosenbaum and Rubin (1983)},
{help scenreg##rosenbaum:Rosenbaum (2002)} and {help scenreg##becker_caliendo:Becker and Caliendo (2007)}, 
except that the method for estimating these scenarios used in {cmd:scenreg} allows 
greater flexibility regarding the distribution of the unobserved variable and the 
hypotheses and parameters that are investigated for scensitivity.  The method is 
similar to the method proposed by {help scenreg##buis:Buis (2010)}, except that he 
used it for a sequential logit model.


{title:Options}

{dlgtab:Model}
 
{phang}
{opt sd(exp)} specified the standard deviation of the unobserved variable, which
can also be interpreted as the effect of the standardized unobserved variable.
The {it:exp} can either be a positive number or an expression that can be 
interpreted by {manhelp generate R}. This option is not optional.

{phang}
{opt link(link_name)} specified the link function, the default is the {cmdab:logi:t} 
link function. Alternitives are: {cmdab:prob:it}, {cmdab:iden:tity}, {cmdab:log},
{cmdab:clog:log}, and {cmdab:logl:og}.

{phang}
{opt dist(dist_name)} specifies the distribution of the unobserved variable. The 
default is the {cmdab:norm:al} distribution. Alternatives are {cmdab:Gaus:sian} (a 
synonym for {cmd:normal}), {cmdab:unif:orm}, and {cmdab:disc:rete} {it:# #}[{it:#} [...]]. 
The numbers in after {cmd:discrete} represent the proportion of observations that
belong to each category of the discrete distribution. Since the numbers are 
propotions, they all need to be larger than 0 and they need to add up to 1. The 
location of these categories will be chosen such that the mean is 0, the standard 
deviation is 1, and all categories are separated by the same distance.

{phang}
{opt rho(varname #)} specifies the correlation of the unobserved variable and the 
variable {it:varname}. The default is 0.

{phang}
{opt noconstant} suppresses the constant term (intercept) in the model.


{dlgtab:SE/Robust}

INCLUDE help vce_asymptall


{dlgtab:Display}

{phang}
{opt or} | {opt rr} | {opt hr} reports the estimated coefficients transformed 
to odds ratios, risk ratios, or hazard ratios i.e., exp(b) rather than b.  
Standard errors and confidence intervals are similarly transformed.  This 
option affects how results are displayed, not how they are estimated.  
Unfortunately, this option suppresses the display of the baseline odds, risk
or hazard, i.e. exp(_cons).  See {help scenreg##newson:Newson (2003)} for a 
way around this problem.  

{pmore}
The {opt or} option is only possible incombination with the {cmd:logit} link
function.  The {opt rr} option is only possible incombination with the 
{cmd:log} link function.  The {opt hr} option is only possible incombination 
with the {cmd:cloglog} link function. 


{phang}
{opt level(#)}; see 
{helpb estimation options##level():[R] estimation options}.

{phang}
{opt coeflegend}; see
     {helpb estimation options##coeflegend:[R] estimation options}.


{marker maximize_options}{...}
{dlgtab:Maximization}

{phang}
{opt draws(#)} specifies the number of pseudo random draws per observation used when calculating the simulated
        likelihood; the default is 100.  See {manhelp mata_halton() M-5} and {help scenreg##drukker_gates:Drukker & Gates (2006)}.

{phang}
{opt start(#)} specifies the index at which the Halton sequence starts; the default is 15.  See {manhelp mata_halton() M-5}
and {help scenreg##drukker_gates:Drukker & Gates (2006)}.

{phang}
{opt eclear} specifies that the Mata external global object S_unobserved_variable may be overwritten.  This global 
object is used to store pseudo-random draws from the unobserved variable, and is normally removed the moment {cmd:scenreg}
successfully finished.  However, it can be left behind when {cmd:scenreg} exited with an error, in which case 
the {opt eclear} option must be specified in the subsequent call to {cmd:scenreg} otherwise it will exit with an error.

{phang}
{it:maximize_options}:
{opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{cmd:{ul:no}}]{opt lo:g}, {opt tr:ace}, 
{opt grad:ient}, {opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance},
; see {manhelp maximize R}.  These options are seldom
used.

{title:Remarks}

{pstd}
The aim of {cmd:scenreg} is to explore the sensitivity of results in a binary regression model to
the presence of unobserved variables.  There are many publications now showing that these
unobserved variable {it:could} influence the results ({help scenreg##neuhaus_jewell:Neuhaus and Jewell (1993)}, 
{help scenreg##allison:Allison (1999)}, {help scenreg##williams:Williams (2009)}, 
and {help scenreg##mood:Mood (2010)}), but these publications cannot tell you how big the problem
is in your data and for your hypotheses or parameters of interest.  That is the question that 
a sensitivity analysis using {cmd:scenreg} is supposed to answer.

{pstd}
The scenarios consists of assumptions concerning the strength of the effect of the standardized
unobserserved variable (specified in the {opt sd(exp)} option), the distribution of the 
unobserved variable (specified in the {opt dist(dist_name)} option), and the correlation between 
the unobserved and an observed variable (specified in the {opt corr(varname #)} option).  The 
strength of the effect of the unobserved variable can be constant or change over variables. The
latter possibility is useful as this "heteroscedasticity" plays an important part in the literature.
The effects are than estimated by integrating the unobserved variable out of the likelihood function
using maximum simulated likelihood, see: {help scenreg##train:Train (2003)} and the special issue
on maximum simulated likelihood in the Stata Journal, {browse "http://www.stata-journal.com/sj6-2.html":issue 6, number 2}.

{pstd}
The hard part is to determine a set of scenarios that on the one hand push the model hard, but on the other
hand are still (somewhat) plausible.  This is not a technical problem, but a substantive one.  The best thing
one can do is look at the literature in your field, and see what kind of effects occur in real data.  
Remember that the effect specified in the {opt sd()} option can be thought of as effects of a standardized
variable. 

{pstd}
To keep the number of scenarios manageable (and estimateable) you will typically want to break your
sensitivity analysis up into several sub-analyses: One that only changes the amount of unobserved
heterogeneity, one that allows the amount of unobserved heterogeneity to change in differing degrees over 
a key variable, one that fixes the amount of unobserved heterogeneity to one number but allows the 
correlation between the unobserved variable and an observed variable of interest to change, etc.


{title:Example}

{pstd}
As a general strategy, it is often useful to build a (sub-)sensitivity analysis in three steps:

{pmore}
1) prepare the data

{pmore}
2) estimate the scenarios, and store those models using {help estimates}

{pmore}
3) analyse the stored scenarios 

{pstd}
The reason for separating the estimating and storing the scenarios from the analysing the scenarios
is that the estimation can take quite a bit of time, so you really want to do that only once, while
the analysis part consist of a lot of moving back and forth between scenarios and parameters that 
might be of interest. By estimating and storing the models you can avoid estimating the same scenario
multiple times and you more easily keep an overview of which scenarios you estimated.

{pstd}
Below is an example of how I would organize such a sensitivity analysis. I start with a basic model
without unobserved heterogeneity, In this case I model union membership of women who were asked in 
1988 where asked question regarding their union membership, marital status and how many years of 
schooling they attained.  The variable of interest is the education of the respondent (grade). 

{cmd}
    sysuse nlsw88, clear
    gen byte black = race == 2 if race <= 2
    gen byte baseline = 1

    scenreg union married never_married black grade baseline, ///
            sd(0) link(logit) or nocons
    est store s0
{txt}

{pstd}
Next I will estimate the other scenarios. In this case I will look at the influence of changing the 
amount of unobserved heterogeneity. So here I estimated three scenarios, where in each subsequent 
scenario the amount of unobserved heterogeneity increased by 1.

{cmd}
    scenreg union married never_married black grade baseline, ///
            sd(1) link(logit) or nocons
    est store s1

    scenreg union married never_married black grade baseline, ///
            sd(2) link(logit) or nocons
    est store s2

    scenreg union married never_married black grade baseline, ///
            sd(3) link(logit) or nocons
    est store s3
{txt}

{pstd}
Next we can use these stored scenarios to look if our conclusions are sensitive to the amount of 
unobserved heterogeneity. Say we are interested in the effect of education for women. The 
So we are looking at the parameter of grade. I start with creating an empty matrix in which I
will later store the results from the different scenarios. I have 4 scenarios, so the matrix will 
contain 4 rows. For each scenario I want to store the amount of unobserved heterogeneity, the
odds ratio for grade, and the p-value of the test whether this odds ratio equals 1 (which is 
equivalent to the test that the coefficient equals 0), so the matrix will contain three columns. 

{cmd}
    matrix res = J(4,3,.)
{txt}

{pstd}
Next I loop over the scenarios, which I called s0 till s3. I start with using {cmd: estimates restore}
to retrieve the appropriate scenario. I than test whether the effect of being white during the 
third scenario equals zero. Than I create a new local macro equal to `i' + 1, so it will run from
1 to 4. This macro will indicate which row of the matrix res I will want to fill. The final line 
says that we populate the `j'th row of matrix res with three numbers (see {help matrix substitution}): 

{pmore}
The first number is amount of unobserved heterogeneity used in that scenario. Here I used the fact 
that I created my scenarios in such a way that the amount of unobserved heterogeneity equals `i'. 
In general one creates the scenarios in such a way that they differ in some regular way, and you 
can often use that regularity to populate the first column of such a results matrix. 

{pmore}
The second  number is the odds ratio for grade.  Here I used the standard Stata way of retrieving
coefficients from models, for more see here: {help _variables}.  The odds ratio is exp(coefficient).

{pmore}
The final number is the p-value of the test whether that the odds ratio equals 1, i.e. the coeficient 
equals 0.  This p-value was left behind by the {help test} command as r(p).

{cmd}
    forvalues i = 0/3 {
        est restore s`i'
        test _b[grade] = 0
        local j = `i' + 1
        matrix res[`j',1] =  `i', exp(_b[grade]), r(p)
    }
    matrix colnames res = "sd" "or" "p"
{txt}

{pstd}
I can than tabulate the results using {help matlist}.   

{cmd}
    matlist res, names(columns) format(%9.3g)
{txt}   
        
{pstd}
Or I can graph them. To do that I first turn the matrix into variables in my dataset using 
{help svmat}. These variables I can than use to create my graphs.

{cmd}
    svmat res, names(col)

    twoway line or sd,                                       /// 
    xtitle("effect of the standardized unobserved variable"  ///
           "(log odds ratio)")                               ///
    ytitle("effect of grade (odds ratio)")

    twoway line p sd,                                        ///
    xtitle("effect of the standardized unobserved variable"  ///
           "(log odds ratio)")                               ///
    ytitle("p-value of test" "whether odds ratio for grade = 1")    
{txt}


{pstd}
Putting this all together:

{cmd}
    // start with preparing the data
    sysuse nlsw88, clear
    gen byte black = race == 2 if race <= 2
    gen byte baseline = 1

    // estimate the scenarios
    scenreg union married never_married black grade baseline, ///
            sd(0) link(logit) or nocons
    est store s0

    scenreg union married never_married black grade baseline, ///
            sd(1) link(logit) or nocons
    est store s1

    scenreg union married never_married black grade baseline, ///
            sd(2) link(logit) or nocons
    est store s2

    scenreg union married never_married black grade baseline, ///
            sd(3) link(logit) or nocons
    est store s3

    // collect estimates from the scenarios
    matrix res = J(4,3,.)

    forvalues i = 0/3 {
        est restore s`i'
        test _b[grade] = 0
        local j = `i' + 1
        matrix res[`j',1] =  `i', exp(_b[grade]), r(p)
    }
    matrix colnames res = "sd" "or" "p"

    // tabulate the estimates
    matlist res, names(columns) format(%9.3g)

    // graph the estimates  
    // first turn the matrix into variables
    svmat res, names(col)

    // graph the variables 
    twoway line or sd,                                       /// 
    xtitle("effect of the standardized unobserved variable"  ///
           "(log odds ratio)")                               ///
    ytitle("effect of grade (odds ratio)")

    twoway line p sd,                                        ///
    xtitle("effect of the standardized unobserved variable"  ///
           "(log odds ratio)")                               ///
    ytitle("p-value of test" "whether odds ratio for grade = 1")    
{txt}


{title:Author}

{p 4 4 2}Maarten L. Buis, Universitaet Tuebingen{break}maarten.buis@uni-tuebingen.de


{title:References}

{marker allison}{...}
{phang}
Allison, Paul D. (1999) "Comparing logit and probit coefficients across groups". 
{it:Sociological Methods & Research}, 28(2): 186-208.

{marker becker_caliendo}{...}
{phang}
Becker, Sascha O. and Marco Caliendo (2007) "Sensitivity analysis for average treatment effects", 
{it:The Stata Journal}, 7(1): 71-83.
{browse "http://www.stata-journal.com/article.html?article=st0121"}

{marker buis}{...}
{phang}
Buis, Maarten L (2010) "Chapter 7, The consequences of unobserved heterogeneity in a sequential logit model", 
In: Buis, Maarten L. {it:Inequality of Educational Outcome and Inequality of Educational Opportunity in the Netherlands during the 20th Century}.
PhD thesis.
{browse "http://www.maartenbuis.nl/dissertation/chap_7.pdf"}

{marker drukker_gates}{...}
{phang}
Drukker, David M. and Richard Gates (2006) "Generating Halton sequences using Mata",
{it:The Stata Journal}, 6(2): 214-228.
{browse "http://www.stata-journal.com/article.html?article=st0103"}

{marker mood}{...}
{phang}
Mood, Carina (2010) "Logistic regression: Why we cannot 
do what we think we can do, and what we can do about 
it." {it:European Sociological Review}, 26(1):6 7–82. 

{marker neuhaus_jewell}{...}
{phang}
Neuhaus, John M. and Nicholas P. Jewell (1993) "A 
Geometric Approach to Assess Bias Due to Omited 
Covariates in Generalized Linear Models." {it:Biometrika}, 
80(4): 807–815. 

{marker newson}{...}
{phang}
Newson, Roger (2003) "Stata tip 1: The eform() option of regress", 
{it:The Stata Journal}, 3(4): 445.
{browse "http://www.stata-journal.com/article.html?article=st0054"}

{marker rosenbaum}{...}
{phang}
Rosenbaum, Paul R (2002) {it:Observational Studies}. New York: Springer, 2d edition.

{marker rosenbaum_rubin}{...}
{phang}
Rosenbaum, Paul R. and Donald B. Rubin (1983) "Assessing Sensitivity to an Unobserved
Binary Covariate in an Observational Study with Binary Outcome." 
{it:Journal of the Royal Statistical Society. Series B}, 45(2): 212–218.

{marker train}{...}
{phang}
Train, Kenneth (2002) {it:Discrete Choice Methods with Simulation}. Cambridge: Cambridge 
University Press.

{marker williams}{...}
{phang}
Williams, Richard (2009) "Using heterogenous choice models to compare logit and probit
coefficients across groups", {it:Sociological Methods & Research}, 37(4): 531–559.


{title:Also see:}

{pstd}
Online: {helpb glm}, {helpb mata_halton()}

{pstd}
If installed: {helpb seqlogit}, {helpb mhbounds} 
