{smcl}
{* *! version 1.0.0 20jan2011}{...}
{cmd:help stsurvdiff} 
{right:also see:  {help sts generate}}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:stsurvdiff} {hline 2}}Difference between two Kaplan-Meier survival curves{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}{cmd:stsurvdiff} {varname} {ifin} [{cmd:,} {it:options}]


{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt g:enerate(stubname)}}defines the stub-name for variables
containing results created by {cmd:stsurvdiff}{p_end}
{synopt :{opt l:evel(#)}}sets the confidence level of the CI for the
difference in survival curves{p_end}
{synopt :{opt s:mooth}}smooths the difference and its standard error
as a function of time ({cmd:_t}){p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
You must {cmd:stset} your data before using {cmd:stsurvdiff}; see
{manhelp stset ST}.{p_end}


{title:Description}

{pstd}
{cmd:stsurvdiff} computes the difference in the Kaplan-Meier
survival curves, and a pointwise confidence interval, at the two
levels of a binary "treatment" variable, {it:varname}.


{title:Options}

{phang}
{opt generate(stubname)} defines the stub-name for variables containing
results created by {cmd:stsurvdiff}. For example, if {it:stubname} is
{cmd:diff}, four new variables are created, with names {cmd:diff},
{cmd:diff_se}, {cmd:diff_lci} and {cmd:diff_uci}, respectively.

{phang}
{opt level(#)} specifies the percent confidence level for the pointwise
confidence interval of the difference in survival functions. The
default {it:#} is 95%.

{phang}
{opt smooth} applies a running-line smooth (see {help running})
to the difference in survival curves and its standard error.


{title:Examples}

{phang2}{cmd:. stsurvdiff treat}{p_end}
{phang2}{cmd:. stsurvdiff treat, generate(diff) level(99) smooth}{p_end}


{title:Author}

{pstd}
Patrick Royston, MRC Clinical Trials Unit, London, UK.
({browse "mailto:patrick.royston@ctu.mrc.ac.uk":pr@ctu.mrc.ac.uk})


{title:Also see}

{psee}
Manual:  {manlink R sts generate}
