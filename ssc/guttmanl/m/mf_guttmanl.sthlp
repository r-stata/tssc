{smcl}
{* version 2.0.0}{...}
{cmd:help mata guttmanl()}
{hline}

{title:Title}

{phang}
{cmd:guttmanl()} {hline 2} Guttman lower bound reliability coefficients


{title:Syntax}

{p 8 42}
{bind:           }{it:g} {cmd:=}
{cmd:guttmanl_setup(}{it:real matrix C}
[{cmd:,} {it:real scalar tbl}]{cmd:)}

{p 8 42}
{it:real colvector}
{cmd:guttmanl(}{it:g}{cmd:)}

{p 8 42}
{bind:   }{it:real scalar}
{cmd:guttmanl_get_l{it:#}(}{it:g}{cmd:)}


{p 8 42}
{it:real colvector}
{cmd:guttmanl_get_l4_q(}{it:g}
[{cmd:,} {it:real rowvector q}{cmd:,}
{it:real scalar newt}]{cmd:)}

{p 8 42}
{bind:   }{it:real matrix}
{cmd:guttmanl_get_l4_which_t(}{it:g}
[{cmd:,} {it:real colvector L4}]{cmd:)}

{p 8 42}
{it:real rowvector}
{cmd:guttmanl_get_l4_which_q(}{it:g}
[{cmd:,} {it:real scalar l4}]{cmd:)}

{p 8 42}
{bind:          }{it:void}
{cmd:guttmanl_set_l4_t(}{it:g}{cmd:,}
{it:real matrix T}{cmd:)}

{p 8 42}
{bind:          }{it:void}
{cmd:guttmanl_set_l4_optimize(}{it:g}
[{cmd:,} {it:real scalar reps}]{cmd:)}


{p 8 42}
{it:real colvector}
{cmd:guttmanl_data(}{it:real matrix X}{cmd:)}


{p 5}
where

{p 8 12 2}
{it:g} is {it:transmorphic} and is passed to the other 
{cmd:guttmanl}*{cmd:()} functions.

{p 8 12 2}
{it:C} is a {it:n x n} covariance matrix.

{p 8 12 2}
{it:tbl}=0 issues a Stata error message instead of a 
traceback log.

{p 8 12 2}
{cmd:{it:#}} is 1, 2, 3, 4, 5 or 6.

{p 8 12 2}
{it:q} is a vector with elements 0<={it:q_i}<=1, indicating 
the quantile split-half coefficients.

{p 8 12 2}
{it:newt} is best not specified. {it:newt}!=0 specifies that 
a random matrix {it:T} be obtained if {it:reps}>0 (see below).

{p 8 12 2}
{it:L4} is a {it:m x} 1 column vector of split-half reliability 
coefficients, obtained from {cmd:guttmanl_get_l4()} or 
{cmd:guttmanl_get_l4_q()}.

{p 8 12 2}
{it:l4} is one split-half reliability coefficient, obtained 
from {cmd:guttmanl_get_l4()} or {cmd:guttmanl_get_l4_q()}.

{p 8 12 2}
{it:T} is a {it:n x m} matrix, indicating the split-halves.

{p 8 12 2}
{it:reps} is a real scalar indicating the number of 
repetitions, i.e. the number of locally optimized 
split-halves.

{p 8 12 2}
{it:X} is a matrix with raw values (test scores, ratings, ...).


{title:Description}

{pstd}
{cmd:guttmanl()} computes lower bound reliability 
coefficients as proposed by Guttman (1945). 

{pstd}
Reliability coefficients are estimated from a covariance matrix 
that is specified with {cmd:guttmanl_setup()}. It is {it:g}, not 
the covariance matrix itself, that is then passed to the other 
{cmd:guttmanl}*{cmd:()} functions.

{pstd}
Coefficients are obtained from {cmd:guttmanl()} or, one at a time, 
by calling the six {cmd:guttmanl_get_l{it:#}()} functions.

{pstd}
There are different ways to obtain an estimate for the split-half 
reliability (lambda 4). As noted by Guttman (1945), any split will 
qualify as a lower bound. Instead of using one split, 
{cmd:guttmanl_get_l4()} considers all ((2^{it:n})/2 - 1) possible 
splits to maximize lambda 4. This is computationally intensive and 
might not be feasible for large {it:n}. The split-halves may be 
specified manually with {cmd:guttmanl_set_l4_t()}. The split 
corresponding to a previously obtained lambda 4 is returned by 
{cmd:guttmanl_get_l4_which_t()}.

{pstd}
{cmd:guttmanl_get_l4_q()} implements the method proposed by Hunt 
and Bentler (2015) to estimate the split-half reliability. The 
authors suggest to use a random series of locally optimal lambda 
4 coefficients and then draw quantiles of interest from the 
resulting empirical distribution. The process is based on {it:reps} 
random splits, where {it:reps} defaults to 1,000 and may be changed 
by {cmd:guttmanl_set_l4_optimize()}. If no quantiles are specified, 
{it:q} defaults to (0.05, 0.5, 0.95). The minimum and maximum 
lambda 4 may be obtained as {it:q}=0 and {it:q}=1, respectively 
and {it:q}=. (i.e. scalar missing) returns the entire set of 
lambda 4 coefficients. The third argument is best not specified, 
but allows a non-random {it:T} to be locally optimized if set to 0.

{pstd}
{cmd:guttmanl_get_l4_which_q()} returns the quantiles 
corresponding to a previously obtained lambda 4.

{pstd}
Note that {cmd:guttmanl_set_l4_t(}{it:g}{cmd:, J(0, 0, 1))} 
resets a previously set {it:T} so that {cmd:guttmanl_get_l4()} 
defaults to using all possible splits. This might be desired 
sometimes. Similarly, setting {it:reps} to 0 causes 
{cmd:guttmanl_get_l4_q()} to obtain quantiles from splits 
indicated by {it:T}.


{pstd}
{cmd:guttmanl_data()} calculates reliability coefficients 
from raw data rather than from a covariance matrix.


{title:Conformability}

	{cmd:guttmanl_setup(}{it:C} [{cmd:,} {it:tbl}]{cmd:)}
		     {it:C}: {it:n x n}
		   {it:tbl}: 1 {it:x} 1
		{it:result}: {it:transmorphic}

	{cmd:guttmanl(}{it:g}{cmd:)}
		     {it:g}: {it:transmorphic}
		{it:result}: 6 {it:x} 1
		
	{cmd:guttmanl_get_l{it:#}(}{it:g}{cmd:)}
		     {it:g}: {it:transmorphic}
		{it:result}: 1 {it:x} 1
		
	{cmd:guttmanl_get_l4_q(}{it:g}[{cmd:,} {it:q}{cmd:,} {it:newt}]{cmd:)}
		     {it:g}: {it:transmorphic}
		     {it:q}: 1 {it:x d}
		  {it:newt}: 1 {it:x} 1
		{it:result}: {it:d x} 1
		
	{cmd:guttmanl_get_l4_which_t(}{it:g} [{cmd:,} {it:L4}]{cmd:)}
		     {it:g}: {it:transmorphic}
		    {it:L4}: {it:r x} 1
		{it:result}: {it:n x r}
		
	{cmd:guttmanl_get_l4_which_q(}{it:g} [{cmd:,} {it:l4}]{cmd:)}
		     {it:g}: {it:transmorphic}
		    {it:l4}: 1 {it:x} 1
		{it:result}: 1 {it:x p}
		
	{cmd:guttmanl_set_l4_t(}{it:g} [{cmd:,} {it:T}]{cmd:)}
		     {it:g}: {it:transmorphic}
		     {it:T}: {it:n x m}

	{cmd:guttmanl_set_l4_optimize(}{it:g} [{cmd:,} {it:reps}]{cmd:)}
		     {it:g}: {it:transmorphic}
		  {it:reps}: 1 {it:x} 1
			 
	{cmd:guttmanl_data(}{it:X}{cmd:)}
		     {it:X}: {it:r x c}
		{it:result}: 6 {it:x} 1
		
		
{title:Diagnostics}

{pstd}
{cmd:guttmanl_setup()} aborts with error if {it:C} is not 
square, symmetric and positive definite, contains missing 
values or any of {cmd:diagonal(}{it:C}{cmd:)}<=0. It also 
aborts with error if {it:C} is 1 {it:x} 1.

{pstd}
{cmd:guttmanl_get_l{it:#}()} functions return 
missing if the result is <=0.

{pstd}
{cmd:guttmanl_get_l4_q()} aborts with error if 
{it:q}<0 or {it:q}>1.

{pstd}
{cmd:guttmanl_get_l4_which_t()} returns 
{cmd:J(0, 0, .)} if lambda 4 has not been 
obtained by {cmd:guttmanl_get_l4}*{cmd:()}. It 
returns {cmd:J(}{it:n}{cmd:, 1, .)} for any 
{it:L4} not previously obtained.

{pstd}
{cmd:guttmanl_get_l4_which_q()} returns 
{cmd:J(1, 0, .)} if lambda 4 has not been 
obtained by {cmd:guttmanl_get_l4_q()}. It 
returns missing if all quantiles have been 
previously obtained or {it:l4} was not 
previously obtained.

{pstd}
{cmd:guttmanl_set_l4_t()} aborts with error if 
{cmd:rows(}{it:T}{cmd:)}!={cmd:rows(}{it:C}{cmd:)}.  

{pstd}
{cmd:guttmanl_set_l4_optimize()} aborts with 
error if {it:reps}<0.

{pstd}
{cmd:guttmanl()} is implemented in terms of 
{cmd:guttmanl_get_l{it:#}()}.

{pstd}
{cmd:guttmanl_data()} is implemented in terms 
of {cmd:guttmanl()}.


{title:Source code}

{pstd}
Available on request.
{p_end}


{title:References}

{pstd}
Benton, T. (2015). An empirical assessment of Guttman's 
Lambda 4 reliability coefficient. In: Millsap, R. E., 
Bolt, D. M., van der Ark, L.A., Wang, W-C. (Eds.)
{it:Quantitative Psychology Research. The 78th Annual Meeting of the Psychometric}
{it:Society}. Springer: Cham Heidelberg New York Dordrecht London. pp.301–310.

{pstd}
Guttman, L. (1945). A BASIS FOR ANALYZING TEST-RETEST 
RELIABILITY. {it:Psychometrika}, 10(4), 255-282.

{pstd}
Hunt, T. (2013). Lambda4: Collection of Internal Consistency 
Reliability Coefficients. R package version 3.0. 
http://CRAN.R-project.org/package=Lambda4

{pstd}
Hunt, T.D., Bentler, P.M. (2015). Quantile Lower Bounds to 
Population Reliability Based on Locally Optimal Splits
Reliability Coefficients. {it:Psychometrika}, 80(1), 182-195.


{title:Acknowledgments}

{pstd}
The code used to find lambda 4 by considering all possible 
splits borrows from the R package Lambda4 (Hunt, 2013) and 
code provided by Benton (2015).

{pstd}
Some of the concepts in the code are borrowed from Joseph Coveney's 
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1321890-guttman-s-lambda2-for-estimating-reliability-in-stata?p=1322050#post1322050":{bf:glambda2}}
(posted on Statalist).


{title:Author}

{pstd}
Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb mata}
{p_end}
