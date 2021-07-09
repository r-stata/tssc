{smcl}
{* Copyright 2007 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 27August2007}{...}
{cmd:help trans2subs}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col :{hi:trans2subs} {hline 2}}Create substitution matrix based on observed transitions{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:trans2subs} {it: state  {ifin}, IDvar(id) SUBSmat(subsmat) [DIAGincl]}


{title:Description}

{pstd}{cmd:trans2subs} calculates a substitution matrix based on
observed transitions in the {it:state} variable, and puts it in the
{it:subsmat} matrix. The data must be in long format, with
{it:idvar} identifying the groups, and must be sorted.

{pstd}Transitions are tabulated from period to period, and the
substitution cost is defined as 2 - p_{a,b} - p{b,a} for
off-diagonal cells, and 0 for diagonal cells. p_{a,b} is defined as
the proportion of transitions from a in t which are to b in t+1.
Note that, by default, cases which do not have a transition from
one period to the next do not enter the calculation.

{title:Options}

{p 0 4}{cmd:IDvar(}{it:idvar}{cmd:)} specifies the ID variable.{p_end}

{p 0 4}{cmd:SUBSmat(}{it:mat}{cmd:)} specifies the Stata matrix to which to write the substitution costs.{p_end}

{p 0 4}{cmd:DIAGincl} causes the cells on the diagonal to be used in the calculation.{p_end}


{title:Comments}

{p} One way to define substition costs for optimal matching is to
use observed transition rates between states. Higher probabilities
of transition imply greater similarity. This {it:may} often be a
good idea, but it is not always the case. It is plausible that in
some domains we will see high probabilities of transition between
states which are substantively quite dissimilar, for instance
between never-married and married.{p_end}

{p}The procedure expects the data in long calendar format, that is
with each record representing a person--month or case--time-unit,
sorted in temporal order within IDvar, the variable identifying the
person or case. The resulting matrix is based on a cross-tabulation
of state at t and t-1. {p_end}

{p}In this format only off-diagonal cases represent transitions:
the diagonal represents months where the state is the same as the
previous month. In the default, the diagonal cases are excluded,
but the option DIAGincl causes them to be included in the
calculation. Including them reduces the range of the substitution costs.{p_end}

{p}The strategy is based in part on that described in Rowher and
Potter's TDA manual, section 6.7.2.5,
http://www.stat.ruhr-uni-bochum.de/pub/tda/doc/tman63/d06070205.zip{p_end}


{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}If your sequences are represented by consecutive variables
{cmd:s1-s50} with ID {cmd:id}, first {cmd:reshape long}:{p_end}

{phang}{cmd:. reshape long s, i(id) j(m)}{p_end}
{phang}{cmd:. trans2subs s, id(id) subs(smat)}{p_end}
{phang}{cmd:. matrix list smat}{p_end}
{phang}{cmd:. trans2subs s, id(id) subs(smat) diag}{p_end}
{phang}{cmd:. matrix list smat2}{p_end}

{phang}{p_end}
