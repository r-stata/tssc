{smcl}
{.-}
help for {cmd:normalbvr} {right:(Roger Newson)}
{.-}

{title:Generate Normal bivariate ridits}

{p 8 27}
{cmd:normalbvr} {it:newvarname} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] ,
  {cmdab:x}{cmd:(}{it:expression_1}{cmd:)} {cmdab:y}{cmd:(}{it:expression_2}{cmd:)}
  [ {cmdab:r:ho}{cmd:(}{it:expression_3}{cmd:)} 
  {cmdab:mux}{cmd:(}{it:expression_4}{cmd:)}  {cmdab:muy}{cmd:(}{it:expression_5}{cmd:)}
  {cmdab:sdx}{cmd:(}{it:expression_6}{cmd:)} {cmdab:sdy}{cmd:(}{it:expression_7}{cmd:)}
  {cmd:float} ]

{pstd}
where {it:expressioni} (for {it:i} from 1 to 7)
is a numeric expression. The numeric expression for each
option must be in the form required by the {cmd:generate} command. That is to say,
each expression must be specified so that the command

{pstd}
{cmd:gene double }{it:newvarname}{cmd:=(}{it:expressioni}{cmd:)}

{pstd}
will work.


{title:Description}

{pstd}
{cmd:normalbvr} inputs expressions specifying an {it:X}-variable and a {it:Y}-variable
and parameters for a bivariate normal distribution,
and generates a new variable,
containing bivariate ridits of the {it:X}-variable and the {it:Y}-variable
with respect to the specified bivariate Normal distribution.
Normal bivariate ridits are used in power calcuations for Kendall's tau-a.
If the {it:X}-variable and the {it:Y}-variable have the specified bivariate Normal distribution,
then the mean bivariate ridit is equal to the population Kendall's tau-a,
and the sampling variance of the sample Kendal's tau-a is equal
to 4 times the variance of the bivariate ridits
divided by the sample number.


{title:Options}

{p 0 4}{cmd:x(}{it:expression_1}{cmd:)} must be specified.
It gives an expression for the {it:X}-variable.

{p 0 4}{cmd:y(}{it:expression_2}{cmd:)} must be specified.
It gives an expression for the {it:Y}-variable.

{p 0 4}{cmd:rho(}{it:expression_3}{cmd:)} gives an expression
for the correlation coefficient of the specified bivariate Normal distribution.
If not specified, it is set to zero.

{p 0 4}{cmd:mux(}{it:expression_4}{cmd:)} gives an expression for the mean of the {it:X}-variable
in the specified bivariate Normal distribution.
If not specified, it is set to zero.

{p 0 4}{cmd:muy(}{it:expression_5}{cmd:)} gives an expression for the mean of the {it:Y}-variable
in the specified bivariate Normal distribution.
If not specified, it is set to zero.

{p 0 4}{cmd:sdx(}{it:expression_6}{cmd:)} gives an expression
for the standard deviation of the {it:X}-variable
in the specified bivariate Normal distribution.
If not specified, it is set to 1.

{p 0 4}{cmd:sdy(}{it:expression_7}{cmd:)} gives an expression
for the standard deviation of the {it:Y}-variable
in the specified bivariate Normal distribution.
If not specified, it is set to 1.

{p 0 4}{cmd:float} specifies that the output variable will have a {help datatypes:storage type} no higher than {hi:float}.
If {cmd:float} is not specified, then {cmd:normalbvr} creates the output variable with storage type {hi:double}.
Whether or not {cmd:float} is specified, {cmd:normlbvr} compresses the output variable as much as possible
without loss of precision. (See help for {help compress}.)


{title:Methods and Formulas}

{pstd}
The bivariate ridit of an {it:x}-value and a {it:y}-value,
with respect to a bivariate distribution for a bivariate random variable {it:(X,Y)},
is equal to

{pstd}
{it:B_XY(x,y) = E[sign(x-X)*sign(y-Y)]}

{pstd}
or (equivalently) to the difference
between the probability that a random value of {it:(X,Y)} is concordant with {it:(x,y)} 
and the probability that a random value of {it:(X,Y)} is discordant with {it:(x,y)}.
The expectation and variance of the variable {it:B_XY(X,Y)}
are used in power calculations for Kendall's tau-a.
The population Kendall's tau-a is equal to the population mean of {it:B_XY(X,Y)},
and the standard deviation of the influence function of Kendall's tau-a
is equal to twice the population standard deviation of {it:B_XY(X,Y)}.
The standard deviation of the influence function of a sample statistic
can be divided by the square root of the sample number
to obtain the asymptotic standard error of the sample statistic.

{pstd}
Note that bivariate ridits are defined on a scale fron -1 to 1,
by analogy with the univariate ridits defined by Brockett and Levene (1977).
For more about univariate ridits,
see the help for the {help ssc:SSC} package {helpb wridit}.

