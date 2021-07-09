{smcl}
{* *! version 1.5.0  25Mar2013}{...}
{* *! version 1.2.1  02Aug2012}{...}
{* *! version 1.1.0  19Jun2012}{...}
{* *! version 1.0.0  18Jun2012}{...}
{cmd:help simpplot}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:simpplot} {hline 2}}Plot describing p-values from a simulation by 
comparing nominal significance levels with the coverages{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:simpplot}
{varlist} 
{ifin} 
[{cmd:,}
{it:{help simpplot##options:options}}
]
      
	  
{marker options}{...}
        {it:options}{col 33}description 
        {hline 67}
        {cmd:main#opt(}{it:}{help twoway_scatter:graph_opts} {cmd:)}{...}
{col 33}options governing the look the #th variable 
        {cmd:ra(}{it:off} | {it:{help twoway_rarea:graph_opts}}{cmd:)}{...}
{col 33}options governing the look of the Monte
{col 33}Carlo region of acceptance
        {opt l:evel(#)}{...}
{col 33}set {help level:confidence level} for the Monte Carlo 
{col 33}region of acceptance; default is {cmd:level(95)}
        {cmd:overall}{...}
{col 33}displays a region of acceptance with an 
{col 33}overall error rate of {cmd:level}. The default is
{col 33}to display a region of acceptance with a 
{col 33}point-wise error rate of {cmd:level}
        {opt reps(#)}{...}
{col 33}number of replications used for computing 
{col 33}the overall error rate. the default is 1000.
        {cmd:ref0(}{it:off} | {it:{help twoway_line:graph_opts}}{cmd:)}{...}
{col 33}options governing the look of a reference
{col 33}line
        {opt nodev:iations}{...}
{col 33}displays the observed coverage against 
{col 33}nominal significance levels; default is to 
{col 33}display the deviations from the nominal 
{col 33}significance level against the nominal 
{col 33}significance level
        {cmd:by(}{it:{varlist}} [{cmd:,} {it:{help by_option:byopts}}]{cmd:)}{...}
{col 33}option for repeating simpplot command
        {opt gen:erate(newvars)}{...}
{col 33}specifies that the deviations or observed 
{col 33}coverages and optionally the x-coordinate, 
{col 33}upper and lower bound of the Monte Carlo 
{col 33}region are to be stored
        {opt addplot(plot)}{...}
{col 33}add other plots to the graph
        {help twoway_scatter:other graph options} 
        {hline 67}


{title:Description}

{pstd}
{cmd:simpplot} describes the results of a simulation that inspects the coverage of 
a statistical test. If a null-hypothesis is true than a statistical test at a 5% 
siginificance level should reject the true null hypothesis in 5% of the 
replications. In a simulation we can make sure that the null hypothesis is true 
in the "population", draw many times from that "population", perform the test in 
each of these "samples", and count how many times the null hypothesis is rejected. 
The proportion of replications in which the hypothesis was rejected is our 
estimate of the coverage of the test, and this coverage should be close to the
nominal siginficance level. There is nothing special about the 5% significance 
level other than that it is the conventional level in many disciplines. We could
just as easily look at the coverage of tests at a 1%, 2%, 10%, or any other 
significance level. {cmd:simpplot} displays by default the deviations from the 
nominal significance level against the entire range of possible nominal 
significance levels. It also displays the range (Monte Carlo region of acceptance) 
within which we can reasonably expect these deviations to remain if the test is 
well behaved.

{pstd}
If a test is well behaved than the p-values of that test of a true null-hypothesis
should follow a standard uniform distribution. That way 1% of the replication will
have a p-value less than 0.01, 5% of the replications will have a p-value less than 
0.05, 10% will have a p-value less than 0.10, etc. So whichever significance level
we choose, we will on average reject the null hypothesis the right number of times. 
One could see the graph produced by {cmd:simpplot} as a graphical test whether the 
distribution of p-values follows a standard uniform distribution. 

{pstd}
Even if the test we are checking with our simulaiton works perfectly, we would 
still expect slight deviations in the distribution of the p-values from a standard 
uniform distribution because of the randomness in a Monte Carlo experiment. To 
quantify the amount of this uncertainty {cmd:simpplot} by default also displays a 
point-wise Monte Carlo region of acceptance. This gives for each nominal significance 
level the range in which we would expect most simulations (by default 95%) to be if 
we were repeating our simulation experiment many times and we were simulating a well 
behaved test. If we did a simulation with {it:n} replication, than for a given 
nominal significance level {it:a} we would expect the number of rejections to follow 
a binomial({it:n},{it:a}) distribution. This is what is being used to compute the 
end points of the point-wise region of accpetance.

{pstd}
A 95% point-wise region of acceptance means that 5% of the replications of our Monte
Carlo experiment is expected to lie outside the point-wise region of acceptance. So,
the chance that the entire set of replications lies within the point-wise region of
acceptence is a lot less than the nominal 95%. {cmd:simpplot} can also display an 
approximate overall region of acceptance, that is the region in which we expect 95%
of the curves to remain if we were repeating the Monte Carlo experiment many times 
using an algorithm discussed by Davison and Hinkley (1997, Chapter 4).

{pmore}
1. Define a grid of nominal significance level consisting of 300 equally spaced values
between .001 and .999, i.e. .001, .0043, .0077, ... .992, .996, .999. Take {cmd:reps} 
samples of the same size from a standard uniform distribution. For each sample from the
uniform distribution and each value on the grid, compute the proportion of that sample 
that is less than or equal to that grid value. 

{pmore}
2. Order each sample from smallest to largest. 

{pmore}
3. Set L to ceil((100 - {cmd:level})/200 * {cmd:reps}). 

{pmore}
4. For each sample, create an envelope using the remaining samples by 
storing for each grid value the Lth and ({cmd:reps} - L)th smallest value, and determine 
whether the entire sample falls within this envelope. The proportion of 
samples for which this is not true is an estimate of the overall error rate
of that envelope.

{pmore}
5. Decrease L until the overall error rate is less than 100 - {cmd:level}. If
the nominal level has not been reached when L = 1, then the entire range is
returned and a warning is displayed reporting the approximate overall error
rate for that envelope.

{pmore}
6. For each value on the grid, calculate reference intervals using the Lth and
(1-L)th sample value.  


{title:options}

{phang}
{opt main#opt(graph_opts)} options governing the look of the #th variable specified
in {it:varlist}. the relevant options are listed in {help twoway_scatter}.

{phang}
{opt ra(off | graph_opts)} options governing the look of the Monte Carlo region of 
acceptance. One can suppres the display (and computation) of the Monte Carlo region 
of acceptance by specifying {cmd:ra(off)}. Alternatively, one can specify options
that change the look of the region of acceptance. The relevant options are listed 
in {help twoway_rarea}.

{phang}
{opt level(#)} set {help level:confidence level} for the Monte Carlo region of 
acceptance; default is level(95)

{phang}
{opt overall} specifies that the approximate overall Monte Carlo region of acceptance 
is displayed instead of the default point-wise Monte Carlo region of acceptance. 

{phang}
{opt reps(#)} specifies the number of samples used to compute the overall Monte Carlo 
region of acceptance. The default is {opt reps(1000)}, which is often not enough. The 
{opt overall} option needs to be specified when specifying the {opt reps(#)} option.

{phang}
{opt ref0(off | graph_opts)} options governing the look of a reference line. By
default this is a horizontal line at 0. If the {cmd:nodeviations} option is specified
than the reference line is a diagonal line from 0,0 to 1,1. One can suppres the 
reference line by specifying {cmd:ref0(off)}. Alternatively, one can specify 
options than change the look of the reference line. The relevant options are listed
in {help twoway_line}.

{phang}
{opt nodeviations} displays the observed coverage against nominal significance levels; 
default is to display the deviations from the nominal significance level against 
the nominal significance level.

{phang}
{cmd:by(}{it:varlist} [{cmd:,} {it:byopts}]{cmd:)} Option by() draws separate plots 
within one graph. The {it:byopts} are documented in {help by_option}.

{phang}
{opt gen:erate(newvars)} specifies that the deviations (the default) or coverages 
(when the {cmd:nodeviations} option has been specified) for each variable in {it:varlist} 
is to be stored. If the number of {it:newvars} is the number of variables in 
{it:varlist} + 3, than the x-coordinate, the upper and lower bound of the Monte Carlo 
region of acceptance are also stored. 

{pmore}
So if one uses {cmd:simpplot} to display {it:k} p-values, than one can specify either 
{it:k} or {it:k} + 3 {it:newvars}. The first {it:k} {it:newvars} will contain the 
deviations or coverages of the corresponding p-value in {it:varlist}. The {it:k}+1th
newvar will contain the x-coordinate for the Monte Carlo region of acceptance, the
{it:k}+2th and {it:k}+3th will contain respectively the lower and upper bound of that
area.

{phang}
{opt addplot(plot)} allows adding more {help graph twoway} plots to the graph

{phang}
{help twoway scatter: other graph options} 


{title:Examples}

{pstd}
In this example we test how well a t-test performs when the data is from a 
non-Gaussian (some prefer to say non-normal) distribution, in this case a 
Chi-square distribution with 2 degrees of freedom. We know that the mean of that 
distribution is 2, so a t-test whether the mean equals 2 is a test of a true 
null-hypothesis. We also look at how well this test performs in different sample 
sizes. In a sample size of 50 the test does not perform too well, the true 
null-hypothesis is too often rejected, but a sample size of a 500 seems already 
big enough for this test to work.

{cmd}
    program drop _all
    program define sim, rclas
        drop _all
        set obs 500
        gen x = rchi2(2)
	
        ttest x=2 in 1/50
        return scalar p50 = r(p)
	
        ttest x=2 
        return scalar p500 = r(p)
    end

    set seed 12345
    simulate p50=r(p50) p500=r(p500), ///
             reps(5000) : sim 

    label var p50 "N=50"
    label var p500 "N=500"
	
    simpplot p50 p500, main1opt(mcolor(red)) ///
                       main2opt(mcolor(blue))
{txt}


{title:Author}

{p 4 4}
Maarten L. Buis{break}
Wissenschaftszentrum Berlin für Sozialforschung, WZB{break}
Research unit Skill Formation and Labor Markets {break}
maarten.buis@wzb.eu
{p_end}


{title:Reference}	  

{phang}
Davison, A.C. and Hinkley, D.V. 1997. 
{it:Bootstrap methods and their application.}
Cambridge: Cambridge University Press.


{title:Also see:}

{p 4 4}
if installed: {help simsum}, {help qenvnormal}, {help qenvchi2}, {help qenvF}
