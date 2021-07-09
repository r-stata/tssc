{smcl}
{* *! version 1.03  14Mar2013}{...}

{title:Title}

{p 4 8 2}
{cmd:integrate()} {hline 2} Numerical integration of Mata functions

{marker syntax}{...}
{title:Syntax}

{p 4 8 2}
{it:real scalar} {cmd:integrate(}{it:&function()}{cmd:,} {it:real scalar lower}{cmd:,} {it: real scalar upper}  |{cmd:,} {it: real scalar quadpts}{cmd:,} {it: transmorphic xarg}{cmd:)}


{p 4 4 2}
where

{p 7 11 2}
{it:&function()} is the function that is integrated, the first argument of this function will be the unit
of integraion.

{p 7 11 2}
{it:xarg} is an optional argument that is passed to the integrand. 

{p 7 11 2}
{it:lower} is the lower limit of the integral, a "." value represents -infinity

{p 7 11 2}
{it:upper} is the upper limit of the integral, a "." value represents +infinity

{p 7 11 2}
{it:quadpts} specifies the number of quadrature points used in the numerical integration; the default is 60.

{marker description}{...}
{title:Description}

{pstd}
{cmd:integrate} is an implementation of three numerical integration algorithms: Gauss-Legendre quadrature; Gauss-Hermite quadrature
; and Gauss-Laguerre. Gauss-Legendre quadrature is used for the definite integrals, Gauss-Hermite quadrature is used for 
the indefinite integral between -infinity and +infinity; and Gauss-Laguerre quadrature is used for the indefinite integral is 
between 0 and +infinity. Any limits can be chosen and the command will select a combination of quadrature techniques to 
calculate the result. The current command does not attempt to look at numerical errors but the user can alter the number of quadrature
points to inspect any numerical instabilities.

{pstd}
The number of quadrature points can be chosen to be any number above 1 but the larger this number the slower the algorithm.
There is no upper limit because the quadrature points are chosen by calculating the eigenvalues and eigenvectors
of a companion matrix. 

{marker examples}{...}
{title:Examples}

{title:Single integration}
{pstd}
Below we use the integrate() function to evaluate the integration of x between -1 and 1:

{it}
    real rowvector f1(real rowvector x)
    {
      return(x)
    }

{sf}
{pstd}
Then to integrate this function type

{it}
    : integrate(&f1(), -1, 1)
    2.27336e-15

{sf}
{pstd}
The analytical solution is 0 and given this is a numerical evaluation the answer is a very small number. In fact this
accuracy cannot be improved by increasing the quadrature points as this is the accuracy of adding numbers.

{title:Double integration}

{pstd}
The integrate function can handle double integrals but will become increasingly more computer intensive with each additional integral.
Double integration will square the number of operations. As an example integrate the function {hi: x+y}
with respect to x and then y over the unit square.

{it}
    real rowvector fin(real rowvector x, real rowvector y)
    {
      return(x:+y)
    }
    real rowvector fout(real rowvector y)
    {
      for(i=1; i<=cols(y);i++) {
        if (i==1) f=integrate(&fin(), -1, 1, 40, y[i])
        else f = f, integrate(&fin(), -1, 1, 40, y[i])
      }
      return(f)
    }

{sf}
{pstd}
Note that the integrate function {hi:requires} the integrand to return a rowvector, however, integrate() only 
returns a real scalar. The function fout() above loops over the elements of y and 
produces the integration with respect to x for each value of y and then returns these multiple elements as
a rowvector. Note that because fin() requires two arguments the integrate() function requires
five arguments including the number of quadrature points specified as 40.
To evaluate the integral type the following

{it}
    : integrate(&fout(), -1, 1)
      -1.14925e-16

{sf}
{pstd}
Again the answer is very close to 0.

{title:Double integration extension}

{pstd}
The last example is one where the upper limit of the inner integral is a function of y. The integral to
be evaluates is the integration from 0 to 2 with respect to y of the integral from 0 to y^2 of 6xy with respect to
x. The example follows the same as the first double integral with the exception in the fout2() function that the
upper limit is y[i]^2.

{it}
    real rowvector fin2(real rowvector x, real rowvector y)
    {
      return(6:*x:*y)
    }
    real rowvector fout2(real rowvector y)
    {
      for(i=1; i<=cols(y);i++) {
        if (i==1) f=integrate(&fin2(), 0, y[i]^2, 40, y[i])
        else f = f, integrate(&fin2(), 0, y[i]^2, 40, y[i])
      }
      return(f)
    }

{sf}
{pstd}
This example was chosen because it is easy to confirm analytically that the answer is 32. The following 
command shows that the integrate gets the correct answer

{it}
    : integrate(&fout2(), 0, 2)
      32

{sf}

{title:Author}

{p}
Adrian Mander, MRC Biostatistics Unit, Cambridge, UK.

Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}

