{smcl}
{* 1.0.8 MLB 21Okt2013}{...}
{* 1.0.7 MLB 13Jun2013}{...}
help for {hi:oparallel}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi: oparallel} {hline 2}}Post-estimation command for testing the parallel regression assumption.{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:oparallel} {cmd:,} 
[
{opt score}
{opt lr}
{opt wald}
{opt wolfe:gould}
{opt brant}
{opt ic}
{opt asl}
{opt reps(#)}
{opt bs:ample}
{cmd:mcci}[{cmd:(}{it:#}{cmd:)}]
{opt nodots}
{opt sa:ving(filename [, replace double every(#)])}
]


{title:Description}

{pstd}
{cmd:oparallel} is a post-estimation command testing the parallel regression 
assumption in a ordered logit model. By default it performs 5 tests: 

{col 8} a likelihood ratio test,
{col 8} a score test,
{col 8} a Wald test,
{col 8} a Wolfe-Gould test, and
{col 8} a Brant test

{pstd}
These tests compare a ordered logit model with the fully generalized ordered 
logit model, which relaxes the parallel regression assumption on all explanatory 
variables. The former is described in {help ologit:help ologit} and the latter in 
({help oparallel##williams:Williams 2006}). The Wolfe-Gould test is discussed in
({help oparallel##wolfe:Wolfe and Gould 1998}) and the Brant test in 
({help oparallel##brant:Brant 1990}). The Wolfe-Gould and Brant tests are 
approximate versions of the likelihood ratio and Wald test respecitvely. Instead
of estimating the models directly, they are estimated as a set of independent
logistic regressions.

{pstd}
Optionally, {cmd:oparallel} can use the bootstrap to compute the p-values for 
these tests. This is done by repeatedly sampling a new dependent variable based 
on the predicted probabilities of the ordered logit model. An ordered logit 
model is estimated using this new dependent variable and the original and the 
test statistic is computed. The distribution of these test statistics is an 
estimate of the sampling distribution if the null hypothesis is true, and the 
proportion of test statistics that is larger than the test statistic in the 
original data is thus an estimate of the p-value 
({help oparallel##efron_tibshirani:Efron and Tibshirani 1993}). This estimate can
be refined by using the number of test statistics larger than the original test
statistic plus one divided by the number of replications plus 1 
({help oparallel##davison_hinkley:Davison and Hinkley 1997}). This is the 
estimate used in {cmd:oparallel}.

{pstd}
In addition, it can display the comparisons of AIC and BIC between 
an ordered logit model and the fully generalized ordered logit model.


{title:Options}

{dlgtab:Statistics}

{pstd}
The default is to compute and display all 5 statistics. If any of the options 
below is specified, then the default changes to computing and displaying only 
the specified statistics.

{phang}
{opt score} specifies that the score test is to be computed and displayed. 

{phang}
{opt lr} specifies that the likelihood ratio test is to be computed and 
displayed. 

{phang}
{opt wald} specifies that the Wald test is to be computed and displayed. 

{phang}
{opt wolfe:gould} specifies that the Wolfe-Gould test is to be computed and 
displayed. 

{phang}
{opt brant} specifies that the Brant test is to be computed and displayed. 

{dlgtab:Other statistics}

{phang}
{opt ic} specifies that the ordered logit and generalized ordered logit model 
are compared using the AIC and BIC.

{dlgtab:Bootstrap}

{phang}
{opt asl} specifies that the bootstrap is used to compute the p-values.

{phang}
{opt reps(#)} specifies the number of replications used. The default is 999. 
This means that an estimated p-value of 5% would be based on only 49 
replications whose test-statistic is larger than the original test statistic. A
more reasonable number would be 19,999, that way an estimated p-value of 5% would
be based on 999 replications whose test-statistic is larger than the original 
test statistic.

{phang}
{cmd:mcci}[{cmd:(}{it:#}{cmd:)}] specifies that the Monte Carlo confidence 
interval for the bootstrap estimate of the p-value is to be computed and 
displayed. It quantifies the uncertainty in the estimate of the p-value due to 
the randomness that is part of the bootstrap procedure. If we were to run this 
bootstrap procedure many times we would expect {it:#}% of these times to return 
a p-value within the Monte Carlo confidence interval. By default, {it:#} is the
{help level:default confidence level}.

{phang}
{opt bs:ample} specifies that each replication will be estimated on a sample with
replacement from the original data. By default, only the dependent variable is 
drawn each replication from implied distribution of the dependent variable from 
the {cmd:ologit} model.

{phang}
{opt nodots} suppresses display of the replication dots.  By default, one dot
character is displayed for each successful replication.

{phang}
{opt sa:ving(filename [, replace double every(#)])} creates a Stata data file 
(.dta file) consisting of variables containing the test statitics and p-values 
for the replicates.

{pmore}
See {help prefix_saving_option} for details about suboptions.


{title:Examples}

{pstd}
Basic use:

{cmd}{...}
        use "http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta", clear
        ologit warm white ed prst male yr89 age
        oparallel
{txt}{...}
{p 4 4 2}({stata "oparallel_ex 1":click to run}){p_end}

{pstd}
The bootstrap p-values (the ASL). Here it is useful to select just one statistic
as otherwise it takes very long. The Brant statistic is usually very quick.

{cmd}{...}
        use "http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta", clear
        ologit warm white ed prst age
        oparallel, brant asl mcci 
{txt}{...}
{p 4 4 2}({stata "oparallel_ex 2":click to run}){p_end}

{pstd}
The distribution of the test statistics from the different bootstrap 
replications is an estimate of the sampling distribution of that statistic if 
the null hypothesis is true. You can save the test statistics using the 
{cmd:saving()} option, and check if that distribution corresponds with the 
theoretical distribution; a Chi-square distribution for the test statistic and 
a standard uniform distribution for the p-values. 

{pstd}
This example requires the {cmd:qenv}, {cmd:qplot}, and {cmd:simpplot} packages, 
which can be downloaded by typing {cmd:ssc install qenv}, {cmd:findit qplot}, 
and {cmd:ssc install simpplot}.

{cmd}{...}
        use "http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta", clear
        ologit warm white ed prst male yr89 age
        tempfile reps
        oparallel, brant asl saving(`reps')
        use `reps', clear
		
        qenvchi2 Brant_stat, gen(lb ub) df(12) overall reps(5000)
        tempname a b
        qplot Brant_stat lb ub, ms(oh none ..) c(. l l) ///
            lc(gs10 ..) legend(off) ytitle("Brant test statistic") ///
            trscale(invchi2(12,@)) xtitle("{&chi}{sup:2}(12) quantiles") ///
            scheme(s2color) ylab(,angle(horizontal)) name(`a')			
			
        simpplot Brant_p, scheme(s2color) ylab(,angle(horizontal)) name(`b')
{txt}{...}
{p 4 4 2}({stata "oparallel_ex 3":click to run}){p_end}


{title:Author}

{p 4 4}
Maarten L. Buis{break}
Wissenschaftszentrum Berlin für Sozialforschung, WZB{break}
Research unit Skill Formation and Labor Markets {break}
maarten.buis@wzb.eu
{p_end}


{title:References}

{marker brant}{...}
{phang}
Brant, Rollin (1990) Assessing proportionality in the proportional odds model
for ordinal logistic regression. {it:Biometrics}, {cmd:46}(4):1171–1178.

{marker davison_hinkley}{...}
{phang}
A.C. Davison & D.V. Hinkley (1997) 
{it:Bootstrap Methods and their Application}. Cambridge: Cambridge University 
Press.

{marker efron_tibshirani}{...}
{phang}
B. Efron & R.J. Tibshirani (1993) 
{it:An Introduction to the Bootstrap}. Boca Raton: Chapman & Hall/CRC.

{marker williams}{...}
{phang}
Williams, Richard (2006) Generalized ordered logit/partial proportional 
odds models for ordinal dependent variables. {it:The Stata Journal}, 
{cmd:6}(1): 58--82.
{browse "http://www.stata-journal.com/article.html?article=st0097"}

{marker wolfe}{...}
{phang}
Wolfe, Rory and William Gould (1998) An approximate likelihood-ratio 
test for ordinal response models. {it:Stata Technical Bulletin},
{cmd:7}(42): 24--27.
{browse "http://www.stata.com/products/stb/journals/stb42.pdf"}


{title:Acknowledgements}

{pstd}
The subroutines for the Wolfe-Gould test are based on {cmd:omodel} version 1.0.1 
by Rory Wolfe and Bill Gould, which is discussed in (Wolfe & Gould 1998)

{pstd}
The subroutines for the Brant test are based on {cmd:brant} version 1.6.0 by 
J. Scott Long and Jeremy Freese, which is part of the {cmd:spost} package.

{pstd}
Richard Williams and Ariel Linden provided many helpful comments


{title:Also see}

{psee}
Online: {helpb ologit}, {helpb test}, {helpb lrtest}

{psee}
If installed: {helpb omodel}, {helpb brant}, {helpb gologit2}
{p_end}
