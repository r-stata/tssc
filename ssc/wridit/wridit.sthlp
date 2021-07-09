{smcl}
{hline}
help for {cmd:wridit}{right:(Roger Newson)}
{hline}

{title:Generate weighted ridits}

{p 8 21 2}
{cmd:wridit} {varname} {ifin} {weight} , {cmdab:g:enerate}{cmd:(}{help varname:{it:newvarname}}{cmd:)} 
  {break}
  [  {cmd:by(}{varlist}{cmd:)}
  {cmdab:fol:ded} {cmdab:rev:erse} {cmdab:perc:ent} {cmd:float}
  ]

{pstd}
{cmd:fweight}s, {cmd:pweight}s,  {cmd:aweight}s, and {cmd:iweight}s are allowed;
see {help weight}.


{title:Description}

{pstd}
{cmd:wridit} inputs a variable and generates its weighted ridits.
If no weights are provided, then all weights are assumed equal to 1,
so unweighted ridits are generated.
Zero weights are allowed,
and imply that the ridits calculated for the observations with zero weights
will refer to the distribution of weights in the observations with nonzero weights.


{title:Options}

{p 4 8 2}
{cmd:generate(}{help varname:{it:newvarname}}{cmd:)} must be specified.
It specifies the name of the generated output variable,
containing the weighted ridits.

{p 4 8 2}
{cmd:by(}{varlist}{cmd:)} specifies a list of by-variables.
If {cmd:by()} is specified,
then the weighted ridits are computed within by-groups.

{p 4 8 2}
{cmd:folded} specifies that the weighted ridits generated will be folded ridits.
A folded ridit, on a proportion scale from -1 to 1,
is defined as {cmd:2*R-1},
where {cmd:R} is the corresponding unfolded ridit (on a proportion scale from 0 to 1).

{p 4 8 2}
{cmd:reverse} specifies that the weighted ridits will be reverse ridits,
based on reverse cumulative probabilities.

{p 4 8 2}
{cmd:percent} specifies that the weighted ridits will be generated on a percentage scale
from 0 to 100,
or from -100 to 100 if {cmd:folded} is specified.
If {cmd:percent} is not specified,
then the weighted ridits will be generated on a proportion scale from 0 to 1,
or from -1 to 1 if {cmd:folded} is specified.

{p 4 8 2}
{cmd:float} specifies that the weighted ridits will be generated with {help data types:storage type} {cmd:float}.
If {cmd:float} is not specified, then the weighted ridits will be generated
 with {help data types:storage type} {cmd:double}.


{title:Remarks}

{pstd}
Ridits were introduced by Bross (1958).
Given a variable {it:X},
the unfolded ridit for a value {it:x} is equal to the probability that {it:X<x}
plus half the probability that {it:X==x}.
The folded ridit for {it:x}, introduced by Brockett and Levene (1977),
is equal to the probability that {it:X<x}
minus the probability that {it:X>x}.
Nicholas J. Cox introduced an {helpb egen} function {cmd:ridit()},
computing unweighted unfolded ridits,
as part of the {helpb egenmore} package,
downloadable from {help ssc:SSC}.


{title:Examples}

{p 8 12 2}{cmd:. wridit mpg, gene(wrid1)}{p_end}

{p 8 12 2}{cmd:. wridit mpg [pwei=weight], gene(wrid2) by(foreign)}{p_end}


{title:References}

{phang}
Brockett, P. L., and Levene, A.  1977.
On a characterization of ridits.
{it:The Annals of Statistics} 5(6): 1245-1248.

{phang}
Bross, I. D. J.  1958.
How to use ridit analysis.
{it:Biometrics} 14(1): 18-38.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] egen}
{p_end}
{p 4 13 2}
On-line: help for {helpb egen}{break}
         help for {helpb egenmore} if installed
{p_end}
