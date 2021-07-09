{smcl}
{* *! version 0.4.1 08jul2020}{...}
{vieweralsosee "[D] egen: resp" "help _gresp"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] egen" "help egen"}{...}
{vieweralsosee "[D] generate" "help generate"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] egen" "mansection D egen"}{...}
{viewerjumpto "Syntax" "_gresp##syntax"}{...}
{viewerjumpto "Description" "_gresp##description"}{...}
{viewerjumpto "Options" "_gresp##options"}{...}
{viewerjumpto "Remarks" "_gresp##remarks"}{...}
{viewerjumpto "Examples" "_gresp##examples"}{...}
{viewerjumpto "Stored results" "_gresp##results"}{...}
{viewerjumpto "Author" "_gresp##author"}{...}
{viewerjumpto "References" "_gresp##References"}{...}
{title:Title}

{phang} 
{hi:[D] egen: resp} {hline 2} RESP for {help egen}.
{p_end}

{marker syntax}{...}
{title:Syntax}

{phang} 
Generate a new variable with AI, RPA, RSI or RESP values{...}
    using Stata's {help egen} command.
{p_end}

{pmore}
[{help by:{bf:by} {it:varlist}{bf::}}]
{cmd:egen}
{dtype}
{newvar}
{cmd:=}
{cmd:resp}{cmd:(}{varname}{cmd:)}
{ifin}{cmd:,}
{cmdab:d:im(}{var:1} {var:2}{cmd:)}
[{cmdab:m:ode(}{help strings:string}{cmd:)}
{cmdab:dup:licates}]
{p_end}

{phang} 
There is a wrapper for the above function.
{p_end}

{pmore}
[{help by:{bf:by} {it:varlist}{bf::}}]
{cmd:resp}
{newvar}
{varname}
{ifin}{cmd:,}
{cmdab:d:im(}{var:1} {var:2}{cmd:)}
[{cmdab:m:ode(}{help strings:string}{cmd:)}
{cmdab:dup:licates}]
{p_end}



{synoptset 30 tabbed}{...}
{synopthdr:Option}
{synoptline}
{synopt:{cmdab:d:im(}{var:1} {var:2}{cmd:)}}{...}
    defines the variables for aggregation (see below);{p_end}
{synopt:{cmdab:m:ode(}{help strings:string}{cmd:)}}{...}
    {help strings:string} is one of {cmd:[ai|rpa|rsi|resp]};{...}
	default is {cmd:ai};{p_end}
{synopt:{cmdab:dup:licates}} tests for duplicates; default is {hi:no} testing;{p_end}
{synoptline}
{p2colreset}{...}



{marker description}{...}
{title:Description}

{pstd} 
{cmd:resp} is an extended function for {help egen}. It calculates the activity
index or its forks for a variable, i.e. the fraction consisting of the relation
of an observation identified by the tuple {cmd:(}{var:1} {var:2}{cmd:)} to the 
sum of all observations identified by the same value of {var:1} in the 
identifying tuple as dividend and the relation of the sum of all observations
identified by the same value of {var:2} in the identifying tuple to the
sum of all observations as divisor. {break}
Symbolical:
{p_end}

{center:{cmd:resp(}{it:x}{cmd:)} = {it:x}/{it:sum}(x|{var:1}) : {it:sum}(x|{var:2})/{it:sum}({it:x})}
{center: with {it:x} identified by the tuple ({var:1} {var:2}).}

{marker options}{...}
{title:Options (extended)}

{phang} 
{cmdab:d:im(}{var:1} {var:2}{cmd:)} defines the two dimensions for which the
Activity Index is calculated. Therefore, sums are generated along {var:1},
{var:2} and overall. Afterwards, every observation of {varname} is divided
by that sum along {var:1}, which shares the same value in {var:1} as
{varname}. Furthermore, the result is divided by the fraction of that sum
along {var:2}, sharing the same value in {var:2} as {varname}, and the
overall sum.
{p_end}

{phang} 
{cmdab:m:ode(}{help strings:string}{cmd:)} controlls the kind of index, which is
given back. Possible options for {help strings:string} are 
{cmd:[ai|rpa|rsi|resp]}. Thereby {cmd:ai} stands for the {hi:Activity Index} (see
above); {cmd:rpa} stands for the natural logarithm of the Activity Index or -
as so called - the {hi:Relative Patent Activity} (see also {help ln}); {opt RSI} for
the {hi:Relative Specialization Index}, i.e. {bind:({it:ai} - 1)/({it:ai} + 1)}; and
{cmd:resp} for the hyperbolic tangent of the Relative Patent Activity or -
also called - the {hi:Index of Relative Specialization}, i.e.
{bind:({it:ai^2} - 1)/({it:ai^2} + 1)} scaled by {it:100}. {cmd:ai} is the default.
{p_end}

