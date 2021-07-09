{smcl}
{* *! version 1.0.1  May2013}{...}
{hline}
help for {hi:matamatrix} -- Mata matrix operations for Stata matrices {right:(Version 1.0.0)}
{hline}

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:matamatrix}
[{it:mname} = ] {it:matrix_expression}

{marker description}{...}
{title:Description}

{p 4 4 2}
{cmd:matamatrix} allows {helpb mata} matrix operators and functions to be used on Stata matrices. 

{marker examples}{...}
{title:Examples}

{p 4 4 2}{stata matamatrix A = (2, 3 \ 4, 5)}{break}
		{stata "matamatrix B = exp(A[1,]) :- 10"}{break}
		{stata matamatrix B}{break}
		{stata "matamatrix exp(A[1,]) :- 10"}{p_end}

{p 4 8 2}Results saved in {cmd:r()} or {cmd:e()} can be used directly. 

{p 4 4 2}{stata "sysuse auto, clear"}{break}
		{stata logit foreign price}{break}
		{stata matamatrix invlogit((10000, 1) * e(b)')} // Estimating the probability of a car being foreign given a price of $10,000{break}
		{stata "matamatrix invlogit((10000,1) * e(b)' :+ (-1,1) :* invnormal(0.975) :* sqrt((10000, 1) * e(V) * (10000,1)'))"} // Deriving 95% confidence intervals

{p 4 8 2}Subscripting can be applied directly to {cmd:r()} or {cmd:e()} matrices 

{p 4 4 2}{stata matamatrix e(V)[1,1]}{break}

{marker note}{...}
{title:Note}
{p 4 4 2}- In theory, all functions in mata that return real matrices can be used, including user-defined ones. mata functions 
			that modify input matrices and output {it:void} matrices such as {cmd:_invsym()} are not supported. All variables in {cmd:matamatrix} must be Stata matrices. 
			{helpb scalar}s and mata variables cannot be included.{break}
		- If speed is an issue, then {cmd:matamatrix} may not be the best idea.{break} 
		- {cmd:matamatrix} has not been tested on all mata commands. Please let me know if you encounter any bugs while using it. 


{title:Author}

{p 4 4 2}Timothy Mak{break}
		School of Public Health, University of Hong Kong{break}
		tshmak@hku.hk{break}
		May 2013{p_end}
