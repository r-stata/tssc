{smcl}
{* 24jan2011}{...}
{hline}
help for {hi:shufflevar}
{hline}

{title:Randomly shuffle variables} 

{p 8 17 2} 
{cmd:shufflevar} {it:varlist}[, {cmdab: Joint DROPold cluster}({it:varname})]


{title:Description} 

{p 4 4 2} 
{cmd:shufflevar} takes {it:varlist} and either jointly or for each variable
shuffles {it:varlist} relative to the rest of the dataset. This means any 
association between {it:varlist} and the rest of the dataset will be random. 
Much like {help bootstrap} or the Quadratic Assignment Procedure (QAP), one 
can build a distribution of results out of randomness to serve as a baseline 
against which to compare empirical results, especially for overall model-fit 
or clustering measures. 

{title:Remarks} 

{p 4 4 2} 
The program is intended for situations where it is hard to model error 
formally, either because the parameter is exotic or because the application 
violates the parameter's assumptions. For instance, the algorithm has been 
used by Fernandez et. al. and Zuckerman to interpret network data, the author 
wrote this implementation for use in interpreting {help st} frailty models 
with widely varying cluster sizes, and others have suggested using the metric 
for adjacency matrices in spatial analysis.

{p 4 4 2}
Much like {help bsample}, the {cmd:shufflevar} command is only really useful 
when worked into a {help forvalues} loop or {help program} that records the
results of each iteration using {help postfile}. See the example code below to 
see how to construct the loop.

{p 4 4 2}
To avoid confusion with the actual data, the shuffled variables are renamed
{it:varname}_shuffled. 

{p 4 4 2}
This command is an implementation of an algorithm used in two papers that used 
it to measure network issues:

{p 4 4 2}
Fernandez, Roberto M., Emilio J. Castilla, and Paul Moore. 2000. "Social
Capital at Work: Networks and Employment at a Phone Center." {it:American Journal of Sociology} 105:1288-1356.

{p 4 4 2}
Zuckerman, Ezra W. 2005. "Typecasting and Generalism in Firm and Market: Career-Based Career Concentration in the Feature Film Industry, 1935-1995." {it:Research in the Sociology of Organizations} 23:173-216.

{title:Options} 
 
{p 4 8 2}
{cmd:joint} specifies that {it:varlist} will be keep their actual relations to 
one another even as they are shuffled relative to the rest of the variables.
If {cmd:joint} is omitted, each variable in the {it:varlist} will be 
shuffled separately.

{p 4 8 2}
{cmd:dropold} specifies that the original sort order versions of {it:varlist}
will be dropped.

{p 4 8 2}
{cmd:cluster}({it:varname}) specifies that shuffling will occur by {it:varname}.

{title:Examples}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. regress price weight}{p_end}
{p 4 8 2}{cmd:. local obs_r2=`e(r2)'}{p_end}
{p 4 8 2}{cmd:. tempname memhold}{p_end}
{p 4 8 2}{cmd:. tempfile results}{p_end}
{p 4 8 2}{cmd:. postfile `memhold' r2 using "`results'"}{p_end}
{p 4 8 2}{cmd:. forvalues i=1/100 {c -(}}{p_end}
{p 4 8 2}{cmd:. 	shufflevar weight, cluster(foreign)}{p_end}
{p 4 8 2}{cmd:. 	quietly regress price weight_shuffled}{p_end}
{p 4 8 2}{cmd:. 	post `memhold' (`e(r2)')}{p_end}
{p 4 8 2}{cmd:. }}{p_end}
{p 4 8 2}{cmd:. postclose `memhold'}{p_end}
{p 4 8 2}{cmd:. use "`results'", clear}{p_end}
{p 4 8 2}{cmd:. sum r2}{p_end}
{p 4 8 2}{cmd:. disp "The observed R^2 of " `obs_r2' " is " (`obs_r2'-`r(mean)')/`r(sd)' " sigmas out on the" _newline "distribution of shuffled R^2s."}{p_end}


{title:Author}

{p 4 4 2}Gabriel Rossman, UCLA{break} 
rossman@soc.ucla.edu

{title:Also see}

{p 4 13 2}On-line:  
help for {help bsample}, 
help for {help forvalues},
help for {help postfile},
help for {help program},
help for {help permute}

