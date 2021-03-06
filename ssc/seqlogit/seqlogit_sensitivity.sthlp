{smcl}
{* MLB 12Apr2012}{...}
{* MLB 22Mar2012}{...}
{* MLB 03Sep2010}{...}
{hline}
Example of how to run a sensitivity analysis with {cmd:seqlogit}
{hline}

{title:Why a sensitivity analyis?}

{pstd}
There is some concern that sequential logit models, as can be estimated with {help seqlogit}, are
especially sensitive to variables that influence the outcome, but are not observed and are thus
not included in the model (Cameron and Heckman 1998). The size of this biasing influence depends
on these unobserved variables, but also on the observed data, the exact model that is estimated,
and the hypothesis that is being test. To find out whether unobserved variables can be a problem
for your model, estimated on your data, testing your hypotheses, {cmd:seqlogit} can estimate a 
sequential logit given a specific scenario concerning unobserved variables. {cmd:seqlogit} allows
a wide variety of such scenario, and the results of a set of such scenarios together form a 
sensitivity analyisis as discussed in (Buis 2011). 

{pstd}
If all our scenarios do not lead to substantive changes in our conclusion we can use that as 
support for using a regular sequential logit. If you do find that some scenarios lead to 
substantive changes, than the scenarios can help you pinpoint specific characteristics of these 
unobserved variables that are especially problematic. This can be very helpful when choosing an
alternative model that corrects for unobserved heterogeneity. For example: should that model allow 
for correlation between the unobserved variable and the observed variables in the first transition 
(that is, can we use a random effects model or not?), or can we get away with a model that assumes 
that the amount of unobserved heterogeneity is constant over transitions or variables like time, 
or must we use models that allow for such heteroskedasticity. There is a wide variety of models to 
choose from when it comes to correcting for unobserved heterogeneity but none can controll for all 
aspects. So having an idea of what the important aspects are can be helpful when choosing your method.


{title:Selecting which scenarios to include}

{pstd}
{cmd:seqlogit} allows for scenarios that differ with respect to 

{pmore}
The amount of unobserved heterogeneity (as specified in the {cmd:sd()} option).

