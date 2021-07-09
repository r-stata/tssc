{smcl}
{hline}
help for {cmd:dtastamp} {right:(Roger Newson)}
{hline}


{title:Store current date and time in dataset characteristics}

{p 8 15}{cmd:dtastamp} [ {cmd:,} {opt df:ormat(format_name)} {opt tf:ormat(format_name)} ]


{title:Description}

{pstd}
{cmd:dtastamp} stores the current date and time in the {help char:dataset characteristics}
{cmd:_dta[datestamp]} and {cmd:_dta[timestamp]}.
This is useful if the user then saves the current dataset to a disk file,
and later wants to know approximately when the file was created.


{title:Options}

{p 4 8 2}
{opt dformat(format_name)} specifies a {help datetime_display_formats:format} to be used for creating the date stamp
from a {help datetime:Stata internal format date numeric value}.
If absent, then it is set to {cmd:%tddd_Mon_CCYY}.

{p 4 8 2}
{opt tformat(format_name)} specifies a {help datetime_display_formats:format} to be used for creating the time stamp
from a {help datetime:Stata internal format datetime/C numeric value}.
If absent, then it is set to {cmd:%tCHH:MM:SS}.


{title:Remarks}

{pstd}
Stata stores creation dates and times in datasets in disk files
(see help for {help dta:file formats dta}),
and displays these dates and times if the user uses the {helpb describe} command.
However, it is not easy for users to access these dates and times for use in their own programs.
{cmd:descgen} allows the user to give the dataset a date stamp and a time stamp in {help char: dataset characteristics},
which the user can later access and use.
In particular, the user may use the {help ssc:SSC} package {helpb xdir}
to create a dataset in memory with one observation for each of a list of disk datasets,
and then use the {help ssc:SSC} package {helpb descgen}
to add variables containing dataset attributes,
using the option {cmd:charlist(datestamp timestamp)}
to create variables containing the date and time stamps.
The packages {helpb xdir} and {helpb descgen} can be downloaded from {help ssc:SSC}.

{pstd}
{cmd:dtastamp} gets the current date and time from the {helpb creturn} results {cmd:c(current_date)} and {cmd:c(current_time)}.
This limits the precision of the time to the nearest second (plus execution delay).


{title:Examples}

{pstd}
Set-up:

{p 16 20}{cmd:. sysuse auto, clear}{p_end}
{p 16 20}{cmd:. describe, full}{p_end}
{p 16 20}{cmd:. char list}{p_end}

{pstd}
The following example saves the default date and time stamps
in the dataset characteristics {cmd:_dta[datestamp]} and {cmd:_dta[timestamp]},
respectively.

{p 16 20}{cmd:. dtastamp}{p_end}
{p 16 20}{cmd:. char list}{p_end}

{pstd}
The following example saves non-default format date and time stamps
in the dataset characteristics {cmd:_dta[datestamp]} and {cmd:_dta[timestamp]},
respectively.

{p 16 20}{cmd:. dtastamp, dformat(%tCCCYY/MM/DD) tformat(%tCHH.MM.SS)}{p_end}
{p 16 20}{cmd:. char list}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[P] char}, {hi:[D] datetime}
{p_end}
{p 4 13 2}
On-line: help for {helpb char}, {helpb datetime}
 {break} help for {helpb xdir}, {helpb descgen} if installed
{p_end}
