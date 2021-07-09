{smcl}
{* 8 Nov 2012}{...}
{hline}
help for {hi:nnipolate}
{hline}

{title:Nearest neighbour interpolation}

{p 8 17 2}{cmd:nnipolate} {it:yvar} {it:xvar} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
{cmd:,} {cmdab:g:enerate}{cmd:(}{it:newvar}{cmd:)} 
[{cmd:ties(}{it:ties_rule}{cmd:)}] 

{p 4 4 2}{cmd:by} {it:...} {cmd::} may be used with {cmd:nnipolate}; 
see help {help by}.


{title:Description}

{p 4 4 2}
{cmd:nnipolate} creates {it:newvar} by averaging non-missing values of
{it:yvar} and using nearest neighbour interpolation of missing values of
{it:yvar}, given {it:xvar}. That is, provided that {it:xvar} is not
missing, 

{p 4 4 2}1. When {it:yvar} is not missing, {it:newvar} is the mean of
{it:yvar} over observations with the same value of {it:xvar}. If a value
of {it:xvar} is unique, then each mean is just the same as the value of
{it:yvar} at that point. 

{p 4 4 2}2. When {it:yvar} is missing, {it:newvar} is filled in using
nearest neighbour interpolation. As interpolation is with respect to
{it:xvar}, that means the value of the previous known value of {it:yvar}
or the value of the next known value of {it:yvar}, depending on which is
nearer in terms of {it:xvar}. Previous or next mean with lower or higher
values of {it:xvar}. 

{p 4 4 2}3. When previous and next values are equally distant from a known 
value, users have a choice of rules that they may wish applied. By default, 
{cmd:nnipolate} uses the mean of the two values. The {cmd:ties()} option
provides alternative rules.  


{title:Remarks} 

{p 4 4 2}This method is presumably most natural or appealing when the 
underlying pattern of change is step-functional, so that the series being 
interpolated is piecewise constant. 

{p 4 4 2}This interpolation method also extrapolates, as unknown values
before the first known value and unknown values after the last known
value are replaced by those respective known values. 

{p 4 4 2}The examples are based on the help for {help ipolate} in Stata
10 up.  Any Stata 8 or 9 users will need to substitute their own. 

{p 4 4 2}'Neighbour' is the standard spelling in (British) English.
'Neighbor' is the standard spelling in American English. 

{p 4 4 2}{cmd:nnipolate} does not support interpolation in two or more 
dimensions. 


{title:Options}

{p 4 8 2}{cmd:generate()} is not optional; it specifies the name of the
new variable to be created.

{p 4 8 2}{cmd:ties()} specifies an alternative to the default rule whereby
previous and next values equally distant from a given point are averaged. The user may 
choose one of {cmdab:n:ext} (next value is used), {cmdab:p:revious} (previous 
value is used), {cmdab:mi:nimum} (smaller value is used), or {cmdab:ma:ximum} (larger 
value is used). As indicated, any unambiguous abbreviation is allowed. 


{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse ipolxmpl1}

{pstd}List the data{p_end}
{phang2}{cmd:. list, sep(0)}

{pstd}Create {cmd:y1} containing a nearest neighbour interpolation of {cmd:y} on {cmd:x}
for missing values of {cmd:y}{p_end}
{phang2}{cmd:. nnipolate y x, gen(y1)}

{pstd}Use alternative rules for handling ties:{p_end}
{phang2}{cmd:. nnipolate y x, ties(next) gen(ynext)}{p_end}
{phang2}{cmd:. nnipolate y x, ties(prev) gen(yprev)}{p_end}
{phang2}{cmd:. nnipolate y x, ties(max) gen(ymax)}{p_end}
{phang2}{cmd:. nnipolate y x, ties(min) gen(ymin)}

{pstd}List the results{p_end}
{phang2}{cmd:. list, sep(0)}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse ipolxmpl2}{p_end}

{pstd}Show years for which the circulation data are missing{p_end}
{phang2}{cmd:. tabulate circ year if circ == ., missing}

{pstd}Create {cmd:csicirc} containing a nearest neighbour interpolation of {cmd:circ} on
{cmd:year} for missing values of {cmd:circ} and perform this calculation
separately for each {cmd:magazine}{p_end}
{phang2}{cmd:. by magazine: nnipolate circ year, gen(csicirc)}{p_end}
    {hline}


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break}  
    n.j.cox@durham.ac.uk


{title:Also see}

{p 4 13 2}Manual:  {hi:[D] ipolate}

{p 4 13 2}On-line:  help for {help ipolate}, 
help for {help cipolate} (if installed), 
help for {help csipolate} (if installed) 