{pmore}
How the amount of unobserved heterogeneity changes over transitions (as specified in the {cmd:sd()}
option), or over other variables (as specified in the {cmd:deltasd()} option.

{pmore}
The correlation between the unobserved variable and observed variable of interest (as specified in
the {cmd:rho()} option).

{pmore}
The distribution of the unobserved variable (either normal (the default), a discrete distribution
(the {cmd:pr()} option), a mixture of normal distributions (the {cmd:mn()} option), or a uniform
distribution (the {cmd:uniform} option).

{pstd}
The hard part is to determine a set of scenarios that on the one hand push the model hard, but on
the other hand are still (somewhat) plausible. This is not a technical problem, but a substantive
one. The best thing one can do is look at the literature in your field, and see what kind of effects
occur in real data. Remember that the effect specified in the {cmd:sd()} option can be thought of 
as effects of a standardized variable. This is for example the approach taken in Buis (2011)

{pstd}
To keep the number of scenarios manageable (and estimateable) you will typically want to break your
sensitivity analysis up into several sub-analyses: One that only changes the amount of unobserved
heterogeneity, one that fixes the initial amount of unobserved heterogeneity at one number but
alows it to change in differing degrees over transitions, one that fixes the amount of unobserved
heterogeneity to one number but allows the initial correlation between the unobserved variable
and the observed variable of interest to change, etc.


{title:How to do a sensitivity analysis}

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
without unobserved heterogeneity, In this case I model educational attainment of an women who were
asked in 1988 how many years of schooling they attained. I modeled this as three transition: whether
or not someone finished highschool, whether they went to college given that they finished highschool,
and whether they finished 4 year college given that they started college. The variable of interest
is whether or not the respondent classified herself as white, and I allowed the effect of that 
variable to change linearly over year of birth (byr). 

{cmd}
    sysuse nlsw88, clear
    gen ed = cond(grade< 12, 1, ///
             cond(grade==12, 2, ///
             cond(grade<16,3,4))) if grade < .
    label define ed 1 "less than high school" ///
                    2 "high school"           ///
                    3 "some college"          ///
                    4 "college" 
    label value ed ed
    gen byr = (1988-age-1950)/10
    gen white = race == 1 if race < .

    seqlogit ed byr south,                   ///   
             ofinterest(white) over(byr)     ///
             tree(1 : 2 3 4, 2 : 3 4, 3 : 4) 
    est store s0
{txt}

{pstd}
Next I will estimate the other scenarios. In this case I will look at the influence of changing the 
amount of unobserved heterogeneity. So here I estimated three scenarios, where in each subsequent 
scenario the amount of unobserved heterogeneity increased by .5.

{cmd}
    seqlogit ed byr south,                   ///   
             ofinterest(white) over(byr)     ///
             tree(1 : 2 3 4, 2 : 3 4, 3 : 4) ///
             or sd(.5) 
    est store s1
	
    seqlogit ed byr south,                   ///   
             ofinterest(white) over(byr)     ///
             tree(1 : 2 3 4, 2 : 3 4, 3 : 4) ///
             or sd(1) 
    est store s2
	
    seqlogit ed byr south,                   ///   
             ofinterest(white) over(byr)     ///
             tree(1 : 2 3 4, 2 : 3 4, 3 : 4) ///
             or sd(1.5) 
    est store s3
{txt}

{pstd}
Next we can use these stored scenarios to look if our conclusions are sensitive to the amount of 
unobserved heterogeneity. Say we are interested in the effect of being white for women born in
1950 in the final transition. The variable white is in our model interacted with the variable byr, 
which is 0 when a respondent is born in 1950. So we are looking at the parameter of white. I 
start with creating an empty matrix in which I will later store the results from the different 
scenarios. I have 4 scenarios, so the matrix will contain 4 rows. For each scenario I want to 
store the amount of unobserved heterogeneity, the coefficient of white, and the p-value of the 
test whether this coeficient equals 0, so the matrix will contain three columns. 

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
that I created my scenarios in such a way that the amount of unobserved heterogeneity equals `i'*.5. 
In general one creates the scenarios in such a way that they differ in some regular way, and you 
can often use that regularity to populate the first column of such a results matrix. 

{pmore}
The second  number is the coeficient of white for the third transition. Here I used the standard 
Stata way of retrieving coefficients from models, for more see here: {help _variables}. 

{pmore}
The final number is the p-value of the test whether that coeficient equals 0. This p-value was
left behind by the {help test} command as r(p).

{cmd}
    forvalues i = 0/3 {
        est restore s`i'
        test [#3]_b[white] = 0
        local j = `i' + 1
        matrix res[`j',1] =  .5*`i', [#3]_b[white], r(p)
    }
    matrix colnames res = "sd" "b" "p"
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

    twoway line b sd,                                        ///
    xtitle("effect of the standardized unobserved variable"  ///
           "(log odds ratio)")                               ///
    ytitle("effect of white (log odds ratio)")

    twoway line p sd,                                        ///
    xtitle("effect of the standardized unobserved variable"  ///
           "(log odds ratio)")                               ///
    ytitle("p-value of test whether effect of white = 0")    ///
    yline(.05)
{txt}


{title:Putting it all together:}

{cmd}
    // start with preparing your data
    sysuse nlsw88, clear
    gen ed = cond(grade< 12, 1, ///
             cond(grade==12, 2, ///
             cond(grade<16,3,4))) if grade < .
    label define ed 1 "less than high school" ///
                    2 "high school"           ///
                    3 "some college"          ///
                    4 "college" 
    label value ed ed
    gen byr = (1988-age-1950)/10
    gen white = race == 1 if race < .

    // estimate your scenarios	
    seqlogit ed byr south,                   ///   
             ofinterest(white) over(byr)     ///
             tree(1 : 2 3 4, 2 : 3 4, 3 : 4) ///
             or 
    est store s0

    seqlogit ed byr south,                   ///   
             ofinterest(white) over(byr)     ///
             tree(1 : 2 3 4, 2 : 3 4, 3 : 4) ///
             or sd(.5) 
    est store s1
	
    seqlogit ed byr south,                   ///   
             ofinterest(white) over(byr)     ///
             tree(1 : 2 3 4, 2 : 3 4, 3 : 4) ///
             or sd(1) 
    est store s2
	
    seqlogit ed byr south,                   ///   
             ofinterest(white) over(byr)     ///
             tree(1 : 2 3 4, 2 : 3 4, 3 : 4) ///
             or sd(1.5) 
    est store s3
	
    // collect estimates from scenarios

    matrix res = J(4,3,.)
    forvalues i = 0/3 {
        est restore s`i'
        test [#3]_b[white] = 0
        local j = `i' + 1
        matrix res[`j',1] =  .5*`i', [#3]_b[white], r(p)
    }
    matrix colnames res = "sd" "b" "p"
	
    // tabulate the estimates
    matlist res, names(columns) format(%9.3g)
	
    // graph the estimates  
    // first turn the matrix into variables
    svmat res, names(col)

    // graph the variables	
    twoway line b sd,                                        ///
    xtitle("effect of the standardized unobserved variable"  ///
           "(log odds ratio)")                               ///
    ytitle("effect of white (log odds ratio)")

    twoway line p sd,                                        ///
    xtitle("effect of the standardized unobserved variable"  ///
           "(log odds ratio)")                               ///
    ytitle("p-value of test whether effect of white = 0")    ///
    yline(.05)
{txt}


{title:References}

{p 4 4 2}
Buis, maarten L. 2011 
``The Consequences of Unobserved Heterogeneity in a Sequential Logit Model'', 
Research in Social Stratification and Mobility, 29(3), pp. 247-262.
{browse "http://dx.doi.org/10.1016/j.rssm.2010.12.006"}

{pstd}
Cameron, Stephen V. and James J. Heckman. 1998. "Life Cycle Schooling and Dynamic
Selection Bias: Models and Evidence for Five Cohorts of American Males."
{it:The Journal of Political Economy} 106:262?333.


{title:Author}

{p 4 4 2}Maarten L. Buis, Universitaet Tuebingen{break}maarten.buis@uni-tuebingen.de


{title:Also see}

{p 4 13 2}
Online: help for {helpb seqlogit}, {helpb estimates}, {helpb lincom}, 
{helpb nlcom}, {helpb test}, {helpb testnl}
{p_end}

