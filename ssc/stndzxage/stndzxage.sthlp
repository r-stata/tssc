{smcl}
{* *! Verions 1   31jul2018}{...}
{cmd:help stndzxage}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}

{hline}

{title:Title}

{p2colset 5 11 13 2}{...}
{p2col :{hi:stndzxage} {hline 2} STaNDardiZe byX AGE}{p_end}
{p2colreset}{...}

{p 5 5 0}
This command standardizes test scores with respect to the mean across age (a running variable) 
assuming normal distributions given age.  Additional variables can be specified 
over which the test variable is age-standardized. For example, a test score could be  
standardized over age and sex. Additionally, a subpopulation can serve as a reference population 
for standardizing the scores of other observations in the same dataset. The program creates a 
new z-score variable, stx_{it:testvar}.  

{title:Syntax}

{p 5 5 2}
{cmdab:stndzxage}
testvar agevar [{it:varlist}] [if]
[{cmd:,} {it:options}]

{p 8 8 8}
{it:testvar} is the variable (test score) to be standardized {p_end}

{p 8 8 8}
{it:agevar} is the running variable over which standardization is done.  
In the child development context, this is typically age, but in other contexts, 
different variables could be used.  For example, to calculate a measure of 
height-standardized basketball skill, the test variable could be number of baskets made 
in 1 minute and the running variable is height.  The age variable should be an 
integer when {it:continuous} is not chosen.

{p 8 8 8} 
[{it:varlist}] are additional categorical variables over which to standardize, 
such as sex or language {p_end}
 
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}

