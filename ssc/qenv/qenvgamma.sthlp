{smcl}
{* 06Feb2013/28feb2013 MLB}{...}
{* 21mar2012/12feb2013}{...}
{cmd:help qenvgamma} 
{hline}

{title:Generate quantile envelopes for gamma quantile-quantile plot}


{title:Syntax}

{p 8 18 2}
{cmd:qenvgamma} 
{it:varname} 
{ifin} 
{cmd:,}
{cmdab:gen:erate(}{it:newvar1 newvar2}{cmd:)} 
[
{cmd:reps(}{it:#}{cmd:)} 
{cmdab:l:evel(}{it:#}{cmd:)}
{cmdab:o:verall} 
{cmd:{char -(}}
{cmdab:a:lpha(}{it:#}{cmd:)}
{cmdab:b:eta(}{it:#}{cmd:)}
{cmd:{char )-}}
]


{title:Description}

{pstd}
{cmd:qenvgamma} generates two numeric variables for later plotting on a
quantile-quantile plot that define an envelope of low and high
expectations for each quantile given repeated sampling from a gamma
distribution with the same number of values, shape and scale parameters  
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
1. Fit gamma distribution using {stata findit gammafit}, which must be 
installed separately, or use the alpha and beta parameters specified in 
the {cmd:alpha()} and {cmd:beta()} options. 

{pstd}
2. Take {cmd:reps} samples of the same size from a gamma distribution
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
conjunction with {stata findit qgamma}, but that would require more work. 

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
{cmd:alpha()} specifies the alpha parameter of the gamma distribution. If
the {cmd:alpha()} option is specified, than the {cmd:beta()} option must
also be specified.

{phang}
{cmd:beta()} specifies the alpha parameter of the gamma distribution. If
the {cmd:beta()} option is specified, than the {cmd:alpha()} option must
also be specified.

{pmore}
The parameters alpha and beta refer to the parameterization of the gamma 
distribution as implemented in 
{help betaden:gammaden}(alpha, beta, 0, {it:varname}).


{title:Examples}

{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. tempname alpha beta}{p_end}
{phang}{cmd:. qenvgamma weight, gen(lower upper)}{p_end}
{phang}{cmd:. scalar `alpha' = e(alpha)}{p_end}
{phang}{cmd:. scalar `beta' = e(beta)}{p_end}
{phang}{cmd:. qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb")}{p_end}
{phang}{cmd:. qplot weight lower upper, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(`beta' * invgammap(`alpha', @)) xtitle(Gamma quantiles)}{p_end}
{phang}{cmd:. qenvgamma weight, overall reps(5000) gen(lower2 upper2)}{p_end}
{phang}{cmd:. qplot weight lower2 upper2, ms(oh none ..) c(. l l) lc(gs10 ..) legend(off) ytitle("Weight, lb") trscale(`beta' * invgammap(`alpha', @)) xtitle(Gamma quantiles)}{p_end} 
{p 4 4 2}({stata `"qenv_ex "gammal""':click to run}){p_end}


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

