{smcl}
{hline}
help for {hi:regaxis} and {hi:logaxis}{right:(Roger Newson)}
{hline}

{title:Regular linear and logarithmic axis scales, ranges and tick lists}

{p 8 15 2}
{cmd:regaxis}
[ {it:varlist} ]
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,}
{cmdab:inc:lude}{cmd:(}{it:numlist}{cmd:)} {cmdab:maxt:icks}{cmd:(}{it:#}{cmd:)}
{cmdab:sin:gleok}
{break}
{cmdab:cy:cle}{cmd:(}{it:#}{cmd:)} {cmdab:ph:ases}{cmd:(}{it:numlist}{cmd:)}
{cmdab:mar:gins}{cmd:(}{it:marginlist}{cmd:)}
{break}
{cmdab:pcr:atios}{cmd:(}{it:numlist}{cmd:)} {cmdab:mcr:atios}{cmd:(}{it:marginratiolist}{cmd:)}
{cmdab:cb:ase}{cmd:(}{it:#}{cmd:)} {cmdab:cpp:ower}{cmd:(}{it:#}{cmd:)}
{break}
{cmdab:lra:nge}{cmd:(}{it:macname}{cmd:)} {cmdab:lti:cks}{cmd:(}{it:macname}{cmd:)}
{cmdab:lrmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:lrma:x}{cmd:(}{it:macname}{cmd:)}
{cmdab:ltmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:ltma:x}{cmd:(}{it:macname}{cmd:)}
{cmdab:lnti:ck}{cmd:(}{it:macname}{cmd:)}
{cmdab:lvmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:lvma:x}{cmd:(}{it:macname}{cmd:)}
{break}
{cmdab:gra:nge}{cmd:(}{it:macname}{cmd:)} {cmdab:gti:cks}{cmd:(}{it:macname}{cmd:)}
{cmdab:grmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:grma:x}{cmd:(}{it:macname}{cmd:)}
{cmdab:gtmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:gtma:x}{cmd:(}{it:macname}{cmd:)}
{cmdab:gnti:ck}{cmd:(}{it:macname}{cmd:)}
{cmdab:gvmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:gvma:x}{cmd:(}{it:macname}{cmd:)}
]

{p 8 15 2}
{cmd:logaxis}
[ {it:varlist} ]
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,}
{cmdab:inc:lude}{cmd:(}{it:numlist}{cmd:)} {cmdab:maxt:icks}{cmd:(}{it:#}{cmd:)}
{cmdab:sin:gleok}
{break}
{cmdab:b:ase}{cmd:(}{it:#}{cmd:)} {cmdab:s:calefactors}{cmd:(}{it:numlist}{cmd:)}
{cmdab:mar:ginfactors}{cmd:(}{it:marginfactorlist}{cmd:)}
{break}
{cmdab:lra:nge}{cmd:(}{it:macname}{cmd:)} {cmdab:lti:cks}{cmd:(}{it:macname}{cmd:)}
{cmdab:lrmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:lrma:x}{cmd:(}{it:macname}{cmd:)}
{cmdab:ltmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:ltma:x}{cmd:(}{it:macname}{cmd:)}
{cmdab:lnti:ck}{cmd:(}{it:macname}{cmd:)}
{cmdab:lvmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:lvma:x}{cmd:(}{it:macname}{cmd:)}
{break}
{cmdab:gra:nge}{cmd:(}{it:macname}{cmd:)} {cmdab:gti:cks}{cmd:(}{it:macname}{cmd:)}
{cmdab:grmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:grma:x}{cmd:(}{it:macname}{cmd:)}
{cmdab:gtmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:gtma:x}{cmd:(}{it:macname}{cmd:)}
{cmdab:gnti:ck}{cmd:(}{it:macname}{cmd:)}
{cmdab:gvmi:n}{cmd:(}{it:macname}{cmd:)} {cmdab:gvma:x}{cmd:(}{it:macname}{cmd:)}
]

{p 4 4 2}
where {it:marginlist} is a list of up to 2 non-negative numbers,
{it:marginratiolist} is a list of up to 2 non-negative numbers,
and {it:marginfactorlist} is a list of up to 2 positive numbers equal to or greater than 1.


{title:Description}

{p 4 4 2}
{cmd:regaxis} generates a regular linear axis range and tick list for a list of variables and/or numbers
to be included in the axis range.
{cmd:logaxis} generates a regular logarithmic axis range and tick list for a list of variables and/or numbers
to be included in the axis range.
Both programs can output the elements of the axis range and/or tick list to be stored in local and/or global macros,
which can then be used in {help graph:Stata graphics commands} as {help axis_options:axis options and suboptions},
such as the {help axis_scale_options:range() suboption of the xscale() and yscale() options},
or the {help axis_label_options:xlabel(), ylabel(), xtick() and ytick() options}.


{title:Input options for {cmd:regaxis} and {cmd:logaxis}}

{p 4 8 2}
{cmd:include(}{it:numlist}{cmd:)} specifies a list of numeric values that must be included in the range
of values between the minimum tick and the maximum tick,
in addition to all values specified in the {it:varlist}.
For example, if the user specifies {cmd:include(0)}, then the axis tick range will include zero,
even if all values in the {it:varlist} are positive.

{p 4 8 2}
{cmd:maxticks(}{it:#}{cmd:)} specifies the maximum number of ticks allowed on the axis.
This number may not be less than 2 or greater than 1600.
If {cmd:maxticks()} is not specified, then
it is set to 25, the maximum number of axis ticks allowed by the {help graph7} command.
The number of ticks allowed is limited
because Stata cannot handle {help nlist:numlists} longer than 1600,
but this limitation is not often important for graph axes in practice.

{p 4 8 2}
{cmd:singleok} specifies that the output tick list can be a single tick
if the data range contains only a single value equal to a valid tick mark position.
If {cmd:singleok} is not specified, and the data range contains only a single valid tick mark position,
then the output tick list will also include one tick mark above that position
and one tick mark below that position.


{title:Input options for {cmd:regaxis} only}

{p 4 8 2}
{cmd:cycle(}{it:#}{cmd:)} specifies the cycle length of the sequence of axis ticks.
The cycle length has the property that, if {it:cycle} is the cycle length and {it:t} is a valid tick mark in the sequence,
then {it:t}{cmd:+}{it:cycle} is also a valid tick mark in the sequence.
If {cmd:cycle()} is not specified, then it is set to a sensible default value.
(Most users do not need to know the definition of a "sensible default value",
but more technically minded users can modify this definition by setting
the {cmd:cbase()} and {cmd:cppower()} options below.)

{p 4 8 2}
{cmd:phases(}{it:numlist}{cmd:)} specifies a list of cycle phases at which the axis ticks appear.
If {cmd:phases()} is not specified, then it is set using the {cmd:pcratios()} option, if that is specified,
and otherwise defaults to a single value of 0.
Axis ticks will be produced at positions of the form

{p 8 8 2}
{it:tick_ij} {cmd:=} {it:phase_i} {cmd:+} {it:cycle}{cmd: * }{it:j}

{p 8 8 2}
where {it:j} is an integer, {it:i} is an integer between 1 and the number of phases specified in the {cmd:phases()} option,
{it:phase_i} is the {it:i}th phase, {it:cycle} is the cycle length specified in the {cmd:cycle()} option,
and {it:tick_ij} is the tick mark position.
The integers {it:j} are chosen so that the tick marks span the nonmissing values in the {it:varlist}
and/or in the {cmd:include()} option.

{p 4 8 2}
{cmd:margins(}{it:marginlist}{cmd:)} specifies the lower and upper range margins,
separating the lower and upper range limits from the minimum and maximum ticks, respectively.
No more than 2 margins may be specified.
If only one margin is given in the {it:marginlist}, then both margins are equal to that margin,
If the {cmd:margins()} option is not specified, then it is set using the {cmd:mcratios()} option if that is specified.
Otherwise, both margins are set to 0,
so that the axis range extends from the minimum tick to the maximum tick.

{p 4 8 2}
{cmd:pcratios(}{it:numlist}{cmd:)} specifies a list of phase/cycle ratios,
which are used to define a list of values for the {cmd:phases()} option as a proportion of the {cmd:cycle()} option.
The {cmd:pcratios()} option is ignored if the {cmd:phases()} option is specified,

{p 4 8 2}
{cmd:mcratios(}{it:marginratiolist}{cmd:)} specifies a list of up to 2 margin/cycle ratios,
which are used to define a list of values for the {cmd:margins()} option as a proportion of the {cmd:cycle()} option.
If only one margin/cycle ratio is specified, then it is used to define both margins.
The {cmd:mcratios()} option is ignored if the {cmd:margins()} option is specified,

{p 4 8 2}
{cmd:cbase(}{it:#}{cmd:)} specifies a logarithmic base used to define the default cycle length
if the {cmd:cycle()} option is not specified. This logarithmic base must be positive,
and is set to 10 if not specified by the user. The {cmd:cbase()} option is ignored
if the user specifies the {cmd:cycle()} option, but otherwise
the {cmd:cycle()} option is defined using the {cmd:cbase()} option and the {cmd:cppower()} option (see below).

{p 4 8 2}
{cmd:cppower(}{it:#}{cmd:)} must be positive, and is set in default to twice
the {cmd:cbase()} option. 
The {cmd:cbase()} and {cmd:cppower()} options are used to define the default cycle length
if the {cmd:cycle()} option is not supplied.
The {cmd:cbase()} and {cmd:cppower()} options are both ignored if the user specifies the {cmd:cycle()} option.
Otherwise, the {cmd:cycle()} option is calculated as follows.
Define {it:vmin} to be the minimum value, and {it:vmax} to be the maximum value, in the {it:varlist}
and/or in the {cmd:include()} option. If all values are missing, then define both {it:vmin} and {it:vmax} to be zero.
Then the {cmd:cycle()} option is set to 1 if {it:vmax} is equal to {it:vmin}, and is otherwise set to

{p 8 8 2}
{it:cycle} {cmd:=} {it:cbase}{cmd:^ceil( log(}{it:vmax}{cmd:-}{it:vmin}{cmd:)/log(}{it:cbase}{cmd:) ) /} {it:cppower}

{p 8 8 2}
where {it:cycle} is the cycle length,
the {cmd:log()} and {cmd:ceil()} functions are defined as in the help for {help mathfun:mathematical functions},
and {it:cbase} and {it:cppower} are the values of the {cmd:cbase()} and {cmd:cppower()} options.
Therefore, {it:cppower} is the number of cycles in the minimum integer power of {it:cbase}
that is at least as large as the data range.
The default values {cmd:cbase(10)} and {cmd:cppower(20)} cause the tick positions to be "semi-round numbers",
or multiples of {cmd:5*10^}{it:k}, where {it:k} is a positive or negative integer.


{title:Input options for {cmd:logaxis} only}

{p 4 8 2}
{cmd:base(}{it:#}{cmd:)} specifies the logarithmic base of the axis ticks.
This base must be strictly greater than one.
If {cmd:base()} is not specified, then it is set to the value {cmd:e=exp(1)},
implying that natural logarithms will be used to define the axis ticks.

{p 4 8 2}
{cmd:scalefactors(}{it:numlist}{cmd:)} specifies a list of scale factors defining the positions at which the axis ticks appear.
If {cmd:scale()} is not specified, then it is set to a single value of 1.
Axis ticks will be produced at positions of the form

{p 8 8 2}
{it:tick_ij} {cmd:=} {it:scalefactor_i} {cmd:*} {it:base}{cmd:^}{it:j}

{p 8 8 2}
where {it:j} is an integer, {it:i} is an integer between 1 and the number of scale factors specified in the {cmd:scalefactors()} option,
{it:scalefactor_i} is the {it:i}th scale factor, {it:base} is the logarithmic base specified in the {cmd:base()} option,
and {it:tick_ij} is the tick mark position.
The tick marks are chosen to span the nonmissing values in the {it:varlist}
and/or in the {cmd:include()} option.

{p 4 8 2}
{cmd:marginfactors(}{it:marginfactorlist}{cmd:)} specifies the lower and upper range margin factors.
The lower range margin factor is the ratio of the minimum tick to the range minimum,
and the upper range margin factor is the ratio of the range maximum to the maximum tick.
For instance, {cmd:marginfactors(1.01, 1.01)} specifies that the range maximum is 1 percent greater than the maximum tick,
and that the minimum tick is 1 percent greater than the range minimum.
No more than 2 margin factors may be specified.
If only one margin factor is given in the {it:marginfactorlist}, then both margin factors are equal to that margin factor,
If {cmd:marginfactors()} is not specified, then both margin factors are set to 1,
so that the axis range extends from the minimum tick to the maximum tick.


{title:Output options for {cmd:regaxis} and {cmd:logaxis}}

{p 4 8 2}
{cmd:lrange(}{it:macname}{cmd:)} inserts the axis range
(a list of 2 numbers specifying the axis minimum and maximum)
in a local macro {it:macname} within the calling program's space.
This macro will be accessible after {cmd:regaxis} or {cmd:logaxis} has finished.
This is helpful for subsequent use,
especially in the {cmd:range()} suboption of the
{help axis_scale_options:graph axis scale options} {cmd:yscale()}, {cmd:xscale()} or {cmd:tscale()}.

{p 4 8 2}
{cmd:lticks(}{it:macname}{cmd:)} inserts the axis tick list
in a local macro {it:macname} within the calling program's space.
This macro will be accessible after {cmd:regaxis} or {cmd:logaxis} has finished.
This is helpful for subsequent use,
especially in the
{help axis_label_options:graph axis label options} {cmd:ylabel()}, {cmd:xlabel()} or {cmd:tlabel()}.

{p 4 8 2}
{cmd:lrmin(}{it:macname}{cmd:)} inserts the axis range minimum
in a local macro {it:macname} within the calling program's space.

{p 4 8 2}
{cmd:lrmax(}{it:macname}{cmd:)} inserts the axis range maximum
in a local macro {it:macname} within the calling program's space.

{p 4 8 2}
{cmd:ltmin(}{it:macname}{cmd:)} inserts the minimum tick
in a local macro {it:macname} within the calling program's space.

{p 4 8 2}
{cmd:ltmax(}{it:macname}{cmd:)} inserts the maximum tick
in a local macro {it:macname} within the calling program's space.

{p 4 8 2}
{cmd:lntick(}{it:macname}{cmd:)} inserts the number of axis ticks
in a local macro {it:macname} within the calling program's space.

{p 4 8 2}
{cmd:lvmin(}{it:macname}{cmd:)} inserts the minimum nonmissing value
appearing in the {it:varlist} and/or the {cmd:include()} option
in a local macro {it:macname} within the calling program's space.
If there are no nonmissing values, then the value returned
is 0 in the case of {cmd:regaxis} and 1 in the case of {cmd:logaxis}.

{p 4 8 2}
{cmd:lvmax(}{it:macname}{cmd:)} inserts the maximum nonmissing value
appearing in the {it:varlist} and/or the {cmd:include()} option
in a local macro {it:macname} within the calling program's space.
If there are no nonmissing values, then the value returned
is 0 in the case of {cmd:regaxis} and 1 in the case of {cmd:logaxis}.

{p 4 8 2}
{cmd:grange(}{it:macname}{cmd:)} inserts the axis range
in the global macro {it:macname}.

{p 4 8 2}
{cmd:gticks(}{it:macname}{cmd:)} inserts the axis tick list
in the global macro {it:macname}.

{p 4 8 2}
{cmd:grmin(}{it:macname}{cmd:)} inserts the axis range minimum
in the global macro {it:macname}.

{p 4 8 2}
{cmd:grmax(}{it:macname}{cmd:)} inserts the axis range maximum
in the global macro {it:macname}.

{p 4 8 2}
{cmd:gtmin(}{it:macname}{cmd:)} inserts the minimum tick
in the global macro {it:macname}.

{p 4 8 2}
{cmd:gtmax(}{it:macname}{cmd:)} inserts the maximum tick
in the global macro {it:macname}.

{p 4 8 2}
{cmd:gntick(}{it:macname}{cmd:)} inserts the number of axis ticks
in the global macro {it:macname}.

{p 4 8 2}
{cmd:gvmin(}{it:macname}{cmd:)} inserts the minimum nonmissing value
appearing in the {it:varlist} and/or the {cmd:include()} option
in the global macro {it:macname}.

{p 4 8 2}
{cmd:gvmax(}{it:macname}{cmd:)} inserts the maximum nonmissing value
appearing in the {it:varlist} and/or the {cmd:include()} option
in the global macro {it:macname}.


{title:Technical note}

{p 4 4 2}
{cmd:regaxis} and {cmd:logaxis} define an axis range and tick mark list to span the range
of values of the variables in the {it:varlist}
(qualified by the {help if} and {help in} qualifiers if these are supplied)
and/or the number list supplied by the {cmd:include()} option.
Either the {it:varlist}, or the {cmd:include()} option, or both may be absent.
If all values are missing, then {cmd:regaxis} takes the minimum and maximum values to be 0,
and {cmd:logaxis} takes the minimum and maximum values to be 1.

{p 4 4 2}
A tick mark list is selected from the infinite sequence of candidate tick marks specified
by the {cmd:cycle()} and {cmd:phase()} options of {cmd:regaxis}, or by the
{cmd:base()} and {cmd:scalefactors()} options of {cmd:logaxis}.
Initially, the tick mark list is defined as the shortest finite list of consecutive candidate tick marks
with a maximum tick mark at or above the maximum value and a minimum tick mark at or below the minimum value.
If the minimum and maximum tick marks are the same, and {cmd:singleok} is not specified,
then {cmd:regaxis} and {cmd:logaxis} add one additional tick mark above and one additional tick mark below.

{p 4 4 2}
If the number of tick marks defined in this way is greater than a maximum set by the {cmd:maxticks()} option,
then {cmd:regaxis} and {cmd:logaxis}
repeat the following procedure
until the number of ticks is no more than the {cmd:maxticks()} value.
If the {cmd:maxticks()} value is 2,
then the first and last ticks are retained, and all others are removed.
Otherwise, if there is more than one phase specified by the {cmd:phases()} option of {cmd:regaxis},
or more than one scale factor specified by the {cmd:scalefactors()} option of {cmd:logaxis}.
then the last phase or scale factor is removed, and the axis is then redefined as before.
Otherwise, if there is only one phase or scale factor,
then {cmd:regaxis} increments the {cmd:cycle()} option by its original value,
and {cmd:logaxis} multiplies the {cmd:base()} option by its original value,
and the axis is then redefined as before.

{p 4 4 2}
When a final list of tick marks has been defined,
the range is set, using the {cmd:margins()} option of {cmd:regaxis}
or the {cmd:marginfactors()} option of {cmd:logaxis}
to define a range minimum at or below the minimum tick and a range maximum at or above the maximum tick.


{title:Examples}

{p 4 8 2}{cmd:. regaxis}{p_end}
{p 4 8 2}{cmd:. return list}{p_end}

{p 4 8 2}{cmd:. regaxis weight, include(0) lticks(xlabs)}{p_end}
{p 4 8 2}{cmd:. regaxis price, include(0) lticks(ylabs)}{p_end}
{p 4 8 2}{cmd:. scatter price weight, ylabel(`ylabs') xlabel(`xlabs')}{p_end}

{p 4 8 2}{cmd:. regaxis rep78, cycle(1) singleok margin(0.5) lrange(yrange) lticks(ylabs)}{p_end}
{p 4 8 2}{cmd:. regaxis weight, include(0) lticks(xlabs)}{p_end}
{p 4 8 2}{cmd:. scatter rep78 weight, yscale(range(`yrange')) ylabel(`ylabs') xlabel(`xlabs')}{p_end}

{p 4 8 2}{cmd:. regaxis length, cycle(12) lticks(xlabs)}{p_end}
{p 4 8 2}{cmd:. regaxis displacement, cycle(100) phases(0 70) lticks(ylabs)}{p_end}
{p 4 8 2}{cmd:. scatter displacement length, ylabel(`ylabs', angle(0)) xlabel(`xlabs')}{p_end}

{p 4 8 2}{cmd:. logaxis}{p_end}
{p 4 8 2}{cmd:. return list}{p_end}

{p 4 8 2}{cmd:. logaxis length, base(2) scale(1 3 5) margin(1.05) lrange(xrange) lticks(xlabs)}{p_end}
{p 4 8 2}{cmd:. logaxis displacement, base(2) scale(1 3 5) lrange(yrange) lticks(ylabs)}{p_end}
{p 4 8 2}{cmd:. scatter displacement length, yscale(log range(`yrange')) ylabel(`ylabs', angle(0)) xscale(log range(`xrange')) xlabel(`xlabs')}{p_end}


{title:Saved results}

{pstd}
{cmd:regaxis} and {cmd:logaxis} save the following results in {cmd:r()}:

{p 4 8 2}{hi:Scalars:}

{p 4 8 2}{cmd:r(rmin)}{space 8}Range minimum{p_end}
{p 4 8 2}{cmd:r(rmax)}{space 8}Range maximum{p_end}
{p 4 8 2}{cmd:r(tmin)}{space 8}Minimum axis tick mark position{p_end}
{p 4 8 2}{cmd:r(tmax)}{space 8}Maximum axis tick mark position{p_end}
{p 4 8 2}{cmd:r(ntick)}{space 7}Number of axis ticks{p_end}
{p 4 8 2}{cmd:r(vmin)}{space 8}Minimum value in {it:varlist} and/or {cmd:include()} list{p_end}
{p 4 8 2}{cmd:r(vmax)}{space 8}Maximum value in {it:varlist} and/or {cmd:include()} list{p_end}

{p 4 8 2}{hi:Macros:}

{p 4 8 2}{cmd:r(range)}{space 8}list of 2 values (the range minimum and maximum){p_end}
{p 4 8 2}{cmd:r(ticks)}{space 8}list of axis tick mark positions{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
Manual:  {hi:[G] graph}, {hi:[G] {it:axis_options}}, {hi:[G] {it:axis_scale_options}}, {hi:[G] {it:axis_label_options}}
{p_end}
{p 4 13 2}
Online:  help for {help graph}, {help axis_options}, {help axis_scale_options}, {help axis_label_options}
{p_end}
