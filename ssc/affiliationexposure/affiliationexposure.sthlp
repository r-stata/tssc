{smcl}
{* *! version 1.0.0  1jun2011}{...}
{cmd:help affiliationexposure} 
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col : affiliationexposure {hline 2}}Compute the Affiliation Exposure Model for two-mode network data{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
affiliationexposure {it:modevars} {cmd:,} {opt attrib:ute}({it:attribvar}) {opt res:ult}({it:resultvarname})

{title:Description}

{pstd}
{cmd:affiliationexposure} calculates the Affiliation Exposure metric based on one or more {it:modevars} and a single {it:attribvar}, placing 
the results in {it:resultvarname}. Only one set of data in memory is supported at this time. {it:attribvar} is not constrained in any way, but caution should be used
if the scale is not linear (ranks are okay). Missing values are treated as zeros.


{title:Example:  computing the affiliation exposure based on three events for one (ranked) attribute}

{phang2}{cmd:. use my_twomode_data}{p_end}
{phang2}{cmd:. list}{p_end}
     +--------------------------------+
     | event1   event2   event3   a1  |
     |--------------------------------|
  1. |      0        0        1    1  |
  2. |      1        1        0    1  |
  3. |      0        0        1    5  |
  4. |      1        0        0    4  |
  5. |      1        0        0    4  |
     +--------------------------------+

{phang2}{cmd:. affiliationexposure event1 event2 event3, attrib(a1) result(ae_a1)}{p_end}
{phang2}{cmd:. list}{p_end}
     +--------------------------------------+
     | event1   event2   event3   a1  ae_a1 |
     |--------------------------------------|
  1. |      0        0        1    1      5 |
  2. |      1        1        0    1      4 |
  3. |      0        0        1    5      1 |
  4. |      1        0        0    4    2.5 |
  5. |      1        0        0    4    2.5 |
     +--------------------------------------+


{title:Reference}

{phang}
Kayo Fujimoto, Jennifer Unger, and Thomas W. Valente. "Network Method of Measuring Affiliation-based Peer Influence: Assessing the Influences of Teammates Smokers on Adolescent Smoking." {it:Child Development}, 
PMCID#299349.

