{smcl}
{* MLB 25Okt2013}{...}
{* MLB 30Apr2012}{...}
{* MLB 11Apr2012}{...}
{* MLB 22Mar2012}{...}
{* MLB 10Apr2010}{...}
{* 23May2007}{...}
{hline}
help for {cmd:seqlogit postestimation}
{hline}

{title:Title}

{p2colset 5 32 35 2}{...}
{p2col :{hi:seqlogit postestimation} {hline 2}}Postestimation tools for
seqlogit{p_end}
{p2colreset}{...}

{title:Description}

post estimation tools specifically for {help seqlogit}:

{p 4 4 2}{helpb seqlogit postestimation##seqlogitdecomp:seqlogitdecomp} Makes a graph showing
a decomposition of the effect of a variable on the highest achieved level of the dependent 
variable into effects of that variable on passing each transition and the importance of that
transition as described in (Buis 2010).

{p 4 4 2}{helpb seqlogit postestimation##uhdesc:uhdesc} creates a table of describtive statistics
of the unobserved variable at each transition. This is only available when the {cmd:sd()} option 
was used for {help seqlogit}.

{p 4 4 2}{helpb seqlogit_sensitivity} is strictly speaking not a tool, but a helpfile showing 
how to run a sensitivity analysis with {cmd:seqlogit}.


The following standard postestimation commands are also available:

{synoptset 14 tabbed}{...}
{p2coldent :command}description{p_end}
{synoptline}
{synopt :{helpb estat}}AIC, BIC, VCE, and estimation sample summary{p_end}
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_margins
INCLUDE help post_nlcom
{synopt :{helpb seqlogit postestimation##predict:predict}}predictions{p_end}
INCLUDE help post_predictnl
INCLUDE help post_suest
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}



{marker seqlogitdecomp}{...}
{hline}
help for {cmd:seqlogitdecomp}
{hline}

{title:Syntax for seqlogitdecomp}

{p 8 17 2}
{cmd:seqlogitdecomp} 
{cmd:[}
varlist
{cmd:]}
{cmd:,} 
{cmd:[}
{opt overat(overatlist)}
{c -(} {opt tab:le} | {opt area} {c )-}
{opt marg}
{opt at(atlist)}
{opt subt:itle(titlelist)}
{opt eql:abel(labellist)}
{opt eqlegend}
{opt xl:ine(linearg)}
{opt yl:ine(linearg)}
{opt ti:tle(title)}
{opt na:me(name, replace)}
{opt ysc:ale(axis_suboptions)}
{opt xsc:ale(axis_suboptions)}
{opt ysiz:e(#)}
{opt xsiz:e(#)}
{cmd:format(}{help %fmt}{cmd:)}
{cmd:]}

{title:Description}

{p 4 4 2}
The idea behind a sequential logit model is that it models the influence of
explanatory/independent/right-hand-side/x variables on the probability of 
passing a set of transitions. For example, one can model the process of 
attaining education as two transitions: a transition between finishing high 
school or not, and a transition between wheter one went to college or not 
given that one finished high school. If we assign a value to each of these 
end states --- in the case of education those would typically be (pseudo-)years 
of education --- than one can also study the effect of the explanatory 
variables on the expected final outcome. 

{p 4 4 2}
The aim of {cmd:seqlogitdecomp} is to study the relationship between the effects
on each transition and the effects on the final outcome. It turns out (Buis 2010) 
that these total effects --- that is, the marginal effect, which is the derivative 
of the expected final outcome with respect to the explanatory variables --- are a 
weighted sum of the effects on each transition. 

{p 4 4 2}
If these transition specific effects are measured in terms of log odds ratios, than the 
weight assigned to each transition is the product of three elements: the proportion at 
risk, the variance, and the expected gain from passing. So a tranisition becomes more
important if more people have to face that transition. The variance component of the
weight is a function that is small when virtually everybody passes a transition or 
everybody fails a transition, and is large when the probability of passing is about 
50%. So, a transition does not add much to the total effect if virtually everybody 
passes or fails that transition. Finally, a transition becomes more important if the
expected gain from passing increases.

{p 4 4 2}
If these transition specifc effects are measured in terms of marginal effects, than the
weights assigned to each transition are the product of two elements: the proportion at 
risk, and the expected gain from passing. 

{p 4 4 2} 
{cmd:seqlogitdecomp} displays a graph or a table showing a decomposition of 
the effect of a variable on the final outcome into effects of the variable on 
passing each transition and the importance of each transition (the weight) 
as described in (Buis 2010). For the graph the variable whose effect will be 
decomposed is specified in the {opt ofinterest()} option in {helpb seqlogit}. 
For the table the variable is specified as the {it:varlist}, the default is
all variables in the {cmd:seqlogit} model. 

{p 4 4 2}
The effect on the expected value can differ between groups in the 
population, for example cohorts. The default graph is designed to show how these 
differences are due to differences in effects on the transitions across groups 
and differences in the importance of each transition across groups. To continue 
the example: the effect of parental status can change over cohorts, and 
{seqlogitdecomp} will tell the extend to which this is due to changes in the 
effects on the transitions between levels of education or changes in the 
importance of each transition. The graph that will be displayed with the {cmd:area} 
option shows the contribution of each transition without splitting it up into 
weights and effects.

{p 4 4 2}
The table is designed to show this extra detail of this decomposition without
the comparison of groups. It will show the effects on each transition, the weights
and their components, the probabiltiy of passing each transition, and the effect
on the final outcome. It also shows the standard errors for each of these components 
except for those components that are by definition fixed and thus not uncertain, e.g. 
the proportion at risk at the first transitions, which is by definition 1.


{title:Options}

{dlgtab 4 2:Main options}

{phang}
{opt overat(overlist)} Specifies the values of the explanatory variables 
of the groups that are to be compared. It cannot be specified in combination
with the {cmd:table} or {cmd:area} option. It overrides any value specified in the {opt at} 
option. Each comparison is seperated by a comma. The syntax for {it:overlist} is:

{p 8 8 2}
{it:varname_1} # [{it:varname_2} # [...]], {it:varname_1} # [{it:varname_2} # [...]], [...] 

{phang}
{opt at(atlist)} specifies the values at which the equations are evaluated.
The syntax for {it:atlist} is: {it:varname} # [{it:varname} # ...]. The 
equations will be evaluated at the mean values of any of the variables not 
specified in {opt at} if those variables are not categorical 
{help fvvarlist:factor variables}. For cateforical factor variables the default
is the minimum (the first category).

{p 8 8 2}
Say the dependent variable is highest achieved level of education, which is 
influenced by child's Socio Economic Status (ses) and cohort (coh) and
the interaction between ses and coh (c.ses#c.coh). We want to compare the 
decomposition of the effect of ses over different cohorts for mean value of 
ses. Say that coh has only three values: 1, 2, and 3 and the mean value of 
ses is .5. Than the {opt overat} and {otp at} options would read:

{p 8 8 2}overat( coh 1, coh 2, coh 3 )  at( ses .5 ){p_end}


{phang}
{opt marg} specifies that the transition specific effects are marginal effects 
instead of log odds ratios. This option may not be specified in combination witht the
{cmd:area} option.

{phang}
{opt table} specifies that the decomposition is to be displayed as a table instead
of a graph. It consists of multiple calls to {help margins}, and it can take a while
to run. The default is to show an array of rectangles whose width represents the weight
of a transition and the height the effect. 

{phang}
{opt area} specifies that an area graph is displayed showing the contribution of each
transition. The default is to show an array of rectangles whose width represents the weight
of a transition and the height the effect, thus splitting each transitions contribution in an
effect and a weight. 

{phang}
{cmd:format(}{help %fmt}{cmd:)} specifies the format used to display the results in 
the table. This option can only be specified in combination with the {cmd:table} option.

{dlgtab 4 2:Graph options}

{pstd}
The graph options cannot be specified in combination with the {cmd:table} option.

{phang}
{opt subt:itel(titlelist)} specifies the titles above each group, cohort in
the example above. The syntax of {it: titlelist} is "string" "string" [...].
The number of titles must equal the number of groups. This option may not be
specified in combination with the {cmd:area} option.

{phang}
{opt eql:abel(labellist)} specifies labels for each transition.  The syntax 
of {it: labellist} is "string" "string" [...]. The number of labels must
equal the number of transitions. If one wants to let the label span more than
one line, one can use `" "string1" "string2" "'.

{phang}
{opt eqlegend} specifies that a legend is used to identify the different 
transitions. By default the transitions are identified using titles on the 
right of the graph.

{phang}
{opt xl:ine(numlist)} see: {help added line options}

{phang}
{opt yl:ine(numlist)} see: {help added line options}

{phang}
{opt ti:tle(title)} see: {help title_options}

{phang}
{opt na:me(name, replace)} see: {help name_option}

{phang}
{opt [y|x]sc:ale(axis sub options)} see: {help axis_scale_options}

{phang}
{opt [y|x]lab:le(rule_or_values)} see: {help axis_options}

{phang}
{opt [y|x]title(title)} see: {help axis_title_options} 

{phang}
{opt [y|x]siz:e(#)} see: {help region_options}


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
		
    seqlogitdecomp paeduc, table     ///
       at(coh 1.5 south 0 paeduc 12) 
	
    seqlogitdecomp,  area                                                 ///
       at(south 0 paeduc 12)                                              ///
       eqlabel(`""less than high school" "versus" "high school or more""' ///
               `""high school" "versus" "any college""'                   ///
               `""junior college" "versus" "college""' )                  ///
       xlab(2 "1920" 3 "1930" 4 "1940" 5 "1950" 6 "1960" 7 "1970")        ///
       xtitle("year of birth")
{txt}{...}


{marker uhdesc}{...}
{hline}
help for {cmd:uhdesc}
{hline}

{title:Syntax for uhdesc}

{p 8 17 2}
{cmd:uhdesc} 
{cmd:,} 
{cmd:[}
{opt at(atlist)}
{opt overat(overatlist)}
{opt l:evels(levellist)}
{opt overlab(stringlist)}
{opt draws(#)}
]

{title:Description}

{p 4 4 2} 
{cmd:uhdesc}  creates a table of describtive statistics of the unobserved variable at each 
transition. This is only available when the {cmd:sd()} option was used for {help seqlogit}.
When the {cmd:sd()} option is specified one is estimating the parameters that would occur
if there is an unobserved variable, which is normally distributed, wich at the first 
transition has a mean of zero, a standard deviation as specified in the {cmd:sd()} option, 
and is uncorrelated witht the observed covariates, and one correctly controlled for this
unobserved variable. The consequences of such an unobserved variable and the way to estimate
the parameters in such a scenario are discussed in (Buis 2011). The aim of {cmd:uhdesc} is
to show what happens to this unobserved variable at the different transitions, and thus
get an insight into why the estimates in the scenario are different (or not) from a regular
sequential logit.


{title:Options}

{phang}
{opt overat(overlist)} Specifies the values of the explanatory variables 
of the groups that are to be compared. It overrides any value specified 
in the {opt at} option. Each comparison is seperated by a comma. The 
syntax for {it:overlist} is:

{p 8 8 2}
{it:varname_1} # [{it:varname_2} # [...]], {it:varname_1} # [{it:varname_2} # [...]], [...] 

{phang}
{opt at(atlist)} specifies the values at which the equations are evaluated.
The syntax for {it:atlist} is: {it:varname} # [{it:varname} # ...]. The 
equations will be evaluated at the mean values of any of the variables not 
specified in {opt at}.

{p 8 8 2}
Say the dependent variable is highest achieved level of education, which is 
influenced by child's Socio Economic Status (ses) and cohort (coh) and
the interaction between ses and coh (_ses_X_coh). We want to compare the 
decomposition of the effect of ses over different cohorts for mean value of 
ses. Say that coh has only three values: 1, 2, and 3 and the mean value of 
ses is .5. Than the {opt overat} and {otp at} options would read:

{p 8 8 2}overat( coh 1, coh 2, coh 3 )  at( ses .5 ){p_end}

{p 8 8 2}
Notice that the values for the interaction term need not be specified in the
{opt overat()} option, as long as it was created using the {opt over()} 
option in {help seqlogit}.

{phang}
{opt overlab(stringlist)} specifies the label that is to be attached to 
each group specified in the {cmd:overatlist()} option. Spaces are not allowed
but an _ will be displayed as an space. The number of labels has to be the
same as the number of groups specified in the {cmd:overatlist()} option.

{p 8 8 2}
To continue the example above: Say that a value of 1 on the variable coh 
corresponds to the cohort born in 1950, a value 2 corresponds to the cohort 
born in 1970, the value 3 corresponds to the cohort born in 1990, then the 
{cmd overlab()} option would read:

{p 8 8 2}overlab(1950 1970 1990)

{phang}
{opt l:evels(levellist)} specifies the values attached to each level of the
dependent variable. If it is not specified the values of the dependent 
variabel will be used. The syntax for {it:levels} is: # = # [, # = #, ...] 

{title:Example}
{cmd}
    sysuse nlsw88, clear
    gen ed = cond(grade< 12, 1, ///
             cond(grade==12, 2, ///
             cond(grade<16,3,4))) if grade < .
    gen byr = (1988-age-1950)/10
    gen white = race == 1 if race < .

    seqlogit ed byr south,                   ///   
             ofinterest(white) over(byr)     ///
             tree(1 : 2 3 4, 2 : 3 4, 3 : 4) ///
             or sd(1)
    
    uhdesc
{txt}


{marker predict}{...}
{hline}
help for {cmd:predict}
{hline}

{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} 
[{cmd:,} {it:statistic} 
{opt o:utcome(#)}
{opt trans:ition(#)}
{opt c:hoice(#)}
{opt eq:uation(#)}
{opt levels(levellist)}
]

{synoptset 14 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{synopt :{cmd:xb}}xb, fitted values{p_end}
{synopt :{cmd:stdp}}standard error of the prediction{p_end}
{synopt :{cmdab:trp:r}}probability of passing transition{p_end}
{synopt :{cmdab:tra:trisk}}proportion of respondents at risk of passing 
transition{p_end}
{synopt :{cmdab:trv:ar}}variance of the indicator variable indicating 
whether or not the respondent passed the transition{p_end}
{synopt :{cmdab:trg:ain}}difference in expected highest achieved level
between those that pass the transition and those that do not{p_end}
{synopt :{cmdab:trw:eight}}weight assigned to transition if transition 
specific effects are log odds ratios{p_end}
{synopt :{cmdab:trmw:eight}}weight assigned to transition if transition 
specific effects are marginal effects{p_end}
{synopt :{cmdab:treff:ect}}contribution of transition to the total effect.{p_end}
{synopt :{cmdab:p:r}}probability that an outcome is the highest achieved 
outcome.{p_end}
{synopt :{cmd:y}}expected highest achieved level{p_end}
{synopt :{cmdab:eff:ect}}Effect of variable of interest on expected 
highest achieved level. This variable is specified in the {cmd:ofinterest()}
option in {cmd:seqlogit}. Interactions with the variables specified in the 
{cmd:over()} option  of {cmd:seqlogit} are automatically taken into account.
{p_end}
{synopt :{cmdab:resid:uals}}difference between highest achieved level and
expected highest achieved level.{p_end}
{synopt :{opt sc:ore}}first derivative of the log likelihood with respect 
to the linear predictor. {p_end}
{synoptline}
{p2colreset}{...}


{title:Options for predict}

{phang}
{opt trans:ition(#)} specifies the transition, 1 is the first transition 
specified in the {opt tree} option in {cmd:seqlogit}, 2 the second, etc.

{phang}
{opt choice(#)} specifies the choice within the transition, 0 is the choice 
(the reference category), 1 the second, etc.

{phang}
{opt eq:uation(#)} specifies the equation, #1 is the first equation, #2 the 
second, etc.

{phang}
{opt l:evels(levellist)} specifies the values attached to each level of the
dependent variable. If it is not specified the values of the dependent 
variabel will be used. The syntax for {it:levels} is: # = # [, # = #, ...] 


{title:References}

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
{browse "http://dx.doi.org/10.1016/j.rssm.2010.12.006"}


{title:Also see}

{p 4 13 2}
Online: help for {helpb seqlogit}, {helpb estimates}, {helpb lincom}, 
{helpb lrtest}, {helpb mfx}, {helpb nlcom}, {helpb predictnl},
{helpb suest}, {helpb test}, {helpb testnl}
{p_end}

