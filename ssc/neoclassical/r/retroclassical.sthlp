{smcl}
{* *! version 1.0.0 21Jul2010} {...}
{cmd: help retroclassical}
{hline}

{title: Title}
{phang}

{bf: retroclassical -- estimates neoclassical education transitions model without 
selection}

{title: Syntax}
{cmd: retroclassical} Y1 "TC1" "TV1Names" "Exclusions" Y1Independent
   Y2 "TC1" "TV2Names" Y2Independent [cluster] ;
   
{title: Description}
{pstd}

{cmd:retroclassical} estimates a bivariate probit model with coefficients re-scaled to 
facilitate cross-equation testing for coefficient equality.  This model sets the 
cross-equation error covariance equal to zero.  It is termed retroclassical for it is 
midway between a variant of the neoclassical education transitions framework proposed 
in Lucas, Fucella, and Berends (2011) and the classical education transitions 
approach.  Note that the first transition appears in the second equation in the 
output.  Yet, in specifying the model the temporally earlier transition is always 
regarded as the first transition.  The estimates are the re-scaled coefficients and 
the appropriate standard errors.  Any subsequent statistical tests will use this 
second set of results.  A related command, {help neoclassical}, estimates a 
neoclassical education transitions model while estimating a possibly non-zero 
cross-equation error variance.  {help neoclassical} provides one part of one way to 
implement the neoclassical education transitions framework, calibrating the 
coefficients across transitions, while accounting for selection.

{phang}
{opt Y1} is the outcome variable for the first transition--this is the selection 
equation for the second transition

{phang}
{opt "TC1"} contains the list of time constant variables; these should be common 
across the first and second equations.  The set of variables should be in quotes 

{phang}
{opt "TV1Names"} contains the names of the variables that have specific values for the 
first transition (and possibly different values for the second transition).  The set 
of variables should be in quotes

{phang}
{opt "Exclusions"} are those variables in the selection equation that are not in the 
equation for the second transition.  An explicit category is made for these variables 
to reinforce the necessity of having such variables to identify the selection process. 
The set of variables should be in quotations, even if it is only 1 variable

{phang}
{opt Y1Independent} is the total number of independent variables in the first equation

{phang}
{opt Y2} is the outcome variable for the second transition--this is the last of the 
two transitions

{phang}
{opt "TC1"} contains the list of variables that are common across the first and second 
equations.  The set of variables should be in quotes and should have the exact same order
as when the variables appeared earlier in the command

{phang}
{opt "TV2Names"} contains the variables that have specific values for the second 
transition (and possibly different values for the first transition).  These variables 
should be in quotes

{phang}
{opt Y2Independent} is the total number of independent variables in the second 
transition equation

{phang}
{opt deff} MUST be supplied.  It is the value of the design effect.  If no design 
effect is needed, input 1.0.

{phang}
{opt cluster} is a variable you may use to obtain Huber-White standard errors

{phang}
{title: Also see}
{psee}
Lucas, Samuel R., Phillip N. Fucella, and Mark Berends. 2011.  "Neo-Classical 
Education Transitions: A Corrected Tale for Three Cohorts."  Research in Social 
Stratification and Mobility.
