{smcl}
{* 1.0.3 MLB 14May2013}{...}
{* 1.0.2 MLB 27Jan2013}{...}
help for {hi:als_norm}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi: asl_norm} {hline 2}}Bootstrap normality tests.{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:asl_norm} {varname} {ifin} 
[
{cmd:,} 
{opt dh:ansen}
{opt hz:irkler}
{opt mku:rtosis}
{opt mskew:ness}
{opt jb:test}
{opt sk:test}
{opt skew:ness}
{opt ku:rtosis}
{opt sw:ilk}
{opt sf:rancia}
{opt all}
{opt fast}
{opt reps(#)}
{opt nodots}
{opt mcci(#)} 
{opt sa:ving(filename [, replace double every(#)])}
]


{title:Description}

{pstd}
{cmd:asl_norm} computes bootstrap estimates of the Achieved Significance Levels (ASL) for a 
number of Gaussianity (normality) tests. The idea behind a boostrap test is to take the logic of 
a p-value literaly: In order to find the probability of observing data with a test statistic at
least as extreme as the one found in the data one can:

{pmore} 1) repeatedly draw a new variable from a Gaussian distribution with the mean and standard
deviation as observed in the data, 

{pmore} 2) compute in each replication the test statistic for that simulated variable, and 

{pmore} 3) compute the ASL as the number of times that that test statistic is as extreme or more than the one
found in the real data plus 1 divided by the number of replications plus 1. 

{pstd}
This ASL can be interpreted as a more robust estimate of the p-value and/or as a simulation check of 
whether the chosen statistic is working well in your sample, i.e. whether the ASL corresponds with 
the asymptotic p-value.

{pstd}
A key aspect of ASLs is that they are computed with aid of a Monte Carlo experiment and are thus
uncertain. If one were to call {cmd: asl_norm} twice (and not set the {help set_seed:seed}), one 
will find slightly different ASLs. {cmd:asl_norm} quantifies this uncertainty by displaying a 
Monte Carlo confidence interval for the ASL. If you were to call {cmd:asl_norm} a 100 times you 
would in 95 of these calls expect to find an ASL within this interval. If you are unhappy with 
the width of this interval, than you can decrease it by specifying more replications in the 
{cmd:reps()}. Typically, I find 19,999 a number that works well for this type of procedure; if 
the "true" p-value is 0.05 than the ASL will on average be computed based on a 999 replications 
where the simulated statistic is larger than the observed statistic.


{title:An aside}

{pstd}
The estimate of the ASL used in this program is discussed in Chapter 4 of 
({help asl_norm##davison_hinkley:Davison and Hinkley 1997}) and deviates slightly from the estimate 
discussed in Chapter 16 of ({help asl_norm##efron_tibshirani:Efron and Tibshirani 1993}) in that the 
latter estimate the ASL using just the proportion of times that that test statistic is more extreme 
than the one found in the real data. With a large number of replications this difference is not going
to matter, but striclty speaking the former is slightly preferable. 

{pstd}
If we find an ASL of {it:a}, than the probability of drawing a dataset with an ASL less than or equal 
to {it:a} if the null hypothesis is true should itself be {it:a}, and this should be true for all 
possible values of {it:a}. So the sampling distribution of the ASL if the null hypothesis is true 
should be a standard uniform distribution. In other words, if the null hypothesis is true all possible 
values of {it:a} should be equally likely.

{pstd}
If we compute our ASL using B replications, than the number of possible values for {it:a} is limited 
to only B+1 values: a value based on 0, 1, 2, ..., or B replications with a test statistic as extreme 
or more than the one found in the real data. Based on the condition discussed above, each of these 
possible values should have a probability of 1/(B+1) if the null hypothesis is true. This means that 
if the null hypothesis is true, the probability of finding 0 replications with a test statistic as 
extreme or more as the one found in the real data is 1/(B+1). Similarly, the probability of finding 1 
or less replications with a test statistic at least as extreme as the one found in the real data is 
2/(B+1). Generally, the probability of finding k or less replications with a test statistic as 
extreme or more as the one found in the real data if the null hypothesis is true is (k+1)/(B+1).


{title:Options}

{dlgtab:Statistics}

{phang}
{opt dh:ansen} specifies that thee Doornik-Hansen statistic as computed by {help mvtest_normality} 
should be used. 

{phang}
{opt hz:irkler} specifies that the Henze-Zirkler statistic as computed by {help mvtest_normality} 
should be used.

{phang}
{opt mku:rtosis} specifies that Mardia's kurtosis test statistic as computed by 
{help mvtest_normality} should be used.

{phang}
{opt mskew:ness} specifies that Mardia's skewness test statistic as computed by 
{help mvtest_normality} should be used.

{phang}
{opt jb:test} specifies that the Jarque-Bera test statistic should be used.

{phang}
{opt sk:test} specifies that the skewness-kurtosis test statistic as computed by {help sktest} 
should be used. The default if N > 5000.

{phang}
{opt skew:ness} specifies that the skewness test statistic as computed by {help sktest} should 
be used.

{phang}
{opt ku:rtosis} specifies that the kurtosis test statistic as computed by {help sktest} should 
be used.

{phang}
{opt sw:ilk} specifies that the Shapiro-Wilk test statistic as computed by {help swilk} should 
be used. Only allowed if 4<=N<=2000. The default if N <= 2000.

{phang}
{opt sf:rancia} specifies that the Shapiro-Francia test statistic as computed by {help sfrancia} 
should be used. Only allowed if 5<=N<=5000. The default if 2000 < N <= 5000.

{phang}
{opt all} specifies that all the above statistics (if allowed) should be used.

{phang}
{opt fast} specifies that all the above statistics (if allowed), except he Henze-Zirkler statistic 
and Mardia's skewness test statistic, which tend to be slow in moderate to large samples.

{dlgtab:Other options}

{phang}
{opt reps(#)} specifies the number of replications used to compute the ASL. The default is {cmd:reps(1000)}.

{phang}
{opt nodots} suppresses display of the replication dots.  By default, one dot character is displayed for
each successful replication.  A red "x" is displayed if there was an error while computing one of the test 
statistics or if one of the test statistics is missing.

{phang}
{opt mcci(#)} specifies the confidence level, as a percentage, for the Monte Carlo confidence interval.  The 
default is {cmd:mcci(95)} or as set by {helpb set level}.

{phang}
{opt saving(filename [, replace double every(#)])} creates a Stata data file containing for each replication
the test statistics. See: {help prefix_saving_option}.


{title:Examples}

{pstd}
In a small sample most tests have at least some degree of trouble. In this case (74 observations) the 
Doornik-Hansen test leads to a p-value that is a bit too large.

{cmd}{...}
    sysuse auto, clear
    asl_norm trunk, dh reps(19999)
{txt}{...}
{p 4 4 2}({stata "asl_norm_ex 1":click to run}){p_end}

{pstd} 
In larger samples the asymptotic p-values tend to be less problematic

{cmd}{...}
    sysuse nlsw88, clear
    gen lnwage = ln(wage)
    asl_norm lnwage if union < ., dh reps(19999)
{txt}{...}
{p 4 4 2}({stata "asl_norm_ex 2":click to run}){p_end}

{pstd}
You can use the {cmd:saving()} option to perform a simulation of how well the tests perform for the number 
of observations in your dataset. This creates a dataset of test statistics on datasets where the null 
hypothesis is true, so the distribution of these statistics should correspond to the theoretical sampling
distribution and the p-values should follow a continuous standard uniform distribution. 

{cmd}{...}
    set seed 12345
    sysuse auto, clear

    tempfile res
    asl_norm trunk, jb sktest reps(1999) saving("`res'", replace)
    use "`res'"

    // check sampling distribution of test statistic
    qenvchi2 sktest, gen(lb ub) df(2) overall reps(5000)
    tempname qplot 
    qplot sktest jbtest lb ub, trscale(invchi2(2,@)) ///
          ms(o o none ..) c(. . l l)  lc(gs10 ..)    ///
          scheme(s2color) ylab(,angle(horizontal))   ///
          legend(order( 1 "sktest"                   ///
                        2 "Jarque-Bera"              ///
                        3 "95% simultaneaous"        ///
                          "Monte Carlo CI"))         ///
          name(`qplot')

    // test sampling distribution of p-values
    gen p_sk = chi2tail(2,sktest)
    label var p_sk "sktest"
    gen p_jb = chi2tail(2,jbtest)
    label var p_jb "Jarque-Bera"
    simpplot p_sk p_jb, overall reps(19999)          ///
             scheme(s2color) ylab(,angle(horizontal))
{txt}{...}
{p 4 4 2}({stata "asl_norm_ex 3":click to run}){p_end}

{pstd}
If you do find a significant difference between the variable and a Gaussian distribution, you will need to 
follow this up with a graphical inspection of that variable in order to determine the source of the problem.
In this case, the problem is in all likelihood that wages were top-coded.

{cmd}{...}
    sysuse nlsw88, clear
    gen lnwage = ln(wage)
    asl_norm lnwage  
    qnorm lnwage 
{txt}{...}
{p 4 4 2}({stata "asl_norm_ex 4":click to run}){p_end}

{pstd}
Better yet, you can combine the testing logic with the graphing logic by adding confidence bands using the
{cmd:qenv} package.

{cmd}{...}
    sysuse nlsw88, clear
    gen lnwage = ln(wage)
    qenvnormal lnwage, gen(lb ub) overall reps(19999)
    sum lnwage
    qplot lnwage lb ub, ms(oh none ..) c(. l l) lc(gs10 ..)       ///
          legend(off) ytitle("ln(wage)") xtitle(Normal quantiles) ///
          trscale(`r(mean)' + `r(sd)' * invnormal(@)) 
{txt}{...}
{p 4 4 2}({stata "asl_norm_ex 5":click to run}){p_end}


{title:Author}

{p 4 4}
Maarten L. Buis{break}
Wissenschaftszentrum Berlin für Sozialforschung, WZB{break}
Research unit Skill Formation and Labor Markets {break}
maarten.buis@wzb.eu
{p_end}


{title:References}

{marker davison_hinkley}{...}
{phang}
A.C. Davison & D.V. Hinkley (1997) 
{it:Bootstrap Methods and their Application}. Cambridge: Cambridge University Press.

{marker efron_tibshirani}{...}
{phang}
B. Efron & R.J. Tibshirani (1993) 
{it:An Introduction to the Bootstrap}. Boca Raton: Chapman & Hall/CRC.


{title:Also see}

{psee}
Online: {helpb qnorm}, {helpb pnorm}, {helpb sktest}, {helpb mvtest normality}, {helpb swilk}

{psee}
If installed: {helpb hangroot}, {helpb qenvnormal}, {helpb qplot}
{p_end}
