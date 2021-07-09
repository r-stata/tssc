{smcl}
{* *! version 1.0  22Oct2016}{...}
{vieweralsosee "wtdttt" "help wtdttt"}{...}
{viewerjumpto "Syntax" "wtdtttdiag##syntax"}{...}
{viewerjumpto "Description" "wtdtttdiag##description"}{...}
{viewerjumpto "Options" "wtdtttdiag##options"}{...}
{viewerjumpto "Remarks - Methods and Formulas" "wtdtttdiag##remarks"}{...}
{viewerjumpto "Examples" "wtdtttdiag##examples"}{...}
{viewerjumpto "Results" "wtdtttdiag##results"}{...}
{viewerjumpto "References" "wtdtttdiag##references"}{...}
{title:Title}

{phang} {bf:wtdtttdiag} {hline 2} Obtain diagnostic plots 
assessing the fit of an estimated parametric Waiting Time 
Distribution (WTD) with respect to the observed histogram of
prescription redemptions.

{marker syntax}{...}
{title:Syntax}

{p 8 40 2}
{cmd:wtdtttdiag}
{varname} [{it:if}] [{it:in}], [{cmd:reverse}
	  	    	       {cmd:nbins(}{it:integer}{cmd:)}
			       {cmd:nq(}{it:integer}{cmd:)}
			       {cmd:replace}
			       {it:twoway options}]

{marker description}{...}
{title:Description}

{pstd} {cmd:wtdtttdiag} produce a diagnostic plot, i.e. a
histogram based on observed prescription redemptions and the
corresponding fitted parametric model of a previous call to {help wtdttt} or {help ranwtdttt} - the latter only if the estimation procedure has converged. {cmd:wtdtttdiag} should be executed immediately after the
relevant {help wtdttt} or {help ranwtdttt} estimated model you want to assess the fit of.
Note that {cmd:wtdtttdiag} is only useful when you did not specify
covariates in your {help wtdttt} or {help ranwtdttt} model.

{marker options}{...}
{title:Options}

{phang}
{opt nbins(integer)} The number of bins plotted in the
histogram. If not specified it is taken to be the integer part of
min{sqrt(n), 10ln(n)/ln(10)}, where n is the number of observations.{p_end}

{phang}
{opt nq(integer)} Number of points used in plotting the fitted
distribution. The default value is 300.{p_end}

{phang}
{opt replace} Replace current dataset with a dataset
containing the values used to make the plot.{p_end}

{phang}
{opt Graph options} Graph options are allowed which allows
you to control the visual characteristics of the plot. Particularly
useful options include {help ytitle}, {help legend}, {help lpattern}
and {help fcolor}. For a full list of options see
{help twoway options}.{p_end} 

{marker examples}{...}
{title:Examples}

A simple example assessing the fit of a Log-Normal model
{phang}
{cmd:. wtdttt rx1time, disttype(lnorm)}{p_end}
{phang}
{cmd:. wtdtttdiag rx1time}{p_end}

An example with a reverse WTD based on a Weibull distribution and
where data used in the plot replace the current dataset in Stata's
memory:

{phang}
{cmd:. wtdttt rx1time, reverse disttype(wei) iadpercentile(0.8)}{p_end}
{phang}
{cmd:. wtdtttdiag rx1time, replace}{p_end}

Further examples are provided in the example do-file
{it:wtdttt_ex.do}, which contains analyses based on the datafile
{it:wtddat.dta} - a simulated dataset, which is also enclosed.

{title:Author}

{pstd}Katrine Bødkergaard Nielsen, Aarhus University, kani@ph.au.dk.

{pstd}Henrik Støvring, Aarhus University, stovring@ph.au.dk.

