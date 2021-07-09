{smcl}
{* 27oct2011}{...}
{hline}
help for {hi:ipfweight}
{hline}

{title:IPF-Algorithm to create adjustment survey weights}

{p 4 14 2}{cmd:ipfweight} {it:varlist} [{cmd:if} {it:exp}]{cmd:, }
{cmdab:gen:erate}{cmd:(}{it:newvar}{cmd:)}
{cmdab:val:ues}{cmd:(}{it:numlist}{cmd:)} 
{cmdab:maxit:er}{cmd:(}{it:#}{cmd:)}
[{cmdab:st:artwgt}{cmd:(}{it:varname}{cmd:)} 
{cmdab:tol:erance}{cmd:(}{it:#}{cmd:)} 
{cmdab:up:threshold}{cmd:(}{it:#}{cmd:)}
{cmdab:lo:threshold}{cmd:(}{it:#}{cmd:)}
{cmdab:mis:rep}]


{title:Description}

{p 4 8 2} {cmd:ipfweight} is based on the iterative proportional fitting algorithm 
(also known as raking) first proposed by Deming and Stephan (1940). Like Nick 
Winter's {help survwgt:survwgt rake} it performs a stepwise adjustment of survey 
sampling weights to achieve known population margins (e.g. sex, education, age etc.) 
but offers some additional features. The adjustment process is repeated until the 
difference between the weighted margins of the variables listed in {it:varlist} 
and the known population margins specified in {cmd:values()} is smaller than a 
tolerance value specified in {cmd:tolerance()} or the maximum number of iterations 
specified in {cmd:maxiter()} is obtained.


{title:Options}

{p 4 4 2} {cmdab:gen:erate(}{it:newvar}{cmd:)} creates a new variable containing
the final weighting factors. It is required.

{p 4 8 2} {cmdab:val:ues(}{it:numlist}{cmd:)} contains the known population 
margins. The order of the specified population margins in {it:numlist} has to 
correspond to the values of each variable in {it:varlist}.

{p 4 8 2} {cmdab:maxit:er(}{it:#}{cmd:)} defines the maximum number of 
iterations. # has to be larger than 1.

{p 4 8 2} {cmdab:st:artwgt(}{it:varname}{cmd:)} uses the values of {it:varname} 
as starting weights. For example, a variable containing design weights that 
transform a sample of households into a sample of individuals can be used here. If 
{cmd:startwgt()} is not specified, each case gets a starting weight of 1.

{p 4 8 2} {cmdab:tol:erance(}{it:#}{cmd:)} specifies the maximum deviation 
between the weighted margins of the variables listed in {it:varlist} and the 
known population margins specified in {cmd:values()} that is tolerated. If 
{cmd:tolerance()} is not specified, the iterative process is repeated # times as 
specified in {cmd:maxiter(}{it:#}{cmd:)}.

{p 4 8 2} {cmdab:up:threshold(}{it:#}{cmd:)} specifies an upper threshold for the final 
weighting factors. If a weighting factor exceeds this threshold, it is trimmed to 
# before the iterative process is continued. An upper threshold of about 5 is 
suggested (DeBell et al. 2009: 31).

{p 4 8 2} {cmdab:lo:threshold(}{it:#}{cmd:)} specifies a lower threshold for the final 
weighting factors. If a weighting factor falls below this threshold, it is trimmed 
to # before the iterative process is continued.

{p 4 8 2} {cmdab:mis:rep} replaces missing values in {it:varlist} with a weighting 
factor of 1 before the iteration process is continued. If {cmd:misrep} is not 
specified, weighting factors for all cases with at least one missing value in 
{it:varlist} cannot be computed. However, a more promising solution is to 
{help mi:multiple impute} missing values before using {cmd:ipfweight}.


{title:Examples}

{p 4 8 2} {inp:. ipfweight sex educ, gen(wgt) val(48.3 51.7 43.7 30.7 25.6) maxit(10)}

{p 4 8 2} {inp:. ipfweight sex educ region, gen(wgt) val(48.3 51.7 43.7 30.7 25.6 78.0 22.0) maxit(25) st(designwgt) tol(.1) up(5) lo(.2) mis}


{title:References}

{p 4 8 2} DeBell, Matthew/Jon A. Krosnick/Arthur Lupia/Caroline Roberts. 2009. 
User’s Guide to the Advance Release of the 2008-2009 ANES Panel Study. Palo Alto, 
CA and Ann Arbor, MI: Stanford University and University of Michigan.

{p 4 8 2} Deming, W. Edwards/Frederick F. Stephan. 1940. On a Least Squares 
Adjustment of a Sampled Frequency Table When the Expected Marginal Totals 
Are Known, in: The Annals of Mathematical Statistics 11 (4): 427-444.


{title:Author}

{p 4 8 2} Michael Bergmann, University of Mannheim, michael.bergmann@uni-mannheim.de


{title:Also see}

Manual:  {hi:[R] weight}

On-line:  help for {help weight}; {help survwgt}

