{smcl}
{* 16 May 2004/16 June 2017}{...}
{hline}
help for {hi:extremes}
{hline}

{title:List extreme values of a variable}

{p 8 17 2}
{cmd:extremes} 
{it:numvar} 
[{it:other_vars}] 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
[
{cmd:,}
{cmd:n(}{it:#}{cmd:)}
{c -(} 
{cmdab:freq:uencies}
{c |} 
{cmd:iqr}[{cmd:(}{it:#}{cmd:)}] 
{c )-} 
{cmdab:hi:gh} 
{cmdab:lo:w} 
{it:list_options} 
]  

{p 4 4 2}
{cmd:by} {it:...}{cmd::} may be used with {cmd:extremes}; see help {help by}.


{title:Description}

{p 4 4 2}{cmd:extremes} lists extreme values of {it:numvar}.  If
{it:other_vars} are also specified, these are also listed for the same
observations. By default, the extremes are the 5 lowest and the 5 highest
values of {it:numvar}. The option {cmd:n()} may be used to change 5 to any
other integer. The option {cmd:iqr}, used with or without an argument, may be
used to select extremes according to their distance from the nearer quartile.
The option {cmd:frequencies} may be used to show the frequencies of distinct
extreme values.  Missing values are ignored. 


{title:Options}

{p 4 8 2}{cmd:n(}{it:#}{cmd:)} specifies a number of values to be shown 
in each tail. {cmd:n} defaults to 5. 

{p 4 8 2}{cmd:frequencies} specifies that frequencies of distinct 
values be shown. That is, imagine the variable treated as discrete 
and shown as a histogram. The table shows the frequencies that would 
be shown as the {cmd:n} leftmost and/or the {cmd:n} rightmost bars 
of the histogram. {it:other_vars} may not be specified with this 
option. 

{p 4 8 2}{cmd:iqr} is short-hand for {cmd:iqr(1.5)}. See just below. 

{p 4 8 2}{cmd:iqr}{cmd:(}{it:#}{cmd:)} specifies use of a rule based on iqr 
(interquartile range) for identifying extremes. That is, calculate  

{p 16 16}(value - upper quartile ) / iqr 

{p 8 8 2}for any values at or above the upper quartile and 

{p 16 16}(value - lower quartile) / iqr 

{p 8 8 2}for any above at or below the lower quartile.  Values will be shown if this
ratio equals or exceeds {it:#} in absolute value. {cmd:iqr(1.5)} corresponds to a
common rule for identifying individual points on box plots. {it:#} may be 
0 or positive. 

{p 4 8 2}{cmd:frequencies} may not be combined with {cmd:iqr} or {cmd:iqr()}. 
 
{p 4 8 2}{cmd:high} specifies that only high values should be shown.

{p 4 8 2}{cmd:low} specifies that only low values should be shown. 

{p 4 8 2}{it:list_options} are options of {help list} other than {cmd:noobs} 
and {cmd:subvarname}. 


{title:Examples}


{p 4 8 2}{cmd:. sysuse auto, clear} 

{p 4 8 2}{cmd:. extremes price make}

{p 4 8 2}{cmd:. extremes price make, iqr}

{p 4 8 2}{cmd:. extremes price make, iqr(3)}

{p 4 8 2}{cmd:. bysort foreign: extremes price make, iqr}


{title:Author} 

{p 4 4 2}Nicholas J. Cox, University of Durham, U.K.{break} 
        n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}This program owes a debt to Michael N. Mitchell's {cmd:hilo}. 
A problem posed by Sylvain Friederich led to tabulation by frequencies. 
David Puddicombe reported a bug. 


{title:Also see}

{p 4 13 2}On-line:  help for {help list}, {help hilo} (if installed), 
{help adjacent} (if installed) 

