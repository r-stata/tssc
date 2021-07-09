{smcl}
{* *! version 1.0.0 21Jul2010} {...}
{cmd: help neoclassical}
{hline}

{title: Title}
{phang}

{bf: neoclassical -- estimates neoclassical education transitions model}

{title: Syntax}
{cmd: neoclassical} Y1 "TC1" "TV1Names" "Exclusions" Y1Independent
   Y2 "TC1" "TV2Names" Y2Independent deff [cluster] ;
   
{title: Description}
{pstd}

{cmd:neoclassical} estimates a bivariate probit model with selection with coefficients 
re-scaled to facilitate cross-equation testing for equality.  It is termed 
neoclassical for it is a variant of the neoclassical education transitions framework 
proposed in Lucas, Fucella, and Berends (2011).  Note that the first transition 
appears in the second equation in the output.  Yet, in specifying the model the 
temporally earlier transition is always regarded as the first transition.  The 
estimates are the re-scaled coefficients and the appropriate standard errors.  Any 
subsequent statistical tests will use this second set of results.  A related command, 
{help retroclassical}, estimates a neoclassical education transitions model while 
fixing the cross-equation error variance at zero.  This provides the result one would 
obtain by calibrating the coefficients across transitions, yet not accounting for 
selection.  Thus, it is a mid-way point between a neoclassical approach and the 
classical approach.

{phang}
{opt Y1} is the outcome variable for the first transition--this is the selection 
equation for the second transition

{phang}
{opt "TC1"} contains the list of time constant variables; these should be common 
across the first and second equations.  The set of variables should be in quotes
both times they are listed, and in the same exact order.

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
{opt "TV2Names"} contains the variables that have specific values for the second 
transition (and possibly different values for the first transition).  These variables 
should be in quotes

{phang}
{opt Y2Independent} is the total number of independent variables in the second 
transition equation

{phang}
{opt deff} MUST be supplied.  It is a design effect and must be listed as 1.0 if there
is no design effect.

{phang}
{opt cluster} is a variable you may use to obtain Huber-White standard errors.  This 
is optional.

{phang}
{title: Also see}
{psee}
Lucas, Samuel R., Phillip N. Fucella, and Mark Berends. 2011.  "Neo-Classical 
Education Transitions: A Corrected Tale for Three Cohorts."  Research in Social 
Stratification and Mobility.
