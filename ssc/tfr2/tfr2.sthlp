{smcl}
{* 17may13}{...}
{hline}
help for {hi:tfr2}
{hline}

{title:Title}

{p 4 4 2}{hi:tfr2} {hline 2} Age-specific fertility rates (ASFRs), total fertility rates (TFRs), fertility trends and rate ratios from birth histories

{p 4 4 2}{hline 2} Please report problems and send comments and suggestions to bruno.schoumaker@uclouvain.be

{title:Table of contents}

     {help tfr2##syn:Syntax}
     {help tfr2##des:Description}
     {help tfr2##opt:Options}
     {help tfr2##exa:Examples}

     {help tfr2##ack:Acknowledgments}
     {help tfr2##cit:Citing tfr2}
     {help tfr2##ref:References}
     {help tfr2##dis:Disclaimer}
     {help tfr2##aut:Author}

{marker syn}
{title:Syntax}

{p 8 15 2}    
{cmdab:tfr2} [ {it:varlist} ] [ {cmd:if} {it:exp} ] 
[ {it:pweight}{cmd: = }{it:exp} ] 
[ {cmd:,} {it:options} ]


    {it:options} {col 26}{it:summary} {col 90}{it:default}
    {hline 100}
    
     {help tfr2##main:Main}
{col 4}	 {cmdab:bv:ar(}{it:varlist}{cmd:)} {col 26}names of birth variables {col 90}b3_01 to b3_20 (or lower)
{col 4}	 {cmdab:len:gth(}{it:integer}{cmd:)} {col 26}length of the period for the computation of the rates (years) {col 90}3
{col 4}	 {cmdab:date:s(}{it:var}{cmd:)} {col 26}date of survey (CMC) {col 90}v008
{col 4}	 {cmdab:wb:irth(}{it:var}{cmd:)} {col 26}date of birth of woman (CMC) {col 90}v011
{col 4}	 {cmdab:ag:eg(}{it:integer}{cmd:)} {col 26}size of age groups (years) {col 90}5
     {help tfr2##Opt:Options}
{col 4}	 {cmdab:cl:uster(}{it:var}{cmd:)} {col 26}cluster identifiers jackknife {col 90}
{col 4}	 {cmdab:awf:(}{it:var}{cmd:)} {col 26}all women factor {col 90}awfactt
{col 4}	 {cmdab:tr:end(}{it:integer}{cmd:)} {col 26}time intervals for fertility trends (years) {col 90}
{col 4}	 {cmdab:mina:ge(}{it:integer}{cmd:)} {col 26}minimum age for ASFRs and TFR (years) {col 90}15
{col 4}	 {cmdab:maxa:ge(}{it:integer}{cmd:)} {col 26}maximum age for ASFRs and TFR (years) {col 90}49
{col 4}	 {cmdab:end:y(}{it:integer}{cmd:)} {col 26}defines the last year of the estimation period {col 90}
{col 4}	 {cmdab:entry:(}{it:var}{cmd:)} {col 26}date of entry in the risk set (e.g. marriage for marital fertility rates) in CMC {col 90}
{col 4}	 {cmdab:cy:ears}{it:}{cmd:} {col 26}rates computed over calendar years{col 90}
{col 4}	 {cmdab:frm:}{it:}{cmd:} {col 26}uses fractional months (day of birth is randomly attributed to women and children) {col 90}
{col 4}	 {cmdab:nor:ates}{it:}{cmd:} {col 26}ASFRs are not displayed{col 90}
{col 4}	 {cmdab:notfr:}{it:}{cmd:} {col 26}TFR is not displayed{col 90}
{col 4}	 {cmdab:mac:}{it:}{cmd:} {col 26}computes mean age at childbearing {col 90}
{col 4}	 {cmdab:se:}{it:}{cmd:} {col 26}standard errors of rates are saved and/or confidence intervals displayed on graphs {col 90}
{col 4}	 {cmdab:l:evel(}{it:#}{cmd:)} {col 26}specifies the confidence level for confidence intervals {col 90}95

     {help tfr2##sav:Saving options}
{col 4}	 {cmdab:savetab:le(}{it:filename}{cmd:)} {col 26}saves table of births and exposure in a Stata file {col 90}
{col 4}	 {cmdab:saver:ates(}{it:filename}{cmd:)} {col 26}saves ASFRs and TFR in a Stata file {col 90}
{col 4}	 {cmdab:savetr:end(}{it:filename}{cmd:)} {col 26}saves TFRs in a Stata file {col 90}
{col 4}	 {cmdab:onlytab:}{it:}{cmd:} {col 26}only saves the table of births and exposure - rates are not computed {col 90}
     {help tfr2##grph:Graph options}
{col 4}	 {cmdab:gr:ates}{it:}{cmd:} {col 26}Graph of ASFRs {col 90}
{col 4}	 {cmdab:gt:rend}{it:}{cmd:} {col 26}Graph of trend of TFRs (works with the option trend) {col 90}
     {help tfr2##inp:Input options}
{col 4}	 {cmdab:inp:ut(}{it:string}{cmd:)} {col 26}format of input data file (wide or table) {col 90}wide

     {help tfr2##oth:Other options}
{col 4}	 {cmdab:dv:} {col 26}displays the name of the variables used by tfr2 {col 90}


{p 8 8 2}
{cmd:by }is allowed with tfr2.

{p 8 8 2}
{cmd:xi }is allowed with tfr2.

{p 8 8 2}
{cmd:pweight} is allowed with {cmd:tfr2}. By default, v005 is used as the weighting variable (name of weights in DHS).

{p 8 8 2}
Note that {cmd:tfr2} will work under Stata 10.0 onward.

{p 8 8 2}
Note that {cmd:tabexp} must be installed for {cmd:tfr2} to work.


{marker des}
{title:Description}

{p 4 4 2}{cmd:tfr2} is a program for analyzing birth histories from demographic surveys. It computes fertility rates, reconstructs fertility trends, and compute rate ratios for recent fertility. It is conceived to be used
with individual recode files of Demographic and Health Surveys (DHS), but can be used with any data file organized like a DHS file (see example with WFS data below).

{p 4 4 2} {cmd:tfr2} notably can be used to replicate results published in DHS reports (http://www.measuredhs.com/help/Datasets/Age-Specific_Fertility_Rates.htm).

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
 

{p 4 4 2} {cmd:tfr2} computes age-specific fertility rates (ASFRs) and total fertility rates (TFRs)
on periods defined in various ways (e.g. 3 years before the survey, 5 years before the survey, 
last 5 calendar years...). Standard errors of ASFRs and TFRs can be computed with jackknife to take account
of clustering.

{p 4 4 2} Rates are computed between exact ages (in rectangles of Lexis diagrams). By default, they are computed for periods defined as "years preceding the survey", but they can be estimated by calendar years ({cmd:cy}).

{p 4 4 2} Both general fertility rates and marital fertility rates can be computed. Marital fertility rates are computed by defining the date of marriage as the entry date (e.g. entry(v509)).

{p 4 4 2} {cmd:tfr2} also allows reconstructing fertility trends using Poisson regression. This approach relies on the 
assumption that the age pattern of fertility is constant over time.

{p 4 4 2} {cmd:tfr2} can be used to estimate rate ratios of explanatory variables. Rate ratios are obtained through a Poisson regression. This approach relies on the 
assumption that the age pattern of fertility is constant across values of the covariates.


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
{opt length}({it:#}) indicates the length of the period for the computation of fertility rates. 
By default, the length is equal to 3 years. 

{phang}
{opt dates}({it:varname}) is a variable containing the date of the survey (in CMC). By default, v008 is used. You can also remove some months from the date of the survey. 
For instance, instead of {cmd:dates}(v008) you can enter {cmd:dates}(v008-36).

{phang}
{opt wbirth}({it:varname}) is a variable containing the date of birth of women (in CMC). By default, v011 is used.
 
{phang}
{opt ageg}({it:#}) is the size of age groups for the computation of ASFRs. By default, 5-year age groupes are used.


{marker opt}
{dlgtab: Options}

{phang}
{cmd: cluster}({it:varname}) indicates the name of the variable containing the identifiers of the primary sampling units (usually v021 in DHS).
If cluster is used, standard errors of rates are computed with jackknife.

{phang}
{cmd: awf}({it:varname}) indicates the name of the variable containing the "all women factor" to be used. This is necessary in surveys where only 
ever married women were interviewed (e.g. Bangladesh, Pakistan,...). By default, the variable awfactt is used.

{phang}
{cmd: trend}({it:#}) is used to compute fertility trends. The integer indicates the size of the intervals for computing TFRs. For instance, a value of 1 means that  
annual fertility rates are computed. If  {cmd: trend} is used, it should be lesser or equal than {cmd: length}.

{phang}
{cmd: minage}({it:#}) is used to set the minimum age to compute fertility rates. The default value is 15.

{phang}
{cmd: maxage}({it:#}) is used to set the maximum (completed) age to compute fertility rates. The default value is 49.

{phang}
{cmd: endy}({it:#}) is used to define the last year of the estimation period. It overrides {cmd: dates} if both are used.

{phang}
{cmd: entry}({it:varname}) is used to compute fertility rates after a date (that may vary across individuals). For instance, it can be used to compute marital fertility rates, by including the date of marriage (in CMC).

{phang}
{cmd: cyears} is used to compute fertility rates over calendar years. By default, rates are computed for years preceding the survey.

{phang}
{cmd: norates} ASFRS are not displayed. 

{phang}
{cmd: notfr} TFR is not displayed.

{phang}
{cmd: mac} computes and displays mean age at childbearing.

{phang}
{cmd: se} indicates that standard errors of rates are saved and/or confidence intervals displayed on a graph. 

{phang}
{cmd: level}({it:#}) specifies the confidence level for confidence intervals.  The default value is 95 (95% confidence intervals). # may be between 10.00 and 99.99.


{marker sav}
{dlgtab: Save options}

{phang}
{cmd: savetable}({it:filename}) saves the table including births and exposure used to estimate rates in a Stata file. To overwrite an existing file, use {cmd: savetable}({it:filename}, replace)

{phang}
{cmd: saverates}({it:filename}) saves fertility rates in a Stata data file. To overwrite an existing file, use {cmd: saverates}({it:filename}, replace)

{phang}
{cmd: savetrend}({it:filename}) saves trends of TFRs in a Stata data file. To overwrite an existing file, use {cmd: savetrend}({it:filename}, replace)

{phang}
{cmd: onlytab} only saves the table of births and exposure. No other output is produced.


{marker grph}
{dlgtab: Graph options}

{phang}
{cmd: grates} displays a graph of age-specific fertility rates

{phang}
{cmd: gtrend} displays a graph of the trend of TFRs (works with the {cmd:trend} option).

{marker inp}
{dlgtab: Input options}

{phang}
{cmd: input(wide|table)} This allows using tfr2 with individual data (wide, default option), or with a table of births and exposure (table). Currently, only tables prepared by {cmd: tabexp} are supported if you use {cmd: input(table)}.

{marker oth}
{dlgtab: Other options}

{phang}
{cmd: dv} displays the names of the variables used by tfr2. This is useful for checking that the correct variables are used.


{marker exa}
{title:Examples with DHS data}

        {txt} Individual recode data files can be obtained from MeasureDHS (www.measuredhs.com).
	{txt} Once you have downloaded the individual recode Stata file for a survey, open it:

        {com}. use KEIR51FL.DTA, clear

        {txt} This opens the file of the 2008 Kenya DHS.

        {txt} {cmd:tfr2} can then be used to compute fertility rates, fertility trends, rate ratios of explanatory variables.


Fertility levels

{p 4 4 2}

{dlgtab:Fertility rates for last x years before the survey}

        {com}. tfr2 
		
        {txt} ASFRs (5-year age groups) and TFRs for the 3 years preceding the survey

	{txt} This is equivalent to 

        {com}. tfr2 [pweight=v005], ageg(5) len(3) wb(v011) dates(v008) awf(awfactt) 
		
        {txt} ASFRs (5-year age groups) and TFRs for the 3 years preceding the survey. 

       {com}. tfr2, len(5) 
		
        {txt} ASFRs (5-year age groups) and TFRs for the 5 years preceding the survey.

        {com}. tfr2, len(1) 
		
        {txt} ASFRs (5-year age groups) and TFRs for the year preceding the survey.

        {com}. tfr2, ageg(1) 
		
        {txt} ASFRs (by single year) and TFRs for the 3 years preceding the survey.

        {com}. tfr2, norates 
		
        {txt} TFRs for the 3 years preceding the survey.


{dlgtab:Fertility rates for x calendar years before the survey}

        {com}. tfr2, len(4) cy 
		
        {txt} ASFRs (5-year age groups) and TFRs for the 4 calendar years preceding the survey 
	{txt} (if the survey was conducted in 1999 - rates computed for the period 1995-1998).


{dlgtab:Fertility rates for last x years before the survey and jackknife standard errors}

        {com}. tfr2, len(3) cluster(v001)
		
        {txt} ASFRs (5-year age groups) and TFRs for the 3 years preceding the survey
	{txt} with jackknife standard errors.

{dlgtab:Fertility rates for last x specific calendar years}

        {com}. tfr2, len(3) endy(1999)
		
        {txt} ASFRs (5-year age groups) and TFRs for the 3-year period ending in 1999.
	{txt} Rates are computed for the period from 1/1997 to 12/1999.

{dlgtab:Marital fertility rates for the x years preceding the survey}

        {com}. tfr2, len(5) entry(v509) 
		
        {txt} Marital ASFRs (5-year age groups) and TFRs for the 5 years preceding the survey.



Fertility trends


{dlgtab:Fertility trends by calendar years for x calendar years before the survey}

        {com}. tfr2, len(15) trend(1) cy
		
        {txt} TFRs(15-49) for the 15 calendar years preceding the survey. 

{dlgtab:Fertility trends by calendar years for x calendar years before the survey between ages 20 and 39}

        {com}. tfr2, len(15) trend(1) mina(20) maxa(39) cy
		
        {txt} TFRs(20-39) for the 15 calendar years preceding the survey.


Explanatory variables


{dlgtab:Fertility rates for x calendar years before the survey by categories of a variable}

        {com}. by v106, sort : tfr2
		
        {txt} ASFRs (5-year age groups) and TFRs for the 3 years preceding the survey by category of v106.


        {com}. by v025, sort : tfr2, awf(awfactu)

        {txt} Same as in previous example, but the 'all women factor' is used for rural-urban comparisons.

{dlgtab:Fertility rates for the x years preceding the survey and rate ratios for categories of variable}

        {com}. xi: tfr2 i.v106, len(5) 
		
        {txt} ASFRs (5-year age groups) and TFRs for the 5 years preceding the survey for the reference category of v106 (education in DHS).
        {txt} Rate ratios for the other categories of v106.


Saving files and displaying graph


{dlgtab:Fertility rates for x calendar years before the survey - saved in a file and displayed on a graph}

        {com}. tfr2, len(4) cy gr saver(c:\rates, replace)
		
        {txt} TFRs(15-49) for the 4 calendar years preceding the survey, saved in a file and displayed on a graph. 

{dlgtab:Fertility trends for x calendar years before the survey - saved in a file and displayed on a graph}

        {com}. tfr2, len(15) trend(1) cy gt savetr(c:\trend, replace)
		
        {txt} TFRs(15-49) for the 15 calendar years preceding the survey, saved in a file and displayed on a graph.

{dlgtab:Fertility trends for x calendar years before the survey - saves table of births and exposure in a file}

        {com}. tfr2, len(5) trend(1) cy gt savet(c:\birth_exp, replace)
		
        {txt} TFRs(15-49) for the 5 calendar years preceding the survey, table of births and exposure saved in a file. 

{dlgtab:Fertility rates for x calendar years before the survey - displayed on a graph with 95% confidence interval}

        {com}. tfr2, len(4) cy gr se
		
        {txt} TFRs(15-49) for the 4 calendar years preceding the survey, displayed on a graph with 95% confidence interval. 


{marker exa}
{title:Examples with WFS data}
	

{dlgtab:Fertility rates for last 3 years before the survey by single year of age}

        {com}. use http://data.princeton.edu/eco572/datasets/cofertx, clear
        {com}. tfr2, dates(v007) wb(v008) bvar(b0*2 b1*2) ageg(1)  
		
        {txt} This replicates the computation of fertility rates in the 1976 WFS in Colombia 
        {txt} as on Germán Rodriguez's website (http://data.princeton.edu/eco572/asfr.html).



{marker ack}
{title:Acknowledgements}

Thanks to all the users who have provided useful feedback.

{marker cit}
{title:Citing tfr2}

Schoumaker Bruno (2012), "A Stata module for computing fertility rates and TFRs from
birth histories: tfr2", Demographic Research, vol. 28.

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
   

Version 1.1.1c 17May2013

