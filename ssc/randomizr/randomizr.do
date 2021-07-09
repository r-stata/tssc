qui log using vignette, replace
/*** 
 randomizer vignette 
 =================================== 
 
randomizr is a port of the R package randomizr for Stata that simplifies the 
design and analysis of randomized experiments. In particular, it makes the 
random assignment procedure transparent, flexible, and most importantly 
reproduceable. By the time that many experiments are written up and made public,
the process by which some units recieved treatments is lost or imprecisely 
described. The randomizr package makes it easy for even the most forgetful of 
researchers to generate error-free, reproduceable 
random assignments.

A hazy understanding of the random assignment procedure leads to two main 
problems at the analysis stage. First, units may have 
different probabilities of assignment to treatment. Analyzing the data as though 
they have the same probabilities of assignment 
leads to biased estimates of the treatment effect. Second, units are sometimes 
assigned to treatment as a cluster. For example, 
all the students in a single classroom may be assigned to the same intervention 
together. If the analysis ignores the clustering 
in the assignments, estimates of average causal effects and the uncertainty 
attending to them may be incorrect.
	
 A Hypothetical Experiment
 -------------------------- 

Throughout this vignette, we'll pretend we're conducting an experiment among 
the 592 individuals in R's HairEyeColor 
dataset. As we'll see, there are many ways to randomly assign subjects to 
treatments. We'll step through five common designs, 
each associated with one of the five randomizr functions: simple_ra, 
complete_ra, block_ra, cluster_ra, and 
block_and_cluster_ra.

Typically, researchers know some basic information about their subjects before 
deploying treatment. For example, they usually know
how many subjects there are in the experimental sample (N), and they usually 
know some basic demographic information about each 
subject.

Our new dataset has 592 subjects. We have three pretreatment covariates, Hair, 
Eye, and Sex, which describe the hair color, eye 
color, and gender of each subject. We also have potential outcomes. We call the
 untreated outcome Y0 and we call the treated 
outcome Y1. 
***/
clear all
use HairEyeColor
des
list in 1/5
//set seed for replicability
set seed 324437641


/***
Imagine that in the absence of any intervention, the outcome (Y0) is correlated 
with out pretreatment covariates. Imagine further 
that the effectiveness of the program varies according to these covariates, 
i.e., the difference between Y1 and Y0 is correlated 
with the pretreatment covariates.

If we were really running an experiment, we would only observe either Y0 or Y1 
for each subject, but since we are simulating, we 
have both. Our inferential target is the average treatment effect (ATE), which 
is defined as the average difference between 
Y0 and Y1.

Simple Random Assignment
-------------------------- 

Simple random assignment assigns all subjects to treatment with an equal 
probability by flipping a (weighted) coin for each 
subject. The main trouble with simple random assignment is that the number of 
subjects assigned to treatment is itself a random 
number - depending on the random assignment, a different number of subjects 
might be assigned to each group.

The simple_ra function has no required arguments. If no other arguments are 
specified,  simple_ra assumes a two-group design and 
a 0.50 probability of assignment.
***/

simple_ra Z
tab Z
/***
To change the probability of assignment, specify the prob argument:
***/
simple_ra Z, replace prob(.3)
tab Z
/***
If you specify num_arms without changing prob_each, simple_ra will assume equal 
probabilities across all arms.
***/
simple_ra Z, replace num_arms(3)
tab Z
/***
You can also just specify the probabilites of your multiple arms. The 
probabilities must sum to 1.
***/
simple_ra Z, replace prob_each(.2 .2 .6)
tab Z
/***
You can also name your treatment arms.
***/
simple_ra Z, replace prob_each(.2 .2 .6) condition_names(control placebo treatment)
tab Z
	   
