{smcl}
{cmd:help rdesigni}
{hline}

{title:Title}

{p 5 8 2}
{cmd:rdesigni} {hline 2} Design analysis


{title:Syntax}

{p 8 12 2}
{cmd:rdesigni} 
{it:D} 
{it:se} 
[ {cmd:,} {it:options} ]


{p 4 8 2}
where {it:D} is the true effect size and {it:se} is the standard error of 
the estimate, and both, {it:D} and {it:se}, may be specified as {it:#} or 
{cmd:(}{it:{help numlist}}{cmd:)}. 


{synoptset 20 tabbed}{...}
{marker opts}{...}
{synopthdr}
{synoptline}
{synopt:{opt a:lpha(numlist)}}significance level; default is 
1-{ccl level}/100{p_end}
{synopt:{opt df(numlist)}}degrees of freedom for t distribution; 
default is {cmd:df(.)}, resulting in the standard normal 
distribution{p_end}
{synopt:{opt r:eps(#)}}number of random draws; default is 
{cmd:reps(10000)}{p_end}
{synopt:{opt par:allel}}process {it:numlists} parallel; default 
is to process all possible combinations{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:rdesigni} implements the design analysis approach discussed in Gelman 
and Carlin (2014). The authors suggest simulating replicated results given 
a true effect size and the parameters of a specific study. The command 
estimates power, Type S (sign) error rate and Type M (magnitude) error 
(exaggeration ratio).

{pstd}
By default, the type M error is found by a series of random draws; to be 
able to reproduce results, set the random-number seed 
(see {helpb set_seed:set seed}).

{pstd}
The {cmd:r} in {cmd:rdesigni} stands for replication, research, 
retro(spective), or R, the software used by the original authors. 

{pstd}
Also see {help immed} for a general description of 
immediate commands.


{title:Options}

{phang}
{opt alpha(numlist)} specifies the significance level used in the study. The 
default is set to 1-{ccl level}/100, according to {cmd:c(level)}.

{phang}
{opt df(numlist)} specifies the degrees of freedom used in the study. The 
default is {cmd:df(.)} and means that the standard normal distribution is 
used.

{phang}
{opt reps(#)} specifies the number of random draws from the distribution  to
simulate replicated results. Default is {cmd:reps(10000)}. When {cmd:reps(0)} 
is specified, a closed-form expression for the Type M error, suggested by 
Lu, Qiu, and Deng (2019), is used.

{phang}
{opt parallel} processes the specified {it:numlist}s in parallel. Default is 
to process all possible combinations of the numbers in {it:numlist}s. The last 
values of shorter {it:numlist}s are used repeatedly.


{title:Examples}

{phang2}{cmd:. rdesigni 0.1 3.28}{p_end}
{phang2}{cmd:. rdesigni 2 8.2}{p_end}
{phang2}{cmd:. rdesigni (0.1 2) (3.28 8.2) , parallel}{p_end}


{title:Saved results}

{pstd}
{cmd:rdesigni} saves the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(reps)}}number of replications{p_end}
{synopt:{cmd:r(alpha)}}significance level{p_end}
{synopt:{cmd:r(df)}}degrees of freedom{p_end}
{synopt:{cmd:r(se)}}standard error of estimate{p_end}
{synopt:{cmd:r(D)}}true effect size{p_end}
{synopt:{cmd:r(crit)}}critical value{p_end}
{synopt:{cmd:r(pr_0)}}probability wrong sign{p_end}
{synopt:{cmd:r(pr_1)}}probability correct sign{p_end}
{synopt:{cmd:r(power)}}power{p_end}
{synopt:{cmd:r(typeS)}}type S error{p_end}
{synopt:{cmd:r(typeM)}}type M error{p_end}

{pstd}
Macros{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(cmd)}}{cmd:rdesigni}{p_end}
{synopt:{cmd:r(seed)}}random-number seed{p_end}

{pstd}
Matrices{p_end}
{synoptset 16 tabbed}{...}
{synopt:{cmd:r(table)}}information from the coefficient table{p_end}


{title:Acknowledgments}

{pstd}
Ariel Linden's {cmd:retrodesign} stimulated the implementation of 
the closed-form expression for the Type M error and helped identify 
a bug that produced wrong results for negative effect sizes.


{title:References}

{pstd}
Gelman, Andrew, Carlin, John (2014). Beyond Power Calculations: Assessing 
Type S (Sign) and Type M (Magnitude) 
Errors. {it:Perspectives on Psychological Science}, 9, 641-651.

{pstd}
Lu, Jiannan, Qiu, Yixuan, and Deng, Alex (2019). A note on 
Type S/M errors in hypothesis 
testing. {it:British Journal of Mathematical and Statistical Psychology}, 
72, 1-17.


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb power}
{p_end}

{psee}
if installed: {help retrodesign}
{p_end}