{pstd}
For more about estimating Kendall's tau-a in Stata,
using the {help sc:SSC} package {helpb somersd},
see Newson (2006).
For more about generalized power calculations
using standard deviations of influence functions,
and using the {help sc:SSC} package {helpb powercal},
see Newson (2004).
For more about the distribution theory of {it:U}-statistics
(such as Kendall's tau-a),
see Section 3.2 of Puri and Sen (1971).
For the application of this theory to power calculations for Kendall's tau-a,
see Newson (2018).


{title:Examples}

{pstd}
The first example generates 10000 observations,
each with a pair of values sampled from a standard bivariate Normal distribution
with a Pearson correlation cofficient of 0.5.
We then use {cmd:normalbvr} to compute the Normal bivariate ridits
in a new variable {cmd:bvridit}.
Finally, we use {helpb collapse} to collapse the dataset to 1 observation,
containing the mean of {cmd:bvridit} in the variable {cmd:taua},
which is an estimate for Kendall's tau-a,
and the standard deviation of the influence function
in a variable {cmd:sdinf},
and list this summary datset.

{p 8 16}{inp:. clear}{p_end}
{p 8 16}{inp:. set seed 98765432}{p_end}
{p 8 16}{inp:. set obs 10000}{p_end}
{p 8 16}{inp:. scal rhoscal = 0.5}{p_end}
{p 8 16}{inp:. gene xvar = rnormal()}{p_end}
{p 8 16}{inp:. gene yvar = rhoscal*xvar + rnormal()*sqrt(1-rhoscal*rhoscal)}{p_end}
{p 8 16}{inp:. normalbvr bvridit, x(xvar) y(yvar) rho(rhoscal)}{p_end}
{p 8 16}{inp:. collapse (count) N=bvridit (mean) taua=bvridit (sd) sdinf=bvridit}{p_end}
{p 8 16}{inp:. replace sdinf=2*sdinf}{p_end}
{p 8 16}{inp:. list, abbr(32)}{p_end}

{pstd}
The second example first creates a dataset with 1 observation
for each of a sequence of 13 Pearson correlations
ranging from -1 to 1 by increments of 1/12,
stored in a variable {cmd:rhovar}.
We then use the {help ssc:SSC} package {helpb expgen}
to create an expanded dataset,
in which each observation in the original dataset
is replaced by 10000 observations,
and simulate, in each observation,
a pair of values in variables {cmd:xvar} and {cmd:yvar},
sampled from a bivariate standard Normal distribution
with the Pearson correlation stored in {cmd:rhovar}.
After this, we use {cmd:normalbvr} to compute the Normal bivariate ridits,
and {helpb collapse} the dataset to create a dataset with 1 observation per Pearson correlation,
and variables {cmd:taua} estimating the corresponding Kendall's tau-a
and {cmd:sdinf} estimatind the standard deviation of the influence function
for estimatin Kendall's tau-a.
This dataset, created using simulation, is listed,
and illustrates Greiner's relation between Kendall's tau-a and the Pearson correlation,
which is given by

{pstd}
{it: taua = (2/_pi)*asin(rho)}

{pstd}
and which holds for a bivariate Normal distribution.

{p 8 16}{inp:. clear}{p_end}
{p 8 16}{inp:. set seed 98765432}{p_end}
{p 8 16}{inp:. set obs 25}{p_end}
{p 8 16}{inp:. gene rhovar=(_n-13)/12}{p_end}
{p 8 16}{inp:. sort rhovar}{p_end}
{p 8 16}{inp:. expgen =10000, sortedby(unique) copyseq(xyseq)}{p_end}
{p 8 16}{inp:. gene xvar = rnormal()}{p_end}
{p 8 16}{inp:. gene yvar = rhovar*xvar + rnormal()*sqrt(1-rhovar*rhovar)}{p_end}
{p 8 16}{inp:. normalbvr bvridit, x(xvar) y(yvar) rho(rhovar)}{p_end}
{p 8 16}{inp:. collapse (count) N=bvridit (mean) taua=bvridit (sd) sdinf=bvridit, by(rhovar)}{p_end}
{p 8 16}{inp:. replace sdinf=2*sdinf}{p_end}
{p 8 16}{inp:. list, abbr(32)}{p_end}

{pstd}
Alternatively, we might use a grid of Normal percentiles,
instead of sampling by Monte Carlo simulation.
In either case, we are numerically integrating values for Kendall's tau-a
and the standard deviation of its influence function.
These can then be used in power calculations
by the {help ssc:SSC} package {helpb powercal}.

{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{phang}
Brockett, P. L., and Levene, A.  1977.
On a characterization of ridits.
{it:The Annals of Statistics} 5(6): 1245-1248.

{pstd}
Newson R.
2018.
Bivariate ridits and distribution theory for Kendall's tau-a.
Download from
{browse "http://www.rogernewsonresources.org.uk/papers.htm#miscellaneous_documents":Roger Newson's website}.

{pstd}
Newson R.
2006.
Confidence intervals for rank statistics: Somers' {it:D} and extensions.
{it:The Stata Journal} 6(3): 309-334.
Download from
{browse "http://www.stata-journal.com/article.html?article=snp15_6":The Stata Journal website}.

{pstd}
Newson R.
2004.
Generalized power calculations for generalized linear models and more.
{it:The Stata Journal} 4(4): 379-401.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0074":The Stata Journal website}.

{pstd}
Puri M. L., and Sen P. K.
1971.
Nonparametric Methods in Multivariate Statistics.
New York: John Wiley & Sons Inc.


{title:Also see}

{p 4 13 2}
{bind: }Manual:  {hi:[R] collapse}
{p_end}
{p 4 13 2}
On-line: help for {helpb collapse}{break}
          help for {helpb powercal}, {helpb somersd}, {helpb expgen}, {helpb wridit} (if installed)