{phang} 
{cmdab:dup:licates} tests, if any tuple of {cmd:(}{var:1} {var:2}{cmd:)} is
unique in every group defined by {help by:{bf:by} {it:varlist}}. Is this condition
not fullfilled, the program aborts. Because of the aggregation along {var:1},
{var:2} and all observations, the uniqueness of the tuples is not required.
Nevertheless it is often assumed and sensible. The default is to {hi:not} test
on duplicates.
{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd} 
In the second half of the 20th century economists tried to measure comparative
advantages. It was observed, that simple relations could not reveal all 
informations about partitions of ressources. For example, neither the relation
of exported cars from Belgium to all exports of Belgium, nor the relation of 
exported cars from Belgium to all exported cars worldwide gives us a degree
of competitiveness of Belgiums car industry. The first relation is an internal
one. The second one does not consider, that Belgium is not capable of producing
numbers of cars like really large countries. (No offence, Belgium!) The
{hi:Activity Index} combines the two relations in the way, that the country
internal relation of exported cars to all exports of a country is compared
to the external relation of exported cars to all exports worldwide. For more
informations about this subject, see {help _gresp##references:the references}
(especially {help _gresp##ref_grupp1994:Grupp 1994}, {help _gresp##ref_grupp1998:Grupp 1998}
and {help _gresp##ref_narin1987:Narin et al. 1987}).
{p_end}

{pstd} 
The {hi:Activity Index (AI)} lacks some essential properties, so some common 
transformations have been established. For statistic calculations the 
{hi:Relative Patent Activity (RPA)} Index has proven to be usefull. It is the
natural logarithm of the {hi:AI}. Both, {hi:AI} and {hi:RPA} are not easy to 
comprehend for a reader, so in presentations or papers two other transformations
are often used instead: the {hi:Relative Specialization Index (RSI)} and the
{hi:Index of Relative Specialization (RESP)}. The latter is the hyperbolic
tangent of the {hi:RPA} scaled by {it:100}, the former the hyperbolic tangent of
half of the {hi:RPA} without scaling at the end.
{p_end}

{pstd} 
It seems, {hi:RSI} and {hi:RESP} are quite the same. They are, but the {hi:RSI}
emphasizes differences around its center (i.e. {it:0}), while the {hi:RESP}
emphasizes differences at the edges (i.e. {it:-100} and {it:100}). Both indices
are applicated in a grand scale, if it comes to {hi:higher education research}.
For example, {it:Piro et al.} used the {hi:RSI} to compare all nordic universities (see 
{help _gresp##ref_piro2011:Piro et al. 2011}, {help _gresp##ref_piro2014:Piro et al. 2014}
and {help _gresp##ref_piro2017:Piro et al. 2017}), while {it:Heinze et al.} used
the {hi:RESP} to compare all german universities and their fields (see
{help _gresp##ref_heinze2019:Heinze et al. 2019} and
{help _gresp##ref_fachprof:Research and teaching profiles of public universities in Germany}).
{p_end}

{marker examples}{...}
{title:Examples}

{pstd}
The example uses the {it:Foreign Affiliates Statistics} from {browse "https://data.wto.org/":WTO Data}.
The data contains the sales by services for the Eurozone and the
years 2011 to 2015 (outward and inward sales differenciated).
For more information, see {it:resp_metadata.csv} and {it:resp_disclaimer.txt}.
{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse resp.dta, clear}{p_end}
{phang2}{cmd:. keep indicatorcode reportingeconomyiso3acode productsectorcode year value}{p_end}
{phang2}{cmd:. rename (*) (indicator country sector year v)}{p_end}
{phang2}{cmd:. reshape wide v, i(country sector year) j(indicator) string}{p_end}

{pstd}Proportions of countries on a sector (outward sales){p_end}
{phang2}{cmd:. sort year sector}{p_end}
{phang2}{cmd:. by year sector: egen prop_out = total(vSER_FA_TUR_O)}{p_end}
{phang2}{cmd:. replace prop_out = vSER_FA_TUR_O/prop_out}{p_end}

{pstd}AI for outward sales on countries and sectors{p_end}
{phang2}{cmd:. by year: egen ai_o = resp(vSER_FA_TUR_O), dim(country sector)}

{pstd}RESP for outward sales, this time using wrapper{p_end}
{phang2}{cmd:. by year: resp resp_o vSER_FA_TUR_O, dim(country sector) mode(resp)}{p_end}

{pstd}Analyzing Belgiums outwarded sales in the year 2015{p_end}
{phang2}{cmd:. format prop_o resp_o %9.3f}{p_end}
{phang2}{cmd:. table prop_o resp_o if year == 2015 & country == "BEL", sep(0)}{p_end}
{pmore}Even though Belgium's contribution to the outwarded sales in the Eurozone
is almost {it:0.03} or lower, in the sectors {it:ADMIN}, {it:FIN} and {it:PROF}
Belgium has quite high {it:RESP} values. This indicates, these are focal sectors
 for Belgium.{p_end}

{marker results}{...}
{title:Stored results}

{pstd} 
{cmd:resp} stores the following in {cmd:r()}:
{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 0 0: Macros}{p_end}
{synopt:{cmd:r(cmdline)}}exact command passed to {cmd:egen}{p_end}
{p2colreset}{...}

{marker author}{...}
{title:Author}

{pstd} 
Joel E. H. Fuchs a.k.a Fantastic Cpt. Fox{break}
Organizational Sociology, University of Wuppertal.{break}
jfuchs{cmd:(}at{cmd:)}uni-wuppertal.de
{p_end}

{marker references}{...}
{title:References}

{marker ref_fachprof}{...}
{pstd} 
Research and teaching profiles of public universities in Germany. 2019. URL:
{browse "https://fachprofile.uni-wuppertal.de/en.html":{it:fachprofile.uni-wuppertal.de}}.
{p_end}

{marker ref_grupp1994}{...}
{pstd} 
Grupp, H. 1994. "The Measurement of Technical Performance of Innovations
by Technometrics and Its Impact on Established Technology Indicators."
Research Policy 23, Pp. 175‐93.
{p_end}

{marker ref_grupp1998}{...}
{pstd} 
Grupp, H. 1998. "Measurement with Patent and Bibliometric Indicators."
Pp. 141‐88 in Foundations of the Economics of Innovation. Theory, Measurement,
Practice, edited by H. Grupp. Cheltenham: Edward Elgar.
{p_end}

{marker ref_heinze2019}{...}
{pstd} 
Heinze, T., Tunger, D., Fuchs, J.E., Jappe, A., Eberhardt, P. 2019.
"Research and teaching profiles of public universities in Germany.
A mapping of selected fields." Wuppertal: BUW. (DOI: 10.25926/9242‐ws58).
{p_end}

{marker ref_narin1987}{...}
{pstd} 
Narin, F., Carpenter, M.P. and Woolf, P. 1987.
"Technological Assessments Based on Patents and Patent Citations."
Pp. 107‐19 in Problems of Measuring Technological Change,
edited by H. Grupp. Köln: TÜV Rheinland.
{p_end}

{marker ref_piro2011}{...}
{pstd} 
Piro, F.N., Aksnes, D.W, Christensen, K.K., Finnbjörnsson, Þ.,
Fröberg, J., Gunnarsdottir, O., Karlsson, S., Klausen, P.H., Kronman, U., Leino,
Y., Magnusson, M.L., Miettinen, M., Nuutinen, A., Poropudas, O.,
Schneider, J.W. and Sivertsen, G. 2011.
"Comparing Research at Nordic Universities Using Bibliometric Indicators."
Policy Brief 4/2011. Oslo: NordForsk.
{p_end}

{marker ref_piro2014}{...}
{pstd} 
Piro, F.N., Aldberg, H., Finnbjörnsson, P., Gunnarsdottir, O.,
Karlsson, S., Larsen, K.S., Leino, Y., Nuutinen, A., Schneider, J.W.,
and Sivertsen, G. 2014.
"Comparing Research at Nordic Universities Using Bibliometric Indicators
– Second Report, Covering the Years 2000‐2012." Policy Paper 2/2014.
Oslo: NordForsk.
{p_end}

{marker ref_piro2017}{...}
{pstd} 
Piro, F.N., Aldberg, H., Aksnes, D.W., Staffan, K.,
Leino, Y., Nuutinen, A., Overballe‐Petersen, M.V.,
Sigurdsson, S.O. and Sivertsen, G. 2017.
"Comparing Research at Nordic Higher Education Institutions
Using Bibliometric Indicators Covering the Years 1999‐2014."
Policy Paper 4/2017. Oslo: NIFU.
{p_end}
