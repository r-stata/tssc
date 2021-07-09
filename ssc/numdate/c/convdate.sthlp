{smcl}
{* 17aug2017/1sep2017}{...}
{cmd:help convdate}
{hline}

{title:Title}

     {cmd:convdate} {hline 2} Convert numeric date-time variable, 
                    generating variable of another date-time type 


{title:Syntax}

{p 4 8 2}{cmd:convdate} {it:datetimetype} {it:newdatevar} {cmd:=} {it:datevar} {ifin}{break}  
[ 
{opt d:ryrun} 
{opt f:ormat(format)} 
{opt last} 
{opt varlabel(variable label)}] 


{title:Description}

{pstd}
{cmd:convdate} is for generating a new Stata numeric date-time variable
{it:newdatevar} of specified date-time type from an existing variable
{it:datevar} that is already a numeric date-time variable. For example, you
might want to create a monthly date variable (example display: 2017m8)
from a daily date variable (example display: 1aug2017), or vice versa. 

{pstd} 
The subcommand {it:datetimetype} is required and should be one of 

    {opt c:lock} 
    {opt C:lock} 
    {opt d:aily} 
    {opt d:ate} (a synonym for {cmd:daily})
    {opt w:eekly} 
    {opt m:onthly} 
    {opt q:uarterly} 
    {opt h:alfyearly} or
    {opt y:early}

{pstd} 
(any abbreviation is allowed, down to single letters)

{pstd}
or alternatively one of 

    {cmd:tc}
    {cmd:tC}
    {cmd:td}
    {cmd:tw}
    {cmd:tm}
    {cmd:tq}
    {cmd:th} or 
    {cmd:ty}. 

{pstd}
As specified to {cmd:convdate}, {it:datevar} must be a numeric date-time
variable. The test of that is whether the variable has been assigned a
date-time display format starting with any of the designators from the
list just above. 

{pstd}
For example, suppose you ask for a monthly date to be calculated from 
your variable {cmd:mydate}. {cmd:convdate} looks at the display format
of {cmd:mydate} to determine what conversion function(s) to use. 

{pstd} 
Details: {cmd:"-"} signs indicating left alignment are also accommodated.
Variables holding years are not an exception, regardless of the fact
that formats ending in {cmd:g} or {cmd:f} can work well otherwise for
such variables. 

{pstd}
{cmd:convdate} applies no other test to determine what makes sense: if
in doubt on this or any other grounds, use the {cmd:dryrun} option. 

{pstd}
Fundamentally, going from a finer date-time to a coarser
date-time (e.g. daily to monthly) loses information and that going
from a coarser date-time to a finer date-time (e.g. monthly to daily)
cannot reinstate any detail present in an earlier incarnation of
{it:datevar}. Stata's convention with coarse to fine conversions is to
return the first possible date: for example, the first day in each
month, or the first month in each quarter. The {cmd:last} option of
{cmd:convdate} uses the reverse convention of yielding (in these
examples) the last day of a month or the last month in a quarter. This
option thereby goes beyond what is immediately possible with Stata's
inbuilt functions. 

{pstd} 
{cmd:convdate} automatically generates {cmd:tc}
({cmd:clock}) and {cmd:tC} ({cmd:Clock}) variables as {help double}, as
is necessary to maintain precision. 


{title:Remarks}

{pstd}
Use of {cmd:convdate} requires understanding of how Stata holds dates and 
times: see the help for {help datetime}. A brief summary follows. 

{pstd}
With the exception of calendar years, Stata records dates and date-times
with origin 0 as the start of 1960. For example, for daily dates 0 is 1
January 1960 and 42 is 12 February 1960; for monthly dates 0 is January
1960 and 42 is July 1963; for quarterly dates 0 is the first quarter of
1960 and 42 is the third quarter of 1970. Using numeric variables to
hold dates makes it very easy to sort observations in date order and to
calculate differences between dates. Using what is admittedly an
arbitrary convention is not a real problem for tables or graphs or other
output, as dates can and should be assigned display formats that make
sense. But given Stata's convention of origin at the start of 1960, it is 
often necessary to map variables containing date or time data in other 
form to Stata's numeric date-time variables. 

{pstd}
People interested in weekly dates may be best advised to record weeks in
terms of some convenient daily dates that define them, say their
beginnings, ends, or middles. For detailed discussion, see Cox (2010,
2012a, 2012c). 

{pstd}
A common pitfall is to think that changing the display format will
convert one kind of date-time to another. Only exceptionally will this
produce the right answer, as the underlying numbers will not be changed.
For more, see Cox (2012b). 

{pstd}
{cmd:convdate} does not offer an option for middle dates. The
calculation is either obvious or a little arbitrary. It is left to users
to decide what is adequate for their purposes. Thus day 15 may be good
enough as the middle day in each month, even though months differ in
length: trivially that date is 14 days later than the first day in each
month. An easier example is that the middle month in each quarter
is one after the first month and one before the last month. 


