{smcl}
{* 14aug2015/17aug2015/18aug2015/19aug2015/20aug2015/9aug2017/1sep2017/12sep2017/25sep2017}{...}
{cmd:help numdate}
{hline}

{title:Title}

{phang}
{cmd:numdate} {hline 2} Generate numeric date-time variable


{title:Syntax}

{p 4 8 2}{cmd:numdate} {it:datetimetype} {it:newdatevar} {cmd:=} {varlist} {ifin},{break}  
{opt p:attern(pattern)}
{break}
[ {opt d:ryrun} {opt f:ormat(format)} {opt t:opyear(topyear)} 
{opt varlabel(variable label)} ] 


{title:Description}

{pstd}
{cmd:numdate} is for generating a new Stata numeric date-time variable
{it:newdatevar} from one or more existing variables {varlist} containing
date or date-time or time information. 

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
As specified to {cmd:numdate}, {varlist} may be string or numeric. For
example, it could be a single string variable containing values
indicating daily dates like {cmd:"2015Mar28"} or quarterly dates like
{cmd:"2015Q2"}. Or, it could be a single numeric variable containing
integers such as {cmd:20150328} which are to be parsed (in this case) as
daily dates. Or, it could be two or more variables, say three variables
indicating day, month, and year for daily dates. 

{pstd}
Whenever any variable within {varlist} is numeric, its contents are
treated by {cmd:numdate} on the fly as string values. 


{title:Remarks} 

{pstd}
Use of {cmd:numdate} requires understanding of how Stata holds dates and 
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
{cmd:numdate} does this, and more. By default it applies a minimal
appropriate display format. It also automatically generates {cmd:tc}
({cmd:clock}) and {cmd:tC} ({cmd:Clock}) variables as {help double}, as
is necessary to maintain precision. It also allows users a dry run, to
test assumptions about the structure of the data. 

{pstd}
People interested in weekly dates may be best advised to record weeks in
terms of some convenient daily dates that define them, say their
beginnings, ends, or middles. For detailed discussion, see Cox (2010,
2012a, 2012b). 

{pstd}
For the converse problem of generating a string variable containing date
information, consider using {cmd:generate} {it:sdatevar} 
{cmd:= string(}{it:newdatevar}{cmd:, "}{it:date_format}{cmd:")} or
alternatively {help tostring} with date format explicit. 


{title:More remarks: What if numdate disappoints?} 

{pstd} 
When {cmd:numdate} works as you expect, you can be happy. When it does not, 
then you need to know more about how it should work and what else you can do. 

{pstd} 
The main idea of {cmd:numdate} is to serve as a wrapper for whichever function 
out of 

    {cmd:clock()} 
    {cmd:Clock()} 
    {cmd:daily()} 
    {cmd:weekly()} 
    {cmd:monthly()} 
    {cmd:quarterly()} 
    {cmd:halfyearly()} or
    {cmd:yearly()}

{pstd}
is appropriate for generating a new date variable. However, these functions are not equally smart. Thus, note that for example 

{p 4 8 2}{cmd:. di monthly("20-09-17 11:22:33", "DM20Yhms")}

{pstd}
just yields missing, as {cmd:monthly()} 
is not smart enough to ignore irrelevant detail. Short of adding work-arounds, 
this can be considered a limitation of {cmd:numdate}. 

{pstd}
Experience is that this bites most often with generation of coarse dates from fine information. The positive advice to to use {help convdate}, part of the 
same package. The following examples illustrates some technique.  

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. set obs 1}{p_end}
{p 4 8 2}{cmd:. gen sandbox = "20-09-17 11:22:33"}{p_end}
{p 4 8 2}{cmd:. numdate clock call_end_c = sandbox, pattern(DM20Yhms) varlabel("Time of Call closure")}{p_end}
{p 4 8 2}{cmd:. convdate daily call_end_d = call_end_c, varlabel("Date of Call closure")}{p_end}
{p 4 8 2}{cmd:. convdate monthly call_end_m = call_end_c, varlabel("Month/Year of Call closure")}{p_end}
{p 4 8 2}{cmd:. convdate yearly call_end_y = call_end_c, varlabel("Year of Call closure")}

{pstd}In short, consider using {cmd:numdate} to generate the first date variable and 
then {help convdate} to convert that to other dates. 


{title:Options} 

{phang}
{opt p:attern()} specifies a pattern indicating the date-time elements of
date or date-time values. It is a required option. Details here are
based on the help for {help datetime_translation:datetime translation}. 

