{smcl}
{* *! version 1.0  8 Aug 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "integrate##syntax"}{...}
{viewerjumpto "Description" "integrate##description"}{...}
{viewerjumpto "Options" "integrate##options"}{...}
{viewerjumpto "Remarks" "integrate##remarks"}{...}
{viewerjumpto "Examples" "integrate##examples"}{...}
{title:Title}
{phang}
{bf:integrate} {hline 2} Numerical integration for one dimensional functions

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:integrate}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt install:mata}}  specifies that the mata code be installed in your personal directory. {p_end}
{synopt:{opt l:ower(#)}}  specifies the lower limit of the integral. Default value is -1.{p_end}
{synopt:{opt u:pper(#)}}  specifies the upper limit of the integral. Default value is 1.{p_end}
{synopt:{opt f:unction(string)}}  specifies the function to be integrated, this must be a function of x. {p_end}
{synopt:{opt q:uadpts(#)}}  specifies the number of quadrature points. Default value is 80.{p_end}
{synopt:{opt v:ectorise}}  specifies the function needs to be vectorised. {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:integrate} is an implementation of Gaussian quadrature. 
The current command does not attempt to look at numerical errors but the user can alter the number of
quadrature points to inspect any numerical instabilities.
Indefinite integrals are handled using transformation within this function.

{pstd}
    This command has been primarily written in the MATA language but is a Stata
    command. The function can be any single line expression and the integration is
    with respect to x. The text from the option function() will be used to create a
    new function in Mata which is then passed to the integration algorithm.

{pstd}
    The number of quadrature points can be chosen to be any number above 1 but the
    larger this number the slower the algorithm.  There is no upper limit because the
    quadrature points are chosen by calculating the eigenvalues and eigenvectors of a
    companion matrix.

{pstd}

{pstd}
{ul:Updating this command using SSC}

{pstd}
To obtain the latest version click the following to install the new version

{pstd}
{stata ssc install integrate,replace}

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt install:mata} lmata specifies that the mata code be installed in your personal directory.

{pstd}
{p_end}

{phang}
{opt l:ower(#)}  specifies the lower limit of the integral. To specify
        that the lower limit is -infinity just specify the missing value . in this
        option.
{p_end}

{phang}
{opt u:pper(#)}  specifies the upper limit of the integral; the default is +1. To specify
        that the upper limit is +infinity just specify the missing value . in this
        option.
{p_end}

{phang}
{opt f:unction(string)}  specifies the function to be integrated. This function needs to
        be defined in terms of x. If the function contains any other unknowns then it
        will crash. The command is much quicker if this function is written in terms
        of vector operations. If the function is written without vector operations
        then the vectorise option needs to be specified and another function is
        constructed that is the vector equivalent of the function (this is slower
        given the extra calculations).
{p_end}

{phang}
{opt q:uadpts(#)}  specifies the number of quadrature points to use in the numerical
        integration; the default is 100. The numerical integration function can allow
        any number of quadrature points but if too many are specified then the
        program will become slow.
{p_end}

{phang}
{opt v:ectorise}  specifies that the function specified in the function() option is not
        defined in terms of vector operators.  The code will generate an additional
        step of creating a new function that allows x as a vector. This involves
        looping over the elements of the rowvector x so will be considerably slower
        but does allow flexibility in the specification of the function.
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
To install the mata code permanently click the following command

{pstd}
 {stata   integrate, installmata}

{pstd}
The distribution functions in Mata already accept vectors as arguments so can be used in the function 
directly. The following examples are all standard results that can be obtained using the cumulative distribution functions.

{pstd}
{stata integrate, f(normalden(x)) l(-1) u(1)}

{pstd}
{stata integrate, f(normalden(x)) l(-1.96) u(1.96)}

{pstd}
{stata integrate, f(normalden(x)) l(-1.96) u(.)}

{pstd}
{stata integrate, f(normalden(x)) l(.) u(.)}

{pstd}
An example of a user-defined function would be the polynomial x+x^2+x^3
note that because this function is not defined by the appropriate vector operations
then the option vectorise needs to be used.{p_end}

{pstd}
{stata integrate, f(x+x^2+x^3) v l(-10) u(10)}

{pstd}
A quicker implementation of the same function would be

{pstd}
{stata integrate, f(x+x^2+x^3) l(-10) u(10) v :integrate, f(x:+x:^2+x:^3) l(-10) u(10) } 

{pstd}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(integral)}}  The value of the integral {p_end}

{title:Author}
{p}

Dr Adrian Mander, MRC Biostatistics Unit, University of Cambridge.

Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}



{title:See Also}
Related commands:

{pstd}
{help integrate_aq} (if installed), install by 
clicking {stata ssc install integrate_aq}

{pstd}
The MATA help file for integrate() {help mf_integrate}.
