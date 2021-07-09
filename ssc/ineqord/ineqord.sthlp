{smcl}
{* *! version 1.0.3  March 2020}{...}

{hline}
help for {hi:ineqord}{right:Stephen P. Jenkins (March 2020)}
{hline}

{viewerdialog ineqord "dialog ineqord"}{...}
{viewerjumpto "Syntax" "ineqord##syntax"}{...}
{viewerjumpto "Description" "ineqord##description"}{...}
{viewerjumpto "Options" "ineqord##options"}{...}
{viewerjumpto "Examples" "ineqord##examples"}{...}
{viewerjumpto "Stored results" "ineqord##results"}{...}
{viewerjumpto "References" "ineqord##references"}{...}

{title:Indices of inequality and polarization for ordinal data}
 
{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:ineqord}
{varname}
[{it:{help ineqord##weight:weight}}]
{ifin}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt a:lpha(#)}} calculate additional Cowell-Flachaire index with parameter #{p_end}
{synopt:{opt nl:evels(#)}} specify total number of levels of response {cmd:varname}: see below {p_end}
{synopt:{opt minl:evel(#)}} specify minimum level of response {cmd:varname}: see below {p_end}
{synopt:{opt ust:atusvar(string)}} save Cowell-Flachaire upward-looking status variable after calculation {p_end}
{synopt:{opt dst:atusvar(string)}} save Cowell-Flachaire downward-looking status variable after calculation {p_end}
{synopt:{opt catv:als(string)}} save distinct values of the response in a new variable {p_end}
{synopt:{opt catp:rops(string)}} save sample category proportions in a new variable {p_end}
{synopt:{opt catcp:rops(string)}} save sample cumulative proportions in a new variable {p_end}
{synopt:{opt catsp:rops(string)}} save sample cumulative survivor proportions in a new variable {p_end}
{synopt:{opt gld:var(string)}} save Generalized Lorenz ordinates for Cowell-Flachaire downward-looking status in a new variable {p_end}
{synopt:{opt glu:var(string)}} save Generalized Lorenz ordinates for Cowell-Flachaire upward-looking status in a new variable {p_end}
{synopt:{opt hp:lus(string)}} save H+ ordinates in a new variable {p_end}
{synopt:{opt hm:inus(string)}} save H- ordinates in a new variable {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
	{opt by} and {opt statsby} are allowed; see {help prefix}.
{p_end}
{marker weight}{...}
{p 4 6 2}
	{opt aweight}s, {opt fweight}s, {opt pweight}s, and {opt iweight}s are allowed.  
	See {help weight}.
{p_end}

{marker description}{...}
{title:Description}

{p 4 4 2} 
{cmd:ineqord} calculates indices of inequality and polarization for ordinal data 
recorded in {cmd:varname}: the Allison-Foster index, the normalized Average Jump index, 
multiple Apouey indices (parameters 0.5, 1, and 2), multiple Abul Naga-Yalcin
indices (parameters ({it:a},{it:b}) = (1,1), (2,1), (1,2), (4,1) and (1,4)), 
multiple Cowell-Flachaire indices (for peer-inclusive downward and upward-looking status; 
parameter {it:alpha} = 0, 0.25, 0.5, 0.75 and, optionally, another {it:alpha} value 
between 0 and 1), the Jenkins index, and also the standard deviation. Optionally, 
{cmd:ineqord} also derives estimates of cumulative distribution functions, 
survivor functions, Generalized Lorenz curves for 'status', and H-plus and H-minus
curves, and saves them in new variables. These can be used to describe 
ordinal data distributions and to undertake dominance checks of differences 
between distributions.

{p 4 4 2} 
Summarizing and comparing distributions of individuals' subjective well-being (SWB) 
is the principal application intended for {cmd:ineqord}, where SWB refers to e.g. 
overall life satisfaction (or satisfaction with a particular life domain such as work or
health), health status, or happiness. For example, regarding life satisfaction, 
respondents may be presented with a linear integer scale running from 0 to 10 
and asked to respond to the question "overall, how satisfied are you with your 
life nowadays where 0 is 'not at all satisfied' and 10 is 'completely satisfied'?" 
Similar scales are used for other SWB measures. Some Likert-like SWB scales employ a 
mixture of negative and non-negative integers to label the scale levels. It is 
assumed that respondents who report the same score have the same well-being. 

{p 4 4 2} 
{cmd:ineqord} assumes the user has respondent-level data: each response on 
{cmd:varname} refers to the ordinal well-being score for a respondent. If the
user has only grouped data on the distribution of the well-being variable, 
the user needs first to construct an individual-level dataset using this
information. See the Examples section for illustrations.

{p 4 4 2} 
The indices calculated by {cmd:ineqord} summarize dispersion in the distribution
of responses across the {it:K} levels of {cmd:varname}, where {it:K} >= 3. The 
levels have numerical labels {it:c}_1, {it:c}_2, {it:c}_3, ..., {it:c}_{it:K}, where 
{c -}oo < {it:c}_1 < {it:c}_2  < {it:c}_3  < ...  < {it:c}_{it:K} < oo. The `linear
integer' scale cited below is the one with {it:c}_{it:k} = {it:k}, for each {it:k} = 
1, 2, 3, ..., {it:K}. The empirical distribution of responses is described by the 
proportion of the {it:N} individuals who report the {it:k}th level, {it:f_k}, 
for each {it:k}. The cumulative distribution function is described 
by the proportion of individuals reporting the {it:k}th level or lower, 
{it:F_k} = Sum(from 1 to {it:k}) {it:f_k}, for each {it:k}. The survivor 
function is described by the proportion of individuals reporting the {it:k}th 
level or higher, {it:S_k} = Sum(from {it:k} to {it:K}) {it:f_k}, for each {it:k}.

{p 4 4 2} 
A commonly-used measure of inequality of such ordinal data, especially life
satisfaction and happiness data, is the standard deviation. Use of this measure is
inappropriate because it assumes that {cmd:varname} is measured on a ratio scale. 
(Kalmijn and Veenhoven (2005) acknowledge this issue but claim that the 
standard deviation is an appropriate measure nonetheless.) 

{p 4 4 2} 
Economists specialising in inequality measurement have long been critical of the 
application to ordinal data of the standard deviation and other inequality indices 
typically applied to variables measured on a ratio scale. These indices use the 
mean as the reference point for assessing spread but with ordinal data, the 
value of the mean is contingent on the scale used. For critiques, see e.g. 
Allison and Foster (2004), Cowell and Flachaire (2017), and Dutta and Foster 
(2013). These authors and others propose inequality measures that respect the 
ordinal nature of the data. In one tradition, indices characterize greater 
inequality as greater spread about the median. The other tradition characterizes
greater inequality as greater spread away from a maximum value. 

{p 4 4 2} 
The Allison-Foster index is the difference between the mean score for 
respondents with scores above the median minus the mean score for respondents 
with scores below the median. This polarization index was first proposed by 
Allison and Foster (2004). Dutta and Foster (2013) provide more extensive 
discussion of it, and the formulae used by {cmd:ineqord} are based on their 
equations 1 and 2 (p. 398). 

{p 4 4 2}
The two-parameter indices proposed by Abdul Naga and Yalcin (2008, 
{it:ANY}({it:a},{it:b}), {it:a},{it:b} >= 1 are a form of weighted difference 
between the percentage of people in the lower half of the distribution and 
the percentage in the upper half of the distribution. The parameters tune the 
weights given to the two halves. {it:ANY}(1,1) weights the two halves equally. 
Roughly speaking, when {it:a} > {it:b}, {it:ANY}({it:a},{it:b}) gives greater 
weight to the top half of the distribution. According to Abul Naga and Yalcin
(2008: 1621), "For a given value of {it:b}, ..., as {it:a} --> oo, the 
inequality index abstracts from the dispersion below the median". On the 
other hand, and again roughly speaking, when {it:b} > {it:a}, {it:ANY}({it:a},{it:b}) 
gives greater weight to the bottom half of the distribution. For a given value 
of {it:a}, choosing larger and larger values of {it:b} places less weight on 
the distribution in categories above the median. In the limiting case when {it:b} 
--> oo, only below-median categories are relevant. Thus, e.g., the indices 
{it:ANY}(1,1), {it:ANY}(1,2), and {it:ANY}(1,4) respectively give increasingly 
greater weight to the lower half of the distribution when assessing overall 
polarization.

{p 4 4 2} 
Apouey's (2007) {it:P}2({it:e}) indices each aggregate the `distances' between 
{it:F_k} and 0.5 (the value of {it:F_k} at the median) across the levels  
of {cmd:varname}. {it:P}2({it:0.5}) uses the square root of the absolute differences 
to summarize 'distance' and {it:P}2({it:1}) uses a 'city block' (linear) distance
function. {it:P}2({it:2}) uses a Euclidean distance metric and is the same as
the the '1 {c -} l-squared' index of Blair and Lacy (2000).  
(The Blair-Lacy index may also be calculated using {cmd:ordvar} on SSC.) 
In general, the value of parameter {it:e} determines how shifts in 
concentration within the group below the median {c -} or the group 
above the median {c -} are assumed to affect overall polarization. 

{p 4 4 2} 
The Average Jump index is the average across respondents of the absolute difference
between each observed value of {cmd: varname} and the median value, normalized 
by the maximum value for the index. For a linear integer scale, the Average Jump 
index equals the Allison-Foster index divided by the total number of levels of 
{cmd:varname} minus one (Allison and Foster, 2004, p. 514). In this case 
(as with the life satisfaction scale cited at the beginning), the index summarizes 
the (normalized) average number of category 'jumps' required to change from the 
observed level to the median level. For a linear integer scale, the Average Jump index 
is the same as the {it:ANY}(1,1) index and the {it:P}2(1) index.

{p 4 4 2} 
Cowell and Flachaire (2017) build inequality measures from axiomatic first principles, 
providing two families of one-parameter indices based on downward-looking and
upward-looking measures of individual 'status', respectively. {cmd:ineqord} 
uses the 'peer-inclusive' (rather than 'peer-exclusive') definitions 
of these, reflecting the focus of Cowell and Flachaire (2017). For an
individual reporting a response corresponding to the {it:k}th level of the 
scale, peer-inclusive downward-looking status is given by {it:F_k} and 
peer-inclusive upward-looking status is given by {it:S_k}. The inequality
indices aggregate 'distances' between each individual's status and the maximum
possible status value. 

{p 4 4 2}
Members of the two Cowell-Flachaire inequality index families {it:I}({it:alpha}),
are distinguished by parameter {it:alpha} which encapsulates the sensitivity of 
overall inequality to the dispersion of individual status in different ranges 
of the status distribution. The lower that {it:alpha} is, the more sensitive 
the overall index is to differences in status at the bottom of the status 
distribution rather than at the top. If the distribution of responses on 
{cmd:varname} is symmetric across the levels, {it:F_k} = {it:S_k} and each 
downward-looking Cowell-Flachaire index has the same value as its upward-looking 
counterpart. 

{p 4 4 2}
Jenkins's (2019b) {it:Jd} index is defined for Cowell and Flachaire's 
peer-inclusive downward-looking status measure and his {it:Ju} index 
for their peer-inclusive upward-looking status measure. Each index is 
equal to the area between the Generalized Lorenz curve for the relevant 
status distribution and the Generalized Lorenz curve for the distribution with
no status inequality (in which case the Generalized Lorenz Curve is a 
straight line between the origin and point (1,1)), divided by the total area 
beneath the perfect equality curve (= 0.5). Equivalently, each index is equal 
to one minus twice the area beneath Generalized Lorenz curve for status. 
The Generalized Lorenz curve for status, GL({it:p}), plots cumulative status 
per capita against cumulative population share, 0 ≤ {it:p} ≤ 1, of individuals 
ranked in ascending order of status. GL(0) = 0 and GL(1) is the arithmetic 
mean of status. See Jenkins (2019b) for details.

{p 4 4 2} 
All of the indices calculated by {cmd:ineqord} equal their minimum value, zero, 
if all respondents report the same value for {cmd:varname}. The Allison-Foster, 
Average Jump, Apouey, and Abul Naga and Yalcin indices each 
summarize polarization of responses relative to the median. These indices reach 
their maximum value when half the responses on {cmd:varname} refer to the minimum 
value of the scale and half the responses refer to the maximum value, i.e. the 
distribution of responses is totally polarized. In this case, the maximum value 
of the indices equals one (except for the Allison-Foster index, for which the maximum
value depends on the number of categories). Cowell-Flachaire {it:I}({it:alpha}) 
and {it:J} indices need not reach a maximum value with this distribution of 
responses: this is because the indices summarize inequality as spread 
rather than as polarization. For example, {it:I}({it:alpha}) 
and {it:J} indices record greater inequality for a uniform distribution
than for a totally polarized distribution (Jenkins 2019b).

{p 4 4 2}
{it:I}({it:alpha}) and {it:J} indices are invariant to order-preserving 
transformations of the ordinal scale variable (i.e. scale independent). 
The Allison-Foster index is not scale independent and hence Dutta and 
Foster (2013), in their empirical applications, provide estimates based on 
linear, convex, and concave scales. Abul Naga-Yalcin and Apouey indices 
are scale independent (but also see the remarks about scale levels below).

{p 4 4 2} 
For correct calculation of the Abul Naga-Yalcin, Average Jump, Apouey, 
and Jenkins indices, {cmd:ineqord} must know the total number of 
possible levels of the ordinal response variable. This number may be greater than 
the maximum observed in the data, e.g. if there are no responses on 
some scale values or if there is total polarization. By default, {cmd:ineqord} 
assumes that the total number of possible levels of the ordinal response 
is the observed number of levels containing responses. If this assumption 
is incorrect, it is the user's responsibility to specify the maximum number 
of levels of response using the {cmd: nlevels} option. 
See also the discussion of scale dependence below.

{p 4 4 2}
The Apouey indices refer to the case in which the ordered response 
categories are labelled with positive integers (1 for the lowest level, 2 for 
the second lowest, etc.), which is a linear integer scale. For correct calculation
of these indices, it is the user's responsibility to check that the scale 
underlying {cmd:varname} is appropriate. Optionally, {cmd: ineqord} relabels 
the observed responses to calculate the Apouey indices using 
a linear transformation: response_new = response {c -} {it:minlevel} + 1, where 
{it: minlevel} is the value specified by the {cmd:minlevel} option. For example, 
using the option, the life satisfaction scale cited above (0, 1, ..., 10) is
converted to (1, 2, ..., 11) by setting {it:minlevel} = 0. Scale ({c -}1, 0, 1) 
would be converted to (1, 2, 3) by setting minlevel = {c -}1. Be aware that 
if the response scale values were instead, (2, 4, 6), say, and the user sets 
{it:minlevel} = 2, {cmd:ineqord}'s calculation would be based on transformed 
responses (1, 3, 5), not (1, 2, 3), and correct calculation of the Apouey 
(and J) indices would also require setting the maximum number of levels to 
5 using the {cmd:nlevels} option. Calculation of the indices would assume that 
scale values 2 and 4 are possible (and this is relevant to the assessment of 
how polarized {cmd:varname} is), but there are no responses observed for them. 
On related issues, see the discussion of the 'mergers principle' by Cowell 
and Flachaire (2017).

{p 4 4 2}
{cmd:ineqord} also provides users with the information required to carry out
dominance checks. Dominance results show that if an appropriately defined graph 
for one distribution lies everywhere on or above the corresponding graph for 
another distribution, this is equivalent to a unanimous ranking of the two 
distribution by all measures satisfying a particular set of properties.

{p 4 4 2} 
Allison and Foster (2004) provide results for '{it:F}-dominance' and '{it:S}-dominance'. 
The former refers to comparisons of CDFs and rankings by average well-being levels: 
if the CDF for distribution {it:A} lies everywhere on or above the CDF below that for 
distribution {it:B}, then {it:A} has higher average well-being than B, 
regardless of scale. {it:S}-dominance refers to comparisons of {it:S}-curves, which are 
derived from CDFs and so the criterion can also be expressed in terms of these. 
If {it:A} and {it:B} have the same median, and the CDF for {it:A} lies above that for 
{it:B} at scale values below the median but above that for {it:B} at scale values at the 
median and above, all polarization indices respecting the property that greater 
spread about the median corresponds to greater polarization will show {it:A} as 
having greater polarization than {it:B}. {it:S}-dominance can only arise if the pair of 
distributions have a common median and if there is no {it:F}-dominance. 

{p 4 4 2}
Jenkins (2019b) shows that, for each of the two Cowell-Flachaire definitions 
of status, if the Generalized Lorenz curve for status distribution {it:A} 
lies nowhere above the Generalized Lorenz curve for status distribution {it:B}, 
all Cowell-Flachaire {it:I}({it:alpha}) indices and the {it:J} index will 
show {it:A} as having more inequality than {it:B}. The Generalized Lorenz 
Curve comparisons can be applied if the distributions have different medians.

{p 4 4 2}
For Gravel, Magdalou, and Moyes (2020), inequality of an ordinal variable 
increases if there is a shift in density mass away from a specific level (one
person moving up a level and one moving down). This is the concept of a 
disequalizing 'Hammond transfer'. The authors define an 'H+' curve 
and an 'H-' curve and prove a dual dominance result: distribution 
{it:A} being more equal than distribution {it:B} is equivalent to finding the 
H+ curve for {it:A} lying nowhere above the H+ curve 
for {it:B} and also the H- curve for {it:A} lying nowhere above 
the H- curve for {it:B}. In addition, {it:F}-dominance implies
H+ dominance. The dual dominance check can be applied if the 
distributions have different medians.

{p 4 4 2}
Bootstrapped standard errors for the indices can be derived using {help bootstrap} 
or e.g. {cmd:rhsbsample}. Analytical formulae exist for some of the indices 
but not all of them (see the References below), and the formulae provided
do not account for sample design features such as weights, clustering, or stratification.

{p 4 4 2}
For an extensive set of examples using {cmd:ineqord}, see Jenkins (2019a, 2019b).

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt a:lpha(#)} Use this to calculate an additional Cowell-Flachaire index
with parameter value alpha. The value must be between 0 and 1.  {p_end}
{phang}
{opt nl:evels(#)} Use this to specify the total number of possible levels of 
the ordinal response variable. Required for correct calculation of the 
Blair-Lacy and Apouey indices if the observed number of levels is less than the 
maximum possible. {p_end}
{phang}
{opt minl:evel(#)} Use this to specify the minimum level of the ordinal response
variable. Required for correct calculation of the Blair-Lacy and Apouey indices 
if the observed minimum is not equal to 1.  {p_end}
{phang}
{opt ust:atusvar(string)} Use this to save the Cowell-Flachaire `upward-looking' 
status variable after calculation. {p_end}
{phang}
{opt dst:atusvar(string)} Use this to save the Cowell-Flachaire `downward-looking' 
status variable  after calculation. {p_end}
{phang}
{opt catv:als(string)} Use this to save the distinct values of the response variable after calculation. {p_end}
{phang}
{opt catp:rops(string)} Use this to save the sample proportions after calculation. {p_end}
{phang}
{opt catc:props(string)} Use this to save the sample cumulative proportions after calculation. {p_end}
{phang}
{opt cats:props(string)} Use this to save the sample cumulative survivor proportions after calculation. {p_end}
{phang}
{opt gld:var(string)} Use this to save the Generalized Lorenz ordinates of the Cowell-Flachaire `downward-looking' 
status variable after calculation. {p_end}
{phang}
{opt glu:var(string)} Use this to save the Generalized Lorenz ordinates of the Cowell-Flachaire `upward-looking' 
status variable after calculation. {p_end}
{phang}
{opt hp:lus(string)} Use this to save H+  ordinates in a new variable after calculation. {p_end}
{phang}
{opt hm:inus(string)} Use this to save H-  ordinates in a new variable after calculation. {p_end} 


{marker examples}{...}
{title:Examples}

{p 8 8 2}{it: Dutta and Foster (2013, p. 514)}

{p 4 8 2}{cmd: set obs 5}

{p 4 8 2}{cmd: ge X = 0}

{p 4 8 2}{cmd: replace X = -1 if _n == 1}

{p 4 8 2}{cmd: replace X =  1 if _n == 5}

{p 4 8 2}{cmd: ineqord X  }

{p 4 8 2}{cmd: ineqord X, minlevel(-1) // note effect on J, Blair-Lacy, and Ahouey indices}

{p 8 8 2}{it: Abul Naga and Yalcin (2008, Tables 2, 4); case with no obs in lowest category}

{p 4 8 2}{cmd: clear}

{p 4 8 2}{cmd: set obs 100}

{p 4 8 2}{cmd: ge central = .}

{p 4 8 2}{cmd: replace central = 2 if _n <= 2}

{p 4 8 2}{cmd: replace central = 3 if _n > 2 & _n <= 13}

{p 4 8 2}{cmd: replace central = 4 if _n > 13 & _n <= 76}

{p 4 8 2}{cmd: replace central = 5 if _n > 76 }

{p 4 8 2}{cmd: ineqord central // Calculation is wrong; ignores fact that zero obs in first category }

{p 4 8 2}{cmd: ineqord central, nlevels(5) // To calculate AN-Y and other indices correctly }

{p 8 12 2}{it: European Social Survey data for Britain, round 8: happiness on a linear integer scale (0, ..., 10)}

{p 4 8 2}{cmd: ineqord happy if cntry == "GB" & essround == 8, minlevel(0) }

{p 4 8 2}{cmd: ineqord happy if cntry == "GB" & essround == 8 /// }

{p 8 8 2}{cmd:   , minlevel(0) catvals(k) catprops(f) /// }

{p 8 8 2}{cmd:       catcprops(F) gldv(gld) catsprops(S) gluv(glu) hplus(Hp) hminus(Hm) }

{p 4 8 2}{cmd: sort k }

{p 4 8 2}{cmd: list k f F gld S glu Hp Hm if !missing(F) }

{pstd}

{marker results}{...}
{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(n_distinct_cats)}} Number of distinct levels in {cmd:varname} {p_end}
{synopt:{cmd:r(mean)}} Mean of {cmd:varname} {p_end}
{synopt:{cmd:r(mean_rescaled)}} Mean of {cmd:varname} if minlevel() option applied  {p_end}
{synopt:{cmd:r(median)}} Median of {cmd:varname} {p_end}
{synopt:{cmd:r(median_rescaled)}} Median of {cmd:varname} if minlevel() option applied {p_end}
{synopt:{cmd:r(newmedian)}} ceil(Median of {cmd:varname}) {p_end}
{synopt:{cmd:r(Var)}} Variance of {cmd:varname} {p_end}
{synopt:{cmd:r(sd)}} Standard deviation of {cmd:varname} {p_end}
{synopt:{cmd:r(sumw)}} Sum of weights {p_end}
{synopt:{cmd:r(N)}} Number of observations on {cmd:varname} {p_end}
{synopt:{cmd:r(min)}} Minimum value of {cmd:varname} {p_end}
{synopt:{cmd:r(max)}} Maximum value of {cmd:varname} {p_end}
{synopt:{cmd:r(min_rescaled)}} Minimum value of {cmd:varname} if minlevel() option applied {p_end}
{synopt:{cmd:r(max_rescaled)}} Maximum value of {cmd:varname} if minlevel() option applied {p_end}
{synopt:{cmd:r(nlevels)}} Number of levels specified in {cmd:nlevels} option {p_end}
{synopt:{cmd:r(minlevel)}} Value of minimum level specified in {cmd:minlevel} option {p_end}
{synopt:{cmd:r(dfmeanabove)}} Mean of {cmd:varname} for obs above the median (Allison-Foster definition) {p_end}
{synopt:{cmd:r(s_H)}} Mean of {cmd:varname} for obs above the median minus the median of {cmd:varname} {p_end}
{synopt:{cmd:r(dfmeanbelow)}} Mean of {cmd:varname} for obs below the median (Allison-Foster definition) {p_end}
{synopt:{cmd:r(s_L)}} Median of {cmd:varname} minus mean of {cmd:varname} for obs above the median {p_end}
{synopt:{cmd:r(allisonfoster)}} Allison-Foster index {p_end}
{synopt:{cmd:r(avjump)}} Average Jump index {p_end}
{synopt:{cmd:r(apoueypt5)}} Apouey P2(0.5) index {p_end}
{synopt:{cmd:r(apouey1)}} Apouey P2(1) index {p_end}
{synopt:{cmd:r(apouey2)}} Apouey P2(2) index {p_end}
{synopt:{cmd:r(blairlacy)}} Blair-Lacy index (1 {c -} l-squared) = P2(2) {p_end}
{synopt:{cmd:r(any11)}} Abul Naga-Yalcin (1,1) index {p_end}
{synopt:{cmd:r(any21)}} Abul Naga-Yalcin (2,1) index {p_end}
{synopt:{cmd:r(any12)}} Abul Naga-Yalcin (1,2) index {p_end}
{synopt:{cmd:r(any41)}} Abul Naga-Yalcin (4,1) index {p_end}
{synopt:{cmd:r(any14)}} Abul Naga-Yalcin (1,4) index {p_end}
{synopt:{cmd:r(i0d)}} Cowell-Flachaire downward-looking index (alpha = 0) {p_end}
{synopt:{cmd:r(ioneqd)}} Cowell-Flachaire downward-looking index (alpha = 0.25) {p_end}
{synopt:{cmd:r(ihalfd)}} Cowell-Flachaire downward-looking index (alpha = 0.5) {p_end}
{synopt:{cmd:r(ithreeqd)}} Cowell-Flachaire downward-looking index (alpha = 0.75) {p_end}
{synopt:{cmd:r(ixd)}} Optional Cowell-Flachaire downward-looking index (alpha = #)  {p_end}
{synopt:{cmd:r(i0u)}} Cowell-Flachaire upward-looking index (alpha = 0) {p_end}
{synopt:{cmd:r(ionequ)}} Cowell-Flachaire upward-looking index (alpha = 0.25) {p_end}
{synopt:{cmd:r(ihalfu)}} Cowell-Flachaire upward-looking index (alpha = 0.5) {p_end}
{synopt:{cmd:r(ithreequ)}} Cowell-Flachaire upward-looking index (alpha = 0.75) {p_end}
{synopt:{cmd:r(ixu)}} Optional Cowell-Flachaire upward-looking index (alpha = #) {p_end}
{synopt:{cmd:r(Jd)}} Jenkins downward-looking index {p_end}
{synopt:{cmd:r(Ju)}} Jenkins upward-looking index {p_end}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(cats_list)}} List of levels of {cmd:varname} {p_end}

{title:Author}
{p}

{p 4 4 2}Stephen P. Jenkins <s.jenkins@lse.ac.uk>{break}
London School of Economics and Political Science (LSE)

{title:Acknowledgements}

{p 4 4 2}I developed this program as part of a project undertaken with
Arthur Grimes and Florencia Tranquilli, both of Motu Research (Wellington, New Zealand).
Benoît-Paul Hébert pointed out an issue with {cmd:levelsof} that affected users
with a Stata version below 15.1 (now addressed), and commented on the help-file 
text. An anonymous referee also made helpful comments.

{marker references}{...}
{title:References}

{p 4 8 2}
Abdul Naga, R. and Yalcin, T. 2008.
Inequality measurement for ordered response health data.
{it: Journal of Health Economics} 27: 1614{c -}1625.

{p 4 8 2}
Allison, R.A. and Foster, J.E. 2004.
Measuring health inequality using qualitative data.
{it: Journal of Health Economics} 23: 505{c -}524.

{p 4 8 2}
Apouey, B. 2007.
Measuring health polarization with self-assessed health data.
{it: Health Economics} 16: 875{c -}894.

{p 4 8 2}
Blair, J., and Lacy, M. 2000. 
Statistics of ordinal variation.
{it:Sociological Methods and Research} 28: 251{c -}280.

{p 4 8 2} 
Cowell, F.A. and Flachaire, E. 2017.
Inequality with ordinal data. 
{it:Economica} 84: 290{c -}321.

{p 4 8 2}
Dutta, I. and Foster, J.E. 2013. 
Inequality of happiness in the US: 1972{c -}2010.
{it:Review of Income and Wealth} 59: 393{c -}415.

{p 4 8 2}
Jenkins, S.P. 2019a.
Better off? Distributional comparisons for ordinal data about personal well-being.
New Zealand Economic Papers, online ahead of print. (Open Access.) 
{browse "https://www.tandfonline.com/doi/full/10.1080/00779954.2019.1697729"} 

{p 4 8 2}
Jenkins, S.P. 2019b.
Inequality comparisons with ordinal data.
Discussion Paper 12811. Bonn: IZA. {browse "http://ftp.iza.org/dp12811"}.

{p 4 8 2}
Kalmijn, W. and Veenhoven, R. 2005.
Measuring inequality of happiness in nations. In search of proper statistics.
{it: Journal of Happiness Studies} 6: 357{c -}396. 

{p 4 8 2}
Gravel, N., Magdalou, B., and Moyes, P. 2020.
Ranking distributions of an ordinal variable.
Economic Theory, online ahead of print.
{browse "https://link.springer.com/article/10.1007/s00199-019-01241-4"}

{title:Also see}

{p 4 13 2}
{help ordvar} if installed (SSC); {help sdlim} if installed (SSC); {help rhsbsample} if installed (SSC)


