{smcl}
{* version 1.1.0}{...}
{cmd:help pwmc}
{hline}

{title:Title}

{p 5}
{cmd:pwmc} {hline 2} Pairwise multiple comparisons 
(unequal variances)


{title:Syntax}

{p 5}
Syntax for pwmc

{p 8}
{cmd:pwmc} {varname} {ifin} {cmd:,} {opt over(varname)} 
[{it:options}]


{p 5}
Immediate command

{p 8 12}
{cmd:pwmci} {it:stats{hi:1}} {it:stats{hi:2}} {it:stats{hi:3}}
[ {it:... stats{hi:k}} ] [ {cmd:,} {it:options} ]


{p 5} where {it:stats} is

{p 8}
[ {cmd:(} ] {it:#obs} {it:#mean} {it:#sd} [ {cmd: )} ]


{title:Description}

{pstd}
{cmd:pwmc} performs pairwise comparisons of means. It computes 
pairwise differences of the means of {varname} over the levels 
of {opt over(varname)}. Confidence intervals are derived using 
procedures allowing for unequal variances across groups. 

{pstd}
{cmd:pwmc} implements Dunnett's {cmd:C}, {cmd:GH} and {cmd:T2} 
procedures, as proposed by Dunnett (1980), Games and Howell (1976) 
and Tamhane (1979).

{pstd}
{cmd:pwmci} is the immediate form of {cmd:pwmc}. See {help immed}.


{title:Options}

{phang}
{opt over(varname)} is required and specifies that means are 
computed for each level of {it:varname}.

{phang}
{opt proc:edure(proc)} specifies the procedure to be used to derive 
confidence intervals. {it:proc} may be any combination of {cmd:C}, 
{cmd:GH} and {cmd:T2} and case does not matter. Default is to report 
confidence intervals using each of the procedures.

{phang}
{opt l:evel(#)} specifies the confidence level, as a percentage, for 
confindence intervals. The default is {cmd:level({hi:{ccl level}})}. 
See {helpb set level}.

{phang}
{opt pv:alues} displays adjusted p-values. The Games and Howell 
adjusted p-value is given by

{p 16}
p_adj = 1 - q_(k, nuhat, abs(t)*sqrt(2))

{p 8 8}
where q is the 
{help tukeyprob():cumulative Studentized range distribution} with k 
means and nuhat degrees of freedem, using Satterthwaite’s (1946) 
approximate formula.

{p 8}
The adjusted p-value for Tamhane's T2 is

{p 16}
p_adj = 1 - (1 - p)^(k*(k - 1)/2)

{p 8 8}
where p is the p-value from a t-test based on Satterthwaite’s (1946) 
approximate formula for the degrees of freedom.

{p 8} There is no adjusted p-value for Dunnet's C.

{phang}
{opt varl:abel} displays variable labels instead of variable names.

{phang}
{opt vall:abel} displays value labels instead of numeric codes.

{phang}
{cmd:cformat(}{it:{help %fmt}}{cmd:)} specifies how to format means, 
standard errors, and confidence limits.

{phang}
{cmd:pformat(}{it:{help %fmt}}{cmd:)} specifies how to format 
adjusted p-values.

{phang}
{cmd:sformat(}{it:{help %fmt}}{cmd:)} specifies how to format 
test statistics.

{phang}
{opt notab:le} does report the results, but only stores them in 
{cmd:r()}.


{title:Example}

{phang2}{cmd:. pwmc wage , over(race)}{p_end}

{phang2}
{cmd:. pwmci (1637 8.08 5.96) (583 6.84 5.08) (26 8.55 5.21)}
{p_end}


{title:Saved results}

{pstd}
{cmd:pwmc} saves the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(k)}}number of levels of {opt over(varname)}{p_end}
{synopt:{cmd:r(ks)}}number of differences{p_end}
{synopt:{cmd:r(level)}}confidence level{p_end}

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(cmd)}}{cmd:pwmc}{p_end}
{synopt:{cmd:r(depvar)}}{it:varname} from which means are 
computed{p_end}
{synopt:{cmd:r(over)}}{it:varname} in {opt over(varname)}{p_end}

{pstd}
Matrices{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(diff)}}differences of means{p_end}
{synopt:{cmd:r(Var)}}variances of differences{p_end}
{synopt:{cmd:r(nuhat)}}degrees of freedom{p_end}
{synopt:{cmd:r(ci)}}confidence intervals{p_end}
{synopt:{cmd:r(t)}}test statistics{p_end}
{synopt:{cmd:r(p_adj)}}adjusted p-values{p_end}
{synopt:{cmd:r(A)}}critical values (cf. Dunnett, 1980){p_end}


{title:References}

{pstd}
Dunnett, Charles W. (1980). Pairwise Multiple Comparisons in the 
Unequal Variance Case, 
{it:Journal of the American Statistical Association}, 75(372), 796-800.

{pstd}
Games, Paul A., Howell, John F. (1976). Pairwise Multiple Comparison 
Procedures with Unequal N's and/or Variances: A Monte Carlo study, 
{it:Journal of Educational Statistics}, 1(2), 113-125.

{pstd}
Tamhane, Ajit C. (1979). A Comparison of Procedures for Multiple 
Comparisons of Means with Unequal Variances, 
{it:Journal of the American Statistical Association}, 74(366), 471-480.


{title:Acknowledgments}

{pstd}
Matthew K. Lau's 'DTK' package for R was helpful developing {cmd:pwmc}.


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb pwmean}, {helpb pwcompare}, {helpb oneway}
{p_end}

{psee}
if installed: {help dunnett}, {help prcomp}
{p_end}