/***
Complete Random Assignment
--------------------------
Complete random assignment is very similar to simple random assignment, except 
that the researcher can specify exactly how many 
units are assigned to each condition.

The syntax for complete_ra is very similar to that of simple_ra. The argument m 
is the number of units assigned to treatment in 
two-arm designs; it is analogous to simple_ra's prob. Similarly, the argument 
m_each is analogous to prob_each.

If you specify no arguments in complete_ra, it assigns exactly half of the 
subjects to treatment.

***/
complete_ra Z, replace
tab Z
/***
To change the number of units assigned, specify the m argument:
***/
complete_ra Z, m(200) replace
tab Z
/***
If you specify multiple arms, complete_ra will assign an equal (within rounding)
number of units to treatment.
***/
complete_ra Z, num_arms(3) replace
tab Z
/***
You can also specify exactly how many units should be assigned to each arm. The 
total of m_each must equal N.
***/
complete_ra Z, m_each(100 200 292) replace
tab Z
/***
You can also name your treatment arms.
***/
complete_ra Z, m_each(100 200 292) replace condition_names(control placebo treatment)
tab Z
/***
###Simple and Complete Random Assignment Compared
When should you use simple_ra versus complete_ra? Basically, if the number of 
units is known beforehand, complete_ra is always 
preferred, for two reasons: 1. Researchers can plan exactly how many treatments 
will be deployed. 2. The standard errors 
associated with complete random assignment are generally smaller, increasing 
experimental power. See this guide on EGAP for more 
on experimental power.

Since you need to know N beforehand in order to use simple_ra(), it may seem 
like a useless function. Sometimes, however, the 
random assignment isn't directly in the researcher's control. For example, when 
deploying a survey exeriment on a platform like 
Qualtrics, simple random assignment is the only possibility due to the 
inflexibility of the built-in random assignment tools. 
When reconstructing the random assignment for analysis after the experiment has 
been conducted, simple_ra() provides a convenient 
way to do so.

To demonstrate how complete_ra() is superior to simple_ra(), let's conduct a 
small simulation with our HairEyeColor dataset.
***/
local sims=1000