{pmore}
The {it:pattern} specifies the order of the date and time components and is
a string composed of a sequence of these elements:

	    Code  {c |} Meaning
	    {hline 6}{c +}{hline 39}
             {cmd:Y}    {c |} 4-digit year
	     {cmd:19Y}  {c |} 2-digit year to be interpreted as 19{it:xx}
             {cmd:20Y}  {c |} 2-digit year to be interpreted as 20{it:xx}
             {cmd:H}    {c |} half-year number  (half-yearly dates only)
             {cmd:Q}    {c |} quarter number    (quarterly dates only)
             {cmd:M}    {c |} month
             {cmd:W}    {c |} week number       (weekly dates only)
             {cmd:D}    {c |} day within month
                  {c |}
             {cmd:h}    {c |} hour of day
             {cmd:m}    {c |} minutes within hour 
             {cmd:s}    {c |} seconds within minute
                  {c |}
             {cmd:#}    {c |} ignore one element 
	    {hline 6}{c BT}{hline 39}

{pmore}
For dates from weekly to half-yearly, a pair of numbers to be translated {c -}
one giving the year and the other the week, month, quarter or half-year {c -}
shoud ideally be separated by a space or punctuation. Note that symbols such as
{cmd:w}, {cmd:m}, {cmd:q}, or {cmd:h} are acceptable punctuation.  Whenever
{varlist} consists of two or more variables, {cmd:numdate} respects this
automatically by combining values from different variables together with
intervening spaces.  Otherwise no extra characters are allowed.  

{pmore}
For dates from weekly to half-yearly that are run together, such as 20153 or 
"20153", an attempt is made to parse into year and other parts. It is 
especially advisable to use the {cmd:dryrun} option to check whether the 
parsing was done correctly. 

{pmore}
For clock and daily dates or date-times, blanks are also allowed in {it:pattern}, which
can make the {it:pattern} easier to read, but they otherwise have no
significance.

{pmore}
Examples of {it:pattern}s include

{p 12 23 2}
{cmd:"MDY"}{bind:      }{varlist}
contains month, day, and year, in that order.

{p 12 23 2}
{cmd:"MD19Y"}{bind:    }means the same as {cmd:"MDY"} except that 
{varlist} may contain two-digit years, and when it does, 
they are to be treated as if they are 4-digit years beginning with 19.

{p 12 23 2}
{cmd:"MDYhms"}{bind:   }{varlist}
contains month, day, year, hour, minute, and second, in that order.

{p 12 23 2}
{cmd:"MDY hms"}{bind:  }means the same as {cmd:"MDYhms"}; the blank has no
meaning.
  
{p 12 23 2} 
{cmd:"MDY#hms"}{bind:  }means that one element between the year and
the hour is to be ignored.  For example, {varlist} contains values like
{cmd:"1-1-2010 at 15:23:17"} or values like {cmd:"1-1-2010 at 3:23:17 PM"}.

{phang}
{opt d:ryrun} indicates that results of the conversion should be shown
without generating a new variable. Results are listed to show at most no
more than 5 non-missing values of the implied date variable, and no more
than 20 missing values, depending on which condition is satisfied first. 
This dry run should allow the user to check assumptions about the
structure of values of {varlist} and/or to see the results of a
particular format, whether default or specified. 

{phang}
{opt f:ormat()} specifies a format other than the default for the
particular date-time type. For full details, see help for 
{help datetime_display_formats:datetime display formats}. 

{phang}
{opt t:opyear()} specifies a "top year" when two-digit years are 
supplied. The explanation here is based on that in 
{help datetime_translation:datetime translation}. 

{pmore}
What if our data include 01-12-06 14:22 and also   15-06-98 11:01?  We
want to interpret the first year as 2006 and the second year as 1998.
When you specify {it:topyear}, you are stating that when years in
{varlist} are two digits, so the full year is to be obtained by finding the
largest year that does not exceed {it:topyear}.  Thus with
{cmd:topyear(2020)} the two-digit year 06 would be interpreted as 2006
because 2006 does not exceed 2020.  The two-digit year 98 would be
interpreted as 1998 because 2098 does exceed 2020.

{phang}
{opt varlabel()} specifies a variable label to override the default. 


{title:Examples}

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. set obs 1}{p_end}

{p 4 8 2}clock date-times:{p_end}
{p 4 8 2}{cmd:. gen ctest1 = "2015 Mar 28 11:22:33"}{p_end}
{p 4 8 2}{cmd:. gen ctest2 = "20152803112233"}{p_end}
{p 4 8 2}{cmd:. gen double ctest3 = 20152803112233 }{p_end}
{p 4 8 2}{cmd:. format ctest3 %20.0f }{p_end}

