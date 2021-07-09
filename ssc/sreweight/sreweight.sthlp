{smcl}
{* Sept2012/}
{cmd:help sreweight }{right:}
{hline}

{title:Title}


{p2colset 5 17 19 2}{...}
{p2col :{hi:sreweight} {hline 2}}Reweights survey variables using external totals{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:sreweight}
{varlist} {ifin} {cmd:,}
{cmdab:sw:eight(}{varname}{cmd:)}
{cmdab:nw:eight}({newvar}) 
{cmdab:tot:al}({it:matrix})
{cmdab:df:unction}({it:name}) 
[{cmdab:sv:alues}({it:matrix}) {cmdab:tol:erance(}#{cmd:)} {cmdab:niter(}#{cmd:)} {cmdab:nt:ries(}#{cmd:)} {cmdab:upb:ound(}#{cmd:)} {cmdab:lowb:ound(}#{cmd:)} {cmdab:rb:ounds(}#{cmd:)} {cmdab:rlowb:ounds(}numlist{cmd:)} 
{cmdab:rupb:ounds(}numlist{cmd:)}]

{title:Description}

{pstd}
{cmd:sreweight} calibrates survey data to external totals. The methodology closely follows Deville and Sarndal (1992) and the recursive algorithm that implements the calibration is from Creedy (2003).

{title:Options for sreweight}

{phang}
{opth sweight(varname)} is required and specifies a numeric variable for the original survey weights.

{phang}
{opth nweight(string)} is required and defines the name of the new variable containing the calibrated weights.

{phang}
{opth total(matrix)} is required and contains a Stata 1xK matrix with the user-provided totals. The arguments must be inserted in the same order as the K calibrating variables in {varlist}.

{phang}
{opth dfunction(string)} is required and specifies the distance function to be used when computing the new weights.
The allowed functions are the chi-squared (type "{opt chi2}"), the modified chi-squared (type "{opt mchi2}"), the Deville and Sarndal's  function (type "{opt ds}") and three more, which we define as A (type "{opt a}"), B (type "{opt b}") 
and C (type "{opt c}"). 
See Pacifico (2010) for details.

{phang}
{opth svalues(matrix)} specifies user-provided starting values. Starting values must be put in a Stata 1xK matrix following the same order as the variables in {varlist}. 
The default is a vector with the Lagrange multipliers obtained from the chi-squared distance function.

{phang}
{opth tolerance(#)} specifies the tolerance level to asses convergence. The default is {opt tolerance(0.000001)}. {opt sreweight} employs a double criterion to asses convergence. 
The first is that the difference between the estimated and the external totals must be lower than the tolerance level. 
The second criterion is that - from one iteration to the other - the variation of the value of the distance function must be lower than the tolerance level for each observation in the estimation sample.

{phang}
{opth ntier(#)} specifies the number of maximum iterations. The default is {opt niter(50)}.

{phang}
{opth ntries(#)} specifies the maximum number of “tries” when the algorithm doeas not achieve convergence within the maximum number of iterations. 
This option can be useful when the external totals are significantly different from the survey totals. 
In such situations the algorithm automatically restarts with new random starting values up to {opt #} times. The default is {opt ntries(0)}.

{phang}
{opth upbound(#)} specifies the upper-bound of the ratio between the new and the original weights when using either the Modified chi-squared or Deville and Sarndal's distance function. 
The default is {cmd:upbound(4)}. Note that this value must be bigger than 1. 

{phang}
{opth lowbound(#)} specifies the lower-bound of the ratio between the new and the original weightwhen using either the Modified chi-squared or Deville and Sarndal's distance function.
The default is {cmd:lowbound(0.2)}. Note that this value must be between 0 and 1. 

{phang}
{opth rbounds(#)} is a relevant option only for the Modified chi-squared and the Deville and Sarndal's distance functions when the options {opt ntries(#)} is effective.
In this case, if the recursion does not achieve convergence the routine starts again with both a new set of starting values and new random bounds. 
The allowed values for this option are 0 (no random bounds) and 1 (allow for random bounds). The default is 0.

{phang}
{opth rlowbound(numlist)} and {opth rupbound(numlist)} are relevant options only for the Modified chi-squared and the Deville and Sarndal's distance functions when the options {opt ntries(#)} and {opt rbounds(#)} are both effective. 
In this case, the two values in {opth rlowbound(numlist)} (or  {opth rupbound(numlist)}) define the support of the uniform distribution from which the new lower (or upper) bound is drawn.
As an example, if the user sets {opth rlowbound(0.2 0.8)} the new lower bound will be drawn from a uniform distribution with support 0.2-0.8. 
When the option {opt rbounds(#)} is effective the default values for these options are {opth rlowbound(0.1 0.7)} and {opth rupbound(1.5 6)}. 

{title:Example}

{pstd}
Consider the following example from Creedy(2003). 
{cmd:id} is the identification number of each unit included in the survey, {cmd:x1}, {cmd:x2}, {cmd:x3} and {cmd:x4} are variables included in the survey, {cmd:weight} is the vector of original survey weights:

{cmd}
. use http://fmwww.bc.edu/RePEc/bocode/r/sreweight, clear
. list

id	x1	x2	x3	x4	weight
1	1	1	0	0	3
2	0	1	0	0	3
3	1	0	2	0	5
4	0	0	6	1	4
5	1	0	4	1	2
6	1	1	0	0	5
7	1	0	5	0	5
8	0	0	6	1	4
9	0	1	0	0	3
10	0	0	3	1	3
11	1	0	2	0	5
12	1	1	0	1	4
13	1	0	3	1	4
14	1	0	4	0	3
15	0	0	5	0	5
16	0	1	0	1	3
17	1	0	2	1	4
18	0	0	6	0	5
19	1	0	4	1	4
20	0	1	0	0	3
{txt}

The survey weights produce the following aggregate totals: 

{cmd}
1.	tabstat x1 x2 x3 x4 [w=weight], s(su)
2.	stats	x1	x2	x3	x4
3.	sum	44	24	213	32
{txt}

Now, let us assume that external information on these variables are available, and that the real population totals are:

{cmd}
	stats	x1	x2	x3	x4
	   	50	20	230	35
{txt}

In this case, {cmd:sreweight} can be used to calibrate the original survey weights so that the new estimated totals will be equal to the population totals:

{cmd}
matrix t=(50 \ 20 \ 230 \ 35)
sreweight x1 x2 x3 x4, sw(weight) nw(wchi2) tot(t) df(chi2)
sreweight x1 x2 x3 x4, sw(weight) nw(wa) tot(t) df(a)
sreweight x1 x2 x3 x4, sw(weight) nw(wb) tot(t) df(b)
sreweight x1 x2 x3 x4, sw(weight) nw(wc) tot(t) df(c)
sreweight x1 x2 x3 x4, sw(weight) nw(wds) tot(t) df(ds)

list w*
weight	wchi2	wa	wb	wc	wds
3	2.753   2.674   2.654   2.697   2.706 
3	2.109   2.228   2.260   2.193   2.178 
5	5.945   5.998   6.012   5.982   5.976 
4	4.005   3.944   3.926   3.963   3.974 
2	2.484   2.514   2.521   2.505   2.501 
5	4.589   4.456   4.423   4.495   4.510 
5	5.752   5.729   5.717   5.739   5.747 
4	4.005   3.944   3.926   3.963   3.974 
3	2.109   2.228   2.260   2.193   2.178 
3	3.120   3.086   3.074   3.098   3.106 
5	5.945   5.998   6.012   5.982   5.976 
4	3.985   3.814   3.762   3.870   3.897 
4	5.019   5.108   5.136   5.080   5.065 
3	3.490   3.490   3.487   3.491   3.494 
5	4.678   4.665   4.666   4.667   4.665 
3	2.345   2.370   2.380   2.360   2.355 
4	5.070   5.191   5.232   5.150   5.128 
5	4.614   4.603   4.604   4.603   4.600 
4	4.967   5.028   5.043   5.010   5.001 
3	2.109   2.228   2.260   2.193   2.178{txt}

Which gives the same values as in Creedy (2003).


{title:Reference}

{phang} Creedy, J., 2003. {it: Survey Reweighting for Tax Microsimulation Modelling}, Treasury Working Paper Series 03/17, New Zealand Treasury.

{phang} Deville, J.C. and Sarndal, C.E., 1992. {it: Calibration estimators in survey sampling}, Journal of the American Statistical Association 87 (418) 376-382, American Statistical Association.

{phang} Pacifico 2010. {it: reweight: A Stata module to reweight survey data to external totals}, CAPPaper N.79.


{title:Author}

{phang}This command was written by Daniele Pacifico (daniele.pacifico@tesoro), Italian Department of the Treasury. Comments and suggestions are welcome. {p_end}


{title:Also see}

{psee}
Manual:  {bf:[R] sreweight}

{psee}
Online:  {manhelp sreweight R}{p_end}


