{smcl}
{* *! version 1.2.0  1May2014}{...}
{* *! version 1.1.0  6Oct2010}{...}
{* *! version 1.0.0  15may2010}{...}
{hline}
help for {hi:epiweek and epiweek2} {right:(Tim Chu)}
{hline}

{title:Title}

{pstd}{hi:epiweek} {hline 2} Generating epidemiological week and epidemiological year from calendar date

{pstd}{hi:epiweek2} {hline 2} Generating calendar date from epidemiological week and epidemiological year


{title:Syntax}

{phang}    
{cmdab:epiweek} {it:varname} {ifin} {cmd:,} {it:epiW(newvarw)} {it:epiY(newvary)}

{pstd}{cmdab:epiweek2} {it:varname} {cmd:,} {it:Start(newvarw)} {it:End(newvary)}


{marker des}
{title:Description}

{pstd}{cmd:epiweek} creates epidemiological week and equivalent 
epidemiological year from the calendar date. US CDC and WHO definition 
the epidemiological week as:

{p 8 8 2} Each epidemiological week begins on a Sunday and ends on a Saturday. 
The first epidemiological week of year ends on the first Saturday of January, 
provided that it falls at least four or more days into the month.

{pstd}{cmd:epiweek2} converts epidemiological week and epidemiological year to 
the calendar date with the starting Sunday and the ending Saturday in the week.

{pstd} It needs to note: 

{p 8 8 2}1. Before running the epiweek program, calendar date need to assign as 
"{it:{error}%td{text}}" type. 

{p 8 8 2}2. Before running the epiweek2 program, variable with epidemiological week and 
year needs to assign as "{it:{error}string{text}}" type and format as four digit 
years following with character "W" and one or two digits for the week. for example, 2014w2.

{title:Example}

{hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse dow1}{p_end}

{pstd}Create new variables {cmd:epi_week} and {cmd:epi_year} from calendar date {p_end}
{phang2}{cmd:. epiweek date, epiw(epi_week) epiy(epi_year)}{p_end}

{pstd}Create new variables - calendar date with starting Sunday {cmd:from} and ending Saturday {cmd:to}{p_end}
{phang2}{cmd:. egen wy = concat(epi_year epi_week), p(w)}{p_end}
{phang2}{cmd:. epiweek2 wy, s(from) e(to)}{p_end}

{title:Author}

{pstd}Tim Chu{p_end}
{pstd}Epidemiologist/Biostatistician{p_end}
{pstd}Vancouver Coastal Health{p_end}
{pstd}Vancouver, Canada{p_end}
{pstd}{browse "mailto:tim.chu@vch.ca":tim.chu@vch.ca}