{synopt:{opt binw:idth(#)}} number of units of {it:agevar} that establishes the 
interval in which the test scores of children will grouped for standardized.  Default is 1.
Cannot be used with the option continuous. {p_end}

{synopt:{opt minb:insize(#)}} minimum number of observations in a bin.  For bins 
with fewer than #, stndzxage changes the values of stx_testvar 
to missing.  Default is 30. When continuous is specified, binwidth refers to the minimum 
number of observations required in the bins defined by {it:varlist} 
(and the reference variable, if indicated).  {p_end}

{synopt:{opt cont:inuous}} Instead of standardizing over subgroups of age, 
the entire age span is used for fitting means and standard deviations using a
polynomial of degree specified in the option {it:polynomial}.  The default is a 
third-degree polynomial. Cannot be used with minbinsize. Default is to 
standardize using the discreet age bins.  {p_end}

{synopt:{opt poly:nomial(#)}} A polynomial of degree # is used to generate the 
age-specific means. Option {it:continuous} must be specified. Default is 3. {p_end}

{synopt:{opt ref:erence(varname)}} The mean and standard deviation used in standardizing
is generated only using observations for which {it:varname}=1, and these reference 
means and standard deviations are applied to the entire population.  {it:varname} 
must only have 0 & 1 values.  Default is to standardize using the entire population. {p_end}

{synopt:{opt ce:iling}}applies a Tobit estimation of the mean using the maximum value of {it:testvar} as the  ceiling. {p_end}
				
{synopt:{opt fl:oor}}applies a Tobit estimation of the mean using the minimum value of {it:testvar} as the floor. {p_end}	
		
{synopt:{opt mean(#)}} adjusts the standardization to the indicated mean # instead of the default 0. {p_end}

{synopt:{opt sd(#)}} adjusts the standardization to the indicated standard deviation # 
instead of the default 1. {p_end}

{synopt:{opt med:ian}}allows for normalization with respect to the median rather
than the mean. Default is mean. Cannot be used with continuous, floor or ceiling. 
(Note:   {p_end}

{synopt:{opt gr:aph}}generates diagnostic graphs. Needs the user-written command
{it:grc1leg} installed. {p_end}
{synoptline}

{title:Description}
{marker description}{...}

{p 5 5 2}
Child ability is often age dependent; standardizing assessments of child development
by age can be helpful for comparisons. For example, children’s test scores are 
dependent on age and a wealth index, but a two-dimensional graph showing standardized
scores by wealth is simpler to illustrate.  Similarly, standardized scores can 
also be helpful in comparing results on different tests.  
{p_end}

{p 5 5 2}
When external norms for standardizing scores are not available or not recommended 
to implement, as in the case with cross-cultural applications of tests, the 
researcher can standardize the test within the population. 
{p_end}

{p 5 5 2}
A number of child development assessments vary the questions given based on the 
child's age (Ages & Stages Questionaire, for example).  Thus the standardization 
of these scores should maintain these age groupings to obtain comparability. The 
score of a 3-month old child should not be standardized with the scores of a 
4-month old child because the questions the parent answers are different.  In this
case, a categorical variable can be specified to indicate question set.  When this 
variable is used in addition to the age variable, {it:stndzxage} ensures that 
the standardization is done separately for each subgroup (question set) 
{p_end}

{p 5 5 2}
If a researcher wishes to standardize by question set, but there are different
ages for which each question set is applied, the categorical variable indicating
which question set was administered can substitute for the age variable in the 
command line.
{p_end}

{p 5 5 2}
{it:stndzxage} provides discrete and continuous methods by which 
within-population age-standardized scores are computed.  
{p_end}

{p 5 5 2} 
{bf:1.Discrete intervals} With this method, the population is divided into 
discrete groups. The grouping criteria can be chosen to account for the density 
of the data over age.  Large populations can group fewer age units while smaller
populations may require wider bins.  
{p_end}

{p 5 5 2}
To ensure sufficient density of the population for standardization, use 
{it: minbinsize} to indicate the minimum number of observations in each bin.  
Then use the option {it: binwidth} to indicate how many units of agevar are 
combined in an age bin.  Bin formation always starts with the youngest age. 
All age levels are included even if there are no individuals of that a given age 
in the data.  If the last group contains just one age unit, it is combined with
the previous group, unless winsize is 1.  See examples below: 
{p_end}


{bf:Values of {it:agevar} in data set} | {bf:binwidth} | {bf:Resulting intervals} 
-----------------------------|----------|---------------------
4, 5, 6, 7, 8, 9, 10         | 2        | 4-5, 6-7, 8-10    
4, 5, 7, 8, 10, 11, 12, 13   | 4        | 4-7, 8-11, 12-13      
4, 5, 7, 8, 10, 11, 13       | 4        | 4-7, 8-11, 12-13    
4, 5, 7, 8, 9, 10, 12        | 4        | 4-7, 8-12             

{p 5 5 2}
{it:stx_testvar} is assigned a value of missing if the number of observations in each
 bin (defined by {it:binwidth} and categorical variables var1, var2, etc.) is less 
 than the specified {it:minbinsize}.  The default minimum bin size is 30. {p_end} 

{p 5 5 2}
{bf:2.Continuous} Data from children across the entire age range may be used to 
determine the mean and standard deviation. {it:stndzxage} uses a polynomial, 
with the degree to be chosen using the option {it:poly(#)}.  The default is
a 3rd degree polynomial, as has been used before in the literature (Rubio-Codina). 
The age dependent standard deviation is calculated similarly by fitting a 
a polynomial (of the same degree indicated by {it:poly(#)}) to the absolute 
value of the residuals. A kernel smoothing option (e.g. lowess) is currently not
provided because this does not allow for the Tobit adjustment. 
{p_end}

{p 5 5 2}
{bf:3.Other features} Sometimes subpopulations require different standardizations, 
such as males and females.  Categorical variables can be listed after the age 
variable to indicate further divisions of the data.  In the discrete process,
the age bins align for all subpopulations.
{p_end}

{p 5 5 2}
A {it:reference} population may be chosen, indicated by a binary variable.  In 
this case, the standardization procedures described above are performed only 
on the reference population, and then these norms are used to calculate 
standardized scores for the rest of the population.  Age distributions of 
the two populations might not always match, so depending on criteria for bin 
width and size, there may be some individuals who remain with unstandardized 
scores.
{p_end}
 
{p 5 5 2} 
One can standardize using the {it:median} instead of the mean, but this is 
available only in the discrete case.  The standard deviation is still generated 
around the mean, however. The {it:mean} and {it:sd} options are useful for 
situations where child development scores are standardized with a mean of 100 
and a standard deviation of 15, as is common in the literature. 
{p_end}

{p 5 5 2} 
A diognostic {it:graph} can be produced to assess if the standardization choices
were appropriate. If a reference group was chosen, only the data from the 
reference group is presented.  For each integer of age, the raw data graph(s) 
show means (or median) used in standardization along with the actual test scores.  
The standardized graph shows the standardized test scores and thier means.  If 
the standardized graph does not appear relatively flat, the researcher may wish
to consider other standardization options (e.g. continuous instead of bins).
{p_end}

{marker examples}{...}
{title:Examples}

{phang}{cmd:. stndzxage ppvt agemonths}{p_end}

{phang}{cmd:. stndzxage ppvt agemonths, continuous graph}{p_end}

{phang}{cmd:. stndzxage ppvt agemonths SES, ref(boy) minbinsize(30) binwidth(3) mean(100) sd(15)}{p_end}

{hline}
{title:Acknowledgements}
Thanks to Soledad Martinez, Ann Weber, Beth Prado, & Lia Fernald



{title:Author}

{pstd}Sarah Anne Reynolds{p_end}
{pstd}School of Public Health{p_end}
{pstd}University of California, Berkeley{p_end}
{pstd}sar48@berkeley.edu{p_end}

