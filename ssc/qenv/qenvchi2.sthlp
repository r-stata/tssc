{smcl}
{* 25Mar2013 NJC minor revisions}{...}
{* 28Feb2013 MLB}{...}
{cmd:help qenvchi2} 
{hline}

{title:Generate quantile envelopes for chi-squared quantile-quantile plot}


{title:Syntax}

{p 8 18 2}
{cmd:qenvchi2} 
{it:varname} 
{ifin} 
{cmd:,}
{cmdab:gen:erate(}{it:newvar1 newvar2}{cmd:)} 
[
{cmd:reps(}{it:#}{cmd:)} 
{cmdab:l:evel(}{it:#}{cmd:)}
{cmdab:o:verall} 
{cmd:df(}{it:#}{cmd:)}
]


{title:Description}

{pstd}
{cmd:qenvchi2} generates two numeric variables for later plotting on a
quantile-quantile plot that define an envelope of low and high
expectations for each quantile given repeated sampling from a chi-squared
distribution with the same number of values, and degrees of freedom  
as the data specified. The program is a helper program designed for use
with {help qplot}, which must be installed separately. 
Type {stata findit qplot} to get references and code sources. 

{pstd} 
When plotted, the envelopes are to be considered indicative, and not as
implying a formal decision. In particular, the envelopes underline which
quantiles are least reliable.  With some experience, they should guide
later analysis. 


{title:Remarks}

{pstd}"Degrees of freedom" is to be understood by purists as indicating 
"number of degrees of freedom".  

{pstd}
The precise recipe is as follows. 

{pstd}
1. Either fit a chi-squared distribution by setting the degrees of freedom 
equal to the mean of {it:varname}, or specify the degrees of freedom in the 
{cmd:df()} option. 

{pstd}
2. Take {cmd:reps} samples of the same size from a chi-squared distribution
with the same parameter values. 

{pstd}
3. Order each sample from smallest to largest. 

{pstd}
4. For each rank, calculate reference intervals containing
{cmd:level}% of the sample quantiles. For example, with the default of
95%, the interval ranges from the 2.5% quantile to the 97.5% quantile,
the quantiles being calculated using a procedure similar to that used
for {help pctile}.  

{pstd}
5. The generated variables contain values defining the reference
intervals.  They are not aligned with the values of {it:varname} in the
dataset, but they are assigned to the same set of observations, which is
sufficient for {help qplot}. 

{pstd} 
In principle, the envelope variables could also be plotted in
conjunction with {help qchi}, but that would require more work. 

{pstd}
This envelope approximates a separate test for each rank. The probability 
that in a variable an observation falls outside this envelope is much 
larger than 100 - {cmd:level}. When specifying the {cmd:overall} option an
envelope will be computed such that the overall error rate will be 
approximately 100 - {cmd:level} using an algorithm discussed by Davison and 
Hinkley (1997, Chapter 4).

{pstd}
1. Set L to ceil((100 - {cmd:level})/200 * {cmd:reps}). 

{pstd}
2. For each sample create an envelope using the remaining samples by 
storing for each rank the Lth and ({cmd:reps} - L)th smallest value, and determine 
whether the entire sample falls within this envelope. The proportion of 
samples for which this is not true is an estimate of the overall error rate
of that envelope.

{pstd}
3. Decrease L until the overall error rate is less than 100 - {cmd:level}. If
the nominal level has not been reached when L = 1, then the entire range is
returned and a warning is displayed reporting the approximate overall error
rate for that envelope.

{pstd}
4. Compute the envelope using all samples based on this L.


{title:Options}

{phang}
{cmd:generate()} specifies the names of two new variables to be
generated.  This is a required option.  

{phang} 
{cmd:reps()} specifies the number of samples to be taken. The default is
100.  This is likely to be adequate for informal exploration.  

{phang} 
{cmd:level()} specifies the percent of sample values to be included
within the envelope for each rank.  {cmd:level(100)} is allowed and
interpreted as the entire range. 

{phang}
{cmd:overall} specifies that an envelope with an approximate overall 
error rate of 100 - {cmd:level} is to be computed instead of a pointwise 
error rate of approximately 100 - {cmd:level}.

{phang}
{cmd:df()} specifies the degrees of freedom of the chi-squared distribution. 


{title:Examples}

{pstd}
In the example below we check whether the sampling distibution of the Wald statistic
as returned by {help test} does follow a chi-squared distribution if the null hypothesis
is true.

{phang}{cmd:. clear all}{p_end}
{phang}{cmd:. sysuse nlsw88}{p_end}
{phang}{cmd:. gen byte black = race == 2 if race <= 2}{p_end}
{phang}{cmd:. keep wage union grade ttl_exp black}{p_end}
{phang}{cmd:. keep if !missing(wage, union, grade, black, ttl_exp)}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. glm  wage union grade black , link(log) vce(robust) family(poisson)}{p_end}
{phang}{cmd:. predict double mu1}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. glm wage union grade black c.ttl_exp##c.ttl_exp , link(log) family(poisson) vce(robust)}{p_end}
{phang}{cmd:. predict double mu2}{p_end}
{phang}{cmd:. gen double ysim = wage - mu2 + mu1}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. tempfile temp}{p_end}
{phang}{cmd:. save `temp'}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. program define sim}{p_end}
{phang}{cmd:.     use `1', clear}{p_end}
{phang}{cmd:.     bsample}{p_end}
{phang}{cmd:.     glm ysim union grade black c.ttl_exp##c.ttl_exp, link(log) vce(robust) family(poisson)}{p_end}
{phang}{cmd:.     test ttl_exp c.ttl_exp#c.ttl_exp}{p_end}
{phang}{cmd:. end}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. simulate chi2=r(chi2) , reps(1000): sim `temp'}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. qenvchi2 chi2, gen(lb ub) df(2)  overall reps(5000)}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. qplot chi2 lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Wald test statistic") trscale(invchi2(2,@)) xtitle("{&chi}{sup:2}(2) quantiles")}{p_end}
{p 4 4 2}({stata `"qenv_ex "chi2""':click to run}){p_end}


{title:Authors} 

{pstd}Maarten Buis, WZB{break} 
      maarten.buis@wzb.eu
         
{pstd}Nicholas J. Cox, Durham University{break} 
      n.j.cox@durham.ac.uk 

 
{title:Reference}         

{phang}
Davison, A.C. and Hinkley, D.V. 1997. 
{it:Bootstrap methods and their application.}
Cambridge: Cambridge University Press.


{title:Also see}

{psee}
Manual:  {bf:[R] diagnostic plots}

