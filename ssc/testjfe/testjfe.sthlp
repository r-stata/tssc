{smcl}
{* *! version 1.0 17 Nov 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "testjfe##syntax"}{...}
{viewerjumpto "Description" "testjfe##description"}{...}
{viewerjumpto "Options" "testjfe##options"}{...}
{viewerjumpto "Remarks" "testjfe##remarks"}{...}
{viewerjumpto "Examples" "testjfe##examples"}{...}
{title:Title}
{phang}
{bf:testjfe} {hline 2} Test for instrument validity in the judge fixed effects design

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:testjfe}
varlist
(min=3
numeric)
[{help if}]
[{help in}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt numknots(#)}}  specifies the number of knots in a the quadratic spline specification of the relationship between the outcome and the instrument propensity

{pstd}
{p_end}
{synopt:{opt cov:ariates(varlist numeric)}}  specifies variables to be added as linear controls to the regressions calculating instrument propensities and the reduced from regression of outcomes on the instruments

{pstd}
{p_end}
{synopt:{opt cr:ossvalidate}}  specifies that the number of knots should be chosen by cross validation

{pstd}
{p_end}
{synopt:{opt disp:gamma}}  specifies that the reduced form coefficients on the instrument dummies should be displayed

{pstd}
{p_end}
{synopt:{opt fit:weight(#)}}  specifies the relative weight that should be placed on the fit component of the test as opposed to the slope component of the test. For designs with many judges, higher weight on fit will yield a more powerful test.

{pstd}
{p_end}
{synopt:{opt gr:aph}}  specifies that a graph be produced showing judge-level average outcomes by judge-level propensity, with the spline-based fit superimposed.

{pstd}
{p_end}
{synopt:{opt gen:erate(namelist min=3  max=3)}}  specifies that judge-level average outcomes, propensities, and the spline-based fit be generated, and gives the names of the variabgles to be generated. Three variable names are required, in the following order: average outcome, propensity, fit. These variables should not already exist in the data in memory.

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:testjfe} jointly tests the exclusion and monotonicity assumptions invoked in instrumental variables estimation of treatment effects when treatment is a binary indicator and the instruments are a set of mutually exclusive dummy variables. 
Stata command crossfold must be installed.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt numknots(#)}     specifies the number of knots in a the quadratic spline specification of the relationship between the outcome and the instrument propensity

{pstd}
{p_end}
{phang}
{opt cov:ariates(varlist numeric)}     specifies variables to be added as linear controls to the regressions calculating instrument propensities and the reduced from regression of outcomes on the instruments

{pstd}
{p_end}
{phang}
{opt cr:ossvalidate}     specifies that the number of knots should be chosen by cross validation

{pstd}
{p_end}
{phang}
{opt disp:gamma}     specifies that the reduced form coefficients on the instrument dummies should be displayed

{pstd}
{p_end}
{phang}
{opt fit:weight(#)}     specifies the relative weight that should be placed on the fit component of the test as opposed to the slope component of the test. For designs with many judges, higher weight on fit will yield a more powerful test.

{pstd}
{p_end}
{phang}
{opt gr:aph}     specifies that a graph be produced showing judge-level average outcomes by judge-level propensity, with the spline-based fit superimposed.

{pstd}
{p_end}
{phang}
{opt gen:erate(namelist min=3  max=3)}     specifies that judge-level average outcomes, propensities, and the spline-based fit be generated, and gives the names of the variabgles to be generated. Three variable names are required, in the following order: average outcome, propensity, fit. These variables should not already exist in the data in memory.

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
testjfe outcome treatment judgeid*, covariates(x*) fitweight(1) generate(ybar pbar yfit) graph

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(pval)}}  p-value {p_end}
{synopt:{cmd:r(chi2)}}  chi-squared test statistic from the fit component of the test {p_end}
{synopt:{cmd:r(df)}}  degrees of freedom from the fit component of the test {p_end}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(numericalissues)}}  {p_end}


{title:References}
{pstd}

{pstd}
Frandsen, Brigham R., Lars Lefgren, Emily Leslie (2020). Judging Judge Fixed Effects. NBER Working Paper No. 25528.


{title:Author}
{p}

Dr. Brigham Frandsen, Brigham Young University.

Email {browse "mailto:frandsen@byu.edu":frandsen@byu.edu}



{title:See Also}
Related commands:

{help crossfold} (if installed)  {stata ssc install crossfold} (to install this command)

