{smcl}
{* *! version 1.0  22apr2013}{...}
{hline}
help for {cmd:rsort}{right:Version 1.0, 22 April 2013}
{hline}

{title:Title}

{p2colset 5 14 21 2}{...}
{p2col: {bf:rsort}}{hline 2} Reproducible random sorting of dataset

{title:Syntax}

{p 8 18 2}
{bf:rsort} [, {it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Required for reproducible sorting}
{synopt:{opt id(varlist)}}ID variable/s uniquely identifying observations{p_end}
{synopt:{opt seed(#)}}random number seed to use{p_end}

{syntab:Convenience}
{synopt:{opt by(varlist)}}sort within groups defined by {it:varlist}{p_end}
{synopt:{opt gen:erate(sortorder)}}create variable containing new observation number{p_end}
{synopt:{opt replace}}replace existing {it:sortorder}{p_end}


{title:Description}

{pstd}{bf:rsort} randomly sorts the dataset in memory. This is useful for various situations in
which the sort order of the dataset may affect results. If the {bf:id()} and {bf:seed()} options are
used then the same dataset will always be sorted the same way, facilitating reproducible analyses.
{p_end}


{title:Options for rsort}

{phang}
{opt id(varlist)} specifies one or more variables that uniquely identify observations within the
dataset. This is required if you wish to reproduce the random sort order reliably in future
analyses. This is because the dataset must start with a definitely reproducible sort order (ie in a
known state) prior to assigning random numbers with which to re-sort the dataset.

{phang}
{opt seed(#)} sets the random number {help seed} to # prior to random sorting. This is usually
also required if you wish to reproduce the random sort order. In some cases you may have already
set the random number seed, in which case you may not need to do so again here. If you want
reproducible results, omit {bf:seed()} only if you're sure that the random seed will be in the same
state every time {bf:rsort} is called.

{phang}
{opt by(varlist)} allows you to sort randomly within by-groups defined by {it:varlist}. This is a
convenience option that saves you from needing to re-sort the data by {it:varlist} after running
{bf:rsort}, while preserving reproducibly random sorting within those by-groups.

{phang}
{opt gen:erate(sortorder)} creates a new variable {it:sortorder} containing the new observation
number in the sorted dataset. If you wish to re-sort the data by one or more variables, but preserve
the random order within the by-groups, you first need to create a new variable containing the sort
order arising from {bf:rsort}. This option saves you the trouble and creates {it:sortorder} for you.
If {it:sortorder} already exists you can replace it with the {bf:replace} option.


{title:Examples}

{phang}Simple random sort of the auto dataset:{p_end}
{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. rsort, id(make) seed(12345)}{p_end}

{phang}Randomly split the dataset into 2 groups within strata defined by {bf:rep78}:{p_end}
{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. rsort, id(make) seed(12345) by(rep78)}{p_end}
{phang}{cmd:. by rep78: gen byte group=mod(_n, 2)}{p_end}
{phang}{cmd:. tab rep78 group, mis}{p_end}


{title:Author}

{p 4 4 2}
Phil Clayton, ANZDATA Registry, Australia, phil@anzdata.org.au


{title:Also see}

{pstd}
Using Stata’s random-number generators, part 2, drawing without replacement:
{browse "http://blog.stata.com/2012/08/03/using-statas-random-number-generators-part-2-drawing-without-replacement/"}
