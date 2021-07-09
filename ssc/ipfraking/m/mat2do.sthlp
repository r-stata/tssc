{smcl}
{* *! version 0.8  15may2012}{...}
{cmd:help mat2do} {right: ({browse "http://web.missouri.edu/~kolenikovs/stata/":Stas Kolenikov's webpage})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{hi:mat2do} {hline 2}}Save Stata matrix as a do-file{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}
{cmd:mat2do }{it:matname}{cmd: using }{it:filename}
[{cmd:,} {it:options}]

{synoptset 43 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{cmd:replace}}overwrite the existing file{p_end}
{synopt :{cmd:append}}add to the existing file{p_end}
{synopt :{cmd:list}}add {cmd:matrix list} command to the end of the do-file{p_end}
{synopt :{cmd:type}}list the matrix and the resulting do-file{p_end}
{synopt :{cmd:notimestamp}}omit the time stamp at the header of the file{p_end}


{title:Description}

{pstd}{cmd:mat2do} stores the values and the attributes (row and column names)
of a Stata matrix as a do-file. By running this do-file, the matrix can be fully
reproduced. The names of the matrix and the do-file are required.
{p_end}


{title:Author}

{pstd}Stanislav Kolenikov{p_end}
{pstd}Senior Scientist{p_end}
{pstd}Abt Associates{p_end}
{pstd}skolenik at gmail dot com{p_end}


{title:Also see}

{psee}{help matrix rownames}, {help mata matsave}