{p 4 8 2}{cmd:. numdate clock c1 = ctest1, pattern(YMDhms)}{p_end}
{p 4 8 2}{cmd:. numdate clock c2 = ctest2, pattern(YDMhms)}{p_end}
{p 4 8 2}{cmd:. numdate clock c3 = ctest3, pattern(YDMhms)}{p_end}

{p 4 8 2}daily dates:{p_end}
{p 4 8 2}{cmd:. gen dtest1 = "2015mar28"}{p_end}
{p 4 8 2}{cmd:. gen dtest2 = "mar2815"}{p_end}
{p 4 8 2}{cmd:. gen long dtest3 = 20152803}{p_end}

{p 4 8 2}{cmd:. numdate daily d1 = dtest1, pattern(YMD) dryrun}{p_end}
{p 4 8 2}{cmd:. numdate daily d1 = dtest1, pattern(YMD)}{p_end}
{p 4 8 2}{cmd:. numdate daily d2 = dtest2, pattern(MDY) topyear(2050) dryrun}{p_end}
{p 4 8 2}{cmd:. numdate daily d2 = dtest2, pattern(MDY) topyear(2050)}{p_end}
{p 4 8 2}{cmd:. numdate daily d3 = dtest3, pattern(YDM) dryrun}{p_end}
{p 4 8 2}{cmd:. numdate daily d3 = dtest3, pattern(YDM)}{p_end}

{p 4 8 2}monthly dates:{p_end}
{p 4 8 2}{cmd:. gen mtest1 = "Mar2015"}{p_end}
{p 4 8 2}{cmd:. gen mtest2 = "2015 3"}{p_end}
{p 4 8 2}{cmd:. gen mtest3 = "20153"}{p_end}

{p 4 8 2}{cmd:. numdate monthly m1 = mtest1, pattern(MY) dryrun}{p_end}
{p 4 8 2}{cmd:. numdate monthly m1 = mtest1, pattern(MY)}{p_end}
{p 4 8 2}{cmd:. numdate monthly m2 = mtest2, pattern(YM) dryrun}{p_end}
{p 4 8 2}{cmd:. numdate monthly m2 = mtest2, pattern(YM)}{p_end}
{p 4 8 2}{cmd:. numdate monthly m3 = mtest3, pattern(YM) dryrun}{p_end}
{p 4 8 2}{cmd:. numdate monthly m3 = mtest3, pattern(YM)}{p_end}

{p 4 8 2}quarterly dates:{p_end}
{p 4 8 2}{cmd:. gen qtest1 = "2015q4"}{p_end}
{p 4 8 2}{cmd:. gen qtest2 = "2015 4"}{p_end}

{p 4 8 2}{cmd:. numdate quarterly q1 = qtest1, pattern(YQ) dryrun}{p_end}
{p 4 8 2}{cmd:. numdate quarterly q1 = qtest1, pattern(YQ)}{p_end}
{p 4 8 2}{cmd:. numdate q q2 = qtest2, pattern(YQ) dryrun format(%tqY_q)}{p_end}
{p 4 8 2}{cmd:. numdate q q2 = qtest2, pattern(YQ) format(%tqY_q)}{p_end}

{p 4 8 2}date information in several variables:{p_end}
{p 4 8 2}{cmd:. gen s1test1 = 2015}{p_end}
{p 4 8 2}{cmd:. gen s1test2 = 3}{p_end}
{p 4 8 2}{cmd:. gen s1test3 = 28}{p_end}

{p 4 8 2}{cmd:. numdate td s1date = s1test1 s1test2 s1test3, pattern(YMD)}{p_end}

{p 4 8 2}{cmd:. gen s2test1 = 2015}{p_end}
{p 4 8 2}{cmd:. gen s2test2 = 3}{p_end}

{p 4 8 2}{cmd:. numdate tq s2date = s2test1 s2test2, pattern(YQ)}{p_end}

{p 4 8 2}{cmd:. list c* }{p_end}
{p 4 8 2}{cmd:. list d*  }{p_end}
{p 4 8 2}{cmd:. list m* }{p_end}
{p 4 8 2}{cmd:. list q* }{p_end}
{p 4 8 2}{cmd:. list s1* }{p_end}
{p 4 8 2}{cmd:. list s2* }{p_end}

        
{title:Author}

{pstd}Nicholas J. Cox, Durham University, UK{p_end}
{pstd}n.j.cox@durham.ac.uk{p_end}


{title:Acknowledgments} 

{pstd}Discussions with William Gould and Robert Picard were stimulating 
and helpful. Rasool Baloch kindly reported a bug. Marc Kaulisch posted an 
example which led to "More remarks" above. 


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
{synopt: {bf:{help convdate}}}Generate variable of other date-time type{p_end}
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


 

