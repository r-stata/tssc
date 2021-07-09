{smcl}
{* Help file updated 2020-04-21,2010-02-05, 2009-09-15}{...}
{hline}
help for {hi:fracrank}{right:P. Van Kerm (April 2020, February 2010, September 2009)}
{hline}

{title:Title}

{pstd}{hi:fracrank} {hline 2} Fractional ranks


{title:Syntax}

{p 8 15 2}
{cmd:fracrank}
{it:varname} 
[{it:weight}] 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
{cmd:,} {opth g:enerate(newvarname [,replace])}
                  
{p 4 8 2}
  {it:varlist} may contain time-series operators; see {help tsvarlist}.
{p_end}
{p 4 8 2}
{cmd:fweight}, {cmd:aweight}, {cmd:pweight} and {cmd:iweight} are allowed; see help {help weights:weights}.
{p_end}


{title:Description}

{pstd}
{hi:fracrank} generates a new variable filled with the fractional rank of the data in the distribution of {it:varname}.
Fractional ranks are computed using a mid-interval cumulative distribution estimator that ensures that the average
fractional rank is 0.5. See the {browse "http://medim.ceps.lu/stata/sgini.pdf":online manual} for details.
{p_end}


{title:Option}

{phang}
{opth generate(newvar)} fills the new variable {it:newvar} with the estimated fractional ranks. The sub-option {cmd:replace} can be used to replace any already existing variable named {it:newvar}.
{p_end}


{title:Example}

{p 8 12 2}{inp:. fracrank price , gen(rank)}

{p 8 12 2}{inp:. fracrank price , gen(rank , replace) }

{title:Also see}

{psee}
Manual:  {bf:[R] cumul}

{psee}
Online:  {helpb cumul}, {helpb sgini} (if installed)


{title:Author}

{pstd}Philippe Van Kerm, CEPS/INSTEAD, Lux{pstd}Philippe Van Kerm, Luxembourg Institute of Socio-Economic Research (LISER) and University of Luxembourg, philippe.vankerm@liser.luembourg, philippe.vankerm@ceps.lu


{title:Acknowledgments}

{pstd}
This package was originally written for the MeDIM project 
({it:Advances in the Measurement of Discrimination, Inequality and Mobility}) 
supported by the Luxembourg Fonds National de la Recherche (contract FNR/06/15/08) 
and by core funding for CEPS/INSTEAD by the
Ministry of Culture, Higher Education and Research of Luxembourg. 


{* Version 2.0 2009-09-15}
