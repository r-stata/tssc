{smcl}
{* 06feb2013/28feb2013 MLB}{...}
{* 21mar2012/12feb2013}{...}
{cmd:help qenvnormal} 
{hline}

{title:Generate quantile envelopes for normal quantile-quantile plot}


{title:Syntax}

{p 8 18 2}
{cmd:qenvnormal} 
{it:varname} 
{ifin} 
{cmd:,}
{cmdab:gen:erate(}{it:newvar1 newvar2}{cmd:)} 
[
{cmd:reps(}{it:#}{cmd:)} 
{cmdab:l:evel(}{it:#}{cmd:)} 
{cmdab:o:verall}
{cmd:{char -(}}
{cmdab:m:ean(}{it:#}{cmd:)}
{cmd:sd(}{it:#}{cmd:)}
{cmd:{char )-}}
]


{title:Description}

{pstd}
{cmd:qenvnormal} generates two numeric variables for later plotting on a
quantile-quantile plot that define an envelope of low and high
expectations for each quantile given repeated sampling from a normal
distribution with the same number of values, mean and standard deviation
as the data specified. The program is a helper program designed for use
with {help qplot}, which must be installed separately. 
Type {stata findit qplot} to get references and code sources. 

{pstd} 
When plotted, the envelopes are to be considered indicative, and not as
implying a formal decision. In particular, the envelopes underline which
quantiles are least reliable.  With some experience, they should guide
later analysis. 


{title:Remarks} 

{pstd}
The precise recipe is as follows. 

{pstd}
1. Calculate number of values, mean and standard deviation or use the 
mean and standard deviation specified in the {cmd:mean()} and {cmd:sd()} 
options. 

{pstd}
2. Take {cmd:reps} samples of the same size from a normal distribution
with the same mean and standard deviation. 

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
intervals.  

{pstd} 
In principle, the envelope variables could also be plotted in
conjunction with {help qnorm}, but that would require more work. 

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
{cmd:mean()} specifies the mean of the normal distribution. If
the {cmd:mean()} option is specified, than the {cmd:sd()} option must
also be specified.

{phang}
{cmd:sd()} specifies the standard deviation of the normal distribution. If
the {cmd:sd()} option is specified, than the {cmd:mean()} option must
also be specified.


{title:Examples} 

{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. qenvnormal weight, gen(lower upper)}{p_end}
{phang}{cmd:. tempname mean sd}{p_end}
{phang}{cmd:. scalar `mean' = r(mean)}{p_end}
{phang}{cmd:. scalar `sd' = r(sd)}{p_end}
{phang}{cmd:. qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb")}{p_end}
{phang}{cmd:. qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(`mean' + `sd' * invnormal(@)) xtitle(Normal quantiles)}{p_end}
{phang}{cmd:. qenvnormal weight, overall reps(2000) gen(lower2 upper2)}{p_end}
{phang}{cmd:. qplot weight lower2 upper2, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(`mean' + `sd' * invnormal(@)) xtitle(Normal quantiles)}{p_end} 
{p 4 4 2}({stata `"qenv_ex "normal""':click to run}){p_end}


{title:Authors} 

{pstd}Nicholas J. Cox, Durham University{break} 
      n.j.cox@durham.ac.uk 

{pstd}Maarten Buis, WZB{break} 
      maarten.buis@wzb.eu
	 
 
{title:Reference}	  

{phang}
Davison, A.C. and Hinkley, D.V. 1997. 
{it:Bootstrap methods and their application.}
Cambridge: Cambridge University Press.


{title:Also see}

{psee}
Manual:  {bf:[R] diagnostic plots}

