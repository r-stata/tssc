{smcl}
{* 17may13}{...}
{hline}
help for {hi:tabexp}
{hline}

{title:Title}

{p 4 4 2}{hi:tabexp} {hline 2} Table of births and exposure from birth history data


{p 4 4 2}{hline 2} Please report problems and send comments and suggestions to bruno.schoumaker@uclouvain.be


{title:Table of contents}

     {help tfr2##syn:Syntax}
     {help tfr2##des:Description}
     {help tfr2##opt:Options}
     {help tfr2##exa:Examples}

     {help tfr2##ack:Acknowledgments}
     {help tfr2##cit:Citing tabexp}
     {help tfr2##ref:References}
     {help tfr2##dis:Disclaimer}
     {help tfr2##aut:Author}


{marker syn}
{title:Syntax}

{p 8 15 2}    
{cmdab:tabexp} [ {it:varlist} ] [ {cmd:if} {it:exp} ] 
[ {it:pweight}{cmd: = }{it:exp} ] 
[ {cmd:,} {it:options} ]


    {it:options} {col 26}{it:summary} {col 90}{it:default}
    {hline 100}
    
     {help tfr2##main:Main}
{col 4}	 {cmdab:bv:ar(}{it:varlist}{cmd:)} {col 26}names of birth variables {col 90}b3_01 to b3_20 (or lower)
{col 4}	 {cmdab:len:gth(}{it:integer}{cmd:)} {col 26}length of the period covered (years) {col 90}3
{col 4}	 {cmdab:date:s(}{it:var}{cmd:)} {col 26}date of survey (CMC) {col 90}v008
{col 4}	 {cmdab:wb:irth(}{it:var}{cmd:)} {col 26}date of birth of woman (CMC) {col 90}v011
{col 4}	 {cmdab:ag:eg(}{it:integer}{cmd:)} {col 26}size of age groups (years) {col 90}5
     {help tfr2##Opt:Options}
{col 4}	 {cmdab:cl:uster(}{it:var}{cmd:)} {col 26}cluster identifiers - jackknife {col 90}
{col 4}	 {cmdab:awf:(}{it:var}{cmd:)} {col 26}all women factor {col 90}awfactt
{col 4}	 {cmdab:tr:end(}{it:integer}{cmd:)} {col 26}time interval for the preparation of the table by periods (years) {col 90}
{col 4}	 {cmdab:mina:ge(}{it:integer}{cmd:)} {col 26}minimum age for the table (years) {col 90}15
{col 4}	 {cmdab:maxa:ge(}{it:integer}{cmd:)} {col 26}maximum age for table (years) {col 90}49
{col 4}	 {cmdab:end:y(}{it:integer}{cmd:)} {col 26}defines the last year of the estimation period {col 90}
{col 4}	 {cmdab:entry:(}{it:var}{cmd:)} {col 26}date of entry in the risk set (e.g. marriage for marital fertility rates) in CMC {col 90}
{col 4}	 {cmdab:frm:}{it:}{cmd:} {col 26}uses fractional months (day of birth is randomly attributed to women and children) {col 90}
{col 4}	 {cmdab:cy:ears}{it:}{cmd:} {col 26}events and exposure rates computed over calendar years{col 90}
{col 4}	 {cmdab:rate:s}{it:}{cmd:} {col 26}displays fertility rates and their standard errors{col 90}
     {help tfr2##sav:Saving options}
{col 4}	 {cmdab:savetab:(}{it:filename}{cmd:)} {col 26}saves table of births and exposure in a Stata file {col 90}
     {help tfr2##oth:Other options}
{col 4}	 {cmdab:force:} {col 26}replaces the data set in the memory by the table of events and exposure {col 90}
{col 4}	 {cmdab:nodis:} {col 26}results are not displayed {col 90}
{col 4}	 {cmdab:dv:} {col 26}displays the name of the variables used by tabexp {col 90}


{p 8 8 2}
{cmd:by }is allowed with tabexp.

{p 8 8 2}
{cmd:xi }is allowed with tabexp.

{p 8 8 2}
{cmd:pweight} is allowed with {cmd: tabexp}. By default, v005 is used as the weighting variable (name of weights in DHS).

{p 8 8 2}
Note that {cmd:tabexp} will work under Stata 10.0 onward.


{marker des}
{title:Description}

{p 4 4 2}{cmd:tabexp} is a program for preparing tables of births and exposure from birth histories. It is conceived to be used
with individual recode files of Demographic and Health Surveys (DHS), but it can be used with any data file organized in the same way as a DHS file (see example with WFS data below).

{p 4 4 2} {cmd:tabexp} can be used to prepare tables of births and exposure to replicate results published in DHS reports (http://www.measuredhs.com/help/Datasets/Age-Specific_Fertility_Rates.htm). 

{p 4 4 2} The data file must be organized using the following principles : (1) each line corresponds to a woman. (2) the dates of births (in CMC) of all the children are recorded in seperate variables (e.g. b3_01 b3_02...b3_20).
This is the way birth histories are organized in DHS standard recode data files.

{p 4 4 2} All dates should be in Century Month Code (CMC).

{p 4 4 2} The following table illustrates the data of a birth history in a DHS. v008 is the date of the survey, v011 is the date of birth of the woman, and b3_01, b3_02,... are the dates of births of all the children. 

{p 4 4 2} The order of births does not matter.

	{c TLC}{hline 40}{c TRC}
	{c |} {it:id}  {it:v008}  {it:v011}  {it:b3_01}  {it:b3_02}  {it:b3_03} {it:...}{c |}
	{c |}{hline 40}{c |}
	{c |}  1  1050  491   1004   943    935      {c |}
	{c |}  2  1048  795   1011   .      .        {c |}
	{c |}  3  1047  708   946    .      .        {c |} 
	{c |}  4  1050  833   .      .      .        {c |} 
	{c BLC}{hline 40}{c BRC}
 

{p 4 4 2} {cmd:tabexp} computes events and exposure on periods defined in various ways (e.g. 3 years before the survey, 5 years before the survey, 
last 5 calendar years...). 

{p 4 4 2} Events and exposure are computed between exact ages (in rectangles of Lexis diagrams). By default, they are computed for periods defined as "years preceding the survey", but they can be estimated by calendar years {cmd:(cy)}.

{p 4 4 2} {cmd:tabexp} can include covariates, and can also be used to prepare tables of births and exposure to compute fertility trends {cmd:(trend)}. 


{marker opt}
{title:Options}

    Contents

     {help tfr2##main:Main}
     {help tfr2##opt:Options}   
     {help tfr2##sav:Save options} 
     {help tfr2##grph:Graph options} 

{marker main}
{dlgtab:Main options}

{phang}
{opt bvar}({it:varlist}) indicates the name of the variables containing the birth dates of the children. 
if not indicated, b3* is used as the variable names. The birth dates of children should be 
in CMC.

{phang}
{opt length}({it:#}) indicates the length of the period for the preparation of the table. 
By default, the length is equal to 3 years. 

{phang}
{opt dates}({it:varname}) is a variable containing the date of the survey (in CMC). By default, v008 is used. Some months can be subtracted from the date of the survey. For instance, instead of using {cmd:dates}(v008), one can use {cmd:dates}(v008-36).

{phang}
{opt wbirth}({it:varname}) is a variable containing the date of birth of women (in CMC). By default, v011 is used.
 
{phang}
{opt ageg}({it:#}) is the size of age groups for the computation of births and exposure. By default, 5-year age groupes are used.


{marker opt}
{dlgtab: Options}

{phang}
{cmd: cluster}({it:varname}) indicates the name of the variable containing the identifiers of the primary sampling units. This is used by tfr2 to compute standard errors with the jackknife method.


{phang}
{cmd: awf}({it:varname}) indicates the name of the variable containing the "all women factor" to be used. This is necessary in surveys where only 
ever married women were interviewed (e.g. Bangladesh, Pakistan,...). By default, the variable awfactt is used if it is found in the data file.

{phang}
{cmd: trend}({it:#}) is used to compute tables for separate periods. The integer indicates the size of the intervals for computing births and exposure. For instance, a value of 1 means that  
births and exposure are computed by 1-year intervals. If  {cmd: trend} is used, it should be lesser or equal than {cmd: length}.

{phang}
{cmd: minage}({it:#}) is used to set the minimum age to compute births and exposure. The default value is 15.

{phang}
{cmd: maxage}({it:#}) is used to set the maximum (completed) age to compute  births and exposure. The default value is 49.

{phang}
{cmd: endy}({it:#}) is used to define the last year of the estimation period. It overrides {cmd: dates} if both are used.

{phang}
{cmd: entry}({it:varname}) is used to compute  births and exposure after a date (that may vary across individuals). For instance, it can be used to compute births and exposure in marriage, by including the date of marriage (in CMC).

{phang}
{cmd: cyears} is used to compute births and exposure over calendar years. By default, they are computed for years preceding the survey.

{phang}
{cmd: rates} computes fertility rates (births/exposure) and their standard errors [rate/root(births)]. 


{marker sav}
{dlgtab: Save options}

{phang}
{cmd: savetable} saves the table of births and exposure in a Stata file. To overwrite an existing file, use {cmd: savetable}({it:filename}, replace).

{marker oth}
{dlgtab: Other options}

{phang}
{cmd: force} replaces the data set in the memory by the table of events and exposure.

{phang}
{cmd: nodis} results are no displayed.

{phang}
{cmd: dv} displays the names of the variables used by tabexp. This is useful for checking that the correct variables are used.



{marker exa}
{title:Examples with DHS data}

        {txt} Individual recode data files can be obtained from MeasureDHS (www.measuredhs.com).
	{txt} Once you have downloaded the individual recode Stata file for a survey, open it:

        {com}. use KEIR51FL.DTA, clear

        {txt} This opens the file of the 2008 Kenya DHS.

        {txt} {cmd:tabexp} can then be used to prepare a table of births and exposure.


{p 4 4 2}

{dlgtab:Table for last x years before the survey}

        {com}. tabexp 
		
        {txt} Births and exposure (5-year age groups) for the 3 years preceding the survey.

	{txt} This is equivalent to 

        {com}. tabexp [pweight=v005], ageg(5) len(3) wb(v011) dates(v008) awf(awfactt) 
		
        {txt} Births and exposure (5-year age groups) for the 3 years preceding the survey.

       {com}. tabexp, len(5) 
		
        {txt} Births and exposure (5-year age groups) for the 5 years preceding the survey.

        {com}. tabexp, len(1) 
		
        {txt} Births and exposure (5-year age groups) for the year preceding the survey.

        {com}. tabexp, ageg(1) 
		
        {txt} Births and exposure (by single year) and TFRs for the 3 years preceding the survey.

        {com}. tabexp, force 
		
        {txt} Births and exposure (5-year age groups) for the year preceding the survey, replaces the data file in memory.


{dlgtab:Births and exposure for x calendar years before the survey}

        {com}. tabexp, len(4) cy 
		
        {txt} Births and exposure (5-year age groups) for the 4 calendar years preceding the survey 
	{txt} (if the survey was conducted in 1999 - computed for the period 1995-1998)


{dlgtab:Births and exposure for last x years before the survey by cluster}

        {com}. tabexp, len(3) cluster(v001)
		
        {txt} Births and exposure (5-year age groups) for the 3 years preceding the survey by variable v001 (cluster identifier).

{dlgtab:Births and exposure for last x specific calendar years}

        {com}. tabexp, len(3) endy(1999)
		
        {txt} Births and exposure (5-year age groups) for the 3-year period ending in 1999.
	{txt} Births and exposure are computed for the period from 1/1997 to 12/1999.

{dlgtab: Births and exposure in marriage for the x years preceding the survey}

        {com}. tabexp, len(5) entry(v509) 
		
        {txt} Marital ASFRs (5-year age groups) and TFRs for the 5 years preceding the survey.



Births and exposure by periods


{dlgtab:Births and exposure by calendar years for x calendar years before the survey}

        {com}. tabexp, len(15) trend(1) cy
		
        {txt} Births and exposure (5-year age groups) for the 15 calendar years preceding the survey.

{dlgtab:Births and exposure by calendar years for x calendar years before the survey between ages 20 and 39}

        {com}. tabexp, len(15) trend(1) mina(20) maxa(39) cy
		
        {txt} Births and exposure (5-year age groups) for the 15 calendar years preceding the survey.


Explanatory variables


{dlgtab:Births and exposure (5-year age groups) for x calendar years before the survey by categories of a variable}

        {com}. tabexp v106
		
        {txt} Births and exposure (5-year age groups) for the 3 years preceding the survey by category of v106 (using one variable with original labels).


        {com}. tabexp v025, awf(awfactu)

        {txt} Same as in previous example, but the 'all women factor' is used for rural-urban comparisons.


        {com}. xi: tabexp i.v106
		
        {txt} Births and exposure (5-year age groups) for the 3 years preceding the survey by category of v106 (using dummy coding).


Saving files and displaying graph


{dlgtab:Births and exposure for x calendar years before the survey saved in a Stata file}

        {com}. tabexp, len(15) trend(1) cy gt savetab(c:\table, replace)
		
        {txt} Births and exposure for the 15 calendar years preceding the survey, saved in a file.


{marker exa}
{title:Examples with WFS data}
	

{dlgtab:Births and exposure for last 3 years before the survey by single year of age}

        {com}. use http://data.princeton.edu/eco572/datasets/cofertx, clear
        {com}. tabexp, dates(v007) wb(v008) bvar(b0*2 b1*2) ageg(1)  
		
        {txt} see fertility rates in the 1976 WFS in Colombia on Germán Rodriguez's website (http://data.princeton.edu/eco572/asfr.html).



{marker ack}
{title:Acknowledgements}

{marker cit}
{title:Citing tabexp}

Schoumaker Bruno (2012), "tabexp : A Stata command for preparing tables of births and exposure from birth histories", Centre de recherche en demographie et societes, Universite catholique de Louvain.

{marker ref}
{title:References}

Rutstein S.O, Rojas G. (2006), {it:Guide to DHS Statistics}, Demographic and Health Surveys, ORC Macro, Calverton.

Schoumaker Bruno (2004), "A person-period approach to analyzing birth histories", {it:Population-E}, vol.59, pp. 689-702.

Schoumaker Bruno (2012), "A Stata module for computing fertility rates and TFRs from
birth histories: tfr2", Demographic Research, vol. 28.

{marker dis}
{title:Disclaimer}

Disclaimer:  There is no warranty on this program either expressed or implied.

{p 4 4 2}

{marker aut}
{title:Author}

   Bruno Schoumaker
   Centre de recherche en demographie et societes
   Universite catholique de Louvain
   Belgium
   bruno.schoumaker@uclouvain.be
   

Version 1.2.1 17May2013

