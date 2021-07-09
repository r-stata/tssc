{smcl}
{* 26aug2019}{...}
{hline}
help for {hi:ultimatch}
{hline}

{title:Matching} - Nearest Neighbor, Radius, Coarsened Exact, Percentile Rank, Mahalanobis and Euclidean Distance Matching in one Package

{p 8 15}{cmd:ultimatch} [{it:varlist}] [{it:if}] [{it:in}], {ul:t}reated({it:var}) [{ul:exa}ct({it:varlist})] [{ul:d}raw(#)] [{ul:ca}liper(#)]
[{ul:su}pport] [{ul:si}ngle] [{ul:g}reedy] [{ul:b}etween] [{ul:ran}k] [{ul:rad}ius] [{ul:eu}clid] [{ul:m}ahalanobis] [{ul:co}py [{ul:f}ull]]
[{ul:re}port({it:varlist}) [{ul:unm}atched]] [{ul:uni}t({it:varlist})] [{ul:exp}({it:string})] [{ul:l}imit({it:string})]{p_end}
 
{title:Description}

{p}{cmd:ultimatch} implements various matching methods. The matching mode depends on the options and parameters specified. If only one variable is 
specified, it is considered a score, which will be used for neigborhood or radius matching. In most cases this score is a predicted propensity 
score, but it can be any variable providing a distance relation. If more than one variable is specified, the {hi:Mahalanobis} or {hi:Euclidean} distance 
will be used to determine the surroundings for every treated observation. Another distance based method is the {hi:Percentile Rank} matching, which is 
activated by the option {cmd:rank}. Finally, by omitting any variable, {hi:Coarsened Exact} matching is assumed requiring the specification of the grouping 
variables in the {cmd:exact} option (see option {cmd:exact} for an alternative method to {hi:Coarsened Exact} matching).{p_end}

{p}From now on, the term "counterfactuals" refers to non-treated observations that are suited to represent a specific treated observation - or a group
of those in case of {hi:Coarsened Exact} matching - in a control group. {cmd:ultimatch} does not implement methods based on adjusting whole
distributions like Entropy Balancing.{p_end}

{p}Besides score based matching {cmd:ultimatch} supports two different kinds of {hi:distance} matching: {hi:Mahalanobis} and {hi:Euclidean} 
distance. The Mahalanobis distance uses the inverted covariance matrix to normalize the distance vector between two points before calculating the 
Euclidean distance. Distance matching allows to find the closest neighbor or all neighbors within a radius in terms of the applied distance 
measurement. Usually, the neighborhood is determined by calculating the distance of a given point (observation) to all other points in the sample. 
The runtime of this process increases according to the product of the treated and the non-treated observations. {cmd:ultimatch} applies a heuristic 
approach that prevents this inflation of the runtime:{break} First, a distance score, Mahalanobis or Eucledian, is created for every observation to 
a point outside the finite sample distribution of {it:varlist}. By sorting the data by this score, it is guaranteed that observations with the same 
score are on the surface of a hypersphere centered on the outside point. The dimensions of the sphere are defined by {it:varlist}. Starting from a 
treated observation, moving along the score axis in both directions increases respectively decreases the radius of the corresponding spherical 
layer. For every not-treated observation visited, the actual Mahalonbis distance to the treated observation is calculated. All visited observations 
are confined within the ever-growing leeway between the deviating inner and outer spheres. The moment where the closest recorded distance to a 
non-treated observation is shorter than the distance of the treated observation to the nearest spherical layer, calculated as difference between the 
scores, all observations further down or up the score axis will return higher distances. They will always reside on shells that move further away 
from the selected treated observation.{break}To identify all neighbors within a given radius, the inner sphere is defined by the specified radius
instead by the respectively closest observation. Every observation encountered within the inner spere belongs to the neighborhood. The neighborhood
is complete when the surfaces of the three involved spheres cease to intersect.{p_end}

{p}Score-based matching exploits the fact that with only one dimension, the spheres transform to points along the score axis and the
closest point is immediately ascertainable. This circumstance allows for more flexible options, extending the neighborhood beyond the nearest
one.{p_end}

{p}{hi:Percentile Rank} transformation can be applied on the score or the distance variables. A percentile rank is the percentage of distinct 
values that are equal or lower than it. As opposed to percentiles, variables with the same value always have the same percentile rank eliminating the 
arbitrariness of percentiles. The percentile ranks of {it:varlist} are used as a way to normalize the dimensions. The default distance is
Euclidean, but it can be switched to Mahalanobis. In the case of score-based matching the transformation eliminates the first differenes of
neighboring scores.{p_end}

{p}{cmd:ultimatch} considers non-treated observations with the same score or distance as one draw. It does not arbitrarily pick one of these 
observations unless the option {cmd:single} is specified. Therefore, it is required to introduce weights (see below) to keep the distributions 
balanced between treated and counterfactuals.{p_end}

{p}Depending on the settings, the following variables will be created:{p_end}

{p 0 4}{hi:_match}: contains an identifier designating matched observations. If possible, observations with the same identifier belong together. This
is guaranteed for the {cmd:greedy} and the {cmd:copy} option. The latter allows {cmd:ultimatch} to append observations to avoid conflicts, i.e. two treated
observations competing for the same counterfactual. Otherwise, in the case of a conflict, the identifier of the closest treated observation is used
for the counterfactuals. For {hi:Coarsened Exact} matching, this variable just enumerates matched cells containing treated and non-treated
observations. Usually there are no gaps in the enumeration of the identifier. Still, they can occur if the option {cmd:greedy} is applied especially in
conjunction with {cmd:caliper}.{break}{hi:_match} is missing for non-matched observations.{p_end}

{p 0 4}{hi:_distance}: contains the distance between an observation and the closest treated observation respectively the allocated treated
observation, if {cmd:copy} is specified. It will not be created for {hi:Coarsened Exact} matching. It can be used to remove outlying matches manually,
e.g. by percentiles.{break}{hi:_distance} is missing for non-matched observations.{p_end}

{p 0 4}{hi:_weight}: contains the weight of the observation after matching. The weights balance the distribution of the counterfactuals according to 
the distribution of the treated. In geeneral, the weight of a treated observation is always 1, while the sum of the weights of its counterfactuals 
also add up to 1. If the option {cmd:copy} is not specified, overlapping counterfactuals accumulate their weights. The weights should always be used 
for subsequent estimations. If options require to create copies of a treated observation the sum of the weights of the copies add up to 
1.{break}{hi:_weight} is missing for non-matched observations.{p_end}

{p 0 4}{hi:_support}: marks observations with common support. It will be created if option {cmd:support} is specified.{break}
{hi:_support} is missing for non-matched observations, 1 for observations with common support and 0 for observations without support.{p_end}

{p 0 4}{hi:_copy}: contains a dummy designating observations that were copied (appended to the data) to avoid conflicts between treated observations 
over a mutual counterfactual. It will only be created if the option {cmd:copy} is specified. Only if option {cmd:full} was specified, treated will be 
among the copied observations.{break}{hi:_copy} is missing for non-matched observations, 1 for matched and appended and 0 for matched, original 
observations.{p_end}

{p}{hi:WARNING: ultimatch will change the sort order of the data and, if canceled, the order of the variables.}{p_end}

{p}{hi:Performance: The algorithm relies heavily on sorting. It is advised to rather drop unused observations than filtering them by {it:if} or {it:in}.}
{p_end}

{p}{hi:HINT: ultimatch can also be used to identfiy geographic neighborhood relations.}{p_end}

{title:Options}

{p 0 4}{ul:t}reated({it:var}) specifies a dummy variable marking the treated observations.{p_end}

{p 0 4}{ul:ca}liper({it:real}) defines the maximum absolute score difference or distance between a treated and a non-treated observation (default: 
no limit). It is {hi:not} supported by {hi:Coarsened Exact} matching because due to lack of a score or a distance. Caliper describes the radius in 
case of {hi:Radius} matching.{break}{hi:Hint:} Because it is difficult to assess the range of the Mahalanobis distance, summarizing the {hi:_distance} variable 
of the counterfactuals is suggested to either remove outlying counterfactuals manually or to define a caliper for a second run.{p_end}

{p 0 4}{ul:d}raw({it:integer}) specifies the number of neighbors for every treated observation to be drawn. Neighbors with the same score or 
distance are considered one draw unless the option {cmd:single} is specified. With this option, it is possible to diminish the burden of the 
"nearest neighbor" by including a larger neighborhood at the expense of similarity. It is {hi:not} supported by {hi:Coarsened Exact} matching 
because it always draws all observations in a cell defined by the option {cmd:exact}. It is also {hi:not} supported by distance-based matching
because the algorithm can only identify the nearest neighbor.{p_end}

{p 0 4}{ul:exa}ct({it:varlist}) specifies a group of variables defining cells (stratums). The counterfactuals must be in the same cell as 
the corresponding treated observation, therefore the term {cmd:exact}. This option can be combined with any matching method. The 
specified variables should be ordinal, categorical or binary. If this option is specified without a general {it:varlist} (a score or 
distance variables), {hi:Coarsened Exact} matching is assumed. In this case, the {hi:_match} variable enumerates the cells containing 
treated and non-treated observations in no specific order.{break}
{hi:Hint:} Coarsened Exact matching can also be emulated by using a group variable based on the defined coarsened stratums as a score. In this case, 
missing values can be included. By applying a {cmd:caliper} below 1, e.g. 0.5, the {hi:Neighbor} matching will always draw 
counterfactuals within the stratum without requiring the {cmd:exact} option. All options of {hi:Neighbor} matching are available including 
{hi:single} for random assignment of counterfactuals and {cmd:copy} for direct associations with the treated observations (see example section 
below).{p_end}

{p 0 4}{ul:rad}ius activates radius matching for score-based and distance-based matching.

{p 0 4}{ul:ran}k activates {hi:Percentile Rank} transformation. In case of distance-based matching the Euclidean distance will be used by default. 
With the option {cmd:mahalanobis} the distance calculation can be switched to {hi:Mahalanobis} distance.{p_end}

{p 0 4}{ul:eu}clid can be applied to switch to Euclidean distance calculation. This is the default setting in case
of {hi:Percentile Rank} transformation. This option is {hi:not} supported by {hi:Coarsened Exact} and score-based matching.{p_end}

{p 0 4}{ul:m}ahalanobis can be applied to switch to Mahalanobis distance calculation. This is the default setting for distance-based matching. This 
option is {hi:not} supported by {hi:Coarsened Exact} and score-based matching.{p_end}

{p 0 4}{ul:b}etween searches for higher and lower ranked neighbours independently. The draw option
limits both directions separately. It is only supported by score-based matching.{p_end}

{p 0 4}{ul:g}reedy draws without replacement. The treated observation with the lowest distance will claim the non-treated observations. Treated
observations that were deprived of their counterfactuals are reactivated to search for alternative neighbors, potentially repressing other treated
observations. This may initiate a displacement cascade until all treated observations have settled with the best counterfactual they could possibly
claim given the competition. It is strongly advised to apply {cmd:greedy} together with a reasonable {cmd:caliper}. It is {hi:not} supported by
{hi:Coarsened Exact} and {hi:Radius} matching.{p_end}

{p 0 4}{ul:si}ngle dismisses the default behaviour of considering all observations with the same score or distance as one observation regarding the 
draw limit. Every observation will be counted towards the draw limit. The counterfactuals are randomly drawn within in groups of equal scores or 
distances. It is {hi:not} supported by {hi:Radius} and {hi:Coarsened Exact} matching as they are not restricted to a specific number of
counterfactuals.{p_end}

{p 0 4}{ul:su}pport guarantees that there is overlap between the treated and non-treated population regarding the score, the so called {it:common 
support}. This option enforces the creation of the {hi:_support} variable marking observations with common support with 1. The score has to be in 
the confines defined by the minimum of the maximum scores and the maximum of the minimum scores of treated vs. non-treated observations. In the case 
of distance-based matching, the first variable is considered to contain the score to allow the inclusion of a propensity score. It is {hi:not} 
supported by {hi:Coarsened Exact} matching.{p_end}

{p 0 4}{ul:co}py [{ul:f}ull] appends copies of counterfactuals that are drawn more than one time by different treated observations. It facilitates 
direct associations of treated observations with their counterfactuals by the {hi:_match} identifier enabling interactions between a treated and 
non-treated observation, e.g. sample splits that do not separate treated and counterfactuals or the calculation of ratios. With {cmd:copy}, every 
group of observations sharing the same {hi:_match} identifier contains one treated and at least one counterfactual. This is not neccessarily the 
case, if the option is omitted. It is {hi:not} directly supported by {hi:Coarsened Exact} matching because it matches groups not individuals. The 
{cmd:full} sub-option forces tuples comprising of exactly one treated and one counterfactual represented by an unique {hi:_match} ID. If a treated 
observation has more than one counterfactual, a copy of the treated will be created for every additional counterfactual. This is the only case where 
the {hi:_weight} variable may contain a weight different from 1 for a treated observation to preserve the original distribution of the treated. The 
{cmd:full} option allows even more control over the interactions at the expense of an inflated dataset. It is also useful for educational purposes 
(see example 2).{p_end}

{p 0 4}{ul:exp}({it:string}) defines a logical expression that will be evaluated before a potential non-treated observation will be matched. If the 
expression evaluates to zero, the observation will be ignored. A variable name with a prefix "t." designates the active treated observation to allow 
for operations between treated and non-treated variables.{break}
{hi:Example:} exp(abs(empl-t.empl) < 20 | min(empl,t.empl)/max(empl,t.empl) >= 0.8){p_end}

{p 0 4}{ul:l}imit({it:string}) defines a list of variable and rank difference pairs. The rank difference can be omitted for a default value of 5. For
each value of one of these variables, a rank percentile will be defined. The absolute rank difference between a treated and a potentially matched
observation has to be lower or equal the specified difference or, if it is omitted, the default value of 5. A rank percentile is defined for the range
[0,100]. A rank difference of 5 means, that the rank of the value of the matched observation is within a 5% interval around the respective rank of the
value of the treated observation. This option can be applied, if polynomials or other non-monotonous transformations were used to estimate the
score. This option should not be confused with {hi:Percentile Rank} matching.{break}
{hi:Example:} limit(empl 10 sales patentstock 10){p_end}

{p 0 4}{ul:re}port({it:varlist}) [{ul:unm}atched] reports the results of the weighted t-tests for the comparisons of the means of these variables between the treated
and the control group. In case of copied counterfactuals (see option {cmd:copy}) or external unit specifications (see option {cmd:unit}) the standard
errors are clustered accordingly. The option {cmd:unmatched} additionally reports the t-tests before the matching.{p_end}

{p 0 4}{ul:uni}t({it:varlist}) defines key variables determining a data unit. These units will be used to estimate clustered standard errors for the
report. If omitted, every observation is considered a unit. {cmd:unit} is useful for panel data, where a unit can be matched in different time
periods.{p_end}

{title:Output}

{p}{hi:ultimatch} reports the treated and control statistics in separate columns. If common {cmd:support} is not enforced, all valid observations
without missings in {it:varlist} and variables specified in the {cmd:exact} and {cmd:limit} option are considered supported. Potential exclusions
defined in the option {cmd:exp} are not regarded. If {cmd:copy} is specified, there will be clustering caused by the copied observations. In
addition, there can be intrinsical clustering of the specified units (see option {cmd:unit}), for example if the same unit is drawn for different time
periods. The row {it:Clustered} in the output designates the number of observations belonging to a cluster. The row {it:Clusters} accomodates the
number of different clusters (the size of the cluster aggregate). If {cmd:report} variables are specified, the reported standard errors are clustered
accordingly. The {cmd:unmatched} standard errors are only clustered, if {cmd:unit} is specified. All reported statistics are returned in the matrix
{hi:r(match)}. Furthermore, the number of computational steps is returned in {hi:r(comp)} to assess the complexity of the matching.{p_end}

{title:Example 1}

{p}In this example, data is simulated to demonstrate a selection bias in a difference-in-differences (DiD) setup and how it can be mitigated by
matching. A group of individuals undergoes treatment with the intention to reduce weight. There is a higher propensity for the self-selection of
individuals with a higher fitness into the treatment indicated by the variable {hi:treated}. The data contains {hi:weight}, {hi:age} and {hi:gender}
for every individual in one period before and one after the treatment. The variable {hi:fitness} is considered unobserved. It is correlated with the
dependent variable {hi:weight} and the selection into treatment leading to a selection bias. The example iterates different matching methods based on
the pre-treatment period for instructional reasons. Remember, the variable fitness is actually unobserved and only reported to demonstrate that
matching on observables can mitigate the selection bias. The example concludes with a DiD regression without matching, resulting in an negative and
significant treatment {hi:effect} represented by the interaction term {hi:treated*period}. Of course, this effect is only driven by the selection bias
as a second regression on the matched data suggests.{p_end}

{p}{hi:Copy+paste} into a do file!{p_end}
{inp}
    clear
    tempfile tmp
    set obs 2000
    gen byte period = 0 //pre-treatment
    gen long id = _n
    gen byte gender = uniform() > 0.5
    gen age = uniform()
    gen fitness = normal(gender*0.25 - age + invnorm(uniform())*0.1) // unobserved selection
    gen weight = normal(-gender*0.25 + age*0.25 - fitness*0.25 + invnorm(uniform())*0.1)
    gen treated = normal(fitness + invnorm(uniform())*0.25) > 0.73
    save `tmp'
    replace period = 1 // after treatment
    replace weight = weight + weight*(uniform()-0.5)*0.2 - weight*(fitness-0.5)*0.25
    append using `tmp'
    sort id period
    replace weight = int(30.5+100*weight)
    replace age = int(18.5+50*age)
    sum age
    gen agegroup = autocode(age,5,r(min),r(max))
    sum weight
    gen weightgroup = autocode(weight,5,r(min),r(max)) 
    egen long coarsecell = group(agegroup gender weightgroup)
    gen effect = treated*period // treatment effect (interaction term for DiD)
    probit treated age gender weight if period == 0 // omitting "unobserved" selection 
    predict score // propensity score

    // Copying and Non-Copying Score-based Neighborhood Matching
    // comparing sum of weights
    ultimatch score if period == 0, tr(treated) report(score age weight gender fitness) unmatched copy
    sum _weight if treated == 0
    di r(sum) // sum of weights equals number of matched treated observations
    drop if _copy == 1
    drop _*
    ultimatch score if period == 0, treated(treated) report(score age weight gender fitness)
    sum _weight if treated == 0 // compare the weights
    di r(sum) 

    // Single Score-based Neighborhood Matching
    // with single draw
    cap drop _*
    ultimatch score if period == 0, treated(treated) report(score age weight gender fitness) single support

    // Score-based Percentile Rank Neighborhood Matching
    cap drop _*
    ultimatch score if period == 0, treated(treated) report(score age weight gender fitness) rank

    // Supported Score-based Neighborhood Matching
    // with exact matching of gender
    cap drop _*
    ultimatch score if period == 0, treated(treated) report(score age weight gender fitness) exact(gender) support

    // Supported Score-based Neighborhood Matching
    // controlling for gender with an expression (same as above but less efficient)
    cap drop _*
    ultimatch score if period == 0, treated(treated) report(score age weight gender fitness) exp(gender == t.gender) support

    // Supported Score-based Neighborhood Matching
    // with percentile rank limitation and common support
    cap drop _*
    ultimatch score if period == 0, treated(treated) report(score age weight gender fitness) limit(age weight) support

    // Score-based Neighborhood Matching (multiple counterfactuals)
    cap drop _*
    ultimatch score if period == 0, treated(treated) report(score age weight gender fitness) draw(3)

    // Sandwiched Score-based Neighborhood Matching
    // with multiple counterfactuals in both directions
    cap drop _*
    ultimatch score if period == 0, treated(treated) report(score age weight gender fitness) draw(3) between

    // Greedy Score-based Neighborhood Matching
    // usage of caliper recommended, especially if draw > 1
    cap drop _*
    ultimatch score if period == 0, treated(treated) report(score age weight gender fitness) draw(3) caliper(0.05) greedy

    // Score-based Radius Matching
    cap drop _*
    ultimatch score if period == 0, treated(treated) report(score age weight gender fitness) caliper(0.01) radius

    // Coarsened Exact Matching
    cap drop _*
    ultimatch if period == 0, treated(treated) report(score age weight gender fitness) exact(agegroup weightgroup gender)
    
    // Copying Single Score-based Neighborhood Matching
    // alternative method to Coarsened Exact based on pseudo score (allows all score-based options like single, copy, greedy)
    // caliper of 0.5 prevents cell transgression
    cap drop _*
    ultimatch coarsecell if period == 0, treated(treated) report(score age weight gender fitness) caliper(0.5) draw(1) single copy
    drop _copy

    // Mahalanobis Distance-based Percentile Rank Neighborhood Matching
    cap drop _*
    ultimatch age weight gender if period == 0, treated(treated) report(score age weight gender fitness) rank mahalanobis

    // Euclidean Distance-based Percentile Rank Neighborhood Matching
    cap drop _*
    ultimatch age weight gender if period == 0, treated(treated) report(score age weight gender fitness) rank euclid

    // Euclidean Distance-based Percentile Rank Radius Matching
    cap drop _*
    ultimatch age weight gender if period == 0, treated(treated) report(score age weight gender fitness) caliper(0.05) rank euclid radius

    // Mahalanobis Distance-based Neighborhood Matching
    cap drop _*
    ultimatch age weight gender if period == 0, treated(treated) report(score age weight gender fitness)

    // Supported Mahalanobis Distance-based Neighborhood Matching incl. score (reporting unmatched for reference)
    cap drop _*
    ultimatch score age weight gender if period == 0, treated(treated) report(score age weight gender fitness) support unmatched

    // difference in differences without matching
    reg weight treated period effect age gender

    // difference in differences with matching
    egen m = max(_match), by(id)  // extending the match into the treatment period
    egen w = max(_weight), by(id) // extending the weight into the treatment period
    reg weight treated period effect age gender [pweight=w] if m != .
{text}

{title:Example 2}

{p}This example creates a two-dimensional scatter plot overlayed with with lines connecting treated (red dots) and counterfactuals (black dots).{p_end}

{p}{hi:Copy+paste} into a do file!{p_end}
{inp}
    clear
    set obs 500
    gen x = uniform()
    gen y = invnorm(uniform())
    sum y
    replace y = (y-r(min))/(r(max)-r(min)) - 0.5
    replace y = x+y*2
    sum x
    replace x = (x-r(min)) / (r(max)-r(min)) // normalizing x-axis
    sum y
    replace y = (y-r(min)) / (r(max)-r(min)) // normalizing y-axis
    gen byte treated = _n <= 250
    ultimatch y x, treated(treated) report(y x) unm copy full euclid
    sum _match
    local max = r(max)
    local graph = ""
    forvalue i = 1/`max' {
        local graph = "`graph' (line y x if _match == `i', lc(gs14))"
    }
    twoway /*
    */ (scatter y x if treated == 0, msize(vsmall) msymbol(circle) mcolor(black)) /*
    */ (scatter y x if treated == 1, msize(vsmall) msymbol(circle) mcolor(red)) /*
    */ `graph', /*
    */ ytitle(Y) ytitle(, size(zero) color(white) orientation(horizontal)) /*
    */ ylabel(none, nogrid) xlabel(none, nogrid) xtitle(X) xtitle(, size(zero)) legend(off) /*
    */ xsize(4) ysize(4) graphregion(margin(0) fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) /*
    */ plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
{text}

{title:Update History}
{p 0 11}{hi:2019.08.26} Fixed a bug in Mahalanobis matching that caused partially greedy behavior in non-greedy mode.{break}
Included options {cmd:euclid} and {cmd:mahalamobis} to improve flexibility for distance matching.{break}
Included option {cmd:full} as sub-option to {cmd:copy} to enforce treated/counterfactual tuples.{break}
Included option {cmd:radius} to explicitly activate radius matching instead of the implicit activation before.{break}
Percentile Rank is now considered a general transformation instead of a separate matching method.{break}
ultimatch now supports radius matching for the distance-based matching method.{break}
Added an additional example.{p_end}

{p 0 11}{hi:2019.04.25} Initial version.{p_end}

{title:Author}

{p 4 4}Thorsten Doherr{break}
Centre for European Economic Research{break}
L7,1{break}
68161 Mannheim{break}
Germany{break}
Phone: +49 621 1235 291{break}
Fax: +49 621 1235 170{break}
E-Mail: doherr@zew.de{break}
Internet: www.zew.de
