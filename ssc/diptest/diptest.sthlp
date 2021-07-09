{smcl}
{* 2 Feb 2009/25 Nov 2016}{...}
{hline}
{cmd:help diptest}
{hline}

{title:Dip statistic to test for unimodality}


{title:Syntax}

{p 8 18 2}
{cmd:diptest} 
{it:varname} 
{ifin} 
[ 
{cmd:,} 
{cmd:by(}{it:byvarlist}{cmd:)}
{cmdab:r:eps(}{it:#}{cmd:)} 
{it:list_options} 
] 


{title:Description}

{p 4 4 2}
{cmd:diptest} calculates and displays the dip statistic to test for
unimodality. This statistic is the maximum difference between the
empirical distribution function and the unimodal distribution function
that minimises that maximum difference. The dip thus measures departure
of a sample from unimodality and was proposed by Hartigan and Hartigan
(1985) as a test statistic for unimodality. Hartigan (1985) published
Fortran code. Maechler (2003) published corrected C code as part of
an R package diptest. 

{p 4 4 2}
The reference distribution for calculating the dip statistic is the
uniform, as a worst case unimodal distribution. P-values are calculated
by comparing the dip statistic obtained with those for repeated samples
of the same size from a uniform distribution. If the true distribution
is not uniform, other methods may be more appropriate or more powerful.
For further discussion, see Hartigan and Hartigan (1985) and Cheng and
Hall (1998). 


{title:Remarks} 

{p 4 4 2}
For reproducibility of P-values, {help generate:set seed} beforehand. 

{p 4 4 2}
Hartigan and Hartigan (1985, p.80), and also Hartigan (1985, p.321),
give a table of percent points (1, 5, 10, 50, 90, 95, 99, 99.5, 99.9%)
for the null distribution of the dip statistic for sample sizes 4(1)10
15 20 30 50 100 200 based on 9999 simulations. 

{p 4 4 2}
For sample sizes 1 to 3 or samples of identical values, the dip is
returned as 0. 

{p 4 4 2}
Note that this procedure is independent of any density estimation
procedure.

{p 4 4 2}
As a side-effect of the calculation, {cmd:diptest} returns low and high
ends of the modal interval for the best-fitting unimodal distribution
corresponding to the data. The mean of values in that interval is also 
reported, without warranty of any merits as a summary. 

{p 4 4 2}
{cmd:diptest} uses Mata for its innermost calculations.
Thus Stata 9 up is required. 


{title:Options} 

{p 4 8 2}
{cmd:by()} specifies that calculations are to be carried out separately
for the distinct groups defined by {it:byvarlist}. The variable(s) in
{it:byvarlist} may be numeric or string. 

{p 4 8 2}
{cmd:reps()} specifies the number of repetitions of sampling from a
uniform distribution of the same size. The default is 10000. Note that
{cmd:reps(0)} suppresses P-value calculation. 

{p 4 8 2}
{it:list_options} are options of {help list} other than {cmd:noobs} and
{cmd:subvarname}. They may be specified to tune the display of results. 


{title:Examples}

{p 4 8 2}{cmd:. * Hartigan and Hartigan 1985 p. 82}{p_end}
{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. set obs 43}{p_end}
{p 4 8 2}{cmd:. gen sfreq = "1001011205411322223121252002013441001000102"}{p_end}
{p 4 8 2}{cmd:. gen quality = 29 + _n}{p_end}
{p 4 8 2}{cmd:. gen freq = real(substr(sfreq, _n, 1))}{p_end}
{p 4 8 2}{cmd:. drop if freq == 0}{p_end}
{p 4 8 2}{cmd:. expand freq}{p_end}
{p 4 8 2}{cmd:. sort quality}{p_end}
{p 4 8 2}{cmd:. diptest quality}


{title:Saved results} 

    r(n_1)       number of observations for first group 	
    r(dip_1)     dip for first group 
    r(low_1)     low end of modal interval for first group 
    r(high_1) 	 high end of modal interval for second group 
    r(mean_1) 	 mean of modal interval for second group 
    r(P_1)       P-value for first group 

    etc. (suffixes _2 etc. indicating second group etc.) 	


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, UK{break} 
n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}Mata code is based on Fortran code in Hartigan (1985) and C
code in Maechler (2003). In November 2016 Diego Calavia Gil kindly
informed me of the need to echo a bug fix in the original code
identified by Yong Fu.  The change is documented in the code. 


{title:References}

{p 4 8 2}
Cheng, M-Y. and P. Hall. 1998. Calibrating the excess mass and
dip tests of modality. {it:Journal, Royal Statistical Society, Series B}
60: 579{c -}589. 

{p 4 8 2}
Hartigan, J.A. and P.M. Hartigan. 1985. The dip test of unimodality.
{it:Annals of Statistics} 13: 70{c -}84. 

{p 4 8 2} 
Hartigan, P.M. 1985. Algorithm AS 217: Computation of the dip 
statistic to test for unimodality. {it:Applied Statistics} 34: 320{c -}325. 
 
{p 4 8 2}
Maechler, M. 2003. diptest 0.25-1. 
{browse "http://www.r-project.org/":http://www.r-project.org/}


{title:Also see}

{p 4 13 2}help for {help kdensity}, {help modes} (if installed), 
{help hsmode} (if installed) 

