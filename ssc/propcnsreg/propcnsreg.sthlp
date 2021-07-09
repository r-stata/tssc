{smcl}
{* 30Okt2012}{...}
{* 14Sep2012}{...}
{* 15May2011}{...}
{* 30Aug2009}{...}
{* 24Mar2009}{...}
{* 24sep2006}{...}
{hline}
help for {hi:propcnsreg}
{hline}

{title:Fitting a measurement model with causal indicators}

{p 8 17 2}
{cmd:propcnsreg} 
{depvar} 
[{indepvars}] 
{ifin} 
{weight} 
{cmd:,} 
{opt con:strained(varlist_c)}
{opt lambda(varlist_l)} 
[
{opt stand:ardized}
{opt lcons}
{opt unit(varname)}
{opt mimic}
{opt logit}
{opt poisson}
{cmd:vce(}{it:{help vce_option:vcetype}}{cmd:)}
{cmdab:r:obust}
{opt cl:uster(clustervar)}  
{opt l:evel(#)} 
{c -(}{opt or} | {opt ir:r}{c )-}
{opt wald}
{it:{help propcnsreg##maximize_options:maximize_options}} 
]

{p 4 4 2}{cmd:by} {it:...} {cmd::} may be used with {cmd:propcnsreg}; see help
{help by}. 

{p 4 4 2}{cmd:fweight}s, {cmd:pweight}s, {cmd:aweight}s, and {cmd:iweight}s are 
allowed; see help {help weights}.


{title:Description}

{p 4 4 2} {cmd:propcnsreg} combines information from several observed 
variables into a single latent variable and estimates the effect of this latent 
variable on the dependent variable. {cmd:propcnsreg} assumes that the observed 
variables influence the latent variable. A common alternative assumption is 
that the latent variable influences the observed variables. For example,
{help factor:factor analysis} is based in this alternative assumption. To 
distinguish between these two situations some authors, following Bollen (1984) 
and Bollen and Lennox (1991), call the observed variables "effect indicators" 
when they are influenced by the latent variable, while they call the observed 
variables "causal indicators" when they influence the latent variable.   
Distinguishing between these two is important as they require very different 
strategies for recovering the latent variable. In a basic (exploratory) factor 
analysis, which is a model for effect indicators, one assumes that the only 
thing that the observed variables have in common is the latent variable, so any 
correlation between the observed variables must be due to the latent variable, 
and it is this correlation that is used to recover the latent variable. In 
{cmd:propcnsreg}, which estimates models for causal indicators, we assume that the 
latent variable is a weighted sum of the observed variables (and optionally an 
error term), and the weights are estimated such that they are optimal for 
predicting the dependent variable. 

{p 4 4 2} Models for dealing with causal indicators come in roughly three
flavors: A model with "sheaf coefficients" (Heise 1972), a model with 
"parametricaly weighted covariates" (Yamaguchi 2002), and a 
Multiple Indicators and Multiple Causes (MIMIC) model (Hauser Goldberger 1971). 
The latter two can be estimated using {cmd:propcnsreg}, while the former
can be estimated using {cmd:sheafcoef}, which is also available from SSC.


{dlgtab:Sheaf coefficient}

{p 4 4 2}The sheaf coefficient is the simplest model of the three. Say we want
to explain a variable y using three observed variables x1, x2, and x3, and we 
think that x1 and x2 actually influence y through a latent variable eta. 
Because eta is a latent variable we need to fix the origin and the unit. The
origin can be fixed by setting eta to 0 when both x1 and x2 are 0, the 
unit can be fixed by setting the standard deviation of eta equal to 1. The 
model starts with simple regression model, where the b-s are the regression
coefficients and e a normally distributed error term, with a mean of 0 and 
a standard deviation that is to be estimated:

{p 8 4 2}
(1) y = b0 + b1 x1 + b2 x2 + b3 x3 + e     

{p 4 4 2}and we want to turn this into, where l is the effect of the latent
variable and the c-s are the effects of the observed variables on the latent
variable:

{p 8 4 2}
(2) y = b0 + l eta + b3 x3 + e             

{p 8 4 2}
(3) eta = c0 + c1 x1 + c2 x2               


{p 4 4 2}
We can fix the origin of eta by constraining c0 to be 0, this way eta will be
0 when both x1 and x2 equal 0. This leaves c1 and c2. We want to choose 
values for these parameters such that eta optimally predicts y, and the standard
deviation of eta equals 1. This means that c1 and c2 are going to be a 
transformation of b1 and b2. We can start with an initial guess that c1 equals
b1 and c2 equals b2, and call the resulting latent variable eta'. This will 
get us closer to where we want to be, as we now have values for all parameters:
c0=0, c1'=b1, c2'=b2, and l'=1. The value for l' is derived from the fact that 
that is the only value where equations (2) and (3) lead to equation (1). 
However, the standard deviation of eta' will generally not be equal to 1, 
actually we can calculate the standard deviation of eta' as follows:

{p 8 4 2}
sd(eta') = sqrt{c -(}b1^2 var(x1) + b2^2 var(x2) + 2 b1 b2 cov(x1, x2){c )-}

{p 4 4 2}
We can recover eta by dividing eta' by its standard deviation, which means that 
the true values of c1 and c2 are actually b1/sd(eta') and b2/sd(eta'). If we
divide eta' by its standard deviation, then we must multiply l' by that same 
number to ensure that equations (2) and (3) continue to lead to equation (1). 
As a consequence l will equal sd(eta'). 

{p 4 4 2}
Notice that the effect of the latent variable will thus always be positive. 
This is necesary because we have only specified the origin and unit of the 
latent variable but not its direction. Say, x1 is the proportion of vegetables 
in a person's diet and x2 the number minutes spent a day excercizing. If we 
did not fix the effect of the latent variable to be positive, then there would 
always be two sets of estimates that would represent exactly the same 
information. If the c's are positive then the latent variable represent the 
healtyness of someone's lifestyle, and if the c's are negative then the latent
variable represent the unhealtyness of that person's lifestyle. Saying that
the healthyness of someone's lifestyle has a positive effect is exactly the 
same as saying that the unhealthyness of someone's lifestyle has a negative 
effect. Stata can't choose between these two, since both statements are the 
same, so we need to choose for it. We can do so by either fixing the 
direction of the latent variable or fixing the direction of the effect. The 
default is to fix the direction of the effect, but we can also specify one 
key variable and fix the direction of the latent variable relative to this 
key variable either by stating that the latent variable is high when the key 
variable is high and low when the key variable is low, or exactly the 
opposite.  

{p 4 4 2}
This illustrates how the following set assumptions can be used to recover
the latent variable and its effect of the dependent variable:

{pmore}
- the latent variable is a weighted sum of the observed variables such that the
latent variable optimally predicts the dependent variable.

{pmore}
- a constraint that fixes the origin of the latent variable.

{pmore}
- a constraint that fixes the unit of the latent variable.

{pmore}
- a constraint that either fixes the direction of the latent variable or the
direction of the effect of the latent variable.

{p 4 4 2}
However, a sheaf coefficient just reorders the information you obtained from
a regular regression. It is just a different way of looking at the regression 
results, which can be useful but it does not impose a testable constraint.

{p 4 4 2}
One possible application of the sheaf coefficient is the comparison of effect
sizes of different blocks of variables. For example, we may have a block of 
variables representing the family situation of the respondent and another
block of variables representing characteristics of the work situation and we
wonder whether the work situation or the family situation is more important
for determining a certain outcome variable. In that case we would estimate
a model with two latent variables, one for the family situation and one for
the work situation, and since both latent variables are standardized their 
effects will be comparable.


{dlgtab: Parametricaly weighted covariates}

{p 4 4 2}
The model with parametricaly weighted covariates builds on the model with
sheaf coefficients, but adds a testable constraint by assuming that the 
effect of the latent variable changes over another observed variable. This
means that instead of equation (2) we will be estimating equation (4) where
the effect of eta changes over x3:

{p 8 4 2}
(4) y = b0 + (l0 + l1 x3) eta + b3 x3 + e 

{p 4 4 2}
If we replace eta with equation (3), and fix the unit of eta by constraining c0 
to be zero, we get:

{p 8 4 2}
y = b0 + (l0 + l1 x3) (c1 x1 + c2 x2) + b3 x3 + e 

{p 8 4 2}
= b0 + (l0 + l1 x3) c1 x1 + (l0 + l1 x3) c2 x2 + b3 x3 + e 

{p 4 4 2}
This means the effect of x1 (through eta) on y equals (l0 + l1 x3) c1, and that the
effect of x2 (through eta) on y equals (l0 + l1 x3) c2. This implies the following 
constraint: for every value of x3, the effect of x1 relative to x2 will always be
{c -(}(l0 + l1 x3) c1{c )-} / {c -(}(l0 + l1 x3) c2{c )-} = c1/c2, which is a 
constant. In other words, the model with parametricaly weighted covariates imposes
a proportionality constraint. A test of this constraint is reported at the bottom
of the output from {cmd:propcnsreg} (when the {cmd:mimic} option is not specified).

{p 4 4 2} This proportionality constraint can also be of substantive interest without 
referring to a latent variable. Consider a 
model where one wants to explain the respondent's education ({it:ed}) with the 
eduction of the father ({it:fed}) and the mother ({it:med}), and that one is 
interested in testing whether the relative contribution of the mother's 
education has increased over time. {cmd:propcnsreg} will estimate this model 
under the null hypothesis that the relative contributions of {it:fed} and {it:med} 
have remained constant overtime. Notice that the effects of {it:fed} and {it:med} 
are allowed to change over time, but the effects of {it:fed} and {it:med} are 
constrained to change by the same proportion over time. So if the effect of 
{it:fed} drops by 10% over a decade, than so does the effect of {it:med}. 

{p 4 4 2}{cmd:propcnsreg} will allow you to identify the unit of the latent 
variable in one of the following three ways: 

{pmore}
- By setting its standard deviation of the latent variable to 1, effectively 
standardizing the latent variable. This is the default parametrization , but can also 
be explicitly requesting by specifying the {cmd:standardized} option. One can
specify one key variable by prefixing that variable in the {cmd:constrained}
option with either a {cmd:+} or a {cmd:-}. The {cmd:+} means that the latent
variable is high when the key variable is high and the latent variable is low
when the key variable is low. The {cmd:-} means exactly the opposite. If no
key variable is specified then l0 is constrained to be postive.

{pmore}
- By setting the coefficient l0 to 1, which means that c1 and c2 represent the 
indirect effects of x1 and x2 through the latent variable on y when x3 equals 0. 

{pmore}
- By setting either the coefficient c1 or c2 to 1, which means that the unit of the latent 
variable will equal the unit of either x1 or x2 respectively. This can be done by
specifying the {opt unit(varname)} option.


{dlgtab:MIMIC}

{p 4 4 2}
The MIMIC model builds on the model with parametricaly weighted covariates by 
assuming that the latent variable is measured with error. This means that the
following model is estimated:

{p 8 4 2}
(5) y = b0 + (l0 + l1 x3) eta + b3 x3 + e_y

{p 8 4 2}
(6) eta = c0 + c1 x1 + c2 x2 + e_eta   

{p 4 4 2}
Where e_y and e_eta are independent normally distributed error terms with means zero 
and standard deviations that need to be estimated. By replacing eta in equation (5) 
with equation (6) one can see that the error term of this model is:

{p 8 4 2}
e_y + (l0 + l1 x3) e_eta

{p 4 4 2}
This combined error term will also be normally distributed, as the sum of two 
independent normally distributed variables is itself also normally distributed, with 
a mean zero and the following standard deviation:

{p 8 4 2}
sqrt{c -(}var(e_y) + (l0 + l1 x3)^2 var(e_eta){c )-}

{p 4 4 2}
So the empirical information that is used to separate the standard deviation of e_y 
from the standard deviation of e_eta is the changes in the residual variance over x3. 
So the data will only contain rather indirect information that can be used for 
estimating this model, and the model may thus not always converge. However, if the 
model is correct it will enable one to control for measurement error in the latent 
variable. 

{p 4 4 2}
There is an important downside to this model, and that is that heteroscedasticity, 
and in particular changes in the variance of e_y over x3, could have a distorting 
influence on the parameter estimates of l0 and l1. Consider again the example where 
one wants to explain the respondent's education with the education of the father and 
the mother, but now assume that we are interested in how the effect of the latent 
variable changes over time. In this case we have good reason to suspect that the 
variance of e_y will also change over time: Education consists of a discrete number 
of categories, and in early cohorts most of the respondents tend to cluster in the 
lowest categories. Over time the average level of education tends to increase, which 
means that the respondents tend to cluster less in the lowest category, and have 
more room to differ from one another. As a consequence the residual variance is likely
to have increased over time. Normally this heteroscedasticity would not be an issue
of great concern, but in a MIMIC model this heteroscedasticity is incorrectly 
interpreted as indicating that there is measurement error in the latent variable 
representing parental education. Moreover, this "information" on the measurement error 
is used to "refine" the estimates of l0 and l1. So, this would be an example where the 
MIMIC model would not be appropriate.


{title:Options}

{dlgtab 4 2:Model}

{phang}
{opt con:strained(varlist_c)} specifies the variables can be thought of as being 
measurements of the same latent variable. The effects of these variables are to be 
constrained to change by the same proportion as the variables specified in 
{opt lambda()} change. 

{pmore}
If the {cmd:standardized} option is specified one can 
identify one variable as a key variable that identifies the direction of the latent
variable, either in the same direction as the key variable ({cmd:+}) or in the 
opposite direction ({cmd:-}). If the {cmd:standardized} option is specified but no
key variable is specified, then the constant of the lambda equation will be 
constrained to be positive.

{phang}
{opt lambda(varlist_l)} specifies the variables along which the effects of the
latent variable changes. 

{phang}
{opt mimic} specifies that a MIMIC model is to be estimated.

{phang}
{opt logit} specifies that the dependent variable is binary and that the influence of 
the latent and control variables on the probability is modeled through a logistic
regression model.

{phang}
{opt poisson} specifies that the dependent variable is a count and that the influence of 
the latent and control variables on the rate is modeled through a poisson regression
model. 

{dlgtab 4 2:Identification}

{phang}
{opt standardized} specified that the unit of the latent variable is identified by 
constraining the standardard deviation of the latent variable to be equal to 1. This 
is the default parametrization.

{phang}
{opt lcons} specifies that the parameters of the variables specified in the 
option {cmd: constrained()} measure the indirect effect of these variables through the
latent variable on the dependent variable when all variables specified in the option 
{cmd: lamda()} are zero. 

{phang}
{opt unit(varname)} specifies that the scale of the latent variable is 
indentified by constraining the unit of the latent variable to be equal to the unit
of {it: varname}. The variable {it: varname} must be specified in {it: varlist_c}.

{dlgtab 4 2:SE/robust/reporting}

{phang}
{cmd:vce(}{it:{help vce_option:vcetype}}{cmd:)} specifies the type of standard error 
reported, which includes types that are derived from asymptotic theory, that are robust 
to some kinds of misspecification, that allow for intragroup correlation, and that use 
bootstrap or jackknife methods; see {help vce_option}.

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
{opt or} specifies that odds ratios are to be displayed. If the {cmd:lcons} option
is specified than the parameters in all three equations (unconstrained, lambda, and
unconstrained) will be exponentiated. In all other cases only the parameters in the
first two equations (unconstrained, and lambda) will be exponentiated. This option
is only allowed in combination with the {cmd:logit} option.

{phang}
{opt irr} specifies that incidence rate ratios are to be displayed. If the 
{cmd:lcons} option is specified than the parameters in all three equations 
(unconstrained, lambda, and unconstrained) will be exponentiated. In all other 
cases only the parameters in the first two equations (unconstrained, and lambda) 
will be exponentiated. This option is only allowed in combination with the 
{cmd:poisson} option.

{phang}
{opt wald} specifies that the test of the proportionality constrained is to be
a Wald test instead of a likelihood ratio test. This is the default when robust
standard errors have been used. This option is not allowed in combination with 
the {cmd:mimic} option.

{marker maximize_options}{...}
{dlgtab 4 2:maximize_options}

{p 4 4 2}
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


{marker example}{...}
{title:Example}

{pstd}
Example illustrating the use of the {cmd:poisson} option to model a 
non-negative but not necessarily a count dependent variable. For its 
advantages see: (Cox et al. 2007; Nichols, 2010; Gould 2011). However,
in a {help propcnsreg_sim:simulation} the point estimates seem to be 
unbiased but the robust standard errors don't seem to perform as well. 
So I use bootstrap standard errors instead of robust standard errors. 
This example also illustrates the use of {help predict} to help with 
interpreting the model:

{cmd}{...}
        sysuse nlsw88, clear

        gen hs = grade == 12 if grade < .
        gen sc = grade > 12 & grade < 16 if grade < .
        gen c = grade >= 16 if grade < .

        gen tenure2 = tenure^2
        gen tenureXunion = tenure*union
        gen tenure2Xunion = tenure2*union

        gen hours2 = ( hours - 40 ) / 5
		
        gen white = race == 1 if race < .

        propcnsreg wage tenure* union white hours2, /*
        */ lambda(tenure tenureXunion union) /*
        */ constrained(hs sc c) unit(c) /*
        */ poisson vce(bootstrap) irr

        predict double effect, effect
        predict double se_effect, stdp eq(lambda)
        gen double lb = effect - invnormal(.975)*se_effect
        gen double ub = effect + invnormal(.975)*se_effect
		
        replace effect = exp(effect)
        replace lb = exp(lb)
        replace ub = exp(ub)
		
        sort tenure

        twoway rarea lb ub tenure if union == 1 || /* 
        */ rarea lb ub tenure if union== 0, /*
        */ astyle(ci ci) || /*
        */ line effect tenure if union == 1 || /* 
        */ line effect tenure if union == 0, /*
        */ yline(1) clpattern(longdash shortdash) /*
        */ legend(label(1 "95% conf. int.") /*
               */ label(2 "95% conf. int.") /*
               */ label(3 "union")          /*
               */ label(4 "non-union")      /*
               */ order(3 4 1 2))           /*
        */ ytitle("effect of education on wage")
{txt}{...}
{phang2}{it:({stata "propcnsreg_ex 1":click to run})}{p_end}

{pstd}
An example for a binary dependent variable. Note that in this
case both the parameters in the unconstrained and the lambda
equation are both odds ratios. 

{cmd}{...}
        sysuse nlsw88, clear
        gen byte high = occupation < 3 if !missing(occupation)
        gen byte white = race == 1 if !missing(race)

        gen byte hs = grade == 12 if !missing(grade)
        gen byte sc = grade > 12 & grade < 16 if !missing(grade)
        gen byte c = grade >= 16 if !missing(grade)

        propcnsreg high white ttl_exp married never_married age, ///
                   lambda(ttl_exp white) ///
                   constrained(hs sc c) unit(c) logit or 
{txt}{...}
{phang2}{it:({stata "propcnsreg_ex 2":click to run})}{p_end}

{title:Author}

{p 4 4 2}Maarten L. Buis, Wissenschaftszentrum Berlin für Sozialforschung (WZB){break}maarten.buis@wzb.eu


{title:References}

{p 4 4 2}
Bollen, Kenneth A. 1984. "Multiple Indicators: Internal Consistency or
No Necessary Relationship" {it:Quality and Quantity} 18(4): 377{c -}385.

{p 4 4 2}
Bollen, Kenneth A. and Richard Lennox. 1991. "Conventional Wisdom
on Measurement: A Structural Equation Perspective"
{it:Psychological Bulletin} 110(2): 305{c -}314.

{p 4 4 2}  Cox, Nicholas J., Jeff Warburton, Alona Armstrong and Victoria 
J. Holliday (2007) "Fitting concentration and load rating curves with 
generalized linear models" {it:Earth Surface Processes and Landforms}, 33(1):25--39. 

{p 4 4 2}
Gould, William. (2011) "Use poisson rather than regress; tell a friend" 
{it:Not Elsewhere Classified, the official Stata blog.}
{browse "http://blog.stata.com/2011/08/22/use-poisson-rather-than-regress-tell-a-friend/"}

{p 4 4 2}
Hauser, Robert M. and Arthur S. Goldberger. 1971. 
"The Treatment of Unobservable Variables in Path Analysis." 
{it:Sociological Methodology} 3: 81{c -}117.

{p 4 4 2}
Heise, David R. 1972. "Employing nominal variables, induced 
variables, and block variables in path analysis." 
{it:Sociological Methods & Research} 1(2): 147{c -}173.

{p 4 4 2}
Nichols, Austin (2010) "Regression for nonnegative skewed dependent variables" 
{it:Stata Conference, 2010}. 
{browse "http://www.stata.com/meeting/boston10/boston10_nichols.pdf"}

{p 4 4 2}
Yamaguchi, Kazuo. 2002. "Regression models with parametrically 
weighted explanatory variables." {it: Sociological Methodology}
32: 219{c -}245.


{title:Suggested citation if using propcnsreg in published work}

{p 4 4 2}
{cmd:propcnsreg} is not an official Stata command. It is a free contribution 
to the research community, like a paper. Please cite it as such.

{p 4 4 2}
Buis, Maarten L.  2007. "PROPCNSREG: Stata program fitting a linear regression 
with a proportionality constraint by maximum likelihood" 
{browse "http://ideas.repec.org/c/boc/bocode/s456858.html"}


{title:Also see:}

{p 4 4 2}
{helpb propcnsreg_postestimation}, {helpb factor}, {helpb sheafcoef} (if installed) 