{title:Options} 

{phang}
{opt d:ryrun} indicates that results of the conversion should be shown
without generating a new variable. Results are listed to show at most no
more than 5 non-missing values of the implied date variable, and no more
than 20 missing values, depending on which condition is satisfied first. 
This dry run should allow the user to check assumptions about the
values of {varname} and/or to see the results of a
particular format, whether default or specified. 

{phang}
{opt f:ormat()} specifies a format other than the default for the
particular date-time type. For full details, see help for 
{help datetime_display_formats:datetime display formats}. 

{phang}
{opt last} specifies that the last possible date be used in coarse to fine
conversions, not the first. For example, given a monthly date variable 
and a request to return a daily date variable, the Stata function {cmd:dofm()}, used within {cmd:convdate} for such problems,  
returns the daily date which is the first day of each month. This option
insists on the last day of each month, or more generally the last possible date.

{p 8 8 2}
For application elsewhere, consider this easy example. 
The last day of August 2017 is one day before the first day of September
2017.

{cmd:        . di %td dofm(ym(2017, 8) + 1) - 1}
{cmd:        31aug2017} 

{p 8 8 2}To get there, add 1 to the monthly date; convert to a 
daily date; and then subtract 1 from the daily date. 

{p 8 8 2}Evidently the same trick applies to any month. 
Hence you never need to wrestle with the complications of different
month lengths and whether a year is leap to determine whether the last
day of a month is 28, 29, 30 or 31.  Always use 
{bind:{cmd:dofm(}monthly date + 1{cmd:) - 1}}.  

{p 8 8 2}In general, the rule is that the last possible {it:fine date} 
from a given {it:coarse date} is that before the first possible 
{it:fine date} corresponding to the next {it:coarse date}.  

{phang}
{opt varlabel()} specifies a variable label to override the default. 


{title:Examples}

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. set obs 1}{p_end}

{p 4 8 2}{cmd:. gen double ctest = clock("2015 Mar 28 11:22:33", "YMD hms")}{p_end}
{p 4 8 2}{cmd:. format ctest %tc}{p_end}
{p 4 8 2}{cmd:. convdate daily  c1=ctest}{p_end}
{p 4 8 2}{cmd:. convdate month  c2=ctest}{p_end}
{p 4 8 2}{cmd:. convdate year   c3=ctest}{p_end}

{p 4 8 2}{cmd:. list c*}{p_end}
    
{p 4 8 2}{cmd:. gen dtest = daily("2015mar28", "YMD")}{p_end}
{p 4 8 2}{cmd:. format dtest %td}{p_end}
{p 4 8 2}{cmd:. convdate month  d1=dtest}{p_end}
{p 4 8 2}{cmd:. convdate year   d2=dtest}{p_end}

{p 4 8 2}{cmd:. list d*}{p_end}

{p 4 8 2}{cmd:. gen mtest = monthly("Mar2015", "MY")}{p_end}
{p 4 8 2}{cmd:. format mtest %tm}{p_end}
{p 4 8 2}{cmd:. convdate daily  m1=mtest}{p_end}
{p 4 8 2}{cmd:. convdate daily  m2=mtest, last}{p_end}
{p 4 8 2}{cmd:. convdate year   m3=mtest}{p_end}

{p 4 8 2}{cmd:. list m*}{p_end}

{p 4 8 2}{cmd:. describe}{p_end}

        
{title:Author}

{pstd}Nicholas J. Cox, Durham University, UK{p_end}
{pstd}n.j.cox@durham.ac.uk{p_end}


{title:References} 

{pstd}
Cox, N.J. 2010. Stata tip 68: Week assumptions. 
{it:Stata Journal} 10(4): 682{c -}685.       

{pstd} 
Cox, N.J. 2012a. 
Stata tip 111: More on working with weeks. 
{it:Stata Journal} 12(3): 565{c -}569. 

{pstd}
Cox, N.J. 2012b. Stata tip 113: Changing a variable's format. 
{it:Stata Journal} 12(4): 761{c -}764.                   

{pstd} 
Cox, N.J. 2012c. 
Stata tip 111: More on working with weeks, erratum. 
{it:Stata Journal} 12(4): 765. 


{title:Also see}

{p2colset 5 35 37 2}{...}
{synopt: {bf:{help numdate}}}Generate numeric date-time variable{p_end}
{synopt: {bf:{help extrdate}}}Generate date-time component variable{p_end}

{synopt: {bf:{help datetimes:[D] datetimes}}}Date and time values and variables
{p_end}
{synopt:{bf:{help datetime_display_formats:[D] datetime display formats}}}Display
       formats for dates and times
{p_end}
{synopt: {bf:{help datetime_translation:[D] datetime translation}}}String to
     numeric date translation functions
{p_end}
{p2colreset}{...}

