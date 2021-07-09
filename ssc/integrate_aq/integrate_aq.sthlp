{smcl}
{* *! version 1.0 16 Jul 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "integrate_aq##syntax"}{...}
{viewerjumpto "Description" "integrate_aq##description"}{...}
{viewerjumpto "Options" "integrate_aq##options"}{...}
{viewerjumpto "Remarks" "integrate_aq##remarks"}{...}
{viewerjumpto "Examples" "integrate_aq##examples"}{...}
{title:Title}
{phang}
{bf:integrate_aq} {hline 2}  Adaptive Gaussian quadrature for a one dimensional integrand

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:integrate_aq}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt l:ower(#)}}  specifies the lower limit of the integral. Default value is -1.{p_end}
{synopt:{opt u:pper(#)}}  specifies the upper limit of the integral. Default value is 1.{p_end}
{synopt:{opt f:unction(string)}}  specifies the function to be integrated, this must be a function of x. {p_end}
{synopt:{opt q:uadpts(#)}}  specifies the number of quadrature points. Default value ist 80.{p_end}
{synopt:{opt v:ectorise}}  specifies the function needs to be vectorised. {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:integrate_aq} is an implementation of Gaussian adaptive quadrature, indefinite integrals
are handled by using transformations onto a definite integral. Infinity limits are
represented by a full stop . The adaptive quadrature splits any single integral, into 
two integrals, at the mid point. If the two integrals is not close to the overall integral
then the sub integrals are split further. By doing the sub-integrals there is some
measurement of the error in the integral. Occasionally some integrands can require many sub-integrals
and this can take a long time to get an answer and will likely result in a large error.

{pstd}
This command has been primarily written in the MATA language but is a Stata command. The function can be
 any single line
expression and the integration is with respect to x. The text from the option function()
will be used to create a new function in Mata which is then passed to the integration algorithm.

{pstd}
The number of quadrature points can be chosen to be any number above 1 but the larger this number the slower the algorithm.
There is no upper limit because the quadrature points are chosen by calculating the eigenvalues and eigenvectors
of a companion matrix.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt l:ower(#)}  specifies the lower limit of the integral. Default value is -1

{phang}
{opt u:pper(#)}  specifies the upper limit of the integral. Default value is 1

{phang}
{opt f:unction(string)}  specifies the function to be integrated, this must be a function of x. 

{phang}
{opt q:uadpts(int 80)}  specifies the number of quadrature points. 

{phang}
{opt v:ectorise}  specifies the function needs to be vectorised. 


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}

{pstd}
The distribution functions in Mata already accept vectors as arguments so can be used in the function 
directly. The following examples are all standard results that can be obtained using the cumulative distribution functions.

{pstd}
{stata integrate_aq, f(normalden(x)) l(-1) u(1)}

{pstd}
{stata integrate_aq, f(normalden(x)) l(-1.96) u(1.96)}

{pstd}
{stata integrate_aq, f(normalden(x)) l(-1.96) u(.)}

{pstd}
{stata integrate_aq, f(normalden(x)) l(.) u(.)}

{pstd}
An example of a user-defined function would be the polynomial x+x^2+x^3
note that because this function is not defined by the appropriate vector operations
then the option vectorise needs to be used.{p_end}

{pstd}
{stata integrate_aq, f(x+x^2+x^3) v l(-10) u(10)}

{pstd}
A quicker implementation of the same function would be

{pstd}
{stata integrate, f(x+x^2+x^3) l(-10) u(10) v :integrate, f(x:+x:^2+x:^3) l(-10) u(10) } 

{pstd}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(integral)}}  The value of the integral {p_end}{synopt:{cmd:r(error)}}  The size of the error associated with the integral  {p_end}

{title:Author}
{p}

Dr Adrian Mander, MRC Biostatistics Unit, University of Cambridge.

Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}



{title:See Also}
Related commands:

{pstd}
{help integrate} (if installed), install by 
clicking {stata ssc install integrate}
