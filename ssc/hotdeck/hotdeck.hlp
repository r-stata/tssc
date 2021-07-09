{smcl}
{*  15 Aug 2007}{...}
{cmd:help hotdeck}
{hline}

{title:Title}

  {hi:Impute missing values using the hotdeck method}

{title:Syntax}

{p 8 27}
{cmdab:hotdeck}
[{it:varlist}] [{cmd:using}] [{hi:if}{it: exp}] [{hi:in}{it: exp}]
,
[
{cmdab:by}{cmd:(}{it:varlist}{cmd:)}
{cmdab:store}
{cmdab:imp:ute}{cmd:(}{it:varlist}{cmd:)}
{cmdab:noise}
{cmdab:keep}{cmd:(}{it:varlist}{cmd:)}
{cmdab:com:mand}{cmd:(}{it:command}{cmd:)}
{cmdab:parms}{cmd:(}{it:varlist}{cmd:)}
{cmdab:seed}{cmd:(}{it:#}{cmd:)}
{cmdab:infiles}{cmd:(}{it:filename filename ...}{cmd:)}
]

{p}

{title:Description}

{pstd}
{hi:Hotdeck} will tabulate the missing data patterns within the {help varlist}.
A row of data with missing values in any of the variables in the {hi:varlist}
 is defined as a `missing line' of data, similarly a `complete line' is one where all the 
variables in the {hi:varlist} contain data. The {hi:hotdeck} procedure
replaces the {hi:varlist} variables in the `missing lines' with the 
corresponding values in the `complete lines'.
{hi:Hotdeck} should be used several times within a multiple imputation 
sequence since missing data 
are imputed stochastically rather than deterministically. The {hi:nmiss} missing 
lines in each stratum of the data described by the `by' option are replaced 
by lines sampled from the {hi:nobs} complete lines in the same stratum. The 
approximate Bayesian bootstrap method of Rubin and Schenker(1986) is used; 
first a bootstrap sample of {hi:nobs} lines are sampled with replacement from 
the complete lines, and the {hi:nmiss} missing lines are sampled at random 
(again with replacement) from this bootstrap sample.

{pstd}
A major assumption with the hotdeck procedure is
that the missing data are either missing completely at random (MCAR) or is 
missing at random (MAR), the probability that a line is missing
varying only with respect to the categorical
variables specified in the `by' option. 

{pstd}
If a dataset contains many variables with missing values then 
it is possible that many of the rows of data will contain at 
least one missing value. The {hi:hotdeck} procedure will not work 
very well in such circumstances.
There are more
elaborate methods that {bf:only} replace missing values, rather than the whole row,
 for imputed values.
These multivariate multiple imputation methods are discussed by Schafer(1997).

{pstd}
A critical point is that all variables that are used in the analysis should be included in
the variable list. This is particularly true for variables that have missing data! 
Variables that predict missingness should be included in the
by option so missing data is imputed within strata.

{title:Latest Version}

{pstd}
The latest version is always kept on the SSC website. To install the latest version click
on the following link 

{phang}
{stata ssc install hotdeck, replace}.

{title:Options}

{phang}
{cmdab:using} specifies the root of the imputed datasets filenames. The default is
"imp" and hence the datasets will be saved as imp1.dta, imp2.dta, ....

{phang}
{cmdab:by}{cmd:(}{it:varlist}{cmd:)} specifies categorical variables defining strata within which 
the imputation is to be carried out. Missing values will be replaced by complete values only within the
strata. If within a strata there are no complete records then no data will be imputed and will lead
to the wrong answers. Make sure there are a reasonable number of complete records per strata.

{phang}
{cmdab:store} specifies whether the imputed datasets are saved to disk.

{phang}
{cmdab:imp:ute}{cmd:(}{it:varlist}{cmd:)} specifies the number of imputed datasets to generate. The number
needed varies according to the percentage missing and the type of data, but 
generally 5 is sufficient.

{phang}
{cmdab:noise} specifies whether the individual analyses, from the {hi:command()} option, 
are displayed.

{phang}
{cmdab:keep}{cmd:(}{it:varlist}{cmd:)} specifies the variables saved in the imputed datasets
in addition to the imputed variables and the by list. By default the imputed
variables and the by list are always saved.

{phang}
{cmdab:com:mand}{cmd:(}{it:command}{cmd:)} specifies the analysis performed on every imputed dataset.

{phang}
{cmdab:parms}{cmd:(}{it:varlist}{cmd:)} specifies the parameters of interest from the
analysis. If the {hi:command} is a regression command then the parameter list can
include a subset of the variables specified in the regression command.The 
final output consists of the combined estimates of these parameters.
For non-standard commands that are "regression" commands the {hi:parms()} option
looks at the estimation matrix e(b) and requires the column names to identify
the coefficients of interest.

{phang}
{cmdab:seed}{cmd:(}{it:#}{cmd:)} specifies the random number generator seed. When using the {hi:seed} option
the hotdeck command must be used in the correct way. The key point is that ALL variables in the analysis command
must be in the variable list, this ensures that the correlations between the variables are maintained post
imputation.

{phang}
{cmdab:infiles}{cmd:(}{it:filename filename ...}{cmd:)} specifies a list of files that have missing
values replaced by imputed values. This is convenient when the user has
several imputed datasets and wants to analyse them and combine the results.


{title:Examples}

Impute values for y in sex/age groups.

  {inp:hotdeck y, by(sex age) }

Additionally to store the imputed datasets above as {hi:imp1.dta} and {hi:imp2.dta}.

  {inp:hotdeck y using imp,store by(sex age) impute(2)} 

{p 0 0}
Hotdeck can also use the stored imputed datafiles hi:imp1.dta} and {hi:imp2.dta}
and carry out the combined analysis. This analysis is displayed for the coefficient
of {hi:x} and constant term {hi:_cons}.

  {inp:hotdeck y using imp, command(logit y x) parms(x _cons) infiles(imp1 imp2)}  

{p 0 0}
Do not save imputed datasets to disk but carry out a logistic regression on the imputed
datasets and display the coefficients for {hi:x} and the constant term {hi:_cons} of the model.

  {inp:hotdeck y x, by(sex age) command(logit y x) parms(x _cons) impute(5)} 


{title:Example - Multiple Equation Model}

{p 0 0}
Multiple equation models require more complicated {hi:parms()} statements.
The example used can be applied to all multiple equation models. The only complication
is that the name of the coefficients are different. 

For the following command

{inp:xtreg kgh f1, mle}

Then inspect the matrix of coefficients

{inp:mat list e(b)}

   e(b)[1,4]
             kgh:        kgh:    sigma_u:    sigma_e:
               f1       _cons       _cons       _cons
   y1  -1.6751401   77.792948           0   16.730843

Then the following command will do an imputation and analysis for the single parameter.

{inp:hotdeck kgh, by(ethn) command(xtreg kgh f1, mle) parms(kgh:f1) impute(5)}

{title:Example - mlogit}

Use this web dataset for STATA release 9.

{stata "use http://www.stata-press.com/data/r9/sysdsn3.dta"}

The simple model without handling missing data

{stata mlogit insure male}

{p 0 0}
The estimated coefficients are put automatically by STATA into the matrix e(b), note the column
headings are the parameter names that {hi:hotdeck} uses. So you can not use the simple syntax
of just {hi:parms(male)} because this refers to two parameters. 

{stata mat list e(b)}

{p 0 0}
So this syntax will handle the missing data using {hi:hotdeck} imputation.

{stata "hotdeck insure male, command(mlogit insure male) parms(Prepaid:male) impute(5)"}

{p 0 0}
{hi:NOTE} hotdeck will fail when using mlogit with spaces in the category labels. This is due
to the lack of functionality in STATA's matrix commands.

{title:Author}

{p}
Adrian Mander, MRC Human Nutrition Research, Cambridge, UK.

Email {browse "mailto:adrian.mander@mrc-hnr.cam.ac.uk":adrian.mander@mrc-hnr.cam.ac.uk}

{title:See Also}
Related commands

HELP FILES 	Installation status	SSC installation links		Description

{help whotdeck}		(if installed)		({stata ssc install whotdeck})  	Weighted version of Hotdeck
