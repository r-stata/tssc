{smcl}
{* *! version 0.9  18mar2015}{...}
{viewerjumpto "Syntax" "percentmatch##syntax"}{...}
{viewerjumpto "Description" "percentmatch##description"}{...}
{viewerjumpto "Options" "percentmatch##options"}{...}
{viewerjumpto "Remarks" "percentmatch##remarks"}{...}
{viewerjumpto "Examples" "percentmatch##examples"}{...}
{viewerjumpto "Returned Results" "percentmatch##returned_results"}{...}
{viewerjumpto "Author" "percentmatch##author"}{...}
{title:Title}

{phang}
{bf:percentmatch} {hline 2} Calculate the highest percentage match (near duplicates) between observations


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:percentmatch}
[{varlist}]
{if}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt gen:erate(newvar)}}Create variable {it:newvar} highest percent match{p_end}
{synopt:{opt id:var}}Uniquely identifying variable in the dataset{p_end}
{synopt:{opt matchedid(newvar)}}Create variable {it:newvar} highest match observation's {it:idvar}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:percentmatch} calculates the highest percent match between observation across
the variables in {varlist} (or across all variables if {it:varlist} is not specified). 
Similar to {duplicates}, {cmd:percentmatch}, compares observations to identify 
identical values. The match percentage is given by the number of identical values 
divided by the number of variables. {cmd:percentmatch} returns the highest match percentage 
for each observation.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth generate(newvar)} creates {it:newvar} containing the highest match percentage.

{phang}
{opt idvar} specifies the uniquely identifying id variable in the dataset. If
the variable doesn't exist in the dataset, it must be created before using
{cmd:percentmatch}. 

{phang}
{opth matchedid(newvar)} creates {it:newvar} with the corresponding highest percentage 
match value for {it:idvar} for each observation. i.e. observation a's highest match was 
with observation b. 


{marker remarks}{...}
{title:Remarks}

{pstd}
This command was developed to detect near duplicates in survey data. See Kuriakose and 
Robbins 2015, Detecting Falsification in Survey Data for more details.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse nlsw88, clear}{p_end}
{phang}{cmd:. percentmatch, generate(pmatch) idvar(idcode) matchedid(m_id)}{p_end}

{phang}{cmd:. sysuse nlsw88, clear}{p_end}
{phang}{cmd:. percentmatch age - wage, gen(pmatch) id(idcode) matchedid(m_id)}{p_end}

{phang}{cmd:. sysuse bpwide, clear}{p_end}
{phang}{cmd:. percentmatch, generate(pmatch) idvar(patient) matchedid(m_id)}{p_end}

{marker returned_results}{...}
{title:Returned Results}

Scalars:
{p2colset 5 20 20 2}{...}
{p2col : {cmd:r(p100)}}Number of observations with 100% match{p_end}
{p2col : {cmd:r(p95)}}Number of observations with 95% match{p_end}
{p2col : {cmd:r(p90)}}Number of observations with 90% match{p_end}
{p2col : {cmd:r(vars)}}Number of variables over which match was calculated{p_end}
{p2col : {cmd:r(N)}}Number of observations over which match was calculated{p_end}

Macros:
{p2col : {cmd:r(varlist)}}Variables over which match was calculated{p_end}
{p2colreset}{...}

{marker author}{...}
{title:Author}

{pstd} Noble L. Kuriakose, SurveyMonkey, noblek@surveymonkey.com

{pstd} Please cite this program by referencing the paper below:

{pmore} Kuriakose, Noble and Robbins, Michael, Falsification in Surveys: Detecting Near Duplicate Observations (March 18, 2015). Available at SSRN: http://ssrn.com/abstract=2580502

 