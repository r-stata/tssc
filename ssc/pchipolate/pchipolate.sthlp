{smcl}
{* 27 Nov 2012/2 Dec 2012}{...}
{hline}
help for {hi:pchipolate}
{hline}

{title:Piecewise cubic Hermite interpolation}

{p 8 17 2}{cmd:pchipolate} {it:yvar} {it:xvar} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
{cmd:,} {cmdab:g:enerate}{cmd:(}{it:newvar}{cmd:)} 

{p 4 4 2}{cmd:by} {it:...} {cmd::} may be used with {cmd:pchipolate}; 
see help {help by}.


{title:Description}

{p 4 4 2}
{cmd:pchipolate} creates {it:newvar} by averaging non-missing values of
{it:yvar} and using piecewise cubic Hermite interpolation of missing values of
{it:yvar}, given {it:xvar}. That is, provided that {it:xvar} is not
missing, 

{p 4 4 2}1. When {it:yvar} is not missing, {it:newvar} is the mean of
{it:yvar} over observations with the same value of {it:xvar}. If a value
of {it:xvar} is unique, then each mean is just the same as the value of
{it:yvar} at that point. 

{p 4 4 2}2. When {it:yvar} is missing, {it:newvar} is filled in using
piecewise cubic Hermite interpolation. 


{title:Remarks} 

{p 4 4 2}This method is often described informally as "pchip". For a lucid
account, see Moler (2004, Ch.3). Informally, pchip interpolates using piecewise 
cubics that join smoothly, so that both the interpolated function and its first 
derivative are continuous. In addition, the interpolant is shape-preserving 
in the sense that it cannot overshoot locally; sections in which observed {it:yvar} 
is increasing, decreasing or constant with {it:xvar} remain so after interpolation, 
and local extremes (maxima, maxima) also remain so. 

{p 4 4 2}This interpolation method also extrapolates.

{p 4 4 2}The first two examples are based on the help for {help ipolate} in Stata
10.  


{title:Options}

{p 4 8 2}{cmd:generate()} is not optional; it specifies the name of the
new variable to be created.


{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse ipolxmpl1, clear}

{pstd}List the data{p_end}
{phang2}{cmd:. list, sep(0)}

{pstd}Create {cmd:y1} containing an interpolation of {cmd:y} on {cmd:x}
for missing values of {cmd:y}{p_end}
{phang2}{cmd:. pchipolate y x, gen(y1)}

{pstd}Plot the result{p_end}
{phang2}{cmd:. line y1 x || scatter y x} 

{pstd}List the result{p_end}
{phang2}{cmd:. list, sep(0)}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse ipolxmpl2, clear}{p_end}

{pstd}Show years for which the circulation data are missing{p_end}
{phang2}{cmd:. tabulate circ year if circ == ., missing}

{pstd}Create {cmd:pchicirc} containing an interpolation of {cmd:circ} on
{cmd:year} for missing values of {cmd:circ} and perform this calculation
separately for each {cmd:magazine}{p_end}
{phang2}{cmd:. by magazine: pchipolate circ year, gen(pchicirc)}{p_end}

{pstd}Plot the result{p_end}
{phang2}{cmd:. line pchicirc year || scatter circ year, by(magazine)}
    {hline}

    {hline}
{pstd}Moler's example{p_end}
{phang2}{cmd:. clear }{p_end}
{phang2}{cmd:. set obs 6 }{p_end}
{phang2}{cmd:. matrix y = (16, 18, 21, 17, 15, 12)' }{p_end}
{phang2}{cmd:. gen y = y[_n, 1] }{p_end}
{phang2}{cmd:. gen x = _n }{p_end}
{phang2}{cmd:. set obs 61}{p_end}
{phang2}{cmd:. replace x = (_n + 1)/10 in 7/L}{p_end}
{phang2}{cmd:. pchipolate y x, gen(pchip)}{p_end}
{phang2}{cmd:. line pchip x, sort || scatter y x }{p_end}
    {hline}


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break}  
    n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}Most of the Mata code in this program is a translation of 
MATLAB code given by Moler (2004).


{title:References} 

{p 4 8 2}Moler, C. 2004. {it:Numerical Computing with MATLAB.} 
Philadelphia: SIAM. Chapter 3. 
(also available in slightly different form at 
{browse "http://www.mathworks.com/moler/interp.pdf":http://www.mathworks.com/moler/interp.pdf})  


{title:Also see}

{p 4 13 2}Manual:  {hi:[D] ipolate}

{p 4 13 2}On-line:  help for {help ipolate}, 
help for {help cipolate} (if installed), 
help for {help csipolate} (if installed), 
help for {help nnipolate} (if installed) 
