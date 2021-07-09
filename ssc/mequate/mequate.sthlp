{smcl}
{* *! version 11.0 30Mar2011}
{cmd:help mequate}
{hline}

{title:Title}
{phang}
{bf:mequate} {hline 2} Calculates equating constants A & B using Mean/Mean and Mean/Sigma Methods under the common-item non-equivalent groups design


{title:Syntax}
{p 8 17 2}
{bf:mequate} {it:formx_a} {it:formx_b} {it:formx_c}{it:formy_a} {it:formy_b} {it:formy_c}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
Note: mequate currently equates forms with dichotomous items only. mequate also assumes that the 3PL models was used. 


{title:Description}
{pstd}
Calculates the equating constants A & B using the Mean/Mean and Mean/Sigma Methods under the common-item non-equivalent
groups design (Kolen & Brennan, 2004). This procedure uses the item parameter estimates a, b, and c, from seperate calibrations
of the 3PL model on each form (x and y). mequate then calculates the equating constants A and B that can be used to transform
form x's scale onto that of form y. As arguments, mequate takes the item parameter estimates from the seperate calibrations of each form.
The item parameter estimates should be arranged in Stata such that each unique item occupies one row. Common items will then have item 
parameter estimates from the form x calibration and the form y calibration in the same row. Items that were only on one form will have
item parameter estimates only in the columns pertaining to that form's calibration. 



{title:Options}
{phang}
{cmd:none} no options are currently available.


{title:Results}
{pstd}
Results are printed in the results window. The equating constants are also stored in the following scalars r(msa), r(msb), r(mma), and r(mmb).
The number of common items is also printed.



{title:Examples}
{cmd:. example}
mequate xa xb xc ya yb yc

{cmd:. example score transformation using results from the Mean/Sigma method.}
gen testx_a_y=xa/`r(msa)'
gen testx_a_y=`r(msa)'*xb+`r(msb)'
gen testx_c_y=xc

{title:Author}
{pstd}
L.W. McGuire, University of Minnesota-Twin Cities, Educational Psychology, contact: lwmcguir@umn.edu



{title:References}
{pstd}
Kolen, M. & Brennan, R. (2004).
{it:Test Equating, Scaling, and Linking}. 


