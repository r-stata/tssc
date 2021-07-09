{smcl}
{* 21aug2017/31aug2017}{...}
{cmd:help extrdate}
{hline}

{title:Title}

{phang}
{cmd:extrdate} {hline 2} Generate date or time component from date-time
variable


{title:Syntax}

{p 4 8 2}{cmd:extrdate} {it:component} {it:newvar} {cmd:=} {it:datevar}
{ifin},{break}  
[ 
{opt d:ryrun} 
{opt f:ormat(format)} 
{opt varlabel(variable label)} ] 


{title:Description}

{pstd}
{cmd:extrdate} is for generating a new Stata numeric variable
{it:newvar} extracting a date or time component from an existing
date-time variable {it:datevar} containing date or date-time or time
information. 

{pstd} 
The subcommand {it:component} is required and should be one of 

    {opt s:s}                  seconds 
    {opt mm}                  minutes 
    {opt hh}                  hours 
    {opt dow}                 day of week 
    {opt da:y}                 day of month 
    {opt doy}                 day of year 
    {opt w:eek}                week of year 
    {opt mo:nth}               month of year 
    {opt q:uarter}             quarter of year 
    {opt ha:lfyear}            halfyear of year 
    {opt y:ear}                year 

{pstd} 
Any umambiguous abbreviation is allowed, down to single letters. 


{title:Remarks} 

{pstd} 
{cmd:extrdate} relies exclusively on the display format of {it:datevar}
to indicate its date-time type. Note that in particular the difference
between {cmd:Clock} and {cmd:clock} is so inferred and the appropriate
function to use is automated thereby. 

{pstd} 
{cmd:extrdate} is just a wrapper for the corresponding Stata function as
given by the full name in the list above, except that 

{p 8 8 2}{cmd:extrdate} will use {cmd:ssC()}, {cmd:mmC()} or {cmd:hhC()}
rather than {cmd:ss()}, {cmd:mm()} or {cmd:hh()} whenever it detects a
variable formatted {cmd:%tC} rather than {cmd:%tc}. 

{p 8 8 2}{cmd:extrdate} will map dates for periods longer than days to
daily dates before attempting to apply any of the other functions. 

{pstd}
Note that {cmd:extrdate} does no more. For example, suppose you want to
convert a time 11:22:33 to the equivalent in some other units, say
hours, minutes or seconds. All that {cmd:extrdate} will do is apply
whichever of {cmd:hh}, {cmd:mm}, {cmd:ss} you specify. It will not
change units for you. 

{pstd}
Use of {cmd:extrdate} requires understanding of how Stata holds dates and 
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
2012a, 2012b). 


{title:Options} 

{phang}
{opt d:ryrun} indicates that results of the conversion should be shown
without generating a new variable. Results are listed to show at most no
more than 5 non-missing values of the implied new variable, and no more
than 20 missing values, depending on which condition is satisfied first. 
This dry run should allow the user to check assumptions about the
values of {it:datevar} and/or to see the results of a
particular format, whether default or specified. 

{phang}
{opt f:ormat()} specifies a format other than the default. This option
is rarely used, as almost all results of this command are variables
containing relatively small integers,  the exception being possibly results in
seconds. 

{phang}
{opt varlabel()} specifies a variable label to override the default. 


{title:Examples}

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. set obs 3}

{p 4 8 2}{cmd:. * first examples: date-time variable }{p_end}
{p 4 8 2}{cmd:. gen str42 whatever = "1952 03 28 02:00:00"}{p_end}
{p 4 8 2}{cmd:. replace whatever = "1999 12 31 23:59:59.999" in 2}{p_end}
{p 4 8 2}{cmd:. replace whatever = "2017 08 03 15:48:00" in 3}{p_end}
{p 4 8 2}{cmd:. gen double dtime = clock(whatever, "Y M D hms")}{p_end}
{p 4 8 2}{cmd:. format dtime %tc }{p_end}
{p 4 8 2}{cmd:. list}

{p 4 8 2}{cmd:. extrdate y year=dtime , dryrun}{p_end}
{p 4 8 2}{cmd:. extrdate hh hh=dtime , dryrun}{p_end}
{p 4 8 2}{cmd:. extrdate ss ss=dtime , dryrun}{p_end}
{p 4 8 2}{cmd:. extrdate doy doy=dtime, dryrun}

{p 4 8 2}{cmd:. * second examples: daily date variable}{p_end}
{p 4 8 2}{cmd:. gen mydate = mdy(3, 28, 2017)}{p_end}
{p 4 8 2}{cmd:. replace mydate = mdy(12, 31, 2016) in 1}{p_end}
{p 4 8 2}{cmd:. replace mydate = mdy(8, 21, 2017) in 3}{p_end}
{p 4 8 2}{cmd:. format mydate %td}

{p 4 8 2}{cmd:. extrdate y Year=mydate, dryrun}{p_end}
{p 4 8 2}{cmd:. extrdate ha Half=mydate, dryrun}{p_end}
{p 4 8 2}{cmd:. extrdate q Quar=mydate, dryrun}{p_end}
{p 4 8 2}{cmd:. extrdate mo Mont=mydate, dryrun}{p_end}
{p 4 8 2}{cmd:. extrdate doy Doy=mydate, dryrun}{p_end}

{p 4 8 2}{cmd:. extrdate y Year=mydate}{p_end}
{p 4 8 2}{cmd:. extrdate ha Half=mydate}{p_end}
{p 4 8 2}{cmd:. extrdate q Quar=mydate}{p_end}
{p 4 8 2}{cmd:. extrdate mo Mont=mydate}{p_end}
{p 4 8 2}{cmd:. extrdate doy Doy=mydate}

{p 4 8 2}{cmd:. list mydate Year Half Quar Mont Doy}{p_end}
{p 4 8 2}{cmd:. describe}{p_end}

{p 4 8 2}{cmd:. * third examples: quarterly date variable}{p_end}
{p 4 8 2}{cmd:. webuse turksales, clear}{p_end}
{p 4 8 2}{cmd:. extrdate y y=t , dryrun}{p_end}
{p 4 8 2}{cmd:. extrdate q q=t , dryrun}{p_end}
{p 4 8 2}{cmd:. extrdate mo m=t , dryrun}

       
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
Cox, N.J. 2012b. 
Stata tip 111: More on working with weeks, erratum. 
{it:Stata Journal} 12(4): 765. 


{title:Also see}

{p2colset 5 35 37 2}{...}
{synopt: {bf:{help numdate}}}Generate numeric date-time variable{p_end}
{synopt: {bf:{help convdate}}}Generate variable of other date-time type{p_end}

{synopt: {bf:{help datetimes:[D] datetimes}}}Date and time values and variables
{p_end}
{synopt:{bf:{help datetime_display_formats:[D] datetime display formats}}}Display
       formats for dates and times
{p_end}
{synopt: {bf:{help datetime_translation:[D] datetime translation}}}String to
     numeric date translation functions
{p_end}
{p2colreset}{...}

