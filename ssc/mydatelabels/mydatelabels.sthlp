{smcl}
{* 26oct2017}{...}
{hline}
help for {hi:mydatelabels} 
{hline}

{title:Axis labels from changes - usually date or time components}

{p 8 17 2}
{cmd:mydatelabels}
[{it:varname}]
[{it:=exp}]
{cmd:,}
{cmdab:l:ocal(}{it:macname}{cmd:)}
[
{cmdab:f:ormat(}{it:format}{cmd:)} 
{cmdab:s:tart} 
{cmdab:e:nd} 
]

{title:Description}

{p 4 4 2}
{cmd:mydatelabels} generate axis labels with a label every time a 
component (hour, month, year) changes. Its use is best explained by examples, as below.

{title:Remarks} 

{p 4 4 2}
When analysing data as sequential cases which occurred at irregular intervals, 
it can be more informative to those interpreting the graph to have an axis 
(which may be a {help help axis_choice_options:secodary axis}) display the date of the first case for each
hour/month/year etc. By way of example, a clustering of failures may be more usefully interpreted as
between July and September, than as case numbers 73 to 86.
{p_end}

{p 4 4 2}
The idea behind {cmd:mydatelabels} is that you provide it with the date or time variable within a {help datetime_functions:date or time function}. 
Optionally you may also specify the sequence variable to 'map' the change in hour/minute/date to (i.e. whatever numeric variable you are using for your x-axis). 
It will then place the appropriate specification in a local macro which you name. You may then use that
local macro as part of a later {cmd:graph} command. 

{title:Options}

{p 4 8 2}
{cmd:local(}{it:macname}{cmd:)} inserts the option specification in
local macro {it:macname} within the calling program's space.  Hence that
macro will be accessible after {cmd:mydatelabels} has
finished. This is helpful for subsequent use with {help graph} or other
graphics commands. This is a required option. 
{p_end}

{p 4 8 2}
{cmd:format()} specifies a format controlling the labels. see {help datetime_display_formats:date/time formats} along with the examples below.
{p_end}

{p 4 8 2}
{cmd:start} include the first observation in the output. default is to omit the first observation.
{p_end}

{p 4 8 2}
{cmd:end} include the last observation in the output. default is to omit the last observation unless it represents a change in value.
{p_end}

{title:Examples}
{pstd}Setup data{p_end}
{phang2}. {stata set obs 200}{p_end}
{phang2}. {stata gen sequence=_n}{p_end}
{phang2}. {stata gen date = td(#1jan2017#) in 1}{p_end}
{phang2}. {stata replace date = date[_n-1] + int(20*runiform()) in 2/l}{p_end}
{phang2}. {stata format date %td}{p_end}
{phang2}. {stata gen outcome = 0 in 1}{p_end}
{phang2}. {stata replace outcome = outcome[_n-1] + runiform() in 2/l}{p_end}

{pstd}In use:{p_end}
{phang2}. {stata mydatelabels sequence=year(date),local(mymac) start format(%tddd_Mon_CCYY)}{p_end}
{phang2}. {stata twoway line outcome sequence, xaxis(1 2) xlabel(`mymac', angle(30) axis(2)) xtitle("year (by 1st case)",axis(2))}{p_end}
{phang2} data over a shorter period of time, best labeled by 1st case for each quarter of calendar year{p_end}
{phang2}. {stata replace date = date[_n-1] + int(5*runiform()) in 2/l}{p_end}
{phang2}. {stata mydatelabels sequence=ceil(month(date)/3),local(mymac) start format(%tdMon_CCYY)}{p_end}
{phang2}. {stata twoway line outcome sequence, xaxis(1 2) xlabel(`mymac', angle(45) axis(2)) xtitle("",axis(2))}{p_end}


{title:Author}

{p 4 4 2}Brent McSharry, Starship Children's Hospital, Auckland New Zealand {break}
brentm@adhb.govt.nz
{p_end}


{title:Acknowledgments} 
{p 4 4 2}
The concept and some code in this script came from Nick J. Cox's excellent {stata findit mylabels}
{p_end}

{title:Also see}

{p 4 13 2}
Online:  help for {help axis_label_options}
{p_end}
