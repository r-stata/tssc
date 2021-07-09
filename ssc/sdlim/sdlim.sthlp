{smcl}
{* *! version 0  Oktober 19, 2010 @ 10:42:19 UK}{...}
{cmd:help sdlim}
{hline}

{title:Title}

{p2colset 5 9 16 2}{...}
{p2col: sdlim {hline 2} Rescaled standard deviations for limited variables}{p_end}
{p2colreset}{...}


{title:Syntax}

{pstd}
Syntax 1: Rescaled standard deviations for many variables

{p 8 17 2}
{cmd:sdlim}
{varlist}
{ifin}
{weight}
{cmd:,}  {cmdab:l:imits(}# #{cmd:)}} [ {cmdab:sim:ulate(}# #{cmd:)}}  {cmd:keep}]


{pstd}
Syntax 2: Rescaled standard deviations by groups

{p 8 17 2}
{cmd:sdlim}
{varname}
{ifin}
{weight}
{cmd:,} {cmd:by(}{varname} {cmd:)} [ {cmdab:l:imits(}# #{cmd:)}} {cmdab:sim:ulate(}# #{cmd:)}} {cmd:keep}]

{p 4 6 2}
  {opt aweight}s, and {opt fweight}s are allowed;
  see {help weight}.
  {p_end}

{p 4 6 2}
  {opt by} is allowed; see {help by}.
  {p_end}


{title:Description}

{pstd} {opt sdlim} rescales the standard deviation of a variable such
that the result is the proportion of the raw standard deviation at the
maximum standard deviation for a given mean.{p_end}

{pstd}The theoretical maximum of the standard deviation of the
variable X with mean = mean(X) is {p_end}

{center:max(SD) = sqrt((min(X) - mean(X)) * (mean(X)-max(X)) * N/(N-1))}

{pstd}The formula assumes that the mimimum and the maximum of X is
 known and fixed. This is the case for variables measured with a
 rating scale, for example.{p_end}

{pstd} {opt sdlim} has two syntaxes. Syntax 1 is used to to rescale
the standard deviations of various variables. In this case the option
{opt limits()} {it:must} be used. Syntax 2 is used to rescale the
standard deviation of {it:one} variable for different groups. In this
case the option {opt by()} is required, while the specification of a
{varlist} behind the command is not allowed.
{p_end}

{title:Options}

{phang} {opt limits(# #)} is used to set the theoretical limits of
the variable(s) for which the standard deviation should be
rescaled. Limits are set by two interger numbers. The first number is
the theoretical minimum of the variable the second number is the
theoretical maximum. Results are omitted if variables contain values
outside its theoretical boundaries. Note that the option is required
if the command is given without option {opt by()} (i.e. for Syntax
1). For Syntax 2 {cmdab:l:imits(# #)} defaults to the minimum and
maximum value of varname over all by-groups.  {p_end}

{phang} {opt by(varname)} is used to compare rescaled standard
deviations between groups defined by categories of varname. With
option by(), rescaling of standard deviation can be done for only one
variable. 

{phang} {opt simulate(# #)} uses a simulation to rescale the standard
deviation of a variable measured with a limited rating scale. The
simulation assumes a latent variable with the mean of the observed
variable and a given standard deviation. It further assumes that all
values of the latent variable that exceed the specified limits are set
to the highest and lowest value of the observed variable. Inside the
parentheses the option requires two numbers. The first number is the
number of observations used in the simulation, the second number is
the standard deviation of the latent variable.

{phang} {opt keep} is used to keep in memory the results of
{cmd:sdlim} as a Stata data set (i.e. a resultsset)


{title:Examples}

{phang}{cmd:. sysuse auto}{p_end}
{phang}{cmd:. sdlim rep78, l(1 5)}{p_end}
{phang}{cmd:. sdlim rep78, by(for)}{p_end}
{phang}{cmd:. sdlim rep78, by(for) l(1 9)}{p_end}

{phang}{cmd:. sdlim rep78, by(for) l(1 9) sim(1000 2)}{p_end}

{title:Saved results}

{pstd} {cmd:sdlim} does not save returns. However with option
{cmd:keep} keep the results are kept in memory as a resultsset.

{title:Acknowledgment}

{pstd} The formula for the maximum standard deviation is published in
Kalmijn, Wim and Ruut Veenhoven, 2005: Measuring inequality of
happiness in nations. In search for proper statistics. Journal of
Happiness Studies 6, 357-396 (Special issue on "Inequality of
Happiness in nations").

{pstd} The two methods for rescaling of standard deviations are
discussed by Delhey, Jan and Kohler, Ulrich: Is Happiness Inequality
Immune to Income Inequality? New Evidence through
Instrument-Effect-Corrected Standard Deviations. This article is
currently under review in Social Science Research. {p_end}

{title:Author}

Ulrich Kohler, WZB
kohler@wzb.eu


{title:Also see}
Manual:  {manlink R summarize}


