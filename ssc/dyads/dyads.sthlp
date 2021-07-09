{smcl}
{* *! version 1.0 05apr2011}
{cmd:help dyads}
{hline}

{title:Title}

{phang}{bf:dyads} {hline 2} Transform observations into dyads

{title:Syntax}

{phang}{bf:dyads} {it:idvar} [{cmd:,} {it:DYadvars(varlist)}]

{title:Description}
{pstd}
{cmd:dyads} takes a set of {it:N} observations and returns a set of
{it:(N(N-1))/2} dyads.  Observations are identified by {it:idvar},
which must be specified.  The user can also specify via
{it:DYadvars()} any variables whose values should be added in for the
second half of the created dyads; the default is to copy only the
value of {it:idvar} for the other half of the dyad.

{title:Remarks}

{pstd}{cmd:dyads} is designed to take a file that has {it:N}
observations, indexed by some {it:idvar}, and create a file that has
{it:(N(N-1))/2} dyads representing all the possible pairs of
observations in the original dataset.  The command is meant to be used
as a preface to calculating dyad-based statistics, as one might do for
many types of network analyses.  In addition to generating pairs of
observation identifierss, {cmd:dyads} can include a user-specified
collection of variables.

{pstd}You could instead create dyads using Stata's matrix-programming
capabilities.  The advantages of {cmd:dyads} are that it doesn't
require learning the matrix syntax for a discrete data-management job
and it isn't limited by Stata's matrix-size boundaries.  Thus it runs
quickly on large datasets.  It is worth noting that {cmd:dyads}
produces {it:N*N} observations before finishing with {it:(N(N-1))/2}
observations.  This may be a memory issue with large datasets.

{title:Examples}

{pstd}The simplest example is to take a list of IDs and generate all pairs
of IDs.  Imagine the following dataset:

{center:{cmd:N   id}}
{center:{hline 6}}
{center:1    1}
{center:2    2}
{center:3    3}
{center:4    4}
{center:5    5}

{pstd}Typing

{phang}{cmd:. dyads id}

{pstd}will produce the following dataset:

{center:{cmd:N  id  id_d}}
{center:{hline 11}}
{center: 1   1     2}
{center: 2   1     3}
{center: 3   1     4}
{center: 4   1     5}
{center: 5   2     3}
{center: 6   2     4}
{center: 7   2     5}
{center: 8   3     4}
{center: 9   3     5}
{center:10   4     5}

{pstd}...that is, all the pairwise combinations of {it:id}.

{pstd}A more useful example might be calculating the distance between pairs
of objects.  Imagine a dataset with firms and their {it:(x,y)}
locations:

{center:{cmd:firm    x   y}}
{center:{hline 13}}
{center:firma  12  13}
{center:firmb   4   6}
{center:firmc  10   2}
{center:firmd   5  17}

{phang}{cmd:. dyads firm, dy(x y)}

{center:{cmd:firm    x   y  firm_d  x_d   y_d}}
{center:{hline 32}}
{center:firma  12  13  firmb     4     6}
{center:firma  12  13  firmc    10     2}
{center:firma  12  13  firmd     5    17}
{center:firmb   4   6  firmc    10     2}
{center:firmb   4   6  firmd     5    17}
{center:firmc  10   2  firmd     5    17}

{pstd}You could now calculate distance for all the dyads using

{phang}{cmd:. generate dist = sqrt((x-x_d)^2+(y-y_d)^2)}

{pstd}A final example shows the utility of choosing {it:idvar}
carefully.  Imagine a dataset with basketball players, the times they
entered the game (expressed in minutes since the start) and the times
they exited:

{center:{cmd:id  timein  timeout}}
{center:{hline 19}}
{center: 1       5       27}
{center: 2      15       41}
{center: 3       8       33}
{center: 4       2       36}
{center: 5      39       51}
{center: 6      33       36}

{pstd}Assume that you want to know the amount of time that each
player-dyad spent on the court together.  In order to generate that
particular statistic, you might want to ensure that the player who
came onto the court earlier is always the {it:first} member of the
dyad.  Creating a unique {it:idvar} on which to run {cmd:dyads} can
help with this.

{phang}{cmd:. sort timein id}

{phang}{cmd:. generate sortid = _n}

{phang}{cmd:. dyads sortid, dy(id timein timeout)}

{center:{cmd:id  timein  timeout  sortid  sortid_d  id_d  timein_d  timeout_d}}
{center:{hline 64}}
{center: 4       2       36       1         2     1         5         27}
{center: 4       2       36       1         3     3         8         33}
{center: 4       2       36       1         4     2        15         41}
{center:...}

{pstd}Notice that, in order to keep the original observation's
identifier when generating the dyads, in this case the variable
{it:id} was included inside {id:DYadvars()}.  Calculation of overlaps
could now proceed under the assumption that the first member of the
dyad always had an earlier or equal starting time than the second
member.

{title:Author}

{phang}John-Paul Ferguson
{phang}ferguson_john-paul@gsb.stanford.edu