//set up empty vectors to collect results
matrix simple_ests=J(`sims',1,.)	
matrix complete_ests=J(`sims',1,.)

//loop through simulation 1000 times
forval i=1/`sims' {
local seed=32430641+`i'
set seed `seed'
//conduct both kinds of random assignment
qui simple_ra Z_simple, replace
qui complete_ra Z_complete, replace

//reveal observed partial outcomes
qui tempvar Y_simple Y_complete
qui gen `Y_simple' = Y1*Z_simple + Y0*(1-Z_simple)
qui gen `Y_complete' = Y1*Z_complete + Y0*(1-Z_complete)

//estimate ATE under both models and save estimates
qui reg `Y_simple' Z_simple
qui matrix simple_ests[`i',1]=_b[Z_simple]
qui reg `Y_complete' Z_complete
qui matrix complete_ests[`i',1]=_b[Z_complete]
}
/***
The standard error of an estimate is defined as the standard deviation of the 
sampling 
distribution of the estimator. When standard errors are estimated (i.e., by 
using the summary() 
command on a model fit), they are estimated using some approximation. This 
simulation allows us 
to measure the standard error directly, since the vectors simple_ests and 
complete_ests describe 
the sampling distribution of each design.
***/
mata: st_numscalar("simple_var",variance(st_matrix("simple_ests")))
mata: st_numscalar("complete_var",variance(st_matrix("complete_ests")))
disp "Simple RA S.D.: " sqrt(simple_var)
disp "Complete RA S.D.: "sqrt(complete_var)

/***
In this simulation complete random assignment led to a
***/
disp round(((simple_var) - (complete_var))/(simple_var)*100, 2)
/***
% decrease in sampling variability. This decrease was obtained with a small 
design tweak that costs 
the researcher essentially nothing.

Block Random Assignment
-------------------------- 
Block random assignment (sometimes known as stratified random assignment) is a 
powerful tool when 
used well. In this design, subjects are sorted into blocks (strata) according to
their pre-treatment 
covariates, and then complete random assignment is conducted within each block. 
For example, a 
researcher might block on gender, assigning exactly half of the men and exactly 
half of the women 
to treatment.

Why block? The first reason is to signal to future readers that treatment effect
heterogeneity may 
be of interest: is the treatment effect different for men versus women? Of 
course, such heterogeneity 
could be explored if complete random assignment had been used, but blocking on 
a covariate defends a 
researcher (somewhat) against claims of data dredging. The second reason is to 
increase precision. If 
the blocking variables are predicitive of the outcome (i.e., they are correlated
with the outcome), 
then blocking may help to decrease sampling variability. It's important, 
however, not to overstate 
these advantages. The gains from a blocked design can often be realized through 
covariate adjustment 
alone.

Blocking can also produce complications for estimation. Blocking can produce 
different probabilities 
of assignment for different subjects. This complication is typically addressed 
in one of two ways: 
"controlling for blocks" in a regression context, or inverse probabilitity 
weights (IPW), in which 
units are weighted by the inverse of the probability that the unit is in the 
condition that it is in.

The only required argument to block_ra is block_var, which is a variable that 
describes which block 
a unit belongs to. block_var can be a string or numeric variable. If no other 
arguments are specified, 
block_ra assigns an approximately equal proportion of each block to treatment.
***/
block_ra Z, block_var(Hair) replace
tab Z Hair
/***
For multiple treatment arms, use the num_arms argument, with or without the 
condition_names argument
***/
block_ra Z, block_var(Hair) num_arms(3) replace
tab Z Hair
block_ra Z, block_var(Hair) condition_names(Control Placebo Treatment) replace
tab Z Hair
/***
block_ra provides a number of ways to adjust the number of subjects assigned to 
each conditions. The 
prob_each argument describes what proportion of each block should be assigned 
to treatment arm. Note 
of course, that block_ra still uses complete random assignment within each 
block; the appropriate 
number of units to assign to treatment within each block is automatically 
determined.			
***/
block_ra Z, block_var(Hair) prob_each(.3 .7) replace
tab Z Hair
/***
For finer control, use the block_m_each argument, which takes a matrix with as 
many rows as there are 
blocks, and as many columns as there are treatment conditions. Remember that the
 rows are in the same 
order as seen in tab block_var, a command that is good to run before 
constructing a block_m_each 
matrix. The matrix can either be defined using the matrix define command or be 
inputted directly into
the block_m_each option.
***/
tab Hair 
matrix define block_m_each=(78, 30\186, 100\51, 20\87,40)
matrix list block_m_each
block_ra Z, replace block_var(Hair) block_m_each(block_m_each)
tab Z Hair 
block_ra Z, replace block_var(Hair) block_m_each(78, 30\186, 100\51, 20\87,40)
tab Z Hair 	
/***
Clustered Assignment
-------------------------- 
Clustered assignment is unfortunate. If you can avoid assigning subjects to 
treatments by cluster, you 
should. Sometimes, clustered assignment is unavoidable. Some common situations 
include:

1) Housemates in households: whole households are assigned to treatment or 
control
2) Students in classrooms: whole classrooms are assigned to treatment or control
3) Residents in towns or villages: whole communities are assigned to treatment 
or control

Clustered assignment decreases the effective sample size of an experiment. In 
the extreme case when 
outcomes are perfectly correlated with clusters, the experiment has an effective 
sample size equal to the 
number of clusters. When outcomes are perfectly uncorrelated with clusters, the 
effective sample size 
is equal to the number of subjects. Almost all cluster-assigned experiments fall 
somewhere in the middle 
of these two extremes.

The only required argument for the cluster_ra function is the clust_var 
argument, which indicates which 
cluster each subject belongs to. Let's pretend that for some reason, we have to 
assign treatments 
according to the unique combinations of hair color, eye color, and gender.
***/
egen clust_var=group(Hair Eye Sex)
tab clust_var
cluster_ra Z_clust, cluster_var(clust_var) 
tab clust_var Z_clust
/***
This shows that each cluster is either assigned to treatment or control. No two 
units within the same 
cluster are assigned to different conditions.

As with all functions in randomizr, you can specify multiple treatment arms in a 
variety of ways:
***/
cluster_ra Z_clust, cluster_var(clust_var) num_arms(3) replace
tab clust_var Z_clust
/***
...or using condition_names. 
***/
cluster_ra Z_clust, cluster_var(clust_var) condition_names(control placebo treatment)  replace
tab clust_var Z_clust
/***
... or using m_each, which describes how many clusters should be assigned to 
each condition. m_each must 
sum to the number of clusters.
***/
cluster_ra Z_clust, cluster_var(clust_var) m_each(5 15 12) replace
tab clust_var Z_clust
/***
Block and Clustered Assignment
-------------------------- 
The power of clustered experiments can sometimes be improved through blocking. 
In this scenario, whole 
clusters are members of a particular block -- imagine villages nested within 
discrete regions, or classrooms 
nested within discrete schools.

As an example, let's group our clusters into blocks by size	
***/
bysort clust_var: egen cluster_size=count(_n)
block_and_cluster_ra Z, block_var(cluster_size) cluster_var(clust_var) replace
tab clust_var Z
tab cluster_size Z 
qui log c

markdoc vignette, replace export(html) install mathjax     
markdoc vignette, replace export(pdf)    
