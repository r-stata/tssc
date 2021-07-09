{smcl}
{* 25apr2012}
{hline}
help for {hi:scm}
{hline}

{title:Social Cognitive Mapping}

{p 8 16 2}{cmd:scm}
   {it:infilename}
   {cmd:,}
   [ {it:options} ]

{title:Description}

{p 4 4 2}
{cmd:scm} processes group nomination data described by {it:infilename} for the detection of interaction, conomination, and similarity groups using Cairns' "Social Cognitive Mapping" procedure.
This command does not affect the data in memory.


{title:Options}
{p 4 8 2}{cmd:{ul:rep}orters(}{it:int}{cmd:)} reports interaction groups and their corresponding levels of consensus; {it:int} specifies the number of respondents providing reports of group membership.{p_end}
{p 4 8 2}{cmd:conom({ul:diag}onal} | {cmd:{ul:norm}alize)} specifies special treatment of the co-nomination matrix (see notes below).{p_end}
{p 4 8 2}{cmd:minsim(}{it:real}{cmd:)} dichotomizes the similarity matrix such that Aij = 1 if the Pearson correlation coefficient of {it:i}'s and {it:j}'s conomination profiles is at least {it:real}, and otherwise is 0.{p_end}
{p 4 8 2}{cmd:{ul:savel}og(}{it:outfilename}{cmd:)} saves the displayed output as a text file named {it:outfilename.txt}.{p_end}
{p 4 8 2}{cmd:{ul:savem}atrix(}{it:outfilename}{cmd:)} saves the co-nomination matrix as a comma-delimited file named {it:outfilename_conom.csv}, and the similarity matrix as a comma-delimited file named {it:outfilename_sim.csv}.{p_end}
{p 4 8 2}{cmd:{ul:noi}solates} excludes from analysis all individuals who were not nominated as a member of any group.{p_end}


{title:Treatment of the co-nomination matrix}
{p 4 4 2}By default, the co-nomination matrix includes only off-diagonal cells, in which Aij = the number of times individual {it:i} and {it:j} were named as members of the same group.
The {cmd:conom} option can be used to modify this:{p_end}
{p 6 6 4}{cmd:conom(diagonal)} specifies that the diagonal cells be included in the co-nomination matrix, where Aii = the total number of times that individual {it:i} was named as a member of any group.
This option yields results that mirror those produced by the SCM 4.0 software, but is not recommended because the resulting "similarity" matrix cannot be interpreted as displaying similarities in individuals' co-nomination profiles.

{p 6 6 4}{cmd:conom(normalize)} specifies that the off-diagonal cell values, Aij, be normalized to control for the total number of times that individuals {it:i} and {it:j} were each nominated as group members.{p_end}


{title:Input}
{p 4 4 2}{it:infilename} must be a comma-delimited file in which rows represent individuals, and columns represent reported group memberships, such that cell Aij = 1 if person {it:i} is reported to be a member of group {it:j}, and otherwise is 0.
The first column must contain IDs, which may include any combination of numbers and letters.{p_end}


{title:References}
{p 0 5}
Neal, J. W., Neal, Z. P.  (In press).  The multiple meanings of peer groups in social cognitive mapping, {it:Social Development} doi: 10.1111/j.1467-9507.2012.00656.x.

{p 0 5}
Cairns, R. B., Perrin, J. E., & Cairns, B. D.  (1985).  Social structure and social cognition in early adolescence: Affiliative patterns, {it:The Journal of Early Adolescence}, 5, 339-355.


{title:Author}
Zachary Neal
Department of Sociology
Michigan Sate University
zpneal@msu.edu
