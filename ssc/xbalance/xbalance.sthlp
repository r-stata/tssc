{smcl}
{hline}
help for {cmd:xbalance}
{hline}

{title:STANDARDIZED DIFFERENCES FOR STRATIFIED COMPARISONS}

{p 8 21 2}
{cmd:xbalance} {it:treatement} {it:strata} {it:varlist}

{title:Description}

{pstd} 
Given a treatment variable, a stratifying factor, and covariates,
{cmd:xbalance} calculates standardized differences (biases) along each
covariate, with and without the stratification. Also, tests for conditional
independence of the treatment variable and the covariates within strata.
Provides both stratified and unstratified analysis.

{pstd}
In the unstratified case, the standardized difference of
covariate means is the mean in the treatment group minus
the mean in the control group, divided by the sd
in the same variable estimated by pooling treatment and control
group sds on the same variable.  In the stratified case, the
denominator of the standardized difference remains the same but
the numerator is a weighted average of within-stratum differences
in means on the covariate.  By default, each stratum is weighted in proportion
to the harmonic mean  of the number of
treated units (a) and control units (b) in the stratum; this weighting is
optimal under certain modeling assumptions (discussed in Kalton 1968,
Hansen and Bowers 2008).

{title:Remarks}

{pstd}
To use xBalance, you must install R, available from CRAN:
{stata:http://cran.r-project.org/} You must also install the RItools package
prior to using. The source and binary code is available via the CRAN repository system for versions of R later than 2.7.0 so installation should simply use (from your R prompt):
 
{p 8 12 2}{cmd: install.packages("RItools")}{p_end}

{pstd}
If you want to install RItools for versions of R more current than 2.2 but earlier than 2.7, you'll have to use: 

{p 8 12 2}{cmd: install.packages("Ritools",type="source",dep=TRUE)}{p_end}
 
{pstd}
If you don't already have the SparseM package installed, you will need the tools required to compile fortran libraries installed in order to build SparseM, specifically gfortran. You should have all the tools you need if you have the full distribution of R (as compared to the "mini" distribution).

{pstd}
After installing RItools, you will need to install the Rsource Stata package.
To install Rsource from SSC:

{p 8 12 2}{stata ssc install rsource}{p_end}

{pstd} 
You must set the global {hi:Rterm_path} prior to running
{cmd:xbalance}. Examples, on Windows and Unix (such as Mac OS X) respectively:

{p 8 12 2}{cmd:.global Rterm_path `"c:\r\R-2.5.0\bin\Rterm.exe"'}{p_end}
{p 8 12 2}{cmd:.global Rterm_path `"/usr/bin/R"'}{p_end}

{pstd}
You may find it convenient to add this to your profile.do.

{title:Examples}

Example using a binary treatment with labels:
{p 8 12 2}{stata sysuse auto}{p_end}
{p 8 12 2}{stata gen price10k=0}{p_end}
{p 8 12 2}{stata replace price10k=1 if price>10000}{p_end}
{p 8 12 2}{stata xbalance foreign price10k mpg rep78 weight length make}{p_end}

Notice that although foreign has labels "Domestic" and "Foreign" in Stata, it becomes coded as "Domestic"=FALSE=0 and "Foreign"=TRUE=1 in R because of a requirement that treatment be either logical (aka binary) or numeric.

Example using a binary treatment without labels:
{p 8 12 2}{stata xbalance price10k foreign mpg}{p_end}

Example using a continuous treatment variable and multiple covariates. Notice that missing values on rep78 receive their own test.
{p 8 12 2}{stata xbalance price foreign mpg rep78 weight length make}{p_end}

An example of a test without stratification.
{p 8 12 2}{stata gen constant=1}{p_end}
{p 8 12 2}{stata xbalance price10k constant foreign mpg rep78}{p_end}

{title:Author}

{pstd} Jake Bowers <jwbowers@illinois.edu>, Mark Fredrickson
<mark.m.fredrickson@gmail.com>, and Ben Hansen <ben.hansen@umich.edu>

{title:Also see}

{p 4 13 2}
On-line help from R.

