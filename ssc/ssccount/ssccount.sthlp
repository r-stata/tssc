{smcl}
{* *! version 0.3  07nov2014}{...}
{vieweralsosee "[G-2] graph twoway line" "help line"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] ssc hot" "help ssc"}{...}
{viewerjumpto "Syntax" "ssccount##syntax"}{...}
{viewerjumpto "Description" "ssccount##description"}{...}
{viewerjumpto "Options" "ssccount##options"}{...}
{viewerjumpto "Examples" "ssccount##examples"}{...}

{title:Title}

{pstd}
ssccount {hline 2} download ssc hits over time for user-written packages


{marker syntax}{...}
{title:Syntax}

{pstd}
{cmd:ssccount} , [ {opt fr:om(first_month)} {opt to(last_month)} {opt au:thor(author_name)} {opt clear} {opt f:illin(#)} {opt gr:aph} {opt pack:age(pkg_name)} {opt sav:ing(filename, replace)} ]


{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt fr:om(first_month)}}first month to download data for, specified in %tm format; default is 2007m7{p_end}
{synopt :{opt to(last_month)}}last month to download data for, specified in %tm format; default is 3 months ago{p_end}
{synopt :{opt au:thor(author_name)}}name of author whose packages are of interest, if applicable{p_end}
{synopt :{opt clear}}specifies that existing data be cleared from memory{p_end}
{synopt :{opt fillin(#)}}specifies the # to fill in for missing months. Default is not to use fillin.{p_end}
{synopt :{opt gr:aph}}specifies that a graph be drawn of results{p_end}
{synopt :{opt pack:age(pkg_name)}}exact name of the package of interest, if applicable{p_end}
{synopt :{opt sav:ing(filename, replace)}}asks Stata to save the files downloaded as {it: filename}.dta{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
For authors of user-written packages released on SSC, {cmd:ssccount} is a command
to keep track of monthly hits. It uses the same datasets as {cmd:ssc hot} and appends
them over time. Datasets are downloaded for the specified date range and loaded into
memory. If neither {opt author()} nor {opt package()} options are specified,
{cmd: ssccount} will download data for all authors and packages for the specified
months. It is then up to the user to process as they wish.

{pstd}
Note that records began in 2007m7 (that is, July 2007) and {cmd:ssccount} will react
angrily if dates before this are specified. Unfortunately {cmd:ssccount} is not a crystal
ball, and if dates specified are in the future you will not get any results. There
also tends to be a lag on the release of the datasets of about two months. Specifying
months that are not yet available will display an error but {cmd:ssccount} will load
into memort (and save if specified) the datasets it was able to download, if any.


{marker options}{...}
{title:Options}

{phang}
{opt fr:om(first_month)} specifies the first month you are interested in.
Must be specified in Stata's %tm format. For example, Jan 2010 is specified as
"2010m1". Must be no later than the date specified in the {opt to()} option.
Default is 2007m7.

{phang}
{opt to(last_month)} specifies the last month you are interested in.
Must be specified in Stata's %tm format. For example, Feb 2010 is given as
"2010m2". Cannot be earlier than the date specified in the {opt from()} option.
Default is three months earlier than the current month, chosen due to a lag before
hits files become available online.

{phang}
{opt author()} specifies the name of the author being searched for. Note that the names
on SSC packages can be of an inconsistent form. You do not have to get it exactly right,
as long as the name used contains what you specify in author. Note that the option is not
sensitive to case, so specifiying {opt author(bloggs)} is the same as {opt author(BLOGGS)}
or anything in between, like {opt author(BlOgGs)}.

{phang}
{opt clear} specifies that any dataset currently in memory be cleared. If there is a data
in memory and the {opt clear} option is not specified, {cmd:ssccount} will exit with an
error.

{phang}
{opt fillin(#)} calls the {help fillin} command. This is for use with plots when more than
one author and/or package has been specified. It creates missing months to form a rectangular
dataset and fills each one in with # hits. Filling as missing (.) is allowed. Default is not
to fill anything.

{phang}
{opt graph} draws a simple graph of the month-by-month hits using {cmd:twoway line} and
overlays a smoothed trend using {cmd:lowess}. If the data contains multiple authors or
packages, the graphs will be drawn by author and/or package.

{phang}
{opt package(pkg_name)} specifies the name of the package of interest. This may be useful if
an author has written multiple packages but is interested in one in particular. It
can also be helpful if the author's name is a substring of one or more other authors'
names.

{phang}
{opt saving(filename, replace)} saves a copy of the dataset you have downloaded.


{marker examples}{...}
{title:Examples}

{pstd}
Download all hits for 2008:

{phang2}
{cmd:ssccount , from(2008m1) to(2008m12) saving(2008data)}

{pstd}
Download and plot hits for the {cmd:ice} package by Patrick Royston from Jun 2007 to Sep 2014:

{phang2}
{cmd:ssccount , from(2007m7) to(2014m9) author(Royston) graph package(ice) saving(icehits)}

{pstd}
Download and plot hits for the {cmd:psmatch2} package from Jan to May 2015:

{phang2}
{cmd:ssccount , from(2015m1) to(2015m5) graph package(psmatch2) saving(psmatch2_2015)}


{title:Acknowledgements}

{pstd} We are grateful to Patrick Royston and Roger Newson for helpful advice on the command.


{title:Authors}

{pstd}
Tim Morris, MRC Clinical Trials Unit at UCL, London UK
{break}
Email: {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}
{break}
Twitter: {browse "https://twitter.com/tmorris_mrc":@tmorris_mrc}

{pstd}
Babak Choodari-Oskooei, MRC Clinical Trials Unit at UCL, London UK
{break}
Email: {browse "mailto:b.choodari-oskooei@ucl.ac.uk":b.choodari-oskooei@ucl.ac.uk}

{...} 