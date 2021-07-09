{smcl}
{* *! version 11.1 21Mar2011}
{cmd:help linequate}
{hline}

{title:Title}
{phang}
{bf:linequate} {hline 2} Calculates linear equating constants A & B using Tucker and Levine's equal and unequal reliability methods.


{title:Syntax}
{p 8 17 2}
{bf:linequate} {it:anchortest} {it:newtest} {it:oldtest}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
Note: Error variances used in the Levine Methods are estimated using Angoff's method (see Peterson, Cook, & Stocking, 1983). 


{title:Description}
{pstd}
Calculates linear equating constants A & B needed to equate a new test (X) to an old test (Y) using an anchor test.
The linear equating constants are to be applied to transform scores using the following equation: T(x)=Ax+B, 
where x represents the scores to be transformed and T(x) represents the transformed scores. 
This command uses three methods: Tucker, Levine's equal reliability method, and Levine's unequal reliability method 
(see Peterson, Cook, & Stocking, 1983).


{title:Options}
{phang}
{cmd:none} no options are currently available.


{title:Results}
{pstd}
Results are printed in the results window. The equating constants are also stored in the following scalars r(tae), r(tb), r(La), r(Lb),
r(LUa), and r(Lub). The number of observations for each linking group is also printed as Nya (the number of students who took the anchor
and old form of the test), Nxa (the number of students who took the anchor and the new form of the test, and Na (the number of students who took the 
anchor test).

{title:Remarks}
{pstd}
If the application of the formulas for the linear equating constancts involve
imaginary numbers, such as the square root of a negative number, a blank result
will print.


{title:Examples}
{cmd:. example}
linequate anchor testX testY

{cmd:. example score transformation using results from Tucker's method.}
gen testx_on_y=r(ta)*testX+r(tb)

{title:Author}
{pstd}
L.W. McGuire, University of Minnesota-Twin Cities, Educational Psychology, contact: lwmcguir@umn.edu



{title:References}
{pstd}
Petersen, N., Cook, L. & Stocking, M. (1983).
IRT versus Conventional Equating Methods: A Comparative Study of Scale Stability. {it:Journal of Educational Statistics}, {it: 8, 137-156}.


