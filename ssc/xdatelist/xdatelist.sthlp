{smcl}
{.-}
help for {cmd:xdatelist} {right:(Roger Newson)}
{.-}


{title:Creating lists of numeric dates}

{p 8 27}
{cmd:xdatelist ,} {cmdab:f:irst}{cmd:(}{it:string_date1}{cmd:)} {cmdab:l:ast}{cmd:(}{it:string_date2}{cmd:)}
  [ {cmdab:u:nit}{cmd:(}{it:unit}{cmd:)} {cmdab:n:units}{cmd:(}{it:#}{cmd:)}
  {cmdab:s:2}{cmd:(}{it:string_argument}{cmd:)}
  {cmdab:y:cutoff}{cmd:(}{it:#}{cmd:)}
  {cmdab:fo:rmat}{cmd:(}{it:%format}{cmd:)} {cmdab:se:parator}{cmd:(}{it:separator_string}{cmd:)}
  ]

{pstd}
where {it:string_date1} and {it:string_date2} are dates given in string format (as might
appear in quotes in the first argument of the {cmd:date()} function), {it:string_argument} is
a string (as might appear in quotes as the second argument to the {cmd:date()} function), and
{it:unit} may be

{pstd}
{cmd:century}|{cmd:year}|{cmd:quarter}|{cmd:month}|{cmd:week}|{cmd:day}


{title:Description}

{pstd}
{cmd:xdatelist} takes, as input, two string-format dates in {it:string_date1} and {it:string_date2}.
It returns, as output in {cmd:r(numlist)}, a numeric list of dates, starting at the first date and
increasing by steps of a specified size (measured in specified units) while remaining no greater
than the second date. Optionally, {cmd:xdatelist} can also return, in {cmd:r(strlist)}, a list of
the same dates in string format. {cmd:xdatelist} is therefore an extended
version of the {helpb datelist} facility.


{title:Options}

{p 0 4}
{cmd:first(}{it:string_date1}}{cmd:)} is the first date in the list, given in string format,
eg {cmd:first(01Jan2000)}. The string format must be acceptable to the {cmd:date()} function;
see {help dates and times:help for dates and times}.

{p 0 4}
{cmd:last(}{it:string_date2}{cmd:)} is the latest date allowed in the list, given in string format.
All numeric dates in the output list will be no greater than the numeric date implied by {cmd:last()}.

{p 0 4}
{cmd:unit(}{it:unit}{cmd:)} is the unit in which the time between successive dates in the list
is to be measured. If {cmd:unit()} is absent, then {cmd:year} is assumed.

{p 0 4}
{cmd:nunits(}{it:#}{cmd:)} is the number of the units specified by {cmd:unit()} between successive
dates in the list.

{p 0 4}
{cmd:s2(}{it:string_argument}{cmd:)} is the {it:s2} (or {it:mask}) string argument passed to the {cmd:date()}
function for decoding the string dates {cmd:first()} and {cmd:last()};
see {help dates and times:help for dates and times}.
Its value should be a permutation of {hi:D}, {hi:M} and {hi:[##]Y},
eg {hi:"MDY"} or {hi:"DM20Y"}. {hi:##}, if specified, indicates a default century for two-digit
years. For instance, {hi:dm20y} interprets "08/06/55" as 8 June, 2055. If {hi:s2()} is absent,
then it is set by default to {hi:"DMY"}.

{p 0 4}
{cmd:ycutoff(}{it:#}{cmd:)} is the {it:y} numeric argument passed to the {cmd:date()} function
for decoding the string dates {cmd:first()} and {cmd:last()};
see {help dates and times:help for dates and times}. Its value should be
an integer from 1000 to 9998 (but probably 2001 to 2099), specifying the handling of
two-digit years. It denotes the largest year to be returned when a two-digit date is encountered.
If it is absent, and there is no {hi:##} in the {cmd:s2} option, then dates with a two-digit
year are set to missing. This may cause {cmd:xdatelist} to fail.

{p 0 4}
{cmd:format(}{it:%fmt}{cmd:)} specifies that the list of dates in {cmd:r(numlist)} should also be
created in string format, using the specified format, and the resulting list of string dates
returned in the result {cmd:r(strlist)}. If {cmd:format()} is not specified, then {cmd:r(strlist)} is not
returned.

{p 0 4}
{cmd:separator(}{it:separator_string}{cmd:)} specifies a separator string used to separate
the elements of the string-format date list in {cmd:r(strlist)}. If {cmd:format()} is absent, then
{cmd:separator} is ignored. If {cmd:format()} is present and {cmd:separator()} is absent, then
the string dates in {cmd:r(strlist)} are separated by single spaces. The {cmd:separator()} option
may be useful if the date format given by {cmd:format()} generates spaces between parts of a
date.


{title:Remarks}

{pstd}
{cmd:xdatelist} performs a similar task to the {cmd:numlist} command; see help for {helpb nlist}.
It is especially useful when the dates in a list are unequally spaced (in days), as happens
when the dates are corresponding days of regularly-spaced months, quarters, years, or centuries.
{cmd:xdatelist} was originally distributed via {help ssc:SSC} under the name of {helpb datelist},
but this name was adopted under Stata 8 to describe a {helpb numlist} containing dates. The name
{cmd:xdatelist} was then introduced for this program, because {cmd:xdatelist} provides an extended
version of the official Stata {helpb datelist} facility.


{title:Examples}

{p 8 16}{inp:. xdatelist, fi(01Jan1901) la(01Jan2000)}{p_end}

{p 8 16}{inp:. xdatelist, fi(01/01/1999) la(11/01/2000) s2(MDY) unit(month) nunit(2)}{p_end}

{p 8 16}{inp:. xdatelist, fi(01Jan1990) la(01Oct2010) unit(quarter) format(%dDmCY)}{p_end}
{p 8 16}{inp:. return list}{p_end}

{p 8 16}{inp:. xdatelist, fi(01Jan1990) la(01Oct2010) unit(quarter) format(%dD_m_CY) sep(,)}{p_end}
{p 8 16}{inp:. return list}{p_end}


{title:Saved results}

{pstd}
{cmd:xdatelist} saves the following results in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(numlist)}}list of numeric dates{p_end}
{synopt:{cmd:r(strlist)}}list of dates in string format{p_end}
{p2colreset}{...}

{pstd}
If {cmd:format()} is not specified, then {cmd:r(strlist)} is not returned.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 0 10}
{bind: }Manual:  {hi:[R] Functions}, {hi:[D] dates and times}, {hi:[P] numlist}.
{p_end}
{p 0 10}
On-line:  help for {helpb functions}, {help dates and times}, {helpb nlist}, {helpb numlist}, {helpb datelist}
{p_end}
