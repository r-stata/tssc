{smcl}
{* 25Mar2013 NJC minor revisions}{...}
{* 28Feb2013 MLB}{...}
{cmd:help qenvF} 
{hline}

{title:Generate quantile envelopes for F quantile-quantile plot}


{title:Syntax}

{p 8 18 2}
{cmd:qenvF} 
{it:varname} 
{ifin} 
{cmd:,}
{cmdab:gen:erate(}{it:newvar1 newvar2}{cmd:)} 
{cmdab:dfn:um(}{it:#}{cmd:)}
{cmdab:dfd:enom(}{it:#}{cmd:)}
[
{cmd:reps(}{it:#}{cmd:)} 
{cmdab:l:evel(}{it:#}{cmd:)}
{cmdab:o:verall} 
]


{title:Description}

{pstd}
{cmd:qenvF} generates two numeric variables for later plotting on a
quantile-quantile plot that define an envelope of low and high
expectations for each quantile given repeated sampling from a F
distribution with the same number of values, and degrees of freedom  
as specified. The program is a helper program designed for use
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
1. Take {cmd:reps} samples of the same size from a F distribution
with the parameter values specified in {cmd:dfnum()} and 
{cmd:dfdenom()}. 

{pstd}
2. Order each sample from smallest to largest. 

{pstd}
3. For each rank, calculate reference intervals containing
{cmd:level}% of the sample quantiles. For example, with the default of
95%, the interval ranges from the 2.5% quantile to the 97.5% quantile,
the quantiles being calculated using a procedure similar to that used
for {help pctile}.  

{pstd}
4. The generated variables contain values defining the reference
intervals.  They are not aligned with the values of {it:varname} in the
dataset, but they are assigned to the same set of observations, which is
sufficient for {help qplot}. 

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
{cmd:dfnum()} specifies the numerator degrees of freedom of the F distribution. 
This is a required option.

{phang}
{cmd:dfdenom()} specifies the denominator degrees of freedom of the F 
distribution. This is a required option.

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


{title:Examples}

{pstd}
In the example below we check whether the sampling distibution of the Wald statistic
as returned by {help test} does follow a F distribution if the null hypothesis
is true.

{phang}{cmd:. clear all}{p_end}
{phang}{cmd:. sysuse auto}{p_end}
{phang}{cmd:. gen lnprice = ln(price)}{p_end}
{phang}{cmd:. reg turn mpg i.rep78 foreign}{p_end}
{phang}{cmd:. predict double mu1}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. reg turn mpg i.rep78 foreign weight lnprice}{p_end}
{phang}{cmd:. predict double mu2}{p_end}
{phang}{cmd:. gen double ysim = turn - mu2 + mu1}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. keep ysim mpg rep78 foreign weight lnprice}{p_end}
{phang}{cmd:. keep if !missing(ysim,  lnprice, mpg, rep78, foreign, weight)}{p_end}
{phang}{cmd:. tempfile temp}{p_end}
{phang}{cmd:. save `temp'}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. program define qenv_sim_F}{p_end}
{phang}{cmd:.     use `1', clear}{p_end}
{phang}{cmd:.     bsample}{p_end}
{phang}{cmd:.     reg ysim mpg i.rep78 foreign weight lnprice}{p_end}
{phang}{cmd:.     test weight lnprice}{p_end}
{phang}{cmd:. end}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. simulate F=r(F), reps(1000): qenv_sim_F `temp'}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. qenvF F, gen(lb ub) dfnum(2) dfdenom(60) overall reps(5000)}{p_end}
{phang}{cmd:. qplot F lb ub, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Wald test statistics") trscale(invF(2,60,@)) xtitle(F(2,60) quantiles)}{p_end}
{p 4 4 2}({stata `"qenv_ex "F""':click to run}){p_end}


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

