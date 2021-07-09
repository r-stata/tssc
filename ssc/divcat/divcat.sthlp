{smcl}
{* *! version 1.3.1  21January2015  Dirk Enzmann}{...}
{hi:help divcat}
{hline}

{title:Title}

{pstd}{hi:divcat} {hline 2} calculates five measures of diversity for multiple categories: Generalized
 variance (GV), entropy (H), its normalized counterparts (NGV, NH), and polarization (RQ).

{title:Syntax}

{p 8 15 2}
{cmd:divcat} {varname} {ifin} {weight} [{cmd:,} {it:options} ]

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt :{opt t:ableout}}display a frequency table of {cmd:{it:varname}}
  {p_end}
{synopt :{opt b:ase(#)}}use the logarithm to base # when calculating entropy (H) (default: 2)
  {p_end}
{synopt :{opt nol:abel}}omit labels of subgroups specified using the {help by} prefix
  {p_end}
{synopt :{opt g:v}}show the generalized variance (GV) and its normalized counterpart (NGV) in a separate table (default: show
 all diversity measures in a common table)
 {p_end}
{synopt :{opt e:ntropy}}show the entropy (H) and its normalized counterpart (NH) in a separate table (default: show
 all diversity measures in a common table)
  {p_end}
{synopt :{opt r:q}}show the polarization measure (RQ) in a separate table (default: show
 all diversity measures in a common table)
  {p_end}
{synopt :{opt nod:etail}}omit common table of all diversity measures
  {p_end}
{synopt :{opt gen_gv(newvar)}}generate a new variable {cmd:{it:newvar}} containing the generalized variance (GV)
  {p_end}
{synopt :{opt gen_ngv(newvar)}}generate a new variable {cmd:{it:newvar}} containing the normalized generalized variance (NGV)
  {p_end}
{synopt :{opt gen_h(newvar)}}generate a new variable {cmd:{it:newvar}} containing the entropy (H)
  {p_end}
{synopt :{opt gen_nh(newvar)}}generate a new variable {cmd:{it:newvar}} containing the normalized entropy (NH)
  {p_end}
{synopt :{opt gen_rq(newvar)}}generate a new variable {cmd:{it:newvar}} containing the polarization measure (RQ)
  {p_end}
{synopt :{opt replace}}replace the contents of {cmd:{it:newvar}} if {cmd:{it:newvar}} exists already
  {p_end}
{synoptline}
{p2colreset}{...}
{pstd}
{hi:by} is allowed (see {help by});{p_end}
{pstd}
{opt aweight}s, {opt fweight}s, and {opt iweight}s are allowed (see {help weight}).{p_end}


{title:Description}

{pstd} {cmd:divcat} calculates five measures of diversity of a categorical
variable (i.e. for multiple categories): generalized variance (GV), entropy
(H), its normalized counterparts (NGV and NH, resp.), and polarization
(RQ). The formulas are given in Budescu and Budescu (2012) (GV, NGV, H, and
NH) and in Montalvo & Reynal-Querol (2002, 2008) (RQ). {cmd:divcat} allows to
generate new variables containing these measures, which is especially useful
when calculating diversity measures separately for subgroups (specified using
the {help by} prefix).

{pstd} There is a large variety of diversity measures. Related concepts are
variance, heterogeneity, inequality, entropy, or concentration. Depending
on the field of study, the same measures are known under different
names:

{p 4 6 2} - The {bf:GV} is also known as the Blau Index (Blau, 1977) or the Hirschman-Herfindahl
Index (HHI) (Hirschman, 1945; Herfindahl, 1950), although some equate
the HHI with the Simpson Index (SI) (Simpson, 1949), whereas GV is actually
1-SI (compare -ineq-: {net "describe ineq, from(http://fmwww.bc.edu/RePEc/bocode/i)":click here}). The
GV can be interpreted as the probability that two randomly paired members of
a population belong to two different subgroups.{p_end}
{p 4 6 2} - The {bf:NGV} is the normalized GV bounded by 0 and 1. Another name for the NGV is
the Index of Qualitative Variation (IQV) (Mueller, Schuessler, & Costner, 1970). The
index can be interpreted as the proportion of the observed variation to the
maximum possible variation. The normalizing transforms GV to a relative measure allowing
comparisons with diversity measures from studies with a different number of categories because
its size does not depend on the number of categories (as in the case of GV).{p_end}
{p 4 6 2} - The entropy measure {bf:H} shares many properties of GV (the abbreviation actually
stands for the Greek letter Eta); an attractive property is its additivity (see Budescu &
Budescu, 2012). Early on, it has been described by Shannon (1948); its formulas differ as to
the base of the logarithm used: The Shannon formula uses the logarithm to base {it:e} (see
also -ineq-: {net "describe ineq, from(http://fmwww.bc.edu/RePEc/bocode/i)":click here}), whereas
Budescu and Budescu (2012) are using the logarithm to base 2 (which is the default
of {cmd:divcat}). In the case of two groups, when using the logarithm to the base 2, H is
equal to its normalized counterpart NH.{p_end}
{p 4 6 2} - The {bf:NH} is the normalized H bounded by 0 and 1. As in the case of GV and its
normalized counterpart NGV, NH is a relative measure: its size no longer depends on
the number of categories (as in the case of H).{p_end}
{p 4 6 2} - {bf:RQ} differs from the previous measures as it is a polarization
measure for discrete variables (see Montalvo & Reynal-Querol, 2002, 2008). As do the
normalized measures, it is bounded between 0 and 1. However, in contrast to the other
measures of diversity that reach a maximum if the cases are distributed equally across all categories (or
if all groups are of the same size), RQ reaches a maximum if there are two (large) groups of equal size (and
all other groups are small). This makes RQ attractive for the study of social conflicts.{p_end}

{pstd} A helpful discussion of the properties of the "fractionalization" measures GV and H as well as
its normalized counterparts can be found in Budescu and Budescu (2012).


{title:Options}

{dlgtab:Main}

{phang}
{opt t:ableout} displays a frequency table of the categorical variable {cmd:{it:varname}}
specified with {cmd:divcat}. If subgroups are specified using the {help by} prefix, a frequency
table for each subgroup will be produced.

{phang}
{opt b:ase(#)} sets the base of the logarithm used when calculating entropy (H) (default: 2). Possible
alternatives are base 10 or the natural logarithm (base {it:e}). Note that the latter
can be specified using the option {opt base(e)}.

{phang}
{opt nol:abel} omits labels of subgroups specified using the {help by} prefix. Note that the maximum
width of row labels of the results table is 32 characters. {opt nol:abel} can help to make the values
separating the subgroups visible in spite of this space restriction.

{phang}
{opt g:v} shows the generalized variance (GV) and its normalized counterpart (NGV) in a separate
table (default: show all diversity measures in a common table)

{phang}
{opt e:ntropy} shows the entropy (H) and its normalized counterpart (NH) in a separate
table (default: show all diversity measures in a common table)

{phang}
{opt r:q} shows the polarization measure (RQ) in a separate table (default: show all diversity
measures in a common table)

{phang}
{opt nod:etail} suppresses the common table of all diversity measures (default: show all diversity
measures in a common table)

{phang}
{opt gen_gv(newvar)} generates a new variable {cmd:{it:newvar}} containing the generalized variance (GV)

{phang}
{opt gen_ngv(newvar)} generates a new variable {cmd:{it:newvar}} containing the normalized generalized
variance (NGV)

{phang}
{opt gen_h(newvar)} generates a new variable {cmd:{it:newvar}} containing the entropy (H)

{phang}
{opt gen_nh(newvar)} generates a new variable {cmd:{it:newvar}} containing the normalized entropy (NH)

{phang}
{opt gen_rq(newvar)} generates a new variable {cmd:{it:newvar}} containing the polarization measure (RQ)

{phang}
{opt replace} replaces the variable specified by {opt gen_gv()}, {opt gen_ngv()}, {opt gen_h()},
{opt gen_nh()}, or {opt gen_rq()} if {cmd:{it:newvar}} exists already.


{title:Examples}

{pstd} Example 1 shows how to calculate the diversity of "rep78" over the subgroups of "foreign", and
how to save GV into the new variable "gv" (to replicate example 1, copy and paste the two command lines
into Stata's command window):

    {cmd:sysuse auto, clear}
    {cmd:bys foreign: divcat rep78, gen_gv(gv)}

{pstd} Examples 2 and 3 demonstrate that the "fractionalization" measures (GV to NH) reach a maximum
if all cases are distributed equally across {it:all} categories of "cat" (first set of input data), whereas the
polarization measure (RQ) moves towards a maximum if the majority of cases is distributed equally
across only {it:two} categories of "cat" (second set of input data) (to replicate the examples, copy and paste the
command lines into Stata's command window):

    {cmd:clear}
    {cmd:input cat cases}
      1 33
      2 33
      3 34
    {cmd:end}
    {cmd:divcat cat [fw = cases], t base(e)}

    {cmd:clear}
    {cmd:input cat cases}
      1 48
      2 48
      3  4
    {cmd:end}
    {cmd:divcat cat [fw = cases], t base(e)}


{title:Saved Results}

{pstd} {cmd:divcat} saves the following in {cmd:r()}: {p_end}

{synoptset 14 tabbed}{...}
{p2col 5 14 18 2: Scalars}{p_end}
{synopt:{cmd:r(N_total)}}total number of cases{p_end}
{synopt:{cmd:r(bygroups)}}number of groups defined by the variables specified with prefix {help by}{p_end}
{synopt:{cmd:r(categs)}}number of categories of {cmd:{it:varname}} (of last {help by} group){p_end}
{synopt:{cmd:r(N)}}number of cases (of last {help by} group){p_end}
{synopt:{cmd:r(GV)}}generalized variance GV (of last {help by} group){p_end}
{synopt:{cmd:r(NGV)}}normalized generalized variance NGV (of last {help by} group){p_end}
{synopt:{cmd:r(H)}}entropy H (of last {help by} group){p_end}
{synopt:{cmd:r(NH)}}normalized entropy NH (of last {help by} group){p_end}
{synopt:{cmd:r(RQ)}}polarization measure RQ (of last {help by} group){p_end}

{synoptset 14 tabbed}{...}
{p2col 5 14 18 2: Macros}{p_end}
{synopt:{cmd:r(base)}}base of logarithm used to calculate the entropy H{p_end}
{synopt:{cmd:r(by)}}group variables specified using the {help by} prefix (if used){p_end}
{synopt:{cmd:r(wgt)}}weights (if used){p_end}

{synoptset 14 tabbed}{...}
{p2col 5 14 18 2: Matrices}{p_end}
{synopt:{cmd:r(div)}}matrix of diversity measures (over {help by} groups){p_end}


{title:References}

{p 4 7 2}Blau, P. M. (1977). {it:Inequality and Heterogeneity}. New York:
Free Press.{p_end}
{p 4 7 2}Budescu, D. V. & Budescu,
M. (2012). {browse "http://psycnet.apa.org/journals/met/17/2/215/":How to measure diversity when you must}.
{it:Psychological Methods}, {it:17}, 215-227.{p_end}
{p 4 7 2}Herfindahl, O. C. (1950). {it:Concentration in the U.S. Steel Industry} (unpublished
doctoral dissertation). New York, NY: Columbia University.{p_end}
{p 4 7 2}Hirschman, A. O. (1945). {it:National Power and the Structure of Foreign Trade.} Berkeley,
CA: University of California Press.{p_end}
{p 4 7 2}Montalvo, J. G. & Reynal-Querol,
M. (2002). {it:Why ethnic fractionalization? Polarization, ethnic conflict, and growth}
(mimeo). [URL: {browse "https://ideas.repec.org/p/upf/upfgen/660.html":https://ideas.repec.org/p/upf/upfgen/660.html}].{p_end}
{p 4 7 2}Montalvo, J. G. & Reynal-Querol, M. (2008). {browse "http://onlinelibrary.wiley.com/doi/10.1111/j.1468-0297.2008.02193.x/abstract":Discrete polarization with an application to the determinants of genocides}. {it:The Economic Journal},
{it:118}, 1835-1865.{p_end}
{p 4 7 2}Mueller, J. H., Schuessler, H. L., & Costner, H. L. (1970). {it:Statistical Reasoning in Sociology}. Boston: Houghton
Mifflin.{p_end}
{p 4 7 2}Shannon, C. (1948). A mathematical theory of communications. {it:Bell System Technical Journal}, {it:27},
397-423, 623-656.{p_end}
{p 4 7 2}Simpson, E. H. (1949). Measurement of diversity. {it:Nature}, {it:163}, 688.{p_end}


{title:Author}

{phang}Dirk Enzmann{p_end}
{phang}Institute of Criminal Sciences, Hamburg{p_end}
{phang}email: {browse "mailto:dirk.enzmann@uni-hamburg.de"}{p_end}
